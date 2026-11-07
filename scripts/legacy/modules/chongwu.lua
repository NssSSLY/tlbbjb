-- 崇武试炼, written from the reference rules (原脚本源码/Script64/常用/崇武试炼.lua). The school master sends the player in; three trial bosses at the centre.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Chongwu={}
local CENTRE={95,66}
local BOSS={['乔峰·试炼']=true,['段誉·试炼']=true,['虚竹·试炼']=true}
local QUEUE_MS=600000
local MASTERS={[0]={'玄寂',91,72,9},[1]={'吕师襄',107,56,11},[2]={'陈孤雁',91,100,10},[3]={'张玄素',77,87,12},[4]={'李十二娘',95,53,15},[5]={'韩世忠',95,76,16},[6]={'本因',95,68,13},[7]={'梅剑',91,45,17},[8]={'苏星河',124,144,14},
    [10]={'慕容杰',49,144,284},[11]={'唐亦风',77,36,615},[12]={'王禅一',99,58,678},[13]={'君还珠',205,72,731},[14]={'行严',255,167,824},[15]={'段延庆',157,57,987}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Chongwu.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'场数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local school=api.school()
    local m=MASTERS[school]
    if not m then error('崇武试炼：门派 '..tostring(school)..' 没有已知的报名 NPC',0) end
    local entrance={name=m[1],x=m[2],y=m[3],scene=m[4]}
    local names={};for n in pairs(BOSS) do names[#names+1]=n end
    local def={name='崇武试炼',mission='崇武试炼',map='崇武试炼',npc=entrance,bosses=names}
    function def.inside(p) return p.map=='崇武试炼' end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('崇武试炼 · '..s) end end
    local function world() return assert(api.world(),'崇武试炼场景不可读') end
    local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
    local fired=DungeonTactics.prompts(api,{'ZMB_230124_137'})
    local function fight()
        local scene=world().scene
        local T=DungeonTactics.new(api,scene,names)
        local start,lastProgress,hps,quiet=api.now(),api.now(),{},nil
        while true do
            local p=world()
            if p.scene~=scene or p.map~='崇武试炼' then return true end
            assert(api.now()-start<battleMs,'崇武试炼战斗超过时限')
            api.alive(minimum,'崇武试炼：角色血量低于停止阈值，自动复活未接入，已停止')
            local boss,npc
            for _,o in ipairs(T.rows()) do
                if BOSS[o.name] then
                    if T.enemy(o) then
                        if not boss or o.dst<boss.dst then boss=o end
                        if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;lastProgress=api.now() end
                    elseif o.hp>0 then npc=o end
                end
            end
            if boss then
                quiet=nil
                local traps=T.traps()
                if T.escape(traps,6,CENTRE[1],CENTRE[2],15,4) then log('躲陷阱');T.stop();lastProgress=api.now()
                elseif #traps>0 and melee and boss.dst>=3 then log('有陷阱，近战等待');T.stop()
                elseif boss.dst>15 then log('靠近 '..boss.name);T.stop();T.move(math.floor(boss.x),math.floor(boss.y))
                else log(boss.name..' · 战斗');T.attack(boss) end
            elseif npc then
                quiet=nil;log('等待开始');T.stop();lastProgress=api.now()
            else
                -- Nothing standing for a moment: this bout is over, whatever the game does with the player next.
                quiet=quiet or api.now();T.stop()
                if api.now()-quiet>=4000 then return false end
            end
            api.maintain()
            local q=world()
            if q.scene==scene and (not hps.px or (q.x-hps.px)^2+(q.y-hps.py)^2>0.25) then hps.px,hps.py=q.x,q.y;lastProgress=api.now() end
            assert(api.now()-lastProgress<180000,'崇武试炼阶段没有进展：'..phase)
            api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        while completed<rounds do
            local p=world()
            if p.map~='崇武试炼' and p.map~='崇武试炼休息室' then
                if fired('ZMB_230124_137') then break end
                api.openNpc(entrance);api.sleep(500)
                local a=api.selectOption({'崇武试炼'},true);api.sleep(800)
                local b=api.selectOption({'前往参与'},true);api.sleep(800);CloseAllWindow()
                if not (a and b) then
                    if completed>0 then break end
                    return {status='already_done',message='崇武试炼：'..entrance.name..'没有报名选项，活动可能未开放或已结束'}
                end
            end
            log('等待进入试炼')
            local began=api.now()
            while world().map~='崇武试炼' do
                if fired('ZMB_230124_137') then return {status=completed>0 and 'done' or 'already_done',message='崇武试炼结束；本次完成 '..completed..' 场'} end
                if api.now()-began>=QUEUE_MS then
                    if completed>0 then return {status='done',message='崇武试炼完成 '..completed..' 场；之后 10 分钟没有再开始'} end
                    error('崇武试炼：报名后 10 分钟没有进入试炼，未重复报名',0)
                end
                api.maintain();api.sleep(1000)
            end
            fight();completed=completed+1;log('本场完成（'..completed..'）')
            -- A finished bout may send the player out, or back to the rest room; give the game a moment.
            local waitOut=api.now()
            while world().map=='崇武试炼' and api.now()-waitOut<math.max(waitMs,60000) do
                if fired('ZMB_230124_137') then break end
                api.maintain();api.sleep(1000)
            end
            if fired('ZMB_230124_137') then break end
            if world().map=='崇武试炼' then return {status='done',message='崇武试炼完成 '..completed..' 场；仍在试炼场景内'} end
        end
        return {status=completed>0 and 'done' or 'already_done',message='崇武试炼结束；本次完成 '..completed..' 场'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'崇武试炼停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
