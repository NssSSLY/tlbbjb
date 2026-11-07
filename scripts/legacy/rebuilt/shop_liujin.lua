-- 购买鎏金礼匣：由 dfz64.dll 字节码模块 物品/购买鎏金礼匣.lua 静态还原
-- 模块 SHA256 b5c65348190cddb5df12d8adaaa35fe11a2535f05ea34f4e85306ab35750b4d5；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。三选一按奖励名在清单里出现的先后挑选（原规则同样按位置排序）。
local m_script_name = "购买鎏金礼匣"
ScriptOnStart(m_script_name, false, false)
local szWant = tostring((TaskConfig or {}).shop_items or "")
local function OpenAndChoose()
    for _, szBox in ipairs({ "鎏金礼匣·一", "鎏金礼匣·二", "鎏金礼匣·三", "鎏金礼匣·四", "鎏金礼匣·五", "鎏金礼匣·六", "鎏金礼匣·七" }) do
        Bag:UseItemByName_click(szBox, 800)
    end
    local s1, s2, s3 = GoldGiftRead()
    s1, s2, s3 = s1:gsub("?", ""), s2:gsub("?", ""), s3:gsub("?", "")
    if s1 == "" or s2 == "" or s3 == "" then
        CloseWindow("GoldRecycle_GiftShop")
        return
    end
    local tPick = {}
    for i, s in ipairs({ s1, s2, s3 }) do
        local nPos = string.find(szWant, s, nil, true)
        if nPos then table.insert(tPick, { index = i, npos = nPos, name = s }) end
    end
    if #tPick > 0 then
        table.sort(tPick, function(a, b) return a.npos < b.npos end)
        PushColorMsg("购买：" .. tPick[1].name)
        GoldGiftChoose(tPick[1].index)
        Sleep(600)
    end
    CloseWindow("GoldRecycle_GiftShop")
end
function _SMain()
    local nBox = 0
    for _, szBox in ipairs({ "鎏金礼匣·一", "鎏金礼匣·二", "鎏金礼匣·三", "鎏金礼匣·四", "鎏金礼匣·五", "鎏金礼匣·六", "鎏金礼匣·七" }) do
        nBox = nBox + Bag:GetItemCount(szBox)
    end
    if nBox == 0 then
        PushColorMsg(m_script_name .. ":背包没有礼匣")
        return
    end
    local bTook = false
    if Player:GetMoney() < 1040000 then
        Bank_GetMoney(1040000)
        Sleep(3000)
        bTook = true
    end
    if Player:GetMoney() < 1040000 then
        PushColorMsg(m_script_name .. "：携带金币不够,暂不开启")
        return
    end
    CloseAllWindow()
    for i = 1, 2 do
        OpenAndChoose()
        Sleep(800)
    end
    if bTook then Bank_SaveMoney(0) end
end
_SMain()
ScriptOnStop(m_script_name, false)
