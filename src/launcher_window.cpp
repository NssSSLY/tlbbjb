#include "launcher_window.hpp"
#include "ui_styles.hpp"

#include "legacy_runner.hpp"
#include "profile_config.hpp"

#include "session_panel.hpp"
#include "feature_plan.hpp"

#include "flow_runner.hpp"
#include "task_completion.hpp"

#include "official_launcher.hpp"
#include "multi_open.hpp"

#include "gameplay_client.hpp"

#include <QAbstractSpinBox>
#include <QDoubleSpinBox>
#include <QListWidget>

#include <QApplication>

#include <QCheckBox>

#include <QCloseEvent>

#include <QComboBox>

#include <QDateTime>
#include <QCryptographicHash>
#include <QFile>

#include <QDialog>

#include <QDialogButtonBox>

#include <QDir>

#include <QFileDialog>

#include <QFileInfo>

#include <QFormLayout>

#include <QFontMetrics>

#include <QGroupBox>

#include <QImage>

#include <QInputDialog>
#include <QMessageBox>

#include <QJsonArray>

#include <QJsonDocument>

#include <QLabel>
#include <QPlainTextEdit>

#include <QLineEdit>

#include <QListWidget>

#include <QMenu>

#include <QProcess>

#include <QPushButton>

#include <QScreen>

#include <QStyle>

#include <QSystemTrayIcon>

#include <QTableWidget>

#include <QTabWidget>

#include <QThread>

#include <QTimer>

#include <QTimeEdit>

#include <QUuid>

#include <QVBoxLayout>

#include <QWinEventNotifier>

#include <tlhelp32.h>



namespace tlbb {

static MainWindow *activeWindow=nullptr;

[[maybe_unused]] static bool startOfficialButton(QProcess *process,const QString &root){

    if(!process||process->state()!=QProcess::Running)return false;

    const DWORD pid=DWORD(process->processId());HANDLE handle=OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION,FALSE,pid);if(!handle)return false;

    wchar_t path[32768]{};DWORD length=32768;bool same=QueryFullProcessImageNameW(handle,0,path,&length)&&QFileInfo(QString::fromWCharArray(path)).canonicalFilePath().compare(QFileInfo(root+"/Launch.exe").canonicalFilePath(),Qt::CaseInsensitive)==0;CloseHandle(handle);if(!same)return false;

    struct Search{DWORD pid;HWND button=nullptr;} search{pid};

    EnumWindows([](HWND top,LPARAM value)->BOOL{auto &s=*reinterpret_cast<Search*>(value);DWORD pid=0;GetWindowThreadProcessId(top,&pid);if(pid!=s.pid||!IsWindowVisible(top))return TRUE;

        EnumChildWindows(top,[](HWND child,LPARAM inner)->BOOL{auto &s=*reinterpret_cast<Search*>(inner);wchar_t cls[32]{},text[128]{};GetClassNameW(child,cls,32);if(_wcsicmp(cls,L"Button")||!IsWindowVisible(child)||!IsWindowEnabled(child))return TRUE;GetWindowTextW(child,text,128);auto name=QString::fromWCharArray(text).remove('&').trimmed();if(name=="开始游戏"||name=="进入游戏"){s.button=child;return FALSE;}return TRUE;},value);return s.button?FALSE:TRUE;},LPARAM(&search));

    if(!search.button)return false;

    DWORD_PTR result=0;SendMessageTimeoutW(search.button,BM_CLICK,0,0,SMTO_ABORTIFHUNG|SMTO_BLOCK,250,&result);

    return true; // Never repeat a delivery with uncertain completion.

}

struct MainWindow::Session {

    GameInfo info;

    QString id,key,source,status="正在绑定";

    bool profileLocked=false; // the role's saved configuration is damaged: never save the panel over it

    ProcessBinding binding;

    QJsonObject identity,live;

    SessionPanel *panel=nullptr;

    QObject *context=nullptr;

    QProcess *worker=nullptr;

    QWinEventNotifier *exitWatch=nullptr;

    QByteArray output;

    QElapsedTimer heartbeat;

    QJsonArray queue;

    FlowRunner flow;

    int next=0;

    bool ready=false,running=false,detaching=false,liveAvailable=false,queueActive=false;

    qint64 bytes=0;

};

static void CALLBACK onForeground(HWINEVENTHOOK,DWORD,HWND,LONG,LONG,DWORD,DWORD){

    if(activeWindow)QMetaObject::invokeMethod(activeWindow,[]{if(activeWindow)activeWindow->syncHotkeys();},Qt::QueuedConnection);

}

MainWindow::MainWindow(const QString &requestedRoot,const QString &script,bool testMode,const QString &dataRoot)

    :store_(dataRoot.isEmpty()?QCoreApplication::applicationDirPath()+"/data":dataRoot),script_(script),testMode_(testMode){

    QString error;store_.load(error);

    setWindowTitle("TLBB 启动器 · 0.15.0");resize(690,360);setMinimumSize(620,330);setFont(QFont("Microsoft YaHei UI",9));

    setStyleSheet(QStringLiteral("QWidget{background:#f3f5f7;color:#1d2c3f;} QLineEdit,QComboBox,QListWidget{background:white;border:1px solid #cbd3df;padding:5px;} QPushButton{background:white;border:1px solid #cbd3df;border-radius:3px;padding:5px 9px;} QGroupBox{border:1px solid #cbd3df;margin-top:8px;padding:10px;} QGroupBox::title{subcontrol-origin:margin;left:8px;padding:0 4px;}") + checkboxStyleSheet());

    auto *central=new QWidget;setCentralWidget(central);auto *outer=new QVBoxLayout(central);outer->setContentsMargins(12,12,12,8);

    auto *path=new QHBoxLayout;path->addWidget(new QLabel("游戏目录"));root_=new QLineEdit(requestedRoot.isEmpty()?store_.launcher.value("game_root").toString("E:/game/tlbb"):requestedRoot);path->addWidget(root_,1);auto *browse=new QPushButton("浏览"),*savePath=new QPushButton("保存");path->addWidget(browse);path->addWidget(savePath);outer->addLayout(path);

    connect(browse,&QPushButton::clicked,this,[this]{if(loginWorker_||launchTime_.isValid())return;auto folder=QFileDialog::getExistingDirectory(this,"选择游戏安装目录",root_->text());if(!folder.isEmpty()){root_->setText(QDir::toNativeSeparators(folder));saveLauncher();}});

    connect(savePath,&QPushButton::clicked,this,[this]{saveLauncher();status_->setText(QFileInfo::exists(gameRoot()+"/Launch.exe")?"目录已保存":"目录已保存；未找到 Launch.exe");refreshGames();syncHotkeys();});

    auto *row=new QHBoxLayout;auto *left=new QVBoxLayout;accounts_=new QListWidget;accounts_->setMaximumWidth(205);accounts_->setMinimumWidth(150);left->addWidget(accounts_,1);auto *ab=new QHBoxLayout;auto *add=new QPushButton("添加账号"),*edit=new QPushButton("编辑");ab->addWidget(add);ab->addWidget(edit);left->addLayout(ab);row->addLayout(left);

    auto *group=new QGroupBox("登录配置");auto *form=new QFormLayout(group);district_=new QComboBox;district_->setEditable(true);district_->addItem("网通-华北网通一区");server_=new QComboBox;server_->setEditable(true);server_->addItem("五台山");district_->lineEdit()->setPlaceholderText("选择或输入游戏大区");server_->lineEdit()->setPlaceholderText("选择或输入服务器名称");role_=new QComboBox;form->addRow("大区",district_);form->addRow("服务器",server_);form->addRow("角色",role_);multi_=new QCheckBox("允许多开");multi_->setChecked(true);multi_->hide();row->addWidget(group,1);outer->addLayout(row,1);

    auto *bottom=new QHBoxLayout;status_=new QLabel(error.isEmpty()?"就绪":error);status_->setWordWrap(true);bottom->addWidget(status_,1);auto *start=new QPushButton("开始游戏");startButton_=start;start->setObjectName("startGame");start->setStyleSheet("background:#146e78;color:white;padding:7px 18px;");bottom->addWidget(start);outer->addLayout(bottom);

    connect(add,&QPushButton::clicked,this,[this]{editAccount(true);});connect(edit,&QPushButton::clicked,this,[this]{editAccount(false);});

    connect(accounts_,&QListWidget::currentRowChanged,this,[this](int){if(!loading_)chooseAccount(accounts_->currentItem()?accounts_->currentItem()->data(Qt::UserRole).toString():QString());});

    connect(district_,&QComboBox::currentTextChanged,this,[this]{if(!loading_){fillRoles();saveLauncher();}});connect(server_,&QComboBox::currentTextChanged,this,[this]{if(!loading_){fillRoles();saveLauncher();}});connect(role_,&QComboBox::currentIndexChanged,this,[this]{if(!loading_)saveLauncher();});connect(multi_,&QCheckBox::toggled,this,[this]{saveLauncher();});connect(start,&QPushButton::clicked,this,[this]{launchGame();});loadAccounts();

    workerJob_=CreateJobObjectW(nullptr,nullptr);if(workerJob_){JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};limits.BasicLimitInformation.LimitFlags=JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE|JOB_OBJECT_LIMIT_PROCESS_MEMORY|JOB_OBJECT_LIMIT_JOB_MEMORY;limits.ProcessMemoryLimit=192ULL*1024*1024;limits.JobMemoryLimit=512ULL*1024*1024;JOBOBJECT_CPU_RATE_CONTROL_INFORMATION cpu{};cpu.ControlFlags=JOB_OBJECT_CPU_RATE_CONTROL_ENABLE|JOB_OBJECT_CPU_RATE_CONTROL_HARD_CAP;cpu.CpuRate=1000;if(!SetInformationJobObject(workerJob_,JobObjectExtendedLimitInformation,&limits,sizeof(limits))||!SetInformationJobObject(workerJob_,JobObjectCpuRateControlInformation,&cpu,sizeof(cpu))){CloseHandle(workerJob_);workerJob_=nullptr;}}

    if(!workerJob_)status_->setText("Worker 隔离不可用，禁止开始脚本");

    if(!testMode_){activeWindow=this;qApp->installNativeEventFilter(this);foregroundHook_=SetWinEventHook(EVENT_SYSTEM_FOREGROUND,EVENT_SYSTEM_FOREGROUND,nullptr,onForeground,0,0,WINEVENT_OUTOFCONTEXT);connect(qApp,&QApplication::focusChanged,this,[this]{syncHotkeys();});allStopRegistered_=RegisterHotKey(nullptr,0x5104,MOD_CONTROL|MOD_ALT|MOD_NOREPEAT,VK_END);

        tray_=new QSystemTrayIcon(style()->standardIcon(QStyle::SP_ComputerIcon),this);tray_->setToolTip("TLBB 启动器");auto *menu=new QMenu(this);menu->addAction("启动器",this,[this]{showNormal();raise();activateWindow();});menu->addAction("停止全部任务",this,[this]{stopAll();});menu->addAction("退出软件",this,[this]{quitClient();});tray_->setContextMenu(menu);connect(tray_,&QSystemTrayIcon::activated,this,[this](QSystemTrayIcon::ActivationReason reason){if(reason==QSystemTrayIcon::DoubleClick){showNormal();raise();activateWindow();}});if(QSystemTrayIcon::isSystemTrayAvailable())tray_->show();}

    auto *refresh=new QTimer(this);refreshTimer_=refresh;refresh->setInterval(1000);connect(refresh,&QTimer::timeout,this,[this]{refreshGames();syncHotkeys();for(auto *s:sessions_.values())if(!s->detaching&&s->flow.active()&&!s->running)runNext(s);});refresh->start();

    auto *supervise=new QTimer(this);supervise->setInterval(500);connect(supervise,&QTimer::timeout,this,[this]{for(auto *s:sessions_.values()){if(!s->detaching&&s->heartbeat.elapsed()>5000)detach(s->info.pid,"Worker 响应超时");else if(!s->detaching&&s->panel->isVisible())updatePanel(s);}});supervise->start();refreshGames();

}

