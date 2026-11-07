-- Verified host for the original single-dungeon sweep wrappers. Their Lua is unchanged.
-- Only the two explicitly mapped dungeons use this contract.
local R=assert(CombatRuntime,"扫荡宿主未加载")
local S,call=R.codes,R.call
local targets={tlzz_sweep_yanzi={key="yzw",name="讨伐燕子坞"},tlzz_sweep_sijue={key="sjz",name="苏州四绝庄"}}
local cfg=TaskConfig or {};local target=assert(targets[cfg.legacy_id],"当前副本没有扫荡完成契约")
local original=SDFB_OnStart
local function whole(v,label,maximum)
    assert(type(v)=="number" and v==math.floor(v) and v>=0 and v<=(maximum or 1000000),"扫荡读数不可用："..label)
    return v
end
local function busy()
    local active,id=call(S.SweepData)
    whole(active,"进行状态",1)
    assert(type(id)=="number" and id==math.floor(id) and id>=-1 and id<=1000000,"扫荡读数不可用：正在扫荡的副本")
    return active,id
end
local function openList()
    if call(S.WindowVisible,nil,nil,"SweepAll")==1 then return end
    call(S.UiCall,{assert(S.ui.PlayerQuicklyEnter_OpenSecKillBox),0})
    local start=GetTickCount()
    repeat Sleep(200);if call(S.WindowVisible,nil,nil,"SweepAll")==1 then return end until GetTickCount()-start>=5000
    error("未确认扫荡列表打开，停止且不重复打开")
end
local function snapshot()
    local active,id=busy();local n=whole(call(S.SweepCount),"副本数量",64);local found
    for i=0,n-1 do
        local low,high,kind,need,action,left,fuben,_,name=call(S.SweepEnum,{i})
        if name==target.name then
            assert(not found,"同名扫荡副本不唯一，无法确认目标")
            action=whole(action,"活动标识")
            local total=GetLuaValue(string.format([[local e=SweepAll_Env
                local f=(type(e)=='table' and e.GetCampaignTotalNum) or GetCampaignTotalNum
                if type(f)~='function' then error('campaign total unavailable') end
                return f(%d)]],action),"n")
            found={low=whole(low,"普通点数"),high=whole(high,"高级点数"),kind=whole(kind,"点数类型",2),
                need=whole(need,"所需点数"),action=whole(action,"活动标识"),left=whole(left,"剩余次数"),
                fuben=whole(fuben,"副本标识"),total=whole(total,"总次数"),active=active,current=id}
            assert(found.left<=found.total,"扫荡总次数和剩余次数矛盾")
        end
    end
    assert(found,"未找到目标副本的扫荡记录："..target.name)
    return found
end
local function points(s)return s.kind==2 and s.high or s.low end
local function assertIdle(s)
    assert(s.active==0,"存在尚未确认结束的扫荡，停止且不重新提交")
end
local function same(a,b)
    assert(a.fuben==b.fuben and a.action==b.action and a.total==b.total,"扫荡目标身份或次数上限发生变化")
end
local function peek()
    local value=GetLuaValue([[local e=SweepPage_Env
        if type(e)~='table' then error('sweep page unavailable') end
        local empty=e.SecKillItemListEmpty or SecKillItemListEmpty
        if type(empty)~='function' then error('sweep list unavailable') end
        if empty()~=1 then return 0 end
        for i=1,6 do local boss=e['SweepPage_Boss'..i..'Name'] local done=e['SweepPage_Boss'..i..'finish']
            if boss and boss:IsVisible() and done and done:IsVisible()==false then return i end
        end return -1]],"n")
    assert(type(value)=="number" and value==math.floor(value) and value>=-1 and value<=6,"扫荡首领状态不可读")
    return value
end
function SDFB_OnStart(param)
    assert(type(param)=="table" and param[target.key]==true,"原脚本选择的副本与任务入口不一致")
    for k,v in pairs(param) do if v==true then assert(k==target.key,"本任务只支持一个已核验的扫荡副本") end end
    openList();local before=snapshot();assertIdle(before)
    if before.left==0 then
        if before.total==0 then return TaskLifecycle.report("limit_reached",target.name.."：当前没有可用扫荡次数或资格") end
        return TaskLifecycle.report("already_done",target.name.."：已无剩余扫荡次数")
    end
    if points(before)<before.need then return TaskLifecycle.report("limit_reached",target.name.."：扫荡点数不足，剩余次数 "..before.left) end
    local last=before;local guard={}
    function guard.beforePage(name,id)
        local now=snapshot();same(last,now);assertIdle(now)
        assert(name==target.name and id==now.fuben and now.left==last.left and now.left>0,"副本身份或剩余次数变化，停止扫荡")
        guard.pageStart=now;guard.seen={}
    end
    guard.peekBoss=peek
    function guard.beforeBoss(index)
        assert(not guard.seen[index],"首领进度未变化，停止且不重复提交第 "..index.." 项")
        guard.seen[index]=true
    end
    function guard.verifyBoss(expected,actual)
        assert(actual==expected or (expected>3 and actual==-2),"扫荡页面目标变化，停止且不重复提交")
    end
    function guard.afterPage(name,id)
        assert(name==target.name and id==guard.pageStart.fuben,"扫荡页面返回了错误副本")
        local start=GetTickCount()
        repeat
            local now=snapshot();same(guard.pageStart,now)
            assert(now.left<=guard.pageStart.left,"剩余次数异常增加，停止扫荡")
            if now.active==1 then assert(now.current==id,"扫荡目标已变化") end
            if now.active==0 and now.left<guard.pageStart.left then last=now;return end
            Sleep(200)
        until GetTickCount()-start>=8000
        error(name.."：未确认扫荡次数减少或扫荡结束，停止且不重复提交")
    end
    __SweepGuard=guard
    local ok,result=pcall(original,param);__SweepGuard=nil
    if not ok then error(result,0) end
    local after=snapshot();same(before,after);assertIdle(after)
    assert(after.left<=before.left,"扫荡次数异常增加")
    if after.left==0 and after.left<before.left then
        return TaskLifecycle.report("done",target.name.."：扫荡次数已核对，完成 "..(before.left-after.left).." 次")
    end
    if after.left>0 and points(after)<after.need then
        return TaskLifecycle.report("limit_reached",target.name.."：点数不足，剩余 "..after.left.." 次")
    end
    error(target.name.."：原规则已退出，但未确认完成或点数不足")
end
