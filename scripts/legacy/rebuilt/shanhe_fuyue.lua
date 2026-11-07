-- 山河赴约：由 dfz64.dll 字节码模块 活动/山河赴约.lua 静态还原
-- 模块 SHA256 478cfe9dc7b738c0c9c8c1d7248edb417ffc19fec3847d8b3cef44525a93750b；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "山河赴约"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_TeSeServerCliked(33)")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = JiangHuShiJi_Env});JiangHuShiJi_Click(1)")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = JiangHuShiJi_Popup_Two_Env});JiangHuShiJi_Popup_Two_LingQu();")
    Sleep(1000)
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name, true)
