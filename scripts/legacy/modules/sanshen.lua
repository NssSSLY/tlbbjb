-- 三神幻境 full flow for the 凤鸣 and 汴京 entrances, written from the reference rules (原脚本源码/Script64/副本/三神幻境(凤鸣).lua,
-- 汴京三神幻境.lua, 系统/fn三神幻境.lua). This task owns its stages and receipts; it does not load the vendor framework.
-- Reference fields this program cannot read (boss and 苍凌子 state, object title, trap names) are replaced by what
-- can be observed; docs/SANSHEN_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Sanshen={}
local R=assert(CombatRuntime)
local SCENE=662
local CAMPAIGN={page=2,campaign='三神幻境'}
local BOSSES={
    {x=54,y=113,runY=113,seal='被封印的裂海玄蜥',names={'裂海玄蜥','裂海魔龙'},final='裂海魔龙',guard=true},
    {x=126,y=65,runY=65,seal='被封印的炼狱凤凰',names={'炼狱凤凰','灭世火凤'},final='灭世火凤',guard=true},
    {x=132,y=152,runY=144,seal='被封印的摄灵蛊花',names={'摄灵蛊花','噬魂花妖'},final='噬魂花妖'},
}
local STAGE={}
for n,b in ipairs(BOSSES) do STAGE[b.seal]=n;for _,name in ipairs(b.names) do STAGE[name]=n end end
STAGE['毒花']=3;STAGE['毒种籽']=3
local PROMPTS={'已杀死裂海魔龙： 1/1','已杀死灭世火凤： 1/1','已杀死噬魂花妖：1/1'}
local KEYS={PROMPTS[1],PROMPTS[2],PROMPTS[3],'MZFB_150810_67','MZFB_150810_69'}
local BIANJING_LINES={[755]=true,[775]=true,[776]=true,[779]=true,[780]=true,[785]=true}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Sanshen.run(kind,injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3000),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 6),3,6,'队伍人数')
    for _,k in ipairs({'小号模式','xzk87','xzk157','sanshen_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','三神幻境开关无效：'..k) end
    local xiaohao=cfg['小号模式']==true
    -- Paid chest rewards need both their own setting and the risk switch; otherwise the free reward is taken.
    local useKey=cfg.xzk87==true and cfg.allow_item==true
    local useGold=cfg.xzk157==true and cfg.allow_spend==true
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'裂海玄蜥','裂海魔龙','炼狱凤凰','灭世火凤','摄灵蛊花','噬魂花妖'}
    local title=kind=='汴京' and '汴京三神幻境' or '三神幻境'
    local def={name=title,mission='三神幻境',map='三神幻境',npc={name='碧落',x=289,y=81,scene=850},bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log(title..' · '..s) end end
    local function world() return assert(api.world(),'三神幻境场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('三神幻境：'..label..'超时',0)
    end
    local function entrance()
        if kind=='汴京' then
            local here=world().scene
            return {name='碧落',x=620,y=380,scene=BIANJING_LINES[here] and here or 755}
        end
        return {name='碧落',x=289,y=81,scene=850}
    end

    local function fight(before)
        local T=DungeonTactics.new(api,SCENE,bossNames)
        local move,attack,enemy,best,list,hasBuff=T.move,T.attack,T.enemy,T.best,T.list,T.hasBuff
        T.watch(KEYS)
        local start,lastProgress=api.now(),api.now()
        local stage,done,seen,resetAt,hps,opened,arrived=0,{},{},{},{},{},{}
        local leader,school=api.isLeader(),api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        if memberIndex>5 then memberIndex=0 end
        local ownName=GetLuaValue("-- sanshen:name\nreturn Player:GetName()",'s')
        assert(type(ownName)=='string' and ownName~='','角色名称不可读')
        local function progress() lastProgress=api.now() end
        local function station(b,r)
            local a=memberIndex*math.pi/3
            return math.floor(b.x+r*math.cos(a)+0.5),math.floor(b.y+r*math.sin(a)+0.5)
        end
        local function firstEnemy(all,names)
            local found
            for _,name in ipairs(names) do
                local o=best(all,name,enemy)
                if o and (not found or o.dst<found.dst) then found=o end
            end
            return found
        end
        -- Fight with traps around: melee only when already beside the target, ranged within 15.
        local function strike(target,danger)
            if #danger>0 then
                local reach=melee and 3 or 15
                if target.dst>reach then log('有陷阱，目标太远，暂不输出');T.stop();return end
            end
            attack(target)
        end
        local function fight1(all,p)
            local b=BOSSES[1];local danger=T.traps()
            if T.escape(danger,6,b.x,b.y,15,4) then log('裂海玄蜥 · 躲陷阱');T.stop();return true end
            local boss=firstEnemy(all,b.names)
            if boss then log(boss.name..' · 战斗');strike(boss,danger);return true end
        end
        local function fight2(all,p)
            local b=BOSSES[2];local danger=T.traps()
            if T.escape(danger,6,b.x,b.y,15,4) then log('炼狱凤凰 · 躲陷阱');T.stop();return true end
            -- 火苗 carry their owner's name: stay 6 from the others; one's own burns those near it, so stay away from everyone.
            local flames,mine={},false
            for _,o in ipairs(all) do
                if o.name:find('的离火',1,true) or o.name:find('的焱火',1,true) then
                    flames[#flames+1]=o
                    if o.name==ownName..'的离火' or o.name==ownName..'的焱火' then mine=true end
                end
            end
            if #flames>0 then
                if mine and T.escape(T.players(),6,b.x,b.y,15,4) then log('炼狱凤凰 · 带火苗离开队友');T.stop();return true end
                if not mine and T.escape(flames,6,b.x,b.y,15,4) then log('炼狱凤凰 · 躲火苗');T.stop();return true end
            end
            if not melee or xiaohao then
                local x,y=station(b,6)
                if not opened['s2'] then if move(x,y) then return true end;opened['s2']=true end
            end
            local boss=firstEnemy(all,b.names)
            if boss then log(boss.name..' · 战斗');attack(boss);return true end
        end
        local function fight3(all,p)
            local b=BOSSES[3];local own_=api.buffs()
            local burning=T.within('MZFB_150810_67',6000) or hasBuff(own_,'每秒对周围玩家造成伤害')
            local poisoned=T.within('MZFB_150810_69',6000) or hasBuff(own_,'毒蛊入体')
            local x,y=station(b,burning and 8 or 6)
            if (not melee or xiaohao) and move(x,y) then log('摄灵蛊花 · 走位');return true end
            local unsafe=false
            if melee and (burning or poisoned) then
                unsafe=true
                if move(x,y) then log('摄灵蛊花 · 散开');T.stop();return true end
            elseif melee then
                if T.escape(T.traps(),6,b.x,b.y,15,4) then log('摄灵蛊花 · 躲陷阱');T.stop();return true end
            end
            local adds={};for _,name in ipairs({'毒种籽','毒花'}) do for _,o in ipairs(list(all,name,enemy)) do adds[#adds+1]=o end end
            local target
            if #adds>0 then
                target=adds[1]
                for _,o in ipairs(adds) do
                    if melee then if o.dst<target.dst then target=o end
                    elseif o.hp<target.hp then target=o end
                end
            else target=firstEnemy(all,b.names) end
            if not target then return false end
            if unsafe and target.dst>=3 then log('摄灵蛊花 · 机制中，目标太远');T.stop();return true end
            log(target.name..' · 战斗');attack(target);return true
        end
        local fights={fight1,fight2,fight3}

        local function runStage(n,all,p)
            local b=BOSSES[n]
            local seal=best(all,b.seal,function(o) return o.hp>0 end)
            if seal then
                -- Sealed again after this run fought it: the team wiped. No revive here, so stop by name.
                if seen[n] then
                    resetAt[n]=resetAt[n] or api.now()
                    if api.now()-resetAt[n]>3000 then error('三神幻境：'..b.seal..'重新封印，本关已重置；自动复活未接入，已停止',0) end
                    T.stop();return
                end
                log(b.seal..' · 开怪')
                if not leader then local x,y=station(b,6);T.stop();move(x,y);return end
                if opened[n] then
                    assert(api.now()-opened[n]<math.max(waitMs,60000),'三神幻境：'..b.seal..'开启后没有解开封印，不重复对话')
                    return
                end
                local guard=best(all,'苍凌子',function(o) return o.hp>0 end)
                if not guard then T.stop();move(b.x,b.runY);return end
                T.stop()
                local started=api.now();log(b.seal..' · 等待全队血量 85%')
                while api.now()-started<45000 and not api.teamHealthy(85) do api.maintain();api.sleep(250) end
                api.openNpc({name='苍凌子',x=math.floor(guard.x),y=math.floor(guard.y),scene=SCENE});api.sleep(1000)
                api.selectOption({'#{MZFB_150810_45}'},false);api.sleep(1000);CloseAllWindow()
                opened[n]=api.now();progress();log(b.seal..' · 已开启')
                return
            end
            resetAt[n]=nil
            local alive
            for _,name in ipairs(b.names) do
                local o=best(all,name,enemy);if o then alive=o end
                if o and (not hps[o.name] or o.hp<hps[o.name]) then hps[o.name]=o.hp;progress() end
            end
            if alive or best(all,'毒花',enemy) or best(all,'毒种籽',enemy) then seen[n]=true;opened[n]=nil end
            if fights[n](all,p) then return end
            log('前往第 '..n..' 个 Boss')
            if move(b.x,b.runY) then return end
            -- Nothing here and no 苍凌子 at the spot: the reference treats the boss as already done.
            if b.guard and not seen[n] and not best(all,'苍凌子') then
                arrived[n]=arrived[n] or api.now()
                if api.now()-arrived[n]>=3000 then done[n]=true;progress();log('第 '..n..' 个 Boss 未发现，按已过处理') end
            end
        end
        local function finishBoss()
            T.stop()
            wait('恢复原珍兽',function() return T.restorePet() end,8500)
            if cfg.sanshen_loot~=false then api.pickup();api.sleep(300) end
            T.clearMove()
        end

        T.readMessages()
        while not done[3] do
            assert(api.now()-start<battleMs,'三神幻境战斗超过时限')
            assert(world().scene==SCENE,'三神幻境未完成时离开副本')
            api.alive(minimum,'三神幻境：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();if T.readMessages() then progress() end
            local all,p=T.rows(),world()
            for n,k in ipairs(PROMPTS) do if T.seenAt[k] then for i=1,n do done[i]=true end end end
            for n,b in ipairs(BOSSES) do
                local o=best(all,b.final);if o and o.hp==0 then for i=1,n do done[i]=true end end
            end
            for _,o in ipairs(all) do if o.name:find('三神宝箱',1,true) then for i=1,3 do done[i]=true end end end
            if done[3] then break end
            local highest=0;for n=1,3 do if done[n] then highest=n end end
            local lowest
            for _,o in ipairs(all) do
                local n=STAGE[o.name]
                if n and o.hp>0 and n>highest and (not lowest or n<lowest) then lowest=n end
            end
            local wanted=math.max(stage,lowest or highest+1)
            if stage==0 and not lowest then
                for n=3,2,-1 do if d2(p,BOSSES[n].x,BOSSES[n].y)<900 then wanted=n;break end end
            end
            if wanted~=stage then
                if stage>0 then finishBoss() end
                for i=1,wanted-1 do done[i]=true end
                stage=wanted;T.clearMove();progress();opened['s2']=nil
            end
            runStage(stage,all,p)
            api.maintain()
            local actual=world()
            if not seen.px or d2(actual,seen.px,seen.py)>0.25 then seen.px,seen.py=actual.x,actual.y;progress() end
            assert(api.now()-lastProgress<180000,'三神幻境阶段没有进展：'..phase)
            api.sleep(250)
        end
        finishBoss()
        -- Chest: free reward unless a paid one is switched on. A chest problem does not undo the finished fight.
        wait('前往三神宝箱',function() return not move(132,152) end,math.max(waitMs,45000))
        for _=1,5 do
            local box
            for _,o in ipairs(T.rows()) do if o.name:find('三神宝箱',1,true) then box=o;break end end
            if not box then log('未发现三神宝箱');break end
            log('开启宝箱')
            api.openNpc({name=box.name,x=math.floor(box.x),y=math.floor(box.y),scene=SCENE});api.sleep(1000)
            api.selectOption({'#{SSHJ_150915_92}'},true);api.sleep(1000)
            local clicked=false
            if useKey then
                local count=GetLuaValue([[-- sanshen:key-count
                    local n=DataPool:GetBaseBag_Num() local c=0
                    for i=0,n-1 do local a=PlayerPackage:EnumItem('base',i)
                        if a and a:GetID()~=0 and a:GetName()=='天星灵符' then c=c+a:GetNum() end end
                    return c]],'n')
                if type(count)=='number' and count>0 and api.selectOption({'#{SSHJ_201030_3}'},true) then clicked=true end
            end
            if useGold and not clicked then
                local gold=GetLuaValue("-- sanshen:gold\nreturn Player:GetData('YUANBAO')",'n')
                if type(gold)=='number' and gold>=240 and QuestFrameOptionClicked('SSHJ_150915_66',0) then api.sleep(500);api.confirmBox();clicked=true end
            end
            if not clicked then api.selectOption({'#{SSHJ_150915_65}'},true) end
            api.sleep(1000)
            GetLuaValue([[-- sanshen:confirm2
                local e=MessageBox_Self2_Env
                if type(e)=='table' and e.this and e.this:IsVisible() then
                    local f=e.MessageBox_Self2_OK_Clicked or MessageBox_Self2_OK_Clicked
                    if type(f)=='function' then f() end
                end
            ]],'',0)
            api.sleep(500)
            local first=api.dialogFirst();CloseAllWindow()
            if first:find('SSHJ_150915_71',1,true) then break end
        end
        if cfg.sanshen_loot~=false then api.pickup();api.sleep(300) end
        local tries=0
        wait('离开三神幻境',function()
            if world().scene~=SCENE then return true end
            if tries<3 then
                tries=tries+1
                api.openNpc({name='苍凌子',x=131,y=140,scene=SCENE});api.sleep(800)
                api.selectOption({'#{MZFB_150810_49}'},true);api.sleep(1000)
                api.selectOption({'#{SSHJ_20220725_02}'},true);api.sleep(1000)
                QuestFrameOptionClicked('#{FBCC_201128_07',0);api.sleep(700)
                api.selectOption({'#{FBCC_201128_11}'},true);api.sleep(700)
                api.confirmBox();CloseAllWindow();api.sleep(1500)
            end
        end,math.max(waitMs,45000))
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
            assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'三神幻境活动记录发生变化或次数回退')
            if c.used>before.used then assert(c.used==before.used+1,'三神幻境次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        if cfg.xzk87==true and not useKey then api.log(title..'：未打开“允许物品处理”，不使用天星灵符') end
        if cfg.xzk157==true and not useGold then api.log(title..'：未打开“允许支付”，不用元宝领双倍') end
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message=title..'今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                local npc=entrance()
                api.openNpc(npc)
                wait('等待队伍集合',function()
                    return api.teamReady(team) and api.teamTogether() and api.teamNear({scene=world().scene,x=npc.x,y=npc.y},20)
                end,math.max(waitMs,70000))
                if api.isLeader() then
                    assert(api.selectOption({'#{FMYZ_180529_2}'},true),'碧落没有入场选项')
                end
                wait('确认进入三神幻境',function() return world().scene==SCENE end)
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message=title..'完成 '..completed..' 轮；三关结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'三神幻境停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
