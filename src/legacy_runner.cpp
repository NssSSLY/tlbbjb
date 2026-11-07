#include "legacy_runner.hpp"
#include "builtin_resources.hpp"
#include "legacy_api_names.hpp"
#include <QDateTime>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QJsonArray>
#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <tuple>
#include <windows.h>
extern "C" {
#include <lauxlib.h>
#include <lualib.h>
}
namespace tlbb {
bool LegacyRunner::parseGameCall(const QString &source,gameplay::Command &command,int &argument){
    if(source.size()>4096)return false;
    auto text=source;text.remove(QRegularExpression("[\\s;]+"));
    const QString start="Clear_XSCRIPT()Set_XSCRIPT_Function_Name(\"",script="\")Set_XSCRIPT_ScriptID(891106)";
    if(text==start+"CheckTodaySign"+script+"Set_XSCRIPT_ParamCount(0)Send_XSCRIPT()"){
        command=gameplay::DailySign;argument=0;return true;
    }
    for(int i=1;i<=5;++i)if(text==start+"GetPrize"+script+QString("Set_XSCRIPT_Parameter(0,%1)Set_XSCRIPT_ParamCount(1)Send_XSCRIPT()").arg(i)){
        command=gameplay::ClaimMonthlyReward;argument=i;return true;
    }
    return false;
}
bool LegacyRunner::parseScriptCall(const QString &source,uint32_t &snippet,gameplay::SnippetArgs &args){
    if(source.size()>4096)return false;
    auto text=source;text.remove(QRegularExpression("\\s+"));
    while(text.endsWith(';'))text.chop(1);
    text.replace(";","");
    args=gameplay::SnippetArgs{};
    if(text=="Target:SendUpdateVipInfoMsg()"){snippet=gameplay::VipRefresh;return true;}  // 领取周道具奖励
    static const QRegularExpression compound("^setmetatable\\(_G,\\{__index=CaiLiaoCompound_Env\\}\\)CaiLiaoCompound_List:SetItemSelectByItemID\\((\\d{1,5})\\)$");
    if(const auto m=compound.match(text);m.hasMatch()){args.ints[0]=m.captured(1).toInt();snippet=gameplay::CompoundSelect;return gameplay::validSnippet(snippet,args);}
    static const QRegularExpression xscript("^Clear_XSCRIPT\\(\\)Set_XSCRIPT_Function_Name\\([\"']([A-Za-z_]{1,48})[\"']\\)Set_XSCRIPT_ScriptID\\((\\d{1,7})\\)"
        "((?:Set_XSCRIPT_Parameter\\(\\d,-?\\d{1,7}\\))*)Set_XSCRIPT_ParamCount\\((\\d)\\)Send_XSCRIPT\\(\\)$");
    if(const auto m=xscript.match(text);m.hasMatch()){
        QList<int> values;static const QRegularExpression parameter("Set_XSCRIPT_Parameter\\((\\d),(-?\\d{1,7})\\)");
        for(auto it=parameter.globalMatch(m.captured(3));it.hasNext();){const auto p=it.next();if(p.captured(1).toInt()!=values.size())return false;values<<p.captured(2).toInt();}
        if(values.size()!=m.captured(4).toInt()||values.size()>2)return false;
        for(int i=0;i<gameplay::count(gameplay::xscripts);++i){
            const auto &rule=gameplay::xscripts[i];
            if(m.captured(1)!=rule.function||m.captured(2).toInt()!=rule.script||values.size()!=rule.params)continue;
            args.ints[0]=i;for(int p=0;p<values.size();++p)args.ints[1+p]=values[p];
            snippet=gameplay::XScript;if(gameplay::validSnippet(snippet,args))return true;
        }
        return false;
    }
    static const QRegularExpression ui("^setmetatable\\(_G,\\{__index=([A-Za-z0-9_]{1,40})_Env\\}\\)(ifthis:IsVisible\\(\\)thenelsereturnend|ifthisandthis:IsVisible\\(\\)then)?([A-Za-z0-9_]{1,60})\\((-?\\d{0,3})\\)(end)?$");
    if(const auto m=ui.match(text);m.hasMatch()){
        if(m.captured(2).startsWith("ifthisand")!=(m.captured(5)=="end"))return false;
        for(int i=0;i<gameplay::count(gameplay::uiCalls);++i){
            const auto &rule=gameplay::uiCalls[i];
            if(m.captured(1)!=rule.window||m.captured(3)!=rule.function||m.captured(4).isEmpty()!=(rule.args==0))continue;
            args.ints[0]=i;args.ints[1]=m.captured(4).toInt();
            snippet=gameplay::UiCall;if(gameplay::validSnippet(snippet,args))return true;
        }
        return false;
    }
    static const QRegularExpression event("^PushEvent\\([\"']([A-Z_]{1,48})[\"']\\)$");
    if(const auto m=event.match(text);m.hasMatch()){
        for(int i=0;i<gameplay::count(gameplay::uiEvents);++i)if(m.captured(1)==gameplay::uiEvents[i]){args.ints[0]=i;snippet=gameplay::UiEvent;return true;}
        return false;
    }
    if(text=="CloseAllWindow()"){snippet=gameplay::CloseAll;return true;}
    return false;
}
QByteArray LegacyRunner::mangle(const QByteArray &name){return "__u_"+name.toHex();}
QByteArray LegacyRunner::translateSource(const QByteArray &input,QString &error){
    error.clear();QByteArray source=input;
    if(source.startsWith("\xEF\xBB\xBF"))source.remove(0,3);
    if(MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,source.constData(),int(source.size()),nullptr,0)<=0&&!source.isEmpty()){
        // Reference scripts are stored as GBK. They are converted once and then run as UTF-8.
        const int wide=MultiByteToWideChar(936,MB_ERR_INVALID_CHARS,source.constData(),int(source.size()),nullptr,0);
        if(wide<=0){error="脚本既不是 UTF-8 也不是 GBK";return {};}
        std::wstring text(size_t(wide),L'\0');MultiByteToWideChar(936,0,source.constData(),int(source.size()),text.data(),wide);
        source=QString::fromWCharArray(text.data(),wide).toUtf8();
    }
    // Lua 5.4 rejects non-ASCII identifiers. Rename them outside strings and comments only.
    QByteArray out;out.reserve(source.size()+256);
    const auto *s=source.constData();const qsizetype n=source.size();qsizetype i=0;
    auto ident=[](unsigned char c){return std::isalnum(c)||c=='_'||c>=0x80;};
    auto longBracket=[&](qsizetype at,int &level){
        if(at>=n||s[at]!='[')return false;
        qsizetype j=at+1;level=0;while(j<n&&s[j]=='='){++level;++j;}
        return j<n&&s[j]=='[';
    };
    auto skipLong=[&](qsizetype at,int level){
        QByteArray close="]"+QByteArray(level,'=')+"]";const auto end=source.indexOf(close,at);return end<0?n:end+close.size();
    };
    while(i<n){
        const unsigned char c=static_cast<unsigned char>(s[i]);int level=0;
        if(c=='-'&&i+1<n&&s[i+1]=='-'){
            qsizetype end;if(longBracket(i+2,level))end=skipLong(i+2,level);else{end=source.indexOf('\n',i);if(end<0)end=n;}
            out.append(s+i,end-i);i=end;continue;
        }
        if(c=='['&&longBracket(i,level)){const auto end=skipLong(i,level);out.append(s+i,end-i);i=end;continue;}
        if(c=='"'||c=='\''){
            qsizetype j=i+1;while(j<n&&s[j]!=char(c)&&s[j]!='\n'){if(s[j]=='\\')++j;++j;}
            j=std::min(n,j+1);out.append(s+i,j-i);i=j;continue;
        }
        if(std::isdigit(c)){qsizetype j=i;while(j<n&&(ident(static_cast<unsigned char>(s[j]))||s[j]=='.'||((s[j]=='+'||s[j]=='-')&&(s[j-1]=='e'||s[j-1]=='E'||s[j-1]=='p'||s[j-1]=='P'))))++j;out.append(s+i,j-i);i=j;continue;}
        if(ident(c)){
            qsizetype j=i;bool wide=false;while(j<n&&ident(static_cast<unsigned char>(s[j]))){wide|=static_cast<unsigned char>(s[j])>=0x80;++j;}
            const QByteArray name(s+i,j-i);out.append(wide?mangle(name):name);i=j;continue;
        }
        out.append(char(c));++i;
    }
    return out;
}
struct LegacyRunner::Impl {
    lua_State *main=nullptr,*thread=nullptr;size_t bytes=0,limit=16*1024*1024;
    qint64 now=0,last=-1,wake=0;int remaining=0;
    QElapsedTimer elapsed;LegacyRequest request;quint64 sequence=0;
    bool loaded=false,done=false,awaiting=false,delivered=false,delayed=false,compat=false;QString failure;
    QVariantList replies;QStringList messages;
    ~Impl(){if(main)lua_close(main);}
    static void *allocate(void *value,void *p,size_t old,size_t size){
        auto self=static_cast<Impl*>(value);if(!p)old=0;
        if(!size){std::free(p);self->bytes-=std::min(old,self->bytes);return nullptr;}
        if(size>old&&size-old>self->limit-self->bytes)return nullptr;
        void *next=std::realloc(p,size);if(next)self->bytes=self->bytes-old+size;return next;
    }
    static Impl *get(lua_State *L){return *static_cast<Impl**>(lua_getextraspace(L));}
    static void hook(lua_State *L,lua_Debug*){auto self=get(L);self->remaining-=1000;if(self->remaining<=0||self->elapsed.elapsed()>20)luaL_error(L,"Legacy Lua execution budget exceeded");}
    // Values supplied by acknowledge() are on the stack when the coroutine resumes.
    static int resume(lua_State *L,int,lua_KContext){return lua_gettop(L);}
    int yield(lua_State *L){awaiting=true;delivered=false;lua_settop(L,0);return lua_yieldk(L,0,0,resume);}
    static int sleep(lua_State *L){
        const auto delay=luaL_checkinteger(L,1);if(delay<0||delay>60000)return luaL_error(L,"Sleep must be 0..60000 ms");
        auto self=get(L);self->wake=self->now+delay;self->delayed=true;lua_settop(L,0);return lua_yieldk(L,0,0,resume);
    }
    static int gameCall(lua_State *L){
        size_t length=0;const auto bytes=luaL_checklstring(L,1,&length);
        const auto format=luaL_optstring(L,2,"");const auto results=luaL_optinteger(L,3,0);
        if(length>4096||format[0]||results!=0)return luaL_error(L,"Unsupported legacy result format");
        auto self=get(L);const auto source=QString::fromUtf8(bytes,qsizetype(length));
        LegacyRequest next;next.id=self->sequence+1;
        if(LegacyRunner::parseGameCall(source,next.command,next.argument))next.kind=LegacyRequest::Game;
        else if(self->compat&&LegacyRunner::parseScriptCall(source,next.snippet,next.args))next.kind=LegacyRequest::Snippet;
        else return luaL_error(L,"Game call is not in the current adapter batch");
        ++self->sequence;self->request=next;return self->yield(L);
    }
    static int close(lua_State *L){
        const auto name=luaL_checkstring(L,1);if(std::strcmp(name,"Fuli_MonthlySign"))return luaL_error(L,"Window is not supported by this batch");
        auto self=get(L);self->request=LegacyRequest{};self->request.id=++self->sequence;self->request.command=gameplay::CloseMonthly;return self->yield(L);
    }
    static int tick(lua_State *L){lua_pushinteger(L,get(L)->now);return 1;}
    static int game(lua_State *L){
        auto self=get(L);LegacyRequest next;next.kind=LegacyRequest::Snippet;
        const auto id=luaL_checkinteger(L,1);if(id<1||id>gameplay::SnippetLast)return luaL_error(L,"Unknown game snippet");
        next.snippet=uint32_t(id);
        for(int t=2;t<=3;++t){if(lua_isnoneornil(L,t))continue;luaL_checktype(L,t,LUA_TTABLE);
            for(int k=1;k<=(t==2?4:3);++k){lua_rawgeti(L,t,k);if(!lua_isnil(L,-1)){
                const auto v=luaL_checknumber(L,-1);if(!std::isfinite(v))return luaL_error(L,"Snippet number is not finite");
                if(t==2){if(v!=std::floor(v)||std::abs(v)>1e7)return luaL_error(L,"Snippet integer out of range");next.args.ints[k-1]=int32_t(v);}else next.args.reals[k-1]=v;}
                lua_pop(L,1);}}
        if(!lua_isnoneornil(L,4)){size_t length=0;const auto text=luaL_checklstring(L,4,&length);
            const auto wide=QString::fromUtf8(text,qsizetype(length));if(wide.size()>47)return luaL_error(L,"Snippet text longer than 47 characters");
            wide.toWCharArray(next.args.text);next.args.text[wide.size()]=0;}
        if(!gameplay::validSnippet(next.snippet,next.args))return luaL_error(L,"Snippet arguments rejected: %d",int(id));
        next.id=++self->sequence;self->request=next;return self->yield(L);
    }
    static int host(lua_State *L){
        const QString op=QString::fromUtf8(luaL_checkstring(L,1));
        if(op!="position"&&op!="alert"&&op!="stop_motion"&&op!="combat_result")return luaL_error(L,"Unknown host request");
        auto self=get(L);LegacyRequest next;next.kind=LegacyRequest::Host;next.host=op;next.detail=QString::fromUtf8(luaL_optstring(L,2,"")).left(32);
        next.id=++self->sequence;self->request=next;return self->yield(L);
    }
    static int log(lua_State *L){
        auto self=get(L);size_t length=0;const auto text=luaL_tolstring(L,1,&length);
        if(self->messages.size()<200)self->messages<<QString::fromUtf8(text,qsizetype(std::min<size_t>(length,600))).left(200);
        lua_settop(L,0);return 0;
    }
    static int clock(lua_State *L){
        const auto now=QDateTime::currentDateTime();
        lua_pushinteger(L,now.toSecsSinceEpoch());lua_pushinteger(L,now.time().hour());lua_pushinteger(L,now.time().minute());lua_pushinteger(L,now.time().second());return 4;
    }
};
LegacyRunner::LegacyRunner():p_(std::make_unique<Impl>()){}
LegacyRunner::~LegacyRunner()=default;
size_t LegacyRunner::allocated()const{return p_->bytes;}
QStringList LegacyRunner::takeMessages(){auto out=p_->messages;p_->messages.clear();return out;}
bool LegacyRunner::load(const QString &path,QString &error,const QString &compatPrelude,const QJsonObject &settings){
    error.clear();p_=std::make_unique<Impl>();auto &s=*p_;s.compat=!compatPrelude.isEmpty();
    QFile file(BuiltinResources::path(path));if(!file.open(QIODevice::ReadOnly)||file.size()<1||file.size()>256*1024){error="旧 Lua 缺失或超过 256 KiB";return false;}
    QByteArray source=file.readAll(),prelude,dataChunk;
    if(s.compat){
        source=translateSource(source,error);if(!error.isEmpty())return false;
        QFile compat(BuiltinResources::path(compatPrelude));if(!compat.open(QIODevice::ReadOnly)||compat.size()<1||compat.size()>128*1024){error="兼容接口 compat.lua 缺失或过大";return false;}
        prelude=translateSource(compat.readAll(),error);if(!error.isEmpty())return false;
        // Keep resource-relative paths relative: absolutePath() resolves them
        // against the shell's working directory, not the application bundle.
        const auto compatDirectory=QFileInfo(compatPrelude).path();
        QFile combat(BuiltinResources::path(compatDirectory+"/combat.lua"));
        if(combat.exists()){
            if(!combat.open(QIODevice::ReadOnly)||combat.size()>64*1024){error="combat.lua 缺失或过大";return false;}
            prelude+='\n'+translateSource(combat.readAll(),error);if(!error.isEmpty())return false;
        }else if(settings.value("combat").toBool()){error="缺少 combat.lua";return false;}
        if(settings.value("legacy_id").toString()=="zhenlong_combat"){
            QFile dungeon(BuiltinResources::path(compatDirectory+"/dungeons/qiju.lua"));
            if(!dungeon.open(QIODevice::ReadOnly)||dungeon.size()>64*1024){error="棋局专用规则缺失";return false;}
            prelude+='\n'+translateSource(dungeon.readAll(),error);if(!error.isEmpty())return false;
        }
        if(settings.value("legacy_id").toString()=="tlzz_keju"){  // 科举题库（原程序 数据/科举.lua，约 0.9 MB）
            QFile bank(BuiltinResources::path(compatDirectory+"/data/keju_bank.lua"));
            if(!bank.open(QIODevice::ReadOnly)||bank.size()>2*1024*1024){error="科举题库缺失或过大";return false;}
            dataChunk=translateSource(bank.readAll(),error);if(!error.isEmpty())return false;
        }
    }
    s.main=lua_newstate(Impl::allocate,&s);if(!s.main){error="无法创建有界 Lua 状态";return false;}
    *static_cast<Impl**>(lua_getextraspace(s.main))=&s;
    for(auto library:{std::pair<const char*,lua_CFunction>{"_G",luaopen_base},{LUA_MATHLIBNAME,luaopen_math},{LUA_TABLIBNAME,luaopen_table},{LUA_STRLIBNAME,luaopen_string}}){luaL_requiref(s.main,library.first,library.second,1);lua_pop(s.main,1);}
    for(const char *name:{"dofile","loadfile","load","collectgarbage","print","pcall","xpcall"}){lua_pushnil(s.main);lua_setglobal(s.main,name);}
    for(auto api:{std::pair<const char*,lua_CFunction>{"Sleep",Impl::sleep},{"GetLuaValue",Impl::gameCall},{"CloseWindow",Impl::close}}){lua_pushcfunction(s.main,api.second);lua_setglobal(s.main,api.first);}
    if(s.compat){
        for(auto api:{std::pair<const char*,lua_CFunction>{"GetTickCount",Impl::tick},{"__game",Impl::game},{"__host",Impl::host},{"__log",Impl::log},{"__clock",Impl::clock}}){lua_pushcfunction(s.main,api.second);lua_setglobal(s.main,api.first);}
        lua_newtable(s.main);
        const auto &ids=legacyApiNames;
        for(const auto &id:ids){lua_pushinteger(s.main,id.second);lua_setfield(s.main,-2,id.first);}
        lua_newtable(s.main);for(int i=0;i<gameplay::count(gameplay::playerKeys);++i){lua_pushinteger(s.main,i);lua_setfield(s.main,-2,gameplay::playerKeys[i]);}
        lua_setfield(s.main,-2,"keys");
        lua_newtable(s.main);for(int i=0;i<gameplay::count(gameplay::uiCalls);++i){lua_pushinteger(s.main,i);lua_setfield(s.main,-2,gameplay::uiCalls[i].function);}
        lua_setfield(s.main,-2,"ui");
        lua_newtable(s.main);for(int i=0;i<gameplay::count(gameplay::closableWindows);++i){lua_pushinteger(s.main,i);lua_setfield(s.main,-2,gameplay::closableWindows[i]);}
        lua_setfield(s.main,-2,"windows");
        auto names=[&](const wchar_t *const *list,int n,const char *field){lua_newtable(s.main);
            for(int i=0;i<n;++i){lua_pushinteger(s.main,i);lua_setfield(s.main,-2,QString::fromWCharArray(list[i]).toUtf8().constData());}lua_setfield(s.main,-2,field);};
        names(gameplay::usableItems,gameplay::count(gameplay::usableItems),"items");names(gameplay::msgBoxTexts,gameplay::count(gameplay::msgBoxTexts),"msgbox");
        names(gameplay::wuhunTexts,gameplay::count(gameplay::wuhunTexts),"wuhun");names(gameplay::shopItems,gameplay::count(gameplay::shopItems),"shop");
        lua_newtable(s.main);for(int i=0;i<gameplay::count(gameplay::xzGifts);++i){lua_pushinteger(s.main,i);lua_setfield(s.main,-2,QString::fromWCharArray(gameplay::xzGifts[i].gift).toUtf8().constData());}
        lua_setfield(s.main,-2,"gifts");
        lua_setglobal(s.main,"__snippets");
        lua_newtable(s.main);
        for(auto it=settings.begin();it!=settings.end();++it){
            if(it.value().isString()){const auto bytes=it.value().toString().toUtf8();lua_pushlstring(s.main,bytes.constData(),size_t(bytes.size()));}
            else if(it.value().isBool())lua_pushboolean(s.main,it.value().toBool());
            else if(it.value().isDouble())lua_pushnumber(s.main,it.value().toDouble());else continue;
            lua_setfield(s.main,-2,it.key().toUtf8().constData());
        }
        lua_setglobal(s.main,"TaskConfig");
        // Built-in data tables (assignments only) load before the timed prelude; the allocator limit still applies.
        if(!dataChunk.isEmpty()&&(luaL_loadbufferx(s.main,dataChunk.constData(),size_t(dataChunk.size()),"=data","t")!=LUA_OK||lua_pcall(s.main,0,0,0)!=LUA_OK)){
            error="内置数据："+QString::fromUtf8(lua_tostring(s.main,-1)).left(300);return false;
        }
        s.remaining=2000000;s.elapsed.restart();lua_sethook(s.main,Impl::hook,LUA_MASKCOUNT,1000);
        if(luaL_loadbufferx(s.main,prelude.constData(),size_t(prelude.size()),"=compat","t")!=LUA_OK||lua_pcall(s.main,0,0,0)!=LUA_OK){
            error="compat.lua："+QString::fromUtf8(lua_tostring(s.main,-1)).left(300);return false;
        }
        lua_sethook(s.main,nullptr,0,0);
        // Chinese API names of the reference program map to ASCII functions defined by compat.lua.
        const std::pair<const char*,const char*> aliases[]={{"等待","__cn_wait"},{"等待到指定时间","__cn_wait_until"},{"等待队伍人数","__cn_wait_team"},
            {"输入屏幕文本","__cn_screen_text"},{"音乐报警","__cn_music_alarm"},{"闪烁窗口","__cn_flash_window"},{"跨图寻路","__cn_cross_map"},
            {"执行脚本","__cn_run_script"},{"下坐骑","__cn_unsupported"},{"使用物品","__cn_unsupported"},{"组队跟随","__cn_unsupported"},
            {"取消跟随","__cn_unsupported"},{"创建队伍","__cn_unsupported"},{"解散队伍","__cn_unsupported"},{"申请进组","__cn_unsupported"}};
        for(const auto &alias:aliases){lua_getglobal(s.main,alias.second);if(lua_isnil(s.main,-1)){error=QString("compat.lua 缺少 %1").arg(alias.second);return false;}lua_pushvalue(s.main,-1);lua_setglobal(s.main,mangle(alias.first).constData());lua_setglobal(s.main,alias.first);}
    }
    s.thread=lua_newthread(s.main);*static_cast<Impl**>(lua_getextraspace(s.thread))=&s;
    if(luaL_loadbufferx(s.thread,source.constData(),size_t(source.size()),s.compat?"=legacy":"legacy_daily_sign","t")!=LUA_OK){error=QString::fromUtf8(lua_tostring(s.thread,-1));return false;}
    s.loaded=true;return true;
}
LegacyRunner::Progress LegacyRunner::poll(qint64 now,LegacyRequest &request,QString &error){
    auto &s=*p_;error.clear();
    if(now<0||now<s.last)s.failure="脚本时钟倒退，已停止";
    s.last=now;s.now=now;
    if(!s.failure.isEmpty()){error=s.failure;return Failed;}
    if(!s.loaded){error="旧 Lua 尚未加载";return Failed;}
    if(s.done)return Finished;
    if(s.awaiting){if(s.delivered)return Waiting;s.delivered=true;request=s.request;return Action;}
    if(s.delayed&&now<s.wake)return Waiting;
    s.delayed=false;s.remaining=200000;s.elapsed.restart();lua_sethook(s.thread,Impl::hook,LUA_MASKCOUNT,1000);
    int arguments=0;
    if(lua_status(s.thread)==LUA_YIELD){
        if(!lua_checkstack(s.thread,8)){s.failure="脚本栈不足";error=s.failure;return Failed;}
        for(const auto &value:s.replies){
            if(value.typeId()==QMetaType::Bool)lua_pushboolean(s.thread,value.toBool());
            else if(value.typeId()==QMetaType::QString){const auto bytes=value.toString().toUtf8();lua_pushlstring(s.thread,bytes.constData(),size_t(bytes.size()));}
            else if(value.canConvert<double>()&&value.isValid()){const double v=value.toDouble();if(std::isfinite(v)&&v==std::floor(v)&&std::abs(v)<9e15)lua_pushinteger(s.thread,lua_Integer(v));else lua_pushnumber(s.thread,v);}
            else lua_pushnil(s.thread);
            ++arguments;
        }
    }
    s.replies.clear();
    int results=0;const int result=lua_resume(s.thread,s.main,arguments,&results);
    if(result==LUA_OK){s.done=true;return Finished;}
    if(result!=LUA_YIELD){const auto text=lua_tostring(s.thread,-1);s.failure=text?QString::fromUtf8(text).left(300):"Legacy Lua error";error=s.failure;return Failed;}
    if(s.awaiting){s.delivered=true;request=s.request;return Action;}
    return Waiting;
}
bool LegacyRunner::acknowledge(quint64 id,bool success,const QString &error,const QVariantList &values){
    auto &s=*p_;if(!s.awaiting||!s.delivered||id!=s.request.id)return false;
    if(!success)s.failure=error.isEmpty()?"游戏动作失败，脚本已停止":error;
    s.replies=values.mid(0,10);s.awaiting=false;s.delivered=false;return true;
}
bool resolveLegacyEntry(const QString &directory,const QString &id,QJsonObject &entry,QString &path,QString &error){
    entry={};path.clear();error.clear();
    QFile f(BuiltinResources::path(directory+"/manifest.json"));
    if(!f.open(QIODevice::ReadOnly)||f.size()>1024*1024){error="内置任务清单不可读";return false;}
    const auto tasks=QJsonDocument::fromJson(f.readAll()).object().value("tasks").toArray();
    if(tasks.isEmpty()||tasks.size()>512){error="内置任务清单无效";return false;}
    int found=0;for(const auto &v:tasks)if(v.toObject().value("id").toString()==id){entry=v.toObject();++found;}
    if(found==1&&entry.value("runtime_enabled")!=QJsonValue(false))path=BuiltinResources::child(directory,entry.value("entry").toString());
    if(path.isEmpty()||!path.endsWith(".lua")){entry={};error="任务清单没有可执行入口，或入口路径无效";return false;}
    return true;
}
// A rewritten task whose setting run_original_source is on runs its original script instead:
// the manifest's original_alternative replaces the entry with the generic original-source adapter.
bool applyOriginalSourceChoice(const QString &directory,const QJsonObject &config,QJsonObject &entry,QString &path,QString &error){
    error.clear();if(!config.value("run_original_source").toBool())return true;
    const auto alternative=entry.value("original_alternative").toObject();
    if(alternative.isEmpty()){error="此任务没有可替换的原脚本";return false;}
    const auto generic=BuiltinResources::child(directory,"original/generic_task.lua");
    if(generic.isEmpty()){error="通用原脚本入口缺失";return false;}
    for(auto i=alternative.begin();i!=alternative.end();++i)entry.insert(i.key(),i.value());
    entry.insert("adapter","original_generic_v1");entry.insert("entry","original/generic_task.lua");entry.insert("requires_resident",true);
    entry.insert("rewritten_task",true);entry.remove("original_alternative");path=generic;return true;
}
QJsonObject legacyDefaults(QJsonObject config){
    if(config.value("legacy_id").toString()=="zhenlong_combat"){
        if(!config.contains("rule_source"))config.insert("rule_source",config.value("engine").toString()=="外部兼容"?"兼容重建":"原规则");
        if(!config.contains("original_quick_mode"))config.insert("original_quick_mode",false);
        if(!config.contains("original_team_count"))config.insert("original_team_count",3);
        if(!config.contains("combat_scene")||config.value("combat_scene").toInt()==3)config.insert("combat_scene",61);
        config.insert("original_bindings",QJsonObject{{"ZH/xzk190","original_quick_mode"}});
    }
    return config;
}
bool validateLegacyConfig(const QJsonObject &input,QString &error){
    const auto config=legacyDefaults(input);
    for(const auto key:{"allow_spend","allow_transfer","allow_sell","allow_item","allow_offline"})if(config.contains(key)&&!config.value(key).isBool()){error="动作权限开关格式无效";return false;}
    if(config.contains("engine")&&config.value("engine").toString()!="游戏内 Lua"&&config.value("engine").toString()!="外部兼容"){error="执行引擎无效";return false;}
    const auto id=config.value("legacy_id").toString();const auto value=config.value("timeout_seconds");const double timeout=value.toDouble(-1);
    if(id.isEmpty()||id.size()>48||!QRegularExpression("^[a-z0-9_]+$").match(id).hasMatch()){error="原脚本任务标识无效";return false;}
    if(!value.isDouble()||!std::isfinite(timeout)||std::floor(timeout)!=timeout||timeout<10||timeout>7200){error="原脚本任务超时应为 10–7200 秒";return false;}
    QJsonObject declaredEntry;QString declaredPath;
    if(!resolveLegacyEntry("scripts/builtin/legacy",id,declaredEntry,declaredPath,error))return false;
    const auto engines=declaredEntry.value("supported_engines").toArray();
    const auto engine=config.value("engine").toString("游戏内 Lua");
    if(!engines.isEmpty()&&!engines.contains(engine)){error="此任务支持的执行引擎："+engines.first().toString()+"；请重新选择引擎或重新添加队列节点";return false;}
    if(declaredEntry.value("combat").toBool()!=config.value("combat").toBool()){error=id=="dungeon_002fbdb4"?"水牢已升级为完整战斗流程，请删除旧队列中的水牢节点并重新添加":"任务战斗能力与运行清单不符";return false;}
    if(declaredEntry.value("adapter")==QJsonValue("water_prison_v1")||declaredEntry.value("adapter")==QJsonValue("sijue_flow_v1")||declaredEntry.value("adapter")==QJsonValue("yanzi_flow_v1")||declaredEntry.value("adapter")==QJsonValue("shaoshi_flow_v1")||declaredEntry.value("adapter")==QJsonValue("piaomiao_flow_v1")||declaredEntry.value("adapter")==QJsonValue("langhuan_flow_v1")||declaredEntry.value("adapter")==QJsonValue("wangling_flow_v1")||declaredEntry.value("adapter")==QJsonValue("sanshen_flow_v1")||declaredEntry.value("adapter")==QJsonValue("guanshan_flow_v1")||declaredEntry.value("adapter")==QJsonValue("mingwang_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_team_count",3,6},{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto key=std::get<0>(spec);const auto v=config.value(key);const auto n=v.toDouble(-1);
            if(!v.isDouble()||!std::isfinite(n)||std::floor(n)!=n||n<std::get<1>(spec)||n>std::get<2>(spec)){error=declaredEntry.value("name").toString()+"参数无效："+QString::fromLatin1(key)+"；旧队列请重新添加本项";return false;}
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("yanzi_flow_v1")){
        if(!QStringList{"普通","初级","中级","高级"}.contains(config.value("yzw_type").toString())
            ||!config.value("yanzi_kill_wyy").isBool()||!config.value("yanzi_supplies").isBool()||!config.value("yanzi_loot").isBool()){
            error="燕子坞配置已更新：请选择难度和副本功能；旧队列请重新添加本项";return false;
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("cuju_flow_v1")||declaredEntry.value("adapter")==QJsonValue("shuaxiang_flow_v1")||declaredEntry.value("adapter")==QJsonValue("tianlong_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="任务配置已更新；旧队列请重新添加本项";return false;}
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("tianjiang_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"tianjiang_search_minutes",1,120}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="天降奇兽配置已更新；旧队列请重新添加本项";return false;}
        }
        if(!config.value("tianjiang_loot").isBool()){error="天降奇兽配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("suyuan_flow_v1")||declaredEntry.value("adapter")==QJsonValue("chuhan_flow_v1")||declaredEntry.value("adapter")==QJsonValue("xiaoaci_flow_v1")||declaredEntry.value("adapter")==QJsonValue("xiakexing_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="任务配置已更新；旧队列请重新添加本项";return false;}
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("nixi_flow_v1")){
        const auto minutes=config.value("nixi_minutes").toDouble(-1);
        if(minutes<1||minutes>600||std::floor(minutes)!=minutes){error="逆袭配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("saodang_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_wait_seconds",5,180},{"saodang_minutes",1,120}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="扫荡副本配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"xzk131","xzk266","xzk274","xzk272","xzk279","xzk278","xzk275","xzk277","xzk276","xzk290"})if(!config.value(key).isBool()){error="扫荡副本配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("songliao_flow_v1")||declaredEntry.value("adapter")==QJsonValue("chongwu_flow_v1")||declaredEntry.value("adapter")==QJsonValue("shijian_flow_v1")||declaredEntry.value("adapter")==QJsonValue("fanzei_flow_v1")||declaredEntry.value("adapter")==QJsonValue("xiaoxiao_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="任务配置已更新；旧队列请重新添加本项";return false;}
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("songliao_flow_v1")){
        for(const auto key:{"songliao_leave_team","songliao_claim"})if(!config.value(key).isBool()){error="宋辽配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("fanzei_flow_v1")){
        const auto sel=config.value("zhk43").toDouble(-1);
        if(sel<0||sel>5||std::floor(sel)!=sel){error="贼兵入侵配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("jiaxue_flow_v1")||declaredEntry.value("adapter")==QJsonValue("tuanzhan_flow_v1")){
        const auto minutes=config.value(declaredEntry.value("adapter")==QJsonValue("jiaxue_flow_v1")?"jiaxue_minutes":"tuanzhan_minutes").toDouble(-1);
        const auto distance=config.value("bjk38").toDouble(-1);
        if(minutes<1||minutes>115||std::floor(minutes)!=minutes||distance<1||distance>30||std::floor(distance)!=distance){error="任务配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("shimen_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"bjk29",1,60},{"dungeon_wait_seconds",5,180},{"shimen_minutes",1,115}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="师门任务配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"shimen_abandon","shimen_tjqq","xzk56","xzk187"})if(!config.value(key).isBool()){error="师门任务配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("mazei_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"mazei_minutes",1,115},{"bjk91",0,20},{"dungeon_team_count",1,6}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="刷马贼配置已更新；旧队列请重新添加本项";return false;}
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("zhuxian_flow_v1")||declaredEntry.value("adapter")==QJsonValue("xinshou_flow_v1")){
        const auto main=declaredEntry.value("adapter")==QJsonValue("zhuxian_flow_v1");
        const auto minutes=config.value(main?"zhuxian_minutes":"xinshou_minutes").toDouble(-1);
        if(minutes<1||minutes>115||std::floor(minutes)!=minutes){error="任务配置已更新；旧队列请重新添加本项";return false;}
        if(!main){const auto level=config.value("xinshou_level").toDouble(-1);if(level<1||level>40||std::floor(level)!=level){error="新手任务配置已更新；旧队列请重新添加本项";return false;}}
    }
    if(config.contains("revive_mode")&&!QStringList{"停止","等待救援","等待后出窍回城"}.contains(config.value("revive_mode").toString())){error="死亡处理设置无效";return false;}
    if(declaredEntry.value("adapter")==QJsonValue("short_flow_v1")&&config.contains("short_minutes")){
        const auto minutes=config.value("short_minutes").toDouble(-1);
        if(minutes<1||minutes>115||std::floor(minutes)!=minutes){error="任务配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("juling_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_team_count",1,6},{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="聚灵谷配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"不打雷锁","不打小怪"})if(!config.value(QString::fromUtf8(key)).isBool()){error="聚灵谷配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("yijue_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="弈决山河配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"yijue_leave_team","yijue_claim"})if(!config.value(key).isBool()){error="弈决山河配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("fenghuang_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"count_fhlm",0,24},{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="凤凰陵墓配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"fhlm_use_items","fhlm_loot","fhlm_claim"})if(!config.value(key).isBool()){error="凤凰陵墓配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("tianbo_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_team_count",7,12},{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="夜探天波府配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"xzk118","tianbo_loot"})if(!config.value(key).isBool()){error="夜探天波府配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("yezhu_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_team_count",1,6},{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto number=config.value(std::get<0>(spec)).toDouble(-1);
            if(number<std::get<1>(spec)||number>std::get<2>(spec)||std::floor(number)!=number){error="野猪任务配置已更新；旧队列请重新添加本项";return false;}
        }
        for(const auto key:{"yezhu_loot","yezhu_leave_map"})if(!config.value(key).isBool()){error="野猪任务配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("guanshan_flow_v1")){
        if(!QStringList{"最低","整五","最高"}.contains(config.value("guanshan_stage").toString())||!QStringList{"血最低","本人","不敲"}.contains(config.value("guanshan_muyu").toString())){error="观山海配置已更新：请选择挑战层数和敲木鱼分工；旧队列请重新添加本项";return false;}
        for(const auto key:{"guanshan_no_tjl","guanshan_xy_stay","guanshan_melee_boss","guanshan_reward_check","guanshan_claim"})if(!config.value(key).isBool()){error="观山海配置已更新；旧队列请重新添加本项";return false;}
        const auto layer=config.value("guanshan_leave_layer").toDouble(-1);if(layer<1||layer>100||std::floor(layer)!=layer){error="观山海离开层数应为 1–100";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("sanshen_flow_v1")){
        if(!config.value("小号模式").isBool()||!config.value("xzk87").isBool()||!config.value("xzk157").isBool()||!config.value("sanshen_loot").isBool()){error="三神幻境配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("wangling_flow_v1")){
        if(!config.value("小号模式").isBool()||!config.value("wangling_loot").isBool()){error="王陵配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("langhuan_flow_v1")){
        if((id=="langhuan"&&!QStringList{"普通","初级","中级","高级"}.contains(config.value("lhfd_type").toString()))||!config.value("xzk217").isBool()||!config.value("langhuan_loot").isBool()){
            error="琅嬛福地配置已更新：请选择难度和副本功能；旧队列请重新添加本项";return false;
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("bingsheng_flow_v1")){
        for(const auto &spec: {std::tuple<const char*,int,int>{"dungeon_team_count",7,12},{"dungeon_rounds",1,20},{"dungeon_wait_seconds",5,180},{"dungeon_battle_seconds",30,3600}}){
            const auto key=std::get<0>(spec);const auto v=config.value(key);const auto n=v.toDouble(-1);
            if(!v.isDouble()||!std::isfinite(n)||std::floor(n)!=n||n<std::get<1>(spec)||n>std::get<2>(spec)){error="兵圣奇阵参数无效："+QString::fromLatin1(key)+"；旧队列请重新添加本项";return false;}
        }
        if(!QStringList{"简单","困难"}.contains(config.value("bingsheng_mode").toString())||!QStringList{"按分队","萧如筠","萧如蔚"}.contains(config.value("bingsheng_twin").toString())){error="兵圣奇阵配置已更新：请选择模式和双子分工；旧队列请重新添加本项";return false;}
        for(const auto key:{"xzk260","xzk230","xzk199","xzk200","xzk201","xzk202","xzk203","xzk204","xzk232","xzk234","bingsheng_loot"})if(!config.value(key).isBool()){error="兵圣奇阵配置已更新；旧队列请重新添加本项";return false;}
    }
    if(declaredEntry.value("adapter")==QJsonValue("piaomiao_flow_v1")){
        if(!QStringList{"普通","初级","中级","高级"}.contains(config.value("dpmf_type").toString())
            ||!config.value("xzk158").isBool()||!config.value("xzk226").isBool()||!config.value("piaomiao_xiaohao").isBool()||!config.value("piaomiao_loot").isBool()){
            error="缥缈峰配置已更新：请选择难度和副本功能；旧队列请重新添加本项";return false;
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("shaoshi_flow_v1")){
        if(!QStringList{"普通","初级","中级","高级"}.contains(config.value("sss_type").toString())
            ||!config.value("xzk47").isBool()||!config.value("xzk189").isBool()||!config.value("shaoshi_loot").isBool()){
            error="少室山配置已更新：请选择难度和副本功能；旧队列请重新添加本项";return false;
        }
    }
    if(declaredEntry.value("adapter")==QJsonValue("sijue_flow_v1")){
        const auto clearance=config.value("sijue_trap_distance");const auto n=clearance.toDouble(-1);
        if(!QStringList{"普通","初级","中级","高级"}.contains(config.value("sjz_type").toString())||!QStringList{"队长","本角色","其他队友"}.contains(config.value("sijue_bell_role").toString())
            ||!config.value("sijue_diagonal").isBool()||!config.value("sijue_columns").isBool()||!config.value("sijue_blind_share").isBool()
            ||!clearance.isDouble()||!std::isfinite(n)||std::floor(n)!=n||n<2||n>10){
            error="四绝庄配置已更新：请选择难度、敲钟分工、失明分担及陷阱距离；旧队列请重新添加本项";return false;
        }
    }
    if(config.value("combat").toBool()){
        QJsonObject declaration;QString declaredPath;
        if(!resolveLegacyEntry("scripts/builtin/legacy",id,declaration,declaredPath,error)||!declaration.value("combat").toBool()){error="任务清单没有声明此任务的战斗能力";return false;}
        auto integer=[&](const char *key,int low,int high){const auto v=config.value(key);const double n=v.toDouble(-1);return v.isDouble()&&std::isfinite(n)&&n==std::floor(n)&&n>=low&&n<=high;};
        if(!config.value("combat").toBool()||!integer("combat_scene",0,4095)||!integer("combat_radius",3,60)
            ||!integer("combat_min_hp",1,95)||!integer("combat_interval_ms",750,5000)||!integer("combat_stall_seconds",10,300)
            ||!integer("combat_kill_goal",1,500)) {error="战斗参数无效：检查场景、范围、血量、间隔、停滞与击杀数";return false;}
        const auto skills=config.value("combat_skills");const auto names=skills.toString().split(QRegularExpression("[,，\\r\\n]+"),Qt::SkipEmptyParts);
        if(!skills.isString()||skills.toString().size()>600||names.size()>12){error="最多配置 12 个技能";return false;}
        for(const auto &n:names)if(n.trimmed().isEmpty()||n.trimmed().size()>47||n.contains(QRegularExpression("[\\x00-\\x1f\\x7f]"))){error="技能名称无效";return false;}
        if(id=="zhenlong_combat"){
            if(config.value("combat_scene").toInt()!=61||(config.value("entry_mode").toString()!="自动入场"&&config.value("entry_mode").toString()!="已在副本")){error="棋局场景或入场方式无效";return false;}
            const auto source=config.value("rule_source").toString();
            if(source!="原规则"&&source!="兼容重建"){error="棋局规则来源无效";return false;}
            if(source=="原规则"&&config.value("engine").toString()=="外部兼容"){error="原棋局规则需要游戏内 Lua；外部兼容请选择兼容重建";return false;}
            if(!integer("original_team_count",3,6)||!config.value("original_quick_mode").isBool()){error="原规则人数或快速入场参数无效";return false;}
        }
        if(config.contains("battle_system")){
            const auto v=config.value("battle_system");const auto b=v.toObject();
            if(!v.isObject()){error="战斗维护配置必须是对象";return false;}
            if(b.value("enabled").toBool()&&config.value("engine").toString()=="外部兼容"){error="战斗维护需要游戏内 Lua";return false;}
            for(const auto key:{"enabled","heal_enabled","heal_only","buff_enabled","pet","pet_feed","emei_enabled","emei_attack","emei_team_heal"})if(b.contains(key)&&!b.value(key).isBool()){error="战斗开关格式无效";return false;}
            if(b.value("emei_enabled").toBool()&&!b.value("enabled").toBool(true)){error="峨嵋策略需要启用战斗维护";return false;}
            for(const auto key:{"heal_percent","mp_percent","pet_feed_percent","pet_stop_percent","pet_sacrifice_min_percent","emei_heal_percent","emei_self_priority_percent"})if(b.contains(key)){
                const auto v=b.value(key);const auto n=v.toDouble(-1);if(!v.isDouble()||!std::isfinite(n)||n!=std::floor(n)||n<1||n>95){error="战斗恢复阈值应为 1–95%";return false;}}
            if(b.value("pet_feed").toBool()&&b.value("pet_feed_percent").toInt(50)<=b.value("pet_stop_percent").toInt(20)){error="珍兽喂养阈值必须高于停止阈值";return false;}
            if(b.value("emei_enabled").toBool()&&b.value("emei_self_priority_percent").toInt(35)>b.value("emei_heal_percent").toInt(75)){error="峨嵋优先自保血量不能高于治疗触发血量";return false;}
            if(b.contains("buff_interval_seconds")){const auto n=b.value("buff_interval_seconds").toDouble(-1);if(n<10||n>600||std::floor(n)!=n){error="增益间隔应为 10–600 秒";return false;}}
            for(const auto key:{"heal_skills","buff_skills","pet_skills","pet_hp_skills","pet_mp_skills","emei_heal_skills"})if(b.contains(key)){
                const auto v=b.value(key);const auto list=v.toString().split(QRegularExpression("[,，\\r\\n]+"),Qt::SkipEmptyParts);
                if(!v.isString()||v.toString().size()>600||list.size()>12){error="每组技能最多 12 项、600 字符";return false;}
                for(const auto &n:list)if(n.trimmed().size()>47||n.contains(QRegularExpression("[\\x00-\\x1f\\x7f]"))){error="恢复技能名称无效";return false;}
            }
        }
    }else if(config.value("combat").toBool()){error="此任务不支持战斗配置";return false;}
    if(config.value("engine").toString()=="外部兼容"){
        QJsonObject declaration;QString path,lookupError;
        if(resolveLegacyEntry("scripts/builtin/legacy",id,declaration,path,lookupError)&&declaration.value("requires_resident").toBool()){error="该任务直接运行原 Lua，请选择游戏内 Lua";return false;}
    }
    if(id=="battle_inspect"&&config.value("engine").toString()=="外部兼容"){error="技能读取需要游戏内 Lua";return false;}
    if(config.contains("run_original_source")){
        if(!config.value("run_original_source").isBool()){error="“用原脚本源码执行”开关格式无效";return false;}
        if(config.value("run_original_source").toBool()){
            if(!declaredEntry.contains("original_alternative")){error="此任务没有可替换的原脚本";return false;}
            if(config.value("engine").toString()=="外部兼容"){error="用原脚本源码执行需要游戏内 Lua";return false;}
        }
    }
    error.clear();return true;
}
}
