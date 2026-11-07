-- 反编译自 dfz64.dll 内嵌字节码 00427f3f（unluac 2025-12-23；仅供分析）
local m_script_name = "一千零一个愿望"
ScriptOnStart(m_script_name)

local function XuYuan_CheckItem(aMissionName)
  local needCount = 5
  local nIndex, idMission, idScript = GetPlayerMission_Item(aMissionName)
  if -1 ~= nIndex then
    local nHave = GetMissionVariable(nIndex, 1)
    needCount = 5 - nHave
  end
  local itemCount = Bag:GetItemCount("愿灵泉", 0, 0, Bag:EnumDaoJuItem())
  if needCount > itemCount then
    if TempBank2Bag("愿灵泉", 0) == false then
      Bank_GetItem("愿灵泉", needCount, nil, nil, true)
    end
    Sleep(500)
    return false
  end
  return true
end

function _SMain(...)
  local m_npc = {
    {
      name = "梁道士",
      x = 282,
      y = 275,
      sceneID = 1
    },
    {
      name = "",
      x = 158,
      y = 188,
      sceneID = 4
    }
  }
  local tryCount = 0
  local tick_out = GetTickCount()
  local m_mission_name = "#{SQXY_09061_4}"
  while true do
    if XuYuan_CheckItem(m_mission_name) then
      local nIndex, idMission, idScript = GetPlayerMission_Item(m_mission_name)
      if -1 ~= nIndex then
        local nComplete = GetMissionComplete(nIndex)
        if 1 == nComplete then
          local npc = m_npc[1]
          GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
          Sleep(600)
          QuestFrameOptionClicked_Item(m_mission_name, 1, 600)
          QuestFrameNextClicked(600)
          QuestFrameMissionComplete(0, 600)
        else
          local npc = m_npc[2]
          GoToScene(npc.x, npc.y, npc.sceneID, 1, nil, nil)
          Sleep(500)
          Dismount()
          Bag:UseItemByName("愿灵泉")
          Sleep(300)
          PlayerStateTimeOut(5, 50)
        end
      else
        local npc = m_npc[1]
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        Sleep(600)
        QuestFrameOptionClicked_Item(m_mission_name, 1, 600)
        local strText = GetNPCEventList_Item(0)
        if "#{SQXY_09061_7}" == strText then
          PushDebugMessage("许愿：已完成")
          break
        end
        QuestFrameAcceptClicked(500)
      end
    else
      tryCount = tryCount + 1
      if tryCount > 3 then
        PushDebugMessage("许愿：愿灵泉数量不足!")
        break
      end
    end
    if GetTickCount() - tick_out > 600000 then
      PushColorMsg("许愿：10分钟超时!")
      break
    end
    DebugStr("许愿:执行中.")
    Sleep(100)
  end
  Bag_Move2TempBank(" 愿灵泉 ", 0)
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
