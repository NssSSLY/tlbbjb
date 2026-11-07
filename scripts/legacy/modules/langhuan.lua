-- 琅嬛福地 full flow, written from the reference rules (原脚本源码/Script64/副本/琅嬛福地.lua, 琅嬛福地(困难).lua and
-- 系统/fn琅嬛福地.lua). The normal and hard tasks share these rules. This task owns its stages and receipts.
-- Reference fields this program cannot read (object facing, 虚竹 title, trap names) are replaced by what can be
-- observed; docs/LANGHUAN_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Langhuan={}
local R=assert(CombatRuntime)
local SCENE=677
local modes={
    ['普通']={option='#{LHFD_160203_02}',suffix='',campaign='琅嬛福地(普通)',page=2},
    ['初级']={option='#{XKFB_250115_10}',suffix='·闻恶',campaign='琅嬛福地(普通)·初级',page=4},
    ['中级']={option='#{XKFB_250115_50}',suffix='·识恶',campaign='琅嬛福地(普通)·中级',page=4},
    ['高级']={option='#{XKFB_250115_11}',suffix='·罚恶',campaign='琅嬛福地(普通)·高级',page=4},
    ['困难']={option='#{LHFD_160203_03}',suffix='',campaign='琅嬛福地(困难)',page=2},
}
local BOSSES={{name='李秋水',x=140,y=62},{name='天山童姥',x=212,y=119},{name='无崖子',x=182,y=207},{name='虚竹',x=82,y=181}}
local BY_NAME={};for i,b in ipairs(BOSSES) do BY_NAME[b.name]=i end
local entrance={name='李青萝',x=292,y=92,scene=2}
local KEYS={'LHFD_160203_75','LHFD_160203_92'}
local LIUYANG_SAFE={{74,170},{93,170},{74,190},{93,190}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Langhuan.run(fixedMode,injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3000),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 6),3,6,'队伍人数')
    local modeName=fixedMode or cfg.lhfd_type or '普通'
    local mode=assert(modes[modeName],'琅嬛福地难度无效')
    for _,k in ipairs({'xzk217','langhuan_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','琅嬛福地开关无效：'..k) end
    local hsFollow=cfg.xzk217==true
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={};for _,b in ipairs(BOSSES) do bossNames[#bossNames+1]=b.name;if mode.suffix~='' then bossNames[#bossNames+1]=b.name..mode.suffix end end
    local def={name='琅嬛福地',mission='琅嬛福地',map='琅嬛福地',npc=entrance,bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('琅嬛福地 · '..s) end end
    local function world() return assert(api.world(),'琅嬛福地场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('琅嬛福地：'..label..'超时',0)
    end
    local function rename(name)
        for _,b in ipairs(BOSSES) do
            for _,variant in pairs(modes) do
                if variant.suffix~='' and name==b.name..variant.suffix then
                    assert(variant==mode,'琅嬛福地首领后缀与所选难度不符：'..name)
                    return b.name
                end
            end
        end
        return name
    end
    local function gather(point)
        wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() and api.teamNear(point,20) end)
    end

    local function fight(before)
        local T=DungeonTactics.new(api,SCENE,bossNames)
        local move,attack,enemy,best,list,hasBuff=T.move,T.attack,T.enemy,T.best,T.list,T.hasBuff
        T.watch(KEYS);T.disable('指点江山 昭君出塞')
        local start,lastProgress=api.now(),api.now()
        local stage,done,seen,resetAt,hps,opened,firstRun,arrived=0,{},{},{},{},{},{},{}
        local leader,school=api.isLeader(),api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local emei=school==4
        local own,ownServer=R.host('battle_self_identity');local memberIndex,leaderId=0,nil
        for i,m in ipairs(api.teamIdentities()) do
            if i==1 then leaderId=m.id end
            if m.id==own and m.server_id==ownServer then memberIndex=i-1 end
        end
        local ownName=GetLuaValue("-- langhuan:name\nreturn Player:GetName()",'s')
        assert(type(ownName)=='string' and ownName~='','角色名称不可读')
        local function progress() lastProgress=api.now() end
        local function station(b,r)
            local a=memberIndex*math.pi/3
            return math.floor(b.x+r*math.cos(a)+0.5),math.floor(b.y+r*math.sin(a)+0.5)
        end
        local function leaderPos()
            if not leaderId or leaderId==own then return nil end
            for _,o in ipairs(api.mechanisms()) do if o.kind==1 and o.id==leaderId then return o end end
        end
        -- Back to NPC form after fighting means a wipe. This program does not revive, so that stops by name.
        local function watchBoss(n,boss)
            if enemy(boss) then
                seen[n]=true;resetAt[n]=nil
                if not hps[boss.name] or boss.hp<hps[boss.name] then hps[boss.name]=boss.hp;progress() end
            elseif boss and boss.hp>0 and seen[n] then
                resetAt[n]=resetAt[n] or api.now()
                if api.now()-resetAt[n]>3000 then error('琅嬛福地：'..boss.name..'恢复为 NPC，本关已重置；自动复活未接入，已停止',0) end
            end
        end
        -- Leader: team HP up to 100 seconds, 血祭 cooldown up to 30 seconds, then one talk and one option.
        local function open(n)
            local b=BOSSES[n]
            if opened[n] then
                assert(api.now()-opened[n]<math.max(waitMs,60000),'琅嬛福地：'..b.name..'开怪后没有进入战斗，不重复对话')
                return
            end
            T.stop()
            local started=api.now();log(b.name..' · 等待全队血量 85%')
            while api.now()-started<100000 and not api.teamHealthy(85) do api.maintain();api.sleep(250) end
            started=api.now();log(b.name..' · 等待峨嵋血祭冷却')
            while api.now()-started<30000 do
                local cooling=false
                for _,m in ipairs(api.emeiMembers()) do if hasBuff(api.buffs(m),'珍兽施放共生和血祭') then cooling=true end end
                if not cooling then break end
                api.maintain();api.sleep(500)
            end
            api.openNpc({name=b.name,x=b.x,y=b.y,scene=SCENE});api.sleep(500)
            api.selectOption({'#{LHFD_160203_28}'},false);api.sleep(500);CloseAllWindow()
            opened[n]=api.now();progress();log(b.name..' · 已开怪')
        end
        -- First steps of a fight: melee 3 from the boss, ranged 6.
        local function disperse(n,b)
            if firstRun[n] then return false end
            local x,y=station(b,melee and 3 or 6);log(b.name..' · 走位')
            if move(x,y) then return true end
            firstRun[n]=true;return false
        end

        local function fight1(all,p,boss)
            local b=BOSSES[1]
            local mirror=best(all,'玉璧残影')
            if mirror then log('李秋水 · 玉璧残影集火');T.basicOnly(false);attack(boss);return end
            if T.within('LHFD_160203_75',6000) then
                -- The reference reads the sword's facing and stands behind it; that field is unreadable, so keep away from it.
                local swords=list(all,'剑')
                if #swords>0 and T.escape(swords,15,b.x,b.y,15,8) then log('李秋水 · 躲剑气');T.stop();return end
            end
            local shade=list(all,'无相踪影',enemy)
            if #shade>0 then
                local t=shade[1]
                if not melee then for _,o in ipairs(shade) do if o.hp<t.hp then t=o end end end
                log('李秋水 · 打无相踪影');T.basicOnly(false);attack(t);return
            end
            if not melee and d2(p,b.x,b.y)>(emei and 36 or 64) then log('李秋水 · 靠近中心');T.stop();move(b.x,b.y);return end
            if boss.hp<=17 and not melee and boss.hp<9 and d2(p,b.x,b.y)>4 then T.stop();move(b.x,b.y);return end
            T.basicOnly(boss.hp<=17)
            log('李秋水 · 战斗');attack(boss)
        end

        local function fight2(all,p,boss)
            local b=BOSSES[2]
            T.basicOnly(false)
            if boss.hp>=50 then
                local danger=T.traps()
                if T.escape(danger,8,b.x,b.y,15,5) then log('天山童姥 · 躲陷阱');T.stop();return end
                if melee and #danger>0 and boss.dst>2 then log('天山童姥 · 有陷阱，近战等待');T.stop();return end
            elseif move(b.x,b.y) then log('天山童姥 · 回中心');T.stop();return end
            log('天山童姥 · 战斗');attack(boss)
        end

        -- 黑水: stay out of each pool's radius (the radius is in its NPC name); the ring is 17 from the centre.
        local function blackWater(all,p,boss)
            local pools={}
            for _,o in ipairs(all) do
                if o.name:find('黑水NPC',1,true) then
                    local r=tonumber((o.name:gsub('黑水NPC','')));o.r=(r and r>0) and r or 4;pools[#pools+1]=o
                end
            end
            if #pools==0 then return false end
            table.sort(pools,function(a,c) return a.dst<c.dst end)
            local b=BOSSES[3]
            if hsFollow and not leader then
                local l=leaderPos()
                if l and d2(l,b.x,b.y)<625 and d2(p,l.x,l.y)>=1 then log('无崖子 · 黑水跟随队长');T.stop();move(math.floor(l.x),math.floor(l.y));return true end
            else
                local first=pools[1].r
                local need=(first>14 and 25) or (first>9 and 22) or (first>4 and 18) or 14
                if pools[1].dst<need then
                    local point,score
                    for clear=need,14,-1 do
                        for i=0,71 do
                            local a=i*math.pi/36
                            local x,y=b.x+17*math.cos(a),b.y+17*math.sin(a)
                            local good=true
                            for _,o in ipairs(pools) do if (o.x-x)^2+(o.y-y)^2<clear*clear then good=false;break end end
                            local s=(p.x-x)^2+(p.y-y)^2
                            if good and (not score or s<score) then point,score={math.floor(x+0.5),math.floor(y+0.5)},s end
                        end
                        if point then break end
                    end
                    assert(point,'琅嬛福地：躲避黑水时没有安全坐标')
                    log('无崖子 · 躲黑水');T.stop();move(point[1],point[2]);return true
                end
            end
            log('无崖子 · 黑水输出');T.basicOnly(false);attack(boss);return true
        end
        local function fight3(all,p,boss)
            local b=BOSSES[3]
            if boss.hp<21 and blackWater(all,p,boss) then return end
            -- 八卦阵: run to the safe zone when shown; while the 卦 stand with no zone yet, hold at the centre.
            local zone
            for _,o in ipairs(all) do if o.name:find('八卦安全区',1,true) then zone=o;break end end
            if zone then
                log('无崖子 · 八卦安全区');T.stop();move(math.floor(zone.x),math.floor(zone.y));return
            end
            for _,o in ipairs(all) do
                if o.name~='' and ('乾坤震巽坎离艮兑'):find(o.name,1,true) then
                    log('无崖子 · 八卦等待');T.stop();move(b.x,b.y);return
                end
            end
            local breaker=list(all,'击杀破阵',enemy)[1]
            if breaker then
                log('无崖子 · 破阵集火');T.basicOnly(false)
                if breaker.dst>3 then T.stop();move(math.floor(breaker.x),math.floor(breaker.y));return end
                attack(breaker);return
            end
            if T.escape(T.traps(),7,b.x,b.y,18,5) then log('无崖子 · 躲陷阱');T.stop();return end
            T.basicOnly(boss.hp<21 and boss.hp>9)
            if boss.hp<18 and boss.hp>10 and (not hsFollow or leader) and d2(p,182,188)>9 then
                log('无崖子 · 到黑水站位');T.stop();move(182,188);return
            end
            if boss.hp>30 and not melee and d2(p,b.x,b.y)>(emei and 16 or 36) then log('无崖子 · 靠近中心');T.stop();move(b.x,b.y);return end
            log('无崖子 · 战斗');attack(boss)
        end

        -- 虚竹: the reference picks mechanics by his title, unreadable here, so it uses its own fallback: check them all.
        local function fight4(all,p,boss)
            local b=BOSSES[4]
            T.basicOnly(false)
            if T.escape(T.traps(),7,b.x,b.y,16,4) then log('虚竹 · 躲陷阱');T.stop();return end
            local age=T.age('LHFD_160203_92')
            if age and age<15000 then
                local line=T.lastLine['LHFD_160203_92'] or ''
                if line:find(ownName,1,true) then
                    if age<=7000 then
                        local q,score
                        for _,s in ipairs(LIUYANG_SAFE) do
                            local v=d2(p,s[1],s[2]);if not score or v<score then q,score=s,v end
                        end
                        log('虚竹 · 被点六阳掌，跑开');T.stop()
                        if move(q[1],q[2]) then return end
                    end
                else
                    local palms=list(all,'六阳掌力')
                    if #palms>0 and T.escape(palms,7,b.x,b.y,15) then log('虚竹 · 躲六阳掌');T.stop();return end
                end
            end
            log('虚竹 · 战斗');attack(boss)
        end
        local fights={fight1,fight2,fight3,fight4}

        local function runStage(n,all,p)
            local b=BOSSES[n]
            local boss=best(all,b.name,function(o) return o.hp>0 end)
            watchBoss(n,boss)
            if resetAt[n] then T.stop();return end
            if enemy(boss) then
                if disperse(n,b) then return end
                fights[n](all,p,boss);return
            end
            if boss then
                log(b.name..' · 开怪')
                if leader then open(n) else local x,y=station(b,3);T.stop();move(x,y) end
                return
            end
            log('前往 '..b.name)
            if move(b.x,b.y) then return end
            if n<4 and not seen[n] then
                arrived[n]=arrived[n] or api.now()
                if api.now()-arrived[n]>=3000 then
                    done[n]=true;progress();log(b.name..' 未发现，前往下一个')
                end
            end
        end
        local function finishBoss()
            T.stop()
            wait('恢复原珍兽',function() return T.restorePet() end,8500)
            T.basicOnly(false)
            if cfg.langhuan_loot~=false then api.pickup();api.sleep(300) end
            T.clearMove()
        end

        T.readMessages()
        local finished=false
        while not finished do
            assert(api.now()-start<battleMs,'琅嬛福地战斗超过时限')
            assert(world().scene==SCENE,'琅嬛福地未完成时离开副本')
            api.alive(minimum,'琅嬛福地：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();if T.readMessages() then progress() end
            local all,p=T.rows(rename),world()
            for n,b in ipairs(BOSSES) do
                local o=best(all,b.name)
                if o and o.hp==0 and seen[n] then for i=1,n do done[i]=true end end
            end
            -- 李青萝 at y=181 means the last boss is done, as the reference's LHFD_Start reads it.
            local guide=best(all,'李青萝')
            if guide and math.floor(guide.y)==181 then for i=1,4 do done[i]=true end end
            if done[4] then finished=true;break end
            local highest=0;for n=1,4 do if done[n] then highest=n end end
            local lowest
            for _,o in ipairs(all) do
                local n=BY_NAME[o.name]
                if n and o.hp>0 and n>highest and (not lowest or n<lowest) then lowest=n end
            end
            local wanted=math.max(stage,lowest or highest+1)
            if stage==0 and not lowest then
                for n=4,2,-1 do if d2(p,BOSSES[n].x,BOSSES[n].y)<900 then wanted=n;break end end
            end
            if wanted~=stage then
                if stage>0 then finishBoss() end
                for i=1,wanted-1 do done[i]=true end
                stage=wanted;T.clearMove();progress()
            end
            runStage(stage,all,p)
            api.maintain()
            local actual=world()
            if not seen.px or d2(actual,seen.px,seen.py)>0.25 then seen.px,seen.py=actual.x,actual.y;progress() end
            assert(api.now()-lastProgress<180000,'琅嬛福地阶段没有进展：'..phase)
            api.sleep(250)
        end
        finishBoss()
        local tries=0
        wait('离开琅嬛福地',function()
            if world().scene~=SCENE then return true end
            if tries<3 then
                tries=tries+1
                api.openNpc({name='李青萝',x=82,y=181,scene=SCENE});api.sleep(500)
                if api.selectOption({'#{LHFD_160203_26}'},true) then api.sleep(500);api.confirmBox() end
                CloseAllWindow();api.sleep(4000)
            end
        end,math.max(waitMs,45000))
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(mode,not refreshed);refreshed=true
            assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'琅嬛福地活动记录发生变化或次数回退')
            if c.used>before.used then assert(c.used==before.used+1,'琅嬛福地次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(mode,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message='琅嬛福地今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                api.openNpc(entrance);gather(entrance)
                if api.isLeader() then
                    assert(api.selectOption({mode.option},true),'李青萝没有所选难度的选项：'..modeName)
                end
                wait('确认进入琅嬛福地',function() return world().scene==SCENE end)
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='琅嬛福地完成 '..completed..' 轮；四关结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'琅嬛福地停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
Langhuan.entrance=entrance
