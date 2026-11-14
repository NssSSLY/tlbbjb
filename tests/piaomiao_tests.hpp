#pragma once
#include "shaoshi_tests.hpp"
namespace tlbb {
// A small field for the production 缥缈峰 entry: objects, prompts and receipts react to what the flow submits.
struct PiaomiaoFake:ResidentFake {
    int mode=0,used=0,limit=2,stage=1,bossHp=100,buHp=100,zhuoHp=100,frames=0,stgPos=0,stgRounds=1;
    int entries=0,opens[6]{},exits=0,school=4;
    bool started=false,leader=true,full=false,together=true,noEntry=false,noOpen=false,noExit=false,noCount=false,wrongSuffix=false,wipe=false,stale=false;
    bool refuseStg=false,refused=false,tongs=false,hasPet=false,petOn=true,blind=false,fog=false,trap=false,slowLqs=false,poisonCloud=false,zombieFirst=false,canLeave=false,must_page=false,fuMissing=false;
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;
    PiaomiaoFake(){scene=246;x=192;y=222;}
    QString modeOption()const{return QStringList{"挑战缥缈峰","#{XKFB_250115_12}","#{XKFB_250115_51}","#{XKFB_250115_13}"}[mode];}
    std::string fighting(const QString &n)const{return (n+QStringList{"","·闻恶","·识恶","·罚恶"}[wrongSuffix?3:mode]).toStdString();}
    void say(const char *line){messages+=line;messages+='\n';}
    double stgX()const{const double a[]={40,41,37,56,72};return a[stgPos];}
    double stgY()const{const double a[]={105,86,60,69,66};return a[stgPos];}
    std::vector<resident::Object> rows(){
        if(scene!=261)return {};
        if(!leader&&!started&&stage<=5)started=true; // Offline teammate opens each boss.
        std::vector<resident::Object> r;
        switch(stage){
        case 1:if(started)r.push_back({100,1100,124,87,double(bossHp),bossHp>0,fighting("哈大霸")});else r.push_back({100,1100,124,87,100,false,"哈大霸"});break;
        case 2:
            if((x-stgX())*(x-stgX())+(y-stgY())*(y-stgY())>400&&stgPos>0)break; // Hidden at his next point until someone comes.
            if(started&&!(zombieFirst&&zombie>0))r.push_back({200,1200,stgX(),stgY(),double(bossHp),bossHp>0,fighting("桑土公")});else if(!started)r.push_back({200,1200,stgX(),stgY(),100,false,"桑土公"});
            if(started)r.push_back({201,1201,stgX()+1,stgY(),double(zombie),zombie>0,"碧磷僵尸"});
            break;
        case 3:if(started)r.push_back({300,1300,116,50,double(bossHp),bossHp>0,fighting("乌老大")});else r.push_back({300,1300,117,49,100,false,"乌老大"});break;
        case 4:
            r.push_back({390,1390,96,41,100,false,"乌老大"});
            if(started){if(buHp>0)r.push_back({400,1400,125,35,double(buHp),true,fighting("不平道人")});
                if(zhuoHp>0)r.push_back({401,1401,127,35,double(zhuoHp),true,fighting("卓不凡")});
                if(buHp<=0&&zhuoHp<=0)r.push_back({402,1402,125,40,double(bossHp),bossHp>0,fighting("任平生")});}
            break;
        case 5:
            r.push_back({390,1390,96,41,100,false,"乌老大"});
            if(started&&bossHp>0&&!hidden())r.push_back({500,1500,125,40,double(bossHp),true,fighting("李秋水")});
            if(started&&bossHp<=0)r.push_back({500,1500,125,40,0,false,fighting("李秋水")});
            break;
        default:r.push_back({390,1390,96,41,100,false,"乌老大"});break;
        }
        return r;
    }
    bool hidden()const{return slowLqs&&bossHp==50&&(x-116)*(x-116)+(y-48)*(y-48)>9;}
    int zombie=100;
    std::vector<resident::Object> objects()override{
        ++frames;
        if(poisonCloud&&stage==3&&started&&x==78&&y==65){say("PMF_20080521_13");stage=4;started=false;bossHp=100;}
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==201){zombie=0;return;}
        if(id==400){buHp-=50;return;}
        if(id==401){zhuoHp-=50;return;}
        if(wipe&&stage==1){started=false;return;}
        bossHp-=50;
        if(stage==2&&bossHp==50&&stgRounds>0&&stgPos==0){--stgRounds;stgPos=1;started=false;bossHp=50;zombie=100;return;}
        if(stage==3&&bossHp<=50&&poisonCloud){bossHp=100;return;}
        if(stage==5&&bossHp<=0){return;}
        if(bossHp<=0&&stage<5){if(stage==3){stage=4;started=false;bossHp=100;return;}if(stage==4){stage=5;started=false;bossHp=100;return;}++stage;started=false;bossHp=100;}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==261?"缥缈峰":"楼兰"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=2;
            if(trap&&stage==5&&started){t+="2\t900\t-1\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;trap=false;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids"){
            if(v=="100:1100"&&tongs){tongs=false;return {Value(1),Value(std::string("4001"))};}
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos){
            must_page=code.find("local page,want="+std::to_string(mode==0?2:4))!=std::string::npos;
            return {Value(used),Value(limit),Value(0),Value(must_page?1:0)};}
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:team-hp")!=std::string::npos)return {Value(1)};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("shaoshi:dialog-first")!=std::string::npos)return {Value(std::string(refused?"#{PMF_20080521_09}":""))};
        if(code.find("piaomiao:dialog-has")!=std::string::npos)return {Value(canLeave?1:0)};
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(4001)")!=std::string::npos)return {Value(std::string("悬枢之痛"))};
            return {Value(std::string("其他"))};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string("42\t903\n43\t904\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==246){scene=261;x=124;y=120;}return {Value(leader?1:0)};}
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(hasPet&&petOn?0:-1),Value(123),Value(456)};
        if(code.find("return __tlbbDungeonPet.read(")==0)return {Value(123),Value(456),Value(petOn?1:0)};
        if(code.find("return __tlbbDungeonPet.submit(")==0){petOn=code.find(",1)")!=std::string::npos;return {Value(1)};}
        if(code.find("dungeon:dialog")!=std::string::npos){
            const auto opts=page=="closed"?QStringList{}:choices();
            return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    QStringList choices(){
        if(scene==246)return {modeOption()};
        if(option=="符敏仪")return fuMissing?QStringList{}:QStringList{"挑战不平道人和卓不凡"};
        if(option=="乌老大"){
            if(stage==3)return refused?QStringList{}:QStringList{"挑战"};
            if(stage>=6||(stage==5&&bossHp<=0))return {"#{PMFCC_150105_1}","确定离开"};
            return {"决战李秋水？"};
        }
        return {"挑战"};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";if(refused){refused=false;stage=2;stgPos=0;started=false;bossHp=100;}return {Value(1)};
        case gameplay::NpcTarget:page="menu";option=QString::fromWCharArray(a.text);if(option=="乌老大"&&stage==3&&refuseStg){refuseStg=false;refused=true;}return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];moves.emplace_back(x,y);return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);if(!choices().contains(label))return {Value(0)};
            if(scene==246){++entries;if(!noEntry){scene=261;x=124;y=120;stage=1;started=false;bossHp=100;buHp=100;zhuoHp=100;stgPos=0;stgRounds=1;zombie=100;}}
            else if(label=="#{PMFCC_150105_1}"){}
            else if(label=="确定离开"){++exits;if(!noExit){scene=246;if(!noCount)++used;}}
            else{++opens[qBound(0,stage,5)];if(!noOpen){started=true;
                if(stage==5){if(fog)say("PMF_20080530_10");}}}
            if(label!="#{PMFCC_150105_1}")page="closed";
            return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:
            return {Value(8),Value((stale?std::string("PMF_20080530_10\nPMF_20080521_13\n"):std::string())+messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void piaomiaoTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](PiaomiaoFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","piaomiao");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","piaomiao",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("piaomiao_flow_v1"),"Piaomiao has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Piaomiao still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"mode",h.mode},{"error",QString::fromStdString(why)},{"entries",h.entries},{"exits",h.exits},{"casts",h.casts},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/piaomiao-tests.json");must(progress.open(QIODevice::WriteOnly),"Piaomiao report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](PiaomiaoFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" stage "+std::to_string(h.stage)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto moved=[](const PiaomiaoFake &h,double x,double y){return std::find(h.moves.begin(),h.moves.end(),std::make_pair(x,y))!=h.moves.end();};
    test("piaomiao_full_five_stage_exit_counter_and_queue",[&]{
        PiaomiaoFake h;std::string why;const auto state=run(h,{},why);must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" stage "+std::to_string(h.stage)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText).c_str());
        must(h.entries==1&&h.exits==1&&h.used==1,"Piaomiao missed or replayed entry / exit");
        must(h.opens[1]==1&&h.opens[2]==2&&h.opens[3]==1&&h.opens[4]==1&&h.opens[5]==1,"Piaomiao boss opened the wrong number of times");
        for(int id:{100,200,300,400,401,402,500})must(has(h.attacked,id),("Piaomiao skipped target "+std::to_string(id)).c_str());
        must(moved(h,41,86),"桑土公 next point not searched");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Piaomiao result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","piaomiao"},{"task","piaomiao"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,4),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Piaomiao receipt did not release next queue item");
    });
    test("piaomiao_difficulties_pages_and_wrong_suffix",[&]{
        std::string why;const QStringList names{"普通","初级","中级","高级"};
        for(int i=1;i<=3;++i){PiaomiaoFake h;h.mode=i;h.limit=4;finished(h,{{"dpmf_type",names[i]}},why);must(h.entries==1&&h.used==1&&h.must_page,"Piaomiao difficulty did not finish on its page");}
        PiaomiaoFake h;h.wrongSuffix=true;h.mode=1;must(run(h,{{"dpmf_type",names[1]}},why)==resident::Vm::Failed,"Wrong difficulty boss accepted");must(why.find("后缀")!=std::string::npos,why.c_str());
    });
    test("piaomiao_limits_preconditions_and_no_feedback",[&]{
        std::string why;
        {PiaomiaoFake h;h.used=h.limit;must(run(h,{},why)==resident::Vm::Completed&&h.entries==0&&h.receipt.contains("already_done"),"Daily count not respected");}
        {PiaomiaoFake h;h.full=true;must(run(h,{},why)==resident::Vm::Failed&&h.entries==0,"Full bag entered");}
        {PiaomiaoFake h;h.together=false;must(run(h,{},why)==resident::Vm::Failed&&h.entries==0,"Scattered team entered");}
        {PiaomiaoFake h;h.noEntry=true;must(run(h,{},why)==resident::Vm::Failed&&h.entries>=1&&h.entries<=6,"Entry retried beyond the team patience");}
        {PiaomiaoFake h;h.noOpen=true;must(run(h,{},why)==resident::Vm::Failed&&h.opens[1]==1&&h.receipt.isEmpty(),"Boss opening replayed or completed");}
        {PiaomiaoFake h;h.noExit=true;must(run(h,{},why)==resident::Vm::Failed&&h.exits<=3&&h.receipt.isEmpty(),"Exit without leaving was completed");}
        {PiaomiaoFake h;h.noCount=true;must(run(h,{},why)==resident::Vm::Failed&&h.exits==1&&h.receipt.isEmpty(),"Count without increase was completed");}
    });
    test("piaomiao_wipe_stops_by_name_and_history_does_not_advance",[&]{
        std::string why;
        {PiaomiaoFake h;h.wipe=true;must(run(h,{},why)==resident::Vm::Failed&&h.receipt.isEmpty()&&h.opens[1]==1,"Boss back to NPC was not a stop");must(why.find("恢复为 NPC")!=std::string::npos,why.c_str());}
        {PiaomiaoFake h;h.stale=true;finished(h,{},why);must(h.logText.find("躲大群")==std::string::npos&&has(h.attacked,100),"History prompts changed the fight");}
    });
    test("piaomiao_mechanisms",[&]{
        std::string why;
        {PiaomiaoFake h;h.tongs=true;h.school=0;finished(h,{},why);must(h.logText.find("哈大霸 · ")!=std::string::npos&&(h.logText.find("远离")!=std::string::npos||h.logText.find("近战暂不打")!=std::string::npos),"悬枢之痛 not handled");}
        {PiaomiaoFake h;h.zombieFirst=true;finished(h,{},why);must(has(h.attacked,201),"碧磷僵尸 alone was not attacked");}
        {PiaomiaoFake h;h.fog=true;finished(h,{},why);must(h.logText.find("躲大群")!=std::string::npos&&moved(h,113,28)&&h.logText.find("大群结束")!=std::string::npos,"大群 safe spot not used");}
        {PiaomiaoFake h;h.fog=true;finished(h,{{"xzk158",true}},why);must(h.logText.find("躲大群")==std::string::npos,"秒杀 option still dodged");}
        {PiaomiaoFake h;h.trap=true;finished(h,{},why);must(h.logText.find("躲寒冰")!=std::string::npos,"寒冰 not dodged");}
        {PiaomiaoFake h;h.slowLqs=true;finished(h,{},why);must(h.logText.find("李秋水 · 寻找")!=std::string::npos&&moved(h,116,48),"Vanished 李秋水 not searched for");}
        {PiaomiaoFake h;h.poisonCloud=true;finished(h,{{"xzk226",true}},why);must(h.logText.find("躲毒群")!=std::string::npos&&moved(h,78,65),"毒群 option not used");}
    });
    test("piaomiao_order_refusal_resume_rounds_and_follower",[&]{
        std::string why;
        {PiaomiaoFake h;h.refuseStg=true;finished(h,{},why);must(h.logText.find("桑土公还没杀完")!=std::string::npos&&h.opens[2]>=3,"乌老大 refusal did not go back");}
        {PiaomiaoFake h;h.fuMissing=true;h.scene=261;h.stage=5;h.x=125;h.y=40;finished(h,{},why);must(h.entries==0&&h.opens[4]==0&&h.opens[5]==1,"Resume at 李秋水 restarted earlier stages");}
        for(int s:{2,3}){PiaomiaoFake h;h.scene=261;h.stage=s;h.x=s==2?40:116;h.y=s==2?105:50;
            finished(h,{},why);must(h.entries==0&&h.exits==1,"Resume restarted entry");for(int e=1;e<s;++e)must(h.opens[e]==0,"Resume replayed an earlier boss");}
        {PiaomiaoFake h;h.leader=false;finished(h,{},why);must(h.entries==0&&h.exits==1&&h.used==1,"Follower chose the entry or did not leave");for(int e=1;e<=5;++e)must(h.opens[e]==0,"Follower opened a boss");}
        {PiaomiaoFake h;h.limit=3;finished(h,{{"dungeon_rounds",2}},why);must(h.used==2&&h.entries==2&&h.exits==2,"Second round did not run");}
    });
    test("piaomiao_config_validation",[&]{
        auto c=combatTestConfig("piaomiao");c.insert("combat_scene",261);c.insert("dungeon_team_count",6);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3000);c.insert("dpmf_type","普通");c.insert("xzk158",false);c.insert("xzk226",false);c.insert("piaomiao_xiaohao",false);c.insert("piaomiao_loot",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("dpmf_type","");must(!validateLegacyConfig(bad,e),"Empty difficulty accepted");
        bad=c;bad.insert("piaomiao_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
        bad=c;bad.remove("xzk158");must(!validateLegacyConfig(bad,e),"Old queue without options accepted");
    });
}
}
