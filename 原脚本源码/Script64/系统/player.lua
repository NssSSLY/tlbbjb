-- 反编译自 dfz64.dll 内嵌字节码 0054608a（unluac 2025-12-23；仅供分析）
Player = {}
Player = require("playerlib")

function Player:GetTID()
  return self.CGetTID()
end

function Player:GetGUID()
  return self.CGetGUID()
end

function Player:GetGUID2()
  local strGUID = GetLuaValue("return Player:GetGUID()", "s")
  local lGUID = tonumber(strGUID) or -1
  return lGUID
end

function Player:GetBangHuiID()
  return self.CGetBangMengID(1)
end

function Player:GetTongMengID()
  return self.CGetBangMengID(2)
end

function Player:GetTargetID()
  return self.CGetTargetID()
end

function Player:GetPos()
  return self.CGetPos()
end

function Player:GetState()
  return GetPlayerState()
end

function Player:GetFightPetGUID()
  return self.CGetFightPetGUID()
end

function Player:GetDataInt(aParam)
  return GetLuaValue(fmt("return Player:GetData([[%s]])", aParam), "n")
end

function Player:GetHP()
  local nHP = self:GetDataInt("HP")
  return nHP
end

function Player:GetMP()
  local nMP = self:GetDataInt("MP")
  return nMP
end

function Player:GetRage()
  if 13 == g_self.menpai then
    return Player:GetDataInt("ENG")
  end
  return Player:GetDataInt("RAGE")
end

function Player:GetHPP()
  local nHP, nMaxHP = GetLuaValue("local nHP = Player:GetData('HP');local nMaxHP = Player:GetData('MAXHP'); return nHP,nMaxHP", "nn")
  if type(nHP) ~= "number" or type(nMaxHP) ~= "number" then
    return 100
  end
  if nMaxHP > 0 then
    local nHPPercent = nHP * 100 / nMaxHP
    return nHPPercent
  end
  return 100
end

function Player:GetMPP()
  local nMP, nMaxMP = GetLuaValue("local nMP = Player:GetData('MP');local nMaxMP = Player:GetData('MAXMP'); return nMP,nMaxMP", "nn")
  if type(nMP) ~= "number" or type(nMaxMP) ~= "number" then
    return 100
  end
  if nMaxMP > 0 then
    local nMPPercent = nMP * 100 / nMaxMP
    return nMPPercent
  end
  return 100
end

function Player:GetMoney(aGetType)
  if 2 == aGetType then
    return GetLuaValue("local money = Player:GetData('MONEY_JZ') return money", "n")
  else
    return GetLuaValue("local money = Player:GetData('MONEY') return money", "n")
  end
end

function GetPlayerVipLevel()
  return GetLuaValue([[
        local level = DataPool:GetAccVipLevel()
        level = level or 0
        return level
    ]], "n")
end

function Player:GetMaxMoney(aLevel)
  local nLevel = aLevel or self:GetDataInt("LEVEL")
  if nLevel >= 100 then
    nLevel = 100
  end
  local maxMoney = nLevel * nLevel
  local vipLevel = GetPlayerVipLevel()
  local vipTable = {
    [4] = 0.3,
    [5] = 0.4,
    [6] = 0.5,
    [7] = 0.6,
    [8] = 0.8,
    [9] = 1
  }
  if vipTable[vipLevel] then
    maxMoney = maxMoney + maxMoney * vipTable[vipLevel]
  end
  return math.floor(maxMoney)
end

function Player:GetMenPaiID()
  return self:GetDataInt("MEMPAI")
end

function Player:GetMySex()
  return GetLuaValue("return Player:GetMySex();", "n")
end

function Player:GetName()
  local szName = GetLuaValue("return Player:GetName();", "s")
  g_self.name = szName
  return szName
end

function Player:IsWaiGong()
  local bWaiGong = GetLuaValue("local n1 = Player:GetData('ATT_PHYSICS');local n2 = Player:GetData('ATT_MAGIC'); if n1 > n2 then return 1 end return 0 ", "b")
  return bWaiGong
