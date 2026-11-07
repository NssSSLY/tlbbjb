-- 反编译自 dfz64.dll 内嵌字节码 002b0ac5（unluac 2025-12-23；仅供分析）
local m_script_name = "抢洛阳赛鲁班"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  LoadScript("fn抢购")
  local param = {}
  param.itemName = HandleText_AddFuHao(ReadConfigText("ZH", "bjk63"), " ", true)
  param.sleep = ReadConfigInt("ZH", "bjk62")
  param.sell_out_stop = ReadConfigBool("ZH", "xzk28")
  param.use_record = false
  param.name = "赛鲁班"
  param.sceneID = LUOYANG_ID
  param.pos = {
    {x = 169, y = 236},
    {x = 204, y = 289},
    {x = 333, y = 269}
  }
  param.refresh_time = 3600
  QQ_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false, false)
