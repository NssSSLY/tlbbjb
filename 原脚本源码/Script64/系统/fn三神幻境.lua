-- 反编译自 dfz64.dll 内嵌字节码 004d098b（unluac 2025-12-23；仅供分析）
local m_param = {}
local m_finish = {
  boss1 = false,
  boss2 = false,
  boss3 = false
}
local m_boss = {
  {
    x = 54,
    y = 113,
    obstacle = "苍凌子",
    allmonster = " 被封印的裂海玄蜥 裂海玄蜥 裂海魔龙 "
  },
  {
    x = 126,
    y = 65,
    obstacle = "苍凌子",
    allmonster = " 被封印的炼狱凤凰 炼狱凤凰 灭世火凤 "
  },
  {
    x = 132,
    y = 152,
    allmonster = " 被封印的摄灵蛊花 摄灵蛊花 噬魂花妖 毒花 毒种籽 "
  }
}
local m_allbossName = " 被封印的裂海玄蜥 裂海玄蜥 裂海魔龙 被封印的炼狱凤凰 炼狱凤凰 灭世火凤 被封印的摄灵蛊花 摄灵蛊花 噬魂花妖 毒花 毒种籽 "

local function sshj_find_all()
  local tObj = Enum2XByName(m_allbossName, {
    1,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    return true
  end
  return false
end

local function sshj_cb_inscene(fX, fY, nScene)
  DebugStr(m_param.sceneName .. "：移动到坐标%s,%s", 2, fX, fY)
  PickUpLua()
  if sshj_find_all() then
    return false
  end
  return FubenCheckSceneDie(m_param.sceneID)
end

local function SSHJ_OpenBox()
  local boss = m_boss[3]
  if GetDist(boss.x, boss.y) > 7 then
    MoveTo(boss.x, boss.y, -1, 1, nil, nil, sshj_cb_inscene)
  end
  local boxName = "三神宝箱"
  local strOption = "#{SSHJ_150915_65}"
  while GetSceneID() == m_param.sceneID do
    TalkNpc(boxName)
    Sleep(1500)
    QuestFrameOptionClicked_Item("#{SSHJ_150915_92}", 1, 1500)
    local bClick = false
    if m_param.keyBox and Bag:GetItemCount("天星灵符") > 0 then
      QuestFrameOptionClicked_Item("#{SSHJ_201030_3}", 1, 1500)
      bClick = true
    end
    if m_param.ybBox and not bClick then
      PushColorMsg("三神幻境：您设置了元宝领取双倍奖励！")
      if Player:GetDataInt("YUANBAO") >= 240 then
        if QuestFrameOptionClicked_Item("SSHJ_150915_66", 0, 1500) then
          MessageBox_Self_OK_Clicked(500)
          bClick = true
        end
      else
        PushDebugMessage("三神幻境：您元宝不足，无法领取双倍！直接获取奖励")
      end
    end
    if not bClick then
      QuestFrameOptionClicked_Item("#{SSHJ_150915_65}", 1, 1500)
    end
    MessageBox_Self2_OK_Clicked(1000)
    Sleep(500)
    local strText = GetNPCEventList_Item(0)
    if "#{SSHJ_150915_71}" == strText then
      break
    end
    PickUpLua()
    DebugStr("三神幻境：开启宝箱.")
  end
end

local function SSHJ_FindSealBoss()
  local tObj = Enum2XByName(" 被封印的裂海玄蜥 被封印的炼狱凤凰 被封印的摄灵蛊花 ", {
    1,
    0,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    return true
  end
  return false
end

local function SSHJ_FindSpecial()
  local tAllSpec = EnumUnSafeSpecial()
  local tObj = ObjFilterByName(tAllSpec, " 刺骨寒霜 狂风暴雨 冰雪连天 百毒缠灵 ", 3)
  if #tObj > 0 then
    local r = 6
    if tObj[1].name == "冰雪连天" then
      r = 4
    end
    return tObj, r
  end
  tObj = {}
  for i = 1, #tAllSpec do
    if string.find(tAllSpec[i].name, "谁入地狱", nil, true) or string.find(tAllSpec[i].name, "烈焰焚身", nil, true) then
      table.insert(tObj, tAllSpec[i])
    end
  end
  if #tObj > 0 then
    return tObj, 11
  end
  if #tAllSpec > 0 and tAllSpec[1].name ~= "BOSS1变身" and tAllSpec[1].name ~= "BOSS2变身" and tAllSpec[1].name ~= "BOSS3变身" then
    PushColorMsg("三神未知的陷阱：" .. tAllSpec[1].name)
  end
  return {}, 0
end

local function SSHJ_TrapRun(aBossIndex)
  local boss = m_boss[aBossIndex]
  local tSpec, r = SSHJ_FindSpecial()
  local bSafe = true
  local param = {}
  if 1 == aBossIndex then
    param.useqg = false
  elseif 2 == aBossIndex then
    param.useqg = false
    param.sort_boss = false
  end
  if #tSpec > 0 then
    bSafe = FubenTrapRun(" 裂海玄蜥 裂海魔龙 炼狱凤凰 灭世火凤 ", boss.x, boss.y, r, 15, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

local function SSHJ_Boss1(nMemIndex)
  local isDoAction = false
  local boss = m_boss[1]
  local tpos = GetAveragePoint(boss.x, boss.y, 6, 6, 0)
  local bIsSafe, tSpecial = SSHJ_TrapRun(1)
  if bIsSafe then
    local tObj = Enum2XByName(" 裂海玄蜥 裂海魔龙 ", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      local tid = tmp.id
      if 0 == #tSpecial and 6 == tmp.state then
        local param = {}
        param.useqg = false
        bIsSafe, _ = FubenTrapRun("", boss.x, boss.y, 10, 15, tObj, nil, FubenRunSafe, nil, nil, param)
        if bIsSafe then
          FubenAttack(-1)
        end
      else
        if #tSpecial > 0 then
          if g_self.isjingong then
            if tmp.dst > 3 then
              DebugStr("三神幻境：Boss1躲避陷阱,近攻暂时不打", 2)
              if tmp.dst <= 15 then
                JinGongFarSkill(tmp.id)
              end
              tid = -1
            end
          elseif tmp.dst > 15 then
            DebugStr("三神幻境：Boss1躲避陷阱,远攻距离过远暂时不打", 2)
            tid = -1
          end
        end
        FubenAttack(tid)
      end
      isDoAction = true
    end
  else
    DebugStr("三神幻境：Boss1躲避陷阱", 2)
    isDoAction = true
  end
  return isDoAction
end

local function SSHJ_Boss2_Huo(aIsCallBack)
  local boss = m_boss[2]
  local bIsSelfInSpecial = false
  local tObj = Enum2XByTitle("#{KBOSS_140805_187", nil, {0, -1}, nil, 5)
  if #tObj > 0 then
    for i = 1, #tObj do
      if tObj[i].name == g_self.name .. "的离火" or tObj[i].name == g_self.name .. "的焱火" then
        bIsSelfInSpecial = true
        break
      end
    end
    if bIsSelfInSpecial then
      local bIsSafe, tSpecial = FubenTrapRun("", boss.x, boss.y, 6, 15, tObj, nil, FubenRunSafe_easy, nil, 12)
      if bIsSafe and not aIsCallBack then
        local bGuid2 = CDG.pet2.GUID
        local bGuid3 = CDG.pet3.GUID
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
        CDG:checktime0()
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
      end
      return true
    else
      BubbleByDst(tObj)
      if tObj[1].dst <= 6 then
        local bIsSafe, tSpecial = FubenTrapRun("", boss.x, boss.y, 6, 7, tObj, nil, FubenRunSafe_easy, nil, 1)
        return true
      end
    end
  end
  return false
end

local function SSHJ_Boss2(nMemIndex)
  local isDoAction = false
  local boss = m_boss[2]
  local tpos = GetAveragePoint(boss.x, boss.y, 6, 6, 0)
  local bIsSafe, tSpecial = SSHJ_TrapRun(2)
  if bIsSafe and 0 == #tSpecial then
    if false == SSHJ_Boss2_Huo(false) then
      if (false == g_self.isjingong or m_param.xiaohao) and nMemIndex >= 0 and nMemIndex <= 5 then
        RunTo(tpos[nMemIndex + 1].x, tpos[nMemIndex + 1].y, 0, 800)
      end
      local tObj = Enum2XByName(" 炼狱凤凰 灭世火凤 ", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      if #tObj > 0 then
        FubenAttack(tObj[1].id)
        isDoAction = true
      end
    else
      DebugStr("三神幻境：Boss2躲火苗 ", 2)
      isDoAction = true
    end
  else
    DebugStr("三神幻境：Boss2躲避陷阱 ", 2)
    if false == bIsSafe then
      isDoAction = true
    end
  end
  return isDoAction
end

local function SSHJ_Boss3(nMemIndex)
  local isDoAction = false
  local boss = m_boss[3]
  local banjin = 6
  if IsInDebugMsgTime("#{MZFB_150810_67}", false, 6) or -1 ~= Player:GetBuff("每秒对周围玩家造成伤害") then
    banjin = 8
  end
  local tpos = GetAveragePoint(boss.x, boss.y, banjin, 6, 0)
  if (g_self.isjingong == false or m_param.xiaohao) and nMemIndex >= 0 and nMemIndex <= 5 then
    RunTo(tpos[nMemIndex + 1].x, tpos[nMemIndex + 1].y, 0, 500)
  end
  local bSafeJG = true
  local bAttack = true
  if IsInDebugMsgTime("#{MZFB_150810_69}", false, 6) or -1 ~= Player:GetBuff("毒蛊入体：该状态消失时会传染给周围玩家。") then
    StateRemoveBad(true, false, false, false, false)
  end
  if g_self.isjingong then
    if IsInDebugMsgTime("#{MZFB_150810_69}", false, 6) or IsInDebugMsgTime("#{MZFB_150810_67}", false, 6) or -1 ~= Player:GetBuff("每秒对周围玩家造成伤害") then
      bSafeJG = false
      bAttack = false
      if nMemIndex >= 0 and nMemIndex <= 5 and FastRun(tpos[nMemIndex + 1], 4) then
        bAttack = true
      end
    else
      local tSpec, r = SSHJ_FindSpecial()
      if #tSpec > 0 then
        bSafeJG = false
        bAttack = false
        local pos = Player:GetPos()
        if IsPosSafe(pos, tSpec, r) then
          bAttack = true
        elseif nMemIndex >= 0 and nMemIndex <= 5 and FastRun(tpos[nMemIndex + 1], 4) then
          bAttack = true
        end
      end
    end
  end
  local tObj = Enum2XByName(" 毒种籽 毒花 ", {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    if g_self.isjingong then
      BubbleByDst(tObj, 1)
    else
      BubbleByHP(tObj, 1)
    end
    DebugStr("三神幻境：集火攻击毒种籽、毒花", 2)
    if false == bSafeJG then
      if bAttack then
        if tObj[1].dst < 3 then
          FubenAttack(tObj[1].id)
        else
          JinGongFarSkill(tObj[1].id)
        end
      end
    else
      local bGuid2 = CDG.pet2.GUID
      local bGuid3 = CDG.pet3.GUID
      if 4 ~= g_self.menpai then
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
      end
      FubenAttack(tObj[1].id, true, true, true, false)
      CDG.pet2.GUID = bGuid2
      CDG.pet3.GUID = bGuid3
    end
    isDoAction = true
  else
    tObj = Enum2XByName(" 摄灵蛊花 噬魂花妖 ", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if #tObj > 0 then
      if false == bSafeJG then
        if bAttack then
          if tObj[1].dst < 3 then
            FubenAttack(tObj[1].id)
          else
            JinGongFarSkill(tObj[1].id)
          end
        end
      else
        FubenAttack(tObj[1].id)
      end
      isDoAction = true
    end
  end
  return isDoAction
end

local function SSHJ_OnAttack(step)
  local boss = m_boss[step]
  local nMemIndex = Team:GetMyIndex()
  local isDoAction = false
  local ispick = false
  PickUpLua()
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    if SSHJ_FindSealBoss() then
      PushColorMsg("三神幻境：Boss未开启.")
      return
    end
    if 1 == step then
      isDoAction = SSHJ_Boss1(nMemIndex)
    elseif 2 == step then
      isDoAction = SSHJ_Boss2(nMemIndex)
    elseif 3 == step then
      isDoAction = SSHJ_Boss3(nMemIndex)
    end
    if false == isDoAction then
      FubenAttack(-1)
      local tObj = Enum2XByName(boss.allmonster, {
        0,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tObj > 0 then
        if 0 == tObj[1].hp and (tObj[1].name == "裂海魔龙" or tObj[1].name == "灭世火凤" or tObj[1].name == "噬魂花妖") then
          ispick = true
          RunTo(boss.x, boss.y, 0, 800)
          break
        end
      else
        debugnote = "没有找到boss,走向中间"
        if false == RunTo(boss.x, boss.y, 0, 500) then
          break
        end
      end
    end
    DebugStr("三神幻境 " .. debugnote)
    Sleep(10)
  end
  PickUpLua()
  if ispick then
    RelivePlayer(1, nil, nil, nil, nil, true)
    PickUpLua_Boss(30, 15, m_param.sceneID, nil, true)
  end
end

local function SSHJ_CDG_callback()
  local nTick = GetTickCount()
  local step = -1
  for i = 1, 3 do
    if GetDist(m_boss[i].x, m_boss[i].y) < 18 then
      step = i
    end
  end
  while -1 ~= step and GetTickCount() - nTick < 4000 do
    local bSafe, tSpec = SSHJ_TrapRun(step)
    if bSafe and 0 == #tSpec then
      if false == SSHJ_Boss2_Huo(true) then
        break
      end
      DebugStr("三神幻境：躲火苗", 3)
    end
    DebugStr("三神幻境：移动到安全位置", 3)
    Sleep(30)
  end
end

local function SSHJ_OnAction(step)
  PushDebugMessage("三神幻境：第" .. step .. "个Boss")
  local boss = m_boss[step]
  local tObj = Enum2XByName(m_allbossName, {
    1,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if 0 == #tObj or GetDist(tObj[1].x, tObj[1].y) > 15 then
    local runY = boss.y
    if 3 == step then
      runY = 144
    end
    MoveTo(boss.x, runY, -1, 1, nil, nil, sshj_cb_inscene)
    if GetDist(boss.x, boss.y) > 30 then
      return
    end
    tObj = Enum2XByName(boss.allmonster, {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if 0 == #tObj and boss.obstacle and GetDist(boss.x, boss.y) < 5 then
      tObj = Enum2XByName(boss.obstacle, {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if 0 == #tObj then
        PushColorMsg("三神幻境：第" .. step .. "个Boss已完成")
        if 1 == step then
          m_finish.boss1 = true
        elseif 2 == step then
          m_finish.boss1 = true
          m_finish.boss2 = true
        end
        return
      end
    end
  elseif string.find(m_boss[1].allmonster, " " .. tObj[1].name .. " ", nil, true) then
    if 1 ~= step then
      PushColorMsg("三神幻境：进度错误1")
    end
    step = 1
  elseif string.find(m_boss[2].allmonster, " " .. tObj[1].name .. " ", nil, true) then
    if 2 ~= step then
      PushColorMsg("三神幻境：进度错误2")
    end
    step = 2
  end
  boss = m_boss[step]
  local nMemIndex = Team:GetMyIndex()
  CloseWindow("Quest")
  local isNeedPaoWei = false
  while FubenCheckSceneDie(m_param.sceneID) do
    if SSHJ_FindSealBoss() then
      if Player:IsLeader() then
        local tObj = Enum2XByName("苍凌子", {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 and 0 == tObj[1].state then
          if tObj[1].dst < 3 then
            CheckAllTeamHP(85, SSHJ_FindSealBoss, 45)
            TalkNpc("苍凌子")
            isNeedPaoWei = true
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{MZFB_150810_45}", 1, 1000)
          else
            RunTo(tObj[1].x, tObj[1].y, 2, 1000)
          end
        else
          local runY = boss.y
          if 3 == step then
            runY = 144
          end
          RunTo(boss.x, runY, 1, 1000)
        end
      else
        local tpos = GetAveragePoint(boss.x, boss.y, 6, 6, 0)
        if nMemIndex >= 0 and nMemIndex <= 5 then
          RunTo(tpos[nMemIndex + 1].x, tpos[nMemIndex + 1].y, 0, 500)
        end
      end
    else
      local tObj = Enum2XByName(m_allbossName, {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      if 0 == #tObj then
        PushDebugMessage("三神幻境：封印已解开" .. step)
        Sleep(2000)
      end
      break
    end
    FubenAttack(-1)
    DebugStr("三神幻境：等待队长开启Boss" .. step)
    Sleep(200)
  end
  CloseWindow("Quest")
  if isNeedPaoWei then
    local tpos = GetAveragePoint(boss.x, boss.y, 6, 6, 0)
    if nMemIndex >= 0 and nMemIndex <= 5 then
      RunTo(tpos[nMemIndex + 1].x, tpos[nMemIndex + 1].y, 0, 1000)
    end
    PlayerStateTimeOut(2, 4, nil)
  end
  if 1 == step or 2 == step then
    CDG.call.back1 = SSHJ_CDG_callback
  end
  SSHJ_OnAttack(step)
  CDG.call.back1 = nil
end

local function SSHJ_OnProcess()
  local tAll = Enum2XByClass("怪物 NPC")
  for i = 1, #tAll do
    local tmp = tAll[i]
    if 0 == tmp.hp then
      RelivePlayer(1, nil, nil, nil, nil, true)
      if tmp.name == "裂海魔龙" then
        m_finish = {
          boss1 = true,
          boss2 = false,
          boss3 = false
        }
      elseif tmp.name == "灭世火凤" then
        m_finish = {
          boss1 = true,
          boss2 = true,
          boss3 = false
        }
      end
    end
    if tmp.name == "三神宝箱·人" or tmp.name == "三神宝箱·地" or tmp.name == "三神宝箱·天" then
      m_finish = {
        boss1 = true,
        boss2 = true,
        boss3 = true
      }
      PushColorMsg("三神宝箱已出现,副本结束!")
      return
    end
  end
  local tHuo = ObjFilterByHP(tAll, 0, 1)
  for i = 1, #tHuo do
    local tmp = tHuo[i]
    if tmp.name == "裂海玄蜥" or tmp.name == "裂海魔龙" or tmp.name == "被封印的裂海玄蜥" then
      m_finish = {
        boss1 = false,
        boss2 = false,
        boss3 = false
      }
      SSHJ_OnAction(1)
      return
    elseif tmp.name == "炼狱凤凰" or tmp.name == "灭世火凤" or tmp.name == "被封印的炼狱凤凰" then
      m_finish = {
        boss1 = true,
        boss2 = false,
        boss3 = false
      }
      SSHJ_OnAction(2)
      return
    elseif tmp.name == "毒花" or tmp.name == "毒种籽" or tmp.name == "摄灵蛊花" or tmp.name == "噬魂花妖" or tmp.name == "被封印的摄灵蛊花" then
      m_finish = {
        boss1 = true,
        boss2 = true,
        boss3 = false
      }
      SSHJ_OnAction(3)
      return
    end
  end
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("已杀死裂海魔龙： 1/1")
  local nMsgTime2 = IsInDebugMsg("已杀死灭世火凤： 1/1")
  local nMsgTime3 = IsInDebugMsg("已杀死噬魂花妖：1/1")
  if m_finish.boss3 or nMsgTime3 and nTransTime < nMsgTime3 then
    m_finish = {
      boss1 = true,
      boss2 = true,
      boss3 = true
    }
    return
  elseif m_finish.boss2 or nMsgTime2 and nTransTime < nMsgTime2 then
    m_finish = {
      boss1 = true,
      boss2 = true,
      boss3 = false
    }
    SSHJ_OnAction(3)
    return
  elseif m_finish.boss1 or nMsgTime1 and nTransTime < nMsgTime1 then
    m_finish = {
      boss1 = true,
      boss2 = false,
      boss3 = false
    }
    SSHJ_OnAction(2)
    return
  end
  for i = 1, 3 do
    if GetDist(m_boss[i].x, m_boss[i].y) < 30 then
      if 3 == i then
        m_finish = {
          boss1 = true,
          boss2 = true,
          boss3 = false
        }
        SSHJ_OnAction(3)
        return
      elseif 2 == i then
        m_finish = {
          boss1 = true,
          boss2 = false,
          boss3 = false
        }
        SSHJ_OnAction(2)
        return
      end
    end
  end
  SSHJ_OnAction(1)
end

function SSHJ_Start(aParam)
  m_param = aParam
  local isOpenBox = false
  while GetSceneID() == m_param.sceneID do
    FuBenCheckDie(m_param.swcq, true)
    PickUpLua()
    local nTransTime = GetSceneTransTime()
    local nMsgTime = IsInDebugMsg("已杀死噬魂花妖：1/1")
    if nMsgTime and nTransTime < nMsgTime or m_finish.boss3 == true then
      RelivePlayer(1, nil, nil, nil, nil, true)
      if false == isOpenBox then
        SSHJ_OpenBox()
        isOpenBox = true
      end
      PickUpLua_Boss(40, 15, m_param.sceneID, nil, true)
      PushDebugMessage("三神幻境：离开副本")
      MoveToNPC("苍凌子", 131, 140, -1, nil, nil, nil, sshj_cb_inscene)
      Sleep(800)
      QuestFrameOptionClicked_Item("#{MZFB_150810_49}", 1, 1800)
      QuestFrameOptionClicked_Item("#{SSHJ_20220725_02}", 1, 1800)
      QuestFrameOptionClicked_Item("#{FBCC_201128_07", 3, 700)
      QuestFrameOptionClicked_Item("#{FBCC_201128_11}", 1, 700)
      MessageBox_Self_OK_Clicked()
      Sleep(1500)
    else
      SSHJ_OnProcess()
    end
    Sleep(50)
    DebugStr("三神幻境副本中.", 2)
  end
  m_param = nil
end
