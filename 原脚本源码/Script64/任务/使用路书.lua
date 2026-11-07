-- 反编译自 dfz64.dll 内嵌字节码 00292f75（unluac 2025-12-23；仅供分析）
local m_script_name = "自动挖路书"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
local m_param = {}
m_param.sceneID = 110
m_param.use_shoufei_npc = GetConfigBool("挖藏宝图", "收费传送")
m_param.open_box = GetConfigBool("挖藏宝图", "开宝箱")
m_param.take_bank = GetConfigBool("挖藏宝图", "仓库取图")
m_param.take_shanghui = GetConfigBool("挖藏宝图", "商会取图")
m_param.shanghui_ids = GetConfigText("挖藏宝图", "取图店铺")
m_param.buy_shanghui = GetConfigBool("挖藏宝图", "商会买图")
m_param.buy_j = HandleTextToNumber(GetConfigText("挖藏宝图", "买图金"), 0)
m_param.buy_y = HandleTextToNumber(GetConfigText("挖藏宝图", "买图银"), 0)
m_param.buy_t = HandleTextToNumber(GetConfigText("挖藏宝图", "买图铜"), 0)
m_param.buy_max_count = HandleTextToNumber(GetConfigText("挖藏宝图", "买图张数"), 0)
m_param.key_count = HandleTextToNumber(GetConfigText("挖藏宝图", "开宝箱钥匙"), 0)
m_param.wt_count = 0
m_param.buy_record = 0
m_param.box_record = {}
local m_data = {}
m_data.count = 0

local function wbt_cb_in_fb(fX, fY, nSceneID)
  if GetSceneID() ~= m_param.sceneID then
    return false
  end
  PickUpLua()
  return true
end

local function WT_EnumObj()
  local tItem = {}
  local tObj = Enum2XByClass("矿地")
  for i = 1, #tObj do
    if tObj[i].name == "宝箱" then
      table.insert(tItem, tObj[i])
    end
  end
  local tTar = ObjFilterByRecord(tItem, m_param.box_record)
  if #tTar > 0 then
    return tTar[1]
  end
  return nil
end

local function WT_KaiXiangZi()
  local xiangzi_Pos = {
    {x = 23, y = 23},
    {x = 16, y = 46},
    {x = 51, y = 32},
    {x = 31, y = 39}
  }
  m_param.box_record = {}
  if m_param.open_box then
    local nCount = Bag:GetItemCount("宝箱钥匙", nil, nil, Bag:EnumCailiaoItem())
    if nCount < m_param.key_count then
      PushColorMsg("背包钥匙低于,不开宝箱 " .. m_param.key_count .. " " .. nCount)
      return
    end
    for k = 1, 5 do
      for i = 1, #xiangzi_Pos do
        PickUpLua()
        if GetSceneID() ~= m_param.sceneID then
          break
        end
        local nCount = Bag:GetItemCount("宝箱钥匙", nil, nil, Bag:EnumCailiaoItem())
        if 0 == nCount then
          PushDebugMessage(m_script_name .. ":已经没有宝箱钥匙")
          break
        end
        local nSpaceNum = Bag:GetSpaceNum(0)
        if nSpaceNum < 2 then
          PushDebugMessage(m_script_name .. ":开图背包空格不足")
          break
        end
        for j = 0, 2 do
          nCount = Bag:GetItemCount("宝箱钥匙", nil, nil, Bag:EnumCailiaoItem())
          if 0 == nCount then
            break
          end
          MoveTo(xiangzi_Pos[i].x, xiangzi_Pos[i].y, -1, 3, nil, nil, wbt_cb_in_fb)
          local tar = WT_EnumObj()
          if tar then
            MoveTo(tar.x, tar.y, -1, 3, nil, nil, wbt_cb_in_fb)
            Sleep(200)
            Dismount()
            Sleep(200)
            Skill:UseName("初级隐遁", 500)
            OpenPackage(tar.id)
            Sleep(1500)
            if 8 == Player:GetState() then
              m_param.box_record = ObjTickPush(m_param.box_record, tar.id)
              PlayerStateTimeOut(8, 8)
              Sleep(500)
              GetLuaValue("if IsWindowShow('LootPacket')==true then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close();end;")
              Sleep(500)
            end
          end
        end
        Sleep(500)
        PickUpLua()
        DebugStr(m_script_name .. ":自动开宝箱中.")
      end
      local nCount = Bag:GetItemCount("宝箱钥匙", nil, nil, Bag:EnumCailiaoItem())
      if 0 == nCount then
        break
      end
    end
  end
