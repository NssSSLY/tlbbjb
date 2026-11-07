-- Four-boss dungeon. Geometry/dialog keys come from 002e1226/004ed3ee;
-- no vendor DLL or mixed framework is loaded. A disappeared target is not a kill.
LoadScript('dungeon_api')
LoadScript('sijue_mechanisms')
LoadScript('dungeon_pet_guard')
Sijue={}
local R=assert(CombatRuntime)
local def={name='四绝庄',mission='#{SJZ_100129_03}',map='四绝庄',
    npc={name='潘菁菁',x=195,y=215,scene=1},
    accept={'#{SJZ_100129_03}'},enter={'#{SJZ_100129_11}'},turnin={'#{SJZ_100129_03}'},
    bosses={'闵墨','秦韵','陶青','庞企'}}
function def.inside(p) return p.scene==291 end
local stages={
    {name='闵墨',center={101,93},guide={96,80},start={100,114},adds={'四绝钟','四绝庄护卫','四绝庄教头'}},
    {name='秦韵',center={28,100},guide={35,87},adds={}},
    {name='陶青',center={97,34},guide={84,22},adds={'青鹰','冰墨虎','火墨虎','玄墨虎','毒墨虎'}},
    {name='庞企',center={30,27},guide={23,17},adds={'星罗武士'}}}
local beginKeys={'#{SJZYH_150824_4}','#{SJZYH_150824_3}','#{SJZYH_150824_2}',
    '#{SJZYH_150824_1}','#{SJZYH_150824_5}','#{SJZYH_150824_6}','#{YXJJ_091118_19}'}
local columns={{41,31},{41,31},{18,31},{18,31},{29,19}}
local modes={['普通']={'#{SJZ_100129_11}',''},['初级']={'#{XKFB_250115_04}','·闻恶'},
    ['中级']={'#{XKFB_250115_47}','·识恶'},['高级']={'#{XKFB_250115_05}','·罚恶'}}
local arenas={{80,75,122,118},{10,78,48,120},{78,10,124,56},{12,10,48,44}}
local function integer(n,lo,hi,label)
    assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n
end
local function distance(p,xy) return (p.x-xy[1])^2+(p.y-xy[2])^2 end
local function byName(objects,name,living)
    local found
    for _,o in ipairs(objects) do
        if o.name==name and (not living or o.hp>0) then
            assert(not found,'同名目标不唯一：'..name);found=o
        end
    end
    return found
