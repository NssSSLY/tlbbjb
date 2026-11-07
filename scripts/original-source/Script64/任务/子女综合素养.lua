-- 反编译自 dfz64.dll 内嵌字节码 00259e6e（unluac 2025-12-23；仅供分析）
local m_script_name = "子女综合素养"
ScriptOnStart(m_script_name, true, false)
CDG.attack = true
local m_param = {}
m_param.missionName = "子女综合素养"
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
local m_npc = {
  {
    name = "木子姐姐",
    x = 151,
    y = 187,
    sceneID = LUOYANG_ID
  }
}

local function OnMission_890511(aMissinoInfo)
  local npc = {
    name = "蔡丙臣",
    x = 220,
    y = 236,
    sceneID = LUOYANG_ID
  }
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  Sleep(500)
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item(aMissinoInfo.missionName)
  QuestFrameOptionClicked_Item("#{SXPY_130826_9}", 1, 800)
  for n = 1, 5 do
    for i = 1, 4 do
      m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
      if 0 ~= m_param.param[0] then
        break
      end
      QuestFrameOptionClicked_ScriptID_Extra(890511, i * 111, 600)
    end
  end
end

local function OnMission_890512()
  local level = m_param.param[2]
  local pos = m_param.param[3]
  local xInfant_DrawPos = {
    [1] = {
      [1] = {
        sceneID = LUOYANG_ID,
        name = "洛阳",
        x = 153,
        y = 158
      },
      [2] = {
        sceneID = LUOYANG_ID,
        name = "洛阳",
        x = 295,
        y = 260
      },
      [3] = {
        sceneID = LUOYANG_ID,
        name = "洛阳",
        x = 226,
        y = 419
      },
      [4] = {
        sceneID = 1,
        name = "苏州",
        x = 367,
        y = 171
      },
      [5] = {
        sceneID = 1,
        name = "苏州",
        x = 278,
        y = 326
      },
      [6] = {
        sceneID = 1,
        name = "苏州",
        x = 181,
        y = 355
      }
    },
    [2] = {
      [1] = {
        sceneID = 2,
        name = "大理",
        x = 70,
        y = 49
      },
      [2] = {
        sceneID = 2,
        name = "大理",
        x = 293,
        y = 46
      },
      [3] = {
        sceneID = 2,
        name = "大理",
        x = 69,
        y = 235
      },
      [4] = {
        sceneID = 18,
        name = "雁南",
        x = 156,
        y = 277
      },
      [5] = {
        sceneID = 18,
        name = "雁南",
        x = 250,
        y = 82
      },
      [6] = {
        sceneID = 18,
        name = "雁南",
        x = 138,
        y = 242
      }
    },
    [3] = {
      [1] = {
        sceneID = 4,
        name = "太湖",
        x = 168,
        y = 189
      },
      [2] = {
        sceneID = 4,
        name = "太湖",
        x = 62,
        y = 74
      },
      [3] = {
        sceneID = 4,
        name = "太湖",
        x = 100,
        y = 175
      },
      [4] = {
        sceneID = 30,
        name = "西湖",
        x = 124,
        y = 50
      },
      [5] = {
        sceneID = 30,
        name = "西湖",
        x = 246,
        y = 193
      },
      [6] = {
        sceneID = 30,
        name = "西湖",
        x = 154,
        y = 132
      }
    }
  }
  if xInfant_DrawPos[level] and xInfant_DrawPos[level][pos] then
    local run = xInfant_DrawPos[level][pos]
    GoToScene(run.x, run.y, run.sceneID, 2)
    Dismount()
    local tItem = Bag:FindItemInfo("文房四宝", nil, nil, Bag:EnumRenWuItem())
    if #tItem > 0 then
      Bag:ItemBtnClicked(tItem[1].index)
      Sleep(500)
      PlayerStateTimeOut(5, 5)
    end
    Sleep(200)
    GetLuaValue("setmetatable(_G, {__index = InfantDraw_Env});this:Hide()")
  else
    DebugStr(m_script_name .. ":书 任务参数坐标有误", 2)
  end
end

local function OnMission_890513()
  local MannerSkill1 = {
    {name = "称赞", id = 2947},
    {name = "点头", id = 2948},
    {name = "摇头", id = 2949}
  }
  local MannerSkill2 = {
    {name = "鞠躬", id = -1},
    {name = "鼓掌", id = -1},
    {name = "抱拳", id = -1},
    {name = "招手", id = -1}
  }
  local MannerSkill3 = {
    {name = "奉茶", id = -1},
    {name = "作揖", id = -1},
    {name = "拜礼", id = -1},
    {name = "拱手", id = -1},
    {name = "执手", id = -1}
  }
  local xMannerNPCTable = {
    [1] = {
      name = "全小颜",
      x = 118,
      y = 138,
      sceneID = LUOYANG_ID
    },
    [2] = {
      name = "曹小明",
      x = 118,
      y = 132,
      sceneID = LUOYANG_ID
    },
    [3] = {
      name = "陆小祺",
      x = 127,
      y = 132,
      sceneID = LUOYANG_ID
    }
  }
  local level = m_param.param[2]
  if -1 == Player:GetBuff("礼仪动作") then
    local npc = xMannerNPCTable[level]
    if npc then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Dismount()
      QuestFrameOptionClicked_Item("#{SXPY_130826_12}", 1, 600)
      CloseWindow("Quest")
    else
      PushColorMsg(m_script_name .. ":礼仪npc获取失败")
    end
  elseif 1 == level then
    for i = 1, #MannerSkill1 do
      Skill:UseSKillRefresh(MannerSkill1[i].name, -1)
      Sleep(1000)
    end
  elseif 2 == level then
    for i = 1, #MannerSkill2 do
      Skill:UseSKillRefresh(MannerSkill2[i].name, -1)
      Sleep(1000)
    end
  elseif 3 == level then
    for i = 1, #MannerSkill3 do
      Skill:UseSKillRefresh(MannerSkill3[i].name, -1)
      Sleep(1000)
    end
  end
