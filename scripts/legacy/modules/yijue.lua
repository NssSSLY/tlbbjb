-- 弈决山河 battleground, written from the reference rules (原脚本源码/Script64/副本/弈决山河.lua). The opponents are players:
-- the game's own enemy relation is read through the host's enemy_players, and skills go through the action button.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/YIJUE_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Yijue={}
local CAMPAIGN={page=1,campaign='弈决山河'}
local CENTRE={253,93}
local QUEUE_MS=600000
local NPCS={
    {lo=60,hi=69,name='康听弦',x=194,y=91,scene=2},
    {lo=70,hi=79,name='康思乐',x=195,y=98,scene=2},
    {lo=80,hi=89,name='康聆音',x=195,y=105,scene=2},
    {lo=90,hi=109,name='石朝华',x=289,y=221,scene=1},
    {lo=110,hi=119,name='李戏生',x=312,y=219,scene=0},
    {lo=120,hi=100000,name='李斯庭',x=316,y=225,scene=0},
}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Yijue.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'场数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    for _,k in ipairs({'yijue_leave_team','yijue_claim'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','弈决山河开关无效：'..k) end
    local level=GetLuaValue("-- yijue:level\nreturn Player:GetData('LEVEL')",'n')
    assert(type(level)=='number','角色等级不可读')
    local npc
    for _,n in ipairs(NPCS) do if level>=n.lo and level<=n.hi then npc=n end end
    if not npc then error('弈决山河：等级 '..math.floor(level)..' 不符合，需要 60 级以上',0) end
    local entrance={name=npc.name,x=npc.x,y=npc.y,scene=npc.scene}
    local def={name='弈决山河',mission='弈决山河',map='弈决山河',npc=entrance,bosses={}}
    function def.inside(p) return p.map:find('弈决山河',1,true)~=nil end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('弈决山河 · '..s) end end
    local function world() return assert(api.world(),'弈决山河场景不可读') end
    local function ui(code) GetLuaValue('-- yijue:ui\n'..code,'',0) end
    local function inBattle(p) return p.map:find('弈决山河',1,true)~=nil end
    local function inRest(p) return p.map:find('战斗休息室',1,true)~=nil end

    local function fight()
        local scene=world().scene
        local T=DungeonTactics.new(api,scene,{})
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local start,lastGhost,attacking=api.now(),-100000,false
        while true do
            local p=world()
            if not inBattle(p) or p.scene~=scene then return end
            assert(api.now()-start<battleMs,'弈决山河战斗超过时限')
            api.skipCinematic()
            local hp=GetLuaValue("-- yijue:hp\nreturn Player:GetData('HP')",'n')
            if type(hp)=='number' and hp<=0 then
                -- Death is normal here. The reference leaves through the battleground's own relive panel.
                attacking=false;log('已死亡，等待回到战场')
                if api.now()-lastGhost>=3000 then
                    lastGhost=api.now()
                    ui("local e=CampPVP2023_Relive_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.CampPVP2023_Relive_Out_Ghost() end")
                end
            else
                local best
                for _,o in ipairs(T.enemyPlayers()) do
                    if o.hp~=0 and (not best or o.dst<best.dst) then best=o end
                end
                if best then
                    if best.dst>(melee and 3 or 15) then
                        log('追击敌人');attacking=false;T.move(math.floor(best.x),math.floor(best.y))
                    else
                        log('战斗');T.clearMove();attacking=true
                        T.strikePlayer(best)
                    end
                else
                    if attacking then api.stopAttack();attacking=false end
                    log('前往中心');T.move(CENTRE[1],CENTRE[2])
                end
            end
            api.maintain();api.sleep(250)
        end
    end

    local function claim()
        if cfg.yijue_claim==false then return end
        log('领取奖励')
        if pcall(api.openNpc,entrance) then api.sleep(500);QuestFrameOptionClicked('#{WWSJ_230213_28}',0);api.sleep(800) end
        CloseAllWindow()
    end
    local function body()
        api.validate(def,cfg)
        while completed<rounds do
            local p=world()
            local before=api.campaign(CAMPAIGN,true)
            local resumed=inBattle(p) or inRest(p)
            if not resumed then
                if before.used==before.limit then
                    claim()
                    return {status=completed>0 and 'done' or 'already_done',message='弈决山河今日次数已满；本次完成 '..completed..' 场'}
                end
                -- The battleground takes single players. Leaving a team needs its own permission.
                if GetTeamCount()>0 then
                    if cfg.yijue_leave_team~=true then error('弈决山河：角色在队伍中，未打开“允许自动退队”，已停止',0) end
                    log('退出队伍');ui("if Player:IsInTeam()==1 then Player:LeaveTeam() end");api.sleep(1000)
                end
                api.openNpc(entrance);api.sleep(500)
                assert(QuestFrameOptionClicked('#{WWSJ_230213_22',0),npc.name..'没有弈决山河报名选项，活动可能未开放')
                api.sleep(1000);CloseAllWindow()
            end
            log('排队等待进入战场')
            local began=api.now()
            while not inBattle(world()) do
                assert(api.now()-began<QUEUE_MS,'弈决山河：报名后 10 分钟没有进入战场，未重复报名')
                api.maintain();api.sleep(1000)
            end
            fight()
            -- An entry resumed from inside may have been counted already, so only a fresh entry is held to the count.
            if not resumed then
                local started,refreshed=api.now(),false
                log('确认本场活动次数')
                while true do
                    local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
                    assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'弈决山河活动记录发生变化或次数回退')
                    if c.used>before.used then break end
                    assert(api.now()-started<math.max(waitMs,15000),'弈决山河：离开战场后活动次数没有增加，不算完成')
                    api.maintain();api.sleep(1000)
                end
            end
            completed=completed+1;log('本场完成（'..completed..'）')
        end
        return {status='done',message='弈决山河完成 '..completed..' 场；已离开战场'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'弈决山河停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
