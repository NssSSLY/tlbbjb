#pragma once
#include <windows.h>
#include <cstdint>
#include <cstring>
// Presses a named CEGUI push button inside the game, exactly as a mouse click does:
// the window's "Clicked" event runs the handler written in the game's own layout file,
// in the window's own script environment. Works even when that script is encrypted.
namespace tlbb::cegui {
struct NameView { union {char small[16];const char *pointer;};uint64_t length=0,capacity=15;
    explicit NameView(const char *name){length=std::strlen(name);if(length<16)std::memcpy(small,name,length+1);else{pointer=name;capacity=length;}}
};
template<class T>T exported(HMODULE module,const char *name){auto p=GetProcAddress(module,name);T result=nullptr;static_assert(sizeof(result)==sizeof(p));std::memcpy(&result,&p,sizeof(p));return result;}
// Visible, enabled buttons only, unless hidden is allowed (a popup menu item fired without opening the menu).
inline bool pressButton(const char *name,bool allowHidden=false,const char *eventSpace="PushButton"){
    HMODULE dll=GetModuleHandleW(L"CEGUIBase.dll");if(!dll||!name)return false;
    auto singleton=exported<void *(*)()>(dll,"?getSingletonPtr@WindowManager@CEGUI@@SAPEAV12@XZ");
    auto present=exported<bool (*)(void*,const NameView&)>(dll,"?isWindowPresent@WindowManager@CEGUI@@QEBA_NAEBV?$StringBaseT@D@2@@Z");
    auto window=exported<void *(*)(void*,const NameView&)>(dll,"?getWindow@WindowManager@CEGUI@@QEBAPEAVWindow@2@AEBV?$StringBaseT@D@2@@Z");
    auto visible=exported<bool (*)(void*,bool)>(dll,"?isVisible@Window@CEGUI@@QEBA_N_N@Z");
    auto disabled=exported<bool (*)(void*,bool)>(dll,"?isDisabled@Window@CEGUI@@QEBA_N_N@Z");
    auto argsCtor=exported<void (*)(void*,void*)>(dll,"??0WindowEventArgs@CEGUI@@QEAA@PEAVWindow@1@@Z");
    if(!singleton||!present||!window||!visible||!disabled||!argsCtor)return false;
    void *manager=singleton();NameView key(name);
    if(!manager||!present(manager,key))return false;
    void *w=window(manager,key);if(!w||(!allowHidden&&!visible(w,false))||disabled(w,false))return false;
    // PushButton::onClicked fires its EventSet at Window + 8 through slot +0x18 (fireEvent).
    const auto base=reinterpret_cast<uintptr_t>(w)+8;uintptr_t table=0,function=0;
    std::memcpy(&table,reinterpret_cast<void*>(base),sizeof(table));if(!table)return false;
    std::memcpy(&function,reinterpret_cast<void*>(table+0x18),sizeof(function));if(!function)return false;
    alignas(16) unsigned char args[64]{};argsCtor(args,w);
    using Fire=void (*)(void*,const NameView&,void*,const NameView&);
    NameView event("Clicked"),space(eventSpace);
    reinterpret_cast<Fire>(function)(reinterpret_cast<void*>(base),event,args,space);
    return true;
}
}
