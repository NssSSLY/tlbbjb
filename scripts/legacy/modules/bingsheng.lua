-- 兵圣奇阵 full flow (12-player raid), written from the reference rules (原脚本源码/Script64/副本/兵圣奇阵(12人).lua).
-- This task owns its stages and receipts; it does not load the vendor framework.
-- Reference data this program cannot read (boss target / state, 牛妖 title, trap names, raid member HP and position)
-- is replaced by what can be observed; docs/BINGSHENG_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Bingsheng={}
local R=assert(CombatRuntime)
local SCENE=294
local CAMPAIGN={page=1,campaign='兵圣奇阵'}
local entrance={name='高阳',x=306,y=255,scene=0}
local NAMES={'萧逸风','萧如筠','耶律焱','耶律连城'}
local DONE={'BSQZ_101223_163','BSQZ_101223_167','BSQZ_101223_171','BSQZ_101223_176'}
local KEYS={'BSQZ_101223_163','BSQZ_101223_167','BSQZ_101223_171','BSQZ_101223_176','BSQZ_101223_122','BSQZ_101223_94'}
local BOSS1_POS={{73,63},{73,59},{73,55},{73,51},{77,48},{77,52},{77,56},{77,59},{73,63},{73,51},{73,59},{77,48}}
local TWINS={
    {name='萧如筠',x=174,y=36,safe={139,64},gate={147,60},colors={'同心竹·蓝','同心竹·黄','同心竹·紫'},
     ring={{159,45},{158,49},{160,57},{168,57},{176,57},{188,57},{188,49},{188,41},{187,33},{183,26},{176,22},{165,29},{163,40}}},
    {name='萧如蔚',x=174,y=100,safe={134,110},gate={140,109},colors={'同心竹·红','同心竹·绿','同心竹·白'},
     ring={{154,101},{154,111},{162,111},{167,118},{175,112},{182,107},{189,100},{189,92},{183,85},{176,85},{168,85},{160,87},{156,93}}},
}
local FUZHEN={['耶律连城·铁骨']={52,212},['耶律连城·元神']={53,195}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end
-- Combat areas of the four fights, from BSQZ_GetPosStep.
local function areaOf(p)
    if p.x<79 and p.y<93 then return 1 end
    if p.x>=138 and p.y<70 then return 2,1 end
    if p.x>=133 and p.y>75 and p.y<115 then return 2,2 end
    if p.x>153 and p.y>132 then return 3 end
    if p.x<99 and p.y>170 then return 4 end
    return -1
end

function Bingsheng.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local teamCount=int(tonumber(cfg.dungeon_team_count or 12),7,12,'团队人数')
    local difficulty=cfg.bingsheng_mode or '简单'
    local option=({['简单']='#{BSQZ_101223_06}',['困难']='#{BSQZ_101223_07}'})[difficulty]
    assert(option,'兵圣奇阵模式无效')
    local twinChoice=cfg.bingsheng_twin or '按分队'
    assert(twinChoice=='按分队' or twinChoice=='萧如筠' or twinChoice=='萧如蔚','兵圣奇阵双子分工无效')
    for _,k in ipairs({'xzk260','xzk230','xzk199','xzk200','xzk201','xzk202','xzk203','xzk204','xzk232','xzk234','bingsheng_loot'}) do
        assert(cfg[k]==nil or type(cfg[k])=='boolean','兵圣奇阵开关无效：'..k)
    end
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'萧逸风','萧如筠','萧如蔚','耶律焱','耶律连城'}
    local def={name='兵圣奇阵',mission='兵圣奇阵',map='兵圣奇阵',npc=entrance,bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('兵圣奇阵 · '..s) end end
    local function world() return assert(api.world(),'兵圣奇阵场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('兵圣奇阵：'..label..'超时',0)
    end

    local function fight(before)
        local T=DungeonTactics.new(api,SCENE,bossNames)
        local move,attack,enemy,best,list,hasBuff=T.move,T.attack,T.enemy,T.best,T.list,T.hasBuff
        T.watch(KEYS)
        local start,lastProgress=api.now(),api.now()
        local stage,done,seen,hps,firstRun=0,{},{},{},{}
        local waited={}
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local outer=GetLuaValue("-- bingsheng:outer\nlocal a=Player:GetData('ATT_PHYSICS') local b=Player:GetData('ATT_MAGIC') if a>b then return 1 end return 0",'n')==1
        local squad,slot=DungeonTactics.raidSelf()
        local raidIndex=(squad*6+slot)%12
        local function progress() lastProgress=api.now() end
        -- A boss back at full health after taking damage means the raid wiped. This program does not revive: stop by name.
        local function watchBoss(boss)
            if not boss then return end
            if boss.hp>0 and hps[boss.name] and boss.hp>=100 and hps[boss.name]<95 then
                error('兵圣奇阵：'..boss.name..'血量恢复，本关已重置；自动复活未接入，已停止',0)
            end
            if not hps[boss.name] or boss.hp<hps[boss.name] then hps[boss.name]=boss.hp;progress() end
        end
        local function started(boss) return boss~=nil and enemy(boss) and boss.hp<100 end
        -- The raid gathers in the fight's area, up to the reference's 90 seconds, before anyone starts it.
        local function raidReady(n,cx,cy,r)
            local inArea=0
            for _,o in ipairs(T.players()) do if d2(o,cx,cy)<r*r then inArea=inArea+1 end end
            if inArea+1>=teamCount then return true end
            waited[n]=waited[n] or api.now()
            if api.now()-waited[n]>90000 then return true end
            log(NAMES[n]..' · 等待团员到位（'..(inArea+1)..'/'..teamCount..'）');progress()
            return false
        end
        local function station(cx,cy,r)
            local a=raidIndex*math.pi/6
            return math.floor(cx+r*math.cos(a)+0.5),math.floor(cy+r*math.sin(a)+0.5)
        end
        local function clear(all,name)
            local mob=list(all,name,enemy)[1]
            if mob then log('清理'..name);attack(mob);return true end
            return false
        end
        local function lowestHp(objects,range)
            local found
            for _,o in ipairs(objects) do
                if (not range or o.dst<=range) and (not found or o.hp<found.hp) then found=o end
            end
            return found
        end

        local function stage1(all,p)
            local boss=best(all,'萧逸风',function(o) return o.hp>0 end);watchBoss(boss)
            -- Only before the fight: dodging during it may legitimately go further out.
            if not started(boss) and d2(p,51,57)>28^2 then log('前往萧逸风');move(58,80);return end
            if clear(all,'风阵守卫') then return end
            if not started(boss) and not raidReady(1,51,60,32) then T.stop();move(58,80);return end
            T.disable('横扫乾坤 暗器连击 三阳开泰 连珠腐尸毒 移花接木 万箭齐发 鹰击长空 定海神针')
            local own=api.buffs()
            if hasBuff(own,'飓风术：') then log('萧逸风 · 中飓风术');T.stop();return end
            local whirl=list(all,'旋风',enemy);local bomb=list(all,'风雷弹',enemy)
            local xun=best(all,'巽风') or best(all,'震雷')
            local point=BOSS1_POS[raidIndex+1] or BOSS1_POS[3]
            local target
            if hasBuff(own,'聚风：') then
                log('萧逸风 · 聚风远离人群')
                if T.escape(T.players(),4,72,55,20,3) then T.stop();return end
                target=lowestHp(whirl,15) or lowestHp(bomb,15)
                if not target then T.stop();return end
            elseif xun then
                log('萧逸风 · 巽风震雷走位')
                if move(point[1],point[2]) then T.stop();return end
                target=lowestHp(whirl,15) or lowestHp(bomb,15)
                if not target then T.stop();return end
            else
                target=lowestHp(whirl,15) or whirl[1] or lowestHp(bomb,15) or bomb[1] or (enemy(boss) and boss or nil)
                if not target then log('前往萧逸风');move(51,57);return end
                if target==boss and boss.hp>=100 then log('萧逸风 · 开战');attack(boss);return end
                if not firstRun[1] and not melee then
                    log('萧逸风 · 走位');if move(point[1],point[2]) then return end;firstRun[1]=true
                end
            end
            log('萧逸风 · 战斗');seen[1]=true;attack(target)
        end

        local twinIndex
        local ringIndex=1
        local function colors(area)
            if cfg.xzk230 then return TWINS[area].colors end
            local out={}
            for key,name in pairs({xzk199='同心竹·蓝',xzk200='同心竹·红',xzk201='同心竹·黄',xzk202='同心竹·绿',xzk203='同心竹·紫',xzk204='同心竹·白'}) do
                if cfg[key] then out[#out+1]=name end
            end
            return out
        end
        local function stage2(all,p)
            if p.x<108 or p.y>120 then log('前往林阵');move(109,93);return end
            if clear(all,'林阵守卫') or clear(all,'风阵守卫') then return end
            local step,area=areaOf(p)
            if step~=2 then
                if not twinIndex then
                    if twinChoice=='萧如筠' then twinIndex=1 elseif twinChoice=='萧如蔚' then twinIndex=2
                    else twinIndex=squad==0 and 1 or 2 end
                end
                log('前往 '..TWINS[twinIndex].name);move(TWINS[twinIndex].gate[1],TWINS[twinIndex].gate[2]);return
            end
            local npc=TWINS[area]
            local boss=best(all,npc.name);if boss and boss.hp>0 then watchBoss(boss) end
            if not started(boss) and not seen[2] then
                if not raidReady(2,174,68,45) then T.stop();move(npc.gate[1],npc.gate[2]);return end
            end
            if cfg.xzk232 and not (boss and boss.hp==0) then
                log(npc.name..' · 安全点等待');T.stop();move(npc.safe[1],npc.safe[2]);progress();return
            end
            T.disable('棒打狗头 凌神式 拖泥带水 行尸走肉')
            local own=api.buffs();local danger=T.traps()
            if hasBuff(own,'迷踪：') or hasBuff(own,'束步：') or hasBuff(own,'步步生竹：') then
                -- Keep walking the ring, skipping points with a trap nearby, until the buff ends.
                log(npc.name..' · 带竹刺跑圈');T.stop()
                for _=1,#npc.ring do
                    local q=npc.ring[ringIndex];local safe=true
                    for _,o in ipairs(danger) do if (o.x-q[1])^2+(o.y-q[2])^2<36 then safe=false;break end end
                    if safe and move(q[1],q[2]) then return end
                    ringIndex=ringIndex%#npc.ring+1
                end
                return
            end
            if T.escape(danger,6,npc.x,npc.y,12,4) then log(npc.name..' · 躲竹刺');T.stop();return end
            for _,name in ipairs(colors(area)) do
                for _,o in ipairs(list(all,name,enemy)) do
                    if o.dst<=25 and not hasBuff(api.buffs(o),'孪生守护：') then log(npc.name..' · 打同心竹');seen[2]=true;attack(o);return end
                end
            end
            if boss and boss.hp==0 then log(npc.name..' 已倒下，等另一路');T.stop();progress();return end
            if not enemy(boss) then log('寻找 '..npc.name);T.stop();move(npc.x,npc.y);return end
            if not firstRun[2] and not melee then
                local a=(slot%6)*math.pi/3
                log(npc.name..' · 走位')
                if move(math.floor(npc.x+5*math.cos(a)+0.5),math.floor(npc.y+5*math.sin(a)+0.5)) then return end
                firstRun[2]=true
            end
            if hasBuff(api.buffs(boss),'无敌：') then log(npc.name..' · 无敌');T.stop();return end
            log(npc.name..' · 战斗');seen[2]=true;attack(boss)
        end

        -- 侵略如火: each raid member takes a 水迹. A 水迹's buff "水迹N" says how many members it holds.
        local function waterSpot(all)
            local spots=list(all,'水迹')
            if #spots==0 then return nil end
            local function angle(o) return math.atan(o.y-193,o.x-193) end
            table.sort(spots,function(a,b) return angle(a)<angle(b) end)
            local running=0
            for _,o in ipairs(spots) do
                local slots=0
                for name in pairs(api.buffs(o)) do
                    local n=name:match('水迹(%d+)');if n then slots=tonumber(n) end
                end
                if raidIndex+1>running and raidIndex+1<=running+slots then return o end
                running=running+slots
            end
            return spots[1]
        end
        local function stage3(all,p)
            if p.x<141 or p.y<150 then log('前往耶律焱');move(196,155);return end
            if clear(all,'火阵守卫') then return end
            if p.y<155 then move(196,155);return end
            local boss=best(all,'耶律焱',function(o) return o.hp>0 end);watchBoss(boss)
            if not started(boss) and not seen[3] and not raidReady(3,193,180,45) then T.stop();return end
            if cfg.xzk234 and not (boss and boss.hp==0) then
                log('耶律焱 · 安全点等待');T.stop();move(158,179);progress();return
            end
            if d2(p,193,193)>100 and not seen[3] then log('前往耶律焱');move(193,193);return end
            T.disable('棒打狗头 凌神式 移魂大法·魔宗 拖泥带水 行尸走肉')
            local own=api.buffs()
            local spot=waterSpot(all)
            if spot then
                log('耶律焱 · 侵略如火站水迹');
                if not (hasBuff(own,'御火术：') and spot.dst<3) then T.stop();move(math.floor(spot.x),math.floor(spot.y));return end
                T.stop();return
            end
            local danger=T.traps();local ox=list(all,'地府牛妖',enemy)
            -- The reference reads who each 牛妖 charges from its title; the lock buff says this character is the one.
            if hasBuff(own,'目标锁定') then for _,o in ipairs(ox) do danger[#danger+1]=o end end
            if T.within('BSQZ_101223_122',6000) and boss then danger[#danger+1]=boss end
            if T.escape(danger,7,193,193,14,5) then log('耶律焱 · 躲避');T.stop();return end
            local bull=lowestHp(ox,melee and 3 or 15)
            if bull then log('耶律焱 · 打牛妖');attack(bull);return end
            if not enemy(boss) then log('寻找耶律焱');T.stop();move(193,193);return end
            if not firstRun[3] and boss.hp>34 then
                local x,y=station(193,193,7);log('耶律焱 · 走位')
                if move(x,y) then return end;firstRun[3]=true
            end
            local t94,t122=T.seenAt['BSQZ_101223_94'],T.seenAt['BSQZ_101223_122']
            if boss.hp<34 and t94 and t122 and t94>t122 then
                log('耶律焱 · 第三次水后站位')
                if move(192,195) then return end
                if melee and boss.dst>=3 then T.stop();return end
            end
            log('耶律焱 · 战斗');seen[3]=true;attack(boss)
        end

        local talks=0
        local function stage4(all,p)
            if p.x>114 or p.y<170 then
                log('前往陈勇义')
                assert(talks<3,'兵圣奇阵：陈勇义传送 3 次没有到耶律连城区域')
                talks=talks+1;T.stop();T.holdPet()
                api.openNpc({name='陈勇义',x=145,y=177,scene=SCENE});api.sleep(500)
                api.selectOption({'#{BSQZ_101223_49}'},false);api.sleep(1500);CloseAllWindow();progress()
                return
            end
            if p.x>82 then move(82,200);return end
            local boss=best(all,'耶律连城',function(o) return o.hp>0 end);watchBoss(boss)
            if not started(boss) and not seen[4] and not raidReady(4,53,203,35) then T.stop();return end
            local own=api.buffs()
            if hasBuff(own,'石牢：') then log('耶律连城 · 被封石牢');T.stop();progress();return end
            if best(all,'吞天石') then log('耶律连城 · 吞天石集火');if enemy(boss) then seen[4]=true;attack(boss) end;return end
            local pile=list(all,'石堆',enemy)[1]
            if pile then log('耶律连城 · 打石堆');seen[4]=true;attack(pile);return end
            local soul=list(all,'耶律连城·元神',enemy)[1];local bone=list(all,'耶律连城·铁骨',enemy)[1]
            local spirit
            if melee or outer then spirit=soul or bone else spirit=bone or soul end
            if spirit then
                log('耶律连城 · 打铁骨元神');seen[4]=true
                local f=FUZHEN[spirit.name]
                if not melee and spirit.dst>14 and f and move(f[1],f[2]) then return end
                attack(spirit);return
            end
            local rocks=list(all,'滚石')
            local function rollSafe(y) for _,g in ipairs(rocks) do if math.abs(y-g.y)<6 then return false end end return true end
            if #rocks>0 and not rollSafe(p.y) then
                for dy=1,15 do
                    for _,y in ipairs({math.floor(p.y)+dy,math.floor(p.y)-dy}) do
                        if rollSafe(y) and (53-p.x)^2+(203-y)^2<=225 then log('耶律连城 · 躲滚石');T.stop();move(math.floor(p.x),y);return end
                    end
                end
            end
            if hasBuff(own,'失明：') then log('耶律连城 · 失明');T.stop();return end
            if T.escape(T.traps(),7,53,203,15,5) then log('耶律连城 · 躲飞沙走石');T.stop();return end
            if not enemy(boss) then log('寻找耶律连城');T.stop();move(53,203);return end
            if not firstRun[4] then
                local x,y=station(53,203,5);log('耶律连城 · 走位')
                if move(x,y) then return end;firstRun[4]=true
            end
            log('耶律连城 · 战斗');seen[4]=true;attack(boss)
        end
        local run={stage1,stage2,stage3,stage4}
        local function finishBoss()
            T.stop()
            wait('恢复原珍兽',function() return T.restorePet() end,8500)
            T.disable('')
            if cfg.bingsheng_loot~=false and world().scene==SCENE then api.pickup();api.sleep(300) end
            T.clearMove()
        end

        T.readMessages()
        while not done[4] do
            assert(api.now()-start<battleMs,'兵圣奇阵战斗超过时限')
            -- Prompts first: the last boss's prompt and the game sending the raid out can land in the same frame.
            if T.readMessages() then progress() end
            for n,k in ipairs(DONE) do if T.seenAt[k] then for i=1,n do done[i]=true end end end
            if done[4] then break end
            assert(world().scene==SCENE,'兵圣奇阵未完成时离开副本')
            api.alive(minimum,'兵圣奇阵：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            local all,p=T.rows(),world()
            for n,name in ipairs({'萧逸风',false,'耶律焱','耶律连城'}) do
                if name then
                    local b=best(all,name);if b and b.hp==0 and seen[n] then for i=1,n do done[i]=true end end
                end
            end
            if done[4] then break end
            local highest=0;for n=1,4 do if done[n] then highest=n end end
            local lowest
            for _,o in ipairs(all) do
                if o.hp>0 then
                    local n=(o.name=='萧逸风' and 1) or ((o.name=='萧如筠' or o.name=='萧如蔚') and 2)
                        or ((o.name=='耶律焱' or o.name=='地府牛妖') and 3)
                        or ((o.name=='耶律连城' or o.name=='石堆' or o.name=='吞天石') and 4)
                    if n and n>highest and (not lowest or n<lowest) then lowest=n end
                end
            end
            local wanted=math.max(stage,lowest or highest+1)
            if wanted~=stage then
                if stage>0 then finishBoss();log(NAMES[stage]..' 已完成') end
                for i=1,wanted-1 do done[i]=true end
                stage=wanted;T.clearMove();progress()
            end
            run[stage](all,p)
            api.maintain()
            local actual=world()
            if not seen.px or d2(actual,seen.px,seen.py)>0.25 then seen.px,seen.py=actual.x,actual.y;progress() end
            assert(api.now()-lastProgress<180000,'兵圣奇阵阶段没有进展：'..phase)
            api.sleep(250)
        end
        finishBoss()
        -- This dungeon has no exit NPC in the reference: the game sends the raid out after the last boss.
        wait('等待离开副本',function() return world().scene~=SCENE end,300000)
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
            assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'兵圣奇阵活动记录发生变化或次数回退')
            if c.used>before.used then assert(c.used==before.used+1,'兵圣奇阵次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message='兵圣奇阵今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                api.openNpc(entrance)
                local isLeader=api.isLeader()
                if isLeader and #DungeonTactics.raid()==0 then
                    log('创建团队')
                    GetLuaValue("-- bingsheng:create-raid\nPlayer:CreateRaidSelf()",'',0);api.sleep(3000)
                end
                if isLeader or DungeonTactics.raidLeader() then
                    wait('等待团队集合',function()
                        local members=DungeonTactics.raid();local emei,inside=0,0
                        for _,m in ipairs(members) do
                            if m.inside then inside=inside+1 end
                            if m.menpai==4 and not m.dead then emei=emei+1 end
                        end
                        assert(#members<=12,'兵圣奇阵：团队超过 12 人')
                        return #members>=teamCount and inside>=teamCount and emei>=2
                    end,math.max(waitMs,120000))
                    if cfg.xzk260~=false then
                        assert(api.selectOption({option},true),'高阳没有所选模式的选项：'..difficulty)
                    else log('团队已就绪，等待手动进入') end
                end
                wait('确认进入兵圣奇阵',function() return world().scene==SCENE end,cfg.xzk260==false and 600000 or nil)
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='兵圣奇阵完成 '..completed..' 轮；四关结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'兵圣奇阵停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
Bingsheng.entrance=entrance
