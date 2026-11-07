-- 反编译自 dfz64.dll 内嵌字节码 00280af8（unluac 2025-12-23；仅供分析）
local m_script_name = "武林印"
ScriptOnStart(m_script_name, false, false)
local m_shimen_npc = {
  {
    name = "慧方",
    x = 96,
    y = 83,
    sceneID = 9,
    menpaiID = 0,
    menpaiName = "少林"
  },
  {
    name = "林岩",
    x = 98,
    y = 105,
    sceneID = 11,
    menpaiID = 1,
    menpaiName = "明教"
  },
  {
    name = "洪通",
    x = 91,
    y = 77,
    sceneID = 10,
    menpaiID = 2,
    menpaiName = "丐帮"
  },
  {
    name = "张中行",
    x = 78,
    y = 95,
    sceneID = 12,
    menpaiID = 3,
    menpaiName = "武当"
  },
  {
    name = "孟龙",
    x = 96,
    y = 88,
    sceneID = 15,
    menpaiID = 4,
    menpaiName = "峨嵋"
  },
  {
    name = "王彦",
    x = 96,
    y = 92,
    sceneID = 16,
    menpaiID = 5,
    menpaiName = "星宿"
  },
  {
    name = "本凡",
    x = 95,
    y = 88,
    sceneID = 13,
    menpaiID = 6,
    menpaiName = "天龙"
  },
  {
    name = "符敏仪",
    x = 95,
    y = 60,
    sceneID = 17,
    menpaiID = 7,
    menpaiName = "天山"
  },
  {
    name = "秦观",
    x = 119,
    y = 152,
    sceneID = 14,
    menpaiID = 8,
    menpaiName = "逍遥"
  },
  {
    name = "慕容胜",
    x = 68,
    y = 127,
    sceneID = 284,
    menpaiID = 10,
    menpaiName = "慕容"
  },
  {
    name = "唐清秋",
    x = 100,
    y = 64,
    sceneID = 615,
    menpaiID = 11,
    menpaiName = "唐门"
  },
  {
    name = "王玄风",
    x = 96,
    y = 98,
    sceneID = 678,
    menpaiID = 12,
    menpaiName = "鬼谷"
  },
  {
    name = "萧声咽",
    x = 160,
    y = 72,
    sceneID = 731,
    menpaiID = 13,
    menpaiName = "桃花岛"
  },
  {
    name = "七叔",
    x = 245,
    y = 191,
    sceneID = 824,
    menpaiID = 14,
    menpaiName = "绝情谷"
  },
  {
    name = "岳老三",
    x = 180,
    y = 181,
    sceneID = 987,
    menpaiID = 15,
    menpaiName = "恶人谷"
  }
}

local function mp_get_shimen_npc()
  local npc = {}
  g_self.menpai = Player:GetDataInt("MEMPAI")
  local menpai = GetMenpaiNameByID(g_self.menpai)
  for i = 1, #m_shimen_npc do
    if m_shimen_npc[i].menpaiName == menpai then
      return m_shimen_npc[i]
    end
  end
  return npc
end

local function ZhuXianComplete(aParam)
  mission_complete_talk_npc(aParam)
end

