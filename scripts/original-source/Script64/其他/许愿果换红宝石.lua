-- 反编译自 dfz64.dll 内嵌字节码 002b49b2（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local npc = {
    name = "梁道士",
    
    x = 282,
    y = 275,
    sceneID = 1
  }
  local itemName = "红宝石"
  while true do
    local nItem = Bag:GetItemCount("许愿果")
    if nItem >= 20 then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(600)
      DialogOptionClicked("许愿果兑换奖励", 1, 700)
      DialogOptionClicked(itemName, 3, 700)
      DialogOptionClicked("我要兑换", 1, 700)
    else
      TempBank2Bag("许愿果")
      Sleep(500)
      nItem = Bag:GetItemCount("许愿果")
      if nItem < 20 then
        Bank_GetItem("许愿果")
        Sleep(500)
        nItem = Bag:GetItemCount("许愿果")
        if nItem < 20 then
          break
        end
      end
    end
    Sleep(200)
    DebugStr("许愿果换" .. itemName)
  end
end

_SMain()
