-- 找回内息：由 dfz64.dll 字节码模块 日常/找回内息.lua 静态还原
-- 模块 SHA256 16e9fa7b6c554a8bafc7e6a295ac7e50453390028dd7f11f2947857ca74e54d5；调用、参数、等待和次数按反汇编逐条保持。
-- 系统提示提前结束尚未接入，按原上限 3 次执行。
function _SMain()
    PushDebugMessage("内息找回")
    DeleteDebugMsg("#{WYXT_20170907_397}")
    for i = 1, 3 do
        GetLuaValue([[
                Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name( "MartialLastDayMonsterReward" )
                Set_XSCRIPT_ScriptID( 507010 )
                Set_XSCRIPT_Parameter(0,1)
                Set_XSCRIPT_Parameter(1,0)
                Set_XSCRIPT_ParamCount(2)
                Send_XSCRIPT()                
            ]])
        Sleep(1500)
        IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click();")
        Sleep(1500)
        if IsInDebugMsg("#{WYXT_20170907_397}") then break end
    end
end
_SMain()
