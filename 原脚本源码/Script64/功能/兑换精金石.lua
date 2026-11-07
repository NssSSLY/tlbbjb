-- 反编译自 dfz64.dll 内嵌字节码 00335565（unluac 2025-12-23；仅供分析）
local m_script_name = "兑换精金石"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  Bank_GetItem(" 精金石 精金石碎片 ", -1, 0)
  Sleep(500)
  GoToScene(358, 245, 1)
  Sleep(500)
  GetLuaValue([[
        Clear_XSCRIPT();
            Set_XSCRIPT_Function_Name('DuiHuanOK');
            Set_XSCRIPT_ScriptID(890174);
            Set_XSCRIPT_ParamCount(0);
        Send_XSCRIPT();]])
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
