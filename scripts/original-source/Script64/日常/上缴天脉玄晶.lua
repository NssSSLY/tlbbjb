-- 反编译自 dfz64.dll 内嵌字节码 00428eb3（unluac 2025-12-23；仅供分析）
local m_script_name = "上缴天脉玄晶"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  local oldCount = Bag:GetItemCount("天脉玄晶")
  while true do
    local strText = GetNPCEventListAllItem()
    if string.find(strText, "#{KVKZYZD_110705_36}", nil, true) then
      local nCount = Bag:GetItemCount("天脉玄晶")
      local needCount = 50 - (oldCount - nCount)
      if nCount < needCount then
        needCount = nCount
      end
      if needCount >= 40 then
        QuestFrameOptionClicked_Item("#{KVKZYZD_110705_38}", 1, 500)
      elseif needCount >= 10 then
        QuestFrameOptionClicked_Item("#{KVKZYZD_110705_37}", 1, 500)
      elseif needCount >= 1 then
        QuestFrameOptionClicked_Item("#{KVKZYZD_110705_36}", 1, 500)
      else
        break
      end
    else
      GoToSceneNPC("陈霄", 105, 200, 850)
    end
    local nowCount = Bag:GetItemCount("天脉玄晶")
    if oldCount - nowCount >= 50 then
      LogMsg("已经上缴超过50个天脉玄晶")
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
end

_SMain()
