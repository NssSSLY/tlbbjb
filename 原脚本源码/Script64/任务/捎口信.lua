-- 反编译自 dfz64.dll 内嵌字节码 0026bb73（unluac 2025-12-23；仅供分析）
local m_script_name = "捎口信"
ScriptOnStart(m_script_name, true, false)

function _SMain()
  while true do
    local nIndex, idMission, idScript = GetPlayerMission_Item(m_script_name)
    if -1 ~= nIndex then
      local npc = GetMissionDesc_NPC(m_script_name)
      if npc then
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        Sleep(500)
        if QuestFrameOptionClicked_Item(m_script_name, 1, 1000) then
          QuestFrameMissionComplete(0, 400)
          CloseWindow("Packet")
        end
      end
    else
      GoToSceneNPC("邱行洛", 232, 319, LUOYANG_ID)
      QuestFrameOptionClicked_Item(m_script_name, 1, 1000)
      local szText = GetNPCEventList_Item(0)
      if string.find(szText, "10次口信", nil, true) then
        PushDebugMessage("捎口信：已完成")
        break
      end
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
