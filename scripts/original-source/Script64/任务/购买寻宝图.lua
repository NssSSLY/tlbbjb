-- 反编译自 dfz64.dll 内嵌字节码 00297d2c（unluac 2025-12-23；仅供分析）
local m_script_name = "购买寻宝图"
ScriptOnStart(m_script_name, false, false)
local npc = {
  x = 224,
  y = 226,
  sceneID = 1,
  name = "吴玠"
}
RecvState(1)

function _SMain()
  DeleteDebugMsg("#{XCBT_260506_11}")
  DeleteDebugMsg("#{XCBT_260506_15}")
  DeleteDebugMsg("#{XCBT_260506_24}")
  DeleteDebugMsg("#{XCBT_260506_10}")
  Bank_GetMoney(1500000)
  while true do
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{XCBT_260506_01}", 1, 600)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{XCBT_260506_05}", 1, 600)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{XCBT_260506_05}", 1, 600)
    Sleep(500)
    GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
    if IsInDebugMsg("#{XCBT_260506_11}") or IsInDebugMsg("#{XCBT_260506_15}") or IsInDebugMsg("#{XCBT_260506_24") or IsInDebugMsg("#{XCBT_260506_10}") then
      PushColorMsg("#{XCBT_260506_11}")
      break
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
