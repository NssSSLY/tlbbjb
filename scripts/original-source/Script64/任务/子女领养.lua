-- 反编译自 dfz64.dll 内嵌字节码 0025bf77（unluac 2025-12-23；仅供分析）
local m_script_name = "子女领养"
ScriptOnStart(m_script_name, true, false)
CDG.attack = true
local m_param = {}
m_param.missionName = "领养子女"
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
local m_npc = {
  name = "张大叔",
  x = 153,
  y = 184,
  sceneID = LUOYANG_ID
}

local function GetInfantCount()
  return GetLuaValue("return Infant:GetInfantCount();", "n")
end

local function ZNLY_Mission1()
  local mispos = {
    {
      x = 254,
      y = 118,
      sceneID = LUOYANG_ID
    },
    {
      x = 244,
      y = 433,
      sceneID = 1
    },
    {
      x = 246,
      y = 193,
      sceneID = 30
    },
    {
      x = 33,
      y = 108,
      sceneID = 2
    },
    {
      x = 154,
      y = 191,
      sceneID = 4
    }
  }
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item("#{SYZN_130820_403}")
  if -1 ~= m_param.misIndex then
    for i = 0, 7 do
      m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
    end
    if 0 == m_param.param[0] then
      local pos
      if 0 == m_param.param[1] then
        pos = mispos[1]
      elseif 0 == m_param.param[2] then
        pos = mispos[2]
      elseif 0 == m_param.param[3] then
        pos = mispos[3]
      elseif 0 == m_param.param[5] then
        pos = mispos[5]
      elseif 0 == m_param.param[4] then
        pos = mispos[4]
      end
      if pos then
        GoToScene(pos.x, pos.y, pos.sceneID)
        Dismount()
        local tItem = Bag:FindItemInfo("画卷", nil, nil, Bag:EnumRenWuItem())
        if #tItem > 0 then
          Bag:ItemBtnClicked(tItem[1].index)
          Sleep(500)
        end
        PlayerStateTimeOut(5, 5)
      else
        PushColorMsg(m_script_name .. ":任务1获取参数失败")
      end
    else
      PushDebugMessage(m_script_name .. ":任务1完成")
      GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{SYZN_130820_403}", 1, 800)
      QuestFrameMissionComplete(nil, 800)
    end
  else
    GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{SYZN_130820_403}", 1, 800)
    QuestFrameAcceptClicked(600)
  end
end

local function ZNLY_Mission2()
  local mispos = {
    {
      x = 267,
      y = 421,
      sceneID = LUOYANG_ID,
      targetName = "梅花"
    },
    {
      x = 176,
      y = 76,
      sceneID = 2,
      targetName = "玫瑰花"
    },
    {
      x = 202,
      y = 328,
      sceneID = 1,
      targetName = "荷花"
    },
    {
      x = 165,
      y = 179,
      sceneID = 4,
      targetName = "茉莉"
    },
    {
      x = 69,
      y = 113,
      sceneID = 30,
      targetName = "兰花"
    }
  }
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item("#{SYZN_130820_456}")
  if -1 ~= m_param.misIndex then
    for i = 0, 7 do
      m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
    end
    if 0 == m_param.param[0] then
      local pos
      if 0 == m_param.param[1] then
        pos = mispos[1]
      elseif 0 == m_param.param[3] then
        pos = mispos[3]
      elseif 0 == m_param.param[5] then
        pos = mispos[5]
      elseif 0 == m_param.param[4] then
        pos = mispos[4]
      elseif 0 == m_param.param[2] then
        pos = mispos[2]
      end
      if pos then
        GoToScene(pos.x, pos.y, pos.sceneID)
        Dismount()
        local tObj = Enum2XByName(pos.targetName, {
          1,
          0,
          0,
          0
        }, nil, 1, 0)
        if #tObj > 0 then
          Target:Select(tObj[1].id, 300)
        end
        local tItem = Bag:FindItemInfo("陶瓷器皿", nil, nil, Bag:EnumRenWuItem())
        if #tItem > 0 then
          Bag:ItemBtnClicked(tItem[1].index)
          Sleep(500)
        end
        PlayerStateTimeOut(5, 5)
      else
        PushColorMsg(m_script_name .. ":任务2获取参数失败")
      end
    else
      PushDebugMessage(m_script_name .. ":任务2完成")
      GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{SYZN_130820_456}", 1, 800)
      QuestFrameMissionComplete(nil, 800)
    end
  else
    GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{SYZN_130820_456}", 1, 800)
    QuestFrameAcceptClicked(600)
  end
