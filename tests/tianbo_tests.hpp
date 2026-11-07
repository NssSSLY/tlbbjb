#pragma once
#include "mingwang_tests.hpp"
namespace tlbb {
// A small field for the production 夜探天波府 entry: five bosses in one scene.
struct TianboFake:ResidentFake {
    int used=0,limit=1,step=0,hp=100,hp2=100,raidSize=12,entries=0,opens=0,gates=0,leaves=0,school=0,mechLeft=30;
    bool started=false,raidLeaderFlag=true,full=false,noEntry=false,noOpen=false,noLeave=false,noCount=false,wipe=false,hard=false,memberOutside=false,invincible=false;
    bool feathers=false,dive=false,clones=false,rays=false,blades=false,warning=false,ministers=false,ring=false,tied=false;
    QString page="closed",npcName,receipt;std::vector<int> attacked;std::string messages;
    TianboFake(){scene=0;x=306;y=245;}
    void say(const char *line){messages+=line;messages+='\n';}
    std::vector<resident::Object> rows(){
        std::vector<resident::Object> r;
        if(scene!=848||step>=5)return r;
        static const std::array<std::array<double,2>,5> pos{{{229,250},{250,158},{130,150},{110,41},{399,92}}};
        static const std::array<const char*,5> names{{"云中鹤","岳老三","叶二娘","段延庆","心魔·延庆太子"}};
        const auto q=pos[step];
        if(step==4)started=true;
        if((x-q[0])*(x-q[0])+(y-q[1])*(y-q[1])>2500)return r;
        r.push_back({100+step,1100+step,q[0],q[1],double(hp),started,names[step]});
        if(step==2)r.push_back({150,1150,q[0]+3,q[1],double(hp2),started,"傀影"});
        if(started&&mechLeft>0){
            if(feathers)r.push_back({160,1160,x+1,y,100,false,"鹤之翎羽"});
            if(dive)r.push_back({161,1161,x+1,y,100,false,"白鹤之影（俯冲）"});
            if(clones)r.push_back({162,1162,x+1,y,100,false,"岳老三分身"});
            if(rays)r.push_back({163,1163,q[0],q[1]-9,100,false,"副本通用空npc"});
            if(blades)r.push_back({164,1164,q[0]+2,q[1]+2,50,true,"红影回刃"});
            if(warning)r.push_back({165,1165,q[0]+1,q[1]-1,100,false,"罪缚无间预警"});
            if(ministers){r.push_back({166,1166,q[0]+2,q[1],50,true,step==3?"蓝衣大臣":"紫衣大臣"});}
            if(ring)r.push_back({167,1167,394,87,100,false,"十方尽诛预警圈内"});
        }
        return r;
    }
    std::vector<resident::Object> objects()override{if(started&&mechLeft>0&&(feathers||dive||clones||rays||warning||ring))--mechLeft;return rows();}
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==164){blades=false;return;}
        if(id==166){ministers=false;return;}
        if(id==150){hp2-=50;}else if(id==100+step){hp-=50;}else return;
        if(step==2?(hp<=0&&hp2<=0):hp<=0)clear();
    }
    void clear(){
        if(wipe){started=false;hp=100;hp2=100;return;}
        if(step==0)say("YTTBF_220524_187");
        if(step==1)say("YTTBF_220524_189");
        if(step==2)say("YTTBF_220524_192");
        if(step==4)say("YTTBF_220524_199");
        if(step==3){x=399;y=92;}
        started=false;hp=100;hp2=100;++step;mechLeft=30;
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==848?"天波府":"洛阳"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){std::string t;int n=0;for(int i=0;i<raidSize-1;++i){t+="1\t"+std::to_string(50+i)+"\t"+std::to_string(950+i)+"\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;}return {Value(scene),Value(n),Value(t)};}
        if(op=="object_buff_ids"){
            if(tied&&v=="-1:-1")return {Value(1),Value(std::string("7001"))};
            if(invincible&&v.rfind("102:",0)==0&&mechLeft-->0)return {Value(1),Value(std::string("7002"))};
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos)return {Value(used),Value(limit),Value(0),Value(1)};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:team-hp")!=std::string::npos)return {Value(1)};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("dungeon:raid-roster")!=std::string::npos){
            std::string t;for(int i=0;i<raidSize;++i)t+=std::to_string(i/6)+"\t"+std::to_string(i%6)+"\t0\t0\t"+((memberOutside&&i==1)?"0":"1")+"\tm"+std::to_string(i)+"\n";
            return {Value(raidSize),Value(t)};
        }
        if(code.find("dungeon:raid-self")!=std::string::npos)return {Value(0),Value(1)};
        if(code.find("dungeon:raid-leader")!=std::string::npos){if(!raidLeaderFlag&&scene==0&&!noEntry){scene=848;x=229;y=240;}return {Value(raidLeaderFlag?1:0)};}
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(1),Value(std::string("42\t903\n"))};
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(raidLeaderFlag?1:0)};
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(7001)")!=std::string::npos)return {Value(std::string("连线：牵连"))};
            if(code.find("(7002)")!=std::string::npos)return {Value(std::string("无敌：免疫所有伤害"))};
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
        if(scene==0)return {"#{YTTBF_220524_05}","#{YTTBF_220524_06}"};
        if(npcName==QString::fromUtf8("杨小弟"))return {"#{YTTBF_220524_138}"};
        if(npcName==QString::fromUtf8("杨文广"))return {QString::fromUtf8("离开天波府"),QString::fromUtf8("确认")};
        return {"#{YTTBF_220524_57}"};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";npcName=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(!choices().contains(label))return {Value(0)};
            if(label=="#{YTTBF_220524_05}"||label=="#{YTTBF_220524_06}"){++entries;hard=label.endsWith("06}");if(!noEntry){scene=848;x=229;y=240;step=0;started=false;}}
            if(label=="#{YTTBF_220524_57}"){++opens;if(!noOpen)started=true;}
            if(label=="#{YTTBF_220524_138}"){++gates;x=110;y=60;}
            if(label==QString::fromUtf8("确认")){++leaves;if(!noLeave){scene=0;x=306;y=245;if(!noCount)++used;}}
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
template<class Test>void tianboTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](TianboFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id","dungeon_002e1e29");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","dungeon_002e1e29",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("tianbo_flow_v1"),"Tianbo has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Tianbo still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"opens",h.opens},{"leaves",h.leaves},{"casts",h.casts},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/tianbo-tests.json");must(progress.open(QIODevice::WriteOnly),"Tianbo report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](TianboFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" step "+std::to_string(h.step)+" hp "+std::to_string(h.hp)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1800)).c_str());
    };
    auto failed=[&](TianboFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto logged=[](const TianboFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("tianbo_five_bosses_leave_count_and_queue",[&]{
        TianboFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.opens==4&&h.gates==1&&h.leaves==1&&h.used==1&&!h.hard,"Tianbo skipped a stage");
        must(has(h.attacked,100)&&has(h.attacked,101)&&has(h.attacked,102)&&has(h.attacked,150)&&has(h.attacked,103)&&has(h.attacked,104),"Tianbo skipped a boss");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Tianbo result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","tianbo"},{"task","dungeon_002e1e29"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,5),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Tianbo receipt did not release next queue item");
    });
    test("tianbo_preconditions_and_no_feedback",[&]{
        std::string why;
        {TianboFake h;h.used=1;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Daily limit not respected");}
        {TianboFake h;finished(h,{{"xzk118",true}},why);must(h.hard,"Hard mode option not used");}
        {TianboFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {TianboFake h;h.raidSize=8;failed(h,{},why);must(h.entries==0,"Small raid entered");}
        {TianboFake h;h.raidSize=8;finished(h,{{"dungeon_team_count",8}},why);must(h.entries==1,"Team setting ignored");}
        {TianboFake h;h.memberOutside=true;failed(h,{},why);must(h.entries==0,"Raid member outside entered");}
        {TianboFake h;h.noEntry=true;failed(h,{},why);must(h.entries==1,"Entry replayed");}
        {TianboFake h;h.noOpen=true;failed(h,{},why);must(h.opens==1,"Open replayed");}
        {TianboFake h;h.noLeave=true;failed(h,{},why);must(h.leaves==3&&h.receipt.isEmpty(),"Leave not bounded");}
        {TianboFake h;h.noCount=true;failed(h,{},why);must(h.receipt.isEmpty(),"Completed without the count");}
        {TianboFake h;h.wipe=true;failed(h,{},why);must(why.find("恢复为 NPC")!=std::string::npos,why.c_str());}
    });
    test("tianbo_resume_and_follower",[&]{
        std::string why;
        {TianboFake h;h.scene=848;h.x=110;h.y=60;h.step=3;finished(h,{},why);must(h.entries==0&&!has(h.attacked,100)&&has(h.attacked,103),"Resume replayed a boss");}
        {TianboFake h;h.raidLeaderFlag=false;h.noOpen=true;failed(h,{},why);must(h.opens==0&&h.entries==0,"Follower opened");}
    });
    test("tianbo_mechanisms",[&]{
        std::string why;
        {TianboFake h;h.dive=true;finished(h,{},why);must(logged(h,"躲俯冲"),"Dive not dodged");}
        {TianboFake h;h.feathers=true;finished(h,{},why);must(logged(h,"躲翎羽"),"Feather not dodged");}
        {TianboFake h;h.feathers=true;h.tied=true;finished(h,{},why);must(logged(h,"连线走位"),"Tie not placed");}
        {TianboFake h;h.step=1;h.scene=848;h.x=250;h.y=150;h.clones=true;finished(h,{},why);must(logged(h,"躲分身"),"Clone not dodged");}
        {TianboFake h;h.step=1;h.scene=848;h.x=250;h.y=150;h.rays=true;finished(h,{},why);must(logged(h,"躲怒鳄袭沙"),"Rays not dodged");}
        {TianboFake h;h.step=2;h.scene=848;h.x=130;h.y=145;h.blades=true;finished(h,{},why);must(has(h.attacked,164),"Blade not attacked");}
        {TianboFake h;h.step=2;h.scene=848;h.x=130;h.y=145;h.invincible=true;finished(h,{},why);must(logged(h,"无敌中停手"),"Invincible not respected");}
        {TianboFake h;h.step=3;h.scene=848;h.x=110;h.y=60;h.warning=true;finished(h,{},why);must(logged(h,"躲罪缚无间"),"Warning not dodged");}
        {TianboFake h;h.step=3;h.scene=848;h.x=110;h.y=60;h.ministers=true;finished(h,{},why);must(has(h.attacked,166),"Minister not attacked");}
        {TianboFake h;h.step=4;h.scene=848;h.x=399;h.y=92;h.ring=true;finished(h,{},why);must(logged(h,"十方尽诛"),"Ring not handled");}
    });
    test("tianbo_config_validation",[&]{
        auto c=combatTestConfig("dungeon_002e1e29");c.insert("combat_scene",848);c.insert("dungeon_team_count",12);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);c.insert("xzk118",false);c.insert("tianbo_loot",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("dungeon_team_count",6);must(!validateLegacyConfig(bad,e),"Team 6 accepted");
        bad=c;bad.insert("xzk118","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
