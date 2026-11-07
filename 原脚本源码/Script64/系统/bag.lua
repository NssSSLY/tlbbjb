-- 反编译自 dfz64.dll 内嵌字节码 0047cbd0（unluac 2025-12-23；仅供分析）
Bag = {}
Bag = require("baglib")

function Bag:_EnumItem(aType, aWithNullObj)
  local tItem = self.EnumBagItem(aType)
  if aWithNullObj then
    return tItem
  end
  local tObj = {}
  for i = 1, #tItem do
    local tmp = tItem[i]
    if 0 ~= tmp.obj then
      table.insert(tObj, tmp)
    end
  end
  return tObj
end

function Bag:EnumAllObj(aWithNullObj)
  return self:_EnumItem(0, aWithNullObj)
end

function Bag:EnumDaoJuItem(aWithNullObj)
  return self:_EnumItem(1, aWithNullObj)
end

function Bag:EnumCailiaoItem(aWithNullObj)
  return self:_EnumItem(2, aWithNullObj)
end

function Bag:EnumRenWuItem(aWithNullObj)
  return self:_EnumItem(3, aWithNullObj)
end

function Bag:EnumDaoCaiRenItem(aWithNullObj)
  return self:_EnumItem(4, aWithNullObj)
end

function Bag:EnumTempBagItem(aWithNullObj)
  return self:_EnumItem(10, aWithNullObj)
end

function Bag:EnumBankItem(aWithNullObj)
  local tObj = self:_EnumItem(11, aWithNullObj)
  for i = 1, #tObj do
    tObj[i].boxIndex = math.floor(tObj[i].index / 20 + 1)
  end
  return tObj
end

function Bag:EnumLootItem()
  local nTotalNum = GetLuaValue("return GetActionNum('lootitem');", "n")
  return self.EnumBagItem(12, nTotalNum)
end

function Bag:EnumJiaoYiSelfItem(aWithNullObj)
  return self:_EnumItem(13, aWithNullObj)
end

function Bag:EnumJiaoYiOtherItem(aWithNullObj)
  return self:_EnumItem(14, aWithNullObj)
end

function Bag:PackUp(aTabIndex, aMust)
  if aMust or not g_config.tysz.un_packup then
    if -1 == aTabIndex then
      GetLuaValue("g_packup_time_zs = os.time(); PlayerPackage:PackUpPacket(0);")
      Sleep(100)
      GetLuaValue("g_packup_time_zs = os.time(); PlayerPackage:PackUpPacket(1);")
    else
      GetLuaValue(fmt("g_packup_time_zs = os.time(); PlayerPackage:PackUpPacket(%d);", aTabIndex))
    end
    Sleep(100)
  else
    DebugColorMsg("已设置禁止整理背包", 6)
  end
end

function Bag:PackUpTempBag(aSleep, aMust)
  if aMust or not g_config.tysz.un_packup then
    GetLuaValue("g_packup_time_zs = os.time();setmetatable(_G, {__index = Packet_Temporary_Env});Packet_Temporary_CleanButtonClk()")
    if aSleep then
      Sleep(aSleep)
    end
  else
    DebugColorMsg("已设置禁止整理锦囊", 6)
  end
end

function Bag:IsInfantEqui(aItemName)
  local szAllName = " 绛麻衣 棉僧衣 锦绸衣 绢丝衣 哭丧棒 雁翎刀 松纹剑 娥眉刺 灵鳌步 一苇渡江 草上飞 水上漂 青铜令 黄铜戒 翠玉佩 白珍珠 黄鬃马 褐鬃马 黑鬃马 云鬃马 太祖长拳 天山折梅手 大理剑诀 美女拳法 虎皮裘 鹿皮裘 貂皮裘 玄狐裘 鹿头短杖 修罗刀 真武剑 红丝绣针 壁虎游墙 踏雪无痕 金雁功 燕双飞 七杀令 玄铁戒 麒麟佩 琉璃珠 大宛 大骊 黄骠 骐骥 龙爪手 天山六阳掌 段式指法 落英剑法 百结衣 玄铁甲 御龙袍 玉女纱衣 韦陀杵 圆月弯刀 吴钩剑 银丝手套 瞬息千里 凭虚临风 扶摇直上 捕雀功 赏罚令 紫金戒 游仙佩 夜明珠 乌骓 汗血 赤兔 的卢 打狗棒法 生死符 一阳指 玉女素心剑 乌蚕衣 七宝云袍 金丝宝甲 软猬甲 打狗棒 屠龙刀 倚天剑 越女剑 神行百变 逍遥游 凌波微步 天罗地网势 圣火令 七宝扳指 和氏璧 随侯珠 绝地 越影 翻羽 奔宵 降龙十八掌 北冥神功 六脉神剑 九阴真经 "
  if string.find(szAllName, " " .. aItemName .. " ", nil, true) then
    return true
  end
  return false
end

function Bag:InfantEqui_lv(aItemName)
  local szAllName = " 绛麻衣 棉僧衣 锦绸衣 绢丝衣 哭丧棒 雁翎刀 松纹剑 娥眉刺 灵鳌步 一苇渡江 草上飞 水上漂 青铜令 黄铜戒 翠玉佩 白珍珠 黄鬃马 褐鬃马 黑鬃马 云鬃马 太祖长拳 天山折梅手 大理剑诀 美女拳法 "
  if string.find(szAllName, " " .. aItemName .. " ", nil, true) then
    return true
  end
  return false
end

function Bag:HasCaiLiaoByType(aTypeName, aObj)
  local tObj = aObj or self:EnumCailiaoItem()
  for i = 1, #tObj do
    if tObj[i].class == aTypeName then
      return true
    end
  end
  return false
end

function Bag:GetShopNPC(aIsPetShop)
  local tShopNPC = {
    {
      x = 275,
      y = 295,
      sceneName = "洛阳",
      sceneID = LUOYANG_ID,
      name = "云渺渺",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 282,
      y = 41,
      sceneName = "凤鸣镇",
      sceneID = 850,
      name = "云潇潇",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 309,
      y = 459,
      sceneName = "金陵",
      sceneID = 762,
      name = "云潇潇",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 309,
      y = 459,
      sceneName = "金陵2线",
      sceneID = 772,
      name = "云潇潇",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 309,
      y = 459,
      sceneName = "金陵3线",
      sceneID = 773,
      name = "云潇潇",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 271,
      y = 133,
      sceneName = "大理",
      sceneID = 2,
      name = "云飘飘",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 109,
      y = 121,
      sceneName = "楼兰",
      sceneID = 246,
      name = "云兮兮",
      option = "看看你卖的东西",
      petshop = true
    },
    {
      x = 171,
      y = 238,
      sceneName = "苏州",
      sceneID = 1,
      name = "云霏霏",
      option = "购买珍兽用品",
      petshop = true
    },
    {
      x = 349,
      y = 248,
      sceneName = "洛阳",
      sceneID = LUOYANG_ID,
      name = "何生富",
      option = "",
      petshop = false
    },
    {
      x = 175,
      y = 293,
      sceneName = "洛阳",
      sceneID = LUOYANG_ID,
      name = "何生财",
      option = "",
      petshop = false
    },
    {
      x = 231,
      y = 83,
      sceneName = "凤鸣镇",
      sceneID = 850,
      name = "高升瑞",
      option = "看看你卖的东西",
      petshop = false
    },
    {
      x = 332,
      y = 370,
      sceneName = "金陵",
      sceneID = 762,
      name = "高升瑞",
      option = "看看你卖的东西",
      petshop = false
    },
    {
      x = 332,
      y = 370,
      sceneName = "金陵2线",
      sceneID = 772,
      name = "高升瑞",
      option = "看看你卖的东西",
      petshop = false
    },
    {
      x = 332,
      y = 370,
      sceneName = "金陵3线",
      sceneID = 773,
      name = "高升瑞",
      option = "看看你卖的东西",
      petshop = false
    },
    {
      x = 208,
      y = 177,
      sceneName = "大理",
      sceneID = 2,
      name = "何生金",
      option = "",
      petshop = false
    },
    {
      x = 219,
      y = 129,
      sceneName = "楼兰",
      sceneID = 246,
      name = "祝三思",
      option = "",
      petshop = false
    },
    {
      x = 184,
      y = 275,
      sceneName = "苏州",
      sceneID = 1,
      name = "张进宝",
      option = "",
      petshop = false
    },
    {
      x = 344,
      y = 228,
      sceneName = "苏州",
      sceneID = 1,
      name = "张小泉",
      option = "",
      petshop = false
    }
  }
  local tNPC = {}
  if aIsPetShop then
    for i = 1, #tShopNPC do
      local tmp = tShopNPC[i]
      if tmp.petshop then
        table.insert(tNPC, tmp)
      end
    end
  else
    for i = 1, #tShopNPC do
      local tmp = tShopNPC[i]
      table.insert(tNPC, tmp)
    end
  end
  return tNPC
end

function Bag:FindItemIndexByTableID(aTableID, aUseItem)
  aUseItem = aUseItem or 0
  if -1 == aTableID then
    return -1
  end
  local strText = fmt([[
            local idTable = %d
            local nUseItem = %d
            for i = 0, 219 do
                local _id_table = PlayerPackage:GetItemTableIndex(i)
                if _id_table == idTable then
                    if nUseItem == 1 then 
                        PlayerPackage:UseItem(i)
                    end
                    return i
                end
            end
            return -1
        ]], aTableID, aUseItem)
  local itemIndex = GetLuaValue(strText, "n")
  return itemIndex
end

function Bag:SearchItemName(aItemName, aObj)
  aObj = aObj or self:EnumAllObj()
  local tName = Text2Table(aItemName, " ")
  local tSearch = GetTableFieldValue(aObj, "name", tName)
  return tSearch
end

function Bag:SearchItemType(aTypeName, aObj)
  aObj = aObj or self:EnumAllObj()
  local tName = Text2Table(aTypeName, " ")
  local tSearch = GetTableFieldValue(aObj, "class", tName)
  if string.find(aTypeName, " 所有宝石 ", nil, true) then
    local tGem = {}
    for i = 1, #aObj do
      local tmp = aObj[i]
      if 5 == tmp.itemType then
        table.insert(tGem, tmp)
      end
    end
    TableInsertTable_arr(tSearch, "index", tGem)
  end
  if string.find(aTypeName, " 珍兽装备 ", nil, true) then
    local tGem = {}
    for i = 1, #aObj do
      local tmp = aObj[i]
      if 7 == tmp.itemType then
        table.insert(tGem, tmp)
      end
    end
    TableInsertTable_arr(tSearch, "index", tGem)
  end
  return tSearch
end

function Bag:SearchItem(aItemName, aObj)
  local tObj = aObj or self:EnumAllObj()
  local tSearch1 = self:SearchItemName(aItemName, tObj)
  local tSearch2 = self:SearchItemType(aItemName, tObj)
  TableInsertTable_arr(tSearch1, "index", tSearch2)
  BubbleSort(tSearch1, "index", 1)
  return tSearch1
end

function Bag:FindItemInfo(aItemName, aCheckBind, aCheckLock, aItem)
  aCheckBind = aCheckBind or 0
  aCheckLock = aCheckLock or 0
  local tBag = aItem or self:EnumAllObj()
  tBag = GetTableFieldValue(tBag, "name", {aItemName})
  if 1 == aCheckBind then
    tBag = GetTableFieldValue(tBag, "bind", {0})
  elseif 2 == aCheckBind then
    tBag = GetTableFieldValue(tBag, "bind", {1})
  end
  if 1 == aCheckLock then
    tBag = GetTableFieldValue(tBag, "lock", {0})
  elseif 2 == aCheckLock then
    tBag = GetTableFieldValue(tBag, "lock", {1})
  end
  return tBag
end

function Bag:GetItemCount(aItemName, aCheckBind, aCheckLock, aItem)
  local tItem = self:FindItemInfo(aItemName, aCheckBind, aCheckLock, aItem)
  local nCount = TableFieldCount(tItem, "count")
  return nCount
end

function Bag:FindItem_vague(strVague, aMode, aObj)
  if nil == strVague or "" == strVague then
    return {}
  end
  aMode = aMode or 2
  local tObj = aObj or self:EnumAllObj()
  local tFind = GetTableChildString(tObj, "name", {strVague}, aMode)
  return tFind
end

function Bag:FindDingWei(aFindName)
  local tItem = self:EnumDaoJuItem()
  local tDingWeiFu = {}
  if nil ~= aFindName then
    if string.find(aFindName, "灵珠", nil, true) then
      tDingWeiFu = GetTableFieldValue(tItem, "name", {"地灵珠", "土灵珠"})
    else
      tDingWeiFu = GetTableFieldValue(tItem, "name", {aFindName})
    end
  else
    tDingWeiFu = self:FindItem_vague("定位符", 2, tItem)
  end
  for i = 1, #tDingWeiFu do
    local tmp = tDingWeiFu[i]
    local pDateExt = 0
    if IsProcess64() then
      pDateExt = R_P(tmp.obj + 24)
    else
      pDateExt = R_P(tmp.obj + 20)
    end
    tmp.dwf = {}
    tmp.dwf.data = R_W(pDateExt + 52)
    tmp.dwf.max_count = R_B(pDateExt + 54)
    tmp.dwf.has_count = R_B(pDateExt + 55)
    tmp.dwf.mapID = R_W(pDateExt + 56)
    tmp.dwf.sceneID = tmp.dwf.mapID
    tmp.dwf.sceneName = ""
    tmp.dwf.x = R_W(pDateExt + 58)
    tmp.dwf.y = R_W(pDateExt + 60)
  end
  return tDingWeiFu
end

function Bag:FindBaoTu(aItem, aItemName)
  local tItem = aItem or self:EnumDaoJuItem()
  local tDingWeiFu = self:FindItemInfo(aItemName, nil, nil, tItem)
  for i = 1, #tDingWeiFu do
    local tmp = tDingWeiFu[i]
    local pDateExt = 0
    if IsProcess64() then
      pDateExt = R_P(tmp.obj + 24)
    else
      pDateExt = R_P(tmp.obj + 20)
    end
    tmp.pos = {}
    tmp.pos.data = R_B(pDateExt + 52)
    tmp.pos.sceneResID = R_W(pDateExt + 53)
    tmp.pos.x = R_W(pDateExt + 55)
    tmp.pos.y = R_W(pDateExt + 57)
  end
  return tDingWeiFu
end

function Bag:EunmBindItem(abRemoveLock, tItem)
  tItem = tItem or self:EnumAllObj()
  local tBind = GetTableFieldValue(tItem, "bind", {1})
  if abRemoveLock then
    tBind = DeleteTableFieldValue(tBind, "lock", {1})
  end
  return tBind
end

function Bag:EnumUnBindItem(abRemoveLock, tItem)
  tItem = tItem or self:EnumAllObj()
  local tUnBind = GetTableFieldValue(tItem, "bind", {0})
  if abRemoveLock then
    tUnBind = DeleteTableFieldValue(tUnBind, "lock", {1})
  end
  return tUnBind
end

function Bag:GetLineRow(aIndex)
  if 0 ~= aIndex % 10 then
    return math.floor(aIndex / 10 + 1), aIndex % 10
  else
    return math.floor(aIndex / 10), 10
  end
end

function Bag:UseItem_action(aIndex, aSleep)
  local strText = fmt([[
            local nIndex = %d
            local theAction = EnumAction(nIndex, "packageitem")
            local itemID = theAction:GetID()
            if itemID ~= 0 then
                setmetatable(_G, {__index = Packet_Env})
                local oldID = Packet_Space_Line10_Row10_button:GetActionItem()
                Packet_Space_Line10_Row10_button:SetActionItem(itemID)
                Packet_Space_Line10_Row10_button:DoAction()
                Packet_Space_Line10_Row10_button:SetActionItem(oldID)
            end
        ]], aIndex)
  GetLuaValue(strText)
  if aSleep then
    Sleep(aSleep)
  end
end

function Bag:ItemBtnClicked(aIndex)
  self:UseItem_action(aIndex)
end

function Bag:GetSpaceNum(aTabIndex)
  return GetLuaValue(fmt("return meGetBagSpaceNum(%d)", aTabIndex), "nnn")
end

function Bag:UseItem(aIndex, aSleep)
  if type(aIndex) == "number" and aIndex >= 0 then
    GetLuaValue("PlayerPackage:UseItem(" .. aIndex .. ")")
    if aSleep then
      Sleep(aSleep)
    end
  end
end

function Bag:UseItemByName(aItemName, aSleep, aItem)
  local tItem = Bag:FindItemInfo(aItemName, 0, 0, aItem)
  if #tItem > 0 then
    self:UseItem(tItem[1].index, aSleep)
    return true
  end
  return false
end

function Bag:UseItemByName_click(aItemName, aSleep, aItem)
  local tItem = Bag:FindItemInfo(aItemName, nil, nil, aItem)
  if #tItem > 0 then
    local tmp = tItem[1]
    self:UseItem_action(tmp.index, aSleep)
    return true
  end
  return false
