-- 反编译自 dfz64.dll 内嵌字节码 00284f56（unluac 2025-12-23；仅供分析）
local m_script_name = "百花缘"
ScriptOnStart(m_script_name, true, false)
CDG.attack = true
CDG.sceneID = -1
CDG.attackMode = "打死换怪"
CDG.overMapErr = true
CDG.die.out = true
CDG.posRadius = 15
CDG.tragetSelect = true
CDG.die.maxCount = 0
CDG.savebank = false
local m_param = {}
m_param.allRound = 20
m_param.missionName = "百花缘"
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
local g_BaiHuaYuan_Pos = {
  [182] = {
    {x = 69, y = 42},
    {x = 42, y = 66},
    {x = 56, y = 147},
    {x = 65, y = 118},
    {x = 62, y = 87},
    {x = 129, y = 57},
    {x = 133, y = 143}
  },
  [184] = {
    {x = 97, y = 33},
    {x = 42, y = 36},
    {x = 38, y = 150},
    {x = 158, y = 140},
    {x = 145, y = 35},
    {x = 97, y = 92}
  },
  [185] = {
    {x = 70, y = 82},
    {x = 100, y = 128},
    {x = 78, y = 46},
    {x = 94, y = 59},
    {x = 79, y = 127},
    {x = 75, y = 135}
  },
  [186] = {
    {x = 94, y = 117},
    {x = 71, y = 103},
    {x = 52, y = 100},
    {x = 95, y = 86},
    {x = 75, y = 56},
    {x = 44, y = 70},
    {x = 50, y = 42},
    {x = 95, y = 35},
    {x = 147, y = 35}
  },
  [187] = {
    {x = 52, y = 148},
    {x = 89, y = 124},
    {x = 50, y = 60},
    {x = 142, y = 42},
    {x = 148, y = 150}
  },
  [189] = {
    {x = 67, y = 143},
    {x = 53, y = 48},
    {x = 95, y = 50},
    {x = 126, y = 73},
    {x = 140, y = 93},
    {x = 142, y = 142},
    {x = 95, y = 127}
  },
  [190] = {
    {x = 95, y = 141},
    {x = 60, y = 35},
    {x = 74, y = 67},
    {x = 39, y = 37},
    {x = 41, y = 145},
    {x = 95, y = 99},
    {x = 146, y = 140},
    {x = 151, y = 67}
  }
}
local g_BaiHuaYuan_Transfer = {
  [182] = {x = 96, y = 157},
  [184] = {x = 98, y = 163},
  [185] = {x = 95, y = 192},
  [186] = {x = 95, y = 140},
  [187] = {x = 39, y = 130},
  [189] = {x = 95, y = 143},
  [190] = {x = 95, y = 150}
}
local g_BaiHuaYuan_Opt = {
  [9] = "打木人锻炼",
  [11] = "去抵挡围剿",
  [12] = "去挑战心魔",
  [13] = "去大战傀儡",
  [14] = "去见识天机傀儡",
  [16] = "打蜘蛛修炼",
  [17] = "去歼灭雪怪"
}

local function GetPlayerMissionRound(aMissionIndex)
  return GetLuaValue(fmt("                local nRound = DataPool:GetPlayerMission_Display(%d, 3)\n                if nRound >= 0 then\n                \tlocal Mission_Variable = DataPool:GetPlayerMission_DataRound(nRound);--当前任务环数\n                \tif Mission_Variable >= 0 then\n                \t    return Mission_Variable\n                \tend\n                end\n                return -1\n        ", aMissionIndex), "n")
end

local function IsMenpaiFubenScene(aSceneID)
  local curScene = aSceneID or GetSceneID()
  local mp = {
    182,
    184,
    185,
    186,
    187,
    189,
    190
  }
  return FindTableValue(mp, curScene)
end

local function bhy_cb_leave_mp_fb(fX, fY, nScene)
  local curScene = GetSceneID()
  if not IsMenpaiFubenScene(curScene) then
    return false
  end
  local run = g_BaiHuaYuan_Transfer[curScene]
  if not run then
    PushColorMsg("百花缘:当前地图获取坐标失败" .. curScene)
    return false
  end
  run.sceneID = curScene
  return true, run
end

local function bhy_cb_not_mp_fb(fX, fY, nScene)
  local curScene = GetSceneID()
  if not IsMenpaiFubenScene(curScene) then
    return true
  end
  DebugStr("百花缘:离开门派副本")
  local run = g_BaiHuaYuan_Transfer[curScene]
  if run then
    RunTo(run.x, run.y, 0, 1000)
  end
  return false
end

