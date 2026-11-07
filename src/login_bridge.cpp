#include "login_protocol.hpp"
#include "game_lua_login.hpp"
#include "live_layout.hpp"
#include "game_text.hpp"
#include "login_password_input.hpp"
#include <cstring>
#include <cstdio>
#include <algorithm>
namespace {
using namespace tlbb;
// This is the read-only MSVC string view used by this exact game build. Never freed by the game.
struct NameView { union {char small[16];const char *pointer;};uint64_t length=0,capacity=15;
    explicit NameView(const char *name){length=std::strlen(name);if(length<16)std::memcpy(small,name,length+1);else{pointer=name;capacity=length;}}
};
template<class T>T symbol(HMODULE module,const char *name){auto p=GetProcAddress(module,name);T result=nullptr;static_assert(sizeof(result)==sizeof(p));std::memcpy(&result,&p,sizeof(p));return result;}
struct Ui {
    HMODULE dll=GetModuleHandleW(L"CEGUIBase.dll");void *manager=nullptr;
    void *(*singleton)()=nullptr;
    bool (*present)(void*,const NameView&)=nullptr;
    void *(*window)(void*,const NameView&)=nullptr;
    bool (*visible)(void*,bool)=nullptr;
    bool (*disabled)(void*,bool)=nullptr;
    const void *(*text)(void*)=nullptr;
    const char *(*cstr)(const void*)=nullptr;
    void (*stringCtor)(void*,const char*)=nullptr;
    void (*stringDtor)(void*)=nullptr;
    void (*setText)(void*,const void*)=nullptr;
    void (*activate)(void*)=nullptr;
    void (*argsCtor)(void*,void*)=nullptr;
    void (*click)(void*,void*)=nullptr;
    void (*mouseArgsCtor)(void*,void*)=nullptr;
    void (*fireEvent)(void*,const NameView&,void*,const NameView&)=nullptr;
    void *(*system)()=nullptr;
    void (*script)(void*,const NameView&)=nullptr;
    bool init(){
#define LOAD(field,type,name) field=symbol<type>(dll,name);if(!field)return false
        if(!dll)return false;
        LOAD(singleton,decltype(singleton),"?getSingletonPtr@WindowManager@CEGUI@@SAPEAV12@XZ");
        LOAD(present,decltype(present),"?isWindowPresent@WindowManager@CEGUI@@QEBA_NAEBV?$StringBaseT@D@2@@Z");
        LOAD(window,decltype(window),"?getWindow@WindowManager@CEGUI@@QEBAPEAVWindow@2@AEBV?$StringBaseT@D@2@@Z");
        LOAD(visible,decltype(visible),"?isVisible@Window@CEGUI@@QEBA_N_N@Z");
        LOAD(disabled,decltype(disabled),"?isDisabled@Window@CEGUI@@QEBA_N_N@Z");
        LOAD(text,decltype(text),"?getText@Window@CEGUI@@QEBAAEBVString32@2@XZ");
        LOAD(cstr,decltype(cstr),"?c_str@String32@CEGUI@@QEBAPEBDXZ");
        LOAD(stringCtor,decltype(stringCtor),"??0String32@CEGUI@@QEAA@PEBD@Z");
        LOAD(stringDtor,decltype(stringDtor),"??1String32@CEGUI@@QEAA@XZ");
        LOAD(setText,decltype(setText),"?setText@Window@CEGUI@@UEAAXAEBVString32@2@@Z");
        LOAD(activate,decltype(activate),"?activate@Window@CEGUI@@QEAAXXZ");
        LOAD(argsCtor,decltype(argsCtor),"??0WindowEventArgs@CEGUI@@QEAA@PEAVWindow@1@@Z");
        LOAD(click,decltype(click),"?onClicked@PushButton@CEGUI@@MEAAXAEAVWindowEventArgs@2@@Z");
        LOAD(mouseArgsCtor,decltype(mouseArgsCtor),"??0MouseEventArgs@CEGUI@@QEAA@PEAVWindow@1@@Z");
#undef LOAD
        manager=singleton();return manager!=nullptr;
    }
    void *find(const char *name){NameView key(name);return present(manager,key)?window(manager,key):nullptr;}
    bool shown(const char *name){auto *w=find(name);return w&&visible(w,false);}
    bool enabled(void *w){return w&&visible(w,false)&&!disabled(w,false);}
    bool read(const char *name,wchar_t *out,int limit,bool includeHidden=false){
        auto *w=find(name);if(!w||(!includeHidden&&!visible(w,false)))return false;
        const char *p=cstr(text(w));char bytes[513]{};size_t n=0;
        for(;n<512;++n){if(!live::read(GetCurrentProcess(),uintptr_t(p)+n,bytes+n,1))return false;if(!bytes[n])break;}
        if(n==512)return false;
        return decodeCeguiUtf8(bytes,int(n),out,limit);
    }
    bool fill(void *w,const char *value){
        if(!enabled(w))return false;
        alignas(16) unsigned char storage[512]{};
        stringCtor(storage,value);setText(w,storage);stringDtor(storage);SecureZeroMemory(storage,sizeof(storage));return true;
    }
    bool dispatch(void *w,const char *name,void *args,const char *space){
        // Native PushButton::onClicked dispatches EventSet at Window + 8 through slot +0x18.
        // Use that same subobject rather than treating Window as EventSet or reading derived fields.
        const auto base=uintptr_t(w)+8;uintptr_t table=0,function=0;
        if(!live::get(GetCurrentProcess(),base,table)||!live::get(GetCurrentProcess(),table+0x18,function))return false;
        using EventFunction=void (*)(void*,const NameView&,void*,const NameView&);
        auto call=reinterpret_cast<EventFunction>(function);NameView event(name),ns(space);call(reinterpret_cast<void*>(base),event,args,ns);return true;
    }
    bool press(const char *name){auto *w=find(name);if(!enabled(w))return false;alignas(16) unsigned char args[64]{};argsCtor(args,w);return dispatch(w,"Clicked",args,"PushButton");}
    bool pressNative(const char *name){auto *w=find(name);if(!enabled(w)||!click)return false;alignas(16) unsigned char args[64]{};argsCtor(args,w);click(w,args);return true;}
    bool passwordMode(bool email){
        const char *name=email?"LogOn_OwnDefineLogon":"LogOn_TraditionLogon";
        auto *w=find(name);if(!enabled(w)){name=email?"OldLogOn_OwnDefineLogon":"OldLogOn_TraditionLogon";w=find(name);}
        if(!enabled(w))return false;
        alignas(16) unsigned char args[192]{};mouseArgsCtor(args,w);return dispatch(w,"MouseLButtonDown",args,"Window");
    }
};
bool nativeString(uintptr_t at,wchar_t *out,size_t cap){
    uintptr_t length=0,capacity=0,ptr=at;char data[257]{};
    if(!live::get(GetCurrentProcess(),at+0x10,length)||!live::get(GetCurrentProcess(),at+0x18,capacity)||length==0||length>256||capacity<length)return false;
    if(capacity>=16&&!live::get(GetCurrentProcess(),at,ptr))return false;
    if(!live::read(GetCurrentProcess(),ptr,data,length))return false;
    return MultiByteToWideChar(936,MB_ERR_INVALID_CHARS,data,int(length),out,int(cap-1))>0;
}
bool serverMatch(login::Packet &p,uintptr_t base){
    uintptr_t manager=0,begin=0,end=0;
    if(!live::get(GetCurrentProcess(),base+0x105d568,manager)||!live::get(GetCurrentProcess(),manager+8,begin)||!live::get(GetCurrentProcess(),manager+16,end)||end<begin||(end-begin)%96||(end-begin)/96>128)return false;
    using ServerInfo=void *(*)(void*,int,int);
    auto info=reinterpret_cast<ServerInfo>(base+0x636740);
    int matches=0;
    for(unsigned a=0;a<(end-begin)/96;++a){
        wchar_t area[129]{};int count=0;
        if(!nativeString(begin+a*96+8,area,129)||!login::sameDistrict(area,p.district)||!live::get(GetCurrentProcess(),begin+a*96+0x58,count)||count<0||count>1024)continue;
        for(int s=0;s<count;++s){auto *entry=info(reinterpret_cast<void*>(manager),int(a),s);wchar_t name[129]{};
            if(entry&&nativeString(uintptr_t(entry)+16,name,129)&&!std::wcscmp(name,p.server)){p.areaIndex=int(a);p.serverIndex=s;++matches;}}
    }
    p.matched=matches==1;return p.matched;
}
bool selectedServer(login::Packet &p,uintptr_t base){
    uintptr_t manager=0,begin=0,end=0;int area=-1,server=-1,count=0;
    if(!live::get(GetCurrentProcess(),base+0x105d568,manager)||!live::get(GetCurrentProcess(),manager+8,begin)||!live::get(GetCurrentProcess(),manager+16,end)||!live::get(GetCurrentProcess(),manager+0x60,area)||!live::get(GetCurrentProcess(),manager+0x64,server)||area<0||server<0||end<begin||(end-begin)%96||(end-begin)/96>128||unsigned(area)>=(end-begin)/96)return false;
    if(!nativeString(begin+uintptr_t(area)*96+8,p.currentDistrict,129)||!live::get(GetCurrentProcess(),begin+uintptr_t(area)*96+0x58,count)||count<1||count>1024||server>=count)return false;
    using ServerInfo=void *(*)(void*,int,int);auto info=reinterpret_cast<ServerInfo>(base+0x636740);
    auto *entry=info(reinterpret_cast<void*>(manager),area,server);
    if(!entry||!nativeString(uintptr_t(entry)+16,p.currentServer,129))return false;
    return login::sameDistrict(p.currentDistrict,p.district)&&!std::wcscmp(p.currentServer,p.server);
}
bool selectThroughGameLua(uintptr_t base,int area,int server,wchar_t (&detail)[65]){
    uintptr_t object=0;if(!live::get(GetCurrentProcess(),base+0x1056970,object)||object<0x10000){std::wcsncpy(detail,L"登录接口对象尚未就绪",64);return false;}
    return game_lua::selectServer(GetModuleHandleW(L"LuaPlus.dll"),reinterpret_cast<void*>(object),area,server,detail);
}
void execute(login::Packet &p,HWND gameWindow){
    p.executedThread=GetCurrentThreadId();
    auto reject=[&](DWORD e){p.error=e;SecureZeroMemory(p.password,sizeof(p.password));SecureZeroMemory(p.account,sizeof(p.account));InterlockedExchange(&p.status,3);};
    FILETIME c{},e{},k{},u{};GetProcessTimes(GetCurrentProcess(),&c,&e,&k,&u);
    const auto now=GetTickCount64();
    if(now>p.expires){reject(WAIT_TIMEOUT);return;}
    if(p.targetThread!=GetCurrentThreadId()||p.created!=((uint64_t(c.dwHighDateTime)<<32)|c.dwLowDateTime)||p.expires-now>5000||p.command<login::Query||p.command>login::SetAccountMode){reject(ERROR_INVALID_DATA);return;}
    wchar_t path[32768]{};GetModuleFileNameW(nullptr,path,32768);const auto *name=std::wcsrchr(path,L'\\');
    auto base=uintptr_t(GetModuleHandleW(nullptr));
    if(!name||_wcsicmp(name+1,L"Game.exe")||!live::signature(GetCurrentProcess(),base)){reject(ERROR_REVISION_MISMATCH);return;}
    if(!std::wmemchr(p.district,0,129)||!std::wmemchr(p.server,0,129)){reject(ERROR_INVALID_PARAMETER);return;}
    Ui ui;if(!ui.init()){reject(ERROR_MOD_NOT_FOUND);return;}
    // Unknown authentication dialogs are never accepted; these known ones explicitly require a person.
    const char *prompts[]={"Pswprotect_BackGround_Frame","Logon_FZKCheckFail_Frame","SelectServerQuest_Frame","OnlyChangyoujia_Logon_Frame","LoginOverTime_Frame"};
    for(auto prompt:prompts)if(ui.shown(prompt)){p.stage=login::Manual;std::wcsncpy(p.prompt,L"游戏验证或提示窗口，请人工处理",64);SecureZeroMemory(p.password,sizeof(p.password));InterlockedExchange(&p.status,2);return;}
    live::Snapshot liveState;
    if(ui.shown("SelectRole_Frame"))p.stage=login::Roles;
    else if(ui.shown("LogOn_Frame"))p.stage=login::Account;
    else if(ui.shown("SelectServer_Frame"))p.stage=login::Server;
    else if(live::snapshot(GetCurrentProcess(),base,liveState))p.stage=login::World;
    const unsigned desiredMode=p.inputMode;
    p.inputMode=ui.enabled(ui.find("LogOn_MailID"))?2:ui.enabled(ui.find("LogOn_ID"))?1:0;
    p.selectedMatches=selectedServer(p,base);
    if(p.stage==login::Roles||(p.command==login::Query&&p.stage==login::World)){for(int i=0;i<3;++i){char key[80]{};const char *suffix=i==0?"":i==1?"2":"3";std::snprintf(key,80,"SelectRole_TargetInfo_Create%s",suffix);if(ui.shown(key))continue;std::snprintf(key,80,"SelectRole_TargetInfo_Name_Text%s",suffix);ui.read(key,p.roleNames[i],65,p.stage==login::World);}}
    if(p.command==login::SelectServer){
        if(p.stage!=login::Server||!serverMatch(p,base)){reject(ERROR_NOT_FOUND);return;}
        if(!selectThroughGameLua(base,p.areaIndex,p.serverIndex,p.prompt)){reject(ERROR_INVALID_FUNCTION);return;}p.actionIssued=1;
    }else if(p.command==login::BackToServer){
        if(p.stage!=login::Account||!ui.press("LogOn_Last")){reject(ERROR_NOT_READY);return;}p.actionIssued=1;
    }else if(p.command==login::SetAccountMode){
        if(p.stage!=login::Account||(desiredMode!=1&&desiredMode!=2)||!ui.passwordMode(desiredMode==2)){reject(ERROR_NOT_READY);return;}p.actionIssued=1;
    }else if(p.command==login::SubmitAccount){
        auto *id=ui.find(desiredMode==2?"LogOn_MailID":"LogOn_ID"),*password=ui.find("LogOn_PassWord"),*button=ui.find("LogOn_LogOnGame");
        if(p.stage!=login::Account||!p.selectedMatches||!p.account[0]||!p.password[0]||!std::memchr(p.account,0,sizeof(p.account))||!std::memchr(p.password,0,sizeof(p.password))||!ui.enabled(id)||!ui.enabled(password)||!ui.enabled(button)){reject(ERROR_NOT_READY);return;}
        // Secure edit boxes update their internal state on character input. The
        // reference launcher activates this box and sends WM_IME_CHAR per byte;
        // setting Window::setText alone does not follow that input path.
        size_t passwordLength=0;
        if(!gameWindow||!login::validPasswordInput(p.password,sizeof(p.password),passwordLength)){
            std::wcsncpy(p.prompt,L"密码须为 1 至 32 位半角字符，请检查后重试",64);reject(ERROR_INVALID_PARAMETER);return;
        }
        const char *current=ui.cstr(ui.text(password));char first=0;
        const bool empty=current&&live::read(GetCurrentProcess(),uintptr_t(current),&first,1)&&!first;
        SecureZeroMemory(&first,sizeof(first));
        if(!empty){
            std::wcsncpy(p.prompt,L"密码框不是空的，请先清空后重新登录",64);reject(ERROR_INVALID_STATE);return;
        }
        if(!ui.fill(id,p.account)){reject(ERROR_NOT_READY);return;}
        ui.activate(password);
        const bool sent=login::sendPasswordInput(p.password,sizeof(p.password),[&](unsigned char ch){
            SendMessageW(gameWindow,WM_IME_CHAR,WPARAM(ch),1);Sleep(3);return true;
        });
        SecureZeroMemory(p.password,sizeof(p.password));
        if(!sent){reject(ERROR_INVALID_DATA);return;}
        if(!ui.pressNative("LogOn_LogOnGame")){reject(ERROR_NOT_READY);return;}p.actionIssued=1;
    }else if(p.command==login::SelectRole||p.command==login::EnterWorld){
        if(p.stage!=login::Roles||!p.selectedMatches||p.slot<1||p.slot>3||!p.roleNames[p.slot-1][0]){reject(ERROR_NOT_FOUND);return;}
        char key[80]{};
        if(p.command==login::SelectRole)std::snprintf(key,80,"SelectRole_TargetInfo_Button%u",p.slot);
        else{std::snprintf(key,80,"SelectRole_TargetInfo_Gaoliang%u",p.slot);if(!ui.shown(key)){reject(ERROR_INVALID_STATE);return;}std::strcpy(key,"SelectRole_Play");}
        if(!ui.press(key)){reject(ERROR_NOT_READY);return;}p.actionIssued=1;
    }
    SecureZeroMemory(p.password,sizeof(p.password));SecureZeroMemory(p.account,sizeof(p.account));InterlockedExchange(&p.status,2);
}
}
extern "C" __declspec(dllexport) LRESULT CALLBACK TlbbLoginHook(int code,WPARAM removed,LPARAM parameter){
    if(code==HC_ACTION&&removed==PM_REMOVE){auto *m=reinterpret_cast<MSG*>(parameter);static const UINT id=RegisterWindowMessageW(tlbb::login::messageName);
        if(m&&m->message==id&&m->wParam==GetCurrentProcessId()){
            wchar_t name[128]{};tlbb::login::mappingName(name,GetCurrentProcessId(),uint64_t(m->lParam));
            HANDLE h=OpenFileMappingW(FILE_MAP_READ|FILE_MAP_WRITE,FALSE,name);
            if(h){auto *p=static_cast<tlbb::login::Packet*>(MapViewOfFile(h,FILE_MAP_READ|FILE_MAP_WRITE,0,0,sizeof(tlbb::login::Packet)));
                if(p){if(p->marker==tlbb::login::magic&&p->version==1&&p->bytes==sizeof(*p)&&p->targetPid==GetCurrentProcessId()&&p->ownerPid!=p->targetPid&&p->nonce==uint64_t(m->lParam)&&InterlockedCompareExchange(&p->status,1,0)==0)execute(*p,m->hwnd);UnmapViewOfFile(p);}CloseHandle(h);}
            m->message=WM_NULL;m->wParam=0;m->lParam=0;
        }}return CallNextHookEx(nullptr,code,removed,parameter);
}
#ifndef TLBB_ENGINE_COMBINED
BOOL WINAPI DllMain(HINSTANCE h,DWORD reason,LPVOID){if(reason==DLL_PROCESS_ATTACH)DisableThreadLibraryCalls(h);return TRUE;}
#endif
