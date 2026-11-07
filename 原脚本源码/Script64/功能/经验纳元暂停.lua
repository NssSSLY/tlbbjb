-- 反编译自 dfz64.dll 内嵌字节码 0034f95c（unluac 2025-12-23；仅供分析）
local m_script_name = "经验纳元暂停"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GoToSceneNPC("何所思", 258, 154, 2)
  Sleep(1000)
  DialogOptionClicked("#{JYQQ_250801_02}", 1, 700)
  Sleep(1000)
  DialogOptionClicked("#{JYQQ_250801_16}", 1, 700)
  Sleep(1000)
  DialogOptionClicked("#{JYQQ_250801_19}", 1, 700)
  Sleep(1000)
end

_SMain()
ScriptOnStop(m_script_name, true)
