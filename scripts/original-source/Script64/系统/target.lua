-- 反编译自 dfz64.dll 内嵌字节码 0055a49e（unluac 2025-12-23；仅供分析）
Target = {}
if m_check_scene_tick_jgyc == nil then
  m_check_scene_tick_jgyc = GetTickCount() - 600000
end
if nil == m_canuse_jgyc then
  m_canuse_jgyc = 0
end

function ClearTick_CheckJGYC()
  m_check_scene_tick_jgyc = GetTickCount() - 600000
end

function JGYCSkillCanUse()
  if GetTickCount() - m_check_scene_tick_jgyc > 60000 then
    local curScene = GetCurrentSceneName()
    curScene = string.gsub(curScene, "1线", "")
    curScene = string.gsub(curScene, "2线", "")
    local strCanUse = " 敦煌 嵩山 雁南 雁北 大军草料场 摩崖洞 草原 水晶湖 辽西 长白山 黄龙府 雪狼湖 先王坟 银皑雪原 \n     燕王古墓一层 燕王古墓二层 燕王古墓三层 燕王古墓四层 燕王古墓五层 燕王古墓六层 燕王古墓七层 燕王古墓八层 燕王古墓九层 \n     太湖 镜湖 西湖 龙泉 黄龙洞 武夷 清源 清源山洞 剑冢 琼州 海贼洞 苗人洞 梅岭 南海 \n     剑阁 无量山 洱海 温泉洞 苍山 野人沟 天坑树洞 石林 玉溪 桃花源 白沙盐坑 盐湖 南诏 苗疆 \n     高昌 塔里木 大宛 撒马尔罕 昆仑山 高昌迷宫 火焰山 火焰谷 塔克拉玛干 汗血岭 圣火宫 昆仑福地 \n     秦皇地宫一层 秦皇地宫二层 秦皇地宫三层 秦皇地宫四层 圣兽山 \n     漠南青原 忘川花海 天岐南淮 林海溪谷 水月洞天 大鲲遗骸 玄海 苍梧秘境 \n     沁水丹林 云遥鹊岭 \n     千帆寨 古今亭 枯荣道 望风古原 剑兰坡 余霞港 星渔湾 冷雁横川 云梦泽 碧笋春林 雨竹岗 苍梧秘境 "
    if "" ~= curScene and string.find(strCanUse, " " .. curScene .. " ", nil, true) then
      m_canuse_jgyc = 1
      DoSystem(1007, Skill.baseID_YC)
    else
      m_canuse_jgyc = 0
      DoSystem(1007, -1)
    end
    m_check_scene_tick_jgyc = GetTickCount()
  end
  return m_canuse_jgyc
end

function Target:Select(aTid, aSleep)
  if type(aTid) ~= "number" or aTid < 0 then
    return
  end
  CallFun(4, aTid)
  if aSleep then
    Sleep(aSleep)
  end
end

function Target:StopAttack(aSleep)
  local bIsAttack = false
  if 7 == Player:GetState() then
    bIsAttack = true
    Skill.CUseSkillByID_fb(-1, -1, -1, -1, Player:GetTID())
    if aSleep then
      Sleep(aSleep)
    end
  end
  return bIsAttack
end

function Target:Attack(aTid, aSleep, aSelect, aSPMode, aJGYC)
  aSleep = aSleep or 300
  if aTid and aTid >= 0 and (7 ~= Player:GetState() or Player:GetTargetID() ~= aTid) then
    if aSelect then
      self:Select(aTid)
    end
    if aJGYC and g_self.isjingong and Skill.baseID_YC > 0 and 1 == JGYCSkillCanUse() then
      Skill:UseID(Skill.baseID_YC, aTid, -1, -1)
      if aSleep then
        Sleep(aSleep)
      end
    else
      Skill:UseSkillByID(Skill.baseID, aTid, nil, nil, aSleep)
    end
    return true
  end
  return false
end

function Target:PetAttack(aTargetID)
  if 0 ~= Player:GetFightPetGUID() then
    local pet = Pet:GetSelfPet()
    if pet and (7 ~= pet.state or pet.target ~= aTargetID) then
      local selfId = Player:GetTID()
      Skill.CUseSkillByID2(-1, aTargetID, -1, -1, selfId)
      Sleep(300)
    end
  end
end

function Target:FindBuff(aTarget, aBuffName)
  local tStr = EnumObjBuff(aTarget)
  local bfind = false
  local buff = ""
  local buff2 = ""
  if "坐骑：" == aBuffName then
    buff2 = "翅膀："
  end
  for i = 1, #tStr do
    if string.find(tStr[i], aBuffName, nil, true) or "" ~= buff2 and string.find(tStr[i], buff2, nil, true) then
      bfind = true
      buff = tStr[i]
      break
    end
  end
  return bfind, buff
end

function Target:GetSpecialBuff(aTarget)
  local bKongZhi = false
  local bFangDa = false
  local bWuDi = false
  local bZuoQi = false
  local strWuDi = {
    "不可被攻击",
    "护体：免疫控制和伤害",
    "传送保护：无敌",
    "呆若木鸡：状态",
    "神佑：不会受到伤害"
  }
  local tStr = EnumObjBuff(aTarget)
  for i = 1, #tStr do
    if false == bKongZhi and (StateHasShiMing(tStr[i]) or StateHasSanGong(tStr[i]) or StateHasFengXue(tStr[i]) or StateHasHunShui(tStr[i]) or StateHasMabi(tStr[i]) or StateHasFengYin(tStr[i]) or StateHasOthreKongZhi(tStr[i])) then
      bKongZhi = true
      break
    end
    if false == bFangDa and string.find(tStr[i], "虚弱：所受伤害放大", nil, true) then
      bFangDa = true
    end
    if false == bZuoQi then
      if string.find(tStr[i], "坐骑：", nil, true) then
        bZuoQi = true
      elseif string.find(tStr[i], "翅膀：", nil, true) then
        bZuoQi = true
      end
    end
    if false == bWuDi then
      for j = 1, #strWuDi do
        if string.find(tStr[i], strWuDi[j], nil, true) then
          bWuDi = true
        end
      end
    end
  end
  return bKongZhi, bFangDa, bWuDi, bZuoQi
end
