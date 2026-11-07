-- 反编译自 dfz64.dll 内嵌字节码 00344393（unluac 2025-12-23；仅供分析）
local m_script_name = "合成龙纹"
ScriptOnStart(m_script_name, false, false)
g_config.hclw = {}
g_config.hclw.bind_lw = ReadConfigBool("ZH", "xzk213")
g_config.hclw.bind_stuff = ReadConfigBool("ZH", "xzk214")
local m_param = {}
m_param.bind_lw = g_config.hclw.bind_lw
m_param.bind_stuff = g_config.hclw.bind_stuff
m_param.tempBag = true
m_param.bank = true

local function lw_removeEquip()
  local strText = [[
            local ActionIndex = EnumAction(19, "equip");
            if ActionIndex:GetID() ~= 0 then
                local szName = ActionIndex:GetName()
                setmetatable(_G, { __index = SelfEquip_Env }); SelfEquip_Equip_Click(25, 0);
                return 0
            else
                return 1
            end
        ]]
  local bOK = false
  for i = 1, 5 do
    bOK = GetLuaValue(strText, "b")
    if bOK then
      break
    end
    if not IsWindowVisible("SelfEquip") then
      GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
      Sleep(300)
    end
    Sleep(1000)
  end
  return bOK
end

local function lw_EnumItem()
  local tObj = {}
  local tYuLin = {}
  for i = 1, BAG_CAILIAO_MIN do
    local strText = "            local itemIdx = %d\n            local theAction, bLocked, bProtect = PlayerPackage:EnumItem('base', itemIdx);\n            if theAction:GetID() ~= 0 then\n                if PlayerPackage:IsBagItemLW(itemIdx) == 1 then\n                    local lv = PlayerPackage:GetBagLWData(itemIdx, \"LEVEL\")\n                    if PlayerPackage:IsLock(itemIdx) ~= 1 or lv > 1 then\n                        local bind = GetItemBindStatus(itemIdx)\n                        return lv, bind, 1\n                    end\n                else\n                    local m_YuLinStuff = {\n                        [1] = { item = 38002106, num = 1, bind = 1 },   -- 绑定       \n                        [2] = { item = 38002107, num = 1, bind = 0 },   -- 不绑定\n                    }\n                    local nItemIndex = PlayerPackage:GetItemTableIndex(itemIdx)\n                    for nindex = 1, table.getn(m_YuLinStuff) do\n                        if m_YuLinStuff[nindex].item == nItemIndex and PlayerPackage:IsLock( itemIdx ) ~= 1 then\n                            return 1, m_YuLinStuff[nindex].bind, 2\n                        end\n                    end\n                end\n            end\n            return 0, 0, 0\n            "
    local lv, bd, nType = GetLuaValue(fmt(strText, i - 1), "nnn")
    if lv > 0 then
      if 1 == nType then
        table.insert(tObj, {
          index = i - 1,
          level = lv,
          bind = bd
        })
      elseif 2 == nType then
        table.insert(tYuLin, {
          index = i - 1,
          level = lv,
          bind = bd
        })
      end
    end
  end
  if #tObj > 0 then
    BubbleByLevel(tObj, 2)
  end
  return tObj, tYuLin
end

local function lw_stuff_EnumItem()
  local tObj = {}
  for i = 1, BAG_CAILIAO_MIN do
    local strText = "                local itemIdx = %d\n                --龙纹提升合成等级的材料\n                local m_LevelupStuff = {\n        \t\t\t\t[1] = { item = 38000152, num = 5  },\t\t--铸纹血玉--绑定\n        \t\t\t\t[2] = { item = 38000164, num = 10 },\t\t--铸纹精玉\n        \t\t\t\t[3] = { item = 38000165, num = 20 },\t\t--铸纹龙玉\n        \t\t\t\t[4] = { item = 38000184, num = 5  },\t\t--铸纹血玉\n        \t\t\t\t[5] = { item = 38000185, num = 10 },\t\t--铸纹精玉\n        \t\t\t\t[6] = { item = 38000186, num = 20 },\t\t--铸纹龙玉\n        \t\t\t}\n                local theAction, bLocked, bProtect = PlayerPackage:EnumItem('base', itemIdx);\n                if theAction:GetID() ~= 0 then\n                    local nFlag = 0\n        \t\t    local nNum = table.getn(m_LevelupStuff)\n        \t\t    local nItemIndex = PlayerPackage:GetItemTableIndex( itemIdx )\n        \t\t    for nIndex = 1, nNum do\n        \t\t        if nItemIndex == m_LevelupStuff[nIndex].item then\n        \t\t            nFlag = 1\n        \t\t            break\n        \t\t        end\n        \t\t    end\n                    --\n                    if nFlag == 1 then\n                        if PlayerPackage:IsLock(itemIdx) ~= 1 then\n                            local bind = GetItemBindStatus(itemIdx)\n                            return nItemIndex,bind\n                        end\n                    end\n                end\n                return 0,0\n            "
    local lv, bd = GetLuaValue(fmt(strText, i - 1), "nn")
    if lv > 0 then
      local n = #tObj + 1
      tObj[n] = {
        index = i - 1,
        itemTable = lv,
        bind = bd
      }
    end
  end
  return tObj
