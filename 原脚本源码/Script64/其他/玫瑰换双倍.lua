-- 反编译自 dfz64.dll 内嵌字节码 002b4cca（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local npc = {
    name = "巴盖里",
    
    x = 183,
    y = 68,
    sceneID = 2
  }
  local itemCount = 5
  while true do
    local nItem = Bag:GetItemCount("波斯玫瑰")
    if itemCount <= nItem then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(600)
      DialogOptionClicked("波斯玫瑰兑换奖励", 1, 800)
      DialogOptionClicked("5朵波斯玫瑰兑换奖励", 1, 800)
      QuestFrameMissionComplete(0, 800)
    else
      TempBank2Bag("波斯玫瑰")
      Sleep(500)
      nItem = Bag:GetItemCount("波斯玫瑰")
      if itemCount > nItem then
        Bank_GetItem("波斯玫瑰")
        Sleep(500)
        nItem = Bag:GetItemCount("波斯玫瑰")
        if itemCount > nItem then
          break
        end
      end
    end
    Sleep(200)
    DebugStr("波斯玫瑰换双倍")
  end
end

_SMain()
