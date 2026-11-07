-- Reference 002fbdb4: two distinct missions, Suzhou -> Yannan -> prison -> Yannan -> Suzhou.
LoadScript('dungeon_api')
WaterPrison={}
local outer={name='平定水牢',mission='帮助平定水牢叛乱',map='水牢',
    npc={name='呼延豹',x=342,y=311,scene=1},accept={'帮助平定水牢叛乱'},turnin={'帮助平定水牢叛乱'}}
local inner={name='水牢',mission='水牢',map='水牢',
    npc={name='呼延庆',x=67,y=77,scene=4},accept={'水牢'},turnin={'水牢'}}
function outer.inside(p) return p.scene==66 or p.map=='水牢' end
inner.inside=outer.inside
local route={{41,83},{40,48},{70,41},{108,41},{142,41},{153,70},{152,109},{152,143},{118,151},{83,149},{48,149},{41,120}}
for i,p in ipairs(route) do route[i]={x=p[1],y=p[2]} end
local function integer(n,lo,hi,name) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,name..'无效');return n end
function WaterPrison.run(injected)
    local api=injected or DungeonApi.new()
    local cfg=TaskConfig or {}
    local rounds=integer(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=integer(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=integer(tonumber(cfg.dungeon_battle_seconds or 1200),30,3600,'战斗时限')*1000
    local team=integer(tonumber(cfg.dungeon_team_count or 3),3,6,'队伍人数')
    local phase,completed='',0
    local function enter(p) if phase~=p then phase=p;api.log('水牢 · '..p) end end
    local function world() return assert(api.world(),'水牢场景不可读') end
    local function mission(def,id)
        local m=api.mission(def)
        if m then
            assert(m.status==0 or m.status==1,def.mission..'任务失败或状态无效')
            assert(not id or m.id==id,def.mission..'任务身份发生变化')
        end
        return m
    end
    local function wait(p,probe,ms)
        enter(p);local started=api.now()
        repeat local v=probe();if v then return v end;api.sleep(250) until api.now()-started>=(ms or waitMs)
        error('水牢：'..p..'超时',0)
    end
    local function body()
        api.validate(outer,cfg)
        for _=1,rounds do
            enter('检查两段任务')
            local m,n=mission(outer),mission(inner)
            assert(m or not n,'有水牢任务但没有帮助平定水牢叛乱，请先核对任务记录')
            assert(m or not outer.inside(world()),'副本内没有对应任务')
            if not m then
                enter('准备战斗');api.space();api.prepareBattle()
                assert(Bag:GetItemCount('水牢令牌')>0,'背包缺少水牢令牌，请准备后运行')
                if api.isLeader() then
                    api.openNpc(outer.npc)
                    if api.limit(outer) then return {status='limit_reached',message='NPC 确认水牢已达上限；本次已完成 '..completed..' 轮'} end
                    wait('等待队伍',function() return api.teamReady(team) end)
                    enter('接取外层任务');api.accept(outer)
                end
                m=wait('等待外层任务',function() local current=mission(outer);if not current then api.acceptShared(outer) end;return current end)
            end
            if m.status==0 then
                enter('准备战斗');api.prepareBattle()
                n=mission(inner)
                if not n or n.status==0 then
                    if not outer.inside(world()) then
                        if not n then assert(Bag:GetItemCount('水牢令牌')>0,'背包缺少水牢令牌，未提交入场') end
                        api.openNpc(inner.npc)
                        wait('等待队伍集合',function() return api.teamReady(team) end)
                        if api.isLeader() then
                            enter('接取水牢与入场')
                            api.enterMission(inner)
                        end
                        wait('等待水牢任务与入场',function()
                            api.acceptShared(inner);n=mission(inner,n and n.id)
                            return n and outer.inside(world())
                        end)
                    end
                    n=assert(mission(inner,n and n.id),'水牢内缺少任务记录')
                    local ctx=api.beginBattle(outer,world().scene)
                    local started=api.now()
                    while n.status==0 do
                        assert(outer.inside(world()) and world().scene==ctx.scene,'水牢任务未完成时离开副本')
                        assert(mission(outer,m.id),'外层任务记录消失')
                        local busy=api.maintain()
                        enter('巡点战斗')
                        api.fight(outer,{key='prison',name='平定水牢',route=route,signature=n.desc},ctx,busy)
                        assert(api.now()-started<battleMs,'水牢战斗超过时限')
                        api.sleep(500)
                        n=assert(mission(inner,n.id),'水牢任务记录消失')
                    end
                    api.stop()
                end
                n=assert(mission(inner,n and n.id),'内层任务尚未交付但记录消失')
                assert(n.status==1,'水牢任务尚未完成')
                if outer.inside(world()) then
                    enter('走到水牢出口')
                    -- A portal changes the map before MoveTo can confirm an
                    -- arrival on the old map. Submit once, then observe exit.
                    CombatRuntime.call(CombatRuntime.codes.RunTo,{world().scene},{95,95})
                    wait('等待离开水牢',function() return world().scene==4 end)
                end
                assert(world().scene==4,'交付水牢前不在雁南')
                enter('交付水牢任务');api.openNpc(inner.npc)
                local check=assert(mission(inner,n.id),'交付前水牢任务消失');assert(check.status==1,'交付前水牢状态变化')
                api.space();api.turnIn(inner)
                wait('确认内层交付及外层完成',function()
                    assert(not mission(inner,n.id),'内层交付后任务仍在')
                    local current=assert(mission(outer,m.id),'外层任务记录消失')
                    return current.status==1 and current
                end)
            else
                assert(not n,'外层已完成但仍有内层任务，请核对记录')
            end
            enter('返回苏州交付');api.openNpc(outer.npc)
            local check=assert(mission(outer,m.id),'外层交付前任务记录消失');assert(check.status==1,'外层任务未完成')
            api.space();api.turnIn(outer)
            wait('确认外层交付',function() return not mission(outer,m.id) end)
            assert(not mission(inner) and world().scene==1,'水牢交付后的场景或任务状态不符')
            completed=completed+1;enter('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='水牢已完成 '..completed..' 轮；两段任务已交付，角色已返回苏州'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stop)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'水牢停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
WaterPrison.definitions={outer=outer,inner=inner,route=route}
