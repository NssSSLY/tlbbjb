-- 领取上周紫微奖励：由 dfz64.dll 字节码模块 帮庄/领取上周紫微奖励.lua 静态还原
-- 模块 SHA256 cb6f5686cbb3856206e8866115c4176f30d18c17ecbf4b281dee90f78132ec5e；调用、参数、等待和循环按反汇编逐条保持；帮会城市由 GoToGuild 进入（见 compat.lua）。
local m_script_name = "领取上周紫微奖励"
ScriptOnStart(m_script_name)
function _SMain()
    GoToGuild()
    DeleteDebugMsg("#{ZJSJ_220708_44}")
    DeleteDebugMsg("#{ZJSJ_220708_72}")
    DeleteDebugMsg("#{ZJSJ_220708_73}")
    local nStart = -1
    while true do
        if GoToGuild() then
            MoveToNPC("姜星落", 93, 59, -1, nil, nil, MoveCallback_InMyGuild)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{ZJSJ_220708_7}", 1, 1000)
            QuestFrameOptionClicked_Item("#{ZJSJ_220708_7}", 1, 1000)
            Sleep(500)
            if IsInDebugMsg("#{ZJSJ_220708_44}") or IsInDebugMsg("#{ZJSJ_220708_72}") or IsInDebugMsg("#{ZJSJ_220708_73}") then break end
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
