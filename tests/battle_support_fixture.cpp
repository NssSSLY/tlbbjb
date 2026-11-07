#include "game_text_session.hpp"
#include <filesystem>
#include <fstream>
#include <functional>
#include <iostream>
#include <sstream>
using namespace tlbb;
using namespace tlbb::resident;
using namespace tlbb::game_lua;
static std::string read(const std::filesystem::path &p){std::ifstream f(p,std::ios::binary);if(!f)throw std::runtime_error("Fixture source missing");return {std::istreambuf_iterator<char>(f),{}};}
static const char *game=R"LUA(
W={hp=100,maxhp=100,mp=100,maxmp=100,rage=20,eng=45,school=4,petHP=90,petMax=100,petH=123,petL=456,petOn=1,happy=90,calls=0,feed=0,cd={},enabled=1,effect=true,selected=903,button=99}
Player={GetData=function(self,k) local keys={HP='hp',MAXHP='maxhp',MP='mp',MAXMP='maxmp',RAGE='rage',ENG='eng',MEMPAI='school'} return W[keys[k]] end}
local function a(i,n,p)
 return {GetID=function() return i end,GetDefineID=function() if W.sameDefine then return 110 end return i+100 end,GetName=function() return n end,
 IsEnable=function() if W.disabledServer and W.selected==W.disabledServer then return 0 end return W.enabled end}
end
function EnumAction(i,kind)
 if kind~='skill' then error('wrong skill kind') end
 if i==0 then return a(10,'test-attack',-1) end
 if i==1 then return a(W.skillID or 11,W.emeiSkills and '清心普善咒' or 'test-heal',-1) end
 if i==2 then return a(12,'test-buff',-1) end
 if i==3 then return a(13,'八阵图',-1) end
 if W.highSkill and i==255 then return a(14,'last-slot',-1) end
 if W.duplicateSkill and i==4 then return a(10,'test-attack',-1) end
 return a(0,'',-1)
end
function GetActionNum(kind) return W.skillCount or 4 end
Pet={}
function Pet:IsPresent(i) if i==0 and not W.noPet then return 1 end return 0 end
function Pet:GetGUID(i) return W.petH,W.petL end
function Pet:GetHP(i) return W.petHP end
function Pet:GetMaxHP(i) return W.petMax end
function Pet:GetHappy(i) return W.happy end
function Pet:GetIsFighting(i) return W.petOn end
function Pet:GetName(i) return 'fixture-pet' end
function Pet:GetPetRelaxAction() return a(31,'pet-rest',0) end
function Pet:SetSelectPetIdx(i) W.petSelected=i end
function Pet:GetPetFightAction() assert(W.petSelected==0) return a(32,'pet-deploy',0) end
function Pet:EnumPetSkill(p,i,kind)
 if kind~='petskill' or p~=0 then error('wrong pet skill arguments') end
 if i==0 then return a(21,'test-pet-hp',p) end
 if i==1 then return a(22,'test-pet-mp',p) end
 if i==2 then return a(23,'test-pet-attack',p) end
 return a(0,'',p)
end
function Pet:Feed(i) W.feed=W.feed+1 if W.effect then W.petHP=90 end end
DataPool={IsCanDoAction=function() return W.canAction or 1 end,SelectAsTargetByObjID=function(self,id) W.selected=id end}
function Player:GetName() return 'fixture-self' end
function DataPool:GetTeamMemberCount() return W.teamCount or 0 end
function DataPool:GetTeamMemberInfo(i) local m=W.members[i+1] return m.name,'school',m.hp,m.maxhp,100,100,80,61 end
function DataPool:GetTeamMemberObjIDNamePortInfo(i)
 W.memberReads=(W.memberReads or 0)+1 local m=W.members[i+1]
 return m.server+(W.reuseMember and W.memberReads>=2 and 1 or 0),m.name,'portrait'
end
function DataPool:GetTeamMemGUIDByUIIndex(i) return W.members[i+1].guid end
function DataPool:IsTeamMemberInScene(i) return W.members[i+1].inside end
function DataPool:GetTeamMemInfoByIndex(i)
 if i==0 then return 'fixture-leader',4,80,0,0 end
 if i==1 then return 'fixture-member',7,65,1,W.memberOffline or 0 end
 error('unexpected member index')
end
Target={IsPresent=function() return true end,GetData=function(self,k)
 if k=='NPCID' then if W.wrongTarget then return 99 end if W.selected==903 then return 42 end
 for i,m in ipairs(W.members or {}) do if W.selected==m.server then return m.client end end return 10 end end}
