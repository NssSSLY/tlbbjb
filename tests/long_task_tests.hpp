#pragma once
#include "battle_tests.hpp"
namespace tlbb {
// 师门: a mission with typed variables, handed in at the school's NPC. School 2 (丐帮): 洪通 at (91,77,10).
struct ShimenFake:PvpFake {
    struct M{int kind=0,status=0,id=500,script=229000;int v5=0,v6=0,v7=0;std::string desc;};
    bool has=false;M m;std::vector<M> queue;int abandons=0,handins=0,accepts=0,buys=0,usesItem=0,opened=0,catches=0,gives=0,noTool=0;
    bool shopHas=true,petPresent=true,hasCollectable=true,dailyFull=false,noAccept=false,noHandIn=false;int petCount=1;
    ShimenFake(){scene=10;x=91;y=77;school=2;leader=true;}
    void next(){if(queue.empty()){has=false;return;}m=queue.front();queue.erase(queue.begin());}
    QStringList choices()override{
        if(dailyFull)return {QString::fromUtf8("师门任务")};
        return {QString::fromUtf8("师门任务"),QString::fromUtf8("买"),QString::fromUtf8("卖"),QString::fromUtf8("酒窖"),QString::fromUtf8("投机取巧"),QString::fromUtf8("确定")};
    }
    void clicked(const QString &l)override{
        if(l==QString::fromUtf8("师门任务")){
            if(has&&m.kind==0&&m.status==0&&scene==1){m.status=1;return;}
            if(!has&&!dailyFull&&!noAccept&&!queue.empty()){++accepts;has=true;next();has=true;}
        }
    }
    void button(int)override{}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;
        if(has&&m.kind==6&&m.status==0&&scene==10&&hasCollectable)r.push_back({300,1300,x+1,y,100,false,"小青蛇"});
        if(has&&m.kind==5&&m.status==0&&scene==5)r.push_back({301,1301,x+1,y,100,true,"山猪"});
        if(scene==700&&fubenHp>0)r.push_back({302,1302,x+1,y,double(fubenHp),true,"酒鬼"});
        return r;
    }
    int fubenHp=0;
    void hit(int id)override{if(id==302){fubenHp-=50;if(fubenHp<=0&&has)m.status=1;}}
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="open_object"){++opened;if(has)m.status=1;return {Value(1)};}
        return PvpFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("dungeon:mission")!=std::string::npos){
            if(!has)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
            return {Value(3),Value(m.id),Value(m.status),Value(m.desc)};
        }
        if(code.find("shimen:vars")!=std::string::npos)return {Value(m.status),Value(0),Value(0),Value(0),Value(m.kind),Value(m.v5),Value(m.v6),Value(m.v7)};
        if(code.find("shimen:script")!=std::string::npos)return {Value(m.script)};
        if(code.find("shimen:dialog-all")!=std::string::npos)return {Value(dailyFull?std::string("今日已经完成60次"):std::string("师门"))};
        if(code.find("shimen:state")!=std::string::npos)return {Value(0)};
        if(code.find("shimen:petbar")!=std::string::npos)return {Value(petCount),Value(100),Value(0)};
        if(code.find("shimen:buy")!=std::string::npos){if(!shopHas)return {Value(0)};++buys;m.status=1;return {Value(1)};}
        if(code.find("shimen:use")!=std::string::npos){if(noTool)return {Value(0)};++usesItem;m.status=1;return {Value(1)};}
        if(code.find("shimen:pet")!=std::string::npos){if(!petPresent)return {Value(-1)};++gives;return {Value(2)};}
        if(code.find("shimen:loot")!=std::string::npos)return {};
        if(code.find("shimen:ui")!=std::string::npos){
            if(code.find("QuestFrameMissionAbnegate")!=std::string::npos){++abandons;has=false;}
            if(code.find("MissionReply_Accept_Clicked")!=std::string::npos){++handins;has=false;}
            return {};
        }
        if(code.find("tactics:skill")!=std::string::npos){++catches;if(has)m.status=1;return {Value(1)};}
        return PvpFake::evaluate(code,f,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        if(id==gameplay::QuestButton&&has&&m.status==1&&!noHandIn&&a.ints[0]==2){++handins;has=false;}
        return SmallFake::snippet(id,a);
    }
};
// 刷马贼: one green bandit near the route on 嵩山 that a talk turns hostile.
struct MazeiFake:PvpFake {
    int kills=0,talks=0,hp=100;bool hostile=false,mute=false,higher=false;
    MazeiFake(){scene=3;x=56;y=57;}
    std::vector<resident::Object> rows()override{
        if(scene!=3||kills>0||higher)return {};
        return {{100,1100,x+1,y,double(hp),hostile,"夺宝马贼"}};
    }
    QStringList choices()override{return {QString::fromUtf8("开启战斗")};}
    void clicked(const QString &)override{++talks;if(!mute)hostile=true;}
    void hit(int id)override{if(id==100){hp-=50;if(hp<=0)kills=1;}}
};
// 主线 and 新手: the table's first missions, played on the game's own outline list.
struct QuestFake:PvpFake {
    struct M{std::string name;int status=0;};
    std::vector<M> hand;std::vector<std::string> outlineNames;int accepts=0,handins=0,kills=0,hp=100;bool noAccept=false,noHandIn=false,outlineBroken=false;std::string killName;int abandon=0,level=30;
    bool onlyAtPoint=false,talkCompletes=false;
    QuestFake(){team=0;}
    std::vector<resident::Object> rows()override{
        if(killName.empty()||hand.empty()||hand[0].status!=0)return {};
        if(onlyAtPoint&&(std::abs(x-273)>1||std::abs(y-156)>1))return {};
        return {{100,1100,x+1,y,double(hp),true,killName}};
    }
    QStringList choices()override{QStringList o;for(const auto &n:outlineNames)o<<QString::fromStdString(n);for(const auto &m:hand)o<<QString::fromStdString(m.name);return o;}
    void clicked(const QString &l)override{
        const auto n=l.toStdString();
        for(auto &m:hand)if(m.name==n&&(m.status==1||talkCompletes)){if(!noHandIn){hand.erase(std::find_if(hand.begin(),hand.end(),[&](const M&v){return v.name==n;}));++handins;}return;}
        for(size_t i=0;i<outlineNames.size();++i)if(outlineNames[i]==n&&!noAccept){hand.push_back({n,0});outlineNames.erase(outlineNames.begin()+long(i));++accepts;return;}
    }
    void hit(int id)override{if(id==100){hp-=50;if(hp<=0&&!hand.empty()){hand[0].status=1;hp=100;}}}
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("questbook:missions")!=std::string::npos){
            std::string t;int slot=0;
            for(const auto &m:hand){t+=std::to_string(slot)+"\t500\t229000\t"+std::to_string(m.status)+"\t"+m.name+"\n";++slot;}
            return {Value(t)};
        }
        if(code.find("questbook:outline")!=std::string::npos){
            if(outlineBroken)return {Value(0)};
            std::string t;for(const auto &o:outlineNames)t+=o+"\1\n";
            return {Value(t)};
        }
        if(code.find("questbook:var")!=std::string::npos)return {Value(0)};
        if(code.find("questbook:state")!=std::string::npos)return {Value(0)};
        if(code.find("questbook:bag")!=std::string::npos)return {Value(std::string())};
        if(code.find("questbook:data")!=std::string::npos)return {Value(level)};
        if(code.find("questbook:abandon")!=std::string::npos){++abandon;if(!hand.empty())hand.erase(hand.begin());return {};}
        if(code.find("xinshou:levelup")!=std::string::npos)return {Value(0)};
        return PvpFake::evaluate(code,f,n);
    }
};
template<class Test>void longTaskTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    auto run=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why,uint64_t limit=8000000){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);if(!cfg.contains("dungeon_wait_seconds"))cfg.insert("dungeon_wait_seconds",5);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue(contract),"Missing completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Flow still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=limit&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Completed,((id+" state ").toStdString()+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1800)).c_str());
    };
    auto failed=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Failed,((id+" expected a stop: state ").toStdString()+std::to_string(int(state))+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto verified=[&](SmallFake &h){return TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object());};
    const char *sm="shimen_flow_v1";const QJsonObject one{{"bjk29",1}};
    using M=ShimenFake::M;
    auto typed=[](int kind,const std::string &desc="",int v5=0,int v6=0,int v7=0){M m;m.kind=kind;m.desc=desc;m.v5=v5;m.v6=v6;m.v7=v7;return m;};
    test("mazei_rounds",[&]{
        std::string why;const char *c="mazei_flow_v1";const QString id="bandits";const QJsonObject base{{"xzk1",true},{"mazei_minutes",1},{"dungeon_team_count",1},{"bjk91",0}};
        {MazeiFake h;finished(h,id,c,base,why);must(h.talks>=1&&h.kills==1&&verified(h),"Bandit not killed");}
        {MazeiFake h;h.mute=true;finished(h,id,c,base,why);must(h.kills==0&&h.talks>=2,"Mute bandit should be retried only after a pause");}
        {MazeiFake h;failed(h,id,c,{{"mazei_minutes",1}},why);must(why.find("没有勾选")!=std::string::npos,why.c_str());}
        {MazeiFake h;auto cfg=base;cfg.insert("dungeon_team_count",3);failed(h,id,c,cfg,why);must(why.find("少于")!=std::string::npos&&h.talks==0,why.c_str());}
    });
    test("quest_book_main_line",[&]{
        std::string why;const char *c="zhuxian_flow_v1";const QString id="mainline";
        auto first=[](QuestFake &h){h.scene=20;h.x=163;h.y=158;h.outlineNames={"草原的劫匪"};h.killName="弯刀马匪";};
        {QuestFake h;first(h);finished(h,id,c,{},why);must(h.accepts==1&&h.handins==1&&verified(h)&&h.receipt.contains("1"),"Mission not played through");}
        {QuestFake h;first(h);h.onlyAtPoint=true;finished(h,id,c,{},why);must(h.handins==1,"Patrol did not walk to the mission's point");}
        {QuestFake h;h.scene=20;finished(h,id,c,{},why);must(h.accepts==0&&h.receipt.contains("already_done"),"Nothing to do");}
        {QuestFake h;first(h);h.noHandIn=true;failed(h,id,c,{},why);must(why.find("5 次")!=std::string::npos,why.c_str());}
        {QuestFake h;first(h);h.noAccept=true;finished(h,id,c,{},why);must(h.accepts==0&&h.receipt.contains("already_done"),"Refused mission should be passed over");}
        {QuestFake h;first(h);h.outlineBroken=true;failed(h,id,c,{},why);must(why.find("大纲")!=std::string::npos,why.c_str());}
        {QuestFake h;first(h);h.hand.push_back({"草原的劫匪",2});h.outlineNames.clear();failed(h,id,c,{},why);must(why.find("允许放弃")!=std::string::npos&&h.abandon==0,why.c_str());}
        {QuestFake h;first(h);finished(h,id,c,{{"zhuxian_skip",QString::fromUtf8("草原的劫匪")}},why);must(h.accepts==0,"Skipped mission taken");}
    });
    test("quest_book_novice",[&]{
        std::string why;const char *c="xinshou_flow_v1";const QString id="novice_1_40";
        {QuestFake h;h.level=40;h.scene=6;finished(h,id,c,{},why);must(h.receipt.contains("already_done"),"Nothing to do");}
        {QuestFake h;h.level=20;finished(h,id,c,{{"xinshou_level",20}},why);must(verified(h)&&h.accepts==0,"Level limit should end the run");}
        {QuestFake h;h.level=5;h.school=9;h.outlineNames={"加入门派"};h.scene=2;failed(h,id,c,{},why);must(why.find("门派")!=std::string::npos&&h.accepts==0,why.c_str());}
    });
    test("revive_modes",[&]{
        std::string why;const char *c="mazei_flow_v1";const QString id="bandits";const QJsonObject base{{"xzk1",true},{"mazei_minutes",1},{"dungeon_team_count",1},{"bjk91",0},{"revive_wait_seconds",5}};
        struct DeadFake:MazeiFake {
            int state=9,relives=0,ghosts=0,rescueAfter=-1,calls=0;bool stayDead=false;
            resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
                using resident::Value;
                if(code.find("dungeon:player-state")!=std::string::npos){if(rescueAfter>=0&&++calls>rescueAfter)state=0;return {Value(state)};}
                if(code.find("dungeon:relive-accept")!=std::string::npos){++relives;return {};}
                if(code.find("dungeon:relive-out")!=std::string::npos){++ghosts;if(!stayDead){state=0;scene=77;x=15;y=25;}return {};}
                return MazeiFake::evaluate(code,f,n);
            }
            QStringList choices()override{return scene==77?QStringList{QString::fromUtf8("洛阳")}:MazeiFake::choices();}
            void clicked(const QString &l)override{if(l==QString::fromUtf8("洛阳")){scene=0;x=100;y=100;return;}MazeiFake::clicked(l);}
        };
        {DeadFake h;h.low=true;failed(h,id,c,base,why);must(why.find("血量")!=std::string::npos&&h.relives==0&&h.ghosts==0,"Stop mode acted on death");}
        {DeadFake h;h.rescueAfter=4;auto cfg=base;cfg.insert("revive_mode",QString::fromUtf8("等待救援"));finished(h,id,c,cfg,why);must(h.relives>0&&h.ghosts==0&&h.kills==1,"Rescue not followed by the task");}
        {DeadFake h;auto cfg=base;cfg.insert("revive_mode",QString::fromUtf8("等待救援"));failed(h,id,c,cfg,why);must(why.find("等待救援超时")!=std::string::npos&&h.ghosts==0,why.c_str());}
        {DeadFake h;auto cfg=base;cfg.insert("revive_mode",QString::fromUtf8("等待后出窍回城"));finished(h,id,c,cfg,why);must(h.ghosts==1&&h.scene!=77&&h.kills==1,"Open-world task should carry on after walking out");}
        {DeadFake h;h.stayDead=true;auto cfg=base;cfg.insert("revive_mode",QString::fromUtf8("等待后出窍回城"));failed(h,id,c,cfg,why);must(why.find("仍处于死亡")!=std::string::npos,why.c_str());}
    });
    test("shimen_mission_types",[&]{
        std::string why;
        const std::string talk="去找#{_INFOAIM100,100,1,张三}对话";
        {ShimenFake h;h.queue={typed(0,talk)};finished(h,"shimen",sm,one,why);must(h.accepts==1&&h.handins==1&&verified(h)&&h.receipt.contains("1"),"Talk mission");}
        {ShimenFake h;h.queue={typed(1,"#Y馒头#W 找 #{_INFOAIM10,10,1,店主}")};finished(h,"shimen",sm,{{"bjk29",1},{"allow_spend",true}},why);must(h.buys==1&&h.handins==1,"Shop mission");}
        {ShimenFake h;h.queue={typed(3,"",0,1,0)};finished(h,"shimen",sm,one,why);must(h.usesItem==1&&h.handins==1,"Tool mission");}
        {ShimenFake h;h.queue={typed(6,"",7)};finished(h,"shimen",sm,one,why);must(h.opened==1&&h.handins==1,"Collect mission");}
    });
    test("shimen_risk_switches",[&]{
        std::string why;
        {ShimenFake h;h.queue={typed(2)};failed(h,"shimen",sm,one,why);must(why.find("允许放弃")!=std::string::npos&&h.abandons==0,why.c_str());}
        {ShimenFake h;h.queue={typed(1,"#Y馒头#W 找 #{_INFOAIM10,10,1,店主}")};failed(h,"shimen",sm,one,why);must(why.find("允许放弃")!=std::string::npos&&h.buys==0,"Bought without permission");}
        {ShimenFake h;h.queue={typed(2),typed(3,"",0,1,0)};finished(h,"shimen",sm,{{"bjk29",1},{"shimen_abandon",true}},why);must(h.abandons==1&&h.handins==1,"Abandon then next");}
        {ShimenFake h;h.petCount=6;failed(h,"shimen",sm,one,why);must(why.find("珍兽栏已满")!=std::string::npos,why.c_str());}
        {ShimenFake h;h.petCount=6;h.queue={typed(3,"",0,1,0)};finished(h,"shimen",sm,{{"bjk29",1},{"xzk187",true}},why);must(h.handins==1,"Pet-free run");}
    });
    test("shimen_stops",[&]{
        std::string why;
        {ShimenFake h;h.dailyFull=true;finished(h,"shimen",sm,one,why);must(h.receipt.contains("already_done"),"Full day");}
        {ShimenFake h;h.noAccept=true;h.queue={typed(0)};failed(h,"shimen",sm,one,why);must(why.find("3 次")!=std::string::npos,why.c_str());}
        {ShimenFake h;h.noHandIn=true;h.queue={typed(3,"",0,1,0)};failed(h,"shimen",sm,one,why);must(why.find("3 次")!=std::string::npos,why.c_str());}
        {ShimenFake h;h.noTool=1;h.queue={typed(3,"",0,1,0)};failed(h,"shimen",sm,one,why);must(why.find("任务栏没有")!=std::string::npos,why.c_str());}
        {ShimenFake h;h.school=9;h.queue={typed(0)};failed(h,"shimen",sm,one,why);must(why.find("师门 NPC")!=std::string::npos,why.c_str());}
    });
    test("shimen_config_validation",[&]{
        QJsonObject c{{"legacy_id","shimen"},{"timeout_seconds",7200},{"combat",true},{"combat_scene",3},{"combat_min_hp",25},{"combat_radius",45},{"combat_interval_ms",1000},{"combat_stall_seconds",60},{"combat_kill_goal",1},{"combat_skills",""},{"entry_mode","自动入场"},
            {"bjk29",60},{"dungeon_wait_seconds",45},{"shimen_minutes",115},{"shimen_abandon",false},{"shimen_tjqq",false},{"xzk56",false},{"xzk187",false}};QString e;
        const bool ok=validateLegacyConfig(c,e);must(ok,e.toUtf8().constData());
        auto bad=c;bad.insert("bjk29",0);must(!validateLegacyConfig(bad,e),"Zero rounds accepted");
        bad=c;bad.insert("shimen_abandon","yes");must(!validateLegacyConfig(bad,e),"String switch accepted");
    });
}
}
