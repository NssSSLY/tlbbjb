-- 战江湖：由 dfz64.dll 字节码模块 活动/战江湖.lua 静态还原
-- 模块 SHA256 e6d1c2b3bce0d717d32fd2e4124e2c6ce869dfca4705993526e73e79f4c70db6；调用、参数、等待和次数按反汇编逐条保持；系统提示提前结束尚未接入，按原上限 8 档执行。
function _SMain()
    CloseAllWindow()
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(35);")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = HeXinChun_Env});HeXinChun_ChangeTabIndex()")
    Sleep(1000)
    local strText = [[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name("GetDayReward")
                Set_XSCRIPT_ScriptID(892664)
                Set_XSCRIPT_Parameter(0,%d)
                Set_XSCRIPT_ParamCount(1)
            Send_XSCRIPT()
        ]]
    DeleteDebugMsg("#{CJYJ_180104_87}")
    for i = 1, 8 do
        GetLuaValue(string.format(strText, i))
        Sleep(1000)
        if IsInDebugMsg("#{CJYJ_180104_87}") then break end
    end
    GetLuaValue("setmetatable(_G, {__index = ZhanJiangHu_Env});ZhanJiangHu_ClickGetHFReward(1)")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = ZhanJiangHu_Env});ZhanJiangHu_ClickGetHFReward(2)")
    Sleep(1000)
    CloseAllWindow()
end
_SMain()
