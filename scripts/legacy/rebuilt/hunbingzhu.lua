-- 合成魂冰珠：由 dfz64.dll 字节码模块 功能/合成魂冰珠.lua 静态还原
-- 模块 SHA256 a140c4c066a93f6233caa95ad1e975a38e1753ca3a985813d2445255e21c7ad0；NPC、选项、数量、等待与 10 分钟上限按反汇编保持；原规则开头的清包与整理背包、取不出材料时的清包/存仓/整理未接入；数量按道具栏+材料栏合计。
local m_script_name = "合成魂冰珠"
ScriptOnStart(m_script_name, false, false)
local hc_level = math.floor(tonumber((TaskConfig or {}).hunbing_level) or 2)
if hc_level < 2 or hc_level > 5 then hc_level = 2 end
local count = 5
local function Names()
    local t = { "魂冰珠（1级）" }
    if hc_level >= 3 then t[#t + 1] = "魂冰珠（2级）" end
    if hc_level >= 4 then t[#t + 1] = "魂冰珠（3级）" end
    if hc_level >= 5 then t[#t + 1] = "魂冰珠（4级）" end
    return t
end
local function Pick()
    local names = Names()
    local mat = ItemTotals("material", "魂冰珠", names)
    local bank = ItemTotals("bank", "魂冰珠", names)
    local temp = ItemTotals("temp", "魂冰珠", names)
    local all = MergeItemTotals(MergeItemTotals(MergeItemTotals({}, mat), bank), temp)
    for _, v in ipairs(mat) do if v.num >= count then return v.name end end
    for _, v in ipairs(all) do if v.num >= count then return v.name end end
    return ""
end
local function HaveCount(name)
    return Bag:GetItemCount(name) + Bag:GetItemCount(name, nil, nil, Bag:EnumCailiaoItem())
end
local function CheckMoney()
    if Player:GetMoney(1) + Player:GetMoney(2) < 10000 then
        PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
        Bank_GetMoney(10000 * 10)
        return false
    end
    return true
end
local function Compose(name)
    local tTarget = {}
    tTarget["魂冰珠（1级）"] = "合成魂冰珠（2级）"
    tTarget["魂冰珠（2级）"] = "合成魂冰珠（3级）"
    tTarget["魂冰珠（3级）"] = "合成魂冰珠（4级）"
    tTarget["魂冰珠（4级）"] = "合成魂冰珠（5级）"
    local szTarget = tTarget[name]
    if not szTarget then
        PushColorMsg(m_script_name .. ":名称不正确" .. name)
        return
    end
    local szText = GetNPCEventListAllItem()
    if string.find(szText, "#{WH_xml_XX(112)}", nil, true) then
        if IsInDebugMsg("#{WU_090908_09}") or IsInDebugMsg("#{WU_090908_10}") or IsInDebugMsg("#{WU_090908_11}") or IsInDebugMsg("#{WU_090908_12}") then
            DeleteDebugMsg("#{WU_090908_09}")
            DeleteDebugMsg("#{WU_090908_10}")
            DeleteDebugMsg("#{WU_090908_11}")
            DeleteDebugMsg("#{WU_090908_12}")
            CloseWindow("Quest")
        end
    else
        GoToSceneNPC("武桐", 139, 197, 2)
        Sleep(500)
        DialogOptionClicked("魂冰珠合成", 1, 700)
        DialogOptionClicked(szTarget, 1, 700)
    end
    QuestFrameOptionClicked_Item("#{WH_xml_XX(112)}", 1, 700)
end
function _SMain()
    DeleteDebugMsg("#{WU_090908_09}")
    DeleteDebugMsg("#{WU_090908_10}")
    DeleteDebugMsg("#{WU_090908_11}")
    DeleteDebugMsg("#{WU_090908_12}")
    local nStart = GetTickCount()
    while true do
        local szName = Pick()
        if szName == "" then
            PushColorMsg(m_script_name .. ":您已没有需要合成的材料")
            break
        end
        if HaveCount(szName) < count then
            TempBank2Bag(szName)
            Sleep(800)
        end
        if HaveCount(szName) < count then
            Bank_GetItem(szName, -1)
            Sleep(800)
        end
        if HaveCount(szName) >= count then
            if CheckMoney() then Compose(szName) else DebugStr(m_script_name .. ":金币不足") end
        else
            PushColorMsg(szName .. ":取出失败")
        end
        if GetTickCount() - nStart > 600000 then
            PushColorMsg(m_script_name .. ":超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
