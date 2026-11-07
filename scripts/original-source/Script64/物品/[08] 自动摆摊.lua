-- 反编译自 dfz64.dll 内嵌字节码 0045d2b4（unluac 2025-12-23；仅供分析）
local m_script_name = "自动摆摊"
ScriptOnStart(m_script_name, false, false)
g_config.zdbt = {}
g_config.zdbt.ty_price = GetConfigCommbox("摆摊收购", "摆摊定价")
g_config.zdbt.over_energy = ReadConfigBool("ZH", "xzk102")
g_config.zdbt.over_time = ReadConfigInt("ZH", "bjk70")
g_config.zdbt.over_jb = ReadConfigBool("ZH", "bjk141")
g_config.zdbt.over_jb_count = ReadConfigInt("ZH", "bjk69")
g_config.zdbt.max_price_diff = ReadConfigInt("ZH", "bjk47")
g_config.zdbt.twname = ReadConfigText("ZH", "bjk46")
g_config.zdbt.scene = GetConfigCommbox("摆摊收购", "摆摊地图")
g_config.zdbt.x = ReadConfigInt("ZH", "bjk45")
g_config.zdbt.y = ReadConfigInt("ZH", "bjk55")
g_config.zdbt.bank_take = ReadConfigBool("ZH", "xzk74")
g_config.zdbt.bank_take_diff = ReadConfigInt("ZH", "bjk57")
g_config.zdbt.sale_all_bagitem = ReadConfigBool("ZH", "xzk146")
g_config.zdbt.not_sale_item = ""
g_config.zdbt.list_item = GetConfigListCtrlEx("摆摊收购", "摆摊列表", 6)
local m_param = {}
m_param.list_item = {}
m_param.auto_item = {}
m_param.ty_price = 1
if 1 == g_config.zdbt.ty_price.sel then
  m_param.ty_price = 2
end
m_param.over_energy = g_config.zdbt.over_energy
m_param.over_time = HandleTextToNumber(g_config.zdbt.over_time, 120)
m_param.over_jb = g_config.zdbt.over_jb
m_param.over_jb_count = HandleTextToNumber(g_config.zdbt.over_jb_count, 10000)
m_param.max_price_diff = HandleTextToNumber(g_config.zdbt.max_price_diff, 0)
m_param.twname = g_config.zdbt.twname
if m_param.twname == "" then
  m_param.twname = "杂货摊位"
end
m_param.twtext = "#G走过路过不要错过"
m_param.twscene = g_config.zdbt.scene.text
m_param.twsceneID = -1
m_param.twx = HandleTextToNumber(g_config.zdbt.x, 295)
m_param.twy = HandleTextToNumber(g_config.zdbt.y, 306)
m_param.bank_take = g_config.zdbt.bank_take
m_param.bank_take_diff = HandleTextToNumber(g_config.zdbt.bank_take_diff, 306)
m_param.sale_all_bagitem = g_config.zdbt.sale_all_bagitem
m_param.not_sale_item = HandleText_AddFuHao(HandleText(g_config.zdbt.not_sale_item), " ", true)
local m_data = {}
m_data.query_item = {}
m_data.tick_bankget = -1

local function ZDBT_GetListItem()
  local list_item = {}
  
  local function _GetModePrice(aStrMode)
    if "市场均价" == aStrMode then
      return 1
    elseif "市场底价" == aStrMode then
      return 2
    elseif "固定价格" == aStrMode then
      return 3
    elseif 1 == g_config.zdbt.ty_price.sel then
      return 2
    end
    return 1
  end
  
  for i = 1, #g_config.zdbt.list_item do
    local info = g_config.zdbt.list_item[i]
    if #info >= 6 then
      local itemName = info[1]
      if #itemName > 1 then
        local nCount = tonumber(info[2]) or 1
        local strType = info[3]
        local nGdPrice = tonumber(info[4]) or 0
        local nModePrice = _GetModePrice(info[5])
        local nSplit = tonumber(info[6]) or 0
        if nCount <= 0 then
          nCount = 1
        end
        local nType = 1
        if "元宝" == strType then
          nType = 2
        end
        if nGdPrice < 0 then
          nGdPrice = 0
        end
        if nSplit < 0 then
          nSplit = 0
        end
        if 3 == nModePrice and nGdPrice <= 0 then
          PushColorMsg(itemName .. ":自定义价格却未设置价格 ")
        elseif m_param.twsceneID == 224 then
          if 2 == nType then
            if FindTableFieldValue(list_item, "name", itemName) == false then
              local gdSingle = nGdPrice / nCount
              table.insert(list_item, {
                name = itemName,
                price_mode = nModePrice,
                price_min_single = 0,
                price_query_single = 0,
                price_gd_single = gdSingle,
                split_num = nSplit
              })
            else
              PushColorMsg("元宝名称重复 " .. itemName)
            end
          end
        elseif 1 == nType then
          if FindTableFieldValue(list_item, "name", itemName) == false then
            local gdSingle = nGdPrice / nCount
            table.insert(list_item, {
              name = itemName,
              price_mode = nModePrice,
              price_min_single = 0,
              price_query_single = 0,
              price_gd_single = gdSingle,
              split_num = nSplit
            })
          else
            PushColorMsg("金币名称重复 " .. itemName)
          end
        end
      end
    end
  end
  return list_item
