-- 反编译自 dfz64.dll 内嵌字节码 00337dd8（unluac 2025-12-23；仅供分析）
local m_script_name = "合成子女套"
ScriptOnStart(m_script_name, false, false)
g_config.hcznt = {}
g_config.hcznt.hc_mode = {
  sel = ReadConfigInt("ZH", "zhk49"),
  text = "",
  data = 0
}
g_config.hcznt.max_level = {
  sel = ReadConfigInt("ZH", "zhk50"),
  text = "",
  data = 0
}
local m_param = {}
m_param.hc_mode = g_config.hcznt.hc_mode.sel + 1
if m_param.hc_mode < 1 or m_param.hc_mode > 4 then
  m_param.hc_mode = 1
end
m_param.max_level = g_config.hcznt.max_level.sel + 1
if m_param.max_level < 1 or m_param.max_level > 3 then
  m_param.max_level = 1
end

local function znt_hecheng(pos1, pos2)
  local strText = fmt([[
            Clear_XSCRIPT();
                Set_XSCRIPT_Function_Name("CompositeBooks");
                Set_XSCRIPT_ScriptID(890630);
                Set_XSCRIPT_Parameter(0, %d);
                Set_XSCRIPT_Parameter(1, %d);
                Set_XSCRIPT_ParamCount(2);
            Send_XSCRIPT();
        ]], pos1, pos2)
  GetLuaValue(strText)
end

local function znt_EnumItem()
  local tObj = {}
  local tBag = Bag:EnumDaoJuItem()
  for i = 1, #tBag do
    local tmp = tBag[i]
    if tmp.class == "子女装备" then
      local nLock = GetLuaValue("return PlayerPackage:IsLock(" .. tmp.index .. ");", "n")
      if 1 ~= nLock then
        local n = #tObj + 1
        tObj[n] = {
          level = tmp.level,
          index = tmp.index,
          bind = tmp.bind
        }
      else
        PushDebugMessage("合成子女套：位置" .. tmp.index .. "的加锁了")
      end
    end
  end
  local tLevel = {}
  for i = 1, #tObj do
    if tObj[i].level < m_param.max_level then
      local n = #tLevel + 1
      tLevel[n] = tObj[i]
    end
  end
  tObj = tLevel
  if 0 == #tObj then
    return false
  end
  local tFree, tBind = {}, {}
  for i = 1, #tObj do
    if 1 == m_param.hc_mode then
      if 1 == tObj[i].bind then
        local n = #tBind + 1
        tBind[n] = tObj[i]
      else
        local n = #tFree + 1
        tFree[n] = tObj[i]
      end
    elseif 2 == m_param.hc_mode then
      tFree = {}
      if 1 == tObj[i].bind then
        local n = #tBind + 1
        tBind[n] = tObj[i]
      end
    elseif 3 == m_param.hc_mode then
      tBind = {}
      if 1 ~= tObj[i].bind then
        local n = #tFree + 1
        tFree[n] = tObj[i]
      end
    elseif 4 == m_param.hc_mode then
      tBind = {}
      tFree = tObj
      break
    end
  end
  local n = #tBind
  for i = 1, n do
    if i < n then
      for j = i + 1, n do
        if tBind[i].level == tBind[j].level then
          znt_hecheng(tBind[i].index, tBind[j].index)
          return true
        end
      end
    end
  end
  n = #tFree
  for i = 1, n do
    if i < n then
      for j = i + 1, n do
        if tFree[i].level == tFree[j].level then
          znt_hecheng(tFree[i].index, tFree[j].index)
          return true
        end
      end
    end
  end
  return false
end

function _SMain(...)
  local nBind = 0
  if 2 == m_param.hc_mode then
    nBind = 2
  elseif 3 == m_param.hc_mode then
    nBind = 1
  end
  local tItem = Bag:SearchItemType("子女装备", Bag:EnumDaoJuItem())
  if 0 == #tItem then
    PushDebugMessage(m_script_name .. ":仓库取子女套.")
    MainBankSaveItem()
    Bank_GetItem(" 子女装备 ", -1, nBind)
  end
  local nTickOut = -1
  while true do
    GoToSceneNPC("子路先生", 151, 177, LUOYANG_ID)
    Sleep(600)
    QuestFrameOptionClicked_Item("#{KPWFS_131112_8}", 1, 700)
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if not znt_EnumItem() then
      local nSpace = Bag:GetSpaceNum(0)
      if 0 == nSpace then
        ClearBag()
        Sleep(500)
        nSpace = Bag:GetSpaceNum(0)
        if 0 == nSpace then
          Bag_SellItem()
          MainBankSaveItem()
        end
        Sleep(500)
        nSpace = Bag:GetSpaceNum(0)
        if 0 == nSpace then
          break
        end
      end
      TempBank2Bag("子女装备", nBind)
      Sleep(500)
      if not znt_EnumItem() then
        local nCnt = Bank_GetItem(" 子女装备 ", -1, nBind)
        if 0 == nCnt then
          break
        end
      end
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 120000 then
      PushColorMsg(m_script_name .. ":执行超时.")
      break
    end
    Sleep(1000)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
