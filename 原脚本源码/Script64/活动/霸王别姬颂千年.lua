-- 反编译自 dfz64.dll 内嵌字节码 0045297d（unluac 2025-12-23；仅供分析）
local m_script_name = "霸王别姬颂千年"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GetLuaValue("setmetatable(_G, {__index = QiXi_Guide_2026_Env});QiXi_Guide_2026_ActionClicked(3);")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = XiQuLianDong_Env});XiQuLianDong_GetGiftClicked();")
end

_SMain()
ScriptOnStop(m_script_name, true)
