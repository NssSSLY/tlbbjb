-- 反编译自 dfz64.dll 内嵌字节码 00269b42（unluac 2025-12-23；仅供分析）
local m_script_name = "挖灵元图"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
local m_param = {}
m_param.buy_sd = ReadConfigBool("ZH", "xzk52")
m_param.use_shoufei_npc = true
m_param.take_bank = false
m_param.itemName = "精品灵元图 珍品灵元图"
local m_data = {}
m_data.count = 0
m_data.npcID = -1
m_data.buy_sd = true
m_data.buy_count = 0
m_data.sceneID = 876

local function TWM_EnumBaoTu()
  local tBaoTu = Bag:SearchItemName(m_param.itemName)
  local tBaoTu_jn = Bag:SearchItemName(m_param.itemName, Bag:EnumTempBagItem())
  for i = 1, #tBaoTu do
    tBaoTu[i].isjn = false
  end
  for i = 1, #tBaoTu_jn do
    local tmp = tBaoTu_jn[i]
    tmp.isjn = true
    table.insert(tBaoTu, tmp)
  end
  return tBaoTu
end

local function LYT_GetSceneInfo()
  local g_bs_base = GetBase(3)
  local g_ofDp_raid_dataptr = GetBase(4)
  local DPptr = R_P(g_bs_base) + g_ofDp_raid_dataptr
  if IsProcess64() then
    DPptr = DPptr + 724
  else
    DPptr = DPptr + 632
  end
  local lytInfo = {}
  for i = 0, 2 do
    local ptr = DPptr + i * 8
    local nSceneID = R_D(ptr)
    local nKey = R_D(ptr + 4)
    local lTemp = 274877907 * nKey
    local nTemp = lTemp >> 32
    local xTemp = nTemp >> 6
    local yTemp = nKey - xTemp * 1000
    table.insert(lytInfo, {
      x = xTemp,
      y = yTemp,
      sceneID = nSceneID,
      key = nKey
    })
  end
  return lytInfo
end

local function TWM_GetBaoTuInfo()
  local bXunHuan = true
  while bXunHuan do
    bXunHuan = false
    local tBaoTu = TWM_EnumBaoTu()
    local lytInfo = LYT_GetSceneInfo()
    local jpInfo = lytInfo[1]
    local zpInfo = lytInfo[2]
    local spInfo = lytInfo[3]
    for i = 1, #tBaoTu do
      local tmp = tBaoTu[i]
      local bNext = false
      if tmp.name == "精品灵元图" then
        if jpInfo.x <= 0 or jpInfo.y <= 0 then
          bNext = true
        end
      elseif tmp.name == "珍品灵元图" then
        if zpInfo.x <= 0 or zpInfo.y <= 0 then
          bNext = true
        end
      elseif tmp.name == "神品灵元图" and (spInfo.x <= 0 or spInfo.y <= 0) then
        bNext = true
      end
      if bNext then
        if tmp.isjn then
          local space = Bag:GetSpaceNum(0)
          if space > 0 then
            bXunHuan = true
            TempBank2BagByIndex(tmp.index)
          end
        else
          bXunHuan = true
          Dismount(300)
          Bag:UseItem(tmp.index, 300)
        end
      end
    end
    Sleep(1000)
    DebugStr(m_script_name .. ":获取灵元图坐标")
  end
  local lytInfo = LYT_GetSceneInfo()
  return lytInfo
end

