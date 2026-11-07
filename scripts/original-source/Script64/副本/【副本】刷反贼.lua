-- 反编译自 dfz64.dll 内嵌字节码 002b54ac（unluac 2025-12-23；仅供分析）
local m_script_name = "刷反贼"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
g_config.shuafan = {}
g_config.shuafan.once = false
g_config.shuafan.pickup = true
g_config.shuafan.scene = {
  sel = -1,
  text = "",
  data = 0
}
g_config.shuafan.scene.sel = ReadConfigInt("ZH", "zhk43")
g_config.shuafan.overtime = false
local m_param = {}
m_param.sceneID = 170
m_param.maxtime = 10
m_param.TransferItem = false
local m_findNpcPos = {
  [6] = {
    {x = 63, y = 172},
    {x = 69, y = 162},
    {x = 75, y = 167},
    {x = 82, y = 191},
    {x = 64, y = 189},
    {x = 68, y = 207},
    {x = 90, y = 210},
    {x = 50, y = 230},
    {x = 50, y = 250},
    {x = 49, y = 266},
    {x = 70, y = 270},
    {x = 132, y = 249},
    {x = 202, y = 230},
    {x = 248, y = 238},
    {x = 231, y = 249},
    {x = 238, y = 224},
    {x = 180, y = 180},
    {x = 148, y = 179},
    {x = 132, y = 196},
    {x = 99, y = 167},
    {x = 120, y = 160},
    {x = 142, y = 154},
    {x = 158, y = 150},
    {x = 180, y = 150},
    {x = 190, y = 140},
    {x = 175, y = 130},
    {x = 172, y = 122},
    {x = 200, y = 90},
    {x = 198, y = 88},
    {x = 184, y = 86},
    {x = 186, y = 79},
    {x = 185, y = 63},
    {x = 170, y = 50},
    {x = 149, y = 50},
    {x = 129, y = 50},
    {x = 110, y = 50},
    {x = 90, y = 50},
    {x = 70, y = 50},
    {x = 93, y = 69},
    {x = 41, y = 75},
    {x = 47, y = 109},
    {x = 50, y = 130}
  },
  [7] = {
    {x = 46, y = 275},
    {x = 70, y = 271},
    {x = 80, y = 248},
    {x = 66, y = 247},
    {x = 51, y = 241},
    {x = 48, y = 197},
    {x = 47, y = 181},
    {x = 49, y = 153},
    {x = 49, y = 133},
    {x = 56, y = 128},
    {x = 46, y = 52},
    {x = 90, y = 47},
    {x = 147, y = 52},
    {x = 153, y = 70},
    {x = 158, y = 81},
    {x = 173, y = 92},
    {x = 224, y = 43},
    {x = 270, y = 60},
    {x = 270, y = 47},
    {x = 273, y = 83},
    {x = 262, y = 104},
    {x = 231, y = 126},
    {x = 222, y = 129},
    {x = 221, y = 148},
    {x = 213, y = 157},
    {x = 178, y = 195},
    {x = 168, y = 229},
    {x = 97, y = 203},
    {x = 108, y = 221},
    {x = 119, y = 236},
    {x = 132, y = 238},
    {x = 114, y = 260},
    {x = 127, y = 261},
    {x = 133, y = 271},
    {x = 161, y = 257},
    {x = 202, y = 244},
    {x = 258, y = 228},
    {x = 278, y = 275},
    {x = 233, y = 268},
    {x = 219, y = 270},
    {x = 197, y = 270},
    {x = 187, y = 272},
    {x = 133, y = 271},
    {x = 89, y = 269}
  },
  [4] = {
    {x = 212, y = 272},
    {x = 242, y = 267},
    {x = 255, y = 264},
    {x = 272, y = 218},
    {x = 269, y = 203},
    {x = 267, y = 191},
    {x = 249, y = 188},
    {x = 239, y = 184},
    {x = 232, y = 219},
    {x = 238, y = 229},
    {x = 236, y = 237},
    {x = 222, y = 228},
    {x = 213, y = 223},
    {x = 198, y = 241},
    {x = 190, y = 234},
    {x = 170, y = 210},
    {x = 181, y = 202},
    {x = 192, y = 190},
    {x = 167, y = 189},
    {x = 189, y = 174},
    {x = 202, y = 142},
    {x = 211, y = 152},
    {x = 221, y = 139},
    {x = 240, y = 143},
    {x = 250, y = 143},
    {x = 237, y = 120},
    {x = 224, y = 118},
    {x = 240, y = 102},
    {x = 223, y = 102},
    {x = 178, y = 93},
    {x = 167, y = 92},
    {x = 220, y = 87},
    {x = 181, y = 52},
    {x = 195, y = 44},
    {x = 198, y = 48},
    {x = 238, y = 62},
    {x = 275, y = 70},
    {x = 281, y = 116},
    {x = 195, y = 43},
    {x = 182, y = 50},
    {x = 168, y = 52},
    {x = 162, y = 47},
    {x = 111, y = 52},
    {x = 127, y = 72},
    {x = 126, y = 96},
    {x = 130, y = 107},
    {x = 107, y = 99},
    {x = 110, y = 110},
    {x = 112, y = 121},
    {x = 133, y = 129},
    {x = 137, y = 137},
    {x = 152, y = 145},
    {x = 148, y = 147},
    {x = 162, y = 148},
    {x = 129, y = 150},
    {x = 118, y = 139},
    {x = 111, y = 147},
    {x = 120, y = 210},
    {x = 109, y = 229},
    {x = 93, y = 241},
    {x = 104, y = 250},
    {x = 53, y = 220},
    {x = 40, y = 236},
    {x = 87, y = 271},
    {x = 132, y = 265},
    {x = 174, y = 254}
  },
  [8] = {
    {x = 279, y = 180},
    {x = 249, y = 169},
    {x = 240, y = 168},
    {x = 229, y = 152},
    {x = 229, y = 81},
    {x = 249, y = 65},
    {x = 266, y = 58},
    {x = 266, y = 41},
    {x = 200, y = 89},
    {x = 169, y = 96},
    {x = 188, y = 151},
    {x = 169, y = 157},
    {x = 158, y = 180},
    {x = 113, y = 99},
    {x = 69, y = 91},
    {x = 52, y = 111},
    {x = 94, y = 108},
    {x = 108, y = 116},
    {x = 108, y = 146},
    {x = 92, y = 145},
    {x = 70, y = 140},
    {x = 112, y = 171},
    {x = 120, y = 179},
    {x = 87, y = 173},
    {x = 73, y = 168}
  },
  [3] = {
    {x = 52, y = 50},
    {x = 66, y = 92},
    {x = 62, y = 110},
    {x = 80, y = 131},
    {x = 83, y = 140},
    {x = 86, y = 200},
    {x = 69, y = 199},
    {x = 63, y = 190},
    {x = 52, y = 187},
    {x = 85, y = 143},
    {x = 117, y = 138},
    {x = 148, y = 160},
    {x = 144, y = 190},
    {x = 137, y = 206},
    {x = 132, y = 206},
    {x = 79, y = 243},
    {x = 62, y = 252},
    {x = 180, y = 250},
    {x = 224, y = 249},
    {x = 231, y = 235},
    {x = 235, y = 219},
    {x = 257, y = 190},
    {x = 259, y = 169},
    {x = 270, y = 131},
    {x = 280, y = 117},
    {x = 277, y = 78},
    {x = 211, y = 273},
    {x = 229, y = 273},
    {x = 249, y = 272},
    {x = 267, y = 282},
    {x = 243, y = 253}
  }
}

