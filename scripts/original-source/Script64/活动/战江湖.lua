-- 反编译自 dfz64.dll 内嵌字节码 004354bc（unluac 2025-12-23；仅供分析）
function _SMain(...)
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
    local strTemp = fmt(strText, i)
    GetLuaValue(strTemp)
    Sleep(1000)
    if IsInDebugMsg("#{CJYJ_180104_87}") then
      break
    end
  end
  GetLuaValue("setmetatable(_G, {__index = ZhanJiangHu_Env});ZhanJiangHu_ClickGetHFReward(1)")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = ZhanJiangHu_Env});ZhanJiangHu_ClickGetHFReward(2)")
  Sleep(1000)
  CloseAllWindow()
end

_SMain()
