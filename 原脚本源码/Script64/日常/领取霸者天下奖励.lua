-- 反编译自 dfz64.dll 内嵌字节码 0042d1e7（unluac 2025-12-23；仅供分析）
local m_script_name = "领取霸者天下奖励"
ScriptOnStart(m_script_name, true, false)

function _SMain(...)
  local nTickOut = -1
  DeleteDebugMsg("#{BZTX_220705_163}")
  DeleteDebugMsg("#{BZTX_220705_164}")
  CloseAllWindow()
  while true do
    GoToSceneNPC("万翎疆", 133, 59, 850)
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 60000 then
      PushColorMsg(m_script_name .. "：超时")
      break
    end
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BZTX_220705_162}", 1, 1000)
    if IsInDebugMsg("#{BZTX_220705_163}") or IsInDebugMsg("#{BZTX_220705_164}") then
      break
    end
    local strItem = GetNPCEventList_Item(0)
    if string.find(strItem, "#{BZTX_220705_382", nil, true) then
      PushColorMsg("不是霸主")
      break
    end
  end
  nTickOut = -1
  DeleteDebugMsg("#{BZTX_220705_164}")
  DeleteDebugMsg("#{BZTX_220705_221}")
  DeleteDebugMsg("#{BZTX_220705_304}")
  while true do
    GoToSceneNPC("万翎疆", 133, 59, 850)
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 60000 then
      PushColorMsg(m_script_name .. "：超时")
      break
    end
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BZTX_220705_220}", 1, 1000)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BZTX_260602_15}", 1, 1000)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BZTX_260602_16}", 1, 1000)
    if IsInDebugMsg("#{BZTX_220705_164}") or IsInDebugMsg("#{BZTX_220705_221}") or IsInDebugMsg("#{BZTX_220705_304}") then
      break
    end
  end
end

_SMain()
ScriptOnStop(m_script_name)