end

function BagUseItemCheckWindowShow(aItemIndex, aCheckWindow, abCloseWindow, aUnCanText, aSleep)
  local strAll = [[
local bCan = true 
    ]]
  for i = 1, #aCheckWindow do
    local strText = ""
    if abCloseWindow then
      strText = fmt([[
  
                    if bCan then
                        setmetatable(_G, {__index = %s_Env})
                        if this and this:IsVisible() then
                            this:Hide()
                        end            
                    end
                ]], aCheckWindow[i])
    else
      strText = fmt([[
                    if bCan then
                        setmetatable(_G, {__index = %s_Env})
                        if this and this:IsVisible() then
                            bCan = false
                        end
                    end            
                ]], aCheckWindow[i])
    end
    strAll = strAll .. strText
  end
  strAll = strAll .. fmt([[
                if bCan then
                    local theAction = EnumAction(%d, "packageitem")
                    local itemID = theAction:GetID()
                    if itemID ~= 0 then
                        setmetatable(_G, {__index = Packet_Env})
                        local oldID = Packet_Space_Line10_Row10_button:GetActionItem()
                        Packet_Space_Line10_Row10_button:SetActionItem(itemID)
                        Packet_Space_Line10_Row10_button:DoAction()
                        Packet_Space_Line10_Row10_button:SetActionItem(oldID)
                    end
                else
                    %s
                end    
    ]], aItemIndex, aUnCanText)
  GetLuaValue(strAll)
  if aSleep then
    Sleep(aSleep)
  end
end

function Bag:LuaUseItem_DJ(aAllItemName, aBind)
  local use_index = -1
  if nil == aAllItemName or "" == aAllItemName then
    return use_index
  end
  aAllItemName = HandleText_AddFuHao(aAllItemName, " ")
  aBind = aBind or 2
  local szText = fmt([[
            local idx = -1
            local szItem = "%s"
            local CurrBagNum = DataPool:GetBaseBag_Num()
            for i = 0, CurrBagNum - 1 do
                local theAction, bLocked, bProtect = PlayerPackage:EnumItem("base", i)
                if theAction:GetID() ~= 0 then
                    local szName = theAction:GetName()
                    if szName and string.find(szItem ," " .. szName .. " " ,nil,true) then
                        --#{ifbind}
                            PlayerPackage:UseItem(i)
                            idx = i
                        --#{endbind}
                    end
                end
            end
            return idx
        ]], aAllItemName)
  if 1 == aBind then
    szText = string.gsub(szText, "--#{ifbind}", "if GetItemBindStatus(i) == 0 then")
    szText = string.gsub(szText, "--#{endbind}", "end")
  elseif 2 == aBind then
    szText = string.gsub(szText, "--#{ifbind}", "if GetItemBindStatus(i) == 1 then")
    szText = string.gsub(szText, "--#{endbind}", "end")
  end
  use_index = GetLuaValue(szText, "n")
  return use_index
end

function Bag:UseItem_SP_ext(aItemName)
  local bUse = false
  local tmp = {}
  local itemTable = {
    {
      name = "小力丹",
      scriptID = 332210,
      count = 4,
      idTable = 30505278,
      p0 = -1,
      p1 = -100,
      p2 = -100,
      p3 = -100
    },
    {
      name = "地力丹",
      scriptID = 332210,
      count = 4,
      idTable = 30505279,
      p0 = -1,
      p1 = -100,
      p2 = -100,
      p3 = -100
    },
    {
      name = "天力丹",
      scriptID = 332210,
      count = 4,
      idTable = 30505280,
      p0 = -1,
      p1 = -100,
      p2 = -100,
      p3 = -100
    },
    {
      name = "金玉富贵袋",
      scriptID = 340007,
      count = 3,
      p0 = -1,
      p1 = -100,
      p2 = -100,
      p3 = -100
    }
  }
  for i = 1, #itemTable do
    if itemTable[i].name == aItemName then
      tmp = itemTable[i]
      break
    end
  end
  if tmp.scriptID then
    if tmp.scriptID == 332210 then
      tmp.p2 = tmp.idTable
      tmp.p3 = 0
    elseif tmp.scriptID == 340007 then
      tmp.p2 = 0
    end
    local tItem = self:FindItemInfo(aItemName, nil, nil, self:EnumDaoJuItem())
    if #tItem > 0 then
      tmp.p1 = tItem[1].index
      PushDebugMessage("吃" .. tItem[1].name)
      bUse = true
      local strText = fmt([[
                    Clear_XSCRIPT()
                        Set_XSCRIPT_ScriptID(%d)
                        Set_XSCRIPT_Function_Name("OnUseItem")
                        Set_XSCRIPT_ParamCount(%d)
                        local p0 = %d
                        local p1 = %d  
                        local p2 = %d
                        local p3 = %d  
                        Set_XSCRIPT_Parameter(0,p0)
                        Set_XSCRIPT_Parameter(1,p1)                              
                        Set_XSCRIPT_Parameter(2,p2)                  
                        if p3 ~= -100 then
                            Set_XSCRIPT_Parameter(3,p3)
                        end
                    Send_XSCRIPT()
                ]], tmp.scriptID, tmp.count, tmp.p0, tmp.p1, tmp.p2, tmp.p3)
      GetLuaValue(strText)
    end
  end
  return bUse
end

function Bag:GetItem_TeXie(tObj, aItem)
  local tTeXie = {}
  for i = 1, #tObj do
    if 5 == tObj[i].itemType or 6 == tObj[i].itemType and 9 ~= tObj[i].childType or 7 == tObj[i].itemType then
      for j = 1, #aItem do
        if 5 == tObj[i].itemType and aItem[j].name == "所有宝石" then
          table.insert(tTeXie, tObj[i])
        elseif 6 == tObj[i].itemType and 9 ~= tObj[i].childType and aItem[j].name == "子女装备" then
          table.insert(tTeXie, tObj[i])
        elseif 7 == tObj[i].itemType and 75 == tObj[i].level and 1 == tObj[i].xing and aItem[j].name == "珍兽装备" then
          table.insert(tTeXie, tObj[i])
        end
      end
    end
  end
  return tTeXie
end

function Bag:CanSaleDestroy_base(aBag, aWhere)
  if 1 == aBag.lock then
    return false
  end
  if 1 == aBag.itemType then
    if aBag.author ~= "" then
      return false
    end
    if aBag.name == "兔耳朵" then
      return false
    end
    if 1 == aBag.level then
      return false
    end
    if 1 == aBag.bind and aBag.xing >= 3 then
      return false
    end
    if aBag.class == "幻饰武器" then
      return false
    end
  end
  if 5 == aBag.itemType and string.find(aBag.name, "1级", nil, true) == nil then
    return false
  end
  if 6 == aBag.itemType and 9 ~= aBag.childType and string.find(" 乌蚕衣 松纹剑 绢丝衣 翠玉佩 貂皮裘 玄狐裘 银丝手套 ", " " .. aBag.name .. " ", nil, true) then
    return false
  end
  if 6 == aBag.itemType and 9 ~= aBag.childType and aBag.level > 0 then
    return false
  end
  if aBag.name == "芳菲节" or aBag.name == "梦迷离" then
    return false
  end
  if 1 == aWhere and (aBag.name == "御瑶盘" or aBag.name == "琉璃焰") then
    local bCanDel = GetLuaValue(fmt([[
                    local bCanDel = 0
                    local itemIdx = %d
                    if PlayerPackage:IsBagItemKFS(itemIdx) == 1 then
                        local nGrow = PlayerPackage:GetBagKfsData(itemIdx, "GROW")
                        local nLevel = PlayerPackage:GetBagKfsData(itemIdx, "EXTRALEVEL")
                        if nGrow == 600 and nLevel == 1 then
                            bCanDel = 1
                        end
                    end
                    return bCanDel
                ]], aBag.index), "b")
    if not bCanDel then
      return false
    end
  end
  return true
end

function Bag:CanSaleDestroy(aBag, aWhere)
  if not self:CanSaleDestroy_base(aBag, aWhere) then
    return false
  end
  if 1 == aBag.itemType then
    if string.find(aBag.desc, "全套由", nil, true) then
      return true
    elseif aBag.xing > 3 then
      return false
    end
  end
  return true
end

