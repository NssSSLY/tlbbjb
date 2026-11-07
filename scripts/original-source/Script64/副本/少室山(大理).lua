-- 反编译自 dfz64.dll 内嵌字节码 002ef962（unluac 2025-12-23；仅供分析）
local m_script_name = "少室山"
ScriptOnStart(m_script_name, true, true)
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk136"), 6)
CDG.hp.em_raid = false
g_pick.check = true
local m_param = {}
m_param.ladcq = ReadConfigBool("ZH", "xzk47")
m_param.not_waitzjx = not ReadConfigBool("ZH", "xzk189")
m_param.swcq = false
m_param.sceneID = 566
m_param.sceneName = "少室山"
m_param.time_boss2wait = -1
m_param.bossNameBZ = ""
m_param.FBType = ReadConfigText("ZH", "sss_type")
local m_finish = {
  boss1 = false,
  boss2 = false,
  boss3 = false,
  boss4 = false,
  boss5 = false
}
local m_boss5_ZouWei = {
  {x = 122, y = 39},
  {x = 128, y = 43},
  {x = 128, y = 50},
  {x = 122, y = 53},
  {x = 116, y = 50},
  {x = 116, y = 43}
}

local function SSS_SetFinishState(boss1, boss2, boss3, boss4, boss5)
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
  if nil ~= boss5 then
    m_finish.boss5 = boss5
  end
end

local function SSS_IsStepOver(nStep)
  local nTransTime = GetSceneTransTime()
  if 5 == nStep then
    local nMsgTime5 = IsInDebugMsg("SSS_ZJ_120109_50")
    if nMsgTime5 and nTransTime < nMsgTime5 then
      return true
    end
  elseif 4 == nStep then
    local nMsgTime4 = IsInDebugMsg("#{SSS_ZJ_120109_02}")
    if nMsgTime4 and nTransTime < nMsgTime4 then
      return true
    end
  elseif 3 == nStep then
    local nMsgTime3 = IsInDebugMsg("CJG_101231_143")
    if nMsgTime3 and nTransTime < nMsgTime3 then
      return true
    end
    nMsgTime3 = IsInDebugMsg("#{CJG_101231_213}")
    if nMsgTime3 and nTransTime < nMsgTime3 then
      return true
    end
  elseif 2 == nStep then
    local nMsgTime2 = IsInDebugMsg("CJG_101231_212")
    if nMsgTime2 and nTransTime < nMsgTime2 then
      return true
    end
    local nMsgTime2_2 = IsInDebugMsg("CJG_101231_234")
    if nMsgTime2_2 and nTransTime < nMsgTime2_2 then
      return true
    end
  elseif 1 == nStep then
    local nMsgTime1 = IsInDebugMsg("CJG_101231_211")
    if nMsgTime1 and nTransTime < nMsgTime1 then
      return true
    end
  end
  return false
end

local function SSS_IsInStep(nStep)
  local nTransTime = GetSceneTransTime()
  if 3 == nStep then
    local nMsgTime = IsInDebugMsg("CJG_101231_140")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
    nMsgTime = IsInDebugMsg("CJG_101231_141")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
  end
  if 4 == nStep then
    local nMsgTime = IsInDebugMsg("CJG_101231_82")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
    nMsgTime = IsInDebugMsg("CJG_101231_83")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
  end
  if 5 == nStep then
    local nMsgTime = IsInDebugMsg("#{SSS_ZJ_120109_14}")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
    nMsgTime = IsInDebugMsg("#{SSS_ZJ_120109_20}")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
    nMsgTime = IsInDebugMsg("#{SSS_ZJ_120109_75}")
    if nMsgTime and nTransTime < nMsgTime then
      return true
    end
  end
  return false
end

local function SSS_GetStep()
  local nTransTime = GetSceneTransTime()
  local nMsgTime5 = IsInDebugMsg("SSS_ZJ_120109_50")
  local nMsgTime4 = IsInDebugMsg("#{SSS_ZJ_120109_02}")
  local nMsgTime3 = IsInDebugMsg("CJG_101231_143")
  local nMsgTime3_2 = IsInDebugMsg("#{CJG_101231_213}")
  local nMsgTime2 = IsInDebugMsg("CJG_101231_212")
  local nMsgTime2_2 = IsInDebugMsg("CJG_101231_234")
  local nMsgTime1 = IsInDebugMsg("CJG_101231_211")
  local nStep = -1
  if nMsgTime5 and nTransTime < nMsgTime5 then
    nStep = 6
    SSS_SetFinishState(true, true, true, true, true)
  elseif nMsgTime4 and nTransTime < nMsgTime4 or SSS_IsInStep(5) then
    nStep = 5
    SSS_SetFinishState(true, true, true, true, false)
  elseif nMsgTime3 and nTransTime < nMsgTime3 or SSS_IsInStep(4) then
    nStep = 4
    SSS_SetFinishState(true, true, true, false, false)
  elseif nMsgTime3_2 and nTransTime < nMsgTime3_2 then
    nStep = 4
    SSS_SetFinishState(true, true, true, false, false)
  elseif nMsgTime2 and nTransTime < nMsgTime2 or SSS_IsInStep(3) then
    nStep = 3
    SSS_SetFinishState(true, true, false, false, false)
  elseif nMsgTime2_2 and nTransTime < nMsgTime2_2 then
    nStep = 3
    SSS_SetFinishState(true, true, nil, false, false)
  elseif nMsgTime1 and nTransTime < nMsgTime1 then
    nStep = 2
    SSS_SetFinishState(true, false, false, false, false)
  end
  DebugStr("少室山：当前进度 Boss" .. nStep, 3)
end

local function SSS_IsStepPos(nStep)
  local pos = Player:GetPos()
  if 1 == nStep then
    if pos.x < 155 and pos.y > 150 then
      return true
    end
  elseif 2 == nStep then
    if pos.x < 97 and pos.y > 99 and pos.y < 150 then
      return true
    end
  elseif 3 == nStep then
    if pos.x > 172 and pos.x < 219 and pos.y > 65 and pos.y < 109 then
      return true
    end
  elseif 4 == nStep then
    if pos.x > 97 and pos.x < 160 and pos.y > 97 and pos.y < 151 then
      return true
    end
  elseif 5 == nStep and pos.y < 67 then
    return true
  end
  return false
end

local function SSS_boss_finish(bFinish, boss, posPick)
  local pos = posPick or {
    {
      x = boss.x,
      y = boss.y
    }
  }
  if bFinish then
    PushDebugMessage("少室山：" .. boss.name .. " 已完成。")
    EatFubenItem(3)
    PickUpLua(nil, true)
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua_Boss(60, 15, nil, pos, true, nil)
    RelivePlayer(1, nil, nil, nil, nil, true)
  end
end

local function SSS_callback(fX, fY, nScene)
  DebugStr("少室山:移动到坐标 %d,%d ", 2, math.floor(fX), math.floor(fY))
  PickUpLua()
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  if not Player:IsLeader() and Player:IsFollow() then
    if 56 == math.floor(fX) and 88 == math.floor(fY) then
      Player:TeamFollow(false, 200)
    end
    if math.floor(fX) == 215 and math.floor(fY) == 180 then
      Player:TeamFollow(false, 200)
    end
  end
  return true
end

