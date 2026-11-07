-- 反编译自 dfz64.dll 内嵌字节码 0035e8d2（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local nTickOut = GetTickCount()
  
  local m_npc = {
    [0] = {
      name = "戴三金",
      x = 66,
      y = 135
    }
  }
  DeleteDebugMsg("#{BHSL_210715_15}")
  while true do
    local debugnote = ""
    if IsMyGuildCity() then
      MoveToNPC(m_npc[0].name, m_npc[0].x, m_npc[0].y, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{BHSL_210715_03}", 1, 1000)
      QuestFrameOptionClicked_Item("#{BHSL_210715_74}", 1, 1000)
    else
    end
    if GoToGuild() == false or IsInDebugMsg("#{BHSL_210715_15}") then
      break
    end
    Sleep(500)
    DebugStr("领取福源礼盒")
    if GetTickCount() - nTickOut > 120000 then
      break
    end
  end
end

_SMain()