local function bhy_cb_in_mp_fb(fX, fY, nScene)
  return IsMenpaiFubenScene()
end

local function LeaveMenPaiFuBen()
  local curScene = GetSceneID()
  local run = g_BaiHuaYuan_Transfer[curScene]
  if run then
    PushColorMsg("百花缘:离开门派副本")
    MoveTo(run.x, run.y, curScene, 1, nil, nil, bhy_cb_leave_mp_fb)
  end
end

local function bhy_is_finish()
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
  m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
  return 1 == m_param.param[0]
end

local function OnMission_808200_0()
  PushColorMsg("百花缘:暂不支持此类型子任务,放弃！")
  QuestFrameMissionAbnegate(m_param.misScriptID)
end

local function OnMission_808200_1()
  local npc = GetMissionDesc_NPC(m_param.missionName)
  if nil == npc then
    PushColorMsg("百花缘：任务1无法取得任务信息")
    return
  end
  if npc.name == "" or -1 == npc.sceneID then
    PushColorMsg("百花缘：任务1无法获取NPC数据")
    return
  end
  local nCurScene = GetSceneID()
  local fubenID = GetFubenSceneIDByMenpaiSceneID(npc.sceneID)
  if nCurScene == fubenID then
    local function _CB()
      if GetSceneID() ~= fubenID then
        PushColorMsg("百花缘:任务1,副本内采集地图不正确")
        
        return true
      end
      if bhy_is_finish() then
        return true
      end
      return false
    end
    
    local caijiPos = g_BaiHuaYuan_Pos[fubenID]
    if caijiPos then
      if 189 == fubenID then
        MoveTo(95, 133, 189, 1, nil, nil, bhy_cb_in_mp_fb)
      end
      BeginCaiji("稀有的花盆", fubenID, caijiPos, _CB)
    end
  else
    LeaveMenPaiFuBen()
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, bhy_cb_not_mp_fb)
    Sleep(1000)
    if nil == g_BaiHuaYuan_Opt[npc.sceneID] then
      PushColorMsg("百花缘:任务1没有找到对话选项" .. npc.sceneID .. ".")
    else
      QuestFrameOptionClicked_Item(g_BaiHuaYuan_Opt[npc.sceneID], 1, 1000)
      MoveConfirm()
    end
  end
end

local function OnMission_808200_2()
  LeaveMenPaiFuBen()
  local caijiPos = {
    {x = 53, y = 232},
    {x = 117, y = 239},
    {x = 92, y = 205},
    {x = 162, y = 201},
    {x = 172, y = 176},
    {x = 170, y = 153},
    {x = 247, y = 146},
    {x = 245, y = 106},
    {x = 186, y = 47},
    {x = 215, y = 48},
    {x = 248, y = 65},
    {x = 277, y = 75},
    {x = 223, y = 197},
    {x = 235, y = 241}
  }
  
  local function _CB()
    if IsMenpaiFubenScene() then
      return true
    end
    if bhy_is_finish() then
      return true
    end
    return false
  end
  
  BeginCaiji("百合花", 4, caijiPos, _CB)
end

local function OnMission_808200_3()
  LeaveMenPaiFuBen()
  local npc = GetMissionDesc_NPC(m_param.missionName)
  if nil == npc then
    PushDebugMessage("百花缘：任务3无法取得任务信息")
  end
  if npc.name == "" or -1 == npc.sceneID then
    PushColorMsg("百花缘：任务3无法获取NPC数据")
    return
  end
  if npc.name == "苏轼" then
    MoveTo(157, 356, 1, 1, nil, nil, bhy_cb_not_mp_fb)
    Sleep(1000)
  end
  MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, bhy_cb_not_mp_fb)
  Sleep(600)
  QuestFrameOptionClicked_Item(m_param.missionName, 1, 600)
end

local function OnMission_808200_4()
  LeaveMenPaiFuBen()
  if Player:GetMoney() < 1497 and Player:GetMoney(2) < 1497 then
    PushColorMsg("百花缘：金币不足无法购买扒鸡！")
    Bank_GetMoney(1497)
    Sleep(1000)
    return
  end
  MoveToNPC("卢三七", 105, 123, 2, nil, nil, nil, bhy_cb_not_mp_fb)
  QuestFrameOptionClicked_Item("购买药品", 1, 700)
  Shop_BuyItem("扒鸡", 1)
  Sleep(600)
end

