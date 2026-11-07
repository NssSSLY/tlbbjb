-- 反编译自 dfz64.dll 内嵌字节码 00555832（unluac 2025-12-23；仅供分析）
Skill = {}
Skill = require("skilllib")
Skill.skill = {}
Skill.miji = {}
Skill.skill_kongzhi = {}
Skill.skill_jinji = {}
Skill.baseID = 0
Skill.baseID_YC = 0
Skill.use_pet_tick = -1
Skill.use_pet_tick_ky = -1
m_skill_sceneID = -1
if m_skill_check_scene_tick == nil then
  m_skill_check_scene_tick = -1
end

function Skill:RefreshMijiSkill()
  self.miji = {}
  local strText = [[
        local Index = %d
        local theAction = EnumAction(Index, "combobook")
        if (theAction:GetID() ~= 0) then
            local skill1, skill2, skill3 = Player:GetComboBookInfo(Index, "comboskill")
            return skill1, skill2, skill3
        end
        return -1,-1,-1
        ]]
  for i = 0, 2 do
    local skill1, skill2, skill3 = GetLuaValue(fmt(strText, i), "nnn")
    self.miji[i + 1] = {}
    self.miji[i + 1][1] = skill1
    self.miji[i + 1][2] = skill2
    self.miji[i + 1][3] = skill3
  end
end

function Skill:GetYCBaseSkill()
  if -1 == g_self.menpai then
    PlayerDataInit()
  end
  if 0 == g_self.menpai then
    self.baseID_YC = 4742
  elseif 1 == g_self.menpai then
    self.baseID_YC = 4743
  elseif 2 == g_self.menpai then
    self.baseID_YC = 4744
  elseif 7 == g_self.menpai then
    self.baseID_YC = 4745
  elseif 10 == g_self.menpai then
    self.baseID_YC = 4746
  end
end

function Skill:GetJinJiSkill()
  self.skill_jinji = {}
  for i = 1, #self.skill do
    local tmp = self.skill[i]
    if not (tmp.attack and tmp.baseskl == false and tmp.id >= 274) or tmp.name == "昭君出塞" or tmp.name == "笑里藏刀" or tmp.name == "金顶绵掌" or tmp.name == "西子捧心" or tmp.name == "斩情诀" then
    elseif tmp.name == "定海神针" or tmp.name == "桃花阵" or tmp.name == "八阵图" or tmp.name == "诛仙阵" or tmp.name == "江行初雪" then
    elseif tmp.name == "佛光普照" then
    elseif tmp.name == "静影沉璧" then
    elseif tmp.name == "两仪剑" then
    elseif tmp.name == "天马飞瀑" then
    elseif tmp.name == "太渊十三剑" then
    elseif tmp.name == "连珠腐尸毒" or tmp.name == "金石俱焚" then
    elseif tmp.name == "三阳开泰" then
    elseif tmp.name == "指点江山" then
    elseif tmp.name == "含沙射影" then
    elseif tmp.name == "暗器连击" then
    elseif -1 == tmp.cdidx and string.find(tmp.name, "级）") then
    elseif 2 == tmp.consume_type and tmp.consume == 500 then
    else
      table.insert(self.skill_jinji, tmp)
    end
  end
end

function Skill:GetKongZhiSkill()
  self.skill_kongzhi = {}
  for i = 1, #self.skill do
    local tmp = self.skill[i]
    if tmp.kongzhi then
      tmp.ex_canattak = true
      tmp.ex_yunqi = false
      tmp.ex_yunqi_state = ""
      if tmp.name == "画地为牢" or tmp.name == "揽雀尾" or tmp.name == "地狱火" then
        tmp.ex_canattak = false
      end
      if tmp.name == "八阵图" or tmp.name == "如封似闭" then
        tmp.ex_yunqi = true
      end
      if tmp.name == "诛仙阵" then
        tmp.ex_yunqi = true
        tmp.ex_yunqi_state = "江行初雪"
      end
      table.insert(self.skill_kongzhi, tmp)
    end
  end
end

function Skill:RefreshSkill()
  self.baseID = 0
  self:RefreshMijiSkill()
  self.skill = self.CEnumSkill()
  for i = 1, #self.skill do
    local tmp = self.skill[i]
    if tmp.baseskl and tmp.attack then
      self.baseID = tmp.id
      break
    end
  end
  self:GetYCBaseSkill()
  self:GetJinJiSkill()
  self:GetKongZhiSkill()