function Bag:GetChangYongDestroyItem()
  return " 未央 灵兽爪 灵兽面 灵兽甲 灵兽饰 灵兽环 傲凰肩 傲凰锦衣 傲凰帽 傲凰手套 傲凰腕 傲凰鞋 八荒段云肩 八荒段云皮甲 八荒段云鞋 八荒断云肩 八荒断云鞋 八荒腰带 八卦宣花斧 白虹环 白虹剑 百炼 百转千形扇 百斐戒指 北斗箍环 北乾箍 北乾箍环 北冥摇光戒 北冥摇光腕 北冥之白马西风扇 北冥之碧磷野火扇 北冥之闭魄 北冥之蝶残 北冥之东山歌酒环 北冥之督亢图穷扇 北冥之风檐古道扇 北冥之割须弃袍扇 北冥之鬼雾护肩 北冥之鬼雾护手 北冥之鬼雾履 北冥之鬼雾帽 北冥之鬼雾腕 北冥之鬼雾腰环 北冥之鬼雾裘 北冥之国士无双轮 北冥之黄泉 北冥之混元无极圈 北冥之九捻 北冥之连决护符 北冥之连影夺目 北冥之炼鸾护手 北冥之炼鸾帽 北冥之炼鸾圣肩 北冥之炼鸾仙履 北冥之炼鸾仙腕 北冥之炼鸾仙裘 北冥之裂戒护符 北冥之烈火淬金环 北冥之烈日锋刃环 北冥之末路 北冥之末路北冥之黄泉 北冥之皮麟护肩 北冥之皮麟护手 北冥之皮麟履 北冥之皮麟帽 北冥之皮麟腕 北冥之皮麟裘 北冥之三清 北冥之韶华护肩 北冥之韶华护手 北冥之韶华履 北冥之韶华帽 北冥之韶华腕 北冥之韶华裘 北冥之水漫声 北冥之铁骨凤凰扇 北冥之西江月 北冥之瑶仙护肩 北冥之瑶仙护手 北冥之瑶仙腕 北冥之瑶仙裘 北冥之银皮护肩 北冥之银皮履 北冥之银霄履 北冥之银皮帽 北冥之银皮腕 北冥之银皮裘 北冥之银霄护肩 北冥之银霄护手 北冥之银霄帽 北冥之银霄皮带 北冥之银霄腕 北冥之银霄裘 北冥之幽仙 北冥之玉楼春 北冥之云归护符 北冥之枕霜寝露环 北冥之狻猊 北冥之狻猊护手 北冥之狻猊帽 北冥之狻猊魔腕 北冥之狻猊圣肩 北冥之狻猊圣履 北冥之狻猊天裘 北冥之魅蛟护手 北冥之魅蛟帽 北冥之魅蛟圣肩 北冥之魅蛟圣腕 北冥之魅蛟圣裘 北冥之魅蛟天履 碧流 碧落 碧落泄银首 碧落泻银的诱惑 碧落泻银手 碧落泻银鞋 碧焰散情肩 碧焰腰带 碧焰之纯 碧焰之华 碧焰之噬 碧影盔 碧影手甲 碧影靴 碧影铠 碧元护手 碧元履 碧元帽 碧元裘 冰粹影月护符 冰粹影月护手 冰粹影月帽 冰粹影月鞋 冰粹影月指环 冰粹月影护符 冰粹月影护手 冰粹月影指环 冰凝风寒护符 冰凝风寒护手 冰凝风寒冒 冰凝风寒帽 冰凝风寒手 冰凝风寒鞋 冰凝风寒指环 冰弦剑 布锦肩 布锦帽 布锦手套 布锦腕 布锦衣 布鞋 布衣 裁金剑 裁云扇 灿星护甲 灿星护肩 灿星皮靴 灿星腰带 苍蟒帽 苍蟒手套 苍蟒鞋 苍蟒衣 朝颜护肩 朝颜皮甲 朝颜皮靴 朝颜腰带 缠魂玄明帽 缠魂玄明手 缠魂指环 长乐 迟悔之环 迟悔之懵 迟悔之沐 迟悔芸玲护肩 赤铜弩 赤骁盔 赤骁手甲 赤骁靴 赤骁铠 赤鸢护手 赤鸢履 赤鸢帽 赤鸢裘 纯阳散雪肩 纯阳散雪鞋 纯阳腰带 雌雄剑 翠玉佩 翠竹戒指 达摩之闭魄 达摩之冰银钻龙叉 达摩之彩金铃 达摩之残魂护符 达摩之冲阵斩马刀 达摩之蝶残 达摩之封霄护肩 达摩之封霄盔 达摩之封霄手甲 达摩之封霄铁甲 达摩之封霄铁靴 达摩之封霄腕 达摩之凤翅镏金镋 达摩之合扇板门刀 达摩之虎尾丧门枪 达摩之魂噬圣盔 达摩之惊魂夺魄枪 达摩之九捻 达摩之连决护符 达摩之烈焰火尖枪 达摩之满月 达摩之灭寒护肩 达摩之灭寒盔 达摩之灭寒手甲 达摩之灭寒铁腕 达摩之灭寒铁靴 达摩之灭寒腰环 达摩之灭寒铠 达摩之灭魄护肩 达摩之灭魄盔 达摩之灭魄手甲 达摩之灭魄腕 达摩之灭魄铠 达摩之逆火钢靴 达摩之逆火护肩 达摩之逆火甲 达摩之逆火盔 达摩之逆火手甲 达摩之逆火腕 达摩之盘龙梅花戟 达摩之劈水电光刀 达摩之青龙偃月刀 达摩之三清 达摩之三清达摩之蛰龙手甲 达摩之誓尘护肩 达摩之誓尘盔 达摩之誓尘手甲 达摩之誓尘铁甲 达摩之誓尘腕 达摩之誓尘靴 达摩之誓尘腰带 达摩之双翅困龙钺 达摩之水漫声 达摩之宿忧 达摩之碎魂圣甲 达摩之碎魂圣肩 达摩之碎魂圣腕 达摩之碎魂手甲 达摩之碎魂天靴 达摩之天崩 达摩之西江月 达摩之玄铁护肩 达摩之玄铁盔 达摩之玄铁手甲 达摩之玄铁腕 达摩之玄铁铠 达摩之幽仙 达摩之鱼鳞贴金刀 达摩之玉楼春 达摩之月铁护肩 达摩之月铁手甲 达摩之月铁腕 达摩之月铁靴 达摩之云归护符 达摩之皂金虎头枪 达摩之丈八蛇矛枪 达摩之蛰龙 达摩之蛰龙圣肩 达摩之蛰龙圣腕 达摩之蛰龙圣靴 达摩之蛰龙手甲 达摩之蛰龙天盔 达摩之蛰龙天铠 达摩之铩羽 地鹤腰环 地鹤之灭 地鹤之碎 地皇冠 地皇肩 地皇锦服 地皇手套 地皇腕 地皇鞋 地火玄卢枪 地玄护手 地玄履 地玄帽 地玄裘 地炎环带 电光锤 雕翎扇 定军扇 毒影彰华护符 毒影瘴华护符 毒影瘴华护手 毒影瘴华帽 毒影瘴华鞋 毒影瘴华指环 毒冥暗灭指环 毒冥黯灭护符 毒冥黯灭护手 毒冥黯灭帽 毒冥黯灭鞋 毒冥黯灭指环 毒冥黯鞋 夺魂尘丝肩 夺魂尘丝腕 夺魂尘丝鞋 夺魂腰带 夺魂腰环 飞花丝帽 飞花杖 飞花仗 飞天腰环 分水峨嵋刺 焚灭暮月冠 焚灭暮月手 焚灭暮月腕 焚灭暮月腰带 焚灭暮月腰环 焚灭之霜 风火轮 风雷枪 凤求凰 佛母紫金枪 拂香环 覆雪护符 覆雪丝帽 高昌袍 归埃云之甲 归埃云之盔 归埃云之手 归埃之触 归埃之术 寒霜冠 寒霜肩 寒霜手套 寒霜腕 寒霜鞋 寒霜衣 寒铁杖 寒雾漫影腕 寒雾腰环 寒雾之泣 寒雾之涌 寒月手甲 汉光弄影剑 虎皮手套 虎皮鞋 虎皮衣 虎爪手套 虎爪鞋 幻凤皮履 幻凤圣手 幻凤圣裘 幻凤仙帽 幻麟圣甲 幻麟圣盔 幻麟圣靴 幻麟手甲 荒毒之闭魄 荒毒之博浪双斧 荒毒之彩金铃 荒毒之残魂护符 荒毒之承影双刀 荒毒之淬血双剑 荒毒之电光双刀 荒毒之蝶残 荒毒之归尘双斧 荒毒之含光双剑 荒毒之虎头飞镰刃 荒毒之混沌 荒毒之金霞带 荒毒之九捻 荒毒之连决护符 荒毒之连影夺目 荒毒之裂戒护符 荒毒之灵动圣肩 荒毒之灵动圣腕 荒毒之灵动手套 荒毒之灵动天冠 荒毒之灵动天靴 荒毒之灵动天衣 荒毒之六合七星剑 荒毒之满月 荒毒之棉丝护肩 荒毒之棉丝护腕 荒毒之棉丝帽 荒毒之棉丝手套 荒毒之棉丝鞋 荒毒之莫问 荒毒之蒲布护肩 荒毒之蒲布帽 荒毒之蒲布手套 荒毒之蒲布腕 荒毒之蒲布衣 荒毒之奇绝碧灵剑 荒毒之青峨冠 荒毒之青峨肩 荒毒之青峨手套 荒毒之青峨腕 荒毒之青峨鞋 荒毒之青峨衣 荒毒之青虹百战剑 荒毒之青陌护符 荒毒之柔云双剑 荒毒之如梦冠 荒毒之如梦肩 荒毒之如梦锦衣 荒毒之如梦手套 荒毒之如梦腕 荒毒之如梦鞋 荒毒之三清 荒毒之圣目肩 荒毒之圣目帽 荒毒之圣目手套 荒毒之圣目腕 荒毒之圣目鞋 荒毒之圣目衣 荒毒之霜华青光剑 荒毒之水漫声 荒毒之四海冠 荒毒之四海肩 荒毒之四海锦服 荒毒之四海手套 荒毒之四海腕 荒毒之四海鞋 荒毒之苏锦肩 荒毒之苏锦帽 荒毒之苏锦手套 荒毒之苏锦腕 荒毒之苏锦鞋 荒毒之苏锦衣 荒毒之幽仙 荒毒之玉楼春 荒毒之云归护符 荒毒之真丝长衫 荒毒之真丝护肩 荒毒之真丝护腕 荒毒之真丝帽 荒毒之真丝鞋 荒毒之镇世 回心融雪鞋 回心融雪衣 回心之哀 回心之链 回心之桑 混天环带 混沌环 火炽焚焰护符 火炽焚焰护手 火炽焚焰帽 火炽焚焰鞋 火炽焚焰指环 火尖枪 火印烈阳护手 火映烈阳护符 火映烈阳护手 火映烈阳帽 火映烈阳套装 火映烈阳鞋 火映烈阳指环 降龙之冲阵斩马刀 降龙之蝶残 降龙之封霄护肩 降龙之封霄盔 降龙之封霄手甲 降龙之封霄铁甲 降龙之封霄铁靴 降龙之封霄腕 降龙之凤翅镏金镋 降龙之合扇板门刀 降龙之虎尾丧门枪 降龙之魂噬圣盔 降龙之九捻 降龙之连决护符 降龙之连影夺目 降龙之裂戒护符 降龙之烈焰火尖枪 降龙之满月 降龙之灭寒护肩 降龙之灭寒盔 降龙之灭寒手甲 降龙之灭寒铁腕 降龙之灭寒铁靴 降龙之灭寒腰环 降龙之灭寒铠 降龙之灭魄护肩 降龙之灭魄盔 降龙之灭魄手甲 降龙之灭魄腕 降龙之灭魄靴 降龙之灭魄铠 降龙之逆火钢靴 降龙之逆火护肩 降龙之逆火甲 降龙之逆火盔 降龙之逆火手甲 降龙之逆火腕 降龙之盘龙梅花戟 降龙之劈水电光刀 降龙之青龙偃月刀 降龙之三清 降龙之誓尘护肩 降龙之誓尘盔 降龙之誓尘手甲 降龙之誓尘铁甲 降龙之誓尘腕 降龙之誓尘靴 降龙之誓尘腰带 降龙之疏影链 降龙之双翅困龙钺 降龙之水漫声 降龙之宿忧 降龙之碎魂 降龙之碎魂圣甲 降龙之碎魂圣肩 降龙之碎魂圣腕 降龙之碎魂手甲 降龙之碎魂天靴 降龙之天崩 降龙之西江月 降龙之玄铁护肩 降龙之玄铁盔 降龙之玄铁手甲 降龙之玄铁腕 降龙之玄铁靴 降龙之玄铁腰带 降龙之玄铁铠 降龙之幽仙 降龙之鱼鳞贴金刀 降龙之月铁护肩 降龙之月铁甲 降龙之月铁盔 降龙之月铁手甲 降龙之月铁腕 降龙之月铁靴 降龙之云归护符 降龙之皂金虎头枪 降龙之蛰龙 降龙之蛰龙圣肩 降龙之蛰龙圣腕 降龙之蛰龙圣靴 降龙之蛰龙手甲 降龙之蛰龙天盔 降龙之蛰龙天铠 金背刀 金顶狼牙槊 金刚散铁手 金刚散指环 金刚战杖 金刚指环 金菊丝帽 锦秋宝靴 锦秋霞芳 锦秋霞芳符 锦秋霞芳甲 锦秋霞芳戒 锦秋霞芳链 精钢剑 精钢迅弩 九变幻化腰 九龙方便铲 九夏暖阳符 九夏暖阳冠 九夏暖阳手 九夏暖阳腕 九夏暖阳腰 九阳碧麟甲 九阳碧麟盔 九阳碧麟手 九阳碧麟鞋 巨门帽 巨门鞋 绢宫扇 绢丝帽 绢丝手套 绢丝鞋 绢丝衣 开明靴 开山钺 开源护手 开源帽 开源靴 开源裘 孔羽冠 孔羽护手 孔羽靴 孔羽裘 枯心之慈 枯心之瑞 枯心之月 枯心莞玉臂 蓝玉剑 蓝云项链 兰沁护腕 狼皮帽 狼皮手套 狼皮鞋 狼皮衣 狼爪帽 狼爪衣 雷袭冠 雷袭护符 雷袭之戒 雷袭之链 冷月玉魅护腕 冷月之环 冷月之铸 冷月之岚 两仪战云弩 亮银枪 列焰刀 烈焰刀 凌烟灭麟鞋 凌烟灭麟之泪 凌烟之海 凌烟之雪 凌烟之麟 灵兽环 灵兽甲 灵兽面 灵兽饰 灵兽爪 流魂宿灭法袍 流魂宿灭冠 流魂宿灭手 流魂宿灭鞋 柳色腰带 龙凤双剑 龙虎刃 龙战潜铁手 龙麟刃 落凰护手 落凰履 落凰帽 落凰裘 麻布帽 麻布手套 麻布鞋 曼陀戒指 绵竹扇 明骁腰带 明蛟腰带 莫愁护手 莫愁帽 莫愁鞋 莫愁衣 墨求 纳林护肩 南蛟龙鞋 凝脉之白马西风扇 凝脉之碧磷野火扇 凝脉之残魂护符 凝脉之蝶残 凝脉之督亢图穷扇 凝脉之风檐古道扇 凝脉之割须弃袍扇 凝脉之鬼雾护肩 凝脉之鬼雾护手 凝脉之鬼雾履 凝脉之鬼雾帽 凝脉之鬼雾腕 凝脉之鬼雾腰环 凝脉之鬼雾裘 凝脉之国士无双轮 凝脉之黄泉 凝脉之混元无极圈 凝脉之九捻 凝脉之连决护符 凝脉之连影夺目 凝脉之炼鸾护手 凝脉之炼鸾帽 凝脉之炼鸾圣肩 凝脉之炼鸾仙履 凝脉之炼鸾仙腕 凝脉之炼鸾仙裘 凝脉之裂戒护符 凝脉之烈火淬金环 凝脉之满月 凝脉之末路 凝脉之皮麟护肩 凝脉之皮麟护手 凝脉之皮麟履 凝脉之皮麟帽 凝脉之皮麟腕 凝脉之皮麟腰带 凝脉之皮麟裘 凝脉之三清 凝脉之韶华护肩 凝脉之韶华护手 凝脉之韶华履 凝脉之韶华帽 凝脉之韶华腕 凝脉之韶华裘 凝脉之水漫声 凝脉之宿忧 凝脉之太乙阴阳环 凝脉之铁骨凤凰扇 凝脉之西江月 凝脉之瑶仙护肩 凝脉之瑶仙护手 凝脉之瑶仙帽 凝脉之瑶仙腕 凝脉之瑶仙裘 凝脉之银皮护肩 凝脉之银皮护手 凝脉之银皮帽 凝脉之银皮腕 凝脉之银皮裘 凝脉之银霄护肩 凝脉之银霄护手 凝脉之银霄履 凝脉之银霄帽 凝脉之银霄皮带 凝脉之银霄腕 凝脉之银霄裘 凝脉之幽仙 凝脉之云归护符 凝脉之枕霜寝露环 凝脉之狻猊 凝脉之狻猊护手 凝脉之狻猊帽 凝脉之狻猊魔腕 凝脉之狻猊圣肩 凝脉之狻猊圣履 凝脉之狻猊天裘 凝脉之彗星袭月轮 凝脉之魅蛟 凝脉之魅蛟护手 凝脉之魅蛟帽 凝脉之魅蛟圣肩 凝脉之魅蛟圣腕 凝脉之魅蛟圣裘 凝脉之魅蛟天履 凝霜环 怒焰寒铁盔 怒焰护符 怒焰之链 怒缨护肩 怒缨戒指 怒缨之护 怒缨之链 皮革帽 泼风刀 七星梦蝶双刀 七曜腰环 嵌金铭头锤 擒龙束铁甲 擒龙束铁腕 擒龙束铁鞋 擒龙腰环 擒龙之束 青陌护符 倾云护肩 倾云皮甲 秋水青云腕 秋水之环 秋水之怜 秋水之朽 儒玄盔 儒玄手甲 儒玄靴 儒玄铠 如故护腕 如心腰带 如意戒指 如玉戒指 锐锋将冠 锐锋将靴 锐锋将铠 锐锋手套 三笑腰带 三笑银桑碗 三笑银桑腕 三笑之哀 三笑之月 商阳圣玉肩 商阳圣玉腕 商阳圣玉鞋 商阳腰带 少商暮落首 少商幕落手 少商指环 少阳护符 少阳月息之魂 少阳之涯 少阳指环 少泽万华臂 少泽万华腰带 少泽之梦 少泽之魄 少泽之仪 神龙开天钺 神龙之碧 神龙之尘 神龙之寒 神龙魅铁甲 神木 神木束腰 神木之沐 神木麒麟袍 神木麒麟腕 神木麒麟鞋 神噬 神噬玉落法袍 神噬玉落冠 神噬玉落手 神噬玉落鞋 神碎带 神霄带 神行帽 神行手套 神行靴 圣火凌波甲 圣火凌波脚 圣火之百裂戒指 圣火之闭魄 圣火之冰银钻龙叉 圣火之残魂护符 圣火之赤 圣火之蝶残 圣火之封霄护肩 圣火之封霄盔 圣火之封霄手甲 圣火之封霄铁甲 圣火之封霄铁靴 圣火之封霄腕 圣火之凤翅镏金镋 圣火之刚 圣火之合扇板门刀 圣火之虎尾丧门枪 圣火之魂噬圣盔 圣火之惊魂夺魄枪 圣火之九捻 圣火之连决护符 圣火之连影夺目 圣火之烈焰火尖枪 圣火之满月 圣火之灭寒护肩 圣火之灭寒盔 圣火之灭寒手甲 圣火之灭寒铁腕 圣火之灭寒铁靴 圣火之灭寒腰环 圣火之灭寒铠 圣火之灭魄护肩 圣火之灭魄盔 圣火之灭魄手甲 圣火之灭魄腕 圣火之灭魄靴 圣火之灭魄铠 圣火之逆火钢靴 圣火之逆火护肩 圣火之逆火甲 圣火之逆火盔 圣火之逆火手甲 圣火之逆火腕 圣火之盘龙梅花戟 圣火之青龙偃月刀 圣火之清心 圣火之三清 圣火之誓尘护肩 圣火之誓尘盔 圣火之誓尘手甲 圣火之誓尘铁甲 圣火之誓尘腕 圣火之誓尘靴 圣火之誓尘腰带 圣火之水漫声 圣火之碎魂圣甲 圣火之碎魂圣肩 圣火之碎魂圣腕 圣火之碎魂手甲 圣火之碎魂天靴 圣火之天崩 圣火之西江月 圣火之心 圣火之玄铁护肩 圣火之玄铁盔 圣火之玄铁手甲 圣火之玄铁腕 圣火之玄铁靴 圣火之玄铁腰带 圣火之玄铁铠 圣火之幽仙 圣火之鱼鳞贴金刀 圣火之月铁护肩 圣火之月铁盔 圣火之月铁腕 圣火之月铁靴 圣火之月腕 圣火之皂金虎头枪 圣火之丈八蛇矛枪 圣火之蛰龙 圣火之蛰龙圣肩 圣火之蛰龙圣腕 圣火之蛰龙圣靴 圣火之蛰龙手甲 圣火之蛰龙天盔 圣火之蛰龙天铠 圣火之铩羽 圣灵肩 狮王锦袍 噬麟圣履 兽角点金枪 蜀锦冠 蜀锦肩 蜀锦帽 蜀锦手套 蜀锦腕 蜀锦鞋 蜀锦衣 水轮护符 水轮护符灵韵 水曜探归肩 水曜之峰 水曜之环 水曜之星 朔光六合冠 朔光六合手 朔光六合靴 朔光六合铠 丝绸帽 丝绸手套 丝绸鞋 丝花戒指 四象虎骨弩 四象梨花杖 松纹古定刀 松纹剑 松枝杖 松枝弩 素女化雨肩 素女腰带 素女之源 素女之月 宿曜镶玉扇 碎魂束腰 碎魂月塑腕 太皇 太极 太极泣火冠 太极泣火护手 太极泣火袍 太极之吟 太极之逐 檀木弩 檀香扇 桃木弩 桃纹杖 天地剑 天工千机符 天火环带 天龙侠情护符 天龙侠情剑 天龙侠情指环 天脉环 天目环 天南蛟龙腕 天南蛟龙鞋 天南蛟龙腰环 天南蛟龙之护佑 天玑帽 天玑鞋 天璇帽 天璇手套 添星护腕 添星手套 添星之环 添星之戒 屠龙文铁腕 屠龙腰带 屠龙之火 屠龙之水 团花双斧 万羽之八荒泯日弩 万羽之绝生 万羽之妙法太一弩 万羽之玄黄两仪弩 万羽之紫霞吞云弩 乌蚕帽 乌蚕鞋 乌蚕衣 乌龙铲 乌玛斧 乌玛斧无极之混沌 无尘炼铁腕 无尘炼铁鞋 无尘之环 无尘之炼 无尘之叹 无道冠 无极之暴闪环带 无极之闭魄 无极之博浪双斧 无极之残魂护符 无极之承影双刀 无极之电光双刀 无极之蝶残 无极之峨手套 无极之归尘双斧 无极之含光双剑 无极之虎头飞镰刃 无极之化血凝碧剑 无极之混沌 无极之金霞带 无极之九捻 无极之连决护符 无极之连影夺目 无极之灵动圣肩 无极之灵动圣腕 无极之灵动手套 无极之灵动天冠 无极之灵动天靴 无极之灵动天衣 无极之六合七星剑 无极之棉丝短衫 无极之棉丝护肩 无极之棉丝护腕 无极之棉丝帽 无极之棉丝鞋 无极之莫问 无极之蒲布护肩 无极之蒲布手套 无极之蒲布腕 无极之蒲布鞋 无极之蒲布衣 无极之奇绝碧灵剑 无极之青峨冠 无极之青峨肩 无极之青峨手套 无极之青峨腕 无极之青峨鞋 无极之青峨衣 无极之青虹百战剑 无极之青玉结 无极之柔云双剑 无极之如梦冠 无极之如梦肩 无极之如梦锦衣 无极之如梦手套 无极之如梦腕 无极之如梦鞋 无极之三清 无极之圣目肩 无极之圣目帽 无极之圣目手套 无极之圣目腕 无极之圣目鞋 无极之圣目衣 无极之霜华青光剑 无极之水漫声 无极之四海冠 无极之四海肩 无极之四海锦服 无极之四海手套 无极之四海腕 无极之四海鞋 无极之苏锦肩 无极之苏锦帽 无极之苏锦手套 无极之苏锦腕 无极之苏锦鞋 无极之苏锦衣 无极之宿忧 无极之天皇苍龙刀 无极之万圣 无极之西江月 无极之幽仙 无极之玉楼春 无极之云归护符 无极之招财腰带 无极之真丝长衫 无极之真丝护肩 无极之真丝护腕 无极之真丝手套 无极之真丝鞋 无极之镇世 无相之白马西风扇 无相之碧磷野火扇 无相之闭魄 无相之残魂护符 无相之蝶残 无相之东山歌酒环 无相之督亢图穷扇 无相之风檐古道扇 无相之割须弃袍扇 无相之鬼雾护肩 无相之鬼雾护手 无相之鬼雾履 无相之鬼雾帽 无相之鬼雾腕 无相之鬼雾腰环 无相之鬼雾裘 无相之国士无双轮 无相之黄泉 无相之混元无极圈 无相之九捻 无相之连决护符 无相之连影夺目 无相之炼鸾帽 无相之炼鸾圣肩 无相之炼鸾仙履 无相之炼鸾仙腕 无相之炼鸾仙裘 无相之裂戒护符 无相之烈火淬金环 无相之满月 无相之末路 无相之皮麟护肩 无相之皮麟护手 无相之皮麟帽 无相之皮麟腕 无相之皮麟裘 无相之三清 无相之韶华护肩 无相之韶华护手 无相之韶华履 无相之韶华帽 无相之韶华腕 无相之韶华裘 无相之水漫声 无相之宿忧 无相之太乙阴阳环 无相之湘妃斑竹扇 无相之瑶仙护肩 无相之瑶仙护手 无相之瑶仙履 无相之瑶仙帽 无相之瑶仙腰环 无相之瑶仙裘 无相之易水寒林扇 无相之银皮护肩 无相之银皮护手 无相之银皮履 无相之银皮帽 无相之银皮腕 无相之银皮腰环 无相之银皮裘 无相之银霄护肩 无相之银霄护手 无相之银霄履 无相之银霄帽 无相之银霄皮带 无相之银霄腕 无相之银霄裘 无相之幽仙 无相之玉楼春 无相之云归护符 无相之枕霜寝露环 无相之狻猊 无相之狻猊护手 无相之狻猊帽 无相之狻猊魔腕 无相之狻猊圣肩 无相之狻猊圣履 无相之狻猊天裘 无相之彗星袭月轮 无相之魅蛟护手 无相之魅蛟帽 无相之魅蛟圣肩 无相之魅蛟圣腕 无相之魅蛟圣裘 无涯八荒肩 无涯腰环 无涯之苍 无涯之穹 无忧之护 无忧之肩 无忧之腕 无魅手甲 无魅羽盔 无魅羽靴 无魅羽铠 五行繁丝腕 五行繁丝鞋 五行腰带 五行之荧 五行之月 夕颜护腕 夕颜之环 夕颜之戒 犀角迅弩 夏弗环 仙武带 相之狻猊魔腕 镶玉扇 湘妃扇 翔龙手套 翔龙鞋 翔龙腰带 翔龙衣 象梨花杖 象血 象牙扇 心云凌雪的祝福 心云凌雪手 心云凌雪首 心云之暮 心云之影 心瀚护膀 心瀚之尘 心瀚之风 心瀚之涟 行云逐月手 行云逐月首 行云逐月鞋 行云逐月之生灵 凶陌圣甲 玄光雷煞护符 玄光雷煞护手 玄光雷煞帽 玄光雷煞帽粗制棉布 玄光雷煞鞋 玄光雷煞指环 玄狐护手 玄狐履 玄狐帽 玄狐裘 玄机冥天冠 玄机冥天袍 玄机冥天手 玄机冥天鞋 玄明耀辰护符 玄明耀辰护手 玄明耀辰帽 玄明耀辰鞋 玄明耀辰指环 玄擎金刚符 玄擎金刚戒 玄擎金刚链 玄擎金刚靴 玄擎内甲 玄铁铠 玄宇风戒 玄宇风帽 玄宇风衣 玄宇护符 玄宇护手 玄羽圣肩 玄羽圣巾 玄羽圣腕 玄羽圣靴 玄羽圣衣 玄羽手套 雪月拈花带 雪月拈花腕 雪月之环 雪月之兰 血火剑 血刃护符 血刃护腕 血刃戒指 血刃腰带 血玉带 炎日熔火肩 炎日熔火之环 炎日焰火之环 炎日之灵 炎日之韵 雁翎枪 雁翎弩 阴阳剑 阴阳灵杖 银环蛇 银蛇枪 银丝手套 饮血枪 影岚护符 映月如玉戒 幽情泪 幽冥冠 幽冥环 游龙爆火肩 游龙剑 游龙腰环 游龙之朽 游龙之吟 游龙之闵 玉女腰环 玉女咏月冠 玉女咏月手 玉女咏月腕 玉女之百裂戒指 玉女之博浪双斧 玉女之承影双刀 玉女之淬血双剑 玉女之电光双刀 玉女之蝶残 玉女之归尘双斧 玉女之含光双剑 玉女之虎头飞镰刃 玉女之化血凝碧剑 玉女之混沌 玉女之混沌荒毒之灵动天冠 玉女之金霞带 玉女之九捻 玉女之连决护符 玉女之连影夺目 玉女之裂戒护符 玉女之灵动圣肩 玉女之灵动圣腕 玉女之灵动手套 玉女之灵动天冠 玉女之灵动天靴 玉女之灵动天衣 玉女之六合七星剑 玉女之满月 玉女之棉丝短衫 玉女之棉丝护肩 玉女之棉丝护腕 玉女之棉丝帽 玉女之棉丝手套 玉女之棉丝鞋 玉女之莫问 玉女之蒲布护肩 玉女之蒲布手套 玉女之蒲布腕 玉女之蒲布鞋 玉女之蒲布衣 玉女之奇绝碧灵剑 玉女之青峨冠 玉女之青峨肩 玉女之青峨手套 玉女之青峨腕 玉女之青峨鞋 玉女之青峨衣 玉女之青虹百战剑 玉女之青陌护符 玉女之柔云双剑 玉女之如梦冠 玉女之如梦肩 玉女之如梦锦衣 玉女之如梦手套 玉女之如梦腕 玉女之如梦鞋 玉女之三清 玉女之圣目肩 玉女之圣目帽 玉女之圣目手套 玉女之圣目腕 玉女之圣目鞋 玉女之圣目衣 玉女之霜华青光剑 玉女之水漫声 玉女之四海冠 玉女之四海肩 玉女之四海锦服 玉女之四海手套 玉女之四海腕 玉女之四海鞋 玉女之苏锦肩 玉女之苏锦帽 玉女之苏锦手套 玉女之苏锦腕 玉女之苏锦鞋 玉女之苏锦衣 玉女之宿忧 玉女之天皇苍龙刀 玉女之巫山箍环 玉女之幽仙 玉女之玉楼春 玉女之招财腰带 玉女之真丝长衫 玉女之真丝护肩 玉女之真丝护腕 玉女之真丝帽 玉女之真丝手套 玉女之真丝鞋 玉女之镇世 玉女之鸾 御赐精钢甲 御赐精钢手甲 御赐精钢束带 御赐精钢靴 浴火手套 浴火天冠 浴火天肩 浴火天腕 浴火天靴 浴火天衣 月色盔 月色手甲 月色靴 月色铠 月铁手甲 月铁靴 月牙铲 月牙戟 云背弩 云鹿迅弩 云缅链 云灭护符 斩龙塑铁肩 斩龙之荒 斩龙之默 斩龙之影 斩情玄魅护腕 斩情之魄 斩情之冥 斩情之魅 折梅护符 折梅云龙首 折梅之慑 折铁刀 真水指环 诛仙翠竹手 诛仙翠竹首 诛仙翠竹腕 诛仙腰带 诛仙之翠 纵横之辰宿流转杖 纵横之大日昭昭杖 纵横之朗月清辉杖 纵横之天地长春杖 纵横之玉霄 纵横之云寒霜雪杖 岚布肩 岚布手套 岚布腕 岚布衣 逍遥环 逍遥靴 婵娟护手 绫罗帽 绫罗手套 绫罗鞋 绫罗衣 殇阙甲 殇阙盔 殇阙手甲 殇阙靴 虔心护手 蜃楼护手 蜃楼帽 蜃楼袍 蜃楼鞋 翡翠项链 貂皮护手 貂皮履 貂皮帽 貂皮裘 鎏金杖 鎏金弩 鲲鹏哀伤之甲 鲲鹏哀伤之盔 鲲鹏哀伤之手 鲲鹏哀伤之鞋 麟暮赤冠 麟暮赤履 麟暮赤手 麟暮赤裘 "
