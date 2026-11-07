-- 反编译自 dfz64.dll 内嵌字节码 004dc4b9（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "一品堂",
  sceneID_hei = -1,
  sceneID_bai = -1
}

function JQ_callback_run_ypt()
  if GetCurrentSceneName() ~= m_data.sceneName then
    return false
  end
  return true
end

function JQ_runto_scene_ypt(bai)
  if GetCurrentSceneName() ~= m_data.sceneName then
    local npc2 = {
      x = 208,
      y = 207,
      sceneID = LUOYANG_ID,
      name = "努儿海"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    if bai then
      QuestFrameOptionClicked_Item("送我去一品堂(白天)", 1)
    else
      QuestFrameOptionClicked_Item("送我去一品堂(夜间)", 1)
    end
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_runto_pos_ypt_out()
  if GetCurrentSceneName() == m_data.sceneName then
    MoveToNPC("努儿海", 32, 114, -1, nil, nil, nil, JQ_callback_run_ypt)
    Sleep(500)
    QuestFrameOptionClicked_Item("离开这里", 1)
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_mis_200095()
  local npc = {
    x = 210,
    y = 207,
    sceneID = LUOYANG_ID,
    name = "赫连铁树"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "万国蹴鞠锦标赛"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200096()
  local npc = {
    x = 210,
    y = 207,
    sceneID = LUOYANG_ID,
    name = "赫连铁树"
  }
  local npc2 = {
    x = 91,
    y = 44,
    sceneID = 17,
    name = "梅剑"
  }
  local strMission = "一剑上天山"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  else
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_mis_200097()
  local npc2 = {
    x = 91,
    y = 44,
    sceneID = 17,
    name = "梅剑"
  }
  local npc = {
    x = 19,
    y = 26,
    sceneID = -1,
    name = "天山童姥"
  }
  local strMission = "虽危实安"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  elseif JQ_runto_scene_ypt() then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run_ypt)
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_mis_200051()
  local npc2 = {
    x = 19,
    y = 26,
    sceneID = -1,
    name = "天山童姥"
  }
  local npc3 = {
    x = 22,
    y = 21,
    sceneID = -1,
    name = "虚竹"
  }
  local strMission = "一笑人间万事"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_ypt() then
      MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_ypt)
      mission_complete_accept(strMission, false, false, true)
    end
  else
    local nTick = GetTickCount()
    while JQ_runto_scene_ypt() do
      local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 == nIndex then
        break
      end
      if 1 == GetMissionComplete(nIndex) then
        MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
        mission_complete_accept(strMission, true, true, true)
        break
      else
        MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run_ypt)
        DebugStr("等待任务完成,300秒超时", 2)
        Sleep(1000)
      end
      if GetTickCount() - nTick > 300000 then
        QuestFrameMissionAbnegate(idScript)
        Sleep(2000)
      end
      Sleep(1000)
    end
  end
end

