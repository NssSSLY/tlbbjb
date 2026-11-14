#pragma once
#include "tianjiang_tests.hpp"
namespace tlbb {
// One shared field for the 溯缘镜 stories: entering, one fight, a final conversation, sent out; then the entrance refuses.
struct SuyuanFake:SmallFake {
    std::string kind;QString enterKey;int entries=0,talks=0,mobHp=100,stage=0,heals=0,prepped=0,relic=0;bool refuseNow=false,noEntry=false,noExit=false,hasTrap=false;int school=0,kickAfter=0;
    int trapLeft=20; // A trap expires, as the game's do.
    explicit SuyuanFake(std::string k):kind(std::move(k)){scene=1075;x=208;y=51;team=0;enterKey=kind=="yuhua"?"#{QXFB_260529_04}":kind=="wujian"?"#{QXFB_260529_03}":"#{QXFB_260529_05}";}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;if(scene!=1079)return r;
        const double cx=x+2,cy=y;
        if(kind=="qianbai"){if(stage==0)r.push_back({100,1100,cx,cy,double(mobHp),true,"伏兵"});if(stage==1)r.push_back({101,1101,186,121,100,false,"项王"});r.push_back({102,1102,189,136,100,false,"溯缘镜"});}
        if(kind=="chuge"){
            if(stage==0){r.push_back({100,1100,cx,cy,double(mobHp),true,"楚军"});r.push_back({110,1110,77,106,50,false,"船舵手"});r.push_back({111,1111,76,106,100,false,"船舵"});}
            if(stage==1)r.push_back({111,1111,77,106,100,false,"船舵"});
            if(stage==2)r.push_back({112,1112,x+1,y,100,false,"虞姬尸体"});
            if(stage==3)r.push_back({102,1102,189,136,100,false,"溯缘镜"});
        }
        if(kind=="yuhua"){
            if(stage==0)r.push_back({113,1113,x+1,y,100,false,"虞姬"});
            if(stage>=1)r.push_back({112,1112,x+2,y,100,false,"虞姬尸体"});
            if(stage==1)r.push_back({114,1114,x+3,y,100,false,"怨骨虞姬"});
            if(stage==2)r.push_back({114,1114,x+3,y,double(mobHp),true,"怨骨虞姬"});
        }
        if(kind=="wujian"){
            if(stage==0)r.push_back({115,1115,186,118,100,false,"项王"}),r.push_back({113,1113,185,118,100,false,"虞姬"});
            if(stage==1)r.push_back({115,1115,186,118,double(mobHp),true,"项王"}),r.push_back({113,1113,185,118,100,false,"虞姬"});
            if(stage>=2)r.push_back({115,1115,186,118,0,true,"项王"});
            if(stage>=2)r.push_back({102,1102,67,221,100,false,"溯缘镜"});
        }
        return r;
    }
    QStringList choices()override{
        if(scene==1075)return {enterKey,"#{QXFB_260529_06}","#{QXZH_250528_34}","#{QXZH_250528_42}","#{QXZH_250528_113}","#{QXZH_250528_53}","#{QXZH_250528_18}"};
        return {"#{QXFB_260529_29}","#{QXFB_260529_20}","#{QXFB_260529_25}","#{QXFB_260529_32}","#{QXFB_260529_43}","#{QXFB_260529_35}","#{QXFB_260529_257}","#{QXFB_260529_231}","#{QXFB_260529_312}","#{QXFB_260529_30}"};
    }
    void leave(){if(!noExit){scene=1075;x=208;y=51;refuseNow=true;}}
    void clicked(const QString &l)override{
        if(l.startsWith("#{QXZH"))++prepped;
        if(l=="#{QXFB_260529_06}"&&scene==1075){
            if(refuseNow){messages+="QXFB_260529_347\n";return;}
            ++entries;if(!noEntry){scene=1079;x=100;y=100;stage=0;mobHp=100;}
            return;
        }
        if(scene!=1079)return;
        ++talks;
        if(l=="#{QXFB_260529_29}")stage=2;
        if(l=="#{QXFB_260529_32}")stage=2;
        if(l=="#{QXFB_260529_43}"&&kind=="chuge")stage=3;
        if(l=="#{QXFB_260529_257}")stage=1;
        if(l=="#{QXFB_260529_231}")stage=2;
        if(l=="#{QXFB_260529_312}")stage=1;
        if(l=="#{QXFB_260529_25}")leave();
    }
    void hit(int id)override{
        if(id==100){mobHp-=50;if(mobHp<=0)stage=1;}
        if(id==114){mobHp-=50;if(mobHp<=15){mobHp=100;leave();}}
        if(id==115){mobHp-=50;if(mobHp<=0)stage=2;}
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="mechanism_snapshot"&&hasTrap&&scene==1079&&stage==0&&trapLeft-->0){std::string t="2\t71\t971\t"+std::to_string(x+1)+"\t"+std::to_string(y)+"\n";return {Value(scene),Value(1),Value(t)};}
        return SmallFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("suyuan:gauge")!=std::string::npos)return {Value(std::string())};
        if(code.find("shaoshi:school")!=std::string::npos)return {Value(school)};
        if(code.find("tactics:skill")!=std::string::npos){++heals;return {Value(1)};}
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(1),Value(std::string("42\t903\n"))};
        return SmallFake::evaluate(code,f,n);
    }
};
struct ChuhanFake:SmallFake {
    int entries=0,leaves=0,claims=0,casts_=0,enemyHp=100,frames=0;bool stuck=false,noOption=false,noEntry=false,refuse=false;
    ChuhanFake(){scene=1075;x=88;y=210;team=0;}
    std::vector<resident::Object> rows()override{return {};}
    QStringList choices()override{return noOption?QStringList{}:QStringList{"#{XQPVP_260526_03}","#{XQPVP_260526_04}","#{XQPVP_260526_05}"};}
    void clicked(const QString &l)override{
        if(l=="#{XQPVP_260526_03}"){if(refuse){messages+="XQPVP_260526_12\n";return;}++entries;if(!noEntry){scene=600;x=100;y=95;refuse=true;}}
        if(l=="#{XQPVP_260526_05}")++claims;
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="position"){
            if(scene==600&&enemyHp<=0&&!stuck&&++frames>=3){scene=1075;x=88;y=210;}
            return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==600?"楚河汉界":"楼兰"))};
        }
        if(op=="enemy_players"){
            if(scene!=600||enemyHp<=0)return {Value(scene),Value(0),Value(std::string())};
            return {Value(scene),Value(1),Value("77\t977\t"+std::to_string(x+1)+"\t"+std::to_string(y)+"\t"+std::to_string(enemyHp)+"\n")};
        }
        return SmallFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("chuhan:hp")!=std::string::npos){frames=0;return {Value(1000)};}
        if(code.find("pvp:cast")!=std::string::npos){++casts_;enemyHp-=50;return {Value(1)};}
        if(code.find("chuhan:ui")!=std::string::npos){if(code.find("LeaveTeam")!=std::string::npos){++leaves;team=0;}return {};}
        return SmallFake::evaluate(code,f,n);
    }
};
struct XiaoaciFake:SmallFake {
    QString enterKey="#{WSTZ_260403_05}";bool chosen=false;
    int stage=1,hp=100,entries=0,opens=0;bool started=false,noEntry=false,noOpen=false,refuse=false,noExit=false,kicked=false;int after=0;
    XiaoaciFake(){scene=0;x=250;y=243;team=0;}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;if(scene!=1072)return r;
        if(stage==1&&started)r.push_back({100,1100,x+1,y,double(hp),true,"野狼"});
        if(stage==2)r.push_back({110,1110,130,120,double(hp),started,"大萨满"});
        if(stage==3)r.push_back({120,1120,127,29,double(hp),started,"萧阿刺"});
        return r;
    }
    QStringList choices()override{return {enterKey,"#{WSTZ_260403_102}","#{WSTZ_260403_93}","#{WSTZ_260403_44}"};}
    void clicked(const QString &l)override{
        if(l==enterKey)chosen=true;
        if(l=="#{WSTZ_260403_102}"&&scene==0&&(chosen||refuse)){if(refuse){messages+="WSTZ_260403_108\n";return;}++entries;if(!noEntry){scene=1072;x=123;y=219;stage=1;started=false;hp=100;}}
        if(l=="#{WSTZ_260403_93}"||l=="#{WSTZ_260403_44}"){++opens;if(!noOpen)started=true;}
    }
    void hit(int id)override{
        hp-=50;if(hp>0)return;hp=100;started=false;
        if(id==100)stage=2;else if(id==110)stage=3;else if(id==120){stage=4;refuse=true;}
    }
    std::vector<resident::Object> objects()override{if(stage==4&&!noExit&&++after>10){scene=0;x=250;y=243;stage=5;}return rows();}
};
struct XiakexingFake:SmallFake {
    int step=1,status=-1,accepts=0,handIns=0,whistles=0,buys=0,mobHp=100,stopAtThree=0;bool skipThree=true;
    XiakexingFake(){scene=1016;x=138;y=24;team=0;}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;
        if(step==2&&status==0&&whistles>=2&&mobHp>0)r.push_back({100,1100,x+1,y,double(mobHp),true,"江湖宵小"});
        if(step==4&&status==0&&scene==1017&&mobHp>0)r.push_back({101,1101,x+1,y,double(mobHp),true,"莽牯毒蛤·影"});
        return r;
    }
    static const char *key(int s){return s==1?"#{XKXYD_250116_09}":s==2?"#{XKXYD_250116_41}":s==3?"#{XKXYD_250116_169}":s==4?"#{XKXYD_250116_98}":"#{XKXYD_250116_135}";}
    QStringList choices()override{
        if(step>5)return {};
        return {key(step),"#{XKXYD_250116_13}","#{XKXYD_250116_28}","#{XKXYD_250116_30}","#{XKXYD_250116_32}","#{XKXYD_250116_168}","#{XKXYD_250116_123}","#{XKSD_250110_03}"};
    }
    void clicked(const QString &l)override{
        if(l=="#{XKXYD_250116_32}")status=1;
        if(l=="#{XKXYD_250116_168}"){scene=1017;x=120;y=50;mobHp=100;}
        if(l=="#{XKXYD_250116_123}"){scene=1016;x=138;y=24;}
    }
    void button(int kind)override{
        if(kind==1&&status<0){++accepts;status=0;if(step==3&&skipThree)status=1;}
        if(kind==3&&status==1){++handIns;++step;status=-1;mobHp=100;}
    }
    void hit(int)override{mobHp-=50;if(mobHp<=0)status=1;}
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("dungeon:mission")!=std::string::npos){
            const bool match=step<=5&&status>=0&&code.find(key(step))!=std::string::npos;
            if(!match)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
            return {Value(2),Value(500),Value(status),Value(std::string("x"))};
        }
        if(code.find("xiakexing:whistle")!=std::string::npos){++whistles;if(whistles==1)page="menu";return {Value(1)};}
        if(code.find("xiakexing:ui")!=std::string::npos){if(code.find("MBuy_OK")!=std::string::npos){++buys;status=1;}return {};}
        if(code.find("xiakexing:dialog-all")!=std::string::npos){
            if(step==2&&status==0&&whistles==1)return {Value(std::string("前往*120*80*1016\n"))};
            return {Value(page=="closed"?std::string():choices().join('\n').toStdString())};
        }
        return SmallFake::evaluate(code,f,n);
    }
};
struct NixiFake:SmallFake {
    int mobHp=100,asks=0,talks=0;bool npcForm=false;
    NixiFake(){scene=3;x=56;y=57;team=0;}
    std::vector<resident::Object> rows()override{
        std::vector<resident::Object> r;
        if(scene==3&&(x-84)*(x-84)+(y-140)*(y-140)<400)r.push_back({100,1100,84,140,double(std::max(mobHp,0)),!npcForm&&mobHp>0,"契丹刺客"});
        return r;
    }
    QStringList choices()override{return {};}
    void hit(int)override{mobHp-=50;}
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        if(id==gameplay::NpcTarget&&npcForm){npcForm=false;++talks;}
        return SmallFake::snippet(id,a);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("nixi:ui")!=std::string::npos){++asks;return {};}
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(2),Value(std::string(leader?"42\t903\n43\t904\n":"43\t904\n42\t903\n"))};
        return SmallFake::evaluate(code,f,n);
    }
};
template<class Test>void activityTests(const QString &root,Test test){
    auto must=[](bool v,const char *s){if(!v)throw std::runtime_error(s);};
    auto run=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why,uint64_t limit=1000000){
        cfg.insert("legacy_id",id);cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy",id,entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue(contract),"Missing completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Flow still loads the vendor framework");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());
        for(uint64_t t=0;t<=limit&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20)vm.step(t);
        why=vm.error();return vm.state();
    };
    auto finished=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Completed,((id+" state ").toStdString()+std::to_string(int(state))+" scene "+std::to_string(h.scene)+" at "+std::to_string(h.x)+","+std::to_string(h.y)+" "+why+"\n"+h.logText.substr(0,1500)).c_str());
    };
    auto failed=[&](SmallFake &h,const QString &id,const char *contract,QJsonObject cfg,std::string &why){
        const auto state=run(h,id,contract,cfg,why);
        must(state==resident::Vm::Failed,("expected a stop: state "+std::to_string(int(state))+"\n"+h.logText.substr(0,1200)).c_str());
    };
    auto has=[](const std::vector<int> &v,int want){return std::count(v.begin(),v.end(),want)>0;};
    auto verified=[&](SmallFake &h){return TaskCompletion::verified(QJsonDocument::fromJson(h.receipt.toUtf8()).object());};
    const char *sy="suyuan_flow_v1";
    test("suyuan_four_stories",[&]{
        std::string why;
        {SuyuanFake h("qianbai");finished(h,"qianbai",sy,{},why);must(h.entries==1&&h.talks>=2&&verified(h)&&h.scene==1075,"qianbai");}
        {SuyuanFake h("chuge");h.school=4;finished(h,"chuge",sy,{},why);must(h.entries==1&&h.prepped==1&&h.heals>=1&&h.scene==1075,"chuge");}
        {SuyuanFake h("yuhua");finished(h,"yuhua",sy,{},why);must(h.entries==1&&h.prepped==2&&h.scene==1075,"yuhua");}
        {SuyuanFake h("wujian");finished(h,"wujian",sy,{},why);must(h.entries==1&&h.prepped==1&&h.scene==1075&&h.logText.find("前往出口")!=std::string::npos,"wujian");}
    });
    test("suyuan_other_difficulties",[&]{
        std::string why;
        struct V{const char *id,*kind,*enter;int prepped;};
        const V all[]={{"orig_00445fe7","qianbai","#{QXFB_260529_04}",0},{"orig_00446737","qianbai","#{QXFB_260529_03}",1},{"orig_0044eec5","yuhua","#{QXFB_260529_03}",2},{"orig_0044d295","yuhua","#{QXFB_260529_05}",2},
            {"orig_00454fcd","wujian","#{QXFB_260529_05}",1},{"orig_00456501","wujian","#{QXFB_260529_04}",1},{"orig_004486c3","chuge","#{QXFB_260529_04}",1},{"orig_00449e91","chuge","#{QXFB_260529_03}",1}};
        for(const auto &v:all){
            SuyuanFake h(v.kind);h.enterKey=v.enter;finished(h,v.id,sy,{},why);
            must(h.entries==1&&h.prepped==v.prepped&&h.scene==1075,v.id);
        }
        // The easy 虞花苦渡 leaves the boss to the leader; a follower waits and the run stops by name when nobody else is there.
        {SuyuanFake h("yuhua");h.enterKey="#{QXFB_260529_03}";h.team=2;h.leader=false;failed(h,"orig_0044eec5",sy,{},why);must(!has(h.attacked,114)&&h.logText.find("怨骨虞姬 · 等待")!=std::string::npos,"Follower attacked");}
        {SuyuanFake h("yuhua");h.team=2;h.leader=false;finished(h,"yuhua",sy,{},why);must(has(h.attacked,114),"Normal follower should attack");}
    });
    test("suyuan_entrance_and_stops",[&]{
        std::string why;
        {SuyuanFake h("qianbai");h.refuseNow=true;finished(h,"qianbai",sy,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Refusal should end");}
        {SuyuanFake h("qianbai");h.noEntry=true;failed(h,"qianbai",sy,{},why);must(h.entries==1,"Entry replayed");}
        {SuyuanFake h("qianbai");h.bag=0;failed(h,"qianbai",sy,{},why);must(h.entries==0,"Full bag entered");}
        {SuyuanFake h("qianbai");h.team=3;h.together=false;failed(h,"qianbai",sy,{{"dungeon_team_count",3}},why);must(h.entries==0,"Scattered team entered");}
        {SuyuanFake h("qianbai");h.noExit=true;failed(h,"qianbai",sy,{},why);must(h.receipt.isEmpty(),"Completed without leaving");}
        {SuyuanFake h("chuge");h.hasTrap=true;finished(h,"chuge",sy,{},why);must(h.logText.find("躲流星")!=std::string::npos,"Trap ignored");}
        {SuyuanFake h("qianbai");h.scene=1079;h.x=100;h.y=100;finished(h,"qianbai",sy,{},why);must(h.entries==0,"Resume re-entered");}
    });
    test("chuhan_full_flow_and_stops",[&]{
        std::string why;const char *c="chuhan_flow_v1";
        {ChuhanFake h;finished(h,"chuhan",c,{},why);must(h.entries==1&&h.casts_>=2&&h.claims==1&&verified(h),"Chuhan skipped a stage");}
        {ChuhanFake h;h.refuse=true;finished(h,"chuhan",c,{{"chuhan_claim",false}},why);must(h.entries==0&&h.claims==0&&h.receipt.contains("already_done"),"Refusal");}
        {ChuhanFake h;h.team=3;failed(h,"chuhan",c,{},why);must(why.find("允许自动退队")!=std::string::npos&&h.entries==0,why.c_str());}
        {ChuhanFake h;h.team=3;finished(h,"chuhan",c,{{"chuhan_leave_team",true}},why);must(h.leaves==1,"Leave switch ignored");}
        {ChuhanFake h;h.noOption=true;failed(h,"chuhan",c,{},why);must(why.find("活动可能未开放")!=std::string::npos,why.c_str());}
        {ChuhanFake h;h.noEntry=true;failed(h,"chuhan",c,{},why);must(h.entries==1&&why.find("未重复报名")!=std::string::npos,why.c_str());}
        {ChuhanFake h;h.stuck=true;failed(h,"chuhan",c,{{"dungeon_battle_seconds",30}},why);must(why.find("超过时限")!=std::string::npos,why.c_str());}
    });
    test("xiaoaci_full_flow_and_stops",[&]{
        std::string why;const char *c="xiaoaci_flow_v1";
        {XiaoaciFake h;finished(h,"xiaoaci",c,{},why);must(h.entries==1&&h.opens==3&&h.scene==0&&verified(h),"Xiaoaci skipped a stage");}
        {XiaoaciFake h;h.enterKey="#{WSTZ_260403_04}";finished(h,"orig_0045a610",c,{},why);must(h.entries==1&&h.opens==3,"Normal difficulty");}
        {XiaoaciFake h;h.enterKey="#{WSTZ_260403_03}";finished(h,"orig_0045b8d6",c,{},why);must(h.entries==1&&h.opens==3,"Easy difficulty");}
        {XiaoaciFake h;h.refuse=true;finished(h,"xiaoaci",c,{},why);must(h.entries==0&&h.receipt.contains("already_done"),"Refusal");}
        {XiaoaciFake h;h.noEntry=true;failed(h,"xiaoaci",c,{},why);must(h.entries==1,"Entry replayed");}
        {XiaoaciFake h;h.noOpen=true;failed(h,"xiaoaci",c,{},why);must(h.opens==1,"Open replayed");}
        {XiaoaciFake h;h.noExit=true;finished(h,"xiaoaci",c,{},why);must(h.receipt.contains(QString::fromUtf8("仍在副本内")),"Stay not stated");}
    });
    test("xiakexing_chain_and_stops",[&]{
        std::string why;const char *c="xiakexing_flow_v1";const QJsonObject spend{{"allow_spend",true}};
        {XiakexingFake h;finished(h,"xiakexing",c,spend,why);must(h.accepts==5&&h.handIns==5&&h.whistles==2&&h.buys==1&&verified(h),"Chain skipped a step");}
        {XiakexingFake h;failed(h,"xiakexing",c,{},why);must(why.find("允许支付")!=std::string::npos&&h.buys==0&&h.step==5,why.c_str());}
        {XiakexingFake h;h.skipThree=false;failed(h,"xiakexing",c,spend,why);must(why.find("第 3 步")!=std::string::npos,why.c_str());}
        {XiakexingFake h;h.step=6;finished(h,"xiakexing",c,spend,why);must(h.receipt.contains("already_done"),"Nothing to do");}
    });
    test("nixi_hunt_and_stops",[&]{
        std::string why;const char *c="nixi_flow_v1";const QJsonObject one{{"nixi_minutes",1},{"bjk91",1}};
        {NixiFake h;finished(h,"nixi",c,one,why);must(h.logText.find("已杀 1 个")!=std::string::npos&&h.asks==1&&verified(h),"Hunt missing");}
        {NixiFake h;h.npcForm=true;finished(h,"nixi",c,one,why);must(h.talks==1&&h.logText.find("已杀 1 个")!=std::string::npos,"Talk to fight");}
        {NixiFake h;h.scene=999;failed(h,"nixi",c,one,why);must(why.find("没有寻找坐标")!=std::string::npos,why.c_str());}
        {NixiFake h;QJsonObject cfg=one;cfg.insert(QString::fromUtf8("逆袭地图"),QString::fromUtf8("嵩山"));h.scene=2;h.x=100;h.y=100;finished(h,"nixi",c,cfg,why);must(h.scene==3,"Target map ignored");}
        {NixiFake h;h.leader=false;h.team=2;finished(h,"nixi",c,one,why);must(h.asks==0,"Follower asked");}
    });
}
}