end

function ParsePrivateItem(aItemText)
  local tItem = {}
  if type(aItemText) == "string" then
    local tStr = SplitString(aItemText, " ", true)
    for i = 1, #tStr do
      local tmp = tStr[i]
      local nBind = 0
      if string.find(tmp, "[不绑]", nil, true) then
        nBind = 1
      end
      if string.find(tmp, "[绑定]", nil, true) then
        nBind = 2
      end
      local strText = string.gsub(tmp, "%[不绑%]", "")
      strText = string.gsub(strText, "%[绑定%]", "")
      strText = string.gsub(strText, " ", "")
      if #strText < 20 then
        table.insert(tItem, {text = strText, data = nBind})
      end
    end
  end
  return tItem
end

function IsUnXiaoHuiItem(aItemName)
  if not g_config.item.un_xiaohui or #g_config.item.un_xiaohui < 3 then
    return false
  end
  if string.find(g_config.item.un_xiaohui, " " .. aItemName .. " ", nil, true) then
    return true
  end
  return false
end

function IsXiaoHuiBaiMingDan(aItem)
  local isBai = false
  if IsUnXiaoHuiItem(aItem.name) then
    isBai = true
  elseif 1 == aItem.itemType then
    if g_config.item.un_xhwq and string.find(" 刀斧类 枪棒类 单短类 双短类 扇类 环类 弩类 长杖类 箫剑类 刀组类 ", " " .. aItem.class .. " ", nil, true) and aItem.level >= g_config.item.un_xhwq_min and aItem.level <= g_config.item.un_xhwq_max then
      isBai = true
    end
    if false == isBai and g_config.item.un_xhms then
      for i = 1, #g_config.item.un_xhms do
        local tmp = g_config.item.un_xhms[i]
        if #tmp > 0 and string.find(aItem.desc, tmp, nil, true) then
          isBai = true
          break
        end
      end
    end
  end
  return isBai
end

function Bag_DeleteAction(aDeleteAction, aOtherName, aItemObj, aWhere)
  aOtherName = aOtherName or ""
  aOtherName = HandleText_AddFuHao(aOtherName, " ", true)
  local delete_count = 0
  if g_config.item.changyong_destroy then
    aOtherName = aOtherName .. Bag:GetChangYongDestroyItem()
  end
  local tBag = aItemObj or Bag:EnumAllObj()
  for i = 1, #tBag do
    local tmpBag = tBag[i]
    local checkNext = true
    if IsFuScriptThread() and tmpBag.name == "扒鸡" then
      checkNext = false
    end
    if IsXiaoHuiBaiMingDan(tmpBag) then
      checkNext = false
    end
    if checkNext and string.find(aOtherName, " " .. tmpBag.name .. " ", nil, true) and Bag:CanSaleDestroy_base(tmpBag, aWhere) then
      if aDeleteAction then
        aDeleteAction(tmpBag)
      end
      delete_count = delete_count + 1
      checkNext = false
    end
    if checkNext and 6 == tmpBag.itemType and 9 ~= tmpBag.childType and 0 == tmpBag.level and (g_config.item.znzblv_all_destroy or g_config.item.znzblv_destroy and 1 == tmpBag.bind) and Bag:InfantEqui_lv(tmpBag.name) then
      if aDeleteAction then
        aDeleteAction(tmpBag)
      end
      delete_count = delete_count + 1
      checkNext = false
    end
    if checkNext then
      for j = 1, #g_config.item.destroy.class do
        local tmpClass = g_config.item.destroy.class[j]
        if tmpBag.class == tmpClass.text then
          if (0 == tmpClass.data or 1 == tmpClass.data and 0 == tmpBag.bind or 2 == tmpClass.data and 1 == tmpBag.bind) and Bag:CanSaleDestroy(tmpBag, aWhere) then
            if aDeleteAction then
              aDeleteAction(tmpBag)
            end
            delete_count = delete_count + 1
            checkNext = false
          end
          break
        end
      end
    end
    if checkNext then
      for j = 1, #g_config.item.destroy.name do
        local tmpName = g_config.item.destroy.name[j]
        if tmpBag.name == tmpName.text then
          if (0 == tmpName.data or 1 == tmpName.data and 0 == tmpBag.bind or 2 == tmpName.data and 1 == tmpBag.bind) and Bag:CanSaleDestroy(tmpBag, aWhere) then
            if aDeleteAction then
              aDeleteAction(tmpBag)
            end
            delete_count = delete_count + 1
            checkNext = false
          end
          break
        end
      end
    end
    if checkNext then
      local tTemp = ParsePrivateItem(g_config.item.private_destroy)
      for j = 1, #tTemp do
        local tmpName = tTemp[j]
        if tmpBag.name == tmpName.text then
          if (0 == tmpName.data or 1 == tmpName.data and 0 == tmpBag.bind or 2 == tmpName.data and 1 == tmpBag.bind) and Bag:CanSaleDestroy(tmpBag, aWhere) then
            if aDeleteAction then
              aDeleteAction(tmpBag)
            end
            delete_count = delete_count + 1
            checkNext = false
          end
          break
        end
      end
    end
  end
  return delete_count
end

function Bag_DeleteBagItem(aOtherName, aBagItem, aMustCheckMiBao)
  if not IsValidConfig(true) then
    return
  end
  if not CheckMibao(aMustCheckMiBao) then
    return
  end
  
  local function delete_action(_ItemInfo)
    if 1 == _ItemInfo.bind then
      PushColorMsg("清理：绑定 %s", _ItemInfo.name)
    else
      PushColorMsg("清理：不绑 %s", _ItemInfo.name)
    end
    if IsFuScriptThread() then
      local nLastTime = GetLuaValue("return g_packup_time_zs", "n")
      if os.time() - nLastTime < 10 then
        PushColorMsg("10秒内整理过背包,暂不清理")
        return
      end
    end
    Sleep(100)
    local tBag = Bag:EnumAllObj()
    for i = 1, #tBag do
      local tmp = tBag[i]
      if tmp.index == _ItemInfo.index then
        if tmp.name == _ItemInfo.name then
          DiscardBagItem(_ItemInfo.index, 200)
          break
        end
        PushColorMsg("清理：%s时名称不匹配%s", _ItemInfo.name, tmp.name)
        Log("清理时名称不匹配 " .. _ItemInfo.name .. " " .. tmp.name)
        break
      end
    end
  end
  
  return Bag_DeleteAction(delete_action, aOtherName, aBagItem, 1)
end

function Bag_DeleteTempBagItem(aOtherName)
  if not IsValidConfig(false) then
    return
  end
  if not CheckMibao(false) then
    return
  end
  local tBag = Bag:EnumTempBagItem()
  
  local function delete_action(_ItemInfo)
    PushColorMsg("清理锦囊：%s", _ItemInfo.name)
    if IsFuScriptThread() then
      local nLastTime = GetLuaValue("return g_packup_time_zs", "n")
      if os.time() - nLastTime < 10 then
        PushColorMsg("10秒内整理过背包锦囊,暂不清理")
        return
      end
    end
    Sleep(100)
    local _tBag = Bag:EnumTempBagItem()
    for i = 1, #_tBag do
      local tmp = _tBag[i]
      if tmp.index == _ItemInfo.index then
        if tmp.name == _ItemInfo.name then
          DiscardTempBagItem(_ItemInfo.index, 200)
          break
        end
        PushColorMsg("清理锦囊：%s时名称不匹配%s", _ItemInfo.name, tmp.name)
        Log("清理锦囊时名称不匹配 " .. _ItemInfo.name .. " " .. tmp.name)
        break
      end
    end
  end
  
  return Bag_DeleteAction(delete_action, aOtherName, tBag, 2)
end

function Bag_DeleteItem(aMustCheckMiBao)
  if CheckMibao(aMustCheckMiBao) then
    Bag_DeleteBagItem()
    Bag_DeleteTempBagItem()
    EatBindItem(10)
    Bag_DeleteTempBagItem()
  end
end

function NpcShop_CheckPos(aToSceneSceneName, aIsPetShop)
  Player:TeamFollow(false, 300)
  local szToSceneName = aToSceneSceneName or GetCurrentSceneName()
  szToSceneName = string.gsub(szToSceneName, "1线", "")
  szToSceneName = string.gsub(szToSceneName, "2线", "")
  if IsKVKSceneName(szToSceneName) then
    szToSceneName = "凤鸣镇"
  end
  local tShopNPC = Bag:GetShopNPC(aIsPetShop)
  local tNPC = GetTableFieldValue(tShopNPC, "sceneName", {szToSceneName})
  if 0 == #tNPC then
    local nTar = GetSceneMainBranch(GetSceneID())
    if 1 == nTar then
      tNPC = GetTableFieldValue(tShopNPC, "sceneName", {"苏州"})
    elseif 2 == nTar then
      tNPC = GetTableFieldValue(tShopNPC, "sceneName", {"大理"})
    elseif 246 == nTar then
      tNPC = GetTableFieldValue(tShopNPC, "sceneName", {"楼兰"})
    else
      tNPC = GetTableFieldValue(tShopNPC, "sceneName", {"洛阳"})
    end
  end
  local npc = {}
  if #tNPC > 0 then
    local tPos = GetAllPosDist(tNPC, nil, "dist")
    BubbleByDist(tPos)
    npc = tPos[1]
    local bUseShouFeiNPC = true
    local bUseDWF = false
    if npc.sceneID == 850 or npc.sceneID == 762 or npc.sceneID == 772 or npc.sceneID == 773 then
      bUseShouFeiNPC = false
      bUseDWF = false
    end
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, nil, bUseShouFeiNPC, bUseDWF)
    Sleep(600)
    if npc.option and "" ~= npc.option then
      QuestFrameOptionClicked_Item(npc.option, 1, 1000)
    end
  else
    PushColorMsg("NpcShop_CheckPos 计算坐标错误！")
  end
