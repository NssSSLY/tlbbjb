-- 反编译自 dfz64.dll 内嵌字节码 00475055（unluac 2025-12-23；仅供分析）
local m_script_name = "购买战功商品"
ScriptOnStart(m_script_name, false, false)
g_config.gmzgsp = {}
g_config.gmzgsp.buy = ReadConfigText("ZH", "bjk160")
local m_param = {}
m_param.item = {}

local function ZhanGong_butItem(aItemName, aItemCount)
  local strText = "            local bBuy = 0\n            local buyName = \"%s\"\n            local buyCount = %d\n\n            local nDuanWei = City:GetWeekDuanWei()\n            local nItemNum = City:GetHonourShopItemNum(nDuanWei)\n            for i = 1, nItemNum do\n                local idx = i - 1\n                local nRemainNum = City:GetHonourShopInfo(idx, \"remainnum\")\n                local theAction = City:EnumHonourShop(idx)\n                if nRemainNum > 0 and theAction:GetID() ~= 0 then\n                    local szName = theAction:GetName()\n                    local nMyHonour = Player:GetData(\"MILITARYEXCHANGE\")\n                    local nItemHonour = City:GetHonourShopInfo(idx, \"honour\")\n                    local nAllNeed = nItemHonour * nRemainNum\n                    local canBuyCount = nRemainNum\n                    if szName == buyName then \n                        if nAllNeed > nMyHonour then \n                            canBuyCount = math.floor(nMyHonour / nItemHonour)\n                        end\n                        if buyCount == -1 or canBuyCount < buyCount then \n                            buyCount = canBuyCount\n                        end\n                        if buyCount > 0 then\n                            meTestMsg(\"购买：\" .. szName .. buyCount .. \"个\")\n                            City:DoHonourShopBuy(idx, buyCount)\n                            bBuy = 1    \n                        end\n                        break  \n                    end\n                end\n            end    \n               \n            return bBuy\n    "
  strText = fmt(strText, aItemName, aItemCount)
  local isBuy = GetLuaValue(strText, "b")
  return isBuy
end

function _SMain(...)
  local nTickOut = -1
  local buyItem = HandleText_AddFuHao(g_config.gmzgsp.buy, " ")
  ClearBag()
  CloseAllWindow()
  local arrItem = SplitString(buyItem, " ")
  for i = 1, #arrItem do
    local arrStr = SplitString(arrItem[i], "*")
    if #arrStr >= 1 then
      local nCount = -1
      local strName = arrStr[1]
      if 2 == #arrStr then
        nCount = tonumber(arrStr[2]) or 0
      end
      table.insert(m_param.item, {
        name = strName,
        count = nCount,
        buy = false
      })
    end
  end
  while true do
    if QuestFrameOptionClicked_Item("#{JWSD_140821_3}", 1, 600) then
      if not IsWindowVisible("JueweiShop") then
        goto lbl_101
      end
      local bBuy = false
      for i = 1, #m_param.item do
        if m_param.item[i].buy == false then
          ZhanGong_butItem(m_param.item[i].name, m_param.item[i].count)
          bBuy = true
          m_param.item[i].buy = true
          break
        end
      end
      if false == bBuy then
        break
      end
    else
      if false == GoToGuild() then
        break
      end
      MoveToNPC("赵子勋", 93, 54, -1, nil, nil, nil, MoveCallback_InMyGuild)
    end
    ::lbl_101::
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    Sleep(300)
    if GetTickCount() - nTickOut > 120000 then
      PushColorMsg(m_script_name .. ":超时")
      break
    end
    Bag:PackUp(-1)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
