-- 原珍珑棋局专用宿主适配层（保留旧模块名以兼容已迁移入口）。副本循环保留在 original/*.lua 的原字节码中。
-- 本批接入棋局单轮；拾取、自动换线、自动复活与今日次数读取尚未接入。
local cfg=TaskConfig or {}
local R=assert(CombatRuntime,"战斗宿主未加载")
local nativeObjects=EnumObjects
local run=nil
Team=Team or {}
function Team:GetMemberCount() return GetTeamCount() end
LoadScript("original_filters")
local originalReady=Team.IsCountReady
function Team:IsCountReady(n) return originalReady(self,tonumber(cfg.original_team_count) or n) end

CDG={}
g_config={skill={shuaguai_gongji=cfg.combat_skills or ""}}
local function configValue(section,key)
    local binding=(cfg.original_bindings or {})[tostring(section).."/"..tostring(key)]
    if not binding then error("尚未映射的原规则参数："..tostring(section).."/"..tostring(key)) end
    return cfg[binding]
end
function ReadConfigBool(section,key) local v=configValue(section,key);return v==true or v==1 or v=="1" end
GetConfigBool=ReadConfigBool
function ReadConfigText(section,key) local v=configValue(section,key);return v==nil and "" or tostring(v) end
GetConfigText=ReadConfigText

local function healthy()
    while R.maintain and R.maintain() do Sleep(200) end
    if GetHPPercent()<=tonumber(cfg.combat_min_hp or 25) then error("角色血量低于停止阈值；原规则本轮已停止，不自动复活") end
end
local function key(o) return tostring(o.id)..":"..tostring(o.server_id) end
local function confirmBoss(o)
    if run.boss or not run.alive[key(o)] then return end
    for i=1,2 do
        local status,id,server,hp=R.call(R.codes.CombatScan,{run.scene,o.id,o.server_id},{64,64,tonumber(cfg.combat_radius or 45)})
        if status~=2 or id~=o.id or server~=o.server_id or hp>0 then error("原规则检测到棋魂消失，但本轮死亡读数未确认") end
        if i==1 then Sleep(100) end
    end
    R.host("combat_result","kill");R.host("combat_result","boss");run.boss=true
    DebugStr("原规则：远古棋魂连续两次死亡读数已确认")
end
function EnumEnvObj()
    assert(run,"原规则尚未初始化");healthy()
    local scene=GetSceneID();if scene~=run.scene then return {} end
    run.entered=true
    local result,nextAlive={},{}
    for _,o in ipairs(nativeObjects()) do
        local identity=key(o)
        if o.hp>0 and o.hostile==1 then run.alive[identity]=true end
        if run.alive[identity] then nextAlive[identity]=true end
        o.class=(o.hostile==1 or (o.hp==0 and run.alive[identity])) and "怪物" or "NPC"
        o.title=o.title or ""
        if o.name=="远古棋魂" and o.hp==0 then confirmBoss(o) end
        result[#result+1]=o
    end
    run.alive=nextAlive -- bounded by the current native snapshot (at most 512 objects)
    return result
end

-- One validated combat step for the target selected by the original rule.
function FubenAttack(id)
    assert(run,"原规则尚未初始化");healthy()
    if GetSceneID()~=run.scene then return false end
    run.entered=true
    if not run.combat then run.combat=R.new(run.scene,{boss_names={"远古棋魂"}}) end
    local s=run.combat
    R.selectOriginalTarget(s,id)
    local event=R.step(s)
    if event=="boss" then run.boss=true end
    return event
end

function MoveCallBack_state_1(x,y,callback) return type(callback)=="function" and callback(x,y,nil)==true end
MoveCallBack_state_2=MoveCallBack_state_1
function MoveCallback_NoFuben() healthy();return false end
function MoveTo(x,y,scene,range,unused,callback,custom)
    x,y=assert(tonumber(x)),assert(tonumber(y));scene=tonumber(scene)
    if not scene or scene<0 then scene=GetSceneID() end
    range=math.max(0.5,tonumber(range) or 2)
    local sent,lastProgress,lx,ly=0,GetTickCount(),nil,nil
    while true do
        healthy()
        if type(callback)=="function" and callback(x,y,custom)==true then return false end
        local current,px,py=GetSceneID(),Player_GetPos()
        if current==scene and (px-x)^2+(py-y)^2<=range^2 then return true end
        if sent==0 or GetTickCount()-lastProgress>8000 then
            if sent>=4 then error("原规则寻路没有进展，已停止") end
            R.call(R.codes.RunTo,{scene},{x,y});sent=sent+1;lastProgress=GetTickCount()
        end
        Sleep(200)
        if lx and math.abs(px-lx)+math.abs(py-ly)>0.5 then lastProgress=GetTickCount() end
        lx,ly=px,py
    end
end
function RunTo(x,y,range,wait)
    healthy();R.call(R.codes.RunTo,{GetSceneID()},{tonumber(x),tonumber(y)})
    if wait then Sleep(math.min(60000,math.max(0,tonumber(wait) or 0))) end
end
function MoveToNPC(name,x,y,scene,unused1,unused2,callback,custom)
    if not MoveTo(x,y,scene,3,nil,callback,custom) then return false end
    scene=tonumber(scene);if not scene or scene<0 then scene=GetSceneID() end
    R.call(R.codes.TalkNpc,{scene},{tonumber(x),tonumber(y)},name)
    local start=GetTickCount()
    repeat
        if R.call(R.codes.QuestOptions)==1 then return true end
        if type(callback)=="function" and callback(x,y,custom)==true then return false end
        Sleep(200)
    until GetTickCount()-start>10000
    error("没有确认原规则 NPC 对话："..tostring(name))
end

local skippedPickup=false
function PickUpLua()
    if not skippedPickup then skippedPickup=true;DebugStr("原规则：拾取接口尚未接入，本轮不拾取") end
end
PickUpLua_Boss=PickUpLua
function ChangeSceneLine()
    if not run.lineNoted then run.lineNoted=true;DebugStr("原规则：本轮保持当前线路，不自动换线") end
end
-- DispelBuffByName is an already-adapted game API. A positive observation also
-- requests dismount; do not pretend an unimplemented mePlayerGetBuff exists.
function IsMount() return not Dismount() end
function DieOutAndGetPos()
    -- A position means "returned from death", not an ordinary position query.
    -- Alive characters produce no event; automatic revival is not implemented.
    healthy();return nil
end
function IsInDebugMsgTime(text,unused,seconds) return IsInDebugMsg(text) end
function LeaveSpecialScene()
    local scene=GetSceneID();local name=GetCurrentSceneName()
    if scene==run.scene or scene==1 or name:find("苏州休息室",1,true) then return true end
    error("原棋局自动入场请先到苏州；其他城市传送尚待接入")
end
function IsHuodongComplete(name)
    assert(name=="棋局","本批没有此活动的完成读取")
    if GetSceneID()==run.scene then run.entered=true;return false end
    if run.entered then
        if not run.boss then error("原规则已离开棋局，但没有确认棋魂死亡；停止且不再次入场") end
        return true
    end
    if GetTickCount()-run.started>30000 then error("原规则未在 30 秒内确认入场；不重新提交") end
    return false -- This is a single-run receipt, not a claimed daily quota reader.
end
local dialogOption=QuestFrameOptionClicked_Item
function QuestFrameOptionClicked_Item(option,mode,wait)
    local entry=option=="珍珑棋局" or option=="#{QJYH_150315_02}" or option=="#{QJYH_150315_03}"
    if entry and run.entries[option] then error("同一原规则入场选项已提交，不重复发送") end
    local ok=dialogOption(option,mode,wait)
    if ok and entry then run.entries[option]=true end
    return ok
end
function BeginOriginalDungeon(kind,scene)
    assert(kind=="qiju" and scene==61,"未知原副本规则")
    run={scene=scene,started=GetTickCount(),entered=GetSceneID()==scene,boss=false,alive={},entries={}}
    healthy()
    if cfg.entry_mode=="已在副本" and not run.entered then error("请先进入珍珑棋局，再运行原规则") end
    LeaveSpecialScene()
    Dismount()
end
function EndOriginalDungeon(kind,scene)
    if not run.boss or not run.entered or GetSceneID()==scene then error("原规则结束，但棋魂死亡和离场条件没有同时确认") end
    R.host("stop_motion");DebugStr("原棋局控制流程执行完成：棋魂死亡与离场已确认")
end
