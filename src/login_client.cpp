#include "game_layout.hpp"
#include "login_client.hpp"
#include "client_store.hpp"
#include "core.hpp"
#include "live_layout.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QRandomGenerator>
#include <QTextStream>
#include <psapi.h>
#include <cstring>

namespace tlbb {
namespace {
QString arg(const QStringList &args,const QString &key,const QString &fallback={}){int i=args.indexOf(key);return i>=0&&i+1<args.size()?args[i+1]:fallback;}
void event(const QString &message,const QString &kind="status",QJsonObject extra={}){extra.insert("event",kind);extra.insert("message",message);QTextStream stream(stdout);stream<<QJsonDocument(extra).toJson(QJsonDocument::Compact)<<'\n';stream.flush();}
bool hashFile(const QString &path,const char *expected){QFile file(path);if(!file.open(QIODevice::ReadOnly))return false;QCryptographicHash hash(QCryptographicHash::Sha256);return hash.addData(&file)&&hash.result().toHex()==expected;}
struct Channel {
    ProcessBinding binding;HMODULE library=nullptr;HOOKPROC entry=nullptr;HWND window=nullptr;DWORD thread=0;
    ~Channel(){if(library)FreeLibrary(library);}
    bool open(quint32 pid,const QString &created,const QString &root,QString &error){
        if(!binding.open(pid,root,created)){error="无法绑定本次启动的游戏进程";return false;}
        // The engine resolves its own addresses inside the game; this checks the file first so a mismatch is reported here, before anything is loaded.
        {std::string why;if(!layout::ensure(reinterpret_cast<const wchar_t*>(binding.info().path.utf16()),why)){error="当前游戏版本无法自动识别登录接口，已停止自动登录："+QString::fromStdString(why);return false;}}
        auto games=discoverGames(root);for(const auto &g:games)if(g.pid==pid&&g.created==created)window=reinterpret_cast<HWND>(g.window);
        DWORD owner=0;thread=GetWindowThreadProcessId(window,&owner);if(!window||owner!=pid||!thread){error="游戏窗口尚未就绪";return false;}
        auto path=QDir::toNativeSeparators(QCoreApplication::applicationDirPath()+"/TLBBEngine.dll");
        library=LoadLibraryExW(reinterpret_cast<LPCWSTR>(path.utf16()),nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
        if(!library){error="登录适配库缺失";return false;}auto symbol=GetProcAddress(library,"TlbbLoginHook");std::memcpy(&entry,&symbol,sizeof(entry));
        if(!entry){error="登录适配库入口缺失";return false;}return true;
    }
    bool call(login::Packet &p,QString &error){
        struct SecretCleanup{login::Packet &packet;~SecretCleanup(){SecureZeroMemory(packet.password,sizeof(packet.password));SecureZeroMemory(packet.account,sizeof(packet.account));}} cleanup{p};
        if(!binding.alive()){error="游戏进程已退出，登录已停止";return false;}
        DWORD owner=0;if(GetWindowThreadProcessId(window,&owner)!=thread||owner!=binding.info().pid){error="游戏窗口身份发生变化，登录已停止";return false;}
        p.targetPid=owner;p.ownerPid=GetCurrentProcessId();p.targetThread=thread;p.created=binding.info().created.toULongLong();p.nonce=QRandomGenerator::system()->generate64();p.expires=GetTickCount64()+(p.command==login::Query?4000:2500);
        wchar_t name[128]{};login::mappingName(name,owner,p.nonce);
        HANDLE mapping=CreateFileMappingW(INVALID_HANDLE_VALUE,nullptr,PAGE_READWRITE,0,sizeof(p),name);const auto code=GetLastError();
        if(!mapping||code==ERROR_ALREADY_EXISTS){if(mapping)CloseHandle(mapping);error="登录命令通道创建失败";return false;}
        auto *remote=static_cast<login::Packet*>(MapViewOfFile(mapping,FILE_MAP_READ|FILE_MAP_WRITE,0,0,sizeof(p)));
        if(!remote){CloseHandle(mapping);error="登录命令通道不可用";return false;}
        std::memcpy(remote,&p,sizeof(p));SecureZeroMemory(p.password,sizeof(p.password));
        HHOOK hook=SetWindowsHookExW(WH_GETMESSAGE,entry,library,thread);
        DWORD dispatchError=hook?0:GetLastError();
        bool posted=false;
        if(hook){const UINT message=RegisterWindowMessageW(login::messageName);posted=message&&PostMessageW(window,message,owner,LPARAM(p.nonce));if(!posted)dispatchError=GetLastError();}
        const qint64 waitLimit=p.command==login::Query?5000:3000;
        QElapsedTimer time;time.start();while(posted&&remote->status<2&&time.elapsed()<waitLimit&&binding.alive())Sleep(10);
        if(hook)UnhookWindowsHookEx(hook);
        // A pending request can be cancelled atomically. An executing callback owns its view until
        // it returns: do not erase data underneath the game if a callback outlasts the deadline.
        login::cancelPending(*remote,dispatchError);
        bool ok=remote->status==2&&remote->executedThread==thread;
        if(remote->status>=2){SecureZeroMemory(remote->password,sizeof(remote->password));SecureZeroMemory(remote->account,sizeof(remote->account));std::memcpy(&p,remote,sizeof(p));SecureZeroMemory(remote,sizeof(*remote));}
        else{p.status=1;p.error=WAIT_TIMEOUT;}
        UnmapViewOfFile(remote);CloseHandle(mapping);
        if(!ok){if(p.status==login::Rejected)error=QString("登录接口拒绝执行（%1），已停止本次登录").arg(p.error)+(p.prompt[0]?QString("：")+QString::fromWCharArray(p.prompt):QString());
            else if(dispatchError)error=QString("登录命令无法投递（%1），已停止本次登录").arg(dispatchError);
            else error="游戏状态接口等待超时，未确认执行结果";}
        return ok;
    }
};
QString stageText(unsigned stage){switch(stage){case login::Server:return "正在选择大区和服务器";case login::Account:return "正在登录账号";case login::Roles:return "正在选择角色";case login::World:return "正在确认角色进入游戏";case login::Manual:return "等待人工完成游戏验证或关闭提示窗口";default:return "等待游戏登录界面";}}
void fillIdentity(login::Packet &packet,const QJsonObject &identity){identity.value("district").toString().left(128).toWCharArray(packet.district);identity.value("server").toString().left(128).toWCharArray(packet.server);packet.slot=identity.value("slot").toInt(1);}
bool gameBytes(const QByteArray &utf8,char *out,int capacity){
    wchar_t wide[513]{};int n=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,utf8.constData(),int(utf8.size()),wide,512);BOOL changed=FALSE;
    int size=n?WideCharToMultiByte(936,WC_NO_BEST_FIT_CHARS,wide,n,out,capacity-1,nullptr,&changed):0;
    SecureZeroMemory(wide,sizeof(wide));if(size<=0||changed){SecureZeroMemory(out,SIZE_T(capacity));return false;}out[size]=0;return true;
}
}
int runLoginWorker(const QStringList &args){
    QString error;Channel channel;
    const auto identity=QJsonDocument::fromJson(QByteArray::fromBase64(arg(args,"--identity").toLatin1(),QByteArray::Base64UrlEncoding)).object();
    const QString root=arg(args,"--game-root");
    if(identity.value("district").toString().isEmpty()||identity.value("server").toString().isEmpty()||identity.value("slot").toInt()<1||identity.value("slot").toInt()>3){event("请配置完整的大区、服务器和角色 1 至 3","failed");return 2;}
    if(!channel.open(arg(args,"--target-pid").toUInt(),arg(args,"--created"),root,error)){event(error,"failed");return 2;}
    const bool probe=args.contains("--login-read-only");
    if(probe){login::Packet p;fillIdentity(p,identity);if(!channel.call(p,error)){event(error,"failed");return 2;}QJsonObject extra{{"stage",int(p.stage)},{"actions",int(p.actionIssued)},{"current_district",QString::fromWCharArray(p.currentDistrict)},{"current_server",QString::fromWCharArray(p.currentServer)}};if(args.contains("--include-cached-roles")){QJsonObject names;for(int i=0;i<3;++i){auto name=QString::fromWCharArray(p.roleNames[i]).trimmed();if(!name.isEmpty())names.insert(QString::number(i+1),name);}extra.insert("roles",names);extra.insert("role_text_encoding","cegui-utf8-v1");}event(stageText(p.stage),"probe",extra);return p.actionIssued?3:0;}
    ClientStore store(arg(args,"--data-root"));if(!store.load(error)){event(error,"failed");return 2;}
    QJsonObject account;for(const auto &value:store.launcher.value("accounts").toArray())if(value.toObject().value("id")==identity.value("account"))account=value.toObject();
    if(account.isEmpty()||account.value("login").toString().trimmed().isEmpty()||account.value("credential_ref").toString()!=identity.value("account").toString()){event("此账号缺少本机加密密码，请编辑账号后重新开始","failed");return 2;}
    LoginFlow flow;QElapsedTimer total,unchanged;total.start();unchanged.start();unsigned previous=999;int lastCommand=0;QJsonObject roles;unsigned failures=0;bool modeTried=false;int notices=0;
    const unsigned desiredMode=account.value("login").toString().contains('@')?2:1;
    while(total.elapsed()<300000&&channel.binding.alive()){
        login::Packet state;fillIdentity(state,identity);
        if(!channel.call(state,error)){
            // Retrying a query cannot repeat account/role actions. A cancelled pending mapping
            // cannot be claimed by a later game callback, even if the boot screen starts pumping.
            const qint64 queryBudget=lastCommand==0?90000:45000;
            if(login::transientQueryFailure(state)&&unchanged.elapsed()<queryBudget&&++failures<45){
                if(failures==1)event("等待游戏界面就绪，只读状态查询尚未响应");
                Sleep(1000);continue;}
            event(error,"failed",{{"stage",int(state.stage)},{"bridge_status",int(state.status)},{"win32_error",int(state.error)}});return 2;
        }
        if(previous!=state.stage){previous=state.stage;unchanged.restart();event(state.stage==login::Manual&&state.prompt[0]?stageText(state.stage)+QString("（窗口：%1）").arg(QString::fromWCharArray(state.prompt)):stageText(state.stage),"status",{{"prompt",QString::fromWCharArray(state.prompt)}});}
        int next=flow.next(login::Stage(state.stage));
        if(next==0&&flow.shouldRetry(login::Stage(state.stage),unchanged.elapsed(),state.passwordFilled))next=login::RetryLogon;
        if(next==0&&flow.credentialsSent&&flow.presses==0&&state.stage==login::Account&&unchanged.elapsed()>8000){event("密码输入后 8 秒仍未进入密码框，未按登录；请手动输入密码后点登录","failed");return 2;}
        if(flow.serverSent&&(state.stage==login::Account||state.stage==login::Roles)&&!state.selectedMatches){event("游戏实际区服与配置不一致，自动登录已停止，没有继续提交账号或角色操作","failed");return 2;}
        if(next==-2){event("游戏已进入其他登录阶段或已在线，已停止自动提交；可正常使用 Home 绑定","skipped");return 0;}
        if(next==-1){event("已检测到角色进入游戏","complete",{{"roles",roles},{"nickname",roles.value(QString::number(identity.value("slot").toInt()))},{"verified_world_samples",flow.worldSamples}});return 0;}
        // The server can take more than half a minute to answer a login press (seen live: ~34 s).
        const qint64 stageBudget=(lastCommand==0&&state.stage==login::Loading)||(state.stage==login::Account&&flow.presses>0)?90000:45000;
        if(state.stage!=login::Manual&&unchanged.elapsed()>stageBudget){event(state.stage==login::Account?QString("账号登录未通过或连接超时（当前账号框%1、密码框%2），请检查游戏提示；没有重复提交密码").arg(state.accountFilled?"有内容":"为空",state.passwordFilled?"有内容":"为空"):QString("登录阶段等待超时，请检查游戏窗口"),"failed",{{"account_filled",int(state.accountFilled)},{"password_filled",int(state.passwordFilled)}});return 2;}
        if(next==0&&state.stage==login::Manual&&state.noticeOk&&notices<3){next=login::DismissNotice;++notices;}
        if(next==login::SubmitAccount&&state.inputMode!=desiredMode){if(modeTried){event("游戏未切换到所需账号密码登录方式，请在游戏中手动切换后登录","failed");return 2;}next=login::SetAccountMode;modeTried=true;}
        if(next>0){
            login::Packet action;fillIdentity(action,identity);action.command=unsigned(next);action.inputMode=desiredMode;
            if(next==login::SubmitAccount){QByteArray password;if(!store.readPassword(identity.value("account").toString(),password,error)){event(error,"failed");return 2;}
                const bool converted=gameBytes(password,action.password,sizeof(action.password))&&gameBytes(account.value("login").toString().trimmed().toUtf8(),action.account,sizeof(action.account));SecureZeroMemory(password.data(),SIZE_T(password.size()));password.clear();
                if(!converted){SecureZeroMemory(action.password,sizeof(action.password));event("账号或密码包含此版本游戏不支持的字符","failed");return 2;}}
            if(!channel.call(action,error)){event(error,"failed",{{"command",next},{"stage",int(action.stage)},{"bridge_status",int(action.status)},{"win32_error",int(action.error)}});return 2;}
            if(!action.actionIssued){event("游戏需要人工验证，本次未提交操作");Sleep(1000);continue;}
            if(next==login::DismissNotice){event(QString("已点击登录提示窗口的确定（%1）").arg(QString::fromWCharArray(action.prompt)),"issued",{{"command",next}});previous=999;Sleep(1000);continue;}
            flow.issued(next);lastCommand=next;unchanged.restart();
            const char *routes[]={"","游戏登录脚本","按钮点击事件","原生点击"};const QString route=QString::fromUtf8(routes[action.pressRoute<4?action.pressRoute:0]);
            if(next==login::RetryLogon){event(QString(flow.presses==1?"密码框已显示，已按登录（方式：%1；账号框%2、密码框%3），等待游戏确认":"登录按钮按下后 10 秒无变化，已再按一次登录（未重新输入密码；方式：%1；账号框%2、密码框%3）").arg(route,action.accountFilled?"有内容":"为空",action.passwordFilled?"有内容":"为空"),"issued",{{"command",next},{"press_route",int(action.pressRoute)}});Sleep(1000);continue;}
            if(next==login::SubmitAccount&&action.pressRoute)flow.presses=1;
            if(next==login::SubmitAccount&&!action.pressRoute){event("账号密码已输入，等待密码框显示后再按登录","issued",{{"command",next}});Sleep(500);continue;}
            if(next==login::SubmitAccount){event(QString("已触发登录按钮（方式：%1；账号框%2、密码框%3），等待游戏确认").arg(route,action.accountFilled?"有内容":"为空",action.passwordFilled?"有内容":"为空"),"issued",{{"command",next},{"stage",int(action.stage)},{"press_route",int(action.pressRoute)},{"account_filled",int(action.accountFilled)},{"password_filled",int(action.passwordFilled)}});Sleep(1000);continue;}
            event(next==login::SubmitAccount?"已触发登录按钮，等待游戏确认":"已提交登录步骤，等待游戏确认","issued",{{"command",next},{"stage",int(action.stage)}});
            if(next==login::SelectRole||next==login::EnterWorld){for(int i=0;i<3;++i){auto name=QString::fromWCharArray(action.roleNames[i]).trimmed();if(!name.isEmpty())roles.insert(QString::number(i+1),name);}}
        }
        Sleep(1000);
    }
    event(channel.binding.alive()?"本次登录已超时，自动登录已停止":"游戏进程已退出，自动登录已停止","failed");return 2;
}
}
