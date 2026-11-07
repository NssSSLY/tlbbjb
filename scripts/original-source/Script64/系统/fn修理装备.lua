-- 反编译自 dfz64.dll 内嵌字节码 004d4635（unluac 2025-12-23；仅供分析）
local m_WuQiLevel = -1
local m_szCaiLiao = {}
local m_shenfu = ""
local m_dajia = false
local m_CaiLiao = {
  {
    level = 49,
    name = "新莽神符1级"
  },
  {
    level = 59,
    name = "新莽神符2级"
  },
  {
    level = 69,
    name = "新莽神符3级"
  },
  {
    level = 79,
    name = "新莽神符4级"
  },
  {
    level = 89,
    name = "新莽神符5级"
  },
  {
    level = 99,
    name = "新莽神符6级"
  },
  {
    level = 102,
    name = "新莽神符7级"
  }
}

local function GetPacketItemID(idx)
  local szText = fmt("local ItemID = PlayerPackage:GetItemTableIndex(%d);return ItemID", idx)
  return GetLuaValue(szText, "n")
end

local function XLZB_CheckPos(aType)
  local npc = {
    x = 354,
    y = 249,
    sceneID = 1,
    name = "薛菲",
    id = 140
  }
  local vipLevel = GetPlayerVipLevel()
  if 2 == aType then
    if 9 == vipLevel then
      return -1
    end
  elseif 1 == aType and vipLevel >= 6 then
    return -1
  end
  if IsKVKSceneName() then
    npc = {
      x = 184,
      y = 216,
      sceneID = 850,
      name = "李立青",
      id = 24
    }
    if 2 == aType then
      npc = {
        x = 195,
        y = 216,
        sceneID = 850,
        name = "欧冶青",
        id = 23
      }
    end
    for i = 1, 5 do
      GoToSceneNPC(npc.name, npc.x, npc.y, 850)
      local tObj = Enum2XByName(npc.name, {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        npc.id = tObj[1].id
        break
      end
    end
    GoToSceneNPC(npc.name, npc.x, npc.y, 850)
  elseif IsDestination(npc.x, npc.y, npc.sceneID, 3) == false then
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    Sleep(800)
  end
  return npc.id
end

local function XLZB_CheckWuHunPos()
  local vipLevel = GetPlayerVipLevel()
  if vipLevel < 6 then
    if IsKVKSceneName() then
      GoToScene(204, 216, 850)
    else
      GoToScene(139, 196, 2)
    end
    Sleep(500)
  end
end

local function XLZB_ChuanZB(EquipRepairNameList)
  local bIsChuan = false
  CloseWindow("EquipRepair")
  local nCurrNum = GetLuaValue("return DataPool:GetBaseBag_Num();", "n")
  for i = 1, nCurrNum do
    local szName = GetLuaValue(fmt([[
                    local szName = ""
                    local iPos  = %d
                    local theAction, bLocked = PlayerPackage:EnumItem("base", iPos);
                    if theAction:GetID() ~= 0 and theAction:GetEquipDur() == 1 then
                        szName = theAction:GetName()
                    end
                    return szName
                ]], i - 1), "s")
    if nil ~= szName and "" ~= szName then
      if not IsWindowVisible("SelfEquip") then
        GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
        Sleep(1000)
      end
      for j = 1, #EquipRepairNameList do
        if EquipRepairNameList[j] == szName then
          bIsChuan = true
          Bag:ItemBtnClicked(i - 1)
          break
        end
      end
    end
  end
  return bIsChuan
end

local function XLZB_RepairShenQi(aParam, EquipRepairNameList)
  local bIsRepair = false
  local minEndurance = aParam.shenqi
  local npcID = XLZB_CheckPos(2)
  local nCurrNum = GetLuaValue("return DataPool:GetBaseBag_Num();", "n")
  for i = 1, nCurrNum do
    local szName, defineID = GetLuaValue(fmt([[
                    local i ,minEndurance = %d-1, %d
                    local szName = ""
                    local itemID = 0
                    local theAction, bLocked = PlayerPackage:EnumItem("base", i);
                    if theAction:GetID() ~= 0 and theAction:GetEquipDur() < minEndurance / 100 then
                        szName = theAction:GetName()
                        itemID = PlayerPackage:GetItemTableIndex(i);
                    end
                    return szName, itemID
                ]], i, minEndurance), "sn")
    if nil ~= szName and "" ~= szName then
      for j = 1, #EquipRepairNameList do
        if EquipRepairNameList[j] == szName then
          local posCL = -1
          if defineID >= 10300000 and defineID <= 10399999 then
            for k = 1, #m_szCaiLiao do
              local tItem = Bag:FindItemInfo(m_szCaiLiao[k])
              if #tItem > 0 then
                posCL = tItem[1].index
                break
              end
            end
          end
          if -1 ~= posCL then
            bIsRepair = true
            local nEnterID = 0
            if -1 == npcID then
              nEnterID = 1
            end
            GetLuaValue(fmt([[
                                    local npcid = %d
                                    local iPos = %d
                                    local posCL = %d
                                    local enterID = %d
                                    Clear_XSCRIPT()
                                        Set_XSCRIPT_Function_Name("OnEquipRepairNew")
                                        Set_XSCRIPT_ScriptID(805027)
                                        Set_XSCRIPT_Parameter(0, npcid)
                                        Set_XSCRIPT_Parameter(1, 0)
                                        Set_XSCRIPT_Parameter(2, iPos)
                                        Set_XSCRIPT_Parameter(3, posCL)
                                        Set_XSCRIPT_Parameter(4, 1)
                                        Set_XSCRIPT_Parameter(5, enterID)
                                        Set_XSCRIPT_ParamCount(6)
                                    Send_XSCRIPT()
                                ]], npcID, i - 1, posCL, nEnterID))
          end
          PushColorMsg("修理神器: " .. szName)
          Sleep(200)
        end
      end
    end
  end
  return bIsRepair
end

local function XLZB_RepairofEquip(aEquipIndex, aEquipName)
  local npcID = XLZB_CheckPos(1)
  local nEnterID = 0
  if -1 == npcID then
    nEnterID = 1
  end
  GetLuaValue(fmt([[
                    local iPos = %d
                    local npcid = %d  
                    local enterID = %d                                    
                    Clear_XSCRIPT()
                        Set_XSCRIPT_Function_Name("OnEquipRepairNew")
                        Set_XSCRIPT_ScriptID(805027)
                        Set_XSCRIPT_Parameter(0, npcid)
                        Set_XSCRIPT_Parameter(1, 1)
                        Set_XSCRIPT_Parameter(2, iPos)
                        Set_XSCRIPT_Parameter(3, -1)
                        Set_XSCRIPT_Parameter(4, 1)
                        Set_XSCRIPT_Parameter(5, enterID)
                        Set_XSCRIPT_ParamCount(6)
                    Send_XSCRIPT()
                    ]], aEquipIndex, npcID, nEnterID))
  PushColorMsg("修理装备: " .. aEquipName)
  Sleep(500)
end

local function XLZB_AddRepairCount(aEquipIndex, aEquipName, aCaiLiaoIndex)
  PushColorMsg("修理装备：使用润物露 " .. aEquipName)
  local npcID = XLZB_CheckPos(1)
  GetLuaValue(fmt([[
                local iPos = %d
                local npcid = %d   
                local cailiao = %d                                   
                Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("EquipFaileTimesOnEquip")
                    Set_XSCRIPT_ScriptID(809265)
                    Set_XSCRIPT_Parameter(0, npcid)
                    Set_XSCRIPT_Parameter(1, iPos)
                    Set_XSCRIPT_Parameter(2, cailiao)
                    Set_XSCRIPT_ParamCount(3)
                Send_XSCRIPT()
            ]], aEquipIndex, npcID, aCaiLiaoIndex))
  Sleep(500)
end

local function XLZB_ZhuangBei(aParam)
  local bIsRepair = false
  local EquipRepairNameList = {}
  local tabEquip = {
    {
      index = 0,
      class = "武器",
      equip_index = 11
    },
    {
      index = 1,
      class = "帽子",
      equip_index = 1
    },
    {
      index = 2,
      class = "衣服",
      equip_index = 12
    },
    {
      index = 3,
      class = "手套",
      equip_index = 4
    },
    {
      index = 4,
      class = "鞋",
      equip_index = 6
    },
    {
      index = 5,
      class = "腰带",
      equip_index = 5
    },
    {
      index = 6,
      class = "戒指",
      equip_index = 7
    },
    {
      index = 7,
      class = "项链",
      equip_index = 13
    },
    {
      index = 8,
      class = "骑乘",
      equip_index = -1
    },
    {
      index = 9,
      class = "行囊",
      equip_index = -1
    },
    {
      index = 10,
      class = "箱格",
      equip_index = -1
    },
    {
      index = 11,
      class = "戒指",
      equip_index = 8
    },
    {
      index = 12,
      class = "护符",
      equip_index = 9
    },
    {
      index = 13,
      class = "护符",
      equip_index = 10
    },
    {
      index = 14,
      class = "护腕",
      equip_index = 3
    },
    {
      index = 15,
      class = "护肩",
      equip_index = 2
    },
    {
      index = 16,
      class = "时装",
      equip_index = -1
    },
    {
      index = 17,
      class = "暗器",
      equip_index = 14
    },
    {
      index = 18,
      class = "武魂",
      equip_index = -1
    },
    {
      index = 19,
      class = "龙纹",
      equip_index = 25
    },
    {
      index = 20,
      class = "令牌",
      equip_index = 16
    },
    {
      index = 21,
      class = "豪侠印",
      equip_index = -1
    }
  }
  for i = 1, #tabEquip do
    local tmp = tabEquip[i]
    if 8 ~= tmp.index and 9 ~= tmp.index and 10 ~= tmp.index and 16 ~= tmp.index and 17 ~= tmp.index and 18 ~= tmp.index then
      local minEndurance = 0
      if 0 == tmp.index then
        minEndurance = aParam.shenqi
      else
        minEndurance = aParam.zhuangbei
      end
      local tid, szName, defineID, repairCount = GetLuaValue(fmt([[
                        local index, minEndurance = %d,%d
                        local ActionIndex = EnumAction(index, "equip")
                        local szName = ""
                        local defineID = -1
                        local repairCount = 3
                        local tid = ActionIndex:GetID()
                        if tid ~= 0 then
                            if ActionIndex:GetEquipDur() < minEndurance / 100 then
                                szName = ActionIndex:GetName()
                                defineID = ActionIndex:GetDefineID()
                                repairCount = ActionIndex:GetRemainRepairCount()
                            end
                            szName = szName or ""
                            defineID = defineID or -1
                        end
                        return tid, szName, defineID,repairCount
                    ]], tmp.index, minEndurance), "nsnn")
      if 0 ~= tid and "" ~= szName then
        bIsRepair = true
        local bShenQiClick = false
        if 0 == tmp.index and defineID >= 10300000 and defineID <= 10399999 and m_WuQiLevel > 41 and m_WuQiLevel < 103 then
          m_szCaiLiao = {}
          for j = 1, #m_CaiLiao do
            if m_CaiLiao[j].level >= m_WuQiLevel then
              table.insert(m_szCaiLiao, m_CaiLiao[j].name)
            end
          end
          local bHaveFu = false
          local szShenFu = " "
          for j = 1, #m_szCaiLiao do
            local nCount = Bag:GetItemCount(m_szCaiLiao[j])
            if nCount > 0 then
              bHaveFu = true
            end
            szShenFu = szShenFu .. m_szCaiLiao[j] .. " "
          end
          m_shenfu = szShenFu
          if not bHaveFu then
            if TempBank2Bag(szShenFu, 2) == false and not m_dajia then
              Bank_GetItem(szShenFu, 1, 2)
            end
            Sleep(800)
          end
          for j = 1, #m_szCaiLiao do
            local nCount = Bag:GetItemCount(m_szCaiLiao[j])
            if nCount > 0 then
              bShenQiClick = true
              break
            end
          end
        end
        if bShenQiClick then
          if not IsWindowVisible("SelfEquip") then
            GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
            Sleep(1000)
          end
          GetLuaValue(fmt("setmetatable(_G, { __index = SelfEquip_Env });SelfEquip_Equip_Click(%d, 0);", tmp.equip_index))
          Sleep(800)
          table.insert(EquipRepairNameList, szName)
          for i = 1, 3 do
            if false == XLZB_RepairShenQi(aParam, EquipRepairNameList) then
              break
            end
            Sleep(500)
          end
          for i = 1, 3 do
            if false == XLZB_ChuanZB(EquipRepairNameList) then
              break
            end
            Sleep(500)
          end
        else
          if 0 == repairCount then
            local needItem = "润物露"
            local tItem = Bag:FindItemInfo(needItem)
            if 0 == #tItem then
              if TempBank2Bag(needItem, 0) == false and not m_dajia then
                PushColorMsg("仓库取" .. needItem)
                Bank_GetItem(needItem, 1, 0)
              end
              Sleep(1000)
            end
            local tItem = Bag:FindItemInfo(needItem)
            if #tItem > 0 then
              local itemPos = tItem[1].index
              local tBind = GetTableFieldValue(tItem, "bind", {1})
              if #tBind > 0 then
                itemPos = tBind[1].index
              end
              XLZB_AddRepairCount(tmp.index, szName, itemPos)
            end
          end
          XLZB_RepairofEquip(tmp.index, szName)
        end
      end
    end
  end
  if not bIsRepair then
    PushDebugMessage("修理装备：已经没有可修理的装备！")
  end
  return bIsRepair
end

local function XLZB_Wuhun(aParam)
  local bIsRepair = false
  local nLife = aParam.wuhun
  local szName = GetLuaValue(fmt([[
                local szName =  DataPool:GetKfsData("NAME")
                local curLife = DataPool:GetKfsData("LIFE")
	            local maxLife = DataPool:GetKfsData("MAXLIFE")
                if szName ~= nil and curLife ~= nil and curLife < %d then 
                    return szName
                end
                return  ""    
            ]], nLife), "s")
  if nil ~= szName and "" ~= szName then
    bIsRepair = true
    local bClick = true
    local tItem = Bag:FindItemInfo("武魂延寿丹")
    if 0 == #tItem then
      if TempBank2Bag("武魂延寿丹", 0) == false then
        Bank_GetItem("武魂延寿丹", 1)
      end
      Sleep(800)
      tItem = Bag:FindItemInfo("武魂延寿丹")
      if 0 == #tItem then
        bClick = false
      end
    end
    if bClick then
      local vipLevel = GetPlayerVipLevel()
      if vipLevel >= 6 and #tItem > 0 then
        if Player:GetMoney(1) + Player:GetMoney(2) < 50000 then
          PushColorMsg("修理武魂：取出5J")
          Bank_GetMoney(50000)
        end
        GetLuaValue(fmt([[
                            local iPos = 18
                            local posCL = %d        
                            Clear_XSCRIPT();
                                Set_XSCRIPT_Function_Name("Kfs_AddLifeNew");
                                Set_XSCRIPT_ScriptID(809270);
                                Set_XSCRIPT_Parameter(0,1); --vip
                                Set_XSCRIPT_Parameter(1,iPos);
                                Set_XSCRIPT_Parameter(2,posCL);
                                Set_XSCRIPT_Parameter(3,1);
                                Set_XSCRIPT_Parameter(4,1);
                                Set_XSCRIPT_ParamCount(5);
                            Send_XSCRIPT();
                            ]], tItem[1].index))
        Sleep(1000)
      else
        GetLuaValue("setmetatable(_G, { __index = Wuhun_Env });Wuhun_Equip_Clicked(0);")
        Sleep(1000)
        if Player:GetMoney(1) + Player:GetMoney(2) < 50000 then
          PushColorMsg("修理武魂：取出5J")
          Bank_GetMoney(50000)
        end
        local iEuip = GetLuaValue(fmt([[
                            local strWuhun = '%s'
                            local nCurrNum = DataPool:GetBaseBag_Num();
                            for i = 1, nCurrNum do
                                local theAction, bLocked = PlayerPackage:EnumItem("base", i - 1);
                                local szName = theAction:GetName()
                                if theAction:GetID() ~= 0 and szName and szName == strWuhun then
                                    local curLife = PlayerPackage:GetBagKfsData(i - 1, "LIFE")
                                    local maxLife = PlayerPackage:GetBagKfsData(i - 1, "MAXLIFE")
                                    if curLife < %d then
                                        return i
                                    end
                                end
                            end
                            return -1
                        ]], szName, nLife), "n")
        if iEuip > 0 and #tItem > 0 then
          XLZB_CheckWuHunPos()
          Dismount()
          Sleep(1000)
          GetLuaValue(fmt("PlayerPackage:Kfs_Op_Do(4,%d,%d, 1, 0)", iEuip - 1, tItem[1].index))
          Sleep(1000)
          Dismount()
          Bag:ItemBtnClicked(iEuip - 1)
          Sleep(1300)
          PlayerStateTimeOut(5, 10)
        end
      end
    else
      PushColorMsg("修理武魂：没有武魂延寿丹。")
    end
  else
    PushDebugMessage("武魂寿命大于" .. nLife .. "无需修理。")
  end
  return bIsRepair
end

function XLZB_Action(aParam)
  m_dajia = false
  Bag:PackUp(0)
  local nCount = 3
  if m_dajia then
    nCount = 1
  end
  m_WuQiLevel = GetLuaValue("local ActionIndex = EnumAction(0, 'equip');local nLevel = ActionIndex:GetEquipLevel();if nLevel == nil then return -1 end return nLevel", "n")
  for i = 1, nCount do
    if false == XLZB_ZhuangBei(aParam) then
      break
    end
    Sleep(1000)
  end
  if IsWindowVisible("SelfEquip") then
    GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
  end
  for i = 1, nCount do
    if false == XLZB_Wuhun(aParam) then
      break
    end
    Sleep(1000)
  end
  if not aParam.unsave_wuzi then
    Bag_Move2TempBank(m_shenfu .. " 武魂延寿丹 润物露", 0)
    if not m_dajia then
      MainBankSaveItem()
    end
  end
end
