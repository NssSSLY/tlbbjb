-- 反编译自 dfz64.dll 内嵌字节码 00313c18（unluac 2025-12-23；仅供分析）
local m_script_name = "讨伐燕子坞"
ScriptOnStart(m_script_name, true, true)
local m_param = {}
m_param.xiaohao = GetConfigBool("副本", "小号模式")
m_param.swcq = ReadConfigBool("ZH", "xzk121")
m_param.kaguai = not ReadConfigBool("ZH", "xzk215")
m_param.killwyy = ReadConfigBool("ZH", "xzk119")
m_param.btxd_safe = false
m_param.missionName = "讨伐燕子坞"
m_param.sceneName = "燕子坞"
m_param.sceneID = 236
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk137"), 6)
m_param.FBType = ReadConfigText("ZH", "yzw_type")
g_pick.check = true
g_pick.pickmode = 0
CDG.hp.em_raid = false
local m_private = {die_wyy = false}
local m_npc = {
  [0] = {
    name = "李纲",
    x = 70,
    y = 120,
    sceneID = 4
  },
  [1] = {
    name = "呼延豹",
    x = 79,
    y = 203,
    sceneID = 236
  },
  [2] = {
    name = "钱宏宇",
    x = 217,
    y = 150,
    sceneID = 236
  },
  [3] = {
    name = "华赫艮",
    x = 180,
    y = 88,
    sceneID = 236
  }
}

local function YZW_IsStep3Pos(aPos)
  local pos = aPos or Player:GetPos()
  if pos.x > 165 or pos.y > 135 then
    return false
  end
  if pos.x > 10 and pos.y > 10 then
    return true
  end
  return false
end

local function YZW_IsStep3()
  local tTeam = Team:GetAllMemberInfo()
  for i = 1, #tTeam do
    if YZW_IsStep3Pos(tTeam[i]) then
      return true
    end
  end
  return false
end

local function YZW_GetStep()
  local nDiff = GetChangeSceneTimeDiff()
  if nDiff < 45 then
    return 1
  end
  if nDiff > 86400 then
    nDiff = 86400
  end
  local nMsgTime4 = IsInDebugMsg("慕容复已被打败")
  local nMsgTime3 = IsInDebugMsg("警惕！第9拨燕子坞援军已经赶至，还有0拨燕子坞援军即将赶来。")
  local nMsgTime3_1 = IsInDebugMsg("燕子坞;王语嫣")
  local nMsgTime3_2 = IsInDebugMsg("鸠摩智被打败，其手下纷纷四散逃窜。")
  local nMsgTime2 = IsInDebugMsg("请迅速赶至阻截点协助钱宏宇将军阻击反贼援军")
  local nMsgTime2_1 = IsInDebugMsg("警惕！第")
  local nMsgTime1 = IsInDebugMsg("请各位大侠速速前往水军旗舰保护他")
  local tObj = {}
  if nMsgTime3 and nMsgTime3 > os.time() - nDiff then
    tObj = Enum2XByName("木人傀儡 秦家寨亲兵 姚伯当" .. m_param.bossNameBZ .. " 青城派弟子 司马林" .. m_param.bossNameBZ .. " 吐蕃喇嘛 鸠摩智" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, {0, -1}, 1, 3)
  end
  local nRet = -1
  if nMsgTime4 and nMsgTime4 > os.time() - nDiff then
    nRet = 4
  elseif nMsgTime3 and nMsgTime3 > os.time() - nDiff and 0 == #tObj then
    nRet = 3
  elseif nMsgTime3_1 and nMsgTime3_1 > os.time() - nDiff then
    nRet = 3
  elseif nMsgTime3_2 and nMsgTime3_2 > os.time() - nDiff then
    nRet = 3
  elseif nMsgTime2 and nMsgTime2 > os.time() - nDiff then
    nRet = 2
  elseif nMsgTime2_1 and nMsgTime2_1 > os.time() - nDiff then
    nRet = 2
  elseif nMsgTime1 and nMsgTime1 > os.time() - nDiff then
    nRet = 1
  end
  if 3 ~= nRet and 4 ~= nRet and YZW_IsStep3() then
    PushColorMsg("有队员在慕容复")
    nRet = 3
  end
  return nRet
end

local function YZW_step2_Start()
  local nMsgTime1 = IsInDebugMsg("请迅速赶至阻截点协助钱宏宇将军阻击反贼援军")
  local nMsgTime2 = IsInDebugMsg("警惕！")
  if nMsgTime1 and nMsgTime2 and nMsgTime1 < nMsgTime2 then
    return true
  end
  return false
end

local function YZW_step2_Over()
  local nDiff = GetChangeSceneTimeDiff()
  if nDiff > 86400 then
    nDiff = 86400
  end
  local nMsgTime2 = IsInDebugMsg("鸠摩智被打败，其手下纷纷四散逃窜。请大家速速从暗道处深入燕子坞内部，击杀逆贼慕容复。")
  if nMsgTime2 and nMsgTime2 > os.time() - nDiff then
    return true
  end
  return false
end

local function YZW_callback_run_step12(fX, fY, nScene)
  DebugStr("段延庆、鸠摩智阶段移动 %d,%d", 2, math.ceil(fX), math.ceil(fY))
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  if YZW_IsStep3Pos() then
    return false
  end
  return true
end

local function YZW_callback_run_step3(fX, fY, nScene)
  DebugStr("慕容复阶段：移动%d,%d", 2, math.ceil(fX), math.ceil(fY))
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  if false == YZW_IsStep3Pos() then
    return false
  end
  return true
