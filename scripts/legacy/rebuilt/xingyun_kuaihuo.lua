-- 幸运快活三：由 dfz64.dll 字节码模块 日常/幸运快活三.lua 静态还原
-- 模块 SHA256 eab9187c48c6b7bcde306f3bdc761e8be257da26b8d9a2a279353fabecb1217a；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "幸运快活三"
ScriptOnStart(m_script_name)
local function IsAllOpen()
    return XingYunEmptyHeads() == 20
end
function _SMain()
    local nStart = -1
    local tPlayed = {}
    while true do
        if IsWindowVisible("XingYun") == false then
            GoToSceneNPC("柳月虹", 230, 350, 1)
            Sleep(600)
            QuestFrameOptionClicked_Item("幸运快活三", 1, 800)
            local szText = GetNPCEventList_Item(0)
            if string.find(szText, "已经参加", nil, true) then
                for i = 1, 6 do
                    GoToSceneNPC("柳月虹", 230, 350, 1)
                    QuestFrameOptionClicked_Item("领取幸运快活三奖励", 1, 800)
                    if GetNPCEventList_Item(0) == "#{XYLP_20071222_02}" then break end
                    Sleep(500)
                end
                break
            elseif string.find(szText, "再等60分钟", nil, true) then
                PushDebugMessage("幸运快活三：距离上次参加快活三的时间太短")
                break
            end
        else
            math.randomseed(GetTickCount())
            local nPick = math.random(1, 20)
            local bNew = true
            for i = 1, #tPlayed do
                if tPlayed[i] == nPick then bNew = false; break end
            end
            if bNew then
                table.insert(tPlayed, nPick)
                GetLuaValue(string.format("setmetatable(_G, {__index = XingYun_Env});Play_Ani(%d)", nPick))
                Sleep(1000)
            end
            if IsAllOpen() then
                PushDebugMessage("快活三任务完成！")
                GetLuaValue("setmetatable(_G, {__index = XingYun_Env});XingYun_Close()")
            end
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        Sleep(1000)
        DebugStr("幸运快活三")
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
