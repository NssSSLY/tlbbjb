-- 反编译自 dfz64.dll 内嵌字节码 003368ab（unluac 2025-12-23；仅供分析）
local m_script_name = "古兰玉兑换宝石"
ScriptOnStart(m_script_name, false, false)
local m_baoshi = ReadConfigText("ZH", "bjk97")

local function BS_format_name(tBS, aStrLevel)
  aStrLevel = aStrLevel or "(1级)"
  local baoshi = {
    "红宝石",
    "绿宝石",
    "紫玉",
    "祖母绿",
    "黄晶石",
    "蓝晶石",
    "红晶石",
    "绿晶石",
    "黄玉",
    "皓石",
    "月光石",
    "碧玺",
    "变石"
  }
  for i = 1, #tBS do
    local temp = tBS[i]
    for j = 1, #baoshi do
      if string.find(temp.name, baoshi[j], nil, true) then
        temp.name = baoshi[j] .. aStrLevel
        break
      end
    end
  end
  return tBS
end

local function GLY_init_data()
  local tText = Text2Table(m_baoshi, " ")
  local tBS = {}
  for i = 1, #tText do
    local tmp = Text2Table(tText[i], "|")
    if 2 == #tmp then
      local strName = tmp[1]
      local nCount = tonumber(tmp[2])
      if type(strName) == "string" and type(nCount) == "number" then
        if FindTableFieldValue(tBS, "name", strName) == false then
          table.insert(tBS, {name = strName, count = nCount})
        else
          for j = 1, #tBS do
            local temp = tBS[j]
            if tBS[j].name == strName then
              tBS[j].count = tBS[j].count + nCount
            end
          end
        end
      else
        PushDebugMessage("兑换宝石：设置有误" .. tText[i])
      end
    end
  end
  local strText = "共兑换" .. #tBS .. "种宝石。"
  for i = 1, #tBS do
    local temp = tBS[i]
    local strTemp = temp.name .. temp.count .. "个 "
    strText = strText .. strTemp
  end
  PushDebugMessage(m_script_name .. strText)
  return tBS
end

function _SMain(...)
  local tDH = GLY_init_data()
  if 0 == #tDH then
    PushDebugMessage(m_script_name .. "：未设置数量")
    return
  end
  tDH = BS_format_name(tDH)
  local tBag = Bag:EnumCailiaoItem()
  for i = 1, #tDH do
    local temp = tDH[i]
    temp.count_have = Bag:GetItemCount(temp.name, nil, nil, tBag)
  end
  local nTickOut = GetTickCount()
  local oldCount = Bag:GetItemCount("古兰玉") + Bag:GetItemCount("古兰玉", nil, nil, Bag:EnumTempBagItem())
  Bank_GetItem(" 古兰玉 ", -1)
  local getCount = Bag:GetItemCount("古兰玉") + Bag:GetItemCount("古兰玉", nil, nil, Bag:EnumTempBagItem())
  DeleteDebugMsg("累计兑换了10颗宝石")
  while true do
    if Bag:GetItemCount("古兰玉") < 30 then
      TempBank2Bag("古兰玉", 0)
      Sleep(300)
    end
    for i = 1, #tDH do
      local temp = tDH[i]
      local nCount = Bag:GetItemCount(temp.name)
      if nCount >= temp.count + temp.count_have then
        table.remove(tDH, i)
        break
      else
        DeleteDebugMsg("#{FZYH_170213_28")
        GoToSceneNPC("彭怀玉", 280, 320, LUOYANG_ID)
        QuestFrameOptionClicked_Item("#{FZYH_170213_7}", 1, 700)
        local strText = string.gsub(temp.name, "%(1级%)", "（1级）", nil, true)
        DialogOptionClicked(strText, 3, 700)
        if IsInDebugMsg("#{FZYH_170213_28") then
          table.remove(tDH, i)
        end
        break
      end
    end
    Bag:PackUp(-1)
    if IsInDebugMsg("累计兑换了10颗宝石") then
      break
    end
    if Bag:GetItemCount("古兰玉") < 3 then
      Bank_GetItem(" 古兰玉 ", -1)
      Sleep(500)
      if Bag:GetItemCount("古兰玉") < 3 then
        PushDebugMessage(m_script_name .. ":古兰玉不足")
        break
      end
    end
    if 0 == #tDH then
      PushDebugMessage(m_script_name .. ":兑换完成！")
      break
    end
    if GetTickCount() - nTickOut > 120000 then
      PushDebugMessage(m_script_name .. ":超时!")
      break
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  Bag:PackUp(-1)
  Bag_Move2TempBank()
  if getCount ~= oldCount then
    Bank_SaveItem("古兰玉")
  end
end

_SMain()
ScriptOnStop(m_script_name)
