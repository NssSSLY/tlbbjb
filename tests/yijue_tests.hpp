#pragma once
#include "fenghuang_tests.hpp"
namespace tlbb {
// A small field for the production 弈决山河 entry: town, rest room, battleground with enemy players.
struct YijueFake:ResidentFake {
    int used=0,limit=1,level=120,team=0,entries=0,leaves=0,claims=0,ghosts=0,casts_=0,enemyHp=100,restFrames=0,selfHp=1000,dieAfter=0,school=0,noEnemyFrames=0;
    bool useRest=true,noEntry=false,noOption=false,noCount=false,inFight=false,enemyFar=true,stuck=false;
    QString page="closed",npcName,receipt;
    YijueFake(){scene=0;x=316;y=225;}
    const char *map()const{return scene==501?"弈决山河":scene==500?"战斗休息室":scene==0?"洛阳":scene==1?"苏州":"大理";}
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position"){
            if(scene==500&&++restFrames>10){scene=501;x=200;y=93;}
            if(scene==501&&enemyHp<=0&&!stuck&&++noEnemyFrames>=3){scene=0;x=316;y=225;if(!noCount)++used;enemyHp=100;noEnemyFrames=0;}
            return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(map()))};
        }
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="mechanism_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="enemy_players"){
            if(scene!=501||enemyHp<=0)return {Value(scene),Value(0),Value(std::string())};
            const double ex=enemyFar?240:x+1;
            return {Value(scene),Value(1),Value("77\t977\t"+std::to_string(ex)+"\t93\t"+std::to_string(enemyHp)+"\n")};
        }
        if(op=="object_buff_ids")return {Value(0),Value(std::string())};
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos)return {Value(used),Value(limit),Value(0),Value(1)};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("yijue:level")!=std::string::npos)return {Value(level)};
        if(code.find("yijue:hp")!=std::string::npos){noEnemyFrames=0;return {Value(selfHp)};}
        if(code.find("pvp:cast")!=std::string::npos){
            ++casts_;enemyHp-=50;
            if(dieAfter>0&&casts_==dieAfter)selfHp=0;
            return {Value(1)};
        }
        if(code.find("yijue:ui")!=std::string::npos){
            if(code.find("LeaveTeam")!=std::string::npos){++leaves;team=0;}
            if(code.find("Out_Ghost")!=std::string::npos){++ghosts;selfHp=1000;}
            return {};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(-1),Value(123),Value(456)};
        return ResidentFake::evaluate(code,f,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::TeamCount:return {Value(team)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";npcName=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(label=="#{WWSJ_230213_22"){
                if(noOption)return {Value(0)};
                ++entries;if(!noEntry){scene=useRest?500:501;x=200;y=93;restFrames=0;}
                return {Value(1),Value(label.toStdString())};
            }
            if(label=="#{WWSJ_230213_28}"){++claims;return {Value(1),Value(label.toStdString())};}
            return {Value(0)};
        }
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void yijueTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](YijueFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","dungeon_0033352d");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","dungeon_0033352d",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("yijue_flow_v1"),"Yijue has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Yijue still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1500000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"casts",h.casts_},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/yijue-tests.json");must(progress.open(QIODevice::WriteOnly),"Yijue report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](YijueFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](YijueFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto logged=[](const YijueFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("yijue_queue_fight_count_claim_and_queue",[&]{
        YijueFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.casts_>=2&&h.used==1&&h.claims==1&&h.leaves==0,"Yijue skipped a stage");
        must(logged(h,"追击敌人"),"Far enemy not chased");
        must(h.npcName==QString::fromUtf8("李斯庭"),"Wrong level NPC");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Yijue result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","yijue"},{"task","dungeon_0033352d"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,6),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Yijue receipt did not release next queue item");
    });
    test("yijue_level_team_and_limits",[&]{
        std::string why;
        {YijueFake h;h.level=59;failed(h,{},why);must(why.find("等级")!=std::string::npos&&h.entries==0,why.c_str());}
        {YijueFake h;h.level=75;h.scene=2;h.x=195;h.y=98;finished(h,{},why);must(h.npcName==QString::fromUtf8("康思乐"),"Level 75 NPC");}
        {YijueFake h;h.level=95;h.scene=1;h.x=289;h.y=221;finished(h,{},why);must(h.npcName==QString::fromUtf8("石朝华"),"Level 95 NPC");}
        {YijueFake h;h.used=1;finished(h,{},why);must(h.entries==0&&h.claims==1&&h.receipt.contains("already_done"),"Daily limit not respected");}
        {YijueFake h;h.used=1;finished(h,{{"yijue_claim",false}},why);must(h.claims==0,"Claim setting ignored");}
        {YijueFake h;h.team=3;failed(h,{},why);must(why.find("允许自动退队")!=std::string::npos&&h.leaves==0&&h.entries==0,why.c_str());}
        {YijueFake h;h.team=3;finished(h,{{"yijue_leave_team",true}},why);must(h.leaves==1&&h.entries==1,"Leave switch ignored");}
    });
    test("yijue_no_feedback_stops",[&]{
        std::string why;
        {YijueFake h;h.noOption=true;failed(h,{},why);must(why.find("活动可能未开放")!=std::string::npos,why.c_str());}
        {YijueFake h;h.noEntry=true;failed(h,{},why);must(h.entries==1&&why.find("未重复报名")!=std::string::npos,why.c_str());}
        {YijueFake h;h.noCount=true;failed(h,{},why);must(why.find("活动次数")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
        {YijueFake h;h.stuck=true;failed(h,{{"dungeon_battle_seconds",30}},why);must(why.find("超过时限")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
    });
    test("yijue_death_rest_and_resume",[&]{
        std::string why;
        {YijueFake h;h.enemyFar=false;h.dieAfter=1;finished(h,{},why);must(h.ghosts>=1&&h.used==1,"Death not handled through the relive panel");}
        {YijueFake h;h.useRest=false;finished(h,{},why);must(h.entries==1,"Direct entry");}
        {YijueFake h;h.scene=501;h.x=200;h.y=93;h.noCount=true;finished(h,{{"dungeon_rounds",1}},why);must(h.entries==0&&h.casts_>=2,"Resume re-entered");}
    });
    test("yijue_config_validation",[&]{
        auto c=combatTestConfig("dungeon_0033352d");c.insert("combat_scene",3);c.insert("dungeon_rounds",20);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);c.insert("yijue_leave_team",false);c.insert("yijue_claim",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("dungeon_rounds",0);must(!validateLegacyConfig(bad,e),"Round 0 accepted");
        bad=c;bad.insert("yijue_claim","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
