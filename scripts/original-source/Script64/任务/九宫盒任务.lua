-- 反编译自 dfz64.dll 内嵌字节码 0024f50f（unluac 2025-12-23；仅供分析）
local m_script_name = "九宫盒"
ScriptOnStart(m_script_name, true, false)
CDG.attack = true
local m_finish = false
local m_missionName = {}
m_missionName[1] = "神秘拼图"
m_missionName[2] = "亦幻亦真"
m_missionName[4] = "寻寻觅觅"
m_missionName[3] = "众里寻她"
m_missionName[7] = "众里寻他"
m_missionName[9] = "九宫谜题"

local function JGH_IsStop()
  local szText = GetNPCEventList_Item(0)
  if "#{TJRW_100511_98}" == szText then
    PushColorMsg("九宫盒:已经完成27环天机任务!")
    return true
  end
  return false
end

local function JGH_AbnegateMission(aMissionName)
  local nIndex, idMission, idScript = GetPlayerMission(aMissionName)
  if -1 ~= idScript then
    QuestFrameMissionAbnegate(idScript)
  end
end

local function JGH_MissionComplete()
  GoToSceneNPC("魏三爷", 328, 246, 1, 3, true, nil, nil, true, true)
  Sleep(1000)
  Bag_DeleteItem()
  QuestFrameOptionClicked_Item("#{TJRW_100511_31}", 1, 800)
  QuestFrameMissionComplete(nil, 800)
end

local function JGH_IsMissionComplete(aMissionName)
  local nIndex, idMission, idScript = GetPlayerMission(aMissionName)
  return GetMissionComplete(nIndex)
end

local function JGH_GetCurrentMiss()
  local idItemRubik = 40004560
  local nCurrentTable = -1
  local nIndexMiss = -1
  local nMaxIndex = 8
  for i = 0, nMaxIndex do
    local idTable = idItemRubik + nMaxIndex - i
    if -1 ~= Bag:FindItemIndexByTableID(idTable) then
      nCurrentTable = idTable
      nIndexMiss = nMaxIndex - i + 1
      break
    end
  end
  return nCurrentTable, nIndexMiss
end

local function JGH_execMission1(aItemTableID)
  local InfoMiss1 = {}
  InfoMiss1[40004528] = {
    sceneID = 4,
    x = 196,
    y = 245
  }
  InfoMiss1[40004529] = {
    sceneID = 8,
    x = 244,
    y = 180
  }
  InfoMiss1[40004530] = {
    sceneID = 26,
    x = 200,
    y = 125
  }
  InfoMiss1[40004531] = {
    sceneID = 25,
    x = 236,
    y = 54
  }
  InfoMiss1[40004532] = {
    sceneID = 27,
    x = 266,
    y = 54
  }
  InfoMiss1[40004533] = {
    sceneID = 20,
    x = 177,
    y = 250
  }
  InfoMiss1[40004534] = {
    sceneID = 24,
    x = 96,
    y = 121
  }
  InfoMiss1[40004535] = {
    sceneID = 18,
    x = 237,
    y = 88
  }
  InfoMiss1[40004536] = {
    sceneID = 31,
    x = 133,
    y = 186
  }
  InfoMiss1[40004527] = {
    sceneID = 30,
    x = 238,
    y = 135
  }
  local pos = InfoMiss1[aItemTableID]
  if nil == pos then
    PushColorMsg("九宫盒:任务1、5,物品table id无数据" .. aItemTableID)
    return
  end
  GoToScene(pos.x, pos.y, pos.sceneID, 2, nil, nil, nil, true, true)
  Dismount()
  Sleep(1000)
  Bag:FindItemIndexByTableID(aItemTableID, 1)
end

local function JGH_IsItemMapMission1()
  local nItemMap = 40004527
  local nMapCall = -1
  for i = 0, 9 do
    if -1 ~= Bag:FindItemIndexByTableID(nItemMap + i) then
      nMapCall = nItemMap + i
      break
    end
  end
  return nMapCall
end

local function JGH_OnMission1(nIndexMiss, idCurItem)
  DebugStr("九宫盒:任务1、5", 2)
  local MissionFlag = JGH_IsMissionComplete(m_missionName[1])
  local idMapMiss1
  if -1 == MissionFlag then
    Bag:FindItemIndexByTableID(idCurItem, 1)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{TJRW_100511_38}", 3, 1000)
    if JGH_IsStop() then
      m_finish = true
    end
    CloseWindow("Quest")
  elseif 0 == MissionFlag then
    idMapMiss1 = JGH_IsItemMapMission1()
    if -1 ~= idMapMiss1 then
      JGH_execMission1(idMapMiss1)
    else
      PushColorMsg("九宫盒:任务1、5 出错缺少物品 " .. nIndexMiss)
      Sleep(3000)
    end
  elseif 1 == MissionFlag then
    JGH_MissionComplete()
  elseif 2 == MissionFlag then
    PushColorMsg("九宫盒：任务失败1、5")
    JGH_AbnegateMission(m_missionName[1])
  else
    PushColorMsg("九宫盒：任务1、5错误 " .. nIndexMiss .. " " .. MissionFlag)
  end
