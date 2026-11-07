-- 反编译自 dfz64.dll 内嵌字节码 00283bbf（unluac 2025-12-23；仅供分析）
local m_script_name = "武林无字谱"
ScriptOnStart(m_script_name, true, false)

function _SMain(...)
  while not IsGuanShanHaiScene() do
    do
      local nIndex, idMission, idScript = GetPlayerMission_Item("#{XZYD_200401_42}")
      if -1 ~= nIndex then
        GoToSceneNPC("沈暝楼", 206, 53, 2)
        QuestFrameOptionClicked_Item("#{XZYD_200401_42}", 1, 800)
        QuestFrameOptionClicked_Item("#{XZYD_200401_11}", 1, 800)
        QuestFrameOptionClicked_Item("#{XZYD_200401_14}", 1, 800)
        QuestFrameOptionClicked_Item("#{XZYD_200401_16}", 1, 800)
        QuestFrameOptionClicked_Item("#{XZYD_200401_68}", 1, 800)
        QuestFrameMissionComplete()
        QuestFrameOptionClicked_Item("#{XZYD_200401_45}", 1, 800)
        QuestFrameAcceptClicked(600)
      else
        nIndex, idMission, idScript = GetPlayerMission_Item("#{XZYD_200401_45}")
        if -1 ~= nIndex then
          GoToSceneNPC("名士芙蓉仙子", 270, 115, 2)
          QuestFrameOptionClicked_Item("#{XZYD_200401_45}", 1, 800)
          QuestFrameOptionClicked_Item("#{XZYD_200401_26}", 1, 800)
          QuestFrameOptionClicked_Item("#{XZYD_200401_28}", 1, 800)
          IsWindowVisible("GiveGift", "GiveGift_GiveOneTime()")
          QuestFrameOptionClicked_Item("#{XZYD_200401_71}", 1, 800)
          QuestFrameOptionClicked_Item("#{XZYD_200401_73}", 1, 800)
          QuestFrameOptionClicked_Item("#{XZYD_200401_75}", 1, 800)
          QuestFrameMissionComplete()
          QuestFrameAcceptClicked(600)
          QuestFrameOptionClicked_Item("#{XZYD_200401_48}", 1, 800)
        else
          nIndex, idMission, idScript = GetPlayerMission_Item("#{XZYD_200401_48}")
          if -1 ~= nIndex then
            GoToSceneNPC("沈寒洲", 210, 51, 2)
            local nComp = GetMissionComplete(nIndex)
            if 1 == nComp then
              QuestFrameOptionClicked_Item("#{XZYD_200401_48}", 1, 800)
              QuestFrameMissionComplete()
            else
              break
            end
          else
            GoToSceneNPC("沈暝楼", 206, 53, 2)
            if QuestFrameOptionClicked_Item("#{XZYD_200401_42}", 1, 800) == false then
              local allText, allCount = GetNPCEventListAllItem()
              if not (not string.find(allText, "#{XZJC_200309_03}") or string.find(allText, "#{XZYD_200401_42}")) then
                break
              end
            end
            QuestFrameAcceptClicked(600)
          end
        end
      end
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