local function FZ_OnAction()
  CDG.sceneID = m_param.sceneID
  if g_self.isjingong then
    CDG.attackMode = "打死换怪"
  else
    CDG.attackMode = "优先绿怪"
  end
  CDG.pickup = g_config.shuafan.pickup
  CDG.overMapErr = true
  CDG.die.out = true
  CDG.posRadius = 15
  CDG.tragetSelect = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  CDG.pos = {
    {x = 86, y = 91},
    {x = 96, y = 79},
    {x = 99, y = 60},
    {x = 103, y = 51},
    {x = 109, y = 26},
    {x = 100, y = 20},
    {x = 90, y = 20},
    {x = 80, y = 20},
    {x = 72, y = 18},
    {x = 57, y = 20},
    {x = 49, y = 32},
    {x = 43, y = 19},
    {x = 26, y = 24},
    {x = 37, y = 57},
    {x = 40, y = 73},
    {x = 25, y = 89},
    {x = 22, y = 97},
    {x = 20, y = 100}
  }
  CDG.posIdx = GetNearestPoint(CDG.pos)
  CDG:SetTimeOut(100)
  
  local function CDG_loop_callback(...)
    DebugStr("刷反：副本中.")
    if GetSceneID() ~= m_param.sceneID then
      return true
    end
    Player:TeamFollow(false, 300)
    local nTransTime = GetSceneTransTime()
    local nMsgTime1 = IsInDebugMsg("离开场景")
    local nMsgTime2 = IsInDebugMsg("已杀死造反恶贼： 31/31")
    if nMsgTime1 and nTransTime < nMsgTime1 or nMsgTime2 and nTransTime < nMsgTime2 then
      PushDebugMessage("刷反:本次已完成")
      PickUpLua(nil, true)
      UseMount()
      RunTo(22, 97, 1, 1500)
      return true
    end
    return false
  end
  
  local function sf_move_cb_in_fb(fX, fY, nScene)
    if GetSceneID() ~= m_param.sceneID then
      return false
    end
    Player:TeamFollow(false, 300)
    local nTransTime = GetSceneTransTime()
    local nMsgTime1 = IsInDebugMsg("已杀死造反恶贼： 30/31")
    local nMsgTime2 = IsInDebugMsg("已杀死造反恶贼： 31/31")
    if #CDG.pos > 2 and (nMsgTime1 and nTransTime < nMsgTime1 or nMsgTime2 and nTransTime < nMsgTime2) then
      PushDebugMessage("刷反:反贼头目")
      CDG.pos = {
        {x = 20, y = 100}
      }
      CDG.posIdx = 1
      return false
    end
    if CDG.pickup then
      PickUpLua(nil, true)
    end
    return true
  end
  
  CDG.callfun = CDG_loop_callback
  CDG.callfun_move = sf_move_cb_in_fb
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("离开场景")
  local nMsgTime2 = IsInDebugMsg("已杀死造反恶贼： 31/31")
  if nMsgTime1 and nTransTime < nMsgTime1 or nMsgTime2 and nTransTime < nMsgTime2 then
    DebugStr("刷反:本次副本已完成!")
    PickUpLua(nil, true)
    UseMount()
    RunTo(22, 97, 1, 1500)
    IsHuodongComplete("贼兵入侵", 1)
  else
    CDG:OnStart()
  end