end

local function ZNLY_Mission3()
  local mispos = {
    {
      x = 366,
      y = 228,
      sceneID = LUOYANG_ID,
      targetName = "王积薪"
    },
    {
      x = 352,
      y = 274,
      sceneID = LUOYANG_ID,
      targetName = "窦梧桐"
    },
    {
      x = 230,
      y = 350,
      sceneID = 1,
      targetName = "柳月虹"
    },
    {
      x = 355,
      y = 240,
      sceneID = 1,
      targetName = "欧治于"
    },
    {
      x = 242,
      y = 31,
      sceneID = 2,
      targetName = "扫地神僧"
    }
  }
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item("#{SYZN_130820_519}")
  if -1 ~= m_param.misIndex then
    for i = 0, 7 do
      m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
    end
    if 0 == m_param.param[0] then
      local pos
      if 0 == m_param.param[1] then
        pos = mispos[1]
      elseif 0 == m_param.param[2] then
        pos = mispos[2]
      elseif 0 == m_param.param[3] then
        pos = mispos[3]
      elseif 0 == m_param.param[4] then
        pos = mispos[4]
      elseif 0 == m_param.param[5] then
        pos = mispos[5]
      end
      if pos then
        GoToSceneNPC(pos.targetName, pos.x, pos.y, pos.sceneID)
        QuestFrameOptionClicked_Item("#{SYZN_130820_533}", 1, 800)
      else
        PushColorMsg(m_script_name .. ":任务3获取参数失败")
      end
    else
      PushDebugMessage(m_script_name .. ":任务3完成")
      GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{SYZN_130820_519}", 1, 800)
      QuestFrameMissionComplete(nil, 800)
    end
  else
    GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{SYZN_130820_519}", 1, 800)
    QuestFrameAcceptClicked(600)
  end
end

function _SMain(...)
  DeleteDebugMsg("#{SYZN_130820_449}")
  DeleteDebugMsg("#{SYZN_130820_514}")
  while true do
    if 0 == GetInfantCount() then
      if -1 ~= Player:GetBuff("初次考验") then
        ZNLY_Mission1()
      elseif -1 ~= Player:GetBuff("再次考验") then
        ZNLY_Mission2()
        if IsInDebugMsg("#{SYZN_130820_449}") then
          break
        end
      elseif -1 ~= Player:GetBuff("最终考验") then
        ZNLY_Mission3()
        if IsInDebugMsg("#{SYZN_130820_514}") then
          break
        end
      elseif -1 ~= Player:GetBuff("领养") then
        GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
        Sleep(500)
        math.randomseed(GetTickCount())
        local suiji = math.random(1, 100)
        QuestFrameOptionClicked_Item("#{SYZN_130820_25}", 1, 800)
        if suiji > 50 then
          QuestFrameOptionClicked_Item("#{SYZN_130820_565}", 1, 800)
        else
          QuestFrameOptionClicked_Item("#{SYZN_130820_566}", 1, 800)
        end
      else
        if 0 == Bag:GetItemCount("爱心玩具") and Player:GetMoney(2) < 300000 then
          Bank_GetMoney(300000)
        end
        GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
        Sleep(500)
        if 0 == Bag:GetItemCount("爱心玩具") then
          QuestFrameOptionClicked_Item("#{SYZN_130820_26}", 1, 800)
          QuestFrameOptionClicked_Item("#{SYZN_130820_17}", 1, 800)
        else
          QuestFrameOptionClicked_Item("#{SYZN_130820_21}", 1, 800)
          QuestFrameOptionClicked_Item("#{SYZN_130820_13}", 1, 800)
        end
      end
    else
      PushDebugMessage(m_script_name .. ":您已经拥有子女")
      break
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_npc = nil
