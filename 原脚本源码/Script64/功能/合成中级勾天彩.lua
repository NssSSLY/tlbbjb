-- 反编译自 dfz64.dll 内嵌字节码 003376c9（unluac 2025-12-23；仅供分析）
local m_script_name = "合成中级勾天彩"
ScriptOnStart(m_script_name, false, false)

function _SMain()
  DeleteDebugMsg("#{GTCHC_140213_19}")
  DeleteDebugMsg("#{GTCHC_140213_20}")
  
  local function _GetCount()
    local djCount = Bag:GetItemCount("初级勾天彩", nil, nil, Bag:EnumCailiaoItem())
    local jnCount = Bag:GetItemCount("初级勾天彩", nil, nil, Bag:EnumTempBagItem())
    local hcCount = Bag:GetItemCount("初级勾天彩合成符")
    local jnhcCount = Bag:GetItemCount("初级勾天彩合成符", nil, nil, Bag:EnumTempBagItem())
    return djCount + jnCount, hcCount + jnhcCount
  end
  
  local gtcNum, hcNum = _GetCount()
  local getItem = ""
  if gtcNum < 5 then
    getItem = getItem .. " 初级勾天彩 "
  end
  if hcNum < 1 then
    getItem = getItem .. " 初级勾天彩合成符 "
  end
  if "" ~= getItem then
    Bank_GetItem(getItem, -1, nil, nil, true)
    Sleep(500)
  end
  gtcNum, hcNum = _GetCount()
  if gtcNum >= 5 and hcNum >= 1 then
    local nTickOut = -1
    TempBank2Bag("初级勾天彩 初级勾天彩合成符", 0)
    ::lbl_47::
    GoToSceneNPC("焦鹰", 125, 201, 850)
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 120000 then
      PushColorMsg(m_script_name .. ":超时120秒！")
    else
      QuestFrameOptionClicked_Item("#{GTCHC_140213_01}", 1, 600)
      QuestFrameOptionClicked_Item("#{GTCHC_140213_04}", 1, 600)
      IsWindowVisible("GouTianCai_HC", "GouTianCai_HC_OnOK()")
      if IsInDebugMsg("#{GTCHC_140213_19}") or IsInDebugMsg("#{GTCHC_140213_20}") then
        TempBank2Bag("初级勾天彩 初级勾天彩合成符", 0)
        gtcNum, hcNum = _GetCount()
        if gtcNum < 5 or hcNum < 1 then
          PushColorMsg(m_script_name .. ":材料不足")
      end
      else
        Sleep(100)
        DebugStr(m_script_name)
        goto lbl_47
      end
    end
  else
    PushColorMsg(m_script_name .. ":您已没有足够的材料")
  end
  Bag_Move2TempBank(" 初级勾天彩 中级勾天彩 初级勾天彩合成符 ")
end

_SMain()
ScriptOnStop(m_script_name)
