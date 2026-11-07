-- 反编译自 dfz64.dll 内嵌字节码 00464940（unluac 2025-12-23；仅供分析）
local m_script_name = "商会管理"
ScriptOnStart(m_script_name, false, false)
GlobalParam_shgl()
local m_param = {}
m_param.sh_ID_text = g_config.shgl.id_text
m_param.sale_all_item = g_config.shgl.sale_all_item
m_param.update_sell_price = g_config.shgl.update_sell_price
m_param.not_sale_item = HandleText_AddFuHao(HandleText(g_config.shgl.not_sale_item))
m_param.ty_price = 1
if 1 == g_config.shgl.ty_price.sel then
  m_param.ty_price = 2
end
m_param.sh_ID = {}
m_param.list_item = {}
m_param.sh_item = {}
m_param.max_price_diff = HandleTextToNumber(g_config.shgl.max_price_diff, 0)

local function SHGL_insert_item(tItem, bAuto_sale, bAuto_update)
  for i = 1, #tItem do
    local tmp = tItem[i]
    if FindTableFieldValue(m_param.list_item, "name", tmp.name) == false and false == FindTableFieldValue(m_param.sh_item, "name", tmp.name) then
      local strName = HandleText_AddFuHao(tmp.name)
      if not string.find(m_param.not_sale_item, strName, nil, true) and (bAuto_sale and 0 == tmp.sale or bAuto_update and 1 == tmp.sale) then
        table.insert(m_param.sh_item, {
          name = tmp.name,
          price_mode = m_param.ty_price,
          price_query_single = 0,
          price_min_single = 0,
          price_gd_single = 0,
          split_num = 0,
          price_query = 0
        })
      end
    end
  end
end