end

local function lwhc_OnAction()
  if not lw_removeEquip() then
    PushColorMsg(m_script_name .. ":取下龙纹失败！")
    ClearBag()
    return false
  end
  local tObj, tYuLin = lw_EnumItem()
  local tLW = {}
  for i = 1, #tObj do
    if i > 1 and 1 == tObj[i].level then
      if m_param.bind_lw then
        if 1 == tObj[i].bind then
          table.insert(tLW, tObj[i])
        end
      else
        table.insert(tLW, tObj[i])
      end
    end
  end
  for i = 1, #tYuLin do
    if m_param.bind_lw then
      if 1 == tYuLin[i].bind then
        table.insert(tLW, tYuLin[i])
      end
    else
      table.insert(tLW, tYuLin[i])
    end
  end
  if #tLW < 1 then
    PushDebugMessage(m_script_name .. ":龙纹材料数量不足,请注意龙纹绑定属性")
    if m_param.tempBag then
      if m_param.bind_lw then
        TempBank2Bag("龙纹 龙纹玉灵", 2)
      else
        TempBank2Bag("龙纹 龙纹玉灵", 0)
      end
      m_param.tempBag = false
      Sleep(1000)
      return true
    end
    if m_param.bank then
      if m_param.bind_lw then
        Bank_GetItem("龙纹 龙纹玉灵", -1, 2)
      else
        Bank_GetItem("龙纹 龙纹玉灵", -1, 0)
      end
      if m_param.bind_stuff then
        Bank_GetItem(" 铸纹血玉 铸纹精玉 铸纹龙玉 ", -1, 2)
      else
        Bank_GetItem(" 铸纹血玉 铸纹精玉 铸纹龙玉 ", -1, 0)
      end
      m_param.bank = false
      Sleep(1000)
      return true
    end
    return false
  end
  if 0 == #tObj then
    PushDebugMessage("合成龙纹：背包没有龙纹")
    return false
  end
  local tMainLw = tObj[1]
  if tMainLw.level < 2 then
    PushDebugMessage(m_script_name .. "主龙纹等级过低")
    return false
  elseif tMainLw.level >= 100 then
    PushDebugMessage(m_script_name .. "主龙纹已满级")
    return false
  end
  if m_param.bind_stuff then
    TempBank2Bag(" 铸纹血玉 铸纹精玉 铸纹龙玉 ", 2)
  else
    TempBank2Bag(" 铸纹血玉 铸纹精玉 铸纹龙玉 ", 0)
  end
  tObj = {}
  tObj = lw_stuff_EnumItem()
  local tStuff = {}
  for i = 1, #tObj do
    if m_param.bind_stuff then
      if 1 == tObj[i].bind then
        table.insert(tStuff, tObj[i])
      end
    else
      table.insert(tStuff, tObj[i])
    end
  end
  local nStuff = -1
  if #tStuff > 0 then
    nStuff = tStuff[1].index
  end
  local strText = fmt("PlayerPackage:Lw_Op_Do(1, %d,%d,%d)", tMainLw.index, tLW[1].index, nStuff)
  GetLuaValue(strText)
  return true
end

function _SMain(...)
  local nTickOut = -1
  ClearBag()
  while true do
    GoToSceneNPC("焦鹰", 125, 201, 850)
    if not IsWindowVisible("LongwenLevelUp") then
      QuestFrameOptionClicked_Item("#{LW_KVK_110704_01}", 1, 700)
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if -1 ~= nTickOut and GetTickCount() - nTickOut > 600000 then
      PushColorMsg("合成龙纹:超时！")
      break
    end
    if false == lwhc_OnAction() then
      break
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  CloseWindow("LongwenLevelUp")
  for i = 1, 5 do
    local strText = [[
                local ActionIndex = EnumAction(19, "equip");
                if ActionIndex:GetID() ~= 0 then
                    return 1
                end
                return 0
            ]]
    local b = GetLuaValue(strText, "n")
    if 1 == b then
      break
    end
    local tObj = lw_EnumItem()
    if #tObj > 0 then
      BubbleByLevel(tObj, 2)
      Bag:ItemBtnClicked(tObj[1].index)
      Sleep(300)
    end
    Sleep(600)
  end
  if IsWindowVisible("SelfEquip") then
    GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
