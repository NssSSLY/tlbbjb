-- 反编译自 dfz64.dll 内嵌字节码 00287c2b（unluac 2025-12-23；仅供分析）
local m_script_name = "绝学引导"
ScriptOnStart(m_script_name)
local m_mission_npc = {
  [0] = {
    name = "灵门禅师",
    x = 97,
    y = 50,
    sceneID = 883,
    mpname = "少林",
    mis2 = {x = 96, y = 59},
    mis4 = {
      x = 134,
      y = 55,
      name = "灵源"
    }
  },
  [1] = {
    name = "拂多诞",
    x = 96,
    y = 52,
    sceneID = 887,
    mpname = "明教",
    mis2 = {x = 55, y = 93},
    mis4 = {
      x = 131,
      y = 55,
      name = "呼禄"
    }
  },
  [2] = {
    name = "庄信方",
    x = 96,
    y = 47,
    sceneID = 891,
    mpname = "丐帮",
    mis2 = {x = 139, y = 136},
    mis4 = {
      x = 131,
      y = 56,
      name = "穆天白"
    }
  },
  [3] = {
    name = "李天师",
    x = 96,
    y = 44,
    sceneID = 886,
    mpname = "武当",
    mis2 = {x = 56, y = 156},
    mis4 = {
      x = 131,
      y = 55,
      name = "九皋处士"
    }
  },
  [4] = {
    name = "孟玉清",
    x = 96,
    y = 48,
    sceneID = 890,
    mpname = "峨嵋",
    mis2 = {x = 96, y = 165},
    mis4 = {
      x = 131,
      y = 56,
      name = "孟听晓"
    }
  },
  [5] = {
    name = "黎牵机",
    x = 97,
    y = 46,
    sceneID = 885,
    mpname = "星宿",
    mis2 = {x = 96, y = 59},
    mis4 = {
      x = 127,
      y = 50,
      name = "黎枯春"
    }
  },
  [6] = {
    name = "段思廉",
    x = 96,
    y = 50,
    sceneID = 889,
    mpname = "天龙",
    mis2 = {x = 95, y = 159},
    mis4 = {
      x = 133,
      y = 54,
      name = "段寿辉"
    }
  },
  [7] = {
    name = "童缈月",
    x = 96,
    y = 47,
    sceneID = 884,
    mpname = "天山",
    mis2 = {x = 96, y = 55},
    mis4 = {
      x = 127,
      y = 54,
      name = "童恨星"
    }
  },
  [8] = {
    name = "北冥客",
    x = 95,
    y = 54,
    sceneID = 888,
    mpname = "逍遥",
    mis2 = {x = 139, y = 139},
    mis4 = {
      x = 131,
      y = 55,
      name = "忘忧君"
    }
  },
  [10] = {
    name = "慕容龙岳",
    x = 96,
    y = 46,
    sceneID = 892,
    mpname = "慕容",
    mis2 = {x = 57, y = 92},
    mis4 = {
      x = 124,
      y = 53,
      name = "慕容恒昌"
    }
  },
  [11] = {
    name = "唐岳平",
    x = 96,
    y = 38,
    sceneID = 893,
    mpname = "唐门",
    mis2 = {x = 52, y = 158},
    mis4 = {
      x = 111,
      y = 42,
      name = "唐岳戈"
    }
  },
  [12] = {
    name = "文始君",
    x = 96,
    y = 46,
    sceneID = 894,
    mpname = "鬼谷",
    mis2 = {x = 96, y = 164},
    mis4 = {
      x = 132,
      y = 56,
      name = "寒泉子"
    }
  },
  [13] = {
    name = "黄落兮",
    x = 96,
    y = 40,
    sceneID = 895,
    mpname = "桃花岛",
    mis2 = {x = 56, y = 93},
    mis4 = {
      x = 133,
      y = 54,
      name = "杨柳风"
    }
  },
  [14] = {
    name = "穆世瑜",
    x = 96,
    y = 50,
    sceneID = 896,
    mpname = "绝情谷",
    mis2 = {x = 96, y = 58},
    mis4 = {
      x = 132,
      y = 56,
      name = "志武"
    }
  },
  [15] = {
    name = "山都",
    x = 96,
    y = 50,
    sceneID = 988,
    mpname = "恶人谷",
    mis2 = {x = 96, y = 109},
    mis4 = {
      x = 130,
      y = 55,
      name = "山鸮"
    }
  }
}
local m_npc = m_mission_npc[g_self.menpai]

function JXYD_Mission1_accept()
  local npc = m_npc
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  QuestFrameOptionClicked_Item("#{ZMYD_230801_269}", 1, 1000)
  QuestFrameAcceptClicked(1000)
end

