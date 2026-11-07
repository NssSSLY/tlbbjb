-- 反编译自 dfz64.dll 内嵌字节码 0042c112（unluac 2025-12-23；仅供分析）
function _SMain(...)
  GetLuaValue("Target:SendUpdateVipInfoMsg()")
  
  Sleep(1000)
  GetLuaValue([[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name("OnUseVIP")
                Set_XSCRIPT_ScriptID(889644)
                Set_XSCRIPT_Parameter(0, 5)
                Set_XSCRIPT_ParamCount(1)
            Send_XSCRIPT()
        ]])
  Sleep(1000)
  EatBindItem(2, " 银丝纳福礼箱 镂金迎福礼箱 镶玉招福礼箱 ")
end

_SMain()
