-- 反编译自 dfz64.dll 内嵌字节码 0046d747（unluac 2025-12-23；仅供分析）
local m_script_name = "购买中都行商"
ScriptOnStart(m_script_name, false, false)
local m_param = {}
m_param.buyItem = HandleText(GetConfigText("中都行商购物", "物品名称"))

local function ZhongDu_BuyItem(aItemName, aBuyCount)
  local strText = "            local buyName = \"%s\"\n            local buyCount = %d\n            local buyState = 0\n            setmetatable(_G, {__index = T3DaibiShop_Env})\n            if this:IsVisible() then\n                buyState = 5 \n                local nHaveToken = Player:LuaFnGetT3ShopToken()\n                local nYuanbao = Player:GetData(\"YUANBAO\")\n                local nTotalNum = GetActionNum(\"t3shop\")\n                for i = 0, nTotalNum - 1 do\n                    local item_shop_index = DataPool:LuaFnGetT3ShopItemInfo(i, \"SHOPINDEX\")\n                    local theAction = EnumAction(item_shop_index, \"t3shop\")\n                    local nPrice = DataPool:LuaFnGetT3ShopItemInfo(i, \"PRICE\")\n                    if theAction:GetID() ~= 0 and nPrice > 0 then\n                        local strName = theAction:GetName()\n                        if strName == buyName then\n                            if buyState == 5 then \n                                buyState = 0\n                            end\n                            local nMaxCanBuyByMoney = 0\n                            local currency = DataPool:LuaFnGetT3ShopItemInfo(i, \"CURRENCY\")\n                            if currency == 0 then\n                                nMaxCanBuyByMoney = math.floor(nYuanbao / nPrice)\n                            else\n                                nMaxCanBuyByMoney = math.floor(nHaveToken / nPrice)\n                            end\n                        \n                            local limit_type = DataPool:LuaFnGetT3ShopItemInfo(i, \"LIMITTYPE\")\n                            local player_limit = DataPool:LuaFnGetT3ShopItemInfo(i, \"PLAYERREMAIN\")\n                            if limit_type == 1 then\n                                if player_limit < nMaxCanBuyByMoney then\n                                    nMaxCanBuyByMoney = player_limit\n                                end\n                            end\n                            if limit_type == 2 then\n                                local guild_limit = DataPool:LuaFnGetT3ShopItemInfo(i, \"GUILDREMAIN\")\n                                if player_limit < 0 then\n                                    if guild_limit < nMaxCanBuyByMoney then\n                                        nMaxCanBuyByMoney = guild_limit\n                                    end\n                                elseif player_limit < guild_limit then\n                                    if player_limit < nMaxCanBuyByMoney then\n                                        nMaxCanBuyByMoney = player_limit\n                                    end\n                                else\n                                    if guild_limit < nMaxCanBuyByMoney then\n                                        nMaxCanBuyByMoney = guild_limit\n                                    end\n                                end\n                            end\n                        \n                            meTestMsg(strName .. \":可购买数量 \" .. nMaxCanBuyByMoney)\n                            if buyCount > nMaxCanBuyByMoney then\n                                buyCount = nMaxCanBuyByMoney\n                                if buyCount <= 0 then\n                                    buyState = 3\n                                    meTestMsg(strName .. \":已无法购买\", 1)\n                                end\n                            end\n                        \n                            if buyCount > 0 then\n                                NpcShop:LuaFnT3ShopBuyItem(i, buyCount)\n                            end\n                            break\n                        end\n                    end\n                end\n            end\n            return buyState\n        "
  local buyState = GetLuaValue(fmt(strText, aItemName, aBuyCount), "n")
  return buyState
end

function _SMain(...)
  local nTickOut = -1
  ClearBag()
  CloseAllWindow()
  local buyTable = Text2Table(m_param.buyItem, " ", "name")
  for i = 1, #buyTable do
    buyTable[i].canbuy = true
  end
  if #buyTable > 0 then
    ::lbl_22::
    if FindTableFieldValue(buyTable, "canbuy", true) == false then
      PushColorMsg(m_script_name .. ":已无可购买物品")
    elseif false ~= GoToGuild() then
      if IsWindowVisible("T3DaibiShop") then
        for i = 1, #buyTable do
          local buyCount = 3
          local state = 0
          if buyTable[i].canbuy then
            state = ZhongDu_BuyItem(buyTable[i].name, buyCount)
          end
          if 3 == state then
            buyTable[i].canbuy = false
          elseif 5 == state then
            PushColorMsg(m_script_name .. "：没有此物品")
            buyTable[i].canbuy = false
          end
          Sleep(200)
        end
      else
        MoveToNPC("李问禅", 106, 59, -1, nil, nil, nil, MoveCallback_InMyGuild)
        QuestFrameOptionClicked_Item("#{SDYC_20220706_05}", 1, 700)
      end
      Sleep(400)
      if -1 == nTickOut then
        nTickOut = GetTickCount()
      end
      if -1 ~= nTickOut and GetTickCount() - nTickOut > 90000 then
        PushColorMsg(m_script_name .. "：执行超时")
      else
        DebugStr(m_script_name)
        goto lbl_22
      end
    end
  else
    PushColorMsg(m_script_name .. ":没有正确的物品名称,多个物品空格分开")
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name, false)
