#pragma once
#include "guanshan_tests.hpp"
namespace tlbb {
// A small field for the production 圣兽山野猪 entries.
struct YezhuFake:ResidentFake {
    bool hunt=true,leader=true,noEntry=false,noLeave=false,together=true,full=false,promptOnKill=true,noBoss=false,bossOnlyAtSpot=false,catchFails=false,hasCatch=true,hasNpc=true,wipe=false;
    int traces=1,kills=0,killsNeeded=2,bossHp=100,entries=0,leaves=0,catches=0,heals=0,swaps=0,school=0,spiritHp=60,rejectedTalks=0;
    bool petGone=false,addsAlive=true;
    QString page="closed",npcName,receipt;std::vector<int> attacked;std::string messages;
    YezhuFake(){scene=201;x=136;y=109;}
    int fb()const{return hunt?231:232;}
    QStringList choices()const{
        if(hunt&&npcName==QString::fromUtf8("云飘飘")&&traces>0)return {QString::fromUtf8("追捕野猪王")};
        if(!hunt&&npcName==QString::fromUtf8("祥瑞神兽"))return {QString::fromUtf8("拯救灵兽")};
        return {QString::fromUtf8("再见")};
    }
    void enter(){if(noEntry)return;scene=fb();x=hunt?60:89;y=hunt?81:64;page="closed";kills=0;bossHp=100;petGone=false;addsAlive=true;if(hunt)--traces;}
    std::vector<resident::Object> rows(){
        std::vector<resident::Object> r;
        if(scene==201&&!hunt){
            if(!leader)return r;
            r.push_back({500,1500,x+5,y,100,false,"路人甲"});
            if(hasNpc&&(x-155)*(x-155)+(y-222)*(y-222)<100)r.push_back({501,1501,160,222,100,false,"祥瑞神兽"});
            return r;
        }
        if(scene!=fb())return r;
        if(hunt){
            if(kills<killsNeeded)r.push_back({200+kills,1200+kills,x+3,y,100,true,"野猪"});
            if(!noBoss&&(!bossOnlyAtSpot||(x-72)*(x-72)+(y-50)*(y-50)<25)){r.push_back({300,1300,72,50,double(bossHp),true,"尖牙野猪王"});}
            if(bossHp<=0&&!petGone)r.push_back({310,1310,74,50,100,false,"尖牙暴龙宝宝"});
        }else{
            r.push_back({320,1320,88,63,double(spiritHp),false,"祥瑞神兽"});
            if(addsAlive)r.push_back({330,1330,91,65,100,true,"发狂野猪"});
            else r.push_back({340,1340,92,66,double(bossHp),true,"野猪头目"});
        }
        return r;
    }
    std::vector<resident::Object> objects()override{return rows();}
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(hunt&&id>=200&&id<300){++kills;if(kills>=killsNeeded&&promptOnKill)messages+="已杀死野猪：30/30\n";return;}
        if(id==330){addsAlive=false;return;}
        bossHp-=50;
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==201?"圣兽山":"野猪"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";return {Value(scene),Value(1),Value(t)};}
        if(op=="object_buff_ids")return {Value(0),Value(std::string())};
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("yezhu:trace")!=std::string::npos)return {Value(traces)};
        if(code.find("yezhu:ui")!=std::string::npos){if(code.find("AppointLeader")!=std::string::npos){++swaps;leader=false;}return {};}
        if(code.find("yezhu:dialog-all")!=std::string::npos)return {Value(page=="closed"?std::string():choices().join('\n').toStdString())};
        if(code.find("yezhu:cast")!=std::string::npos){
            if(code.find("捕兽")!=std::string::npos){
                if(!hasCatch)return {Value(-1)};
                ++catches;if(catchFails)messages+="ResultText_127\n";else petGone=true;
                return {Value(1)};
            }
            ++heals;spiritHp=100;return {Value(1)};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string("42\t903\n43\t904\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(leader?1:0)};
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(-1),Value(123),Value(456)};
        if(code.find("dungeon:dialog")!=std::string::npos){
            const auto opts=page=="closed"?QStringList{}:choices();
            return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(full?0:5)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";npcName=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:
            if(scene==fb()&&a.ints[0]==fb()&&a.reals[0]==(hunt?27:237)&&a.reals[1]==(hunt?107:234)){++leaves;if(noLeave){x=a.reals[0];y=a.reals[1];}else{scene=201;x=136;y=109;}return {Value(1)};}
            scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(!choices().contains(label))return {Value(0)};
            if(label==QString::fromUtf8("追捕野猪王")||label==QString::fromUtf8("拯救灵兽")){++entries;enter();}
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
template<class Test>void yezhuTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](YezhuFake &h,QJsonObject cfg,std::string &why){
        const QString id=h.hunt?"dungeon_0031c749":"dungeon_0031db5f";
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("yezhu_flow_v1"),"Yezhu has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Yezhu still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=2400000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"task",id},{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"leaves",h.leaves},{"casts",h.casts},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/yezhu-tests.json");must(progress.open(QIODevice::WriteOnly),"Yezhu report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](YezhuFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" kills "+std::to_string(h.kills)+" boss "+std::to_string(h.bossHp)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](YezhuFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto logged=[](const YezhuFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("yezhu_hunt_full_flow_and_queue",[&]{
        YezhuFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.kills>=2&&has(h.attacked,300)&&h.catches==1&&h.leaves>=1&&h.scene!=231,"Hunt skipped a stage");
        must(logged(h,"前往尖牙野猪王"),"30/30 prompt did not lead to the boss");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Hunt result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","yezhu"},{"task","dungeon_0031c749"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,5),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Hunt receipt did not release next queue item");
    });
    test("yezhu_hunt_traces_and_preconditions",[&]{
        std::string why;
        {YezhuFake h;h.traces=0;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done")&&h.swaps==0,"No trace should end without a swap");}
        // After handing over, this client follows; no offline leader enters, so it stops by name.
        {YezhuFake h;h.traces=0;failed(h,{{"yezhu_swap_leader",true}},why);must(h.swaps==1&&why.find("没有进入副本")!=std::string::npos,why.c_str());}
    });
    test("yezhu_hunt_feedback_stops",[&]{
        std::string why;
        {YezhuFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {YezhuFake h;h.together=false;failed(h,{{"dungeon_team_count",3}},why);must(h.entries==0,"Scattered team entered");}
        {YezhuFake h;h.noEntry=true;failed(h,{},why);must(h.entries>=1&&h.entries<=6,"Entry retried beyond the team patience");}
        {YezhuFake h;h.noLeave=true;failed(h,{},why);must(h.receipt.isEmpty(),"Completed without leaving");}
        {YezhuFake h;h.scene=231;h.x=60;h.y=81;h.noBoss=true;failed(h,{{"dungeon_battle_seconds",30}},why);must(h.receipt.isEmpty(),"Completed without a boss");}
    });
    test("yezhu_hunt_catch_options_and_empty_lap",[&]{
        std::string why;
        {YezhuFake h;finished(h,{{"yezhu_catch",false}},why);must(h.catches==0,"Catch setting ignored");}
        {YezhuFake h;h.catchFails=true;finished(h,{},why);must(h.catches==1,"Failed catch replayed");}
        {YezhuFake h;h.hasCatch=false;finished(h,{},why);must(logged(h,"技能列表没有 捕兽"),"Missing catch skill not named");}
        // Resumed after the prompt: no monsters and no new prompt, so one empty lap leads to the boss.
        {YezhuFake h;h.scene=231;h.x=60;h.y=81;h.kills=2;h.promptOnKill=false;h.bossOnlyAtSpot=true;finished(h,{},why);must(logged(h,"一圈没有目标")&&has(h.attacked,300),"Empty lap did not lead to the boss");}
    });
    test("yezhu_rampage_full_flow_and_heal",[&]{
        std::string why;
        {YezhuFake h;h.hunt=false;h.school=4;finished(h,{},why);
            must(h.entries==1&&has(h.attacked,330)&&has(h.attacked,340)&&h.leaves>=1&&h.heals>=1,"Rampage skipped a stage");
            must(logged(h,"发现灵兽 祥瑞神兽"),"灵兽 not found through its dialog");}
        {YezhuFake h;h.hunt=false;h.school=4;finished(h,{{"yezhu_heal",false}},why);must(h.heals==0,"Heal setting ignored");}
        {YezhuFake h;h.hunt=false;finished(h,{},why);must(h.heals==0,"Non-emei healed");}
    });
    test("yezhu_rampage_search_limit_and_follower",[&]{
        std::string why;
        {YezhuFake h;h.hunt=false;h.hasNpc=false;failed(h,{},why);must(why.find("没有找到灵兽")!=std::string::npos&&h.entries==0,why.c_str());}
        {YezhuFake h;h.hunt=false;h.leader=false;failed(h,{},why);must(why.find("没有进入副本")!=std::string::npos&&h.entries==0,why.c_str());}
        {YezhuFake h;h.hunt=false;h.scene=232;h.x=89;h.y=64;finished(h,{},why);must(h.entries==0&&has(h.attacked,340),"Resume did not finish");}
    });
    test("yezhu_config_validation",[&]{
        auto c=combatTestConfig("dungeon_0031c749");c.insert("combat_scene",231);c.insert("dungeon_team_count",1);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",1800);
        c.insert("yezhu_loot",true);c.insert("yezhu_leave_map",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("dungeon_team_count",0);must(!validateLegacyConfig(bad,e),"Team 0 accepted");
        bad=c;bad.insert("yezhu_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
