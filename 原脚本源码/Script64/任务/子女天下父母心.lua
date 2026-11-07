-- 反编译自 dfz64.dll 内嵌字节码 002585c4（unluac 2025-12-23；仅供分析）
local m_script_name = "子女天下父母心"
ScriptOnStart(m_script_name, true, false)
CDG.attack = true
local m_param = {}
m_param.missionName = "天下父母心"
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
m_param.missionChildType = {
  BaiFang = 1,
  Caiji = 2,
  DingDianYinDao = 3,
  XunWu = 4,
  BuZhuo = 5
}
m_param.catchFilter = {}

local function GetInfantLevel(aIndex)
  return GetLuaValue(fmt("return Infant:GetInfantLevel(%d);", aIndex), "n")
end

local function GetInfantExpMission(aMissIndex)
  local misId, sceneId, sceneName, NpcName, PosX, PosZ = GetLuaValue(fmt([[
	
                local misId, sceneId, sceneName, NpcName, PosX, PosZ = DataPool:GetInfantExpMission(%d)
                return misId, sceneId, sceneName, NpcName, PosX, PosZ
            ]], aMissIndex), "nnssnn", 6)
  if 0 == sceneId then
    sceneId = LUOYANG_ID
  end
  if "成年大猩猩、" == NpcName then
    NpcName = "成年大猩猩"
  end
  if "成年北极熊" == NpcName then
    PosX = 227
    PosZ = 203
  end
  return misId, sceneId, sceneName, NpcName, PosX, PosZ
end

local function OnMission_890500()
  local MissType = m_param.param[1]
  local BaoZhuangIndex = m_param.param[2]
  local MissIndex = m_param.param[3]
  local nMisId, nSceneID, szSceneName, szNpcName, X, Y = GetInfantExpMission(MissIndex)
  if -1 == nMisId or "" == szNpcName then
    PushDebugMessage("天下父母心：没有找到NPC信息[%d]", MissIndex)
    Sleep(500)
    return
  end
  if MissType == m_param.missionChildType.BaiFang then
    PushDebugMessage("天下父母心：拜访")
    GoToSceneNPC(szNpcName, X, Y, nSceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("天下父母心", 1, 600)
  elseif MissType == m_param.missionChildType.Caiji then
    PushDebugMessage("天下父母心：采集")
    
    local function _CB()
      m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
      m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
      if -1 == m_param.misIndex or 0 ~= m_param.param[0] then
        return true
      end
      return false
    end
    
    local pos = {
      {x = X, y = Y}
    }
    BeginCaiji(szNpcName, nSceneID, pos, _CB)
  elseif MissType == m_param.missionChildType.XunWu then
    PushDebugMessage("天下父母心：寻物")
    local npc = {
      x = 230,
      y = 308,
      sceneID = LUOYANG_ID,
      name = "白萌生"
    }
    if MissIndex >= 47 and MissIndex <= 52 then
      npc = {
        x = 274,
        y = 322,
        sceneID = LUOYANG_ID,
        name = "陶得宝"
      }
    end
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    Sleep(500)
    Shop_BuyItem(szNpcName, 1)
    Sleep(300)
  elseif MissType == m_param.missionChildType.DingDianYinDao then
    PushDebugMessage("天下父母心：定点使用物品")
    if 1 == BaoZhuangIndex then
      szNpcName = "风筝"
    elseif 2 == BaoZhuangIndex then
      szNpcName = "小铲子"
    elseif 3 == BaoZhuangIndex then
      szNpcName = "健康树"
    elseif 4 == BaoZhuangIndex then
      szNpcName = "飞火流星"
    end
    GoToScene(X, Y, nSceneID, 1)
    Dismount()
    local tItem = Bag:FindItemInfo(szNpcName, nil, nil, Bag:EnumRenWuItem())
    if #tItem > 0 then
      Bag:ItemBtnClicked(tItem[1].index)
      Sleep(1000)
    end
    PlayerStateTimeOut(5, 5)
  elseif MissType == m_param.missionChildType.BuZhuo then
    PushDebugMessage("天下父母心：捕捉")
    local catchInfo = {
      pos = {
        {x = X, y = Y}
      },
      sceneID = 112,
      sceneName = "玄武岛",
      petName = szNpcName,
      attackName = szNpcName,
      name = ""
    }
    
    local function mis_callback()
      HuDaoPet()
      m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
      if 0 ~= m_param.param[0] then
        PushDebugMessage("抓珍兽:已完成!")
        return true
      end
      local bCatch = false
      bCatch, m_param.catchFilter = OnCatch(catchInfo, m_param.catchFilter)
      if bCatch then
        return true
      end
      DebugStr("天下父母心：抓珍兽", 2)
      return false
    end
    
    CatchPet(catchInfo, mis_callback)
  end
end

function _SMain(...)
  LoadScript("caiji")
  local npc = {
    name = "木子姐姐",
    x = 151,
    y = 187,
    sceneID = LUOYANG_ID
  }
  DeleteDebugMsg("#{CZRW_130822_8}")
  while true do
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
    if -1 ~= m_param.misIndex then
      for i = 0, 7 do
        m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
      end
      if 1 == m_param.param[0] then
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        Sleep(500)
        QuestFrameOptionClicked_Item(m_param.missionName, 1, 1000)
        if m_param.param[1] == m_param.missionChildType.BuZhuo then
          if IsWindowVisible("MissionReply") then
            local _, _, _, szNpcName = GetInfantExpMission(m_param.param[3])
            PushDebugMessage("天下父母心:交珍兽 " .. szNpcName)
            GetLuaValue(fmt([[
                                    local petName = "%s"
                                    setmetatable(_G, {__index = MissionReply_Env})
                                    if this:IsVisible() then
                                        local PET_MAX_NUMBER = 10
                                        for i = PET_MAX_NUMBER - 1, 0, -1 do
                                            if mePetCheckIndex(i) then
                                                local szPetName, szOn = Pet:GetPetList_Appoint(i)
                                                if szPetName ~= nil and szPetName ~= "" then
                                                    if szOn == "on_packa" then
                                                        if szPetName == petName then
                                                            MissionReply:OnContinue(i)
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                ]], szNpcName))
            Sleep(500)
          end
        else
          QuestFrameNextClicked(500)
          QuestFrameMissionComplete(nil, 500)
        end
      else
        OnMission_890500()
      end
    else
      if GetInfantLevel(0) > 90 then
        PushColorMsg("天下父母心：子女等级超过90级不能领取任务")
        break
      end
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(500)
      QuestFrameOptionClicked_Item(m_param.missionName, 1, 1000)
      if IsInDebugMsg("#{CZRW_130822_8}") then
        PushColorMsg("天下父母心：今日已完成5次任务")
        break
      end
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
