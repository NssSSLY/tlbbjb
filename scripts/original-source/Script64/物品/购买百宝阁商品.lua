-- 反编译自 dfz64.dll 内嵌字节码 0047764f（unluac 2025-12-23；仅供分析）
local m_script_name = "购买百宝阁商品"
ScriptOnStart(m_script_name, false, false)
g_config.gmbbg = {}
g_config.gmbbg.buy = ReadConfigText("ZH", "bjk161")
local m_param = {}
m_param.item = {}

local function BaiBaoGe_butItem(aItemName, aItemCount)
  local strText = "        local bBuy = 0\n        local buyName = \"%s\"\n        local buyCount = %d\n        local TotalCnt = City:GetGuildShopInfo(0, \"total\")\n        for i = 1, TotalCnt do\n            local idx = i\n            local theAction, isSoldOut = City:EnumGuildShop(idx)\n            if isSoldOut ~= 0 and theAction:GetID() ~= 0 then\n                local szName = theAction:GetName()\n                local nTotalMoney = Guild:GetGuildContri()\n                local contribute = City:GetGuildShopInfo(idx, \"contribute\")\n                local nRemainNum = City:GetGuildShopInfo(idx, \"MaxNumber\"); \n                local nItemTableIndex = City:GetGuildShopInfo(idx, \"itemindex\");\n                if nRemainNum > 0 then             \n                    if szName == buyName then\n                        bBuy = 1\n                        local canBuyCount = math.floor(nTotalMoney / contribute)\n                        if buyCount == -1 or canBuyCount < buyCount then \n                            buyCount = canBuyCount\n                        end\n                        if buyCount > nRemainNum then \n                            buyCount = nRemainNum\n                        end\n                    \n                        if buyCount > 0 then \n                            meTestMsg(\"购买：\" .. szName .. buyCount .. \"个\")\n                            City:DoGuildShopBuy(idx, buyCount)\n                        end\n                        break\n                    end\n                end\n            end\n        end\n\n        return bBuy\n    "
  strText = fmt(strText, aItemName, aItemCount)
  GetLuaValue(strText, "b")
end

function _SMain(...)
  local nTickOut = -1
  local buyItem = HandleText_AddFuHao(g_config.gmbbg.buy, " ")
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
  while false ~= GoToGuild() do
    if IsWindowVisible("BangHui_Shop") then
      local bBuy = false
      for i = 1, #m_param.item do
        if m_param.item[i].buy == false then
          bBuy = true
          BaiBaoGe_butItem(m_param.item[i].name, m_param.item[i].count)
          m_param.item[i].buy = true
          break
        end
      end
      if false == bBuy then
        break
      end
    else
      MoveToNPC("万藏宝", 149, 44, -1, nil, nil, nil, MoveCallback_InMyGuild)
      QuestFrameOptionClicked_Item("#{BHSC_140509_04}", 1, 500)
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 90000 then
      PushColorMsg(m_script_name .. ":购买超时")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