function JQ_mis_200052()
  local npc = {
    x = 210,
    y = 207,
    sceneID = LUOYANG_ID,
    name = "赫连铁树"
  }
  local npc3 = {
    x = 22,
    y = 21,
    sceneID = -1,
    name = "虚竹"
  }
  local strMission = "环佩空归月夜魂"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_ypt() then
      MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_pos_ypt_out() then
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_200053()
  local npc = {
    x = 210,
    y = 207,
    sceneID = LUOYANG_ID,
    name = "赫连铁树"
  }
  local npc3 = {
    x = 32,
    y = 70,
    sceneID = -1,
    name = "晓蕾"
  }
  local strMission = "酒罢问君三语"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_ypt_out() then
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_runto_scene_ypt(true) then
    MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_mis_200055()
  local npc = {
    x = 210,
    y = 207,
    sceneID = LUOYANG_ID,
    name = "赫连铁树"
  }
  local npc3 = {
    x = 32,
    y = 70,
    sceneID = -1,
    name = "晓蕾"
  }
  local pos = {
    {x = 32, y = 75},
    {x = 32, y = 85}
  }
  local strMission = "我的爱情不是梦"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_ypt(true) then
      local tObj = Enum2XByName("一品点燃火炬", {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if 0 == #tObj then
        tObj = Enum2XByName("一品点燃火炬", {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
          mission_complete_accept(strMission, false, false, true)
          mission_complete_accept("酒罢问君三语", false, true, true)
        else
          MoveTo(pos[2].x, pos[2].y, -1, nil, nil, nil, JQ_callback_run_ypt)
          local tObj = Enum2XByName("一品点燃火炬", {
            1,
            1,
            0,
            0
          }, nil, nil, 0)
          if 0 == #tObj then
            MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
            mission_complete_accept(strMission, false, false, true)
          end
        end
      else
        local nTick = GetTickCount()
        
        local function call_back()
          DebugStr(strMission .. ":已用时间%d秒", 2, math.floor((GetTickCount() - nTick) / 1000))
          local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
          if 1 == nComplete then
            return true
          end
          if JQ_callback_run_ypt() == false then
            return true
          end
          if GetTickCount() - nTick > 90000 then
            local tObj = Enum2XByName("一品点燃火炬", {
              0,
              1,
              0,
              0
            }, nil, nil, 0)
            if 0 == #tObj then
              return true
            end
          end
          return false
        end
        
        BeginAttack(pos, nil, " 一品点燃火炬 ", call_back, JQ_callback_run_ypt)
      end
    end
  elseif JQ_runto_scene_ypt(true) then
    MoveToNPC("虚竹", 29, 90, -1, nil, nil, nil, JQ_callback_run_ypt)
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_mis_200056()
  local npc3 = {
    x = 21,
    y = 28,
    sceneID = -1,
    name = "李清露"
  }
  local strMission = "一生有你"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_scene_ypt(true) then
      MoveToNPC("虚竹", 29, 90, -1, nil, nil, nil, JQ_callback_run_ypt)
      mission_complete_accept(strMission, false, false, true)
    end
  elseif 1 == GetMissionComplete(nIndex) then
    MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
    mission_complete_accept(strMission, false, true, true)
  elseif JQ_runto_scene_ypt(true) then
    MoveTo(npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run_ypt)
    DebugStr("等待任务结束")
  end
end

function JQ_mis_2000_06()
  local strMission = "#{JQLJ_130819_06}"
  if GetCurrentSceneName() == m_data.sceneName then
    JQ_runto_pos_ypt_out()
  else
    local npc2 = {
      x = 160,
      y = 158,
      sceneID = 2,
      name = "赵天师"
    }
    PushDebugMessage("易筋经")
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_YPT_DoMission()
  local bHave = false
  local callFun
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " 万国蹴鞠锦标赛 ", nil, true) then
    JQ_mis_200095()
    bHave = true
  elseif string.find(strTemp, " 一剑上天山 ", nil, true) then
    JQ_mis_200096()
    bHave = true
  elseif string.find(strTemp, " 虽危实安 ", nil, true) then
    JQ_mis_200097()
    bHave = true
  elseif string.find(strTemp, " 一笑人间万事 ", nil, true) then
    JQ_mis_200051()
    bHave = true
  elseif string.find(strTemp, " 环佩空归月夜魂 ", nil, true) then
    JQ_mis_200052()
    bHave = true
  elseif string.find(strTemp, " 酒罢问君三语 ", nil, true) then
    JQ_mis_200053()
    bHave = true
  elseif string.find(strTemp, " 我的爱情不是梦 ", nil, true) then
    JQ_mis_200055()
    bHave = true
  elseif string.find(strTemp, " 一生有你 ", nil, true) then
    JQ_mis_200056()
    bHave = true
  elseif string.find(strTemp, " #{JQLJ_130819_06} ", nil, true) then
    JQ_mis_2000_06()
    bHave = true
  end
  return bHave, callFun
end

function JQ_YPT_IsInProcess(strProcess)
  if "#{Juqing_Can_038}" == strProcess then
    JQ_mis_200095()
    return JQ_mis_200095
  elseif "#{Juqing_Can_039}" == strProcess then
    JQ_mis_200096()
    return JQ_mis_200096
  elseif "#{Juqing_Can_040}" == strProcess then
    JQ_mis_200097()
    return JQ_mis_200097
  elseif "#{Juqing_Can_041}" == strProcess then
    JQ_mis_200051()
    return JQ_mis_200051
  elseif "#{Juqing_Can_042}" == strProcess then
    JQ_mis_200052()
    return JQ_mis_200052
  elseif "#{Juqing_Can_043}" == strProcess then
    JQ_mis_200053()
    return JQ_mis_200053
  elseif "#{Juqing_Can_044}" == strProcess then
    JQ_mis_200055()
    return JQ_mis_200055
  elseif "#{Juqing_Can_045}" == strProcess then
    JQ_mis_200056()
    return JQ_mis_200056
  end
  return nil
end
