#pragma once
#include "tianbo_tests.hpp"
namespace tlbb {
// A small field for the production 凤凰陵墓 entries. Rooms follow the leader's route from 26: 26, 20, 19, 13 ...
struct FenghuangFake:ResidentFake {
    std::vector<int> events{3,7,9};std::vector<int> cells{26,20,19,13,14,8};
    int at=-1,used=0,limit=1,hp=100,entries=0,opens=0,selects=0,items=0,keyUses=0,school=0,mechLeft=30,claims=0,kickFrames=0,statueOpens=0,hardEntries=0;
    bool hard=false,started=false,statueDone=false,full=false,together=true,leader=true,noEntry=false,noOpen=false,noSelect=false,noCount=false,wipe=false,kick=true,traps=false,badBuff=false,stay=false,orb=false,shade=false,gameDone=false;
    QString page="closed",npcName,receipt;std::vector<int> attacked;std::string messages;
    FenghuangFake(){scene=260;x=186;y=113;}
    int event()const{return at>=0&&at<int(events.size())?events[at]:0;}
    std::vector<resident::Object> rows(){
        std::vector<resident::Object> r;
        if(scene!=999)return r;
        if(at<0){r.push_back({90,1090,54,131,100,false,"杨建月"});return r;}
        if(at>=int(events.size()))return r;
        const auto e=event();const double cx=100,cy=100;
        if(e==3||e==4||e==5||e==9||e==10){
            const char *name=e==3?"地陵蛊花":e==4?"岩铸战将":e==5?"暗冥乌犍":e==9?"镇陵战魂":"霜影";
            if(!gameDone)r.push_back({100+e,1100+e,cx,cy,double(hp),started,name});
            if(started&&mechLeft>0){
                if(badBuff&&false)r.push_back({0,0,0,0,0,false,""});
                if(orb&&e==9)r.push_back({120,1120,cx+2,cy,50,true,"暗夜珠"});
                if(shade&&e==9)r.push_back({121,1121,x+1,y,100,false,"暗夜凰影"});
                if(e==3&&orb)r.push_back({122,1122,cx+2,cy,50,true,"毒花"});
            }
            return r;
        }
        if(!statueDone){r.push_back({110,1110,cx,cy,100,false,"火凤石雕"});return r;}
        if(gameDone)return r;
        if(e==7){r.push_back({130,1130,cx+2,cy,100,false,"真火鼎"});r.push_back({131,1131,cx+3,cy,double(hp),true,"风元灵"});}
        if(e==8){r.push_back({132,1132,cx+2,cy,double(hp),true,"守陵傀儡"});}
        if(e==1){r.push_back({133,1133,cx+5,cy,100,false,"金币陷阱"});}
        if(e==2){r.push_back({134,1134,cx+6,cy,100,false,"金区域"});}
        if(e==6){r.push_back({135,1135,cx+2,cy,100,false,"银月凤雕"});}
        return r;
    }
    std::vector<resident::Object> objects()override{
        if(started&&mechLeft>0&&(orb||shade||traps||badBuff))--mechLeft;
        if(statueDone&&!gameDone&&(event()==1||event()==2)&&(x==105||x==106)){gameDone=true;}
        return rows();
    }
    void hit(int id){
        ++casts;attacked.push_back(id);
        if(id==120||id==122){orb=false;return;}
        if(id==131||id==132||id==100+event()){
            hp-=50;
            if(hp<=0){
                if(wipe&&id>=100&&id<=110){started=false;hp=100;return;}
                gameDone=true;hp=100;
                if(event()==9){messages+="FHCL_240708_168\n";}
            }
        }
    }
    int state(int cell)const{
        for(size_t i=0;i<cells.size();++i)if(cells[i]==cell){
            if(int(i)<at)return 3;
            if(int(i)==at)return gameDone?3:2;
            return 1;
        }
        return 0;
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position"){
            if(scene==999&&at>=0&&at<int(events.size())&&event()==9&&gameDone&&!stay&&++kickFrames>10){scene=260;x=186;y=113;if(!noCount)++used;}
            if(scene==999&&stay&&at>=0&&event()==9&&gameDone&&!noCount&&used==0)++used;
            return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==999?"凤凰陵墓":"外面"))};
        }
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot"){
            std::string t="1\t43\t904\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";int n=1;
            if(traps&&started&&mechLeft>0){t+="2\t70\t970\t"+std::to_string(x+1)+"\t"+std::to_string(y)+"\n";++n;}
            return {Value(scene),Value(n),Value(t)};
        }
        if(op=="object_buff_ids"){
            if(v=="-1:-1"&&badBuff&&started&&mechLeft>0)return {Value(1),Value(std::string("8001"))};
            if(v=="-1:-1"&&event()==2&&statueDone&&!gameDone)return {Value(1),Value(std::string("8002"))};
            if(v=="-1:-1"&&event()==6&&statueDone&&!gameDone)return {Value(1),Value(std::string("8003"))};
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
        if(code.find("fenghuang:base")!=std::string::npos){
            if(at<0||at>=int(cells.size()))return {Value(0),Value(0),Value(0),Value(0),Value(0)};
            const int c=cells[at]-1;return {Value(c/6+1),Value(c%6+1),Value(1),Value(0),Value(0)};
        }
        if(code.find("fenghuang:room")!=std::string::npos){
            int a=0,b=0;const auto p=code.find("AskWeekPveMapInfo(");std::sscanf(code.c_str()+p,"AskWeekPveMapInfo(%d,%d)",&a,&b);
            const int cell=a*6+b+1;int ev=-1;for(size_t i=0;i<cells.size()&&i<events.size();++i)if(cells[i]==cell)ev=events[i];
            return {Value(state(cell)),Value(ev)};
        }
        if(code.find("fenghuang:interact")!=std::string::npos){++keyUses;gameDone=true;return {Value(1)};}
        if(code.find("fenghuang:ui")!=std::string::npos){
            const auto p=code.find("Room_Clicked(");
            if(p!=std::string::npos){
                int cell=0;std::sscanf(code.c_str()+p,"Room_Clicked(%d)",&cell);++selects;
                if(!noSelect){for(size_t i=0;i<cells.size();++i)if(cells[i]==cell){at=int(i);gameDone=false;statueDone=false;started=false;hp=100;mechLeft=30;kickFrames=0;x=100;y=90;}}
            }
            if(code.find("Skill_Icon_Btn")!=std::string::npos)++items;
            return {};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(2),Value(std::string(leader?"42\t903\n43\t904\n":"43\t904\n42\t903\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==260&&!noEntry){}return {Value(leader?1:0)};}
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(8001)")!=std::string::npos)return {Value(std::string("冥厄：毒蛊入体"))};
            if(code.find("(8002)")!=std::string::npos)return {Value(std::string("金色印记：x"))};
            if(code.find("(8003)")!=std::string::npos)return {Value(std::string("银月秘钥"))};
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
        if(scene==260)return {"#{FHCL_240708_295}","#{FHCL_240708_6}","#{FHCL_240708_158}","#{FHCL_240708_5}"};
        if(npcName==QString::fromUtf8("杨建月"))return {"#{FHCL_240708_162}"};
        if(npcName==QString::fromUtf8("火凤石雕"))return {"#{FHCL_240708_189}"};
        return {"#{FHCL_240708_76}","#{FHCL_240708_318}","#{FHCL_240708_321}","#{FHCL_240708_331}","#{FHCL_240708_330}"};
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
            if(scene==260&&(label=="#{FHCL_240708_6}"||label=="#{FHCL_240708_158}")){++entries;if(label.endsWith("158}"))++hardEntries;if(!noEntry){scene=999;x=54;y=131;at=-1;}}
            if(label=="#{FHCL_240708_5}")++claims;
            if(label=="#{FHCL_240708_189}"){++statueOpens;if(!noOpen)statueDone=true;}
            if(label.startsWith("#{FHCL_240708_")&&scene==999&&npcName!=QString::fromUtf8("时烈风")&&npcName!=QString::fromUtf8("杨建月")&&npcName!=QString::fromUtf8("火凤石雕")){++opens;if(!noOpen)started=true;}
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
template<class Test>void fenghuangTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](FenghuangFake &h,QJsonObject cfg,std::string &why,const QString &id="dungeon_00322b14"){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("fenghuang_flow_v1"),"Fenghuang has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Fenghuang still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=1200000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"task",id},{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"entries",h.entries},{"opens",h.opens},{"casts",h.casts},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/fenghuang-tests.json");must(progress.open(QIODevice::WriteOnly),"Fenghuang report unavailable");progress.write(QJsonDocument(report).toJson());
        return vm.state();
    };
    auto finished=[&](FenghuangFake &h,QJsonObject cfg,std::string &why,const QString &id="dungeon_00322b14"){
        const auto state=run(h,cfg,why,id);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" at "+std::to_string(h.at)+" gameDone "+std::to_string(h.gameDone)+" pos "+std::to_string(h.x)+","+std::to_string(h.y)+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1800)).c_str());
    };
    auto failed=[&](FenghuangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    auto logged=[](const FenghuangFake &h,const char *s){return h.logText.find(s)!=std::string::npos;};
    test("fenghuang_rooms_count_claim_and_queue",[&]{
        FenghuangFake h;std::string why;finished(h,{},why);
        must(h.entries==1&&h.hardEntries==0&&h.selects==3&&h.opens==2&&h.statueOpens==1&&h.used==1&&h.claims==1,("Fenghuang skipped a stage: entries "+std::to_string(h.entries)+" selects "+std::to_string(h.selects)+" opens "+std::to_string(h.opens)+" statue "+std::to_string(h.statueOpens)+" used "+std::to_string(h.used)+" claims "+std::to_string(h.claims)).c_str());
        must(has(h.attacked,103)&&has(h.attacked,131)&&has(h.attacked,109)&&h.items>=1,"Fenghuang skipped a room");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Fenghuang result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","fenghuang"},{"task","dungeon_00322b14"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,11,5),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Fenghuang receipt did not release next queue item");
    });
    test("fenghuang_hard_settings_and_preconditions",[&]{
        std::string why;
        {FenghuangFake h;finished(h,{},why,"dungeon_0032b023");must(h.hardEntries==1,"Hard entry option not used");}
        {FenghuangFake h;finished(h,{{"fhlm_use_items",false},{"fhlm_claim",false}},why);must(h.items==0&&h.claims==0,"Settings ignored");}
        {FenghuangFake h;h.used=1;finished(h,{},why);must(h.entries==0&&h.claims==1&&h.receipt.contains("already_done"),"Daily limit not respected");}
        {FenghuangFake h;h.full=true;failed(h,{},why);must(h.entries==0,"Full bag entered");}
        {FenghuangFake h;h.together=false;failed(h,{},why);must(h.entries==0,"Scattered team entered");}
        {FenghuangFake h;h.noEntry=true;failed(h,{},why);must(h.entries>=1&&h.entries<=6,"Entry retried beyond the team patience");}
    });
    test("fenghuang_no_feedback_and_wipe",[&]{
        std::string why;
        {FenghuangFake h;h.noOpen=true;failed(h,{},why);must(h.opens==1&&h.receipt.isEmpty(),"Open replayed");}
        {FenghuangFake h;h.noSelect=true;failed(h,{},why);must(h.receipt.isEmpty()&&why.find("杨建月")==std::string::npos,why.c_str());}
        {FenghuangFake h;h.wipe=true;failed(h,{},why);must(why.find("恢复为 NPC")!=std::string::npos,why.c_str());}
        {FenghuangFake h;h.noCount=true;failed(h,{},why);must(why.find("活动次数")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
        {FenghuangFake h;h.stay=true;finished(h,{},why);must(h.receipt.contains(QString::fromUtf8("仍在副本内"))&&h.claims==0,"Stayed result not stated");}
    });
    test("fenghuang_every_room_kind",[&]{
        std::string why;
        auto play=[&](int e,const char *text,bool setBad=false,bool setOrb=false,bool setTraps=false,bool setShade=false){
            FenghuangFake h;h.events={e,9};h.badBuff=setBad;h.orb=setOrb;h.traps=setTraps;h.shade=setShade;finished(h,{},why);
            must(logged(h,text),(std::string("room log missing: ")+text+"\n"+h.logText.substr(0,1000)).c_str());return h;
        };
        play(1,"险中觅宝");play(2,"凤凰奇阵 · 金区域");
        {auto h=play(6,"密匙解匣 · 交给银月凤雕");must(h.keyUses==1,"Key not handed in");}
        play(7,"三元归鼎 · 打风元灵");play(8,"大破火凤阵 · 打傀儡");
        play(4,"岩铸战将 · 躲陷阱",false,false,true);
        play(5,"暗冥乌犍 · 远离队友",true);
        play(10,"霜影 · 战斗");
        play(3,"集火毒花",false,true);
        {FenghuangFake h;h.events={9};h.orb=true;h.shade=true;finished(h,{},why);must(has(h.attacked,120)&&logged(h,"躲凤影"),"Final boss mechanisms missing");}
    });
    test("fenghuang_resume_and_follower",[&]{
        std::string why;
        {FenghuangFake h;h.scene=999;h.x=100;h.y=90;h.at=1;finished(h,{},why);must(h.entries==0&&!has(h.attacked,103)&&has(h.attacked,131),"Resume replayed a room");}
        {FenghuangFake h;h.leader=false;h.noEntry=true;failed(h,{},why);must(h.entries==1,"Follower entry");}
        {FenghuangFake h;h.leader=false;h.scene=999;h.x=100;h.y=90;h.at=0;h.noOpen=true;failed(h,{},why);must(h.opens==0&&h.selects==0,"Follower opened or moved");}
    });
    test("fenghuang_config_validation",[&]{
        auto c=combatTestConfig("dungeon_00322b14");c.insert("combat_scene",999);c.insert("count_fhlm",0);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);
        for(const auto key:{"fhlm_use_items","fhlm_loot","fhlm_claim"})c.insert(key,true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));
        auto bad=c;bad.insert("count_fhlm",25);must(!validateLegacyConfig(bad,e),"Team 25 accepted");
        bad=c;bad.insert("fhlm_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"External engine accepted");
    });
}
}
