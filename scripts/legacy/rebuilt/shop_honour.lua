-- 购买战功商品：由 dfz64.dll 字节码模块 物品/购买战功商品.lua 静态还原
-- 模块 SHA256 fd1127a0ace62e0a159879c71cefdf7228869caa681bafe436bc4bb6c6e3e7c2；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "购买战功商品"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local nStart = -1
    local tItem = ParseItemList((TaskConfig or {}).shop_items, -1)
    -- 原规则开头清理背包（ClearBag），不执行。
    CloseAllWindow()
    while true do
        if QuestFrameOptionClicked_Item("#{JWSD_140821_3}", 1, 600) then
            if IsWindowVisible("JueweiShop") then
                local bAny = false
                for _, v in ipairs(tItem) do
                    if not v.bought then
                        ShopBuy("honour", v.name, v.count)
                        v.bought = true
                        bAny = true
                        break
                    end
                end
                if not bAny then break end
            end
        else
            if GoToGuild() == false then break end
            MoveToNPC("赵子勋", 93, 54, -1, nil, nil, MoveCallback_InMyGuild)
        end
        if nStart == -1 then nStart = GetTickCount() end
        Sleep(300)
        if GetTickCount() - nStart > 120000 then
            PushColorMsg(m_script_name .. ":超时")
            break
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
