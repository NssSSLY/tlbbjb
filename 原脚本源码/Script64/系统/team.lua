-- 反编译自 dfz64.dll 内嵌字节码 0055b610（unluac 2025-12-23；仅供分析）
Team = {}
Raid = {}
local m_TimeCheckTeamNear = -1
local m_TeamSteadyTime = -1

function Team:CreateTeam()
  local strText = [[
            if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then
                Player:CreateTeamSelf();
            end
        ]]
  GetLuaValue(strText)
  Sleep(100)
end

function Team:LeaveTeam()
  local strText = [[
            if Player:IsInTeam() == 1 then
                Player:LeaveTeam()
            end
        ]]
  GetLuaValue(strText)
end

function Team:UpdateData(aMember)
  local nHP, nMaxHP = GetLuaValue("local nHP = Player:GetData('HP');local nMaxHP = Player:GetData('MAXHP'); return nHP,nMaxHP", "nn")
  local myHPP = 100
  if nMaxHP > 0 then
    myHPP = nHP * 100 / nMaxHP
  end
  local myTID = Player:GetTID()
  local pos = Player:GetPos()
  for i = 1, #aMember do
    local tmp = aMember[i]
    if tmp.id == myTID then
      aMember[i].hpcur = nHP
      aMember[i].hp = myHPP
      aMember[i].hpmax = nMaxHP
      aMember[i].x = pos.x
      aMember[i].y = pos.y
      break
    end
  end
  return aMember
end

function Team:GetAllMemberInfo()
  local is_self_leader = false
  local tAllMember = EnumMemberInfo(1)
  if #tAllMember > 0 then
    local myguid = Player:GetGUID()
    if tAllMember[1].guid == myguid then
      is_self_leader = true
    end
  end
  for i = 1, #tAllMember do
    local tmp = tAllMember[i]
    tmp.isjingong = IsMenpaiJinGong(tmp.menpai)
  end
  tAllMember = self:UpdateData(tAllMember)
  return tAllMember, is_self_leader
end

function Team:GetUpdateMemberInfo()
  local tMem, isLeader = self:GetAllMemberInfo()
  return tMem, isLeader
end

function Team:GetLeaderInfo()
  local tAllMember, bIsSelfLeader = self:GetAllMemberInfo()
  if #tAllMember > 0 and tAllMember[1].sceneID >= 0 then
    local leader = tAllMember[1]
    if 0 == leader.x or 0 == leader.y then
      leader.x, leader.y = GetSceneTempPos(leader.sceneID)
    end
    return leader, bIsSelfLeader
  end
  return nil, nil
end

function Team:IsHaveDieMember()
  local bHave = false
  local szDieName = " "
  local tObj = self:GetAllMemberInfo()
  for i = 1, #tObj do
    if tObj[i].id > 0 and 0 == tObj[i].hp then
      bHave = true
      szDieName = szDieName .. tObj[i].name .. " "
    end
  end
  if " " == szDieName then
    szDieName = ""
  end
  return bHave, szDieName
end

function Team:GetAllInfo()
  local info = {}
  local strInfo = GetLuaValue("return meGetAllTeamInfo(2);", "s")
  local arrInfo = SplitString(strInfo, " ", true)
  for i = 1, #arrInfo do
    local memInfo = SplitString(arrInfo[i], "&", true)
    if #memInfo >= 4 then
      local tmp = {
        name = memInfo[1],
        index = tonumber(memInfo[2]),
        level = tonumber(memInfo[3]),
        menpai = memInfo[4]
      }
      table.insert(info, tmp)
    end
  end
  return info
end

function Team:GetAllName()
  local tObj = self:GetAllMemberInfo()
  local strTeam = Array2Text(tObj, " ", "name")
  return strTeam
end

function Team:GetMemberInfoByName(szName)
  local tObj = self:GetAllMemberInfo()
  tObj = ObjFilterByName(tObj, szName, 0)
  if #tObj > 0 then
    return tObj[1]
  end
  return {}
end

function Team:GetMemberCount(abSure)
  if nil == abSure then
    abSure = true
  end
  local nTeamCount = GetLuaValue("return DataPool:GetTeamMemberCount()", "n")
  if 0 == nTeamCount and abSure then
    local nSceneTime = GetChangeSceneTimeDiff()
    if nSceneTime < 4 then
      Sleep(2000)
      nTeamCount = GetLuaValue("return DataPool:GetTeamMemberCount()", "n")
    end
  end
  return nTeamCount
