-- 反编译自 dfz64.dll 内嵌字节码 002bba5a（unluac 2025-12-23；仅供分析）
local m_script_name = "偷袭门派"
ScriptOnStart(m_script_name, true, false)
g_config.shuaxiao = {}
g_config.shuaxiao.once = false
g_config.shuaxiao.overtime = true
g_config.shuaxiao.maxtime = 10
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
if g_config.nottongbu.fuben_ty_xhmode then
  CDG.attack = false
end
local m_param = {}
m_param.maxtime = HandleTextToNumber(g_config.shuaxiao.maxtime, 10)
local m_xiaoMenpaiID = -1
local m_posIndex = 0
local m_fubenPos = {
  [0] = {
    {x = 95, y = 125},
    {x = 106, y = 103},
    {x = 106, y = 99},
    {x = 88, y = 104},
    {x = 80, y = 91},
    {x = 69, y = 88},
    {x = 70, y = 68},
    {x = 96, y = 90},
    {x = 87, y = 82},
    {x = 104, y = 80},
    {x = 100, y = 72},
    {x = 88, y = 72},
    {x = 95, y = 71}
  },
  [1] = {
    {x = 98, y = 149},
    {x = 98, y = 135},
    {x = 99, y = 117},
    {x = 97, y = 107},
    {x = 77, y = 95},
    {x = 92, y = 92},
    {x = 98, y = 84},
    {x = 112, y = 72},
    {x = 111, y = 57},
    {x = 82, y = 71},
    {x = 98, y = 57},
    {x = 98, y = 44},
    {x = 99, y = 45}
  },
  [2] = {
    {x = 71, y = 95},
    {x = 85, y = 80},
    {x = 46, y = 86},
    {x = 44, y = 108},
    {x = 43, y = 61},
    {x = 63, y = 52},
    {x = 72, y = 66},
    {x = 80, y = 64},
    {x = 58, y = 62}
  },
  [3] = {
    {x = 93, y = 169},
    {x = 103, y = 167},
    {x = 89, y = 138},
    {x = 77, y = 130},
    {x = 72, y = 112},
    {x = 78, y = 110},
    {x = 93, y = 113},
    {x = 78, y = 97},
    {x = 83, y = 84},
    {x = 70, y = 84},
    {x = 46, y = 94},
    {x = 45, y = 58},
    {x = 90, y = 57},
    {x = 86, y = 53}
  },
  [4] = {
    {x = 89, y = 138},
    {x = 92, y = 108},
    {x = 95, y = 91},
    {x = 82, y = 89},
    {x = 65, y = 107},
    {x = 40, y = 110},
    {x = 54, y = 91},
    {x = 51, y = 72},
    {x = 57, y = 57},
    {x = 44, y = 44},
    {x = 35, y = 56},
    {x = 112, y = 111},
    {x = 75, y = 73},
    {x = 93, y = 68},
    {x = 95, y = 40}
  },
  [5] = {
    {x = 95, y = 52},
    {x = 71, y = 57},
    {x = 69, y = 72},
    {x = 89, y = 75},
    {x = 108, y = 71},
    {x = 115, y = 72},
    {x = 96, y = 87},
    {x = 90, y = 98},
    {x = 101, y = 99},
    {x = 97, y = 119},
    {x = 96, y = 129},
    {x = 95, y = 139},
    {x = 95, y = 52}
  },
  [6] = {
    {x = 93, y = 123},
    {x = 107, y = 105},
    {x = 104, y = 91},
    {x = 95, y = 89},
    {x = 85, y = 90},
    {x = 72, y = 107},
    {x = 78, y = 57},
    {x = 64, y = 69},
    {x = 42, y = 57},
    {x = 73, y = 35},
    {x = 96, y = 36},
    {x = 117, y = 36},
    {x = 157, y = 38},
    {x = 138, y = 59},
    {x = 115, y = 73},
    {x = 95, y = 38}
  },
  [7] = {
    {x = 95, y = 118},
    {x = 112, y = 118},
    {x = 78, y = 120},
    {x = 120, y = 97},
    {x = 100, y = 100},
    {x = 83, y = 99},
    {x = 66, y = 102},
    {x = 94, y = 83},
    {x = 97, y = 70},
    {x = 87, y = 69},
    {x = 62, y = 38},
    {x = 60, y = 66},
    {x = 74, y = 48},
    {x = 91, y = 45},
    {x = 103, y = 47},
    {x = 125, y = 37},
    {x = 115, y = 50},
    {x = 94, y = 45}
  },
  [8] = {
    {x = 47, y = 148},
    {x = 53, y = 76},
    {x = 51, y = 56},
    {x = 73, y = 55},
    {x = 105, y = 88},
    {x = 125, y = 95},
    {x = 123, y = 75},
    {x = 144, y = 59},
    {x = 159, y = 58},
    {x = 125, y = 130},
    {x = 143, y = 123},
    {x = 127, y = 154},
    {x = 115, y = 144},
    {x = 76, y = 153},
    {x = 70, y = 136},
    {x = 120, y = 88}
  },
  [10] = {
    {x = 142, y = 157},
    {x = 142, y = 139},
    {x = 146, y = 120},
    {x = 156, y = 82},
    {x = 159, y = 54},
    {x = 168, y = 51},
    {x = 129, y = 38},
    {x = 111, y = 44},
    {x = 67, y = 27},
    {x = 52, y = 30},
    {x = 55, y = 60},
    {x = 67, y = 115},
    {x = 86, y = 114},
    {x = 86, y = 133},
    {x = 69, y = 132},
    {x = 56, y = 135},
    {x = 34, y = 164}
  },
  [11] = {
    {x = 162, y = 152},
    {x = 167, y = 126},
    {x = 160, y = 101},
    {x = 129, y = 68},
    {x = 99, y = 67},
    {x = 40, y = 69},
    {x = 33, y = 80},
    {x = 72, y = 50},
    {x = 76, y = 39},
    {x = 67, y = 32},
    {x = 75, y = 43}
  },
  [12] = {
    {x = 95, y = 146},
    {x = 108, y = 123},
    {x = 108, y = 154},
    {x = 138, y = 146},
    {x = 148, y = 134},
    {x = 155, y = 104},
    {x = 152, y = 89},
    {x = 152, y = 72},
    {x = 137, y = 68},
    {x = 114, y = 78},
    {x = 100, y = 107},
    {x = 85, y = 106},
    {x = 83, y = 121},
    {x = 81, y = 135},
    {x = 79, y = 142},
    {x = 65, y = 141},
    {x = 49, y = 134},
    {x = 34, y = 124},
    {x = 40, y = 106},
    {x = 40, y = 71},
    {x = 55, y = 71},
    {x = 79, y = 87},
    {x = 88, y = 66},
    {x = 104, y = 66},
    {x = 97, y = 61}
  },
  [13] = {
    {x = 246, y = 184},
    {x = 221, y = 189},
    {x = 201, y = 179},
    {x = 183, y = 173},
    {x = 175, y = 162},
    {x = 158, y = 163},
    {x = 158, y = 144},
    {x = 158, y = 114},
    {x = 128, y = 114},
    {x = 117, y = 96},
    {x = 111, y = 84},
    {x = 128, y = 88},
    {x = 167, y = 83},
    {x = 159, y = 60},
    {x = 171, y = 56},
    {x = 160, y = 55}
  },
  [14] = {
    {x = 180, y = 342},
    {x = 178, y = 318},
    {x = 206, y = 316},
    {x = 240, y = 318},
    {x = 257, y = 309},
    {x = 257, y = 279},
    {x = 255, y = 258},
    {x = 245, y = 258},
    {x = 257, y = 224},
    {x = 257, y = 193},
    {x = 255, y = 163}
  },
  [15] = {
    {x = 32, y = 195},
    {x = 44, y = 144},
    {x = 41, y = 115},
    {x = 59, y = 77},
    {x = 65, y = 88},
    {x = 85, y = 98},
    {x = 131, y = 109},
    {x = 120, y = 118},
    {x = 108, y = 58},
    {x = 82, y = 44}
  }
}
local m_scenePos = {
  [9] = {
    {x = 92, y = 130},
    {x = 70, y = 60},
    {x = 67, y = 109},
    {x = 95, y = 139},
    {x = 128, y = 76},
    {x = 133, y = 143},
    {x = 154, y = 144},
    {x = 149, y = 61},
    {x = 48, y = 40},
    {x = 46, y = 141},
    {x = 66, y = 136}
  },
  [11] = {
    {x = 100, y = 167},
    {x = 72, y = 139},
    {x = 83, y = 154},
    {x = 61, y = 117},
    {x = 48, y = 97},
    {x = 39, y = 37},
    {x = 61, y = 36},
    {x = 59, y = 79},
    {x = 86, y = 56},
    {x = 83, y = 39},
    {x = 112, y = 38},
    {x = 110, y = 58},
    {x = 133, y = 51},
    {x = 153, y = 37},
    {x = 154, y = 59},
    {x = 116, y = 139},
    {x = 138, y = 158},
    {x = 154, y = 78}
  },
  [10] = {
    {x = 93, y = 119},
    {x = 72, y = 118},
    {x = 70, y = 92},
    {x = 92, y = 79},
    {x = 76, y = 60},
    {x = 92, y = 46},
    {x = 125, y = 63},
    {x = 106, y = 80},
    {x = 112, y = 117},
    {x = 130, y = 155},
    {x = 152, y = 149},
    {x = 155, y = 92},
    {x = 134, y = 83},
    {x = 155, y = 64},
    {x = 152, y = 37},
    {x = 61, y = 39},
    {x = 45, y = 36},
    {x = 43, y = 147}
  },
  [12] = {
    {x = 101, y = 136},
    {x = 96, y = 112},
    {x = 105, y = 127},
    {x = 78, y = 86},
    {x = 47, y = 55},
    {x = 81, y = 49},
    {x = 97, y = 62},
    {x = 80, y = 135},
    {x = 90, y = 180},
    {x = 50, y = 177},
    {x = 46, y = 139}
  },
  [15] = {
    {x = 86, y = 142},
    {x = 39, y = 152},
    {x = 37, y = 108},
    {x = 40, y = 46},
    {x = 98, y = 39},
    {x = 145, y = 106},
    {x = 146, y = 153},
    {x = 144, y = 43}
  },
  [16] = {
    {x = 99, y = 150},
    {x = 96, y = 84},
    {x = 124, y = 73},
    {x = 144, y = 54},
    {x = 136, y = 36},
    {x = 71, y = 43},
    {x = 71, y = 80},
    {x = 48, y = 65},
    {x = 61, y = 145},
    {x = 91, y = 129},
    {x = 144, y = 140},
    {x = 147, y = 87},
    {x = 96, y = 125}
  },
  [13] = {
    {x = 98, y = 120},
    {x = 66, y = 122},
    {x = 64, y = 146},
    {x = 42, y = 135},
    {x = 24, y = 126},
    {x = 40, y = 80},
    {x = 53, y = 39},
    {x = 153, y = 36},
    {x = 96, y = 79},
    {x = 154, y = 90},
    {x = 154, y = 124},
    {x = 118, y = 124},
    {x = 96, y = 129}
  },
  [17] = {
    {x = 91, y = 119},
    {x = 67, y = 100},
    {x = 40, y = 147},
    {x = 33, y = 95},
    {x = 38, y = 44},
    {x = 66, y = 80},
    {x = 95, y = 100},
    {x = 128, y = 98},
    {x = 146, y = 140},
    {x = 155, y = 45},
    {x = 124, y = 69},
    {x = 117, y = 51},
    {x = 61, y = 42},
    {x = 61, y = 65}
  },
  [14] = {
    {x = 68, y = 143},
    {x = 48, y = 147},
    {x = 49, y = 55},
    {x = 115, y = 88},
    {x = 57, y = 111},
    {x = 89, y = 124},
    {x = 144, y = 154},
    {x = 148, y = 123},
    {x = 159, y = 54},
    {x = 126, y = 43}
  },
  [284] = {
    {x = 29, y = 137},
    {x = 52, y = 162},
    {x = 29, y = 163},
    {x = 29, y = 109},
    {x = 54, y = 62},
    {x = 31, y = 59},
    {x = 87, y = 67},
    {x = 30, y = 28},
    {x = 131, y = 36},
    {x = 167, y = 51},
    {x = 161, y = 97},
    {x = 157, y = 165},
    {x = 134, y = 117},
    {x = 83, y = 162}
  },
  [615] = {
    {x = 126, y = 69},
    {x = 95, y = 102},
    {x = 43, y = 147},
    {x = 121, y = 119},
    {x = 163, y = 156},
    {x = 164, y = 35},
    {x = 78, y = 41},
    {x = 23, y = 23}
  },
  [678] = {
    {x = 86, y = 147},
    {x = 33, y = 133},
    {x = 34, y = 73},
    {x = 18, y = 42},
    {x = 48, y = 23},
    {x = 85, y = 65},
    {x = 161, y = 56},
    {x = 117, y = 24},
    {x = 148, y = 105},
    {x = 109, y = 149},
    {x = 94, y = 105}
  },
  [731] = {
    {x = 245, y = 171},
    {x = 264, y = 164},
    {x = 233, y = 143},
    {x = 209, y = 116},
    {x = 189, y = 115},
    {x = 188, y = 77},
    {x = 160, y = 75},
    {x = 171, y = 54},
    {x = 150, y = 53},
    {x = 159, y = 82},
    {x = 106, y = 83},
    {x = 128, y = 111},
    {x = 157, y = 138},
    {x = 109, y = 135},
    {x = 133, y = 166},
    {x = 167, y = 190},
    {x = 167, y = 154},
    {x = 224, y = 184},
    {x = 239, y = 223}
  },
  [824] = {
    {x = 278, y = 318},
    {x = 255, y = 275},
    {x = 232, y = 265},
    {x = 275, y = 253},
    {x = 256, y = 198},
    {x = 282, y = 165},
    {x = 256, y = 165},
    {x = 229, y = 165},
    {x = 239, y = 191},
    {x = 173, y = 258},
    {x = 157, y = 271},
    {x = 124, y = 250}
  },
  [987] = {
    {x = 123, y = 218},
    {x = 51, y = 208},
    {x = 35, y = 118},
    {x = 121, y = 154},
    {x = 104, y = 62},
    {x = 134, y = 55},
    {x = 180, y = 179}
  }
}

