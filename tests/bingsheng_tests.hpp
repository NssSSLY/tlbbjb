#pragma once
#include "piaomiao_tests.hpp"
namespace tlbb {
// A small field for the production 兵圣奇阵 entry: objects, prompts and receipts react to what the flow submits.
struct BingshengFake:ResidentFake {
    int used=0,limit=1,stage=1,bossHp=100,frames=0,raidSize=12,emei=2,entries=0,bossAttacks=0,talks=0,mySquad=0,school=4;
    bool inRaid=true,raidLeaderFlag=true,leaderFlag=true,full=false,noEntry=false,noCount=false,noOut=false,wipe=false,stale=false,hard=false;
    bool jufeng=false,water=false,bambooBuff=false,trap=false,lock=false,pile=false,spirit=false,rock=false,bamboo=false,farTeam=false,noLeave=false;
    int created=0;
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;
    BingshengFake(){scene=0;x=306;y=255;}
    void say(const char *line){messages+=line;messages+='\n';}
    void next(const char *prompt){say(prompt);++stage;bossHp=100;
        if(stage==5){if(!noOut)scene=0;if(!noCount)++used;}}
    std::vector<resident::Object> rows(){
        if(scene!=294)return {};
        std::vector<resident::Object> r;
        switch(stage){
        case 1:r.push_back({100,1100,51,57,double(bossHp),bossHp>0,"萧逸风"});
            if(jufeng&&bossHp<100)r.push_back({101,1101,74,55,50,true,"旋风"});break;
        case 2:{const bool north=y<70; // The route this character actually took.
            r.push_back({200,1200,174,north?36.0:100.0,double(bossHp),bossHp>0,north?"萧如筠":"萧如蔚"});
            if(bamboo)r.push_back({201,1201,172,north?38.0:98.0,50,true,north?"同心竹·蓝":"同心竹·红"});break;}
        case 3:r.push_back({300,1300,193,193,double(bossHp),bossHp>0,"耶律焱"});
            if(water&&bossHp<100)r.push_back({301,1301,190,190,100,false,"水迹"});
            if(lock&&bossHp<100)r.push_back({302,1302,x+1,y,50,true,"地府牛妖"});break;
        case 4:r.push_back({400,1400,53,203,double(bossHp),bossHp>0,"耶律连城"});
            if(pile&&bossHp<100)r.push_back({401,1401,55,205,50,true,"石堆"});
            if(spirit&&bossHp<100)r.push_back({402,1402,52,212,50,true,"耶律连城·铁骨"});
            if(rock&&bossHp<100)r.push_back({403,1403,70,y,100,false,"滚石"});break;
        default:break;
        }
        return r;
    }
    int waterFrames=0,lockFrames=0,rockFrames=0;
    std::vector<resident::Object> objects()override{
        ++frames;
        if(water&&x==190&&y==190&&++waterFrames>5)water=false; // 侵略如火 ends once the character has stood on its spot.
        if(lock&&stage==3&&bossHp<100&&++lockFrames>12)lock=false; // The lock on this character runs out.
        if(rock&&stage==4&&bossHp<100&&++rockFrames>8)rock=false; // The rolling stones pass.
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==101){jufeng=false;return;}
        if(id==201){bamboo=false;return;}
        if(id==302){lock=false;return;}
        if(id==401){pile=false;return;}
        if(id==402){spirit=false;return;}
        if(wipe&&stage==3&&bossHp==50){bossHp=100;return;}
        bossHp-=25;
        if(stage==3&&bossHp==75&&water)say("BSQZ_101223_94");
        if(bossHp<=0){if(stage==1)next("BSQZ_101223_163");else if(stage==2)next("BSQZ_101223_167");else if(stage==3)next("BSQZ_101223_171");else next("BSQZ_101223_176");}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==294?"兵圣奇阵":"洛阳"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t;int n=0;
            if(!farTeam)for(int i=0;i<raidSize-1;++i){const double px=jufeng?60:x,py=jufeng?60:y;t+="1\t"+std::to_string(50+i)+"\t"+std::to_string(950+i)+"\t"+std::to_string(px)+"\t"+std::to_string(py)+"\n";++n;}
            if(trap&&stage==2&&bossHp<100){t+="2\t900\t-1\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;trap=false;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids"){
            if(v=="-1:-1"){
                if(jufeng&&stage==1&&bossHp<100)return {Value(1),Value(std::string("5001"))};
                if(bambooBuff&&stage==2&&bossHp<100){bambooBuff=false;return {Value(1),Value(std::string("5002"))};}
                if(lock&&stage==3&&bossHp<100)return {Value(1),Value(std::string("5003"))};
            }
            if(v=="301:1301")return {Value(1),Value(std::string("5004"))};
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos)return {Value(used),Value(limit),Value(0),Value(code.find("local page,want=1")!=std::string::npos?1:0)};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("bingsheng:outer")!=std::string::npos)return {Value(0)};
        if(code.find("bingsheng:create-raid")!=std::string::npos){++created;inRaid=true;return {};}
        if(code.find("dungeon:raid-roster")!=std::string::npos){
            if(!inRaid)return {Value(0),Value(std::string())};
            std::string t;for(int i=0;i<raidSize;++i)t+=std::to_string(i/6)+"\t"+std::to_string(i%6)+"\t"+std::to_string(i<emei?4:0)+"\t0\t1\tm"+std::to_string(i)+"\n";
            return {Value(raidSize),Value(t)};
        }
        if(code.find("dungeon:raid-self")!=std::string::npos)return {Value(mySquad),Value(1)};
        if(code.find("dungeon:raid-leader")!=std::string::npos){if(!raidLeaderFlag&&scene==0)enterAsFollower();return {Value(raidLeaderFlag?1:0)};}
        if(code.find("dungeon:buff-names")!=std::string::npos){
            for(auto [id,text]:std::initializer_list<std::pair<const char*,const char*>>{{"(5001)","聚风：吸引周围"},{"(5002)","迷踪：被追踪"},{"(5003)","目标锁定：携带者勿让地狱牛妖靠近"},{"(5004)","水迹12"}})
                if(code.find(id)!=std::string::npos)return {Value(std::string(text))};
            return {Value(std::string("其他"))};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(leaderFlag?1:0)};
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(-1),Value(123),Value(456)};
        if(code.find("dungeon:dialog")!=std::string::npos){
            const auto opts=page=="closed"?QStringList{}:choices();
            return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    void enterAsFollower(){scene=294;x=58;y=80;}
    QStringList choices()const{
        if(option=="高阳")return {hard?"#{BSQZ_101223_07}":"#{BSQZ_101223_06}"};
        if(option=="陈勇义")return {"#{BSQZ_101223_49}"};
        return {};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";option=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];moves.emplace_back(x,y);return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);if(!choices().contains(label))return {Value(0)};
            if(option=="高阳"){++entries;if(!noEntry){scene=294;x=58;y=80;stage=1;bossHp=100;}}
            else if(option=="陈勇义"){++talks;x=82;y=200;}
            page="closed";return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:
            return {Value(8),Value((stale?std::string("BSQZ_101223_176\nBSQZ_101223_163\n"):std::string())+messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void bingshengTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](BingshengFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","bingsheng");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","bingsheng",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("bingsheng_flow_v1"),"Bingsheng has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Bingsheng still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1500000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"casts",h.casts},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/bingsheng-tests.json");must(progress.open(QIODevice::WriteOnly),"Bingsheng report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](BingshengFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" stage "+std::to_string(h.stage)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText).c_str());
    };
    auto failed=[&](BingshengFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto moved=[](const BingshengFake &h,double x,double y){return std::find(h.moves.begin(),h.moves.end(),std::make_pair(x,y))!=h.moves.end();};
    auto logged=[](const BingshengFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("bingsheng_full_four_stage_counter_and_queue",[&]{
        BingshengFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.used==1&&h.talks==1,"Bingsheng missed or replayed entry / transfer");
        for(int id:{100,200,300,400})must(has(h.attacked,id),("Bingsheng skipped boss "+std::to_string(id)).c_str());
        must(moved(h,147,60),"Squad 0 did not go to 萧如筠");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Bingsheng result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","bingsheng"},{"task","bingsheng"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,4),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Bingsheng receipt did not release next queue item");
    });
    test("bingsheng_modes_squads_and_raid_creation",[&]{
        std::string why;
        {BingshengFake h;h.hard=true;finished(h,{{"bingsheng_mode","困难"}},why);must(h.entries==1,"Hard mode option not used");}
        {BingshengFake h;h.mySquad=1;finished(h,{},why);must(moved(h,140,109),"Squad 1 did not go to 萧如蔚");}
        {BingshengFake h;h.mySquad=1;finished(h,{{"bingsheng_twin","萧如筠"}},why);must(moved(h,147,60),"Explicit twin choice ignored");}
        {BingshengFake h;h.inRaid=false;finished(h,{},why);must(h.created==1,"Leader did not create the raid");}
    });
    test("bingsheng_preconditions_and_no_feedback",[&]{
        std::string why;
        {BingshengFake h;h.used=h.limit;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Daily count not respected");}
        {BingshengFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {BingshengFake h;h.raidSize=6;failed(h,{},why);must(h.entries==0,"Small raid entered");}
        {BingshengFake h;h.emei=1;failed(h,{},why);must(h.entries==0,"Raid with one 峨嵋 entered");}
        {BingshengFake h;h.noEntry=true;failed(h,{},why);must(h.entries==1,"Entry replayed without feedback");}
        {BingshengFake h;h.noCount=true;failed(h,{},why);must(h.receipt.isEmpty(),"Count without increase was completed");}
        {BingshengFake h;h.noOut=true;failed(h,{},why);must(h.receipt.isEmpty(),"Still inside was completed");}
    });
    test("bingsheng_wipe_stops_by_name_and_history_does_not_advance",[&]{
        std::string why;
        {BingshengFake h;h.wipe=true;failed(h,{},why);must(why.find("血量恢复")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
        {BingshengFake h;h.stale=true;finished(h,{},why);must(has(h.attacked,100),"History prompts skipped combat");}
    });
    test("bingsheng_gathers_raid_up_to_90_seconds",[&]{
        std::string why;BingshengFake h;h.farTeam=true;finished(h,{},why);must(logged(h,"等待团员到位")&&has(h.attacked,100),"Gather wait not used, or it never timed out");
    });
    test("bingsheng_mechanisms",[&]{
        std::string why;
        {BingshengFake h;h.jufeng=true;finished(h,{},why);must(logged(h,"聚风远离人群")&&has(h.attacked,101),"聚风 not handled");}
        {BingshengFake h;h.bamboo=true;finished(h,{{"xzk230",true}},why);must(has(h.attacked,201),"同心竹 of this route not attacked");}
        {BingshengFake h;h.bambooBuff=true;finished(h,{},why);must(logged(h,"带竹刺跑圈"),"迷踪 ring not used");}
        {BingshengFake h;h.trap=true;finished(h,{},why);must(logged(h,"躲竹刺"),"竹刺 not dodged");}
        {BingshengFake h;h.water=true;finished(h,{},why);must(logged(h,"侵略如火站水迹")&&moved(h,190,190),"水迹 not used");}
        {BingshengFake h;h.lock=true;finished(h,{},why);must(logged(h,"耶律焱 · 躲避"),"牛妖 lock not dodged");}
        {BingshengFake h;h.pile=true;finished(h,{},why);must(has(h.attacked,401),"石堆 not attacked");}
        {BingshengFake h;h.spirit=true;finished(h,{},why);must(has(h.attacked,402),"铁骨 not attacked");}
        {BingshengFake h;h.rock=true;finished(h,{},why);must(logged(h,"躲滚石"),"滚石 not dodged");}
    });
    test("bingsheng_resume_rounds_and_follower",[&]{
        std::string why;
        {BingshengFake h;h.scene=294;h.stage=3;h.x=196;h.y=160;finished(h,{},why);must(h.entries==0&&!has(h.attacked,100)&&has(h.attacked,300),"Resume replayed earlier bosses");}
        {BingshengFake h;h.leaderFlag=false;h.raidLeaderFlag=false;finished(h,{},why);must(h.entries==0&&h.used==1,"Follower chose the entry");}
    });
    test("bingsheng_config_validation",[&]{
        auto c=combatTestConfig("bingsheng");c.insert("combat_scene",294);c.insert("dungeon_team_count",12);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);c.insert("bingsheng_mode","简单");c.insert("bingsheng_twin","按分队");
        for(const auto key:{"xzk260","xzk230","xzk199","xzk200","xzk201","xzk202","xzk203","xzk204","xzk232","xzk234","bingsheng_loot"})c.insert(key,false);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("dungeon_team_count",6);must(!validateLegacyConfig(bad,e),"Six-player raid accepted");
        bad=c;bad.insert("bingsheng_mode","");must(!validateLegacyConfig(bad,e),"Empty mode accepted");
        bad=c;bad.insert("bingsheng_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
