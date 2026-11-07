#include "resident_client.hpp"
#include "builtin_resources.hpp"
#include <QJsonDocument>
#include "core.hpp"
#include "live_layout.hpp"
#include "login_protocol.hpp"
#include "legacy_runner.hpp"
#include "original_library.hpp"
#include "legacy_api_names.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDateTime>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QRandomGenerator>
#include <QRegularExpression>
#include <QSet>
#include <cstring>
extern "C" {
#include <lauxlib.h>
#include <lualib.h>
}
namespace tlbb {
// Generic original tasks: the task chunk plus the framework modules its manifest entry lists, compiled from original-source.
static bool genericRuleChunks(const QString &directory,const QJsonObject &entry,QJsonObject &chunks,QJsonObject &names,QString &error){
    chunks={};names={};const auto index=originalLibraryIndex(directory,error);if(!error.isEmpty())return false;
    QJsonObject byToken,byName;auto modules=index.value("modules").toArray();for(const auto &v:index.value("custom_sources").toArray())modules.append(v);
    for(const auto &v:modules){const auto m=v.toObject();byToken.insert(m.value("token").toString(),m);byName.insert(m.value("name").toString(),m);}
    QList<QJsonObject> wanted{byToken.value(entry.value("original_token").toString()).toObject()};
    for(const auto &v:entry.value("framework").toArray())wanted.append(byName.value(v.toString()).toObject());
    // Method modules load on demand (original_generic_host): this program's Player/Bag/... tables hide them from discovery.
    for(const auto name:{"player","target","pet","team","skill"})if(byName.contains(name))wanted.append(byName.value(name).toObject()); // bag (99 KB) only when listed
    if(wanted.size()>48){error="原脚本框架模块超过 48 个";return false;}
    qsizetype total=0;
    for(const auto &m:wanted){
        if(m.isEmpty()){error="原 Lua 模块不存在：通用任务依赖缺失";return false;}
        const auto token=m.value("token").toString();if(chunks.contains(token))continue;
        QByteArray data;if(!originalSourceChunk(directory,token,data,error))return false;
        total+=data.size();if(total>1200*1024){error="原脚本及其框架模块超过 1.2 MiB";return false;}
        chunks.insert(token,QString::fromLatin1(data.toBase64()));names.insert(m.value("name").toString(),token);
    }
    return true;
}
struct ResidentChannel::Impl {
    ProcessBinding binding;HMODULE library=nullptr;HOOKPROC hook=nullptr;HWND window=nullptr;DWORD thread=0;
    HANDLE mapping=nullptr;resident::Packet *packet=nullptr;uint64_t nonce=0,session=0;bool started=false,inFlight=false;
    ~Impl(){if(packet)UnmapViewOfFile(packet);if(mapping)CloseHandle(mapping);if(library)FreeLibrary(library);}
};
ResidentChannel::ResidentChannel():p_(std::make_unique<Impl>()){}
ResidentChannel::~ResidentChannel(){if(p_->started&&p_->binding.alive()){QJsonObject s;QString e;command(resident::Stop,s,e);}}
bool ResidentChannel::open(quint32 pid,const QString &created,const QString &root,QString &error){
    auto &p=*p_;if(p.packet){error="Resident channel is already open";return false;}
    if(!p.binding.open(pid,root,created)){error=p.binding.error;return false;}
    auto hash=[](const QString &path,const char *expected){QFile f(BuiltinResources::path(QDir::cleanPath(path)));if(!f.open(QIODevice::ReadOnly))return false;QCryptographicHash h(QCryptographicHash::Sha256);return h.addData(&f)&&h.result().toHex()==expected;};
    if(!hash(p.binding.info().path,live::imageSha256)||!hash(root+"/Bin64/LuaPlus.dll",login::luaPlusSha256)||!hash(root+"/Bin64/CEGUIBase.dll",login::ceguiSha256)){error="Resident engine: unsupported game/SDK version";return false;}
    for(const auto &g:discoverGames(root))if(g.pid==pid&&g.created==created)p.window=reinterpret_cast<HWND>(g.window);
    DWORD owner=0;p.thread=GetWindowThreadProcessId(p.window,&owner);if(owner!=pid||!p.thread){error="Game window identity is unavailable";return false;}
    const auto path=QDir::toNativeSeparators(QCoreApplication::applicationDirPath()+"/TLBBEngine.dll");
    p.library=LoadLibraryExW(reinterpret_cast<LPCWSTR>(path.utf16()),nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if(!p.library){error="Missing TLBBEngine.dll";return false;}auto symbol=GetProcAddress(p.library,"TlbbResidentHook");std::memcpy(&p.hook,&symbol,sizeof(symbol));
    if(!p.hook){error="Resident engine entry missing";return false;}
    p.nonce=QRandomGenerator::system()->generate64();p.session=QRandomGenerator::system()->generate64();wchar_t name[128]{};resident::mappingName(name,pid,p.nonce);
    p.mapping=CreateFileMappingW(INVALID_HANDLE_VALUE,nullptr,PAGE_READWRITE,0,sizeof(resident::Packet),name);
    if(!p.mapping||GetLastError()==ERROR_ALREADY_EXISTS){error="Cannot allocate resident control channel";return false;}
    p.packet=static_cast<resident::Packet*>(MapViewOfFile(p.mapping,FILE_MAP_READ|FILE_MAP_WRITE,0,0,sizeof(resident::Packet)));
    if(!p.packet){error="Cannot map resident control channel";return false;}
    new(p.packet)resident::Packet();error.clear();return true;
}
bool ResidentChannel::exchange(resident::Command command,QJsonObject &state,QString &error){
    auto &p=*p_;state={};if(!p.packet||!p.binding.alive()){error="Game exited or resident channel unavailable";return false;}
    if(p.inFlight&&p.packet->status==1){error="Previous resident request is still executing; no command was resubmitted";return false;}
    DWORD owner=0;if(GetWindowThreadProcessId(p.window,&owner)!=p.thread||owner!=p.binding.info().pid){error="Game window changed";return false;}
    auto &packet=*p.packet;packet.command=command;packet.targetPid=owner;packet.ownerPid=GetCurrentProcessId();packet.targetThread=p.thread;
    packet.created=p.binding.info().created.toULongLong();packet.nonce=p.nonce;packet.session=p.session;packet.expires=GetTickCount64()+2500;
    packet.error[0]=packet.log[0]=0;p.inFlight=true;InterlockedExchange(&packet.status,0);
    const auto h=SetWindowsHookExW(WH_GETMESSAGE,p.hook,p.library,p.thread);const auto message=RegisterWindowMessageW(resident::messageName);
    const bool posted=h&&message&&PostMessageW(p.window,message,owner,LPARAM(p.nonce));QElapsedTimer timer;timer.start();
    while(posted&&packet.status<2&&timer.elapsed()<3000&&p.binding.alive())Sleep(1);
    if(h)UnhookWindowsHookEx(h);
    const bool ok=packet.status==2&&packet.executedThread==p.thread;
    if(!ok){InterlockedCompareExchange(&packet.status,4,0);error=packet.error[0]?QString::fromUtf8(packet.error):"Resident request result is uncertain; it will not be replayed";return false;}
    state={{"state",int(packet.state)},{"lua_bytes",double(packet.luaBytes)},{"calls",double(packet.nativeCalls)},{"raw_calls",double(packet.rawCalls)},
        {"ticks",double(packet.ticks)},{"kills",int(packet.kills)},{"boss",bool(packet.boss)},{"ipc_requests",int(packet.ipcRequests)},
        {"battle",QJsonDocument::fromJson(QByteArray(packet.battle)).object()},{"error",QString::fromUtf8(packet.error)},{"log",QString::fromUtf8(packet.log)}};
    p.inFlight=false;
    if(command==resident::Stop||packet.state>=4)p.started=false;
    error.clear();return true;
}
bool ResidentChannel::start(const QByteArray &source,const QJsonObject &config,QJsonObject &state,QString &error){
    if(!p_->packet||source.isEmpty()||source.size()>=qsizetype(resident::payloadCapacity)){error="Resident task exceeds 2 MiB";return false;}
    auto &p=*p_->packet;p.sourceBytes=uint32_t(source.size());std::memcpy(p.source,source.constData(),size_t(source.size()));
    p.timeoutSeconds=uint32_t(config.value("timeout_seconds").toInt(600));p.allowFlags=(config.value("allow_spend").toBool()?1:0)|(config.value("allow_transfer").toBool()?2:0)|(config.value("allow_offline").toBool()?4:0)|(config.value("legacy_id").toString()=="battle_inspect"?8:0)|(config.value("allow_sell").toBool()?16:0)|(config.value("allow_item").toBool()?32:0);p.combat=config.value("combat").toBool();
    const bool ok=exchange(resident::Start,state,error);p_->started=ok&&p_->packet->state<4;return ok;
}
bool ResidentChannel::command(resident::Command cmd,QJsonObject &state,QString &error){return exchange(cmd,state,error);}
static QByteArray quoteLua(const QString &text){
    QByteArray out="\"";for(const unsigned char c:text.toUtf8()){
        if(c=='"'||c=='\\'){out+='\\';out+=char(c);}else if(c<32||c==127){out+='\\';out+=QByteArray::number(c).rightJustified(3,'0');}else out+=char(c);
    }return out+'"';
}
static QByteArray literal(const QJsonValue &v){
    if(v.isNull()||v.isUndefined())return "nil";
    if(v.isString())return quoteLua(v.toString());
    if(v.isBool())return v.toBool()?"true":"false";
    if(v.isDouble())return QByteArray::number(v.toDouble(),'g',16);
    QByteArray out="{";if(v.isArray()){for(const auto &item:v.toArray())out+=literal(item)+',';}
    else if(v.isObject()){const auto o=v.toObject();for(auto i=o.begin();i!=o.end();++i)out+='['+quoteLua(i.key())+"]="+literal(i.value())+',';}
    return out+'}';
}
QByteArray prepareResidentScript(const QString &directory,const QString &entry,const QJsonObject &config,QString &error){
    error.clear();QJsonObject snippets,keys,ui,windows,items,msgbox;
    for(const auto &id:legacyApiNames)snippets.insert(id.first,id.second);
    for(int i=0;i<gameplay::count(gameplay::playerKeys);++i)keys.insert(gameplay::playerKeys[i],i);
    for(int i=0;i<gameplay::count(gameplay::uiCalls);++i)ui.insert(gameplay::uiCalls[i].function,i);
    for(int i=0;i<gameplay::count(gameplay::closableWindows);++i)windows.insert(gameplay::closableWindows[i],i);
    for(int i=0;i<gameplay::count(gameplay::usableItems);++i)items.insert(QString::fromWCharArray(gameplay::usableItems[i]),i);
    for(int i=0;i<gameplay::count(gameplay::msgBoxTexts);++i)msgbox.insert(QString::fromWCharArray(gameplay::msgBoxTexts[i]),i);
    snippets.insert("keys",keys);snippets.insert("ui",ui);snippets.insert("windows",windows);snippets.insert("items",items);snippets.insert("msgbox",msgbox);
    QByteArray source="__snippets="+literal(snippets)+"\nTaskConfig="+literal(legacyDefaults(config))+"\n";
    auto read=[&](const QString &path){QFile f(BuiltinResources::path(QDir::cleanPath(path)));if(!f.open(QIODevice::ReadOnly)||f.size()>256*1024){error="脚本缺失或过大："+QFileInfo(path).fileName();return QByteArray();}return LegacyRunner::translateSource(f.readAll(),error);};
    source+=read(directory+"/compat.lua")+'\n';if(!error.isEmpty())return {};
    source+=read(directory+"/task_lifecycle.lua")+'\n';if(!error.isEmpty())return {};
    source+=read(directory+"/combat.lua")+'\n';if(!error.isEmpty())return {};
    if(config.value("legacy_id").toString()=="zhenlong_combat"){source+=read(directory+"/dungeons/qiju.lua")+'\n';if(!error.isEmpty())return {};}
    source+=read(directory+"/resident.lua")+'\n';if(!error.isEmpty())return {};
    const std::pair<const char*,const char*> aliases[]={{"等待","__cn_wait"},{"等待到指定时间","__cn_wait_until"},{"等待队伍人数","__cn_wait_team"},
        {"输入屏幕文本","__cn_screen_text"},{"音乐报警","__cn_music_alarm"},{"闪烁窗口","__cn_flash_window"},{"跨图寻路","__cn_cross_map"},
        {"执行脚本","__cn_run_script"},{"下坐骑","__cn_unsupported"},{"使用物品","__cn_unsupported"},{"组队跟随","__cn_unsupported"},
        {"取消跟随","__cn_unsupported"},{"创建队伍","__cn_unsupported"},{"解散队伍","__cn_unsupported"},{"申请进组","__cn_unsupported"}};
    // Renamed spelling for translated scripts; the real name for original-source copies (_ENV["等待"]).
    for(const auto &a:aliases)source+=LegacyRunner::mangle(a.first)+'='+a.second+"\n_ENV["+quoteLua(QString::fromUtf8(a.first))+"]="+a.second+'\n';
    // Every task's payload carries its modules, so a dungeon's own flow travels only with the tasks that load it.
    // Other modules stay always-present: some are loaded by computed names.
    static const QSet<QString> flowOnly{"shaoshi","piaomiao","bingsheng","langhuan","wangling","sanshen","guanshan","yezhu","mingwang","tianbo","fenghuang","yijue","juling","saodang","tianjiang","short_tasks","daily_tasks","jinzhen","shimen","mazei","quest_book","zhuxian","xinshou","songliao","chongwu","shijian","fanzei","xiaoxiao","jiaxue","tuanzhan","suyuan","chuhan","xiaoaci","xiakexing","nixi","cuju","shuaxiang","tianlong","dungeon_tactics","yanzi","yanzi_api","sijue","sijue_mechanisms"};
    QSet<QString> reachable;QStringList pending{entry};
    while(!pending.isEmpty()){
        QFile f(BuiltinResources::path(QDir::cleanPath(pending.takeLast())));if(!f.open(QIODevice::ReadOnly))continue;
        const auto text=QString::fromUtf8(f.readAll());
        auto loads=QRegularExpression("LoadScript\\(\\s*['\"](\\w+)['\"]").globalMatch(text);
        while(loads.hasNext()){const auto name=loads.next().captured(1);if(!reachable.contains(name)){reachable.insert(name);pending.append(directory+"/modules/"+name+".lua");}}
    }
    QJsonObject modules;QDir folder(directory+"/modules");
    for(const auto &name:BuiltinResources::files(directory+"/modules","*.lua")){if(modules.size()>=64){error="模块超过 64 个";return {};}
        const auto base=QFileInfo(name).completeBaseName();if(flowOnly.contains(base)&&!reachable.contains(base))continue;
        modules.insert(base,QString::fromUtf8(read(name)));if(!error.isEmpty())return {};}
    modules.insert("city_travel",QString::fromUtf8(read(directory+"/../navigation/city_travel.lua")));if(!error.isEmpty())return {};
    auto navigationJson=[&](const QString &p){QFile f(BuiltinResources::path(QDir::cleanPath(p)));if(!f.open(QIODevice::ReadOnly)||f.size()>128*1024){error="导航资料不可读或过大";return QJsonObject{};}auto o=QJsonDocument::fromJson(f.readAll()).object();if(o.isEmpty())error="导航资料格式无效";return o;};
    auto navigation=navigationJson(directory+"/../navigation/catalog.json");QJsonArray cities;
    for(const auto &v:navigation.value("city_files").toArray()){
        const auto path=v.toString();
        if(cities.size()>=128||!QRegularExpression("^cities/[a-z0-9_-]+\\.json$").match(path).hasMatch()){error="导航城市路径无效";return {};}
        cities.append(navigationJson(directory+"/../navigation/"+path));if(!error.isEmpty())return {};
    }
    if(!error.isEmpty())return {};
    navigation.insert("cities",cities);source+="NavigationCatalog="+literal(navigation)+'\n';
    source+="__resident_modules="+literal(modules)+'\n';
    QJsonObject declaration;QString declaredPath,lookupError;
    const bool resolved=resolveLegacyEntry(directory,config.value("legacy_id").toString(),declaration,declaredPath,lookupError);
    if(resolved&&!applyOriginalSourceChoice(directory,config,declaration,declaredPath,error))return {};
    if(resolved&&declaration.contains("original_token")){
        QJsonObject chunks,names;const auto adapter=declaration.value("adapter").toString();
        if(adapter=="original_generic_v1"){if(!genericRuleChunks(directory,declaration,chunks,names,error))return {};}
        else if(adapter!="original_archive_v1"||!originalRuleClosure(directory,declaration.value("original_token").toString(),chunks,names,error))return {};
        source+="__original_rules="+literal(chunks)+"\n__original_names="+literal(names)+'\n';
        QJsonObject data;static const QRegularExpression dataName("^[a-z_]{1,32}$");
        for(const auto &v:declaration.value("data_files").toArray()){
            const auto name=v.toString();if(!dataName.match(name).hasMatch()){error="原程序数据文件名无效："+name;return {};}
            const auto text=read(directory+"/data/"+name+".lua");if(!error.isEmpty())return {};
            data.insert(name,QString::fromUtf8(text));
        }
        source+="__original_data="+literal(data)+'\n';
        if(declaration.value("coord_files").toBool()){ // route files data\坐标\*.txt of the reference program
            QJsonObject coords;for(const auto &file:BuiltinResources::files(directory+"/data/coords","*.txt")){
                const auto text=read(file);if(!error.isEmpty())return {};coords.insert(QFileInfo(file).completeBaseName(),QString::fromUtf8(text));}
            if(coords.isEmpty()){error="原程序坐标文件缺失";return {};}
            source+="__original_coords="+literal(coords)+'\n';
        }
        QJsonObject shapes,defaults;
        QFile catalog(BuiltinResources::path("tasks/catalog.json"));
        if(catalog.open(QIODevice::ReadOnly))for(const auto &v:QJsonDocument::fromJson(catalog.readAll()).object().value("tasks").toArray()){
            const auto t=v.toObject();if(t.value("id")!=declaration.value("id"))continue;
            for(const auto &setting:t.value("settings").toArray()){const auto field=setting.toObject();QJsonArray options;
                for(const auto &choice:field.value("choices").toArray())options.append(choice.isObject()?QJsonValue(choice):QJsonValue(QJsonObject{{"text",choice},{"data",choice}}));
                if(!options.isEmpty())shapes.insert(field.value("key").toString(),QJsonObject{{"options",options}});
                if(field.contains("default"))defaults.insert(field.value("key").toString(),field.value("default"));
            }
        }
        // A setting missing from an older queue node, or left at an empty value the catalog no longer offers,
        // takes the catalog default instead of reaching the original script as nil/"" (少室山 难度 crashed on that).
        source+="for k,v in pairs("+literal(defaults)+") do local cur=TaskConfig[k] if cur==nil or (cur=='' and v~='') then TaskConfig[k]=v end end\n";
        declaration.insert("config_shapes",shapes);source+="__original_entry="+literal(declaration)+'\n';
    }
    if(declaration.value("validation_contract").toString()=="original_sweep_v1")source+="LoadScript('original_sweep_host')\n";
    source+="local function __task_entry()\n"+read(entry)+"\nend\nlocal __task_definition=__task_entry()\nif type(__task_definition)=='table' and __task_definition.run then RunTaskDefinition(__task_definition) end\n";
    if(source.size()>=qsizetype(resident::payloadCapacity)){error="任务及模块超过 2 MiB";return {};}return error.isEmpty()?source:QByteArray();
}
}