end

function Bank_CheckBankPos(aToSceneSceneName, aUseVip)
  Player:TeamFollow(false, 300)
  CloseWindow("Exchange")
  if IsWindowVisible("BigBank") then
    return
  end
  if aUseVip then
    local nLevel = GetPlayerVipLevel()
    if 8 == nLevel or 9 == nLevel then
      PushColorMsg("VIP8、9使用随身银行")
      GetLuaValue([[
            	Clear_XSCRIPT()
		            Set_XSCRIPT_Function_Name("OnUseVIP")
		            Set_XSCRIPT_ScriptID(889644)
		            Set_XSCRIPT_Parameter(0, 2)
		            Set_XSCRIPT_ParamCount(1)
	            Send_XSCRIPT()    
            ]])
      Sleep(1500)
      return
    end
  end
  local szToSceneName = aToSceneSceneName or GetCurrentSceneName()
  szToSceneName = string.gsub(szToSceneName, "1线", "")
  szToSceneName = string.gsub(szToSceneName, "2线", "")
  if IsKVKSceneName(szToSceneName) then
    szToSceneName = "凤鸣镇"
  end
  local tNpc_Bank = {}
  tNpc_Bank = {
    {
      x = 347,
      y = 248,
      name = "卫先生",
      sceneName = "洛阳",
      sceneID = LUOYANG_ID
    },
    {
      x = 191,
      y = 299,
      name = "褚先生",
      sceneName = "洛阳",
      sceneID = LUOYANG_ID
    },
    {
      x = 187,
      y = 279,
      name = "严伙计",
      sceneName = "苏州",
      sceneID = 1
    },
    {
      x = 343,
      y = 246,
      name = "梁伙计",
      sceneName = "苏州",
      sceneID = 1
    },
    {
      x = 217,
      y = 174,
      name = "何伙计",
      sceneName = "大理",
      sceneID = 2
    },
    {
      x = 219,
      y = 122,
      name = "庞伙计",
      sceneName = "楼兰",
      sceneID = 246
    },
    {
      x = 265,
      y = 118,
      name = "钱先生",
      sceneName = "凤鸣镇",
      sceneID = 850
    },
    {
      x = 338,
      y = 351,
      name = "钱先生",
      sceneName = "金陵",
      sceneID = 762
    },
    {
      x = 338,
      y = 351,
      name = "钱先生",
      sceneName = "金陵2线",
      sceneID = 772
    },
    {
      x = 338,
      y = 351,
      name = "钱先生",
      sceneName = "金陵3线",
      sceneID = 773
    }
  }
  local run = tNpc_Bank[5]
  if "洛阳" == szToSceneName or "钱庄" == szToSceneName or "雁南" == szToSceneName or "嵩山" == szToSceneName or "敦煌" == szToSceneName then
    run = tNpc_Bank[1]
    if GetCurrentSceneName() == "洛阳" and GetDist(tNpc_Bank[2].x, tNpc_Bank[2].y) < GetDist(tNpc_Bank[1].x, tNpc_Bank[1].y) then
      run = tNpc_Bank[2]
    end
  elseif "苏州" == szToSceneName or "太湖" == szToSceneName or "西湖" == szToSceneName then
    run = tNpc_Bank[3]
    if GetCurrentSceneName() == "苏州" and GetDist(tNpc_Bank[4].x, tNpc_Bank[4].y) < GetDist(tNpc_Bank[3].x, tNpc_Bank[3].y) then
      run = tNpc_Bank[4]
    end
  elseif "大理" == szToSceneName then
    run = tNpc_Bank[5]
  elseif "楼兰" == szToSceneName then
    run = tNpc_Bank[6]
  elseif "凤鸣镇" == szToSceneName then
    run = tNpc_Bank[7]
  elseif "金陵" == szToSceneName then
    run = tNpc_Bank[8]
  elseif "金陵2线" == szToSceneName then
    run = tNpc_Bank[9]
  elseif "金陵3线" == szToSceneName then
    run = tNpc_Bank[10]
  end
  local bUseShouFeiNPC = true
  local bUseDWF = true
  if run.sceneID == 850 or run.sceneID == 762 or run.sceneID == 772 or run.sceneID == 773 then
    bUseShouFeiNPC = false
    bUseDWF = false
  end
  GoToSceneNPC(run.name, run.x, run.y, run.sceneID, nil, nil, nil, nil, bUseShouFeiNPC, bUseDWF)
  Sleep(600)
  QuestFrameOptionClicked_Item("打开银行", 1, 700)
end

function Bank_GetItemPos(aItem)
  local item = aItem
  return item.index % 20 + 1
end

function Bank_TakeOutItemAction(tItem, aNotTakeOut)
  if false == aNotTakeOut then
    PushDebugMessage("仓库取出：" .. tItem.name)
    local itempPos = Bank_GetItemPos(tItem)
    GetLuaValue(fmt([[
                    setmetatable(_G, {__index = BigBank_Env})
                    if this:IsVisible() then
                        BigBank_Item%d_%d:DoAction()
                    end
                ]], tItem.boxIndex, itempPos))
    Sleep(150)
  end
end

function Bank_TakeOutItem(aItemName, aTakeNum, aBindState, aLockState, aNotTakeOut, aBankCallback)
  aItemName = HandleText_AddFuHao(aItemName, " ")
  local nTakeCnt = 0
  local nRealCnt = 0
  local tAllItem = Bag:EnumBankItem()
  local tBank = {}
  if 1 == aBindState then
    tBank = Bag:EnumUnBindItem(nil, tAllItem)
  elseif 2 == aBindState then
    tBank = Bag:EunmBindItem(nil, tAllItem)
  else
    tBank = tAllItem
  end
  if 1 == aLockState then
    tBank = DeleteTableFieldValue(tBank, "lock", {1})
  end
  for i = 1, #tBank do
    local tmp = tBank[i]
    if aBankCallback and false == aBankCallback() then
      break
    end
    if string.find(aItemName, " " .. tmp.name .. " ", nil, true) then
      Bank_TakeOutItemAction(tmp, aNotTakeOut)
      nTakeCnt = nTakeCnt + 1
      nRealCnt = nRealCnt + tmp.count
    elseif string.find(aItemName, " " .. tmp.class .. " ", nil, true) and tmp.class ~= "藏宝图" then
      Bank_TakeOutItemAction(tmp, aNotTakeOut)
      nTakeCnt = nTakeCnt + 1
      nRealCnt = nRealCnt + tmp.count
    elseif 5 == tmp.itemType and string.find(aItemName, " 所有宝石 ", nil, true) then
      Bank_TakeOutItemAction(tmp, aNotTakeOut)
      nTakeCnt = nTakeCnt + 1
      nRealCnt = nRealCnt + tmp.count
    elseif tmp.class == "子女装备" and string.find(aItemName, " 子女装备 ", nil, true) then
      Bank_TakeOutItemAction(tmp, aNotTakeOut)
      nTakeCnt = nTakeCnt + 1
      nRealCnt = nRealCnt + 1
    elseif 7 == tmp.itemType and string.find(aItemName, " 珍兽装备 ", nil, true) and 75 == tmp.level and 1 == tmp.xing then
      Bank_TakeOutItemAction(tmp, aNotTakeOut)
      nTakeCnt = nTakeCnt + 1
      nRealCnt = nRealCnt + 1
    end
    if aTakeNum > 0 and aTakeNum <= nRealCnt then
      break
    end
  end
  return nRealCnt
end

function Bank_EnumItem(aMustRefresh)
  local tBankItem = Bag:EnumBankItem()
  if 0 == #tBankItem or aMustRefresh then
    Bank_CheckBankPos(nil, true)
    local nLastTick = GetTickCount()
    while true do
      if IsWindowVisible("BigBank") then
        tBankItem = Bag:EnumBankItem()
        break
      elseif IsWindowVisible("Bank") then
        GetLuaValue("setmetatable(_G, {__index=Bank_Env});PushEvent(\"TOGLE_BIGBANK\", Bank:GetNpcId());this:Hide();Bank:SetOpenWhichBank(1)")
        Sleep(800)
      else
        Bank_CheckBankPos(nil, true)
      end
      if GetTickCount() - nLastTick > 5000 then
        PushDebugMessage("获取仓库物品:超时")
        break
      end
      if IsInFubenScene() then
        PushColorMsg("仓库遍历：当前为副本地图！")
        break
      end
      Sleep(100)
      DebugStr("获取仓库物品")
    end
    CloseAllWindow()
  end
  if 0 == #tBankItem then
    tBankItem = Bag:EnumBankItem()
  end
  return tBankItem
end

function Bank_GetItem(aItemName, aGetNum, aBindState, aLockState, aPackUpBag, aCallBack)
  aGetNum = aGetNum or -1
  aBindState = aBindState or 0
  aLockState = aLockState or 0
  local nGetCnt = 0
  local isTimeOut = false
  if "" == aItemName then
    return nGetCnt, isTimeOut
  end
  Bag_DeleteItem()
  if aPackUpBag then
    Bag:PackUp(-1)
  end
  local tAllItem = Bag:EnumBankItem()
  if #tAllItem > 0 then
    local canGet = Bank_TakeOutItem(aItemName, -1, aBindState, aLockState, true, nil)
    if 0 == canGet then
      PushColorMsg("仓库取物：仓库没有需要取出的物品")
      return nGetCnt, isTimeOut
    end
  end
  Bank_CheckBankPos(nil, true)
  local nLastTick = GetTickCount()
  local wait_tick = 30000
  if IsUnLockMibao() == false then
    wait_tick = 1000
  end
  while true do
    if IsWindowVisible("BigBank") then
      nGetCnt = Bank_TakeOutItem(aItemName, aGetNum, aBindState, aLockState, false, aCallBack)
      Sleep(300)
      break
    elseif IsWindowVisible("Bank") then
      GetLuaValue("setmetatable(_G, {__index=Bank_Env});PushEvent(\"TOGLE_BIGBANK\", Bank:GetNpcId());this:Hide();Bank:SetOpenWhichBank(1)")
      Sleep(800)
    else
      Bank_CheckBankPos(nil, true)
    end
    if wait_tick < GetTickCount() - nLastTick then
      PushDebugMessage("仓库取物:超时!可能密保验证没过")
      isTimeOut = true
      break
    end
    if IsInFubenScene() then
      PushColorMsg("仓库取物：当前为副本地图！")
      break
    end
    DebugStr("仓库取物中...")
    Sleep(200)
  end
  if aPackUpBag then
    Bag:PackUp(-1)
  end
  CloseAllWindow()
  return nGetCnt, isTimeOut
end

function Bank_SaveOnAction(aItemName, aBindState)
  aBindState = aBindState or 2
  local bIsHave = false
  local tSearch = Bag:SearchItem(aItemName)
  for i = 1, #tSearch do
    local tmp = tSearch[i]
    if 0 == aBindState or 0 == tmp.bind and 1 == aBindState or 1 == tmp.bind and 2 == aBindState then
      bIsHave = true
      Bag:ItemBtnClicked(tmp.index)
      Sleep(300)
    end
    if not IsWindowVisible("BigBank") then
      break
    end
  end
  return bIsHave
end

function Bank_GetBankMoney()
  local nMoneyAll = GetLuaValue("local nMoneyAll, nGoldCoin, nSilverCoin, nCopperCoin = Bank:GetBankMoney() return nMoneyAll", "s")
  return tonumber(nMoneyAll) or 0
end

function Bank_GetMoney(aGetMoney, aToSceneName)
  if aGetMoney > 0 and aGetMoney <= Player:GetMoney() then
    return true
  end
  if not IsWindowVisible("BigBank") and not IsWindowVisible("Bank") then
    local bUseVip = true
    if not IsSafeSceneID() then
      PushColorMsg("仓库取钱：当前地图不安全")
      bUseVip = false
    end
    Bank_CheckBankPos(aToSceneName, bUseVip)
  end
  local nLastTick = GetTickCount()
  while true do
    if IsWindowVisible("BigBank") or IsWindowVisible("Bank") then
      if aGetMoney > 0 then
        local nGet = aGetMoney - Player:GetMoney()
        local strText = fmt([[
                        local nMoney = %s
                        local nMoneyAll, nGoldCoin, nSilverCoin, nCopperCoin = Bank:GetBankMoney()
                        if nMoney > nMoneyAll then
                            nMoney = nMoneyAll
                        end
                        if nMoney > 0 then
                            Bank:GetMoneyFromBank(nMoney)
                        else
                            return 0
                        end
                        return 1
                    ]], nGet)
        if 0 == GetLuaValue(strText, "n") then
          break
        end
        Sleep(1000)
      elseif aGetMoney < 0 then
        local strText = fmt([[
                        local nMoney = %s
                        local nMoneyAll,nGoldCoin,nSilverCoin,nCopperCoin = Bank:GetBankMoney();
                        local nNeed = nMoneyAll + nMoney
                        if nNeed > 0 then 
                            Bank:GetMoneyFromBank(nNeed); 
                            return 1 
                        else 
                            return 0 
                        end
                    ]], aGetMoney)
        local nRet = GetLuaValue(strText, "n")
        if 0 == nRet then
          break
        end
      else
        DebugStr("取金币参数为0", 2)
      end
    else
      Bank_CheckBankPos(aToSceneName, true)
    end
    if aGetMoney > 0 and aGetMoney <= Player:GetMoney() then
      break
    end
    if IsInFubenScene() then
      PushColorMsg("仓库存钱：当前为副本地图！")
      break
    end
    if GetTickCount() - nLastTick > 15000 then
      PushDebugMessage("仓库取钱:超时!可能密保验证没过或金币不够")
      break
    end
    Sleep(1000)
    DebugStr("仓库取钱中")
  end
  if aGetMoney > 0 then
    if aGetMoney <= Player:GetMoney() then
      return true
    else
      return false
    end
  end
  return true
end

function Bank_SaveMoney(aKeepTong)
  aKeepTong = aKeepTong or 0
  local old_money = Player:GetMoney()
  if aKeepTong >= old_money then
    return
  end
  if not IsWindowVisible("BigBank") and not IsWindowVisible("Bank") then
    Bank_CheckBankPos(nil, true)
  end
  local nLastTick = GetTickCount()
  while true do
    if IsWindowVisible("BigBank") or IsWindowVisible("Bank") then
      local nSave = Player:GetMoney() - aKeepTong
      GetLuaValue(fmt("Bank:SaveMoneyToBank(%s);", nSave))
      Sleep(1000)
    else
      Bank_CheckBankPos(nil, true)
    end
    if aKeepTong >= Player:GetMoney() then
      break
    end
    if GetTickCount() - nLastTick > 15000 then
      PushDebugMessage("仓库存钱:超时!可能密保验证没过")
      break
    end
    if IsInFubenScene() then
      PushColorMsg("仓库存钱：当前为副本地图！")
      break
    end
    DebugStr("仓库存钱中")
    Sleep(200)
  end
  local nSave = old_money - Player:GetMoney()
  PushColorMsg("银行存钱：本次存入 %.2f 金", nSave / 10000)
  CloseAllWindow()
end

function Bank_SaveItem(aItemName, aKeepMoney, aBindState, aUnCloseWindow)
  if type(aItemName) ~= "string" or "" == aItemName then
    return
  end
  Bag:PackUp(-1)
  aItemName = HandleText_AddFuHao(aItemName)
  aKeepMoney = aKeepMoney or -1
  local tSearch = Bag:SearchItem(aItemName)
  if 0 == #tSearch then
    return
  end
  Bank_CheckBankPos(nil, true)
  local nLastTick = GetTickCount()
  local wait_tick = 45000
  if IsUnLockMibao() == false then
    wait_tick = 8000
  end
  local bIsHave = true
  DeleteDebugMsg("目标箱子已经满了")
  while true do
    if IsWindowVisible("BigBank") then
      bIsHave = Bank_SaveOnAction(aItemName, aBindState)
      if not g_config.tysz.un_bank_packup then
        GetLuaValue("setmetatable(_G, {__index = BigBank_Env});BigBank_PackUp_Clicked();")
      end
      if aKeepMoney >= 0 then
        Bank_SaveMoney(aKeepMoney)
      end
    elseif IsWindowVisible("Bank") then
      GetLuaValue("setmetatable(_G, {__index=Bank_Env});PushEvent(\"TOGLE_BIGBANK\", Bank:GetNpcId());this:Hide();Bank:SetOpenWhichBank(1)")
      Sleep(800)
    else
      Bank_CheckBankPos(nil, true)
    end
    if not bIsHave then
      break
    end
    if IsInDebugMsg("目标箱子已经满了") then
      PushColorMsg("仓库存物：仓库已满！")
      break
    end
    if IsUnLockMibao() == false then
      PushColorMsg("仓库存物：您还未解锁密保！")
      break
    end
    if wait_tick < GetTickCount() - nLastTick then
      PushDebugMessage("仓库存物:超时!可能密保验证没过")
      break
    end
    if IsInFubenScene() then
      PushColorMsg("仓库存物：当前为副本地图！")
      break
    end
    DebugStr("仓库存物品中")
    Sleep(200)
  end
  Bag:PackUp(-1)
  if aUnCloseWindow then
  else
    CloseAllWindow()
  end
