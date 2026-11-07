-- 兑换幻色勾天彩：由 dfz64.dll 字节码模块 功能/兑换幻色勾天彩.lua 静态还原
-- 模块 SHA256 0a4dcc22c49bc54aefabf3b2173a38c63336d737975dbf89b641e3b15939c454；调用、参数、等待和循环按反汇编逐条保持。结束时把物品挪回锦囊的步骤未接入，物品留在背包。
local m_script_name = "兑换幻色勾天彩"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local nItem = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumCailiaoItem())
    local nTemp = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumTempBagItem())
    if nItem + nTemp < 5 then Bank_GetItem(" 高级勾天彩 ", -1, nil, nil, true) end
    nItem = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumCailiaoItem())
    nTemp = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumTempBagItem())
    local nStart = -1
    if nItem + nTemp >= 5 then
        while true do
            if Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumCailiaoItem()) < 5 then TempBank2Bag("高级勾天彩", 0) end
            GoToSceneNPC("焦鹰", 125, 201, 850)
            if nStart == -1 then nStart = GetTickCount() end
            if GetTickCount() - nStart > 120000 then
                PushColorMsg(m_script_name .. ":超时120秒！")
                break
            end
            QuestFrameOptionClicked_Item("#{GTCHC_140213_01}", 1, 600)
            QuestFrameOptionClicked_Item("#{LW_KVK_130426_9}", 1, 600)
            local szText = GetNPCEventList_Item(0)
            if szText == "#{LW_KVK_130426_6}" then
                PushColorMsg(m_script_name .. ":高级勾天彩不足")
                break
            elseif szText == "#{LW_KVK_130426_5}" then
                break
            end
            Sleep(100)
            DebugStr(m_script_name)
        end
    else
        PushColorMsg(m_script_name .. ":您已没有足够的高级勾天彩")
    end
    Bag_Move2TempBank(" 高级勾天彩 幻色勾天彩 ")
end
_SMain()
ScriptOnStop(m_script_name)
