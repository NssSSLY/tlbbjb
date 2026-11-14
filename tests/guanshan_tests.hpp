#pragma once
#include "sanshen_tests.hpp"
namespace tlbb {
// A small field for the production 观山海 entry. Each layer: NPC guardian -> talk and open -> fight -> next-layer dialog.
struct GuanshanFake:ResidentFake {
    QStringList layers{"燕驰野","无执"};int index=0,layer=5,bossHp=100,frames=0,week=20,entries=0,opens=0,ups=0,leaves=0,claims=0,school=4,mech=0;
    bool started=false,beaten=false,leader=true,full=false,together=true,noEntry=false,noOpen=false,noLeave=false,noCount=false,failed=false,memberConfirmed=false;
    bool add=false,trap=false,cone=false,jar=false,spikes=false,web=false,rage=false,hasSkill=true,thdPair=false,poolFar=false;int leaveAt=0;
    int useSkillCalls=0,fishCalls=0,uiEntered=0;
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;QStringList uiWindows;
    enum Win{None,Peak,Stage} win=None;
    GuanshanFake(){scene=2;x=210;y=51;}
    void say(const char *line){messages+=line;messages+='\n';}
    QString guardian()const{return index<layers.size()?layers[index]:QString();}
    std::vector<resident::Object> rows(){
        if(scene!=749)return {};
        if(!leader&&beaten){beaten=false;layer+=1;} // Offline leader confirms the next layer.
        if(!leader&&!started&&!beaten&&index<layers.size())started=true; // Offline teammate opens each layer.
        std::vector<resident::Object> r;
        // The last guardian stays as an NPC offering the next layer or the way out.
        if(index>=layers.size()){if(index==layers.size())r.push_back({99+index,1099+index,70,70,100,false,layers.last().toStdString()});return r;}
        const auto g=guardian().toStdString();
        if(!started)r.push_back({100+index,1100+index,70,70,100,false,g});
        else{
            r.push_back({100+index,1100+index,70,70,double(bossHp),true,g});
            if(add&&bossHp<100)r.push_back({150,1150,72,70,50,true,"魁元弟子"});
            if(cone&&bossHp<100&&mech<10)r.push_back({151,1151,75,70,100,false,"空npc"});
            if(jar&&bossHp<100&&mech<10)r.push_back({152,1152,72,72,100,false,"酒坛"});
            if(spikes&&bossHp<100)r.push_back({153,1153,71,71,50,true,"铁蒺藜"});
            if(web&&bossHp<100&&mech<10)r.push_back({154,1154,x+1,y,100,true,"地面蜘蛛网"});
            if(rage&&bossHp<100&&mech<10)r.push_back({155,1155,68,70,100,false,"红木木鱼"});
            if(thdPair)r.push_back({160,1160,76,70,double(bossHp),true,"离人偶"});
        }
        return r;
    }
    std::vector<resident::Object> objects()override{
        ++frames;
        if(started&&bossHp<100&&(cone||jar||web||rage)&&++mech>=10){cone=jar=web=rage=false;}
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==150){add=false;return;}
        if(id==153){spikes=false;return;}
        bossHp-=50;
        if(bossHp==50&&cone)say("BSJN_200327_18");
        if(bossHp<=0){started=false;beaten=true;bossHp=100;++index;mech=0;}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==749?"观山海":"大理"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=2;
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids"){
            if(v=="-1:-1"&&jar&&bossHp<100)return {Value(1),Value(std::string("6001"))};
            if(rage&&v.rfind(std::to_string(100+index)+":",0)==0&&bossHp<100)return {Value(1),Value(std::string("6002"))};
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:team-hp")!=std::string::npos)return {Value(1)};
        if(code.find("shaoshi:emei-members")!=std::string::npos)return {Value(std::string())};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("guanshan:name")!=std::string::npos)return {Value(std::string("甲"))};
        if(code.find("guanshan:lowest")!=std::string::npos)return {Value(1)};
        if(code.find("guanshan:mp")!=std::string::npos)return {Value(9000),Value(100)};
        if(code.find("guanshan:yinyang")!=std::string::npos)return {Value(0)};
        if(code.find("guanshan:confirm2")!=std::string::npos)return {};
        if(code.find("guanshan:layer")!=std::string::npos)return {Value(layer)};
        if(code.find("guanshan:shown")!=std::string::npos)return {Value(code.find("WuLin_Up_Env")!=std::string::npos&&page=="up"?1:0)};
        if(code.find("guanshan:week")!=std::string::npos)return {Value(win==Peak?"本周剩余挑战次数："+std::to_string(week)+"/20":std::string())};
        if(code.find("guanshan:choose")!=std::string::npos)return {Value(win==Stage?(leader?1:3):-1)};
        if(code.find("guanshan:range")!=std::string::npos)return {Value(1),Value(10)};
        if(code.find("guanshan:up-range")!=std::string::npos)return {Value(layer+1),Value(layer+5)};
        if(code.find("guanshan:interact")!=std::string::npos){if(!hasSkill)return {Value(-1)};if(code.find("3922")!=std::string::npos)++useSkillCalls;if(code.find("3943")!=std::string::npos)++fishCalls;mech=99;jar=rage=false;return {Value(1)};}
        if(code.find("guanshan:ui")!=std::string::npos){
            uiWindows.append(QString::fromStdString(code));
            if(code.find("WuLin_Peak_EnterScene")!=std::string::npos&&win==Peak){++uiEntered;win=Stage;}
            if(code.find("WuLin_Leader_OnChooseStageConfirm")!=std::string::npos||code.find("WuLin_Member_OnChooseStageConfirm")!=std::string::npos){++entries;if(!noEntry){scene=749;x=70;y=60;win=None;--week;index=0;started=false;beaten=false;bossHp=100;}}
            if(code.find("LeaderUpgradeConfirm")!=std::string::npos){++ups;layer+=1;beaten=false;page="closed";}
            return {};
        }
        if(code.find("guanshan:dialog-all")!=std::string::npos){
            if(page=="closed"||scene!=749)return {Value(std::string())};
            if(failed)return {Value(std::string("#{PTFB_191228_218}\n"))};
            if(index>=layers.size()||beaten)return {Value(std::string("#{PTFB_191228_217}\n#{PTFB_191228_73}\n"))};
            return {Value(std::string("#{PTFB_191228_77}开启\n"))};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string(leader?"42\t903\n43\t904\n44\t905\n":"43\t904\n42\t903\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==2&&entries==0&&!noEntry){win=Stage;}return {Value(leader?1:0)};}
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(6001)")!=std::string::npos)return {Value(std::string("追击目标：被解谊持续追击"))};
            if(code.find("(6002)")!=std::string::npos)return {Value(std::string("狂慧：伤害加成 200%"))};
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
        if(scene==2)return {"#{PTFB_191228_02}","#{PTFB_191228_04}","#{PTFB_191228_241}","#{PTFB_191228_259}","#{PTFB_191228_467}"};
        return {"#{PTFB_191228_217}","#{PTFB_191228_73}","#{PTFB_191228_218}","#{PTFB_191228_477}","#{PTFB_191228_36}"};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:if(page!="up")page="closed";if(scene==2&&win==Peak&&entries>0)win=None;return {Value(1)};
        case gameplay::NpcTarget:page="menu";option=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];moves.emplace_back(x,y);return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(label=="#{PTFB_191228_77"){++opens;if(!noOpen)started=true;page="closed";return {Value(1),Value(label.toStdString())};}
            if(!choices().contains(label))return {Value(0)};
            if(label=="#{PTFB_191228_02}"){if(entries==0||!noCount)win=Peak;else win=Peak;if(entries>0&&noCount)++week;}
            else if(label=="#{PTFB_191228_217}"){page="up";return {Value(1),Value(label.toStdString())};}
            else if(label=="#{PTFB_191228_477}"){++leaves;if(!noLeave){scene=2;x=210;y=51;index=layers.size()+1;}}
            else if(label=="#{PTFB_191228_467}"){++claims;}
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
template<class Test>void guanshanTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](GuanshanFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","guanshan");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","guanshan",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("guanshan_flow_v1"),"Guanshan has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Guanshan still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"opens",h.opens},{"leaves",h.leaves},{"casts",h.casts},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/guanshan-tests.json");must(progress.open(QIODevice::WriteOnly),"Guanshan report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](GuanshanFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" index "+std::to_string(h.index)+" layer "+std::to_string(h.layer)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](GuanshanFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto logged=[](const GuanshanFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    const QJsonObject leaveAtSix{{"guanshan_leave_layer",7}};
    test("guanshan_full_layers_leave_claim_and_queue",[&]{
        GuanshanFake h;std::string why;finished(h,leaveAtSix,why);
        must(h.entries==1&&h.uiEntered==1,"Guanshan missed or replayed the entry windows");
        must(h.opens==2&&has(h.attacked,100)&&has(h.attacked,101),"Guanshan did not open and fight each layer");
        must(h.ups>=1&&h.leaves>=1&&h.scene==2&&h.claims>=1,"Guanshan did not advance, leave and claim");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Guanshan result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","guanshan"},{"task","guanshan"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,5),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Guanshan receipt did not release next queue item");
    });
    test("guanshan_week_limit_preconditions_and_no_feedback",[&]{
        std::string why;
        {GuanshanFake h;h.week=0;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Weekly limit not respected");}
        {GuanshanFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {GuanshanFake h;h.together=false;failed(h,{},why);must(h.entries==0,"Scattered team entered");}
        {GuanshanFake h;h.noEntry=true;failed(h,{},why);must(h.entries>=1&&h.entries<=6,"Entry retried beyond the team patience");}
        {GuanshanFake h;h.noOpen=true;failed(h,{},why);must(h.opens==1&&h.receipt.isEmpty(),"Open replayed or completed without a fight");}
        {GuanshanFake h;h.noLeave=true;failed(h,leaveAtSix,why);must(h.leaves==1&&h.receipt.isEmpty(),"Leave replayed or completed without leaving");}
        {GuanshanFake h;h.noCount=true;failed(h,leaveAtSix,why);must(why.find("剩余次数")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
    });
    test("guanshan_failure_dialog_leaves_and_skip_boss",[&]{
        std::string why;
        {GuanshanFake h;h.failed=true;finished(h,{},why);must(logged(h,"挑战失败")&&h.scene==2,"Failure dialog did not leave");}
        {GuanshanFake h;finished(h,{{"guanshan_skip_boss",QString::fromUtf8("燕驰野")}},why);must(logged(h,"不打 燕驰野")&&!has(h.attacked,100),"Skip setting ignored");}
    });
    test("guanshan_stage_choice_and_reward_check",[&]{
        std::string why;
        {GuanshanFake h;finished(h,{{"guanshan_stage",QString::fromUtf8("最高")},{"guanshan_leave_layer",7}},why);must(logged(h,"挑战第 10 层"),"Highest layer not chosen");}
        {GuanshanFake h;finished(h,{{"guanshan_stage",QString::fromUtf8("整五")},{"guanshan_leave_layer",7}},why);must(logged(h,"挑战第 5 层"),"Multiple of five not chosen");}
        {GuanshanFake h;finished(h,{{"guanshan_reward_check",true},{"guanshan_leave_layer",7}},why);must(h.uiWindows.join("").contains("WeekAwardActive"),"Reward check not sent");}
        {GuanshanFake h;finished(h,leaveAtSix,why);must(!h.uiWindows.join("").contains("WeekAwardActive")&&h.uiWindows.join("").contains("WeekAwardCancelActive"),"Reward check should be cleared");}
    });
    test("guanshan_mechanisms",[&]{
        std::string why;
        auto layer=[&](const QString &boss){GuanshanFake h;h.layers={boss};return h;};
        {auto h=layer("唐简");h.cone=true;finished(h,leaveAtSix,why);must(logged(h,"躲星河流倾"),"Cone not dodged");}
        {auto h=layer("唐简");h.spikes=true;finished(h,leaveAtSix,why);must(has(h.attacked,153),"铁蒺藜 not attacked");}
        {auto h=layer("唐简");h.spikes=true;finished(h,{{"guanshan_no_tjl",true},{"guanshan_leave_layer",7}},why);must(!has(h.attacked,153),"铁蒺藜 setting ignored");}
        {auto h=layer("解谊");h.jar=true;finished(h,leaveAtSix,why);must(logged(h,"拼酒")&&h.useSkillCalls>=1,"拼酒 not used");}
        {auto h=layer("解谊");h.jar=true;h.hasSkill=false;finished(h,leaveAtSix,why);must(logged(h,"机制技能 3922"),"Missing mechanism skill not named");}
        {auto h=layer("夜来");h.web=true;finished(h,leaveAtSix,why);must(logged(h,"躲蛛网"),"蛛网 not dodged");}
        {auto h=layer("无执");h.rage=true;finished(h,leaveAtSix,why);must(logged(h,"敲木鱼")&&h.fishCalls>=1,"木鱼 not used");}
        {auto h=layer("无执");h.rage=true;finished(h,{{"guanshan_muyu",QString::fromUtf8("不敲")},{"guanshan_leave_layer",7}},why);must(h.fishCalls==0,"木鱼 setting ignored");}
        {GuanshanFake h;h.add=true;finished(h,leaveAtSix,why);must(has(h.attacked,150)&&std::find(h.attacked.begin(),h.attacked.end(),150)<h.attacked.end(),"Disciple not attacked");}
        {auto h=layer("朝覆雨");h.thdPair=true;finished(h,leaveAtSix,why);must(has(h.attacked,100),"桃花岛 pair not attacked");}
    });
    test("guanshan_resume_rounds_and_follower",[&]{
        std::string why;
        {GuanshanFake h;h.scene=749;h.x=70;h.y=70;h.index=1;finished(h,leaveAtSix,why);must(h.entries==0&&!has(h.attacked,100)&&has(h.attacked,101),"Resume replayed an earlier layer");}
        {GuanshanFake h;h.leader=false;finished(h,leaveAtSix,why);must(h.opens==0&&h.ups==0,"Follower opened or advanced a layer");}
    });
    test("guanshan_config_validation",[&]{
        auto c=combatTestConfig("guanshan");c.insert("combat_scene",749);c.insert("dungeon_team_count",6);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);
        c.insert("guanshan_stage",QString::fromUtf8("最低"));c.insert("guanshan_muyu",QString::fromUtf8("血最低"));c.insert("guanshan_leave_layer",100);for(const auto key:{"guanshan_no_tjl","guanshan_xy_stay","guanshan_melee_boss","guanshan_reward_check","guanshan_claim"})c.insert(key,false);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("guanshan_stage","");must(!validateLegacyConfig(bad,e),"Empty stage accepted");
        bad=c;bad.insert("guanshan_leave_layer",0);must(!validateLegacyConfig(bad,e),"Layer 0 accepted");
        bad=c;bad.insert("guanshan_claim","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
