-- 反编译自 dfz64.dll 内嵌字节码 00547bce（unluac 2025-12-23；仅供分析）
local m_param = {}
m_param.item_take = {}
m_param.item_open = {}
m_param.item_close = {}
m_param.item_bag = {}
m_param.sh_ID = {}
m_param.tick = -1
local m_sg_param = {}
local m_sg_data = {}
m_sg_data.buyid_list = {}

function PlayerShop_GetStallNum()
  return GetLuaValue("return PlayerShop:GetStallNum(\"self\");", "n")
end

function PlayerShop_SetCurSelectPage(aPage)
  local bOK = true
  if aPage > 0 and aPage < 11 then
    aPage = aPage - 1
    local strText = fmt([[
       
                local actIndex = PlayerShop:UIIndexToLogicIndex(%d, true);
                if actIndex ~= -1 then 
                    PlayerShop:SetCurSelectPage("self", actIndex);
                end
                return actIndex               
            ]], aPage)
    local actIndex = GetLuaValue(strText, "n")
    if -1 == actIndex then
      bOK = false
    end
  end
  return bOK
end

function PlayerShop_ClickPage(aPage)
  GetLuaValue(fmt("setmetatable(_G, {__index=PS_ShopMag_Env});PS_ShopMag_Page_Click(%d);", aPage))
  Sleep(700)
  for i = 1, 10 do
    if PlayerShop_SetCurSelectPage(aPage) then
      break
    end
    Sleep(300)
  end
end

function PlayerShop_UpStall(aPrice)
  local strText = "PlayerShop:UpStall('item'," .. aPrice .. ");"
  GetLuaValue(strText)
  Sleep(600)
end

function PlayerShop_SetSelect(aPos)
  GetLuaValue(fmt("PlayerShop:SetSelectPet(%d -1)", aPos))
end

function PlayerShop_DownSale()
  GetLuaValue("PlayerShop:DownSale('item');")
  Sleep(600)
end

function PlayerShop_RetackItem()
  GetLuaValue("PlayerShop:RetackItem('item');")
  Sleep(800)
end

function PlayerShop_GetPageSpaceNum(aPage)
  return GetLuaValue(fmt([[
                local page ,n = %d,0       
                local actIndex = PlayerShop:UIIndexToLogicIndex(page - 1, true)
                for i = 1, 20 do
                    local theAction, bLocked = PlayerShop:EnumItem(actIndex, i - 1, "self")
                    if theAction:GetID() == 0 then
                        n = n + 1
                    end
                end
                return n 
            ]], aPage), "n")
end

function PlayerShop_IsOpenStall(aPage)
  return GetLuaValue(fmt([[
                local actIndex = PlayerShop:UIIndexToLogicIndex(%d, true)
                return PlayerShop:IsOpenStall("self",actIndex);    
            ]], aPage - 1), "n")
end

function PlayerShop_EnumItem(iPage, iPos)
  local strText = fmt([[
            local iPage, iPos  = %d,%d
            setmetatable(_G, {__index = PS_ShopMag_Env})
            local actIndex = PlayerShop:UIIndexToLogicIndex(iPage - 1, true)
            if actIndex ~= -1 then
                PlayerShop:SetCurSelectPage("self", actIndex)
                PlayerShop:SetSelectPet(iPos -1)
                local theAction, bLocked = PlayerShop:EnumItem(actIndex, iPos - 1, "self")
                if theAction:GetID() ~= 0 then
                    if PlayerShop:GetSelectIndex("self") == iPos then
                        local szName = theAction:GetName()
                        local nNum = theAction:GetNum()
                        local nIsSale = PlayerShop:IsSelectOnSale("item")
                        if szName and nNum and szName ~= "" and nNum > 0 then
                            local nMoney = 0
                            if nIsSale == 1 then
                                nMoney = PlayerShop:GetObjPrice("self", "item")
                            end
                            return szName, nNum, nIsSale, nMoney
                        end
                    end
                end
            end
            return "", 0, 0, 0
        ]], iPage, iPos)
  return GetLuaValue(strText, "snnn")
end

function PlayerShop_EnumPageObj(aPage)
  local tAll = {}
  for i = 1, 20 do
    local szItemName, nItemNum, nSale, nMoney = PlayerShop_EnumItem(aPage, i)
    if szItemName and nItemNum > 0 and "" ~= szItemName then
      table.insert(tAll, {
        index = i,
        name = szItemName,
        count = nItemNum,
        sale = nSale,
        price = nMoney
      })
    end
  end
  return tAll
end

function SH_init_SHID(aIDText)
  local tSH_ID = {}
  local allID = SplitString(aIDText, " ", true)
  for i = 1, #allID do
    local nID = tonumber(allID[i])
    if type(nID) == "number" and nID > 0 and FindTableFieldValue(tSH_ID, "id", nID) == false then
      table.insert(tSH_ID, {id = nID})
    end
  end
  return tSH_ID
end

function SH_CloseWindow()
  CloseWindow("PS_ShopMag")
  CloseWindow("PS_ShopList")
  CloseWindow("PS_ShopSearch")
end

function SH_QueryIndexById(strID, aShopType)
  local tID_index = {}
  QuestFrameOptionClicked_Item("#{RCYH_180606_102}", 1, 1000)
  if 1 == aShopType then
    local strText = [[
            setmetatable(_G, {__index = PS_ShopList_Env})
            if this:IsVisible() then
                PS_ShopList_ChangeTabIndex(1)
            end
        ]]
    GetLuaValue(strText)
    Sleep(500)
  end
  local strText = fmt([[
            local strID = "%s"
            local strRet = " "
            local nNum = PlayerShop:GetShopNum("search")
            for i = 0, nNum - 1 do
                local nIndex = PlayerShop:EnumSearchShopIndex(i)  --nIsFavor nRecItemnum nFrezeType             
                local szShopName, OpenNum, SaleNum, szType, _, _, _, nShopIndex = PlayerShop:EnumShop(nIndex)
                if string.find(strID, " " .. nShopIndex .. " ", nil, true) then
                    local strTemp = nIndex .. "&" .. nShopIndex
                    strRet = strRet .. strTemp .. " "
                end
            end
            return strRet       
        ]], strID)
  local strRet = GetLuaValue(strText, "s")
  local strArr1 = SplitString(strRet, " ", true)
  for i = 1, #strArr1 do
    local strArr2 = SplitString(strArr1[i], "&", true)
    if 2 == #strArr2 then
      local nIndex, nShopIndex = tonumber(strArr2[1]), tonumber(strArr2[2])
      if type(nIndex) == "number" and type(nShopIndex) == "number" then
        table.insert(tID_index, {id = nShopIndex, index = nIndex})
      end
    end
  end
  return tID_index
end

function SH_OpenManage(tSHID, aShopType)
  aShopType = aShopType or 0
  if 0 == #tSHID then
    return -2
  end
  if IsWindowVisible("PS_ShopMag") == false then
    GoToSceneNPC("乔复盛", 330, 299, LUOYANG_ID, nil, nil, nil, nil, true, true)
    ChangeSceneLine(true)
    Sleep(500)
    if IsWindowVisible("PS_ShopMag") == false then
      local tSHID_index = SH_QueryIndexById(Array2Text(tSHID, " ", "id"), aShopType)
      for i = 1, #tSHID do
        local bFind = false
        for j = 1, #tSHID_index do
          if tSHID_index[j].id == tSHID[i].id then
            PushDebugMessage("商会管理打开商会ID:" .. tSHID[i].id)
            for k = 1, 2 do
              GetLuaValue(fmt("PlayerShop:AskOpenShop(\"manage\", %d)", tSHID_index[j].index))
              Sleep(800)
            end
            bFind = true
            break
          end
        end
        if bFind then
          break
        end
      end
    end
    return -1
  else
    CloseWindow("PS_ShopList")
    CloseWindow("PS_ShopSearch")
    return GetLuaValue("return PlayerShop:GetShopInfo(\"self\",\"shopindex\")", "n")
  end
end

