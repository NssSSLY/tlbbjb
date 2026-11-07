-- 反编译自 dfz64.dll 内嵌字节码 0050c192（unluac 2025-12-23；仅供分析）
local m_param = {}
local m_data = {}
m_data.sceneID = 877
m_data.boss_zero = {
  x = 52,
  y = 107,
  r = 15,
  rmin = 1,
  rmax = 15,
  name = ""
}

local function JLG_LeaveScene()
  MoveToNPC("云昕昕", 56, 139, m_data.sceneID, 3, nil, nil, MoveCallback_InScene)
  Sleep(600)
  QuestFrameOptionClicked_Item("#{SESX_230426_98}", 1, 1000)
  QuestFrameOptionClicked_Item("#{SESX_230426_40}", 1, 1000)
end

local function JLG_OpenBox()
  local bFindBox = false
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("#{SESX_230426_107}")
  if nMsgTime1 and nTransTime < nMsgTime1 then
    bFindBox = true
    PushDebugMessage("聚灵谷:已经领取奖励,离开副本")
    for i = 1, 5 do
      RelivePlayer(1, nil, nil, nil, nil, false)
    end
    JLG_LeaveScene()
    return bFindBox
  end
  local tObj = Enum2XByName("聚灵宝箱", {
    1,
    0,
    0,
    0
  }, nil, 3, 0)
  if #tObj > 0 then
    bFindBox = true
    if IsInDebugMsgTime("#{SESX_230426_106}", nil, 100) then
      for i = 1, 5 do
        RelivePlayer(1, nil, nil, nil, nil, false)
      end
      JLG_LeaveScene()
    else
      local tmp = tObj[1]
      RunTo(tmp.x, tmp.y, 3, 1000)
      PlayerStateTimeOut(2, 8)
      OpenTalk(tmp.id, 500)
      QuestFrameOptionClicked_Item("#{SESX_230426_103}", 1, 1000)
    end
    RelivePlayer(1, nil, nil, nil, nil, false)
  end
  return bFindBox
end

local function jlg_move_cb(...)
  if JLG_OpenBox() then
    return false
  end
  return MoveCallback_InScene(...)
end

local function JLG_FindBoss()
  local tObj = Enum2XByName(" 剧毒乌犍 玄雷宝驹 雪海沧龙 赤焰黑虎 ", {
    0,
    1,
    0,
    0
  }, {-1, -1}, 0, 3)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

local function JLG_CheckZeroPos(aBoss, aBossIndex)
  local zero = m_data.boss_zero
  local myPos
  local nDist = 7
  if aBoss.dst > 15 then
    MoveTo(zero.x, zero.y, m_data.sceneID, nDist, nil, nil, MoveCallback_InScene)
  end
  if 22222222 == aBossIndex then
    for i = 1, 6 do
      if not RunTo(zero.x, zero.y, 0, 500) then
        break
      end
      Sleep(500)
    end
  else
    local zeroDist = 7
    if g_self.isjingong then
      zeroDist = 3
    end
    for i = 1, 6 do
      local bOk = TeamDispersedStations(zero, zeroDist, 6)
      if bOk then
        break
      end
      Sleep(500)
    end
  end
  return zero
end

local function JLG_JDWJ_spec_1(aBoss, aZero)
  local bHave = false
  local bSafe = true
  local npc = aBoss
  if nil == npc then
    npc = aZero
  end
  local zero = aZero
  local trapR = 6
  local teamR = 7
  if -1 ~= Player:GetBuff("毒厄") then
    bHave = true
    bSafe = false
    local bIsRun = false
    local tPlayer = Enum2XByClass("玩家")
    local tTrap = DeleteTableFieldValue(tPlayer, "name", {
      g_self.name
    })
    if #tTrap > 0 then
      bSafe = FubenTrapRun(npc.name, zero.x, zero.y, trapR, zero.r, tTrap, nil, FubenRunSafe)
    else
      bSafe = true
    end
  else
    local tPlayer = Enum2XByClass("玩家")
    tPlayer = DeleteTableFieldValue(tPlayer, "name", {
      g_self.name
    })
    local tTrap = GetHasBuffObj(tPlayer, "毒厄", false)
    if #tTrap > 0 then
      bHave = true
      bSafe = false
      bSafe = FubenTrapRun(npc.name, zero.x, zero.y, trapR, zero.r, tTrap, nil, FubenRunSafe)
    end
  end
  return bHave, bSafe
