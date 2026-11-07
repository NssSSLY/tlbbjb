-- 反编译自 dfz64.dll 内嵌字节码 00348a98（unluac 2025-12-23；仅供分析）
local m_script_name = "宝石兑换券"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  local gemName3 = GetConfigCommbox("设置", "宝石兑换券3级")
  local gemName4 = GetConfigCommbox("设置", "宝石兑换券4级")
  gemName3 = gemName3.text
  gemName4 = gemName4.text
  CloseWindow("Quest")
  local n3 = Bag:GetItemCount("3级宝石兑换券")
  local n4 = Bag:GetItemCount("4级宝石兑换券")
  local n3jn = Bag:GetItemCount("3级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
  local n4jn = Bag:GetItemCount("4级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
  if 0 == n3 and 0 == n4 and 0 == n3jn and 0 == n4jn then
    PushColorMsg(m_script_name .. ":您没有兑换券")
  else
    local tick_out = -1
    while true do
      local n3 = Bag:GetItemCount("3级宝石兑换券")
      local n4 = Bag:GetItemCount("4级宝石兑换券")
      local n3jn = Bag:GetItemCount("3级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
      local n4jn = Bag:GetItemCount("4级宝石兑换券", nil, nil, Bag:EnumTempBagItem())
      if IsDestination(68, 45, 224, 3) then
        local allItem = GetNPCEventListAllItem()
        if string.find(allItem, "#{Agreement_Info_OK}", nil, true) then
          QuestFrameOptionClicked_Item("#{Agreement_Info_OK}", 1, 700)
        elseif string.find(allItem, "猫眼石", nil, true) and string.find(allItem, "红宝石", nil, true) then
          if string.find(allItem, "(3级)", nil, true) then
            if n3 > 0 and "" ~= gemName3 then
              QuestFrameOptionClicked_Item(gemName3, 3, 700)
            else
              CloseWindow("Quest")
            end
          elseif string.find(allItem, "(4级)", nil, true) then
            if n4 > 0 and "" ~= gemName4 then
              QuestFrameOptionClicked_Item(gemName4, 3, 700)
            else
              CloseWindow("Quest")
            end
          end
        elseif string.find(allItem, "#{CZDH_XML_1}", nil, true) then
          if n3 > 0 then
            QuestFrameOptionClicked_Item("#{CZDH_XML_1}", 1, 700)
          elseif n4 > 0 then
            QuestFrameOptionClicked_Item("#{BSDHQ_140327_05}", 1, 700)
          end
        else
          GoToSceneNPC("钱夫人", 68, 45, 224)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{BSDHQ_140327_02}", 1, 700)
        end
      else
        GoToSceneNPC("钱夫人", 68, 45, 224)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BSDHQ_140327_02}", 1, 700)
      end
      if n3 > 0 then
      elseif n4 > 0 then
      elseif n3jn > 0 or n4jn > 0 then
        TempBank2Bag(" 3级宝石兑换券 4级宝石兑换券 ")
      else
        PushColorMsg(m_script_name .. "：您已经没有宝石兑换券")
        break
      end
      if -1 == tick_out then
        tick_out = GetTickCount()
      end
      if GetTickCount() - tick_out > 90000 then
        break
      end
      DebugStr(m_script_name)
    end
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
