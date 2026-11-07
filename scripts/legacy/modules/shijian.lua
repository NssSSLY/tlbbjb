-- 拭剑天下 arena, written from the reference rules (原脚本源码/Script64/常用/拭剑天下.lua).
-- This task owns its stages and receipts; it does not load the vendor framework. docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Shijian={}
local ARENAS={[1019]=true,[974]=true,[1074]=true}
local QUEUE_MS=600000
local ROOMS={{5,67,5,67,36,14},{97,162,5,67,132,14},{187,253,5,67,219,14},{5,66,101,157,36,107},{97,162,101,157,132,107},{187,253,101,157,219,107},{5,66,187,253,36,197},{97,162,187,253,132,197},{187,253,187,253,219,197}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Shijian.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'总时限')*1000
    local level=DungeonTactics.level(api)
    local npc
    if level>=120 then npc={name='周叔彬',x=183,y=102,scene=2}
    elseif level>=90 then npc={name='周伯衡',x=296,y=225,scene=0}
    elseif level>=70 then npc={name='周仲青',x=293,y=229,scene=1}
    elseif level>=60 then npc={name='周颐真',x=185,y=98,scene=2}
    else error('拭剑天下：等级 '..math.floor(level)..' 不符合，需要 60 级以上',0) end
    local def={name='拭剑天下',mission='拭剑天下',map='擂台',npc=npc,bosses={}}
    function def.inside(p) return ARENAS[p.scene]==true end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('拭剑天下 · '..s) end end
    local function world() return assert(api.world(),'拭剑天下场景不可读') end
    local function inRoom(p) return p.map:find('休息室',1,true)~=nil end
    local school=api.school()
    local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
    local function pick(T)
        local best,score
        for _,o in ipairs(T.enemyPlayers()) do
            if o.hp~=0 then
                local invincible,magnified=T.playerState(o)
                if not invincible then
                    -- The reference's order: magnified first, then low health, then nearest.
                    local s=(magnified and 0 or 2000)+((o.hp>0 and o.hp<30) and 0 or 1000)+o.dst
                    if not score or s<score then best,score=o,s end
                end
            end
        end
        return best
    end
    local function fight(endAt)
        local scene=world().scene
        local T=DungeonTactics.new(api,scene,{});T.watch({'SCGZ_180816_47'});T.readMessages()
        while true do
            T.readMessages()
            local p=world()
            if p.scene~=scene then return end
            assert(api.now()<endAt,'拭剑天下超过总时限')
            local hp=GetLuaValue("-- shijian:hp\nreturn Player:GetData('HP')",'n')
            if type(hp)=='number' and hp<=0 then log('已死亡，等待本局结束');T.clearMove()
            elseif T.within('SCGZ_180816_47',35000) or T.hasBuff(api.buffs(),'战斗准备') then log('等待开战');T.stop()
            else
                local t=pick(T)
                if t then
                    if t.dst>(melee and 5 or 12) then log('追击敌人');T.move(math.floor(t.x),math.floor(t.y))
                    else log('战斗');T.clearMove();T.strikePlayer(t) end
                else log('等待对手');T.stop() end
            end
            if world().scene==scene then api.maintain() end
            api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        local fired=DungeonTactics.prompts(api,{'BWDH_180804_66'})
        local endAt=api.now()+battleMs
        local inside,clicked=false,false
        local began=api.now()
        while true do
            assert(api.now()<endAt,'拭剑天下超过总时限')
            local p=world()
            if inRoom(p) then
                inside=true;began=api.now();log('休息室')
                if fired('BWDH_180804_66') then
                    log('比赛结束，离开休息室');local spot
                    for _,r in ipairs(ROOMS) do if p.x>=r[1] and p.x<=r[2] and p.y>=r[3] and p.y<=r[4] then spot=r end end
                    if spot and pcall(api.openNpc,{name='擂台指引使',x=spot[5],y=spot[6],scene=p.scene}) then
                        api.sleep(500);api.selectOption({'#{BWDH_180804_71}'},true);api.sleep(800)
                        api.selectOption({'#{BWDH_180804_71}'},true);api.sleep(800)
                    end
                    if world().scene==p.scene then CloseAllWindow() end
                    api.sleep(3000)
                end
                api.maintain();api.sleep(1000)
            elseif ARENAS[p.scene] then
                inside=true;fight(endAt);began=api.now()
            elseif inside then
                return {status='done',message='拭剑天下结束；已离开擂台'}
            elseif not clicked then
                clicked=true
                api.openNpc(npc);api.sleep(800)
                assert(QuestFrameOptionClicked('#{BWDH_180804_11',0),npc.name..'没有拭剑天下报名选项，活动可能未开放')
                api.sleep(2000);CloseAllWindow();log('排队等待进入');began=api.now()
            else
                assert(api.now()-began<QUEUE_MS,'拭剑天下：报名后 10 分钟没有进入，未重复报名')
                api.maintain();api.sleep(1000)
            end
        end
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'拭剑天下停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
