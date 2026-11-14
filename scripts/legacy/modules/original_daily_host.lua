-- Adapter only: task bodies are the original Lua 5.4 chunks, not rewritten loops.
local cfg=TaskConfig or {}
local rawCount=Bag.GetItemCount
local oldNpc=GetNPCEventList_Item
local oldNpcAll=GetNPCEventListAllItem
local oldOption,oldDialog=QuestFrameOptionClicked_Item,DialogOptionClicked
local oldDebug,oldDelete=IsInDebugMsg,DeleteDebugMsg
local oldGameLua=GetLuaValue
local oldMessage,oldColor=PushDebugMessage,PushColorMsg
local state
local claimResults={rose="#{SDJZH_091106_04}",seed="#{SDJZH_091106_23}"}
local bagFull="#{SDJZH_091106_24}"
-- Game text carries colour, line-break and item codes (#cFF0000, #r, #W, #{_ITEM...}); the
-- NPC reply may also wrap the dictionary sentence in more text. Compare the plain words.
local function plainText(v)
    v=tostring(v or ""):gsub("#c%x%x%x%x%x%x",""):gsub("#{_[^}]*}",""):gsub("#%a","")
    return (v:gsub("[%s%p]",""):gsub("，",""):gsub("。",""):gsub("！",""):gsub("：",""))
end
local translations={}
local function translate(key)
    if translations[key]~=nil then return translations[key] end
    local dictionaryKey=key:match("^#{([%w_]+)}$");local plain=""
    if dictionaryKey then
        local translated=GetDictionaryString(dictionaryKey)
        if type(translated)=="string" and translated~=key and translated~=dictionaryKey then plain=plainText(translated) end
    end
    translations[key]=plain;return plain
end
local function matchesDictionary(value,key)
    if type(value)~="string" or value=="" then return false end
    if value:find(key,1,true) then return true end
    local plain,wanted=plainText(value),translate(key)
    -- Short fragments could match unrelated lines; require a real sentence.
    return #wanted>=9 and #plain>0 and plain:find(wanted,1,true)~=nil
end
-- The game's own bottom-screen message list, where claim results also appear.
local function messageShows(key)
    local wanted=translate(key);if #wanted<9 then return false end
    local ok,found=pcall(oldDebug,wanted);return ok and found==true
end
local gems={['红宝石']=true,['绿宝石']=true,['紫玉']=true,['祖母绿']=true,['黄晶石']=true,['蓝晶石']=true,
    ['红晶石']=true,['绿晶石']=true,['黄玉']=true,['皓石']=true,['月光石']=true,['碧玺']=true,['变石']=true}
local function baseName(name)
    local n=tostring(name or ""):gsub("（1级）$",""):gsub("%(1级%)$","")
    return gems[n] and n or nil
end
local function counted(name,list)
    local n=rawCount(Bag,name,nil,nil,list)
    assert(type(n)=="number" and n>=0 and n==math.floor(n),"物品数量不可读："..name)
    return n
end
function Bag.GetItemCount(_,name,a,b,list)
    local base=baseName(name)
    if not base then return rawCount(Bag,name,a,b,list) end
    -- This task must compare the same inventory scope before and after exchange.
    -- Its original baseline explicitly supplies the material list, whereas its
    -- later reads use the default list. Normalize those gem reads to base+material
    -- so an already carried stack cannot make a new exchange look completed.
    local ascii,wide=base.."(1级)",base.."（1级）"
    local material=Bag:EnumCailiaoItem()
    return counted(ascii,nil)+counted(wide,nil)+counted(ascii,material)+counted(wide,material)
end
local function gemCount(name)
    return Bag:GetItemCount(name)
end
local function limitText(v)
    v=tostring(v or ""):gsub("#c%x%x%x%x%x%x","")
    return v:find("累计兑换了10颗宝石",1,true)~=nil
        or ((v:find("兑换",1,true)~=nil) and (v:find("上限",1,true)~=nil)
            and (v:find("已达",1,true)~=nil or v:find("达到",1,true)~=nil))
end
local function observe(v)
    if not state then return end
    v=tostring(v or "")
    if state.kind=="gulanyu" then state.limited=state.limited or limitText(v)
    elseif state.kind=="shitu" then
        local text=plainText(v)
        state.done=state.done or text:find("已经参加过此活动",1,true)~=nil
            or text:find("已参加过此活动",1,true)~=nil or text:find("今天已经领取",1,true)~=nil
    elseif state.kind=="xingyun" then
        if v:find("已经参加",1,true) then state.done=true end
        if v:find("再等60分钟",1,true) then state.cooldown=true end
        if matchesDictionary(v,"#{XYLP_20071222_02}") then state.rewardConfirmed=true end
    elseif claimResults[state.kind] then
        if matchesDictionary(v,claimResults[state.kind]) then state.done=true end
        if matchesDictionary(v,bagFull) then state.bagFull=true end
    end
end
local function observeShituNpc()
    -- NPC responses may be in another list entry and may contain colour tags.
    local _,count=oldNpcAll();count=tonumber(count) or 0
    for index=0,math.min(31,math.max(-1,count-1)) do
        observe(oldNpc(index))
        if state.done then break end
    end
    if not state.done then for _,line in ipairs({"已经参加过此活动","今天已经领取"}) do local ok,found=pcall(oldDebug,line);if ok and found==true then state.done=true end end end
    return state.done
end
-- Check only immediately before a new claim or participation; already-completed
-- tasks can still finish even if the bag is full. A failed read is not free space.
local function requireClaimSpace()
    local space=Bag:GetSpaceNum(0)
    assert(type(space)=="number" and space==math.floor(space) and space>0,
        "背包没有可用空位或空位无法读取，未提交领取，请先整理背包")
end
local function freeSlots()
    local ok,space=pcall(Bag.GetSpaceNum,Bag,0)
    return ok and type(space)=="number" and space==math.floor(space) and space or nil
end
local function observeClaimNpc()
    -- Check each NPC response separately, then the bottom-screen messages.
    local _,count=oldNpcAll();count=tonumber(count) or 0
    for index=0,math.min(31,math.max(-1,count-1)) do
        observe(oldNpc(index))
        if state.done or state.bagFull then break end
    end
    if not state.done and messageShows(claimResults[state.kind]) then state.done=true end
    if not state.bagFull and messageShows(bagFull) then state.bagFull=true end
    -- The claimed item takes a bag slot: fewer free slots after this submit is the item arriving.
    if not state.done and state.claimPending and state.slotsBefore then
        local now=freeSlots();if now and now<state.slotsBefore then state.done=true;state.byBag=true end
    end
    return state.done
end
function GetNPCEventList_Item(index)
    local text,kind=oldNpc(index);observe(text)
    if state and claimResults[state.kind] then
        if matchesDictionary(text,claimResults[state.kind]) then return claimResults[state.kind],kind end
        if matchesDictionary(text,bagFull) then return bagFull,kind end
    end
    return text,kind
end
function IsInDebugMsg(key)
    local found=oldDebug(key)
    if state and state.kind=="gulanyu" then
        if oldDebug("累计兑换了10颗宝石") then state.limited=true end
        if key=="累计兑换了10颗宝石" and state.limited then return true end
        -- A single exchange success is not proof that a requested batch is done.
        if key=="#{FZYH_170213_28" or key=="#{FZYH_170213_28}" then
            return found and state.activeGem~=nil and gemCount(state.activeGem)>=state.targets[state.activeGem]
        end
    end
    return found
end
function DeleteDebugMsg(key)
    if state and state.kind=="gulanyu" and oldDebug("累计兑换了10颗宝石") then state.limited=true end
    return oldDelete(key)
end
local function message(fn,v)
    observe(v)
    if state and tostring(v):find("超时",1,true) then state.timedout=true end
    fn(v)
end
function PushDebugMessage(v) return message(oldMessage,v) end
function PushColorMsg(v) return message(oldColor,v) end
local function refreshLimit()
    if oldDebug("累计兑换了10颗宝石") then state.limited=true end
    local text=oldNpc(0);observe(text)
    return state.limited
end
function QuestFrameOptionClicked_Item(option,mode,wait)
    if state and state.kind=="gulanyu" and refreshLimit() then return false end
    if state and claimResults[state.kind] then
        local expected=state.kind=="rose" and "#{SDJZH_xml_XX(01)}" or "#{SDJZH_xml_XX(13)}"
        if option==expected then
            observeClaimNpc()
            if state.bagFull then error("背包需要清理：领取未执行，请先手动整理背包") end
            if state.done then CloseAllWindow();error(TaskLifecycle.skip("already_done","NPC 已确认今日领取状态"),0) end
            if state.claimPending then error("领取请求已提交，但游戏状态未确认；停止且不重复领取") end
            requireClaimSpace()
            state.slotsBefore=freeSlots()
            local ok=oldOption(option,mode,wait)
            if ok then
                state.claimPending=true
                local start=GetTickCount()
                repeat
                    if observeClaimNpc() then CloseAllWindow();error(TaskLifecycle.skip("done","NPC 已确认领取状态"),0) end
                    if state.bagFull then error("背包需要清理：未确认领取完成") end
                    Sleep(200)
                until GetTickCount()-start>=2000
                -- Reopen the same conversation for a status read only. Do not
                -- click the claim option a second time when its result is unclear.
                if state.kind=="rose" then GoToSceneNPC("巴盖里",182,69,2)
                else GoToSceneNPC("阿里",185,65,2) end
                start=GetTickCount()
                repeat
                    if observeClaimNpc() then CloseAllWindow();error(TaskLifecycle.skip("done","NPC 已确认领取状态"),0) end
                    if state.bagFull then error("背包需要清理：未确认领取完成") end
                    Sleep(200)
                until GetTickCount()-start>=5000
                error("领取请求已提交，但 NPC 状态未确认；停止且不重复领取")
            end
            return ok
        end
    end
    if state and state.kind=="shitu" and option=="师徒心连心" then
        if observeShituNpc() then
            CloseAllWindow()
            error(TaskLifecycle.skip("already_done","NPC 已确认今天参加过师徒心连心"),0)
        end
        if state.claimPending then error("领取已提交，但未确认师徒心连心完成状态；停止且不重复领取") end
        requireClaimSpace()
        local ok=oldOption(option,mode,wait)
        assert(ok,"没有找到师徒心连心领取选项，未提交领取")
        state.claimPending=true
        local start=GetTickCount()
        repeat
            if observeShituNpc() then
                CloseAllWindow()
                error(TaskLifecycle.skip("done","NPC 已确认今天参加过师徒心连心"),0)
            end
            Sleep(200)
        until GetTickCount()-start>=2000
        -- Reopen only the NPC conversation to read its status; never submit
        -- the claim option again when the first result is uncertain.
        GoToSceneNPC("聂政",139,132,2)
        start=GetTickCount()
        repeat
            if observeShituNpc() then
                CloseAllWindow()
                error(TaskLifecycle.skip("done","NPC 已确认今天参加过师徒心连心"),0)
            end
            Sleep(200)
        until GetTickCount()-start>=5000
        error("领取已提交，但 NPC 未确认今日完成；停止且不重复领取")
    end
    if state and state.kind=="xingyun" and option=="幸运快活三" then
        observe(oldNpc(0))
        if state.done or state.cooldown then return false end
        if state.joinPending then error("参加幸运快活三已提交，但窗口 / 参加状态未确认；停止且不重复参加") end
        requireClaimSpace()
        local ok=oldOption(option,mode,wait)
        if ok then state.joinPending=true end
        return ok
    end
    if state and state.kind=="xingyun" and option=="领取幸运快活三奖励" then
        if state.rewardConfirmed then return false end
        if state.rewardPending then error("幸运快活三奖励已提交，但 NPC 状态未确认；停止且不重复领取") end
        requireClaimSpace()
        local ok=oldOption(option,mode,wait)
        if ok then state.rewardPending=true end
        return ok
    end
    return oldOption(option,mode,wait)
end
function DialogOptionClicked(option,mode,wait)
    if not state or state.kind~="gulanyu" or not baseName(option) then return oldDialog(option,mode,wait) end
    if refreshLimit() then return false end
    local base=baseName(option);local target=assert(state.targets[base],"兑换清单中没有该宝石")
    state.activeGem=base
    local before=gemCount(base)
    if before>=target then return false end
    local ok=oldDialog(option,mode,wait)
    if not ok then error("未找到宝石兑换选项，未计入数量："..option) end
    state.submitted=state.submitted+1
    local start=GetTickCount()
    while true do
        if refreshLimit() then return true end
        local after=gemCount(base)
        if after>before then
            assert(after<=target,"实际兑换数量超过目标，已停止："..base)
            PushDebugMessage(string.format("确认兑换 %s：%d → %d，目标 %d",base,before,after,target));return true
        end
        if GetTickCount()-start>=8000 then error("兑换提交后未确认物品增加或上限反馈，停止且不重复提交："..base) end
        Sleep(200)
    end
end
-- The reference game handler can fail in its visual animation after updating the
-- selected head. Continue only when this exact head visibly changed from an
-- unselected tooltip to an empty tooltip, and only for the reported UI error.
function GetLuaValue(code,...)
    local source=tostring(code or "")
    local prefix="setmetatable(_G, {__index = XingYun_Env});Play_Ani("
    local index=state and state.kind=="xingyun" and source:find(prefix,1,true)==1 and tonumber(source:match("Play_Ani%((%d+)%)$"))
    if not index or index<1 or index>20 then return oldGameLua(code,...) end
    local function tip()
        return oldGameLua(string.format([[local e=XingYun_Env local h=e and e['XingYun_Head%d']
            if not h or not h.GetToolTip then return '' end return h:GetToolTip() or '']],index),"s")
    end
    local before=tip()
    local result=table.pack(pcall(oldGameLua,code,...))
    if result[1] then return table.unpack(result,2,result.n) end
    local reason=tostring(result[2] or "")
    if reason:find("SetProperty",1,true) and before~="" and tip()=="" then
        PushDebugMessage("快活三：头像选择已变化，忽略本次动画错误并继续")
        return
    end
    error("快活三头像选择后状态未确认："..reason,0)
end
function ReadConfigText(section,key)
    assert(state and state.kind=="gulanyu" and section=="ZH" and key=="bjk97","原配置读取尚未映射："..tostring(section).."/"..tostring(key))
    return state.originalList
end
-- Original cleanup entry is not a license to delete items.
function PackUp() PushDebugMessage("背包自动整理未启用；不删除物品") end
Bag.PackUp=PackUp
local function parseGems()
    local list,counts={},{}
    for item in tostring(cfg.gulanyu_list or ""):gmatch("%S+") do
        local n,c=item:match("^(.-)|(%d+)$");local base=baseName(n);c=tonumber(c)
        assert(base and c and c>=1 and c<=9999,"兑换清单格式无效，应为一级宝石名称|数量："..item)
        if not counts[base] then list[#list+1]=base;counts[base]=0 end
        counts[base]=counts[base]+c;assert(counts[base]<=9999,"兑换数量超过上限")
    end
    assert(#list>0,"请先设置兑换清单，未执行兑换")
    state.targets={};local effective={}
    for _,name in ipairs(list) do
        local have=gemCount(name)
        local total=cfg.gulanyu_count_mode=="持有目标总数"
        local target=total and counts[name] or have+counts[name]
        state.targets[name]=target
        local need=math.max(0,target-have)
        PushDebugMessage(string.format("兑换前校验 %s：现有 %d，目标 %d，需新增 %d",name,have,target,need))
        if need>0 then effective[#effective+1]=name.."|"..need end
    end
    state.originalList=table.concat(effective," ")
end
local function verify()
    if state.timedout then return "failed","原规则已超时，完成条件未确认" end
    if state.kind=="gulanyu" then
        local complete=true;for name,target in pairs(state.targets) do complete=complete and gemCount(name)>=target end
        if complete then return "done","古兰玉兑换数量已核对，本项完成" end
        if state.limited then return "limit_reached","古兰玉兑换已达今日上限，本项结束并继续下一项" end
        return "failed","古兰玉兑换退出，但数量和每日上限均未确认"
    elseif state.kind=="shitu" and state.done then return state.claimPending and "done" or "already_done","师徒心连心今日已领取 / 已参加，完成状态已确认"
    elseif state.kind=="xingyun" then
        if state.rewardConfirmed then return "done","幸运快活三奖励已由 NPC 对话确认" end
        if state.cooldown then return "already_done","幸运快活三处于参加间隔，本项跳过" end
        if state.done then return "failed","幸运快活三已参加，但奖励领取状态未确认" end
    elseif claimResults[state.kind] then
        if state.bagFull then return "failed","背包需要清理，未确认领取完成" end
        if state.done then return state.claimPending and "done" or "already_done",(state.kind=="rose" and "波斯玫瑰" or "鲜花种子")..(state.byBag and "：领取后背包空位减少，已确认领取" or "：已由游戏对话确认完成") end
    end
    return "failed","原规则已退出，但任务完成条件未确认"
end
function RunOriginalDaily(kind,body)
    state={kind=kind,submitted=0,limited=false}
    if kind=="xingyun" then assert(cfg.allow_spend==true,"幸运快活三：请在任务参数启用“允许支付”后运行；当前未移动、未参加") end
    if kind=="gulanyu" then
        parseGems()
        if state.originalList=="" then return TaskLifecycle.report("already_done","已有宝石数量达到持有目标，无需兑换") end
        if refreshLimit() then return TaskLifecycle.report("limit_reached","当前已读到今日兑换上限，未提交兑换") end
    end
    return TaskLifecycle.run(body,verify)
end
