-- 珍珑棋局专用兼容流程；共享战斗层不含本活动的 NPC、路线、Boss 名称。
local cfg=TaskConfig or {}
local R=assert(CombatRuntime)
local CS,cg,ch,cl=R.codes,R.call,R.host,R.log
local function setting(k,v) if cfg[k]==nil then return v end return cfg[k] end
local function combat_setup(scene) return R.new(scene,{boss_names={"远古棋魂"}}) end
local combat_step=R.step
function RunZhenlongDungeon()
    local scene=tonumber(setting("combat_scene",61))
    if GetSceneID()~=scene then
        if setting("entry_mode","自动入场")~="自动入场" then error("请先进入珍珑棋局") end
        if cg(CS.TeamCount)<3 then error("珍珑棋局需要已有队伍且至少三人；请先组队") end
        GoToSceneNPC("张弈国",267,242,1)
        if not QuestFrameOptionClicked("珍珑棋局",0) then error("没有找到珍珑棋局入场选项") end
        Sleep(800)
        if GetSceneID()~=scene then QuestFrameOptionClicked("#{QJYH_150315_02}",1) end
        local start=GetTickCount()
        while GetSceneID()~=scene do if GetTickCount()-start>30000 then error("未确认进入棋局；请检查队长、人数、次数和活动条件") end Sleep(500) end
    end
    local s=combat_setup(scene);s.x,s.y=64,64
    local points={{45,45},{82,45},{82,82},{45,82},{45,64},{64,64}}
    local last=GetTickCount();local patrol=0;local moved=-10000
    while true do
        local event=combat_step(s)
        if event=="boss" then break end
        if event~="empty" then last=GetTickCount()
        elseif GetTickCount()-last>25000 and GetTickCount()-moved>3000 then
            patrol=patrol%#points+1;local p=points[patrol]
            cg(CS.RunTo,{scene},{p[1],p[2]});moved=GetTickCount()
        end
        if GetTickCount()-last>90000 then error("90 秒未发现怪物；未确认通关，已停止") end
        Sleep(500)
    end
    ch("stop_motion")
    GoToSceneNPC("齐圣",40,40,scene)
    if not QuestFrameOptionClicked("确定",1) then error("远古棋魂死亡已确认，但没有找到离场选项") end
    local start=GetTickCount()
    while GetSceneID()==scene do if GetTickCount()-start>20000 then error("没有确认离开棋局") end Sleep(500) end
    cl("远古棋魂死亡及离场均已确认")
end

