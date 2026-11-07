-- 反编译自 dfz64.dll 内嵌字节码 002c0fc9（unluac 2025-12-23；仅供分析）
local m_script_name = "兵圣奇阵"
ScriptOnStart(m_script_name, true, true)
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk43"), 12)
CDG.hp.em_pet = false
CDG.hp.em_raid = true
g_pick.check = true
g_pick.pickmode = 0
local m_param = {}
m_param.mp_check_ever = true
m_param.boss1_boss2_teamhp_protect = false
m_param.boss1_boss2_teamhp_cmp = 50
m_param.isattack = CDG.attack
m_param.swcq = false
m_param.knMode = ReadConfigBool("ZH", "xzk110")
m_param.adjustMember = ReadConfigBool("ZH", "xzk170")
m_param.autoFuben = ReadConfigBool("ZH", "xzk260")
m_param.boss2_which = 3
if ReadConfigBool("ZH", "dxk34") then
  m_param.boss2_which = 1
elseif ReadConfigBool("ZH", "dxk35") then
  m_param.boss2_which = 2
end
m_param.boss2_bxn1_hdw2 = ReadConfigBool("ZH", "xzk230")
m_param.boss2_bing = ReadConfigBool("ZH", "xzk199")
m_param.boss2_huo = ReadConfigBool("ZH", "xzk200")
m_param.boss2_xuan = ReadConfigBool("ZH", "xzk201")
m_param.boss2_du = ReadConfigBool("ZH", "xzk202")
m_param.boss2_nei = ReadConfigBool("ZH", "xzk203")
m_param.boss2_wai = ReadConfigBool("ZH", "xzk204")
m_param.boss2_safe_wait = ReadConfigBool("ZH", "xzk232")
m_param.boss3_safe_wait = ReadConfigBool("ZH", "xzk234")
local m_data = {}
m_data.sceneName = "兵圣奇阵"
m_data.sceneID = 294
m_data.boss = {
  {
    step = 1,
    x = 51,
    y = 57,
    name = "萧逸风"
  },
  {
    step = 2,
    x = 0,
    y = 0,
    name = "萧如筠 萧如蔚"
  },
  {
    step = 3,
    x = 193,
    y = 193,
    name = "耶律焱",
    xSafe = 158,
    ySafe = 179
  },
  {
    step = 4,
    x = 53,
    y = 203,
    name = "耶律连城"
  }
}
m_data.shuiji_unsafe = {}
local m_finish = {
  boss1 = false,
  boss2 = false,
  boss3 = false,
  boss4 = false
}
local m_wait = {tick = -1, max = 90000}

function GetLinePos(aPosA, aPosB, aStep)
  local allPos = {}
  local nDist = GetDist(aPosA.x, aPosA.y, aPosB.x, aPosB.y)
  if nDist > 4 then
    local nAngle = GetAngle(aPosA.x, aPosA.y, aPosB.x, aPosB.y)
    local i = aStep
    while nDist > i do
      local tPos = GetAnglePos(aPosA, nAngle, i)
      table.insert(allPos, tPos)
      i = i + aStep
    end
  end
  return allPos
end

local function BSQZ_SetFinishState(boss1, boss2, boss3, boss4)
  if nil ~= boss1 then
    m_finish.boss1 = boss1
  end
  if nil ~= boss2 then
    m_finish.boss2 = boss2
  end
  if nil ~= boss3 then
    m_finish.boss3 = boss3
  end
  if nil ~= boss4 then
    m_finish.boss4 = boss4
  end
end

local function BSQZ_RefreshStep()
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("#{BSQZ_101223_163}")
  local nMsgTime2 = IsInDebugMsg("#{BSQZ_101223_167}")
  local nMsgTime3 = IsInDebugMsg("#{BSQZ_101223_171}")
  local nMsgTime4 = IsInDebugMsg("#{BSQZ_101223_176}")
  if nMsgTime1 and nTransTime < nMsgTime1 then
    BSQZ_SetFinishState(true, nil, nil, nil)
  end
  if nMsgTime2 and nTransTime < nMsgTime2 then
    BSQZ_SetFinishState(true, true, nil, nil)
  end
  if nMsgTime3 and nTransTime < nMsgTime3 then
    BSQZ_SetFinishState(true, true, true, nil)
  end
  if nMsgTime4 and nTransTime < nMsgTime4 then
    BSQZ_SetFinishState(true, true, true, true)
  end
end

local function BSQZ_IsStepOver(nStep)
  BSQZ_RefreshStep()
  if 1 == nStep then
    return m_finish.boss1
  elseif 2 == nStep then
    return m_finish.boss2
  elseif 3 == nStep then
    return m_finish.boss3
  elseif 4 == nStep then
    return m_finish.boss4
  end
  return false
end

local function BSQZ_boss_finish(bFinish, boss, posPick)
  m_wait.tick = -1
  local pos = posPick or {
    {
      x = boss.x,
      y = boss.y
    }
  }
  if bFinish then
    PushDebugMessage(m_data.sceneName .. ":" .. boss.name .. " 已完成！")
    PickUpLua(nil, true, true)
    RelivePlayer(1, nil, nil, nil, nil, false)
    PickUpLua(nil, true, true)
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua_Boss(60, 15, nil, pos, true, nil)
    RelivePlayer(1, nil, nil, nil, nil, true)
  end
  PickUpMust()
end

local function BSQZ_callback_run(fX, fY, nScene)
  DebugStr(m_data.sceneName .. ":正在移动到 %d,%d ", 2, math.floor(fX), math.floor(fY))
  PickUpLua(nil, true, true)
  if FubenCheckSceneDie(m_data.sceneID) == false then
    return false
  end
  return true
end

local function BSQZ_GetPosStep(pos)
  pos = pos or Player:GetPos()
  if pos.x < 79 and pos.y < 93 then
    return 1, -1
  end
  if pos.x >= 138 and pos.y < 70 then
    return 2, 1
  end
  if pos.x >= 133 and pos.y > 75 and pos.y < 115 then
    return 2, 2
  end
  if pos.x > 153 and pos.y > 132 then
    return 3, -1
  end
  if pos.x < 99 and pos.y > 170 then
    return 4, -1
  end
  return -1, -1
end

local function BSQZ_IsInStepPos(aStep, pos)
  local bIs = false
  if BSQZ_GetPosStep(pos) == aStep then
    bIs = true
  end
  return bIs
end

local function BSQZ_IsAllInStepPos(aStep)
  local tAll = Raid:GetUpdateMemberInfo()
  local bAllIn = true
  for i = 1, #tAll do
    local tmp = tAll[i]
    if false == BSQZ_IsInStepPos(aStep, tmp) then
      bAllIn = false
      DebugStr(tmp.name .. " 不在战斗区域,坐标" .. tmp.x .. "，" .. tmp.y .. " " .. aStep, 2)
      break
    end
  end
  return bAllIn
end