end

local function WT_BuyCBT()
  PushDebugMessage(m_script_name .. ":商会购买路书")
  Bag:PackUp(-1)
  local buyPrice = m_param.buy_j * 10000 + m_param.buy_y * 100 + m_param.buy_t
  if buyPrice > 0 then
    local needMoney = (m_param.buy_max_count - m_param.buy_record) * buyPrice
    local nowMoney = Player:GetMoney()
    if needMoney > nowMoney then
      Bank_GetMoney(needMoney, "洛阳")
      Sleep(500)
    end
    local bBuySuccess = true
    DeleteDebugMsg("数据已改变，请重新打开商店")
    for i = 1, 50 do
      if 0 == Bag:GetSpaceNum(0) then
        break
      end
      local nNum, nPrice = ShangHui_BuyItem("路书", 1, buyPrice)
      if nNum > 0 then
        if IsInDebugMsg("数据已改变，请重新打开商店") then
          bBuySuccess = false
          DeleteDebugMsg("数据已改变，请重新打开商店")
        else
          m_param.buy_record = m_param.buy_record + 1
        end
        if m_param.buy_record >= m_param.buy_max_count then
          m_param.buy_shanghui = false
          break
        end
        Sleep(300)
      end
      if IsInFubenScene() then
        break
      end
    end
    if Player:GetMoney() > 10000 then
      Bank_SaveMoney(0)
    end
    if 0 == Bag:GetItemCount("路书") then
      PushDebugMessage(m_script_name .. ":商会未能成功购买路书.")
      if bBuySuccess then
        m_param.buy_shanghui = false
      end
    end
    PushDebugMessage(m_script_name .. "：总共已经购买%d张图", m_param.buy_record)
  else
    PushDebugMessage(m_script_name .. ":您未设置购买单价,不购买宝图")
    m_param.buy_shanghui = false
  end
end

local function WT_GetCount()
  local oldCount_1 = Bag:GetItemCount("路书")
  local oldCount_2 = Bag:GetItemCount("未破译的路书")
  local oldCount = oldCount_1 + oldCount_2
  return oldCount
end

local function WT_TakeCBT()
  PushDebugMessage(m_script_name .. ":前往仓库取图")
  MainBankSaveItem("路书 未破译的路书")
  ClearBag()
  local oldCount = WT_GetCount()
  local nCnt = Bank_GetItem(" 路书 未破译的路书 ", 100)
  Sleep(800)
  local newCount = WT_GetCount()
  if oldCount >= newCount then
    m_param.take_bank = false
  end
end

local function WT_TakeCBT_sh()
  PushDebugMessage(m_script_name .. ":前往商会取图")
  MainBankSaveItem("路书 未破译的路书")
  ClearBag()
  local oldCount = WT_GetCount()
  SHQW_OnStart(m_param.shanghui_ids, "路书|0|1 未破译的路书|0|1")
  Sleep(800)
  local newCount = WT_GetCount()
  if oldCount >= newCount then
    m_param.take_shanghui = false
  end
end

local function TWM_EnumBaoTu()
  local tBaoTu = Bag:FindBaoTu(nil, "路书")
  local tBaoTu_jn = Bag:FindBaoTu(Bag:EnumTempBagItem(), "路书")
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

