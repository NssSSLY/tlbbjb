-- 天降奇兽(刷丹), written from the reference rules (原脚本源码/Script64/副本/天降奇兽(刷丹).lua). During its four daily windows the leader
-- searches 楼兰 for the beast, the team enters and kills 护岛神兽 and 无敌飞天猫, then walks out.
-- The reference's timed 抢点 mode and direct packet are not ported. This task owns its stages and receipts; it does not
-- load the vendor framework. docs/TIANJIANG_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Tianjiang={}
local R=assert(CombatRuntime)
local SCENE=268
local TOWN=246
local SCRIPT=808121
local WINDOWS={{13,30,30},{18,30,20},{19,0,30},{21,45,30}}
local ROUTE1={{166,250},{161,221},{153,206},{121,178},{109,151},{88,149},{66,138},{142,134},{143,160},{182,153},{175,81},{140,88},{123,78},{126,41},{159,45}}
local ROUTE2={{289,267},{261,264},{234,228},{243,100},{255,39},{237,47},{77,44},{33,49},{73,81},{99,197},{63,199},{40,217},{103,233}}
local PATROL={{188,123},{178,162},{117,152},{128,104}}
local TARGET={['护岛神兽']=true,['无敌飞天猫']=true}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Tianjiang.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local searchMs=int(tonumber(cfg.tianjiang_search_minutes or 30),1,120,'寻找时限')*60000
    assert(cfg.tianjiang_loot==nil or type(cfg.tianjiang_loot)=='boolean','天降奇兽开关无效：tianjiang_loot')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'护岛神兽','无敌飞天猫'}
    local def={name='天降奇兽',mission='天降奇兽',map='楼兰',npc={name='千年奇兽',x=173,y=156,scene=TOWN},bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('天降奇兽 · '..s) end end
    local function world() return assert(api.world(),'天降奇兽场景不可读') end
    local function ui(code) GetLuaValue('-- tianjiang:ui\n'..code,'',0) end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    -- The window now open (1 to 4), or nil.
    local function window()
        local h,m=GetLuaValue("-- tianjiang:time\nlocal t=os.date('*t',DataPool:GetCurrentServerTime()) return t.hour,t.min",'nn')
        assert(type(h)=='number' and type(m)=='number','服务器时间不可读')
        local now=h*60+m
        for i,w in ipairs(WINDOWS) do
            local start=w[1]*60+w[2]
            if now>=start and now<start+w[3] then return i end
        end
    end

    local function fight()
        ui("if Player:IsFollow()==1 or Player:IsFollow()==true then Player:StopFollow() end")
        local T=DungeonTactics.new(api,SCENE,bossNames)
        local start,lastProgress,hps,killed,idx,leavingAt=api.now(),api.now(),{},{},1,nil
        local own=R.host('battle_self_identity');local leaderId
        for i,m in ipairs(api.teamIdentities()) do if i==1 then leaderId=m.id end end
        local function progress() lastProgress=api.now() end
        while true do
            local p=world()
            if p.scene~=SCENE then return end
            api.alive(minimum,'天降奇兽：角色血量低于停止阈值，自动复活未接入，已停止')
            local target
            for _,o in ipairs(T.rows()) do
                if TARGET[o.name] then
                    if o.hp==0 then if not killed[o.name] then killed[o.name]=true;progress() end
                    elseif T.enemy(o) then
                        if not target or o.dst<target.dst then target=o end
                        if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;progress() end
                    end
                end
            end
            if target then
                log(target.name..' · 战斗');T.attack(target)
            elseif (killed['护岛神兽'] and killed['无敌飞天猫']) or api.now()-start>600000 then
                -- 10 minutes is the reference's limit inside. The exit is between these two spots.
                log('离开副本');T.stop()
                leavingAt=leavingAt or api.now()
                assert(api.now()-leavingAt<math.max(waitMs,120000),'天降奇兽：走到出口后仍在副本内')
                if cfg.tianjiang_loot~=false and not killed.looted then killed.looted=true;api.pickup() end
                if world().scene~=SCENE then return end
                if d2(p,70,67)>1 then T.move(70,67) else T.move(76,70) end
            elseif isLead() then
                log('寻找目标');T.stop()
                local q=PATROL[idx]
                if not T.move(q[1],q[2]) then idx=idx%#PATROL+1;T.clearMove() end
            else
                log('跟随队长');T.stop()
                for _,o in ipairs(T.players()) do
                    if o.id==leaderId and d2(p,o.x,o.y)>16 then T.move(math.floor(o.x),math.floor(o.y));break end
                end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,'天降奇兽阶段没有进展：'..phase)
            api.sleep(250)
        end
    end
    -- The beast is known only by its title, which cannot be read. The friendly NPC whose dialog carries script 808121 is it.
    local function entryOption()
        local text=GetLuaValue(string.format([[-- tianjiang:option
            local want=%d
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local kind,unused,script,extra,text=DataPool:GetNPCEventList_Item(i)
                if script==want and type(text)=='string' then return text end
            end
            return '']],SCRIPT),'s')
        return type(text)=='string' and text or ''
    end
    local function search(step)
        local route=step>2 and ROUTE2 or ROUTE1
        if world().scene~=TOWN then MoveTo(route[1][1],route[1][2],TOWN) end
        local T=DungeonTactics.new(api,TOWN,bossNames)
        ui("if Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end")
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(route) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        local rejected,start={},api.now()
        while api.now()-start<searchMs do
            if window()==nil then return false end
            log('寻找千年奇兽')
            local cand
            for _,o in ipairs(T.rows()) do
                if o.class~='怪物' and o.hp>0 and o.name~='' and not rejected[o.name] and not o.name:find('的',1,true) and (not cand or o.dst<cand.dst) then cand=o end
            end
            if cand then
                rejected[cand.name]=true
                if pcall(api.openNpc,{name=cand.name,x=math.floor(cand.x),y=math.floor(cand.y),scene=TOWN}) then
                    api.sleep(500)
                    local option=entryOption()
                    if option~='' then
                        api.log('天降奇兽：发现 '..cand.name)
                        assert(QuestFrameOptionClicked(option,1),'千年奇兽的入场选项已消失')
                        api.sleep(1000);CloseAllWindow()
                        return true
                    end
                end
                CloseAllWindow();T.clearMove()
            else
                local q=route[idx]
                if not T.move(q[1],q[2]) then
                    idx=idx%#route+1;T.clearMove()
                    if idx==1 then rejected={} end
                end
            end
            api.maintain();api.sleep(250)
        end
        return false
    end
    local function body()
        api.validate(def,cfg)
        while completed<rounds do
            if world().scene~=SCENE then
                local step=window()
                if not step then
                    if completed>0 then break end
                    error('天降奇兽：现在不是活动时间（13:30、18:30、19:00、21:45 开始），未做定时抢点',0)
                end
                api.space();api.prepareBattle()
                if isLead() then
                    if not search(step) then
                        if completed>0 then break end
                        error('天降奇兽：活动期间没有找到千年奇兽',0)
                    end
                    log('确认进入副本');local began=api.now()
                    while world().scene~=SCENE do
                        assert(api.now()-began<math.max(waitMs,60000),'天降奇兽：选择后没有进入副本，未重复发送')
                        api.maintain();api.sleep(500)
                    end
                else
                    if world().scene~=TOWN then MoveTo(173,156,TOWN) end
                    log('等待队长进入副本');local began=api.now()
                    while world().scene~=SCENE do
                        if api.now()-began>=searchMs then
                            if completed>0 then return {status='done',message='天降奇兽完成 '..completed..' 轮；之后没有再进入副本'} end
                            error('天降奇兽：没有进入副本',0)
                        end
                        api.maintain();api.sleep(500)
                    end
                end
            end
            fight();completed=completed+1;log('本轮完成（'..completed..'）')
        end
        return {status='done',message='天降奇兽完成 '..completed..' 轮'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'天降奇兽停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
