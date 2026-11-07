-- 领取战功奖励：由 dfz64.dll 字节码模块 帮庄/领取战功奖励.lua 静态还原
-- 模块 SHA256 d00b6549b2133aa154ec3acd070348aab41e5a4762b0d0dd16f269d90c5f01e0；调用、参数、等待和循环按反汇编逐条保持；帮会城市由 GoToGuild 进入（见 compat.lua）。
local m_script_name = "领取战功奖励"
ScriptOnStart(m_script_name)
function _SMain()
    GoToGuild()
    local nStart = -1
    while true do
        if GoToGuild() then
            MoveToNPC("赵子勋", 93, 54, -1, nil, nil, MoveCallback_InMyGuild)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{ZGMW_201009_01}", 1, 1000)
            IsWindowVisible("T3ZhanGongGet", "T3ZhanGongGet_OnOKClicked()")
            Sleep(500)
            if IsInDebugMsg("#{ZGMW_201009_33}") or IsInDebugMsg("#{ZGMW_201009_34}") or IsInDebugMsg("#{ZGMW_201009_35}") then break end
        else
            PushColorMsg(m_script_name .. ":没有帮派城市！")
            break
        end
        Sleep(100)
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
