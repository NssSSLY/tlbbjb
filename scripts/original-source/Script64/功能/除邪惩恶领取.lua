-- 反编译自 dfz64.dll 内嵌字节码 0034f2ae（unluac 2025-12-23；仅供分析）
local m_script_name = "除邪惩恶领取"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GoToSceneNPC("姚楚娥", 216, 139, 2)
  Sleep(1000)
  DialogOptionClicked("#{CJJY_250806_02}", 1, 700)
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = ExorciseEvil_Env});ExorciseEvil_LevelBox_Clicked();")
end

_SMain()
ScriptOnStop(m_script_name, true)
