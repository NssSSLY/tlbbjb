-- 反编译自 dfz64.dll 内嵌字节码 002eb7bd（unluac 2025-12-23；仅供分析）
local m_script_name = "天降奇兽"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.attack = true
g_pick.check = true
m_pos1 = {
  {x = 166, y = 250},
  {x = 161, y = 221},
  {x = 153, y = 206},
  {x = 121, y = 178},
  {x = 109, y = 151},
  {x = 88, y = 149},
  {x = 66, y = 138},
  {x = 142, y = 134},
  {x = 143, y = 160},
  {x = 182, y = 153},
  {x = 175, y = 81},
  {x = 140, y = 88},
  {x = 123, y = 78},
  {x = 126, y = 41},
  {x = 159, y = 45}
}
m_pos2 = {
  {x = 289, y = 267},
  {x = 261, y = 264},
  {x = 234, y = 228},
  {x = 243, y = 100},
  {x = 255, y = 39},
  {x = 237, y = 47},
  {x = 77, y = 44},
  {x = 33, y = 49},
  {x = 73, y = 81},
  {x = 99, y = 197},
  {x = 63, y = 199},
  {x = 40, y = 217},
  {x = 103, y = 233}
}
local m_param = {}
m_param.unfind_timeout = ReadConfigInt("ZH", "bjk166")
m_param.pos1_x = ReadConfigInt("ZH", "bjk19")
m_param.pos1_y = ReadConfigInt("ZH", "bjk163")
m_param.pos2_x = ReadConfigInt("ZH", "bjk164")
m_param.pos2_y = ReadConfigInt("ZH", "bjk165")
m_param.sceneID = 268
local m_data = {}
m_data.findnpc_posindex = 1
m_data.last_findtick = -1
m_data.isRunInHuoDongTime = false
m_data.time = {
  {h = 13, m = 30},
  {h = 18, m = 30},
  {h = 19, m = 0},
  {h = 21, m = 45}
}
m_data.fubenpos = {
  {x = 188, y = 123},
  {x = 178, y = 162},
  {x = 117, y = 152},
  {x = 128, y = 104}
}
m_data.kill_ftm = false
m_data.kill_hdss = false
m_data.robpos = {
  {
    x = 173,
    y = 156,
    sceneID = 246
  },
  {
    x = 237,
    y = 225,
    sceneID = 246
  }
}
if m_param.pos1_x > 0 and m_param.pos1_y > 0 then
  m_data.robpos[1].x = m_param.pos1_x
  m_data.robpos[1].y = m_param.pos1_y
end
if m_param.pos2_x > 0 and m_param.pos2_y > 0 then
  m_data.robpos[2].x = m_param.pos2_x
  m_data.robpos[2].y = m_param.pos2_y
end

local function TJQS_InitFindLuXian()
  local posFile = GetUserScriptPath("坐标天降奇兽.lua")
  if "" ~= posFile then
    if LoadUserPathScript(posFile) == false then
      PushColorMsg("天降奇兽坐标:加载自定义坐标失败,请检查语法或者删除自定义坐标")
    else
      PushColorMsg("已加载用户自定义坐标")
    end
  end
end

local function TJQS_GetTimeInfo()
  local nTime = GetServerTime()
  local nowTime = os.date("*t", nTime)
  local temp = {}
  for i = 1, #m_data.time do
    temp[i] = {}
    temp[i].starttime = os.time({
      year = nowTime.year,
      month = nowTime.month,
      day = nowTime.day,
      hour = m_data.time[i].h,
      min = m_data.time[i].m,
      sec = 0
    })
    local maxtime = 1800
    if 18 == m_data.time[i].h then
      maxtime = 1200
    end
    temp[i].endtime = temp[i].starttime + maxtime
  end
  for i = 1, #temp do
    if nTime > temp[i].starttime + 2 and nTime <= temp[i].endtime then
      return {rob = false, step = i}
    end
  end
  local nTimeStep = -1
  for i = 1, #temp do
    if nTime < temp[i].starttime then
      nTimeStep = i
      break
    end
  end
  return {rob = true, step = nTimeStep}
