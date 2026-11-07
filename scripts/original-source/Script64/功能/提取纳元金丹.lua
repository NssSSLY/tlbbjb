-- 反编译自 dfz64.dll 内嵌字节码 0034f4e5（unluac 2025-12-23；仅供分析）
local m_script_name = "提取纳元金丹"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GoToSceneNPC("何所思", 258, 154, 2)
  Sleep(1000)
  DialogOptionClicked("#{JYQQ_250801_03}", 1, 700)
  Sleep(1000)
  DialogOptionClicked("#{JYQQ_250801_33}", 1, 700)
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
end

_SMain()
ScriptOnStop(m_script_name, true)
