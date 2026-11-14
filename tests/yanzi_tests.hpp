#pragma once
#include "sijue_tests.hpp"
namespace tlbb {
struct YanziFake:ResidentFake {
    int stage=0,mode=0,used=0,limit=2,duan=100,yue=100,yun=100,jiumo=100,mrf=100,wyy=100,wave=0,frames=0,reflectReads=0;
    int entries=0,duanStarts=0,qianStarts=0,tunnels=0,exits=0,pickups=0,uses=0,recalls=0,deploys=0;
    int petOn=1,antidote=0,boxes=0;bool opened=false,spawned=false,leader=true,full=false,together=true,teamNearby=true;
    bool noEntry=false,noStart=false,noTunnel=false,noExit=false,noCount=false,badCampaign=false,wrongSuffix=false,missing=false,reused=false;
    bool poison=false,poisoned=false,noAntidote=false,noItemEffect=false,badIce=false,ice=false,hasPet=false,noPetReceipt=false,qianDead=false;
    bool staleMessages=false,ally=false,mrfWasSeen=false,delayedFirst=false,noFirstEffect=false,pendingFirst=false,cancelledFirst=false;int firstReads=0;
    bool lootWindow=false,duanLooted=false,mrfLooted=false,noLootOpen=false;int lootOpens=0;
    QString page="closed",receipt;std::vector<int> attacked;std::vector<std::pair<double,double>> moves;
    YanziFake(){scene=4;x=70;y=120;}
    QString modeKey()const{return QStringList{"讨伐燕子坞","#{XKFB_250115_08}","#{XKFB_250115_49}","#{XKFB_250115_09}"}[mode];}
    std::string name(const QString &n)const{return (n+QStringList{"","·闻恶","·识恶","·罚恶"}[wrongSuffix?3:mode]).toStdString();}
    void reset(){stage=0;duan=yue=yun=jiumo=mrf=wyy=100;wave=0;opened=spawned=mrfWasSeen=false;reflectReads=0;poisoned=false;duanLooted=mrfLooted=lootWindow=false;}
    QStringList choices()const{
        if(page=="closed")return {};
        if(scene==4)return page=="entry"?QStringList{modeKey()}:QStringList{"讨伐燕子坞"};
        if(stage==3)return wave==9?QStringList{"从地道进入燕子坞"}:QStringList{};
        return {"战斗吧！"};
    }
    std::vector<resident::Object> rows(){
        if(scene!=236)return {};
        if(stage==0&&duan==0&&x>190&&y<190){stage=2;opened=false;}
        if(stage==0){
            if(!leader)opened=true;
            if(!opened)return {{10,110,79,203,100,false,"呼延豹"}};
            if(missing&&duan==0)return {};
            std::vector<resident::Object> r{{100,reused&&duan==0?1001:1000,83,203,double(duan),duan>0,name("段延庆")}};
            if(yue>0)r.push_back({101,1002,82,202,double(yue),true,name("岳老三")});
            if(yun>0)r.push_back({102,1003,84,202,double(yun),true,name("云中鹤")});
            return r;
        }
        if(stage==2){
            std::vector<resident::Object> r{{20,120,217,150,double(qianDead&&opened?0:100),false,"钱宏宇"}};
            if(!leader&&!opened){opened=true;wave=1;}
            if(opened&&wave<9)r.push_back({200+wave,2000+wave,217,150,100,true,"燕子坞援军"});
            else if(opened&&wave==9)r.push_back({300,3000,220,158,double(jiumo),jiumo>0,name("鸠摩智")});
            return r;
        }
        if(stage==3)return {{30,130,180,88,100,false,"华赫艮"}};
        if(stage==4){
            if(!spawned)return {};
            if(mrf>0)mrfWasSeen=true;
            if(missing&&mrf==0)return {};
            std::vector<resident::Object> r{{400,4000,49,80,double(mrf),mrf>0,name("慕容复")}};
            if(wyy>0)r.push_back({401,4001,53,80,double(wyy),true,name("王语嫣")});
            return r;
        }
        return {};
    }
    std::vector<resident::Object> objects()override{
        ++frames;
        if(pendingFirst&&!noFirstEffect&&++firstReads>=3){mrf=97;pendingFirst=false;}
        if(ally&&frames%4==0){
            if(stage==0&&opened)duan=yue=yun=0;
            else if(stage==2&&opened){if(wave<9)++wave;else jiumo=0;}
            else if(stage==4&&spawned&&mrf>0&&mrfWasSeen){mrf=0;if(!noCount)++used;}
        }
        return rows();
    }
    resident::Values call(const std::string &op,const std::string &v)override{
        using resident::Value;
        if(op=="task_result"){receipt=QString::fromStdString(v);return {};}
        if(op=="position")return {Value(true),Value(scene),Value(x),Value(y),Value(std::string(scene==236?"燕子坞":"太湖"))};
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="loot_snapshot"){
            std::string text;if(stage==0&&duan==0&&!duanLooted)text="3\t500\t1500\t83\t203\n";
            if(stage==4&&mrf==0&&!mrfLooted)text="3\t501\t1501\t49\t80\n";
            return {Value(scene),Value(text.empty()?0:1),Value(text)};
        }
        if(op=="open_loot"){if(v!="500:1500"&&v!="501:1501")throw std::runtime_error("Wrong ground loot pair");++lootOpens;if(!noLootOpen)lootWindow=true;return {Value(1)};}
        if(op=="mechanism_snapshot"){
            const auto text=std::string("1\t43\t904\t")+std::to_string(teamNearby?x:300)+"\t"+std::to_string(y)+"\n1\t44\t905\t"+std::to_string(x)+"\t"+std::to_string(y)+"\n";
            return {Value(scene),Value(2),Value(text)};
        }
        if(op=="object_buff_ids"){
            if(v=="-1:-1"&&poison&&stage==2&&!poisoned)return {Value(1),Value(std::string("1001"))};
            if(v=="400:4000"&&mrf<100&&mrf>0&&reflectReads<3){++reflectReads;return {Value(1),Value(std::string("1002"))};}
            return {Value(0),Value(std::string())};
        }
        return ResidentFake::call(op,v);
    }
    resident::Values evaluate(const std::string &code,const std::string &f,int n)override{
        using resident::Value;
        if(code.find("yanzi:campaign-refresh")!=std::string::npos)return {};
        if(code.find("yanzi:campaign")!=std::string::npos){if(badCampaign)return {Value(0),Value(-1),Value(0),Value(0),Value(std::string("讨伐燕子坞"))};return {Value(used),Value(limit),Value(0),Value(0),Value(std::string("讨伐燕子坞"))};}
        if(code.find("yanzi:use-item")!=std::string::npos){++uses;if(!noItemEffect){if(code.find("悲酥清风解药")!=std::string::npos){--antidote;poisoned=true;}else{--boxes;++antidote;}}return {Value(1)};}
        if(code.find("yanzi:item")!=std::string::npos){
            const bool potion=code.find("悲酥清风解药")!=std::string::npos;const int total=potion?antidote:code.find("段延庆的宝箱\"")!=std::string::npos?boxes:0;
            return {Value(total?0:-1),Value(total?100:-1),Value(total),Value(total)};
        }
        if(code.find("yanzi:loot-visible")!=std::string::npos)return {Value(lootWindow)};
        if(code.find("yanzi:loot-close")!=std::string::npos){lootWindow=false;return {};}
        if(code.find("yanzi:pickup")!=std::string::npos){if(!lootWindow)throw std::runtime_error("Ground package not open");++pickups;if(stage==0){duanLooted=true;if(!noAntidote)boxes=1;}else mrfLooted=true;lootWindow=false;return {};}
        if(code.find("yanzi:temporary-antidote")!=std::string::npos)return {};
        if(code.find("yanzi:temporary-take")!=std::string::npos){if(!noAntidote)antidote=1;return {};}
        if(code.find("dungeon:pet-guard-init")!=std::string::npos)return {};
        if(code=="return __tlbbDungeonPet.find()")return {Value(hasPet&&petOn?0:-1),Value(123),Value(456)};
        if(code.find("return __tlbbDungeonPet.read(")==0)return {Value(123),Value(456),Value(petOn)};
        if(code.find("return __tlbbDungeonPet.submit(")==0){const bool on=code.find(",1)")!=std::string::npos;if(on)++deploys;else ++recalls;if(!noPetReceipt)petOn=on?1:0;return {Value(1)};}
        if(code.find("dungeon:stop-attack")!=std::string::npos){if(pendingFirst)cancelledFirst=true;return {Value(42)};}
        if(code.find("dungeon:team-identities")!=std::string::npos)return {Value(3),Value(std::string("42\t903\n43\t904\n44\t905\n"))};
        if(code.find("dungeon:team-together")!=std::string::npos)return {Value(together?1:0)};
        if(code.find("dungeon:leader")!=std::string::npos){if(!leader&&scene==4){scene=236;x=79;y=203;reset();}return {Value(leader?1:0)};}
        if(code.find("dungeon:cinematic")!=std::string::npos)return {};
        if(code.find("dungeon:buff-names")!=std::string::npos)return {Value(std::string(code.find("(1001)")!=std::string::npos?"就擒：无法使用":"斗转星移"))};
        if(code.find("dungeon:dialog")!=std::string::npos){auto opts=choices();return {Value(page=="closed"?-1:int(opts.size())),Value(opts.join('\n').toStdString()),Value(opts.join('\n').toStdString())};}
        return ResidentFake::evaluate(code,f,n);
    }
    resident::Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        using resident::Value;
        if(id==gameplay::BagSpace)return {Value(full?0:5)};
        if(id==gameplay::CloseAll){page="closed";return {Value(1)};}
        if(id==gameplay::NpcTarget){page="menu";if(QString::fromWCharArray(a.text)=="华赫艮")stage=3;return {Value(1)};}
        if(id==gameplay::RunTo){
            scene=a.ints[0];x=a.reals[0];y=a.reals[1];moves.emplace_back(x,y);
            if(stage==4&&x==60&&y==70)spawned=true;
            if(stage==4&&!leader&&x==49&&y==89)spawned=true; // Offline teammate opens the encounter.
            if(stage==4&&mrf==0&&x==62&&y==20&&!noExit){scene=4;++exits;}
            return {Value(1)};
        }
        if(id==gameplay::QuestOption){
            const auto label=QString::fromWCharArray(a.text);if(!choices().contains(label))return {Value(0)};
            if(scene==4){if(label==modeKey()&&(mode==0||page=="entry")){++entries;if(!noEntry){scene=236;x=79;y=203;reset();}page="closed";}else page="entry";}
            else if(label=="战斗吧！"){
                if(stage==0)++duanStarts;else ++qianStarts;
                if(!noStart){opened=true;if(stage==2)wave=1;}page="closed";
            }else if(label=="从地道进入燕子坞"){++tunnels;if(!noTunnel){stage=4;x=49;y=115;}page="closed";}
            return {Value(1),Value(label.toStdString())};
        }
        if(id==gameplay::DebugMessages){
            std::string msg=staleMessages?"慕容复已被打败\n警惕！第9拨燕子坞援军已经赶至，还有0拨燕子坞援军即将赶来。\n":"";
            if(stage==2&&wave>0)msg+="警惕！第"+std::to_string(wave)+"拨燕子坞援军已经赶至\n";
            if(stage==2&&jiumo==0)msg+="鸠摩智被打败，其手下纷纷四散逃窜。\n";
            if(stage==4&&ice&&mrf>0&&mrf<100)msg+=badIce?"YZW_MRF_SKILL_BTXD:bad":"YZW_MRF_SKILL_BTXD:49,80";
            return msg.empty()?resident::Values{Value(0)}:resident::Values{Value(1),Value(msg)};
        }
        if(id==gameplay::CombatScan){for(auto &o:rows())if(o.id==a.ints[1]&&o.server==a.ints[2])return {Value(o.hp<=0?2:1),Value(o.id),Value(o.server),Value(o.hp),Value(o.x),Value(o.y),Value(1),Value(100)};return {Value(3),Value(-1),Value(-1),Value(0),Value(0),Value(0),Value(0),Value(100)};}
        if(id==gameplay::CombatCast){
            ++casts;attacked.push_back(a.ints[1]);
            if(a.ints[1]==100)duan=0;
            else if(a.ints[1]==101)yue=0;
            else if(a.ints[1]==102)yun=0;
            else if(a.ints[1]>=200&&a.ints[1]<300)++wave;
            else if(a.ints[1]==300)jiumo=0;
            else if(a.ints[1]==401)wyy=0;
            else if(a.ints[1]==400){if(mrf==100&&(delayedFirst||noFirstEffect))pendingFirst=true;else mrf=mrf==100?97:mrf>50?40:0;if(mrf==0&&!noCount)++used;}
            return {Value(1)};
        }
        return ResidentFake::snippet(id,a);
    }
};
template<class Test>void yanziTests(const QString &root,Test test){
    auto must=[](bool x,const char *s){if(!x)throw std::runtime_error(s);};QJsonArray report;
    auto run=[&](YanziFake &h,QJsonObject cfg,std::string &why,bool healOnly=false){
        cfg.insert("legacy_id","yanzi");cfg.insert("combat",true);cfg.insert("dungeon_wait_seconds",5);cfg.insert("dungeon_team_wait_seconds",30);
        QJsonObject entry;QString path,error;must(resolveLegacyEntry(root+"/scripts/legacy","yanzi",entry,path,error),qPrintable(error));
        must(entry.value("validation_contract")==QJsonValue("yanzi_flow_v1"),"Yanzi has no completion contract");
        auto source=prepareResidentScript(root+"/scripts/legacy",path,cfg,error);must(!source.isEmpty(),qPrintable(error));must(!source.contains("__original_rules="),"Yanzi still loads mixed vendor framework");
        if(healOnly)source.replace("local function __task_entry()","CombatRuntime.canAttack=function() return false end\nlocal function __task_entry()");
        resident::Vm vm(h);must(vm.start(source.toStdString(),why),why.c_str());size_t peak=0;
        for(uint64_t t=0;t<=300000&&(vm.state()==resident::Vm::Running||vm.state()==resident::Vm::Sleeping);t+=20){vm.step(t);peak=qMax(peak,vm.allocated());}
        why=vm.error();report.append(QJsonObject{{"state",int(vm.state())},{"mode",h.mode},{"error",QString::fromStdString(why)},{"log",QString::fromStdString(h.logText)},{"entries",h.entries},{"duan_starts",h.duanStarts},{"qian_starts",h.qianStarts},{"tunnels",h.tunnels},{"exits",h.exits},{"casts",h.casts},{"uses",h.uses},{"recalls",h.recalls},{"deploys",h.deploys},{"used",h.used},{"peak_lua_bytes",double(peak)}});
        QFile progress(QCoreApplication::applicationDirPath()+"/yanzi-tests.json");must(progress.open(QIODevice::WriteOnly),"Yanzi running report unavailable");progress.write(QJsonDocument(report).toJson());return vm.state();
    };
    test("yanzi_full_four_stage_combat_exit_counter_and_queue",[&]{
        YanziFake h;std::string why;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());
        must(h.entries==1&&h.duanStarts==1&&h.qianStarts==1&&h.tunnels==1&&h.exits==1&&h.used==1,"Yanzi missed/replayed stages");
        must(h.casts==15&&h.attacked.front()==100&&h.attacked.back()==400&&std::count(h.attacked.begin(),h.attacked.end(),101)==1&&std::count(h.attacked.begin(),h.attacked.end(),102)==1,"Yanzi did not fight all waves and bosses");
        auto receipt=QJsonDocument::fromJson(h.receipt.toUtf8()).object();must(TaskCompletion::verified(receipt),"Yanzi result not verified");
        FlowRunner f;QString e;QJsonObject first{{"node_id","yanzi"},{"task","yanzi"},{"enabled",true},{"params",QJsonObject{}}};auto next=first;next.insert("node_id","next");next.insert("task","wait");
        must(f.start({{"queue",QJsonArray{first,next}},{"scheduled",QJsonArray{}},{"flow",QJsonObject{}}},e),qPrintable(e));auto time=QDateTime(QDate(2026,10,31),QTime(12,0));f.poll(time);f.finish(TaskCompletion::verified(receipt),receipt.value("status").toString());must(f.poll(time).value("node_id")==QJsonValue("next"),"Yanzi receipt did not release next queue item");
    });
    test("yanzi_difficulties_and_wrong_suffix",[&]{
        std::string why;for(int i=1;i<=3;++i){YanziFake h;h.mode=i;must(run(h,{{"yzw_type",QStringList{"普通","初级","中级","高级"}[i]}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==1&&h.used==1,"Yanzi difficulty did not finish");}
        YanziFake h;h.wrongSuffix=true;must(run(h,{},why)==resident::Vm::Failed&&h.casts==0,"Wrong difficulty boss attacked");
    });
    test("yanzi_reflection_ice_poison_and_pet_restore",[&]{
        YanziFake h;h.poison=true;h.ice=true;h.hasPet=true;std::string why;
        must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.uses==2&&h.poisoned&&h.recalls>=1&&h.recalls==h.deploys&&h.petOn==1,"Yanzi did not restore supplies/pet");
        must(h.logText.find("斗转星移停手")!=std::string::npos&&h.logText.find("冰天雪地避让")!=std::string::npos,"Yanzi special mechanics not exercised");
    });
    test("yanzi_first_output_waits_for_animation_or_stops_without_replay",[&]{
        YanziFake h;h.delayedFirst=true;std::string why;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(!h.cancelledFirst&&h.used==1,"Initial attack cancelled before damage receipt");
        YanziFake bad;bad.noFirstEffect=true;must(run(bad,{},why)==resident::Vm::Failed,why.c_str());must(std::count(bad.attacked.begin(),bad.attacked.end(),400)==1&&bad.receipt.isEmpty(),"Initial output was replayed without feedback");
    });
    test("yanzi_resume_multiple_rounds_and_optional_wyy",[&]{
        std::string why;
        for(int s:{0,2,4}){YanziFake h;h.scene=236;h.stage=s;h.opened=s==0;h.spawned=s==4;h.x=s==4?49:s==2?217:83;h.y=s==4?89:s==2?150:203;
            must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==0&&h.exits==1,"Yanzi resume restarted entry");}
        YanziFake h;must(run(h,{{"dungeon_rounds",2},{"yanzi_kill_wyy",true}},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.used==2&&h.entries==2&&std::count(h.attacked.begin(),h.attacked.end(),401)==2,"Yanzi rounds/WYY config lost");
    });
    test("yanzi_no_feedback_is_not_replayed_or_completed",[&]{
        for(int i=0;i<9;++i){YanziFake h;h.noEntry=i==0;h.noStart=i==1;h.noTunnel=i==2;h.noExit=i==3;h.noCount=i==4;h.badCampaign=i==5;h.reused=i==6;h.poison=i==7;h.noAntidote=i==7;h.hasPet=i==8;h.noPetReceipt=i==8;std::string why;
            must(run(h,{},why)==resident::Vm::Failed,(why+"\n"+h.logText).c_str());must((h.noEntry?h.entries<=6:h.entries<=1)&&h.duanStarts<=1&&h.qianStarts<=1&&h.tunnels<=1&&h.receipt.isEmpty(),"Yanzi replayed uncertain action or marked done");}
    });
    test("yanzi_preconditions_limits_stale_messages_and_invalid_ice",[&]{
        for(int i=0;i<3;++i){YanziFake h;h.full=i==0;h.together=i!=1;h.teamNearby=i!=2;std::string why;must(run(h,{},why)==resident::Vm::Failed&&h.entries==0,why.c_str());}
        YanziFake h;h.used=h.limit;std::string why;must(run(h,{},why)==resident::Vm::Completed&&h.entries==0&&h.receipt.contains("already_done"),"Daily limit not respected");
        YanziFake old;old.staleMessages=true;must(run(old,{},why)==resident::Vm::Completed,(why+"\n"+old.logText).c_str());must(old.casts==15,"History messages skipped combat");
        YanziFake ice;ice.ice=true;ice.badIce=true;must(run(ice,{},why)==resident::Vm::Failed&&ice.receipt.isEmpty(),"Malformed ice was ignored");
        YanziFake item;item.poison=true;item.noItemEffect=true;must(run(item,{},why)==resident::Vm::Failed&&item.uses==1,"Unconfirmed item use repeated");
        YanziFake qian;qian.qianDead=true;must(run(qian,{},why)==resident::Vm::Failed&&qian.tunnels==0,"Qian protection failure ignored");
    });
    test("yanzi_follower_and_emei_heal_only",[&]{
        std::string why;YanziFake h;h.leader=false;must(run(h,{},why)==resident::Vm::Completed,(why+"\n"+h.logText).c_str());must(h.entries==0&&h.duanStarts==0&&h.qianStarts==0,"Follower opened leader-only stage");
        YanziFake support;support.ally=true;must(run(support,{},why,true)==resident::Vm::Completed,(why+"\n"+support.logText).c_str());must(support.casts==0&&support.used==1,"Heal-only role issued output or failed completion");
    });
    test("yanzi_config_engine_modes_and_types",[&]{
        auto c=combatTestConfig("yanzi");c.insert("dungeon_team_count",3);c.insert("dungeon_rounds",1);c.insert("dungeon_wait_seconds",45);c.insert("dungeon_battle_seconds",1800);c.insert("yzw_type","普通");c.insert("yanzi_kill_wyy",false);c.insert("yanzi_supplies",true);c.insert("yanzi_loot",true);QString e;
        must(validateLegacyConfig(c,e),qPrintable(e));auto bad=c;bad.insert("engine","外部兼容");must(!validateLegacyConfig(bad,e),"Yanzi external engine accepted");bad=c;bad.insert("yanzi_loot","true");must(!validateLegacyConfig(bad,e),"Yanzi string switch accepted");bad=c;bad.insert("yzw_type","");must(!validateLegacyConfig(bad,e),"Old empty difficulty accepted");
    });
    test("yanzi_ground_loot_requires_open_window_before_taking",[&]{
        YanziFake h;h.noLootOpen=true;std::string why;must(run(h,{},why)==resident::Vm::Failed,why.c_str());
        must(h.lootOpens==1&&h.pickups==0&&h.qianStarts==0&&h.receipt.isEmpty(),"Unopened package was taken/reopened or stage continued");
    });
    test("yanzi_native_loot_type_identity_range_and_interface",[&]{
        QByteArray memory(0x30000,0);const uintptr_t self=0x1000,head=0x2000,node=0x3000,obj=0x9000,input=0xa000;
        auto put=[&](uintptr_t at,auto v){must(at+sizeof(v)<=size_t(memory.size()),"Loot fixture bounds");std::memcpy(memory.data()+at,&v,sizeof(v));};
        uintptr_t openFn=combat::openLootFunction;
        auto read=[&](uintptr_t at,void *to,size_t n){
            uintptr_t result=at==combat::managerGlobal?0x8000:at==combat::inputGlobal?input:at==combat::inputVtable+0x110?openFn:0;
            if(result&&n==sizeof(result)){std::memcpy(to,&result,n);return true;}
            if(at+n>size_t(memory.size()))return false;
            std::memcpy(to,memory.constData()+at,n);return true;
        };
        put(self,combat::selfVtable);put(self+0x4c,80.f);put(self+0x54,200.f);put(input,combat::inputVtable);
        put(0x8000,combat::managerVtable);put(0x8108,self);put(0x80e0,head);put(0x80e8,uint64_t(1));put(head+8,node);put(head+25,uint8_t(1));
        put(node,head);put(node+16,head);put(node+32,50);put(node+40,obj);put(obj,combat::lootVtable);put(obj+0x28,50);put(obj+0x2c,500);put(obj+0x4c,82.f);put(obj+0x54,201.f);
        std::vector<combat::Mechanism> rows;
        must(combat::mechanismSnapshot(read,0,self,rows)&&rows.empty(),"Loot leaked into trap/player snapshot");
        must(combat::mechanismSnapshot(read,0,self,rows,true)&&rows.size()==1&&rows[0].kind==3,"Typed ItemBox snapshot unavailable");
        must(combat::lootOpenReady(read,0,self,input,50,500),"Current close ItemBox rejected");
        must(!combat::lootOpenReady(read,0,self,input,50,501),"Reused loot pair accepted");
        put(obj+0x4c,85.f);must(!combat::lootOpenReady(read,0,self,input,50,500),"Remote package accepted");put(obj+0x4c,82.f);
        put(obj,combat::npcVtable);must(!combat::lootOpenReady(read,0,self,input,50,500),"NPC accepted as package");put(obj,combat::lootVtable);
        put(obj+0x48,uint8_t(1));must(!combat::lootOpenReady(read,0,self,input,50,500),"Removed package accepted");put(obj+0x48,uint8_t(0));
        openFn++;must(!combat::lootOpenReady(read,0,self,input,50,500),"Foreign input function accepted");openFn--;
        put(input,uintptr_t(7));must(!combat::lootOpenReady(read,0,self,input,50,500),"Foreign input class accepted");
    });
    QFile f(QCoreApplication::applicationDirPath()+"/yanzi-tests.json");must(f.open(QIODevice::WriteOnly),"Yanzi report unavailable");f.write(QJsonDocument(report).toJson());
}
}
