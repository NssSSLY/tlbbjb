-- 反编译自 dfz64.dll 内嵌字节码 0033b7a9（unluac 2025-12-23；仅供分析）
local m_script_name = "合成棉布"
ScriptOnStart(m_script_name, false, false)
g_config.hcmb = {}
g_config.hcmb.hc_level = GetConfigCommbox("设置", "合成棉布等级")
g_config.hcmb.hc_mode = GetConfigCommbox("设置", "合成棉布模式")
local m_param = {}
m_param.hc_level = g_config.hcmb.hc_level.sel + 1
m_param.count = 5
m_param.hc_mode = g_config.hcmb.hc_mode.sel + 1
if m_param.hc_mode < 1 or m_param.hc_mode > 4 then
  m_param.hc_mode = 1
end

local function HC_Find(aItem)
  local arrName = {"棉布碎片"}
  if m_param.hc_level >= 2 then
    table.insert(arrName, "1级棉布")
  end
  if m_param.hc_level >= 3 then
    table.insert(arrName, "2级棉布")
  end
  if m_param.hc_level >= 4 then
    table.insert(arrName, "3级棉布")
  end
  local tBS = GetTableFieldValue(aItem, "name", arrName)
  local tBind = Bag:EunmBindItem(true, tBS)
  local tUnBind = Bag:EnumUnBindItem(true, tBS)
  
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
  local tBindGem = _get_tab(tBind)
  local tUnBindGem = _get_tab(tUnBind)
  return tGem, tBindGem, tUnBindGem
end

local function HC_GetName()
  local tBank = Bank_EnumItem()
  local tBag = Bag:EnumCailiaoItem()
  local tBagTemp = Bag:EnumTempBagItem()
  local tGem_bank, tBindGem_bank, tUnBindGem_bank = HC_Find(tBank)
  local tGem_bag, tBindGem_bag, tUnBindGem_bag = HC_Find(tBag)
  local tGem_bagT, tBindGem_bagT, tUnBindGem_bagT = HC_Find(tBagTemp)
  local tGem_all, tGemBind_all, tGemUnBind_all = {}, {}, {}
  
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
  tGemBind_all = _insert_check(tGemBind_all, tBindGem_bag)
  tGemBind_all = _insert_check(tGemBind_all, tBindGem_bagT)
  tGemBind_all = _insert_check(tGemBind_all, tBindGem_bank)
  tGemUnBind_all = _insert_check(tGemUnBind_all, tUnBindGem_bag)
  tGemUnBind_all = _insert_check(tGemUnBind_all, tUnBindGem_bagT)
  tGemUnBind_all = _insert_check(tGemUnBind_all, tUnBindGem_bank)
  if 1 == m_param.hc_mode then
    for i = 1, #tBindGem_bag do
      local tmp = tBindGem_bag[i]
      if tmp.num >= m_param.count then
        return tmp.name, 2
      end
    end
    for i = 1, #tUnBindGem_bag do
      local tmp = tUnBindGem_bag[i]
      if tmp.num >= m_param.count then
        return tmp.name, 1
      end
    end
    for i = 1, #tBindGem_bag do
      local tmp = tBindGem_bag[i]
      for j = 1, #tGemBind_all do
        if tGemBind_all[j].name == tmp.name and tGemBind_all[j].num >= m_param.count then
          return tmp.name, 2
        end
      end
    end
    for i = 1, #tUnBindGem_bag do
      local tmp = tUnBindGem_bag[i]
      for j = 1, #tGemUnBind_all do
        if tGemUnBind_all[j].name == tmp.name and tGemUnBind_all[j].num >= m_param.count then
          return tmp.name, 1
        end
      end
    end
    for i = 1, #tGemBind_all do
      local tmp = tGemBind_all[i]
      if tmp.num >= m_param.count then
        return tmp.name, 2
      end
    end
    for i = 1, #tGemUnBind_all do
      local tmp = tGemUnBind_all[i]
      if tmp.num >= m_param.count then
        return tmp.name, 1
      end
    end
  elseif 2 == m_param.hc_mode then
    for i = 1, #tBindGem_bag do
      local tmp = tBindGem_bag[i]
      if tmp.num >= m_param.count then
        return tmp.name, 2
      end
    end
    for i = 1, #tBindGem_bag do
      local tmp = tBindGem_bag[i]
      for j = 1, #tGemBind_all do
        if tGemBind_all[j].name == tmp.name and tGemBind_all[j].num >= m_param.count then
          return tmp.name, 2
        end
      end
    end
    for i = 1, #tGemBind_all do
      local tmp = tGemBind_all[i]
      if tmp.num >= m_param.count then
        return tmp.name, 2
      end
    end
  elseif 3 == m_param.hc_mode then
    for i = 1, #tUnBindGem_bag do
      local tmp = tUnBindGem_bag[i]
      if tmp.num >= m_param.count then
        return tmp.name, 1
      end
    end
    for i = 1, #tUnBindGem_bag do
      local tmp = tUnBindGem_bag[i]
      for j = 1, #tGemUnBind_all do
        if tGemUnBind_all[j].name == tmp.name and tGemUnBind_all[j].num >= m_param.count then
          return tmp.name, 1
        end
      end
    end
    for i = 1, #tGemUnBind_all do
      local tmp = tGemUnBind_all[i]
      if tmp.num >= m_param.count then
        return tmp.name, 1
      end
    end
  elseif 4 == m_param.hc_mode then
    for i = 1, #tGem_bag do
      local tmp = tGem_bag[i]
      if tmp.num >= m_param.count then
        return tmp.name, 0
      end
    end
    for i = 1, #tGem_bag do
      local tmp = tGem_bag[i]
      for j = 1, #tGem_all do
        if tGem_all[j].name == tmp.name and tGem_all[j].num >= m_param.count then
          return tmp.name, 0
        end
      end
    end
    for i = 1, #tGem_all do
      local tmp = tGem_all[i]
      if tmp.num >= m_param.count then
        return tmp.name, 0
      end
    end
  end
  return "", -1
