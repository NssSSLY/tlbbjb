-- 主线任务, written from the reference rules (原脚本源码/Script64/任务/主线任务.lua). The mission table below is the reference's, untouched; quest_book.lua holds the helpers.
-- Its bag clean-up and team-chat steps are not ported. docs/LONG_TASKS_HANDOFF.md names the differences.
LoadScript('quest_book')
Zhuxian={}
local SCENES={['南海']=39,['南诏']=33,['嵩山']=3,['敦煌']=8,['无量山']=6,['梅岭']=38,['洱海']=29,['玉溪']=32,['琼州']=40,['盐湖']=76,['苗疆']=34,['草原']=25,['西湖']=35,['辽西']=26,['银皑雪原']=75,['长白山']=27,['雁南']=23,['黄龙府']=28}
local function book(_ENV)
    local function ZhuXianAttack(m) m.is_check_team=nil;mission_attack_mode_1(m) end
    local function ZhuXianComplete(m) m.is_check_team=nil;mission_complete_talk_npc(m) end
local MissionTable = {
  function()
    local apt = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷"
    }
    local misName = "草原的劫匪"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 273, y = 156}
        },
        use_horse = true,
        sceneName = "草原",
        targetName = "弯刀马匪"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷"
    }
    local misName = "郡主的命令"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 78, y = 246}
        },
        use_horse = true,
        sceneName = "草原",
        targetName = "闪电马匪"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷"
    }
    local misName = "英雄的证明"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 198, y = 104}
        },
        use_horse = true,
        sceneName = "草原",
        targetName = "追风马匪"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 190,
      y = 200,
      sceneID = 20,
      name = "阮老太太"
    }
    local misName = "黑蜂刺"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 263, y = 279},
          {x = 241, y = 287}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "蒙古黑蜂的刺",
        sceneName = "草原",
        targetName = "蒙古黑蜂"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 198,
      y = 203,
      sceneID = 20,
      name = "阮实"
    }
    local misName = "脆弱的粮道"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 177, y = 250},
          {x = 199, y = 258}
        },
        use_horse = true,
        sceneName = "草原",
        targetName = "草原狼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 198,
      y = 203,
      sceneID = 20,
      name = "阮实"
    }
    local misName = "煮豆燃萁"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 51, y = 48},
          {x = 79, y = 46}
        },
        use_horse = true,
        sceneName = "草原",
        targetName = "打草谷宋兵"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷"
    }
    local comp = {
      x = 138,
      y = 53,
      sceneID = 20,
      name = "阮诚"
    }
    local misName = "白马青牛"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 275, y = 146}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "郡主的手帕",
        sceneName = "草原",
        targetName = "端木元"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 138,
      y = 53,
      sceneID = 20,
      name = "阮诚"
    }
    local comp = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷"
    }
    local mission = {
      name = "绝情剑",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷",
      next_mission = false
    }
    local misName = "勇气"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        local function _CB()
          local nIndex, idMission, idScript = GetPlayerMission(misName)
          
          local nComplete = GetMissionVariable(nIndex, 0)
          if -1 == nIndex or 0 ~= nComplete then
            return true
          end
          return false
        end
        
        BeginCaiji("白狼大王宝箱", "草原", {
          {x = 173, y = 249}
        }, _CB)
      end,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 158,
      sceneID = 20,
      name = "萧蔷"
    }
    local comp = {
      x = 138,
      y = 53,
      sceneID = 20,
      name = "阮诚"
    }
    local misName = "灵魂的呼唤"
    
    function _HuSong()
      while true do
        local nIndex, idMission, idScript = GetPlayerMission(misName)
        local nComplete = GetMissionVariable(nIndex, 0)
        if -1 == nIndex or 0 ~= nComplete then
          break
        end
        local tDD = Enum2XByName("阿菲", {
          1,
          0,
          0,
          0
        })
        if #tDD > 0 then
          local dou = tDD[1]
          if GetDist(dou.x, dou.y, 162, 160) < 3 then
            GoToSceneNPC("阿菲", dou.x, dou.y, 20)
            DialogOptionClicked(misName, 1, 600)
          else
            GoToScene(dou.x, dou.y, 20)
          end
        else
          PushDebugMessage("没有找到NPC")
          Sleep(2000)
          local tDD = Enum2XByName("阿菲", {
            1,
            0,
            0,
            0
          })
          if 0 == #tDD then
            QuestFrameMissionAbnegate(idScript)
          end
        end
        DebugStr(misName)
        Sleep(500)
      end
    end
    
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = _HuSong,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 138,
      y = 53,
      sceneID = 20,
      name = "阮诚"
    }
    local comp = {
      x = 170,
      y = 74,
      sceneID = 33,
      name = "沈万三"
    }
    local mission = {
      commit = true,
      name = "闻香下马",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 74,
      sceneID = 33,
      name = "沈万三"
    }
    local misName = "无限商机"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 40, y = 250},
          {x = 38, y = 231}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "红袍蜘蛛的丝",
        sceneName = "梅岭",
        targetName = "红袍蜘蛛"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 74,
      sceneID = 33,
      name = "沈万三"
    }
    local misName = "坎坷的商途"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 109, y = 105},
          {x = 111, y = 131}
        },
        use_horse = true,
        sceneName = "梅岭",
        targetName = "丛林野人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 195,
      y = 48,
      sceneID = 33,
      name = "太阳花"
    }
    local comp = {
      x = 162,
      y = 274,
      sceneID = 33,
      name = "甘草"
    }
    local misName = "无间道"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 195,
      y = 48,
      sceneID = 33,
      name = "太阳花"
    }
    local misName = "泾渭分明"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 234, y = 44},
          {x = 269, y = 58}
        },
        use_horse = true,
        sceneName = "梅岭",
        targetName = "山越护法"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 161,
      y = 286,
      sceneID = 33,
      name = "荆棘"
    }
    local misName = "以眼还眼"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 120, y = 71},
          {x = 100, y = 60}
        },
        use_horse = true,
        sceneName = "梅岭",
        targetName = "山越祭司"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 161,
      y = 286,
      sceneID = 33,
      name = "荆棘"
    }
    local comp = {
      x = 192,
      y = 70,
      sceneID = 33,
      name = "月季"
    }
    local misName = "为难"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 284,
      sceneID = 33,
      name = "冬刺"
    }
    local comp = {
      x = 170,
      y = 74,
      sceneID = 33,
      name = "沈万三"
    }
    local misName = "绝世好男儿"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 169,
      y = 240,
      sceneID = 33,
      name = "克里斯蒂安"
    }
    local comp = {
      x = 170,
      y = 74,
      sceneID = 33,
      name = "沈万三"
    }
    local misName = "十字军"
    
    function _HuSong()
      while true do
        local nIndex, idMission, idScript = GetPlayerMission(misName)
        local nComplete = GetMissionVariable(nIndex, 0)
        if -1 == nIndex or 0 ~= nComplete then
          break
        end
        local tDD = Enum2XByName("克里斯蒂安", {
          1,
          0,
          0,
          0
        })
        if #tDD > 0 then
          local dou = tDD[1]
          if GetDist(dou.x, dou.y, 169, 240) < 3 then
            GoToSceneNPC("克里斯蒂安", dou.x, dou.y, 33)
            DialogOptionClicked(misName, 1, 600)
          else
            GoToScene(dou.x, dou.y, 33)
          end
        else
          PushDebugMessage("没有找到NPC..")
          Sleep(2000)
          local tDD = Enum2XByName("克里斯蒂安", {
            1,
            0,
            0,
            0
          })
          if 0 == #tDD then
            QuestFrameMissionAbnegate(idScript)
          end
        end
        DebugStr(misName)
        Sleep(500)
      end
    end
    
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = _HuSong,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 192,
      y = 70,
      sceneID = 33,
      name = "月季"
    }
    local misName = "罪魁祸首"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 192, y = 70}
        },
        use_horse = true,
        sceneName = "梅岭",
        targetName = "严白虎"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 74,
      sceneID = 33,
      name = "沈万三"
    }
    local comp = {
      x = 49,
      y = 51,
      sceneID = 27,
      name = "索姆拉"
    }
    local misName = "停车枫林晚"
    local mission = {
      commit = true,
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 46,
      y = 51,
      sceneID = 27,
      name = "萝卜"
    }
    local misName = "萝卜要云母"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 118, y = 98}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "云母石零件",
        sceneName = "玉溪",
        targetName = "云母石人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 46,
      y = 51,
      sceneID = 27,
      name = "萝卜"
    }
    local misName = "萝卜要蜘蛛"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 57, y = 73}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "剧毒蜘蛛腿 剧毒蜘蛛丝",
        sceneName = "玉溪",
        targetName = "剧毒狼蛛"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 46,
      y = 51,
      sceneID = 27,
      name = "萝卜"
    }
    local misName = "萝卜要龙血"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 87, y = 258},
          {x = 66, y = 270}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "龙血石零件",
        sceneName = "玉溪",
        targetName = "龙血石人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 49,
      y = 51,
      sceneID = 27,
      name = "索姆拉"
    }
    local comp = {
      x = 280,
      y = 47,
      sceneID = 27,
      name = "阿黑"
    }
    local mission = {
      name = "绝世神兵",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 280,
      y = 47,
      sceneID = 27,
      name = "阿黑"
    }
    local misName = "女娲石人"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 115, y = 250}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "玉溪",
        targetName = "女娲石人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 280,
      y = 47,
      sceneID = 27,
      name = "阿黑"
    }
    local misName = "偃师护法"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 222, y = 213}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "玉溪",
        targetName = "偃师护法"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 280,
      y = 47,
      sceneID = 27,
      name = "阿黑"
    }
    local misName = "大偃师"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 223, y = 264},
          {x = 246, y = 273}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "玉溪",
        targetName = "大偃师"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 277,
      y = 44,
      sceneID = 27,
      name = "阿依娜"
    }
    local comp = {
      x = 46,
      y = 51,
      sceneID = 27,
      name = "萝卜"
    }
    local mission = {
      name = "傻哥哥",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 280,
      y = 47,
      sceneID = 27,
      name = "阿黑"
    }
    local comp = {
      x = 252,
      y = 142,
      sceneID = 27,
      name = "阿诗玛"
    }
    local misName = "英雄救美"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 254, y = 147}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "玉溪",
        targetName = "热布巴拉"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 276,
      y = 45,
      sceneID = 27,
      name = "古鲁拉"
    }
    local comp = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local mission = {
      commit = true,
      name = "不蒸馒头",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local misName = "红衣马匪"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 208, y = 59}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "辽西",
        targetName = "红衣马匪"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local misName = "黑衣马匪"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 104, y = 89}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "辽西",
        targetName = "黑衣马匪"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local misName = "擒贼擒王"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 104, y = 60}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "辽西",
        targetName = "阿史那默谷"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local misName = "莽盖三杰"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 242, y = 52},
          {x = 222, y = 70},
          {x = 217, y = 47}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "辽西",
        targetName = "龙胜 萧允 李通"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 158,
      y = 195,
      sceneID = 21,
      name = "巴图"
    }
    local misName = "白狼皮"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 161, y = 268}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "白狼皮 干狼粪",
        sceneName = "辽西",
        targetName = "白狼王"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 158,
      y = 195,
      sceneID = 21,
      name = "巴图"
    }
    local misName = "黑蜂蜜"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 88, y = 220}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "黑蜂蜜",
        sceneName = "辽西",
        targetName = ""
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 164,
      y = 199,
      sceneID = 21,
      name = "伯颜"
    }
    local misName = "驱赶黑蜂"
    
    local function _AttackCallBack()
      DebugStr("驱赶黑蜂:执行中", 2)
      local nIndex, idMission, idScript = GetPlayerMission(misName)
      local nComplete = GetMissionVariable(nIndex, 0)
      if 1 == nComplete or -1 == nIndex then
        return true
      end
      local tRenWu = Bag:EnumRenWuItem()
      local tGLF = Bag:FindItemInfo("干狼粪", nil, nil, tRenWu)
      local tHZZ = Bag:FindItemInfo("火折子", nil, nil, tRenWu)
      if #tGLF > 0 and #tHZZ > 0 then
        Bag:UseItem(tHZZ[1].index, 500)
      end
      return false
    end
    
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 161, y = 268}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "白狼皮 干狼粪",
        sceneName = "辽西",
        targetName = "",
        call_back_attack = _AttackCallBack
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 191,
      sceneID = 21,
      name = "博尔伦"
    }
    local comp = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local mission = {
      name = "辽军元帅",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 170,
      y = 206,
      sceneID = 21,
      name = "耶律金"
    }
    local comp = {
      x = 53,
      y = 219,
      sceneID = 229,
      name = "周游"
    }
    local mission = {
      commit = true,
      name = "寻求温暖的办法",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 53,
      y = 219,
      sceneID = 229,
      name = "周游"
    }
    local comp = {
      x = 172,
      y = 24,
      sceneID = 229,
      name = "宁令哥"
    }
    local mission = {
      name = "通知宁令哥",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 53,
      y = 219,
      sceneID = 229,
      name = "周游"
    }
    local misName = "冰天雪地灵企鹅"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 141, y = 110}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "银皑雪原",
        targetName = "成年灵企鹅"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 53,
      y = 219,
      sceneID = 229,
      name = "周游"
    }
    local comp = {
      x = 215,
      y = 58,
      sceneID = 229,
      name = "博拉"
    }
    local mission = {
      name = "父亲的想念",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 53,
      y = 219,
      sceneID = 229,
      name = "周游"
    }
    local misName = "思乡情怯"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 178, y = 66}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "雪原狼皮",
        sceneName = "银皑雪原",
        targetName = "雪原狼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 172,
      y = 24,
      sceneID = 229,
      name = "宁令哥"
    }
    local misName = "冰天雪地圣企鹅"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 171, y = 153}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "银皑雪原",
        targetName = "成年圣企鹅"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 172,
      y = 24,
      sceneID = 229,
      name = "宁令哥"
    }
    local misName = "冰封的保护神"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 140, y = 65}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "银皑雪原",
        targetName = ""
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 172,
      y = 24,
      sceneID = 229,
      name = "宁令哥"
    }
    local misName = "冰山上的来客"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 131, y = 78}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "银皑雪原",
        targetName = "银皑雪人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 215,
      y = 58,
      sceneID = 229,
      name = "博拉"
    }
    local misName = "雪原莽盖"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 154, y = 181}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "银皑雪原",
        targetName = "雪原莽盖"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 215,
      y = 58,
      sceneID = 229,
      name = "博拉"
    }
    local comp = {
      x = 58,
      y = 80,
      sceneID = 229,
      name = "袁平"
    }
    local mission = {
      name = "冰天雪地寻豆豆",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 58,
      y = 80,
      sceneID = 229,
      name = "袁平"
    }
    local misName = "豆豆的保镖"
    
    function _HuSongDouDou()
      while true do
        local nIndex, idMission, idScript = GetPlayerMission(misName)
        local nComplete = GetMissionVariable(nIndex, 0)
        if -1 == nIndex or 0 ~= nComplete then
          break
        end
        local tDD = Enum2XByName("豆豆", {
          1,
          0,
          0,
          0
        })
        if #tDD > 0 then
          local dou = tDD[1]
          if GetDist(dou.x, dou.y, 60, 80) < 3 then
            GoToSceneNPC("豆豆", dou.x, dou.y, 229)
            DialogOptionClicked(misName, 1, 600)
          else
            GoToScene(dou.x, dou.y, 229)
          end
        else
          PushDebugMessage("没有找到可爱的豆豆")
          Sleep(2000)
          local tDD = Enum2XByName("豆豆", {
            1,
            0,
            0,
            0
          })
          if 0 == #tDD then
            QuestFrameMissionAbnegate(idScript)
          end
        end
        DebugStr(misName)
        Sleep(500)
      end
    end
    
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = _HuSongDouDou,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 215,
      y = 58,
      sceneID = 229,
      name = "博拉"
    }
    local comp = {
      x = 163,
      y = 191,
      sceneID = 21,
      name = "博尔伦"
    }
    local mission = {
      commit = true,
      name = "一封家书",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡"
    }
    local misName = "血字的研究"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 70, y = 135}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "南海鳄鱼的血液",
        sceneName = "南海",
        targetName = "南海鳄鱼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡"
    }
    local comp = {
      x = 111,
      y = 60,
      sceneID = 34,
      name = "丁涟漪"
    }
    local mission = {
      name = "剧中人",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡"
    }
    local comp = {
      x = 206,
      y = 237,
      sceneID = 34,
      name = "岳仲秋"
    }
    local mission = {
      name = "四签名",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 111,
      y = 60,
      sceneID = 34,
      name = "丁涟漪"
    }
    local misName = "黑暗"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 158, y = 80}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "南海",
        targetName = "鳄鱼帮混混"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 111,
      y = 60,
      sceneID = 34,
      name = "丁涟漪"
    }
    local comp = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡"
    }
    local mission = {
      name = "空屋",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 206,
      y = 237,
      sceneID = 34,
      name = "岳仲秋"
    }
    local misName = "五个橘核"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 165, y = 167}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "橘核",
        sceneName = "南海",
        targetName = "石老人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡",
      next_mission = false
    }
    local misName = "一线光明"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 265, y = 193}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "五雷石",
        sceneName = "南海",
        targetName = "岳不平"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡"
    }
    local comp = {
      x = 250,
      y = 186,
      sceneID = 34,
      name = "石敢当",
      next_mission = false
    }
    local mission = {
      name = "雷神桥之谜",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 250,
      y = 186,
      sceneID = 34,
      name = "石敢当"
    }
    local comp = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡",
      next_mission = false
    }
    local mission = {
      name = "第二块血迹",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 114,
      y = 59,
      sceneID = 34,
      name = "叶流凡"
    }
    local comp = {
      x = 128,
      y = 50,
      sceneID = 28,
      name = "白景武"
    }
    local mission = {
      commit = true,
      name = "戴面纱的房客",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 163,
      sceneID = 26,
      name = "郑玄"
    }
    local comp = {
      x = 48,
      y = 34,
      sceneID = 235,
      name = "杨元"
    }
    local mission = {
      commit = true,
      name = "同命相连",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 48,
      y = 34,
      sceneID = 235,
      name = "杨元"
    }
    local misName = "月夜惊梦"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 97, y = 35}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "盐湖",
        targetName = "盐湖熊"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 48,
      y = 34,
      sceneID = 235,
      name = "杨元"
    }
    local mission = {
      name = "白沙村的厄运",
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToScene(71, 151, 235)
      end,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 48,
      y = 34,
      sceneID = 235,
      name = "杨元"
    }
    local misName = "旺财"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 66, y = 199}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "旺财的夜明珠",
        sceneName = "盐湖",
        targetName = "偃师监工"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 48,
      y = 34,
      sceneID = 235,
      name = "杨元"
    }
    local misName = "忍无可忍"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 66, y = 199}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "盐湖",
        targetName = "偃师监工"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 31,
      y = 42,
      sceneID = 235,
      name = "李若水"
    }
    local comp = {
      x = 176,
      y = 194,
      sceneID = 235,
      name = "王思嘉"
    }
    local mission = {
      name = "惘然劫",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 31,
      y = 42,
      sceneID = 235,
      name = "李若水"
    }
    local misName = "鳄毒膏"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 62, y = 102},
          {x = 44, y = 117}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "盐湖鳄鱼肉",
        sceneName = "盐湖",
        targetName = "盐湖鳄鱼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 176,
      y = 194,
      sceneID = 235,
      name = "王思嘉"
    }
    local comp = {
      x = 31,
      y = 42,
      sceneID = 235,
      name = "李若水"
    }
    local mission = {
      name = "笔迹",
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 176,
      y = 194,
      sceneID = 235,
      name = "王思嘉"
    }
    local misName = "傀儡木人"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 196, y = 142}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "木人轴承",
        sceneName = "盐湖",
        targetName = "挖盐木人"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 172,
      y = 204,
      sceneID = 235,
      name = "郑杨"
    }
    local misName = "突袭偃师"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 204, y = 202}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "盐湖",
        targetName = "偃师守卫"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 172,
      y = 204,
      sceneID = 235,
      name = "郑杨"
    }
    local comp = {
      x = 31,
      y = 42,
      sceneID = 235,
      name = "李若水"
    }
    local misName = "奈何忠义老"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 172,
      y = 204,
      sceneID = 235,
      name = "郑杨"
    }
    local misName = "歃血之约"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 214, y = 37}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "盐湖",
        targetName = "古里赤"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 151,
      y = 49,
      sceneID = 28,
      name = "阿瓦"
    }
    local misName = "凤凰旧寨"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 277, y = 142}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "南诏",
        targetName = "黑沼豹"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 151,
      y = 67,
      sceneID = 28,
      name = "阿旺"
    }
    local misName = "蝴蝶神祭坛"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToScene(257, 266, 28)
      end,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 151,
      y = 67,
      sceneID = 28,
      name = "阿旺"
    }
    local misName = "黑苗战士"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 102, y = 271}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "南诏",
        targetName = "黑苗战士"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local misName = "藤甲贼"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 65, y = 172}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "南诏",
        targetName = "藤甲贼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local misName = "藤甲贼元帅"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 109, y = 199}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "龙纹银锁片",
        sceneName = "南诏",
        targetName = "兀骨突"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local comp = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local misName = "战争的原因"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 196, y = 161}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "苗疆",
        targetName = "古汉"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local comp = {
      x = 147,
      y = 47,
      sceneID = 28,
      name = "白兰"
    }
    local misName = "战果报告"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 47,
      sceneID = 28,
      name = "白兰"
    }
    local misName = "争夺矿山"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 185, y = 212},
          {x = 150, y = 201}
        },
        use_horse = true,
        is_pick = false,
        sceneName = "南诏",
        targetName = "藤甲勇士"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 47,
      sceneID = 28,
      name = "白兰"
    }
    local misName = "真实的谎言"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 103, y = 210}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "凤纹银锁片",
        sceneName = "南诏",
        targetName = "图巴鲁"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 47,
      sceneID = 28,
      name = "白兰"
    }
    local comp = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local misName = "凤纹银锁片"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 128,
      y = 50,
      sceneID = 28,
      name = "白景武"
    }
    local comp = {
      x = 117,
      y = 108,
      sceneID = 22,
      name = "完颜呵里布"
    }
    local misName = "英雄迟暮"
    local mission = {
      commit = true,
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 117,
      y = 108,
      sceneID = 22,
      name = "完颜呵里布"
    }
    local misName = "交贡品"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 75, y = 272}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "虎皮",
        sceneName = "长白山",
        targetName = "东北虎"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 118,
      y = 107,
      sceneID = 22,
      name = "完颜兀术"
    }
    local misName = "捉迷藏"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("完颜粘没喝", 147, 120, 22)
        GoToSceneNPC("完颜斡离不", 165, 90, 22)
        GoToSceneNPC("完颜讹里朵", 178, 114, 22)
      end,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 118,
      y = 107,
      sceneID = 22,
      name = "完颜兀术"
    }
    local comp = {
      x = 147,
      y = 123,
      sceneID = 22,
      name = "徒单福晋"
    }
    local misName = "神医的配方"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 201, y = 190}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "南海神医的配方",
        sceneName = "长白山",
        targetName = "雪人"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 123,
      sceneID = 22,
      name = "徒单福晋"
    }
    local comp = {
      x = 157,
      y = 127,
      sceneID = 22,
      name = "完颜吴乞买"
    }
    local misName = "送药酒"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 120,
      sceneID = 22,
      name = "完颜粘没喝"
    }
    local comp = {
      x = 147,
      y = 123,
      sceneID = 22,
      name = "徒单福晋"
    }
    local misName = "极品人参"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        local function _CB()
          local nIndex, idMission, idScript = GetPlayerMission(misName)
          
          local nComplete = GetMissionVariable(nIndex, 0)
          if -1 == nIndex or 0 ~= nComplete then
            return true
          end
          return false
        end
        
        BeginCaiji("六品叶人参", "长白山", {
          {x = 49, y = 51},
          {x = 112, y = 52}
        }, _CB)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 166,
      y = 90,
      sceneID = 22,
      name = "完颜斡离不"
    }
    local comp = {
      x = 147,
      y = 123,
      sceneID = 22,
      name = "徒单福晋"
    }
    local misName = "熊胆"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 57, y = 169}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "熊胆",
        sceneName = "长白山",
        targetName = "黑熊"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 121,
      sceneID = 22,
      name = "完颜盈哥"
    }
    local comp = {
      x = 234,
      y = 78,
      sceneID = 22,
      name = "完颜阿骨打"
    }
    local misName = "寻找阿骨打"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 234,
      y = 78,
      sceneID = 22,
      name = "完颜阿骨打"
    }
    local comp = {
      x = 117,
      y = 108,
      sceneID = 22,
      name = "完颜呵里布"
    }
    local misName = "韬光养晦"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 234,
      y = 78,
      sceneID = 22,
      name = "完颜阿骨打"
    }
    local misName = "突袭"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 269, y = 270}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "女真首领的旗帜",
        sceneName = "长白山",
        targetName = "纥石烈阿疏"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 147,
      y = 123,
      sceneID = 22,
      name = "徒单福晋"
    }
    local misName = "天涯海角"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("岳仲秋", 206, 237, 34, nil, nil, nil, nil, true, true)
        DialogOptionClicked("得到一块异种树皮", 1, 600)
      end,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 241,
      y = 159,
      sceneID = 35,
      name = "元子衿"
    }
    local misName = "盗神"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 252, y = 63}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "岳不平的密信",
        sceneName = "琼州",
        targetName = "南海盗神"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 241,
      y = 159,
      sceneID = 35,
      name = "元子衿"
    }
    local comp = {
      x = 246,
      y = 151,
      sceneID = 35,
      name = "凌忆慈",
      next_mission = false
    }
    local misName = "密信"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 246,
      y = 151,
      sceneID = 35,
      name = "凌忆慈"
    }
    local comp = {
      x = 256,
      y = 242,
      sceneID = 35,
      name = "岳老三"
    }
    local misName = "解开疑云"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 274,
      y = 269,
      sceneID = 35,
      name = "悠悠"
    }
    local misName = "青青子衿"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 260, y = 195}
        },
        use_horse = true,
        sceneName = "琼州",
        targetName = "嗜血鳄鱼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 274,
      y = 269,
      sceneID = 35,
      name = "悠悠"
    }
    local misName = "护花使者"
    
    function _HuSong()
      while true do
        local nIndex, idMission, idScript = GetPlayerMission(misName)
        local nComplete = GetMissionVariable(nIndex, 0)
        if -1 == nIndex or 0 ~= nComplete then
          break
        end
        local tDD = Enum2XByName("悠悠", {
          1,
          0,
          0,
          0
        })
        if #tDD > 0 then
          local dou = tDD[1]
          if GetDist(dou.x, dou.y, 274, 269) < 3 then
            GoToSceneNPC("悠悠", dou.x, dou.y, 35)
            DialogOptionClicked(misName, 1, 600)
          else
            GoToScene(dou.x, dou.y, 35)
          end
        else
          PushDebugMessage("没有找到NPC!")
          Sleep(2000)
          local tDD = Enum2XByName("悠悠", {
            1,
            0,
            0,
            0
          })
          if 0 == #tDD then
            QuestFrameMissionAbnegate(idScript)
          end
        end
        DebugStr(misName)
        Sleep(500)
      end
    end
    
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = _HuSong,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 256,
      y = 242,
      sceneID = 35,
      name = "岳老三"
    }
    local misName = "剪除勇士"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = apt,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 206, y = 218}
        },
        use_horse = true,
        sceneName = "琼州",
        targetName = "鳄鱼帮勇士"
      },
      OnAction = ZhuXianAttack,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 256,
      y = 242,
      sceneID = 35,
      name = "岳老三"
    }
    local misName = "剪除杀手"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 169, y = 95}
        },
        use_horse = true,
        sceneName = "琼州",
        targetName = "鳄鱼帮杀手"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 256,
      y = 242,
      sceneID = 35,
      name = "岳老三"
    }
    local misName = "玄武门之变"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 113, y = 115},
          {x = 113, y = 142}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "裘老七的腰牌",
        sceneName = "琼州",
        targetName = "裘老七"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 246,
      y = 151,
      sceneID = 35,
      name = "凌忆慈"
    }
    local comp = {
      x = 92,
      y = 266,
      sceneID = 29,
      name = "阿会南"
    }
    local misName = "最后一片净土"
    local mission = {
      commit = true,
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 201,
      y = 256,
      sceneID = 29,
      name = "阿松"
    }
    local misName = "阿松的请求"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 51, y = 51}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "沼泽鳄鱼皮",
        sceneName = "苗疆",
        targetName = "沼泽鳄鱼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local misName = "胆怯的阿雨"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 51, y = 51}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "沼泽鳄鱼皮",
        sceneName = "苗疆",
        targetName = "沼泽鳄鱼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local comp = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local misName = "感恩"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local comp = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local misName = "扬明的计划"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local comp = {
      x = 92,
      y = 266,
      sceneID = 29,
      name = "阿会南"
    }
    local misName = "勇闯寒玉塔"
    
    function _HuSong()
      while true do
        local nIndex, idMission, idScript = GetPlayerMission(misName)
        local nComplete = GetMissionVariable(nIndex, 0)
        if -1 == nIndex or 0 ~= nComplete then
          break
        end
        local tDD = Enum2XByName("阿雨的灵魂", {
          1,
          0,
          0,
          0
        })
        if #tDD > 0 then
          local dou = tDD[1]
          if GetDist(dou.x, dou.y, 184, 262) < 3 then
            GoToSceneNPC("阿雨的灵魂", dou.x, dou.y, 29)
            DialogOptionClicked(misName, 1, 600)
          else
            GoToScene(dou.x, dou.y, 29)
          end
        else
          Sleep(2000)
          local tDD = Enum2XByName("阿雨的灵魂", {
            1,
            0,
            0,
            0
          })
          if 0 == #tDD then
            QuestFrameMissionAbnegate(idScript)
          end
        end
        DebugStr(misName)
        Sleep(500)
      end
    end
    
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = _HuSong,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local misName = "厄修罗"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 205, y = 208}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "厄修罗护身符",
        sceneName = "苗疆",
        targetName = "厄修罗"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local misName = "永夜修罗"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 162, y = 48}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "永夜修罗护身符",
        sceneName = "苗疆",
        targetName = "永夜修罗"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local misName = "万劫修罗"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 37, y = 198}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "万劫修罗护身符",
        sceneName = "苗疆",
        targetName = "万劫修罗"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 182,
      y = 264,
      sceneID = 29,
      name = "阿雨"
    }
    local comp = {
      x = 157,
      y = 223,
      sceneID = 28,
      name = "扬明"
    }
    local misName = "修罗王的指示"
    local mission = {
      commit = true,
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 191,
      sceneID = 23,
      name = "拓跋文"
    }
    local misName = "温暖的呼吸"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 159, y = 133}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "雪山狼皮",
        sceneName = "黄龙府",
        targetName = "雪山狼"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 163,
      y = 191,
      sceneID = 23,
      name = "拓跋文"
    }
    local misName = "荒蛮的原野"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 174, y = 260}
        },
        use_horse = true,
        sceneName = "黄龙府",
        targetName = "大黑熊"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 166,
      y = 204,
      sceneID = 23,
      name = "符夕颜"
    }
    local misName = "危险的处境"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 67, y = 143}
        },
        use_horse = true,
        sceneName = "黄龙府",
        targetName = "雪山莽盖"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 166,
      y = 204,
      sceneID = 23,
      name = "符夕颜"
    }
    local comp = {
      x = 190,
      y = 48,
      sceneID = 23,
      name = "刘傲天"
    }
    local misName = "伤心的礼物"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 190,
      y = 48,
      sceneID = 23,
      name = "刘傲天"
    }
    local comp = {
      x = 46,
      y = 276,
      sceneID = 23,
      name = "慕容天狼"
    }
    local misName = "圣物的守护"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 46,
      y = 276,
      sceneID = 23,
      name = "慕容天狼"
    }
    local misName = "重甲的战斗"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 78, y = 66}
        },
        use_horse = true,
        sceneName = "黄龙府",
        targetName = "重甲莽盖"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 46,
      y = 276,
      sceneID = 23,
      name = "慕容天狼"
    }
    local misName = "巴伦的战斗"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 279, y = 201}
        },
        use_horse = true,
        sceneName = "黄龙府",
        targetName = "巴伦莽盖"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 46,
      y = 276,
      sceneID = 23,
      name = "慕容天狼"
    }
    local comp = {
      x = 166,
      y = 204,
      sceneID = 23,
      name = "符夕颜"
    }
    local misName = "无奈的真相"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 166,
      y = 204,
      sceneID = 23,
      name = "符夕颜"
    }
    local misName = "痛苦的爆发"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = m_mission_pos[misName] or {
          {x = 79, y = 38}
        },
        use_horse = true,
        is_pick = true,
        pick_item = "霍斯的腰牌",
        sceneName = "黄龙府",
        targetName = "霍斯"
      },
      OnAction = ZhuXianAttack,
      param_complete = apt,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 155,
      y = 195,
      sceneID = 23,
      name = "宇文苏"
    }
    local comp = {
      x = 163,
      y = 191,
      sceneID = 23,
      name = "拓跋文"
    }
    local misName = "情感的轮回"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end
}

    return MissionTable
