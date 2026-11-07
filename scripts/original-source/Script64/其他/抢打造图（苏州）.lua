-- 反编译自 dfz64.dll 内嵌字节码 002b1147（unluac 2025-12-23；仅供分析）
local m_script_name = "抢苏州李乐施"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  LoadScript("fn抢购")
  local param = {}
  param.itemName = HandleText_AddFuHao(ReadConfigText("ZH", "bjk63"), " ", true)
  param.sleep = ReadConfigInt("ZH", "bjk62")
  param.sell_out_stop = ReadConfigBool("ZH", "xzk28")
  param.use_record = false
  param.name = "李乐施"
  param.sceneID = 1
  param.pos = {
    {x = 290, y = 187}
  }
  param.refresh_time = 3600
  param.option = "善恶值换打造图与鉴定符"
  QQ_Action(param)
end

_SMain()
ScriptOnStop(m_script_name, false, false)
