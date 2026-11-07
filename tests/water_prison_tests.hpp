#pragma once
#include "sanhuan_tests.hpp"
#include "flow_runner.hpp"
namespace tlbb {
struct WaterFake:ResidentFake {
    bool outer=false,inner=false,leader=true,full=false,noToken=false,noAccept=false,noEntry=false;
    bool noInnerDelivery=false,noOuterDelivery=false,emptyUntilPatrol=false,patrolled=false,wrongIdentity=false,vanish=false,leaveEarly=false;
    int outerState=0,innerState=0,innerId=200,hits=0,outerAccepts=0,innerEntries=0,innerDeliveries=0,outerDeliveries=0,exitRequests=0,choices=0;
    int count=3,tokens=20;QString page="menu",receipt;
    WaterFake(){scene=1;x=342;y=311;}
    QString title()const{return scene==1?QString("帮助平定水牢叛乱"):QString("水牢");}
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value((scene==66?QString("水牢"):scene==4?QString("雁南"):QString("苏州")).toStdString())};
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &format,int n)override{
        using resident::Value;
        if(code.find("dungeon:mission")!=std::string::npos){
            const bool isOuter=code.find("帮助平定水牢叛乱")!=std::string::npos;
            if(!(isOuter?outer:inner))return {Value(-1),Value(-1),Value(-1),Value(std::string())};
            return {Value(isOuter?0:1),Value(isOuter?100:innerId),Value(isOuter?outerState:innerState),Value(std::string("live progress ")+std::to_string(hits))};
        }
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(leader?1:0)};
        if(code.find("dungeon:dialog")!=std::string::npos){
            if(page=="closed")return {Value(-1),Value(std::string()),Value(std::string())};
            const auto t=title().toStdString();return {Value(1),Value(t),Value(t)};
        }
        if(code.find("dungeon:button")!=std::string::npos){
            const bool accept=code.find("local kind=\"accept\"")!=std::string::npos;
            // The actual LuaPlus button adapter compares its page signature.
            // Mirror that receipt check before applying the fake game effect.
            for(const auto &signature:{"outer-accept","inner-accept","inner-enter","inner-turnin","outer-turnin"}){
                const bool current=(std::string(signature)=="outer-accept"&&accept&&(page=="accept"||(!leader&&scene==1&&!outer)))
                    ||(std::string(signature)=="inner-accept"&&accept&&page=="sharedEnter")
                    ||(std::string(signature)=="inner-enter"&&!accept&&page=="enter")
                    ||(std::string(signature)=="inner-turnin"&&!accept&&page=="turnin"&&scene==4)
                    ||(std::string(signature)=="outer-turnin"&&!accept&&page=="turnin"&&scene==1);
                if(current&&code.find("if signature==\""+std::string(signature)+"\"")!=std::string::npos)return {Value(std::string())};
            }
            if(accept&&((page=="accept")||(!leader&&scene==1&&!outer))){++outerAccepts;if(!noAccept){outer=true;outerState=0;page="closed";}return {Value(std::string("outer-accept"))};}
            if(accept&&page=="sharedEnter"){inner=true;innerState=0;scene=66;page="closed";++innerEntries;return {Value(std::string("inner-accept"))};}
            if(!accept&&page=="enter"){++innerEntries;inner=true;innerState=0;hits=0;if(!noEntry)scene=66;page="closed";--tokens;return {Value(std::string("inner-enter"))};}
            if(!accept&&page=="turnin"&&scene==4){++innerDeliveries;if(!noInnerDelivery){inner=false;outerState=1;}page="closed";return {Value(std::string("inner-turnin"))};}
            if(!accept&&page=="turnin"&&scene==1){++outerDeliveries;if(!noOuterDelivery){outer=false;outerState=0;}page="closed";return {Value(std::string("outer-turnin"))};}
            return {Value(std::string())};
        }
        return ResidentFake::evaluate(code,format,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        if(id==gameplay::CloseAll)return {Value(1)};
        if(id==gameplay::BagCount)return {Value(noToken?0:tokens)};
        if(id==gameplay::BagSpace)return {Value(full?0:5)};
        if(id==gameplay::TeamCount)return {Value(count)};
        if(id==gameplay::RunTo){
            if(scene==66&&a.ints[0]==66){
                if(a.reals[0]==95&&a.reals[1]==95){++exitRequests;scene=4;x=95;y=95;return {Value(1)};}
                patrolled=true;
            }
            scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        }
        if(id==gameplay::NpcTarget){page=(!leader&&scene==4)?"sharedEnter":"menu";return {Value(1)};}
        if(id==gameplay::QuestOption){
            const auto label=QString::fromWCharArray(a.text);
            if(label!=title())return {Value(0),Value(std::string())};
            ++choices;
            page=scene==1?(outer&&outerState==1?"turnin":"accept"):(inner&&innerState==1?"turnin":"enter");
            return {Value(1),Value(label.toStdString())};
        }
        if(id==gameplay::CombatScan){
            if(emptyUntilPatrol&&!patrolled)return {Value(1),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
            return {Value(1),Value(10),Value(101),Value(100),Value(x),Value(y),Value(1),Value(100)};
        }
        if(id==gameplay::CombatName)return {Value(1),Value(0),Value(std::string("水牢叛军"))};
        if(id==gameplay::CombatCast){++casts;++hits;if(hits>=3)innerState=1;if(wrongIdentity)++innerId;if(vanish)inner=false;if(leaveEarly)scene=4;return {Value(1)};}
        return ResidentFake::snippet(id,a);
    }
};
template<class Test>void waterPrisonTests(const QString &root,Test test){
    auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};QJsonArray cases;
    auto run=[&](WaterFake &h,QJsonObject config,std::string &why){
        config.insert("legacy_id","dungeon_002fbdb4");config.insert("combat",true);config.insert("dungeon_wait_seconds",5);
        QJsonObject metadata;QString entry,error;must(resolveLegacyEntry(root+"/scripts/legacy","dungeon_002fbdb4",metadata,entry,error),qPrintable(error));
        must(metadata.value("validation_contract")==QJsonValue("water_prison_v1")&&metadata.value("combat").toBool(),"Water entry contract/combat declaration missing");
        const auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,error);must(!source.isEmpty()&&error.isEmpty(),qPrintable(error));
        must(!source.contains("__original_rules="),"Water flow loads placeholder framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=180000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();cases.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"outer_accepts",h.outerAccepts},{"inner_entries",h.innerEntries},{"casts",h.casts},{"exits",h.exitRequests},{"inner_deliveries",h.innerDeliveries},{"outer_deliveries",h.outerDeliveries},{"peak_lua_bytes",double(peak)}});return vm.state();
    };
    test("water_production_entry_two_missions_fight_exit_and_delivery",[&]{
        WaterFake h;std::string why;must(run(h,{},why)==resident::Vm::Completed,why.c_str());
        must(h.outerAccepts==1&&h.innerEntries==1&&h.innerDeliveries==1&&h.outerDeliveries==1&&h.exitRequests==1&&h.casts==3,"Water skipped/repeated a required phase");
        must(!h.outer&&!h.inner&&h.scene==1&&TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object()),"Water terminal state is wrong");
        FlowRunner flow;QString error;const QJsonObject water{{"node_id","water"},{"task","dungeon_002fbdb4"},{"enabled",true},{"params",QJsonObject{}}};
        auto next=water;next.insert("node_id","next");next.insert("task","wait");
        must(flow.start({{"queue",QJsonArray{water,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},error),qPrintable(error));
        const auto time=QDateTime::fromString("2026-10-29T12:00:00+08:00",Qt::ISODate);
        must(flow.poll(time).value("task")==QJsonValue("dungeon_002fbdb4"),"Queue did not select water entry");
        const auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();flow.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());
        must(flow.poll(time).value("node_id")==QJsonValue("next"),"Verified water completion did not release the next task");
    });
    test("water_rounds_patrol_and_in_progress_resume",[&]{
        WaterFake repeated;std::string why;repeated.emptyUntilPatrol=true;must(run(repeated,{{"dungeon_rounds",2}},why)==resident::Vm::Completed,why.c_str());
        must(repeated.patrolled&&repeated.casts==6&&repeated.innerEntries==2&&repeated.outerDeliveries==2,"Water rounds/patrol did not execute");
        for(int mode=0;mode<3;++mode){WaterFake h;h.outer=true;h.inner=mode!=2;h.scene=mode==0?66:mode==1?4:1;h.innerState=mode==1?1:0;h.outerState=mode==2?1:0;
            must(run(h,{},why)==resident::Vm::Completed,why.c_str());must(h.outerAccepts==0&&h.innerEntries==0&&h.casts==(mode==0?3:0),"Water resumed by restarting a completed step");}
    });
    test("water_preconditions_stop_before_acceptance",[&]{
        for(int mode=0;mode<3;++mode){WaterFake h;h.full=mode==0;h.noToken=mode==1;if(mode==2)h.count=2;std::string why;
            must(run(h,{},why)==resident::Vm::Failed,why.c_str());must(h.outerAccepts==0&&h.innerEntries==0&&h.casts==0&&h.receipt.isEmpty(),"Invalid preconditions still entered water prison");}
    });
    test("water_uncertain_accept_entry_and_delivery_not_replayed",[&]{
        for(int mode=0;mode<4;++mode){WaterFake h;h.noAccept=mode==0;h.noEntry=mode==1;h.noInnerDelivery=mode==2;h.noOuterDelivery=mode==3;std::string why;
            must(run(h,{},why)==resident::Vm::Failed,why.c_str());must(h.outerAccepts<=1&&h.innerEntries<=1&&h.innerDeliveries<=1&&h.outerDeliveries<=1&&h.receipt.isEmpty()&&h.stops>0,"Unconfirmed dungeon action replayed or reported success");}
    });
    test("water_mission_and_scene_changes_terminate_without_success",[&]{
        for(int mode=0;mode<4;++mode){WaterFake h;h.wrongIdentity=mode==0;h.vanish=mode==1;h.leaveEarly=mode==2;
            if(mode==3){h.outer=true;h.inner=true;h.innerState=2;h.scene=66;}
            std::string why;must(run(h,{},why)==resident::Vm::Failed,why.c_str());must(h.outerDeliveries==0&&h.receipt.isEmpty(),"Invalid mission/scene got completion receipt");}
    });
    test("water_follower_accepts_shared_prompts_without_selecting_entry",[&]{
        WaterFake h;h.leader=false;std::string why;must(run(h,{},why)==resident::Vm::Completed,why.c_str());
        must(h.innerEntries==1&&h.outerAccepts==1&&h.choices==2,"Follower selected a leader-only acceptance/entry action");
    });
    QFile report(QCoreApplication::applicationDirPath()+"/water-prison-tests.json");must(report.open(QIODevice::WriteOnly),"Water test report unavailable");report.write(QJsonDocument(cases).toJson());
}
}
