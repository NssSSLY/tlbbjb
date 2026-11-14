-- Runner for the reference's mission tables (主线任务, 新手1-40级). The tables stay as they are in the reference; the helpers they call are plain Lua here,
-- run through a private environment so nothing touches the VM's globals. Every wait goes through Sleep, which holds the time limit and the health stop.
-- docs/LONG_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
QuestBook={}
function QuestBook.new(api,o)
    local cfg=TaskConfig or {}
    local label=o.label
    local Q={handed=0,phase=''}
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local deadline=api.now()+o.minutes*60000
    local function log(s) if Q.phase~=s then Q.phase=s;api.log(label..' · '..s) end end
    Q.log=log
    local function world() return assert(api.world(),label..'场景不可读') end
    local function raw(code,format) return GetLuaValue('-- questbook:'..code,format or '',format and #format or 0) end
    local function check()
        assert(api.now()<deadline,label..'超过总时限')
        api.alive(minimum,label..'：角色血量低于停止阈值，已停止',true)
    end
    Q.check=check
    local E=setmetatable({},{__index=_G})
    Q.env=E
    E.fmt=string.format;E.LUOYANG_ID=0;E.m_mission_pos={};E.g_public_dir=''
    E.g_self={menpai=math.floor(api.school())}
    E.CDG={double={},skill_attack={},skill_state={},pet1={GUID=-1}}
    function E.Sleep(ms) check();api.maintain();api.sleep(math.max(tonumber(ms) or 0,1)) end
    function E.GetTickCount() return api.now() end
    function E.DebugStr() end
    function E.PushDebugMessage() end
    function E.PushColorMsg(s,...) if select('#',...)>0 then s=string.format(s,...) end api.log(label..'：'..tostring(s)) end
    function E.GetSceneID() return world().scene end
    function E.GetCurrentSceneName() return world().map end
    function E.GetDist(x1,y1,x2,y2)
        if x2==nil then local p=world();x2,y2=p.x,p.y end
        return math.sqrt((x1-x2)^2+(y1-y2)^2)
    end
    local function dict(key)
        if type(key)~='string' or not key:find('#{',1,true) then return key end
        local inner=key:match('^#{(.-)}$');if not inner then return key end
        local text=GetDictionaryString and GetDictionaryString(inner) or nil
        return type(text)=='string' and text~='' and text or key
    end
    -- Missions in hand, read once per moment: the tables ask about every entry on every pass.
    local cached,cachedAt={},-100000
    local function missions()
        if api.now()-cachedAt<250 then return cached end
        local text=raw([[missions
            local t=''
            for i=0,19 do
                if DataPool:GetPlayerMission_InUse(i)==1 then
                    local title=DataPool:GetPlayerMission_Memo(i)
                    local id=tonumber((string.gsub(DataPool:GetPlayerMission_Name(i) or '','Mission:','')))
                    t=t..i..'\t'..tostring(id)..'\t'..tostring(DataPool:GetPlayerMission_Display(i,7))..'\t'..tostring(DataPool:GetPlayerMission_Variable(i,0))..'\t'..tostring(title)..'\n'
                end
            end
            return t]],'s')
        assert(type(text)=='string',label..'任务栏不可读')
        cached={};cachedAt=api.now()
        for slot,id,script,status,title in text:gmatch('([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\n]*)\n') do
            cached[#cached+1]={slot=math.floor(tonumber(slot)),id=tonumber(id) or -1,script=tonumber(script) or -1,status=tonumber(status) or -1,title=title,resolved=dict(title)}
        end
        return cached
    end
    function Q.refresh() cachedAt=-100000 end
    local function find(name)
        local want=dict(name)
        for _,m in ipairs(missions()) do if m.title==name or m.resolved==want or m.title==want then return m end end
    end
    function E.GetPlayerMission(name)
        local m=find(name);if not m then return -1,-1,-1 end
        return m.slot,m.id,m.script
    end
    E.GetPlayerMission_Item=E.GetPlayerMission
    function E.GetMissionVariable(slot,k)
        if type(slot)~='number' or slot<0 or slot>19 then return -1 end
        if k==0 then for _,m in ipairs(missions()) do if m.slot==slot then return m.status end end return -1 end
        local n=raw(string.format("var\nif DataPool:GetPlayerMission_InUse(%d)==1 then return DataPool:GetPlayerMission_Variable(%d,%d) end return -1",slot,slot,k),'n')
        return tonumber(n) or -1
    end
    function E.GetMissionVariableByName_Item(name,k)
        local m=find(name);if not m then return -1,-1 end
        return E.GetMissionVariable(m.slot,k),m.slot
    end
    -- The game's own list of what can be accepted.
    local outline,outlineAt='',-100000
    function E.CollectMissionOutline()
        local text=raw([[outline
            local function call(name,...)
                local g=_G[name]
                if type(g)=='function' then return g(...) end
                return Player[name](Player,...)
            end
            call('CollectMissionOutline')
            local n=call('GetMissionOutlineNum')
            local t=''
            for i=0,(tonumber(n) or 0)-1 do
                local row={call('GetMissionOutlineInfo',i)}
                for j=1,#row do if type(row[j])=='string' then t=t..row[j]..'\1' end end
                t=t..'\n'
            end
            return t]],'s')
        assert(type(text)=='string',label..'：任务大纲读取接口不可用，请反馈这条提示')
        outline,outlineAt=text,api.now()
    end
    local OUTLINE_NAMES={['归风之迷']='归云之迷',['勇闯三才阵']='勇探三才阵'}
    function E.IsMissionOutline(name)
        if api.now()-outlineAt>60000 then E.CollectMissionOutline() end
        local want=dict(OUTLINE_NAMES[name] or name)
        return outline:find(want,1,true)~=nil or outline:find(name,1,true)~=nil
    end
    -- Movement. Waits and interrupts stay with the game's own route walking.
    local function resolveScene(scene) if scene==nil or scene==-1 then return world().scene end return scene end
    function E.GoToScene(x,y,scene) check();MoveTo(math.floor(x),math.floor(y),resolveScene(scene));Q.refresh() end
    function E.GoToSceneNPC(name,x,y,scene)
        check();CloseAllWindow()
        api.openNpc({name=name,x=math.floor(x),y=math.floor(y),scene=resolveScene(scene)});Q.refresh()
    end
    function E.MoveToNPC(name,x,y,scene,_,_,_,cb)
        if cb and cb()==false then return end
        E.GoToSceneNPC(name,x,y,scene)
    end
    function E.TalkNpc(name) TalkNpc(name) end
    function E.Dismount() pcall(api.prepareBattle);return true end
    function E.UseMount() end
    function E.DoubleExp_Get() end
    function E.DoubleExp_Freeze() end
    function E.Bag_DeleteItem() end
    function E.PickUpLua() if world() then api.pickup() end end
    local T,scene_
    local function tactics()
        local s=world().scene
        if s~=scene_ then scene_=s;T=DungeonTactics.new(api,s,{}) end
        return T
    end
    Q.tactics=tactics
    function E.RunTo(x,y,_,ms) tactics().move(math.floor(x),math.floor(y));E.Sleep(ms or 300) end
    local function nameMatch(want,name)
        if want==nil or want=='' then return true end
        return (' '..want..' '):find(' '..name..' ',1,true)~=nil
    end
    -- flags[1] friendly NPCs, flags[2] hostile. The reference's other filters have no readable data.
    function E.Enum2XByName(name,flags)
        local friendly,hostile=flags and flags[1]==1,flags and flags[2]==1
        local t=tactics();local out={}
        for _,o in ipairs(t.rows()) do
            if nameMatch(name,o.name) and o.hp>0 then
                local enemy=t.enemy(o)
                if (enemy and hostile) or (not enemy and friendly) then out[#out+1]=o end
            end
        end
        table.sort(out,function(a,b) return a.dst<b.dst end)
        return out
    end
    function E.PlayerStateTimeOut(state,seconds)
        local began=api.now();E.Sleep(300)
        while tonumber(raw('state\nif not Player or type(Player.GetState)~="function" then return -1 end return Player:GetState()','n'))==state and api.now()-began<seconds*1000 do E.Sleep(200) end
    end
    -- Dialog.
    function E.QuestFrameOptionClicked_Item(text,mode,ms)
        local ok
        if mode==3 then ok=QuestFrameOptionClicked(text,0) else ok=api.selectOption({text},true)~=nil end
        if ok and ms then E.Sleep(ms) end
        return ok and true or false
    end
    E.DialogOptionClicked=E.QuestFrameOptionClicked_Item
    function E.QuestFrameNextClicked(ms) QuestFrameNextClicked(ms or 300) end
    function E.QuestFrameAcceptClicked(ms) QuestFrameAcceptClicked(ms or 300) end
    function E.QuestFrameMissionComplete(_,ms) QuestFrameMissionComplete(nil,ms or 300) end
    function E.MessageBox_Self_OK_Clicked(ms) pcall(api.confirmBox);if ms then E.Sleep(ms) end end
    function E.GetNPCEventList_Item(i)
        local t=raw(string.format("dialog\nlocal e=Quest_Env if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end local a,b,c,d,s=DataPool:GetNPCEventList_Item(%d) return s or ''",i),'s')
        return type(t)=='string' and t or ''
    end
    function E.QuestFrameMissionAbnegate(id)
        if cfg.quest_abandon~=true then error(label..'：有任务需要放弃后重接，未打开“允许放弃任务”，已停止',0) end
        log('放弃任务');raw(string.format('abandon\nQuestFrameMissionAbnegate(%d)',id));api.sleep(1000);Q.refresh()
    end
    -- Bags. Mission items are the task's own; anything from the normal bag needs the item permission.
    local QUEST_BASE=200
    local function enumBag(kind,n,base)
        local text=raw(string.format([[bag
            local t='' for i=0,%s-1 do local a=PlayerPackage:EnumItem('%s',i)
                if a and a:GetID()~=0 then t=t..(%d+i)..'\t'..(a:GetNum() or 1)..'\t'..(a:GetName() or '')..'\n' end end
            return t]],n,kind,base),'s')
        local out={};for index,num,name in tostring(text or ''):gmatch('([^\t]+)\t([^\t]+)\t([^\n]*)\n') do
            out[#out+1]={index=math.floor(tonumber(index)),num=tonumber(num) or 1,name=name,quest=base==QUEST_BASE}
        end
        return out
    end
    E.Bag={}
    function E.Bag:EnumRenWuItem() return enumBag('quest','DataPool:GetTaskBag_Num()',QUEST_BASE) end
    function E.Bag:EnumAllObj() return enumBag('base','DataPool:GetBaseBag_Num()',0) end
    function E.Bag:FindItemInfo(name,_,_,list)
        local out={};for _,a in ipairs(list or self:EnumAllObj()) do if a.name==name then out[#out+1]=a end end
        return out
    end
    function E.Bag:GetItemCount(name,_,_,list) local c=0;for _,a in ipairs(self:FindItemInfo(name,nil,nil,list)) do c=c+a.num end return c end
    function E.Bag:UseItem(index,ms) raw(string.format('use\nPlayerPackage:UseItem(%d)',index));if ms then E.Sleep(ms) end end
    function E.Bag:UseItemByName(name,ms,list)
        local item=self:FindItemInfo(name,nil,nil,list)[1]
        if not item then return false end
        if not item.quest and cfg.allow_item~=true then return false end
        self:UseItem(item.index,ms);return true
    end
    E.Skill={}
    function E.Skill.CUseSkillByID(define,target)
        local t=tactics()
        for _,o in ipairs(t.rows()) do
            if o.id==target then
                local used,missing=t.useSkill(define,o)
                assert(not missing,label..'：角色没有技能 '..tostring(define))
                return used
            end
        end
        return false
    end
    E.Player={}
    function E.Player:GetDataInt(key) return tonumber(raw(string.format("data\nreturn Player:GetData('%s')",key),'n')) or 0 end
    function E.Player:GetBuff(name) return tactics().hasBuff(api.buffs(),name) and 1 or -1 end
    function E.Player:IsJinGong() E.g_self.menpai=math.floor(api.school()) end
    function E.Player:IsLeader() return GetTeamCount()==0 or api.isLeader() end
    E.Team={}
    function E.Team:LeaveTeam()
        if GetTeamCount()==0 then return end
        if cfg.quest_leave_team~=true then error(label..'：这一步要单人进行，未打开“允许自动退队”，已停止',0) end
        log('退出队伍');raw('leave\nif Player:IsInTeam()==1 then Player:LeaveTeam() end');api.sleep(1000)
    end
    function E.TeamCheckNear() end
    function E.GetNearestPoint() return 1 end
    function E.Player:GetMoney() return tonumber(raw("money\nreturn Player:GetData('MONEY')",'n')) or 0 end
    function E.Player:TeamFollow() end
    function E.Bank_GetMoney(n) error(label..'：身上金钱不足 '..tostring(n)..' 铜，已停止；从钱庄取钱不做',0) end
    -- A table's own "fight here until this says stop" step, in the shape the reference's fighter takes.
    function E.CDG:SetTimeOut() end
    function E.CDG:OnStart() E.BeginAttack(self.pos,nil,self.targetName,self.callfun,nil,{pickup=self.pickup}) end
    function E.Shop_BuyItem(name,count)
        if cfg.allow_spend~=true then error(label..'：要买 '..name..'，未打开“允许支付”，已停止',0) end
        local n=raw(string.format([[buy
            local want,count=%q,%d local bought=0
            for _=1,count do for i=0,35 do local a=EnumAction(i,'boothitem') if a and a:GetID()~=0 and a:GetName()==want then NpcShop:BulkBuyItem(i,1,0) bought=bought+1 break end end end
            return bought]],name,count or 1),'n')
        E.Sleep(500)
        return n
    end
    -- Reference helpers for the mission record.
    function E.mission_get_name(m) if m.option==nil or #m.option==0 then return m.name end return m.option[1] end
    function E.mission_complete_accept(text,next_,complete,accept)
        E.Sleep(200)
        local clicked=E.DialogOptionClicked(text,1,600)
        if next_ then E.QuestFrameNextClicked(500) end
        if complete then E.QuestFrameMissionComplete(nil,500) end
        if accept then E.QuestFrameAcceptClicked(500) end
        Q.refresh()
        return clicked
    end
    function E.mission_accept(m)
        log('接任务 '..m.name)
        local p=m.param_accept
        if not api.spaceChecked then api.space();api.spaceChecked=true end
        for _=1,3 do
            E.GoToSceneNPC(p.name,p.x,p.y,p.sceneID)
            local name=E.mission_get_name(m)
            E.mission_complete_accept(name,false,false,true)
            CloseAllWindow()
            if E.GetPlayerMission(name)~=-1 then return end
            E.Sleep(500)
        end
        Q.refused[m.name]=true
        log('接不了 '..m.name..'，本次跳过')
    end
    function E.mission_accept_next(m)
        local p=m.param_complete
        if not (p and type(p.next_mission)=='table') then return end
        local began=api.now()
        while api.now()-began<10000 do
            local any=false
            for _,name in ipairs(p.next_mission) do
                if E.GetPlayerMission(name)==-1 then
                    E.GoToSceneNPC(p.name,p.x,p.y,p.sceneID)
                    E.mission_complete_accept(name,false,false,true)
                    any=true
                end
            end
            if not any then break end
            E.Sleep(100)
        end
    end
    function E.mission_complete_talk_npc(m)
        log('交任务 '..m.name)
        if m.is_check_team then E.Team:LeaveTeam() end
        local p=m.param_complete
        local getNext=p.next_mission==nil or p.next_mission~=false
        local name=E.mission_get_name(m)
        local done,gone=false,false
        for _=1,5 do
            E.GoToSceneNPC(p.name,p.x,p.y,p.sceneID)
            if m.option and #m.option>1 then for _,o in ipairs(m.option) do E.DialogOptionClicked(o,1,700) end end
            E.mission_complete_accept(name,true,true,getNext)
            CloseAllWindow()
            local slot=E.GetPlayerMission(name)
            -- A mission still in hand only moved a step: that is not a hand-in, whatever the talk did.
            if slot==-1 then done,gone=true,true;break end
            if E.GetMissionVariable(slot,0)~=1 then done=true;break end
            E.Sleep(500)
        end
        if not done then error(label..'：交任务 '..m.name..' 5 次没有变化，不再重复',0) end
        if gone then Q.handed=Q.handed+1 end
        E.mission_accept_next(m)
    end
    -- Patrol the points and clear what the mission names, until the mission says so. A callback may repoint CDG.pos.
    function E.BeginAttack(pos,sceneName,target,done,_,opts)
        -- Dungeon maps have no fixed id: their name stands for wherever the mission already put the player.
        local scene=(sceneName and sceneName~='' and o.scenes[sceneName]) or world().scene
        local first=pos and pos[1]
        if world().scene~=scene and first then MoveTo(first.x,first.y,scene) end
        local t=tactics()
        local idx,last,hps,lastLoot=1,api.now(),{},-100000
        pcall(api.prepareBattle)
        E.CDG.pos=nil
        while not done() do
            check();t=tactics()
            assert(api.now()-last<300000,label..'：打 '..tostring(target)..' 5 分钟没有进展')
            local points=E.CDG.pos or pos
            local mob
            for _,o2 in ipairs(t.rows()) do
                if t.enemy(o2) and nameMatch(target,o2.name) then
                    if not mob or o2.dst<mob.dst then mob=o2 end
                    if not hps[o2.id] or o2.hp<hps[o2.id] then hps[o2.id]=o2.hp;last=api.now() end
                end
            end
            if mob then t.attack(mob)
            else
                t.stop()
                if opts and opts.pickup and api.now()-lastLoot>=3000 then lastLoot=api.now();api.pickup() end
                local q=points and points[math.min(idx,#points)]
                if q then
                    if not t.move(q.x,q.y) then idx=idx%#points+1;t.clearMove() end
                end
            end
            E.Sleep(250)
            Q.refresh()
        end
        t=tactics();t.stop();api.pickup()
    end
    function E.mission_attack_mode_1(m)
        log('打怪 '..m.name)
        local p=m.param_action
        local name=E.mission_get_name(m)
        local done=p.call_back_attack or function()
            local slot=E.GetPlayerMission(name)
            return slot==-1 or E.GetMissionVariable(slot,0)==1
        end
        E.BeginAttack(p.pos,p.sceneName,p.targetName,done,nil,{pickup=p.is_pick})
    end
    function E.BeginCaiji(item,sceneName,route,done)
        local scene=type(sceneName)=='number' and sceneName or assert(o.scenes[sceneName],label..'：不认识的地图 '..tostring(sceneName))
        log('采集 '..item)
        if world().scene~=scene then MoveTo(route[1].x,route[1].y,scene) end
        local t=tactics();local i,tried,last=1,{},api.now()
        while not done() do
            check();Q.refresh()
            assert(api.now()-last<300000,label..'：5 分钟没有采到 '..item)
            local target
            for _,o2 in ipairs(t.rows()) do
                if o2.name:find(item,1,true) and not t.enemy(o2) and api.now()-(tried[o2.id] or -100000)>=60000 and (not target or o2.dst<target.dst) then target=o2 end
            end
            if target then
                if target.dst>=2.4 then t.move(math.floor(target.x),math.floor(target.y))
                else
                    t.stop();E.Dismount();tried[target.id]=api.now();last=api.now()
                    CombatRuntime.host('open_object',math.floor(target.id)..':'..math.floor(target.server_id))
                    E.PlayerStateTimeOut(8,20);E.PlayerStateTimeOut(5,20)
                    raw("loot\nlocal e=LootPacket_Env if e and e.this and e.this:IsVisible() then PlayerPackage:PickAllItem() CloseWindow('LootPacket',true) end")
                    t.clearMove()
                end
            else
                local q=route[i]
                if not t.move(q.x,q.y) then i=i%#route+1;t.clearMove() end
            end
            E.Sleep(250)
        end
        t.stop()
    end
    -- The reference's three passes: do, hand in, accept. Each returns whether it acted.
    Q.refused={}
    local stuck={}
    local function signature(slot)
        local v={}
        for k=0,3 do v[#v+1]=tostring(E.GetMissionVariable(slot,k)) end
        return table.concat(v,',')
    end
    function Q.commit(tableOf,hook)
        Q.refresh()
        for _,fn in ipairs(tableOf) do
            local mis=fn()
            local slot=E.GetPlayerMission(E.mission_get_name(mis))
            if slot~=-1 and E.GetMissionVariable(slot,0)==1 then
                mis.is_complete=true
                if not hook or hook(mis)~=false then mis.OnComplete(mis) end
                return true
            end
        end
        return false
    end
    function Q.act(tableOf,hook)
        Q.refresh()
        for _,fn in ipairs(tableOf) do
            local mis=fn()
            local name=E.mission_get_name(mis)
            local slot,_,script=E.GetPlayerMission(name)
            if slot~=-1 and not (o.skip and o.skip[mis.name]) then
                local status=E.GetMissionVariable(slot,0)
                if status==0 then
                    if mis.commit and Q.commit(tableOf,hook) then return true end
                    -- The same mission state again and again means this step is not getting anywhere.
                    local sig=name..':'..signature(slot)
                    if stuck.sig==sig then stuck.n=stuck.n+1 else stuck.sig,stuck.n=sig,1 end
                    if stuck.n>12 then error(label..'：任务 '..mis.name..' 做了 12 次没有变化，不再重复',0) end
                    log('做任务 '..mis.name)
                    if mis.OnAction then mis.OnAction(mis)
                    elseif mis.OnComplete and (not hook or hook(mis)~=false) then mis.OnComplete(mis) end
                    return true
                elseif status==2 then
                    E.QuestFrameMissionAbnegate(script)
                end
            end
        end
        return false
    end
    function Q.accept(tableOf,filter)
        E.CollectMissionOutline();E.Sleep(300)
        local acted,lastScene=false,-1
        for i,fn in ipairs(tableOf) do
            local mis=fn()
            local p=mis.param_accept
            if p and not Q.refused[mis.name] and not (o.skip and o.skip[mis.name]) and E.IsMissionOutline(mis.name)
                and (lastScene==-1 or lastScene==p.sceneID) and (not filter or filter(mis,i)) then
                lastScene=p.sceneID
                acted=true
                mis.OnAccept(mis)
                if o.stopAfter and i>o.stopAfter then break end
            end
        end
        return acted
    end
    return Q
end
