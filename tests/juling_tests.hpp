#pragma once
#include "yijue_tests.hpp"
namespace tlbb {
// A small field for the production 聚灵谷 entries: adds, one beast, a box, and 云昕昕 out.
struct JulingFake:ResidentFake {
    QString beast=QString::fromUtf8("剧毒乌犍");
    int used=0,limit=1,hp=100,addHp=100,entries=0,boxOpens=0,leaves=0,school=0,mechLeft=40,followAsks=0,wrongEntries=0,lastEntryNpcX=0;
    bool boxUp=false,boxOpened=false,full=false,together=true,leader=true,noEntry=false,noLeave=false,noCount=false,wipe=false,adds=true;
    bool trap=false,poison=false,shield=false,charge=false,clone=false,cone=false,warn=false,lock=false,wild=false,skipCatch=false;
    QString page="closed",npcName,receipt;std::vector<int> attacked;std::string messages;
    JulingFake(){scene=112;x=153;y=146;}
    std::vector<resident::Object> rows(){
        std::vector<resident::Object> r;
        if(scene==112){r.push_back({60,1060,150,146,100,false,"玄雷宝驹"});r.push_back({61,1061,156,146,100,false,"剧毒乌犍"});return r;}
        if(scene==201||scene==875){if(!wild)return r;if((x-221)*(x-221)+(y-165)*(y-165)<400)r.push_back({62,1062,222,166,100,false,beast.toStdString()});return r;}
        if(scene!=877)return r;
        if(adds&&addHp>0)r.push_back({70,1070,x+2,y,double(addHp),true,"灵谷小怪"});
        if((!adds||addHp<=0)&&!boxUp&&!boxOpened){
            r.push_back({80,1080,52,107,double(hp),true,beast.toStdString()});
            if(mechLeft>0){
                if(cone)r.push_back({81,1081,x+1,y,100,false,"生肖副本通用空NPC"});
                if(clone)r.push_back({82,1082,60,107,100,false,"雪海沧龙"});
                if(warn){r.push_back({83,1083,52,115,100,false,"白虎预警NPC"});r.push_back({84,1084,60,107,100,false,"生肖副本通用空NPC"});}
                if(lock)r.push_back({85,1085,54,107,50,true,"雷锁"});
            }
        }
        if(boxUp)r.push_back({90,1090,52,110,100,false,"聚灵宝箱"});
        r.push_back({91,1091,56,139,100,false,"云昕昕"});
        return r;
    }
    std::vector<resident::Object> objects()override{if(mechLeft>0&&(trap||poison||cone||clone||warn||charge||shield))--mechLeft;return rows();}
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==70){addHp-=50;return;}
        if(id==85){lock=false;return;}
        if(id==80){
            hp-=50;
            if(hp<=20&&wipe){hp=100;return;}
            if(hp<=0){boxUp=true;messages+="SESX_230426_35\n";}
        }
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==877?"聚灵谷":"外面"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=1;
            if(trap&&mechLeft>0&&scene==877&&!boxUp){t+="2\t71\t971\t"+std::to_string(x+1)+"\t"+std::to_string(y)+"\n";++n;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids"){
            if(v=="-1:-1"&&poison&&mechLeft>0)return {Value(1),Value(std::string("9001"))};
            if(v.rfind("80:",0)==0&&shield&&mechLeft>0)return {Value(1),Value(std::string("9002"))};
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos)return {Value(used),Value(limit),Value(0),Value(1)};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("juling:ui")!=std::string::npos){if(code.find("AskTeamFollow")!=std::string::npos)++followAsks;return {};}
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(2),Value(std::string(leader?"42\t903\n43\t904\n":"43\t904\n42\t903\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&!noEntry&&scene!=877&&(scene==112||scene==201)){scene=877;x=107;y=120;++used;}return {Value(leader?1:0)};}
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(9001)")!=std::string::npos)return {Value(std::string("毒厄 雷域：x"))};
            if(code.find("(9002)")!=std::string::npos)return {Value(std::string("护盾：抵消"))};
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
        if(npcName==QString::fromUtf8("云昕昕"))return {"#{SESX_230426_98}","#{SESX_230426_40}"};
        if(npcName==QString::fromUtf8("聚灵宝箱"))return {"#{SESX_230426_103}"};
        if(scene==112)return {npcName==QString::fromUtf8("玄雷宝驹")?"#{SESX_230426_15}":"#{SESX_230426_139}"};
        return {"#{SESX_230426_140}"};
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::TeamCount:return {Value(2)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";npcName=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(!choices().contains(label))return {Value(0)};
            if(label=="#{SESX_230426_15}"||label=="#{SESX_230426_139}"||label=="#{SESX_230426_140}"){++entries;if(!noEntry){scene=877;x=107;y=120;if(!noCount)++used;}}
            if(label=="#{SESX_230426_103}"){++boxOpens;boxUp=false;boxOpened=true;messages+="SESX_230426_107\n";}
            if(label=="#{SESX_230426_40}"){++leaves;if(!noLeave){scene=112;x=153;y=146;}}
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
template<class Test>void julingTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](JulingFake &h,QJsonObject cfg,std::string &why,const QString &id){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("juling_flow_v1"),"Juling has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Juling still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1500000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"task",id},{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"casts",h.casts},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/juling-tests.json");must(progress.open(QIODevice::WriteOnly),"Juling report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    const QString easy="dungeon_00301bdf",normal="dungeon_0030129e",hard="dungeon_002ff923";
    auto finished=[&](JulingFake &h,QJsonObject cfg,std::string &why,const QString &id){
        const auto state=run(h,cfg,why,id);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" hp "+std::to_string(h.hp)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](JulingFake &h,QJsonObject cfg,std::string &why,const QString &id){
        const auto state=run(h,cfg,why,id);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto logged=[](const JulingFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("juling_easy_full_flow_and_queue",[&]{
        JulingFake h;std::string why;finished(h,{},why,easy);
        must(h.entries==1&&has(h.attacked,70)&&has(h.attacked,80)&&h.boxOpens==1&&h.leaves==1&&h.used==1,"Juling skipped a stage");
        must(h.choices().size()>0,"choices");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Juling result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","juling"},{"task",easy},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,6),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Juling receipt did not release next queue item");
    });
    test("juling_three_entries_and_settings",[&]{
        std::string why;
        {JulingFake h;finished(h,{},why,normal);must(h.entries==1&&h.npcName!=QString(),"Normal entry");}
        {JulingFake h;h.wild=true;h.scene=201;h.x=221;h.y=165;finished(h,{},why,hard);must(h.entries==1&&h.followAsks==1,"Hard entry");}
        {JulingFake h;h.wild=true;h.scene=875;h.x=251;h.y=272;failed(h,{{QString::fromUtf8("宿灵渊"),true}},why,hard);must(why.find("10 分钟")!=std::string::npos,why.c_str());}
        {JulingFake h;h.wild=true;h.scene=201;h.x=221;h.y=165;failed(h,{{QString::fromUtf8("不打剧毒乌犍"),true}},why,hard);must(h.entries==0,"Skipped beast entered");}
        // With adds left to the team and nobody clearing them, the run stands at the boss spot and stops by name.
        {JulingFake h;failed(h,{{QString::fromUtf8("不打小怪"),true}},why,easy);must(logged(h,"前往首领位置")&&!has(h.attacked,70),"Skip adds ignored");}
    });
    test("juling_preconditions_and_stops",[&]{
        std::string why;
        {JulingFake h;h.used=1;finished(h,{},why,easy);must(h.entries==0&&h.receipt.contains("already_done"),"Limit not respected");}
        {JulingFake h;h.full=true;failed(h,{},why,easy);must(h.entries==0,"Full bag entered");}
        {JulingFake h;h.together=false;failed(h,{{"dungeon_team_count",2}},why,easy);must(h.entries==0,"Scattered team entered");}
        {JulingFake h;h.noEntry=true;failed(h,{},why,easy);must(h.entries==1,"Entry replayed");}
        {JulingFake h;h.noCount=true;failed(h,{},why,easy);must(why.find("活动次数")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
        {JulingFake h;h.noLeave=true;failed(h,{},why,easy);must(h.leaves==3&&h.receipt.isEmpty(),"Leave not bounded");}
        {JulingFake h;h.wipe=true;failed(h,{},why,easy);must(why.find("灭团")!=std::string::npos,why.c_str());}
    });
    test("juling_four_beasts",[&]{
        std::string why;
        auto beast=[&](const char *name,auto setup,const char *text){
            JulingFake h;h.beast=QString::fromUtf8(name);h.adds=false;setup(h);finished(h,{},why,easy);
            must(logged(h,text),(std::string("log missing: ")+text+"\n"+h.logText.substr(0,900)).c_str());return h;
        };
        beast("剧毒乌犍",[](JulingFake &h){h.trap=true;},"躲陷阱");
        beast("剧毒乌犍",[](JulingFake &h){h.poison=true;},"毒厄离开队友");
        beast("玄雷宝驹",[](JulingFake &h){h.cone=true;},"躲扇形");
        beast("玄雷宝驹",[](JulingFake &h){h.poison=true;},"雷域停手");
        beast("玄雷宝驹",[](JulingFake &h){h.shield=true;},"破盾");
        {auto h=beast("玄雷宝驹",[](JulingFake &h){h.lock=true;},"打雷锁");must(has(h.attacked,85),"雷锁 not attacked");}
        beast("雪海沧龙",[](JulingFake &h){h.clone=true;},"机制中");
        beast("赤焰黑虎",[](JulingFake &h){h.warn=true;},"赤焰黑虎");
    });
    test("juling_resume_and_follower",[&]{
        std::string why;
        {JulingFake h;h.scene=877;h.x=52;h.y=107;h.adds=false;h.noCount=true;finished(h,{},why,easy);must(h.entries==0,"Resume entered again");}
        {JulingFake h;h.leader=false;finished(h,{},why,easy);must(h.entries==0&&h.leaves==1,"Follower opened an entry");}
    });
    test("juling_config_validation",[&]{
        auto c=combatTestConfig(easy);c.insert("combat_scene",877);c.insert("dungeon_team_count",1);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);c.insert(QString::fromUtf8("不打雷锁"),false);c.insert(QString::fromUtf8("不打小怪"),false);QString e;
        const bool valid=validateLegacyConfig(c,e);must(valid,e.toUtf8().constData());
        auto bad=c;bad.insert("dungeon_team_count",0);must(!validateLegacyConfig(bad,e),"Team 0 accepted");
        bad=c;bad.insert(QString::fromUtf8("不打小怪"),"true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
