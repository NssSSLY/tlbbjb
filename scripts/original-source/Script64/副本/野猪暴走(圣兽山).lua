-- 反编译自 dfz64.dll 内嵌字节码 0031db5f（unluac 2025-12-23；仅供分析）
local m_script_name = "野猪暴走"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
g_config.yzbz = {}
g_config.yzbz.mode_qiang = false
g_config.yzbz.once = false
g_config.yzbz.pickup = true
g_config.yzbz.overtime = true
local m_param = {}
m_param.mode_qiang = g_config.yzbz.mode_qiang
m_param.sceneID_sss = 201
m_param.sceneID_fb = 232
m_param.once = g_config.yzbz.once
m_param.count = 1
m_param.yn_x = 133
m_param.yn_y = 125
m_param.xh_x = 133
m_param.xh_y = 125
m_param.qpos = {
  {
    x = m_param.yn_x,
    y = m_param.yn_y,
    sceneID = m_param.sceneID_sss
  },
  {
    x = m_param.xh_x,
    y = m_param.xh_y,
    sceneID = m_param.sceneID_sss
  }
}
m_param.TransferItem = false
local m_findNpcPos = {}
m_findNpcPos[201] = {
  {x = 155, y = 222},
  {x = 211, y = 203},
  {x = 229, y = 133},
  {x = 202, y = 141},
  {x = 68, y = 182},
  {x = 105, y = 204},
  {x = 87, y = 174},
  {x = 141, y = 189},
  {x = 211, y = 75},
  {x = 213, y = 34},
  {x = 175, y = 26},
  {x = 153, y = 50},
  {x = 97, y = 58},
  {x = 96, y = 20},
  {x = 84, y = 68},
  {x = 22, y = 160},
  {x = 93, y = 62},
  {x = 97, y = 135},
  {x = 130, y = 141},
  {x = 156, y = 95},
  {x = 130, y = 94},
  {x = 139, y = 131}
}
local m_data = {}
m_data.time = {
  {
    h = 14,
    m = 0,
    eh = 16,
    em = 40
  },
  {
    h = 21,
    m = 30,
    eh = 23,
    em = 59
  }
}
m_data.isRunInHuoDongTime = false
m_data.robpos = {}

local function SZ_FindNPC()
  local tObj = Enum2XByTitle("灵兽", {
    1,
    0,
    0,
    0
  }, nil, 1, 0)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