end

local function YZW_callback_HP_step1()
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  local nStep = YZW_GetStep()
  if 1 ~= nStep then
    return false
  end
  local tObj = Enum2XByName(" 岳老三" .. m_param.bossNameBZ .. " 云中鹤" .. m_param.bossNameBZ .. " 段延庆" .. m_param.bossNameBZ .. " ", {
    1,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    return false
  end
  return true
end

local function YZW_callback_HP_step3()
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  local nStep = YZW_GetStep()
  if 3 ~= nStep then
    return false
  end
  local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 0)
  if #tObj > 0 then
    return false
  end
  return true
end

local function YZW_NPC_HP(npcName)
  if 4 == g_self.menpai then
    local tNPC = Enum2XByName(npcName, {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tNPC > 0 and tNPC[1].hp < 80 and tNPC[1].hp > 0 then
      Skill:UseSkillByName("清心普善咒", tNPC[1].id, -1, -1, 700)
    end
  end
end

local function YZW_NPC_Protect(tMonster, npcName)
  local isProtect = false
  if g_self.isjingong == false then
    local tNPC = Enum2XByName(npcName, {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tNPC > 0 then
      for i = 1, #tMonster do
        if tMonster[i].target == tNPC[1].id then
          FubenAttack(tMonster[i].id)
          isProtect = true
          break
        end
      end
    end
  end
  return isProtect
end

local function YZW_step3_bsqf()
  local bBuff = Pet:CheckBuff("就擒：无法使用")
  if bBuff then
    PushColorMsg("珍兽中毒收回")
    Pet:Relax(300)
  end
  if -1 ~= Player:GetBuff("就擒：无法使用") then
    TempBank2Bag("悲酥清风解药", 0)
    Sleep(100)
    local tItem = Bag:FindItemInfo("悲酥清风解药")
    if #tItem > 0 then
      Bag:ItemBtnClicked(tItem[1].index)
      Sleep(300)
    else
      return false
    end
  end
  return true
end

local function YZW_step_zhanshen(aStep)
  if m_param.xiaohao then
    while FubenCheckSceneDie(m_param.sceneID) do
      local debugnote = ""
      if Player:IsLeader() then
        local tMem = Team:GetHPMostMember()
        if tMem and tMem.name ~= g_self.name then
          PushColorMsg("站神换队长")
          TeamChangeLeader(-1, tMem.name)
          Sleep(1000)
        end
      end
      local nowStep = YZW_GetStep()
      if 1 == aStep then
        if 1 ~= nowStep then
          local npc = m_npc[1]
          PickUpLua()
          MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
          break
        else
          MoveTo(94, 181, m_param.sceneID, nil, nil, nil, YZW_callback_run_step12)
          debugnote = "在此等待捡包"
        end
      elseif 2 == aStep then
        debugnote = " 二阶"
        PickUpLua()
      elseif 3 == aStep then
        PickUpLua()
        if false == YZW_IsStep3Pos() then
          break
        end
        if 3 ~= nowStep then
          MoveTo(49, 89, -1, nil, nil, nil, YZW_callback_run_step3)
          break
        else
          MoveTo(37, 85, -1, nil, nil, nil, YZW_callback_run_step3)
          YZW_step3_bsqf()
          debugnote = " 打慕容复 在此等待捡包"
        end
      end
      Sleep(80)
      DebugStr("燕子坞：小号模式" .. debugnote)
    end
    return true
  end
  return false
end

local function YZW_step2_waitteam()
  TickInitTeamSteady()
  while FubenCheckSceneDie(m_param.sceneID) and 2 == YZW_GetStep() and false == YZW_IsStep3Pos() do
    DebugStr("燕子坞：卡怪等待队员集合.")
    MoveTo(198, 156, m_param.sceneID, 1, nil, nil, YZW_callback_run_step12)
    if IsTeamSteady(9) then
      break
    end
    FubenAttack(-1)
    Sleep(50)
  end
end

local function YZW_OnStep1()
  local thisStep = 1
  local npc = m_npc[1]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    if false == YZW_step_zhanshen(thisStep) then
      local tObj = Enum2XByName("岳老三" .. m_param.bossNameBZ .. " 云中鹤" .. m_param.bossNameBZ .. " 段延庆" .. m_param.bossNameBZ, {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      YZW_NPC_HP("呼延豹")
      if #tObj > 0 then
        local tmp = tObj[1]
        ZhiDianJiangShanObj(tObj[1], false)
        if tmp.name == "段延庆" and tmp.hp < 50 then
          Skill:UseKongZhi_fuben(tmp, true, true)
          FubenAttack(tmp.id, true, true)
          debugnote = ",集火攻击段延庆"
        else
          FubenAttack(tmp.id)
        end
      else
        local nStep = YZW_GetStep()
        if 1 == nStep then
          MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
          if IsTeamSteady(27) then
            CheckAllTeamHP(85, YZW_callback_HP_step1, 30)
            QuestFrameOptionClicked_Item("战斗吧！", 1, 500)
            if not g_self.isjingong then
              local mov = {x = 83, y = 203}
              TeamDispersedStations(mov, 4)
              Sleep(600)
              PlayerStateTimeOut(2, 5)
            end
          else
            FubenAttack(-1)
            debugnote = ",等待队员集合"
          end
          Sleep(1000)
          CloseWindow("Quest")
        else
          break
        end
      end
    else
      break
    end
    Sleep(50)
    DebugStr("燕子坞：段延庆 " .. debugnote)
  end
  local nTick = GetTickCount()
  while FubenCheckSceneDie(m_param.sceneID) and YZW_GetStep() > 1 and false == YZW_IsStep3Pos() do
    LootFilter_clear()
    Bag_DeleteItem()
    local _, _, nAll, bPick = PickUpLua(nil, true)
    RelivePlayer(1, nil, nil, nil, nil, true)
    EatBindItem(3, " 段延庆的宝箱 段延庆的宝藏 段延庆的宝箱·遗 ")
    local tItem = Bag:FindItemInfo("悲酥清风解药")
    if not (not (#tItem > 0) or bPick) and GetTickCount() - nTick > 5000 then
      break
    end
    do
      local tJN = Bag:EnumTempBagItem()
      tItem = Bag:FindItemInfo("悲酥清风解药", nil, nil, tJN)
      if not (not (#tItem > 0) or bPick) and GetTickCount() - nTick > 5000 then
        break
      end
    end
    if GetDist(npc.x, npc.y) > 8 then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
    end
    if 0 == nAll and GetTickCount() - nTick > 15000 then
      break
    end
    Sleep(50)
    DebugStr("燕子坞：段延庆捡包")
  end
  if FubenCheckSceneDie(m_param.sceneID) and YZW_GetStep() > 1 and false == YZW_IsStep3Pos() then
    for i = 1, 3 do
      PickUpLua()
      Sleep(500)
    end
  end
  if m_param.kaguai and 2 == YZW_GetStep() and Player:IsLeader() then
    PushColorMsg("队长卡怪")
    YZW_step2_waitteam()
  end
end

local function YZW_step2_mode_kill()
  local npc = m_npc[2]
  local xBattle, yBattle = 224, 168
  if m_param.xiaohao then
    xBattle = 220
    yBattle = 158
  end
  local nlastfindtime = -1
  UseMount()
  while FubenCheckSceneDie(m_param.sceneID) and false == YZW_IsStep3Pos() do
    local debugnote = ""
    YZW_NPC_HP(npc.name)
    local nStep = YZW_GetStep()
    if nStep > 3 then
      PushDebugMessage("前往慕容复阶段")
      break
    end
    if YZW_step2_Start() or not Player:IsLeader() then
      local tObj = Enum2XByName("木人傀儡 秦家寨亲兵 姚伯当" .. m_param.bossNameBZ .. " 青城派弟子 司马林" .. m_param.bossNameBZ .. " 吐蕃喇嘛 鸠摩智" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, {0, -1}, 1, 3)
      local isProtect = YZW_NPC_Protect(tObj, npc.name)
      local pos = Player:GetPos()
      if false == isProtect and pos.y > 175 then
        RunTo(xBattle, yBattle, 0, 3000)
      end
      if #tObj > 0 then
        nlastfindtime = -1
        if false == isProtect then
          FubenAttack(tObj[1].id)
        else
          debugnote = ",需保护钱宏宇"
        end
      else
        if 3 == nStep then
          if YZW_step2_Over() then
            PushDebugMessage("鸠摩智已完成")
            if m_param.xiaohao then
              RunTo(224, 168, 0, 1000)
              PlayerStateTimeOut(2, 6)
            end
            for i = 1, 5 do
              PickUpLua()
              Sleep(500)
            end
            RelivePlayer(1, nil, nil, nil, nil, true)
            for i = 1, 5 do
              PickUpLua()
              Sleep(500)
            end
            break
          end
          if -1 == nlastfindtime then
            nlastfindtime = GetTickCount()
          end
          if GetTickCount() - nlastfindtime > 35000 then
            PushColorMsg("未发现鸠摩智,去慕容复处 ")
            break
          else
            FubenAttack(-1)
            PickUpLua()
          end
          RelivePlayer(1, nil, nil, nil, nil, true)
        else
          RunTo(xBattle, yBattle, 0, 1000)
          PlayerStateTimeOut(2, 10)
          FubenAttack(-1)
        end
        RunTo(xBattle, yBattle, 0, 1000)
      end
      debugnote = "杀怪中"
    else
      debugnote = "队长开怪"
      if 3 == nStep then
        PushColorMsg("未开怪：怪物,第3阶段已开始")
        break
      end
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
      Sleep(600)
      QuestFrameOptionClicked_Item("战斗吧！", 1, 1000)
    end
    if YZW_IsStep3() then
      PushColorMsg("燕子坞：结束打怪,队友已经前往慕容复处！")
      break
    end
    DebugStr("燕子坞：鸠摩智 " .. debugnote)
    Sleep(50)
  end
end

local function YZW_step2_xiaoguai()
  local nSort = 0
  if g_self.isjingong then
    nSort = 1
  end
  local tObj = Enum2XByName("木人傀儡 秦家寨亲兵 姚伯当" .. m_param.bossNameBZ .. " 青城派弟子 司马林" .. m_param.bossNameBZ .. " 吐蕃喇嘛 鸠摩智" .. m_param.bossNameBZ, {
    0,
    1,
    0,
    0
  }, {0, -1}, 1, 3)
  if #tObj > 0 then
    FubenAttack(tObj[1].id)
    Sleep(200)
    return true
  end
  return false
end

local function YZW_step2_kaguai_leader()
  local npc = m_npc[2]
  while FubenCheckSceneDie(m_param.sceneID) and false == YZW_IsStep3() do
    local debugnote = ""
    YZW_NPC_HP(npc.name)
    if 2 ~= YZW_GetStep() then
      PushDebugMessage("钱宏宇阶段完成")
      return
    end
    if YZW_step2_Start() then
      MoveTo(227, 181, -1, nil, nil, nil, YZW_callback_run_step12)
      local tObj = Enum2XByClass(" 怪物 ", {0, 15}, 1)
      local nTickOut = GetTickCount()
      while 0 == #tObj or tObj[1].dst > 4 do
        Sleep(200)
        tObj = Enum2XByClass(" 怪物 ", {0, 15}, 1)
        DebugStr("燕子坞：等待援军接近")
        if GetTickCount() - nTickOut > 30000 then
          PushColorMsg("燕子坞：等待援军超时1")
          break
        end
      end
      MoveTo(217, 150, -1, 1, false, nil, YZW_callback_run_step12)
      tObj = Enum2XByClass(" 怪物 ", {0, 15}, 1)
      nTickOut = GetTickCount()
      while 0 == #tObj or tObj[1].dst > 6 do
        Sleep(200)
        tObj = Enum2XByClass(" 怪物 ", {0, 15}, 1)
        DebugStr("燕子坞：等待援军接近2.")
        if GetTickCount() - nTickOut > 30000 then
          PushColorMsg("燕子坞：等待援军超时2")
          break
        end
      end
      MoveTo(182, 172, -1, nil, false, nil, YZW_callback_run_step12)
      nTickOut = GetTickCount()
      ::lbl_150::
      tObj = Enum2XByName(npc.name, {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        break
      end
      FubenAttack(-1)
      do
        local diff = GetTickCount() - nTickOut
        if diff > 12000 then
          break
        end
        DebugStr(fmt("钱宏宇:等待其接近,%d秒后超时,卡怪失败后将自动阻截", 12 - math.floor(diff / 1000)))
        Sleep(100)
      end
      goto lbl_150
      break
    else
      debugnote = "队长开怪中"
      UseMount()
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
      Sleep(600)
      QuestFrameOptionClicked_Item("战斗吧！", 1, 1000)
      if false == YZW_step2_Start() then
        Sleep(1000)
      end
    end
    DebugStr("燕子坞：阶段二" .. debugnote)
    Sleep(50)
  end
  while FubenCheckSceneDie(m_param.sceneID) and 2 == YZW_GetStep() do
    debugnote = ""
    local isAttack = true
    local tTmp = Enum2XByName(npc.name, {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tTmp > 0 then
      if tTmp[1].dst > 3 then
        RunTo(tTmp[1].x, tTmp[1].y, 0, 1000)
        debugnote = "前往" .. npc.name
      else
        isAttack = YZW_step2_xiaoguai()
      end
      YZW_NPC_HP(npc.name)
      TalkNpc(npc.name)
      Sleep(500)
    else
      FubenAttack(-1)
      isAttack = YZW_step2_xiaoguai()
    end
    if #tTmp > 0 then
      if false == isAttack then
        if tTmp[1].dst <= 3 then
          break
        end
      else
        debugnote = ",发现npc、正在清怪"
      end
    elseif false == isAttack then
      if false == RunTo(196, 156, 0, 1000) then
        Sleep(4000)
        tTmp = Enum2XByName(npc.name, {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if 0 == #tTmp then
          PushColorMsg("未发现钱宏宇,队长卡怪失败,自动阻截!")
          YZW_step2_mode_kill()
          break
        else
        end
      end
    else
      debugnote = ",未发现钱宏宇,清理小怪"
    end
    Sleep(100)
    DebugStr("燕子坞：队长卡怪中" .. debugnote)
  end
end

local function YZW_step2_kaguai_member()
  local npc = m_npc[2]
  MoveTo(198, 156, m_param.sceneID, 1, nil, nil, YZW_callback_run_step12)
  local debugnote = ""
  local nlasttick = -1
  while FubenCheckSceneDie(m_param.sceneID) and false == YZW_IsStep3() do
    local isAttack = false
    local tTmp = Enum2XByName(npc.name, {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tTmp > 0 then
      YZW_NPC_HP(npc.name)
      local pos = Player:GetPos()
      if pos.x > 198 then
        RunTo(198, 156, 0, 500)
      end
      if tTmp[1].x <= 200 and tTmp[1].dst > 3 then
        RunTo(tTmp[1].x, tTmp[1].y, 0, 500)
      end
      if tTmp[1].x <= 200 then
        TalkNpc(npc.name)
        Sleep(200)
        if tTmp[1].dst <= 3 then
          isAttack = YZW_step2_xiaoguai()
        end
      end
    else
      RunTo(198, 156, 0, 2000)
    end
    FubenAttack(-1)
    if 2 ~= YZW_GetStep() then
      break
    end
    if YZW_step2_Start() then
      if -1 == nlasttick then
        nlasttick = GetTickCount()
      end
      local diff = GetTickCount() - nlasttick
      if false == isAttack and diff > 60000 then
        break
      end
      local nTemp = 60 - math.floor(diff / 1000)
      debugnote = "卡怪中," .. nTemp .. " 秒后超时,如果失败将自动阻截"
    else
      debugnote = "等待队长开怪."
    end
    DebugStr("钱宏宇队员：" .. debugnote)
    Sleep(100)
  end
  local tTmp = Enum2XByName(npc.name, {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  if 0 == #tTmp then
    PushColorMsg("队员卡怪失败,自动阻截")
    YZW_step2_mode_kill()
  end
end

local function YZW_step3_wait_step2()
  local npc = m_npc[3]
  local nTickOut = GetTickCount()
  while FubenCheckSceneDie(m_param.sceneID) and false == YZW_IsStep3Pos() do
    if GetDist(npc.x, npc.y) > 15 then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
    end
    local bTalk = false
    local nStep = YZW_GetStep()
    if 1 == nStep then
      PushColorMsg("燕子坞：过通道时阶段错误 1")
      break
    elseif 2 == nStep then
      GivePlayerState("冰肌玉骨", 7, false)
      local nDiff = GetChangeSceneTimeDiff()
      if nDiff > 86400 then
        nDiff = 86400
      end
      local nMsgTime2 = IsInDebugMsg("警惕！第8拨")
      if nMsgTime2 and nMsgTime2 > os.time() - nDiff then
        UseMount()
        bTalk = true
      else
        FubenAttack(-1)
        if GetTickCount() - nTickOut > 30000 then
          nTickOut = GetTickCount()
          bTalk = true
        end
      end
    else
      bTalk = true
    end
    if bTalk then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, YZW_callback_run_step12)
      Sleep(500)
      QuestFrameOptionClicked_Item("从地道进入燕子坞", 1, 1000)
    end
    DebugStr("燕子坞：在通道口等待进入地道")
    Sleep(1000)
  end
end

local function YZW_OnStep2()
  if GetDist(180, 90) > 20 then
    if m_param.kaguai then
      if Player:IsLeader() then
        YZW_step2_kaguai_leader()
      else
        YZW_step2_kaguai_member()
      end
    else
      YZW_step2_mode_kill()
    end
  else
    PushColorMsg("当前在慕容复入口处")
  end
  YZW_step3_wait_step2()
end

local function YZW_step3_btxd_runpos(xNpc, yNpc, bIsKeepDist)
  local xRun = 49
  local yMin, yMax = 69, 93
  local safedist = 10
  if bIsKeepDist then
    safedist = 7
    yMin = 75
    yMax = 89
  end
  local pos = Player:GetPos()
  local safepos = {}
  for i = 1, yMax - yMin do
    if safedist <= GetDist(xRun, yMin + i, xNpc, yNpc) then
      local dist = GetDist(pos.x, pos.y, xRun, yMin + i)
      table.insert(safepos, {
        x = xRun,
        y = yMin + i,
        dst = dist
      })
    end
  end
  BubbleByDst(safepos, 1)
  return safepos
end

local function YZW_step3_btxd()
  if m_param.btxd_safe then
    return true
  end
  local safedist = 10
  local nMsgTime, szMsgText, nMsgTick = IsInDebugMsg("YZW_MRF_SKILL_BTXD:")
  if nMsgTime and os.time() - nMsgTime < 5 then
    local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    local _, _, fX, fY = string.find(szMsgText, "(%d+%.?%d+),(%d+%.?%d+)")
    local xNpc, yNpc = 0, 0
    if 0 == #tObj then
      xNpc = tonumber(fX)
      yNpc = tonumber(fY)
      if nil == xNpc or nil == yNpc then
        PushDebugMessage("冰天雪地坐标参数错误！")
        return false
      else
        PushColorMsg("冰天雪地:坐标[%d,%d]", math.ceil(xNpc), math.ceil(yNpc))
      end
    else
      xNpc = tObj[1].x
      yNpc = tObj[1].y
    end
    if safedist > GetDist(xNpc, yNpc) then
      local safepos = YZW_step3_btxd_runpos(xNpc, yNpc, false)
      if #safepos > 0 then
        local runpos = safepos[1]
        for i = 1, 12 do
          if YZW_step3_bsqf() then
            if 4 == g_self.menpai and GetDist(xNpc, yNpc) < 5 then
              Skill:UseName("呆若木鸡", 500)
            end
            FastRun(runpos, 4)
          end
          if 3 == Player:GetState() then
            Sleep(400)
          elseif RunTo(runpos.x, runpos.y, 0, 400) == false then
            break
          end
        end
      else
        PushColorMsg("冰天雪地没有安全坐标？")
      end
    else
      DebugStr("冰天雪地:距离慕容复较远,无需躲避[%d,%d]", 3, math.ceil(xNpc), math.ceil(yNpc))
    end
    return false
  end
  return true
end

local function YZW_step3_other_ys()
  local bSafe = true
  local tObj = Enum2XByClass("怪物 NPC")
  local selfTID = Player:GetTID()
  local selfPet = Pet:GetTID()
  for i = 1, #tObj do
    if tObj[i].name ~= "慕容复" .. m_param.bossNameBZ then
      if tObj[i].target == selfTID then
        bSafe = false
        Pet:Relax()
        Skill:UseName("初级隐遁", 2000)
        PushDebugMessage("隐身:" .. tObj[i].name)
      elseif -1 ~= selfPet and tObj[i].target == selfPet then
        Pet:Relax()
      end
    end
  end
  return bSafe
end

local function YZW_step3_wyy()
  if not m_param.killwyy then
    return true
  end
  local bSafe = true
  if m_private.die_wyy == false then
    local bGuid2 = CDG.pet2.GUID
    local bGuid3 = CDG.pet3.GUID
    local nDiff = GetChangeSceneTimeDiff()
    if nDiff > 86400 then
      nDiff = 86400
    end
    local nMsgTime2 = IsInDebugMsg("段公子，你能去帮帮我表哥吗？")
    if nMsgTime2 and nMsgTime2 > os.time() - nDiff then
      bSafe = false
      CDG.pet2.GUID = 0
      CDG.pet3.GUID = 0
      CDG.skill_attack_jinji_disable = " 横扫乾坤 暗器连击 三阳开泰 连珠腐尸毒 万箭齐发 鹰击长空 定海神针 步步生花 "
      while FubenCheckSceneDie(m_param.sceneID) and YZW_IsStep3Pos() and YZW_step3_bsqf() do
        local tObj = Enum2XByName("王语嫣", {
          1,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          if 0 == tObj[1].hp then
            m_private.die_wyy = true
            break
          end
          local bcheckpet = false
          ZhiDianJiangShanObj(tObj[1], false)
          FubenAttack(tObj[1].id, nil, nil, true, bcheckpet, nil, false)
        else
          local tBoss = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
            1,
            1,
            0,
            0
          }, nil, nil, 0)
          if 0 == #tBoss then
            if false == RunTo(73, 68, 0, 500) then
              m_private.die_wyy = true
              break
            end
          elseif tBoss[1].target == Player:GetTID() or tBoss[1].target == Pet:GetTID() then
            PushDebugMessage("慕容复目标是自己,暂时不去杀王语嫣")
            Pet:Relax(200)
            if 7 == Player:GetState() then
              Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 200)
            end
            RunTo(57, 77, 0, 1000)
            YZW_step3_btxd()
            FubenAttack(-1)
          elseif false == RunTo(73, 68, 0, 500) then
            m_private.die_wyy = true
            break
          end
        end
        Sleep(300)
        DebugStr("已设置杀王语嫣")
      end
      Pet:Relax()
      MoveTo(60, 80, -1, 1, false, nil, YZW_callback_run_step3)
      Dismount()
      Sleep(300)
      Skill:UseName("初级隐遁", 300)
      RunTo(49, 89, 0, 1000)
      PlayerStateTimeOut(2, 2)
    end
    CDG.pet2.GUID = bGuid2
    CDG.pet3.GUID = bGuid3
  end
  CDG.skill_attack_jinji_disable = " 横扫乾坤 三阳开泰 连珠腐尸毒 暗器连击 金顶绵掌 步步生花 "
  return bSafe
end

local function YZW_step3_runsafe_dzxy()
  local pos = Player:GetPos()
  if pos.y > 90 then
    RunTo(49, 89, 0, 200)
  else
    RunTo(49, pos.y + 1, 0, 200)
  end
end

local function YZW_step3_boss_keepdist(tBoss, keepdist)
  if g_self.isjingong == false and keepdist > GetDist(tBoss.x, tBoss.y) and tBoss.target ~= Player:GetTID() then
    local safepos = YZW_step3_btxd_runpos(tBoss.x, tBoss.y, true)
    if #safepos > 0 then
      local run = safepos[1]
      RunTo(run.x, run.y, 0, 1000)
      DebugStr("远攻远离boss进行攻击", 3)
      return false
    end
  end
  return true
end

local function YZW_step3_mrfhp50(tBoss)
  if tBoss.hp < 51 then
    local bAttack = true
    if YZW_step3_bsqf() then
      YZW_step3_wyy()
    end
    local bSafe = YZW_step3_btxd()
    if bSafe and not m_param.btxd_safe then
      bAttack = YZW_step3_boss_keepdist(tBoss, 7)
    end
    return bSafe, bAttack
  end
  return true, true
end

local function YZW_step3_dzxy(tmp, time_dzxy)
  if Target:FindBuff(tmp, "斗转星移") then
    time_dzxy = GetTickCount()
    YZW_step3_runsafe_dzxy()
    if Player:IsLeader() then
      Player:TeamFollow(true)
      Sleep(700)
      Player:TeamFollow(false)
      Sleep(300)
    end
    Pet:CheckRelax(tmp.id, 2)
    local bSafe = true
    while true do
      local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
        1,
        1,
        0,
        0
      }, nil, nil, 0)
      if 0 == #tObj then
        break
      end
      local tmp = tObj[1]
      if bSafe and Target:FindBuff(tmp, "斗转星移") == false then
        break
      end
      if 7 == Player:GetState() then
        Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 200)
        YZW_step3_runsafe_dzxy()
      else
        if tmp.hp < 50 and not m_param.btxd_safe then
          YZW_step3_boss_keepdist(tmp, 7)
        end
        local bcheckpet = true
        FubenAttack(-1, nil, nil, true, bcheckpet)
        CDG:checktime0()
        CDG:checktime0()
        CDG:checkPetHappy(CDG.pet1.GUID)
      end
      if Target:FindBuff(tmp, "斗转星移") then
        CDG:SetActionTick(true)
        time_dzxy = GetTickCount()
      end
      bSafe = YZW_step3_mrfhp50(tmp)
      Sleep(50)
      DebugStr("燕子坞：等待斗转星移", 2)
    end
  end
  return time_dzxy
end

local function YZW_step3_mrf()
  local time_dzxy = -1
  local posidx = 1
  CDG.call.back1 = YZW_step3_btxd
  CDG.skill_attack_jinji_disable = " 横扫乾坤 三阳开泰 连珠腐尸毒 暗器连击 金顶绵掌 步步生花 "
  local bUnSafeTick = -1
  while FubenCheckSceneDie(m_param.sceneID) and YZW_IsStep3Pos() do
    local debugnote = ""
    YZW_step3_other_ys()
    local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      posidx = 1
      local tmp = tObj[1]
      if 0 == tmp.hp then
        PushDebugMessage("慕容复已死亡")
        RunTo(tmp.x, tmp.y, 0, 300)
        PickUpLua()
        break
      end
      local bSafe, bAttack = YZW_step3_mrfhp50(tmp)
      if false == bAttack then
        debugnote = " 正在移动"
        tmp.id = -1
      end
      if false == bSafe then
        debugnote = " 躲避冰天雪地"
        if g_self.isjingong then
          tmp.id = -1
        end
        bUnSafeTick = GetTickCount()
      else
        bUnSafeTick = -1
      end
      time_dzxy = YZW_step3_dzxy(tmp, time_dzxy)
      if -1 ~= time_dzxy then
        local nDiff = GetTickCount() - time_dzxy
        if nDiff < 9000 then
          if nDiff < 600 then
            tmp.id = -1
          end
        else
          Pet:CheckRelax(tmp.id, 2)
          tmp.id = -1
          if 7 == Player:GetState() then
            YZW_step3_runsafe_dzxy()
          end
        end
        if -1 ~= tmp.id then
          ZhiDianJiangShanObj(tmp, false)
        end
        FubenAttack(tmp.id)
      else
        debugnote = "出首次斗转星移后正常攻击"
        if 7 == Player:GetState() then
          Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 200)
          RunTo(49, 91, 0, 200)
          RunTo(49, 87, 0, 200)
        elseif tmp.hp > 97.99 then
          FubenAttack(tmp.id)
        else
          debugnote = " 即将出斗转星移"
          Pet:CheckRelax(tmp.id, 2)
          if Player:IsLeader() then
            Player:TeamFollow(true)
            Sleep(700)
            Player:TeamFollow(false)
            Sleep(300)
          end
          if 7 == Player:GetState() then
            Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 200)
            YZW_step3_runsafe_dzxy()
          end
          FubenAttack(-1)
        end
      end
    elseif GetTickCount() - bUnSafeTick > 5000 then
      debugnote = " 没有找到慕容复"
      if 4 == YZW_GetStep() then
        PushDebugMessage("boss已完成")
        break
      end
      if 1 == posidx then
        if RunTo(49, 70, 0, 300) == false then
          posidx = 2
        end
      elseif 2 == posidx then
        if RunTo(49, 89, 0, 300) == false then
          posidx = 3
        end
      else
        PushDebugMessage("无法找到慕容复")
        break
      end
    else
      debugnote = " 冰天雪地,暂不寻找慕容复"
    end
    Sleep(50)
    DebugStr("燕子坞：慕容复 " .. debugnote)
  end
  CDG.call.back1 = nil
  CDG.skill_attack_jinji_disable = ""
end

local function YZW_OnStep3()
  local tItem = Bag:FindItemInfo("悲酥清风解药")
  if 0 == #tItem then
    EatBindItem(3, " 段延庆的宝箱 段延庆的宝藏 段延庆的宝箱·遗 ")
  end
  YZW_step3_wait_step2()
  local debugnote = ""
  TickInitTeamSteady()
  while FubenCheckSceneDie(m_param.sceneID) and YZW_IsStep3Pos() and 3 == YZW_GetStep() and false == YZW_step_zhanshen(3) do
    do
      local pos = Player:GetPos()
      if pos.x < 77 and pos.y < 95 and pos.x > 40 then
        FubenAttack(-1)
        GivePlayerState("冰肌玉骨", 7, false)
        local tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
          1,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          if Player:IsLeader() then
            YZW_step3_mrf()
          else
            for i = 1, 10 do
              tObj = Enum2XByName("慕容复" .. m_param.bossNameBZ, {
                1,
                1,
                0,
                0
              }, nil, nil, 0)
              if #tObj > 0 and tObj[1].hp < 100 and 99.0 ~= tObj[1].hp then
                PushDebugMessage("慕容复hp:" .. tObj[1].hp)
                break
              end
              PickUpLua()
              Sleep(1000)
            end
            YZW_step3_mrf()
          end
        else
          RunTo(49, 89, 0, 1000)
          if Player:IsLeader() then
            if IsTeamSteady(20) then
              CheckAllTeamHP(85, YZW_callback_HP_step3, 20)
              MoveTo(60, 70, -1, 1, false, nil, YZW_callback_run_step3)
              Sleep(1000)
              MoveTo(49, 89, -1, 1, false, nil, YZW_callback_run_step3)
              Sleep(1000)
            end
          else
            debugnote = ",等待队长开启"
          end
        end
      else
        MoveTo(49, 89, -1, nil, nil, nil, YZW_callback_run_step3)
        Sleep(300)
        Pet:Relax()
        Dismount()
        Sleep(300)
        Skill:UseName("初级隐遁", 500)
        goto lbl_199
        break
      end
    end
    ::lbl_199::
    Sleep(50)
    DebugStr("燕子坞：开启慕容复" .. debugnote)
  end
end

local function YZW_OnStep4()
  if false == YZW_IsStep3Pos() then
    DebugStr("燕子坞副本已结束,前往通道")
    YZW_step3_wait_step2()
    return
  end
  local pos = Player:GetPos()
  if pos.x < 77 and pos.y < 95 and pos.x > 40 then
  else
    MoveTo(49, 80, -1, nil, nil, nil, YZW_callback_run_step3)
  end
  PickUpLua()
  if YZW_IsStep3Pos() then
    RelivePlayer(2, 20, 20, 100, 110, true)
  end
  if FubenCheckSceneDie(m_param.sceneID) and YZW_IsStep3Pos() then
    PickUpLua_Boss(45, 30, m_param.sceneID, {
      {x = 49, y = 70},
      {x = 49, y = 89}
    }, true, nil)
  end
  SDQY_HuoDong()
  PickUpMust()
  while FubenCheckSceneDie(m_param.sceneID) and YZW_IsStep3Pos() do
    PickUpLua()
    if 4 ~= YZW_GetStep() then
      PushColorMsg("副本已完成")
      break
    end
    local nDiff = GetChangeSceneTimeDiff()
    if nDiff < 45 then
      PushColorMsg("已离开副本")
      break
    end
    if false == IsMount() then
      FubenAttack(-1)
    end
    RelivePlayer(2, 20, 20, 100, 110, true)
    local pos = Player:GetPos()
    if pos.x < 61 or pos.y > 38 then
      RunTo(65, 36, 0, 600)
    else
      RunTo(62, 20, 0, 600)
    end
    MoveConfirm()
    Sleep(50)
    DebugStr("燕子坞:已完成,离开副本")
  end
end

local function YZW_Start()
  while GetSceneID() == m_param.sceneID do
    local nStep = YZW_GetStep()
    g_pick.pickmode = 0
    if 1 == nStep then
      YZW_OnStep1()
    elseif 2 == nStep then
      local npc = m_npc[1]
      if GetDist(npc.x, npc.y) < 15 then
        PickUpLua()
        local tItem = Bag:FindItemInfo("悲酥清风解药")
        if 0 == #tItem then
          local tJN = Bag:EnumTempBagItem()
          tItem = Bag:FindItemInfo("悲酥清风解药", nil, nil, tJN)
        end
        if 0 == #tItem then
          for i = 1, 5 do
            PickUpLua()
            Sleep(1000)
            tItem = Bag:FindItemInfo("悲酥清风解药")
            if #tItem > 0 then
              break
            end
          end
        end
      end
      YZW_OnStep2()
    elseif 3 == nStep then
      YZW_OnStep3()
    elseif 4 == nStep then
      YZW_OnStep4()
    else
      PushColorMsg("燕子坞：未知进度" .. nStep)
    end
    PickUpLua()
    FuBenCheckDie(m_param.swcq, true)
    Sleep(50)
    DebugStr("燕子坞：副本进行中", 3)
  end
end

function YZW_CallBack()
  if 5 == GetSceneID() then
    PushColorMsg("武当山")
    return MoveToNPC("莫太冲", 101.03, 136.47, 12)
  elseif 30 == GetSceneID() then
    PushColorMsg("在西湖")
    MoveTo(273, 178, 731, nil, nil)
    return MoveToNPC("方七佛", 102.13, 167.01, 11)
  end
  return true
end

function _SMain(...)
  local npc = {
    name = "李纲",
    x = 70,
    y = 120,
    sceneID = 4
  }
  local nTickOut = -1
  m_param.bossNameBZ = ""
  if m_param.FBType == "普通" then
    m_param.bossNameBZ = ""
    m_param.m_fb_text = "讨伐燕子坞"
    m_param.m_fb_next = 2
  elseif m_param.FBType == "初级" then
    m_param.bossNameBZ = "·闻恶"
    m_param.m_fb_text = "讨伐燕子坞·初级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "中级" then
    m_param.bossNameBZ = "·识恶"
    m_param.m_fb_text = "讨伐燕子坞·中级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "高级" then
    m_param.bossNameBZ = "·罚恶"
    m_param.m_fb_text = "讨伐燕子坞·高级"
    m_param.m_fb_next = 4
  end
  while true do
    local debugnote = ""
    if GetSceneID() == m_param.sceneID then
      YZW_Start()
      GoToScene(276, 56, 1)
      break
    else
      Bag_DeleteItem()
      if IsHuodongComplete(m_param.missionName, 2) then
        Sleep(3000)
        if GetSceneID() ~= m_param.sceneID and IsHuodongComplete(m_param.missionName, 2, true) then
          PushColorMsg("燕子坞:今日已完成!")
          break
        end
      end
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      ChangeSceneLine()
      if -1 == nTickOut then
        nTickOut = GetTickCount()
      end
      Sleep(500)
      local teamCount = m_teamCount
      if Player:IsLeader() and Team:IsCountReady(teamCount) then
        if Team:GetSurroundMember() >= Team:GetMemberCount() or GetTickCount() - nTickOut > 60000 then
          Sleep(1000)
          if m_param.FBType == "普通" then
            PushColorMsg("普通")
            QuestFrameOptionClicked_Item("讨伐燕子坞", 1, 1000)
          elseif m_param.FBType == "初级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_08}", 1, 1000)
          elseif m_param.FBType == "中级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_49}", 1, 1500)
          elseif m_param.FBType == "高级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_09}", 1, 1500)
          end
          if not CheckFubenJinRi() then
            goto lbl_180
          end
          Sleep(3000)
          if GetSceneID() ~= m_param.sceneID then
            break
          end
        else
          debugnote = " 等待队员集合,60秒超时"
          Sleep(500)
        end
      end
      ::lbl_180::
      if IsMount() == false then
        FubenAttack(-1)
      end
    end
    Sleep(300)
    DebugStr("燕子坞：等待进入副本" .. debugnote, 2)
  end
end

RecvState(3)
_SMain()
m_param = nil
m_private = nil
ScriptOnStop(m_script_name, true)