local function LTY_FindTarget()
  local obj
  local nType = 0
  if GetSceneID() == m_data.sceneID then
    obj = 4
    nType = 4
    local tObj = Enum2XByClass("NPC")
    tObj = ObjFilterByStr(tObj, "存元匣", 5, "name")
    if #tObj > 0 then
      BubbleByDst(tObj)
      obj = tObj[1]
      Skill.CUseSkillByID(3, obj.id, -1, -1)
      Sleep(2000)
    end
    return obj, nType
  end
  local tObj1 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_19}", {
    1,
    0,
    0,
    0
  }, {0, -1}, 1, 0)
  local tObj1_1 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_89}", {
    1,
    0,
    0,
    0
  }, {0, -1}, 1, 0)
  local tObj2_1 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_36}", {
    1,
    0,
    0,
    0
  }, {0, -1}, 1, 0)
  local tObj2_2 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_39}", {
    1,
    0,
    0,
    0
  }, {0, -1}, 1, 0)
  local tObj2_3 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_40}", {
    1,
    0,
    0,
    0
  }, {0, -1}, 1, 0)
  local tObj3 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_18}", {
    0,
    1,
    0,
    0
  }, {0, -1}, 1, 0)
  if #tObj1 > 0 or #tObj1_1 > 0 then
    nType = 1
    if #tObj1 > 0 then
      obj = tObj1[1]
    elseif #tObj1_1 > 0 then
      obj = tObj1_1[1]
    end
    RunTo(obj.x, obj.y, 3, 1000)
    OpenTalk(obj.id, 1000)
    DialogOptionClicked("#{ZSCB_230426_21}", 1, 1000)
  elseif #tObj2_1 > 0 or #tObj2_2 > 0 or #tObj2_3 > 0 then
    nType = 2
    if #tObj2_1 > 0 then
      obj = tObj2_1[1]
    elseif #tObj2_2 > 0 then
      obj = tObj2_2[1]
    elseif #tObj2_3 > 0 then
      obj = tObj2_3[1]
    end
    Skill.CUseSkillByID(4948, obj.id, -1, -1)
    Sleep(1000)
  elseif #tObj3 > 0 then
    nType = 3
    obj = tObj3[1]
  end
  return obj, nType
end

local function LYT_Action(aItemIndex)
  local nTarget = 0
  CDG.skill_attack_jinji_disable = " 归元阵 天覆阵 地载阵 风扬阵 暗器护体 "
  if -1 ~= aItemIndex then
    FubenAttack(-1)
  end
  local nOldSceneID = GetSceneID()
  local nUseTick = -1
  while true do
    local tTar, nType = LTY_FindTarget()
    if tTar then
      nTarget = nType
      if 3 == nType then
        Target:Attack(tTar.id, 200)
        Dismount()
        GoToTarget("", 3, tTar.id)
        FubenAttack(tTar.id)
      end
    else
      PickUpLua()
      if -1 == aItemIndex then
        break
      end
      local nowScene = GetSceneID()
      if nOldSceneID ~= nowScene or IsDiFuScene(nowScene) then
        break
      end
      if 3 == nTarget and -1 == Player:GetBuff("乾坤壶：") then
        PickUpLua_Boss(15, 15, nil)
      end
      Dismount(300)
      local bUse = Bag:UseItem(aItemIndex, 800)
      if bUse then
        nUseTick = GetTickCount()
      elseif -1 == nUseTick or GetTickCount() - nUseTick > 6000 then
        break
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. ":任务中")
  end
  PickUpLua()
  return nTarget
end

