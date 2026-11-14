-- Common game adapter for explicit dungeon flows. All unknown states remain errors/waits.
DungeonApi={}
local R=assert(CombatRuntime)
local function valid(n,lo,hi) return type(n)=="number" and n==math.floor(n) and n>=lo and n<=hi end
local function q(s) return string.format("%q",s) end
local function clean(s) return (tostring(s or ""):gsub("#c%x%x%x%x%x%x",""):gsub("#%a",""):gsub("^%s+",""):gsub("%s+$","")) end
local function resolve(s)
    local key=s:match("^#{([%w_]+)}$")
    return key and GetDictionaryString(key) or s
end
-- 等队员：用户规则是“要开始进行，不要光等待就停止”。队伍集合 / 进场统一等这么久（默认 180 秒，
-- 30–900 可调），期间队长主动反复对话；超过才判定这一项无法进行，标记失败，任务列表继续下一项。
function DungeonApi.teamPatience()
    local c=TaskConfig or {};local n=tonumber(c.dungeon_team_wait_seconds or 180) or 180
    return math.max(30,math.min(n,900))*1000
end
-- 进场：队员没接任务 / 没准备好 / 没走到时 NPC 不放行。队长每 6 秒重新对话并选入场选项一次，
-- 直到 inside() 为真；队员只等队长带队。attempt 出错（选项暂时不在等）不算失败，下一轮再试。
-- opts.skipFirst：调用前已经对话选过一次（首轮带有完成判定等），从第二次起才重新对话。
-- opts.leader：团队副本由团长判定，覆盖队伍的队长判定。
function DungeonApi.enterRetry(api,name,inside,attempt,opts)
    opts=opts or {}
    local began,tries,limit=api.now(),0,DungeonApi.teamPatience()
    local leader=opts.leader
    if leader==nil then leader=type(api.isLeader)~='function' or api.isLeader() end
    while not inside() do
        tries=tries+1
        if leader and not (opts.skipFirst and tries==1) then
            if tries>1 then api.log(name..' · 队员未就绪或未进入，重新对话（第 '..tries..' 次）') end
            local ok,why=pcall(attempt)
            if not ok then api.log(name..' · 本次进入对话未成功，稍后重试：'..tostring(why)) end
        elseif tries==1 and not leader then api.log(name..' · 等待队长带队进入') end
        local t=api.now()
        repeat
            if inside() then return true end
            if api.maintain then api.maintain() end
            api.sleep(250)
        until api.now()-t>=6000
        assert(api.now()-began<limit,name..'：已等待 '..math.floor(limit/1000)..' 秒仍未进入（队员未接任务、未准备好或未到场），本项标记失败，继续下一项')
    end
    return true
