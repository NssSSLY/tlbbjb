-- 反编译自 dfz64.dll 内嵌字节码 0042c956（unluac 2025-12-23；仅供分析）
local m_script_name = "领取师徒心连心"
ScriptOnStart(m_script_name)

function _SMain(...)
  DeleteDebugMsg("#{ResultText_15}")
  GoToSceneNPC("聂政", 139, 132, 2)
  local tick_out = GetTickCount()
  while true do
    GoToSceneNPC("聂政", 139, 132, 2)
    Sleep(800)
    QuestFrameOptionClicked_Item("师徒心连心", 1, 1000)
    local strText = GetNPCEventList_Item(0)
    if string.find(strText, "对不起，你今天已经参加过此活动了，请明天再来!", nil, true) then
      break
    end
    if GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    Sleep(100)
    if IsInDebugMsg("#{ResultText_15}") then
      PushDebugMessage(m_script_name .. "：背包需要清理!")
      Bag_DeleteItem()
    end
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
