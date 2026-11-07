-- 反编译自 dfz64.dll 内嵌字节码 00296c02（unluac 2025-12-23；仅供分析）
local m_script_name = "购买路书"
ScriptOnStart(m_script_name, false, false)
local npc = {
  x = 224,
  y = 226,
  sceneID = 1,
  name = "吴玠"
}
RecvState(1)

function _SMain()
  DeleteDebugMsg("#{CPBT_260115_13}")
  DeleteDebugMsg("#{CPBT_260115_14}")
  DeleteDebugMsg("#{CPBT_260115_15}")
  Bank_GetMoney(2000000)
  while true do
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{CPBT_260115_02}", 1, 600)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{CPBT_260115_06}", 1, 600)
    Sleep(500)
    GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
    if IsInDebugMsg("#{CPBT_260115_14}") or IsInDebugMsg("#{CPBT_260115_15}") or IsInDebugMsg("#{CPBT_260115_13}") then
      PushColorMsg("#{CPBT_260115_14}")
      break
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