MainWindow::~MainWindow(){

    cancelLogin();

    disconnect(qApp,nullptr,this,nullptr);for(auto *timer:findChildren<QTimer*>())timer->stop();

    for(auto *child:findChildren<QObject*>())QObject::disconnect(child,nullptr,this,nullptr);

    activeWindow=nullptr;if(foregroundHook_)UnhookWinEvent(foregroundHook_);qApp->removeNativeEventFilter(this);for(int id:{0x5101,0x5102,0x5103,0x5104})UnregisterHotKey(nullptr,id);

    for(auto *s:sessions_.values()){QObject::disconnect(s->worker,nullptr,s->context,nullptr);if(s->worker->state()!=QProcess::NotRunning){s->worker->kill();s->worker->waitForFinished(500);}saveProfile(s);s->panel->retire();delete s->panel;delete s->context;delete s;}sessions_.clear();

    const auto labels=toasts_.values();toasts_.clear();for(auto *l:labels)delete l;if(workerJob_)CloseHandle(workerJob_);

}

QString MainWindow::gameRoot()const{return QDir::cleanPath(QDir::fromNativeSeparators(root_->text().trimmed()));}

void MainWindow::loadAccounts(){loading_=true;accounts_->clear();auto *temporary=new QListWidgetItem("未保存账号",accounts_);temporary->setData(Qt::UserRole,QString());for(const auto &v:store_.launcher.value("accounts").toArray()){auto a=v.toObject();auto *item=new QListWidgetItem(a.value("alias").toString("账号"),accounts_);item->setData(Qt::UserRole,a.value("id"));}QString id=store_.launcher.value("selected_account").toString();int index=0;for(int i=0;i<accounts_->count();++i)if(accounts_->item(i)->data(Qt::UserRole).toString()==id)index=i;accounts_->setCurrentRow(index);loading_=false;chooseAccount(id);}

void MainWindow::chooseAccount(const QString &id){selectedAccount_=id;loading_=true;QJsonObject a;for(const auto &v:store_.launcher.value("accounts").toArray())if(v.toObject().value("id").toString()==id)a=v.toObject();district_->setCurrentText(a.value("district").toString(store_.launcher.value("district").toString("网通-华北网通一区")));server_->setCurrentText(a.value("server").toString(store_.launcher.value("server").toString("五台山")));loading_=false;fillRoles();role_->setCurrentIndex(qMax(0,role_->findData(a.value("slot").toInt(1))));}

void MainWindow::fillRoles(){bool before=loading_;loading_=true;int old=role_->currentData().toInt();QJsonObject names;for(const auto &v:store_.launcher.value("accounts").toArray())if(v.toObject().value("id").toString()==selectedAccount_)names=v.toObject().value("destinations").toObject().value(district_->currentText()+"/"+server_->currentText()).toObject().value("roles").toObject();role_->clear();int count=3;for(const auto &key:names.keys())count=qBound(3,qMax(count,key.toInt()),12);for(int i=1;i<=count;++i)role_->addItem(names.value(QString::number(i)).toString(QString("角色 %1").arg(i)),i);role_->setCurrentIndex(qMax(0,role_->findData(old)));loading_=before;}

QJsonObject MainWindow::selectedIdentity()const{return {{"account",selectedAccount_},{"district",district_->currentText().trimmed()},{"server",server_->currentText().trimmed()},{"slot",role_->currentData().toInt()}};}

bool MainWindow::saveLauncher(){if(loading_)return true;store_.launcher.insert("game_root",gameRoot());store_.launcher.insert("multi_open",multi_->isChecked());store_.launcher.insert("selected_account",selectedAccount_);store_.launcher.insert("district",district_->currentText());store_.launcher.insert("server",server_->currentText());auto accounts=store_.launcher.value("accounts").toArray();for(int i=0;i<accounts.size();++i){auto a=accounts[i].toObject();if(a.value("id").toString()==selectedAccount_){a.insert("district",district_->currentText());a.insert("server",server_->currentText());a.insert("slot",role_->currentData().toInt());accounts[i]=a;}}store_.launcher.insert("accounts",accounts);QString error;if(!store_.save(error)){status_->setText(error);return false;}return true;}

void MainWindow::editAccount(bool isNew){if(loginWorker_||launchTime_.isValid()){status_->setText("请先取消本次登录，再修改账号");return;}QJsonObject original;auto list=store_.launcher.value("accounts").toArray();for(const auto &v:list)if(v.toObject().value("id").toString()==selectedAccount_)original=v.toObject();if(!isNew&&original.isEmpty()){status_->setText("请先添加或选择账号");return;}

    QDialog dialog(this);dialog.setWindowTitle(isNew?"添加账号":"编辑账号");auto *layout=new QFormLayout(&dialog);auto *alias=new QLineEdit(original.value("alias").toString()),*login=new QLineEdit(original.value("login").toString()),*password=new QLineEdit;password->setEchoMode(QLineEdit::Password);alias->setPlaceholderText("例如：主账号");login->setPlaceholderText("输入游戏登录账号");password->setPlaceholderText(isNew?"输入游戏密码":"留空保留密码（需勾选保存）");alias->setMaxLength(64);login->setMaxLength(128);password->setMaxLength(128);auto *remember=new QCheckBox("保存密码以自动登录（本机加密）");remember->setChecked(true);layout->addRow("别名",alias);layout->addRow("账号",login);layout->addRow("密码",password);layout->addRow(remember);auto *buttons=new QDialogButtonBox(QDialogButtonBox::Ok|QDialogButtonBox::Cancel);layout->addRow(buttons);connect(buttons,&QDialogButtonBox::accepted,&dialog,&QDialog::accept);connect(buttons,&QDialogButtonBox::rejected,&dialog,&QDialog::reject);
    // A failed save re-opens the dialog with what was entered; nothing continues on stale account data.
    const auto previous=store_.launcher;const auto base=original;const auto baseList=list;
    for(;;){if(dialog.exec()!=QDialog::Accepted||alias->text().trimmed().isEmpty())return;original=base;list=baseList;

    QString id=isNew?QUuid::createUuid().toString(QUuid::WithoutBraces):selectedAccount_;original.insert("id",id);original.insert("alias",alias->text().trimmed());original.insert("login",login->text().trimmed());if(remember->isChecked()&&!password->text().isEmpty()){QString error;if(!store_.savePassword(id,password->text(),error)){status_->setText(error);QMessageBox::warning(this,"账号未保存",error);continue;}original.insert("credential_ref",id);}else if(!remember->isChecked()){original.remove("credential_ref");}if(isNew)list.append(original);else for(int i=0;i<list.size();++i)if(list[i].toObject().value("id").toString()==id)list[i]=original;store_.launcher.insert("accounts",list);store_.launcher.insert("selected_account",id);QString error;
    if(!store_.save(error)){store_.launcher=previous;status_->setText(error);QMessageBox::warning(this,"账号未保存",error+"\n输入内容已保留，可修改后重试");continue;}
    password->clear();loadAccounts();return;}

}

GameInfo MainWindow::gameInfo(quint32 pid)const{for(const auto &g:discoverGames(gameRoot()))if(g.pid==pid)return g;return {};}

void MainWindow::refreshGames(){games_=discoverGames(gameRoot());for(auto key:toasts_.keys())if(!IsWindow(reinterpret_cast<HWND>(key))){auto *old=toasts_.take(key);old->deleteLater();}if(!launchTime_.isValid())return;if(launchTime_.elapsed()>600000||(officialStartTime_.isValid()&&officialStartTime_.elapsed()>90000)){launchTime_.invalidate();if(refreshTimer_)refreshTimer_->setInterval(1000);setLoginBusy(false);status_->setText("官方启动步骤超时，未发送账号密码；查看 data/logs/login-events.jsonl");loginAudit("official_launch_timeout");return;}

    HANDLE snapshot=CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);if(snapshot!=INVALID_HANDLE_VALUE){QHash<quint32,quint32> parents;PROCESSENTRY32W e{};e.dwSize=sizeof(e);if(Process32FirstW(snapshot,&e))do{parents.insert(e.th32ProcessID,e.th32ParentProcessID);}while(Process32NextW(snapshot,&e));CloseHandle(snapshot);for(int pass=0;pass<8;++pass){bool changed=false;for(auto i=parents.begin();i!=parents.end();++i)if(!launchFamily_.contains(i.key())&&launchFamily_.contains(i.value())){launchFamily_.insert(i.key());changed=true;}if(!changed)break;}}

    QVector<GameInfo> candidates;for(const auto &g:games_)if(!beforeLaunch_.contains(g.pid)&&launchFamily_.contains(g.pid)&&g.window)candidates.append(g);

    if(candidates.isEmpty()&&!testMode_&&!launchButtonSent_&&(!officialPoll_.isValid()||officialPoll_.elapsed()>1000)){

        officialPoll_.restart();QVector<QJsonObject> ready;QJsonObject observed;

        for(auto pid:launchFamily_){const auto path=processPath(pid);const auto name=QFileInfo(path).fileName();if(name.compare("Launch.exe",Qt::CaseInsensitive)&&name.compare("Launch.bin",Qt::CaseInsensitive))continue;

            HANDLE process=OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION,FALSE,pid);if(!process)continue;const auto created=processCreated(process);CloseHandle(process);auto probe=tryOfficialStart(pid,created,gameRoot(),false);if(probe.value("identified").toBool()){probe.insert("created",created);observed=probe;if(probe.value("ready").toBool())ready.append(probe);}}

        if(observed!=lastLauncherProbe_&&!observed.isEmpty()){lastLauncherProbe_=observed;loginAudit("official_launcher_state",observed);}

        if(ready.size()==1){const auto probe=ready[0];auto result=tryOfficialStart(probe.value("pid").toInt(),probe.value("created").toString(),gameRoot(),true);loginAudit("official_start_result",result);if(result.value("issued").toBool()){launchButtonSent_=true;officialStartTime_.start();status_->setText("已自动操作官方开始游戏，等待游戏窗口");}}

        else if(ready.size()>1){status_->setText("发现多个官方启动器，已停止自动开始，未发送账号密码");loginAudit("ambiguous_official_launcher");launchTime_.invalidate();setLoginBusy(false);}

        else if(observed.value("phase").toString()=="waiting_official_update")status_->setText("等待官方更新完成，完成后自动开始游戏");
        else if(observed.value("phase").toString()=="unsupported_launcher_skin")status_->setText("官方启动器界面已更新，程序不认识按钮位置；请手动点一次“开始游戏”，进游戏后照常自动登录");

    }

    if(refreshTimer_)refreshTimer_->setInterval(launchTime_.isValid()&&(launchTime_.elapsed()<5000||(officialStartTime_.isValid()&&officialStartTime_.elapsed()<5000))?100:1000);

    if(candidates.size()==1){auto g=candidates[0];launchTime_.invalidate();if(refreshTimer_)refreshTimer_->setInterval(1000);loginAudit("game_found",{{"target_pid",int(g.pid)},{"created",g.created}});bind(g.pid,"launcher",pendingIdentity_,false);setLoginBusy(false);if(!testMode_&&!pendingIdentity_.value("account").toString().isEmpty())beginLogin(g);else status_->setText(QString("已绑定 PID %1；未选择保存的账号，请手动登录，Home 呼出任务面板").arg(g.pid));}

    else if(candidates.size()>1){launchTime_.invalidate();setLoginBusy(false);status_->setText("启动链有多个游戏窗口，请在目标游戏按 Home 绑定；没有发送登录凭据");}

}

