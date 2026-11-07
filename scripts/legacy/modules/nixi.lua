-- 逆袭 assassin hunt, written from the reference rules (原脚本源码/Script64/活动/逆袭.lua). The leader walks a map's points and kills 契丹刺客.
-- Paid transport, 定位符, 马鞍 and team chat announcements are not ported. This task owns its stages and receipts; it does not load
-- the vendor framework. docs/ACTIVITY_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Nixi={}
local NAMES={['黄金契丹刺客']=true,['契丹刺客']=true}
local MAPS={['无量山']=6,['剑阁']=7,['嵩山']=3,['太湖']=4,['西湖']=30,['武夷']=32,['敦煌']=8,['雁南']=18,['雁北']=19,['草原']=20,['洱海']=24,['苍山']=25}
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
POS[23]={{64,194},{54,117},{119,82},{252,53},{252,108},{263,270},{218,254},{196,177},{171,278},{119,275},{108,216}}
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
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

function Nixi.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local minutes=int(tonumber(cfg.nixi_minutes or 60),1,600,'运行时长')
    local bagSeconds=int(tonumber(cfg.bjk91 or 5),0,20,'等包时间')
    local choice=tostring(cfg['逆袭地图'] or '当前地图')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='逆袭',mission='逆袭',map='逆袭',npc={name='契丹刺客',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    local phase,kills='',0
    local function log(s) if phase~=s then phase=s;api.log('逆袭 · '..s) end end
    local function world() return assert(api.world(),'逆袭场景不可读') end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local deadline=api.now()+minutes*60000
    local counted,tried={},{}
    -- One frame of hunting on a scene. True while something was worth staying for.
    local function hunt(T)
        local all=T.rows()
        local mob,npc
        for _,o in ipairs(all) do
            if NAMES[o.name] then
                if o.hp==0 then
                    if not counted[o.id] then
                        counted[o.id]=true;kills=kills+1;api.log('逆袭：本次已杀 '..kills..' 个刺客')
                        if bagSeconds>0 then
                            local began=api.now()
                            repeat api.pickup();api.sleep(500) until api.now()-began>=bagSeconds*1000 or world().scene~=T.scene
                        end
                        return true
                    end
                elseif T.enemy(o) then
                    if not mob or o.hp<mob.hp then mob=o end
                elseif (not tried[o.id] or api.now()-tried[o.id]>=30000) and (not npc or o.dst<npc.dst) then npc=o end
            end
        end
        if mob then log('击杀刺客');T.attack(mob);return true end
        if npc then
            -- A green assassin at or below the player's level starts its fight on talk; higher ones do not answer, and are skipped for a while.
            tried[npc.id]=api.now();T.stop();log('对话刺客')
            if pcall(api.openNpc,{name=npc.name,x=math.floor(npc.x),y=math.floor(npc.y),scene=T.scene}) then api.sleep(300) end
            if world().scene==T.scene then CloseAllWindow() end
            return true
        end
        return false
    end
    local function leader()
        local target
        if choice=='当前地图' then target=world().scene else target=assert(MAPS[choice],'逆袭地图无效：'..choice) end
        local route=POS[target]
        if not route then error('逆袭：地图 '..tostring(choice=='当前地图' and target or choice)..' 没有寻找坐标，已停止',0) end
        if world().scene~=target then MoveTo(route[1][1],route[1][2],target) end
        local T=DungeonTactics.new(api,target,{});T.scene=target
        GetLuaValue("-- nixi:ui\nif Player:IsLeader()==1 and (Player:IsFollow()==0 or Player:IsFollow()==false) then Player:TeamFrame_AskTeamFollow() end",'',0)
        local idx,best=1,nil
        do local p=world();for i,q in ipairs(route) do local s=d2(p,q[1],q[2]);if not best or s<best then idx,best=i,s end end end
        while api.now()<deadline do
            api.alive(minimum,'逆袭：角色血量低于停止阈值，自动复活未接入，已停止')
            assert(world().scene==target,'逆袭：离开了目标地图')
            if not hunt(T) then
                log('巡逻寻找');T.stop()
                local q=route[idx]
                if not T.move(q[1],q[2]) then idx=idx%#route+1;T.clearMove() end
            end
            api.maintain();api.sleep(250)
        end
    end
    local function follower()
        local T,scene
        local leaderId;for i,m in ipairs(api.teamIdentities()) do if i==1 then leaderId=m.id end end
        while api.now()<deadline do
            api.alive(minimum,'逆袭：角色血量低于停止阈值，自动复活未接入，已停止')
            local p=world()
            if p.scene~=scene then scene=p.scene;T=DungeonTactics.new(api,scene,{});T.scene=scene end
            if not hunt(T) then
                log('跟随队长');T.stop()
                for _,o in ipairs(T.players()) do
                    if o.id==leaderId and d2(p,o.x,o.y)>9 then T.move(math.floor(o.x),math.floor(o.y));break end
                end
            end
            api.maintain();api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        api.space();api.prepareBattle()
        if isLead() then leader() else follower() end
        return {status='done',message='逆袭运行 '..minutes..' 分钟，已杀 '..kills..' 个刺客'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'逆袭停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
