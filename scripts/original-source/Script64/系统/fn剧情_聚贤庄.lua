-- 反编译自 dfz64.dll 内嵌字节码 004e835b（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "聚贤庄",
  sceneID_hei = 113,
  sceneID_bai = 36
}

function JQ_callback_run_jxz()
  if not JQ_IsFubenScene(m_data.sceneName) then
    return false
  end
  return true
end

function JQ_runto_scene_jxz(bai)
  if not JQ_IsFubenScene(m_data.sceneName) then
    local npc2 = {
      x = 307,
      y = 343,
      sceneID = LUOYANG_ID,
      name = "徐惊雷"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    if bai then
      QuestFrameOptionClicked_Item("送我去聚贤庄（白天）", 1)
    else
      QuestFrameOptionClicked_Item("送我去聚贤庄（夜间）", 1)
    end
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_runto_pos_jxz_out()
  if JQ_IsFubenScene(m_data.sceneName) then
    MoveToNPC("徐惊雷", 60, 111, -1, nil, nil, nil, JQ_callback_run_jxz)
    Sleep(500)
    QuestFrameOptionClicked_Item("送我去洛阳", 1)
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_mis_200086()
  local npc = {
    x = 307,
    y = 343,
    sceneID = LUOYANG_ID,
    name = "徐惊雷"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "四海为家"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200087()
  local npc = {
    x = 307,
    y = 343,
    sceneID = LUOYANG_ID,
    name = "徐惊雷"
  }
  local npc2 = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local strMission = "群龙无首"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  else
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_mis_200088()
  local npc = {
    x = 307,
    y = 343,
    sceneID = LUOYANG_ID,
    name = "徐惊雷"
  }
  local npc2 = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local strMission = "共同进退"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200089()
  local npc = {
    x = 307,
    y = 343,
    sceneID = LUOYANG_ID,
    name = "徐惊雷"
  }
  local npc2 = {
    x = 38,
    y = 98,
    sceneID = 9,
    name = "玄慈"
  }
  local strMission = "天下武功出少林"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  else
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_mis_200090()
  local npc = {
    x = 307,
    y = 343,
    sceneID = LUOYANG_ID,
    name = "徐惊雷"
  }
  local npc2 = {
    x = 38,
    y = 98,
    sceneID = 9,
    name = "玄慈"
  }
  local strMission = "聚贤庄"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200021()
  local npc2 = {
    x = 18,
    y = 86,
    sceneID = -1,
    name = "乔峰"
  }
  local strMission = "顶天立地"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_jxz() then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_jxz)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_jxz() then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_jxz)
      mission_complete_accept(strMission, true, true, true)
    else
      local nTick = GetTickCount()
      
      local function call_back()
        DebugStr(strMission .. ":已用时间%d秒,120秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          return true
        end
        if JQ_callback_run_jxz() == false then
          return true
        end
        if -1 == nIndex then
          PushDebugMessage(strMission .. ":任务列表无此任务！")
          return true
        end
        if GetTickCount() - nTick > 120000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          JQ_runto_pos_jxz_out()
          return true
        end
        return false
      end
      
      BeginAttack({
        {x = 50, y = 65},
        {x = 60, y = 56},
        {x = 75, y = 69}
      }, nil, " 鲍千灵 祁六 向望海 ", call_back, JQ_callback_run_jxz)
    end
  end
end

function JQ_mis_200026()
  local npc = {
    x = 376,
    y = 268,
    sceneID = LUOYANG_ID,
    name = "乔峰"
  }
  local npc2 = {
    x = 18,
    y = 86,
    sceneID = -1,
    name = "乔峰"
  }
  local strMission = "后会有期"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_jxz() then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_jxz)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_pos_jxz_out() then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_mis_200022()
  local npc = {
    x = 376,
    y = 268,
    sceneID = LUOYANG_ID,
    name = "乔峰"
  }
  local npc2 = {
    x = 307,
    y = 343,
    sceneID = LUOYANG_ID,
    name = "徐惊雷"
  }
  local npc3 = {
    x = 18,
    y = 86,
    sceneID = -1,
    name = "乔峰"
  }
  local strMission = "虽万千人吾往矣"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_jxz_out() then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
      mission_complete_accept(strMission, false, false, true)
    end
  else
    local nTick = GetTickCount()
    while JQ_runto_pos_jxz_out() do
      if GetTickCount() - nTick > 150000 then
        QuestFrameMissionAbnegate(idScript)
        break
      end
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
      mission_complete_accept(strMission, false, true, false)
      Sleep(800)
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 == nIndex then
        JQ_runto_scene_jxz(true)
        Sleep(600)
        if JQ_runto_scene_jxz(true) then
          JQ_mis_200024()
          break
        end
        break
      end
      DebugStr("等待剧情,150秒超时放弃任务！")
    end
  end
