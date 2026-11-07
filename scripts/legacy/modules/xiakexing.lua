-- 侠客行 guide chain, written from the reference rules (原脚本源码/Script64/活动/侠客行.lua). Five missions from 木影, handed in one by one.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/ACTIVITY_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Xiakexing={}
local TOWN,BATTLE=1016,1017
local MUYING={name='木影',x=138,y=24,scene=TOWN}
local LONGXIN={name='龙辛',x=127,y=24,scene=TOWN}
local MULI={name='木离',x=127,y=40,scene=BATTLE}
local STEPS={'#{XKXYD_250116_09}','#{XKXYD_250116_41}','#{XKXYD_250116_169}','#{XKXYD_250116_98}','#{XKXYD_250116_135}'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Xiakexing.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local limitMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'总时限')*1000
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='侠客行',mission=STEPS[1],map='侠客行',npc=MUYING,bosses={}}
    function def.inside() return false end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('侠客行 · '..s) end end
    local function world() return assert(api.world(),'侠客行场景不可读') end
    local function ui(code) GetLuaValue('-- xiakexing:ui\n'..code,'',0) end
    local function dialogText()
        local text=GetLuaValue([[-- xiakexing:dialog-all
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local all=''
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                if type(t)=='string' then all=all..t..'\n' end
            end
            return all]],'s')
        return type(text)=='string' and text or ''
    end
    local function say(npc,keys)
        api.openNpc(npc);api.sleep(500)
        for _,k in ipairs(keys) do api.selectOption({k},true);api.sleep(800) end
    end
    local function useWhistle()
        local r=GetLuaValue([[-- xiakexing:whistle
            for i=0,DataPool:GetBaseBag_Num()-1 do local a=PlayerPackage:EnumItem('base',i)
                if a and a:GetID()~=0 and a:GetName()=='召引竹哨' then PlayerPackage:UseItem(i) return 1 end end
            return 0]],'n')
        assert(r==1,'侠客行：背包没有召引竹哨')
    end
    -- Mission in hand first, then what 木影 offers. 0 means the chain is over.
    local function current()
        for i,key in ipairs(STEPS) do
            local m=api.mission({mission=key})
            if m then return i,m end
        end
        if world().scene~=TOWN then return nil end
        api.openNpc(MUYING);api.sleep(500)
        local text=dialogText();CloseAllWindow()
        for i,key in ipairs(STEPS) do if text:find(key,1,true) then return i,nil end end
        return 0
    end
    local function killAll(name,scene,done)
        local T=DungeonTactics.new(api,scene,{})
        local began,last,hps=api.now(),api.now(),{}
        while not done() do
            assert(world().scene==scene,'侠客行：战斗时离开场景')
            api.alive(minimum,'侠客行：角色血量低于停止阈值，自动复活未接入，已停止')
            assert(api.now()-last<180000,'侠客行：打 '..name..' 没有进展')
            local mob
            for _,o in ipairs(T.rows()) do
                if T.enemy(o) and o.name:find(name,1,true) and (not mob or o.dst<mob.dst) then mob=o end
                if T.enemy(o) and (not hps[o.id] or o.hp<hps[o.id]) then hps[o.id]=o.hp;last=api.now() end
            end
            if mob then log('打 '..name);T.attack(mob) else T.stop() end
            api.maintain();api.sleep(250)
        end
        T.stop()
    end
    local function settled(step,signature)
        local began=api.now()
        while api.now()-began<math.max(waitMs,60000) do
            local s,m=current()
            if s==nil then return end
            if tostring(s)..':'..tostring(m and m.status)~=signature then return end
            api.maintain();api.sleep(1000)
        end
        error('侠客行：第 '..step..' 步操作后任务没有变化，不再重复',0)
    end
    local function body()
        api.validate(def,cfg)
        local start,changed=api.now(),false
        while true do
            assert(api.now()-start<limitMs,'侠客行超过总时限')
            local step,m=current()
            if step==nil then step=4;m=api.mission({mission=STEPS[4]}) end
            if step==0 then
                return {status=changed and 'done' or 'already_done',message=changed and '侠客行引导任务已完成' or '侠客行：没有可做的引导任务'}
            end
            local key=STEPS[step]
            local signature=tostring(step)..':'..tostring(m and m.status)
            log('第 '..step..' 步')
            if not m then
                say(MUYING,{key});api.sleep(500);QuestFrameAcceptClicked(1000);CloseAllWindow()
            elseif m.status~=0 then
                if step==4 and world().scene==BATTLE then
                    say(MULI,{'#{XKXYD_250116_123}'});CloseAllWindow()
                    local began=api.now()
                    while world().scene==BATTLE do
                        assert(api.now()-began<math.max(waitMs,60000),'侠客行：木离选项后仍在战斗场景')
                        api.maintain();api.sleep(500)
                    end
                    signature='moved'
                else
                    say(step==5 and LONGXIN or MUYING,{key});QuestFrameMissionComplete(nil,800);CloseAllWindow()
                end
            elseif step==1 then
                say(MUYING,{key,'#{XKXYD_250116_13}','#{XKXYD_250116_28}','#{XKXYD_250116_30}','#{XKXYD_250116_32}'});CloseAllWindow()
            elseif step==2 then
                -- The first use names the place in its dialog; the second, there, calls the mobs.
                api.prepareBattle();useWhistle();api.sleep(1000)
                local x,y,scene=dialogText():match('%*[%c]*(%d+)%*[%c]*(%d+)%*[%c]*(%d+)')
                CloseAllWindow()
                assert(x,'侠客行：召引竹哨没有给出坐标')
                x,y,scene=tonumber(x),tonumber(y),tonumber(scene)
                log('前往 '..x..','..y);MoveTo(x,y,scene);api.prepareBattle();useWhistle();api.sleep(500);CloseAllWindow()
                killAll('江湖宵小',scene,function() local c=api.mission({mission=key});return not c or c.status~=0 end)
                signature='moved'
            elseif step==3 then
                error('侠客行：第 3 步没有已知做法（原脚本同样只提示“不知道该干嘛”），请手动完成后重新运行',0)
            elseif step==4 then
                if world().scene~=BATTLE then
                    say(MUYING,{key,'#{XKXYD_250116_168}'});CloseAllWindow()
                    local began=api.now()
                    while world().scene~=BATTLE do
                        assert(api.now()-began<math.max(waitMs,60000),'侠客行：选择后没有进入战斗场景')
                        api.maintain();api.sleep(500)
                    end
                end
                local T=DungeonTactics.new(api,BATTLE,{});T.move(126,53)
                killAll('莽牯毒蛤',BATTLE,function() local c=api.mission({mission=key});return not c or c.status~=0 end)
                signature='moved'
            elseif step==5 then
                -- This one buys from the 侠客 shop.
                if cfg.allow_spend~=true then error('侠客行：第 5 步要在龙辛处购买，未打开“允许支付”，已停止',0) end
                say(LONGXIN,{'#{XKSD_250110_03}'})
                ui("Xiake_Shop_Env.Xiake_Shop_Buy(2)");api.sleep(1000)
                ui("Xiake_Shop_Mbuy_Env.Xiake_Shop_MBuy_OK_Clicked()");api.sleep(1000);CloseAllWindow()
            end
            changed=true
            if signature~='moved' then settled(step,signature) end
        end
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'侠客行停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