end

function EatFubenItem(aCount)
  local bEat = false
  if IsInDebugMsgTime("#{SJZ_100129_150}", nil, 3600) then
    TempBank2Bag(" 小还丹 ", 2)
    Sleep(500)
    for i = 1, aCount do
      local bRet4 = Bag:UseItem_SP_ext("金玉富贵袋")
      if bRet4 then
        bEat = true
        Sleep(100)
      else
        break
      end
    end
  else
    TempBank2Bag(" 小力丹 地力丹 天力丹 小还丹 ", 2)
    Sleep(500)
    for i = 1, aCount do
      local bRet1 = Bag:UseItem_SP_ext("小力丹")
      local bRet2 = Bag:UseItem_SP_ext("地力丹")
      local bRet3 = Bag:UseItem_SP_ext("天力丹")
      local bRet4 = Bag:UseItem_SP_ext("金玉富贵袋")
      if bRet1 or bRet2 or bRet3 or bRet4 then
        bEat = true
        Sleep(100)
      else
        break
      end
    end
  end
  Bag:LuaUseItem_DJ(" 小还丹 ", 2)
  return bEat
end

function OpenBindItem(aUseCount)
  local bHave = false
  aUseCount = aUseCount or 20
  DeleteDebugMsg("#{XZJC_200309_112}")
  DeleteDebugMsg("#{XZYX_200309_30}")
  DeleteDebugMsg("#{XZYX_200309_31}")
  DeleteDebugMsg("#{XZJC_200309_279}")
  for i = 1, aUseCount do
    local bHasXinJue = false
    local tBag = Bag:EnumDaoJuItem()
    for j = 1, #tBag do
      local tmp = tBag[j]
      if 1 == tmp.bind and 0 == tmp.lock then
        if not IsInDebugMsg("#{XZJC_200309_279}") and tmp.class == "心诀道具" then
          if tmp.name == "良品残印集录" or tmp.name == "精品残印集录" or tmp.name == "良品心诀集录" or tmp.name == "精品心诀集录" or tmp.name == "残印集录·良" or tmp.name == "心诀集录·良" or tmp.name == "残印集录·珍" or tmp.name == "心诀集录·珍" or not string.find(tmp.name, "集录", nil, true) then
            bHasXinJue = true
            Bag:UseItem(tmp.index, 100)
          end
        elseif not IsInDebugMsg("#{XZYX_200309_30}") and not IsInDebugMsg("#{XZYX_200309_31}") and (tmp.name == "良品礼扎" or tmp.name == "精品礼扎" or tmp.name == "珍品礼扎" or string.find(tmp.name, "名士还礼", nil, true)) then
          bHasXinJue = true
          Bag:UseItem(tmp.index, 100)
        end
        if IsInDebugMsg("#{XZJC_200309_112}") then
          break
        end
      end
      IsWindowVisible("Item_MultiUse", "Item_MultiUse_BuyMulti_Clicked()")
    end
    if false == bHasXinJue then
      break
    end
    bHave = true
    if IsInDebugMsg("#{XZJC_200309_112}") then
      break
    end
  end
  return bHave
end

function Bag_SellAction(aSellAction, aOtherName, aOtherNameBind, aItemObj)
  aOtherName = aOtherName or ""
  aOtherNameBind = aOtherNameBind or ""
  local sale_count = 0
  local sale_action = aSellAction
  if g_config.item.changyong_sale then
    local strChangYongItem = " 奇物 活跃金币 元丰重宝 元丰通宝 青铜古币 财富银币 熊猫金币 鸿福金币 鸿运金币 巢氏古器皿 签名足球 山海金币 珍宝币 少室山古币 "
    aOtherName = aOtherName .. strChangYongItem
    aOtherName = HandleText(aOtherName)
  end
  local tBag = aItemObj or Bag:EnumAllObj()
  for i = 1, #tBag do
    local tmpBag = tBag[i]
    local checkNext = true
    if "" ~= aOtherName then
      local bSale = false
      if string.find(aOtherName, " " .. tmpBag.name .. " ", nil, true) then
        bSale = true
      elseif string.find(aOtherName, " " .. tmpBag.class .. " ", nil, true) then
        bSale = true
      end
      if bSale then
        if Bag:CanSaleDestroy(tmpBag, 1) then
          if sale_action then
            sale_action(tmpBag)
          end
          sale_count = sale_count + 1
        end
        checkNext = false
      end
    end
    if checkNext and 1 == tmpBag.bind then
      local bSale = false
      if string.find(aOtherNameBind, " " .. tmpBag.name .. " ", nil, true) then
        bSale = true
      elseif string.find(aOtherNameBind, " " .. tmpBag.class .. " ", nil, true) then
        bSale = true
      end
      if bSale then
        if Bag:CanSaleDestroy(tmpBag, 1) then
          if sale_action then
            sale_action(tmpBag)
          end
          sale_count = sale_count + 1
        end
        checkNext = false
      end
    end
    if checkNext then
      for j = 1, #g_config.item.sale.class do
        local tmpClass = g_config.item.sale.class[j]
        if tmpBag.class == tmpClass.text then
          if 0 == tmpClass.data or 1 == tmpClass.data and 0 == tmpBag.bind or 2 == tmpClass.data and 1 == tmpBag.bind then
            if Bag:CanSaleDestroy(tmpBag, 1) then
              if sale_action then
                sale_action(tmpBag)
              end
              sale_count = sale_count + 1
            end
            checkNext = false
          end
          break
        end
      end
    end
    if checkNext then
      for j = 1, #g_config.item.sale.name do
        local tmpName = g_config.item.sale.name[j]
        if tmpBag.name == tmpName.text then
          if 0 == tmpName.data or 1 == tmpName.data and 0 == tmpBag.bind or 2 == tmpName.data and 1 == tmpBag.bind then
            if Bag:CanSaleDestroy(tmpBag, 1) then
              if sale_action then
                sale_action(tmpBag)
              end
              sale_count = sale_count + 1
            end
            checkNext = false
          end
          break
        end
      end
    end
  end
  return sale_count
end

function PacketTempMovePacket(aAsItemName, aAsItemIndex)
  aAsItemName = aAsItemName or ""
  aAsItemIndex = aAsItemIndex or -1
  if "ALL_ITEM" ~= aAsItemName then
    aAsItemName = HandleText(aAsItemName)
    aAsItemName = HandleText_AddFuHao(aAsItemName, " ", true)
  end
  local strText = fmt([[
            local itemName = "%s"
            local itemIndex = %d + 1
  
            local GRID_BUTTONS = {}
            GRID_BUTTONS = {
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element0:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element1:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element2:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element3:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element4:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element5:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element6:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element7:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element8:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element9:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element10:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element11:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element12:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element13:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element14:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element15:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element16:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element17:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element18:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element19:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element20:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element21:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element22:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element23:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element24:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element25:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element26:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element27:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element28:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element29:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element30:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element31:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element32:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element33:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element34:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element35:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element36:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element37:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element38:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element39:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element40:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element41:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element42:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element43:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element44:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element45:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element46:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element47:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element48:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element49:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element50:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element51:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element52:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element53:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element54:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element55:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element56:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element57:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element58:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element59:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element60:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element61:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element62:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element63:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element64:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element65:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element66:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element67:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element68:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element69:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element70:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element71:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element72:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element73:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element74:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element75:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element76:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element77:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element78:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element79:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element80:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element81:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element82:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element83:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element84:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element85:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element86:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element87:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element88:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element89:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element90:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element91:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element92:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element93:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element94:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element95:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element96:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element97:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element98:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element99:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element100:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element101:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element102:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element103:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element104:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element105:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element106:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element107:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element108:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element109:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element110:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element111:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element112:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element113:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element114:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element115:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element116:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element117:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element118:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
                function() setmetatable(_G, {__index = Packet_Temporary_Env});local btn = Packet_Temporary_ActionsList_auto_element119:GetLuaActionButton("Packet_Temporary");btn:DoAction() end,
            }
            local nRet = 0
            if itemIndex >= 1 and itemIndex <= 120 then 
                GRID_BUTTONS[itemIndex]()
                nRet = 1
            elseif itemName ~= "" then
                setmetatable(_G, {__index = Packet_Temporary_Env})   
                for i = 1, 120 do
                    local theAction, bLocked = Bank:EnumTemItem(i - 1)
                    if theAction:GetID() ~= 0 then
                        local szName = theAction:GetName()
                        szName = " " .. szName .. " "
                        if itemName == "ALL_ITEM" or string.find(itemName, szName, nil, true) then                     
                            GRID_BUTTONS[i]()
                            nRet = 1         
                        end
                    end
                end
            end

            return nRet  
        ]], aAsItemName, aAsItemIndex)
  return GetLuaValue(strText, "b")
end

function TempBankSellMove(aOtherItemName, aOtherNameBind)
  local bClose = true
  if IsWindowVisible("Packet_Temporary") then
    bClose = false
  else
    GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_Temporary_BtnClick()")
    Sleep(500)
  end
  local tTempBag = Bag:EnumTempBagItem()
  
  local function move_action(_ItemInfo)
    PacketTempMovePacket(nil, _ItemInfo.index)
    Sleep(100)
  end
  
  local can_sell_count = Bag_SellAction(move_action, aOtherItemName, aOtherNameBind, tTempBag)
  if bClose then
    CloseWindow("Packet_Temporary")
  end
  return can_sell_count
end

function TempBank2BagByIndex(aItemIndex)
  local bClose = true
  if IsWindowVisible("Packet_Temporary") then
    bClose = false
  else
    GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_Temporary_BtnClick()")
    Sleep(500)
  end
  local bHave = false
  bHave = PacketTempMovePacket(nil, aItemIndex)
  if bClose then
    CloseWindow("Packet_Temporary")
  end
  return bHave
end

function TempBank2Bag(aAllItem, aBindState, aTakeNum)
  local itemName = ""
  if aAllItem and "" ~= aAllItem then
    itemName = HandleText_AddFuHao(aAllItem, " ")
  else
    return
  end
  aBindState = aBindState or 0
  aTakeNum = aTakeNum or 0
  local bIsHave = false
  local nTakeCnt = 0
  local nRealCnt = 0
  local bClose = true
  if IsWindowVisible("Packet_Temporary") then
    bClose = false
  end
  local tTempBag = Bag:EnumTempBagItem()
  local tSearch = Bag:SearchItem(itemName, tTempBag)
  for i = 1, #tSearch do
    local tmp = tSearch[i]
    if 0 == aBindState or 0 == tmp.bind and 1 == aBindState or 1 == tmp.bind and 2 == aBindState then
      bIsHave = true
      if not IsWindowVisible("Packet_Temporary") then
        GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_Temporary_BtnClick()")
        Sleep(300)
      end
      PushColorMsg("%s:从锦囊取出到背包", tmp.name)
      PacketTempMovePacket(nil, tmp.index)
      Sleep(50)
      nTakeCnt = nTakeCnt + 1
      nRealCnt = nRealCnt + tmp.count
      if aTakeNum > 0 and aTakeNum <= nRealCnt then
        break
      end
    end
  end
  if bIsHave then
    Sleep(500)
  end
  if bClose then
    CloseWindow("Packet_Temporary")
  end
  return bIsHave
end

function TempBankGetNullPos()
  local tObj = Bag:EnumTempBagItem(true)
  local tNullPos = GetTableFieldValue(tObj, "obj", {0})
  return tNullPos
end

function Bag_MoveAction(aAction, aOtherName, aBindState, aItemObj, aNotWithUserConfig)
  aOtherName = aOtherName or ""
  aBindState = aBindState or 0
  local move_count = 0
  local tBag = aItemObj or Bag:EnumAllObj()
  for i = 1, #tBag do
    local tmpBag = tBag[i]
    local checkNext = true
    if (0 == aBindState or 0 == tmpBag.bind and 1 == aBindState or 1 == tmpBag.bind and 2 == aBindState) and string.find(aOtherName, " " .. tmpBag.name .. " ", nil, true) then
      if aAction and false == aAction(tmpBag) then
        checkNext = false
        break
      end
      move_count = move_count + 1
      checkNext = false
    end
    if not aNotWithUserConfig and checkNext then
      for j = 1, #g_config.item.temp_bag.class do
        local tmpClass = g_config.item.temp_bag.class[j]
        if tmpBag.class == tmpClass.text then
          if 0 == tmpClass.data or 1 == tmpClass.data and 0 == tmpBag.bind or 2 == tmpClass.data and 1 == tmpBag.bind then
            if aAction and false == aAction(tmpBag) then
              checkNext = false
              break
            end
            move_count = move_count + 1
            checkNext = false
          end
          break
        end
      end
    end
    if not aNotWithUserConfig and checkNext then
      for j = 1, #g_config.item.temp_bag.name do
        local tmpName = g_config.item.temp_bag.name[j]
        if tmpBag.name == tmpName.text then
          if 0 == tmpName.data or 1 == tmpName.data and 0 == tmpBag.bind or 2 == tmpName.data and 1 == tmpBag.bind then
            if aAction and false == aAction(tmpBag) then
              checkNext = false
              break
            end
            move_count = move_count + 1
            checkNext = false
          end
          break
        end
      end
    end
  end
  return move_count
end