local function TWM_GetBaoTuInfo()
  local tBaoTu = {}
  local bXunHuan = true
  while bXunHuan do
    bXunHuan = false
    tBaoTu = TWM_EnumBaoTu()
    for i = 1, #tBaoTu do
      local tmp = tBaoTu[i]
      if 0 == tmp.pos.data then
        if tmp.isjn then
          local space = Bag:GetSpaceNum(0)
          if space > 1 then
            bXunHuan = true
            TempBank2BagByIndex(tmp.index)
          end
        else
          local space = Bag:GetSpaceNum(0)
          if space > 2 then
            bXunHuan = true
            Bag:UseItem(tmp.index, 300)
          end
        end
      elseif not tmp.isjn then
        local tMove = {}
        table.insert(tMove, tmp)
      end
    end
    Sleep(1000)
    DebugStr(m_script_name .. ":获取宝图坐标")
  end
  local cur_scene_name = GetCurrentSceneName()
  cur_scene_name = string.gsub(cur_scene_name, "1线", "")
  cur_scene_name = string.gsub(cur_scene_name, "2线", "")
  local selfPos = Player:GetPos()
  for i = 1, #tBaoTu do
    local tmp = tBaoTu[i]
    tmp.x = tmp.pos.x
    tmp.y = tmp.pos.y
    tmp.pos.sceneID = tmp.pos.sceneResID
    tmp.sceneID = tmp.pos.sceneID
    tmp.sceneName = GetSceneNameByID(tmp.sceneID)
    tmp.dst = GetDist(tmp.x, tmp.y, selfPos.x, selfPos.y)
    tmp.dist = CMGraph:GetDist(cur_scene_name, tmp.sceneName)
  end
  local tValid = TableDeleteTable(tBaoTu, {
    {sceneID = -1}
  }, "sceneID")
  return tValid
end

local function TWM_UseBaoTu()
  local nNowScene = GetSceneID()
  local tBaoTu = TWM_GetBaoTuInfo()
  local tCurSceneMT = GetTableFieldValue(tBaoTu, "sceneID", {nNowScene})
  local tuse
  if #tCurSceneMT > 0 then
    BubbleByDst(tCurSceneMT)
    tuse = tCurSceneMT[1]
  elseif #tBaoTu > 0 then
    BubbleByDist(tBaoTu)
    if #tBaoTu > 1 then
      tuse = tBaoTu[2]
    else
      tuse = tBaoTu[1]
    end
  end
  if tuse then
    local strSceneName = GetSceneNameByID(tuse.sceneID)
    PushDebugMessage(m_script_name .. "：前往%s %d,%d 使用宝图", strSceneName, math.floor(tuse.x), math.floor(tuse.y))
    
    local function _cb(...)
      return GetSceneID() ~= m_param.sceneID
    end
    
    MoveTo(tuse.x, tuse.y, tuse.sceneID, 5, nil, nil, _cb, m_param.use_shoufei_npc, true)
    local tOld = GetTableFieldValue(Bag:EnumTempBagItem(), "id", {
      tuse.id
    })
    if #tOld > 0 then
      PushDebugMessage(m_script_name .. ":从锦囊移出宝图" .. tOld[1].index)
      for i = 1, 3 do
        TempBank2BagByIndex(tOld[1].index)
        Sleep(300)
        tOld = GetTableFieldValue(Bag:EnumTempBagItem(), "id", {
          tuse.id
        })
        if 0 == #tOld then
          break
        end
      end
    end
    tOld = GetTableFieldValue(Bag:EnumTempBagItem(), "id", {
      tuse.id
    })
    if #tOld > 0 then
      PushColorMsg(m_script_name .. ":从锦囊移出宝图失败")
      return
    end
    tOld = GetTableFieldValue(Bag:EnumDaoJuItem(), "id", {
      tuse.id
    })
    if #tOld > 0 then
      for i = 1, 3 do
        local space = Bag:GetSpaceNum(0)
        if space >= 1 then
          Bag:UseItem(tOld[1].index, 800)
        end
        tOld = GetTableFieldValue(Bag:EnumDaoJuItem(), "id", {
          tuse.id
        })
        if 0 == #tOld then
          m_data.count = m_data.count + 1
          break
        end
      end
    end
  end
end

