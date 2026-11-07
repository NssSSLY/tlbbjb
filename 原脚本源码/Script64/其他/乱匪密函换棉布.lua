-- 反编译自 dfz64.dll 内嵌字节码 002a902c（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local npc = {
    name = "苏辙",
    
    x = 258,
    y = 165,
    sceneID = LUOYANG_ID
  }
  local nNeed = 0
  while true do
    local nItem = Bag:GetItemCount("乱匪密函")
    if nNeed <= nItem then
      if DialogOptionClicked("上缴乱匪密函换取封赏", 1, 600) then
        DialogOptionClicked("42个乱匪密函兑换封赏", 1, 600)
        QuestFrameMissionComplete(1, 200)
      else
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        Sleep(200)
      end
    else
      PushColorMsg("乱匪密函数量不足")
      break
    end
    Sleep(200)
    DebugStr("乱匪密函兑换")
  end
end

_SMain()
