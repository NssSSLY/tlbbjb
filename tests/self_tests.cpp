#include "core.hpp"
#include "route_catalog.hpp"
#include "flow_runner.hpp"
#include "profile_config.hpp"
#include "legacy_runner.hpp"
#include "gameplay_client.hpp"
#include "combat_tests.hpp"
#include "resource_tests.hpp"
#include "resident_tests.hpp"
#include "original_rules_tests.hpp"
#include "daily_task_tests.hpp"
#include "task_audit_tests.hpp"
#include "dungeon_sweep_tests.hpp"
#include "sanhuan_tests.hpp"
#include "water_prison_tests.hpp"
#include "sijue_tests.hpp"
#include "yanzi_tests.hpp"
#include "shaoshi_tests.hpp"
#include "piaomiao_tests.hpp"
#include "bingsheng_tests.hpp"
#include "langhuan_tests.hpp"
#include "wangling_tests.hpp"
#include "sanshen_tests.hpp"
#include "guanshan_tests.hpp"
#include "yezhu_tests.hpp"
#include "mingwang_tests.hpp"
#include "tianbo_tests.hpp"
#include "fenghuang_tests.hpp"
#include "yijue_tests.hpp"
#include "juling_tests.hpp"
#include "small_dungeon_tests.hpp"
#include "tianjiang_tests.hpp"
#include "activity_tests.hpp"
#include "saodang_tests.hpp"
#include "battle_tests.hpp"
#include "long_task_tests.hpp"
#include "short_task_tests.hpp"
#include "daily_routine_tests.hpp"
#include <QDateTime>
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QProcess>
#include <QSet>
#include <QHash>
#include <QRegularExpression>
#include <QTemporaryDir>
#include <cwchar>
#include <functional>
#include <stdexcept>