end

local function JLG_JDWJ_spec2(aZero)
  local zero = aZero
  local teamR = 7
  local bIn, strMsg = IsInDebugMsgTime("#{SESX_230426_81}", false, 3)
  if bIn then
    local bRun = TeamDispersedStations(zero, teamR, 6)
    return true
  end
  return false
end

local function JLG_JDWJ_spec3(aBoss, aZero)
  local bHave = false
  local bSafe = true
  local npc = aBoss
  if nil == npc then
    npc = aZero
  end
  local zero = aZero
  local trapR = 6
  local tTrap = {}
  local bFindTarp = false
  local tAll = EnumEnvObj()
  for i = 1, #tAll do
    local tmp = tAll[i]
    if tmp.class == "陷阱" then
      if tmp.name == "毒疫缠身陷阱简单" or tmp.name == "毒疫缠身陷阱中等" or tmp.name == "毒疫缠身陷阱困难" then
        bFindTarp = true
        table.insert(tTrap, tmp)
      end
    elseif tmp.class == "NPC" then
      if tmp.name == "牛陷阱预警NPC" then
        bFindTarp = true
        table.insert(tTrap, tmp)
      end
    elseif tmp.class == "玩家" and tmp.name ~= g_self.name and Target:FindBuff(tmp, "毒厄") then
      table.insert(tTrap, tmp)
    end
  end
  if bFindTarp then
    bHave = true
    if g_self.isjingong and CDG.attack then
      bSafe = FubenTrapRun(npc.name, zero.x, zero.y, trapR, zero.r, tTrap, nil, FubenRunSafe)
    else
      bSafe = FubenTrapRun("", zero.x, zero.y, trapR, zero.r, tTrap, nil, FubenRunSafe)
    end
  end
  return bHave, bSafe
end

local function JLG_JDWJ_cb()
  local tObj = Enum2XByName("剧毒乌犍", {
    0,
    1,
    0,
    0
  }, {0, -1}, 0, 0)
  if #tObj > 0 then
    local zero = m_data.boss_zero
    local bHave1, bSafe1 = JLG_JDWJ_spec3(tObj[1], zero)
    if bHave1 then
      return false
    end
    local bHave2, bSafe2 = JLG_JDWJ_spec_1(tObj[1], zero)
    if bHave2 then
      return false
    end
  end
  return true
end

