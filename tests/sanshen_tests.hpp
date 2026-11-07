#pragma once
#include "wangling_tests.hpp"
namespace tlbb {
// A small field for the production 三神幻境 entries. Each boss: sealed -> first form -> second form -> dead.
struct SanshenFake:ResidentFake {
    int used=0,limit=2,stage=1,form=0,bossHp=100,frames=0,entries=0,opens[4]{},exits=0,school=4,boxTalks=0,keyUses=0,goldUses=0,freeUses=0,keyCount=0,gold=0;
    bool leader=true,full=false,together=true,noEntry=false,noOpen=false,noExit=false,noCount=false,wipe=false,stale=false;
    bool trap=false,flameOther=false,flameMine=false,seed=false,burn=false,noCorpse=false;int mech=0;
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;int startScene;
    explicit SanshenFake(int s=850){scene=s;startScene=s;x=s==850?289:620;y=s==850?81:380;}
    void say(const char *line){messages+=line;messages+='\n';}
    double bx()const{return stage==1?54:stage==2?126:132;}
    double by()const{return stage==1?113:stage==2?65:152;}
    std::vector<resident::Object> rows(){
        if(scene!=662)return {};
        std::vector<resident::Object> r;
        static const char *const names[3][3]={{"被封印的裂海玄蜥","裂海玄蜥","裂海魔龙"},{"被封印的炼狱凤凰","炼狱凤凰","灭世火凤"},{"被封印的摄灵蛊花","摄灵蛊花","噬魂花妖"}};
        if(stage<=3){
            if(!leader&&form==0)form=1; // Offline teammate unseals each boss.
            const int base=stage*100;
            if(form==0){r.push_back({base,base+1000,bx(),by(),100,false,names[stage-1][0]});r.push_back({90,1090,bx()+2,by()+2,100,false,"苍凌子"});}
            else{
                r.push_back({base+form,base+form+1000,bx(),by(),double(bossHp),bossHp>0,names[stage-1][form]});
                if(stage==2&&flameOther&&mech<10)r.push_back({250,1250,x+1,y,100,false,"乙的离火"});
                if(stage==2&&flameMine&&mech<10)r.push_back({251,1251,x+1,y,100,false,"甲的焱火"});
                if(stage==3&&seed)r.push_back({350,1350,bx()+2,by(),50,true,"毒种籽"});
            }
        }else r.push_back({900,1900,132,152,100,false,"三神宝箱·地"});
        return r;
    }
    std::vector<resident::Object> objects()override{
        ++frames;
        if(form>0&&stage==2&&(flameOther||flameMine))++mech;
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==350){seed=false;return;}
        if(wipe&&stage==2&&form==1){form=0;bossHp=100;return;}
        bossHp-=50;
        if(bossHp<=0){
            if(form==1){form=2;bossHp=100;return;}
            say(stage==1?"已杀死裂海魔龙： 1/1":stage==2?"已杀死灭世火凤： 1/1":"已杀死噬魂花妖：1/1");
            ++stage;form=0;bossHp=100;
        }
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==662?"三神幻境":"凤鸣镇"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=2;
            if(trap&&stage==1&&form>0){t+="2\t900\t-1\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;trap=false;}
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
        if(code.find("shaoshi:team-hp")!=std::string::npos)return {Value(1)};
        if(code.find("shaoshi:confirm")!=std::string::npos||code.find("sanshen:confirm2")!=std::string::npos)return {};
        if(code.find("shaoshi:dialog-first")!=std::string::npos)return {Value(std::string(option.startsWith("三神宝箱")&&boxTalks>0?"#{SSHJ_150915_71}":""))};
        if(code.find("sanshen:name")!=std::string::npos)return {Value(std::string("甲"))};
        if(code.find("sanshen:key-count")!=std::string::npos)return {Value(keyCount)};
        if(code.find("sanshen:gold")!=std::string::npos)return {Value(gold)};
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string("42\t903\n43\t904\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==startScene&&used==0){scene=662;x=54;y=100;}return {Value(leader?1:0)};}
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
        if(scene!=662)return {"#{FMYZ_180529_2}"};
        if(option.startsWith("三神宝箱"))return {"#{SSHJ_150915_92}","#{SSHJ_201030_3}","#{SSHJ_150915_65}"};
        if(option=="苍凌子"&&stage>3)return {"#{MZFB_150810_49}","#{SSHJ_20220725_02}","#{FBCC_201128_11}"};
        return {"#{MZFB_150810_45}"};
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
            if(label=="#{FBCC_201128_07")return {Value(0)};
            if(label=="SSHJ_150915_66"){++goldUses;++boxTalks;return {Value(1),Value(label.toStdString())};}
            if(!choices().contains(label))return {Value(0)};
            if(scene!=662){++entries;if(!noEntry){scene=662;x=54;y=100;stage=1;form=0;bossHp=100;boxTalks=0;}page="closed";}
            else if(label=="#{MZFB_150810_45}"){++opens[stage];if(!noOpen){form=1;bossHp=100;}page="closed";}
            else if(label=="#{FBCC_201128_11}"){++exits;if(!noExit){scene=startScene;if(!noCount)++used;}}
            else if(label=="#{SSHJ_201030_3}"){++keyUses;++boxTalks;}
            else if(label=="#{SSHJ_150915_65}"){++freeUses;++boxTalks;}
            return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:
            return {Value(8),Value((stale?std::string("已杀死噬魂花妖：1/1\n"):std::string())+messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
template<class Test>void sanshenTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](SanshenFake &h,QJsonObject cfg,std::string &why,const QString &id="sanshen"){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("sanshen_flow_v1"),"Sanshen has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Sanshen still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"task",id},{"error",QString::fromStdString(why)},{"entries",h.entries},{"exits",h.exits},{"casts",h.casts},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/sanshen-tests.json");must(progress.open(QIODevice::WriteOnly),"Sanshen report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](SanshenFake &h,QJsonObject cfg,std::string &why,const QString &id="sanshen"){
        const auto state=run(h,cfg,why,id);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" stage "+std::to_string(h.stage)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](SanshenFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto moved=[](const SanshenFake &h,double x,double y){return std::find(h.moves.begin(),h.moves.end(),std::make_pair(x,y))!=h.moves.end();};
    auto logged=[](const SanshenFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("sanshen_full_three_bosses_chest_exit_counter_and_queue",[&]{
        SanshenFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.exits==1&&h.used==1,"Sanshen missed or replayed entry / exit");
        for(int s=1;s<=3;++s)must(h.opens[s]==1,"Sanshen boss unsealed other than once");
        for(int id:{101,102,201,202,301,302})must(has(h.attacked,id),("Sanshen skipped form "+std::to_string(id)).c_str());
        must(h.freeUses==1&&h.keyUses==0&&h.goldUses==0,"Default chest was not the single free reward");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Sanshen result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","sanshen"},{"task","sanshen"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,4),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Sanshen receipt did not release next queue item");
    });
    test("sanshen_paid_chest_needs_setting_and_risk_switch",[&]{
        std::string why;
        {SanshenFake h;h.keyCount=2;h.gold=500;finished(h,{{"xzk87",true},{"xzk157",true}},why);must(h.keyUses==0&&h.goldUses==0&&h.freeUses==1,"Paid reward used without the risk switches");}
        {SanshenFake h;h.keyCount=2;finished(h,{{"xzk87",true},{"allow_item",true}},why);must(h.keyUses==1&&h.freeUses==0,"天星灵符 not used when allowed");}
        {SanshenFake h;h.gold=500;finished(h,{{"xzk157",true},{"allow_spend",true}},why);must(h.goldUses==1&&h.freeUses==0,"元宝 double not used when allowed");}
        {SanshenFake h;h.gold=100;finished(h,{{"xzk157",true},{"allow_spend",true}},why);must(h.goldUses==0&&h.freeUses==1,"元宝 used below the price");}
        {SanshenFake h;h.keyCount=0;finished(h,{{"xzk87",true},{"allow_item",true}},why);must(h.keyUses==0&&h.freeUses==1,"Missing 灵符 did not fall back to free");}
    });
    test("sanshen_bianjing_entrance_uses_its_own_npc_and_line",[&]{
        std::string why;SanshenFake h(775);finished(h,{},why,"dungeon_002fd257");must(h.entries==1&&h.used==1&&logged(h,"汴京三神幻境"),"汴京 entrance did not finish");
        SanshenFake other(0);other.x=100;other.y=100;finished(other,{},why,"dungeon_002fd257");must(moved(other,620,380),"汴京 entrance was not routed to its NPC");
    });
    test("sanshen_limits_preconditions_and_no_feedback",[&]{
        std::string why;
        {SanshenFake h;h.used=h.limit;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Daily count not respected");}
        {SanshenFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {SanshenFake h;h.together=false;failed(h,{},why);must(h.entries==0,"Scattered team entered");}
        {SanshenFake h;h.noEntry=true;failed(h,{},why);must(h.entries==1,"Entry replayed without feedback");}
        {SanshenFake h;h.noOpen=true;failed(h,{},why);must(h.opens[1]==1&&h.receipt.isEmpty(),"Unseal replayed or completed");}
        {SanshenFake h;h.noExit=true;failed(h,{},why);must(h.exits<=3&&h.receipt.isEmpty(),"Exit without leaving was completed");}
        {SanshenFake h;h.noCount=true;failed(h,{},why);must(h.exits==1&&h.receipt.isEmpty(),"Count without increase was completed");}
        {SanshenFake h;h.stale=true;finished(h,{},why);must(has(h.attacked,101),"History prompt skipped combat");}
    });
    test("sanshen_wipe_stops_by_name",[&]{
        std::string why;SanshenFake h;h.wipe=true;failed(h,{},why);must(why.find("重新封印")!=std::string::npos&&h.opens[2]==1&&h.receipt.isEmpty(),why.c_str());
    });
    test("sanshen_mechanisms",[&]{
        std::string why;
        {SanshenFake h;h.trap=true;finished(h,{},why);must(logged(h,"裂海玄蜥 · 躲陷阱"),"Trap not dodged");}
        {SanshenFake h;h.flameOther=true;finished(h,{},why);must(logged(h,"躲火苗"),"Other player's flame not dodged");}
        {SanshenFake h;h.flameMine=true;finished(h,{},why);must(logged(h,"带火苗离开队友"),"Own flame not moved away from the team");}
        {SanshenFake h;h.seed=true;finished(h,{},why);must(has(h.attacked,350),"毒种籽 not attacked");}
    });
    test("sanshen_resume_rounds_and_follower",[&]{
        std::string why;
        for(int s:{2,3}){SanshenFake h;h.scene=662;h.stage=s;h.x=s==2?126:132;h.y=s==2?70:144;finished(h,{},why);must(h.entries==0&&h.exits==1,"Resume restarted entry");for(int e=1;e<s;++e)must(h.opens[e]==0,"Resume replayed an earlier boss");}
        {SanshenFake h;h.limit=3;finished(h,{{"dungeon_rounds",2}},why);must(h.used==2&&h.entries==2&&h.exits==2,"Second round did not run");}
        {SanshenFake h;h.leader=false;finished(h,{},why);must(h.entries==0&&h.exits==1&&h.used==1,"Follower chose the entry or did not leave");for(int e=1;e<=3;++e)must(h.opens[e]==0,"Follower unsealed a boss");}
    });
    test("sanshen_config_validation",[&]{
        for(const auto &id:QStringList{"sanshen","dungeon_002fd257"}){
            auto c=combatTestConfig(id);c.insert("combat_scene",662);c.insert("dungeon_team_count",6);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3000);c.insert(QString::fromUtf8("小号模式"),false);c.insert("xzk87",false);c.insert("xzk157",false);c.insert("sanshen_loot",true);QString e;
            must(validateLegacyConfig(c,e),qPrintable(e));
            auto bad=c;bad.insert("sanshen_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
            bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
        }
    });
}
}
