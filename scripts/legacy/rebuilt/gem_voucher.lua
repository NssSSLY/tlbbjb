-- 宝石兑换券：由 dfz64.dll 字节码模块 功能/宝石兑换券.lua 静态还原
-- 模块 SHA256 41c1a1b12323583080efc05b9e241f72e00a228fa72409afcf1b5a5966e344a3；NPC、选项、判断顺序与 90 秒上限按反汇编保持；原程序“设置”页的两个下拉框改为任务设置里的文字（填写要点的宝石选项，按包含匹配）。
local m_script_name = "宝石兑换券"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local cfg = TaskConfig or {}
    local szGem3 = tostring(cfg.voucher_gem3 or "")
    local szGem4 = tostring(cfg.voucher_gem4 or "")
    CloseWindow("Quest")
    local n3 = Bag:GetItemCount("3级宝石兑换券")
    local n4 = Bag:GetItemCount("4级宝石兑换券")
    local t3 = Bag:GetItemCount("3级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
    local t4 = Bag:GetItemCount("4级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
    if n3 == 0 and n4 == 0 and t3 == 0 and t4 == 0 then
        PushColorMsg(m_script_name .. ":您没有兑换券")
        return
    end
    local nStart = -1
    while true do
        n3 = Bag:GetItemCount("3级宝石兑换券")
        n4 = Bag:GetItemCount("4级宝石兑换券")
        t3 = Bag:GetItemCount("3级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
        t4 = Bag:GetItemCount("4级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
        if IsDestination(68, 45, 224, 3) then
            local szText = GetNPCEventListAllItem()
            if string.find(szText, "#{Agreement_Info_OK}", nil, true) then
                QuestFrameOptionClicked_Item("#{Agreement_Info_OK}", 1, 700)
            elseif string.find(szText, "猫眼石", nil, true) and string.find(szText, "红宝石", nil, true) then
                if string.find(szText, "(3级)", nil, true) then
                    if n3 > 0 and szGem3 ~= "" then QuestFrameOptionClicked_Item(szGem3, 0, 700) else CloseWindow("Quest") end
                elseif string.find(szText, "(4级)", nil, true) then
                    if n4 > 0 and szGem4 ~= "" then QuestFrameOptionClicked_Item(szGem4, 0, 700) else CloseWindow("Quest") end
                end
            elseif string.find(szText, "#{CZDH_XML_1}", nil, true) then
                if n3 > 0 then
                    QuestFrameOptionClicked_Item("#{CZDH_XML_1}", 1, 700)
                elseif n4 > 0 then
                    QuestFrameOptionClicked_Item("#{BSDHQ_140327_05}", 1, 700)
                end
            else
                GoToSceneNPC("钱夫人", 68, 45, 224)
                Sleep(500)
                QuestFrameOptionClicked_Item("#{BSDHQ_140327_02}", 1, 700)
            end
        else
            GoToSceneNPC("钱夫人", 68, 45, 224)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{BSDHQ_140327_02}", 1, 700)
        end
        if n3 <= 0 and n4 <= 0 then
            if t3 > 0 or t4 > 0 then
                TempBank2Bag(" 3级宝石兑换券 4级宝石兑换券 ")
            else
                PushColorMsg(m_script_name .. "：您已经没有宝石兑换券")
                break
            end
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 90000 then break end
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name, false)
