-- 反编译自 dfz64.dll 内嵌字节码 004de8ed（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "万劫谷",
  sceneID_hei = 119,
  sceneID_bai = 118
}

function JQ_callback_run_wjg()
  if not JQ_IsFubenScene(m_data.sceneName) then
    return false
  end
  local tObj = Enum2XByName("万劫谷木人守卫", {
    1,
    1,
    1,
    0
  }, nil, nil, 10)
  if #tObj > 0 then
    return false
  end
  return true
end

function JQ_WJG_runto_scene_wjg(bai)
  if not JQ_IsFubenScene(m_data.sceneName) then
    local npc2 = {
      x = 71,
      y = 28,
      sceneID = 2,
      name = "华赫艮"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    if bai then
      QuestFrameOptionClicked_Item("送我去万劫谷（白天）", 1)
    else
      QuestFrameOptionClicked_Item("送我去万劫谷(夜间)", 1)
    end
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_WJG_runto_pos_wjg_in(xPos, yPos, strNpc)
  if GetDist(108, 113) < 15 then
    RunTo(108, 111, 3, 1000)
    TalkNpc("万劫谷木人守卫")
    Sleep(500)
    QuestFrameOptionClicked_Item("送我进去", 1, 700)
  end
  if xPos and yPos and strNpc and GetDist(108, 113) > 15 then
    MoveToNPC(strNpc, xPos, yPos, -1, nil, nil, nil, JQ_callback_run_wjg)
  end
end

function JQ_WJG_runto_pos_wjg_out()
  if GetDist(108, 113) > 15 then
    MoveToNPC("华赫艮", 104, 79, -1, nil, nil, nil, JQ_callback_run_wjg)
    Sleep(500)
    QuestFrameOptionClicked_Item("送我到门口去", 1)
    Sleep(500)
  end
  if GetDist(108, 113) < 15 then
    RunTo(108, 111, 3, 1000)
    TalkNpc("万劫谷木人守卫")
    Sleep(500)
    QuestFrameOptionClicked_Item("送我去大理", 1)
    Sleep(600)
  end
end

function JQ_WJG_mis_200001()
  local npc = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "谁家子弟谁家院"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_WJG_mis_200002()
  local npc = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local strMission = "青衫磊落险峰行"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  elseif JQ_WJG_runto_scene_wjg() then
    JQ_WJG_runto_pos_wjg_in(28, 14, "钟灵")
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_WJG_mis_200003()
  local strMission = "微笑之旅"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_WJG_runto_scene_wjg() then
      JQ_WJG_runto_pos_wjg_in(28, 14, "钟灵")
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_WJG_runto_scene_wjg() then
    JQ_WJG_runto_pos_wjg_in(48, 94, "万劫谷石敢当")
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_WJG_mis_200004()
  local strMission = "恶贯满盈"
  local npc = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_WJG_runto_scene_wjg() then
      JQ_WJG_runto_pos_wjg_in(48, 94, "万劫谷石敢当")
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_IsFubenScene(m_data.sceneName) then
    JQ_WJG_runto_pos_wjg_out()
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_WJG_mis_200005()
  local strMission = "相会在万劫谷"
  local npc = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  elseif JQ_WJG_runto_scene_wjg(true) then
    JQ_WJG_runto_pos_wjg_in(104, 57, "段正淳")
    mission_complete_accept(strMission, false, true, true)
  end
end

function JQ_WJG_mis_200006()
  local strMission = "大战万劫谷"
  local pos = {
    {
      x = 106,
      y = 23,
      name = "云中鹤"
    },
    {
      x = 77,
      y = 21,
      name = "岳老三"
    },
    {
      x = 52,
      y = 32,
      name = "叶二娘"
    }
  }
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_WJG_runto_scene_wjg(true) then
      JQ_WJG_runto_pos_wjg_in(103, 59, "段正淳")
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_WJG_runto_scene_wjg(true) then
    if 1 == GetMissionComplete(nIndex) then
      JQ_WJG_runto_pos_wjg_in(103, 59, "段正淳")
      mission_complete_accept(strMission, true, true, true)
    else
      JQ_WJG_runto_pos_wjg_in()
      local nTick = GetTickCount()
      
      local function call_back()
        DebugStr(strMission .. ":已用时间%d秒,120秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
        local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          return true
        end
        if JQ_callback_run_wjg() == false then
          return true
        end
        if -1 == nIndex then
          PushDebugMessage(strMission .. ":任务列表无此任务！")
          return true
        end
        if GetTickCount() - nTick > 120000 then
          PushColorMsg(strMission .. ":任务超时,放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          JQ_WJG_runto_pos_wjg_out()
          return true
        end
        return false
      end
      
      BeginAttack(pos, nil, " 云中鹤 岳老三 叶二娘 ", call_back, JQ_callback_run_wjg)
    end
  end
end

function JQ_WJG_mis_200007()
  local strMission = "大进军"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_WJG_runto_scene_wjg(true) then
      JQ_WJG_runto_pos_wjg_in(103, 59, "段正淳")
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_WJG_runto_scene_wjg(true) then
    JQ_WJG_runto_pos_wjg_in(60, 87, "段正明")
    mission_complete_accept(strMission, true, true, true)
  end
end

function JQ_WJG_mis_200008()
  local strMission = "虎啸龙吟"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_WJG_runto_scene_wjg(true) then
      JQ_WJG_runto_pos_wjg_in(60, 87, "段正明")
      mission_complete_accept(strMission, false, false, true)
    end
  elseif JQ_WJG_runto_scene_wjg(true) then
    if 1 == GetMissionComplete(nIndex) then
      JQ_WJG_runto_pos_wjg_in(60, 87, "段正明")
      mission_complete_accept(strMission, true, true, true)
    else
      JQ_WJG_runto_pos_wjg_in()
      if Bag:GetItemCount("石屋的钥匙", nil, nil, Bag:EnumRenWuItem()) > 0 then
        JQ_WJG_runto_pos_wjg_in(48, 94, "万劫谷石敢当")
        QuestFrameOptionClicked_Item("打开石门", 1, 600)
      else
        local nTick = GetTickCount()
        
        local function call_back()
          DebugStr(strMission .. ":已用时间%d秒,120秒超时后将放弃重接任务！", 2, math.floor((GetTickCount() - nTick) / 1000))
          local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
          if 1 == nComplete then
            return true
          end
          if JQ_callback_run_wjg() == false then
            return true
          end
          if Bag:GetItemCount("石屋的钥匙", nil, nil, Bag:EnumRenWuItem()) > 0 then
            return true
          end
          if -1 == nIndex then
            PushDebugMessage(strMission .. ":任务列表无此任务！")
            return true
          end
          if GetTickCount() - nTick > 120000 then
            PushColorMsg(strMission .. ":任务超时,放弃任务！")
            QuestFrameMissionAbnegate(idScript)
            JQ_WJG_runto_pos_wjg_out()
            return true
          end
          return false
        end
        
        BeginAttack({
          {x = 59, y = 89}
        }, nil, " 段延庆 ", call_back, JQ_callback_run_wjg, {pickup = true})
      end
    end
  end
end

function JQ_WJG_mis_200009()
  local strMission = "#{JQLJ_130819_01}"
  if JQ_IsFubenScene(m_data.sceneName) then
    JQ_WJG_runto_pos_wjg_out()
  else
    local npc2 = {
      x = 160,
      y = 158,
      sceneID = 2,
      name = "赵天师"
    }
    PushDebugMessage("美人画卷：交任务")
    JQ_mission_complete(npc2, strMission)
  end
end

function JQ_WJG_DoMission()
  local bHave = false
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " 谁家子弟谁家院 ", nil, true) then
    JQ_WJG_mis_200001()
    bHave = true
  elseif string.find(strTemp, " 青衫磊落险峰行 ", nil, true) then
    JQ_WJG_mis_200002()
    bHave = true
  elseif string.find(strTemp, " 微笑之旅 ", nil, true) then
    JQ_WJG_mis_200003()
    bHave = true
  elseif string.find(strTemp, " 恶贯满盈 ", nil, true) then
    JQ_WJG_mis_200004()
    bHave = true
  elseif string.find(strTemp, " 相会在万劫谷 ", nil, true) then
    JQ_WJG_mis_200005()
    bHave = true
  elseif string.find(strTemp, " 大战万劫谷 ", nil, true) then
    JQ_WJG_mis_200006()
    bHave = true
  elseif string.find(strTemp, " 大进军 ", nil, true) then
    JQ_WJG_mis_200007()
    bHave = true
  elseif string.find(strTemp, " 虎啸龙吟 ", nil, true) then
    JQ_WJG_mis_200008()
    bHave = true
  elseif string.find(strTemp, " #{JQLJ_130819_01} ", nil, true) then
    JQ_WJG_mis_200009()
    bHave = true
  end
  return bHave
end

function JQ_WJG_IsInProcess(strProcess)
  if "#{Juqing_Can_001}" == strProcess then
    JQ_WJG_mis_200001()
    return JQ_WJG_mis_200001
  elseif "#{Juqing_Can_002}" == strProcess then
    JQ_WJG_mis_200002()
    return JQ_WJG_mis_200002
  elseif "#{Juqing_Can_003}" == strProcess then
    JQ_WJG_mis_200003()
    return JQ_WJG_mis_200003
  elseif "#{Juqing_Can_004}" == strProcess then
    JQ_WJG_mis_200004()
    return JQ_WJG_mis_200004
  elseif "#{Juqing_Can_005}" == strProcess then
    JQ_WJG_mis_200005()
    return JQ_WJG_mis_200005
  elseif "#{Juqing_Can_006}" == strProcess then
    JQ_WJG_mis_200006()
    return JQ_WJG_mis_200006
  elseif "#{Juqing_Can_007}" == strProcess then
    JQ_WJG_mis_200007()
    return JQ_WJG_mis_200007
  elseif "#{Juqing_Can_008}" == strProcess then
    JQ_WJG_mis_200008()
    return JQ_WJG_mis_200008
  end
  return nil
end
