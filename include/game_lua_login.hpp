#pragma once
#include <windows.h>
#include <cstdint>
#include <cstring>
#include <cwchar>
namespace tlbb::game_lua {
template<class T>T api(HMODULE module,const char *name){auto p=GetProcAddress(module,name);T result=nullptr;static_assert(sizeof(result)==sizeof(p));std::memcpy(&result,&p,sizeof(p));return result;}
inline bool selectServer(HMODULE module,void *object,int area,int server,wchar_t (&detail)[65]){
    auto fail=[&](const wchar_t *reason){std::wcsncpy(detail,reason,64);return false;};
    if(!module||!object)return fail(L"登录接口对象尚未就绪");
    using State=void *(*)(void*);using Destroy=void (*)(void*);using Top=int (*)(void*);using SetTop=void (*)(void*,int);using IsTable=bool (*)(void*);
    using PushObject=void (*)(void*,void*);using String=void (*)(void*,const char*);
    using Index=void (*)(void*,int);using Number=void (*)(void*,double);using Test=int (*)(void*,int);using Call=int (*)(void*,int,int,int);
    using Text=const char *(*)(void*,int);
    auto owner=api<State>(module,"?GetState@LuaObject@LuaPlus@@QEBAPEAVLuaState@2@XZ");
    auto create=api<State>(module,"?CreateThread@LuaState@LuaPlus@@SAPEAV12@PEAV12@@Z");
    auto native=api<State>(module,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
    auto destroy=api<Destroy>(module,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");
    auto top=api<Top>(module,"lua_gettop");auto setTop=api<SetTop>(module,"lua_settop");
    auto isTable=api<IsTable>(module,"?IsTable@LuaObject@LuaPlus@@QEBA_NXZ");
    auto push=api<PushObject>(module,"?lua_pushtobject@LuaPlus@@YAXPEAUlua_State@@PEAX@Z");
    auto string=api<String>(module,"lua_pushstring");auto get=api<Index>(module,"lua_gettable");
    auto value=api<Index>(module,"lua_pushvalue");auto number=api<Number>(module,"lua_pushnumber");
    auto isC=api<Test>(module,"lua_iscfunction");auto check=api<Test>(module,"lua_checkstack");auto call=api<Call>(module,"lua_pcall");
    auto type=api<Test>(module,"lua_type");auto text=api<Text>(module,"lua_tostring");
    if(!owner||!create||!native||!destroy||!top||!setTop||!isTable||!push||!string||!get||!value||!number||!isC||!check||!call||!type||!text)return fail(L"游戏脚本接口版本不匹配");
    if(!isTable(object))return fail(L"登录接口登记对象不是有效方法表");
    // The game's root VM retains thousands of interface objects. The SDK-created child shares
    // their table values and owns a fresh stack; its destructor never closes the parent VM.
    void *child=create(owner(object));if(!child)return fail(L"游戏脚本子状态创建失败");
    struct ChildGuard{void *state;Destroy destroy;~ChildGuard(){destroy(state);}} guard{child,destroy};
    auto *vm=native(child);if(!vm)return fail(L"游戏脚本子状态无效");
    const int before=top(vm);if(before<0||before>256||!check(vm,8))return fail(L"游戏脚本子状态容量不足");
    // PushStack uses the packed 12-byte TValue at +0x18 in this hash-locked LuaPlus version.
    push(vm,reinterpret_cast<char*>(object)+0x18);string(vm,"SelectLoginServer");get(vm,-2);
    if(!isC(vm,-1)){setTop(vm,before);return fail(L"游戏选服方法尚未登记");}
    // The registration table owns the methods, not the game's C++ instance. The
    // native thunk extracts its this pointer from global GameProduceLogin / __object.
    string(vm,"GameProduceLogin");get(vm,-10001); // LUA_GLOBALSINDEX in this Lua 5.0 build.
    if(type(vm,-1)!=7&&type(vm,-1)!=5){setTop(vm,before);return fail(L"游戏登录实例尚未就绪");}
    number(vm,area);number(vm,server);number(vm,3);
    const int result=call(vm,4,0,0);
    if(result!=0){const char *reason=text(vm,-1);wchar_t message[49]{};if(reason){size_t bytes=0;while(bytes<80&&reason[bytes])++bytes;MultiByteToWideChar(936,0,reason,int(bytes),message,48);}std::swprintf(detail,65,L"选服 Lua(%d)：%.45ls",result,message[0]?message:L"方法返回异常");}
    setTop(vm,before);return result==0;
}
}
