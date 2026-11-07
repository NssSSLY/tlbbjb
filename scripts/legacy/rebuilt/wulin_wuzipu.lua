-- 武林无字谱：由 dfz64.dll 字节码模块 任务/武林无字谱.lua 静态还原
-- 模块 SHA256 6426d4ebbbbc575d73e48a90ae0d537c00070db152cd617129b59f2694010729；调用、参数、等待和循环按反汇编逐条保持。原规则用模式匹配找 #{…} 文字，这里改成按原文查找，意思相同。
local m_script_name = "武林无字谱"
ScriptOnStart(m_script_name, true, false)
function _SMain()
    -- 闭环保护：本轮状态与上一轮相同计为没有进展，连续 6 轮就停止并写明原因（原规则没有上限）。
    local guard = NoProgress(m_script_name, 6)
    while not IsGuanShanHaiScene() do
        guard(GetPlayerMission_Item("#{XZYD_200401_42}") .. "|" .. GetPlayerMission_Item("#{XZYD_200401_45}") .. "|" .. GetPlayerMission_Item("#{XZYD_200401_48}"))
        if GetPlayerMission_Item("#{XZYD_200401_42}") ~= -1 then
            GoToSceneNPC("沈暝楼", 206, 53, 2)
            QuestFrameOptionClicked_Item("#{XZYD_200401_42}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_11}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_14}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_16}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_68}", 1, 800)
            QuestFrameMissionComplete()
            QuestFrameOptionClicked_Item("#{XZYD_200401_45}", 1, 800)
            QuestFrameAcceptClicked(600)
        elseif GetPlayerMission_Item("#{XZYD_200401_45}") ~= -1 then
            GoToSceneNPC("名士芙蓉仙子", 270, 115, 2)
            QuestFrameOptionClicked_Item("#{XZYD_200401_45}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_26}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_28}", 1, 800)
            IsWindowVisible("GiveGift", "GiveGift_GiveOneTime()")
            QuestFrameOptionClicked_Item("#{XZYD_200401_71}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_73}", 1, 800)
            QuestFrameOptionClicked_Item("#{XZYD_200401_75}", 1, 800)
            QuestFrameMissionComplete()
            QuestFrameAcceptClicked(600)
            QuestFrameOptionClicked_Item("#{XZYD_200401_48}", 1, 800)
        else
            local nIndex = GetPlayerMission_Item("#{XZYD_200401_48}")
            if nIndex ~= -1 then
                GoToSceneNPC("沈寒洲", 210, 51, 2)
                if GetMissionComplete(nIndex) ~= 1 then break end
                QuestFrameOptionClicked_Item("#{XZYD_200401_48}", 1, 800)
                QuestFrameMissionComplete()
            else
                GoToSceneNPC("沈暝楼", 206, 53, 2)
                if QuestFrameOptionClicked_Item("#{XZYD_200401_42}", 1, 800) == false then
                    local szText = GetNPCEventListAllItem()
                    if string.find(szText, "#{XZJC_200309_03}", nil, true) and not string.find(szText, "#{XZYD_200401_42}", nil, true) then break end
                end
                QuestFrameAcceptClicked(600)
            end
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name, false)
