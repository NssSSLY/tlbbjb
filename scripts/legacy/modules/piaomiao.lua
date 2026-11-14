-- 挑战缥缈峰 full flow, written from the reference rules (原脚本源码/Script64/副本/缥缈峰(大).lua and 系统/fn缥缈峰.lua).
-- This task owns its stages and receipts; it does not load the vendor framework.
-- Reference fields this program cannot read (boss target, boss menpai, trap names) are replaced by what can be
-- observed; docs/PIAOMIAO_HANDOFF.md names each one. Bag_DeleteItem and the 碧玉套 equipment swap are not ported.
LoadScript('shaoshi')
LoadScript('dungeon_pet_guard')
Piaomiao={}
local R=assert(CombatRuntime)
local SCENE=261
local modes={
    ['普通']={option='挑战缥缈峰',suffix='',campaign='楼兰大缥缈',page=2},
    ['初级']={option='#{XKFB_250115_12}',suffix='·闻恶',campaign='楼兰大缥缈·初级',page=4},
    ['中级']={option='#{XKFB_250115_51}',suffix='·识恶',campaign='楼兰大缥缈·中级',page=4},
    ['高级']={option='#{XKFB_250115_13}',suffix='·罚恶',campaign='楼兰大缥缈·高级',page=4},
}
local BOSSES={'哈大霸','碧磷僵尸','桑土公','乌老大','不平道人','卓不凡','任平生','李秋水'}
local entrance={name='程青霜',x=192,y=222,scene=246}
local NAMES={'哈大霸','桑土公','乌老大','任平生','李秋水'}
-- 桑土公 moves along these points; the last one is where the reference waits longest.
local STG={{40,105},{41,86},{37,60},{56,69},{72,66}}
local FIND_LQS={{125,40},{116,48},{125,56},{133,48}}
-- 李秋水 大群: each prompt pair names the safe spot.
local DAQUN={{113,28,'PMF_20080530_10','PMFTS_80917_5'},{136,67,'PMF_20080530_11','PMFTS_80917_3'},{102,48,'PMF_20080530_12','PMFTS_80917_6'},
    {114,67,'PMF_20080530_13','PMFTS_80917_1'},{136,28,'PMF_20080530_14','PMFTS_80917_2'},{147,48,'PMF_20080530_15','PMFTS_80917_4'}}
