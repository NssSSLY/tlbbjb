-- 购买中都行商：由 dfz64.dll 字节码模块 物品/购买中都行商.lua 静态还原
-- 模块 SHA256 6a6b98966ecc72ad100011e715e31e3f9832bb28a15a6313c79fa6331dd43d3b；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "购买中都行商"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local nStart = -1
    -- 原规则开头清理背包（ClearBag），不执行。
    CloseAllWindow()
    local tItem = ParseItemList((TaskConfig or {}).shop_items, 3)
    for _, v in ipairs(tItem) do v.canbuy = true end
    if #tItem == 0 then
        PushColorMsg(m_script_name .. ":没有正确的物品名称,多个物品空格分开")
        CloseAllWindow()
        return
    end
    while true do
        local bAny = false
        for _, v in ipairs(tItem) do if v.canbuy then bAny = true end end
        if not bAny then
            PushColorMsg(m_script_name .. ":已无可购买物品")
            break
        end
        if GoToGuild() == false then break end
        if IsWindowVisible("T3DaibiShop") then
            for _, v in ipairs(tItem) do
                local nState = 0
                if v.canbuy then nState = ShopBuy("t3", v.name, 3) end
                if nState == 3 then
                    v.canbuy = false
                elseif nState == 5 then
                    PushColorMsg(m_script_name .. "：没有此物品")
                    v.canbuy = false
                end
                Sleep(200)
            end
        else
            MoveToNPC("李问禅", 106, 59, -1, nil, nil, MoveCallback_InMyGuild)
            QuestFrameOptionClicked_Item("#{SDYC_20220706_05}", 1, 700)
        end
        Sleep(400)
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 90000 then
            PushColorMsg(m_script_name .. "：执行超时")
            break
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name, false)
