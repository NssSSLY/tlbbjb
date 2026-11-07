-- 反编译自 dfz64.dll 内嵌字节码 005450ab（unluac 2025-12-23；仅供分析）
function GetTRLeaderInfo()
  local info
  
  local bIsLeader = false
  if Player:IsInRaid() then
    info, bIsLeader = Raid:GetLeaderInfo()
  elseif Player:IsInTeam() then
    info, bIsLeader = Team:GetLeaderInfo()
  end
  return info, bIsLeader
end

function MoveCallBack_GoToTRLeader(fX, fY, nScene, aFollowCallBack)
  local leader, isleader = GetTRLeaderInfo()
  if isleader then
    return false, nil
  end
  if not leader then
    if Player:IsInRaid(true) == false and false == Player:IsInTeam(true) then
      return false, nil
    end
    DebugStr("跟随队团长：正在移动到 x:%s y:%s scene:%s", 1, fX, fY, nScene)
    Sleep(500)
    return true, nil
  end
  if -1 ~= FollowFilterScene(leader.sceneID) then
    DebugStr("跟随队团长：目标不在正确的地图,暂不跟随!")
    return false, nil
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    RunTo(leaderObj.x, leaderObj.y, 1, 350)
    if leaderObj.dst <= 3 then
      return false, nil
    else
      leaderObj.sceneID = leader.sceneID
      return true, leaderObj
    end
  end
  if aFollowCallBack and false == aFollowCallBack(leader) then
    return false, nil
  end
  if leader.sceneID == 10001 then
    PushDebugMessage("跟随队团长：目标可能在帮会")
  end
  DebugStr("跟随队团长：移动到 x:%s y:%s scene:%s", 1, math.floor(leader.x), math.floor(leader.y), leader.sceneID)
  if leader.sceneID == 65535 then
    return true, nil
  else
    if leader.sceneID == GetSceneID() then
      ChangeSceneLineID(leader.mapID)
    end
    if leader.x > 0 and (leader.x ~= fX or leader.y ~= fY or leader.sceneID ~= nScene) then
      AutoRunToTarget(leader.x, leader.y, leader.sceneID, true)
      Sleep(300)
    else
      return true, nil
    end
  end
  return true, leader
end

function GoToTRLeader(aMoveCallBack, aCallBack, bUseShouFeiNpc, bUseDingWeiFu, aKeepDist, aFollowCallBack)
  aKeepDist = aKeepDist or 3
  aMoveCallBack = aMoveCallBack or MoveCallBack_GoToTRLeader
  aCallBack = aCallBack or MoveCallBack_state_1
  local leader, isleader = GetTRLeaderInfo()
  if not leader or isleader then
    return -1
  end
  if leader.sceneID == 65535 then
    return -1
  end
  if leader.sceneID == 10001 then
    PushDebugMessage("跟随队团长：目标可能在帮会")
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    leader.x = leaderObj.x
    leader.y = leaderObj.y
  end
  if nil == aFollowCallBack or aFollowCallBack(leader) then
    if leader.sceneID == GetSceneID() then
      ChangeSceneLineID(leader.mapID)
    end
    MoveTo(leader.x, leader.y, leader.sceneID, aKeepDist, nil, aCallBack, aMoveCallBack, bUseShouFeiNpc, bUseDingWeiFu, nil, aFollowCallBack)
  end
  return 0
end

function PK_CheckUseQingGong(aX, aY)
  DeleteDebugMsg("#{ResultText_167}")
  if IsInDebugMsg("#{ResultText_167}") then
    PushDebugMessage("使用轻功飞到 %s ,%s", math.floor(aX), math.floor(aY))
    Skill:UseQingGong(aX, aY)
    Sleep(1000)
    DeleteDebugMsg("#{ResultText_167}")
  end
end

function Sort_dist(tObj)
  local tNear = {}
  for i = 1, #tObj do
    if tObj[i].dst <= 5 then
      table.insert(tNear, tObj[i])
    end
  end
  return tNear
end

function Sort_fangda(tObj)
  local tFangDa = {}
  for i = 1, #tObj do
    if tObj[i].fangda then
      table.insert(tFangDa, tObj[i])
    end
  end
  return tFangDa
end

function Sort_hp_little(tObj)
  local tDiXue = {}
  for i = 1, #tObj do
    if tObj[i].hp < 30 then
      table.insert(tDiXue, tObj[i])
    end
  end
  return tDiXue
end

function Sort_name(tObj, aNameList)
  local tName = {}
  for i = 1, #tObj do
    if string.find(aNameList, " " .. tObj[i].name .. " ", nil, true) then
      table.insert(tName, tObj[i])
    end
  end
  return tName
end

function Sort_menpai(tObj, aMenpaiList)
  local tMenPai = {}
  for i = 1, #tObj do
    if tObj[i].strmenpai and tObj[i].strmenpai ~= "" and string.find(aMenpaiList, " " .. tObj[i].strmenpai .. " ", nil, true) then
      table.insert(tMenPai, tObj[i])
    end
  end
  return tMenPai
end

function CheckLeaderScene(aAllSceneID, aCheckCount)
end