local MissionTable = {
  function()
    local apt = {
      x = 256,
      y = 274,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 149,
      y = 121,
      sceneID = 2,
      name = "祝富贵"
    }
    local misName = "青铜武林印之管理员邀请函"
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
      x = 149,
      y = 121,
      sceneID = 2,
      name = "祝富贵"
    }
    local comp = {
      x = 149,
      y = 121,
      sceneID = 2,
      name = "祝富贵"
    }
    local misName = "汇通天下"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function(_param)
        while true do
          DebugStr("执行任务:汇通天下")
          local nIndex = GetPlayerMission(misName, 1)
          local nParam0 = GetMissionVariable(nIndex, 0)
          if -1 == nIndex or 1 == nParam0 then
            CloseAllWindow()
            break
          end
          Bag:UseItemByName("天龙工资书", 1000)
          GoToSceneNPC("祝富贵", 149, 121, 2)
          DialogOptionClicked("红利商店", 1, 1000)
          Sleep(200)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 149,
      y = 121,
      sceneID = 2,
      name = "祝富贵"
    }
    local misName = "青铜武林印之相助师门"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnComplete = function(_param)
        local npc = mp_get_shimen_npc()
        if npc.x then
          GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
          DialogOptionClicked("青铜武林印之相助师门", 1, 800)
          QuestFrameNextClicked(700)
          QuestFrameMissionComplete(nil, 700)
          QuestFrameAcceptClicked(700)
        end
      end
    }
    return mission
  end,
  function()
    local misName = "青铜武林印之除恶务尽"
    local comp = {
      x = 94,
      y = 201,
      sceneID = 2,
      name = "付劫生"
    }
    local mission = {
      name = misName,
      OnAccept = function()
        local npc = mp_get_shimen_npc()
        if npc.x then
          GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
          DialogOptionClicked("青铜武林印之除恶务尽", 1, 800)
          QuestFrameAcceptClicked(700)
        end
      end,
      OnAction = function()
        if Player:GetMoney() + Player:GetMoney(2) < 1000 then
          Bank_GetMoney(1500)
        end
        GoToSceneNPC("卢三七", 105, 123, 2)
        Sleep(500)
        DialogOptionClicked("购买药品", 1, 100)
        Sleep(1000)
        Shop_BuyItem("金创药", 1)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 94,
      y = 201,
      sceneID = 2,
      name = "付劫生"
    }
    local comp = {
      x = 224,
      y = 226,
      sceneID = 1,
      name = "吴玠"
    }
    local misName = "青铜武林印之惩凶打图"
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
      x = 256,
      y = 274,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 303,
      y = 193,
      sceneID = LUOYANG_ID,
      name = "童贯"
    }
    local misName = "裹银武林印之蹴鞠盛会"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if Player:GetMoney() < 1000 then
          Bank_GetMoney(1000)
        end
        GoToSceneNPC("芮福祥", 347, 284, LUOYANG_ID)
        Sleep(500)
        DialogOptionClicked("买卖杂货", 1, 1000)
        Shop_BuyItem("白玉瓶", 1)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 303,
      y = 193,
      sceneID = LUOYANG_ID,
      name = "童贯"
    }
    local comp = {
      x = 290,
      y = 321,
      sceneID = LUOYANG_ID,
      name = "诸葛孔亮"
    }
    local misName = "裹银武林印之贝叶经残片"
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
      x = 290,
      y = 321,
      sceneID = LUOYANG_ID,
      name = "诸葛孔亮"
    }
    local comp = {
      x = 325,
      y = 318,
      sceneID = LUOYANG_ID,
      name = "赵明诚"
    }
    local misName = "裹银武林印之繁忙的漕运"
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
      x = 290,
      y = 321,
      sceneID = LUOYANG_ID,
      name = "诸葛孔亮"
    }
    local comp = {
      x = 270,
      y = 255,
      sceneID = LUOYANG_ID,
      name = "乔致广"
    }
    local misName = "裹银武林印之赚钱"
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
      x = 256,
      y = 274,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 356,
      y = 236,
      sceneID = LUOYANG_ID,
      name = "付云伤"
    }
    local misName = "镏金武林印之云锦商行"
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
      x = 356,
      y = 236,
      sceneID = LUOYANG_ID,
      name = "付云伤"
    }
    local comp = {
      x = 355,
      y = 268,
      sceneID = 1,
      name = "云姗姗"
    }
    local misName = "镏金武林印之如虎添翼"
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
      x = 355,
      y = 268,
      sceneID = 1,
      name = "云姗姗"
    }
    local comp = {
      x = 140,
      y = 195,
      sceneID = 2,
      name = "无崖子"
    }
    local misName = "镏金武林印之神勇武魂"
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
      x = 140,
      y = 195,
      sceneID = 2,
      name = "无崖子"
    }
    local comp = {
      x = 242,
      y = 31,
      sceneID = 2,
      name = "扫地神僧"
    }
    local misName = "镏金武林印之潜心修炼"
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

local function ZhuXianCommitMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if 1 == nComplete then
      DebugStr("交任务 " .. mis.name, 2)
      mis.is_complete = true
      mis.OnComplete(mis)
      bDoAction = true
      break
    end
  end
  return bDoAction
end

