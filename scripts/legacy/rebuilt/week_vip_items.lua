-- 领取周道具奖励：由 dfz64.dll 字节码模块 日常/领取周道具奖励.lua 静态还原
-- 模块 SHA256 649f02b4dcf1506d0d7f0ecdcf557b234015635565c8fc97ac2740db1a8b6b8a；调用、参数、等待和循环按反汇编逐条保持。EatBindItem 只接入按名字开礼箱这一段（见 compat.lua）。
function _SMain()
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
