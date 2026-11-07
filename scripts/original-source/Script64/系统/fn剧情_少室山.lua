-- 反编译自 dfz64.dll 内嵌字节码 004e0f25（unluac 2025-12-23；仅供分析）
local m_data = {
  sceneName = "少室山（剧情）",
  sceneID_hei = 565,
  sceneID_bai = -1
}

function JQ_callback_run_sss()
  if GetCurrentSceneName() ~= m_data.sceneName then
    return false
  end
  return true
end

function JQ_runto_scene_sss()
  if GetCurrentSceneName() ~= m_data.sceneName then
    local npc2 = {
      x = 70,
      y = 58,
      sceneID = 2,
      name = "朱丹臣"
    }
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(600)
    QuestFrameOptionClicked_Item("#{CJG_101231_68}", 1)
    Sleep(600)
    return false
  else
    return true
  end
end

function JQ_runto_pos_sss_out()
  if GetCurrentSceneName() == m_data.sceneName then
    MoveToNPC("知客僧", 131, 221, -1, nil, nil, nil, JQ_callback_run_sss)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{SJZ_100129_120}", 1)
    Sleep(600)
    MessageBox_Self_OK_Clicked()
    return false
  else
    return true
  end
end

function JQ_mis_889333()
  local npc = {
    x = 114,
    y = 91,
    sceneID = 10,
    name = "吴长风"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "#{CJG_101231_121}"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc2, strMission)
  else
    JQ_mission_complete(npc, strMission)
  end
end

function JQ_mis_889318()
  local npc = {
    x = 114,
    y = 91,
    sceneID = 10,
    name = "吴长风"
  }
  local npc2 = {
    x = 160,
    y = 158,
    sceneID = 2,
    name = "赵天师"
  }
  local strMission = "#{CJG_101231_122}"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc, strMission)
  elseif 1 == GetMissionComplete(nIndex) then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(500)
    Dismount()
    Sleep(300)
    mission_complete_accept(strMission, true, true, true)
  else
    local nTick = GetTickCount()
    
    local function call_back()
      DebugStr(strMission .. ":已用时间%d秒！", 2, math.floor((GetTickCount() - nTick) / 1000))
      local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
      if 1 == nComplete then
        return true
      end
      if -1 == nIndex then
        PushDebugMessage(strMission .. ":任务列表无此任务！")
        return true
      end
      return false
    end
    
    BeginAttack({
      {x = 57, y = 73}
    }, "玉溪", " 剧毒狼蛛 ", call_back, JQ_callback_run, {pickup = false})
  end
end

function JQ_mis_889319()
  local npc = {
    x = 114,
    y = 91,
    sceneID = 10,
    name = "吴长风"
  }
  local strMission = "#{CJG_101231_123}"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(500)
    Dismount()
    Sleep(300)
    mission_complete_accept(strMission, false, false, true)
  elseif 1 == GetMissionComplete(nIndex) then
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, false, nil, JQ_callback_run)
    Sleep(500)
    mission_complete_accept(strMission, true, true, true)
  elseif -1 ~= Player:GetBuff("探听隐秘") then
    MoveTo(155, 135, 10, nil, false, nil, JQ_callback_run)
  else
    QuestFrameMissionAbnegate(idScript)
  end
end

