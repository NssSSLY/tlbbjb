-- 反编译自 dfz64.dll 内嵌字节码 004ed3ee（unluac 2025-12-23；仅供分析）
local m_param = {}
CDG.defaultCity = 1
CDG.hp.em_raid = false
local m_finish = {
  boss1 = false,
  boss2 = false,
  boss3 = false,
  boss4 = false
}
local m_start = {
  boss1 = false,
  boss2 = false,
  boss3 = false,
  boss4 = false
}
local m_pos_pqq = {
  {x = 96, y = 80},
  {x = 35, y = 87},
  {x = 84, y = 22},
  {x = 23, y = 17}
}
local m_pos_zhandou = {
  {
    xul = 84,
    yul = 77,
    xlr = 118,
    ylr = 110
  },
  {
    xul = 11,
    yul = 83,
    xlr = 44,
    ylr = 118
  },
  {
    xul = 80,
    yul = 13,
    xlr = 121,
    ylr = 53
  },
  {
    xul = 15,
    yul = 14,
    xlr = 44,
    ylr = 40
  }
}
local m_pos_boss_zero = {
  {
    x = 101,
    y = 93,
    r = 15
  },
  {
    x = 28,
    y = 100,
    r = 15
  },
  {
    x = 97,
    y = 34,
    r = 15
  },
  {
    x = 30,
    y = 27,
    r = 12
  }
}

local function SJZ_SetFinishState(boss1, boss2, boss3, boss4)
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

local function SJZ_SetStartState(boss1, boss2, boss3, boss4)
  if nil ~= boss1 then
    m_start.boss1 = boss1
  end
  if nil ~= boss2 then
    m_start.boss2 = boss2
  end
  if nil ~= boss3 then
    m_start.boss3 = boss3
  end
  if nil ~= boss4 then
    m_start.boss4 = boss4
  end
end

local function SJZ_InitData()
  SJZ_SetFinishState(false, false, false, false)
  SJZ_SetStartState(false, false, false, false)
end

local function SJZ_Boss2ToBoss3(pos)
  local posStart = {x = 36, y = 80}
  local posHalfway = {x = 60, y = 70}
  local posEnd = {x = 84, y = 55}
  local dist = 6
  local xStart = posStart.x
  local yStart = posStart.y
  local xBian = posHalfway.x - posStart.x
  local yBian = posStart.y - posHalfway.y
  local zBian = GetDist(posStart.x, posStart.y, posHalfway.x, posHalfway.y)
  for i = 0, zBian do
    local xLen = i / zBian * xBian
    local yLen = i / zBian * yBian
    local xCmp = xStart + xLen
    local yCmp = yStart - yLen
    if dist >= GetDist(xCmp, yCmp, pos.x, pos.y) then
      return true
    end
  end
  xStart = posHalfway.x
  yStart = posHalfway.y
  xBian = posEnd.x - posHalfway.x
  yBian = posHalfway.y - posEnd.y
  zBian = GetDist(posHalfway.x, posHalfway.y, posEnd.x, posEnd.y)
  for i = 0, zBian do
    local xLen = i / zBian * xBian
    local yLen = i / zBian * yBian
    local xCmp = xStart + xLen
    local yCmp = yStart - yLen
    if dist >= GetDist(xCmp, yCmp, pos.x, pos.y) then
      return true
    end
  end
  local tPos = {
    {x = 68, y = 71},
    {x = 80, y = 65},
    {x = 83, y = 61}
  }
  for i = 1, #tPos do
    local xCmp = tPos[i].x
    local yCmp = tPos[i].y
    if dist >= GetDist(xCmp, yCmp, pos.x, pos.y) then
      return true
    end
  end
  return false
end

local function SJZ_GetQuYu(pos)
  local pos_zd
  pos = pos or Player:GetPos()
  if pos.x < 10 or pos.x > 127 or pos.y < 10 or pos.y > 127 then
    PushDebugMessage("四绝庄：错误的坐标" .. pos.x .. " " .. pos.y)
    return -1
  end
  if pos.x >= 97 and pos.x < 115 and pos.y > 108 and pos.y <= 120 then
    return 0
  end
  pos_zd = m_pos_zhandou[1]
  if pos.x >= pos_zd.xul and pos.x <= pos_zd.xlr and pos.y >= pos_zd.yul and pos.y <= pos_zd.ylr then
    return 1
  end
  if pos.x >= 44 and pos.x < 79 and pos.y >= 85 and pos.y <= 103 then
    return 12
  end
  pos_zd = m_pos_zhandou[2]
  if pos.x >= pos_zd.xul and pos.x <= pos_zd.xlr and pos.y >= pos_zd.yul and pos.y <= pos_zd.ylr then
    return 2
  end
  if SJZ_Boss2ToBoss3(pos) then
    return 23
  end
  pos_zd = m_pos_zhandou[3]
  if pos.x >= pos_zd.xul and pos.x <= pos_zd.xlr and pos.y >= pos_zd.yul and pos.y <= pos_zd.ylr then
    return 3
  end
  if not (pos.x > 45 and pos.x < 80 and pos.y >= 21 and pos.y <= 61 or pos.x > 18 and pos.x < 50 and pos.y > 39 and pos.y < 60) or pos.x > 73 and pos.x < 81 and pos.y > 58 then
  else
    return 34
  end
  pos_zd = m_pos_zhandou[4]
  if pos.x >= pos_zd.xul and pos.x <= pos_zd.xlr and pos.y >= pos_zd.yul and pos.y <= pos_zd.ylr then
    return 4
  end
  PushDebugMessage("四绝庄：未识别坐标" .. pos.x .. " " .. pos.y)
  return -2
end

local function SJZ_findboss_npc(step)
  if step < 1 or step > 4 then
    return false, {}
  end
  local bossname = {
    "闵墨",
    "秦韵",
    "陶青",
    "庞企"
  }
  local tObj = Enum2XByName(bossname[step], {
    1,
    0,
    0,
    0
  }, {0, -1}, nil, 0)
  if #tObj > 0 then
    if 4 == step then
      m_start.boss4 = false
      m_finish.boss4 = true
    end
    return true, tObj[1]
  end
  return false, {}
