-- 凤凰陵墓 full flow (普通 and 困难), written from the reference rules (原脚本源码/Script64/副本/凤凰陵墓-普通.lua, 凤凰陵墓-困难.lua; they
-- differ only in the entry option). A 30-room map: the leader walks a fixed route, each room holds a boss or a small game.
-- This task owns its stages and receipts; it does not load the vendor framework. Bag_DeleteItem is not ported.
-- Reference fields this program cannot read (state, facing, trap names, leader's target) are replaced by what can be
-- observed; docs/FENGHUANG_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Fenghuang={}
local R=assert(CombatRuntime)
local SCENE=999
local CAMPAIGN={page=1,campaign='凤凰陵墓'}
local entrance={name='时烈风',x=186,y=113,scene=260}
local ROUTE={25,26,20,19,13,14,8,7,1,2,3,4,10,9,15,16,22,21,27,28}
local KIND={[1]='game',[2]='game',[3]='boss',[4]='boss',[5]='boss',[6]='game',[7]='game',[8]='game',[9]='boss',[10]='boss'}
local BOSS={
    [3]={names={'地陵蛊花','蛊墓花妖'},open='#{FHCL_240708_76}',trap=6},
    [4]={names={'岩铸战将'},open='#{FHCL_240708_318}',trap=5},
    [5]={names={'暗冥乌犍'},open='#{FHCL_240708_321}',trap=6},
    [9]={names={'镇陵战魂','涅槃：镇陵战魂'},open='#{FHCL_240708_331}',trap=6},
    [10]={names={'霜影'},open='#{FHCL_240708_330}'},
}
local SEAL={['金色印记：']='金区域',['绿色印记：']='木区域',['蓝色印记：']='水区域',['红色印记：']='火区域',['紫色印记：']='土区域'}
local KEYS={'FHCL_240708_168'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Fenghuang.run(mode,injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local title=mode==2 and '凤凰陵墓-困难' or '凤凰陵墓-普通'
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.count_fhlm or 0),0,24,'队伍人数')
    for _,k in ipairs({'fhlm_use_items','fhlm_loot','fhlm_claim'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean',title..'开关无效：'..k) end
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'地陵蛊花','蛊墓花妖','岩铸战将','暗冥乌犍','镇陵战魂','涅槃：镇陵战魂','霜影'}
    local def={name=title,mission='凤凰陵墓',map='凤凰陵墓',npc=entrance,bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log(title..' · '..s) end end
    local function world() return assert(api.world(),title..'场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error(title..'：'..label..'超时',0)
    end
    local function ui(code) GetLuaValue('-- fenghuang:ui\n'..code,'',0) end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function gathered()
        if GetTeamCount()==0 then return team<=1 end
        if team>0 and not api.teamReady(team) then return false end
        return api.teamTogether()
    end

    -- The map panel: the rooms' state is only filled in once it has been opened.
    local function refreshMap()
        ui("MiniMap_Env.ToggleSceneMap()");api.sleep(300)
        ui("ZhouchangPVE_SceneFb_Env.ZhouchangPVE_SceneFb_Close()")
    end
    local function here()
        local x,z,a,b,c=GetLuaValue([[-- fenghuang:base
            local inStart,sx,sz,x,z,bx,bz,a,b,c=AskWeekPveMapBaseInfo()
            return x,z,a,b,c]],'nnnnn')
        if type(x)~='number' or type(z)~='number' or x<1 or x>5 or z<1 or z>6 then return nil end
        return math.floor((x-1)*6+z),{a or 0,b or 0,c or 0}
    end
    local function room(index)
        local x,z=math.floor((index-1)/6),(index-1)%6
        local state,event=GetLuaValue(string.format([[-- fenghuang:room
            local ok,param=AskWeekPveMapInfo(%d,%d)
            if ok~=1 then return -1,-1 end
            local e=ZhouchangPVE_SceneFb_Env
            return e.ZhouchangPVE_GetMapRoomState(param),e.ZhouchangPVE_GetMapRoomEventId(param)]],x,z),'nn')
        return tonumber(state) or -1,tonumber(event) or -1
    end
    local function selectRoom(index)
        ui("MiniMap_Env.ToggleSceneMap()");api.sleep(800)
        ui(string.format("ZhouchangPVE_SceneFb_Env.ZhouchangPVE_SceneFb_Room_Clicked(%d)",index));api.sleep(800)
        ui("ZhouchangPVE_SceneFb_Env.ZhouchangPVE_SceneFb_GO()");api.sleep(800)
        ui("MessageBox_Self2_Env.MessageBox_Self2_Ok_Clicked()");api.sleep(800)
        ui("ZhouchangPVE_SceneFb_Env.ZhouchangPVE_SceneFb_Close()")
    end
    local function useItems(items)
        if cfg.fhlm_use_items==false then return end
        for i=1,3 do
            if (items[i] or 0)>0 then
                ui("MiniMap_Env.ToggleSceneMap()");api.sleep(300)
                ui(string.format("ZhouchangPVE_SceneFb_Env.ZhouchangPVE_SceneFb_Skill_Icon_Btn(%d)",i));api.sleep(300)
                ui("MessageBox_Self2_Env.MessageBox_Self2_Ok_Clicked()");api.sleep(1500)
                ui("ZhouchangPVE_SceneFb_Env.ZhouchangPVE_SceneFb_Close()")
            end
        end
    end

    -- Returns true when the game's own record says this run finished.
    local function fight(before)
        local T=DungeonTactics.new(api,SCENE,bossNames);T.watch(KEYS);T.readMessages()
        local move,enemy,best,list,hasBuff=T.move,T.enemy,T.best,T.list,T.hasBuff
        local start,lastProgress=api.now(),api.now()
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        local over,lastRead,cell,state,event,items=false,-100000,nil,-1,-1,{}
        local started,lastTalk,startTalk,opened,seen,resetAt,sent,hps,warned,centre,settled=false,-100000,-100000,{},{},{},{},{},{},{},{}
        local function progress() lastProgress=api.now() end
        local function station(z,r)
            local a=memberIndex*math.pi/3
            return math.floor(z.x+r*math.cos(a)+0.5),math.floor(z.y+r*math.sin(a)+0.5)
        end
        local function own_(text) return hasBuff(api.buffs(),text) end
        local function useOn(define,o)
            local r=GetLuaValue(string.format([[-- fenghuang:interact
                local define,server,client=%d,%d,%d
                local a=nil for i=0,255 do local t=EnumAction(i,'skill') if t and t:GetDefineID()==define then a=t break end end
                if not a then return -1 end
                DataPool:SelectAsTargetByObjID(server)
                local present=Target:IsPresent()
                if not present or present==0 or Target:GetData('NPCID')~=client then return 0 end
                local e=Packet_Env local b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end
                local old=b:GetActionItem() b:SetActionItem(a:GetID()) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end
                return 1
            ]],define,o.server_id,o.id),'n')
            if r==-1 and not warned[define] then warned[define]=true;api.log(title..'：技能列表没有机制技能 '..define) end
            return r==1
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
        -- Leader: team HP up to 30 seconds, then one talk and one option for this room.
        local function openRoom(npc,option,z)
            local key=cell..':'..npc.name
            if isLead() then
                if opened[key] then
                    assert(api.now()-opened[key]<math.max(waitMs,60000),title..'：'..npc.name..'开启后没有反应，不重复对话')
                else
                    T.stop()
                    if npc.dst>3 then move(math.floor(npc.x),math.floor(npc.y));return end
                    local began=api.now();log(npc.name..' · 等待全队血量 85%')
                    while api.now()-began<30000 and not api.teamHealthy(85) do api.maintain();api.sleep(250) end
                    TalkNpc(npc.name);api.sleep(1000)
                    api.selectOption({option},true);api.sleep(1000);api.confirmBox();CloseAllWindow()
                    opened[key]=api.now();progress();log(npc.name..' · 已开启')
                end
            else
                local x,y=station(z,7);T.stop();move(x,y)
            end
        end
        -- With traps around, melee only strikes within 3 and ranged runs to 15.
        local function strike(target,traps)
            if #traps>0 and melee and target.dst>3 then log(target.name..' · 有陷阱，暂不靠近');T.stop();return end
            if not melee and target.dst>15 then T.stop();move(math.floor(target.x),math.floor(target.y));return end
            T.attack(target)
        end
        local function bossRoom(all,p)
            local B=BOSS[event]
            local boss,npc
            for _,name in ipairs(B.names) do
                boss=boss or best(all,name,enemy)
                npc=npc or best(all,name,function(o) return o.hp>0 and not enemy(o) end)
            end
            local key=cell
            if not boss and npc then
                if seen[key] then
                    resetAt[key]=resetAt[key] or api.now()
                    if api.now()-resetAt[key]>3000 then error(title..'：'..npc.name..'恢复为 NPC，本关已重置；自动复活未接入，已停止',0) end
                    T.stop();return
                end
                centre[key]=centre[key] or {x=math.floor(npc.x),y=math.floor(npc.y)}
                log(npc.name..' · 开启');openRoom(npc,B.open,centre[key]);return
            end
            if not boss then log('等待首领');T.stop();return end
            seen[key]=true;resetAt[key]=nil
            centre[key]=centre[key] or {x=math.floor(boss.x),y=math.floor(boss.y)}
            local z=centre[key]
            if not hps[boss.id] or boss.hp<hps[boss.id] then hps[boss.id]=boss.hp;progress() end
            local traps=T.traps()
            if B.trap and T.escape(traps,B.trap,z.x,z.y,15,3) then log(boss.name..' · 躲陷阱');T.stop();return end
            if event==3 then
                local adds={};for _,n in ipairs({'毒种籽','毒花'}) do for _,o in ipairs(list(all,n,enemy)) do adds[#adds+1]=o end end
                if #adds>0 then
                    local t=adds[1]
                    for _,o in ipairs(adds) do if melee then if o.dst<t.dst then t=o end elseif o.hp<t.hp then t=o end end
                    log('地陵蛊花 · 集火毒花');T.attack(t);return
                end
                if own_('毒蛊入体') and T.escape(T.players(),12,z.x,z.y,15,6) then log('地陵蛊花 · 远离队友');T.stop();return end
            elseif event==5 then
                if own_('冥厄：') and T.escape(T.players(),12,z.x,z.y,15,6) then log('暗冥乌犍 · 远离队友');T.stop();return end
            elseif event==9 then
                local orbs=list(all,'暗夜珠',function(o) return o.hp>0 end)
                for _,o in ipairs(list(all,'耀光珠',function(o) return o.hp>0 end)) do orbs[#orbs+1]=o end
                if #orbs>0 then
                    local o=orbs[1]
                    if (o.name=='暗夜珠' and own_('融光甲')) or (o.name=='耀光珠' and own_('镇夜甲')) then
                        log('镇陵战魂 · 靠近'..o.name);T.stop();move(math.floor(o.x),math.floor(o.y));return
                    end
                    if enemy(o) then log('镇陵战魂 · 打'..o.name);T.attack(o);return end
                end
                local spot=list(all,'通用空npc')[1]
                if spot and coneDodge(boss,spot,p,45) then log('镇陵战魂 · 躲扇形');T.stop();return end
                local dance=list(all,'凤舞成双')
                if T.escape(dance,5,z.x,z.y,15,3) then log('镇陵战魂 · 躲凤舞成双');T.stop();return end
                local shade=list(all,own_('镇夜甲') and '辉光凤影' or '暗夜凰影')
                if T.escape(shade,8,z.x,z.y,20,5) then log('镇陵战魂 · 躲凤影');T.stop();return end
            end
            if not settled[key] then
                local x,y=station(z,melee and 3 or 7)
                if move(x,y) then log(boss.name..' · 走位');return end
                settled[key]=true
            end
            log(boss.name..' · 战斗');strike(boss,traps)
        end
        local function gameRoom(all,p)
            -- 火凤石雕 starts every game room.
            local statue=best(all,'火凤石雕',function(o) return o.hp>0 end)
            if statue then
                local z={x=math.floor(statue.x),y=math.floor(statue.y)}
                centre[cell]=z;log('火凤石雕 · 开启');openRoom(statue,'#{FHCL_240708_189}',z);return
            end
            centre[cell]=centre[cell] or {x=math.floor(p.x),y=math.floor(p.y)}
            local z=centre[cell]
            if event==1 then
                -- 险中觅宝: each member takes a coin in team order.
                local coins=list(all,'金币陷阱');table.sort(coins,function(a,b) return a.id<b.id end)
                local c=coins[memberIndex%math.max(#coins,1)+1]
                if c then log('险中觅宝 · 拾金币');T.stop();if move(math.floor(c.x),math.floor(c.y)) then progress() end
                else log('险中觅宝 · 等待');T.stop() end
            elseif event==2 then
                -- 凤凰奇阵: each mark has its own zone.
                local want;for buff,zone in pairs(SEAL) do if own_(buff) then want=zone;break end end
                if want then
                    for _,o in ipairs(all) do
                        if o.name:find(want,1,true) then log('凤凰奇阵 · '..want);T.stop();if move(math.floor(o.x),math.floor(o.y)) then progress() end;return end
                    end
                end
                log('凤凰奇阵 · 等待印记');T.stop();move(z.x,z.y)
            elseif event==6 then
                -- 密匙解匣: a key goes to its statue; without one, hit the puppets for it.
                local key=own_('银月秘钥') and '银月凤雕' or own_('炎日秘钥') and '炎日凤雕' or own_('玄夜秘钥') and '玄夜凤雕'
                if key then
                    local o=best(all,key)
                    if o then
                        log('密匙解匣 · 交给'..key);T.stop()
                        if o.dst>3 then move(math.floor(o.x),math.floor(o.y)) elseif api.now()-lastTalk>=1000 then lastTalk=api.now();useOn(3,o);progress() end
                    else T.stop();move(z.x,z.y) end
                    return
                end
                local mob=best(all,'守陵傀儡',enemy)
                if mob then log('密匙解匣 · 打傀儡');T.attack(mob);if mob.hp<(hps[mob.id] or 101) then hps[mob.id]=mob.hp;progress() end
                else log('密匙解匣 · 等待');T.stop() end
            elseif event==7 then
                -- 三元归鼎: each cauldron is fed by killing the other two elements.
                local wants={['真火鼎']={'风元灵','水元灵'},['穹风鼎']={'火元灵','水元灵'},['丹水鼎']={'火元灵','风元灵'}}
                for name,mobs in pairs(wants) do
                    if best(all,name) then
                        for _,m in ipairs(mobs) do
                            local o=best(all,m,enemy)
                            if o then
                                log('三元归鼎 · 打'..m)
                                if o.dst>14 then T.stop();move(math.floor(o.x),math.floor(o.y)) else T.attack(o) end
                                if o.hp<(hps[o.id] or 101) then hps[o.id]=o.hp;progress() end
                                return
                            end
                        end
                    end
                end
                log('三元归鼎 · 等待');T.stop()
            elseif event==8 then
                -- 大破火凤阵: dodge the 火凤, and everyone hits the same puppet (lowest id), since a leader's target cannot be read.
                if T.escape(list(all,'火凤'),3,z.x,z.y,60,2) then log('大破火凤阵 · 躲火凤');T.stop();return end
                local mobs=list(all,'守陵傀儡',enemy);table.sort(mobs,function(a,b) return a.id<b.id end)
                local t=mobs[1]
                if t then
                    log('大破火凤阵 · 打傀儡')
                    if t.dst>3 then T.stop();move(math.floor(t.x),math.floor(t.y)) else T.attack(t) end
                    if t.hp<(hps[t.id] or 101) then hps[t.id]=t.hp;progress() end
                else log('大破火凤阵 · 等待');T.stop() end
            end
        end
        -- Leader on a cleared room: use map items, then the next room on the route, or any unexplored neighbour.
        local function advance()
            if not isLead() then log('等待队长选择下一间');T.stop();return end
            local nextRoom
            for i,c in ipairs(ROUTE) do if c==cell then nextRoom=ROUTE[i+1];break end end
            if not nextRoom then
                for _,c in ipairs({cell-1,cell-6,cell+1,cell+6}) do
                    if c>=1 and c<=30 and room(c)==1 then nextRoom=c;break end
                end
            end
            if not nextRoom then log('没有可去的墓室');T.stop();return end
            if sent[nextRoom] then
                assert(api.now()-sent[nextRoom]<math.max(waitMs,60000),title..'：选择第 '..nextRoom..' 间后没有反馈，不重复发送')
                return
            end
            T.stop();useItems(items)
            log('前往第 '..nextRoom..' 间');selectRoom(nextRoom);sent[nextRoom]=api.now();progress()
        end

        local lastState
        while not over do
            if T.readMessages() then progress() end
            if T.seenAt['FHCL_240708_168'] then over=true;break end
            local p=world()
            assert(p.scene==SCENE,title..'未完成时离开副本')
            assert(api.now()-start<battleMs,title..'战斗超过时限')
            api.alive(minimum,title..'：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            local all=T.rows()
            if best(all,'涅槃：镇陵战魂',function(o) return o.hp==0 end) then over=true;break end
            local leader_=best(all,'杨建月',function(o) return o.hp>0 and math.floor(o.x)==54 and math.floor(o.y)==131 end)
            local guide=best(all,'时烈风',function(o) return o.hp>0 and math.floor(o.x)==46 and math.floor(o.y)==131 end)
            if leader_ and not started then
                log('杨建月 · 准备探索');T.stop()
                if isLead() then
                    if leader_.dst>3 then move(54,131)
                    else
                        local began=api.now()
                        while api.now()-began<30000 and not api.teamHealthy(85) do api.maintain();api.sleep(250) end
                        TalkNpc('杨建月');api.sleep(1000)
                        api.selectOption({'#{FHCL_240708_162}'},true);api.sleep(800);api.confirmBox();api.sleep(800);CloseAllWindow()
                        selectRoom(26);started=true;sent[26]=api.now();progress()
                    end
                end
            elseif guide and not leader_ and not started and api.now()-startTalk>=10000 then
                startTalk=api.now();T.stop();log('时烈风 · 对话')
                TalkNpc('时烈风');api.sleep(800);api.selectOption({'#{FHCL_240708_24}'},true);api.sleep(800);CloseAllWindow()
            else
                if api.now()-lastRead>=3000 then
                    lastRead=api.now();refreshMap()
                    local c,it=here()
                    if c then
                        items=it
                        local s,e=room(c)
                        if c~=cell or s~=state then
                            if state==2 and s==3 and cfg.fhlm_loot~=false then T.stop();T.restorePet();api.pickup();api.sleep(300) end
                            T.clearMove();progress()
                        end
                        cell,state,event=c,s,e
                        if s==2 then started=true end
                    end
                end
                if state==2 then
                    if KIND[event]=='boss' then bossRoom(all,p)
                    elseif KIND[event]=='game' then gameRoom(all,p)
                    else log('未知墓室事件 '..tostring(event));T.stop() end
                elseif state==3 and cell then advance()
                else log('等待墓室');T.stop() end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,title..'阶段没有进展：'..phase)
            api.sleep(250)
        end
        T.stop();T.restorePet()
        if cfg.fhlm_loot~=false then api.pickup();api.sleep(300) end
        -- The reference has no exit step after the last room; it waits. The activity count settles the result.
        local refreshed,began=false,api.now();log('等待活动次数和离场')
        while api.now()-began<300000 do
            local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
            assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,title..'活动记录发生变化或次数回退')
            if c.used>before.used then
                assert(c.used==before.used+1,title..'次数一次增加超过一轮')
                local left=api.now()
                while world().scene==SCENE and api.now()-left<math.max(waitMs,60000) do api.maintain();api.sleep(500) end
                return world().scene~=SCENE
            end
            world();api.maintain();api.sleep(1000)
        end
        error(title..'：通关后活动次数没有增加，不算完成',0)
    end

    local function claim()
        if cfg.fhlm_claim==false or world().scene~=entrance.scene then return end
        if pcall(api.openNpc,entrance) then
            api.sleep(500);api.selectOption({'#{FHCL_240708_295}'},true);api.sleep(800)
            api.selectOption({'#{FHCL_240708_5}'},true);api.sleep(800)
        end
        CloseAllWindow()
    end
    local function body()
        api.validate(def,cfg)
        local inside=false
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            if world().scene~=SCENE then
                if before.used==before.limit then
                    if completed==0 then claim() end
                    return {status=completed>0 and 'done' or 'already_done',message=title..'今日次数已满；本次完成 '..completed..' 轮'}
                end
                api.space();api.prepareBattle()
                api.openNpc(entrance)
                wait('等待队伍集合',gathered,math.max(waitMs,70000))
                api.selectOption({'#{FHCL_240708_295}'},true);api.sleep(1000)
                api.selectOption({mode==2 and '#{FHCL_240708_158}' or '#{FHCL_240708_6}'},true);api.sleep(1000)
                CloseAllWindow()
                wait('确认进入凤凰陵墓',function() return world().scene==SCENE end,math.max(waitMs,60000))
            end
            inside=not fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
            if inside then break end
        end
        if inside then return {status='done',message=title..'完成 '..completed..' 轮；次数已确认，仍在副本内'} end
        claim()
        return {status='done',message=title..'完成 '..completed..' 轮；通关、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,title..'停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
