-- 圣兽山野猪: 追捕野猪王 and 野猪暴走, written from the reference rules (原脚本源码/Script64/副本/追捕野猪王(圣兽山).lua,
-- 野猪暴走(圣兽山).lua). This task owns its stages and receipts; it does not load the vendor framework.
-- Reference fields this program cannot read (灵兽 title, green-name owner, player state) are replaced by what can be
-- observed; docs/YEZHU_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Yezhu={}
local R=assert(CombatRuntime)
local SSS=201
local SEARCH_MS=600000
local KINDS={
    hunt={title='追捕野猪王',scene=231,boss='尖牙野猪王',exit={27,107},npc={name='云飘飘',x=136,y=109,scene=SSS}},
    rampage={title='野猪暴走',scene=232,boss='野猪头目',exit={237,234},npc={name='灵兽',x=139,y=131,scene=SSS}},
}
local PATROL={{60,81},{78,94},{94,88},{87,75},{87,64},{92,39},{81,30},{74,41},{58,37},{33,37},{38,50},{45,52},{60,50}}
local BOSS_SPOT={72,50}
local PETS={}
for name in ('成年血牙暴龙 成年钢牙暴龙 成年利牙暴龙 成年尖牙暴龙 血牙暴龙宝宝 钢牙暴龙宝宝 利牙暴龙宝宝 尖牙暴龙宝宝'):gmatch('%S+') do PETS[name]=true end
local SEARCH={{155,222},{211,203},{229,133},{202,141},{68,182},{105,204},{87,174},{141,189},{211,75},{213,34},{175,26},{153,50},{97,58},{96,20},{84,68},{22,160},{93,62},{97,135},{130,141},{156,95},{130,94},{139,131}}
local KEYS={'30/30','ResultText_127'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Yezhu.run(kind,injected)
    local K=assert(KINDS[kind],'野猪任务类型无效')
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 1800),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 1),1,6,'队伍人数')
    for _,k in ipairs({'yezhu_loot','yezhu_catch','yezhu_heal','yezhu_swap_leader','yezhu_leave_map'}) do
        assert(cfg[k]==nil or type(cfg[k])=='boolean','野猪任务开关无效：'..k)
    end
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={K.boss}
    local title=K.title
    local def={name=title,mission=title,map=title,npc=K.npc,bosses=bossNames}
    function def.inside(p) return p.scene==K.scene end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log(title..' · '..s) end end
    local function world() return assert(api.world(),title..'场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error(title..'：'..label..'超时',0)
    end
    local function ui(code) GetLuaValue('-- yezhu:ui\n'..code,'',0) end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function gathered()
        if team<=1 then return true end
        return api.teamReady(team) and api.teamTogether()
    end
    local warned={}
    -- Cast by name on any object through the action button; 捕兽 and 清心普善咒 are not attacks on a hostile.
    local function castOn(name,o)
        local r=GetLuaValue(string.format([[-- yezhu:cast
            local name,server,client=%q,%d,%d
            local a=nil for i=0,255 do local t=EnumAction(i,'skill') if t and t:GetID()~=0 and t:GetName()==name then a=t break end end
            if not a then return -1 end
            DataPool:SelectAsTargetByObjID(server)
            local present=Target:IsPresent()
            if not present or present==0 or Target:GetData('NPCID')~=client then return 0 end
            local e=Packet_Env local b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end
            local old=b:GetActionItem() b:SetActionItem(a:GetID()) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end
            return 1
        ]],name,o.server_id,o.id),'n')
        if r==-1 and not warned[name] then warned[name]=true;api.log(title..'：技能列表没有 '..name..'，跳过这一步') end
        return r==1
    end

    local function fight()
        ui("if Player:IsFollow()==1 or Player:IsFollow()==true then Player:StopFollow() end")
        local T=DungeonTactics.new(api,K.scene,bossNames);T.watch(KEYS);T.readMessages()
        local start,lastProgress,hps=api.now(),api.now(),{}
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local emei=school==4
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        local a=(memberIndex%3)*2*math.pi/3
        local station={math.floor(89+3*math.cos(a)+0.5),math.floor(64+3*math.sin(a)+0.5)}
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(PATROL) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        local toBoss,killedAt,cycleKills,healAt=false,nil,0,-100000
        local function progress() lastProgress=api.now() end
        local function leave()
            T.clearMove()
            wait('前往出口',function() return world().scene~=K.scene or not T.move(K.exit[1],K.exit[2]) end,math.max(waitMs,120000))
            wait('确认离开副本',function()
                if world().scene~=K.scene then return true end
                api.confirmBox();T.clearMove();T.move(K.exit[1],K.exit[2])
            end)
        end
        while true do
            local now=api.now()
            if now-start>=battleMs then
                -- The reference leaves after its limit; an unfinished run does not count as done.
                T.stop();leave();error(title..'：超过战斗时限，已离开副本，本轮不算完成',0)
            end
            assert(world().scene==K.scene,title..'未完成时离开副本')
            api.alive(minimum,title..'：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();if T.readMessages() then progress() end
            if kind=='hunt' and T.seenAt['30/30'] and not toBoss then toBoss=true;T.clearMove();log('前往尖牙野猪王') end
            local all,p=T.rows(),world()
            local corpse=T.best(all,K.boss,function(o) return o.hp==0 end)
            local near
            for _,o in ipairs(all) do
                if T.enemy(o) and not PETS[o.name] then
                    if not hps[o.id] then hps[o.id]=o.hp end
                    if o.hp<hps[o.id] then hps[o.id]=o.hp;progress() end
                    if o.dst<=(kind=='rampage' and not melee and 8 or 15) and (not near or o.dst<near.dst) then near=o end
                end
            end
            -- 野猪暴走 ends with its leader; 追捕 also clears whatever remains around the corpse first.
            if corpse then
                killedAt=killedAt or now
                if kind=='rampage' or (not near and now-killedAt>=3000) then break end
            end
            if emei and kind=='rampage' and cfg.yezhu_heal~=false and now-healAt>=900 then
                for _,o in ipairs(all) do
                    if o.class~='怪物' and o.hp>0 and o.hp<70 and o.dst<=30 then healAt=now;log('清心普善咒 · '..o.name);castOn('清心普善咒',o);break end
                end
            end
            if near then
                if near.name==K.boss then log(K.boss..' · 战斗') else log('清理') end
                cycleKills=cycleKills+1
                T.attack(near)
            elseif corpse then
                T.stop()
            elseif kind=='rampage' then
                log('守点');T.stop();T.move(station[1],station[2])
            elseif toBoss then
                T.stop()
                local boss=T.best(all,K.boss,T.enemy)
                if boss then T.move(math.floor(boss.x),math.floor(boss.y)) else T.move(BOSS_SPOT[1],BOSS_SPOT[2]) end
            else
                log('巡逻刷怪');T.stop()
                local q=PATROL[idx]
                if not T.move(q[1],q[2]) then
                    idx=idx+1;T.clearMove()
                    if idx>#PATROL then
                        idx=1
                        -- A whole empty lap: on a resumed run the 30/30 prompt may already be history.
                        if cycleKills==0 then toBoss=true;log('一圈没有目标，前往尖牙野猪王') end
                        cycleKills=0
                    end
                end
            end
            api.maintain()
            local q=world()
            if not hps.px or d2(q,hps.px,hps.py)>0.25 then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,title..'阶段没有进展：'..phase)
            api.sleep(250)
        end
        T.stop()
        wait('恢复原珍兽',function() return T.restorePet() end,8500)
        if cfg.yezhu_loot~=false then
            api.pickup();api.sleep(300)
            local dead=T.best(T.rows(),K.boss,function(o) return o.hp==0 end)
            if dead then
                T.clearMove()
                wait('前往尸体',function() return not T.move(math.floor(dead.x),math.floor(dead.y)) end,15000)
                api.pickup();api.sleep(300)
            end
        end
        if kind=='hunt' and cfg.yezhu_catch~=false then
            -- One 捕兽 per pet: a failed catch is not retried, so a full pet list cannot loop.
            local tried={}
            for _=1,8 do
                local pet
                for _,o in ipairs(T.rows()) do
                    if PETS[o.name] and o.hp>0 and not tried[o.id] and (not pet or o.dst<pet.dst) then pet=o end
                end
                if not pet then break end
                tried[pet.id]=true;T.clearMove();log('捕捉 '..pet.name)
                wait('走近 '..pet.name,function() return pet.dst<=3 or not T.move(math.floor(pet.x),math.floor(pet.y)) end,30000)
                local seen=T.seenAt['ResultText_127']
                if castOn('捕兽',pet) then
                    local began=api.now()
                    while api.now()-began<20000 do
                        api.maintain();api.sleep(500);T.readMessages()
                        if T.seenAt['ResultText_127']~=seen then break end
                        local still=false
                        for _,o in ipairs(T.rows()) do if o.id==pet.id then still=true;break end end
                        if not still then break end
                    end
                end
            end
        end
        leave()
    end

    -- 追捕野猪王 entry: 云飘飘 for the leader, who needs 野猪王的踪迹. nil continues, a table ends the task.
    local function traceCount()
        local n=GetLuaValue([[-- yezhu:trace
            local c=0
            for i=0,DataPool:GetTaskBag_Num()-1 do local a=PlayerPackage:EnumItem('quest',i)
                if a and a:GetID()~=0 and a:GetName()=='野猪王的踪迹' then c=c+a:GetNum() end end
            return c]],'n')
        assert(type(n)=='number','任务栏物品不可读');return n
    end
    local swapped=false
    local function enterHunt()
        local lead=isLead()
        if lead then
            local n=traceCount()
            if n==0 then api.sleep(3000);n=traceCount() end
            if n==0 and world().scene~=K.scene then
                local count=GetTeamCount()
                if cfg.yezhu_swap_leader==true and count>1 and not swapped then
                    swapped=true;api.log(title..'：队长没有野猪王的踪迹，把队长交给最后一名队员')
                    ui(string.format('Player:AppointLeader(%d)',count-1));api.sleep(1000)
                    lead=false
                else
                    return {status=completed>0 and 'done' or 'already_done',message=title..'队长没有野猪王的踪迹；本次完成 '..completed..' 轮'}
                end
            end
        end
        api.space();api.prepareBattle()
        api.openNpc(K.npc)
        if not lead then return nil,true end
        wait('等待队伍集合',function() return gathered() and (team<=1 or api.teamNear({scene=SSS,x=K.npc.x,y=K.npc.y},20)) end,math.max(waitMs,70000))
        assert(api.selectOption({'追捕野猪王'},true),'云飘飘没有追捕野猪王选项')
        wait('确认进入副本',function() return world().scene==K.scene end)
    end
    -- 野猪暴走 entry. The 灵兽 is known only by its title, which cannot be read; the friendly NPCs met on the
    -- search route are asked in turn, and the one offering 拯救灵兽 is it.
    local function enterRampage()
        api.space();api.prepareBattle()
        if not isLead() then
            if world().scene~=SSS then MoveTo(133,125,SSS) end
            return nil,true
        end
        if world().scene~=SSS then MoveTo(SEARCH[1][1],SEARCH[1][2],SSS) end
        local T=DungeonTactics.new(api,SSS,bossNames)
        ui("if Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end")
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(SEARCH) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        local rejected,start={},api.now()
        while api.now()-start<SEARCH_MS do
            log('寻找灵兽')
            local cand
            for _,o in ipairs(T.rows()) do
                if o.class~='怪物' and o.hp>0 and o.name~='' and not rejected[o.name] and not o.name:find('的',1,true) and (not cand or o.dst<cand.dst) then cand=o end
            end
            if cand then
                rejected[cand.name]=true
                local ok=pcall(api.openNpc,{name=cand.name,x=math.floor(cand.x),y=math.floor(cand.y),scene=SSS})
                local found=false
                if ok then
                    api.sleep(500)
                    local text=GetLuaValue([[-- yezhu:dialog-all
                        local e=Quest_Env
                        if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
                        local all=''
                        for i=0,DataPool:GetNPCEventList_Num()-1 do
                            local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                            if type(t)=='string' then all=all..t..'\n' end
                        end
                        return all]],'s')
                    found=type(text)=='string' and text:find('拯救灵兽',1,true)~=nil
                end
                if found then
                    api.log(title..'：发现灵兽 '..cand.name)
                    wait('等待队伍集合',gathered,math.max(waitMs,70000))
                    assert(api.selectOption({'拯救灵兽'},true),'灵兽的拯救选项已消失')
                    wait('确认进入副本',function() return world().scene==K.scene end)
                    return
                end
                CloseAllWindow();T.clearMove()
            else
                local q=SEARCH[idx]
                if not T.move(q[1],q[2]) then
                    idx=idx+1;T.clearMove()
                    if idx>#SEARCH then idx=1;rejected={} end
                end
            end
            api.maintain();api.sleep(250)
        end
        if completed>0 then return {status='done',message=title..'已 10 分钟没有找到灵兽；本次完成 '..completed..' 轮'} end
        error(title..'：10 分钟没有找到灵兽',0)
    end

    local function body()
        api.validate(def,cfg)
        local result
        while completed<rounds do
            if world().scene~=K.scene then
                local ended,follow
                if kind=='hunt' then ended,follow=enterHunt() else ended,follow=enterRampage() end
                if ended then result=ended;break end
                if follow then
                    CloseAllWindow();log('等待队长进入副本')
                    local start=api.now()
                    while world().scene~=K.scene and api.now()-start<SEARCH_MS do api.maintain();api.sleep(500) end
                    if world().scene~=K.scene then
                        if completed>0 then result={status='done',message=title..'已 10 分钟没有进入副本；本次完成 '..completed..' 轮'};break end
                        error(title..'：10 分钟没有进入副本',0)
                    end
                end
            end
            fight();completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        result=result or {status='done',message=title..'完成 '..completed..' 轮；首领尸体和离场均已确认'}
        if cfg.yezhu_leave_map~=false and world().scene==SSS then
            -- The reference walks out of 圣兽山 at the end. Failing here does not undo a finished run.
            local ok,why=pcall(MoveTo,282,64,112)
            if not ok then api.log(title..'：离开圣兽山失败：'..tostring(why)) end
        end
        return result
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,title..'停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
