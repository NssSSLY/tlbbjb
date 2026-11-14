-- 刷箱子 (楼兰寻宝), written from the reference rules (原脚本源码/Script64/副本/【副本】刷箱子.lua). Kill 200, then 镇宝龙王, loot until the game ends it.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/SMALL_DUNGEONS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Shuaxiang={}
local SCENE=269
local CAMPAIGN={page=1,campaign='楼兰寻宝'}
local entrance={name='金久灵',x=162,y=75,scene=246}
local SEARCH={{63,77},{82,78},{78,55},{53,53},{50,77}}
local KEYS={'已杀死怪物 200/200','ResultText_167'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Shuaxiang.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 3),1,6,'队伍人数')
    assert(cfg.xzk190==nil or type(cfg.xzk190)=='boolean','刷箱子开关无效：xzk190')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='刷箱子',mission='楼兰寻宝',map='楼兰',npc=entrance,bosses={'镇宝龙王'}}
    function def.inside(p) return p.scene==SCENE end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('刷箱子 · '..s) end end
    local function world() return assert(api.world(),'刷箱子场景不可读') end
    local function dialogText()
        local text=GetLuaValue([[-- shuaxiang:dialog-all
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local all=''
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                if type(t)=='string' then all=all..t..'\n' end
            end
            return all]],'s')
        return type(text)=='string' and text or ''
    end
    local function fight()
        local T=DungeonTactics.new(api,SCENE,{'镇宝龙王'});T.watch(KEYS);T.readMessages()
        local start,lastMob,lastPick,searchAt,killedBoss=api.now(),api.now(),-100000,1,false
        while true do
            T.readMessages()
            local p=world()
            if p.scene~=SCENE then return killedBoss end
            assert(api.now()-start<battleMs,'刷箱子战斗超过时限')
            api.alive(minimum,'刷箱子：角色血量低于停止阈值，自动复活未接入，已停止')
            local all=T.rows()
            local mob,boss,corpse
            for _,o in ipairs(all) do
                if T.enemy(o) then
                    if o.name=='镇宝龙王' then boss=o elseif not mob or o.dst<mob.dst then mob=o end
                elseif o.name=='镇宝龙王' and o.hp==0 then corpse=o end
            end
            if boss or mob then
                lastMob=api.now();local target=boss or mob
                if target==boss then
                    log('杀镇宝龙王')
                    if boss.dst>3 and d2(p,63,78)>9 then T.stop();T.move(63,78) else T.attack(boss) end
                elseif mob.dst>5 then log('追怪');T.stop();T.move(math.floor(mob.x),math.floor(mob.y))
                else log('杀怪');T.attack(mob) end
            else
                T.stop()
                if corpse then killedBoss=true end
                if api.now()-lastPick>=1500 then lastPick=api.now();api.pickup() end
                if world().scene~=SCENE then return killedBoss end
                if corpse and corpse.dst>3 then log('前往龙王尸体');T.move(math.floor(corpse.x),math.floor(corpse.y))
                elseif T.seenAt['已杀死怪物 200/200'] then
                    -- Waiting for chests: walk the two spots the reference uses so that new boxes come into reach.
                    log('拾取箱子')
                    local inner=p.x>=57 and p.x<=72 and p.y>=57 and p.y<=72
                    if inner then T.move(63,78) else T.move(65,70) end
                elseif api.now()-lastMob>35000 then
                    log('搜索怪物')
                    local q=SEARCH[searchAt]
                    if not T.move(q[1],q[2]) then searchAt=searchAt%#SEARCH+1;T.clearMove() end
                else log('等待刷新') end
            end
            api.maintain();api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        local before=api.campaign(CAMPAIGN,true)
        local resumed=world().scene==SCENE
        if not resumed then
            if before.used==before.limit then return {status='already_done',message='刷箱子今日次数已满'} end
            api.space();api.prepareBattle()
            api.openNpc(entrance);api.sleep(500)
            api.selectOption({'楼兰寻宝'},true);api.sleep(800)
            local text=dialogText()
            assert(not text:find('#{LLXB_8815_09}',1,true),'刷箱子：现在不是活动时间')
            if GetTeamCount()>0 and api.isLeader() or GetTeamCount()==0 then
                log('等待队伍集合');local began=api.now()
                while not (team<=1 or (api.teamReady(team) and api.teamTogether())) do
                    assert(api.now()-began<DungeonApi.teamPatience(),'刷箱子：等待队伍集合超时')
                    api.maintain();api.sleep(250)
                end
                assert(api.selectOption({cfg.xzk190==true and '#{LLXB_8815_26}' or '#{LLXB_8815_25}'},true),'金久灵没有入场选项')
                api.sleep(800)
                local reply=dialogText()
                assert(not reply:find('#{LLXB_8815_10}',1,true),'刷箱子：需要队伍才能入场')
                assert(not reply:find('#{LLXB_8815_12}',1,true),'刷箱子：队伍人数不足')
                CloseAllWindow()
            else CloseAllWindow() end
            log('确认进入副本');local began=api.now()
            while world().scene~=SCENE do
                assert(api.now()-began<math.max(waitMs,60000),'刷箱子：没有进入副本')
                api.maintain();api.sleep(500)
            end
        end
        fight()
        if not resumed then
            local started,refreshed=api.now(),false
            log('确认活动次数')
            while true do
                local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
                assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'刷箱子活动记录发生变化或次数回退')
                if c.used>before.used then break end
                assert(api.now()-started<math.max(waitMs,15000),'刷箱子：离开后活动次数没有增加，不算完成')
                api.maintain();api.sleep(1000)
            end
        end
        return {status='done',message='刷箱子完成；已离开副本'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'刷箱子停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