void MainWindow::launchGame(){if(loginWorker_||launchTime_.isValid()){cancelLogin();status_->setText("本次自动登录已取消；游戏和官方启动器保持运行");return;}if(!saveLauncher()){status_->setText(status_->text()+"；账号与区服设置未保存，未开始登录");return;}auto existing=discoverGames(gameRoot());if(!multi_->isChecked()&&!existing.isEmpty()){const auto &g=existing.first();toast(g,"已有游戏运行；按 Home 绑定。再次启动请勾选允许多开");status_->setText("已有游戏；请在游戏前台按 Home 绑定，或勾选允许多开");if(g.window)SetForegroundWindow(reinterpret_cast<HWND>(g.window));return;}QString launch=gameRoot()+"/Launch.exe";if(!QFileInfo::exists(launch)){status_->setText("未找到 Launch.exe，请检查游戏目录");return;}MEMORYSTATUSEX memory{};memory.dwLength=sizeof(memory);if(GlobalMemoryStatusEx(&memory)&&memory.ullAvailPhys<2ULL*1024*1024*1024){status_->setText("可用内存不足，暂不启动新游戏");return;}

    // Reject missing credentials before launching. Test fixtures never read real account data.

    if(!testMode_&&!selectedAccount_.isEmpty()){QJsonObject account;for(const auto &v:store_.launcher.value("accounts").toArray())if(v.toObject().value("id").toString()==selectedAccount_)account=v.toObject();const auto cli=QCoreApplication::arguments();const int protectedAt=cli.indexOf("--protected-login-hash");const auto protectedHash=!protectedLoginFingerprint_.isEmpty()?protectedLoginFingerprint_:(protectedAt>=0&&protectedAt+1<cli.size()?cli[protectedAt+1]:QString());if(!protectedHash.isEmpty()&&!account.value("login").toString().isEmpty()&&ClientStore::loginFingerprint(account.value("login").toString())==protectedHash){status_->setText("此账号用于保留的在线角色，请选择另一个测试账号");return;}QByteArray secret;QString error;bool valid=!account.value("login").toString().trimmed().isEmpty()&&account.value("credential_ref").toString()==selectedAccount_&&store_.readPassword(selectedAccount_,secret,error);SecureZeroMemory(secret.data(),SIZE_T(secret.size()));secret.clear();if(!valid){status_->setText(error.isEmpty()?"请编辑账号，输入账号密码并勾选本机加密保存密码":error);return;}if(district_->currentText().trimmed().isEmpty()||server_->currentText().trimmed().isEmpty()||role_->currentData().toInt()>3){status_->setText("请填写大区、服务器，并选择角色 1 至 3");return;}}

    // 允许多开：the game itself stops at two clients; free its two instance slots in the running games.
    QString multiOpenNote;
    if(!existing.isEmpty()){QList<quint32> pids;for(const auto &g:existing)pids.append(quint32(g.pid));QString why;const int released=multi_open::releaseInstanceLimit(pids,why);
        loginAudit("multi_open_release",{{"games",int(pids.size())},{"released",released},{"detail",why}});
        if(existing.size()>=2&&!released)multiOpenNote="；未能解除游戏的双开限制"+(why.isEmpty()?QString():"（"+why+"）");}
    officialPoll_.invalidate();officialStartTime_.invalidate();lastLauncherProbe_={};loginAudit("launch_requested",{{"saved_account_selected",!selectedAccount_.isEmpty()},{"preexisting_game_count",existing.size()}});

    launchButtonSent_=false;beforeLaunch_.clear();for(const auto &g:existing)beforeLaunch_.insert(g.pid);launchFamily_.clear();pendingIdentity_=selectedIdentity();launcherProcess_=new QProcess(this);auto *process=launcherProcess_;process->setProgram(launch);process->setWorkingDirectory(gameRoot());connect(process,&QProcess::started,this,[this,process]{launchFamily_.insert(quint32(process->processId()));});connect(process,&QProcess::errorOccurred,this,[this,process](QProcess::ProcessError error){if(launcherProcess_!=process)return;launchTime_.invalidate();setLoginBusy(false);status_->setText("游戏启动器启动失败："+process->errorString());if(error==QProcess::FailedToStart){launcherProcess_=nullptr;process->deleteLater();}});connect(process,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),this,[this,process]{if(launcherProcess_==process)launcherProcess_=nullptr;process->deleteLater();});process->start();launchTime_.start();if(refreshTimer_)refreshTimer_->setInterval(100);setLoginBusy(true);status_->setText(selectedAccount_.isEmpty()?"未选择保存的账号；官方启动器打开后请手动登录":"等待官方启动器完成更新并打开游戏；游戏出现后自动选择区服、登录账号和角色");if(!multiOpenNote.isEmpty())status_->setText(status_->text()+multiOpenNote);

}

void MainWindow::setLoginBusy(bool busy){if(startButton_)startButton_->setText(busy?"取消登录":"开始游戏");for(auto *widget:{static_cast<QWidget*>(root_),static_cast<QWidget*>(district_),static_cast<QWidget*>(server_),static_cast<QWidget*>(role_),static_cast<QWidget*>(accounts_),static_cast<QWidget*>(multi_)})if(widget)widget->setEnabled(!busy);}

void MainWindow::cancelLogin(){launchTime_.invalidate();if(refreshTimer_)refreshTimer_->setInterval(1000);setLoginBusy(false);if(loginWorker_){auto *worker=loginWorker_;loginWorker_=nullptr;QObject::disconnect(worker,nullptr,this,nullptr);worker->kill();worker->waitForFinished(300);worker->deleteLater();}loginOutput_.clear();loginPid_=0;}

void MainWindow::startConfiguredGame(){launchGame();}

void MainWindow::loginAudit(const QString &event,const QJsonObject &details){

    const auto directory=store_.root+"/logs";QDir().mkpath(directory);QFile file(directory+"/login-events.jsonl");

    const bool rotate=file.exists()&&file.size()>1024*1024;if(!file.open(QIODevice::WriteOnly|(rotate?QIODevice::Truncate:QIODevice::Append)))return;

    auto record=details;record.insert("event",event);record.insert("time",QDateTime::currentDateTime().toString(Qt::ISODateWithMs));file.write(QJsonDocument(record).toJson(QJsonDocument::Compact)+'\n');

}

void MainWindow::beginLogin(const GameInfo &game){

    if(loginWorker_||!game.pid)return;

    loginPid_=game.pid;loginOutput_.clear();const auto identity=pendingIdentity_;const auto created=game.created;loginAudit("login_worker_requested",{{"target_pid",int(game.pid)}});

    auto *worker=new QProcess(this);loginWorker_=worker;worker->setProgram(QCoreApplication::applicationFilePath());worker->setWorkingDirectory(QCoreApplication::applicationDirPath());

    worker->setArguments({"--login-worker","--target-pid",QString::number(game.pid),"--created",created,"--game-root",gameRoot(),"--data-root",store_.root,"--identity",QString::fromLatin1(QJsonDocument(identity).toJson(QJsonDocument::Compact).toBase64(QByteArray::Base64UrlEncoding|QByteArray::OmitTrailingEquals))});

    worker->setProperty("terminal",false);setLoginBusy(true);status_->setText("已绑定新游戏，等待自动登录界面");

    connect(worker,&QProcess::started,this,[this,worker]{if(workerJob_&&!testMode_){HANDLE h=OpenProcess(PROCESS_SET_QUOTA|PROCESS_TERMINATE,FALSE,DWORD(worker->processId()));bool assigned=h&&AssignProcessToJobObject(workerJob_,h);if(h)CloseHandle(h);if(!assigned){status_->setText("登录进程资源限制设置失败，本次自动登录已停止");worker->kill();}}});

    connect(worker,&QProcess::readyReadStandardError,this,[worker]{worker->readAllStandardError();});

    connect(worker,&QProcess::readyReadStandardOutput,this,[this,worker,identity,created,pid=game.pid]{

        if(loginWorker_!=worker)return;

        loginOutput_+=worker->readAllStandardOutput();if(loginOutput_.size()>65536){status_->setText("登录输出异常，本次自动登录已停止");worker->kill();return;}

        while(loginOutput_.contains('\n')){int end=loginOutput_.indexOf('\n');auto object=QJsonDocument::fromJson(loginOutput_.left(end)).object();loginOutput_.remove(0,end+1);const auto kind=object.value("event").toString();const auto message=object.value("message").toString().left(180);QJsonObject audit{{"target_pid",int(pid)},{"kind",kind},{"message",message}};for(const auto &key:{"stage","command","bridge_status","win32_error","verified_world_samples"})if(object.contains(key))audit.insert(key,object.value(key));loginAudit("login_progress",audit);status_->setText(message);auto info=gameInfo(pid);if(info.created!=created)continue;

            if(auto *session=sessions_.value(pid))append(session,message);

            if(kind=="failed"||kind=="skipped"||kind=="complete"){worker->setProperty("terminal",true);toast(info,message);}

            if(kind=="complete"&&object.value("verified_world_samples").toInt()>=2){auto accounts=store_.launcher.value("accounts").toArray();for(int i=0;i<accounts.size();++i){auto account=accounts[i].toObject();if(account.value("id")!=identity.value("account"))continue;if(protectedLoginFingerprint_.isEmpty()&&QCoreApplication::arguments().contains("--protect-first-login")){protectedLoginFingerprint_=ClientStore::loginFingerprint(account.value("login").toString());protectedGamePid_=pid;protectedAccountId_=identity.value("account").toString();}const auto names=object.value("roles").toObject();for(int slot=1;slot<=3;++slot)account=ClientStore::rememberRole(account,identity.value("district").toString(),identity.value("server").toString(),slot,names.value(QString::number(slot)).toString());accounts[i]=account;}store_.launcher.insert("accounts",accounts);QString error;if(!store_.save(error))status_->setText(error);fillRoles();}

        }

    });

    connect(worker,&QProcess::errorOccurred,this,[this,worker](QProcess::ProcessError error){if(loginWorker_==worker){status_->setText("登录子进程无法运行，本次登录已停止");if(error==QProcess::FailedToStart){loginWorker_=nullptr;loginPid_=0;setLoginBusy(false);worker->deleteLater();}}});

    connect(worker,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),this,[this,worker](int,QProcess::ExitStatus){if(loginWorker_==worker){if(!worker->property("terminal").toBool())status_->setText("自动登录已停止；请检查游戏提示");loginWorker_=nullptr;loginPid_=0;loginOutput_.clear();setLoginBusy(false);}worker->deleteLater();});worker->start();

}

void MainWindow::toast(const GameInfo &g,const QString &message){

    if(!g.window||!IsWindow(reinterpret_cast<HWND>(g.window)))return;

    auto *label=toasts_.value(g.window);

    if(auto *s=sessions_.value(g.pid);s&&s->panel&&s->panel->isVisible()){

        if(label)label->hide();

        s->panel->appendLog(QDateTime::currentDateTime().toString("HH:mm:ss ")+message.left(180));

        return;

    }

    if(!label){

        label=new QLabel(nullptr,Qt::Tool|Qt::FramelessWindowHint|Qt::WindowDoesNotAcceptFocus|Qt::WindowTransparentForInput);

        label->setAttribute(Qt::WA_ShowWithoutActivating);label->setWordWrap(false);label->setTextFormat(Qt::PlainText);

        label->setAlignment(Qt::AlignCenter);label->setFont(QFont("Microsoft YaHei UI",9));

        label->setStyleSheet("background:#173747;color:#ffffff;border:1px solid #7ab8c1;border-radius:3px;padding:3px 10px;");

        SetWindowLongPtrW(reinterpret_cast<HWND>(label->winId()),GWLP_HWNDPARENT,LONG_PTR(g.window));

        auto *timer=new QTimer(label);timer->setObjectName("dismiss");timer->setSingleShot(true);

        connect(timer,&QTimer::timeout,label,&QWidget::hide);toasts_.insert(g.window,label);

    }

    const HWND game=reinterpret_cast<HWND>(g.window);

    RECT r{};if(!GetClientRect(game,&r))return;POINT p{0,0};if(!ClientToScreen(game,&p))return;

    const HWND overlay=reinterpret_cast<HWND>(label->winId());

    // Move to the game's monitor first. A DPI-unaware game reports 96 DPI even

    // when this Qt overlay uses display scaling, so size using the overlay DPI.

    SetWindowPos(overlay,HWND_TOP,p.x+(r.right-r.left)/2,p.y+12,0,0,SWP_NOSIZE|SWP_NOACTIVATE);

    const qreal scale=label->devicePixelRatioF();

    const auto text=message.left(180).simplified();const auto metrics=label->fontMetrics();

    const int maximum=qMax(1,qMin(360,int((r.right-r.left)/scale)-24));

    const int width=qMin(maximum,qMax(140,metrics.horizontalAdvance(text)+24));

    const int height=qBound(24,metrics.height()+8,30);

    label->setText(metrics.elidedText(text,Qt::ElideRight,qMax(1,width-24)));label->resize(width,height);

    // Native client coordinates are physical pixels; keep the DPI conversion together.

    const int physicalWidth=qRound(width*scale),physicalHeight=qRound(height*scale);

    const int x=p.x+(r.right-r.left-physicalWidth)/2,y=p.y+qRound(12*scale);

    SetWindowPos(overlay,HWND_TOP,x,y,physicalWidth,physicalHeight,SWP_NOACTIVATE);

    label->show();SetWindowLongPtrW(overlay,GWLP_HWNDPARENT,LONG_PTR(g.window));

    SetWindowPos(overlay,HWND_TOP,x,y,physicalWidth,physicalHeight,SWP_NOACTIVATE);

    label->findChild<QTimer*>("dismiss")->start(1600);

}

