-- 反编译自 dfz64.dll 内嵌字节码 004f727b（unluac 2025-12-23；仅供分析）
g_pick.pickmode = 0
g_pick.check = true
CDG.hp.em_raid = false
local m_param = {}
m_param.xiaohao = false
m_param.yz_unrun = false
m_param.sceneID = 600
m_param.gd_dist = 4
local m_xZero, m_yZero, m_radius = 48, 49, 18
local m_ZouWei = {
  {x = 48, y = 42},
  {x = 54, y = 46},
  {x = 54, y = 53},
  {x = 48, y = 56},
  {x = 42, y = 53},
  {x = 42, y = 46}
}
local m_data = {
  xBf = -1,
  yBf = -1,
  tickBf = -1,
  leaderName = "",
  memberName = "",
  isleader = false
}

function WL_InitData()
  DeleteDebugMsg("XWLFB_140218_112")
  DeleteDebugMsg("XWLFB_140218_27")
  m_data.xBf = -1
  m_data.yBf = -1
  m_data.tickBf = -1
end

function WL_CheckJinRi()
  local bSelfComp = false
  local strText, nListCount = GetNPCEventListAllItem()
  if string.find(strText, "#{XWLFB_140218_17}", nil, true) then
    DebugColorMsg("有队员已刷过！")
    local tMember = Team:GetAllMemberInfo()
    for i = 1, #tMember do
      local tmp = tMember[i]
      if string.find(strText, tmp.name .. [[

#{XWLFB_140218_23}]], nil, true) then
        if tmp.name == g_self.name then
          Team:LeaveTeam()
          bSelfComp = true
          break
        else
          Team:KickTeamMember(tmp.teamIndex)
          break
        end
      end
    end
  end
  return bSelfComp
end

function WL_GetOldTeam()
  if m_data.leaderName == "" and "" == m_data.memberName and Player:IsLeader() then
    m_data.isleader = true
    m_data.memberName = Team:GetAllName()
  elseif m_data.leaderName == "" and m_data.isleader == false and not Player:IsLeader() then
    local tLeader, bIsLeader = Team:GetLeaderInfo()
    if tLeader and not bIsLeader then
      m_data.isleader = false
      m_data.leaderName = tLeader.name
    end
  end
end

function WL_IsOldTeamReady(nWaitTimeOut)
  local outtick = 70000
  if outtick < GetTickCount() - nWaitTimeOut then
    return true
  end
  if m_data.memberName == "" then
    return true
  end
  local allName = Team:GetAllName()
  local arrTeam = Text2Table(m_data.memberName, " ")
  for i = 1, #arrTeam do
    if "" ~= arrTeam[i] and not string.find(allName, arrTeam[i], nil, true) then
      DebugStr(arrTeam[i] .. " 还未加入队伍,70秒超时,还剩" .. math.floor((outtick - (GetTickCount() - nWaitTimeOut)) / 1000) .. "秒")
      return false
    end
  end
  return true
end

local function WL_checkZeroPos(bossname, aDist)
  local dist = aDist or m_radius
  if dist < GetDist(m_xZero, m_yZero) then
    PickUpLua()
    RunTo(m_xZero, m_yZero, 0, 250)
    DebugStr(bossname .. ":前往中心点", 3)
    return false
  end
  return true
end

local function WL_OnNPC(tObj)
  local nDist = 3
  local szTalkNpc = ""
  if g_self.isjingong then
    nDist = 5
  end
  for i = 1, #tObj do
    if tObj[i].name == "长右" then
      if WL_checkZeroPos("长右npc", nDist) and Player:IsLeader() then
        szTalkNpc = tObj[i].name
      end
      break
    elseif tObj[i].name == "蛊雕" then
      if GetDist(tObj[i].x, tObj[i].y, m_xZero, m_yZero) < 3 and Player:IsLeader() then
        szTalkNpc = tObj[i].name
        break
      end
      RunTo(tObj[i].x, tObj[i].y, 0, 300)
      break
    elseif tObj[i].name == "毕方" then
      if WL_checkZeroPos("毕方npc", nDist) and Player:IsLeader() then
        szTalkNpc = tObj[i].name
      end
      break
    elseif tObj[i].name == "毕方幻象" then
      local nMsgTime, szMsgText, nMsgTick = IsInDebugMsg("XWLFB_140218_112")
      if nMsgTime then
        for i = 1, #tObj do
          if string.find(szMsgText, ";" .. tObj[i].id .. ";", nil, true) then
            m_data.xBf = tObj[i].x
            m_data.yBf = tObj[i].y
            m_data.tickBf = GetTickCount()
            break
          end
        end
      else
        PushDebugMessage("未获取到毕方真身数据")
      end
    end
  end
  if "" ~= szTalkNpc then
    TalkNpc(szTalkNpc)
    Sleep(800)
    QuestFrameOptionClicked_Item("#{XWLFB_140218_86}", 1, 1200)
  end
end

local function WL_checkUnSafeState(bIsCallBack)
  local tAllSpec = EnumUnSafeSpecial()
  local tSpecial = ObjFilterByName(tAllSpec, " 冰冻三尺 开明怒火冲天效果陷阱 燃烧的怒火 腐毒缠身 怒火冲天 ", 3)
  local tUnKnow = ObjFilterByName(tAllSpec, " 冰冻三尺 开明怒火冲天效果陷阱 燃烧的怒火 腐毒缠身 怒火冲天 ", 4)
  if -1 == Player:GetBuff("腐尸草") then
    for i = 1, #tUnKnow do
      PushColorMsg("未知的陷阱：" .. tUnKnow[i].name)
    end
    local bIsSafe = true
    local param = {}
    param.useqg = false
    if #tSpecial > 0 then
      bIsSafe = FubenTrapRun("", m_xZero, m_yZero, 7, m_radius, tSpecial, nil, FubenRunSafe, nil, nil, param)
    elseif not m_param.yz_unrun and IsInDebugMsgTime("XWLFB_140218_59", nil, 6) then
      local tObj = Enum2XByName("英招", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tObj > 0 then
        tSpecial = tObj
        bIsSafe = FubenTrapRun("", m_xZero, m_yZero, 8, m_radius, tSpecial, nil, FubenRunSafe, nil, nil, param)
      end
    end
    return bIsSafe, tSpecial
  else
    return false, tSpecial
  end
end

local function WL_CDG_callback()
  local nTick = GetTickCount()
  while GetTickCount() - nTick < 4000 do
    local bIsSafe, tSpecial = WL_checkUnSafeState(true)
    if bIsSafe or 0 == #tSpecial then
      break
    end
    DebugStr("王陵：移动到安全位置", 2)
    Sleep(30)
  end
  return true
end

local function WL_Leave()
  local nMsgTime, szMsgText, nMsgTick = IsInDebugMsg("XWLFB_140218_27", 1)
  if nMsgTime then
    local nDiff = GetChangeSceneTimeDiff()
    if nDiff > 120 and os.time() - nMsgTime < 60 then
      PushDebugMessage("王陵：本次已完成,离开副本！")
      PickUpLua_Boss(30, 20, m_param.sceneID, m_ZouWei, true)
      while GetSceneID() == m_param.sceneID do
        nDiff = GetChangeSceneTimeDiff()
        if nDiff > 120 then
          MoveToNPC("萧陵", 66, 80, m_param.sceneID, nil, false, nil, MoveCallback_InScene)
          Sleep(900)
          nDiff = GetChangeSceneTimeDiff()
          if nDiff > 120 then
            QuestFrameOptionClicked_Item("#{CSFB_KVK_110623_31}", 1, 700)
            QuestFrameOptionClicked_Item("#{WLFB_220726_02}", 1, 700)
            QuestFrameOptionClicked_Item("#{FBCC_201128_07", 3, 700)
            QuestFrameOptionClicked_Item("#{FBCC_201128_11}", 1, 700)
          else
            break
          end
          Sleep(600)
        else
          break
        end
      end
      WL_InitData()
      return true
    else
      PushColorMsg("王陵：存在错误的进度数据，删除！")
    end
  end
  return false
end

local function WL_OnAttack(tObj, tSpecial)
  local tTarget = {}
  local tAttack = ObjFilterByName(tObj, " 腐烂的食物 萧陵 ", 4)
  tTarget = ObjFilterByName(tAttack, " 美味的食物 ", 3)
  if #tTarget > 0 then
    local tKill = {}
    local zero = {x = m_xZero, y = m_yZero}
    GetAllPosDist(tTarget, zero, "dist_zero")
    for j = 1, 12 do
      for i = 1, #tTarget do
        local tmp = tTarget[i]
        if j >= tmp.dist_zero then
          table.insert(tKill, tmp)
        end
      end
      if #tKill > 0 then
        break
      end
    end
    if #tKill > 0 then
      if g_self.isjingong == false then
        WL_checkZeroPos("长右", 5)
        tTarget = tKill
      elseif tKill[1].dist_zero < 8 then
        tTarget = tKill
      end
    end
    if g_self.isjingong then
      BubbleByDst(tTarget, 1)
    else
      local tObj = ObjFilterByDst(tTarget, 15)
      if #tObj > 0 then
        tTarget = tObj
      end
    end
    FubenAttack(tTarget[1].id, true, false, true, false, true)
    return
  end
  tTarget = ObjFilterByName(tAttack, "毕方幻象", 0)
  if #tTarget > 0 then
    for i = 1, #tTarget do
      tTarget[i].dst = GetDist(m_data.xBf, m_data.yBf, tTarget[i].x, tTarget[i].y)
    end
    if -1 == m_data.xBf or -1 == m_data.yBf then
      BubbleByHP(tTarget, 1)
    else
      BubbleByDst(tTarget, 1)
    end
    FubenAttack(tTarget[1].id)
    return
  end
  tTarget = ObjFilterByName(tAttack, "镇魔天雷", 0)
  if #tTarget > 0 then
    BubbleByDst(tTarget, 1)
    local tNPC = Enum2XByName("蛊雕", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tNPC > 0 and GetDist(tNPC[1].x, tNPC[1].y, tTarget[1].x, tTarget[1].y) <= m_param.gd_dist then
      FubenAttack(tTarget[1].id, true, true, true, false, true)
    else
      FubenAttack(-1)
      if #tNPC > 0 then
        RunTo(tNPC[1].x, tNPC[1].y, 1, 300)
      end
    end
    return
  end
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  tTarget = ObjFilterByName(tAttack, " 穷奇·幻 侍魔者 慑魂 ", 3)
  if #tTarget > 0 then
    if g_self.isjingong then
      BubbleByDst(tTarget, 1)
    else
      BubbleByHP(tTarget, 1)
    end
    local bUseJinJiSkill = true
    if tTarget[1].name == "慑魂" then
      bUseJinJiSkill = false
    else
      DebugStr("集火攻击", 3)
      CDG.pet2.GUID = 0
      CDG.pet3.GUID = 0
    end
    local mustAttack = false
    if tTarget[1].name == "侍魔者" or tTarget[1].name == "慑魂" then
      mustAttack = true
    end
    FubenAttack(tTarget[1].id, true, bUseJinJiSkill, true, false, mustAttack)
    CDG.pet2.GUID = bGuid2
    CDG.pet3.GUID = bGuid3
    return
  end
  if m_param.xiaohao then
    local selfTID = Player:GetTID()
    for i = 1, #tAttack do
      if tAttack[i].target == selfTID then
        Skill:UseName("初级隐遁", 300)
      end
    end
  end
  if #tSpecial > 0 and false == m_param.xiaohao then
    local dist = 15
    if g_self.isjingong then
      dist = 2
    end
    local bIsAttack = false
    for i = 1, #tAttack do
      if dist >= tAttack[i].dst then
        bIsAttack = true
        FubenAttack(tAttack[i].id)
      end
    end
    if false == bIsAttack then
      DebugStr("有陷阱,暂不攻击远距离怪", 3)
      if g_self.isjingong and #tAttack > 0 then
        JinGongFarSkill(tAttack[1].id, true)
      else
        FubenAttack(-1)
      end
    end
    return
  end
  if #tAttack > 0 then
    if 0 == #tSpecial and g_self.isjingong == false then
      WL_checkZeroPos("攻击时", 10)
    end
    if 0 == #tSpecial and m_param.xiaohao then
      WL_checkZeroPos("小号", 8)
    end
    FubenAttack(tAttack[1].id)
  end
  return
end

function WL_OnAction(aParam)
  m_param = aParam
  if m_param.gd_dist < 2 then
    m_param.gd_dist = 2
  end
  CDG.call.back1 = WL_CDG_callback
  EatBindItem()
  while GetSceneID() == m_param.sceneID do
    local debugnote = ""
    DieOutAndGetPos()
    local bIsSafe, tSpecial = WL_checkUnSafeState()
    if bIsSafe then
      local tObj = Enum2XByClass("怪物", {0, -1})
      tObj = ObjFilterByName(tObj, " 萧陵 ", 4)
      if #tObj > 0 then
        debugnote = " 打怪"
        WL_OnAttack(tObj, tSpecial)
      else
        FubenAttack(-1)
        tObj = Enum2XByName(" 毕方 蛊雕 长右 毕方幻象 ", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 3)
        if #tObj > 0 then
          debugnote = " 开怪"
          WL_OnNPC(tObj)
        elseif false == WL_Leave() then
          tObj = Enum2XByName(" 蛊雕 镇魔天雷 ", {
            0,
            1,
            0,
            0
          }, nil, nil, 3)
          if 0 == #tObj then
            local nMemIndex = Team:GetMyIndex()
            if nMemIndex >= 0 and nMemIndex <= 5 then
              EatBindItem()
              RunTo(m_ZouWei[nMemIndex + 1].x, m_ZouWei[nMemIndex + 1].y, 0, 300)
            end
          end
        end
      end
    end
    Sleep(10)
    PickUpLua()
    DebugStr("王陵：副本中" .. debugnote)
  end
  CDG.call.back1 = nil
  m_param = nil
end
