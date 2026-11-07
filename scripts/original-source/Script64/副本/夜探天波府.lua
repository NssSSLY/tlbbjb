-- 反编译自 dfz64.dll 内嵌字节码 002e1e29（unluac 2025-12-23；仅供分析）
local m_script_name = "夜探天波府"
ScriptOnStart(m_script_name, true, true)
CDG.hp.em_pet = false
CDG.hp.em_raid = true
g_pick.check = true
g_pick.pickmode = 0
local m_param = {}
m_param.knMode = ReadConfigBool("ZH", "xzk118")
m_param.teamCount = HandleTextToNumber(GetConfigText("组队人数", "天波府"), 12)
if m_param.teamCount < 7 or m_param.teamCount > 12 then
  m_param.teamCount = 12
end
local m_data = {}
m_data.sceneName = "天波府"
m_data.sceneID = 848
m_data.npc = {
  x = 306,
  y = 245,
  sceneID = LUOYANG_ID,
  name = "穆小妹"
}
m_data.boss = {
  {
    step = 1,
    x = 229,
    y = 250,
    name = "云中鹤",
    stepobj = " 云中鹤 "
  },
  {
    step = 2,
    x = 250,
    y = 158,
    name = "岳老三",
    stepobj = " 岳老三 "
  },
  {
    step = 3,
    x = 130,
    y = 150,
    name = "叶二娘",
    stepobj = " 叶二娘 傀影 "
  },
  {
    step = 4,
    x = 110,
    y = 41,
    name = "段延庆",
    stepobj = " 段延庆 心魔·延庆太子 "
  }
}
m_data.allNPC = " 云中鹤 岳老三 叶二娘 傀影 段延庆 "
m_data.allName = " 云中鹤 岳老三 叶二娘 傀影 段延庆 心魔·延庆太子 "
local m_finish = {
  boss1 = false,
  boss2 = false,
  boss3 = false,
  boss4 = false
}

local function TBF_SetFinishState(boss1, boss2, boss3, boss4)
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

local function TBF_RefreshStep()
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("#{YTTBF_220524_187}")
  local nMsgTime2 = IsInDebugMsg("#{YTTBF_220524_189}")
  local nMsgTime3 = IsInDebugMsg("#{YTTBF_220524_192}")
  local nMsgTime4 = IsInDebugMsg("#{YTTBF_220524_199}")
  if nMsgTime1 and nTransTime < nMsgTime1 then
    TBF_SetFinishState(true, nil, nil, nil)
  end
  if nMsgTime2 and nTransTime < nMsgTime2 then
    TBF_SetFinishState(true, true, nil, nil)
  end
  if nMsgTime3 and nTransTime < nMsgTime3 then
    PushColorMsg("叶二娘在说话，此boss结束")
    TBF_SetFinishState(true, true, true, nil)
  end
  if nMsgTime4 and nTransTime < nMsgTime4 then
    TBF_SetFinishState(true, true, true, true)
  end
end

local function TBF_boss_finish(bFinish, boss, posPick)
  local pos = posPick or {
    {
      x = boss.x,
      y = boss.y
    }
  }
  if bFinish then
    PushDebugMessage(m_data.sceneName .. ":" .. boss.name .. " 已完成！")
    PushColorMsg("在捡包")
    PickUpLua(nil, true, true)
    RelivePlayer(1, nil, nil, nil, nil, false)
    PickUpLua(nil, true, true)
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua_Boss(60, 15, nil, pos, true, nil)
    RelivePlayer(1, nil, nil, nil, nil, true)
  end
  PickUpMust()
end

local function TBF_GetPosStep(aPos)
  local pos = aPos or Player:GetPos()
  if pos.x > 200 and pos.x < 260 and pos.y > 220 and pos.y < 282 then
    return 1, -1
  end
  if pos.x < 156 and pos.y > 125 and pos.y < 185 then
    return 3, -1
  end
  if pos.x > 300 then
    return 4, 2
  end
  if pos.y < 80 then
    return 4, 1
  end
  return -1, -1
end

local function TBF_IsInStepPos(aStep, aPos)
  local bIs = false
  if 2 == aStep then
    local npc = m_data.boss[2]
    if GetDist(npc.x, npc.y) > 25 then
      return false
    end
    return true
  end
  if TBF_GetPosStep(aPos, aStep) == aStep then
    bIs = true
  end
  return true
end

local function TBF_cb_run(fX, fY, nScene)
  DebugStr(m_data.sceneName .. ":正在移动到 %d,%d ", 2, math.floor(fX), math.floor(fY))
  PickUpLua(nil, true, true)
  if FubenCheckSceneDie(m_data.sceneID) == false then
    return false
  end
  return true
end

local function TBF_cb_run_123(fX, fY, nScene)
  local _selfPos = Player:GetPos()
  if _selfPos.y < 80 or _selfPos.x > 300 then
    return false
  end
  return TBF_cb_run(fX, fY, nScene)
end

