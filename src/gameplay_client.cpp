#include "gameplay_client.hpp"
#include "core.hpp"
#include "live_layout.hpp"
#include "login_protocol.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QRandomGenerator>
#include <cmath>
#include <cstring>
namespace tlbb {
struct GameplayChannel::Impl {
    ProcessBinding binding;HMODULE library=nullptr;HOOKPROC callback=nullptr;HWND window=nullptr;DWORD thread=0;uint32_t frameKind=0;
    ~Impl(){if(library)FreeLibrary(library);}
};
GameplayChannel::GameplayChannel():p_(std::make_unique<Impl>()){}
GameplayChannel::~GameplayChannel()=default;
bool GameplayChannel::open(quint32 pid,const QString &created,const QString &root,QString &error){
    if(p_->library){error="动作通道已打开";return false;}
    if(!p_->binding.open(pid,root,created)){error=p_->binding.error;return false;}
    auto hash=[](const QString &path,const char *expected){QFile file(path);if(!file.open(QIODevice::ReadOnly))return false;QCryptographicHash h(QCryptographicHash::Sha256);return h.addData(&file)&&h.result().toHex()==expected;};
    if(!hash(p_->binding.info().path,live::imageSha256)||!hash(root+"/Bin64/CEGUIBase.dll",login::ceguiSha256)||!hash(root+"/Bin64/LuaPlus.dll",login::luaPlusSha256)){
        error="当前游戏/界面/脚本 SDK 版本未适配";return false;
    }
    for(const auto &game:discoverGames(root))if(game.pid==pid&&game.created==created)p_->window=reinterpret_cast<HWND>(game.window);
    DWORD owner=0;p_->thread=GetWindowThreadProcessId(p_->window,&owner);
    if(!p_->window||owner!=pid||!p_->thread){error="未找到当前会话的游戏窗口";return false;}
    const auto path=QDir::toNativeSeparators(QCoreApplication::applicationDirPath()+"/TLBBEngine.dll");
    p_->library=LoadLibraryExW(reinterpret_cast<LPCWSTR>(path.utf16()),nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if(!p_->library){error="缺少任务动作桥接 DLL";return false;}
    auto symbol=GetProcAddress(p_->library,"TlbbGameplayHook");std::memcpy(&p_->callback,&symbol,sizeof(symbol));
    if(!p_->callback){error="任务动作桥接入口缺失";return false;}
    return true;
}
bool GameplayChannel::exchange(gameplay::Packet &request,QJsonObject &state,QString &error){
    state={};error.clear();
    if(!p_->callback||!p_->binding.alive()||!gameplay::validCommand(request.command,request.argument)){error="动作通道或参数无效";return false;}
    if(request.command==gameplay::RunSnippet&&!gameplay::validSnippet(request.argument,request.args)){error="游戏片段参数超出允许范围";return false;}
    DWORD owner=0;if(GetWindowThreadProcessId(p_->window,&owner)!=p_->thread||owner!=p_->binding.info().pid){error="游戏窗口身份已改变";return false;}
    request.frameKind=p_->frameKind;
    request.targetPid=owner;request.ownerPid=GetCurrentProcessId();request.targetThread=p_->thread;
    request.created=p_->binding.info().created.toULongLong();request.nonce=QRandomGenerator::system()->generate64();request.expires=GetTickCount64()+2500;
    wchar_t name[128]{};gameplay::mappingName(name,owner,request.nonce);
    HANDLE mapping=CreateFileMappingW(INVALID_HANDLE_VALUE,nullptr,PAGE_READWRITE,0,sizeof(request),name);const auto code=GetLastError();
    if(!mapping||code==ERROR_ALREADY_EXISTS){if(mapping)CloseHandle(mapping);error="无法创建独立动作通道";return false;}
    auto remote=static_cast<gameplay::Packet*>(MapViewOfFile(mapping,FILE_MAP_READ|FILE_MAP_WRITE,0,0,sizeof(request)));
    if(!remote){CloseHandle(mapping);error="无法映射动作请求";return false;}
    std::memcpy(remote,&request,sizeof(request));
    HHOOK hook=SetWindowsHookExW(WH_GETMESSAGE,p_->callback,p_->library,p_->thread);
    DWORD dispatchError=hook?0:GetLastError();bool posted=false;
    if(hook){const auto message=RegisterWindowMessageW(gameplay::messageName);posted=message&&PostMessageW(p_->window,message,owner,LPARAM(request.nonce));if(!posted)dispatchError=GetLastError();}
    QElapsedTimer time;time.start();while(posted&&remote->status<gameplay::Done&&time.elapsed()<3000&&p_->binding.alive())Sleep(10);
    if(hook)UnhookWindowsHookEx(hook);
    gameplay::cancelPending(*remote,dispatchError?dispatchError:WAIT_TIMEOUT);
    const bool ok=remote->status==gameplay::Done&&remote->executedThread==p_->thread;
    if(ok&&remote->frameKind>=1&&remote->frameKind<=3)p_->frameKind=remote->frameKind;
    std::memcpy(&request,remote,sizeof(request));
    state={{"ready",bool(request.stateReady)},{"visible",bool(request.frameVisible)},{"today",int(request.today)},
        {"signed_today",bool(request.signedToday)},{"signed_days",int(request.signedDays)},{"manual",bool(request.manual)},
        {"actions",int(request.actionIssued)},{"command",int(request.command)},{"argument",int(request.argument)},
        {"bridge_status",int(request.status)},{"win32_error",int(dispatchError?dispatchError:request.error)}};
    if(!ok){const auto detail=QString::fromWCharArray(request.detail).left(96);error=detail.isEmpty()?"动作通道未确认；本次停止且不会重发":detail;}
    UnmapViewOfFile(remote);CloseHandle(mapping);return ok;
}
bool GameplayChannel::call(gameplay::Command command,int argument,QJsonObject &state,QString &error){
    gameplay::Packet request;request.command=command;request.argument=uint32_t(argument);
    return exchange(request,state,error);
}
bool GameplayChannel::snippet(uint32_t id,const gameplay::SnippetArgs &args,SnippetReply &reply,QString &error){
    reply={};gameplay::Packet request;request.command=gameplay::RunSnippet;request.argument=id;request.args=args;
    QJsonObject state;const bool ok=exchange(request,state,error);
    reply.actions=request.actionIssued!=0;reply.manual=request.manual!=0;
    if(!ok)return false;
    reply.count=int(qMin<uint32_t>(request.resultCount,8));
    for(int i=0;i<8;++i)reply.numbers[i]=std::isfinite(request.results[i])?request.results[i]:0;
    request.resultText[512]=0;reply.text=QString::fromWCharArray(request.resultText);
    return true;
}
quintptr GameplayChannel::window()const{return reinterpret_cast<quintptr>(p_->window);}
bool validateDailySignConfig(const QJsonObject &config,QString &error){
    const auto value=config.value("timeout_seconds");const double timeout=value.toDouble(-1);
    if(!value.isDouble()||!std::isfinite(timeout)||std::floor(timeout)!=timeout||timeout<10||timeout>300){error="签到超时应为 10–300 秒";return false;}
    error.clear();return true;
}
int runGameplayProbe(const QStringList &args){
    auto arg=[&](const QString &key){const int i=args.indexOf(key);return i>=0&&i+1<args.size()?args[i+1]:QString();};
    GameplayChannel channel;QString error;QJsonObject state;
    bool ok=channel.open(arg("--target-pid").toUInt(),arg("--created"),arg("--game-root"),error)
        &&channel.call(gameplay::Query,0,state,error);
    state.insert("success",ok);state.insert("error",error);state.insert("query_only",true);
    if(ok&&args.contains("--read")){
        // Read-only diagnostics for live acceptance. Action snippets are never sent from here.
        struct Read{const char *label;uint32_t id;std::initializer_list<int> ints;const wchar_t *text;};
        const Read reads[]={{"money",gameplay::PlayerData,{0},L""},{"money_jz",gameplay::PlayerData,{1},L""},{"level",gameplay::PlayerData,{8},L""},
            {"team",gameplay::TeamCount,{},L""},{"bank",gameplay::BankState,{},L""},{"talisman_low",gameplay::BagCount,{},L"低级宝石合成符"},
            {"gems_bag",gameplay::GemList,{0},L""},{"sweep_count",gameplay::SweepCount,{},L""},{"sweep_data",gameplay::SweepData,{},L""},
            {"sweep_all_visible",gameplay::WindowVisible,{},L"SweepAll"},{"quest_options",gameplay::QuestOptions,{},L""}};
        QJsonObject reads_out;
        for(const auto &r:reads){
            gameplay::SnippetArgs a;int i=0;for(int v:r.ints)a.ints[i++]=v;std::wcsncpy(a.text,r.text,48);
            if(gameplay::snippetIssuesAction(r.id))continue;
            SnippetReply reply;QString readError;QJsonArray values;
            const bool readOk=channel.snippet(r.id,a,reply,readError);
            for(int n=0;n<reply.count;++n)values.append(reply.numbers[n]);
            reads_out.insert(r.label,QJsonObject{{"ok",readOk},{"error",readError},{"values",values},{"text",reply.text},{"actions",reply.actions}});
        }
        state.insert("reads",reads_out);state.insert("read_only",true);
    }
    QFile output(arg("--report"));if(!output.open(QIODevice::WriteOnly))return 3;
    output.write(QJsonDocument(state).toJson());return ok?0:1;
}
}