local function OnMission_808200_5()
  local npc = GetMissionDesc_NPC(m_param.missionName)
  if nil == npc then
    PushColorMsg("百花缘：任务5无法取得任务信息")
    return
  end
  if npc.name == "" or -1 == npc.sceneID then
    PushColorMsg("百花缘：任务5无法获取NPC数据")
    return
  end
  local nCurScene = GetSceneID()
  local fubenID = GetFubenSceneIDByMenpaiSceneID(npc.sceneID)
  if nCurScene == fubenID then
    local CaiJi = g_BaiHuaYuan_Pos[nCurScene]
    if CaiJi then
      PickUpLua()
      
      local function CDG_loop_callback(...)
        if bhy_is_finish() then
          return true
        end
        if g_self.isjingong and 7 ~= Player:GetState() then
          local tObj = CDG:EnumTarget()
          if #tObj > 0 then
            PushDebugMessage("百花缘:近攻远程技能辅助攻击")
            JinGongFarSkill(tObj[1].id, true)
            Sleep(500)
          end
        end
        DebugStr("百花缘：任务5 遗失的小铲子")
        return false
      end
      
      CDG.sceneID = nCurScene
      CDG.pos = CaiJi
      CDG.posIdx = 1
      CDG.callfun = CDG_loop_callback
      CDG.callfun_move = bhy_cb_in_mp_fb
      CDG:OnStart()
    else
      PushColorMsg("百花缘:任务5 没有此地图坐标")
    end
  else
    LeaveMenPaiFuBen()
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, bhy_cb_not_mp_fb)
    Sleep(1000)
    if nil == g_BaiHuaYuan_Opt[npc.sceneID] then
      PushColorMsg("百花缘:任务5没有找到对话选项" .. npc.sceneID .. ".")
    else
      QuestFrameOptionClicked_Item(g_BaiHuaYuan_Opt[npc.sceneID], 1, 1000)
      MoveConfirm()
    end
  end
end

function _SMain(...)
  m_param.allRound = ReadConfigInt("ZH", "bjk121")
  if m_param.allRound <= 0 then
    m_param.allRound = 20
  end
  if m_param.allRound > 20 then
    PushColorMsg("百花缘:每天超过20环没有奖励,您的设置已超过20环！")
  end
  local m_npc = {
    {
      name = "阿里",
      x = 185,
      y = 65,
      sceneID = 2
    },
    {
      name = "姜鲤",
      x = 224,
      y = 296,
      sceneID = LUOYANG_ID
    }
  }
  Bag_DeleteItem()
  LoadScript("caiji")
  while true do
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
    if -1 ~= m_param.misIndex then
      for i = 0, 7 do
        m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
      end
      if 1 == m_param.param[0] then
        PushDebugMessage(m_param.missionName .. ":任务已完成")
        local npc = m_npc[1]
        LeaveMenPaiFuBen()
        local nFunc = m_param.param[4]
        if 4 == nFunc and 0 == Bag:GetItemCount("扒鸡", nil, nil, Bag:EnumDaoJuItem()) then
          OnMission_808200_4()
        end
        MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, bhy_cb_not_mp_fb)
        PickUpLua(nil, true)
        QuestFrameOptionClicked_Item("#{SDHDRW_xml_XX(03)}", 1, 700)
        QuestFrameOptionClicked_Item(m_param.missionName, 1, 600)
        QuestFrameMissionComplete(nil, 300)
        ClearBag()
      else
        local nRound = GetPlayerMissionRound(m_param.misIndex)
        if nRound > m_param.allRound then
          PushColorMsg(fmt("百花缘：今日已完成%d次任务！", nRound))
          QuestFrameMissionAbnegate(m_param.misScriptID)
          break
        end
        local nFunc = m_param.param[4]
        if 0 == nFunc then
          OnMission_808200_0()
        elseif 1 == nFunc then
          OnMission_808200_1()
        elseif 2 == nFunc then
          OnMission_808200_2()
        elseif 3 == nFunc then
          OnMission_808200_3()
        elseif 4 == nFunc then
          OnMission_808200_4()
        elseif 5 == nFunc then
          OnMission_808200_5()
        end
      end
    else
      local npc = m_npc[1]
      LeaveMenPaiFuBen()
      DeleteDebugMsg("#{SDHDRW_091109_02}")
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, bhy_cb_not_mp_fb)
      QuestFrameOptionClicked_Item("#{SDHDRW_xml_XX(03)}", 1, 700)
      QuestFrameOptionClicked_Item(m_param.missionName, 1, 600)
      if IsInDebugMsg("#{SDHDRW_091109_02}") then
        Sleep(10000)
      end
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
m_param = nil
g_BaiHuaYuan_Pos = nil
g_BaiHuaYuan_Transfer = nil
g_BaiHuaYuan_Opt = nil