end

function Skill:GetJinGongFarSkill()
  local skl = {}
  if g_self.isjingong then
    for i = 1, #Skill.skill do
      local tmp = Skill.skill[i]
      if tmp.attack == true and tmp.dist > 12 and tmp.kongzhi == false then
        table.insert(skl, tmp)
      end
    end
  end
  return skl
end

function Skill:GetSkillByID(aSkillID)
  for i = 1, #Skill.skill do
    local tmp = Skill.skill[i]
    if tmp.id == aSkillID then
      return tmp
    end
  end
  return nil
end

function Skill:GetSkillByName(aSkillName)
  for i = 1, #Skill.skill do
    local tmp = Skill.skill[i]
    if tmp.name == aSkillName then
      return tmp
    end
  end
  return nil
end

function Skill:CanUseByCdIdx(aCdIdx)
  if -1 == aCdIdx then
    return true
  end
  return self.CGetCD(aCdIdx) <= 0
end

function Skill:IsMiJi(aSkill)
  if aSkill and -1 ~= aSkill.id then
    for i = 1, #self.miji do
      for j = 1, #self.miji[i] do
        if self.miji[i][j] == aSkill.id then
          return i - 1, j - 1
        end
      end
    end
  end
  return -1, -1
end

function Skill:CanUseGuiGuZhenFa(aSkill)
  if 12 == g_self.menpai then
    local tSkillName = {
      "聚星阵·长生",
      "绝星阵·破军",
      "聚星阵·阴阳",
      "绝星阵·七杀",
      "绝星阵·贪狼"
    }
    local tName = {
      g_self.name .. "的七杀星阵",
      g_self.name .. "的长生星阵",
      g_self.name .. "的破军星阵",
      g_self.name .. "的贪狼星阵",
      g_self.name .. "的阴阳星阵"
    }
    if FindTableValue(tSkillName, aSkill.name) then
      for i = 1, 2 do
        local tObj = Enum2XByClass("阵法")
        local tZhenFa = GetTableFieldValue(tObj, "name", tName)
        if #tZhenFa > 0 then
          return false
        end
        Sleep(300)
      end
    end
  end
  return true
end

function Skill:CanUseSkill(aSkill)
  if aSkill and self:CanUseByCdIdx(aSkill.cdidx) then
    local bookIndex, skillIndex = self:IsMiJi(aSkill)
    if -1 ~= bookIndex then
      if GetMiJiSkillIndex(bookIndex) == skillIndex and Player:GetMP() >= 300 then
        return true
      end
      return false
    end
    local bCanUse = true
    if 0 == aSkill.consume_type then
      local minMP = 1000
      if aSkill.consume > -1 and Player:GetMP() < aSkill.consume then
        bCanUse = false
      elseif aSkill.name == "暗器投掷" or aSkill.name == "暗器打穴" or aSkill.name == "暗器护体" or aSkill.name == "暗器连击" or aSkill.name == "诛仙万象" then
        if Player:GetMPP() < 5 then
          bCanUse = false
        end
      elseif -1 == aSkill.consume and minMP > Player:GetMP() then
        bCanUse = false
      end
    elseif 1 == aSkill.consume_type then
      if aSkill.name == "同生共死" and Player:GetHPP() < 20 then
        bCanUse = false
      elseif aSkill.name == "如封似闭" and Player:GetHPP() < 6 then
        bCanUse = false
      end
    elseif 2 == aSkill.consume_type then
      if aSkill.consume > -1 and Player:GetRage() < aSkill.consume then
        bCanUse = false
      end
    elseif 3 == aSkill.consume_type then
    elseif 4 == aSkill.consume_type then
      local minMP = 1000
      if minMP > Player:GetMP() then
        bCanUse = false
      elseif 2 == g_self.menpai then
        if Player:GetDataInt("STRIKEPOINT") < aSkill.consume then
          bCanUse = false
        end
      elseif 14 == g_self.menpai and Player:GetDataInt("CONGRENPOINT") < aSkill.consume then
        bCanUse = false
      end
    end
    if bCanUse and aSkill.buff_need ~= "" and -1 == Player:GetBuff(aSkill.buff_need) then
      bCanUse = false
    end
    if bCanUse and self:CanUseGuiGuZhenFa(aSkill) == false then
      bCanUse = false
    end
    return bCanUse
  end
  return false
end

