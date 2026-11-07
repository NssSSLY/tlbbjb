-- 祈鸿金-交子：由 dfz64.dll 字节码模块 活动/祈鸿金-交子.lua 静态还原
-- 模块 SHA256 ddc160f076b2cae9d5498d36ef25d3445fc63172efa6c59c602aa97c28e93d1f；调用、参数、等待和次数按反汇编逐条保持。
-- 系统提示 #{ZJWF_201231_27} 提前结束尚未接入，按原上限 20 次执行。
function _SMain()
    local strText = [[
    	Clear_XSCRIPT();
        Set_XSCRIPT_Function_Name('GetPrize');
        Set_XSCRIPT_ScriptID(885577);
        Set_XSCRIPT_Parameter(0,%d);
        Set_XSCRIPT_ParamCount(1);
        Send_XSCRIPT();
    ]]
    for i = 1, 4 do
        GetLuaValue(string.format(strText, i))
        Sleep(500)
    end
    strText = [[
    	setmetatable(_G, {__index = Xichunchi_Prize2_Env});
        Xichunchi_Prize2_Reward_Clicked(1);
    ]]
    DeleteDebugMsg("#{ZJWF_201231_27}")
    for i = 1, 20 do
        GetLuaValue(string.format(strText, i))
        Sleep(1000)
        if IsInDebugMsg("#{ZJWF_201231_27}") then break end
    end
end
_SMain()
