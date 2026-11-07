-- 反编译自 dfz64.dll 内嵌字节码 0046388b（unluac 2025-12-23；仅供分析）
local m_script_name = "商会比价"
ScriptOnStart(m_script_name, false, false)
PushDebugMessage("对定价方式或通用定价为[市场底价]的物品进行比价")
GlobalParam_shgl()
g_config.shbj = {}
g_config.shbj.id_text = g_config.shgl.id_text
g_config.shbj.time_over = ReadConfigBool("ZH", "xzk151")
g_config.shbj.over_min = ReadConfigInt("ZH", "bjk123")
g_config.shbj.run_diff = ReadConfigInt("ZH", "bjk122")
local m_param = {}
m_param.sh_ID_text = g_config.shbj.id_text
m_param.sh_ID = {}
m_param.run_diff = HandleTextToNumber(g_config.shbj.run_diff)
m_param.time_over = g_config.shbj.time_over
m_param.over_min = HandleTextToNumber(g_config.shbj.over_min)
m_param.list_item = {}
m_param.bj_item = {}
m_param.max_price_diff = HandleTextToNumber(g_config.shgl.max_price_diff, 0)

local function SHGL_ItemUpStall(szItemName, nItemNum, tQuery)
  local bIsUpStall = false
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name == szItemName then
      local nPrice = math.floor(tmp.price_query_single * nItemNum)
      local nPrice_min = math.floor(tmp.price_min_single * nItemNum)
      if nPrice > nPrice_min then
        nPrice = nPrice - 1
      end
      if nPrice > 0 then
        bIsUpStall = true
        PushDebugMessage("商会比价：#cff66cc" .. tmp.name .. " #c00FFFF#e010101上架价格#cff66cc" .. nPrice .. "#c00FFFF#e010101铜")
        PlayerShop_UpStall(nPrice)
        break
      end
    end
  end
  return bIsUpStall
end

local function SHGL_ItemUpdateDownStall(szItemName, nItemNum, nMoney, tQuery)
  local bIsUpdate = false
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name == szItemName then
      local nPrice = math.floor(tmp.price_query_single * nItemNum)
      local nPrice_min = math.floor(tmp.price_min_single * nItemNum)
      if nPrice > nPrice_min then
        nPrice = nPrice - 1
      end
      if nPrice > 0 and nPrice ~= nMoney then
        bIsUpdate = true
        PushDebugMessage("商会比价：" .. tmp.name .. " 需要更新价格！")
        PlayerShop_DownSale()
        break
      end
    end
  end
  return bIsUpdate
end

function SHGL_Up_Down(tQuery_Item)
  local bIsUpStall = false
  local bIsUpdate = false
  local nStallNum = PlayerShop_GetStallNum()
  for page = 1, nStallNum do
    if 2 == PlayerShop_IsOpenStall(page) then
      PlayerShop_ClickPage(page)
      for i = 1, 20 do
        local szItemName, nItemNum, nSale, nMoney = PlayerShop_EnumItem(page, i)
        if szItemName and 1 == nSale and nItemNum > 0 and nMoney > 0 and "" ~= szItemName and "nil" ~= szItemName and SHGL_ItemUpdateDownStall(szItemName, nItemNum, nMoney, tQuery_Item) then
          bIsUpdate = true
        end
      end
      for i = 1, 20 do
        local szItemName, nItemNum, nSale, nMoney = PlayerShop_EnumItem(page, i)
        if szItemName and 0 == nSale and nItemNum > 0 and "" ~= szItemName and "nil" ~= szItemName and SHGL_ItemUpStall(szItemName, nItemNum, tQuery_Item) then
          bIsUpStall = true
        end
      end
      Sleep(500)
    end
  end
  return bIsUpStall, bIsUpdate
end

function _SMain()
  LoadScript("shanghui")
  ClearBag()
  CloseAllWindow()
  local tSHID = SH_init_SHID(m_param.sh_ID_text)
  if 0 == #tSHID then
    PushDebugMessage("商会比价：未解析到正确的商会ID,请检查！")
    return
  end
  table.insert(m_param.sh_ID, tSHID[1])
  if m_param.run_diff < 8 then
    m_param.run_diff = 8
  end
  if m_param.over_min <= 0 then
    m_param.over_min = 3
  end
  m_param.list_item = SHGL_EnumItemList()
  m_param.bj_item = {}
  for i = 1, #m_param.list_item do
    local tmp = m_param.list_item[i]
    if 1 == tmp.price_mode then
    elseif 2 == tmp.price_mode then
      table.insert(m_param.bj_item, tmp)
    elseif 3 == tmp.price_mode then
    end
  end
  if 0 == #m_param.bj_item then
    PushColorMsg("没有解析到物品！对定价方式或通用定价为【市场底价】的物品进行比价")
    return
  end
  SH_CloseWindow()
  local nStartTime = GetTickCount()
  while true do
    local debugnote = ""
    local tQuery_Item = SHGL_QueryPrice(m_param.bj_item, nil, m_param.sh_ID_text, m_param.max_price_diff)
    while true do
      local openID = SH_OpenManage(m_param.sh_ID)
      if openID > 0 then
        local bIsUpStall, bIsUpdate = SHGL_Up_Down(tQuery_Item)
        break
      else
        debugnote = ",打开管理窗口,商会ID" .. openID
      end
      Sleep(500)
      DebugStr("商会比价 " .. debugnote)
    end
    Sleep(m_param.run_diff * 1000)
    if m_param.time_over and -1 ~= nStartTime and GetTickCount() - nStartTime > m_param.over_min * 60 * 1000 then
      PushColorMsg("商会比价：已经运行" .. m_param.over_min .. "分钟，结束！")
      break
    end
    DebugStr("商会比价 " .. debugnote)
  end
  SH_CloseWindow()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
