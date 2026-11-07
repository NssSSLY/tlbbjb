-- 反编译自 dfz64.dll 内嵌字节码 002b03dc（unluac 2025-12-23；仅供分析）
local m_script_name = "抢大理神秘商人"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  LoadScript("fn抢购")
  local param = {}
  param.itemName = HandleText_AddFuHao(ReadConfigText("ZH", "bjk63"), " ", true)
  param.sleep = ReadConfigInt("ZH", "bjk62")
  param.sell_out_stop = ReadConfigBool("ZH", "xzk28")
  param.use_record = false
  param.name = "神秘商人"
  param.sceneID = 2
  param.pos = {
    {x = 108, y = 64}
  }
  param.refresh_time = 0
  param.option = "#{SMYBSD_091102_04}"
  QQ_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false, false)