local KEYS={'PMF_20080521_13','你获得经验'}
for _,d in ipairs(DAQUN) do KEYS[#KEYS+1]=d[3];KEYS[#KEYS+1]=d[4] end
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end
local function enemy(o) return o~=nil and o.class=='怪物' and o.hp>0 end
-- Where the 李秋水 arena is walkable, from PMF_GoBit_Border_LiQiuShui.
local function inArena(x,y)
    if not (x>92 and x<157 and y>28 and y<69) or (x<103 and y<35) or (x<111 and y<31) or (x>137 and y<31) or (x>148 and y<34) or (x>119 and x<130 and y>42 and y<53) then return false end
    return true
end

function Piaomiao.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3000),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 6),3,6,'队伍人数')
    local mode=assert(modes[cfg.dpmf_type or '普通'],'缥缈峰难度无效')
    for _,k in ipairs({'xzk158','xzk226','piaomiao_xiaohao','piaomiao_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','缥缈峰开关无效：'..k) end
    local msqs,ddq,xiaohao=cfg.xzk158==true,cfg.xzk226==true,cfg.piaomiao_xiaohao==true
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='缥缈峰',mission='挑战缥缈峰',map='缥缈峰',npc=entrance,bosses={}}
    function def.inside(p) return p.scene==SCENE end
    for _,n in ipairs(BOSSES) do def.bosses[#def.bosses+1]=n;if mode.suffix~='' then def.bosses[#def.bosses+1]=n..mode.suffix end end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('缥缈峰 · '..s) end end
    local function world() return assert(api.world(),'缥缈峰场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('缥缈峰：'..label..'超时',0)
    end
    local function dict(key)
        local text=tostring(GetDictionaryString(key) or ''):gsub('#c%x%x%x%x%x%x',''):gsub('#%a',''):gsub('^%s+',''):gsub('%s+$','')
        return text
    end
    local function rows()
        local all=api.objects();assert(type(all)=='table' and #all<=512,'缥缈峰对象不可读')
        local result={}
        for _,o in ipairs(all) do
            local name=tostring(rawget(o,'name') or '')
            for _,base in ipairs(BOSSES) do
                for _,variant in pairs(modes) do
                    if variant.suffix~='' and name==base..variant.suffix then
                        assert(variant==mode,'缥缈峰首领后缀与所选难度不符：'..name)
                        name=base
                    end
                end
            end
            result[#result+1]={id=o.id,server_id=o.server_id,x=o.x,y=o.y,hp=o.hp,dst=o.dst,class=o.class,hostile=o.hostile,name=name}
        end
        return result
    end
    local function best(all,name,accept)
        local found
        for _,o in ipairs(all) do
            if o.name==name and (not accept or accept(o)) and (not found or o.dst<found.dst) then found=o end
        end
        return found
    end
    local function sameCampaign(a,b)
        assert(a.name==b.name and a.limit==b.limit and b.used>=a.used,'缥缈峰活动记录发生变化或次数回退')
    end
    local function gather(point)
        wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() and api.teamNear(point,20) end,DungeonApi.teamPatience())
    end
    -- 乌老大 stands at x=117 before his fight; anywhere else, in NPC form, he has been beaten.
    local function wldBeaten(o) return o.class~='怪物' and o.hp>0 and math.floor(o.x)~=117 end

    local function fight(before)
        local ctx=api.beginBattle(def,SCENE).combat;local pet=DungeonPetGuard.new()
        local start,lastProgress=api.now(),api.now()
        local stage,stopped,key,lastMove=0,false,'',-10000
        local done,opened,opens,seen,resetAt,hps={}, {},{},{},{},{}
        local leader,school=api.isLeader(),api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0;local leaderId
        for i,m in ipairs(api.teamIdentities()) do
            if i==1 then leaderId=m.id end
            if m.id==own and m.server_id==ownServer then memberIndex=i-1 end
        end
        local phrases={};for _,k in ipairs(KEYS) do phrases[k]=k:match('^[%w_]+$') and dict(k) or '' end
        local counts,seenAt,firstRead={},{},true
        local function readMessages()
            local lines=api.messages()
            for _,k in ipairs(KEYS) do
                local n,phrase=0,phrases[k]
                for _,line in ipairs(lines) do
                    if line:find(k,1,true) or (phrase~='' and phrase~=k and line:find(phrase,1,true)) then n=n+1 end
                end
                if not firstRead and n>(counts[k] or 0) then seenAt[k]=api.now();lastProgress=api.now() end
                counts[k]=n
            end
            firstRead=false
        end
        local function hasBuff(set,text) for name in pairs(set) do if name:find(text,1,true) then return true end end return false end
        local function stop()
            if not stopped then api.stopAttack();stopped=true end
            if ctx.id>=0 then ctx=R.new(SCENE,{boss_names=def.bosses}) end
        end
        local function move(x,y)
            assert(world().scene==SCENE,'缥缈峰移动时场景已变化')
            if d2(world(),x,y)<=1 then return false end
            local nextKey=x..','..y
            if nextKey~=key or api.now()-lastMove>=4000 then
                api.stop();R.call(R.codes.RunTo,{SCENE},{x,y});key=nextKey;lastMove=api.now()
            end
            return true
        end
        local function go(x,y,label) wait(label,function() return not move(x,y) end,math.max(waitMs,45000)) end
        local function attack(target)
            if not enemy(target) then return false end
            if d2(world(),target.x,target.y)>35^2 then move(target.x,target.y);return true end
            if not DungeonPetGuard.update(pet,false) then stop();return true end
            if not api.maintain() and R.canAttack() then
                stopped=false;R.selectOriginalTarget(ctx,target.id);R.step(ctx)
            end
            return true
        end
        local function teamHp(timeout)
            local started=api.now();log('等待全队血量 80%')
            while api.now()-started<timeout and not api.teamHealthy(80) do api.maintain();api.sleep(250) end
        end
        -- Bosses return to NPC form when the team is wiped. This program does not revive, so that stops by name.
        local function watchBoss(n,boss)
            if enemy(boss) then
                seen[n]=true;resetAt[n]=nil;opened[n]=nil
                if not hps[boss.name] or boss.hp<hps[boss.name] then lastProgress=api.now() end
                hps[boss.name]=boss.hp
            elseif boss and boss.hp>0 and seen[n] then
                resetAt[n]=resetAt[n] or api.now()
                if api.now()-resetAt[n]>3000 then error('缥缈峰：'..boss.name..'恢复为 NPC，本关已重置；自动复活未接入，已停止',0) end
            end
        end
        local arrived={}
        local function back(n,why)
            log(why);stage=n;for i=n,5 do done[i]=nil;seen[i]=nil;opened[i]=nil;arrived[i]=nil end
            key='';lastProgress=api.now()
        end
        -- Leader talks to one NPC. A refusal naming the previous boss sends the flow back to it; no dialog result
        -- after the deadline stops, and the talk is not resent. `onMissing` handles a dialog without the option.
        -- Read-only: whether the open dialog offers an option, without clicking it.
        local function dialogHas(dictKey)
            return GetLuaValue(string.format([[-- piaomiao:dialog-has
                local e=Quest_Env
                if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end
                local raw,text=%q,%q
                for i=0,DataPool:GetNPCEventList_Num()-1 do
                    local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                    if t==raw or (text~='' and t==text) then return 1 end
                end
                return 0
            ]],'#{'..dictKey..'}',dict(dictKey)),'n')==1
        end
        local function openBoss(n,name,x,y,option,onMissing)
            if opened[n] then
                assert(api.now()-opened[n]<math.max(waitMs,60000),'缥缈峰：'..name..'开怪后没有进入战斗，不重复对话')
                return
            end
            opens[n]=(opens[n] or 0)+1
            assert(opens[n]<=8,'缥缈峰：'..name..'开怪超过 8 次')
            stop();teamHp(35000)
            api.openNpc({name=name,x=x,y=y,scene=SCENE});api.sleep(500)
            if api.selectOption({option},true) then
                api.sleep(1000);api.confirmBox();CloseAllWindow()
                opened[n]=api.now();lastProgress=api.now();log(name..' · 已开怪')
            else
                local first=api.dialogFirst();local canLeave=dialogHas('PMFCC_150105_1');CloseAllWindow();lastProgress=api.now()
                if onMissing then onMissing(first,canLeave) else error('缥缈峰：'..name..'没有“'..option..'”选项',0) end
            end
        end
        local function traps()
            local out={};for _,o in ipairs(api.mechanisms()) do if o.kind==2 then out[#out+1]=o end end;return out
        end
        local function leaderPos()
            if not leaderId or leaderId==own then return nil end
            for _,o in ipairs(api.mechanisms()) do if o.kind==1 and o.id==leaderId then return o end end
        end
        -- Leave `danger` to the nearest grid point in the circle with clearance r, or `fallback` when none has r.
        local function escape(danger,r,cx,cy,maxR,fallback,valid)
            local p=world();local inside=false
            for _,o in ipairs(danger) do if d2(p,o.x,o.y)<r*r then inside=true;break end end
            if not inside then return false end
            local function search(clear)
                local point,score
                for y=math.floor(cy-maxR),math.ceil(cy+maxR) do for x=math.floor(cx-maxR),math.ceil(cx+maxR) do
                    if (x-cx)^2+(y-cy)^2<=maxR*maxR and (not valid or valid(x,y)) then
                        local good=true
                        for _,o in ipairs(danger) do if (o.x-x)^2+(o.y-y)^2<clear*clear then good=false;break end end
                        local s=d2(p,x,y)
                        if good and (not score or s<score) then point,score={x,y},s end
                    end
                end end
                return point
            end
            local point=search(r) or (fallback and search(fallback))
            if point then move(point[1],point[2]) else api.stop() end
            return true
        end
        local function station(cx,cy,r)
            local a=memberIndex*math.pi/3
            return math.floor(cx+r*math.cos(a)+0.5),math.floor(cy+r*math.sin(a)+0.5)
        end
        local function markDone(n,how)
            if not done[n] then done[n]=true;lastProgress=api.now();log(NAMES[n]..(how or ' 已完成')) end
        end
        local function finishBoss()
            stop()
            wait('恢复原珍兽',function() return DungeonPetGuard.update(pet,false) end,8500)
            if cfg.piaomiao_loot~=false then api.pickup();api.sleep(300) end
            key=''
        end
        -- An empty spot after a few seconds means the boss is already past, as the reference's PMF_FindBoss decides.
        -- The next boss's dialog and the final count still have to agree.
        local function notThere(n,seconds)
            arrived[n]=arrived[n] or api.now()
            if api.now()-arrived[n]>=seconds*1000 then markDone(n,' 未发现，按已过处理') end
        end

        local function stage1(all,p)
            local boss=best(all,'哈大霸',function(o) return o.hp>0 end)
            watchBoss(1,boss)
            if enemy(boss) then
                local tongs=hasBuff(api.buffs(boss),'悬枢之痛')
                if (tongs and boss.dst<5) or GetHPPercent()<35 and boss.dst<5 or xiaohao and boss.dst<7 then
                    log('哈大霸 · 远离');stop();escape({boss},7,124,91,15,5);return
                end
                if (not melee or xiaohao) and not opened['s1'] then
                    local x,y=station(124,91,7)
                    if move(x,y) then return end;opened['s1']=true
                end
                if xiaohao then stop();return end
                if melee and tongs then log('哈大霸 · 悬枢之痛近战暂不打');stop();return end
                log('哈大霸 · 战斗');attack(boss)
            elseif resetAt[1] then stop() -- Back to NPC form: confirming a wipe, never reopening.
            elseif boss then
                log('哈大霸 · 开怪')
                if leader then openBoss(1,'哈大霸',124,87,'挑战') else move(124,91) end
            else
                log('前往哈大霸')
                if not move(124,87) then notThere(1,5) end
            end
        end

        -- Search state for 桑土公, who reappears at the next point after each fight.
        local search={index=1,at=nil}
        local function stage2(all,p)
            local boss=best(all,'桑土公',function(o) return o.hp>0 end)
            local zombie=best(all,'碧磷僵尸',enemy)
            if enemy(boss) then seen[2]=true;opened[2]=nil;search.at=nil;lastProgress=api.now() end
            if enemy(boss) or zombie then log('桑土公 · 战斗');attack(enemy(boss) and boss or zombie);return end
            if boss then
                log('桑土公 · 开怪')
                if leader then
                    openBoss(2,'桑土公',boss.x,boss.y,'挑战',function(first)
                        if first:find('#{PMF_20080521_09}',1,true) or first:find('#{PMF_20080521_11}',1,true) then back(1,'哈大霸还没杀完，返回')
                        else error('缥缈峰：桑土公没有“挑战”选项',0) end
                    end)
                else move(math.floor(boss.x),math.floor(boss.y)) end
                return
            end
            -- Not visible: the pet rests while searching so it does not pull the 碧磷僵尸.
            DungeonPetGuard.update(pet,true)
            if not leader then
                log('桑土公 · 跟随队长寻找')
                local l=leaderPos()
                if l then move(math.floor(l.x),math.floor(l.y)) else move(STG[1][1],STG[1][2]) end
                return
            end
            log('桑土公 · 寻找')
            local point=STG[search.index]
            if move(point[1],point[2]) then search.at=nil;return end
            search.at=search.at or api.now()
            local waitSeconds=(search.index==#STG or seen[2]) and 30 or 2
            if api.now()-search.at>=waitSeconds*1000 then
                if search.index==#STG then markDone(2,' 所有点位未发现，按已过处理')
                else search.index=search.index+1;search.at=nil end
            end
        end

        local function stage3(all,p)
            local boss=best(all,'乌老大',function(o) return o.hp>0 end)
            if boss and wldBeaten(boss) then markDone(3);return end
            watchBoss(3,boss)
            if enemy(boss) then
                if seenAt['PMF_20080521_13'] or (ddq and seenAt['你获得经验']) then markDone(3);return end
                if ddq or xiaohao then
                    log('乌老大 · 躲毒群');stop()
                    if api.now()-(seen.wldAt or api.now())>420000 then markDone(3,' 躲毒群超时，按已过处理');return end
                    seen.wldAt=seen.wldAt or api.now();move(78,65);return
                end
                if not melee and move(108,54) then return end
                log('乌老大 · 战斗');attack(boss)
            elseif resetAt[3] then stop() -- Back to NPC form at his start: confirming a wipe, never reopening.
            elseif boss then
                log('乌老大 · 开怪')
                if leader then
                    openBoss(3,'乌老大',116,50,'挑战',function(first)
                        if first:find('#{PMF_20080521_09}',1,true) or first:find('#{PMF_20080521_11}',1,true) then back(2,'桑土公还没杀完，返回')
                        else error('缥缈峰：乌老大没有“挑战”选项',0) end
                    end)
                else
                    local l=leaderPos()
                    if l then move(math.floor(l.x),math.floor(l.y)) else move(116,50) end
                end
            else
                log('前往乌老大')
                -- The reference tries his usual spot, then the spot beside it.
                if not arrived.spot then
                    if not move(116,50) then arrived.spot=true end
                elseif not move(108,45) then notThere(3,5) end
            end
        end

        local function stage4(all,p)
            local ren=best(all,'任平生',function(o) return o.hp>0 end)
            local bu=best(all,'不平道人',enemy);local zhuo=best(all,'卓不凡',enemy)
            for _,o in ipairs({bu,zhuo,enemy(ren) and ren or nil}) do
                if o and (not hps[o.name] or o.hp<hps[o.name]) then hps[o.name]=o.hp;lastProgress=api.now() end
            end
            local target=bu or zhuo or (enemy(ren) and ren or nil)
            if target then seen[4]=true;opened[4]=nil;log('不平道人 / 卓不凡 / 任平生 · 战斗');attack(target);return end
            if seen[4] then
                log('等待任平生');stop();move(125,40)
                -- The reference re-checks after 45 seconds; 乌老大's dialog then confirms or sends the flow back here.
                notThere(4,45);return
            end
            log('符敏仪 · 开怪')
            if leader then
                openBoss(4,'符敏仪',158,54,'挑战不平道人和卓不凡',function() markDone(4,' 符敏仪已无挑战选项，按已过处理') end)
            else move(125,35) end
        end

        -- 李秋水 大群: go to the safe spot named by the newest prompt; attacks wait until it passes.
        local dqActive=false
        local function daqun()
            if msqs then return false end
            local point,newest
            for _,d in ipairs(DAQUN) do
                for i=3,4 do
                    local at=seenAt[d[i]]
                    if at and api.now()-at<15000 and (not newest or at>newest) then point,newest=d,at end
                end
            end
            if not point then
                if dqActive then dqActive=false;log('李秋水 · 大群结束');move(125,40) end
                return false
            end
            dqActive=true;log('李秋水 · 躲大群');stop()
            local own_=api.buffs()
            if not hasBuff(own_,'失明：') then
                if api.now()-newest>12000 and hasBuff(own_,'无法使用任何攻击技能') then move(125,40)
                else move(point[1],point[2]) end
            end
            return true
        end
        local findIndex=1
        local function stage5(all,p)
            local boss=best(all,'李秋水',function(o) return o.hp>0 end)
            watchBoss(5,boss)
            if daqun() then return end
            if enemy(boss) then
                if hasBuff(api.buffs(),'无法使用任何攻击技能') then stop();move(125,40);return end
                local danger=traps()
                if not msqs and escape(danger,7,124.5,47.5,15,6,inArena) then log('李秋水 · 躲寒冰');stop();return end
                if melee and #danger>0 and boss.dst>2.5 and not msqs then log('李秋水 · 有陷阱，近战等待');stop();return end
                log('李秋水 · 战斗');attack(boss);return
            end
            if seen[5] then
                -- She blinks away between attacks: look around the four reference points.
                log('李秋水 · 寻找');stop()
                local q=FIND_LQS[findIndex]
                if not move(q[1],q[2]) then findIndex=findIndex%#FIND_LQS+1 end
                return
            end
            log('李秋水 · 开怪')
            if leader then
                openBoss(5,'乌老大',96,41,'决战李秋水？',function(_,canLeave)
                    if canLeave then markDone(5,' 已可离场') else back(4,'李秋水选项未出现，返回任平生') end
                end)
            else move(125,40) end
        end
        local run={stage1,stage2,stage3,stage4,stage5}

        readMessages()
        while not done[5] do
            assert(api.now()-start<battleMs,'缥缈峰战斗超过时限')
            assert(world().scene==SCENE,'缥缈峰未完成时离开副本')
            api.alive(minimum,'缥缈峰：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();readMessages()
            local all,p=rows(),world()
            -- Dead bodies confirm a stage, only after this run saw that boss fighting (or, for 任平生, any body).
            for n,name in ipairs(NAMES) do
                local b=best(all,name)
                if b and b.hp==0 and (seen[n] or n==4) then markDone(n);for i=1,n-1 do done[i]=true end end
            end
            if done[5] then break end
            local highest=0;for n=1,5 do if done[n] then highest=n end end
            -- The lowest boss still alive on the field decides the stage, as the reference's PMF_OnStep does.
            local lowest
            for _,o in ipairs(all) do
                if o.hp>0 then
                    local n=(o.name=='哈大霸' and 1) or ((o.name=='碧磷僵尸' or o.name=='桑土公') and 2)
                        or (o.name=='乌老大' and not wldBeaten(o) and 3)
                        or ((o.name=='不平道人' or o.name=='卓不凡' or o.name=='任平生') and 4) or (o.name=='李秋水' and 5)
                    if n and (not lowest or n<lowest) then lowest=n end
                end
            end
            -- Nothing alive in sight: a missed body must not send the flow back to an earlier boss.
            local wanted=lowest or math.max(stage,highest+1)
            if not lowest and highest==0 and stage==0 then
                if d2(p,40,106)<64 then wanted=2
                elseif p.x>79 and p.x<120 and p.y<77 then wanted=3
                elseif p.x>79 and p.y<77 then wanted=4 end
            end
            if wanted~=stage then
                if wanted>stage and stage>0 then finishBoss() end
                if wanted>stage then for i=1,wanted-1 do done[i]=true end end
                stage=wanted;key='';lastProgress=api.now();opened['s1']=nil
            end
            run[stage](all,p)
            api.maintain()
            local actual=world()
            if not seen.px or d2(actual,seen.px,seen.py)>0.25 then seen.px,seen.py=actual.x,actual.y;lastProgress=api.now() end
            assert(api.now()-lastProgress<180000,'缥缈峰阶段没有进展：'..phase)
            api.sleep(250)
        end
        finishBoss()
        -- Exit through 乌老大. A dialog still offering the 李秋水 fight means she is not finished.
        go(95,39,'前往乌老大')
        local tries=0
        wait('离开缥缈峰',function()
            if world().scene~=SCENE then return true end
            if tries<3 then
                tries=tries+1
                api.openNpc({name='乌老大',x=95,y=39,scene=SCENE});api.sleep(500)
                if api.selectOption({'#{PMFCC_150105_1}'},true) then
                    api.sleep(800);api.selectOption({'确定离开'},true);api.sleep(500);api.confirmBox()
                elseif api.selectOption({'决战李秋水？'},true) then
                    error('缥缈峰：乌老大仍提供决战李秋水，本轮未完成',0)
                end
                CloseAllWindow();api.sleep(4000)
            end
        end,math.max(waitMs,45000))
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(mode,not refreshed);refreshed=true;sameCampaign(before,c)
            if c.used>before.used then assert(c.used==before.used+1,'缥缈峰次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(mode,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message='缥缈峰今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                api.openNpc(entrance);gather(entrance)
                DungeonApi.enterRetry(api,'确认进入缥缈峰',function() return world().scene==SCENE end,function()
                    CloseAllWindow();api.openNpc(entrance)
                    assert(api.selectOption({mode.option},true),'程青霜没有所选难度的选项：'..tostring(cfg.dpmf_type or '普通'))
                end)
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='缥缈峰完成 '..completed..' 轮；五关结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'缥缈峰停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
Piaomiao.entrance=entrance