end

local function ZDBT_GetAutoItem()
  local auto_item = {}
  local nModePrice = 1
  if 1 == g_config.zdbt.ty_price.sel then
    nModePrice = 2
  end
  if m_param.sale_all_bagitem then
    local tItem = Bag:EnumUnBindItem(true)
    for i = 1, #tItem do
      local tmp = tItem[i]
      if FindTableFieldValue(m_param.list_item, "name", tmp.name) == false and not string.find(m_param.not_sale_item, " " .. tmp.name .. " ", nil, true) then
        if m_param.twsceneID == 224 then
          local isYBItem = GetLuaValue(fmt("return PlayerPackage:IsYubaoTradeItem(%d);", tmp.index), "n")
          if 1 == isYBItem then
            table.insert(auto_item, {
              name = tmp.name,
              price_mode = nModePrice,
              price_min_single = 0,
              price_query_single = 0,
              price_gd_single = 0,
              split_num = 0
            })
          end
        else
          table.insert(auto_item, {
            name = tmp.name,
            price_mode = nModePrice,
            price_min_single = 0,
            price_query_single = 0,
            price_gd_single = 0,
            split_num = 0
          })
        end
      end
    end
  end
  return auto_item
end

local function ZDBT_GetStallCount()
  return GetLuaValue([[
            local nSpace = 0
            for i = 1, 20 do
                local theAction = EnumAction(i - 1, "st_self")
                if theAction:GetID() == 0 then
                    nSpace = nSpace + 1
                end
            end
            return nSpace
        ]], "n")
end

local function ZDBT_ItemUpStall(aBagItem, atPrice)
  local bIsUpStall = false
  if not IsWindowVisible("StallSale", nil, "PushEvent(\"OPEN_STALL_SALE\")") then
    Sleep(2000)
  end
  local nIndex = aBagItem.index
  local nItemNum = aBagItem.count
  if 0 == nItemNum then
    return false
  end
  local tmp = atPrice
  if 0 == atPrice.split_num or nItemNum <= atPrice.split_num then
    if 0 ~= ZDBT_GetStallCount() then
      CloseWindow("InputMoney")
      CloseWindow("InputYuanbao")
      local nPrice = math.floor(tmp.price_query_single * nItemNum)
      if tmp.price_query_single > 0 and 0 == nPrice then
        nPrice = 1
      end
      local nPrice_min = math.floor(tmp.price_min_single * nItemNum)
      if 3 == tmp.price_mode and tmp.price_gd_single > 0 then
        nPrice = math.floor(tmp.price_gd_single * nItemNum)
        if 0 == nPrice then
          nPrice = 1
        end
      end
      if 2 ~= tmp.price_mode or nPrice_min < nPrice then
      end
      if nPrice > 0 then
        Bag:ItemBtnClicked(nIndex)
        Sleep(600)
        if IsWindowVisible("InputMoney") then
          GetLuaValue(fmt("StallSale:ReferItemPrice(%d);", nPrice))
          PushColorMsg(fmt("上架:%s, 数量：%d, 总价:%.2f金", tmp.name, nItemNum, nPrice / 10000))
          CloseWindow("InputMoney")
        elseif IsWindowVisible("InputYuanbao") then
          PushColorMsg(fmt("上架:%s, 数量：%d, 总价:%s元宝", tmp.name, nItemNum, nPrice))
          GetLuaValue(fmt("StallSale:ReferItemPrice(%d);", nPrice))
          CloseWindow("InputYuanbao")
        end
        Sleep(200)
      end
    end
  else
    SplitItem(nIndex, atPrice.split_num)
  end
  return true