local function BSQZ_IsBossStart(aBoss)
  local strName = aBoss.name
  if "耶律连城" == strName then
    strName = strName .. " 石堆"
  end
  local tObj = Enum2XByName(strName, {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    if 100 == tObj[1].hp and 7 == tObj[1].state then
      PushDebugMessage("Boss已进入攻击状态")
      return true
    elseif tObj[1].hp < 100 then
      PushDebugMessage("Boss已进入战斗状态")
      return true
    end
  end
  return false
end

local function BSQZ_callback_hp()
  local boss = {
    name = "萧逸风 萧如筠 萧如蔚 耶律焱 耶律连城"
  }
  local isStart = BSQZ_IsBossStart(boss)
  return not isStart
end

local function BSQZ_qlxg(aBoss, aMonsterName)
  local bHave = false
  local nTick = GetTickCount()
  while FubenCheckSceneDie(m_data.sceneID) do
    local tObj = Enum2XByName(aMonsterName, {
      0,
      1,
      0,
      0
    }, {0, -1}, 1, 0)
    if 0 == #tObj then
      break
    end
    DebugStr(m_data.sceneName .. " :清理小怪" .. aBoss.name .. " " .. aMonsterName, 2)
    bHave = true
    if 1 == aBoss.step and BSQZ_IsInStepPos(aBoss.step) == false then
      PushColorMsg("清理小怪时,不在Boss1战斗区域")
      break
    end
    FubenAttack(tObj[1].id)
    Sleep(150)
    if 2 == aBoss.step and tObj[1].dst > 14 then
      RunTo(tObj[1].x, tObj[1].y, 3, 2000)
    end
    if GetTickCount() - nTick > 120000 then
      break
    end
  end
  return bHave
end

local function BSQZ_em_xsx(aNpc)
  local nSec = 10
  local nTick = GetTickCount()
  while GetTickCount() - nTick < nSec * 1000 do
    DebugStr("等待峨嵋打血上限,剩余%d秒", 1, math.floor(nSec - (GetTickCount() - nTick) / 1000))
    FubenAttack(-1)
    Sleep(150)
    if BSQZ_IsBossStart(aNpc) or BSQZ_IsInStepPos(aNpc.step) == false then
      break
    end
  end
end

local function BSQZ_IsWaitRaidTickOut(aBoss)
  local isTickOut = false
  if -1 == m_wait.tick then
    m_wait.tick = GetTickCount()
  end
  if GetTickCount() - m_wait.tick > m_wait.max then
    isTickOut = true
  else
    DebugStr(aBoss.name .. ":有团员没进入战斗区域,%d秒后超时", 4, math.floor((m_wait.max - (GetTickCount() - m_wait.tick)) / 1000))
  end
  return isTickOut
end

local function BSQZ_start_pos(aBoss)
  local bOK = true
  local r = 7
  local nPosCount = 12
  local rIndex = Raid_GetIndex()
  local zero = aBoss
  if 1 == aBoss.step then
    zero.y = aBoss.y + 7
  elseif 4 == aBoss.step then
    r = 5
  end
  while nPosCount < rIndex + 1 do
    rIndex = rIndex - nPosCount
  end
  local tpos = GetAveragePoint(zero.x, zero.y, r, nPosCount, 0)
  local run = tpos[rIndex + 1]
  if not run then
    return bOK
  end
  bOK = not RunTo(run.x, run.y, 1, 1000)
  return bOK
end

local function BSQZ_boss1_pos(aFast)
  local bOK = true
  local tPos = {
    {x = 73, y = 63},
    {x = 73, y = 59},
    {x = 73, y = 55},
    {x = 73, y = 51},
    {x = 77, y = 48},
    {x = 77, y = 52},
    {x = 77, y = 56},
    {x = 77, y = 59},
    {x = 73, y = 63},
    {x = 73, y = 51},
    {x = 73, y = 59},
    {x = 77, y = 48}
  }
  local tYG = {}
  local tJG = {}
  local tRaid = Raid:GetAllMemberInfo()
  for i = 1, #tRaid do
    if IsMenpaiJinGong(tRaid[i].menpai) == false then
      table.insert(tYG, tRaid[i])
    else
      table.insert(tJG, tRaid[i])
    end
  end
  for i = 1, #tJG do
    table.insert(tYG, tJG[i])
  end
  local posIndex = 3
  for i = 1, #tYG do
    if tYG[i].name == g_self.name then
      posIndex = i
      break
    end
  end
  local run = tPos[posIndex]
  if not run then
    return bOK
  end
  if aFast then
    bOK = FastRun(run, 5)
  else
    bOK = not RunTo(run.x, run.y, 0, 1000)
  end
  return bOK
end

local function BSQZ_boss1_EnumObj()
  local tAll = Enum2XByClass("怪物", nil, 3)
  local tBoss = ObjFilterByName(tAll, "萧逸风", 0)
  tBoss = tBoss[1]
  local tXF = ObjFilterByName(tAll, "旋风", 0)
  tXF = ObjFilterByHP(tXF, 0, 1)
  local tXunF = ObjFilterByName(tAll, "巽风", 0)
  local tZL = ObjFilterByName(tAll, "震雷", 0)
  local tFLD = ObjFilterByName(tAll, "风雷弹", 0)
  tFLD = ObjFilterByHP(tFLD, 0, 1)
  return tBoss, tXF, tXunF, tZL, tFLD
end

local function BSQZ_boss1_EnumJF(aSafePlayer)
  local tJF = {}
  local tWanJia = Enum2XByClass("玩家", {0, -1})
  for i = 1, #tWanJia do
    if Target:FindBuff(tWanJia[i], "聚风：") then
      if not aSafePlayer then
        table.insert(tJF, tWanJia[i])
      end
    elseif aSafePlayer then
      table.insert(tJF, tWanJia[i])
    end
  end
  return tJF
end

local function BSQZ_boss1_jufeng()
  local bHave = false
  local bSafe = true
  local npc = m_data.boss[1]
  local tPos = {
    {x = 72, y = 67},
    {x = 75, y = 43},
    {x = 71, y = 46}
  }
  if -1 ~= Player:GetBuff("聚风：") then
    bHave = true
    local tJF = BSQZ_boss1_EnumJF(true)
    local rSpec = 4
    local myPos = Player:GetPos()
    if not IsPosSafe(myPos, tJF, rSpec) then
      bSafe = false
      local tSafePos = {}
      for i = 1, #tPos do
        if IsPosSafe(tPos[i], tJF, rSpec) then
          table.insert(tSafePos, tPos[i])
        end
      end
      GetAllPosDist(tSafePos, myPos, "dist")
      BubbleByDist(tSafePos)
      if #tSafePos > 0 then
        local run = tSafePos[1]
        FastRun(run, 5)
      else
        FubenTrapRun("", npc.x, npc.y, rSpec, 20, tJF, nil, FubenRunSafe, nil, nil, nil)
      end
    end
  end
  return bHave, bSafe
end

local function BSQZ_boss1_xf_zl(atXunF, atZL, atRun)
  local bHave = false
  local bSafe = true
  local tSpec = {}
  local npc = m_data.boss[1]
  if 0 == #atXunF and 0 == #atZL then
    return bHave, bSafe
  end
  bHave = true
  bSafe = BSQZ_boss1_pos(true)
  return bHave, bSafe
end

local function BSQZ_boss1_fengleidan(atFLD, aCheckDist)
  local tAttack = {}
  local tFLD = atFLD
  if aCheckDist then
    tFLD = ObjFilterByDst(tFLD, aCheckDist, 2)
  end
  local tPlayer = Enum2XByClass("玩家", {0, -1})
  for j = 6, 2, -1 do
    for i = 1, #tFLD do
      if IsPosSafe(tFLD[i], tPlayer, j) then
        table.insert(tAttack, tFLD[i])
      end
    end
    if #tAttack > 0 then
      break
    end
  end
  if 0 == #tAttack then
    tAttack = tFLD
  end
  return tAttack
end

local function BSQZ_boss1_get_xf_fld(atXF, atFLD, aCheckDist)
  local tar
  local bIsXuanF = false
  local nDist15 = 15
  local tXF15 = ObjFilterByDst(atXF, nDist15, 2)
  if #tXF15 > 0 then
    bIsXuanF = true
    BubbleByHP(tXF15)
    tar = tXF15[1]
  elseif #atXF > 0 and not aCheckDist then
    bIsXuanF = true
    BubbleByDst(atXF)
    tar = atXF[1]
  end
  if not tar then
    local tFLD15 = BSQZ_boss1_fengleidan(atFLD, aCheckDist)
    if #tFLD15 > 0 then
      BubbleByHP(tFLD15)
      tar = tFLD15[1]
    elseif #atFLD > 0 and not aCheckDist then
      BubbleByDst(atFLD)
      tar = atFLD[1]
    end
  end
  return tar, bIsXuanF
end

local function BSQZ_boss1_action_callback()
  local bFindSpecJF, bSafeSpecJF = BSQZ_boss1_jufeng()
  if bFindSpecJF then
    return false
  end
  local tBoss, tXF, tXunF, tZL, tFLD = BSQZ_boss1_EnumObj()
  if #tXunF or #tZL > 0 then
    local bFindSpec1, bSafeSpec1 = BSQZ_boss1_xf_zl(tXunF, tZL)
    if not bSafeSpec1 then
      return false
    end
  elseif #tXF > 0 then
    return false
  end
  return true
end

local function BSQZ_Boss1_XYF(aClassName, aType)
  local npc = m_data.boss[1]
  DebugStr(m_data.sceneName .. "：" .. npc.name .. aClassName .. aType)
  if GetDist(npc.x, npc.y) > 28 then
    UseMount()
    MoveTo(58, 80, -1, 1, nil, nil, BSQZ_callback_run)
    RunTo(58, 80, 0, 500)
    return
  end
  if BSQZ_qlxg(npc, "风阵守卫") then
    return
  end
  if false == BSQZ_IsBossStart(npc) then
    RunTo(58, 80, 3, 500)
    if false == BSQZ_IsAllInStepPos(npc.step) and false == BSQZ_IsWaitRaidTickOut(npc) then
      FubenAttack(-1)
      return
    end
  end
  local tLast = {
    x = npc.x,
    y = npc.y
  }
  CheckAllRaidHP(85, BSQZ_callback_hp, 45)
  local bFirstRun = false
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.skill_attack_jinji_disable = " 横扫乾坤 暗器连击 三阳开泰 连珠腐尸毒 移花接木 万箭齐发 鹰击长空 定海神针 "
  CDG.call.back1 = BSQZ_boss1_action_callback
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    if false == BSQZ_IsInStepPos(npc.step) then
      PushColorMsg("当前坐标不是boss1区域！")
      break
    end
    if -1 == Player:GetBuff("飓风术：") then
      local tBoss, tXF, tXunF, tZL, tFLD = BSQZ_boss1_EnumObj()
      if tBoss then
        tLast.x = tBoss.x
        tLast.y = tBoss.y
        if 0 == tBoss.hp then
          m_finish.boss1 = true
          break
        end
      end
      local bFindSpecJF, bSafeSpecJF = BSQZ_boss1_jufeng()
      local bFindSpec1, bSafeSpec1 = false, true
      local bFindSpecXF = false
      local tar
      if bSafeSpecJF then
        if bFindSpecJF then
          tar, bFindSpecXF = BSQZ_boss1_get_xf_fld(tXF, tFLD, 15)
        else
          bFindSpec1, bSafeSpec1 = BSQZ_boss1_xf_zl(tXunF, tZL)
          if bFindSpec1 then
            if bSafeSpec1 then
              tar, bFindSpecXF = BSQZ_boss1_get_xf_fld(tXF, tFLD, 15)
            end
          else
            tar, bFindSpecXF = BSQZ_boss1_get_xf_fld(tXF, tFLD)
            if nil == tar then
              tar = tBoss
            end
          end
        end
      else
        debugnote = " 远离人群"
      end
      if tar then
        local tid = tar.id
        if bFindSpec1 or bFindSpecJF then
          CDG.pet2.GUID = 0
          CDG.pet3.GUID = 0
          if g_self.isjingong then
            if tar.dst > 3 then
              if tar.dst > 15 or false == JinGongFarSkill(tid) then
                debugnote = " 近攻暂不攻击"
                tid = -1
              else
                tid = -1
              end
            end
          elseif tar.dst > 15 then
            debugnote = " 超出范围暂不攻击"
            tid = -1
          end
          FubenAttack(tid, nil, bFindSpecXF, true, false)
          CDG.pet2.GUID = bGuid2
          CDG.pet3.GUID = bGuid3
        elseif 100 == tar.hp and tar.name == "萧逸风" then
          RunTo(tar.x, tar.y, 1, 1000)
          FubenAttack(tid)
        elseif false == bFirstRun then
          debugnote = " 走位中"
          if BSQZ_boss1_pos(false) then
            bFirstRun = true
          end
        elseif g_self.isjingong then
          FubenAttack(tid, nil, bFindSpecXF)
        elseif tar.name == "旋风" or BSQZ_boss1_pos(false) then
          FubenAttack(tid, nil, bFindSpecXF)
        end
      else
        if bFindSpec1 or bFindSpecJF or bFindSpecXF then
        else
          debugnote = " 未找到boss"
          BSQZ_RefreshStep()
          if m_finish.boss1 then
            break
          end
          RunTo(npc.x, npc.y, 0, 500)
        end
        if bSafeSpec1 and bSafeSpecJF then
          FubenAttack(-1)
        end
      end
    else
      debugnote = " 中飓风术"
    end
    Sleep(50)
    DebugStr("Boss1:" .. npc.name .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  CDG.skill_attack_jinji_disable = ""
  CDG.call.back1 = nil
  BSQZ_RefreshStep()
  local tpos = {}
  table.insert(tpos, {
    x = npc.x,
    y = npc.y
  })
  if tLast.x then
    table.insert(tpos, {
      x = tLast.x,
      y = tLast.y
    })
  end
  BSQZ_boss_finish(m_finish.boss1, npc, tpos)
end

local function BSQZ_boss2_txlz()
  local tAttack
  local bHave_txz = false
  local attackName = " "
  if m_param.boss2_bxn1_hdw2 then
    local nStep, nBossIndex = BSQZ_GetPosStep()
    if 2 == nStep and 1 == nBossIndex then
      attackName = "同心竹·蓝 同心竹·黄 同心竹·紫"
    elseif 2 == nStep and 2 == nBossIndex then
      attackName = "同心竹·红 同心竹·绿 同心竹·白"
    elseif 2 == nStep then
      PushColorMsg("同心竹：识别分工失败")
      return bHave_txz
    end
  else
    if m_param.boss2_bing then
      attackName = attackName .. "同心竹·蓝 "
    end
    if m_param.boss2_huo then
      attackName = attackName .. "同心竹·红 "
    end
    if m_param.boss2_xuan then
      attackName = attackName .. "同心竹·黄 "
    end
    if m_param.boss2_du then
      attackName = attackName .. "同心竹·绿 "
    end
    if m_param.boss2_nei then
      attackName = attackName .. "同心竹·紫 "
    end
    if m_param.boss2_wai then
      attackName = attackName .. "同心竹·白 "
    end
  end
  local tObj = Enum2XByName(attackName, {
    0,
    1,
    0,
    0
  }, {0, 25}, 1, 3)
  for i = 1, #tObj do
    bHave_txz = true
    if not Target:FindBuff(tObj[i], "孪生守护：") then
      tAttack = tObj[i]
      break
    end
  end
  return tAttack, bHave_txz
end

local function BSQZ_boss2_IsBrotherDie(aNpc)
  local nTransTime = GetSceneTransTime()
  local nMsgTime1, szMsgText = IsInDebugMsg("BSQZ_101223_87")
  local nMsgTime2 = IsInDebugMsg("BSQZ_101223_169")
  local bDie = false
  if nMsgTime2 and nTransTime < nMsgTime2 and nMsgTime1 and nMsgTime1 > nMsgTime2 and string.find(szMsgText, aNpc.brother, nil, true) then
    bDie = true
  end
  return bDie
end

local function BSQZ_boss2_is_safe_pos(atPos, atSpec1, atSpec2)
  local rSpec1 = 4
  local rSpec2 = 6
  if IsPosSafe(atPos, atSpec1, rSpec1) and IsPosSafe(atPos, atSpec2, rSpec2) then
    return true
  end
  return false
end

local function BSQZ_boss2_special(aNpc, atSpec1, atSpec2)
  local bHave = false
  local bSafe = true
  local bFind = true
  if #atSpec1 > 0 or #atSpec2 > 0 then
    bHave = true
    local myPos = Player:GetPos()
    if not BSQZ_boss2_is_safe_pos(myPos, atSpec1, atSpec2) then
      bSafe = false
      local posSafe = {}
      local allPos = GetRangeAllPos(aNpc.x, aNpc.y, 1, 12, nil)
      for i = 1, #allPos do
        if BSQZ_boss2_is_safe_pos(allPos[i], atSpec1, atSpec2) then
          table.insert(posSafe, allPos[i])
        end
      end
      if #posSafe > 0 then
        BubbleByDst(posSafe, 1)
        FastRun(posSafe[1], 5)
      else
        bFind = false
      end
    end
  end
  return bHave, bSafe, bFind
end

local function BSQZ_boss2_EnumObj(aNpc)
  local tAll = Enum2XByClass("怪物 陷阱", nil, 3)
  local tBoss1 = ObjFilterByName(tAll, aNpc.name, 0)
  tBoss1 = tBoss1[1]
  local tBoss2 = ObjFilterByName(tAll, aNpc.brother, 0)
  tBoss2 = tBoss2[1]
  local tSpec1 = {}
  local tZCCG = ObjFilterByName(tAll, "竹刺·穿骨", 5)
  local tYDSRA = ObjFilterByName(tAll, "诱敌深入A", 5)
  for i = 1, #tZCCG do
    table.insert(tSpec1, tZCCG[i])
  end
  for i = 1, #tYDSRA do
    table.insert(tSpec1, tYDSRA[i])
  end
  local tSpec2 = {}
  local tZCCS = ObjFilterByName(tAll, "竹刺·缠身", 5)
  local tYDSRB = ObjFilterByName(tAll, "诱敌深入B", 5)
  for i = 1, #tZCCS do
    table.insert(tSpec2, tZCCS[i])
  end
  for i = 1, #tYDSRB do
    table.insert(tSpec2, tYDSRB[i])
  end
  return tBoss1, tSpec1, tSpec2, tBoss2
end

local function BSQZ_boss2_pos(aNpc, aFast, aOnlyGet)
  local bOK = true
  local r = 5
  local nGroup, myIndex = Raid:GetMyRaidIndex()
  if myIndex < 0 or myIndex > 5 then
    DebugColorMsg("迷踪:团队索引获取失败！", 4)
    myIndex = 0
  end
  local tPos = GetAveragePoint(aNpc.x, aNpc.y, r, 6, 0)
  local run = tPos[myIndex + 1]
  if not aOnlyGet then
    if aFast then
      bOK = FastRun(run, 5)
    else
      bOK = not RunTo(run.x, run.y, 0, 1000)
    end
  end
  return bOK, run
end

local function BSQZ_boss2_get_next_pos_angle(atAllPos, aCmpPos)
  local nextPos
  for i = 1, #atAllPos do
    if atAllPos[i].angle > aCmpPos.angle then
      nextPos = atAllPos[i]
      break
    end
  end
  nextPos = nextPos or atAllPos[1]
  return nextPos
end

local function BSQZ_IsLineSafe(aPosA, aPosB, atSpec1, atSpec2)
  local tLinePos = GetLinePos(aPosA, aPosB, 2)
  GetAllPosDist(tLinePos)
  for i = 1, #tLinePos do
    local tmp = tLinePos[i]
    if tmp.dst >= 3 and not BSQZ_boss2_is_safe_pos(tmp, atSpec1, atSpec2) then
      return false
    end
  end
  return true
end

local function BSQZ_boss2_player(aNpc)
  local tPlayer = Enum2XByClass("玩家")
  for i = #tPlayer, 1, -1 do
    if tPlayer[i].name == g_self.name then
      table.remove(tPlayer, i)
    end
  end
  local tBoss1, tSpec1, tSpec2, tBoss2 = BSQZ_boss2_EnumObj(aNpc)
  for i = 1, #tSpec2 do
    table.insert(tPlayer, tSpec2[i])
  end
  local _, _, bFind = BSQZ_boss2_special(aNpc, tSpec1, tPlayer)
  return bFind
end

local function BSQZ_boss2_check_buff(aNpc)
  local bHaveCG = false
  local bHaveCS = false
  local bSafe = true
  local bFindSafePos = true
  local tBoss1Run = {
    {x = 159, y = 45},
    {x = 158, y = 49},
    {x = 160, y = 57},
    {x = 168, y = 57},
    {x = 176, y = 57},
    {x = 188, y = 57},
    {x = 188, y = 49},
    {x = 188, y = 41},
    {x = 187, y = 33},
    {x = 183, y = 26},
    {x = 176, y = 22},
    {x = 165, y = 29},
    {x = 163, y = 40}
  }
  local tBoss2Run = {
    {x = 154, y = 101},
    {x = 154, y = 111},
    {x = 162, y = 111},
    {x = 167, y = 118},
    {x = 175, y = 112},
    {x = 182, y = 107},
    {x = 189, y = 100},
    {x = 189, y = 92},
    {x = 183, y = 85},
    {x = 176, y = 85},
    {x = 168, y = 85},
    {x = 160, y = 87},
    {x = 156, y = 93}
  }
  local tRunPos = tBoss1Run
  if aNpc.name == "萧如蔚" then
    tRunPos = tBoss2Run
  end
  local myPos = Player:GetPos()
  if -1 ~= Player:GetBuff("迷踪：") then
    bHaveCS = true
    local oldTick = GetTickCount()
    local tBoss1, tSpec1, tSpec2, tBoss2 = BSQZ_boss2_EnumObj(aNpc)
    local rSpec1 = 4
    local tSafePos = {}
    for i = 1, #tRunPos do
      if BSQZ_boss2_is_safe_pos(tRunPos[i], tSpec1, tSpec2) and BSQZ_IsLineSafe(myPos, tRunPos[i], tSpec1, tSpec2) then
        table.insert(tSafePos, tRunPos[i])
      end
    end
    GetAllPosDist(tSafePos)
    if #tSafePos > 0 then
      BubbleByDst(tSafePos)
      local runPos = tSafePos[1]
      if tBoss1 and tBoss1.hp < 25 then
        FastSkill(runPos, 5)
        RunTo(runPos.x, runPos.y, 0, 200)
      end
      while -1 ~= Player:GetBuff("迷踪：") do
        RunTo(runPos.x, runPos.y, 0, 200)
        Sleep(10)
        if GetTickCount() - oldTick > 4800 then
          break
        end
      end
      local flyPos = myPos
      tBoss1, tSpec1, tSpec2, tBoss2 = BSQZ_boss2_EnumObj(aNpc)
      if BSQZ_boss2_is_safe_pos(flyPos, tSpec1, tSpec2) and GetDist(flyPos.x, flyPos.y) > 5 then
      else
        _, flyPos = BSQZ_boss2_pos(aNpc, false, true)
        if not BSQZ_boss2_is_safe_pos(flyPos, tSpec1, tSpec2) then
          local tPos = GetAveragePoint(flyPos.x, flyPos.y, 4, 36, 0)
          local tFlySafe = {}
          for i = 1, #tPos do
            if BSQZ_boss2_is_safe_pos(tPos[i], tSpec1, tSpec2) then
              table.insert(tFlySafe, tPos[i])
            end
          end
          if #tFlySafe > 0 then
            GetAllPosDist(tFlySafe, aNpc)
            BubbleByDst(tFlySafe)
            flyPos = tFlySafe[1]
          end
        end
      end
      Skill:UseQingGong(flyPos.x, flyPos.y)
      Sleep(600)
      if PlayerStateTimeOut(3, 3, nil) then
        Sleep(300)
      end
      RunTo(flyPos.x, flyPos.y, 0, 300)
    else
      PushColorMsg("迷踪：未找到安全坐标")
      bFindSafePos = BSQZ_boss2_player(aNpc)
    end
  elseif -1 ~= Player:GetBuff("束步：") or -1 ~= Player:GetBuff("步步生竹：") then
    bHaveCG = true
    local rSpec1 = 5
    for i = 1, #tRunPos do
      tRunPos[i].angle = GetAngle(aNpc.x, aNpc.y, tRunPos[i].x, tRunPos[i].y)
      tRunPos[i].dst = GetDist(myPos.x, myPos.y, tRunPos[i].x, tRunPos[i].y)
    end
    local tRaidPos = GetAveragePoint(aNpc.x, aNpc.y, 11, 36, 0)
    for i = 1, #tRaidPos do
      tRaidPos[i].angle = GetAngle(aNpc.x, aNpc.y, tRaidPos[i].x, tRaidPos[i].y)
    end
    BubbleByDst(tRunPos)
    local startPos = tRunPos[1]
    BubbleSort(tRunPos, "angle")
    local runPos = {
      x = startPos.x,
      y = startPos.y,
      angle = startPos.angle
    }
    local tBoss1, tSpec1Ref, tSpec2Ref, tBoss2 = BSQZ_boss2_EnumObj(aNpc)
    local nMaxCount = 1
    while not BSQZ_boss2_is_safe_pos(runPos, tSpec1Ref, tSpec2Ref) and nMaxCount < 20 do
      runPos = BSQZ_boss2_get_next_pos_angle(tRunPos, runPos)
      nMaxCount = nMaxCount + 1
    end
    local errRun = 0
    while -1 ~= Player:GetBuff("束步：") or -1 ~= Player:GetBuff("步步生竹：") do
      tBoss1, tSpec1Ref, tSpec2Ref, tBoss2 = BSQZ_boss2_EnumObj(aNpc)
      local myPos = Player:GetPos()
      if BSQZ_boss2_is_safe_pos(runPos, tSpec1Ref, tSpec2Ref) and BSQZ_IsLineSafe(myPos, runPos, tSpec1Ref, tSpec2Ref) then
        errRun = 0
        if tBoss1 and tBoss1.hp < 25 then
          FastSkill(runPos, 5)
        end
        if RunTo(runPos.x, runPos.y, 1, 500) == false then
          runPos = BSQZ_boss2_get_next_pos_angle(tRunPos, runPos)
        end
      else
        runPos = BSQZ_boss2_get_next_pos_angle(tRaidPos, runPos)
        errRun = errRun + 1
      end
      if errRun > #tRaidPos then
        PushColorMsg("步步生竹：未找到安全坐标")
        bFindSafePos = BSQZ_boss2_player(aNpc)
        break
      end
      if 4 == g_self.menpai and tBoss1 and tBoss1.hp < 16 then
        Skill:UseName("呆若木鸡", 500)
      end
      Sleep(50)
      DebugStr("步步生竹陷阱", 2)
    end
  end
  return bHaveCG, bHaveCS, bFindSafePos
end

local function BSQZ_boss2_action_callback()
  if -1 ~= Player:GetBuff("迷踪：") then
    return false
  end
  if -1 ~= Player:GetBuff("束步：") then
    return false
  end
  if -1 ~= Player:GetBuff("步步生竹：") then
    return false
  end
  local tBoss = {
    {
      name = "萧如筠",
      brother = "萧如蔚",
      x = 174,
      y = 36,
      xSafe = 139,
      ySafe = 64,
      xCheck = 172,
      yCheck = 56,
      step = 2
    },
    {
      name = "萧如蔚",
      brother = "萧如筠",
      x = 174,
      y = 100,
      xSafe = 134,
      ySafe = 110,
      xCheck = 172,
      yCheck = 84,
      step = 2
    }
  }
  local npc = tBoss[2]
  local nStep, nBossIndex = BSQZ_GetPosStep()
  if 1 == nBossIndex then
    npc = tBoss[1]
  end
  local tBoss1, tSpec1, tSpec2, tBoss2 = BSQZ_boss2_EnumObj(npc)
  local bHaveSpec, bSafeSpec = BSQZ_boss2_special(npc, tSpec1, tSpec2)
  if not bSafeSpec then
    return false
  end
  return true
end

local function BSQZ_Boss2_OnAction(aActionBossIndex)
  local tBoss = {
    {
      name = "萧如筠",
      brother = "萧如蔚",
      x = 174,
      y = 36,
      xSafe = 139,
      ySafe = 64,
      xCheck = 172,
      yCheck = 56,
      step = 2
    },
    {
      name = "萧如蔚",
      brother = "萧如筠",
      x = 174,
      y = 100,
      xSafe = 134,
      ySafe = 110,
      xCheck = 172,
      yCheck = 84,
      step = 2
    }
  }
  local npc = tBoss[2]
  if 1 == aActionBossIndex then
    npc = tBoss[1]
  end
  local tLast = {
    x = npc.x,
    y = npc.y
  }
  if m_param.boss2_safe_wait then
    while FubenCheckSceneDie(m_data.sceneID) do
      local debugnote = " 安全点休息"
      local bOver = false
      local tObj = Enum2XByName(npc.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tObj > 0 then
        tLast.x = tObj[1].x
        tLast.y = tObj[1].y
        if 0 == tObj[1].hp and m_param.isattack then
          PushDebugMessage("Boss2：已结束,前往战斗区域")
          RunTo(npc.x, npc.y, 0, 1000)
          break
        end
      else
        BSQZ_RefreshStep()
        if m_finish.boss2 then
          bOver = true
          PickUpLua(nil, true, true)
          UseMount()
          if RunTo(npc.x, npc.y, 3, 1000) == false then
            break
          end
        end
      end
      local nStep, nBossIndex = BSQZ_GetPosStep()
      if 2 ~= nStep then
        PushDebugMessage("Boss2:已不在战斗区域")
        break
      end
      if false == bOver and RunTo(npc.xSafe, npc.ySafe, 1, 1000) == false then
        FubenAttack(-1)
      end
      Sleep(50)
      DebugStr("Boss2:" .. npc.name .. debugnote)
    end
  end
  local bFirstRun = false
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.skill_attack_jinji_disable = " 棒打狗头 凌神式 拖泥带水 行尸走肉 "
  CDG.call.back1 = BSQZ_boss2_action_callback
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    local bHaveCG, bHaveCS, bFindSafePos = BSQZ_boss2_check_buff(npc)
    if not (bHaveCG or bHaveCS) or not bFindSafePos then
      local tBoss1, tSpec1, tSpec2, tBoss2 = BSQZ_boss2_EnumObj(npc)
      local bHaveSpec, bSafeSpec, bFindSafeSpec = BSQZ_boss2_special(npc, tSpec1, tSpec2)
      if bSafeSpec or not bFindSafeSpec then
        if not bHaveSpec and not tBoss1 then
          BSQZ_RefreshStep()
          if m_finish.boss2 then
            break
          end
          local nStep, nBossIndex = BSQZ_GetPosStep()
          if 2 ~= nStep then
            PushDebugMessage("Boss2:已不在战斗区域.")
            break
          end
          debugnote = " 没有找到boss"
          RunTo(npc.x, npc.y, 0, 500)
        end
        local tAttackTXZ, bHave_txz = BSQZ_boss2_txlz()
        local tar = tAttackTXZ or tBoss1
        local bJinJi = false
        local bUsePet = false
        if tAttackTXZ then
        elseif tBoss1 then
          local bBrotherDie = BSQZ_boss2_IsBrotherDie(npc)
          tLast.x = tBoss1.x
          tLast.y = tBoss1.y
          if 0 == tBoss1.hp then
            debugnote = " 已死亡"
            RunTo(tBoss1.x, tBoss1.y, 3, 500)
          else
            if bBrotherDie then
              debugnote = debugnote .. " 集火攻击"
              bJinJi = bBrotherDie
            end
            if m_param.boss2_safe_wait then
              break
            end
          end
        end
        if tar then
          local tid = tar.id
          if tar.name == "萧如筠" or tar.name == "萧如蔚" then
            if tar.hp > 0 then
              if Target:FindBuff(tar, "无敌：") then
                tid = -1
              end
              if 4 == g_self.menpai and tar.hp < 25 then
                RelivePlayerJZDJ(25)
              end
            else
              tid = -1
            end
          end
          if bHaveSpec then
            if -1 ~= tid and bFindSafeSpec then
              if Player:GetMPP() > 10 then
                CDG.pet2.GUID = 0
                CDG.pet3.GUID = 0
              end
              local rSpec = 4
              if g_self.isjingong then
                if tar.dst > 3 then
                  if tar.dst > 15 or false == JinGongFarSkill(tid) then
                    debugnote = debugnote .. " 超出范围"
                    tid = -1
                    local zero = npc
                    zero.r = 11
                    local bRun = AStarRun(zero, tar, tSpec1, rSpec, nil, nil, 3)
                  else
                    tid = -1
                  end
                end
              elseif tar.dst > 15 then
                debugnote = debugnote .. " 超出范围"
                tid = -1
                local zero = npc
                zero.r = 11
                local bRun = AStarRun(zero, tar, tSpec1, rSpec, nil, nil, 3)
              end
            end
            FubenAttack(tid, nil, bJinJi, nil, bUsePet)
            CDG.pet2.GUID = bGuid2
            CDG.pet3.GUID = bGuid3
          elseif false == bFirstRun then
            debugnote = " 走位中"
            if BSQZ_boss2_pos(npc, false, false) then
              bFirstRun = true
            end
          elseif g_self.isjingong then
            FubenAttack(tid, nil, bJinJi, nil, bUsePet)
          elseif tBoss1 and 0 == tBoss1.hp then
            FubenAttack(-1)
            RelivePlayer(1, nil, nil, nil, nil, true)
          else
            BSQZ_boss2_pos(npc, false, false)
            FubenAttack(tid, nil, bJinJi, nil, bUsePet)
          end
        elseif not bHaveSpec then
          FubenAttack(-1)
          RelivePlayer(1, nil, nil, nil, nil, true)
        end
      else
        debugnote = " 躲避陷阱."
      end
    end
    Sleep(50)
    DebugStr("Boss2:" .. npc.name .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  CDG.skill_attack_jinji_disable = ""
  CDG.call.back1 = nil
  BSQZ_RefreshStep()
  local tpos = {}
  table.insert(tpos, {
    x = npc.x,
    y = npc.y
  })
  if tLast.x then
    table.insert(tpos, {
      x = tLast.x,
      y = tLast.y
    })
  end
  BSQZ_boss_finish(m_finish.boss2, npc, tpos)
end

local function BSQZ_Boss2(szClass, aType)
  local npc = m_data.boss[2]
  DebugStr(m_data.sceneName .. "：" .. npc.name .. " " .. szClass .. aType)
  local pos = Player:GetPos()
  if pos.x < 108 or pos.y > 120 then
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua(nil, true, true)
    MoveTo(109, 93, -1, 1, nil, nil, BSQZ_callback_run)
    return
  end
  if BSQZ_qlxg(npc, "林阵守卫") then
    return
  end
  if BSQZ_qlxg(npc, "风阵守卫") then
    return
  end
  local nStep, nBossIndex = BSQZ_GetPosStep()
  if 2 == nStep then
    if false == BSQZ_IsBossStart(npc) then
      MPCheck100(m_param.mp_check_ever)
      if false == BSQZ_IsAllInStepPos(npc.step) and false == BSQZ_IsWaitRaidTickOut(npc) then
        if 1 == nBossIndex then
          RunTo(147, 60, 0, 500)
        elseif 2 == nBossIndex then
          RunTo(140, 109, 0, 500)
        else
          PushColorMsg("Boss2坐标阶段有误")
        end
        FubenAttack(-1)
        return
      end
      CheckAllRaidHP(85, BSQZ_callback_hp, 45)
      local boss = {
        name = "萧如筠 萧如蔚",
        step = 2
      }
      BSQZ_em_xsx(boss)
    end
    BSQZ_Boss2_OnAction(nBossIndex)
    return
  end
  if 3 == m_param.boss2_which then
    local idx = Raid:GetMyRaidIndex()
    if 0 ~= idx then
      m_param.boss2_which = 2
    else
      m_param.boss2_which = 1
    end
  end
  if 1 == m_param.boss2_which then
    MoveTo(147, 60, -1, 1, nil, nil, BSQZ_callback_run)
    return
  end
  MoveTo(140, 109, -1, 1, nil, nil, BSQZ_callback_run)
  return
end

local function BSQZ_boss3_EnumObj()
  local tAll = Enum2XByClass("怪物 陷阱 NPC", nil, 3)
  local tBoss1 = ObjFilterByName(tAll, "耶律焱", 0)
  tBoss1 = tBoss1[1]
  local tShuiJi = ObjFilterByName(tAll, "水迹", 0)
  local tXianJin = ObjFilterByName(tAll, "地火焚天", 5)
  local tNiuYao = ObjFilterByName(tAll, "地府牛妖", 0)
  tNiuYao = ObjFilterByHP(tNiuYao, 0, 1)
  local tNY_self = ObjFilterByTitle(tNiuYao, "冲向" .. g_self.name, 0)
  return tBoss1, tShuiJi, tXianJin, tNiuYao, tNY_self
end

local function BSQZ_boss3_hn_check()
  local bNext = false
  local bIsSelf = false
  local nMsgTime = IsInDebugMsg("#{BSQZ_101223_122}")
  if nMsgTime and os.time() - nMsgTime <= 6 then
    bNext = true
  end
  if -1 ~= Player:GetBuff("目标锁定：携带者勿让地狱牛妖靠近") then
    bIsSelf = true
  end
  return bNext, bIsSelf
end

local function BSQZ_boss3_qlrh(aNpc, atShuiJi)
  local bFind, bSafe = false, true
  local tShuiJi = atShuiJi
  if #tShuiJi > 0 then
    bFind = true
    if #m_data.shuiji_unsafe >= 3 then
      m_data.shuiji_unsafe = {}
    end
    local bRun = true
    if -1 ~= Player:GetBuff("御火术：") then
      for i = 1, #tShuiJi do
        if tShuiJi[i].dst < 3 then
          bRun = false
          break
        end
      end
    else
      for i = 1, #tShuiJi do
        if tShuiJi[i].dst < 1 and not FindTableValue(m_data.shuiji_unsafe, tShuiJi[i].id) then
          table.insert(m_data.shuiji_unsafe, tShuiJi[i].id)
        end
      end
    end
    if bRun then
      bSafe = false
      local nFindCount = 0
      for i = 1, #tShuiJi do
        tShuiJi[i].angle = GetAngle(aNpc.x, aNpc.y, tShuiJi[i].x, tShuiJi[i].y)
        tShuiJi[i].buff_count = 0
        local bFind, strBuff = Target:FindBuff(tShuiJi[i], "水迹")
        if bFind then
          strBuff = string.gsub(strBuff, "水迹", "")
          tShuiJi[i].buff_count = tonumber(strBuff) or 0
          nFindCount = nFindCount + tShuiJi[i].buff_count
        end
      end
      for i = 1, #tShuiJi do
        if 0 == tShuiJi[i].buff_count then
          PushColorMsg("识别水迹失败！")
        end
      end
      local sjIndex = 1
      local nCalcCount = 0
      local raidIndex = Raid_GetIndex() + 1
      for i = 1, #tShuiJi do
        local nNowCount = tShuiJi[i].buff_count + nCalcCount
        if nCalcCount < raidIndex and raidIndex <= nNowCount then
          sjIndex = i
          break
        end
        nCalcCount = nNowCount
      end
      local runSJ = tShuiJi[sjIndex]
      if FindTableValue(m_data.shuiji_unsafe, runSJ.id) then
        PushColorMsg("默认水迹位被占！")
        BubbleByDst(tShuiJi)
        for i = 1, #tShuiJi do
          if not FindTableValue(m_data.shuiji_unsafe, tShuiJi[i].id) then
            runSJ = tShuiJi[i]
            break
          end
        end
      end
      FastRun(runSJ, 5)
    else
      bSafe = true
    end
  else
    m_data.shuiji_unsafe = {}
  end
  return bFind, bSafe
end

local function BSQZ_boss3_special(aNpc, atBoss, atXianJin, atNY_self)
  local bHave = false
  local bHave_HN = false
  local bSafe = true
  local tSpec = {}
  local tBoss1 = atBoss
  local tXianJin = atXianJin
  local tNY_self = atNY_self
  local bNext_hn, bIsSelf_hn = BSQZ_boss3_hn_check()
  for i = 1, #tXianJin do
    table.insert(tSpec, tXianJin[i])
  end
  for i = 1, #tNY_self do
    bHave_HN = true
    table.insert(tSpec, tNY_self[i])
  end
  if bNext_hn and tBoss1 then
    bHave_HN = true
    table.insert(tSpec, tBoss1)
  end
  if #tSpec > 0 then
    bHave = true
    if bHave_HN then
      bSafe = FubenTrapRun("", aNpc.x, aNpc.y, 7, 14, tSpec, nil, FubenRunSafe, nil, nil, nil)
    else
      bSafe = FubenTrapRun(aNpc.name, aNpc.x, aNpc.y, 7, 14, tSpec, nil, FubenRunSafe, nil, nil, nil)
    end
  end
  return bHave, bSafe, bHave_HN
end

local function BSQZ_boss3_fhlx_checkHP(aNpc, aBoss)
  local bSafe, bShui_three = true, false
  if aBoss and aBoss.hp and aBoss.hp < 34 then
    local nTransTime = GetSceneTransTime()
    local nMsgTime1 = IsInDebugMsg("BSQZ_101223_94")
    local nMsgTime2 = IsInDebugMsg("BSQZ_101223_101")
    local nMsgTime3 = IsInDebugMsg("BSQZ_101223_122")
    if nMsgTime1 and nMsgTime3 and nMsgTime1 > nMsgTime3 and nTransTime < nMsgTime1 then
      bShui_three = true
    end
  end
  return bSafe, bShui_three
end

local function BSQZ_boss3_fhlx_runsafe(aAllSafePos)
  local run = {x = 192, y = 195}
  for i = 1, #aAllSafePos do
    aAllSafePos[i].hp = GetDist(aAllSafePos[i].x, aAllSafePos[i].y, run.x, run.y)
  end
  BubbleByHP(aAllSafePos, 1)
  return not RunTo(aAllSafePos[1].x, aAllSafePos[1].y, 0, 500)
end

local function BSQZ_boss3_action_callback()
  local tBoss1, tShuiJi, tXianJin, tNiuYao, tNY_self = BSQZ_boss3_EnumObj()
  if #tShuiJi > 0 and -1 == Player:GetBuff("御火术：") then
    return false
  else
  end
  if #tNY_self > 0 then
    return false
  end
  local bNext_hn, bIsSelf_hn = BSQZ_boss3_hn_check()
  if bNext_hn then
    return false
  end
  if 0 == #tShuiJi then
    local npc = m_data.boss[3]
    local bHave_spec, bSafe_spec, bHave_self_HN = BSQZ_boss3_special(npc, tBoss1, tXianJin, tNY_self)
    if not bSafe_spec then
      return false
    end
  end
  return true
end

local function BSQZ_Boss3(szClass, nType)
  local npc = m_data.boss[3]
  DebugStr(m_data.sceneName .. "：" .. npc.name .. " " .. szClass .. nType)
  local pos = Player:GetPos()
  if pos.x < 141 or pos.y < 150 then
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua(nil, true, true)
    RelivePlayer(1, nil, nil, nil, nil, true)
    MoveTo(196, 155, -1, 1, nil, nil, BSQZ_callback_run)
    return
  end
  if BSQZ_qlxg(npc, "火阵守卫") then
    return
  end
  if pos.y < 155 then
    DebugStr(npc.name .. ":移动到战斗区域", 2)
    RunTo(196, 155, 0, 500)
    return
  end
  if false == BSQZ_IsBossStart(npc) then
    MPCheck100(m_param.mp_check_ever)
    if false == BSQZ_IsAllInStepPos(npc.step) and false == BSQZ_IsWaitRaidTickOut(npc) then
      FubenAttack(-1)
      return
    end
    CheckAllRaidHP(85, BSQZ_callback_hp, 45)
    BSQZ_em_xsx(npc)
  end
  if not m_param.boss3_safe_wait and RunTo(193, 193, 10, 600) then
    return
  end
  local tLast = {
    x = npc.x,
    y = npc.y
  }
  if m_param.boss3_safe_wait then
    while FubenCheckSceneDie(m_data.sceneID) do
      local debugnote = " 安全点等待"
      local bOver = false
      local tObj = Enum2XByName(npc.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tObj > 0 then
        tLast.x = tObj[1].x
        tLast.y = tObj[1].y
      else
        BSQZ_RefreshStep()
        if m_finish.boss3 then
          bOver = true
          UseMount()
          PickUpLua(nil, true, true)
          if RunTo(npc.x, npc.y, 0, 500) == false then
            break
          end
        end
      end
      if 3 ~= BSQZ_GetPosStep() then
        PushDebugMessage("Boss3:已不在战斗区域")
        break
      end
      if false == bOver and false == RunTo(npc.xSafe, npc.ySafe, 0, 1000) then
        FubenAttack(-1)
      end
      Sleep(50)
      DebugStr("Boss3:" .. npc.name .. debugnote)
    end
  end
  local bFirstRun = false
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.skill_attack_jinji_disable = " 棒打狗头 凌神式 移魂大法·魔宗 拖泥带水 行尸走肉 "
  CDG.call.back1 = BSQZ_boss3_action_callback
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = " "
    local tBoss1, tShuiJi, tXianJin, tNiuYao, tNY_self = BSQZ_boss3_EnumObj()
    local bFind_SJ, bSafe_SJ = BSQZ_boss3_qlrh(npc, tShuiJi)
    local bHave_spec, bSafe_spec, bHave_self_HN = false, true, false
    local bUsePet = true
    local bJinJi = false
    local tar = tBoss1
    if bSafe_SJ then
      if bFind_SJ then
        tar = nil
      else
        bHave_spec, bSafe_spec, bHave_self_HN = BSQZ_boss3_special(npc, tBoss1, tXianJin, tNY_self)
      end
      if bSafe_spec then
        if #tNiuYao > 0 then
          bUsePet = false
          bJinJi = true
          CDG.pet2.GUID = 0
          CDG.pet3.GUID = 0
          BubbleByDst(tNiuYao, 1)
          if false == g_self.isjingong then
            for i = 1, #tNiuYao do
              if tNiuYao[i].dst < 15 then
                Skill:UseKongZhi_fuben(tNiuYao[i], true, true)
              end
            end
          else
            for i = 1, #tNiuYao do
              if tNiuYao[i].dst < 3 then
                Skill:UseKongZhi_fuben(tNiuYao[i], true, true)
              end
            end
          end
          BubbleByHP(tNiuYao)
          for i = 1, #tNiuYao do
            if tNiuYao[i].dst <= 15 then
              tar = tNiuYao[i]
              break
            end
          end
        end
        if tar then
          if tar.name == "地府牛妖" then
            if g_self.isjingong then
              JinGongFarSkill(tar.id)
            else
              FubenAttack(tar.id, nil, bJinJi, true, bUsePet)
            end
          else
            tLast.x = tar.x
            tLast.y = tar.y
            if 0 == tar.hp then
              m_finish.boss3 = true
              break
            end
            if false == bFirstRun and tar.hp > 34 then
              debugnote = " 走位中"
              if BSQZ_start_pos(npc) then
                bFirstRun = true
              end
            else
              local bCheckRaidHP, bShui_three = BSQZ_boss3_fhlx_checkHP(npc, tar)
              local bSafe_FHLX = false
              if bShui_three then
                local radius = 6
                local run = {x = 192, y = 195}
                if IsPosSafe(run, tXianJin, radius) then
                  bSafe_FHLX = not RunTo(run.x, run.y, 0, 500)
                else
                  local safePos = GetRangeAllPos(npc.x, npc.y, 1, 13)
                  safePos = GetAllSafePos(tXianJin, safePos, radius)
                  if #safePos > 0 then
                    bSafe_FHLX = BSQZ_boss3_fhlx_runsafe(safePos)
                  end
                end
              else
                bSafe_FHLX = true
              end
              if bSafe_FHLX then
                if g_self.isjingong then
                  if tar.dst >= 3 then
                    if bHave_spec then
                      if not bShui_three and not bHave_self_HN then
                        local zero = npc
                        zero.r = 14
                        local bRun = AStarRun(zero, tar, tXianJin, 6, nil, nil, 3)
                      end
                    elseif not bShui_three then
                      FubenAttack(tar.id, nil, false, true, true)
                    end
                  else
                    FubenAttack(tar.id, nil, false, true, true)
                  end
                else
                  FubenAttack(tar.id, nil, false, true, true)
                end
              end
            end
          end
        else
          FubenAttack(-1)
          if not bFind_SJ then
            BSQZ_RefreshStep()
            if m_finish.boss3 then
              break
            end
            debugnote = " 没有找到boss"
            if RunTo(npc.x, npc.y, 0, 500) == false then
              break
            end
          end
        end
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
      else
        debugnote = " 躲避陷阱"
      end
    else
      debugnote = " 躲避侵略如火"
    end
    Sleep(100)
    DebugStr("Boss3:耶律焱" .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  CDG.skill_attack_jinji_disable = ""
  CDG.call.back1 = nil
  BSQZ_RefreshStep()
  local tpos = {}
  table.insert(tpos, {
    x = npc.x,
    y = npc.y
  })
  if tLast.x then
    table.insert(tpos, {
      x = tLast.x,
      y = tLast.y
    })
  end
  BSQZ_boss_finish(m_finish.boss3, npc, tpos)
end

local function BSQZ_callback_run_boss4(fX, fY, nScene)
  local pos = Player:GetPos()
  if pos.x <= 114 and pos.y >= 170 then
    RunTo(82, 200, 0, 500)
    return false
  end
  return BSQZ_callback_run(fX, fY, nScene)
end

local function BSQZ_boss4_EnumObj()
  local tAll = Enum2XByClass("怪物 陷阱 NPC", nil, 3)
  local tBoss1 = ObjFilterByName(tAll, "耶律连城", 0)
  tBoss1 = tBoss1[1]
  local tYuanShen = ObjFilterByName(tAll, "耶律连城·元神", 0)
  tYuanShen = ObjFilterByHP(tYuanShen, 0, 1)
  local tTieGu = ObjFilterByName(tAll, "耶律连城·铁骨", 0)
  tTieGu = ObjFilterByHP(tTieGu, 0, 1)
  local tGunShi = ObjFilterByName(tAll, "滚石", 0)
  local tShiDui = ObjFilterByName(tAll, "石堆", 0)
  tShiDui = ObjFilterByHP(tShiDui, 0, 1)
  local tTunTianShi = ObjFilterByName(tAll, "吞天石", 0)
  local tXianJin = ObjFilterByName(tAll, "飞沙走石-预警", 0)
  return tBoss1, tYuanShen, tTieGu, tGunShi, tShiDui, tTunTianShi, tXianJin
end

local function BSQZ_boss4_tgys(atYS, atTG)
  local bHave_tgys = false
  if 0 == #atYS and 0 == #atTG then
    return bHave_tgys
  end
  bHave_tgys = true
  local bWaiGong = Player:IsWaiGong()
  local tFZ = {
    ["耶律连城·铁骨"] = {x = 52, y = 212},
    ["耶律连城·元神"] = {x = 53, y = 195}
  }
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = " "
    local tBoss1, tYS, tTG, tGunShi, tShiDui, tTunTianShi, tXianJin = BSQZ_boss4_EnumObj()
    if 0 == #tTG and 0 == #tYS or #tTunTianShi > 0 then
      break
    end
    PickUpLua(nil, true, true)
    local tAttack = {}
    if g_self.isjingong or bWaiGong then
      if #tYS > 0 then
        debugnote = ",打元神"
        tAttack = tYS
        for i = 1, #tTG do
          if tTG[i].target == Player:GetTID() then
            Skill:UseName("初级隐遁", 1500)
          end
          Pet:CheckRelax(tTG[i].target, 1)
        end
      elseif #tTG > 0 then
        debugnote = ",打铁骨"
        tAttack = tTG
      end
    end
    if 0 == #tAttack and (g_self.isjingong == false or false == bWaiGong) then
      if #tTG > 0 then
        debugnote = ",打铁骨!"
        tAttack = tTG
        for i = 1, #tYS do
          if tYS[i].target == Player:GetTID() then
            Skill:UseName("初级隐遁", 1500)
          end
          Pet:CheckRelax(tYS[i].target, 1)
        end
      else
        debugnote = ",打元神!"
        tAttack = tYS
      end
    end
    if #tAttack > 0 then
      local bAttack = true
      local petID = Pet:GetTID()
      local selfID = Player:GetTID()
      for i = 1, #tAttack do
        if tAttack[i].target == selfID or tAttack[i].target == petID and -1 ~= petID then
          local run = tFZ[tAttack[i].name]
          if run and run.x and run.y and RunTo(run.x, run.y, 1, 500) then
            debugnote = debugnote .. " 拉进符阵"
            bAttack = false
          end
        end
      end
      if bAttack then
        BubbleByDst(tAttack, 1)
        local tmp = tAttack[1]
        local runpos = tFZ[tmp.name]
        if g_self.isjingong == false then
          local run = GetRunposOfRange(runpos, tmp, 14)
          if RunTo(run.x, run.y, 1, 500) then
            debugnote = debugnote .. " 走向符阵"
            bAttack = false
          end
        end
      end
      if bAttack then
        local tmp = tAttack[1]
        ZhiDianJiangShanObj(tmp, true)
        if 8 == g_self.menpai then
          XiShanXingLv(tmp.id)
        end
        FubenAttack(tmp.id, nil, nil, true, false)
      end
    else
      debugnote = " 未找到攻击目标铁骨、元神"
    end
    Sleep(50)
    DebugStr("Boss4:铁骨元神" .. debugnote)
  end
  return bHave_tgys
end

local function BSQZ_gunshi_possafe(aPos, atGunShi)
  local bSafe = true
  for i = 1, #atGunShi do
    if math.abs(aPos.y - atGunShi[i].y) < 6 then
      bSafe = false
      break
    end
  end
  return bSafe
end

local function BSQZ_boss4_gunshi(atGunShi)
  local npc = m_data.boss[4]
  local bHave = false
  local bSafe = true
  local tGunShi = atGunShi
  if #tGunShi > 0 then
    bHave = true
    local myPos = Player:GetPos()
    if not BSQZ_gunshi_possafe(myPos, tGunShi) then
      bSafe = false
      local allPos = GetRangeAllPos(npc.x, npc.y, 1, 15, nil)
      local posSafe = {}
      for i = 1, #allPos do
        if BSQZ_gunshi_possafe(allPos[i], tGunShi) then
          table.insert(posSafe, allPos[i])
        end
      end
      if #posSafe > 0 then
        GetAllPosDist(posSafe, myPos)
        BubbleByDst(posSafe)
        local run = posSafe[1]
        RunTo(run.x, run.y, 0, 500)
      end
    end
  end
  return bHave, bSafe
end

local function BSQZ_boss4_shidui(atShuiDui)
  local bHave = false
  local tar
  local tShiDui = atShuiDui
  if #tShiDui > 0 then
    bHave = true
    if -1 ~= Player:GetBuff("石牢：") then
      while -1 ~= Player:GetBuff("石牢：") do
        Sleep(600)
        DebugStr("被封入石牢", 2)
      end
    else
      local tUnSafePlayer = {}
      local tWanJia = Enum2XByClass("玩家", {0, -1})
      for i = 1, #tWanJia do
        if Target:FindBuff(tWanJia[i], "石牢：") then
          table.insert(tUnSafePlayer, tWanJia[i])
        end
      end
      local tFirstAttack = {}
      for i = 1, #tShiDui do
        for j = 1, #tUnSafePlayer do
          if GetDist(tShiDui[i].x, tShiDui[i].y, tUnSafePlayer[j].x, tUnSafePlayer[j].y) < 2 then
            table.insert(tFirstAttack, tShiDui[i])
            break
          end
        end
      end
      local tFirstAttack_15 = ObjFilterByDst(tFirstAttack, 15, 2)
      local tShiDui_15 = ObjFilterByDst(tShiDui, 15, 2)
      BubbleByHP(tFirstAttack_15)
      BubbleByHP(tShiDui_15)
      local myPos = Player:GetPos()
      if g_self.isjingong then
        if #tFirstAttack > 0 then
          BubbleByDst(tFirstAttack)
          if tFirstAttack[1].dst < 3 then
            tar = tFirstAttack[1]
          end
        end
        if nil == tar then
          if #tFirstAttack_15 > 0 then
            JinGongFarSkill(tFirstAttack_15[1].id)
          end
          BubbleByDst(tShiDui)
          tar = tShiDui[1]
        end
      elseif #tFirstAttack_15 > 0 then
        tar = tFirstAttack[1]
      elseif #tFirstAttack > 0 then
        BubbleByDst(tFirstAttack)
        tar = tFirstAttack[1]
        local run = GetRunposOfRange(myPos, tar, 14)
        RunTo(run.x, run.y, 0, 1000)
      elseif #tShiDui_15 > 0 then
        tar = tShiDui_15[1]
      else
        BubbleByDst(tShiDui)
        tar = tShiDui[1]
        if tar.dst > 15 then
          local run = GetRunposOfRange(myPos, tar, 14)
          RunTo(run.x, run.y, 0, 1000)
        end
      end
    end
  end
  return bHave, tar
end

local function BSQZ_boss4_special(atSpec)
  local bHave = false
  local bSafe = true
  local bSelf = false
  local npc = m_data.boss[4]
  local tSpec = {}
  for i = 1, #atSpec do
    table.insert(tSpec, atSpec[i])
  end
  local tWanJia = Enum2XByClass("玩家", {0, -1})
  for i = 1, #tWanJia do
    if Target:FindBuff(tWanJia[i], "失明：") then
      if tWanJia[i].name == g_self.name then
        bSelf = true
      else
        table.insert(tSpec, tWanJia[i])
      end
    end
  end
  if #tSpec > 0 then
    bHave = true
    if not bSelf then
      bSafe = FubenTrapRun("", npc.x, npc.y, 7, 15, tSpec, nil, FubenRunSafe, nil, nil, nil)
    else
      bSafe = false
    end
  end
  return bHave, bSafe
end

local function BSQZ_boss4_action_callback()
  if IsInDebugMsgTime("#{BSQZ_210714_27", nil, 5) then
    return false
  end
  return true
end

local function BSQZ_Boss4(szClass, nType)
  local npc = m_data.boss[4]
  DebugStr(m_data.sceneName .. "：" .. npc.name .. " " .. szClass .. nType)
  local pos = Player:GetPos()
  if pos.x > 114 or pos.y < 170 then
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua(nil, true, true)
    MoveToNPC("陈勇义", 145, 177, -1, 3, nil, nil, BSQZ_callback_run_boss4)
    pos = Player:GetPos()
    if pos.x > 114 or pos.y < 170 then
      Sleep(500)
      Pet:Relax()
      Dismount()
      Sleep(500)
      QuestFrameOptionClicked_Item("#{BSQZ_101223_49}", 1, 5000)
    end
    return
  end
  if pos.x > 82 then
    DebugStr(npc.name .. ":移动到战斗区域", 2)
    RunTo(82, 200, 0, 500)
    return
  end
  if false == BSQZ_IsBossStart(npc) then
    RunTo(82, 200, 0, 500)
    MPCheck100(m_param.mp_check_ever)
    if false == BSQZ_IsAllInStepPos(npc.step) and false == BSQZ_IsWaitRaidTickOut(npc) then
      FubenAttack(-1)
      return
    end
    CheckAllRaidHP(85, BSQZ_callback_hp, 45)
    BSQZ_em_xsx(npc)
  end
  local bFirstRun = false
  local tLast = {
    x = npc.x,
    y = npc.y
  }
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.call.back1 = BSQZ_boss4_action_callback
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = " "
    local bHave_SD = false
    local bHave_GS, bSafe_GS = false, true
    local bHave_FSZS, bSafe_FSZS = false, true
    local tBoss1, tYuanShen, tTieGu, tGunShi, tShiDui, tTunTianShi, tXianJin = BSQZ_boss4_EnumObj()
    local tar = tBoss1
    if tBoss1 then
      tLast.x = tBoss1.x
      tLast.y = tBoss1.y
      if 0 == tBoss1.hp then
        m_finish.boss4 = true
        break
      end
    elseif 0 == #tYuanShen and 0 == #tTieGu and 0 == #tGunShi and 0 == #tShiDui and 0 == #tTunTianShi then
      FubenAttack(-1)
      RunTo(npc.x, npc.y, 0, 500)
      PickUpLua(nil, true, true)
      BSQZ_RefreshStep()
      if m_finish.boss4 or BSQZ_GetPosStep() ~= npc.step then
        break
      end
      debugnote = " 没有找到boss"
    end
    local bJinJi = false
    local bUsePet = true
    if #tTunTianShi > 0 then
      bJinJi = true
      bUsePet = false
    else
      local tar_SD
      bHave_SD, tar_SD = BSQZ_boss4_shidui(tShiDui)
      if tar_SD then
        tar = tar_SD
      end
      if not bHave_SD then
        local bHave_tgys = BSQZ_boss4_tgys(tYuanShen, tTieGu)
        if not bHave_tgys then
          bHave_GS, bSafe_GS = BSQZ_boss4_gunshi(tGunShi)
          if not bHave_GS then
            bHave_FSZS, bSafe_FSZS = BSQZ_boss4_special(tXianJin)
          end
        end
      else
        bUsePet = false
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
      end
    end
    if not bSafe_GS or not bSafe_FSZS then
      debugnote = debugnote .. " 躲避陷阱"
      tar = nil
    end
    if tar then
      local tid = tar.id
      if not bHave_SD and not bHave_tgys and not bHave_GS and not bHave_FSZS and false == bFirstRun then
        debugnote = debugnote .. " 起始走位中"
        tid = -1
        if BSQZ_start_pos(npc) then
          bFirstRun = true
        end
      end
      if -1 ~= tid then
        if g_self.isjingong then
          if tar.dst > 3 then
            if bHave_GS and #tGunShi > 0 and tGunShi[1].x < 65 then
              tid = -1
            end
            if bHave_FSZS then
              tid = -1
            end
          end
        elseif tar.dst > 15 and not bHave_FSZS and (not bHave_GS or #tGunShi > 0 and tGunShi[1].x > 65) then
          local myPos = Player:GetPos()
          local run = GetRunposOfRange(myPos, tar, 14)
          RunTo(run.x, run.y, 0, 1000)
        end
        FubenAttack(tar.id, nil, bJinJi, true, bUsePet)
        Sleep(50)
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
      end
    end
    Sleep(50)
    DebugStr("Boss4:耶律连城" .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  CDG.call.back1 = nil
  BSQZ_RefreshStep()
  local tpos = {}
  table.insert(tpos, {
    x = npc.x,
    y = npc.y
  })
  if tLast.x then
    table.insert(tpos, {
      x = tLast.x,
      y = tLast.y
    })
  end
  BSQZ_boss_finish(m_finish.boss4, npc, tpos)
end

local function BSQZ_ExitScene()
  DebugStr(m_data.sceneName .. "：已完成")
  PickUpLua(nil, true, true)
  RelivePlayer(1, nil, nil, nil, nil, true)
  SDQY_HuoDong()
end

local function BSQZ_OnProcess(szClass, nType)
  BSQZ_RefreshStep()
  if m_finish.boss4 then
    BSQZ_ExitScene()
    return
  end
  local tObj = Enum2XByClass("怪物 NPC")
  local tAll = ObjFilterByHP(tObj, 0, 1)
  for i = 1, #tAll do
    local tmp = tAll[i]
    if tmp.name == "萧逸风" then
      BSQZ_SetFinishState(false, false, false, false)
      BSQZ_Boss1_XYF(tmp.class, 1)
      return
    elseif tmp.name == "萧如筠" or tmp.name == "萧如蔚" then
      BSQZ_SetFinishState(true, false, false, false)
      BSQZ_Boss2(tmp.class, 1)
      return
    elseif tmp.name == "耶律焱" or tmp.name == "地府牛妖" then
      BSQZ_SetFinishState(true, true, false, false)
      BSQZ_Boss3(tmp.class, 1)
      return
    elseif tmp.name == "耶律连城" or tmp.name == "石堆" or tmp.name == "铁骨符阵" or tmp.name == "元神符阵" or tmp.name == "吞天石" then
      BSQZ_SetFinishState(true, true, true, false)
      BSQZ_Boss4(tmp.class, 1)
      return
    end
  end
  if m_finish.boss3 then
    BSQZ_Boss4("NPC", 2)
    return
  elseif m_finish.boss2 then
    BSQZ_Boss3("NPC", 2)
    return
  elseif m_finish.boss1 then
    BSQZ_Boss2("NPC", 2)
    return
  end
  DebugStr("兵圣奇阵：开始")
  BSQZ_Boss1_XYF("NPC", 2)
end

local function BSQZ_OnDie()
  DieRelive(0)
  local tObj = Enum2XByName(" 萧逸风 萧如筠 萧如蔚 耶律焱 耶律连城 ", {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 and 100 == tObj[1].hp then
    PushColorMsg("可能已经灭团，自动出窍！" .. tObj[1].name)
    DieRelive(-1)
  else
    local myStep = BSQZ_GetPosStep()
    if BSQZ_IsStepOver(myStep) or #tObj > 0 and 0 == tObj[1].hp then
      local tEM = Raid:GetLifeMenPai("峨嵋")
      local bHaveEM = false
      for i = 1, #tEM do
        if BSQZ_GetPosStep(tEM[i]) == myStep then
          bHaveEM = true
          break
        end
      end
      if false == bHaveEM then
        PushColorMsg("附近没有峨嵋,自动出窍！")
        DieRelive(-1)
      end
    end
  end
  return false
end

local function BSQZ_Start()
  while GetSceneID() == m_data.sceneID do
    BSQZ_OnProcess()
    FuBenCheckDie(m_param.swcq, true, BSQZ_OnDie)
    PickUpLua(nil, true, true)
    Sleep(50)
    DebugStr(m_data.sceneName .. "：副本中", 3)
  end
end

local function BSQZ_asjust_member()
  if not m_param.adjustMember then
    return true
  end
  local team_or_raid, bleader, nCount = GetLuaValue("return meGetTeamRaidBaseInfo()", "nbn")
  if bleader and 2 == team_or_raid then
  else
    return false
  end
  local tAllMemb = Raid:GetAllMemberInfo()
  local tRaid = {}
  for i = 1, 6 do
    tRaid[i] = {}
  end
  for i = 1, #tAllMemb do
    local group = tAllMemb[i].groupIndex + 1
    if nil == tRaid[group] then
      tRaid[group] = {}
    end
    table.insert(tRaid[group], tAllMemb[i])
  end
  if (6 ~= #tRaid[1] or 6 ~= #tRaid[2]) and (tRaid[3] and #tRaid[3] > 0 or tRaid[4] and #tRaid[4] > 0 or tRaid[5] and #tRaid[5] > 0) then
    local dest = {groupIndex = -1, teamIndex = -1}
    local source = {groupIndex = -1, teamIndex = -1}
    if 6 ~= #tRaid[1] then
      dest = {groupIndex = 0, teamIndex = 5}
    elseif 6 ~= #tRaid[2] then
      dest = {groupIndex = 1, teamIndex = 5}
    end
    if tRaid[3] and #tRaid[3] > 0 then
      source = {groupIndex = 2, teamIndex = 0}
    elseif tRaid[4] and #tRaid[4] > 0 then
      source = {groupIndex = 3, teamIndex = 0}
    elseif tRaid[5] and #tRaid[5] > 0 then
      source = {groupIndex = 4, teamIndex = 0}
    end
    Raid:ExchangeMember(source, dest)
    Sleep(1000)
    DebugStr("调整团队:调节其它分队团员到1、2分队", 3)
    return false
  end
  local em_1 = GetTableFieldValue(tRaid[1], "menpai", {4})
  local em_2 = GetTableFieldValue(tRaid[2], "menpai", {4})
  local diff = math.abs(#em_1 - #em_2)
  if diff >= 2 then
    local dest = {groupIndex = -1, teamIndex = -1}
    local source = {groupIndex = -1, teamIndex = -1}
    if #em_1 > #em_2 then
      source = em_1[1]
      if 6 == #tRaid[2] then
        local other_2 = DeleteTableFieldValue(tRaid[2], "menpai", {4})
        if #other_2 > 0 then
          dest = other_2[1]
        end
      else
        dest = {groupIndex = 1, teamIndex = 5}
      end
    elseif #em_2 > #em_1 then
      source = em_2[1]
      if 6 == #tRaid[1] then
        local other_1 = DeleteTableFieldValue(tRaid[1], "menpai", {4})
        if #other_1 > 0 then
          dest = other_1[1]
        end
      else
        dest = {groupIndex = 0, teamIndex = 5}
      end
    end
    Raid:ExchangeMember(source, dest)
    Sleep(1000)
    DebugStr("调整团队:调节峨嵋.", 3)
    return false
  end
  local t_one_del = GetTableFieldValue(tRaid[1], "menpai", {
    1,
    2,
    5,
    8
  })
  local t_two_del = GetTableFieldValue(tRaid[2], "menpai", {
    0,
    3,
    7,
    10
  })
  if #t_one_del > 0 and #t_two_del > 0 then
    Raid:ExchangeMember(t_one_del[1], t_two_del[1])
    Sleep(1000)
    DebugStr("调整团队:1", 3)
    return false
  elseif #t_one_del > 0 then
    if #tRaid[2] < 6 then
      Raid:ExchangeMember(t_one_del[1], {groupIndex = 1, teamIndex = 5})
      Sleep(1000)
      DebugStr("调整团队:2", 3)
      return false
    else
      local t_del = GetTableFieldValue(tRaid[2], "menpai", {13, 6})
      if #t_del > 0 then
        Raid:ExchangeMember(t_one_del[1], t_del[1])
        Sleep(1000)
        DebugStr("调整团队:3", 3)
        return false
      elseif #em_2 > #em_1 then
        Raid:ExchangeMember(t_one_del[1], em_2[1])
        Sleep(1000)
        DebugStr("调整团队:4", 3)
        return false
      end
    end
  elseif #t_two_del > 0 then
    if #tRaid[1] < 6 then
      Raid:ExchangeMember(t_two_del[1], {groupIndex = 0, teamIndex = 5})
      Sleep(1000)
      DebugStr("调整团队:5", 3)
      return false
    else
      local t_del = GetTableFieldValue(tRaid[1], "menpai", {11, 12})
      if #t_del > 0 then
        Raid:ExchangeMember(t_two_del[1], t_del[1])
        Sleep(1000)
        DebugStr("调整团队:6", 3)
        return false
      elseif #em_1 > #em_2 then
        Raid:ExchangeMember(t_two_del[1], em_1[1])
        Sleep(1000)
        DebugStr("调整团队:7", 3)
        return false
      end
    end
  end
  t_one_del = GetTableFieldValue(tRaid[1], "menpai", {11, 12})
  t_two_del = GetTableFieldValue(tRaid[2], "menpai", {13, 6})
  if #t_one_del > 0 and #t_two_del > 0 then
    Raid:ExchangeMember(t_one_del[1], t_two_del[1])
    Sleep(1000)
    DebugStr("调整团队:8", 3)
    return false
  elseif #t_one_del > 0 then
    if #tRaid[2] < 6 then
      Raid:ExchangeMember(t_one_del[1], {groupIndex = 1, teamIndex = 5})
      Sleep(1000)
      DebugStr("调整团队:9", 3)
      return false
    elseif #em_2 > #em_1 then
      Raid:ExchangeMember(t_one_del[1], em_2[1])
      Sleep(1000)
      DebugStr("调整团队:10", 3)
      return false
    end
  elseif #t_two_del > 0 then
    if #tRaid[1] < 6 then
      Raid:ExchangeMember(t_two_del[1], {groupIndex = 0, teamIndex = 5})
      Sleep(1000)
      DebugStr("调整团队:11", 3)
      return false
    elseif #em_1 > #em_2 then
      Raid:ExchangeMember(t_two_del[1], em_1[1])
      Sleep(1000)
      DebugStr("调整团队:12", 3)
      return false
    end
  end
  local t_em_all = em_1
  for i = 1, #em_2 do
    table.insert(t_em_all, em_2[i])
  end
  local em_num = #t_em_all
  if em_num > 2 and #em_1 > 0 and #em_2 > 0 then
    BubbleSort(t_em_all, "hpmax", 2)
    if t_em_all[em_num].hpmax > 100 then
      if 3 == em_num then
        if t_em_all[1].groupIndex == t_em_all[2].groupIndex then
          Raid:ExchangeMember(t_em_all[1], t_em_all[3])
          Sleep(1000)
          DebugStr("调整团队:13", 3)
          return false
        elseif t_em_all[1].groupIndex == t_em_all[3].groupIndex then
          Raid:ExchangeMember(t_em_all[1], t_em_all[2])
          Sleep(1000)
          DebugStr("调整团队:14", 3)
          return false
        end
      elseif em_num > 3 and t_em_all[1].groupIndex ~= t_em_all[em_num].groupIndex then
        for i = 2, em_num - 1 do
          if t_em_all[i].groupIndex == t_em_all[1].groupIndex then
            Raid:ExchangeMember(t_em_all[i], t_em_all[em_num])
            Sleep(1000)
            DebugStr("调整团队:15", 3)
            return false
          end
        end
      end
    else
      DebugStr("调整团员：等待峨嵋集合", 3)
      return false
    end
  end
  return true
end

local function BSQZ_raid_member()
  local bOK = false
  local debugnote = ""
  local team_or_raid, bleader, nCount = GetLuaValue("return meGetTeamRaidBaseInfo()", "nbn")
  if bleader and 1 == team_or_raid and nCount >= 2 then
    GetLuaValue("Player:CreateRaidSelf()")
    Sleep(3000)
  end
  local teamCount = m_teamCount
  if teamCount < 7 or teamCount > 12 then
    teamCount = 12
  end
  if bleader and 2 == team_or_raid and nCount >= teamCount then
    local tEM = Raid:GetLifeMenPai("峨嵋")
    if #tEM >= 2 then
      if nCount > 12 then
        debugnote = " 团队人数过多."
      else
        bOK = true
      end
    else
      debugnote = " 峨嵋门派不足2个."
    end
  elseif bleader then
    debugnote = " 等待组团."
  end
  return bOK, debugnote
end

function _SMain(...)
  local szMode = "[简单模式]"
  if m_param.knMode then
    szMode = "[困难模式]"
  end
  if 1 == g_client_type then
    local _, _, _, nHave = IsHuodongComplete("兵圣奇阵", 1, true)
    if 0 == nHave then
      PushColorMsg("今天没有" .. m_script_name)
      return
    end
  end
  local bOver = false
  while true do
    local debugnote = ""
    if GetSceneID() == m_data.sceneID then
      BSQZ_Start()
      bOver = true
    else
      CloseWindow("Quest")
      if GetSceneID() ~= m_data.sceneID and IsHuodongComplete("兵圣奇阵", 1) then
        Sleep(3000)
        if GetSceneID() ~= m_data.sceneID and IsHuodongComplete("兵圣奇阵", 1) then
          PushDebugMessage("兵圣奇阵：今日已完成！")
          break
        end
      end
      if bOver then
        Sleep(3000)
        if GetSceneID() ~= m_data.sceneID then
          PushColorMsg("兵圣奇阵：已完成.")
          break
        end
      end
      GoToSceneNPC("高阳", 306, 255, LUOYANG_ID)
      ChangeSceneLine()
      Sleep(800)
      FubenAttack(-1)
      local bOK_member, szMsg = BSQZ_raid_member()
      debugnote = szMsg
      local bOK_adjust = BSQZ_asjust_member()
      if bOK_member and bOK_adjust then
        if m_param.autoFuben then
          PushDebugMessage("进入副本")
          if m_param.knMode then
            QuestFrameOptionClicked_Item("#{BSQZ_101223_07}", 1, 800)
          else
            QuestFrameOptionClicked_Item("#{BSQZ_101223_06}", 1, 800)
          end
        else
          debugnote = " 团队准备完成,未设置自动进入副本"
        end
      end
    end
    Sleep(100)
    DebugStr(m_data.sceneName .. "：等待进入副本" .. debugnote .. " " .. szMode, 2)
  end
end

_SMain()
ScriptOnStop(m_script_name, true)
m_param = nil
m_data = nil
m_finish = nil
m_wait = nil

local function BSQZ_raidhp_protect(bMust, hpCmp)
  local bSafe = true
  local nCheckHP = hpCmp or m_param.boss1_boss2_teamhp_cmp
  if bMust or m_param.boss1_boss2_teamhp_protect then
    local tObj = Enum2XByClass("玩家")
    local tLife = ObjFilterByHP(tObj, 0, 1)
    tLife = ObjFilterByDst(tLife, 25, 2)
    local tDie = ObjFilterByHP(tObj, 0, 2)
    tDie = ObjFilterByDst(tDie, 25, 2)
    if #tLife > 1 then
      BubbleByHP(tLife, 1)
      if nCheckHP >= tLife[1].hp or #tDie > 0 then
        for i = 1, #tLife do
          if 5 == tLife[i].menpai then
            bSafe = false
          end
        end
      end
    end
  end
  return bSafe
end

local function BSQZ_em_checkdie(boss)
  if 4 ~= g_self.menpai then
    return
  end
  local tObj = Enum2XByClass("玩家")
  local tLife = ObjFilterByHP(tObj, 0, 1)
  local tDie = ObjFilterByHP(tObj, 0, 2)
  if 1 == boss.step or 3 == boss.step then
    if 1 == boss.step then
      local tXF = Enum2XByName("旋风", {
        0,
        1,
        0,
        0
      }, {0, -1}, 3, 0)
      if #tXF > 0 then
        return
      end
    end
    if #tLife > 1 and #tDie > 0 then
      BubbleByHP(tLife, 1)
      if tLife[1].hp > 80 then
        local tEM = Raid:GetLifeMenPai("峨嵋")
        for i = 1, #tEM do
          if BSQZ_GetPosStep(tEM[i]) == boss.step and GetDist(boss.x, boss.y, tEM[i].x, tEM[i].y) < 25 then
            if tEM[i].name == g_self.name then
              RelivePlayer(1, nil, nil, nil, nil, false)
            end
            break
          end
        end
      end
    end
  end
  if 2 == boss.step then
    tLife = ObjFilterByDst(tLife, 25, 2)
    tDie = ObjFilterByDst(tDie, 25, 2)
    local tEM = {}
    for i = 1, #tLife do
      if 5 == tLife[i].menpai then
        table.insert(tEM, tLife[i])
      end
    end
    if #tLife > 1 and #tDie > 0 then
      BubbleByHP(tLife, 1)
      if tLife[1].hp > 80 then
        local bHave_lymz = false
        for i = 1, #tLife do
          if Target:FindBuff(tLife[i], "林野迷踪：") or Target:FindBuff(tLife[i], "林野迷踪-定身") then
            bHave_lymz = true
            break
          end
        end
        if false == bHave_lymz then
          local tAllEM = Raid:GetLifeMenPai("峨嵋")
          for j = 1, #tAllEM do
            for i = 1, #tEM do
              local nStep, nBossIndex = BSQZ_GetPosStep(tEM[i])
              if nStep == boss.step and tAllEM[j].name == tEM[i].name then
                if tEM[i].name == g_self.name then
                  RelivePlayer(1, nil, nil, nil, nil, false)
                end
                break
              end
            end
          end
        end
      end
    end
  end
end