end

local function TJQS_FindNpcObj()
  local tObj = Enum2XByTitle("千年奇兽", {
    1,
    0,
    0,
    0
  }, nil, 1, 0)
  if #tObj > 0 then
    m_data.last_findtick = GetTickCount()
    return tObj[1]
  end
  return nil
end

local function TJQS_FindAttackObj()
  local tObj = Enum2XByName(" 护岛神兽 无敌飞天猫 ", {
    0,
    1,
    0,
    0
  }, {0, -1}, 3, 3)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

local function TJQS_FindDieObj()
  local tObj = Enum2XByName(" 护岛神兽 无敌飞天猫 ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  for i = 1, #tObj do
    local tmp = tObj[i]
    if 0 == tmp.hp then
      if tmp.name == "护岛神兽" then
        m_data.kill_hdss = true
      elseif tmp.name == "无敌飞天猫" then
        m_data.kill_ftm = true
      end
    end
  end
end

local function TJQS_RefreshDieObj()
  if GetSceneID() == m_param.sceneID then
    TJQS_FindDieObj()
  else
    m_data.kill_hdss = false
    m_data.kill_ftm = false
  end
end

local function TJQS_LeaveScene_Player()
  while GetSceneID() == m_param.sceneID do
    local nDiff = GetChangeSceneTimeDiff()
    if nDiff < 20 then
      PushColorMsg("天降奇兽：刚进副本 ")
      break
    end
    local leader, isleader = Team:GetLeaderInfo()
    if not leader or isleader or leader.sceneID == m_param.sceneID then
      break
    end
    local leaderObj = FindObjByGUID(leader.guid)
    if leaderObj then
      break
    end
    Player:TeamFollow(false, 300)
    PickUpLua()
    Sleep(300)
    DieOutAndGetPos()
    if 0 == Player:GetState() then
      RunTo(76, 70, 0, 3000)
    end
    RunTo(70, 67, 0)
    Sleep(1000)
    DebugStr("队长不在副本,离开副本.")
  end
end

local function TJQS_LeaveScene_Leader()
  while GetSceneID() == m_param.sceneID and Player:IsLeader() do
    local nDst = GetDist(70, 69)
    if nDst > 15 then
      if not Player:IsFollow() then
        UseMount()
        Sleep(2000)
      end
      Player:TeamFollow(true, 300)
      RunTo(70, 67, 0, 1000)
    elseif nDst < 5 then
      Player:TeamFollow(false, 300)
      RunTo(70, 67)
    else
      RunTo(70, 67)
    end
    if nDst < 1 then
      RunTo(76, 70)
      Sleep(3000)
    end
    PickUpLua()
    Sleep(300)
    DebugStr("Boss已经打完,准备离开副本")
  end
end

local function TJQS_leader_kill(aTarget)
  local xLast, yLast = aTarget.x, aTarget.y
  local nFindTime = GetTickCount()
  while true do
    local tTmp = FindObjByTID(aTarget.id)
    if not tTmp then
      RunTo(xLast, yLast, 1, 1500)
      if GetTickCount() - nFindTime > 15000 then
        PushColorMsg("15秒未找到攻击目标:" .. aTarget.name)
        break
      end
    else
      nFindTime = GetTickCount()
      xLast = tTmp.x
      yLast = tTmp.y
      RunTo(tTmp.x, tTmp.y, 4, 1000)
      if 0 == tTmp.hp then
        TJQS_FindDieObj()
        PickUpLua()
        PickUpLua_Boss(5, 5, m_param.sceneID)
        break
      else
        FubenAttack(tTmp.id)
      end
    end
    Sleep(300)
    DebugStr("正在杀" .. aTarget.name)
  end
end

local function TJQS_ld_cb(fX, fY, nScene)
  TJQS_RefreshDieObj()
  PickUpLua()
  if not Player:IsLeader() then
    return false
  end
  if GetSceneID() ~= m_param.sceneID then
    return false
  end
  local target = TJQS_FindAttackObj()
  if target then
    RunTo(target.x, target.y, 1, 300)
    return false
  end
  if not Player:IsFollow() then
    UseMount()
    Sleep(2000)
    Player:TeamFollow(true, 300)
  end
  return true
end

local function TJQS_dy_cb(fX, fY, nScene)
  TJQS_RefreshDieObj()
  PickUpLua()
  if GetSceneID() ~= m_param.sceneID then
    return false
  end
  local leader, isleader = Team:GetLeaderInfo()
  if isleader or not leader then
    return false, nil
  end
  if leader.sceneID ~= m_param.sceneID then
    return false
  end
  return MoveCallBack_GoToLeader(fX, fY, nScene)
end

local function TJQS_OnAction()
  local idx = 1
  local nTickOut = GetTickCount()
  while GetSceneID() == m_param.sceneID do
    if Player:IsLeader() then
      local target = TJQS_FindAttackObj()
      if target then
        TJQS_leader_kill(target)
      else
        if GetTickCount() - nTickOut > 600000 then
          LogMsg(m_script_name .. ":副本内超时")
          TJQS_LeaveScene_Leader()
        end
        if m_data.kill_hdss and m_data.kill_ftm then
          TJQS_LeaveScene_Leader()
        else
          if idx > #m_data.fubenpos then
            idx = 1
          end
          MoveTo(m_data.fubenpos[idx].x, m_data.fubenpos[idx].y, -1, 3, true, nil, TJQS_ld_cb)
          if not TJQS_FindAttackObj() then
            idx = idx + 1
          end
        end
      end
    elseif Player:IsFollow() then
      DebugStr("天降奇兽：组队跟随中.")
      local leader, isleader = Team:GetLeaderInfo()
      if leader and leader.sceneID ~= m_param.sceneID then
        Player:TeamFollow(false, 300)
      end
    else
      local nFollowDist = 4
      local target = TJQS_FindAttackObj()
      if target then
        nFollowDist = 8
        FubenAttack(target.id)
      else
        TJQS_LeaveScene_Player()
      end
      GoToLeader(TJQS_dy_cb, nil, nil, nil, nFollowDist)
    end
    PickUpLua()
    TJQS_RefreshDieObj()
    DieOutAndGetPos()
    Sleep(200)
    DebugStr("天降奇兽：副本中")
  end
  PickUpLua()
end

local function TJQS_leader_findObj(aStep)
  local pos = m_pos1
  if aStep > 2 then
    pos = m_pos2
  end
  
  local function _findNpc(aX, aY, aSceneID)
    if IsInFubenScene() then
      PushDebugMessage("天降奇兽:当前在副本地图")
      return false
    end
    if TJQS_FindNpcObj() then
      return false
    end
    return MoveCallBack_Default(aX, aY, aSceneID)
  end
  
  local tNpc = TJQS_FindNpcObj()
  if not tNpc then
    if m_data.findnpc_posindex > #pos then
      m_data.findnpc_posindex = 1
    end
    local run = pos[m_data.findnpc_posindex]
    if run and run.x and run.y then
      MoveTo(run.x, run.y, 246, 3, true, nil, _findNpc)
    else
      DebugColorMsg("天降奇兽:坐标数据有误", 2)
    end
  end
  if nil == tNpc then
    tNpc = TJQS_FindNpcObj()
  end
  if nil == tNpc then
    if GetSceneID() == 246 then
      m_data.findnpc_posindex = m_data.findnpc_posindex + 1
    end
  else
    SP_OpenTalkAndClickedOption(tNpc.id, 808121, 1)
    Sleep(100)
    if GetDist(tNpc.x, tNpc.y) > 3 then
      GoToScene(tNpc.x, tNpc.y, 246, 5)
    end
  end
end

local function TJQS_player_follow_loulan()
  if Player:IsFollow() then
    if IsKVKSceneName() then
      Player:TeamFollow(false, 300)
    end
    Sleep(600)
  else
    UseMount()
    
    local function dy_cb(fX, fY, nScene)
      local leader, isleader = Team:GetLeaderInfo()
      if leader and leader.sceneID == m_param.sceneID then
        return false
      end
      if GetSceneID() == m_param.sceneID then
        return false
      end
      return MoveCallBack_GoToLeader(fX, fY, nScene)
    end
    
    GoToLeader(dy_cb)
  end
end

local function TJQS_Qiang(step)
  local pos = m_data.robpos[1]
  if step > 2 then
    pos = m_data.robpos[2]
  end
  GoToScene(pos.x, pos.y, pos.sceneID)
  if not IsMount() then
    Player:TeamFollow(false, 300)
    UseMount()
  end
  if IsMount() then
    Player:TeamFollow(true, 300)
  end
  DoSystem(1001, g_self.isjingong, Skill.baseID, 100, 65000, 4)
  DoSystem(1002, 1)
  RecvState(16)
  while GetSceneID() == pos.sceneID do
    local tNpc = TJQS_FindNpcObj()
    if tNpc then
      SP_OpenTalkAndClickedOption(tNpc.id, 808121, 1)
      Sleep(20)
      if tNpc.dst > 3 then
        RunTo(tNpc.x, tNpc.y, 2, 500)
      end
    else
      DebugStr("天降奇兽:非活动时间抢点坐标等待刷新")
      local tstep = TJQS_GetTimeInfo()
      if tstep.rob == false then
        PushColorMsg("天降奇兽:已经过了抢的时间,寻找灵兽")
        break
      end
      if false == IsDestination(pos.x, pos.y, pos.sceneID, 2) then
        GoToScene(pos.x, pos.y, pos.sceneID)
      end
    end
    Sleep(10)
    if not Player:IsLeader() then
      break
    end
  end
  DoSystem(1004)
  Player:TeamFollow(true, 300)
end

function _SMain(...)
  LeaveSpecialScene({
    m_param.sceneID
  }, nil)
  InitServerTime()
  TJQS_InitFindLuXian()
  while true do
    if GetSceneID() == m_param.sceneID then
      TJQS_OnAction()
      m_data.last_findtick = GetTickCount()
    else
      m_data.kill_hdss = false
      m_data.kill_ftm = false
      local tstep = TJQS_GetTimeInfo()
      if tstep.rob then
        if m_data.isRunInHuoDongTime then
          LogMsg("天降奇兽：活动已经结束")
          break
        end
        if tstep.step >= 1 and tstep.step <= 4 then
          if Player:IsLeader() then
            TJQS_Qiang(tstep.step)
          else
            TJQS_player_follow_loulan()
          end
          m_data.last_findtick = -1
        else
          DebugStr("天降奇兽：当前可能不是活动时间" .. tstep.step, 2)
        end
      else
        if 2 ~= tstep.step then
          m_data.isRunInHuoDongTime = true
        end
        if -1 == m_data.last_findtick then
          m_data.last_findtick = GetTickCount()
        end
        if tstep.step >= 1 and tstep.step <= 4 then
          if Player:IsLeader() then
            TJQS_leader_findObj(tstep.step)
          else
            TJQS_player_follow_loulan()
          end
        else
          PushDebugMessage("天降奇兽：错误的索引 " .. tstep.step)
        end
      end
      if -1 ~= m_data.last_findtick and GetTickCount() - m_data.last_findtick > m_param.unfind_timeout * 60 * 1000 then
        LogMsg("天降奇兽:" .. m_param.unfind_timeout .. "分钟没找到兽结束！")
        break
      end
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  DoSystem(1004)
  Player:TeamFollow(false, 300)
end

_SMain()
ScriptOnStop(m_script_name, false)
m_param = nil
m_data = nil
