-- 领取剑指金陵渡奖励：由 dfz64.dll 字节码模块 帮庄/领取剑指金陵渡奖励.lua 静态还原
-- 模块 SHA256 85e5faca1080c3ee421a8ee7b702a4cdd02edc4502613a65b30603a69f3af33c；调用、参数、等待和循环按反汇编逐条保持；帮会城市由 GoToGuild 进入（见 compat.lua）。
local m_script_name = "领取剑指金陵渡奖励"
function _SMain()
    GoToGuild()
    local nStart = -1
    DeleteDebugMsg("#{LDDQ_20200819_66}")
    DeleteDebugMsg("#{LDDQ_20200819_96}")
    while true do
        if GoToGuild() then
            MoveToNPC("万翎峥", 107, 60, -1, nil, nil, MoveCallback_InMyGuild)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{JLDQZ_200814_128}", 1, 1000)
            DialogOptionClicked("领取道具奖励", 1, 800)
            Sleep(500)
            if IsInDebugMsg("#{LDDQ_20200819_66}") or IsInDebugMsg("#{LDDQ_20200819_96}") then break end
        else
            PushColorMsg(m_script_name .. ":没有帮派城市！")
            break
        end
        Sleep(100)
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 30000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr(m_script_name)
    end
    nStart = -1
    DeleteDebugMsg("#{DQYX_200922_58}")
    DeleteDebugMsg("#{LDDQ_20200819_96}")
    while true do
        if GoToGuild() then
            MoveToNPC("万翎峥", 107, 60, -1, nil, nil, MoveCallback_InMyGuild)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{DQYX_200922_48}", 1, 1000)
            DialogOptionClicked("领取道具奖励", 1, 800)
            Sleep(500)
            if IsInDebugMsg("#{DQYX_200922_58}") or IsInDebugMsg("#{LDDQ_20200819_96}") then break end
        else
            PushColorMsg(m_script_name .. ":没有帮派城市！")
            break
        end
        Sleep(100)
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 30000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
