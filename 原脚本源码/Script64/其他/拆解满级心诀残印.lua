-- 反编译自 dfz64.dll 内嵌字节码 002b2a3b（unluac 2025-12-23；仅供分析）
function _SMain()
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_OpenXingZhen()")
  
  Sleep(1000)
  local nListCount = GetLuaValue("return DataPool:LuaFnGetXingJuanListCount()", "n")
  for idx = 1, nListCount do
    local tem = GetLuaValue(fmt([[
					local idx = %d
					local nXingJuanID = DataPool:LuaFnGetXingJuanID(idx-1)
					if DataPool:LuaFnGetXingJuanInfo(nXingJuanID, "UnLocked") > 0 then
						if DataPool:LuaFnGetXingJuanInfo(nXingJuanID, "Order") >= 5 then
							local count = DataPool:LuaFnGetXingJuanInfo(nXingJuanID, "ChipCount")
							if count > 0 then
								Clear_XSCRIPT()
									Set_XSCRIPT_Function_Name("MeltChip")
									Set_XSCRIPT_ScriptID(888555)
									Set_XSCRIPT_Parameter(0, nXingJuanID)
									Set_XSCRIPT_Parameter(1, count)
									Set_XSCRIPT_ParamCount(2)
								Send_XSCRIPT()
								return 0
							end
						end
					end
					return -1
				]], idx), "n")
    if 0 == tem then
      Sleep(500)
    end
  end
end

_SMain()