end

function Team:IsCountReady(aNeedCnt)
  if aNeedCnt <= 1 then
    return true
  end
  if aNeedCnt > 6 then
    aNeedCnt = 6
  end
  local nTeam = self:GetMemberCount()
  if aNeedCnt <= nTeam then
    return true
  end
  DebugStr("队伍不足%s人,等待组队,组队页面可设置", 2, aNeedCnt)
  return false
end

function Team:GetSurroundMember(aDistance)
  aDistance = aDistance or 9
  local szTeamName = self:GetAllName()
  local tObj = Enum2XByName(szTeamName, {
    0,
    0,
    1,
    0
  }, {-1, aDistance}, nil, 3)
  return #tObj, tObj
end

function Team:GetSurroundMember_teamdata(aDistance)
  local tObj = self:GetAllMemberInfo()
  local tmp = {}
  for i = 1, #tObj do
    if aDistance >= tObj[i].dst then
      table.insert(tmp, tObj[i])
    end
  end
  return #tmp
end

function Team:KickTeamMember(aIndex)
  if aIndex and aIndex >= 0 and aIndex <= 5 then
    GetLuaValue(fmt("Player:KickTeamMember(%d)", aIndex))
    Sleep(1000)
  end
end

function Team:IsHaveMenpaiID(aMenpaiID)
  local tMember, bIsLeader = Team:GetAllMemberInfo()
  for i = 1, #tMember do
    if tMember[i].menpai == aMenpaiID then
      return true
    end
  end
  return false
end

function Team:IsHaveMenpai(aMenpaiName)
  local menpaiID = GetMenpaiIDByName(aMenpaiName)
  if -1 ~= menpaiID then
    local strText = fmt("return meIsTeamHaveMenpai(%d)", menpaiID)
    local idx = GetLuaValue(strText, "n")
    if idx >= 0 then
      return true
    end
  end
  return false
end

function Team:GetMyIndex()
  local tMember = self:GetAllMemberInfo()
  local myTID = Player:GetTID()
  for i = 1, #tMember do
    local tmp = tMember[i]
    if tmp.id == myTID then
      return tmp.teamIndex, #tMember
    end
  end
  return -1, 0
end

function Team:GetIndex(aMemName)
  return GetLuaValue(fmt([[
	
            local TeamCount = DataPool:GetTeamMemberCount()
            if TeamCount <= 0 then return -1 end
            local strName = '%s'	
            for i = 0, TeamCount - 1 do
                local szName = DataPool:GetTeamMemInfoByIndex(i);
                if szName == strName then
                    return i
                end
            end		
            return -1
        ]], aMemName), "n")
end

function Team:IsSceneHaveFammily(aSceneID, aMenPai)
  local bHave = false
  local hpcur = 0
  local nSceneID = aSceneID or GetSceneID()
  local selfName = Player:GetName()
  local tAllMember, _ = self:GetUpdateMemberInfo()
  for i = 1, #tAllMember do
    local tmp = tAllMember[i]
    if tmp.sceneID == nSceneID and tmp.name ~= selfName and tmp.menpai == aMenPai then
      bHave = true
      if tmp.hpcur > 0 then
        hpcur = tmp.hpcur
        break
      end
    end
  end
  return bHave, hpcur
end

function Team:GetHPLeastMember(aCheckDie)
  local tAllMember, _ = self:GetUpdateMemberInfo()
  if #tAllMember > 0 then
    local nSceneID = GetSceneID()
    BubbleSort(tAllMember, "hpmax", 1)
    for i = 1, #tAllMember do
      local tmp = tAllMember[i]
      if tmp.sceneID == nSceneID and (false == aCheckDie or tmp.hpcur > 0) then
        return tmp
      end
    end
  end
  return nil
end

function Team:GetHPMostMember()
  local tAllMember, _ = self:GetAllMemberInfo()
  if #tAllMember > 0 then
    local nSceneID = GetSceneID()
    BubbleSort(tAllMember, "hpmax", 2)
    for i = 1, #tAllMember do
      local tmp = tAllMember[i]
      if tmp.sceneID == nSceneID then
        return tmp
      end
    end
  end
  return nil
end