local function WT_UseWPY()
  if 0 == Bag:GetSpaceNum(0) then
    DebugColorMsg("背包已满,无法使用路书", 2)
    local tItem = Bag:FindItemInfo("路书")
    if #tItem > 1 then
      local _ItemInfo = tItem[1]
      local tNullPos = TempBankGetNullPos()
      if #tNullPos > 0 then
        PushColorMsg("%s：移动到锦囊", _ItemInfo.name)
        math.randomseed(GetTickCount())
        local idx = math.random(1, #tNullPos)
        BagBankTempMove(_ItemInfo.index, tNullPos[idx].index, true)
        Sleep(50)
      end
    end
  end
  for i = 1, 50 do
    local tItem = Bag_GetItemLimitCanUse("路书", 89, nil)
    if #tItem > 0 then
      Bag:UseItem(tItem[1].index, 50)
    else
      break
    end
    Sleep(10)
  end
end

local function Bag_GetItemCanUseCount(aItemName, aCheckLevel, atItem)
  aCheckLevel = 89
  local tItem = Bag_GetItemLimitCanUse(aItemName, aCheckLevel, atItem)
  return #tItem
end

function OnStarBoss(guaiName)
  local guaibool = true
  while guaibool do
    guaibool = false
    tObj = Enum2XByClass("怪物")
    for i = 1, #tObj do
      if tObj[i].name == guaiName then
        FubenAttack(tObj[i].id)
        guaibool = true
        Sleep(500)
      end
    end
  end
end

function OnRenwu()
  tObj = Enum2XByClass("NPC 怪物")
  for i = 1, #tObj do
    if string.find(tObj[i].title, "#{CPBT_260115_43", nil, true) then
      Dismount()
      if tObj[i].class == "怪物" then
        OnStarBoss(tObj[i].name)
        break
      end
      if tObj[i].class == "NPC" then
        Team:LeaveTeam()
        TalkNpc(tObj[i].name, 400)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_46}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_47}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_53}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_54}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_93}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_94}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_95}", 1, 200)
        Sleep(200)
        QuestFrameOptionClicked_Item("#{CPBT_260115_96}", 1, 200)
        Sleep(200)
        break
      end
    end
    if string.find(tObj[i].name, "夺宝马贼", nil, true) and tObj[i].hp > 0 then
      break
    end
    if string.find(tObj[i].name, "#{CPBT_260115_60", nil, true) then
      Dismount()
      Team:LeaveTeam()
      Sleep(1000)
      Team:CreateTeam()
      Sleep(1000)
      TalkNpc(tObj[i].name, 400)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{CPBT_260115_62}", 1, 600)
      GetLuaValue("setmetatable(_G, {__index = WuhunQuest_Env});WuhunQuest_Bn1Click();")
      Sleep(1500)
      break
    end
  end
  Sleep(1000)
  while GetSceneID() == 1060 do
    tObj = Enum2XByClass("NPC")
    if #tObj > 0 then
      for i = 1, #tObj do
        if string.find(tObj[i].name, "桃源秘宝", nil, true) then
          Skill.CUseSkillByID(6026, tObj[i].id, -1, -1)
          Sleep(1500)
        end
      end
    else
      MoveTo(66, 69)
    end
  end
  while GetSceneID() == 1059 do
    tObj = Enum2XByClass("怪物 NPC")
    if #tObj > 0 then
      for i = 1, #tObj do
        if Player:IsLeader() then
          if string.find(tObj[i].name, "洞府奇珍匣", nil, true) then
            Skill.CUseSkillByID(6025, tObj[i].id, -1, -1)
            Sleep(1500)
            GetLuaValue("setmetatable(_G, {__index = Collection_CangbaotuGiftBox_Six_Env});Collection_CangbaotuGiftBox_Six_OnItemClicked(1)")
            GetLuaValue("setmetatable(_G, {__index = Collection_CangbaotuGiftBox_Six_Env});Collection_CangbaotuGiftBox_Six_OnGetClicked()")
          end
        elseif string.find(tObj[i].name, "洞府仙灵", nil, true) then
          Skill.CUseSkillByID(6025, tObj[i].id, -1, -1)
          Sleep(1500)
        end
        if string.find(tObj[i].name, "洞府恶念", nil, true) then
          local fucs_Obj = Enum2XByClass("陷阱")
          if #fucs_Obj > 0 then
            local shanxing = fucs_Obj[1]
            local param = {}
            param.useqg = true
            param.usesx = true
            bSafe = FubenTrapRun("", tObj[i].x, tObj[i].y, 16, 25, fucs_Obj, nil, FubenRunSafe, nil, nil, param)
            if bSafe then
              FubenAttack(tObj[i].id)
              Sleep(200)
            end
          else
            if GetDist(63, 65) > 5 then
              RunTo(63, 65)
            else
              FubenAttack(tObj[i].id)
            end
            Sleep(200)
          end
        end
      end
    else
      MoveTo(63, 65)
    end
  end
