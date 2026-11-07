-- 反编译自 dfz64.dll 内嵌字节码 0036e251（unluac 2025-12-23；仅供分析）
local m_script_name = "天外马贼"
ScriptOnStart(m_script_name, true, false)
g_config.twmz = {}
g_config.twmz.mode_2 = ReadConfigBool("ZH", "dxk6")
g_config.twmz.mode2_scene = ReadConfigText("ZH", "bjk6")
g_config.twmz.mode1_wait_sec = ReadConfigInt("ZH", "bjk124")
g_config.twmz.kill_count = ReadConfigInt("ZH", "bjk5")
g_config.twmz.die_wait = ReadConfigBool("ZH", "xzk71")
g_config.twmz.die_wait_min = ReadConfigInt("ZH", "bjk119")
g_config.twmz.cuncang = ReadConfigBool("ZH", "xzk63")
g_config.twmz.cuncang_space = ReadConfigInt("ZH", "bjk23")
g_config.twmz.tu_bank_take = ReadConfigBool("ZH", "xzk62")
g_config.twmz.tu_sh_take = ReadConfigBool("ZH", "xzk64")
g_config.twmz.sh_id_text = ReadConfigText("ZH", "bjk7")
g_config.twmz.tu_buy_count = ReadConfigInt("ZH", "bjk33")
g_config.twmz.tu_buy_shanghui = ReadConfigBool("ZH", "xzk65")
g_config.twmz.tu_buy_tianwai = false
g_config.twmz.tu_buy_j = ReadConfigInt("ZH", "bjk16")
g_config.twmz.tu_buy_y = ReadConfigInt("ZH", "bjk31")
g_config.twmz.tu_buy_t = ReadConfigInt("ZH", "bjk32")
g_config.twmz.tu_buy_yb = 0
g_config.twmz.jiaoyi = ReadConfigBool("ZH", "xzk76")
g_config.twmz.over_noitem = ReadConfigBool("ZH", "xzk61")
g_config.twmz.over_checktime = ReadConfigBool("ZH", "xzk66")
g_config.twmz.over_day = GetConfigCommbox("天外马", "结束日")
g_config.twmz.over_h = GetConfigCommbox("天外马", "结束时")
g_config.twmz.over_m = GetConfigCommbox("天外马", "结束分")
g_config.twmz.auto_team = ReadConfigBool("ZH", "xzk78")
CDG:InitFubenParam()
CDG.attack = true
CDG.jgyc = true
CDG.hp.em_yxjx = false
g_pick.pickmode = 0
local m_param = {}
m_param.mode = 1
if g_config.twmz.mode_2 then
  m_param.mode = 2
end
m_param.mode2_scene = g_config.twmz.mode2_scene
m_param.wait_mz_sec = HandleTextToNumber(g_config.twmz.mode1_wait_sec, 0)
m_param.kill_count = HandleTextToNumber(g_config.twmz.kill_count, 3)
m_param.not_sydt = false
m_param.sydt_handle = 1
m_param.die_wait = g_config.twmz.die_wait
m_param.die_wait_min = HandleTextToNumber(g_config.twmz.die_wait_min, 0)
m_param.cuncang = g_config.twmz.cuncang
m_param.cuncang_space = HandleTextToNumber(g_config.twmz.cuncang_space, 2)
m_param.tu_bank_take = g_config.twmz.tu_bank_take
m_param.tu_sh_take = g_config.twmz.tu_sh_take
m_param.sh_id_text = g_config.twmz.sh_id_text or ""
m_param.tu_buy_count = HandleTextToNumber(g_config.twmz.tu_buy_count, 5)
m_param.tu_buy_shanghui = g_config.twmz.tu_buy_shanghui
m_param.tu_buy_tianwai = g_config.twmz.tu_buy_tianwai
m_param.tu_buy_j = HandleTextToNumber(g_config.twmz.tu_buy_j, 0)
m_param.tu_buy_y = HandleTextToNumber(g_config.twmz.tu_buy_y, 0)
m_param.tu_buy_t = HandleTextToNumber(g_config.twmz.tu_buy_t, 0)
m_param.tu_buy_yb = HandleTextToNumber(g_config.twmz.tu_buy_yb, 0)
m_param.jiaoyi = g_config.twmz.jiaoyi
m_param.over_noitem = g_config.twmz.over_noitem
m_param.over_time = -1
if g_config.twmz.over_checktime then
  local ttab = os.date("*t")
  local hour = g_config.twmz.over_h.sel
  local min = g_config.twmz.over_m.sel
  ttab.hour = hour
  ttab.min = min
  m_param.over_time = os.time(ttab)
  if 1 == g_config.twmz.over_day.sel then
    local oneday = 86400
    m_param.over_time = m_param.over_time + oneday
  end
  local nowTime = os.time()
  local diffTime = m_param.over_time - nowTime
  PushColorMsg("天外马：将在%d分钟后结束！", math.floor(diffTime / 60))