local function JLG_BossJDWJ(aBoss)
  local zero = JLG_CheckZeroPos(aBoss, 1)
  zero.name = "剧毒乌犍"
  CDG.call.back1 = JLG_JDWJ_cb
  while FubenCheckSceneDie(m_data.sceneID) do
    if not JLG_JDWJ_spec2(zero) then
      local tObj = Enum2XByName(zero.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, 0, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        local tid = tmp.id
        local bHave1, bSafe1 = JLG_JDWJ_spec3(tmp, zero)
        local bHave2 = false
        local bSafe2 = true
        if false == bHave1 then
          bHave2, bSafe2 = JLG_JDWJ_spec_1(tmp, zero)
        end
        if bSafe1 and bSafe2 then
          if (bHave1 or bHave2) and g_self.isjingong and CDG.attack and tmp.dst > 3 then
            JinGongFarSkill(tid)
            tid = -1
          end
          FubenAttack(tid)
        end
      else
        if false ~= JLG_OpenBox() then
          goto lbl_119
        end
        MoveTo(zero.x, zero.y, m_data.sceneID, 7, nil, nil, jlg_move_cb)
        local tObj = Enum2XByName(zero.name, {
          0,
          1,
          0,
          0
        }, {0, -1}, 0, 0)
        if 0 == #tObj then
          break
        end
      end
    else
      FubenAttack(-1)
    end
    ::lbl_119::
    Sleep(100)
    DebugStr("Boss:" .. zero.name)
  end
  CDG.call.back1 = nil
end

local function JLG_XLBJ_spec1(aBoss)
  local bHave = false
  local bSafe = true
  local tObj = Enum2XByName("生肖副本通用空NPC", {
    1,
    0,
    0,
    0
  }, nil, 0, 0)
  if #tObj > 0 then
    bHave = true
    local shanxing = tObj[1]
    bSafe = FubenShanXing(aBoss, shanxing, 1, 55)
  end
  return bHave, bSafe
end

local function JLG_XLBJ_spec2()
  local bHave = false
  local bSafe = true
  if IsInDebugMsgTime("#{SESX_230426_87}", nil, 20) then
    bHave = true
    local zero = m_data.boss_zero
    if RunTo(zero.x, zero.y, 2, 800) == false then
      bSafe = true
    end
  end
  return bHave, bSafe
end

local function JLG_xlbj_cb()
  local tObj = Enum2XByName("玄雷宝驹", {
    0,
    1,
    0,
    0
  }, {0, -1}, 0, 0)
  if #tObj > 0 then
    local bHave2, bSafe2 = JLG_XLBJ_spec2()
    if bHave2 then
      return false
    end
    local bHave1, bSafe1 = JLG_XLBJ_spec1(tObj[1])
    if bHave1 then
      return false
    end
  end
  return true
end

local function JLG_BossXLBJ(aBoss)
  local zero = JLG_CheckZeroPos(aBoss, 2)
  zero.name = "玄雷宝驹"
  CDG.call.back1 = JLG_xlbj_cb
  while FubenCheckSceneDie(m_data.sceneID) do
    if -1 == Player:GetBuff("雷域：") then
      local tObj = {}
      if not m_param.unkill_ls then
        tObj = Enum2XByName("雷锁", {
          0,
          1,
          0,
          0
        }, {0, -1}, 3, 0)
      end
      local tBoss = Enum2XByName(zero.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, 0, 0)
      if 0 == #tObj then
        tObj = tBoss
      end
      if #tObj > 0 then
        local bJinJi = false
        local tid = tObj[1].id
        local tar
        if #tBoss > 0 then
          tar = tBoss[1]
          local bHave1, bSafe1 = false, true
          local bHave2, bSafe2 = JLG_XLBJ_spec2()
          if not bHave2 then
            bHave1, bSafe1 = JLG_XLBJ_spec1(tar)
          end
          if bSafe1 and bSafe2 then
            if Target:FindBuff(tar, "护盾：") then
              tid = tar.id
              bJinJi = true
            elseif bHave2 then
              if IsInDebugMsgTime("#{SESX_230426_87}", nil, 3) then
                tid = -1
              end
            elseif bHave1 then
              if tar.dst > 15 then
                tid = -1
              else
                if g_self.isjingong and CDG.attack and tar.dst > 3 then
                  JinGongFarSkill(tid)
                  tid = -1
                else
                end
              end
            end
            FubenAttack(tid, nil, bJinJi)
          end
        end
      elseif false == JLG_OpenBox() then
        MoveTo(zero.x, zero.y, m_data.sceneID, 7, nil, nil, jlg_move_cb)
        local tObj = Enum2XByName(zero.name, {
          0,
          1,
          0,
          0
        }, {0, -1}, 0, 0)
        if 0 == #tObj then
          break
        end
      end
    end
    Sleep(100)
    DebugStr("Boss:" .. zero.name)
  end
  CDG.call.back1 = nil
end

local function JLG_XHCL_spec1(aBoss)
  local bHave = false
  local bSafe = true
  local zero = m_data.boss_zero
  local tAll = Enum2XByClass("NPC", {0, -1})
  local tObj = ObjFilterByName(tAll, "雪海沧龙", 0)
  local tTrap = {}
  for i = 1, #tObj do
    if GetDist(tObj[i].x, tObj[i].y, zero.x, zero.y) > 1 then
      local tmp = {
        x = zero.x,
        y = zero.y
      }
      tmp.angle = GetAngle(zero.x, zero.y, tObj[i].x, tObj[i].y)
      table.insert(tTrap, tmp)
    end
  end
  if #tTrap > 0 then
    bHave = true
    bSafe = FubenTrapTiaoXing(tTrap, 15, 4, zero)
  end
  return bHave, bSafe
end

local function JLG_XHCL_spec2(aBoss)
  local bHave = false
  local bSafe = true
  if IsInDebugMsgTime("#{SESX_230426_69}", nil, 20) then
    bHave = true
    bSafe = false
    local zero = m_data.boss_zero
    local tAll = Enum2XByClass("NPC", {0, -1})
    local tObj = ObjFilterByName(tAll, "生肖副本通用空NPC", 0)
    local tTrap = {}
    for i = 1, #tObj do
      if GetDist(tObj[i].x, tObj[i].y, zero.x, zero.y) > 1 then
        local tmp = {
          x = zero.x,
          y = zero.y
        }
        tmp.angle = GetAngle(zero.x, zero.y, tObj[i].x, tObj[i].y)
        table.insert(tTrap, tmp)
      end
    end
    if #tTrap > 0 then
      bHave = true
      bSafe = FubenTrapTiaoXing(tTrap, 15, 3, zero)
    end
  end
  return bHave, bSafe
end

local function JLG_XHCL_spec3(aBoss)
  local bHave = false
  local bSafe = true
  local npc = aBoss
  if nil == npc then
    npc = m_data.boss_zero
  end
  local zero = m_data.boss_zero
  local trapR = 6
  local teamR = 7
  if -1 ~= Player:GetBuff("重雪：") then
    bHave = true
    bSafe = false
    local bIsRun = false
    local tPlayer = Enum2XByClass("玩家")
    local tTrap = DeleteTableFieldValue(tPlayer, "name", {
      g_self.name
    })
    if #tTrap > 0 then
      bSafe = FubenTrapRun(npc.name, zero.x, zero.y, trapR, zero.r, tTrap, nil, FubenRunSafe)
    else
      bSafe = true
    end
  else
    local tPlayer = Enum2XByClass("玩家")
    tPlayer = DeleteTableFieldValue(tPlayer, "name", {
      g_self.name
    })
    local tTrap = GetHasBuffObj(tPlayer, "重雪：", false)
    if #tTrap > 0 then
      bHave = true
      bSafe = false
      bSafe = FubenTrapRun(npc.name, zero.x, zero.y, trapR, zero.r, tTrap, nil, FubenRunSafe)
    end
  end
  return bHave, bSafe
end

local function JLG_xhcl_cb()
  local tObj = Enum2XByName("雪海沧龙", {
    0,
    1,
    0,
    0
  }, {0, -1}, 0, 0)
  if #tObj > 0 then
    local zero = m_data.boss_zero
    local bHave1, bSafe1 = JLG_XHCL_spec1(tObj[1])
    if bHave1 then
      return false
    end
    local bHave2, bSafe2 = JLG_XHCL_spec2(tObj[1])
    if bHave2 then
      return false
    end
    local bHave3, bSafe3 = JLG_XHCL_spec3(tObj[1], zero)
    if bHave3 then
      return false
    end
  end
  return true
end

local function JLG_BossXHCL(aBoss)
  local zero = JLG_CheckZeroPos(aBoss, 3)
  zero.name = "雪海沧龙"
  CDG.call.back1 = JLG_xhcl_cb
  while FubenCheckSceneDie(m_data.sceneID) do
    local tObj = Enum2XByName(zero.name, {
      0,
      1,
      0,
      0
    }, {0, -1}, 0, 0)
    if #tObj > 0 then
      local tar = tObj[1]
      local tid = -1
      local bHave1 = false
      local bSafe1 = true
      local bHave2, bSafe2 = JLG_XHCL_spec2(tar)
      local bHave3 = false
      local bSafe3 = true
      if false == bHave2 then
        bHave1, bSafe1 = JLG_XHCL_spec1(tar)
        if false == bHave1 then
          bHave3, bSafe3 = JLG_XHCL_spec3(tar)
        end
      end
      if bSafe1 and bSafe2 and bSafe3 then
        tid = tar.id
        if bHave2 then
          tid = -1
        elseif bHave1 or bHave3 then
          if tar.dst > 15 then
            tid = -1
          elseif g_self.isjingong and CDG.attack and tar.dst > 3 then
            JinGongFarSkill(tid)
            tid = -1
          end
        end
        FubenAttack(tid)
      end
    elseif false == JLG_OpenBox() then
      MoveTo(zero.x, zero.y, m_data.sceneID, 7, nil, nil, jlg_move_cb)
      local tObj = Enum2XByName(zero.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, 0, 0)
      if 0 == #tObj then
        break
      end
    end
    Sleep(100)
    DebugStr("Boss:" .. zero.name)
  end
  CDG.call.back1 = nil
end

local function JLG_CYHH_spec1()
  local bHave = false
  local bSafe = true
  local zero = m_data.boss_zero
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tZero = ObjFilterByName(tAll, "白虎预警NPC", 0)
  local tKong = ObjFilterByName(tAll, "生肖副本通用空NPC", 0)
  if #tZero > 0 and #tKong > 0 then
    bHave = true
    bSafe = false
    local tTrap = {}
    for i = 1, #tKong do
      if tKong[i].x ~= tZero[1].x or tKong[i].y ~= tZero[1].y then
        local tmp = {
          x = zero.x,
          y = zero.y
        }
        tmp.angle = GetAngle(zero.x, zero.y, tKong[i].x, tKong[i].y)
        table.insert(tTrap, tmp)
        break
      end
    end
    if #tTrap > 0 then
      bSafe = FubenTrapTiaoXing(tTrap, 15, 4, zero)
    end
  end
  return bHave, bSafe
end

local function JLG_CYHH_spec2()
  local bHave = false
  local bSafe = true
  local zero = m_data.boss_zero
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  if IsInDebugMsgTime("#{SESX_230426_75}", nil, 6) then
    bHave = true
    bSafe = false
  end
  local tObj = ObjFilterByName(tAll, "白虎预警NPC", 0)
  local tTrap = tObj
  for i = 1, #tTrap do
    tTrap[i].angle = GetTargetAngle(tTrap[i])
  end
  if #tTrap > 0 then
    bHave = true
    bSafe = FubenTrapTiaoXing(tObj, 15, 4, zero)
  end
  return bHave, bSafe
end

local function JLG_cyhh_cb()
  local bHave2, bSafe2 = JLG_CYHH_spec2()
  if bHave2 then
    return false
  end
  local bHave1, bSafe1 = JLG_CYHH_spec1()
  if bHave1 then
    return false
  end
  return true
end

local function JLG_BossCYHH(aBoss)
  local zero = JLG_CheckZeroPos(aBoss, 4)
  zero.name = "赤焰黑虎"
  CDG.call.back1 = JLG_cyhh_cb
  while FubenCheckSceneDie(m_data.sceneID) do
    local tObj = Enum2XByName(zero.name, {
      0,
      1,
      0,
      0
    }, {0, -1}, 0, 0)
    if #tObj > 0 then
      local tar = tObj[1]
      local tid = -1
      local bHave2, bSafe2 = JLG_CYHH_spec2()
      local bHave1, bSafe1 = false, true
      if false == bHave2 then
        bHave1, bSafe1 = JLG_CYHH_spec1()
      end
      if bSafe1 and bSafe2 then
        tid = tar.id
        if bHave2 then
          tid = -1
        elseif bHave1 then
          if tar.dst > 15 then
            tid = -1
          elseif g_self.isjingong and CDG.attack and tar.dst > 3 then
            JinGongFarSkill(tid)
            tid = -1
          end
        end
        if not bHave2 then
          FubenAttack(tid)
        end
      end
    elseif false == JLG_OpenBox() then
      MoveTo(zero.x, zero.y, m_data.sceneID, 7, nil, nil, jlg_move_cb)
      local tObj = Enum2XByName(zero.name, {
        0,
        1,
        0,
        0
      }, {0, -1}, 0, 0)
      if 0 == #tObj then
        break
      end
    end
    Sleep(100)
    DebugStr("Boss:" .. zero.name)
  end
  CDG.call.back1 = nil
end

local function JLG_OnBoss()
  if JLG_OpenBox() then
    return true
  end
  local tBoss = JLG_FindBoss()
  if tBoss then
    CDG.die.out = m_param.swcq
    if tBoss.name == "剧毒乌犍" then
      JLG_BossJDWJ(tBoss)
    elseif tBoss.name == "玄雷宝驹" then
      JLG_BossXLBJ(tBoss)
    elseif tBoss.name == "雪海沧龙" then
      JLG_BossXHCL(tBoss)
    elseif tBoss.name == "赤焰黑虎" then
      JLG_BossCYHH(tBoss)
    end
    return true
  end
  return false
end

local function JLG_OnAction()
  CDG.sceneID = m_data.sceneID
  if g_self.isjingong then
    CDG.attackMode = "打死换怪"
  else
    CDG.attackMode = "优先绿怪"
  end
  CDG.pickup = false
  CDG.overMapErr = true
  CDG.die.out = true
  CDG.posRadius = 15
  CDG.tragetSelect = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  CDG.pos = {
    {x = 107, y = 120},
    {x = 133, y = 79},
    {x = 107, y = 59},
    {x = 83, y = 55},
    {x = 60, y = 72},
    {x = 52, y = 107}
  }
  CDG.posIdx = GetNearestPoint(CDG.pos)
  CDG:SetTimeOut(200)
  
  local function CDG_loop_callback(...)
    DebugStr("聚灵谷：清理小怪", 2)
    if GetSceneID() ~= m_data.sceneID then
      return true
    end
    JLG_OpenBox()
    if JLG_FindBoss() then
      local bOver = true
      local tObj = Enum2XByClass("怪物", {0, -1})
      for i = 1, #tObj do
        local tmp = tObj[i]
        if tmp.name ~= "" and string.find(" 剧毒乌犍 玄雷宝驹 雪海沧龙 赤焰黑虎 ", tmp.name, nil, true) then
        else
          bOver = false
          break
        end
      end
      if bOver then
        return true
      end
    end
    local nTransTime = GetSceneTransTime()
    local nMsgTime1 = IsInDebugMsg("#{SESX_230426_35")
    if nMsgTime1 and nTransTime < nMsgTime1 then
      PushDebugMessage("聚灵谷:本次已完成")
      UseMount()
      return true
    end
    return false
  end
  
  local function sf_move_cb_in_fb(fX, fY, nScene)
    if GetSceneID() ~= m_data.sceneID then
      return false
    end
    JLG_OpenBox()
    if JLG_FindBoss() then
      local bOver = true
      local tObj = Enum2XByClass("怪物", {0, -1})
      for i = 1, #tObj do
        local tmp = tObj[i]
        if tmp.name ~= "" and string.find(" 剧毒乌犍 玄雷宝驹 雪海沧龙 赤焰黑虎 ", tmp.name, nil, true) then
        else
          bOver = false
          break
        end
      end
      if bOver then
        return true
      end
    end
    if CDG.pickup then
      PickUpLua(nil, true)
    end
    return true
  end
  
  CDG.callfun = CDG_loop_callback
  CDG.callfun_move = sf_move_cb_in_fb
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("#{SESX_230426_35")
  if nMsgTime1 and nTransTime < nMsgTime1 then
    DebugStr("聚灵谷:本次副本已完成!")
    JLG_OpenBox()
    UseMount()
    IsHuodongComplete("灵谷勘兽迹", 1)
  elseif false == JLG_OnBoss() then
    if m_param.unkill_xg then
      MoveTo(m_data.boss_zero.x, m_data.boss_zero.y, m_data.sceneID, 12, nil, nil, jlg_move_cb)
    else
      CDG:OnStart()
    end
  end
end

function JLG_Fuben(aParam)
  m_param = aParam
  while GetSceneID() == m_data.sceneID do
    JLG_OnAction()
    FuBenCheckDie(m_param.swcq, true)
    Sleep(50)
    DebugStr("聚灵谷副本中")
  end
end
