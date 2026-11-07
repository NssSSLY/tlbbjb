-- 本程序的战斗执行层。目标类型、归属、生命与场景由桥接重新核对；规则随完整包分发。
-- 副本无关的战斗 / 恢复公共层；入场、Boss 名单、路线和通关条件由各副本规则提供。
local CS, cg, ch, cl = S, game, host, log
local cfg = TaskConfig or {}
local function combat_args(scene, id, server, index)
    return {scene, id or -1, server or -1, index or 0}
end
local function setting(key, fallback) local v=cfg[key]; if v==nil then return fallback end return v end
local support
local function ensure_support()
    if not cfg.battle_system or cfg.battle_system.enabled==false then return nil end
    if not support then LoadScript("battle_support");support=BattleSupport.new(false) end
    return support
end
local function maintain(target)
    local s=ensure_support();return s and BattleSupport.tick(s,target) or false
end
local function can_attack() local s=ensure_support();return not s or BattleSupport.outputEnabled(s) end
local function pet_suspended(paused,identity)
    local s=ensure_support();if not s then return true end
    if s.pending and (s.pending.kind=='喂养' or s.pending.action and s.pending.action.pet>=0) then return false end
    if s.pet then
        assert(s.pet.index==identity.index and s.pet.high==identity.high and s.pet.low==identity.low,'机制珍兽与战斗维护身份不符')
    end
    s.petSuspended=paused==true;return true
