-- 反编译自 dfz64.dll 内嵌字节码 00475d8d（unluac 2025-12-23；仅供分析）
local m_script_name = "购买玲珑阁物品"
ScriptOnStart(m_script_name)

function llg_itemName()
  local g_Cur_ShopList = DataPool:LuaFnGetChongLouShopByLv(1)
  local g_nTotalNum = table.getn(g_Cur_ShopList)
  local name = ""
  for i = 1, g_nTotalNum do
    if "" == name then
      name = g_Cur_ShopList[i].name
    else
      name = name .. " " .. g_Cur_ShopList[i].name
    end
  end
  g_Cur_ShopList = DataPool:LuaFnGetChongLouShopByLv(2)
  g_nTotalNum = table.getn(g_Cur_ShopList)
  for i = 1, g_nTotalNum do
    if "" == name then
      name = g_Cur_ShopList[i].name
    else
      name = name .. " " .. g_Cur_ShopList[i].name
    end
  end
  return name
end

local function llg_GetDaiBi()
  local strText = [[
            local strText1 = ""
            local strText2 = ""
            setmetatable(_G, {__index = ChongLou_DaibiShop_Env})
            if this:IsVisible() then
                strText1 = ChongLou_DaibiShop_Text2:GetText()
                strText2 = ChongLou_DaibiShop_Text1:GetText()
            end
            return strText1,strText2
    ]]
  local strText1, strText2 = GetLuaValue(strText, "ss")
  local _, _, daibi1 = string.find(strText1, "拥有玲珑华璧：(%d+)")
  local _, _, daibi2 = string.find(strText2, "拥有玲珑白玉：(%d+)")
  daibi1 = tonumber(daibi1) or -1
  daibi2 = tonumber(daibi2) or -1
  return daibi1, daibi2
end

local function llg_mbuy(aItemName, aDaibi1, aDaibi2, aBuyCount)
  local strText = fmt("            local itemName = \"%s\"\n            local money1 = %d\n            local money2 = %d\n            local nBuy = %d\n            local g_Cur_ShopList = DataPool:LuaFnGetChongLouShopByLv(1)\n            local g_nTotalNum = table.getn(g_Cur_ShopList)\n            for i = 1, g_nTotalNum do\n                local tmp = g_Cur_ShopList[i]\n                if tmp.name == itemName then\n                    if tmp.time_type == 0 and nBuy <= 0 then\n                        return 1\n                    end\n                    local canBuy = math.floor(money1 / tmp.price)\n                    if tmp.count > 0 and tmp.count < canBuy then\n                        canBuy = tmp.count\n                    end\n                    if nBuy > 0 and nBuy < canBuy then\n                        canBuy = nBuy\n                    end\n                \n                    if canBuy > 0 then\n                        Clear_XSCRIPT()\n                        Set_XSCRIPT_ScriptID(888431)\n                        Set_XSCRIPT_Function_Name(\"MBuyConfirm\")\n                        Set_XSCRIPT_Parameter(0, 40)\n                        Set_XSCRIPT_Parameter(1, tmp.id)\n                        Set_XSCRIPT_Parameter(2, canBuy)\n                        Set_XSCRIPT_ParamCount(3)\n                        Send_XSCRIPT()\n                        meTestMsg(\"购买：\" .. itemName .. canBuy .. \"个\")\n                        return 0\n                    else\n                        return 2\n                    end\n                end\n            end\n        \n            g_Cur_ShopList = DataPool:LuaFnGetChongLouShopByLv(2)\n            g_nTotalNum = table.getn(g_Cur_ShopList)\n            for i = 1, g_nTotalNum do\n                local tmp = g_Cur_ShopList[i]\n                if tmp.name == itemName then\n                    if tmp.time_type == 0 and nBuy <= 0 then\n                        return 1\n                    end\n                    local canBuy = math.floor(money2 / tmp.price)\n                    if tmp.count > 0 and tmp.count < canBuy then\n                        canBuy = tmp.count\n                    end\n                    if nBuy > 0 and nBuy < canBuy then\n                        canBuy = nBuy\n                    end\n                \n                    if canBuy > 0 then\n                        Clear_XSCRIPT()\n                        Set_XSCRIPT_ScriptID(888431)\n                        Set_XSCRIPT_Function_Name(\"MBuyConfirm\")\n                        Set_XSCRIPT_Parameter(0, 40)\n                        Set_XSCRIPT_Parameter(1, tmp.id)\n                        Set_XSCRIPT_Parameter(2, canBuy)\n                        Set_XSCRIPT_ParamCount(3)\n                        Send_XSCRIPT()\n                        meTestMsg(\"购买：\" .. itemName .. canBuy .. \"个\")\n                        return 0\n                    else\n                        return 2\n                    end\n                end\n            end\n            return 3\n    ", aItemName, aDaibi1, aDaibi2, aBuyCount)
  return GetLuaValue(strText, "n")
end

function _SMain(...)
  CloseAllWindow()
  local buyItemName = HandleText_AddFuHao(GetConfigText("玲珑阁购物", "物品名称"))
  local buyTable = {}
  local buyArr = SplitString(buyItemName, " ", true)
  for i = 1, #buyArr do
    local buyCount = -1
    local itemName = buyArr[i]
    if string.find(itemName, "*", nil, true) then
      local _, _, strCount = string.find(itemName, "%*(%d+)")
      buyCount = tonumber(strCount) or 0
      _, _, itemName = string.find(itemName, "(.-)%*")
    end
    if itemName and buyCount then
      table.insert(buyTable, {
        name = itemName,
        buy_count = buyCount,
        old_count = Bag:GetItemCount(itemName)
      })
    end
  end
  local tickOut = -1
  while true do
    if not IsWindowVisible("ChongLou_DaibiShop") then
      MoveToNPC("李问禅", 106, 59, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(500)
      DialogOptionClicked("玲珑阁", 1, 800)
    end
    local daibi1, daibi2 = llg_GetDaiBi()
    if daibi1 >= 0 and daibi2 >= 0 then
      local bBuy = false
      for i = 1, #buyTable do
        local temp = buyTable[i]
        if temp.buy_count > 0 then
          local bagCount = Bag:GetItemCount(temp.name)
          local havBuy = bagCount - temp.old_count
          local needBuy = temp.buy_count - havBuy
          if needBuy >= 0 then
            temp.buy_count = needBuy
          else
            temp.buy_count = 0
          end
        end
        if 0 ~= temp.buy_count then
          local buyState = llg_mbuy(temp.name, daibi1, daibi2, temp.buy_count)
          Sleep(800)
          if 0 ~= buyState then
            temp.buy_count = 0
            if 1 == buyState then
              PushColorMsg(m_script_name .. ":非限购物品请在名称后面输入物品数量：" .. temp.name)
            elseif 3 == buyState then
              PushColorMsg(m_script_name .. ":没有此商品 " .. temp.name)
            else
              PushColorMsg("购买完成 " .. temp.name)
            end
          else
            bBuy = true
            break
          end
        end
      end
      if false == bBuy then
        PushColorMsg(m_script_name .. ":购买完成")
        break
      end
    end
    if -1 == tickOut then
      tickOut = GetTickCount()
    end
    if GetTickCount() - tickOut > 60000 then
      PushColorMsg(m_script_name("：购买超时"))
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