local function TXMP_GetXiaoMenPai()
  local curScene = GetSceneID()
  local menpaiID = GetMenpaiIDByXiaoFubenID(curScene)
  if -1 ~= menpaiID then
    return menpaiID
  end
  local tObj = Enum2XByName("江湖宵小", {
    1,
    0,
    0,
    0
  }, nil, 1, 0)
  if #tObj > 0 then
    return GetMenpaiIDBySceneID(curScene)
  end
  local strInfo = GetLuaValue("return meGetXiaoInfo()", "s")
  local strArr = SplitString(strInfo, "&", true)
  if 2 == #strArr then
    local nowTick = GetTickCount()
    local menpaiName = strArr[1]
    local refreshTick = tonumber(strArr[2])
    if refreshTick and nowTick - refreshTick < 3600000 then
      if "慕容世家" == menpaiName then
        menpaiName = "慕容"
      end
      return GetMenpaiIDByName(menpaiName)
    end
  end
  return -1
end

local function txmp_movecb_not_in_fb(fX, fY, nScene)
  if -1 ~= GetMenpaiIDByXiaoFubenID() then
    return false
  end
  return true
end

local function txmp_movecb_findNPC(fX, fY, nScene)
  if not Player:IsLeader() then
    return false
  end
  if -1 ~= GetMenpaiIDByXiaoFubenID() then
    return false
  end
  local tObj = Enum2XByName("江湖宵小", {
    1,
    0,
    0,
    0
  }, nil, 1, 0)
  if #tObj > 0 then
    RunTo(tObj[1].x, tObj[1].y, 0, 300)
    return false
  end
  if not Player:IsFollow() then
    UseMount()
    Player:TeamFollow(true, 300)
  end
  return true
