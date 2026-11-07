-- 反编译自 dfz64.dll 内嵌字节码 00395187（unluac 2025-12-23；仅供分析）
local m_script_name = "自动开启箱子奖励"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  while Bag:GetItemCount("1级宝石礼盒") > 0 do
    Bag:UseItemByName_click("1级宝石礼盒", 600)
  end
  while Bag:GetItemCount("义行令礼盒") > 0 do
    Bag:UseItemByName_click("义行令礼盒", 600)
  end
end

_SMain()
ScriptOnStop(m_script_name)
