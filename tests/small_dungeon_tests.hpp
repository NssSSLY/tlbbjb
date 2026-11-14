#pragma once
#include "juling_tests.hpp"
namespace tlbb {
// Shared plumbing for the short flows below: dialog, team and object answers.
struct SmallFake:ResidentFake {
    QString page="closed",npcName,receipt;std::vector<int> attacked;std::string messages;
    int team=3,used=0,limit=1,bag=5;bool leader=true,together=true;
    virtual std::vector<resident::Object> rows()=0;
    virtual QStringList choices()=0;
    virtual void clicked(const QString &){}
    virtual void hit(int){}
    virtual void button(int){}
    virtual std::string buffs(const std::string &){return {};}
    std::vector<resident::Object> objects()override{return rows();}
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string("场景"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="mechanism_snapshot")return {Value(scene),Value(0),Value(std::string())};
        if(op=="object_buff_ids"){const auto b=buffs(v);return {Value(b.empty()?0:1),Value(b)};}
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("shaoshi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("shaoshi:campaign")!=std::string::npos)return {Value(used),Value(limit),Value(0),Value(1)};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(0)};
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(leader?1:0)};
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(-1),Value(123),Value(456)};
        if(code.find("dialog-all")!=std::string::npos)return {Value(page=="closed"?std::string():choices().join('\n').toStdString())};
        if(code.find("dungeon:dialog")!=std::string::npos){
            const auto opts=page=="closed"?QStringList{}:choices();
            return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        switch(id){
        case gameplay::BagSpace:return {Value(bag)};
        case gameplay::TeamCount:return {Value(team)};
        case gameplay::CloseAll:page="closed";return {Value(1)};
        case gameplay::NpcTarget:page="menu";npcName=QString::fromWCharArray(a.text);return {Value(1)};
        case gameplay::RunTo:scene=a.ints[0];x=a.reals[0];y=a.reals[1];return {Value(1)};
        case gameplay::QuestButton:if(page!="closed")button(a.ints[0]);return {Value(0)};
        case gameplay::QuestOption:{
            const auto label=QString::fromWCharArray(a.text);
            if(!choices().contains(label))return {Value(0)};
            clicked(label);return {Value(1),Value(label.toStdString())};
        }
        case gameplay::DebugMessages:return {Value(8),Value(messages)};
        case gameplay::CombatScan:{
            for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        case gameplay::CombatCast:++casts;attacked.push_back(a.ints[1]);hit(a.ints[1]);return {Value(1)};
        default:return ResidentFake::snippet(id,a);
        }
    }
};
struct CujuFake:SmallFake {
    int mobHp=100,delivered=0,entries=0,noExit=0;bool ball=false,noEntry=false,knocked=false,done=false;int knockLeft=20;
    CujuFake(){scene=1;x=283;y=241;}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;if(scene!=233)return r;
        if(mobHp>0)r.push_back({100,1100,x+1,y,double(mobHp),true,"持球球员"});
        r.push_back({101,1101,37,31,100,false,"于倩倩"});return r;
    }
    QStringList choices()override{return scene==233?QStringList{QString::fromUtf8("送")}:QStringList{QString::fromUtf8("横扫牡丹碗")};}
    void hit(int id)override{if(id==100){mobHp-=50;if(mobHp<=0)ball=true;}}
    void clicked(const QString &l)override{
        if(l==QString::fromUtf8("横扫牡丹碗")){++entries;if(!noEntry){scene=233;x=30;y=30;}}
        if(l==QString::fromUtf8("送")){++delivered;ball=false;done=true;}
    }
    std::string buffs(const std::string &v)override{if(v!="-1:-1")return {};if(knocked&&knockLeft-->0)return "9101";return ball?"9102":std::string();}
    std::vector<resident::Object> objects()override{
        if(done&&++noExit>6){scene=1;x=283;y=241;done=false;}
        return rows();
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("dungeon:buff-names")!=std::string::npos){
            if(code.find("(9101)")!=std::string::npos)return {Value(std::string("被打醒"))};
            if(code.find("(9102)")!=std::string::npos)return {Value(std::string("蹴鞠光环"))};
            return {Value(std::string("其他"))};
        }
        return SmallFake::evaluate(code,f,n);
    }
};
struct ShuaxiangFake:SmallFake {
    int kills=0,bossHp=100,entries=0,frames=0;bool noEntry=false,noCount=false,wrongTime=false,hard=false,quick=false,noExit=false;
    ShuaxiangFake(){scene=246;x=162;y=75;}
    std::vector<resident::Object> objects()override{
        if(scene==269&&bossHp<=0&&!noExit&&++frames>30){scene=246;x=162;y=75;if(!noCount)++used;}
        return rows();
    }
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;if(scene!=269)return r;
        if(kills<2)r.push_back({100+kills,1100+kills,x+1,y,100,true,"楼兰守卫"});
        else r.push_back({110,1110,63,78,double(bossHp),true,"镇宝龙王"});
        return r;
    }
    QStringList choices()override{
        if(wrongTime)return {"#{LLXB_8815_09}"};
        return {QString::fromUtf8("楼兰寻宝"),"#{LLXB_8815_25}","#{LLXB_8815_26}"};
    }
    void hit(int id)override{
        if(id>=100&&id<110){++kills;if(kills==2)messages+="已杀死怪物 200/200\n";return;}
        if(id==110)bossHp-=50;
    }
    void clicked(const QString &l)override{
        if(l=="#{LLXB_8815_25}"||l=="#{LLXB_8815_26}"){++entries;quick=l.endsWith("26}");if(!noEntry){scene=269;x=63;y=77;}}
    }
};
struct TianlongFake:SmallFake {
    int status=-1,kills=0,entries=0,starts=0,leaves=0,handIn=0,accepts=0,tokens=1;bool waves=false,noEntry=false,noStart=false,noLeave=false,noOffer=false;
    TianlongFake(){scene=246;x=171;y=120;}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;if(scene!=300)return r;
        if(waves&&kills<240)r.push_back({100,1100,x+1,y,50,true,"幻境怪物"});
        r.push_back({101,1101,64,57,100,false,"若梦"});return r;
    }
    QStringList choices()override{
        if(scene==300)return {"#{TLHJ_120110_29}","#{TLHJ_120110_34}","#{TLHJ_120110_30}","#{INTERFACE_XML_557}"};
        QStringList o;if(!noOffer)o<<"#{TLHJ_120110_62}";o<<"#{TLHJ_120110_02}";return o;
    }
    void hit(int id)override{
        if(id!=100)return;
        kills+=80;messages+="已杀 "+std::to_string(kills)+"/240\n";
        if(kills>=240)status=1;
    }
    void button(int kind)override{
        if(kind==1){++accepts;status=0;}
        if(kind==3&&status==1){++handIn;status=-1;}
    }
    void clicked(const QString &l)override{
        if(l=="#{TLHJ_120110_02}"){++entries;if(!noEntry){--tokens;scene=300;x=64;y=50;}}
        if(l=="#{TLHJ_120110_29}"){++starts;if(!noStart)waves=true;}
        if(l=="#{INTERFACE_XML_557}"){++leaves;if(!noLeave){scene=246;x=171;y=120;}}
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("tianlong:tokens")!=std::string::npos)return {Value(tokens)};
        if(code.find("dungeon:mission")!=std::string::npos){
            if(status<0)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
            return {Value(3),Value(777),Value(status),Value(std::string("幻境"))};
        }
        return SmallFake::evaluate(code,f,n);
    }
};
template<class Test>void smallDungeonTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    auto run=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue(contract),"Missing completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Flow still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=800000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int id){return std::count(v.begin(),v.end(),id)>0;};
    const QString cuju="dungeon_0031bd09",box="dungeon_002b9e15",tl="dungeon_002ee7ae";
    test("cuju_full_flow_and_stops",[&]{
        std::string why;
        {CujuFake h;finished(h,cuju,"cuju_flow_v1",{},why);must(h.entries==1&&has(h.attacked,100)&&h.delivered==1,"Cuju skipped a stage");must(TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object()),"Cuju result not verified");}
        {CujuFake h;h.knocked=true;finished(h,cuju,"cuju_flow_v1",{},why);must(h.logText.find("被打醒")!=std::string::npos,"Knocked state ignored");}
        {CujuFake h;h.scene=0;h.x=301;h.y=192;finished(h,cuju,"cuju_flow_v1",{},why);must(h.npcName==QString::fromUtf8("于倩倩"),"Receiver talk");}
        {CujuFake h;h.noEntry=true;failed(h,cuju,"cuju_flow_v1",{},why);must(h.entries==1,"Entry replayed");}
        {CujuFake h;h.together=false;failed(h,cuju,"cuju_flow_v1",{},why);must(h.entries==0,"Scattered team entered");}
        {CujuFake h;h.leader=false;h.noEntry=true;failed(h,cuju,"cuju_flow_v1",{},why);must(h.entries==0,"Follower signed up");}
    });
    test("shuaxiang_full_flow_and_stops",[&]{
        std::string why;
        {ShuaxiangFake h;finished(h,box,"shuaxiang_flow_v1",{},why);must(h.entries==1&&h.kills==2&&has(h.attacked,110)&&h.used==1&&!h.quick,"Box run skipped a stage");must(TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object()),"Box result not verified");}
        {ShuaxiangFake h;finished(h,box,"shuaxiang_flow_v1",{{"xzk190",true}},why);must(h.quick,"Quick option ignored");}
        {ShuaxiangFake h;h.used=1;finished(h,box,"shuaxiang_flow_v1",{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Limit not respected");}
        {ShuaxiangFake h;h.wrongTime=true;failed(h,box,"shuaxiang_flow_v1",{},why);must(why.find("活动时间")!=std::string::npos,why.c_str());}
        {ShuaxiangFake h;h.noEntry=true;failed(h,box,"shuaxiang_flow_v1",{},why);must(h.entries==1,"Entry replayed");}
        {ShuaxiangFake h;h.noCount=true;failed(h,box,"shuaxiang_flow_v1",{},why);must(why.find("活动次数")!=std::string::npos,why.c_str());}
    });
    test("tianlong_full_flow_and_stops",[&]{
        std::string why;const QJsonObject item{{"allow_item",true}};
        {TianlongFake h;finished(h,tl,"tianlong_flow_v1",item,why);must(h.accepts==1&&h.entries==1&&h.starts==1&&h.leaves==1&&h.handIn==1&&h.tokens==0,"Tianlong skipped a stage");must(TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object()),"Tianlong result not verified");}
        {TianlongFake h;failed(h,tl,"tianlong_flow_v1",{},why);must(why.find("允许物品处理")!=std::string::npos&&h.entries==0,why.c_str());}
        {TianlongFake h;h.tokens=0;failed(h,tl,"tianlong_flow_v1",item,why);must(why.find("试炼令牌")!=std::string::npos&&h.entries==0,why.c_str());}
        {TianlongFake h;h.noOffer=true;finished(h,tl,"tianlong_flow_v1",item,why);must(h.receipt.contains("already_done"),"No offer should end");}
        {TianlongFake h;h.status=2;failed(h,tl,"tianlong_flow_v1",item,why);must(why.find("手动放弃")!=std::string::npos,why.c_str());}
        {TianlongFake h;h.noEntry=true;failed(h,tl,"tianlong_flow_v1",item,why);must(h.entries==1,"Entry replayed");}
        {TianlongFake h;h.noStart=true;h.status=0;h.scene=300;h.x=64;h.y=57;failed(h,tl,"tianlong_flow_v1",item,why);must(h.starts==1,"Start replayed");}
        {TianlongFake h;h.noLeave=true;failed(h,tl,"tianlong_flow_v1",item,why);must(h.leaves==3&&h.receipt.isEmpty(),"Leave not bounded");}
        {TianlongFake h;h.status=1;finished(h,tl,"tianlong_flow_v1",item,why);must(h.entries==0&&h.handIn==1,"Finished mission not handed in");}
    });
    test("small_dungeon_config_validation",[&]{
        QString e;
        for(const auto &id:{cuju,box,tl}){
            auto c=combatTestConfig(id);c.insert("combat_scene",3);c.insert("dungeon_team_count",3);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",3600);if(id==box)c.insert("xzk190",false);
            const bool valid=validateLegacyConfig(c,e);must(valid,e.toUtf8().constData());
            auto bad=c;bad.insert("dungeon_wait_seconds",1);must(!validateLegacyConfig(bad,e),"Short wait accepted");
        }
    });
}
}
