-- 反编译自 dfz64.dll 内嵌字节码 0043a9a2（unluac 2025-12-23；仅供分析）
local m_script_name = "山河赴约"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
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