end

local function SJZ_findboss_target()
  local tObj = Enum2XByName("闵墨" .. m_param.bossNameBZ .. " 秦韵" .. m_param.bossNameBZ .. " 陶青" .. m_param.bossNameBZ .. " 庞企" .. m_param.bossNameBZ, {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    return true, tObj[1]
  end
  return false, {}
end

local function SJZ_findboss_other(bMoHu)
  local strName = "四绝庄护卫 四绝庄教头 回音幡 青鹰 星罗武士"
  if bMoHu then
    strName = "四绝庄护卫 四绝庄教头 回音幡 青鹰 冰墨虎 火墨虎 玄墨虎 毒墨虎 星罗武士"
  end
  local tObj = Enum2XByName(strName, {
    1,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    return true
  elseif -1 ~= Player:GetBuff("烛影摇红") then
    return true
  end
  return false
end

local function SJZ_callback_quyu(fX, fY, nScene)
  DebugStr("四绝庄：移动到%d,%d", 2, math.ceil(fX), math.ceil(fY))
  PickUpLua()
  if GetSceneID() ~= m_param.sceneID or 9 == Player:GetState() then
    return false
  end
  local pos = {x = fX, y = fY}
  local qy1 = SJZ_GetQuYu(pos)
  local qy2 = SJZ_GetQuYu()
  if qy1 < 5 then
    if 12 == qy2 then
      qy2 = 2
    elseif 23 == qy2 then
      qy2 = 3
    elseif 34 == qy2 then
      qy2 = 4
    end
  end
  if qy1 ~= qy2 then
    PushColorMsg("四绝庄:区域与移动坐标不匹配")
    return false
  end
  if SJZ_findboss_target() or SJZ_findboss_other(true) then
    PushDebugMessage("四绝庄:寻路时发现目标")
    return false
  end
  return true
end

local function SJZ_boss1_CDG_cb()
  local pos_zero = m_pos_boss_zero[1]
  local bSafe, tSpecial = FubenTrapRun("闵墨" .. m_param.bossNameBZ, pos_zero.x, pos_zero.y, 7, 14, nil, nil, FubenRunSafe)
  return bSafe, tSpecial
end

local function SJZ_Boss1_QiaoZhong_YG()
  local ShunYiID = -1
  if 3 == g_self.menpai then
    ShunYiID = 379
  elseif 8 == g_self.menpai then
    ShunYiID = 524
  elseif 11 == g_self.menpai then
    ShunYiID = 2904
  end
  if m_param.boss1qiaozhong and -1 ~= ShunYiID then
    PushDebugMessage("四绝庄:队内无近攻,当前门派可以敲钟")
    for i = 1, 10 do
      if Pet:Relax() and Dismount() then
        break
      end
      Sleep(100)
    end
    Sleep(500)
    for i = 1, 5 do
      if RunTo(101, 110, 0, 800) == false then
        break
      end
    end
    Sleep(500)
    for i = 1, 7 do
      local pos = Player:GetPos()
      if pos.y < 100 then
        if false == Skill:UseName("初级隐遁", 150) then
          break
        end
      else
        Skill:UseSkillByID(ShunYiID, -1, 103, 96, 350)
      end
      Sleep(100)
    end
    RunTo(102, 80, 0, 300)
    local nowTick = GetTickCount()
    while GetTickCount() - nowTick < 5000 do
      local tObj = Enum2XByName("四绝钟", {
        1,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        if tObj[1].hp > 0 then
          Target:Attack(tObj[1].id)
        else
          break
        end
      elseif RunTo(102, 80, 0, 300) == false then
        break
      end
      Sleep(500)
    end
    return true
  end
  return false
end

local function SJZ_Boss1_QiaoZhong()
  local pos = m_pos_pqq[1]
  if m_param.boss1qiaozhong and g_self.isjingong then
    if -1 == Player:GetBuff("隐身") then
      Dismount()
      if Pet:Relax(100) == false then
        return
      end
      RunTo(100, 114, 2, 1000)
      TalkNpc("潘菁菁", 500)
      QuestFrameOptionClicked_Item("#{YXJJ_091118_19}", 1, 600)
    else
      Pet:Relax()
      Sleep(200)
      RunTo(102, 80, 0, 1500)
    end
    return
  end
  local isHaveJinGong = false
  local isHaveYuanGongShunYi = false
  if Team:IsHaveMenpai("少林") or Team:IsHaveMenpai("丐帮") or Team:IsHaveMenpai("明教") or Team:IsHaveMenpai("天山") or Team:IsHaveMenpai("慕容") then
    isHaveJinGong = true
  end
  if false == isHaveJinGong then
    if SJZ_Boss1_QiaoZhong_YG() then
      return
    elseif Team:IsHaveMenpai("武当") or Team:IsHaveMenpai("逍遥") or Team:IsHaveMenpai("唐门") then
      isHaveYuanGongShunYi = true
    end
  end
  if false == isHaveJinGong and false == isHaveYuanGongShunYi then
    PushColorMsg("Boss1:无可敲钟门派")
    RunTo(pos.x, pos.y, 3, 1500)
    return
  end
  CDG.hp.em_target_dist = 5
  FubenAttack(-1)
  CDG.hp.em_target_dist = 16
  local nDiff = GetChangeSceneTimeDiff()
  if nDiff > 35 then
    PushDebugMessage("Boss1:35秒内没有完成敲钟,出动！")
    RunTo(pos.x, pos.y, 3, 1500)
  else
    DebugStr(fmt("Boss1:等待敲钟,剩余%d秒", 35 - math.floor(nDiff)))
  end
end

local function SJZ_Boss1_step0()
  local tObj = Enum2XByName("潘菁菁", {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  local bHavePqq = false
  if #tObj > 0 then
    bHavePqq = true
  end
  local bNextBoss = false
  if false == bHavePqq then
    local tTeam = Team:GetAllMemberInfo()
    for i = 1, #tTeam do
      local nQY = SJZ_GetQuYu(tTeam[i])
      if 12 == nQY or 2 == nQY or 23 == nQY or 3 == nQY or 34 == nQY or 4 == nQY then
        bNextBoss = true
        break
      end
    end
    if bNextBoss then
      PushDebugMessage("Boss1已完成,前往下个boss")
    else
      for i = 1, 6 do
        tObj = Enum2XByName("潘菁菁", {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          bHavePqq = true
          break
        end
        Sleep(1000)
        PushDebugMessage("Boss1:寻找门口潘菁菁")
        if IsInDebugMsgTime("SJZ_100129_31", nil, 50) then
          PushDebugMessage("Boss1:敲钟成功")
          break
        end
      end
    end
  end
  if bHavePqq then
    SJZ_SetFinishState(false, false, false, false)
    SJZ_SetStartState(false, false, false, false)
    SJZ_Boss1_QiaoZhong()
  else
    local pos = m_pos_pqq[1]
    RunTo(pos.x, pos.y, 0, 1500)
  end
end

local function SJZ_Boss1_step1_xiaoguai()
  local tObj = Enum2XByName("四绝钟", {
    1,
    1,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 and tObj[1].hp > 0 then
    Target:Attack(tObj[1].id, 300)
    return true
  end
  if -1 ~= Player:GetBuff("隐身") then
    if RunTo(102, 80, 0, 1500) == false then
      Player:DispelBuffByName("隐身")
    end
    return true
  end
  tObj = Enum2XByName("四绝庄护卫 四绝庄教头", {
    0,
    1,
    0,
    0
  }, {0, -1}, 1, 3)
  if #tObj > 0 then
    FubenAttack(tObj[1].id)
    DebugStr("Boss1:打小怪")
    return true
  end
  return false
end

local function SJZ_FindBoss(step)
  if SJZ_GetQuYu() ~= step then
    PushDebugMessage("四绝庄:找boss时范围不符%d" .. step, SJZ_GetQuYu())
    return false
  end
  local pos_zero = m_pos_boss_zero[step]
  local radius = 5
  if 3 == step then
    radius = 7
  end
  local pos = GetAveragePoint(pos_zero.x, pos_zero.y, radius, 6, 0)
  local idxPos = 1
  local isFind = false
  local debugnote = ""
  while FubenCheckSceneDie(m_param.sceneID) do
    debugnote = ""
    local bIsRun = true
    if idxPos > #pos then
      PushDebugMessage("四绝庄:没有发现boss" .. step)
      break
    end
    if SJZ_GetQuYu() ~= step then
      break
    end
    local bFind, tmp = SJZ_findboss_npc(step)
    if false == bFind then
      bFind, tmp = SJZ_findboss_target()
    end
    if bFind then
      RunTo(tmp.x, tmp.y, 0, 500)
    else
      bFind = SJZ_findboss_other(false)
    end
    if bFind then
      isFind = true
      break
    end
    if 1 == step or 4 == step then
      local bSafe, tSpecial = FubenTrapRun("", pos_zero.x, pos_zero.y, 7, 13, nil, nil, FubenRunSafe)
      if #tSpecial > 0 then
        debugnote = " 有陷阱暂时不移动"
        bIsRun = false
      end
    end
    if bIsRun then
      if false == IsMount() then
        FubenAttack(-1)
      end
      debugnote = "," .. pos[idxPos].x .. " " .. pos[idxPos].y
      RunTo(pos[idxPos].x, pos[idxPos].y, 0, 500)
    else
      CDG:checkHP(true)
    end
    if GetDist(pos[idxPos].x, pos[idxPos].y) < 2 then
      debugnote = debugnote .. " 换点"
      idxPos = idxPos + 1
    end
    PickUpLua()
    DebugStr("正在寻找boss" .. step .. " " .. idxPos .. debugnote)
    Sleep(100)
  end
  PickUpLua()
  return isFind
end

local function SJZ_Boss_step(step)
  local pos = m_pos_pqq[step]
  local pos_zd = m_pos_zhandou[step]
  local key = "boss" .. step
  local debugnote = ""
  CloseWindow("Quest")
  if 1 == step then
    if SJZ_Boss1_step1_xiaoguai() then
      return
    end
  elseif 4 == step then
    IsWindowVisible("AnimationPass", "AnimationPass_OnClick()")
  end
  if false == m_start[key] then
    debugnote = ",准备开怪"
    if RunTo(pos.x, pos.y, 3, 600) then
      return
    end
  end
  if m_finish[key] then
    EatFubenItem(3)
    if 1 == step then
      local bSafe, tSpecial = SJZ_boss1_CDG_cb()
      if #tSpecial > 0 then
        PushDebugMessage("Boss1:已结束,周围有陷阱！")
        if bSafe then
          local bHasBag = SafeRunToPickBag(m_pos_boss_zero[1], tSpecial, 7)
        end
        FubenAttack(-1)
        return
      end
    end
    PushDebugMessage("Boss" .. step .. ": 已完成")
    local nDiff = GetChangeSceneTimeDiff()
    if nDiff > 30 then
      PickUpLua_Boss(30, 15, m_param.sceneID)
    else
      PickUpLua()
    end
    RelivePlayer(2, pos_zd.xul, pos_zd.yul, pos_zd.xlr, pos_zd.ylr, true)
    PickUpLua()
    MoveToNPC("潘菁菁", pos.x, pos.y, -1, nil, nil, nil, SJZ_callback_quyu)
  end
  if false == m_start[key] or m_finish[key] then
    TalkNpc("潘菁菁", 700)
  end
  local strItem = GetNPCEventListAllItem()
  if QuestFrameOptionClicked_Item("#{SJZYH_150824_4}", 1) then
  elseif QuestFrameOptionClicked_Item("#{SJZYH_150824_3}", 1) then
  elseif QuestFrameOptionClicked_Item("#{SJZYH_150824_2}", 1) then
  elseif FindQuestFrameOption("#{SJZYH_150824_1}") or FindQuestFrameOption("#{SJZYH_150824_5}") or FindQuestFrameOption("#{SJZYH_150824_6}") then
    if 1 == step then
      SJZ_SetFinishState(false, false, false, false)
    elseif 2 == step then
      ClearDbgMsg()
      SJZ_SetFinishState(true, false, false, false)
    elseif 3 == step then
      SJZ_SetFinishState(true, true, false, false)
    elseif 4 == step then
      SJZ_SetFinishState(true, true, true, false)
    end
    FubenAttack(-1)
    if 2 == step or Player:IsLeader() then
      local nDist = 15
      if 2 == step then
        nDist = 32
      end
      if IsTeamSteady(nDist) then
        local function _sjz_cb_hp_fuben()
          if GetSceneID() ~= m_param.sceneID then
            return false
          end
          return not SJZ_findboss_target()
        end
        
        CheckAllTeamHP(85, _sjz_cb_hp_fuben, 30)
        if 4 == step then
          QuestFrameOptionClicked_Item("#{SJZYH_150824_5}", 1, 1000)
          QuestFrameOptionClicked_Item("#{SJZYH_150824_6}", 1, 800)
        else
          QuestFrameOptionClicked_Item("#{SJZYH_150824_1}", 1)
        end
      end
    end
  else
    local nIndex, idMission, idScript = GetPlayerMission_Item(m_param.missionName)
    local bShiBai = FindQuestFrameOption("#{SJZ_100129_62}")
    local bossPickPos
    if 4 == step and 1 == GetMissionComplete(nIndex) then
      local pos_zero = m_pos_boss_zero[step]
      bossPickPos = GetAveragePoint(pos_zero.x, pos_zero.y, 5, 6, 0)
    elseif false == m_finish[key] and false == SJZ_FindBoss(step) then
      debugnote = debugnote .. " 未找到boss"
      m_finish[key] = true
    end
    DebugStr("Boss step " .. step .. ":" .. debugnote, 2)
    if 4 == step and (1 == GetMissionComplete(nIndex) or bShiBai) then
      if bShiBai then
        PushColorMsg("四绝庄：任务已失败！")
      else
        PushDebugMessage("四绝庄：任务已完成！")
      end
      Sleep(500)
      SDQY_HuoDong()
      RelivePlayer(2, pos_zd.xul, pos_zd.yul, pos_zd.xlr, pos_zd.ylr, true)
      PickUpLua_Boss(30, 15, m_param.sceneID, bossPickPos)
      PickUpLua()
      EatFubenItem(3)
      MoveToNPC("潘菁菁", pos.x, pos.y, -1, nil, nil, nil, SJZ_callback_quyu)
      Sleep(400)
      PickUpLua()
      QuestFrameOptionClicked_Item("#{SJZ_100129_120}", 1, 600)
      if bShiBai then
        QuestFrameOptionClicked_Item("#{YXJJ_091118_19}", 1, 300)
      end
    end
  end
  Sleep(200)
end

local function SJZ_ZhanShen(step, tObj, tSpecial)
  if 0 == #tObj then
    return
  end
  local tmp = tObj[1]
  local pos_zero = m_pos_boss_zero[step]
  if m_param.xiaohao and 0 == #tSpecial then
    if tmp.target == Player:GetTID() then
      PushDebugMessage("小号:boss目标是自己,隐身")
      Skill:UseName("初级隐遁", 500)
    end
    if 1 == step or 3 == step then
      local b1, t1 = FubenTrapRun("", pos_zero.x, pos_zero.y, 7, pos_zero.r, tObj, nil, FubenRunSafe_easy)
      if false == b1 then
        DebugStr("小号:远离boss" .. step, 2)
      end
    end
  end
end

local function SJZ_Boss1()
  CDG.call.back1 = SJZ_boss1_CDG_cb
  local bossname = "闵墨 闵墨" .. m_param.bossNameBZ
  local step = 1
  local pos_zero = m_pos_boss_zero[step]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local bSafe, tSpecial = FubenTrapRun(bossname, pos_zero.x, pos_zero.y, 7, 14, nil, nil, FubenRunSafe)
    local tObj = Enum2XByName(bossname, {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if 0 == #tObj and 0 == #tSpecial then
      PushDebugMessage("没有找到Boss" .. step)
      break
    end
    SJZ_ZhanShen(step, tObj, tSpecial)
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.class == "NPC" then
        AStarRun(pos_zero, tmp, tSpecial, 7)
        FubenAttack(-1)
        break
      elseif g_self.isjingong and #tSpecial > 0 then
        if tmp.dst < 3 then
          FubenAttack(tmp.id)
        else
          debugnote = "近攻有陷阱"
          if m_param.xiaohao == false then
            AStarRun(pos_zero, tmp, tSpecial, 7)
          end
          FubenAttack(-1)
        end
      else
        if -1 ~= tmp.id and m_param.zhidian then
          ZhiDianJiangShan(tmp, false)
        end
        FubenAttack(tmp.id)
      end
    else
      debugnote = "有陷阱"
      FubenAttack(-1)
    end
    DebugStr("四绝庄：boss" .. step .. " " .. debugnote)
    Sleep(50)
  end
  CDG.call.back1 = nil
end

local function SJZ_Boss2_HYF_3to4(tHYF)
  if 3 ~= #tHYF then
    return tHYF
  end
  local pos1 = {
    x = tHYF[1].x,
    y = tHYF[1].y
  }
  local pos2 = {}
  for i = 1, #tHYF do
    if tHYF[i].x ~= pos1.x then
      pos2.x = tHYF[i].x
    end
    if tHYF[i].y ~= pos1.y then
      pos2.y = tHYF[i].y
    end
  end
  if pos2.x and pos2.y then
    local tPos = {}
    table.insert(tPos, {
      x = pos1.x,
      y = pos1.y
    })
    table.insert(tPos, {
      x = pos1.x,
      y = pos2.y
    })
    table.insert(tPos, {
      x = pos2.x,
      y = pos1.y
    })
    table.insert(tPos, {
      x = pos2.x,
      y = pos2.y
    })
    return tPos
  end
  return tHYF
end

local function SJZ_Boss2_HYF_safe(aOnlyCheckPos)
  local step = 2
  local pos_zero = m_pos_boss_zero[step]
  local safePos = {}
  local safeHyfDist = 9
  local runpos = {
    {x = 41, y = 87},
    {x = 16, y = 87}
  }
  if m_param.boss2diagonal then
    runpos = {
      {x = 41, y = 87},
      {x = 16, y = 114}
    }
  end
  runpos[1].dst = GetDist(runpos[1].x, runpos[1].y)
  runpos[2].dst = GetDist(runpos[2].x, runpos[2].y)
  local tHYF = Enum2XByName("回音幡", {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  tHYF = SJZ_Boss2_HYF_3to4(tHYF)
  if 0 == #tHYF then
    return true, {}
  end
  if aOnlyCheckPos then
    return IsPosSafe(aOnlyCheckPos, tHYF, safeHyfDist)
  end
  if IsPosSafe(runpos[1], tHYF, safeHyfDist) then
    table.insert(safePos, runpos[1])
    if 4 == #tHYF then
      return false, safePos
    end
    if 2 == #tHYF and tHYF[1].x ~= tHYF[2].x and tHYF[1].x < pos_zero.x and tHYF[2].x < pos_zero.x and IsInDebugMsgTime("SJZ_100129_50", nil, 6) then
      return false, safePos
    end
  end
  if IsPosSafe(runpos[2], tHYF, safeHyfDist) then
    table.insert(safePos, runpos[2])
  end
  BubbleByDst(safePos)
  return false, safePos
end

local function SJZ_Boss2_HYF()
  local safedist = 15
  if g_self.isjingong then
    safedist = 3
  end
  local bSafe, safepos = SJZ_Boss2_HYF_safe()
  if false == bSafe then
    local nowTick = GetTickCount()
    while FubenCheckSceneDie(m_param.sceneID) do
      local bCheck = SJZ_Boss2_HYF_safe(safepos[1])
      local issafe, tpos = SJZ_Boss2_HYF_safe()
      if false == bCheck then
        PushDebugMessage("前往安全坐标")
        if #tpos > 0 then
          safepos = tpos
        end
      end
      if issafe and GetTickCount() - nowTick > 12000 then
        break
      end
      if #safepos > 0 then
        safepos[1].dst = GetDist(safepos[1].x, safepos[1].y)
        FastRun(safepos[1], 4)
        if false == RunTo(safepos[1].x, safepos[1].y, 0, 800) then
          local tObj = Enum2XByName("秦韵 秦韵" .. m_param.bossNameBZ, {
            1,
            1,
            0,
            0
          }, nil, nil, 3)
          if #tObj > 0 and safedist >= tObj[1].dst then
            break
          end
          FubenAttack(-1)
        end
        DebugStr("Boss2:等待其接近%d,移动到%s,%s", 2, #safepos, safepos[1].x, safepos[1].y)
      else
        DebugStr("Boss2:回音幡", 2)
      end
      Sleep(100)
    end
  end
  return bSafe
end

local function SJZ_Boss2_get_zyyh_safe_pos()
  local startPos = {x = 16, y = 114}
  local runpos = {}
  if m_param.xiaohao then
    startPos = {x = 43, y = 104}
    for i = 1, 10 do
      runpos[i] = {}
      runpos[i].x = startPos.x
      runpos[i].y = startPos.y + i - 1
      runpos[i].dst = GetDist(runpos[i].x, runpos[i].y)
    end
  else
    for i = 1, 25 do
      runpos[i] = {}
      runpos[i].x = startPos.x + i - 1
      runpos[i].y = startPos.y
      runpos[i].dst = GetDist(runpos[i].x, runpos[i].y)
    end
  end
  local tHYF = Enum2XByClass("玩家", {0, -1})
  Player:GetName()
  tHYF = ObjFilterByName(tHYF, g_self.name, 2)
  local safePos = {}
  for j = 1, #runpos do
    if IsPosSafe(runpos[j], tHYF, 6) then
      table.insert(safePos, runpos[j])
    end
  end
  BubbleByDst(safePos)
  return safePos
end

local function SJZ_Boss2_ZYYH()
  local debugnote = ""
  while FubenCheckSceneDie(m_param.sceneID) do
    debugnote = ""
    StateRemoveBad(true, false, false, false, false)
    if -1 == Player:GetBuff("烛影摇红") then
      break
    end
    Pet:Relax(100)
    if false ~= SJZ_Boss2_HYF_safe() then
      local safepos = SJZ_Boss2_get_zyyh_safe_pos()
      if #safepos > 0 then
        local tObj = Enum2XByName("秦韵 秦韵" .. m_param.bossNameBZ, {
          1,
          1,
          0,
          0
        }, nil, nil, nil)
        if #tObj > 0 and tObj[1].target == Player:GetTID() then
          Skill:UseName("初级隐遁", 300)
        end
        FastRun(safepos[1], 4)
        if false == RunTo(safepos[1].x, safepos[1].y, 0, 600) then
          FubenAttack(-1)
        end
      else
        debugnote = ",没有找到安全坐标"
        if m_param.xiaohao then
          RunTo(43, 87)
        else
          RunTo(16, 87)
        end
      end
    else
      break
    end
    Sleep(50)
    DebugStr("Boss2:躲避烛影摇红" .. debugnote, 2)
  end
end

local function SJZ_Boss2_CDG_cb()
  if -1 ~= Player:GetBuff("烛影摇红") then
    return false
  end
  local bSafe, safepos = SJZ_Boss2_HYF_safe()
  if false == bSafe and #safepos > 0 then
    FastRun(safepos[1], 4)
    if RunTo(safepos[1].x, safepos[1].y, 0, 800) then
      return false
    end
  end
  return true
end

local function SJZ_Boss2_zhanshen()
  local debugnote = "等待,可设置为大号分担失明！"
  local runpos = {x = 62, y = 102}
  if m_param.boss2xhfd then
    debugnote = "分担失明"
    runpos = {x = 43, y = 104}
  end
  if m_param.xiaohao then
    while FubenCheckSceneDie(m_param.sceneID) and not IsInDebugMsg("SJZ_100129_50") and not IsInDebugMsg("SJZ_100129_51") do
      local tObj = Team:GetAllMemberInfo()
      for i = 1, #tObj do
        if tObj[i].y > 5 and tObj[i].y < 75 then
          PushDebugMessage("Boss2:已完成,队员在其他区域")
          return
        end
      end
      SJZ_Boss2_ZYYH()
      tObj = Enum2XByName("秦韵 秦韵" .. m_param.bossNameBZ, {
        1,
        1,
        0,
        0
      }, nil, nil, 3)
      SJZ_ZhanShen(2, tObj, {})
      if RunTo(runpos.x, runpos.y, 1, 1000) == false then
        FubenAttack(-1)
      end
      if 12 ~= SJZ_GetQuYu() and 2 ~= SJZ_GetQuYu() then
        break
      end
      Sleep(50)
      DebugStr("Boss2:小号" .. debugnote)
    end
    if 12 == SJZ_GetQuYu() then
      local pos = m_pos_pqq[2]
      FastRun(pos, 4)
      RunTo(pos.x, pos.y, 0, 600)
    end
  end
end

local function SJZ_Boss2()
  CDG.call.back1 = SJZ_Boss2_CDG_cb
  local bossname = "秦韵 秦韵" .. m_param.bossNameBZ
  local step = 2
  local pos_zero = m_pos_boss_zero[step]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    SJZ_Boss2_ZYYH()
    SJZ_Boss2_zhanshen()
    local bSafe = SJZ_Boss2_HYF()
    local tObj = Enum2XByName(bossname, {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if bSafe and 0 == #tObj then
      PushDebugMessage("没有找到Boss" .. step)
      break
    end
    SJZ_ZhanShen(step, tObj, {})
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.class == "NPC" then
        RunTo(tmp.x, tmp.y, 0, 1000)
        break
      end
      if (tmp.x > pos_zero.x - 3 or tmp.y > pos_zero.y - 3) and m_param.xiaohao == false and Player:GetTID() == tmp.target and not IsInDebugMsg("SJZ_100129_50") and not IsInDebugMsg("SJZ_100129_51") then
        debugnote = "拉boss"
        tmp.id = -1
        RunTo(16, 87, 0, 1000)
      end
      if -1 ~= tmp.id and m_param.zhidian then
        ZhiDianJiangShan(tmp, false)
      end
      FubenAttack(tmp.id)
    end
    DebugStr("四绝庄：boss" .. step .. " " .. debugnote)
    Sleep(50)
  end
  CDG.call.back1 = nil
end

local function SJZ_Boss3()
  local debugnote = ""
  local bossname = "陶青" .. m_param.bossNameBZ
  local step = 3
  local pos_zero = m_pos_boss_zero[step]
  local attackAttr = Player:GetAttackAttr()
  while FubenCheckSceneDie(m_param.sceneID) do
    debugnote = ""
    local bQingYing = false
    local tObj = Enum2XByName("青鹰", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    GetAllPosDist(tObj, pos_zero)
    BubbleByDst(tObj, 1)
    if 0 == #tObj then
      tObj = Enum2XByName("冰墨虎 火墨虎 玄墨虎 毒墨虎", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      if #tObj > 0 then
        local tBoss = Enum2XByName(bossname, {
          1,
          1,
          0,
          0
        }, {0, -1}, nil, 3)
        if 0 == #tBoss then
          PushDebugMessage("发现墨虎,没有发现boss")
          break
        end
      end
    else
      bQingYing = true
    end
    if 0 == #tObj then
      tObj = Enum2XByName(bossname, {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
    end
    if 0 == #tObj then
      PushDebugMessage("没有找到Boss" .. step)
      break
    end
    local tmp = tObj[1]
    for j = 1, #attackAttr do
      local bOver = false
      for i = 1, #tObj do
        if tObj[i].name == attackAttr[j].name .. "墨虎" then
          tmp = tObj[i]
          bOver = true
          break
        end
      end
      if bOver then
        break
      end
    end
    local bMustAttack = false
    if tmp.name == bossname then
      if Target:FindBuff(tmp, "青鹰的守护") then
        FubenTrapRun("", pos_zero.x, pos_zero.y, 7, 18, tObj, nil, FubenRunSafe)
        debugnote = "青鹰的守护,远离boss"
        tmp.id = -1
      elseif Target:FindBuff(tmp, "天罡护体") then
        debugnote = ",青鹰出现"
        RunTo(91, 45, 3, 800)
        tmp.id = -1
      elseif tmp.class == "NPC" then
        RunTo(tmp.x, tmp.y, 0, 1000)
        break
      end
      if -1 ~= tmp.id and m_param.zhidian then
        ZhiDianJiangShan(tmp, false)
      end
    elseif string.find("青鹰 冰墨虎 火墨虎 玄墨虎 毒墨虎", tmp.name, nil, true) then
      bMustAttack = true
    end
    if bQingYing and tmp.id > -1 then
      TargetAttack(tmp.id, false)
    else
      FubenAttack(tmp.id, nil, nil, nil, nil, bMustAttack)
    end
    DebugStr("四绝庄：boss" .. step .. " " .. debugnote)
    Sleep(50)
  end
end

local function SJZ_Boss4_longzhu()
  local nowtick = GetTickCount()
  local pos_longzhu = {
    {x = 41, y = 31},
    {x = 41, y = 31},
    {x = 18, y = 31},
    {x = 18, y = 31},
    {x = 29, y = 19}
  }
  local timeout = 8
  local longzhu = {}
  local tmp = {
    msgtime = -1,
    msg = "",
    tick = -1
  }
  for i = 1, 5 do
    tmp.msgtime, tmp.msg, tmp.tick = IsInDebugMsg(fmt("SJZ_100129_7%d", 2 + i))
    if tmp.msgtime and timeout > os.time() - tmp.msgtime then
      table.insert(longzhu, {
        dst = tmp.msgtime,
        x = pos_longzhu[i].x,
        y = pos_longzhu[i].y
      })
    end
  end
  BubbleByDst(longzhu, 2)
  return longzhu
end

local function SJZ_Boss4_teamOK(startTick)
  local debugnote = ""
  if -1 ~= startTick and GetTickCount() - startTick > 60000 then
    return true
  end
  local pos_zero = m_pos_boss_zero[4]
  local pos_Range = m_pos_zhandou[4]
  local bOK = true
  local bDie, szDieName = Team:IsHaveDieMember()
  if bDie then
    debugnote = "有队员死亡!"
    if -1 == startTick then
      for i = 1, 10 do
        if Pet:Relax() then
          break
        end
      end
    end
    bOK = false
  end
  if bOK and Team:GetSurroundMember(14) < Team:GetMemberCount() then
    debugnote = "等待队员集中!"
    bOK = false
    if -1 == startTick then
      for i = 1, 10 do
        if Pet:Relax() then
          break
        end
      end
    end
  end
  RelivePlayer(2, pos_Range.xul, pos_Range.yul, pos_Range.xlr, pos_Range.ylr, true)
  if RunTo(pos_zero.x, pos_zero.y, 0, 1000) then
    debugnote = "移动到中心"
    bOK = false
  end
  if false == bOK then
    if -1 == startTick then
      startTick = GetTickCount()
    end
    local diff = math.ceil((60000 - (GetTickCount() - startTick)) / 1000)
    if 7 == Player:GetState() then
      Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 500)
    end
    DebugStr("boss4:检查复活队员%d秒后超时," .. debugnote, 2, diff)
  end
  return bOK
end

local function SJZ_Boss4_CDG_cb()
  local bossname = "庞企" .. m_param.bossNameBZ
  local pos_zero = m_pos_boss_zero[4]
  local bSafe, tSpecial = FubenTrapRun(bossname, pos_zero.x, pos_zero.y, 6, pos_zero.r, nil, nil, FubenRunSafe)
  return bSafe, tSpecial
end

local function SJZ_Boss4()
  CDG.call.back1 = SJZ_Boss4_CDG_cb
  local bossname = "庞企" .. m_param.bossNameBZ
  local step = 4
  local pos_zero = m_pos_boss_zero[step]
  local nIndex = Team:GetMyIndex()
  local runpos = {
    {x = 33, y = 22},
    {x = 37, y = 27},
    {x = 35, y = 33},
    {x = 23, y = 33},
    {x = 22, y = 26},
    {x = 22, y = 26}
  }
  if g_self.isjingong == false then
    runpos = {
      {x = 30, y = 27},
      {x = 32, y = 28},
      {x = 32, y = 31},
      {x = 27, y = 31},
      {x = 27, y = 28},
      {x = 28, y = 27}
    }
  end
  local startWaitTick = -1
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("星罗武士", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if 0 == #tObj then
      tObj = Enum2XByName(bossname, {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
    end
    local longzhu = SJZ_Boss4_longzhu()
    local bSafe, tSpecial = SJZ_Boss4_CDG_cb()
    if 0 == #tSpecial and 0 == #tObj and 0 == #longzhu then
      PushDebugMessage("没有找到Boss" .. step)
      break
    end
    if bSafe then
      if #tObj > 0 then
        local bJinJiSkill = false
        local bMustAttack = false
        local bCheckMP = true
        local bXiaoGuai = false
        if "星罗武士" == tObj[1].name then
          bXiaoGuai = true
          bCheckMP = false
          bJinJiSkill = true
          debugnote = ",甩技能"
          bMustAttack = true
          if g_self.isjingong then
            Skill:UseSpeed()
          end
          if 8 == g_self.menpai and false == m_param.xiaohao then
            Skill:UseName("定海神针", 300)
            Skill:UseName("步步生花", 300)
          end
          CDG.skill_attack_jinji_disable = " 暗器连击 "
          if tObj[1].dst < 6 and 4 == g_self.menpai then
            Skill:UseName("月落西山", 300)
          end
          if g_self.isjingong then
            GetAllPosDist(tObj)
            BubbleByDst(tObj, 1)
            if tObj[1].dst > 5 then
              JinGongFarSkill(tObj[1].id)
            else
            end
          end
        elseif tObj[1].hp > 80 then
          CDG.skill_attack_jinji_disable = "横扫乾坤 真武七截阵 三阳开泰 连珠腐尸毒 三环套月 七星聚首 玉碎昆岗 万箭齐发 天女散花 太上忘情 绝星阵·七杀 暗器连击"
        else
          CDG.skill_attack_jinji_disable = ""
        end
        local tmp = tObj[1]
        if tmp.name == bossname then
          if tmp.hp > 90 and g_self.isjingong == false then
            local pos = runpos[nIndex + 1]
            if pos then
              RunTo(pos.x, pos.y, 0, 2000)
            end
          end
          local tLongZhu = Enum2XByName("金龙柱 木龙柱 水龙柱 火龙柱 土龙柱", {
            1,
            0,
            0,
            0
          }, {0, -1}, nil, 3)
          if tmp.hp > 60 and 0 == #tLongZhu then
            bJinJiSkill = true
            debugnote = "龙柱未出现,甩技能"
          end
          if 0 == #tSpecial and m_param.boss4longzhu and #longzhu > 0 and RunTo(longzhu[1].x, longzhu[1].y, 0, 1000) then
            debugnote = ",拉到龙柱处"
            tmp.id = -1
          end
          if Target:FindBuff(tmp, "天罡护体") then
            tmp.id = -1
            debugnote = ",小怪即将出现"
            local pos = runpos[nIndex + 1]
            if pos then
              RunTo(pos.x, pos.y, 0, 1000)
            end
          elseif Target:FindBuff(tmp, "四绝之怒") then
            if -1 == startWaitTick then
              if false == SJZ_Boss4_teamOK(-1) then
                tmp.id = -1
              end
              startWaitTick = GetTickCount()
            end
            if false == SJZ_Boss4_teamOK(startWaitTick) then
              tmp.id = -1
            end
          elseif tmp.class == "NPC" then
            RunTo(tmp.x, tmp.y, 0, 1000)
            break
          end
          if #tSpecial > 0 then
            if g_self.isjingong then
              if tmp.dst > 2 then
                tmp.id = -1
                debugnote = debugnote .. ",有陷阱近攻暂时不打"
              end
            elseif tmp.dst > 15 then
              tmp.id = -1
              debugnote = debugnote .. ",有陷阱 Boss距离过远"
            end
          end
          if -1 ~= tmp.id and m_param.zhidian then
            ZhiDianJiangShan(tmp, false)
          end
        end
        if bXiaoGuai and tmp.id > -1 then
          TargetAttack(tmp.id, true)
        else
          FubenAttack(tmp.id, nil, bJinJiSkill, bCheckMP, nil, bMustAttack)
        end
      end
    else
      debugnote = ",躲避陷阱"
    end
    DebugStr("四绝庄：boss" .. step .. " " .. debugnote)
    Sleep(50)
  end
  CDG.call.back1 = nil
end

local function SJZ_OnProcess()
  IsWindowVisible("AnimationPass", "AnimationPass_OnClick()")
  local tAll = Enum2XByName("闵墨 闵墨" .. m_param.bossNameBZ .. " 秦韵 秦韵" .. m_param.bossNameBZ .. " 回音幡 陶青 陶青" .. m_param.bossNameBZ .. " 青鹰 庞企 庞企" .. m_param.bossNameBZ .. " 星罗武士", {
    1,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  local tObj = {}
  for i = 1, #tAll do
    if 4 == SJZ_GetQuYu(tAll[i]) and (tAll[i].name == "闵墨" or tAll[i].name == "闵墨" .. m_param.bossNameBZ or tAll[i].name == "秦韵" or tAll[i].name == "秦韵" .. m_param.bossNameBZ or tAll[i].name == "陶青" or tAll[i].name == "陶青" .. m_param.bossNameBZ) then
    else
      table.insert(tObj, tAll[i])
    end
  end
  if #tObj > 0 then
    local tmp = tObj[1]
    PushDebugMessage("四绝庄：发现目标 " .. tmp.name .. " " .. tmp.class)
    if tmp.class == "NPC" then
      if tmp.name == "庞企" then
        SJZ_SetFinishState(true, true, true, false)
        SJZ_SetStartState(true, true, true, false)
      elseif tmp.name == "陶青" then
        SJZ_SetFinishState(true, true, true, nil)
        SJZ_SetStartState(true, true, true, nil)
      elseif tmp.name == "秦韵" then
        SJZ_SetFinishState(true, true, nil, nil)
        SJZ_SetStartState(true, true, nil, nil)
      elseif tmp.name == "闵墨" then
        SJZ_SetFinishState(true, nil, nil, nil)
        SJZ_SetStartState(true, nil, nil, nil)
      elseif tmp.name == "回音幡" then
        SJZ_SetFinishState(true, false, false, false)
        SJZ_SetStartState(true, true, false, false)
        SJZ_Boss2()
        return
      end
    elseif tmp.name == "庞企" or tmp.name == "庞企" .. m_param.bossNameBZ or tmp.name == "星罗武士" then
      SJZ_SetFinishState(true, true, true, false)
      SJZ_SetStartState(true, true, true, true)
      SJZ_Boss4()
      return
    elseif tmp.name == "陶青" or tmp.name == "青鹰" or tmp.name == "陶青" .. m_param.bossNameBZ then
      SJZ_SetFinishState(true, true, false, false)
      SJZ_SetStartState(true, true, true, false)
      SJZ_Boss3()
      return
    elseif tmp.name == "秦韵" or tmp.name == "秦韵" .. m_param.bossNameBZ or tmp.name == "回音幡" then
      SJZ_SetFinishState(true, false, false, false)
      SJZ_SetStartState(true, true, false, false)
      SJZ_Boss2()
      return
    elseif tmp.name == "闵墨" or tmp.name == "闵墨" .. m_param.bossNameBZ then
      SJZ_SetFinishState(false, false, false, false)
      SJZ_SetStartState(true, false, false, false)
      SJZ_Boss1()
      return
    end
  end
  local step = SJZ_GetQuYu()
  if 0 == step then
    SJZ_Boss1_step0()
  elseif 1 == step then
    SJZ_Boss_step(1)
  elseif 2 == step then
    SJZ_Boss_step(2)
  elseif 3 == step then
    SJZ_Boss_step(3)
  elseif 4 == step then
    SJZ_Boss_step(4)
  end
  local pos = m_pos_pqq[1]
  if 12 == step then
    PushDebugMessage("四绝庄：移动到boss2")
    pos = m_pos_pqq[2]
    SJZ_Boss2_zhanshen()
    MoveToNPC("潘菁菁", pos.x, pos.y, -1, nil, nil, nil, SJZ_callback_quyu)
  elseif 23 == step then
    PushDebugMessage("四绝庄：移动到boss3")
    pos = m_pos_pqq[3]
    MoveToNPC("潘菁菁", pos.x, pos.y, -1, nil, nil, nil, SJZ_callback_quyu)
  elseif 34 == step then
    PushDebugMessage("四绝庄：移动到boss4")
    pos = m_pos_pqq[4]
    MoveToNPC("潘菁菁", pos.x, pos.y, -1, nil, nil, nil, SJZ_callback_quyu)
  elseif step < 0 or step > 4 then
    PushDebugMessage("四绝庄：错误的进度" .. step)
  end
end

function SJZ_Start(aParam)
  m_param = aParam
  g_pick.check = true
  SJZ_InitData()
  while GetSceneID() == m_param.sceneID do
    SJZ_OnProcess()
    FuBenCheckDie(m_param.swcq, true)
    Sleep(50)
    DebugStr("四绝庄：副本进行中", 3)
  end
  PushDebugMessage("四绝庄:已经离开副本")
end
