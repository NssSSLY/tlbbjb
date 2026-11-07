-- 反编译自 dfz64.dll 内嵌字节码 002b0705（unluac 2025-12-23；仅供分析）
local m_script_name = "抢束河步青云"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  LoadScript("fn抢购")
  local param = {}
  param.itemName = HandleText_AddFuHao(ReadConfigText("ZH", "bjk63"), " ", true)
  param.sleep = ReadConfigInt("ZH", "bjk62")
  param.sell_out_stop = ReadConfigBool("ZH", "xzk28")
  param.use_record = false
  param.yinshen = true
  param.name = "步青云"
  param.sceneID = 260
  param.pos = {
    {x = 168, y = 188},
    {x = 177, y = 137},
    {x = 168, y = 83},
    {x = 135, y = 82},
    {x = 100, y = 85},
    {x = 116, y = 188}
  }
  param.refresh_time = 7200
  QQ_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false, false)
