-- 捎口信：由 dfz64.dll 字节码模块 任务/捎口信.lua 静态还原
-- 模块 SHA256 5f96eaf12dbe01410370b1a5a68750f40102c1984423d10feeea2974f3478836；调用、参数、等待和循环按反汇编逐条保持。关闭背包界面（CloseWindow("Packet")）不在可关闭名单里，跳过。
local m_script_name = "捎口信"
ScriptOnStart(m_script_name, true, false)
function _SMain()
    -- 闭环保护：本轮状态与上一轮相同计为没有进展，连续 6 轮就停止并写明原因（原规则没有上限）。
    local guard = NoProgress(m_script_name, 6)
    while true do
        local nIndex = GetPlayerMission_Item(m_script_name)
        guard(nIndex .. "|" .. (nIndex ~= -1 and GetMissionDesc(m_script_name) or ""))
        if nIndex ~= -1 then
            local npc = GetMissionDesc_NPC(m_script_name)
            if npc then
                GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
                Sleep(500)
                if QuestFrameOptionClicked_Item(m_script_name, 1, 1000) then
                    QuestFrameMissionComplete(0, 400)
                    CloseWindow("Packet")
                end
            end
        else
            GoToSceneNPC("邱行洛", 232, 319, LUOYANG_ID)
            QuestFrameOptionClicked_Item(m_script_name, 1, 1000)
            if string.find(GetNPCEventList_Item(0), "10次口信", nil, true) then
                PushDebugMessage("捎口信：已完成")
                break
            end
        end
        Sleep(200)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
