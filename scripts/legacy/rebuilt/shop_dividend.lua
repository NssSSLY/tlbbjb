-- 购买半价红利商品：由 dfz64.dll 字节码模块 物品/购买半价红利商品.lua 静态还原
-- 模块 SHA256 c31d47393951e7f85ae9c59e136fcc84874970350257e1cc41b85d7461c2811d；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。原规则一次把整份清单交给游戏，这里逐个名字调用，价格档位判断不变。
local m_script_name = "购买红利半价商品"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    -- 原规则开头清理背包（ClearBag），不执行。
    DeleteDebugMsg("#{LJSD_180312_05}")
    DeleteDebugMsg("对不起，您的红利数量不足，完成每周的工资任务可以获得红利。")
    local tItem = ParseItemList((TaskConfig or {}).shop_items, 1)
    local nStart = GetTickCount()
    while true do
        for _, v in ipairs(tItem) do
            DebugStr("购买宝石：" .. v.name, 2)
            ShopBuy("dividend", v.name)
        end
        Sleep(800)
        if IsInDebugMsg("#{LJSD_180312_05}") or IsInDebugMsg("对不起，您的红利数量不足，完成每周的工资任务可以获得红利。") then break end
        if GetTickCount() - nStart > 65000 then
            PushColorMsg(m_script_name .. ":购买超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