end

local function ZDBT_GetItem()
  local tExc = {}
  local tItem = Bag:EnumUnBindItem(true)
  for i = 1, #tItem do
    local tmp = tItem[i]
    local nLocked = GetLuaValue(fmt("local theAction, bLocked, bProtect = PlayerPackage:EnumItem(\"base\", %d);return bLocked", tmp.index), "n")
    if 0 == nLocked then
      table.insert(tExc, tmp)
    end
  end
  local tGet = TableGetTable(tExc, m_data.query_item, "name")
  return tGet
end

local function ZDBT_BagToStall()
  local bBagHave = false
  local tItem = ZDBT_GetItem()
  for i = 1, #tItem do
    local tmp = tItem[i]
    local tFind = GetTableFieldValue(m_data.query_item, "name", {
      tmp.name
    })
    if #tFind > 0 then
      local priceInfo = tFind[1]
      ZDBT_ItemUpStall(tmp, priceInfo)
      bBagHave = true
    end
  end
  return bBagHave
end

local function ZDBT_GetItemFromBank(abMust)
  local bOver = false
  local spaceCount = ZDBT_GetStallCount()
  if m_param.bank_take then
    if abMust or 20 == spaceCount or GetTickCount() - m_data.tick_bankget > m_param.bank_take_diff * 60 * 1000 then
      local szGetItem = ""
      for i = 1, #m_data.query_item do
        local tmp = m_data.query_item[i]
        szGetItem = szGetItem .. tmp.name .. " "
      end
      if TempBank2Bag(szGetItem, 1, 0) == false then
        RemoveStall()
        local nCnt = Bank_GetItem(szGetItem, -1, 1, 1, false)
        m_data.tick_bankget = GetTickCount()
        if 0 == nCnt and 20 == spaceCount then
          bOver = true
        elseif 0 == nCnt then
          m_param.bank_take = false
        end
      end
    end
  elseif 20 == spaceCount then
    bOver = true
  end
  return bOver
end

local function ZDBT_CheckUpStall()
  local bOver = false
  local spaceCount = ZDBT_GetStallCount()
  if spaceCount > 0 then
    local bBagHave = ZDBT_BagToStall()
    if not bBagHave then
      bOver = ZDBT_GetItemFromBank()
    end
  end
  return bOver
end

local function ZDBT_FindTanWeiPos()
  local allPos = GetRangeAllPos(m_param.twx, m_param.twy, 1, 15, nil)
  for i = 1, #allPos do
    local pos = allPos[i]
    DeleteDebugMsg("这个地方不能摆摊")
    RunTo(pos.x, pos.y, 0, 1000)
    PlayerStateTimeOut(2, 10)
    GetLuaValue("PlayerPackage:OpenStallSaleFrame();StallSale:AgreeBeginStall();")
    Sleep(1000)
    if 10 == Player:GetState() then
      break
    end
    DebugStr("正在周围寻找摆摊位置")
  end
end