end
local function hostile(o) return o and o.class=='怪物' and o.hp>0 end
function Sijue.run(injected)
    local api=injected or DungeonApi.new();local cfg=TaskConfig or {}
    local rounds=integer(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=integer(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=integer(tonumber(cfg.dungeon_battle_seconds or 1800),30,3600,'战斗时限')*1000
    local team=integer(tonumber(cfg.dungeon_team_count or 3),3,6,'队伍人数')
    local mode=assert(modes[cfg.sjz_type or '普通'],'四绝庄难度无效')
    local def=setmetatable({enter={mode[1]},bosses={}}, {__index=def})
    for _,s in ipairs(stages) do def.bosses[#def.bosses+1]=s.name;if mode[2]~='' then def.bosses[#def.bosses+1]=s.name..mode[2] end end
    local radius=integer(tonumber(cfg.sijue_trap_distance or 4),2,10,'陷阱安全距离')
    for _,key in ipairs({'sijue_diagonal','sijue_columns','sijue_blind_share'}) do assert(cfg[key]==nil or type(cfg[key])=='boolean','四绝庄开关无效：'..key) end
    local bell=cfg.sijue_bell_role or '队长'
    assert(bell=='队长' or bell=='本角色' or bell=='其他队友','敲钟分工无效')
    local function bellOwner() return bell=='本角色' or bell=='队长' and api.isLeader() end
    local phase,completed='',0
    local function enter(p) if phase~=p then phase=p;api.log('四绝庄 · '..p) end end
    local function world() return assert(api.world(),'四绝庄场景不可读') end
    local function mission(id)
        local m=api.mission(def)
        if m then
            assert(m.status==0 or m.status==1,'四绝庄任务失败或状态无效')
            assert(not id or m.id==id,'四绝庄任务身份发生变化')
        end
        return m
    end
    local function wait(label,probe,ms)
        enter(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(ms or waitMs)
        error('四绝庄：'..label..'超时',0)
    end
    local function objects()
        local all=api.objects();assert(type(all)=='table' and #all<=512,'四绝庄对象列表不可读')
        local nearby={};local p=world()
        for _,o in ipairs(all) do if (o.x-p.x)^2+(o.y-p.y)^2<=45^2 then
            for _,stage in ipairs(stages) do
                for _,variant in pairs(modes) do
                    if variant[2]~='' and o.name==stage.name..variant[2] then
                        assert(variant==mode,'四绝庄首领后缀与所选难度不符：'..o.name)
                        local copy={};for k,v in pairs(o) do copy[k]=v end;o=copy;o.name=stage.name;break
                    end
                end
            end
            nearby[#nearby+1]=o
        end end
        return nearby
    end
    local nav=SijueMechanisms.new(api,radius);local arena=arenas[1]
    local function guide(point)
        wait('前往潘菁菁',function()
            nav.read();return not nav.move(point,arena)
        end,math.max(waitMs,45000))
        api.stop();api.openNpc({name='潘菁菁',x=point[1],y=point[2],scene=291})
    end
    local function move(point,label)
        if label then enter(label) end
        return nav.move(point,arena)
    end
    local function fight(m)
        local ctx=api.beginBattle(def,291);local start=api.now()
        local pet=DungeonPetGuard.new();local stoppedAttack=false
        local function releasePet()
            wait('恢复原珍兽出战',function()
                nav.read();if nav.escape(arena) then return false end
                return DungeonPetGuard.update(pet,false)
            end,45000)
        end
        local index,seen,deadReads,engaged=1,{},0,false
        local lastPosition=world()
        local npcIdentity,npcReads=nil,0
        local startSubmitted,transitionSubmitted=false,false
        local progressAt=api.now();local stageHp,stageIdentity=nil,nil
        local column,knownColumns=nil,{};local lastColumnAt=-10000
        local warned={}
        -- Resuming uses an observed boss identity; the first absent bosses do
        -- not generate fabricated death receipts.
        local all=objects()
        for i,s in ipairs(stages) do if byName(all,s.name,true) then index=i;break end end
        arena=arenas[index]
        enter('第 '..index..' 场 · '..stages[index].name)
        local function reset(nextIndex)
            index=nextIndex;seen={};deadReads=0;engaged=false;startSubmitted=false;transitionSubmitted=false
            arena=arenas[index];lastPosition=world()
            npcIdentity=nil;npcReads=0
            progressAt=api.now();stageHp=nil;stageIdentity=nil;ctx=api.beginBattle(def,291)
            column=nil;knownColumns={};lastColumnAt=-10000
            enter('第 '..index..' 场 · '..stages[index].name)
        end
        while true do
            assert(api.now()-start<battleMs,'四绝庄战斗超过时限')
            assert(def.inside(world()),'四绝庄任务未完成时离开副本')
            local current=assert(mission(m.id),'四绝庄战斗中任务记录消失')
            if current.status==1 then api.stop();releasePet();return end
            api.skipCinematic();all=objects();nav.read()
            local s=stages[index]
            arena=arenas[index]
            -- A positively observed later boss is a separate progression
            -- witness (important for followers and a resumed run).
            local later
            for i=index+1,4 do if byName(all,stages[i].name,true) then later=i;break end end
            local boss=byName(all,s.name,false)
            if later and not (boss and boss.hp>0) then reset(later);s=stages[index];arena=arenas[index];boss=byName(all,s.name,false) end
            local nextStage=false
            if boss then
                local identity=boss.id..':'..boss.server_id
                if stageIdentity and identity~=stageIdentity and hostile(boss) then
                    assert(not engaged,'四绝庄首领身份变化，停止核对：'..s.name)
                end
                if boss.class=='NPC' then
                    -- The reference explicitly treats the named friendly NPC
                    -- form as a passed arena. Require two matching snapshots;
                    -- this also supports a teammate's kill and a resumed run.
                    npcReads=npcIdentity==identity and npcReads+1 or 1;npcIdentity=identity
                    if npcReads>=2 then nextStage=true end
                elseif boss.hp>0 then
                    npcIdentity=nil;npcReads=0;stageIdentity=identity
                    seen[identity]=true;deadReads=0
                    if hostile(boss) then engaged=true end
                    if stageHp==nil or boss.hp<stageHp then stageHp=boss.hp;progressAt=api.now() end
                elseif seen[identity] then
                    deadReads=deadReads+1
                    if deadReads>=2 then nextStage=true end
                end
            else deadReads=0;npcIdentity=nil;npcReads=0 end
            if nextStage then
                api.stop()
                if index==4 then
                    wait('等待庞企结束后的任务完成状态',function() return assert(mission(m.id),'四绝庄任务记录消失').status==1 end)
                    releasePet();return
                end
                if not transitionSubmitted then
                    enter(s.name..'结束，前往下一场');guide(s.guide)
                    api.selectOption(beginKeys,false);transitionSubmitted=true;progressAt=api.now()
                end
                wait('等待下一首领出现',function()
                    assert(def.inside(world()),'转场时离开四绝庄')
                    assert(mission(m.id),'转场时任务记录消失')
                    local rows=objects();return byName(rows,stages[index+1].name,true)
                end)
                reset(index+1)
            elseif npcReads>0 then
                -- Do not submit a start/transition during the first friendly
                -- snapshot; confirm the NPC form on the next observation.
                api.maintain();api.sleep(500)
            else
                local busy=api.maintain();local own=api.buffs();local buffs=boss and boss.hp>0 and api.buffs(boss) or {}
                local messages=api.messages();local target,mechanism=nil,false
                local function suspend()
                    if not stoppedAttack then api.stopAttack();stoppedAttack=true end
                    if ctx.combat.id>=0 then ctx.combat=R.new(291,{boss_names=def.bosses}) end
                end
                -- Bell is an explicit assignment: other members wait/fight
                -- guards and must not each initiate another bell event.
                if index==1 and bellOwner() then target=byName(all,'四绝钟',true) end
                if target and not hostile(target) then target=nil end
                if index==2 then
                    if own['烛影摇红'] then
                        suspend()
                        local point=nav.spread()
                        if point then move(point,'秦韵 · 烛影摇红离开人群')
                        else enter('秦韵 · 等待无队友与陷阱覆盖的避让点') end
                        mechanism=true
                    else
                        local banners={};for _,o in ipairs(all) do if o.name=='回音幡' and o.hp>0 then banners[#banners+1]=o end end
                        if #banners>0 or api.hasMessage(messages,'#{SJZ_100129_50}') then
                            local safe,score
                            for _,point in ipairs({{41,87},cfg.sijue_diagonal and {16,114} or {16,87}}) do
                                local clear=true;for _,o in ipairs(banners) do if distance(o,point)<81 then clear=false end end
                                local d=distance(world(),point)
                                if clear and nav.safe(point) and (not score or d<score) then safe=point;score=d end
                            end
                            assert(safe,'回音幡覆盖了两处避让点，停止等待人工处理')
                            suspend()
                            move(safe,'秦韵 · 避让回音幡');mechanism=true
                        elseif cfg.sijue_blind_share and engaged and not api.hasMessage(messages,'#{SJZ_100129_51}') and nav.teamInArena() then
                            suspend();move({43,104},'秦韵 · 分担失明待命');mechanism=true
                        end
                    end
                end
                if index==3 or index==4 then
                    for _,name in ipairs(s.adds) do local o=byName(all,name,true);if hostile(o) then target=o;break end end
                    if engaged and not target and (buffs['青鹰的守护'] or buffs['天罡护体']) then
                        if ctx.combat.id>=0 then api.stop();ctx.combat=R.new(291,{boss_names=def.bosses}) end
                        mechanism=true;enter(s.name..' · 等待护体目标出现')
                    end
                end
                if index==4 and cfg.sijue_columns~=false then
                    for i=1,5 do
                        -- Original ADDI uses i+2: dictionary keys 73..77.
                        local key='#{SJZ_100129_'..(72+i)..'}';local active=api.hasMessage(messages,key)
                        if active and not knownColumns[key] then column=columns[i];lastColumnAt=api.now() end
                        knownColumns[key]=active
                    end
                    if column and api.now()-lastColumnAt<8000 then
                        suspend()
                        mechanism=true;move(column,'庞企 · 龙柱引导')
                    elseif buffs['四绝之怒'] and not target then
                        mechanism=true;enter('庞企 · 等待龙柱提示')
                    end
                end
                if mechanism then
                    suspend()
                    DungeonPetGuard.update(pet,true)
                else
                    local escaping,why=nav.escape(arena)
                    if escaping then
                        suspend();DungeonPetGuard.update(pet,true);enter('陷阱 · '..(why or '撤离危险范围'));mechanism=true
                    end
                end
                if not mechanism and not busy then
                    if not target then
                        for _,name in ipairs(s.adds) do
                            local o=byName(all,name,true)
                            if (name~='四绝钟' or bellOwner()) and hostile(o) then target=o;break end
                        end
                    end
                    if not target and hostile(boss) then target=boss end
                    if target then
                        if not nav.clear(world(),target) then
                            suspend();DungeonPetGuard.update(pet,true)
                            if nav.safe({target.x,target.y}) then move({target.x,target.y},'陷阱 · 绕行至战斗目标')
                            else enter('陷阱 · 等待目标离开危险范围') end
                        elseif not DungeonPetGuard.update(pet,false) then suspend()
                        elseif R.canAttack() then stoppedAttack=false;R.selectOriginalTarget(ctx.combat,target.id);R.step(ctx.combat)
                        else api.maintain() end
                    elseif not engaged and not startSubmitted and api.isLeader() then
                        local point=index==1 and s.start or stages[index-1].guide
                        enter('准备 '..s.name);guide(point)
                        api.selectOption(beginKeys,false);startSubmitted=true;progressAt=api.now()
                    elseif not boss then
                        -- Re-query objects while moving to the actual arena;
                        -- no absent-target success and no repeated start click.
                        move(s.center)
                    end
                end
                local actual=world()
                if (actual.x-lastPosition.x)^2+(actual.y-lastPosition.y)^2>0.25 then progressAt=api.now();lastPosition=actual end
                assert(api.now()-progressAt<(engaged and 120000 or waitMs),
                    s.name..'阶段没有进展；未重复开怪或将目标消失记为击杀')
                if not R.canAttack() and not warned.support then
                    warned.support=true;api.log('四绝庄按峨嵋只治疗策略运行，等待队友推进首领阶段')
                end
                api.sleep(500)
            end
        end
    end
    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            enter('检查任务与准备');local m=mission()
            assert(m or not def.inside(world()),'四绝庄内没有对应任务')
            if not m then
                api.space();api.prepareBattle();api.openNpc(def.npc)
                if api.limit(def) then return {status='limit_reached',message='NPC 确认四绝庄已达上限；本次完成 '..completed..' 轮'} end
                wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() end)
                if api.isLeader() then api.accept(def) end
                m=wait('等待四绝庄任务',function() local v=mission();if not v then api.acceptShared(def) end;return v end)
            end
            if m.status==0 then
                api.prepareBattle()
                if not def.inside(world()) then
                    api.openNpc(def.npc);wait('等待入场队伍',function() return api.teamReady(team) and api.teamTogether() end)
                    if api.isLeader() then
                        if not api.selectOption(def.enter,true) then
                            api.selectOption(def.accept,false)
                            wait('等待'..(cfg.sjz_type or '普通')..'四绝庄入场选项',function() return api.selectOption(def.enter,true) end)
                        end
                    end
                    wait('等待进入四绝庄',function() api.acceptShared(def);return def.inside(world()) end)
                end
                fight(m)
            end
            assert(assert(mission(m.id),'四绝庄交付前任务消失').status==1,'四绝庄任务尚未完成')
            if def.inside(world()) then
                enter('离开四绝庄');guide(stages[4].guide)
                api.selectOption({'#{SJZ_100129_120}'},false)
                wait('确认离开四绝庄',function() return world().scene==1 end)
            end
            enter('返回潘菁菁交付');api.openNpc(def.npc);api.space()
            assert(assert(mission(m.id),'交付前任务记录消失').status==1,'交付前任务状态变化')
            api.turnIn(def);wait('确认四绝庄交付',function() return not mission(m.id) end)
            assert(world().scene==1,'四绝庄交付后未返回苏州')
            completed=completed+1;enter('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='四绝庄完成 '..completed..' 轮；任务已交付，角色已返回苏州'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stop)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'四绝庄停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
Sijue.definition=def
Sijue.stages=stages
