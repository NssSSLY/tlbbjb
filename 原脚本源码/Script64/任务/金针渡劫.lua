-- 反编译自 dfz64.dll 内嵌字节码 002897e2（unluac 2025-12-23；仅供分析）
local m_script_name = "金针渡劫"
ScriptOnStart(m_script_name, true, false)

local function ZhuXianAttack(aParam)
  aParam.attackMode = "打死换怪"
  mission_attack_mode_1(aParam)
end

local function ZhuXianComplete(aParam)
  mission_complete_talk_npc(aParam)
end

local MissionTable = {
  function()
    local apt = {
      x = 43,
      y = 108,
      sceneID = 15,
      name = "韩映雪"
    }
    local comp = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local misName = "金针渡劫-重攻轻守"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = apt
    local misName = "金针渡劫-子午针灸经"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 265, y = 252}
        },
        sceneName = "西湖",
        targetName = "龙井水贼",
        is_pick = true,
        pick_item = "子午针灸经残页",
        call_back_attack = function()
          DebugStr("金针渡劫-子午针灸经:正在执行中", 2)
          local nComplete, nIndex = GetMissionVariableByName_Item("金针渡劫-子午针灸经", 0)
          if 1 == nComplete or -1 == nIndex then
            return true
          end
          return false
        end
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = {
      x = 216,
      y = 204,
      sceneID = 1,
      name = "庞安时"
    }
    local misName = "金针渡劫-三人同行"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = {
      x = 216,
      y = 204,
      sceneID = 1,
      name = "庞安时"
    }
    local misName = "金针渡劫-回马枪"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if 124 == GetSceneID() then
          local fubenSceneID = 124
          CDG.jgyc = false
          CDG.targetName = ""
          CDG.sceneID = fubenSceneID
          CDG.sceneName = "集市"
          CDG.attackMode = "优先近怪"
          CDG.pickup = false
          CDG.overMapErr = true
          CDG.die.out = true
          CDG.posRadius = 15
          CDG.tragetSelect = true
          CDG.die.maxCount = 0
          CDG.savebank = false
          CDG.pos = {
            {x = 32, y = 38},
            {x = 19, y = 38},
            {x = 22, y = 23},
            {x = 34, y = 23}
          }
          CDG.posIdx = GetNearestPoint(CDG.pos)
          CDG:SetTimeOut(100)
          
          local function CDG_loop_callback(...)
            DebugStr(m_script_name .. "：副本中.")
            if GetSceneID() ~= fubenSceneID then
              return true
            end
            Player:TeamFollow(false, 300)
            local nComplete = GetMissionVariableByName_Item("金针渡劫-回马枪", 0)
            if 0 ~= nComplete then
              PushColorMsg(m_script_name .. ":任务完成")
              return true
            end
            return false
          end
          
          local function sf_move_cb_in_fb(fX, fY, nScene)
            if GetSceneID() ~= fubenSceneID then
              return false
            end
            return true
          end
          
          CDG.callfun = CDG_loop_callback
          CDG.callfun_move = sf_move_cb_in_fb
          CDG.clearBag = false
          CDG:OnStart()
        else
          GoToSceneNPC("庞安时", 216, 204, 1)
          DialogOptionClicked("送我去集市", 1, 1000)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 216,
      y = 204,
      sceneID = 1,
      name = "庞安时"
    }
    local comp = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local misName = "金针渡劫-一代奇才"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local comp = {
      x = 229,
      y = 248,
      sceneID = 2,
      name = "王韶"
    }
    local misName = "金针渡劫-运用自如"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function(...)
        if Player:GetMoney(1) < 50000 then
          Bank_GetMoney(50000)
        else
          ZhuXianComplete(...)
        end
      end
    }
    return mission
  end
}

local function ZhuXianCommitMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if 1 == nComplete then
      DebugStr("交任务 " .. mis.name, 2)
      mis.is_complete = true
      mis.OnComplete(mis)
      bDoAction = true
      break
    end
  end
  return bDoAction
end

local function ZhuXianDoMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if -1 ~= nIndex then
      if 0 == nComplete then
        if mis.commit then
          PushColorMsg("切换地图,提交已完成任务！")
          if ZhuXianCommitMission() then
            return true
          end
        end
        DebugStr("执行任务 " .. mis.name, 2)
        if mis.OnAction then
          mis.OnAction(mis)
        elseif mis.OnComplete then
          mis.OnComplete(mis)
        end
        bDoAction = true
        break
      elseif 2 == nComplete then
        PushColorMsg("放弃任务：" .. misName)
        QuestFrameMissionAbnegate(idScript)
      end
    end
  end
  return bDoAction
end

local function ZhuXianCanAccept(aMisName)
  return true
end

local function ZhuXianAcceptCheckScene(aMisTable, aAcceptSceneID, aAcceptIndex)
  local mis_table = aMisTable
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    if -1 ~= nIndex and GetSceneID() ~= aAcceptSceneID and mis.param_accept.sceneID ~= aAcceptSceneID then
      return false
    end
  end
  return true
end

local function ZhuXianAcceptMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  CollectMissionOutline()
  Sleep(500)
  local lastScene = -1
  local nLevel = Player:GetDataInt("LEVEL")
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    if (mis.is_complete == nil or mis.is_complete == false) and IsMissionOutline(mis.name) and ZhuXianCanAccept(mis.name) and (-1 == lastScene or lastScene == mis.param_accept.sceneID) and mis.param_accept and mis.param_accept.sceneID and ZhuXianAcceptCheckScene(mis_table, mis.param_accept.sceneID, i) then
      lastScene = mis.param_accept.sceneID
      DebugStr("接任务 " .. mis.name, 2)
      bDoAction = true
      mis.OnAccept(mis)
    end
  end
  return bDoAction
end

function _SMain()
  if 4 ~= g_self.menpai then
    PushColorMsg("非峨嵋门派")
    return
  end
  LoadScript("mission")
  local nOverCount = 0
  while true do
    local debugnote = " "
    if false == ZhuXianDoMission() then
      if false == ZhuXianCommitMission() then
        if false == ZhuXianAcceptMission() then
          if nOverCount <= 2 then
            local apt = {
              x = 43,
              y = 108,
              sceneID = 15,
              name = "韩映雪"
            }
            GoToSceneNPC(apt.name, apt.x, apt.y, apt.sceneID)
            DialogOptionClicked("金针渡劫-重攻轻守", 1, 700)
            QuestFrameAcceptClicked(500)
            nOverCount = nOverCount + 1
          else
            PushColorMsg(m_script_name .. "：无任务可接")
            break
          end
        end
      elseif false == ZhuXianCommitMission() then
        ZhuXianAcceptMission()
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. debugnote, 1)
  end
end

_SMain()
ScriptOnStop(m_script_name)
MissionTable = nil
