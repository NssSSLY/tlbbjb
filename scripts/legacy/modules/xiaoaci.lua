-- 暗袭萧阿刺, written from the reference rules (原脚本源码/Script64/活动/暗袭萧阿刺(困难).lua). Three stages in 边境石窟.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/ACTIVITY_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Xiaoaci={}
local SCENE=1072
local entrance={name='灵灵铃',x=250,y=243,scene=0}
local KEYS={'WSTZ_260403_57'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Xiaoaci.run(enterKey)
    enterKey=enterKey or '#{WSTZ_260403_05}'
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 1),1,6,'队伍人数')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'大萨满','萧阿刺'}
    local def={name='暗袭萧阿刺',mission='暗袭萧阿刺',map='边境石窟',npc=entrance,bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('暗袭萧阿刺 · '..s) end end
    local function world() return assert(api.world(),'暗袭萧阿刺场景不可读') end
    local function gathered()
        if team<=1 then return true end
        return api.teamReady(team) and api.teamTogether()
    end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end

    -- Returns true when the raid was sent out, false when it stays inside after the last stage.
    local function fight()
        local T=DungeonTactics.new(api,SCENE,bossNames);T.watch(KEYS);T.readMessages()
        local best,enemy=T.best,T.enemy
        local start,lastProgress,hps,opened,seen,lastTalk,stage,startedAt=api.now(),api.now(),{},{},{},-100000,1,nil
        local own,ownServer=require and nil,nil
        local function progress() lastProgress=api.now() end
        local function hostile(all)
            local t
            for _,o in ipairs(all) do
                if enemy(o) then
                    if not t or o.dst<t.dst then t=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;progress() end
                end
            end
            return t
        end
        local function open(name,x,y,key,n)
            if opened[n] then
                assert(api.now()-opened[n]<math.max(waitMs,60000),'暗袭萧阿刺：'..name..'开启后没有反应，不重复对话')
                return
            end
            if not isLead() then T.stop();T.move(x,y);return end
            if T.move(x,y) then return end
            if not gathered() then log('等待队伍到位');T.stop();return end
            T.stop();CloseAllWindow();TalkNpc(name);api.sleep(1000)
            api.selectOption({key},true);api.sleep(1000);CloseAllWindow()
            opened[n]=api.now();progress();log(name..' · 已开启')
        end
        while true do
            if T.readMessages() then progress() end
            local p=world()
            if p.scene~=SCENE then return true end
            assert(api.now()-start<battleMs,'暗袭萧阿刺战斗超过时限')
            api.alive(minimum,'暗袭萧阿刺：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            local all=T.rows()
            -- What stands on the field says where a resumed run is.
            if stage<3 and best(all,'萧阿刺') then stage=3 elseif stage<2 and best(all,'大萨满') then stage=2 end
            local mob=hostile(all)
            if stage==1 then
                if mob then seen[1]=true;log('第一段 · 清怪');T.attack(mob)
                elseif seen[1] then stage=2;T.clearMove();progress()
                elseif opened[1] then
                    -- The reference waits 15 seconds for the escort, then walks to the fight.
                    if api.now()-opened[1]>=15000 then log('前往第一段');T.stop();T.move(127,190) else T.stop() end
                    assert(api.now()-opened[1]<math.max(waitMs,60000)+15000,'暗袭萧阿刺：灵灵铃开启后没有反应，不重复对话')
                else log('灵灵铃 · 开启');open('灵灵铃',123,219,'#{WSTZ_260403_93}',1) end
            elseif stage==2 then
                local boss=best(all,'大萨满',enemy)
                if boss or mob then seen[2]=true;opened[2]=nil;log('大萨满 · 战斗');T.attack(boss or mob)
                elseif seen[2] then stage=3;T.clearMove();progress()
                elseif best(all,'大萨满') then log('大萨满 · 开启');open('大萨满',130,120,'#{WSTZ_260403_44}',2)
                else log('前往大萨满');T.stop();T.move(130,120) end
            elseif stage==3 then
                local boss=best(all,'萧阿刺',enemy)
                local corpse=best(all,'萧阿刺',function(o) return o.hp==0 end)
                if boss then
                    seen[3]=true;opened[3]=nil
                    if T.within('WSTZ_260403_57',10000) then
                        if T.escape({boss},10,130,50,12,6) then progress() end
                        log('萧阿刺 · 躲避');T.stop()
                    elseif T.escape(T.traps(),5,boss.x,boss.y,10,3) then log('萧阿刺 · 躲陷阱');T.stop();progress()
                    elseif d2(p,130,50)>324 then T.stop();T.move(130,50)
                    else
                        log('萧阿刺 · 战斗')
                        if boss.dst>15 then T.stop();T.move(math.floor(boss.x),math.floor(boss.y)) else T.attack(boss) end
                    end
                elseif corpse or (seen[3] and not best(all,'萧阿刺')) then
                    stage=4;startedAt=api.now();T.stop();progress();log('结束，等待离场')
                elseif best(all,'萧阿刺') then log('萧阿刺 · 开启');open('萧阿刺',127,29,'#{WSTZ_260403_44}',3)
                else log('前往萧阿刺');T.stop();T.move(127,29) end
            else
                -- The reference has no exit step either; it waits here.
                T.stop();progress()
                if api.now()-startedAt>=math.max(waitMs,120000) then return false end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,'暗袭萧阿刺阶段没有进展：'..phase)
            api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        local stayed=false
        while completed<rounds and not stayed do
            if world().scene~=SCENE then
                api.space();api.prepareBattle()
                api.openNpc(entrance)
                log('等待队伍集合');local began=api.now()
                while not gathered() do
                    assert(api.now()-began<DungeonApi.teamPatience(),'暗袭萧阿刺：等待队伍集合超时')
                    api.maintain();api.sleep(250)
                end
                local T=DungeonTactics.new(api,entrance.scene,bossNames);T.watch({'WSTZ_260403_108'});T.readMessages()
                api.selectOption({enterKey},true);api.sleep(1000);CloseAllWindow()
                if world().scene~=SCENE then
                    TalkNpc('灵灵铃');api.sleep(1000)
                    api.selectOption({'#{WSTZ_260403_102}'},true);api.sleep(1000);CloseAllWindow()
                    T.readMessages()
                    if T.seenAt['WSTZ_260403_108'] then
                        return {status=completed>0 and 'done' or 'already_done',message='暗袭萧阿刺：入口提示次数已用完；本次完成 '..completed..' 轮'}
                    end
                end
                log('确认进入副本');began=api.now()
                while world().scene~=SCENE do
                    assert(api.now()-began<math.max(waitMs,60000),'暗袭萧阿刺：选择后没有进入副本，未重复发送')
                    api.maintain();api.sleep(500)
                end
            end
            stayed=not fight();completed=completed+1;log('本轮完成（'..completed..'）')
        end
        if stayed then return {status='done',message='暗袭萧阿刺完成 '..completed..' 轮；仍在副本内，没有继续下一轮'} end
        return {status='done',message='暗袭萧阿刺完成 '..completed..' 轮；已离场'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'暗袭萧阿刺停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
