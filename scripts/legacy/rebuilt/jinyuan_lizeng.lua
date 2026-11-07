-- 金元礼赠：由 dfz64.dll 字节码模块 活动/金元礼赠.lua 静态还原
-- 模块 SHA256 5df2aec319b2a025b79184b9337a7b331aa6184e2a41a93a50c1b41f171e7395；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "金元礼赠"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GetLuaValue([[
        setmetatable(_G, {__index = New_SeasonCard_Env});
        New_SeasonCard_Icon_GetClick();
    ]])
    Sleep(1000)
    Dismount()
    Bag:UseItemByName_click("100绑定元宝票", 1000)
    Sleep(1000)
end
_SMain()
ScriptOnStop(m_script_name, true)
