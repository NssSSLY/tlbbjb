#pragma once
#include "yanzi_tests.hpp"
namespace tlbb {
// A small field for the production 少室山 entry: objects, prompts and receipts react to what the flow submits.
struct ShaoshiFake:ResidentFake {
    int mode=0,used=0,limit=2,stage=1,part=0,bossHp=100,xinmo=100,hits=0,frames=0;
    int entries=0,opens[6]{},exits=0,pickups=0,lootOpens=0,recalls=0,deploys=0,zxSwitchHits=0,goodZx=2;
    bool started=false,leader=true,full=false,together=true,noEntry=false,noOpen=false,noPrompt5=false,noExit=false,noCount=false;
    bool wrongSuffix=false,wipe=false,dailyLimit=false,stale=false,reflectWindow=false,burn=false,poison=false,selfBlast=false,ghost=false,trap=false,wild=false,hasPet=false,petOn=true,mpull=false;
    int windowFrames=0,castsInWindow=0;bool windowOpen=false;
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;
    ShaoshiFake(){scene=2;x=69;y=60;}
    QString modeOption()const{return QStringList{"#{CJG_101231_70}","#{XKFB_250115_06}","#{XKFB_250115_48}","#{XKFB_250115_07}"}[mode];}
    std::string bossName(const QString &n)const{return (n+QStringList{"","·闻恶","·识恶","·罚恶"}[wrongSuffix?3:mode]).toStdString();}
    void say(const char *line){messages+=line;messages+='\n';}
    std::vector<resident::Object> rows(){
        if(scene!=566)return {};
        if(!leader&&!started&&(stage<=4||(stage==5&&y<67)))started=true; // Offline teammate opens each boss.
        auto boss=[&](int id,double px,double py,const QString &n){
            if(started)return resident::Object{id,id+1000,px,py,double(bossHp),bossHp>0,bossName(n)};
            return resident::Object{id,id+1000,px,py,100.0,false,n.toStdString()};};
        std::vector<resident::Object> r;
        switch(stage){
        case 1:r.push_back(boss(100,130,171,"鸠摩智"));if(started&&part==0)r.push_back({101,1101,128,170,100,true,"信徒"});break;
        case 2:r.push_back(boss(200,68,121,"庄聚贤"));if(started&&part==0)r.push_back({201,1201,70,120,100,true,"冰蚕"});break;
        case 3:r.push_back(boss(300,195,86,"慕容复"));break;
        case 4:r.push_back(boss(400,130,126,"丁春秋"));if(started&&part==0)r.push_back({401,1401,132,126,100,true,"血咒巫蛊"});break;
        case 5:
            if(y>67){r.push_back({500,1500,130,124,100,false,"少林弟子"});break;}
            r.push_back({510,1510,134,37,100,false,"扫地神僧"});
            if(!started){r.push_back({520,1520,133,37,100,false,"萧远山"});r.push_back({530,1530,134,38,100,false,"慕容博"});break;}
            if(part==0)r.push_back({520,1520,122,46,double(bossHp),true,bossName("萧远山")});
            if(part==1){r.push_back({520,1520,133,37,100,false,"萧远山"});r.push_back({530,1530,122,46,double(bossHp),true,bossName("慕容博")});if(ghost)r.push_back({540,1540,120,46,100,true,"GGSS_160905_06"});}
            if(part==2){r.push_back({550,1550,122,46,double(xinmo),xinmo>0,"心魔"});r.push_back({560,1560,110,40,100,false,"达魔正心"});r.push_back({561,1561,130,50,100,false,"达魔正心"});
                if(mpull)r.push_back({520,1520,115,45,double(bossHp),true,bossName("萧远山")});}
            break;
        default:if(y<67)r.push_back({510,1510,120,33,100,false,"扫地神僧"});break;
        }
        return r;
    }
    std::vector<resident::Object> objects()override{
        ++frames;
        if(mpull&&part==2&&started&&(x-130)*(x-130)+(y-50)*(y-50)<=36){bossHp-=2;if(bossHp<=0){mpull=false;bossHp=100;}}
        return rows();
    }
    void advance(){
        started=false;part=0;bossHp=100;
        static const char *const prompts[]={"","CJG_101231_211","CJG_101231_212","CJG_101231_143","SSS_ZJ_120109_02","SSS_ZJ_120109_50"};
        if(stage<5||!noPrompt5)say(prompts[stage]);
        ++stage;
    }
    void hit(int id){
        ++casts;attacked.push_back(id);if(windowOpen)++castsInWindow;
        if(id==101||id==201||id==401){part=1;return;}
        if(id==540){ghost=false;return;}
        if(id==550){xinmo=0;if(!mpull){part=3;say("SSS_ZJ_120109_50");stage=6;started=false;}return;}
        if(id==520&&stage==5&&part==0){bossHp-=slow?5:50;if(bossHp<=0){part=1;bossHp=100;}return;}
        if(id==530){bossHp-=50;if(bossHp==50&&ghost)say("");if(bossHp<=0){part=2;bossHp=100;}return;}
        if(wipe&&stage==3){started=false;return;}
        bossHp-=50;if(bossHp<=0){advance();}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==566?"少室山":"大理"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=2;
            if(trap&&stage==2&&started){t+="2\t900\t-1\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;trap=false;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids"){
            if(v=="-1:-1"&&selfBlast&&stage==4&&started){selfBlast=false;return {Value(1),Value(std::string("3001"))};}
            if(v=="-1:-1"&&poison&&stage==5&&part==1&&started){poison=false;return {Value(1),Value(std::string("3002"))};}
            if(v=="-1:-1"&&mpull&&stage==5&&part==2){return {Value(1),Value(std::string("3003"))};}
            if(v=="200:1200"&&wild){return {Value(1),Value(std::string("3004"))};}
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
        if(code.find("shaoshi:emei-members")!=std::string::npos)return {Value(std::string())};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("shaoshi:dialog-first")!=std::string::npos)return {Value(std::string(dailyLimit?"#{CJG_101231_75}":""))};
        if(code.find("dungeon:buff-names")!=std::string::npos){
            for(auto [id,text]:std::initializer_list<std::pair<const char*,const char*>>{{"(3001)","自爆：即将爆炸"},{"(3002)","千蛛万毒"},{"(3003)","萧远山目标"},{"(3004)","疯狂：极大的提高伤害"}})
                if(code.find(id)!=std::string::npos)return {Value(std::string(text))};
            return {Value(std::string("其他"))};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string("42\t903\n43\t904\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==2&&used==0){scene=566;x=129;y=215;}return {Value(leader?1:0)};}
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(hasPet&&petOn?0:-1),Value(123),Value(456)};
        if(code.find("return __tlbbDungeonPet.read(")==0)return {Value(123),Value(456),Value(petOn?1:0)};
        if(code.find("return __tlbbDungeonPet.submit(")==0){const bool on=code.find(",1)")!=std::string::npos;if(on)++deploys;else ++recalls;petOn=on;return {Value(1)};}
        if(code.find("dungeon:dialog")!=std::string::npos){
            const auto opts=page=="closed"?QStringList{}:choices();
            return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    QStringList choices()const{
        if(scene==2)return {modeOption()};
        if(option=="少林弟子")return {"#{SSS_ZJ_120109_06}"};
        if(option=="扫地神僧")return stage>=6?QStringList{"#{CJG_101231_79}"}:QStringList{"#{SSS_ZJ_120109_11}"};
        return {"#{CJG_101231_375}"};
    }
    int school=4;bool must_page=false,slow=false;
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";option=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:
            scene=a.ints[0];x=a.reals[0];y=a.reals[1];moves.emplace_back(x,y);
            return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);if(!choices().contains(label))return {Value(0)};
            if(scene==2){++entries;if(!noEntry&&!dailyLimit){scene=566;x=129;y=215;stage=1;started=false;part=0;bossHp=100;xinmo=100;}}
            else if(label=="#{SSS_ZJ_120109_06}"){stage=5;y=66;x=137;}
            else if(label=="#{CJG_101231_79}"){++exits;if(!noExit){scene=2;if(!noCount)++used;}}
            else{++opens[qBound(0,stage,5)];if(!noOpen){started=true;part=0;bossHp=100;if(stage==3&&reflectWindow){say("CJG_101231_140");windowOpen=true;windowFrames=frames;}}}
            page="closed";return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:
            if(stale&&frames==0)return {Value(2),Value(std::string("SSS_ZJ_120109_50\nCJG_101231_211\n"))};
            if(windowOpen&&frames-windowFrames>30)windowOpen=false; // One object read per 250 ms hold frame: inside the 10 s stop window.
            if(stage==5&&part==0&&started&&burn){say("SSS_ZJ_120109_14");burn=false;}
            return {Value(32),Value((stale?std::string("SSS_ZJ_120109_50\nCJG_101231_211\n"):std::string())+messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void shaoshiTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](ShaoshiFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","shaoshi");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","shaoshi",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("shaoshi_flow_v1"),"Shaoshi has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Shaoshi still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"mode",h.mode},{"error",QString::fromStdString(why)},{"entries",h.entries},{"exits",h.exits},{"casts",h.casts},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/shaoshi-tests.json");must(progress.open(QIODevice::WriteOnly),"Shaoshi report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    test("shaoshi_full_five_stage_exit_counter_and_queue",[&]{
        ShaoshiFake h;std::string why;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        must(h.entries==1&&h.exits==1&&h.used==1,"Shaoshi missed or replayed entry / exit");
        for(int s=1;s<=5;++s)must(h.opens[s]==1,"Shaoshi boss opened other than once");
        for(int id:{100,101,200,201,300,400,401,520,530,550})must(has(h.attacked,id),("Shaoshi skipped target "+std::to_string(id)).c_str());
        must(has(h.attacked,101)&&std::find(h.attacked.begin(),h.attacked.end(),101)<std::find(h.attacked.begin(),h.attacked.end(),100),"Followers of 鸠摩智 were not cleared first");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Shaoshi result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","shaoshi"},{"task","shaoshi"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,4),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Shaoshi receipt did not release next queue item");
    });
    test("shaoshi_difficulties_pages_and_wrong_suffix",[&]{
        std::string why;const QStringList names{"普通","初级","中级","高级"};
        for(int i=1;i<=3;++i){ShaoshiFake h;h.mode=i;h.limit=4;must(run(h,{{"sss_type",names[i]}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==1&&h.used==1&&h.must_page,"Shaoshi difficulty did not finish on its page");}
        ShaoshiFake h;h.wrongSuffix=true;h.mode=1;must(run(h,{{"sss_type",names[1]}},why)==resident::Vm::Failed,"Wrong difficulty boss accepted");must(why.find("后缀")!=std::string::npos,why.c_str());
    });
    test("shaoshi_limits_preconditions_and_no_feedback",[&]{
        std::string why;
        {ShaoshiFake h;h.used=h.limit;must(run(h,{},why)==resident::Vm::Completed&&h.entries==0&&h.receipt.contains("already_done"),"Daily count not respected");}
        {ShaoshiFake h;h.dailyLimit=true;must(run(h,{},why)==resident::Vm::Completed&&h.receipt.contains("already_done"),"朱丹臣 daily text not respected");}
        {ShaoshiFake h;h.full=true;must(run(h,{},why)==resident::Vm::Failed&&h.entries==0,"Full bag entered");}
        {ShaoshiFake h;h.together=false;must(run(h,{},why)==resident::Vm::Failed&&h.entries==0,"Scattered team entered");}
        {ShaoshiFake h;h.noEntry=true;must(run(h,{},why)==resident::Vm::Failed&&h.entries==1,"Entry replayed without feedback");}
        {ShaoshiFake h;h.noOpen=true;must(run(h,{},why)==resident::Vm::Failed&&h.opens[1]==1&&h.receipt.isEmpty(),"Boss opening replayed or completed");}
        {ShaoshiFake h;h.noExit=true;must(run(h,{},why)==resident::Vm::Failed&&h.exits<=3&&h.receipt.isEmpty(),"Exit without leaving was completed");}
        {ShaoshiFake h;h.noCount=true;must(run(h,{},why)==resident::Vm::Failed&&h.exits==1&&h.receipt.isEmpty(),"Count without increase was completed");}
    });
    test("shaoshi_wipe_stops_by_name_and_history_does_not_advance",[&]{
        std::string why;
        {ShaoshiFake h;h.wipe=true;must(run(h,{},why)==resident::Vm::Failed&&h.receipt.isEmpty()&&h.opens[3]==1,"Boss back to NPC was not a stop");must(why.find("恢复为 NPC")!=std::string::npos,why.c_str());}
        {ShaoshiFake h;h.stale=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(has(h.attacked,100)&&h.opens[1]==1,"History prompts skipped combat");}
    });
    test("shaoshi_mechanisms",[&]{
        std::string why;
        {ShaoshiFake h;h.reflectWindow=true;h.hasPet=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("慕容复 · 停手")!=std::string::npos&&h.castsInWindow==0&&h.recalls>=1&&h.recalls==h.deploys&&h.petOn,("慕容复 stop window attacked or lost the pet: casts "+std::to_string(h.castsInWindow)+" recalls "+std::to_string(h.recalls)+" deploys "+std::to_string(h.deploys)+" on "+std::to_string(h.petOn)+"\n"+h.logText).c_str());}
        {ShaoshiFake h;h.burn=true;h.slow=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("躲焚天灭地")!=std::string::npos,"焚天灭地 not dodged");}
        {ShaoshiFake h;h.selfBlast=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("自爆远离队友")!=std::string::npos,"自爆 not handled");}
        {ShaoshiFake h;h.poison=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("千蛛万毒走位")!=std::string::npos,"千蛛万毒 not handled");}
        {ShaoshiFake h;h.ghost=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(has(h.attacked,540),"鬼谷 target skipped");}
        {ShaoshiFake h;h.trap=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("躲陷阱")!=std::string::npos,"庄聚贤 trap not dodged");}
        {ShaoshiFake h;h.mpull=true;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("换另一个")!=std::string::npos&&!h.mpull,"达魔正心 pull did not find the damaging one");}
        {ShaoshiFake h;must(run(h,{{"xzk47",true}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.logText.find("绕场输出")!=std::string::npos,"绕场 option lost");}
    });
    test("shaoshi_resume_rounds_and_follower",[&]{
        std::string why;
        for(int s:{2,3,4}){ShaoshiFake h;h.scene=566;h.stage=s;const double px[]={0,0,68,195,130},py[]={0,0,121,86,126};h.x=px[s];h.y=py[s];
            must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==0&&h.exits==1,"Resume restarted entry");for(int e=1;e<s;++e)must(h.opens[e]==0,"Resume replayed an earlier boss");}
        {ShaoshiFake h;h.limit=3;must(run(h,{{"dungeon_rounds",2}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.used==2&&h.entries==2&&h.exits==2,"Second round did not run");}
        {ShaoshiFake h;h.leader=false;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==0,"Follower chose the entry");for(int e=1;e<=5;++e)must(h.opens[e]==0,"Follower opened a boss");must(h.exits==1&&h.used==1,"Follower did not leave");}
    });
    test("shaoshi_config_validation",[&]{
        auto c=combatTestConfig("shaoshi");c.insert("combat_scene",566);c.insert("dungeon_team_count",6);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3000);c.insert("sss_type","普通");c.insert("xzk47",false);c.insert("xzk189",false);c.insert("shaoshi_loot",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("sss_type","");must(!validateLegacyConfig(bad,e),"Empty difficulty accepted");
        bad=c;bad.insert("shaoshi_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
        bad=c;bad.remove("xzk47");must(!validateLegacyConfig(bad,e),"Old queue without options accepted");
    });
}
}
