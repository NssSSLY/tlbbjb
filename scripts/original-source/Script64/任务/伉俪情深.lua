-- 反编译自 dfz64.dll 内嵌字节码 00252a6a（unluac 2025-12-23；仅供分析）
local m_script_name = "伉俪情深"
ScriptOnStart(m_script_name, false, false)
local m_param = {}
m_param.param = {}

local function FQ_OnMission1()
  local MissionInfo = {
    {
      x = 200,
      y = 168,
      sceneID = 30
    },
    {
      x = 88,
      y = 134,
      sceneID = 164
    },
    {
      x = 120,
      y = 138,
      sceneID = 1
    }
  }
  if 0 == m_param.param[1] then
    if IsDestination(MissionInfo[1].x, MissionInfo[1].y, MissionInfo[1].sceneID, 3) == false then
      UseMount()
      if Player:IsLeader() then
        Player:TeamFollow(true, 500)
      end
    end
    GoToSceneNPC("梁祝之墓", MissionInfo[1].x, MissionInfo[1].y, MissionInfo[1].sceneID)
    Sleep(500)
    Player:TeamFollow(false, 500)
    Dismount()
    Sleep(500)
    QuestFrameOptionClicked_Item("#{FQRC_150605_136}", 1, 1500)
  elseif 0 == m_param.param[2] then
    if IsDestination(MissionInfo[2].x, MissionInfo[2].y, MissionInfo[2].sceneID, 3) == false then
      UseMount()
      if Player:IsLeader() then
        Player:TeamFollow(true, 500)
      end
    end
    GoToScene(MissionInfo[2].x, MissionInfo[2].y, MissionInfo[2].sceneID, 1)
    Sleep(500)
    Player:TeamFollow(false, 500)
    Dismount()
    if Player:IsLeader() then
      Sleep(1000)
      Bag:UseItemByName("孔明灯")
      Sleep(1000)
    end
  elseif 0 == m_param.param[3] then
    if IsDestination(MissionInfo[3].x, MissionInfo[3].y, MissionInfo[3].sceneID, 3) == false then
      UseMount()
      if Player:IsLeader() then
        Player:TeamFollow(true, 500)
      end
    end
    GoToScene(MissionInfo[3].x, MissionInfo[3].y, MissionInfo[3].sceneID)
    Sleep(500)
    Player:TeamFollow(false, 500)
    Dismount()
    if Player:IsLeader() then
      Sleep(1000)
      Bag:UseItemByName("同心锁")
      Sleep(1000)
    end
  end
end

