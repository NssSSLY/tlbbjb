-- 反编译自 dfz64.dll 内嵌字节码 0035db1f（unluac 2025-12-23；仅供分析）
local m_script_name = "领取上周紫微奖励"
ScriptOnStart(m_script_name)

function _SMain(...)
  GoToGuild()
  DeleteDebugMsg("#{ZJSJ_220708_44}")
  DeleteDebugMsg("#{ZJSJ_220708_72}")
  DeleteDebugMsg("#{ZJSJ_220708_73}")
  local tick_out = -1
  while true do
    if GoToGuild() then
      MoveToNPC("姜星落", 93, 59, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{ZJSJ_220708_7}", 1, 1000)
      QuestFrameOptionClicked_Item("#{ZJSJ_220708_7}", 1, 1000)
      Sleep(500)
      if IsInDebugMsg("#{ZJSJ_220708_44}") or IsInDebugMsg("#{ZJSJ_220708_72}") or IsInDebugMsg("#{ZJSJ_220708_73}") then
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
    if GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
