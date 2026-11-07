-- 反编译自 dfz64.dll 内嵌字节码 0045d0bd（unluac 2025-12-23；仅供分析）
local m_script_name = "寒山侠影"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GoToSceneNPC("寒时月", 272, 269, LUOYANG_ID)
  Sleep(1000)
  QuestFrameOptionClicked_Item("#{DGRR_260821_14}", 1, 1000)
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
