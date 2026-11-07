-- 购买寒纹玉物品：由 dfz64.dll 字节码模块 物品/购买寒纹玉物品.lua 静态还原
-- 模块 SHA256 97d524d639ceef3a822e9db5c5934b0e08743e191cfdf8c8557e2f35ea5e30c4；购买流程、判断与超时按反汇编保持；购买动作改为本程序固定的游戏内购买过程（只按设置里的物品名逐个购买）；原程序设置页的物品清单改为任务设置。
local m_script_name = "购买寒纹玉物品"
ScriptOnStart(m_script_name)
function _SMain()
    CloseAllWindow()
    local tItem = ParseItemList((TaskConfig or {}).shop_items, -1)
    local nStart = GetTickCount()
    while true do
        if not IsWindowVisible("ActivitySchedule_Shop") then
            if not IsWindowVisible("TodayCampaignListNew") then
                GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env}); PlayerQuicklyEnter_ActivityShedule()")
                Sleep(300)
            end
            if not IsWindowVisible("ActivitySchedule_Shop") then
                GetLuaValue("setmetatable(_G, {__index = TodayCampaignListNew_Env}); TodayCampaignListNew_WeeklyShop_Clicked()")
                Sleep(800)
            end
        end
        if IsWindowVisible("ActivitySchedule_Shop") then
            local bBuy = false
            for _, v in ipairs(tItem) do
                if HuoYueShopBuy(1, v.name, -1) == 1 then bBuy = true; break end
            end
            if not bBuy then
                PushColorMsg("华玉集：没有可购买的物品")
                break
            end
            CloseAllWindow()
        end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg("华玉集：购买超时")
            break
        end
        Sleep(500)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