void MainWindow::append(Session *s,const QString &message){QString line=QDateTime::currentDateTime().toString("HH:mm:ss ")+message.left(1024);if(s&&s->panel){s->status=message.left(180);s->panel->appendLog(line);

        // Session log for acceptance review; bounded and kept in the software folder, no credentials.

        QDir().mkpath(store_.root+"/logs");QFile log(store_.root+QString("/logs/session-%1-%2.log").arg(s->info.pid).arg(QDate::currentDate().toString("yyyyMMdd")));

        if(log.size()<2*1024*1024&&log.open(QIODevice::Append|QIODevice::Text))log.write((line+"\n").toUtf8());
        if(s->panel->isVisible())updatePanel(s);}else status_->setText(message.left(180));}

void MainWindow::bind(quint32 pid,const QString &source,QJsonObject identity,bool show){

    auto info=gameInfo(pid);if(!info.pid||!info.window){status_->setText("未找到目标游戏窗口");return;}

    if(auto *s=sessions_.value(pid)){if(!s->detaching&&s->binding.alive()&&s->info.created==info.created){if(show)s->panel->showForGame();return;}toast(info,"旧会话正在清理，请稍后按 Home");return;}

    toast(info,"正在绑定游戏 · 校验进程与窗口");if(!workerJob_||sessions_.size()>=8){toast(info,"绑定失败：资源隔离不可用或会话已达上限");return;}

    auto *s=new Session;s->context=new QObject(this);if(!s->binding.open(pid,gameRoot(),info.created)){toast(info,"绑定失败："+s->binding.error);delete s->context;delete s;return;}

    s->info=info;s->source=source;s->identity=identity;s->id=QUuid::createUuid().toString(QUuid::WithoutBraces);s->key=identity.value("account").toString().isEmpty()?"unassigned/"+QString::number(pid)+"/"+info.created:ClientStore::roleKey(identity);QJsonObject saved;QString profileNote;const auto state=store_.loadProfile(s->key,saved,profileNote);s->profileLocked=state==ClientStore::ProfileState::Damaged;s->panel=new SessionPanel(info,saved);s->heartbeat.start();sessions_.insert(pid,s);if(!profileNote.isEmpty())QTimer::singleShot(0,s->context,[this,s,profileNote]{if(sessions_.values().contains(s))append(s,profileNote);});

    s->panel->runRequested=[this,s](QJsonArray q){runQueue(s,q);};s->panel->flowRequested=[this,s](QJsonObject plan){runPlan(s,plan);};s->panel->pauseRequested=[this,s]{if(!s->flow.active())return;s->flow.pause(!s->flow.paused());if(s->running)send(s,{{"op","pause"}});s->status=s->flow.status();updatePanel(s);};s->panel->stopRequested=[this,s]{s->flow.stop();s->queueActive=false;send(s,{{"op","stop"}});s->status="已停止";updatePanel(s);};s->panel->reloadRequested=[this,s]{send(s,{{"op","reload"}});};s->panel->detachRequested=[this,s]{detach(s->info.pid,"用户解绑");};s->panel->saveRequested=[this,s]{if(saveProfile(s))append(s,"此角色配置已保存");};s->panel->copyRequested=[this,s]{copyProfile(s);};s->panel->associateRequested=[this,s]{associate(s);};
    s->panel->favoritesChanged=[this,s]{saveProfile(s);};

    s->exitWatch=new QWinEventNotifier(s->binding.handle(),s->context);connect(s->exitWatch,&QWinEventNotifier::activated,s->context,[this,s]{s->exitWatch->setEnabled(false);detach(s->info.pid,"游戏已退出");});

    s->worker=new QProcess(s->context);s->worker->setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments *a){a->flags|=CREATE_NO_WINDOW;});

    connect(s->worker,&QProcess::started,s->context,[this,s]{HANDLE process=OpenProcess(PROCESS_SET_QUOTA|PROCESS_TERMINATE|PROCESS_QUERY_LIMITED_INFORMATION,FALSE,DWORD(s->worker->processId()));bool ok=process&&AssignProcessToJobObject(workerJob_,process);if(process)CloseHandle(process);if(!ok)detach(s->info.pid,"Worker 资源隔离失败");});

    connect(s->worker,&QProcess::readyReadStandardOutput,s->context,[this,s]{s->output+=s->worker->readAllStandardOutput();if(s->output.size()>256*1024){detach(s->info.pid,"Worker 输出超过上限");return;}for(int i=0;i<64;++i){int n=s->output.indexOf('\n');if(n<0)break;auto e=QJsonDocument::fromJson(s->output.left(n)).object();s->output.remove(0,n+1);if(e.value("session").toString()==s->id)handle(s,e);}});

    connect(s->worker,&QProcess::readyReadStandardError,s->context,[this,s]{auto data=s->worker->readAllStandardError();if(!data.isEmpty())append(s,"Worker："+QString::fromUtf8(data.left(1024)));});

    auto cleanup=[this,s]{s->detaching=true;const auto pid=s->info.pid;const auto id=s->id;QTimer::singleShot(0,s->context,[this,pid,id]{auto *current=sessions_.value(pid);if(current&&current->id==id)release(current);});};

    connect(s->worker,&QProcess::errorOccurred,s->context,[this,s,cleanup](QProcess::ProcessError error){append(s,s->worker->errorString());if(error==QProcess::FailedToStart)cleanup();});

    connect(s->worker,qOverload<int,QProcess::ExitStatus>(&QProcess::finished),s->context,[cleanup](int,QProcess::ExitStatus){cleanup();});

    s->worker->start(QCoreApplication::applicationFilePath(),{"--worker","--target-pid",QString::number(pid),"--created",s->info.created,"--session",s->id,"--game-root",gameRoot(),"--script",script_});

    s->panel->shown=[this,s]{if(auto *label=toasts_.value(s->info.window))label->hide();};

    if(show)s->panel->showForGame();

    append(s,"会话已建立，等待 Worker 就绪");updatePanel(s);

}

void MainWindow::release(Session *s){if(sessions_.value(s->info.pid)!=s)return;saveProfile(s);sessions_.remove(s->info.pid);s->exitWatch->setEnabled(false);s->binding.close();for(auto *dialog:s->panel->findChildren<QDialog*>())dialog->reject();s->panel->retire();s->panel->deleteLater();s->context->deleteLater();delete s;syncHotkeys();}

void MainWindow::send(Session *s,QJsonObject c){if(!s||s->detaching||s->worker->state()!=QProcess::Running)return;c.insert("session",s->id);auto data=QJsonDocument(c).toJson(QJsonDocument::Compact)+"\n";if(data.size()>8192||s->worker->bytesToWrite()>65536){append(s,"控制队列已满");return;}s->worker->write(data);}

void MainWindow::detach(quint32 pid,const QString &reason){if(loginPid_==pid)cancelLogin();auto *s=sessions_.value(pid);if(!s||s->detaching)return;s->flow.stop();s->queueActive=false;saveProfile(s);send(s,{{"op","quit"}});s->detaching=true;s->ready=false;s->running=false;s->exitWatch->setEnabled(false);s->panel->hide();toast(s->info,reason+" · 已停止脚本并解绑，不关闭游戏");s->worker->closeWriteChannel();QTimer::singleShot(1500,s->context,[s]{if(s->worker->state()!=QProcess::NotRunning)s->worker->kill();});}

void MainWindow::handle(Session *s,const QJsonObject &event){

    s->heartbeat.restart();QString type=event.value("event").toString();

    if(type=="heartbeat"){s->bytes=qint64(event.value("private_commit_bytes").toDouble());s->live=event.value("live_state").toObject();s->liveAvailable=event.value("live_position_available").toBool();if(s->panel->isVisible())updatePanel(s);return;}

    if(type=="ready"){s->ready=true;s->liveAvailable=event.value("live_position_available").toBool();s->status="绑定成功";toast(s->info,"已绑定 · Home 面板 / End 解绑");}

    if(type=="started"){s->running=true;s->status=event.value("mode").toString()=="preview"?"预演运行":"任务运行";}

    if(type=="paused")s->status=s->flow.status();

    if(type=="completed"){
        const auto result=TaskCompletion::flowOutcome(event);const bool verified=result.verified;
        const auto outcome=result.outcome;const bool limited=outcome=="limit_reached";
        s->running=false;s->status=!verified?"脚本结束 · 完成条件未核验":limited?"已达上限":outcome=="already_done"?"此前已完成":event.value("preview").toBool()?"预演完成":"任务完成";
        auto completed=s->flow.finish(verified,outcome);
        if(!verified)append(s,"Lua 已结束，但未确认任务达成；按本项失败策略处理，不删除定时配置");
        if(verified&&!limited&&completed.value("scheduled").toBool()&&s->flow.deleteCompleted()){
            completed.remove("scheduled");auto profile=s->panel->profile();profile.insert("scheduled",FlowRunner::withoutNode(profile.value("scheduled").toArray(),completed));s->panel->setProfile(profile);saveProfile(s);
        }
        if(s->flow.active())QTimer::singleShot(100,s->context,[this,s]{if(!s->detaching)runNext(s);});
    }

    if(type=="stopped"){s->running=false;s->flow.stop();s->queueActive=false;s->status="已停止";}

    if(type=="error"||type=="blocked"){s->running=false;s->flow.finish(false);s->queueActive=s->flow.active();s->status="执行被阻止 · "+s->flow.status();}

    if(type=="target_exited")detach(s->info.pid,"游戏已退出");

    if(!event.value("message").toString().isEmpty())append(s,event.value("message").toString());

    updatePanel(s);

}

void MainWindow::runLegacyQueue(Session *s,QJsonArray queue){

    if(!s->ready||s->detaching||s->running)return;

    if(queue.isEmpty()){append(s,"任务流程为空");return;}

    for(const auto &value:queue){auto n=value.toObject(),p=n.value("params").toObject();auto id=n.value("task").toString();QString mode=p.value("mode").toString(id=="luoyang_move"?"live_move":"live");

        if(id=="luoyang_move"){append(s,"洛阳坐标移动测试项已移除，请从保存的任务列表删除该项");return;}
        if(id!="plant"){append(s,"该任务尚未适配，流程没有开始："+id);toast(s->info,"任务待适配，未执行");return;}

        if(mode!="preview"&&id!="luoyang_move"){append(s,"真实种植尚未适配，未执行");return;}

        if(mode=="live_move"&&!s->liveAvailable){append(s,"真实位置尚不可用，先完成登录并核对版本");return;}

        if(id=="luoyang_move")p.insert("operation","move");

        QString error;if(!validatePlantConfig(p,error)){append(s,error);return;}

    }s->queue=queue;s->next=0;s->queueActive=true;saveProfile(s);runNext(s);

}

void MainWindow::runLegacyNext(Session *s){if(!s->queueActive||s->detaching)return;if(s->next>=s->queue.size()){s->queueActive=false;s->status="流程完成";updatePanel(s);return;}auto n=s->queue[s->next++].toObject(),p=n.value("params").toObject();QString id=n.value("task").toString();QString mode=p.take("mode").toString(id=="luoyang_move"?"live_move":"live");if(id=="luoyang_move")p.insert("operation","move");s->running=true;send(s,{{"op","start"},{"mode",mode},{"config",p}});}

