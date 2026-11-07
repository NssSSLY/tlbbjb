-- [功能] 买卖补给：由 dfz64.dll 字节码模块 物品/[功能] 买卖补给.lua 静态还原
-- 模块 SHA256 613203032117feb16b19ccb78668fa275571333d2e096be08a9827830182c1ec；出售名单组成、先卖后买（珍兽用品再人物药品）、补到设定数量、背包满停止按反汇编保持（functions.lua MainSellBuyItem 与 bag.lua Bag_SellItem / Bag_BuyPetItem / Bag_BuyPlayerItem）；原程序设置页的出售与补给选项改为任务设置；开始时的校场回血（要花钱）、吃副本道具、清包（删除物品）未接入；出售只按名字和绑定，原程序按类别出售与“能否出售”判断读不到；购买一次买一个，只放行药品与珍兽用品。
local m_script_name = "补给出售"
ScriptOnStart(m_script_name, true, false, false)
local cfg = TaskConfig or {}
local function List(text_, bind, out)
    for name in tostring(text_ or ""):gmatch("%S+") do table.insert(out, { name = name, bind = bind }) end
end
local function Bag_SellItem(aOtherName)
    local tSell = {}
    List(cfg.sell_any, 0, tSell)
    List(cfg.sell_unbind, 1, tSell)
    List(cfg.sell_bind, 2, tSell)
    List(aOtherName, 0, tSell)
    if cfg.sell_common == true then
        List(" 奇物 活跃金币 元丰重宝 元丰通宝 青铜古币 财富银币 熊猫金币 鸿福金币 鸿运金币 巢氏古器皿 签名足球 山海金币 珍宝币 少室山古币 ", 0, tSell)
    end
    SellBagItems(tSell)
end
local function Bag_BuyPetItem()
    local tWant = {}
    local function want(name, count)
        name = tostring(name or ""):gsub("%s", "")
        if name ~= "" and (tonumber(count) or 0) > 0 then table.insert(tWant, { name = name, count = tonumber(count) }) end
    end
    want(cfg.buy_pet_type1, cfg.buy_pet_type1_count)
    want(cfg.buy_pet_type2, cfg.buy_pet_type2_count)
    want("回旋金球", cfg.buy_hxjq_count)
    if #tWant == 0 then return end
    local bNeed = false
    for _, v in ipairs(tWant) do if Bag:GetItemCount(v.name) < v.count then bNeed = true end end
    if not bNeed then return end
    if Player:GetMoney(1) + Player:GetMoney(2) < 30000 then Bank_GetMoney(50000) end
    BuySupplies(tWant, true)
end
local function Bag_BuyPlayerItem()
    BuySupplies({ { name = "金创药", count = tonumber(cfg.buy_jcy_count) or 0 }, { name = "归灵丸", count = tonumber(cfg.buy_glw_count) or 0 } }, false)
end
function MainSellBuyItem()
    PushDebugMessage("执行：补给出售")
    -- 原规则此处先校场回血、吃副本道具，再清包（删除物品），均未接入。
    Bag_SellItem(" 小麋鹿贺卡 圣诞老人贺卡 圣诞树贺卡 ")
    Bag_BuyPetItem()
    Bag_BuyPlayerItem()
    CloseAllWindow()
    PushDebugMessage("补给出售：已完成!")
end
MainSellBuyItem()
