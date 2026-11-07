-- 反编译自 dfz64.dll 内嵌字节码 0047a37d（unluac 2025-12-23；仅供分析）
local m_script_name = "钱庄寄售"
ScriptOnStart(m_script_name, false, false, false)
g_config["寄售上架"] = {}
g_config["寄售上架"]["上架仓库锦囊"] = ReadConfigBool("ZH", "xzk192")
g_config["寄售上架"]["检查上架数量"] = ReadConfigBool("ZH", "xzk67")
g_config["寄售上架"]["通用定价"] = GetConfigCommbox("寄售", "通用定价")
g_config["寄售上架"]["物品列表"] = GetConfigListCtrlEx("寄售", "物品列表", 5)
local m_param = {}
m_param.bank_take = g_config["寄售上架"]["上架仓库锦囊"]
m_param.check_split = g_config["寄售上架"]["检查上架数量"]
local m_data = {}
m_data.query_item = {}

local function JSSJ_GetListInfo(aName)
  local tItem = GetTableFieldValue(m_data.query_item, "name", {aName})
  if #tItem > 0 then
    return tItem[1]
  end
  return nil
end

local function QZJS_AskData()
end

local function QZJS_GetActionState()
  QZJS_AskData()
  local szText = [[
        local nAction = 0
        local nEmpty = 0
        local allName = ""
        for i = 1, 10 do
            local theAction = EnumAction(i - 1, "ybmarket_self")
            if theAction:GetID() == 0 then
                nEmpty = nEmpty + 1
            else
                local pName, nowStatus, price = Auction:GetMySellBoxItemAuctionInfo(i - 1)
                allName = allName .. pName .. " "
                if nowStatus == 3 then
                    Auction:GetMoney(2, i - 1)
                    nAction = 3
                elseif nowStatus == 2 then
                    Auction:GetBackExpired(2, i - 1, 0)                    
                    nAction = 2
                end
            end
        end
        return nEmpty,nAction,allName
        ]]
  return GetLuaValue(szText, "nns")
end

local function QZJS_CheckPrice()
  local bUpdate = false
  for i = 1, 10 do
    local szText = fmt([[
                local i = %d
                local theAction = EnumAction(i - 1, "ybmarket_self")
                if theAction:GetID() ~= 0 then
                    local pName, nowStatus, price = Auction:GetMySellBoxItemAuctionInfo(i - 1)
                    if pName ~= nil and pName ~= "" then
                        return theAction:GetNum(),price,nowStatus,pName
                    end
                end
                return -1,-1,-1,"nil"
            ]], i)
    local iNum, iPrice, iStatus, szName = GetLuaValue(szText, "nnns")
    if iNum > 0 and iPrice > 0 and 1 == iStatus then
      local item = JSSJ_GetListInfo(szName)
      if item then
        local fPrice = item.price_query_single * iNum
        if 3 == item.price_mode then
          fPrice = item.price_gd_single * iNum
        end
        if fPrice >= 2 and fPrice <= 200000 then
          local nPrice = math.floor(fPrice)
          if 2 == item.price_mode and nPrice == fPrice and nPrice >= 10 then
            nPrice = nPrice - 1
            if nPrice / iNum < item.price_min_single then
              nPrice = nPrice + 1
            end
          end
          if nPrice ~= iPrice then
            bUpdate = true
            PushColorMsg("商品:%s 与设置的价格不符!", szName)
            GetLuaValue(fmt([[
              
                                local idx = %d
                                local nPrice = %d
                                local guidH, guidL = Auction:GetMyAuctionSellBoxItemGuid(idx)
                                Auction:ChangePrice(2, idx, nPrice, guidH, guidL)        
                            ]], i - 1, nPrice))
            Sleep(500)
          end
        end
      end
    end
  end
  return bUpdate
end

local function QZJS_OnAction()
  local bOpenWindow = false
  local bMaxCount = false
  local bUpdate = QZJS_CheckPrice()
  for i = 1, 10 do
    local nEmpty, nAction = QZJS_GetActionState()
    if 2 ~= nAction and 3 ~= nAction then
      break
    end
    Sleep(300)
  end
  local bAction = false
  local bSplit = false
  local tBag = Bag:EnumUnBindItem(true)
  local tAction_item = TableGetTable(tBag, m_data.query_item, "name")
  local nCnt = 0
  local maxCnt = 1
  while true do
    nCnt = nCnt + 1
    for i = 1, #tAction_item do
      local tmp = tAction_item[i]
      local item = JSSJ_GetListInfo(tmp.name)
      if item and (0 == item.split_num or tmp.count == item.split_num or not m_param.check_split and tmp.count < item.split_num) then
        local fPrice = item.price_query_single * tmp.count
        if 3 == item.price_mode then
          fPrice = item.price_gd_single * tmp.count
        end
        if fPrice >= 2 and fPrice <= 200000 then
          local nPrice = math.floor(fPrice)
          if 2 == item.price_mode and nPrice == fPrice and nPrice >= 10 then
            nPrice = nPrice - 1
            if nPrice / tmp.count < item.price_min_single then
              nPrice = nPrice + 1
            end
          end
          bAction = true
          PushColorMsg("上架：%s", tmp.name)
          GetLuaValue(fmt("Auction:PacketSend_SellItem(%d, %d, 1)", tmp.index, nPrice))
          Sleep(400)
        else
          PushColorMsg("寄售：价格低于2YB无法上架")
        end
      elseif item and tmp.count > item.split_num and item.split_num > 0 then
        if tmp.index < 30 then
          local nBagBaseSpace = Bag:GetSpaceNum(0)
          if nBagBaseSpace > 0 then
            bSplit = true
            SplitItem(tmp.index, item.split_num)
          else
            DebugColorMsg("背包没用空位,无法拆分", 2)
          end
        else
          local nBagMatSpace = Bag:GetSpaceNum(1)
          if nBagMatSpace > 0 then
            bSplit = true
            SplitItem(tmp.index, item.split_num)
          else
            DebugColorMsg("背包没用空位,无法拆分", 2)
          end
        end
      end
      if not IsWindowVisible("YbMarketSale") then
        bOpenWindow = true
      end
      local nEmpty, nAction = QZJS_GetActionState()
      if 0 == nEmpty then
        bMaxCount = true
        break
      end
    end
    if false == bAction and false == bSplit then
      Bag:PackUp(-1)
      Sleep(1000)
      maxCnt = 3
    end
    if nCnt >= maxCnt then
      break
    end
  end
  return bOpenWindow, bMaxCount, bAction, bSplit, bUpdate
