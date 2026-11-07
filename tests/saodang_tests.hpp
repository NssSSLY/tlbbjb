#pragma once
#include "activity_tests.hpp"
namespace tlbb {
// The game's sweep windows: a box listing dungeons, and a page per dungeon that runs its bosses.
struct SaodangFake:SmallFake {
    struct Row{std::string name;int low,high,kind,need,left,id;};
    std::vector<Row> rows_{{"讨伐燕子坞",10,0,1,1,2,501},{"少室山",0,10,2,1,1,502},{"三神幻境",10,0,1,1,1,503}};
    bool box=false,page=false,chest=false,boxBroken=false,pageBroken=false,noCount=false,fullBag=false,blockIt=false,activeSession=false;
    int bossLeft=2,current=-1,oks=0,opens=0,keys=0,lingfu=0,free=0,sessionId=502;
    SaodangFake(){scene=0;x=100;y=100;team=0;}
    std::vector<resident::Object> rows()override{return {};}
    QStringList choices()override{return {};}
    Row *find(int id){for(auto &r:rows_)if(r.id==id)return &r;return nullptr;}
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("saodang:shown")!=std::string::npos){
            if(code.find("SweepAll_Env")!=std::string::npos)return {Value(box?1:0)};
            if(code.find("SweepPage_Env")!=std::string::npos)return {Value(page?1:0)};
            return {Value(chest?1:0)};
        }
        if(code.find("saodang:open-box")!=std::string::npos){if(!boxBroken)box=true;return {};}
        if(code.find("saodang:close-page")!=std::string::npos){page=false;return {};}
        if(code.find("saodang:count")!=std::string::npos)return {Value(int(rows_.size()))};
        if(code.find("saodang:enum")!=std::string::npos){
            int i=0;const auto p=code.find("EnumSecKillTable')(");std::sscanf(code.c_str()+p,"EnumSecKillTable')(%d)",&i);
            const auto &r=rows_[size_t(i)];
            return {Value(r.name),Value(r.low),Value(r.high),Value(r.kind),Value(r.need),Value(1000+i),Value(r.left),Value(r.id)};
        }
        if(code.find("saodang:session")!=std::string::npos)return {Value(activeSession?1:0),Value(sessionId)};
        if(code.find("saodang:open-page")!=std::string::npos){
            int id=0;const auto p=code.find("OpenSecKillPage')(");std::sscanf(code.c_str()+p,"OpenSecKillPage')(%d",&id);
            ++opens;if(!pageBroken){page=true;current=id;bossLeft=2;}
            return {};
        }
        if(code.find("saodang:step")!=std::string::npos){
            if(blockIt){messages+="SDXG_20210624_31\n";return {Value(1)};}
            if(fullBag){messages+="FBSD_150126_33\n";return {Value(1)};}
            if(current==503&&bossLeft==1){chest=true;return {Value(-2)};}
            if(bossLeft>0){--bossLeft;return {Value(3-bossLeft)};}
            finish();return {Value(-1)};
        }
        if(code.find("saodang:ok")!=std::string::npos){
            ++oks;
            if(chest){chest=false;finish();}
            return {};
        }
        if(code.find("saodang:keys")!=std::string::npos)return {Value(keys)};
        if(code.find("saodang:chest")!=std::string::npos){if(code.find("OpenLingfu")!=std::string::npos)++lingfu;else ++free;return {};}
        return SmallFake::evaluate(code,f,n);
    }
    void finish(){if(auto *r=find(current);r&&!noCount){--r->left;}activeSession=false;page=false;}
};
template<class Test>void saodangTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    const QString id="dungeon_002fbab1";const char *contract="saodang_flow_v1";
    auto run=[&](SaodangFake &h,QJsonObject cfg,std::string &why){
        cfg.insert("legacy_id",id);cfg.insert("dungeon_wait_seconds",5);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue(contract),"Saodang has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Saodang still loads the vendor framework");
        QFile module(root+"/scripts/legacy/modules/saodang.lua");must(module.open(QIODevice::ReadOnly),"Saodang module missing");const auto text=module.readAll();
        for(const char *banned:{"ClearBag(","Bag_SellItem(","Bag_DeleteItem(","MainBankSaveItem(","EatBindItem("})must(!text.contains(banned),"Saodang calls clean-up it must not run");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=1000000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](SaodangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Completed,("state "+std::to_string(int(state))+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](SaodangFake &h,QJsonObject cfg,std::string &why){
        const auto state=run(h,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    const QJsonObject yzw{{"xzk131",true}};
    test("saodang_sweeps_only_what_is_ticked",[&]{
        std::string why;
        {SaodangFake h;finished(h,yzw,why);must(h.rows_[0].left==0&&h.rows_[1].left==1&&h.rows_[2].left==1,"Wrong dungeons swept");must(TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object()),"Result not verified");must(h.receipt.contains(QString::fromUtf8("讨伐燕子坞 2 次")),"Count not stated");}
        {SaodangFake h;finished(h,{{"xzk131",true},{"xzk274",true}},why);must(h.rows_[0].left==0&&h.rows_[1].left==0,"Second dungeon not swept");}
        {SaodangFake h;h.rows_[0].left=0;finished(h,yzw,why);must(h.opens==0&&h.receipt.contains("already_done"),"Nothing left should end");}
        {SaodangFake h;failed(h,{},why);must(why.find("没有勾选")!=std::string::npos,why.c_str());}
    });
    test("saodang_chest_and_risk_switch",[&]{
        std::string why;const QJsonObject ss{{"xzk278",true}};
        {SaodangFake h;h.keys=3;finished(h,ss,why);must(h.free==1&&h.lingfu==0,"灵符 used without permission");}
        {SaodangFake h;h.keys=3;auto c=ss;c.insert("allow_item",true);finished(h,c,why);must(h.lingfu==1&&h.free==0,"灵符 not used");}
        {SaodangFake h;auto c=ss;c.insert("allow_item",true);finished(h,c,why);must(h.free==1,"No 灵符 should be free");}
    });
    test("saodang_stops",[&]{
        std::string why;
        {SaodangFake h;h.boxBroken=true;failed(h,yzw,why);must(why.find("窗口打不开")!=std::string::npos,why.c_str());}
        {SaodangFake h;h.fullBag=true;failed(h,yzw,why);must(why.find("背包已满")!=std::string::npos&&h.receipt.isEmpty(),why.c_str());}
        {SaodangFake h;h.blockIt=true;failed(h,yzw,why);must(why.find("成就不足")!=std::string::npos,why.c_str());}
        {SaodangFake h;h.rows_[0].need=99;failed(h,yzw,why);must(why.find("点数不足")!=std::string::npos&&h.opens==0,why.c_str());}
        {SaodangFake h;h.noCount=true;failed(h,yzw,why);must(why.find("次数没有变化")!=std::string::npos,why.c_str());}
        {SaodangFake h;h.pageBroken=true;failed(h,yzw,why);must(h.receipt.isEmpty(),"Completed without a page");}
        {SaodangFake h;h.activeSession=true;finished(h,yzw,why);must(h.rows_[1].left==0&&h.rows_[0].left==0,"Unfinished sweep not resumed first");}
    });
    test("saodang_config_validation",[&]{
        QJsonObject c{{"legacy_id",id},{"timeout_seconds",7200},{"dungeon_wait_seconds",45},{"saodang_minutes",20}};for(const auto key:{"xzk131","xzk266","xzk274","xzk272","xzk279","xzk278","xzk275","xzk277","xzk276","xzk290"})c.insert(key,false);c.insert("xzk131",true);QString e;
        const bool valid=validateLegacyConfig(c,e);must(valid,e.toUtf8().constData());
        auto bad=c;bad.insert("saodang_minutes",0);must(!validateLegacyConfig(bad,e),"Limit 0 accepted");
        bad=c;bad.insert("xzk131","true");must(!validateLegacyConfig(bad,e),"String switch accepted");
    });
}
}
