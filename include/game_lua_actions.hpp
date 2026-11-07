#pragma once
#include "game_lua_login.hpp"
#include "game_snippets.hpp"
#include <algorithm>
#include <cstdio>
#include <cmath>
namespace tlbb::game_lua {
// Fixed game APIs only. No script text or arbitrary function name crosses the IPC.
inline bool monthlySign(HMODULE module,void *object,int reward,bool &mayHaveIssued,wchar_t (&detail)[97]){
    mayHaveIssued=false;
    auto fail=[&](const wchar_t *message){std::wcsncpy(detail,message,96);return false;};
    if(!module||!object||reward<0||reward>5)return fail(L"签到参数或脚本对象无效");
    using State=void *(*)(void*);using Destroy=void (*)(void*);using Top=int (*)(void*);using Index=void (*)(void*,int);
    using String=void (*)(void*,const char*);using Number=void (*)(void*,double);using Test=int (*)(void*,int);using Call=int (*)(void*,int,int,int);
    auto owner=api<State>(module,"?GetState@LuaObject@LuaPlus@@QEBAPEAVLuaState@2@XZ");
    auto create=api<State>(module,"?CreateThread@LuaState@LuaPlus@@SAPEAV12@PEAV12@@Z");
    auto native=api<State>(module,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
    auto destroy=api<Destroy>(module,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");
    auto table=api<bool (*)(void*)>(module,"?IsTable@LuaObject@LuaPlus@@QEBA_NXZ");
    auto top=api<Top>(module,"lua_gettop");auto set=api<Index>(module,"lua_settop");
    auto string=api<String>(module,"lua_pushstring");auto number=api<Number>(module,"lua_pushnumber");
    auto get=api<Index>(module,"lua_gettable");auto type=api<Test>(module,"lua_type");
    auto check=api<Test>(module,"lua_checkstack");auto call=api<Call>(module,"lua_pcall");
    if(!owner||!create||!native||!destroy||!table||!top||!set||!string||!number||!get||!type||!check||!call)return fail(L"游戏脚本 SDK 版本不符");
    if(!table(object))return fail(L"游戏脚本登记对象无效");
    void *child=create(owner(object));if(!child)return fail(L"无法创建独立脚本子状态");
    struct Guard{void *p;Destroy destroy;~Guard(){destroy(p);}}guard{child,destroy};
    auto vm=native(child);if(!vm||top(vm)>256||!check(vm,12))return fail(L"游戏脚本子状态容量不足");
    const int before=top(vm);
    const char *names[]={"Clear_XSCRIPT","Set_XSCRIPT_Function_Name","Set_XSCRIPT_ScriptID","Set_XSCRIPT_Parameter","Set_XSCRIPT_ParamCount","Send_XSCRIPT"};
    for(const auto name:names){string(vm,name);get(vm,-10001);const bool found=type(vm,-1)==6;set(vm,before);if(!found)return fail(L"当前游戏未注册签到所需脚本接口");}
    auto invoke=[&](const char *name,const char *text,double a,double b,int count,bool strings=false){
        string(vm,name);get(vm,-10001);
        if(strings)string(vm,text);else{if(count>=1)number(vm,a);if(count>=2)number(vm,b);}
        const bool ok=call(vm,count,0,0)==0;set(vm,before);return ok;
    };
    if(!invoke(names[0],nullptr,0,0,0)||!invoke(names[1],reward?"GetPrize":"CheckTodaySign",0,0,1,true)
        ||!invoke(names[2],nullptr,891106,0,1)
        ||(reward&&!invoke(names[3],nullptr,0,reward,2))
        ||!invoke(names[4],nullptr,reward?1:0,0,1))return fail(L"签到请求构建失败，未发送");
    // A failed Send call may already have submitted a request. Never replay it.
    mayHaveIssued=true;
    if(!invoke(names[5],nullptr,0,0,0))return fail(L"签到发送结果不确定，已停止且不会重发");
    return true;
}
struct LuaArg { bool text=false; double number=0; const char *string=nullptr; };
struct LuaResult { int count=0; double numbers[8]{}; char text[513]{}; };
// Compiles one fixed snippet in an SDK child state and calls the function it returns.
// The caller supplies only typed values; the source always comes from game_snippets.hpp.
inline bool runSnippet(HMODULE module,void *object,const char *source,const LuaArg *args,int argCount,bool action,LuaResult &out,bool &mayHaveIssued,wchar_t (&detail)[97]){
    mayHaveIssued=false;out=LuaResult{};
    auto fail=[&](const wchar_t *message){std::wcsncpy(detail,message,96);return false;};
    if(!module||!object||!source||argCount<0||argCount>6)return fail(L"游戏片段参数或脚本对象无效");
    using State=void *(*)(void*);using Destroy=void (*)(void*);using Top=int (*)(void*);using Index=void (*)(void*,int);
    using String=void (*)(void*,const char*);using Number=void (*)(void*,double);using Test=int (*)(void*,int);using Call=int (*)(void*,int,int,int);
    using Load=int (*)(void*,const char*,size_t,const char*);using ToNumber=double (*)(void*,int);using ToText=const char *(*)(void*,int);using Length=size_t (*)(void*,int);
    auto owner=api<State>(module,"?GetState@LuaObject@LuaPlus@@QEBAPEAVLuaState@2@XZ");
    auto create=api<State>(module,"?CreateThread@LuaState@LuaPlus@@SAPEAV12@PEAV12@@Z");
    auto native=api<State>(module,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
    auto destroy=api<Destroy>(module,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");
    auto table=api<bool (*)(void*)>(module,"?IsTable@LuaObject@LuaPlus@@QEBA_NXZ");
    auto top=api<Top>(module,"lua_gettop");auto set=api<Index>(module,"lua_settop");
    auto string=api<String>(module,"lua_pushstring");auto number=api<Number>(module,"lua_pushnumber");
    auto type=api<Test>(module,"lua_type");auto check=api<Test>(module,"lua_checkstack");auto call=api<Call>(module,"lua_pcall");
    auto load=api<Load>(module,"luaL_loadbuffer");auto toNumber=api<ToNumber>(module,"lua_tonumber");
    auto toText=api<ToText>(module,"lua_tostring");auto toBool=api<Test>(module,"lua_toboolean");auto length=api<Length>(module,"lua_strlen");
    if(!owner||!create||!native||!destroy||!table||!top||!set||!string||!number||!type||!check||!call||!load||!toNumber||!toText||!toBool||!length)return fail(L"游戏脚本 SDK 版本不符");
    if(!table(object))return fail(L"游戏脚本登记对象无效");
    void *child=create(owner(object));if(!child)return fail(L"无法创建独立脚本子状态");
    struct Guard{void *p;Destroy destroy;~Guard(){destroy(p);}}guard{child,destroy};
    auto vm=native(child);if(!vm||top(vm)>256||!check(vm,16))return fail(L"游戏脚本子状态容量不足");
    const int before=top(vm);
    auto reason=[&](const wchar_t *prefix){
        const char *text=type(vm,-1)==4?toText(vm,-1):nullptr;wchar_t message[64]{};
        if(text){size_t bytes=0;while(bytes<120&&text[bytes])++bytes;MultiByteToWideChar(936,0,text,int(bytes),message,63);}
        std::swprintf(detail,97,L"%ls%.60ls",prefix,message);set(vm,before);return false;
    };
    // Lua 5.0 type tags: nil 0, boolean 1, number 3, string 4, function 6.
    if(load(vm,source,std::strlen(source),"=tlbb")!=0)return reason(L"片段编译失败：");
    if(call(vm,0,1,0)!=0||type(vm,-1)!=6)return reason(L"片段初始化失败：");
    for(int i=0;i<argCount;++i){if(args[i].text)string(vm,args[i].string?args[i].string:"");else number(vm,args[i].number);}
    // From here a game call may already have happened; the caller must never replay it.
    mayHaveIssued=action;
    if(call(vm,argCount,8,0)!=0)return reason(action?L"游戏动作结果不确定：":L"游戏读取失败：");
    bool copied=false;
    for(int i=0;i<8;++i){
        const int at=before+1+i,kind=type(vm,at);
        if(kind==0)continue;
        out.count=i+1;
        if(kind==1)out.numbers[i]=toBool(vm,at)?1:0;
        else if(kind==3)out.numbers[i]=toNumber(vm,at);
        else if(kind==4&&!copied){const auto text=toText(vm,at);const size_t bytes=std::min<size_t>(length(vm,at),512);if(text)std::memcpy(out.text,text,bytes);out.text[bytes]=0;copied=true;}
    }
    set(vm,before);return true;
}
// Maps a validated snippet request to its fixed source and typed Lua arguments.
inline bool runGameSnippet(HMODULE module,void *object,uint32_t id,const gameplay::SnippetArgs &a,LuaResult &out,bool &mayHaveIssued,wchar_t (&detail)[97]){
    mayHaveIssued=false;
    if(!gameplay::validSnippet(id,a)){std::wcsncpy(detail,L"游戏片段参数超出允许范围",96);return false;}
    char text[160]{},label[32]{},padded[164]{},extra[3][32]{};
    auto gbk=[](const wchar_t *source,char *target,int size){BOOL lossy=FALSE;const int n=WideCharToMultiByte(936,WC_NO_BEST_FIT_CHARS,source,-1,target,size,nullptr,&lossy);return n>0&&!lossy;};
    if(a.text[0]&&!gbk(a.text,text,int(sizeof(text)))){std::wcsncpy(detail,L"文本无法转换为游戏编码",96);return false;}
    const int *i=a.ints;LuaArg args[6];int n=0;
    auto num=[&](double v){args[n++].number=v;};auto str=[&](const char *v){args[n].text=true;args[n++].string=v;};
    switch(id){
    case gameplay::CombatCast:num(i[1]);num(i[2]);num(i[3]);str(text);break;
    case gameplay::CombatSkill:str(text);break;
    case gameplay::CombatName:num(i[0]);break;
    case gameplay::RunTo:num(a.reals[0]);num(a.reals[1]);num(i[0]);break;
    case gameplay::TalkNpc:num(a.reals[0]);num(a.reals[1]);num(i[0]);str(text);break;
    case gameplay::NpcTarget:case gameplay::BagCount:case gameplay::WindowVisible:str(text);break;
    case gameplay::QuestOption:str(text);num(i[0]);break;
    case gameplay::QuestButton:
        if(i[0]>1&&!gbk(i[0]==2?L"继续":L"完成",label,int(sizeof(label)))){std::wcsncpy(detail,L"按钮文本转换失败",96);return false;}
        num(i[0]);num(i[1]);str(label);break;
    case gameplay::PlayerData:str(gameplay::playerKeys[i[0]]);break;
    case gameplay::XScript:{const auto &r=gameplay::xscripts[i[0]];str(r.function);num(r.script);num(r.params);num(i[1]);num(i[2]);break;}
    case gameplay::UiCall:{const auto &r=gameplay::uiCalls[i[0]];str(r.window);str(r.function);num(r.args);num(i[1]);num(r.visible?1:0);break;}
    case gameplay::UiEvent:str(gameplay::uiEvents[i[0]]);break;
    case gameplay::BankMoney:num(i[0]);num(i[1]);break;
    case gameplay::BankItem:case gameplay::TempBag:{
        std::snprintf(padded,sizeof(padded),id==gameplay::TempBag?" %s ":"%s",text);str(padded);num(i[0]);break;}
    case gameplay::BagStore:case gameplay::BagSell:str(text);num(i[0]);break;
    case gameplay::SweepEnum:case gameplay::SweepOpenPage:num(i[0]);break;
    case gameplay::SweepBoss:
        if(!gbk(L"扫荡三神幻境",label,int(sizeof(label)))){std::wcsncpy(detail,L"副本标题转换失败",96);return false;}
        str(label);break;
    case gameplay::CloseNamed:str(gameplay::closableWindows[i[0]]);break;
    case gameplay::DictText:str(text);break;
    case gameplay::NpcEventItem:num(i[0]);break;
    case gameplay::UseBagItem:case gameplay::MsgBoxText:
        if(!gbk(id==gameplay::UseBagItem?gameplay::usableItems[i[0]]:gameplay::msgBoxTexts[i[0]],label,int(sizeof(label)))){std::wcsncpy(detail,L"物品或提示文本转换失败",96);return false;}
        str(label);if(id==gameplay::UseBagItem){num(i[1]);num(i[2]);}break;
    case gameplay::MissionFind:case gameplay::Dismount:str(text);break;
    case gameplay::MissionVar:num(i[0]);num(i[1]);break;
    case gameplay::BagCountIn:case gameplay::ItemList:num(i[0]);str(text);break;
    case gameplay::CompoundSelect:case gameplay::LifeCompose:case gameplay::BagSpace:num(i[0]);break;
    case gameplay::WuhunList:case gameplay::MissionDesc:str(text);break;
    case gameplay::UiEnabled:str(gameplay::uiButtons[i[0]].window);str(gameplay::uiButtons[i[0]].button);break;
    case gameplay::CityEnemyHas:case gameplay::OpenAddEnemy:case gameplay::BieYeProduct:case gameplay::GoldGiftChoose:num(i[0]);break;
    case gameplay::HuoYueBuy:num(i[0]);num(i[1]);str(text);break;
    case gameplay::UseBoxItem:str(text);break;
    case gameplay::HuoDongEnum:case gameplay::SectOper:num(i[0]);break;
    case gameplay::AwakeAdd:num(i[0]);num(i[1]);num(i[2]);break;
    case gameplay::EquipDur:case gameplay::EquipRepair:num(i[0]);num(i[1]);break;
    case gameplay::DianJin:
        if(!gbk(L"点金玉",extra[0],32)||!gbk(L"3级棉布",extra[1],32)||!gbk(L"3级秘银",extra[2],32)){std::wcsncpy(detail,L"物品文本转换失败",96);return false;}
        num(i[0]);num(i[1]);num(i[2]);str(extra[0]);str(extra[1]);str(extra[2]);break;
    case gameplay::XZGift:
        if(!gbk(gameplay::xzGifts[i[0]].hero,extra[0],32)||!gbk(gameplay::xzGifts[i[0]].gift,extra[1],32)){std::wcsncpy(detail,L"名士文本转换失败",96);return false;}
        str(extra[0]);str(extra[1]);break;
    case gameplay::GemCarve:
        if(!gbk(L"宝石雕琢符",extra[0],32)||!gbk(L"级",extra[1],32)){std::wcsncpy(detail,L"宝石文本转换失败",96);return false;}
        str(text);str(extra[0]);str(extra[1]);break;
    case gameplay::LwCombine:num(i[0]);num(i[1]);num(i[2]);break;
    case gameplay::LwEquip:num(i[0]);break;
    case gameplay::SelfTarget:num(i[0]);num(i[1]);break;
    case gameplay::WuhunLife:case gameplay::XiuLianInfo:case gameplay::XinfaRead:case gameplay::XinfaStudy:num(i[0]);break;
    case gameplay::EquipRestore:case gameplay::WuhunRepair:
        if(!gbk(id==gameplay::EquipRestore?L"润物露":L"武魂延寿丹",label,int(sizeof(label)))){std::wcsncpy(detail,L"物品文本转换失败",96);return false;}
        if(id==gameplay::EquipRestore){num(i[0]);num(i[1]);}str(label);break;
    case gameplay::NpcShopBuy:if(!gbk(gameplay::shopItems[i[0]],label,int(sizeof(label)))){std::wcsncpy(detail,L"物品文本转换失败",96);return false;}str(label);break;
    case gameplay::DividendBuy:str(text);break;
    case gameplay::HonourBuy:case gameplay::GuildShopBuy:case gameplay::T3ShopBuy:case gameplay::ChongLouBuy:case gameplay::GuiShiBuy:num(i[0]);str(text);break;
    case gameplay::WuhunText:if(!gbk(gameplay::wuhunTexts[i[0]],label,int(sizeof(label)))){std::wcsncpy(detail,L"提示文本转换失败",96);return false;}str(label);break;
    case gameplay::WuhunCompound:num(i[0]);num(i[1]);str(text);break;
    case gameplay::ShopMoney:num(i[0]);break;
    case gameplay::GemList:
        if(!gbk(L"石",extra[0],32)||!gbk(L"级",extra[1],32)||!gbk(L"合成符",extra[2],32)){std::wcsncpy(detail,L"宝石文本转换失败",96);return false;}
        num(i[0]);str(extra[0]);str(extra[1]);str(extra[2]);break;
    case gameplay::GemCombine:{
        const wchar_t *tiers[]={L"低级宝石合成符",L"高级宝石合成符",L"超级宝石合成符"};
        if(!gbk(L"宝石合成",extra[0],32)||!gbk(tiers[i[2]-1],extra[1],32)){std::wcsncpy(detail,L"宝石文本转换失败",96);return false;}
        str(text);num(i[0]);num(i[1]);str(extra[0]);str(extra[1]);break;}
    default:break;
    }
    return runSnippet(module,object,gameplay::snippetSource(id),args,n,gameplay::snippetIssuesAction(id),out,mayHaveIssued,detail);
}
}
