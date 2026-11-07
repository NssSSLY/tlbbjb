-- 领取福源礼盒：由 dfz64.dll 字节码模块 帮庄/领取福源礼盒.lua 静态还原
-- 模块 SHA256 650a25364c20ce93f899ce392ead92db7575c6b352ef66935ed3942ce5abec5c；调用、参数、等待和循环按反汇编逐条保持；帮会城市由 GoToGuild 进入（见 compat.lua）。
function _SMain()
    local nStart = GetTickCount()
    local npc = { { name = "戴三金", x = 66, y = 135 } }
    DeleteDebugMsg("#{BHSL_210715_15}")
    while true do
        if IsMyGuildCity() then
            MoveToNPC(npc[1].name, npc[1].x, npc[1].y, -1, nil, nil, MoveCallback_InMyGuild)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{BHSL_210715_03}", 1, 1000)
            QuestFrameOptionClicked_Item("#{BHSL_210715_74}", 1, 1000)
        elseif GoToGuild() == false then
            return
        end
        if IsInDebugMsg("#{BHSL_210715_15}") then return end
        Sleep(500)
        DebugStr("领取福源礼盒")
        if GetTickCount() - nStart > 120000 then return end
    end
end
_SMain()
