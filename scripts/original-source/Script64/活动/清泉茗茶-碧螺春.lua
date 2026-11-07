-- 反编译自 dfz64.dll 内嵌字节码 0043c03c（unluac 2025-12-23；仅供分析）
local m_script_name = "清泉茗茶"
ScriptOnStart(m_script_name, false, false)
local m_npc = {
  name = "陆屿",
  x = 296,
  y = 188,
  sceneID = 1
}
local m_mission = {}
local m_param = {}
local m_lastName = {}

local function XW_OnMission1(idScript)
  if 1 ~= m_param[1] then
    if 5 ~= Player:GetState() then
      GoToScene(90, 194, 30)
      Dismount()
      local tObj = Enum2XByName("龙井", {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if #tObj > 0 then
        Skill.CUseSkillByID(3677, tObj[1].id)
        Sleep(500)
      end
    end
  else
    GoToScene(104, 66, 30)
    Dismount()
    Bag:UseItemByName_click("竹筒", 500, Bag:EnumRenWuItem())
  end
end

local function XW_OnMission2(idScript)
  if 1 ~= m_param[1] then
    if 5 ~= Player:GetState() then
      GoToScene(185, 219, 4)
      Dismount()
      local tObj = Enum2XByName("碧螺春", {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if #tObj > 0 then
        Skill.CUseSkillByID(3677, tObj[1].id)
        Sleep(500)
      end
    end
  else
    GoToScene(154, 223, 4)
    Dismount()
    Bag:UseItemByName_click("竹筒", 500, Bag:EnumRenWuItem())
  end
end

local function XW_OnMission3(idScript)
  if 1 ~= m_param[1] then
    if 5 ~= Player:GetState() then
      GoToScene(146, 207, 6)
      Dismount()
      local tObj = Enum2XByName("普洱", {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if #tObj > 0 then
        Skill.CUseSkillByID(3677, tObj[1].id)
        Sleep(500)
      end
    end
  else
    GoToScene(161, 229, 6)
    Dismount()
    Bag:UseItemByName_click("竹筒", 500, Bag:EnumRenWuItem())
  end
end

local function XW_OnMission4(idScript)
  if 1 ~= m_param[1] then
    if 5 ~= Player:GetState() then
      GoToScene(84, 235, 7)
      Dismount()
      local tObj = Enum2XByName("竹叶青", {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if #tObj > 0 then
        Skill.CUseSkillByID(3677, tObj[1].id)
        Sleep(500)
      end
    end
  else
    GoToScene(98, 248, 7)
    Dismount()
    Bag:UseItemByName_click("竹筒", 500, Bag:EnumRenWuItem())
  end
end

local function XW_GetMission()
  for i = 1, 4 do
    local nIndex, idScript = GetPlayerMission_ID(m_mission[i].id)
    if -1 ~= nIndex then
      return nIndex, idScript, m_mission[i].misFun
    end
  end
  return -1, -1, nil
end

m_mission = {
  {id = 1288, misFun = XW_OnMission1},
  {id = 1289, misFun = XW_OnMission2},
  {id = 1290, misFun = XW_OnMission3},
  {id = 1291, misFun = XW_OnMission4}
}

local function XW_OnMission()
  local debugnote = ""
  local nIndex, idScript, execMission = XW_GetMission()
  if -1 ~= nIndex then
    for j = 0, 7 do
      m_param[j] = GetMissionVariable(nIndex, j)
    end
    if 0 == m_param[0] then
      execMission(idScript)
    elseif 1 == m_param[0] then
      GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{QQMC_120522_03}", 1, 600)
      QuestFrameMissionComplete()
      Sleep(600)
    elseif 2 == m_param[0] then
      QuestFrameMissionAbnegate(idScript)
    end
  else
    GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{QQMC_120522_03}", 1, 600)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{QQMC_220526_18}", 1, 600)
    Sleep(600)
    local szItem = GetNPCEventList_Item(0)
    if "#{QQMC_120522_09}" == szItem then
      return false
    end
  end
  return true
end

local function XW_GetPlayerCha(tPlayer)
  if Target:FindBuff(tPlayer, "：变身为龙井茶") then
    return "龙井茶"
  end
  if Target:FindBuff(tPlayer, "：变身为普洱茶") then
    return "普洱茶"
  end
  if Target:FindBuff(tPlayer, "：变身为碧螺春") then
    return "碧螺春茶"
  end
  if Target:FindBuff(tPlayer, "：变身为竹叶青") then
    return "竹叶青茶"
  end
  return ""
end

local function XW_GetMyCha()
  if -1 ~= Player:GetBuff("：变身为龙井茶") then
    return "龙井茶"
  end
  if -1 ~= Player:GetBuff("：变身为普洱茶") then
    return "普洱茶"
  end
  if -1 ~= Player:GetBuff("：变身为碧螺春") then
    return "碧螺春茶"
  end
  if -1 ~= Player:GetBuff("：变身为竹叶青") then
    return "竹叶青茶"
  end
  return ""
end

local function XW_YaoQing(aHasBuff)
  local tick = GetTickCount()
  for i = #m_lastName, 1, -1 do
    local tmp = m_lastName[i]
    if tick - tmp.tick > 120000 then
      table.remove(m_lastName, i)
    end
  end
  local tPlayer = Enum2XByClass("玩家")
  for i = 1, #tPlayer do
    local tmp = tPlayer[i]
    if 0 == tmp.inteam then
      local cha = XW_GetPlayerCha(tmp)
      if "" ~= cha then
        local bHas = false
        for j = 1, #aHasBuff do
          if aHasBuff[j] == cha then
            bHas = true
          end
        end
        if false == bHas then
          local bFind = false
          for i = 1, #m_lastName do
            local tmp2 = m_lastName[i]
            if tmp.name == tmp2.name then
              bFind = true
            end
          end
          if false == bFind then
            local nowTick = GetTickCount()
            table.insert(m_lastName, {
              name = tmp.name,
              tick = nowTick
            })
            GetLuaValue("Target:SendTeamRequest('" .. tmp.name .. "');")
            PushColorMsg("邀请" .. tmp.name .. " " .. cha)
            Sleep(1000)
          end
        end
      end
    end
  end
end

local function XW_HeCha()
  g_self.name = Player:GetName()
  while true do
    local tItem = Bag:FindItemInfo("龙井茶")
    if 0 == #tItem then
      tItem = Bag:FindItemInfo("普洱茶")
    end
    if 0 == #tItem then
      tItem = Bag:FindItemInfo("碧螺春茶")
    end
    if 0 == #tItem then
      tItem = Bag:FindItemInfo("竹叶青茶")
    end
    local myBuff = XW_GetMyCha()
    if 0 == #tItem and "" == myBuff then
      PushDebugMessage("您没有喝茶道具")
      break
    end
    GoToScene(m_npc.x, m_npc.y, m_npc.sceneID)
    Dismount(1000)
    if "" ~= myBuff then
      local bIn = GetLuaValue("if Player:IsInTeam() == 1 then return 1 end return 0", "n")
      if 1 == bIn then
        local tTeam = Team:GetAllMemberInfo()
        local myIndex = Team:GetMyIndex()
        if Player:IsLeader() then
          local hasBuff = {}
          local tTiName = {}
          table.insert(hasBuff, myBuff)
          for i = 1, #tTeam do
            local tmp = tTeam[i]
            local tab = FindObjByTID(tmp.id)
            if tab and tab.name ~= g_self.name then
              local cha = XW_GetPlayerCha(tab)
              if "" ~= cha then
                local bHas = false
                for j = 1, #hasBuff do
                  if hasBuff[j] == cha then
                    bHas = true
                  end
                end
                if false == bHas then
                  table.insert(hasBuff, cha)
                else
                  table.insert(tTiName, tab.name)
                end
              else
                table.insert(tTiName, tab.name)
              end
            end
          end
          if 0 == #tTiName then
            local nCount = Team:GetMemberCount()
            if nCount > 4 then
              GetLuaValue("Player:KickTeamMember(4)")
              Sleep(2000)
            elseif 4 == nCount then
              GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
              QuestFrameOptionClicked_Item("#{QQMC_120522_04}", 1, 800)
              QuestFrameOptionClicked_Item("#{QQMC_120522_71}", 1, 800)
            else
              Team:AgreeNearJoin()
              XW_YaoQing(hasBuff)
            end
          else
            local memIndex = Team:GetIndex(tTiName[1])
            if -1 ~= memIndex then
              GetLuaValue("Player:KickTeamMember(" .. memIndex .. ")")
              Sleep(1000)
            end
          end
          local tTeam = Team:GetAllMemberInfo()
          if 1 == #tTeam then
            Team:LeaveTeam()
          else
            GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
            QuestFrameOptionClicked_Item("#{QQMC_120522_04}", 1, 800)
            QuestFrameOptionClicked_Item("#{QQMC_120522_71}", 1, 800)
          end
        else
          for i = 1, #tTeam do
            local tmp = tTeam[i]
            local tab = FindObjByTID(tmp.id)
            if tab then
              local cha = XW_GetPlayerCha(tab)
              if cha == myBuff then
                local memIndex = Team:GetIndex(tmp.name)
                if -1 ~= memIndex and myIndex > memIndex then
                  PushDebugMessage("队伍状态重复")
                  Team:LeaveTeam()
                  break
                end
              end
            end
          end
          GoToSceneNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID)
          QuestFrameOptionClicked_Item("#{QQMC_120522_04}", 1, 800)
          QuestFrameOptionClicked_Item("#{QQMC_120522_71}", 1, 800)
        end
      else
        local hasBuff = {}
        table.insert(hasBuff, myBuff)
        XW_YaoQing(hasBuff)
        Team:AgreeNearInvite()
      end
    elseif #tItem > 0 then
      Bag:UseItem(tItem[1].index, 200)
    else
      break
    end
    if IsInDebugMsg("#{QQMC_120522_112}") or IsInDebugMsg("#{QQMC_120522_118}") then
      break
    end
    Sleep(1000)
    DebugStr("喝茶中...")
  end
end

function _SMain(...)
  DeleteDebugMsg("#{QQMC_120522_112}")
  DeleteDebugMsg("#{QQMC_120522_118}")
  ClearBag()
  while true do
    if false == XW_OnMission() then
      PushColorMsg("今日清泉茗茶任务已完成")
      XW_HeCha()
      break
    end
    Sleep(100)
    DebugStr("清泉茗茶:执行中")
  end
  Team:LeaveTeam()
end

_SMain()
