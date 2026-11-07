-- 反编译自 dfz64.dll 内嵌字节码 004f9aa5（unluac 2025-12-23；仅供分析）
local m_script_name = "琅嬛福地"
local m_param = {}
local m_finish = {
  boss1 = false,
  boss2 = false,
  boss3 = false,
  boss4 = false
}
local m_step = 0
local m_pos = {
  {
    x = 140,
    y = 62,
    name = "副本通用动态阻挡",
    npc = "李秋水"
  },
  {
    x = 212,
    y = 119,
    name = "副本通用动态阻挡",
    npc = "天山童姥"
  },
  {
    x = 182,
    y = 207,
    name = "副本通用动态阻挡",
    npc = "无崖子"
  },
  {
    x = 82,
    y = 181,
    name = "副本通用动态阻挡",
    npc = "虚竹"
  }
}

local function LHFD_SetFinishState(boss1, boss2, boss3, boss4)
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

local function LHFD_cb_inscene(fX, fY, nScene)
  DebugStr(m_param.sceneName .. ":移动到坐标 %d,%d", 2, math.floor(fX), math.floor(fY))
  PickUpLua()
  return FubenCheckSceneDie(m_param.sceneID)
end

local function LHFD_cb_checkhp()
  local tObj = Enum2XByName(" 李秋水" .. m_param.bossNameBZ .. " 天山童姥" .. m_param.bossNameBZ .. " 无崖子" .. m_param.bossNameBZ .. " 虚竹" .. m_param.bossNameBZ .. " ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    return false
  end
  return FubenCheckSceneDie(m_param.sceneID)
end

local function LHFD_boss_finish(bFinish, boss, posPick)
  local pos = posPick or {
    {
      x = boss.x,
      y = boss.y
    }
  }
  PickUpLua(nil, true)
  if bFinish then
    PushDebugMessage(m_param.sceneName .. ":" .. boss.npc .. " 已完成。")
    RelivePlayer(1, nil, nil, nil, nil, false)
    PickUpLua(nil, true)
    RelivePlayer(2, -1, -1, -1, -1, true)
    PickUpLua_Boss(60, 15, nil, pos, true, nil)
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpMust()
  end
end

local function Boss1Jian(aID)
  if IsInDebugMsgTime("LHFD_160203_75", false, 6) then
    PushColorMsg("李秋水:发现剑气")
    CDG.call.back1 = nil
    local zero = m_pos[1]
    zero.rmin = 1
    zero.rmax = 15
    while FubenCheckSceneDie(m_param.sceneID) and IsInDebugMsgTime("LHFD_160203_75", false, 6) do
      local debugnote = ""
      local tAll = Enum2XByClass("NPC 怪物")
      local tBoss = ObjFilterByStrClass(tAll, "怪物", 0)
      local tNPC = ObjFilterByStrClass(tAll, "NPC", 0)
      local tJian = ObjFilterByName(tNPC, "剑", 0)
      local tLQS = ObjFilterByName(tBoss, "李秋水", 1)
      if #tJian > 0 then
        local lqs = tLQS[1]
        local jian = tJian[1]
        local trapPos = {
          x = jian.x,
          y = jian.y
        }
        local trapAngle = GetTargetAngle(jian)
        local bTrapSafe = FubenShanXing2(zero, trapPos, trapAngle, 45, lqs)
        if bTrapSafe then
          PlayerStateTimeOut(2, 2)
          if lqs then
            CheckDistAttack(lqs, false)
          end
          if -1 == aID then
            debugnote = " 已安全"
          end
        end
      else
        FubenAttack(-1)
      end
      Sleep(50)
      DebugStr("琅嬛福地:李秋水躲避剑气" .. debugnote, 2)
    end
    CDG.call.back1 = m_param.callback
    PushDebugMessage("李秋水:剑气已释放")
  end
end

local function Boss1WXZY()
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local tObj = Enum2XByName("无相踪影", {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 0)
  while #tObj > 0 and FubenCheckSceneDie(m_param.sceneID) do
    if g_self.isjingong then
      BubbleByDst(tObj, 1)
    else
      BubbleByHP(tObj, 1)
    end
    CDG.pet2.GUID = 0
    CDG.pet3.GUID = 0
    FubenAttack(tObj[1].id, nil, true, true, false, true)
    Sleep(100)
    DebugStr("琅嬛福地:无相踪影")
    tObj = Enum2XByName("无相踪影", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss1YBCY()
  local tObj = Enum2XByName("玉璧残影", {
    1,
    1,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 then
    return true
  end
  return false
end

local function Boss1OnAction()
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local boss = m_pos[1]
  local tLast = {
    x = boss.x,
    y = boss.y
  }
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("李秋水" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      tLast.x = tObj[1].x
      tLast.y = tObj[1].y
      if 0 == tObj[1].hp then
        m_finish.boss1 = true
        break
      end
      local bYBCY = Boss1YBCY()
      if false == bYBCY then
        Boss1Jian(tObj[1].id)
        Boss1WXZY()
      end
      if false == bYBCY and false == g_self.isjingong then
        local nDist = 8
        if 4 == g_self.menpai then
          nDist = 6
        end
        if nDist < GetDist(boss.x, boss.y) then
          RunTo(boss.x, boss.y, 3, 700)
        end
      end
      if bYBCY or tObj[1].hp > 17 then
        if bYBCY then
          debugnote = "玉璧残影，集火攻击"
          CDG.pet3.GUID = 0
          CDG.pet2.GUID = 0
          FubenAttack(tObj[1].id, true, true, true, false, true, true)
          CDG.pet2.GUID = bGuid2
          CDG.pet3.GUID = bGuid3
        else
          debugnote = "."
          FubenAttack(tObj[1].id)
        end
      else
        if false == g_self.isjingong and tObj[1].hp < 9 then
          RunTo(boss.x, boss.y, 2, 1000)
        end
        debugnote = "暂不用技能."
        FubenAttack(tObj[1].id, false, false)
      end
    else
      PickUpLua()
      debugnote = " 未找到boss"
      if false == RunTo(boss.x, boss.y, 1, 500) then
        break
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地:李秋水 " .. debugnote)
  end
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
  LHFD_boss_finish(m_finish.boss1, boss, tpos)
end

local function Boss2Special()
  local bIsSafe = true
  local tSpecial = {}
  CDG.call.back1 = nil
  local zero = m_pos[2]
  repeat
    local tAllSpec = EnumUnSafeSpecial()
    local specName = " 寒冰符指引特效 寒冰符 饮血爆炸陷阱 天火符 "
    tSpecial = ObjFilterByName(tAllSpec, specName, 3)
    local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
    if #tSpecial > 0 then
      local param = {}
      param.useqg = false
      bIsSafe, tSpecial = FubenTrapRun("", zero.x, zero.y, 8, 15, tSpecial, nil, FubenRunSafe, nil, nil, param)
      Sleep(50)
      DebugStr("天山童姥:躲避陷阱")
    else
      bIsSafe = true
    end
  until bIsSafe
  CDG.call.back1 = m_param.callback
  return bIsSafe, tSpecial
end

local function Boss2OnAction()
  local boss = m_pos[2]
  local tLast = {
    x = boss.x,
    y = boss.y
  }
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("天山童姥" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      tLast.x, tLast.y = tObj[1].x, tObj[1].y
      if 0 == tObj[1].hp then
        m_finish.boss2 = true
        break
      end
      local bCheckPet = true
      local bUseJinJi = false
      local bMustAttack = false
      if Target:FindBuff(tObj[1], "速速打破血盾") then
        debugnote = "集火打血盾"
        bCheckPet = false
        bUseJinJi = true
        if 4 == g_self.menpai and CDG.hp.em_yxjx then
          bMustAttack = true
        end
      end
      if tObj[1].hp >= 50 then
        local bIsSafe, tSpecial = Boss2Special()
        local bAttack = false
        if bIsSafe then
          if g_self.isjingong then
            if 0 == #tSpecial then
              bAttack = true
            else
              local tmp = Enum2XByName("天山童姥" .. m_param.bossNameBZ, {
                0,
                1,
                0,
                0
              }, nil, nil, 0)
              if #tmp > 0 then
                if tmp[1].dst <= 2 then
                  bAttack = true
                else
                  debugnote = "有陷进,近攻暂时不攻击"
                  if tmp[1].dst <= 15 then
                    JinGongFarSkill(tmp[1].id)
                  end
                end
              end
            end
          else
            bAttack = true
          end
        end
        if bAttack then
          FubenAttack(tObj[1].id, nil, bUseJinJi, nil, bCheckPet, bMustAttack)
        elseif bIsSafe then
          FubenAttack(-1)
        end
      elseif RunTo(boss.x, boss.y, 0, 500) == false then
        FubenAttack(tObj[1].id)
      end
    else
      PickUpLua()
      if RunTo(boss.x, boss.y, 0, 800) == false then
        break
      end
    end
    Sleep(100)
    DebugStr("琅嬛福地:天山童姥 " .. debugnote)
  end
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
  LHFD_boss_finish(m_finish.boss2, boss, tpos)
end

local function Boss3BaGua(tid)
  CDG.call.back1 = nil
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByClass("NPC")
    local runpos = {x = -1, y = -1}
    for i = 1, #tObj do
      if string.find(tObj[i].name, "八卦安全区", nil, true) then
        runpos.x, runpos.y = tObj[i].x, tObj[i].y
        break
      end
    end
    if runpos.x > 0 and runpos.y > 0 then
      FastRun(runpos, 3)
      if RunTo(runpos.x, runpos.y, 2, 500) == false then
        if -1 == tid then
          debugnote = " 躲阵"
        end
        FubenAttack(-1)
      end
    else
      local bBaGua = false
      for i = 1, #tObj do
        if string.find("乾坤震巽坎离艮兑", tObj[i].name, nil, true) then
          if RunTo(m_pos[3].x, m_pos[3].y, 1, 200) == false then
            if -1 ~= tid then
              debugnote = " 躲阵中"
            end
            FubenAttack(-1)
          end
          bBaGua = true
          break
        end
      end
      if false == bBaGua then
        break
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地：无崖子八卦阵")
  end
  CDG.call.back1 = m_param.callback
end

local function Boss3JSPZ(hp)
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local emYXJX = CDG.hp.em_yxjx
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  CDG.hp.em_yxjx = false
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName("击杀破阵", {
      0,
      1,
      0,
      0
    }, {0, -1}, 1, 0)
    local xSafe, ySafe, tid = -1, -1, -1
    if #tObj > 0 then
      xSafe, ySafe, tid = tObj[1].x, tObj[1].y, tObj[1].id
    end
    if xSafe > 0 and ySafe > 0 and tid > 0 then
      if GetDist(xSafe, ySafe) > 3 then
        Skill:UseSpeed()
        RunTo(xSafe, ySafe, 0, 250)
      else
        local bCheckHP = false
        if hp < 18 then
          FubenAttack(tid, true, false, bCheckHP, false, true, true)
        else
          FubenAttack(tid, true, true, bCheckHP, false, true, true)
        end
      end
    else
      break
    end
    Sleep(50)
    DebugStr("琅嬛福地：无崖子破阵集火攻击")
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  CDG.hp.em_yxjx = emYXJX
end

local function Boss3XianJin(hp, bCallBack)
  local boss = m_pos[3]
  CDG.call.back1 = nil
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local specName = " 凌波微步伤害陷阱 黑白棋陷阱展示 黑棋陷阱 白棋陷阱 "
    local tAllSpec = EnumUnSafeSpecial()
    local tSpecial = ObjFilterByName(tAllSpec, specName, 3)
    local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
    if #tSpecial > 0 then
      local bIsSafe = false
      local param = {}
      param.useqg = false
      if tSpecial[1].name == "黑白棋陷阱展示" or tSpecial[1].name == "黑棋陷阱" or tSpecial[1].name == "白棋陷阱" then
        bIsSafe = FubenTrapRun("", boss.x, boss.y, 5, 18, tSpecial, nil, FubenRunSafe, nil, nil, param)
      else
        bIsSafe = FubenTrapRun("", boss.x, boss.y, 7, 18, tSpecial, nil, FubenRunSafe, nil, nil, param)
      end
      if bIsSafe then
        if bCallBack then
          debugnote = " 已安全"
        end
        local tObj = Enum2XByName("无崖子" .. m_param.bossNameBZ, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          hp = tmp.hp
          CheckDistAttack(tmp, false)
        else
          FubenAttack(-1)
        end
      end
    else
      break
    end
    if hp < 20 then
      local tObj = Enum2XByClass("NPC")
      local bOver = false
      for i = 1, #tObj do
        if string.find(tObj[i].name, "黑水NPC", nil, true) then
          bOver = true
          break
        end
      end
      if bOver then
        break
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地：躲避无崖子陷阱." .. debugnote)
  end
  CDG.call.back1 = m_param.callback
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss3_hs_fl()
  if Player:IsLeader() then
    return 0
  end
  local leader = Team:GetLeaderInfo()
  if not leader then
    PushColorMsg("无崖子:跟随队长时未获取到队长信息")
    return 0
  end
  if 0 == leader.hp then
    PushDebugMessage("无崖子:跟随队长时队长死亡")
    return 0
  end
  local xPos, yPos = leader.x, leader.y
  local nearLeader = FindObjByGUID(leader.guid)
  if nearLeader then
    xPos, yPos = nearLeader.x, nearLeader.y
  end
  if GetDist(m_pos[3].x, m_pos[3].y, xPos, yPos) < 25 then
    if GetDist(xPos, yPos) < 1 then
    else
      local runpos = {x = xPos, y = yPos}
      FastRun(runpos, 4)
      return 2
    end
  else
    PushColorMsg("无崖子:跟随队长时队长位置非boss区域！")
    return 0
  end
  return 1
end

local function Boss3_get_hs()
  local tHeiS = {}
  local tObj = Enum2XByClass("NPC")
  for i = 1, #tObj do
    if string.find(tObj[i].name, "黑水NPC", nil, true) then
      local szR = string.gsub(tObj[i].name, "黑水NPC", "")
      local r = tonumber(szR)
      if type(r) ~= "number" or r <= 0 then
        r = 4
      end
      local n = #tHeiS + 1
      tHeiS[n] = {}
      tHeiS[n] = tObj[i]
      tHeiS[n].r = r
    end
  end
  BubbleByDst(tHeiS, 1)
  return tHeiS
end

local function Boss3HeiShui()
  local boss = m_pos[3]
  local bHaveHeiShui = false
  local allpos = GetAveragePoint(boss.x, boss.y, 17, 72, 0)
  CDG.call.back1 = nil
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  if 4 ~= g_self.menpai then
    CDG.pet3.GUID = 0
  end
  CDG.pet2.GUID = 0
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tHeiS = Boss3_get_hs()
    if bHaveHeiShui and 0 == #tHeiS then
      Sleep(200)
      tHeiS = Boss3_get_hs()
    end
    local bIsSelfSafe = true
    if #tHeiS > 0 then
      bHaveHeiShui = true
      local nflag = 0
      if m_param.hsFollow then
        nflag = Boss3_hs_fl()
      end
      if 0 == nflag then
        local rReal = 14
        if tHeiS[1].r > 14 then
          rReal = 25
        elseif tHeiS[1].r > 9 then
          rReal = 22
        elseif tHeiS[1].r > 4 then
          rReal = 18
        end
        for i = 1, #tHeiS do
          if tHeiS[i].dst < 14 or rReal > GetDist(tHeiS[1].x, tHeiS[1].y) then
            bIsSelfSafe = false
            break
          end
        end
        if false == bIsSelfSafe then
          local safepos1 = {}
          for i = rReal, 14, -1 do
            safepos1 = GetAllSafePos(tHeiS, allpos, i)
            if #safepos1 > 0 then
              break
            end
          end
          if 0 == #safepos1 then
            PushColorMsg("琅嬛福地：躲避黑水时没有找到安全坐标!")
            break
          end
          for i = 1, #safepos1 do
            safepos1[i].angle = GetAngle(boss.x, boss.y, safepos1[i].x, safepos1[i].y)
          end
          local angleSpecial = GetAngle(boss.x, boss.y, tHeiS[1].x, tHeiS[1].y)
          local safepos_2 = {}
          for i = 1, #safepos1 do
            if angleSpecial < safepos1[i].angle then
              table.insert(safepos_2, safepos1[i])
            end
          end
          local runpos = {x = -1, y = -1}
          if 0 == #safepos_2 then
            BubbleSort(safepos1, "angle", 1)
            runpos.x, runpos.y = safepos1[1].x, safepos1[1].y
          else
            BubbleSort(safepos_2, "angle", 1)
            runpos.x, runpos.y = safepos_2[1].x, safepos_2[1].y
          end
          if runpos.x > 0 and runpos.y > 0 then
            local nTick = GetTickCount()
            while GetTickCount() - nTick < 6000 do
              local temp = Boss3_get_hs()
              if false == IsPosSafe(runpos, temp, 13) or FastRun(runpos, 4) or GetDist(runpos.x, runpos.y) < 2 then
                break
              end
              Sleep(50)
              PushDebugMessage("黑水跑位 %s,%s", math.floor(runpos.x), math.floor(runpos.y))
            end
            RunTo(runpos.x, runpos.y, 0, 600)
          else
            bIsSelfSafe = true
            PushColorMsg("无崖子:躲避黑水,没有合适的坐标！")
          end
        end
      end
      if 2 ~= nflag then
        local temp = Boss3_get_hs()
        local tObj = Enum2XByName("无崖子" .. m_param.bossNameBZ, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if 0 == #temp or temp[1].dst >= 14 then
          if #tObj > 0 then
            local bJinJiSkill = true
            CheckDistAttack(tObj[1], false, bJinJiSkill)
          else
            FubenAttack(-1, nil, nil, true, false)
          end
        else
          PushDebugMessage("走位中.")
          if 1 == nflag and #tObj > 0 then
            FubenAttack(tObj[1].id, nil, nil, true, false)
          end
        end
      else
        debugnote = " 跟随队长走位中"
      end
    else
      if false == bHaveHeiShui then
        break
      end
      local tObj = Enum2XByName("无崖子" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if 0 == #tObj or 0 == tObj[1].hp then
        PickUpLua()
        break
      else
        PushColorMsg("搜索黑水")
        local bHas = false
        for i = 1, 8 do
          local temp = Boss3_get_hs()
          if #temp > 0 then
            bHas = true
            break
          end
          Sleep(100)
          FubenAttack(-1, nil, nil, true, false)
        end
        if false == bHas then
          PushColorMsg("未发现黑水,攻击无崖子")
          FubenAttack(tObj[1].id, nil, nil, nil, false)
        end
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地：黑水集火攻击" .. debugnote)
  end
  if bHaveHeiShui then
    PushDebugMessage("躲避黑水完成")
  end
  CDG.call.back1 = m_param.callback
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss3OnAction()
  local boss = m_pos[3]
  local tLast = {
    x = boss.x,
    y = boss.y
  }
  local tick_follow = -1
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("无崖子" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      tLast.x, tLast.y = tObj[1].x, tObj[1].y
      if 0 == tObj[1].hp then
        m_finish.boss3 = true
        break
      end
      if tObj[1].hp < 21 then
        Boss3HeiShui()
      end
      Boss3BaGua(tObj[1].id)
      Boss3JSPZ(tObj[1].hp)
      Boss3XianJin(tObj[1].hp, false)
      local bCheckPet = true
      local bUseSkill = true
      local tid = tObj[1].id
      if tObj[1].hp < 21 then
        bUseSkill = false
        if m_param.hsFollow == false or Player:IsLeader() then
          if tObj[1].hp < 18 and tObj[1].hp > 10 and RunTo(182, 188, 3, 650) then
            tid = -1
            bCheckPet = false
          end
        elseif tObj[1].hp < 18 and m_param.hsFollow and GetTickCount() - tick_follow > 10000 then
          if 2 == Boss3_hs_fl() then
            debugnote = " 跟随队长."
            tid = -1
          else
            tick_follow = GetTickCount()
          end
        end
      end
      if tObj[1].hp > 9 then
        if tObj[1].hp > 30 and false == g_self.isjingong then
          local dist = 6
          if 4 == g_self.menpai then
            dist = 4
          end
          if false == RunTo(boss.x, boss.y, dist, 300) then
            FubenAttack(tid, bUseSkill, false, true, bCheckPet)
          else
            debugnote = " 靠近中心点"
          end
        else
          FubenAttack(tid, bUseSkill, false, true, bCheckPet)
        end
      else
        local bUseJinJi = false
        if tObj[1].hp < 7 then
          bUseJinJi = true
          debugnote = " 集火攻击"
        end
        FubenAttack(tid, true, bUseJinJi, true, false)
      end
    else
      PickUpLua()
      if false == RunTo(boss.x, boss.y, 1, 800) then
        break
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地:无崖子" .. debugnote)
  end
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
  LHFD_boss_finish(m_finish.boss3, boss, tpos)
end

local function Boss4XianJin(bCallBack)
  local boss = m_pos[4]
  CDG.call.back1 = nil
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local specName = " 韦陀掌伤害陷阱 罗汉拳伤害陷阱 "
    local tAllSpec = EnumUnSafeSpecial()
    local tSpecial = ObjFilterByName(tAllSpec, specName, 3)
    local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
    if #tSpecial > 0 then
      local param = {}
      param.useqg = false
      local bIsSafe, tSpecial = FubenTrapRun("虚竹" .. m_param.bossNameBZ, boss.x, boss.y, 7, 15, tSpecial, nil, FubenRunSafe, nil, nil, param)
      if bIsSafe then
        if bCallBack then
          debugnote = " 已安全"
        end
        local tObj = Enum2XByName("虚竹" .. m_param.bossNameBZ, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          CheckDistAttack(tmp, false)
        else
          FubenAttack(-1)
        end
      end
    else
      break
    end
    Sleep(20)
    DebugStr("虚竹:躲避伤害陷阱" .. debugnote)
  end
  CDG.call.back1 = m_param.callback
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss4HeiBaQi(tid)
  local boss = m_pos[4]
  CDG.call.back1 = nil
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local specName = "珍珑棋局"
    local tAllSpec = EnumUnSafeSpecial()
    local tSpecial = ObjFilterByName(tAllSpec, specName, 5)
    if #tSpecial > 0 then
      local param = {}
      param.useqg = false
      local bIsSafe = FubenTrapRun("", boss.x, boss.y, 4, 16, tSpecial, nil, FubenRunSafe, nil, nil, param)
      if bIsSafe then
        if -1 == tid then
          debugnote = " 已安全"
        end
        local tmp = FindObjByTID(tid)
        CheckDistAttack(tmp, false)
      end
    else
      break
    end
    Sleep(80)
    DebugStr("虚竹:躲避棋局" .. debugnote)
  end
  CDG.call.back1 = m_param.callback
end

local function Boss4LiuYangZ()
  local tarName = ""
  local tSafePos = {
    {x = 74, y = 170},
    {x = 93, y = 170},
    {x = 74, y = 190},
    {x = 93, y = 190}
  }
  local bHasMsg, strDbgMsg, nSpecTime = IsInDebugMsgTime("LHFD_160203_92", false, 15)
  if bHasMsg then
    local str1 = string.sub(strDbgMsg, 22, -1)
    local posEnd = string.find(str1, "*")
    if posEnd then
      tarName = string.sub(str1, 0, posEnd - 1)
    end
  end
  if bHasMsg and os.time() - nSpecTime <= 7 and "" ~= tarName and tarName == g_self.name then
    GetAllPosDist(tSafePos)
    BubbleByDst(tSafePos, 1)
    while IsInDebugMsgTime("LHFD_160203_92", false, 7) do
      if FastRun(tSafePos[1], 4) then
        local tObj = Enum2XByName("虚竹" .. m_param.bossNameBZ, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        CheckDistAttack(tObj[1], true)
      end
      Sleep(100)
      DebugStr(tarName .. ":将被使用六阳掌")
    end
  end
  if bHasMsg and "" ~= tarName and tarName ~= g_self.name then
    local xZero, yZero = -1, -1
    while FubenCheckSceneDie(m_param.sceneID) do
      local debugnote = ""
      local tObj = Enum2XByClass("玩家 NPC")
      local bHaveLYZ = false
      for i = 1, #tObj do
        if tObj[i].class == "NPC" and tObj[i].name == "六阳掌力" then
          bHaveLYZ = true
        end
      end
      if false == bHaveLYZ then
        for i = 1, #tObj do
          if tObj[i].class == "玩家" and tObj[i].name and "" ~= tObj[i].name and tarName == tObj[i].name then
            xZero, yZero = tObj[i].x, tObj[i].y
            break
          end
        end
      end
      local tBoss = Enum2XByName("虚竹" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if xZero > 0 and yZero > 0 then
        local dist = GetDist(xZero, yZero)
        local cmpPos = Player:GetPos()
        if g_self.isjingong and CDG.attack and #tBoss > 0 then
          dist = GetDist(xZero, yZero, tBoss[1].x, tBoss[1].y)
          cmpPos = tBoss[1]
        end
        if dist < 7 then
          dist = 7
        end
        local tPos = GetAveragePoint(xZero, yZero, dist, 6, 0)
        tPos = GetAllPosDist(tPos, cmpPos, "dst")
        BubbleByDst(tPos, 1)
        local runpos = {x = -1, y = -1}
        for i = 1, #tPos do
          runpos.x, runpos.y = tPos[i].x, tPos[i].y
          if GetDist(m_pos[4].x, m_pos[4].y, runpos.x, runpos.y) < 15 then
            break
          end
        end
        if runpos.x > 0 and runpos.y > 0 then
          debugnote = " 移动到坐标 " .. runpos.x .. "," .. runpos.y
          if false == RunTo(runpos.x, runpos.y, 0, 200) then
            if #tBoss > 0 then
              CheckDistAttack(tBoss[1], false)
            else
              FubenAttack(-1)
            end
          end
        else
          PushColorMsg("六阳掌没有安全坐标.")
        end
      elseif #tBoss > 0 then
        FubenAttack(tBoss[1].id)
      else
        FubenAttack(-1)
      end
      if os.time() - nSpecTime > 10 and false == bHaveLYZ then
        break
      end
      Sleep(50)
      DebugStr("虚竹:躲避六阳掌 " .. debugnote)
    end
  end
end

local function Boss4OnAction()
  local boss = m_pos[4]
  local tLast = {
    x = boss.x,
    y = boss.y
  }
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("虚竹" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      tLast.x, tLast.y = tObj[1].x, tObj[1].y
      if 0 == tObj[1].hp then
        m_finish.boss4 = true
        break
      end
      if tObj[1].title == "逍遥真身" then
        Boss4LiuYangZ()
        Boss4HeiBaQi(tObj[1].id)
      elseif tObj[1].title == "少林真身" then
        Boss4XianJin()
      else
        PushDebugMessage("琅嬛福地:Boss4未读取到虚竹状态")
        Boss4XianJin()
        Boss4LiuYangZ()
        Boss4HeiBaQi(tObj[1].id)
      end
      FubenAttack(tObj[1].id)
    else
      PickUpLua()
      if RunTo(boss.x, boss.y, 1, 800) == false then
        break
      end
    end
    Sleep(80)
    DebugStr("琅嬛福地:虚竹")
  end
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
  LHFD_boss_finish(m_finish.boss4, boss, tpos)
end

local function LHFD_OnAction(nIndex)
  local boss = m_pos[nIndex]
  local tObj = Enum2XByName(" 李秋水" .. m_param.bossNameBZ .. " 天山童姥" .. m_param.bossNameBZ .. " 无崖子" .. m_param.bossNameBZ .. " 虚竹" .. m_param.bossNameBZ .. " ", {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if 0 == #tObj then
    if GetDist(boss.x, boss.y) > 3 then
      RelivePlayer(2, -1, -1, -1, -1, true)
      MoveTo(boss.x, boss.y, -1, 1, nil, nil, LHFD_cb_inscene)
      Sleep(1500)
    else
      local tObj = Enum2XByName(boss.npc, {
        1,
        1,
        0,
        0
      }, nil, nil, 0)
      if nIndex < 4 and 0 == #tObj then
        Sleep(3000)
        tObj = Enum2XByName(boss.npc, {
          1,
          1,
          0,
          0
        }, nil, nil, 0)
        if 0 == #tObj then
          PushColorMsg(m_script_name .. " :未找到 " .. boss.npc .. " 前往下一个boss")
          if 1 == nIndex then
            LHFD_SetFinishState(true, false, false, false)
          elseif 2 == nIndex then
            LHFD_SetFinishState(true, true, false, false)
          elseif 3 == nIndex then
            LHFD_SetFinishState(true, true, true, false)
          elseif 4 == nIndex then
            LHFD_SetFinishState(true, true, true, true)
          end
          return
        end
      end
    end
  end
  local maxTime = 30
  local checkTime = -1
  while true do
    if FubenCheckSceneDie(m_param.sceneID) == false then
      return
    end
    local tmp = Enum2XByName(boss.npc, {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tmp > 0 then
      MPCheck100(m_param.mustMP100)
      FubenAttack(-1)
      if Player:IsLeader() then
        CheckAllTeamHP(85, LHFD_cb_checkhp, 100)
        local bCheck, name = Team:CheckPetXueJiCD(5)
        if bCheck then
        else
          DebugStr("等待峨嵋 %s 血祭冷却,暂不开怪! %d秒超时", 2, name, maxTime)
        end
        if -1 == checkTime then
          checkTime = GetTickCount()
        end
        if GetTickCount() - checkTime > maxTime * 1000 then
          bCheck = true
        end
        if bCheck then
          RunTo(boss.x, boss.y, 2, 1000)
          TalkNpc(boss.npc)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{LHFD_160203_28}", 1, 500)
        end
      else
        TeamDispersedStations(boss, 3)
      end
    else
      break
    end
    Sleep(500)
    DebugStr("琅嬛福地：开启" .. boss.npc)
  end
  CloseWindow("Quest")
  for i = 1, 3 do
    if g_self.isjingong then
      TeamDispersedStations(boss, 3)
    else
      TeamDispersedStations(boss, 6)
    end
    PlayerStateTimeOut(2, 5)
  end
  m_step = nIndex
  if 1 == nIndex then
    Boss1OnAction()
  elseif 2 == nIndex then
    Boss2OnAction()
  elseif 3 == nIndex then
    Boss3OnAction()
  elseif 4 == nIndex then
    Boss4OnAction()
  end
  RelivePlayer(2, -1, -1, -1, -1, true)
end

local function LHFD_OnProcess()
  local tObj = Enum2XByClass("怪物 NPC")
  local tAll = ObjFilterByHP(tObj, 0, 1)
  for i = 1, #tAll do
    local tmp = tAll[i]
    if tmp.name == "李秋水" or tmp.name == "李秋水" .. m_param.bossNameBZ then
      LHFD_SetFinishState(false, false, false, false)
      LHFD_OnAction(1)
      return
    elseif tmp.name == "天山童姥" or tmp.name == "天山童姥" .. m_param.bossNameBZ then
      LHFD_SetFinishState(true, false, false, false)
      LHFD_OnAction(2)
      return
    elseif tmp.name == "无崖子" or tmp.name == "无崖子" .. m_param.bossNameBZ then
      LHFD_SetFinishState(true, true, false, false)
      LHFD_OnAction(3)
      return
    elseif tmp.name == "虚竹" or tmp.name == "虚竹" .. m_param.bossNameBZ then
      LHFD_SetFinishState(true, true, true, false)
      LHFD_OnAction(4)
      return
    end
  end
  if m_finish.boss4 then
    return
  elseif m_finish.boss3 then
    LHFD_SetFinishState(true, true, true, false)
    LHFD_OnAction(4)
    return
  elseif m_finish.boss2 then
    LHFD_SetFinishState(true, true, false, false)
    LHFD_OnAction(3)
    return
  elseif m_finish.boss1 then
    LHFD_SetFinishState(true, false, false, false)
    LHFD_OnAction(2)
    return
  end
  for i = 1, 4 do
    if GetDist(m_pos[i].x, m_pos[i].y) < 30 then
      if 4 == i then
        LHFD_SetFinishState(true, true, true, false)
        LHFD_OnAction(4)
        return
      elseif 3 == i then
        LHFD_SetFinishState(true, true, false, false)
        LHFD_OnAction(3)
        return
      elseif 2 == i then
        LHFD_SetFinishState(true, false, false, false)
        LHFD_OnAction(2)
        return
      end
    end
  end
  PickUpLua()
  LHFD_OnAction(1)
end

local function LHFD_OnDie()
  DieRelive(0)
  local tObj = Enum2XByName(" 李秋水 天山童姥 无崖子 虚竹 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    PushColorMsg(m_script_name .. ":已经灭队，自动出窍！")
    DieRelive(-1)
  else
    local bHave, HPValue = Team:IsSceneHaveFammily(nil, 4)
    if false == bHave or 0 == HPValue then
      Sleep(4000)
      bHave, HPValue = Team:IsSceneHaveFammily(nil, 4)
      if false == bHave or 0 == HPValue then
        PushDebugMessage("福地副本：峨嵋已出或者已死亡,自动出窍")
        DieRelive(-1)
      end
    end
  end
  return false
end

local function LHFD_action_callback()
  if 1 == m_step then
    Boss1Jian(-1)
  elseif 2 == m_step then
    Boss2Special()
  elseif 3 == m_step then
    Boss3BaGua(-1)
    Boss3XianJin(100, true)
    Boss3HeiShui()
  elseif 4 == m_step then
    Boss4XianJin(true)
    Boss4HeiBaQi(-1)
  end
  return true
end

function LHFD_Start(aParam)
  m_param = aParam
  CDG.call.back1 = LHFD_action_callback
  m_param.callback = LHFD_action_callback
  while GetSceneID() == m_param.sceneID do
    local debugnote = ""
    FuBenCheckDie(false, true, LHFD_OnDie)
    PickUpLua()
    local tObj = Enum2XByName("李青萝", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 and math.floor(tObj[1].y) == 181 then
      PushColorMsg("琅嬛福地:已完成!")
      SDQY_HuoDong()
      local pos = m_pos[4]
      MoveToNPC("李青萝", pos.x, pos.y, -1, 3, nil, nil, LHFD_cb_inscene)
      Sleep(300)
      QuestFrameOptionClicked_Item("#{LHFD_160203_26}", 1, 800)
      MessageBox_Self_OK_Clicked(500)
      debugnote = "离开副本."
    else
      LHFD_OnProcess()
    end
    Sleep(50)
    DebugStr(m_param.sceneName .. "：副本中 " .. debugnote, 3)
  end
end