function Skill:UseID(aSkillID, aTargetID, aPosX, aPosY)
  if g_self.isjingong then
    self.CUseSkillByID_fb(aSkillID, aTargetID, aPosX, aPosY, Player:GetTID())
  else
    self.CUseSkillByID_fb(aSkillID, aTargetID, aPosX, aPosY, Player:GetTID())
  end
end

function SkillIsFubenScene()
  if -1 == m_skill_check_scene_tick then
    m_skill_check_scene_tick = GetTickCount() - 600000
  end
  if GetTickCount() - m_skill_check_scene_tick > 30000 then
    m_skill_sceneID = GetSceneID()
    m_skill_check_scene_tick = GetTickCount()
  end
  if IsSafeSceneID(m_skill_sceneID) then
    return true
  elseif IsInFubenScene(m_skill_sceneID) then
    return true
  end
  return false
end

function Skill:Use(aSkill, aTargetID, aPosX, aPosY)
  if SkillIsFubenScene() then
    self.CUseSkillByID(aSkill.id, aTargetID, aPosX, aPosY)
    return
  end
  if not g_self.isjingong or 0 == aSkill.type then
  elseif 1 == aSkill.type then
    if aTargetID >= 0 and aSkill.id >= 0 and aSkill.fdist <= 12 then
      local tar = FindObjByTID(aTargetID)
      if tar then
        local cmpDist = aSkill.fdist
        if cmpDist < tar.dst then
          OpenPackage(aTargetID)
          if tar.dst > 3.5 then
            if 0 ~= Player:GetFightPetGUID() then
              self.CUseSkillByID_fb(-1, aTargetID, aPosX, aPosY, Player:GetTID())
            end
            return
          end
          Sleep(100)
        end
      end
    end
  elseif (2 == aSkill.type or 6 == aSkill.type) and aPosX > 0 and aPosY > 0 and aSkill.fdist > 0 then
    local nDist = GetDist(aPosX, aPosY)
    if nDist > aSkill.fdist then
      PushColorMsg(aSkill.name .. ":距离过远" .. nDist)
      RunTo(aPosX, aPosY, 1, 500)
    end
  end
  self:UseID(aSkill.id, aTargetID, aPosX, aPosY)
end

function Skill:CheckUse(aSkill, aTargetID, aPosX, aPosY, aSleep)
  local bUse = false
  if not aSkill then
    return bUse
  end
  if self:CanUseSkill(aSkill) then
    if aSkill.name == "八列之舞" then
      if -1 ~= aTargetID and g_self.name ~= "" then
        local tObj = EnumEnvObj()
        local tTar = ObjFilterByTID(tObj, aTargetID)
        local tLRE = ObjFilterByStrClass(tObj, "阵法", 0)
        tLRE = ObjFilterByName(tLRE, g_self.name .. "的离人偶", 0)
        if #tTar > 0 then
          if #tLRE > 0 then
            local t1 = tTar[1]
            local t2 = tLRE[1]
            local dist = GetDist(t1.x, t1.y, t2.x, t2.y)
            if dist <= 3 then
              return false
            end
          elseif -1 == aPosX or -1 == aPosY then
            aPosX = tTar[1].x
            aPosY = tTar[1].y
          end
        else
          PushDebugMessage("八列之舞离人偶:没有找到指定目标")
          return false
        end
      else
        PushDebugMessage("八列之舞离人偶:没有指定目标")
        return false
      end
    end
    bUse = true
    if aSkill.diandi and (-1 == aPosX or -1 == aPosY) then
      if -1 == aTargetID then
        local pos = Player:GetPos()
        aPosX = pos.x
        aPosY = pos.y
      else
        local obj = FindObjByTID(aTargetID)
        if obj then
          aPosX = obj.x
          aPosY = obj.y
        end
      end
    end
    self:Use(aSkill, aTargetID, aPosX, aPosY)
    if aSleep then
      Sleep(aSleep)
    end
    local tSkillName = {
      "聚星阵·长生",
      "绝星阵·破军",
      "聚星阵·阴阳",
      "绝星阵·七杀",
      "绝星阵·贪狼"
    }
    if FindTableValue(tSkillName, aSkill.name) then
      Sleep(300)
    end
  end
  return bUse
end

