-- 购买云锦行物品：由 dfz64.dll 字节码模块 物品/购买云锦行物品.lua 静态还原
-- 模块 SHA256 09c81ecc711c037f1664b2188249861b97c8ae220af1d219a3d75f68261283f9；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "购买云锦行物品"
ScriptOnStart(m_script_name)
function _SMain()
    CloseAllWindow()
    local tItem = ParseItemList((TaskConfig or {}).shop_items, 0)
    local nStart = -1
    while true do
        if not IsWindowVisible("ActivitySchedule_Shop2") then
            GoToSceneNPC("付云伤", 356, 235, LUOYANG_ID)
            Sleep(500)
            DialogOptionClicked("云锦行", 1, 800)
        end
        if IsWindowVisible("ActivitySchedule_Shop2") then
            local szBuy = nil
            for _, v in ipairs(tItem) do
                if not v.bought and HuoYueShopBuy(2, v.name, v.count) == 1 then
                    v.bought = true
                    szBuy = v.name
                    break
                end
            end
            if not szBuy then
                PushColorMsg("云锦行：没有可购买的物品")
                break
            end
            CloseAllWindow()
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg("云锦行：购买超时")
            break
        end
        Sleep(500)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
