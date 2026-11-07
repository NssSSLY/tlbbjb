-- 反编译自 dfz64.dll 内嵌字节码 00342c4a（unluac 2025-12-23；仅供分析）
local m_script_name = "合成魂冰珠"
ScriptOnStart(m_script_name, false, false)
g_config["合成魂冰珠"] = {}
g_config["合成魂冰珠"].hc_level = GetConfigCommbox("设置", "合成魂冰珠等级")
local m_param = {}
m_param.count = 5
m_param.hc_level = g_config["合成魂冰珠"].hc_level.sel + 2

local function HC_Find(aItem)
  local arrName = {
    "魂冰珠（1级）"
  }
  if m_param.hc_level >= 3 then
    table.insert(arrName, "魂冰珠（2级）")
  end
  if m_param.hc_level >= 4 then
    table.insert(arrName, "魂冰珠（3级）")
  end
  if m_param.hc_level >= 5 then
    table.insert(arrName, "魂冰珠（4级）")
  end
  local tBS = GetTableFieldValue(aItem, "name", arrName)
  
  local function _get_tab(_Item)
    local tab = {}
    for i = 1, #_Item do
      local tmp = _Item[i]
      local tFind = GetTableFieldValue(tab, "name", {
        tmp.name
      })
      if 0 == #tFind then
        table.insert(tab, {
          name = tmp.name,
          num = TableNameFieldCount(_Item, tmp.name, "count")
        })
      end
    end
    return tab
  end
  
  local tGem = _get_tab(tBS)
  return tGem
end

local function HC_GetName()
  local tBag = Bag:EnumCailiaoItem()
  local tBank = Bank_EnumItem()
  local tBagTemp = Bag:EnumTempBagItem()
  local tGem_bag = HC_Find(tBag)
  local tGem_bank = HC_Find(tBank)
  local tGem_bagT = HC_Find(tBagTemp)
  local tGem_all = {}
  
  local function _insert_check(_Insert, _From)
    for i = 1, #_From do
      local tmp = _From[i]
      local bFind = false
      for j = 1, #_Insert do
        if _Insert[j].name == tmp.name then
          bFind = true
          _Insert[j].num = _Insert[j].num + tmp.num
          break
        end
      end
      if false == bFind then
        table.insert(_Insert, {
          name = tmp.name,
          num = tmp.num
        })
      end
    end
    return _Insert
  end
  
  tGem_all = _insert_check(tGem_all, tGem_bag)
  tGem_all = _insert_check(tGem_all, tGem_bagT)
  tGem_all = _insert_check(tGem_all, tGem_bank)
  for i = 1, #tGem_bag do
    local tmp = tGem_bag[i]
    if tmp.num >= m_param.count then
      return tmp.name
    end
  end
  for i = 1, #tGem_all do
    local tmp = tGem_all[i]
    if tmp.num >= m_param.count then
      return tmp.name
    end
  end
  return ""
end

local function HC_IsHaveMoney()
  local nNeed = 10000
  if nNeed > Player:GetMoney(1) + Player:GetMoney(2) then
    PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
    Bank_GetMoney(nNeed * 10)
    return false
  end
  return true
end

local function HC_OnAction(aItemName)
  local tab = {}
  tab["魂冰珠（1级）"] = "合成魂冰珠（2级）"
  tab["魂冰珠（2级）"] = "合成魂冰珠（3级）"
  tab["魂冰珠（3级）"] = "合成魂冰珠（4级）"
  tab["魂冰珠（4级）"] = "合成魂冰珠（5级）"
  local option = tab[aItemName]
  if option then
    local allItem = GetNPCEventListAllItem()
    if string.find(allItem, "#{WH_xml_XX(112)}", nil, true) then
      if IsInDebugMsg("#{WU_090908_09}") or IsInDebugMsg("#{WU_090908_10}") or IsInDebugMsg("#{WU_090908_11}") or IsInDebugMsg("#{WU_090908_12}") then
        DeleteDebugMsg("#{WU_090908_09}")
        DeleteDebugMsg("#{WU_090908_10}")
        DeleteDebugMsg("#{WU_090908_11}")
        DeleteDebugMsg("#{WU_090908_12}")
        CloseWindow("Quest")
      end
    else
      GoToSceneNPC("武桐", 139, 197, 2)
      Sleep(500)
      DialogOptionClicked("魂冰珠合成", 1, 700)
      DialogOptionClicked(option, 1, 700)
    end
    QuestFrameOptionClicked_Item("#{WH_xml_XX(112)}", 1, 700)
  else
    PushColorMsg(m_script_name .. ":名称不正确" .. aItemName)
  end
end

function _SMain(...)
  ClearBag()
  Bag:PackUp(-1)
  DeleteDebugMsg("#{WU_090908_09}")
  DeleteDebugMsg("#{WU_090908_10}")
  DeleteDebugMsg("#{WU_090908_11}")
  DeleteDebugMsg("#{WU_090908_12}")
  local tickOut = GetTickCount()
  while true do
    local gemName = HC_GetName()
    if "" ~= gemName then
      local nCount = Bag:GetItemCount(gemName)
      if nCount < m_param.count then
        TempBank2Bag(gemName)
        Sleep(800)
      end
      nCount = Bag:GetItemCount(gemName)
      if nCount < m_param.count then
        Bank_GetItem(gemName, -1)
        Sleep(800)
      end
      nCount = Bag:GetItemCount(gemName)
      if nCount >= m_param.count then
        if HC_IsHaveMoney() then
          HC_OnAction(gemName)
        else
          DebugStr(m_script_name .. ":金币不足", 2)
        end
      else
        DebugColorMsg(gemName .. ":取出失败", 2)
        ClearBag()
        MainBankSaveItem()
        Bag:PackUp(-1)
      end
    else
      PushColorMsg(m_script_name .. ":您已没有需要合成的材料")
      break
    end
    if GetTickCount() - tickOut > 600000 then
      PushColorMsg(m_script_name .. ":超时")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
