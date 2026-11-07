-- 反编译自 dfz64.dll 内嵌字节码 0034932d（unluac 2025-12-23；仅供分析）
local m_script_name = "宝石雕琢"
ScriptOnStart(m_script_name, false, false)
g_config.bsdz = {}
g_config.bsdz.baoshi = ReadConfigText("ZH", "bjk107")
g_config.bsdz.bind = ReadConfigBool("ZH", "xzk281")
g_config.bsdz.unbind = ReadConfigBool("ZH", "xzk282")
local m_param = {}
m_param.baoshi = HandleText(g_config.bsdz.baoshi)
m_param.baoshi = HandleText_AddFuHao(m_param.baoshi)
m_param.bind = g_config.bsdz.bind
m_param.unbind = g_config.bsdz.unbind
m_param.item = {}
local m_item = {
  {
    level = 1,
    slevel = "1级",
    name = "宝石雕琢符1级"
  },
  {
    level = 2,
    slevel = "2级",
    name = "宝石雕琢符2级"
  },
  {
    level = 3,
    slevel = "3级",
    name = "宝石雕琢符3级"
  },
  {
    level = 4,
    slevel = "4级",
    name = "宝石雕琢符4级"
  },
  {
    level = 5,
    slevel = "5级",
    name = "宝石雕琢符5级"
  },
  {
    level = 6,
    slevel = "6级",
    name = "宝石雕琢符6级"
  },
  {
    level = 7,
    slevel = "7级",
    name = "宝石雕琢符7级"
  },
  {
    level = 8,
    slevel = "8级",
    name = "宝石雕琢符8级"
  }
}

local function BSDZ_GetBSLevel(aItem)
  local tItem = {}
  for j = 1, #aItem do
    local tTar = aItem[j]
    for i = 1, #m_item do
      local tmp = m_item[i]
      if string.find(tTar.name, tmp.slevel, nil, true) then
        tTar.bs_level = tmp.level
        table.insert(tItem, tTar)
        break
      end
    end
  end
  return tItem
end

local function BSDZ_IsHaveDzf(aItem)
  local dzfName = fmt(" 宝石雕琢符%d级 ", aItem.bs_level)
  local tObj = Bag:EnumDaoJuItem()
  local tFind = Bag:FindItem_vague(dzfName, 3, tObj)
  return BSDZ_GetBSLevel(tFind)
end

local function BSDZ_GetDZInfo(aItem)
  BubbleSort(aItem, "bs_level", 2)
  for j = 1, #aItem do
    local tDZF = BSDZ_IsHaveDzf(aItem[j])
    if #tDZF > 0 then
      BubbleSort(tDZF, "bs_level", 1)
      if 0 == aItem[j].bind then
        for i = 1, #tDZF do
          if 0 == tDZF[i].bind then
            return aItem[j], tDZF[i]
          end
        end
      else
        for i = 1, #tDZF do
          if 1 == tDZF[i].bind then
            return aItem[j], tDZF[i]
          end
        end
        return aItem[j], tDZF[1]
      end
    end
  end
  return nil, nil
end

local function BSDZ_Action(GemItemPos, NeedItemPos)
  local strText = fmt([[
        local g_GemItemPos = %d
        local itemcount = PlayerPackage:GetBagItemNum(g_GemItemPos)
		Clear_XSCRIPT()
			Set_XSCRIPT_Function_Name("OnGemCarve")
			Set_XSCRIPT_ScriptID(800117)
			Set_XSCRIPT_Parameter(0, g_GemItemPos)
			Set_XSCRIPT_Parameter(1, %d)
			Set_XSCRIPT_Parameter(2, 135)
			Set_XSCRIPT_Parameter(3, 1) 
			Set_XSCRIPT_Parameter(4, itemcount) 
			Set_XSCRIPT_ParamCount(5)
		Send_XSCRIPT()
	]], GemItemPos, NeedItemPos)
  GetLuaValue(strText)
  Sleep(100)
end