local function TBF_cb_raidhp()
  local tObj = Enum2XByName(m_data.allNPC, {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    return false
  end
  local tObj = Enum2XByName("段延庆", {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 then
    local tmp = tObj[1]
    if tmp.dst > 10 then
      RunTo(tmp.x, tmp.y, 5, 1000)
    end
  end
  return true
end

local function TBF_cb_ondie()
  TBF_RefreshStep()
  DieRelive(0)
  local tObj = Enum2XByName(m_data.allNPC, {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    PushColorMsg("可能已经灭团，自动出窍！" .. tObj[1].name)
    DieRelive(-1)
  else
    local tObj = Enum2XByName("心魔·延庆太子", {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      if 0 == tmp.hp then
        m_finish.boss4 = true
        PushColorMsg("延庆太子已完成")
        DieRelive(-1)
      end
    elseif m_finish.boss4 then
      DieRelive(-1)
      PushColorMsg("延庆太子已完成!")
    end
    local myPos = Player:GetPos()
    if myPos.x < 300 or m_finish.boss4 then
      local tEM = Raid:GetLifeMenPai("峨嵋")
      local bHaveEM = false
      local myPos = Player:GetPos()
      for i = 1, #tEM do
        if GetDist(tEM[i].x, tEM[i].y, myPos.x, myPos.y) < 40 then
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

local function TBF_start_pos(aBoss)
  local bOK = true
  local r = 7
  local nPosCount = 12
  local rIndex = Raid_GetIndex()
  if 1 == aBoss.step then
    r = 7
    nPosCount = 12
  elseif 2 == aBoss.step or 3 == aBoss.step or 4 == aBoss.step then
    r = 7
    nPosCount = 12
  elseif 5 == aBoss.step then
    r = 5
    nPosCount = 12
  end
  while nPosCount < rIndex + 1 do
    rIndex = rIndex - nPosCount
  end
  local tpos = GetAveragePoint(aBoss.x, aBoss.y, r, nPosCount, 0)
  local run = tpos[rIndex + 1]
  if not run then
    return bOK
  end
  bOK = not RunTo(run.x, run.y, 1, 1500)
  return bOK
end

local function TBF_OpenBoss(aBoss, aObj)
  if aObj.name == "段延庆" and aObj.dst > 10 then
    local npc = aBoss
    
    local function _cb(...)
      local _selfPos = Player:GetPos()
      if _selfPos.y >= 80 then
        return false
      end
      return TBF_cb_run(...)
    end
    
    MoveTo(npc.x, npc.y, -1, 12, nil, nil, _cb)
  end
  local leader, isleader = Raid:GetLeaderInfo()
  if isleader then
    RunTo(aObj.x, aObj.y, 3, 1000)
    CheckAllRaidHP(85, TBF_cb_raidhp, 45)
    RunTo(aObj.x, aObj.y, 3, 1000)
    PlayerStateTimeOut(2, 5)
    TalkNpc(aObj.name, 800)
    QuestFrameOptionClicked_Item("#{YTTBF_220524_57}", 1, 1000)
    QuestFrameOptionClicked_Item("#{YTTBF_220524_85}", 1, 1000)
    QuestFrameOptionClicked_Item("#{YTTBF_220524_84}", 1, 1000)
    QuestFrameOptionClicked_Item("#{YTTBF_220524_103}", 1, 1000)
  else
    TBF_start_pos(aBoss)
    FubenAttack(-1)
  end
end

local function TBF_CheckObj(aNpc)
  local bStepOk = true
  local tBoss
  local tObj = Enum2XByClass("NPC 怪物 陷阱")
  if #tObj > 0 then
    for i = 1, 4 do
      if i ~= aNpc.step then
        local tmp = m_data.boss[i]
        for j = 1, #tObj do
          if tObj[j].name ~= "" and string.find(tmp.stepobj, tObj[j].name, nil, true) then
            LogMsg(aNpc.step .. ":与阶段不匹配的目标：" .. tObj[j].name)
            bStepOk = false
            break
          end
        end
        if false == bStepOk then
          break
        end
      end
    end
    for i = 1, #tObj do
      if tObj[i].name == aNpc.name then
        tBoss = tObj[i]
        break
      end
    end
  end
  return bStepOk, tObj, tBoss
end

local function TBF_boss1_lx(atHZLX, aBoss, aNpc)
  if #atHZLX > 0 and aBoss and -1 ~= Player:GetBuff("连线：") then
    local tLXPlayer = {}
    local tPlayer = Enum2XByClass("玩家")
    for i = 1, #tPlayer do
      local tStr = EnumObjBuff(tPlayer[i])
      for j = 1, #tStr do
        if string.find(tStr[j], "连线：", nil, true) then
          table.insert(tLXPlayer, tPlayer[i])
          break
        end
      end
    end
    local tAllRaid = Raid:GetAllMemberInfo()
    for i = 1, #tLXPlayer do
      local tlxp = tLXPlayer[i]
      tlxp.raidIndex = Raid_GetIndex(tlxp.name, tAllRaid) + 1
    end
    local tAngle = {
      {
        min = 0,
        max = 120,
        hzly = {}
      },
      {
        min = 120,
        max = 240,
        hzly = {}
      },
      {
        min = 240,
        max = 360,
        hzly = {}
      }
    }
    for i = 1, #atHZLX do
      local tmp = atHZLX[i]
      atHZLX[i].angle = GetAngle(aBoss.x, aBoss.y, tmp.x, tmp.y)
      if atHZLX[i].angle >= 0 and atHZLX[i].angle < 120 then
        table.insert(tAngle[1].hzly, atHZLX[i])
      elseif atHZLX[i].angle >= 120 and atHZLX[i].angle < 240 then
        table.insert(tAngle[2].hzly, atHZLX[i])
      elseif atHZLX[i].angle >= 240 and atHZLX[i].angle < 360 then
        table.insert(tAngle[3].hzly, atHZLX[i])
      end
    end
    BubbleSort(tLXPlayer, "raidIndex")
    local myAngle
    for i = 1, #tLXPlayer do
      if tLXPlayer[i].name == g_self.name then
        if 1 == i or 2 == i or 3 == i then
          myAngle = tAngle[i]
        end
        break
      end
    end
    if nil == myAngle then
      myAngle = tAngle[3]
      local selfPos = Player:GetPos()
      local nAngle = GetAngle(aBoss.x, aBoss.y, selfPos.x, selfPos.y)
      for i = 1, #tAngle do
        if nAngle >= tAngle[i].min and nAngle < tAngle[i].max then
          myAngle = tAngle[i]
          break
        end
      end
    end
    if 0 == #myAngle.hzly then
      for i = 1, #tAngle do
        if #tAngle[i].hzly > 0 and (0 == #myAngle.hzly or #myAngle.hzly < #tAngle[i].hzly) then
          myAngle = tAngle[i]
        end
      end
    end
    local posSafe = {}
    local aTrapRadius = 6
    local allPos = GetRangeAllPos(aNpc.x, aNpc.y, 1, 18, nil)
    for i = 1, #allPos do
      if IsPosSafe(allPos[i], atHZLX, aTrapRadius) then
        allPos[i].angle = GetAngle(aBoss.x, aBoss.y, allPos[i].x, allPos[i].y)
        table.insert(posSafe, allPos[i])
      end
    end
    local myAnglePos = {}
    for i = 1, #posSafe do
      local tmp = posSafe[i]
      if tmp.angle >= myAngle.min and tmp.angle < myAngle.max then
        table.insert(myAnglePos, posSafe[i])
      end
    end
    local runPos = {}
    local nDiff = 3
    for k = 1, 10 do
      for i = 1, #myAngle.hzly do
        local thzly = myAngle.hzly[i]
        for j = 1, #myAnglePos do
          if nDiff >= math.abs(myAnglePos[j].angle - thzly.angle) then
            table.insert(runPos, myAnglePos[j])
          end
        end
      end
      if #runPos > 0 then
        break
      end
      nDiff = nDiff * k
    end
    if #runPos > 0 then
      local tTongJi = {}
      local selfPos = Player:GetPos()
      for i = 1, #runPos do
        local tmp = runPos[i]
        local field = tmp.x .. tmp.y
        local tFind = GetTableFieldValue(tTongJi, "name", {field})
        if 0 == #tFind then
          local nDist = GetDist(tmp.x, tmp.y, selfPos.x, selfPos.y)
          table.insert(tTongJi, {
            name = field,
            num = 1,
            x = tmp.x,
            y = tmp.y,
            dst = nDist
          })
        else
          for j = 1, #tTongJi do
            if tTongJi[j].name == field then
              tTongJi[j].num = tTongJi[j].num + 1
              break
            end
          end
        end
      end
      BubbleSort(tTongJi, "num", 2)
      if #tTongJi > 0 then
        local run = tTongJi[1]
        for i = 1, #tTongJi do
          if tTongJi[i].dst < 5 then
            run = tTongJi[i]
            break
          end
        end
        local bSafe = false
        if GetDist(run.x, run.y, selfPos.x, selfPos.y) < 1 then
          bSafe = true
        elseif Skill:UseShunYi(run.x, run.y) == false then
          local zero = aNpc
          zero.r = 20
          local bRun = AStarRun(zero, run, atHZLX, 4, nil, nil, 5)
        end
        return true, bSafe
      else
        PushColorMsg("连线：坐标错误")
      end
    else
      PushColorMsg("连线：未找到合适坐标")
    end
  end
  return false, false
end

local function TBF_boss1_lx_yj(atHZLY, atFYYJ, aBoss, aNpc)
  if not (#atFYYJ > 0) or aBoss then
  end
end

local function TBF_YunZhongHe()
  local npc = m_data.boss[1]
  local tLast = {
    x = npc.x,
    y = npc.y
  }
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    local bStepOk, tAll, tBoss = TBF_CheckObj(npc)
    if false == bStepOk then
      break
    end
    if 0 == #tAll then
      debugnote = " 没有发现目标"
      PickUpLua()
      RunTo(npc.x, npc.y, 0, 2000)
    elseif tBoss and tBoss.class == "NPC" then
      TBF_OpenBoss(npc, tBoss)
    else
      local bFindSpec = false
      local bFindSpec2 = false
      local isSafePos = true
      local isSafeRun = true
      local tHZLY = ObjFilterByName(tAll, "鹤之翎羽", 0)
      local tFYYJ = {}
      local tSYZH = ObjFilterByName(tAll, "白鹤之影（俯冲）", 0)
      if #tHZLY > 0 or #tFYYJ > 0 or #tSYZH > 0 then
        bFindSpec = true
      end
      if #tSYZH > 0 then
        bFindSpec2 = true
        local tSpecial = {}
        for i = 1, #tSYZH do
          table.insert(tSpecial, tSYZH[i])
        end
        for i = 1, #tHZLY do
          table.insert(tSpecial, tHZLY[i])
        end
        local nR = 6
        local bSafe, _, posSafe, nFindPos = FubenTrapRun("", npc.x, npc.y, 6, 20, tSpecial, nil, FubenRunSafe, nil, nil, nil)
        if 2 == nFindPos then
          bSafe, _, posSafe, nFindPos = FubenTrapRun("", npc.x, npc.y, 6, 20, tSYZH, nil, FubenRunSafe, nil, nil, nil)
        end
        isSafePos = bSafe
        if 4 == g_self.menpai and not bSafe then
          local hpp = Player:GetHPP()
          if hpp < 30 then
            Skill:UseName("呆若木鸡", 500)
          end
        end
      else
        local bLX, bSafe1 = TBF_boss1_lx(tHZLY, tBoss, npc)
        if false == bLX then
          if #tHZLY > 0 then
            for i = 7, 4, -1 do
              local bSafe2, _, posSafe, nFindPos = FubenTrapRun(npc.name, npc.x, npc.y, i, 20, tHZLY, nil, FubenRunSafe, nil, nil, nil)
              if 2 ~= nFindPos then
                isSafePos = bSafe2
                break
              end
            end
          end
        else
          isSafePos = bSafe1
          isSafeRun = false
        end
      end
      if tBoss then
        tLast.x = tBoss.x
        tLast.y = tBoss.y
        if 0 == tBoss.hp then
          PushColorMsg(npc.name .. ":已死亡")
          m_finish.boss1 = true
          break
        end
        if isSafePos then
          if #tSYZH > 0 then
            FubenAttack(-1)
          else
            local tid = tBoss.id
            if bFindSpec then
              if g_self.isjingong then
                if tBoss.dst > 3 then
                  if tBoss.dst > 15 or false == JinGongFarSkill(tid) then
                    if isSafeRun and 0 == #tFYYJ then
                      local zero = npc
                      zero.r = 20
                      local bRun = AStarRun(zero, tBoss, tHZLY, 4, nil, nil, 3)
                      if bRun then
                        tid = -1
                      else
                        DebugColorMsg(npc.name .. "：未找到安全寻路路径", 3)
                      end
                    else
                      tid = -1
                    end
                  else
                    tid = -1
                  end
                end
              elseif tBoss.dst > 15 then
                if isSafeRun and 0 == #tFYYJ then
                  local zero = npc
                  zero.r = 20
                  local bRun = AStarRun(zero, tBoss, tHZLY, 4, nil, nil, 3)
                  if bRun then
                    tid = -1
                  else
                    DebugColorMsg(npc.name .. "：未找到安全寻路路径", 3)
                    RunTo(tBoss.x, tBoss.y, 0, 500)
                  end
                else
                  tid = -1
                end
              end
            end
            FubenAttack(tid)
          end
        end
      elseif not bFindSpec then
        TBF_RefreshStep()
        if m_finish.boss1 then
          PushColorMsg(npc.name .. ":已完成")
          break
        else
          debugnote = " 未发现boss,前往中心点"
          Sleep(1000)
          local tObj = Enum2XByName(npc.name, {
            1,
            1,
            0,
            0
          }, nil, nil, 0)
          if 0 == #tObj then
            RunTo(npc.x, npc.y, 0, 1000)
          end
          FubenAttack(-1)
        end
        if false == TBF_IsInStepPos(npc.step) then
          PushColorMsg("当前坐标不是boss1区域！")
          break
        end
      elseif isSafePos then
        FubenAttack(-1)
        local zero = npc
        zero.r = 20
        local bRun = AStarRun(zero, zero, tHZLY, 4, nil, nil, 3)
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. "：" .. npc.name .. debugnote)
  end
  TBF_RefreshStep()
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
  TBF_boss_finish(m_finish.boss1, npc, tpos)
end

local function TBF_boss2_hczz(atHCZZ, aBoss)
  local npc = m_data.boss[2]
  local bOK = true
  if #atHCZZ > 0 then
    bOK = FubenTrapRun("", npc.x, npc.y, 5, 15, atHCZZ, nil, FubenRunSafe_easy, nil, nil, nil)
  end
  return bOK
end

local function TBF_boss2_nexs(atNexs, aNpc)
  local bOK = true
  local myPos = Player:GetPos()
  local zeroDist = GetDist(aNpc.x, aNpc.y, myPos.x, myPos.y)
  local myAngle = GetAngle(aNpc.x, aNpc.y, myPos.x, myPos.y)
  for i = 1, #atNexs do
    atNexs[i].angle = GetAngle(aNpc.x, aNpc.y, atNexs[i].x, atNexs[i].y)
    atNexs[i].angle_diff = math.abs(myAngle - atNexs[i].angle)
    if atNexs[i].angle_diff >= 315 then
      atNexs[i].angle_diff = 360 - atNexs[i].angle_diff
    end
  end
  if zeroDist < 9 then
    zeroDist = 9
  end
  BubbleSort(atNexs, "angle_diff")
  if #atNexs > 0 then
    local nAngleAdd1 = atNexs[1].angle + 22.5
    if nAngleAdd1 >= 360 then
      nAngleAdd1 = nAngleAdd1 - 360
    end
    local nAngleSub1 = atNexs[1].angle - 22.5
    if nAngleSub1 < 0 then
      nAngleSub1 = 360 + nAngleSub1
    end
    local runPos1 = GetAnglePos(aNpc, nAngleAdd1, zeroDist)
    local runPos2 = GetAnglePos(aNpc, nAngleSub1, zeroDist)
    local runPos = runPos1
    if runPos2.x and runPos1.x and GetDist(runPos2.x, runPos2.y, myPos.x, myPos.y) < GetDist(runPos1.x, runPos1.y, myPos.x, myPos.y) then
      runPos = runPos2
    end
    if GetDist(runPos.x, runPos.y) > 1 then
      PushColorMsg("怒鳄袭沙：移动到%s,%s", math.floor(runPos.x), math.floor(runPos.y))
    end
    local bRun = RunTo(runPos.x, runPos.y, 0, 1000)
    bOK = not bRun
  end
  return bOK
end

local function TBF_YueLaoSan()
  local npc = m_data.boss[2]
  local tLast = {
    x = npc.x,
    y = npc.y
  }
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    local bStepOk, tAll, tBoss = TBF_CheckObj(npc)
    if false == bStepOk then
      break
    end
    if 0 == #tAll then
      debugnote = " 没有发现目标"
      PickUpLua()
      RunTo(npc.x, npc.y, 0, 2000)
    elseif tBoss and tBoss.class == "NPC" then
      TBF_OpenBoss(npc, tBoss)
    else
      local bFindSpec = false
      local isSafePos = true
      local tHCZZ = ObjFilterByName(tAll, "横冲直撞预警圈", 0)
      local tNEXS = ObjFilterByName(tAll, "副本通用空npc", 0)
      local tCJJ = ObjFilterByName(tAll, "沉金锏", 0)
      local tFS = ObjFilterByName(tAll, " 岳老三分身预警 岳老三分身 ", 3)
      if #tFS > 0 or #tNEXS > 0 or #tHCZZ > 0 then
        bFindSpec = true
      end
      if IsInDebugMsgTime("#{YTTBF_220524_81}", nil, 5) then
        local tObj = Enum2XByClass("珍兽")
        for i = 1, #tObj do
          if 0 == tObj[i].level then
            table.insert(tFS, tObj[i])
          end
        end
      end
      if #tFS > 0 then
        debugnote = " 分身"
        for i = 10, 7, -1 do
          local bSafe, _, posSafe, nFindPos = FubenTrapRun("", npc.x, npc.y, i, 19, tFS, nil, FubenRunSafe, nil, nil, nil)
          if 2 ~= nFindPos then
            isSafePos = bSafe
            break
          end
        end
      else
        local tSpec = {}
        if #tNEXS > 0 then
          local tpos = tNEXS[1]
          tpos.angle = GetAngle(npc.x, npc.y, tpos.x, tpos.y)
          local nAngle = tpos.angle
          table.insert(tSpec, tpos)
          while nAngle >= 0 do
            nAngle = nAngle - 45
            if nAngle >= 0 then
              local newpos = GetAnglePos(npc, nAngle, tpos.dst)
              table.insert(tSpec, newpos)
            end
          end
          nAngle = tpos.angle
          while nAngle < 360 do
            nAngle = nAngle + 45
            if nAngle < 360 then
              local newpos = GetAnglePos(npc, nAngle, tpos.dst)
              table.insert(tSpec, newpos)
            end
          end
        end
        if #tSpec > 0 then
          debugnote = " 怒鳄袭沙"
          isSafePos = TBF_boss2_nexs(tSpec, npc)
        else
          isSafePos = TBF_boss2_hczz(tHCZZ, tBoss)
        end
      end
      if tBoss then
        tLast.x = tBoss.x
        tLast.y = tBoss.y
        if 0 == tBoss.hp then
          PushColorMsg(npc.name .. ":已死亡")
          m_finish.boss2 = true
          break
        end
        if isSafePos then
          if #tFS > 0 then
            if 4 == g_self.menpai then
              CDG.pet2.GUID = 0
              CDG.pet3.GUID = 0
              FubenAttack(-1, nil, nil, nil, false)
              CDG.pet2.GUID = bGuid2
              CDG.pet3.GUID = bGuid3
            end
          else
            local tid = tBoss.id
            if bFindSpec then
              if g_self.isjingong then
                if tBoss.dst > 3 then
                  if tBoss.dst > 15 or false == JinGongFarSkill(tid) then
                    debugnote = " 近攻暂不攻击"
                    tid = -1
                  else
                    tid = -1
                  end
                end
              elseif tBoss.dst > 15 then
                debugnote = " 超出范围暂不攻击"
                tid = -1
              end
            elseif g_self.isjingong then
              FubenAttack(tid)
            else
              CheckUseJZDJ("#{YTTBF_220524_81}", 15, 30)
              if IsInDebugMsgTime("#{YTTBF_220524_79}", nil, 8) or TBF_start_pos(npc) then
                FubenAttack(tid)
              end
            end
          end
        end
      elseif not bFindSpec then
        TBF_RefreshStep()
        if m_finish.boss2 then
          PushColorMsg(npc.name .. ":已完成")
          break
        else
          debugnote = " 未发现boss,前往中心点"
          Sleep(1000)
          local tObj = Enum2XByName(npc.name, {
            1,
            1,
            0,
            0
          }, nil, nil, 0)
          if 0 == #tObj then
            RunTo(npc.x, npc.y, 0, 1000)
          end
          FubenAttack(-1)
        end
        if false == TBF_IsInStepPos(npc.step) then
          PushColorMsg("当前坐标不是boss2区域！")
          break
        end
      elseif isSafePos then
        FubenAttack(-1)
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. "：" .. npc.name .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  TBF_RefreshStep()
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
  TBF_boss_finish(m_finish.boss2, npc, tpos)
end

local function TBF_boss3_pjcc(aKNpc, aBoss1, aBoss2)
  local bFind = false
  local bSafe = true
  local npc = m_data.boss[3]
  if aBoss1 and aBoss2 and 4 == #aKNpc and IsInDebugMsgTime("#{YTTBF_220524_98}", nil, 10) then
    bFind = true
    local tLX = {}
    for i = 1, #aKNpc do
      if 0 ~= GetDist(aKNpc[i].x, aKNpc[i].y, aBoss1.x, aBoss1.y) and 0 ~= GetDist(aKNpc[i].x, aKNpc[i].y, aBoss2.x, aBoss2.y) then
        table.insert(tLX, aKNpc[i])
      end
    end
    for i = 1, #tLX do
      local tmp = tLX[i]
      tmp.angle1 = GetAngle(aBoss1.x, aBoss1.y, tmp.x, tmp.y)
      tmp.angle2 = GetAngle(aBoss2.x, aBoss2.y, tmp.x, tmp.y)
    end
    local posSafe = {}
    local aTrapRadius = 5
    local tSpec = {}
    table.insert(tSpec, aBoss1)
    table.insert(tSpec, aBoss2)
    local allPos = GetRangeAllPos(npc.x, npc.y, 1, 15, nil)
    for i = 1, #allPos do
      if IsPosSafe(allPos[i], tSpec, aTrapRadius) then
        table.insert(posSafe, allPos[i])
      end
    end
    local posRun = {}
    local nSafeAngle = 30
    for i = 1, #posSafe do
      local tmp = posSafe[i]
      tmp.angle1 = GetAngle(aBoss1.x, aBoss1.y, tmp.x, tmp.y)
      tmp.angle2 = GetAngle(aBoss2.x, aBoss2.y, tmp.x, tmp.y)
      local bSafePos = true
      for j = 1, #tLX do
        local diff1 = math.abs(tLX[j].angle1 - tmp.angle1)
        local diff2 = math.abs(tLX[j].angle2 - tmp.angle2)
        if diff1 >= 315 then
          diff1 = 360 - diff1
        end
        if diff2 >= 315 then
          diff2 = 360 - diff2
        end
        if nSafeAngle > diff1 or nSafeAngle > diff2 then
          bSafePos = false
          break
        end
      end
      if bSafePos then
        table.insert(posRun, tmp)
      end
    end
    GetAllPosDist(posRun, Player:GetPos(), "dist")
    if #posRun > 0 then
      DebugColorMsg(npc.name .. "：躲避破甲摧城", 3)
      BubbleSort(posRun, "dist")
      local runPos = posRun[1]
      if FastRun(runPos, 5) then
        bSafe = true
      else
        bSafe = false
      end
    end
  end
  return bFind, bSafe
end

local function TBF_boss3_hr(atHYHR, atQYHR, aHaveSpec)
  local bFind = false
  local tHYHR = atHYHR
  local tQYHR = atQYHR
  local bFindSpec = aHaveSpec
  if #tHYHR > 0 or #tQYHR > 0 then
    bFind = true
    local tAttack = tHYHR
    if -1 ~= Player:GetBuff("红影：") then
      if #tQYHR > 0 then
        tAttack = tQYHR
      end
    elseif 0 == #tHYHR then
      tAttack = tQYHR
    end
    BubbleByDst(tAttack)
    local tmp = tAttack[1]
    if bFindSpec then
      if g_self.isjingong then
        if tmp.dst <= 3 then
          FubenAttack(tmp.id)
        else
          JinGongFarSkill(tmp.id)
        end
      else
        FubenAttack(tmp.id)
      end
    else
      FubenAttack(tmp.id)
    end
  end
  return bFind
end

local function TBF_YeErNiang()
  local npc = m_data.boss[3]
  local tLast1 = {
    x = npc.x,
    y = npc.y
  }
  local tLast2 = {
    x = npc.x,
    y = npc.y
  }
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    local bStepOk, tAll, tBoss = TBF_CheckObj(npc)
    if false == bStepOk then
      break
    end
    if 0 == #tAll then
      debugnote = " 没有发现目标"
      PickUpLua()
      RunTo(npc.x, npc.y, 0, 2000)
    elseif tBoss and tBoss.class == "NPC" then
      TBF_OpenBoss(npc, tBoss)
    else
      local ttBoss2 = ObjFilterByName(tAll, "傀影", 0)
      local tBoss2 = ttBoss2[1]
      local tHYHR = ObjFilterByName(tAll, "红影回刃", 0)
      tHYHR = ObjFilterByHP(tHYHR, 0, 1)
      local tQYHR = ObjFilterByName(tAll, "青影回刃", 0)
      tQYHR = ObjFilterByHP(tQYHR, 0, 1)
      local tXJ = ObjFilterByName(tAll, "青影预警 红影预警 ", 3)
      local tKNPC = ObjFilterByName(tAll, "副本通用空npc", 0)
      if tBoss then
        tLast1.x = tBoss.x
        tLast1.y = tBoss.y
      end
      if tBoss2 then
        tLast2.x = tBoss2.x
        tLast2.y = tBoss2.y
      end
      local bFindSpec, isSafePos = TBF_boss3_pjcc(tKNPC, tBoss, tBoss2)
      if false == bFindSpec then
        local tSpec = tXJ
        if not tBoss or Target:FindBuff(tBoss, "无敌：免疫所有伤害") then
        else
          for i = 1, #tHYHR do
            table.insert(tSpec, tHYHR[i])
          end
          for i = 1, #tQYHR do
            table.insert(tSpec, tQYHR[i])
          end
        end
        if #tSpec > 0 then
          bFindSpec = true
          local bSafe, _, posSafe, nFindPos = FubenTrapRun("", npc.x, npc.y, 5, 16, tSpec, nil, FubenRunSafe, nil, nil, nil)
          isSafePos = bSafe
        end
      end
      local bFindHR = TBF_boss3_hr(tHYHR, tQYHR, bFindSpec)
      if bFindHR then
        debugnote = " 攻击回刃"
      else
        local tar
        if tBoss and tBoss2 and tBoss.hp > 0 and tBoss2.hp > 0 then
          if g_self.isjingong or math.abs(tBoss.hp - tBoss2.hp) > 15 then
            if -1 ~= Player:GetBuff("红影：") then
              tar = tBoss2
            else
              tar = tBoss
            end
          elseif tBoss.hp > tBoss2.hp then
            tar = tBoss
          else
            tar = tBoss2
          end
        elseif tBoss and tBoss.hp > 0 then
          tar = tBoss
        elseif tBoss2 and tBoss2.hp > 0 then
          tar = tBoss2
        elseif not tBoss and not tBoss2 then
          TBF_RefreshStep()
          if m_finish.boss3 then
            PushColorMsg(npc.name .. ":已完成")
            break
          else
            debugnote = " 未发现boss,前往中心点"
            Sleep(1000)
            local tObj = Enum2XByName(npc.stepobj, {
              1,
              1,
              0,
              0
            }, nil, nil, 3)
            if 0 == #tObj then
              RunTo(npc.x, npc.y, 0, 1000)
            end
            FubenAttack(-1)
          end
          if false == TBF_IsInStepPos(npc.step) then
            PushColorMsg("当前坐标不是boss3区域！")
            break
          end
        else
          TBF_RefreshStep()
          m_finish.boss3 = true
          if m_finish.boss3 then
            PushColorMsg(npc.name .. ":已完成")
            break
          end
        end
        if tar and isSafePos then
          if Target:FindBuff(tBoss, "无敌：免疫所有伤害") then
            FubenAttack(-1)
          else
            local tid = tar.id
            if bFindSpec then
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
            elseif g_self.isjingong then
            elseif tar.dst > 15 then
              RunTo(tar.x, tar.y, 0, 1500)
            end
            FubenAttack(tid)
          end
        end
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. "：" .. npc.name .. debugnote)
  end
  TBF_RefreshStep()
  local tpos = {}
  table.insert(tpos, {
    x = npc.x,
    y = npc.y
  })
  table.insert(tpos, {
    x = tLast1.x,
    y = tLast1.y
  })
  table.insert(tpos, {
    x = tLast2.x,
    y = tLast2.y
  })
  TBF_boss_finish(m_finish.boss3, npc, tpos)
end

local function TBF_boss4_zfwj(atZFWJ)
  local npc = m_data.boss[4]
  local bFind = false
  local bSelf = false
  local bSafe = true
  if #atZFWJ > 0 then
    bFind = true
    if -1 ~= Player:GetBuff("连线：") then
      bSelf = true
    end
    local angleOther = {min = 20, max = 160}
    local angleLX = {min = 185, max = 355}
    for i = 1, #atZFWJ do
      local tmp = atZFWJ[i]
      tmp.angle = GetAngle(npc.x, npc.y, tmp.x, tmp.y)
    end
    local myPos = Player:GetPos()
    local myDist = GetDist(npc.x, npc.y, myPos.x, myPos.y)
    local myAngle = GetAngle(npc.x, npc.y, myPos.x, myPos.y)
    local tAllPos = {}
    if bSelf then
      local rZero = 9
      if myAngle >= angleLX.min and myAngle <= angleLX.max then
        rZero = myDist
        if rZero < 9 then
          rZero = 9
        end
      end
      for i = angleLX.min, angleLX.max do
        local tpos = GetAnglePos(npc, i, rZero)
        tpos.dst = GetDist(myPos.x, myPos.y, tpos.x, tpos.y)
        table.insert(tAllPos, tpos)
      end
    else
      local rZero = 5
      if myAngle >= angleOther.min and myAngle <= angleOther.max then
        rZero = myDist
        if rZero < 5 then
          rZero = 5
        end
      end
      for i = angleOther.min, angleOther.max do
        local tpos = GetAnglePos(npc, i, rZero)
        tpos.dst = GetDist(myPos.x, myPos.y, tpos.x, tpos.y)
        table.insert(tAllPos, tpos)
      end
    end
    local tSafePos = {}
    for i = 1, #tAllPos do
      local checkPos = tAllPos[i]
      local bPosSafe = true
      for j = 1, #atZFWJ do
        local tmp = atZFWJ[j]
        local nDiff = math.abs(tmp.angle - checkPos.angle)
        if nDiff >= 315 then
          nDiff = 360 - nDiff
        end
        if nDiff < 20 then
          bPosSafe = false
          break
        end
      end
      if bPosSafe then
        table.insert(tSafePos, checkPos)
      end
    end
    if #tSafePos > 0 then
      BubbleByDst(tSafePos)
      local runpos = tSafePos[1]
      local bRun = RunTo(runpos.x, runpos.y, 0, 1500)
      bSafe = not bRun
    else
      DebugColorMsg("没有找到安全坐标", 3)
    end
  end
  return bFind, bSelf, bSafe
end

local function TBF_boss4_yqtz()
  local npc = {
    x = 399,
    y = 92,
    name = "心魔·延庆太子",
    step = 5
  }
  local tLast2 = {
    x = npc.x,
    y = npc.y
  }
  local tSFPos = {
    {
      x = 389,
      y = 82,
      type = 2
    },
    {
      x = 409,
      y = 82,
      type = 2
    },
    {
      x = 389,
      y = 102,
      type = 2
    },
    {
      x = 409,
      y = 102,
      type = 2
    },
    {
      x = 394,
      y = 87,
      type = 1
    },
    {
      x = 404,
      y = 87,
      type = 1
    },
    {
      x = 394,
      y = 97,
      type = 1
    },
    {
      x = 404,
      y = 97,
      type = 1
    }
  }
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    local tAll = Enum2XByClass("NPC 怪物 陷阱")
    local ttBoss = ObjFilterByName(tAll, "心魔·延庆太子", 0)
    local tBoss = ttBoss[1]
    local tDC = ObjFilterByName(tAll, "紫衣大臣", 0)
    tDC = ObjFilterByHP(tDC, 0, 1)
    local tSFJZ = ObjFilterByName(tAll, " 十方尽诛预警圈外 十方尽诛效果圈外 十方尽诛预警圈内 十方尽诛效果圈内 ", 3)
    local tJXRY = ObjFilterByName(tAll, "剑悬日月", 5)
    if tBoss then
      tLast2.x = tBoss.x
      tLast2.y = tBoss.y
    end
    local bFindSpec1 = false
    local bFindSpec2 = false
    local bFindSpec3, isSafePos = false, true
    if #tDC > 0 then
      bFindSpec1 = true
      local bCheckPet = false
      CDG.pet2.GUID = 0
      CDG.pet3.GUID = 0
      BubbleByDst(tDC)
      local tmp = tDC[1]
      if g_self.isjingong then
        if tmp.dst <= 3 then
          FubenAttack(tmp.id, nil, nil, nil, bCheckPet)
        elseif not JinGongFarSkill(tmp.id) then
          FubenAttack(tmp.id, nil, nil, nil, bCheckPet)
        end
      else
        FubenAttack(tmp.id, nil, nil, nil, bCheckPet)
      end
      CDG.pet2.GUID = bGuid2
      CDG.pet3.GUID = bGuid3
    elseif #tSFJZ > 0 then
      bFindSpec2 = true
      local tSafePos = {}
      for i = 1, #tSFPos do
        local bSafe = true
        for j = 1, #tSFJZ do
          if GetDist(tSFJZ[j].x, tSFJZ[j].y, tSFPos[i].x, tSFPos[i].y) < 5 then
            bSafe = false
            break
          end
        end
        if bSafe then
          table.insert(tSafePos, tSFPos[i])
        end
      end
      local myPos = Player:GetPos()
      GetAllPosDist(tSafePos, myPos, "dist")
      BubbleByDist(tSafePos)
      local tSafePos_nq = {}
      local runpos
      for i = 1, #tSafePos do
        if 1 == tSafePos[i].type then
          if nil == runpos then
            runpos = tSafePos[i]
          end
          table.insert(tSafePos_nq, tSafePos[i])
        end
      end
      if tBoss and g_self.isjingong and #tSafePos_nq > 0 then
        GetAllPosDist(tSafePos_nq, tBoss, "dist_boss")
        BubbleSort(tSafePos_nq, "dist_boss", 1)
        runpos = tSafePos_nq[1]
      end
      if nil == runpos and #tSafePos > 0 then
        runpos = tSafePos[1]
      end
      if runpos then
        if g_self.isjingong then
          if GetDist(runpos.x, runpos.y, myPos.x, myPos.y) < 3 then
            isSafePos = true
          else
            isSafePos = FastRun(runpos, 5)
          end
        else
          isSafePos = FastRun(runpos, 5)
        end
      end
    elseif #tJXRY > 0 then
      bFindSpec3 = true
      local bSafe, _, posSafe, nFindPos = FubenTrapRun("", npc.x, npc.y, 7, 16, tJXRY, nil, FubenRunSafe, nil, nil, nil)
      isSafePos = bSafe
    end
    if tBoss then
      if bFindSpec1 then
      elseif bFindSpec2 then
        if isSafePos then
          debugnote = " 集火boss"
          CDG.pet2.GUID = 0
          CDG.pet3.GUID = 0
          local emYXJX = CDG.hp.em_yxjx
          CDG.hp.em_yxjx = false
          CheckUseJZDJ("#{YTTBF_220524_117}", 1, 75)
          FubenAttack(tBoss.id, true, true, nil, false)
          CDG.pet2.GUID = bGuid2
          CDG.pet3.GUID = bGuid3
          CDG.hp.em_yxjx = emYXJX
        end
      elseif bFindSpec3 then
        if isSafePos then
          local tar = tBoss
          local tid = tar.id
          if g_self.isjingong then
            if tar.dst > 3 then
              if tar.dst > 15 or JinGongFarSkill(tid) == false then
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
          FubenAttack(tid)
        end
      elseif 0 == tBoss.hp then
        PushColorMsg(npc.name .. ":已死亡")
        m_finish.boss4 = true
        break
      else
        local tar = tBoss
        local tid = tar.id
        if g_self.isjingong then
          FubenAttack(tid)
        elseif TBF_start_pos(npc) then
          FubenAttack(tid)
        end
      end
    else
      debugnote = " 没发现boss"
      local myPos = Player:GetPos()
      if myPos.x > 300 then
      else
        break
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. "：" .. npc.name .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  return tLast2
end

local function TBF_boss4_dyq()
  local npc = m_data.boss[4]
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  while FubenCheckSceneDie(m_data.sceneID) do
    local debugnote = ""
    local bStepOk, tAll, tBoss = TBF_CheckObj(npc)
    if false == bStepOk then
      break
    end
    if 0 == #tAll then
      debugnote = " 没有发现目标"
      PickUpLua()
      
      local function _cb(...)
        local _selfPos = Player:GetPos()
        if _selfPos.y >= 80 then
          return false
        end
        return TBF_cb_run(...)
      end
      
      MoveTo(npc.x, npc.y, -1, 12, nil, nil, _cb)
      RunTo(npc.x, npc.y, 0, 2000)
    elseif tBoss and tBoss.class == "NPC" then
      TBF_OpenBoss(npc, tBoss)
    else
      local tDC = ObjFilterByName(tAll, "蓝衣大臣", 0)
      tDC = ObjFilterByHP(tDC, 0, 1)
      local tZFWJ = ObjFilterByName(tAll, "罪缚无间预警", 0)
      local tJMFX = ObjFilterByName(tAll, "苔杖", 5)
      local bFindSpec1 = false
      local bFindSpec2 = false
      local bFindSpec3, isSafePos = false, true
      if #tDC > 0 then
        local bCheckPet = false
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
        bFindSpec1 = true
        BubbleByDst(tDC)
        local tmp = tDC[1]
        if g_self.isjingong then
          if tmp.dst <= 3 then
            FubenAttack(tmp.id, nil, nil, nil, bCheckPet)
          elseif not JinGongFarSkill(tmp.id) then
            FubenAttack(tmp.id, nil, nil, nil, bCheckPet)
          end
        else
          FubenAttack(tmp.id, nil, nil, nil, bCheckPet)
        end
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
      else
        local bSelf, bSafe
        bFindSpec2, bSelf, bSafe = TBF_boss4_zfwj(tZFWJ, tBoss)
        if bFindSpec2 then
          if bSelf then
            debugnote = " 被连线"
          elseif bSafe then
            FubenAttack(-1)
          end
        elseif #tJMFX > 0 then
          bFindSpec3 = true
          local bSafe, _, posSafe, nFindPos = FubenTrapRun("", npc.x, npc.y, 6, 16, tJMFX, nil, FubenRunSafe, nil, nil, nil)
          isSafePos = bSafe
        end
      end
      if bFindSpec1 or bFindSpec2 then
      elseif bFindSpec3 then
        if tBoss and isSafePos then
          local tar = tBoss
          local tid = tar.id
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
          FubenAttack(tid)
        end
      else
        IsWindowVisible("AnimationPass", "AnimationPass_OnClick()")
        if tBoss then
          local tar = tBoss
          local tid = tar.id
          if g_self.isjingong then
          elseif tar.dst > 15 then
            RunTo(tar.x, tar.y, 0, 1500)
          end
          FubenAttack(tid)
        else
          local ttBoss2 = ObjFilterByName(tAll, "心魔·延庆太子", 0)
          if #ttBoss2 > 0 then
            PushColorMsg("发现：心魔·延庆太子")
            break
          end
          TBF_RefreshStep()
          if m_finish.boss4 then
            PushColorMsg(npc.name .. ":已完成")
            break
          else
            debugnote = " 未发现boss,前往中心点"
            Sleep(1000)
            local myPos = Player:GetPos()
            if myPos.y >= 80 then
              break
            end
            local tObj = Enum2XByName(npc.name, {
              1,
              1,
              0,
              0
            }, nil, nil, 0)
            if 0 == #tObj then
              local function _cb(...)
                local _selfPos = Player:GetPos()
                
                if _selfPos.y >= 80 then
                  return false
                end
                return TBF_cb_run(...)
              end
              
              MoveTo(npc.x, npc.y, -1, 12, nil, nil, _cb)
              RunTo(npc.x, npc.y, 0, 1000)
            end
            FubenAttack(-1)
          end
        end
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. "：" .. npc.name .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function TBF_DuanYanQing()
  local npc = m_data.boss[4]
  local tLast2 = {x = 399, y = 92}
  while FubenCheckSceneDie(m_data.sceneID) do
    local tObj = Enum2XByName(npc.stepobj, {
      1,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.name == "段延庆" then
        TBF_boss4_dyq()
      elseif tmp.name == "心魔·延庆太子" then
        tLast2.x = tmp.x
        tLast2.y = tmp.y
        if 0 == tmp.hp then
          m_finish.boss4 = true
          break
        else
          local yqpos = TBF_boss4_yqtz()
          if yqpos then
            tLast2.x = yqpos.x
            tLast2.y = yqpos.y
          end
        end
      end
    else
      TBF_RefreshStep()
      if m_finish.boss4 then
        PushColorMsg(npc.name .. ":已完成")
        break
      end
      if TBF_IsInStepPos(npc.step) == false then
        PushColorMsg("当前坐标不是boss4区域！")
        break
      end
      local myPos = Player:GetPos()
      if myPos.y < 80 then
        PushColorMsg("段延庆坐标处!")
        
        local function _cb(...)
          local _selfPos = Player:GetPos()
          if _selfPos.y >= 80 then
            return false
          end
          return TBF_cb_run(...)
        end
        
        MoveTo(npc.x, npc.y, -1, 10, nil, nil, _cb)
        RunTo(npc.x, npc.y, 0, 1000)
        return
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. "：" .. npc.name .. ",心魔·延庆太子")
  end
  TBF_RefreshStep()
  local tpos = {}
  table.insert(tpos, {
    x = npc.x,
    y = npc.y
  })
  table.insert(tpos, {
    x = tLast2.x,
    y = tLast2.y
  })
  TBF_boss_finish(m_finish.boss4, npc, tpos)
end

local function TBF_action_callback()
  local tAll = Enum2XByClass("NPC 怪物 陷阱")
  local tSYZH = ObjFilterByName(tAll, "白鹤之影（俯冲）", 0)
  local tHCZZ = ObjFilterByName(tAll, "横冲直撞预警圈", 0)
  local tNEXS = ObjFilterByName(tAll, "副本通用空npc", 0)
  local tCJJ = ObjFilterByName(tAll, "沉金锏", 0)
  local tFS = ObjFilterByName(tAll, " 岳老三分身预警 岳老三分身 ", 3)
  local tZFWJ = ObjFilterByName(tAll, "罪缚无间预警", 0)
  local tJMFX = ObjFilterByName(tAll, "苔杖", 5)
  local tJXRY = ObjFilterByName(tAll, "剑悬日月", 5)
  if #tSYZH > 0 then
    if 4 == g_self.menpai then
      PlayerStateTimeOut(5, 1)
    end
    return false
  elseif #tFS > 0 then
    return false
  elseif #tZFWJ > 0 then
    local bFind, bSelf, bSafe = TBF_boss4_zfwj(tZFWJ)
    if bSelf or not bSafe then
      return false
    end
  elseif #tJMFX > 0 or #tJXRY > 0 then
    return false
  end
  return true
end

local function TBF_OnProcess()
  TBF_RefreshStep()
  PickUpLua()
  if m_finish.boss4 then
    DebugColorMsg("副本完成", 3)
    RelivePlayer(1, nil, nil, nil, nil, true)
    local myPos = Player:GetPos()
    if myPos.y > 317 then
      local tObj = Enum2XByName("穆小妹", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        RunTo(tObj[1].x, tObj[1].y, 0, 1000)
        Dismount(500)
        Pet:Relax(300)
        TalkNpc("穆小妹", 600)
        QuestFrameOptionClicked_Item("#{YTTBF_220524_260}", 1, 800)
      end
      return
    elseif myPos.x > 300 then
      PickUpLua_Boss(15, 15, m_data.sceneID)
      local tDieEM, tDieOther, tRelive = GetDiePlayer()
      if 4 ~= g_self.menpai or 0 == #tRelive then
        RunTo(406, 99, 2, 1000)
        PickUpLua()
        TalkNpc("杨文广", 600)
        DialogOptionClicked("离开天波府", 1, 800)
        DialogOptionClicked("确认", 1, 800)
      else
        PushColorMsg("有玩家需要复活")
      end
    else
      PushColorMsg("我是谁？我在哪？")
    end
    return
  end
  local tObj = Enum2XByName(m_data.allName, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    local tmp = tObj[1]
    PushColorMsg("发现Boss:" .. tmp.name)
    if tmp.name == "云中鹤" then
      if tmp.hp > 0 then
        TBF_SetFinishState(false, false, false, false)
        TBF_YunZhongHe()
        return
      else
        TBF_SetFinishState(true, false, false, false)
      end
    elseif tmp.name == "岳老三" then
      if tmp.hp > 0 then
        TBF_SetFinishState(true, false, false, false)
        TBF_YueLaoSan()
        return
      else
        TBF_SetFinishState(true, true, false, false)
      end
    elseif tmp.name == "叶二娘" or tmp.name == "傀影" then
      for i = 1, #tObj do
        if tObj[i].hp > 0 then
          TBF_SetFinishState(true, true, false, false)
          TBF_YeErNiang()
          return
        end
      end
      TBF_SetFinishState(true, true, nil, false)
    elseif tmp.name == "段延庆" or tmp.name == "心魔·延庆太子" then
      if tmp.hp > 0 then
        TBF_SetFinishState(true, true, true, false)
        TBF_DuanYanQing()
      end
      return
    else
      PushColorMsg("未知阶段？")
    end
  end
  RelivePlayer(1, nil, nil, nil, nil, true)
  local nIndex = 1
  local myPos = Player:GetPos()
  if myPos.x > 300 then
    PushColorMsg("心魔坐标处")
    RunTo(399, 92, 0, 1000)
    return
  elseif myPos.y < 80 then
    PushColorMsg("段延庆坐标处")
    local npc = m_data.boss[4]
    
    local function _cb(...)
      local _selfPos = Player:GetPos()
      if _selfPos.y >= 80 then
        return false
      end
      return TBF_cb_run(...)
    end
    
    MoveTo(npc.x, npc.y, -1, 10, nil, nil, _cb)
    RunTo(npc.x, npc.y, 0, 1000)
    return
  end
  if m_finish.boss3 then
    nIndex = 4
    if myPos.y > 317 then
      local tObj = Enum2XByName("穆小妹", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        RunTo(tObj[1].x, tObj[1].y, 0, 1000)
        Dismount(500)
        Pet:Relax(300)
        TalkNpc("穆小妹", 600)
        QuestFrameOptionClicked_Item("#{YTTBF_220524_259}", 1, 800)
      end
      return
    else
      MoveTo(119, 99, -1, 1, nil, nil, TBF_cb_run_123)
      Dismount(500)
      Pet:Relax(300)
      TalkNpc("杨小弟", 500)
      QuestFrameOptionClicked_Item("#{YTTBF_220524_138}", 1, 800)
      return
    end
  elseif m_finish.boss2 then
    nIndex = 3
  elseif m_finish.boss1 then
    nIndex = 2
  end
  local pos = m_data.boss[nIndex]
  if GetDist(pos.x, pos.y) > 10 then
    if nIndex > 2 then
      local tObj = Enum2XByName("穆小妹", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        RunTo(tObj[1].x, tObj[1].y, 0, 1000)
        Dismount(500)
        Pet:Relax(300)
        TalkNpc("穆小妹", 600)
        if m_finish.boss3 then
          QuestFrameOptionClicked_Item("#{YTTBF_220524_259}", 1, 800)
          return
        elseif m_finish.boss2 then
          QuestFrameOptionClicked_Item("#{YTTBF_220524_258}", 1, 800)
          return
        end
      end
    end
    UseMount()
    MoveTo(pos.x, pos.y, -1, 1, nil, nil, TBF_cb_run_123)
    return
  end
end

local function TBF_Start()
  CDG.call.back1 = TBF_action_callback
  while GetSceneID() == m_data.sceneID do
    TBF_OnProcess()
    FuBenCheckDie(false, true, TBF_cb_ondie)
    PickUpLua(nil, true, true)
    Sleep(50)
    DebugStr(m_script_name .. "：副本中", 2)
  end
end

function _SMain()
  local bOver = false
  if 1 == g_client_type then
    local _, _, _, nHave = IsHuodongComplete("夜探天波府", 1, true)
    if 0 == nHave then
      Sleep(3000)
      local _, _, _, nHave = IsHuodongComplete("夜探天波府", 1, true)
      if 0 == nHave then
        PushColorMsg("今天没有" .. m_script_name)
        return
      end
    end
  end
  while true do
    local debugnote = ""
    if GetSceneID() == m_data.sceneID then
      TBF_Start()
      bOver = true
    else
      if bOver then
        Sleep(3000)
        if GetSceneID() ~= m_data.sceneID then
          break
        end
      end
      if IsHuodongComplete("夜探天波府", 1) then
        Sleep(3000)
        if IsHuodongComplete("夜探天波府", 1, true) and GetSceneID() ~= m_data.sceneID then
          LogMsg(m_script_name .. ":已完成")
          break
        end
      end
      local npc = m_data.npc
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      ChangeSceneLine()
      FubenAttack(-1)
      local team_or_raid, bleader, nCount = GetLuaValue("return meGetTeamRaidBaseInfo()", "nbn")
      if bleader and 2 == team_or_raid then
        if nCount >= m_param.teamCount then
          if m_param.knMode then
            QuestFrameOptionClicked_Item("#{YTTBF_220524_06}", 1, 1000)
          else
            QuestFrameOptionClicked_Item("#{YTTBF_220524_05}", 1, 1000)
          end
        else
          debugnote = " 团队人数不够"
        end
      end
    end
    Sleep(300)
    DebugStr(m_data.sceneName .. "：等待进入副本" .. debugnote, 2)
  end
end

RecvState(1)
_SMain()
ScriptOnStop(m_script_name, true)
