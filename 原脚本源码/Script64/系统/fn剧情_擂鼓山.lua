-- 反编译自 dfz64.dll 内嵌字节码 004e4386（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "擂鼓山",
  sceneID_hei = 117,
  sceneID_bai = 120
}

function JQ_callback_run_lgs()
  if GetCurrentSceneName() ~= m_data.sceneName then
    return false
  end
  return true
end

function JQ_runto_scene_lgs(bai)
  if GetCurrentSceneName() ~= m_data.sceneName then
    local npc2 = {
      x = 152,
      y = 153,
      sceneID = 14,
      name = "范百龄"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    if bai then
      QuestFrameOptionClicked_Item("送我去擂鼓山(白天)", 1)
    else
      QuestFrameOptionClicked_Item("送我去擂鼓山(夜间)", 1)
    end
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_runto_pos_lgs_out()
  if GetCurrentSceneName() == m_data.sceneName then
    MoveToNPC("范百龄", 56, 107, -1, nil, nil, nil, JQ_callback_run_lgs)
    Sleep(500)
    QuestFrameOptionClicked_Item("离开这里", 1)
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_mis_200094()
  local npc = {
    x = 125,
    y = 144,
    sceneID = 14,
    name = "苏星河"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "珍珑棋会"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200041()
  local npc = {
    x = 125,
    y = 144,
    sceneID = 14,
    name = "苏星河"
  }
  local npc2 = {
    x = 79,
    y = 30,
    sceneID = -1,
    name = "苏星河"
  }
  local strMission = "静候佳音"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_lgs_out() then
      JQ_mission_accept(npc, strMission)
    end
  elseif JQ_runto_scene_lgs() then
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_lgs)
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_mis_200042()
  local npc = {
    x = 125,
    y = 144,
    sceneID = 14,
    name = "苏星河"
  }
  local npc2 = {
    x = 79,
    y = 30,
    sceneID = -1,
    name = "苏星河"
  }
  local strMission = "输赢成败谁人算"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_lgs() then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_lgs)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_lgs() then
    if 1 == GetMissionComplete(nIndex) then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_lgs)
      mission_complete_accept(strMission, true, true, true)
    else
      RunTo(88, 31, 0, 600)
      Dismount()
      DebugStr("等待任务完成", 2)
      Skill:UseName("初级隐遁", 500)
      Sleep(1000)
    end
  end
end

function JQ_mis_200043()
  local npc = {
    x = 125,
    y = 144,
    sceneID = 14,
    name = "苏星河"
  }
  local npc2 = {
    x = 79,
    y = 30,
    sceneID = -1,
    name = "苏星河"
  }
  local strMission = "择日再战"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_lgs() then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_lgs)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_pos_lgs_out() then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_mis_200045()
  local npc = {
    x = 125,
    y = 144,
    sceneID = 14,
    name = "苏星河"
  }
  local npc2 = {
    x = 67,
    y = 37,
    sceneID = -1,
    name = "丁春秋"
  }
  local strMission = "关门捉贼"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_lgs_out() then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_lgs(true) then
    if 1 == GetMissionComplete(nIndex) then
      local tObj = Enum2XByName("苏星河", {
        1,
        1,
        1,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        RunTo(tObj[1].x, tObj[1].y, 0, 500)
        TalkNpc("苏星河")
        Sleep(500)
        mission_complete_accept(strMission, true, true, true)
      else
        MoveTo(npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_lgs)
      end
    else
      CDG.die.out = true
      CDG.attack = true
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_lgs)
      while JQ_runto_scene_lgs(true) do
        local tObj = Enum2XByName("丁春秋", {
          1,
          1,
          1,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          if tObj[1].class == "NPC" then
            RunTo(tObj[1].x, tObj[1].y, 0, 500)
            TalkNpc("丁春秋")
            Sleep(500)
            QuestFrameOptionClicked_Item("挑战丁春秋", 1)
            Sleep(600)
          else
            FubenAttack(tObj[1].id, true, true)
          end
        elseif RunTo(npc2.x, npc2.y, 0, 500) == false then
          break
        end
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete or -1 == nIndex then
          break
        end
        Sleep(200)
        DebugStr("关门捉贼：击杀丁春秋")
      end
    end
  end
end

function JQ_mis_2000_05()
  local strMission = "#{JQLJ_130819_05}"
  if GetCurrentSceneName() == m_data.sceneName then
    JQ_runto_pos_lgs_out()
  else
    local npc2 = {
      x = 160,
      y = 158,
      sceneID = 2,
      name = "赵天师"
    }
    PushDebugMessage("天山童姥")
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_LGS_DoMission()
  local bHave = false
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " 珍珑棋会 ", nil, true) then
    JQ_mis_200094()
    bHave = true
  elseif string.find(strTemp, " 静候佳音 ", nil, true) then
    JQ_mis_200041()
    bHave = true
  elseif string.find(strTemp, " 输赢成败谁人算 ", nil, true) then
    JQ_mis_200042()
    bHave = true
  elseif string.find(strTemp, " 择日再战 ", nil, true) then
    JQ_mis_200043()
    bHave = true
  elseif string.find(strTemp, " 关门捉贼 ", nil, true) then
    JQ_mis_200045()
    bHave = true
  elseif string.find(strTemp, " #{JQLJ_130819_05} ", nil, true) then
    JQ_mis_2000_05()
    bHave = true
  end
  return bHave
end

function JQ_LGS_IsInProcess(strProcess)
  if "#{Juqing_Can_033}" == strProcess then
    JQ_mis_200094()
    return JQ_mis_200094
  elseif "#{Juqing_Can_034}" == strProcess then
    JQ_mis_200041()
    return JQ_mis_200041
  elseif "#{Juqing_Can_035}" == strProcess then
    JQ_mis_200042()
    return JQ_mis_200042
  elseif "#{Juqing_Can_036}" == strProcess then
    JQ_mis_200043()
    return JQ_mis_200043
  elseif "#{Juqing_Can_037}" == strProcess then
    JQ_mis_200045()
    return JQ_mis_200045
  end
  return nil
end
