#pragma once
#include "short_task_tests.hpp"
namespace tlbb {
template<class Test>void dailyRoutineTests(const QString &root,Test test){
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
    // 清泉茗茶: offered once, leaves then bamboo, then the NPC says the day is done.
    struct TeaFake:ShortFake {
        int id=-1,status=0,var1=0,offers=0,handed=0,bamboo=0;bool noBamboo=false;
        TeaFake(){scene=1;x=296;y=188;options={"#{QQMC_120522_03}","#{QQMC_220526_18}"};}
        void clicked(const QString &l)override{
            if(l=="#{QQMC_220526_18}"){
                if(handed>=1){dialogText="#{QQMC_120522_09}\n";return;}
                ++offers;id=1289;status=0;var1=0;
            }
            if(l=="#{QQMC_120522_03}"&&id>0&&status==1){id=-1;++handed;}
        }
        resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
            using resident::Value;
            if(code.find("daily:tea-mission")!=std::string::npos){
                if(id<0)return {Value(-1),Value(-1),Value(-1),Value(-1),Value(-1)};
                return {Value(2),Value(id),Value(status),Value(var1),Value(777)};
            }
            if(code.find("daily:use-quest")!=std::string::npos){if(noBamboo)return {Value(0)};++bamboo;status=1;return {Value(1)};}
            return ShortFake::evaluate(code,f,n);
        }
    };
    test("daily_tea",[&]{
        std::string why;
        auto leaves=[](TeaFake &h){h.onFrame=[&h]{if(h.id==1289&&h.scene==4&&h.var1==0&&h.list.empty())h.list={{500,1500,h.x+1,h.y,100,false,"碧螺春"}};};h.onSkill=[&h]{h.var1=1;h.list.clear();};};
        {TeaFake h;leaves(h);finished(h,"tea_biluo",{},why);must(h.offers==1&&h.bamboo==1&&h.handed==1&&verified(h),"Tea not played through");must(h.used_==0,"Drank without being asked");}
        {TeaFake h;h.dialogText="#{QQMC_120522_09}\n";finished(h,"tea_biluo",{},why);must(h.offers==0||h.handed==0,"Nothing should run");must(h.receipt.contains("already_done"),"Finished day");}
        {TeaFake h;h.id=1289;h.status=2;failed(h,"tea_biluo",{},why);must(why.find("允许放弃")!=std::string::npos,why.c_str());}
        {TeaFake h;leaves(h);h.noBamboo=true;failed(h,"tea_biluo",{},why);must(why.find("竹筒")!=std::string::npos,why.c_str());}
    });
    // 天劫楼: two floors, then the day-done dialog.
    struct TianjieFake:ShortFake {
        int status=-1,floorsDone=0,hp=100;
        void hit(int id)override{if(id==100){hp-=50;if(hp<=0){list.clear();status=1;}}}
        resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
            using resident::Value;
            if(code.find("dungeon:mission")!=std::string::npos){
                if(status<0)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
                return {Value(1),Value(900),Value(status),Value(std::string())};
            }
            return ShortFake::evaluate(code,f,n);
        }
    };
    test("daily_tianjie",[&]{
        std::string why;
        {TianjieFake h;h.scene=2;h.x=94;h.y=201;h.options={"#{TJL_xml_XX(02)}","#{TJL_xml_XX(01)}","#{TJL_xml_XX(04)}"};
            h.onClick=[&h](const QString &l){
                if(l=="#{TJL_xml_XX(02)}"){h.scene=272;h.x=73;h.y=79;return;}
                if(l=="#{TJL_xml_XX(01)}"&&h.status==1){h.status=-1;++h.floorsDone;return;}
                if(l=="#{TJL_xml_XX(01)}"&&h.status<0){if(h.floorsDone>=2){h.dialogText="#{TJL_090714_02}\n";return;}h.status=0;h.hp=100;h.list={{100,1100,h.x+1,h.y,100,true,"恶徒"}};}
            };
            h.onFrame=[&h]{if(!h.list.empty()&&h.list[0].id==100){h.list[0].x=h.x+1;h.list[0].y=h.y;h.list[0].hp=h.hp;}if(h.scene==272&&std::abs(h.x-82)<=1&&std::abs(h.y-80)<=1&&!h.dialogText.empty()){h.scene=2;h.x=94;h.y=201;}};
            finished(h,"orig_00291057",{},why);must(h.scene==2,"Should leave the tower");must(h.receipt.contains("2")&&verified(h),"Floors not counted");}
    });
    test("daily_beijiu_and_jianzong",[&]{
        std::string why;
        {ShortFake h;h.scene=0;h.x=399;h.y=224;h.options={u("领取饮酒奖励"),u("领取斟酒奖励"),u("领取上周斟酒达成奖励"),u("领取斟酒达成奖励")};h.list={{500,1500,399,225,100,false,"酒坛"}};
            h.onSkill=[&]{h.messages+="BJJH_221024_66\n";};
            h.onClick=[&](const QString &l){if(l==QString::fromUtf8("领取饮酒奖励"))h.messages+="BJJH_221024_12\n";if(l==QString::fromUtf8("领取斟酒奖励"))h.messages+="BJJH_221024_18\n";if(l==QString::fromUtf8("领取斟酒达成奖励"))h.messages+="BJJH_221024_29\n";};
            finished(h,"beijiu",{},why);must(h.skillUses==1&&h.clickedLog.contains(u("领取饮酒奖励"))&&verified(h),"Drink and claim");}
        {ShortFake h;h.scene=0;h.x=399;h.y=224;failed(h,"beijiu",{{"short_minutes",1}},why);must(why.find("酒坛")!=std::string::npos||why.find("时限")!=std::string::npos,why.c_str());}
        struct ZmFake:ShortFake {
            int level=-1;bool hook=true;
            resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
                using resident::Value;
                if(code.find("daily:zm-level")!=std::string::npos)return hook?resident::Values{Value(level),Value(10)}:resident::Values{Value(-2),Value(-2)};
                if(code.find("daily:zm-goto")!=std::string::npos)return {Value(std::string("守关人")),Value(1),Value(50),Value(60)};
                return ShortFake::evaluate(code,f,n);
            }
        };
        {ZmFake h;h.scene=1;h.x=50;h.y=60;h.level=3;finished(h,"orig_00257006",{},why);must(h.receipt.contains("already_done"),"No entry option should end");}
        {ZmFake h;h.scene=1;h.hook=false;failed(h,"orig_00257006",{},why);must(why.find("宗门塔")!=std::string::npos,why.c_str());}
        {ZmFake h;h.scene=1;h.team=3;h.level=3;failed(h,"orig_00257006",{},why);must(why.find("自动退队")!=std::string::npos,why.c_str());}
    });
    test("daily_linwei",[&]{
        std::string why;
        struct LwFake:ShortFake {
            std::map<std::string,int> hand;
            resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
                using resident::Value;
                if(code.find("dungeon:mission")!=std::string::npos){
                    for(auto &kv:hand)if(code.find(kv.first)!=std::string::npos)return {Value(1),Value(900),Value(kv.second),Value(std::string())};
                    return {Value(-1),Value(-1),Value(-1),Value(std::string())};
                }
                return ShortFake::evaluate(code,f,n);
            }
        };
        const QStringList all{"#{KDJYD_250814_14}","#{KDJYD_250814_18}","#{KDJYD_250814_37}","#{KDJYD_250814_39}","#{KDJYD_250814_41}","#{KDJYD_250814_53}","#{KDJYD_250814_57}","#{KDJYD_250814_91}","#{KDJYD_250814_102}","#{KDJYD_250814_115}","#{XL_XML_36}","#{XL_XML_35}","#{KDJYD_250814_152}","#{SZJJ_250801_05}","#{KDJYD_250814_169}"};
        {LwFake h;h.scene=2;h.x=100;h.y=102;finished(h,"orig_00291c56",{},why);must(h.receipt.contains("already_done"),"Nothing offered should end");}
        {LwFake h;h.scene=2;h.x=100;h.y=102;h.options=all;failed(h,"orig_00291c56",{},why);must(why.find("允许提升修炼")!=std::string::npos,why.c_str());}
        {LwFake h;h.scene=2;h.x=100;h.y=102;h.options=all;failed(h,"orig_00291c56",{{"linwei_xiulian",true}},why);must(why.find("允许物品处理")!=std::string::npos,why.c_str());}
        {LwFake h;h.scene=2;h.x=100;h.y=102;h.options=all;h.seeds=100;finished(h,"orig_00291c56",{{"linwei_xiulian",true},{"allow_item",true},{"short_minutes",60}},why);must(verified(h)&&h.receipt.contains("done"),"Chain not finished");}
        {LwFake h;h.scene=2;h.x=100;h.y=102;h.options=all;h.seeds=100;h.hand["KDJYD_250814_169"]=0;failed(h,"orig_00291c56",{{"linwei_xiulian",true},{"allow_item",true},{"short_minutes",60}},why);must(why.find("任务还在")!=std::string::npos,why.c_str());}
    });
    test("daily_jinzhen",[&]{
        std::string why;
        {QuestFake h;h.school=0;h.scene=15;failed(h,"orig_002897e2",{},why);must(why.find("峨嵋")!=std::string::npos,why.c_str());}
        {QuestFake h;h.school=4;h.scene=15;h.x=43;h.y=108;finished(h,"orig_002897e2",{},why);must(h.receipt.contains("already_done"),"Nothing to do");}
        {QuestFake h;h.school=4;h.scene=15;h.x=43;h.y=108;h.talkCompletes=true;h.outlineNames={"金针渡劫-重攻轻守"};finished(h,"orig_002897e2",{},why);must(h.accepts==1&&h.handins==1&&h.receipt.contains("1"),"Talk-only mission");}
        {QuestFake h;h.school=4;h.scene=15;h.x=43;h.y=108;h.outlineNames={"金针渡劫-重攻轻守"};failed(h,"orig_002897e2",{},why);must(why.find("没有变化")!=std::string::npos&&why.find("已交 0 个")!=std::string::npos,"A talk that changes nothing must not count as handed in");}
        {QuestFake h;h.school=4;h.scene=2;h.x=229;h.y=248;h.hand.push_back({"金针渡劫-运用自如",1});failed(h,"orig_002897e2",{},why);must(why.find("允许支付")!=std::string::npos&&h.handins==0,why.c_str());}
    });
}
}
