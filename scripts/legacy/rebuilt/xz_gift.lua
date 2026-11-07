-- 名士赠礼：由 dfz64.dll 字节码模块 功能/名士赠礼.lua 静态还原
-- 模块 SHA256 abd4868650ce50bb0337f53afa2fd8d6b792c621d6f5675bc2dc7584ea57f8c1；内置礼物表、能否赠送的判断、十次/单次赠送次数与结束条件按反汇编保持；原程序设置页可追加的赠礼条目（物品-场景-名士-秘籍）只放行内置名单，未接入；原规则每轮还按物品类别打开绑定礼包（OpenBindItem），类别读不到，未接入。
local m_script_name = "名士赠礼"
ScriptOnStart(m_script_name, false, false)
local tGift = {
    { itemName = "剑谱", npcName = "乔峰" }, { itemName = "女儿红", npcName = "乔峰" }, { itemName = "胭脂盒", npcName = "王语嫣" },
    { itemName = "湖州笔", npcName = "阿朱" }, { itemName = "酸角糕", npcName = "天山童姥" }, { itemName = "澄心纸", npcName = "天山童姥" },
    { itemName = "青玉佩", npcName = "慕容复" }, { itemName = "满日弓", npcName = "李秋水" }, { itemName = "玄铁矿石", npcName = "李秋水" },
    { itemName = "徐夫人匕", npcName = "梦姑" }, { itemName = "琴箫曲谱", npcName = "慕容复" }, { itemName = "朱砂印泥", npcName = "无崖子" },
    { itemName = "义山诗集", npcName = "虚竹" }, { itemName = "三段锦紫牙", npcName = "阿朱" }, { itemName = "桃花泉奕谱", npcName = "段誉" },
}
local function Give(aItem)
    if not XZOpenGift(aItem.itemName) then return false end
    Sleep(1000)
    if IsWindowVisible("GiveGift") then
        DeleteDebugMsg("#{XZYX_200309_18}")
        local nCount = Bag:GetItemCount(aItem.itemName)
        if nCount >= 10 then
            for _ = 1, math.floor(nCount / 10) do
                GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveTenTime()")
                Sleep(50)
                if IsInDebugMsg("#{XZYX_200309_18}") then break end
            end
            for _ = 1, nCount % 10 do
                GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveOneTime()")
                Sleep(50)
            end
        else
            for _ = 1, nCount do
                GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveOneTime()")
                Sleep(50)
                if IsInDebugMsg("#{XZYX_200309_18}") then break end
            end
        end
        GetLuaValue("setmetatable(_G, {__index = GiveGift_Env});GiveGift_GiveOneTime()")
    end
    return true
end
local function TryGift(aItem)
    if Bag:GetItemCount(aItem.itemName) == 0 then return false end
    return Give(aItem)
end
function _SMain()
    local szItem = ""
    for _, v in ipairs(tGift) do szItem = szItem .. v.itemName .. " " end
    Bank_GetItem(szItem)
    TempBank2Bag(szItem)
    local nStart = GetTickCount()
    while true do
        local bAny = false
        for _, v in ipairs(tGift) do
            if not v.comp then
                if TryGift(v) then
                    bAny = true
                    break
                end
                v.comp = true
            end
        end
        Sleep(300)
        if not bAny then break end
        if GetTickCount() - nStart > 600000 then
            PushColorMsg("名士赠礼：执行超时！")
            break
        end
        DebugStr(m_script_name)
    end
    CloseWindow("GiveGift")
end
_SMain()
ScriptOnStop(m_script_name, false)
