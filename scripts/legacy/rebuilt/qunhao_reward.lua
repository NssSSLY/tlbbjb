-- 领取群豪榜奖励：由 dfz64.dll 字节码模块 活动/领取群豪榜奖励.lua 静态还原
-- 模块 SHA256 770dbddb309297cc1ee996717846506bfe5e9f9a0223dd908e5fd32f4766a46d；调用、参数、等待和次数按反汇编逐条保持。
-- 原规则在出现系统提示 #{FWQJD_210114_08} 时提前结束；本程序尚未读取系统提示，按原上限 10 档执行。
function _SMain()
    local strText = [[
    	Clear_XSCRIPT()
		Set_XSCRIPT_Function_Name("CallByClient")
		Set_XSCRIPT_ScriptID(888267)
		Set_XSCRIPT_Parameter(0,%d)
		Set_XSCRIPT_ParamCount(1)
	    Send_XSCRIPT()
    ]]
    DeleteDebugMsg("#{FWQJD_210114_08}")
    for i = 1, 10 do
        GetLuaValue(string.format(strText, i))
        Sleep(1000)
        if IsInDebugMsg("#{FWQJD_210114_08}") then break end
    end
end
_SMain()
