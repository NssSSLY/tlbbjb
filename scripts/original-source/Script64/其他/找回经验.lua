-- 反编译自 dfz64.dll 内嵌字节码 002aa095（unluac 2025-12-23；仅供分析）
function _SMain(...)
  PushDebugMessage("经验找回")
  
  DeleteDebugMsg("#{XTZY_171213_13}")
  DeleteDebugMsg("#{XTZY_171213_24}")
  DeleteDebugMsg("#{XTZY_171213_31}")
  for i = 1, 3 do
    GetLuaValue([[
                Clear_XSCRIPT();
                Set_XSCRIPT_Function_Name("GetExp_ByMoney");
                Set_XSCRIPT_ScriptID(892659); 
                Set_XSCRIPT_Parameter(0, 0 )  
                Set_XSCRIPT_ParamCount(1);
                Send_XSCRIPT();
                ]])
    Sleep(1500)
    IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click();")
    Sleep(1500)
    if IsInDebugMsg("#{XTZY_171213_13}") or IsInDebugMsg("#{XTZY_171213_24}") or IsInDebugMsg("#{XTZY_171213_31}") then
      break
    end
  end
end

_SMain()
