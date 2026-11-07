-- 购买玲珑阁物品：由 dfz64.dll 字节码模块 物品/购买玲珑阁物品.lua 静态还原
-- 模块 SHA256 3061e7c7eab457d4ab3acbe4c120ae2e832aa96063850e7123f099361cd44d2f；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "购买玲珑阁物品"
ScriptOnStart(m_script_name)
function _SMain()
    CloseAllWindow()
    local tItem = {}
    for _, v in ipairs(ParseItemList((TaskConfig or {}).shop_items, -1)) do
        table.insert(tItem, { name = v.name, buy_count = v.count, old_count = Bag:GetItemCount(v.name) })
    end
    local nStart = -1
    while true do
        if not IsWindowVisible("ChongLou_DaibiShop") then
            MoveToNPC("李问禅", 106, 59, -1, nil, nil, MoveCallback_InMyGuild)
            Sleep(500)
            DialogOptionClicked("玲珑阁", 1, 800)
        end
        if IsWindowVisible("ChongLou_DaibiShop") then
            local bBuying = false
            for _, v in ipairs(tItem) do
                if v.buy_count > 0 then
                    local nLeft = v.buy_count - (Bag:GetItemCount(v.name) - v.old_count)
                    if nLeft >= 0 then v.buy_count = nLeft else v.buy_count = 0 end
                end
                if v.buy_count ~= 0 then
                    local nResult = ShopBuy("chonglou", v.name, v.buy_count)
                    Sleep(800)
                    if nResult == 0 then
                        bBuying = true
                        break
                    end
                    v.buy_count = 0
                    if nResult == 1 then
                        PushColorMsg(m_script_name .. ":非限购物品请在名称后面输入物品数量：" .. v.name)
                    elseif nResult == 3 then
                        PushColorMsg(m_script_name .. ":没有此商品 " .. v.name)
                    else
                        PushColorMsg("购买完成 " .. v.name)
                    end
                end
            end
            if not bBuying then
                PushColorMsg(m_script_name .. ":购买完成")
                break
            end
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. "：购买超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
