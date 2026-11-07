-- 反编译自 dfz64.dll 内嵌字节码 0035e4c6（unluac 2025-12-23；仅供分析）
local m_script_name = "领取战功奖励"
ScriptOnStart(m_script_name)

function _SMain(...)
  GoToGuild()
  local tick_out = -1
  while true do
    if GoToGuild() then
      MoveToNPC("赵子勋", 93, 54, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{ZGMW_201009_01}", 1, 1000)
      IsWindowVisible("T3ZhanGongGet", "T3ZhanGongGet_OnOKClicked()")
      Sleep(500)
      if IsInDebugMsg("#{ZGMW_201009_33}") or IsInDebugMsg("#{ZGMW_201009_34}") or IsInDebugMsg("#{ZGMW_201009_35}") then
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