end
local isInLeader = false
local m_data = {}
m_data.die_just = {}
m_data.pos_just = {}
m_data.allKillCount = 0
m_data.tickCunCang = 0
m_data.pos = {
  x = -1,
  y = -1,
  sceneID = -1
}
m_data.over = false
m_data.oldmz = {}
m_data.oldmz_tick = GetTickCount() - 30000
m_data.buyCount = 0
m_data.buyTick = -1
m_data.noitemTick = -1
m_data.jy_x = 244
m_data.jy_y = 130
m_data.over_x = 189
m_data.over_y = 118
local g_KvKMaZeiScene = {
  [855] = {
    sceneName = "漠南青原",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [856] = {
    sceneName = "忘川花海",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [857] = {
    sceneName = "天岐南淮",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [854] = {
    sceneName = "林海溪谷",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [860] = {
    sceneName = "水月洞天",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [669] = {
    sceneName = "沁水丹林",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [670] = {
    sceneName = "云遥鹊岭",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [756] = {
    sceneName = "千帆寨",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [758] = {
    sceneName = "古今亭",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [759] = {
    sceneName = "枯荣道",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [763] = {
    sceneName = "望风古原",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [764] = {
    sceneName = "剑兰坡",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [765] = {
    sceneName = "余霞港",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [766] = {
    sceneName = "星渔湾",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [767] = {
    sceneName = "冷雁横川",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [768] = {
    sceneName = "云梦泽",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [769] = {
    sceneName = "碧笋春林",
    ServerResID = -1,
    nowMazeiCnt = 0
  },
  [770] = {
    sceneName = "雨竹岗",
    ServerResID = -1,
    nowMazeiCnt = 0
  }
}

local function TWM_GetSceneIDByResID()
  for i, v in pairs(g_KvKMaZeiScene) do
    if -1 == g_KvKMaZeiScene[i].ServerResID then
      g_KvKMaZeiScene[i].ServerResID = GetMapIDBySceneID(i)
    end
  end
  return -1
end

local function TWM_TongJiAdd()
  local nScene = GetSceneID()
  m_data.allKillCount = m_data.allKillCount + 1
  if g_KvKMaZeiScene[nScene] then
    g_KvKMaZeiScene[nScene].nowMazeiCnt = g_KvKMaZeiScene[nScene].nowMazeiCnt + 1
    local strMsg = fmt("天外马：总杀马%d只, %s 杀马%d只", m_data.allKillCount, g_KvKMaZeiScene[nScene].sceneName, g_KvKMaZeiScene[nScene].nowMazeiCnt)
    LogMsg(strMsg)
  else
    local strMsg = fmt("天外马：总杀马%d只。", m_data.allKillCount)
    LogMsg(strMsg)
  end
end

local function TWM_TongJiCheckDie(tObj)
  local tTmp = {}
  for i = 1, #tObj do
    if tObj[i].hp > 0 then
      local n = #tTmp + 1
      tTmp[n] = tObj[i]
    else
      local bJoin = true
      for j = 1, #m_data.die_just do
        if m_data.die_just[j].id == tObj[i].id then
          bJoin = false
          break
        end
      end
      if bJoin then
        if #m_data.die_just > 10 then
          table.remove(m_data.die_just, 1)
        end
        m_data.die_just[#m_data.die_just + 1] = tObj[i]
        TWM_TongJiAdd()
      end
    end
  end
  return tTmp
end

local function TWM_OnDie()
  if 9 == Player:GetState() then
    local selfPos = Player:GetPos()
    m_data.pos.x = selfPos.x
    m_data.pos.y = selfPos.y
    m_data.pos.sceneID = GetSceneID()
    Player:TeamFollow(false, 300)
    while 9 == Player:GetState() do
      DieRelive(-1)
      Sleep(3000)
      DebugStr("天外马:角色死亡")
    end
    Sleep(2000)
    CDG:checkDiFu()
    MainSellBuyItem(nil, m_script_name)
    MainBankSaveItem("稀世珍宝图")
    local nNowTick = GetTickCount()
    while m_param.die_wait and GetTickCount() - nNowTick < m_param.die_wait_min * 60 * 1000 and GetSceneID() == 850 do
      Sleep(3000)
      if -1 ~= m_param.over_time and os.time() > m_param.over_time then
        PushColorMsg("天外马:已到达设置的结束时间！")
        m_data.over = true
        break
      end
      DebugStr("天外马:死亡等待%d分钟", nil, m_param.die_wait_min)
    end
  end
end

local function TWM_CheckCunCang()
  if GetTickCount() - m_data.tickCunCang > 60000 then
    Bag:PackUpTempBag(500)
    if m_param.cuncang then
      local spaceNum = Bag:GetSpaceNum(0)
      local spaceNum2 = Bag:GetSpaceNum(1)
      if (0 == spaceNum or 0 == spaceNum2 or spaceNum < m_param.cuncang_space or spaceNum2 < m_param.cuncang_space) and 9 ~= Player:GetState() then
        PushDebugMessage("天外马:需要存仓")
        Player:TeamFollow(false, 300)
        MainSellBuyItem(nil, m_script_name)
        MainBankSaveItem("稀世珍宝图")
        Sleep(1000)
      end
    end
    m_data.tickCunCang = GetTickCount()
  end
end

local function TWM_CheckFollow(fX, fY, aSceneID)
  if not IsDestination(fX, fY, aSceneID, 25) then
    if not IsMount() then
      Player:TeamFollow(false, 300)
      UseMount()
      Sleep(300)
    end
    if not Player:IsFollow() then
      UseMount()
      PickUpLua(nil, true)
      Player:TeamFollow(true, 300)
    end
  end
end

local function twm_move_cb(fX, fY, nScene)
  if not Player:IsLeader() then
    return false
  end
  TWM_CheckFollow(fX, fY, nScene)
  return true
end

local function TWM_EnumObj()
  local tObj = Enum2XByName("夺宝马贼头领", {
    0,
    1,
    0,
    0
  }, nil, nil, 0)
  tObj = ObjFilterByColor(tObj, "红绿")
  tObj = TWM_TongJiCheckDie(tObj)
  return tObj
end

local function TWM_FindObject()
  local tObj = TWM_EnumObj()
  if #tObj > 0 then
    local tNew = {}
    if GetTickCount() - m_data.oldmz_tick < 5000 then
      tNew = TableDeleteTable(tObj, m_data.oldmz, "id")
    end
    local tar
    if #tNew > 0 then
      BubbleByDst(tNew)
      tar = tNew[1]
    else
      BubbleByDst(tObj)
      tar = tObj[1]
    end
    return true, tar, tObj
  end
  return false, nil, {}
end

local function TWM_GetMaTuCount()
  local bagCount = Bag:GetItemCount("稀世珍宝图")
  local tempbagCount = Bag:GetItemCount("稀世珍宝图", nil, nil, Bag:EnumTempBagItem())
  return bagCount + tempbagCount
end

local function TWM_BuyAction(aCB)
  for i = 1, 50 do
    Bag_Move2TempBank("稀世珍宝图", nil, nil, false)
    Sleep(300)
    local spaceNum = Bag:GetSpaceNum(0)
    if spaceNum <= 1 then
      Bag_DeleteBagItem()
      Sleep(500)
    end
    spaceNum = Bag:GetSpaceNum(0)
    if spaceNum <= 1 then
      PushColorMsg("天外马:背包空位不足2格")
      break
    end
    if m_param.tu_buy_count > 0 and m_data.buyCount >= m_param.tu_buy_count then
      m_param.tu_buy_tianwai = false
      m_param.tu_buy_shanghui = false
      LogMsg("天外马:已超出买图上限")
      break
    end
    DebugStr("天外马：购买马图")
    local oldCount = TWM_GetMaTuCount()
    aCB()
    local buyCount = TWM_GetMaTuCount() - oldCount
    m_data.buyCount = m_data.buyCount + buyCount
  end
  m_data.buyTick = GetTickCount()
end

local function JY_CheckItem()
  local hasOtherItem = false
  local selfHasItem = false
  local tItem = Bag:EnumJiaoYiOtherItem()
  local tYBP = Bag:FindItemInfo("稀世珍宝图", nil, nil, tItem)
  if #tYBP ~= #tItem then
    hasOtherItem = true
  end
  local tItem = Bag:EnumJiaoYiSelfItem()
  if #tItem > 0 then
    selfHasItem = true
  end
  return hasOtherItem, selfHasItem
end

local function TWM_Exchange_leader()
  if not m_param.jiaoyi then
    return false
  end
  if Player:IsLeader() then
    local last_exchange_tick = -1
    local oldCount = TWM_GetMaTuCount()
    while Player:IsLeader() do
      GoToScene(m_data.jy_x, m_data.jy_y, 850)
      Bag_Move2TempBank("稀世珍宝图", nil, nil, false)
      if IsWindowVisible("Exchange") then
        local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
        local teamName = HandleText_AddFuHao(Team:GetAllName(), " ", true)
        if string.find(teamName, " " .. otherName .. " ", nil, true) then
          local nStartTick = GetTickCount()
          while IsWindowVisible("Exchange") do
            if GetTickCount() - nStartTick > 45000 then
              PushColorMsg("%s:交易超时", otherName)
              CloseWindow("Exchange")
              break
            end
            if Exchange_IsLocked("other") and Exchange_IsLocked("self") then
              local hasOther1, hasOther2 = JY_CheckItem()
              if hasOther1 or hasOther2 then
                PushColorMsg("交易物品不正确")
                CloseWindow("Exchange")
                break
              end
              if 0 ~= Exchange_GetMoney("self") then
                CloseWindow("Exchange")
                break
              end
              if not Exchange_IsLocked("other") or not Exchange_IsLocked("self") then
                CloseWindow("Exchange")
                break
              else
                GetLuaValue("Exchange:AcceptExchange()")
                Sleep(500)
                local nTick1 = GetTickCount()
                while IsWindowVisible("Exchange") and Exchange_IsLocked("other") and Exchange_IsLocked("self") do
                  Sleep(500)
                  if GetTickCount() - nTick1 > 8000 then
                    PushDebugMessage("对方超过8秒没有确定交易！")
                    CloseWindow("Exchange")
                    break
                  end
                end
              end
            elseif Exchange_IsLocked("other") then
              Sleep(1000)
              Exchange_LockExchange()
              Sleep(1500)
            elseif Exchange_IsLocked("self") then
              CloseWindow("Exchange")
              break
            else
              local hasOther1, hasOther2 = JY_CheckItem()
              if hasOther1 or hasOther2 then
                PushColorMsg("交易物品不正确")
                CloseWindow("Exchange")
                break
              end
              if 0 ~= Exchange_GetMoney("self") then
                CloseWindow("Exchange")
                break
              end
            end
            Sleep(500)
            DebugStr("与 %s 交易中", nil, otherName)
          end
          local newCount = TWM_GetMaTuCount()
          if newCount ~= oldCount then
            oldCount = newCount
            last_exchange_tick = GetTickCount()
          end
        else
          PushColorMsg("非队员,取消交易")
          CloseWindow("Exchange")
        end
      elseif Exchange_IsInList() then
        GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env});MainMenuBar_Exchange_Clicked();")
        Sleep(800)
      elseif GetTickCount() - last_exchange_tick > 30000 then
        goto lbl_265
      end
      Sleep(500)
      DebugStr("等待交易宝图中,30秒超时")
    end
  else
  end
  ::lbl_265::
  if TWM_GetMaTuCount() > 0 then
    return true
  else
    if -1 == m_data.noitemTick then
      m_data.noitemTick = GetTickCount()
    end
    if GetTickCount() - m_data.noitemTick < 120000 then
      DebugStr("天外马：120秒没有队员交易将判断购买宝图", 2)
      return true
    else
      m_data.noitemTick = -1
    end
  end
  return false
end

local function TWM_TakeBaoTu()
  local spaceNum = Bag:GetSpaceNum(0)
  local nGetNum = spaceNum - 0
  if nGetNum <= 0 then
    nGetNum = 1
  end
  if GetTickCount() - m_data.tickCunCang > 120000 then
    MainSellBuyItem(nil, m_script_name)
    MainBankSaveItem("稀世珍宝图")
    m_data.tickCunCang = GetTickCount()
  end
  if m_param.tu_bank_take then
    Sleep(1000)
    PushColorMsg("仓库取图")
    local bankItem = Bank_EnumItem()
    if 0 == #bankItem then
      bankItem = Bank_EnumItem(true)
    end
    if Bag:GetItemCount("稀世珍宝图", nil, nil, bankItem) > 0 then
      Bank_GetItem(" 稀世珍宝图 ", nGetNum)
      Sleep(1000)
    end
    if 0 == TWM_GetMaTuCount() then
      Bank_GetItem(" 稀世珍宝图 ", nGetNum)
      Sleep(2000)
    end
    if 0 == TWM_GetMaTuCount() then
      m_param.tu_bank_take = false
    end
  elseif false == TWM_Exchange_leader() then
    if m_param.tu_sh_take then
      PushColorMsg("商会取图")
      SHQW_OnStart(m_param.sh_id_text, "稀世珍宝图|0|0")
      if 0 == TWM_GetMaTuCount() then
        SHQW_OnStart(m_param.sh_id_text, "稀世珍宝图|0|0")
        Sleep(2000)
      end
      if 0 == TWM_GetMaTuCount() then
        m_param.tu_sh_take = false
      end
    elseif GetTickCount() - m_data.buyTick > 300000 then
      if m_param.tu_buy_tianwai then
        m_param.tu_buy_tianwai = false
      elseif m_param.tu_buy_shanghui then
        PushColorMsg("商会买图")
        local buyPrice = m_param.tu_buy_j * 10000 + m_param.tu_buy_y * 100 + m_param.tu_buy_t
        Bank_GetMoney(buyPrice * 30, "洛阳")
        
        local function _cb()
          local nNum, nPrice = ShangHui_BuyItem("稀世珍宝图", 1, buyPrice)
        end
        
        TWM_BuyAction(_cb)
        Bank_SaveMoney(0)
      else
        DebugStr("天外马：买图数量已上限")
      end
    else
      DebugStr("天外马：购买间隔小于5分钟")
    end
  end
end

local function TWM_IsInMazeiScene(aSceneID)
  local curScene = aSceneID or GetSceneID()
  if g_KvKMaZeiScene[curScene] then
    return true
  end
  return false
end

local function TWM_GetCurMazeiPos()
  local tObj = EnumTianWaiMa()
  local selfPos = Player:GetPos()
  for i = 1, #tObj do
    local tmp = tObj[i]
    tmp.dst = GetDist(tmp.x, tmp.y, selfPos.x, selfPos.y)
  end
  return tObj
end

local function TWM_EnumBaoTu()
  local tBaoTu = Bag:FindBaoTu(nil, "稀世珍宝图")
  local tBaoTu_jn = Bag:FindBaoTu(Bag:EnumTempBagItem(), "稀世珍宝图")
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
    if 0 == #tBaoTu and Player:IsLeader() then
      local nCount = Team:GetMemberCount()
      if nCount > 1 then
        PushColorMsg("移交队长")
        GetLuaValue(fmt("Player:AppointLeader(%d)", nCount - 1))
        if isInLeader then
          m_data.over = true
        end
        isInLeader = true
        Sleep(2000)
      end
    end
    for i = 1, #tBaoTu do
      local tmp = tBaoTu[i]
      if 0 == tmp.pos.data or tmp.pos.sceneResID <= 583 then
        if tmp.isjn then
          local space = Bag:GetSpaceNum(0)
          if space > 0 then
            bXunHuan = true
            TempBank2BagByIndex(tmp.index)
          end
        else
          bXunHuan = true
          Bag:UseItem(tmp.index, 300)
        end
      elseif not tmp.isjn then
        local tMove = {}
        table.insert(tMove, tmp)
        Bag_Move2TempBank("稀世珍宝图", nil, tMove, false)
      end
    end
    Sleep(1000)
    DebugStr("天外马:获取珍宝图坐标")
  end
  local selfPos = Player:GetPos()
  for i = 1, #tBaoTu do
    local tmp = tBaoTu[i]
    tmp.x = tmp.pos.x
    tmp.y = tmp.pos.y
    tmp.dst = GetDist(tmp.x, tmp.y, selfPos.x, selfPos.y)
    tmp.pos.sceneID = -1
    local strSceneName = GetSceneNameByResID(tmp.pos.sceneResID)
    strSceneName = string.gsub(strSceneName, "1线", "")
    strSceneName = string.gsub(strSceneName, "2线", "")
    for k, v in pairs(g_KvKMaZeiScene) do
      if v.sceneName == strSceneName then
        tmp.pos.sceneID = k
        break
      end
    end
    tmp.sceneID = tmp.pos.sceneID
  end
  local tValid = TableDeleteTable(tBaoTu, {
    {sceneID = -1}
  }, "sceneID")
  if m_param.not_sydt then
    local tSYDT = GetTableFieldValue(tValid, "sceneID", {613})
    if 1 == m_param.sydt_handle then
      for i = 1, #tSYDT do
        local tmp = tSYDT[i]
        if tmp.isjn then
          DiscardTempBagItem(tmp.index, 300)
          PushColorMsg("天外马：锦囊删除水月洞天宝图" .. tmp.index)
        else
          DiscardBagItem(tmp.index, 300)
          PushColorMsg("天外马：背包删除水月洞天宝图" .. tmp.index)
        end
      end
    end
    tValid = TableDeleteTable(tValid, {
      {sceneID = 613}
    }, "sceneID")
  end
  return tValid
end

local function TWM_OnKill(aAttackID)
  local maxCount = 3
  local oldCount = m_data.allKillCount
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  if aAttackID > 0 then
    local debugnote = ""
    local aid = aAttackID
    CDG.pet2.GUID = 0
    CDG.pet3.GUID = 0
    while 9 ~= Player:GetState() do
      FubenAttack(aid)
      Sleep(300)
      local tObj = TWM_EnumObj()
      if 0 == #tObj then
        break
      end
      local tar
      for i = 1, #tObj do
        if tObj[i].id == aid then
          tar = tObj[i]
          break
        end
      end
      local tLv = ObjFilterByColor(tObj, "绿")
      if #tLv > 0 then
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
        debugnote = " 绿马暂不回蓝"
      else
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
        debugnote = ""
      end
      local bFindAttack = false
      for i = 1, #tLv do
        local tmp = tLv[i]
        if tmp.id == aAttackID then
          aid = aAttackID
          bFindAttack = true
        end
      end
      if not bFindAttack and #tLv > 0 then
        BubbleByDst(tLv)
        if tLv[1].dst < 20 then
          aid = tLv[1].id
          bFindAttack = true
        end
      end
      if not bFindAttack then
        BubbleByHP(tObj)
        aid = tObj[1].id
        bFindAttack = true
      end
      local selfPos = Player:GetPos()
      m_data.pos.x = selfPos.x
      m_data.pos.y = selfPos.y
      m_data.pos.sceneID = GetSceneID()
      local keepDist = 11
      if tar then
        local nDist = GetDist(selfPos.x, selfPos.y, tar.x, tar.y)
        if keepDist < nDist then
          RunTo(tar.x, tar.y, 1, 4000)
        end
      end
      PickUpLua(nil, true)
      DebugStr("天外马：击杀马贼" .. debugnote)
    end
  else
    PushColorMsg(m_script_name .. ":怪物id错误 " .. aAttackID)
  end
  local tObj = TWM_EnumObj()
  if 0 == #tObj then
    UseMount()
  end
  PickUpLua(nil, true)
  if m_data.allKillCount ~= oldCount and -1 == Player:GetBuff("乾坤壶：") then
    PickUpLua_Boss(15, 15, nil)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  return m_data.allKillCount - oldCount
end

local function twm_cb_check_posObj(aX, aY, aScene)
  if not Player:IsLeader() then
    return false
  end
  local newPos
  local bFind, tar = TWM_FindObject()
  if bFind then
    if g_self.isjingong then
      if tar.dst < 4 then
        return false
      end
    elseif tar.dst < 15 then
      return false
    end
    newPos = {}
    newPos.x = tar.x
    newPos.y = tar.y
    newPos.sceneID = aScene
    if GetDist(newPos.x, newPos.y, aX, aY) > 5 then
      AutoRunToTarget(newPos.x, newPos.y, newPos.sceneID, false)
    end
    return true, newPos
  end
  local bNext = false
  local tTmp = TWM_GetCurMazeiPos()
  for j = 1, #tTmp do
    local dist = GetDist(tTmp[j].x, tTmp[j].y, aX, aY)
    if dist < 15 then
      bNext = true
      newPos = {}
      newPos.x = tTmp[j].x
      newPos.y = tTmp[j].y
      newPos.sceneID = aScene
      if dist > 3 then
        AutoRunToTarget(newPos.x, newPos.y, newPos.sceneID, false)
      end
      break
    end
  end
  if not bNext then
    return false
  end
  TWM_CheckFollow(aX, aY, aScene)
  return true, newPos
end

local function TWM_PosRecordCheck(aPosX, aPosY)
  local diffTime = 80
  local nNowTick = GetTickCount()
  for i = #m_data.pos_just, 1, -1 do
    local tmp = m_data.pos_just[i]
    if tmp.tick - nNowTick > diffTime * 1000 then
      table.remove(m_data.pos_just, i)
    end
  end
  for i = 1, #m_data.pos_just do
    local tmp = m_data.pos_just[i]
    if GetDist(tmp.x, tmp.y, aPosX, aPosY) < 15 then
      PushColorMsg("%d秒内去过坐标【%d,%d】,不再前往", diffTime, math.floor(aPosX), math.floor(aPosY))
      return false
    end
  end
  return true
end

local function TWM_PosRecordPush(aPosX, aPosY)
  local nNowTick = GetTickCount()
  local tmp = {
    x = aPosX,
    y = aPosY,
    tick = nNowTick
  }
  table.insert(m_data.pos_just, tmp)
end

local function TWM_OnSearchScene(aSceneID, aNeedKillCount, aNextSceneID)
  local killNum = 0
  local tickOutWaitMaZei = -1
  if nil == g_KvKMaZeiScene[aSceneID] then
    PushColorMsg("天外马：错误的地图ID " .. aSceneID)
    return
  end
  PushDebugMessage("天外马：在 " .. g_KvKMaZeiScene[aSceneID].sceneName .. " 寻找马贼头领！")
  UseMaAn()
  ::lbl_23::
  if Player:IsLeader() then
    do
      local nowScene = GetSceneID()
      if nowScene ~= aSceneID and not IsDiFuScene(nowScene) and m_data.pos.x > 0 and m_data.pos.y > 0 and m_data.pos.sceneID > 0 and g_KvKMaZeiScene[m_data.pos.sceneID] then
        PushColorMsg("天外马：不在刷马地图,回记录的坐标！")
        MoveTo(m_data.pos.x, m_data.pos.y, m_data.pos.sceneID, nil, nil, MoveCallBack_state_2, twm_move_cb)
      end
      local tPos = TWM_GetCurMazeiPos()
      BubbleByDst(tPos)
      for i = 1, #tPos do
        if false ~= TWM_FindObject() then
          break
        end
        if 1 == #tPos or #tPos == i or TWM_PosRecordCheck(tPos[i].x, tPos[i].y) then
          Player:TeamFollow(true, 300)
          MoveTo(tPos[i].x, tPos[i].y, aSceneID, 5, nil, MoveCallBack_state_2, twm_cb_check_posObj)
          if GetSceneID() == aSceneID then
            TWM_PosRecordPush(tPos[i].x, tPos[i].y)
            local selfPos = Player:GetPos()
            m_data.pos.x, m_data.pos.y, m_data.pos.sceneID = selfPos.x, selfPos.y, aSceneID
          end
          tPos = TWM_GetCurMazeiPos()
          if 0 == #tPos then
            do
              local pos = Player:GetPos()
              RunTo(pos.x + 3, pos.y + 3, 0, 1000)
            end
            break
          else
            break
          end
        end
      end
      local bFindObj, tar, allMZ = TWM_FindObject()
      if bFindObj then
        tickOutWaitMaZei = -1
        if tar.dst > 7 then
          if tar.dst > 25 then
            TWM_CheckFollow(tar.x, tar.y, aSceneID)
            RunTo(tar.x, tar.y, 1, 300)
          end
          RunTo(tar.x, tar.y, 1, 300)
          
          local function _dist_cb()
            PickUpLua()
            local tmp = FindObjByTID(tar.id)
            if not tmp then
              return false
            end
            if tmp.dst <= 7 then
              return false
            end
            return true
          end
          
          PlayerStateTimeOut(2, 20, _dist_cb)
        end
        local nRet = TWM_OnKill(tar.id)
        if nRet > 0 then
          killNum = killNum + nRet
        end
      elseif 1 == #tPos then
        local tObj = Enum2XByName("夺宝马贼头领", {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        local tHong = ObjFilterByColor(tObj, "红绿")
        if #tObj > 0 and 0 == #tHong then
          DebugColorMsg("地图最后一只白马", 4)
          tPos = {}
        end
      end
      if aNeedKillCount > 0 then
        if aNeedKillCount <= killNum then
          goto lbl_429
        end
        if 0 == #tPos and false == bFindObj then
          if -1 == tickOutWaitMaZei then
            if m_param.wait_mz_sec > 0 then
              tickOutWaitMaZei = GetTickCount()
              PushDebugMessage("天外马：若%d秒没有发现马贼,将忽略少掉的马！", m_param.wait_mz_sec)
            end
          elseif GetTickCount() - tickOutWaitMaZei > m_param.wait_mz_sec * 1000 then
            PushColorMsg("%s：有%d只马可能被其他人杀掉,等待超时！", g_KvKMaZeiScene[aSceneID].sceneName, aNeedKillCount - killNum)
            goto lbl_429
          end
          if 0 == Player:GetState() and not Player:IsFollow() then
            if IsMount() then
              Player:TeamFollow(true, 300)
            else
              for i = 1, 3 do
                FubenAttack(-1)
              end
              UseMount()
            end
          elseif not IsMount() then
            Player:TeamFollow(false, 300)
            FubenAttack(-1)
            FubenAttack(-1)
            UseMount()
            Player:TeamFollow(true, 300)
          end
        else
          tickOutWaitMaZei = -1
        end
        if m_param.wait_mz_sec > 0 then
          if -1 == tickOutWaitMaZei then
            DebugStr("天外马：需杀%d只马,剩余%d只,地图无马时开始等待并计算超时！", 2, aNeedKillCount, aNeedKillCount - killNum)
          else
            local nDiff = m_param.wait_mz_sec * 1000 - (GetTickCount() - tickOutWaitMaZei)
            nDiff = math.floor(nDiff / 1000)
            DebugStr("天外马：需杀%d只马,剩余%d只,等待刷新中,剩余%d秒！", 2, aNeedKillCount, aNeedKillCount - killNum, nDiff)
          end
        else
          DebugStr("天外马：需杀%d只马,剩余%d只,您未设置缺马超时,将刷完指定数量！", 2, aNeedKillCount, aNeedKillCount - killNum)
        end
      else
        if not bFindObj and 0 == #tPos and aNextSceneID and aSceneID ~= aNextSceneID then
          local function _cb()
            local nScene = GetSceneID()
            
            if nScene == aNextSceneID then
              return false
            end
            if nScene == aSceneID then
              local tPos = TWM_GetCurMazeiPos()
              if #tPos > 0 then
                PushColorMsg("模式2：当前地图又刷新了马贼")
                return false
              end
            end
            if not Player:IsLeader() then
              return false
            end
            return true
          end
          
          PushColorMsg("模式2：前往下个地图 " .. GetSceneNameByID(aNextSceneID))
          MoveTo(200, 200, aNextSceneID, nil, nil, MoveCallBack_state_2, _cb)
          if GetSceneID() == aNextSceneID then
            goto lbl_429
          end
        end
        DebugStr("天外马：模式2刷马中 ")
      end
      Sleep(300)
      PickUpLua(nil, true)
      TWM_OnDie()
      TWM_CheckCunCang()
      if -1 ~= m_param.over_time and os.time() > m_param.over_time then
        PushColorMsg("天外马:已到达设置的结束时间！")
        m_data.over = true
      else
        goto lbl_23
      end
    end
    ::lbl_429::
  end
end

local function TWM_UseBaoTu()
  Player:TeamFollow(false, 300)
  local nNowScene = GetSceneID()
  local tBaoTu = TWM_GetBaoTuInfo()
  local tCurSceneMT = GetTableFieldValue(tBaoTu, "sceneID", {nNowScene})
  local tuse
  if #tCurSceneMT > 0 then
    BubbleByDst(tCurSceneMT)
    tuse = tCurSceneMT[1]
  elseif #tBaoTu > 0 then
    tuse = tBaoTu[1]
  end
  if tuse then
    local strSceneName = GetSceneNameByID(tuse.sceneID)
    PushDebugMessage("天外马：前往%s %d,%d放出马贼", strSceneName, math.floor(tuse.x), math.floor(tuse.y))
    local nStartTick = GetTickCount()
    
    local function use_move_cb(fX, fY, nScene)
      if false == twm_move_cb(fX, fY, nScene) then
        return false
      end
      if GetTickCount() - nStartTick > 600000 then
        PushColorMsg(m_script_name .. ":马图坐标可能有问题,退出寻路")
        return false
      end
      local tObj = TWM_EnumObj()
      if #tObj > 0 then
        BubbleByHP(tObj, 2)
        if tObj[1].hp >= 100 then
          PushColorMsg("放马时发现马贼头领")
          RunTo(tObj[1].x, tObj[1].y, 1, 1000)
          PlayerStateTimeOut(2, 7)
          TWM_OnKill(tObj[1].id)
        else
          local tHong = ObjFilterByColor(tObj, "红")
          if #tHong > 0 then
            PushColorMsg("放马时发现马贼头领！")
            RunTo(tHong[1].x, tHong[1].y, 1, 1000)
            PlayerStateTimeOut(2, 7)
            TWM_OnKill(tHong[1].id)
          end
        end
      end
      return true
    end
    
    if IsMount() then
      Player:TeamFollow(true, 300)
    end
    MoveTo(tuse.x, tuse.y, tuse.sceneID, 5, nil, MoveCallBack_state_2, use_move_cb)
    PlayerStateTimeOut(2, 2)
    RunTo(tuse.x, tuse.y, 1, 300)
    local tOld = GetTableFieldValue(Bag:EnumTempBagItem(), "id", {
      tuse.id
    })
    if #tOld > 0 then
      PushDebugMessage("从锦囊移出宝图" .. tOld[1].index)
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
      PushColorMsg("从锦囊移出宝图失败")
      return -2
    end
    _, _, m_data.oldmz = TWM_FindObject()
    tOld = GetTableFieldValue(Bag:EnumDaoJuItem(), "id", {
      tuse.id
    })
    if #tOld > 0 then
      for i = 1, 3 do
        Player:TeamFollow(false, 500)
        Dismount(500)
        Bag:UseItem(tOld[1].index, 800)
        tOld = GetTableFieldValue(Bag:EnumDaoJuItem(), "id", {
          tuse.id
        })
        if 0 == #tOld then
          break
        end
      end
    end
    if 0 == #tOld then
      m_data.oldmz_tick = GetTickCount()
      PushColorMsg(g_KvKMaZeiScene[tuse.sceneID].sceneName .. ":成功使用1张宝图")
      m_data.pos.x, m_data.pos.y, m_data.pos.sceneID = tuse.x, tuse.y, tuse.sceneID
      return 1, tuse.sceneID
    end
    PushDebugMessage(g_KvKMaZeiScene[tuse.sceneID].sceneName .. ":使用马图失败！")
    return -2
  end
  return -1
end

local function TWM_OnLeader()
  local mode2Search = {}
  local sceneArr = SplitString(m_param.mode2_scene, " ", true)
  for i = 1, #sceneArr do
    local id = GetSceneIDByName(sceneArr[i])
    if TWM_IsInMazeiScene(id) then
      table.insert(mode2Search, id)
    end
  end
  local startScene = GetSceneID()
  if not TWM_IsInMazeiScene(startScene) then
    startScene = -1
  end
  while Player:IsLeader() and 1 == m_param.mode do
    local tObj = TWM_EnumObj()
    local tTar = ObjFilterByColor(tObj, "红")
    if 0 == #tTar then
      tTar = ObjFilterByColor(tObj, "绿")
    end
    if #tTar > 0 then
      BubbleByDst(tTar)
      TWM_OnKill(tTar[1].id)
    else
      break
    end
    Sleep(500)
    DebugStr("天外马:有打红的马贼")
  end
  while Player:IsLeader() do
    if 1 == m_param.mode then
      local nRet, nScene = TWM_UseBaoTu()
      if 1 == nRet then
        TWM_OnSearchScene(nScene, m_param.kill_count)
      elseif -1 == nRet then
        if 0 == TWM_GetMaTuCount() then
          if m_param.over_noitem then
            PushDebugMessage("天外马：背包已没有马图")
            m_data.over = true
            break
          end
          TWM_TakeBaoTu()
        else
          DebugColorMsg("马图")
        end
      end
    elseif 2 == m_param.mode then
      if #mode2Search > 0 then
        for i = 1, #mode2Search do
          if -1 == startScene or -1 ~= startScene and mode2Search[i] == startScene then
            local nextScene = mode2Search[i + 1]
            nextScene = nextScene or mode2Search[1]
            PushDebugMessage("天外马：模式2循环搜索马贼 地图" .. GetSceneNameByID(mode2Search[i]))
            TWM_OnSearchScene(mode2Search[i], -1, nextScene)
          end
        end
        startScene = -1
      else
        local curScene = GetSceneID()
        if TWM_IsInMazeiScene(curScene) then
          table.insert(mode2Search, curScene)
        else
          DebugStr("天外马：模式2您需要移动到一个马贼地图")
          Sleep(3000)
        end
      end
    end
    if -1 ~= m_param.over_time and os.time() > m_param.over_time then
      PushColorMsg("天外马:已达到结束时间！")
      m_data.over = true
      break
    end
    if m_data.over then
      break
    end
    Sleep(500)
    PickUpLua(nil, true)
    DebugStr("天外马:队长")
    TWM_OnDie()
    TWM_CheckCunCang()
  end
end

local function twdy_callback(fX, fY, nScene)
  local leader, isleader = Team:GetLeaderInfo()
  if leader and g_KvKMaZeiScene[leader.sceneID] == nil and leader.sceneID ~= 850 then
    DebugStr("天外马:跟随队长不在天外地图,暂不跟随！", 2)
    return false
  end
  return MoveCallBack_GoToLeader(fX, fY, nScene)
end

local function TWM_JY_player_Action()
  local leader, isleader = Team:GetLeaderInfo()
  if leader and not isleader then
  else
    CloseAllWindow()
    return
  end
  local nStartTick = GetTickCount()
  while IsWindowVisible("Exchange") do
    if GetTickCount() - nStartTick > 45000 then
      PushColorMsg(m_script_name .. "：交易超时")
      CloseWindow("Exchange")
      break
    end
    if Exchange_IsLocked("other") and Exchange_IsLocked("self") then
      local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
      if otherName == leader.name then
        GetLuaValue("Exchange:AcceptExchange()")
        Sleep(1000)
        local nTick1 = GetTickCount()
        while IsWindowVisible("Exchange") and Exchange_IsLocked("other") and Exchange_IsLocked("self") do
          Sleep(500)
          if GetTickCount() - nTick1 > 8000 then
            PushDebugMessage("对方超过8秒没有确定交易！")
            CloseWindow("Exchange")
            break
          end
        end
      end
    elseif Exchange_IsLocked("other") then
      Sleep(1000)
      Exchange_LockExchange()
      Sleep(1500)
    elseif Exchange_IsLocked("self") then
      Sleep(2000)
    else
      local tExc = Bag:FindItemInfo("稀世珍宝图", 0, 1)
      tExc = Exchange_DeleteLockItem(tExc)
      if 0 == #tExc and 0 == GetLuaValue("return GetActionNum('ex_self');", "n") then
        CloseWindow("Exchange")
        break
      elseif #tExc > 0 and GetLuaValue("return GetActionNum('ex_self');", "n") < 5 then
        local tmp = tExc[1]
        Bag:ItemBtnClicked(tmp.index)
      end
      if Exchange_GetMoney("self") > 0 then
        CloseWindow("Exchange")
      elseif 5 == GetLuaValue("return GetActionNum('ex_self');", "n") then
        Exchange_LockExchange()
      elseif 0 == #tExc and GetLuaValue("return GetActionNum('ex_self');", "n") > 0 then
        Exchange_LockExchange()
      end
    end
    Sleep(600)
    DebugStr("交易：正在交易物品")
  end
end

local function TWM_Exchange_player()
  if not m_param.jiaoyi then
    return
  end
  if 0 == TWM_GetMaTuCount() then
    local bankItem = Bank_EnumItem()
    if 0 == #bankItem then
      bankItem = Bank_EnumItem(true)
    end
    if Bag:GetItemCount("稀世珍宝图", nil, nil, bankItem) > 0 then
      Bank_GetItem(" 稀世珍宝图 ", 10)
    end
  end
  if TWM_GetMaTuCount() > 0 then
    GoToLeader(twdy_callback, MoveCallBack_state_2)
    local leader, isleader = Team:GetLeaderInfo()
    if leader and not isleader then
      local tObj = Enum2XByName(leader.name, {
        0,
        0,
        1,
        0
      }, {0, -1}, 0, 3)
      if #tObj > 0 and GetDist(tObj[1].x, tObj[1].y, m_data.jy_x, m_data.jy_y) < 5 then
        TempBank2Bag("稀世珍宝图", 1)
      end
      local lastTickSend = -1
      local maxTick = GetTickCount()
      while not Player:IsLeader() and 0 ~= Bag:GetItemCount("稀世珍宝图") do
        local tObj = Enum2XByName(leader.name, {
          0,
          0,
          1,
          0
        }, {0, -1}, 0, 3)
        if #tObj > 0 and GetDist(tObj[1].x, tObj[1].y, m_data.jy_x, m_data.jy_y) < 5 then
          if IsWindowVisible("Exchange") then
            local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
            if otherName == leader.name then
              TWM_JY_player_Action()
            else
              CloseWindow("Exchange")
              break
            end
          else
            GoToScene(tObj[1].x, tObj[1].y, GetSceneID())
            Sleep(500)
            if GetTickCount() - lastTickSend > 20000 then
              lastTickSend = GetTickCount()
              SP_SendJiaoYiAsk(tObj[1].id)
            else
              DebugStr("等待发送交易,%d秒", 2, 20)
            end
          end
        else
          break
        end
        if GetTickCount() - maxTick > 60000 then
          CloseAllWindow()
          PushColorMsg("交易超时")
          break
        end
        Sleep(500)
        DebugStr("队员交易马图")
      end
      Bag_Move2TempBank("稀世珍宝图", nil, nil, false)
    end
  elseif m_param.tu_sh_take then
    PushColorMsg("队员：商会取图")
    if GetTickCount() - m_data.noitemTick > 300000 then
      SHQW_OnStart(m_param.sh_id_text, "稀世珍宝图|0|0")
      if 0 == TWM_GetMaTuCount() then
        SHQW_OnStart(m_param.sh_id_text, "稀世珍宝图|0|0")
        Sleep(2000)
      end
      if 0 == TWM_GetMaTuCount() then
        m_param.tu_sh_take = false
      end
      m_data.noitemTick = GetTickCount()
    else
      DebugStr("天外马：商会取图间隔小于5分钟", 3)
    end
  elseif m_param.tu_buy_shanghui then
    if GetTickCount() - m_data.buyTick > 300000 then
      PushColorMsg("队员：商会买图")
      local buyPrice = m_param.tu_buy_j * 10000 + m_param.tu_buy_y * 100 + m_param.tu_buy_t
      Bank_GetMoney(buyPrice * 30, "洛阳")
      
      local function _cb()
        local nNum, nPrice = ShangHui_BuyItem("稀世珍宝图", 1, buyPrice)
      end
      
      TWM_BuyAction(_cb)
      Bank_SaveMoney(0)
    else
      DebugStr("队长：买图间隔小于5分钟", 3)
    end
  end
end

local function TWM_CheckLeaderState(aTickOver)
  if GetSceneID() == 850 then
    local leader, isleader = Team:GetLeaderInfo()
    if leader and not isleader and 850 == leader.sceneID then
      local xPos = leader.x
      local yPos = leader.y
      local leaderObj = FindObjByGUID(leader.guid)
      if leaderObj then
        xPos = leaderObj.x
        yPos = leaderObj.y
      end
      if GetDist(xPos, yPos, m_data.over_x, m_data.over_y) < 2 then
        if -1 == aTickOver then
          aTickOver = GetTickCount()
        elseif GetTickCount() - aTickOver > 3000 then
          local allName = GetLocalPlayerName()
          if string.find(allName, " " .. leader.name .. " ", nil, true) then
            local msg = "天外马:队长已停止！"
            PushColorMsg(msg)
            Log(msg)
            m_data.over = true
          end
        end
      elseif m_param.jiaoyi and GetDist(xPos, yPos, m_data.jy_x, m_data.jy_y) < 2 then
        if -1 == aTickOver then
          aTickOver = GetTickCount()
        elseif GetTickCount() - aTickOver > 2000 then
          local msg = "天外马:队长正等待交易马图"
          DebugStr(msg, 2)
          TWM_Exchange_player()
        end
      else
        aTickOver = -1
      end
    else
      aTickOver = -1
    end
  end
  return aTickOver
end

local function member_obj_cb(fX, fY, nScene)
  local bMove, newPos = twdy_callback(fX, fY, nScene)
  if bMove then
    local leader, isleader = Team:GetLeaderInfo()
    if leader then
      local leaderObj = FindObjByGUID(leader.guid)
      if leaderObj and leaderObj.dst <= 10 then
        local tObj = TWM_EnumObj()
        if #tObj > 0 then
          PushColorMsg("跟随队长时,附近有马贼")
          return false, nil
        end
      end
    end
    return true, newPos
  end
  return false, nil
end

local function TWM_OnPlayer()
  local tickOver = -1
  local leaderDist = 3
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local debugnote = ""
  while not Player:IsLeader() do
    local bHaveHong = false
    if Player:IsFollow() then
      DebugStr("天外马：队员组队跟随中")
    else
      GoToLeader(member_obj_cb, MoveCallBack_state_2, false, false, leaderDist)
      local tObj = TWM_EnumObj()
      local tLv = ObjFilterByColor(tObj, "绿")
      local tHong = ObjFilterByColor(tObj, "红")
      if #tLv > 0 then
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
        debugnote = " 绿马暂不回蓝"
      else
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
        debugnote = ""
      end
      if #tHong > 0 then
        bHaveHong = true
      end
      if #tObj > 0 then
        leaderDist = 10
        local tar
        local leader, isleader = Team:GetLeaderInfo()
        if leader then
          local leaderObj = FindObjByGUID(leader.guid)
          if leaderObj then
            local tInfo = GetTableFieldValue(tObj, "id", {
              leaderObj.target
            })
            if #tInfo > 0 then
              tar = tInfo[1]
            end
          end
        end
        if not tar then
          BubbleByDst(tObj, 1)
          tar = tObj[1]
        end
        FubenAttack(tar.id)
        local keepDist = 11
        if tar and keepDist < tar.dst then
          RunTo(tar.x, tar.y, 1, 3000)
        end
      else
        leaderDist = 3
      end
      DebugStr("天外马：队员跟随队长" .. debugnote)
    end
    if false == bHaveHong and -1 ~= m_param.over_time and os.time() > m_param.over_time then
      PushColorMsg("天外马:已到达设置的结束时间！")
      m_data.over = true
      break
    end
    tickOver = TWM_CheckLeaderState(tickOver)
    if m_data.over then
      break
    end
    Sleep(200)
    PickUpLua(nil, true)
    TWM_OnDie()
    TWM_CheckCunCang()
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

function _SMain(...)
  LoadScript("jiaoyi")
  LoadScript("shanghui")
  LeaveSpecialScene(nil, nil)
  if not IsKVKSceneName() then
    MoveTo(155, 118, 850)
  elseif Player:IsLeader() and GetDist(m_data.over_x, m_data.over_y) < 3 then
    RunTo(328, 357)
  end
  while true do
    if Player:IsLeader() then
      TWM_OnLeader()
    else
      TWM_OnPlayer()
    end
    if m_data.over then
      break
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  local tickOut = -1
  while Player:IsLeader() do
    GoToScene(m_data.over_x, m_data.over_y, 850)
    Player:TeamFollow(false, 300)
    if -1 == tickOut then
      tickOut = GetTickCount()
    end
    if GetTickCount() - tickOut > 90000 then
      break
    end
    Sleep(500)
    DebugStr("天外马：90秒内结束运行")
  end
  Player:TeamFollow(false, 300)
  if g_config.twmz.auto_team then
    Team:LeaveTeam()
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_data = nil
g_KvKMaZeiScene = nil
m_param = nil
