-- 古兰玉兑换宝石：由 dfz64.dll 字节码模块 功能/古兰玉兑换宝石.lua 静态还原
-- 模块 SHA256 982b8581bb3f879a8c6a84d940ab24d2b2163acb20afd700b48a23f11380d43b；清单解析、逐个兑换、结束条件与 120 秒上限按反汇编保持；原程序“组合”页的清单改为任务设置（格式 宝石|数量，空格分隔）；宝石数量按全角“（1级）”名字在道具栏+材料栏合计；原规则的成功提示键缺少右括号，只能按原文匹配；整理背包与移回锦囊未接入。
local m_script_name = "古兰玉兑换宝石"
ScriptOnStart(m_script_name, false, false)
local szConfig = tostring((TaskConfig or {}).gulanyu_list or "")
local tGem = { "红宝石", "绿宝石", "紫玉", "祖母绿", "黄晶石", "蓝晶石", "红晶石", "绿晶石", "黄玉", "皓石", "月光石", "碧玺", "变石" }
local function AddLevel(t)
    for _, v in ipairs(t) do
        for _, g in ipairs(tGem) do
            if string.find(v.name, g, nil, true) then v.name = g .. "（1级）"; break end
        end
    end
    return t
end
local function ReadList()
    local t = {}
    for szItem in string.gmatch(szConfig, "%S+") do
        local szName, szCount = string.match(szItem, "^(.-)|(%d+)$")
        local nCount = tonumber(szCount)
        if szName and szName ~= "" and nCount then
            local bFound = false
            for _, v in ipairs(t) do if v.name == szName then v.count = v.count + nCount; bFound = true end end
            if not bFound then t[#t + 1] = { name = szName, count = nCount } end
        else
            PushDebugMessage("兑换宝石：设置有误" .. szItem)
        end
    end
    local szInfo = "共兑换" .. #t .. "种宝石。"
    for _, v in ipairs(t) do szInfo = szInfo .. v.name .. v.count .. "个 " end
    PushDebugMessage(m_script_name .. szInfo)
    return t
end
local function GemCount(name) return Bag:GetItemCount(name) + Bag:GetItemCount(name, nil, nil, Bag:EnumCailiaoItem()) end
local function JadeCount() return Bag:GetItemCount("古兰玉") + Bag:GetItemCount("古兰玉", nil, nil, Bag:EnumTempBagItem()) end
function _SMain()
    local tList = ReadList()
    if #tList == 0 then
        PushDebugMessage(m_script_name .. "：未设置数量")
        return
    end
    AddLevel(tList)
    for _, v in ipairs(tList) do v.count_have = GemCount(v.name) end
    local nStart = GetTickCount()
    local nBefore = JadeCount()
    Bank_GetItem(" 古兰玉 ", -1)
    local nAfter = JadeCount()
    DeleteDebugMsg("累计兑换了10颗宝石")
    while true do
        if Bag:GetItemCount("古兰玉") < 30 then
            TempBank2Bag("古兰玉", 0)
            Sleep(300)
        end
        for i, v in ipairs(tList) do
            if GemCount(v.name) >= v.count + v.count_have then
                table.remove(tList, i)
                break
            end
            DeleteDebugMsg("#{FZYH_170213_28")
            GoToSceneNPC("彭怀玉", 280, 320, LUOYANG_ID)
            QuestFrameOptionClicked_Item("#{FZYH_170213_7}", 1, 700)
            DialogOptionClicked(v.name, 0, 700)
            if IsInDebugMsg("#{FZYH_170213_28") then table.remove(tList, i) end
            break
        end
        if IsInDebugMsg("累计兑换了10颗宝石") then break end
        if Bag:GetItemCount("古兰玉") < 3 then
            Bank_GetItem(" 古兰玉 ", -1)
            Sleep(500)
            if Bag:GetItemCount("古兰玉") < 3 then
                PushDebugMessage(m_script_name .. ":古兰玉不足")
                break
            end
        end
        if #tList == 0 then
            PushDebugMessage(m_script_name .. ":兑换完成！")
            break
        end
        if GetTickCount() - nStart > 120000 then
            PushDebugMessage(m_script_name .. ":超时!")
            break
        end
        Sleep(100)
        DebugStr(m_script_name)
    end
    Bag_Move2TempBank()
    if nAfter ~= nBefore then Bank_SaveItem("古兰玉") end
end
_SMain()
ScriptOnStop(m_script_name)
