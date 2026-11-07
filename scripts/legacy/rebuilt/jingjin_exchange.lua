-- 兑换精金石：由 dfz64.dll 字节码模块 功能/兑换精金石.lua 静态还原
-- 模块 SHA256 575552eda923ba8b3aa0cb463e03dd5df3135bcd3bc233b42e0d2fa8b5ea582e；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "兑换精金石"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    Bank_GetItem(" 精金石 精金石碎片 ", -1, 0)
    Sleep(500)
    GoToScene(358, 245, 1)
    Sleep(500)
    GetLuaValue([[
        Clear_XSCRIPT();
            Set_XSCRIPT_Function_Name('DuiHuanOK');
            Set_XSCRIPT_ScriptID(890174);
            Set_XSCRIPT_ParamCount(0);
        Send_XSCRIPT();
    ]])
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