end

function _SMain(...)
  LeaveSpecialScene(nil, nil)
  LoadScript("shanghui")
  TempBank2Bag("路书")
  Sleep(500)
  local nWPYOut = -1
  while true do
    local curScene = GetSceneID()
    if curScene == m_param.sceneID then
      Bag:PackUp(-1)
      ClearBag()
      Sleep(500)
      MoveTo(28, 31, m_param.sceneID, nil, nil, nil, wbt_cb_in_fb)
      Sleep(200)
      Dismount()
      Sleep(200)
    else
      if 0 == Bag:GetSpaceNum(0) then
        PushColorMsg("满了")
        break
      end
      Dismount()
      PickUpLua()
      Bag:PackUp(-1)
      for i = 1, 3 do
        OnRenwu()
      end
      if Player:GetHP() < 40000 then
        XiaoChangHuiXue(50, true)
      end
      PickUpLua()
      if m_param.wt_count > 0 and m_data.count >= m_param.wt_count then
        LogMsg(m_script_name .. ":已达到指定的挖图次数!")
        Sleep(3000)
        if GetSceneID() ~= m_param.sceneID then
          break
        end
      end
      if Bag:GetSpaceNum(1) <= 1 then
        Sleep(500)
        PushDebugMessage(m_script_name .. ":材料栏空格不足,可能无法拾取宝箱钥匙")
        MainBankSaveItem("路书")
      end
      if 0 == Bag:GetItemCount("路书") and 0 == Bag:GetItemCount("路书", nil, nil, Bag:EnumTempBagItem()) then
        Bag:PackUp(-1)
        Sleep(2000)
        if GetSceneID() == m_param.sceneID then
          goto lbl_249
        end
        if 0 == Bag_GetItemCanUseCount("路书") then
          if 0 == Bag_GetItemCanUseCount("路书", nil, Bag:EnumTempBagItem()) then
            if m_param.take_bank then
              WT_TakeCBT()
            elseif m_param.take_shanghui then
              WT_TakeCBT_sh()
            elseif m_param.buy_shanghui then
              WT_BuyCBT()
            else
              PushColorMsg(m_script_name .. "：已没有路书!")
              Sleep(3000)
              if GetSceneID() ~= m_param.sceneID then
                break
              end
            end
          else
            TempBank2Bag("路书")
          end
        else
          TempBank2Bag("路书")
          Sleep(500)
          WT_UseWPY()
        end
      else
        if 0 == Bag:GetSpaceNum(1) then
          local tItem = Bag:EnumCailiaoItem()
          if #tItem > 0 then
            local _ItemInfo = tItem[1]
            local tNullPos = TempBankGetNullPos()
            if #tNullPos > 0 then
              PushColorMsg("材料包已满,随机移动物品到锦囊：%s", _ItemInfo.name)
              math.randomseed(GetTickCount())
              local idx = math.random(1, #tNullPos)
              BagBankTempMove(_ItemInfo.index, tNullPos[idx].index, true)
              Sleep(50)
            end
          end
        end
        TWM_UseBaoTu()
      end
    end
    ::lbl_249::
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
m_param = nil
