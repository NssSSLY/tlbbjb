-- 反编译自 dfz64.dll 内嵌字节码 00471348（unluac 2025-12-23；仅供分析）
local m_script_name = "购买天荒商行"
ScriptOnStart(m_script_name)
g_config["天荒商行购物"] = {}
g_config["天荒商行购物"]["物品名称"] = GetConfigText("天荒商行购物", "物品名称")
g_config["天荒商行购物"]["元宝物品"] = GetConfigText("天荒商行购物", "元宝物品")
local m_param = {}
m_param.item_GB = {}
m_param.item_YB = {}

local function THSH_BuyItem(aNpcID, aItemName, aItemCount, aShowType)
  local bBuy = 0
  local strText = fmt("    local bBuy = 0 \n    local g_FengmingShop_MBuy_TargetId = %d -- npcID\n    local buyName = \"%s\"\n    local buyCount = %d\n    local nType = %d\n    \n    local idxStart = 0\n    local idxEnd = 1\n    if nType == 2 then \n        idxStart = 2\n        idxEnd = 2\n    end\n    local g_FengmingShop_CurPage = 1\n    local g_FengmingShop_PerPageCount = 15\n    \n    for shoptype = idxStart, idxEnd do\n        local tblinfo = NpcShop:GetFengMingShopData(shoptype, g_FengmingShop_CurPage, g_FengmingShop_PerPageCount)\n        if type(tblinfo) == \"table\" then\n            for i = 1, table.getn(tblinfo) do\n                local itemid = tblinfo[i].itemid\n                local itemnum = tblinfo[i].itemnum\n                local itemName = tblinfo[i].itemname\n                local daibitype = tblinfo[i].daibitype\n                local price = tblinfo[i].price\n                local limitweek = tblinfo[i].limitweek\n                local limitweek_self = tblinfo[i].limitweek_self\n                local limitpermanent = tblinfo[i].limitpermanent\n                local limitpermanent_self = tblinfo[i].limitpermanent_self\n    \n                local ndaibicount = 0\n                if daibitype == 1 then\n                    ndaibicount = NpcShop:GetFengMingShopDaiBi()\n                else\n                    ndaibicount = Player:GetData(\"YUANBAO\")\n                end\n    \n                local nislimit = 0\n                local limitnum = 0\n                if limitweek < 0 and limitpermanent < 0 then\n                    nislimit = 0\n                elseif limitweek > 0 then\n                    nislimit = 1\n                    limitnum = limitweek_self\n                elseif limitpermanent > 0 then\n                    nislimit = 1\n                    limitnum = limitpermanent_self\n                end\n    \n                local maxNum = NpcShop:FengmingShopCalcMaxNumCanBuy(itemid, itemnum, shoptype, ndaibicount, price, nislimit, limitnum, 0, 1)\n                if maxNum > 0 then\n                    -- local itemName = DataPool:Lua_GetItemNameByIndex(itemid)\n                    if buyName == itemName then\n                        bBuy = 1\n                        if buyCount > 0 or nislimit == 1 then\n                            if buyCount > 0 and buyCount < maxNum then\n                                maxNum = buyCount\n                            end\n                        else\n                            if buyCount == -1 then \n                                meTestMsg(\"非限购物品请在名称后面输入物品数量：\" .. itemName)\n                                maxNum = 0\n                            end\n                        end\n    \n                        if maxNum > 0 then\n                            meTestMsg(\"购买：\" .. itemName .. maxNum .. \"个\")\n                            Clear_XSCRIPT()\n                            Set_XSCRIPT_Function_Name(\"BuyItem\") -- 脚本函数名称\n                            Set_XSCRIPT_ScriptID(889833) -- 脚本编号\n                            Set_XSCRIPT_Parameter(0, g_FengmingShop_MBuy_TargetId)\n                            Set_XSCRIPT_Parameter(1, shoptype)\n                            Set_XSCRIPT_Parameter(2, itemid)\n                            Set_XSCRIPT_Parameter(3, maxNum)\n                            Set_XSCRIPT_Parameter(4, g_FengmingShop_CurPage)\n                            Set_XSCRIPT_ParamCount(5) -- 参数个数\n                            Send_XSCRIPT()\n                        end\n                        break\n                    end\n                end\n            end\n        end\n        if bBuy == 1 then \n            break\n        end\n    end\n    \n    return bBuy\n    ", aNpcID, aItemName, aItemCount, aShowType)
  if IsWindowVisible("FengmingShop") then
    bBuy = GetLuaValue(strText, "n")
    if 1 == bBuy then
    end
    CloseAllWindow()
  else
    bBuy = 2
  end
  return bBuy
end

function _SMain(...)
  local nTickOut = -1
  local buyItem_GB = HandleText_AddFuHao(g_config["天荒商行购物"]["物品名称"])
  local buyItem_YB = HandleText_AddFuHao(g_config["天荒商行购物"]["元宝物品"])
  ClearBag()
  CloseAllWindow()
  local arrItem = SplitString(buyItem_GB, " ")
  for i = 1, #arrItem do
    local arrStr = SplitString(arrItem[i], "*")
    if #arrStr >= 1 then
      local nCount = -1
      local strName = arrStr[1]
      if 2 == #arrStr then
        nCount = tonumber(arrStr[2]) or 0
      end
      table.insert(m_param.item_GB, {
        name = strName,
        count = nCount,
        buy = false
      })
    end
  end
  local arrItem = SplitString(buyItem_YB, " ")
  for i = 1, #arrItem do
    local arrStr = SplitString(arrItem[i], "*")
    if #arrStr >= 1 then
      local nCount = -1
      local strName = arrStr[1]
      if 2 == #arrStr then
        nCount = tonumber(arrStr[2]) or 0
      end
      table.insert(m_param.item_YB, {
        name = strName,
        count = nCount,
        buy = false
      })
    end
  end
  local npcID = -1
  while true do
    if -1 == npcID then
      GoToSceneNPC("姜临", 82, 182, 850)
      local tObj = Enum2XByName("姜临", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        npcID = tObj[1].id
      end
    end
    if not IsWindowVisible("FengmingShop") then
      GoToSceneNPC("姜临", 82, 182, 850)
      Sleep(500)
      DialogOptionClicked("天荒商行", 1, 600)
    end
    if -1 ~= npcID then
      local bBuy_GB = false
      local bBuy_YB = false
      for i = 1, #m_param.item_GB do
        if m_param.item_GB[i].buy == false then
          bBuy_GB = true
          local nBuy = THSH_BuyItem(npcID, m_param.item_GB[i].name, m_param.item_GB[i].count, 1)
          if 0 == nBuy or 1 == nBuy then
            m_param.item_GB[i].buy = true
          end
          break
        end
      end
      for i = 1, #m_param.item_YB do
        if false == m_param.item_YB[i].buy then
          bBuy_YB = true
          local nBuy = THSH_BuyItem(npcID, m_param.item_YB[i].name, m_param.item_YB[i].count, 2)
          if 0 == nBuy or 1 == nBuy then
            m_param.item_YB[i].buy = true
          end
          break
        end
      end
      if false == bBuy_GB and false == bBuy_YB then
        PushColorMsg("天荒商行：没有可购买的物品")
        break
      end
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 60000 then
      PushColorMsg("天荒商行：购买超时")
      break
    end
    Sleep(500)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
