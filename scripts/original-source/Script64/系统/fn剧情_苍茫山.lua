-- 反编译自 dfz64.dll 内嵌字节码 004eaaa7（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "苍茫山",
  sceneID_hei = 121,
  sceneID_bai = 120
}

function JQ_callback_run_cms()
  if not JQ_IsFubenScene(m_data.sceneName) then
    return false
  end
  return true
end

function JQ_runto_scene_cms(bai)
  if not JQ_IsFubenScene(m_data.sceneName) then
    local npc2 = {
      x = 128,
      y = 50,
      sceneID = 18,
      name = "耶律莫哥"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    if bai then
      QuestFrameOptionClicked_Item("送我去苍茫山（白天）", 1)
      QuestFrameOptionClicked_Item("送我去苍茫山(白天)", 1)
    else
      QuestFrameOptionClicked_Item("送我去苍茫山(夜间)", 1)
    end
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_runto_pos_cms_out()
  if JQ_IsFubenScene(m_data.sceneName) then
    MoveToNPC("耶律莫哥", 104, 19, -1, nil, nil, nil, JQ_callback_run_cms)
    Sleep(500)
    QuestFrameOptionClicked_Item("送我去雁南", 1)
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_mis_200091()
  local npc = {
    x = 326,
    y = 355,
    sceneID = LUOYANG_ID,
    name = "康敏"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "保护马夫人"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200092()
  local npc = {
    x = 326,
    y = 355,
    sceneID = LUOYANG_ID,
    name = "康敏"
  }
  local npc2 = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local strMission = "一盘散沙"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  else
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_mis_200093()
  local npc = {
    x = 74,
    y = 30,
    sceneID = -1,
    name = "萧峰"
  }
  local npc2 = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local strMission = "远赴苍茫山"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  elseif JQ_runto_scene_cms() then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_mis_200031()
  local npc = {
    x = 74,
    y = 30,
    sceneID = -1,
    name = "萧峰"
  }
  local strMission = "天时不如地利"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_cms() then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_cms() then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, true, true, true)
      Sleep(500)
      if JQ_runto_scene_cms() then
        JQ_mis_200032()
      end
    else
      local nTick = GetTickCount()
      while JQ_runto_scene_cms() do
        if GetTickCount() - nTick > 90000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          JQ_runto_pos_cms_out()
        end
        if 1 == GetMissionComplete(nIndex) then
          break
        end
        MoveTo(24, 80, -1, nil, nil, nil, JQ_callback_run_cms)
        MoveTo(40, 105, -1, nil, nil, nil, JQ_callback_run_cms)
        MoveTo(88, 105, -1, nil, nil, nil, JQ_callback_run_cms)
        MoveTo(67, 85, -1, nil, nil, nil, JQ_callback_run_cms)
        Sleep(500)
        DebugStr(strMission .. " 90秒超时放弃")
      end
    end
  end
end

function JQ_mis_200032()
  local npc = {
    x = 69,
    y = 26,
    sceneID = -1,
    name = "耶律洪基"
  }
  local npc2 = {
    x = 195,
    y = 41,
    sceneID = 19,
    name = "耶律余睹"
  }
  local strMission = "勤王"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_cms() then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_pos_cms_out() then
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_mis_200033()
  local npc = {
    x = 69,
    y = 26,
    sceneID = -1,
    name = "耶律洪基"
  }
  local npc2 = {
    x = 195,
    y = 41,
    sceneID = 19,
    name = "耶律余睹"
  }
  local strMission = "运筹帷幄"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_cms_out() then
      JQ_mission_accept(npc2, strMission)
    end
  elseif JQ_runto_scene_cms(true) then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_mis_200035()
  local npc = {
    x = 69,
    y = 26,
    sceneID = -1,
    name = "耶律洪基"
  }
  local npc2 = {
    x = 74,
    y = 30,
    sceneID = -1,
    name = "萧峰"
  }
  local strMission = "四面楚歌"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_cms(true) then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_cms(true) then
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_cms)
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_mis_200036()
  local npc = {
    x = 50,
    y = 106,
    sceneID = -1,
    name = "萧峰"
  }
  local npc2 = {
    x = 74,
    y = 30,
    sceneID = -1,
    name = "萧峰"
  }
  local strMission = "金戈荡寇鏖兵"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_cms(true) then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, false, false, true)
    end
  else
    if not JQ_IsFubenScene(m_data.sceneName) then
      PushColorMsg("不在任务地图,放弃任务：金戈荡寇鏖兵")
      QuestFrameMissionAbnegate(idScript)
      return
    end
    if JQ_runto_scene_cms(true) then
      if 1 == GetMissionComplete(nIndex) then
        local nTick = GetTickCount()
        while JQ_runto_scene_cms(true) do
          MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
          mission_complete_accept(strMission, true, true, true)
          Sleep(500)
          local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
          if -1 == nIndex then
            break
          end
          if GetTickCount() - nTick > 90000 then
            PushColorMsg(strMission .. ":任务超时,放弃任务!!！")
            QuestFrameMissionAbnegate(idScript)
            JQ_runto_pos_cms_out()
            Sleep(100)
          end
        end
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if -1 == nIndex and JQ_runto_scene_cms(true) then
          JQ_mis_200037()
        end
      else
        local nTick = GetTickCount()
        
        local function call_back()
          DebugStr(strMission .. ":已用时间%d秒,200秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
          local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
          if 1 == nComplete then
            return true
          end
          if JQ_callback_run_cms() == false then
            return true
          end
          if -1 == nIndex then
            PushDebugMessage(strMission .. ":任务列表无此任务！")
            return true
          end
          if GetTickCount() - nTick > 200000 then
            PushColorMsg(strMission .. ":任务超时,放弃任务！")
            QuestFrameMissionAbnegate(idScript)
            JQ_runto_pos_cms_out()
            return true
          end
          return false
        end
        
        BeginAttack({
          {x = 73, y = 45},
          {x = 45, y = 105}
        }, nil, " 耶律涅鲁古 ", call_back, JQ_callback_run_cms)
      end
    end
  end
end

function JQ_mis_200037()
  local npc = {
    x = 50,
    y = 106,
    sceneID = -1,
    name = "萧峰"
  }
  local npc2 = {
    x = 75,
    y = 26,
    sceneID = -1,
    name = "萧峰"
  }
  local strMission = "六军辟易"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_cms(true) then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, false, false, true)
    end
  else
    local nTick = GetTickCount()
    while JQ_runto_scene_cms(true) do
      if GetTickCount() - nTick > 150000 then
        QuestFrameMissionAbnegate(idScript)
        JQ_runto_pos_cms_out()
        break
      end
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_cms)
      mission_complete_accept(strMission, true, true, true)
      Sleep(800)
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 == nIndex then
        break
      end
      DebugStr("等待剧情,150秒超时放弃任务！")
    end
  end