end

local function TXMP_UpdateQuestInfo()
  local nIndex, idMission, idScript = GetPlayerMission("偷袭门派")
  local nParam1, nParam2 = 0, 0
  if -1 ~= nIndex then
    nParam1 = GetMissionVariable(nIndex, 1)
    nParam2 = GetMissionVariable(nIndex, 2)
  end
  return nParam1, nParam2
end

local function XX_OnFubenAction()
  local nNowScene = GetSceneID()
  local nFubenMenPai = GetMenpaiIDByXiaoFubenID(nNowScene)
  local fubenPos = m_fubenPos[nFubenMenPai]
  if nil == fubenPos then
    PushColorMsg(m_script_name .. ":副本内取门派失败 " .. nFubenMenPai)
    return
  end
  CDG.sceneID = nNowScene
  if g_self.isjingong then
    CDG.attackMode = "打死换怪"
  else
    CDG.attackMode = "优先满血"
  end
  CDG.pickup = true
  CDG.overMapErr = true
  CDG.die.out = true
  CDG.posRadius = 15
  CDG.tragetSelect = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  CDG.pos = fubenPos
  CDG.posIdx = GetNearestPoint(CDG.pos)
  CDG:SetTimeOut(100)
  
  local function CDG_loop_callback(...)
    DebugStr("刷小：副本中.")
    if GetSceneID() ~= nNowScene then
      return true
    end
    if not Player:IsLeader() then
      local leader, isleader = Team:GetLeaderInfo()
      if leader and leader.sceneID == nNowScene then
        return true
      end
    end
    Player:TeamFollow(false, 300)
    local nTransTime = GetSceneTransTime()
    local nMsgTime1 = IsInDebugMsg("离开场景")
    if nMsgTime1 and nTransTime < nMsgTime1 then
      PushDebugMessage("刷小:本次已完成")
      PickUpLua(nil, true)
      UseMount()
      return true
    end
    return false
  end
  
  local function _move_cb_in_fb(fX, fY, nScene)
    if -1 == GetMenpaiIDByXiaoFubenID() then
      return false
    end
    Player:TeamFollow(false, 300)
    if not Player:IsLeader() then
      local leader, isleader = Team:GetLeaderInfo()
      if leader and leader.sceneID == nNowScene then
        return false
      end
    end
    if #CDG.pos > 1 then
      local nParam1, nParam2 = TXMP_UpdateQuestInfo()
      if 30 == nParam1 then
        PushDebugMessage("刷小:恶霸")
        local bossPos = fubenPos[#fubenPos]
        local pos = {}
        table.insert(pos, bossPos)
        CDG.pos = pos
        CDG.posIdx = 1
        return false
      end
    end
    return true
  end
  
  CDG.callfun = CDG_loop_callback
  CDG.callfun_move = _move_cb_in_fb
  local nTransTime = GetSceneTransTime()
  local nMsgTime1 = IsInDebugMsg("离开场景")
  if nMsgTime1 and nTransTime < nMsgTime1 then
    DebugStr("刷小:本次副本已完成!")
    LootFilter_clear()
    PickUpLua(nil, true)
    if not IsMount() then
      FubenAttack(-1)
    end
    UseMount()
    IsHuodongComplete("偷袭门派", 1)
    if os.time() - nMsgTime1 > 60 then
      if MoveFei() > 0 then
        LogMsg("刷小：1分钟超时,强制离开副本")
      else
        PushColorMsg("刷小：1分钟超时")
      end
    end
  elseif Player:IsLeader() then
    CDG:OnStart()
  else
    local leader, isleader = Team:GetLeaderInfo()
    if leader and leader.sceneID == nNowScene then
      PickUpLua()
      
      local function _callback(fX, fY, nScene)
        PickUpLua()
        local leader, isleader = Team:GetLeaderInfo()
        if leader and leader.sceneID ~= nNowScene then
          return false
        end
        if GetSceneID() ~= nNowScene then
          return false
        end
        return MoveCallBack_GoToLeader(fX, fY, nScene)
      end
      
      local nDist = 5
      if g_self.isjingong then
        nDist = 9
      end
      local tObj = Enum2XByClass("怪物", {0, -1})
      if 0 == #tObj then
        nDist = 2
      end
      GoToLeader(_callback, nil, false, false, nDist)
      tObj = Enum2XByClass("怪物", {0, -1})
      if 0 == #tObj then
        PickUpLua()
        tObj = Enum2XByClass("怪物", {0, -1})
        if 0 == #tObj and false == IsMount() then
          FubenAttack(-1)
          
          local function _IsZuoQi()
            tObj = Enum2XByClass("怪物", {0, -1})
            if #tObj > 0 then
              return false
            end
            return not IsMount()
          end
          
          GetLuaValue("Player:UseSkillInLua_Const();")
          SleepCallBack(5000, 100, _IsZuoQi)
        end
      end
      local tHP100 = ObjFilterByHP(tObj, 100, 0)
      if g_self.isjingong then
        if #tHP100 > 0 then
          JinGongFarSkill(tHP100[1].id)
        end
        if #tObj > 0 then
          BubbleByDst(tObj)
          local tmp = tObj[1]
          FubenAttack(tmp.id)
          Sleep(100)
        end
      elseif #tHP100 > 0 then
        local tmp = tHP100[1]
        FubenAttack(tmp.id)
        Sleep(100)
      elseif #tObj > 0 then
        local tmp = tObj[1]
        FubenAttack(tmp.id)
        Sleep(100)
      end
    else
      CDG:OnStart()
    end
  end
end

local function XX_OnLeaderSearch()
  local nowScene = GetSceneID()
  local tObj = Enum2XByName("江湖宵小", {
    1,
    0,
    0,
    0
  }, nil, 1, 0)
  if #tObj > 0 then
    local curMenpai = GetMenpaiIDBySceneID(nowScene)
    MoveTo(tObj[1].x, tObj[1].y, nowScene, 5, true, nil, txmp_movecb_not_in_fb)
    if GetSceneIDByMenpaiID(g_self.menpai) ~= nowScene then
      DebugStr(m_script_name .. ":需要切换队长", 3)
      local szName = " "
      local tMember, bIsLeader = Team:GetAllMemberInfo()
      for i = 1, #tMember do
        if tMember[i].menpai == curMenpai then
          szName = szName .. tMember[i].name .. " "
        end
      end
      local tObj2 = Enum2XByName(szName, {
        0,
        0,
        1,
        0
      }, {0, -1}, nil, 3)
      if " " ~= szName and #tObj2 > 0 then
        BubbleByDst(tObj2, 1)
        TeamChangeLeader(-1, tObj2[1].name)
      end
      return 1
    end
    if Player:IsLeader() then
      OpenTalk(tObj[1].id, 500)
      if Team:GetSurroundMember(8) < Team:GetMemberCount() then
        PushColorMsg("等待队员靠近")
        Player:TeamFollow(false, 300)
        Sleep(1000)
        PushColorMsg("1111")
        QuestFrameOptionClicked_Item("#{XMPTX_210712_11}", 1, 1500)
        Sleep(200)
        QuestFrameOptionClicked_Item("难道我还怕你不成……", 1, 1500)
      else
        PushColorMsg("222")
        QuestFrameOptionClicked_Item("#{XMPTX_210712_11}", 1, 1500)
        Sleep(200)
        QuestFrameOptionClicked_Item("难道我还怕你不成……", 1, 500)
      end
    end
    return 1
  end
  if -1 ~= m_xiaoMenpaiID then
    local nScene = GetSceneIDByMenpaiID(m_xiaoMenpaiID)
    local mappos = m_scenePos[nScene]
    if mappos then
      if 0 == m_posIndex and GetSceneID() == nScene then
        m_posIndex = GetNearestPoint(mappos)
      end
      if m_posIndex <= 0 or m_posIndex > #mappos then
        m_posIndex = 1
      end
      local tObj = Enum2XByName("江湖宵小", {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if 0 == #tObj then
        local run = mappos[m_posIndex]
        MoveTo(run.x, run.y, nScene, 3, true, nil, txmp_movecb_findNPC)
        tObj = Enum2XByName("江湖宵小", {
          1,
          0,
          0,
          0
        }, nil, 1, 0)
        if 0 == #tObj then
          m_posIndex = m_posIndex + 1
        end
      end
    else
      DebugStr(m_script_name .. ":地图数据获取失败 " .. nScene)
    end
    return 2
  else
    DebugStr(m_script_name .. ":未获取到宵小门派数据,等待刷新！", 2)
    local nScene = GetSceneIDByMenpaiID(g_self.menpai)
    local posArr = m_scenePos[nScene]
    if posArr then
      local run = posArr[1]
      MoveTo(run.x, run.y, nScene, nil, nil, nil, txmp_movecb_not_in_fb)
      if not IsMount() then
        Player:TeamFollow(false, 300)
        UseMount()
      end
    end
    return 3
  end
  return -1
end

function _SMain(...)
  local tab = {}
  for i = 1, #g_MenPaiInfo do
    table.insert(tab, g_MenPaiInfo[i].xiaoSceneID)
  end
  LeaveSpecialScene(tab, nil)
  tab = nil
  local lastFujinTeamCount = 0
  local tickOutHasMenpai = -1
  local lastFindTime = GetTickCount()
  local org_leader = Team:GetLeaderInfo()
  local xLast, yLast, nLastTime = -1, -1, -1
  while true do
    if -1 == GetMenpaiIDByXiaoFubenID() then
      local xiaoMenpai = TXMP_GetXiaoMenPai()
      if -1 ~= xiaoMenpai then
        m_xiaoMenpaiID = xiaoMenpai
        if Team:IsHaveMenpaiID(xiaoMenpai) == false then
          if -1 == tickOutHasMenpai then
            tickOutHasMenpai = GetTickCount()
          end
          if GetTickCount() - tickOutHasMenpai > 20000 and -1 == GetMenpaiIDByXiaoFubenID() then
            Sleep(3000)
            if Team:IsHaveMenpaiID(xiaoMenpai) == false and -1 == GetMenpaiIDByXiaoFubenID() then
              Sleep(3000)
              if Team:IsHaveMenpaiID(xiaoMenpai) == false and -1 == GetMenpaiIDByXiaoFubenID() then
                PushColorMsg(m_script_name .. ":队伍中没有[%s]派的成员,结束!", GetMenpaiNameByID(xiaoMenpai))
                break
              end
            end
          end
        else
          tickOutHasMenpai = -1
        end
      end
    end
    if -1 ~= GetMenpaiIDByXiaoFubenID() then
      while -1 ~= GetMenpaiIDByXiaoFubenID() do
        XX_OnFubenAction()
        Sleep(100)
        DebugStr("宵小副本中...")
      end
      if g_config.shuaxiao.once then
        PushColorMsg(m_script_name .. ":您设置只刷一轮")
        break
      end
      tickOutHasMenpai = -1
      lastFindTime = GetTickCount()
    else
      if IsHuodongComplete("偷袭门派", 1) then
        Sleep(2000)
        if -1 == GetMenpaiIDByXiaoFubenID() then
          PushColorMsg(m_script_name .. ":已刷满")
          break
        end
      end
      if m_param.maxtime > 0 and GetTickCount() - lastFindTime > m_param.maxtime * 60 * 1000 then
        Sleep(2000)
        if -1 == GetMenpaiIDByXiaoFubenID() then
          PushColorMsg(m_script_name .. ":已经" .. m_param.maxtime .. "分钟没有进入副本")
          break
        end
      end
      if Player:IsLeader() then
        local flag = XX_OnLeaderSearch()
        if 3 == flag and IsMount() then
          local fujinCount = Team:GetSurroundMember(5)
          if fujinCount ~= lastFujinTeamCount then
            PushDebugMessage("刷小:队长组队跟随")
            Sleep(3000)
            GetLuaValue("Player:TeamFrame_AskTeamFollow();")
            Sleep(300)
            lastFujinTeamCount = fujinCount
          end
        end
      elseif not Player:IsFollow() then
        UseMount()
        
        local function dy_cb(fX, fY, nScene)
          return MoveCallBack_GoToLeader(fX, fY, nScene)
        end
        
        GoToLeader(dy_cb)
      else
        if IsKVKSceneName() then
          Player:TeamFollow(false, 300)
        else
          local selfPos = Player:GetPos()
          if selfPos.x ~= xLast or selfPos.y ~= yLast then
            xLast, yLast = selfPos.x, selfPos.y
            nLastTime = -1
          else
            local leader = Team:GetLeaderInfo()
            if leader then
              local t1 = FindObjByGUID(leader.guid)
              if not t1 then
                if GetSceneID() == leader.sceneID then
                  if GetDist(leader.x, leader.y, selfPos.x, selfPos.y) > 15 then
                    if -1 ~= nLastTime then
                      if GetTickCount() - nLastTime > 5000 and not IsSceneTransed() then
                        PushColorMsg("队员卡图,自动退出跟随")
                        Player:TeamFollow(false, 300)
                      end
                    else
                      nLastTime = GetTickCount()
                    end
                  else
                    nLastTime = -1
                  end
                else
                  nLastTime = -1
                end
              else
                nLastTime = -1
              end
            else
              nLastTime = -1
            end
          end
        end
        Sleep(500)
      end
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  Player:TeamFollow(false, 300)
  if org_leader and Player:IsLeader() and org_leader.name ~= g_self.name then
    TeamChangeLeader(-1, org_leader.name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_fubenPos = nil
m_scenePos = nil