function Team:GetMemberHPAverage()
  local tAllMember = self:GetAllMemberInfo()
  local nCnt = #tAllMember
  if #tAllMember > 0 then
    local allHP = 0
    for i = 1, #tAllMember do
      if tAllMember[i].hpmax > 0 then
        allHP = allHP + tAllMember[i].hpmax
      else
        PushDebugMessage("获取队友%s血量失败,可能不再同一地图", tAllMember[i].name)
        nCnt = nCnt - 1
      end
    end
    if nCnt > 0 then
      return allHP / nCnt
    end
  end
  return Player:GetDataInt("MAXHP")
end

function Team:GetCurrentHPMostMember()
  local tAllMember, _ = self:GetUpdateMemberInfo()
  if #tAllMember > 0 then
    local nSceneID = GetSceneID()
    BubbleSort(tAllMember, "hpcur", 2)
    for i = 1, #tAllMember do
      local tmp = tAllMember[i]
      if tmp.sceneID == nSceneID then
        return tmp.name
      end
    end
  end
  return ""
end

function Team:IsInSameScene()
  local tAllMember, _ = self:GetAllMemberInfo()
  local nSceneID = GetSceneID()
  for i = 1, #tAllMember do
    local tmp = tAllMember[i]
    if tmp.sceneID ~= nSceneID then
      return false
    end
  end
  return true
end

function Team:CheckMemberHP(aHPCmp)
  local tAllMember = self:GetUpdateMemberInfo()
  local nSceneID = GetSceneID()
  for i = 1, #tAllMember do
    local tmp = tAllMember[i]
    if tmp.sceneID == nSceneID and aHPCmp >= tmp.hp then
      return false, tmp.name
    end
  end
  return true, ""
end

function Team:CheckMemberMP(aMPCmp, aMenPai)
  local strName = self:GetAllName()
  local tAllMember = Enum2XByName(strName, {
    0,
    0,
    1,
    0
  }, nil, nil, 3)
  for i = 1, #tAllMember do
    local tmp = tAllMember[i]
    if aMPCmp > tmp.mpp and (nil == aMenPai or tmp.menpai == aMenPai) then
      return false, tmp.name
    end
  end
  return true, ""
end

function Team:CheckPetXueJiCD(aMenPai)
  local strName = self:GetAllName()
  local tAllMember = Enum2XByName(strName, {
    0,
    0,
    1,
    0
  }, nil, nil, 3)
  for i = 1, #tAllMember do
    local tmp = tAllMember[i]
    if (nil == aMenPai or tmp.menpai == aMenPai) and Target:FindBuff(tmp, "珍兽施放共生和血祭") then
      return false, tmp.name
    end
  end
  return true, ""
end