end

function JQ_mis_2000_04()
  local strMission = "#{JQLJ_130819_04}"
  if JQ_IsFubenScene(m_data.sceneName) then
    JQ_runto_pos_cms_out()
  else
    local npc2 = {
      x = 160,
      y = 158,
      sceneID = 2,
      name = "赵天师"
    }
    PushDebugMessage("神木王鼎")
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_CMS_DoMission()
  local bHave = false
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " 保护马夫人 ", nil, true) then
    JQ_mis_200091()
    bHave = true
  elseif string.find(strTemp, " 一盘散沙 ", nil, true) then
    JQ_mis_200092()
    bHave = true
  elseif string.find(strTemp, " 远赴苍茫山 ", nil, true) then
    JQ_mis_200093()
    bHave = true
  elseif string.find(strTemp, " 天时不如地利 ", nil, true) then
    JQ_mis_200031()
    bHave = true
  elseif string.find(strTemp, " 勤王 ", nil, true) then
    JQ_mis_200032()
    bHave = true
  elseif string.find(strTemp, " 运筹帷幄 ", nil, true) then
    JQ_mis_200033()
    bHave = true
  elseif string.find(strTemp, " 四面楚歌 ", nil, true) then
    JQ_mis_200035()
    bHave = true
  elseif string.find(strTemp, " 金戈荡寇鏖兵 ", nil, true) then
    JQ_mis_200036()
    bHave = true
  elseif string.find(strTemp, " 六军辟易 ", nil, true) then
    JQ_mis_200037()
    bHave = true
  elseif string.find(strTemp, " #{JQLJ_130819_04} ", nil, true) then
    JQ_mis_2000_04()
    bHave = true
  end
  return bHave
end

function JQ_CMS_IsInProcess(strProcess)
  if "#{Juqing_Can_024}" == strProcess then
    JQ_mis_200091()
    return JQ_mis_200091
  elseif "#{Juqing_Can_025}" == strProcess then
    JQ_mis_200092()
    return JQ_mis_200092
  elseif "#{Juqing_Can_026}" == strProcess then
    JQ_mis_200093()
    return JQ_mis_200093
  elseif "#{Juqing_Can_027}" == strProcess then
    JQ_mis_200031()
    return JQ_mis_200031
  elseif "#{Juqing_Can_028}" == strProcess then
    JQ_mis_200032()
    return JQ_mis_200032
  elseif "#{Juqing_Can_029}" == strProcess then
    JQ_mis_200033()
    return JQ_mis_200033
  elseif "#{Juqing_Can_030}" == strProcess then
    JQ_mis_200035()
    return JQ_mis_200035
  elseif "#{Juqing_Can_031}" == strProcess then
    JQ_mis_200036()
    return JQ_mis_200036
  elseif "#{Juqing_Can_032}" == strProcess then
    JQ_mis_200037()
    return JQ_mis_200037
  end
  return nil
end