local function SSS_cb_hp()
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  local tObj = Enum2XByName(" 鸠摩智 庄聚贤 慕容复 丁春秋 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    return true
  end
  return false
end

local function SSS_cb_boss5_hp()
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  local tObj = Enum2XByName(" 萧远山" .. m_param.bossNameBZ .. " 慕容博" .. m_param.bossNameBZ .. " 心魔 黑色心魔 达魔正心 ", {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    return false
  end
  return true
end

local function SSS_Kill_Monster()
  local nSort = 1
  if g_self.isjingong == false then
    nSort = 1
  end
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByClass("怪物", {0, -1}, nSort)
    if 0 == #tObj or string.find("鸠摩智 鸠摩智" .. m_param.bossNameBZ .. " 信徒 庄聚贤 庄聚贤" .. m_param.bossNameBZ .. " 冰蚕 慕容复 慕容复" .. m_param.bossNameBZ .. " 丁春秋 丁春秋" .. m_param.bossNameBZ, tObj[1].name, nil, true) or tObj[1].name == "萧远山" .. m_param.bossNameBZ or tObj[1].name == "慕容博" .. m_param.bossNameBZ or tObj[1].name == "丁春秋" .. m_param.bossNameBZ or tObj[1].name == "血咒巫蛊" or tObj[1].name == "萧远山与慕容博" then
      break
    end
    local tmp = tObj[1]
    if tmp.dst >= 15 then
      local pos = Player:GetPos()
      if pos.y > 150 then
        PushColorMsg("少室山：距离过远 " .. tmp.name)
        RunTo(tmp.x, tmp.y, 0, 1000)
      end
    end
    FubenAttack(tmp.id)
    Sleep(300)
    DebugStr("少室山：清理小怪中 " .. tmp.name)
  end
end

local function SSS_Boss0()
  local pos = Player:GetPos()
  if pos.y > 208 then
    local nIndex = Team:GetMyIndex()
    if 0 == nIndex or 2 == nIndex or 4 == nIndex then
      MoveTo(117, 204, -1, nil, nil, nil, SSS_callback)
    else
      MoveTo(142, 204, -1, nil, nil, nil, SSS_callback)
    end
    Sleep(1000)
    MoveTo(129, 204, -1, nil, nil, nil, SSS_callback)
    Sleep(500)
    MoveTo(129, 182, -1, nil, nil, nil, SSS_callback)
  elseif pos.y > 182 then
    MoveTo(129, 182, -1, 1, nil, nil, SSS_callback)
    RunTo(129, 182, 0, 1000)
  else
    DebugStr("少室山：无法判断进度" .. pos.y, 3)
    Sleep(1000)
    local tObj = Enum2XByClass("怪物", {0, -1})
    if 0 == #tObj then
      PushColorMsg("无法判断进度")
      RunTo(122, 46, 0, 1000)
    end
  end
  SSS_Kill_Monster()
end

local function SSS_Boss1(szclass)
  local boss = {
    name = "鸠摩智" .. m_param.bossNameBZ,
    x = 130,
    y = 171
  }
  DebugStr("少室山：" .. boss.name .. " " .. szclass)
  if "NPC" == szclass then
    RelivePlayer(1, nil, nil, nil, nil, true)
    local pos = {x = 0, y = 0}
    MoveKaTuSetSDPos(pos)
    MoveKaTu(boss.x, boss.y, m_param.sceneID)
    if Player:IsLeader() then
      if RunTo(131, 172, 3, 1000) == false then
        CheckAllTeamHP(85, SSS_cb_hp, 30)
        TalkNpc("鸠摩智")
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{CJG_101231_375}", 1, 1000)
        MessageBox_Self_OK_Clicked()
      end
      CloseWindow("Quest")
    elseif g_self.isjingong then
      RunTo(131, 172, 0, 1000)
    else
      local nIndex = Team:GetMyIndex()
      if 0 == nIndex or 2 == nIndex or 4 == nIndex then
        RunTo(126, 166, 0, 1000)
      else
        RunTo(133, 166, 0, 1000)
      end
    end
    FubenAttack(-1)
    return
  end
  if false == g_self.isjingong and not Player:IsLeader() then
    local nIndex = Team:GetMyIndex()
    if 0 == nIndex or 2 == nIndex or 4 == nIndex then
      if RunTo(126, 166, 1, 1000) then
        return
      end
    elseif RunTo(133, 166, 1, 1000) then
      return
    end
  end
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName("信徒", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tObj > 0 then
      if g_self.isjingong then
        BubbleByDst(tObj, 1)
      end
    else
      tObj = Enum2XByName(boss.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
    end
    local tmp = {}
    tmp.id = -1
    if 0 == #tObj then
      PushDebugMessage("未找到目标：" .. boss.name)
      Sleep(1000)
      PickUpLua()
      if SSS_IsStepOver(1) then
        SSS_SetFinishState(true, false, false, false, false)
        break
      end
      local tObj = Enum2XByName(boss.name, {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 and 0 == tObj[1].hp then
        SSS_SetFinishState(true, false, false, false, false)
        break
      end
      if false == SSS_IsStepPos(1) or RunTo(boss.x, boss.y, 0, 1000) == false then
        break
      end
    else
      tmp = tObj[1]
    end
    FubenAttack(tmp.id)
    Sleep(50)
    DebugStr("少室山:" .. boss.name)
  end
  SSS_boss_finish(m_finish.boss1, boss)
end

local function SSS_get_special_boss2()
  local bKuangBao = false
  local bKuangBao_self = false
  local tAllSpec = EnumUnSafeSpecial()
  local specName = " 冰蚕丝（冰） "
  local tSpecial = ObjFilterByName(tAllSpec, specName, 3)
  local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
  for i = 1, #tUnKnow do
    PushColorMsg("庄聚贤未知的陷阱：" .. tUnKnow[i].name)
  end
  local tBoss
  local tObj = Enum2XByName("庄聚贤" .. m_param.bossNameBZ, {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 0)
  if #tObj > 0 then
    tBoss = tObj[1]
    if Target:FindBuff(tBoss, "疯狂：极大的提高伤害") then
      bKuangBao = true
      if tBoss.target == Player:GetTID() then
        bKuangBao_self = true
      end
      if bKuangBao_self or g_self.isjingong == false or false == CDG.attack then
        table.insert(tSpecial, tObj[1])
      end
    end
  end
  return tSpecial, bKuangBao, bKuangBao_self, tBoss
end

local function SSS_Boss2_runsafe(pos, posSafe, aParam)
  local runpos = pos
  if CDG.attack then
    if g_self.isjingong then
      local tObj = Enum2XByName("冰蚕", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if 0 == #tObj then
        tObj = Enum2XByName("庄聚贤" .. m_param.bossNameBZ, {
          0,
          1,
          0,
          0
        }, {0, -1}, nil, 0)
      end
      if #tObj > 0 then
        local allpos = GetAllPosDist(posSafe, tObj[1], "hp")
        BubbleByHP(allpos, 1)
        if #allpos > 0 then
          runpos = allpos[1]
        end
      end
    elseif g_self.isjingong == false then
      local tObj = Enum2XByName("冰蚕", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tObj > 0 then
        local allpos = GetAllPosDist(posSafe, tObj[1], "hp")
        BubbleByHP(allpos, 1)
        if #allpos > 0 then
          runpos = allpos[1]
        end
      end
    end
  end
  RunTo(runpos.x, runpos.y, 0, 200)
  for i = 1, 5 do
    if 2 ~= Player:GetState() and GetDist(runpos.x, runpos.y) > 1 then
      RunTo(runpos.x, runpos.y, 0, 100)
    else
      break
    end
  end
end

local function SSS_zjx_pullrun(aPosNext, aPosAll, aTarget, aParam)
  local run = aPosNext
  if aParam and aParam.shunyi then
    BubbleByHP(aPosAll, 2)
    local temp = aPosAll[1]
    for i = 1, #aPosAll do
      if aPosAll[i].dst <= 15 then
        temp = aPosAll[i]
        break
      end
    end
    if Skill:UseShunYi(temp.x, temp.y) == false then
      Skill:UseSpeed()
    else
      run = temp
    end
  elseif aParam and aParam.jiasu then
    Skill:UseSpeed()
  end
  RunTo(run.x, run.y, 0, 200)
  return run
end

local function SSS_special_boss2()
  local boss = {
    name = "庄聚贤",
    x = 68,
    y = 121,
    r = 14
  }
  local bHasSpecial = false
  local bKuangBao = false
  local bKuangBao_self = false
  local tSpecial = {}
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local keepDist = 8
    local zjx
    local tempSpec = {}
    tempSpec, bKuangBao, bKuangBao_self, zjx = SSS_get_special_boss2()
    if #tempSpec > 0 then
      tSpecial = tempSpec
    end
    if bKuangBao_self then
      bHasSpecial = true
      local param = {}
      param.shunyi = true
      param.jiasu = true
      local bPullBoss = FubenPullTarget(boss.x, boss.y, boss.r, zjx, keepDist, SSS_zjx_pullrun, param)
      debugnote = debugnote .. " 狂暴状态拉怪"
      if false == bPullBoss then
        break
      end
    else
      if not (#tempSpec > 0) then
        break
      end
      bHasSpecial = true
      do
        local param = {}
        param.useqg = false
        local bSpecSafe = FubenTrapRun("", boss.x, boss.y, 5, boss.r, tempSpec, nil, SSS_Boss2_runsafe, nil, nil, param)
        debugnote = debugnote .. " 躲避陷阱"
        if bSpecSafe then
          break
        end
      end
      goto lbl_82
      break
    end
    ::lbl_82::
    if false == bHasSpecial then
      break
    end
    Sleep(50)
    DebugStr("少室山:庄聚贤走位" .. debugnote)
  end
  return bHasSpecial, bKuangBao, bKuangBao_self, tSpecial
end

local function SSS_cdg_cb_Boss2()
  SSS_special_boss2()
  return true
end

local function sss_astar_run(aPosPath)
  local bRun = false
  local path = aPosPath
  if path and #path < 30 then
    local n = #path
    if n > 10 then
      n = 10
    end
    for i = 1, n do
      local tmp = path[i]
      if GetDist(tmp.x, tmp.y) >= 1 then
        bRun = true
        PushDebugMessage("少室山：安全移动到：" .. tmp.x .. " " .. tmp.y)
        RunTo(tmp.x, tmp.y, 0, 200)
      end
    end
  end
  return bRun
end

local function SSS_Boss2(szclass)
  local boss = {
    name = "庄聚贤",
    x = 68,
    y = 121,
    r = 14
  }
  DebugStr("少室山：" .. boss.name)
  local pos = Player:GetPos()
  if pos.y > 90 then
    MoveTo(boss.x, boss.y, -1, nil, nil, nil, SSS_callback)
    Sleep(1000)
  end
  Dismount()
  if "NPC" == szclass then
    RelivePlayer(1, nil, nil, nil, nil, true)
    FubenAttack(-1)
    MPCheck100(true)
    if Player:IsLeader() then
      CheckAllTeamHP(85, SSS_cb_hp, 45)
      local maxTime = 90
      local bCheck = true
      if m_param.not_waitzjx then
      else
        local name = ""
        bCheck, name = Team:CheckPetXueJiCD(5)
        if bCheck then
          local mpp = 40
          bCheck, name = Team:CheckMemberMP(mpp, 5)
          if false == bCheck then
            DebugStr("等待 %s 回蓝%d%%,暂不开怪! %d秒超时", 2, name, mpp, maxTime)
          end
        else
          DebugStr("等待峨嵋 %s 血祭冷却,暂不开怪! %d秒超时", 2, name, maxTime)
        end
        if -1 == m_param.time_boss2wait then
          m_param.time_boss2wait = GetTickCount()
        end
        if false == bCheck then
          DebugStr("庄聚贤:剩余 %d 秒后开启", 3, math.floor((maxTime * 1000 + m_param.time_boss2wait - GetTickCount()) / 1000))
        end
        if GetTickCount() - m_param.time_boss2wait > maxTime * 1000 then
          bCheck = true
        end
      end
      if bCheck then
        TalkNpc("庄聚贤")
        Sleep(1500)
        QuestFrameOptionClicked_Item("#{CJG_101231_375}", 1, 3000)
        MessageBox_Self_OK_Clicked()
      end
    end
    CloseWindow("Quest")
    return
  end
  CDG.call.back1 = SSS_cdg_cb_Boss2
  CDG.skill_attack_jinji_disable = " 指点江山 "
  local boss_zero = {
    x = boss.x,
    y = boss.y,
    r = 15,
    rmin = 1,
    rmax = 18,
    name = ""
  }
  TeamDispersedStations(boss_zero, 7, Team:GetMemberCount())
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("冰蚕", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if 0 == #tObj then
      tObj = Enum2XByName(" 庄聚贤 庄聚贤" .. m_param.bossNameBZ .. " ", {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
    elseif false == m_param.yxbc then
      PushColorMsg("直接干庄聚贤")
      tObj = Enum2XByName(" 庄聚贤 庄聚贤" .. m_param.bossNameBZ .. " ", {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      if 0 == #tObj then
        tObj = Enum2XByName("冰蚕", {
          0,
          1,
          0,
          0
        }, {0, -1}, nil, 0)
        PushColorMsg("目标切换到冰蚕")
      end
    end
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.name == boss.name and "NPC" == tmp.class then
        PushDebugMessage("少室山：庄聚贤变身NPC")
        DieRelive(-1)
        break
      end
      local bJinJi = false
      local bUsePet = true
      local bHasSpecial, bKuangBao, bKuangBao_self, tSpecial = SSS_special_boss2()
      if bKuangBao then
        if 4 ~= g_self.menpai then
          debugnote = debugnote .. ",狂暴时集火攻击"
          bJinJi = true
        end
        if 0 == g_self.menpai and CDG.attack and not bKuangBao_self and Player:GetHPP() > 40 then
          if tmp.dst < 8 then
            if false == Skill:UseSkillByName("灭此朝食", tmp.id, nil, nil, 200) and false == Skill:UseSkillByName("狮子吼", tmp.id, nil, nil, 200) and false == Skill:UseSkillByName("调虎离山 ", tmp.id, nil, nil, 200) then
              JinGongFarSkill(tmp.id)
            end
          else
            JinGongFarSkill(tmp.id, true)
            Skill:UseSkillByName("调虎离山", tmp.id, nil, nil, 200)
          end
        end
      end
      if bKuangBao_self then
        bUsePet = false
        if g_self.isjingong then
          JinGongFarSkill(tmp.id)
          debugnote = debugnote .. " 近攻暂时不攻击"
          local tObj = Enum2XByClass("玩家", {0, -1})
          if #tObj > 1 then
            tmp.id = -1
          end
        end
      elseif bHasSpecial and g_self.isjingong and CDG.attack and tmp.dst > 2.3 then
        JinGongFarSkill(tmp.id)
        AStarRun(boss, tmp, tSpecial, 5, nil, sss_astar_run)
        if tmp.name == "冰蚕" then
          tmp.id = -1
        end
      end
      FubenAttack(tmp.id, nil, bJinJi, true, bUsePet)
    else
      debugnote = " 寻找目标"
      FubenAttack(-1)
      Sleep(1000)
      PickUpLua()
      if SSS_IsStepOver(2) then
        SSS_SetFinishState(true, true, false, false, false)
        break
      end
    end
    Sleep(50)
    DebugStr("少室山:庄聚贤" .. debugnote)
  end
  CDG.skill_attack_jinji_disable = ""
  SSS_boss_finish(m_finish.boss2, boss)
  CDG.call.back1 = nil
end

local function SSS_Boss3_buff(tBoss)
  local bSafe = true
  local nMsgTime1 = IsInDebugMsg("CJG_101231_140")
  if nMsgTime1 and (os.time() - nMsgTime1 < 10 or Target:FindBuff(tBoss, "以彼之道还施彼身：")) then
    PushColorMsg("停手")
    bSafe = false
    if os.time() - nMsgTime1 < 3 and Player:IsLeader() then
      Player:TeamFollow(true, 700)
      Player:TeamFollow(false, 300)
    end
    StopAttack(tBoss, {x = 195, y = 86})
  end
  if bSafe then
    local nMsgTime = IsInDebugMsg("CJG_101231_141")
    if nMsgTime and (os.time() - nMsgTime < 14 or 6 == tBoss.state) then
      DebugStr("慕容复:恃强凌弱" .. tBoss.state, 2)
      bSafe = false
      if os.time() - nMsgTime < 3 and Player:IsLeader() then
        Player:TeamFollow(true, 700)
        Player:TeamFollow(false, 300)
      end
      StopAttack(tBoss, {x = 195, y = 86})
    end
  end
  return bSafe
end

local function SSS_Boss3(szclass)
  local boss = {
    name = "慕容复",
    x = 195,
    y = 86
  }
  DebugStr("少室山：" .. boss.name)
  local pos = Player:GetPos()
  if pos.x < 90 or pos.y > 105 then
    UseMount()
    MoveTo(56, 88, -1, nil, nil, nil, SSS_callback)
    Sleep(500)
  end
  pos = Player:GetPos()
  if "NPC" == szclass and pos.x < 172 then
    MoveTo(167, 85, -1, nil, nil, nil, SSS_callback)
    Sleep(500)
    SSS_Kill_Monster()
    RunTo(boss.x, boss.y, 0, 4000)
    return
  end
  SSS_Kill_Monster()
  if "NPC" == szclass then
    FubenAttack(-1)
    RelivePlayer(1, nil, nil, nil, nil, true)
    RunTo(boss.x, boss.y, 3, 1000)
    if Player:IsLeader() then
      CheckAllTeamHP(85, SSS_cb_hp, 45)
      TalkNpc(boss.name)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{CJG_101231_375}", 1, 1500)
      Sleep(1500)
      MessageBox_Self_OK_Clicked()
      CloseWindow("Quest")
    end
    return
  end
  CDG.skill_attack_jinji_disable = " 指点江山 横扫乾坤 三阳开泰 连珠腐尸毒 暗器连击 金顶绵掌 步步生花 "
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tObj > 0 then
      local tmp = tObj[1]
      local bSafe = SSS_Boss3_buff(tmp)
      local bJinJi = false
      local bCheckHP = true
      if bSafe then
        if tmp.hp < 34 then
          debugnote = " 集火攻击"
          bJinJi = true
          if 4 == g_self.menpai then
            local bHave, hpName = EnumPlayerState("镜花水月：", 2)
            if bHave then
              bCheckHP = false
              CDG:checkHP_Name(hpName, CDG.hp.cmp)
              CDG:checkHP_Pet()
            end
          end
        end
      else
        debugnote = " 暂停攻击"
        tmp.id = -1
      end
      FubenAttack(tmp.id, nil, bJinJi, bCheckHP)
    else
      debugnote = " 寻找目标"
      FubenAttack(-1, 0)
      Sleep(1000)
      PickUpLua()
      if SSS_IsStepOver(3) then
        SSS_SetFinishState(true, true, true, false, false)
        break
      end
      local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 and 0 == tObj[1].hp then
        SSS_SetFinishState(true, true, true, false, false)
        break
      end
      if false == SSS_IsStepPos(3) or RunTo(boss.x, boss.y, 0, 1000) == false then
        break
      end
    end
    Sleep(50)
    DebugStr("少室山:慕容复" .. debugnote)
  end
  SSS_boss_finish(m_finish.boss3, boss)
  CDG.skill_attack_jinji_disable = ""
end

local function SSS_Boss4_special_self()
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    if -1 == Player:GetBuff("自爆：") then
      break
    end
    local tObj = Enum2XByClass("玩家", {0, -1})
    tObj = ObjFilterByName(tObj, g_self.name, 4)
    local param = {}
    param.useqg = false
    local bSafe, tSpecial = FubenTrapRun("", 130, 127, 12, 15, tObj, nil, FubenRunSafe, nil, nil, param)
    debugnote = "需远离队友!"
    local tXue = Enum2XByName("血咒巫蛊", {
      0,
      1,
      0,
      0
    }, {0, 15}, 3, 0)
    local tBoss = Enum2XByName("丁春秋" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    local temp
    local actionID = -1
    if not m_param.ladcq and #tXue > 0 then
      temp = tXue[1]
      if false == g_self.isjingong or temp.dst <= 2 then
        actionID = temp.id
      else
        JinGongFarSkill(temp.id)
      end
    else
      if #tBoss > 0 then
        StopAttack(tBoss[1], nil)
      end
      local pet = Pet:GetSelfPet()
      if pet and 7 == pet.state then
        Pet:Relax(200)
      end
    end
    if bSafe then
      debugnote = "已远离队友!"
      FubenAttack(actionID)
    end
    Sleep(50)
    DebugStr("少室山：即将自爆 " .. debugnote)
  end
end

local function SSS_Boss4_is_special_2()
  local nMsgTime = IsInDebugMsg("CJG_101231_83")
  if nMsgTime and os.time() - nMsgTime <= 10 then
    return true
  end
  return false
end

local function SSS_Boss4_is_special_1()
  local nMsgTime = IsInDebugMsg("#{CJG_101231_82")
  if nMsgTime and os.time() - nMsgTime <= 10 then
    return true
  end
  if SSS_Boss4_is_special_2() then
    return true
  end
  return false
end

local function SSS_Boss4_mode2(nIndex, tBoss, tXue)
  local runpos = {
    {x = 110, y = 115},
    {x = 110, y = 120},
    {x = 110, y = 125},
    {x = 110, y = 130},
    {x = 110, y = 135},
    {x = 110, y = 140},
    {x = 115, y = 140},
    {x = 120, y = 140},
    {x = 125, y = 140},
    {x = 130, y = 140},
    {x = 135, y = 140},
    {x = 140, y = 140},
    {x = 145, y = 140},
    {x = 145, y = 135},
    {x = 145, y = 130},
    {x = 145, y = 125},
    {x = 145, y = 120},
    {x = 145, y = 115},
    {x = 140, y = 115},
    {x = 135, y = 115},
    {x = 130, y = 115},
    {x = 125, y = 115},
    {x = 120, y = 115},
    {x = 115, y = 115},
    {x = 115, y = 120},
    {x = 115, y = 125},
    {x = 115, y = 130},
    {x = 115, y = 135},
    {x = 120, y = 135},
    {x = 125, y = 135},
    {x = 130, y = 135},
    {x = 135, y = 135},
    {x = 140, y = 135},
    {x = 140, y = 130},
    {x = 140, y = 125},
    {x = 140, y = 120},
    {x = 135, y = 120},
    {x = 130, y = 120},
    {x = 125, y = 120},
    {x = 120, y = 120},
    {x = 120, y = 125},
    {x = 120, y = 130},
    {x = 125, y = 130},
    {x = 130, y = 130},
    {x = 135, y = 130},
    {x = 135, y = 125},
    {x = 130, y = 125},
    {x = 125, y = 125}
  }
  local attackID = -1
  if #tXue > 0 and #tBoss > 0 then
    if IsPosSafe(runpos[nIndex], tXue, 4) and IsPosSafe(tBoss[1], tXue, 4) then
      if 1 ~= nIndex and g_self.isjingong and false == SSS_Boss4_is_special_1() then
        attackID = tBoss[1].id
      elseif false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 500) and (g_self.isjingong == false or tBoss[1].dst <= 3) then
        attackID = tBoss[1].id
      end
    elseif IsPosSafe(runpos[nIndex], tXue, 4) == false or false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 500) and GetDist(runpos[nIndex].x, runpos[nIndex].y, tBoss[1].x, tBoss[1].y) <= 3 and 2 ~= tBoss[1].state then
      local bHaveSafePos = false
      for i = 1, #runpos do
        if nIndex < i and IsPosSafe(runpos[i], tXue, 4) then
          bHaveSafePos = true
          nIndex = i
          break
        end
      end
      if false == bHaveSafePos then
        nIndex = 1
        PushColorMsg("丁春秋：未找到安全坐标")
      end
      RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 1000)
    elseif false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 500) then
      if g_self.isjingong == false then
        attackID = tBoss[1].id
      else
        JinGongFarSkill(tBoss[1].id)
      end
    end
  else
    if #tBoss > 0 and false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 1000) and (g_self.isjingong == false or tBoss[1].dst <= 2) then
      attackID = tBoss[1].id
    else
    end
  end
  return nIndex, attackID
end

local function SSS_Boss4(szclass)
  local boss = {
    name = "丁春秋",
    x = 130,
    y = 126
  }
  DebugStr("少室山：" .. boss.name)
  local pos = Player:GetPos()
  if pos.x > 173 and pos.y < 115 then
    MoveTo(215, 180, -1, nil, nil, nil, SSS_callback)
    Sleep(500)
  end
  if pos.x < 173 and pos.y < 93 then
    MoveTo(56, 88, -1, nil, nil, nil, SSS_callback)
    MoveTo(boss.x, boss.y, -1, nil, nil, nil, SSS_callback)
    return
  end
  pos = Player:GetPos()
  if pos.x > 151 or pos.y > 140 then
    MoveTo(boss.x, boss.y, -1, nil, nil, nil, SSS_callback)
    Sleep(500)
  end
  SSS_Kill_Monster()
  if "NPC" == szclass then
    RelivePlayer(1, nil, nil, nil, nil, true)
    FubenAttack(-1)
    RunTo(boss.x, boss.y, 3, 1000)
    if Player:IsLeader() then
      CheckAllTeamHP(85, SSS_cb_hp, 45)
      TalkNpc(boss.name)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{CJG_101231_375}", 1, 1500)
      MessageBox_Self_OK_Clicked()
      CloseWindow("Quest")
    end
    return
  end
  local tLast = {}
  tLast.ipos = 1
  tLast.id = -1
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.skill_attack_jinji_disable = " 指点江山 "
  while FubenCheckSceneDie(m_param.sceneID) do
    CDG.pet2.GUID = bGuid2
    CDG.pet3.GUID = bGuid3
    local debugnote = ""
    local tXue = Enum2XByName("血咒巫蛊", {
      0,
      1,
      0,
      0
    }, {0, -1}, 3, 0)
    local tBoss = Enum2XByName("丁春秋" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tBoss > 0 then
      tLast.x = tBoss[1].x
      tLast.y = tBoss[1].y
    end
    SSS_Boss4_special_self()
    if #tBoss > 0 and tBoss[1].hp > 0 then
      tLast.id = -1
      local bJinJi = false
      local bUsePet = true
      if m_param.ladcq then
        tLast.ipos, tLast.id = SSS_Boss4_mode2(tLast.ipos, tBoss, tXue)
        if 4 ~= g_self.menpai and #tXue > 0 then
          debugnote = " 集火攻击"
          bJinJi = true
        end
      elseif SSS_Boss4_is_special_2() then
        if RunTo(boss.x, boss.y, 3, 1000) == false then
          local temp = tBoss[1]
          if #tXue > 0 then
            debugnote = " 攻击血咒巫蛊..."
            bUsePet = false
            if 4 ~= g_self.menpai then
              CDG.pet3.GUID = 0
            end
            CDG.pet2.GUID = 0
            bJinJi = true
            temp = tXue[1]
          end
          tLast.id = temp.id
          if g_self.isjingong and temp.dst > 3 then
            JinGongFarSkill(temp.id)
            tLast.id = -1
          end
        end
      elseif #tXue > 0 then
        debugnote = " 集火攻击血咒巫蛊"
        bUsePet = false
        if 4 ~= g_self.menpai then
          CDG.pet3.GUID = 0
        end
        CDG.pet2.GUID = 0
        bJinJi = true
        tLast.id = tXue[1].id
      elseif g_self.isjingong or TeamDispersedStations(boss, 5) then
        tLast.id = tBoss[1].id
      end
      FubenAttack(tLast.id, true, bJinJi, true, bUsePet)
    else
      debugnote = " 寻找目标"
      Sleep(500)
      PickUpLua()
      FubenAttack(-1)
      if SSS_IsStepOver(4) or #tBoss > 0 and 0 == tBoss[1].hp then
        SSS_SetFinishState(true, true, true, true, false)
        break
      end
      if not tLast.x or RunTo(tLast.x, tLast.y, 0, 1000) ~= false then
        PushDebugMessage("少室山:没有找到" .. boss.name)
      end
      do break end
      if false == SSS_IsStepPos(4) then
        PushDebugMessage("少室山:坐标范围错误：" .. boss.name)
        break
      end
    end
    Sleep(50)
    DebugStr("少室山:" .. boss.name .. debugnote)
  end
  CDG.skill_attack_jinji_disable = ""
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  local tpos = {}
  table.insert(tpos, {
    x = boss.x,
    y = boss.y
  })
  if tLast.x then
    table.insert(tpos, {
      x = tLast.x,
      y = tLast.y
    })
  end
  SSS_boss_finish(m_finish.boss4, boss, tpos)
end

local function SSS_Boss5_is_step1()
  local tAll = Enum2XByClass("NPC 怪物", {0, -1})
  local isStep = false
  for i = 1, #tAll do
    if tAll[i].class == "NPC" and tAll[i].name == "萧远山" then
      return false
    end
    if tAll[i].class == "怪物" and tAll[i].name == "慕容博" .. m_param.bossNameBZ then
      return false
    end
    if tAll[i].class == "怪物" and tAll[i].name == "萧远山" .. m_param.bossNameBZ then
      isStep = true
    end
  end
  return isStep
end

local function SSS_Boss5_is_step2()
  local tAll = Enum2XByClass("NPC 怪物", {0, -1})
  local isStep = false
  for i = 1, #tAll do
    if tAll[i].class == "NPC" and tAll[i].name == "慕容博" then
      return false
    end
    if tAll[i].class == "怪物" and tAll[i].name == "萧远山" .. m_param.bossNameBZ then
      return false
    end
    if tAll[i].class == "怪物" and tAll[i].name == "慕容博" .. m_param.bossNameBZ then
      isStep = true
    end
  end
  return isStep
end

local function SSS_Boss5_is_step3()
  local tAll = Enum2XByClass("NPC 怪物", {0, -1})
  local isBoss1_Guai, isBoss2_Guai = false, false
  local isStep = false
  for i = 1, #tAll do
    if tAll[i].name == "心魔" or tAll[i].name == "黑色心魔" or tAll[i].name == "达魔正心" then
      return true
    end
    if tAll[i].class == "怪物" and tAll[i].name == "萧远山" .. m_param.bossNameBZ then
      isBoss1_Guai = true
    end
    if tAll[i].class == "怪物" and tAll[i].name == "慕容博" .. m_param.bossNameBZ then
      isBoss2_Guai = true
    end
  end
  if isBoss1_Guai and isBoss2_Guai then
    return true
  end
  return isStep
end

local function SSS_Boss5_mrb_sl(tBoss)
  local bSafe = true
  local nID = tBoss.id
  local nMsgTime = IsInDebugMsg("SSS_ZJ_120109_37")
  if nMsgTime and os.time() - nMsgTime < 15 then
    bSafe = false
    nID = -1
    if RunTo(122, 46, 3, 1000) == false then
      nID = tBoss.id
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_xx(tBoss, nMemIndex)
  local bSafe = true
  local nID = -1
  if tBoss then
    nID = tBoss.id
  end
  local nMsgTime = IsInDebugMsg("SSS_ZJ_120109_42")
  if -1 ~= Player:GetBuff("千蛛万毒") or nMsgTime and os.time() - nMsgTime < 25 then
    nID = -1
    bSafe = false
    if RunTo(m_boss5_ZouWei[nMemIndex + 1].x, m_boss5_ZouWei[nMemIndex + 1].y, 0, 500) == false then
      if false == g_self.isjingong or tBoss and tBoss.dst < 3 then
        if tBoss then
          nID = tBoss.id
        end
      elseif tBoss then
        JinGongFarSkill(tBoss.id)
      end
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_gb(tBoss, nMemIndex)
  local bSafe = true
  local nID = tBoss.id
  local nMsgTime = IsInDebugMsg("#{SSS_ZJ_120109_39}")
  if nMsgTime and os.time() - nMsgTime < 21 then
    nID = -1
    bSafe = false
    if nMsgTime and os.time() - nMsgTime <= 5 then
      RunTo(m_boss5_ZouWei[nMemIndex + 1].x, m_boss5_ZouWei[nMemIndex + 1].y, 0, 500)
    else
      local tSpecial = {}
      table.insert(tSpecial, {
        x = tBoss.x,
        y = tBoss.y
      })
      local param = {}
      param.useqg = false
      local bSafe = FubenTrapRun("", 122, 46, 5, 12, tSpecial, nil, FubenRunSafe, nil, nil, param)
      if bSafe then
        if g_self.isjingong and tBoss.dst >= 3 then
          JinGongFarSkill(tBoss.id)
        else
          nID = tBoss.id
        end
      end
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_thd(tBoss)
  local bSafe = true
  local nID = tBoss.id
  local tObj = Enum2XByName("#{SSS_ZJ_120109_79}", {
    1,
    1,
    0,
    0
  }, nil, nil, 0)
  local tSpecial = EnumUnSafeSpecial("暴风雪陷阱")
  if #tObj > 0 then
    table.insert(tSpecial, tObj[1])
  end
  if #tSpecial > 0 then
    bSafe = false
    nID = -1
    local bSafe_run = FubenTrapRun("慕容博" .. m_param.bossNameBZ, 122, 46, 10, 15, tSpecial, nil, nil)
    if bSafe_run then
      if g_self.isjingong and tBoss.dst >= 3 then
        JinGongFarSkill(tBoss.id)
      else
        nID = tBoss.id
      end
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_cr(tBoss)
  local bSafe = true
  local nID = tBoss.id
  local tSpecial = Enum2XByName("从刃内息三刀 从刃内息预警 绝情谷内息三刀 绝情谷内息预警 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  local tSpecial2 = EnumUnSafeSpecial("三刀陷阱")
  for i = 1, #tSpecial2 do
    table.insert(tSpecial, tSpecial2[i])
  end
  if #tSpecial > 0 then
    bSafe = false
    nID = -1
    local bSafe_run = FubenTrapRun("", 122, 46, 6, 15, tSpecial, nil, nil)
    if bSafe_run then
      if g_self.isjingong and tBoss.dst >= 3 then
        JinGongFarSkill(tBoss.id)
      else
        nID = tBoss.id
      end
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_xy_mr(tBoss, nMemIndex)
  local bSafe = true
  local nID = tBoss.id
  local runpos2 = {
    {x = 122, y = 35},
    {x = 132, y = 41},
    {x = 132, y = 52},
    {x = 122, y = 57},
    {x = 112, y = 52},
    {x = 112, y = 41}
  }
  local timeDiff = 23
  local specialR = 3
  local nMsgTime = IsInDebugMsg("SSS_ZJ_120109_46")
  if not nMsgTime or os.time() - nMsgTime > 23 then
    nMsgTime = IsInDebugMsg("SSS_ZJ_120109_45")
  end
  if nMsgTime and timeDiff > os.time() - nMsgTime then
    local tSpecial = EnumUnSafeSpecial()
    bSafe = false
    nID = -1
    local run = m_boss5_ZouWei[nMemIndex + 1]
    if IsPosSafe(run, tSpecial, specialR) == false then
      local run2 = runpos2[nMemIndex + 1]
      if IsPosSafe(run2, tSpecial, specialR) then
        run = run2
      end
    end
    if FastRun(run, 5) then
      local pos = Player:GetPos()
      if false == g_self.isjingong or tBoss.dst < 3 then
        nID = tBoss.id
      else
        JinGongFarSkill(tBoss.id)
      end
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_ts(tBoss, isSafe)
  local bSafe = true
  local nID = tBoss.id
  local tObj = Enum2XByName("寒冰", {
    0,
    1,
    0,
    0
  }, {0, -1}, 1, 0)
  if #tObj > 0 then
    bSafe = false
    if isSafe then
      nID = tObj[1].id
    elseif g_self.isjingong == false then
      nID = tObj[1].id
    else
      JinGongFarSkill(tObj[1].id)
      nID = -1
    end
  elseif false == isSafe then
    bSafe = false
    nID = -1
  end
  return bSafe, nID
end

local function SSS_Boss5_mrb_gg(tBoss)
  local bSafe = true
  local nID = tBoss.id
  local run = {x = 122, y = 38}
  local tObj = Enum2XByName("#{GGSS_160905_06}", {
    0,
    1,
    0,
    0
  }, {0, -1}, 1, 0)
  if #tObj > 0 then
    bSafe = false
    nID = tObj[1].id
    if g_self.isjingong and tObj[1].dst > 4 and tBoss.target == Player:GetTID() then
      nID = -1
      if RunTo(run.x, run.y, 0, 500) == false then
        nID = tBoss.id
      end
    end
  else
    local nMsgTime = IsInDebugMsg("GGSS_160905_03")
    if nMsgTime and os.time() - nMsgTime < 21 then
      bSafe = false
      nID = -1
      if g_self.isjingong then
        run.x = 115
        run.y = 46
      end
      if RunTo(run.x, run.y, 0, 500) == false then
        if g_self.isjingong == false or tBoss.dst < 3 then
          nID = tBoss.id
        else
          JinGongFarSkill(tBoss.id)
        end
      end
    end
  end
  return bSafe, nID
end

local function SSS_Boss5_step2()
  local boss = {
    name = "慕容博",
    x = 122,
    y = 46
  }
  local isStep = SSS_Boss5_is_step2()
  if isStep then
    PushDebugMessage("boss5阶段：" .. boss.name)
    local tLast = {}
    local nMemIndex = Team:GetMyIndex()
    if nMemIndex < 0 or nMemIndex > 5 then
      math.randomseed(GetTickCount())
      nMemIndex = math.random(0, 5)
    end
    local bGuid2 = CDG.pet2.GUID
    local bGuid3 = CDG.pet3.GUID
    local tlhlTime = -1
    while FubenCheckSceneDie(m_param.sceneID) do
      CDG.pet2.GUID = bGuid2
      CDG.pet3.GUID = bGuid3
      local debugnote = ""
      local tTLNX = Enum2XByName("天龙内息", {
        1,
        0,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tTLNX > 0 then
        tlhlTime = os.time()
      end
      if #tTLNX > 0 or os.time() - tlhlTime < 6 then
        debugnote = " 天龙内息,暂不回蓝"
        CDG.pet3.GUID = 0
      end
      local tBoss = Enum2XByName("慕容博" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if 0 == #tBoss then
        while -1 ~= Player:GetBuff("千蛛万毒") do
          SSS_Boss5_mrb_xx(nil, nMemIndex)
          DebugStr("星宿陷阱")
          Sleep(100)
          tBoss = Enum2XByName(boss.name, {
            0,
            1,
            0,
            0
          }, {0, -1}, nil, 0)
          if #tBoss > 0 then
            break
          end
          PlayerStateTimeOut(2, 3)
          FubenAttack(-1)
        end
        tBoss = Enum2XByName(boss.name, {
          0,
          1,
          0,
          0
        }, {0, -1}, nil, 0)
        if 0 == #tBoss then
          PushDebugMessage("阶段5：慕容博或已脱离战斗")
          break
        end
      end
      local bSafe = true
      local bUseSkill = true
      local bJinJi = false
      if 4 ~= g_self.menpai then
        bJinJi = true
        debugnote = debugnote .. " 集火攻击"
      end
      tLast.id = -1
      bSafe, tLast.id = SSS_Boss5_mrb_xx(tBoss[1], nMemIndex)
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_ts(tBoss[1], true)
      else
        bSafe, tLast.id = SSS_Boss5_mrb_ts(tBoss[1], false)
      end
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_cr(tBoss[1])
      end
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_xy_mr(tBoss[1], nMemIndex)
      end
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_gb(tBoss[1], nMemIndex)
      end
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_thd(tBoss[1])
      end
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_sl(tBoss[1])
      end
      if bSafe then
        bSafe, tLast.id = SSS_Boss5_mrb_gg(tBoss[1])
      end
      if -1 == tLast.id then
        debugnote = debugnote .. " 内息暂不攻击"
      end
      local bUsePet = true
      if not bSafe then
        bUsePet = false
        if 4 ~= g_self.menpai then
          CDG.pet3.GUID = 0
        end
        CDG.pet2.GUID = 0
      end
      if Target:FindBuff(tBoss[1], "运气无敌状态") then
        tLast.id = -1
      end
      FubenAttack(tLast.id, bUseSkill, bJinJi, true, bUsePet)
      Sleep(50)
      if bSafe then
        if SSS_Boss5_is_step3() then
          break
        end
      else
        debugnote = debugnote .. " 正在内息."
      end
      DebugStr("阶段5:" .. boss.name .. debugnote)
    end
    CDG.pet2.GUID = bGuid2
    CDG.pet3.GUID = bGuid3
  end
  return isStep
end

local function SSS_Boss3_step3_zzx(tBoss, tZX)
  local pos = GetAveragePoint(tZX.x, tZX.y, 3, 36)
  for i = 1, 3 do
    local r = i + 3
    local tmp = GetAveragePoint(tZX.x, tZX.y, r, 36)
    local bSafe = true
    for j = 1, #tmp do
      if tmp[j].x < 105 or tmp[j].x > 142 or tmp[j].y < 33 or tmp[j].y > 60 then
        bSafe = false
        break
      end
    end
    if bSafe then
      pos = tmp
    else
      break
    end
  end
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = tBoss.name
    local tObj = Enum2XByName(tBoss.name, {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    local tFZX = FindObjByTID(tZX.id)
    if not (0 ~= #tObj and tFZX) then
      break
    end
    local buffName = tObj[1].name .. "目标"
    if -1 == Player:GetBuff(buffName) then
      break
    end
    GetAllPosDist(pos, tObj[1], "dist")
    BubbleByDist(pos, 2)
    local run = pos[1]
    if RunTo(run.x, run.y, 0, 500) == false then
      local tHSXM = Enum2XByName("黑色心魔", {
        0,
        1,
        0,
        0
      }, {0, 15}, nil, 0)
      if #tHSXM > 0 then
        DebugStr("阶段5:黑色心魔", 1)
        if false == g_self.isjingong then
          FubenAttack(tHSXM[1].id, nil, nil, true, false)
        else
          JinGongFarSkill(tHSXM[1].id)
        end
      else
        FubenAttack(-1, nil, nil, true, false)
      end
    end
    Sleep(50)
    DebugStr("阶段5:达摩正心 " .. debugnote, 2)
  end
end

local function SSS_Boss5_step3()
  local boss = {
    name = "心魔",
    x = 122,
    y = 46
  }
  local isStep = SSS_Boss5_is_step3()
  local posIdx = 1
  if isStep then
    PushDebugMessage("少室山阶段5：" .. boss.name)
    while FubenCheckSceneDie(m_param.sceneID) do
      local debugnote = ""
      local tObj = Enum2XByClass("NPC 怪物", {0, -1})
      local tXYS = ObjFilterByName(tObj, "萧远山", 1)
      local tMRB = ObjFilterByName(tObj, "慕容博", 1)
      local tXM = ObjFilterByName(tObj, "心魔", 0)
      local tHSXM = ObjFilterByName(tObj, "黑色心魔", 0)
      local tXYS_dmzx = ObjFilterByTitle(tObj, "对萧远山造成伤害", 0)
      local tMRB_dmzx = ObjFilterByTitle(tObj, "对慕容博造成伤害", 0)
      local tid = -1
      if #tXM > 0 then
        BubbleByDst(tXM, 1)
        tid = tXM[1].id
        if Target:FindBuff(tXM[1], "无敌") then
          tid = -1
        end
      end
      local bMustAttack = false
      if #tHSXM > 0 then
        bMustAttack = true
        BubbleByDst(tHSXM, 1)
        tid = tHSXM[1].id
      end
      local bSafe = true
      local bPull = false
      local keepdist = 9
      if #tXYS > 0 and -1 ~= Player:GetBuff("萧远山目标") then
        debugnote = " 拉萧远山"
        bSafe = false
        if #tXYS_dmzx > 0 then
          BubbleByDst(tXYS_dmzx, 1)
          SSS_Boss3_step3_zzx(tXYS[1], tXYS_dmzx[1])
        else
          bPull = FubenPullTarget(boss.x, boss.y, 8, tXYS[1], keepdist)
        end
      end
      if #tMRB > 0 and -1 ~= Player:GetBuff("慕容博目标") then
        debugnote = " 拉慕容博"
        bSafe = false
        if #tMRB_dmzx > 0 then
          BubbleByDst(tMRB_dmzx, 1)
          SSS_Boss3_step3_zzx(tMRB[1], tMRB_dmzx[1])
        else
          bPull = FubenPullTarget(boss.x, boss.y, 8, tMRB[1], keepdist)
        end
      end
      if bSafe then
        FubenAttack(tid)
        if -1 == tid then
          if posIdx > #m_boss5_ZouWei then
            posIdx = 1
          end
          if RunTo(m_boss5_ZouWei[posIdx].x, m_boss5_ZouWei[posIdx].y, 0, 300) == false then
            posIdx = posIdx + 1
          end
        end
      elseif false == g_self.isjingong and false == bPull then
        FubenAttack(tid, nil, nil, true, false, bMustAttack)
      else
        FubenAttack(-1, nil, nil, true, false)
      end
      if 0 == #tXM then
        local tNPC = Enum2XByName("萧远山 慕容博", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 3)
        if #tNPC > 0 then
          PushDebugMessage("阶段5：心魔阶段完成")
          break
        end
      end
      Sleep(50)
      DebugStr("阶段5心魔:" .. boss.name .. debugnote)
    end
  end
  return isStep
end

local function SSS_Boss5_step1()
  local boss = {
    name = "萧远山",
    x = 122,
    y = 46
  }
  local isStep1 = SSS_Boss5_is_step1()
  if isStep1 then
    PushDebugMessage("少室山阶段5：" .. boss.name)
    local tLast = {}
    tLast.id = -1
    tLast.x, tLast.y = boss.x, boss.y
    while FubenCheckSceneDie(m_param.sceneID) do
      local debugnote = ""
      local tBoss = Enum2XByName("萧远山" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      local nMsgTime = IsInDebugMsg("#{SSS_ZJ_120109_14}")
      nMsgTime = nMsgTime or 0
      tLast.id = -1
      if #tBoss > 0 then
        tLast.id = tBoss[1].id
        if nMsgTime and os.time() - nMsgTime < 9 then
          tLast.x = tBoss[1].x
          tLast.y = tBoss[1].y
        end
      end
      if nMsgTime and os.time() - nMsgTime < 18 and os.time() - nMsgTime > 2 then
        debugnote = " 躲避焚天灭地"
        tLast.id = -1
        local xRun, yRun = 107, 52
        if GetDist(tLast.x, tLast.y, 137, 37) >= GetDist(tLast.x, tLast.y, 107, 52) then
          xRun, yRun = 137, 37
        end
        if os.time() - nMsgTime > 6 and GetDist(xRun, yRun) > 5 then
          local run = {x = xRun, y = yRun}
          FastRun(run, 4)
        end
        if RunTo(xRun, yRun, 0, 500) == false then
          if #tBoss > 0 and tBoss[1].dst <= 15 and false == g_self.isjingong then
            tLast.id = tBoss[1].id
          end
          FubenAttack(tLast.id)
        end
      else
        FubenAttack(tLast.id)
      end
      if 0 == #tBoss and os.time() - nMsgTime > 20 or SSS_Boss5_is_step3() then
        break
      end
      Sleep(50)
      DebugStr("阶段5:" .. boss.name .. debugnote)
    end
  end
  return isStep1
end

local function SSS_Boss5(szclass)
  local boss = {
    name = "萧远山 慕容博",
    x = 122,
    y = 46
  }
  DebugStr("少室山：" .. boss.name)
  local pos = Player:GetPos()
  if "NPC" == szclass and pos.y > 67 then
    MoveTo(130, 125, -1, nil, nil, nil, SSS_callback)
    Sleep(500)
    local tObj = Enum2XByName("少林弟子", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      while #tObj > 0 and tObj[1].y > 121 do
        TalkNpc("少林弟子")
        Sleep(1000)
        if QuestFrameOptionClicked_Item("#{SSS_ZJ_120109_06}", 1, 1000) then
          MessageBox_Self_OK_Clicked()
          Sleep(1000)
          CloseWindow("Quest")
        end
        Sleep(100)
        FubenAttack(-1)
        DebugStr("少室山：对话少林弟子")
        tObj = Enum2XByName("少林弟子", {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
      end
    else
      for i = 1, 5 do
        tObj = Enum2XByName("少林弟子", {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          return
        end
        Sleep(1000)
        if IsMount() == false then
          FubenAttack(-1)
        end
      end
      PushDebugMessage("少室山：未发现少林弟子,前往藏经阁")
    end
    MoveTo(137, 37, -1, nil, nil, nil, SSS_callback)
    return
  end
  if "NPC" == szclass then
    RelivePlayer(1, nil, nil, nil, nil, true)
    FubenAttack(-1)
    RunTo(134, 37, 0, 600)
    if Player:IsLeader() then
      CheckAllTeamHP(85, SSS_cb_boss5_hp, 30)
      TalkNpc("扫地神僧")
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{SSS_ZJ_120109_11}", 1, 1200)
      MessageBox_Self_OK_Clicked()
      CloseWindow("Quest")
      Sleep(1200)
    end
    return
  end
  CDG.skill_attack_jinji_disable = " 指点江山 三阳开泰 连珠腐尸毒 "
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = "萧远山"
    local bStep = false
    bStep = SSS_Boss5_step1()
    if false == bStep then
      debugnote = "慕容博"
      bStep = SSS_Boss5_step2()
    end
    if false == bStep then
      debugnote = "心魔"
      bStep = SSS_Boss5_step3()
    end
    if false == bStep then
      debugnote = "等待剧情"
      PickUpLua()
      RelivePlayer(1, nil, nil, nil, nil, true)
      local tNPC = Enum2XByName("萧远山", {
        1,
        0,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tNPC > 0 and math.floor(tNPC[1].x) == 133 and 37 == math.floor(tNPC[1].y) then
        break
      end
      RunTo(122, 46, 3, 500)
    end
    if SSS_IsStepOver(5) then
      SSS_SetFinishState(true, true, true, true, true)
      break
    end
    if false == SSS_IsStepPos(5) then
      PushDebugMessage("少室山：坐标范围错误 " .. boss.name)
      break
    end
    local tObj = Enum2XByClass("NPC", {0, -1})
    local tXYS = ObjFilterByName(tObj, "萧远山", 1)
    local tMRB = ObjFilterByName(tObj, "慕容博", 1)
    if #tXYS > 0 and #tMRB > 0 and tXYS[1].x > 130 then
      PushDebugMessage("少室山Boss5：进度已重置")
      break
    end
    Sleep(50)
    DebugStr("少室山Boss5:" .. debugnote)
  end
  CDG.skill_attack_jinji_disable = ""
  SSS_boss_finish(m_finish.boss5, boss)
end

local function SSS_ExitScene()
  if SSS_IsStepOver(5) then
    local pos = Player:GetPos()
    if pos.y > 67 then
      MoveTo(122, 46, -1, nil, nil, nil, SSS_callback)
    else
      PickUpLua()
      RelivePlayer(2, 0, 0, 0, 0, true)
      if RunTo(120, 34, 0, 1000) == false then
        TalkNpc("扫地神僧")
        Sleep(800)
        QuestFrameOptionClicked_Item("#{CJG_101231_79}", 1, 1000)
        MessageBox_Self_OK_Clicked()
        Sleep(1500)
      end
    end
  end
end

local function SSS_OnProcess()
  SSS_GetStep()
  if m_finish.boss5 then
    SDQY_HuoDong()
    SSS_ExitScene()
    return
  end
  local tObj = Enum2XByClass("NPC 怪物")
  for i = 1, #tObj do
    local tmp = tObj[i]
    if tmp.name ~= "" and tmp.hp > 0 then
      if (tmp.name == "鸠摩智" or tmp.name == "鸠摩智" .. m_param.bossNameBZ) and tmp.y > 150 and tmp.y < 185 then
        SSS_SetFinishState(false, false, false, false, false)
        SSS_Boss1(tmp.class)
        return
      elseif tmp.name == "庄聚贤" or tmp.name == "庄聚贤" .. m_param.bossNameBZ or tmp.name == "冰蚕" then
        SSS_SetFinishState(true, false, false, false, false)
        SSS_Boss2(tmp.class)
        return
      elseif (tmp.name == "慕容复" or tmp.name == "慕容复" .. m_param.bossNameBZ) and tmp.y > 62 then
        SSS_SetFinishState(true, true, false, false, false)
        SSS_Boss3(tmp.class)
        return
      elseif tmp.name == "丁春秋" or tmp.name == "丁春秋" .. m_param.bossNameBZ or tmp.name == "血咒巫蛊" then
        SSS_SetFinishState(true, true, true, false, false)
        SSS_Boss4(tmp.class)
        return
      elseif string.find("扫地神僧 萧远山 萧远山" .. m_param.bossNameBZ .. " 慕容博 慕容博" .. m_param.bossNameBZ .. " 心魔 黑色心魔 达魔正心 少林弟子", tmp.name, nil, true) then
        for j = 1, #tObj do
          if string.find("心魔 黑色心魔 达魔正心", tObj[j].name, nil, true) then
            tmp.class = "怪物"
            break
          end
          if tObj[j].class == "怪物" and (tObj[j].name == "萧远山" or tObj[j].name == "慕容博" or tObj[j].name == "萧远山" .. m_param.bossNameBZ or tObj[j].name == "慕容博" .. m_param.bossNameBZ) then
            tmp.class = "怪物"
            break
          end
        end
        SSS_SetFinishState(true, true, true, true, false)
        SSS_Boss5(tmp.class)
        return
      end
    end
  end
  SSS_GetStep()
  if m_finish.boss4 then
    SSS_Boss5("NPC")
    return
  elseif m_finish.boss3 then
    SSS_Boss4("NPC")
    return
  elseif m_finish.boss2 then
    SSS_Boss3("NPC")
    return
  elseif m_finish.boss1 then
    SSS_Boss2("NPC")
    return
  end
  local pos = Player:GetPos()
  if pos.y > 10 and pos.y < 67 then
    PushColorMsg("少室山：根据坐标获取副本进度 5 .")
    SSS_Boss5("NPC")
    return
  end
  if m_finish.boss1 == false then
    SSS_Boss0()
  end
  local pos = Player:GetPos()
  if pos.y > 171 then
    MoveTo(130, 171, -1, 1, nil, nil, SSS_callback)
    RunTo(130, 171, 0, 1000)
  end
end

local function SSS_OnDie()
  DieRelive(0)
  local tObj = Enum2XByName(" 鸠摩智 庄聚贤 丁春秋 慕容复 萧远山 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    if SSS_IsStepOver(5) then
      return true
    end
    if tObj[1].name == "慕容复" and tObj[1].y < 67 then
      return true
    elseif tObj[1].name == "萧远山" then
      if math.floor(tObj[1].x) == 133 then
        local tMRB = Enum2XByName("慕容博", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 0)
        if #tMRB > 0 and math.floor(tMRB[1].x) == 134 then
          PushColorMsg("萧远山变成NPC,自动出窍")
          DieRelive(-1)
        else
          DebugStr("少室山:正与慕容博战斗", 2)
        end
      end
    else
      PushColorMsg("可能灭队,自动出窍.Boss恢复NPC状态:" .. tObj[1].name)
      DieRelive(-1)
    end
  else
    tObj = Enum2XByName("鸠摩智 鸠摩智" .. m_param.bossNameBZ .. " 庄聚贤 庄聚贤" .. m_param.bossNameBZ .. " 丁春秋 丁春秋" .. m_param.bossNameBZ .. " 慕容复 慕容复" .. m_param.bossNameBZ .. " 萧远山 萧远山" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if 0 == #tObj then
      return true
    end
  end
  return false
end

local function SSS_Start()
  while GetSceneID() == m_param.sceneID do
    SSS_OnProcess()
    PickUpLua()
    EatFubenItem(3)
    FuBenCheckDie(m_param.swcq, true, SSS_OnDie)
    Sleep(50)
    DebugStr("少室山：副本中", 3)
  end
end

function _SMain(...)
  local npc = {
    name = "朱丹臣",
    x = 69,
    y = 60,
    sceneID = 2
  }
  EatFubenItem(3)
  m_param.bossNameBZ = ""
  if m_param.FBType == "普通" then
    m_param.bossNameBZ = ""
    m_param.m_fb_text = "少室山"
    m_param.m_fb_next = 2
  elseif m_param.FBType == "初级" then
    m_param.bossNameBZ = "·闻恶"
    m_param.m_fb_text = "少室山·初级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "中级" then
    m_param.bossNameBZ = "·识恶"
    m_param.m_fb_text = "少室山·中级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "高级" then
    m_param.bossNameBZ = "·罚恶"
    m_param.m_fb_text = "少室山·高级"
    m_param.m_fb_next = 4
  end
  while true do
    local debugnote = ""
    if GetSceneID() == m_param.sceneID then
      SSS_Start()
      break
    elseif IsHuodongComplete(m_param.m_fb_text, m_param.m_fb_next) == false then
      Bag_DeleteItem()
      GoToScene(npc.x, npc.y, npc.sceneID)
      if Player:IsLeader() then
        if 1 == m_param.line then
          ChangeSceneLine()
        elseif 2 == m_param.line then
          ChangeScene2Line()
        end
      else
        local leader, isleader = Team:GetLeaderInfo()
        if leader and leader.sceneID == GetSceneID() then
          ChangeSceneLineID(leader.mapID)
        end
      end
      Sleep(500)
      FubenAttack(-1)
      local teamCount = HandleTextToNumber(g_config.team.count_sss, 6)
      if Player:IsLeader() and Team:IsCountReady(teamCount) then
        if IsTeamSteady() then
          TalkNpc(npc.name)
          Sleep(500)
          if m_param.FBType == "普通" then
            QuestFrameOptionClicked_Item("#{CJG_101231_70}", 1, 1500)
          elseif m_param.FBType == "初级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_06}", 1, 1500)
          elseif m_param.FBType == "中级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_48}", 1, 1500)
          elseif m_param.FBType == "高级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_07}", 1, 1500)
          end
          local strText = GetNPCEventList_Item(0)
          if string.find(strText, "#{CJG_101231_75", nil, true) then
            Sleep(1000)
            if GetSceneID() ~= m_param.sceneID then
              PushDebugMessage("您今日已经刷过少室山副本，结束！")
              break
            end
          end
        else
          debugnote = " 等待队员集合."
        end
      end
    else
      Sleep(1000)
      if GetSceneID() ~= m_param.sceneID and IsHuodongComplete(m_param.m_fb_text, m_param.m_fb_next, true) then
        PushDebugMessage("少室山:已完成")
        break
      end
    end
    Sleep(300)
    DebugStr(m_script_name .. ":等待进入副本" .. debugnote)
  end
  EatFubenItem(3)
end

RecvState(1)
_SMain()
m_param = nil
m_finish = nil
m_boss5_ZouWei = nil
ScriptOnStop(m_script_name, true)