function SHGL_EnumItemList()
  local list_item = {}
  
  local function _GetModePrice(aStrMode)
    if "市场均价" == aStrMode then
      return 1
    elseif "市场底价" == aStrMode then
      return 2
    elseif "固定价格" == aStrMode then
      return 3
    elseif 1 == g_config.shgl.ty_price.sel then
      return 2
    end
    return 1
  end
  
  for i = 1, #g_config.shgl.list_item do
    local tmp = g_config.shgl.list_item[i]
    local info = SplitString(tmp, "|")
    if #info >= 6 then
      local itemName = info[1]
      if #itemName > 1 then
        local nCount = tonumber(info[2]) or 1
        local nMinPrice = tonumber(info[3]) or 0
        local nGdPrice = tonumber(info[4]) or 0
        local nModePrice = _GetModePrice(info[5])
        local nSplit = tonumber(info[6]) or 0
        if nCount <= 0 then
          nCount = 1
        end
        if nMinPrice < 0 then
          nMinPrice = 0
        end
        if nGdPrice < 0 then
          nGdPrice = 0
        end
        if nSplit < 0 then
          nSplit = 0
        end
        if 3 == nModePrice and nGdPrice <= 0 then
          PushColorMsg(itemName .. ":固定价格模式未设置价格 ")
        end
        if FindTableFieldValue(list_item, "name", itemName) == false then
          local minSingle = nMinPrice / nCount
          local gdSingle = nGdPrice / nCount
          table.insert(list_item, {
            name = itemName,
            price_mode = nModePrice,
            price_query_single = 0,
            price_min_single = minSingle,
            price_gd_single = gdSingle,
            split_num = nSplit,
            price_query = 0
          })
        else
          PushColorMsg("商会管理列表名称重复 " .. itemName)
        end
      end
    end
  end
  return list_item
end

function SHGL_QueryPrice_base_price(strSHID, szItemName, aPriceMode, aMaxPriceDiff)
  local nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType = GetLuaValue(fmt("        local myShopID = \"%s\"\n        local strItem = \"%s\"\n        local findType = 0\n        setmetatable(_G, {__index = PS_ShopSearch_Env})\n        local allPrice, allNum = 0, 0\n        local minPrice, minNum = 0, 0\n        for i = 1, 10 do\n            local theAction = EnumAction(i - 1, \"playershop_cur_page\")\n            if theAction:GetID() ~= 0 then\n                local pName, pShopName, pShopID, pCount, pYB = PlayerShop:GetItemPSInfo(i - 1)\n                if pName ~= nil and pShopID ~= nil and pCount ~= nil and pYB ~= nil and pCount > 0 then\n                    if pName == strItem then\n                        if not string.find(myShopID, \" \" .. pShopID .. \" \", nil, true) then\n                            findType = 2\n                            allPrice = allPrice + pYB\n                            allNum = allNum + pCount\n                            if minPrice == 0 or minNum == 0 then \n                                minPrice = pYB\n                                minNum =  pCount\n                            end\n                        else\n                            --PushDebugMessage(\"首页被自己垄断\")\n                            if findType ~= 2 then\n                                findType = 1\n                            end\n                        end\n                    end\n                end\n            else\n                break\n            end\n        end\n        if allPrice > 0 and allNum > 0 then\n            return minPrice, minNum, allPrice, allNum, findType\n        end    \n        return 0, 0, 0, 0, 0\n    ", strSHID, szItemName), "nnnnn")
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

function SHGL_QueryPrice_OnAction(tQuery, tUpStall, aShID, aMaxPriceDiff)
  local nState = 0
  local strSHID = HandleText_AddFuHao(aShID)
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name and tmp.name ~= "" and FindTableFieldValue(tUpStall, "name", tmp.name) == false then
      if 3 ~= tmp.price_mode then
        local find = {type = 2, subtype = 1}
        if tmp.name == "御瑶盘" or tmp.name == "琉璃焰" or string.find(tmp.name, "坐骑：", nil, true) then
          find.type = 3
          find.subtype = 10101
        elseif Bag:IsInfantEqui(tmp.name) then
          find.type = 4
          find.subtype = 10101
        end
        GetLuaValue(fmt("PlayerShop:PacketSend_Search(%d, %d, 1, \"%s\", 1)", find.type, find.subtype, tmp.name))
        PushDebugMessage("查询物品:" .. tmp.name)
        Sleep(2000)
        if false == IsWindowVisible("PS_ShopSearch") then
          nState = -1
          break
        end
        local nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType = SHGL_QueryPrice_base_price(strSHID, tmp.name, tmp.price_mode, aMaxPriceDiff)
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
              split_num = tmp.split_num,
              price_query = tmp.price_query
            })
            nState = nState + 1
          end
        else
          PushDebugMessage(tmp.name .. ":没有查询到,可在列表设置固定价格来上架")
        end
      else
        table.insert(tUpStall, {
          price_query_single = 0,
          name = tmp.name,
          price_mode = tmp.price_mode,
          price_min_single = tmp.price_min_single,
          price_gd_single = tmp.price_gd_single,
          split_num = tmp.split_num,
          price_query = tmp.price_query
        })
        nState = nState + 1
      end
    end
  end
  return tUpStall, nState
end

function SHGL_QueryPrice(aListItem, aShItem, aShID, aMaxPriceDiff)
  SH_CloseWindow()
  local tUpStall = {}
  local nState_1, nState_2 = 0, 0
  local nMaxCnt = -1
  while true do
    if ShangHui_CheckSearchPage() then
      tUpStall, nState_1 = SHGL_QueryPrice_OnAction(aListItem, tUpStall, aShID, aMaxPriceDiff)
      if aShItem then
        tUpStall, nState_2 = SHGL_QueryPrice_OnAction(aShItem, tUpStall, aShID, aMaxPriceDiff)
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
    DebugStr("正在查询市场价格")
  end
  return tUpStall
end

function QZ_QueryPrice_base_price(aWithOutName, szItemName, aPriceMode, aMaxPriceDiff)
  local nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType = GetLuaValue(fmt("        local strWithOutName = \"%s\"\n        local strItem = \"%s\"\n        local findType = 0\n        local allPrice, allNum = 0, 0\n        local minPrice, minNum = 0, 0\n        for i = 1, 10 do\n            local theAction = EnumAction(i - 1, \"ybmarket_cur_page\")\n            if theAction:GetID() ~= 0 then\n                local pName , pSeller ,pCount ,pYB  = Auction:GetItemAuctionInfo(i - 1)\n                if pName ~= nil and pSeller ~= nil and pCount ~= nil and pYB ~= nil and pCount > 0 then\n                    if pName == strItem then\n                        if not string.find(strWithOutName, \" \" .. pSeller .. \" \", nil, true) then\n                            findType = 2\n                            allPrice = allPrice + pYB\n                            allNum = allNum + pCount\n                            if minPrice == 0 or minNum == 0 then \n                                minPrice = pYB\n                                minNum =  pCount\n                            end\n                        else\n                            -- PushDebugMessage(\"首页指定玩家垄断\" .. pSeller)\n                            if findType ~= 2 then\n                                findType = 1\n                            end\n                        end\n                    end\n                end\n            else\n                break\n            end\n        end\n        if allPrice > 0 and allNum > 0 then\n            return minPrice, minNum, allPrice, allNum, findType\n        end    \n        return 0, 0, 0, 0, 0\n    ", aWithOutName, szItemName), "nnnnn")
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

function QZ_QueryPrice_OnAction(tQuery, tUpStall, aWithOutName, aMaxPriceDiff)
  local nState = 0
  local strWithOutName = HandleText_AddFuHao(aWithOutName)
  for i = 1, #tQuery do
    local tmp = tQuery[i]
    if tmp.name and tmp.name ~= "" and FindTableFieldValue(tUpStall, "name", tmp.name) == false then
      if 3 ~= tmp.price_mode then
        GetLuaValue(fmt("Auction:PacketSend_Search(2, 1, 1, \"%s\", 1)", tmp.name))
        PushDebugMessage("查询物品:" .. tmp.name)
        Sleep(2000)
        if false == IsWindowVisible("YbMarket") then
          nState = -1
          break
        end
        local nMinPrice, nMinCount, nAllPrice, nAllCount, nFindType = QZ_QueryPrice_base_price(strWithOutName, tmp.name, tmp.price_mode, aMaxPriceDiff)
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

function QZ_CheckMarketPage()
  if IsWindowVisible("YbMarket") then
    Sleep(100)
    return true
  else
    Player:TeamFollow(false, 300)
    GoToSceneNPC("孙聚财", 60, 30, 224)
    ChangeSceneLine(true)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{YBSC_100111_43}", 1, 1500)
  end
  return false
end

function QZ_CloseWindow()
  CloseWindow("YbMarket")
end

function QZ_QueryPrice(aListItem, aOtherItem, aWithOutName, aMaxPriceDiff)
  QZ_CloseWindow()
  local tUpStall = {}
  local nState_1, nState_2 = 0, 0
  local nMaxCnt = -1
  while true do
    if QZ_CheckMarketPage() then
      tUpStall, nState_1 = QZ_QueryPrice_OnAction(aListItem, tUpStall, aWithOutName, aMaxPriceDiff)
      if aOtherItem and #aOtherItem > 0 then
        tUpStall, nState_2 = QZ_QueryPrice_OnAction(aOtherItem, tUpStall, aWithOutName, aMaxPriceDiff)
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

