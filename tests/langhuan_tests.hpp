#pragma once
#include "bingsheng_tests.hpp"
namespace tlbb {
// A small field for the production 琅嬛福地 entries: objects, prompts and receipts react to what the flow submits.
struct LanghuanFake:ResidentFake {
    int used=0,limit=2,stage=1,bossHp=100,frames=0,mode=0,entries=0,opens[5]{},exits=0,school=4,mechFrames=0;
    bool started=false,leader=true,full=false,together=true,noEntry=false,noOpen=false,noExit=false,noCount=false,wrongSuffix=false,wipe=false,must_page=false;
    bool sword=false,shade=false,mirror=false,trap=false,bagua=false,zone=false,breaker=false,pool=false,palmSelf=false,palmOther=false,follow=false;
    std::string name="甲";
    QString page="closed",option,receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;std::string messages;
    LanghuanFake(){scene=2;x=292;y=92;}
    QString modeOption()const{return QStringList{"#{LHFD_160203_02}","#{XKFB_250115_10}","#{XKFB_250115_50}","#{XKFB_250115_11}","#{LHFD_160203_03}"}[mode];}
    std::string fighting(const QString &n)const{return (n+QStringList{"","·闻恶","·识恶","·罚恶",""}[wrongSuffix?3:mode]).toStdString();}
    void say(const std::string &line){messages+=line;messages+='\n';}
    resident::Object bossAt(int id,double px,double py,const QString &n){
        if(started)return {id,id+1000,px,py,double(bossHp),bossHp>0,fighting(n)};
        return {id,id+1000,px,py,100.0,false,n.toStdString()};
    }
    std::vector<resident::Object> rows(){
        if(scene!=677)return {};
        if(!leader&&!started&&stage<=4)started=true; // Offline teammate opens each boss.
        std::vector<resident::Object> r;const bool hurt=started&&bossHp<100;
        switch(stage){
        case 1:r.push_back(bossAt(100,140,62,"李秋水"));
            if(hurt&&sword)r.push_back({101,1101,x+1,y,100,false,"剑"});
            if(hurt&&shade)r.push_back({102,1102,142,60,50,true,"无相踪影"});
            if(hurt&&mirror)r.push_back({103,1103,139,61,100,false,"玉璧残影"});break;
        case 2:r.push_back(bossAt(200,212,119,"天山童姥"));break;
        case 3:r.push_back(bossAt(300,182,207,"无崖子"));
            if(hurt&&bagua)r.push_back({301,1301,180,205,100,false,"乾"});
            if(hurt&&zone)r.push_back({302,1302,175,200,100,false,"八卦安全区"});
            if(hurt&&breaker)r.push_back({303,1303,190,210,50,true,"击杀破阵"});
            if(bossHp<21&&bossHp>0&&pool)r.push_back({304,1304,x+1,y,100,false,"黑水NPC4"});break;
        case 4:r.push_back(bossAt(400,82,181,"虚竹"));
            if(hurt&&palmOther)r.push_back({401,1401,x+1,y,100,false,"六阳掌力"});break;
        default:r.push_back({410,1410,82,181,100,false,"李青萝"});break;
        }
        return r;
    }
    std::vector<resident::Object> objects()override{
        ++frames;
        // Timed mechanics end by themselves, as they do in the game.
        const bool live=started&&bossHp<100&&((stage==1&&sword)||(stage==3&&(bagua||zone))||(stage==3&&pool&&bossHp<21)||(stage==4&&palmOther));
        if(live&&++mechFrames>10){sword=bagua=zone=pool=palmOther=false;}
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==102){shade=false;return;}
        if(id==303){breaker=false;return;}
        if(wipe&&stage==2&&bossHp==75){started=false;return;}
        bossHp-=stage==3?20:25;
        if(stage==1&&bossHp==75&&sword)say("LHFD_160203_75");
        if(stage==4&&bossHp==75&&palmSelf)say("LHFD_160203_92 "+name);
        if(stage==4&&bossHp==75&&palmOther)say("LHFD_160203_92 其他人");
        if(bossHp<=0){++stage;started=false;bossHp=100;}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==677?"琅嬛福地":"大理"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=2;
            if(trap&&stage==2&&started&&bossHp<100){t+="2\t900\t-1\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";++n;trap=false;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids")return {Value(0),Value(std::string())};
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos){
            must_page=code.find("local page,want="+std::to_string(mode>=1&&mode<=3?4:2))!=std::string::npos;
            return {Value(used),Value(limit),Value(0),Value(must_page?1:0)};}
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("shaoshi:team-hp")!=std::string::npos)return {Value(1)};
        if(code.find("shaoshi:emei-members")!=std::string::npos)return {Value(std::string())};
        if(code.find("shaoshi:confirm")!=std::string::npos)return {};
        if(code.find("langhuan:name")!=std::string::npos)return {Value(name)};
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string(leader?"42\t903\n43\t904\n44\t905\n":"43\t904\n42\t903\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==2){scene=677;x=140;y=80;}return {Value(leader?1:0)};}
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
        if(scene==2)return {modeOption()};
        if(option=="李青萝")return {"#{LHFD_160203_26}"};
        return {"#{LHFD_160203_28}"};
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
            if(scene==2){++entries;if(!noEntry){scene=677;x=140;y=80;stage=1;started=false;bossHp=100;}}
            else if(option=="李青萝"){++exits;if(!noExit){scene=2;if(!noCount)++used;}}
            else{++opens[qBound(0,stage,4)];if(!noOpen)started=true;}
            page="closed";return {Value(1),Value(label.toStdString())};
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
template<class Test>void langhuanTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](LanghuanFake &h,QJsonObject cfg,std::string &why,const QString &id="langhuan"){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_count",3);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("langhuan_flow_v1"),"Langhuan has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Langhuan still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"task",id},{"error",QString::fromStdString(why)},{"entries",h.entries},{"exits",h.exits},{"casts",h.casts},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/langhuan-tests.json");must(progress.open(QIODevice::WriteOnly),"Langhuan report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](LanghuanFake &h,QJsonObject cfg,std::string &why,const QString &id="langhuan"){
        const auto state=run(h,cfg,why,id);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" stage "+std::to_string(h.stage)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1600)).c_str());
    };
    auto failed=[&](LanghuanFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto moved=[](const LanghuanFake &h,double x,double y){return std::find(h.moves.begin(),h.moves.end(),std::make_pair(x,y))!=h.moves.end();};
    auto logged=[](const LanghuanFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("langhuan_full_four_stage_exit_counter_and_queue",[&]{
        LanghuanFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.exits==1&&h.used==1,"Langhuan missed or replayed entry / exit");
        for(int s=1;s<=4;++s)must(h.opens[s]==1,"Langhuan boss opened other than once");
        for(int id:{100,200,300,400})must(has(h.attacked,id),("Langhuan skipped boss "+std::to_string(id)).c_str());
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Langhuan result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","langhuan"},{"task","langhuan"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,4),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Langhuan receipt did not release next queue item");
    });
    test("langhuan_difficulties_hard_entry_and_wrong_suffix",[&]{
        std::string why;const QStringList names{"普通","初级","中级","高级"};
        for(int i=1;i<=3;++i){LanghuanFake h;h.mode=i;h.limit=4;finished(h,{{"lhfd_type",names[i]}},why);must(h.entries==1&&h.used==1&&h.must_page,"Langhuan difficulty did not finish on its page");}
        {LanghuanFake h;h.mode=4;finished(h,{},why,"dungeon_002fe064");must(h.entries==1&&h.used==1&&h.must_page,"Hard entry did not use its own option and campaign");}
        LanghuanFake h;h.wrongSuffix=true;h.mode=1;must(run(h,{{"lhfd_type",names[1]}},why)==resident::Vm::Failed,"Wrong difficulty boss accepted");must(why.find("后缀")!=std::string::npos,why.c_str());
    });
    test("langhuan_limits_preconditions_and_no_feedback",[&]{
        std::string why;
        {LanghuanFake h;h.used=h.limit;finished(h,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Daily count not respected");}
        {LanghuanFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {LanghuanFake h;h.together=false;failed(h,{},why);must(h.entries==0,"Scattered team entered");}
        {LanghuanFake h;h.noEntry=true;failed(h,{},why);must(h.entries==1,"Entry replayed without feedback");}
        {LanghuanFake h;h.noOpen=true;failed(h,{},why);must(h.opens[1]==1&&h.receipt.isEmpty(),"Boss opening replayed or completed");}
        {LanghuanFake h;h.noExit=true;failed(h,{},why);must(h.exits<=3&&h.receipt.isEmpty(),"Exit without leaving was completed");}
        {LanghuanFake h;h.noCount=true;failed(h,{},why);must(h.exits==1&&h.receipt.isEmpty(),"Count without increase was completed");}
    });
    test("langhuan_wipe_stops_by_name",[&]{
        std::string why;LanghuanFake h;h.wipe=true;failed(h,{},why);must(why.find("恢复为 NPC")!=std::string::npos&&h.opens[2]==1&&h.receipt.isEmpty(),why.c_str());
    });
    test("langhuan_mechanisms",[&]{
        std::string why;
        {LanghuanFake h;h.sword=true;finished(h,{},why);must(logged(h,"躲剑气"),"剑气 not dodged");}
        {LanghuanFake h;h.shade=true;finished(h,{},why);must(has(h.attacked,102),"无相踪影 not attacked");}
        {LanghuanFake h;h.mirror=true;h.shade=true;finished(h,{},why);must(logged(h,"玉璧残影集火"),"玉璧残影 not focused");}
        {LanghuanFake h;h.trap=true;finished(h,{},why);must(logged(h,"天山童姥 · 躲陷阱"),"童姥 trap not dodged");}
        {LanghuanFake h;h.bagua=true;finished(h,{},why);must(logged(h,"八卦等待"),"八卦 wait not used");}
        {LanghuanFake h;h.zone=true;finished(h,{},why);must(logged(h,"八卦安全区")&&moved(h,175,200),"八卦 safe zone not used");}
        {LanghuanFake h;h.breaker=true;finished(h,{},why);must(has(h.attacked,303),"破阵 not attacked");}
        {LanghuanFake h;h.pool=true;finished(h,{},why);must(logged(h,"躲黑水"),"黑水 not dodged");}
        {LanghuanFake h;h.palmSelf=true;finished(h,{},why);must(logged(h,"被点六阳掌"),"六阳掌 on self not handled");}
        {LanghuanFake h;h.palmOther=true;finished(h,{},why);must(logged(h,"躲六阳掌"),"六阳掌 on others not handled");}
    });
    test("langhuan_resume_rounds_and_follower",[&]{
        std::string why;
        for(int s:{2,3}){LanghuanFake h;h.scene=677;h.stage=s;h.x=s==2?212:182;h.y=s==2?119:207;finished(h,{},why);must(h.entries==0&&h.exits==1,"Resume restarted entry");for(int e=1;e<s;++e)must(h.opens[e]==0,"Resume replayed an earlier boss");}
        {LanghuanFake h;h.limit=3;finished(h,{{"dungeon_rounds",2}},why);must(h.used==2&&h.entries==2&&h.exits==2,"Second round did not run");}
        {LanghuanFake h;h.leader=false;finished(h,{},why);must(h.entries==0&&h.exits==1&&h.used==1,"Follower chose the entry or did not leave");for(int e=1;e<=4;++e)must(h.opens[e]==0,"Follower opened a boss");}
    });
    test("langhuan_config_validation",[&]{
        auto c=combatTestConfig("langhuan");c.insert("combat_scene",677);c.insert("dungeon_team_count",6);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3000);c.insert("lhfd_type","普通");c.insert("xzk217",false);c.insert("langhuan_loot",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("lhfd_type","");must(!validateLegacyConfig(bad,e),"Empty difficulty accepted");
        bad=c;bad.insert("langhuan_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
        auto hard=combatTestConfig("dungeon_002fe064");hard.insert("combat_scene",677);hard.insert("dungeon_team_count",6);hard.insert("dungeon_rounds",1);hard.insert("dungeon_wait_seconds",45);hard.insert("dungeon_battle_seconds",3000);hard.insert("xzk217",false);hard.insert("langhuan_loot",true);
        must(validateLegacyConfig(hard,e),qPrintable(e));
    });
}
}
