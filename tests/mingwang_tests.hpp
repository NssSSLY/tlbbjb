#pragma once
#include "yezhu_tests.hpp"
namespace tlbb {
// A small field for the production 剑破明王境 entry: seven trials in one scene.
struct MingwangFake:ResidentFake {
    QStringList npcs{"田晓宇","刘昌浩","董思","赵博","李欣泽","叶秋霜","彭靖"};
    QStringList bosses{"慕容复·影","大轮寺梵僧","裂海魔龙·影","","李秋水·影","","燕驰野·影"};
    int step=0,hp=100,entries=0,starts=0,skillAssigns=0,gates=0,relicsTaken=0,lampsLit=0,kickAfter=4,dazao=0;
    enum Stage{Npc,Fight,Relic,Lamp,Clear} stage=Npc;
    bool needClaim=false,claimed=false,noStart=false,noEntry=false,wipe=false,full=false,together=true,leader=true,askSkill=true,stay=false,dragon=false,lotus=false,dzxy=false,dead7=false;
    int noMoveKick=0,dzxyLeft=20;QString page="closed",npcName,receipt;std::vector<int> attacked;std::string messages;
    MingwangFake(){scene=0;x=355;y=221;}
    std::vector<resident::Object> rows(){
        std::vector<resident::Object> r;
        if(scene!=934)return r;
        if(step>=7){if(dead7)r.push_back({300,1300,244,61,0,true,bosses[6].toStdString()});return r;}
        const std::array<std::array<double,2>,7> pos{{{81,250},{127,224},{60,124},{72,50},{158,121},{256,173},{244,61}}};
        const auto q=pos[step];
        const bool close=(x-q[0])*(x-q[0])+(y-q[1])*(y-q[1])<400;
        if(stage==Npc&&close)r.push_back({100+step,1100+step,q[0],q[1],100,false,npcs[step].toStdString()});
        if(stage==Fight)r.push_back({300+step,1300+step,q[0],q[1],double(hp),true,bosses[step].toStdString()});
        if(stage==Relic){if(lotus)r.push_back({203,1203,q[0]+2,q[1],100,false,"雪莲"});else r.push_back({200,1200,q[0]+2,q[1],100,false,"锡杖"});}
        if(stage==Lamp)r.push_back({210,1210,q[0]+2,q[1],100,false,"莲花灯"});
        return r;
    }
    std::vector<resident::Object> objects()override{
        if(stage==Relic&&lotus&&step==3&&x==74&&y==50){lotus=false;advance();}
        return rows();
    }
    void advance(){stage=Npc;hp=100;++step;if(step>=7){dead7=true;}}
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(step<7&&stage==Fight&&id==300+step){hp-=50;if(hp<=0){if(wipe){stage=Npc;hp=100;}else if(step==6){dead7=true;step=7;}else advance();}}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position"){
            if(scene==934&&step>=7&&!stay&&++noMoveKick>kickAfter*30){scene=0;x=355;y=221;}
            return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==934?"明王境":"洛阳"))};
        }
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";return {Value(scene),Value(2),Value(t)};}
        if(op=="object_buff_ids"){
            if(dzxy&&v.rfind("300:",0)==0&&hp<100&&dzxyLeft-->0)return {Value(1),Value(std::string("6010"))};
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(0)};
        if(code.find("shaoshi:team-hp")!=std::string::npos)return {Value(1)};
        if(code.find("shaoshi:emei-members")!=std::string::npos)return {Value(std::string())};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("mingwang:name")!=std::string::npos)return {Value(std::string("甲"))};
        if(code.find("mingwang:dazao")!=std::string::npos)return {Value(step==2?1:0)};
        if(code.find("mingwang:interact")!=std::string::npos){if(code.find("4976")!=std::string::npos){++lampsLit;advance();}return {Value(1)};}
        if(code.find("mingwang:ui")!=std::string::npos){
            if(code.find("RouGe_Skill_OkClicked")!=std::string::npos){++skillAssigns;askSkill=false;}
            if(code.find("BossChoiceConfirm")!=std::string::npos)++dazao;
            return {};
        }
        if(code.find("mingwang:dialog-all")!=std::string::npos){
            if(page=="closed")return {Value(std::string())};
            std::string t;if(scene==934&&askSkill&&step==0)t="#{RGPT_231130_97}\n";return {Value(t+"开始挑战\n")};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string(leader?"42\t903\n43\t904\n44\t905\n":"43\t904\n42\t903\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(leader?1:0)};
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(6010)")!=std::string::npos)return {Value(std::string("斗转星移"))};
            return {Value(std::string("其他"))};
        }
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(-1),Value(123),Value(456)};
        if(code.find("dungeon:dialog")!=std::string::npos){
            const auto opts=page=="closed"?QStringList{}:choices();
            return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    QStringList choices()const{
        if(scene==0)return {"#{RGPT_231130_02}","#{RGPT_231130_03}","#{RGPT_231130_71}"};
        if(npcName==QString::fromUtf8("雪雕"))return {"#{RGPT_231130_639}","#{RGPT_231130_642}"};
        if(npcName==QString::fromUtf8("幻境深处"))return {"#{RGPT_231130_116}"};
        if(npcName==QString::fromUtf8("锡杖"))return {"#{RGPT_231130_297}"};
        return {QString::fromUtf8("技能分配"),QString::fromUtf8("开始挑战")};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";npcName=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::QuestButton:
            if(scene==0&&page!="closed"&&(!needClaim||claimed)){++entries;if(!noEntry){scene=934;x=81;y=250;step=0;stage=Npc;}}
            else if(scene==0)++entries;
            return {Value(0)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(!choices().contains(label))return {Value(0)};
            if(label=="#{RGPT_231130_71}")claimed=true;
            if(label==QString::fromUtf8("开始挑战")){++starts;if(!noStart){if(step==3)stage=Relic;else if(step==5)stage=Lamp;else stage=Fight;}}
            if(label=="#{RGPT_231130_639}"){++gates;x=60;y=124;}
            if(label=="#{RGPT_231130_642}"){++gates;x=158;y=121;}
            if(label=="#{RGPT_231130_116}"){++gates;x=244;y=61;}
            if(label=="#{RGPT_231130_297}"){++relicsTaken;advance();}
            return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:return {Value(8),Value(messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void mingwangTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](MingwangFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","dungeon_002cfcf9");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","dungeon_002cfcf9",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("mingwang_flow_v1"),"Mingwang has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Mingwang still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=2400000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"starts",h.starts},{"casts",h.casts},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/mingwang-tests.json");must(progress.open(QIODevice::WriteOnly),"Mingwang report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](MingwangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" step "+std::to_string(h.step)+" stage "+std::to_string(int(h.stage))+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1800)).c_str());
    };
    auto failed=[&](MingwangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto logged=[](const MingwangFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("mingwang_seven_trials_and_queue",[&]{
        MingwangFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.starts==7&&h.skillAssigns==1&&h.dazao==1,"Mingwang skipped a trial start");
        must(has(h.attacked,300)&&has(h.attacked,301)&&has(h.attacked,302)&&has(h.attacked,304)&&has(h.attacked,306),"Mingwang skipped a boss");
        must(h.relicsTaken==1&&h.lampsLit==1&&h.gates==3&&h.scene==0,"Mingwang skipped relics, lamps or gates");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Mingwang result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","mingwang"},{"task","dungeon_002cfcf9"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,5),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Mingwang receipt did not release next queue item");
    });
    test("mingwang_entry_claim_and_stops",[&]{
        std::string why;
        {MingwangFake h;h.needClaim=true;finished(h,{},why);must(h.claimed&&logged(h,"领取入场资格"),"Entry claim not used");}
        {MingwangFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {MingwangFake h;h.together=false;failed(h,{},why);must(h.entries==0,"Scattered team entered");}
        {MingwangFake h;h.noEntry=true;failed(h,{},why);must(h.entries>=2&&h.entries<=8&&h.receipt.isEmpty(),"Entry retried beyond the team patience");}
        {MingwangFake h;h.noStart=true;failed(h,{},why);must(h.starts==1&&h.receipt.isEmpty(),"Trial start replayed");}
        {MingwangFake h;h.wipe=true;failed(h,{},why);must(why.find("重新出现")!=std::string::npos,why.c_str());}
    });
    test("mingwang_stays_inside_and_resume",[&]{
        std::string why;
        {MingwangFake h;h.stay=true;finished(h,{{"dungeon_rounds",3}},why);must(h.receipt.contains(QString::fromUtf8("仍在副本内"))&&h.entries==1,"Stayed result not stated");}
        {MingwangFake h;h.scene=934;h.x=158;h.y=121;h.step=4;finished(h,{},why);must(h.entries==0&&!has(h.attacked,300)&&has(h.attacked,304),"Resume replayed an earlier trial");}
        {MingwangFake h;h.leader=false;h.scene=934;h.x=81;h.y=250;h.noStart=true;failed(h,{},why);must(h.starts==0,"Follower started a trial");}
    });
    test("mingwang_mechanisms",[&]{
        std::string why;
        {MingwangFake h;h.dzxy=true;finished(h,{},why);must(logged(h,"斗转星移，停手"),"斗转星移 not respected");}
    });
    test("mingwang_config_validation",[&]{
        auto c=combatTestConfig("dungeon_002cfcf9");c.insert("combat_scene",934);c.insert("dungeon_team_count",3);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("dungeon_team_count",1);must(!validateLegacyConfig(bad,e),"Team 1 accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
