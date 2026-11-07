-- 反编译自 dfz64.dll 内嵌字节码 00334aad（unluac 2025-12-23；仅供分析）
local m_script_name = "兑换幻色勾天彩"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  local djCount = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumCailiaoItem())
  local jnCount = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumTempBagItem())
  if djCount + jnCount < 5 then
    Bank_GetItem(" 高级勾天彩 ", -1, nil, nil, true)
  end
  djCount = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumCailiaoItem())
  jnCount = Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumTempBagItem())
  local nTickOut = -1
  if djCount + jnCount >= 5 then
    ::lbl_50::
    if Bag:GetItemCount("高级勾天彩", nil, nil, Bag:EnumCailiaoItem()) < 5 then
      TempBank2Bag("高级勾天彩", 0)
    end
    GoToSceneNPC("焦鹰", 125, 201, 850)
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 120000 then
      PushColorMsg(m_script_name .. ":超时120秒！")
    else
      QuestFrameOptionClicked_Item("#{GTCHC_140213_01}", 1, 600)
      QuestFrameOptionClicked_Item("#{LW_KVK_130426_9}", 1, 600)
      do
        local strText = GetNPCEventList_Item(0)
        if "#{LW_KVK_130426_6}" == strText then
          PushColorMsg(m_script_name .. ":高级勾天彩不足")
          goto lbl_127
        else
        end
        if "#{LW_KVK_130426_5}" ~= strText then
          Sleep(100)
          DebugStr(m_script_name)
          goto lbl_50
        end
      end
    end
  else
    PushColorMsg(m_script_name .. ":您已没有足够的高级勾天彩")
  end
  ::lbl_127::
  Bag_Move2TempBank(" 高级勾天彩 幻色勾天彩 ")
end

_SMain()
ScriptOnStop(m_script_name)
