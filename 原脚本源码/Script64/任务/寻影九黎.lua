-- 反编译自 dfz64.dll 内嵌字节码 0025d97e（unluac 2025-12-23；仅供分析）
local m_script_name = "寻影九黎"
ScriptOnStart(m_script_name, true, false)
local m_param = {}
m_param.auto_team = false
m_param.knMode = ReadConfigBool("ZH", "xzk122")
m_param.zhanshen = ReadConfigBool("ZH", "xzk115")

local function XYJL_GetParam(aMisIndex, aScriptID)
  local MonsterInfo_easy = {
    [1] = {
      [1] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [2] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [3] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [4] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [5] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [6] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [7] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [8] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [9] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [10] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      }
    },
    [2] = {
      [1] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [2] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [3] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      },
      [4] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [5] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      },
      [6] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [7] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      },
      [8] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [9] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [10] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      }
    },
    [3] = {
      [1] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [2] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [3] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      },
      [4] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [5] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [6] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      },
      [7] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [8] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [9] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [10] = {
        monstertype = 1,
        monsterid = 51172,
        num = 10,
        scene = 15344,
        res = 859,
        posx = 47,
        posz = 47
      }
    },
    [4] = {
      [1] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [2] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [3] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [4] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [5] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [6] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [7] = {
        monstertype = 1,
        monsterid = 51171,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 203,
        posz = 212
      },
      [8] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      },
      [9] = {
        monstertype = 1,
        monsterid = 51169,
        num = 10,
        scene = 15345,
        res = 860,
        posx = 72,
        posz = 43
      },
      [10] = {
        monstertype = 1,
        monsterid = 51170,
        num = 10,
        scene = 15343,
        res = 858,
        posx = 77,
        posz = 124
      }
    }
  }
  local MonsterInfo_diff = {
    [1] = {
      [1] = {
        monstertype = 1,
        monsterid = 51173,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 60,
        posz = 51
      },
      [2] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [3] = {
        monstertype = 1,
        monsterid = 51179,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 208,
        posz = 168
      },
      [4] = {
        monstertype = 1,
        monsterid = 51175,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 160,
        posz = 96
      },
      [5] = {
        monstertype = 2,
        monsterid = 51168,
        num = 1,
        scene = 15340,
        res = 855,
        pos = {
          {x = 187, y = 139}
        }
      },
      [6] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      },
      [7] = {
        monstertype = 1,
        monsterid = 51175,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 160,
        posz = 96
      },
      [8] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [9] = {
        monstertype = 1,
        monsterid = 51173,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 60,
        posz = 51
      },
      [10] = {
        monstertype = 2,
        monsterid = 51167,
        num = 1,
        scene = 15341,
        res = 856,
        pos = {
          {x = 107, y = 31}
        }
      }
    },
    [2] = {
      [1] = {
        monstertype = 1,
        monsterid = 51177,
        num = 10,
        scene = 15342,
        res = 857,
        posx = 122,
        posz = 193
      },
      [2] = {
        monstertype = 1,
        monsterid = 51176,
        num = 10,
        scene = 15342,
        res = 857,
        posx = 212,
        posz = 53
      },
      [3] = {
        monstertype = 1,
        monsterid = 51177,
        num = 10,
        scene = 15342,
        res = 857,
        posx = 122,
        posz = 193
      },
      [4] = {
        monstertype = 2,
        monsterid = 51166,
        num = 1,
        scene = 15342,
        res = 857,
        pos = {
          {x = 103, y = 84}
        }
      },
      [5] = {
        monstertype = 1,
        monsterid = 51177,
        num = 10,
        scene = 15342,
        res = 857,
        posx = 122,
        posz = 193
      },
      [6] = {
        monstertype = 1,
        monsterid = 51176,
        num = 10,
        scene = 15342,
        res = 857,
        posx = 212,
        posz = 53
      },
      [7] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [8] = {
        monstertype = 1,
        monsterid = 51173,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 60,
        posz = 51
      },
      [9] = {
        monstertype = 2,
        monsterid = 51167,
        num = 1,
        scene = 15341,
        res = 856,
        pos = {
          {x = 107, y = 31}
        }
      },
      [10] = {
        monstertype = 1,
        monsterid = 51179,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 208,
        posz = 168
      }
    },
    [3] = {
      [1] = {
        monstertype = 1,
        monsterid = 51173,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 60,
        posz = 51
      },
      [2] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [3] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      },
      [4] = {
        monstertype = 1,
        monsterid = 51175,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 160,
        posz = 96
      },
      [5] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      },
      [6] = {
        monstertype = 2,
        monsterid = 51168,
        num = 1,
        scene = 15340,
        res = 855,
        pos = {
          {x = 187, y = 139}
        }
      },
      [7] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      },
      [8] = {
        monstertype = 2,
        monsterid = 51167,
        num = 1,
        scene = 15341,
        res = 856,
        pos = {
          {x = 107, y = 31}
        }
      },
      [9] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [10] = {
        monstertype = 1,
        monsterid = 51173,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 60,
        posz = 51
      }
    },
    [4] = {
      [1] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [2] = {
        monstertype = 1,
        monsterid = 51179,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 208,
        posz = 168
      },
      [3] = {
        monstertype = 2,
        monsterid = 51167,
        num = 1,
        scene = 15341,
        res = 856,
        pos = {
          {x = 107, y = 31}
        }
      },
      [4] = {
        monstertype = 1,
        monsterid = 51173,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 60,
        posz = 51
      },
      [5] = {
        monstertype = 1,
        monsterid = 51174,
        num = 10,
        scene = 15341,
        res = 856,
        posx = 188,
        posz = 83
      },
      [6] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      },
      [7] = {
        monstertype = 2,
        monsterid = 51168,
        num = 1,
        scene = 15340,
        res = 855,
        pos = {
          {x = 187, y = 139}
        }
      },
      [8] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      },
      [9] = {
        monstertype = 1,
        monsterid = 51175,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 160,
        posz = 96
      },
      [10] = {
        monstertype = 1,
        monsterid = 51178,
        num = 10,
        scene = 15340,
        res = 855,
        posx = 129,
        posz = 150
      }
    }
  }
  local num = GetMissionVariable(aMisIndex, 1)
  local index = GetMissionVariable(aMisIndex, 2)
  local subindex = GetMissionVariable(aMisIndex, 3)
  local infotab
  if 998267 == aScriptID or 998346 == aScriptID then
    if nil == MonsterInfo_easy[index] or nil == MonsterInfo_easy[index][subindex] then
      PushColorMsg("寻影九黎简单：参数错误" .. aMisIndex .. " " .. index .. " " .. subindex)
    else
      infotab = MonsterInfo_easy[index][subindex]
    end
  elseif 998268 == aScriptID or 998347 == aScriptID then
    if nil == MonsterInfo_diff[index] or nil == MonsterInfo_diff[index][subindex] then
      PushColorMsg("寻影九黎困难：参数错误" .. aMisIndex .. " " .. index .. " " .. subindex)
    else
      infotab = MonsterInfo_diff[index][subindex]
    end
  end
  local mis
  if infotab then
    mis = {}
    mis.sceneID = infotab.res
    mis.pos = infotab.pos or {
      {
        x = infotab.posx,
        y = infotab.posz
      }
    }
  end
  return mis