end
local function names(text)
    -- A byte class cannot hold a Chinese comma: its bytes would split other characters.
    local out={};for w in (tostring(text or ''):gsub('，',' '):gsub(',',' ')):gmatch('%S+') do out[w]=true end
    return out
end
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Zhuxian.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local minutes=int(tonumber(cfg.zhuxian_minutes or 115),1,115,'总时限')
    for _,k in ipairs({'quest_abandon'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','主线开关无效：'..k) end
    local Q=QuestBook.new(api,{label='主线任务',minutes=minutes,scenes=SCENES,skip=names(cfg.zhuxian_skip)})
    local def={name='主线任务',mission='主线任务',map='',npc={name='',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    local table_=book(Q.env)
    local function body()
        api.validate(def,cfg)
        local idle=0
        while true do
            local more=api.resumable(function()
                Q.check()
                if not Q.act(table_) then
                    if not Q.commit(table_) and not Q.accept(table_) then return false end
                end
                Q.env.Sleep(100)
                return true
            end)
            if more==false then break end
        end
        if Q.handed==0 then return {status='already_done',message='主线任务：现在没有可做的任务'} end
        return {status='done',message='主线任务交了 '..Q.handed..' 个，已没有可做的任务'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..Q.phase..'；已交 '..Q.handed..' 个]',0) end
    assert(stopped,'主线任务停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
