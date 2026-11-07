-- 贼兵入侵 (刷反贼), written from the reference rules (原脚本源码/Script64/副本/【副本】刷反贼.lua). The leader finds 造反恶贼 in the wild, the team clears 31.
-- The reference's rapid re-clicking on the NPC is not ported. This task owns its stages and receipts; it does not load the vendor framework.
-- docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Fanzei={}
local SCENE=170
local CAMPAIGN={page=1,campaign='贼兵入侵'}
local MAPS={3,8,4,7,6}
local SEARCH={}
SEARCH[3]={{52,50},{66,92},{62,110},{80,131},{83,140},{86,200},{69,199},{63,190},{52,187},{85,143},{117,138},{148,160},{144,190},{137,206},{132,206},{79,243},{62,252},{180,250},{224,249},{231,235},{235,219},{257,190},{259,169},{270,131},{280,117},{277,78},{211,273},{229,273},{249,272},{267,282},{243,253}}
SEARCH[4]={{212,272},{242,267},{255,264},{272,218},{269,203},{267,191},{249,188},{239,184},{232,219},{238,229},{236,237},{222,228},{213,223},{198,241},{190,234},{170,210},{181,202},{192,190},{167,189},{189,174},{202,142},{211,152},{221,139},{240,143},{250,143},{237,120},{224,118},{240,102},{223,102},{178,93},{167,92},{220,87},{181,52},{195,44},{198,48},{238,62},{275,70},{281,116},{195,43},{182,50},{168,52},{162,47},{111,52},{127,72},{126,96},{130,107},{107,99},{110,110},{112,121},{133,129},{137,137},{152,145},{148,147},{162,148},{129,150},{118,139},{111,147},{120,210},{109,229},{93,241},{104,250},{53,220},{40,236},{87,271},{132,265},{174,254}}
SEARCH[6]={{63,172},{69,162},{75,167},{82,191},{64,189},{68,207},{90,210},{50,230},{50,250},{49,266},{70,270},{132,249},{202,230},{248,238},{231,249},{238,224},{180,180},{148,179},{132,196},{99,167},{120,160},{142,154},{158,150},{180,150},{190,140},{175,130},{172,122},{200,90},{198,88},{184,86},{186,79},{185,63},{170,50},{149,50},{129,50},{110,50},{90,50},{70,50},{93,69},{41,75},{47,109},{50,130}}
SEARCH[7]={{46,275},{70,271},{80,248},{66,247},{51,241},{48,197},{47,181},{49,153},{49,133},{56,128},{46,52},{90,47},{147,52},{153,70},{158,81},{173,92},{224,43},{270,60},{270,47},{273,83},{262,104},{231,126},{222,129},{221,148},{213,157},{178,195},{168,229},{97,203},{108,221},{119,236},{132,238},{114,260},{127,261},{133,271},{161,257},{202,244},{258,228},{278,275},{233,268},{219,270},{197,270},{187,272},{133,271},{89,269}}
SEARCH[8]={{279,180},{249,169},{240,168},{229,152},{229,81},{249,65},{266,58},{266,41},{200,89},{169,96},{188,151},{169,157},{158,180},{113,99},{69,91},{52,111},{94,108},{108,116},{108,146},{92,145},{70,140},{112,171},{120,179},{87,173},{73,168}}
local PATROL={{86,91},{96,79},{99,60},{103,51},{109,26},{100,20},{90,20},{80,20},{72,18},{57,20},{49,32},{43,19},{26,24},{37,57},{40,73},{25,89},{22,97},{20,100}}
local KEYS={'已杀死造反恶贼： 30/31','已杀死造反恶贼： 31/31','离开场景'}
local SEARCH_MS=600000
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Fanzei.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 3),1,6,'队伍人数')
    local sel=int(tonumber(cfg.zhk43 or 0),0,5,'寻找地图')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='贼兵入侵',mission='贼兵入侵',map='反贼',npc={name='造反恶贼',x=0,y=0,scene=3},bosses={}}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('贼兵入侵 · '..s) end end
    local function world() return assert(api.world(),'贼兵入侵场景不可读') end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function gathered()
        if team<=1 then return true end
        return api.teamReady(team) and api.teamTogether()
    end
    local function target()
        if sel>=1 then return MAPS[sel] end
        local here=world().scene
        for _,m in ipairs(MAPS) do if m==here then return m end end
        return MAPS[1]
    end
    local function fight()
        GetLuaValue("-- fanzei:ui\nif Player:IsFollow()==1 or Player:IsFollow()==true then Player:StopFollow() end",'',0)
        local T=DungeonTactics.new(api,SCENE,{});T.watch(KEYS);T.readMessages()
        local start,lastProgress,lastLoot,hps,leaving=api.now(),api.now(),-100000,{},nil
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(PATROL) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        while true do
            if T.readMessages() then lastProgress=api.now() end
            local p=world()
            if p.scene~=SCENE then return end
            assert(api.now()-start<battleMs,'贼兵入侵战斗超过时限')
            api.alive(minimum,'贼兵入侵：角色血量低于停止阈值，自动复活未接入，已停止')
            local mob
            for _,o in ipairs(T.rows()) do
                if T.enemy(o) then
                    if o.dst<=15 and (not mob or o.dst<mob.dst) then mob=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;lastProgress=api.now() end
                end
            end
            if T.seenAt['已杀死造反恶贼： 31/31'] or T.seenAt['离开场景'] then
                leaving=leaving or api.now()
                assert(api.now()-leaving<math.max(waitMs,120000),'贼兵入侵：结束后走到出口仍在副本内')
                log('离开副本');T.stop();api.pickup()
                if world().scene~=SCENE then return end
                T.move(22,97)
            elseif mob then log('清怪');T.attack(mob)
            elseif T.seenAt['已杀死造反恶贼： 30/31'] then log('前往反贼头目');T.stop();T.move(20,100)
            else
                log('巡逻');T.stop()
                if api.now()-lastLoot>=3000 then lastLoot=api.now();api.pickup() end
                if world().scene~=SCENE then return end
                local q=PATROL[idx]
                if not T.move(q[1],q[2]) then idx=idx%#PATROL+1;T.clearMove() end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;lastProgress=api.now() end
            assert(api.now()-lastProgress<180000,'贼兵入侵阶段没有进展：'..phase)
            api.sleep(250)
        end
    end
    local function search()
        local map=target();local route=SEARCH[map]
        if world().scene~=map then MoveTo(route[1][1],route[1][2],map) end
        local T=DungeonTactics.new(api,map,{})
        GetLuaValue("-- fanzei:ui\nif Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end",'',0)
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(route) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        local tried,start={},api.now()
        while api.now()-start<SEARCH_MS do
            log('寻找造反恶贼')
            local npc
            for _,o in ipairs(T.rows()) do
                if o.name=='造反恶贼' and o.hp>0 and not T.enemy(o) and api.now()-(tried[o.id] or -100000)>=30000 and (not npc or o.dst<npc.dst) then npc=o end
            end
            if npc then
                tried[npc.id]=api.now()
                if pcall(api.openNpc,{name=npc.name,x=math.floor(npc.x),y=math.floor(npc.y),scene=map}) then
                    api.sleep(500)
                    local began=api.now()
                    while not gathered() and api.now()-began<math.max(waitMs,70000) do api.maintain();api.sleep(250) end
                    if gathered() and api.selectOption({'难道我还怕你不成……'},true) then api.sleep(1000);CloseAllWindow();return true end
                end
                if world().scene==map then CloseAllWindow() end
                T.clearMove()
            else
                local q=route[idx]
                if not T.move(q[1],q[2]) then idx=idx%#route+1;T.clearMove() end
            end
            api.maintain();api.sleep(250)
        end
        return false
    end
    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            local resumed=world().scene==SCENE
            if not resumed then
                if before.used==before.limit then
                    return {status=completed>0 and 'done' or 'already_done',message='贼兵入侵今日次数已满；本次完成 '..completed..' 轮'}
                end
                api.space();api.prepareBattle()
                local began=api.now()
                if isLead() then
                    if not search() then
                        if completed>0 then break end
                        error('贼兵入侵：10 分钟没有找到可入场的造反恶贼',0)
                    end
                    began=api.now();log('确认进入副本')
                    while world().scene~=SCENE do
                        assert(api.now()-began<math.max(waitMs,60000),'贼兵入侵：选择后没有进入副本，未重复发送')
                        api.maintain();api.sleep(500)
                    end
                else
                    local map=target()
                    if world().scene~=map then MoveTo(SEARCH[map][1][1],SEARCH[map][1][2],map) end
                    log('等待队长进入副本')
                    while world().scene~=SCENE do
                        if api.now()-began>=SEARCH_MS then
                            if completed>0 then return {status='done',message='贼兵入侵完成 '..completed..' 轮；之后没有再进入副本'} end
                            error('贼兵入侵：10 分钟没有进入副本',0)
                        end
                        api.maintain();api.sleep(500)
                    end
                end
            end
            fight()
            if not resumed then
                local started,refreshed=api.now(),false
                log('确认本轮活动次数')
                while true do
                    local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
                    assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'贼兵入侵活动记录发生变化或次数回退')
                    if c.used>before.used then break end
                    assert(api.now()-started<math.max(waitMs,15000),'贼兵入侵：离开后活动次数没有增加，不算完成')
                    api.maintain();api.sleep(1000)
                end
            end
            completed=completed+1;log('本轮完成（'..completed..'）')
        end
        return {status='done',message='贼兵入侵完成 '..completed..' 轮'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'贼兵入侵停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