end

function _SMain(...)
  LeaveSpecialScene({
    m_param.sceneID
  }, nil)
  
  local function _Qiang()
    local tick_out = GetTickCount()
    local curSceneID = GetSceneID()
    while Player:IsLeader() and not (Team:GetMemberCount() < 3) do
      local tObj = Enum2XByName("造反恶贼", {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        OpenTalk(tmp.id, 300)
        QuestFrameOptionClicked_Item("难道我还怕你不成……", 1, 600)
        if 170 ~= curSceneID and IsDestination(tmp.x, tmp.y, curSceneID, 3) == false then
          GoToScene(tmp.x, tmp.y, curSceneID, 5)
        end
      else
        break
      end
      if GetTickCount() - tick_out > 90000 then
        break
      end
      Sleep(15)
    end
  end
  
  local function SF_FindNPC()
    local curScene = GetSceneID()
    local tObj = Enum2XByName("造反恶贼", {
      1,
      0,
      0,
      0
    }, nil, 1, 0)
    if #tObj > 0 then
      local tmp = tObj[1]
      GoToScene(tmp.x, tmp.y, curScene, 5)
      OpenTalk(tmp.id, 300)
      QuestFrameOptionClicked_Item("难道我还怕你不成……", 1, 600)
      return true
    end
    return false
  end
  
  local function sf_movecb_findNPC(fX, fY, nScene)
    local curSceneID = GetSceneID()
    if curSceneID == m_param.sceneID then
      return false
    end
    if not Player:IsLeader() then
      return false
    end
    if curSceneID == nScene and SF_FindNPC() then
      return false
    end
    if not Player:IsFollow() then
      UseMount()
      Player:TeamFollow(true, 300)
    end
    return true
  end
  
  local allScene = {
    {sceneID = 3, sceneName = "嵩山"},
    {sceneID = 8, sceneName = "敦煌"},
    {sceneID = 4, sceneName = "太湖"},
    {sceneID = 7, sceneName = "剑阁"},
    {sceneID = 6, sceneName = "无量山"}
  }
  local tarScene = allScene[g_config.shuafan.scene.sel]
  if nil == tarScene then
    local curScene = GetSceneID()
    local tGet = GetTableFieldValue(allScene, "sceneID", {curScene})
    if #tGet > 0 then
      tarScene = tGet[1]
    else
      math.randomseed(GetTickCount())
      tarScene = allScene[math.random(1, #allScene)]
    end
  end
  local posIndex = 1
  if GetSceneID() == tarScene.sceneID then
    posIndex = GetNearestPoint(m_findNpcPos[tarScene.sceneID])
  end
  local lastFindTime = GetTickCount()
  while true do
    local curScene = GetSceneID()
    if curScene == m_param.sceneID then
      while GetSceneID() == m_param.sceneID do
        FZ_OnAction()
        Sleep(100)
        DebugStr("反贼副本中...")
      end
      if g_config.shuafan.once then
        PushColorMsg("刷反:您设置只刷一轮")
        break
      end
      lastFindTime = GetTickCount()
    elseif IsHuodongComplete("贼兵入侵", 1) then
      Sleep(2000)
      if GetSceneID() ~= m_param.sceneID and IsHuodongComplete("贼兵入侵", 1, true) then
        PushColorMsg("刷反:已刷满")
        break
      end
    else
      if g_config.shuafan.overtime and m_param.maxtime > 0 and GetTickCount() - lastFindTime > m_param.maxtime * 60 * 1000 then
        PushColorMsg("刷反:已经" .. m_param.maxtime .. "分钟没有进入副本")
        Sleep(2000)
        if GetSceneID() ~= m_param.sceneID then
          break
        end
      end
      if Player:IsLeader() then
        DebugStr("刷反:队长寻找造反恶贼.")
        local searchPos = m_findNpcPos[tarScene.sceneID]
        if posIndex > #searchPos then
          posIndex = 1
        end
        local tmp = searchPos[posIndex]
        if curScene ~= tarScene.sceneID or false == SF_FindNPC() then
          MoveTo(tmp.x, tmp.y, tarScene.sceneID, nil, nil, nil, sf_movecb_findNPC, true, m_param.TransferItem)
          if false == SF_FindNPC() then
            posIndex = posIndex + 1
          end
        else
          PushColorMsg("刷反:发现npc,开始抢进副本")
          _Qiang()
        end
      elseif not Player:IsFollow() then
        UseMount()
        DebugStr("刷反:队员跟着队长寻找反贼")
        
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
        
        GoToLeader(dy_cb, nil, true, true)
      else
        if IsKVKSceneName() then
          Player:TeamFollow(false, 300)
        end
        DebugStr("刷反:队员组队跟随寻找反贼")
        Sleep(500)
      end
    end
    Sleep(80)
  end
  Player:TeamFollow(false, 300)
  GoBackCity()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_findNpcPos = nil
