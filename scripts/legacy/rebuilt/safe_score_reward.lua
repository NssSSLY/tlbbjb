-- 领取安全评分奖励：由 dfz64.dll 字节码模块 日常/领取安全评分奖励.lua 静态还原
-- 模块 SHA256 dbb3394f2d41783329528ef940bc99a73090040e0c80b93a08eac4040a9da042；调用、参数、等待和超时按反汇编逐条保持。
local m_script_name = "领取安全评分奖励"
function _SMain()
    Sleep(100)
    PushDebugMessage(m_script_name)
    local nTick = GetTickCount()
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
        end
        GetLuaValue("PushEvent('OPEN_SAFECENTER_SAFESCORE')")
        Sleep(3000)
        if nTick ~= -1 and GetTickCount() - nTick > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
ScriptOnStart(m_script_name, true, true)
_SMain()
ScriptOnStop(m_script_name)
