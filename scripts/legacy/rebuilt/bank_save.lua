-- [功能] 物品存仓：由 dfz64.dll 字节码模块 物品/[功能] 物品存仓.lua 静态还原
-- 模块 SHA256 1eb9adf627a4ae5d2dbb41ed82c8077e06e3cd8c809b2e83e2f8e336281cefca；名单分组、存放顺序、锦囊先取出、仓库满判断和存钱条件按反汇编保持（functions.lua MainBankSaveItem）；原程序设置页的存仓名单与存钱选项改为任务设置；原程序还能按物品类别存放，类别读不到，只按名字；锦囊取出不区分绑定；副本内只存一轮、密保未解锁的判断未接入。
local m_script_name = "物品存仓"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
function MainBankSaveItem()
    CloseAllWindow()
    local nKeep = -1
    if cfg.bank_save_money == true then
        nKeep = math.floor((tonumber(cfg.bank_keep_money) or 0) * 10000)
        if nKeep < 0 then nKeep = -1 end
        PushDebugMessage("执行：仓库存放物品")
    else
        PushColorMsg("执行仓库存物：您未勾选存钱")
    end
    local szAny, szUnBind, szBind = tostring(cfg.bank_save_any or ""), tostring(cfg.bank_save_unbind or ""), tostring(cfg.bank_save_bind or "")
    local bTemp = cfg.bank_save_temp == true
    for i = 1, 2 do
        if bTemp then
            TempBank2Bag(szAny)
            TempBank2Bag(szUnBind)
            TempBank2Bag(szBind)
        end
        Bank_SaveItem(szAny, nKeep, 0)
        Bank_SaveItem(szUnBind, nKeep, 1)
        Bank_SaveItem(szBind, nKeep, 2)
        if IsInDebugMsg("目标箱子已经满了") or not bTemp then break end
    end
    if nKeep >= 0 and Player:GetMoney() > nKeep then Bank_SaveMoney(nKeep) end
    PushDebugMessage("仓库存物:已完成")
    CloseAllWindow()
end
MainBankSaveItem()
ScriptOnStop(m_script_name)