end

local function JGH_getInfoNPCMission2()
  local infoObj = Enum2XByName("幻花妖", {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  if #infoObj < 3 then
    PushDebugMessage("任务2怪物错误 : %d ", #infoObj)
    return nil
  end
  for i = 1, 3 do
    if -1 == infoObj[i].model then
      return nil
    end
  end
  if infoObj[1].model == infoObj[2].model then
    return infoObj[3]
  elseif infoObj[1].model == infoObj[3].model then
    return infoObj[2]
  else
    return infoObj[1]
  end
end

local function JGH_execMission2()
  DeleteDebugMsg("TJRW_100511_13")
  if -1 ~= Bag:FindItemIndexByTableID(40004537, 1) then
    Sleep(1000)
    local npc
    local nMsgTime, strMsg = IsInDebugMsg("TJRW_100511_13")
    if nMsgTime then
      local nStartCharScene = string.find(strMsg, string.char(17))
      if nStartCharScene then
        local nEndCharScene = string.find(strMsg, string.char(42), nStartCharScene)
        if nEndCharScene then
          nStartCharScene = nStartCharScene + 1
          nEndCharScene = nEndCharScene - 1
          local szScene = string.sub(strMsg, nStartCharScene, nEndCharScene)
          local szText = fmt([[
                            local strDictionary = '%s'
                            return meGetDictionaryString(strDictionary)
                            ]], szScene)
          szScene = GetLuaValue(szText, "s")
          local nScene = GetSceneIDByName(szScene)
          local _, _, xPos, yPos = string.find(strMsg, "}.-(%d+).-(%d+)}")
          xPos = tonumber(xPos) or -1
          yPos = tonumber(yPos) or -1
          if -1 ~= nScene and -1 ~= xPos and -1 ~= yPos then
            npc = {
              x = xPos,
              y = yPos,
              sceneID = nScene
            }
          end
        end
      end
    end
    if not npc then
      if nil == JGH_getInfoNPCMission2() then
        PushColorMsg("九宫盒:任务2、6未获取到坐标")
      end
      return
    end
    PushColorMsg("九宫盒:任务2、6前往 %s,%s 地图:%s ", npc.x, npc.y, npc.sceneID)
    GoToScene(npc.x, npc.y, npc.sceneID, 2, nil, nil, nil, true, true)
  else
    local tObj = Enum2XByName("幻花妖", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tObj > 0 then
      FubenAttack(tObj[1].id)
    else
      local curScene = GetSceneID()
      local tar = JGH_getInfoNPCMission2()
      if tar then
        MoveTo(tar.x, tar.y, curScene)
        OpenTalk(tar.id, 1000)
        QuestFrameOptionClicked_Item("#{TJRW_100511_15}", 1, 800)
      else
        PushColorMsg("九宫盒:任务2、6没有任务进度")
      end
    end
  end
end

local function JGH_OnMission2(nIndexMiss, idCurItem)
  DebugStr("九宫盒:任务2、6", 2)
  local MissionFlag = JGH_IsMissionComplete(m_missionName[2])
  if -1 == MissionFlag then
    Bag:FindItemIndexByTableID(idCurItem, 1)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{TJRW_100511_39}", 3, 1000)
    if JGH_IsStop() then
      m_finish = true
    end
    CloseWindow("Quest")
  elseif 0 == MissionFlag then
    JGH_execMission2()
  elseif 1 == MissionFlag then
    JGH_MissionComplete()
  elseif 2 == MissionFlag then
    PushColorMsg("九宫盒：任务失败2、6")
    JGH_AbnegateMission(m_missionName[2])
  else
    PushColorMsg("九宫盒：任务2、6错误 " .. nIndexMiss .. " " .. MissionFlag)
  end
end

local function JGH_execMission3()
  local strText = [[
            local TeamCount = DataPool:GetTeamMemberCount()
            local iSexy = Player:GetMySex()
            for i = 0, TeamCount - 1 do
                local szName = DataPool:GetTeamMemInfoByIndex(i)
                if szName ~= nil and szName ~= "" then
                    local nTeamFriend, nIndexFriend = DataPool:GetFriendByName(szName)
                    if nTeamFriend >= 1 and nTeamFriend <= 4 then
                        local nSex = DataPool:GetFriend(nTeamFriend, nIndexFriend, "SEX")
                        if nSex ~= -1 and nSex ~= iSexy then
                            return szName
                        end
                    end
                end
            end         
            return ""
        ]]
  local strName = GetLuaValue(strText, "s")
  
  local function _FindMember(aMemName)
    local tMem = Team:GetAllMemberInfo()
    for i = 1, #tMem do
      if "" ~= aMemName and tMem[i].name == aMemName then
        if 0 == tMem[i].x or 0 == tMem[i].y then
          tMem[i].x, tMem[i].y = GetSceneTempPos(tMem[i].sceneID)
        end
        return tMem[i]
      end
    end
    return nil
  end
  
  local tar = _FindMember(strName)
  if tar then
    local function _jgh_move_cb(fX, fY, nScene)
      local leader = _FindMember(strName)
      
      if not leader then
        return false
      end
      Player:TeamFollow(false, 300)
      if -1 ~= FollowFilterScene(leader.sceneID) then
        DebugStr("九宫盒:队友不在正确的地图,暂不跟随!")
        return false, nil
      end
      local leaderObj = FindObjByGUID(leader.guid)
      if leaderObj then
        RunTo(leaderObj.x, leaderObj.y, 1, 350)
        if leaderObj.dst <= 3 then
          return false, nil
        else
          leaderObj.sceneID = leader.sceneID
          return true, leaderObj
        end
      end
      DebugStr("九宫盒:跟随队友移动到 x:%s y:%s scene:%s", 1, math.floor(leader.x), math.floor(leader.y), leader.sceneID)
      if leader.x > 0 and (leader.x ~= fX or leader.y ~= fY or leader.sceneID ~= nScene) then
        if leader.sceneID ~= 65535 then
          AutoRunToTarget(leader.x, leader.y, leader.sceneID, true)
          Sleep(300)
        else
          return true, nil
        end
      else
        return true, nil
      end
      return true, leader
    end
    
    MoveTo(tar.x, tar.y, tar.sceneID, 2, true, nil, _jgh_move_cb, true, true)
    local target = FindObjByGUID(tar.guid)
    if target then
      RunTo(target.x, target.y, 0, 500)
      Target:Select(target.id, 600)
      Bag:FindItemIndexByTableID(40004559, 1)
    end
  else
    DebugStr("九宫盒:该任务请提前与异性好友组队", 3)
  end
end

local function JGH_OnMission3(nIndexMiss, idCurItem)
  DebugStr("九宫盒:任务3、7", 2)
  local MissionFlag = JGH_IsMissionComplete(m_missionName[3])
  if -1 == MissionFlag then
    MissionFlag = JGH_IsMissionComplete(m_missionName[7])
  end
  if -1 == MissionFlag then
    Bag:FindItemIndexByTableID(idCurItem, 1)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{TJRW_100511_19}", 3, 1000)
    QuestFrameOptionClicked_Item("#{TJRW_100511_25}", 3, 1000)
    if JGH_IsStop() then
      m_finish = true
    end
    CloseWindow("Quest")
  elseif 0 == MissionFlag then
    JGH_execMission3()
  elseif 1 == MissionFlag then
    JGH_MissionComplete()
  elseif 2 == MissionFlag then
    PushColorMsg("九宫盒：任务失败3、7")
    JGH_AbnegateMission(m_missionName[3])
    JGH_AbnegateMission(m_missionName[7])
  else
    PushColorMsg("九宫盒：任务3、7错误 " .. nIndexMiss .. " " .. MissionFlag)
  end
end

local function JGH_execMission4()
  local nIndex = GetPlayerMission(m_missionName[4])
  local nParamItem = GetMissionVariable(nIndex, 5)
  if -1 == nIndex or -1 == nParamItem then
    PushColorMsg("九宫盒:任务4、8信息有误")
    return
  end
  local szItemName = GetLuaValue(fmt([[
            local strDictionary = DataPool:GetPlayerMission_StrList(%d)
            if string.find(strDictionary, "#{", nil, true) then
                local szItemName = meGetDictionaryString(strDictionary)
                return szItemName
            end      
            return ""
        ]], nParamItem), "s")
  if "" == szItemName then
    PushColorMsg("九宫盒:任务4、8无法识别物品" .. nParamItem)
    return
  end
  local nCount = Bag:GetItemCount(szItemName, nil, nil, Bag:EnumCailiaoItem())
  if 0 == nCount then
    Bank_GetMoney(100000, "洛阳")
    ShangHui_BuyItem(szItemName, 1)
    Sleep(1000)
  end
end

local function JGH_OnMission4(nIndexMiss, idCurItem)
  DebugStr("九宫盒:任务4、8", 2)
  local MissionFlag = JGH_IsMissionComplete(m_missionName[4])
  if -1 == MissionFlag then
    Bag:FindItemIndexByTableID(idCurItem, 1)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{TJRW_100511_41}", 3, 1000)
    if JGH_IsStop() then
      m_finish = true
    end
    CloseWindow("Quest")
  elseif 0 == MissionFlag then
    JGH_execMission4()
  elseif 1 == MissionFlag then
    JGH_MissionComplete()
  elseif 2 == MissionFlag then
    PushColorMsg("九宫盒:任务失败4、8")
    JGH_AbnegateMission(m_missionName[4])
  else
    PushColorMsg("九宫盒:任务错误4、8:" .. nIndexMiss .. " " .. MissionFlag)
  end
end

local function JGH_execMission9()
  PushColorMsg("九宫盒：请您回答谜题！")
  m_finish = true
end

local function JGH_OnMission9(nIndexMiss, idCurItem)
  DebugStr("九宫盒:任务9", 2)
  local MissionFlag = JGH_IsMissionComplete(m_missionName[9])
  if -1 == MissionFlag then
    Bag:FindItemIndexByTableID(idCurItem, 1)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{TJRW_100511_27}", 3, 1000)
    if JGH_IsStop() then
      m_finish = true
    end
    CloseWindow("Quest")
  elseif 0 == MissionFlag then
    JGH_execMission9()
  elseif 1 == MissionFlag then
    JGH_MissionComplete()
  elseif 2 == MissionFlag then
    PushColorMsg("九宫盒:任务9失败")
    JGH_AbnegateMission(m_missionName[9])
  else
    PushColorMsg("九宫盒:任务9错误" .. nIndexMiss .. " " .. MissionFlag)
  end
end

function _SMain(...)
  while true do
    local idRenWuItem, nIndexMiss = JGH_GetCurrentMiss()
    if -1 ~= idRenWuItem then
      if 1 == nIndexMiss then
        JGH_OnMission1(nIndexMiss, idRenWuItem)
      elseif 2 == nIndexMiss then
        JGH_OnMission2(nIndexMiss, idRenWuItem)
      elseif 3 == nIndexMiss then
        JGH_OnMission3(nIndexMiss, idRenWuItem)
      elseif 4 == nIndexMiss then
        JGH_OnMission4(nIndexMiss, idRenWuItem)
      elseif 5 == nIndexMiss then
        JGH_OnMission1(nIndexMiss, idRenWuItem)
      elseif 6 == nIndexMiss then
        JGH_OnMission2(nIndexMiss, idRenWuItem)
      elseif 7 == nIndexMiss then
        JGH_OnMission3(nIndexMiss, idRenWuItem)
      elseif 8 == nIndexMiss then
        JGH_OnMission4(nIndexMiss, idRenWuItem)
      elseif 9 == nIndexMiss then
        JGH_OnMission9(nIndexMiss, idRenWuItem)
      end
    else
      local nIndexBag = Bag:FindItemIndexByTableID(30900089)
      if -1 == nIndexBag then
        TempBank2Bag(" 九宫盒 ", 0)
        Sleep(500)
      end
      nIndexBag = Bag:FindItemIndexByTableID(30900089)
      if -1 == nIndexBag then
        Bank_GetItem("九宫盒", -1)
        Sleep(500)
      end
      nIndexBag = Bag:FindItemIndexByTableID(30900089)
      if -1 == nIndexBag then
        PushColorMsg("九宫盒:商会购买九宫盒")
        Bank_GetMoney(200000, "洛阳")
        ShangHui_BuyItem("九宫盒", 1)
        Sleep(500)
        Bank_SaveMoney(0)
      end
      nIndexBag = Bag:FindItemIndexByTableID(30900089)
      if -1 ~= nIndexBag then
        Bag:UseItemByName("九宫盒", 1000, Bag:EnumDaoJuItem())
        QuestFrameOptionClicked_Item("#{TJRW_100511_2}#{TJRW_100511_38}", 1, 800)
        if JGH_IsStop() then
          break
        end
        CloseWindow("Quest")
      else
        PushColorMsg("九宫盒:缺少道具")
        break
      end
    end
    Sleep(200)
    if m_finish then
      break
    end
    DebugStr(m_script_name)
  end
  Bag_Move2TempBank("九宫盒")
end

_SMain()
ScriptOnStop(m_script_name, false)
m_missionName = nil
