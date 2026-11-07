-- 自动开启箱子奖励：由 dfz64.dll 字节码模块 常用/自动开启箱子奖励.lua 静态还原
-- 模块 SHA256 10f92987021844651cdbbaa887c63c5d6188acdb19641291f34394c50285caa9；调用、参数、等待和循环按反汇编逐条保持。打开失败时停止，避免原规则在打不开时无限重试。
local m_script_name = "自动开启箱子奖励"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    while Bag:GetItemCount("1级宝石礼盒") > 0 do
        if not Bag:UseItemByName_click("1级宝石礼盒", 600) then break end
    end
    while Bag:GetItemCount("义行令礼盒") > 0 do
        if not Bag:UseItemByName_click("义行令礼盒", 600) then break end
    end
end
_SMain()
ScriptOnStop(m_script_name)
