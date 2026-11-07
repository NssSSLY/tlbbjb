#include "window.hpp"
#include <QApplication>
#include <QCloseEvent>
#include <QComboBox>
#include <QDateTime>
#include <QDir>
#include <QDoubleSpinBox>
#include <QFile>
#include <QFileInfo>
#include <QFormLayout>
#include <QGroupBox>
#include <QHBoxLayout>
#include <QHeaderView>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QLabel>
#include <QLineEdit>
#include <QMenu>
#include <QPlainTextEdit>
#include <QProcess>
#include <QPushButton>
#include <QSaveFile>
#include <QSet>
#include <QSpinBox>
#include <QSplitter>
#include <QStatusBar>
#include <QStyle>
#include <QSystemTrayIcon>
#include <QThread>
#include <QTimer>
#include <QTreeWidget>
#include <QUuid>
#include <QVBoxLayout>
#include <QWinEventNotifier>

namespace tlbb {
static MainWindow *activeWindow = nullptr;
struct MainWindow::Session {
    GameInfo info;
    QString id, status = "正在绑定", version, mode = "live_move";
    ProcessBinding binding;
    QProcess *worker = nullptr;
    QWinEventNotifier *exitWatch = nullptr;
    QByteArray output;
    QStringList log;
    QJsonObject config;
    QJsonObject liveState;
    bool liveAvailable = false;
    QElapsedTimer heartbeat;
    bool ready = false, running = false, paused = false, detaching = false;
    qint64 bytes = 0;
};
static void CALLBACK onForeground(HWINEVENTHOOK, DWORD, HWND, LONG, LONG, DWORD, DWORD) {
    if (activeWindow)
        QMetaObject::invokeMethod(
            activeWindow,
            [] {
                if (activeWindow)
                    activeWindow->syncHotkeys();
            },
            Qt::QueuedConnection);
}
MainWindow::MainWindow(const QString &gameRoot, const QString &script, bool testMode)
    : script_(script), testMode_(testMode) {
    setWindowTitle("TLBB Lua 任务客户端 · 真实移动测试版 0.2");
    resize(1120, 780);
    setMinimumSize(960, 680);
    setFont(QFont("Microsoft YaHei UI", 10));
    setStyleSheet(
        "QMainWindow,QWidget{background:#f4f6f9;color:#172033;} QGroupBox{background:white;border:1px solid "
        "#dce2eb;border-radius:8px;margin-top:12px;padding:14px;} "
        "QGroupBox::title{subcontrol-origin:margin;left:14px;padding:0 5px;} "
        "QLineEdit,QSpinBox,QDoubleSpinBox,QComboBox{background:white;border:1px solid "
        "#cbd5e1;border-radius:5px;padding:6px;min-height:20px;} QPushButton{background:white;border:1px "
        "solid #cbd5e1;border-radius:5px;padding:7px 13px;} QPushButton:hover{background:#e8eff8;} "
        "QPushButton:disabled{color:#9ca3af;background:#eef0f4;} "
        "QTreeWidget,QPlainTextEdit{background:white;border:1px solid #dce2eb;border-radius:5px;} "
        "QHeaderView::section{background:#edf2f7;padding:7px;border:0;} QStatusBar{background:#e8edf4;}");
    auto *central = new QWidget;
    setCentralWidget(central);
    auto *outer = new QVBoxLayout(central);
    outer->setContentsMargins(20, 16, 20, 12);
    outer->setSpacing(10);
    setStyleSheet(styleSheet() + " QLabel{background:transparent;}");
    auto *title = new QLabel("TLBB · 多会话 Lua 任务");
    title->setStyleSheet("font-size:23px;font-weight:600;");
    outer->addWidget(title);
    auto *subtitle = new QLabel("Home 绑定  /  End 解绑  /  Insert 显示或隐藏面板   ·   每个游戏独立运行");
    subtitle->setStyleSheet("color:#526176;");
    outer->addWidget(subtitle);
    banner_ =
        new QLabel("已接入当前游戏版本的真实位置与洛阳近距离移动。种植、技能、NPC 和自动登录仍待适配。");
    banner_->setWordWrap(true);
    banner_->setStyleSheet("background:#fff3d6;color:#795400;padding:10px;border-radius:6px;");
    outer->addWidget(banner_);
    auto *location = new QHBoxLayout;
    location->addWidget(new QLabel("游戏目录"));
    root_ = new QLineEdit(QDir::toNativeSeparators(gameRoot));
    location->addWidget(root_, 1);
    auto *refresh = new QPushButton("刷新进程");
    auto *launch = new QPushButton("启动游戏");
    location->addWidget(refresh);
    location->addWidget(launch);
    outer->addLayout(location);
    connect(refresh, &QPushButton::clicked, this, [this] {
        refreshGames();
        syncHotkeys();
    });
    connect(launch, &QPushButton::clicked, this, [this] { launchGame(); });
    auto *splitter = new QSplitter(Qt::Horizontal);
    outer->addWidget(splitter, 1);
    auto *left = new QWidget;
    auto *leftLayout = new QVBoxLayout(left);
    leftLayout->setContentsMargins(0, 0, 8, 0);
    auto *listTitle = new QLabel("游戏会话");
    listTitle->setStyleSheet("font-weight:600;");
    leftLayout->addWidget(listTitle);
    gamesList_ = new QTreeWidget;
    gamesList_->setHeaderLabels({"进程 / 窗口", "状态"});
    gamesList_->header()->setSectionResizeMode(0, QHeaderView::Stretch);
    gamesList_->setRootIsDecorated(false);
    gamesList_->setMinimumWidth(300);
    leftLayout->addWidget(gamesList_);
    auto *bindingButtons = new QHBoxLayout;
    auto *bindButton = new QPushButton("绑定所选");
    auto *detachButton = new QPushButton("解绑所选");
    bindingButtons->addWidget(bindButton);
    bindingButtons->addWidget(detachButton);
    leftLayout->addLayout(bindingButtons);
    connect(gamesList_, &QTreeWidget::currentItemChanged, this,
            [this](QTreeWidgetItem *item, QTreeWidgetItem *) {
                if (item)
                    select(item->data(0, Qt::UserRole).toUInt());
            });
    connect(bindButton, &QPushButton::clicked, this, [this] {
        if (gamesList_->currentItem())
            bind(gamesList_->currentItem()->data(0, Qt::UserRole).toUInt());
    });
    connect(detachButton, &QPushButton::clicked, this, [this] { detach(selected_, "用户解绑"); });
    auto *note =
        new QLabel("绑定只建立会话，不会自动启动任务。\n隐藏面板不影响任务；游戏退出则清理对应脚本。");
    note->setWordWrap(true);
    note->setStyleSheet("color:#66758a;font-size:12px;");
    leftLayout->addWidget(note);
    splitter->addWidget(left);
    auto *right = new QWidget;
    auto *rightLayout = new QVBoxLayout(right);
    rightLayout->setContentsMargins(8, 0, 0, 0);
    sessionLabel_ = new QLabel("请先选择并绑定游戏进程");
    sessionLabel_->setStyleSheet("font-weight:600;font-size:15px;");
    rightLayout->addWidget(sessionLabel_);
    auto *group = new QGroupBox("洛阳移动 / 种植测试 · Lua 参数");
    auto *form = new QFormLayout(group);
    form->addRow("脚本", new QLabel("洛阳移动 / 种植规则"));
    form->addRow("地图", new QLabel("洛阳（需先进入该地图）"));
    auto *coordinates = new QHBoxLayout;
    x_ = new QSpinBox;
    y_ = new QSpinBox;
    x_->setRange(0, 10000);
    y_->setRange(0, 10000);
    x_->setValue(360);
    y_->setValue(317);
    coordinates->addWidget(new QLabel("X"));
    coordinates->addWidget(x_);
    coordinates->addWidget(new QLabel("Y"));
    coordinates->addWidget(y_);
    form->addRow("目标坐标", coordinates);
    crop_ = new QLineEdit;
    crop_->setMaxLength(64);
    crop_->setPlaceholderText("种植测试填写作物；真实移动可留空");
    form->addRow("作物参数", crop_);
    rounds_ = new QSpinBox;
    rounds_->setRange(1, 100);
    rounds_->setValue(1);
    form->addRow("执行次数", rounds_);
    tolerance_ = new QDoubleSpinBox;
    tolerance_->setRange(0.1, 5);
    tolerance_->setValue(1);
    tolerance_->setSingleStep(0.1);
    form->addRow("到达容差", tolerance_);
    timeout_ = new QSpinBox;
    timeout_->setRange(10, 1800);
    timeout_->setValue(120);
    timeout_->setSuffix(" 秒");
    form->addRow("任务超时", timeout_);
    mode_ = new QComboBox;
    mode_->addItem("真实移动到坐标（洛阳，32 格内，不播种）", "live_move");
    mode_->addItem("流程预演（不操作游戏）", "preview");
    mode_->addItem("真实种植（种植接口尚未接入）", "live");
    form->addRow("运行方式", mode_);
    rightLayout->addWidget(group);
    auto *buttons = new QHBoxLayout;
    start_ = new QPushButton("开始任务");
    start_->setStyleSheet("QPushButton{background:#177d82;color:white;border-color:#177d82;} "
                          "QPushButton:disabled{background:#dbe2e9;color:#7b8797;border-color:#dbe2e9;}");
    pause_ = new QPushButton("暂停 / 恢复");
    stop_ = new QPushButton("停止任务");
    reload_ = new QPushButton("重新加载 Lua");
    for (auto *b : {start_, pause_, stop_, reload_})
        buttons->addWidget(b);
    rightLayout->addLayout(buttons);
    connect(start_, &QPushButton::clicked, this, [this] { taskStart(); });
    connect(pause_, &QPushButton::clicked, this,
            [this] { send(sessions_.value(selected_), {{"op", "pause"}}); });
    connect(stop_, &QPushButton::clicked, this,
            [this] { send(sessions_.value(selected_), {{"op", "stop"}}); });
    connect(reload_, &QPushButton::clicked, this,
            [this] { send(sessions_.value(selected_), {{"op", "reload"}}); });
    auto *scriptLabel = new QLabel("脚本：luoyang_plant.lua · 参数修改无需重新编译 · 重载失败保留旧版本");
    scriptLabel->setWordWrap(true);
    scriptLabel->setStyleSheet("color:#526176;font-size:12px;");
    rightLayout->addWidget(scriptLabel);
    status_ = new QLabel("任务未启动");
    status_->setWordWrap(true);
    status_->setMinimumHeight(fontMetrics().lineSpacing() * 2 + 6);
    rightLayout->addWidget(status_);
    logs_ = new QPlainTextEdit;
    logs_->setReadOnly(true);
    logs_->setMaximumBlockCount(1000);
    logs_->setPlaceholderText("会话日志。预演日志会明确标记，不代表实际游戏操作。");
    rightLayout->addWidget(logs_, 1);
    splitter->addWidget(right);
    splitter->setSizes({340, 700});
    dataRoot_ = QCoreApplication::applicationDirPath() + "/user-data";
    if (!testMode_) {
        QFile profiles(dataRoot_ + "/profiles.json");
        if (profiles.open(QIODevice::ReadOnly) && profiles.size() < 128 * 1024)
            savedProfiles_ = QJsonDocument::fromJson(profiles.readAll()).object();
        applyConfig(savedProfiles_.value("default").toObject());
    }
    workerJob_ = CreateJobObjectW(nullptr, nullptr);
    if (workerJob_) {
        JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
        limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE |
                                                  JOB_OBJECT_LIMIT_PROCESS_MEMORY |
                                                  JOB_OBJECT_LIMIT_JOB_MEMORY;
        limits.ProcessMemoryLimit = 192ULL * 1024 * 1024;
        limits.JobMemoryLimit = 512ULL * 1024 * 1024;
        JOBOBJECT_CPU_RATE_CONTROL_INFORMATION cpu{};
        cpu.ControlFlags = JOB_OBJECT_CPU_RATE_CONTROL_ENABLE | JOB_OBJECT_CPU_RATE_CONTROL_HARD_CAP;
        cpu.CpuRate = 1000;
        if (!SetInformationJobObject(workerJob_, JobObjectExtendedLimitInformation, &limits,
                                     sizeof(limits)) ||
            !SetInformationJobObject(workerJob_, JobObjectCpuRateControlInformation, &cpu, sizeof(cpu))) {
            CloseHandle(workerJob_);
            workerJob_ = nullptr;
        }
    }
    if (!workerJob_)
        banner_->setText("资源隔离配置失败，当前禁止创建脚本 Worker。请查看正常用户桌面环境。");
    if (!testMode_) {
        activeWindow = this;
        qApp->installNativeEventFilter(this);
        foregroundHook_ = SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, nullptr,
                                          onForeground, 0, 0, WINEVENT_OUTOFCONTEXT);
        allStopRegistered_ = RegisterHotKey(nullptr, 0x5104, MOD_CONTROL | MOD_ALT | MOD_NOREPEAT, VK_END);
        tray_ = new QSystemTrayIcon(style()->standardIcon(QStyle::SP_ComputerIcon), this);
        tray_->setToolTip("TLBB Lua 任务客户端");
        auto *menu = new QMenu(this);
        menu->addAction("显示面板", this, [this] {
            showNormal();
            raise();
            activateWindow();
        });
        menu->addAction("停止全部任务", this, [this] { stopAll(); });
        menu->addAction("退出并停止", this, [this] { quitClient(); });
        tray_->setContextMenu(menu);
        connect(tray_, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
            if (reason == QSystemTrayIcon::DoubleClick)
                togglePanel();
        });
        if (QSystemTrayIcon::isSystemTrayAvailable())
            tray_->show();
    }
    auto *refreshTimer = new QTimer(this);
    refreshTimer->setInterval(2000);
    connect(refreshTimer, &QTimer::timeout, this, [this] {
        refreshGames();
        syncHotkeys();
    });
    refreshTimer->start();
    auto *supervise = new QTimer(this);
    supervise->setInterval(500);
    connect(supervise, &QTimer::timeout, this, [this] {
        for (auto *s : sessions_)
            if (!s->detaching && s->worker && s->worker->state() != QProcess::NotRunning &&
                s->heartbeat.elapsed() > 4000) {
                append(s, "Worker 无响应，已停止该会话");
                detach(s->info.pid, "Worker 超时");
            }
    });
    supervise->start();
    refreshGames();
    select(0);
    statusBar()->showMessage("真实移动测试版 0.2 · 种植待适配 · Ctrl+Alt+End 停止全部任务");
}
MainWindow::~MainWindow() {
    activeWindow = nullptr;
    if (foregroundHook_)
        UnhookWinEvent(foregroundHook_);
    for (int id : {0x5101, 0x5102, 0x5103, 0x5104})
        UnregisterHotKey(nullptr, id);
    qApp->removeNativeEventFilter(this);
    // Only our Workers belong to this job; game processes are never assigned.
    if (workerJob_)
        CloseHandle(workerJob_);
    for (auto *s : sessions_) {
        if (s->exitWatch)
            s->exitWatch->setEnabled(false);
        if (s->worker) {
            s->worker->disconnect(this);
            if (s->worker->state() != QProcess::NotRunning) {
                s->worker->kill();
                s->worker->waitForFinished(500);
            }
        }
        delete s;
    }
}
void MainWindow::append(Session *s, const QString &text) {
    QString line = QDateTime::currentDateTime().toString("HH:mm:ss") + "  " + text.left(1024);
    if (s) {
        s->log.append(line);
        while (s->log.size() > 200)
            s->log.removeFirst();
    }
    if (isVisible() && (!s || s->info.pid == selected_))
        logs_->appendPlainText(line);
}
QJsonObject MainWindow::config() const {
    return {{"x", x_->value()},
            {"y", y_->value()},
            {"crop", crop_->text().trimmed()},
            {"rounds", rounds_->value()},
            {"tolerance", tolerance_->value()},
            {"timeout_seconds", timeout_->value()}};
}
void MainWindow::applyConfig(const QJsonObject &c) {
    if (c.isEmpty())
        return;
    x_->setValue(c.value("x").toInt(360));
    y_->setValue(c.value("y").toInt(317));
    crop_->setText(c.value("crop").toString());
    rounds_->setValue(c.value("rounds").toInt(1));
    tolerance_->setValue(c.value("tolerance").toDouble(1));
    timeout_->setValue(c.value("timeout_seconds").toInt(120));
}
void MainWindow::saveProfile() {
    if (auto *s = sessions_.value(selected_))
        s->config = config();
    if (testMode_)
        return;
    savedProfiles_.insert("default", config());
    QDir().mkpath(dataRoot_);
    QSaveFile file(dataRoot_ + "/profiles.json");
    if (file.open(QIODevice::WriteOnly)) {
        file.write(QJsonDocument(savedProfiles_).toJson());
        if (!file.commit())
            append(nullptr, "保存参数失败");
    }
}
void MainWindow::select(quint32 pid) {
    if (auto *previous = sessions_.value(selected_)) {
        previous->config = config();
        previous->mode = mode_->currentData().toString();
    }
    selected_ = pid;
    logs_->clear();
    auto *s = sessions_.value(pid);
    if (s) {
        applyConfig(s->config);
        mode_->setCurrentIndex(qMax(0, mode_->findData(s->mode)));
        sessionLabel_->setText(QString("当前会话 · PID %1").arg(pid));
        for (const auto &line : s->log)
            logs_->appendPlainText(line);
        status_->setText(s->status);
    } else {
        sessionLabel_->setText(pid ? QString("PID %1 · 尚未绑定").arg(pid) : "请先选择并绑定游戏进程");
        status_->setText("任务未启动");
    }
    start_->setEnabled(s && s->ready && !s->running && !s->detaching);
    pause_->setEnabled(s && s->running && !s->detaching);
    stop_->setEnabled(s && s->ready && !s->detaching);
    reload_->setEnabled(s && s->ready && !s->detaching);
}
void MainWindow::updateRows() {
    for (int i = 0; i < gamesList_->topLevelItemCount(); ++i) {
        auto *item = gamesList_->topLevelItem(i);
        auto *s = sessions_.value(item->data(0, Qt::UserRole).toUInt());
        item->setText(1, s ? s->status : "未绑定");
    }
    auto *s = sessions_.value(selected_);
    start_->setEnabled(s && s->ready && !s->running && !s->detaching);
    pause_->setEnabled(s && s->running && !s->detaching);
    stop_->setEnabled(s && s->ready && !s->detaching);
    reload_->setEnabled(s && s->ready && !s->detaching);
    if (s) {
        QString text = QString("%1 · Lua %2 · Worker 提交内存 %3 MiB")
                           .arg(s->status, s->version.isEmpty() ? "未加载" : s->version)
                           .arg(s->bytes / 1048576.0, 0, 'f', 1);
        if (s->liveState.value("position_valid").toBool())
            text += QString("\n真实位置：%1（%2，%3）")
                        .arg(s->liveState.value("map").toString())
                        .arg(s->liveState.value("x").toDouble(), 0, 'f', 2)
                        .arg(s->liveState.value("y").toDouble(), 0, 'f', 2);
        status_->setText(text);
    }
}
void MainWindow::refreshGames() {
    games_ = discoverGames(QDir::fromNativeSeparators(root_->text()));
    QSet<quint32> listed;
    gamesList_->blockSignals(true);
    for (const auto &game : games_) {
        listed.insert(game.pid);
        QTreeWidgetItem *item = nullptr;
        for (int i = 0; i < gamesList_->topLevelItemCount(); ++i)
            if (gamesList_->topLevelItem(i)->data(0, Qt::UserRole).toUInt() == game.pid)
                item = gamesList_->topLevelItem(i);
        if (!item) {
            item = new QTreeWidgetItem(gamesList_);
            item->setData(0, Qt::UserRole, game.pid);
        }
        item->setText(0, QString("PID %1\n%2")
                             .arg(game.pid)
                             .arg(game.title.isEmpty() ? "角色未解析 / 窗口未枚举" : game.title));
    }
    for (int i = gamesList_->topLevelItemCount() - 1; i >= 0; --i)
        if (!listed.contains(gamesList_->topLevelItem(i)->data(0, Qt::UserRole).toUInt()))
            delete gamesList_->takeTopLevelItem(i);
    gamesList_->blockSignals(false);
    updateRows();
    if (launchTime_.isValid()) {
        if (launchTime_.elapsed() > 60000) {
            launchTime_.invalidate();
            append(nullptr, "等待游戏进程超时；未重复启动");
        } else
            for (const auto &game : games_)
                if (!beforeLaunch_.contains(game.pid)) {
                    launchTime_.invalidate();
                    bind(game.pid);
                    break;
                }
    }
}
void MainWindow::send(Session *s, QJsonObject command) {
    if (!s || s->detaching || !s->worker || s->worker->state() != QProcess::Running)
        return;
    command.insert("session", s->id);
    auto data = QJsonDocument(command).toJson(QJsonDocument::Compact) + "\n";
    if (data.size() > 8192 || s->worker->bytesToWrite() > 65536) {
        append(s, "控制队列超过上限，已拒绝请求");
        return;
    }
    s->worker->write(data);
}
void MainWindow::bind(quint32 pid) {
    if (auto *existing = sessions_.value(pid)) {
        if (existing->binding.alive() && !existing->detaching) {
            select(pid);
            return;
        }
        if (existing->worker && existing->worker->state() != QProcess::NotRunning) {
            append(existing, "正在清理旧会话，请稍后重新绑定");
            return;
        }
        if (existing->exitWatch) {
            existing->exitWatch->setEnabled(false);
            existing->exitWatch->deleteLater();
        }
        if (existing->worker)
            existing->worker->deleteLater();
        sessions_.remove(pid);
        delete existing;
    }
    // Bound history is finite too; inactive PIDs must not accumulate forever.
    if (sessions_.size() >= 32) {
        for (quint32 expired : sessions_.keys()) {
            auto *old = sessions_.value(expired);
            if (old->detaching && (!old->worker || old->worker->state() == QProcess::NotRunning)) {
                if (old->exitWatch) {
                    old->exitWatch->setEnabled(false);
                    old->exitWatch->disconnect(this);
                    old->exitWatch->deleteLater();
                }
                if (old->worker) {
                    old->worker->disconnect(this);
                    old->worker->deleteLater();
                }
                sessions_.remove(expired);
                delete old;
                if (sessions_.size() < 32)
                    break;
            }
        }
    }
    if (!workerJob_) {
        append(nullptr, "资源隔离不可用，无法创建脚本会话");
        return;
    }
    int active = 0;
    for (auto *s : sessions_)
        if (!s->detaching)
            ++active;
    if (active >= 8) {
        append(nullptr, "当前基础版最多八个绑定会话");
        return;
    }
    MEMORYSTATUSEX memory{};
    memory.dwLength = sizeof(memory);
    if (GlobalMemoryStatusEx(&memory) &&
        memory.ullAvailPhys < qMax<quint64>(2ULL * 1024 * 1024 * 1024, memory.ullTotalPhys / 10)) {
        append(nullptr, "可用内存不足，暂不新增会话");
        return;
    }
    auto *s = new Session;
    if (!s->binding.open(pid, QDir::fromNativeSeparators(root_->text()))) {
        append(nullptr, s->binding.error);
        delete s;
        return;
    }
    s->info = s->binding.info();
    s->id = QUuid::createUuid().toString(QUuid::WithoutBraces);
    s->config = config();
    s->heartbeat.start();
    sessions_.insert(pid, s);
    s->exitWatch = new QWinEventNotifier(s->binding.handle(), this);
    connect(s->exitWatch, &QWinEventNotifier::activated, this, [this, s] {
        s->exitWatch->setEnabled(false);
        detach(s->info.pid, "游戏进程已退出");
    });
    s->worker = new QProcess(this);
    s->worker->setCreateProcessArgumentsModifier(
        [](QProcess::CreateProcessArguments *a) { a->flags |= CREATE_NO_WINDOW; });
    connect(s->worker, &QProcess::started, this, [this, s] {
        HANDLE worker = OpenProcess(PROCESS_SET_QUOTA | PROCESS_TERMINATE | PROCESS_QUERY_LIMITED_INFORMATION,
                                    FALSE, DWORD(s->worker->processId()));
        bool ok = worker && AssignProcessToJobObject(workerJob_, worker);
        if (worker)
            CloseHandle(worker);
        if (!ok) {
            append(s, QString("Worker 资源隔离失败（%1），已终止脚本").arg(GetLastError()));
            detach(s->info.pid, "资源隔离失败");
        }
    });
    connect(s->worker, &QProcess::readyReadStandardOutput, this, [this, s] {
        s->output += s->worker->readAllStandardOutput();
        if (s->output.size() > 65536) {
            detach(s->info.pid, "Worker 输出超过上限");
            return;
        }
        for (int n = 0; n < 64; ++n) {
            int newline = s->output.indexOf('\n');
            if (newline < 0)
                break;
            auto line = s->output.left(newline);
            s->output.remove(0, newline + 1);
            auto event = QJsonDocument::fromJson(line).object();
            if (event.value("session").toString() == s->id)
                handle(s, event);
        }
    });
    connect(s->worker, &QProcess::readyReadStandardError, this, [this, s] {
        auto error = s->worker->readAllStandardError();
        if (!error.isEmpty())
            append(s, "Worker: " + QString::fromUtf8(error.left(2048)));
    });
    connect(s->worker, &QProcess::errorOccurred, this, [this, s](QProcess::ProcessError) {
        append(s, "Worker 启动或运行错误：" + s->worker->errorString());
    });
    connect(s->worker, qOverload<int, QProcess::ExitStatus>(&QProcess::finished), this,
            [this, s](int code, QProcess::ExitStatus) {
                s->ready = false;
                s->running = false;
                s->detaching = true;
                s->status = "已解绑";
                if (s->exitWatch)
                    s->exitWatch->setEnabled(false);
                s->binding.close();
                append(s, QString("Worker 已退出，代码 %1").arg(code));
                updateRows();
            });
    s->worker->start(QCoreApplication::applicationFilePath(),
                     {"--worker", "--target-pid", QString::number(pid), "--created", s->info.created,
                      "--session", s->id, "--game-root", QDir::fromNativeSeparators(root_->text()),
                      "--script", script_});
    select(pid);
    append(s, "已建立只读会话，等待 Worker 就绪");
    updateRows();
}
void MainWindow::detach(quint32 pid, const QString &reason) {
    auto *s = sessions_.value(pid);
    if (!s || s->detaching)
        return;
    send(s, {{"op", "quit"}});
    s->detaching = true;
    s->ready = false;
    s->running = false;
    s->status = "正在解绑";
    if (s->exitWatch)
        s->exitWatch->setEnabled(false);
    append(s, reason + "；停止该会话，不关闭游戏");
    if (s->worker) {
        s->worker->closeWriteChannel();
        QTimer::singleShot(1500, s->worker, [worker = s->worker] {
            if (worker->state() != QProcess::NotRunning)
                worker->kill();
        });
    }
    updateRows();
}
void MainWindow::handle(Session *s, const QJsonObject &e) {
    s->heartbeat.restart();
    QString type = e.value("event").toString(), message = e.value("message").toString();
    if (type == "heartbeat") {
        s->bytes = qint64(e.value("private_commit_bytes").toDouble());
        s->liveAvailable = e.value("live_position_available").toBool();
        s->liveState = e.value("live_state").toObject();
        if (isVisible())
            updateRows();
        return;
    }
    if (type == "ready") {
        s->ready = true;
        s->liveAvailable = e.value("live_position_available").toBool();
        s->status = s->liveAvailable ? "真实位置已就绪" : "只读绑定";
    } else if (type == "started") {
        s->running = true;
        s->paused = false;
        s->mode = e.value("mode").toString();
        s->status = s->mode == "live_move" ? "真实移动运行" : "预演运行";
        s->version = e.value("version").toString();
    } else if (type == "paused") {
        s->paused = e.value("paused").toBool();
        s->status = s->mode == "live_move" ? (s->paused ? "真实移动暂停" : "真实移动运行")
                                           : (s->paused ? "预演暂停" : "预演运行");
        message = s->status;
    } else if (type == "completed") {
        s->running = false;
        s->status = e.value("preview").toBool() ? "预演完成" : "真实移动完成";
    } else if (type == "stopped") {
        s->running = false;
        s->paused = false;
        s->status = s->detaching ? "正在解绑" : "任务已停止";
    } else if (type == "blocked") {
        s->status = "真实执行被阻止";
        message += "：" + liveMissingCapabilities().join("、");
    } else if (type == "reloaded")
        s->version = e.value("version").toString();
    else if (type == "error") {
        s->status = "错误";
    } else if (type == "target_exited") {
        detach(s->info.pid, "游戏进程退出");
    }
    if (!message.isEmpty())
        append(s, (e.value("preview").toBool() || s->status.startsWith("预演") ? "[预演] " : "") + message);
    updateRows();
}
void MainWindow::taskStart() {
    auto *s = sessions_.value(selected_);
    if (!s || !s->ready)
        return;
    QString error;
    auto parameters = config();
    if (mode_->currentData().toString() == "live_move")
        parameters.insert("operation", "move");
    if (!validatePlantConfig(parameters, error)) {
        append(s, error);
        return;
    }
    s->config = parameters;
    saveProfile();
    send(s, {{"op", "start"}, {"mode", mode_->currentData().toString()}, {"config", parameters}});
}
quint32 MainWindow::foregroundGame() const {
    HWND foreground = GetForegroundWindow();
    DWORD pid = 0;
    GetWindowThreadProcessId(foreground, &pid);
    if (pid == GetCurrentProcessId())
        return selected_;
    for (const auto &game : games_)
        if (game.pid == pid)
            return pid;
    return 0;
}
void MainWindow::syncHotkeys() {
    if (testMode_)
        return;
    DWORD pid = 0;
    GetWindowThreadProcessId(GetForegroundWindow(), &pid);
    bool applicable = pid == GetCurrentProcessId();
    for (const auto &game : games_)
        if (game.pid == pid)
            applicable = true;
    auto update = [&](int id, UINT key, bool &registered) {
        if (applicable && !registered)
            registered = RegisterHotKey(nullptr, id, MOD_NOREPEAT, key);
        if (!applicable && registered) {
            UnregisterHotKey(nullptr, id);
            registered = false;
        }
    };
    update(0x5101, VK_HOME, homeRegistered_);
    update(0x5102, VK_END, endRegistered_);
    update(0x5103, VK_INSERT, insertRegistered_);
    statusBar()->showMessage(applicable ? QString("Home %1 · End %2 · Insert %3 · 全部停止键 %4")
                                              .arg(homeRegistered_ ? "可用" : "冲突",
                                                   endRegistered_ ? "可用" : "冲突",
                                                   insertRegistered_ ? "可用" : "冲突",
                                                   allStopRegistered_ ? "Ctrl+Alt+End" : "注册失败，请用托盘")
                                        : "等待游戏窗口或任务面板获得焦点");
}
bool MainWindow::nativeEventFilter(const QByteArray &, void *message, qintptr *) {
    auto *msg = static_cast<MSG *>(message);
    if (msg->message != WM_HOTKEY)
        return false;
    quint32 pid = foregroundGame();
    if (msg->wParam == 0x5101 && pid)
        bind(pid);
    else if (msg->wParam == 0x5102 && pid)
        detach(pid, "End 解绑");
    else if (msg->wParam == 0x5103) {
        if (pid)
            select(pid);
        togglePanel();
    } else if (msg->wParam == 0x5104)
        stopAll();
    else
        return false;
    return true;
}
void MainWindow::togglePanel() {
    if (isVisible() && !isMinimized()) {
        saveProfile();
        hide();
        if (returnWindow_ && IsWindow(returnWindow_))
            SetForegroundWindow(returnWindow_);
    } else {
        returnWindow_ = GetForegroundWindow();
        showNormal();
        raise();
        activateWindow();
        select(selected_);
        updateRows();
    }
}
void MainWindow::stopAll() {
    for (auto *s : sessions_)
        send(s, {{"op", "stop"}});
}
void MainWindow::quitClient() {
    if (quitting_)
        return;
    quitting_ = true;
    saveProfile();
    for (auto *s : sessions_)
        detach(s->info.pid, "客户端退出");
    QTimer::singleShot(1700, qApp, &QCoreApplication::quit);
}
void MainWindow::closeEvent(QCloseEvent *event) {
    if (!quitting_ && tray_ && tray_->isVisible()) {
        saveProfile();
        hide();
        event->ignore();
        return;
    }
    if (!quitting_) {
        event->ignore();
        quitClient();
        return;
    }
    QMainWindow::closeEvent(event);
}
void MainWindow::launchGame() {
    QString root = QDir::fromNativeSeparators(root_->text()), launcher = root + "/Launch.exe";
    if (!QFileInfo::exists(launcher)) {
        append(nullptr, "未找到安装目录下的 Launch.exe");
        return;
    }
    if (launchTime_.isValid()) {
        append(nullptr, "已有启动请求等待中");
        return;
    }
    MEMORYSTATUSEX memory{};
    memory.dwLength = sizeof(memory);
    if (GlobalMemoryStatusEx(&memory) &&
        memory.ullAvailPhys < qMax<quint64>(2ULL * 1024 * 1024 * 1024, memory.ullTotalPhys / 10)) {
        append(nullptr, "可用内存不足，暂不启动新游戏");
        return;
    }
    beforeLaunch_.clear();
    for (const auto &game : discoverGames(root))
        beforeLaunch_.insert(game.pid);
    QProcess launcherProcess;
    launcherProcess.setProgram(launcher);
    launcherProcess.setWorkingDirectory(root);
    if (!launcherProcess.startDetached()) {
        append(nullptr, "启动器启动失败");
        return;
    }
    launchTime_.start();
    append(nullptr, "启动器已打开，等待实际游戏进程；不解除游戏实例限制");
}
bool MainWindow::saveScreenshot(const QString &path) {
    show();
    qApp->processEvents();
    select(selected_);
    updateRows();
    qApp->processEvents();
    QImage image(size() * devicePixelRatioF(), QImage::Format_ARGB32);
    image.setDevicePixelRatio(devicePixelRatioF());
    render(&image);
    return image.save(path);
}
bool MainWindow::bindForSmoke(quint32 pid) {
    if (!testMode_)
        return false;
    bind(pid);
    QElapsedTimer timer;
    timer.start();
    while (timer.elapsed() < 2500) {
        qApp->processEvents();
        auto *s = sessions_.value(pid);
        if (s && s->ready && (!s->liveAvailable || s->liveState.value("position_valid").toBool()))
            return true;
        QThread::msleep(5);
    }
    return false;
}
QJsonObject MainWindow::diagnostics() const {
    QJsonArray sessions;
    bool movement = false;
    for (auto *s : sessions_) {
        movement = movement || s->liveAvailable;
        sessions.append(QJsonObject{{"pid", int(s->info.pid)},
                                    {"ready", s->ready},
                                    {"status", s->status},
                                    {"running", s->running},
                                    {"worker_private_commit_bytes", double(s->bytes)},
                                    {"live_position_available", s->liveAvailable},
                                    {"live_state", s->liveState}});
    }
    return {{"resource_job_configured", workerJob_ != nullptr},
            {"sessions", sessions},
            {"hotkeys_tested", false},
            {"game_actions_available", movement},
            {"planting_available", false},
            {"scope", "UI rendering and read-only binding; no gameplay commands"}};
}
} // namespace tlbb
