-- 鬼市千金阁买物：由 dfz64.dll 字节码模块 物品/鬼市千金阁买物.lua 静态还原
-- 模块 SHA256 8032bab2ab0bb439e231cb55c9668a4d35ff0d3a8f773590beb95ff3aa76c14c；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "鬼市千金阁买物"
ScriptOnStart(m_script_name, true, false)
local tNpc = {
    { name = "张世平", sceneID = 2, x = 68, y = 178 },
    { name = "柳金蟾", sceneID = 1, x = 222, y = 235 },
    { name = "赵钱孙", sceneID = LUOYANG_ID, x = 183, y = 232 },
}
function _SMain()
    local nStart = -1
    -- 原规则开头清理背包（ClearBag），不执行。
    CloseAllWindow()
    local tItem = ParseItemList((TaskConfig or {}).shop_items, 1)
    for _, v in ipairs(tItem) do v.canbuy = true end
    if #tItem == 0 then
        PushColorMsg(m_script_name .. ":没有正确的物品名称,多个物品空格分开")
        CloseAllWindow()
        return
    end
    local npc = tNpc[3]
    while true do
        local bAny = false
        for _, v in ipairs(tItem) do if v.canbuy then bAny = true end end
        if not bAny then
            PushColorMsg(m_script_name .. ":已无可购买物品")
            break
        end
        if IsWindowVisible("GuiShi_Shop") then
            for _, v in ipairs(tItem) do
                local nCount = 1
                if v.name == "金蚕丝" then nCount = 10 end
                local nState = ShopBuy("guishi", v.name, nCount)
                if nState == 3 or nState == 0 then v.canbuy = false end
                if nState == 4 and nCount > 1 then
                    nCount = 1
                    nState = ShopBuy("guishi", v.name, nCount)
                end
                if nState == 4 and nCount == 1 then v.canbuy = false end
                Sleep(200)
            end
        else
            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
            QuestFrameOptionClicked_Item("#{GSHB_190801_47}", 1, 700)
        end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 180000 then
            PushColorMsg(m_script_name .. "：执行超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name, false)