function Target:GetServerId2ClientId(server) for i,m in ipairs(W.members or {}) do if m.server==server then return m.client end end return -1 end
function Lua_CheckActionItemCoolDown(id) return W.cd[id] or 0 end
Packet_Env={Packet_Space_Line10_Row10_button={
 GetActionItem=function() return W.button end,SetActionItem=function(self,v) W.button=v end,
 DoAction=function()
 W.calls=W.calls+1
 if W.uncertain then error('uncertain fixture action') end
 if not W.effect then return end
 W.cd[W.button]=1
 if W.button==31 then W.petOn=0 W.recalls=(W.recalls or 0)+1 end
 if W.button==32 then W.petOn=1 W.deploys=(W.deploys or 0)+1 end
 if W.cooldownOnly then return end
 if W.button==11 then
   if W.selected==903 then W.hp=90 else for i,m in ipairs(W.members or {}) do if W.selected==m.server then m.hp=90 end end end
 end
 if W.button==21 then W.hp=90 end
 if W.button==22 then W.mp=90 W.petHP=50 end
 end}}
)LUA";
struct BattleHost:Host{
    GameTextSession &text;std::string snapshot,logs;
    explicit BattleHost(GameTextSession &t):text(t){}
    Values evaluate(const std::string &s,const std::string &f,int n)override{return text.evaluate(s,f,n);}
    Values snippet(uint32_t id,const gameplay::SnippetArgs &a)override{
        if(id==gameplay::BagSpace)return {Value(5)};
        if(id==gameplay::Dismount)return text.evaluate("W.mountRequests=(W.mountRequests or 0)+1 return W.mountSubmit or 0","n",1);
        if(id==gameplay::CombatName)return {Value(1),Value(0),Value(std::string("fixture-enemy"))};
        if(id==gameplay::CombatScan)return text.evaluate("return 1,(W.scanCandidate and 10 or "+std::to_string(a.ints[1])+"),(W.scanMismatch and -1 or W.scanCandidate and 101 or "+std::to_string(a.ints[2])+"),100,65,64,(W.scanCandidate and 1 or 0),100","nnnnnnnn",8);
        if(id==gameplay::CombatCast){
            if(a.ints[0]==61&&a.ints[1]==10&&a.ints[2]==101&&a.ints[3]==-1&&a.text[0]==0)
                return text.evaluate("assert(W.allowBasic) W.calls=W.calls+1 return W.basicResult or 1","n",1);
            if(a.ints[0]!=61||a.ints[1]!=10||a.ints[2]!=101||a.ints[3]!=0||std::wcscmp(a.text,L"test-attack"))throw std::runtime_error("Wrong skill/target identity passed to native adapter");
            return text.evaluate("W.calls=W.calls+1 if W.uncertain then error('uncertain fixture action') end return W.submitResult or 1","n",1);
        }
        throw std::runtime_error("Unexpected battle snippet");
    }
    Values call(const std::string &op,const std::string &detail)override{
        if(op=="stop_motion"){text.evaluate("W.stops=(W.stops or 0)+1","",0);return {};}
        if(op=="battle_self_identity")return {Value(42),Value(903)};
        if(op=="position")return {Value(true),Value(61),Value(64),Value(64),Value(std::string("fixture-map"))};
        if(op=="mechanism_snapshot")return text.evaluate("return 61,W.mechanismCount or 0,W.mechanismText or ''","nns",3);
        if(op=="loot_snapshot")return text.evaluate("return 61,(W.lootTaken or not W.lootPresent) and 0 or 1,(W.lootTaken or not W.lootPresent) and '' or W.lootText","nns",3);
        if(op=="open_loot")return text.evaluate("assert('"+detail+"'=='50:500') W.lootOpens=(W.lootOpens or 0)+1 if not W.noLootOpen then W.lootVisible=true end return 1","n",1);
        if(op=="battle_snapshot"){snapshot=detail;return {};}
        if(op=="object_buff_ids")return text.evaluate("return W.buffCount or 0,W.buffIds or ''","ns",2);
        throw std::runtime_error("Unexpected battle host operation");
    }
    void log(const std::string &s)override{logs+=s+'\n';}
    std::vector<Object> objects()override{
        auto v=text.evaluate("return (W.targetClient or 10),(W.targetServer or 101),W.enemy~=false","nnb",3);
        return {{int(v[0].number),int(v[1].number),65,64,100,v[2].number!=0,"fixture-target"}};
    }
};
int wmain(int argc,wchar_t **argv){
    if(argc!=4)return 2;
    try{
        HMODULE dll=LoadLibraryExW(argv[1],nullptr,LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR|LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);if(!dll)return 3;
        auto create=api<void*(*)(bool,bool)>(dll,"?Create@LuaState@LuaPlus@@SAPEAV12@_N0@Z");
        auto native=api<void*(*)(void*)>(dll,"?GetCState@LuaState@LuaPlus@@QEAAPEAUlua_State@@XZ");
        auto destroy=api<void(*)(void*)>(dll,"?Destroy@LuaState@LuaPlus@@SAXPEAV12@@Z");
        auto ctor=api<void(*)(void*,void*,int)>(dll,"??0LuaObject@LuaPlus@@QEAA@PEAVLuaState@1@H@Z");
        auto dtor=api<void(*)(void*)>(dll,"??1LuaObject@LuaPlus@@QEAA@XZ");
        auto setTop=api<void(*)(void*,int)>(dll,"lua_settop");
        auto owner=create(false,false);auto vm=native(owner);
        for(const auto name:{"luaopen_base","luaopen_table","luaopen_string","luaopen_math"}){api<int(*)(void*)>(dll,name)(vm);setTop(vm,0);}
        api<void(*)(void*)>(dll,"lua_newtable")(vm);alignas(16) unsigned char registration[80]{};ctor(registration,owner,1);setTop(vm,0);
        const auto module=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/battle_support.lua");
        const auto resident=read(std::filesystem::path(argv[2])/"scripts/legacy/resident.lua");
        const auto skillHost=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/original_skill_host.lua");
        const auto genericHost=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/original_generic_host.lua");
        const auto dungeonApi=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/dungeon_api.lua");
        const auto dungeonFlow=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/dungeon_flow.lua");
        const auto sanhuan=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/sanhuan.lua");
        const auto originalConfig=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/original_config.lua");
        const auto emeiSupport=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/emei_support.lua");
        const auto combatSource=read(std::filesystem::path(argv[2])/"scripts/legacy/combat.lua");
        const auto petGuard=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/dungeon_pet_guard.lua");
        const auto yanziApi=read(std::filesystem::path(argv[2])/"scripts/legacy/modules/yanzi_api.lua");
        auto luaString=[](const std::string &s){std::string eq="====";while(s.find("]"+eq+"]")!=std::string::npos)eq+='=';return "["+eq+"["+s+"]"+eq+"]";};
        int checks=0,failures=0;std::string results;
        auto test=[&](const std::string &name,const std::string &config,const std::string &seed,const std::string &logic,const std::string &fail="",int casts=-1,int feeds=-1){
            ++checks;bool ok=false;std::string reason;
            try{
                GameTextSession text(dll,registration);text.evaluate(game,"",0);if(!seed.empty())text.evaluate(seed,"",0);
                BattleHost host(text);Vm run(host);std::string error;
                const auto pre="TaskConfig={combat_min_hp=25,battle_system="+config+"}\nCombatRuntime={codes={CombatScan=30,CombatCast=31},call=__game,host=__host,log=__log}\n"
                    "Player={} Bag={} function Player_GetPos() return 64,64 end function GetSceneID() return 61 end function GetHPPercent() return GetLuaValue('return W.hp*100/W.maxhp','n') end\n"
                    "__resident_modules={battle_support="+luaString(module)+",original_skill_host="+luaString(skillHost)+",original_generic_host="+luaString(genericHost)+
                    ",dungeon_api="+luaString(dungeonApi)+",dungeon_flow="+luaString(dungeonFlow)+",sanhuan="+luaString(sanhuan)+",original_config="+luaString(originalConfig)+",emei_support="+luaString(emeiSupport)+",dungeon_pet_guard="+luaString(petGuard)+",yanzi_api="+luaString(yanziApi)+"}\n";
                if(!run.start(pre+module+'\n'+resident+'\n'+logic,error))throw std::runtime_error(error);
                for(uint64_t now=0;now<=16000&&(run.state()==Vm::Running||run.state()==Vm::Sleeping);now+=20)run.step(now);
                if(fail.empty())ok=run.state()==Vm::Completed;else ok=run.state()==Vm::Failed&&run.error().find(fail)!=std::string::npos;
                reason=run.error();if(!ok&&reason.empty())reason="unexpected terminal state";
                const auto n=text.evaluate("return W.calls,W.feed,W.button","nnn",3);
                ok=ok&&(casts<0||n[0].number==casts)&&(feeds<0||n[1].number==feeds)&&n[2].number==99;
                if(name=="inspect_has_live_skills_and_pet")ok=ok&&host.snapshot.find("test-attack")!=std::string::npos&&host.snapshot.find("fixture-pet")!=std::string::npos;
            }catch(const std::exception &e){reason=e.what();}
            if(!ok){++failures;std::cerr<<name<<": "<<reason<<'\n';}
            if(!results.empty())results+=',';results+="{\"name\":\""+name+"\",\"passed\":"+(ok?"true":"false")+'}';
        };
        const std::string start="local s=BattleSupport.new(false) ";
        const std::string guard="LoadScript('dungeon_pet_guard');local s=BattleSupport.new(false);CombatRuntime.setPetSuspended=function(v,p) if s.pending then return false end if s.pet then assert(s.pet.index==p.index and s.pet.high==p.high and s.pet.low==p.low) end s.petSuspended=v return true end;local g=DungeonPetGuard.new();";
        const std::string rest="assert(not DungeonPetGuard.update(g,true));Sleep(600);assert(DungeonPetGuard.update(g,true));BattleSupport.tick(s);assert(g.phase=='recalled');";
        test("pet_guard_actual_lua50_rest_deploy_receipts","{pet=true}","",guard+rest+
            "assert(not DungeonPetGuard.update(g,false));Sleep(600);assert(DungeonPetGuard.update(g,false));assert(g.phase=='idle' and not s.petSuspended);assert(GetLuaValue('return W.recalls','n')==1 and GetLuaValue('return W.deploys','n')==1)","",2,0);
        test("pet_guard_no_pet_or_initially_resting_is_not_deployed","{}","W.petOn=0",guard+
            "assert(DungeonPetGuard.update(g,true));assert(DungeonPetGuard.update(g,false));assert(g.phase=='idle')","",0,0);
        test("pet_guard_empty_roster_is_not_deployed","{}","W.noPet=true",guard+"assert(DungeonPetGuard.update(g,true));assert(DungeonPetGuard.update(g,false))","",0,0);
        test("pet_guard_no_receipt_never_repeats","{}","W.effect=false",guard+
            "while true do DungeonPetGuard.update(g,true);Sleep(200) end","珍兽指令后状态未确认",1,0);
        test("pet_guard_unready_can_retry_without_command","{}","W.enabled=0",guard+
            "assert(not DungeonPetGuard.update(g,true));assert(GetLuaValue('return W.calls','n')==0);GetLuaValue('W.enabled=1','',0);"+rest,"",1,0);
        test("pet_guard_identity_changed_does_not_restore","{pet=true}","",guard+rest+
            "GetLuaValue('W.petL=999','',0);DungeonPetGuard.update(g,false)","珍兽身份变化",1,0);
        test("pet_guard_manual_deploy_does_not_override","{pet=true}","",guard+rest+
            "GetLuaValue('W.petOn=1','',0);DungeonPetGuard.update(g,true)","被手动出战",1,0);
        test("pet_guard_character_heal_continues_while_pet_rests","{pet=true,heal_enabled=true,heal_skills='test-heal'}","",guard+rest+
            "GetLuaValue('W.hp=20','',0);Sleep(600);assert(BattleSupport.tick(s));assert(GetLuaValue('return W.hp','n')==90)","",2,0);
        test("pet_guard_pending_pet_action_waits","{pet=true}","",guard+
            "s.pending={kind='喂养'};assert(not DungeonPetGuard.update(g,true));assert(GetLuaValue('return W.calls','n')==0);s.pending=nil;"+rest,"",1,0);
        test("pet_guard_release_before_recall_receipt_waits_for_deploy","{pet=true}","",guard+
            "assert(not DungeonPetGuard.update(g,true));Sleep(600);assert(not DungeonPetGuard.update(g,false));assert(g.phase=='recalled');assert(not DungeonPetGuard.update(g,false));Sleep(600);assert(DungeonPetGuard.update(g,false))","",2,0);
        test("pet_guard_manual_recall_before_command_not_redeployed","{}","W.enabled=0",guard+
            "assert(not DungeonPetGuard.update(g,true));GetLuaValue('W.petOn=0','',0);DungeonPetGuard.update(g,false)","被手动收回",0,0);
        test("pet_guard_invalid_guid_not_serialized","{}","W.petL=0/0","LoadScript('dungeon_pet_guard');local g=DungeonPetGuard.new();DungeonPetGuard.update(g,true)","pet GUID unavailable",0,0);
        test("pet_guard_deploy_no_receipt_not_replayed","{}","",guard+rest+
            "GetLuaValue('W.effect=false','',0);while true do DungeonPetGuard.update(g,false);Sleep(200) end","珍兽指令后状态未确认",2,0);
        const std::string emei="{emei_enabled=true,emei_attack=false,emei_heal_skills='test-heal'}";
        const std::string member="W.teamCount=1 W.members={{name='fixture-mate',guid='g1',server=904,client=43,hp=20,maxhp=100,inside=1}} ";
        test("generic_output_policy_unchanged","{}","",start+"assert(BattleSupport.outputEnabled(s))","",0,0);
        test("emei_no_output_when_enabled",emei,"",start+"assert(not BattleSupport.outputEnabled(s));assert(not BattleSupport.tick(s));assert(GetLuaValue('return W.selected','n')==903)","",0,0);
        test("emei_self_emergency_before_lower_hp_teammate",emei,member+"W.hp=30 W.members[1].hp=10",start+
            "assert(BattleSupport.tick(s));assert(s.pending.target.index==-1);assert(GetLuaValue('return W.members[1].hp','n')==10)","",1,0);
        test("emei_self_protection_respects_global_stop_threshold","{emei_enabled=true,emei_attack=false,emei_self_priority_percent=10,emei_heal_skills='test-heal'}",member+"W.hp=20 W.members[1].hp=5",start+
            "assert(BattleSupport.tick(s));assert(s.pending.target.index==-1)","",1,0);
        test("emei_team_low_hp_before_nonurgent_self",emei,member+"W.hp=70",start+
            "assert(BattleSupport.tick(s));assert(s.pending.target.guid=='g1');assert(GetLuaValue('return W.members[1].hp','n')==90);Sleep(600);BattleSupport.tick(s);assert(s.pending==nil)","",1,0);
        test("emei_other_school_uses_generic_policy",emei,member+"W.school=3",start+
            "assert(s.emei==nil and BattleSupport.outputEnabled(s));assert(not BattleSupport.tick(s));assert(GetLuaValue('return W.memberReads or 0','n')==0)","",0,0);
        test("emei_dead_offscene_and_unloaded_not_healed",emei,
            "W.teamCount=3 W.members={{name='dead',guid='g1',server=904,client=43,hp=0,maxhp=100,inside=1},{name='far',guid='g2',server=905,client=44,hp=10,maxhp=100,inside=0},{name='loading',guid='g3',server=906,client=-1,hp=10,maxhp=100,inside=1}}",
            start+"assert(not BattleSupport.tick(s))","",0,0);
        test("emei_reused_target_never_cast",emei,member+"W.reuseMember=true",start+"BattleSupport.tick(s)","healing target identity changed",0,0);
        test("emei_left_team_during_pending",emei,member,start+
            "assert(BattleSupport.tick(s));GetLuaValue('W.teamCount=0','',0);Sleep(600);BattleSupport.tick(s)","治疗目标离队",1,0);
        test("emei_cast_receipt_survives_concurrent_damage",emei,member+"W.cooldownOnly=true",start+
            "assert(BattleSupport.tick(s));Sleep(600);BattleSupport.tick(s);assert(s.pending==nil)","",1,0);
        test("emei_auto_selects_only_learned_heal","{emei_enabled=true,emei_attack=false}","W.emeiSkills=true W.hp=30",start+
            "assert(#s.emei.heals==1 and s.emei.heals[1]=='清心普善咒');assert(BattleSupport.tick(s))","",1,0);
        test("emei_manual_unlearned_skill_rejected","{emei_enabled=true,emei_heal_skills='missing'}","",start,"未学会",0,0);
        test("emei_policy_replaces_legacy_self_only_switch","{emei_enabled=true,emei_attack=true,emei_heal_skills='test-heal',heal_only=true,heal_enabled=true}","",start+
            "assert(BattleSupport.outputEnabled(s))","",0,0);
        test("emei_chooses_lowest_living_teammate",emei,
            member+"W.teamCount=2 W.members[2]={name='urgent',guid='g2',server=905,client=44,hp=10,maxhp=100,inside=1}",start+
            "assert(BattleSupport.tick(s));assert(s.pending.target.guid=='g2')","",1,0);
        test("emei_team_healing_can_be_disabled","{emei_enabled=true,emei_attack=false,emei_team_heal=false,emei_heal_skills='test-heal'}",member,start+
            "assert(not BattleSupport.tick(s));assert(GetLuaValue('return W.memberReads or 0','n')==0)","",0,0);
        test("emei_big_hp_values_keep_integer_precision",emei,member+"W.members[1].hp=20000000 W.members[1].maxhp=100000000",start+
            "assert(s.emei.members[1].hp==20000000 and s.emei.members[1].maxhp==100000000)","",0,0);
        test("emei_only_heal_blocks_pet_attack","{emei_enabled=true,emei_attack=false,emei_heal_skills='test-heal',pet=true,pet_skills='test-pet-attack'}","",start+
            "assert(not BattleSupport.tick(s,{id=10,server=101,scene=61,x=64,y=64,radius=45}))","",0,0);
        const auto combatPrelude="TaskConfig.battle_system.enabled=true;local S={CombatScan="+std::to_string(gameplay::CombatScan)+",CombatCast="+std::to_string(gameplay::CombatCast)+",CombatName="+std::to_string(gameplay::CombatName)+",CombatSkill="+std::to_string(gameplay::CombatSkill)+"};local game,host,log=__game,__host,__log;function trim(s) return s end\n"+combatSource+"\n";
        test("pet_guard_production_runtime_waits_feed_and_restores_maintenance","{pet=true,pet_feed=true}","W.petHP=30",combatPrelude+
            "CombatRuntime.prepare();assert(CombatRuntime.maintain());LoadScript('dungeon_pet_guard');local g=DungeonPetGuard.new();assert(not DungeonPetGuard.update(g,true));assert(GetLuaValue('return W.calls','n')==0);Sleep(600);CombatRuntime.maintain();assert(not DungeonPetGuard.update(g,true));Sleep(600);assert(DungeonPetGuard.update(g,true));CombatRuntime.maintain();assert(GetLuaValue('return W.petOn','n')==0);assert(not DungeonPetGuard.update(g,false));Sleep(600);assert(DungeonPetGuard.update(g,false));CombatRuntime.maintain();assert(GetLuaValue('return W.petOn','n')==1)","",2,1);
        test("combat_submission_receipt_ignores_unavailable_basic_and_throttle","{}","W.scanCandidate=true W.allowBasic=true W.basicResult=0",combatPrelude+
            "local s=CombatRuntime.new(61);CombatRuntime.step(s);assert(s.submitted==0);Sleep(1600);GetLuaValue('W.basicResult=1','',0);CombatRuntime.step(s);assert(s.submitted==1);CombatRuntime.step(s);assert(s.submitted==1)","",2,0);
        test("emei_dungeon_only_heal_still_scans_and_patrols",emei,"W.scanCandidate=true",combatPrelude+
            "TaskConfig.combat_skills='unlearned-output';local s=CombatRuntime.new(61);assert(CombatRuntime.step(s)=='supporting');GetLuaValue('W.scanCandidate=false','',0);assert(CombatRuntime.step(s)=='empty')","",0,0);
        test("emei_idle_allows_basic_only_when_enabled","{emei_enabled=true,emei_attack=true,emei_heal_skills='test-heal'}","W.scanCandidate=true W.allowBasic=true",combatPrelude+
            "local s=CombatRuntime.new(61);assert(CombatRuntime.step(s)=='fighting')","",1,0);
        test("emei_original_skill_host_respects_no_attack_and_catalog_reload",emei,"",combatPrelude+
            "TaskConfig.combat=true;assert(skilllib.CUseSkillByID(110,10)==0);skilllib.CEnumSkill();BattleSupport.skillList();Sleep(600);assert(skilllib.CUseSkillByID(110,10)==0)","",0,0);
        test("emei_confirmed_heal_no_extra_delay",emei,member,start+
            "assert(BattleSupport.tick(s));Sleep(600);GetLuaValue('W.hp=30 W.cd[11]=0','',0);BattleSupport.tick(s);assert(s.pending and s.pending.target.index==-1)","",2,0);
        test("emei_does_not_interrupt_active_cast",emei,member,start+
            "assert(BattleSupport.tick(s));GetLuaValue('W.canAction=0 W.hp=30','',0);Sleep(600);assert(BattleSupport.tick(s));assert(s.pending.target.index==0);GetLuaValue('W.canAction=1 W.cd[11]=0','',0);Sleep(600);BattleSupport.tick(s);assert(s.pending.target.index==-1)","",2,0);
        test("emei_support_mode_keeps_self_buff","{emei_enabled=true,emei_attack=false,emei_heal_skills='test-heal',buff_enabled=true,buff_skills='test-buff'}","",start+
            "assert(BattleSupport.tick(s));assert(s.pending.kind=='自身增益')","",1,0);
        test("emei_unavailable_target_does_not_block_other_member",emei,
            member+"W.disabledServer=904 W.teamCount=2 W.members[2]={name='second',guid='g2',server=905,client=44,hp=30,maxhp=100,inside=1}",start+
            "assert(BattleSupport.tick(s));assert(s.pending.target.guid=='g2');assert(s.emei.unavailable.g1)","",1,0);
        test("original_control_values_preserved","{}","",
            "LoadScript('original_config');local c=OriginalConfig.combo({sel=2,text='选项三',data=88});assert(c.sel==2 and c.text=='选项三' and c.data==88);local mapped=OriginalConfig.combo('选项乙',{options={{text='选项甲',data=7},{text='选项乙',data=false}}});assert(mapped.sel==1 and mapped.text=='选项乙' and mapped.data==false);local l=OriginalConfig.list({{text='技能',data=42,sel=1}});assert(l[1].data==42 and l[1].sel==1);local unknown=OriginalConfig.combo(2);assert(unknown.sel==2);assert(not pcall(function() return unknown.text end));assert(not pcall(OriginalConfig.combo,1.5))","",0,0);
        const std::string genericInit="__original_entry={original_token='fixture'};LoadScript('original_generic_host');";
        test("generic_structured_control_readers_agree","{}","",genericInit+
            "TaskConfig.control={sel=2,text='option',data=88};assert(ReadConfigInt('', 'control')==2 and ReadConfigText('', 'control')=='option');local c=GetConfigCommbox('', 'control');assert(c.sel==2 and c.text=='option' and c.data==88)","",0,0);
        test("generic_missing_mission_outline_is_not_false","{}","",genericInit+
            "GetLuaValue('return meIsMissionOutline(\"x\",0,119)','b')","meIsMissionOutline",0,0);
        test("generic_existing_mission_native_is_forwarded","{}","function meIsMissionOutline() return true end",genericInit+
            "assert(GetLuaValue('return meIsMissionOutline(\"x\",0,119)','b'))","",0,0);
        test("generic_scene_elapsed_uses_observed_transitions","{}","",genericInit+
            "assert(GetLuaValue('return meGetSceneTransTimeDiff()','n')==0);Sleep(1000);assert(GetLuaValue('return meGetSceneTransTimeDiff()','n')>=1);GetSceneID=function() return 62 end;assert(GetLuaValue('return meGetSceneTransTimeDiff()','n')==0)","",0,0);
        test("generic_live_mission_slots_are_validated","{}","function DataPool:GetPlayerMission_InUse(i) return 0 end",genericInit+
            "GetLuaValue('meRefreshMission()','',0)","",0,0);
        // 0 means wait, as in the reference: nothing is clicked. Only -1 walks out through the panel.
        test("generic_dead_player_is_not_silently_revived","{}","W.hp=0",genericInit+
            "GetLuaValue('meReliveHandle(0)','',0)","",0,0);
        const std::string dungeonSeed=R"LUA(
W.mission=false W.status=0 W.accepts=0 W.deliveries=0 W.dialog='test' W.mode='menu'
function DataPool:GetPlayerMission_InUse(i) if W.badSlot then return -1 end if W.mission and (i==0 or W.duplicate and i==1) then return 1 end return 0 end
function DataPool:GetPlayerMission_Memo(i) return 'test','{100,120,653,target}' end
function DataPool:GetPlayerMission_Name(i) return 'Mission:88' end
function DataPool:GetPlayerMission_Variable(i,n) return W.status end
function DataPool:GetNPCEventList_Num() return 1 end
function DataPool:GetNPCEventList_Item(i) return 'id',0,1,0,W.dialog end
function Player:IsLeader() return W.leader end
function DClick(text) if text~='test' then return 0 end if W.status==1 then W.mode='continue' else W.mode='accept' end return 1 end
local function button(kind)
 return {IsVisible=function() return W.mode==kind end,GetProperty=function() return W.disabled and 'True' or 'False' end,GetText=function() return W.mode end}
end
Quest_Env={this={IsVisible=function() return true end},Quest_Button_Accept=button('accept'),Quest_Button_Continue=button('continue'),
 QuestAccept_Clicked=function() W.accepts=W.accepts+1 W.mission=true W.status=0 end,
 MissionContinue_Clicked=function() W.deliveries=W.deliveries+1 if not W.noDelivery then W.mission=false end end}
)LUA";
        const std::string dungeonLogic="LoadScript('dungeon_api') local a=DungeonApi.new() local d={mission='test',map='map',accept={'test'},turnin={'test'}} "
            "function QuestFrameOptionClicked(t) return GetLuaValue('return DClick('..string.format('%q',t)..')','n')==1 end ";
        test("dungeon_buff_names_expand_each_pair_in_lua50","{}",dungeonSeed+
            "W.buffCount=10 W.buffIds='1,2,3,4,5,6,7,8,9,10' function Lua_GetBuffInfo(id) return 'icon'..id,'buff'..id end",dungeonLogic+
            "local b=a.buffs();for i=1,10 do assert(b['buff'..i]) end assert(not b.icon1)","",0,0);
        test("dungeon_buff_missing_definition_is_not_empty_lua50","{}",dungeonSeed+
            "W.buffCount=1 W.buffIds='99' function Lua_GetBuffInfo(id) return '','' end",dungeonLogic+"a.buffs()","Buff 定义名称不可读",0,0);
        test("dungeon_buff_count_mismatch_is_error","{}",dungeonSeed+"W.buffCount=1",dungeonLogic+"a.buffs()","Buff 数量不一致",0,0);
        test("dungeon_stop_attack_selects_and_verifies_self_lua50","{}",dungeonSeed+"W.selected=101",dungeonLogic+
            "a.stopAttack();assert(GetLuaValue('return W.selected','n')==903)","",0,0);
        test("dungeon_stop_attack_requires_selected_identity_lua50","{}",dungeonSeed+"W.wrongTarget=true",dungeonLogic+"a.stopAttack()","自身目标未确认",0,0);
        test("dungeon_team_identities_read_real_game_methods_lua50","{}",dungeonSeed+
            "W.teamCount=2 W.members={{name='self',guid='g0',server=903,client=42,inside=1},{name='mate',guid='g1',server=904,client=43,inside=true}}",dungeonLogic+
            "local t=a.teamIdentities();assert(#t==2 and t[1].id==42 and t[2].server_id==904);GetLuaValue('W.members[2].inside=0','',0);assert(not pcall(a.teamIdentities))","",0,0);
        test("dungeon_team_bad_server_not_passed_to_native_lua50","{}",dungeonSeed+
            "W.teamCount=1 W.members={{name='mate',guid='g1',server=0.5,client=43,inside=1}} function Target:GetServerId2ClientId() error('invalid native invocation') end",dungeonLogic+
            "a.teamIdentities()","team server identity unavailable",0,0);
        const std::string yanziSeed=R"LUA(
W.campaignUsed=0 W.campaignLimit=2 W.campaignKind=1 W.itemCount=2 W.itemDefine=77 W.temporary=1 W.tempOpen=false
PlayerQuicklyEnter_Env={PlayerQuicklyEnter_ActivityShedule=function() W.campaignRefresh=(W.campaignRefresh or 0)+1 end}
function GetNewCampaignCount(page) assert(page==2) return W.campaignN or 2 end
function EnumNewCampaign(page,index,key)
 assert(page==2)
 if key=='name' then if index==1 or W.duplicateCampaign then return '讨伐燕子坞' end return 'other' end
 assert(index==1 or W.duplicateCampaign)
 if key=='MyCampaingCount' then return W.campaignUsed end
 if key=='PlayNum' then return W.campaignLimit end
 if key=='IsToday' then return W.campaignKind end
 error('wrong campaign key')
end
function DataPool:GetBaseBag_Num() return 4 end
local function item()
 return {GetID=function() return W.itemCount>0 and 88 or 0 end,GetName=function() return '悲酥清风解药' end,
 GetDefineID=function() return W.itemDefine end,GetNum=function() return W.itemCount end}
end
PlayerPackage={EnumItem=function(self,kind,i) assert(kind=='base') if i==0 then return item() end end,
 UseItem=function(self,i) assert(i==0) W.itemUses=(W.itemUses or 0)+1 W.itemCount=W.itemCount-1 end}
W.lootPresent=true W.lootText=string.format('3%c50%c500%c65%c64%c',9,9,9,9,10) W.lootVisible=true
LootPacket_Env={this={IsVisible=function() return W.lootVisible end}}
function CloseWindow(name,v) assert(name=='LootPacket' and v==true) W.lootVisible=false end
function PlayerPackage:PickAllItem() assert(W.lootVisible and W.lootOpens==1) W.pickRequests=(W.pickRequests or 0)+1 W.lootTaken=true end
Packet_Temporary_Env={this={IsVisible=function() return W.tempOpen end},Packet_Temporary_ActionsList_auto_element0={GetLuaActionButton=function(self,k)
 assert(k=='Packet_Temporary') return {DoAction=function() W.itemCount=W.itemCount+W.temporary W.temporary=0 end} end}}
Packet_Env.Packet_Temporary_BtnClick=function() W.tempOpen=true end
Bank={GetTemBankItemNum=function() return W.temporary end,EnumTemItem=function(self,i) if i==0 and W.temporary>0 then return {
 GetID=function() return 89 end,GetName=function() return '悲酥清风解药' end},false end end}
)LUA";
        const std::string yanziLogic="CombatRuntime.codes.BagSpace="+std::to_string(gameplay::BagSpace)+";LoadScript('yanzi_api');local a=YanziApi.new();";
        test("yanzi_campaign_current_api_and_exact_name_lua50","{}",yanziSeed,yanziLogic+
            "local c=a.campaign(true);assert(c.used==0 and c.limit==2);assert(GetLuaValue('return W.campaignRefresh','n')==1);GetLuaValue('W.campaignUsed=1','',0);assert(a.campaign(false).used==1)","",0,0);
        test("yanzi_campaign_bad_limit_unknown_and_duplicate_lua50","{}",yanziSeed,yanziLogic+
            "GetLuaValue('W.campaignLimit=-1','',0);assert(not pcall(a.campaign));GetLuaValue('W.campaignLimit=2 W.duplicateCampaign=true','',0);assert(not pcall(a.campaign));GetLuaValue('W.duplicateCampaign=false W.campaignKind=2','',0);assert(not pcall(a.campaign))","",0,0);
        test("yanzi_named_item_identity_and_single_use_lua50","{}",yanziSeed,yanziLogic+
            "local t=a.item('悲酥清风解药');assert(t.slot==0 and t.id==77 and t.total==2);a.useItem(t);assert(a.item(t.name).total==1);assert(not pcall(a.useItem,t));assert(GetLuaValue('return W.itemUses','n')==1)","",0,0);
        test("yanzi_item_slot_reused_is_not_used_lua50","{}",yanziSeed,yanziLogic+
            "local t=a.item('悲酥清风解药');GetLuaValue('W.itemDefine=78','',0);assert(not pcall(a.useItem,t));assert(GetLuaValue('return W.itemUses or 0','n')==0)","",0,0);
        test("yanzi_pickup_submission_not_completion_lua50","{}",yanziSeed,yanziLogic+
            "assert(a.pickup()==1);assert(GetLuaValue('return W.pickRequests','n')==1);assert(a.item('悲酥清风解药').total==2);assert(not GetLuaValue('return W.lootVisible','b'));assert(a.pickup()==0)","",0,0);
        test("yanzi_loot_no_open_feedback_never_takes_or_replays_lua50","{}",yanziSeed+"W.noLootOpen=true",yanziLogic+
            "assert(not pcall(a.pickup));assert(GetLuaValue('return W.lootOpens','n')==1);assert(GetLuaValue('return W.pickRequests or 0','n')==0)","",0,0);
        test("yanzi_loot_rejects_non_package_and_count_mismatch_lua50","{}",yanziSeed+"W.lootText=string.gsub(W.lootText,'^3','1')",yanziLogic+
            "assert(not pcall(a.pickup));assert(GetLuaValue('return W.lootOpens or 0','n')==0)","",0,0);
        test("yanzi_temporary_bag_uses_current_bank_api_lua50","{}",yanziSeed,yanziLogic+
            "a.takeAntidote();assert(a.item('悲酥清风解药').total==3);assert(GetLuaValue('return W.temporary','n')==0)","",0,0);
        test("yanzi_team_coordinates_require_same_pair_and_proximity_lua50","{}",yanziSeed+
            "W.teamCount=2 W.members={{name='self',guid='g0',server=903,client=42,inside=1},{name='mate',guid='g1',server=904,client=43,inside=1}} W.mechanismCount=1 W.mechanismText=string.format('1%c43%c904%c64%c64%c',9,9,9,9,10)",yanziLogic+
            "assert(a.teamNear({scene=61,x=64,y=64},20));GetLuaValue(\"W.mechanismText=string.gsub(W.mechanismText,'904','999')\",'',0);assert(not a.teamNear({scene=61,x=64,y=64},20))","",0,0);
        test("dungeon_team_scene_boolean_and_unknown_lua50","{}",dungeonSeed+
            "W.teamCount=2 W.members={{inside=1},{inside=false}}",dungeonLogic+
            "assert(not a.teamTogether());GetLuaValue('W.members[2].inside=true','',0);assert(a.teamTogether());GetLuaValue('W.members[2].inside=nil','',0);assert(not pcall(a.teamTogether))","",0,0);
        test("dungeon_exact_option_no_implicit_fallback_lua50","{}",dungeonSeed,dungeonLogic+
            "assert(not a.selectOption({'other'},true));assert(a.selectOption({'test'},false)=='test');assert(GetLuaValue('return W.mode','s')=='accept')","",0,0);
        test("dungeon_localized_mission_and_shared_dialog_lua50","{}",dungeonSeed+"W.mode='accept'",dungeonLogic+
            "function GetDictionaryString() return 'test' end d.mission='#{SJZ_100129_03}';assert(a.acceptShared(d));assert(a.mission(d).id==88)","",0,0);
        test("dungeon_shared_acceptance_closed_dialog_is_idle_lua50","{}",dungeonSeed+
            "Quest_Env.this.IsVisible=function() return false end",dungeonLogic+
            "assert(not a.acceptShared(d));assert(GetLuaValue('return W.accepts','n')==0)","",0,0);
        test("dungeon_shared_acceptance_matches_task_and_never_replays_lua50","{}",dungeonSeed+
            "W.mode='accept' Quest_Env.QuestAccept_Clicked=function() W.accepts=W.accepts+1 end",dungeonLogic+
            "GetLuaValue(\"W.dialog='other'\",'',0);assert(not a.acceptShared(d));GetLuaValue(\"W.dialog='test'\",'',0);assert(a.acceptShared(d));assert(not a.acceptShared(d));assert(GetLuaValue('return W.accepts','n')==1)","",0,0);
        test("dungeon_accept_continue_entry_pages_lua50","{}",dungeonSeed+
            "W.world=4 Quest_Env.QuestAccept_Clicked=function() W.accepts=W.accepts+1 W.mission=true W.mode='continue' end Quest_Env.MissionContinue_Clicked=function() W.deliveries=W.deliveries+1 W.world=66 W.mode='closed' end",dungeonLogic+
            "a.world=function() return {scene=GetLuaValue('return W.world','n')} end;d.inside=function(p) return p.scene==66 end;a.enterMission(d);assert(GetLuaValue('return W.accepts','n')==1 and GetLuaValue('return W.deliveries','n')==1)","",0,0);
        test("dungeon_mission_absence_and_record_lua50","{}",dungeonSeed,dungeonLogic+
            "assert(a.mission(d)==nil);GetLuaValue('W.mission=true','',0);local m=a.mission(d);assert(m.slot==0 and m.id==88 and m.status==0 and m.desc=='{100,120,653,target}')","",0,0);
        test("dungeon_bad_slot_is_not_absence_lua50","{}",dungeonSeed+"W.badSlot=true",dungeonLogic+"a.mission(d)","mission slot state unavailable",0,0);
        test("dungeon_duplicate_mission_rejected_lua50","{}",dungeonSeed+"W.mission=true W.duplicate=true",dungeonLogic+"a.mission(d)","duplicate dungeon mission",0,0);
        test("dungeon_boolean_leader_lua50","{}",dungeonSeed+"W.leader=true",dungeonLogic+"assert(a.isLeader());GetLuaValue('W.leader=false','',0);assert(not a.isLeader())","",0,0);
        test("dungeon_raw_dictionary_limit_is_terminal_lua50","{}",dungeonSeed+"W.dialog='#{LIMIT}'",dungeonLogic+
            "function GetDictionaryString() return 'localized limit' end d.limit={'#{LIMIT}'};assert(a.limit(d));assert(GetLuaValue('return W.accepts','n')==0)","",0,0);
        test("dungeon_accept_actual_visible_handler_lua50","{}",dungeonSeed,dungeonLogic+
            "a.accept(d);assert(a.mission(d).status==0);assert(GetLuaValue('return W.accepts','n')==1)","",0,0);
        test("dungeon_disabled_accept_not_submitted_lua50","{}",dungeonSeed+"W.disabled=true",dungeonLogic+
            "assert(not pcall(a.accept,d));assert(GetLuaValue('return W.accepts','n')==0)","",0,0);
        test("dungeon_turnin_and_no_replay_lua50","{}",dungeonSeed+"W.mission=true W.status=1 W.noDelivery=true",dungeonLogic+
            "assert(not pcall(a.turnIn,d));assert(GetLuaValue('return W.deliveries','n')==1);GetLuaValue('W.noDelivery=false','',0);a.turnIn(d);assert(a.mission(d)==nil)","",0,0);
        const std::string mountLogic=dungeonLogic+"CombatRuntime.codes.Dismount="+std::to_string(gameplay::Dismount)+"; ";
        test("dungeon_dismount_waits_for_actual_state_lua50","{}",dungeonSeed+
            "W.mountSubmit=1 W.mountReads=0 function GetMountID() W.mountReads=W.mountReads+1 if W.mountReads>=2 then return -1 end return 123 end",
            mountLogic+"a.prepareBattle();assert(GetLuaValue('return W.mountRequests','n')==1);assert(GetLuaValue('return W.mountReads','n')==2)","",0,0);
        test("dungeon_dismount_no_effect_is_not_replayed_lua50","{}",dungeonSeed+
            "W.mountSubmit=1 function GetMountID() return 123 end",mountLogic+
            "assert(not pcall(a.prepareBattle));assert(GetLuaValue('return W.mountRequests','n')==1)","",0,0);
        test("dungeon_dismount_missing_interface_rejected_lua50","{}",dungeonSeed+"W.mountSubmit=-1",mountLogic+
            "assert(not pcall(a.prepareBattle));assert(GetLuaValue('return W.mountRequests','n')==1)","",0,0);
        const std::string progressSeed=R"LUA(
