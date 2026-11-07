-- 反编译自 dfz64.dll 内嵌字节码 0042cd40（unluac 2025-12-23；仅供分析）
local m_script_name = "领取波斯玫瑰"
ScriptOnStart(m_script_name)

function _SMain(...)
  GoToSceneNPC("巴盖里", 182, 69, 2)
  local tick_out = GetTickCount()
  while true do
    GoToSceneNPC("巴盖里", 182, 69, 2)
    Sleep(600)
    QuestFrameOptionClicked_Item("#{SDJZH_xml_XX(01)}", 1, 700)
    local szText = GetNPCEventList_Item(0)
    if "#{SDJZH_091106_04}" == szText then
      PushDebugMessage("领取波斯玫瑰完成！")
      break
    elseif "#{SDJZH_091106_24}" == szText then
      PushDebugMessage(m_script_name .. "：背包需要清理!")
      Bag_DeleteItem()
    end
    if -1 ~= tick_out and GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
