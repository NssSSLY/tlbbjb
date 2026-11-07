-- SDK-backed subset of the original native libraries. No reference DLL or old offsets.
-- id = learned skill DefineID; action_id is the game's current action handle.
-- cdidx is this adapter's action-slot index, not a claimed native cooldown-table offset.
local R=assert(CombatRuntime,"战斗宿主未加载")
local cfg=TaskConfig or {}
LoadScript("battle_support")
local B=assert(BattleSupport)
-- Explicit CExec reloads must not erase an uncertain submission or its throttle.
local state=__original_skill_state or {lastCast=-10000,uncertain=false}
__original_skill_state=state
local function skills()
    if not state.inventory then state.inventory=B.skillList() end
    return state.inventory
end
local function current(a)
    local live=B.readAction(a.index,-1)
    assert(live and live.id==a.id and live.define==a.define and live.name==a.name,"技能动作身份变化，请重新开始任务")
    assert(type(live.cooldown)=="number" and live.cooldown>=0,"技能冷却不可读")
    return live
end
function skilllib.CEnumSkill()
    local out={}
    for _,a in ipairs(skills()) do
        local live=current(a)
        out[#out+1]={id=a.define,action_id=a.id,cdidx=a.index,name=a.name,
            enabled=live.enabled,cooldown=live.cooldown,reason=B.restriction(a.name),schema="sdk_action_v1"}
    end
    return out -- attack/baseskl/consume/fdist are unknown, never fabricated.
end
function skilllib.CGetCD(index)
    assert(type(index)=="number" and index==math.floor(index),"冷却索引无效")
    for _,a in ipairs(skills()) do if a.index==index then return current(a).cooldown end end
    error("冷却索引不属于本次技能清单")
end
function skilllib.CUseSkillByID(id,target,x,y)
    assert(cfg.combat==true,"此任务未声明战斗能力")
    assert(not state.uncertain,"上次技能结果不确定，不重复提交")
    assert(type(id)=="number" and id>0 and id==math.floor(id),"技能定义 ID 无效")
    assert(type(target)=="number" and target>=0 and target==math.floor(target),"目标客户端 ID 无效")
    assert((x==nil or x==-1) and (y==nil or y==-1),"指定地点的技能释放尚未适配")
    local selected
    for _,a in ipairs(skills()) do if a.define==id then assert(not selected,"技能定义 ID 不唯一");selected=a end end
    assert(selected,"本角色没有此已学技能定义 ID")
    local reason=B.restriction(selected.name);assert(not reason,selected.name.."："..tostring(reason))
    local policy=cfg.battle_system or {}
    for _,key in ipairs({"heal_skills","buff_skills"}) do
        for n in tostring(policy[key] or ""):gsub("，",","):gmatch("[^,\r\n]+") do
            assert(n:match("^%s*(.-)%s*$")~=selected.name,"治疗 / 增益技能不能作为敌方输出")
        end
    end
    if R.maintain and R.maintain() then return 0 end
    if R.canAttack and not R.canAttack() then return 0 end
    local maintenance=R.prepare and R.prepare()
    if maintenance then B.outputAllowed(maintenance,selected.name) end
    assert(GetHPPercent()>tonumber(cfg.combat_min_hp or 25),"角色血量低于停止阈值")
    local live=current(selected)
    if not live.enabled or live.cooldown~=0 or GetTickCount()-state.lastCast<tonumber(cfg.combat_interval_ms or 1000) then return 0 end
    local identity
    for _,o in ipairs(EnumObjects()) do if o.id==target and o.hp>0 and o.hostile==1 then identity=o;break end end
    assert(identity,"目标不是当前可见的存活敌方 NPC")
    local scene=GetSceneID();local px,py=Player_GetPos();local radius=tonumber(cfg.combat_radius or 45)
    local status,client,server=R.call(R.codes.CombatScan,{scene,target,identity.server_id},{px,py,radius})
    assert(status==1 and client==target and server==identity.server_id,"施放前目标身份或距离已变化")
    state.uncertain=true -- an exception here must never reopen automatic submission.
    local submitted=R.call(R.codes.CombatCast,{scene,target,server,selected.index},{px,py,radius},selected.name)
    assert(submitted==0 or submitted==1,"技能提交失败，停止且不重新选择目标")
    state.uncertain=false;state.lastCast=GetTickCount()
    return submitted -- submission only; each dungeon owns damage/completion checks.
end
function skilllib.CUseSkillByID2() error("CUseSkillByID2 的独立原生协议尚未适配，不能替换为普通技能") end
function skilllib.CUseSkillByID_fb() error("CUseSkillByID_fb 的专用调用尚未适配，不能替换为普通技能") end
OriginalCallCapabilities={schema="sdk_action_v1",module_execution=true,game_lua_formats="nlsb",
    npc_filters=true,player_objects=false,pet_objects=false,loot_objects=false,
    learned_skill_actions=true,native_skill_attributes=false,ground_skills=false,
    alternate_skill_protocols=false}
