-- 购买百宝阁商品：由 dfz64.dll 字节码模块 物品/购买百宝阁商品.lua 静态还原
-- 模块 SHA256 5b324945670c91bd3ed853f2779b8d752ac196732b6a98fe0e972765b9722151；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "购买百宝阁商品"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local nStart = -1
    local tItem = ParseItemList((TaskConfig or {}).shop_items, -1)
    -- 原规则开头清理背包（ClearBag），不执行。
    CloseAllWindow()
    while true do
        if GoToGuild() == false then break end
        if IsWindowVisible("BangHui_Shop") then
            local bAny = false
            for _, v in ipairs(tItem) do
                if not v.bought then
                    bAny = true
                    ShopBuy("guild", v.name, v.count)
                    v.bought = true
                    break
                end
            end
            if not bAny then break end
        else
            MoveToNPC("万藏宝", 149, 44, -1, nil, nil, MoveCallback_InMyGuild)
            QuestFrameOptionClicked_Item("#{BHSC_140509_04}", 1, 500)
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 90000 then
            PushColorMsg(m_script_name .. ":购买超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