local function ZhuXianDoMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if -1 ~= nIndex then
      if 0 == nComplete then
        if mis.commit then
          PushColorMsg("切换地图,提交已完成任务！")
          if ZhuXianCommitMission() then
            return true
          end
        end
        DebugStr("执行任务 " .. mis.name, 2)
        if mis.OnAction then
          mis.OnAction(mis)
        elseif mis.OnComplete then
          mis.OnComplete(mis)
        end
        bDoAction = true
        break
      elseif 2 == nComplete then
        PushColorMsg("放弃任务：" .. misName)
        QuestFrameMissionAbnegate(idScript)
      end
    end
  end
  return bDoAction
end

local function ZhuXianCanAccept(aMisName)
  return true
end

local function ZhuXianAcceptCheckScene(aMisTable, aAcceptSceneID, aAcceptIndex)
  local mis_table = aMisTable
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    if -1 ~= nIndex and GetSceneID() ~= aAcceptSceneID and mis.param_accept.sceneID ~= aAcceptSceneID then
      return false
    end
  end
  return true
end

local function ZhuXianAcceptMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  CollectMissionOutline()
  Sleep(500)
  local lastScene = -1
  local nLevel = Player:GetDataInt("LEVEL")
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    if (mis.is_complete == nil or mis.is_complete == false) and IsMissionOutline(mis.name) and ZhuXianCanAccept(mis.name) and (-1 == lastScene or lastScene == mis.param_accept.sceneID) and mis.param_accept and mis.param_accept.sceneID and ZhuXianAcceptCheckScene(mis_table, mis.param_accept.sceneID, i) then
      lastScene = mis.param_accept.sceneID
      DebugStr("接任务 " .. mis.name, 2)
      bDoAction = true
      mis.OnAccept(mis)
      if i > 63 then
        break
      end
    end
  end
  return bDoAction
end

function _SMain()
  LoadScript("mission")
  local nOverCount = 0
  while true do
    local debugnote = ""
    if false == ZhuXianDoMission() then
      if false == ZhuXianCommitMission() then
        if false == ZhuXianAcceptMission() then
          if nOverCount <= 2 then
            local apt = {
              x = 256,
              y = 274,
              sceneID = LUOYANG_ID,
              name = "周天师"
            }
            GoToSceneNPC(apt.name, apt.x, apt.y, apt.sceneID)
            DialogOptionClicked("青铜武林印之管理员邀请函", 1, 700)
            QuestFrameAcceptClicked(500)
            GoToSceneNPC(apt.name, apt.x, apt.y, apt.sceneID)
            DialogOptionClicked("裹银武林印之蹴鞠盛会", 1, 700)
            QuestFrameAcceptClicked(500)
            GoToSceneNPC(apt.name, apt.x, apt.y, apt.sceneID)
            DialogOptionClicked("镏金武林印之云锦商行", 1, 700)
            QuestFrameAcceptClicked(500)
            nOverCount = nOverCount + 1
          else
            PushColorMsg("武林印：无任务可接")
            break
          end
        end
      elseif false == ZhuXianCommitMission() then
        ZhuXianAcceptMission()
      end
    end
    Sleep(100)
    DebugStr("武林印 " .. debugnote, 1)
  end
  Bag:UseItemByName_click("青铜武林印", 1000)
  Bag:UseItemByName_click("裹银武林印（1级）", 1000)
  Bag:UseItemByName_click("镏金武林印（1级）", 1000)
  Bag:UseItemByName_click("裹银武林印（2级）", 1000)
  Bag:UseItemByName_click("镏金武林印（2级）", 1000)
  Bag:UseItemByName_click("裹银武林印（3级）", 1000)
  Bag:UseItemByName_click("镏金武林印（3级）", 1000)
  Bag:UseItemByName_click("裹银武林印（4级）", 1000)
  Bag:UseItemByName_click("镏金武林印（4级）", 1000)
  Bag:UseItemByName_click("裹银武林印（5级）", 1000)
  Bag:UseItemByName_click("镏金武林印（5级）", 1000)
  Bag:UseItemByName_click("裹银武林印（6级）", 1000)
  Bag:UseItemByName_click("镏金武林印（6级）", 1000)
end

_SMain()
ScriptOnStop(m_script_name)
MissionTable = nil
