#pragma once
#include "resident_tests.hpp"
#include "task_completion.hpp"
#include "flow_runner.hpp"
#include "client_store.hpp"
#include "resident_clock.hpp"
#include <QTemporaryDir>
#include <QJsonArray>
#include <QJsonDocument>
namespace tlbb {
template<class Test>void taskAuditTests(const QString &root,Test test){
    test("role_profile_damage_backup_and_unwritable_store",[&]{
        auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
        QDir().mkpath(root+"/artifacts/store-tests");QTemporaryDir dir(root+"/artifacts/store-tests/owned-XXXXXX");must(dir.isValid(),"temporary store unavailable");
        ClientStore store(dir.path());QJsonObject loaded;QString note,error;
        must(store.loadProfile("role",loaded,note)==ClientStore::ProfileState::Missing&&loaded.isEmpty(),"new role not reported missing");
        must(store.saveProfile("role",QJsonObject{{"v",1}},error)&&store.saveProfile("role",QJsonObject{{"v",2}},error),qPrintable(error));
        must(QFile::exists(store.profilePath("role")+".bak"),"previous valid profile not kept as backup");
        // A damaged file with a valid backup: the backup is used and the damaged file is kept beside it.
        {QFile f(store.profilePath("role"));must(f.open(QIODevice::WriteOnly),"profile not writable");f.write("{\"v\":");}
        must(store.loadProfile("role",loaded,note)==ClientStore::ProfileState::Restored&&loaded.value("v").toInt()==1&&note.contains(".damaged-"),"backup not restored");
        must(QDir(QFileInfo(store.profilePath("role")).absolutePath()).entryList({"*.damaged-*"}).size()==1,"damaged file not preserved");
        // No usable copy at all: reported damaged and the bytes stay untouched (the launcher then refuses to save).
        QFile::remove(store.profilePath("role")+".bak");
        {QFile f(store.profilePath("role"));must(f.open(QIODevice::WriteOnly),"profile not writable");f.write("not json");}
        must(store.loadProfile("role",loaded,note)==ClientStore::ProfileState::Damaged&&loaded.isEmpty()&&!note.isEmpty(),"damaged profile read as new");
        {QFile f(store.profilePath("role"));must(f.open(QIODevice::ReadOnly)&&f.readAll()=="not json","damaged profile changed by loading");}
        // An unwritable store reports failure; the caller stops instead of continuing on stale data.
        const auto blocked=dir.path()+"/blocked";{QFile f(blocked);must(f.open(QIODevice::WriteOnly),"blocker unavailable");f.write("x");}
        ClientStore unwritable(blocked);unwritable.launcher={{"schema",3}};
        must(!unwritable.save(error)&&!error.isEmpty(),"save into a file path reported success");
        must(!unwritable.saveProfile("role",QJsonObject{{"v",1}},error),"profile save into a file path reported success");
    });
    test("resident_clock_pause_lease_and_timeout",[&]{
        auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
        resident::Clock c;c.start(1000,10); // 10 s of running time
        must(c.step(6000,true,false)==resident::Clock::Run&&c.active==5000,"running time not counted");
        // 60 s paused with the controller renewing its lease: neither timed out nor counted.
        for(uint64_t t=7000;t<=67000;t+=1000){c.renew(t);must(c.step(t,true,true)==resident::Clock::Paused,"paused task timed out");}
        must(c.active==5000,"paused time counted");c.resume(67000);
        c.renew(71000);must(c.step(71000,true,false)==resident::Clock::Run&&c.active==9000,"resume lost or added time");
        c.renew(73000);must(c.step(73000,true,false)==resident::Clock::TimedOut,"running time beyond timeout accepted");
        resident::Clock lost;lost.start(0,600);must(lost.step(6000,true,true)==resident::Clock::Disconnected,"lost controller ignored while paused");
        resident::Clock gone;gone.start(0,600);must(gone.step(100,false,false)==resident::Clock::Disconnected,"exited controller ignored");
    });
    test("scheduled_completion_removes_node_by_id",[&]{
        auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
        const QJsonArray nodes{QJsonObject{{"node_id","a"},{"task","x"},{"params",QJsonObject{{"n",1}}}},QJsonObject{{"node_id","b"},{"task","y"}}};
        // Completed copy carries run-time additions and a parameter edited during the run.
        const QJsonObject completed{{"node_id","a"},{"task","x"},{"params",QJsonObject{{"n",2},{"combat_skills","Alpha"}}}};
        const auto left=FlowRunner::withoutNode(nodes,completed);
        must(left.size()==1&&left[0].toObject().value("node_id").toString()=="b","completed node with changed fields not removed");
        must(FlowRunner::withoutNode(nodes,QJsonObject{{"task","x"}}).size()==2,"node without id removed something");
        must(FlowRunner::withoutNode(QJsonDocument::fromJson(QJsonDocument(nodes).toJson()).array(),completed).size()==1,"restored (reloaded) list not matched");
    });
    auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};
    test("all_registered_task_entries_compile_with_supported_engines",[&]{
        auto read=[](const QString &path){QFile f(BuiltinResources::path(path));if(!f.open(QIODevice::ReadOnly))throw std::runtime_error("Audit input missing");return QJsonDocument::fromJson(f.readAll()).object();};
        const auto catalog=read("tasks/catalog.json").value("tasks").toArray();const auto manifest=read("scripts/builtin/legacy/manifest.json").value("tasks").toArray();QJsonArray results;
        int residentCount=0,externalCount=0,contracts=0;qsizetype maximum=0;
        for(const auto &v:manifest){const auto entry=v.toObject();const auto id=entry.value("id").toString();const auto task=plannedTask(catalog,id);
            const auto engines=entry.value("supported_engines").toArray();const auto engine=engines.isEmpty()?QString("游戏内 Lua"):engines.first().toString();
            QJsonObject config{{"legacy_id",id},{"engine",engine},{"timeout_seconds",entry.value("timeout_seconds").toInt(600)}};
            if(entry.value("combat").toBool())config.insert("combat",true);
            for(const auto &setting:task.value("settings").toArray()){const auto s=setting.toObject();config.insert(s.value("key").toString(),s.value("default"));}
            if(config.value("combat").toBool()){
                config.insert("combat_scene",id=="zhenlong_combat"?61:3);config.insert("combat_radius",45);config.insert("combat_min_hp",25);
                config.insert("combat_interval_ms",1000);config.insert("combat_stall_seconds",60);config.insert("combat_kill_goal",1);config.insert("combat_skills","");config.insert("entry_mode","自动入场");
            }
            QString error,path;QJsonObject resolved;must(validateLegacyConfig(config,error),qUtf8Printable(id+": "+error));
            must(resolveLegacyEntry("scripts/builtin/legacy",id,resolved,path,error),qUtf8Printable(error));qsizetype bytes=0;
            if(engine=="游戏内 Lua"){
                const auto source=prepareResidentScript("scripts/builtin/legacy",path,config,error);must(error.isEmpty()&&!source.isEmpty(),qUtf8Printable(id+": "+error));bytes=source.size();maximum=qMax(maximum,bytes);
                ResidentFake host;resident::Vm vm(host);std::string why;must(vm.start(source.toStdString(),why),(id+": "+QString::fromStdString(why)).toUtf8().constData());
                vm.stop();must(vm.allocated()==0&&host.evaluations==0&&host.casts==0,"Compile-only entry audit issued an action or leaked its VM");++residentCount;
            }else{
                LegacyRunner runner;const bool loaded=runner.load(path,error,"scripts/builtin/legacy/compat.lua",config);
                must(loaded,qUtf8Printable(id+": "+error));++externalCount;
            }
            const auto contract=entry.value("validation_contract").toString();if(!contract.isEmpty())++contracts;
            const auto completion=!contract.isEmpty()?"strict_receipt":entry.value("combat").toBool()?"combat_death_and_exit_checks":id=="daily_sign"?"dedicated_sign_state":"script_return_only";
            results.append(QJsonObject{{"id",id},{"name",task.value("name").toString(entry.value("name").toString())},{"category",task.value("category")},
                {"engine",engine},{"entry",entry.value("entry")},{"package_bytes",double(bytes)},{"entry_loaded",true},{"runtime_tested_in_this_audit",false},{"completion_validation",completion}});
        }
        const auto directory=root+"/artifacts/task-audit-2026-10-27";must(QDir().mkpath(directory),"Cannot write audit directory");QFile out(directory+"/entry-audit.json");must(out.open(QIODevice::WriteOnly),"Cannot write entry audit");
        out.write(QJsonDocument(QJsonObject{{"passed",true},{"registered_entries",results.size()},{"resident_entries",residentCount},{"external_entries",externalCount},
            {"strict_completion_contracts",contracts},{"largest_resident_package_bytes",double(maximum)},{"game_actions_sent",0},{"real_game_tested",false},{"entries",results}}).toJson());
        const int xiaomi=148; // imported 小蜜文本 tasks (docs/XIAOMI_SCRIPT_MAP.md)
        must(results.size()==274+xiaomi&&residentCount==273+xiaomi&&externalCount==1&&contracts==85,"Task runtime audit coverage changed");
        QString error;QJsonObject missing{{"legacy_id","not_registered"},{"timeout_seconds",300},{"engine","游戏内 Lua"}};
        must(!validateLegacyConfig(missing,error),"Unregistered non-combat task passed preflight");
        missing.insert("legacy_id","shimen");must(!validateLegacyConfig(missing,error),"Unadapted Shimen passed preflight");
        missing.insert("legacy_id","tlzz_keju");must(!validateLegacyConfig(missing,error)&&error.contains("外部兼容"),"Unsupported exam engine passed preflight");
    });
    test("sequential_completion_unknown_limit_and_failure_policies",[&]{
        const QDateTime now(QDate(2026,10,27),QTime(12,0));QString error;
        auto node=[](QString id,QString policy){return QJsonObject{{"node_id",id},{"task","fixture"},{"enabled",true},{"params",QJsonObject{{"failure",policy}}}};};
        for(const auto &policy:QStringList{"停止队列","跳过本项","等待人工"}){
            auto first=node("first",policy);first.insert("start_minute",0);first.insert("end_minute",1439);
            FlowRunner flow;must(flow.start({{"queue",QJsonArray{node("next",policy)}},{"scheduled",QJsonArray{first}},{"flow",QJsonObject{{"delete_completed",true},{"daily_scheduled",false}}}},error),qUtf8Printable(error));
            must(flow.poll(now).value("node_id").toString()=="first","Due scheduled task was not selected");
            const QJsonObject unverified{{"event","completed"},{"operation","legacy"},{"verified",false}};
            must(!TaskCompletion::eventVerified(unverified),"A bare script return was accepted as verified completion");flow.finish(false,"unverified");
            must(flow.states().value("first").toString()=="未核验","Unknown completion mislabeled done");
            if(policy=="停止队列")must(!flow.active()&&flow.poll(now).isEmpty(),"Unknown task advanced a stop-policy queue");
            if(policy=="跳过本项")must(flow.poll(now).value("node_id").toString()=="next","Explicit skip policy failed to advance");
            if(policy=="等待人工"){must(flow.paused()&&flow.poll(now).isEmpty(),"Unknown completion ignored manual pause");flow.pause(false);must(flow.poll(now).value("node_id").toString()=="next","Manual resume replayed unknown action");}
        }
        // Worker finish → completed event → launcher outcome → queue, through the same functions Worker and the
        // launcher call (TaskCompletion::facts / judge / completedEvent / flowOutcome), starting from the resident
        // poll state. A dungeon's own contract decides: healer-only (zero own kills) and "today's count is full"
        // complete it; kills never stand in for a final receipt; only the kill task counts kills.
        struct Case{const char *name;QJsonObject config;bool combat;bool killTask;QJsonObject state;bool left;bool accepted;bool verified;};
        auto receipt=[](QString status){return status.isEmpty()?QJsonObject{}:QJsonObject{{"status",status},{"verified",true}};};
        auto poll=[&](QString status,int kills,bool boss=false){return QJsonObject{{"state",3},{"kills",kills},{"boss",boss},{"task_result",receipt(status)}};};
        const QJsonObject yanzi{{"legacy_id","yanzi"},{"validation_contract","yanzi_flow_v1"},{"combat_kill_goal",1}};
        const QJsonObject sijue{{"legacy_id","sijue"},{"validation_contract","sijue_flow_v1"},{"combat_kill_goal",1}};
        const QJsonObject generic{{"legacy_id","pet_sell_npc"},{"combat_kill_goal",1}};
        const QJsonObject killing{{"legacy_id","dungeon_combat"},{"combat_kill_goal",3}};
        const QJsonObject chess{{"legacy_id","zhenlong_combat"},{"combat_kill_goal",1}};
        const Case cases[]={
            {"healer-only dungeon",yanzi,true,false,poll("done",0),false,true,true},
            {"count already full",yanzi,true,false,poll("limit_reached",0),false,true,true},
            {"kills without receipt",sijue,true,false,poll("",40),false,false,false},
            {"generic original dungeon",generic,true,false,poll("",1),false,true,false},
            {"kill goal short",killing,true,true,poll("",2),false,false,false},
            {"kill goal met",killing,true,true,poll("",3),false,true,true},
            {"chess boss without exit",chess,true,false,poll("",5,true),false,false,false},
            {"chess boss and exit",chess,true,false,poll("",5,true),true,true,true},
        };
        for(const auto &c:cases){
            const auto j=TaskCompletion::judge(TaskCompletion::facts(c.config,c.combat,c.killTask,c.state,c.left));
            must(j.accepted==c.accepted&&j.verified==c.verified&&(j.accepted||!j.reason.isEmpty()),c.name);
            FlowRunner flow;must(flow.start({{"queue",QJsonArray{node("first","跳过本项"),node("next","跳过本项")}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},error),qUtf8Printable(error));
            flow.poll(now);
            if(!j.accepted){flow.finish(false,j.reason);must(flow.states().value("first").toString()!="完成",c.name);continue;}
            const auto result=TaskCompletion::flowOutcome(TaskCompletion::completedEvent(j,c.state.value("task_result").toObject()));
            flow.finish(result.verified,result.outcome);
            must((flow.states().value("first").toString()=="未核验")==!j.verified,c.name);
            if(c.state.value("task_result").toObject().value("status").toString()=="limit_reached")must(flow.states().value("first").toString()=="已达上限",c.name);
            must(flow.poll(now).value("node_id").toString()=="next",c.name);
        }
        for(const auto &status:QStringList{"done","already_done","limit_reached"}){
            FlowRunner flow;auto first=node("first","停止队列");must(flow.start({{"queue",QJsonArray{first,node("next","停止队列")}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},error),qUtf8Printable(error));
            const QJsonObject receipt{{"status",status},{"verified",true}};must(TaskCompletion::eventVerified({{"task_result",receipt}}),"Verified terminal receipt was lost");
            flow.poll(now);flow.finish(true,status);must(flow.poll(now).value("node_id").toString()=="next","Verified result did not advance in order");
        }
    });
}
}
