-- 反编译自 dfz64.dll 内嵌字节码 004627b4（unluac 2025-12-23；仅供分析）
local m_script_name = "商会取物"
ScriptOnStart(m_script_name, false, false)
GlobalParam_shgl()
g_config.shqw = {}
g_config.shqw.id_text = g_config.shgl.id_text
g_config.shqw.item_text = GetItemConfigText(g_self.name, "物品", "商会取")

function _SMain()
  ClearBag()
  LoadScript("shanghui")
  SHQW_OnStart(g_config.shqw.id_text, g_config.shqw.item_text)
end

_SMain()
ScriptOnStop(m_script_name)
