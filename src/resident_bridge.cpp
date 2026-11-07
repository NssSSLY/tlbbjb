#include "resident_protocol.hpp"
#include "resident_clock.hpp"
#include "resident_native.hpp"
#include "resident_vm.hpp"
#include "game_text_session.hpp"
#include "combat_world.hpp"
#include "object_buffs.hpp"
#include "mechanism_world.hpp"
#include "live_layout.hpp"
#include <algorithm>
#include <charconv>
#include <cstdio>
#include <stdexcept>
namespace tlbb::resident {
namespace {
uint64_t processCreated(){FILETIME c{},e{},k{},u{};GetProcessTimes(GetCurrentProcess(),&c,&e,&k,&u);return (uint64_t(c.dwHighDateTime)<<32)|c.dwLowDateTime;}
struct Adapter:Host {
    uintptr_t base=uintptr_t(GetModuleHandleW(nullptr));HWND window=nullptr;uint32_t flags=0;bool combatTask=false;
    uint32_t kills=0;bool boss=false;uint64_t rawCalls=0;std::string latest,battle,taskResult;
    std::unique_ptr<GameTextSession> gameText;
    live::Snapshot world(){live::Snapshot s;if(!live::signature(GetCurrentProcess(),base)||!live::snapshot(GetCurrentProcess(),base,s))throw std::runtime_error("Character world state is unavailable");return s;}
    explicit Adapter(HWND hwnd,uint32_t allow,bool combat):window(hwnd),flags(allow),combatTask(combat){
        world();uintptr_t registration=0;if(!live::get(GetCurrentProcess(),base+0x1056970,registration))throw std::runtime_error("Game Lua registration is unavailable");
        gameText=std::make_unique<GameTextSession>(GetModuleHandleW(L"LuaPlus.dll"),reinterpret_cast<void*>(registration));
    }
    bool sameGameLua(){uintptr_t registration=0;return live::get(GetCurrentProcess(),base+0x1056970,registration)&&gameText->sameOwner(reinterpret_cast<void*>(registration));}
    void ensure(){world();if(!sameGameLua()){gameText->abandon();throw std::runtime_error("Game Lua state changed; start a new task after login");}}
    ~Adapter(){if(gameText)try{if(!sameGameLua())gameText->abandon();}catch(...){gameText->abandon();}}
    Values evaluate(const std::string &source,const std::string &format,int count)override{ensure();++rawCalls;return gameText->evaluate(source,format,count);}
    Values snippet(uint32_t id,const gameplay::SnippetArgs &args)override{
        const auto risk=gameplay::snippetRisk(id,args);
        if((risk&gameplay::RiskSpend)&&!(flags&1))throw std::runtime_error("Compatibility API: allow_spend is off");
        if((risk&gameplay::RiskTransfer)&&!(flags&2))throw std::runtime_error("Compatibility API: allow_transfer is off");
        if((risk&gameplay::RiskOffline)&&!(flags&4))throw std::runtime_error("Compatibility API: allow_offline is off");
        if((risk&gameplay::RiskSell)&&!(flags&16))throw std::runtime_error("Compatibility API: allow_sell is off");
        if((risk&gameplay::RiskItem)&&!(flags&32))throw std::runtime_error("Compatibility API: allow_item is off");
        if(id>=gameplay::CombatScan&&id<=gameplay::CombatName&&!combatTask)throw std::runtime_error("This task did not declare combat settings");
        gameplay::Packet p;p.command=gameplay::RunSnippet;p.argument=id;p.args=args;p.created=processCreated();p.targetThread=GetCurrentThreadId();p.expires=GetTickCount64()+2500;
        localSnippet(p);
        if(p.status!=gameplay::Done){
            if(p.manual)throw std::runtime_error("Complete the game's verification, then start the task again");
            const int n=WideCharToMultiByte(CP_UTF8,0,p.detail,-1,nullptr,0,nullptr,nullptr);std::string message(n>0?size_t(n):1,0);
            if(n>0)WideCharToMultiByte(CP_UTF8,0,p.detail,-1,message.data(),n,nullptr,nullptr);
            throw std::runtime_error(n>0?message.c_str():"Game call failed; it will not be replayed");
        }
        Values out;for(uint32_t i=0;i<p.resultCount&&i<8;++i)out.emplace_back(p.results[i]);
        if(p.resultText[0]){const int n=WideCharToMultiByte(CP_UTF8,0,p.resultText,-1,nullptr,0,nullptr,nullptr);std::string text(size_t(n),0);WideCharToMultiByte(CP_UTF8,0,p.resultText,-1,text.data(),n,nullptr,nullptr);text.pop_back();out.emplace_back(std::move(text));}
        return out;
    }
    Values call(const std::string &op,const std::string &value)override{
        if(op=="task_result"){
            if(value.size()>1024||value.find('\n')!=std::string::npos)throw std::runtime_error("Task result bounds exceeded");
            taskResult=value;return {};
        }
        if(op=="battle_snapshot"){
            if(value.size()>=64*1024)throw std::runtime_error("Battle snapshot exceeds 64 KiB");
            battle=value;return {};
        }
        if(op=="battle_self_identity"){
            const auto s=world();int client=-1,server=-1;
            if(!live::get(GetCurrentProcess(),s.player+0x28,client)||!live::get(GetCurrentProcess(),s.player+0x2c,server)||client<0||server<0)
                throw std::runtime_error("Player identity unavailable");
            return {Value(client),Value(server)};
        }
        if(op=="object_buff_ids"){
            const auto s=world();int client=-2,server=-2;const auto sep=value.find(':');
            if(value.size()>32||sep==std::string::npos)throw std::runtime_error("Buff identity format is invalid");
            const auto a=std::from_chars(value.data(),value.data()+sep,client),b=std::from_chars(value.data()+sep+1,value.data()+value.size(),server);
            if(a.ec!=std::errc()||a.ptr!=value.data()+sep||b.ec!=std::errc()||b.ptr!=value.data()+value.size())throw std::runtime_error("Buff identity format is invalid");
            const auto started=GetTickCount64();auto read=[&](uintptr_t at,void *to,size_t n){return GetTickCount64()-started<=8&&live::read(GetCurrentProcess(),at,to,n);};
            const auto object=combat::buffObject(read,base,s.player,client,server);std::vector<int> ids;
            if(!object||!combat::buffIds(read,object,ids)||combat::buffObject(read,base,s.player,client,server)!=object)
                throw std::runtime_error("Buff tree/identity unavailable or changed");
            std::string result;for(auto id:ids){if(!result.empty())result+=",";result+=std::to_string(id);}
            return {Value(int(ids.size())),Value(std::move(result))};
        }
        if(op=="mechanism_snapshot"||op=="loot_snapshot"){
            const auto s=world();const auto began=GetTickCount64();
            auto read=[&](uintptr_t at,void *to,size_t n){return GetTickCount64()-began<=8&&live::read(GetCurrentProcess(),at,to,n);};
            std::vector<combat::Mechanism> rows;
            if(!combat::mechanismSnapshot(read,base,s.player,rows,op=="loot_snapshot"))throw std::runtime_error("Mechanism/loot object layout/list changed");
            std::string text;char line[160];
            for(const auto &o:rows){std::snprintf(line,sizeof(line),"%d\t%d\t%d\t%.9g\t%.9g\n",o.kind,o.client,o.server,double(o.x),double(o.y));text+=line;}
            return {Value(s.scene),Value(int(rows.size())),Value(std::move(text))};
        }
        if(op=="enemy_players"){
            // Other players the game itself rates as enemies: the same relation function objects() uses for NPCs.
            const auto s=world();const auto began=GetTickCount64();
            auto read=[&](uintptr_t at,void *to,size_t n){return GetTickCount64()-began<=8&&live::read(GetCurrentProcess(),at,to,n);};
            auto get=[&](uintptr_t at,auto &v){return read(at,&v,sizeof(v));};
            std::vector<combat::Mechanism> rows;
            if(!combat::mechanismSnapshot(read,base,s.player,rows))throw std::runtime_error("Player object layout/list changed");
            uintptr_t relation=0,table=0,fn=0;
            if(!get(base+0x1054eb8,relation)||!get(relation,table)||!get(table+0x2c0,fn)||fn<base+0x1000||fn>=base+0xa00000)throw std::runtime_error("Enemy relation interface mismatch");
            using Enemy=int (*)(void*,void*,void*,int);
            std::string text;char line[160];int count=0;
            for(const auto &o:rows){
                if(o.kind!=1)continue;
                if(!reinterpret_cast<Enemy>(fn)(reinterpret_cast<void*>(relation),reinterpret_cast<void*>(s.player),reinterpret_cast<void*>(o.object),0))continue;
                // Health as a percentage when its layout reads back sane; -1 means unknown, never dead.
                uintptr_t data=0,values=0;float hp=-1;
                if(!get(o.object+0x228,data)||!get(data+8,values)||!get(values+8,hp)||!std::isfinite(hp)||hp<0||hp>100)hp=-1;
                std::snprintf(line,sizeof(line),"%d\t%d\t%.9g\t%.9g\t%.9g\n",o.client,o.server,double(o.x),double(o.y),double(hp));text+=line;++count;
            }
            return {Value(s.scene),Value(count),Value(std::move(text))};
        }
        if(op=="open_loot"||op=="open_object"){ // open_object: gathering objects, which take the same click as a loot pack
            const auto s=world();int client=-2,server=-2;const auto sep=value.find(':');
            if(value.size()>32||sep==std::string::npos)throw std::runtime_error("Loot identity format is invalid");
            const auto a=std::from_chars(value.data(),value.data()+sep,client),b=std::from_chars(value.data()+sep+1,value.data()+value.size(),server);
            if(a.ec!=std::errc()||a.ptr!=value.data()+sep||b.ec!=std::errc()||b.ptr!=value.data()+value.size())throw std::runtime_error("Loot identity format is invalid");
            const auto began=GetTickCount64();auto read=[&](uintptr_t at,void *to,size_t n){return GetTickCount64()-began<=8&&live::read(GetCurrentProcess(),at,to,n);};
            if(!combat::lootOpenReady(read,base,s.player,s.input,client,server,op=="open_object"))throw std::runtime_error("Loot identity, distance or input interface changed");
            const auto current=world();
            if(current.scene!=s.scene||current.player!=s.player||current.input!=s.input)throw std::runtime_error("Scene changed before opening loot");
            using Open=void (*)(void*,int,bool);
            reinterpret_cast<Open>(base+combat::openLootFunction)(reinterpret_cast<void*>(s.input),client,true);
            return {Value(1)}; // Submission; the task must observe the new LootPacket window.
        }
        if(op=="position"){
            live::Snapshot s;if(!live::snapshot(GetCurrentProcess(),base,s))return {Value(false)};
            const int n=WideCharToMultiByte(CP_UTF8,0,s.map,-1,nullptr,0,nullptr,nullptr);std::string name(size_t(n),0);WideCharToMultiByte(CP_UTF8,0,s.map,-1,name.data(),n,nullptr,nullptr);name.pop_back();
            return {Value(true),Value(s.scene),Value(s.x),Value(s.y),Value(std::move(name))};
        }
        if(op=="stop_motion"){
            const auto s=world();const float point[]={s.x,s.y};using Move=void (*)(void*,const float*);
            reinterpret_cast<Move>(base+live::moveFunction)(reinterpret_cast<void*>(s.input),point);return {};
        }
        if(op=="stop_attack"){
            // Auto-attack and chasing follow the selected target: select ourselves (identity-checked), then stop moving.
            // Two independent cleanup steps: a failed attack stop must not skip the motion stop; both failures are reported.
            std::string failure;
            try{
                const auto s=world();int client=-1,server=-1;
                if(!live::get(GetCurrentProcess(),s.player+0x28,client)||!live::get(GetCurrentProcess(),s.player+0x2c,server)||client<0||server<0)
                    throw std::runtime_error("Player identity unavailable; attack stop not confirmed");
                const auto selected=gameText->evaluate("-- engine:stop-attack\nDataPool:SelectAsTargetByObjID("+std::to_string(server)+")\nreturn Target:GetData('NPCID')","n",1);
                if(selected.empty()||selected[0].kind!=Value::Number||int(selected[0].number)!=client)throw std::runtime_error("Self target not confirmed; attack stop not confirmed");
            }catch(const std::exception &e){failure=e.what();}
            try{call("stop_motion","");}catch(const std::exception &e){failure+=(failure.empty()?"":"; ")+std::string("motion stop failed: ")+e.what();}
            if(!failure.empty())throw std::runtime_error(failure);
            return {};
        }
        if(op=="combat_result"){if(value=="kill")++kills;else if(value=="boss")boss=true;else throw std::runtime_error("Unknown combat result");return {};}
        if(op=="alert"){if(value=="flash"){FLASHWINFO f{sizeof(f),window,FLASHW_ALL|FLASHW_TIMERNOFG,5,0};FlashWindowEx(&f);}else MessageBeep(MB_ICONEXCLAMATION);return {};}
        throw std::runtime_error("Unknown resident host operation");
    }
    std::vector<Object> objects()override{
        const auto s=world();const auto began=GetTickCount64();auto get=[&](uintptr_t at,auto &v){return GetTickCount64()-began<=12&&live::get(GetCurrentProcess(),at,v);};
        uintptr_t manager=0,vt=0,head=0,root=0;uint64_t count=0;
        if(!get(base+combat::managerGlobal,manager)||!get(manager,vt)||vt!=base+combat::managerVtable||!get(manager+0xe0,head)||!get(manager+0xe8,count)||count>512||!get(head+8,root))throw std::runtime_error("Object list bounds/layout mismatch");
        uintptr_t pending[64]{};int top=0,seen=0;if(root!=head)pending[top++]=root;std::vector<Object> out;
        while(top){const auto at=pending[--top];if(++seen>int(count))throw std::runtime_error("Invalid object tree");
            struct Node{uintptr_t left,parent,right;uint8_t color,nil,pad[6];int key,pad2;uintptr_t object;}n{};
            if(!get(at,n)||n.nil)throw std::runtime_error("Unreadable object tree");
            for(auto child:{n.left,n.right})if(child!=head){if(!child||top>=64)throw std::runtime_error("Object traversal limit exceeded");pending[top++]=child;}
            if(!get(n.object,vt))throw std::runtime_error("Object expired");
            if(vt!=base+combat::npcVtable)continue;
            Object o;o.id=n.key;float pos[3]{},hp=0;uintptr_t data=0,values=0;uint8_t removed=0;int client=-1;
            if(!get(n.object+0x28,client)||client!=o.id||!get(n.object+0x2c,o.server)||!get(n.object+0x48,removed)||!get(n.object+0x228,data)||!get(data+8,values)||!get(values+8,hp)
                ||!live::read(GetCurrentProcess(),n.object+0x4c,pos,sizeof(pos)))throw std::runtime_error("Object snapshot expired");
            if(removed)continue;
            o.x=pos[0];o.y=pos[2];o.hp=hp;
            if(!std::isfinite(o.x)||!std::isfinite(o.y)||!std::isfinite(o.hp)||o.id<0||o.server<0||o.hp<0||o.hp>100)throw std::runtime_error("Invalid object position/health");
            o.distance=std::hypot(o.x-s.x,o.y-s.y);
            uintptr_t relation=0,table=0,fn=0;
            if(!get(base+0x1054eb8,relation)||!get(relation,table)||!get(table+0x2c0,fn)||fn<base+0x1000||fn>=base+0xa00000)throw std::runtime_error("Enemy relation interface mismatch");
            using Enemy=int (*)(void*,void*,void*,int);
            o.hostile=o.hp>0&&reinterpret_cast<Enemy>(fn)(reinterpret_cast<void*>(relation),reinterpret_cast<void*>(s.player),reinterpret_cast<void*>(n.object),0)!=0;out.push_back(o);
        }
        uintptr_t headAgain=0,playerAgain=0;uint64_t countAgain=0;
        if(seen!=int(count)||!get(manager+0xe0,headAgain)||headAgain!=head||!get(manager+0xe8,countAgain)||countAgain!=count||!get(manager+0x108,playerAgain)||playerAgain!=s.player)throw std::runtime_error("Object list changed");
        for(size_t start=0;start<out.size();start+=32){const size_t end=std::min(out.size(),start+32);std::string code="return ";
            for(size_t i=start;i<end;++i){if(i>start)code+=",";code+="(Target:GetNpcName("+std::to_string(out[i].id)+") or '')";}
            const auto names=gameText->evaluate(code,std::string(end-start,'s'),int(end-start));for(size_t i=start;i<end;++i)out[i].name=names[i-start].text;
        }
        return out;
    }
    void log(const std::string &value)override{if(latest.size()+value.size()+1>3500)latest.clear();latest+=value.substr(0,600)+"\n";}
};
struct Manager {
    std::unique_ptr<Adapter> adapter;std::unique_ptr<Vm> vm;HANDLE owner=nullptr;HWND window=nullptr;UINT_PTR timer=0;
    DWORD ownerPid=0;uint64_t session=0,ticks=0;uint32_t requests=0;Clock clock;
    std::string failure,lastLog,lastBattle,lastTaskResult;Vm::State finalState=Vm::Idle;uint64_t callCount=0,rawCount=0;uint32_t kills=0;bool boss=false,paused=false,stepping=false;Command deferred=Poll;
    void finish(Vm::State state,const std::string &why={}){
        failure=why;finalState=state;if(timer){KillTimer(window,timer);timer=0;}
        if(vm){callCount=vm->calls();if(adapter){rawCount=adapter->rawCalls;kills=adapter->kills;boss=adapter->boss;lastLog=adapter->latest;lastBattle=adapter->battle;lastTaskResult=adapter->taskResult;if(ticks&&callCount&&!(adapter->flags&8))try{adapter->call("stop_attack","");}catch(const std::exception &e){if(failure.empty())failure=std::string("Stop attack/motion was not confirmed; take control manually: ")+e.what();if(state==Vm::Completed)finalState=Vm::Failed;}}
            vm->stop();vm.reset();}
        adapter.reset();
        if(owner){CloseHandle(owner);owner=nullptr;}
    }
    void step(){
        if(!vm||stepping)return;
        switch(clock.step(GetTickCount64(),owner&&WaitForSingleObject(owner,0)==WAIT_TIMEOUT,paused)){ // resident_clock.hpp
        case Clock::Disconnected:finish(Vm::Failed,"Controller disconnected; resident task stopped");return;
        case Clock::Paused:return;
        case Clock::TimedOut:finish(Vm::Failed,"Resident task timeout");return;
        case Clock::Run:break;
        }
        adapter->ensure();++ticks;stepping=true;vm->step(clock.active);stepping=false;
        if(vm->state()==Vm::Completed)finish(Vm::Completed);else if(vm->state()==Vm::Failed){const auto why=vm->error();finish(Vm::Failed,why);}
        const auto next=deferred;deferred=Poll;control(next);
    }
    void control(Command cmd){
        if(stepping){if(deferred!=Stop)deferred=cmd;return;}
        if(cmd==Stop){finish(Vm::Stopped);return;}
        if(cmd==Pause&&vm){try{if(!(adapter->flags&8))adapter->call("stop_attack","");paused=true;vm->pause(true);}catch(const std::exception &e){finish(Vm::Failed,e.what());}}
        if(cmd==Resume&&vm){clock.resume(GetTickCount64());paused=false;vm->pause(false);}
    }
    void snapshot(Packet &p){p.state=vm?uint32_t(paused?Vm::Paused:vm->state()):uint32_t(finalState);p.luaBytes=vm?vm->allocated():0;p.nativeCalls=vm?vm->calls():callCount;p.rawCalls=adapter?adapter->rawCalls:rawCount;
        p.ticks=ticks;p.kills=adapter?adapter->kills:kills;p.boss=adapter?adapter->boss:boss;p.ipcRequests=requests;
        std::snprintf(p.battle,sizeof(p.battle),"%s",(adapter?adapter->battle:lastBattle).c_str());
        std::snprintf(p.error,sizeof(p.error),"%s",failure.c_str());auto &log=adapter?adapter->latest:lastLog;const auto &result=adapter?adapter->taskResult:lastTaskResult;const auto output=(result.empty()?std::string():"@TLBB_TASK_RESULT "+result+"\n")+log;std::snprintf(p.log,sizeof(p.log),"%s",output.c_str());log.clear();}
};
Manager *manager=nullptr; // Lifetime belongs to Game.exe; no SDK calls from DllMain/process detach.
void CALLBACK timer(HWND,UINT,UINT_PTR,DWORD){
    if(!manager)return;
    try{manager->step();}catch(const std::exception &e){manager->stepping=false;manager->finish(Vm::Failed,e.what());}
}
void execute(Packet &p,HWND window){
    p.executedThread=GetCurrentThreadId();auto reject=[&](const char *why){std::snprintf(p.error,sizeof(p.error),"%s",why);InterlockedExchange(&p.status,3);};
    const auto now=GetTickCount64();if(p.created!=processCreated()||p.targetThread!=GetCurrentThreadId()||now>p.expires||p.expires-now>5000||p.command<Start||p.command>Stop){reject("Resident request identity/expiry mismatch");return;}
    wchar_t name[32768]{};GetModuleFileNameW(nullptr,name,32768);const auto file=std::wcsrchr(name,L'\\');
    if(!file||_wcsicmp(file+1,L"Game.exe")){reject("Resident engine requires Game.exe");return;}
    if(!manager){
        HMODULE pinned=nullptr;
        if(!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS|GET_MODULE_HANDLE_EX_FLAG_PIN,reinterpret_cast<LPCWSTR>(&timer),&pinned)){reject("Cannot retain resident engine lifetime");return;}
        manager=new Manager;
    }
    auto &m=*manager;
    if(p.command==Start){
        if(m.vm){reject("This game already has an active task");return;}
        if(!p.sourceBytes||p.sourceBytes>=payloadCapacity||p.timeoutSeconds<10||p.timeoutSeconds>7200){reject("Resident source/timeout bounds exceeded");return;}
        m.adapter.reset();m.failure.clear();m.lastBattle.clear();m.lastTaskResult.clear();m.lastLog.clear();m.callCount=m.rawCount=m.ticks=0;m.kills=0;m.boss=m.paused=false;m.deferred=Poll;m.ownerPid=p.ownerPid;m.session=p.session;m.window=window;
        try {
            m.owner=OpenProcess(SYNCHRONIZE,FALSE,p.ownerPid);if(!m.owner)throw std::runtime_error("Cannot watch controller lifetime");
            m.adapter=std::make_unique<Adapter>(window,p.allowFlags,p.combat!=0);m.vm=std::make_unique<Vm>(*m.adapter);
            std::string error;if(!m.vm->start(std::string(p.source,p.sourceBytes),error))throw std::runtime_error(error);
            m.clock.start(now,p.timeoutSeconds);m.requests=0;m.finalState=Vm::Running;
            m.timer=SetTimer(window,0x544c420b,20,timer);if(!m.timer)throw std::runtime_error("Cannot schedule resident Lua on game UI thread");
        }catch(const std::exception &e){m.finish(Vm::Failed,e.what());reject(e.what());return;}
    }else if(m.ownerPid!=p.ownerPid||m.session!=p.session){reject("Resident session does not belong to this controller");return;}
    ++m.requests;m.clock.renew(now);
    if(p.command!=Start&&p.command!=Poll)m.control(Command(p.command));
    m.snapshot(p);InterlockedExchange(&p.status,2);
}
}
}
extern "C" __declspec(dllexport) LRESULT CALLBACK TlbbResidentHook(int code,WPARAM removed,LPARAM value){
    using namespace tlbb::resident;
    if(code==HC_ACTION&&removed==PM_REMOVE){auto msg=reinterpret_cast<MSG*>(value);static const UINT id=RegisterWindowMessageW(messageName);
        if(msg&&id&&msg->message==id&&msg->wParam==GetCurrentProcessId()){
            wchar_t name[128]{};mappingName(name,GetCurrentProcessId(),uint64_t(msg->lParam));auto h=OpenFileMappingW(FILE_MAP_READ|FILE_MAP_WRITE,FALSE,name);
            if(h){auto p=static_cast<Packet*>(MapViewOfFile(h,FILE_MAP_READ|FILE_MAP_WRITE,0,0,sizeof(Packet)));
                if(p){if(p->marker==magic&&p->bytes==sizeof(Packet)&&p->version==3&&p->targetPid==GetCurrentProcessId()&&p->ownerPid!=p->targetPid&&p->nonce==uint64_t(msg->lParam)&&InterlockedCompareExchange(&p->status,1,0)==0)execute(*p,msg->hwnd);UnmapViewOfFile(p);}CloseHandle(h);}
            msg->message=WM_NULL;msg->wParam=msg->lParam=0;
        }
    }return CallNextHookEx(nullptr,code,removed,value);
}