end

local function OnMission_890514(aMissinoInfo)
  local npc = {
    name = "张伯智",
    x = 162,
    y = 266,
    sceneID = LUOYANG_ID
  }
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  Sleep(500)
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item(aMissinoInfo.missionName)
  QuestFrameOptionClicked_Item("#{SXPY_130826_15}", 1, 800)
  for n = 1, 5 do
    for i = 1, 4 do
      m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
      if 0 ~= m_param.param[0] then
        break
      end
      QuestFrameOptionClicked_ScriptID_Extra(890514, i * 111, 600)
    end
  end
end

local function OnMission_890515(aMissinoInfo)
  while true do
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item(aMissinoInfo.missionName)
    m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
    if 0 ~= m_param.param[0] then
      break
    end
    GoToScene(176, 150, LUOYANG_ID, 1)
    Dismount()
    local tObj = Enum2XByName("靶子", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    for i = 1, #tObj do
      local tmp = tObj[i]
      if Target:FindBuff(tmp, "射击目标") then
        Target:Select(tmp.id, 500)
        local tItem = Bag:FindItemInfo("弓箭", nil, nil, Bag:EnumRenWuItem())
        if #tItem > 0 then
          Bag:ItemBtnClicked(tItem[1].index)
          Sleep(1000)
        end
      end
    end
    Sleep(300)
    DebugStr(m_script_name .. "：射箭")
  end
end

function _SMain(...)
  local mission = {
    {
      name = "学习对诗",
      itemName = "#{SXPY_130826_3}",
      missionName = "#{SXPY_130826_32}"
    },
    {
      name = "学习作画",
      itemName = "#{SXPY_130826_4}",
      missionName = "#{SXPY_130826_78}"
    },
    {
      name = "学习礼仪",
      itemName = "#{SXPY_130826_5}",
      missionName = "#{SXPY_130826_108}"
    },
    {
      name = "切磋音律",
      itemName = "#{SXPY_130826_6}",
      missionName = "#{SXPY_130826_144}"
    },
    {
      name = "学习射箭",
      itemName = "#{SXPY_130826_7}",
      missionName = "#{SXPY_130826_188}"
    }
  }
  while true do
    local infantIndex = 0
    local maxAttr = GetLuaValue(fmt("return Infant:GetInfantMaxAttr(%d);", infantIndex), "n")
    if maxAttr > 0 then
      local info = {}
      for i = 1, 5 do
        local attr = GetLuaValue(fmt("return Infant:GetInfantAttr(0, %d)", i - 1), "n")
        table.insert(info, {index = i, value = attr})
      end
      local uninfo = {}
      for i = 1, #info do
        local tmp = info[i]
        if maxAttr > tmp.value then
          table.insert(uninfo, tmp)
        end
      end
      if 0 == #uninfo then
        break
      end
      BubbleSort(uninfo, "value")
      local misIndex = uninfo[1].index
      m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item(mission[misIndex].missionName)
      if -1 ~= m_param.misIndex then
        for i = 0, 7 do
          m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
        end
        if 1 == m_param.param[0] then
          local npc = m_npc[1]
          GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
          QuestFrameOptionClicked_Item("#{SXPY_130826_1}", 1, 600)
          QuestFrameOptionClicked_Item(mission[misIndex].itemName, 1, 600)
          QuestFrameNextClicked(600)
          QuestFrameMissionComplete(nil, 600)
        else
          PushDebugMessage(mission[misIndex].name .. ":任务" .. misIndex)
          if 1 == misIndex then
            OnMission_890511(mission[misIndex])
          elseif 2 == misIndex then
            OnMission_890512()
          elseif 3 == misIndex then
            OnMission_890513()
          elseif 4 == misIndex then
            OnMission_890514(mission[misIndex])
          elseif 5 == misIndex then
            OnMission_890515(mission[misIndex])
          end
        end
      else
        PushDebugMessage(m_script_name .. ":接取任务 " .. mission[misIndex].name)
        local npc = m_npc[1]
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        QuestFrameOptionClicked_Item("#{SXPY_130826_1}", 1, 600)
        QuestFrameOptionClicked_Item(mission[misIndex].itemName, 1, 600)
        QuestFrameAcceptClicked(600)
      end
    else
      PushColorMsg(m_script_name .. ":子女31级可执行此任务！")
      GetLuaValue("setmetatable(_G, {__index = SelfEquip_Env});SelfEquip_Infant_Switch()")
      break
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
