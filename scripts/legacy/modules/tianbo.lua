-- 夜探天波府 full flow (raid of 7 to 12), written from the reference rules (原脚本源码/Script64/副本/夜探天波府.lua).
-- This task owns its stages and receipts; it does not load the vendor framework.
-- Reference data this program cannot read (trap names, raid member HP and position, pets' level) is replaced by what
-- can be observed; docs/TIANBO_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Tianbo={}
local R=assert(CombatRuntime)
local SCENE=848
local CAMPAIGN={page=1,campaign='夜探天波府'}
local entrance={name='穆小妹',x=306,y=245,scene=0}
local BOSSES={
    {name='云中鹤',x=229,y=250},
    {name='岳老三',x=250,y=158},
    {name='叶二娘',x=130,y=150,second='傀影'},
    {name='段延庆',x=110,y=41},
    {name='心魔·延庆太子',x=399,y=92},
}
local STAGE={['云中鹤']=1,['岳老三']=2,['叶二娘']=3,['傀影']=3,['段延庆']=4,['心魔·延庆太子']=5}
local PROMPTS={[1]='YTTBF_220524_187',[2]='YTTBF_220524_189',[3]='YTTBF_220524_192',[5]='YTTBF_220524_199'}
local KEYS={'YTTBF_220524_187','YTTBF_220524_189','YTTBF_220524_192','YTTBF_220524_199','YTTBF_220524_79','YTTBF_220524_81','YTTBF_220524_98'}
local SHIFANG={{394,87,1},{404,87,1},{394,97,1},{404,97,1},{389,82,2},{409,82,2},{389,102,2},{409,102,2}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end
-- The reference's compass: 0 is -y, clockwise.
local function angle(x1,y1,x2,y2) return math.deg(math.atan(x2-x1,-(y2-y1)))%360 end
local function anglePos(x,y,a,d) local r=math.rad(a);return x+d*math.sin(r),y-d*math.cos(r) end
local function gap(a,b) local v=math.abs(a-b)%360;if v>180 then v=360-v end;return v end

function Tianbo.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local teamCount=int(tonumber(cfg.dungeon_team_count or 12),7,12,'团队人数')
    for _,k in ipairs({'xzk118','tianbo_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','夜探天波府开关无效：'..k) end
    local option=cfg.xzk118==true and '#{YTTBF_220524_06}' or '#{YTTBF_220524_05}'
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'云中鹤','岳老三','叶二娘','傀影','段延庆','心魔·延庆太子'}
    local def={name='夜探天波府',mission='夜探天波府',map='天波府',npc=entrance,bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('夜探天波府 · '..s) end end
    local function world() return assert(api.world(),'夜探天波府场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('夜探天波府：'..label..'超时',0)
    end

    local function fight(before)
        local T=DungeonTactics.new(api,SCENE,bossNames);T.watch(KEYS);T.readMessages()
        local move,enemy,best,list,hasBuff=T.move,T.enemy,T.best,T.list,T.hasBuff
        local start,lastProgress=api.now(),api.now()
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local isLeader=DungeonTactics.raidLeader()
        local squad,slot=DungeonTactics.raidSelf()
        local raidIndex=(squad*6+slot)%12
        local own,ownServer=R.host('battle_self_identity')
        local stage,done,seen,hps,opened,resetAt,settled=0,{},{},{},{},{},{}
        local lastTalk=-100000
        local function progress() lastProgress=api.now() end
        local function station(b,r)
            local a=raidIndex*math.pi/6
            return math.floor(b.x+r*math.cos(a)+0.5),math.floor(b.y+r*math.sin(a)+0.5)
        end
        -- Named warnings plus the unnamed trap objects: a trap's name cannot be read, so both count as danger.
        local function danger(all,names)
            local out=T.traps()
            for _,name in ipairs(names) do for _,o in ipairs(list(all,name)) do out[#out+1]=o end end
            return out
        end
        local function safeAt(x,y,set,r)
            for _,o in ipairs(set) do if (o.x-x)^2+(o.y-y)^2<r*r then return false end end
            return true
        end
        -- With danger around, melee only strikes within 3 and ranged within 15. Otherwise they walk a safe approach.
        local function strike(target,set)
            if #set>0 then
                local reach=melee and 3 or 15
                if target.dst>reach then
                    local best_,score
                    for i=0,23 do
                        local a=i*math.pi/12
                        local d=melee and 2 or 12
                        local x,y=target.x+d*math.cos(a),target.y+d*math.sin(a)
                        if safeAt(x,y,set,4) then
                            local s=d2(world(),x,y);if not score or s<score then best_,score={math.floor(x+0.5),math.floor(y+0.5)},s end
                        end
                    end
                    T.stop()
                    if best_ then log('绕开危险靠近 '..target.name);move(best_[1],best_[2]) else log('有危险，目标太远，暂不攻击') end
                    return
                end
            end
            T.attack(target)
        end

        -- 云中鹤
        local function tieLine(feathers,boss,b,p)
            if #feathers==0 or not hasBuff(api.buffs(),'连线：') then return false end
            -- Tied members split into three thirds around him, ordered by server id so that every client agrees.
            local tied={{server_id=ownServer}}
            for _,o in ipairs(T.players()) do if o.id~=own and hasBuff(api.buffs(o),'连线：') then tied[#tied+1]=o end end
            table.sort(tied,function(a,c) return a.server_id<c.server_id end)
            local index=1;for i,o in ipairs(tied) do if o.server_id==ownServer then index=i end end
            local third=math.floor(angle(boss.x,boss.y,p.x,p.y)/120)+1
            if index<=3 then third=index end
            local groups={{},{},{}}
            for _,o in ipairs(feathers) do
                o.angle=angle(boss.x,boss.y,o.x,o.y)
                local g=groups[math.floor(o.angle/120)+1];g[#g+1]=o
            end
            local mine=groups[third]
            if #mine==0 then
                for i=1,3 do if #groups[i]>#mine then mine,third=groups[i],i end end
            end
            local point,score
            for dx=-18,18 do for dy=-18,18 do
                local x,y=b.x+dx,b.y+dy
                if dx*dx+dy*dy<=324 and safeAt(x,y,feathers,6) then
                    local a=angle(boss.x,boss.y,x,y)
                    if a>=(third-1)*120 and a<third*120 then
                        local off=999;for _,o in ipairs(mine) do off=math.min(off,gap(a,o.angle)) end
                        local s=math.floor(off/3)*1000+d2(p,x,y)
                        if not score or s<score then point,score={x,y},s end
                    end
                end
            end end
            if not point then return false end
            log('云中鹤 · 连线走位')
            if move(point[1],point[2]) then T.stop();return true end
            return false
        end
        local function fight1(all,p,boss)
            local b=BOSSES[1]
            local shadows=list(all,'白鹤之影（俯冲）')
            local feathers=danger(all,{'鹤之翎羽'})
            if #shadows>0 then
                local both={};for _,o in ipairs(shadows) do both[#both+1]=o end;for _,o in ipairs(feathers) do both[#both+1]=o end
                if T.escape(both,6,b.x,b.y,20,4) then log('云中鹤 · 躲俯冲');T.stop();return end
                log('云中鹤 · 俯冲中停手');T.stop();return
            end
            if tieLine(feathers,boss,b,p) then return end
            if T.escape(feathers,7,b.x,b.y,20,4) then log('云中鹤 · 躲翎羽');T.stop();return end
            log('云中鹤 · 战斗');strike(boss,feathers)
        end
        -- 岳老三
        local function fight2(all,p,boss)
            local b=BOSSES[2]
            local clones=list(all,'岳老三分身');for _,o in ipairs(list(all,'岳老三分身预警')) do clones[#clones+1]=o end
            if #clones>0 then
                if T.escape(clones,10,b.x,b.y,19,7) then log('岳老三 · 躲分身');T.stop();return end
                log('岳老三 · 分身中停手');T.stop();return
            end
            local spot=list(all,'副本通用空npc')[1]
            local set=danger(all,{'横冲直撞预警圈'})
            if spot then
                -- 怒鳄袭沙: eight rays 45 apart. Stand midway between two of them.
                local base=angle(b.x,b.y,spot.x,spot.y)
                local mine=angle(b.x,b.y,p.x,p.y)
                local r=math.max(9,math.sqrt(d2(p,b.x,b.y)))
                local nearest=base+math.floor((mine-base)/45+0.5)*45
                local q,score
                for _,a in ipairs({nearest+22.5,nearest-22.5}) do
                    local x,y=anglePos(b.x,b.y,a,r)
                    local s=d2(p,x,y);if not score or s<score then q,score={math.floor(x+0.5),math.floor(y+0.5)},s end
                end
                if move(q[1],q[2]) then log('岳老三 · 躲怒鳄袭沙');T.stop();return end
                set[#set+1]=spot
            elseif T.escape(set,5,b.x,b.y,15,3) then log('岳老三 · 躲横冲直撞');T.stop();return end
            if #set>0 then log('岳老三 · 机制中输出');strike(boss,set);return end
            if not melee and not T.within('YTTBF_220524_79',8000) then
                local x,y=station(b,7)
                if move(x,y) then log('岳老三 · 走位');return end
            end
            log('岳老三 · 战斗');T.attack(boss)
        end
        -- 叶二娘 and 傀影
        local function fight3(all,p,boss,boss2)
            local b=BOSSES[3]
            local anchor=boss or boss2
            local spots=list(all,'副本通用空npc')
            local invincible=boss and hasBuff(api.buffs(boss),'无敌：免疫所有伤害')
            local red,blue=list(all,'红影回刃',enemy),list(all,'青影回刃',enemy)
            local set=danger(all,{'青影预警','红影预警'})
            local dodged=false
            if boss and boss2 and #spots==4 and T.within('YTTBF_220524_98',10000) then
                -- 破甲摧城: two lines from each of them; stay 30 off every line and 5 from both.
                local lines={}
                for _,o in ipairs(spots) do
                    if d2(o,boss.x,boss.y)>0 and d2(o,boss2.x,boss2.y)>0 then lines[#lines+1]=o end
                end
                local point,score
                for dx=-15,15 do for dy=-15,15 do
                    local x,y=b.x+dx,b.y+dy
                    if dx*dx+dy*dy<=225 and safeAt(x,y,{boss,boss2},5) then
                        local good=true
                        for _,o in ipairs(lines) do
                            if gap(angle(boss.x,boss.y,o.x,o.y),angle(boss.x,boss.y,x,y))<30 or gap(angle(boss2.x,boss2.y,o.x,o.y),angle(boss2.x,boss2.y,x,y))<30 then good=false;break end
                        end
                        if good then local s=d2(p,x,y);if not score or s<score then point,score={x,y},s end end
                    end
                end end
                if point and move(point[1],point[2]) then log('叶二娘 · 躲破甲摧城');T.stop();dodged=true end
            else
                if boss and not invincible then
                    for _,o in ipairs(red) do set[#set+1]=o end
                    for _,o in ipairs(blue) do set[#set+1]=o end
                end
                if T.escape(set,5,b.x,b.y,16,3) then log('叶二娘 · 躲预警');T.stop();dodged=true end
            end
            local redBuff=hasBuff(api.buffs(),'红影：')
            local blades=(redBuff and #blue>0) and blue or (#red>0 and red) or blue
            if #blades>0 then
                if dodged then return end
                local t=blades[1]
                if melee and #set>0 and t.dst>3 then log('叶二娘 · 回刃太远');T.stop();return end
                log('叶二娘 · 打回刃');T.attack(t);return
            end
            if dodged then return end
            if invincible then log('叶二娘 · 无敌中停手');T.stop();return end
            local target
            if boss and boss2 then
                if melee or math.abs(boss.hp-boss2.hp)>15 then target=redBuff and boss2 or boss
                else target=boss.hp>boss2.hp and boss or boss2 end
            else target=anchor end
            log('叶二娘 · 战斗');strike(target,set)
        end
        -- 段延庆
        local function fight4(all,p,boss)
            local b=BOSSES[4]
            local ministers=list(all,'蓝衣大臣',enemy)
            if #ministers>0 then log('段延庆 · 打大臣');T.attack(ministers[1]);return end
            local warn=list(all,'罪缚无间预警')
            if #warn>0 then
                -- Tied members take the far arc at 9 or more, the others the near arc at 5 or more; 20 clear of every warning.
                local tied=hasBuff(api.buffs(),'连线：')
                local lo,hi,minR=20,160,5
                if tied then lo,hi,minR=185,355,9 end
                local mine=angle(b.x,b.y,p.x,p.y)
                local r=minR
                if mine>=lo and mine<=hi then r=math.max(minR,math.sqrt(d2(p,b.x,b.y))) end
                local q,score
                for a=lo,hi do
                    local clear=true
                    for _,o in ipairs(warn) do if gap(a,angle(b.x,b.y,o.x,o.y))<20 then clear=false;break end end
                    if clear then
                        local x,y=anglePos(b.x,b.y,a,r)
                        local s=d2(p,x,y);if not score or s<score then q,score={math.floor(x+0.5),math.floor(y+0.5)},s end
                    end
                end
                if q and move(q[1],q[2]) then log('段延庆 · 躲罪缚无间');T.stop();return end
                log('段延庆 · 罪缚无间中停手');T.stop();return
            end
            local set=T.traps()
            for _,o in ipairs(all) do if o.name:find('苔杖',1,true) then set[#set+1]=o end end
            if T.escape(set,6,b.x,b.y,16,4) then log('段延庆 · 躲陷阱');T.stop();return end
            log('段延庆 · 战斗');strike(boss,set)
        end
        -- 心魔·延庆太子
        local function fight5(all,p,boss)
            local b=BOSSES[5]
            local ministers=list(all,'紫衣大臣',enemy)
            if #ministers>0 then log('心魔 · 打大臣');T.attack(ministers[1]);return end
            local sword,ring={},{}
            for _,o in ipairs(all) do
                if o.name:find('十方尽诛',1,true) then ring[#ring+1]=o
                elseif o.name:find('剑悬日月',1,true) then sword[#sword+1]=o end
            end
            local traps=T.traps()
            -- 十方尽诛 shows many circles at once; a trap's name cannot be read, so four or more count as it.
            if #ring==0 and #traps>=4 then ring=traps elseif #ring>0 then for _,o in ipairs(traps) do sword[#sword+1]=o end else sword=traps end
            if #ring>0 then
                local point,score
                for _,s in ipairs(SHIFANG) do
                    if safeAt(s[1],s[2],ring,5) then
                        local v=s[3]*100000+d2(p,s[1],s[2])
                        if not score or v<score then point,score=s,v end
                    end
                end
                if point and d2(p,point[1],point[2])>=(melee and 9 or 1) and move(point[1],point[2]) then log('心魔 · 躲十方尽诛');T.stop();return end
                log('心魔 · 十方尽诛集火');T.attack(boss);return
            end
            if #sword>0 then
                if T.escape(sword,7,b.x,b.y,16,4) then log('心魔 · 躲剑悬日月');T.stop();return end
                log('心魔 · 战斗');strike(boss,sword);return
            end
            if not melee then
                local x,y=station(b,7)
                if move(x,y) then log('心魔 · 走位');return end
            end
            log('心魔 · 战斗');T.attack(boss)
        end
        local fights={fight1,fight2,fight3,fight4,fight5}

        local function open(n,npc)
            local b=BOSSES[n]
            if not isLeader then local x,y=station(b,7);T.stop();move(x,y);return end
            if opened[n] then
                assert(api.now()-opened[n]<math.max(waitMs,60000),'夜探天波府：'..b.name..'开怪后没有进入战斗，不重复对话')
                return
            end
            T.stop()
            if npc.dst>3 then move(math.floor(npc.x),math.floor(npc.y));return end
            local started=api.now();log(b.name..' · 等待队伍血量 85%')
            while api.now()-started<45000 and not api.teamHealthy(85) do api.maintain();api.sleep(250) end
            TalkNpc(npc.name);api.sleep(800)
            for _,k in ipairs({'#{YTTBF_220524_57}','#{YTTBF_220524_85}','#{YTTBF_220524_84}','#{YTTBF_220524_103}'}) do
                api.selectOption({k},true);api.sleep(800)
            end
            CloseAllWindow();opened[n]=api.now();progress();log(b.name..' · 已开怪')
        end
        local function talk(name,key)
            if api.now()-lastTalk<6000 then return end
            lastTalk=api.now();T.stop();CloseAllWindow();TalkNpc(name);api.sleep(800)
            api.selectOption({key},true);api.sleep(800);CloseAllWindow()
        end
        -- Between bosses: the guide at the rebirth point sends the raid onward; 杨小弟 opens the way to 段延庆.
        local function travel(n,all,p)
            local b=BOSSES[n]
            local guide=best(all,'穆小妹',function(o) return o.hp>0 end)
            if p.y>317 and n>=3 and guide then
                log('穆小妹 · 传送')
                if move(math.floor(guide.x),math.floor(guide.y)) then return end
                talk('穆小妹',n==3 and '#{YTTBF_220524_258}' or '#{YTTBF_220524_259}');return
            end
            if n==4 and p.y>=80 and p.x<=300 then
                log('前往杨小弟')
                if not move(119,99) then talk('杨小弟','#{YTTBF_220524_138}') end
                return
            end
            if n==5 and p.x<=300 then log('等待进入心魔');T.stop();return end
            log('前往 '..b.name);T.stop();move(b.x,b.y)
        end
        local function finishBoss()
            T.stop()
            wait('恢复原珍兽',function() return T.restorePet() end,8500)
            if cfg.tianbo_loot~=false then api.pickup();api.sleep(300) end
            T.clearMove()
        end

        while not done[5] do
            -- Prompts first: the last prompt and being moved can land in the same frame.
            if T.readMessages() then progress() end
            for n,k in pairs(PROMPTS) do if T.seenAt[k] then for i=1,n do done[i]=true end end end
            assert(api.now()-start<battleMs,'夜探天波府战斗超过时限')
            local p=world()
            assert(p.scene==SCENE,'夜探天波府未完成时离开副本')
            api.alive(minimum,'夜探天波府：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            local all=T.rows()
            for n,b in ipairs(BOSSES) do
                local dead=best(all,b.name,function(o) return o.hp==0 end)
                if dead and seen[n] and (not b.second or not best(all,b.second,enemy)) then for i=1,n do done[i]=true end end
                if b.second and seen[n] then
                    local d2_=best(all,b.second,function(o) return o.hp==0 end)
                    if d2_ and not best(all,b.name,enemy) then for i=1,n do done[i]=true end end
                end
            end
            if done[5] then break end
            local highest=0;for n=1,5 do if done[n] then highest=n end end
            local lowest
            for _,o in ipairs(all) do
                local n=STAGE[o.name]
                if n and o.hp>0 and n>highest and (not lowest or n<lowest) then lowest=n end
            end
            local wanted=math.max(stage,lowest or highest+1)
            if wanted~=stage then
                if stage>0 then finishBoss() end
                for i=1,wanted-1 do done[i]=true end
                stage=wanted;progress()
            end
            local b=BOSSES[stage]
            local boss=best(all,b.name,enemy)
            local boss2=b.second and best(all,b.second,enemy)
            local npc=best(all,b.name,function(o) return o.hp>0 and not enemy(o) end) or (b.second and best(all,b.second,function(o) return o.hp>0 and not enemy(o) end))
            if boss or boss2 then
                seen[stage]=true;opened[stage]=nil;resetAt[stage]=nil
                for _,o in ipairs({boss,boss2}) do
                    if o and (not hps[o.id] or o.hp<hps[o.id]) then hps[o.id]=o.hp;progress() end
                end
                if not settled[stage] then
                    local x,y=station(b,melee and 3 or 7)
                    if move(x,y) then log(b.name..' · 走位') else settled[stage]=true end
                end
                if settled[stage] then fights[stage](all,p,boss or boss2,boss2) end
            elseif npc then
                -- Back to NPC form after fighting means a wipe. This program does not revive, so that stops by name.
                if seen[stage] then
                    resetAt[stage]=resetAt[stage] or api.now()
                    if api.now()-resetAt[stage]>3000 then error('夜探天波府：'..b.name..'恢复为 NPC，本关已重置；自动复活未接入，已停止',0) end
                    T.stop()
                else log(b.name..' · 开怪');open(stage,npc) end
            else
                travel(stage,all,p)
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not seen.px or d2(q,seen.px,seen.py)>0.25) then seen.px,seen.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,'夜探天波府阶段没有进展：'..phase)
            api.sleep(250)
        end
        finishBoss()
        local tries=0
        wait('离开天波府',function()
            local p=world()
            if p.scene~=SCENE then return true end
            if tries>=3 then return false end
            if p.y>317 then
                tries=tries+1;talk('穆小妹','#{YTTBF_220524_260}');api.sleep(1500)
            elseif not move(406,99) and api.now()-lastTalk>=6000 then
                tries=tries+1;lastTalk=api.now();T.stop();CloseAllWindow();TalkNpc('杨文广');api.sleep(800)
                api.selectOption({'离开天波府'},true);api.sleep(800)
                api.selectOption({'确认'},true);api.sleep(800);api.confirmBox();CloseAllWindow();api.sleep(1500)
            end
        end,math.max(waitMs,60000))
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
            assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'夜探天波府活动记录发生变化或次数回退')
            if c.used>before.used then assert(c.used==before.used+1,'夜探天波府次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message='夜探天波府今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                api.openNpc(entrance)
                if DungeonTactics.raidLeader() then
                    wait('等待团队集合',function()
                        local members=DungeonTactics.raid();local inside=0
                        for _,m in ipairs(members) do if m.inside then inside=inside+1 end end
                        return #members>=teamCount and inside>=teamCount
                    end,DungeonApi.teamPatience())
                    assert(api.selectOption({option},true),'穆小妹没有所选模式的选项')
                end
                DungeonApi.enterRetry(api,'确认进入天波府',function() return world().scene==SCENE end,function()
                    CloseAllWindow();api.openNpc(entrance)
                    assert(api.selectOption({option},true),'穆小妹没有所选模式的选项')
                end,{skipFirst=true,leader=DungeonTactics.raidLeader()})
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='夜探天波府完成 '..completed..' 轮；五个首领结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'夜探天波府停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
