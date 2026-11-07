-- 反编译自 dfz64.dll 内嵌字节码 0042a927（unluac 2025-12-23；仅供分析）
local m_script_name = "提交紫微灵草"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  local tick_out = -1
  DeleteDebugMsg("#{ZJSJ_220708_76}")
  TempBank2Bag("紫微凤尾枝 紫微银堇叶 紫微香兰蕊")
  CloseAllWindow()
  while true do
    local nCount1 = Bag:GetItemCount("紫微凤尾枝", nil, 1)
    local nCount2 = Bag:GetItemCount("紫微银堇叶", nil, 1)
    local nCount3 = Bag:GetItemCount("紫微香兰蕊", nil, 1)
    if 0 == nCount1 and 0 == nCount2 and 0 == nCount3 then
      Sleep(500)
      nCount1 = Bag:GetItemCount("紫微凤尾枝", nil, 1)
      nCount2 = Bag:GetItemCount("紫微银堇叶", nil, 1)
      nCount3 = Bag:GetItemCount("紫微香兰蕊", nil, 1)
    end
    if 0 == nCount1 and 0 == nCount2 and 0 == nCount3 then
      PushColorMsg(m_script_name .. ":您没有紫微灵草")
      break
    end
    local bOpenNpc = false
    if nCount1 > 0 then
      if QuestFrameOptionClicked_Item("#{ZJSJ_220708_14}", 1, 600) == false then
        bOpenNpc = true
      end
    elseif nCount2 > 0 then
      if false == QuestFrameOptionClicked_Item("#{ZJSJ_220708_15}", 1, 600) then
        bOpenNpc = true
      end
    elseif nCount3 > 0 and false == QuestFrameOptionClicked_Item("#{ZJSJ_220708_16}", 1, 600) then
      bOpenNpc = true
    end
    if bOpenNpc then
      GoToSceneNPC("姜星辰", 144, 200, 850)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{ZJSJ_220708_6}", 1, 600)
    else
      MessageBox_Self2_OK_Clicked(600)
      IsWindowVisible("ThreeCity_ZiWei_Change", "ThreeCity_ZiWei_Change_Confirm()")
    end
    if -1 == tick_out then
      tick_out = GetTickCount()
    end
    if IsInDebugMsg("#{ZJSJ_220708_76}") then
      break
    end
    if GetTickCount() - tick_out > 60000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
