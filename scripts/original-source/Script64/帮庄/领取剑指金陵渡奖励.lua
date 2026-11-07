-- 反编译自 dfz64.dll 内嵌字节码 0035df3d（unluac 2025-12-23；仅供分析）
local m_script_name = "领取剑指金陵渡奖励"

function _SMain(...)
  GoToGuild()
  local tick_out = -1
  DeleteDebugMsg("#{LDDQ_20200819_66}")
  DeleteDebugMsg("#{LDDQ_20200819_96}")
  while true do
    if GoToGuild() then
      MoveToNPC("万翎峥", 107, 60, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{JLDQZ_200814_128}", 1, 1000)
      DialogOptionClicked("领取道具奖励", 1, 800)
      Sleep(500)
      if IsInDebugMsg("#{LDDQ_20200819_66}") or IsInDebugMsg("#{LDDQ_20200819_96}") then
        break
      end
    else
      PushColorMsg(m_script_name .. ":没有帮派城市！")
      break
    end
    Sleep(100)
    if -1 == tick_out then
      tick_out = GetTickCount()
    end
    if GetTickCount() - tick_out > 30000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr(m_script_name)
  end
  local tick_out = -1
  DeleteDebugMsg("#{DQYX_200922_58}")
  DeleteDebugMsg("#{LDDQ_20200819_96}")
  while true do
    if GoToGuild() then
      MoveToNPC("万翎峥", 107, 60, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{DQYX_200922_48}", 1, 1000)
      DialogOptionClicked("领取道具奖励", 1, 800)
      Sleep(500)
      if IsInDebugMsg("#{DQYX_200922_58}") or IsInDebugMsg("#{LDDQ_20200819_96}") then
        break
      end
    else
      PushColorMsg(m_script_name .. ":没有帮派城市！")
      break
    end
    Sleep(100)
    if -1 == tick_out then
      tick_out = GetTickCount()
    end
    if GetTickCount() - tick_out > 30000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
