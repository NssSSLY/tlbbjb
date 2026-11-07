-- 反编译自 dfz64.dll 内嵌字节码 0044533c（unluac 2025-12-23；仅供分析）
local m_npc = {
  x = 139,
  y = 182,
  sceneID = LUOYANG_ID,
  name = "月老"
}

function _SMain(...)
  DeleteDebugMsg("#{JHJL_151222_05}")
  DeleteDebugMsg("#{JHJL_151222_04}")
  DeleteDebugMsg("#{JHJL_151222_13")
  GetLuaValue("setmetatable(_G, {__index = Valentine_Gift_Env});Valentine_Gift_GetClick();")
  Sleep(500)
  CloseAllWindow()
  local nTickOut = -1
  while true do
    local npc = m_npc
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    Sleep(500)
    QuestFrameOptionClicked_Item("#{JHJL_151222_01}", 1, 800)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{JHJL_151222_01}", 1, 800)
    if IsInDebugMsg("#{JHJL_151222_05}") or IsInDebugMsg("#{JHJL_151222_08}") or IsInDebugMsg("#{JHJL_151222_13") or IsInDebugMsg("#{JHJL_151222_04}") then
      break
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 60000 then
      PushDebugMessage("领取超时")
      break
    end
    Sleep(500)
    DebugStr("领取结婚纪念品")
  end
  Bag:UseItemByName_click("眷梦情思礼包", 1000)
  Bag:UseItemByName_click("彩蝶恩爱礼匣", 1000)
  Bag:UseItemByName_click("青鸟悦爱礼匣", 1000)
  Bag:UseItemByName_click("鸳鸯痴爱礼匣", 1000)
  Bag:UseItemByName_click("鸾凤唯爱礼匣", 1000)
  Bag:UseItemByName_click("鸾凤唯爱礼匣", 1000)
end

_SMain()
