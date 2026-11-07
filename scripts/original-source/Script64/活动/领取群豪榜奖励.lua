-- 反编译自 dfz64.dll 内嵌字节码 0043a727（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：长字符串开头多出的换行（1 处，反编译器输出问题）
function _SMain(...)
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
    local strTemp = fmt(strText, i)
    GetLuaValue(strTemp)
    Sleep(1000)
    if IsInDebugMsg("#{FWQJD_210114_08}") then
      break
    end
  end
end

_SMain()
