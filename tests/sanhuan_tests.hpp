#pragma once
#include "resident_tests.hpp"
#include "task_completion.hpp"
#include <QCoreApplication>

namespace tlbb {
// Runs the production Lua entry/adapter with deterministic game replies. No Game.exe is opened.
struct SanhuanFake:ResidentFake {
    bool modern=false,accepted=false,noAccept=false,noTurnIn=false,full=false,missingProgress=false,replaceMission=false;
    bool noTargetLink=false,emptyAlways=false,emptyUntilMove=false,movedInside=false,mounted=false;
    int stage=0,accepts=0,entries=0,turnIns=0,exits=0,missionId=88;
    QString receipt;
    explicit SanhuanFake(bool isNew):modern(isNew){scene=isNew?246:1;x=isNew?295:133;y=isNew?68:260;}
    QString title() const{return modern?QString("剑荡三环除妖魔"):QString("除匪首力破三关");}
    QStringList choices() const {
        if(scene==653)return {"#{LSHYH_150210_40}","#{LSHYH_150210_43}"};
        if(accepted&&stage<(modern?3:8))return {modern?QString("进入炎魔山"):QString("#{LSHYH_150210_78}")};
        return {title()};
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="loot_snapshot"||op=="mechanism_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value((scene==653?QString("三才峡谷"):scene==777?QString("炎魔山"):scene==246?QString("楼兰"):QString("苏州")).toStdString())};
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &format,int count)override{
        using resident::Value;
        if(code.find("dungeon:mission")!=std::string::npos){
            if(!accepted)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
            const auto desc=stage>=3?QString("{295,68,246,何悦}"):noTargetLink?QString("清除怪物"):QString("{%1,80,777,目标}").arg(80+stage*10);
            return {Value(0),Value(missionId),Value(stage>=(modern?3:8)?1:0),Value((modern?desc:QString("三才峡谷进度")).toStdString())};
        }
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(1)};
        if(code.find("dungeon:dialog")!=std::string::npos){const auto text=choices().join('\n').toStdString();return {Value(int(choices().size())),Value(text),Value(text)};}
        if(code.find("dungeon:button")!=std::string::npos){
            if(code.find("local kind=\"accept\"")!=std::string::npos){++accepts;if(!noAccept)accepted=true;return {Value(std::string("accept"))};}
            if(code.find("if signature==\"turnin\"")!=std::string::npos)return {Value(std::string())};
            ++turnIns;if(!noTurnIn){accepted=false;stage=0;}return {Value(std::string("turnin"))};
        }
        if(code.find("dungeon:sancai-progress")!=std::string::npos){
            if(missingProgress)return {Value(0),Value(std::string()),Value(std::string()),Value(std::string()),Value(std::string()),Value(std::string())};
            auto fraction=[](int n,int total){return Value(std::to_string(n)+"/"+std::to_string(total));};
            if(stage<5)return {Value(1),fraction(stage>=1?30:0,30),fraction(stage>=2?1:0,1),fraction(stage>=3?6:0,6),fraction(stage>=4?1:0,1),fraction(0,1)};
            if(stage<7)return {Value(2),fraction(stage>=6?30:0,30),fraction(0,1),Value(std::string()),Value(std::string()),Value(std::string())};
            return {Value(3),fraction(0,1),Value(std::string()),Value(std::string()),Value(std::string()),Value(std::string())};
        }
        return ResidentFake::evaluate(code,format,count);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;const auto text=QString::fromWCharArray(a.text);
        if(id==gameplay::CloseAll)return {Value(1)};
        if(id==gameplay::Dismount&&mounted)return {Value(-1)};
        if(id==gameplay::RunTo&&scene==777&&a.ints[0]==777)movedInside=true;
        if(id==gameplay::BagSpace)return {Value(full?0:5)};
        if(id==gameplay::QuestOption){
            if(!choices().contains(text))return {Value(0),Value(std::string())};
            if(text=="#{LSHYH_150210_78}"||text=="进入炎魔山"){
                scene=modern?777:653;x=183;y=155;++entries;if(replaceMission)++missionId;
            }else if(text=="#{LSHYH_150210_40}"||text=="#{LSHYH_150210_43}"){scene=1;++exits;}
            return {Value(1),Value(text.toStdString())};
        }
        if(id==gameplay::CombatScan){
            if(emptyAlways||(emptyUntilMove&&!movedInside))return {Value(1),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
            if(a.ints[1]>=0&&a.ints[1]!=100+stage)return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
            return {Value(1),Value(100+stage),Value(1000+stage),Value(100),Value(x),Value(y),Value(1),Value(100)};
        }
        if(id==gameplay::CombatName)return {Value(1),Value(0),Value(std::string("副本敌人"))};
        if(id==gameplay::CombatCast){++stage;++casts;return {Value(1)};}
        return ResidentFake::snippet(id,a);
    }
};

template<class Test>void sanhuanTests(const QString &root,const QString &temporary,Test test){
    auto must=[](bool value,const char *why){if(!value)throw std::runtime_error(why);};
    QJsonArray cases;
    auto execute=[&](SanhuanFake &host,QJsonObject config,std::string &why){
        const auto id=host.modern?"dungeon_new_sanhuan":"dungeon_00320005";
        config.insert("legacy_id",id);config.insert("combat",true);
        QString error;QJsonObject declaration;QString entry;
        must(resolveLegacyEntry(root+"/scripts/legacy",id,declaration,entry,error),qPrintable(error));
        must(declaration.value("validation_contract")=="dungeon_flow_v1","Dungeon completion contract missing");
        const auto source=prepareResidentScript(root+"/scripts/legacy",entry,config,error);
        must(error.isEmpty()&&!source.isEmpty(),qPrintable(error));
        must(!source.contains("__original_rules="),"Explicit flow still loads the mixed vendor framework");
        resident::Vm vm(host);must(vm.start(source.toStdString(),why),why.c_str());
        size_t peak=0;
        for(uint64_t now=0;now<=180000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20){vm.step(now);peak=qMax(peak,vm.allocated());}
        why=vm.error();
        cases.append(QJsonObject{{"task",id},{"state",int(vm.state())},{"error",QString::fromStdString(why)},
            {"accepts",host.accepts},{"entries",host.entries},{"casts",host.casts},{"turnins",host.turnIns},
            {"peak_lua_bytes",double(peak)},{"receipt",QJsonDocument::fromJson(host.receipt.toUtf8()).object()}});
        QFile report(QCoreApplication::applicationDirPath()+"/sanhuan-flow-tests.json");
        must(report.open(QIODevice::WriteOnly),"Dungeon flow report unavailable");
        report.write(QJsonDocument(QJsonObject{{"real_game_tested",false},{"cases",cases}}).toJson());
        return vm.state();
    };
    test("sanhuan_two_production_entries_complete_accept_combat_exit_turnin",[&]{
        for(bool modern:{false,true}){
            SanhuanFake host(modern);std::string why;
            must(execute(host,{},why)==resident::Vm::Completed,(why+" | "+host.logText).c_str());
            must(host.accepts==1&&host.entries==1&&host.turnIns==1,"Dungeon actions are missing or replayed");
            must(host.casts==(modern?3:8)&&host.scene==(modern?246:1)&&!host.accepted,"Dungeon did not finish its combat/exit/mission lifecycle");
            must(TaskCompletion::verified(QJsonDocument::fromJson(host.receipt.toUtf8()).object()),"Dungeon completion receipt missing");
            if(!modern)for(const auto &stage:QStringList{"宋兵","副都统","匪类","都统","余毒","野熊","红熊王","葛荣"})
                must(QString::fromStdString(host.logText).contains("战斗 · "+stage),"Old dungeon skipped a combat stage");
        }
    });
    test("sanhuan_rounds_and_completed_mission_resume",[&]{
        SanhuanFake repeated(false);std::string why;
        must(execute(repeated,{{"dungeon_rounds",2}},why)==resident::Vm::Completed,why.c_str());
        must(repeated.accepts==2&&repeated.entries==2&&repeated.turnIns==2&&repeated.casts==16,"Round count is wrong");
        SanhuanFake done(false);done.accepted=true;done.stage=8;
        must(execute(done,{},why)==resident::Vm::Completed,why.c_str());
        must(done.accepts==0&&done.entries==0&&done.casts==0&&done.turnIns==1,"Completed mission was replayed");
        SanhuanFake inside(false);inside.accepted=true;inside.stage=5;inside.scene=653;
        must(execute(inside,{},why)==resident::Vm::Completed,why.c_str());
        must(inside.entries==0&&inside.accepts==0&&inside.casts==3&&inside.turnIns==1,"In-progress dungeon did not resume");
    });
    test("sanhuan_failures_do_not_claim_success_or_repeat_actions",[&]{
        for(int mode=0;mode<5;++mode){
            SanhuanFake host(false);host.full=mode==0;host.noAccept=mode==1;host.noTurnIn=mode==2;
            host.missingProgress=mode==3;host.replaceMission=mode==4;std::string why;
            must(execute(host,{},why)==resident::Vm::Failed,("mode="+std::to_string(mode)+" "+why).c_str());
            must(host.receipt.isEmpty()&&host.stops>0,"Failed dungeon has a success receipt or no cleanup");
            must(host.accepts<2&&host.entries<2&&host.turnIns<2,"Unconfirmed action was replayed");
            if(mode==0)must(host.accepts==0&&host.entries==0,"Full bag still submitted a mission");
            if(mode==3)must(host.casts==0&&why.find("进度")!=std::string::npos,"Missing progress became stage zero");
            if(mode==4)must(host.casts==0&&why.find("身份")!=std::string::npos,"Changed mission identity was ignored");
        }
    });
    test("sanhuan_new_route_validation_runs_before_game_actions",[&]{
        SanhuanFake host(true);std::string why;
        must(execute(host,{{"sanhuan_route","100,120;bad"}},why)==resident::Vm::Failed,why.c_str());
        must(host.accepts==0&&host.entries==0&&host.casts==0,"Invalid route reached game actions");
    });
    test("sanhuan_new_missing_coordinates_and_configured_patrol",[&]{
        SanhuanFake missing(true);missing.noTargetLink=true;missing.emptyAlways=true;std::string why;
        must(execute(missing,{},why)==resident::Vm::Failed&&why.find("巡点")!=std::string::npos,why.c_str());
        must(missing.casts==0&&missing.receipt.isEmpty(),"Missing target coordinates were treated as success");
        SanhuanFake routed(true);routed.noTargetLink=true;routed.emptyUntilMove=true;
        must(execute(routed,{{"sanhuan_route","200,210;220,230"}},why)==resident::Vm::Completed,why.c_str());
        must(routed.movedInside&&routed.casts==3&&routed.turnIns==1,"Configured patrol did not run");
    });
    test("sanhuan_unadapted_mount_stops_before_accept_or_entry",[&]{
        SanhuanFake host(false);host.mounted=true;std::string why;
        must(execute(host,{},why)==resident::Vm::Failed&&why.find("坐骑")!=std::string::npos,why.c_str());
        must(host.accepts==0&&host.entries==0&&host.casts==0,"Mount precondition was checked after entering");
    });
    test("dungeon_flow_waits_for_follower_and_checks_terminal_contract",[&]{
        const auto entry=temporary+"/dungeon-flow-contract.lua";QFile file(entry);
        must(file.open(QIODevice::WriteOnly),"Dungeon contract test unavailable");
        file.write(R"LUA(
LoadScript('dungeon_flow')
for mode=1,6 do
 local time,accepted,inside,complete,submitted,entered,delivered,stopped=0,false,false,false,0,0,0,0
 local maintenance=0
 local def={name='test',npc={},inside=function(w) return w.scene==7 end}
 local api={now=function() return time end,sleep=function(n) time=time+n end,log=function() end,
 validate=function() end,prepareBattle=function() end,stop=function() stopped=stopped+1 end,world=function() return {scene=inside and 7 or 1} end,
 mission=function() if not accepted then return end return {id=42,status=complete and 1 or 0} end,
 openNpc=function() end,limit=function() return mode==2 end,space=function() end,
 accept=function() submitted=submitted+1;accepted=true end,isLeader=function() return false end,
 teamReady=function() if mode==3 then return false end inside=true;return true end,
 enter=function() entered=entered+1 end,beginBattle=function() return {} end,
 maintain=function() maintenance=maintenance+1;return false end,progress=function() if mode==4 or mode==6 and maintenance<3 then return nil end return {name='phase'} end,
 fight=function() complete=true end,leave=function() if mode~=5 then inside=false end end,
 turnIn=function() delivered=delivered+1;accepted=false end}
 local ok,result=pcall(DungeonFlow.run,def,{dungeon_wait_seconds=5,dungeon_battle_seconds=30},api)
 assert(entered==0 and stopped>0)
 if mode==1 or mode==6 then assert(ok and result.status=='done' and delivered==1);if mode==6 then assert(maintenance>=3) end
 elseif mode==2 then assert(ok and result.status=='limit_reached' and submitted==0)
 else assert(not ok and delivered==0) end
end
)LUA");file.close();
        QString error;const auto source=prepareResidentScript(root+"/scripts/legacy",entry,{},error);
        must(error.isEmpty(),qPrintable(error));ResidentFake host;resident::Vm vm(host);std::string why;
        must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t now=0;now<200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);now+=20)vm.step(now);
        must(vm.state()==resident::Vm::Completed,vm.error().c_str());
    });
}
}
