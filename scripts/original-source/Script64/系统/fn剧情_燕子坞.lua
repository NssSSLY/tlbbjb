-- 反编译自 dfz64.dll 内嵌字节码 004e5d55（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "燕子坞",
  sceneID_hei = 114,
  sceneID_bai = 37
}

function JQ_callback_run_yzw()
  if not JQ_IsFubenScene(m_data.sceneName) then
    return false
  end
  return true
end

function JQ_runto_scene_yzw(bai)
  if not JQ_IsFubenScene(m_data.sceneName) then
    local npc2 = {
      x = 180,
      y = 395,
      sceneID = 1,
      name = "老顾"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    if bai then
      QuestFrameOptionClicked_Item("送我去燕子坞（白天）", 1)
    else
      QuestFrameOptionClicked_Item("送我去燕子坞（夜间）", 1)
    end
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_runto_pos_yzw_out()
  if JQ_IsFubenScene(m_data.sceneName) then
    MoveToNPC("老顾", 109, 103, -1, nil, nil, nil, JQ_callback_run_yzw)
    Sleep(500)
    QuestFrameOptionClicked_Item("送我去苏州", 1)
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_mis_200083()
  local npc = {
    x = 209,
    y = 180,
    sceneID = 1,
    name = "阿碧"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "姑苏慕容"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200084()
  local strMission = "还施水阁"
  local npc = {
    x = 209,
    y = 180,
    sceneID = 1,
    name = "阿碧"
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  elseif JQ_runto_scene_yzw() then
    MoveToNPC("王语嫣", 62, 81, -1, nil, nil, nil, JQ_callback_run_yzw)
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_mis_200012()
  local strMission = "独战双雄"
  local pos = {
    {x = 59, y = 18},
    {x = 95, y = 48}
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_yzw() then
      MoveToNPC("王语嫣", 62, 81, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_yzw() then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC("王语嫣", 62, 81, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, true, true, true)
    else
      local nTick = GetTickCount()
      
      local function call_back()
        DebugStr(strMission .. ":已用时间%d秒,120秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          return true
        end
        if JQ_callback_run_yzw() == false then
          return true
        end
        if -1 == nIndex then
          PushDebugMessage(strMission .. ":任务列表无此任务！")
          return true
        end
        if GetTickCount() - nTick > 120000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          JQ_runto_pos_yzw_out()
          return true
        end
        return false
      end
      
      BeginAttack(pos, nil, " 司马林 姚伯当 ", call_back, JQ_callback_run_yzw, {pickup = true})
    end
  end
end

function JQ_mis_200013()
  local strMission = "夜长梦多"
  local npc = {
    x = 210,
    y = 182,
    sceneID = 1,
    name = "慕容复"
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_yzw() then
      MoveToNPC("王语嫣", 62, 81, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_pos_yzw_out() then
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200085()
  local strMission = "一品堂"
  local npc = {
    x = 210,
    y = 182,
    sceneID = 1,
    name = "慕容复"
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_yzw_out() then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_yzw(true) then
    MoveToNPC("王语嫣", 62, 81, -1, nil, nil, nil, JQ_callback_run_yzw)
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_mis_200015()
  local strMission = "指点群豪戏"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_yzw(true) then
      MoveToNPC("王语嫣", 62, 81, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_yzw(true) then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC("王语嫣", 60, 70, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, true, true, true)
      Sleep(600)
    else
      local nTick = GetTickCount()
      
      local function call_back()
        DebugStr(strMission .. ":已用时间%d秒,120秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          return true
        end
        if JQ_callback_run_yzw() == false then
          return true
        end
        if -1 == nIndex then
          PushDebugMessage(strMission .. ":任务列表无此任务！")
          return true
        end
        if GetTickCount() - nTick > 120000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          JQ_runto_pos_yzw_out()
          return true
        end
        return false
      end
      
      BeginAttack({
        {x = 60, y = 80}
      }, nil, " 黄胡子 灰袍客 虎爪门弟子 摔角高手 虬髯武士 ", call_back, JQ_callback_run_yzw)
    end
  end
end

function JQ_mis_200016()
  local strMission = "悲酥清风"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_yzw(true) then
      MoveToNPC("王语嫣", 60, 70, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, false, false, true)
      mission_complete_accept("指点群豪戏", false, false, true)
      local nTick = GetTickCount()
      
      local function call_back()
        DebugStr(strMission .. ":已用时间%d秒,120秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
        local tObj = Enum2XByName("李延宗", {
          1,
          1,
          1,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          return true
        end
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          return true
        end
        if JQ_callback_run_yzw() == false then
          return true
        end
        if -1 ~= nIndex then
          PushDebugMessage(strMission .. ":任务列表无此任务！")
          return true
        end
        if GetTickCount() - nTick > 120000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          return true
        end
        return false
      end
      
      BeginAttack({
        {x = 59, y = 72}
      }, nil, " 黄胡子 灰袍客 虎爪门弟子 摔角高手 虬髯武士 ", call_back, JQ_callback_run_yzw, {pickup = true})
    end
  elseif JQ_runto_scene_yzw(true) then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC("王语嫣", 60, 70, -1, nil, nil, nil, JQ_callback_run_yzw)
      mission_complete_accept(strMission, true, true, true)
    else
      local nTick = GetTickCount()
      while JQ_callback_run_yzw() do
        if GetTickCount() - nTick > 120000 then
          QuestFrameMissionAbnegate(idScript)
          JQ_runto_pos_yzw_out()
          JQ_runto_pos_yzw_out()
        end
        MoveToNPC("李延宗", 61, 76, -1, nil, nil, nil, JQ_callback_run_yzw)
        Sleep(800)
        QuestFrameOptionClicked_Item("得到悲酥清风的解药", 1)
        Sleep(800)
        if Bag:GetItemCount("悲酥清风解药", nil, nil, Bag:EnumRenWuItem()) > 0 then
          break
        end
        DebugStr("等待剧情,120超时放弃任务！")
      end
    end
  end
end

function JQ_mis_2000_02()
  local strMission = "#{JQLJ_130819_02}"
  if JQ_IsFubenScene(m_data.sceneName) then
    JQ_runto_pos_yzw_out()
  else
    local npc2 = {
      x = 160,
      y = 158,
      sceneID = 2,
      name = "赵天师"
    }
    PushDebugMessage("残破来信：交任务")
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_YZW_DoMission()
  local bHave = false
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " 姑苏慕容 ", nil, true) then
    JQ_mis_200083()
    bHave = true
  elseif string.find(strTemp, " 还施水阁 ", nil, true) then
    JQ_mis_200084()
    bHave = true
  elseif string.find(strTemp, " 独战双雄 ", nil, true) then
    JQ_mis_200012()
    bHave = true
  elseif string.find(strTemp, " 夜长梦多 ", nil, true) then
    JQ_mis_200013()
    bHave = true
  elseif string.find(strTemp, " 一品堂 ", nil, true) then
    JQ_mis_200085()
    bHave = true
  elseif string.find(strTemp, " 指点群豪戏 ", nil, true) then
    JQ_mis_200015()
    bHave = true
  elseif string.find(strTemp, " 悲酥清风 ", nil, true) then
    JQ_mis_200016()
    bHave = true
  elseif string.find(strTemp, " #{JQLJ_130819_02} ", nil, true) then
    JQ_mis_2000_02()
    bHave = true
  end
  return bHave
end

function JQ_YZW_IsInProcess(strProcess)
  if "#{Juqing_Can_009}" == strProcess then
    JQ_mis_200083()
    return JQ_mis_200083
  elseif "#{Juqing_Can_010}" == strProcess then
    JQ_mis_200084()
    return JQ_mis_200084
  elseif "#{Juqing_Can_011}" == strProcess then
    JQ_mis_200012()
    return JQ_mis_200012
  elseif "#{Juqing_Can_012}" == strProcess then
    JQ_mis_200013()
    return JQ_mis_200013
  elseif "#{Juqing_Can_013}" == strProcess then
    JQ_mis_200085()
    return JQ_mis_200085
  elseif "#{Juqing_Can_014}" == strProcess then
    JQ_mis_200015()
    return JQ_mis_200015
  elseif "#{Juqing_Can_015}" == strProcess then
    JQ_mis_200016()
    return JQ_mis_200016
  end
  return nil
end
