-- 反编译自 dfz64.dll 内嵌字节码 00543797（unluac 2025-12-23；仅供分析）
Pet = {}

function Pet:GetSelfPet()
  local selfTID = Player:GetTID()
  local tPet = Enum2XByClass("珍兽", {0, -1})
  for i = 1, #tPet do
    if tPet[i].petzrid == selfTID then
      return tPet[i]
    end
  end
  return nil
end

function Pet:GetTID()
  local tpet = self:GetSelfPet()
  if tpet then
    return tpet.id
  end
  return -1
end

function Pet:GetLevel(aGUID)
  return GetLuaValue(fmt("return mePetGetLevel(%d)", aGUID), "n")
end

function Pet:Feed(idx)
  GetLuaValue(fmt("mePetFeed(%d);", idx))
  Sleep(120)
end

function Pet:Relax(aSleep)
  if 0 ~= Player:GetFightPetGUID() then
    local brelax = GetLuaValue("return mePetRelax();", "b")
    Sleep(100)
    if aSleep then
      Sleep(aSleep)
    end
    return false
  end
  return true
end

function Pet:CheckRelax(aID, aType)
  local bRelax = false
  aType = aType or 1
  local tpet = self:GetSelfPet()
  if tpet then
    if 1 == aType then
      if tpet.id == aID then
        bRelax = true
        self:Relax()
      end
    elseif 2 == aType and tpet.target == aID then
      bRelax = true
      self:Relax()
    end
  end
  return bRelax
end

function Pet:CheckBuff(aBuff)
  local tpet = Pet:GetSelfPet()
  if tpet then
    local tBuff = EnumObjBuff(tpet)
    for i = 1, #tBuff do
      if string.find(tBuff[i], aBuff, nil, true) then
        return true
      end
    end
  end
  return false
end

function Pet:GetMaxCount()
  local maxNum = 10
  local mylevel = Player:GetDataInt("LEVEL")
  if type(mylevel) ~= "number" then
    return 3
  end
  local MaxCount = 0
  if mylevel < 21 then
    MaxCount = 2
  elseif mylevel < 41 then
    MaxCount = 3
  elseif mylevel < 61 then
    MaxCount = 4
  elseif mylevel < 81 then
    MaxCount = 5
  else
    MaxCount = 6
  end
  MaxCount = MaxCount + Player:GetDataInt("PET_EXTRANUM")
  if maxNum < MaxCount then
    MaxCount = maxNum
  end
  return MaxCount
end

function Pet:GetCurrentCount()
  return GetLuaValue("return Pet:GetPet_Count();", "n")
end

function Pet:GetBasic(aIndex)
  return GetLuaValue(fmt("return mePetGetBasic(%d)", aIndex), "n")
end

function Pet:GetSavvy(aIndex)
  return GetLuaValue(fmt("return mePetGetSavvy(%d)", aIndex), "n")
end

function Pet:Free(aIndex)
  GetLuaValue(fmt("mePetFree_Confirm(%d)", aIndex))
end

function Pet:Restore()
  GetLuaValue("mePetRestore();")
end

function Pet:GetAllInfo()
  local allPet = {}
  local strAllPet = GetLuaValue("return meGetAllPet()", "s")
  local strArr = SplitString(strAllPet, " ", true)
  for i = 1, #strArr do
    local infoArr = SplitString(strArr[i], "&")
    if #infoArr >= 9 then
      local tmp = {}
      tmp.index = tonumber(infoArr[1]) or -1
      tmp.guid = tonumber(infoArr[2]) or -1
      tmp.maxhp = tonumber(infoArr[3]) or -1
      tmp.name = infoArr[4]
      tmp.on = infoArr[5]
      tmp.level = tonumber(infoArr[6]) or -1
      tmp.wuxing = tonumber(infoArr[7]) or -1
      tmp.gengu = tonumber(infoArr[8]) or -1
      tmp.org_name = infoArr[9]
      if -1 ~= tmp.index and -1 ~= tmp.guid and -1 ~= tmp.maxhp and -1 ~= tmp.level then
        table.insert(allPet, tmp)
      end
    end
  end
  return allPet
