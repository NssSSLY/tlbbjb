-- 合成精铁：由 dfz64.dll 字节码模块 功能/合成精铁.lua 静态还原
-- 模块 SHA256 1858fab7328204bf3b17486c45ab2ea252b7b93871e5a1e761ee714982a97dcb；NPC、界面操作、数量、等待与 300 秒上限按反汇编保持。原程序有四种绑定模式（绑定优先/只绑定/只非绑定/混合），材料栏、仓库、锦囊的绑定状态读法尚未实测，本程序只实现“混合（不区分绑定）”；
-- 原规则每轮先整理背包（Bag:PackUp），取不出材料时清包并存仓（ClearBag / MainBankSaveItem），这些未接入。
local m_script_name = "合成精铁"
ScriptOnStart(m_script_name, false, false)
local hc_level = math.floor(tonumber((TaskConfig or {}).compose_level) or 1)
if hc_level < 1 or hc_level > 4 then hc_level = 1 end
local count = 5
local function Names()
    local t = { "精铁碎片" }
    if hc_level >= 2 then t[#t + 1] = "1级精铁" end
    if hc_level >= 3 then t[#t + 1] = "2级精铁" end
    if hc_level >= 4 then t[#t + 1] = "3级精铁" end
    return t
end
-- 混合模式：材料栏里够 5 个的先合；否则材料栏有、加上锦囊和仓库够 5 个的；否则任何够 5 个的。
local function Pick()
    local names = Names()
    local bank = ItemTotals("bank", "精铁", names)
    local mat = ItemTotals("material", "精铁", names)
    local temp = ItemTotals("temp", "精铁", names)
    local all = MergeItemTotals(MergeItemTotals(MergeItemTotals({}, mat), temp), bank)
    for _, v in ipairs(mat) do if v.num >= count then return v.name end end
    for _, v in ipairs(mat) do
        for _, w in ipairs(all) do if w.name == v.name and w.num >= count then return v.name end end
    end
    for _, w in ipairs(all) do if w.num >= count then return w.name end end
    return ""
end
local function HaveCount(name)
    return Bag:GetItemCount(name) + Bag:GetItemCount(name, nil, nil, Bag:EnumCailiaoItem())
end
local function CheckMoney()
    if Player:GetMoney(1) + Player:GetMoney(2) < 5000 then
        PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
        Bank_GetMoney(5000 * 10)
        return false
    end
    return true
end
local function Level(name)
    if string.find(name, "碎片", nil, true) then return 0
    elseif string.find(name, "1级", nil, true) then return 1
    elseif string.find(name, "2级", nil, true) then return 2
    elseif string.find(name, "3级", nil, true) then return 3 end
    return -1
end
local function Compose(name)
    local nLevel = Level(name)
    if IsWindowVisible("CaiLiaoCompound") and nLevel ~= -1 then
        GetLuaValue("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_List:SetItemSelectByItemID(10003)")
        Sleep(800)
        GetLuaValue(string.format("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_List:SetItemSelectByItemID(%d)", nLevel))
        Sleep(800)
        GetLuaValue("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_OnMaxNum();")
        Sleep(500)
        GetLuaValue("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_OK_Click();")
        Sleep(800)
        MessageBox_Self2_OK_Clicked()
    else
        GoToSceneNPC("彭怀玉", 282, 321, LUOYANG_ID)
        Sleep(500)
        QuestFrameOptionClicked_Item("材料合成", 1, 700)
    end
end
function _SMain()
    local nStart = GetTickCount()
    while true do
        local szName = Pick()
        if szName == "" then
            PushColorMsg(m_script_name .. ":您已没有需要合成的材料")
            break
        end
        if HaveCount(szName) < count then
            TempBank2Bag(szName)
            Sleep(300)
        end
        if HaveCount(szName) < count then
            Bank_GetItem(szName, -1)
            Sleep(300)
        end
        if HaveCount(szName) >= count then
            if CheckMoney() then Compose(szName) else DebugStr(m_script_name .. ":金币不足") end
        else
            DebugStr(szName .. ":取出失败")
        end
        if GetTickCount() - nStart > 300000 then
            PushColorMsg(m_script_name .. ":超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
