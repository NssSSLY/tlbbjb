-- 王陵 full flow for the 凤鸣 and 汴京 entrances, written from the reference rules (原脚本源码/Script64/副本/凤鸣王陵(龙纹).lua,
-- 汴京王陵.lua, 系统/fn王陵.lua). This task owns its stages and receipts; it does not load the vendor framework.
-- Not ported on purpose: the reference kicks a member (or leaves the team) who has already run it today; this flow
-- names them and stops. Trap names are unreadable, see docs/WANGLING_HANDOFF.md.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Wangling={}
local R=assert(CombatRuntime)
local SCENE=600
local CAMPAIGN={page=2,campaign='凤鸣王陵'}
local ZERO_X,ZERO_Y,RADIUS=48,49,18
local ZOUWEI={{48,42},{54,46},{54,53},{48,56},{42,53},{42,46}}
local KEYS={'XWLFB_140218_112','XWLFB_140218_27','XWLFB_140218_59'}
local TALK='#{XWLFB_140218_86}'
local NPCS={['长右']=true,['蛊雕']=true,['毕方']=true,['毕方幻象']=true}
local BIANJING_LINES={[755]=true,[775]=true,[776]=true,[779]=true,[780]=true,[785]=true}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Wangling.run(kind,injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3000),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 6),3,6,'队伍人数')
    for _,k in ipairs({'小号模式','wangling_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','王陵开关无效：'..k) end
    local xiaohao=cfg['小号模式']==true
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'长右','蛊雕','毕方','开明','英招','穷奇'}
    local title=kind=='汴京' and '汴京王陵' or '凤鸣王陵'
    local def={name=title,mission='凤鸣王陵',map='王陵',npc={name='萧陵',x=289,y=67,scene=850},bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log(title..' · '..s) end end
    local function world() return assert(api.world(),'王陵场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('王陵：'..label..'超时',0)
    end
    -- 汴京 has six lines: stay on the current one, otherwise line 1.
    local function entrance()
        if kind=='汴京' then
            local here=world().scene
            return {name='萧陵',x=410,y=380,scene=BIANJING_LINES[here] and here or 755}
        end
        return {name='萧陵',x=289,y=67,scene=850}
    end
    local function dialogText()
        local text=GetLuaValue([[-- wangling:dialog-all
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local all=''
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                if type(t)=='string' then all=all..t..'\n' end
            end
            return all
        ]],'s')
        assert(type(text)=='string','NPC 对话不可读');return text
    end

    local function fight(before)
        local T=DungeonTactics.new(api,SCENE,bossNames)
        local move,attack,enemy,best,list,hasBuff=T.move,T.attack,T.enemy,T.best,T.list,T.hasBuff
        T.watch(KEYS)
        local start,lastProgress=api.now(),api.now()
        local bf,talked,lastHp={},{},{}
        local leader,school=api.isLeader(),api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        if memberIndex>5 then memberIndex=0 end
        local function progress() lastProgress=api.now() end
        -- Near the centre first, then a single talk. No fight within a minute stops rather than talking again.
        local function talkNpc(o)
            if talked[o.name] then
                assert(api.now()-talked[o.name]<math.max(waitMs,60000),'王陵：'..o.name..'开怪后没有进入战斗，不重复对话')
                return
            end
            T.stop();api.openNpc({name=o.name,x=math.floor(o.x),y=math.floor(o.y),scene=SCENE});api.sleep(800)
            api.selectOption({TALK},false);api.sleep(1000);CloseAllWindow()
            talked[o.name]=api.now();progress();log(o.name..' · 已开怪')
        end
        local function onNpc(all,p)
            local near=melee and 5 or 3
            for _,o in ipairs(all) do
                if not enemy(o) and o.hp>0 and NPCS[o.name] then
                    if o.name=='毕方幻象' then
                        -- The prompt names the real one by object ID; attacks later favour the 幻象 nearest it.
                        local line=T.lastLine['XWLFB_140218_112']
                        if line then
                            for _,c in ipairs(all) do
                                if c.name=='毕方幻象' and line:find(';'..c.id..';',1,true) then bf.x,bf.y=c.x,c.y;break end
                            end
                        end
                        return true
                    elseif o.name=='蛊雕' then
                        log('蛊雕 · 开怪')
                        if leader and d2(o,ZERO_X,ZERO_Y)<9 then talkNpc(o) else T.stop();move(math.floor(o.x),math.floor(o.y)) end
                        return true
                    else
                        log(o.name..' · 开怪')
                        if d2(p,ZERO_X,ZERO_Y)>near*near then T.stop();move(ZERO_X,ZERO_Y)
                        elseif leader then talkNpc(o) else T.stop() end
                        return true
                    end
                end
            end
            return false
        end
        local function center(limit,p)
            if d2(p,ZERO_X,ZERO_Y)>limit*limit then T.stop();move(ZERO_X,ZERO_Y);return true end
            return false
        end
        local function onAttack(all,p,hostile,danger)
            local food=list(hostile,'美味的食物')
            if #food>0 then
                local t=food[1]
                for _,o in ipairs(food) do if d2(o,ZERO_X,ZERO_Y)<d2(t,ZERO_X,ZERO_Y) then t=o end end
                local nearCentre=d2(t,ZERO_X,ZERO_Y)<=144
                if nearCentre and not melee and center(5,p) then log('长右 · 回中心');return end
                if melee and d2(t,ZERO_X,ZERO_Y)>=64 then t=food[1] end
                log('长右 · 打美味的食物');attack(t);return
            end
            local fake=list(hostile,'毕方幻象')
            if #fake>0 then
                local t=fake[1]
                for _,o in ipairs(fake) do
                    if bf.x then if d2(o,bf.x,bf.y)<d2(t,bf.x,bf.y) then t=o end
                    elseif o.hp<t.hp then t=o end
                end
                log('毕方 · 打幻象');attack(t);return
            end
            local thunder=list(hostile,'镇魔天雷')[1]
            if thunder then
                local gd=best(all,'蛊雕')
                if gd and (gd.x-thunder.x)^2+(gd.y-thunder.y)^2<=16 then log('蛊雕 · 打镇魔天雷');attack(thunder)
                else
                    log('蛊雕 · 等镇魔天雷靠近');T.stop()
                    if gd then move(math.floor(gd.x),math.floor(gd.y)) end
                end
                return
            end
            for _,name in ipairs({'穷奇·幻','侍魔者','慑魂'}) do
                local list_=list(hostile,name)
                if #list_>0 then
                    local t=list_[1]
                    if not melee then for _,o in ipairs(list_) do if o.hp<t.hp then t=o end end end
                    log('打 '..name);attack(t);return
                end
            end
            if #danger>0 and not xiaohao then
                local range=melee and 2 or 15
                for _,o in ipairs(hostile) do
                    if o.dst<=range then log('有陷阱，只打近处');attack(o);return end
                end
                T.stop();return
            end
            if #danger==0 then
                if not melee and center(10,p) then return end
                if xiaohao and center(8,p) then return end
            end
            log('战斗');attack(hostile[1])
        end

        T.readMessages()
        while true do
            assert(api.now()-start<battleMs,'王陵战斗超过时限')
            assert(world().scene==SCENE,'王陵未完成时离开副本')
            api.alive(minimum,'王陵：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();if T.readMessages() then progress() end
            local all,p=T.rows(),world()
            local hostile={}
            for _,o in ipairs(all) do
                if enemy(o) and o.name~='萧陵' and o.name~='腐烂的食物' then
                    hostile[#hostile+1]=o;talked[o.name]=nil
                    if not lastHp[o.id] or o.hp<lastHp[o.id] then lastHp[o.id]=o.hp;progress() end
                end
            end
            table.sort(hostile,function(a,b) return a.dst<b.dst end)
            local own_=api.buffs()
            local danger=T.traps()
            local moved=false
            if hasBuff(own_,'腐尸草') then log('腐尸草 · 等待');T.stop();moved=true
            elseif T.escape(danger,7,ZERO_X,ZERO_Y,RADIUS,5) then log('躲陷阱');T.stop();moved=true
            elseif T.within('XWLFB_140218_59',6000) then
                local yz=list(all,'英招',enemy)
                if #yz>0 and T.escape(yz,8,ZERO_X,ZERO_Y,RADIUS,5) then log('躲英招');T.stop();moved=true end
            end
            if not moved then
                if #hostile>0 then onAttack(all,p,hostile,danger)
                elseif not onNpc(all,p) then
                    if T.seenAt['XWLFB_140218_27'] then break end
                    log('等待下一波');T.stop();local q=ZOUWEI[memberIndex+1];move(q[1],q[2])
                end
            end
            api.maintain()
            assert(api.now()-lastProgress<180000,'王陵阶段没有进展：'..phase)
            api.sleep(250)
        end
        T.stop()
        wait('恢复原珍兽',function() return T.restorePet() end,8500)
        if cfg.wangling_loot~=false then api.pickup();api.sleep(300) end
        -- Exit through 萧陵. Reference option order; a dialog offering none of them is retried at most three times.
        local tries=0
        wait('离开王陵',function()
            if world().scene~=SCENE then return true end
            if tries<3 then
                tries=tries+1
                api.openNpc({name='萧陵',x=66,y=80,scene=SCENE});api.sleep(500)
                api.selectOption({'#{CSFB_KVK_110623_31}'},true);api.sleep(700)
                api.selectOption({'#{WLFB_220726_02}'},true);api.sleep(700)
                QuestFrameOptionClicked('#{FBCC_201128_07',0);api.sleep(700)
                api.selectOption({'#{FBCC_201128_11}'},true);api.sleep(700)
                CloseAllWindow();api.sleep(3000)
            end
        end,math.max(waitMs,45000))
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
            assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'王陵活动记录发生变化或次数回退')
            if c.used>before.used then assert(c.used==before.used+1,'王陵次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message=title..'今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                local npc=entrance()
                api.openNpc(npc)
                -- Crossing servers can break the team up: the reference waits 70 seconds for it to re-form.
                wait('等待队伍集合',function()
                    return api.teamReady(team) and api.teamTogether() and api.teamNear({scene=world().scene,x=npc.x,y=npc.y},20)
                end,DungeonApi.teamPatience())
                if api.isLeader() then
                    assert(api.selectOption({'#{FMZLW_111219_03}'},true),'萧陵没有入场选项')
                    api.sleep(1000)
                    local text=dialogText()
                    if world().scene~=SCENE and text:find('#{XWLFB_140218_17}',1,true) then
                        -- The reference kicks whoever is listed, or leaves the team itself. That is left to the player.
                        local names={};for name in text:gmatch('([^\n]+)\n#{XWLFB_140218_23}') do names[#names+1]=name end
                        local selfName=GetLuaValue("-- wangling:name\nreturn Player:GetName()",'s')
                        for _,n in ipairs(names) do
                            if n==selfName then return {status=completed>0 and 'done' or 'already_done',message=title..'：本角色今日已完成'} end
                        end
                        error('王陵：队员今日已完成（'..table.concat(names,'、')..'），请调整队伍后重新运行；本程序不自动踢人',0)
                    end
                end
                DungeonApi.enterRetry(api,'确认进入王陵',function() return world().scene==SCENE end,function()
                    CloseAllWindow();api.openNpc(npc)
                    assert(api.selectOption({'#{FMZLW_111219_03}'},true),'萧陵没有入场选项')
                end,{skipFirst=true})
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message=title..'完成 '..completed..' 轮；结束提示、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'王陵停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
