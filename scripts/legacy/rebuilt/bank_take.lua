-- 仓库取出物品：由 dfz64.dll 字节码模块 物品/仓库取出物品.lua 静态还原
-- 模块 SHA256 5e48966d608bdcb0d4cae89350efbe4693f06310baeb128a2061ee2e14fa232b；先锦囊后仓库的顺序按反汇编保持（functions.lua MainBankTakeItem）；原程序设置页的取物名单改为任务设置；原程序按绑定状态分三份名单，仓库物品的绑定状态读不到，合为一份按名字取；按物品类别取未接入。
local m_script_name = "仓库取物"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
function MainBankTakeItem()
    PushDebugMessage("执行：仓库取出物品")
    local szName = tostring(cfg.bank_take or "")
    if cfg.bank_take_temp == true then TempBank2Bag(szName) end
    Bank_GetItem(szName, -1)
    PushDebugMessage("仓库取物：已完成！")
end
MainBankTakeItem()
ScriptOnStop(m_script_name)
