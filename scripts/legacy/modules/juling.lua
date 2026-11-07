-- 聚灵谷 full flow (简单, 普通, 困难), written from the reference rules (原脚本源码/Script64/副本/聚灵谷简单.lua, 聚灵谷普通.lua, 聚灵谷困难.lua,
-- 系统/fn聚灵谷.lua). The three differ only in how the raid enters; the fight is one scene.
-- This task owns its stages and receipts; it does not load the vendor framework.
-- Reference fields this program cannot read (NPC level, facing, trap names) are replaced by what can be observed;
-- docs/JULING_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Juling={}
local R=assert(CombatRuntime)
local SCENE=877
local CAMPAIGN={page=1,campaign='灵谷勘兽迹'}
local ZERO={x=52,y=107,r=15}
local PATROL={{107,120},{133,79},{107,59},{83,55},{60,72},{52,107}}
local BEASTS={['剧毒乌犍']=true,['玄雷宝驹']=true,['雪海沧龙']=true,['赤焰黑虎']=true}
local SEARCH_MS=600000
local SEARCH={
    [201]={{221,165},{228,133},{202,139},{165,152},{225,73},{200,66},{175,42},{101,56},{99,18},{73,20},{88,59},{30,44},{45,111},{46,150},{19,172},{93,162},{50,212},{102,216}},
    [875]={{251,272},{239,262},{174,257},{171,233},{217,204},{227,228},{265,170},{277,72},{204,84},{192,107},{180,73},{126,89},{49,118},{111,248},{41,222},{87,284}},
}
local KEYS={'SESX_230426_35','SESX_230426_106','SESX_230426_107','SESX_230426_81','SESX_230426_87','SESX_230426_69','SESX_230426_75'}
local NAMES={'聚灵谷简单','聚灵谷普通','聚灵谷困难'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Juling.run(mode,injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local title=assert(NAMES[mode],'聚灵谷难度无效')
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 1),1,6,'队伍人数')
    for _,k in ipairs({'不打雷锁','不打小怪','不打雪海沧龙','不打赤焰黑虎','不打玄雷宝驹','不打剧毒乌犍','宿灵渊'}) do
        assert(cfg[k]==nil or type(cfg[k])=='boolean',title..'开关无效：'..k)
    end
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'剧毒乌犍','玄雷宝驹','雪海沧龙','赤焰黑虎'}
    local entranceNpc=mode==2 and {x=156,y=146} or {x=150,y=146}
    local def={name=title,mission='灵谷勘兽迹',map='聚灵谷',npc={name='灵兽',x=153,y=146,scene=112},bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log(title..' · '..s) end end
    local function world() return assert(api.world(),title..'场景不可读') end
    local function ui(code) GetLuaValue('-- juling:ui\n'..code,'',0) end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function gathered()
        if team<=1 then return true end
        return api.teamReady(team) and api.teamTogether()
    end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error(title..'：'..label..'超时',0)
    end

    -- Returns true once the raid has left the scene.
    local function fight()
        ui("if Player:IsFollow()==1 or Player:IsFollow()==true then Player:StopFollow() end")
        local T=DungeonTactics.new(api,SCENE,bossNames);T.watch(KEYS);T.readMessages()
        local move,enemy,best,list,hasBuff=T.move,T.enemy,T.best,T.list,T.hasBuff
        local start,lastProgress=api.now(),api.now()
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        local hps,settled,lowest={},{},{}
        local patrolAt,boxTried,lastLeave,leaves,best_=1,nil,-100000,0,nil
        do local p=world();for i,q in ipairs(PATROL) do local s=d2(p,q[1],q[2]);if not best_ or s<best_ then patrolAt,best_=i,s end end end
        local function progress() lastProgress=api.now() end
        local function station(r)
            local a=memberIndex*math.pi/3
            return math.floor(ZERO.x+r*math.cos(a)+0.5),math.floor(ZERO.y+r*math.sin(a)+0.5)
        end
        local function ownBuff(text) return hasBuff(api.buffs(),text) end
        local function othersWith(text)
            local out={}
            for _,o in ipairs(T.players()) do if hasBuff(api.buffs(o),text) then out[#out+1]=o end end
            return out
        end
        -- A strip from the centre along an angle, half-width w, length 15: stand clear of every strip.
        local function stripDodge(angles,w,p)
            local inside=function(x,y)
                for _,a in ipairs(angles) do
                    local ux,uy=math.cos(a),math.sin(a)
                    local along=(x-ZERO.x)*ux+(y-ZERO.y)*uy
                    local perp=math.abs((x-ZERO.x)*uy-(y-ZERO.y)*ux)
                    if along>=0 and along<=15 and perp<w then return true end
                end
                return false
            end
            if not inside(p.x,p.y) then return false end
            local point,score
            for dx=-15,15 do for dy=-15,15 do
                local x,y=ZERO.x+dx,ZERO.y+dy
                if dx*dx+dy*dy<=225 and not inside(x,y) then
                    local s=d2(p,x,y);if not score or s<score then point,score={x,y},s end
                end
            end end
            if point then move(point[1],point[2]) end
            return true
        end
        local function anglesTo(items,skip)
            local out={}
            for _,o in ipairs(items) do
                if d2(o,ZERO.x,ZERO.y)>1 and not (skip and d2(o,skip.x,skip.y)<1) then out[#out+1]=math.atan(o.y-ZERO.y,o.x-ZERO.x) end
            end
            return out
        end
        local function coneDodge(boss,spot,p,unsafe)
            local cone=math.deg(math.atan(spot.y-boss.y,spot.x-boss.x))
            local mine=math.deg(math.atan(p.y-boss.y,p.x-boss.x))
            local diff=math.abs(cone-mine);if diff>180 then diff=360-diff end
            if diff>=unsafe then return false end
            local r=math.max(4,math.sqrt(d2(p,boss.x,boss.y)))
            local a=math.rad(cone+unsafe+30)
            move(math.floor(boss.x+r*math.cos(a)+0.5),math.floor(boss.y+r*math.sin(a)+0.5));return true
        end
        -- During a mechanic melee only strikes within 3, and everyone within 15.
        local function strike(target,mech)
            if mech and (target.dst>15 or (melee and target.dst>3)) then log(target.name..' · 机制中目标太远');T.stop();return end
            T.attack(target)
        end
        local H={}
        H['剧毒乌犍']=function(all,p,boss)
            if T.within('SESX_230426_81',3000) then
                log('剧毒乌犍 · 散开');T.stop();local x,y=station(7);move(x,y);return
            end
            local set=T.traps();for _,o in ipairs(list(all,'牛陷阱预警NPC')) do set[#set+1]=o end
            local named=#set>0
            for _,o in ipairs(othersWith('毒厄')) do set[#set+1]=o end
            if T.escape(set,6,ZERO.x,ZERO.y,ZERO.r,3) then log('剧毒乌犍 · 躲陷阱');T.stop();return end
            local poisoned=ownBuff('毒厄')
            if poisoned and T.escape(T.players(),6,ZERO.x,ZERO.y,ZERO.r,3) then log('剧毒乌犍 · 毒厄离开队友');T.stop();return end
            log('剧毒乌犍 · 战斗');strike(boss,named or poisoned or #set>0)
        end
        H['玄雷宝驹']=function(all,p,boss)
            if ownBuff('雷域：') then log('玄雷宝驹 · 雷域停手');T.stop();return end
            local charge=T.within('SESX_230426_87',20000)
            if charge and d2(p,ZERO.x,ZERO.y)>4 then log('玄雷宝驹 · 回中心');T.stop();move(ZERO.x,ZERO.y);return end
            local spot=list(all,'生肖副本通用空NPC')[1]
            if not charge and spot and coneDodge(boss,spot,p,55) then log('玄雷宝驹 · 躲扇形');T.stop();return end
            if hasBuff(api.buffs(boss),'护盾：') then log('玄雷宝驹 · 破盾');T.attack(boss);return end
            local locks=cfg['不打雷锁']==true and {} or list(all,'雷锁',enemy)
            if T.within('SESX_230426_87',3000) then log('玄雷宝驹 · 蓄力停手');T.stop();return end
            if #locks>0 then
                local t=locks[1];for _,o in ipairs(locks) do if o.hp<t.hp then t=o end end
                log('玄雷宝驹 · 打雷锁');T.attack(t);return
            end
            log('玄雷宝驹 · 战斗');strike(boss,spot~=nil)
        end
        H['雪海沧龙']=function(all,p,boss)
            if T.within('SESX_230426_69',20000) then
                local a=anglesTo(list(all,'生肖副本通用空NPC'))
                if #a>0 and stripDodge(a,3,p) then log('雪海沧龙 · 躲冰柱');T.stop();return end
                log('雪海沧龙 · 冰柱中停手');T.stop();return
            end
            local clones={};for _,o in ipairs(all) do if o.name=='雪海沧龙' and not enemy(o) and o.hp>0 then clones[#clones+1]=o end end
            local a=anglesTo(clones)
            if #a>0 then
                if stripDodge(a,4,p) then log('雪海沧龙 · 躲龙息');T.stop();return end
                log('雪海沧龙 · 机制中输出');strike(boss,true);return
            end
            local heavy=ownBuff('重雪：')
            local set=heavy and T.players() or othersWith('重雪：')
            if T.escape(set,6,ZERO.x,ZERO.y,ZERO.r,3) then log('雪海沧龙 · 重雪分开');T.stop();return end
            log('雪海沧龙 · 战斗');strike(boss,heavy or #set>0)
        end
        H['赤焰黑虎']=function(all,p,boss)
            local warn=list(all,'白虎预警NPC')
            local spots=list(all,'生肖副本通用空NPC')
            if #warn>0 then
                local a=anglesTo(#spots>0 and spots or warn,#spots>0 and warn[1] or nil)
                if #a>0 and stripDodge(a,4,p) then log('赤焰黑虎 · 躲扑击');T.stop();return end
            end
            if T.within('SESX_230426_75',6000) then log('赤焰黑虎 · 机制中停手');T.stop();return end
            log('赤焰黑虎 · 战斗');strike(boss,#warn>0)
        end
        local function leaveScene()
            if leaves>=3 or api.now()-lastLeave<6000 then return end
            log('云昕昕 · 离开')
            if move(56,139) then return end
            lastLeave=api.now();leaves=leaves+1;T.stop();CloseAllWindow()
            TalkNpc('云昕昕');api.sleep(800)
            api.selectOption({'#{SESX_230426_98}'},true);api.sleep(800)
            api.selectOption({'#{SESX_230426_40}'},true);api.sleep(800);api.confirmBox();CloseAllWindow();api.sleep(1500)
        end

        local cleared=false
        while true do
            if T.readMessages() then progress() end
            local p=world()
            if p.scene~=SCENE then
                assert(cleared or T.seenAt['SESX_230426_35'] or T.seenAt['SESX_230426_107'],title..'未完成时离开副本')
                return true
            end
            assert(api.now()-start<battleMs,title..'战斗超过时限')
            api.alive(minimum,title..'：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            local all=T.rows()
            local boss,adds,nearAdd=nil,{},nil
            for _,o in ipairs(all) do
                if enemy(o) then
                    if BEASTS[o.name] then boss=o
                    else adds[#adds+1]=o;if not nearAdd or o.dst<nearAdd.dst then nearAdd=o end end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;progress() end
                end
            end
            local box=best(all,'聚灵宝箱',function(o) return o.hp>0 end)
            if T.seenAt['SESX_230426_35'] or T.seenAt['SESX_230426_107'] or box then cleared=true end
            if T.within('SESX_230426_106',100000) or T.seenAt['SESX_230426_107'] then
                leaveScene()
                if leaves>=3 and api.now()-lastLeave>math.max(waitMs,60000) then error(title..'：离开选项发出后仍在副本内，不再重复',0) end
            elseif box then
                log('开启聚灵宝箱');T.stop()
                if box.dst>3 then move(math.floor(box.x),math.floor(box.y))
                elseif not boxTried or api.now()-boxTried>=6000 then
                    boxTried=api.now();progress();CloseAllWindow()
                    TalkNpc('聚灵宝箱');api.sleep(800)
                    api.selectOption({'#{SESX_230426_103}'},true);api.sleep(1000);CloseAllWindow()
                end
            elseif boss then
                -- Back at near-full health after taking real damage means the team wiped; no revive here.
                lowest[boss.id]=math.min(lowest[boss.id] or 100,boss.hp)
                if lowest[boss.id]<70 and boss.hp>=99 then error(title..'：'..boss.name..'回满血量，判定灭团；自动复活未接入，已停止',0) end
                if not settled[boss.name] then
                    local x,y=station(melee and 3 or 7)
                    if move(x,y) then log(boss.name..' · 走位') else settled[boss.name]=true end
                end
                if settled[boss.name] then H[boss.name](all,p,boss) end
            elseif cleared then
                leaveScene()
            elseif cfg['不打小怪']==true then
                log('前往首领位置');T.stop();move(ZERO.x,ZERO.y)
            elseif nearAdd and nearAdd.dst<=15 then
                log('清理小怪');T.attack(nearAdd)
            else
                log('巡逻清理');T.stop()
                local q=PATROL[patrolAt]
                if not move(q[1],q[2]) then patrolAt=patrolAt%#PATROL+1;T.clearMove() end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,title..'阶段没有进展：'..phase)
            api.sleep(250)
        end
    end

    -- 简单 and 普通: at (153,146) in scene 112 the two beasts stand 6 apart. Their level cannot be read; their spot tells them apart.
    local function enterTown()
        if world().scene~=112 or d2(world(),153,146)>9 then MoveTo(153,146,112) end
        wait('等待队伍集合',gathered,math.max(waitMs,70000))
        if not isLead() then return true end
        local T=DungeonTactics.new(api,112,bossNames)
        local npc
        local start=api.now()
        while not npc and api.now()-start<waitMs do
            for _,o in ipairs(T.rows()) do
                if BEASTS[o.name] and o.hp>0 and d2(o,entranceNpc.x,entranceNpc.y)<=9 then npc=o end
            end
            if not npc then api.maintain();api.sleep(500) end
        end
        assert(npc,title..'：入口处没有找到灵兽')
        CloseAllWindow();TalkNpc(npc.name);api.sleep(800)
        assert(api.selectOption({mode==2 and '#{SESX_230426_139}' or '#{SESX_230426_15}'},true),npc.name..'没有入场选项')
        api.sleep(1000);CloseAllWindow()
    end
    -- 困难: beasts roam 圣兽山 or 宿灵渊. The leader walks the route; followers wait there.
    local function enterWild()
        local target=cfg['宿灵渊']==true and 875 or 201
        local route=SEARCH[target]
        if not isLead() then
            if world().scene~=target then MoveTo(route[1][1],route[1][2],target) end
            return true
        end
        if world().scene~=target then MoveTo(route[1][1],route[1][2],target) end
        local T=DungeonTactics.new(api,target,bossNames)
        ui("if Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end")
        local idx,best_=1,nil
        do local p=world();for i,q in ipairs(route) do local s=d2(p,q[1],q[2]);if not best_ or s<best_ then idx,best_=i,s end end end
        local tried,start={},api.now()
        while api.now()-start<SEARCH_MS do
            log('寻找灵兽')
            local npc
            for _,o in ipairs(T.rows()) do
                if BEASTS[o.name] and o.hp>0 and cfg['不打'..o.name]~=true and api.now()-(tried[o.id] or -100000)>=30000 and (not npc or o.dst<npc.dst) then npc=o end
            end
            if npc then
                tried[npc.id]=api.now()
                log('发现 '..npc.name)
                if pcall(api.openNpc,{name=npc.name,x=math.floor(npc.x),y=math.floor(npc.y),scene=target}) then
                    api.sleep(500)
                    if gathered() and api.selectOption({'#{SESX_230426_140}'},true) then
                        api.sleep(1000);CloseAllWindow()
                        return
                    end
                end
                CloseAllWindow();T.clearMove()
            else
                local q=route[idx]
                if not T.move(q[1],q[2]) then idx=idx%#route+1;T.clearMove() end
            end
            api.maintain();api.sleep(250)
        end
        error(title..'：10 分钟没有找到可入场的灵兽',0)
    end
    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            local resumed=world().scene==SCENE
            if not resumed then
                if before.used==before.limit then
                    return {status=completed>0 and 'done' or 'already_done',message=title..'本周次数已满；本次完成 '..completed..' 轮'}
                end
                api.space();api.prepareBattle()
                local follower
                if mode==3 then follower=enterWild() else follower=enterTown() end
                log('确认进入聚灵谷')
                local began=api.now()
                while world().scene~=SCENE do
                    if api.now()-began>=(follower and SEARCH_MS or math.max(waitMs,60000)) then error(title..'：没有进入副本',0) end
                    api.maintain();api.sleep(500)
                end
            end
            fight()
            if not resumed then
                local started,refreshed=api.now(),false
                log('确认本轮活动次数')
                while true do
                    local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
                    assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,title..'活动记录发生变化或次数回退')
                    if c.used>before.used then assert(c.used==before.used+1,title..'次数一次增加超过一轮');break end
                    assert(api.now()-started<math.max(waitMs,15000),title..'：离开后活动次数没有增加，不算完成')
                    api.maintain();api.sleep(1000)
                end
            end
            completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message=title..'完成 '..completed..' 轮；通关、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,title..'停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
