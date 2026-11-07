-- 反编译自 dfz64.dll 内嵌字节码 004664f6（unluac 2025-12-23；仅供分析）
local m_script_name = "天外寄售"
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

function TW_QueryPrice_base_price(aWithOutName, szItemName, aPriceMode, aMaxPriceDiff)
  local nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType = GetLuaValue(fmt("        local strWithOutName = \"%s\"\n        local strItem = \"%s\"\n        local findType = 0\n        local allPrice, allNum = 0, 0\n        local minPrice, minNum = 0, 0\n        for i = 1, 10 do\n            local theAction = EnumAction(i - 1, \"tauction_yb\")\n            if theAction:GetID() ~= 0 then\n                local pName , pSeller ,pCount ,pYB  = TAuction:GetItemAuctionInfo(1, i - 1)\n                if pName ~= nil and pSeller ~= nil and pCount ~= nil and pYB ~= nil and pCount > 0 then\n                    if pName == strItem then\n                        if not string.find(strWithOutName, \" \" .. pSeller .. \" \", nil, true) then\n                            findType = 2\n                            allPrice = allPrice + pYB\n                            allNum = allNum + pCount\n                            if minPrice == 0 or minNum == 0 then \n                                minPrice = pYB\n                                minNum =  pCount\n                            end\n                        else\n                            -- PushDebugMessage(\"首页指定玩家垄断\" .. pSeller)\n                            if findType ~= 2 then\n                                findType = 1\n                            end\n                        end\n                    end\n                end\n            else\n                break\n            end\n        end\n        if allPrice > 0 and allNum > 0 then\n            return minPrice, minNum, allPrice, allNum, findType\n        end    \n        return 0, 0, 0, 0, 0\n    ", aWithOutName, szItemName), "nnnnn")
  if 1 == aPriceMode then
    nMinPrice = nAllPrice
    nMinCount = nAllCount
  elseif 2 == aPriceMode then
    local maxDiff = aMaxPriceDiff
    if maxDiff > 0 and nMinCount > 0 and nMinPrice > 0 then
      local diffPrice = nAllPrice - nMinPrice
      local diffCount = nAllCount - nMinCount
      if diffCount > 0 and diffPrice > 0 then
        local minPP = nMinPrice / nMinCount
        local diffPP = diffPrice / diffCount
        if maxDiff < 100 - minPP / diffPP * 100 then
          PushColorMsg(szItemName .. ":市场底价低于平均价的" .. maxDiff .. "%,使用平均价")
          nMinPrice = diffPrice
          nMinCount = diffCount
        end
      end
    end
  end
  return nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType
end

function TW_QueryPrice_OnAction(tQuery, tUpStall, aWithOutName, aMaxPriceDiff)
  local nState = 0
  local strWithOutName = HandleText_AddFuHao(aWithOutName)
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name and tmp.name ~= "" and FindTableFieldValue(tUpStall, "name", tmp.name) == false then
      if 3 ~= tmp.price_mode then
        GetLuaValue(fmt("TAuction:PacketSend_Search(1, 1, 1, \"%s\", 1)", tmp.name))
        PushDebugMessage("查询物品:" .. tmp.name)
        Sleep(2000)
        if false == IsWindowVisible("TMarket") then
          nState = -1
          break
        end
        local nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType = TW_QueryPrice_base_price(strWithOutName, tmp.name, tmp.price_mode, aMaxPriceDiff)
        if nMinPrice > 0 and nMinCount > 0 then
          if 1 ~= nFindType then
            local fPrice = nMinPrice / nMinCount
            if tmp.price_min_single > 0 and fPrice < tmp.price_min_single then
              fPrice = tmp.price_min_single
            end
            table.insert(tUpStall, {
              price_query_single = fPrice,
              name = tmp.name,
              price_mode = tmp.price_mode,
              price_min_single = tmp.price_min_single,
              price_gd_single = tmp.price_gd_single,
              split_num = tmp.split_num
            })
            nState = nState + 1
          end
        else
          PushDebugMessage(tmp.name .. ":没有查询到,可在列表设置自定价格来上架")
        end
      else
        table.insert(tUpStall, {
          price_query_single = 0,
          name = tmp.name,
          price_mode = tmp.price_mode,
          price_min_single = tmp.price_min_single,
          price_gd_single = tmp.price_gd_single,
          split_num = tmp.split_num
        })
        nState = nState + 1
      end
    end
  end
  return tUpStall, nState
