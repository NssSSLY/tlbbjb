-- 反编译自 dfz64.dll 内嵌字节码 002fbdb4（unluac 2025-12-23；仅供分析）
local m_script_name = "平定水牢"
ScriptOnStart(m_script_name, true, true)
local m_fubenSceneID = 66
local m_missionName = "帮助平定水牢叛乱"
local m_isover = false
CDG.sceneName = ""
CDG.sceneID = -1
CDG.die.out = true
CDG.posRadius = 8
CDG.pos = {
  {x = 41, y = 83},
  {x = 40, y = 48},
  {x = 70, y = 41},
  {x = 108, y = 41},
  {x = 142, y = 41},
  {x = 153, y = 70},
  {x = 152, y = 109},
  {x = 152, y = 143},
  {x = 118, y = 151},
  {x = 83, y = 149},
  {x = 48, y = 149},
  {x = 41, y = 120}
}

function CDG_callback_isOver()
  if GetCurrentSceneName() ~= "水牢" then
    return true
  end
  local nComplete = GetMissionVariableByName_Item("水牢", 0)
  if 1 == nComplete then
    return true
  end
  return false
end

function CDG_callback_onMove(fX, fY, nScene)
  PickUpLua()
  if GetCurrentSceneName() ~= "水牢" then
    return false
  end
  return true
end

CDG.callfun = CDG_callback_isOver
CDG.callfun_move = CDG_callback_onMove

local function SL_OnMission()
  local nComplete = GetMissionVariableByName_Item("水牢", 0)
  if 1 == nComplete then
    GoToSceneNPC("呼延庆", 67, 77, 4)
    if QuestFrameOptionClicked_Item("水牢", 1, 600) then
      QuestFrameNextClicked(600)
      QuestFrameMissionComplete(0, 600)
    end
    return false
  end
  return true
end

local function SL_Mission_PingDingShuiLao()
  local nComplete = GetMissionVariableByName_Item(m_missionName, 0)
  if 1 == nComplete then
    GoToSceneNPC("呼延豹", 342, 311, 1)
    if QuestFrameOptionClicked_Item(m_missionName, 1, 800) then
      QuestFrameNextClicked(800)
      QuestFrameMissionComplete(0, 400)
    end
    return false
  end
  return true
end

function _SMain(...)
  DeleteDebugMsg("一个人势单力薄")
  DeleteDebugMsg("3位同伴")
  DeleteDebugMsg("你有队员不在旁边")
  DeleteDebugMsg("任务记录已满")
  if GetCurrentSceneName() ~= "水牢" then
    local itemCount = Bag:GetItemCount("水牢令牌", 0, 0)
    if itemCount < 1 then
      if TempBank2Bag("水牢令牌", 0) == false then
        PushDebugMessage("锦囊也没有水牢令牌,前往仓库取出")
        Bank_GetItem("水牢令牌", 1, nil, nil, true)
      end
      Sleep(500)
    end
    itemCount = Bag:GetItemCount("水牢令牌", 0, 0)
    if 0 == itemCount then
      PushColorMsg("水牢:无令牌,结束")
      return
    end
  else
    local ndis = 9999
    local n = 1
    for i = 1, #CDG.pos do
      local nowdis = GetDist(CDG.pos[i].x, CDG.pos[i].y)
      if ndis > nowdis then
        ndis = nowdis
        n = i
      end
    end
    if ndis < 10 then
      CDG.posIdx = n
    end
  end
  while true do
    local debugnote = ""
    if GetCurrentSceneName() == "水牢" then
      m_isover = true
      if 1 ~= GetMissionVariableByName_Item("水牢", 0) then
        debugnote = " 正在杀怪."
        CDG:OnStart()
      else
        debugnote = " 水牢完成,离开副本."
        MoveTo(95, 95, -1, nil, nil, nil, CDG_callback_onMove)
      end
    elseif SL_OnMission() and SL_Mission_PingDingShuiLao() then
      if m_isover then
        break
      end
      local nIndex, idMission, idScript = GetPlayerMission_Item(m_missionName)
      if 2 == GetMissionComplete(nIndex) then
        PushDebugMessage("水牢：任务已失败，自动放弃！")
        QuestFrameMissionAbnegate(idScript)
      end
      if Player:IsLeader() then
        if -1 == nIndex then
          DebugStr("水牢：接任务", 2)
          GoToSceneNPC("呼延豹", 342, 311, 1)
          ChangeSceneLine()
          if Team:GetSurroundMember(5) == Team:GetMemberCount() then
            Sleep(5000)
            if Team:GetSurroundMember(5) == Team:GetMemberCount() then
              QuestFrameOptionClicked_Item(m_missionName, 1, 800)
              if Team:GetSurroundMember(5) == Team:GetMemberCount() then
                QuestFrameAcceptClicked(800)
              end
            end
          else
            debugnote = " 等待队员集合后接取任务"
          end
        else
          GoToSceneNPC("呼延庆", 67, 77, 4)
          FubenAttack(-1)
          if QuestFrameOptionClicked_Item("水牢", 1, 800) then
            QuestFrameAcceptClicked(800)
          end
          if IsInDebugMsg("一个人势单力薄") then
            PushDebugMessage("水牢：你还没有队伍")
            break
          end
          if IsInDebugMsg("3位同伴") then
            PushDebugMessage("水牢：队伍不足3人！结束")
            break
          end
          if IsInDebugMsg("你有队员不在旁边") then
            Sleep(3000)
          end
          if IsInDebugMsg("任务记录已满") then
            PushDebugMessage("队伍中有人的任务记录已满。")
            Sleep(2000)
          end
          local szText = GetNPCEventList_Item(0)
          if string.find(szText, "非法手段", nil, true) then
            break
          end
          if string.find(szText, "不满足", nil, true) then
            PushDebugMessage("水牢：有不满足条件的队员,无法进入")
            break
          end
        end
      else
        local function member_fl_cb(fX, fY, nScene)
          QuestFrameAcceptClicked(200)
          
          if GetCurrentSceneName() == "水牢" then
            return false, nil
          end
          local leader, isleader = Team:GetLeaderInfo()
          if leader and leader.sceneID == m_fubenSceneID then
            return false, nil
          end
          return MoveCallBack_GoToLeader(fX, fY, nScene)
        end
        
        local leader, isleader = Team:GetLeaderInfo()
        if leader and not isleader and 1 == leader.sceneID then
          debugnote = " 跟随队长"
          GoToLeader(member_fl_cb)
        elseif -1 == nIndex then
          GoToSceneNPC("呼延豹", 342, 311, 1)
          ChangeSceneLine()
        else
          GoToSceneNPC("呼延庆", 67, 77, 4)
        end
        QuestFrameAcceptClicked()
      end
    end
    Sleep(200)
    DebugStr("水牢：进行中" .. debugnote)
  end
  if m_isover then
    GoToSceneNPC("呼延豹", 342, 311, 1)
  end
end

_SMain()
ScriptOnStop(m_script_name)
