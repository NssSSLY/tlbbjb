-- 刷马贼, written from the reference rules (原脚本源码/Script64/常用/自动刷马贼.lua), its loop-the-ticked-maps mode. The refresh-watching mode needs a native helper with no source.
-- 收费传送, 定位符, 补给, 存仓, 出售, 喊话 and leader swaps are not ported. This task owns its stages and receipts; it does not load the vendor framework.
-- docs/LONG_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Mazei={}
local POS={}
POS[3]={{56,57},{84,140},{119,138},{46,171},{52,223},{94,268},{175,248},{187,170},{215,271},{251,269},{278,270},{251,204},{250,91}}
POS[4]={{165,254},{89,253},{53,220},{124,147},{127,64},{158,44},{234,61},{241,145},{179,170},{180,200},{218,218},{269,196},{261,246}}
POS[5]={{191,46},{70,44},{119,83},{125,88},{128,143},{119,169},{108,146},{45,204},{69,263},{48,256},{38,276},{108,272},{169,224},{225,257},{238,252}}
POS[8]={{239,164},{178,154},{164,118},{246,71},{261,52},{124,108},{66,78},{97,128},{77,152},{116,183},{51,213},{112,217},{203,234}}
POS[18]={{54,50},{56,103},{56,143},{137,116},{119,165},{83,180},{97,206},{81,245},{51,261},{192,270},{228,271},{238,233},{194,216},{266,179},{218,115},{249,47},{163,73},{102,44}}
POS[19]={{254,175},{251,165},{266,51},{192,48},{113,39},{50,36},{47,87},{40,130},{105,101},{151,119},{74,190},{114,261}}
POS[20]={{254,222},{258,285},{177,244},{106,252},{50,265},{82,230},{109,181},{49,163},{49,52},{109,40},{129,118},{191,128},{186,84},{270,89}}
POS[21]={{101,262},{170,270},{84,225},{93,201},{55,189},{55,156},{61,91},{103,58},{113,92},{233,50},{275,86},{248,125},{224,143},{151,137},{155,170},{225,201},{268,223},{219,259},{271,252}}
POS[22]={{117,156},{55,165},{52,216},{123,192},{47,119},{93,180},{142,52},{99,118},{85,81},{107,47},{47,53},{45,91},{198,139},{213,271},{201,135},{234,163},{267,150},{169,64},{262,104},{249,53}}
POS[23]={{64,194},{54,117},{119,82},{222,57},{252,65},{252,108},{263,270},{218,254},{196,177},{171,278},{119,275},{108,216}}
POS[24]={{206,130},{187,139},{149,99},{135,143},{77,100},{62,148},{44,185},{96,196},{81,236},{87,266},{155,234},{170,266},{181,232},{230,269},{240,215},{252,167}}
POS[25]={{162,54},{153,100},{139,107},{95,130},{105,123},{62,72},{95,130},{71,187},{63,214},{49,257},{87,136},{112,222},{157,143},{195,157},{156,195},{169,261},{227,263},{264,267},{214,225},{265,136}}
POS[26]={{174,108},{206,66},{98,56},{48,100},{87,77},{118,111},{105,132},{85,155},{112,188},{139,217},{44,241},{105,245},{231,232},{256,275},{242,198},{258,175},{235,159}}
POS[27]={{124,61},{48,97},{51,119},{103,155},{44,243},{86,273},{172,251},{183,216},{210,257},{270,251},{240,190},{219,119},{270,149},{264,66},{150,101}}
POS[28]={{192,144},{276,192},{221,163},{240,224},{203,213},{201,257},{47,256},{59,160},{106,158},{106,216},{182,198},{159,172},{94,106},{64,75},{83,46}}
POS[29]={{34,35},{98,53},{155,122},{151,65},{191,53},{170,122},{274,132},{139,150},{227,154},{222,227},{279,243},{270,276},{205,200},{153,190},{115,216},{42,210},{57,188},{64,47}}
POS[30]={{83,77},{112,95},{105,175},{62,187},{112,229},{76,245},{101,257},{183,195},{210,210},{235,201},{231,253},{262,268},{232,122}}
POS[31]={{64,245},{106,240},{69,183},{50,123},{105,136},{108,126},{93,75},{193,89},{266,85},{222,119},{172,162},{250,148},{241,169},{40,142},{244,209},{181,224},{158,270},{265,270},{280,248}}
POS[32]={{69,97},{52,215},{86,257},{150,262},{188,277},{199,243},{129,175},{211,184},{239,167},{267,100},{274,58},{199,124},{195,90},{216,80},{227,66},{145,45}}
POS[33]={{68,254},{64,225},{49,100},{101,54},{137,71},{113,125},{142,135},{126,189},{150,218},{132,261},{197,262},{250,269},{226,165},{268,191},{269,112},{238,75},{246,41}}
POS[34]={{277,261},{244,103},{173,129},{222,219},{176,272},{124,257},{154,210},{127,133},{63,178},{51,121},{93,91},{39,70},{57,39},{156,44},{155,83},{190,115},{245,42},{284,66},{249,177}}
POS[35]={{188,218},{210,192},{118,160},{196,253},{186,250},{142,260},{114,226},{77,255},{72,235},{137,129},{112,111},{170,84},{110,76},{140,70},{50,49},{265,57},{241,84},{258,178},{210,158},{224,116},{262,221}}
if POS[34] then for _,q in ipairs(POS[34]) do if q[1]==57 and q[2]==32 then q[2]=39 end end end
local SCENES={{'xzk1','嵩山',3},{'xzk2','太湖',4},{'xzk3','镜湖',5},{'xzk4','西湖',30},{'xzk5','龙泉',31},{'xzk6','武夷',32},{'xzk7','梅岭',33},{'xzk8','南海',34},{'xzk9','琼州',35},{'xzk10','敦煌',8},{'xzk11','雁南',18},{'xzk12','雁北',19},
    {'xzk13','草原',20},{'xzk14','辽西',21},{'xzk15','长白山',22},{'xzk16','黄龙府',23},{'xzk17','洱海',24},{'xzk18','苍山',25},{'xzk19','石林',26},{'xzk20','玉溪',27},{'xzk21','南诏',28},{'xzk22','苗疆',29}}