end

function _SMain(...)
  local m_npc = {
    {
      x = 275,
      y = 71,
      sceneID = 850,
      name = "姜炎俊"
    }
  }
  local npc = m_npc[1]
  CDG.attack = true
  CDG.sceneName = ""
  CDG.sceneID = -1
  CDG.attackMode = "打死换怪"
  if m_param.zhanshen then
    CDG.attackMode = "站神模式"
    CDG.dxys = true
  end
  CDG.posRadius = 5
  CDG.buji = false
  CDG.targetName = "夺宝马贼头领 林家军 关家军 鲁家军 武家军"
  CDG.targetType = 2
  CDG.targetOwer = "红绿白"
  CDG.tragetSelect = true
  CDG.die.out = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  CDG.jgyc = true
  DeleteDebugMsg("#{PHRW_220905_41}")
  DeleteDebugMsg("#{PHRW_220905_42}")
  while true do
    local nIndex, idMission, idScript = GetPlayerMission_Item("#{PHRW_220905_04}")
    local nComplete = GetMissionComplete(nIndex)
    if -1 == nComplete then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(600)
      QuestFrameOptionClicked_Item("#{PHRW_220905_04}", 1, 800)
      if m_param.knMode then
        QuestFrameOptionClicked_Item("#{PHRW_220905_08}", 1, 800)
      else
        QuestFrameOptionClicked_Item("#{PHRW_220905_07}", 1, 800)
      end
      QuestFrameAcceptClicked(800)
      local strText = GetNPCEventList_Item(0)
      if string.find(strText, "#{PHRW_220905_41}", nil, true) or string.find(strText, "#{PHRW_220905_42}", nil, true) then
        PushColorMsg(m_script_name .. ":已完成！！")
        break
      end
      if IsInDebugMsg("#{PHRW_220905_41}") or IsInDebugMsg("#{PHRW_220905_42}") then
        PushColorMsg(m_script_name .. ":已完成")
        break
      end
    elseif 0 == nComplete then
      local function mis_callback(...)
        local _nIndex, _idMission, _idScript = GetPlayerMission_Item("#{PHRW_220905_04}")
        
        local nComplete = GetMissionComplete(_nIndex)
        if 0 ~= nComplete then
          if m_param.auto_team then
            Team:LeaveTeam()
          end
          return true
        end
        if m_param.auto_team then
          TeamCheckNear()
        end
        local misinfo = XYJL_GetParam(_nIndex, _idScript)
        if misinfo then
          CDG.pos = misinfo.pos
          CDG.sceneID = misinfo.sceneID
          CDG.sceneName = GetSceneNameByID(CDG.sceneID)
        else
          PushColorMsg("任务时获取参数失败")
          return true
        end
        DebugStr("寻影九黎:任务中", 2)
        return false
      end
      
      local misinfo = XYJL_GetParam(nIndex, idScript)
      if misinfo then
        CDG.pos = misinfo.pos
        CDG.sceneID = misinfo.sceneID
        CDG.sceneName = GetSceneNameByID(CDG.sceneID)
        CDG.callfun = mis_callback
        CDG:OnStart()
      end
    elseif 1 == nComplete then
      Skill:UseName("初级隐遁", 500)
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(600)
      Bag_DeleteItem()
      QuestFrameOptionClicked_Item("#{PHRW_220905_04}", 1, 700)
      QuestFrameMissionComplete(nil, 600)
    end
    DebugStr(m_script_name)
    Sleep(200)
  end
  if m_param.auto_team then
    Team:LeaveTeam()
  end
end

_SMain()
ScriptOnStop(m_script_name)