function Team:AskNearTeam()
  local szText = [[
            local szRetName = ""
            if Player:IsInTeam() == 0 then
                local tObj = meGetPlayerListTab(true)
                for j = 1, table.getn(tObj) do
                    local tmp = tObj[j]
                    if tmp.team_flag ~= 0 then
                        szRetName = szRetName .. tmp.name .. " "
                    end
                end
            end        
            return szRetName
        ]]
  local szName = GetLuaValue(szText, "s")
  local tName = Text2Table(szName, " ")
  if #tName > 0 then
    math.randomseed(GetTickCount())
    local idx = math.random(1, #tName)
    GetLuaValue("Target:SendTeamApply('" .. tName[idx] .. "');")
    Sleep(200)
  end
end

function Team:AgreeNearJoin()
  local szText = [[
        if Player:IsLeader() == 1 then
            local tObj = meGetPlayerListTab(true)
            local nCnt = DataPool:GetApplyMemberCount()
            for i = nCnt - 1, 0, -1 do
                local nNowTeamCnt = DataPool:GetTeamMemberCount()
                if nNowTeamCnt >= 6 then
                    break
                end
                local szNick, iFamily, iLevel, iCapID, iHead, iArmourID, iCuffID, iFootID, iWeaponID, _, sZoneWorldID, iFightScore, szGuildName = DataPool:GetApplyMemberInfo(i)
                for j = 1, table.getn(tObj) do
                    local tmp = tObj[j]
                    if tmp.name == szNick then
                        Player:SendAgreeJoinTeam_Apply(i)
                        DataPool:EraseApply(i)
                        break
                    end
                end
            end
        end
        ]]
  GetLuaValue(szText)
end

function Team:InviteNear()
  local szText = [[
        local strRetName = ""
        if Player:IsInTeam() == 0 or Player:IsLeader() == 1 then
            local tObj = meGetPlayerListTab(true)
            for i = 1, table.getn(tObj) do
                local tmp = tObj[i]
                if tmp.team_flag == 0 then
                    strRetName = strRetName .. tmp.name .. " "
                end
            end
        end
        return strRetName
        ]]
  local strName = GetLuaValue(szText, "s")
  local tName = Text2Table(strName, " ")
  if #tName > 0 then
    math.randomseed(GetTickCount())
    local idx = math.random(1, #tName)
    GetLuaValue("Target:SendTeamRequest('" .. tName[idx] .. "');")
    Sleep(200)
  end
end

function Team:AgreeNearInvite()
  local szText = [[
        local nRet = 0
        if Player:IsInTeam() == 0 then
            local tObj = meGetPlayerListTab(true)
            local nCnt = DataPool:GetInviteTeamCount()
            for i = nCnt - 1, 0, -1 do
                local szName, menpai, level = DataPool:GetInviteTeamMemberInfo(i, 0)
                for j = 1, table.getn(tObj) do
                    local tmp = tObj[j]
                    if tmp.name == szName then
                        Player:AgreeJoinTeam(i)
                        nRet = 1
                    end
                end
            end
        end
        return nRet
    ]]
  local isHave = GetLuaValue(szText, "b")
  return isHave
end

function Team:LeaveCheckNear()
  local num, tObj = self:GetSurroundMember(20)
  if num <= 1 then
    self:LeaveTeam()
  end
end

function Raid:GetAllMemberInfo()
  local tAllMember = EnumMemberInfo(2)
  for i = 1, #tAllMember do
    tAllMember[i].raidIndex = i
  end
  return tAllMember
end

function Raid:GetLeaderInfo()
  local tAllMember = self:GetAllMemberInfo()
  for i = 1, #tAllMember do
    if 1 == tAllMember[i].leader then
      local leader = tAllMember[i]
      if 0 == leader.x or 0 == leader.y then
        leader.x, leader.y = GetSceneTempPos(leader.sceneID)
      end
      local myguid = Player:GetGUID()
      local is_self_leader = false
      if leader.guid == myguid then
        is_self_leader = true
      end
      return leader, is_self_leader
    end
  end
  return nil, false
end

function Raid:GetUpdateMemberInfo()
  local tMem, isLeader = self:GetAllMemberInfo()
  tMem = Team:UpdateData(tMem)
  return tMem
end

function Raid:GetAllName()
  local tObj = self:GetAllMemberInfo()
  local strTeam = Array2Text(tObj, " ", "name")
  return strTeam
end

function Raid:CheckMemberHP(aHPCmp)
  local tAll = self:GetUpdateMemberInfo()
  for i = 1, #tAll do
    if aHPCmp > tAll[i].hp then
      return false
    end
  end
  return true
end

function Raid:GetLifeMenPai(strMenPai)
  local nMenPaiID = GetMenpaiIDByName(strMenPai)
  local tRaid = self:GetUpdateMemberInfo()
  local tFind = {}
  for i = 1, #tRaid do
    if tRaid[i].menpai == nMenPaiID and tRaid[i].hp > 0 then
      table.insert(tFind, tRaid[i])
    end
  end
  return tFind
end

function Raid:GetMyRaidIndex()
  local strText = "local mySquad, myIndex  = Player:GetMyRaidIndex(); return mySquad ,myIndex"
  local nGroup, myIndex = GetLuaValue(strText, "nn")
  return nGroup, myIndex
end

function Raid_GetIndex(aCmpName, atRaid)
  local strCmp = aCmpName or g_self.name
  local tRaid = atRaid or Raid:GetAllMemberInfo()
  local raidIndex = -1
  for i = 1, #tRaid do
    local tmp = tRaid[i]
    if tmp.name == strCmp then
      raidIndex = i - 1
      break
    end
  end
  while raidIndex >= 12 do
    raidIndex = raidIndex - 12
  end
  return raidIndex
end

function Raid:ExchangeMember(aSource, aDest)
  if aSource.groupIndex >= 0 and aSource.groupIndex <= 4 and aSource.teamIndex >= 0 and aSource.teamIndex <= 5 and aDest.groupIndex >= 0 and aDest.groupIndex <= 4 and aDest.teamIndex >= 0 and aDest.teamIndex <= 5 then
    GetLuaValue(fmt("Raid:ExchangeMemberPosition(%d, %d, %d, %d)", aSource.groupIndex, aSource.teamIndex, aDest.groupIndex, aDest.teamIndex))
  end
end

function Raid:GetAllYuanGong()
  local tRaid = self:GetAllMemberInfo()
  local tYG = {}
  for i = 1, #tRaid do
    if IsMenpaiJinGong(tRaid[i].menpai) == false then
      table.insert(tYG, tRaid[i])
    end
  end
  return tYG
end

function Raid:GetSelfYGIndex()
  local tYG = self:GetAllYuanGong()
  for i = 1, #tYG do
    if tYG[i].id == Player:GetTID() then
      return i
    end
  end
  return -1
end

function TeamCheckNear()
  Team:AgreeNearJoin()
  Team:LeaveCheckNear()
  Team:AgreeNearInvite()
  local nTickOut = 3000
  if 2 == g_client_type then
    nTickOut = 30000
  end
  if nTickOut < GetTickCount() - m_TimeCheckTeamNear then
    Team:InviteNear()
    Team:AskNearTeam()
    m_TimeCheckTeamNear = GetTickCount()
  end
end

function CheckAllTeamHP(aHPCmp, aHPCallback, aTimeOut)
  aTimeOut = aTimeOut or 25
  if not Team:IsHaveMenpai("峨嵋") then
    aTimeOut = 10
  end
  if not Team:CheckMemberHP(aHPCmp) then
    local nClock = os.time()
    while not Team:CheckMemberHP(aHPCmp) and not (aTimeOut < os.time() - nClock) do
      DebugStr(fmt("队员血量不足%s/100,等待%d秒补血，剩余%d秒", aHPCmp, aTimeOut, math.ceil(aTimeOut - os.time() + nClock)))
      Sleep(200)
      FubenAttack(-1)
      if 9 == Player:GetState() or aHPCallback and false == aHPCallback() then
        break
      end
    end
  else
    FubenAttack(-1)
  end
end

function CheckAllRaidHP(aHPCmp, aHPCallback, aTimeOut)
  aTimeOut = aTimeOut or 25
  local tEM = Raid:GetLifeMenPai("峨嵋")
  if 0 == #tEM then
    aTimeOut = 10
  end
  if Raid:CheckMemberHP(aHPCmp) == false then
    local nClock = os.time()
    while Raid:CheckMemberHP(aHPCmp) == false and not (aTimeOut < os.time() - nClock) do
      DebugStr(fmt("团员血量不足%s/100,等待%d秒补血，剩余%d秒", aHPCmp, aTimeOut, math.ceil(aTimeOut - os.time() + nClock)))
      Sleep(200)
      FubenAttack(-1)
      if 9 == Player:GetState() or aHPCallback and false == aHPCallback() then
        break
      end
    end
  else
    FubenAttack(-1)
  end
end

function TeamChangeLeader(aAsMenpai, aAsName)
  aAsName = aAsName or ""
  local tMember, bIsLeader = Team:GetAllMemberInfo()
  if bIsLeader then
    if "" ~= aAsName then
      for i = 1, #tMember do
        if tMember[i].name == aAsName and tMember[i].name ~= g_self.name then
          PushDebugMessage(fmt("将队长按名称交给:%s", tMember[i].name))
          GetLuaValue(fmt("Player:AppointLeader(%d)", tMember[i].teamIndex))
          Sleep(300)
          return true, #tMember
        end
      end
    elseif -1 ~= aAsMenpai then
      for i = 1, #tMember do
        if tMember[i].menpai == aAsMenpai then
          PushDebugMessage(fmt("将队长按门派交给:%s", tMember[i].name))
          GetLuaValue(fmt("Player:AppointLeader(%d)", tMember[i].teamIndex))
          Sleep(300)
          return true, #tMember
        end
      end
    end
  end
  return false, #tMember
end

function TickInitTeamSteady()
  m_TeamSteadyTime = -1
end

function IsTeamSteady(aDist, aTickOut)
  aTickOut = aTickOut or 25000
  aDist = aDist or 15
  local nowTick = GetTickCount()
  local surNum
  if aDist > 16 then
    surNum = Team:GetSurroundMember_teamdata(aDist)
  else
    surNum = Team:GetSurroundMember(aDist)
  end
  if -1 ~= m_TeamSteadyTime and nowTick > m_TeamSteadyTime or surNum >= Team:GetMemberCount() then
    m_TeamSteadyTime = -1
    return true
  else
    if -1 == m_TeamSteadyTime then
      m_TeamSteadyTime = nowTick + aTickOut
    end
    DebugStr("等待队员集合，" .. math.ceil((m_TeamSteadyTime - nowTick) / 1000) .. "秒后自动开始", 2)
  end
  return false
end