function _SMain(...)
  LoadScript("shanghui")
  m_param.twsceneID = GetSceneIDByName(m_param.twscene)
  m_param.list_item = ZDBT_GetListItem()
  m_param.auto_item = ZDBT_GetAutoItem()
  local bNeedQuery = false
  for i = 1, #m_param.list_item do
    local tmp = m_param.list_item[i]
    if 3 ~= tmp.price_mode then
      bNeedQuery = true
      break
    end
  end
  if false == bNeedQuery then
    for i = 1, #m_param.auto_item do
      local tmp = m_param.auto_item[i]
      if 3 ~= tmp.price_mode then
        bNeedQuery = true
        break
      end
    end
  end
  if bNeedQuery then
    PushDebugMessage("自动摆摊:需要查询价格")
    RemoveStall()
    if m_param.twsceneID == 224 then
      m_data.query_item = QZ_QueryPrice(m_param.list_item, m_param.auto_item, "", m_param.max_price_diff)
    else
      m_data.query_item = SHGL_QueryPrice(m_param.list_item, m_param.auto_item, "", m_param.max_price_diff)
    end
  else
    for i = 1, #m_param.list_item do
      local tmp = m_param.list_item[i]
      table.insert(m_data.query_item, {
        name = tmp.name,
        price_query_single = tmp.price_query_single,
        price_mode = tmp.price_mode,
        price_min_single = tmp.price_min_single,
        price_gd_single = tmp.price_gd_single,
        split_num = tmp.split_num
      })
    end
  end
  if Player:GetMoney() < 1000 and Player:GetMoney(2) < 1000 then
    PushColorMsg("自动摆摊：携带金币不足10银,无法摆摊")
    Bank_GetMoney(10000)
  end
  if m_param.bank_take and 10 ~= Player:GetState() then
    local nSpace1 = Bag:GetSpaceNum(0)
    local nSpace2 = Bag:GetSpaceNum(1)
    if nSpace1 > 0 and nSpace2 > 0 then
      PushColorMsg("自动摆摊:仓库取出")
      local tBank = Bank_EnumItem()
      local itemBank = TableGetTable(tBank, m_data.query_item, "name")
      if #itemBank > 0 then
        PushDebugMessage("自动摆摊：背包有空位,仓库取物")
        ZDBT_GetItemFromBank()
      end
    end
  end
  local startTime = os.time()
  local is_first = true
  local last_pos
  while true do
    if os.time() - startTime > m_param.over_time * 60 then
      PushColorMsg("自动摆摊：已满%s分钟,结束摆摊！", m_param.over_time)
      break
    end
    if m_param.over_energy then
      local nRet = GetLuaValue("local nEnergy = Player:GetData('ENERGY');local nMaxEnergy = Player:GetData('MAXENERGY');if nMaxEnergy > 0 then if nEnergy >= nMaxEnergy then return 1 end end return 0;", "n")
      if 1 == nRet then
        PushColorMsg("自动摆摊：精力已经恢复满,结束摆摊！")
        break
      end
    end
    if m_param.over_jb then
      local nBankMoney = Bank_GetBankMoney()
      local bagMoney = Player:GetMoney()
      if nBankMoney + bagMoney > m_param.over_jb_count * 10000 then
        PushColorMsg("自动摆摊：金币已达到预设值,结束摆摊！")
        break
      end
    end
    if 10 == Player:GetState() then
      local pos = Player:GetPos()
      last_pos = {}
      last_pos.x = pos.x
      last_pos.y = pos.y
      last_pos.sceneID = GetSceneID()
      if is_first then
        is_first = false
        GetLuaValue(fmt([[
                    setmetatable(_G, {__index = StallSale_Env});
                    if this:IsVisible() then  
                        StallSale:ModifStallName("%s");
                    end
                ]], m_param.twname))
        GetLuaValue(fmt([[
                    setmetatable(_G, {__index = StallMessage_Env});
                    if this:IsVisible() then  
                        StallMessage_StaticText:SetText("%s");
                    end
                ]], m_param.twtext))
      end
      if ZDBT_CheckUpStall() then
        PushColorMsg("自动摆摊：已经没有需要摆摊的物品,结束摆摊！")
        break
      end
      Sleep(5000)
    else
      is_first = true
      if Player:GetMoney() < 1000 and Player:GetMoney(2) < 1000 then
        PushColorMsg("自动摆摊：携带金币不足10银,无法摆摊")
        break
      end
      Pet:Relax()
      if last_pos then
        GoToScene(last_pos.x, last_pos.y, last_pos.sceneID, 1)
        ChangeSceneLine(true)
      else
        GoToScene(m_param.twx, m_param.twy, m_param.twsceneID, 1)
        ChangeSceneLine(true)
      end
      Dismount()
      Sleep(800)
      if CheckMibao(nil) then
        DeleteDebugMsg("这个地方不能摆摊")
        GetLuaValue("PlayerPackage:OpenStallSaleFrame();StallSale:AgreeBeginStall();")
        Sleep(1000)
        if IsInDebugMsg("这个地方不能摆摊") then
          ZDBT_FindTanWeiPos()
        end
      end
      MessageBox_Self_OK_Clicked(500)
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
  RemoveStall()
  Bank_SaveMoney(0)
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
