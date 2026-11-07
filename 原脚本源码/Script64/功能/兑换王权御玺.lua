-- 反编译自 dfz64.dll 内嵌字节码 0033503d（unluac 2025-12-23；仅供分析）
local m_script_name = "兑换王权御玺"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  local itemName = "王权御令"
  local tick_out = -1
  DeleteDebugMsg("#{ZZZB_200805_25}")
  DeleteDebugMsg("#{ZZZB_200805_51}")
  CloseAllWindow()
  ClearBag()
  while true do
    IsWindowVisible("T3XinTianWai_Guide", "T3XinTianWai_Guide_OnClose()")
    local nCount = Bag:GetItemCount(itemName)
    if nCount < 100 then
      TempBank2Bag(itemName)
      Sleep(500)
      nCount = Bag:GetItemCount(itemName)
      if nCount < 100 then
        Bank_GetItem(itemName)
        Sleep(500)
      end
      nCount = Bag:GetItemCount(itemName)
    end
    if nCount < 100 then
      PushColorMsg(m_script_name .. ":您王权御令数量不足")
      break
    end
    GoToSceneNPC("殷轩奇", 88, 173, 850)
    if -1 == tick_out then
      tick_out = GetTickCount()
    end
    QuestFrameOptionClicked_Item("#{ZZZB_200805_2}", 1, 800)
    QuestFrameOptionClicked_Item("#{ZZZB_200805_23}", 1, 800)
    IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click();")
    if IsInDebugMsg("#{ZZZB_200805_25}") or IsInDebugMsg("#{ZZZB_200805_51}") then
      break
    end
    if GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
