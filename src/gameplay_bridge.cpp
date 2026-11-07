#include "gameplay_protocol.hpp"
#include "game_lua_actions.hpp"
#include "combat_world.hpp"
#include "live_layout.hpp"
#include <cstdio>
#include <cstring>
#include <cwchar>
#include <initializer_list>
namespace {
using namespace tlbb;
struct Name {union{char small[16];const char *pointer;};uint64_t length=0,capacity=15;
    explicit Name(const char *p){length=std::strlen(p);if(length<16)std::memcpy(small,p,length+1);else{pointer=p;capacity=length;}}
};
struct Ui {
    void *manager=nullptr;
    bool (*present)(void*,const Name&)=nullptr;void *(*window)(void*,const Name&)=nullptr;
    bool (*visible)(void*,bool)=nullptr;void (*hide)(void*)=nullptr;
    // DebugListBox_ListBox is a CEGUI Listbox (FalagardInfoList::AddInfo -> Listbox::addItem).
    int messages(wchar_t *out,int capacity){
        auto dll=GetModuleHandleW(L"CEGUIBase.dll");if(!dll||capacity<2)return -1;
        auto itemCount=game_lua::api<size_t (*)(void*)>(dll,"?getItemCount@Listbox@CEGUI@@QEBA_KXZ");
        auto itemAt=game_lua::api<void *(*)(void*,size_t)>(dll,"?getListboxItemFromIndex@Listbox@CEGUI@@QEBAPEAVListboxItem@2@_K@Z");
        auto itemText=game_lua::api<void *(*)(void*)>(dll,"?getText@ListboxItem@CEGUI@@QEBAAEBVString32@2@XZ");
        auto cstr=game_lua::api<const char *(*)(void*)>(dll,"?c_str@String32@CEGUI@@QEBAPEBDXZ");
        if(!itemCount||!itemAt||!itemText||!cstr)return -1;
        void *list=find("DebugListBox_ListBox");out[0]=0;if(!list)return 0;
        const size_t total=itemCount(list);int used=0,kept=0;
        for(size_t i=total>12?total-12:0;i<total;++i){
            void *item=itemAt(list,i);if(!item)continue;const char *utf8=cstr(itemText(item));if(!utf8)continue;
            wchar_t line[200]{};if(MultiByteToWideChar(CP_UTF8,0,utf8,-1,line,199)<=0)continue;
            const int n=int(std::wcslen(line));if(used+n+2>=capacity)break;
            std::wcscpy(out+used,line);used+=n;out[used++]=L'\n';out[used]=0;++kept;
        }
        return kept;
    }
    bool init(){
        auto dll=GetModuleHandleW(L"CEGUIBase.dll");if(!dll)return false;
        auto singleton=game_lua::api<void *(*)()>(dll,"?getSingletonPtr@WindowManager@CEGUI@@SAPEAV12@XZ");
        present=game_lua::api<decltype(present)>(dll,"?isWindowPresent@WindowManager@CEGUI@@QEBA_NAEBV?$StringBaseT@D@2@@Z");
        window=game_lua::api<decltype(window)>(dll,"?getWindow@WindowManager@CEGUI@@QEBAPEAVWindow@2@AEBV?$StringBaseT@D@2@@Z");
        visible=game_lua::api<decltype(visible)>(dll,"?isVisible@Window@CEGUI@@QEBA_N_N@Z");
        hide=game_lua::api<decltype(hide)>(dll,"?hide@Window@CEGUI@@QEAAXXZ");
        manager=singleton?singleton():nullptr;return manager&&present&&window&&visible&&hide;
    }
    void *find(const char *p){Name name(p);return present(manager,name)?window(manager,name):nullptr;}
    bool shown(const char *p,bool local=false){auto w=find(p);return w&&visible(w,local);}
    const char *monthly(gameplay::Packet &packet){
        const auto preferred=packet.frameKind;packet.frameKind=0;
        const char *prefixes[]={"Fuli_MonthlySign","MonthlySign","MonthlySignSP"};
        const char *chosen=nullptr;int matches=0;char name[96]{};
        for(unsigned i=0;i<3;++i){std::snprintf(name,96,"%s_Frame",prefixes[i]);if(shown(name)){chosen=prefixes[i];packet.frameKind=i+1;++matches;}}
        packet.frameVisible=matches==1;
        if(matches>1)return nullptr;
        if(!chosen){
            if(preferred>=1&&preferred<=3){std::snprintf(name,96,"%s_Frame",prefixes[preferred-1]);if(find(name)){chosen=prefixes[preferred-1];packet.frameKind=preferred;}}
            // Hidden parent: only local child flags from a previously loaded panel can remain.
            for(unsigned i=0;!chosen&&i<3;++i){std::snprintf(name,96,"%s_Frame",prefixes[i]);if(find(name)){chosen=prefixes[i];packet.frameKind=i+1;break;}}
        }
        if(!chosen)return nullptr;
        int today=0,found=0;
        for(int day=1;day<=31;++day){
            std::snprintf(name,96,"%s_Date_%d_Today",chosen,day);if(shown(name,true)){today=day;++found;}
            std::snprintf(name,96,"%s_Date_%d_Mark",chosen,day);if(shown(name,true))++packet.signedDays;
        }
        if(found!=1||packet.signedDays>31)return chosen;
        packet.today=today;std::snprintf(name,96,"%s_Date_%d_Mark",chosen,today);
        packet.signedToday=shown(name,true);packet.stateReady=1;return chosen;
    }
};
void execute(gameplay::Packet &p){
    p.executedThread=GetCurrentThreadId();
    auto reject=[&](DWORD error,const wchar_t *text){p.error=error;std::wcsncpy(p.detail,text,96);InterlockedExchange(&p.status,gameplay::Rejected);};
    FILETIME c{},e{},k{},u{};GetProcessTimes(GetCurrentProcess(),&c,&e,&k,&u);const auto now=GetTickCount64();
    if(p.targetThread!=GetCurrentThreadId()||p.created!=((uint64_t(c.dwHighDateTime)<<32)|c.dwLowDateTime)
        ||now>p.expires||p.expires-now>5000||p.frameKind>3||!gameplay::validCommand(p.command,p.argument)){reject(ERROR_INVALID_DATA,L"动作身份、参数或时限无效");return;}
    wchar_t path[32768]{};GetModuleFileNameW(nullptr,path,32768);const auto name=std::wcsrchr(path,L'\\');
    const auto base=uintptr_t(GetModuleHandleW(nullptr));live::Snapshot world;
    if(!name||_wcsicmp(name+1,L"Game.exe")||!live::signature(GetCurrentProcess(),base)||!live::snapshot(GetCurrentProcess(),base,world)){reject(ERROR_REVISION_MISMATCH,L"角色未进入游戏或版本未适配");return;}
    Ui ui;if(!ui.init()){reject(ERROR_MOD_NOT_FOUND,L"游戏界面接口未就绪");return;}
    for(const char *modal:{"Pswprotect_BackGround_Frame","Logon_FZKCheckFail_Frame","OnlyChangyoujia_Logon_Frame"})if(ui.shown(modal))p.manual=1;
    if(p.command==gameplay::RunSnippet){
        if(!gameplay::validSnippet(p.argument,p.args)){reject(ERROR_INVALID_PARAMETER,L"游戏片段参数无效");return;}
        if(p.argument==gameplay::DebugMessages){
            const int n=ui.messages(p.resultText,512);if(n<0){reject(ERROR_PROC_NOT_FOUND,L"界面列表接口不可用");return;}
            p.resultCount=1;p.results[0]=n;InterlockedExchange(&p.status,gameplay::Done);return;
        }
        if(p.manual&&gameplay::snippetIssuesAction(p.argument)){reject(ERROR_BUSY,L"请先完成游戏验证");return;}
        if(p.argument==gameplay::CombatScan||p.argument==gameplay::CombatCast){
            if(world.scene!=p.args.ints[0]){reject(ERROR_INVALID_STATE,L"场景已变化，战斗请求已停止");return;}
            const auto scanStarted=GetTickCount64();
            auto read=[&](uintptr_t at,void *to,size_t n){return GetTickCount64()-scanStarted<=12&&live::read(GetCurrentProcess(),at,to,n);};
            auto enemy=[&](uintptr_t player,uintptr_t npc){
                uintptr_t system=0,vt=0,fn=0;
                if(!live::get(GetCurrentProcess(),base+0x1054eb8,system)||!live::get(GetCurrentProcess(),system,vt)
                    ||vt<base+0xa00000||vt>base+0x1000000||!live::get(GetCurrentProcess(),vt+0x2c0,fn)||fn<base+0x1000||fn>=base+0xa00000)return -1;
                using Relation=int (*)(void*,void*,void*,int);
                return reinterpret_cast<Relation>(fn)(reinterpret_cast<void*>(system),reinterpret_cast<void*>(player),reinterpret_cast<void*>(npc),0)!=0?1:0;
            };
            combat::Scan scan;
            if(!combat::scan(read,enemy,base,p.args.ints[1],p.args.ints[2],p.args.reals[0],p.args.reals[1],p.args.reals[2],scan)){
                reject(ERROR_INVALID_DATA,L"怪物快照无效或场景对象超过 512，战斗已停止");return;
            }
            if(p.argument==gameplay::CombatScan){
                p.resultCount=8;const auto &t=scan.target;
                const double v[]={double(scan.status),double(t.client),double(t.server),t.hp,t.x,t.y,double(scan.enemies),scan.selfHp};
                for(int i=0;i<8;++i)p.results[i]=v[i];
                InterlockedExchange(&p.status,gameplay::Done);return;
            }
            if(scan.status!=1||scan.target.client!=p.args.ints[1]||scan.target.server!=p.args.ints[2]||scan.selfHp<=0){
                p.resultCount=1;p.results[0]=-4;InterlockedExchange(&p.status,gameplay::Done);return;
            }
        }
        if(p.argument==gameplay::SelfTarget){
            // The player's own identity is read here, in the game, not trusted from the caller.
            int client=-1,server=-1;
            if(!live::get(GetCurrentProcess(),world.player+0x28,client)||!live::get(GetCurrentProcess(),world.player+0x2c,server)||client<0||server<0){reject(ERROR_INVALID_DATA,L"角色身份不可读，停攻未确认");return;}
            p.args.ints[0]=client;p.args.ints[1]=server;
        }
        uintptr_t object=0;if(!live::get(GetCurrentProcess(),base+0x1056970,object)||object<0x10000){reject(ERROR_NOT_READY,L"游戏脚本登记对象尚未就绪");return;}
        game_lua::LuaResult result;bool mayHaveIssued=false;
        if(!game_lua::runGameSnippet(GetModuleHandleW(L"LuaPlus.dll"),reinterpret_cast<void*>(object),p.argument,p.args,result,mayHaveIssued,p.detail)){
            p.actionIssued=mayHaveIssued;p.error=ERROR_INVALID_FUNCTION;InterlockedExchange(&p.status,gameplay::Rejected);return;
        }
        p.actionIssued=gameplay::snippetIssuesAction(p.argument);p.resultCount=uint32_t(result.count);
        for(int i=0;i<8;++i)p.results[i]=result.numbers[i];
        if(result.text[0]&&!MultiByteToWideChar(936,0,result.text,-1,p.resultText,512))p.resultText[0]=0;
        InterlockedExchange(&p.status,gameplay::Done);return;
    }
    const char *prefix=ui.monthly(p);
    if(p.command!=gameplay::Query&&p.manual){reject(ERROR_BUSY,L"请先完成游戏验证");return;}
    if(p.command==gameplay::DailySign||p.command==gameplay::ClaimMonthlyReward){
        if(p.command==gameplay::ClaimMonthlyReward&&(!p.frameVisible||!p.stateReady||!p.signedToday)){reject(ERROR_NOT_READY,L"今日签到状态尚未确认，未提交奖励请求");return;}
        uintptr_t object=0;if(!live::get(GetCurrentProcess(),base+0x1056970,object)||object<0x10000){reject(ERROR_NOT_READY,L"游戏脚本登记对象尚未就绪");return;}
        bool mayHaveIssued=false;
        if(!game_lua::monthlySign(GetModuleHandleW(L"LuaPlus.dll"),reinterpret_cast<void*>(object),p.command==gameplay::DailySign?0:int(p.argument),mayHaveIssued,p.detail)){
            p.actionIssued=mayHaveIssued;p.error=ERROR_INVALID_FUNCTION;InterlockedExchange(&p.status,gameplay::Rejected);return;
        }
        p.actionIssued=1;
    }else if(p.command==gameplay::CloseMonthly){
        if(prefix&&p.frameVisible){char frame[96]{};std::snprintf(frame,96,"%s_Frame",prefix);ui.hide(ui.find(frame));p.actionIssued=1;}
    }
    InterlockedExchange(&p.status,gameplay::Done);
}
}
namespace tlbb::resident { void localSnippet(gameplay::Packet &p){execute(p);} }
extern "C" __declspec(dllexport) LRESULT CALLBACK TlbbGameplayHook(int code,WPARAM removed,LPARAM value){
    if(code==HC_ACTION&&removed==PM_REMOVE){auto m=reinterpret_cast<MSG*>(value);static const UINT id=RegisterWindowMessageW(tlbb::gameplay::messageName);
        if(m&&id&&m->message==id&&m->wParam==GetCurrentProcessId()){
            wchar_t name[128]{};tlbb::gameplay::mappingName(name,GetCurrentProcessId(),uint64_t(m->lParam));
            HANDLE mapping=OpenFileMappingW(FILE_MAP_READ|FILE_MAP_WRITE,FALSE,name);
            if(mapping){auto p=static_cast<tlbb::gameplay::Packet*>(MapViewOfFile(mapping,FILE_MAP_READ|FILE_MAP_WRITE,0,0,sizeof(tlbb::gameplay::Packet)));
                if(p){if(p->marker==tlbb::gameplay::magic&&p->version==2&&p->bytes==sizeof(*p)&&p->targetPid==GetCurrentProcessId()&&p->ownerPid!=p->targetPid&&p->nonce==uint64_t(m->lParam)&&InterlockedCompareExchange(&p->status,tlbb::gameplay::Executing,tlbb::gameplay::Pending)==tlbb::gameplay::Pending)execute(*p);UnmapViewOfFile(p);}CloseHandle(mapping);}
            m->message=WM_NULL;m->wParam=0;m->lParam=0;
        }}return CallNextHookEx(nullptr,code,removed,value);
}
#ifndef TLBB_ENGINE_COMBINED
BOOL WINAPI DllMain(HINSTANCE module,DWORD reason,LPVOID){if(reason==DLL_PROCESS_ATTACH)DisableThreadLibraryCalls(module);return TRUE;}
#endif