local function SHGL_EnumSHItem(bAuto_sale, bAuto_update, aOtherItem)
  SH_CloseWindow()
  m_param.sh_item = {}
  for i = 1, #aOtherItem do
    local tmp = aOtherItem[i]
    if FindTableFieldValue(m_param.list_item, "name", tmp.name) == false and FindTableFieldValue(m_param.sh_item, "name", tmp.name) == false then
      local strName = HandleText_AddFuHao(tmp.name)
      if not string.find(m_param.not_sale_item, strName, nil, true) then
        table.insert(m_param.sh_item, {
          name = tmp.name,
          price_mode = m_param.ty_price,
          price_query_single = 0,
          price_min_single = 0,
          price_gd_single = 0,
          split_num = 0,
          price_query = 0
        })
      end
    end
  end
  if false == bAuto_sale and false == bAuto_update then
    return
  end
  local tSHID = SH_init_SHID(m_param.sh_ID_text)
  while true do
    local openID = SH_OpenManage(tSHID)
    if openID > 0 then
      local nStallNum = PlayerShop_GetStallNum()
      for page = 1, nStallNum do
        if 2 == PlayerShop_IsOpenStall(page) then
          PlayerShop_ClickPage(page)
          local tItem = PlayerShop_EnumPageObj(page)
          SHGL_insert_item(tItem, bAuto_sale, bAuto_update)
        end
      end
      tSHID = DeleteTableFieldValue(tSHID, "id", {openID})
      CloseWindow("PS_ShopMag")
    elseif -2 == openID then
      PushDebugMessage("商会管理：统计自动上架或更新物品完成," .. #m_param.sh_item .. "种物品")
      break
    end
    Sleep(500)
    DebugStr("商会管理：,正在统计自动上架或更新的物品")
  end
end

local function SHGL_ItemUpStall(szItemName, nItemNum, tQuery)
  local bIsUpStall = false
  local bIsQuery = false
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name == szItemName then
      bIsQuery = true
      local nPrice = math.floor(tmp.price_query_single * nItemNum)
      local nPrice_min = math.floor(tmp.price_min_single * nItemNum)
      if 3 == tmp.price_mode and tmp.price_gd_single > 0 then
        nPrice = math.floor(tmp.price_gd_single * nItemNum)
      end
      if 2 == tmp.price_mode and nPrice_min < nPrice then
        nPrice = nPrice - 1
      end
      if nPrice > 0 then
        if nPrice < 200000000 then
          bIsUpStall = true
          PushDebugMessage("商会管理：#cff66cc" .. tmp.name .. " #c00FFFF#e010101上架价格#cff66cc" .. nPrice .. "#c00FFFF#e010101铜")
          PlayerShop_UpStall(nPrice)
          break
        else
          PushColorMsg(tmp.name .. ":总价超出2万金,无法上架，请尝试拆分")
        end
      end
    end
  end
  if false == bIsQuery then
  end
  return bIsUpStall
end

local function SHGL_ItemUpdateDownStall(szItemName, nItemNum, aOldMoney, tQuery)
  local bIsUpdate = false
  local bIsQuery = false
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name == szItemName then
      bIsQuery = true
      local nPrice = math.floor(tmp.price_query_single * nItemNum)
      local nPrice_min = math.floor(tmp.price_min_single * nItemNum)
      if 3 == tmp.price_mode and tmp.price_gd_single > 0 then
        nPrice = math.floor(tmp.price_gd_single * nItemNum)
      end
      if 2 == tmp.price_mode and nPrice_min < nPrice then
        nPrice = nPrice - 1
      end
      if nPrice > 0 and nPrice ~= aOldMoney then
        bIsUpdate = true
        PushDebugMessage("商会管理：" .. tmp.name .. " 需要更新价格！")
        PlayerShop_DownSale()
        break
      end
    end
  end
  if false == bIsQuery then
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
      if m_param.update_sell_price then
        for i = 1, 20 do
          local szItemName, nItemNum, nSale, nMoney = PlayerShop_EnumItem(page, i)
          if szItemName and 1 == nSale and nItemNum > 0 and nMoney > 0 and "" ~= szItemName and "nil" ~= szItemName and SHGL_ItemUpdateDownStall(szItemName, nItemNum, nMoney, tQuery_Item) then
            bIsUpdate = true
          end
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
  m_param.sh_ID = SH_init_SHID(m_param.sh_ID_text)
  if 0 == #m_param.sh_ID then
    PushDebugMessage("商会管理：未解析到正确的商会ID,请检查！")
    return
  end
  m_param.list_item = SHGL_EnumItemList()
  local strTakeItem = ""
  local strSaveItem = ""
  if g_config.shgl.cun_bag or g_config.shgl.cun_bank then
    for i = 1, #m_param.list_item do
      local tmp = m_param.list_item[i]
      local str = tmp.name .. "|" .. tmp.split_num
      strTakeItem = strTakeItem .. str .. " "
      strSaveItem = strSaveItem .. tmp.name .. " "
    end
  end
  local tOther_item = SHCW_CunAllItem(g_config.shgl.cun_allbag, g_config.shgl.cun_allbag, g_config.shgl.cun_allbank, m_param.not_sale_item, {})
  if #tOther_item > 0 then
    for i = 1, #tOther_item do
      local tmp = tOther_item[i]
      strTakeItem = strTakeItem .. tmp.name .. " "
      strSaveItem = strSaveItem .. tmp.name .. " "
    end
  end
  local bBank = false
  if g_config.shgl.cun_bank or g_config.shgl.cun_allbank then
    bBank = true
  end
  if #strTakeItem > 2 then
    SHCW_OnStart(m_param.sh_ID_text, strTakeItem, "", bBank)
  end
  if g_config.shgl.cun_bank or g_config.shgl.cun_allbank then
    PushColorMsg("商会管理:剩余物品存入仓库")
    Bank_SaveItem(strSaveItem, -1, 1)
    Bag_Move2TempBank()
  end
  SHGL_EnumSHItem(m_param.sale_all_item, m_param.update_sell_price, tOther_item)
  local tQuery_Item = SHGL_QueryPrice(m_param.list_item, m_param.sh_item, m_param.sh_ID_text, m_param.max_price_diff)
  SH_CloseWindow()
  while true do
    local debugnote = ""
    local openID = SH_OpenManage(m_param.sh_ID)
    if openID > 0 then
      local bIsUpStall, bIsUpdate = SHGL_Up_Down(tQuery_Item)
      if false == bIsUpStall and false == bIsUpdate then
        m_param.sh_ID = DeleteTableFieldValue(m_param.sh_ID, "id", {openID})
        CloseWindow("PS_ShopMag")
      end
    else
      if -2 == openID then
        PushColorMsg("商会管理：已经没有需要管理的商会")
        break
      end
      debugnote = ",打开商会ID" .. openID
    end
    Sleep(100)
    DebugStr("商会管理 " .. debugnote)
  end
  SH_CloseWindow()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
