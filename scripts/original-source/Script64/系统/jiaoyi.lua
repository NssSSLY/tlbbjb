-- 反编译自 dfz64.dll 内嵌字节码 00538db9（unluac 2025-12-23；仅供分析）
function Exchange_IsInList()
  return GetLuaValue("local bIs = Exchange:IsStillAnyAppInList();if bIs then return 1 else return 0 end", "b")
end

function Exchange_IsLocked(aType)
  return GetLuaValue(fmt("local bIs = Exchange:IsLocked('%s');if bIs then return 1 else return 0 end;", aType), "b")
end

function Exchange_LockExchange()
  local strText = [[
        if not Exchange:IsLocked("self") then
            if GetAuthorizedSafeFlag() == 1 then
                local isExist = Exchange:IsSendSelfToDest()
                if isExist == 1 and CheckPhoneMibaoAndMinorPassword() == 0 then
                    Exchange_Cancel()
                    return
                end
            end
            Exchange:LockExchange()
        end
    ]]
  GetLuaValue(strText)
  Sleep(500)
end

function Exchange_DeleteLockItem(aItem)
  local tExc = {}
  for i = 1, #aItem do
    local tmp = aItem[i]
    local nLocked = GetLuaValue(fmt("local theAction, bLocked, bProtect = PlayerPackage:EnumItem(\"base\", %d);return bLocked", tmp.index), "n")
    if 0 == nLocked then
      table.insert(tExc, tmp)
    end
  end
  return tExc
end

function Exchange_GetMoney(aType)
  local strMoney = GetLuaValue(fmt([[
            setmetatable(_G, {__index = Exchange_Env})
            if this:IsVisible() then
                local nMoney, nGoldCoin, nSilverCoin, nCopperCoin = Exchange:GetMoney("%s")
                return nMoney
            end
            return 0        
        ]], aType), "s")
  return math.floor(tonumber(strMoney))
end

function Exchange_InputMoney(aMoney)
  GetLuaValue(fmt([[
        setmetatable(_G, {__index = Exchange_Env})
        if this:IsVisible() then
            Exchange:GetMoneyFromInput(%s);
        end
    ]], aMoney))
end

function Exchange_IsHeiMingDan(aName)
  local file = io.open(g_public_dir .. "角色设置\\交易黑名单.txt", "r")
  if file then
    local strText = file:read("*a")
    if type(strText) == "string" and "" ~= strText then
      local allText = HandleText(strText)
      allText = string.gsub(allText, "\r", " ")
      allText = string.gsub(allText, "\n", " ")
      allText = string.gsub(allText, "  ", " ")
      allText = string.gsub(allText, "  ", " ")
      allText = HandleText_AddFuHao(allText, " ")
      local text1 = HandleText_AddFuHao(aName, " ")
      if string.find(allText, text1, nil, true) then
        return true
      end
    end
    io.close(file)
  else
  end
  return false
end

function Exchange_checkMaxMoney()
  local maxMoney = Player:GetMaxMoney() * 10000
  local nBankMoney = Bank_GetBankMoney()
  local otherMoney = Exchange_GetMoney("other")
  local bagMoney = Player:GetMoney()
  if maxMoney < nBankMoney + otherMoney + bagMoney then
    return false
  end
  return true
end

function Exchange_CalcSelfYB()
  local hasOtherItem = false
  local nPrice = 0
  local tItem = Bag:EnumJiaoYiSelfItem()
  local tYBP = Bag:FindItemInfo("元宝票", nil, nil, tItem)
  if #tYBP ~= #tItem then
    hasOtherItem = true
  end
  if #tYBP > 0 then
    nPrice = TableFieldCount(tYBP, "ybpValue")
  end
  return nPrice, hasOtherItem
end
