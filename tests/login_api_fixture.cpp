#include "game_lua_login.hpp"
#include "game_lua_actions.hpp"
#include <cstdio>
#include <cwchar>
#include <string>
using namespace tlbb::game_lua;
static double (*numberAt)(void*,int)=nullptr;
static int (*getTop)(void*)=nullptr;
static int (*typeAt)(void*,int)=nullptr;
static int called=0;
static const char *(*textAt)(void*,int)=nullptr;
static int sent=0,signs=0,rewards=0,clears=0;
static int scriptId=0,param=-1,paramCount=-1;
static std::string functionName;
static bool requestValid=true;
static wchar_t firstActionError[97]{};
static int setupOk=0;
static int clearRequest(void *state){requestValid&=getTop(state)==0;scriptId=0;param=-1;paramCount=-1;functionName.clear();++clears;return 0;}
static int setFunction(void *state){requestValid&=getTop(state)==1&&typeAt(state,1)==4;const auto text=textAt(state,1);functionName=text?text:"";return 0;}
static int setScript(void *state){requestValid&=getTop(state)==1;scriptId=int(numberAt(state,1));return 0;}
static int setParameter(void *state){requestValid&=getTop(state)==2&&numberAt(state,1)==0;param=int(numberAt(state,2));return 0;}
static int setCount(void *state){requestValid&=getTop(state)==1;paramCount=int(numberAt(state,1));return 0;}
static int sendRequest(void *state){requestValid&=getTop(state)==0&&scriptId==891106;++sent;if(functionName=="CheckTodaySign"){requestValid&=paramCount==0&&param==-1;++signs;}else{requestValid&=functionName=="GetPrize"&&paramCount==1&&param>=1&&param<=5;++rewards;}return 0;}
static int callback(void *state){if(getTop(state)==4&&typeAt(state,1)==7&&numberAt(state,2)==15&&numberAt(state,3)==12&&numberAt(state,4)==3)++called;return 0;}
int wmain(int argc,wchar_t **argv){
    if(argc!=3)return 2;
    auto dll=LoadLibraryExW(argv[1],nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);if(!dll)return 3;
    using Create=void *(*)(bool,bool);using State=void *(*)(void*);using Destroy=void (*)(void*);
    using NewTable=void (*)(void*);using String=void (*)(void*,const char*);using Closure=void (*)(void*,int (*)(void*),int);
    using Index=void (*)(void*,int);using Number=void (*)(void*,double);using Constructor=void (*)(void*,void*,int);
    auto create=api<Create>(dll,"?Create@LuaState@LuaPlus@@SAPEAV12@_N0@Z");auto native=api<State>(dll,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
    auto destroy=api<Destroy>(dll,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");auto table=api<NewTable>(dll,"lua_newtable");
    auto string=api<String>(dll,"lua_pushstring");auto closure=api<Closure>(dll,"lua_pushcclosure");auto set=api<Index>(dll,"lua_settable");
    auto setTop=api<Index>(dll,"lua_settop");auto number=api<Number>(dll,"lua_pushnumber");
    auto ctor=api<Constructor>(dll,"??0LuaObject@LuaPlus@@QEAA@PEAVLuaState@1@H@Z");auto dtor=api<Destroy>(dll,"??1LuaObject@LuaPlus@@QEAA@XZ");
    auto userdata=api<void *(*)(void*,size_t)>(dll,"lua_newuserdata");typeAt=api<int (*)(void*,int)>(dll,"lua_type");
    getTop=api<int (*)(void*)>(dll,"lua_gettop");numberAt=api<double (*)(void*,int)>(dll,"lua_tonumber");
    textAt=api<const char *(*)(void*,int)>(dll,"lua_tostring");
    if(!create||!native||!destroy||!table||!string||!closure||!set||!setTop||!number||!ctor||!dtor||!getTop||!numberAt||!userdata||!typeAt)return 4;
    void *owner=create(false,false);if(!owner)return 5;void *vm=native(owner);
    table(vm);string(vm,"SelectLoginServer");closure(vm,callback,0);set(vm,-3);
    alignas(16) unsigned char object[80]{};ctor(object,owner,1);setTop(vm,0);
    string(vm,"GameProduceLogin");userdata(vm,sizeof(void*));set(vm,-10001);
    const char *names[]={"Clear_XSCRIPT","Set_XSCRIPT_Function_Name","Set_XSCRIPT_ScriptID","Set_XSCRIPT_Parameter","Set_XSCRIPT_ParamCount","Send_XSCRIPT"};
    int (*callbacks[])(void*)={clearRequest,setFunction,setScript,setParameter,setCount,sendRequest};
    for(int i=0;i<6;++i){string(vm,names[i]);closure(vm,callbacks[i],0);set(vm,-10001);}
    for(int i=0;i<6331;++i)number(vm,double(i));
    const int before=getTop(vm);bool ok=before==6331;wchar_t detail[65]{};
    for(int i=0;i<32&&ok;++i)ok=selectServer(dll,object,15,12,detail)&&getTop(vm)==before;
    ok=ok&&called==32&&textAt;
    setupOk=ok;
    if(ok){
        wchar_t actionDetail[97]{};bool mayHaveIssued=false;
        for(int round=0;round<2&&ok;++round)for(int reward=0;reward<=5&&ok;++reward){ok=monthlySign(dll,object,reward,mayHaveIssued,actionDetail)&&mayHaveIssued&&getTop(vm)==before;if(!ok)std::wcsncpy(firstActionError,actionDetail,96);}
        const int priorClears=clears;
        auto nil=api<void (*)(void*)>(dll,"lua_pushnil");ok=ok&&nil;
        auto createThread=api<State>(dll,"?CreateThread@LuaState@LuaPlus@@SAPEAV12@PEAV12@@Z");
        if(nil&&createThread){auto child=createThread(owner);auto childVm=native(child);string(childVm,"Send_XSCRIPT");nil(childVm);set(childVm,-10001);destroy(child);ok=ok&&!monthlySign(dll,object,0,mayHaveIssued,actionDetail)&&!mayHaveIssued&&clears==priorClears&&getTop(vm)==before;}else ok=false;
        ok=ok&&requestValid&&sent==12&&signs==2&&rewards==10;
    }
    for(int i=0;i<before&&ok;++i)ok=numberAt(vm,i+1)==i;
    dtor(object);destroy(owner);FreeLibrary(dll);
    FILE *report=_wfopen(argv[2],L"wb");if(!report)return 6;
    char detailUtf8[400]{};WideCharToMultiByte(CP_UTF8,0,firstActionError,-1,detailUtf8,400,nullptr,nullptr);
    std::fprintf(report,"{\"status\":\"%s\",\"parent_stack\":%d,\"callback_count\":%d,\"daily_sign_calls\":%d,\"reward_calls\":%d,\"clears\":%d,\"setup_ok\":%d,\"action_error\":\"%s\",\"game_process_accessed\":false,\"parent_stack_preserved\":%s}\n",ok?"pass":"fail",before,called,signs,rewards,clears,setupOk,detailUtf8,ok?"true":"false");std::fclose(report);
    return ok?0:1;
}
