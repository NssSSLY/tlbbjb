-- 反编译自 dfz64.dll 内嵌字节码 0054210f（unluac 2025-12-23；仅供分析）
function CollectMissionOutline()
  GetLuaValue("CollectMissionOutline()")
end

function IsMissionOutline(aMissionName, aMinLevel, aMaxLevel)
  aMinLevel = aMinLevel or 0
  aMaxLevel = aMaxLevel or 119
  if "归风之迷" == aMissionName then
    aMissionName = "归云之迷"
  end
  if "勇闯三才阵" == aMissionName then
    aMissionName = "勇探三才阵"
  end
  local strText = fmt("return meIsMissionOutline(\"%s\",%d,%d) ", aMissionName, aMinLevel, aMaxLevel)
  return GetLuaValue(strText, "b")
end

function mission_complete_accept(strClicked, bNext, bComplete, bAccept)
  Sleep(200)
  local bClicked = DialogOptionClicked(strClicked, 1, 600)
  if bNext then
    QuestFrameNextClicked(500)
  end
  if bComplete then
    Bag_DeleteItem()
    QuestFrameMissionComplete(nil, 500)
  end
  if bAccept then
    QuestFrameAcceptClicked(500)
  end
  return bClicked
end

function mission_get_name(aMission)
  local misName = ""
  if aMission.option == nil or 0 == #aMission.option then
    misName = aMission.name
  elseif #aMission.option > 0 then
    misName = aMission.option[1]
  end
  return misName
end

function mission_accept(aMission)
  PushDebugMessage("接任务：" .. aMission.name)
  local param = aMission.param_accept
  local use_horse = true
  if param.use_horse ~= nil and param.use_horse == false then
    use_horse = false
  end
  local call_back_run
  if nil ~= param.call_back_run then
    call_back_run = param.call_back_run
  elseif nil ~= param.sceneName and param.sceneName ~= "" then
    if param.sceneID and -1 ~= param.sceneID then
      function call_back_run(fX, fY, nScene)
        DebugStr("接任务移动到%s,%s", 1, fX, fY)
        
        if GetSceneID() ~= param.sceneID then
          return false
        end
        return true
      end
    else
      function call_back_run(fX, fY, nScene)
        DebugStr("任务移动到%s,%s", 1, fX, fY)
        
        if GetCurrentSceneName() ~= param.sceneName then
          return false
        end
        return true
      end
    end
  end
  for i = 1, 3 do
    if nil == call_back_run then
      GoToSceneNPC(param.name, param.x, param.y, param.sceneID, nil, use_horse, nil, nil, true, true)
    else
      MoveToNPC(param.name, param.x, param.y, param.sceneID, nil, use_horse, nil, call_back_run, true, true)
    end
    local misName = mission_get_name(aMission)
    mission_complete_accept(misName, false, false, true)
    if -1 ~= GetPlayerMission(misName) then
      break
    end
    PushColorMsg("再次尝试接任务：" .. misName)
    Sleep(100)
  end
end

function mission_accept_next(mission)
  local param = mission.param_complete
  if param and param.next_mission then
    local nTick = GetTickCount()
    while GetTickCount() - nTick < 10000 do
      local bAccept = false
      for i = 1, #param.next_mission do
        local nIndex, idMission, idScript = GetPlayerMission(param.next_mission[i])
        if -1 == nIndex then
          GoToSceneNPC(param.name, param.x, param.y, param.sceneID, nil, nil, nil, nil, true, true)
          mission_complete_accept(param.next_mission[i], false, false, true)
          bAccept = true
        end
        DebugStr("接取下个任务：" .. param.next_mission[i])
      end
      if false == bAccept then
        break
      end
      Sleep(100)
    end
  end
end

function mission_complete_talk_npc(aMission)
  PushDebugMessage("交任务：" .. aMission.name)
  if aMission.is_check_team then
    Team:LeaveTeam()
  end
  local param = aMission.param_complete
  local use_horse = true
  if param.use_horse ~= nil and param.use_horse == false then
    use_horse = false
  end
  local getNext = false
  if nil == param.next_mission or param.next_mission then
    getNext = true
  end
  local call_back_run
  if nil ~= param.call_back_run then
    call_back_run = param.call_back_run
  elseif nil ~= param.sceneName and param.sceneName ~= "" then
    if param.sceneID and -1 ~= param.sceneID then
      function call_back_run(fX, fY, nScene)
        DebugStr("交任务移动到%s,%s", 1, fX, fY)
        
        if GetSceneID() ~= param.sceneID then
          return false
        end
        return true
      end
    else
      function call_back_run(fX, fY, nScene)
        DebugStr("交任务移动到%s,%s", 1, fX, fY)
        
        if GetCurrentSceneName() ~= param.sceneName then
          return false
        end
        return true
      end
    end
  end
  while true do
    if nil == call_back_run then
      GoToSceneNPC(param.name, param.x, param.y, param.sceneID, nil, use_horse, nil, nil, true, true)
    else
      MoveToNPC(param.name, param.x, param.y, param.sceneID, nil, use_horse, nil, call_back_run, true, true)
    end
    local misName = mission_get_name(aMission)
    if nil == aMission.option or 0 == #aMission.option then
      mission_complete_accept(aMission.name, true, true, getNext)
    elseif 1 == #aMission.option then
      mission_complete_accept(aMission.option[1], true, true, getNext)
    elseif #aMission.option > 1 then
      for i = 1, #aMission.option do
        DialogOptionClicked(aMission.option[i], 1, 700)
      end
      mission_complete_accept(aMission.option[1], true, true, getNext)
    end
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if 1 ~= nComplete or -1 == nIndex then
      break
    end
    Sleep(200)
    GetLuaValue("meReliveHandle(-1)")
    DebugStr("交任务：" .. aMission.name)
    if call_back_run and false == call_back_run() then
      break
    end
  end
  mission_accept_next(aMission)
end

function mission_attack_mode_1(aMission)
  local misName = mission_get_name(aMission)
  local param = aMission.param_action
  local nTick = GetTickCount()
  
  local function call_back_attack()
    DebugStr(aMission.name .. ":执行中，已用时%d秒", 2, math.floor((GetTickCount() - nTick) / 1000))
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if 1 == nComplete or -1 == nIndex then
      return true
    end
    if aMission.is_check_team then
      TeamCheckNear()
    end
    return false
  end
  
  if param.call_back_attack ~= nil then
    call_back_attack = param.call_back_attack
  end
  local call_back_run
  if nil ~= param.call_back_run then
    call_back_run = param.call_back_run
  else
  end
  local pickmode = g_pick.pickmode
  local pickItem = g_pick.pickItem
  if param.pick_item and param.pick_item ~= "" then
    PickUpLua_SetItem(param.pick_item)
  end
  BeginAttack(param.pos, param.sceneName, param.targetName, call_back_attack, call_back_run, {
    attackMode = aMission.attackMode,
    pickup = param.is_pick,
    horse = param.use_horse
  })
  g_pick.pickmode = pickmode
  g_pick.pickItem = pickItem
end
