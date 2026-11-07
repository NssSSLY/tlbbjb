-- 反编译自 dfz64.dll 内嵌字节码 0043b4bf（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local strText = [[

    	Clear_XSCRIPT();
        Set_XSCRIPT_Function_Name('GetPrize');
        Set_XSCRIPT_ScriptID(885577);
        Set_XSCRIPT_Parameter(0,%d);
        Set_XSCRIPT_ParamCount(1);
        Send_XSCRIPT();
    ]]
  for i = 1, 4 do
    local strTemp = fmt(strText, i)
    GetLuaValue(strTemp)
    Sleep(500)
  end
  strText = [[
    	setmetatable(_G, {__index = Xichunchi_Prize2_Env});
        Xichunchi_Prize2_Reward_Clicked(1);
    ]]
  DeleteDebugMsg("#{ZJWF_201231_27}")
  for i = 1, 20 do
    local strTemp = fmt(strText, i)
    GetLuaValue(strTemp)
    Sleep(1000)
    if IsInDebugMsg("#{ZJWF_201231_27}") then
      break
    end
  end
end

_SMain()
