-- Task-specific receipts around unmodified original bytecode.
-- Only declared contracts may run; other archived rules are not silently enabled.
local cfg,entry=TaskConfig or {},assert(__original_entry,"缺少原规则入口声明")
local function count(name,list)
    local n=Bag:GetItemCount(name,nil,nil,list)
    assert(type(n)=="number" and n>=0 and n==math.floor(n),"物品数量不可读："..name)
    return n
end
local allowed={['金纹铜钱']=true,['踏雪迎冬礼盒']=true}
local function use(name,pause)
    assert(allowed[name],"本任务未声明此消耗物品："..tostring(name))
    local before=count(name);if before==0 then return false end
    assert(cfg.allow_spend==true,"使用现有铜钱与礼盒需要启用允许支付 / 消耗")
    local code=string.format([[local n=DataPool:GetBaseBag_Num()
        if type(n)~='number' or n<1 or n>512 then error('inventory unavailable') end
        for i=0,n-1 do local a=PlayerPackage:EnumItem('base',i)
          if a and a:GetID()~=0 and a:GetName()==%q then PlayerPackage:UseItem(i) return 1 end
        end return 0]],name)
    assert(GetLuaValue(code,'n')==1,"提交前物品身份已变化，停止且不重发")
    local start=GetTickCount()
    repeat
        Sleep(200)
        local after=count(name)
        if after<before then if pause then Sleep(pause) end return true end
        assert(after==before,"物品数量出现外部变化，停止本项")
    until GetTickCount()-start>=5000
    error("使用后未确认物品减少，停止且不重复提交："..name)
end
local function selectTarget(_,id,pause)
    local found
    for _,o in ipairs(EnumObjects()) do if o.id==id and o.name=="摇钱树" and o.hostile~=1 then found=o;break end end
    assert(found and found.server_id>=0,"摇钱树目标身份不可确认")
    local observed=GetLuaValue(string.format("DataPool:SelectAsTargetByObjID(%d) return Target:GetData('NPCID')",found.server_id),'n')
    assert(observed==id,"选中结果与摇钱树身份不符，停止且不重发")
    if pause then Sleep(pause) end
end
function RunOriginalArchiveTask()
    assert(entry.adapter=="original_archive_v1" and entry.validation_contract=="jinwen_inventory_v1"
        and entry.original_token=="0043a061","原规则缺少已实现的任务完成契约")
    local temp=Bag:EnumTempBagItem()
    local before=count("金纹铜钱")+count("金纹铜钱",temp)
    local reward=count("踏雪迎冬礼盒")
    if before==0 and reward==0 then return TaskLifecycle.report("already_done","背包和锦囊均无金纹铜钱，背包无待开礼盒，无需执行") end
    assert(cfg.allow_spend==true,"请启用允许支付 / 消耗；当前未移动或使用物品")
    Bag.FindItemInfo=function(_,name)
        assert(name=="金纹铜钱","本契约仅提供原任务的铜钱存在性读取")
        return count(name)>0 and {{name=name,num=count(name)}} or {}
    end
    Bag.UseItemByName_click=function(_,name,pause)return use(name,pause)end
    Target={Select=selectTarget}
    local remaining
    return TaskLifecycle.run(function()return RunOriginalRule(entry.original_token,false)end,function()
        remaining=count("金纹铜钱")+count("金纹铜钱",temp)
        if remaining~=0 then return 'failed',"原规则退出，但仍有金纹铜钱未处理："..remaining end
        return 'done',"原规则执行结束，金纹铜钱已清空并核对库存；礼盒按原规则最多使用三次"
    end)
end
