#pragma once
#include "langhuan_tests.hpp"
namespace tlbb {
// A small field for the production 王陵 entries. Waves: 长右 -> 蛊雕 -> 毕方 -> done prompt.
struct WanglingFake:ResidentFake {
    int used=0,limit=2,wave=1,bossHp=100,frames=0,entries=0,opens[4]{},exits=0,school=4,leaveClicks=0,waitedFrames=0;
    bool started=false,leader=true,full=false,together=true,noEntry=false,noOpen=false,noExit=false,noCount=false,noPrompt=false,stale=false;
    bool food=false,thunder=false,thunderNear=false,fake=false,fakeNpc=false,trap=false,rot=false,yz=false,minion=false;
    std::string alreadyDone,selfName="甲";int minionHp=50,fakeHp=50;
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;int startScene;
    explicit WanglingFake(int s=850){scene=s;startScene=s;x=s==850?289:410;y=s==850?67:380;}
    void say(const char *line){messages+=line;messages+='\n';}
    std::vector<resident::Object> rows(){
        if(scene!=600)return {};
        if(!leader&&!started&&wave<=3)started=true; // Offline teammate opens each wave.
        std::vector<resident::Object> r;r.push_back({900,1900,66,80,100,false,"萧陵"});
        const double hp=double(bossHp);
        switch(wave){
        case 1:if(started)r.push_back({100,1100,48,49,hp,hp>0,"长右"});else r.push_back({100,1100,48,49,100,false,"长右"});
            if(started&&food)r.push_back({101,1101,50,50,50,true,"美味的食物"});
            if(started&&rot)r.push_back({102,1102,51,50,50,true,"腐烂的食物"});
            if(started&&minion)r.push_back({103,1103,47,50,double(minionHp),minionHp>0,"侍魔者"});break;
        case 2:if(started)r.push_back({200,1200,48,49,hp,hp>0,"蛊雕"});else r.push_back({200,1200,48,49,100,false,"蛊雕"});
            if(started&&thunder)r.push_back({201,1201,thunderNear?49.0:70.0,49,50,true,"镇魔天雷"});break;
        case 3:if(started)r.push_back({300,1300,48,49,hp,hp>0,"毕方"});else r.push_back({300,1300,48,49,100,false,"毕方"});
            if(started&&fake){r.push_back({301,1301,40,40,double(fakeHp),true,"毕方幻象"});r.push_back({302,1302,56,56,double(fakeHp),true,"毕方幻象"});}
            if(started&&yz)r.push_back({303,1303,x+1,y,100,true,"英招"});break;
        default:break;
        }
        return r;
    }
    std::vector<resident::Object> objects()override{
        ++frames;
        if(thunder&&wave==2&&started&&!thunderNear&&++waitedFrames>6)thunderNear=true;
        if(yz&&wave==3&&started&&++waitedFrames>10)yz=false;
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==101){food=false;return;}
        if(id==103){minion=false;return;}
        if(id==201){thunder=false;return;}
        if(id==301||id==302){fake=false;return;}
        if(id==303)return;
        bossHp-=50;
        if(wave==3&&bossHp==50&&yz)say("XWLFB_140218_59");
        if(bossHp<=0){++wave;started=false;bossHp=100;if(wave==4&&!noPrompt)say("XWLFB_140218_27");}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==600?"王陵":"凤鸣镇"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=2;
            if(trap&&wave==1&&started&&bossHp<100){t+="2\t900\t-1\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;trap=false;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids")return {Value(0),Value(std::string())};
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos)return {Value(used),Value(limit),Value(0),Value(code.find("local page,want=2")!=std::string::npos?1:0)};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("wangling:name")!=std::string::npos)return {Value(selfName)};
        if(code.find("wangling:dialog-all")!=std::string::npos)return {Value(alreadyDone.empty()?std::string():"#{XWLFB_140218_17}\n"+alreadyDone+"\n#{XWLFB_140218_23}\n")};
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string("42\t903\n43\t904\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==startScene&&used==0){scene=600;x=48;y=60;}return {Value(leader?1:0)};}
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
        if(scene!=600)return {"#{FMZLW_111219_03}"};
        if(option=="萧陵")return {"#{CSFB_KVK_110623_31}","#{WLFB_220726_02}","#{FBCC_201128_11}"};
        return {"#{XWLFB_140218_86}"};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";option=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];moves.emplace_back(x,y);return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(label=="#{FBCC_201128_07")return {Value(0)}; // Not offered in this dialog.
            if(!choices().contains(label))return {Value(0)};
            if(scene!=600){++entries;if(!noEntry&&alreadyDone.empty()){scene=600;x=48;y=60;wave=1;started=false;bossHp=100;}}
            else if(label=="#{FBCC_201128_11}"){++exits;if(!noExit){scene=startScene;if(!noCount)++used;}}
            else if(option!="萧陵"){++opens[qBound(0,wave,3)];if(!noOpen)started=true;}
            if(option!="萧陵")page="closed";
            return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:
            return {Value(8),Value((stale?std::string("XWLFB_140218_27\n"):std::string())+messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void wanglingTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](WanglingFake &h,QJsonObject cfg,std::string &why,const QString &id="wangling"){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("wangling_flow_v1"),"Wangling has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Wangling still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"task",id},{"error",QString::fromStdString(why)},{"entries",h.entries},{"exits",h.exits},{"casts",h.casts},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/wangling-tests.json");must(progress.open(QIODevice::WriteOnly),"Wangling report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](WanglingFake &h,QJsonObject cfg,std::string &why,const QString &id="wangling"){
        const auto state=run(h,cfg,why,id);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" wave "+std::to_string(h.wave)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](WanglingFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto moved=[](const WanglingFake &h,double x,double y){return std::find(h.moves.begin(),h.moves.end(),std::make_pair(x,y))!=h.moves.end();};
    auto logged=[](const WanglingFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("wangling_full_waves_exit_counter_and_queue",[&]{
        WanglingFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.exits==1&&h.used==1,"Wangling missed or replayed entry / exit");
        for(int s=1;s<=3;++s)must(h.opens[s]==1,"Wangling wave opened other than once");
        for(int id:{100,200,300})must(has(h.attacked,id),("Wangling skipped boss "+std::to_string(id)).c_str());
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Wangling result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","wangling"},{"task","wangling"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,4),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Wangling receipt did not release next queue item");
    });
    test("wangling_bianjing_entrance_uses_its_own_npc_and_line",[&]{
        std::string why;WanglingFake h(775);finished(h,{},why,"dungeon_002fd8cc");
        must(h.entries==1&&h.used==1&&h.logText.find("汴京王陵")!=std::string::npos,"汴京 entrance did not finish");
        WanglingFake other(0);other.x=100;other.y=100;finished(other,{},why,"dungeon_002fd8cc");must(moved(other,410,380),"汴京 entrance was not routed to its NPC");
    });
    test("wangling_member_done_today_names_them_and_never_kicks",[&]{
        std::string why;
        {WanglingFake h;h.alreadyDone="乙";failed(h,{},why);must(why.find("乙")!=std::string::npos&&why.find("不自动踢人")!=std::string::npos,why.c_str());must(h.logText.find("KickTeam")==std::string::npos,"Member was kicked");}
        {WanglingFake h;h.alreadyDone="甲";finished(h,{},why);must(h.receipt.contains("already_done"),"Own completion was not already_done");}
    });
    test("wangling_limits_preconditions_and_no_feedback",[&]{
        std::string why;
        {WanglingFake h;h.used=h.limit;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Daily count not respected");}
        {WanglingFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {WanglingFake h;h.together=false;failed(h,{},why);must(h.entries==0,"Scattered team entered");}
        {WanglingFake h;h.noEntry=true;failed(h,{},why);must(h.entries>=1&&h.entries<=6,"Entry retried beyond the team patience");}
        {WanglingFake h;h.noOpen=true;failed(h,{},why);must(h.opens[1]==1&&h.receipt.isEmpty(),"Wave opening replayed or completed");}
        {WanglingFake h;h.noExit=true;failed(h,{},why);must(h.exits<=3&&h.receipt.isEmpty(),"Exit without leaving was completed");}
        {WanglingFake h;h.noCount=true;failed(h,{},why);must(h.exits==1&&h.receipt.isEmpty(),"Count without increase was completed");}
        {WanglingFake h;h.noPrompt=true;failed(h,{},why);must(h.exits==0&&h.receipt.isEmpty(),"No done prompt still left the dungeon");}
        {WanglingFake h;h.stale=true;finished(h,{},why);must(h.opens[1]==1&&has(h.attacked,100),"History prompt ended the run early");}
    });
    test("wangling_mechanisms",[&]{
        std::string why;
        {WanglingFake h;h.food=true;h.rot=true;finished(h,{},why);must(has(h.attacked,101)&&!has(h.attacked,102),"Food targets wrong");}
        {WanglingFake h;h.minion=true;finished(h,{},why);must(has(h.attacked,103),"侍魔者 not attacked");}
        {WanglingFake h;h.thunder=true;finished(h,{},why);must(logged(h,"等镇魔天雷靠近")&&has(h.attacked,201),"镇魔天雷 not timed to 蛊雕");}
        {WanglingFake h;h.fake=true;finished(h,{},why);must(has(h.attacked,301)||has(h.attacked,302),"幻象 not attacked");}
        {WanglingFake h;h.trap=true;finished(h,{},why);must(logged(h,"躲陷阱"),"Trap not dodged");}
        {WanglingFake h;h.yz=true;finished(h,{},why);must(logged(h,"躲英招"),"英招 not dodged");}
    });
    test("wangling_resume_rounds_and_follower",[&]{
        std::string why;
        {WanglingFake h;h.scene=600;h.wave=2;h.x=48;h.y=60;finished(h,{},why);must(h.entries==0&&h.opens[1]==0&&h.exits==1,"Resume replayed the start");}
        {WanglingFake h;h.limit=3;finished(h,{{"dungeon_rounds",2}},why);must(h.used==2&&h.entries==2&&h.exits==2,"Second round did not run");}
        {WanglingFake h;h.leader=false;finished(h,{},why);must(h.entries==0&&h.exits==1&&h.used==1,"Follower chose the entry or did not leave");for(int e=1;e<=3;++e)must(h.opens[e]==0,"Follower opened a wave");}
    });
    test("wangling_config_validation",[&]{
        for(const auto &id:QStringList{"wangling","dungeon_002fd8cc"}){
            auto c=combatTestConfig(id);c.insert("combat_scene",600);c.insert("dungeon_team_count",6);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3000);c.insert(QString::fromUtf8("小号模式"),false);c.insert("wangling_loot",true);QString e;
            must(validateLegacyConfig(c,e),qPrintable(e));
            auto bad=c;bad.insert("wangling_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
            bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
        }
    });
}
}
