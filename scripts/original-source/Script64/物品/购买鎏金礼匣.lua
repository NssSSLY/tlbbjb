-- 反编译自 dfz64.dll 内嵌字节码 004795c7（unluac 2025-12-23；仅供分析）
local m_script_name = "购买鎏金礼匣"
ScriptOnStart(m_script_name, false, false)
local m_buyItem = ReadConfigText("ZH", "bjk117")

function XiaHuaLiuJinLiXia()
  local aBagItem = Bag:EnumDaoJuItem()
  Bag:UseItemByName_click("鎏金礼匣·一", 800, aBagItem)
  Bag:UseItemByName_click("鎏金礼匣·二", 800, aBagItem)
  Bag:UseItemByName_click("鎏金礼匣·三", 800, aBagItem)
  Bag:UseItemByName_click("鎏金礼匣·四", 800, aBagItem)
  Bag:UseItemByName_click("鎏金礼匣·五", 800, aBagItem)
  Bag:UseItemByName_click("鎏金礼匣·六", 800, aBagItem)
  Bag:UseItemByName_click("鎏金礼匣·七", 800, aBagItem)
  local strText = [[
            setmetatable(_G, {__index = GoldRecycle_GiftShop_Env})
            local strName1, strName2, strName3 = "", "", ""
            local strMoney1, strMoney2, strMoney3 = "", "", ""
            if this:IsVisible() then
                strName1 = GoldRecycle_GiftShop_Item1_Info:GetText()
                strName2 = GoldRecycle_GiftShop_Item2_Info:GetText()
                strName3 = GoldRecycle_GiftShop_Item3_Info:GetText()
                strMoney1 = GoldRecycle_GiftShop_Item1_Name:GetText()
                strMoney2 = GoldRecycle_GiftShop_Item2_Name:GetText()
                strMoney3 = GoldRecycle_GiftShop_Item3_Name:GetText()
            end
            return strName1,strName2 ,strName3 ,strMoney1 ,strMoney2 ,strMoney3
        ]]
  local strName1, strName2, strName3, strMoney1, strMoney2, strMoney3 = GetLuaValue(strText, "ssssss")
  strName1 = string.gsub(strName1, "?", "")
  strName2 = string.gsub(strName2, "?", "")
  strName3 = string.gsub(strName3, "?", "")
  strMoney1 = string.gsub(strMoney1, "?金币：", "")
  strMoney2 = string.gsub(strMoney2, "?金币：", "")
  strMoney3 = string.gsub(strMoney3, "?金币：", "")
  if "" ~= strName1 and "" ~= strName2 and "" ~= strName3 then
    local pos1 = string.find(m_buyItem, strName1, nil, true)
    local pos2 = string.find(m_buyItem, strName2, nil, true)
    local pos3 = string.find(m_buyItem, strName3, nil, true)
    local tab = {}
    if pos1 then
      table.insert(tab, {
        index = 1,
        npos = pos1,
        name = strName1
      })
    end
    if pos2 then
      table.insert(tab, {
        index = 2,
        npos = pos2,
        name = strName2
      })
    end
    if pos3 then
      table.insert(tab, {
        index = 3,
        npos = pos3,
        name = strName3
      })
    end
    if #tab > 0 then
      BubbleSort(tab, "npos", 1)
      local tmp = tab[1]
      PushColorMsg("购买：" .. tmp.name)
      GetLuaValue(fmt([[
                        setmetatable(_G, {__index = GoldRecycle_GiftShop_Env});
                        if this:IsVisible() then
                            GoldRecycle_GiftShop_Choose(%d)
                            GoldRecycle_GiftShop_GetClick()
                        end        
                    ]], tmp.index))
      Sleep(600)
    end
  end
  CloseWindow("GoldRecycle_GiftShop")
end

function _SMain()
  local tObj = Bag:SearchItemName("鎏金礼匣·一 鎏金礼匣·二 鎏金礼匣·三 鎏金礼匣·四 鎏金礼匣·五 鎏金礼匣·六 鎏金礼匣·七")
  if 0 == #tObj then
    PushColorMsg(m_script_name .. ":背包没有礼匣")
    return
  end
  local bGetMoney = false
  if Player:GetMoney() < 1040000 then
    Bank_GetMoney(1040000)
    Sleep(3000)
    bGetMoney = true
  end
  if Player:GetMoney() < 1040000 then
    DebugColorMsg(m_script_name .. "：携带金币不够,暂不开启", 4)
    return
  end
  CloseAllWindow()
  for i = 1, 2 do
    XiaHuaLiuJinLiXia()
    Sleep(800)
  end
  if bGetMoney then
    Bank_SaveMoney(0)
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
