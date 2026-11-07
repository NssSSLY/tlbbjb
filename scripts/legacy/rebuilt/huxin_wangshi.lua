-- 湖心往事：由 dfz64.dll 字节码模块 活动/湖心往事.lua 静态还原
-- 模块 SHA256 c6c90befcf119df008676746a69b1707cdfe09f8bb13a37d282fd3fd144ee9f8；调用、参数、等待和循环按反汇编逐条保持。原规则循环里每轮先离队，本程序不自动离队；原规则循环内没有等待，这里每轮加 0.5 秒，避免空转。
local m_script_name = "湖心往事"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    if GetSceneID() ~= 1031 then
        -- 原规则此处先 Team:LeaveTeam() 离开队伍；本程序不自动离队。
        GoToSceneNPC("宁采臣", 69, 146, 1039)
        Sleep(1000)
        GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(77);")
        Sleep(1000)
        GetLuaValue("setmetatable(_G, {__index = Qixi_HuaJuan_Env});Qixi_HuaJuan_Story_Goto();")
        Sleep(1000)
        GoToSceneNPC("宁采臣", 69, 146, 1039)
        Sleep(300)
        Dismount()
        QuestFrameOptionClicked_Item("#{QNHJ_250609_08}", 1, 600)
        Sleep(1000)
        QuestFrameMissionComplete(nil, 700)
        Sleep(1000)
        QuestFrameAcceptClicked(2000)
        Sleep(1000)
        QuestFrameMissionComplete(nil, 700)
    end
    -- 闭环保护：本轮状态与上一轮相同计为没有进展，连续 12 轮就停止并写明原因（原规则没有上限）。
    local guard = NoProgress(m_script_name, 12)
    while true do
        local nIndex = GetPlayerMission_Item("#{HXWS_20250613_62}")
        guard(nIndex .. "|" .. (nIndex ~= -1 and GetMissionComplete(nIndex) or "") .. "|" .. GetSceneID())
        if nIndex == -1 then
            DeleteDebugMsg("#{HXWS_20250613_31}")
            GoToSceneNPC("宁采臣", 69, 146, 1039)
            Sleep(300)
            Dismount()
            QuestFrameOptionClicked_Item("#{HXWS_20250613_11}", 1, 600)
            Sleep(1000)
            QuestFrameAcceptClicked(2000)
            if IsInDebugMsg("#{HXWS_20250613_31}") then break end
        elseif GetMissionComplete(nIndex) == 0 then
            if GetSceneID() == 1031 then
                GoToSceneNPC("聂小倩", 64, 34, 1031)
                Sleep(300)
                QuestFrameOptionClicked_Item("#{HXWS_20250613_9}", 1, 600)
            end
        else
            GoToSceneNPC("宁采臣", 69, 146, 1039)
            Sleep(300)
            QuestFrameOptionClicked_Item("#{HXWS_20250613_11}", 1, 600)
            Sleep(1000)
            GetLuaValue("setmetatable(_G, {__index = Qixi_HuaJuan_Env});Qixi_HuaJuan_RewardClicked(1)")
            break
        end
        Sleep(500)
    end
end
_SMain()
ScriptOnStop(m_script_name, true)