local function FQ_OnMission2()
  local MissionInfo = {
    {
      x = 179,
      y = 126,
      sceneID = 4
    },
    {
      x = 121,
      y = 163,
      sceneID = 4
    },
    {
      x = 122,
      y = 165,
      sceneID = 4
    }
  }
  local nSex = GetLuaValue("return GetMySelfRaceId();", "n")
  if 1 == nSex then
    PushDebugMessage("夫君.")
  else
    PushDebugMessage("娘子.")
  end
  if 0 == m_param.param[1] then
    if 1 == nSex then
      if 0 ~= Bag:GetItemCount("彩纸") then
        if IsDestination(MissionInfo[2].x, MissionInfo[2].y, MissionInfo[2].sceneID, 3) == false then
          UseMount()
          if Player:IsLeader() then
            Player:TeamFollow(true, 500)
          end
        end
        GoToScene(MissionInfo[2].x, MissionInfo[2].y, MissionInfo[2].sceneID)
        Sleep(500)
        Player:TeamFollow(false, 500)
        Dismount()
        Sleep(500)
        local tMember = Team:GetAllMemberInfo()
        for i = 1, #tMember do
          local tmp = tMember[i]
          if tmp.name ~= g_self.name then
            local tObj = Enum2XByName(tmp.name, {
              0,
              0,
              1,
              0
            }, nil, nil, 0)
            if #tObj > 0 then
              Target:Select(tObj[1].id, 500)
              local tItem = Bag:FindItemInfo("彩纸")
              if #tItem > 0 then
                Bag:ItemBtnClicked(tItem[1].index)
                Sleep(500)
              end
            end
            break
          end
        end
      else
        local tObj = Enum2XByClass("矿地")
        tObj = ObjFilterByName(tObj, "彩纸", 0)
        if #tObj > 0 then
          Player:TeamFollow(false, 500)
          Dismount()
          BubbleByDst(tObj)
          for i = 1, #tObj do
            local tmp = tObj[i]
            MoveTo(tmp.x, tmp.y, 4)
            OpenPackage(tmp.id)
            Sleep(1000)
            PlayerStateTimeOut(8, 5)
            if 0 ~= Bag:GetItemCount("彩纸") then
              break
            end
            local bOk = GetLuaValue("if IsWindowShow('LootPacket') then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close(); return 1 end; return 0 ", "b")
            if bOk then
              Sleep(50)
              break
            end
          end
        else
          if IsDestination(MissionInfo[1].x, MissionInfo[1].y, MissionInfo[1].sceneID, 3) == false then
            UseMount()
            if Player:IsLeader() then
              Player:TeamFollow(true, 500)
            end
          end
          GoToScene(MissionInfo[1].x, MissionInfo[1].y, MissionInfo[1].sceneID)
          Sleep(500)
          Player:TeamFollow(false, 500)
        end
      end
    else
      local function _move_cb(fX, fY, nScene)
        if not Player:IsLeader() and Player:IsFollow() then
          return false
        end
        return true
      end
      
      if 4 == GetSceneID() then
        local tMember = Team:GetAllMemberInfo()
        for i = 1, #tMember do
          local tmp = tMember[i]
          if tmp.name ~= g_self.name then
            if 4 == tmp.sceneID and (Player:IsLeader() or false == Player:IsFollow()) then
              MoveTo(tmp.x, tmp.y, tmp.sceneID, nil, nil, nil, _move_cb)
            end
            break
          end
        end
      elseif Player:IsLeader() or false == Player:IsFollow() then
        MoveTo(MissionInfo[1].x, MissionInfo[1].y, MissionInfo[1].sceneID, nil, nil, nil, _move_cb)
      end
      if Player:IsLeader() then
        Player:TeamFollow(false, 500)
      end
    end
  elseif 0 == m_param.param[2] then
    if IsDestination(MissionInfo[3].x, MissionInfo[3].y, MissionInfo[3].sceneID, 3) == false then
      UseMount()
      if Player:IsLeader() then
        Player:TeamFollow(true, 500)
      end
    end
    GoToSceneNPC("心语树", MissionInfo[3].x, MissionInfo[3].y, MissionInfo[3].sceneID)
    Sleep(500)
    Player:TeamFollow(false, 500)
    if 0 == nSex then
      Dismount()
      QuestFrameOptionClicked_Item("#{FQRC_150605_117}", 1, 2000)
    end
  end
end

local function FQ_OnMission3()
  local MissionInfo = {
    {
      x = 189,
      y = 211,
      sceneID = 18
    },
    {
      x = 115,
      y = 97,
      sceneID = 24
    },
    {
      x = 68,
      y = 117,
      sceneID = 7
    }
  }
  local posIndex = 0
  if 0 == m_param.param[1] then
    posIndex = 1
  elseif 0 == m_param.param[2] then
    posIndex = 2
  elseif 0 == m_param.param[3] then
    posIndex = 3
  end
  local pos = MissionInfo[posIndex]
  if pos then
    if IsDestination(pos.x, pos.y, pos.sceneID, 3) == false then
      UseMount()
      if Player:IsLeader() then
        Player:TeamFollow(true, 500)
      end
    end
    GoToScene(pos.x, pos.y, pos.sceneID)
    Sleep(500)
    Player:TeamFollow(false, 500)
    Dismount()
    Sleep(800)
    if Player:IsLeader() then
      local tItem = Bag:FindItemInfo("三生石")
      if #tItem > 0 then
        Bag:ItemBtnClicked(tItem[1].index)
        Sleep(1500)
      end
    end
  end
