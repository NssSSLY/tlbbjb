-- 反编译自 dfz64.dll 内嵌字节码 0042d778（unluac 2025-12-23；仅供分析）
local m_script_name = "领取鲜花种子"
ScriptOnStart(m_script_name)

function _SMain()
  GoToSceneNPC("阿里", 185, 65, 2)
  local tick_out = GetTickCount()
  while true do
    GoToSceneNPC("阿里", 185, 65, 2)
    Sleep(600)
    QuestFrameOptionClicked_Item("#{SDJZH_xml_XX(13)}", 1, 1000)
    local szText = GetNPCEventList_Item(0)
    if "#{SDJZH_091106_24}" == szText then
      PushDebugMessage(m_script_name .. "：背包需要清理!")
      ClearBag()
    elseif "#{SDJZH_091106_23}" == szText then
      PushDebugMessage(m_script_name .. "：已完成！")
      break
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
