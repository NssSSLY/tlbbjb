-- 反编译自 dfz64.dll 内嵌字节码 0033470e（unluac 2025-12-23；仅供分析）
local m_script_name = "修理装备"
ScriptOnStart(m_script_name, false, false)
PushColorMsg("修理装备：[功能2]页面可设置修理参数")
g_config["修理装备"] = {}
g_config["修理装备"]["装备阈值"] = ReadConfigInt("ZH", "bjk52")
g_config["修理装备"]["神器阈值"] = ReadConfigInt("ZH", "bjk53")
g_config["修理装备"]["武魂阈值"] = ReadConfigInt("ZH", "bjk77")

function _SMain(...)
  LoadScript("fn修理装备")
  local param = {}
  param.shenqi = 10
  param.zhuangbei = 10
  param.wuhun = 16
  param.unsave_wuzi = false
  if g_config["修理装备"] then
    param.zhuangbei = HandleTextToNumber(g_config["修理装备"]["装备阈值"], 10)
    param.shenqi = HandleTextToNumber(g_config["修理装备"]["神器阈值"], 10)
    param.wuhun = HandleTextToNumber(g_config["修理装备"]["武魂阈值"], 16)
  end
  XLZB_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false)