namespace tlbb {
static void require(bool ok, const char *message) {
    if (!ok)
        throw std::runtime_error(message);
}
static void write(const QString &path, const QByteArray &bytes) {
    QFile file(path);
    require(file.open(QIODevice::WriteOnly), "Cannot write fixture");
    require(file.write(bytes) == bytes.size(), "Incomplete fixture write");
}
static QJsonObject configuration(int rounds = 1) {
    return {{"x", 360},         {"y", 317},       {"crop", "测试作物"},
            {"rounds", rounds}, {"tolerance", 1}, {"timeout_seconds", 20}};
}
struct Child {
    QProcess process;
    QByteArray buffer;
    QJsonArray events;
    QString session;
    ~Child() {
        if (process.state() != QProcess::NotRunning) {
            process.kill();
            process.waitForFinished(1000);
        }
    }
    void launch(const QStringList &args) {
        process.setCreateProcessArgumentsModifier(
            [](QProcess::CreateProcessArguments *a) { a->flags |= CREATE_NO_WINDOW; });
        process.start(QCoreApplication::applicationFilePath(), args);
        require(process.waitForStarted(2000), "Child failed to start");
    }
    void pump() {
        buffer += process.readAllStandardOutput();
        require(buffer.size() < 65536, "Worker output grew without bounds");
        while (buffer.contains('\n')) {
            int i = buffer.indexOf('\n');
            auto event = QJsonDocument::fromJson(buffer.left(i)).object();
            buffer.remove(0, i + 1);
            if (!event.isEmpty())
                events.append(event);
        }
    }
    QJsonObject waitEvent(const QString &type, int timeout = 3000) {
        QElapsedTimer timer;
        timer.start();
        while (timer.elapsed() < timeout) {
            pump();
            for (const auto &e : events)
                if (e.toObject().value("event").toString() == type)
                    return e.toObject();
            process.waitForReadyRead(20);
            QCoreApplication::processEvents();
        }
        throw std::runtime_error(
            ("Missing worker event: " + type + " " + QString::fromUtf8(process.readAllStandardError()))
                .toStdString());
    }
    void send(QJsonObject command) {
        command.insert("session", session);
        process.write(QJsonDocument(command).toJson(QJsonDocument::Compact) + "\n");
        process.waitForBytesWritten(500);
    }
};
int runSelfTests(const QString &root, const QString &reportPath) {
    QDir().mkpath(root + "/artifacts");
    QTemporaryDir temp(root + "/artifacts/test-fixtures-XXXXXX");
    QJsonArray passed;
    QString failure;
    auto test = [&](const QString &name, const std::function<void()> &function) {
        if (!failure.isEmpty())
            return;
        try {
            function();
            passed.append(name);
        } catch (const std::exception &e) {
            failure = name + ": " + QString::fromUtf8(e.what());
        }
    };
    QString path = root + "/scripts/luoyang_plant.lua";
    auto node=[](QString id,bool timed=false){QJsonObject n{{"node_id",id},{"task","luoyang_move"},{"enabled",true},{"params",QJsonObject{{"x",360},{"failure","停止队列"}}}};if(timed){n.insert("start_minute",600);n.insert("end_minute",660);}return n;};
    auto moment=[](const char *s){return QDateTime::fromString(QString::fromLatin1(s),Qt::ISODate);};
    test("scheduled_journal_survives_restart_and_refuses_bad_storage", [&] {
        const auto path=temp.filePath("scheduled-journal.json");QString error;
        const QJsonObject plan{{"queue",QJsonArray{}},{"scheduled",QJsonArray{node("saved",true)}},{"flow",QJsonObject{}}};
        FlowRunner first;first.setJournalPath(path);require(first.start(plan,error),qPrintable(error));
        require(!first.poll(moment("2026-10-29T10:05:00+08:00")).isEmpty(),"Initial journal dispatch missing");
        FlowRunner restarted;restarted.setJournalPath(path);require(restarted.start(plan,error),qPrintable(error));
        require(restarted.poll(moment("2026-10-29T10:06:00+08:00")).isEmpty(),"Restart replayed issued task");
        require(!restarted.poll(moment("2026-10-30T10:06:00+08:00")).isEmpty(),"Next daily window blocked");
        restarted.finish(true,"done");restarted.stop();require(restarted.start(plan,error),qPrintable(error));
        require(restarted.poll(moment("2026-10-30T10:07:00+08:00")).isEmpty(),"Completed task replayed");
        FlowRunner other;other.setJournalPath(temp.filePath("other-role.json"));require(other.start(plan,error),qPrintable(error));
        require(!other.poll(moment("2026-10-30T10:07:00+08:00")).isEmpty(),"Journal leaked between roles");
        write(path,"invalid");FlowRunner corrupt;corrupt.setJournalPath(path);require(!corrupt.start(plan,error),"Corrupt journal ignored");
        FlowRunner unwritable;unwritable.setJournalPath(path+"/child.json");require(unwritable.start(plan,error),qPrintable(error));
        require(unwritable.poll(moment("2026-10-29T10:05:00+08:00")).isEmpty()&&!unwritable.journalError().isEmpty(),"Dispatch preceded durable journal");
    });
    test("flow_bounds_identity_and_immutable_snapshot", [&] {
        QJsonObject plan{{"queue",QJsonArray{node("a")}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}};QString error;FlowRunner flow;
        require(flow.start(plan,error),qPrintable(error));auto entries=plan.value("queue").toArray();auto n=entries[0].toObject();n.insert("params",QJsonObject{{"x",999}});entries[0]=n;plan.insert("queue",entries);
        require(flow.poll(moment("2026-10-25T09:00:00+08:00")).value("params").toObject().value("x").toInt()==360,"Running plan followed draft edits");
        require(!flow.start(plan,error),"Active plan overwritten");flow.stop();
        plan.insert("scheduled",QJsonArray{node("a",true)});require(!FlowRunner::validate(plan,error),"Duplicate cross-list identity accepted");
        auto bad=node("time",true);bad.insert("end_minute",600);plan.insert("scheduled",QJsonArray{bad});require(!FlowRunner::validate(plan,error),"Empty time window accepted");
        QJsonArray many;for(int i=0;i<65;++i)many.append(node(QString("n%1").arg(i)));plan.insert("queue",many);require(!FlowRunner::validate(plan,error),"Oversized list accepted");
    });
    test("scheduled_nodes_wait_for_completion_and_do_not_repeat", [&] {
        FlowRunner flow;QString error;require(flow.start({{"queue",QJsonArray{node("a"),node("b")}},{"scheduled",QJsonArray{node("t",true)}},{"flow",QJsonObject{{"daily_scheduled",true}}}},error),qPrintable(error));
        require(flow.poll(moment("2026-10-25T09:59:00+08:00")).value("node_id")==QJsonValue("a"),"Wrong first regular node");
        require(flow.poll(moment("2026-10-25T10:05:00+08:00")).isEmpty(),"Timed task preempted active action");flow.finish(true);
        require(flow.poll(moment("2026-10-25T10:05:00+08:00")).value("node_id")==QJsonValue("t"),"Timed task not inserted at boundary");flow.finish(true);
        require(flow.poll(moment("2026-10-25T10:05:00+08:00")).value("node_id")==QJsonValue("b"),"Regular queue did not resume");flow.finish(true);
        require(flow.poll(moment("2026-10-25T10:10:00+08:00")).isEmpty()&&flow.active(),"Same window repeated or monitor exited");
        require(flow.poll(moment("2026-10-24T10:10:00+08:00")).isEmpty(),"Clock rollback repeated a task");
        require(flow.poll(moment("2026-10-26T10:10:00+08:00")).value("node_id")==QJsonValue("t"),"Next daily window not eligible");
        flow.finish(true);flow.stop();require(flow.poll(moment("2026-10-27T10:10:00+08:00")).isEmpty(),"Stopped scheduler dispatched work");
    });
    test("overnight_windows_pause_and_single_run_are_consistent", [&] {
        auto n=node("night",true);n.insert("start_minute",1380);n.insert("end_minute",120);FlowRunner flow;QString error;
        require(flow.start({{"queue",QJsonArray{}},{"scheduled",QJsonArray{n}},{"flow",QJsonObject{}}},error),qPrintable(error));
        flow.pause(true);require(flow.poll(moment("2026-10-25T23:30:00+08:00")).isEmpty(),"Paused scheduler dispatched");flow.pause(false);
        require(!flow.poll(moment("2026-10-25T23:30:00+08:00")).isEmpty(),"Overnight start missing");flow.finish(true);
        require(flow.poll(moment("2026-10-26T01:30:00+08:00")).isEmpty(),"Midnight split one window into two");
        require(!flow.poll(moment("2026-10-26T23:30:00+08:00")).isEmpty(),"Next overnight window missing");flow.stop();
        n.insert("node_id","night-boundary"); // Independent one-shot schedule, not a replay after clock rollback.
        require(flow.start({{"queue",QJsonArray{}},{"scheduled",QJsonArray{n}},{"flow",QJsonObject{{"daily_scheduled",false}}}},error),qPrintable(error));
        require(flow.poll(moment("2026-10-25T02:00:00+08:00")).isEmpty(),"End boundary incorrectly included");
        require(!flow.poll(moment("2026-10-25T23:00:00+08:00")).isEmpty(),"Start boundary incorrectly excluded");flow.finish(true);flow.poll(moment("2026-10-25T23:01:00+08:00"));require(!flow.active(),"One-shot monitor did not finish");
        n.insert("node_id","night-delete");
        require(flow.start({{"queue",QJsonArray{}},{"scheduled",QJsonArray{n}},{"flow",QJsonObject{{"daily_scheduled",true},{"delete_completed",true}}}},error),qPrintable(error));flow.poll(moment("2026-10-25T23:00:00+08:00"));flow.finish(true);require(flow.poll(moment("2026-10-26T23:00:00+08:00")).isEmpty()&&!flow.active(),"Deleted timed node repeated next day");
    });
    test("flow_loop_limit_and_failure_policy_release_executor", [&] {
        FlowRunner flow;QString error;require(flow.start({{"queue",QJsonArray{node("a")}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{{"loop",true},{"loop_limit",2}}}},error),qPrintable(error));
        const auto now=moment("2026-10-25T10:00:00+08:00");require(!flow.poll(now).isEmpty(),"First loop missing");flow.finish(true);require(flow.poll(now).isEmpty(),"Loop spun in same poll");require(!flow.poll(now).isEmpty(),"Second loop missing");flow.finish(true);flow.poll(now);require(!flow.active(),"Loop limit ignored");
        auto n=node("fail");n.insert("params",QJsonObject{{"failure","等待人工"}});require(flow.start({{"queue",QJsonArray{n,node("b")}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},error),qPrintable(error));flow.poll(now);flow.finish(false);require(flow.paused()&&!flow.busy()&&flow.poll(now).isEmpty(),"Manual failure did not pause");flow.pause(false);require(flow.poll(now).value("node_id")==QJsonValue("b"),"Manual resume repeated failed action");
    });
    test("profile_migration_and_portable_import_exclude_identity", [&] {
        QJsonObject old{{"queue",QJsonArray{QJsonObject{{"task","plant"},{"params",QJsonObject{{"mode","preview"}}}}}},{"tasks",QJsonObject{{"mine",QJsonObject{{"reference_route",QJsonObject{{"id","source-id"}}}}}}},{"account","private-account"},{"password","private-secret"},{"identity",QJsonObject{{"pid",123}}},{"bag",QJsonObject{{"destroy_enabled",true}}},{"tab",8}};
        const auto migrated=migrateTaskProfile(old);require(migrated.value("tab").toInt()==0&&migrated.value("queue").toArray().size()==1,"Legacy task data lost");
        const auto exported=portableProfile(migrated);const auto config=exported.value("config").toObject();require(!config.contains("account")&&!config.contains("password")&&!config.contains("identity"),"Private identity exported");require(config.value("bag").toObject().value("destroy_enabled")==QJsonValue(false),"Destroy flag survived export");
        QString error;QJsonObject imported;require(readPortableProfile(exported,imported,error),qPrintable(error));require(imported.value("tasks")==migrated.value("tasks"),"Reference route removed during migration");
        auto invalid=exported;auto c=config;auto n=node("bad",true);n.insert("end_minute",600);c.insert("scheduled",QJsonArray{n});invalid.insert("config",c);require(!readPortableProfile(invalid,imported,error)&&imported.isEmpty(),"Malformed imported schedule partially applied");
    });
    test("worker_movement_preview_has_no_plant_effect", [&] {
        Child game,worker;game.launch({"--fixture-game","--lifetime","20000"});ProcessBinding identity;
        require(identity.open(quint32(game.process.processId()),root,{},true),qPrintable(identity.error));worker.session="movement-preview";
        worker.launch({"--worker","--test-target","--target-pid",QString::number(identity.info().pid),"--created",identity.info().created,"--session",worker.session,"--game-root",root,"--script",path});worker.waitEvent("ready");
        auto config=configuration();config.insert("operation","move");config.insert("crop","");worker.send({{"op","start"},{"mode","preview"},{"config",config}});
        const auto result=worker.waitEvent("completed",5000);require(result.value("preview").toBool()&&result.value("state").toObject().value("planted_count").toInt()==0,"Movement preview planted crops");
        require(result.value("actions").toInt()==1,"Movement preview submitted unexpected actions");
    });
    test("reference_route_catalog_is_bounded_and_unverified", [&] {
        QJsonArray routes;QString error;
        require(RouteCatalog::load(root+"/scripts/data/reference_routes.json",routes,error),qPrintable(error));
        require(routes.size()==38,"Reference route count changed unexpectedly");
        int points=0;for(const auto &r:routes)points+=r.toObject().value("points").toArray().size();
        require(points==1094,"Reference point sequence was truncated");
        const auto ref=RouteCatalog::reference(routes[0].toObject());
        require(ref.value("verified")==QJsonValue(false)&&ref.value("runtime_enabled")==QJsonValue(false),"Reference became executable");
        require(!ref.contains("points")&&!ref.contains("map"),"Unverified map or points copied into action parameters");
        require(RouteCatalog::load(root+"/scripts/data/tlzz_reference_routes.json",routes,error)&&routes.size()==72,"Assistant references missing");
        points=0;for(const auto &r:routes)points+=r.toObject().value("points").toArray().size();
        require(points==912&&routes[0].toObject().value("id").toString().startsWith("tlzz-"),"Assistant point sequence or namespace changed");
        QFile assistantFile(root+"/scripts/data/tlzz_reference_routes.json");require(assistantFile.open(QIODevice::ReadOnly),"Assistant source fixture missing");
        auto invalid=QJsonDocument::fromJson(assistantFile.readAll()).object();auto entries=invalid.value("routes").toArray();auto first=entries[0].toObject();auto source=first.value("source").toObject();source.insert("path","data/坐标/../../private.json");first.insert("source",source);entries[0]=first;invalid.insert("routes",entries);
        require(!RouteCatalog::parse(QJsonDocument(invalid).toJson(),routes,error)&&routes.isEmpty(),"Assistant traversal path accepted");
    });
    test("reference_route_invalid_catalog_rejected_atomically", [&] {
        QFile file(root+"/scripts/data/reference_routes.json");require(file.open(QIODevice::ReadOnly),"Missing route fixture");
        const auto valid=QJsonDocument::fromJson(file.readAll()).object();
        auto check=[&](QJsonObject input){QJsonArray result{QJsonObject{{"stale",true}}};QString error;require(!RouteCatalog::parse(QJsonDocument(input).toJson(),result,error)&&result.isEmpty()&&!error.isEmpty(),"Invalid route left usable partial state");};
        auto bad=valid;bad.insert("runtime_enabled",true);check(bad);
        auto entries=valid.value("routes").toArray();auto entry=entries[0].toObject();
        entry.insert("verified",true);entries[0]=entry;bad=valid;bad.insert("routes",entries);check(bad);
        entries=valid.value("routes").toArray();entry=entries[0].toObject();auto source=entry.value("source").toObject();
        source.insert("path","坐标/../data.txt");entry.insert("source",source);entries[0]=entry;bad=valid;bad.insert("routes",entries);check(bad);
        entries=valid.value("routes").toArray();entries[1]=entries[0];bad=valid;bad.insert("routes",entries);check(bad);
        entries=valid.value("routes").toArray();entry=entries[0].toObject();auto points=entry.value("points").toArray();auto point=points[0].toObject();
        point.insert("x","61");points[0]=point;entry.insert("points",points);entries[0]=entry;bad=valid;bad.insert("routes",entries);check(bad);
        QJsonArray result;QString error;require(!RouteCatalog::parse(QByteArray(512*1024+1,' '),result,error),"Unbounded route file accepted");
    });
    test("original_daily_lua_preserves_sleep_and_command_order", [&] {
        LegacyRunner runner;QString error;require(runner.load(root+"/scripts/legacy/daily_sign.lua",error),"Original daily Lua did not load");
        const QList<QPair<gameplay::Command,int>> expected{{gameplay::DailySign,0},{gameplay::ClaimMonthlyReward,1},{gameplay::ClaimMonthlyReward,2},{gameplay::ClaimMonthlyReward,3},{gameplay::ClaimMonthlyReward,4},{gameplay::ClaimMonthlyReward,5},{gameplay::CloseMonthly,0}};
        int actions=0;bool finished=false;quint64 lastId=0;
        for(qint64 now=0;now<=10000&&!finished;now+=100){
            LegacyRequest request;const auto progress=runner.poll(now,request,error);
            require(progress!=LegacyRunner::Failed,qPrintable(error));
            if(progress==LegacyRunner::Action){
                require(actions<expected.size()&&request.command==expected[actions].first&&request.argument==expected[actions].second,"Original rule sequence changed");
                require(request.id>lastId&&now>=1000,"Sleep or request identity was lost");lastId=request.id;
                require(!runner.acknowledge(request.id+1,true),"Wrong receipt identity accepted");
                LegacyRequest duplicate;require(runner.poll(now,duplicate,error)==LegacyRunner::Waiting,"Pending action was replayed");
                require(runner.acknowledge(request.id,true)&&!runner.acknowledge(request.id,true),"Duplicate receipt accepted");++actions;
            }
            finished=progress==LegacyRunner::Finished;
        }
        require(finished&&actions==7&&runner.allocated()<16*1024*1024,"Original daily Lua did not finish within bounds");
    });
    test("legacy_game_calls_are_typed_and_failure_is_not_replayed", [&] {
        gameplay::Command command=gameplay::Query;int argument=0;
        require(!LegacyRunner::parseGameCall("return Player:GetData('NAME')",command,argument),"Arbitrary game script accepted");
        require(!LegacyRunner::parseGameCall("Clear_XSCRIPT();Set_XSCRIPT_Function_Name(\"GetPrize\");Set_XSCRIPT_ScriptID(999999);Set_XSCRIPT_Parameter(0,1);Set_XSCRIPT_ParamCount(1);Send_XSCRIPT()",command,argument),"Other server script accepted");
        LegacyRunner runner;QString error;require(runner.load(root+"/scripts/legacy/daily_sign.lua",error),"Daily fixture failed");LegacyRequest request;
        require(runner.poll(0,request,error)==LegacyRunner::Waiting&&runner.poll(1000,request,error)==LegacyRunner::Action,"First original action missing");
        require(runner.acknowledge(request.id,false,"uncertain delivery"),"Failure receipt refused");
        require(runner.poll(1100,request,error)==LegacyRunner::Failed&&error=="uncertain delivery","Failed action was resumed");
    });
    test("legacy_lua_sandbox_and_execution_budgets", [&] {
        const QList<QByteArray> sources{"while true do end","local x=string.rep('X',32*1024*1024)","io.open('private.txt')","GetLuaValue('os.execute(1)','',0)","Sleep(60001)","error({})"};
        int index=0;for(const auto &source:sources){
            const auto file=temp.path()+"/bad-legacy-"+QString::number(index++)+".lua";write(file,source);
            LegacyRunner runner;QString error;require(runner.load(file,error),"Malformed fixture source");LegacyRequest request;
            require(runner.poll(0,request,error)==LegacyRunner::Failed&&!error.isEmpty(),"Unsupported or unbounded legacy script ran");
            require(runner.allocated()<=16*1024*1024,"Legacy Lua exceeded its memory budget");
        }
    });
    test("gameplay_packet_bounds_and_late_callback_cancellation", [&] {
        require(sizeof(gameplay::Packet)<4096&&gameplay::Packet{}.command==gameplay::Query,"Unsafe gameplay packet default");
        require(gameplay::validCommand(gameplay::ClaimMonthlyReward,1)&&gameplay::validCommand(gameplay::ClaimMonthlyReward,5),"Valid reward rejected");
        require(!gameplay::validCommand(gameplay::ClaimMonthlyReward,0)&&!gameplay::validCommand(gameplay::ClaimMonthlyReward,6)&&!gameplay::validCommand(99,0)&&!gameplay::validCommand(gameplay::Query,1),"Unsupported gameplay request accepted");
        gameplay::Packet packet;gameplay::cancelPending(packet);require(packet.status==gameplay::Cancelled&&packet.error==WAIT_TIMEOUT,"Pending request was not cancelled");
        require(InterlockedCompareExchange(&packet.status,gameplay::Executing,gameplay::Pending)==gameplay::Cancelled,"Late action claimed cancelled packet");
        packet.status=gameplay::Executing;gameplay::cancelPending(packet);require(packet.status==gameplay::Executing,"Executing callback lost ownership");
        QString error;require(validateDailySignConfig({{"timeout_seconds",90}},error),"Valid sign config refused");
        require(!validateDailySignConfig({{"timeout_seconds",301}},error)&&!validateDailySignConfig({{"timeout_seconds",9}},error),"Unbounded sign timeout accepted");
    });
    test("lua_wait_duration_clock_and_validation", [&] {
        LuaTask lua;QString error;Decision decision;
        require(lua.load(root+"/scripts/utility/wait_until.lua",error),qPrintable(error));
        QJsonObject config{{"wait_kind","等待时长"},{"wait_seconds",2},{"timeout_seconds",5}};
        require(validateWaitConfig(config,error),"Valid duration refused");
        require(lua.step({{"active_elapsed_ms",1999}},config,{},decision,error)&&decision.kind=="wait","Duration completed early");
        require(lua.step({{"active_elapsed_ms",2000}},config,{},decision,error)&&decision.kind=="complete","Duration did not complete");
        config.insert("wait_kind","指定时刻");config.insert("wait_time","23:59");config.insert("target_epoch_ms",5000);
        require(validateWaitConfig(config,error),"Valid clock refused");
        require(lua.step({{"now_ms",4999}},config,{},decision,error)&&decision.kind=="wait","Clock completed early");
        require(lua.step({{"now_ms",5000}},config,{},decision,error)&&decision.kind=="complete","Clock did not complete");
        config.insert("wait_time","24:00");require(!validateWaitConfig(config,error),"Bad clock accepted");
        config.insert("wait_kind","等待时长");config.insert("wait_seconds",6);require(!validateWaitConfig(config,error),"Short timeout accepted");
    });
    test("lua_plant_closed_loop_and_duplicate_gate", [&] {
        LuaTask lua;
        QString error;
        require(lua.load(path, error), qPrintable(error));
        PreviewWorld world;
        QJsonObject context;
        bool done = false;
        for (int i = 0; i < 30; ++i) {
            world.advance();
            if (world.pending())
                continue;
            Decision d;
            require(lua.step(world.snapshot(), configuration(2), context, d, error), qPrintable(error));
            context = d.context;
            if (d.kind == "move" || d.kind == "plant") {
                require(world.submit(d, error), qPrintable(error));
                require(!world.submit(d, error), "Duplicate pending action accepted");
            }
            if (d.kind == "complete") {
                done = true;
                break;
            }
        }
        require(done, "Task did not complete");
        require(world.actions == 3, "Unexpected duplicate or missing actions");
        require(world.snapshot().value("planted_count").toInt() == 2, "Effects not confirmed");
    });
    test("manual_position_change_replans", [&] {
        LuaTask lua;
        QString error;
        require(lua.load(path, error), qPrintable(error));
        auto state = PreviewWorld{}.snapshot();
        state.insert("x", 100);
        Decision d;
        require(lua.step(state, configuration(), {}, d, error), qPrintable(error));
        require(d.kind == "move" && d.x == 360 && d.y == 317, "Did not replan to configured position");
    });
    test("lua_movement_without_plant_state_and_manual_replan", [&] {
        LuaTask lua;
        QString error;
        require(lua.load(path, error), qPrintable(error));
        auto c = configuration();
        c.insert("operation", "move");
        c.insert("crop", "");
        require(validatePlantConfig(c, error), "Movement incorrectly requires a crop");
        QJsonObject state{{"position_valid", true}, {"map", "洛阳"}, {"x", 356}, {"y", 318}};
        Decision decision;
        require(lua.step(state, c, {}, decision, error) && decision.kind == "move",
                "Movement incorrectly requires planting state");
        state.insert("x", 360);
        state.insert("y", 317);
        require(lua.step(state, c, decision.context, decision, error) && decision.kind == "complete",
                "Movement did not confirm arrival");
        state.insert("x", 357);
        require(lua.step(state, c, decision.context, decision, error) && decision.kind == "move",
                "Movement did not replan after manual position change");
        state.insert("map", "其他地图");
        require(lua.step(state, c, {}, decision, error) && decision.kind == "error",
                "Movement accepted an unsupported map");
    });
    test("wrong_map_missing_position_and_seed", [&] {
        LuaTask lua;
        QString error;
        require(lua.load(path, error), qPrintable(error));
        Decision d;
        auto state = PreviewWorld{}.snapshot();
        state.insert("map", "其他地图");
        require(lua.step(state, configuration(), {}, d, error) && d.kind == "error", "Wrong map accepted");
        state.insert("map", "洛阳");
        state.insert("position_valid", false);
        require(lua.step(state, configuration(), {}, d, error) && d.kind == "error",
                "Invalid position accepted");
        state.insert("position_valid", true);
        state.insert("x", 360);
        state.insert("y", 317);
        state.insert("seed_available", false);
        require(lua.step(state, configuration(), {}, d, error) && d.kind == "error", "Missing seed accepted");
    });
    test("configuration_bounds", [&] {
        QString error;
        auto c = configuration();
        require(validatePlantConfig(c, error), "Valid parameters rejected");
        c.insert("crop", "");
        require(!validatePlantConfig(c, error), "Empty crop accepted");
        c = configuration();
        c.insert("rounds", 1.5);
        require(!validatePlantConfig(c, error), "Fractional rounds accepted");
        c = configuration();
        c.insert("timeout_seconds", -1);
        require(!validatePlantConfig(c, error), "Invalid timeout accepted");
    });
    const QByteArray prefix =
        "return {id='luoyang_plant',version='test',context_schema=1,step=function(s,c,x) ";
    test("lua_sandbox_and_strict_results", [&] {
        QString file = temp.filePath("sandbox.lua");
        write(file, "assert(io==nil and os==nil and package==nil and debug==nil and load==nil)\n" + prefix +
                        "return {kind='wait',context=x} end}");
        LuaTask lua;
        QString error;
        require(lua.load(file, error), qPrintable(error));
        Decision d;
        require(lua.step(PreviewWorld{}.snapshot(), configuration(), {}, d, error), qPrintable(error));
        write(file, prefix + "return setmetatable({}, {__index=function() while true do end end}) end}");
        LuaTask bad;
        require(bad.load(file, error), qPrintable(error));
        require(!bad.step({}, configuration(), {}, d, error), "Metatable output accepted");
    });
    test("lua_initialization_and_step_budgets", [&] {
        QString file = temp.filePath("loop.lua"), error;
        write(file, "while true do end");
        LuaTask init;
        require(!init.load(file, error), "Infinite initialization was not stopped");
        write(file, prefix + "while true do end end}");
        LuaTask step;
        require(step.load(file, error), qPrintable(error));
        Decision d;
        require(!step.step({}, configuration(), {}, d, error), "Infinite decision was not stopped");
    });
    test("lua_memory_quota", [&] {
        QString file = temp.filePath("memory.lua"), error;
        write(file, prefix + "return {kind='wait',message=string.rep('x',32*1024*1024)} end}");
        LuaTask lua;
        require(lua.load(file, error), qPrintable(error));
        Decision d;
        require(!lua.step({}, configuration(), {}, d, error), "Memory budget was not enforced");
        require(lua.allocated() <= 16 * 1024 * 1024, "Lua exceeded its allocation quota");
    });
    test("failed_candidate_preserves_active_vm", [&] {
        LuaTask active;
        QString error;
        require(active.load(path, error), qPrintable(error));
        QString bad = temp.filePath("bad.lua");
        write(bad, "this is invalid Lua");
        LuaTask candidate;
        require(!candidate.load(bad, error), "Invalid candidate accepted");
        Decision d;
        require(active.step(PreviewWorld{}.snapshot(), configuration(), {}, d, error) && d.kind == "move",
                "Active VM was affected by failed candidate");
    });
    test("three_workers_independent_and_game_exit_cleanup", [&] {
        struct JobGuard {
            HANDLE handle = CreateJobObjectW(nullptr, nullptr);
            ~JobGuard() {
                if (handle)
                    CloseHandle(handle);
            }
        } job;
        require(job.handle != nullptr, "Test Job could not be created");
        JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
        limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_PROCESS_MEMORY |
                                                  JOB_OBJECT_LIMIT_JOB_MEMORY |
                                                  JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
        limits.ProcessMemoryLimit = 192ULL * 1024 * 1024;
        limits.JobMemoryLimit = 512ULL * 1024 * 1024;
        require(
            SetInformationJobObject(job.handle, JobObjectExtendedLimitInformation, &limits, sizeof(limits)),
            "Worker Job memory configuration failed");
        JOBOBJECT_CPU_RATE_CONTROL_INFORMATION cpu{};
        cpu.ControlFlags = JOB_OBJECT_CPU_RATE_CONTROL_ENABLE | JOB_OBJECT_CPU_RATE_CONTROL_HARD_CAP;
        cpu.CpuRate = 1000;
        require(SetInformationJobObject(job.handle, JobObjectCpuRateControlInformation, &cpu, sizeof(cpu)),
                "Worker Job CPU configuration failed");
        Child games[3], workers[3];
        ProcessBinding identities[3];
        for (int i = 0; i < 3; ++i) {
            games[i].launch({"--fixture-game", "--lifetime", "20000"});
            require(identities[i].open(quint32(games[i].process.processId()), root, {}, true),
                    qPrintable(identities[i].error));
            ProcessBinding stale;
            require(!stale.open(identities[i].info().pid, root, "stale-identity", true),
                    "Stale creation identity accepted");
            workers[i].session = "test-" + QString::number(i);
            workers[i].launch({"--worker", "--test-target", "--target-pid",
                               QString::number(identities[i].info().pid), "--created",
                               identities[i].info().created, "--session", workers[i].session, "--game-root",
                               root, "--script", path});
            HANDLE workerHandle =
                OpenProcess(PROCESS_SET_QUOTA | PROCESS_TERMINATE | PROCESS_QUERY_LIMITED_INFORMATION, FALSE,
                            DWORD(workers[i].process.processId()));
            require(workerHandle != nullptr, "Cannot open owned Worker for Job assignment");
            bool assigned = AssignProcessToJobObject(job.handle, workerHandle);
            BOOL inJob = FALSE;
            bool queried = IsProcessInJob(workerHandle, job.handle, &inJob);
            CloseHandle(workerHandle);
            require(assigned && queried && inJob, "Worker not assigned to resource Job");
            BOOL targetInJob = TRUE;
            require(IsProcessInJob(identities[i].handle(), job.handle, &targetInJob) && !targetInJob,
                    "Target game fixture was incorrectly resource-limited");
            workers[i].waitEvent("ready");
            workers[i].send({{"op", "start"}, {"mode", "live"}, {"config", configuration()}});
            auto blocked = workers[i].waitEvent("blocked");
            require(blocked.value("missing").toArray().size() == 2, "Planting capability gate missing");
            workers[i].send({{"op", "start"}, {"mode", "live_move"}, {"config", configuration()}});
            auto refused = workers[i].waitEvent("error");
            require(refused.value("message").toString().contains("版本"),
                    "Native movement was enabled for an unsupported fixture image");
            workers[i].send({{"op", "start"}, {"mode", "preview"}, {"config", configuration(i + 1)}});
        }
        for (int i = 0; i < 3; ++i) {
            auto completed = workers[i].waitEvent("completed", 5000);
            require(completed.value("preview").toBool(), "Preview was not labelled");
            require(completed.value("state").toObject().value("planted_count").toInt() == i + 1,
                    "Session state leaked across workers");
        }
        games[1].process.kill();
        require(games[1].process.waitForFinished(1000), "Fixture did not exit");
        require(workers[1].process.waitForFinished(2000), "Worker did not follow target exit");
        require(workers[0].process.state() == QProcess::Running &&
                    workers[2].process.state() == QProcess::Running,
                "Other session exited");
        workers[0].send({{"op", "quit"}});
        workers[0].process.closeWriteChannel();
        require(workers[0].process.waitForFinished(2000), "Detach did not stop Worker");
        require(games[0].process.state() == QProcess::Running, "Detach closed game fixture");
        workers[2].process.closeWriteChannel();
        require(workers[2].process.waitForFinished(2000), "Control disconnect left orphan Worker");
    });
    test("worker_wait_pause_stop_and_target_exit", [&] {
        Child game,worker;game.launch({"--fixture-game","--lifetime","20000"});
        ProcessBinding identity;require(identity.open(quint32(game.process.processId()),root,{},true),"Wait target binding failed");
        worker.session="wait-fixture";
        worker.launch({"--worker","--test-target","--target-pid",QString::number(identity.info().pid),"--created",identity.info().created,"--session",worker.session,"--game-root",root,"--script",path});
        worker.waitEvent("ready");
        const QJsonObject config{{"wait_kind","等待时长"},{"wait_seconds",1},{"timeout_seconds",10}};
        worker.send({{"op","start"},{"mode","wait"},{"config",config}});worker.waitEvent("started");
        worker.send({{"op","pause"}});worker.waitEvent("paused");
        QElapsedTimer paused;paused.start();while(paused.elapsed()<1200){worker.process.waitForReadyRead(50);worker.pump();}
        for(const auto &e:worker.events)require(e.toObject().value("event")!="completed","Duration advanced while paused");
        worker.send({{"op","pause"}});auto done=worker.waitEvent("completed",4000);
        require(done.value("actions")==0&&done.value("operation")=="wait","Waiting issued a game action");
        worker.events={};worker.send({{"op","start"},{"mode","wait"},{"config",config}});worker.waitEvent("started");
        worker.send({{"op","stop"}});worker.waitEvent("stopped");
        require(game.process.state()==QProcess::Running,"Stopping wait closed the game");
        worker.events={};worker.send({{"op","start"},{"mode","wait"},{"config",config}});worker.waitEvent("started");
        game.process.kill();require(game.process.waitForFinished(1000),"Wait fixture exit failed");
        require(worker.process.waitForFinished(2000),"Waiting worker did not follow game exit");
    });
    test("reference_script_calls_map_only_to_whitelisted_snippets", [&] {
        uint32_t snippet=0;gameplay::SnippetArgs args;
        require(LegacyRunner::parseScriptCall("Clear_XSCRIPT();Set_XSCRIPT_Function_Name('GetPrize');Set_XSCRIPT_ScriptID(885577);Set_XSCRIPT_Parameter(0,3);Set_XSCRIPT_ParamCount(1);Send_XSCRIPT();",snippet,args)
            &&snippet==gameplay::XScript&&args.ints[0]==5&&args.ints[1]==3,"Whitelisted server request rejected");
        require(LegacyRunner::parseScriptCall("Clear_XSCRIPT()\n Set_XSCRIPT_Function_Name( \"MartialLastDayMonsterReward\" )\n Set_XSCRIPT_ScriptID( 507010 )\n Set_XSCRIPT_Parameter(0,1)\n Set_XSCRIPT_Parameter(1,0)\n Set_XSCRIPT_ParamCount(2)\n Send_XSCRIPT()",snippet,args)
            &&args.ints[0]==4&&args.ints[1]==1&&args.ints[2]==0,"Two-parameter request rejected");
        require(LegacyRunner::parseScriptCall("setmetatable(_G, {__index = MessageBox_Self3_Env});if this:IsVisible() then else return end;MessageBox_Self3_OnOk();",snippet,args)&&snippet==gameplay::UiCall&&args.ints[0]==3,"Guarded UI call rejected");
        require(LegacyRunner::parseScriptCall("setmetatable(_G, {__index = Token_Shop_Env});Token_Shop_GetReward_Click(5)",snippet,args)&&args.ints[1]==5,"UI call argument lost");
        require(LegacyRunner::parseScriptCall("PushEvent('OPEN_SAFECENTER_SAFESCORE')",snippet,args)&&snippet==gameplay::UiEvent,"UI event rejected");
        for(const char *bad:{"return Player:GetData('NAME')","setmetatable(_G, {__index = Token_Shop_Env});Token_Shop_GetReward_Click(6)",
            "Clear_XSCRIPT();Set_XSCRIPT_Function_Name('GetPrize');Set_XSCRIPT_ScriptID(885578);Set_XSCRIPT_Parameter(0,3);Set_XSCRIPT_ParamCount(1);Send_XSCRIPT()",
            "Clear_XSCRIPT();Set_XSCRIPT_Function_Name('GetPrize');Set_XSCRIPT_ScriptID(885577);Set_XSCRIPT_Parameter(0,3);Set_XSCRIPT_ParamCount(2);Send_XSCRIPT()",
            "Clear_XSCRIPT();Set_XSCRIPT_Function_Name('GetPrize');Set_XSCRIPT_ScriptID(885577);Set_XSCRIPT_Parameter(1,3);Set_XSCRIPT_ParamCount(1);Send_XSCRIPT()",
            "setmetatable(_G, {__index = Token_Shop_Env});os.execute(1)","PushEvent('OPEN_BANK')","CloseAllWindow();os.exit()"})
            require(!LegacyRunner::parseScriptCall(bad,snippet,args),bad);
        gameplay::SnippetArgs a;a.ints[0]=gameplay::count(gameplay::xscripts);require(!gameplay::validSnippet(gameplay::XScript,a),"Unknown request index accepted");
        a=gameplay::SnippetArgs{};a.reals[0]=3000;require(!gameplay::validSnippet(gameplay::RunTo,a),"Out-of-map coordinate accepted");
        a=gameplay::SnippetArgs{};std::wcscpy(a.text,L"bad\nname");require(!gameplay::validSnippet(gameplay::NpcTarget,a),"Control text accepted");
        require(sizeof(gameplay::Packet)<4096,"Packet grew past one page");
    });
    test("reference_source_gbk_and_chinese_identifiers", [&] {
        const wchar_t *wide=L"输入屏幕文本(\"等待 中文\") -- 等待(1)\nlocal 坐标 = 1 等待(坐标)\n--[[ 等待 ]] s=[[等待]] x=0x1F";
        const int n=WideCharToMultiByte(936,0,wide,-1,nullptr,0,nullptr,nullptr);QByteArray local(n-1,'\0');WideCharToMultiByte(936,0,wide,-1,local.data(),n,nullptr,nullptr);
        QString error;const auto out=QString::fromUtf8(LegacyRunner::translateSource(local,error));
        const auto m=[](const char *s){return QString::fromLatin1(LegacyRunner::mangle(QByteArray(s)));};
        require(error.isEmpty()&&out==m("输入屏幕文本")+"(\"等待 中文\") -- 等待(1)\nlocal "+m("坐标")+" = 1 "+m("等待")+"("+m("坐标")+")\n--[[ 等待 ]] s=[[等待]] x=0x1F","Identifier translation changed strings, comments or numbers");
        require(LegacyRunner::translateSource(QByteArray("\xff\xff\xff",3),error).isEmpty()&&!error.isEmpty(),"Undecodable source accepted");
    });
    test("reference_tasks_run_against_simulated_game", [&] {
        const auto legacy=root+"/scripts/legacy";
        const auto manifest=QJsonDocument::fromJson([&]{QFile f(legacy+"/manifest.json");require(f.open(QIODevice::ReadOnly),"Manifest missing");return f.readAll();}()).object();
        struct Sim {int scene=0;double x=100,y=100;bool quest=false,safe=false;int bag=60,team=3,cost=30;QStringList log;
            bool small=false,big=false,temp=false,sweepAll=false,sweepPage=false,shop=false,gemWindow=false;int money=20000,stored=100000,tempItems=0,left=0,boss=0,profit=100000,talisman=0;QList<int> stacks;
            struct Gem{QString name;int bind,num,level;};QList<Gem> gems;
            QString map="大理",city,npcItem,npcAll,prompts;int box=0,today=0,week=0;
            int useLeft=0,mission=-1,timer=0,vip=0;int vars[8]{};QHash<QString,QString> optionPrompt;QHash<QString,int> material,tempCount;
            QHash<int,QList<QPair<QString,int>>> lists;QHash<QString,QString> optionWindow;QSet<QString> shown;int attr=-1,need=0,cohesionCost=0;QHash<QString,QString> uiPrompt;QString wuhun,missionDesc;bool buttons[2]{};bool manor=false;int plots[5]{};int gardenFree=2,gardenHire=4;QString examText;QHash<QString,int> stock;QString goldGift;
            int hdLeft=0,menpai=500;QString awake;QMap<QString,int> held;QSet<QString> noOption;
            QHash<QString,QString> talkWindow;QHash<int,QVariantList> equip;bool wuhunLow=false;int xlJing=2,xlLevel=2,xfLevel=0;
            int djLeft=0,carveLeft=0;QSet<QString> given;bool lwEq=false;QList<QVariantList> lwItems;};
        auto respond=[](Sim &g,const LegacyRequest &r)->QVariantList{
            if(r.kind==LegacyRequest::Host){if(r.host=="position")return {true,g.scene,g.x,g.y,g.map};g.log<<"alert:"+r.detail;return {};}
            require(r.kind==LegacyRequest::Snippet,"Monthly sign request outside its task");
            const auto &a=r.args;const auto text=QString::fromWCharArray(a.text);
            switch(r.snippet){
            case gameplay::RunTo:g.scene=a.ints[0];g.x=a.reals[0];g.y=a.reals[1];g.quest=false;g.log<<QString("run:%1,%2,%3").arg(a.ints[0]).arg(a.reals[0]).arg(a.reals[1]);return {1};
            case gameplay::TalkNpc:case gameplay::NpcTarget:g.quest=true;g.log<<"talk:"+text;if(g.talkWindow.contains(text))g.shown.insert(g.talkWindow.value(text));return {1};
            case gameplay::QuestOptions:return {g.quest?1:0,2};
            case gameplay::QuestOption:if(!g.quest||g.noOption.contains(text))return {0};g.log<<QString("option:%1:%2").arg(text).arg(a.ints[0]);if(text=="我要兑换")g.bag-=g.cost;if(text=="打开银行")g.small=true;if(text=="#{RCYH_180606_105}")g.shop=true;if(text=="#{BSLCYH_130529_133}")g.gemWindow=true;if(g.optionPrompt.contains(text))g.prompts+=g.optionPrompt.value(text)+"\n";if(g.optionWindow.contains(text))g.shown.insert(g.optionWindow.value(text));if(text=="是的，我要领取。")g.timer+=3600;return {1,text};
            case gameplay::QuestButton:if(!g.quest)return {0};g.quest=false;g.log<<QString("button:%1").arg(a.ints[0]);if(a.ints[0]==3)g.bag-=g.cost;if(a.ints[0]==2&&g.mission>=0)g.mission=-1;
                if(a.ints[0]>=2)for(auto it=g.held.begin();it!=g.held.end();++it)if(it.value()==1){g.held.erase(it);break;}
                return {1};
            case gameplay::BagCount:return {text=="低级宝石合成符"?g.talisman:text.contains("合成符")?0:g.bag,3};
            case gameplay::PlayerData:{const QString key=gameplay::playerKeys[a.ints[0]];return {key=="MONEY"?g.money:key=="MONEY_JZ"?0:key=="MEMPAI"?g.menpai:key=="TODAYACTIVEPOINT"?g.today:key=="WEEKACTIVEPOINT"?g.week:500};}
            case gameplay::TeamCount:return {g.team};
            case gameplay::XScript:{const auto &x=gameplay::xscripts[a.ints[0]];if(QString(x.function)=="OnAugury")++g.box;if(QString(x.function)=="OnFuBenSecKill"&&g.hdLeft>0)--g.hdLeft;
                if(QString(x.function)=="AskXiuLianLevelUp")++g.xlLevel;if(QString(x.function)=="AskXiuLianAdvanceJingJie"){++g.xlJing;g.xlLevel=0;}g.log<<QString("xs:%1").arg(x.function)+(x.params>0?QString(":%1").arg(a.ints[1]):"")+(x.params>1?QString(":%1").arg(a.ints[2]):"");return {1};}
            case gameplay::UiCall:{const auto &u=gameplay::uiCalls[a.ints[0]];g.log<<QString("ui:%1").arg(u.function)+(u.args?QString(":%1").arg(a.ints[1]):"");
                if(g.uiPrompt.contains(u.function))g.prompts+=g.uiPrompt.value(u.function)+"\n";
                if(QString(u.function)=="ShenqiSX_HY_OK_Clicked")g.bag-=5;
                g.sweepAll|=QString(u.function)=="PlayerQuicklyEnter_OpenSecKillBox";g.temp|=QString(u.function)=="Packet_Temporary_BtnClick";return {1};}
            case gameplay::WindowVisible:if(g.shown.contains(text))return {1};return {(text=="SweepAll"?g.sweepAll:text=="SweepPage"?g.sweepPage:text=="Packet_Temporary"?g.temp:text=="PS_ShopMag"?g.shop:text=="SanShen_BaoXiang"?false:g.safe)?1:0};
            case gameplay::CloseAll:g.log<<"closeall";g.small=g.big=g.quest=false;g.shown.remove("Shop");return {1};
            case gameplay::BankState:return {g.small?1:0,g.big?1:0,g.stored,g.money};
            case gameplay::BankBig:if(!g.small)return {0};g.small=false;g.big=true;g.log<<"bankbig";return {1};
            case gameplay::BankMoney:{if(!g.big)return {-1};int n=qMin(a.ints[1],a.ints[0]==1?g.stored:g.money);if(n<=0)return {0};
                if(a.ints[0]==1){g.stored-=n;g.money+=n;}else{g.stored+=n;g.money-=n;}g.log<<QString("bankmoney:%1:%2").arg(a.ints[0]).arg(n);return {n};}
            case gameplay::BankItem:{int total=0;for(int v:g.stacks)total+=v;if(!g.big)return {-1,0};if(a.ints[0]!=1||g.stacks.isEmpty())return {0,total};g.bag+=g.stacks.takeFirst();g.log<<"bankitem:"+text;return {1,total};}
            case gameplay::BagStore:if(!g.big||g.bag<=0)return {0};g.stacks<<g.bag;g.bag=0;g.log<<"bagstore:"+text+(a.ints[0]?QString(":%1").arg(a.ints[0]):QString());return {1};
            case gameplay::TempBag:{if(!g.temp)return {-1,0};const int moved=g.tempItems>0?1:0;g.bag+=g.tempItems;g.tempItems=0;g.log<<QString("temp:%1:%2").arg(a.ints[0]==1?QString("ALL"):text).arg(moved);return {moved,moved};}
            case gameplay::SweepCount:return {2};
            case gameplay::SweepEnum:return a.ints[0]==0?QVariantList{5,8,1,2,300,0,40,0,QString("讨伐燕子坞")}:QVariantList{5,8,1,2,301,g.left,41,0,QString("少室山")};
            case gameplay::SweepData:return {0,0,0};
            case gameplay::SweepOpenPage:g.sweepPage=true;g.boss=0;g.log<<QString("openpage:%1").arg(a.ints[0]);return {1};
            case gameplay::SweepBoss:if(!g.sweepPage)return {-3};if(g.boss>=2){return {-1};}++g.boss;if(g.boss==2)--g.left;g.log<<QString("boss:%1").arg(g.boss);return {g.boss};
            case gameplay::CloseNamed:{const QString w=gameplay::closableWindows[a.ints[0]];if(w=="SweepPage")g.sweepPage=false;if(w=="Packet_Temporary")g.temp=false;if(w=="Gemcompose")g.gemWindow=false;g.log<<"close:"+w;return {1};}
            case gameplay::ShopMoney:{if(!g.shop)return {-1};const int n=qMin(a.ints[0],g.profit);if(n<=0)return {0};g.profit-=n;g.money+=n;g.log<<QString("shopmoney:%1").arg(n);return {n};}
            case gameplay::GemList:{if((a.ints[0]==1&&!g.big)||(a.ints[0]==2&&!g.temp))return {-1,0};QString lines;int n=0;
                if(a.ints[0]==0)for(const auto &gem:g.gems)if(gem.num>0){lines+=QString("%1\t%2\t%3\t%4\n").arg(gem.name).arg(gem.bind).arg(gem.num).arg(gem.level);++n;}
                return {n,0,lines};}
            case gameplay::GemCombine:{if(!g.gemWindow)return {-1};const int mode=a.ints[0],need=a.ints[1];int total=0,level=0;bool bound=false;
                for(const auto &gem:g.gems)if(gem.name==text&&(mode==2||gem.bind==mode)){total+=gem.num;level=gem.level;}
                if(total<need||g.talisman<=0)return {total<need?-2:-3};
                int rest=need;for(auto &gem:g.gems)if(rest>0&&gem.name==text&&(mode==2||gem.bind==mode)){const int used=qMin(rest,gem.num);gem.num-=used;rest-=used;bound|=gem.bind==1&&used>0;}
                QString next=text;next.replace(QString("（%1级）").arg(level),QString("（%1级）").arg(level+1));
                g.gems<<Sim::Gem{next,bound?1:0,1,level+1};--g.talisman;g.log<<QString("combine:%1:%2").arg(text).arg(need);return {1};}
            case gameplay::UiEvent:g.safe=true;g.log<<"event";return {1};
            case gameplay::DebugMessages:return {int(g.prompts.count('\n')),g.prompts};
            case gameplay::NpcEventItem:return {g.quest?1:0,g.quest?g.npcItem:QString()};
            case gameplay::NpcEventAll:return {g.quest?2:0,g.quest?g.npcAll:QString()};
            case gameplay::GuildInfo:return {g.city.isEmpty()?-1:12,g.city};
            case gameplay::ActiveBox:return {g.box};
            case gameplay::UseBagItem:{const auto name=QString::fromWCharArray(gameplay::usableItems[a.ints[0]]);if(g.useLeft<=0)return {-1};--g.useLeft;g.log<<"use:"+name;if(name=="愿灵泉")g.vars[0]=1;return {3};}
            case gameplay::MissionFind:if(!g.held.isEmpty()){const int i=int(g.held.keys().indexOf(text));return {i,i>=0?77:-1};}return {g.mission,g.mission>=0?77:-1};
            case gameplay::MissionVar:if(!g.held.isEmpty()){const auto k=g.held.keys();return {a.ints[0]<k.size()?g.held.value(k[a.ints[0]]):-1};}return {g.mission>=0?g.vars[a.ints[1]]:-1};
            case gameplay::PlayerState:return {0};
            case gameplay::Dismount:g.log<<"dismount";return {0};
            case gameplay::DoubleTimer:return {g.timer};
            case gameplay::VipLevel:return {g.vip};
            case gameplay::MsgBoxText:{const auto name=QString::fromWCharArray(gameplay::msgBoxTexts[a.ints[0]]);g.log<<"msgbox:"+name;if(name.contains("冻结"))g.timer=0;return {1};}
            case gameplay::QuitGame:g.log<<"quit";return {1};
            case gameplay::XingYunCount:return {-1};
            case gameplay::VipRefresh:g.log<<"viprefresh";return {1};
            case gameplay::BagCountIn:return {a.ints[0]==1?g.material.value(text):g.tempCount.value(text)};
            case gameplay::ItemList:{if(a.ints[0]==3&&!g.big)return {-1,QString()};QString lines;int n=0;
                for(const auto &item:g.lists.value(a.ints[0])){if(item.first.contains(text)){lines+=QString("%1\t%2\n").arg(item.first).arg(item.second);++n;}}
                return {n,lines};}
            case gameplay::CompoundSelect:g.log<<QString("select:%1").arg(a.ints[0]);return {1};
            case gameplay::AttackAttr:return {g.attr};
            case gameplay::CohesionCost:return {g.need,g.cohesionCost};
            case gameplay::LifeCompose:g.log<<QString("life:%1").arg(a.ints[0]);return {1};
            case gameplay::BagSpace:return {5};
            case gameplay::WuhunList:return {int(g.wuhun.count('\n')),g.wuhun};
            case gameplay::WuhunCompound:g.log<<QString("wuhun:%1:%2").arg(a.ints[0]).arg(a.ints[1]);return {1};
            case gameplay::MissionDesc:return {g.missionDesc.isEmpty()?0:1,g.missionDesc};
            case gameplay::UiEnabled:return {g.buttons[a.ints[0]]?1:0};
            case gameplay::EquipAdjust:g.log<<"adjust";return {2};
            case gameplay::CityEnemyHas:return {0};
            case gameplay::CityEnemyAsk:g.log<<"enemyask";return {1};
            case gameplay::OpenAddEnemy:g.log<<QString("war:%1").arg(a.ints[0]);return {1};
            case gameplay::BieYeScene:return {g.manor?1:0};
            case gameplay::BieYeProduct:return {g.plots[a.ints[0]],100};
            case gameplay::BieYeAsk:return {1};
            case gameplay::BieYeGardeners:return {g.gardenFree,g.gardenHire};
            case gameplay::WuhunText:g.log<<QString("wuhuntext:%1").arg(a.ints[0]);return {1};
            case gameplay::ExamRead:return {g.examText.isEmpty()?0:1,g.examText};
            case gameplay::HuoYueBuy:case gameplay::DividendBuy:case gameplay::HonourBuy:case gameplay::GuildShopBuy:case gameplay::T3ShopBuy:case gameplay::ChongLouBuy:case gameplay::GuiShiBuy:{
                const int count=r.snippet==gameplay::HuoYueBuy?a.ints[1]:r.snippet==gameplay::DividendBuy?1:a.ints[0];
                g.log<<QString("shop:%1:%2:%3").arg(r.snippet).arg(count).arg(text);const bool have=g.stock.value(text)>0;if(have){g.stock[text]-=1;}
                return {r.snippet==gameplay::T3ShopBuy?(have?0:3):r.snippet==gameplay::ChongLouBuy?(have?0:2):(have?1:0)};}
            case gameplay::GoldGiftRead:return {g.goldGift.isEmpty()?0:1,g.goldGift};
            case gameplay::GoldGiftChoose:g.log<<QString("gift:%1").arg(a.ints[0]);return {1};
            case gameplay::DictText:return {1,text};
            case gameplay::HuoDongCount:return {2};
            case gameplay::HuoDongEnum:return a.ints[0]==0?QVariantList{1,5,0,0,3,2-g.hdLeft,2,QString("活动甲")}:QVariantList{3,0,1,0,3,0,5,QString("活动乙")};
            case gameplay::UseBoxItem:g.log<<"box:"+text;return {4};
            case gameplay::AwakeRead:return {g.awake.isEmpty()?0:1,g.awake};
            case gameplay::AwakeAdd:g.log<<QString("awake:%1:%2:%3").arg(a.ints[0]).arg(a.ints[1]).arg(a.ints[2]);return {1};
            case gameplay::SectOper:g.log<<QString("sect:%1").arg(a.ints[0]);if(g.held.contains("绝学问武意纵横"))g.held["绝学问武意纵横"]=1;return {1};
            case gameplay::NpcShopBuy:g.log<<"npcshop:"+QString::fromWCharArray(gameplay::shopItems[a.ints[0]]);return {3};
            case gameplay::BagSell:if(!g.shown.contains("Shop"))return {-1};if(g.bag<=0)return {-3};g.bag=0;g.log<<QString("sell:%1:%2").arg(text).arg(a.ints[0]);return {0};
            case gameplay::EquipDur:return g.equip.value(a.ints[0],QVariantList{0,-1,3,QString()});
            case gameplay::EquipRepair:g.log<<QString("repair:%1:%2").arg(a.ints[0]).arg(a.ints[1]);g.equip.remove(a.ints[0]);return {1};
            case gameplay::EquipRestore:g.log<<QString("restore:%1:%2").arg(a.ints[0]).arg(a.ints[1]);return {2};
            case gameplay::WuhunLife:return {g.wuhunLow?1:0,QString("武魂甲")};
            case gameplay::WuhunRepair:g.log<<"wuhunrepair";g.wuhunLow=false;return {3};
            case gameplay::XiuLianInfo:return {g.xlJing,g.xlLevel,4,100,100};
            case gameplay::XinfaRead:return a.ints[0]==1?QVariantList{7,g.xfLevel,1}:QVariantList{-1,-1,0};
            case gameplay::XinfaStudy:g.log<<QString("xinfa:%1").arg(a.ints[0]);++g.xfLevel;return {1};
            case gameplay::DianJin:g.log<<QString("dianjin:%1:%2:%3").arg(a.ints[0]).arg(a.ints[1]).arg(a.ints[2]);if(g.djLeft<=0)return {0};--g.djLeft;return {1};
            case gameplay::XZGift:{const auto gift=QString::fromWCharArray(gameplay::xzGifts[a.ints[0]].gift);if(g.given.contains(gift))return {0};
                g.given.insert(gift);g.shown.insert("GiveGift");g.log<<"xzgift:"+gift;return {1};}
            case gameplay::GemCarve:if(g.carveLeft<=0)return {0};--g.carveLeft;g.log<<"carve:"+text;return {1};
            case gameplay::LwScan:{QString t;for(const auto &v:g.lwItems)t+=QString("%1\t%2\t%3\t%4\n").arg(v[0].toInt()).arg(v[1].toInt()).arg(v[2].toLongLong()).arg(v[3].toInt());
                return {g.lwEq?1:0,int(g.lwItems.size()),t};}
            case gameplay::LwUnequip:if(!g.lwEq)return {1};g.lwEq=false;g.log<<"lwunequip";return {0};
            case gameplay::LwCombine:{g.log<<QString("lwcombine:%1:%2:%3").arg(a.ints[0]).arg(a.ints[1]).arg(a.ints[2]);
                for(int k=0;k<g.lwItems.size();++k)if(g.lwItems[k][0].toInt()==a.ints[1]){g.lwItems.removeAt(k);break;}return {1};}
            case gameplay::LwEquip:g.log<<QString("lwequip:%1").arg(a.ints[0]);g.lwEq=true;return {1};
            default:require(false,"Unexpected snippet");return {};
            }
        };
        QSet<QString> spendSeen,offlineSeen,sellSeen,stalled;
        auto runTask=[&](const QString &id,Sim &g,qint64 limit,QString *failure=nullptr,const QJsonObject &settings={}){
            QJsonObject entry;for(const auto &v:manifest.value("tasks").toArray())if(v.toObject().value("id")==id)entry=v.toObject();
            require(!entry.isEmpty(),qPrintable("Missing manifest task "+id));
            // These two historical compatibility scenarios retain their old reconstructed entry;
            // the production entries now execute original Lua through the resident VM.
            const auto historical=id=="tlzz_rose_claim"?QString("rebuilt/rose_claim.lua"):id=="tlzz_flower_seed"?QString("rebuilt/flower_seed.lua"):entry.value("entry").toString();
            LegacyRunner runner;QString error;require(runner.load(legacy+"/"+historical,error,legacy+"/compat.lua",settings),qPrintable(id+": "+error));
            for(qint64 now=0;now<=limit;now+=100){
                LegacyRequest request;const auto progress=runner.poll(now,request,error);runner.takeMessages();
                if(progress==LegacyRunner::Failed&&failure){*failure=error;return false;}
                // The simulator does not consume items; a no-progress guard stop is a valid end of the task.
                if(progress==LegacyRunner::Failed&&(error.contains("没有变化")||error.contains("没有进展"))){stalled.insert(id);return true;}
                require(progress!=LegacyRunner::Failed,qPrintable(id+": "+error));
                if(progress==LegacyRunner::Finished)return true;
                if(progress==LegacyRunner::Action&&request.kind==LegacyRequest::Snippet&&(gameplay::snippetRisk(request.snippet,request.args)&gameplay::RiskSpend))spendSeen.insert(id);
                if(progress==LegacyRunner::Action&&request.kind==LegacyRequest::Snippet&&(gameplay::snippetRisk(request.snippet,request.args)&gameplay::RiskOffline))offlineSeen.insert(id);
                if(progress==LegacyRunner::Action&&request.kind==LegacyRequest::Snippet&&(gameplay::snippetRisk(request.snippet,request.args)&gameplay::RiskSell))sellSeen.insert(id);
                if(progress==LegacyRunner::Action)require(runner.acknowledge(request.id,true,{},respond(g,request)),"Receipt refused");
            }
            return false;
        };
        auto repeat=[](const QStringList &items,int times){QStringList out;for(int i=0;i<times;++i)out<<items;return out;};
        QStringList liangyuan{"xs:GetTodayHuoYuePointGift"};for(int i=1;i<=5;++i)liangyuan<<QString("ui:Token_Shop_GetReward_Click:%1").arg(i);
        QStringList qunhao,gold{"xs:GetPrize:1","xs:GetPrize:2","xs:GetPrize:3","xs:GetPrize:4"},jiaozi=gold;for(int i=1;i<=10;++i)qunhao<<QString("xs:CallByClient:%1").arg(i);
        gold<<repeat({"ui:Xichunchi_Prize2_Reward_Clicked:2","ui:MessageBox_Self3_OnOk"},20);jiaozi<<repeat({"ui:Xichunchi_Prize2_Reward_Clicked:1"},20);
        const QList<QPair<QString,QStringList>> expected{
            {"tlzz_liangyuan",liangyuan},{"tlzz_safe_score",{"event","xs:SafeScoreGetBonus","closeall"}},{"tlzz_qunhao",qunhao},
            {"tlzz_exp_recover",repeat({"xs:GetExp_ByMoney:0","ui:WuhunQuest_Bn1Click"},3)},{"tlzz_neixi_recover",repeat({"xs:MartialLastDayMonsterReward:1:0","ui:WuhunQuest_Bn1Click"},3)},
            {"tlzz_qihongjin_gold",gold},{"tlzz_qihongjin_jiaozi",jiaozi},
            {"tlzz_nayuan_claim",{"run:2,258,154","talk:何所思","option:#{JYQQ_250801_02}:1","option:#{JYQQ_250801_15}:1","option:#{JYQQ_250801_19}:1"}},
            {"tlzz_nayuan_jindan",{"run:2,258,154","talk:何所思","option:#{JYQQ_250801_03}:1","option:#{JYQQ_250801_33}:1","ui:MessageBox_Self_OK_Clicked"}},
            {"tlzz_chuxie_claim",{"run:2,216,139","talk:姚楚娥","option:#{CJJY_250806_02}:1","ui:ExorciseEvil_LevelBox_Clicked"}},
            {"tlzz_persian_rose",QStringList{"run:2,187,68"}<<repeat({"talk:巴盖里","option:波斯玫瑰兑换奖励:0","option:30朵波斯玫瑰兑换奖励:0","button:3"},2)},
            {"tlzz_rose",QStringList{"run:2,183,68"}<<repeat({"talk:巴盖里","option:波斯玫瑰兑换奖励:1","option:30朵波斯玫瑰兑换奖励:1","button:3"},2)
                <<QStringList{"ui:Packet_Temporary_BtnClick","temp:波斯玫瑰:0","close:Packet_Temporary","run:2,217,174","talk:何伙计","option:打开银行:0","bankbig","closeall"}},
            {"tlzz_window_alarm",{"alert:sound","alert:flash"}},{"tlzz_wait_team",{}},
            {"tlzz_luanfei_tiangang",{"run:0,258,165","talk:苏辙","option:上缴乱匪密函换取封赏:1","option:32个乱匪密函兑换封赏:1","button:3"}},
            {"tlzz_nayuan_pause",{"run:2,258,154","talk:何所思","option:#{JYQQ_250801_02}:1","option:#{JYQQ_250801_16}:1","option:#{JYQQ_250801_19}:1"}},
            {"tlzz_nayuan_end",{"run:2,258,154","talk:何所思","option:#{JYQQ_250801_02}:1","option:#{JYQQ_250801_17}:1"}},
            {"tlzz_zhan_jianghu",QStringList{"closeall","ui:PlayerQuicklyEnter_Clicked:35","ui:HeXinChun_ChangeTabIndex"}<<QStringList{"xs:GetDayReward:1","xs:GetDayReward:2","xs:GetDayReward:3","xs:GetDayReward:4","xs:GetDayReward:5","xs:GetDayReward:6","xs:GetDayReward:7","xs:GetDayReward:8"}
                <<QStringList{"ui:ZhanJiangHu_ClickGetHFReward:1","ui:ZhanJiangHu_ClickGetHFReward:2","closeall"}},
            {"tlzz_xibi_fuxia",QStringList{"ui:XiGua_Guide_Clicked:4"}<<repeat({"ui:XiGuaJie_Activity_Start_Clicked"},3)
                <<QStringList{"ui:XiGuaJie_Activity_GetLichengReward_Clicked:1","ui:XiGuaJie_Activity_GetLichengReward_Clicked:2","ui:XiGuaJie_Activity_GetLichengReward_Clicked:3","ui:XiGuaJie_Activity_GetLichengReward_Clicked:4","ui:XiGuaJie_Activity_GetLichengReward_Clicked:5"}
                <<QStringList{"ui:XiGuaJie_Activity_GetReward_Clicked:1","ui:XiGuaJie_Activity_GetReward_Clicked:2","ui:XiGuaJie_Activity_GetReward_Clicked:3","closeall"}},
            {"tlzz_shanhe_fuyue",{"ui:PlayerQuicklyEnter_TeSeServerCliked:33","ui:JiangHuShiJi_Click:1","ui:JiangHuShiJi_Popup_Two_LingQu","closeall"}},
            {"tlzz_bawang_bieji",{"ui:QiXi_Guide_2026_ActionClicked:3","ui:XiQuLianDong_GetGiftClicked"}},
            {"tlzz_tianmai_fuze",QStringList{"run:850,105,200"}<<repeat({"talk:陈霄","option:#{TWWK_20220708_51}:1"},5)},
            {"tlzz_gong_caiyun",{"run:2,172,122","talk:龚彩云","option:领取活动奖励:1","talk:龚彩云","option:#{YCBC_180510_32}:1","talk:龚彩云","option:#{YCBC_180510_22}:1","talk:龚彩云","option:#{YCBC_180510_23}:1"}}};
        for(const auto &item:expected){
            Sim g;require(runTask(item.first,g,30*60*1000),qPrintable(item.first+" did not finish"));
            require(g.log==item.second,qPrintable(item.first+" sequence: "+g.log.join(" | ")));
        }
        Sim wish;wish.cost=7;require(runTask("tlzz_wish_fruit",wish,30*60*1000)&&wish.bag==4&&wish.log.count("option:我要兑换:0")==8,"Wish fruit exchange count changed");
        Sim timed;require(!runTask("tlzz_wait_time",timed,2000)&&timed.log.isEmpty(),"Timed example ran early");
        Sim quit;require(runTask("tlzz_offline",quit,60000)&&quit.log==QStringList{"quit"},qPrintable("Offline sequence: "+quit.log.join(" | ")));
        Sim week;week.useLeft=1;require(runTask("tlzz_week_vip_items",week,30*60*1000)&&week.log==QStringList{"viprefresh","xs:OnUseVIP:5","use:银丝纳福礼箱","ui:Item_MultiUse_BuyMulti_Clicked"},
            qPrintable("Weekly VIP items sequence: "+week.log.join(" | ")));
        Sim enough;enough.timer=8000;require(runTask("tlzz_double_exp_get",enough,30*60*1000)&&enough.log.isEmpty(),qPrintable("Double exp claimed when enough: "+enough.log.join(" | ")));
        Sim dexp;dexp.npcItem="你没有在我这里冻结过双倍经验";const QStringList claim{"option:#{SBSJ_100726_02}:1","talk:刘健明","option:我想领一小时双倍经验时间:1","option:是的，我要领取。:1"};
        require(runTask("tlzz_double_exp_get",dexp,30*60*1000)&&dexp.log==QStringList{"closeall","run:0,242,235","talk:刘健明"}+claim+QStringList{"talk:刘健明"}+claim&&dexp.timer==7200,
            qPrintable("Double exp claim sequence: "+dexp.log.join(" | ")));
        Sim freeze;freeze.timer=3600;freeze.vip=3;require(runTask("tlzz_double_exp_freeze",freeze,30*60*1000)&&freeze.log==QStringList{"xs:OnUseVIP:11","msgbox:确定进行冻结"},
            qPrintable("Double exp freeze sequence: "+freeze.log.join(" | ")));
        Sim home;require(runTask("tlzz_back_city",home,30*60*1000)&&home.log==QStringList{"run:1,358,227"},qPrintable("Back to city sequence: "+home.log.join(" | ")));
        Sim wish1001;wish1001.mission=2;wish1001.useLeft=5;wish1001.npcItem="#{SQXY_09061_7}";
        require(runTask("tlzz_wish_1001",wish1001,30*60*1000)&&wish1001.log==QStringList{"run:4,158,188","dismount","use:愿灵泉","run:1,282,275","talk:梁道士","option:#{SQXY_09061_4}:1","button:2",
            "talk:梁道士","option:#{SQXY_09061_4}:1","closeall"},qPrintable("1001 wishes sequence: "+wish1001.log.join(" | ")));
        // Direct original daily chunks are tested through the real LuaPlus SDK
        // below; this external-runner mock cannot execute their binary bodies.
        Sim sihui;sihui.optionPrompt.insert("#{SXTZ_200731_22}","#{SXTZ_200731_24}");
        require(runTask("tlzz_sihui_juan",sihui,30*60*1000)&&sihui.log.count("option:#{SXTZ_200731_22}:1")==1&&sihui.log.contains("talk:薛晏"),qPrintable("四绘卷 sequence: "+sihui.log.join(" | ")));
        Sim jingjin;require(runTask("tlzz_jingjin",jingjin,30*60*1000)&&jingjin.log.contains("run:1,358,245")&&jingjin.log.endsWith("closeall")&&jingjin.log.contains("xs:DuiHuanOK"),
            qPrintable("精金石 sequence: "+jingjin.log.join(" | ")));
        Sim cbt;cbt.optionPrompt.insert("#{BTSM_260114_04}","#{BTSM_260114_08}");
        require(runTask("tlzz_cangbaotu",cbt,30*60*1000)&&cbt.log.count("option:#{BTSM_260114_04}:1")==1,qPrintable("藏宝图 sequence: "+cbt.log.join(" | ")));
        Sim yuxi;yuxi.bag=150;yuxi.optionPrompt.insert("#{ZZZB_200805_23}","#{ZZZB_200805_25}");
        require(runTask("tlzz_wangquan_yuxi",yuxi,30*60*1000)&&yuxi.log==QStringList{"closeall","ui:T3XinTianWai_Guide_OnClose","run:850,88,173","talk:殷轩奇","option:#{ZZZB_200805_2}:1",
            "option:#{ZZZB_200805_23}:1","ui:WuhunQuest_Bn1Click","closeall"},qPrintable("王权御玺 sequence: "+yuxi.log.join(" | ")));
        Sim gtcLow;gtcLow.material.insert("中级勾天彩",2);require(runTask("tlzz_goutiancai_high",gtcLow,30*60*1000)&&!gtcLow.log.contains("talk:焦鹰"),
            qPrintable("勾天彩 ran without materials: "+gtcLow.log.join(" | ")));
        Sim gtc;gtc.material.insert("中级勾天彩",10);gtc.tempCount.insert("中级勾天彩合成符",3);require(!runTask("tlzz_goutiancai_high",gtc,20*1000)&&gtc.log.contains("option:#{GTCHC_140213_03}:1")&&gtc.log.contains("ui:GouTianCai_HC_OnOK"),
            qPrintable("高级勾天彩 sequence: "+gtc.log.join(" | ")));
        Sim huanse;huanse.material.insert("高级勾天彩",10);huanse.npcItem="#{LW_KVK_130426_5}";
        require(runTask("tlzz_huanse_exchange",huanse,30*60*1000)&&huanse.log.count("option:#{LW_KVK_130426_9}:1")==1,qPrintable("幻色兑换 sequence: "+huanse.log.join(" | ")));
        Sim hunyu;require(runTask("tlzz_hunyu",hunyu,30*60*1000)&&hunyu.log.contains("option:#{JXSQ_170804_132}:1")&&!hunyu.log.contains("option:#{JXSQ_170804_133}:1")&&hunyu.log.contains("ui:ShenqiSX_HY_OK_Clicked"),
            qPrintable("魂玉 sequence: "+hunyu.log.join(" | ")));
        Sim mianbu;mianbu.lists.insert(1,{{"棉布碎片",8}});mianbu.optionWindow.insert("材料合成","CaiLiaoCompound");
        require(runTask("tlzz_compose_mianbu",mianbu,30*60*1000)&&mianbu.log.contains("talk:彭怀玉")&&mianbu.log.contains("select:10002")&&mianbu.log.contains("select:0")
            &&mianbu.log.contains("ui:CaiLiaoCompound_OK_Click")&&mianbu.log.indexOf("select:10002")<mianbu.log.indexOf("ui:CaiLiaoCompound_OK_Click"),qPrintable("棉布 sequence: "+mianbu.log.join(" | ")));
        Sim noMianbu;noMianbu.lists.insert(1,{{"棉布碎片",3},{"1级棉布",9}});require(runTask("tlzz_compose_mianbu",noMianbu,30*60*1000)&&!noMianbu.log.contains("talk:彭怀玉"),
            qPrintable("棉布 composed a grade above the setting: "+noMianbu.log.join(" | ")));
        Sim hbz;hbz.lists.insert(1,{{"魂冰珠（1级）",6}});
        require(runTask("tlzz_hunbingzhu",hbz,30*60*1000)&&hbz.log.contains("option:魂冰珠合成:1")&&hbz.log.contains("option:合成魂冰珠（2级）:1")&&hbz.log.contains("option:#{WH_xml_XX(112)}:1"),
            qPrintable("魂冰珠 sequence: "+hbz.log.join(" | ")));
        Sim voucher;voucher.npcAll=" #{CZDH_XML_1} ";require(runTask("tlzz_gem_voucher",voucher,30*60*1000)&&voucher.log.contains("run:224,68,45")&&voucher.log.contains("option:#{CZDH_XML_1}:1"),
            qPrintable("宝石兑换券 sequence: "+voucher.log.join(" | ")));
        Sim cohesion;cohesion.attr=2;cohesion.need=2;cohesion.cohesionCost=20000;cohesion.optionWindow.insert("五行宝玉凝聚","EquipBaoJian_Cohesion");
        require(runTask("tlzz_jiutian_yusui",cohesion,30*60*1000)&&cohesion.log.contains("option:五行宝玉凝聚:1")&&cohesion.log.contains("ui:EquipBaoJian_Cohesion_OnOK"),
            qPrintable("凝聚九天玉碎 sequence: "+cohesion.log.join(" | ")));
        Sim noAttr;noAttr.need=2;noAttr.cohesionCost=1;require(runTask("tlzz_jiutian_yusui",noAttr,30*60*1000)&&!noAttr.log.contains("ui:EquipBaoJian_Cohesion_OnOK"),"Cohesion ran without an attack attribute");
        Sim poor;poor.attr=1;poor.need=2;poor.cohesionCost=50000;poor.optionWindow.insert("五行宝玉凝聚","EquipBaoJian_Cohesion");
        require(runTask("tlzz_jiutian_yusui",poor,30*60*1000)&&!poor.log.contains("ui:EquipBaoJian_Cohesion_OnOK"),"Cohesion ran without enough money");
        Sim qxEmpty;require(runTask("tlzz_qianxin",qxEmpty,30*60*1000)&&qxEmpty.log==QStringList{"ui:PlayerQuicklyEnter_Clicked:77","ui:Qixi_HuaJuan_ShopButton_Clicked"},
            qPrintable("倩心阁 without items: "+qxEmpty.log.join(" | ")));
        Sim qxCap;qxCap.shown.insert("DaHuaQiXi_Shop");require(runTask("tlzz_qianxin",qxCap,30*60*1000,nullptr,{{"qianxin_items","金蚕丝"}})&&qxCap.log.count("ui:DaHuaQiXi_Shop_Clicked:10")==50,
            "倩心阁 exchange was not capped");
        Sim qxShut;require(runTask("tlzz_qianxin",qxShut,30*60*1000,nullptr,{{"qianxin_items","金蚕丝"}})&&!qxShut.log.join(" ").contains("DaHuaQiXi_Shop_Clicked"),"倩心阁 bought without the shop window");
        Sim qx;qx.shown.insert("DaHuaQiXi_Shop");qx.uiPrompt.insert("MessageBox_Self3_OnOk","#{DHSD_20240522_25}");
        require(runTask("tlzz_qianxin",qx,30*60*1000,nullptr,{{"qianxin_items","金蚕丝 不存在的物品"}})&&qx.log==QStringList{"ui:PlayerQuicklyEnter_Clicked:77","ui:Qixi_HuaJuan_ShopButton_Clicked",
            "ui:DaHuaQiXi_Shop_Clicked:10","ui:MessageBox_Self3_OnOk"},qPrintable("倩心阁 sequence: "+qx.log.join(" | ")));
        Sim jg;jg.lists.insert(1,{{"普通的黄骨",3}});require(!runTask("tlzz_jiagong",jg,5000)&&jg.log.contains("life:404"),qPrintable("加工材料 sequence: "+jg.log.join(" | ")));
        Sim jgNone;require(runTask("tlzz_jiagong",jgNone,30*60*1000)&&!jgNone.log.join(" ").contains("life:"),qPrintable("加工材料 ran without materials: "+jgNone.log.join(" | ")));
        Sim wh;wh.wuhun="3\t1\t1\n7\t1\t1\n9\t0\t1\n";
        require(runTask("tlzz_wuhun",wh,30*60*1000)&&!wh.log.isEmpty()&&wh.log.contains("wuhun:3:7")&&!wh.log.join(" ").contains(":9"),qPrintable("武魂 sequence: "+wh.log.join(" | ")));
        Sim whUnbound;whUnbound.wuhun=wh.wuhun;require(runTask("tlzz_wuhun",whUnbound,30*60*1000,nullptr,{{"wuhun_mode",3}})&&!whUnbound.log.join(" ").contains("wuhun:"),
            qPrintable("武魂 paired a single unbound item: "+whUnbound.log.join(" | ")));
        Sim whHigh;whHigh.wuhun="3\t1\t2\n7\t1\t2\n";require(runTask("tlzz_wuhun",whHigh,30*60*1000)&&!whHigh.log.join(" ").contains("wuhun:"),"武魂 composed above the level limit");
        Sim jy;jy.useLeft=1;require(runTask("tlzz_jinyuan",jy,30*60*1000)&&jy.log==QStringList{"ui:New_SeasonCard_Icon_GetClick","dismount","use:100绑定元宝票"},qPrintable("金元礼赠 sequence: "+jy.log.join(" | ")));
        QStringList haoqi{"ui:PlayerQuicklyEnter_Clicked:70","ui:Newserver_Hongbao_Tab_Click:1"};for(int i=1;i<=23;++i)haoqi<<QString("xs:LingQu:%1").arg(i);
        haoqi<<"ui:Newserver_Hongbao_Tab_Click:2"<<"ui:Newserver_Hongbao_Tab_Click:3"<<"ui:NewServerHongbaoBossReward"<<"ui:PlayerQuicklyEnter_Clicked:70";
        Sim hq;hq.bag=0;require(runTask("tlzz_haoqi",hq,30*60*1000,nullptr,{{"haoqi_buy",0}})&&hq.log==haoqi,qPrintable("豪气满江湖 without buying: "+hq.log.join(" | ")));
        Sim hqBuy;hqBuy.bag=0;require(runTask("tlzz_haoqi",hqBuy,30*60*1000)&&hqBuy.log.contains("xs:Buy:1:1")&&hqBuy.log.contains("xs:Buy:3:1"),qPrintable("豪气满江湖 buying: "+hqBuy.log.join(" | ")));
        Sim hs;require(runTask("tlzz_hanshan",hs,30*60*1000)&&hs.log==QStringList{"run:0,272,269","talk:寒时月","option:#{DGRR_260821_14}:1"},qPrintable("寒山侠影 sequence: "+hs.log.join(" | ")));
        Sim adj;require(runTask("tlzz_equip_adjust",adj,30*60*1000)&&adj.log==QStringList{"adjust"},"装备资质鉴定 sequence");
        Sim boxes;boxes.bag=0;require(runTask("tlzz_open_boxes",boxes,30*60*1000)&&boxes.log.isEmpty(),"开箱子 ran without boxes");
        Sim war;require(!runTask("tlzz_guild_war",war,10000,nullptr,{{"war_guild_ids","123 x"}})&&war.log.contains("enemyask")&&war.log.contains("war:123"),qPrintable("宣战 sequence: "+war.log.join(" | ")));
        Sim warNone;require(runTask("tlzz_guild_war",warNone,30*60*1000)&&warNone.log.isEmpty(),"宣战 ran without guild ids");
        Sim kx;kx.npcItem="你已经捎了10次口信";require(runTask("tlzz_kouxin",kx,30*60*1000)&&kx.log==QStringList{"run:0,232,319","talk:邱行洛","option:捎口信:1","closeall"},qPrintable("捎口信 sequence: "+kx.log.join(" | ")));
        Sim kxGo;kxGo.mission=3;kxGo.missionDesc="把口信带给{#G洛阳,201,88,0,赵捕头}#G小提示";
        require(!runTask("tlzz_kouxin",kxGo,5000)&&kxGo.log.contains("run:0,201,88")&&kxGo.log.contains("talk:赵捕头")&&kxGo.log.contains("option:捎口信:1"),qPrintable("捎口信 delivery: "+kxGo.log.join(" | ")));
        Sim wzp;require(!runTask("tlzz_wuzipu",wzp,5000)&&wzp.log.contains("talk:沈暝楼")&&wzp.log.contains("option:#{XZYD_200401_42}:1")&&wzp.log.contains("button:1"),qPrintable("武林无字谱 sequence: "+wzp.log.join(" | ")));
        Sim lc;require(runTask("tlzz_lianchi",lc,30*60*1000)&&lc.log.size()==16&&lc.log.last()=="ui:WuhunQuest_Bn1Click",qPrintable("莲池相宝 sequence: "+lc.log.join(" | ")));
        Sim hx;hx.optionPrompt.insert("#{JHJL_151222_01}","#{JHJL_151222_05}");
        require(runTask("tlzz_hongxian",hx,30*60*1000)&&hx.log.count("option:#{JHJL_151222_01}:1")==2&&hx.log.contains("talk:月老"),qPrintable("红线相忆 sequence: "+hx.log.join(" | ")));
        Sim shw;shw.npcItem="*12*34*2";shw.quest=true;require(runTask("tlzz_shanhe_wanli",shw,30*60*1000)&&shw.log.contains("run:2,12,34")&&shw.log.last()=="ui:Frost_ButtonClick:3",qPrintable("山河万里行 sequence: "+shw.log.join(" | ")));
        Sim shwBad;require(runTask("tlzz_shanhe_wanli",shwBad,30*60*1000)&&!shwBad.log.contains("ui:Frost_ButtonClick:3"),"山河万里行 moved without coordinates");
        Sim px;require(runTask("tlzz_puxue",px,30*60*1000)&&px.log.count("ui:XiGua_Guide_Clicked:1")==9&&px.log.contains("close:ZhongXiaItem")&&!px.log.contains("ui:ZhongXia_OnActivate"),qPrintable("蒲雪饮冰 sequence: "+px.log.join(" | ")));
        Sim hxws;hxws.optionPrompt.insert("#{HXWS_20250613_11}","#{HXWS_20250613_31}");
        require(runTask("tlzz_huxin",hxws,30*60*1000)&&hxws.log.contains("ui:Qixi_HuaJuan_Story_Goto")&&hxws.log.contains("option:#{HXWS_20250613_11}:1"),qPrintable("湖心往事 sequence: "+hxws.log.join(" | ")));
        const QJsonObject fishCfg{{"zy_level","早熟"},{"zy_kind","鲤鱼"}};
        Sim zyOut;QString zyWhy;require(!runTask("tlzz_manor_fish",zyOut,30*60*1000,&zyWhy,fishCfg)&&zyWhy.contains("手动进入"),qPrintable("庄园 outside the manor: "+zyWhy));
        Sim zyBad;zyBad.manor=true;require(runTask("tlzz_manor_fish",zyBad,30*60*1000,nullptr,{{"zy_level","早熟"},{"zy_kind","鲸鱼"}})&&!zyBad.log.join(" ").contains("talk:"),"庄园 ran with a wrong setting");
        Sim zyHarvest;zyHarvest.manor=true;zyHarvest.plots[4]=3;
        require(!runTask("tlzz_manor_fish",zyHarvest,30000,nullptr,fishCfg)&&zyHarvest.log.contains("talk:何翁")&&zyHarvest.log.contains("option:收获食材:0"),qPrintable("庄园养鱼 harvest: "+zyHarvest.log.join(" | ")));
        Sim zySow;zySow.manor=true;zySow.optionWindow.insert("播撒鱼苗","BieYePlanting");
        require(!runTask("tlzz_manor_fish",zySow,30000,nullptr,fishCfg)&&zySow.log.contains("option:播撒鱼苗:0")&&zySow.log.contains("ui:BieYePlanting_SwitchPage:1")
            &&zySow.log.contains("ui:BieYePlanting_ItemDataChanged:3")&&zySow.log.contains("ui:BieYePlanting_Buttons_Clicked"),qPrintable("庄园养鱼 sowing: "+zySow.log.join(" | ")));
        Sim zyNoHire;zyNoHire.manor=true;zyNoHire.gardenFree=0;require(runTask("tlzz_manor_fish",zyNoHire,30*60*1000,nullptr,fishCfg)&&!zyNoHire.log.contains("option:播撒鱼苗:0"),"庄园 hired a gardener without permission");
        Sim zyDone;zyDone.manor=true;zyDone.plots[2]=2;zyDone.plots[3]=2;
        require(runTask("tlzz_manor_mine",zyDone,30*60*1000,nullptr,{{"zy_level","少量"},{"zy_kind","石灰石"}})&&zyDone.log.contains("talk:何闲庭"),qPrintable("庄园采矿 finished: "+zyDone.log.join(" | ")));
        Sim zyPlant;zyPlant.manor=true;zyPlant.plots[0]=2;zyPlant.plots[1]=4;
        require(!runTask("tlzz_manor_plant",zyPlant,30000,nullptr,{{"zy_level","中生"},{"zy_kind","桃树"}})&&zyPlant.log.contains("talk:2号苗圃")&&zyPlant.log.contains("option:收获木材:0")&&!zyPlant.log.contains("talk:1号苗圃"),
            qPrintable("庄园种植 harvest: "+zyPlant.log.join(" | ")));
        Sim kj;kj.shown.insert("Examination");
        kj.examText=QString::fromUtf8("在《神雕侠侣》中，在洪七公与欧阳锋两大高手夹击之下，全身筋脉俱废的是谁？\n下列答案中只有1个是正确的，请选择\t洪七公\t藏边五丑\t欧阳锋\t\t");
        require(!runTask("tlzz_keju",kj,10000,nullptr,{{"legacy_id","tlzz_keju"}})&&kj.log.contains("ui:Examination_Button_Clicked:2")&&!kj.log.contains("ui:Examination_Button_Clicked:1"),
            qPrintable("科举 answer: "+kj.log.join(" | ")));
        Sim kjNoBank;QString kjWhy;require(!runTask("tlzz_keju",kjNoBank,10000,&kjWhy)&&kjWhy.contains(QString::fromUtf8("题库未加载")),qPrintable("科举 without bank: "+kjWhy));
        Sim yj;yj.shown.insert("ActivitySchedule_Shop2");yj.stock.insert("金蚕丝",1);
        require(runTask("tlzz_shop_yunjin",yj,30*60*1000,nullptr,{{"shop_items","金蚕丝*2 不存在"}})&&yj.log.contains("shop:72:2:金蚕丝")&&yj.log.contains("shop:72:0:不存在")&&yj.log.count("shop:72:2:金蚕丝")==1,
            qPrintable("云锦行 sequence: "+yj.log.join(" | ")));
        Sim hw;hw.shown.insert("ActivitySchedule_Shop");hw.stock.insert("寒玉",2);
        require(runTask("tlzz_shop_hanwenyu",hw,30*60*1000,nullptr,{{"shop_items","寒玉"}})&&hw.log.count("shop:72:-1:寒玉")==3,qPrintable("寒纹玉 sequence: "+hw.log.join(" | ")));
        Sim hon;hon.map=hon.city="测试城";hon.shown.insert("JueweiShop");
        require(runTask("tlzz_shop_honour",hon,30*60*1000,nullptr,{{"shop_items","甲*2 乙"}})&&hon.log.contains("shop:74:2:甲")&&hon.log.contains("shop:74:-1:乙")&&hon.log.last()=="closeall",
            qPrintable("honour shop sequence: "+hon.log.join(" | ")+" /"));
        Sim t3;t3.map=t3.city="测试城";t3.shown.insert("T3DaibiShop");t3.stock.insert("甲",1);
        require(runTask("tlzz_shop_t3",t3,30*60*1000,nullptr,{{"shop_items","甲 乙"}})&&t3.log.count("shop:76:3:甲")==2&&t3.log.count("shop:76:3:乙")==1,qPrintable("中都行商 sequence: "+t3.log.join(" | ")));
        Sim gs;gs.shown.insert("GuiShi_Shop");require(runTask("tlzz_shop_guishi",gs,30*60*1000,nullptr,{{"shop_items","金蚕丝 雪莲"}})&&gs.log.contains("shop:78:10:金蚕丝")&&gs.log.contains("shop:78:1:雪莲"),
            qPrintable("鬼市 sequence: "+gs.log.join(" | ")));
        Sim cl;cl.map=cl.city="测试城";cl.shown.insert("ChongLou_DaibiShop");cl.stock.insert("灵玉",1);
        require(runTask("tlzz_shop_chonglou",cl,30*60*1000,nullptr,{{"shop_items","灵玉*3"}})&&cl.log.contains("shop:77:3:灵玉"),qPrintable("玲珑阁 sequence: "+cl.log.join(" | ")));
        Sim lj;lj.money=2000000;lj.goldGift="金币\t银两\t宝石";require(runTask("tlzz_shop_liujin",lj,30*60*1000,nullptr,{{"shop_items","宝石 金币"}})&&lj.log.count("gift:3")==2,
            qPrintable("鎏金礼匣 sequence: "+lj.log.join(" | ")));
        Sim hd;hd.hdLeft=2;hd.lists.insert(0,{{"活动宝箱",2},{"其他",1}});const bool hdOk=runTask("tlzz_huodong_sweep",hd,30*60*1000);require(hdOk&&hd.log==QStringList{"ui:PlayerQuicklyEnter_OpenSecKillBox","ui:SweepAll_Tab_2_OnClick",
            "xs:OnFuBenSecKill:1","xs:OnFuBenSecKill:1","box:活动宝箱","ui:Item_MultiUse_BuyMulti_Clicked"},qPrintable("活动扫荡 sequence: "+hd.log.join(" | ")));
        Sim hdNoBox;hdNoBox.lists.insert(0,{{"活动宝箱",2}});require(runTask("tlzz_huodong_sweep",hdNoBox,30*60*1000,nullptr,{{"hdsd_openbox",false}})&&!hdNoBox.log.join(" ").contains("box:"),"活动扫荡 opened boxes when disabled");
        Sim awOut;QString awWhy;require(!runTask("tlzz_manor_awake",awOut,30000,&awWhy,{{"zy_pets","小白"}})&&awWhy.contains("手动进入"),qPrintable("血脉觉醒 outside the manor: "+awWhy));
        Sim aw;aw.manor=true;aw.shown.insert("BieYePetBar_Awake");aw.awake="1&小白?可觉醒 2&小黑?疲劳 3&路人?可觉醒 \t1&小花?无法觉醒 2&小黑?可觉醒 ";
        aw.uiPrompt.insert("BieYePetBar_Awake_Promote_Click","#{JYSL_160518_136}");
        const bool awOk=runTask("tlzz_manor_awake",aw,30*60*1000,nullptr,{{"zy_pets","小白  小黑 小花"}});
        require(awOk&&aw.log.mid(0,6)==QStringList{"closeall","awake:1:0:0","awake:1:0:1","awake:2:1:0","awake:2:0:1","ui:BieYePetBar_Awake_Promote_Click"}
            &&aw.log.count("ui:BieYePetBar_Awake_Promote_Click")==1,qPrintable("血脉觉醒 sequence: "+aw.log.join(" | ")));
        const QSet<QString> jxOptions{"#{ZMYD_230801_269}","#{ZMYD_230801_354}","#{ZMYD_230801_641}"};
        Sim jx1;jx1.menpai=0;jx1.held.insert("初识秘境济师门",1);jx1.noOption=jxOptions;
        const bool jx1Ok=runTask("tlzz_juexue_guide",jx1,30*60*1000);require(jx1Ok&&jx1.log==QStringList{"run:883,97,50","talk:灵门禅师","button:3","talk:灵门禅师"},qPrintable("绝学引导 mission 1: "+jx1.log.join(" | ")));
        Sim jx2;jx2.menpai=0;jx2.held.insert("开灵除尘秘宝现",0);const bool jx2Ok=runTask("tlzz_juexue_guide",jx2,30*60*1000);require(jx2Ok&&jx2.log==QStringList{"run:883,96,59"},qPrintable("绝学引导 mission 2: "+jx2.log.join(" | ")));
        Sim jx3;jx3.menpai=0;jx3.held.insert("绝学问武意纵横",0);require(runTask("tlzz_juexue_guide",jx3,30*60*1000)&&jx3.log.isEmpty(),qPrintable("绝学引导 chose a sect without permission: "+jx3.log.join(" | ")));
        Sim jx4;jx4.menpai=0;jx4.held.insert("绝学问武意纵横",0);jx4.noOption=jxOptions;
        const bool jx4Ok=runTask("tlzz_juexue_guide",jx4,30*60*1000,nullptr,{{"jxyd_choose",true}});require(jx4Ok&&jx4.log==QStringList{"sect:0","run:883,134,55","talk:灵源","button:3","closeall","run:883,97,50","talk:灵门禅师"},
            qPrintable("绝学引导 mission 3: "+jx4.log.join(" | ")));
        Sim jxNone;require(runTask("tlzz_juexue_guide",jxNone,30*60*1000)&&jxNone.log.isEmpty(),"绝学引导 ran for an unknown school");
        Sim wl;wl.held.insert("裹银武林印之贝叶经残片",1);const bool wlOk=runTask("tlzz_wulinyin",wl,30*60*1000);require(wlOk&&wl.held.isEmpty()&&wl.log.mid(0,4)==QStringList{"run:0,290,321","talk:诸葛孔亮","option:裹银武林印之贝叶经残片:1","button:2"}
            &&wl.log.count("option:镏金武林印之云锦商行:1")>=3&&!wl.log.join(" ").contains("npcshop:"),qPrintable("武林印 sequence: "+wl.log.join(" | ")));
        Sim wlBuy;wlBuy.held.insert("青铜武林印之除恶务尽",0);const bool wlBuyOk=runTask("tlzz_wulinyin",wlBuy,30*60*1000);require(wlBuyOk&&wlBuy.log.count("npcshop:金创药")==3&&wlBuy.log.contains("talk:卢三七")
            &&wlBuy.log.contains("option:购买药品:1"),qPrintable("武林印 buy sequence: "+wlBuy.log.join(" | ")));
        Sim bs;const bool bsOk=runTask("tlzz_bank_save",bs,30*60*1000,nullptr,{{"bank_save_bind","波斯玫瑰"},{"bank_save_money",true},{"bank_keep_money",1}});
        require(bsOk&&bs.log.contains("bagstore:波斯玫瑰:2")&&bs.log.contains("bankmoney:2:10000")&&bs.money==10000,qPrintable("物品存仓 sequence: "+bs.log.join(" | ")));
        Sim bsNone;require(runTask("tlzz_bank_save",bsNone,30*60*1000)&&!bsNone.log.join(" ").contains("bagstore")&&!bsNone.log.join(" ").contains("bankmoney"),"物品存仓 stored without a list");
        Sim bt;bt.bag=0;bt.stacks={5};const bool btOk=runTask("tlzz_bank_take",bt,30*60*1000,nullptr,{{"bank_take","波斯玫瑰"}});
        require(btOk&&bt.log.contains("bankitem:波斯玫瑰")&&bt.bag==5,qPrintable("仓库取物 sequence: "+bt.log.join(" | ")));
        Sim sp;sp.bag=10;sp.talkWindow.insert("何生金","Shop");sp.optionWindow.insert("购买药品","Shop");
        const bool spOk=runTask("tlzz_supply",sp,30*60*1000,nullptr,{{"sell_bind","旧衣服"},{"buy_jcy_count",3}});
        require(spOk&&sp.log.mid(0,3)==QStringList{"run:2,208,177","talk:何生金","sell:旧衣服:2"}&&sp.log.contains("talk:卢三七")&&sp.log.count("npcshop:金创药")==3,
            qPrintable("买卖补给 sequence: "+sp.log.join(" | ")));
        Sim spNone;spNone.bag=0;require(runTask("tlzz_supply",spNone,30*60*1000)&&!spNone.log.join(" ").contains("sell:")&&!spNone.log.join(" ").contains("npcshop:"),"买卖补给 acted without settings");
        Sim rp;rp.bag=5;rp.equip.insert(0,QVariantList{601,10300001,3,QString("神器甲")});rp.equip.insert(1,QVariantList{501,-1,3,QString("帽子甲")});rp.equip.insert(4,QVariantList{701,-1,0,QString("鞋甲")});
        const bool rpOk=runTask("tlzz_repair",rp,30*60*1000);
        require(rpOk&&rp.log==QStringList{"run:1,354,249","talk:薛菲","repair:1:1","restore:4:1","repair:4:1"},qPrintable("修理装备 sequence: "+rp.log.join(" | ")));
        Sim rw;rw.vip=6;rw.bag=5;rw.wuhunLow=true;rw.money=60000;const bool rwOk=runTask("tlzz_repair",rw,30*60*1000);
        require(rwOk&&rw.log==QStringList{"wuhunrepair"},qPrintable("修理武魂 sequence: "+rw.log.join(" | ")));
        Sim rwLow;rwLow.bag=5;rwLow.wuhunLow=true;require(runTask("tlzz_repair",rwLow,30*60*1000)&&!rwLow.log.contains("wuhunrepair"),"修理武魂 ran below VIP6");
        require(sellSeen.contains("tlzz_supply")&&!sellSeen.contains("tlzz_bank_save"),"Selling was not classified");
        Sim ls;ls.money=3000000;ls.optionPrompt.insert("#{CPBT_260115_06}","#{CPBT_260115_14}");const bool lsOk=runTask("tlzz_buy_lushu",ls,30*60*1000);
        require(lsOk&&ls.log==QStringList{"run:1,224,226","talk:吴玠","option:#{CPBT_260115_02}:1","option:#{CPBT_260115_06}:1","ui:MessageBox_Self_OK_Clicked"},qPrintable("购买路书 sequence: "+ls.log.join(" | ")));
        Sim lsCap;lsCap.money=3000000;require(runTask("tlzz_buy_lushu_low",lsCap,60*60*1000)&&lsCap.log.count("option:#{CPBT_260115_06}:1")==30,"购买初级路书 was not capped");
        Sim lm;lm.money=3000000;lm.optionPrompt.insert("#{CPBT_260115_07}","#{CPBT_260115_92}");const bool lmOk=runTask("tlzz_buy_lushu_mid",lm,30*60*1000);
        require(lmOk&&lm.log.count("option:#{CPBT_260115_07}:1")==1&&lm.log.contains("ui:MessageBox_Self_Cancel_Clicked:0")&&lm.log.contains("bankmoney:2:3000000"),qPrintable("购买中级路书 sequence: "+lm.log.join(" | ")));
        Sim xb;xb.money=3000000;xb.optionPrompt.insert("#{XCBT_260506_05}","#{XCBT_260506_10}");const bool xbOk=runTask("tlzz_buy_xunbaotu",xb,30*60*1000);
        require(xbOk&&xb.log.count("option:#{XCBT_260506_05}:1")==2&&xb.log.count("talk:吴玠")==1,qPrintable("购买寻宝图 sequence: "+xb.log.join(" | ")));
        Sim xl;const bool xlOk=runTask("tlzz_xiulian",xl,30*60*1000,nullptr,{{"zdxl_list","第1本-第2卷-到3重"}});
        require(xlOk&&xl.log.count("xs:AskXiuLianLevelUp:171:1")==2&&xl.log.count("xs:AskXiuLianAdvanceJingJie:171:1")==1&&xl.xlJing==3&&xl.log.mid(0,3)==QStringList{"run:2,241,31","talk:扫地神僧","option:#{XL_XML_35}:1"},
            qPrintable("点修炼 sequence: "+xl.log.join(" | ")));
        Sim xlNone;require(runTask("tlzz_xiulian",xlNone,30*60*1000)&&xlNone.log.isEmpty(),"点修炼 ran without a plan");
        Sim xf;xf.menpai=0;const bool xfOk=runTask("tlzz_xinfa",xf,30*60*1000,nullptr,{{"xf_1",2}});
        require(xfOk&&xf.log.count("xinfa:1")==2&&xf.log.contains("msgbox:需要使用角色自身经验")&&xf.log.contains("run:9,91,72")&&xf.log.contains("bankmoney:1:99999"),qPrintable("点心法 sequence: "+xf.log.join(" | ")));
        Sim xfBad;require(runTask("tlzz_xinfa",xfBad,30*60*1000)&&xfBad.log.isEmpty(),"点心法 ran for an unknown school");
        Sim lf;lf.bag=90;lf.cost=42;const bool lfOk=runTask("tlzz_luanfei_mianbu",lf,30*60*1000);
        require(lfOk&&lf.log.count("button:3")==2&&lf.log.count("option:42个乱匪密函兑换封赏:1")==2&&lf.bag==6,qPrintable("乱匪密函换棉布 sequence: "+lf.log.join(" | ")));
        Sim dj;dj.djLeft=3;const bool djOk=runTask("tlzz_dianjin",dj,30*60*1000,nullptr,{{"dj_mianbu",true}});
        require(djOk&&dj.log.count("dianjin:0:1:0")==5&&dj.log.contains("talk:彭怀玉")&&dj.log.contains("option:#{ZZQH_180929_1}:1"),qPrintable("材料点金 sequence: "+dj.log.join(" | ")));
        Sim djNone;require(runTask("tlzz_dianjin",djNone,30*60*1000)&&djNone.log.isEmpty(),"材料点金 ran without materials");
        Sim xz;xz.bag=12;const bool xzOk=runTask("tlzz_xz_gift",xz,30*60*1000);
        require(xzOk&&xz.log.count("xzgift:剑谱")==1&&xz.given.size()==15&&xz.log.count("ui:GiveGift_GiveTenTime")==15&&xz.log.count("ui:GiveGift_GiveOneTime")==45&&xz.log.endsWith("close:GiveGift"),
            qPrintable("名士赠礼 sequence: "+xz.log.join(" | ")));
        Sim gc;gc.carveLeft=2;const bool gcOk=runTask("tlzz_gem_carve",gc,30*60*1000,nullptr,{{"bsdz_list","红宝石（3级）"},{"bsdz_bind",true},{"bsdz_unbind",true}});
        require(gcOk&&gc.log.count("carve:红宝石(3级)")==2&&gc.log.contains("talk:彭怀玉"),qPrintable("宝石雕琢 sequence: "+gc.log.join(" | ")));
        Sim gcOne;gcOne.carveLeft=2;require(runTask("tlzz_gem_carve",gcOne,30*60*1000,nullptr,{{"bsdz_list","红宝石(3级)"},{"bsdz_bind",true}})&&gcOne.log.isEmpty(),"宝石雕琢 ran with a single bind type");
        Sim lwg;lwg.lwEq=true;lwg.lwItems={{10,1,5,1},{11,1,1,0},{12,2,1,1},{13,3,38000152,1}};
        const bool lwOk=runTask("tlzz_longwen",lwg,30*60*1000,nullptr,{{"lw_allow",true}});
        require(lwOk&&lwg.log.count("lwcombine:10:11:13")==1&&lwg.log.count("lwcombine:10:12:13")==1&&lwg.log.count("lwunequip")==1&&lwg.log.contains("lwequip:10")&&lwg.lwEq
            &&lwg.log.contains("run:850,125,201"),qPrintable("合成龙纹 sequence: "+lwg.log.join(" | ")));
        Sim lwNo;lwNo.lwEq=true;require(runTask("tlzz_longwen",lwNo,30*60*1000)&&lwNo.log.isEmpty()&&lwNo.lwEq,"合成龙纹 unequipped without permission");
        {   // Every task must end by itself (finish or fail with a reason) within its declared timeout in a neutral world.
            const auto catalog=QJsonDocument::fromJson([&]{QFile f(root+"/design/task-catalog.json");require(f.open(QIODevice::ReadOnly),"Catalog missing");return f.readAll();}()).object().value("tasks").toArray();
            QStringList report;
            for(const auto &v:manifest.value("tasks").toArray()){
                const auto e=v.toObject();const auto id=e.value("id").toString();
                if(e.value("requires_resident").toBool()||id=="zhenlong_combat"||id=="dungeon_combat"||id=="battle_inspect"||id=="daily_sign"||id=="tlzz_wait_time"||id=="tlzz_wait_team")continue;
                QJsonObject settings{{"legacy_id",id}};for(const auto &c:catalog)if(c.toObject().value("id").toString()==id)
                    for(const auto &st:c.toObject().value("settings").toArray())settings.insert(st.toObject().value("key").toString(),st.toObject().value("default"));
                const qint64 limit=qint64(e.value("timeout_seconds").toInt(600))*1000;
                Sim g;QString outcome="timeout";int actions=0;QStringList last;
                try{
                    LegacyRunner runner;QString error;
                    if(!runner.load(legacy+"/"+e.value("entry").toString(),error,legacy+"/compat.lua",settings))outcome="load:"+error;
                    else for(qint64 now=0;now<=limit;now+=100){
                        LegacyRequest r;const auto p=runner.poll(now,r,error);for(const auto &m:runner.takeMessages()){last<<m;if(last.size()>3)last.removeFirst();}
                        if(p==LegacyRunner::Failed){outcome="failed:"+error;break;}
                        if(p==LegacyRunner::Finished){outcome=QString("finished@%1s").arg(now/1000);break;}
                        if(p==LegacyRunner::Action){if(r.kind==LegacyRequest::Snippet&&gameplay::snippetIssuesAction(r.snippet))++actions;if(!runner.acknowledge(r.id,true,{},respond(g,r))){outcome="receipt";break;}}
                    }
                }catch(const std::exception &x){outcome=QString("exception:")+x.what();}
                report<<QString("%1\t%2\tactions=%3\t%4").arg(id,outcome).arg(actions).arg(last.join(" / "));
            }
            QFile out(QDir::tempPath()+"/tlbb-task-sweep.txt");if(out.open(QIODevice::WriteOnly|QIODevice::Truncate))out.write(report.join("\n").toUtf8());
            QStringList stuck;for(const auto &line:report){const auto f=line.split('\t');
                if(f.value(1)=="timeout"||f.value(1).startsWith("exception")||f.value(1).startsWith("load:")||f.value(1)=="receipt"||f.value(2).mid(8).toInt()>600)stuck<<f.value(0)+" "+f.value(1);}
            require(stuck.isEmpty(),qPrintable("Tasks that do not end by themselves: "+stuck.join("; ")));
        }
        Sim ljPoor;ljPoor.stored=0;require(runTask("tlzz_shop_liujin",ljPoor,30*60*1000,nullptr,{{"shop_items","宝石"}})&&!ljPoor.log.join(" ").contains("gift:"),"鎏金礼匣 opened without enough gold");
        Sim fatie;fatie.optionPrompt.insert("#{XKSC_200325_05}","#{XKSC_200325_12}");
        require(runTask("tlzz_wuxing_fatie",fatie,30*60*1000)&&fatie.log==QStringList{"run:1,200,334","talk:独孤悔","talk:独孤悔","option:#{XKSC_200325_01}:1","option:#{XKSC_200325_05}:1"},
            qPrintable("五行法帖 sequence: "+fatie.log.join(" | ")));
        Sim huoyue;huoyue.box=1;huoyue.today=500;huoyue.week=2500;require(runTask("tlzz_huoyue_gift",huoyue,30*60*1000)
            &&huoyue.log==QStringList{"xs:OnAugury:1","xs:OnAugury:2","xs:OnAugury:3","xs:OnAugury:4","xs:OnAugury_week:1","xs:OnAugury_week:2"},qPrintable("Activity gift sequence: "+huoyue.log.join(" | ")));
        Sim lowActive;lowActive.box=2;lowActive.today=40;lowActive.week=1500;require(runTask("tlzz_huoyue_gift",lowActive,30*60*1000)&&lowActive.log==QStringList{"xs:OnAugury_week:1"},
            qPrintable("Activity gift thresholds: "+lowActive.log.join(" | ")));
        Sim seed;seed.npcItem="#{SDJZH_091106_23}";require(runTask("tlzz_flower_seed",seed,30*60*1000)
            &&seed.log==QStringList{"run:2,185,65","talk:阿里","talk:阿里","option:#{SDJZH_xml_XX(13)}:1","closeall"},qPrintable("Flower seed sequence: "+seed.log.join(" | ")));
        for(const char *id:{"tlzz_flower_seed","tlzz_rose_claim"}){
            Sim full;full.npcItem="#{SDJZH_091106_24}";QString failure;
            require(!runTask(id,full,30*60*1000,&failure)&&failure.contains("不会自动删除"),qPrintable(QString(id)+" bag-full did not stop: "+failure));
        }
        Sim guild;guild.map=guild.city="测试城";guild.prompts="#{ZGMW_201009_33}\n";require(runTask("tlzz_guild_zhangong",guild,30*60*1000)
            &&guild.log==QStringList{"run:0,93,54","talk:赵子勋","option:#{ZGMW_201009_01}:1","ui:T3ZhanGongGet_OnOKClicked","closeall"},qPrintable("Guild merit sequence: "+guild.log.join(" | ")));
        Sim noGuild;require(runTask("tlzz_guild_zhangong",noGuild,30*60*1000)&&noGuild.log==QStringList{"closeall"},qPrintable("No-guild merit sequence: "+noGuild.log.join(" | ")));
        Sim stale;stale.map=stale.city="测试城";stale.prompts="#{ZJSJ_220708_44}\n";
        require(!runTask("tlzz_guild_ziwei_lastweek",stale,10*1000)&&stale.log.count("talk:姜星落")>=2,qPrintable("Old prompt ended the task early: "+stale.log.join(" | ")));
        {
            QFile catalogFile(root+"/design/task-catalog.json");require(catalogFile.open(QIODevice::ReadOnly),"Catalog missing");
            QSet<QString> tagged;for(const auto &v:QJsonDocument::fromJson(catalogFile.readAll()).object().value("tasks").toArray())if(v.toObject().value("risks").toArray().contains(QJsonValue("spend")))tagged.insert(v.toObject().value("id").toString());
            for(const auto &id:spendSeen)require(tagged.contains(id),qPrintable(id+" spends money but has no 允许支付 switch"));
            catalogFile.seek(0);QSet<QString> offlineTagged;for(const auto &v:QJsonDocument::fromJson(catalogFile.readAll()).object().value("tasks").toArray())if(v.toObject().value("risks").toArray().contains(QJsonValue("offline")))offlineTagged.insert(v.toObject().value("id").toString());
            for(const auto &id:offlineSeen)require(offlineTagged.contains(id),qPrintable(id+" closes the game but has no 允许下线 switch"));
            gameplay::SnippetArgs lottery;std::wcscpy(lottery.text,L"幸运快活三");lottery.ints[0]=1;
            require(offlineSeen.contains("tlzz_offline")&&tagged.contains("tlzz_xingyun")&&
                (gameplay::snippetRisk(gameplay::QuestOption,lottery)&gameplay::RiskSpend),"Offline / 快活三 steps were not classified");
            require(spendSeen.contains("tlzz_cangbaotu")&&spendSeen.contains("tlzz_wangquan_yuxi"),"藏宝图 / 王权御玺 spending was not classified");
            for(const char *id:{"tlzz_compose_mianbu","tlzz_hunbingzhu","tlzz_jiutian_yusui","tlzz_qianxin","tlzz_haoqi","tlzz_equip_adjust","tlzz_lianchi","tlzz_shop_yunjin","tlzz_shop_honour","tlzz_shop_t3","tlzz_shop_guishi","tlzz_shop_chonglou","tlzz_shop_liujin","tlzz_manor_awake","tlzz_wulinyin","tlzz_supply","tlzz_repair","tlzz_buy_lushu","tlzz_buy_lushu_mid","tlzz_buy_xunbaotu","tlzz_xiulian","tlzz_xinfa","tlzz_dianjin","tlzz_gem_carve","tlzz_longwen"})require(spendSeen.contains(id),qPrintable(QString(id)+" compose fee was not classified"));
            require(spendSeen.contains("tlzz_qihongjin_gold")&&spendSeen.contains("tlzz_exp_recover"),"Spending steps were not classified");
            gameplay::SnippetArgs free;free.ints[0]=5;free.ints[1]=1;require(gameplay::snippetRisk(gameplay::XScript,free)==gameplay::RiskNone,"Free reward claim marked as spending");
        }
        Sim ruby;ruby.bag=20;ruby.cost=20;require(runTask("tlzz_wish_fruit_ruby",ruby,30*60*1000)&&ruby.log==QStringList{"run:1,282,275","talk:梁道士","option:许愿果兑换奖励:1","option:红宝石:0","option:我要兑换:1",
            "ui:Packet_Temporary_BtnClick","temp:许愿果:0","close:Packet_Temporary","run:2,217,174","talk:何伙计","option:打开银行:0","bankbig","closeall"},qPrintable("Ruby exchange sequence: "+ruby.log.join(" | ")));
        // 原文件数量判断恒为真会无限循环：只允许改正后的重建版本上架。
        for(const char *broken:{"tlzz_luanfei_mianbu"}){for(const auto &v:manifest.value("tasks").toArray()){const auto o=v.toObject();
            if(o.value("id").toString()==broken)require(o.value("reconstructed").toBool()&&o.value("entry").toString().startsWith("rebuilt/"),"Endless-loop original was listed");}}
        const QStringList openBank{"run:2,217,174","talk:何伙计","option:打开银行:0","bankbig"};
        Sim get;require(runTask("tlzz_bank_get_money",get,30*60*1000)&&get.log==openBank+QStringList{"bankmoney:1:30000","closeall"}&&get.money==50000,qPrintable("Bank withdraw sequence: "+get.log.join(" | ")));
        Sim save;require(runTask("tlzz_bank_save_money",save,30*60*1000)&&save.log==openBank+QStringList{"bankmoney:2:20000","closeall"}&&save.money==0,qPrintable("Bank deposit sequence: "+save.log.join(" | ")));
        Sim rich;rich.money=60000;require(runTask("tlzz_bank_get_money",rich,60000)&&rich.log.isEmpty(),"Withdraw ran with enough money carried");
        Sim rose;rose.bag=0;rose.tempItems=30;rose.stacks={20,20};
        require(runTask("tlzz_rose",rose,60*60*1000),qPrintable("Rose with bank did not finish: "+rose.log.join(" | ")));
        require(rose.log.count("button:3")==2&&rose.log.count("bankitem:波斯玫瑰")==2&&rose.log.count("temp:波斯玫瑰:1")==1&&rose.bag==10&&rose.stacks.isEmpty(),qPrintable("Rose bank/temporary bag flow: "+rose.log.join(" | ")));
        Sim shop;require(runTask("tlzz_shop_get_money",shop,30*60*1000)&&shop.money==50000
            &&shop.log==QStringList{"run:0,330,299","talk:乔复盛","talk:乔复盛","option:#{RCYH_180606_105}:1","shopmoney:30000"},qPrintable("Shop withdraw sequence: "+shop.log.join(" | ")));
        auto gemSim=[](QList<Sim::Gem> gems){Sim g;g.gems=gems;g.talisman=5;return g;};
        const QStringList gemWindow{"close:Gemcompose","run:0,282,321","talk:彭怀玉","option:#{BSLCYH_130529_133}:1"};
        const QStringList noMore{"ui:Packet_Temporary_BtnClick","close:Packet_Temporary","run:2,217,174","talk:何伙计","option:打开银行:0","bankbig","closeall","close:Gemcompose"};
        Sim unbound=gemSim({{"红宝石（1级）",0,10,1},{"红宝石（1级）",1,4,1}});
        require(runTask("tlzz_gem_unbound",unbound,30*60*1000)&&unbound.log==gemWindow+QStringList{"combine:红宝石（1级）:5","combine:红宝石（1级）:5"}+noMore&&unbound.talisman==3,
            qPrintable("Unbound gem sequence: "+unbound.log.join(" | ")));
        Sim bound=gemSim({{"红宝石（1级）",0,10,1},{"红宝石（1级）",1,4,1}});
        require(runTask("tlzz_gem_bound",bound,30*60*1000)&&bound.log.filter(QRegularExpression("^combine:")).size()==0&&bound.talisman==5,qPrintable("Bound gem sequence: "+bound.log.join(" | ")));
        Sim mixed=gemSim({{"红宝石（1级）",0,3,1},{"红宝石（1级）",1,2,1}});
        require(runTask("tlzz_gem_mixed",mixed,30*60*1000)&&mixed.log.count("combine:红宝石（1级）:5")==1&&mixed.talisman==4,qPrintable("Mixed gem sequence: "+mixed.log.join(" | ")));
        Sim noTalisman=gemSim({{"蓝宝石（4级）",0,5,4}});
        require(runTask("tlzz_gem_unbound",noTalisman,30*60*1000)&&noTalisman.log.filter(QRegularExpression("^combine:")).size()==0,"Gem compose ran without the matching talisman tier");
        Sim sweep;sweep.left=2;require(runTask("tlzz_sweep_shaoshi",sweep,30*60*1000),"Sweep did not finish");
        const QStringList page{"close:SweepPage","openpage:41","boss:1","ui:SweepPage_OnOkClicked","boss:2","ui:SweepPage_OnOkClicked","close:SweepPage","close:Shop"};
        require(sweep.log==QStringList{"ui:PlayerQuicklyEnter_OpenSecKillBox"}+page+page&&sweep.left==0,qPrintable("Sweep sequence: "+sweep.log.join(" | ")));
        for(const auto &v:manifest.value("tasks").toArray()){const auto id=v.toObject().value("id").toString();if(!id.startsWith("tlzz_sweep_"))continue;
            Sim none;require(runTask(id,none,30*60*1000)&&none.log==QStringList{"ui:PlayerQuicklyEnter_OpenSecKillBox"},qPrintable(id+" without remaining sweeps: "+none.log.join(" | ")));}
        for(const auto &v:manifest.value("tasks").toArray()){
            const auto t=v.toObject();QFile f(legacy+"/"+t.value("entry").toString());require(f.open(QIODevice::ReadOnly),"Manifest entry missing");
            if(t.contains("original_sha256"))require(QCryptographicHash::hash(f.readAll(),QCryptographicHash::Sha256).toHex()==t.value("original_sha256").toString().toLatin1(),qPrintable("Original script changed: "+t.value("id").toString()));
        }
    });
    test("compat_sandbox_hides_primitives_and_stops_on_uncertain_action", [&] {
        const auto legacy=root+"/scripts/legacy";int index=0;
        for(const QByteArray &source:QList<QByteArray>{"__game(1,{0},{1,1})","GetLuaValue('os.execute(1)')","LoadScript('fnOther')","Player:GetData('NAME')","__cn_unsupported()"}){
            const auto file=temp.path()+"/compat-bad-"+QString::number(index++)+".lua";write(file,source);
            LegacyRunner runner;QString error;require(runner.load(file,error,legacy+"/compat.lua"),"Compat fixture failed");LegacyRequest request;
            require(runner.poll(0,request,error)==LegacyRunner::Failed&&!error.isEmpty(),source.constData());
        }
        const auto file=temp.path()+"/compat-move.lua";write(file,"MoveTo(10,10,0)");
        LegacyRunner runner;QString error;require(runner.load(file,error,legacy+"/compat.lua"),"Move fixture failed");LegacyRequest request;
        require(runner.poll(0,request,error)==LegacyRunner::Action&&request.kind==LegacyRequest::Host,"Position not read before moving");
        require(runner.acknowledge(request.id,true,{},{true,0,100.0,100.0,QString("洛阳")}),"Position receipt refused");
        require(runner.poll(100,request,error)==LegacyRunner::Action&&request.snippet==gameplay::RunTo,"Move request missing");
        require(runner.acknowledge(request.id,false,"uncertain"),"Failure receipt refused");
        require(runner.poll(200,request,error)==LegacyRunner::Failed&&error=="uncertain","Uncertain move was resumed");
        QJsonObject config{{"legacy_id","tlzz_rose"},{"timeout_seconds",600}};QString configError;
        require(validateLegacyConfig(config,configError),"Valid legacy config rejected");
        config.insert("legacy_id","../x");require(!validateLegacyConfig(config,configError),"Path-like legacy id accepted");
        config.insert("legacy_id","tlzz_rose");config.insert("timeout_seconds",9);require(!validateLegacyConfig(config,configError),"Short timeout accepted");
    });
    resourceTests(root,test);
    taskAuditTests(root,test);
    combatTests(root,temp.path(),test);
    residentTests(root,temp.path(),test);
    dungeonSweepTests(root,test);
    sanhuanTests(root,temp.path(),test);
    waterPrisonTests(root,test);
    sijueTests(root,test);
    yanziTests(root,test);
    shaoshiTests(root,test);
    piaomiaoTests(root,test);
    bingshengTests(root,test);
    langhuanTests(root,test);
    wanglingTests(root,test);
    sanshenTests(root,test);
    guanshanTests(root,test);
    yezhuTests(root,test);
    mingwangTests(root,test);
    tianboTests(root,test);
    fenghuangTests(root,test);
    yijueTests(root,test);
    julingTests(root,test);
    smallDungeonTests(root,test);
    tianjiangTests(root,test);
    activityTests(root,test);
    saodangTests(root,test);
    battleTests(root,test);
    longTaskTests(root,test);
    shortTaskTests(root,test);
    dailyRoutineTests(root,test);
    originalRulesTests(root,temp.path(),test);
    dailyTaskTests(root,temp.path(),test);
    QJsonObject report{{"status", failure.isEmpty() ? "pass" : "fail"},
                       {"passed", passed},
                       {"passed_count", passed.size()},
                       {"failure", failure},
                       {"scope", "owned fixture processes and explicit preview only; no game actions"}};
    QFile output(reportPath);
    if (output.open(QIODevice::WriteOnly))
        output.write(QJsonDocument(report).toJson());
    return failure.isEmpty() ? 0 : 1;
}
} // namespace tlbb
