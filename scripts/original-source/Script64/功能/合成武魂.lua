-- 反编译自 dfz64.dll 内嵌字节码 0033d598（unluac 2025-12-23；仅供分析）
local m_script_name = "合成武魂"
ScriptOnStart(m_script_name, false, false)
g_config["合成武魂"] = {}
g_config["合成武魂"].hc_level = GetConfigInt("设置", "合成武魂等级")
g_config["合成武魂"].hc_mode = GetConfigCommbox("设置", "合成武魂模式")
local m_param = {}
m_param.hc_level = HandleTextToNumber(g_config["合成武魂"].hc_level, 2)
m_param.hc_mode = g_config["合成武魂"].hc_mode.sel + 1
if m_param.hc_mode < 1 or m_param.hc_mode > 4 then
  m_param.hc_mode = 1
end

local function HC_Find(aItem, aIsBag)
  local arrName = {"御瑶盘", "琉璃焰"}
  local tBS = GetTableFieldValue(aItem, "name", arrName)
  local tWuHun = {}
  for i = 1, #tBS do
    local tmp = tBS[i]
    local extLevel = 0
    if aIsBag then
      extLevel = GetLuaValue(fmt("local main_lv = PlayerPackage:GetBagKfsData(%d, \"EXTRALEVEL\") return main_lv", tmp.index), "n")
    end
    tBS[i].ext_level = extLevel
    if extLevel < m_param.hc_level then
      table.insert(tWuHun, tBS[i])
    end
  end
  local tBind = Bag:EunmBindItem(true, tWuHun)
  local tUnBind = Bag:EnumUnBindItem(true, tWuHun)
  local tGem = tWuHun
  local tBindGem = tBind
  local tUnBindGem = tUnBind
  return tGem, tBindGem, tUnBindGem
end

local function HC_GetName()
  local tBag = Bag:EnumDaoJuItem()
  local tGem_bag, tBindGem_bag, tUnBindGem_bag = HC_Find(tBag, true)
  local tGem_all, tGemBind_all, tGemUnBind_all = {}, {}, {}
  
  local function _insert_check(_Insert, _From)
    for i = 1, #_From do
      local tmp = _From[i]
      table.insert(_Insert, tmp)
    end
    return _Insert
  end
  
  tGem_all = _insert_check(tGem_all, tGem_bag)
  tGemBind_all = _insert_check(tGemBind_all, tBindGem_bag)
  tGemUnBind_all = _insert_check(tGemUnBind_all, tUnBindGem_bag)
  BubbleSort(tGem_bag, "ext_level", 1)
  BubbleSort(tBindGem_bag, "ext_level", 1)
  BubbleSort(tUnBindGem_bag, "ext_level", 1)
  BubbleSort(tGem_all, "ext_level", 1)
  BubbleSort(tGemBind_all, "ext_level", 1)
  BubbleSort(tGemUnBind_all, "ext_level", 1)
  if 1 == m_param.hc_mode then
    for i = 1, #tGemBind_all do
      if i < #tGemBind_all then
        local tmp = tGemBind_all[i]
        local tmp_next = tGemBind_all[i + 1]
        if tmp.ext_level == tmp_next.ext_level then
          return tmp.ext_level, 2
        end
      end
    end
    for i = 1, #tGemUnBind_all do
      if i < #tGemUnBind_all then
        local tmp = tGemUnBind_all[i]
        local tmp_next = tGemUnBind_all[i + 1]
        if tmp.ext_level == tmp_next.ext_level then
          return tmp.ext_level, 1
        end
      end
    end
  elseif 2 == m_param.hc_mode then
    for i = 1, #tGemBind_all do
      if i < #tGemBind_all then
        local tmp = tGemBind_all[i]
        local tmp_next = tGemBind_all[i + 1]
        if tmp.ext_level == tmp_next.ext_level then
          return tmp.ext_level, 2
        end
      end
    end
  elseif 3 == m_param.hc_mode then
    for i = 1, #tGemUnBind_all do
      if i < #tGemUnBind_all then
        local tmp = tGemUnBind_all[i]
        local tmp_next = tGemUnBind_all[i + 1]
        if tmp.ext_level == tmp_next.ext_level then
          return tmp.ext_level, 1
        end
      end
    end
  elseif 4 == m_param.hc_mode then
    for i = 1, #tGem_all do
      if i < #tGem_all then
        local tmp = tGem_all[i]
        local tmp_next = tGem_all[i + 1]
        if tmp.ext_level == tmp_next.ext_level then
          return tmp.ext_level, 0
        end
      end
    end
  end
  return -1, -1
end

local function HC_CheckBagItem(aLevel, aBindState)
  local tBag = Bag:EnumDaoJuItem()
  local tWH_bag, tBindWH_bag, tUnBindWH_bag = HC_Find(tBag, true)
  local tHC = tWH_bag
  if 1 == aBindState then
    tHC = tUnBindWH_bag
  elseif 2 == aBindState then
    tHC = tBindWH_bag
  end
  local tAction = GetTableFieldValue(tHC, "ext_level", {aLevel})
  if #tAction >= 2 then
    return tAction[1], tAction[2]
  else
    TempBank2Bag("御瑶盘 琉璃焰", 0)
    Sleep(600)
  end
  tBag = Bag:EnumDaoJuItem()
  tWH_bag, tBindWH_bag, tUnBindWH_bag = HC_Find(tBag, true)
  tHC = tWH_bag
  if 1 == aBindState then
    tHC = tUnBindWH_bag
  elseif 2 == aBindState then
    tHC = tBindWH_bag
  end
  tAction = GetTableFieldValue(tHC, "ext_level", {aLevel})
  if #tAction >= 2 then
    return tAction[1], tAction[2]
  else
    Bank_GetItem("御瑶盘 琉璃焰", -1, 0)
    Sleep(600)
  end
  return nil, nil
end

function _SMain()
  ClearBag()
  Bag:PackUp(-1)
  if m_param.hc_level < 2 then
    m_param.hc_level = 2
  elseif m_param.hc_level > 7 then
    m_param.hc_level = 7
  end
  local tickOut = GetTickCount()
  while true do
    local hcLevel, bindState = HC_GetName()
    if hcLevel > 0 then
      local tWH1, tWH2 = HC_CheckBagItem(hcLevel, bindState)
      if tWH1 and tWH2 then
        GetLuaValue(fmt([[
                            Clear_XSCRIPT()
                                Set_XSCRIPT_Function_Name( "OnWuHunCompoundNew" )
                                Set_XSCRIPT_ScriptID(790076)
                                Set_XSCRIPT_Parameter(0, %d)					
                                Set_XSCRIPT_Parameter(1, %d)					
                                Set_XSCRIPT_Parameter(2, 1)					
                                Set_XSCRIPT_ParamCount(3)
                            Send_XSCRIPT()
                        ]], tWH1.index, tWH2.index))
        Sleep(1000)
      end
    else
      PushColorMsg(m_script_name .. ":背包没有可合成的武魂")
      if TempBank2Bag("御瑶盘 琉璃焰", 0) == false then
        local tBank = Bank_EnumItem()
        local tGem_bank = HC_Find(tBank)
        if #tGem_bank > 0 then
          if 0 == Bank_GetItem("御瑶盘 琉璃焰", -1, 0) then
            PushColorMsg(m_script_name .. ":已没有需要合成的武魂")
            break
          end
        else
          PushColorMsg(m_script_name .. ":已没有需要合成的武魂!")
          break
        end
      end
      Sleep(2000)
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
