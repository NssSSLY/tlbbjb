#pragma once
#include "long_task_tests.hpp"
namespace tlbb {
// Scripted world for the short tasks: named rows, a map name, a guild city, and answers to the tasks' own tagged reads.
struct ShortFake:PvpFake {
    std::vector<resident::Object> list;QStringList options;std::string guild="我的帮会",dialogText;int seeds=0,used_=0,skillUses=0,refine=0,chips=0,bagRoom=5,ydfLeft=2,ydfBuys=0,ydfSub=7,clock=20*60,asks=0;
    QStringList clickedLog;std::function<void(const QString&)> onClick;std::function<void()> onSkill,onFrame;std::function<void(const std::string&)> onUse;
    ShortFake(){team=0;}
    std::vector<resident::Object> rows()override{return list;}
    QStringList choices()override{return options;}
    void clicked(const QString &l)override{clickedLog<<l;if(onClick)onClick(l);}
    void tick()override{if(onFrame)onFrame();}
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("short:guild-city")!=std::string::npos)return {Value(guild)};
        if(code.find("short:guild-ask")!=std::string::npos){++asks;return {};}
        if(code.find("short:state")!=std::string::npos)return {Value(0)};
        if(code.find("short:count")!=std::string::npos)return {Value(seeds)};
        if(code.find("short:use")!=std::string::npos){++used_;if(seeds>0)--seeds;if(onUse)onUse(code);return {Value(1)};}
        if(code.find("short:dialog-all")!=std::string::npos)return {Value(dialogText)};
        if(code.find("short:clock")!=std::string::npos)return {Value(clock)};
        if(code.find("short:loot")!=std::string::npos||code.find("short:ui")!=std::string::npos||code.find("short:flower")!=std::string::npos||code.find("short:ydf-load")!=std::string::npos)return {};
        if(code.find("short:refine")!=std::string::npos){
            if(chips<20)return {Value(0),Value(chips)};
            if(bagRoom<=0)return {Value(2),Value(chips)};
            ++refine;const int was=chips;chips-=20;--bagRoom;return {Value(1),Value(was)};
        }
        if(code.find("short:ydf-buy")!=std::string::npos){if(ydfLeft>0){--ydfLeft;++ydfBuys;return {Value(1),Value(0)};}return {Value(0),Value(ydfSub)};}
        if(code.find("tactics:skill")!=std::string::npos){++skillUses;if(onSkill)onSkill();return {Value(1)};}
        return PvpFake::evaluate(code,f,n);
    }
};
template<class Test>void shortTaskTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    const char *c="short_flow_v1";
    auto run=[&](SmallFake &h,const QString &id,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);if(!cfg.contains("dungeon_wait_seconds"))cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue(c),"Missing completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Flow still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=8000000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](SmallFake &h,const QString &id,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,cfg,why);
        must(state==resident::Vm::Completed,((id+" state ").toStdString()+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](SmallFake &h,const QString &id,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,cfg,why);
        must(state==resident::Vm::Failed,((id+" expected a stop: state ").toStdString()+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto verified=[&](SmallFake &h){return TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object());};
    auto u=[](const char *s){return QString::fromUtf8(s);};
    test("short_qingji",[&]{
        std::string why;
        {ShortFake h;h.scene=1075;h.x=158;h.y=100;h.options={"#{QRYJH_221104_13}","#{QRYJH_221104_21}","#{QRYJH_221104_135}"};h.team=2;h.seeds=1;h.dialogText="#{QRYJH_221104_130}\n";
            h.onUse=[&](const std::string&){h.list={{500,1500,137,40,100,false,"小小的花朵"}};};
            h.onClick=[&](const QString &l){if(l=="#{QRYJH_221104_21}")h.list={{501,1501,137,40,100,false,"盛开的虞美人花"}};};
            finished(h,"qingji",{},why);must(h.used_==1&&h.clickedLog.contains("#{QRYJH_221104_135}")&&verified(h),"Flower not played through");}
        {ShortFake h;h.scene=1075;h.x=158;h.y=100;failed(h,"qingji",{},why);must(why.find("痴情种")!=std::string::npos,why.c_str());}
    });
    test("short_xingluo",[&]{
        std::string why;QJsonObject cfg{{"采集地图",u("玄海")},{"紫微香兰",true},{"short_minutes",2}};
        {ShortFake h;h.scene=115;h.x=136;h.y=213;h.list={{500,1500,136,214,100,false,"紫微香兰"},{501,1501,136,215,100,false,"紫微凤尾"}};
            h.onSkill=[&]{h.list.clear();h.clock=21*60+40;};
            finished(h,"xingluo",cfg,why);must(h.skillUses==1&&verified(h),"Herb not picked");}
        {ShortFake h;h.scene=115;h.clock=22*60;finished(h,"xingluo",cfg,why);must(h.receipt.contains("already_done"),"Out of hours");}
        {ShortFake h;failed(h,"xingluo",{{"采集地图",u("玄海")}},why);must(why.find("没有勾选")!=std::string::npos,why.c_str());}
    });
    test("short_wenhua",[&]{
        std::string why;
        struct WenhuaFake:ShortFake {
            int status=-1;bool noScene=false,handedIn=false;
            resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
                using resident::Value;
                if(code.find("dungeon:mission")!=std::string::npos){
                    if(status<0)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
                    return {Value(2),Value(700),Value(status),Value(std::string())};
                }
                return ShortFake::evaluate(code,f,n);
            }
        };
        auto game=[&](WenhuaFake &h){h.scene=0;h.x=254;h.y=252;h.options={"#{XYYJ_260529_23}","#{GXCJ_260604_03}","#{XYYJ_260529_49}"};
            h.onClick=[&h](const QString &l){
                if(l=="#{GXCJ_260604_03}"&&!h.noScene){h.status=0;h.scene=1075;h.x=144;h.y=117;h.list={{500,1500,144,118,100,false,"遗失的碎镜片"}};}
                if(l=="#{GXCJ_260604_03}"&&h.noScene)h.status=0;
                if(l=="#{XYYJ_260529_49}"){h.status=-1;h.handedIn=true;}
            };
            h.onSkill=[&h]{h.list.clear();if(h.skillUses>=1){h.status=1;}};};
        {WenhuaFake h;game(h);finished(h,"wenhua",{},why);must(h.handedIn&&h.skillUses>=1&&verified(h),"Mission not played through");}
        {WenhuaFake h;game(h);h.noScene=true;failed(h,"wenhua",{},why);must(why.find("1075")!=std::string::npos,why.c_str());}
        {WenhuaFake h;h.scene=0;h.x=254;h.y=252;finished(h,"wenhua",{},why);must(h.receipt.contains("already_done"),"Nothing to do");}
    });
    test("short_guild_tasks",[&]{
        std::string why;
        auto inCity=[&](ShortFake &h){h.options={u("进入本帮城市")};h.onClick=[&h](const QString &l){if(l==QString::fromUtf8("进入本帮城市")){h.scene=500;h.map="我的帮会";h.x=60;h.y=130;}};h.scene=0;h.x=237;h.y=236;};
        {ShortFake h;h.guild="";finished(h,"guild_box",{},why);must(h.receipt.contains("already_done"),"No guild should end");}
        {ShortFake h;inCity(h);h.list={{500,1500,0,0,100,false,"福利宝箱"}};bool placed=false;h.onFrame=[&]{if(h.scene==500&&!placed){h.list[0].x=h.x+1;h.list[0].y=h.y;placed=true;}};h.onSkill=[&]{h.list.clear();};
            finished(h,"guild_box",{},why);must(h.skillUses==1&&h.receipt.contains("1"),"Box not opened");}
        {ShortFake h;inCity(h);h.team=0;finished(h,"orig_00350c2c",{},why);must(h.receipt.contains("already_done"),"No whistle should end");}
        {ShortFake h;inCity(h);h.options<<"#{SBG_140512_05}"<<"#{SBG_140512_60}"<<"#{SBG_140512_45}";auto base=h.onClick;
            h.onClick=[&h,base](const QString &l){base(l);if(l=="#{SBG_140512_45}"){h.scene=501;h.map="神兵阁";h.x=100;h.y=100;}};
            bool left=false;h.onFrame=[&]{if(h.scene==501&&std::abs(h.x-165)<=1&&std::abs(h.y-253)<=1&&!left){left=true;h.scene=500;h.map="我的帮会";}};
            finished(h,"orig_00351748",{{"short_minutes",1}},why);must(left&&verified(h),"Should enter, grind and walk out");}
        {ShortFake h;inCity(h);h.options<<"#{SBG_140512_05}"<<"#{SBG_140512_60}";auto base=h.onClick;
            h.onClick=[&h,base](const QString &l){base(l);if(l=="#{SBG_140512_60}")h.messages+="SBG_140512_69\n";};
            finished(h,"orig_00351748",{{"short_minutes",1}},why);must(h.receipt.contains("already_done"),"Already entered today");}
    });
    test("short_zhenyuan_and_yuandan",[&]{
        std::string why;
        {ShortFake h;h.scene=1;h.x=349;h.y=229;h.chips=40;failed(h,"zhenyuan",{},why);must(why.find("允许物品处理")!=std::string::npos&&h.refine==0,"Refined without permission");}
        {ShortFake h;h.scene=1;h.x=349;h.y=229;h.chips=40;h.list={{500,1500,349,230,100,false,"张士心"}};finished(h,"zhenyuan",{{"allow_item",true}},why);must(h.refine==2&&h.chips==0&&verified(h),"Should refine twice");}
        {ShortFake h;h.scene=1;h.x=349;h.y=229;h.chips=40;h.bagRoom=0;h.list={{500,1500,349,230,100,false,"张士心"}};finished(h,"zhenyuan",{{"allow_item",true}},why);must(h.refine==0&&h.receipt.contains("already_done"),"Full bar should end");}
        const QJsonObject buy{{"bjk90",u("甲")}};
        {ShortFake h;h.scene=1;h.x=178;h.y=231;h.options={u("元丹坊")};failed(h,"yuandan",buy,why);must(why.find("允许支付")!=std::string::npos&&h.ydfBuys==0,"Bought without permission");}
        {ShortFake h;h.scene=1;h.x=178;h.y=231;failed(h,"yuandan",{{"allow_spend",true}},why);must(why.find("没有填写")!=std::string::npos,why.c_str());}
        {ShortFake h;h.scene=1;h.x=178;h.y=231;h.options={u("元丹坊")};auto cfg=buy;cfg.insert("allow_spend",true);finished(h,"yuandan",cfg,why);must(h.ydfBuys==2&&verified(h),"Should buy until sold out");}
        {ShortFake h;h.scene=1;h.x=178;h.y=231;h.options={u("元丹坊")};h.ydfLeft=0;h.ydfSub=1;auto cfg=buy;cfg.insert("allow_spend",true);failed(h,"yuandan",cfg,why);must(why.find("周次")!=std::string::npos,why.c_str());}
    });
}
}