function QZ_BuyItem(aBuyName, aBuyNum, aMaxMoney, aNameCmpMode)
  aNameCmpMode = aNameCmpMode or 1
  if aMaxMoney <= 0 then
    return -1
  end
  if nil == aBuyName or "" == aBuyName or aBuyNum <= 0 then
    return -1
  end
  CloseWindow("Quest")
  CloseWindow("WuhunQuest")
  DeleteDebugMsg("#{YBSC_100111_56}")
  DeleteDebugMsg("背包空间不足")
  local nTickOut = -1
  while true do
    if QZ_CheckMarketPage() then
      Sleep(300)
      GetLuaValue(fmt("Auction:PacketSend_Search(2, 1, 1, \"%s\", 1)", aBuyName))
      Sleep(2000)
      local bOk = GetLuaValue(fmt([[
                        local szName = '%s'
                        local theAction = EnumAction(0, "ybmarket_cur_page")
                        if theAction:GetID() ~= 0 then
                            local pName, pSeller ,pCount ,pYB = Auction:GetItemAuctionInfo(0)
                            if szName ~= "" and string.find(pName,szName,nil,true) then
                                return 1 
                            end
                        end
                        return 0
                    ]], aBuyName), "b")
      if bOk then
        break
      end
      if IsInDebugMsg("#{YBSC_100111_56}") then
        PushColorMsg("钱庄没有物品：" .. aBuyName)
        return -1
      end
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 20000 then
      PushColorMsg("钱庄打开搜索超时")
      return -1
    end
    Sleep(300)
    DebugStr("钱庄搜索物品：" .. aBuyName)
  end
  local nCount, nPrice = GetLuaValue(fmt([[
                local strWithOutName = ""
                local strItem = "%s"
                local nCount = %d
                local nMaxMoney = %f
                local nMohu = 1
                setmetatable(_G, {__index = YbMarket_Env})
                if this:IsVisible() then
                    for i = 1, 10 do
                        local theAction = EnumAction(i - 1, "ybmarket_cur_page")
                        if theAction:GetID() ~= 0 then
                            local pName, pSeller, pCount, pYB = Auction:GetItemAuctionInfo(i - 1)
                            if pName ~= nil and pSeller ~= nil and pCount ~= nil and pYB ~= nil and pCount > 0 then                         
                                if not string.find(strWithOutName, " " .. pSeller .. " ", nil, true) then
                                    if (nMohu == 1 and pName == strItem) and pCount <= nCount and pYB / pCount <= nMaxMoney then
                                        Auction:PacketSend_Buy(2, i - 1, 0)
                                        return pCount, pYB
                                    end
                                end             
                            end
                        else
                            break
                        end
                    end
                end
                return -1, -1
            ]], aBuyName, aBuyNum, aMaxMoney), "nn")
  if -1 ~= nCount then
    Sleep(1000)
    if IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click();") then
      Sleep(500)
    end
  end
  return nCount, nPrice
end

function SHCW_CunAllItem(aAllBagItem, aAllJnItem, aAllBankItem, aNotSaleItem, aWithOutItem)
  local tCanSellItem = {}
  aNotSaleItem = HandleText_AddFuHao(aNotSaleItem)
  local tAllItem = {}
  local tItem_bag = {}
  local tItem_jn = {}
  local tItem_bank = {}
  if aAllBagItem then
    tItem_bag = Bag:EnumUnBindItem(true)
  end
  if aAllJnItem then
    tItem_jn = Bag:EnumUnBindItem(true, Bag:EnumTempBagItem())
  end
  if aAllBankItem then
    tItem_bank = Bag:EnumUnBindItem(true, Bank_EnumItem())
  end
  tAllItem = TableInsertTable_arr(tAllItem, "name", tItem_bag)
  tAllItem = TableInsertTable_arr(tAllItem, "name", tItem_jn)
  tAllItem = TableInsertTable_arr(tAllItem, "name", tItem_bank)
  if #tAllItem > 0 then
    while true do
      if ShangHui_CheckSearchPage() then
        for i = 1, #tAllItem do
          local tmp = tAllItem[i]
          if tmp.name and tmp.name ~= "" and not tmp.query and FindTableFieldValue(tCanSellItem, "name", tmp.name) == false and FindTableFieldValue(aWithOutItem, "name", tmp.name) == false then
            local strName = HandleText_AddFuHao(tmp.name)
            if not string.find(aNotSaleItem, strName, nil, true) then
              local find = {type = 2, subtype = 1}
              if tmp.name == "御瑶盘" or tmp.name == "琉璃焰" then
                find.type = 3
                find.subtype = 10101
              elseif Bag:IsInfantEqui(tmp.name) then
                find.type = 4
                find.subtype = 10101
              end
              GetLuaValue(fmt("PlayerShop:PacketSend_Search(%d, %d, 1, \"%s\", 1)", find.type, find.subtype, tmp.name))
              Sleep(1200)
              local bOk = GetLuaValue(fmt([[
                                    local szName = '%s'
                                    setmetatable(_G, {__index = PS_ShopSearch_Env})
                                    for i = 1, 10 do
                                        local theAction = EnumAction(i - 1, "playershop_cur_page")
                                        if theAction:GetID() ~= 0 then
                                            local pName, pShopName, pShopID, pCount, pYB = PlayerShop:GetItemPSInfo(i - 1)
                                            if pName and pName == szName then 
                                                return 1
                                            end
                                        end
                                    end
                                    return 0 
                                ]], tmp.name), "b")
              if bOk then
                PushColorMsg(tmp.name .. ":可出售")
                table.insert(tCanSellItem, tmp)
              else
                PushDebugMessage(tmp.name .. ":未查询到,不出售")
              end
              tmp.query = true
            else
              tmp.query = true
            end
          else
            tmp.query = true
          end
          if false == IsWindowVisible("PS_ShopSearch") then
            break
          end
        end
      end
      local bNextQuery = false
      for i = 1, #tAllItem do
        local tmp = tAllItem[i]
        if not tmp.query then
          bNextQuery = true
          break
        end
      end
      if not bNextQuery then
        PushDebugMessage("查询可上架物品完成")
        break
      end
      Sleep(100)
      DebugStr("正在查询可上架物品")
    end
  end
  return tCanSellItem
end