end
local function combat_setup(scene,options)
    options=options or {}
    local bosses={}
    for _,name in ipairs(options.boss_names or {}) do bosses[name]=true end
    local state={scene=scene,id=-1,server=-1,name="",kills=0,dead=0,lastcast=-10000,lastbasic=-10000,submitted=0,
        progress=GetTickCount(),hp=nil,skills={},boss_names=bosses,radius=tonumber(setting("combat_radius",45)),minimum=tonumber(setting("combat_min_hp",25))}
    local helper=ensure_support()
    local names=tostring(setting("combat_skills","")):gsub("，",",")
    for name in (can_attack() and names or ""):gmatch("[^,\r\n]+") do
        name=trim(name)
        if name~="基础攻击" then
        local idx=helper and BattleSupport.outputAllowed(helper,name) or cg(CS.CombatSkill,nil,nil,name)
        if idx<0 then error("未找到已学技能："..name) end
        state.skills[#state.skills+1]={name=name,index=idx}
        end
    end
    state.x,state.y=Player_GetPos()
    if state.x<0 then error("战斗起点不可读") end
    return state
end
local function drop_target(s) s.id,s.server,s.name,s.dead,s.hp=-1,-1,"",0,nil;s.progress=GetTickCount() end
-- Original dungeon rules sometimes nominate a particular monster. Preserve that
-- choice: an unreadable or vanished nominated target must never fall back to a
-- different nearby enemy. Keep both client and server identity for revalidation.
local function original_target(s,id)
    if id~=nil then
        id=tonumber(id)
        assert(id and id==math.floor(id) and id>=-1 and id<=2147483647,"原副本目标 ID 无效")
    end
    if id and id>=0 and id~=s.id then
        local chosen
        for _,o in ipairs(EnumEnvObj()) do
            if o.id==id and o.class=="怪物" and o.hp>0 then
                assert(not chosen,"原副本目标身份不唯一")
                chosen=o
            end
        end
        assert(chosen and type(chosen.server_id)=="number" and chosen.server_id>=0,"原副本指定的敌方目标不可确认")
        if s.id>=0 then ch("stop_motion") end
        s.id,s.server,s.name,s.hp,s.dead=chosen.id,chosen.server_id,chosen.name,chosen.hp,0
        s.progress=GetTickCount()
    end
    local x,y=Player_GetPos()
    assert(type(x)=="number" and type(y)=="number" and x>=0 and y>=0,"副本战斗角色坐标不可读")
    s.x,s.y=x,y
end
local function combat_step(s)
    if GetSceneID()~=s.scene then error("战斗场景已变化，停止本任务") end
    if maintain() then return "recovering",0 end
    -- The character may move during a fight or be moved by the player. Scan
    -- from its current position rather than the point where combat started.
    local px,py=Player_GetPos()
    assert(type(px)=="number" and type(py)=="number" and px>=0 and py>=0,"战斗角色坐标不可读")
    s.x,s.y=px,py
    local status,id,server,hp,x,y,count,selfhp=cg(CS.CombatScan,combat_args(s.scene,s.id,s.server),{s.x,s.y,s.radius})
    if not status or status<1 or not selfhp then error("战场状态不可读") end
    -- Protection uses real HP/MAXHP. The native diagnostic ratio has an unverified scale.
    if GetHPPercent()<=s.minimum then error("角色血量低于停止阈值，等待人工处理") end
    if not can_attack() then return id<0 and "empty" or "supporting",count end
    if s.id>=0 and status==2 and id==s.id and server==s.server then
        s.dead=s.dead+1
        if s.dead>=2 then
            local boss=s.boss_names[s.name]==true
            s.kills=s.kills+1;ch("combat_result","kill");cl("确认目标死亡："..s.name)
            if boss then ch("combat_result","boss") end
            drop_target(s);ch("stop_motion");return boss and "boss" or "kill",count
        end
        return "confirming",count
    end
    if status==3 then
        cl("目标离开可见范围；未计入击杀："..s.name);drop_target(s);ch("stop_motion");return "lost",count
    end
    if id<0 then return "empty",count end
    if s.id<0 then
        s.id,s.server=id,server;s.hp=hp;s.progress=GetTickCount()
        -- The compatibility wire returns numeric positions first, then its string value.
        local _,_,name=cg(CS.CombatName,{id});s.name=name or ("目标 "..id);cl("战斗目标："..s.name)
    end
    s.dead=0
    if s.hp==nil or hp<s.hp then s.hp=hp;s.progress=GetTickCount() end
    if GetTickCount()-s.progress>tonumber(setting("combat_stall_seconds",60))*1000 then error("目标生命长期未下降，停止战斗："..s.name) end
    if GetTickCount()-s.lastcast<tonumber(setting("combat_interval_ms",1000)) then return "fighting",count end
    if maintain(s) then return "recovering",count end
    local args=combat_args(s.scene,s.id,s.server,-1)
    for _,skill in ipairs(s.skills) do
        args[4]=skill.index
        local r=cg(CS.CombatCast,args,{s.x,s.y,s.radius},skill.name)
        if r==1 then s.lastcast=GetTickCount();s.submitted=s.submitted+1;return "fighting",count end
        if r==-2 then error("技能列表已变化，请重新开始任务："..skill.name) end
        if r<0 then drop_target(s);ch("stop_motion");return "lost",count end
    end
    if GetTickCount()-s.lastbasic>=1500 then
        args[4]=-1
        local r=cg(CS.CombatCast,args,{s.x,s.y,s.radius})
        if r<0 then drop_target(s);ch("stop_motion");return "lost",count end
        if r==1 then s.submitted=s.submitted+1 end
        s.lastbasic=GetTickCount();s.lastcast=GetTickCount()
    end
    return "fighting",count
end
function RunDungeonCombat()
    local scene=tonumber(setting("combat_scene",-1))
    if GetSceneID()~=scene then error("请进入配置的副本场景后运行") end
    local s=combat_setup(scene);local goal=tonumber(setting("combat_kill_goal",1))
    while s.kills<goal do combat_step(s);Sleep(500) end
    ch("stop_motion");cl("已确认击杀 "..s.kills.." 个目标；本项战斗完成")
end
-- Adapter entry points: original rule chunks own their control flow; this layer
-- supplies the already-adapted skill selection, native validation and receipts.
CombatRuntime={new=combat_setup,step=combat_step,selectOriginalTarget=original_target,call=cg,codes=CS,host=ch,log=cl,maintain=maintain,canAttack=can_attack,prepare=ensure_support,setPetSuspended=pet_suspended}