function Skill:UseSkillByID(aSkillID, aTargetID, aX, aY, aSleep)
  aTargetID = aTargetID or -1
  aX = aX or -1
  aY = aY or -1
  local skill = self:GetSkillByID(aSkillID)
  return self:CheckUse(skill, aTargetID, aX, aY, aSleep)
end

function Skill:UseSKillRefresh(aSkillName, aTargetID)
  local allSkill = self.CEnumSkill()
  for i = 1, #allSkill do
    local tmp = allSkill[i]
    if tmp.name == aSkillName then
      self.CUseSkillByID(tmp.id, aTargetID, -1, -1)
      return true
    end
  end
  return false
end

function Skill:UseSkillByName(aSkillName, aTargetID, aX, aY, aSleep)
  aTargetID = aTargetID or -1
  if nil == aY and aX then
    if -1 ~= aX then
      aSleep = aX
    end
    aX = nil
  end
  aX = aX or -1
  aY = aY or -1
  local skill = self:GetSkillByName(aSkillName)
  return self:CheckUse(skill, aTargetID, aX, aY, aSleep)
end

function Skill:UseName(aSkillName, aSleep)
  aSleep = aSleep or 200
  return self:UseSkillByName(aSkillName, -1, -1, -1, aSleep)
end

function Skill:UseZuHe(aSkillArr, aUseMode, aTargetID, aObj)
  local tSkl = aSkillArr
  local n = #tSkl
  if n <= 0 then
    return
  end
  if 0 == aUseMode.mode then
    return
  elseif 1 == aUseMode.mode then
    local bCanUse = true
    if not aUseMode.using then
      for i = 1, n do
        local skill = self:GetSkillByName(tSkl[i].text)
        if skill and self:CanUseSkill(skill) == false then
          bCanUse = false
          break
        end
      end
    end
    if bCanUse then
      aUseMode.using = true
      local bUse = false
      for i = 1, n do
        if 0 == tSkl[i].data then
          if Skill:UseSkillByName(tSkl[i].text, aTargetID, nil, nil, 300) then
            bUse = true
            break
          else
            tSkl[i].data = 1
          end
        end
      end
      if not bUse then
        aUseMode.using = false
        for i = 1, #tSkl do
          tSkl[i].data = 0
        end
      end
    end
  else
    if 2 == aUseMode.mode then
      if nil == aObj or 0 == #aObj then
        return
      end
      local tmp = ObjFilterByInt(aObj, 6, 2, "dst")
      if #tmp > 4 then
        for i = 1, n do
          math.randomseed(GetTickCount())
          local idx = math.random(1, #tmp)
          for k = 1, 3 do
            if Skill:UseSkillByName(tSkl[i].text, tmp[idx].id, nil, nil, 300) then
            else
              break
            end
          end
        end
      end
    else
    end
  end
end

function Skill:UseAttack(aSkillArr, aTargetID, aSkillIndex, aSkillNotUseName, aStateCallBack)
  local tSkl = aSkillArr
  local n = #tSkl
  local bUse = false
  if n <= 0 then
    return -1, bUse
  end
  if aSkillIndex <= 0 or aSkillIndex > n then
    aSkillIndex = 1
  end
  local nSleep = 350
  aSkillNotUseName = aSkillNotUseName or ""
  if "" ~= aSkillNotUseName then
    aSkillNotUseName = HandleText_AddFuHao(aSkillNotUseName, " ")
  end
  for i = 1, n do
    if string.find(" 移花接木 溪山行旅 风雷万钧 天地同寿 ", tSkl[i].text, nil, true) then
      if not string.find(aSkillNotUseName, " " .. tSkl[i].text .. " ", nil, true) then
        local bNext = true
        if aTargetID >= 0 and tSkl[i].text == "移花接木" then
          local skill = self:GetSkillByName(tSkl[i].text)
          if skill and self:CanUseByCdIdx(skill.cdidx) then
            local tmp = FindObjByTID(aTargetID)
            if tmp and tmp.dst > 3 then
              bNext = false
            end
          end
        end
        if bNext then
          local isUse = self:UseSkillByName(tSkl[i].text, aTargetID, nil, nil, nSleep)
          if isUse then
            return aSkillIndex, true
          end
        end
      end
      break
    end
  end
  for j = 1, 2 do
    for i = 1, n do
      if aSkillIndex <= i and not string.find(aSkillNotUseName, " " .. tSkl[i].text .. " ", nil, true) then
        local bNext = true
        if tSkl[i].text == "移花接木" then
          bNext = false
        end
        if bNext and aTargetID >= 0 then
          local skill = self:GetSkillByName(tSkl[i].text)
          if skill and skill.qun and (5 == skill.dist or 7 == skill.dist) and self:CanUseByCdIdx(skill.cdidx) then
            local tmp = FindObjByTID(aTargetID)
            if not tmp or tmp.dst > skill.dist then
              bNext = false
            end
          end
        end
        if bNext then
          bUse = self:UseSkillByName(tSkl[i].text, aTargetID, nil, nil, nSleep)
          if bUse then
            aSkillIndex = i + 1
            break
          end
        end
      end
    end
    if not bUse then
      aSkillIndex = 1
    else
      break
    end
  end
  if bUse then
    PlayerStateTimeOut(5, 8, aStateCallBack)
  end
  return aSkillIndex, bUse
end

function Skill:UseKongZhi(aSkillArr, aTarget, aCheckBuff)
  local bUse = false
  if false == aCheckBuff or false == Target:GetSpecialBuff(aTarget) then
    for i = 1, #aSkillArr do
      local tmp = aSkillArr[i]
      local bCanUse = true
      local skill = self:GetSkillByName(tmp.text)
      if skill then
        if tmp.text == "兰花点穴手" then
          bCanUse = false
          if self:CanUseSkill(skill) then
            if -1 ~= Player:GetBuff("隐身") then
              bCanUse = true
            end
            if self:UseShunYi(aTarget.x, aTarget.y) and -1 ~= Player:GetBuff("隐身") then
              bCanUse = true
              Sleep(500)
            end
          end
        elseif skill.qun and (5 == skill.dist or 7 == skill.dist) and aTarget.dst > skill.dist then
          bCanUse = false
        end
        if bCanUse and self:UseSkillByName(tmp.text, aTarget.id, nil, nil, 350) then
          bUse = true
          break
        end
      end
    end
  end
  return bUse
end

function Skill:UseKongZhi_fuben(aTarget, aCanAttack, aNoYunQi)
  if 0 == #self.skill_kongzhi then
    self:RefreshSkill()
  end
  local skillArr = {}
  for i = 1, #self.skill_kongzhi do
    local tmp = self.skill_kongzhi[i]
    local bInsert = true
    if aNoYunQi and tmp.ex_yunqi then
      bInsert = false
      if tmp.ex_yunqi_state ~= "" then
        if -1 ~= Player:GetBuff(tmp.ex_yunqi_state) then
          bInsert = true
        else
          Skill:UseName(tmp.ex_yunqi_state, 300)
        end
      end
    end
    if aCanAttack and tmp.ex_canattak == false then
      bInsert = false
    end
    if bInsert then
      local skl = {
        data = 0,
        text = tmp.name
      }
      table.insert(skillArr, skl)
    end
  end
  return self:UseKongZhi(skillArr, aTarget, true)
end

function Skill:UseCheckBuff(aSkillName)
  local bUse = false
  local skill = self:GetSkillByName(aSkillName)
  if skill and skill.buff_check ~= "" and -1 == Player:GetBuff(skill.buff_check) then
    local tid = Player:GetTID()
    bUse = self:UseSkillByName(skill.name, tid, nil, nil, 400)
  end
  return bUse
end

function Skill:UseState(aSkillArr, aSkillIndex, aSkillNotUseName)
  local bUseIndex = 0
  if IsMount() or Player:IsFollow(false) or Player:GetMP() < 300 then
    return aSkillIndex
  end
  local n = #aSkillArr
  if 0 == n then
    return bUseIndex
  end
  aSkillNotUseName = aSkillNotUseName or ""
  aSkillNotUseName = HandleText_AddFuHao(aSkillNotUseName, " ", true)
  local start_index = aSkillIndex
  local stop_index = n
  if start_index < 0 or n <= start_index then
    start_index = 0
  end
  local bUse = false
  for j = 1, 2 do
    for i = 1, n do
      if i > start_index and i <= stop_index then
        local tmp = aSkillArr[i]
        if not string.find(aSkillNotUseName, " " .. tmp.text .. " ", nil, true) then
          if tmp.text == "暗器护体" then
            if -1 == Player:GetBuff("增加：") and -1 == Player:GetBuff("增强：") then
              bUse = self:UseName("暗器护体", 400)
              if bUse then
                bUseIndex = i
                break
              end
            end
          elseif self:UseCheckBuff(tmp.text) then
            bUse = true
            bUseIndex = i
            PlayerStateTimeOut(5, 5)
            break
          end
        end
      end
    end
    if bUse or 0 == start_index then
      break
    end
    stop_index = start_index
    start_index = 0
  end
  return bUseIndex
end

function Skill:GetSkillByPartName(aSkillName)
  for i = 1, #Skill.skill do
    local tmp = Skill.skill[i]
    if string.find(tmp.name, aSkillName) then
      return tmp
    end
  end
  return nil
end

function Skill:UseQingGong(aPosX, aPosY)
  Dismount(600)
  CallFun(6, aPosX, aPosY)
  Sleep(100)
end

function Skill:CheckUseQingGong(aPosX, aPosY)
  local skl = self:GetSkillByPartName("轻功")
  if self:CanUseSkill(skl) then
    self:UseQingGong(aPosX, aPosY)
    PushDebugMessage("使用轻功技能")
    return true
  end
  return false
end

function Skill:UseSpeed()
  local bUse = false
  if IsMount() or Player:IsFollow(false) or Player:GetMP() < 300 then
    return bUse
  end
  if 2 == g_self.menpai and -1 ~= Player:GetBuff("横扫乾坤：") then
    return false
  end
  for i = 1, #self.skill do
    local tmp = self.skill[i]
    if tmp.jiasu and not tmp.attack and not tmp.shunyi then
      bUse = self:UseName(tmp.name, 150)
      break
    end
  end
  return bUse
end

function Skill:UseShunYi(aPosX, aPosY)
  local bUse = false
  if IsMount() or Player:IsFollow(false) or Player:GetMP() < 300 then
    return bUse
  end
  for i = 1, #self.skill do
    local tmp = self.skill[i]
    if tmp.shunyi and not tmp.attack then
      bUse = self:UseSkillByName(tmp.name, nil, aPosX, aPosY, 500)
      break
    end
  end
  return bUse
end

function Skill:UsePetSkill(aSkillName, aPosX, aPosY, aSleep)
  local bPointSkill = false
  local bUse = false
  local pet_point_skill = {
    "冰天雪地",
    "烈火燎原",
    "血毒万里",
    "五雷轰顶",
    "极冰凝杀",
    "劫火焚杀",
    "腐毒蚀杀",
    "玄雷击杀"
  }
  if type(aSkillName) ~= "string" or "" == aSkillName then
    return false
  end
  if "高级神佑" == aSkillName and -1 ~= Player:GetBuff("疲劳：主人无法再配合珍兽施放神佑技能") then
    return false
  end
  if ("高级共生" == aSkillName or "高级血祭" == aSkillName) and -1 ~= Player:GetBuff("疲劳：主人无法再配合珍兽施放共生和血祭技能") then
    return false
  end
  if "高级肉墙" == aSkillName and -1 ~= Player:GetBuff("疲劳：主人无法再配合珍兽施放肉墙技能") then
    return false
  end
  for i = 1, #pet_point_skill do
    if string.find(aSkillName, pet_point_skill[i], nil, true) then
      bPointSkill = true
      if -1 ~= Player:GetBuff("疲劳：主人无法再配合珍兽施放群攻技能") then
        return false
      end
    end
  end
  if string.find(aSkillName, "咆哮", nil, true) or string.find(aSkillName, "血爆", nil, true) then
    local nowTick = GetTickCount()
    if nowTick - self.use_pet_tick < 65000 then
      return false
    end
    self.use_pet_tick = nowTick
  end
  if string.find(aSkillName, "嗜血", nil, true) then
    local nowTick = GetTickCount()
    if nowTick - self.use_pet_tick_ky < 60500 then
      return false
    end
    self.use_pet_tick_ky = nowTick
  end
  if bPointSkill then
    local pet_point_skill_id = GetLuaValue("return meGetPetPointSkillID()", "n")
    if pet_point_skill_id > 0 then
      if nil == aPosX or nil == aPosY then
        local pos = Player:GetPos()
        aPosX = pos.x
        aPosY = pos.y
      end
      self.CUseSkillByID2(pet_point_skill_id, -1, aPosX, aPosY, Pet:GetTID())
    end
  else
    bUse = GetLuaValue(fmt("return meUsePetSkill([[%s]]);", aSkillName), "b")
  end
  if bUse and aSleep then
    Sleep(aSleep)
  end
  return bUse
end

return Skill
