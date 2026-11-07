-- 反编译自 dfz64.dll 内嵌字节码 00338cee（unluac 2025-12-23；仅供分析）
local m_script_name = "合成宝石"
ScriptOnStart(m_script_name, false, false)
g_config.hcbs = {}
g_config.hcbs.hc_level = GetConfigCommbox("设置", "合成宝石等级")
g_config.hcbs.hc_mode = GetConfigCommbox("设置", "合成宝石模式")
g_config.hcbs.count = GetConfigCommbox("设置", "合成宝石数量")
g_config.hcbs.only_bag = GetConfigBool("设置", "合成宝石背包")
local m_param = {}
m_param.count = 5
if 2 == g_config.hcbs.count.sel then
  m_param.count = 3
elseif 1 == g_config.hcbs.count.sel then
  m_param.count = 4
end
m_param.hc_level = g_config.hcbs.hc_level.sel + 2
m_param.only_bag = g_config.hcbs.only_bag
m_param.hc_mode = g_config.hcbs.hc_mode.sel + 1
if m_param.hc_mode < 1 or m_param.hc_mode > 4 then
  m_param.hc_mode = 1
end

local function HCGem_IsHaveHCF(aGemName, aBind)
  if 2 == aBind then
    aBind = 0
  end
  local hcfName = "低级宝石合成符"
  if string.find(aGemName, "4级", nil, true) or string.find(aGemName, "5级", nil, true) or string.find(aGemName, "6级", nil, true) then
    hcfName = "高级宝石合成符"
  elseif string.find(aGemName, "7级", nil, true) or string.find(aGemName, "8级", nil, true) then
    hcfName = "超级宝石合成符"
  end
  local tHCF = Bag:FindItemInfo(hcfName, aBind, nil, Bag:EnumDaoJuItem())
  if #tHCF > 0 then
    return tHCF[1].index
  end
  TempBank2Bag(hcfName, aBind)
  Sleep(500)
  tHCF = Bag:FindItemInfo(hcfName, aBind, nil, Bag:EnumDaoJuItem())
  if #tHCF > 0 then
    return tHCF[1].index
  end
  PushDebugMessage(m_script_name .. ":仓库取出合成符")
  Bank_GetItem(hcfName, -1, aBind)
  tHCF = Bag:FindItemInfo(hcfName, aBind, nil, Bag:EnumDaoJuItem())
  if #tHCF > 0 then
    return tHCF[1].index
  end
  return -1
end

local function GetGemLevel(aGemName)
  for i = 1, 8 do
    local str = fmt("%s级", i)
    if string.find(aGemName, str, nil, true) then
      return i
    end
  end
  return -1
end

local function HCGem_Find(aItem)
  local tItem = aItem
  local tBS = ObjFilterByInt(tItem, 5, 0, "itemType")
  for i = 1, #tBS do
    tBS[i].bs_level = GetGemLevel(tBS[i].name)
  end
  tBS = ObjFilterByInt(tBS, 1, 3, "bs_level")
  tBS = ObjFilterByInt(tBS, m_param.hc_level, 4, "bs_level")
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

local function HCGem_GetName()
  local tBank = Bank_EnumItem()
  local tBag = Bag:EnumCailiaoItem()
  local tBagTemp = Bag:EnumTempBagItem()
  if m_param.only_bag then
    tBank = {}
    tBagTemp = {}
  end
  local tGem_bank, tBindGem_bank, tUnBindGem_bank = HCGem_Find(tBank)
  local tGem_bag, tBindGem_bag, tUnBindGem_bag = HCGem_Find(tBag)
  local tGem_bagT, tBindGem_bagT, tUnBindGem_bagT = HCGem_Find(tBagTemp)
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

local function HCGem_IsHaveMoney()
  local nNeed = 5000
  if nNeed > Player:GetMoney(1) + Player:GetMoney(2) then
    PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
    Bank_GetMoney(nNeed * 10)
    return false
  end
  return true
end

local function HCGem_IsVisible()
  local szTemp = [[
            setmetatable(_G, { __index = Gemcompose_Env});
            if this:IsVisible() then
                local szTitle = Gemcompose_DragTitle:GetText()
                return szTitle
            else
                return "nil"
            end
        ]]
  local szRet = GetLuaValue(szTemp, "s")
  if string.find(szRet, "宝石合成", nil, true) then
    return true
  end
  return false
end

local function HCGem_OnAction(aGemName, aBindState, aHCFIndex)
  if HCGem_IsVisible() then
    local tGem = Bag:FindItemInfo(aGemName, aBindState)
    if #tGem > 0 then
      local CurrentOdds = 100
      local nSel = 0
      if 4 == m_param.count then
        nSel = 1
        CurrentOdds = 75
      elseif 3 == m_param.count then
        nSel = 2
        CurrentOdds = 50
      end
      local szTemp = fmt("LifeAbility:Do_Combine(%d, %d, %d, %d)", tGem[1].itemIndex, aHCFIndex, nSel, CurrentOdds)
      GetLuaValue(szTemp)
      Sleep(100)
    end
  else
    CloseWindow("Gemcompose")
    GoToSceneNPC("彭怀玉", 282, 321, LUOYANG_ID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{BSLCYH_130529_133}", 1, 700)
  end
end

function _SMain(...)
  local tickOut = GetTickCount()
  while true do
    Bag:PackUp(-1)
    local gemName, bindState = HCGem_GetName()
    if "" ~= gemName then
      local nCount = Bag:GetItemCount(gemName, bindState)
      if nCount < m_param.count and not m_param.only_bag then
        TempBank2Bag(gemName, bindState)
        Sleep(300)
      end
      nCount = Bag:GetItemCount(gemName, bindState)
      if nCount < m_param.count and not m_param.only_bag then
        Bank_GetItem(gemName, -1, bindState)
        Sleep(300)
      end
      nCount = Bag:GetItemCount(gemName, bindState)
      if nCount >= m_param.count then
        if HCGem_IsHaveMoney() then
          local hcfIndex = HCGem_IsHaveHCF(gemName, bindState)
          if -1 ~= hcfIndex then
            HCGem_OnAction(gemName, bindState, hcfIndex)
          else
            PushColorMsg(m_script_name .. ":您没有合成符了")
            break
          end
        else
          DebugStr(m_script_name .. ":金币不足", 2)
        end
      else
        DebugStr(gemName .. ":取出失败", 2)
        ClearBag()
        MainBankSaveItem("低级宝石合成符")
      end
    else
      PushColorMsg(m_script_name .. ":您已没有需要合成的宝石")
      break
    end
    if GetTickCount() - tickOut > 900000 then
      PushColorMsg(m_script_name .. ":超时")
      break
    end
    Sleep(200)
    if IsWindowVisible("LoginSelectServerQuest", "SelectServerQuest_Bn1Click()") then
      Sleep(200)
    end
    DebugStr(m_script_name)
  end
  ClearBag()
  MainBankSaveItem()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