W.progressPage=1 W.openProgress=0
local function panel(page) return {IsVisible=function() return W.progressPage==page end} end
local function label(s) return {GetProperty=function() return s end} end
Sancai_Env={this={IsVisible=function() return W.openProgress==1 end},Sancai_BK1=panel(1),Sancai_BK2=panel(2),Sancai_BK3=panel(3),
 Sancai_Image1Info2=label('30/30'),Sancai_Image1Info3=label('1/1'),Sancai_Image1Info4=label('3/6'),Sancai_Image1Info5=label('0/1'),Sancai_Image1Info6=label('0/1'),
 Sancai_Image2Info2=label('30/30'),Sancai_Image2Info3=label('0/1'),Sancai_Image3Info2=label('0/1')}
function PushEvent(event,arg) assert(event=='3HUAN_OPEN_UI_RESULT' and arg==1) W.openProgress=1 end
)LUA";
        test("sancai_progress_actual_lua50_widgets_and_event","{}",progressSeed,
            "LoadScript('sanhuan');local a={now=function() return 0 end};local c={lastStageRead=0};local d=Sanhuan.definitions.old;assert(d.progress(a,{},c).key==3);GetLuaValue('W.progressPage=2','',0);assert(d.progress(a,{},c).key==7);GetLuaValue('W.progressPage=3','',0);assert(d.progress(a,{},c).key==8)","",0,0);
        const std::string pending="assert(BattleSupport.tick(s)) Sleep(600) BattleSupport.tick(s) assert(s.pending==nil)";
        test("team_basic_members","{}","W.memberOffline=1","function GetTeamCount() return 2 end local t=Team:GetBasicMembers() assert(#t==2 and t[1].name=='fixture-leader' and t[1].menpai==4 and t[1].level==80 and t[1].index==0 and not t[1].dead and t[2].dead and t[2].offline)","",0,0);
        test("team_empty","{}","","function GetTeamCount() return 0 end assert(#Team:GetBasicMembers()==0)","",0,0);
        test("inspect_has_live_skills_and_pet","{}","","BattleSupport.inspect()","",0,0);
        for(int school=0;school<16;++school)test("school_"+std::to_string(school)+"_learned_actions","{}","W.school="+std::to_string(school),"local s=BattleSupport.new(true) assert(s.school=="+std::to_string(school)+" and #s.skills==4)","",0,0);
        test("taohua_uses_eng_not_rage","{}","W.school=13","local s=BattleSupport.new(true) assert(s.rage==45)","",0,0);
        test("unknown_school_keeps_id","{}","W.school=99","local s=BattleSupport.new(true) assert(s.school==99)","",0,0);
        test("oversized_skill_list_rejected","{}","W.skillCount=257",start,"技能动作数量",0,0);
        test("full_256_slot_count_supported","{}","W.skillCount=256 W.highSkill=true","local s=BattleSupport.new(true) assert(#s.skills==5 and s.skills[5].index==255)","",0,0);
        test("missing_count_uses_bounded_sparse_slots","{}","GetActionNum=nil W.highSkill=true","local s=BattleSupport.new(true) assert(#s.skills==5 and s.skills[5].index==255)","",0,0);
        test("count_query_failure_uses_bounded_slots","{}","function GetActionNum() error('unsupported kind') end","local s=BattleSupport.new(true) assert(#s.skills==4)","",0,0);
        test("duplicate_actions_not_listed_twice","{}","W.duplicateSkill=true","local s=BattleSupport.new(true) assert(#s.skills==4)","",0,0);
        test("boolean_skill_and_pet_flags_supported","{}","W.enabled=true W.petOn=true","local s=BattleSupport.new(true) assert(s.skills[1].enabled and s.pet.on==1)","",0,0);
        test("negative_cooldown_rejected","{}","W.cd[10]=-1",start,"技能冷却",0,0);
        test("role_heal_before_pet_feed","{heal_enabled=true,heal_skills='test-heal',pet=true,pet_feed=true}","W.hp=10 W.petHP=30",start+pending,"",1,0);
        test("self_heal_confirmed","{heal_enabled=true,heal_skills='test-heal'}","W.hp=30",start+pending,"",1,0);
        test("heal_no_effect_no_replay","{heal_enabled=true,heal_skills='test-heal'}","W.hp=30 W.effect=false",start+"while true do BattleSupport.tick(s) Sleep(200) end","未确认技能",1,0);
        test("heal_cooldown_alone_not_success","{heal_enabled=true,heal_skills='test-heal'}","W.hp=30 W.cooldownOnly=true",start+"while true do BattleSupport.tick(s) Sleep(200) end","未确认技能",1,0);
        test("disabled_skill_never_cast","{heal_enabled=true,heal_skills='test-heal'}","W.hp=10 W.enabled=0",start+"BattleSupport.tick(s)","无可用恢复",0,0);
        test("cooldown_skill_never_cast","{heal_enabled=true,heal_skills='test-heal'}","W.hp=10 W.cd[11]=1",start+"BattleSupport.tick(s)","无可用恢复",0,0);
        test("pet_feed_confirmed","{pet=true,pet_feed=true}","W.petHP=30",start+pending,"",0,1);
        test("pet_feed_no_effect_no_replay","{pet=true,pet_feed=true}","W.petHP=30 W.effect=false",start+"while true do BattleSupport.tick(s) Sleep(200) end","未确认技能",0,1);
        test("dead_pet_never_fed","{pet=true,pet_feed=true}","W.petHP=0",start+"BattleSupport.tick(s)","珍兽死亡",0,0);
        test("low_pet_stop","{pet=true}","W.petHP=10",start+"BattleSupport.tick(s)","珍兽生命低于",0,0);
        test("pet_identity_change","{pet=true}","",start+"GetLuaValue('W.petH=999','',0) Sleep(600) BattleSupport.tick(s)","身份已变化",0,0);
        test("pet_mp_confirmed","{pet=true,pet_mp_skills='test-pet-mp'}","W.mp=10",start+pending,"",1,0);
        test("pet_sacrifice_low_hp_blocked","{pet=true,pet_mp_skills='test-pet-mp'}","W.mp=10 W.petHP=50",start+"assert(not BattleSupport.tick(s))","",0,0);
        test("unlearned_heal_rejected","{heal_enabled=true,heal_skills='missing'}","",start,"未找到本角色",0,0);
        test("ground_skill_rejected","{heal_enabled=true,heal_skills='八阵图'}","",start,"特殊技能待适配",0,0);
        test("changed_skill_identity_rejected","{heal_enabled=true,heal_skills='test-heal'}","W.hp=30",start+"GetLuaValue('W.skillID=111','',0) BattleSupport.tick(s)","动作已变化",0,0);
        test("wrong_self_target_rejected","{heal_enabled=true,heal_skills='test-heal'}","W.hp=30 W.wrongTarget=true",start+"BattleSupport.tick(s)","目标变化",0,0);
        test("uncertain_cast_not_replayed","{heal_enabled=true,heal_skills='test-heal'}","W.hp=30 W.uncertain=true",start+"BattleSupport.tick(s)","uncertain fixture",1,0);
        test("heal_output_overlap_rejected","{heal_enabled=true,heal_skills='test-heal'}","",start+"BattleSupport.outputAllowed(s,'test-heal')","不能同时配置",0,0);
        test("invalid_hp_not_guessed","{}","W.maxhp=0",start,"战斗读数无效",0,0);
        test("pet_hostile_action_confirmed","{pet=true,pet_skills='test-pet-attack'}","",start+"assert(BattleSupport.tick(s,{id=10,server=101,scene=61,x=64,y=64,radius=45})) Sleep(600) BattleSupport.tick(s) assert(s.pending==nil)","",1,0);
        test("buff_throttle","{buff_enabled=true,buff_skills='test-buff',buff_interval_seconds=60}","",start+"local t={id=10,server=101,scene=61,x=64,y=64,radius=45} assert(BattleSupport.tick(s,t)) Sleep(600) BattleSupport.tick(s) Sleep(2000) assert(not BattleSupport.tick(s,t))","",1,0);
        const std::string petProbe="__original_entry={original_token='002bb430'};LoadScript('original_generic_host');";
        test("dungeon_pet_absent_numeric","{}","W.petOn=0",petProbe+"assert(Player:GetFightPetGUID()==-1)","",0,0);
        test("dungeon_pet_absent_boolean","{}","function Pet:IsPresent(i) return false end",petProbe+"assert(Player:GetFightPetGUID()==-1)","",0,0);
        // A pet that is out reads as its GUID (high*2^32+low) through the native-level reader; no special-case stop.
        test("dungeon_pet_present_returns_guid","{}","",petProbe+"assert(Player:GetFightPetGUID()==528280977864)","",0,0);
        test("dungeon_pet_presence_nil_is_error","{}","function Pet:IsPresent(i) return nil end",petProbe+"Player:GetFightPetGUID()","pet presence state unavailable",0,0);
        test("dungeon_pet_presence_bad_number_is_error","{}","function Pet:IsPresent(i) return 2 end",petProbe+"Player:GetFightPetGUID()","pet presence state unavailable",0,0);
        test("dungeon_pet_fighting_nil_is_error","{}","function Pet:GetIsFighting(i) return nil end",petProbe+"Player:GetFightPetGUID()","pet fighting state unavailable",0,0);
        const std::string api="TaskConfig.combat=true ";
        test("original_skill_catalog_does_not_fabricate_attributes","{}","",api+"local t=skilllib.CEnumSkill();assert(#t==4 and t[1].id==110 and t[1].action_id==10 and t[1].baseskl==nil and t[1].consume==nil and t[1].schema=='sdk_action_v1')","",0,0);
        test("original_cooldown_refreshes_live_action","{}","",api+"local t=skilllib.CEnumSkill();GetLuaValue('W.cd[10]=1','',0);assert(skilllib.CGetCD(t[1].cdidx)==1)","",0,0);
        test("original_skill_target_and_throttle","{}","",api+"assert(skilllib.CUseSkillByID(110,10)==1);assert(skilllib.CUseSkillByID(110,10)==0)","",1,0);
        test("original_skill_unknown_or_changed_id","{}","",api+"skilllib.CEnumSkill();GetLuaValue('W.skillID=111','',0);skilllib.CGetCD(1)","身份变化",0,0);
        test("original_skill_bad_target_never_submitted","{}","W.enemy=false",api+"skilllib.CUseSkillByID(110,10)","存活敌方",0,0);
        test("original_skill_reused_target_never_submitted","{}","W.scanMismatch=true",api+"skilllib.CUseSkillByID(110,10)","目标身份",0,0);
        test("original_skill_disabled_never_submitted","{}","W.enabled=false",api+"assert(skilllib.CUseSkillByID(110,10)==0)","",0,0);
        test("original_skill_low_hp_never_submitted","{}","W.hp=10",api+"skilllib.CUseSkillByID(110,10)","停止阈值",0,0);
        test("original_skill_uncertain_call_not_replayed","{}","W.uncertain=true",api+"assert(not pcall(skilllib.CUseSkillByID,110,10));skilllib.CUseSkillByID(110,10)","不重复提交",1,0);
        test("original_skill_reload_does_not_clear_uncertain_state","{}","W.uncertain=true",api+"assert(not pcall(skilllib.CUseSkillByID,110,10));CExec('original_skill_host');skilllib.CUseSkillByID(110,10)","不重复提交",1,0);
        test("original_skill_ambiguous_define_id_rejected","{}","W.sameDefine=true",api+"skilllib.CUseSkillByID(110,10)","不唯一",0,0);
        test("original_skill_ground_mode_not_aliased","{}","",api+"skilllib.CUseSkillByID(110,10,64,64)","地点",0,0);
        test("original_skill_alternate_protocol_not_aliased","{}","",api+"skilllib.CUseSkillByID2(110,10)","独立原生协议",0,0);
        test("original_skill_requires_combat_declaration","{}","","skilllib.CUseSkillByID(110,10)","未声明战斗",0,0);
        dtor(registration);destroy(owner);FreeLibrary(dll);
        std::ofstream report(std::filesystem::path(argv[3]),std::ios::binary);report<<"{\"passed\":"<<(failures?"false":"true")<<",\"checks\":["<<results<<"],\"failures\":"<<failures<<",\"real_game_tested\":false}";
        std::cout<<checks<<" battle SDK checks, "<<failures<<" failures\n";return failures?1:0;
    }catch(const std::exception &e){std::cerr<<e.what()<<'\n';return 4;}
}
