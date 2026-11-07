-- 修理装备：由 dfz64.dll 字节码模块 功能/修理装备.lua 静态还原
-- 模块 SHA256 3894e9707d23ad57bad5c12c66c3439fa6d6050230973026c3789501b8e593ae；装备栏位表、阈值（武器按神器阈值）、润物露与武魂延寿丹先锦囊后仓库的取法、修理请求与最多 3 轮按反汇编保持（fn修理装备.lua XLZB_Action）；原程序[功能2]页的三个阈值改为任务设置；神器要先卸下再修理、VIP6 以下的武魂要先卸下再续命，这两种涉及卸下装备，未接入，只提示；跨服场景要扫描 NPC 对象，未接入；最后把剩余材料移回锦囊未接入。
local m_script_name = "修理装备"
ScriptOnStart(m_script_name, false, false)
PushColorMsg("修理装备：任务设置里可修改修理阈值")
local cfg = TaskConfig or {}
local tParam = { zhuangbei = tonumber(cfg.zb_limit) or 10, shenqi = tonumber(cfg.sq_limit) or 10, wuhun = tonumber(cfg.wh_limit) or 16 }
local bAtNpc = GetPlayerVipLevel() < 6
local tSlot = {
    { index = 0, class = "武器" }, { index = 1, class = "帽子" }, { index = 2, class = "衣服" }, { index = 3, class = "手套" }, { index = 4, class = "鞋" },
    { index = 5, class = "腰带" }, { index = 6, class = "戒指" }, { index = 7, class = "项链" }, { index = 8, class = "骑乘" }, { index = 9, class = "行囊" },
    { index = 10, class = "箱格" }, { index = 11, class = "戒指" }, { index = 12, class = "护符" }, { index = 13, class = "护符" }, { index = 14, class = "护腕" },
    { index = 15, class = "护肩" }, { index = 16, class = "时装" }, { index = 17, class = "暗器" }, { index = 18, class = "武魂" }, { index = 19, class = "龙纹" },
    { index = 20, class = "令牌" }, { index = 21, class = "豪侠印" },
}
local tSkip = { [8] = true, [9] = true, [10] = true, [16] = true, [17] = true, [18] = true }
local function GoRepairNPC()
    if bAtNpc and not IsDestination(354, 249, 1, 3) then
        GoToSceneNPC("薛菲", 354, 249, 1)
        Sleep(800)
    end
end
local function TakeItem(szName)
    if Bag:GetItemCount(szName) > 0 then return true end
    if TempBank2Bag(szName) == false then
        PushColorMsg("仓库取" .. szName)
        Bank_GetItem(szName, 1)
    end
    Sleep(1000)
    return Bag:GetItemCount(szName) > 0
end
local function RepairEquip()
    local bAny = false
    for _, v in ipairs(tSlot) do
        if not tSkip[v.index] then
            local nLimit = v.index == 0 and tParam.shenqi or tParam.zhuangbei
            local tid, szName, nDefine, nLeft = EquipDurability(v.index, math.max(1, math.min(100, nLimit)))
            if tid ~= 0 and szName ~= "" then
                bAny = true
                if v.index == 0 and nDefine >= 10300000 and nDefine <= 10399999 then
                    -- 原规则：神器卸下到背包修理后再装上。
                    PushColorMsg("修理神器: " .. szName .. " 需要卸下修理，未接入，请手动修理")
                else
                    if nLeft == 0 and TakeItem("润物露") then
                        PushColorMsg("修理装备：使用润物露 " .. szName)
                        GoRepairNPC()
                        EquipRestoreCount(v.index, bAtNpc)
                        Sleep(500)
                    end
                    GoRepairNPC()
                    EquipRepairAt(v.index, bAtNpc)
                    PushColorMsg("修理装备: " .. szName)
                    Sleep(500)
                end
            end
        end
    end
    if not bAny then PushDebugMessage("修理装备：已经没有可修理的装备！") end
    return bAny
end
local function RepairWuhun()
    local bLow = WuhunLowLife(math.max(1, tParam.wuhun))
    if not bLow then
        PushDebugMessage("武魂寿命大于" .. tParam.wuhun .. "无需修理。")
        return false
    end
    if not TakeItem("武魂延寿丹") then
        PushColorMsg("修理武魂：没有武魂延寿丹。")
        return true
    end
    if bAtNpc then
        -- 原规则：VIP6 以下先卸下武魂，在背包里续命后再装上。
        PushColorMsg("修理武魂：VIP6 以下需要先卸下武魂，未接入，请手动续命")
        return false
    end
    if Player:GetMoney(1) + Player:GetMoney(2) < 50000 then
        PushColorMsg("修理武魂：取出5J")
        Bank_GetMoney(50000)
    end
    WuhunAddLife()
    Sleep(1000)
    return true
end
function XLZB_Action()
    for _ = 1, 3 do
        if not RepairEquip() then break end
        Sleep(1000)
    end
    for _ = 1, 3 do
        if not RepairWuhun() then break end
        Sleep(1000)
    end
end
XLZB_Action()
ScriptOnStop(m_script_name, false)