local function TWM_UseBaoTu()
  local nNowScene = GetSceneID()
  local tInfo = TWM_GetBaoTuInfo()
  local tBaoTu = TWM_EnumBaoTu()
  local jpBT = Bag:FindItemInfo("精品灵元图", nil, nil, tBaoTu)
  local zpBT = Bag:FindItemInfo("珍品灵元图", nil, nil, tBaoTu)
  local spBT = Bag:FindItemInfo("神品灵元图", nil, nil, tBaoTu)
  local tarScene
  local strItem = ""
  if #jpBT > 0 then
    tarScene = tInfo[1]
    strItem = "精品灵元图"
  elseif #zpBT > 0 then
    tarScene = tInfo[2]
    strItem = "珍品灵元图"
  elseif #spBT > 0 then
    tarScene = tInfo[3]
    strItem = "神品灵元图"
  else
    return
  end
  if tarScene.x > 0 and tarScene.y > 0 then
    local strSceneName = GetSceneNameByID(tarScene.sceneID)
    PushDebugMessage(m_script_name .. "：前往%s %d,%d 使用宝图", strSceneName, math.floor(tarScene.x), math.floor(tarScene.y))
    GoToScene(tarScene.x, tarScene.y, tarScene.sceneID, 5, nil, nil, nil, m_param.use_shoufei_npc, true)
    TempBank2Bag(strItem)
    local tOld = Bag:FindItemInfo(strItem)
    local nOldCount = Bag:GetItemCount(strItem, nil, nil, tOld)
    if #tOld > 0 then
      LYT_Action(tOld[1].index)
      local nNowCount = Bag:GetItemCount(strItem)
      if nNowCount ~= nOldCount then
        m_data.count = m_data.count + 1
      end
    end
  end
end

local function WT_GetCount()
  local oldCount_1 = Bag:GetItemCount(m_param.itemName)
  local oldCount_2 = 0
  local oldCount = oldCount_1 + oldCount_2
  return oldCount
end

local function WT_TakeCBT()
  PushDebugMessage(m_script_name .. ":前往仓库取图")
  MainBankSaveItem(m_param.itemName)
  ClearBag()
  local oldCount = WT_GetCount()
  local nCnt = Bank_GetItem(m_param.itemName, 100)
  Sleep(800)
  local newCount = WT_GetCount()
  if oldCount >= newCount then
    m_param.take_bank = false
  end
end

local function WT_Buy_SD()
  local nTickOut = -1
  CloseAllWindow()
  ClearBag()
  local bBuy = false
  local nSubType = 0
  Bank_GetMoney(5000000, "苏州")
  while true do
    if -1 ~= m_data.npcID and IsWindowVisible("PetNeidan_Shop") then
      local nRetType, nSubRet = YDF_BuyAction("精品灵元图", 5)
      if 0 == nRetType then
        nSubType = nSubRet
        break
      else
        bBuy = true
      end
    else
      GoToSceneNPC("云丹丹", 178, 231, 1)
      local tObj = Enum2XByName("云丹丹", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        m_data.npcID = tObj[1].id
        Sleep(500)
        DialogOptionClicked("元丹坊", 1, 1000)
      end
      Sleep(500)
    end
    if -1 == nTickOut then
      nTickOut = GetTickCount()
    end
    if GetTickCount() - nTickOut > 180000 then
      LogMsg(m_script_name .. ":购买超时")
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
  if bBuy then
    m_data.buy_sd = true
  elseif 3 == nSubType then
    m_data.buy_sd = false
  elseif 5 == nSubType then
    m_data.buy_sd = false
  elseif 6 == nSubType then
    m_data.buy_count = m_data.buy_count + 1
    if m_data.buy_count >= 3 then
      LogMsg(m_script_name .. ":金币不够")
      m_data.buy_sd = false
    end
  end
  Bank_SaveMoney(0)
end

function _SMain(...)
  CloseAllWindow()
  LoadScript("fn元丹坊")
  while true do
    PickUpLua(nil, true)
    if 0 == LYT_Action(-1) then
      local tBaoTu = TWM_EnumBaoTu()
      if 0 == #tBaoTu then
        Bag:PackUp(-1)
        Sleep(2000)
        if m_param.buy_sd and m_data.buy_sd then
          WT_Buy_SD()
        elseif m_param.take_bank then
          WT_TakeCBT()
        else
          PushColorMsg(m_script_name .. "：已没有灵元图!")
          break
        end
      else
        m_data.buy_sd = true
        TWM_UseBaoTu()
      end
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
  Bag:PackUp(-1)
  if not IsSafeSceneID() then
    GoBackCity()
  end
end

_SMain()
ScriptOnStop(m_script_name)
