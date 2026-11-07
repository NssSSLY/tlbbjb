#pragma once
#include "resident_client.hpp"
#include "resident_vm.hpp"
#include "native_controller.hpp"
#include "bridge_protocol.hpp"
#include "original_library.hpp"
#include <QFile>
#include <QCoreApplication>
#include <QDir>
#include <QProcess>
#include <QElapsedTimer>
#include <QJsonDocument>
#include <functional>
namespace tlbb {
struct ResidentFake:resident::Host {
    uint64_t evaluations=0;int casts=0,kills=0,boss=0,stops=0,scene=3;double x=64,y=64;bool low=false,uncertain=false;int entryScene=3;
    std::string logText;
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;using resident::Values;
        switch(id){
        case gameplay::CombatSkill:return {Value(3),Value(300),Value(0)};
        case gameplay::CombatName:return {Value(1),Value(0),Value(std::string("远古棋魂"))};
        case gameplay::CombatScan:return {Value(casts>=3&&a.ints[1]>=0?2:1),Value(10),Value(101),Value(casts>=3?0.0:1.0-casts*0.2),Value(65),Value(64),Value(1),Value(low?10:100)};
        case gameplay::CombatCast:++casts;if(uncertain)throw std::runtime_error("uncertain cast");return {Value(1)};
        case gameplay::PlayerData:return {Value(a.ints[0]==4&&low?10:100)};
        case gameplay::TeamCount:return {Value(3)};
        case gameplay::WindowVisible:return {Value(0)};
        case gameplay::BagSpace:return {Value(5)};
        case gameplay::DictText:return {Value(1),Value(QString::fromWCharArray(a.text).toStdString())};
        case gameplay::DebugMessages:return {Value(1),Value(std::string())};
        case gameplay::MissionFind:return {Value(-1),Value(-1),Value(-1)};
        case gameplay::PlayerState:case gameplay::Dismount:return {Value(0)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::TalkNpc:case gameplay::NpcTarget:return {Value(1)};
        case gameplay::QuestOptions:return {Value(1),Value(1)};
        case gameplay::QuestOption:{const auto name=QString::fromWCharArray(a.text);if(name=="珍珑棋局")scene=entryScene;if(name=="确定")scene=1;return {Value(1),Value(name.toStdString())};}
        default:throw std::runtime_error("Unexpected resident fixture snippet "+std::to_string(id));
        }
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string("苏州"))};
        if(op=="combat_result"){if(v=="kill")++kills;else if(v=="boss")++boss;return {};}
        if(op=="stop_motion"){++stops;return {};}
        if(op=="battle_self_identity")return {Value(5),Value(500)};
        if(op=="alert")return {};
        if(op=="mechanism_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="object_buff_ids")return {Value(0),Value(std::string())};
        throw std::runtime_error("Unknown fixture host call");
    }
    resident::Values evaluate(const std::string &code,const std::string&,int count)override{
        using resident::Value;++evaluations;
        if(code.find("Player:GetData")!=std::string::npos&&count==2)return {Value(100),Value(100)};
        if(code.find("Player:GetData")!=std::string::npos)return {Value(low&&code.find("MAXHP")==std::string::npos?10:100)};
        if(code=="echo")return {Value(double(evaluations)),Value(std::string("无白名单直调")),Value(),Value(true)};
        if(code=="many"){resident::Values values;for(int i=1;i<=32;++i)values.emplace_back(i);return values;}
        if(code=="throw")throw std::runtime_error("uncertain fixture call");
        if(code.find("generic:fight-pet-guid")!=std::string::npos)return {Value(-1),Value(-1)}; // no pet out
        if(code.find("generic:team-members")!=std::string::npos)return {Value(1),Value(QString::fromUtf8("0\t本人\t9001\t500\t5\t100\t100\t1\t2\t89\t12\t0\t0\n").toStdString())};
        if(count==1)return {Value(double(evaluations))};
        return {};
    }
    std::vector<resident::Object> objects()override{return {{10,101,65,64,100,true,"远古棋魂"},{11,102,66,64,100,false,"传送人"}};}
    void log(const std::string &text)override{logText+=text+'\n';}
};
template<class Test>void residentTests(const QString &root,const QString &temporary,Test test){
    auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
    auto finish=[](resident::Vm &vm,uint64_t limit=60000){for(uint64_t now=0;now<=limit&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);};
    // Startup diagnostics fail on any stop that is not one of these named, documented gaps (docs/FIX_CHECKLIST.md).
    // Every stop of an original-script task must be listed in tests/data/original-task-gaps.json as
    // "<task id>" (or "<task id>#原脚本" for a rewritten task's original-source mode) -> the exact gap text.
    // The sweep also fails on a listed gap that no longer happens, so a fix must remove its exception.
    QJsonObject gapFile;{QFile f(root+"/tests/data/original-task-gaps.json");if(f.open(QIODevice::ReadOnly))gapFile=QJsonDocument::fromJson(f.readAll()).object();}
    auto rowKey=[](const QJsonObject &r){return r.value("task").toString()+(r.value("alternative").toBool()?QString::fromUtf8("#原脚本"):QString());};
    auto onlyKnownGaps=[&](const QJsonArray &rows,const QString &section,bool requireCurrent=false){
        const auto gaps=gapFile.value(section).toObject();QStringList failures;
        for(const auto &v:rows){const auto r=v.toObject();const auto key=rowKey(r);
            auto error=r.value("error").toString()+r.value("preparation_error").toString()+r.value("start_error").toString();
            error.remove(QRegularExpression("(original_generic_host|task):\d+: ")); // positions shift with every edit
            const bool stopped=!error.isEmpty()||r.value("state").toInt()==resident::Vm::Failed;const auto gap=gaps.value(key).toString();
            if(stopped&&(gap.isEmpty()||!error.contains(gap)))failures<<key+" stopped outside its listed gap: "+error.section('\n',0,0).left(300);
            if(!stopped&&!gap.isEmpty()&&requireCurrent)failures<<key+" no longer stops at its listed gap (remove it from original-task-gaps.json): "+gap;
        }
        must(failures.isEmpty(),(QString::number(failures.size())+" unlisted/stale gaps:\n"+failures.join('\n')).toUtf8().constData());
    };
    test("resident_requested_dungeon_start_diagnostics",[&]{
        const auto entry=root+"/scripts/legacy/original/generic_task.lua";
        QJsonArray results;
        for(const auto &id:QStringList{"yanzi","sijue","shaoshi","piaomiao","dungeon_002b9e15","langhuan","dungeon_002fe064","bingsheng","sanshen","dungeon_002fd257","wangling","dungeon_0031db5f","dungeon_00322b14","dungeon_0032b023","orig_0034fff0","invasion","xiaoxiao","dungeon_0031c749","orig_002a9c1e"}){
            QString error;const QJsonObject config{{"legacy_id",id},{"combat",true},{"timeout_seconds",600}};
            QJsonObject declared;QString currentEntry;
            must(resolveLegacyEntry(root+"/scripts/legacy",id,declared,currentEntry,error),qPrintable(error));
            if(declared.value("adapter")==QJsonValue("sijue_flow_v1")||declared.value("adapter")==QJsonValue("yanzi_flow_v1")||declared.value("adapter")==QJsonValue("shaoshi_flow_v1")||declared.value("adapter")==QJsonValue("piaomiao_flow_v1")||declared.value("adapter")==QJsonValue("bingsheng_flow_v1")||declared.value("adapter")==QJsonValue("langhuan_flow_v1")||declared.value("adapter")==QJsonValue("wangling_flow_v1")||declared.value("adapter")==QJsonValue("sanshen_flow_v1")||declared.value("adapter")==QJsonValue("guanshan_flow_v1")||declared.value("adapter")==QJsonValue("mingwang_flow_v1")||declared.value("adapter")==QJsonValue("tianbo_flow_v1")||declared.value("adapter")==QJsonValue("fenghuang_flow_v1")||declared.value("adapter")==QJsonValue("yijue_flow_v1")||declared.value("adapter")==QJsonValue("juling_flow_v1")||declared.value("adapter")==QJsonValue("tianjiang_flow_v1")||declared.value("adapter")==QJsonValue("shimen_flow_v1")||declared.value("adapter")==QJsonValue("short_flow_v1")||declared.value("adapter")==QJsonValue("mazei_flow_v1")||declared.value("adapter")==QJsonValue("zhuxian_flow_v1")||declared.value("adapter")==QJsonValue("xinshou_flow_v1")||declared.value("adapter")==QJsonValue("songliao_flow_v1")||declared.value("adapter")==QJsonValue("chongwu_flow_v1")||declared.value("adapter")==QJsonValue("shijian_flow_v1")||declared.value("adapter")==QJsonValue("fanzei_flow_v1")||declared.value("adapter")==QJsonValue("xiaoxiao_flow_v1")||declared.value("adapter")==QJsonValue("jiaxue_flow_v1")||declared.value("adapter")==QJsonValue("tuanzhan_flow_v1")||declared.value("adapter")==QJsonValue("saodang_flow_v1")||declared.value("adapter")==QJsonValue("suyuan_flow_v1")||declared.value("adapter")==QJsonValue("chuhan_flow_v1")||declared.value("adapter")==QJsonValue("xiaoaci_flow_v1")||declared.value("adapter")==QJsonValue("xiakexing_flow_v1")||declared.value("adapter")==QJsonValue("nixi_flow_v1")||declared.value("adapter")==QJsonValue("cuju_flow_v1")||declared.value("adapter")==QJsonValue("shuaxiang_flow_v1")||declared.value("adapter")==QJsonValue("tianlong_flow_v1")||declared.value("adapter")==QJsonValue("yezhu_flow_v1")){
                results.append(QJsonObject{{"task",id},{"entry",declared.value("entry")},{"coverage_report",id=="yanzi"?"yanzi-tests.json":id=="shaoshi"?"shaoshi-tests.json":id=="piaomiao"?"piaomiao-tests.json":id=="bingsheng"?"bingsheng-tests.json":declared.value("adapter")==QJsonValue("langhuan_flow_v1")?"langhuan-tests.json":declared.value("adapter")==QJsonValue("wangling_flow_v1")?"wangling-tests.json":declared.value("adapter")==QJsonValue("sanshen_flow_v1")||declared.value("adapter")==QJsonValue("guanshan_flow_v1")||declared.value("adapter")==QJsonValue("mingwang_flow_v1")||declared.value("adapter")==QJsonValue("tianbo_flow_v1")||declared.value("adapter")==QJsonValue("fenghuang_flow_v1")||declared.value("adapter")==QJsonValue("yijue_flow_v1")||declared.value("adapter")==QJsonValue("juling_flow_v1")||declared.value("adapter")==QJsonValue("tianjiang_flow_v1")||declared.value("adapter")==QJsonValue("shimen_flow_v1")||declared.value("adapter")==QJsonValue("short_flow_v1")||declared.value("adapter")==QJsonValue("mazei_flow_v1")||declared.value("adapter")==QJsonValue("zhuxian_flow_v1")||declared.value("adapter")==QJsonValue("xinshou_flow_v1")||declared.value("adapter")==QJsonValue("songliao_flow_v1")||declared.value("adapter")==QJsonValue("chongwu_flow_v1")||declared.value("adapter")==QJsonValue("shijian_flow_v1")||declared.value("adapter")==QJsonValue("fanzei_flow_v1")||declared.value("adapter")==QJsonValue("xiaoxiao_flow_v1")||declared.value("adapter")==QJsonValue("jiaxue_flow_v1")||declared.value("adapter")==QJsonValue("tuanzhan_flow_v1")||declared.value("adapter")==QJsonValue("saodang_flow_v1")||declared.value("adapter")==QJsonValue("suyuan_flow_v1")||declared.value("adapter")==QJsonValue("chuhan_flow_v1")||declared.value("adapter")==QJsonValue("xiaoaci_flow_v1")||declared.value("adapter")==QJsonValue("xiakexing_flow_v1")||declared.value("adapter")==QJsonValue("nixi_flow_v1")||declared.value("adapter")==QJsonValue("cuju_flow_v1")||declared.value("adapter")==QJsonValue("shuaxiang_flow_v1")||declared.value("adapter")==QJsonValue("tianlong_flow_v1")||declared.value("adapter")==QJsonValue("yezhu_flow_v1")?"sanshen-tests.json":"sijue-tests.json"},{"real_game_tested",false}});
                continue; // Dedicated production-flow fixture replaces the obsolete generic-start probe.
            }
            auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,error);
            QJsonObject row{{"task",id},{"real_game_tested",false}};
            if(source.isEmpty())row.insert("preparation_error",error);
            else {
                struct DungeonStartFixture:ResidentFake {
                    resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                        // Explicitly model an empty bag; default scalar mock is not a bag record.
                        if(code.find("local kind=0 local t=")!=std::string::npos)return {resident::Value(std::string())};
                        if(code.find("pet API unavailable")!=std::string::npos)return {resident::Value(0)};
                        if(code=="return tonumber(Player:IsLeader())")return {resident::Value(1)};
                        if(code=="return DataPool:GetCurrentServerTime()")return {resident::Value(1793180000)};
                        if(code.find("local t=os.date")!=std::string::npos)return {resident::Value(2026),resident::Value(10),resident::Value(28),resident::Value(13),resident::Value(30),resident::Value(0)};
                        if(code.find("return os.time({year=")!=std::string::npos)return {resident::Value(1793181600)};
                        if(code.find("GetNewCampaignCount")!=std::string::npos)return {resident::Value(0),resident::Value(1),resident::Value(1),resident::Value(1)};
                        return ResidentFake::evaluate(code,format,count);
                    }
                    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {
                        if(id==gameplay::WindowVisible)return {resident::Value(0)};
                        if(id==gameplay::UiCall)return {resident::Value(1)};
                        if(id==gameplay::GuildInfo)return {resident::Value(0),resident::Value(std::string())};
                        if(id==gameplay::TempBag)return {resident::Value(0)};
                        if(id==gameplay::NpcEventItem)return {resident::Value(1),resident::Value(std::string())};
                        if(id==gameplay::CloseNamed)return {resident::Value(1)};
                        if(id==gameplay::UseBagItem)return {resident::Value(0)};
                        return ResidentFake::snippet(id,a);
                    }
                } host;host.scene=1;
                source.replace("local ok,err=pcall(chunk)","local ok,err=xpcall(chunk,__offline_traceback)");
                resident::Vm vm(host,true);std::string why;
                if(!vm.start(source.toStdString(),why))row.insert("start_error",QString::fromStdString(why));
                else {finish(vm,15000);row.insert("state",int(vm.state()));row.insert("error",QString::fromStdString(vm.error()));row.insert("log",QString::fromStdString(host.logText).left(1500));}
            }
            results.append(row);
        }
        const auto reportDir=qEnvironmentVariable("TLBB_DUNGEON_DIAGNOSTIC_DIR");
        if(!reportDir.isEmpty()){QFile out(reportDir+"/requested-dungeon-start-diagnostics.json");
            must(out.open(QIODevice::WriteOnly),"Dungeon diagnostics report unavailable");
            out.write(QJsonDocument(QJsonObject{{"offline_fixture_only",true},{"results",results}}).toJson());}
        onlyKnownGaps(results,"diagnostics");
    });
    test("resident_all_generic_tasks_startup_sweep",[&]{
        // Every generic original task starts under the fixture; stops are reported (TLBB_DUNGEON_DIAGNOSTIC_DIR).
        QFile manifest(root+"/scripts/legacy/manifest.json");must(manifest.open(QIODevice::ReadOnly),"manifest missing");
        const auto entry=root+"/scripts/legacy/original/generic_task.lua";QJsonArray results;
        for(const auto &v:QJsonDocument::fromJson(manifest.readAll()).object().value("tasks").toArray()){const auto t=v.toObject();
            const bool alternative=t.contains("original_alternative"); // a rewritten task switched to its original source
            const bool xiaomi=t.value("adapter").toString()=="xiaomi_text_v1"; // imported 小蜜文本 task
            if(t.value("adapter").toString()!="original_generic_v1"&&!alternative&&!xiaomi)continue;
            QString error;QJsonObject config{{"legacy_id",t.value("id")},{"combat",t.value("combat").toBool()},{"timeout_seconds",600}};
            if(alternative)config.insert("run_original_source",true);
            for(const auto &r:(alternative?t.value("original_alternative").toObject():t).value("risks").toArray())config.insert("allow_"+r.toString(),true);
            auto source=prepareResidentScript(root+"/scripts/legacy",xiaomi?root+"/scripts/legacy/"+t.value("entry").toString():entry,config,error);
            QJsonObject row{{"task",t.value("id")},{"name",t.value("name")},{"alternative",alternative}};
            if(source.isEmpty()){row.insert("preparation_error",error);results.append(row);continue;}
            struct SweepFixture:ResidentFake {
                resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                    if(code.find("local kind=0 local t=")!=std::string::npos)return {resident::Value(std::string())};
                    if(code.find("pet API unavailable")!=std::string::npos)return {resident::Value(0)};
                    if(code=="return tonumber(Player:IsLeader())")return {resident::Value(1)};
                    if(code=="return DataPool:GetCurrentServerTime()"||code.find("if os and os.time then return os.time()")!=std::string::npos)return {resident::Value(1793180000)};
                    if(code.find("local t=os.date")!=std::string::npos)return {resident::Value(2026),resident::Value(10),resident::Value(28),resident::Value(13),resident::Value(30),resident::Value(0)};
                    if(code.find("return os.time({year=")!=std::string::npos)return {resident::Value(1793181600)};
                    if(code.find("GetNewCampaignCount")!=std::string::npos)return {resident::Value(0),resident::Value(1),resident::Value(1),resident::Value(1)};
                    if(code.find("-- xiaomi:bag")!=std::string::npos)return {resident::Value(0),resident::Value(-1)}; // empty bag
                    if(code.find("'MEMPAI'")!=std::string::npos)return {resident::Value(4)};
                    return ResidentFake::evaluate(code,format,count);
                }
                resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {
                    try{return ResidentFake::snippet(id,a);}catch(const std::exception&){}
                    if(id==gameplay::WindowVisible||id==gameplay::TempBag||id==gameplay::UseBagItem)return {resident::Value(0)};
                    if(id==gameplay::GuildInfo)return {resident::Value(0),resident::Value(std::string())};
                    return {resident::Value(1),resident::Value(std::string())};
                }
            } host;host.scene=1;
            source.replace("local ok,err=pcall(chunk)","local ok,err=xpcall(chunk,__offline_traceback)");
            resident::Vm vm(host,true);std::string why;
            if(!vm.start(source.toStdString(),why))row.insert("start_error",QString::fromStdString(why));
            else{finish(vm,8000);row.insert("state",int(vm.state()));row.insert("error",QString::fromStdString(vm.error()).left(400));}
            results.append(row);
        }
        must(results.size()>=300,"generic task sweep incomplete");
        const auto reportDir=qEnvironmentVariable("TLBB_DUNGEON_DIAGNOSTIC_DIR");
        if(!reportDir.isEmpty()){QFile out(reportDir+"/all-generic-startup.json");must(out.open(QIODevice::WriteOnly),"sweep report unavailable");
            out.write(QJsonDocument(QJsonObject{{"offline_fixture_only",true},{"results",results}}).toJson());}
        // All 128: explicit "未接入" stops are reported gaps; any other stop (nil comparison, rejected arguments,
        // missing module) fails.
        onlyKnownGaps(results,"sweep",true);
    });
    test("resident_full_team_dungeon_diagnostics",[&]{
        const auto entry=root+"/scripts/legacy/original/generic_task.lua";
        QJsonArray results;
        for(const auto &id:QStringList{"pet_sell_npc"}){
            QString error;const QJsonObject config{{"legacy_id",id},{"combat",true},{"timeout_seconds",600}};
            auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,error);
            QJsonObject row{{"task",id},{"real_game_tested",false}};
            if(source.isEmpty())row.insert("preparation_error",error);
            else {
                struct DungeonStartFixture:ResidentFake {
                    resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                        // Explicitly model an empty bag; default scalar mock is not a bag record.
                        if(code.find("local kind=0 local t=")!=std::string::npos)return {resident::Value(std::string())};
                        if(code.find("pet API unavailable")!=std::string::npos)return {resident::Value(0)};
                        if(code=="return tonumber(Player:IsLeader())")return {resident::Value(1)};
                        if(code=="return DataPool:GetCurrentServerTime()")return {resident::Value(1793180000)};
                        if(code.find("local t=os.date")!=std::string::npos)return {resident::Value(2026),resident::Value(10),resident::Value(28),resident::Value(13),resident::Value(30),resident::Value(0)};
                        if(code.find("return os.time({year=")!=std::string::npos)return {resident::Value(1793181600)};
                        if(code.find("GetNewCampaignCount")!=std::string::npos)return {resident::Value(0),resident::Value(1),resident::Value(1),resident::Value(1)};
                        return ResidentFake::evaluate(code,format,count);
                    }
                    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {
                        if(id==gameplay::TeamCount)return {resident::Value(6)};
                        if(id==gameplay::WindowVisible)return {resident::Value(0)};
                        if(id==gameplay::UiCall)return {resident::Value(1)};
                        if(id==gameplay::GuildInfo)return {resident::Value(0),resident::Value(std::string())};
                        if(id==gameplay::TempBag)return {resident::Value(0)};
                        if(id==gameplay::NpcEventItem)return {resident::Value(1),resident::Value(std::string())};
                        if(id==gameplay::CloseNamed)return {resident::Value(1)};
                        if(id==gameplay::UseBagItem)return {resident::Value(0)};
                        return ResidentFake::snippet(id,a);
                    }
                } host;host.scene=1;
                source.replace("local ok,err=pcall(chunk)","local ok,err=xpcall(chunk,__offline_traceback)");
                resident::Vm vm(host,true);std::string why;
                if(!vm.start(source.toStdString(),why))row.insert("start_error",QString::fromStdString(why));
                else {finish(vm,15000);row.insert("state",int(vm.state()));row.insert("error",QString::fromStdString(vm.error()));row.insert("log",QString::fromStdString(host.logText).left(1500));}
            }
            results.append(row);
        }
        const auto reportDir=qEnvironmentVariable("TLBB_DUNGEON_DIAGNOSTIC_DIR");
        if(!reportDir.isEmpty()){QFile out(reportDir+"/full-team-dungeon-diagnostics.json");
            must(out.open(QIODevice::WriteOnly),"Full-team dungeon diagnostics report unavailable");
            out.write(QJsonDocument(QJsonObject{{"offline_fixture_only",true},{"results",results}}).toJson());}
        onlyKnownGaps(results,"diagnostics");
    });
    test("resident_four_dungeon_configuration_and_space_checks",[&]{
        for(const auto &token:QStringList{"00313c18","002e1226","002ef962","002fef1e"}){
            const auto path=temporary+"/selected-dungeon-probe.lua";QFile f(path);
            must(f.open(QIODevice::WriteOnly),"selected dungeon probe unavailable");
            f.write("__original_entry={original_token='"+token.toLatin1()+"'};LoadScript('original_generic_host');assert(GetUserConfig('CONFIG_PATH')=='');assert(GetUserConfig('other')==nil);assert(ClearBag());assert(not pcall(ClearBag))");f.close();
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);
            must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
            struct BagFixture:ResidentFake {int checks=0;resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {
                if(id==gameplay::BagSpace)return {resident::Value(checks++<2?5:0)}; // ClearBag reads both bags
                return ResidentFake::snippet(id,a);
            }} host;
            resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
            must(vm.state()==resident::Vm::Completed,vm.error().c_str());
        }
    });
    test("resident_boar_activity_server_time",[&]{
        const auto path=temporary+"/boar-time-probe.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"boar time probe unavailable");
        f.write("__original_entry={original_token='0031db5f'};LoadScript('original_generic_host');local d=os.date('*t',1730000000);assert(d.year==2026 and d.month==10 and d.day==28 and d.hour==12 and d.min==34 and d.sec==56);assert(os.time({year=2026,month=10,day=28,hour=14,min=0,sec=0})==1793181600);assert(not pcall(os.date,'*t',-1));assert(not pcall(os.time,{year=2026,month=13,day=28,hour=14,min=0,sec=0}))");f.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        struct DateFixture:ResidentFake {resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
            if(code.find("local t=os.date")!=std::string::npos){if(code.find("1730000000")==std::string::npos)throw std::runtime_error("wrong date timestamp");return {resident::Value(2026),resident::Value(10),resident::Value(28),resident::Value(12),resident::Value(34),resident::Value(56)};}
            if(code.find("return os.time({year=2026,month=10,day=28,hour=14,min=0,sec=0})")!=std::string::npos)return {resident::Value(1793181600)};
            return ResidentFake::evaluate(code,format,count);
        }} host;
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("original_source_covers_library_and_every_generic_task_compiles",[&]{
        // Original tasks run from scripts/original-source (decompiled, structurally checked against the bytecode).
        QString error;const auto directory=root+"/scripts/legacy";const auto index=originalLibraryIndex(directory,error);must(error.isEmpty(),qPrintable(error));
        QFile sources(root+"/scripts/original-source/index.json");must(sources.open(QIODevice::ReadOnly),"original-source index missing");
        const auto files=QJsonDocument::fromJson(sources.readAll()).object().value("modules").toObject();
        auto all=index.value("modules").toArray();for(const auto &v:index.value("custom_sources").toArray())all.append(v);
        for(const auto &v:all){const auto token=v.toObject().value("token").toString();must(files.contains(token),qPrintable("no source for "+v.toObject().value("name").toString()));
            QByteArray chunk;must(originalSourceChunk(directory,token,chunk,error)&&chunk.startsWith("\x1bLua"),qPrintable(error));}
        QFile manifest(root+"/scripts/legacy/manifest.json");must(manifest.open(QIODevice::ReadOnly),"manifest missing");int generic=0;
        for(const auto &v:QJsonDocument::fromJson(manifest.readAll()).object().value("tasks").toArray()){const auto t=v.toObject();
            if(t.value("adapter").toString()!="original_generic_v1")continue;++generic;
            const auto source=prepareResidentScript(directory,root+"/scripts/legacy/original/generic_task.lua",QJsonObject{{"legacy_id",t.value("id")}},error);
            must(error.isEmpty()&&source.contains("__original_rules={[")&&source.size()<qsizetype(resident::payloadCapacity),qPrintable(t.value("id").toString()+"："+error));}
        // Tasks moved to their own flows leave this list; the floor only catches a lost manifest.
        must(generic>=40,"generic task inventory shrank");
    });
    test("generic_host_team_buff_natives_and_clear_gaps",[&]{
        // EnumMemberInfo from team records + native player positions; Buffs through the identity-checked reader.
        const auto path=temporary+"/generic-natives-probe.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"natives probe unavailable");
        f.write(QString::fromUtf8(R"LUA(LoadScript('original_generic_host')
local m=EnumMemberInfo(1)
assert(#m==3,'member count')
assert(m[1].name=='甲' and m[1].leader==1 and m[1].id==500 and m[1].teamIndex==0 and m[1].dst==0 and m[1].hp==50 and m[1].sceneID==3,'self member')
assert(m[2].name=='乙' and m[2].id==501 and m[2].client_id==7 and m[2].x==70 and m[2].y==64 and math.abs(m[2].dst-6)<1e-9 and m[2].menpai==4 and m[2].level==90 and m[2].mapID==12,'other member')
assert(not pcall(EnumMemberInfo,2),'raid must be explicit')
assert(m[3].name=='丙' and m[3].id==-1 and m[3].hp==-1 and m[3].inScene==false and m[3].dead==false and m[3].sceneID==-1,'off-scene member')
LoadScript('common_2') LoadScript('team')
local dead,names=Team:IsHaveDieMember() assert(dead==false,'off-scene member classified dead: '..tostring(names))
local players=Enum2XByClass('玩家') assert(#players==1 and players[1].name=='乙' and players[1].class=='玩家','player class enumeration')
local ok2,e2=pcall(function() return players[1].mpp end) assert(not ok2 and e2:find('mpp',1,true),'player MP must be explicit')
local objs=EnumEnvObj() assert(#objs>0,'objects')
local ok3,e3=pcall(function() return objs[1].target==1 end) assert(not ok3 and e3:find('target',1,true),'boss target must be explicit')
LoadScript('player')
assert(Player:GetFightPetGUID()==-1,'no pet out')
local i,text=Player:GetBuff('千蛛万毒') assert(i==0 and text:find('毒伤',1,true),'own buff')
assert(Player:GetBuff('不存在')==-1,'absent buff')
assert(GetLuaValue('return mePlayerGetBuff([[坐骑：]]);','nsn')==1,'IsMount path')
local b=EnumObjBuff({id=10,server_id=101,name='首领'}) assert(#b==1 and b[1]=='疯狂：极大的提高伤害','object buff')
assert(not pcall(EnumObjBuff,{name='无身份'}),'object without identity')
local ok,e=pcall(GetLuaValue,'return mePetFeed(1)') assert(not ok and e:find('mePetFeed',1,true),'unmapped helper must name itself')
assert(GetLuaValue('local h=mePetGetHappy(0) return h','n')~=nil,'no configured pet'))LUA").toUtf8());f.close();
        struct NativesFixture:ResidentFake {bool pet=false;
            resident::Values call(const std::string &op,const std::string &v)override{
                using resident::Value;
                if(op=="battle_self_identity")return {Value(5),Value(500)};
                if(op=="mechanism_snapshot")return {Value(scene),Value(1),Value(std::string("1\t7\t501\t70\t64\n"))};
                if(op=="object_buff_ids"){if(v=="-1:-1")return {Value(2),Value(std::string("11,12"))};if(v=="10:101")return {Value(1),Value(std::string("13"))};throw std::runtime_error("unexpected buff identity "+v);}
                return ResidentFake::call(op,v);
            }
            resident::Values evaluate(const std::string &code,const std::string &format,int count)override{
                using resident::Value;
                if(code.find("generic:team-members")!=std::string::npos)
                    return {Value(3),Value(QString::fromUtf8("0\t甲\t9001\t500\t5\t50\t100\t1\t2\t89\t12\t0\t0\n1\t乙\t9002\t501\t7\t80\t100\t1\t4\t90\t12\t0\t0\n2\t丙\t9003\t502\t-1\t-1\t-1\t0\t3\t88\t12\t0\t0\n").toStdString())};
                if(code.find("generic:fight-pet-guid")!=std::string::npos)return pet?resident::Values{Value(3),Value(77)}:resident::Values{Value(-1),Value(-1)};
                if(code.find("generic:buff-text")!=std::string::npos){
                    if(code.find("Lua_GetBuffInfo(13)")!=std::string::npos)return {Value(QString::fromUtf8("疯狂：极大的提高伤害").toStdString())};
                    return {Value(QString::fromUtf8("千蛛万毒：每秒受到毒伤").toStdString()),Value(QString::fromUtf8("坐骑：骏马").toStdString())};
                }
                return ResidentFake::evaluate(code,format,count);
            }
        } host;
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,QJsonObject{{"legacy_id","pet_sell_npc"}},error);must(error.isEmpty(),qPrintable(error));
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("original_combos_route_files_dates_and_object_title",[&]{
        // Dropdowns carry real text (catalog choices + default), 采集 reads its route file, os.date formats the
        // given time, and an object's title is not invented.
        struct DateFixture:ResidentFake {
            resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                if(code.find("return os.date(\"%H\",1730000000)")!=std::string::npos)return {resident::Value(std::string("12"))};
                return ResidentFake::evaluate(code,format,count);
            }
        };
        const auto path=temporary+"/combo-probe.lua";
        auto run=[&](const QString &id,const QJsonObject &extra,const QByteArray &probe){
            QFile f(path);must(f.open(QIODevice::WriteOnly),"combo probe unavailable");f.write(probe);f.close();
            QJsonObject config{{"legacy_id",id}};for(auto i=extra.begin();i!=extra.end();++i)config.insert(i.key(),i.value());
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,config,error);must(error.isEmpty(),qPrintable(id+error));
            DateFixture host;resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
            must(vm.state()==resident::Vm::Completed,(id+": "+QString::fromStdString(vm.error())).toUtf8().constData());};
        run("gather_script",QJsonObject{{QString::fromUtf8("采集地图"),QString::fromUtf8("1级太湖")}},QString::fromUtf8(
            "LoadScript('original_generic_host') local c=GetConfigCommbox('设置','采集地图') assert(c.text=='1级太湖','route choice')"
            " local f=io.open(DoSystem(22)..'data\\\\坐标\\\\'..c.text..'.txt','r') assert(f,'route file') local t=f:read('*a') io.close(f) assert(t:find('257,260',1,true),'route content')"
            " assert(io.open(DoSystem(22)..'data\\\\坐标\\\\不存在.txt','r')==nil,'unknown file')"
            " assert(os.date('%H',1730000000)=='12','formatted time') local o=EnumEnvObj()[1] assert(not pcall(function() return o.title end),'title invented')").toUtf8());
    });
    test("xiaomi_api_contract",[&]{
        // 小蜜 API on the program's layer: text results, known maps only, explicit stops, no spinning, refused words.
        const auto path=temporary+"/xiaomi-probe.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"xiaomi probe unavailable");
        f.write(QString::fromUtf8(R"LUA(LoadScript('xiaomi_api')
assert(LUA_取返回值('return 7')=='7','number result is text')
assert(到数值('12')==12 and 到数值('x')==0 and 到整数(2.9)==2,'number helpers')
assert(math.abs(计算两点距离(0,0,3,4)-5)<1e-9,'distance')
assert(获取人物信息(17)==3 and 获取人物信息(7)==64 and 获取人物信息(8)==64,'position codes')
local ok,e=pcall(获取人物信息,62) assert(not ok and e:find('62',1,true),'unknown code named')
ok,e=pcall(跨图寻路,'鬼市',1,1) assert(not ok and e:find('鬼市',1,true),'unknown map named')
ok,e=pcall(LUA_Call,'DataPool:DelFriend(0,0)') assert(not ok and e:find('DelFriend',1,true),'deletion refused')
ok,e=pcall(XiaomiRequire,{'spend'}) assert(not ok and e:find('允许支付',1,true),'risk switch required')
XiaomiRequire({'item'})
写配置项('p','s','k','v') assert(读配置项('p','s','k')=='v','config note')
assert(获取背包物品数量('丹')==2 and 获取背包物品位置('丹')==4,'bag scan')
for i=1,6 do assert(右键使用物品('丹'),'item used') end
ok,e=pcall(右键使用物品,'丹') assert(not ok and e:find('丹',1,true),'unchanged item use must stop')
local name,school=获取人物属性() assert(name=='甲' and school=='峨嵋','name and school')
-- Scripts redefine program functions in terms of this API; that must not recurse.
function PushDebugMessage(s) 屏幕提示(s) end function Sleep(ms) 延时(ms) end PushDebugMessage('x') Sleep(1)
-- 1 / 0 results: scripts compare with ==1 and ==0.
assert(窗口是否出现('Quest')==1 and 窗口是否出现('Hidden')==0 and IsWindowShow('Quest')==true and IsWindowShow('Hidden')==false,'window results')
assert(对话NPC('甲')==1,'NPC talk is 1 once the window shows')
assert(组队_是否组队()==(组队_获取队伍人数()>0 and 1 or 0),'team result')
ok,e=pcall(执行功能,'自动清包') assert(not ok and e:find('自动清包',1,true),'unlisted builtin stops by name')
assert(执行功能('同步游戏时间')==nil,'clock builtin')
assert(获取任务进度('101')==1 and 获取任务进度('102')==0 and 获取任务进度('103')==-1,'mission progress')
assert(获取技能ID('甲技')==55 and 获取技能ID('乙技')==-1,'skill id')
assert(使用技能(55)==true and 使用技能(nil)==false,'skill cast')
assert(判断技能冷却('甲技')==1,'skill ready')
assert(判断人物死亡()==0,'alive')
ok,e=pcall(遍历周围物品,4,'甲',15) assert(not ok and e:find('4',1,true),'unknown object mode named')
local n,id=遍历周围物品(1,'没有的名字',15) assert(id==-1,'nothing found is -1'))LUA").toUtf8());f.close();
        struct XiaomiFixture:ResidentFake {
            std::string note;
            resident::Values evaluate(const std::string &code,const std::string &format,int count)override{
                using resident::Value;
                if(code=="return 7")return {Value(7)};
                if(code.find("-- xiaomi:bag")!=std::string::npos)return {Value(2),Value(3)};
                if(code.find("Quest_Env")!=std::string::npos)return {Value(1)};
                if(code.find("Hidden_Env")!=std::string::npos)return {Value(0)};
                if(code.find("GetPlayerMission_InUse")!=std::string::npos){if(code.find("local id=101")!=std::string::npos)return {Value(1)};if(code.find("local id=102")!=std::string::npos)return {Value(0)};return {Value(-1)};}
                if(code.find("GetName()==name")!=std::string::npos){const bool first=code.find(QString::fromUtf8("甲技").toStdString())!=std::string::npos;return {Value(code.find("cd==0")!=std::string::npos?(first?1:0):(first?55:-1))};}
                if(code.find("local id=55")!=std::string::npos)return {Value(1)};
                if(code.find("__xiaomiIni[")!=std::string::npos){if(code.find("if not __xiaomiIni")!=std::string::npos)return {Value(note)};note="v";return {};}
                if(code.find("Player:GetName()")!=std::string::npos)return {Value(QString::fromUtf8("甲").toStdString())};
                if(code.find("'MEMPAI'")!=std::string::npos)return {Value(4)};
                return ResidentFake::evaluate(code,format,count);
            }
        } host;
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,QJsonObject{{"allow_item",true}},error);must(error.isEmpty(),qPrintable(error));
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("rewritten_tasks_can_run_their_original_source",[&]{
        // run_original_source swaps a rewritten task to its original script; every offered alternative must build.
        QString error;const auto directory=root+"/scripts/legacy";QFile manifest(directory+"/manifest.json");must(manifest.open(QIODevice::ReadOnly),"manifest missing");
        int offered=0;QString plain;
        for(const auto &v:QJsonDocument::fromJson(manifest.readAll()).object().value("tasks").toArray()){const auto t=v.toObject();const auto id=t.value("id").toString();
            if(!t.contains("original_alternative")){if(t.value("adapter").toString()=="tlzz_compat_v1"&&plain.isEmpty())plain=id;continue;}
            ++offered;const QJsonObject config{{"legacy_id",id},{"run_original_source",true}};
            QJsonObject entry;QString path;must(resolveLegacyEntry(directory,id,entry,path,error)&&applyOriginalSourceChoice(directory,config,entry,path,error),qPrintable(id+error));
            must(entry.value("adapter").toString()=="original_generic_v1"&&path.endsWith("original/generic_task.lua")&&!entry.value("combat").toBool(),"alternative did not replace the entry");
            const auto source=prepareResidentScript(directory,path,config,error);
            must(error.isEmpty()&&source.contains("__original_entry=")&&source.contains("original_generic_v1"),qPrintable(id+"："+error));
            QJsonObject off;QString offPath;must(resolveLegacyEntry(directory,id,off,offPath,error)&&applyOriginalSourceChoice(directory,QJsonObject{{"legacy_id",id}},off,offPath,error)&&off.value("adapter").toString()=="tlzz_compat_v1","switch off must keep the rewrite");
        }
        must(offered>=100,"original alternatives missing");
        QJsonObject entry;QString path;must(!plain.isEmpty()&&resolveLegacyEntry(directory,plain,entry,path,error),"no task without alternative");
        must(!applyOriginalSourceChoice(directory,QJsonObject{{"run_original_source",true}},entry,path,error)&&!error.isEmpty(),"switch accepted without an original script");
    });
    test("original_source_index_reloads_when_override_changes",[&]{
        // The source index is cached per resolved file and its size/time: an edited override index and script
        // take effect at the next task start in the same process instead of failing against stale hashes.
        const auto base=QCoreApplication::applicationDirPath()+"/overrides/scripts/builtin/original-source";
        QFile builtin(root+"/scripts/original-source/index.json");must(builtin.open(QIODevice::ReadOnly),"index missing");
        auto index=QJsonDocument::fromJson(builtin.readAll()).object();auto modules=index.value("modules").toObject();
        QString token;for(auto i=modules.begin();i!=modules.end();++i)if(i.value().toObject().value("name").toString()=="json")token=i.key();
        auto write=[&](const QByteArray &script){
            QDir().mkpath(base+"/override");QFile s(base+"/override/json.lua");must(s.open(QIODevice::WriteOnly),"override script unavailable");s.write(script);s.close();
            auto m=modules.value(token).toObject();m.insert("path","override/json.lua");m.insert("sha256",QString::fromLatin1(QCryptographicHash::hash(script,QCryptographicHash::Sha256).toHex()));
            m.insert("bytes",script.size());auto all=modules;all.insert(token,m);auto copy=index;copy.insert("modules",all);
            QFile i(base+"/index.json");must(i.open(QIODevice::WriteOnly),"override index unavailable");i.write(QJsonDocument(copy).toJson());};
        QString error;QByteArray first,second;
        write("return 1");const bool a=originalSourceChunk("scripts/builtin/legacy",token,first,error);
        write("return 2 -- edited");const bool b=originalSourceChunk("scripts/builtin/legacy",token,second,error);
        QDir(base).removeRecursively();QByteArray restored;originalSourceChunk("scripts/builtin/legacy",token,restored,error);
        must(a&&b&&!first.isEmpty()&&first!=second,qPrintable("override edit not picked up: "+error));
    });
    test("original_source_rejects_tampered_file",[&]{
        // An override with different bytes fails the index hash instead of running altered rules.
        const auto overrides=QCoreApplication::applicationDirPath()+"/overrides/scripts/builtin/original-source/Script64/系统";
        QDir().mkpath(overrides);const auto path=overrides+"/json.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"override unavailable");f.write("return {}");f.close();
        QString error;const auto index=originalLibraryIndex(root+"/scripts/legacy",error);QString token;
        for(const auto &v:index.value("modules").toArray())if(v.toObject().value("name").toString()=="json")token=v.toObject().value("token").toString();
        QByteArray chunk;const bool ok=originalSourceChunk("scripts/builtin/legacy",token,chunk,error);QFile::remove(path);
        must(!ok&&error.contains("校验失败"),qPrintable("tampered source accepted: "+error));
    });
    test("resident_generic_original_data_files",[&]{
        // 清剿九黎余孽 reads coordinates from the original script/数据 files.
        const auto path=temporary+"/data-probe.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"data probe unavailable");
        f.write("for name,source in pairs(__original_data) do assert(load(source,'='..name,'t',_G))() end;"
                "assert(__original_entry.data_files[1]=='jiuli_pos','data file')");f.close();
        for(const auto &id:QStringList{"jiuli_clear"}){
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,QJsonObject{{"legacy_id",id}},error);
            must(error.isEmpty()&&source.contains("__original_data={["),qPrintable(id+error));
        }
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,QJsonObject{{"legacy_id","jiuli_clear"}},error);
        ResidentFake host;resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("resident_fight_pet_guid_reader",[&]{
        const auto path=temporary+"/sijue-pet-probe.lua";QFile f(path);
        must(f.open(QIODevice::WriteOnly),"sijue pet probe unavailable");
        f.write("__original_entry={original_token='002e1226'};LoadScript('original_generic_host');assert(Player:GetFightPetGUID()==-1);assert(Player:GetFightPetGUID()==3*4294967296+77);assert(not pcall(Player.GetFightPetGUID,Player))");f.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);
        must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        struct PetFixture:ResidentFake {int checks=0;resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
            if(code.find("generic:fight-pet-guid")!=std::string::npos){const int n=checks++;if(n==0)return {resident::Value(-1),resident::Value(-1)};if(n==1)return {resident::Value(3),resident::Value(77)};return {resident::Value(1)};}
            return ResidentFake::evaluate(code,format,count);
        }} host;
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("resident_event_leader_read",[&]{
        for(const auto &token:QStringList{"002cf5a7","002b54ac","0031c749","0031db5f","00313c18"}){
        const auto path=temporary+"/wangling-leader-probe.lua";QFile f(path);
        must(f.open(QIODevice::WriteOnly),"wangling leader probe unavailable");
        f.write("__original_entry={original_token='"+token.toLatin1()+"'};LoadScript('original_generic_host');assert(Player:IsLeader());assert(not pcall(Player.IsLeader,Player))");f.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);
        must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        struct LeaderFixture:ResidentFake {int reads=0;resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
            if(code=="return tonumber(Player:IsLeader())")return {resident::Value(reads++==0?1:7)};
            return ResidentFake::evaluate(code,format,count);
        }} host;
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
        }
    });
    test("resident_cxdt_purchase_disabled_only_for_that_task",[&]{
        const auto path=temporary+"/cxdt-config-probe.lua";QFile f(path);
        must(f.open(QIODevice::WriteOnly),"cxdt config probe unavailable");
        f.write(QString::fromUtf8("__original_entry={original_token='00267ca1'};TaskConfig={['购买定位']=true,['制作定位']=true,['收费传送']=true};LoadScript('original_generic_host');assert(not GetConfigBool('', '购买定位'));assert(not GetConfigBool('', '制作定位'));assert(GetConfigBool('', '收费传送'));__original_entry.original_token='other';assert(GetConfigBool('', '购买定位'))").toUtf8());f.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);
        must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        ResidentFake host;resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
        must(host.evaluations==0,"cxdt configuration probe executed game Lua");
    });
    test("resident_selected_dungeons_item_name_search",[&]{
        for(const auto &token:QStringList{"002bb430","002fd257","002fe064","002fe6b9"}){
            const auto path=temporary+"/dungeon-bag-search.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"bag search probe unavailable");
            f.write("__original_entry={original_token='"+token.toLatin1()+"'};LoadScript('original_generic_host');local a=Bag:SearchItemName('itemA itemB');assert(#a==2 and a[1].index==3 and a[1].count==2 and a[2].index==101,'bag matches');local b=Bag:SearchItemName('itemB',{{name='itemB',index=8},{name='itemC',index=9}});assert(#b==1 and b[1].index==8,'provided items');assert(not pcall(Bag.SearchItemName,Bag,'itemA'),'malformed result')");f.close();
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
            struct BagFixture:ResidentFake {int reads=0;
                resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                    if(code.find("local kind=0 local t=")!=std::string::npos){++reads;return {resident::Value(reads==1?std::string("7\titemA\t2\t3\t0\t0\n8\titemC\t1\t4\t0\t0\n9\titemB\t1\t101\t1\t0\n"):std::string("broken-record\n"))};}
                    return ResidentFake::evaluate(code,format,count);
                }
            } host;
            resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm,120000);
            must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.reads==2,"provided item list should not query game");
        }
    });
    test("resident_selected_dungeons_pet_presence",[&]{
        for(const auto &token:QStringList{"002bb430","002fd257","002fe064","002fe6b9"}){
            const auto path=temporary+"/dungeon-pet-presence.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"pet presence probe unavailable");
            f.write("__original_entry={original_token='"+token.toLatin1()+"'};LoadScript('original_generic_host');assert(Player:IsLeader(),'leader');assert(not pcall(Player.IsLeader,Player),'invalid leader state');assert(Player:GetFightPetGUID()==-1,'absent pet');assert(Player:GetFightPetGUID()==3*4294967296+77,'pet out');assert(not pcall(Player.GetFightPetGUID,Player),'invalid state')");f.close();
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
            struct PetFixture:ResidentFake {int reads=0,leaders=0;
                resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                    if(code=="return tonumber(Player:IsLeader())")return {resident::Value(leaders++==0?1:2)};
                    if(code.find("generic:fight-pet-guid")!=std::string::npos){const int n=reads++;if(n==0)return {resident::Value(-1),resident::Value(-1)};if(n==1)return {resident::Value(3),resident::Value(77)};return {resident::Value(1)};}
                    return ResidentFake::evaluate(code,format,count);
                }
            } host;
            resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm,120000);
            must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.reads==3,"pet presence query count");
        }
    });
    test("resident_selected_dungeons_bag_space_check",[&]{
        for(const auto &token:QStringList{"002bb430","002fd257","002fe064","002fe6b9"}){
            const auto path=temporary+"/dungeon-bag-space.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"bag space probe unavailable");
            f.write("__original_entry={original_token='"+token.toLatin1()+"'};LoadScript('original_generic_host');assert(Bag_DeleteBagItem());assert(ClearBag());assert(not pcall(Bag_DeleteBagItem),'full material bag')");f.close();
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
            struct SpaceFixture:ResidentFake {int reads=0;
                resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {
                    if(id==gameplay::BagSpace){++reads;return {resident::Value(reads==6?0:5)};}
                    return ResidentFake::snippet(id,a);
                }
            } host;
            resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm,120000);
            must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.reads==6,"both bag types should be checked");
        }
    });
    test("resident_yanzi_bag_precheck_without_deletion",[&]{
        const auto path=temporary+"/yanzi-bag-space.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"yanzi bag probe unavailable");
        f.write("__original_entry={original_token='00313c18'};LoadScript('original_generic_host');assert(Bag_DeleteItem());assert(not pcall(Bag_DeleteItem,'specified'));assert(not pcall(Bag_DeleteItem),'full material')");f.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        struct SpaceFixture:ResidentFake {int reads=0;resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {if(id==gameplay::BagSpace)return {resident::Value(++reads==4?0:5)};return ResidentFake::snippet(id,a);}} host;
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm,120000);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.reads==4,"yanzi checks both bags");
    });
    test("resident_dungeon_hp_mp_percent_readers",[&]{
        const auto path=temporary+"/dungeon-vitals-probe.lua";QFile f(path);
        must(f.open(QIODevice::WriteOnly),"vitals probe unavailable");
        f.write("__original_entry={original_token='00320005'};LoadScript('original_generic_host');assert(Player:GetHPP()==25);assert(Player:GetMPP()==75);assert(Player:IsLeader()==true);assert(Player:GetTID()==903 and playerlib.CGetTID()==903);assert(Player:GetFightPetGUID()==-1);assert(Pet:GetSelfPet()==nil);assert(not pcall(Player.GetFightPetGUID,Player));LoadScript('original_filters');assert(Team:IsCountReady(3));assert(not Team:IsCountReady(4));assert(ClearBag());assert(not pcall(ClearBag));local t=Bag:SearchItemName('itemA itemB',{{name='itemA',index=1},{name='itemC',index=2},{name='itemB',index=3}});assert(#t==2 and t[1].index==1 and t[2].index==3)");f.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",path,{},error);
        must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        struct Vitals:ResidentFake {
            int bagChecks=0,petChecks=0;
            resident::Values call(const std::string &op,const std::string &value) override {
                if(op=="battle_self_identity")return {resident::Value(42),resident::Value(903)};
                return ResidentFake::call(op,value);
            }
            resident::Values evaluate(const std::string &code,const std::string &format,int count) override {
                if(code=="return tonumber(Player:IsLeader())")return {resident::Value(1)};
                if(code.find("generic:fight-pet-guid")!=std::string::npos)return petChecks++<2?resident::Values{resident::Value(-1),resident::Value(-1)}:resident::Values{resident::Value(1)};
                return ResidentFake::evaluate(code,format,count);
            }
            resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a) override {
                if(id==gameplay::BagSpace)return {resident::Value(bagChecks++<2?5:0)}; // ClearBag reads both bags
                if(id==gameplay::PlayerData){const int v[]={50,200,75,100};if(a.ints[0]>=4&&a.ints[0]<=7)return {resident::Value(v[a.ints[0]-4])};}
                return ResidentFake::snippet(id,a);
            }
        } host;
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("resident_archived_plain_lua_uses_original_cexec_and_load_cache",[&]{
        QString error,token;const auto directory=root+"/scripts/legacy";const auto index=originalLibraryIndex(directory,error);must(error.isEmpty(),qPrintable(error));
        for(const auto &v:index.value("custom_sources").toArray())if(v.toObject().value("name").toString()=="自定义·窗口闪烁报警")token=v.toObject().value("token").toString();
        QJsonObject chunks,names;must(originalRuleClosure(directory,token,chunks,names,error),qPrintable(error));
        const auto path=temporary+"/archived-source.lua";QFile f(path);must(f.open(QIODevice::WriteOnly),"Plain original fixture entry missing");
        f.write("__original_rules={['"+token.toLatin1()+"']='"+chunks.value(token).toString().toLatin1()+"'}\n__original_names={probe='"+token.toLatin1()+"'}\nCExec('probe');CExec('probe');LoadScript('probe');LoadScript('probe');assert(not pcall(RunOriginalRule,'deadbeef'))");f.close();
        const auto source=prepareResidentScript(directory,path,{},error);must(error.isEmpty(),qPrintable(error));
        struct Alarm:ResidentFake {int alarms=0;resident::Values call(const std::string &op,const std::string &value)override{if(op=="alert"){++alarms;return {};}return ResidentFake::call(op,value);}}host;
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.alarms==6&&host.evaluations==0,"Plain original loading lost its cache or issued game actions");
    });
    test("resident_original_archive_task_inventory_receipts_and_no_replay",[&]{
        struct Inventory:ResidentFake {
            int coins=2,rewards=0,uses=0,selects=0,reports=0;bool unchanged=false,throwUse=false,badTarget=false;std::string result;
            Inventory(){scene=0;x=256;y=246;}
            resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
                using resident::Value;const auto name=QString::fromWCharArray(a.text);
                if(id==gameplay::BagCount)return {Value(name=="金纹铜钱"?coins:rewards)};
                if(id==gameplay::BagCountIn)return {Value(0)};
                if(id==gameplay::WindowVisible)return {Value(1)};
                if(id==gameplay::TempBag||id==gameplay::CloseNamed||id==gameplay::CloseAll||id==gameplay::Dismount||id==gameplay::PlayerState)return {Value(0)};
                return ResidentFake::snippet(id,a);
            }
            resident::Values evaluate(const std::string &code,const std::string &format,int count)override{
                using resident::Value;
                if(code.find("DataPool:SelectAsTargetByObjID")!=std::string::npos){++selects;return {Value(badTarget?999:11)};}
                if(code.find("PlayerPackage:UseItem")!=std::string::npos){++uses;if(throwUse)throw std::runtime_error("uncertain item submission");
                    if(!unchanged){if(code.find("金纹铜钱")!=std::string::npos)--coins;else --rewards;}return {Value(1)};}
                return ResidentFake::evaluate(code,format,count);
            }
            resident::Values call(const std::string &op,const std::string &value)override{
                if(op=="task_result"){++reports;result=value;return {};}
                return ResidentFake::call(op,value);
            }
            std::vector<resident::Object> objects()override{return {{11,102,256,246,100,false,"摇钱树"}};}
        };
        for(int scenario=0;scenario<7;++scenario){
            Inventory host;host.unchanged=scenario==2;host.throwUse=scenario==3;host.badTarget=scenario==4;
            if(scenario==1)host.coins=0;
            if(scenario==6){host.coins=0;host.rewards=4;}
            QString error;const QJsonObject cfg{{"legacy_id","jinwen"},{"engine","游戏内 Lua"},{"allow_spend",scenario!=5},{"timeout_seconds",360}};
            const auto source=prepareResidentScript(root+"/scripts/legacy",root+"/scripts/legacy/original/archive_entry.lua",cfg,error);
            must(error.isEmpty()&&!source.isEmpty()&&source.size()<512*1024,qPrintable(error));
            must(source.contains("__original_rules")&&!source.contains("\"0025fb7b\""),"Unrelated source rules were preloaded");
            resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm,120000);
            if(scenario==0){must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.coins==0&&host.uses==2&&host.reports==1,"Original coin task did not verify completion");}
            else if(scenario==1){must(vm.state()==resident::Vm::Completed&&host.uses==0&&host.selects==0&&host.reports==1,"Empty inventory failed the precheck");}
            else if(scenario==6){must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.rewards==1&&host.uses==3&&host.reports==1,"Original three-box limit was rewritten");}
            else {must(vm.state()==resident::Vm::Failed&&host.reports==0,"Unconfirmed action reported task success");
                must(host.uses==((scenario==2||scenario==3)?1:0),"Uncertain item use replayed or failed precheck acted");}
            must(vm.allocated()==0,"Original task retained VM memory after termination");
        }
    });
    test("resident_combined_engine_exports_and_owned_hook",[&]{
        const auto path=QDir::toNativeSeparators(QCoreApplication::applicationDirPath()+"/TLBBEngine.dll");
        const auto dll=LoadLibraryExW(reinterpret_cast<LPCWSTR>(path.utf16()),nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);must(dll,"Combined engine DLL cannot load");
        bool exports=true;for(const auto *name:{"TlbbBridgeHook","TlbbLoginHook","TlbbGameplayHook","TlbbResidentHook"})exports=exports&&GetProcAddress(dll,name);FreeLibrary(dll);must(exports,"Combined engine lost hook entries");
        std::unique_ptr<QProcess,std::function<void(QProcess*)>> fixture(new QProcess,[](QProcess *p){if(p->state()!=QProcess::NotRunning){p->kill();p->waitForFinished(3000);}delete p;});
        fixture->start(QCoreApplication::applicationFilePath(),{"--bridge-fixture"});must(fixture->waitForStarted(3000),"Owned hook fixture did not start");
        struct Window{DWORD pid;HWND hwnd=nullptr;} target{DWORD(fixture->processId())};
        for(int i=0;i<100&&!target.hwnd;++i){EnumWindows([](HWND w,LPARAM arg)->BOOL{auto &t=*reinterpret_cast<Window*>(arg);DWORD pid=0;GetWindowThreadProcessId(w,&pid);wchar_t cls[64]{};GetClassNameW(w,cls,64);if(pid==t.pid&&std::wcscmp(cls,L"TLBBBridgeFixture")==0){t.hwnd=w;return FALSE;}return TRUE;},LPARAM(&target));if(!target.hwnd)Sleep(10);}
        must(target.hwnd,"Owned fixture window missing");
        const auto result=bridgeCommand(target.pid,{},root,path,bridge::ThreadProbe,0,0,true);
        must(result.value("success").toBool()&&result.value("game_actions_issued").toInt()==0,"Combined engine message hook failed on owned fixture");
        PostMessageW(target.hwnd,WM_CLOSE,0,0);must(fixture->waitForFinished(3000),"Owned fixture did not exit");
    });
    test("resident_synchronous_returns_continuations_no_replay_and_ipc",[&]{
        ResidentFake host;resident::Vm vm(host);std::string error;
        must(vm.start("for i=1,10000 do local n,s,z,b=GetLuaValue('echo','',4);assert(n==i and s=='无白名单直调' and z==nil and b==true) end",error),error.c_str());
        QElapsedTimer wall;wall.start();int slices=0;size_t peak=vm.allocated();
        for(uint64_t now=0;now<=60000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20){++slices;vm.step(now);peak=qMax(peak,vm.allocated());}
        const double wallMs=double(wall.nsecsElapsed())/1000000;
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.evaluations==10000&&vm.calls()==10000,"Yielded native calls were replayed or lost");must(vm.allocated()==0,"Completed VM retained allocator memory");
        QJsonObject report{{"status","pass"},{"fixture_native_calls",10000},{"per_action_ipc",0},{"scheduled_slices",slices},{"fixture_wall_ms",wallMs},{"lua_allocator_peak",double(peak)},{"lua_allocator_after_completion",0},{"game_process_accessed",false},{"realtime_game_speedup_measured",false}};
        QFile out(root+"/artifacts/resident-benchmark-0.15.0.json");must(out.open(QIODevice::WriteOnly),"Benchmark report unavailable");out.write(QJsonDocument(report).toJson());
    });
    test("resident_pause_sleep_stop_and_repeated_cleanup",[&]{
        ResidentFake host;resident::Vm vm(host);std::string error;
        must(vm.start("Sleep(100);GetLuaValue('once');Sleep(100)",error),error.c_str());vm.step(0);vm.pause(true);vm.step(5000);must(host.evaluations==0&&vm.state()==resident::Vm::Paused,"Paused Lua executed");
        vm.pause(false);vm.step(99);must(host.evaluations==0,"Sleep ended early");vm.step(100);must(host.evaluations==1,"Sleep did not resume");vm.stop();must(vm.allocated()==0,"Stop leaked Lua memory");
        for(int i=0;i<200;++i){must(vm.start("local t=string.rep('x',100000);Sleep(10)",error),error.c_str());vm.step(0);vm.stop();must(vm.allocated()==0,"Repeated stop leaked Lua memory");}
        must(vm.start("local t={GetLuaValue('many','',32)};assert(#t==32 and t[32]==32)",error),error.c_str());finish(vm);must(vm.state()==resident::Vm::Completed,vm.error().c_str());
        must(vm.start("local n=GetLuaValue('inferred','n');assert(type(n)=='number')",error),error.c_str());finish(vm);must(vm.state()==resident::Vm::Completed,"Original two-argument GetLuaValue did not infer its result count");
    });
    test("resident_instruction_memory_and_uncertain_error_bounds",[&]{
        ResidentFake host;resident::Vm vm(host);std::string error;
        must(vm.start("while true do end",error),error.c_str());finish(vm);must(vm.state()==resident::Vm::Failed&&vm.allocated()==0,"Unbounded loop did not fail and release");
        must(vm.start("local a={} for i=1,100 do a[i]=string.rep('x',1024*1024) end",error),error.c_str());finish(vm);must(vm.state()==resident::Vm::Failed&&vm.allocated()==0,"16 MiB allocator bound failed");
        must(vm.start("GetLuaValue('throw');GetLuaValue('must not replay')",error),error.c_str());vm.step(0);must(vm.state()==resident::Vm::Failed&&host.evaluations==1,"Uncertain action replayed");
        must(vm.start("local t=setmetatable({},{__gc=function() while true do end end})",error),error.c_str());finish(vm);must(vm.state()==resident::Vm::Failed&&host.evaluations==1&&vm.allocated()==0,"Unbudgeted __gc finalizer was registered");
        must(!vm.start("invalid ! lua",error)&&vm.allocated()==0,"Syntax error retained Lua state");
    });
    test("resident_prepared_manifest_modules_objects_and_new_game_api",[&]{
        const auto dir=root+"/scripts/legacy";QFile file(dir+"/manifest.json");must(file.open(QIODevice::ReadOnly),"Manifest missing");
        ResidentFake host;resident::Vm vm(host);QString error;std::string e;
        for(const auto &v:QJsonDocument::fromJson(file.readAll()).object().value("tasks").toArray()){
            const auto task=v.toObject();if(task.value("adapter").toString()!="tlzz_compat_v1")continue;
            const auto source=prepareResidentScript(dir,dir+"/"+task.value("entry").toString(),{},error);must(error.isEmpty(),qPrintable(error));
            must(vm.start(source.toStdString(),e),e.c_str());vm.stop();
        }
        const auto entry=temporary+"/resident-probe.lua";QFile out(entry);must(out.open(QIODevice::WriteOnly),"Probe missing");out.write("local n,s,z,b=GetLuaValue('echo','',4);assert(n==1 and s=='无白名单直调' and z==nil and b);assert(#EnumObjects()==2 and #Enum2XByName('传送人')==1 and #Enum2XByClass('怪物')==1);assert(Player:GetData('NEW_GAME_KEY')==100);assert(Game.Lua==GetLuaValue and TaskConfig.optional==nil);LoadScript('character_status');local hp,maximum=ReadCharacterVitals();assert(hp==100 and maximum==100)");out.close();
        auto source=prepareResidentScript(dir,entry,{{"optional",QJsonValue::Null}},error);must(error.isEmpty(),qPrintable(error));must(vm.start(source.toStdString(),e),e.c_str());finish(vm);must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
    test("resident_combat_chess_lifecycle_low_hp_and_no_replay",[&]{
        for(int scenario=0;scenario<4;++scenario){
            const bool chess=scenario==1;auto config=combatTestConfig(chess?"zhenlong_combat":"dungeon_combat");config.insert("entry_mode","自动入场");
            const auto entry=temporary+"/resident-fight.lua";QFile out(entry);must(out.open(QIODevice::WriteOnly),"Fight probe missing");out.write(chess?"RunZhenlongDungeon()":"RunDungeonCombat()");out.close();
            QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,error);must(error.isEmpty(),qPrintable(error));
            ResidentFake host;host.low=scenario==2;host.uncertain=scenario==3;if(chess){host.scene=1;host.entryScene=61;}
            resident::Vm vm(host);std::string e;must(vm.start(source.toStdString(),e),e.c_str());finish(vm,120000);
            if(scenario<2){must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.casts==3&&host.kills==1,"Resident combat death confirmation failed");if(chess)must(host.boss==1&&host.scene==1,"Resident chess did not confirm boss and exit");}
            else{must(vm.state()==resident::Vm::Failed,"Resident combat failure was ignored");must(host.casts==(scenario==2?0:1),"Low HP attacked or uncertain cast replayed");}
        }
    });
    test("resident_original_module_contract_and_failure_cleanup",[&]{
        const auto entry=temporary+"/resident-loader.lua";QFile out(entry);must(out.open(QIODevice::WriteOnly),"Loader probe missing");
        out.write(R"LUA(
__resident_modules.probe="executions=(executions or 0)+1;CSleep(0);return executions,nil,'end'"
local n,z,s=CExec('probe.lua');assert(n==1 and z==nil and s=='end')
assert(CExec('probe')==2)
LoadScript('probe.lua');LoadScript('probe');assert(executions==3)
__resident_modules.broken="error('broken module')"
assert(not pcall(LoadScript,'broken'));__resident_modules.broken="recovered=true"
LoadScript('broken');assert(recovered)
KejuQ={'question'};KejuA={'answer'};LoadScript('科举.lua');assert(Q==KejuQ and A==KejuA)
__resident_modules.recursive="CExec('recursive')"
assert(not pcall(CExec,'recursive'));__resident_modules.recursive="return 19"
assert(CExec('recursive')==19)
for _,name in ipairs({'../probe','folder/probe','folder\\probe',''}) do assert(not pcall(CExec,name)) end
assert(not pcall(CExec,'missing_module'))
)LUA");out.close();
        QString error;auto source=prepareResidentScript(root+"/scripts/legacy",entry,{},error);must(error.isEmpty(),qPrintable(error));
        ResidentFake host;resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.evaluations==0,"Module control unexpectedly executed game Lua");
    });
    test("resident_original_filters_are_generic_not_chess_only",[&]{
        const auto entry=temporary+"/resident-filter.lua";QFile out(entry);must(out.open(QIODevice::WriteOnly),"Filter probe missing");
        out.write("local t=Enum2XByName('远古棋魂',{0,1,0,0},nil,nil,0);assert(#t==1 and t[1].server_id==101);assert(#Enum2XByClass('NPC')==1);assert(#Enum2XByClass('怪物 NPC')==2);assert(not pcall(Enum2XByClass,'怪物 包裹'));assert(not pcall(Enum2XByClass,'玩家'));assert(not pcall(Enum2XByName,'x',{0,0,1,0}));assert(playerlib.CGetPos().x==64)");out.close();
        QString error;auto source=prepareResidentScript(root+"/scripts/legacy",entry,{},error);must(error.isEmpty(),qPrintable(error));
        ResidentFake host;resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.casts==0,"Read-only filter issued a cast");
    });
    test("resident_original_enum_dead_identity_not_reused",[&]{
        const auto entry=temporary+"/resident-death.lua";QFile out(entry);must(out.open(QIODevice::WriteOnly),"Identity probe missing");
        out.write("local t=EnumEnvObj();assert(t[1].class=='怪物');Sleep(100);t=EnumEnvObj();assert(t[1].hp==0 and t[1].class=='怪物');Sleep(100);t=EnumEnvObj();assert(t[1].class=='NPC')");out.close();
        struct Changing:ResidentFake {int reads=0;std::vector<resident::Object> objects()override{
            ++reads;return {{10,reads<3?101:999,65,64,reads==1?100.0:0.0,reads==1,"target"}};
        }}host;
        QString error;auto source=prepareResidentScript(root+"/scripts/legacy",entry,{},error);must(error.isEmpty(),qPrintable(error));
        resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),why.c_str());finish(vm);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());must(host.casts==0,"Snapshot identity check issued an action");
    });
}
}
