-- A dungeon owns its rules; the adapter owns game calls. No vendor globals are merged.
DungeonFlow={}
local function integer(n,lo,hi,label)
    assert(type(n)=="number" and n==math.floor(n) and n>=lo and n<=hi,label.."无效")
    return n
end
function DungeonFlow.run(def,cfg,api)
    local rounds=integer(tonumber(cfg.dungeon_rounds or 1),1,20,"副本轮数")
    local timeout=integer(tonumber(cfg.dungeon_wait_seconds or 45),5,180,"状态等待秒数")*1000
    local battleTimeout=integer(tonumber(cfg.dungeon_battle_seconds or 1200),30,3600,"战斗超时秒数")*1000
    local team=integer(tonumber(cfg.dungeon_team_count or cfg["老三环"] or 3),0,6,"队伍人数")
    team=math.max(3,team)
    -- 队长等队员接任务 / 准备：一直对话重试，直到进入副本；超过这个时长才放弃本项，让任务列表继续。
    local patience=integer(tonumber(cfg.dungeon_team_wait_seconds or 180),30,900,"等待队员秒数")*1000
    local phase,completed="",0
    local function enter(name)
        if phase~=name then phase=name;api.log(def.name.." · "..name) end
    end
    local function wait(name,probe,ms)
        enter(name)
        local start=api.now()
        repeat
            local value=probe()
            if value then return value end
            api.sleep(250)
        until api.now()-start>=(ms or timeout)
        error(def.name.."："..name.."超时",0)
    end
    local function mission(identity)
        local m=api.mission(def)
        if m then
            -- 3: this character entered once and left. Inside it is still in progress; outside it is the reference's "放弃后重接".
            assert(m.status==0 or m.status==1 or ((m.status==3 or m.status==2) and def.redo),def.name.."：任务失败或状态无效（"..tostring(m.status).."）")
            assert(not identity or m.id==identity,def.name.."：任务身份发生变化")
        end
        return m
    end
    local function outside() local w=api.world();return w and not def.inside(w) and w end
    local function turnIn(m)
        if def.inside(assert(api.world(),"场景不可读")) then
            if def.afterComplete then enter("拾取包裹");def.afterComplete(api) end
            enter("离开副本");api.leave(def,m)
            wait("等待离场",outside)
        end
        enter("交付任务");api.openNpc(def.npc)
        local current=mission(m.id)
        assert(current and current.status==1,def.name.."：交付前完成状态已变化")
        api.space()
        api.turnIn(def)
        wait("等待任务交付",function() return mission(m.id)==nil end)
        assert(outside(),def.name.."：交付后仍在副本")
        completed=completed+1
        enter("本轮完成（"..completed.."/"..rounds.."）")
    end
    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            enter("检查任务")
            local w=assert(api.world(),"当前场景不可读")
            local m=mission()
            if not m and def.inside(w) then error(def.name.."：副本内没有对应任务，请先确认任务记录",0) end
            -- Failed, or walked out of earlier: the mission has to be dropped and taken again.
            if m and (m.status==2 or (m.status==3 and not def.inside(w))) then
                if cfg.dungeon_abandon~=true then error(def.name.."：任务已失败或中途离开过副本，要重接请打开“允许放弃任务”",0) end
                enter("放弃任务重接")
                GetLuaValue(string.format("-- dungeon:abandon\nQuestFrameMissionAbnegate(DataPool:GetPlayerMission_Display(%d,7))",m.slot),'',0)
                wait("等待放弃确认",function() return mission()==nil end)
                m=nil
            end
            if not m then
                enter("接取任务");api.openNpc(def.npc)
                -- The NPC may already have today's terminal state. No bag inspection is used as evidence.
                if api.limit(def) then
                    return {status="limit_reached",message=def.name.."：NPC 提示今日次数已用完；本次完成 "..completed.." 轮"}
                end
                api.space()
                enter("准备战斗");api.prepareBattle()
                enter("接取任务")
                api.accept(def) -- submit once, then only query until the mission exists
                m=wait("等待接取确认",function() return mission() end)
            end
            if m.status~=1 then
                enter("准备战斗");api.prepareBattle()
                if not def.inside(assert(api.world(),"场景不可读")) then
                    enter("等待队伍")
                    wait("等待队伍",function() return api.teamReady(team) end,patience)
                    local function insideNow() local p=api.world();return p and def.inside(p) and p end
                    if api.isLeader() then
                        -- 队员没接任务或没准备好时 NPC 不放行：隔几秒再对话一次，直到进入。
                        local began,tries=api.now(),0
                        while not insideNow() do
                            tries=tries+1
                            enter(tries==1 and "进入副本" or "等待队员接任务 / 准备（第 "..tries.." 次对话）")
                            local okTalk,why=pcall(function() api.openNpc(def.npc);api.enter(def) end)
                            if not okTalk and tries==1 then api.log(def.name.."：进入对话未成功，继续重试："..tostring(why)) end
                            local t=api.now()
                            repeat if insideNow() then break end api.sleep(250) until api.now()-t>=6000
                            if not insideNow() then
                                assert(api.now()-began<patience,def.name.."：已等待 "..math.floor(patience/1000).." 秒，队员仍未接任务或未准备好，跳过本项")
                            end
                        end
                    end
                    wait("等待进入副本",insideNow,patience)
                end
                local inside=assert(api.world(),"副本场景不可读")
                local scene=inside.scene
                local start=api.now()
                local context=api.beginBattle(def,scene)
                enter("战斗")
                while true do
                    local p=api.world()
                    if p then
                        assert(def.inside(p) and p.scene==scene,def.name.."：任务未完成时已离开副本")
                        local current=assert(mission(m.id),def.name.."：战斗中任务记录消失")
                        if current.status==1 then m=current;break end
                        local supportBusy=api.maintain()
                        local stage=api.progress(def,current,context)
                        if stage then
                            enter("战斗 · "..stage.name)
                            api.fight(def,stage,context,supportBusy)
                        end
                    end
                    assert(api.now()-start<battleTimeout,def.name.."：战斗超时，当前阶段："..phase)
                    api.sleep(500)
                end
                api.stop()
            end
            turnIn(m)
        end
        return {status="done",message=def.name.."：已交付 "..completed.." 轮任务，角色已离开副本"}
    end
    local ok,result=pcall(body)
    -- Cleanup must not hide the phase and cause of the primary failure.
    local cleaned,why=pcall(api.stop)
    if not ok then error(tostring(result).." [阶段："..phase.."]",0) end
    assert(cleaned,"副本结束停止动作失败："..tostring(why))
    return result
end