end

local function HC_IsHaveMoney()
  local nNeed = 5000
  if nNeed > Player:GetMoney(1) + Player:GetMoney(2) then
    PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
    Bank_GetMoney(nNeed * 10)
    return false
  end
  return true
end

local function HC_IsVisible()
  return IsWindowVisible("CaiLiaoCompound")
end

local function HC_GetLevel(aGemName)
  if string.find(aGemName, "碎片", nil, true) then
    return 0
  elseif string.find(aGemName, "1级", nil, true) then
    return 1
  elseif string.find(aGemName, "2级", nil, true) then
    return 2
  elseif string.find(aGemName, "3级", nil, true) then
    return 3
  end
  return -1
end

local function HC_OnAction(aGemName, aBindState)
  local hcLevel = HC_GetLevel(aGemName)
  if HC_IsVisible() and -1 ~= hcLevel then
    GetLuaValue("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_List:SetItemSelectByItemID(10002)")
    Sleep(800)
    GetLuaValue(fmt("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_List:SetItemSelectByItemID(%d)", hcLevel))
    Sleep(800)
    GetLuaValue("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_OnMaxNum();")
    Sleep(500)
    GetLuaValue("setmetatable(_G, {__index = CaiLiaoCompound_Env});CaiLiaoCompound_OK_Click();")
    Sleep(800)
    MessageBox_Self2_OK_Clicked()
  else
    GoToSceneNPC("彭怀玉", 282, 321, LUOYANG_ID)
    Sleep(500)
    QuestFrameOptionClicked_Item("材料合成", 1, 700)
  end
end

function _SMain()
  local tickOut = GetTickCount()
  while true do
    Bag:PackUp(-1)
    local gemName, bindState = HC_GetName()
    if "" ~= gemName then
      local nCount = Bag:GetItemCount(gemName, bindState)
      if nCount < m_param.count then
        TempBank2Bag(gemName, bindState)
        Sleep(300)
      end
      nCount = Bag:GetItemCount(gemName, bindState)
      if nCount < m_param.count then
        Bank_GetItem(gemName, -1, bindState)
        Sleep(300)
      end
      nCount = Bag:GetItemCount(gemName, bindState)
      if nCount >= m_param.count then
        if HC_IsHaveMoney() then
          if 1 == bindState then
            Bag_Move2TempBank(gemName, 2)
          elseif 2 == bindState then
            Bag_Move2TempBank(gemName, 1)
          end
          HC_OnAction(gemName, bindState)
        else
          DebugStr(m_script_name .. ":金币不足", 2)
        end
      else
        DebugStr(gemName .. ":取出失败", 2)
        ClearBag()
        MainBankSaveItem()
      end
    else
      PushColorMsg(m_script_name .. ":您已没有需要合成的材料")
      break
    end
    if GetTickCount() - tickOut > 300000 then
      PushColorMsg(m_script_name .. ":超时")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  ClearBag()
  MainBankSaveItem()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