end

function TW_CheckMarketPage()
  if IsWindowVisible("TMarket") then
    Sleep(100)
    return true
  else
    Player:TeamFollow(false, 300)
    if JL_MoveToNPC_line("商弘继", 433, 379, 1) then
      Sleep(500)
      QuestFrameOptionClicked_Item("#{WMZSZH_131028_11}", 1, 1500)
    end
  end
  return false
end

function TW_CloseWindow()
  CloseWindow("TMarket")
end

function TW_QueryPrice(aListItem, aOtherItem, aWithOutName, aMaxPriceDiff)
  TW_CloseWindow()
  local tUpStall = {}
  local nState_1, nState_2 = 0, 0
  local nMaxCnt = -1
  while true do
    if TW_CheckMarketPage() then
      tUpStall, nState_1 = TW_QueryPrice_OnAction(aListItem, tUpStall, aWithOutName, aMaxPriceDiff)
      if aOtherItem and #aOtherItem > 0 then
        tUpStall, nState_2 = TW_QueryPrice_OnAction(aOtherItem, tUpStall, aWithOutName, aMaxPriceDiff)
      end
      if 0 == nState_1 and 0 == nState_2 then
        nMaxCnt = nMaxCnt + 1
        if nMaxCnt > -1 then
          break
        end
        Sleep(500)
      else
        nMaxCnt = -1
      end
    end
    Sleep(200)
    DebugStr("正在查询元宝市场价格")
  end
  return tUpStall
end

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
        for i = 1, 10 do
            local theAction = EnumAction(i - 1, "tauction_yb_self")
            if theAction:GetID() == 0 then
                nEmpty = nEmpty + 1
            else
                local pName, nowStatus, price, itemlefttime = TAuction:GetMySellBoxItemAuctionInfo(1, i - 1)
                if nowStatus == 3 then
                    TAuction:GetMoney(1 , i - 1)
                    nAction = 3
                elseif nowStatus == 2 then
                    -- TAuction:ReUpExpired(1 , i - 1,0)
                    TAuction:GetBackExpired(1, i - 1, 0)                    
                    nAction = 2
                end
            end
        end
        return nEmpty,nAction
        ]]
  return GetLuaValue(szText, "nn")
end

local function QZJS_CheckPrice()
  local bUpdate = false
  for i = 1, 10 do
    local szText = fmt([[
                local i = %d
                local theAction = EnumAction(i - 1, "tauction_yb_self")
                if theAction:GetID() ~= 0 then
                    local pName, nowStatus, price, itemlefttime = TAuction:GetMySellBoxItemAuctionInfo(1, i - 1)
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
                                TAuction:ChangePrice(1, idx, nPrice)        
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
          GetLuaValue(fmt("TAuction:PacketSend_SellItem(1, %d, %d, 1)", tmp.index, nPrice))
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
          end
        else
          local nBagMatSpace = Bag:GetSpaceNum(1)
          if nBagMatSpace > 0 then
            bSplit = true
            SplitItem(tmp.index, item.split_num)
          end
        end
      end
      if not IsWindowVisible("TMarketSale") then
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
  local list_item = JSSJ_GetItem("天外")
  if 0 == #list_item then
    PushColorMsg("寄售：未解析到物品")
    return
  end
  if Player:GetMoney(1) + Player:GetMoney(2) < 30000 then
    PushColorMsg("寄售：金币不足3J,取金币！")
    Bank_GetMoney(30000, "凤鸣镇")
  end
  m_data.query_item = TW_QueryPrice(list_item, {}, g_self.name, 0)
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
    if GetSceneID() == 762 and IsWindowVisible("TMarketSale") then
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
      if JL_MoveToNPC_line("商弘继", 433, 379, 1) then
        Sleep(500)
        QuestFrameOptionClicked_Item("#{YBSC_100111_65}", 1, 1000)
      end
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
    Sleep(200)
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
  JSSJ_Action()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