void MainWindow::runQueue(Session *s,QJsonArray queue){

    for(int i=0;i<queue.size();++i){auto node=queue[i].toObject();if(node.value("node_id").toString().isEmpty())node.insert("node_id",QUuid::createUuid().toString(QUuid::WithoutBraces));if(!node.contains("enabled"))node.insert("enabled",true);queue[i]=node;}

    runPlan(s,{{"queue",queue},{"scheduled",QJsonArray{}},{"flow",QJsonObject{{"loop",false},{"monitor_scheduled",false}}}});

}

void MainWindow::runPlan(Session *s,QJsonObject plan){

    if(!s->ready||s->detaching||s->running||s->flow.active()){append(s,"当前会话未就绪或已有流程运行，请先停止");return;}

    // Snapshot current role recovery/pet policy once at flow start. Node-specific
    // output skill priorities and the rest of the stored plan stay independent.
    for(const auto key:{"queue","scheduled"}){auto nodes=plan.value(key).toArray();
        for(int i=0;i<nodes.size();++i){auto n=nodes[i].toObject();auto p=n.value("params").toObject();
            if(p.value("combat").toBool()){auto battle=s->panel->profile().value("battle").toObject();battle.insert("enabled",battle.value("enabled").toBool(true));p.insert("battle_system",battle);
                if(p.value("combat_skills").toString().trimmed().isEmpty())p.insert("combat_skills",battle.value("skills").toString().replace('\n',','));
                n.insert("params",p);nodes[i]=n;}}
        plan.insert(key,nodes);}
    QString error;if(!FlowRunner::validate(plan,error)){append(s,error);return;}
      const auto taskCatalog=ClientStore::readJson(QCoreApplication::applicationDirPath()+"/tasks/catalog.json").value("tasks").toArray();

    for(const auto &key:{"queue","scheduled"})for(const auto &value:plan.value(key).toArray()){

        if(QString(key)=="scheduled"&&!plan.value("flow").toObject().value("monitor_scheduled").toBool(true))continue;

        const auto n=value.toObject();if(!n.value("enabled").toBool())continue;auto p=n.value("params").toObject();const auto id=n.value("task").toString();const auto mode=p.value("mode").toString(id=="luoyang_move"?"live_move":"live");
          if(id=="luoyang_move"){append(s,"洛阳坐标移动测试项已移除，请从保存的任务列表删除该项；流程未开始");return;}
          const auto task=plannedTask(taskCatalog,id);
          if(task.value("planning_only").toBool()){append(s,"任务尚未适配，两个列表均未开始："+task.value("name").toString()+"；"+plannedTaskReason(task));return;}

        if(QJsonDocument(p).toJson(QJsonDocument::Compact).size()>6000){append(s,"单节点参数过大，流程未开始");return;}

        if(id=="wait"){if(!validateWaitConfig(p,error)){append(s,error);return;}continue;}

        if(id=="daily_sign"){if(!s->liveAvailable||!validateDailySignConfig(p,error)){append(s,error.isEmpty()?"签到需要已登录且版本已适配的角色":error);return;}continue;}

        if(mode=="legacy"){if(!s->liveAvailable||p.value("legacy_id").toString()!=id||!validateLegacyConfig(p,error)){append(s,error.isEmpty()?"原脚本任务需要已登录且版本已适配的角色":error);return;}continue;}

        if(id!="plant"&&id!="luoyang_move"){append(s,"该任务尚未适配，两个列表均未开始："+id);return;}

        if(mode!="preview"&&(id!="luoyang_move"||mode!="live_move")){append(s,"真实任务接口尚未适配，流程未开始");return;}

        if(mode=="live_move"&&!s->liveAvailable){append(s,"真实位置不可用，流程未开始");return;}

        if(id=="luoyang_move")p.insert("operation","move");

        if(!validatePlantConfig(p,error)){append(s,error);return;}

    }

    s->flow.setJournalPath(store_.root+"/runs/"+QString::fromLatin1(QCryptographicHash::hash(s->key.toUtf8(),QCryptographicHash::Sha256).toHex())+".json");
    if(!s->flow.start(plan,error)){append(s,error);return;}s->queueActive=true;saveProfile(s);runNext(s);

}

void MainWindow::runNext(Session *s){

    if(s->detaching||s->running||!s->flow.active())return;

    const auto node=s->flow.poll(QDateTime::currentDateTime());s->queueActive=s->flow.active();s->status=s->flow.status();
    if(!s->flow.journalError().isEmpty()){append(s,s->flow.journalError());s->status=s->flow.journalError();}

    if(!node.isEmpty()){auto p=node.value("params").toObject();const auto id=node.value("task").toString();const auto savedMode=p.take("mode").toString(id=="luoyang_move"?"live_move":"live");const auto mode=id=="wait"?QString("wait"):id=="daily_sign"?QString("daily_sign"):savedMode;if(id=="luoyang_move")p.insert("operation","move");s->running=true;send(s,{{"op","start"},{"mode",mode},{"config",p}});}

    updatePanel(s);

}

bool MainWindow::saveProfile(Session *s){if(!s||!s->panel)return false;if(s->profileLocked){append(s,"角色配置文件损坏，已停止自动保存以保留原文件："+QDir::toNativeSeparators(store_.profilePath(s->key)));return false;}QString error;bool ok=store_.saveProfile(s->key,s->panel->profile(),error);if(!ok)append(s,error);return ok;}

void MainWindow::updatePanel(Session *s){if(s&&s->panel){s->panel->runtime(s->status,s->ready&&!s->detaching,s->running||s->flow.active(),s->live,s->bytes);if(s->panel->isVisible())s->panel->flowStates(s->flow.states());}}

void MainWindow::associate(Session *s){auto list=store_.launcher.value("accounts").toArray();if(list.isEmpty()){append(s,"先在启动器添加账号，再关联角色槽位");return;}QStringList choices;QVector<QJsonObject> identities;for(const auto &v:list){auto a=v.toObject();for(int slot=1;slot<=3;++slot){choices<<QString("%1 / %2 / 角色 %3").arg(a.value("alias").toString(),server_->currentText()).arg(slot);identities.append(QJsonObject{{"account",a.value("id")},{"district",district_->currentText()},{"server",server_->currentText()},{"slot",slot}});}}

    bool ok=false;auto selected=QInputDialog::getItem(s->panel,"关联配置","选择当前游戏实际使用的账号 / 角色槽位",choices,0,false,&ok);if(!ok||!sessions_.values().contains(s)||s->detaching)return;if(s->running||s->flow.active()||s->queueActive){append(s,"任务运行中不能修改配置归属：请先停止任务，避免配置与执行记录分属不同角色");return;}
    // Linking chooses whose configuration this panel is. The target's saved configuration wins; the current one
    // is kept under its old owner and only becomes the target's when the target has none yet.
    const auto identity=identities[choices.indexOf(selected)];const auto key=ClientStore::roleKey(identity);if(key==s->key){append(s,"已关联该角色");return;}
    QJsonObject target;QString note;const auto state=store_.loadProfile(key,target,note);
    if(state==ClientStore::ProfileState::Damaged){append(s,note+"；未关联");return;}
    if(!s->profileLocked&&!saveProfile(s))return;
    s->identity=identity;s->key=key;s->profileLocked=false;
    if(state==ClientStore::ProfileState::Missing){saveProfile(s);append(s,"该角色尚无配置，已以当前配置建立；昵称接口待读取，不推断角色名称");}
    else{s->panel->setProfile(target);updatePanel(s);append(s,"已关联并加载该角色已有配置"+(note.isEmpty()?QString():"；"+note));}

}

void MainWindow::copyProfile(Session *s){

    QVector<quint32> targetPids;QStringList choices;for(auto *other:sessions_)if(other!=s&&!other->detaching){targetPids<<other->info.pid;choices<<QString("PID %1 · %2").arg(other->info.pid).arg(other->status);}if(targetPids.isEmpty()){append(s,"当前没有其他已绑定角色可复制");return;}

    QDialog dialog(s->panel);dialog.setWindowTitle("复制配置");auto *layout=new QVBoxLayout(&dialog);auto *list=new QListWidget;for(const auto &name:choices){auto *item=new QListWidgetItem(name,list);item->setCheckState(Qt::Unchecked);}layout->addWidget(list);auto *note=new QLabel("复制任务参数、流程和后勤草稿；账号身份与运行状态不复制，技能不复制，销毁关闭。");note->setWordWrap(true);layout->addWidget(note);auto *buttons=new QDialogButtonBox(QDialogButtonBox::Ok|QDialogButtonBox::Cancel);layout->addWidget(buttons);connect(buttons,&QDialogButtonBox::accepted,&dialog,&QDialog::accept);connect(buttons,&QDialogButtonBox::rejected,&dialog,&QDialog::reject);if(dialog.exec()!=QDialog::Accepted)return;

    if(!sessions_.values().contains(s))return;

    auto source=s->panel->profile();for(int i=0;i<targetPids.size();++i)if(list->item(i)->checkState()==Qt::Checked){auto *t=sessions_.value(targetPids[i]);if(!t||t->detaching)continue;auto p=copyTaskConfiguration(source,t->panel->profile());t->panel->setProfile(p);updatePanel(t);saveProfile(t);}append(s,"目标配置草稿已复制，运行中的流程不变");

}

quint32 MainWindow::foregroundGame()const{HWND w=GetForegroundWindow();DWORD pid=0;GetWindowThreadProcessId(w,&pid);if(pid==GetCurrentProcessId()){HWND top=GetAncestor(w,GA_ROOT);for(auto *s:sessions_)if(!s->detaching&&reinterpret_cast<HWND>(s->panel->winId())==top)return s->info.pid;return 0;}return isGamePath(processPath(pid),gameRoot())?pid:0;}

void MainWindow::syncHotkeys(){if(testMode_)return;bool applicable=foregroundGame()!=0;if(applicable){DWORD pid=0;GetWindowThreadProcessId(GetForegroundWindow(),&pid);if(pid==GetCurrentProcessId()&&(qobject_cast<QLineEdit*>(qApp->focusWidget())||qobject_cast<QAbstractSpinBox*>(qApp->focusWidget())))applicable=false;}auto update=[&](int id,UINT key,bool &flag){if(applicable&&!flag){flag=RegisterHotKey(nullptr,id,MOD_NOREPEAT,key);if(!flag)hotkeyError_=GetLastError();}if(!applicable&&flag){UnregisterHotKey(nullptr,id);flag=false;}};update(0x5101,VK_HOME,homeRegistered_);update(0x5102,VK_END,endRegistered_);update(0x5103,VK_INSERT,insertRegistered_);}

bool MainWindow::dispatchHotkey(quintptr id){auto pid=foregroundGame();if(id==0x5101&&pid){bind(pid);return true;}if(id==0x5102&&pid){detach(pid,"End 解绑");return true;}if(id==0x5103&&pid){auto *s=sessions_.value(pid);if(s){if(s->panel->isVisible())s->panel->hide();else s->panel->showForGame();}return true;}if(id==0x5104){stopAll();return true;}return false;}

bool MainWindow::nativeEventFilter(const QByteArray &,void *message,qintptr *){auto *m=static_cast<MSG*>(message);if(m->message!=WM_HOTKEY)return false;lastHotkey_=m->wParam;return dispatchHotkey(m->wParam);}

void MainWindow::stopAll(){cancelLogin();for(auto *s:sessions_){s->flow.stop();s->queueActive=false;send(s,{{"op","stop"}});}}

void MainWindow::quitClient(){if(quitting_)return;quitting_=true;cancelLogin();saveLauncher();for(auto pid:sessions_.keys())detach(pid,"软件退出");QTimer::singleShot(1700,qApp,&QCoreApplication::quit);}

void MainWindow::closeEvent(QCloseEvent *e){if(!quitting_&&tray_&&tray_->isVisible()){saveLauncher();hide();e->ignore();return;}if(!quitting_){e->ignore();quitClient();return;}QMainWindow::closeEvent(e);}

