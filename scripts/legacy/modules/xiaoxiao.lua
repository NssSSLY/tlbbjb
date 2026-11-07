-- 偷袭门派 (江湖宵小), written from the reference rules (原脚本源码/Script64/副本/偷袭门派(宵小).lua). 宵小 raid one school at a time; only a member of that
-- school can start the fight. The reference learns the school from a native helper with no source here, so the leader walks the team's schools in turn.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Xiaoxiao={}
local CAMPAIGN={page=1,campaign='偷袭门派'}
local INFO={}  -- school id -> {scene, inner scene}
INFO[0]={scene=9,inner=173}
INFO[1]={scene=11,inner=175}
INFO[2]={scene=10,inner=174}
INFO[3]={scene=12,inner=176}
INFO[4]={scene=15,inner=179}
INFO[5]={scene=16,inner=180}
INFO[6]={scene=13,inner=177}
INFO[7]={scene=17,inner=181}
INFO[8]={scene=14,inner=178}
INFO[10]={scene=284,inner=288}
INFO[11]={scene=615,inner=618}
INFO[12]={scene=678,inner=681}
INFO[13]={scene=731,inner=742}
INFO[14]={scene=824,inner=829}
INFO[15]={scene=987,inner=1001}
local INNER={};for id,v in pairs(INFO) do INNER[v.inner]=id end
local INNER_POS,MAP_POS={},{}
INNER_POS[0]={{95,125},{106,103},{106,99},{88,104},{80,91},{69,88},{70,68},{96,90},{87,82},{104,80},{100,72},{88,72},{95,71}}
INNER_POS[1]={{98,149},{98,135},{99,117},{97,107},{77,95},{92,92},{98,84},{112,72},{111,57},{82,71},{98,57},{98,44},{99,45}}
INNER_POS[2]={{71,95},{85,80},{46,86},{44,108},{43,61},{63,52},{72,66},{80,64},{58,62}}
INNER_POS[3]={{93,169},{103,167},{89,138},{77,130},{72,112},{78,110},{93,113},{78,97},{83,84},{70,84},{46,94},{45,58},{90,57},{86,53}}
INNER_POS[4]={{89,138},{92,108},{95,91},{82,89},{65,107},{40,110},{54,91},{51,72},{57,57},{44,44},{35,56},{112,111},{75,73},{93,68},{95,40}}
INNER_POS[5]={{95,52},{71,57},{69,72},{89,75},{108,71},{115,72},{96,87},{90,98},{101,99},{97,119},{96,129},{95,139},{95,52}}
INNER_POS[6]={{93,123},{107,105},{104,91},{95,89},{85,90},{72,107},{78,57},{64,69},{42,57},{73,35},{96,36},{117,36},{157,38},{138,59},{115,73},{95,38}}
INNER_POS[7]={{95,118},{112,118},{78,120},{120,97},{100,100},{83,99},{66,102},{94,83},{97,70},{87,69},{62,38},{60,66},{74,48},{91,45},{103,47},{125,37},{115,50},{94,45}}
INNER_POS[8]={{47,148},{53,76},{51,56},{73,55},{105,88},{125,95},{123,75},{144,59},{159,58},{125,130},{143,123},{127,154},{115,144},{76,153},{70,136},{120,88}}
INNER_POS[10]={{142,157},{142,139},{146,120},{156,82},{159,54},{168,51},{129,38},{111,44},{67,27},{52,30},{55,60},{67,115},{86,114},{86,133},{69,132},{56,135},{34,164}}
INNER_POS[11]={{162,152},{167,126},{160,101},{129,68},{99,67},{40,69},{33,80},{72,50},{76,39},{67,32},{75,43}}
INNER_POS[12]={{95,146},{108,123},{108,154},{138,146},{148,134},{155,104},{152,89},{152,72},{137,68},{114,78},{100,107},{85,106},{83,121},{81,135},{79,142},{65,141},{49,134},{34,124},{40,106},{40,71},{55,71},{79,87},{88,66},{104,66},{97,61}}
INNER_POS[13]={{246,184},{221,189},{201,179},{183,173},{175,162},{158,163},{158,144},{158,114},{128,114},{117,96},{111,84},{128,88},{167,83},{159,60},{171,56},{160,55}}
INNER_POS[14]={{180,342},{178,318},{206,316},{240,318},{257,309},{257,279},{255,258},{245,258},{257,224},{257,193},{255,163}}
INNER_POS[15]={{32,195},{44,144},{41,115},{59,77},{65,88},{85,98},{131,109},{120,118},{108,58},{82,44}}
MAP_POS[9]={{92,130},{70,60},{67,109},{95,139},{128,76},{133,143},{154,144},{149,61},{48,40},{46,141},{66,136}}
MAP_POS[10]={{93,119},{72,118},{70,92},{92,79},{76,60},{92,46},{125,63},{106,80},{112,117},{130,155},{152,149},{155,92},{134,83},{155,64},{152,37},{61,39},{45,36},{43,147}}
MAP_POS[11]={{100,167},{72,139},{83,154},{61,117},{48,97},{39,37},{61,36},{59,79},{86,56},{83,39},{112,38},{110,58},{133,51},{153,37},{154,59},{116,139},{138,158},{154,78}}
MAP_POS[12]={{101,136},{96,112},{105,127},{78,86},{47,55},{81,49},{97,62},{80,135},{90,180},{50,177},{46,139}}
MAP_POS[13]={{98,120},{66,122},{64,146},{42,135},{24,126},{40,80},{53,39},{153,36},{96,79},{154,90},{154,124},{118,124},{96,129}}
MAP_POS[14]={{68,143},{48,147},{49,55},{115,88},{57,111},{89,124},{144,154},{148,123},{159,54},{126,43}}
MAP_POS[15]={{86,142},{39,152},{37,108},{40,46},{98,39},{145,106},{146,153},{144,43}}
MAP_POS[16]={{99,150},{96,84},{124,73},{144,54},{136,36},{71,43},{71,80},{48,65},{61,145},{91,129},{144,140},{147,87},{96,125}}
MAP_POS[17]={{91,119},{67,100},{40,147},{33,95},{38,44},{66,80},{95,100},{128,98},{146,140},{155,45},{124,69},{117,51},{61,42},{61,65}}
MAP_POS[284]={{29,137},{52,162},{29,163},{29,109},{54,62},{31,59},{87,67},{30,28},{131,36},{167,51},{161,97},{157,165},{134,117},{83,162}}
MAP_POS[615]={{126,69},{95,102},{43,147},{121,119},{163,156},{164,35},{78,41},{23,23}}
MAP_POS[678]={{86,147},{33,133},{34,73},{18,42},{48,23},{85,65},{161,56},{117,24},{148,105},{109,149},{94,105}}
MAP_POS[731]={{245,171},{264,164},{233,143},{209,116},{189,115},{188,77},{160,75},{171,54},{150,53},{159,82},{106,83},{128,111},{157,138},{109,135},{133,166},{167,190},{167,154},{224,184},{239,223}}
MAP_POS[824]={{278,318},{255,275},{232,265},{275,253},{256,198},{282,165},{256,165},{229,165},{239,191},{173,258},{157,271},{124,250}}
MAP_POS[987]={{123,218},{51,208},{35,118},{121,154},{104,62},{134,55},{180,179}}
local SEARCH_MS=600000
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Xiaoxiao.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    assert(cfg.xiaoxiao_change_leader==nil or type(cfg.xiaoxiao_change_leader)=='boolean','偷袭门派开关无效')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='偷袭门派',mission='偷袭门派',map='宵小',npc={name='江湖宵小',x=0,y=0,scene=9},bosses={}}
    function def.inside(p) return INNER[p.scene]~=nil end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('偷袭门派 · '..s) end end
    local function world() return assert(api.world(),'偷袭门派场景不可读') end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function ui(code) GetLuaValue('-- xiaoxiao:ui\n'..code,'',0) end
    local school=math.floor(api.school())
    -- Everyone's school, in team order, with the slot to hand leadership to.
    local function roster()
        local text=GetLuaValue([[-- xiaoxiao:roster
            local t='' local n=DataPool:GetTeamMemberCount()
            for i=0,n-1 do local name,menpai=DataPool:GetTeamMemInfoByIndex(i) t=t..tostring(menpai)..'\n' end
            return t]],'s')
        local out={};for s in tostring(text or ''):gmatch('[^\n]+') do out[#out+1]=math.floor(tonumber(s) or -1) end
        return out
    end
    local function killCount()
        local m=api.mission(def)
        if not m then return -1 end
        local n=GetLuaValue(string.format("-- xiaoxiao:kills\nreturn DataPool:GetPlayerMission_Variable(%d,1)",m.slot),'n')
        return type(n)=='number' and n or -1
    end
    local function leaderName()
        local n=GetLuaValue("-- xiaoxiao:leader\nif DataPool:GetTeamMemberCount()<1 then return '' end local name=DataPool:GetTeamMemInfoByIndex(0) return name or ''",'s')
        return type(n)=='string' and n or ''
    end
    -- Give the team back to whoever led it before this task handed it over.
    local function restoreLeader(name)
        if name=='' or cfg.xiaoxiao_change_leader~=true or GetTeamCount()==0 or not api.isLeader() or leaderName()==name then return end
        log('把队长交回 '..name)
        ui(string.format([[local want=%q
            for i=0,DataPool:GetTeamMemberCount()-1 do
                local name=DataPool:GetTeamMemInfoByIndex(i)
                if name==want then Player:AppointLeader(i) break end
            end]],name))
    end
    local function fight()
        ui("if Player:IsFollow()==1 or Player:IsFollow()==true then Player:StopFollow() end")
        local scene=world().scene
        local route=assert(INNER_POS[INNER[scene]],'偷袭门派：副本内没有此门派的坐标')
        local T=DungeonTactics.new(api,scene,{});T.watch({'离开场景'});T.readMessages()
        local start,lastProgress,lastLoot,hps,leaving=api.now(),api.now(),-100000,{},nil
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(route) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        while true do
            if T.readMessages() then lastProgress=api.now() end
            local p=world()
            if p.scene~=scene then return end
            assert(api.now()-start<battleMs,'偷袭门派战斗超过时限')
            api.alive(minimum,'偷袭门派：角色血量低于停止阈值，自动复活未接入，已停止')
            local mob
            for _,o in ipairs(T.rows()) do
                if T.enemy(o) then
                    if o.dst<=15 and (not mob or o.dst<mob.dst) then mob=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;lastProgress=api.now() end
                end
            end
            if T.seenAt['离开场景'] and not mob then
                -- The game moves the team out on its own; the reference only waits, then forces its way out after a minute.
                leaving=leaving or api.now();log('等待离开副本');T.stop();api.pickup();lastProgress=api.now()
                if world().scene~=scene then return end
                assert(api.now()-leaving<math.max(waitMs,120000),'偷袭门派：结束后仍在副本内')
            elseif mob then log('清怪');T.attack(mob)
            elseif isLead() then
                T.stop()
                if api.now()-lastLoot>=3000 then lastLoot=api.now();api.pickup() end
                if world().scene~=scene then return end
                if killCount()==30 then log('前往恶霸');local q=route[#route];T.move(q[1],q[2])
                else
                    log('巡逻')
                    local q=route[idx]
                    if not T.move(q[1],q[2]) then idx=idx%#route+1;T.clearMove() end
                end
            else
                log('跟随队长');T.stop()
                local leaderId=DungeonTactics.leaderId()
                for _,o in ipairs(T.players()) do
                    if o.id==leaderId and d2(p,o.x,o.y)>16 then T.move(math.floor(o.x),math.floor(o.y));break end
                end
            end
            if world().scene==scene then
                api.maintain()
                local q=world()
                if q.scene==scene and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;lastProgress=api.now() end
                assert(api.now()-lastProgress<180000,'偷袭门派阶段没有进展：'..phase)
            end
            api.sleep(250)
        end
    end
    -- Walk the team's schools. True once a fight was started; nil after handing over leadership.
    local function search()
        local schools,seen={},{}
        local function add(s) if s and INFO[s] and not seen[s] and MAP_POS[INFO[s].scene] then seen[s]=true;schools[#schools+1]=s end end
        add(school);for _,s in ipairs(roster()) do add(s) end
        assert(#schools>0,'偷袭门派：队伍的门派都没有寻找坐标')
        local start=api.now();local tried={}
        local turn=1
        while api.now()-start<SEARCH_MS do
            local s=schools[turn];local map=INFO[s].scene;local route=MAP_POS[map]
            if world().scene~=map then MoveTo(route[1][1],route[1][2],map) end
            local T=DungeonTactics.new(api,map,{})
            ui("if Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end")
            for i=1,#route do
                log('寻找江湖宵小（'..s..' 号门派）')
                while T.move(route[i][1],route[i][2]) do
                    local npc=T.best(T.rows(),'江湖宵小',function(o) return o.hp>0 and not T.enemy(o) and api.now()-(tried[o.id] or -100000)>=30000 end)
                    if npc then
                        tried[npc.id]=api.now()
                        if s~=school then
                            -- Only that school's member can start it.
                            if cfg.xiaoxiao_change_leader~=true then error('偷袭门派：宵小在别的门派，未打开“允许自动交队长”，已停止',0) end
                            for slot,m in ipairs(roster()) do
                                if m==s then
                                    log('交队长给该门派队员');ui(string.format('Player:AppointLeader(%d)',slot-1));api.sleep(1000)
                                    return nil
                                end
                            end
                        else
                            local ok=pcall(api.openNpc,{name=npc.name,x=math.floor(npc.x),y=math.floor(npc.y),scene=map})
                            if ok then
                                api.sleep(500)
                                api.selectOption({'#{XMPTX_210712_11}'},true);api.sleep(800)
                                api.selectOption({'难道我还怕你不成……'},true);api.sleep(800)
                            end
                            if world().scene==map then CloseAllWindow() end
                            return true
                        end
                    end
                    assert(api.now()-start<SEARCH_MS,'偷袭门派：10 分钟没有找到江湖宵小')
                    api.maintain();api.sleep(250)
                end
                T.clearMove()
            end
            turn=turn%#schools+1
        end
        return false
    end
    local originalLeader=''
    local function body()
        api.validate(def,cfg)
        originalLeader=leaderName()
        for _=1,rounds do
            local before=api.campaign(CAMPAIGN,true)
            local resumed=INNER[world().scene]~=nil
            if not resumed then
                if before.used==before.limit then
                    return {status=completed>0 and 'done' or 'already_done',message='偷袭门派今日次数已满；本次完成 '..completed..' 轮'}
                end
                api.space();api.prepareBattle()
                -- Leadership can arrive mid-wait: the member of the raided school is handed it and takes over the talk.
                local began,talked=api.now(),false
                while INNER[world().scene]==nil do
                    if isLead() and not talked then
                        local r=search()
                        if r==true then talked=true;began=api.now();log('确认进入副本')
                        elseif r==false then
                            if completed>0 then return {status='done',message='偷袭门派完成 '..completed..' 轮；之后没有再找到江湖宵小'} end
                            error('偷袭门派：10 分钟没有找到江湖宵小',0)
                        end
                    elseif not talked then log('等待队长进入副本') end
                    if api.now()-began>=(talked and math.max(waitMs,60000) or SEARCH_MS) then
                        if completed>0 then return {status='done',message='偷袭门派完成 '..completed..' 轮；之后没有再进入副本'} end
                        error('偷袭门派：'..(talked and '选择后没有进入副本，未重复发送' or '10 分钟没有进入副本'),0)
                    end
                    api.maintain();api.sleep(500)
                end
            end
            fight()
            if not resumed then
                local started,refreshed=api.now(),false
                log('确认本轮活动次数')
                while true do
                    local c=api.campaign(CAMPAIGN,not refreshed);refreshed=true
                    assert(c.name==before.name and c.limit==before.limit and c.used>=before.used,'偷袭门派活动记录发生变化或次数回退')
                    if c.used>before.used then break end
                    assert(api.now()-started<math.max(waitMs,15000),'偷袭门派：离开后活动次数没有增加，不算完成')
                    api.maintain();api.sleep(1000)
                end
            end
            completed=completed+1;log('本轮完成（'..completed..'）')
        end
        return {status='done',message='偷袭门派完成 '..completed..' 轮'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    pcall(restoreLeader,originalLeader)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'偷袭门派停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