local function BSDZ_OnAction()
  local bDoSomething = false
  for j = 1, BAG_CAILIAO_MIN do
    local tBag = Bag:EnumAllObj()
    local bAction = false
    for i = 1, #m_param.item do
      local tItem = Bag:FindItemInfo(m_param.item[i].name, nil, nil, tBag)
      tItem = BSDZ_GetBSLevel(tItem)
      local tBind = Bag:EunmBindItem(true, tItem)
      local tUnBind = Bag:EnumUnBindItem(true, tItem)
      local tBs, tDzf
      if #tBind > 0 and m_param.bind then
        tBs, tDzf = BSDZ_GetDZInfo(tBind)
      end
      if (nil == tBs or nil == tDzf) and #tUnBind > 0 and m_param.unbind then
        tBs, tDzf = BSDZ_GetDZInfo(tUnBind)
      end
      if tBs and tDzf then
        bAction = true
        bDoSomething = true
        BSDZ_Action(tBs.index, tDzf.index)
        break
      end
      if bDoSomething and 0 == Bag:GetSpaceNum(1) then
        PushColorMsg("材料包已满")
        break
      end
    end
    if 0 == Bag:GetSpaceNum(1) or false == bAction then
      break
    end
    Sleep(300)
  end
  return bDoSomething
end

function BSDZ_GetBagItem(aBindState)
  local tBag = Bag:SearchItemName(m_param.baoshi)
  if 1 == aBindState then
    tBag = GetTableFieldValue(tBag, "bind", {0})
  elseif 2 == aBindState then
    tBag = GetTableFieldValue(tBag, "bind", {1})
  end
  return tBag
end

function _SMain(...)
  local m_npc = {
    x = 281,
    y = 321,
    sceneID = LUOYANG_ID,
    name = "彭怀玉"
  }
  if not m_param.bind and not m_param.unbind then
    PushDebugMessage(m_script_name .. ":您还为设置雕琢宝石的绑定类型")
    return
  end
  m_param.baoshi = string.gsub(m_param.baoshi, "（", "(")
  m_param.baoshi = string.gsub(m_param.baoshi, "）", ")")
  m_param.item = Text2Table(m_param.baoshi, " ", "name")
  local takeDzfName = " "
  if string.find(m_param.baoshi, "1级", nil, true) then
    takeDzfName = takeDzfName .. "宝石雕琢符1级 "
  end
  if string.find(m_param.baoshi, "2级", nil, true) then
    takeDzfName = takeDzfName .. "宝石雕琢符2级 "
  end
  if string.find(m_param.baoshi, "3级", nil, true) then
    takeDzfName = takeDzfName .. "宝石雕琢符3级 "
  end
  ClearBag()
  Bag:PackUp(-1)
  local bindState = 0
  if m_param.bind and m_param.unbind then
    bindState = 0
  elseif m_param.bind then
    bindState = 2
  elseif m_param.unbind then
    bindState = 1
  end
  TempBank2Bag(takeDzfName, 0)
  local nTickOut = GetTickCount()
  while true do
    local tBag = BSDZ_GetBagItem(bindState)
    if 0 == #tBag then
      TempBank2Bag(m_param.baoshi, bindState)
    end
    tBag = BSDZ_GetBagItem(bindState)
    if 0 == #tBag then
      Bank_GetItem(m_param.baoshi, nil, bindState)
      Bank_GetItem(takeDzfName, -1)
    end
    GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
    Sleep(500)
    local bDo = BSDZ_OnAction()
    if false == bDo then
      TempBank2Bag(m_param.baoshi, bindState)
      TempBank2Bag(takeDzfName, 0)
      Sleep(500)
      if false == BSDZ_OnAction() then
        Bank_GetItem(m_param.baoshi, nil, bindState)
        Bank_GetItem(takeDzfName, -1)
        GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
        if false == BSDZ_OnAction() then
          PushDebugMessage(m_script_name .. ":已经没有可以雕琢的宝石或雕琢符")
          break
        end
      end
    end
    if GetTickCount() - nTickOut > 300000 then
      PushDebugMessage(m_script_name .. ":超时!")
      break
    end
    Sleep(500)
    Bag:PackUp(-1)
    DebugStr(m_script_name)
  end
  MainBankSaveItem()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
