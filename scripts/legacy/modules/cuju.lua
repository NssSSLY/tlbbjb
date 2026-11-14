-- 蹴鞠大赛(踢球), written from the reference rules (原脚本源码/Script64/副本/蹴鞠大赛(踢球).lua). Kill what carries the ball, carry it to the goal.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/SMALL_DUNGEONS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Cuju={}
local SCENE=233
local GOAL={37,31}
local NPCS={[0]={name='童贯',x=301,y=192,scene=0},[1]={name='于倩倩',x=283,y=241,scene=1},[2]={name='夏青青',x=295,y=131,scene=2}}
local RECEIVERS={['童贳']=true,['于倩倩']=true,['夏青青']=true}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Cuju.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 3),1,6,'队伍人数')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='蹴鞠大赛',mission='蹴鞠大赛',map='蹴鞠',npc=NPCS[1],bosses={}}
    function def.inside(p) return p.scene==SCENE end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('蹴鞠大赛 · '..s) end end
    local function world() return assert(api.world(),'蹴鞠大赛场景不可读') end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function fight()
        local T=DungeonTactics.new(api,SCENE,{})
        local start,lastProgress,lastTalk,hps,delivered=api.now(),api.now(),-100000,{},0
        while true do
            local p=world()
            if p.scene~=SCENE then return delivered end
            assert(api.now()-start<battleMs,'蹴鞠大赛战斗超过时限')
            api.alive(minimum,'蹴鞠大赛：角色血量低于停止阈值，自动复活未接入，已停止')
            local own=api.buffs()
            if T.hasBuff(own,'被打醒') then
                log('被打醒，等待');T.stop()
            else
                local all=T.rows()
                local mob
                for _,o in ipairs(all) do
                    if T.enemy(o) and (not mob or o.dst<mob.dst) then mob=o end
                    if T.enemy(o) and (not hps[o.id] or o.hp<hps[o.id]) then hps[o.id]=o.hp;lastProgress=api.now() end
                end
                if mob then
                    log('打怪');T.attack(mob)
                elseif T.hasBuff(own,'蹴鞠光环') then
                    log('送球');T.stop()
                    api.pickup()
                    if world().scene~=SCENE then return delivered end
                    if not T.move(GOAL[1],GOAL[2]) and api.now()-lastTalk>=6000 then
                        lastTalk=api.now()
                        for _,o in ipairs(all) do
                            if RECEIVERS[o.name] then
                                CloseAllWindow();TalkNpc(o.name);api.sleep(800)
                                if QuestFrameOptionClicked('送',0) then delivered=delivered+1;lastProgress=api.now() end
                                api.sleep(800);CloseAllWindow();break
                            end
                        end
                    end
                else log('等待刷怪');T.stop() end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or (q.x-hps.px)^2+(q.y-hps.py)^2>0.25) then hps.px,hps.py=q.x,q.y;lastProgress=api.now() end
            assert(api.now()-lastProgress<300000,'蹴鞠大赛阶段没有进展：'..phase)
            api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        if world().scene~=SCENE then
            api.space();api.prepareBattle()
            -- The reference picks the nearest of the three by the map it is on; anywhere else, 苏州.
            local npc=NPCS[world().scene] or NPCS[1]
            if isLead() then
                api.openNpc(npc)
                log('等待队伍集合');local began=api.now()
                while not (team<=1 or (api.teamReady(team) and api.teamTogether())) do
                    assert(api.now()-began<DungeonApi.teamPatience(),'蹴鞠大赛：等待队伍集合超时')
                    api.maintain();api.sleep(250)
                end
                assert(api.selectOption({'横扫牡丹碗'},true),npc.name..'没有横扫牡丹碗选项，活动可能未开放')
                api.sleep(1000);CloseAllWindow()
            else
                -- A follower meets the leader at the same NPC and waits.
                api.openNpc(npc);CloseAllWindow()
            end
            log('确认进入球场');local began=api.now()
            while world().scene~=SCENE do
                assert(api.now()-began<(isLead() and math.max(waitMs,60000) or 600000),'蹴鞠大赛：没有进入球场')
                api.maintain();api.sleep(500)
            end
        end
        local delivered=fight()
        return {status='done',message='蹴鞠大赛结束，送球 '..delivered..' 次；已离开球场'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'蹴鞠大赛停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
