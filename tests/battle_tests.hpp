#pragma once
#include "saodang_tests.hpp"
namespace tlbb {
// Battlefields and player fights: a map name per scene, enemy players, and the game's own prompts.
struct PvpFake:SmallFake {
    int enemyHp=100,casts_=0,level=120,school=0,items=0,skills=0,leaves=0,declared=0,appointed=0;std::string map="城市",enemyBuff,selfBuff,enemyName="甲";
    PvpFake(){team=0;}
    std::vector<resident::Object> rows()override{return {};}
    QStringList choices()override{return {};}
    std::string buffs(const std::string &v)override{return v=="-1:-1"?selfBuff:(v=="77:977"?enemyBuff:std::string());}
    virtual void tick(){}
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="position"){tick();return {Value(true),Value(scene),Value(x),Value(y),Value(map)};}
        if(op=="enemy_players"){
            if(enemyHp<=0)return {Value(scene),Value(0),Value(std::string())};
            return {Value(scene),Value(1),Value("77\t977\t"+std::to_string(x+1)+"\t"+std::to_string(y)+"\t"+std::to_string(enemyHp)+"\n")};
        }
        return SmallFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("tactics:level")!=std::string::npos)return {Value(level)};
        if(code.find("tactics:leader")!=std::string::npos)return {Value(-1)};
        if(code.find("pvp:cast")!=std::string::npos){++casts_;enemyHp-=50;return {Value(1)};}
        if(code.find("tactics:skill")!=std::string::npos){++skills;return {Value(1)};}
        if(code.find("dungeon:mission")!=std::string::npos)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
        if(code.find(":hp\n")!=std::string::npos)return {Value(1000)};
        if(code.find("songliao:use")!=std::string::npos){++items;return {Value(0)};}
        if(code.find(":ui\n")!=std::string::npos){
            if(code.find("LeaveTeam")!=std::string::npos){++leaves;team=0;}
            if(code.find("AppointLeader")!=std::string::npos){++appointed;leader=false;}
            return {};
        }
        if(code.find("tuanzhan:name")!=std::string::npos)return {Value(enemyName)};
        if(code.find("tuanzhan:declare")!=std::string::npos){++declared;return {};}
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(9101)")!=std::string::npos)return {Value(std::string("虚弱：所受伤害放大"))};
            if(code.find("(9102)")!=std::string::npos)return {Value(std::string("传送保护：无敌"))};
            return {Value(std::string("其他"))};
        }
        return SmallFake::evaluate(code,f,n);
    }
};
struct SongliaoFake:PvpFake {
    int week=3,entries=0,claims=0,after=0;bool noEntry=false,noOption=false,full=false;
    SongliaoFake(){scene=0;x=307;y=230;}
    QStringList choices()override{
        if(map=="雁门关前哨")return {QString::fromUtf8("退出雁门关前哨")};
        if(noOption)return {};
        return {"#{SLDZ_220216_01","#{SLDZ_100805_03}"};
    }
    void clicked(const QString &l)override{
        if(l=="#{SLDZ_220216_01"){++entries;if(!noEntry){scene=843;map="雁门关前哨";x=36;y=14;}}
        if(l=="#{SLDZ_100805_03}"){++claims;messages+="SLDZ_220216_11\n";}
    }
    void tick()override{
        if(scene==843&&!noEntry){
            if(full){messages+="SLDZ_220216_32\n";full=false;after=-1000;}
            if(after>=0&&++after>3){scene=844;map="宋辽战场一";x=100;y=100;after=0;}
        }
        if(scene==844&&enemyHp<=0&&++after>3){scene=0;map="城市";x=307;y=230;}
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("songliao:week")!=std::string::npos)return {Value(week)};
        return PvpFake::evaluate(code,f,n);
    }
};
struct ChongwuFake:PvpFake {
    int hp=100,entries=0,after=0;bool noOption=false,noEntry=false,hasNpcForm=false;
    ChongwuFake(){scene=9;x=91;y=72;}
    QStringList choices()override{return noOption?QStringList{}:QStringList{QString::fromUtf8("崇武试炼"),QString::fromUtf8("前往参与")};}
    std::vector<resident::Object> rows()override{
        if(map=="崇武试炼"&&hp>0)return {{100,1100,x+1,y,double(hp),true,"乔峰·试炼"}};
        return {};
    }
    void hit(int id)override{if(id==100)hp-=50;}
    void clicked(const QString &l)override{if(l==QString::fromUtf8("前往参与")){++entries;if(!noEntry){scene=900;map="崇武试炼休息室";}}}
    void tick()override{
        if(map=="崇武试炼休息室"&&++after>3){map="崇武试炼";x=95;y=66;after=0;}
        if(map=="崇武试炼"&&hp<=0&&++after>60){scene=9;map="城市";x=91;y=72;messages+="ZMB_230124_137\n";}
    }
};
struct ShijianFake:PvpFake {
    int entries=0,leaves2=0,after=0;bool noOption=false,noEntry=false;
    ShijianFake(){scene=2;x=183;y=102;}
    QStringList choices()override{
        if(scene==900)return {"#{BWDH_180804_71}"};
        return noOption?QStringList{}:QStringList{"#{BWDH_180804_11"};
    }
    void clicked(const QString &l)override{
        if(l=="#{BWDH_180804_11"){++entries;if(!noEntry){scene=900;map="擂台休息室";x=36;y=14;}}
        if(l=="#{BWDH_180804_71}"){if(++leaves2==2){scene=2;map="城市";x=183;y=102;}}
    }
    void tick()override{
        if(scene==900&&enemyHp>0&&++after>3){scene=1019;map="擂台";x=50;y=50;after=0;}
        if(scene==1019&&enemyHp<=0&&++after>3){scene=900;map="擂台休息室";x=36;y=14;messages+="BWDH_180804_66\n";}
    }
};
struct FanzeiFake:PvpFake {
    int kills=0,entries=0,tail=0;bool noNpc=false,noEntry=false,noExit=false,noCount=false;
    FanzeiFake(){scene=3;x=100;y=100;limit=1;}
    std::vector<resident::Object> objects()override{
        if(scene==170&&kills>=2&&!noExit&&std::abs(x-22)<=1&&std::abs(y-97)<=1){scene=3;x=100;y=100;if(!noCount)++used;}
        return rows();
    }
    std::vector<resident::Object> rows()override{
        if(scene==3&&!noNpc)return {{200,1200,x+1,y,100,false,"造反恶贼"}};
        if(scene==170&&kills<2)return {{100+kills,1100+kills,x+1,y,50,true,"反贼"}};
        return {};
    }
    QStringList choices()override{return {QString::fromUtf8("难道我还怕你不成……")};}
    void clicked(const QString &)override{++entries;if(!noEntry){scene=170;x=86;y=91;}}
    void hit(int id)override{if(id>=100&&id<110){++kills;if(kills==2)messages+="已杀死造反恶贼： 31/31\n";}}
};
struct XiaoxiaoFake:PvpFake {
    int kills=0,entries=0,after=0;std::string roster;bool noNpc=false,noCount=false;int home=9;
    XiaoxiaoFake(){scene=9;x=92;y=130;limit=1;}
    std::vector<resident::Object> objects()override{
        if(scene==173&&kills>=2&&++after>5){scene=9;x=92;y=130;if(!noCount)++used;}
        return rows();
    }
    void tick()override{if(appointed&&scene==9&&kills==0&&++after>5){scene=173;x=95;y=125;after=0;}}
    std::vector<resident::Object> rows()override{
        if(scene==home&&!noNpc&&!appointed)return {{200,1200,x+1,y,100,false,"江湖宵小"}};
        if(scene==173&&kills<2)return {{100+kills,1100+kills,x+1,y,50,true,"宵小"}};
        return {};
    }
    QStringList choices()override{return {"#{XMPTX_210712_11}",QString::fromUtf8("难道我还怕你不成……")};}
    void clicked(const QString &l)override{if(l!="#{XMPTX_210712_11}"){++entries;scene=173;x=95;y=125;}}
    void hit(int id)override{if(id>=100&&id<110){++kills;if(kills==2)messages+="离开场景\n";}}
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("xiaoxiao:roster")!=std::string::npos)return {Value(roster)};
        if(code.find("xiaoxiao:leader")!=std::string::npos)return {Value(std::string("甲"))};
        return PvpFake::evaluate(code,f,n);
    }
};
template<class Test>void battleTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    auto run=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);if(!cfg.contains("dungeon_wait_seconds"))cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue(contract),"Missing completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Flow still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=4000000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Completed,((id+" state ").toStdString()+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Failed,((id+" expected a stop: state ").toStdString()+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto verified=[&](SmallFake &h){return TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object());};
    const char *sl="songliao_flow_v1";
    test("songliao_battle",[&]{
        std::string why;
        {SongliaoFake h;finished(h,"songliao",sl,{},why);must(h.entries==1&&h.casts_>0&&h.claims==1&&verified(h),"Battle not run through");must(h.npcName==QString::fromUtf8("郑怀远"),"Wrong NPC for the level");must(h.items==0,"Item used without permission");}
        {SongliaoFake h;finished(h,"songliao",sl,{{"allow_item",true}},why);must(h.items>0,"Items not used with permission");}
        {SongliaoFake h;h.level=95;h.scene=1;h.x=294;h.y=241;finished(h,"songliao",sl,{},why);must(h.npcName==QString::fromUtf8("刘博"),"Level bracket");}
        {SongliaoFake h;finished(h,"songliao",sl,{{"songliao_claim",false}},why);must(h.claims==0,"Claim switch ignored");}
        {SongliaoFake h;h.week=2;failed(h,"songliao",sl,{},why);must(why.find("不是活动日")!=std::string::npos&&h.entries==0,why.c_str());}
        {SongliaoFake h;h.level=50;failed(h,"songliao",sl,{},why);must(why.find("等级")!=std::string::npos,why.c_str());}
        {SongliaoFake h;h.team=3;failed(h,"songliao",sl,{},why);must(why.find("自动退队")!=std::string::npos&&h.entries==0&&h.leaves==0,why.c_str());}
        {SongliaoFake h;h.team=3;finished(h,"songliao",sl,{{"songliao_leave_team",true}},why);must(h.leaves==1&&h.entries==1,"Leave switch");}
        {SongliaoFake h;h.noOption=true;failed(h,"songliao",sl,{},why);must(h.entries==0,why.c_str());}
        {SongliaoFake h;h.noEntry=true;failed(h,"songliao",sl,{},why);must(h.entries==1&&why.find("未重复报名")!=std::string::npos,"Queue resent");}
        {SongliaoFake h;h.enemyBuff="9102";h.enemyHp=100;h.noEntry=false;h.full=false;std::string w;const auto state=run(h,"songliao",sl,{{"dungeon_battle_seconds",30}},w);must(state==resident::Vm::Failed&&h.casts_==0,"Invincible player attacked");}
    });
    test("chongwu_trial",[&]{
        std::string why;const char *c="chongwu_flow_v1";const QString id="orig_0037d84b";
        {ChongwuFake h;finished(h,id,c,{},why);must(h.entries==1&&h.hp<=0&&verified(h),"Trial not run through");must(h.receipt.contains("1"),"Rounds not stated");}
        {ChongwuFake h;h.school=4;h.scene=15;h.x=95;h.y=53;finished(h,id,c,{},why);must(h.npcName==QString::fromUtf8("李十二娘"),"Wrong master");}
        {ChongwuFake h;h.school=9;failed(h,id,c,{},why);must(why.find("报名 NPC")!=std::string::npos,why.c_str());}
        {ChongwuFake h;h.noOption=true;finished(h,id,c,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Closed event");}
        {ChongwuFake h;h.noEntry=true;failed(h,id,c,{},why);must(h.entries==1&&why.find("未重复报名")!=std::string::npos,why.c_str());}
    });
    test("shijian_arena",[&]{
        std::string why;const char *c="shijian_flow_v1";const QString id="orig_0037edf5";
        {ShijianFake h;finished(h,id,c,{},why);must(h.entries==1&&h.casts_>0&&h.leaves2==2&&verified(h),"Arena not run through");must(h.npcName==QString::fromUtf8("擂台指引使"),"Room NPC");}
        {ShijianFake h;h.level=50;failed(h,id,c,{},why);must(why.find("等级")!=std::string::npos,why.c_str());}
        {ShijianFake h;h.noOption=true;failed(h,id,c,{},why);must(h.entries==0,why.c_str());}
        {ShijianFake h;h.noEntry=true;failed(h,id,c,{},why);must(h.entries==1&&why.find("未重复报名")!=std::string::npos,why.c_str());}
    });
    test("fanzei_rounds",[&]{
        std::string why;const char *c="fanzei_flow_v1";const QString id="invasion";const QJsonObject solo{{"dungeon_team_count",1},{"zhk43",1}};
        {FanzeiFake h;finished(h,id,c,solo,why);must(h.entries==1&&h.kills==2&&h.used==1&&verified(h),"Round not run through");}
        {FanzeiFake h;h.used=1;finished(h,id,c,solo,why);must(h.entries==0&&h.receipt.contains("already_done"),"Full count should end");}
        {FanzeiFake h;h.noCount=true;failed(h,id,c,solo,why);must(why.find("不算完成")!=std::string::npos,why.c_str());}
        {FanzeiFake h;h.noNpc=true;failed(h,id,c,solo,why);must(h.entries==0&&why.find("没有找到")!=std::string::npos,why.c_str());}
        {FanzeiFake h;h.noEntry=true;failed(h,id,c,solo,why);must(h.entries==1&&why.find("未重复发送")!=std::string::npos,why.c_str());}
        {FanzeiFake h;h.noExit=true;failed(h,id,c,solo,why);must(why.find("出口")!=std::string::npos,why.c_str());}
    });
    test("xiaoxiao_rounds_and_leader_switch",[&]{
        std::string why;const char *c="xiaoxiao_flow_v1";const QString id="xiaoxiao";
        {XiaoxiaoFake h;finished(h,id,c,{},why);must(h.entries==1&&h.kills==2&&h.used==1&&verified(h),"Round not run through");}
        {XiaoxiaoFake h;h.used=1;finished(h,id,c,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Full count should end");}
        {XiaoxiaoFake h;h.noCount=true;failed(h,id,c,{},why);must(why.find("不算完成")!=std::string::npos,why.c_str());}
        {XiaoxiaoFake h;h.noNpc=true;failed(h,id,c,{},why);must(why.find("没有找到")!=std::string::npos,why.c_str());}
        // 宵小 raid 少林 while the leader is 明教: needs the switch before anything changes hands.
        {XiaoxiaoFake h;h.school=1;h.team=2;h.roster="1\n0\n";h.scene=11;h.x=98;h.y=149;failed(h,id,c,{},why);must(why.find("自动交队长")!=std::string::npos&&h.appointed==0,why.c_str());}
        {XiaoxiaoFake h;h.school=1;h.team=2;h.roster="1\n0\n";h.scene=11;h.x=98;h.y=149;finished(h,id,c,{{"xiaoxiao_change_leader",true}},why);must(h.appointed==1&&h.entries==0&&h.used==1,"Handover not followed");}
    });
    test("jiaxue_support",[&]{
        std::string why;const char *c="jiaxue_flow_v1";const QString id="heal_support";
        {PvpFake h;h.school=4;h.scene=0;h.x=100;h.y=100;finished(h,id,c,{{"jiaxue_minutes",1}},why);must(verified(h)&&h.skills==0,"Ran with reactions off");}
        {PvpFake h;h.school=4;h.scene=0;h.x=100;h.y=100;h.selfBuff="9101";finished(h,id,c,{{"jiaxue_minutes",1},{"xzk07",true}},why);must(h.skills>0,"呆若木鸡 not used");}
        {PvpFake h;h.school=4;h.scene=0;h.x=100;h.y=100;finished(h,id,c,{{"jiaxue_minutes",1},{"xzk106",true}},why);must(h.skills>0,"月落西山 not used");}
        {PvpFake h;h.scene=0;failed(h,id,c,{{"jiaxue_minutes",1}},why);must(why.find("峨嵋")!=std::string::npos,why.c_str());}
    });
    test("tuanzhan_targets",[&]{
        std::string why;const char *c="tuanzhan_flow_v1";const QString id="pvp";
        auto fake=[](PvpFake &h){h.scene=0;h.x=100;h.y=100;};
        {PvpFake h;fake(h);finished(h,id,c,{{"tuanzhan_minutes",1},{"xzk221",true}},why);must(h.casts_>0&&verified(h),"全杀 did not attack");}
        {PvpFake h;fake(h);h.enemyBuff="9102";finished(h,id,c,{{"tuanzhan_minutes",1},{"xzk221",true}},why);must(h.casts_==0,"Invincible player attacked");}
        {PvpFake h;fake(h);finished(h,id,c,{{"tuanzhan_minutes",1},{"xzk222",true},{"bjk156",QString::fromUtf8("甲 乙")}},why);must(h.casts_>0,"Listed player not attacked");}
        {PvpFake h;fake(h);finished(h,id,c,{{"tuanzhan_minutes",1},{"xzk222",true},{"bjk156",QString::fromUtf8("丙")}},why);must(h.casts_==0,"Unlisted player attacked");}
        {PvpFake h;fake(h);failed(h,id,c,{{"tuanzhan_minutes",1}},why);must(why.find("不会攻击")!=std::string::npos&&h.casts_==0,why.c_str());}
    });
    test("battle_config_validation",[&]{
        QString e;
        QJsonObject a{{"legacy_id","songliao"},{"timeout_seconds",7200},{"combat",true},{"combat_scene",3},{"combat_min_hp",25},{"combat_radius",45},{"combat_interval_ms",1000},{"combat_stall_seconds",60},{"combat_kill_goal",1},{"combat_skills",""},{"entry_mode","自动入场"},{"dungeon_wait_seconds",45},{"dungeon_battle_seconds",3600},{"songliao_leave_team",false},{"songliao_claim",true}};
        const bool validA=validateLegacyConfig(a,e);must(validA,e.toUtf8().constData());
        auto bad=a;bad.insert("dungeon_battle_seconds",5);must(!validateLegacyConfig(bad,e),"Short limit accepted");
        bad=a;bad.insert("songliao_leave_team","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
        QJsonObject b{{"legacy_id","pvp"},{"timeout_seconds",7200},{"combat",true},{"combat_scene",3},{"combat_min_hp",25},{"combat_radius",45},{"combat_interval_ms",1000},{"combat_stall_seconds",60},{"combat_kill_goal",1},{"combat_skills",""},{"entry_mode","自动入场"},{"tuanzhan_minutes",60},{"bjk38",8}};
        const bool validB=validateLegacyConfig(b,e);must(validB,e.toUtf8().constData());
        bad=b;bad.insert("tuanzhan_minutes",0);must(!validateLegacyConfig(bad,e),"Zero minutes accepted");
        QJsonObject d{{"legacy_id","invasion"},{"timeout_seconds",7200},{"combat",true},{"combat_scene",170},{"combat_min_hp",25},{"combat_radius",45},{"combat_interval_ms",1000},{"combat_stall_seconds",60},{"combat_kill_goal",1},{"combat_skills",""},{"entry_mode","自动入场"},{"dungeon_rounds",20},{"dungeon_wait_seconds",45},{"dungeon_battle_seconds",3600},{"dungeon_team_count",3},{"zhk43",0}};
        const bool validD=validateLegacyConfig(d,e);must(validD,e.toUtf8().constData());
        bad=d;bad.insert("zhk43",9);must(!validateLegacyConfig(bad,e),"Unknown map accepted");
    });
}
}