end
function DungeonApi.new()
    local api={now=GetTickCount,sleep=Sleep,log=PushDebugMessage}
    local sharedSignatures={}
    api.stop=function() R.host("stop_motion") end
    api.stopAttack=function()
        local id,server=R.host('battle_self_identity')
        assert(valid(id,0,2147483647) and valid(server,0,2147483647),'停手时自身身份不可读')
        local selected=GetLuaValue(string.format([[-- dungeon:stop-attack
            DataPool:SelectAsTargetByObjID(%d)
            return Target:GetData('NPCID')
        ]],server),'n')
        assert(selected==id,'停手时自身目标未确认');api.stop()
    end
    api.world=function()
        local ok,scene,x,y,map=R.host("position")
        if not ok then return nil end
        assert(valid(scene,0,100000) and type(x)=="number" and type(y)=="number" and x==x and y==y,"副本位置读数无效")
        return {scene=scene,x=x,y=y,map=tostring(map or "")}
    end
    api.mission=function(def)
        local title=resolve(def.mission)
        local slot,id,status,desc=GetLuaValue(string.format([[
            -- dungeon:mission
            local memo=%s local original=%s local found=-1 local mid=-1 local state=-1 local description=''
            for i=0,19 do
                local used=DataPool:GetPlayerMission_InUse(i)
                if used~=0 and used~=1 then error('mission slot state unavailable') end
                if used==1 then local title,text=DataPool:GetPlayerMission_Memo(i)
                    if title==memo or title==original then
                        if found~=-1 then error('duplicate dungeon mission') end
                        found=i mid=tonumber((string.gsub(DataPool:GetPlayerMission_Name(i) or '','Mission:','')))
                        state=DataPool:GetPlayerMission_Variable(i,0) description=text or ''
                    end
                end
            end
            return found,mid,state,description
        ]],q(title),q(def.mission)),"nnns")
        assert(valid(slot,-1,19),"副本任务槽位不可读")
        if slot==-1 then return nil end
        assert(valid(id,0,2147483647) and valid(status,0,3) and type(desc)=="string","副本任务记录不可读")
        sharedSignatures[def.mission]=nil -- receipt permits the next legitimate task cycle
        return {slot=slot,id=id,status=status,desc=desc}
    end
    api.space=function()
        local n=R.call(R.codes.BagSpace,{0})
        assert(valid(n,0,512) and n>0,"背包已满或空位不可读取，请先整理背包")
    end
    api.teamReady=function(n) return GetTeamCount()>=n end
    api.teamTogether=function()
        local ready=GetLuaValue([[-- dungeon:team-together
            local n=DataPool:GetTeamMemberCount()
            if type(n)~='number' or n<1 or n>6 then error('team count unavailable') end
            for i=0,n-1 do
                local v=DataPool:IsTeamMemberInScene(i)
                if v==0 or v==false then return 0 end
                if v~=1 and v~=true then error('team scene unavailable') end
            end
            return 1
        ]],'n')
        assert(ready==0 or ready==1,'队伍同场景状态不可读');return ready==1
    end
    api.isLeader=function()
        local value=GetLuaValue([[-- dungeon:leader
            local v=Player:IsLeader()
            if v==true or v==1 then return 1 end
            if v==false or v==0 then return 0 end
            error('team leader state unavailable')]],"n")
        assert(value==0 or value==1,"队长状态不可读")
        return value==1
    end
    api.validate=function(def,cfg)
        assert(cfg.engine~="外部兼容","此副本流程需要游戏内 Lua")
        assert(type(def.inside)=="function" and def.npc and def.mission,"副本定义不完整")
        if def.validate then def.validate(cfg) end
        if R.prepare then R.prepare() end
    end
    api.prepareBattle=function()
        local result=R.call(R.codes.Dismount,nil,nil,"坐骑：")
        if result==0 then return end
        -- The game has no DispelBuffByName of its own. Its mount button is a toggle, and the reference uses it the same way when flying.
        if result==-1 then GetLuaValue("-- dungeon:mount-toggle\nPlayer:UseSkillInLua_Const()",'',0)
        else assert(result==1,"取消坐骑接口返回值无效") end
        local start=api.now()
        repeat
            local id=GetLuaValue([[-- dungeon:mount-state
                if type(GetMountID)=='function' then return GetMountID() end
                if Player and type(Player.GetMountID)=='function' then return Player:GetMountID() end
                error('mount state unavailable')
            ]],"n")
            assert(valid(id,-1,2147483647),"坐骑状态不可读")
            if id==-1 then return end
            api.sleep(250)
        until api.now()-start>=8000
        error("取消坐骑请求后状态未变化，停止且不重复提交",0)
    end
    api.openNpc=function(npc)
        CloseAllWindow()
        GoToSceneNPC(npc.name,npc.x,npc.y,npc.scene)
    end
    local function options(allowClosed)
        local count,text,all=GetLuaValue([[-- dungeon:dialog
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1,'','' end
            local n=DataPool:GetNPCEventList_Num() local choices='' local all=''
            if type(n)~='number' or n<0 or n>128 then error('dialog count unavailable') end
            for i=0,n-1 do local kind,unused,script,extra,text=DataPool:GetNPCEventList_Item(i)
                if type(text)=='string' then
                    all=all..text..'\n'
                    if kind=='id' then choices=choices..text..'\n' end
                end
            end
            return n,choices,all
        ]],"nss")
        if allowClosed and count==-1 and text=='' and all=='' then return nil,nil end
        assert(type(text)=="string" and type(all)=="string" and valid(count,0,128),"NPC 对话不可读")
        local out={};for line in text:gmatch("[^\n]+") do out[#out+1]=line end
        return out,all
    end
    -- Exact displayed choices only. The caller owns the receipt/deadline and
    -- must not equate "option submitted" with the resulting phase.
    api.selectOption=function(keys,allowMissing)
        local candidates=options(allowMissing)
        if not candidates then return nil end
        for _,key in ipairs(keys) do
            for _,candidate in ipairs(candidates) do
                if candidate==key or clean(resolve(candidate))==clean(resolve(key)) then
                    assert(QuestFrameOptionClicked(candidate,1),"NPC 选项提交失败："..candidate)
                    return key
                end
            end
        end
        if not allowMissing then error("NPC 缺少指定选项："..table.concat(keys," / "),0) end
    end
    api.objects=EnumEnvObj
    api.mechanisms=function()
        local before=assert(api.world(),'机制快照前场景不可读')
        local scene,count,text=R.host('mechanism_snapshot')
        assert(scene==before.scene and valid(count,0,512) and type(text)=='string','机制快照不可读或场景变化')
        local rows,seen={},{}
        for line in text:gmatch('[^\n]+') do
            local k,id,server,x,y=line:match('^(%d+)\t(%d+)\t(-?%d+)\t([^\t]+)\t([^\t]+)$')
            k,id,server,x,y=tonumber(k),tonumber(id),tonumber(server),tonumber(x),tonumber(y)
            assert((k==1 or k==2) and valid(id,0,2147483647) and valid(server,k==1 and 0 or -1,2147483647)
                and x and y and x==x and y==y and math.abs(x)<100000 and math.abs(y)<100000 and not seen[id],'机制对象字段或身份无效')
            seen[id]=true;rows[#rows+1]={kind=k,id=id,server_id=server,x=x,y=y}
        end
        assert(#rows==count and assert(api.world(),'机制快照后场景不可读').scene==scene,'机制对象数量或场景变化')
        return rows
    end
    api.teamIdentities=function()
        local count,text=GetLuaValue([[-- dungeon:team-identities
            local n=DataPool:GetTeamMemberCount() local rows='' local seen={}
            if type(n)~='number' or n~=math.floor(n) or n<1 or n>6 then error('team count unavailable') end
            for i=0,n-1 do
                local server,name=DataPool:GetTeamMemberObjIDNamePortInfo(i)
                local guid=DataPool:GetTeamMemGUIDByUIIndex(i)
                local inside=DataPool:IsTeamMemberInScene(i)
                if inside~=1 and inside~=true then error('team member left scene') end
                if type(server)~='number' or server~=math.floor(server) or server<0 or server>2147483647 then error('team server identity unavailable') end
                local client=Target:GetServerId2ClientId(server)
                if type(server)~='number' or type(client)~='number' or server<0 or client<0 or client~=math.floor(client)
                    or guid==nil or type(name)~='string' or name=='' or seen[server] then error('team identity unavailable') end
                seen[server]=true rows=rows..string.format('%.0f\t%.0f\n',client,server)
            end
            if DataPool:GetTeamMemberCount()~=n then error('team changed during read') end
            return n,rows
        ]],'ns')
        assert(valid(count,1,6) and type(text)=='string','队员身份不可读')
        local rows,seen={},{};for line in text:gmatch('[^\n]+') do
            local id,server=line:match('^(%d+)\t(%d+)$');id,server=tonumber(id),tonumber(server)
            assert(valid(id,0,2147483647) and valid(server,0,2147483647) and not seen[id] and not seen['s'..server],'队员身份无效')
            seen[id]=true;seen['s'..server]=true;rows[#rows+1]={id=id,server_id=server}
        end
        assert(#rows==count,'队员身份数量变化');return rows
    end
    api.buffs=function(object)
        local id,server=-1,-1
        if object then id,server=object.id,object.server_id end
        assert(valid(id,-1,2147483647) and valid(server,-1,2147483647),"Buff 对象身份无效")
        local count,text=R.host('object_buff_ids',string.format('%d:%d',id,server))
        assert(valid(count,0,256) and type(text)=='string',"Buff ID 不可读")
        local ids={};for token in text:gmatch('[^,]+') do
            local n=tonumber(token);assert(valid(n,0,2147483647),'Buff ID 无效');ids[#ids+1]=n
        end
        assert(#ids==count,'Buff 数量不一致')
        local result={}
        for first=1,#ids,8 do
            local terms={};for i=first,math.min(first+7,#ids) do terms[#terms+1]='Lua_GetBuffInfo('..ids[i]..')' end
            -- Lua only expands the final function call's multiple results.
            -- Assign each pair first, then return all scalar names.
            local code='-- dungeon:buff-names\nlocal names={} '
            for j,term in ipairs(terms) do code=code..'local icon,name='..term..' names['..j..']=name ' end
            local returns={};for j=1,#terms do returns[j]='names['..j..']' end
            local values=table.pack(GetLuaValue(code..' return '..table.concat(returns,','),string.rep('s',#terms)))
            assert(values.n==#terms,'Buff 名称数量不一致')
            for j=1,#terms do
                assert(type(values[j])=='string' and values[j]~='','Buff 定义名称不可读：'..ids[first+j-1])
                result[values[j]]=true
            end
        end
        return result
    end
    api.messages=function()
        local n,text=R.call(R.codes.DebugMessages)
        if n==0 and text==nil then text='' end
        assert(valid(n,0,128) and type(text)=='string','系统提示不可读')
        local lines={};for line in text:gmatch('[^\n]+') do lines[#lines+1]=clean(line) end
        return lines
    end
    api.hasMessage=function(lines,key)
        local phrase=clean(resolve(key));assert(phrase~='','提示字典不可读：'..key)
        for _,line in ipairs(lines) do if line:find(key,1,true) or line:find(phrase,1,true) then return true end end
        return false
    end
    api.skipCinematic=function()
        GetLuaValue([[-- dungeon:cinematic
            local e=AnimationPass_Env
            if type(e)=='table' and e.this and e.this:IsVisible() then
                local fn=e.AnimationPass_OnClick or _G.AnimationPass_OnClick
                if type(fn)~='function' then error('AnimationPass handler unavailable') end
                fn()
            end
        ]],'',0)
    end
    api.limit=function(def)
        local _,text=options()
        for _,key in ipairs(def.limit or {}) do
            local phrase=clean(resolve(key))
            if text:find(key,1,true) or phrase~="" and clean(text):find(phrase,1,true) then return true end
        end
        local body=clean(text)
        if body:find(def.mission,1,true) or body:find(clean(resolve(def.mission)),1,true) then
            for _,phrase in ipairs({"今日次数已用完","今日参与次数已达上限","今天已经参加过此活动"}) do
                if body:find(phrase,1,true) then return true end
            end
        end
        return false
    end
    -- Resolve an actual displayed option, submit exactly once, and let the flow observe the result.
    local function choose(def,kind)
        local candidates,text=options()
        local configured=(TaskConfig or {})[kind.."_option"]
        if type(configured)=="string" then configured=configured:match("^%s*(.-)%s*$") end
        local allowed=type(configured)=="string" and configured~="" and {configured} or def[kind] or {}
        for _,key in ipairs(allowed) do
            if QuestFrameOptionClicked(key,1) then return end
        end
        local selected
        for _,candidate in ipairs(candidates) do
            local label=clean(resolve(candidate))
            local hit=kind=="accept" and label==clean(resolve(def.mission))
                or kind=="enter" and label:find("进入",1,true) and
                   (label:find(def.map,1,true) or label:find(def.mission,1,true))
                or kind=="turnin" and label==clean(resolve(def.mission))
            if hit then assert(not selected,"NPC 有多个匹配选项，请填写具体选项");selected=candidate end
        end
        assert(selected and QuestFrameOptionClicked(selected,1),"未找到"..kind.."选项；当前对话："..text)
    end
    local function press(kind,previous)
        return GetLuaValue(string.format([[-- dungeon:button
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local kind=%s local b=nil
            if kind=='accept' then b=e.Quest_Button_Accept else b=e.Quest_Button_Continue end
            if not b or not b:IsVisible() or tostring(b:GetProperty('Disabled'))~='False' then return '' end
            local signature=(b:GetText() or '')
            for i=0,DataPool:GetNPCEventList_Num()-1 do local a,b,c,d,t=DataPool:GetNPCEventList_Item(i) signature=signature..'|'..tostring(t or '') end
            if signature==%s then return '' end
            local name=kind=='accept' and 'QuestAccept_Clicked' or 'MissionContinue_Clicked'
            local fn=e[name] or _G[name]
            if type(fn)~='function' then error('dungeon dialog handler unavailable: '..name) end
            fn() return signature
        ]],q(kind),q(previous or "")),"s")
    end
    api.accept=function(def)
        choose(def,"accept")
        local start,previous,advanced=api.now(),'',0
        repeat
            if api.mission(def) then return end
            local signature=press('accept',sharedSignatures[def.mission])
            if signature~='' then sharedSignatures[def.mission]=signature;return end
            local signature=press("continue",previous)
            if signature~='' then previous=signature;advanced=advanced+1 end
            assert(advanced<=3,'接取页面变化超过三次，请检查任务对话')
            api.sleep(250)
        until api.now()-start>=5000
        error("接取页面没有可用的接受按钮",0)
    end
    api.acceptShared=function(def)
        local _,text=options(true)
        if text and (clean(text):find(def.mission,1,true) or clean(text):find(clean(resolve(def.mission)),1,true)) then
            local signature=press('accept',sharedSignatures[def.mission])
            if signature~='' then sharedSignatures[def.mission]=signature;return true end
        end
        return false
    end
    api.enterMission=function(def)
        choose(def,'accept')
        local start,acceptSig,continueSig,submitted=api.now(),'','',0
        repeat
            local p=api.world();if p and def.inside(p) then return end
            local a=press('accept',acceptSig)
            if a~='' then acceptSig=a;submitted=submitted+1 end
            local c=press('continue',continueSig)
            if c~='' then continueSig=c;submitted=submitted+1 end
            assert(submitted<=3,'入场对话变化超过三次')
            api.sleep(250)
        until api.now()-start>=tonumber((TaskConfig or {}).dungeon_wait_seconds or 45)*1000
        error('接取/入场已提交但未确认场景变化，不重复点击选项',0)
    end
    api.enter=function(def) choose(def,"enter") end
    api.turnIn=function(def)
        choose(def,"turnin")
        local previous,pressed,start="",0,api.now()
        repeat
            if not api.mission(def) then return end
            local signature=press("continue",previous)
            if signature~="" then previous=signature;pressed=pressed+1 end
            assert(pressed<=3,"交付页面变化超过三次，请检查任务对话")
            api.sleep(250)
        until api.now()-start>=10000
        error("交付请求后任务记录仍存在；当前页面不重复提交",0)
    end
    api.leave=function(def,m) return def.leave(api,m) end
    api.beginBattle=function(def,scene)
        api.prepareBattle()
        return {scene=scene,combat=R.new(scene,{boss_names=def.bosses}),index=0,routeIndex=1,lastMove=-10000,
                lastStageRead=api.now(),lastProgress=api.now()}
    end
    api.progress=function(def,m,context) return def.progress(api,m,context) end
    api.maintain=function() return R.maintain and R.maintain() or false end
    api.teamPatience=DungeonApi.teamPatience
    api.enterRetry=function(name,inside,attempt) return DungeonApi.enterRetry(api,name,inside,attempt) end
    -- What to do about dying, per the task's setting. 停止 keeps the old rule: low health stops the task while the character still lives.
    -- A rescue is accepted when the game offers one. 出窍回城 walks out through 孟婆; open-world tasks then carry on (api.RESUME), dungeons end the run.
    api.RESUME='\0resume-after-death'
    function api.resumable(step)
        local ok,why=pcall(step)
        if ok then return why end
        if why==api.RESUME then return nil end
        error(why,0)
    end
    api.alive=function(minimum,message,resume)
        local cfg=TaskConfig or {}
        local mode=tostring(cfg.revive_mode or '停止')
        if mode=='停止' then
            if GetHPPercent()>minimum then return true end
            -- GetHPPercent reads 0 while a floor or scene loads (max HP not readable yet). Stop only on
            -- three valid low readings in a row; an unreadable sample is a load, not low health.
            for _=1,3 do
                api.sleep(300)
                local hp,max=Player:GetData('HP'),Player:GetData('MAXHP')
                if type(hp)~='number' or type(max)~='number' or hp<0 or max<=0 then return true end
                if hp*100//max>minimum then return true end
            end
            assert(false,message)
        end
        local function state() return GetLuaValue('-- dungeon:player-state\nif not Player or type(Player.GetState)~="function" then return -1 end return Player:GetState()','n') end
        if state()~=9 then return true end
        api.log('角色死亡，'..mode)
        pcall(api.stopAttack)
        local began,limit=api.now(),math.max(tonumber(cfg.revive_wait_seconds or 60) or 60,1)*1000
        while api.now()-began<limit do
            GetLuaValue([[-- dungeon:relive-accept
                local e=Relive_Env
                if type(e)=='table' and e.this and e.this:IsVisible() and e.Relive_Relive_Button and e.Relive_Relive_Button:IsVisible() then
                    local on=e.Relive_Relive_Button:IsEnabled()
                    if on==1 or on==true then e.Relive_Relive() end
                end]],'',0)
            api.sleep(1000)
            if state()~=9 then api.log('已被救起，继续');return true end
        end
        if mode~='等待后出窍回城' then error((message or '角色死亡')..'：等待救援超时，已停止',0) end
        api.log('等待超时，出窍')
        GetLuaValue("-- dungeon:relive-out\nlocal e=Relive_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.Relive_Out_Ghost() end",'',0)
        local out=api.now()
        local function here() return assert(api.world(),'死亡后场景不可读') end
        local function underworld(s) return s==77 or s==578 or s==823 end
        while state()==9 do
            assert(api.now()-out<60000,'出窍后 60 秒仍处于死亡状态，已停止')
            api.sleep(1000)
        end
        api.sleep(1000)
        while underworld(here().scene) do
            assert(api.now()-out<180000,'地府里 3 分钟没有回到城市，已停止')
            pcall(api.openNpc,{name='孟婆',x=15,y=25,scene=here().scene})
            api.sleep(700)
            if here().scene==77 then QuestFrameOptionClicked('洛阳',0) else QuestFrameOptionClicked('#{KVKGZ_110620_128}',1) end
            api.sleep(2000);CloseAllWindow()
        end
        api.log('已出窍回城')
        if resume then error(api.RESUME,0) end
        error((message or '角色死亡')..'：已出窍回城，副本内进度中止，本次任务结束',0)
    end
    api.fight=function(def,stage,context,supportBusy)
        if stage.key~=context.index then
            context.index=stage.key;context.routeIndex=1;context.lastMove=-10000
            context.lastProgress=api.now();api.stop()
        end
        if stage.signature~=context.signature then context.signature=stage.signature;context.lastProgress=api.now() end
        if supportBusy then return end
        local event=R.step(context.combat)
        if event=="boss" or event=="kill" then context.lastProgress=api.now() end
        if event=="empty" then
            local route=stage.route or {}
            local p=api.world();if not p then return end
            local target=route[context.routeIndex]
            if target then
                if (p.x-target.x)^2+(p.y-target.y)^2<=9 then
                    if #route>1 then
                        context.routeIndex=context.routeIndex%#route+1;target=route[context.routeIndex];context.lastMove=-10000
                    else target=nil end
                end
                if target and api.now()-context.lastMove>=8000 then
                    R.call(R.codes.RunTo,{context.scene},{target.x,target.y});context.lastMove=api.now()
                end
            end
            assert(#route>0 or api.now()-context.lastProgress<15000,
                def.name.."：任务没有返回当前场景的目标坐标，请配置巡点坐标")
            assert(api.now()-context.lastProgress<90000,def.name.."：90 秒没有战斗或阶段进展，阶段："..stage.name)
        end
    end
    return api
end
