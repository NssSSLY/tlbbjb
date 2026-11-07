#pragma once
#include "combat_world.hpp"
#include <stdexcept>
#include <QMap>
#include <QFile>
#include <cstring>
#include <limits>
namespace tlbb {
inline QJsonObject combatTestConfig(QString id="dungeon_combat"){
    return {{"legacy_id",id},{"combat",true},{"combat_scene",id=="zhenlong_combat"?61:3},{"combat_radius",45},{"combat_min_hp",25},
        {"combat_interval_ms",1000},{"combat_stall_seconds",60},{"combat_kill_goal",1},{"combat_skills",""},
        {"entry_mode","自动入场"},{"timeout_seconds",2400}};
}
template<class Test>void combatTests(const QString &root,const QString &temporary,Test test){
    auto must=[](bool value,const char *why){if(!value)throw std::runtime_error(why);};
    test("combat_native_snapshot_bounds_identity_and_hostility",[&]{
        QMap<uintptr_t,QByteArray> memory;
        auto add=[&](uintptr_t at,int n){memory.insert(at,QByteArray(n,0));};
        auto put=[&](uintptr_t at,auto value){auto it=memory.upperBound(at);must(it!=memory.begin(),"fixture address missing");--it;const auto index=at-it.key();must(index+sizeof(value)<=size_t(it->size()),"fixture bounds");std::memcpy(it->data()+index,&value,sizeof(value));};
        auto read=[&](uintptr_t at,void *to,size_t n){auto it=memory.upperBound(at);if(it==memory.begin())return false;--it;const auto index=at-it.key();if(index+n>size_t(it->size()))return false;std::memcpy(to,it->constData()+index,n);return true;};
        const uintptr_t base=0x140000000,manager=0x20000,head=0x30000,one=0x40000,two=0x41000,three=0x42000;
        add(base+combat::managerGlobal,8);add(manager,512);add(head,48);
        put(base+combat::managerGlobal,manager);put(manager,base+combat::managerVtable);put(manager+0x108,uintptr_t(0x70000));
        put(manager+0xe0,head);put(manager+0xe8,uint64_t(3));put(head+8,one);
        auto object=[&](uintptr_t at,uintptr_t vt,int server,float hp){
            add(at,0x300);add(at+0x1000,32);add(at+0x1100,32);
            put(at,vt);put(at+0x2c,server);put(at+0x4c,float(65));put(at+0x54,float(64));
            put(at+0x228,at+0x1000);put(at+0x1008,at+0x1100);put(at+0x1108,hp);
        };
        object(0x50000,base+combat::npcVtable,101,1);object(0x60000,base+combat::npcVtable,102,1);object(0x70000,base+0x100,103,1);
        auto node=[&](uintptr_t at,int key,uintptr_t obj,uintptr_t left,uintptr_t right){add(at,48);put(at,left);put(at+8,head);put(at+16,right);put(at+32,key);put(at+40,obj);put(obj+0x28,key);};
        node(one,10,0x50000,two,three);node(two,5,0x60000,head,head);node(three,20,0x70000,head,head);
        auto hostile=[](uintptr_t,uintptr_t obj){return obj==0x50000?1:0;};combat::Scan out;
        must(combat::scan(read,hostile,base,-1,-1,64,64,45,out)&&out.target.client==10&&out.enemies==1&&out.selfHp==100,"Nearest hostile NPC not selected");
        put(0x51108,float(0));must(combat::scan(read,hostile,base,10,101,64,64,45,out)&&out.status==2,"Observed death not returned");
        must(combat::scan(read,hostile,base,10,999,64,64,45,out)&&out.status==3,"Reused client id counted as death");
        put(0x51108,float(1));must(combat::scan(read,hostile,base,-1,-1,500,500,3,out)&&out.target.client==-1,"Out-of-range NPC selected");
        put(manager+0xe8,uint64_t(513));must(!combat::scan(read,hostile,base,-1,-1,64,64,45,out),"Unbounded scene accepted");
        put(manager+0xe8,uint64_t(3));put(one,one);must(!combat::scan(read,hostile,base,-1,-1,64,64,45,out),"Cyclic tree accepted");put(one,two);
        put(0x51108,std::numeric_limits<float>::quiet_NaN());must(!combat::scan(read,hostile,base,-1,-1,64,64,45,out),"Invalid health accepted as empty room");
    });
    test("combat_config_and_ipc_bounds",[&]{
        auto c=combatTestConfig();QString error;must(validateLegacyConfig(c,error),"Valid combat config rejected");
        for(const auto &pair:QList<QPair<QString,int>>{{"combat_radius",61},{"combat_interval_ms",749},{"combat_min_hp",0},{"combat_scene",4096},{"combat_kill_goal",0}}){auto bad=c;bad.insert(pair.first,pair.second);must(!validateLegacyConfig(bad,error),"Invalid combat limit accepted");}
        auto bad=c;bad.insert("combat_skills",QString(48,'x'));must(!validateLegacyConfig(bad,error),"Oversized skill name accepted");
        bad=c;bad.insert("legacy_id","tlzz_rose");must(!validateLegacyConfig(bad,error),"Combat enabled on undeclared task");
        gameplay::SnippetArgs a;a.ints[0]=3;a.ints[1]=10;a.ints[2]=101;a.ints[3]=-1;a.reals[0]=64;a.reals[1]=64;a.reals[2]=45;
        must(gameplay::validSnippet(gameplay::CombatCast,a),"Valid cast rejected");a.ints[1]=-1;must(!gameplay::validSnippet(gameplay::CombatCast,a),"Invalid target cast accepted");
        must(!gameplay::snippetIssuesAction(gameplay::CombatScan)&&!gameplay::snippetIssuesAction(gameplay::CombatSkill)&&gameplay::snippetIssuesAction(gameplay::CombatCast),"Combat read/write classification wrong");
        auto bcfg=c;bcfg.insert("engine","游戏内 Lua");
        bcfg.insert("battle_system",QJsonObject{{"enabled",true},{"heal_enabled",true},{"heal_percent",60},{"heal_skills","自身治疗"},{"pet",true},{"pet_feed_percent",50},{"pet_stop_percent",20}});
        must(validateLegacyConfig(bcfg,error),"Valid battle maintenance config rejected");
        for(const auto key:{"heal_percent","mp_percent","pet_feed_percent","pet_stop_percent","pet_sacrifice_min_percent"}){auto bad=bcfg;auto b=bad.value("battle_system").toObject();b.insert(key,96);bad.insert("battle_system",b);must(!validateLegacyConfig(bad,error),"Unbounded battle threshold accepted");}
        auto ext=bcfg;ext.insert("engine","外部兼容");must(!validateLegacyConfig(ext,error),"Resident battle maintenance accepted by external engine");
        auto badList=bcfg;auto policy=badList.value("battle_system").toObject();policy.insert("heal_skills",QString(48,'x'));badList.insert("battle_system",policy);must(!validateLegacyConfig(badList,error),"Oversized healing name accepted");
        auto emei=bcfg;auto emeiPolicy=emei.value("battle_system").toObject();emeiPolicy.insert("emei_enabled",true);emeiPolicy.insert("emei_attack",false);emei.insert("battle_system",emeiPolicy);
        must(validateLegacyConfig(emei,error),"Valid Emei policy rejected");
        for(const auto &key:QStringList{"emei_enabled","emei_attack","emei_team_heal"}){auto p=emeiPolicy;p.insert(key,"true");auto c=emei;c.insert("battle_system",p);must(!validateLegacyConfig(c,error),"Untyped Emei switch accepted");}
        for(const auto &key:QStringList{"emei_heal_percent","emei_self_priority_percent"}){auto p=emeiPolicy;p.insert(key,96);auto c=emei;c.insert("battle_system",p);must(!validateLegacyConfig(c,error),"Unbounded Emei threshold accepted");}
        auto inconsistent=emeiPolicy;inconsistent.insert("emei_heal_percent",30);inconsistent.insert("emei_self_priority_percent",40);emei.insert("battle_system",inconsistent);
        must(!validateLegacyConfig(emei,error),"Inconsistent Emei thresholds accepted");
        const auto source=c;
        QJsonObject sourceProfile{{"tasks",QJsonObject{{"dungeon_combat",source}}},{"queue",QJsonArray{QJsonObject{{"task","dungeon_combat"},{"params",source}}}}};
        auto mine=c;mine.insert("combat_skills","目标角色技能");
        QJsonObject b{{"identity","target"},{"battle",QJsonObject{{"skills","目标默认技能"}}},{"tasks",QJsonObject{{"dungeon_combat",mine}}}};
        const auto copied=copyTaskConfiguration(sourceProfile,b);
        must(copied.value("identity").toString()=="target"&&copied.value("tasks").toObject().value("dungeon_combat").toObject().value("combat_skills").toString()=="目标角色技能"
            &&copied.value("queue").toArray()[0].toObject().value("params").toObject().value("combat_skills").toString()=="目标角色技能"
            &&copied.value("queue").toArray()[0].toObject().value("params").toObject().value("battle_system")==b.value("battle"),"Copy replaced target skill bindings or identity");
    });
    struct Sim{int scene=3,casts=0,kills=0,boss=0,stops=0,patrols=0,deadReads=0;double x=64,y=64;bool quest=false,low=false,empty=false,lost=false,changed=false,uncertain=false,missingSkill=false;QStringList skills,options;};
    auto run=[&](QJsonObject config,Sim &s,qint64 limit,QString &error){
        const auto file=temporary+"/combat-test.lua";QFile f(file);must(f.open(QIODevice::WriteOnly),"Combat fixture source missing");
        f.write(config.value("legacy_id").toString()=="zhenlong_combat"?"RunZhenlongDungeon()":"RunDungeonCombat()");f.close();
        LegacyRunner lua;must(lua.load(file,error,root+"/scripts/legacy/compat.lua",config),qPrintable(error));
        for(qint64 now=0;now<=limit;now+=100){
            LegacyRequest r;const auto p=lua.poll(now,r,error);lua.takeMessages();
            if(p==LegacyRunner::Failed)return -1;
            if(p==LegacyRunner::Finished)return 1;
            if(p!=LegacyRunner::Action)continue;
            QVariantList values;
            if(r.kind==LegacyRequest::Host){
                if(r.host=="position")values={true,s.scene,s.x,s.y,QString("苏州")};
                if(r.host=="stop_motion")++s.stops;
                if(r.host=="combat_result"){if(r.detail=="kill")++s.kills;if(r.detail=="boss")++s.boss;}
            }else{
                must(r.kind==LegacyRequest::Snippet,"Unexpected game command");const auto &a=r.args;const auto text=QString::fromWCharArray(a.text);
                switch(r.snippet){
                case gameplay::CombatSkill:values={s.missingSkill?-1:text=="冷却技能"?2:3,300,0};break;
                case gameplay::CombatName:values={1,0,config.value("legacy_id").toString()=="zhenlong_combat"?QString("远古棋魂"):QString("副本怪物")};break;
                case gameplay::CombatScan:{
                    const bool dead=s.casts>=3&&!s.lost;int status=dead&&a.ints[1]>=0?2:s.lost&&s.casts>0&&a.ints[1]>=0?3:1;
                    if(status==2)++s.deadReads;
                    values={status,s.empty?-1:10,s.empty?-1:101,dead?0.0:1.0-s.casts*0.2,65,64,s.empty?0:1,s.low?10:100};break;}
                case gameplay::CombatCast:
                    if(a.ints[3]==2){s.skills<<"cooldown";values={0};break;}
                    ++s.casts;s.skills<<text;
                    if(s.uncertain){must(lua.acknowledge(r.id,false,"delivery uncertain"),"Failure ack rejected");continue;}
                    if(s.changed)s.scene=1;
                    values={1};break;
                case gameplay::TeamCount:values={3};break;
                case gameplay::PlayerData:values={a.ints[0]==4?(s.low?10:100):100};break;
                case gameplay::RunTo:s.scene=a.ints[0];s.x=a.reals[0];s.y=a.reals[1];++s.patrols;values={1};break;
                case gameplay::TalkNpc:case gameplay::NpcTarget:s.quest=true;values={1};break;
                case gameplay::QuestOptions:values={s.quest?1:0,1};break;
                case gameplay::QuestOption:s.options<<text;if(text=="珍珑棋局")s.scene=config.value("combat_scene").toInt();if(text=="确定")s.scene=1;values={1,text};break;
                default:must(false,"Unknown combat fixture request");
                }
            }
            must(lua.acknowledge(r.id,true,{},values),"Combat ack rejected");
        }
        return 0;
    };
    test("combat_skill_priority_cooldown_and_confirmed_death",[&]{
        QString error;auto c=combatTestConfig();c.insert("combat_skills","冷却技能，溪山行旅");Sim s;
        must(run(c,s,30000,error)==1,qPrintable(error));must(s.casts==3&&s.kills==1&&s.deadReads==2&&s.stops>=1,"Combat finished without two death samples");
        must(s.skills==QStringList{"cooldown","溪山行旅","cooldown","溪山行旅","cooldown","溪山行旅"},"Skill priority, UTF-8 names or cooldown skip changed");
        c.insert("combat_skills","冷却技能");Sim basic;must(run(c,basic,30000,error)==1&&basic.casts==3&&basic.kills==1,"Basic attack fallback failed");
    });
    test("combat_low_health_lost_target_scene_change_and_uncertain_delivery",[&]{
        QString error;auto c=combatTestConfig();Sim low;low.low=true;must(run(c,low,30000,error)==-1&&low.casts==0,"Low-health character attacked");
        Sim lost;lost.lost=true;must(run(c,lost,20000,error)==0&&lost.kills==0,"Missing target counted as a kill");
        Sim changed;changed.changed=true;must(run(c,changed,30000,error)==-1&&changed.casts==1,"Combat continued across scene transition");
        Sim uncertain;uncertain.uncertain=true;must(run(c,uncertain,30000,error)==-1&&uncertain.casts==1,"Uncertain cast replayed");
        Sim missing;missing.missingSkill=true;c.insert("combat_skills","不存在技能");must(run(c,missing,30000,error)==-1&&missing.casts==0,"Missing skill preflight failed");
    });
    test("zhenlong_entry_combat_boss_confirmation_exit_and_empty_timeout",[&]{
        QString error;auto c=combatTestConfig("zhenlong_combat");Sim s;s.scene=1;s.x=100;s.y=100;
        must(run(c,s,60000,error)==1,qPrintable(error));must(s.kills==1&&s.boss==1&&s.deadReads==2&&s.scene==1&&s.options.contains("珍珑棋局")&&s.options.contains("确定"),"Dungeon lifecycle incomplete");
        Sim empty;empty.scene=61;empty.empty=true;must(run(c,empty,120000,error)==-1&&empty.boss==0&&empty.kills==0&&empty.patrols>=6,"Empty dungeon reported success or did not patrol");
        c.insert("entry_mode","已在副本");Sim outside;outside.scene=1;must(run(c,outside,10000,error)==-1&&outside.patrols==0,"Manual-entry mode moved outside dungeon");
    });
}
}
