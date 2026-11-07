-- 反编译自 dfz64.dll 内嵌字节码 002b2381（unluac 2025-12-23；仅供分析）
local m_script_name = "抢苏州朱超重"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  LoadScript("fn抢购")
  local param = {}
  param.itemName = HandleText_AddFuHao(ReadConfigText("ZH", "bjk63"), " ", true)
  param.sleep = ReadConfigInt("ZH", "bjk62")
  param.sell_out_stop = ReadConfigBool("ZH", "xzk28")
  param.use_record = false
  param.name = "朱超重"
  param.sceneID = 1
  param.pos = {
    {x = 275, y = 329},
    {x = 230, y = 324},
    {x = 228, y = 210},
    {x = 279, y = 210},
    {x = 279, y = 190},
    {x = 324, y = 193},
    {x = 329, y = 331}
  }
  param.refresh_time = 30000
  QQ_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false, false)
