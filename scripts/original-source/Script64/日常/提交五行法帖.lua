-- 反编译自 dfz64.dll 内嵌字节码 0042a183（unluac 2025-12-23；仅供分析）
local m_script_name = "提交五行法帖"
ScriptOnStart(m_script_name)

function _SMain(...)
  DeleteDebugMsg("#{XKSC_200325_12}")
  DeleteDebugMsg("#{XKSC_200325_13}")
  DeleteDebugMsg("#{XKSC_200325_16}")
  local bCun = false
  local itemCount = Bag:GetItemCount("五行法帖", 0, 0, Bag:EnumDaoJuItem())
  if 0 == itemCount then
    bCun = true
    PushDebugMessage("五行法帖：先尝试锦囊取出")
    if TempBank2Bag("五行法帖", 0) == false then
      PushDebugMessage("锦囊也没有五行法帖,前往仓库取出")
      Bank_GetItem("五行法帖", -1, nil, nil, true)
    end
  end
  GoToSceneNPC("独孤悔", 200, 334, 1)
  local tick_out = GetTickCount()
  local b250, b100, b50, b20, b10 = true, true, true, true, true
  while true do
    GoToSceneNPC("独孤悔", 200, 334, 1)
    QuestFrameOptionClicked_Item("#{XKSC_200325_01}", 1, 800)
    local spaceNum = Bag:GetItemCount("五行法帖", nil, 1)
    if spaceNum >= 250 and b250 then
      QuestFrameOptionClicked_Item("#{XKSC_200325_07}", 1, 800)
      if IsInDebugMsg("#{XKSC_200325_13}") then
        DeleteDebugMsg("#{XKSC_200325_13}")
        b250 = false
      end
    elseif spaceNum >= 100 and b100 then
      QuestFrameOptionClicked_Item("#{XKSC_200325_06}", 1, 800)
      if IsInDebugMsg("#{XKSC_200325_13}") then
        DeleteDebugMsg("#{XKSC_200325_13}")
        b100 = false
      end
    elseif spaceNum >= 50 and b50 then
      QuestFrameOptionClicked_Item("#{XKSC_200325_05}", 1, 800)
      if IsInDebugMsg("#{XKSC_200325_13}") then
        DeleteDebugMsg("#{XKSC_200325_13}")
        b50 = false
      end
    elseif spaceNum >= 20 and b20 then
      QuestFrameOptionClicked_Item("#{XKSC_200325_04}", 1, 800)
      if IsInDebugMsg("#{XKSC_200325_13}") then
        DeleteDebugMsg("#{XKSC_200325_13}")
        b20 = false
      end
    elseif spaceNum >= 10 and b10 then
      QuestFrameOptionClicked_Item("#{XKSC_200325_03}", 1, 800)
      if IsInDebugMsg("#{XKSC_200325_13}") then
        DeleteDebugMsg("#{XKSC_200325_13}")
        b10 = false
      end
    else
      break
    end
    if IsInDebugMsg("#{XKSC_200325_12}") then
      break
    end
    if IsInDebugMsg("#{XKSC_200325_16}") then
      PushDebugMessage(m_script_name .. "：背包需要清理!")
      Bag_DeleteItem()
    end
    if GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr(m_script_name)
    Sleep(600)
  end
  Bag_Move2TempBank(" 五行法帖 ", 0)
end

_SMain()
ScriptOnStop(m_script_name)