end

local function JSSJ_Action()
  local list_item = JSSJ_GetItem("钱庄")
  if 0 == #list_item then
    PushColorMsg("寄售：未解析到物品")
    return
  end
  if Player:GetMoney(1) + Player:GetMoney(2) < 30000 then
    PushColorMsg("寄售：金币不足3J,取金币！")
    Bank_GetMoney(30000, "洛阳")
  end
  local tBankItem = Bank_EnumItem()
  local tBagItem = Bag:EnumAllObj()
  local tJNItem = Bag:EnumTempBagItem()
  local tAllItem = {}
  tAllItem = TableInsertTable_arr(tAllItem, "name", tBankItem)
  tAllItem = TableInsertTable_arr(tAllItem, "name", tBagItem)
  tAllItem = TableInsertTable_arr(tAllItem, "name", tJNItem)
  while true do
    if GetSceneID() == 224 and IsWindowVisible("YbMarketSale") then
      local _, _, allName = QZJS_GetActionState()
      local tName = Text2Table(allName, " ", "name")
      tAllItem = TableInsertTable_arr(tAllItem, "name", tName)
      for i = 1, 10 do
        local nEmpty, nAction = QZJS_GetActionState()
        if 2 ~= nAction and 3 ~= nAction then
          goto lbl_126
        end
        Sleep(300)
      end
      break
    else
      Player:TeamFollow(false, 300)
      GoToSceneNPC("孙聚财", 60, 30, 224)
      ChangeSceneLine(true)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{YBSC_100111_65}", 1, 1000)
    end
    Sleep(500)
    DebugStr("收取元宝")
  end
  ::lbl_126::
  list_item = TableGetTable(list_item, tAllItem, "name")
  m_data.query_item = QZ_QueryPrice(list_item, {}, g_self.name, 0)
  if 0 == #m_data.query_item then
    PushColorMsg("寄售：未查询到物品")
    return
  end
  local bTempTake = false
  local bBankTake = false
  local nTickOut = -1
  DeleteDebugMsg("#{YBSC_100111_02}")
  CloseAllWindow()
  while true do
    if GetSceneID() == 224 and IsWindowVisible("YbMarketSale") then
      local bOpenWindow, bMaxCount, bAction, bSplit, bUpdate = QZJS_OnAction()
      if false == bOpenWindow then
        if bMaxCount then
          PushColorMsg("寄售：寄售商品上限！")
          break
        end
        if false == bUpdate and false == bAction and false == bSplit then
          PushColorMsg("寄售：已经没有需要寄售的物品！")
          if m_param.bank_take then
            PushDebugMessage("仓库锦囊取需要上架钱庄的物品")
            local szItemName = Array2Text(m_data.query_item, " ", "name")
            if false == bTempTake then
              TempBank2Bag(szItemName, 1)
              Sleep(1000)
              bTempTake = true
            elseif false == bBankTake then
              Bank_GetItem(szItemName, -1, 1, 1)
              Sleep(1000)
              bBankTake = true
            else
              break
            end
          else
            break
          end
        end
      end
    else
      Player:TeamFollow(false, 300)
      GoToSceneNPC("孙聚财", 60, 30, 224)
      ChangeSceneLine(true)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{YBSC_100111_65}", 1, 1000)
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 300000 then
      PushColorMsg("寄售上架：超时!")
      break
    end
    if IsInDebugMsg("#{YBSC_100111_02}") then
      PushColorMsg("寄售：今日上架次数到上限，已经无法上架！")
      break
    end
    Sleep(300)
    DebugStr("寄售上架")
  end
  CloseAllWindow()
  if m_param.bank_take then
    Bag_Move2TempBank(nil, nil, nil, false)
  end
  Bag:PackUp(-1)
end

function _SMain(...)
  LoadScript("shanghui")
  if Player:GetMoney(1) + Player:GetMoney(2) < 200000 then
    PushColorMsg(m_script_name .. ":金币不足20J,仓库取出")
    Bank_GetMoney(200000, "洛阳")
  end
  JSSJ_Action()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