end

function Player:IsJinGong()
  g_self.menpai = self:GetMenPaiID()
  g_self.isjingong = IsMenpaiJinGong(g_self.menpai)
  return g_self.isjingong, g_self.menpai
end

function Player:GetAttackAttr()
  local strText = [[
            local iIceAttack  		= Player:GetData( "ATTACKCOLD" );
            local iFireAttack 		= Player:GetData( "ATTACKFIRE" );
            local iThunderAttack	= Player:GetData( "ATTACKLIGHT" );
            local iPoisonAttack		= Player:GetData( "ATTACKPOISON" );
            return iIceAttack,iFireAttack,iThunderAttack,iPoisonAttack
        ]]
  local iIceAttack, iFireAttack, iThunderAttack, iPoisonAttack = GetLuaValue(strText, "nnnn")
  local tmp = {}
  table.insert(tmp, {
    name = "冰",
    attr = iIceAttack,
    index = 1
  })
  table.insert(tmp, {
    name = "火",
    attr = iFireAttack,
    index = 2
  })
  table.insert(tmp, {
    name = "玄",
    attr = iThunderAttack,
    index = 3
  })
  table.insert(tmp, {
    name = "毒",
    attr = iPoisonAttack,
    index = 4
  })
  BubbleSort(tmp, "attr", 2)
  return tmp
end

function Player:GetPKValue()
  return self:GetDataInt("PKVALUE")
end

function Player:YuanBaoToTicket(aCount)
  GetLuaValue(fmt("Player:YuanBaoToTicket(%d);", aCount))
  Sleep(100)
end

function Player:IsInTeam(abSure)
  if nil == abSure then
    abSure = true
  end
  local isLeader = GetLuaValue("return Player:IsInTeam()", "b")
  if not isLeader and abSure then
    local nSceneTime = GetChangeSceneTimeDiff()
    if nSceneTime < 4 then
      Sleep(2000)
      isLeader = GetLuaValue("return Player:IsInTeam()", "b")
    end
  end
  return isLeader
end

function Player:IsInRaid(abSure)
  if nil == abSure then
    abSure = true
  end
  local isLeader = GetLuaValue("return Player:IsInRaid()", "b")
  if not isLeader and abSure then
    local nSceneTime = GetChangeSceneTimeDiff()
    if nSceneTime < 4 then
      Sleep(2000)
      isLeader = GetLuaValue("return Player:IsInRaid()", "b")
    end
  end
  return isLeader
end

function Player:IsLeader(abSure)
  if nil == abSure then
    abSure = true
  end
  local nLeader = GetLuaValue("local leader = tonumber(Player:IsLeader()) return leader", "n")
  if 0 == nLeader and abSure then
    local nSceneTime = GetChangeSceneTimeDiff()
    if nSceneTime < 4 then
      Sleep(2000)
      nLeader = GetLuaValue("local leader = tonumber(Player:IsLeader())  return leader", "n")
    end
  end
  return 1 == nLeader
end

function Player:IsLeader_m()
  return DoSystem(19)
end

function Player:IsFollow(abSure)
  return IsPlayerFollow(abSure)
end

function Player:IsFollow_m()
  return DoSystem(20)
end

function Player:TeamFollow(aFollow, aSleep)
  if aFollow then
    if self:IsFollow() == false then
      GetLuaValue("if Player:IsLeader() == 1 then Player:TeamFrame_AskTeamFollow(); end")
      if aSleep then
        Sleep(aSleep)
      end
    end
  elseif self:IsFollow() then
    GetLuaValue("Player:StopFollow();")
    if aSleep then
      Sleep(aSleep)
    end
  end
end

function Player:GetBuff(aBuffName)
  return GetLuaValue("return mePlayerGetBuff([[" .. aBuffName .. "]]);", "nsn")
end

function Player:DispelBuffByName(aBuffName)
  return GetLuaValue("return mePlayerDispelBuff([[" .. aBuffName .. "]]);", "b")
end

return Player
