#pragma once
#include "small_dungeon_tests.hpp"
namespace tlbb {
// 天降奇兽: a beast hidden among town NPCs, then two targets inside.
struct TianjiangFake:SmallFake {
    int hour=13,minute=40,entries=0,asks=0,rejects=0,catHp=100,beastHp=100,kicked=0,rounds=0;bool beastUp=true,noEntry=false,noLeave=false,hasCat=true;
    TianjiangFake(){scene=246;x=166;y=250;}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;
        if(scene==246){r.push_back({60,1060,x+3,y,100,false,"路人甲"});if(beastUp&&(x-153)*(x-153)+(y-206)*(y-206)<100)r.push_back({61,1061,154,207,100,false,"雪域奇兽"});return r;}
        if(scene!=268)return r;
        if((x-188)*(x-188)+(y-123)*(y-123)<400)r.push_back({70,1070,188,125,double(std::max(0,beastHp)),beastHp>0,"护岛神兽"});
        if(hasCat&&(x-178)*(x-178)+(y-162)*(y-162)<400)r.push_back({71,1071,178,160,double(std::max(0,catHp)),catHp>0,"无敌飞天猫"});
        return r;
    }
    QStringList choices()override{return {QString::fromUtf8("再见")};}
    void hit(int id)override{if(id==70)beastHp-=50;if(id==71)catHp-=50;}
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        if(id==gameplay::QuestOption&&QString::fromWCharArray(a.text)==QString::fromUtf8("进入奇兽巢穴")){
            ++entries;if(!noEntry){scene=268;x=120;y=120;beastHp=catHp=100;}
            return {Value(1),Value(std::string("进入奇兽巢穴"))};
        }
        if(id==gameplay::RunTo&&a.ints[0]==268&&a.reals[0]==76&&a.reals[1]==70&&!noLeave){scene=246;x=166;y=250;++rounds;hour=14;minute=10;return {Value(1)};}
        return SmallFake::snippet(id,a);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("tianjiang:time")!=std::string::npos)return {Value(hour),Value(minute)};
        if(code.find("tianjiang:option")!=std::string::npos){
            if(page=="closed")return {Value(std::string())};
            return {Value(std::string(npcName==QString::fromUtf8("雪域奇兽")?"进入奇兽巢穴":""))};
        }
        if(code.find("tianjiang:ui")!=std::string::npos){if(code.find("AskTeamFollow")!=std::string::npos)++asks;return {};}
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(2),Value(std::string(leader?"42\t903\n43\t904\n":"43\t904\n42\t903\n"))};
        return SmallFake::evaluate(code,f,n);
    }
};
template<class Test>void tianjiangTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    const QString id="dungeon_002eb7bd";
    auto run=[&](TianjiangFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("tianjiang_search_minutes",1);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("tianjiang_flow_v1"),"Tianjiang has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Tianjiang still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=900000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](TianjiangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](TianjiangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int want){return std::count(v.begin(),v.end(),want)>0;};
    test("tianjiang_window_search_fight_and_leave",[&]{
        std::string why;
        {TianjiangFake h;finished(h,{},why);must(h.entries==1&&h.asks==1&&has(h.attacked,70)&&has(h.attacked,71)&&h.rounds==1,"Tianjiang skipped a stage");must(h.logText.find("发现 雪域奇兽")!=std::string::npos,"Beast not named");must(TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object()),"Tianjiang result not verified");}
        {TianjiangFake h;h.hour=9;failed(h,{},why);must(why.find("不是活动时间")!=std::string::npos&&h.entries==0,why.c_str());}
        {TianjiangFake h;h.beastUp=false;failed(h,{},why);must(why.find("没有找到")!=std::string::npos&&h.entries==0,why.c_str());}
        {TianjiangFake h;h.noEntry=true;failed(h,{},why);must(h.entries==1,"Entry replayed");}
        {TianjiangFake h;h.noLeave=true;failed(h,{},why);must(h.receipt.isEmpty(),"Completed without leaving");}
        {TianjiangFake h;h.leader=false;failed(h,{},why);must(h.entries==0&&h.asks==0,"Follower searched");}
        {TianjiangFake h;h.scene=268;h.x=188;h.y=123;finished(h,{},why);must(h.entries==0&&h.rounds==1,"Resume re-entered");}
    });
    test("tianjiang_config_validation",[&]{
        auto c=combatTestConfig(id);c.insert("combat_scene",268);c.insert("dungeon_rounds",20);c.insert("dungeon_wait_seconds",45);c.insert("tianjiang_search_minutes",30);c.insert("tianjiang_loot",true);QString e;
        const bool valid=validateLegacyConfig(c,e);must(valid,e.toUtf8().constData());
        auto bad=c;bad.insert("tianjiang_search_minutes",0);must(!validateLegacyConfig(bad,e),"Search 0 accepted");
        bad=c;bad.insert("tianjiang_loot","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
    });
}
}
