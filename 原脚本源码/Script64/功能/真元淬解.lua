-- 反编译自 dfz64.dll 内嵌字节码 0034eded（unluac 2025-12-23；仅供分析）
local m_script_name = "真元淬解"
ScriptOnStart(m_script_name, false, false)
g_config.zycj = {}
g_config.zycj.baise = ReadConfigBool("ZH", "xzk112")
g_config.zycj.lvse = ReadConfigBool("ZH", "xzk113")
g_config.zycj.lanse = ReadConfigBool("ZH", "xzk116")
g_config.zycj.zise = ReadConfigBool("ZH", "xzk117")
g_config.zycj.allname = ReadConfigText("ZH", "bjk179")

function _SMain(...)
  ZYCJ_Action(36)
end

_SMain()
ScriptOnStop(m_script_name)