end

local function FQ_OnMission4()
  local MissionInfo = {
    {
      x = 337,
      y = 411,
      sceneID = 1,
      name = "李子白"
    }
  }
  local pos = MissionInfo[1]
  if IsDestination(pos.x, pos.y, pos.sceneID, 3) == false then
    UseMount()
    if Player:IsLeader() then
      Player:TeamFollow(true, 500)
    end
  end
  if -1 ~= Player:GetBuff("前世今生的考验") then
    GetLuaValue([[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name("OnUserClickFinish")
                Set_XSCRIPT_ScriptID(891359)
                Set_XSCRIPT_ParamCount(0)
            Send_XSCRIPT()
        ]])
    Sleep(1500)
  else
    GoToSceneNPC(pos.name, pos.x, pos.y, pos.sceneID)
    Player:TeamFollow(false, 500)
    Dismount()
    Sleep(800)
    QuestFrameOptionClicked_Item("#{FQRC_150605_247}", 1, 1000)
  end
end

local m_mission = {
  {
    misName = "一生一世",
    itemName = "#{FQRC_150605_9}",
    misFun = FQ_OnMission1
  },
  {
    misName = "纸鹤心语",
    itemName = "#{FQRC_150605_17}",
    misFun = FQ_OnMission2
  },
  {
    misName = "三生之约",
    itemName = "#{FQRC_150605_42}",
    misFun = FQ_OnMission3
  },
  {
    misName = "前世今生",
    itemName = "#{FQRC_150605_247}",
    misFun = FQ_OnMission4
  }
}

local function FQ_OnMission()
  local npc = {
    name = "花仙",
    x = 139,
    y = 179,
    sceneID = LUOYANG_ID
  }
  for i = 1, #m_mission do
    local nIndex, idMission, idScript = GetPlayerMission_Item(m_mission[i].itemName)
    if -1 ~= nIndex then
      for j = 0, 7 do
        m_param.param[j] = GetMissionVariable(nIndex, j)
      end
      if 0 == m_param.param[0] then
        m_mission[i].misFun()
      elseif 1 == m_param.param[0] then
        if IsDestination(npc.x, npc.y, npc.sceneID, 3) == false then
          UseMount()
          if Player:IsLeader() then
            Player:TeamFollow(true, 500)
          end
        end
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        Sleep(800)
        Player:TeamFollow(false, 500)
        if Player:IsLeader() then
          QuestFrameOptionClicked_Item("#{FQRC_150605_49}", 1, 1000)
          QuestFrameMissionComplete(nil, 600)
        end
      elseif 2 == m_param.param[0] then
        QuestFrameMissionAbnegate(idScript)
      end
      return true
    end
  end
  PushDebugMessage("夫妻任务：接取")
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  Sleep(500)
  QuestFrameOptionClicked_Item("#{FQRC_150605_49}", 1, 1000)
  QuestFrameAcceptClicked(1000)
  local szText = GetNPCEventList_Item(0)
  if string.find(szText, "FQRW_171219_03", nil, true) then
    PushColorMsg("夫妻任务：本周次数已达到，结束！")
    for i = 1, 3 do
      Team:LeaveTeam()
      Sleep(200)
    end
    return false
  elseif string.find(szText, "FQRC_150605_54", nil, true) then
    PushColorMsg("夫妻任务：与您的爱人组成二人队伍！")
    return false
  elseif "#{FQRC_150605_52}" == szText then
    PushColorMsg("夫妻任务：与您的爱人组队来此!")
    return false
  elseif string.find(szText, "FQRC_150605_60", nil, true) then
    Sleep(3000)
  end
  return true
end

function _SMain(...)
  while false ~= FQ_OnMission() do
    Sleep(500)
    DebugStr("夫妻伉俪情深任务")
  end
  Player:TeamFollow(false, 500)
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_mission = nil
