#include "resident_vm.hpp"
#include <chrono>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <ctime>
#include <stdexcept>
#include <windows.h>
extern "C" {
#include <lauxlib.h>
#include <lualib.h>
}
namespace tlbb::resident {
struct Vm::Impl {
    Host &host;lua_State *main=nullptr,*co=nullptr;State state=Idle;
    size_t bytes=0;uint64_t now=0,wake=0,last=0,nativeCalls=0,instructions=0;int thisCalls=0,quantum=0;
    bool hasTime=false,closing=false,offlineDiagnostics=false;std::string failure;std::chrono::steady_clock::time_point deadline;
    // Lua errors/OOM use longjmp. Keep heap-owning result buffers on the VM, never
    // in C callback frames that Lua may unwind without running C++ destructors.
    Values values;std::vector<Object> objectResults;std::string code,format;
    explicit Impl(Host &h,bool diagnostics):host(h),offlineDiagnostics(diagnostics){}~Impl(){close();}
    void close(){
        if(main){closing=true;deadline=std::chrono::steady_clock::now()+std::chrono::milliseconds(2);quantum=0;lua_sethook(main,hook,LUA_MASKCOUNT,1000);lua_close(main);closing=false;}
        main=co=nullptr;values.clear();objectResults.clear();code.clear();format.clear();
    }
    static Impl &self(lua_State *l){return **static_cast<Impl**>(lua_getextraspace(l));}
    static void *allocate(void *ctx,void *old,size_t previous,size_t size){
        auto &s=*static_cast<Impl*>(ctx);if(!old)previous=0;
        if(!size){std::free(old);s.bytes-=previous>s.bytes?s.bytes:previous;return nullptr;}
        if(size>previous&&size-previous>16*1024*1024-s.bytes)return nullptr;
        void *p=std::realloc(old,size);if(p)s.bytes=s.bytes-previous+size;return p;
    }
    static void hook(lua_State *l,lua_Debug*){
        auto &s=self(l);s.instructions+=1000;s.quantum+=1000;
        if(s.instructions>10000000)luaL_error(l,"Lua exceeded 10M instructions without Sleep");
        if(s.quantum>=25000||std::chrono::steady_clock::now()>=s.deadline){
            if(lua_isyieldable(l))lua_yield(l,0);else luaL_error(l,"Lua execution slice exceeded");
        }
    }
    static int resumeApi(lua_State *l,int,lua_KContext op){return invoke(l,int(op),false);}
    static int api(lua_State *l){return invoke(l,int(lua_tointeger(l,lua_upvalueindex(1))),true);}
    static int invoke(lua_State *l,int op,bool yieldable){
        auto &s=self(l);
        if(s.closing)return luaL_error(l,"Task is closing; native calls are disabled");
        if(yieldable&&(s.thisCalls>=8||std::chrono::steady_clock::now()>=s.deadline))return lua_yieldk(l,0,op,resumeApi);
        luaL_checkstack(l,64,"Resident return stack");
        ++s.thisCalls;++s.nativeCalls;
        try {
            auto &values=s.values;values.clear();
            if(op==1){
                s.code=luaL_checkstring(l,1);s.format=luaL_optstring(l,2,"");const int count=int(luaL_optinteger(l,3,lua_Integer(s.format.size())));
                if(s.code.size()>128*1024||count<0||count>32||(!s.format.empty()&&int(s.format.size())!=count))throw std::runtime_error("GetLuaValue source/result bounds exceeded");
                if(s.format.find_first_not_of("nlsb")!=std::string::npos)throw std::runtime_error("GetLuaValue formats are n/l/s/b");
                values=s.host.evaluate(s.code,s.format,count);
            }else if(op==2){
                const auto id=luaL_checkinteger(l,1);gameplay::SnippetArgs args;
                for(int t=2;t<=3;++t)if(!lua_isnoneornil(l,t)){
                    luaL_checktype(l,t,LUA_TTABLE);
                    for(int k=1;k<=(t==2?4:3);++k){lua_rawgeti(l,t,k);if(!lua_isnil(l,-1)){
                        const auto n=luaL_checknumber(l,-1);if(!std::isfinite(n)||(t==2&&(n!=std::floor(n)||std::abs(n)>10000000)))throw std::runtime_error("Invalid native argument");
                        if(t==2)args.ints[k-1]=int32_t(n);else args.reals[k-1]=n;
                    }lua_pop(l,1);}
                }
                if(!lua_isnoneornil(l,4)){
                    size_t n=0;const char *text=luaL_checklstring(l,4,&n);
                    const int size=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,text,int(n),args.text,48);
                    if(size<1||size>47)throw std::runtime_error("Native text exceeds 47 characters");
                    args.text[size]=0;
                }
                if(id<1||id>gameplay::SnippetLast||!gameplay::validSnippet(uint32_t(id),args))throw std::runtime_error("Native arguments rejected");
                values=s.host.snippet(uint32_t(id),args);
            }else if(op==3){values=s.host.call(luaL_checkstring(l,1),luaL_optstring(l,2,""));
            }else if(op==4){s.host.log(luaL_tolstring(l,1,nullptr));lua_settop(l,0);return 0;
            }else if(op==5){
                SYSTEMTIME time{};GetLocalTime(&time);const uint64_t unixTime=uint64_t(std::time(nullptr));
                values={Value(double(unixTime)),Value(int(time.wHour)),Value(int(time.wMinute)),Value(int(time.wSecond))};
            }else if(op==6){
                s.objectResults=s.host.objects();lua_settop(l,0);lua_createtable(l,int(s.objectResults.size()),0);int index=0;
                for(const auto &o:s.objectResults){lua_createtable(l,0,8);
                    auto number=[&](const char *key,double n){lua_pushnumber(l,n);lua_setfield(l,-2,key);};
                    number("id",o.id);number("server_id",o.server);number("x",o.x);number("y",o.y);number("hp",o.hp);number("hostile",o.hostile?1:0);number("dst",o.distance);
                    lua_pushlstring(l,o.name.data(),o.name.size());lua_setfield(l,-2,"name");lua_rawseti(l,-2,++index);
                }return 1;
            }
            if(values.size()>32)throw std::runtime_error("Too many return values");
            lua_settop(l,0);int n=0;
            for(const auto &v:values){
                if(v.kind==Value::Text)lua_pushlstring(l,v.text.data(),v.text.size());
                else if(v.kind==Value::Boolean)lua_pushboolean(l,v.number!=0);
                else if(v.kind==Value::Number)lua_pushnumber(l,v.number);else lua_pushnil(l);
                ++n;
            }return n;
        }catch(const std::exception &e){s.failure=e.what();}
        return luaL_error(l,"%s",s.failure.c_str());
    }
    static int traceback(lua_State *l){luaL_traceback(l,l,lua_tostring(l,1),1);return 1;}
    static int sleep(lua_State *l){auto &s=self(l);const auto n=luaL_checkinteger(l,1);if(n<0||n>60000)return luaL_error(l,"Sleep must be 0..60000");s.wake=s.now+uint64_t(n);s.instructions=0;s.state=Sleeping;return lua_yield(l,0);}
    static int tick(lua_State *l){lua_pushinteger(l,lua_Integer(self(l).now));return 1;}
    static int metatable(lua_State *l){
        luaL_checktype(l,1,LUA_TTABLE);
        if(!lua_isnil(l,2)){
            luaL_checktype(l,2,LUA_TTABLE);lua_pushliteral(l,"__gc");lua_rawget(l,2);
            if(!lua_isnil(l,-1))return luaL_error(l,"Resident tasks cannot register __gc finalizers");
            lua_pop(l,1);
        }
        if(luaL_getmetafield(l,1,"__metatable")!=LUA_TNIL)return luaL_error(l,"Cannot change a protected metatable");
        lua_settop(l,2);lua_setmetatable(l,1);lua_settop(l,1);return 1;
    }
};
Vm::Vm(Host &host,bool diagnostics):p_(std::make_unique<Impl>(host,diagnostics)){}Vm::~Vm()=default;
bool Vm::start(const std::string &source,std::string &error){
    auto &s=*p_;s.close();s.failure.clear();s.bytes=0;s.now=s.wake=s.last=s.nativeCalls=s.instructions=0;s.hasTime=false;s.state=Idle;
    if(source.empty()||source.size()>2*1024*1024){error="Resident source must be 1 byte..2 MiB";return false;}
    s.main=lua_newstate(Impl::allocate,&s);if(!s.main){error="Cannot create Lua state";return false;}*static_cast<Impl**>(lua_getextraspace(s.main))=&s;
    for(const auto &lib:{std::pair<const char*,lua_CFunction>{LUA_GNAME,luaopen_base},{LUA_MATHLIBNAME,luaopen_math},{LUA_TABLIBNAME,luaopen_table},{LUA_STRLIBNAME,luaopen_string}}){luaL_requiref(s.main,lib.first,lib.second,1);lua_pop(s.main,1);}
    for(const char *key:{"dofile","loadfile"}){lua_pushnil(s.main);lua_setglobal(s.main,key);}
    // Lua disables debug hooks inside __gc, including lua_close; such callbacks
    // cannot share the cooperative scheduler's execution budget.
    lua_pushcfunction(s.main,Impl::metatable);lua_setglobal(s.main,"setmetatable");
    const char *names[]={"GetLuaValue","__game","__host","__log","__clock","__objects"};
    for(int i=0;i<6;++i){lua_pushinteger(s.main,i+1);lua_pushcclosure(s.main,Impl::api,1);lua_setglobal(s.main,names[i]);}
    if(s.offlineDiagnostics){lua_pushcfunction(s.main,Impl::traceback);lua_setglobal(s.main,"__offline_traceback");}
    lua_pushcfunction(s.main,Impl::sleep);lua_setglobal(s.main,"Sleep");lua_pushcfunction(s.main,Impl::tick);lua_setglobal(s.main,"GetTickCount");
    lua_pushboolean(s.main,1);lua_setglobal(s.main,"__resident");s.co=lua_newthread(s.main);*static_cast<Impl**>(lua_getextraspace(s.co))=&s;
    if(luaL_loadbufferx(s.co,source.data(),source.size(),"=task","t")!=LUA_OK){error=lua_tostring(s.co,-1);s.failure=error;s.state=Failed;s.close();return false;}
    s.state=Running;error.clear();return true;
}
void Vm::step(uint64_t active){
    auto &s=*p_;if(s.state!=Running&&s.state!=Sleeping)return;
    if(s.hasTime&&active<s.last){s.failure="Resident clock moved backwards";s.state=Failed;return;}s.hasTime=true;s.now=s.last=active;
    if(s.state==Sleeping&&active<s.wake)return;
    s.state=Running;s.thisCalls=0;s.quantum=0;s.deadline=std::chrono::steady_clock::now()+std::chrono::milliseconds(2);
    lua_sethook(s.co,Impl::hook,LUA_MASKCOUNT,1000);int n=0;const int result=lua_resume(s.co,nullptr,0,&n);
    if(result==LUA_OK){s.state=Completed;s.close();}
    else if(result!=LUA_YIELD){const auto why=lua_tostring(s.co,-1);s.failure=why?why:"Resident Lua error";s.state=Failed;s.close();}
}
void Vm::pause(bool value){auto &s=*p_;if(value&&(s.state==Running||s.state==Sleeping))s.state=Paused;else if(!value&&s.state==Paused)s.state=s.now<s.wake?Sleeping:Running;}
void Vm::stop(){p_->close();p_->state=Stopped;}
Vm::State Vm::state()const{return p_->state;}size_t Vm::allocated()const{return p_->bytes;}uint64_t Vm::calls()const{return p_->nativeCalls;}const std::string &Vm::error()const{return p_->failure;}
}