local function YZ_OnAction()
  local nMemIndex = Team:GetMyIndex()
  if nMemIndex > 2 then
    nMemIndex = nMemIndex - 3
  end
  local tPos = GetAveragePoint(89, 64, 3, 3, 0)
  local pos = {}
  if tPos[nMemIndex + 1] then
    table.insert(pos, tPos[nMemIndex + 1])
  else
    pos = {
      {x = 89, y = 64}
    }
  end
  CDG.sceneID = m_param.sceneID_fb
  if g_self.isjingong then
    CDG.attackMode = "打死换怪"
  else
    CDG.attackMode = "优先绿怪"
  end
  CDG.pickup = g_config.yzbz.pickup
  CDG.overMapErr = true
  CDG.die.out = true
  if g_self.isjingong then
    CDG.posRadius = 15
  else
    CDG.posRadius = 8
  end
  CDG.tragetSelect = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  CDG.pos = pos
  
  local function CDG_loop_callback(...)
    if GetSceneID() ~= m_param.sceneID_fb then
      return true
    end
    Player:TeamFollow(false, 500)
    local tObj = Enum2XByName("野猪头目", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 and 0 == tObj[1].hp then
      PushDebugMessage(m_script_name .. ":野猪头目已死亡")
      return true
    end
    if 4 == g_self.menpai then
      local tar = SZ_FindNPC()
      if tar and tar.hp < 70 then
        Skill:UseSkillByName("清心普善咒", tar.id, -1, -1, 900)
      end
    end
    local nTransTimeDiff = GetChangeSceneTimeDiff()
    DebugStr(m_script_name .. ":正在刷猪,已进行%d分%d秒", 2, math.floor(nTransTimeDiff / 60), math.floor(nTransTimeDiff % 60))
    if nTransTimeDiff > 1800 then
      PushColorMsg(m_script_name .. ":本次副本超时半小时，离开副本")
      return true
    end
    return false
  end
  
  local function sf_move_cb_in_fb(fX, fY, nScene)
    if GetSceneID() ~= m_param.sceneID_fb then
      return false
    end
    return true
  end
  
  CDG.callfun = CDG_loop_callback
  CDG.callfun_move = sf_move_cb_in_fb
  CDG:OnStart()
  local pickPos
  local tObj = Enum2XByName("野猪头目", {
    0,
    1,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 then
    pickPos = {
      {
        x = tObj[1].x,
        y = tObj[1].y
      }
    }
  end
  PickUpLua_Boss(15, 15, m_param.sceneID_fb, pickPos)
  PickUpLua(nil, true)
  if pickPos then
    RunTo(pickPos[1].x, pickPos[1].y, 1, 2000)
    PlayerStateTimeOut(2, 5)
    PickUpLua(nil, true)
  end
  while GetSceneID() == m_param.sceneID_fb do
    MoveTo(237, 234, m_param.sceneID_fb, nil, nil, nil, sf_move_cb_in_fb)
    Sleep(1000)
    MoveConfirm()
    Sleep(600)
    DebugStr(m_script_name .. ":离开副本.")
  end
end

local function YZ_GetTimeInfo()
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
    local maxtime = 8400
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

local function YZ_player_follow()
  if not Player:IsFollow() then
    UseMount()
    DebugStr(m_script_name .. ":跟着队长找灵兽")
    
    local function dy_cb(fX, fY, nScene)
      local leader, isleader = Team:GetLeaderInfo()
      if leader and leader.sceneID == m_param.sceneID_fb then
        return false
      end
      if GetSceneID() == m_param.sceneID_fb then
        return false
      end
      return MoveCallBack_GoToLeader(fX, fY, nScene)
    end
    
    GoToLeader(dy_cb, nil, true, true)
  else
    if IsKVKSceneName() then
      Player:TeamFollow(false, 300)
    end
    DebugStr(m_script_name .. ":组队跟随")
  end
end

local function sf_movecb_findNPC(fX, fY, nScene)
  local curSceneID = GetSceneID()
  if curSceneID == m_param.sceneID_fb then
    return false
  end
  if not Player:IsLeader() then
    return false
  end
  if SZ_FindNPC() then
    return false
  end
  if not Player:IsFollow() then
    UseMount()
    Player:TeamFollow(true, 300)
  end
  return true
end

local function YZ_Qiang()
  local pos = m_data.robpos
  MoveTo(pos.x, pos.y, pos.sceneID, nil, nil, nil, sf_movecb_findNPC, true, m_param.TransferItem)
  if not IsMount() then
    Player:TeamFollow(false, 300)
    UseMount()
  end
  if IsMount() then
    Player:TeamFollow(true, 300)
  end
  DoSystem(1001, g_self.isjingong, Skill.baseID, 100, 65000, 5)
  DoSystem(1002, 1)
  RecvState(16)
  while GetSceneID() == pos.sceneID do
    local tNpc = SZ_FindNPC()
    if tNpc then
      SP_OpenTalkAndClickedOption(tNpc.id, 402102, -1)
      Sleep(20)
      if tNpc.dst > 3 then
        RunTo(tNpc.x, tNpc.y, 2, 500)
      end
    else
      DebugStr(m_script_name .. ":非活动时间抢点坐标等待刷新")
      local tstep = YZ_GetTimeInfo()
      if tstep.rob == false then
        PushColorMsg(m_script_name .. ":已经过了抢的时间,寻找NPC")
        break
      end
      if false == IsDestination(pos.x, pos.y, pos.sceneID, 2) then
        MoveTo(pos.x, pos.y, pos.sceneID, nil, nil, nil, sf_movecb_findNPC)
      end
    end
    Sleep(10)
    if not Player:IsLeader() or 9 == Player:GetState() then
      break
    end
  end
  DoSystem(1004)
  Player:TeamFollow(true, 300)
end

function _SMain()
  LeaveSpecialScene({
    m_param.sceneID_fb
  }, nil)
  InitServerTime()
  m_data.robpos = m_param.qpos[2]
  local tmpstep = YZ_GetTimeInfo()
  if 1 == tmpstep.step then
    m_data.robpos = m_param.qpos[1]
  end
  
  local function SZ_FindAndTalkNPC()
    local tar = SZ_FindNPC()
    if tar then
      PushDebugMessage("发现灵兽！")
      GoToScene(tar.x, tar.y, m_param.sceneID_sss, 5)
      Sleep(400)
      OpenTalk(tar.id, 300)
      QuestFrameOptionClicked_Item("拯救灵兽", 1, 800)
      return true
    end
    return false
  end
  
  local posIndex = 1
  if GetSceneID() == m_param.sceneID_sss then
    posIndex = GetNearestPoint(m_findNpcPos[m_param.sceneID_sss])
  end
  local lastFindTime = GetTickCount()
  local currentCount = 0
  while true do
    local curScene = GetSceneID()
    if curScene == m_param.sceneID_fb then
      YZ_OnAction()
      currentCount = currentCount + 1
      if m_param.once and currentCount >= m_param.count then
        PushColorMsg("野猪暴走:您设置只刷" .. m_param.count .. "轮")
        break
      end
      lastFindTime = GetTickCount()
    else
      local tstep = {rob = false}
      if m_param.mode_qiang then
        tstep = YZ_GetTimeInfo()
      end
      if tstep.rob then
        if m_data.isRunInHuoDongTime then
          PushColorMsg(m_script_name .. "：活动已经结束")
          break
        end
        if Player:IsLeader() then
          YZ_Qiang()
        else
          YZ_player_follow()
        end
        lastFindTime = GetTickCount()
      else
        m_data.isRunInHuoDongTime = true
        if g_config.yzbz.overtime and GetTickCount() - lastFindTime > 600000 then
          PushColorMsg(m_script_name .. ":已经10分钟没有进入副本")
          break
        end
        if Player:IsLeader() then
          DebugStr(m_script_name .. ":队长寻找灵兽.")
          local searchPos = m_findNpcPos[m_param.sceneID_sss]
          if posIndex > #searchPos then
            posIndex = 1
          end
          local tmp = searchPos[posIndex]
          if curScene ~= m_param.sceneID_sss or not SZ_FindAndTalkNPC() then
            MoveTo(tmp.x, tmp.y, m_param.sceneID_sss, nil, nil, nil, sf_movecb_findNPC, true, m_param.TransferItem)
            if not SZ_FindAndTalkNPC() then
              posIndex = posIndex + 1
            end
          end
        else
          YZ_player_follow()
        end
      end
    end
    Sleep(100)
  end
  Player:TeamFollow(false, 500)
  if GetSceneID() == 201 then
    GoToScene(282, 64, 112)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_findNpcPos = nil