function Bag_Move2TempBank(aItemName, aBindState, aBagItem, aPackUpBag, aNotWithUserConfig)
  aBindState = aBindState or 0
  
  local function move_action(_ItemInfo)
    local tNullPos = TempBankGetNullPos()
    if #tNullPos > 0 then
      PushColorMsg("%s：移动到锦囊", _ItemInfo.name)
      math.randomseed(GetTickCount())
      local idx = math.random(1, #tNullPos)
      BagBankTempMove(_ItemInfo.index, tNullPos[idx].index, true)
      Sleep(50)
    else
      PushColorMsg("%s：移动到锦囊失败,锦囊需要清理!", _ItemInfo.name)
      return false
    end
    return true
  end
  
  if aItemName and "" ~= aItemName then
    aItemName = HandleText_AddFuHao(aItemName, " ")
  end
  local move_count = Bag_MoveAction(move_action, aItemName, aBindState, aBagItem, aNotWithUserConfig)
  if move_count > 0 then
    if aPackUpBag or nil == aPackUpBag then
      Sleep(300)
      Bag:PackUpTempBag(500)
    end
    local bClose = true
    if IsWindowVisible("Packet_Temporary") then
      bClose = false
    else
      GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_Temporary_BtnClick()")
      Sleep(300)
    end
    if bClose then
      CloseWindow("Packet_Temporary")
    end
  end
  return move_count
end

function GetFubenBox()
  local strItem = ""
  strItem = strItem .. "余毒的宝箱 红熊王的宝箱 葛荣的宝箱 愤怒葛荣的宝箱 余毒的宝藏 红熊王的宝藏 葛荣的宝藏 愤怒葛荣的宝藏 "
  strItem = strItem .. "巽藏宝箱 震藏宝箱 坤藏宝箱 乾藏宝箱 "
  strItem = strItem .. "巽藏宝箱·遗 震藏宝箱·遗 坤藏宝箱·遗 乾藏宝箱·遗 "
  strItem = strItem .. "巽藏宝箱·损 震藏宝箱·损 坤藏宝箱·损 乾藏宝箱·损 "
  strItem = strItem .. "巽藏宝藏 震藏宝藏 坤藏宝藏 乾藏宝藏 "
  strItem = strItem .. "巽藏宝藏·遗 震藏宝藏·遗 坤藏宝藏·遗 乾藏宝藏·遗 "
  strItem = strItem .. "巽藏宝藏·损 震藏宝藏·损 坤藏宝藏·损 乾藏宝藏·损 "
  strItem = strItem .. "哈大霸的宝匣 桑土公的宝匣 乌老大的宝匣 任平生的宝匣 李秋水的宝匣 "
  strItem = strItem .. "哈大霸的宝盒 桑土公的宝盒 乌老大的宝盒 任平生的宝盒 李秋水的宝盒 "
  strItem = strItem .. "哈大霸的宝盒·遗 桑土公的宝盒·遗 乌老大的宝盒·遗 任平生的宝盒·遗 李秋水的宝盒·遗 "
  strItem = strItem .. "哈大霸的宝箱 桑土公的宝箱 乌老大的宝箱 任平生的宝箱 李秋水的宝箱 "
  strItem = strItem .. "哈大霸的宝箱·遗 桑土公的宝箱·遗 乌老大的宝箱·遗 任平生的宝箱·遗 李秋水的宝箱·遗 "
  strItem = strItem .. "哈大霸的宝箱·旧 桑土公的宝箱·旧 乌老大的宝箱·旧 任平生的宝箱·旧 李秋水的宝箱·旧 "
  strItem = strItem .. "哈大霸的宝藏 桑土公的宝藏 乌老大的宝藏 任平生的宝藏 李秋水的宝藏 "
  strItem = strItem .. "段延庆的宝箱 鸠摩智的宝箱 慕容复的宝箱 "
  strItem = strItem .. "段延庆的宝藏 鸠摩智的宝藏 慕容复的宝藏 "
  strItem = strItem .. "段延庆的宝箱·遗 鸠摩智的宝箱·遗 慕容复的宝箱·遗 "
  strItem = strItem .. "耶律辛的宝盒 耶律宛的宝盒 耶律元的宝盒 耶律洪基的宝盒 耶律辛的宝箱 耶律宛的宝箱 耶律元的宝箱 耶律洪基的宝箱 "
  strItem = strItem .. "闵墨的宝箱 秦韵的宝箱 陶青的宝箱 庞企的宝箱 "
  strItem = strItem .. "闵墨的宝藏 秦韵的宝藏 陶青的宝藏 庞企的宝藏 "
  strItem = strItem .. "闵墨的宝箱·遗 秦韵的宝箱·遗 陶青的宝箱·遗 庞企的宝箱·遗 "
  strItem = strItem .. "鸣金锦匣 暗火锦匣 启天锦匣 藏坤锦匣 "
  strItem = strItem .. "启天宝箱 藏坤宝箱 "
  return strItem
end

function Box2TempBag()
  if g_config.fuben.ty_un_openbox then
    Bag_Move2TempBank(GetFubenBox(), nil, nil, true)
  end
end

function Bag_GetItemLimitCanUse(aItemName, aCheckLevel, atItem)
  local tBSLB = Bag:FindItemInfo(aItemName, nil, nil, atItem)
  if nil == aCheckLevel or aCheckLevel < g_self.level then
    return tBSLB
  end
  local tCanUse = {}
  if #tBSLB > 0 then
    local nowTime = GetServerTime_init()
    for i = 1, #tBSLB do
      local tmp = tBSLB[i]
      local pDateExt = 0
      if IsProcess64() then
        pDateExt = R_P(tmp.obj + 24)
      else
        pDateExt = R_P(tmp.obj + 20)
      end
      local pDate = R_D(pDateExt + 52)
      local b32HH = pDate >> 24 & 255
      local b32HL = pDate >> 16 & 255
      local b32LH = pDate >> 8 & 255
      local b32LL = pDate & 255
      local puData = b32HH << 24 | b32HL << 16 | b32LH << 8 | b32LL
      local nYear = 2000 + math.floor(puData / 100000000)
      puData = puData % 100000000
      local nYue = math.floor(puData / 1000000)
      puData = puData % 1000000
      local nRi = math.floor(puData / 10000)
      puData = puData % 10000
      local nShi = math.floor(puData / 100)
      puData = puData % 100
      local nFen = puData
      local getTime = os.time({
        year = nYear,
        month = nYue,
        day = nRi,
        hour = nShi,
        min = nFen,
        sec = 59
      })
      if nowTime - getTime > 86400 then
        table.insert(tCanUse, tBSLB[i])
      end
    end
  end
  return tCanUse
end

function EatBindItem(nCount, aEatItemName, aMustOpenBox)
  g_config.item.xiaohua_bind = g_config.item.xiaohua_bind or ""
  g_config.item.xiaohua_unbind = g_config.item.xiaohua_unbind or ""
  local bEat = false
  nCount = nCount or 20
  if 0 == g_self.level then
    PlayerDataInit()
  end
  local strLockItem = " 真元珀 真元精珀 归山令 "
  if g_self.level >= 80 then
    strLockItem = strLockItem .. " 紫色真元符集 橙色真元符集 "
  end
  if not IsInDebugMsg("#{LSHYH_150210_123}") then
    strLockItem = strLockItem .. " 上品少阳丹 "
  end
  local strUnLockItem = " 浑天璞石 精金素月礼匣 秘银棉布礼盒 藏金券 御赐令赏 武约心诀素盒 武约心诀繁盒 工资卡 心诀素盒 四绘玲珑匣 苍鹤药魄 玄机药尘 一包云沙 一袋碎银 武约好礼 物锦华袋 周活跃好礼 银丝白巧囊 "
  strUnLockItem = strUnLockItem .. " 50绑定元宝 100绑定元宝 200绑定元宝 中秋节礼包 圣诞大礼盒 元旦大礼盒 "
  if g_self.level >= 75 then
    strUnLockItem = strUnLockItem .. " 释灵浆 "
  end
  local strItem = strLockItem .. strUnLockItem
  if not CheckMibao() then
    strItem = strUnLockItem
  end
  if aMustOpenBox or not g_config.fuben.ty_un_openbox then
    local tSpace = TempBankGetNullPos()
    if #tSpace > 10 then
      strItem = strItem .. GetFubenBox()
    else
      DebugColorMsg("天机锦囊：几乎满了,不自动吃宝盒宝箱", 5)
    end
  end
  local userBind = HandleText(g_config.item.xiaohua_bind)
  if #userBind > 1 then
    TempBank2Bag(userBind, 2)
  end
  if #userBind > 0 then
    strItem = userBind .. strItem
  end
  local userUnBind = HandleText_AddFuHao(HandleText(g_config.item.xiaohua_unbind))
  if #userBind > 1 then
    TempBank2Bag(userUnBind, 1)
  end
  CloseWindow("BigBank")
  CloseWindow("Shop")
  DeleteDebugMsg("#{OR_PILFER_LOCK_FLAG}")
  DeleteDebugMsg("#{ResultText_71}")
  local strUseItem = aEatItemName or strItem
  for i = 1, nCount do
    if -1 == Bag:LuaUseItem_DJ(strUseItem, 2) and (#userUnBind < 4 or -1 == Bag:LuaUseItem_DJ(userUnBind, 1)) then
      break
    end
    bEat = true
    if IsInDebugMsg("#{OR_PILFER_LOCK_FLAG}") or IsInDebugMsg("#{ResultText_71}") then
      bEat = false
      break
    end
    Sleep(100)
    IsWindowVisible("Item_MultiUse", "Item_MultiUse_BuyMulti_Clicked()")
    if g_config.item.xiaohua_wyhl.sel > 2 or g_config.item.xiaohua_wyhl.sel < 0 then
      g_config.item.xiaohua_wyhl.sel = 0
    end
    IsWindowVisible("HuoyueWeeklyGift", fmt([[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name("ClientActivateOnce")  
                Set_XSCRIPT_ScriptID(892466)
                Set_XSCRIPT_Parameter(0,%d)
                Set_XSCRIPT_Parameter(1,1)
                Set_XSCRIPT_ParamCount(2)
            Send_XSCRIPT()   
        ]], g_config.item.xiaohua_wyhl.sel + 1))
    if g_config.item.xiaohua_wjhd.sel >= 0 and g_config.item.xiaohua_wjhd.sel <= 3 then
      IsWindowVisible("ActivitySchedule_Choose", fmt([[
                        ActivitySchedule_Choose_Action_Click(%d) 
                        ActivitySchedule_Choose_Clicked()
                    ]], g_config.item.xiaohua_wjhd.sel + 1))
    end
    DebugStr("消化物品.", 3)
  end
  local tItem = Bag:EnumAllObj()
  local tBSLB = Bag_GetItemLimitCanUse("1级宝石礼包", 120, tItem)
  for i = 1, #tBSLB do
    local tmp = tBSLB[i]
    PushColorMsg("1级宝石礼包可用" .. tmp.index)
    Bag:UseItem(tmp.index, 300)
  end
  local tXHD = Bag:FindItemInfo("小还丹", 2, nil, tItem)
  if #tXHD > 0 then
    local tmp = tXHD[1]
    Bag:UseItem(tmp.index, 300)
  end
  
  local function _UseVagueItem(_ItemNameTable, _aItem)
    local tBagItem = _aItem or Bag:EnumDaoJuItem()
    local other = GetTableChildString(tBagItem, "name", _ItemNameTable, 2)
    for i = 1, #other do
      if 1 == other[i].bind then
        Bag:UseItem(other[i].index)
      end
    end
  end
  
  local function _UseFuJiangLin(_aItem)
    if not IsInDebugMsgTime("#{FJTL_140305_06}", nil, 3600) and not IsInDebugMsg("#{FJTL_140305_09}") then
      local nCount = Bag:GetItemCount("福降令", nil, nil, _aItem)
      if nCount > 0 then
        PushColorMsg("自动使用 福降令 祈福")
        GetLuaValue("                        Clear_XSCRIPT();\n\t\t\t                Set_XSCRIPT_Function_Name( \"DoBless_WithFJL\" );\t\n\t\t\t                Set_XSCRIPT_ScriptID( 890509 );\t\t\t        \n\t\t\t                Set_XSCRIPT_Parameter( 0, 1 );\t\t\t        -- 0:非活动界面 1:活动界面\n\t\t\t                Set_XSCRIPT_ParamCount( 1 );\t\t\t        -- 参数个数\n\t\t\t            Send_XSCRIPT(); \n                    ")
        Sleep(200)
      end
    end
  end
  
  _UseVagueItem({"真元·紫"}, tItem)
  _UseFuJiangLin(tItem)
  if bEat then
    CloseWindow("Packet_Temporary")
  end
  return bEat
end

function GetScriptSceneName(aScriptName)
  if type(aScriptName) ~= "string" then
    return nil
  end
  if "四绝庄" == aScriptName or "除匪首力破三关" == aScriptName or "刷棋" == aScriptName then
    return "苏州"
  elseif "剑荡三环除妖魔" == aScriptName or "缥缈峰(大)" == aScriptName or "刷箱子" == aScriptName or "天降奇兽" == aScriptName then
    return "楼兰"
  elseif "观山海" == aScriptName or "琅嬛福地" == aScriptName or "琅嬛福地(困难)" == aScriptName or "少室山" == aScriptName then
    return "大理"
  elseif "兵圣奇阵" == aScriptName then
    return "洛阳"
  end
  return nil
end

function Bag_SellItem(aOtherName, aOtherNameBind, aScriptName)
  aOtherName = aOtherName or ""
  aOtherNameBind = aOtherNameBind or ""
  if "" ~= aOtherName then
    aOtherName = HandleText_AddFuHao(aOtherName, " ", true)
  end
  if "" ~= aOtherNameBind then
    aOtherNameBind = HandleText_AddFuHao(aOtherNameBind, " ", true)
  end
  local goPetShop = true
  EatBindItem()
  local move_count = TempBankSellMove(aOtherName, aOtherNameBind)
  local can_sell_count = Bag_SellAction(nil, aOtherName, aOtherNameBind)
  if 0 == move_count and 0 == can_sell_count then
    Sleep(500)
    EatBindItem()
    move_count = TempBankSellMove(aOtherName, aOtherNameBind)
    if 0 == move_count then
      PushDebugMessage("出售:背包和锦囊无可出售物品！")
      return false
    end
  end
  CloseAllWindow()
  NpcShop_CheckPos(GetScriptSceneName(aScriptName), goPetShop)
  local nLastTick = GetTickCount()
  local wait_tick = 45000
  if IsUnLockMibao() == false then
    wait_tick = 2000
  end
  
  local function sale_action(_ItemInfo)
    PushDebugMessage("出售:%s", _ItemInfo.name)
    Bag:ItemBtnClicked(_ItemInfo.index)
    Sleep(300)
  end
  
  DeleteDebugMsg("#{SSCK_180821_25}")
  while true do
    if IsWindowVisible("Shop") then
      local can_sell_count = Bag_SellAction(sale_action, aOtherName, aOtherNameBind)
      if 0 == can_sell_count then
        EatBindItem()
        move_count = TempBankSellMove(aOtherName, aOtherNameBind)
        if 0 == move_count then
          PushDebugMessage("出售:背包和锦囊已无可卖物品！")
          break
        end
        if IsInDebugMsg("#{SSCK_180821_25}") and wait_tick > 10000 then
          wait_tick = 20000
        end
      end
    else
      NpcShop_CheckPos(GetScriptSceneName(aScriptName), goPetShop)
    end
    Sleep(200)
    if wait_tick < GetTickCount() - nLastTick then
      PushColorMsg("出售：超时!可能密保验证没过")
      break
    end
    if IsInFubenScene() then
      PushColorMsg("出售物品：当前为副本地图！")
      break
    end
    DebugStr("出售物品中")
  end
  Bag_Move2TempBank()
end

function Shop_BuyItem(aBuyName, aBuyNum)
  if not aBuyNum or aBuyNum < 0 then
    PushColorMsg("购买物品:%s 数量有误!", aBuyName)
    return
  end
  GetLuaValue(fmt("return meBuyShopItem('%s',%d)", aBuyName, aBuyNum), "n")
  Sleep(500)
end

function ShangHui_CheckSearchPage()
  if IsWindowVisible("PS_ShopSearch") then
    Sleep(100)
    return true
  elseif IsWindowVisible("PS_ShopList", "PS_ShopList_ChangeTabIndex(3)") then
    Sleep(1000)
  else
    Player:TeamFollow(false, 300)
    GoToSceneNPC("乔复盛", 330, 299, LUOYANG_ID)
    ChangeSceneLine(true)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{RCYH_180606_102}", 1, 1500)
  end
  return false
end

function ShangHui_BuyItem(aBuyName, aBuyNum, aMaxMoney, aNameCmpMode)
  aMaxMoney = aMaxMoney or Player:GetMoney()
  aNameCmpMode = aNameCmpMode or 1
  if nil == aBuyName or "" == aBuyName or aBuyNum <= 0 then
    return -1
  end
  CloseWindow("Quest")
  DeleteDebugMsg("#{YBSC_100111_56}")
  DeleteDebugMsg("您的空间不足")
  local nTickOut = -1
  while true do
    if ShangHui_CheckSearchPage() then
      Sleep(300)
      local tmp = {}
      tmp.name = aBuyName
      local find = {type = 2, subtype = 1}
      if tmp.name == "御瑶盘" or tmp.name == "琉璃焰" then
        find.type = 3
        find.subtype = 10101
      elseif Bag:IsInfantEqui(tmp.name) then
        find.type = 4
        find.subtype = 10101
      end
      GetLuaValue(fmt("PlayerShop:PacketSend_Search(%d, %d, 1, \"%s\", 1)", find.type, find.subtype, tmp.name))
      Sleep(2000)
      local bOk = GetLuaValue(fmt([[
                        local szName = '%s'
                        setmetatable(_G, {__index = PS_ShopSearch_Env})
                        local theAction = EnumAction(0 , "playershop_cur_page")
                        if theAction:GetID() ~= 0 then
                            local name = theAction:GetName() 
                            if szName ~= "" and string.find(name,szName,nil,true) then
                                return 1 
                            end
                        end
                        return 0 
                    ]], aBuyName), "b")
      if bOk then
        break
      end
      if IsInDebugMsg("#{YBSC_100111_56}") then
        PushColorMsg("商会没有物品：" .. aBuyName)
        return -1
      end
    end
    if IsInFubenScene() then
      break
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 20000 then
      PushColorMsg("商会打开搜索超时")
      return -1
    end
    Sleep(300)
    DebugStr("商会搜索物品：" .. aBuyName)
  end
  local nCount, nPrice = GetLuaValue(fmt([[
	
                setmetatable(_G, {__index = PS_ShopSearch_Env})
                for i = 1 ,10 do
                    local theAction = EnumAction( i - 1 , "playershop_cur_page")
                    if theAction:GetID() ~= 0 then
                       local pName ,pShopName, pShopID ,pCount ,pYB = PlayerShop:GetItemPSInfo( i - 1 )			
                       if pName ~= nil and pName ~= "" and pShopID ~= nil and pCount ~= nil and pYB ~= nil and pCount > 0 then 
                            local szNeed,nCount,nMaxMoney,nMohu = "%s",%d ,%f ,%d                                
                            if ((nMohu ==1 and pName == szNeed ) or (nMohu == 3 and string.find(pName,szNeed,nil,true)))                                   
                                and pCount <= nCount and pYB/pCount <= nMaxMoney then                               	 
                            	    PlayerShop:SearchPageBuyItem(i - 1, "item")
                            	    return pCount,pYB
                            end
                        end
                    end
                end
                return -1,-1 
            ]], aBuyName, aBuyNum, aMaxMoney, aNameCmpMode), "nn")
  if -1 ~= nCount then
    Sleep(500)
  end
  return nCount, nPrice
end

function ShangHui_GetMoney(aGetMoney)
  if type(aGetMoney) ~= "number" then
    PushDebugMessage("商会取钱：参数有误,应是整型！")
    return
  end
  if aGetMoney > 0 and aGetMoney <= Player:GetMoney() then
    return true
  end
  GoToSceneNPC("乔复盛", 330, 299, LUOYANG_ID)
  ChangeSceneLine(true)
  local nLastTick = GetTickCount()
  while true do
    if IsWindowVisible("PS_ShopMag") then
      local nGet = aGetMoney - Player:GetMoney()
      local strText = fmt([[
                local nMoney = %s
                local nMoneyAll= PlayerShop:GetMoney("profit","self");
                if nMoney > nMoneyAll then
                    nMoney = nMoneyAll
                end
                if nMoney > 0 then
                    PlayerShop:ApplyMoney("draw_ok", nMoney);
                else
                    return 0
                end
                return 1
            ]], nGet)
      if 0 == GetLuaValue(strText, "n") then
        break
      end
      Sleep(3000)
    else
      GoToSceneNPC("乔复盛", 330, 299, LUOYANG_ID)
      ChangeSceneLine(true)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{RCYH_180606_105}", 1, 700)
    end
    if aGetMoney <= Player:GetMoney() then
      break
    end
    if IsInFubenScene() then
      PushColorMsg("商会取钱：当前为副本地图！")
      break
    end
    if GetTickCount() - nLastTick > 15000 then
      PushDebugMessage("商会取钱:超时!可能密保验证没过或金币不够")
      break
    end
    Sleep(1000)
    DebugStr("商会取钱")
  end
end

function Bag_BuyPetItem(aScriptName)
  local needBuy = false
  Bag_DeleteItem()
  Bag:PackUp(0)
  local buyHuiXuanJinQiu = 0
  local keepCountHuiXuanJinQiu = 0
  local buyPetType1 = 0
  local keepCountPetType1 = 0
  local buyPetType1Name = g_config.protect.buy_pet_type1.text
  local buyPetType2 = 0
  local keepCountPetType2 = 0
  local buyPetType2Name = g_config.protect.buy_pet_type2.text
  if g_config.protect.buy_hxjq then
    keepCountHuiXuanJinQiu = HandleTextToNumber(g_config.protect.buy_hxjq_count)
    local hasCount = Bag:GetItemCount("回旋金球")
    if keepCountHuiXuanJinQiu > hasCount then
      buyHuiXuanJinQiu = keepCountHuiXuanJinQiu - hasCount
    end
  end
  keepCountPetType1 = HandleTextToNumber(g_config.protect.buy_pet_type1_count)
  local hasCount = Bag:GetItemCount(buyPetType1Name)
  if keepCountPetType1 > 0 and keepCountPetType1 > hasCount then
    buyPetType1 = keepCountPetType1 - hasCount
  end
  keepCountPetType2 = HandleTextToNumber(g_config.protect.buy_pet_type2_count)
  hasCount = Bag:GetItemCount(buyPetType2Name)
  if keepCountPetType2 > 0 and keepCountPetType2 > hasCount then
    buyPetType2 = keepCountPetType2 - hasCount
  end
  local buyPetEWai = 0
  local keepCountPetEWai = 0
  local buyPetNameEWai = g_config.fuben.ty_buy_pet.text
  if type(aScriptName) == "string" and "" ~= aScriptName then
    local bujiFuben = HandleText_AddFuHao(g_config.fuben.ty_buy_pet_script, " ")
    local thisName = HandleText_AddFuHao(aScriptName)
    if string.find(bujiFuben, thisName, nil, true) then
      PushColorMsg(aScriptName .. " 需额外补给")
      keepCountPetEWai = HandleTextToNumber(g_config.fuben.ty_buy_pet_count)
      local hasCount = Bag:GetItemCount(buyPetNameEWai)
      if keepCountPetEWai > 0 and keepCountPetEWai > hasCount then
        buyPetEWai = keepCountPetEWai - hasCount
        if buyPetNameEWai == buyPetType1Name then
          if keepCountPetType1 < keepCountPetEWai then
            buyPetType1 = buyPetEWai
            keepCountPetType1 = keepCountPetEWai
          end
          buyPetEWai = 0
          keepCountPetEWai = 0
        end
        if buyPetNameEWai == buyPetType2Name then
          if keepCountPetType2 < keepCountPetEWai then
            buyPetType2 = buyPetEWai
            keepCountPetType2 = keepCountPetEWai
          end
          buyPetEWai = 0
          keepCountPetEWai = 0
        end
      end
    end
  end
  if buyHuiXuanJinQiu > 0 or buyPetType1 > 0 or buyPetType2 > 0 or buyPetEWai > 0 then
    local saveMoney = false
    if Player:GetMoney(1) + Player:GetMoney(2) < 30000 then
      saveMoney = true
      Bank_GetMoney(50000, GetScriptSceneName(aScriptName))
    end
    needBuy = true
    local goPetShop = true
    CloseAllWindow()
    NpcShop_CheckPos(GetScriptSceneName(aScriptName), goPetShop)
    local nLastTick = GetTickCount()
    local wait_tick = 45000
    if IsUnLockMibao() == false then
      wait_tick = 2000
    end
    DeleteDebugMsg("购买数量过大，包裹道具栏空位不足或包裹已满。")
    while true do
      if IsWindowVisible("Shop") then
        if buyHuiXuanJinQiu > 0 then
          Shop_BuyItem("回旋金球", buyHuiXuanJinQiu)
          Sleep(300)
          buyHuiXuanJinQiu = 0
          local hasCount = Bag:GetItemCount("回旋金球")
          if keepCountHuiXuanJinQiu > hasCount then
            buyHuiXuanJinQiu = keepCountHuiXuanJinQiu - hasCount
          end
        end
        if buyPetType1 > 0 then
          Shop_BuyItem(buyPetType1Name, buyPetType1)
          Sleep(300)
          buyPetType1 = 0
          local hasCount = Bag:GetItemCount(buyPetType1Name)
          if keepCountPetType1 > hasCount then
            buyPetType1 = keepCountPetType1 - hasCount
          end
        end
        if buyPetType2 > 0 then
          Shop_BuyItem(buyPetType2Name, buyPetType2)
          Sleep(300)
          buyPetType2 = 0
          local hasCount = Bag:GetItemCount(buyPetType2Name)
          if keepCountPetType2 > hasCount then
            buyPetType2 = keepCountPetType2 - hasCount
          end
        end
        if buyPetEWai > 0 then
          Shop_BuyItem(buyPetNameEWai, buyPetEWai)
          Sleep(300)
          buyPetEWai = 0
          local hasCount = Bag:GetItemCount(buyPetNameEWai)
          if keepCountPetEWai > hasCount then
            buyPetEWai = keepCountPetEWai - hasCount
          end
        end
      else
        NpcShop_CheckPos(GetScriptSceneName(aScriptName), goPetShop)
      end
      if 0 == buyHuiXuanJinQiu and 0 == buyPetType1 and 0 == buyPetType2 and 0 == buyPetEWai then
        break
      end
      if IsInDebugMsg("购买数量过大，包裹道具栏空位不足或包裹已满。") then
        PushColorMsg("购买珍兽用品：背包已满")
        break
      end
      Sleep(800)
      if wait_tick < GetTickCount() - nLastTick then
        PushColorMsg("购买珍兽用品：超时!可能密保验证没过")
        break
      end
      if IsInFubenScene() then
        PushColorMsg("购买珍兽用品：当前为副本地图！")
        break
      end
      DebugStr("购买珍兽用品")
    end
    if saveMoney then
      Bank_SaveMoney(0)
    end
  end
  CloseAllWindow()
  return needBuy
end

function Bag_BuyPlayerItem(aScriptName)
  local szToSceneName = GetScriptSceneName(aScriptName) or GetCurrentSceneName()
  szToSceneName = string.gsub(szToSceneName, "1线", "")
  szToSceneName = string.gsub(szToSceneName, "2线", "")
  Bag_DeleteItem()
  Bag:PackUp(0)
  local buyJcy = 0
  local keepCountJcy = 0
  local buyGlw = 0
  local keepCountGlw = 0
  if g_config.protect.buy_jcy then
    keepCountJcy = HandleTextToNumber(g_config.protect.buy_jcy_count)
    local hasCount = Bag:GetItemCount("金创药")
    if keepCountJcy > hasCount then
      buyJcy = keepCountJcy - hasCount
    end
  end
  if g_config.protect.buy_glw then
    keepCountGlw = HandleTextToNumber(g_config.protect.buy_glw_count)
    local hasCount = Bag:GetItemCount("归灵丸")
    if keepCountGlw > hasCount then
      buyGlw = keepCountGlw - hasCount
    end
  end
  CloseAllWindow()
  if 0 == buyJcy and 0 == buyGlw then
    return
  end
  local tShopNPC = {
    {
      x = 229,
      y = 307,
      sceneName = "洛阳",
      sceneID = LUOYANG_ID,
      name = "白萌生"
    },
    {
      x = 193,
      y = 252,
      sceneName = "苏州",
      sceneID = 1,
      name = "胡繁"
    },
    {
      x = 105,
      y = 123,
      sceneName = "大理",
      sceneID = 2,
      name = "卢三七",
      option = "购买药品"
    }
  }
  local sceneTab = {
    szToSceneName,
    szToSceneName .. "1线",
    szToSceneName .. "2线"
  }
  local tNPC = GetTableFieldValue(tShopNPC, "sceneName", sceneTab)
  if 0 == #tNPC then
    tNPC = GetTableFieldValue(tShopNPC, "sceneName", {"洛阳"})
  end
  if 0 == #tNPC then
    return
  end
  local npc = tNPC[1]
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  local nLastTick = GetTickCount()
  local wait_tick = 45000
  if IsUnLockMibao() == false then
    wait_tick = 10000
  end
  DeleteDebugMsg("购买数量过大，包裹道具栏空位不足或包裹已满。")
  while true do
    if IsWindowVisible("Shop") then
      if buyJcy > 0 then
        Shop_BuyItem("金创药", buyJcy)
        Sleep(300)
        buyJcy = 0
        local hasCount = Bag:GetItemCount("金创药")
        if keepCountJcy > hasCount then
          buyJcy = keepCountJcy - hasCount
        end
      end
      if buyGlw > 0 then
        Shop_BuyItem("归灵丸", buyGlw)
        Sleep(300)
        buyGlw = 0
        local hasCount = Bag:GetItemCount("归灵丸")
        if keepCountGlw > hasCount then
          buyGlw = keepCountGlw - hasCount
        end
      end
    else
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      if npc.option then
        Sleep(500)
        QuestFrameOptionClicked_Item(npc.option, 1, 700)
      end
    end
    if 0 == buyJcy and 0 == buyGlw then
      break
    end
    if IsInDebugMsg("购买数量过大，包裹道具栏空位不足或包裹已满。") then
      PushColorMsg("补给药品：背包已满")
      break
    end
    Sleep(800)
    if wait_tick < GetTickCount() - nLastTick then
      PushColorMsg("补给药品：超时!可能密保验证没过")
      break
    end
    if IsInFubenScene() then
      PushColorMsg("补给药品：当前为副本地图！")
      break
    end
    DebugStr("补给药品")
  end
  CloseAllWindow()
end

function Bag_UseTuLingZhu(aToSceneID, aCmpPos)
  local bUse = false
  local tDWF = Bag:FindDingWei("灵珠")
  for i = 1, #tDWF do
    local tmp = tDWF[i]
    if tmp.dwf.data > 0 then
      local strSceneName = GetSceneNameByResID(tmp.dwf.mapID)
      strSceneName = string.gsub(strSceneName, "1线", "")
      strSceneName = string.gsub(strSceneName, "2线", "")
      tmp.dwf.sceneName = strSceneName
      tmp.dwf.sceneID = GetSceneIDByName(strSceneName)
    end
  end
  if #tDWF > 0 then
    local tTargetDWF = {}
    for i = 1, #tDWF do
      local tmp = tDWF[i]
      if tmp.dwf.data > 0 and tmp.dwf.sceneID == aToSceneID then
        tmp.x = tmp.dwf.x
        tmp.y = tmp.dwf.y
        tmp.sceneName = tmp.dwf.sceneName
        table.insert(tTargetDWF, tmp)
      end
    end
    if #tTargetDWF > 0 then
      PushDebugMessage("使用土灵珠回：%s", tTargetDWF[1].sceneName)
      if aCmpPos then
        GetAllPosDist(tTargetDWF, aCmpPos, "dist")
        BubbleByDist(tTargetDWF)
      end
      Player:TeamFollow(false, 300)
      Dismount()
      Sleep(300)
      Bag:UseItem(tTargetDWF[1].index, 600)
      PlayerStateTimeOut(5, 20)
      bUse = true
    end
  end
  return bUse
end

function Bag_CDFLCheckScene(aSceneName, anAllIndex)
  local bFind = false
  local tItem = Bag:FindItemInfo("彻地符箓")
  if #tItem > 0 then
    local nAllIndex = anAllIndex
    local nIndex = tItem[1].index
    local strText = fmt("       \n                local Client_ItemIndex = %d       \n                local szScene = '%s'\n                local nAllIndex = %d\n                if nAllIndex == 1  then\n                    for i = 0, 29 do\n                        local pos, strText, count, posx, posy, init = PlayerPackage:GetDunJiaShuPosInfo(Client_ItemIndex, i)\n                        if strText == szScene or strText .. \"1线\" == szScene or strText .. \"2线\" == szScene then\n                            return 1\n                        end\n                    end                     \n                else \n                    local DJS_SelIndex = 9\n                    local pos, strText, count, posx, posy, init = PlayerPackage:GetDunJiaShuPosInfo(Client_ItemIndex, DJS_SelIndex)\n                    if strText == szScene or strText .. \"1线\" == szScene or strText .. \"2线\" == szScene then\n                        return 1\n                    end\n                end\n                return 0\n            ", nIndex, aSceneName, nAllIndex)
    if GetLuaValue(strText, "b") then
      bFind = true
    end
  end
  return bFind
end

function Bag_UseDingWeiCDFL(aSceneName, aAllIndex)
  local bUse = false
  local tItem = Bag:FindItemInfo("彻地符箓")
  if #tItem > 0 then
    local nAllIndex = 0
    if aAllIndex then
      nAllIndex = 1
    end
    if Bag_CDFLCheckScene(aSceneName, nAllIndex) then
      Dismount(600)
      local nIndex = tItem[1].index
      local strText = fmt([[
       
                local Client_ItemIndex = %d       
                local szScene = '%s'
                local nAllIndex = %d
                if nAllIndex == 1  then
                    for i = 0, 29 do
                        local pos, strText, count, posx, posy, init = PlayerPackage:GetDunJiaShuPosInfo(Client_ItemIndex, i)
                        if strText == szScene then
                            Clear_XSCRIPT()
                                Set_XSCRIPT_Function_Name("SetUISelIdx")
                                Set_XSCRIPT_ScriptID(330059)
                                Set_XSCRIPT_Parameter(0, Client_ItemIndex)
                                Set_XSCRIPT_Parameter(1, i)
                                Set_XSCRIPT_ParamCount(2)
                            Send_XSCRIPT()
                            PlayerPackage:UseItem(Client_ItemIndex)
                            return 1
                        end
                    end                     
                else 
                    local DJS_SelIndex = 9
                    local pos, strText, count, posx, posy, init = PlayerPackage:GetDunJiaShuPosInfo(Client_ItemIndex, DJS_SelIndex)
                    if strText == szScene then
                        Clear_XSCRIPT()
                            Set_XSCRIPT_Function_Name("SetUISelIdx")
                            Set_XSCRIPT_ScriptID(330059)
                            Set_XSCRIPT_Parameter(0, Client_ItemIndex)
                            Set_XSCRIPT_Parameter(1, DJS_SelIndex)
                            Set_XSCRIPT_ParamCount(2)
                        Send_XSCRIPT()
                        PlayerPackage:UseItem(Client_ItemIndex)
                        return 1
                    end
                end
                return 0
            ]], nIndex, aSceneName, nAllIndex)
      if GetLuaValue(strText, "b") then
        bUse = true
        Sleep(1000)
      end
      PlayerStateTimeOut(5, 10)
    end
  end
  return bUse
end

function TakeItemToBag(aItemName)
  if 0 == Bag:GetItemCount(aItemName) then
    TempBank2Bag(aItemName, 0)
    Sleep(500)
  end
  if 0 == Bag:GetItemCount(aItemName) and Bag:GetItemCount(aItemName, nil, nil, Bank_EnumItem()) then
    Bank_GetItem(aItemName)
    Sleep(500)
  end
end

return Bag
