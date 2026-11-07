-- 天龙幻境, written from the reference rules (原脚本源码/Script64/副本/天龙幻境.lua). A mission with 240 kills in eight rings.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/SMALL_DUNGEONS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Tianlong={}
local SCENE=300
local entrance={name='浮生',x=171,y=120,scene=246}
local CENTRE={x=64,y=57}
local POS={[0]={63,31},[1]={87,40},[2]={97,64},[3]={87,87},[4]={63,97},[5]={40,87},[6]={30,64},[7]={40,40},[8]={64,57}}
local KEYS={'/240','TLHJ_120110_39','TLHJ_120110_42'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Tianlong.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='天龙幻境',mission='#{TLHJ_120110_62}',map='天龙幻境',npc=entrance,bosses={}}
    function def.inside(p) return p.scene==SCENE end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('天龙幻境 · '..s) end end
    local function world() return assert(api.world(),'天龙幻境场景不可读') end
    local function isLead() return GetTeamCount()==0 or api.isLeader() end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('天龙幻境：'..label..'超时',0)
    end
    local function tokens()
        local n=GetLuaValue([[-- tianlong:tokens
            local c=0
            for i=0,DataPool:GetBaseBag_Num()-1 do local a=PlayerPackage:EnumItem('base',i)
                if a and a:GetID()~=0 and a:GetName()=='试炼令牌' then c=c+a:GetNum() end end
            return c]],'n')
        assert(type(n)=='number','背包不可读');return n
    end
    local function fight()
        local T=DungeonTactics.new(api,SCENE,{});T.watch(KEYS);T.readMessages()
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local start,lastProgress,hps,startTalk,leaves,lastLeave=api.now(),api.now(),{},nil,0,-100000
        local function stepNow()
            local line=T.lastLine['/240'] or ''
            local n=tonumber(line:match('已杀 (%d+)/240'))
            if n then
                if n>=239 then return 8 end
                return math.floor(n/30)
            end
            if T.seenAt['TLHJ_120110_39'] or T.seenAt['TLHJ_120110_42'] then return 0 end
            return -1
        end
        while true do
            if T.readMessages() then lastProgress=api.now() end
            local p=world()
            if p.scene~=SCENE then return end
            assert(api.now()-start<battleMs,'天龙幻境战斗超过时限')
            api.alive(minimum,'天龙幻境：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            local mob
            for _,o in ipairs(T.rows()) do
                if T.enemy(o) then
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;lastProgress=api.now() end
                    -- Ranged spread damage over full-health mobs; melee takes the nearest.
                    if not mob or (melee and o.dst<mob.dst) or (not melee and ((o.hp>=100 and mob.hp<100) or (o.hp>=100)==(mob.hp>=100) and o.dst<mob.dst)) then mob=o end
                end
            end
            if mob then
                log('战斗')
                if not melee and mob.dst>15 then T.stop();T.move(math.floor(mob.x),math.floor(mob.y)) else T.attack(mob) end
            else
                T.stop()
                local m=api.mission(def)
                if m and m.status==1 then
                    if api.now()-lastLeave>=6000 and leaves<3 then
                        log('若梦 · 离开')
                        if not T.move(CENTRE.x,CENTRE.y) then
                            lastLeave=api.now();leaves=leaves+1;CloseAllWindow();TalkNpc('若梦');api.sleep(800)
                            api.selectOption({'#{TLHJ_120110_30}'},true);api.sleep(800)
                            api.selectOption({'#{INTERFACE_XML_557}'},true);api.sleep(800);CloseAllWindow()
                        end
                    elseif leaves>=3 then
                        assert(api.now()-lastLeave<math.max(waitMs,60000),'天龙幻境：离开选项发出后仍在副本内，不再重复')
                    end
                else
                    local step=stepNow()
                    if step==-1 then
                        if isLead() then
                            if not startTalk then
                                log('若梦 · 开始')
                                if not T.move(CENTRE.x,CENTRE.y) then
                                    startTalk=api.now();CloseAllWindow();TalkNpc('若梦');api.sleep(800)
                                    api.selectOption({'#{TLHJ_120110_29}'},true);api.sleep(800)
                                    api.selectOption({'#{TLHJ_120110_34}'},true);api.sleep(800);CloseAllWindow();lastProgress=api.now()
                                end
                            else
                                assert(api.now()-startTalk<math.max(waitMs,60000),'天龙幻境：开始后没有反馈，不重复对话')
                            end
                        else step=0 end
                    end
                    local q=POS[step]
                    if q then log('第 '..step..' 波位置');T.move(q[1],q[2]) end
                end
            end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or (q.x-hps.px)^2+(q.y-hps.py)^2>0.25) then hps.px,hps.py=q.x,q.y;lastProgress=api.now() end
            assert(api.now()-lastProgress<180000,'天龙幻境阶段没有进展：'..phase)
            api.sleep(250)
        end
    end
    local function body()
        api.validate(def,cfg)
        local inside=world().scene==SCENE
        local m=api.mission(def)
        if not inside and not m then
            -- Mission first; the reference treats the board's refusal as "nothing left today".
            api.openNpc(entrance);api.sleep(500)
            local clicked=api.selectOption({'#{TLHJ_120110_62}'},true)
            if not clicked then CloseAllWindow();return {status='already_done',message='天龙幻境：浮生没有任务选项，今日可能已完成'} end
            api.sleep(600);QuestFrameAcceptClicked(600);CloseAllWindow()
            m=wait('确认接取任务',function() return api.mission(def) end)
        end
        if not inside then
            if m.status==2 then error('天龙幻境：任务已失败，请到任务栏手动放弃后重新运行',0) end
            if m.status==0 then
                api.space();api.prepareBattle()
                if isLead() then
                    -- Entering spends one 试炼令牌.
                    if cfg.allow_item~=true then error('天龙幻境：入场要消耗试炼令牌，未打开“允许物品处理”，已停止',0) end
                    if tokens()==0 then error('天龙幻境：背包没有试炼令牌（不从仓库取），已停止',0) end
                    api.openNpc(entrance);api.sleep(500)
                    assert(api.selectOption({'#{TLHJ_120110_02}'},true),'浮生没有入场选项')
                    api.sleep(800);CloseAllWindow()
                else api.openNpc(entrance);CloseAllWindow() end
                log('确认进入副本');local began=api.now()
                while world().scene~=SCENE do
                    assert(api.now()-began<(isLead() and math.max(waitMs,60000) or 600000),'天龙幻境：没有进入副本')
                    api.maintain();api.sleep(500)
                end
                inside=true
            end
        end
        if inside then fight() end
        -- Hand in. The mission leaving the list is the receipt.
        m=wait('确认任务完成状态',function() return api.mission(def) or 'gone' end)
        if m~='gone' then
            if m.status~=1 then error('天龙幻境：离开副本后任务没有完成',0) end
            api.openNpc(entrance);api.sleep(500)
            api.selectOption({'#{TLHJ_120110_62}'},true);api.sleep(600)
            QuestFrameNextClicked(600);QuestFrameMissionComplete(nil,600);CloseAllWindow()
            wait('确认交付任务',function() return not api.mission(def) end)
        end
        return {status='done',message='天龙幻境完成：任务已交付'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'天龙幻境停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