function JXYD_Mission1()
  local npc = m_npc
  while true do
    local nIndex, idMission, idScript = GetPlayerMission("初识秘境济师门")
    if -1 ~= nIndex then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      local nComplete = GetMissionVariable(nIndex, 0)
      if 1 == nComplete then
        QuestFrameOptionClicked_Item("#{ZMYD_230801_269}", 1, 1000)
        QuestFrameMissionComplete(nil, 800)
        QuestFrameAcceptClicked(1000)
      else
        QuestFrameOptionClicked_Item("#{ZMYD_230801_269}", 1, 1000)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_285}", 1, 1000)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_273}", 1, 1000)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_287}", 1, 1000)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_289}", 1, 1000)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_291}", 1, 1000)
      end
    else
      break
    end
    Sleep(500)
    DebugStr("初识秘境济师门")
  end
end

function JXYD_Mission2_accept()
  local npc = m_npc
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  QuestFrameOptionClicked_Item("#{ZMYD_230801_354}", 1, 1000)
  QuestFrameAcceptClicked(1000)
end

function JXYD_Mission2()
  local npc = m_npc
  while true do
    local nIndex, idMission, idScript = GetPlayerMission("开灵除尘秘宝现")
    if -1 ~= nIndex then
      local nComplete = GetMissionVariable(nIndex, 0)
      if 1 == nComplete then
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_354}", 1, 1000)
        QuestFrameMissionComplete(nil, 800)
        QuestFrameAcceptClicked(1000)
      else
        GoToScene(npc.mis2.x, npc.mis2.y, npc.sceneID)
        local tItem = Bag:SearchItemType("镇派秘宝")
        if #tItem > 0 then
          Dismount(800)
          local tmp = tItem[1]
          Bag:UseItemByName_click(tmp.name, 1000)
          PlayerStateTimeOut(5, 8)
        end
      end
    else
      break
    end
    Sleep(500)
    DebugStr("开灵除尘秘宝现")
  end
end

function JXYD_Mission3_accept()
  local npc = m_npc
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  QuestFrameOptionClicked_Item("#{ZMYD_230801_641}", 1, 1000)
  QuestFrameAcceptClicked(1000)
end

function JXYD_Mission3()
  local npc = m_npc
  while true do
    local tItem = Bag:SearchItemType("镇派秘宝")
    if #tItem > 0 then
      local tmp = tItem[1]
      Bag:UseItemByName_click(tmp.name, 1000)
    end
    local nIndex, idMission, idScript = GetPlayerMission("绝学问武意纵横")
    if -1 == nIndex then
      break
    end
    do
      local nComplete = GetMissionVariable(nIndex, 0)
      if 1 == nComplete then
        GoToSceneNPC(npc.mis4.name, npc.mis4.x, npc.mis4.y, npc.sceneID)
        QuestFrameOptionClicked_Item("#{ZMYD_230801_641}", 1, 1000)
        QuestFrameMissionComplete(nil, 800)
        QuestFrameAcceptClicked(1000)
      else
        for i = 1, 10 do
          local nComp = GetMissionVariable(nIndex, 0)
          if 0 ~= nComp then
            goto lbl_71
          end
          GetLuaValue(fmt([[
                                local nIdx = %d
                                local nSectId = DataPool:GetZongMenTalentNormalData(nIdx, "SectId")
                                Player:Lua_AskSectOper(0, nSectId)
                                ]], i - 1))
          Sleep(500)
        end
        goto lbl_71
        break
      end
    end
    ::lbl_71::
    Sleep(500)
    DebugStr("绝学问武意纵横")
  end
  CloseAllWindow()
end

local MissionTable = {
  {
    name = "初识秘境济师门",
    doMis = JXYD_Mission1,
    aptMis = JXYD_Mission1_accept
  },
  {
    name = "开灵除尘秘宝现",
    doMis = JXYD_Mission2,
    aptMis = JXYD_Mission2_accept
  },
  {
    name = "绝学问武意纵横",
    doMis = JXYD_Mission3,
    aptMis = JXYD_Mission3_accept
  }
}

function JXYD_DoMission()
  for i = 1, #MissionTable do
    local tmp = MissionTable[i]
    local nIndex, idMission, idScript = GetPlayerMission(tmp.name)
    if -1 ~= nIndex then
      tmp.doMis()
      return true
    end
  end
  return false
end

function JXYD_AcceptMission()
  CollectMissionOutline()
  Sleep(500)
  for i = 1, #MissionTable do
    local tmp = MissionTable[i]
    if IsMissionOutline(tmp.name) then
      tmp.aptMis()
      return true
    end
  end
  return false
end

function _SMain()
  LoadScript("mission")
  while true do
    if JXYD_DoMission() == false and false == JXYD_AcceptMission() then
      PushColorMsg("完成引导任务")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
