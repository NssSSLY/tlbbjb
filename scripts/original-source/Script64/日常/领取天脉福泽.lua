-- 反编译自 dfz64.dll 内嵌字节码 0042c38c（unluac 2025-12-23；仅供分析）
local m_script_name = "领取天脉福泽"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  DeleteDebugMsg("#{TWWK_20220708_89}")
  for i = 1, 5 do
    GoToSceneNPC("陈霄", 105, 200, 850)
    QuestFrameOptionClicked_Item("#{TWWK_20220708_51}", 1, 800)
    Sleep(300)
    if IsInDebugMsg("#{TWWK_20220708_89}") then
      break
    end
    DebugStr(m_script_name)
  end
end

_SMain()