local NAMES={['夺宝马贼']=true,['护宝马贼']=true}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Mazei.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local minutes=int(tonumber(cfg.mazei_minutes or 60),1,115,'运行时长')
    local bagSeconds=int(tonumber(cfg.bjk91 or 1),0,20,'等包时间')
    local minTeam=int(tonumber(cfg.dungeon_team_count or 3),1,6,'最低队伍人数')
    local waitTeam=cfg.xzk77==true
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local chosen={}
    for _,s in ipairs(SCENES) do if cfg[s[1]]==true then chosen[#chosen+1]={name=s[2],scene=s[3]} end end
    local current=cfg.xzk23==true
    if #chosen==0 and not current then error('刷马贼：没有勾选地图，也没有打开“先刷当前地图”',0) end
    local def={name='刷马贼',mission='马贼',map='',npc={name='夺宝马贼',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    local phase,kills='',0
    local function log(s) if phase~=s then phase=s;api.log('刷马贼 · '..s) end end
    local function world() return assert(api.world(),'刷马贼场景不可读') end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local deadline=api.now()+minutes*60000
    local counted,tried={},{}
    local function alive() api.alive(minimum,'刷马贼：角色血量低于停止阈值，已停止',true) end
    -- Team below the minimum: wait for it when asked to, otherwise the run ends here.
    local function teamOk()
        if GetTeamCount()>=minTeam or minTeam<=1 then return true end
        if not waitTeam then return false end
        log('队伍少于 '..minTeam..' 人，等待')
        while GetTeamCount()<minTeam do
            if api.now()>=deadline then return false end
            api.maintain();api.sleep(5000)
        end
        return true
    end
    -- One frame of hunting. True while something was worth staying for.
    local function hunt(T)
        local mob,npc
        for _,o in ipairs(T.rows()) do
            if NAMES[o.name] then
                if o.hp==0 then
                    if not counted[o.id] then
                        counted[o.id]=true;kills=kills+1;api.log('刷马贼：本次已杀 '..kills..' 个')
                        local began=api.now()
                        repeat api.pickup();api.sleep(500) until api.now()-began>=bagSeconds*1000 or world().scene~=T.scene
                        return true
                    end
                elseif T.enemy(o) then
                    if not mob or o.hp<mob.hp then mob=o end
                elseif (not tried[o.id] or api.now()-tried[o.id]>=30000) and (not npc or o.dst<npc.dst) then npc=o end
            end
        end
        if mob then log('击杀马贼');T.attack(mob);return true end
        if npc and isLead() then
            -- The reference opens a green bandit at or under its level by talking. Level is not readable: a higher one does not answer and is passed over for 30 seconds.
            tried[npc.id]=api.now();T.stop();log('开启 '..npc.name)
            if pcall(api.openNpc,{name=npc.name,x=math.floor(npc.x),y=math.floor(npc.y),scene=T.scene}) then
                api.sleep(300);api.selectOption({'开启战斗'},true);api.sleep(300)
            end
            if world().scene==T.scene then CloseAllWindow() end
            return true
        end
        return false
    end
    local function search(target)
        local route=POS[target]
        if not route then error('刷马贼：地图 '..tostring(target)..' 没有寻找坐标，已停止',0) end
        if world().scene~=target then
            log('前往地图 '..target);MoveTo(route[1][1],route[1][2],target)
        end
        local T=DungeonTactics.new(api,target,{});T.scene=target
        GetLuaValue("-- mazei:ui\nif Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end",'',0)
        local idx=1
        while idx<=#route do
            if api.now()>=deadline or not isLead() then return end
            alive()
            if world().scene~=target then return end
            if not hunt(T) then
                log('巡逻寻马');T.stop()
                if not T.move(route[idx][1],route[idx][2]) then idx=idx+1;T.clearMove() end
            end
            api.maintain();api.sleep(250)
        end
        T.stop()
    end
    local function leader()
        api.space()
        if current then
            local here=world().scene
            if POS[here] then search(here) end
            current=false
        end
        if #chosen==0 then return true end
        while api.now()<deadline and isLead() do
            for _,s in ipairs(chosen) do
                if api.now()>=deadline or not isLead() then return true end
                if not teamOk() then return false end
                search(s.scene)
            end
        end
        return true
    end
    local function follower()
        local T,scene
        while api.now()<deadline and not isLead() do
            alive()
            if not teamOk() then return false end
            local p=world()
            if p.scene~=scene then scene=p.scene;T=DungeonTactics.new(api,scene,{});T.scene=scene end
            if not hunt(T) then
                log('跟随队长');T.stop()
                local id=DungeonTactics.leaderId()
                local found=false
                for _,o in ipairs(T.players()) do
                    if o.id==id then found=true;if d2(p,o.x,o.y)>9 then T.move(math.floor(o.x),math.floor(o.y)) end;break end
                end
                if not found then GetLuaValue("-- mazei:ui\nif Player:IsFollow()==0 or Player:IsFollow()==false then Player:TeamFrame_AskTeamFollow() end",'',0) end
                api.pickup()
            end
            api.maintain();api.sleep(250)
        end
        return true
    end
    local function body()
        api.validate(def,cfg);api.prepareBattle()
        local enough=true
        if not teamOk() then error('刷马贼：队伍少于 '..minTeam..' 人，已停止；要等人请打开“人数不足时等待”',0) end
        while enough and api.now()<deadline do
            local r=api.resumable(function() if isLead() then return leader() else return follower() end end)
            if r~=nil then enough=r end
            if #chosen==0 and isLead() then break end
        end
        return {status='done',message='刷马贼结束，本次已杀 '..kills..' 个'..(enough and '' or '；队伍人数不足')}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..'；已杀 '..kills..' 个]',0) end
    assert(stopped,'刷马贼停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