bool MainWindow::saveScreenshot(const QString &path){show();qApp->processEvents();QImage image(size()*devicePixelRatioF(),QImage::Format_ARGB32);image.setDevicePixelRatio(devicePixelRatioF());render(&image);return image.save(path);}

bool MainWindow::bindForSmoke(quint32 pid){if(!testMode_)return false;bind(pid,"smoke",{},false);QElapsedTimer timer;timer.start();while(timer.elapsed()<3000){qApp->processEvents();auto *s=sessions_.value(pid);if(s&&s->ready)return true;QThread::msleep(5);}return false;}

QJsonObject MainWindow::diagnostics()const{QJsonArray sessions;for(auto *s:sessions_)sessions.append(QJsonObject{{"pid",int(s->info.pid)},{"created",s->info.created},{"ready",s->ready},{"running",s->running},{"source",s->source},{"worker_pid",double(s->worker->processId())},{"worker_private_commit_bytes",double(s->bytes)},{"live_position_available",s->liveAvailable},{"panel",s->panel->diagnostics()}});return {{"version","0.15.0"},{"protected_game_pid",int(protectedGamePid_)},{"protected_account_key",protectedAccountId_},{"protected_login_guard",!protectedLoginFingerprint_.isEmpty()},{"launcher_status",status_->text()},{"login_busy",loginWorker_!=nullptr},{"launch_ticket_active",launchTime_.isValid()},{"resource_job_configured",workerJob_!=nullptr},{"sessions",sessions},{"account_count",store_.launcher.value("accounts").toArray().size()},{"multi_open",multi_->isChecked()},{"hotkey_home_registered",homeRegistered_},{"last_hotkey",double(lastHotkey_)},{"hotkey_error",int(hotkeyError_)},{"foreground_game",int(foregroundGame())},{"foreground_window",QString::number(quintptr(GetForegroundWindow()))},{"configured_game_root",gameRoot()},{"native_gameplay_tested",false},{"automatic_authentication_available",true},{"automatic_authentication_live_verified",false},{"login_worker_pid",loginWorker_?double(loginWorker_->processId()):0},{"role_nickname_reader_available",true}};}

