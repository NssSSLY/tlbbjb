-- 楚汉之战 battleground, written from the reference rules (原脚本源码/Script64/活动/楚汉之战.lua). Same shape as 弈决山河, plus camps and monsters.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/ACTIVITY_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Chuhan={}
local entrance={name='苏星河',x=88,y=210,scene=1075}
local QUEUE_MS=600000
local KEYS={'XQPVP_260526_12'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Chuhan.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'场数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    for _,k in ipairs({'chuhan_leave_team','chuhan_claim'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','楚汉之战开关无效：'..k) end
    local def={name='楚汉之战',mission='楚汉之战',map='楚河汉界',npc=entrance,bosses={}}
    function def.inside(p) return p.map:find('楚河汉界',1,true)~=nil end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('楚汉之战 · '..s) end end
    local function world() return assert(api.world(),'楚汉之战场景不可读') end
    local function ui(code) GetLuaValue('-- chuhan:ui\n'..code,'',0) end
    local function inBattle(p) return p.map:find('楚河汉界',1,true)~=nil end
    local function inCamp(p) return p.map:find('驻扎营地',1,true)~=nil end

    local function fight()
        local scene=world().scene
        local T=DungeonTactics.new(api,scene,{})
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local start,lastGhost,lastTalk=api.now(),-100000,-100000
        while true do
            local p=world()
            if not inBattle(p) or p.scene~=scene then return end
            assert(api.now()-start<battleMs,'楚汉之战战斗超过时限')
            api.skipCinematic()
            local hp=GetLuaValue("-- chuhan:hp\nreturn Player:GetData('HP')",'n')
            if type(hp)=='number' and hp<=0 then
                -- Death is normal here. The reference leaves through the battleground's own relive panel.
                log('已死亡，等待回到战场')
                if api.now()-lastGhost>=3000 then
                    lastGhost=api.now()
                    ui("local e=Relive_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.Relive_Out_Ghost() end")
                end
            else
                local own=api.buffs()
                local han,chu=T.hasBuff(own,'汉营'),T.hasBuff(own,'楚营')
                local all=T.rows()
                -- Behind one's own gate the messenger sends the player out.
                local messenger=T.best(all,'传令兵')
                if messenger and api.now()-lastTalk>=8000 then
                    local hanGate,chuGate=T.best(all,'汉营大门'),T.best(all,'楚营大门')
                    if (han and hanGate and hanGate.x>=p.x) or (chu and chuGate and chuGate.x<=p.x) then
                        lastTalk=api.now();log('传令兵 · 出营')
                        if pcall(api.openNpc,{name='传令兵',x=math.floor(messenger.x),y=math.floor(messenger.y),scene=scene}) then
                            api.sleep(500);api.selectOption({'#{XQPVP_260526_139}'},true);api.sleep(800)
                        end
                        if world().scene==scene then CloseAllWindow() end
                        p=world()
                    end
                end
                if p.scene==scene and inBattle(p) then
                    local best
                    for _,o in ipairs(T.enemyPlayers()) do if o.hp~=0 and (not best or o.dst<best.dst) then best=o end end
                    if best then
                        if best.dst>(melee and 3 or 15) then log('追击敌人');T.move(math.floor(best.x),math.floor(best.y))
                        else log('战斗');T.clearMove();T.strikePlayer(best) end
                    else
                        local mob
                        for _,o in ipairs(all) do if T.enemy(o) and (not mob or o.dst<mob.dst) then mob=o end end
                        if mob then log('打怪');T.attack(mob)
                        else log('前往对方营地');T.stop();if han then T.move(262,95) else T.move(55,95) end end
                    end
                end
            end
            api.maintain();api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        while completed<rounds do
            local p=world()
            local started=inBattle(p) or inCamp(p)
            if not started then
                if GetTeamCount()>0 then
                    if cfg.chuhan_leave_team~=true then error('楚汉之战：角色在队伍中，未打开“允许自动退队”，已停止',0) end
                    log('退出队伍');ui("if Player:IsInTeam()==1 then Player:LeaveTeam() end");api.sleep(1000)
                end
                api.openNpc(entrance);api.sleep(500)
                local T=DungeonTactics.new(api,entrance.scene,{});T.watch(KEYS);T.readMessages()
                assert(api.selectOption({'#{XQPVP_260526_03}'},true),'苏星河没有楚汉之战报名选项，活动可能未开放')
                api.sleep(1500);T.readMessages();CloseAllWindow()
                if T.seenAt['XQPVP_260526_12'] then
                    -- The reference's "nothing left today": hand in what the rounds earned.
                    if cfg.chuhan_claim~=false then
                        log('领取奖励')
                        if pcall(api.openNpc,entrance) then
                            api.sleep(500);api.selectOption({'#{XQPVP_260526_04}'},true);api.sleep(800)
                            api.selectOption({'#{XQPVP_260526_05}'},true);api.sleep(800)
                        end
                        CloseAllWindow()
                    end
                    return {status=completed>0 and 'done' or 'already_done',message='楚汉之战：今日次数已用完；本次完成 '..completed..' 场'}
                end
            end
            log('排队等待进入战场')
            local began=api.now()
            while not inBattle(world()) do
                assert(api.now()-began<QUEUE_MS,'楚汉之战：报名后 10 分钟没有进入战场，未重复报名')
                api.maintain();api.sleep(1000)
            end
            fight();completed=completed+1;log('本场完成（'..completed..'）')
        end
        return {status='done',message='楚汉之战完成 '..completed..' 场；已离开战场'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'楚汉之战停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
