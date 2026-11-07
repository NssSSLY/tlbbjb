-- 合成中级勾天彩：由 dfz64.dll 字节码模块 功能/合成中级勾天彩.lua 静态还原
-- 模块 SHA256 77e3723251531ab89b7c540a8a054f2ed7de404bf40c0b881c78081b70e017b9；调用、参数、等待和循环按反汇编逐条保持。结束时把物品挪回锦囊的步骤未接入，物品留在背包。
local m_script_name = "合成中级勾天彩"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    DeleteDebugMsg("#{GTCHC_140213_19}")
    DeleteDebugMsg("#{GTCHC_140213_20}")
    local function GetCount()
        local nItem = Bag:GetItemCount("初级勾天彩", nil, nil, Bag:EnumCailiaoItem()) + Bag:GetItemCount("初级勾天彩", nil, nil, Bag:EnumTempBagItem())
        local nFu = Bag:GetItemCount("初级勾天彩合成符") + Bag:GetItemCount("初级勾天彩合成符", nil, nil, Bag:EnumTempBagItem())
        return nItem, nFu
    end
    local nItem, nFu = GetCount()
    local szTake = ""
    if nItem < 5 then szTake = szTake .. " 初级勾天彩 " end
    if nFu < 1 then szTake = szTake .. " 初级勾天彩合成符 " end
    if szTake ~= "" then
        Bank_GetItem(szTake, -1, nil, nil, true)
        Sleep(500)
    end
    nItem, nFu = GetCount()
    if nItem >= 5 and nFu >= 1 then
        local nStart = -1
        TempBank2Bag("初级勾天彩 初级勾天彩合成符", 0)
        while true do
            GoToSceneNPC("焦鹰", 125, 201, 850)
            if nStart == -1 then nStart = GetTickCount() end
            if GetTickCount() - nStart > 120000 then
                PushColorMsg(m_script_name .. ":超时120秒！")
                break
            end
            QuestFrameOptionClicked_Item("#{GTCHC_140213_01}", 1, 600)
            QuestFrameOptionClicked_Item("#{GTCHC_140213_04}", 1, 600)
            IsWindowVisible("GouTianCai_HC", "GouTianCai_HC_OnOK()")
            if IsInDebugMsg("#{GTCHC_140213_19}") or IsInDebugMsg("#{GTCHC_140213_20}") then
                TempBank2Bag("初级勾天彩 初级勾天彩合成符", 0)
                nItem, nFu = GetCount()
                if nItem < 5 or nFu < 1 then
                    PushColorMsg(m_script_name .. ":材料不足")
                    break
                end
            end
            Sleep(100)
            DebugStr(m_script_name)
        end
    else
        PushColorMsg(m_script_name .. ":您已没有足够的材料")
    end
    Bag_Move2TempBank(" 初级勾天彩 中级勾天彩 初级勾天彩合成符 ")
end
_SMain()
ScriptOnStop(m_script_name)