int MainWindow::runUiTests(const QString &fixtureRoot,const QString &report){

    QJsonArray passed;QString failure;bool physicalHotkeys=true;QVector<quint32> owned;QJsonObject observed;

    auto require=[](bool ok,const char *message){if(!ok)throw std::runtime_error(message);};

    auto wait=[&](std::function<bool()> predicate,int ms=5000){QElapsedTimer time;time.start();while(time.elapsed()<ms){qApp->processEvents();if(predicate())return true;QThread::msleep(10);}return predicate();};

    auto record=[&](const QString &name){passed.append(name);};

    auto press=[&](quint32 pid,UINT key,quintptr command){auto g=gameInfo(pid);require(g.window!=0,"Fixture window missing");ShowWindow(reinterpret_cast<HWND>(g.window),SW_RESTORE);SetForegroundWindow(reinterpret_cast<HWND>(g.window));wait([&]{return foregroundGame()==pid;},500);syncHotkeys();if(foregroundGame()==pid&&homeRegistered_){INPUT input[2]{};input[0].type=input[1].type=INPUT_KEYBOARD;input[0].ki.wVk=WORD(key);input[1].ki.wVk=WORD(key);input[1].ki.dwFlags=KEYEVENTF_KEYUP;require(SendInput(2,input,sizeof(INPUT))==2,"Fixture key input failed");}else{physicalHotkeys=false;if(command==0x5101)bind(pid,"home",{},false);if(command==0x5102)detach(pid,"测试 End");}qApp->processEvents();};

    try{

        require(testMode_&&QFileInfo::exists(fixtureRoot+"/.owned-binding-fixture"),"Only owned fixture roots may be tested");root_->setText(fixtureRoot);testMode_=false;activeWindow=this;qApp->installNativeEventFilter(this);foregroundHook_=SetWinEventHook(EVENT_SYSTEM_FOREGROUND,EVENT_SYSTEM_FOREGROUND,nullptr,onForeground,0,0,WINEVENT_OUTOFCONTEXT);

        QProcess first,second;first.start(fixtureRoot+"/Bin64/Game.exe");require(first.waitForStarted(),"First fixture failed");owned<<quint32(first.processId());require(wait([&]{return gameInfo(owned[0]).window!=0;}),"First fixture window timed out");

        require(sessions_.isEmpty(),"Unbound fixture unexpectedly attached");press(owned[0],VK_HOME,0x5101);require(wait([&]{auto *s=sessions_.value(owned[0]);return s&&s->ready;}),"Home binding failed");record("Home binds an already-running unbound foreground fixture");

        auto *a=sessions_.value(owned[0]);require(a->panel->diagnostics().value("tab_count").toInt()==9,"Wrong task tab count");require(GetWindow(reinterpret_cast<HWND>(a->panel->winId()),GW_OWNER)==nullptr,"Panel is owned by a window and would stay above / minimize with the game");record("Independent panel is a standalone window with nine functional tabs");

        a->panel->selectTask("plant");a->panel->showForGame();wait([]{return false;},100);a->panel->screenshot(QFileInfo(report).absolutePath()+"/session-native.png");

        auto *overlay=toasts_.value(a->info.window);require(overlay!=nullptr,"Missing binding toast");QImage toastImage(overlay->size(),QImage::Format_ARGB32);overlay->render(&toastImage);toastImage.save(QFileInfo(report).absolutePath()+"/binding-toast.png");record("Binding progress/result shown in non-activating game-owned upper overlay");

        press(owned[0],VK_HOME,0x5101);require(wait([&]{return sessions_.size()==1;}),"Duplicate Home created session");record("Repeated Home reuses the same session");

        second.start(fixtureRoot+"/Bin64/Game.exe");require(second.waitForStarted(),"Second fixture failed");owned<<quint32(second.processId());require(wait([&]{return gameInfo(owned[1]).window!=0;}),"Second fixture window timed out");press(owned[1],VK_HOME,0x5101);require(wait([&]{auto *s=sessions_.value(owned[1]);return s&&s->ready;}),"Second binding failed");auto *b=sessions_.value(owned[1]);require(a->panel!=b->panel,"Shared task window");auto p=a->panel->profile();p.insert("probe_value",123);a->panel->setProfile(p);require(!b->panel->profile().contains("probe_value"),"Profiles leaked");record("Two games have separate task windows and independent profiles");

        const auto controls=a->panel->findChildren<QPushButton*>().size();for(int i=0;i<4;++i)a->panel->setProfile(a->panel->profile());require(a->panel->findChildren<QPushButton*>().size()==controls,"Replacing profile leaked controls");record("Repeated profile replacement disposes nested layouts without accumulating controls");

        a->panel->selectTask("grind");QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);auto *routeChoice=a->panel->findChild<QComboBox*>("grind_reference_route");require(routeChoice&&routeChoice->count()==111,"Reference route choices missing");routeChoice->setCurrentIndex(1);

        const auto routeParams=a->panel->profile().value("tasks").toObject().value("grind").toObject();

        require(!routeParams.value("reference_route").toObject().value("id").toString().isEmpty()&&routeParams.value("reference_route").toObject().value("runtime_enabled")==QJsonValue(false),"Route binding became executable or was not saved");

        require(!b->panel->profile().value("tasks").toObject().value("grind").toObject().contains("reference_route"),"Route selection leaked across games");

        a->panel->selectTab("参数");a->panel->showForGame();QCoreApplication::processEvents();require(routeChoice->isVisible(),"Route editor not visible");a->panel->screenshot(QFileInfo(report).absolutePath()+"/reference-route-panel.png");

        auto *preview=a->panel->findChild<QPushButton*>("grind_route_preview");require(preview&&preview->isEnabled(),"Route preview unavailable");preview->click();

        auto *points=a->panel->findChild<QTableWidget*>("reference_route_points");require(points&&points->rowCount()==25&&points->item(0,1)->text()=="61"&&points->item(0,2)->text()=="257","Route preview changed source coordinates");

        auto *routeDialog=qobject_cast<QDialog*>(points->parentWidget());require(routeDialog,"Missing route dialog");routeDialog->grab().save(QFileInfo(report).absolutePath()+"/reference-route-points.png");routeDialog->close();QCoreApplication::sendPostedEvents(nullptr,QEvent::DeferredDelete);

        a->panel->setProfile(a->panel->profile());routeChoice=a->panel->findChild<QComboBox*>("grind_reference_route");require(routeChoice&&routeChoice->currentIndex()==1,"Saved route selection was lost on panel rebuild");

        routeChoice->setCurrentIndex(39);a->panel->setProfile(a->panel->profile());routeChoice=a->panel->findChild<QComboBox*>("grind_reference_route");

        require(routeChoice&&routeChoice->currentIndex()==39&&routeChoice->currentText().startsWith("天龙助手"),"Assistant source selection was not preserved");

        record("38 reference routes and 72 assistant references persist independently without enabling actions; original points are previewed");

        auto profile=a->panel->profile();auto taskParams=profile.value("tasks").toObject();taskParams.insert("plant",QJsonObject{{"mode","preview"},{"x",360},{"y",317},{"rounds",1},{"tolerance",0.3},{"timeout_seconds",20}});profile.insert("tasks",taskParams);profile.insert("flow",QJsonObject{{"loop",false},{"daily_scheduled",false},{"monitor_scheduled",true},{"delete_completed",true}});a->panel->setProfile(profile);a->panel->selectTab("所有功能");

        const int expectedCatalog=ClientStore::readJson(QCoreApplication::applicationDirPath()+"/tasks/catalog.json").value("tasks").toArray().size();
        auto *library=a->panel->findChild<QTableWidget*>("taskLibrary");auto *search=a->panel->findChild<QLineEdit*>("taskSearch");require(library&&search&&library->rowCount()==expectedCatalog,"Task library incomplete");search->setText("签到");require(library->rowCount()==1&&library->item(0,2)->text()=="已接入·待实测","Daily sign integration status missing");

        // Tasks lose this alias as they move to dedicated flows, so the count comes from the catalog.
        int aliased=0;for(const auto &v:ClientStore::readJson(QCoreApplication::applicationDirPath()+"/tasks/catalog.json").value("tasks").toArray())if(v.toObject().value("aliases").toArray().contains(QJsonValue("天龙助手")))++aliased;
        search->setText("天龙助手");require(aliased>0&&library->rowCount()>=aliased,"Reference script tasks missing");for(int row=0;row<library->rowCount();++row)require(library->item(row,2)->text()=="已接入·待实测","Reference script status missing");search->setText("洛阳坐标移动");require(library->rowCount()==0,"Removed movement task is still listed");
        search->setText("种植");int plantRow=-1;for(int row=0;row<library->rowCount();++row)if(library->item(row,0)->data(Qt::UserRole).toString()=="plant")plantRow=row;require(plantRow>=0,"Plant preview task missing");QMetaObject::invokeMethod(library,"cellDoubleClicked",Qt::DirectConnection,Q_ARG(int,plantRow),Q_ARG(int,0));

        QCheckBox *destination=nullptr;for(auto *c:a->panel->findChildren<QCheckBox*>())if(c->text()=="双击添加到定时列表")destination=c;require(destination,"Schedule destination toggle missing");destination->setChecked(true);

        const QTime current=QTime::currentTime();a->panel->findChild<QTimeEdit*>("scheduleStart")->setTime(current.addSecs(-60));a->panel->findChild<QTimeEdit*>("scheduleEnd")->setTime(current.addSecs(1800));QMetaObject::invokeMethod(library,"cellDoubleClicked",Qt::DirectConnection,Q_ARG(int,plantRow),Q_ARG(int,0));

        require(a->panel->profile().value("queue").toArray().size()==1&&a->panel->profile().value("scheduled").toArray().size()==1,"Double-click queue destination incorrect");

        auto snap=a->panel->profile();auto drafts=snap.value("tasks").toObject();auto draft=drafts.value("plant").toObject();draft.insert("x",361);drafts.insert("plant",draft);snap.insert("tasks",drafts);a->panel->setProfile(snap);require(a->panel->profile().value("queue").toArray()[0].toObject().value("params").toObject().value("x").toInt()==360,"Queue parameters followed draft edits");
        const auto fixturePlantParams=a->panel->profile().value("queue").toArray()[0].toObject().value("params").toObject();

        search=a->panel->findChild<QLineEdit*>("taskSearch");search->clear();a->panel->selectTab("所有功能");a->panel->showForGame();qApp->processEvents();a->panel->screenshot(QFileInfo(report).absolutePath()+"/all-functions.png");record("Task search and double-click destinations create independent regular and timed parameter snapshots");

        updatePanel(a);a->panel->findChild<QPushButton*>("startFlow")->click();require(a->flow.active()||a->running,"Preview plan did not start");require(wait([&]{return !a->flow.active()&&!a->running;},8000),"Preview flow did not finish");require(a->flow.states().size()==2,"Both executor paths did not run");require(a->panel->profile().value("scheduled").toArray().isEmpty(),"Successful timed task not removed from unchanged draft");record("One executor runs timed and regular preview nodes and deletes only confirmed unchanged timed drafts");

        QJsonObject invalid{{"node_id","unadapted"},{"task","pvp"},{"enabled",true},{"params",QJsonObject{}}};runPlan(a,{{"queue",QJsonArray{invalid}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}});require(!a->flow.active()&&!a->running&&a->status.contains("尚未适配"),"Unsupported task passed capability gate");record("Unadapted task is rejected before either queue starts");

        {const auto saved=a->panel->profile();auto old=saved;const QJsonObject retired{{"node_id","retired"},{"task","luoyang_move"},{"enabled",true},{"params",QJsonObject{{"mode","preview"}}}};
            old.insert("queue",QJsonArray{retired});a->panel->setProfile(old);auto *table=a->panel->findChild<QTableWidget*>("regularQueue");
            require(table&&table->rowCount()==1&&table->item(0,1)->text().contains("已移除"),"Saved retired task was not identified");
            runPlan(a,{{"queue",QJsonArray{retired}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}});
            require(!a->flow.active()&&!a->running&&a->panel->profile().value("queue").toArray()==QJsonArray{retired},"Retired task ran or saved queue was silently deleted");
            a->panel->setProfile(saved);record("Retired movement task stays visible in old queues and cannot start");}

        auto future=QJsonObject{{"node_id","future"},{"task","plant"},{"enabled",true},{"params",fixturePlantParams},{"start_minute",(current.hour()*60+current.minute()+30)%1440},{"end_minute",(current.hour()*60+current.minute()+60)%1440}};runPlan(a,{{"queue",QJsonArray{}},{"scheduled",QJsonArray{future}},{"flow",QJsonObject{}}});require(a->flow.active()&&!a->running,"Future schedule did not enter waiting state");a->panel->pauseRequested();require(a->flow.paused(),"Waiting scheduler did not pause");a->panel->stopRequested();require(!a->flow.active()&&first.state()==QProcess::Running,"Stopping monitor closed game or retained scheduler");record("Waiting scheduler pauses and stops without a running action or game exit");

        {
            const bool previousLive=a->liveAvailable;a->liveAvailable=true;
            QJsonObject good{{"node_id","before_bad"},{"task","plant"},{"enabled",true},{"params",fixturePlantParams}};
            QJsonObject bad{{"node_id","bad_entry"},{"task","not_registered"},{"enabled",true},{"params",QJsonObject{{"mode","legacy"},{"legacy_id","not_registered"},{"engine","游戏内 Lua"},{"timeout_seconds",300}}}};
            runPlan(a,{{"queue",QJsonArray{good,bad}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}});a->liveAvailable=previousLive;
            require(!a->flow.active()&&!a->running,"A missing later entry started the earlier queue task");
            record("Full queue preflight rejects an unregistered later script before any task starts");
            const auto savedProfile=a->panel->profile();auto draft=savedProfile;
            QJsonObject unknown{{"node_id","unverified_timed"},{"task","tlzz_haoqi"},{"enabled",true},{"start_minute",0},{"end_minute",1439},{"params",QJsonObject{{"failure","停止队列"}}}};
            draft.insert("scheduled",QJsonArray{unknown});a->panel->setProfile(draft);QString flowError;
            require(a->flow.start({{"queue",QJsonArray{}},{"scheduled",QJsonArray{unknown}},{"flow",QJsonObject{{"delete_completed",true},{"daily_scheduled",false}}}},flowError),qPrintable(flowError));
            require(!a->flow.poll(QDateTime(QDate(2026,10,27),QTime(12,0))).isEmpty(),"Unknown completion fixture did not claim its node");a->running=true;
            handle(a,{{"event","completed"},{"verified",false},{"preview",false},{"operation","legacy"}});
            require(!a->flow.active()&&!a->running&&a->flow.states().value("unverified_timed").toString()=="未核验"
                &&a->panel->profile().value("scheduled").toArray()==QJsonArray{unknown},"Unverified task was labeled complete, deleted or advanced");
            a->flow.stop();a->panel->setProfile(savedProfile);
            record("Bare Lua return is unverified, preserves timed configuration and obeys stop policy");
            a->panel->selectTask("tlzz_keju");qApp->processEvents();auto *examEngine=a->panel->findChild<QComboBox*>("tlzz_keju_engine");
            require(examEngine&&examEngine->count()==1&&examEngine->currentText()=="外部兼容","Exam offered an engine without its question bank");
            record("Exam UI selects the external engine which loads its complete question bank");
        }
        for(const auto &tab:QStringList{"保护","技能","组队组团","物品","其他","信息","保存"}){a->panel->selectTab(tab);qApp->processEvents();a->panel->screenshot(QFileInfo(report).absolutePath()+"/page-"+tab+".png");}

        auto *listing=a->panel->findChild<QTableWidget*>("listingRules");require(listing,"Listing table missing");QPushButton *addItem=nullptr;for(auto *button:a->panel->findChildren<QPushButton*>())if(button->text()=="添加物品规则")addItem=button;require(addItem,"Add listing rule missing");addItem->click();require(listing->rowCount()==1,"Listing row not added");listing->item(0,1)->setText("fixture-item");listing->item(0,3)->setText("123");require(a->panel->profile().value("trade").toObject().value("listings").toArray()[0].toObject().value("price").toInt()==123,"Listing edit not saved");auto *destroy=a->panel->findChild<QCheckBox*>("bag_destroy_enabled");require(destroy&&!destroy->isEnabled()&&!destroy->isChecked(),"Destroy control became active");a->panel->selectTab("物品");a->panel->findChild<QTabWidget*>("itemTabs")->setCurrentIndex(4);qApp->processEvents();a->panel->screenshot(QFileInfo(report).absolutePath()+"/auto-listing.png");record("Listing rules persist as drafts and destruction remains disabled");

        auto *leader=a->panel->findChild<QLineEdit*>("team_leader");require(leader,"Team leader field missing");leader->setText("fixture-leader");require(a->panel->profile().value("team").toObject().value("leader")==QJsonValue("fixture-leader")&&!b->panel->profile().value("team").toObject().contains("leader"),"Team rules leaked between games");a->panel->selectTask("pvp");qApp->processEvents();a->panel->screenshot(QFileInfo(report).absolutePath()+"/pvp-settings.png");record("Team and combat rule pages preserve independent per-game drafts");
        const auto beforeDaily=a->panel->profile();auto oldDaily=beforeDaily;auto dailyDrafts=oldDaily.value("tasks").toObject();
        dailyDrafts.insert("tlzz_gulanyu",QJsonObject{{"engine","外部兼容"},{"gulanyu_list","红宝石|2"}});oldDaily.insert("tasks",dailyDrafts);
        auto oldQueue=oldDaily.value("queue").toArray();oldQueue.append(QJsonObject{{"node_id","daily-mode-fixture"},{"task","tlzz_gulanyu"},{"enabled",true},{"params",dailyDrafts.value("tlzz_gulanyu")}});oldDaily.insert("queue",oldQueue);
        a->panel->setProfile(oldDaily);a->panel->selectTask("tlzz_gulanyu");qApp->processEvents();
        auto *quantity=a->panel->findChild<QComboBox*>("tlzz_gulanyu_gulanyu_count_mode");auto *dailyEngine=a->panel->findChild<QComboBox*>("tlzz_gulanyu_engine");
        require(quantity&&quantity->count()==2&&quantity->currentText()=="本次新增数量","Gem quantity semantics missing");
        require(dailyEngine&&dailyEngine->count()==1&&dailyEngine->currentText()=="游戏内 Lua","Direct original daily mode missing");
        quantity->setCurrentText("持有目标总数");const auto migrated=a->panel->profile();
        require(migrated.value("tasks").toObject().value("tlzz_gulanyu").toObject().value("gulanyu_count_mode").toString()=="持有目标总数","Gem quantity setting not saved");
        const auto migratedNode=migrated.value("queue").toArray().last().toObject().value("params").toObject();
        require(migratedNode.value("engine").toString()=="游戏内 Lua"&&migratedNode.value("gulanyu_list").toString()=="红宝石|2","Original daily mode migration changed quantity or missed queued config");
        a->panel->screenshot(QFileInfo(report).absolutePath()+"/gem-quantity-settings.png");record("Original daily tasks expose explicit gem quantity mode and retain saved values during engine migration");
        a->panel->setProfile(beforeDaily);
        a->panel->selectTask("zhenlong_combat");qApp->processEvents();
        auto *combatSkills=a->panel->findChild<QLineEdit*>("zhenlong_combat_combat_skills");require(combatSkills,"Combat parameter editor missing");combatSkills->setText("fixture-skill");
        const auto combatDraft=a->panel->profile().value("tasks").toObject().value("zhenlong_combat").toObject();
        require(combatDraft.value("combat").toBool()&&combatDraft.value("combat_skills").toString()=="fixture-skill","Combat config not wired");
        auto *ruleSource=a->panel->findChild<QComboBox*>("zhenlong_combat_rule_source");auto *originalQuick=a->panel->findChild<QCheckBox*>("zhenlong_combat_original_quick_mode");auto *entryMode=a->panel->findChild<QComboBox*>("zhenlong_combat_entry_mode");
        require(ruleSource&&originalQuick&&entryMode&&ruleSource->currentText()=="原规则"&&combatDraft.value("combat_scene").toInt()==61,"Original rule selector or corrected scene missing");
        originalQuick->setChecked(true);require(a->panel->profile().value("tasks").toObject().value("zhenlong_combat").toObject().value("original_quick_mode").toBool(),"Original config flag not saved");
        entryMode->setCurrentText("已在副本");require(!originalQuick->isEnabled(),"Entry-only original flag enabled inside dungeon");entryMode->setCurrentText("自动入场");ruleSource->setCurrentText("兼容重建");require(!originalQuick->isEnabled(),"Original flag affects reconstructed rule");ruleSource->setCurrentText("原规则");require(originalQuick->isEnabled(),"Original flag did not resume");
        a->panel->screenshot(QFileInfo(report).absolutePath()+"/combat-settings.png");record("Dungeon combat parameters are editable and isolated per game");

        auto *registryTable=a->panel->findChild<QTableWidget*>("dungeonRegistry");require(registryTable&&registryTable->rowCount()==32,"Complete provided dungeon inventory missing");
        int executableDungeons=0;for(int row=0;row<registryTable->rowCount();++row)executableDungeons+=registryTable->item(row,2)->text()=="已接入 · 待实测"?1:0;
        require(executableDungeons==1,"Unadapted dungeon inventory mislabeled as runnable");record("All 32 source dungeon modules are listed with separate adapter status");
        auto *originalTable=a->panel->findChild<QTableWidget*>("originalRuleRegistry");auto *originalSearch=a->panel->findChild<QLineEdit*>("originalRuleSearch");
        require(originalTable&&originalTable->rowCount()==354&&originalSearch,"Complete original Lua library is absent");
        originalSearch->setText("抓珍兽上架商会");int originalVisible=0;
        for(int row=0;row<originalTable->rowCount();++row)if(!originalTable->isRowHidden(row)){++originalVisible;require(originalTable->item(row,2)->text().contains("空壳"),"Source stub mislabeled executable");}
        require(originalVisible==1,"Original source search does not isolate the selected rule");originalSearch->clear();
        a->panel->selectTab("信息");a->panel->findChild<QTabWidget*>("sessionInfoTabs")->setCurrentWidget(originalTable->parentWidget());qApp->processEvents();a->panel->screenshot(QFileInfo(report).absolutePath()+"/original-library.png");
        a->panel->selectTask("jinwen");qApp->processEvents();require(a->panel->findChild<QPushButton*>("taskRun_jinwen")->isEnabled(),"Original item task has no runnable UI entry");
        auto promotedProfile=a->panel->profile();auto promotedTasks=promotedProfile.value("tasks").toObject();promotedTasks.insert("jinwen",QJsonObject{{"mode","planned"},{"plan_rounds",1}});promotedProfile.insert("tasks",promotedTasks);
        a->panel->setProfile(promotedProfile);a->panel->selectTask("jinwen");qApp->processEvents();QJsonArray capturedOriginalRun;
        const auto previousRun=a->panel->runRequested;a->panel->runRequested=[&](QJsonArray nodes){capturedOriginalRun=nodes;};
        a->panel->findChild<QPushButton*>("taskRun_jinwen")->click();a->panel->runRequested=previousRun;
        require(capturedOriginalRun.size()==1,"Promoted task did not dispatch one parameter snapshot");
        const auto promotedParams=capturedOriginalRun.first().toObject().value("params").toObject();
        require(promotedParams.value("mode").toString()=="legacy"&&promotedParams.value("legacy_id").toString()=="jinwen"&&!promotedParams.value("allow_spend").toBool(),"Promoted draft did not select its real original entry with consumption disabled");
        record("318 original chunks and 36 source files expose readiness and stub status; adapted task has a runnable entry");
        auto *featureTable=a->panel->findChild<QTableWidget*>("featurePlanRegistry");require(featureTable&&featureTable->rowCount()==88,"Requested feature roadmap missing");
        a->panel->selectTab("信息");a->panel->findChild<QTabWidget*>("sessionInfoTabs")->setCurrentWidget(featureTable);qApp->processEvents();a->panel->screenshot(QFileInfo(report).absolutePath()+"/feature-plan.png");
        auto *priorityFilter=a->panel->findChild<QComboBox*>("taskCategory");
        search=a->panel->findChild<QLineEdit*>("taskSearch");library=a->panel->findChild<QTableWidget*>("taskLibrary");
        require(priorityFilter&&search&&library,"Feature priority filter missing");search->clear();priorityFilter->setCurrentText("优先接入");qApp->processEvents();
        require(library->rowCount()>=11,"Explicit priority tasks absent from the library");bool hasShimen=false;
        for(int row=0;row<library->rowCount();++row)if(library->item(row,0)->data(Qt::UserRole).toString()=="pet_shop"){hasShimen=true;require(library->item(row,2)->text()=="优先待接入","Priority draft mislabeled ready");}
        require(hasShimen,"Planned task lost its priority");priorityFilter->setCurrentText("全部");record("User feature roadmap and priority filter retain accurate readiness");
        auto *parameters=a->panel->findChild<QListWidget*>("parameterTasks");require(parameters,"Parameter selector missing");
        for(int row=0;row<parameters->count();++row)if(parameters->item(row)->data(Qt::UserRole).toString()=="pet_shop")parameters->setCurrentRow(row);
        a->panel->selectTab("参数");qApp->processEvents();auto *plannedRounds=a->panel->findChild<QDoubleSpinBox*>("pet_shop_plan_rounds");require(plannedRounds,"Planned parameter draft missing");plannedRounds->setValue(2);
        require(a->panel->profile().value("tasks").toObject().value("pet_shop").toObject().value("plan_rounds").toInt()==2&&!b->panel->profile().value("tasks").toObject().contains("pet_shop"),"Draft settings leaked between roles");
        auto *draftRun=a->panel->findChild<QPushButton*>("taskRun_pet_shop");require(draftRun&&!draftRun->isEnabled(),"Planned task's immediate run button enabled");record("Planned parameters persist per role while immediate execution remains disabled");
        a->panel->screenshot(QFileInfo(report).absolutePath()+"/priority-parameters.png");
        QJsonObject plannedNode{{"node_id","planned-pet-shop"},{"task","pet_shop"},{"enabled",true},{"params",QJsonObject{{"mode","planned"}}},{"start_minute",0},{"end_minute",1439}};
        runPlan(a,{{"queue",QJsonArray{}},{"scheduled",QJsonArray{plannedNode}},{"flow",QJsonObject{}}});
        require(!a->flow.active()&&!a->running&&a->status.contains("尚未适配"),"Planned timed task started before capability completion");record("Planned tasks are rejected before either execution list starts");
        auto *battleLearned=a->panel->findChild<QTableWidget*>("battle_learned_skills");auto *readSkills=a->panel->findChild<QPushButton*>("battle_read");
        auto *heal=a->panel->findChild<QCheckBox*>("battle_heal_enabled");auto *petMaintenance=a->panel->findChild<QCheckBox*>("battle_pet");
        require(battleLearned&&readSkills&&heal&&petMaintenance,"Battle maintenance controls missing");
        heal->setChecked(true);petMaintenance->setChecked(true);
        require(a->panel->profile().value("battle").toObject().value("heal_enabled").toBool()&&!b->panel->profile().value("battle").toObject().value("heal_enabled").toBool(),"Battle policy leaked between roles");
        QJsonObject skill{{"pet",-1},{"id",301},{"name","fixture-learned"},{"enabled",true},{"cooldown",0}};
        QJsonObject petSkill{{"pet",0},{"id",302},{"name","fixture-pet-skill"},{"enabled",false},{"cooldown",1}};
        QJsonObject petState{{"name","fixture-pet"},{"hp",50},{"maxhp",100},{"happy",80},{"skills",QJsonArray{petSkill}}};
        QJsonObject battleState{{"school_id",4},{"school_name","峨嵋"},{"hp",60},{"maxhp",100},{"mp",30},{"maxmp",100},{"skills",QJsonArray{skill}},{"pet",petState}};
        a->panel->runtime("owned battle fixture",true,false,QJsonObject{{"battle",battleState}},0);
        require(battleLearned->rowCount()==2&&battleLearned->item(0,1)->text()=="fixture-learned"&&readSkills->isEnabled(),"Learned skills snapshot not displayed");
        require(a->panel->findChild<QLabel*>("battle_vitals")->text().contains("60.0%")&&a->panel->findChild<QLabel*>("battle_pet_state")->text().contains("50.0%"),"HP ratios not shown from current maxima");
        battleLearned->selectRow(0);a->panel->findChild<QComboBox*>("battle_skill_usage")->setCurrentIndex(1);a->panel->findChild<QPushButton*>("battle_skill_add")->click();
        require(a->panel->profile().value("battle").toObject().value("heal_skills").toString()=="fixture-learned","Selected skill not saved to role healing config");
        a->panel->runtime("owned running fixture",true,true,QJsonObject{{"battle",battleState}},0);require(!readSkills->isEnabled(),"Skill probe could interrupt running task");
        a->panel->runtime("owned battle fixture",true,false,QJsonObject{{"battle",battleState}},0);a->panel->selectTab("技能");qApp->processEvents();
        a->panel->screenshot(QFileInfo(report).absolutePath()+"/battle-maintenance.png");record("Battle vitals, battleLearned actions and role-specific recovery controls are wired");


        multi_->setChecked(true);launchGame();require(wait([&]{for(auto *s:sessions_)if(s->source=="launcher"&&s->ready)return true;return false;},10000),"Launcher-owned child auto binding failed");quint32 third=0;for(auto *s:sessions_)if(s->source=="launcher")third=s->info.pid;require(third!=0&&launchButtonSent_,"Missing Launch.bin start-button handoff");owned<<third;record("Start Game follows Launch.exe to Launch.bin, presses its start button once and binds the new game");

        auto *ownedLogin=new QProcess(this);ownedLogin->start(QCoreApplication::applicationFilePath(),{"--fixture-game","--lifetime","60000"});require(ownedLogin->waitForStarted(),"Login lifecycle fixture failed");loginWorker_=ownedLogin;loginPid_=owned[0];setLoginBusy(true);cancelLogin();require(ownedLogin->state()==QProcess::NotRunning&&loginWorker_==nullptr&&loginPid_==0,"Cancel left a login worker running");require(first.state()==QProcess::Running&&sessions_.contains(owned[0]),"Cancel closed the game or detached its task session");record("Cancelling login releases its owned child and preserves game and task session");

        press(owned[0],VK_END,0x5102);require(wait([&]{return !sessions_.contains(owned[0]);}),"End did not detach first session");require(sessions_.contains(owned[1])&&sessions_.contains(third),"End detached other games");require(first.state()==QProcess::Running,"End closed game");record("End stops one Worker and panel without closing game or other sessions");

        second.terminate();second.waitForFinished(2000);require(wait([&]{return !sessions_.contains(owned[1]);}),"Game exit did not clean up session");record("Target exit automatically cleans up its Worker and panel");

        auto learned=ClientStore::rememberRole(QJsonObject{},"area","server",2,"fixture-nickname");require(learned.value("destinations").toObject().value("area/server").toObject().value("roles").toObject().value("2").toString()=="fixture-nickname","Role cache failed");require(!learned.value("destinations").toObject().contains("area/other"),"Role cache leaked servers");record("Verified nickname cache replaces a slot only within its account/server destination (fixture data)");

        QString error;require(store_.savePassword("fixture-only","not-a-real-password",error),"Credential encryption failed");require(store_.save(error),"Launcher save failed");ClientStore reopened(store_.root);require(reopened.load(error)&&reopened.launcher.value("multi_open").toBool(),"Launcher settings not persisted");record("Launcher settings persist and credential fixture is encrypted locally");

        for(int i=0;i<4;++i){bind(owned[0],"home",{},false);require(wait([&]{auto *s=sessions_.value(owned[0]);return s&&s->ready;}),"Rebind failed");detach(owned[0],"循环测试");require(wait([&]{return !sessions_.contains(owned[0]);}),"Repeated detach leaked a session");}record("Repeated bind/unbind cycles release sessions and Workers");

        selectedAccount_="owned-protected-fixture";store_.launcher.insert("accounts",QJsonArray{QJsonObject{{"id",selectedAccount_},{"alias","fixture"},{"login","OwnedOriginal@sohu.com"}}});protectedLoginFingerprint_=ClientStore::loginFingerprint("ownedoriginal");multi_->setChecked(true);launchGame();require(!launchTime_.isValid()&&status_->text().contains("保留"),"Protected account launch was not blocked");selectedAccount_.clear();protectedLoginFingerprint_.clear();store_.launcher.insert("accounts",QJsonArray{});record("Protected account cannot launch another login or create another game");

        observed=diagnostics();

        for(auto pid:owned){auto g=gameInfo(pid);if(g.window)PostMessageW(reinterpret_cast<HWND>(g.window),WM_CLOSE,0,0);}wait([&]{return sessions_.isEmpty();});first.waitForFinished(1000);require(sessions_.isEmpty(),"Fixture sessions left behind");record("All fixture exits leave no script sessions");

    }catch(const std::exception &e){failure=QString::fromUtf8(e.what());observed=diagnostics();}

    for(auto pid:owned){auto g=gameInfo(pid);if(g.window)PostMessageW(reinterpret_cast<HWND>(g.window),WM_CLOSE,0,0);}for(auto pid:sessions_.keys())detach(pid,"测试结束");wait([&]{return sessions_.isEmpty();},3000);

    QJsonObject result{{"passed",failure.isEmpty()},{"checks",passed},{"failure",failure},{"native_hotkey_input_verified_on_owned_fixtures",physicalHotkeys},{"real_game_tested",false},{"real_login_tested",false},{"gameplay_actions_sent",0},{"observed",observed},{"remaining_sessions",sessions_.size()}};QString writeError;ClientStore::writeJson(report,result,writeError);return failure.isEmpty()?0:1;

}

} // namespace tlbb

