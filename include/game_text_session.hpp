#pragma once
#include "game_lua_login.hpp"
#include "resident_vm.hpp"
#include <chrono>
#include <cmath>
#include <cstring>
#include <stdexcept>
namespace tlbb::resident {
inline std::string convert(const std::string &s,UINT from,UINT to){
    if(s.empty())return {};
    const int n=MultiByteToWideChar(from,MB_ERR_INVALID_CHARS,s.data(),int(s.size()),nullptr,0);if(n<=0)throw std::runtime_error("Invalid script text encoding");
    std::wstring w(size_t(n),0);MultiByteToWideChar(from,MB_ERR_INVALID_CHARS,s.data(),int(s.size()),w.data(),n);
    BOOL lossy=FALSE;const int size=WideCharToMultiByte(to,to==CP_UTF8?0:WC_NO_BEST_FIT_CHARS,w.data(),n,nullptr,0,nullptr,to==CP_UTF8?nullptr:&lossy);
    if(size<=0||lossy)throw std::runtime_error("Game text cannot be encoded");
    std::string result(size_t(size),0);WideCharToMultiByte(to,to==CP_UTF8?0:WC_NO_BEST_FIT_CHARS,w.data(),n,result.data(),size,nullptr,to==CP_UTF8?nullptr:&lossy);
    if(lossy)throw std::runtime_error("Game text conversion lost characters");
    return result;
}
// Text coming back from the game (tooltips, chat, NPC lines) can hold bytes that are not valid GBK;
// it is shown, never executed, so decode it tolerantly instead of failing the whole task.
inline std::string fromGame(const std::string &s){
    if(s.empty())return {};
    const int n=MultiByteToWideChar(936,0,s.data(),int(s.size()),nullptr,0);if(n<=0)return {};
    std::wstring w(size_t(n),0);MultiByteToWideChar(936,0,s.data(),int(s.size()),w.data(),n);
    const int size=WideCharToMultiByte(CP_UTF8,0,w.data(),n,nullptr,0,nullptr,nullptr);if(size<=0)return {};
    std::string result(size_t(size),0);WideCharToMultiByte(CP_UTF8,0,w.data(),n,result.data(),size,nullptr,nullptr);return result;
}
// One persistent official Lua 5.0 child state per resident task. The parent's stack is never used.
// No function-name whitelist: the installed, trusted task controls the game Lua text it executes.
class GameTextSession {
    using State=void *(*)(void*);using Destroy=void (*)(void*);using Index=void (*)(void*,int);
    using Push=void (*)(void*,const char*);using Type=int (*)(void*,int);using Hook=void (*)(void*,void*);
    using SetHook=int (*)(void*,Hook,int,int);
    HMODULE dll_=nullptr;void *owner_=nullptr,*child_=nullptr,*vm_=nullptr;Destroy destroy_=nullptr;
    Index set_=nullptr;Push push_=nullptr;SetHook hook_=nullptr;int (*error_)(void*)=nullptr;
    std::chrono::steady_clock::time_point deadline_;int instructions_=0;
    inline static thread_local GameTextSession *active_=nullptr;
    static void budget(void *l,void*){
        auto s=active_;if(!s)return;s->instructions_+=1000;
        if(s->instructions_>=50000||std::chrono::steady_clock::now()>=s->deadline_){s->push_(l,"Game Lua execution budget exceeded");s->error_(l);}
    }
    template<class T>T function(const char *n){auto p=game_lua::api<T>(dll_,n);if(!p)throw std::runtime_error("Missing game Lua SDK entry");return p;}
public:
    GameTextSession(HMODULE dll,void *registration):dll_(dll){
        auto owner=function<State>("?GetState@LuaObject@LuaPlus@@QEBAPEAVLuaState@2@XZ");
        auto create=function<State>("?CreateThread@LuaState@LuaPlus@@SAPEAV12@PEAV12@@Z");
        auto native=function<State>("?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
        destroy_=function<Destroy>("?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");
        set_=function<Index>("lua_settop");push_=function<Push>("lua_pushstring");hook_=function<SetHook>("lua_sethook");error_=function<int (*)(void*)>("lua_error");
        auto isTable=function<bool (*)(void*)>("?IsTable@LuaObject@LuaPlus@@QEBA_NXZ");if(!registration||!isTable(registration))throw std::runtime_error("Game Lua registration not ready");
        owner_=owner(registration);child_=create(owner_);if(!child_)throw std::runtime_error("Cannot create game Lua child");
        try {
            vm_=native(child_);if(!vm_||!function<int (*)(void*,int)>("lua_checkstack")(vm_,48))throw std::runtime_error("Game Lua child stack unavailable");
            set_(vm_,0);
            const char setup[]="local globals=_G local base=globals.setmetatable local env={} env._G=env "
                "env.setmetatable=function(t,m) if t==env and type(m)=='table' then local inherited=m.__index "
                "m.__index=function(tab,key) local v=nil if type(inherited)=='table' then v=inherited[key] "
                "elseif type(inherited)=='function' then v=inherited(tab,key) end if v~=nil then return v end return globals[key] end end return base(t,m) end "
                "return base(env,{__index=globals})";
            if(function<int (*)(void*,const char*,size_t,const char*)>("luaL_loadbuffer")(vm_,setup,sizeof(setup)-1,"=task.env")!=0
                ||function<int (*)(void*,int,int,int)>("lua_pcall")(vm_,0,1,0)!=0)throw std::runtime_error("Cannot create private game Lua environment");
        }catch(...){destroy_(child_);child_=nullptr;throw;}
    }
    ~GameTextSession(){if(child_)destroy_(child_);}
    bool sameOwner(void *registration){return registration&&function<bool (*)(void*)>("?IsTable@LuaObject@LuaPlus@@QEBA_NXZ")(registration)&&function<State>("?GetState@LuaObject@LuaPlus@@QEBAPEAVLuaState@2@XZ")(registration)==owner_;}
    // If the game has already destroyed/replaced its owner state, its former
    // child must not be passed back into the SDK destructor.
    void abandon(){child_=vm_=nullptr;}
    GameTextSession(const GameTextSession&)=delete;GameTextSession &operator=(const GameTextSession&)=delete;
    Values evaluate(const std::string &utf8,const std::string &format,int count){
        if(count<0||count>32||utf8.size()>128*1024||(!format.empty()&&int(format.size())!=count))throw std::runtime_error("Game Lua source/result bounds exceeded");
        for(char c:format)if(c!='n'&&c!='l'&&c!='s'&&c!='b')throw std::runtime_error("GetLuaValue formats are n/l/s/b");
        const auto source=[&]{try{return convert(utf8,CP_UTF8,936);}catch(const std::exception &x){throw std::runtime_error(std::string("Game Lua source is not valid UTF-8 / GBK text: ")+x.what());}}();set_(vm_,1);
        struct Reset{void *vm;Index set;~Reset(){set(vm,1);}}reset{vm_,set_};
        auto type=function<Type>("lua_type");auto text=function<const char *(*)(void*,int)>("lua_tostring");
        auto load=function<int (*)(void*,const char*,size_t,const char*)>("luaL_loadbuffer");
        auto fail=[&]{const auto why=type(vm_,-1)==4?text(vm_,-1):nullptr;throw std::runtime_error(why?fromGame(why):"Game Lua execution failed");};
        if(load(vm_,source.data(),source.size(),"=task.game")!=0)fail();
        function<Index>("lua_pushvalue")(vm_,1);function<int (*)(void*,int)>("lua_setfenv")(vm_,2);
        instructions_=0;deadline_=std::chrono::steady_clock::now()+std::chrono::milliseconds(2);active_=this;hook_(vm_,budget,8,1000);
        const int code=function<int (*)(void*,int,int,int)>("lua_pcall")(vm_,0,count,0);
        hook_(vm_,nullptr,0,0);active_=nullptr;if(code!=0)fail();
        Values out;size_t total=0;
        for(int i=0;i<count;++i){
            const int at=2+i,t=type(vm_,at);const char requested=format.empty()?0:format[size_t(i)];
            if(requested=='s'||(!requested&&t==4)){
                const auto p=text(vm_,at);if(!p)throw std::runtime_error("Game Lua result is not text");
                const auto n=function<size_t (*)(void*,int)>("lua_strlen")(vm_,at);total+=n;if(total>64*1024)throw std::runtime_error("Game Lua results exceed 64 KiB");
                out.emplace_back(fromGame(std::string(p,n)));
            }else if(requested=='n'||requested=='l'||(!requested&&t==3)){
                if(t!=3)throw std::runtime_error("Game Lua result is not numeric");
                const auto n=function<double (*)(void*,int)>("lua_tonumber")(vm_,at);
                if(!std::isfinite(n))throw std::runtime_error("Game Lua result is not finite");
                out.emplace_back(n);
            }else if(requested=='b'){
                // Game APIs often use 0/1. Lua considers numeric zero truthy;
                // preserving that rule here would turn "not ready" into true.
                if(t==1)out.emplace_back(function<int (*)(void*,int)>("lua_toboolean")(vm_,at)!=0);
                else if(t==3){const auto n=function<double (*)(void*,int)>("lua_tonumber")(vm_,at);
                    if(!std::isfinite(n))throw std::runtime_error("Game Lua boolean is not finite");
                    out.emplace_back(n!=0);
                }else throw std::runtime_error("Game Lua result is not boolean or numeric");
            }else if(!requested&&t==1)out.emplace_back(function<int (*)(void*,int)>("lua_toboolean")(vm_,at)!=0);
            else if(t==0)out.emplace_back();else throw std::runtime_error("Game Lua result type is not scalar");
        }return out;
    }
};
}