end

function Pet:AddtAttribute()
  local szText = [[
        for i = 0, 9 do
            if Pet:IsPresent(i) then
                local cntPot = Pet:GetPotential(i)
                if cntPot > 0 then
                    local nTraitID = Pet:GetAttackTraitID(i)
                    if nTraitID == 12 then
                        Pet:Add_Attribute(i, 0, cntPot, 0, 0, 0)
                    elseif nTraitID == 11 then
                        Pet:Add_Attribute(i, cntPot, 0, 0, 0, 0)
                    end
                end
            end
        end
    ]]
  if CheckMibao(nil) then
    GetLuaValue(szText)
  end
end

function HuDaoPet()
  local tObj = Enum2XByName("护岛神兽", {
    0,
    1,
    0,
    0
  }, {0, -1}, 1, 0)
  if #tObj > 0 then
    local tmp = tObj[1]
    if tmp.dst < 5 then
      DebugStr("护岛神兽:隐身躲避", 3)
      Dismount()
      Pet:Relax(200)
      Skill:UseName("初级隐遁", 1000)
      while -1 ~= Player:GetBuff("初级隐身") do
        Sleep(300)
      end
    end
  end
end

function OnCatch(aCatchInfo, aFilter, aMoveCB)
  local move_cb = aMoveCB or MoveCallback_InScene
  local bCatch = false
  local curScene = GetSceneID()
  local npcName = HandleText_AddFuHao(aCatchInfo.petName)
  local tPet = Enum2XByName(npcName, {
    1,
    0,
    0,
    0
  }, nil, 1, 3)
  tPet = ObjTickFilter(tPet, aFilter, 30000)
  if #tPet > 0 then
    bCatch = true
    DeleteDebugMsg("#{ResultText_127}")
    CDG:checkHP_Pet()
    local tar = tPet[1]
    local startTick = GetTickCount()
    
    local function loop_cb()
      if GetTickCount() - startTick > 30000 then
        return false
      end
      return CheckDieState()
    end
    
    MoveTo(tar.x, tar.y, curScene, nil, nil, loop_cb, move_cb)
    Dismount()
    CDG:checkHP_Pet()
    Skill:UseSkillByName("捕兽", tar.id, nil, nil, 500)
    PlayerStateTimeOut(2, 5)
    PlayerStateTimeOut(5, 60)
    if IsInDebugMsg("#{ResultText_127}") then
      bCatch = false
      aFilter = ObjTickPush(aFilter, tar.id)
    end
    CDG:checkHP_Pet()
  end
  return bCatch, aFilter
end

function CatchPet(aCatchInfo, aCallBack)
  local bIs = g_pick.ispick
  g_pick.ispick = false
  local sklTbl = CDG.skill_attack
  local sklComb1 = CDG.skill_comb1
  local sklComb2 = CDG.skill_comb2
  if aCatchInfo.useSkill then
  else
    CDG.skill_attack = {}
  end
  CDG.skill_comb1 = {}
  CDG.skill_comb2 = {}
  CDG.attack = true
  CDG.sceneName = aCatchInfo.sceneName
  CDG.sceneID = aCatchInfo.sceneID
  if aCatchInfo.attackMode == nil then
    CDG.attackMode = "打死换怪"
    if g_self.isjingong and CDG.pet1.GUID > 0 then
      CDG.attackMode = "宠拉人打"
    end
  else
    CDG.attackMode = aCatchInfo.attackMode
  end
  CDG.pos = aCatchInfo.pos
  CDG.posRadius = 15
  CDG.buji = false
  if aCatchInfo.attackName and aCatchInfo.attackName ~= "" then
    CDG.targetName = HandleText_AddFuHao(aCatchInfo.attackName)
  else
    CDG.targetName = ""
  end
  CDG.targetOwer = "红绿"
  CDG.tragetSelect = true
  CDG.die.out = true
  CDG.callfun = aCallBack
  CDG:OnStart()
  g_pick.ispick = bIs
  CDG.skill_attack = sklTbl
  CDG.skill_comb1 = sklComb1
  CDG.skill_comb2 = sklComb2
end

return Pet
