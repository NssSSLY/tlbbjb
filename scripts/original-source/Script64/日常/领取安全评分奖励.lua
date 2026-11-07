-- 反编译自 dfz64.dll 内嵌字节码 0042c5fe（unluac 2025-12-23；仅供分析）
local m_script_name = "领取安全评分奖励"

function _SMain()
  Sleep(100)
  PushDebugMessage(m_script_name)
  local tick_out = GetTickCount()
  while true do
    if IsWindowVisible("SafeCenter_SafeScore") then
      GetLuaValue([[
					Clear_XSCRIPT()
						Set_XSCRIPT_Function_Name("SafeScoreGetBonus")  
						Set_XSCRIPT_ScriptID(890643) 
						Set_XSCRIPT_ParamCount(0)
					Send_XSCRIPT()
				]])
      Sleep(1000)
      break
    else
      GetLuaValue("PushEvent('OPEN_SAFECENTER_SAFESCORE')")
    end
    Sleep(3000)
    if -1 ~= tick_out and GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
