#pragma once
#include "water_prison_tests.hpp"
#include "object_buffs.hpp"
namespace tlbb {
struct SijueFake:ResidentFake {
    bool active=false,leader=true,full=false,noAccept=false,noEntry=false,noTurnin=false,noNext=false;
    bool missing=false,reused=false,badBuff=false,mechanisms=false,limit=false,together=true,ally=false,earlyExit=false,npcForm=false;
    bool wrongMode=false,badMechanisms=false,spreadPlayers=false,share=false,trap=false,hasPet=false,noPetReceipt=false,unsafeCast=false;
    int mode=0,petOn=1,recalls=0,deploys=0,mechanismReads=0;std::vector<std::pair<double,double>> waypoints;
    int stage=0,mid=1147,hp=100,bellHP=100,addHP=100,ownReads=0,messageReads=0,frames=0;
    int accepts=0,entries=0,deliveries=0,exits=0,transitions=0,moves=0,bellCasts=0,addCasts=0;
    int starts[4]{};QString page="menu",receipt;std::vector<int> attacked;
    const char *names[4]={"闵墨","秦韵","陶青","庞企"};
    const int centers[4][2]={{101,93},{28,100},{97,34},{30,27}};
    QString entryKey()const{return QStringList{"#{SJZ_100129_11}","#{XKFB_250115_04}","#{XKFB_250115_47}","#{XKFB_250115_05}"}[mode];}
    std::string bossName()const{return (QString::fromUtf8(names[stage])+QStringList{"","·闻恶","·识恶","·罚恶"}[wrongMode?3:mode]).toStdString();}
    SijueFake(){scene=1;x=195;y=215;}
    void next(){++stage;hp=100;addHP=100;frames=0;ownReads=0;messageReads=0;npcForm=false;x=centers[stage][0];y=centers[stage][1];page="closed";}
    bool started()const{return starts[stage]>0||!leader;}
    QStringList choices()const{
        if(page=="closed")return {};
        if(scene==1)return page=="entry"?QStringList{entryKey()}:QStringList{"#{SJZ_100129_03}"};
        if(stage==3&&hp==0)return {"#{SJZ_100129_120}"};
        return {"#{YXJJ_091118_19}"};
    }
    std::vector<resident::Object> rows(){
        if(noNext&&stage>0)return {};
        if(missing&&hp==0)return {};
        if(!started())return {};
        std::vector<resident::Object> out{{100+stage,1000+stage,double(centers[stage][0]),double(centers[stage][1]),double(hp),hp>0&&!npcForm,bossName()}};
        if(stage==0&&started()&&bellHP>0)out.push_back({50,500,x,y,double(bellHP),true,"四绝钟"});
        if(stage>=2&&started()&&addHP>0)out.push_back({200+stage,2000+stage,x,y,double(addHP),true,stage==2?"青鹰":"星罗武士"});
        if(mechanisms&&stage==1&&started()&&ownReads>=2&&ownReads<4)out.push_back({77,777,41,87,100,false,"回音幡"});
        return out;
    }
    std::vector<resident::Object> objects()override{
        ++frames;if(ally&&started()&&frames>=6)hp=0;
        if(!leader&&hp==0&&stage<3)next();
        return rows();
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="mechanism_snapshot"){
            ++mechanismReads;if(badMechanisms)return {Value(scene),Value(1),Value(std::string())};
            std::string text;int count=0;
            if(stage==1&&(spreadPlayers||share)){text="1\t43\t904\t28\t114\n";++count;}
            if(trap&&stage==0&&hp>0&&started()){text+="2\t90\t-1\t95\t93\n";++count;}
            return {Value(scene),Value(count),Value(text)};
        }
        if(op=="position"){
            if(!leader&&active&&scene==1&&!(stage==3&&hp==0)){scene=291;x=101;y=93;}
            return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==291?"四绝庄":"苏州"))};
        }
        if(op=="object_buff_ids"){
            if(!QRegularExpression("^-?[0-9]+:-?[0-9]+$").match(QString::fromStdString(v)).hasMatch())throw std::runtime_error("Buff identity format is invalid");
            if(badBuff)throw std::runtime_error("Buff tree/identity unavailable or changed");
            if(v=="-1:-1"){
                ++ownReads;
                if(mechanisms&&stage==1&&started()&&ownReads<3)return {Value(1),Value(std::string("101"))};
            }else if(stage==2&&started()&&addHP>0)return {Value(1),Value(std::string("102"))};
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(hasPet&&petOn?0:-1),Value(123),Value(456)};
        if(code.find("return __tlbbDungeonPet.read(")==0)return {Value(123),Value(456),Value(petOn)};
        if(code.find("return __tlbbDungeonPet.submit(")==0){
            const bool deploy=code.find(",1)")!=std::string::npos;if(deploy)++deploys;else ++recalls;
            if(!noPetReceipt)petOn=deploy?1:0;
            return {Value(1)};
        }
        if(code.find("dungeon:stop-attack")!=std::string::npos)return {Value(42)};
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(2),Value(std::string("42\t903\n43\t904\n"))};
        if(code.find("dungeon:mission")!=std::string::npos){
            if(!active)return {Value(-1),Value(-1),Value(-1),Value(std::string())};
            return {Value(0),Value(mid),Value(stage==3&&hp==0?1:0),Value(std::string("boss progress"))};
        }
        if(code.find("dungeon:leader")!=std::string::npos)return {Value(leader?1:0)};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:buff-names")!=std::string::npos)return {Value(std::string(code.find("(101)")!=std::string::npos?"烛影摇红":"青鹰的守护"))};
        if(code.find("dungeon:dialog")!=std::string::npos){
            if(page=="closed")return {Value(-1),Value(std::string()),Value(std::string())};
            auto text=choices().join('\n');if(limit)text+=" 今日次数已用完";
            return {Value(int(choices().size())),Value(choices().join('\n').toStdString()),Value(text.toStdString())};
        }
        if(code.find("dungeon:button")!=std::string::npos){
            if(code.find("local kind=\"accept\"")!=std::string::npos&&(page=="accept"||(!leader&&!active))){
                if(code.find("if signature==\"accept\"")!=std::string::npos)return {Value(std::string())};
                ++accepts;if(!noAccept){active=true;page="closed";}return {Value(std::string("accept"))};
            }
            if(page=="turnin"&&code.find("local kind=\"continue\"")!=std::string::npos){
                if(code.find("if signature==\"turnin\"")!=std::string::npos)return {Value(std::string())};
                ++deliveries;if(!noTurnin){active=false;hp=100;stage=0;bellHP=100;addHP=100;for(auto &s:starts)s=0;}
                page="closed";return {Value(std::string("turnin"))};
            }
            return {Value(std::string())};
        }
        return ResidentFake::evaluate(code,f,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        if(id==gameplay::CloseAll){page="closed";return {Value(1)};}
        if(id==gameplay::BagSpace)return {Value(full?0:5)};
        if(id==gameplay::NpcTarget){page="menu";return {Value(1)};}
        if(id==gameplay::RunTo){++moves;scene=a.ints[0];x=a.reals[0];y=a.reals[1];waypoints.emplace_back(x,y);return {Value(1)};}
        if(id==gameplay::DebugMessages){
            ++messageReads;
            if(mechanisms&&stage==3&&messageReads==1)return {Value(1),Value(std::string("#{SJZ_100129_73}"))};
            return {Value(0)}; // Real native adapter omits an empty resultText.
        }
        if(id==gameplay::QuestOption){
            const auto label=QString::fromWCharArray(a.text);if(!choices().contains(label))return {Value(0),Value(std::string())};
            if(label=="#{SJZ_100129_03}")page=!active?"accept":stage==3&&hp==0?"turnin":"entry";
            if(label==entryKey()){++entries;if(!noEntry){scene=291;x=trap?89:101;y=93;}page="closed";}
            if(label=="#{YXJJ_091118_19}"){
                if((hp==0||npcForm)&&stage<3){++transitions;next();++starts[stage];}else{++starts[stage];page="closed";}
            }
            if(label=="#{SJZ_100129_120}"){++exits;scene=1;x=195;y=215;page="closed";}
            return {Value(1),Value(label.toStdString())};
        }
        if(id==gameplay::CombatScan){
            auto out=rows();for(const auto &o:out)if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};
            return {Value(a.ints[1]>=0?3:1),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};
        }
        if(id==gameplay::CombatName)return {Value(1),Value(0),Value(bossName())};
        if(id==gameplay::CombatCast){
            if(trap&&stage==0){
                const double dx=101-x,dy=93-y,len=dx*dx+dy*dy;
                const double t=len>0?std::clamp(((95-x)*dx+(93-y)*dy)/len,0.0,1.0):0;
                if(std::pow(x+t*dx-95,2)+std::pow(y+t*dy-93,2)<16)unsafeCast=true;
            }
            ++casts;attacked.push_back(a.ints[1]);if(a.ints[1]==50){bellHP=0;++bellCasts;}
            else if(a.ints[1]>=200){addHP=0;++addCasts;}else hp=0;
            if(reused)++mid;
            if(earlyExit)scene=1;
            return {Value(1)};
        }
        return ResidentFake::snippet(id,a);
    }
};
template<class Test>void sijueTests(const QString &root,Test test){
    auto must=[](bool v,const char *why){if(!v)throw std::runtime_error(why);};QJsonArray cases;
    test("buff_native_tree_bounds_cycles_duplicates_and_identity",[&]{
        QByteArray memory(0x30000,0);
        auto put=[&](uintptr_t at,auto v){must(at+sizeof(v)<=size_t(memory.size()),"Buff fixture write bounds");std::memcpy(memory.data()+at,&v,sizeof(v));};
        auto read=[&](uintptr_t at,void *p,size_t n){if(at+n>size_t(memory.size()))return false;std::memcpy(p,memory.constData()+at,n);return true;};
        const uintptr_t object=0x1000,head=0x2000,node=0x3000,child=0x4000;
        put(object+0x180,head);put(object+0x188,uint64_t(2));put(head+8,node);put(head+25,uint8_t(1));
        put(node,child);put(node+16,head);put(node+32,int(101));put(child,head);put(child+16,head);put(child+32,int(100));std::vector<int> ids;
        must(combat::buffIds(read,object,ids)&&ids.size()==2,"Buff IDs not enumerated");
        put(object+0x188,uint64_t(257));must(!combat::buffIds(read,object,ids),"Unbounded buffs accepted");put(object+0x188,uint64_t(2));
        put(child,node);must(!combat::buffIds(read,object,ids),"Cyclic buff tree accepted");put(child,head);
        put(child+32,int(101));must(!combat::buffIds(read,object,ids),"Duplicate buff IDs accepted");put(child+32,int(100));
        put(child+25,uint8_t(1));must(!combat::buffIds(read,object,ids),"Sentinel as real buff accepted");put(child+25,uint8_t(0));
        put(object+0x188,uint64_t(1));must(!combat::buffIds(read,object,ids),"Buff size mismatch accepted");
        put(object+0x188,uint64_t(0));put(head+8,head);must(combat::buffIds(read,object,ids)&&ids.empty(),"Actual empty buff set rejected");
        // A fake address space uses base=0 so no actual Windows memory is read.
        auto layoutRead=[&](uintptr_t at,void *p,size_t n){
            if(at==combat::managerGlobal&&n==8){uintptr_t m=0x8000;std::memcpy(p,&m,n);return true;}return read(at,p,n);
        };
        put(0x8000,combat::managerVtable);put(0x8108,object);put(0x80e0,head);put(0x80e8,uint64_t(1));put(head+8,node);
        put(node+32,int(10));put(node+40,uintptr_t(0x9000));put(0x9000,combat::npcVtable);put(0x9028,int(10));put(0x902c,int(101));
        must(combat::buffObject(layoutRead,0,object,10,101)==0x9000&&combat::buffObject(layoutRead,0,object,-1,-1)==object,"Buff identity resolver rejected known pair");
        must(!combat::buffObject(layoutRead,0,object,10,999),"Reused server ID accepted for buffs");
        put(0x9048,uint8_t(1));must(!combat::buffObject(layoutRead,0,object,10,101),"Removed buff object accepted");
    });
    test("mechanism_native_typed_coordinates_bounds_and_identity",[&]{
        QByteArray memory(0x30000,0);
        auto put=[&](uintptr_t at,auto v){must(at+sizeof(v)<=size_t(memory.size()),"Mechanism fixture bounds");std::memcpy(memory.data()+at,&v,sizeof(v));};
        auto read=[&](uintptr_t at,void *p,size_t n){
            if(at==combat::managerGlobal&&n==8){uintptr_t manager=0x8000;std::memcpy(p,&manager,n);return true;}
            if(at+n>size_t(memory.size()))return false;
            std::memcpy(p,memory.constData()+at,n);return true;
        };
        const uintptr_t self=0x1000,head=0x2000,node=0x3000,child=0x4000,third=0x5000;
        put(self,combat::selfVtable);put(0x8000,combat::managerVtable);put(0x8108,self);put(0x80e0,head);put(0x80e8,uint64_t(3));put(head+8,node);put(head+25,uint8_t(1));
        auto row=[&](uintptr_t n,int id,uintptr_t obj,uintptr_t vt,int server,float x,float y){
            put(n,head);put(n+16,head);put(n+32,id);put(n+40,obj);put(obj,vt);put(obj+0x28,id);put(obj+0x2c,server);put(obj+0x4c,x);put(obj+0x54,y);
        };
        row(node,10,0x9000,combat::otherVtable,101,12.5f,99.5f);row(child,9,0xa000,combat::specialVtable,-1,13.f,100.f);row(third,11,0xb000,combat::npcVtable,103,14.f,101.f);
        put(node,child);put(node+16,third);std::vector<combat::Mechanism> out;
        must(combat::mechanismSnapshot(read,0,self,out)&&out.size()==2&&out[0].kind==1&&out[0].x==12.5f&&out[1].kind==2,"Typed snapshot did not exclude NPCs/read XZ");
        must(combat::buffObject(read,0,self,10,101)==0x9000,"Other-player Buff pair rejected");
        put(0x902c,102);must(!combat::buffObject(read,0,self,10,101),"Other-player reused Buff identity accepted");put(0x902c,101);
        put(0xa048,uint8_t(1));must(combat::mechanismSnapshot(read,0,self,out)&&out.size()==1,"Removed trap retained");put(0xa048,uint8_t(0));
        put(0x9028,99);must(!combat::mechanismSnapshot(read,0,self,out),"Reused mechanism identity accepted");put(0x9028,10);
        put(0xa04c,std::numeric_limits<float>::infinity());must(!combat::mechanismSnapshot(read,0,self,out),"Non-finite coordinate accepted");put(0xa04c,13.f);
        put(child,node);must(!combat::mechanismSnapshot(read,0,self,out),"Cyclic mechanism tree accepted");put(child,head);
        put(0x80e8,uint64_t(513));must(!combat::mechanismSnapshot(read,0,self,out),"Unbounded snapshot accepted");put(0x80e8,uint64_t(3));
        put(head+25,uint8_t(0));must(!combat::mechanismSnapshot(read,0,self,out),"Invalid tree sentinel accepted");
    });
    test("sijue_config_bounds_engine_and_difficulty",[&]{
        auto c=combatTestConfig("sijue");c.insert("dungeon_team_count",3);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",1800);
        c.insert("sjz_type","普通");c.insert("sijue_bell_role","队长");c.insert("sijue_diagonal",false);c.insert("sijue_columns",true);c.insert("sijue_blind_share",false);c.insert("sijue_trap_distance",4);QString error;
        must(validateLegacyConfig(c,error),qPrintable(error));
        for(const auto &key:QStringList{"dungeon_team_count","dungeon_rounds","dungeon_wait_seconds","dungeon_battle_seconds"}){auto b=c;b.insert(key,0);must(!validateLegacyConfig(b,error),"Invalid Sijue numeric accepted");}
        auto b=c;b.insert("engine","外部兼容");must(!validateLegacyConfig(b,error),"Sijue accepted external mode");
        for(const auto &mode:QStringList{"普通","初级","中级","高级"}){b=c;b.insert("sjz_type",mode);must(validateLegacyConfig(b,error),qPrintable(error));}
        b=c;b.insert("sjz_type","未知");must(!validateLegacyConfig(b,error),"Unknown Sijue difficulty accepted");
        for(const auto &v:QJsonArray{0,11,3.5,"4"}){b=c;b.insert("sijue_trap_distance",v);must(!validateLegacyConfig(b,error),"Invalid trap clearance accepted");}
        b=c;b.insert("sijue_diagonal","false");must(!validateLegacyConfig(b,error),"Sijue accepted string boolean");
        b=c;b.remove("sijue_bell_role");must(!validateLegacyConfig(b,error),"Old Sijue queue without assignment accepted");
    });
    auto run=[&](SijueFake &h,QJsonObject c,std::string &why,bool healOnly=false){
        c.insert("legacy_id","sijue");c.insert("combat",true);c.insert("dungeon_wait_seconds",5);c.insert("dungeon_team_wait_seconds",30);
        QJsonObject meta;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","sijue",meta,path,error),qPrintable(error));
        must(meta.value("validation_contract")==QJsonValue("sijue_flow_v1"),"Sijue completion contract missing");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,c,error);must(!source.isEmpty()&&error.isEmpty(),qPrintable(error));
        must(!source.contains("__original_rules="),"Sijue still loads vendor framework");
        if(healOnly)source.replace("local function __task_entry()","CombatRuntime.canAttack=function() return false end\nlocal function __task_entry()");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=180000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();cases.append(QJsonObject{{"state",int(vm.state())},{"error",QString::fromStdString(why)},{"log",QString::fromStdString(h.logText)},{"mode",h.mode},{"accepts",h.accepts},{"entries",h.entries},{"casts",h.casts},{"bell_casts",h.bellCasts},{"add_casts",h.addCasts},{"recalls",h.recalls},{"deploys",h.deploys},{"transitions",h.transitions},{"exits",h.exits},{"deliveries",h.deliveries},{"peak_lua_bytes",double(peak)}});return vm.state();
    };
    test("sijue_four_bosses_bell_adds_exit_delivery_and_queue",[&]{
        SijueFake h;std::string why;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        must(h.accepts==1&&h.entries==1&&h.transitions==3&&h.exits==1&&h.deliveries==1,"Sijue skipped/replayed phases");
        must(h.bellCasts==1&&h.addCasts==2&&h.casts==7&&h.scene==1&&!h.active,"Sijue combat/terminal state wrong");
        must(h.attacked==std::vector<int>{50,100,101,202,102,203,103},"Sijue did not prioritize mechanisms/adds");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Sijue completion is not verified");
        FlowRunner f;QString e;auto n=QJsonObject{{"node_id","sijue"},{"task","sijue"},{"enabled",true},{"params",QJsonObject{}}};auto next=n;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{n,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));
        auto time=QDateTime(QDate(2026,10,30),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());
        must(f.poll(time).value("node_id")==QJsonValue("next"),"Sijue receipt did not release next queue item");
    });
    test("sijue_buffs_banners_and_dragon_column_movement",[&]{
        SijueFake h;h.mechanisms=true;std::string why;must(run(h,{{"sijue_diagonal",true}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        must(h.logText.find("烛影摇红")!=std::string::npos&&h.logText.find("回音幡")!=std::string::npos&&h.logText.find("龙柱引导")!=std::string::npos,("Sijue mechanisms did not run\n"+h.logText).c_str());
    });
    test("sijue_all_difficulty_entries_and_suffixes",[&]{
        for(int i=1;i<=3;++i){SijueFake h;h.mode=i;std::string why;
            must(run(h,{{"sjz_type",QStringList{"普通","初级","中级","高级"}[i]}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
            must(h.entries==1&&h.casts==7&&h.deliveries==1,"High difficulty skipped actual combat chain");}
        SijueFake h;h.wrongMode=true;std::string why;must(run(h,{},why)==resident::Vm::Failed&&h.casts==0,"Wrong difficulty suffix was attacked");
    });
    test("sijue_trap_route_and_target_resume",[&]{
        SijueFake h;h.trap=true;std::string why;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        must(!h.unsafeCast&&h.casts==7&&h.deliveries==1,"Combat chased through a trap or failed to resume");
    });
    test("sijue_spread_uses_players_not_fixed_point",[&]{
        SijueFake h;h.mechanisms=true;h.spreadPlayers=true;std::string why;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        bool spread=false;for(auto [x,y]:h.waypoints)if(y==114&&x>=16&&x<=40&&std::abs(x-28)>=6)spread=true;
        must(spread,"Candle movement ignored other players");
    });
    test("sijue_mechanism_pet_recall_and_restore",[&]{
        SijueFake h;h.mechanisms=true;h.hasPet=true;std::string why;
        must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.recalls>=2&&h.recalls==h.deploys&&h.petOn==1,"Mechanism pet guard did not restore original pet");
        SijueFake bad;bad.mechanisms=true;bad.hasPet=true;bad.noPetReceipt=true;
        must(run(bad,{},why)==resident::Vm::Failed&&bad.recalls==1&&bad.deploys==0,"Unacknowledged recall was replayed");
    });
    test("sijue_blind_share_role_waits_and_keeps_team_progress",[&]{
        SijueFake h;h.active=true;h.scene=291;h.stage=1;h.starts[1]=1;h.x=28;h.y=100;h.share=true;h.ally=true;std::string why;
        must(run(h,{{"sijue_blind_share",true}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        must(h.logText.find("分担失明待命")!=std::string::npos&&h.deliveries==1,"Sharing role never ran or blocked final handoff");
        for(int id:h.attacked)must(id!=101,"Sharing role attacked Qin Yun instead of waiting");
        SijueFake bad;bad.badMechanisms=true;must(run(bad,{},why)==resident::Vm::Failed&&bad.casts==0,"Bad mechanism snapshot was treated as empty");
    });
    test("sijue_resume_and_multiple_rounds",[&]{
        std::string why;
        for(int i=0;i<4;++i){SijueFake h;h.active=true;h.scene=291;h.stage=i;h.starts[i]=1;h.x=h.centers[i][0];h.y=h.centers[i][1];
            must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.accepts==0&&h.entries==0&&h.exits==1,"Sijue resume restarted entrance");}
        SijueFake h;must(run(h,{{"dungeon_rounds",2}},why)==resident::Vm::Completed,why.c_str());must(h.accepts==2&&h.entries==2&&h.deliveries==2&&h.casts==14,"Sijue rounds lost state isolation");
        SijueFake npc;npc.active=true;npc.scene=291;npc.stage=1;npc.starts[1]=1;npc.x=28;npc.y=100;npc.npcForm=true;
        must(run(npc,{},why)==resident::Vm::Completed,why.c_str());must(npc.casts==4&&npc.transitions==2,"Friendly boss form was attacked instead of advancing");
    });
    test("sijue_unknown_state_not_replayed_or_completed",[&]{
        for(int i=0;i<8;++i){SijueFake h;h.noAccept=i==0;h.noEntry=i==1;h.noTurnin=i==2;h.noNext=i==3;h.missing=i==4;h.reused=i==5;h.badBuff=i==6;h.earlyExit=i==7;
            std::string why;must(run(h,{},why)==resident::Vm::Failed,(why+"\n"+h.logText).c_str());must(h.accepts<=1&&h.entries<=1&&h.deliveries<=1&&h.receipt.isEmpty()&&h.stops>0,"Unknown Sijue state replayed or reported done");}
    });
    test("sijue_preconditions_and_actual_limit",[&]{
        for(int i=0;i<2;++i){SijueFake h;h.full=i==0;h.together=i!=1;std::string why;must(run(h,{},why)==resident::Vm::Failed,why.c_str());must(h.accepts==0&&h.casts==0,"Sijue accepted before readiness");}
        SijueFake h;h.limit=true;std::string why;must(run(h,{},why)==resident::Vm::Completed,why.c_str());must(h.accepts==0&&h.receipt.contains("limit_reached"),"NPC limit did not stop entry");
    });
    test("sijue_emei_heal_only_waits_for_team_progress",[&]{
        SijueFake h;h.active=true;h.scene=291;h.x=101;h.y=93;h.ally=true;std::string why;
        must(run(h,{},why,true)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.casts==0&&h.deliveries==1,"Heal-only role issued output or failed team progression");
    });
    test("sijue_follower_and_bell_assignment",[&]{
        SijueFake h;h.leader=false;h.ally=true;std::string why;
        must(run(h,{},why,true)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==0&&h.accepts==1&&h.casts==0,"Follower selected leader-only entry or combat");
        SijueFake owner;must(run(owner,{{"sijue_bell_role","其他队友"}},why)==resident::Vm::Completed,why.c_str());
        must(owner.bellCasts==0,"Other member's bell assignment was ignored");
    });
    QFile report(QCoreApplication::applicationDirPath()+"/sijue-tests.json");must(report.open(QIODevice::WriteOnly),"Sijue report unavailable");report.write(QJsonDocument(cases).toJson());
}
}
