-- 反编译自 dfz64.dll 内嵌字节码 002b146f（unluac 2025-12-23；仅供分析）
local m_script_name = "抢辽西刘季"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  LoadScript("fn抢购")
  local param = {}
  param.itemName = HandleText_AddFuHao(ReadConfigText("ZH", "bjk63"), " ", true)
  param.sleep = ReadConfigInt("ZH", "bjk62")
  param.sell_out_stop = ReadConfigBool("ZH", "xzk28")
  param.use_record = false
  param.yinshen = true
  param.name = "刘季"
  param.sceneID = 21
  param.pos = {
    {x = 278, y = 48}
  }
  param.refresh_time = 7200
  param.option = "看看你卖的东西"
  QQ_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false, false)