function JQ_mis_889320()
  local npc = {
    x = 114,
    y = 91,
    sceneID = 10,
    name = "吴长风"
  }
  local npc2 = {
    x = 71,
    y = 18,
    sceneID = 2,
    name = "段正淳"
  }
  local npc3 = {
    x = 70,
    y = 58,
    sceneID = 2,
    name = "朱丹臣"
  }
  local strMission = "#{CJG_101231_124}"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    if JQ_runto_pos_sss_out() then
      JQ_mission_accept(npc, strMission)
    end
  elseif 1 == GetMissionComplete(nIndex) then
    MoveToNPC(npc3.name, npc3.x, npc3.y, npc3.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(500)
    mission_complete_accept(strMission, true, true, true)
  else
    MoveToNPC(npc2.name, npc2.x, npc2.y, npc2.sceneID, nil, nil, nil, JQ_callback_run)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{CJG_101231_373}", 1)
  end
end

function JQ_mis_sss_fuben_jmz()
  local strMission = "#{CJG_101231_126}"
  while GetSceneID() == 565 do
    local debugnote = ""
    local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
    if -1 == nIndex or 1 == nComplete then
      break
    end
    local tObj = Enum2XByName("鸠摩智", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      local tmp = tObj[1]
      local nMsgTime, _, nMsgTick = IsInDebugMsg("#{CJG_101231_21}")
      if GetTickCount() - nMsgTick < 5500 then
        tmp.id = -1
        if GetDist(tmp.x, tmp.y, 116, 175) > GetDist(tmp.x, tmp.y, 128, 165) then
          RunTo(116, 175, 0, 500)
        else
          RunTo(128, 165, 0, 500)
        end
      end
      if 9 ~= Player:GetState() then
        FubenAttack(tmp.id, true, true)
      else
        debugnote = "角色死亡"
      end
    elseif RunTo(129, 171, 3, 500) == false then
      debugnote = "未找到boss"
    end
    Sleep(200)
    DebugStr("偷龙转凤 " .. debugnote)
  end
end

function JQ_mis_sss_fuben_dcq_zjx_mrf()
  local strMission = "#{CJG_101231_128}"
  while GetSceneID() == 565 do
    local debugnote = ""
    local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
    if -1 == nIndex or 1 == nComplete then
      break
    end
    local tObj = Enum2XByName("丁春秋", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if 0 == #tObj then
      tObj = Enum2XByName("慕容复", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
    end
    if 0 == #tObj then
      tObj = Enum2XByName("庄聚贤", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
    end
    if #tObj > 0 then
      if "丁春秋" == tObj[1].name and -1 == Player:GetBuff("增加毒抗") then
        local pos = {
          x = 124,
          y = 127,
          name = "虚竹",
          option = "#{CJG_101231_66}"
        }
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        QuestFrameOptionClicked_Item(pos.option, 1)
      elseif "庄聚贤" == tObj[1].name and -1 == Player:GetBuff("增加内外功") then
        local pos = {
          x = 130,
          y = 127,
          name = "萧峰",
          option = "#{CJG_101231_65}"
        }
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        QuestFrameOptionClicked_Item(pos.option, 1)
      elseif "慕容复" == tObj[1].name and -1 == Player:GetBuff("增加冰火玄毒属性攻击") then
        local pos = {
          x = 136,
          y = 129,
          name = "段誉",
          option = "#{CJG_101231_67}"
        }
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        QuestFrameOptionClicked_Item(pos.option, 1)
      end
    end
    if #tObj > 0 then
      local tmp = tObj[1]
      if 9 ~= Player:GetState() then
        FubenAttack(tmp.id, true, true)
      else
        debugnote = "角色死亡"
      end
    else
      debugnote = "未找到boss"
      if RunTo(130, 127, 3, 500) == false then
      end
    end
    Sleep(200)
    DebugStr("独龙战群英 " .. debugnote)
  end
end

function JQ_mis_sss_fuben_xys_mrb()
  local strMission = "#{CJG_101231_130}"
  while GetSceneID() == 565 do
    local debugnote = ""
    local nComplete, nIndex = GetMissionVariableByName_Item(strMission, 0)
    if -1 == nIndex or 1 == nComplete then
      break
    end
    local tObj = Enum2XByName("慕容博", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if 0 == #tObj then
      tObj = Enum2XByName("萧远山", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
    end
    if #tObj > 0 then
      local tmp = tObj[1]
      if 9 ~= Player:GetState() then
        FubenAttack(tmp.id, true, true)
      else
        debugnote = "角色死亡"
      end
    else
      debugnote = "未找到boss"
      if RunTo(123, 37, 3, 500) == false then
      end
    end
    Sleep(200)
    DebugStr("佛法无边 " .. debugnote)
  end
end

function JQ_mis_sss_fuben()
  CDG.attack = true
  local pos_npc = {
    {
      x = 128,
      y = 221,
      name = "虚竹"
    },
    {
      x = 130,
      y = 180,
      name = "虚竹"
    },
    {
      x = 124,
      y = 129,
      name = "虚竹"
    }
  }
  local pos_xf = {
    {
      x = 130,
      y = 130,
      name = "萧峰"
    },
    {
      x = 119,
      y = 44,
      name = "萧峰"
    }
  }
  local pos_sdss = {
    {
      x = 123,
      y = 37,
      name = "扫地神僧"
    }
  }
  while GetSceneID() == 565 do
    local debugnote = ""
    local strMission = "#{CJG_101231_126}"
    local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
    if -1 ~= nIndex then
      local nComplete, _ = GetMissionVariableByName_Item(strMission, 0)
      if 1 == nComplete then
        local pos = pos_npc[2]
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        mission_complete_accept(strMission, true, true, true)
      else
        JQ_mis_sss_fuben_jmz()
      end
    end
    if -1 == nIndex then
      strMission = "#{CJG_101231_340}"
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 ~= nIndex then
        local pos = pos_npc[3]
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        mission_complete_accept(strMission, true, true, true)
      end
    end
    if -1 == nIndex then
      strMission = "#{CJG_101231_127}"
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 ~= nIndex then
        local nComplete, _ = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          local pos = pos_xf[1]
          MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
          mission_complete_accept(strMission, true, true, true)
          MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
          mission_complete_accept("#{CJG_101231_128}", false, false, true)
        else
          MoveToNPC("燕云十八骑都尉", 127, 137, -1, nil, nil, nil, JQ_callback_run_sss)
          QuestFrameOptionClicked_Item("#{CJG_101231_149}", 1)
        end
      end
    end
    if -1 == nIndex then
      strMission = "#{CJG_101231_128}"
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 ~= nIndex then
        local nComplete, _ = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          local pos = pos_xf[1]
          MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
          mission_complete_accept(strMission, true, true, true)
        else
          JQ_mis_sss_fuben_dcq_zjx_mrf()
        end
      end
    end
    if -1 == nIndex then
      strMission = "#{CJG_101231_129}"
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 ~= nIndex then
        local pos = pos_xf[2]
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        mission_complete_accept(strMission, true, true, true)
      end
    end
    if -1 == nIndex then
      strMission = "#{CJG_101231_130}"
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 ~= nIndex then
        local nComplete, _ = GetMissionVariableByName_Item(strMission, 0)
        if 1 == nComplete then
          local pos = pos_sdss[1]
          MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
          mission_complete_accept(strMission, true, true, true)
        else
          JQ_mis_sss_fuben_xys_mrb()
        end
      end
    end
    if -1 == nIndex then
      strMission = "#{CJG_101231_125}"
      local param = {}
      nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
      if -1 == nIndex then
        break
      end
      for i = 0, 7 do
        param[i] = GetMissionVariable(nIndex, i)
      end
      if 1 ~= param[0] then
        local strTalk = ""
        local strTalk2 = ""
        local pos = {}
        local pos2 = {}
        local npc_name = ""
        if 0 == param[1] then
          strTalk = "#{CJG_101231_391}"
          strTalk2 = "#{CJG_101231_126}"
          pos = pos_npc[1]
          pos2 = pos_npc[2]
          npc_name = "虚竹"
        elseif 0 == param[2] and 0 == param[3] and 0 == param[4] then
          if 1 == param[7] then
            strTalk = "#{CJG_101231_340}"
            strTalk2 = ""
            pos = pos_npc[2]
            pos2 = pos_npc[3]
            npc_name = "虚竹"
          elseif 2 == param[7] then
            strTalk = "#{CJG_101231_127}"
            strTalk2 = "#{CJG_101231_127}"
            pos = pos_npc[2]
            pos2 = pos_npc[3]
            npc_name = "虚竹"
          elseif 3 == param[7] then
            strTalk = "#{CJG_101231_128}"
            strTalk2 = ""
            pos = pos_xf[1]
            pos2 = pos_xf[1]
            npc_name = "萧峰"
          else
            debugnote = "没有获取到正确的参数 - 1"
            strTalk = "#{CJG_101231_128}"
            strTalk2 = ""
            pos = pos_npc[2]
            pos2 = pos_npc[3]
            npc_name = "虚竹"
          end
        elseif 1 == param[2] and 1 == param[3] and 1 == param[4] then
          if 3 == param[7] or 4 == param[7] then
            strTalk = "#{CJG_101231_129}"
            strTalk2 = ""
            pos = pos_xf[1]
            pos2 = pos_xf[1]
            npc_name = "萧峰"
          elseif 5 == param[7] then
            strTalk = "#{CJG_101231_130}"
            strTalk2 = ""
            pos = pos_sdss[1]
            pos2 = pos_sdss[1]
            npc_name = "扫地神僧"
          else
            debugnote = "没有获取到正确的参数 - 2"
            strTalk = "#{CJG_101231_130}"
            strTalk2 = ""
            pos = pos_sdss[1]
            pos2 = pos_sdss[1]
            npc_name = "扫地神僧"
          end
        else
          debugnote = "没有获取到正确的参数 - 3"
          strTalk = "#{CJG_101231_128}"
          strTalk2 = ""
          pos = pos_xf[1]
          pos2 = pos_xf[1]
          npc_name = "萧峰"
        end
        local tObj = Enum2XByName(npc_name, {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          RunTo(tmp.x, tmp.y, 0, 500)
          TalkNpc(tmp.name)
          Sleep(600)
          QuestFrameOptionClicked_Item("#{CJG_101231_391}", 1, 500)
          QuestFrameOptionClicked_Item("#{CJG_101231_126}", 1, 500)
          QuestFrameOptionClicked_Item("#{CJG_101231_340}", 1, 500)
          QuestFrameOptionClicked_Item("#{CJG_101231_127}", 1, 500)
          QuestFrameOptionClicked_Item("#{CJG_101231_128}", 1, 500)
          QuestFrameOptionClicked_Item("#{CJG_101231_129}", 1, 500)
          QuestFrameOptionClicked_Item("#{CJG_101231_130}", 1, 500)
          Sleep(500)
          QuestFrameAcceptClicked()
        else
          PushDebugMessage("没有找到任务NPC")
          MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
          Sleep(600)
          QuestFrameOptionClicked_Item(strTalk, 1)
          Sleep(600)
          QuestFrameAcceptClicked()
          Sleep(600)
          MoveToNPC(pos2.name, pos2.x, pos2.y, -1, nil, nil, nil, JQ_callback_run_sss)
          if "" ~= strTalk2 then
            Sleep(600)
            QuestFrameOptionClicked_Item(strTalk2, 1)
            Sleep(500)
            QuestFrameAcceptClicked()
          end
        end
      else
        break
      end
    end
    Sleep(400)
    DebugStr("少室山剧情副本 " .. debugnote)
  end
end

function JQ_mis_889321()
  local npc3 = {
    x = 70,
    y = 58,
    sceneID = 2,
    name = "朱丹臣"
  }
  local strMission = "#{CJG_101231_125}"
  local nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
  if -1 == nIndex then
    JQ_mission_accept(npc3, strMission)
  elseif 1 == GetMissionComplete(nIndex) then
    local pos = {
      x = 123,
      y = 37,
      name = "扫地神僧"
    }
    MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
    mission_complete_accept("#{CJG_101231_130}", true, true, true)
    MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
    mission_complete_accept(strMission, true, true, true)
    nIndex, idMission, idScript = GetPlayerMission_Item(strMission)
    if -1 == nIndex then
      while GetCurrentSceneName() == m_data.sceneName do
        MoveToNPC(pos.name, pos.x, pos.y, -1, nil, nil, nil, JQ_callback_run_sss)
        QuestFrameOptionClicked_Item("#{SJZ_100129_120}", 1)
        Sleep(1000)
        DebugStr("离开副本。。。")
      end
    end
  elseif JQ_runto_scene_sss() then
    JQ_mis_sss_fuben()
  end
end

function JQ_SSS_DoMission()
  local bHave = false
  local strTemp = GetPlayerMissionAllName()
  if string.find(strTemp, " #{CJG_101231_121} ", nil, true) then
    JQ_mis_889333()
    bHave = true
  elseif string.find(strTemp, " #{CJG_101231_122} ", nil, true) then
    JQ_mis_889318()
    bHave = true
  elseif string.find(strTemp, " #{CJG_101231_123} ", nil, true) then
    JQ_mis_889319()
    bHave = true
  elseif string.find(strTemp, " #{CJG_101231_124} ", nil, true) then
    JQ_mis_889320()
    bHave = true
  elseif string.find(strTemp, " #{CJG_101231_125} ", nil, true) then
    JQ_mis_889321()
    bHave = true
  end
  return bHave
end

function JQ_SSS_IsInProcess(strProcess)
  if "#{CJG_101231_115}" == strProcess then
    JQ_mis_889333()
    return JQ_mis_889333
  elseif "#{CJG_101231_116}" == strProcess then
    JQ_mis_889318()
    return JQ_mis_889318
  elseif "#{CJG_101231_117}" == strProcess then
    JQ_mis_889319()
    return JQ_mis_889319
  elseif "#{CJG_101231_118}" == strProcess then
    JQ_mis_889320()
    return JQ_mis_889320
  elseif "#{CJG_101231_119}" == strProcess then
    JQ_mis_889321()
    return JQ_mis_889321
  end
  return nil
end
