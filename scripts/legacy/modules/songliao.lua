-- 宋辽大战 battleground, written from the reference rules (原脚本源码/Script64/常用/宋辽大战.lua). Wednesdays and Sundays.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Songliao={}
local QUEUE_MS=600000
local NPCS={
    {hi=69,name='方玉拓',x=235,y=222,scene=2},{hi=79,name='司相',x=223,y=230,scene=2},{hi=89,name='齐资',x=255,y=238,scene=2},
    {hi=109,name='刘博',x=294,y=241,scene=1},{hi=119,name='祝帅',x=312,y=235,scene=0},{hi=100000,name='郑怀远',x=307,y=230,scene=0},
}
local PIECES={'相（宋）','車（宋）','砲（宋）','炮（辽）','車（辽）','将（辽）','卒（辽）','象（辽）','馬（宋）','兵（宋）','帥（宋）','仕（宋）'}
local GIFTS={'宋辽破竹礼·雀影','宋辽破竹礼·鹤鸣','宋辽破竹礼·鹰扬','宋辽破竹礼·虎啸','宋辽破竹礼·龙腾'}
local ROOMS={{5,67,5,67,36,14},{97,162,5,67,132,14},{187,253,5,67,219,14},{5,66,101,157,36,107},{97,162,101,157,132,107},{187,253,101,157,219,107},{5,66,187,253,36,197},{97,162,187,253,132,197},{187,253,187,253,219,197}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Songliao.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    for _,k in ipairs({'songliao_leave_team','songliao_claim'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','宋辽开关无效：'..k) end
    local level=DungeonTactics.level(api)
    if level<60 then error('宋辽大战：等级 '..math.floor(level)..' 不符合，需要 60 级以上',0) end
    local npc;for _,n in ipairs(NPCS) do if level<=n.hi then npc=n;break end end
    local entrance={name=npc.name,x=npc.x,y=npc.y,scene=npc.scene}
    local def={name='宋辽大战',mission='宋辽大战',map='宋辽战场',npc=entrance,bosses={}}
    function def.inside(p) return p.map:find('宋辽战场',1,true)~=nil end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('宋辽大战 · '..s) end end
    local function world() return assert(api.world(),'宋辽大战场景不可读') end
    local function ui(code) GetLuaValue('-- songliao:ui\n'..code,'',0) end
    local function inBattle(p) return p.map:find('宋辽战场',1,true)~=nil end
    local function inRoom(p) return p.map=='雁门关前哨' end
    local fired=DungeonTactics.prompts(api,{'SLDZ_220216_43','SLDZ_220216_108','SLDZ_220216_32','SLDZ_220216_11'})
    -- Activity items only; each is used once as it turns up.
    local function useNamed(name)
        return GetLuaValue(string.format([[-- songliao:use
            local want=%q
            for i=0,DataPool:GetBaseBag_Num()-1 do local a=PlayerPackage:EnumItem('base',i)
                if a and a:GetID()~=0 and a:GetName()==want then PlayerPackage:UseItem(i) return 1 end end
            return 0]],name),'n')==1
    end
    local function fight()
        local scene=world().scene
        local T=DungeonTactics.new(api,scene,{})
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local start,side,lastItem=api.now(),0,-100000
        local towers={}
        local function towerSet(keys)
            for _,k in ipairs(keys) do local w=GetDictionaryString(k);if type(w)=='string' and w~='' then towers[w]=true end end
        end
        if cfg.allow_item==true and not T.hasBuff(api.buffs(),'乾坤壶：') then useNamed('乾坤壶') end
        while true do
            local p=world()
            if not inBattle(p) or p.scene~=scene then return end
            assert(api.now()-start<battleMs,'宋辽大战战斗超过时限')
            local hp=GetLuaValue("-- songliao:hp\nreturn Player:GetData('HP')",'n')
            if type(hp)=='number' and hp<=0 then
                log('已死亡，等待回到战场');T.reliveOut()
            else
                if side==0 then
                    local own=api.buffs()
                    if T.hasBuff(own,'辽·小卒') then side=1;towerSet({'SLDZ_220216_167','SLDZ_220216_168','SLDZ_220216_169'})
                    elseif T.hasBuff(own,'宋·小兵') then side=2;towerSet({'SLDZ_220216_170','SLDZ_220216_171','SLDZ_220216_172'}) end
                end
                if cfg.allow_item==true and api.now()-lastItem>=3000 then
                    lastItem=api.now()
                    for _,name in ipairs(PIECES) do if useNamed(name) then api.log('宋辽大战：使用 '..name);break end end
                end
                local best
                for _,o in ipairs(T.enemyPlayers()) do
                    if o.hp~=0 and o.dst<=15 and not T.playerState(o) and (not best or o.dst<best.dst) then best=o end
                end
                if best then log('打玩家');T.clearMove();T.strikePlayer(best)
                else
                    local tower,mob
                    for _,o in ipairs(T.rows()) do
                        if T.enemy(o) then
                            if towers[o.name] and (not tower or o.dst<tower.dst) then tower=o end
                            if not mob or o.dst<mob.dst then mob=o end
                        end
                    end
                    local t=tower or mob
                    if t then
                        if t.dst>(melee and 3 or 15) then log('前往目标');T.stop();T.move(math.floor(t.x),math.floor(t.y))
                        else log('打防御塔或怪');T.attack(t) end
                    else
                        log('前往前线');T.stop()
                        if side==1 then T.move(210,270) elseif side==2 then T.move(110,45) end
                    end
                end
            end
            api.pickup()
            if world().scene==scene then api.maintain() end
            api.sleep(250)
        end
    end
    local function leaveRoom()
        local began=api.now()
        while inRoom(world()) do
            assert(api.now()-began<math.max(waitMs,60000),'宋辽大战：离开休息室没有反馈')
            local p=world();local spot
            for _,r in ipairs(ROOMS) do if p.x>=r[1] and p.x<=r[2] and p.y>=r[3] and p.y<=r[4] then spot=r end end
            if spot and pcall(api.openNpc,{name=npc.name,x=spot[5],y=spot[6],scene=p.scene}) then
                api.sleep(500);api.selectOption({'退出雁门关前哨'},true);api.sleep(800);api.confirmBox()
            end
            CloseAllWindow();api.sleep(3000)
        end
    end
    local function claim()
        if cfg.songliao_claim==false then return end
        log('领取奖励')
        for _=1,5 do
            if pcall(api.openNpc,entrance) then api.sleep(500);api.selectOption({'#{SLDZ_100805_03}'},true);api.sleep(1000) end
            CloseAllWindow()
            if fired('SLDZ_220216_11') then break end
        end
        if cfg.allow_item==true then for _,g in ipairs(GIFTS) do if useNamed(g) then api.sleep(1000) end end end
    end
    local function body()
        api.validate(def,cfg)
        local p=world()
        if not (inBattle(p) or inRoom(p)) then
            local week=GetLuaValue("-- songliao:week\nreturn tonumber(os.date('%w'))",'n')
            assert(type(week)=='number','宋辽大战：日期不可读')
            if week~=3 and week~=0 then error('宋辽大战：活动在周三和周日，今天不是活动日',0) end
            if GetTeamCount()>0 then
                if cfg.songliao_leave_team~=true then error('宋辽大战：角色在队伍中，未打开“允许自动退队”，已停止',0) end
                log('退出队伍');ui("if Player:IsInTeam()==1 then Player:LeaveTeam() end");api.sleep(1000)
            end
            api.openNpc(entrance);api.sleep(500)
            local clicked=QuestFrameOptionClicked('#{SLDZ_220216_01',0);api.sleep(2000);CloseAllWindow()
            if fired('SLDZ_220216_43') then claim();return {status='already_done',message='宋辽大战：本次活动已结束或已参加'} end
            if fired('SLDZ_220216_108') then
                if pcall(api.openNpc,entrance) then api.sleep(500);api.selectOption({'#{SLDZ_100805_03}'},true);api.sleep(800) end
                CloseAllWindow()
            end
            assert(clicked,npc.name..'没有宋辽报名选项，活动可能未开放')
        end
        log('排队等待进入战场')
        local began=api.now()
        while not inBattle(world()) do
            assert(api.now()-began<QUEUE_MS,'宋辽大战：报名后 10 分钟没有进入战场，未重复报名')
            if inRoom(world()) and fired('SLDZ_220216_32') then
                log('本场已满或已结束，离开休息室');leaveRoom();claim()
                return {status='already_done',message='宋辽大战：没有进入战场就结束了'}
            end
            api.maintain();api.sleep(1000)
        end
        fight()
        if cfg.songliao_leave_team==true then ui("if Player:IsInRaid()==1 then Player:LeaveRiad() end") end
        claim()
        return {status='done',message='宋辽大战完成；已离开战场'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'宋辽大战停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