end

function JQ_mis_200024()
  local npc = {
    x = 94,
    y = 51,
    sceneID = -1,
    name = "薛慕华"
  }
  local npc2 = {
    x = 60,
    y = 16,
    sceneID = -1,
    name = "乔峰"
  }
  local strMission = "血战聚贤庄"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_jxz(true) then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_jxz)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_jxz(true) then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_jxz)
      mission_complete_accept(strMission, true, true, true)
    else
      local nTick = GetTickCount()
      
      local function call_back()
        DebugStr(strMission .. ":已用时间%d秒,1200秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          return true
        end
        if JQ_callback_run_jxz() == false then
          return true
        end
        if -1 == nIndex then
          PushDebugMessage(strMission .. ":任务列表无此任务！")
          return true
        end
        if GetTickCount() - nTick > 1200000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          JQ_runto_pos_jxz_out()
          return true
        end
        return false
      end
      
      BeginAttack({
        {x = 60, y = 30}
      }, nil, "", call_back, JQ_callback_run_jxz)
    end
  end
end

function JQ_mis_2000_03()
  local strMission = "#{JQLJ_130819_03}"
  if JQ_IsFubenScene(m_data.sceneName) then
    JQ_runto_pos_jxz_out()
  else
    local npc2 = {
      x = 160,
      y = 158,
      sceneID = 2,
      name = "赵天师"
    }
    PushDebugMessage("雁南绝字：交任务")
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_JXZ_DoMission()
  local bHave = false
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " 四海为家 ", nil, true) then
    JQ_mis_200086()
    bHave = true
  elseif string.find(strTemp, " 群龙无首 ", nil, true) then
    JQ_mis_200087()
    bHave = true
  elseif string.find(strTemp, " 共同进退 ", nil, true) then
    JQ_mis_200088()
    bHave = true
  elseif string.find(strTemp, " 天下武功出少林 ", nil, true) then
    JQ_mis_200089()
    bHave = true
  elseif string.find(strTemp, " 聚贤庄 ", nil, true) then
    JQ_mis_200090()
    bHave = true
  elseif string.find(strTemp, " 顶天立地 ", nil, true) then
    JQ_mis_200021()
    bHave = true
  elseif string.find(strTemp, " 后会有期 ", nil, true) then
    JQ_mis_200026()
    bHave = true
  elseif string.find(strTemp, " 虽万千人吾往矣 ", nil, true) then
    JQ_mis_200022()
    bHave = true
  elseif string.find(strTemp, " 血战聚贤庄 ", nil, true) then
    JQ_mis_200024()
    bHave = true
  elseif string.find(strTemp, " #{JQLJ_130819_03} ", nil, true) then
    JQ_mis_2000_03()
    bHave = true
  end
  return bHave
end

function JQ_JXZ_IsInProcess(strProcess)
  if "#{Juqing_Can_016}" == strProcess then
    JQ_mis_200086()
    return JQ_mis_200086
  elseif "#{Juqing_Can_017}" == strProcess then
    JQ_mis_200087()
    return JQ_mis_200087
  elseif "#{Juqing_Can_018}" == strProcess then
    JQ_mis_200088()
    return JQ_mis_200088
  elseif "#{Juqing_Can_019}" == strProcess then
    JQ_mis_200089()
    return JQ_mis_200089
  elseif "#{Juqing_Can_020}" == strProcess then
    JQ_mis_200090()
    return JQ_mis_200090
  elseif "#{Juqing_Can_021}" == strProcess then
    JQ_mis_200021()
    return JQ_mis_200021
  elseif "#{Juqing_Have_046}" == strProcess or "#{Juqing_Can_046}" == strProcess then
    JQ_mis_200026()
    return JQ_mis_200026
  elseif "#{Juqing_Can_022}" == strProcess then
    JQ_mis_200022()
    return JQ_mis_200022
  elseif "#{Juqing_Can_023}" == strProcess then
    JQ_mis_200024()
    return JQ_mis_200024
  end
  return nil
end
