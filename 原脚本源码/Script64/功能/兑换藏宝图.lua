-- 反编译自 dfz64.dll 内嵌字节码 0034fb9a（unluac 2025-12-23；仅供分析）
local m_script_name = "兑换藏宝图"
ScriptOnStart(m_script_name, false, false)
local npc = {
  x = 224,
  y = 226,
  sceneID = 1,
  name = "吴玠"
}
RecvState(1)

function _SMain()
  DeleteDebugMsg("#{BTSM_260114_08}")
  local money = Player:GetMoney()
  PushColorMsg(money / 10000)
  if money / 10000 < 10 then
    PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
    Bank_GetMoney(100000)
  end
  while true do
    local money = Player:GetMoney()
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BTSM_260114_02}", 1, 600)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BTSM_260114_04}", 1, 600)
    Sleep(500)
    Bag_Move2TempBank(" 藏宝图 ", 0)
    Sleep(500)
    if IsInDebugMsg("#{BTSM_260114_08}") then
      PushColorMsg("#{BTSM_260114_08}")
      break
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