local function SHCW_init_item(aItemText, aItemText_close)
  m_param.item_open = {}
  m_param.item_close = {}
  local allItem = SplitString(aItemText, " ", true)
  for i = 1, #allItem do
    local arrItem = SplitString(allItem[i], "|", true)
    local nSplit = 0
    if 2 == #arrItem then
      nSplit = tonumber(arrItem[2]) or 0
      if nSplit < 0 then
        nSplit = 0
      end
    end
    if "" ~= arrItem[1] then
      local bInsert = false
      m_param.item_open, bInsert = TableInsertTable(m_param.item_open, "name", {
        name = arrItem[1],
        split_num = nSplit
      })
      if false == bInsert then
        PushColorMsg("商会存物:名称重复 " .. arrItem[1])
      end
    else
      PushColorMsg(allItem[i] .. " 设置有误，忽略-1！")
    end
  end
  allItem = SplitString(aItemText_close, " ", true)
  for i = 1, #allItem do
    local arrItem = SplitString(allItem[i], "|", true)
    local nSplit = 0
    if 2 == #arrItem then
      nSplit = tonumber(arrItem[2]) or 0
      if nSplit < 0 then
        nSplit = 0
      end
    end
    if "" ~= arrItem[1] then
      local bInsert = false
      m_param.item_close, bInsert = TableInsertTable(m_param.item_close, "name", {
        name = arrItem[1],
        split_num = nSplit
      })
      if false == bInsert then
        PushColorMsg("打烊物品名称重复：" .. arrItem[1])
      end
    else
      PushColorMsg(allItem[i] .. " 打烊物品 设置有误，忽略-1！")
    end
  end
  PushDebugMessage("商会存物:已设置物品数量" .. #m_param.item_open + #m_param.item_close)
end

local function SHCW_Bag_isHaveItem()
  local function _TakeTempBag(atItem)
    local strItemName = Array2Text(atItem, " ", "name")
    
    strItemName = HandleText_AddFuHao(strItemName)
    TempBank2Bag(strItemName, 1)
    local tItem = atItem
    for i = 1, #tItem do
      local tmp = tItem[i]
      if tmp.name == "所有宝石" then
        TempBank2Bag("所有宝石", 1)
        Sleep(10)
      elseif tmp.name == "子女装备" then
        TempBank2Bag("子女装备", 1)
        Sleep(10)
      elseif tmp.name == "珍兽装备" then
        TempBank2Bag("珍兽装备", 1)
        Sleep(10)
      end
    end
  end
  
  local function _get_class_from_name(_aBag, _aArr)
    local tTarget = {}
    if 0 == #_aArr then
      return tTarget
    end
    for i = 1, #_aBag do
      if FindTableFieldValue(_aArr, "name", _aBag[i].class) then
        table.insert(tTarget, _aBag[i])
      end
    end
    return tTarget
  end
  
  local tAction_open = {}
  local tAction_close = {}
  for i = 1, 2 do
    tAction_open = {}
    tAction_close = {}
    local tBag = Bag:EnumUnBindItem(true)
    tAction_open = TableGetTable(tBag, m_param.item_open, "name")
    local tTeXie = Bag:GetItem_TeXie(tBag, m_param.item_open)
    tAction_open = TableInsertTable_arr(tAction_open, "name", tTeXie)
    local tClass = _get_class_from_name(tBag, m_param.item_open)
    tAction_open = TableInsertTable_arr(tAction_open, "name", tClass)
    for j = 1, #tAction_open do
      tAction_open[j].split_num = 0
    end
    for i = 1, #m_param.item_open do
      for j = 1, #tAction_open do
        if m_param.item_open[i].name == tAction_open[j].name then
          tAction_open[j].split_num = m_param.item_open[i].split_num
        end
      end
    end
    tBag = Bag:EnumUnBindItem(true)
    tAction_close = TableGetTable(tBag, m_param.item_close, "name")
    local tTeXie_close = Bag:GetItem_TeXie(tBag, m_param.item_close)
    tAction_close = TableInsertTable_arr(tAction_close, "name", tTeXie_close)
    local tClass = _get_class_from_name(tBag, m_param.item_close)
    tAction_close = TableInsertTable_arr(tAction_close, "name", tClass)
    for j = 1, #tAction_close do
      tAction_close[j].split_num = 0
    end
    for i = 1, #m_param.item_close do
      for j = 1, #tAction_close do
        if m_param.item_close[i].name == tAction_close[j].name then
          tAction_close[j].split_num = m_param.item_close[i].split_num
        end
      end
    end
    if 0 == #tAction_open or 0 == #tAction_close then
      _TakeTempBag(m_param.item_open)
      _TakeTempBag(m_param.item_close)
    else
      break
    end
  end
  return tAction_open, tAction_close
end

local function SHCW_bank_getItem()
  local bSuccess = true
  if m_param.bank_get then
    ClearBag()
    CloseWindow("PS_ShopMag")
    Bag:PackUp(-1)
    Sleep(200)
    local spacenum_0 = Bag:GetSpaceNum(0)
    local spacenum_1 = Bag:GetSpaceNum(1)
    if spacenum_0 > 0 or spacenum_1 > 0 then
      PushDebugMessage("商会存物：背包有空格,仓库取物")
      if #m_param.item_open > 0 or #m_param.item_close > 0 then
        local szItemName = Array2Text(m_param.item_open, " ", "name")
        local szItemName_close = Array2Text(m_param.item_close, " ", "name")
        szItemName = szItemName .. " " .. szItemName_close
        local nTakeCnt = Bank_GetItem(szItemName, -1, 1, 1, true)
        if 0 == nTakeCnt then
          PushDebugMessage("商会存物：仓库已经没有物品！")
          bSuccess = false
        end
      else
        PushDebugMessage("商会存物：取物名称为空！")
        bSuccess = false
      end
    else
      PushDebugMessage("商会存物：背包已满,无法从仓库取物！")
      bSuccess = false
    end
  else
    bSuccess = false
  end
  return bSuccess
end

local function SHCW_ClickBagItem(aPage, aOpenClose)
  local bAction = false
  local tAction_open, tAction_close = SHCW_Bag_isHaveItem()
  local tAction = tAction_open
  if 1 == aOpenClose then
    tAction = tAction_close
  end
  for i = 1, #tAction do
    if 0 == tAction[i].split_num or tAction[i].count <= tAction[i].split_num then
      bAction = true
      if not IsWindowVisible("PS_ShopMag") then
        break
      end
      Bag:ItemBtnClicked(tAction[i].index)
      Sleep(500)
      if 0 ~= PlayerShop_GetPageSpaceNum(aPage) then
      else
        break
      end
    end
  end
  local bSplit = false
  tAction_open, tAction_close = SHCW_Bag_isHaveItem()
  tAction = tAction_open
  if 1 == aOpenClose then
    tAction = tAction_close
  end
  local nBagBaseSpace = Bag:GetSpaceNum(0)
  if nBagBaseSpace > 0 then
    for i = 1, #tAction do
      if tAction[i].index < BAG_CAILIAO_MIN and tAction[i].split_num > 0 and tAction[i].count > tAction[i].split_num then
        bSplit = true
        SplitItem(tAction[i].index, tAction[i].split_num)
      end
    end
  end
  local nBagMatSpace = Bag:GetSpaceNum(1)
  if nBagMatSpace > 0 then
    for i = 1, #tAction do
      if tAction[i].index >= BAG_CAILIAO_MIN and tAction[i].split_num > 0 and tAction[i].count > tAction[i].split_num then
        bSplit = true
        SplitItem(tAction[i].index, tAction[i].split_num)
      end
    end
  end
  if false == bAction and false == bSplit then
    PushColorMsg("商会管理：背包已经没有空位拆分物品")
    return false
  end
  return true
end

local function SHCW_stall_open(aPage)
  local tAction_open, tAction_close = SHCW_Bag_isHaveItem()
  local nSpaceNum = PlayerShop_GetPageSpaceNum(aPage)
  local bAction = false
  while nSpaceNum > 0 and #tAction_open > 0 do
    bAction = true
    if false == SHCW_ClickBagItem(aPage, 2) then
      return false
    end
    local nSpaceNum_new = PlayerShop_GetPageSpaceNum(aPage)
    if nSpaceNum_new == nSpaceNum then
      PlayerShop_ClickPage(aPage)
      Sleep(800)
    end
    nSpaceNum = nSpaceNum_new
    tAction_open, tAction_close = SHCW_Bag_isHaveItem()
    if 0 == #tAction_open or false == IsWindowVisible("PS_ShopMag") then
      break
    end
    DebugStr("商会存物:将背包物品" .. tAction_open[1].name .. "放入开张柜台" .. aPage)
    if GetTickCount() - m_param.tick > 480000 then
      break
    end
  end
  return bAction
end

local function SHCW_stall_close(aPage)
  local tAction_open, tAction_close = SHCW_Bag_isHaveItem()
  local nSpaceNum = PlayerShop_GetPageSpaceNum(aPage)
  local bAction = false
  while nSpaceNum > 0 and #tAction_close > 0 do
    bAction = true
    if false == SHCW_ClickBagItem(aPage, 1) then
      return false
    end
    local nSpaceNum_new = PlayerShop_GetPageSpaceNum(aPage)
    if nSpaceNum_new == nSpaceNum then
      PlayerShop_ClickPage(aPage)
      Sleep(800)
    end
    nSpaceNum = nSpaceNum_new
    tAction_open, tAction_close = SHCW_Bag_isHaveItem()
    if 0 == #tAction_close or false == IsWindowVisible("PS_ShopMag") then
      break
    end
    DebugStr("商会存物:将背包物品" .. tAction_close[1].name .. "放入打烊柜台" .. aPage)
    if GetTickCount() - m_param.tick > 480000 then
      break
    end
  end
  return bAction
end

local function SHCW_Action()
  local bHave_all_space = false
  local tAction_open, tAction_close = SHCW_Bag_isHaveItem()
  if #tAction_open > 0 or #tAction_close > 0 then
    ::lbl_10::
    do
      local debugnote = ""
      local openID = SH_OpenManage(m_param.sh_ID)
      if openID > 0 then
        local nStallNum = PlayerShop_GetStallNum()
        local bHave_this_space = false
        for page = 1, nStallNum do
          PlayerShop_ClickPage(page)
          local nStall = PlayerShop_IsOpenStall(page)
          if 2 == nStall then
            if SHCW_stall_open(page) then
              bHave_this_space = true
              bHave_all_space = true
            end
          elseif 1 == nStall and SHCW_stall_close(page) then
            bHave_this_space = true
            bHave_all_space = true
          end
          tAction_open, tAction_close = SHCW_Bag_isHaveItem()
          if 0 == #tAction_open and 0 == #tAction_close or IsWindowVisible("PS_ShopMag") == false then
            break
          end
        end
        if false == bHave_this_space then
          PushColorMsg("商会ID：" .. openID .. "没有可用的空位，忽略该商会。")
          m_param.sh_ID = DeleteTableFieldValue(m_param.sh_ID, "id", {openID})
          CloseWindow("PS_ShopMag")
        end
      else
        if -2 == openID then
          PushDebugMessage("商会存物：已经没有需要管理的商会")
          bHave_all_space = false
          goto lbl_125
        end
        debugnote = ",打开管理窗口,商会ID" .. openID
      end
      tAction_open, tAction_close = SHCW_Bag_isHaveItem()
      if (0 ~= #tAction_open or 0 ~= #tAction_close) and not (GetTickCount() - m_param.tick > 480000) then
        Sleep(100)
        DebugStr("商会存物:将物品存入商会" .. debugnote)
        goto lbl_10
      end
    end
  else
    bHave_all_space = true
  end
  ::lbl_125::
  return bHave_all_space
end

function SHCW_OnStart(IDText, ItemText_open, ItemText_close, b_bank_take)
  if type(IDText) ~= "string" then
    PushDebugMessage("商会存物：商会ID名称设置错误(类型不匹配),请检查！")
    return
  end
  if type(ItemText_open) ~= "string" then
    PushDebugMessage("商会存物：物品名称设置错误(类型不匹配),请检查！")
    return
  end
  if type(ItemText_close) ~= "string" then
    PushDebugMessage("商会存物：打烊物品名称设置错误(类型不匹配),请检查！")
    return
  end
  if type(b_bank_take) ~= "boolean" then
    PushDebugMessage("商会存物：参数4类型不匹配,请检查！")
    return
  end
  m_param.sh_ID = {}
  m_param.bank_get = b_bank_take
  SHCW_init_item(ItemText_open, ItemText_close)
  m_param.sh_ID = SH_init_SHID(IDText)
  if 0 == #m_param.item_open and 0 == #m_param.item_close then
    PushDebugMessage("商会存物：未解析到正确的物品名称,请检查！")
    return
  end
  if 0 == #m_param.sh_ID then
    PushDebugMessage("商会存物：未解析到正确的商会ID,请检查！")
    return
  end
  SH_CloseWindow()
  m_param.tick = GetTickCount()
  while true do
    local tAction_open, tAction_close = SHCW_Bag_isHaveItem()
    if #tAction_open > 0 or #tAction_close > 0 then
      if false == SHCW_Action() then
        PushColorMsg("商会存物：商会内物品已满,或者背包已无法拆分物品！")
        break
      end
    elseif false == SHCW_bank_getItem() then
      PushColorMsg("商会存物：已经没有需要存放的物品")
      break
    end
    if GetTickCount() - m_param.tick > 480000 then
      PushColorMsg("商会存物：存放物品超时8分钟")
      break
    end
    Sleep(100)
    DebugStr("商会存物")
  end
  SH_CloseWindow()
end

local function SHQW_bag_item()
  local item_bag = {}
  local tBag = Bag:EnumAllObj()
  for i = 1, #m_param.item_take do
    local tmp = m_param.item_take[i]
    local nCount = Bag:GetItemCount(tmp.name, 1, 1, tBag)
    table.insert(item_bag, {
      name = tmp.name,
      count = nCount
    })
  end
  return item_bag
end

local function SHQW_init_item(aItemText)
  m_param.item_take = {}
  local allItem = SplitString(aItemText, " ", true)
  for i = 1, #allItem do
    local arrItem = SplitString(allItem[i], "|", true)
    if #arrItem > 0 then
      local num = tonumber(arrItem[2]) or 0
      local isdown = tonumber(arrItem[3]) or 0
      if #arrItem[1] > 2 then
        local bInsert = false
        m_param.item_take, bInsert = TableInsertTable(m_param.item_take, "name", {
          name = arrItem[1],
          count = num,
          down = isdown,
          complete = false
        })
        if false == bInsert then
          PushColorMsg("商会取物：名称重复 " .. arrItem[1])
        end
      else
        PushColorMsg(allItem[i] .. " 设置有误，忽略-2！")
      end
    elseif "" ~= allItem[i] then
      PushColorMsg(allItem[i] .. " 设置有误，忽略-1！")
    end
  end
  m_param.item_bag = SHQW_bag_item()
end

local function SHQW_item_refresh()
  local tBag = Bag:EnumAllObj()
  for i = #m_param.item_take, 1, -1 do
    local tNeed = m_param.item_take[i]
    if tNeed.count > 0 then
      local oldCnt = 0
      local tTemp = GetTableFieldValue(m_param.item_bag, "name", {
        tNeed.name
      })
      if #tTemp > 0 then
        oldCnt = tTemp[1].count
      end
      local nowCount = Bag:GetItemCount(tNeed.name, 1, 1, tBag)
      if nowCount - oldCnt >= tNeed.count then
        PushColorMsg(tNeed.name .. ":已取出足够数量")
        table.remove(m_param.item_take, i)
      end
    end
  end
end

local function SHQW_take_out(aPage)
  local bHave_this_item = false
  for k = 1, 20 do
    if 0 == #m_param.item_take then
      break
    end
    local tItem = PlayerShop_EnumPageObj(aPage)
    local tItem_have = TableGetTable(tItem, m_param.item_take, "name")
    for i = 1, #m_param.item_take do
      local tmp = m_param.item_take[i]
      if tmp.name == "子女装备" then
        for j = 1, #tItem do
          if Bag:IsInfantEqui(tItem[j].name) then
            tItem_have = TableInsertTable(tItem_have, "index", tItem[j])
          end
        end
        break
      end
    end
    SetTableFieldValue(tItem_have, m_param.item_take, "name", "down")
    if #tItem_have > 0 then
      for i = 1, #tItem_have do
        local tmp = tItem_have[i]
        if 1 == tmp.down or 0 == tmp.sale then
          DeleteDebugMsg("您的空间不足")
          bHave_this_item = true
          if 1 == tmp.sale then
            PlayerShop_SetSelect(tmp.index)
            PlayerShop_DownSale()
          end
          PlayerShop_SetSelect(tmp.index)
          PlayerShop_RetackItem()
          if IsInDebugMsg("您的空间不足") then
            PushColorMsg("商会取物:背包已满,无法取出 " .. tmp.name)
            m_param.item_take = DeleteTableFieldValue(m_param.item_take, "name", {
              tmp.name
            })
          end
          SHQW_item_refresh()
          break
        end
      end
    else
      break
    end
  end
  return bHave_this_item
end

local function SHQW_Action()
  local bHave_all_item = false
  while true do
    local debugnote = ""
    local openID = SH_OpenManage(m_param.sh_ID)
    if openID > 0 then
      local nStallNum = PlayerShop_GetStallNum()
      local bHave_this_item = false
      for page = 1, nStallNum do
        if 0 == #m_param.item_take then
          break
        end
        PlayerShop_ClickPage(page)
        local bTake = SHQW_take_out(page)
        if bTake then
          bHave_this_item = true
          bHave_all_item = true
        end
        if IsWindowVisible("PS_ShopMag") == false then
          bHave_this_item = true
          break
        end
      end
      if false == bHave_this_item then
        PushColorMsg("商会ID：" .. openID .. "没有可取物品，忽略该商会。")
        m_param.sh_ID = DeleteTableFieldValue(m_param.sh_ID, "id", {openID})
        CloseWindow("PS_ShopMag")
      end
    else
      if -2 == openID then
        PushColorMsg("商会取物：已经没有可用的商会ID")
        bHave_all_item = false
        break
      end
      debugnote = ",打开管理窗口,商会ID" .. openID
    end
    if 0 == #m_param.item_take or GetTickCount() - m_param.tick > 300000 then
      break
    end
    Sleep(100)
    DebugStr("商会取物:取出物品" .. debugnote)
  end
  return bHave_all_item
end

function SHQW_OnStart(IDText, ItemText)
  if type(IDText) ~= "string" then
    PushDebugMessage("商会取物：商会ID名称设置错误(类型不匹配),请检查！")
    return
  end
  if type(ItemText) ~= "string" then
    PushDebugMessage("商会取物：物品名称设置错误(类型不匹配),请检查！")
    return
  end
  m_param.sh_ID = SH_init_SHID(IDText)
  SHQW_init_item(ItemText)
  if 0 == #m_param.item_take then
    PushDebugMessage("商会取物：未解析到正确的物品名称,请检查！")
    return
  end
  if 0 == #m_param.sh_ID then
    PushDebugMessage("商会取物：未解析到正确的商会ID,请检查！")
    return
  end
  SH_CloseWindow()
  GoToSceneNPC("乔复盛", 330, 299, LUOYANG_ID)
  ChangeSceneLine(true)
  m_param.tick = GetTickCount()
  while false ~= SHQW_Action() do
    if GetTickCount() - m_param.tick > 300000 then
      PushColorMsg("商会取物：超时5分钟")
      break
    end
    if 0 == #m_param.item_take then
      PushColorMsg("商会取物：已经没有需要取出的物品！")
      break
    end
    Sleep(100)
    DebugStr("商会取物")
  end
  SH_CloseWindow()
end

function SJSG_GetItem()
  local allItem = {}
  local arrInfo = GetConfigListCtrlEx("摆摊收购", "收购列表", 4)
  for i = 1, #arrInfo do
    local strInfo = arrInfo[i]
    local strName = strInfo[1]
    local strJB = strInfo[2]
    local strYB = strInfo[3]
    local strCount = strInfo[4]
    local nJB = tonumber(strJB) or 0
    local nYB = tonumber(strYB) or 0
    local nCount = tonumber(strCount) or 0
    if #strName > 0 and #strName < 20 and (nJB > 0 or nYB > 0) and nCount > 0 then
      TableInsertTable(allItem, "name", {
        name = strName,
        jinbi = nJB,
        yuanbao = nYB,
        count = nCount,
        buyCount = 0,
        oldCount = 0
      })
    end
  end
  return allItem
end

function SJSG_TakeMoney(aMust)
  if aMust or IsInDebugMsg("金钱不") then
    PushDebugMessage("收购：需要取出金币")
    Bank_GetMoney(m_sg_param.qjsl * 10000)
    if m_sg_param.shqq then
      ShangHui_GetMoney(m_sg_param.qjsl * 10000)
    end
    DeleteDebugMsg("金钱不")
    CloseAllWindow()
  end
end

function SJSG_CheckBag()
  local bOK = true
  if m_sg_param.full_daoju then
    if Bag:GetSpaceNum(0) <= m_sg_param.min_space_daoju then
      PushColorMsg("收购：道具栏空格不足,执行设置脚本！")
      ScriptExecScript(m_sg_param.runScript)
      Sleep(3000)
    end
    if Bag:GetSpaceNum(0) <= m_sg_param.min_space_daoju then
      bOK = false
    end
  end
  if m_sg_param.full_cailiao then
    if Bag:GetSpaceNum(1) <= m_sg_param.min_space_cailiao then
      PushColorMsg("收购：材料栏空格不足,执行设置脚本！")
      ScriptExecScript(m_sg_param.runScript)
      Sleep(3000)
    end
    if Bag:GetSpaceNum(1) <= m_sg_param.min_space_cailiao then
      bOK = false
    end
  end
  return bOK
end

function SJSG_SaoShangHui(aItem)
  local bBuy = false
  while true do
    local bSuccess = false
    for i = 1, #aItem do
      local tmp = aItem[i]
      tmp.oldCount = Bag:GetItemCount(tmp.name, 1, 1)
    end
    for i = 1, #aItem do
      local tmp = aItem[i]
      local needCount = tmp.count - tmp.buyCount
      if tmp.jinbi > 0 and needCount > 0 then
        bBuy = true
        local bOldMoney = Player:GetMoney()
        local buyCount = ShangHui_BuyItem(tmp.name, needCount, tmp.jinbi, 1)
        for j = 1, 10 do
          if not (buyCount > 0) then
            break
          end
          Sleep(600)
          do
            local nowMoney = Player:GetMoney()
            if nowMoney == bOldMoney then
              break
            end
            bOldMoney = nowMoney
            local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
            if tmp.buyCount + nowCount - tmp.oldCount >= tmp.count then
              PushDebugMessage("扫商会： %s 已购买足够数量", tmp.name)
              break
            end
            needCount = tmp.count - tmp.buyCount - (nowCount - tmp.oldCount)
            if needCount > 0 then
              buyCount = ShangHui_BuyItem(tmp.name, needCount, tmp.jinbi, 1)
              goto lbl_95
              break
            end
          end
          ::lbl_95::
        end
      end
      SJSG_CheckBag()
      SJSG_TakeMoney()
    end
    for i = 1, #aItem do
      local tmp = aItem[i]
      local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
      if nowCount ~= tmp.oldCount then
        bSuccess = true
      end
      tmp.buyCount = tmp.buyCount + nowCount - tmp.oldCount
    end
    if not bSuccess then
      break
    end
    Sleep(100)
    DebugStr("扫商会中")
  end
  return bBuy, aItem
end

function SJSG_SaoQianZhuang(aItem)
  local bBuy = false
  for i = 1, #aItem do
    local tmp = aItem[i]
    tmp.oldCount = Bag:GetItemCount(tmp.name, 1, 1)
  end
  for i = 1, #aItem do
    local tmp = aItem[i]
    local needCount = tmp.count - tmp.buyCount
    if tmp.yuanbao > 0 and needCount > 0 then
      bBuy = true
      local bOldMoney = Player:GetDataInt("YUANBAO")
      local buyCount = QZ_BuyItem(tmp.name, needCount, tmp.yuanbao)
      for j = 1, 10 do
        if not (buyCount > 0) then
          break
        end
        Sleep(600)
        do
          local nowMoney = Player:GetDataInt("YUANBAO")
          if nowMoney == bOldMoney then
            break
          end
          bOldMoney = nowMoney
          local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
          if tmp.buyCount + nowCount - tmp.oldCount >= tmp.count then
            PushDebugMessage("扫钱庄： %s 已购买足够数量", tmp.name)
            break
          end
          needCount = tmp.count - tmp.buyCount - (nowCount - tmp.oldCount)
          if needCount > 0 then
            buyCount = QZ_BuyItem(tmp.name, needCount, tmp.yuanbao)
            goto lbl_94
            break
          end
        end
        ::lbl_94::
      end
    end
    SJSG_CheckBag()
  end
  for i = 1, #aItem do
    local tmp = aItem[i]
    local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
    tmp.buyCount = tmp.buyCount + nowCount - tmp.oldCount
  end
  return bBuy, aItem
end

function DT_GetBuyInfo(aIndex)
  local name, money, num = GetLuaValue(fmt([[
                local nIndex = %d
                setmetatable(_G, {__index = StallBuy_Env}) 
                if this:IsVisible() then    
                    local theAction = EnumAction(nIndex, "st_other");
                    if theAction:GetID() ~= 0 then
                        local nMoney = StallBuy:GetPrice("item",nIndex)
                        return theAction:GetName(), nMoney, theAction:GetNum()
                    end
                end
                return "", 0, 0
            ]], aIndex), "snn")
  return name, money, num
end

function DT_Buy(aIndex, aPrice)
  GetLuaValue(fmt([[
                setmetatable(_G, {__index = StallBuy_Env}) 
                if this:IsVisible() then 
                    StallBuy_Item%d:DoAction();
                end
            ]], aIndex + 1))
  Sleep(400)
  GetLuaValue(fmt([[
            setmetatable(_G, {__index = StallBuy_Env}) 
            if this:IsVisible() then   
                local nIndex = %d
                local nPrice = %d 
                local curPrice = StallBuy:GetPrice("item", nIndex);
                if curPrice == nPrice then 
                    StallBuy_Buy_Clicked();
                end
            end
        ]], aIndex, aPrice))
  Sleep(300)
  GetLuaValue("setmetatable(_G, {__index = MessageBoxCommon_Env});if this:IsVisible() then MessageBoxCommon_Ok_Clicked() end")
  Sleep(800)
end

function DT_StallBuy(aX, aY, aDiTanID, aSceneID)
  CloseWindow("StallBuy")
  MoveTo(aX, aY, aSceneID, 5)
  Sleep(500)
  OpenDitan(aDiTanID)
  Sleep(600)
  PlayerStateTimeOut(2, 5)
  if not IsWindowVisible("StallBuy") then
    PushDebugMessage("超过5秒未打开摊位！")
    return true
  end
  GetLuaValue("setmetatable(_G, {__index = StallBuy_Env});if this:IsVisible() then StallBuy_ChangeTabIndex(1) end;")
  Sleep(300)
  local stallType = GetLuaValue("return StallBuy:GetStallType();", "n")
  for i = 1, #m_sg_param.list_item do
    local tmp = m_sg_param.list_item[i]
    tmp.oldCount = Bag:GetItemCount(tmp.name, 1, 1)
  end
  local nowMoney = Player:GetMoney()
  local nowYuanBao = Player:GetDataInt("YUANBAO")
  for i = 0, 19 do
    local szName, nMoney, nNum = DT_GetBuyInfo(i)
    if nNum > 0 then
      local tBuy = GetTableFieldValue(m_sg_param.list_item, "name", {szName})
      if #tBuy > 0 then
        local tmp = tBuy[1]
        local needCount = tmp.count - tmp.buyCount
        if needCount > 0 then
          local isBuy = false
          if 0 == stallType then
            if tmp.jinbi > 0 and tmp.jinbi >= nMoney / nNum then
              isBuy = true
            end
          elseif 1 == stallType and tmp.yuanbao > 0 and tmp.yuanbao >= nMoney / nNum and nowYuanBao >= nMoney then
            isBuy = true
          end
          if isBuy then
            local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
            if tmp.buyCount + nowCount - tmp.oldCount >= tmp.count then
              PushDebugMessage("扫地摊： %s 已购买足够数量", tmp.name)
            else
              DT_Buy(i, nMoney)
            end
          end
        end
      end
    end
  end
  for i = 1, #m_sg_param.list_item do
    local tmp = m_sg_param.list_item[i]
    local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
    tmp.buyCount = tmp.buyCount + nowCount - tmp.oldCount
  end
  CloseWindow("StallBuy")
  return true
end

function SJSG_DT_FindObject()
  local nSceneID = GetSceneID()
  local tObj = Enum2XByClass("玩家")
  local tPlayer = ObjFilterByInt(tObj, 10, 0, "state")
  tPlayer = DeleteTableFieldValue(tPlayer, "id", m_sg_data.buyid_list)
  if 0 == #tPlayer then
    return true
  end
  while #tPlayer > 0 do
    GetAllPosDist(tPlayer)
    BubbleByDst(tPlayer, 1)
    local tmp = tPlayer[1]
    table.insert(m_sg_data.buyid_list, tmp.id)
    PushDebugMessage("扫摊收购：正在扫[%s]的摊位，本轮已扫[%d]个摊位", tmp.name, #m_sg_data.buyid_list)
    RunTo(tmp.x, tmp.y, 0, 500)
    if DT_StallBuy(tmp.x, tmp.y, tmp.id, nSceneID) == false then
      return false
    end
    if GetSceneID() ~= 224 then
      SJSG_TakeMoney()
    end
    table.remove(tPlayer, 1)
  end
  return true
end

function SJSG_DiTan_Action(aSceneID, aLuXian)
  if 0 == #aLuXian then
    return
  end
  m_sg_data.buyid_list = {}
  if GetSceneID() ~= aSceneID then
    GoToScene(aLuXian[1].x, aLuXian[1].y, aSceneID)
    ChangeSceneLine(true)
  end
  
  local function _cb(_aX, _aY, _aSceneID)
    if SJSG_DT_FindObject() == false then
    end
    return MoveCallBack_Default(_aX, _aY, _aSceneID)
  end
  
  for i = 1, #aLuXian do
    local tmp = aLuXian[i]
    MoveTo(tmp.x, tmp.y, aSceneID, nil, nil, nil, _cb)
    ChangeSceneLine(true)
    SJSG_CheckBag()
    if 224 ~= aSceneID then
      SJSG_TakeMoney()
    end
  end
end

function SJSG_Action(aParam, aScriptName)
  m_sg_param = aParam
  m_sg_data = {}
  m_sg_param.list_item = SJSG_GetItem()
  if 0 == #m_sg_param.list_item then
    PushColorMsg(aScriptName .. ":未解析到正确的物品")
    return
  end
  local tickOut = GetTickCount()
  if m_sg_param.ssh or m_sg_param.sdt then
    Bank_GetMoney(m_sg_param.qjsl * 10000)
  end
  while true do
    if m_sg_param.ssh then
      SJSG_SaoShangHui(m_sg_param.list_item)
    end
    if m_sg_param.sdt then
      if m_sg_param.dt_ly then
        SJSG_DiTan_Action(LUOYANG_ID, m_sg_param.luxian_ly)
      end
      if m_sg_param.dt_sz then
        SJSG_DiTan_Action(1, m_sg_param.luxian_sz)
      end
    end
    if m_sg_param.sqz then
      SJSG_SaoQianZhuang(m_sg_param.list_item)
      if m_sg_param.dt_qz then
        SJSG_DiTan_Action(224, m_sg_param.luxian_qz)
      end
    end
    Sleep(500)
    DebugStr(aScriptName)
    local bHave = false
    for i = 1, #m_sg_param.list_item do
      local tmp = m_sg_param.list_item[i]
      if tmp.buyCount < tmp.count then
        bHave = true
        break
      end
    end
    if false == bHave then
      PushColorMsg(aScriptName .. ":收购完成")
      break
    end
    if false == SJSG_CheckBag() then
      PushColorMsg(aScriptName .. ":背包已满")
      break
    end
    if Player:GetMoney() + Bank_GetBankMoney() < m_sg_param.min_jinbi then
      PushColorMsg(aScriptName .. ":金币不足")
      break
    end
    if GetTickCount() - tickOut > m_sg_param.max_time * 60 * 1000 then
      PushColorMsg(aScriptName .. ":已到达结束时间")
      break
    end
  end
  Bank_SaveMoney(0)
  if m_sg_param.full_daoju or m_sg_param.full_cailiao then
    ScriptExecScript(m_sg_param.runScript, aScriptName)
  end
  m_sg_param = nil
  m_sg_data = nil
end

local function HHSG_CalcJB()
  local nPrice = 0
  local nPrice_yb = 0
  local hasOtherItem = false
  local hasLimit = false
  
  local function HHSG_GetItemInfo(_aItem)
    local tItem = GetTableFieldValue(m_sg_param.list_item, "name", {
      _aItem.name
    })
    if #tItem > 0 then
      return tItem[1]
    end
    return nil
  end
  
  local tYBP = Bag:EnumJiaoYiOtherItem()
  if #tYBP > 0 then
    for i = 1, #tYBP do
      local price = 0
      local price_yb = 0
      local tmp = tYBP[i]
      local info = HHSG_GetItemInfo(tmp)
      if info then
        if info.buyCount + tmp.count > info.count then
          hasLimit = true
        end
        if info.jinbi > 0 then
          price = info.jinbi * tmp.count
        elseif info.yuanbao > 0 then
          if m_sg_param.sceneID ~= 224 then
            PushColorMsg("非钱庄地图不收购元宝物品")
          else
            price_yb = info.yuanbao * tmp.count
          end
        end
      else
        hasOtherItem = true
      end
      nPrice = nPrice + price
      nPrice_yb = nPrice_yb + price_yb
    end
  end
  if hasOtherItem then
    PushColorMsg("对方放入了非收购物品")
  end
  if hasLimit then
    PushColorMsg("对方放入物品数量超出限制")
  end
  return math.floor(nPrice), math.floor(nPrice_yb), hasOtherItem, hasLimit
end

function HHSG_Action(aParam, aScriptName)
  m_sg_param = aParam
  m_sg_param.list_item = SJSG_GetItem()
  local tSGItem = {}
  for i = 1, #m_sg_param.list_item do
    if m_sg_param.list_item[i].jinbi > 0 or m_sg_param.list_item[i].yuanbao > 0 then
      table.insert(tSGItem, m_sg_param.list_item[i])
    end
  end
  m_sg_param.list_item = tSGItem
  if 0 == #m_sg_param.list_item then
    PushColorMsg(aScriptName .. ":未解析到正确的物品")
    return
  end
  
  local function HHSG_CheckSelfJYItem()
    local tItem = Bag:EnumJiaoYiSelfItem()
    if #tItem > 0 then
      return true
    end
    return false
  end
  
  local tickTalkNear = -1
  
  local function HHSG_AutoTalk()
    if m_sg_param.is_talk_near and GetTickCount() - tickTalkNear > 8000 then
      TalkChatMsg("near", m_sg_param.talk_msg)
      tickTalkNear = GetTickCount()
    end
    if m_sg_param.is_talk_scene then
      SendTalkChatMsg("scene", m_sg_param.talk_msg, 180)
    end
  end
  
  local tickOut = GetTickCount()
  Bank_GetMoney(m_sg_param.qjsl * 10000)
  while true do
    if IsWindowVisible("Exchange") then
      local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
      if Exchange_IsHeiMingDan(otherName) == false then
        local oldMoney = Player:GetMoney(1)
        local oldYuanBao = Player:GetDataInt("YUANBAO")
        local bInvalid = false
        for i = 1, #m_sg_param.list_item do
          local tmp = m_sg_param.list_item[i]
          tmp.oldCount = Bag:GetItemCount(tmp.name, 1, 1)
        end
        local nStartTick = GetTickCount()
        while IsWindowVisible("Exchange") do
          if GetTickCount() - nStartTick > 60000 then
            PushColorMsg("%s:交易超时", otherName)
            CloseWindow("Exchange")
            bInvalid = true
            break
          end
          if Exchange_IsLocked("other") and Exchange_IsLocked("self") then
            local needJB, needYB, hasOther1, hasLimit = HHSG_CalcJB()
            local selfYB, hasOther2 = Exchange_CalcSelfYB()
            if hasOther1 or hasLimit then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if 0 == needYB then
              local hasOther = HHSG_CheckSelfJYItem()
              if hasOther then
                CloseWindow("Exchange")
                bInvalid = true
                break
              end
            elseif hasOther2 then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            local nSelfMoney = Exchange_GetMoney("self")
            if needJB ~= nSelfMoney or needYB ~= selfYB then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if not Exchange_IsLocked("other") or not Exchange_IsLocked("self") then
              CloseWindow("Exchange")
              bInvalid = true
              break
            else
              GetLuaValue("Exchange:AcceptExchange()")
              Sleep(500)
              local nTick1 = GetTickCount()
              while IsWindowVisible("Exchange") and Exchange_IsLocked("other") and Exchange_IsLocked("self") do
                Sleep(500)
                if GetTickCount() - nTick1 > 8000 then
                  PushDebugMessage("对方超过8秒没有确定交易！")
                  CloseWindow("Exchange")
                  break
                end
              end
            end
          elseif Exchange_IsLocked("other") then
            Sleep(1000)
            Exchange_LockExchange()
            Sleep(1500)
          elseif Exchange_IsLocked("self") then
            CloseWindow("Exchange")
            bInvalid = true
            break
          else
            local needJB, needYB, hasOther1, hasLimit = HHSG_CalcJB()
            local selfYB, hasOther2 = Exchange_CalcSelfYB()
            if hasOther1 or hasLimit then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if 0 == needYB then
              local hasOther = HHSG_CheckSelfJYItem()
              if hasOther then
                CloseWindow("Exchange")
                bInvalid = true
                break
              end
            elseif hasOther2 then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if Exchange_GetMoney("self") ~= needJB then
              if needJB > Player:GetMoney() then
                PushColorMsg("金币不足,取消交易")
                TalkSendPrivateMsg(otherName, "身上金币不足,请尝试减少数量！")
                CloseWindow("Exchange")
                SJSG_TakeMoney(true)
                break
              else
                PushColorMsg("需要 %s 金币 ", needJB / 10000)
                Exchange_InputMoney(needJB)
                Sleep(500)
              end
            end
            if needYB ~= selfYB then
              if 0 == selfYB and needYB <= Player:GetDataInt("YUANBAO") then
                PushColorMsg("需要 %s 元宝", needYB)
                Player:YuanBaoToTicket(needYB)
                Sleep(500)
                local tBag = Bag:FindItemInfo("元宝票")
                for i = 1, #tBag do
                  local tmp = tBag[i]
                  if tmp.ybpValue == needYB then
                    Bag:ItemBtnClicked(tmp.index)
                    break
                  end
                end
                Sleep(400)
              elseif needYB > Player:GetDataInt("YUANBAO") then
                PushColorMsg("元宝不足,取消交易")
                TalkSendPrivateMsg(otherName, "身上元宝不足,请尝试减少数量！")
                CloseWindow("Exchange")
                bInvalid = true
                break
              else
                PushColorMsg("对方已经修改了物品,取下元宝重新计算")
                local strText = "                                        local SELF_BUTTON = {\n                                            function() setmetatable(_G, {__index = Exchange_Env});Self_Exchange_Item1:DoAction() end,\n                                            function() setmetatable(_G, {__index = Exchange_Env});Self_Exchange_Item2:DoAction() end,\n                                            function() setmetatable(_G, {__index = Exchange_Env});Self_Exchange_Item3:DoAction() end,\n                                            function() setmetatable(_G, {__index = Exchange_Env});Self_Exchange_Item4:DoAction() end,\n                                            function() setmetatable(_G, {__index = Exchange_Env});Self_Exchange_Item5:DoAction() end                                         \n                                        }\n                                        local bTake = 0\n                                        for i = 0, 4 do\n                                            local theAction = EnumAction(i, \"ex_self\")\n                                            if theAction:GetID() ~= 0 then\n                                                meTestMsg(\"交易：取下\" .. i + 1)\n                                                SELF_BUTTON[i + 1]()\n                                                bTake = 1\n                                                break\n                                            end\n                                        end\n                                        return bTake\n                                    "
                for i = 1, 5 do
                  local bTake = GetLuaValue(strText, "b")
                  if not bTake then
                    break
                  end
                  Sleep(600)
                end
              end
            end
          end
          Sleep(500)
          DebugStr("与 %s 交易中", nil, otherName)
        end
        for i = 1, #m_sg_param.list_item do
          local tmp = m_sg_param.list_item[i]
          local nowCount = Bag:GetItemCount(tmp.name, 1, 1)
          tmp.buyCount = tmp.buyCount + nowCount - tmp.oldCount
        end
        local tYBP = Bag:FindItemInfo("元宝票", nil, nil)
        local nowYuanBao = Player:GetDataInt("YUANBAO") + TableFieldCount(tYBP, "ybpValue")
        if Player:GetMoney() ~= oldMoney or nowYuanBao ~= oldYuanBao then
          PushDebugMessage(fmt("交易成功！本次交易共花费 %d 铜,%d 元宝", oldMoney - Player:GetMoney(), oldYuanBao - nowYuanBao))
        end
        for i = 1, 50 do
          if false == Bag:UseItemByName("元宝票", 2000) then
            break
          end
        end
      else
        PushColorMsg("%s:玩家在黑名单中,拒绝交易", otherName)
        CloseWindow("Exchange")
      end
    elseif Exchange_IsInList() then
      Bag:UseItemByName("元宝票", 500)
      GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env});MainMenuBar_Exchange_Clicked();")
      Sleep(800)
    else
      Bag:UseItemByName("元宝票", 500)
      if m_sg_param.sceneID >= 0 and m_sg_param.x > 0 and m_sg_param.y > 0 then
        GoToScene(m_sg_param.x, m_sg_param.y, m_sg_param.sceneID)
        ChangeSceneLine(true)
      end
    end
    HHSG_AutoTalk()
    Sleep(1000)
    DebugStr(aScriptName)
    local bHave = false
    for i = 1, #m_sg_param.list_item do
      local tmp = m_sg_param.list_item[i]
      if tmp.buyCount < tmp.count then
        bHave = true
        break
      end
    end
    if false == bHave then
      PushColorMsg(aScriptName .. ":收购完成")
      break
    end
    if false == SJSG_CheckBag() then
      PushColorMsg(aScriptName .. ":背包已满")
      break
    end
    if Player:GetMoney() + Bank_GetBankMoney() < m_sg_param.min_jinbi then
      PushColorMsg(aScriptName .. ":金币不足")
      break
    end
    if GetTickCount() - tickOut > m_sg_param.max_time * 60 * 1000 then
      PushColorMsg(aScriptName .. ":已到达结束时间")
      break
    end
  end
  Bank_SaveMoney(0)
  if m_sg_param.full_daoju or m_sg_param.full_cailiao then
    ScriptExecScript(m_sg_param.runScript, aScriptName)
  end
  m_sg_param = nil
end

function JSSJ_GetItem(aScene)
  local list_item = {}
  
  local function _GetModePrice(aStrMode)
    local nMode = 0
    local nGDPrice = 0
    if "市场均价" == aStrMode then
      nMode = 1
    elseif "市场底价" == aStrMode then
      nMode = 2
    elseif "通用定价" == aStrMode then
      if 1 == g_config["寄售上架"]["通用定价"].sel then
        nMode = 2
      else
        nMode = 1
      end
    else
      local strGuDing = string.gsub(aStrMode, "YB", "")
      nGDPrice = tonumber(strGuDing) or 0
      if nGDPrice > 0 then
        nMode = 3
      end
    end
    return nMode, nGDPrice
  end
  
  local arrList = g_config["寄售上架"]["物品列表"]
  for i = 1, #arrList do
    local strInfo = arrList[i]
    if 5 == #strInfo then
      local strName = strInfo[1]
      local strMode = strInfo[2]
      local strMinYB = strInfo[3]
      local strSplit = strInfo[4]
      local strScene = strInfo[5]
      if "凤鸣镇" == strScene then
        strScene = "天外"
      end
      if strScene == aScene then
        local nSplit = tonumber(strSplit) or 0
        if nSplit < 0 then
          nSplit = 0
        end
        local minSingle = tonumber(strMinYB) or 0
        if minSingle < 0 then
          minSingle = 0
        end
        local nMode, nGDPrice = _GetModePrice(strMode)
        if 0 ~= nMode and (3 ~= nMode or nGDPrice > 0) then
          TableInsertTable(list_item, "name", {
            name = strName,
            price_mode = nMode,
            price_query_single = 0,
            price_min_single = minSingle,
            price_gd_single = nGDPrice,
            split_num = nSplit
          })
        else
          PushColorMsg("寄售上架：" .. strName .. " 价格设置有误")
        end
      end
    end
  end
  return list_item
end
