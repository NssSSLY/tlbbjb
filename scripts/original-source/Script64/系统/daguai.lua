-- 反编译自 dfz64.dll 内嵌字节码 004c3b9c（unluac 2025-12-23；函数 CDG:checkMP 由原字节码手工还原并经对拍核对；仅供分析）
CDG = {}
local m_param = {}
local m_data = {}
m_data.tick_check_skill = GetTickCount()

function CDG:Init()
  m_param = {}
  m_param.timeOut = {
    {
      time = 2500,
      last = GetTickCount() - 600000
    },
    {
      time = 5000,
      last = GetTickCount() - 600000
    },
    {
      time = 15000,
      last = GetTickCount() - 600000
    },
    {
      time = 60000,
      last = GetTickCount() - 600000
    },
    {
      time = 180000,
      last = GetTickCount() - 600000
    }
  }
  m_param.last_hp = -1
  m_param.last_targetID = -1
  m_param.idx_skl_attack = 1
  m_param.idx_skl_jinji = 1
  m_param.idx_skl_state = 1
  m_param.overthislopp = false
  m_param.over = false
  self.scriptName = ""
  self.sceneID = -1
  self.sceneName = ""
  self.line = 0
  self.pos = {}
  self.posIdx = 1
  self.posRadius = 5
  self.posFollow = false
  self.sceneFollow = false
  self.moveFollow = false
  self.attackMode = "打死换怪"
  self.jgyc = false
  self.attackRadius = 17
  self.attack = true
  self.attackGrab = 0
  self.skill_attack = {}
  self.skill_control = {}
  self.skill_state = {}
  self.skill_comb1 = {}
  self.skcb1 = {mode = 0, using = false}
  self.skill_comb2 = {}
  self.skcb2 = {mode = 0, using = false}
  self.skill_jinji = {}
  self.skill_attack_jinji_disable = ""
  self.targetName = ""
  self.targetType = 3
  self.targetClass = " 怪物 "
  self.targetOwer = "红绿"
  self.tragetSelect = false
  self.dxys = false
  self.tsys = false
  self.maxKillNum = -1
  self.wuyi = false
  self.die = {
    out = true,
    waittime = -1,
    count = 0,
    maxCount = 0
  }
  self.pickup = true
  self.pet1 = {
    GUID = -1,
    skill = false,
    kouliang = "",
    OldGUID = -1,
    orgGUID = -1
  }
  self.pet2 = {GUID = -1}
  self.pet3 = {GUID = -1}
  self.petArr = {}
  self.rescue = false
  self.mp = {cmp = 0}
  self.hp = {
    cmp = 0,
    qxpsz = false,
    cxyq = false,
    em_fgpz = false,
    hpskill = false,
    petcmp = 0,
    pet_first_kl = true,
    em_pet = false,
    em_team = false,
    em_raid = false,
    em_namelist = "",
    em_firstlist_cmp = 0,
    em_firstlist_name = "",
    em_bh_id = "",
    em_bh_self = false,
    em_tm_self = false,
    em_target_dist = 16,
    em_yxjx = false
  }
  self.energy = {check = false, cmp = 0}
  self.level = {check = false, cmp = 0}
  self.petattr = false
  self.defaultCity = 0
  self.beep = false
  self.tulingzhu = false
  self.savebank = false
  self.buji = true
  self.horse = true
  self.double = {
    tld = false,
    xdld = false,
    xld = false,
    exp = false
  }
  self.back = {
    buypetRation = false,
    buypetHappy = false,
    buyhy = false,
    fullprop = false,
    fullmate = false,
    fullbag = false
  }
  self.overMapErr = false
  self.callfun = nil
  self.callfun_move = nil
  self.callfun_posidx = nil
  self.call = {back1 = nil, CanJiaXue = nil}
end

function CDG:SetTimeOut(aTime1)
  if aTime1 then
    m_param.timeOut[1].time = aTime1
  end
end

function CDG:SetActionTick(aTick3)
  if aTick3 then
    m_param.timeOut[3].last = GetTickCount() - 600000
  end
end

function CDG:SetGrab(aGrab)
  if aGrab then
    DoSystem(1002, CDG.attackGrab)
  else
    DoSystem(1002, 0)
  end
end

function CDG:IsOver()
  if m_param.over or m_param.overthislopp then
    return true
  end
  return false
end

function CDG:IsRun()
  return not CDG:IsOver()
end

function CDG:EnumTarget()
  local tObj = Enum2XByClass(self.targetClass, {
    0,
    self.attackRadius
  })
  tObj = ObjFilterByStr(tObj, self.targetName, self.targetType, "name")
  tObj = ObjFilterByColor(tObj, self.targetOwer)
  return tObj
end

function CDG:UseSkillPet(aUsePoint, aPosX, aPosY)
  if self.pet1.GUID == self.pet1.OldGUID and self.pet1.skill and 0 ~= Player:GetFightPetGUID() then
    if aUsePoint then
      Skill:UsePetSkill("冰天雪地烈火燎原血毒万里五雷轰顶极冰凝杀劫火焚杀腐毒蚀杀玄雷击杀", aPosX, aPosY, 350)
    else
      Skill:UsePetSkill("咆哮高级血爆", nil, nil, 350)
      Skill:UsePetSkill("高级嗜血", nil, nil, 350)
    end
  end
end

function CDG:PickUp()
  local n = 0
  if self.pickup then
    _, n = PickUpLua()
  end
  return n
end

function CDG:checkDXYS()
  if self.dxys then
    local skill = Skill:GetSkillByName("初级隐遁")
    if skill and Skill:CanUseSkill(skill) then
      local hp = Player:GetHP()
      if hp < m_param.last_hp then
        Skill:UseName("初级隐遁", 300)
      end
      m_param.last_hp = hp
    end
  end
end

function CDG:GetDoubleExp()
  if self.double.exp then
    DoubleExp_Get(120)
  end
end

function CDG:checkLevelUp()
  if self.level.check and self.level.cmp >= 0 then
    local nLevel = GetLuaValue("return meLevelUp(" .. self.level.cmp .. ");", "nn")
    if nLevel >= self.level.cmp then
      self.level.check = false
    end
  end
end

function CDG:PetAddAttribute()
  if self.petattr then
    Pet:AddtAttribute()
  end
end

function CDG:checkWuYi()
  if self.wuyi then
    local nWuYiMonsterNum = GetLuaValue("return MaritialSys:GetMaritialTodayNum();", "n")
    if type(nWuYiMonsterNum) == "number" and nWuYiMonsterNum >= 3000 then
      PushColorMsg("结束：武意已刷满" .. nWuYiMonsterNum)
      m_param.over = true
    end
  end
end

function CDG:checkKillNum()
  local nH = tonumber(os.date("%H"))
  local nM = tonumber(os.date("%M"))
  if type(nH) ~= "number" or type(nM) ~= "number" then
    PushColorMsg("获取时间时类型错误" .. type(nH) .. " " .. type(nM))
    return
  end
  if nH >= 22 then
    return
  end
  if 0 == nH and nM < 4 then
    return
  end
  if self.maxKillNum <= 0 or self.maxKillNum > 10000 then
    return
  end
  local nowNum = Player:GetDataInt("KILLMONSTERCOUNT")
  if nowNum >= self.maxKillNum and nowNum < 10001 then
    PushColorMsg("结束：杀怪数量达到" .. nowNum)
    m_param.over = true
  end
end

function CDG:checkEnergy()
  if self.energy.check then
    local n = GetLuaValue("return meCheckEnergy(" .. self.energy.cmp .. ");", "n")
    if 1 == n then
      PushColorMsg("结束：精力达到设定值")
      m_param.over = true
    end
  end
end

function CDG:checkDouble()
  if self:IsOver() then
    return
  end
  if self.double.tld then
    local n = GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env}) if MainMenuBar_Doub_Watch:IsVisible() then return 1 end return 0", "n")
    if 0 == n then
      Bag:UseItemByName("天灵丹", 200)
    end
  end
  if self.double.xdld then
    if -1 == Player:GetBuff("小灵丹：") and Bag:UseItemByName("小灵丹", 800) then
      MessageBox_Self2_OK_Clicked()
    end
    if -1 == Player:GetBuff("地灵丹：") and Bag:UseItemByName("地灵丹", 800) then
      MessageBox_Self2_OK_Clicked()
    end
  end
  if self.double.xld and -1 == Player:GetBuff("玄灵丹：") then
    if Bag:UseItemByName("小玄灵丹", 1500) then
      MessageBox_Self2_OK_Clicked()
      Sleep(1000)
      MessageBox_Self_OK_Clicked()
    elseif Bag:UseItemByName("玄灵丹", 1500) then
      MessageBox_Self2_OK_Clicked()
      Sleep(1000)
      MessageBox_Self_OK_Clicked()
    end
  end
  if self.double.xyd and -1 == Player:GetBuff("双益丹：") then
    if Bag:UseItemByName("双益丹", 1500) then
      MessageBox_Self2_OK_Clicked()
      Sleep(1000)
      MessageBox_Self_OK_Clicked()
    elseif Bag:UseItemByName("双益丹", 1500) then
      MessageBox_Self2_OK_Clicked()
      Sleep(1000)
      MessageBox_Self_OK_Clicked()
    end
  end
  if self.double.xly and -1 == Player:GetBuff("醒灵玉：") then
    if Bag:UseItemByName("醒灵玉", 1500) then
      MessageBox_Self2_OK_Clicked()
    elseif Bag:UseItemByName("醒灵玉", 1500) then
      MessageBox_Self2_OK_Clicked()
    end
  end
  if self.double.jly and -1 == Player:GetBuff("聚灵玉：") then
    if Bag:UseItemByName("聚灵玉", 1500) then
      MessageBox_Self2_OK_Clicked()
    elseif Bag:UseItemByName("聚灵玉", 1500) then
      MessageBox_Self2_OK_Clicked()
    end
  end
  if self.double.cww and -1 == Player:GetBuff("从武丸：") then
    if Bag:UseItemByName("从武丸", 1500) then
      MessageBox_Self2_OK_Clicked()
    elseif Bag:UseItemByName("从武丸", 1500) then
      MessageBox_Self2_OK_Clicked()
    end
  end
  if self.double.sww and -1 == Player:GetBuff("善武丸：") then
    if Bag:UseItemByName("善武丸", 1500) then
      MessageBox_Self2_OK_Clicked()
    elseif Bag:UseItemByName("善武丸", 1500) then
      MessageBox_Self2_OK_Clicked()
    end
  end
end

function CDG:checkBagBack()
  if self:IsOver() then
    return
  end
  local delProp, delMate = 0, 0
  if self.back.fullbag or self.back.fullmate or self.back.fullprop then
    if IsUnLockMibao() == false then
      return
    end
    local tDaoJu = Bag:EnumDaoJuItem()
    local tCaiLiao = Bag:EnumCailiaoItem()
    delProp = Bag_DeleteBagItem(nil, tDaoJu)
    delMate = Bag_DeleteBagItem(nil, tCaiLiao)
  end
  if self.back.fullprop and 0 == delProp and 0 == Bag:GetSpaceNum(0) then
    self:GoBack("道具栏已满,回城！")
  end
  if self.back.fullmate and 0 == delMate and 0 == Bag:GetSpaceNum(1) then
    self:GoBack("材料栏已满,回城！")
  end
  if self.back.fullbag and 0 == delProp and 0 == delMate and 0 == Bag:GetSpaceNum(0) and 0 == Bag:GetSpaceNum(1) then
    self:GoBack("背包已满,回城！")
  end
end

function CDG:checkDie()
  if 9 == Player:GetState() then
    self:SetGrab(false)
    if self.die.out then
      PushDebugMessage("已设置自动出窍！")
      DieRelive(-1)
      Sleep(1000)
    else
      DieRelive(0)
      DebugStr("未设置死亡出窍")
    end
    return true
  end
  return false
end

function CDG:checkRescue()
  if self.rescue and 4 == g_self.menpai then
    local selfPos = Player:GetPos()
    RelivePlayer(2, selfPos.x - 15, selfPos.y - 15, selfPos.x + 15, selfPos.y + 15, 1, true)
  end
end

function CDG:GoBack(aMsg)
  if self:IsOver() then
    return
  end
  if self.sceneID < 0 and self.sceneFollow == false then
    return
  end
  if 0 == #self.pos and self.sceneFollow == false then
    return
  end
  self:SetGrab(false)
  if aMsg then
    PushDebugMessage(aMsg)
  end
  if IsKVKSceneName(self.sceneName) then
    MoveTo(161, 121, 850, nil, nil, MoveCallBack_state_2)
  else
    MoveTo(256, 302, LUOYANG_ID, nil, nil, MoveCallBack_state_2, nil, true, true)
  end
end

function CDG:checkBuJi()
  if self.back.buypetRation and self.pet1.kouliang ~= "" then
    local tItem = Bag:FindItemInfo(self.pet1.kouliang)
    if 0 == #tItem then
      self:GoBack("需要回城补给珍兽口粮")
      return
    end
  end
  if self.back.buypetHappy then
    local tItem = Bag:FindItemInfo("回旋金球")
    if 0 == #tItem then
      self:GoBack("需要回城补给回旋金球")
      return
    end
  end
  if self.back.buyhy then
    local tItem = Bag:FindItemInfo("金创药")
    if 0 == #tItem then
      self:GoBack("需要回城补给金创药")
      return
    end
  end
end

function CDG:checkDiFu()
  local cur_scene_id = GetSceneID()
  if not IsDiFuScene(cur_scene_id) then
    return false
  end
  self:SetGrab(false)
  local bfengming = false
  if 578 == cur_scene_id or 823 == cur_scene_id then
    bfengming = true
  end
  if self.beep then
  end
  self.die.count = self.die.count + 1
  local nOldTick = GetTickCount()
  DeleteDebugMsg("目标场景人数已满")
  DeleteDebugMsg("目标服务器负载过高")
  local cityTable = {
    {name = "洛阳"},
    {name = "苏州"},
    {name = "大理"}
  }
  local outCity = "洛阳"
  if 3 == self.defaultCity then
    outCity = "楼兰"
  elseif 2 == self.defaultCity then
    outCity = "大理"
  elseif 1 == self.defaultCity then
    outCity = "苏州"
  end
  while IsDiFuScene(cur_scene_id) do
    Player:TeamFollow(false, 500)
    while self.die.waittime > 0 and GetTickCount() - nOldTick < self.die.waittime * 60 * 1000 do
      Sleep(5000)
      DebugStr("已设置地府等待：" .. self.die.waittime .. "分钟")
    end
    if g_config.tysz.back_bangzhan then
      local unBackScript = HandleText_AddFuHao(g_config.tysz.unback_bangzhan, " ", true)
      if (g_runing_script == "" or not string.find(unBackScript, " " .. g_runing_script .. " ", nil, true)) and IsBangHuiPK() then
        LogMsg("帮战中,暂时不离开地府 " .. g_runing_script)
        while IsBangHuiPK() do
          Sleep(20000)
          DebugStr("帮战中,暂时不离开地府." .. g_runing_script)
          local curScene = GetSceneID()
          if not IsDiFuScene(curScene) then
            LogMsg("帮战,当前不是地府地图" .. curScene)
            break
          end
        end
        LogMsg("帮战已结束")
      end
    end
    if RunTo(15, 25, 1, 600) == false then
      TalkNpc("孟婆", 700)
      local allItem = GetNPCEventListAllItem()
      if string.find(allItem, "#{KVKGZ_110620_128}", nil, true) then
        bfengming = true
      end
      if bfengming then
        QuestFrameOptionClicked_Item("#{KVKGZ_110620_128}", 1)
      else
        QuestFrameOptionClicked_Item(outCity)
        if IsInDebugMsg("目标场景人数已满") or IsInDebugMsg("目标服务器负载过高") then
          PushColorMsg("场景爆满:自动更换地图")
          local newCity = TableDeleteTable(cityTable, {
            {name = outCity}
          }, "name")
          if #newCity > 0 then
            math.randomseed(GetTickCount())
            local idx = math.random(1, #newCity)
            outCity = newCity[idx].name
          end
          DeleteDebugMsg("目标场景人数已满")
          DeleteDebugMsg("目标服务器负载过高")
        end
      end
    end
    Sleep(1000)
    cur_scene_id = GetSceneID()
  end
  if self.die.maxCount > 0 and self.die.count >= self.die.maxCount then
    ShowWarningMsg("结束：死亡超过" .. self.die.maxCount)
    m_param.over = true
  end
  return true
end

function CDG:checkJianYu()
  local cur_scene_id = GetSceneID()
  if 194 ~= cur_scene_id and 577 ~= cur_scene_id then
    return false
  end
  self:SetGrab(false)
  local bfengming = false
  if 577 == cur_scene_id then
    bfengming = true
  end
  if self.beep then
  end
  while 194 == cur_scene_id or 577 == cur_scene_id do
    Player:TeamFollow(false, 500)
    if RunTo(44, 31, 1, 600) == false then
      TalkNpc("张正贵", 800)
      QuestFrameOptionClicked_Item("我要出去", 1, 800)
      if bfengming then
        QuestFrameOptionClicked_Item("#{KVKGZ_110620_128}", 1)
      elseif 0 == self.defaultCity then
        QuestFrameOptionClicked_Item("洛阳")
      elseif 1 == self.defaultCity then
        QuestFrameOptionClicked_Item("苏州")
      else
        QuestFrameOptionClicked_Item("大理")
      end
    end
    Sleep(1500)
    cur_scene_id = GetSceneID()
  end
  return true
end

function CDG:checkPet1Play()
  local curGUID = Player:GetFightPetGUID()
  if 0 == curGUID or -1 == curGUID then
    return true
  end
  if self.pet2.GUID == curGUID and self.pet1.GUID ~= self.pet2.GUID then
    return false
  end
  if self.pet3.GUID == curGUID and self.pet1.GUID ~= self.pet3.GUID then
    return false
  end
  return true
end

function CDG:checkPetHappy(aGUID)
  local nHappy = 0
  for i = 1, 3 do
    local tWanJu = Bag:SearchItemName("回旋金球 黄锡弹弓")
    if #tWanJu > 0 then
      nHappy = GetLuaValue(fmt("return mePetCheckHappy(%d,%d,2)", aGUID, 89), "n")
    else
      tWanJu = Bag:SearchItemName("超级珍兽滋补丹 超级珍兽回春丹 珍兽滋补丹 珍兽回春丹 珍兽万补丹 珍兽回神丹")
      if #tWanJu > 0 then
        nHappy = GetLuaValue(fmt("return mePetCheckHappy(%d,%d,1)", aGUID, 61), "n")
      else
        nHappy = GetLuaValue(fmt("local nHappy,idx = mePetGetHappy(%d) return nHappy", aGUID), "n")
        break
      end
    end
    if nHappy >= 60 then
      break
    end
    Sleep(300)
  end
  return nHappy
end

function CDG:checkHP_Pet(aUseEMSkill)
  if nil == aUseEMSkill then
    aUseEMSkill = true
  end
  if self.hp.petcmp <= 0 then
    return
  end
  local nGuid = Player:GetFightPetGUID()
  if 0 == nGuid or -1 == nGuid then
    return
  end
  local hpp, idx = GetLuaValue(fmt("return mePetGetHPP(%d)", nGuid), "nn")
  if hpp > self.hp.petcmp or hpp < 0 then
    return
  end
  local bUseItem = true
  if 4 == g_self.menpai and self.hp.em_pet and aUseEMSkill and nGuid == self.pet3.GUID then
    if self.hp.qxpsz then
      if Skill:UseSkillByName("清心普善咒", Pet:GetTID(), -1, -1, 300) then
        PlayerStateTimeOut(5, 3, self.call.back1)
        if hpp > 30 then
          bUseItem = false
        end
      end
    elseif self.hp.cxyq then
      if Skill:UseSkillByName("冲虚养气", Pet:GetTID(), -1, -1, 300) then
        PlayerStateTimeOut(5, 5, self.call.back1)
        if hpp > 30 then
          bUseItem = false
        end
      end
    elseif self.hp.em_fgpz and Skill:UseSkillByName("佛光普照", -1, -1, -1, 300) then
      PlayerStateTimeOut(5, 5, self.call.back1)
      if hpp > 30 then
        bUseItem = false
      end
    end
  end
  if bUseItem and idx >= 0 then
    if self.hp.pet_first_kl then
      Pet:Feed(idx)
      if hpp < 8 then
        Pet:Feed(idx)
      end
    else
      local tWanJu = Bag:SearchItemName("超级珍兽滋补丹 超级珍兽回春丹 珍兽滋补丹 珍兽回春丹 珍兽万补丹 珍兽回神丹")
      if #tWanJu > 0 then
        BagUseItemCheckWindowShow(tWanJu[1].index, {
          "Packet_Temporary",
          "Shop",
          "BigBank"
        }, false, fmt("mePetFeed(%d);", idx), 120)
        if hpp < 8 then
          Pet:Feed(idx)
        end
      else
        Pet:Feed(idx)
        if hpp < 8 then
          Pet:Feed(idx)
        end
      end
    end
  end
end

function CDG:checkHP_PetGUID(aPetGuid, aHPCmp)
  local nGuid = Player:GetFightPetGUID()
  if nGuid ~= aPetGuid then
    local hpp = GetLuaValue(fmt("return mePetCheckHP(%d,%d)", aPetGuid, aHPCmp), "n")
    return hpp
  end
  if 0 == nGuid or -1 == nGuid then
    return 100
  end
  local hpp, idx = GetLuaValue(fmt("return mePetGetHPP(%d)", nGuid), "nn")
  if aHPCmp < hpp or hpp < 0 then
    return hpp
  end
  if IsMount() then
    return hpp
  end
  if self.hp.pet_first_kl then
    Pet:Feed(idx)
    if hpp < 8 then
      Pet:Feed(idx)
    end
  else
    local tWanJu = Bag:SearchItemName("超级珍兽滋补丹 超级珍兽回春丹 珍兽滋补丹 珍兽回春丹 珍兽万补丹 珍兽回神丹")
    if #tWanJu > 0 then
      BagUseItemCheckWindowShow(tWanJu[1].index, {
        "Packet_Temporary",
        "Shop",
        "BigBank"
      }, false, fmt("mePetFeed(%d);", idx), 120)
    else
      Pet:Feed(idx)
    end
  end
  return hpp
end

function CDG:checkPetPlay(aGUID)
  if 0 ~= aGUID and -1 ~= aGUID then
    if 9 == Player:GetState() then
      return false
    end
    local curGUID = Player:GetFightPetGUID()
    if curGUID >= 0 and curGUID ~= aGUID then
      local nHappy = self:checkPetHappy(aGUID)
      if nHappy >= 60 and nHappy <= 100 then
        local nt = GetTickCount()
        while 7 == Player:GetState() and not (GetTickCount() - nt > 2000) do
          Target:StopAttack(250)
          self:checkHP_Pet(false)
          if self.call.back1 and self.call.back1() == false then
            return false
          end
          if Player:GetFightPetGUID() == aGUID then
            break
          end
        end
        self:checkHP_Pet(false)
        if Player:GetFightPetGUID() ~= aGUID then
          GetLuaValue(fmt("mePetGoFight(%d);", aGUID))
          if Player:GetFightPetGUID() ~= aGUID and PlayerStateTimeOut(5, 6, self.call.back1) then
            Sleep(250)
          end
        end
      end
    end
  end
  local curGUID = Player:GetFightPetGUID()
  if curGUID == aGUID then
    return true
  end
  return false
end

-- 手工还原：unluac 2025-12-23 无法处理此函数的控制流（ControlFlowHandler.is_break_jmp 空指针），
-- 依据原字节码（daguai 第 30 个函数，源行 839-941）逐条翻译；与原字节码做过随机对拍，返回值和调用序列一致。
function CDG:checkMP(aUsePetXueJi)
  if aUsePetXueJi == nil then
    aUsePetXueJi = true
  end
  if self.mp.cmp <= 0 then
    return true
  end
  local mpp = Player:GetMPP()
  local bUseItem = false
  local bNeedMP = mpp < self.mp.cmp
  if not bNeedMP and mpp < self.mp.cmp + 3 and mpp < 95 then
    local curGUID = Player:GetFightPetGUID()
    bNeedMP = aUsePetXueJi and curGUID > 0 and curGUID == self.pet3.GUID and self.pet1.GUID ~= self.pet3.GUID
  end
  if bNeedMP then
    if self.call.back1 and self.call.back1() == false then
      return false
    end
    local bUseXueJi = false
    local tick_out = GetTickCount()
    if aUsePetXueJi and self.pet3.GUID > 0 and Player:GetBuff("珍兽施放共生和血祭") == -1 then
      bUseXueJi = true
      for i = 1, 4 do
        local hp = CDG:checkHP_PetGUID(self.pet3.GUID, 100)
        if hp > 90 then
          break
        end
        if self.call.back1 and self.call.back1() == false then
          return false
        end
        Sleep(250)
      end
      if self:checkPetPlay(self.pet3.GUID) then
        if GetTickCount() - tick_out > 2500 then
          PushColorMsg("召唤血祭珍兽...")
          return false
        end
        for i = 1, 4 do
          local hp = CDG:checkHP_PetGUID(self.pet3.GUID, 100)
          if hp > 90 then
            break
          end
          if self.call.back1 and self.call.back1() == false then
            return false
          end
          Sleep(300)
        end
        if GetLuaValue("return meUsePetSkill('高级血祭');", "b") then
          Sleep(100)
          return false
        end
      end
    end
    if not bUseXueJi then
      mpp = Player:GetMPP()
      if mpp < self.mp.cmp then
        local tItem = Bag:SearchItemName("行气散 还灵丹 归灵丸 采香丸")
        if #tItem > 0 then
          bUseItem = true
          Bag:UseItem(tItem[1].index, 200)
        end
        tItem = Bag:SearchItemName("玉液净瓶 仙露净瓶 玉液宝瓶")
        if #tItem > 0 then
          bUseItem = true
          Bag:UseItem(tItem[1].index, 200)
        end
      end
    end
  end
  local curGUID = Player:GetFightPetGUID()
  if curGUID > 0 and curGUID == self.pet3.GUID and self.pet1.GUID ~= self.pet3.GUID then
    if bUseItem == false and self.mp.cmp <= mpp or Player:GetBuff("珍兽施放共生和血祭") ~= -1 then
      Pet:Relax()
      return true
    end
  end
  return false
end

function CDG:checkHP(aUsePetGongSheng)
  if nil == aUsePetGongSheng then
    aUsePetGongSheng = true
  end
  if self.hp.cmp <= 0 then
    return
  end
  local hpp = Player:GetHPP()
  local bUseItem = false
  if not (hpp > self.hp.cmp) then
    if self.call.CanJiaXue then
      local bCan = self.call.CanJiaXue(1)
      if not bCan then
        goto lbl_303
      end
    end
    if 0 == g_self.menpai and self.hp.hpskill then
      Skill:UseName("易筋锻骨", 250)
    elseif 12 == g_self.menpai and self.hp.hpskill then
      if not string.find(self.skill_attack_jinji_disable, "聚星阵·长生", nil, true) then
        Skill:UseName("聚星阵·长生", 250)
      end
      Skill:UseName("五气朝元", 250)
    elseif 14 == g_self.menpai and self.hp.hpskill then
      if not string.find(self.skill_attack_jinji_disable, "情尽盈血", nil, true) then
        Skill:UseName("情尽盈血", 250)
      end
    elseif 4 == g_self.menpai then
      local tid = Player:GetTID()
      if self.hp.qxpsz then
        local cnt = 1
        if hpp < 50 then
          cnt = 2
        end
        for j = 1, cnt do
          for i = 1, 4 do
            if Skill:UseSkillByName("清心普善咒", tid, -1, -1, 300) then
              PlayerStateTimeOut(5, 3, self.call.back1)
              break
            end
            Sleep(250)
          end
        end
      elseif self.hp.cxyq then
        if Skill:UseSkillByName("冲虚养气", tid, -1, -1, 300) then
          PlayerStateTimeOut(5, 5, self.call.back1)
        end
      elseif self.hp.em_fgpz and Skill:UseSkillByName("佛光普照", -1, -1, -1, 300) then
        PlayerStateTimeOut(5, 5, self.call.back1)
      end
    end
    hpp = Player:GetHPP()
    if not (hpp > self.hp.cmp) then
      if aUsePetGongSheng and self.pet2.GUID > 0 and -1 == Player:GetBuff("珍兽施放共生和血祭") then
        for i = 1, 4 do
          local hp = CDG:checkHP_PetGUID(self.pet2.GUID, 100)
          if hp > 90 then
            break
          end
          if self.call.back1 and self.call.back1() == false then
            return false
          end
          Sleep(300)
        end
        if self:checkPetPlay(self.pet2.GUID) then
          for i = 1, 3 do
            local hp = CDG:checkHP_PetGUID(self.pet2.GUID, 100)
            if hp > 90 then
              break
            end
            if self.call.back1 and self.call.back1() == false then
              return false
            end
            Sleep(300)
          end
          GetLuaValue("return meUsePetSkill('高级共生');", "b")
          Sleep(200)
        end
      end
      hpp = Player:GetHPP()
      if not (hpp > self.hp.cmp) then
        local tItem = Bag:SearchItemName("行血散 活血散 金创药 鹿茸丹")
        if #tItem > 0 then
          bUseItem = true
          Bag:UseItem(tItem[1].index, 200)
        end
        tItem = Bag:SearchItemName("银丹葫芦 金丹葫芦 仙丹葫芦")
        if #tItem > 0 then
          bUseItem = true
          Bag:UseItem(tItem[1].index, 200)
        end
      end
    end
  end
  ::lbl_303::
  local curGUID = Player:GetFightPetGUID()
  if curGUID > 0 and curGUID == self.pet2.GUID and self.pet1.GUID ~= self.pet2.GUID and (false == bUseItem and hpp > self.hp.cmp or -1 ~= Player:GetBuff("珍兽施放共生和血祭")) then
    Pet:Relax()
  end
end

function CDG:checkHP_Name(aHPName, aHpCmp, aObj)
  local jiaxue_name = ""
  if 4 ~= g_self.menpai then
    return jiaxue_name
  end
  if "" == aHPName then
    return jiaxue_name
  elseif "#{ALL}" == aHPName then
    aHPName = ""
  end
  local tObj = aObj or Enum2XByClass("玩家")
  tObj = ObjFilterByStr(tObj, aHPName, 3, "name")
  tObj = ObjFilterByInt(tObj, self.hp.em_target_dist, 2, "dst")
  tObj = ObjFilterByInt(tObj, 0, 1, "hp")
  tObj = ObjFilterByInt(tObj, aHpCmp, 2, "hp")
  tObj = EnumFriendPlayer(tObj)
  if #tObj > 0 then
    local tJX
    BubbleByHP(tObj, 1)
    if self.call.CanJiaXue then
      tJX = self.call.CanJiaXue(2, tObj)
    else
      tJX = tObj[1]
    end
    if tJX then
      if self.hp.qxpsz then
        jiaxue_name = tJX.name
        if Skill:UseSkillByName("清心普善咒", tJX.id, -1, -1, 300) then
          PlayerStateTimeOut(5, 6, self.call.back1)
        end
        if self.hp.em_fgpz then
          local tNear = ObjFilterByDst(tObj, 7, 2)
          BubbleByHP(tNear, 1)
          if #tNear >= 4 and tNear[4].hp < self.hp.cmp and Skill:UseSkillByName("佛光普照", -1, -1, -1, 300) then
            PlayerStateTimeOut(5, 5, self.call.back1)
          end
        end
      elseif self.hp.cxyq then
        jiaxue_name = tJX.name
        if Skill:UseSkillByName("冲虚养气", tJX.id, -1, -1, 300) then
          PlayerStateTimeOut(5, 10, self.call.back1)
        end
        if self.hp.em_fgpz then
          local tNear = ObjFilterByDst(tObj, 7, 2)
          BubbleByHP(tNear, 1)
          if #tNear >= 4 and tNear[4].hp < self.hp.cmp and Skill:UseSkillByName("佛光普照", -1, -1, -1, 300) then
            PlayerStateTimeOut(5, 5, self.call.back1)
          end
        end
      elseif self.hp.em_fgpz and Skill:UseSkillByName("佛光普照", -1, -1, -1, 300) then
        PlayerStateTimeOut(5, 5, self.call.back1)
      end
    end
  end
  return jiaxue_name
end

function CDG:checkHP_Player()
  local add_hp_name = ""
  if self.hp.cmp <= 0 or 4 ~= g_self.menpai then
    return add_hp_name
  end
  local tObj = Enum2XByClass("玩家")
  add_hp_name = self:checkHP_Name(self.hp.em_firstlist_name, self.hp.em_firstlist_cmp, tObj)
  if "" ~= add_hp_name then
    return add_hp_name
  end
  local jiaxue_name = ""
  if self.hp.em_team then
    jiaxue_name = jiaxue_name .. Team:GetAllName()
  end
  if self.hp.em_raid then
    jiaxue_name = jiaxue_name .. Raid:GetAllName()
  end
  if self.hp.em_bh_self then
    local tid = Player:GetBangHuiID()
    if tid >= 0 then
      local tTmp = ObjFilterByInt(tObj, tid, 0, "bhid")
      local szName = Array2Text(tTmp, " ", "name")
      jiaxue_name = jiaxue_name .. szName
    end
  end
  if self.hp.em_tm_self then
    local tid = Player:GetTongMengID()
    if tid >= 0 then
      local tTmp = ObjFilterByInt(tObj, tid, 0, "tmid")
      local szName = Array2Text(tTmp, " ", "name")
      jiaxue_name = jiaxue_name .. szName
    end
  end
  if "" ~= self.hp.em_bh_id then
    local tTmp = ObjFilterByBHID(tObj, self.hp.em_bh_id)
    local szName = Array2Text(tTmp, " ", "name")
    jiaxue_name = jiaxue_name .. szName
  end
  jiaxue_name = jiaxue_name .. self.hp.em_namelist
  return self:checkHP_Name(jiaxue_name, self.hp.cmp, tObj)
end

function CDG:SkillState()
  m_param.idx_skl_state = Skill:UseState(self.skill_state, m_param.idx_skl_state, self.skill_attack_jinji_disable)
end

function CDG:SkillAttack(aTid)
  local bUse = false
  m_param.idx_skl_attack, bUse = Skill:UseAttack(self.skill_attack, aTid, m_param.idx_skl_attack, self.skill_attack_jinji_disable)
  return bUse
end

function CDG:SkillJinJi(aTid)
  local bUse = false
  if #self.skill_jinji > 0 then
    m_param.idx_skl_jinji, bUse = Skill:UseAttack(self.skill_jinji, aTid, m_param.idx_skl_jinji, self.skill_attack_jinji_disable)
    if not bUse and 3 == g_self.menpai then
      Skill:UseName("游刃有余", 200)
    end
    self:checkSkill()
  else
    Skill:RefreshSkill()
  end
  return bUse
end

function CDG:checkMapLeader()
  if not self.posFollow or not self.sceneFollow then
    return false
  end
  local leader, isleader = Team:GetLeaderInfo()
  if not leader or isleader then
    return true
  end
  local curScene = GetSceneID()
  if curScene == leader.sceneID then
    return true
  end
  self:SetGrab(false)
  if self:checkDiFu() or self:checkJianYu() then
    return true
  end
  GoToLeader(nil, MoveCallBack_state_2, true, true)
  return true
end

function CDG:checkPosLeader()
  if not self.posFollow then
    return false
  end
  local leader, isleader = Team:GetLeaderInfo()
  if not leader or isleader then
    return true
  end
  local curScene = GetSceneID()
  if curScene ~= leader.sceneID then
    return true
  end
  local lx, ly = leader.x, leader.y
  local findLeader = FindObjByGUID(leader.guid)
  if findLeader then
    lx, ly = findLeader.x, findLeader.y
  end
  local nDist = 6
  if 0 == Player:GetState() then
    nDist = 3
  end
  if nDist < GetDist(lx, ly) then
    self:SetGrab(false)
    if findLeader then
      if Target:FindBuff(findLeader, "坐骑：") then
        UseMount()
      end
    elseif self.attackMode == "站神模式" then
      UseMount()
    end
    GoToLeader(MoveCallBack_same_scene_GoToLeader, MoveCallBack_state_2, false, false)
  end
  return true
end

function CDG:checkMap()
  if self:IsOver() then
    return
  end
  if self:checkMapLeader() then
    return
  end
  if self.sceneID < 0 then
    return
  end
  local curScene = GetSceneID()
  if self.sceneID == curScene then
    if 0 ~= self.line then
      local curSceneName = GetCurrentSceneName()
      if string.find(curSceneName, "1线") then
        if 2 == self.line then
          ChangeScene2Line()
        end
      elseif string.find(curSceneName, "2线") and 1 == self.line then
        ChangeSceneLine()
      end
    end
    return
  end
  self:SetGrab(false)
  if self.overMapErr then
    m_param.overthislopp = true
    return
  end
  if self:checkDie() then
    return
  end
  if self:checkDiFu() or self:checkJianYu() then
    return
  end
  if -1 ~= self.pet1.GUID and 0 ~= self.pet1.GUID then
    local curGUID = Player:GetFightPetGUID()
    if 0 == curGUID then
      Dismount()
      self:checkPetPlay(self.pet1.GUID)
    end
  end
  if #self.pos > 0 then
    if self.savebank then
      MainBankSaveItem()
      Sleep(1000)
    end
    if self.buji then
      MainSellBuyItem(true, nil)
      Sleep(1000)
    end
    if self.savebank or self.buji then
      XiaoChangHuiXue(90)
    end
    self:GetDoubleExp()
    local bRun = true
    if self.tulingzhu then
      if Bag_UseTuLingZhu(self.sceneID, self.pos[1]) then
        Sleep(1000)
        bRun = false
      else
        PushDebugMessage("没有找到定位在：%s的土灵珠", GetSceneNameByID(self.sceneID))
      end
    end
    if bRun then
      MainMoveToScene(self.sceneID, self.pos[1].x, self.pos[1].y, CDG.IsRun)
    end
  else
    DebugStr("返回地图时发现未设置定点坐标", 2)
    Sleep(5000)
  end
end

function CDG_callback_move(fX, fY, nScene)
  CDG:PickUp()
  if CDG.callfun_move then
    local bRet = CDG.callfun_move(fX, fY, nScene)
    if false == bRet then
      return false
    end
  end
  if nScene >= 0 and GetSceneID() ~= nScene then
    return false
  end
  if CDG.moveFollow and #CDG.pos > 1 and GetDist(fX, fY) > 7 and -1 ~= Player:GetBuff("坐骑：") then
    Player:TeamFollow(true, 300)
  end
  return true
end

function CDG:checkPos()
  if self:IsOver() then
    return
  end
  if self:checkPosLeader() then
    return
  end
  if #self.pos > 0 then
    if self.callfun_posidx then
      self.posIdx = self.callfun_posidx(self.posIdx)
    end
    if self.posIdx > #self.pos or self.posIdx < 1 then
      self.posIdx = 1
    end
    local nScene = self.sceneID
    if -1 == nScene then
      nScene = -2
    end
    if IsDestination(self.pos[self.posIdx].x, self.pos[self.posIdx].y, nScene, self.posRadius) then
      local tObj = self:EnumTarget()
      if 0 == #tObj then
        MoveTo(self.pos[self.posIdx].x, self.pos[self.posIdx].y, nScene, 3, self.horse, MoveCallBack_state_2, CDG_callback_move)
        tObj = self:EnumTarget()
        if 0 == #tObj then
          self.posIdx = self.posIdx + 1
        end
      end
    else
      self:SetGrab(false)
      MoveTo(self.pos[self.posIdx].x, self.pos[self.posIdx].y, nScene, nil, self.horse, MoveCallBack_state_2, CDG_callback_move)
    end
    if self.moveFollow and #self.pos > 1 then
      Player:TeamFollow(false, 300)
    end
  end
end

function CDG:SelectTarget(aTid)
  if self.tragetSelect then
    Target:Select(aTid)
  end
end

function CDG:OnPetAttack(aTid)
  self:SelectTarget(aTid)
  Target:PetAttack(aTid)
end

function CDG:OnAttack(aTid, aObj)
  if self.attack then
    if 9 == Player:GetState() then
      return
    end
    if Player:GetMPP() > 5 then
      Skill:UseZuHe(self.skill_comb1, self.skcb1, aTid, aObj)
      Skill:UseZuHe(self.skill_comb2, self.skcb2, aTid, aObj)
      self:SkillAttack(aTid)
    end
    if #aObj > 0 then
      self:UseSkillPet(true, aObj[1].x, aObj[1].y)
      self:UseSkillPet(false)
    end
    Target:Attack(aTid, 350, self.tragetSelect, nil, self.jgyc)
  end
end

function CDG:MS_KillDie(aObj)
  local nAll = #aObj
  if nAll <= 0 then
    return
  end
  if -1 ~= m_param.last_targetID then
    for i = 1, #aObj do
      if aObj[i].id == m_param.last_targetID then
        self:OnAttack(aObj[i].id, aObj)
        return
      end
    end
  end
  BubbleByDst(aObj, 1)
  BubbleByHP(aObj, 1)
  self:OnAttack(aObj[1].id, aObj)
  m_param.last_targetID = aObj[1].id
end

function CDG:MS_FirstLvGuai(aObj, aAttackNum)
  local nAll = #aObj
  if nAll <= 0 then
    return
  end
  aAttackNum = aAttackNum or 5
  if g_self.isjingong then
    aAttackNum = 1
  end
  local tTmp = ObjFilterByColor(aObj, "绿")
  local nLv = #tTmp
  if nLv > 0 then
    BubbleByHP(tTmp, 1)
    if aAttackNum > nLv then
      aAttackNum = nLv
    end
    for i = 1, aAttackNum do
      self:OnAttack(tTmp[i].id, aObj)
    end
  elseif nAll > 0 then
    local isAttack = false
    if not g_self.isjingong then
      for i = 1, #aObj do
        if aObj[i].id ~= m_param.last_targetID then
          isAttack = true
          self:OnAttack(aObj[i].id, aObj)
          m_param.last_targetID = aObj[i].id
          break
        end
      end
    end
    if false == isAttack then
      self:OnAttack(aObj[1].id, aObj)
      m_param.last_targetID = aObj[1].id
    end
  end
end

function CDG:MS_FirstHPMaxGuai(aObj, aAttackNum)
  local nAll = #aObj
  if nAll <= 0 then
    return
  end
  aAttackNum = aAttackNum or 5
  if g_self.isjingong then
    aAttackNum = 1
  end
  local tTmp = ObjFilterByHP(aObj, 100, 0)
  local nLv = #tTmp
  if nLv > 0 then
    if aAttackNum > nLv then
      aAttackNum = nLv
    end
    for i = 1, aAttackNum do
      self:OnAttack(tTmp[i].id, aObj)
    end
  else
    self:OnAttack(aObj[1].id, aObj)
  end
end

function CDG:MS_OnlyPet(aObj)
  local nAll = #aObj
  if nAll <= 0 then
    return
  end
  local tTmp = ObjFilterByColor(aObj, "绿")
  local nAttackNum = 5
  local nLv = #tTmp
  if nLv > 0 then
    if nAttackNum > nLv then
      nAttackNum = nLv
    end
    self:UseSkillPet(false)
    for i = 1, nAttackNum do
      self:OnPetAttack(tTmp[i].id)
    end
    self:UseSkillPet(true, tTmp[1].x, tTmp[1].y)
  elseif nAll > 0 then
    BubbleByHP(aObj, 1)
    self:OnPetAttack(aObj[1].id)
    self:UseSkillPet(true, aObj[1].x, aObj[1].y)
    self:UseSkillPet(false)
  end
  if nLv <= 2 then
    self:checkfree()
  end
end

function CDG:MS_PetAndPlayer(aObj)
  local nAll = #aObj
  if nAll <= 0 then
    return
  end
  local tTmp = ObjFilterByColor(aObj, "绿")
  local tTmp2 = ObjFilterByInt(aObj, 5, 2, "dst")
  if #tTmp2 < 7 then
    local n = #tTmp
    if n > 5 then
      n = 5
    end
    for i = 1, n do
      self:OnPetAttack(tTmp[i].id)
      local nState = Player:GetState()
      if 0 == nState then
        BubbleByHP(tTmp2, 1)
        for j = 1, #tTmp2 do
          local tar = FindObjByTID(tTmp2[j].id)
          if tar and tar.hp > 0 then
            self:OnAttack(tTmp2[j].id, aObj)
            break
          end
        end
      end
    end
  end
  if #tTmp2 > 0 then
    BubbleByHP(tTmp2, 1)
    self:OnAttack(tTmp2[1].id, aObj)
  end
end

function CDG:MS_OnlyLeader(aObj)
  local leader, isleader = Team:GetLeaderInfo()
  if not leader or isleader then
    return
  end
  local findLeader = FindObjByGUID(leader.guid)
  if not findLeader then
    return
  end
  if 7 == findLeader.state then
    if findLeader.target >= 0 then
      self:OnAttack(findLeader.target, aObj)
    end
  elseif 7 == Player:GetState() then
    Target:StopAttack(500)
  else
    self:checkfree()
  end
end

function CDG:MS_ZhanShen(aObj)
  if 5 == g_self.menpai then
  end
  if self.tsys and 7 == g_self.menpai then
    if -1 == Player:GetBuff("隐身") then
      Skill:UseName("金蝉脱壳", 500)
    end
  else
    self:checkMapLeader()
    self:checkPosLeader()
  end
  Sleep(200)
end

function CDG:MS_QiangGuai(aObj)
  local nState = Player:GetState()
  if 9 == nState then
    self:SetGrab(false)
  else
    self:SetGrab(true)
    if 0 == nState then
      if g_self.isjingong and 0 ~= self.pet1.GUID and -1 ~= self.pet1.GUID and not self.jgyc and Skill.baseID_YC > 0 then
        self:MS_PetAndPlayer(aObj)
      else
        self:MS_FirstLvGuai(aObj, 2)
        Sleep(2000)
      end
    end
  end
end

function CDG:checktime0()
  local bEmSkillPet = false
  local add_hp_name = self:checkHP_Player()
  if "" == add_hp_name then
    bEmSkillPet = true
    self:checkHP(true)
  end
  self:checkMP(true)
  self:checkHP_Pet(bEmSkillPet)
  self:checkDXYS()
end

function CDG:checktime1()
  if self:IsOver() then
    return
  end
  if GetTickCount() - m_param.timeOut[1].last > m_param.timeOut[1].time then
    self:checkMap()
    self:checkPos()
    m_param.timeOut[1].last = GetTickCount()
  end
end

function CDG:checktime2()
  if self:IsOver() then
    return
  end
  if GetTickCount() - m_param.timeOut[2].last > m_param.timeOut[2].time then
    self:PickUp()
    if IsMount() and (self.sceneID < 0 or self.sceneID == GetSceneID()) then
      if self.sceneFollow and self.posFollow or self.attackMode == "站神模式" and self.posFollow then
        local leader, isleader = Team:GetLeaderInfo()
        if not leader or isleader then
          Dismount(300)
        else
          local findLeader = FindObjByGUID(leader.guid)
          if findLeader and findLeader.dst < 8 and 2 ~= findLeader.state and #self:EnumTarget() > 0 then
            Dismount(300)
          end
        end
      elseif self.scriptName == "刷怪" or self.scriptName == "刷怪神兵阁" then
        if #self.pos <= 1 or #self:EnumTarget() > 0 then
          Dismount(300)
        end
      elseif string.find(self.scriptName, "聚灵谷", nil, true) then
        if #self.pos <= 1 or #self:EnumTarget() > 0 then
          Dismount(300)
        end
      else
        Dismount(300)
      end
    end
    m_param.timeOut[2].last = GetTickCount()
  end
end

function CDG:checktime3()
  if self:IsOver() then
    return
  end
  if GetTickCount() - m_param.timeOut[3].last > m_param.timeOut[3].time then
    self:checkPetHappy(self.pet1.GUID)
    if self:checkPet1Play() then
      if #self.petArr > 0 then
        local levelNow = Pet:GetLevel(self.petArr[1].GUID)
        if levelNow >= self.petArr[1].needLevel then
          while Player:GetFightPetGUID() == self.petArr[1].GUID do
            Pet:Relax(500)
            PushDebugMessage("宠物等级已经达到:" .. self.petArr[1].needLevel)
          end
          self.pet1.GUID = -1
          if self.pet1.OldGUID == self.petArr[1].GUID then
            self.pet1.OldGUID = -1
          end
          table.remove(self.petArr, 1)
        else
          self.pet1.GUID = self.petArr[1].GUID
        end
      else
        self.pet1.GUID = self.pet1.OldGUID
      end
      self:checkPetPlay(self.pet1.GUID)
    end
    self:checkDie()
    self:checkRescue()
    self:checkBuJi()
    if self.moveFollow and #self.pos > 1 then
      Player:TeamFollow(false, 300)
    end
    m_param.timeOut[3].last = GetTickCount()
  end
end

function CDG:checktime4()
  if self:IsOver() then
    return
  end
  if GetTickCount() - m_param.timeOut[4].last > m_param.timeOut[4].time then
    self:checkWuYi()
    self:checkKillNum()
    self:checkEnergy()
    self:checkLevelUp()
    self:checkDouble()
    self:checkBagBack()
    self:PetAddAttribute()
    m_param.timeOut[4].last = GetTickCount()
  end
end

function CDG:checkSkill(aMust)
  if aMust or GetTickCount() - m_data.tick_check_skill > 45000 then
    if IsInDebugMsg("#{ResultText_3}") then
      DeleteDebugMsg("#{ResultText_3}")
      Skill:RefreshSkill()
    end
    m_data.tick_check_skill = GetTickCount()
  end
end

function CDG:checktime5()
  if self:IsOver() then
    return
  end
  if GetTickCount() - m_param.timeOut[5].last > m_param.timeOut[5].time then
    if self.attackMode ~= "珍兽单刷" and self.attackMode ~= "站神模式" and self.attackMode ~= "协助队长" then
      local tObj = Enum2XByClass(self.targetClass, {0, -1})
      tObj = ObjFilterByStr(tObj, self.targetName, self.targetType, "name")
      local mytid = Player:GetTID()
      local pettid = Pet:GetTID()
      local tAttack = {}
      for i = 1, #tObj do
        local tmp = tObj[i]
        if tmp.target == mytid or tmp.target == pettid then
          tAttack[#tAttack + 1] = tmp
        end
      end
      if #tAttack > 0 then
        BubbleByDst(tAttack)
        Target:Attack(tAttack[1].id, 350)
      end
    end
    m_param.timeOut[5].last = GetTickCount()
  end
end

function CDG:checkfree()
  if self.call.back1 == nil or self.call.back1() ~= false then
    self:checkDiFu()
    self:checkJianYu()
    self:SkillState()
    Bag_DeleteBagItem()
  end
end

function CDG:ModeAttack()
  local tObj = self:EnumTarget()
  if self.attackMode == "打死换怪" then
    self:MS_KillDie(tObj)
  elseif self.attackMode == "优先绿怪" then
    self:MS_FirstLvGuai(tObj)
  elseif self.attackMode == "优先满血" then
    self:MS_FirstHPMaxGuai(tObj)
  elseif self.attackMode == "珍兽单刷" then
    self:MS_OnlyPet(tObj)
  elseif self.attackMode == "宠拉人打" then
    self:MS_PetAndPlayer(tObj)
  elseif self.attackMode == "协助队长" then
    self:MS_OnlyLeader(tObj)
  elseif self.attackMode == "站神模式" then
    self:MS_ZhanShen(tObj)
  elseif self.attackMode == "普通抢怪" then
    self:MS_QiangGuai(tObj)
  elseif self.attackMode == "超级抢怪" then
    self:MS_QiangGuai(tObj)
  else
    self:MS_KillDie(tObj)
  end
  return tObj
end

function CDG:OnStart()
  m_param.over = false
  m_param.overthislopp = false
  while true do
    self:checktime0()
    self:checktime1()
    self:checktime2()
    self:checktime3()
    self:checktime4()
    self:checktime5()
    if m_param.overthislopp or m_param.over then
      break
    end
    Sleep(50)
    local tObj = self:ModeAttack()
    if 0 == #tObj then
      self:checkfree()
    end
    if m_param.overthislopp or m_param.over then
      break
    end
    if self.callfun then
      m_param.overthislopp = self.callfun()
      if m_param.overthislopp then
        break
      end
    end
  end
  self:SetGrab(false)
  local ret = m_param.over
  m_param.overthislopp = false
  m_param.over = false
  HuiShouLiRenOu()
  return ret
end

function CDG:BossStart(aTargetID, aUseSkill, aUseJinJiSkill, aCheckHpMpDx, aPetFightHappyDieOutBuji, aMustAttack, aPetSkill, aOnlyPetAttack)
  if not self.attack and not aMustAttack then
    aTargetID = -1
  end
  local aCheckMapPos = false
  local aCheckFree = false
  if -1 == aTargetID then
    aCheckFree = true
  end
  if nil == aUseSkill then
    aUseSkill = true
  end
  if nil == aCheckHpMpDx then
    aCheckHpMpDx = true
  end
  if nil == aPetFightHappyDieOutBuji then
    aPetFightHappyDieOutBuji = true
  end
  if nil == aPetSkill then
    aPetSkill = true
  end
  if aMustAttack then
    aPetFightHappyDieOutBuji = false
  end
  if -1 ~= aTargetID and not aMustAttack and g_config.nottongbu.fuben_ty_hongguai and self.scriptName ~= "" and "" ~= g_config.fuben.ty_hg_name then
    local allName = HandleText_AddFuHao(g_config.fuben.ty_hg_name, " ")
    local thisName = HandleText_AddFuHao(self.scriptName, " ")
    if string.find(allName, thisName, nil, true) then
      local tmp = FindObjByTID(aTargetID)
      if tmp then
        local tObj = {}
        table.insert(tObj, tmp)
        tObj = ObjFilterByColor(tObj, "红")
        if 0 == #tObj then
          aTargetID = -1
          DebugStr("副本:您已设置只打红怪,暂不攻击" .. tmp.name, 5)
        end
      end
    end
  end
  if -1 ~= aTargetID then
    if aOnlyPetAttack then
      self:OnPetAttack(aTargetID)
    else
      local add_hp_name = ""
      if 4 == g_self.menpai and CDG.hp.em_yxjx then
        add_hp_name = self:checkHP_Player()
      end
      if "" == add_hp_name or aMustAttack or 4 == g_self.menpai and Player:GetMP() < 2000 then
        Target:Attack(aTargetID, 200, self.tragetSelect, nil, self.jgyc)
        if aUseJinJiSkill then
          self:SkillJinJi(aTargetID)
        end
        self:checkHP_Pet(false)
        if aUseSkill then
          self:SkillAttack(aTargetID)
        end
      else
        DebugStr("副本峨嵋优先加血", 10)
      end
    end
    if aPetSkill then
      local obj = FindObjByTID(aTargetID)
      if obj then
        self:UseSkillPet(true, obj.x, obj.y)
        self:UseSkillPet(false)
      end
    end
  end
  if aCheckHpMpDx then
    self:checktime0()
  end
  if aPetFightHappyDieOutBuji then
    self:checktime3()
  end
  if aCheckMapPos then
    self:checktime1()
  end
  if aCheckFree then
    self:checkfree()
  end
end

function CDG:InitCommonParam()
  g_pick.ispick = true
  g_pick.check = false
  g_pick.filterMode = 0
  g_pick.pickmode = 0
  if g_config.item.pick_part then
    g_pick.pickmode = 1
  end
  self.skill_state = g_config.skill.shuaguai_zhuangtai
  self.skill_attack = g_config.skill.shuaguai_gongji
  self.pet1.GUID = g_config.protect.pet_chuzhan.guid
  self.pet1.OldGUID = self.pet1.GUID
  self.pet1.orgGUID = self.pet1.GUID
  self.pet2.GUID = g_config.protect.pet_gongsheng.guid
  self.pet3.GUID = g_config.protect.pet_xueji.guid
  self.pet1.skill = g_config.protect.pet_skill
  self.hp.qxpsz = g_config.protect.qingxin
  self.hp.cxyq = g_config.protect.chongxu
  self.hp.em_fgpz = g_config.protect.em_fgpz
  self.hp.em_pet = g_config.protect.em_pet
  self.hp.em_team = g_config.protect.em_team
  self.hp.em_raid = g_config.protect.em_raid
  self.hp.em_bh_self = g_config.protect.em_banghui_self
  self.hp.em_tm_self = g_config.protect.em_tongmeng
  self.hp.em_bh_id = ""
  if g_config.protect.em_banghui_other and #g_config.protect.em_banghui_other_ids > 0 then
    self.hp.em_bh_id = " " .. HandleText(g_config.protect.em_banghui_other_ids) .. " "
  end
  self.hp.em_namelist = ""
  if g_config.protect.em_check_mingdan then
    self.hp.em_namelist = Array2Text(g_config.protect.em_mingdan, " ", "text")
  end
  self.hp.em_firstlist_name = ""
  self.hp.em_firstlist_cmp = HandleTextToNumber(g_config.protect.em_first_hpp)
  if g_config.protect.em_check_first then
    self.hp.em_firstlist_name = Array2Text(g_config.protect.em_first_mingdan, " ", "text")
  end
  self.hp.em_yxjx = g_config.fuben.ty_em_yxjx
  self.hp.cmp = HandleTextToNumber(g_config.protect.hpp)
  self.mp.cmp = HandleTextToNumber(g_config.protect.mpp)
  self.hp.petcmp = HandleTextToNumber(g_config.protect.hpp_pet)
  self.hp.hpskill = g_config.protect.hp_skill
  self.hp.pet_first_kl = g_config.protect.first_kouliang
end

function CDG:PetParamOther()
  if not g_config.protect.pet_chuzhan_fb or -1 == g_config.protect.pet_chuzhan_fb.guid then
  elseif 0 == g_config.protect.pet_chuzhan_fb.guid then
    self.pet1.GUID = 0
    self.pet1.OldGUID = self.pet1.GUID
  else
    self.pet1.GUID = g_config.protect.pet_chuzhan_fb.guid
    self.pet1.OldGUID = self.pet1.GUID
  end
end

function CDG:InitFubenParam()
  self.skill_attack = g_config.skill.fuben_gongji
  self.skill_state = g_config.skill.fuben_zhuangtai
  self.tragetSelect = g_config.fuben.ty_select_target
  self.pickup = true
  self.attack = true
  self.die.out = false
  self.die.waittime = -1
  self.die.maxCount = 0
  self.back.buypetRation = false
  self.back.buypetHappy = false
  self.back.buyhy = false
  self.back.fullprop = false
  self.back.fullmate = false
  self.back.fullbag = false
  self.level.check = false
  self.savebank = false
  self.buji = false
  self.energy.check = false
end

function UIPosListToTable(aUIPosList)
  local posArr = {}
  for i = 1, #aUIPosList do
    local tmp = aUIPosList[i]
    if 3 == #tmp then
      local strPosX = tonumber(tmp[2])
      local strPosY = tonumber(tmp[3])
      if strPosX and strPosY then
        local pos = {}
        pos.x = strPosX
        pos.y = strPosY
        posArr[#posArr + 1] = pos
      end
    end
  end
  return posArr
end

function CDG:InitUpgradePet()
  self.petArr = {}
  local strpet = GetLuaValue("return meGetLevelUpPet()", "s")
  local arrPet = SplitString(strpet, " ", true)
  for i = 1, #arrPet do
    local arrInfo = SplitString(arrPet[i], "&", true)
    if #arrInfo >= 3 then
      local nIndex = tonumber(arrInfo[1])
      local nGuid = tonumber(arrInfo[2])
      local nNeedLevel = tonumber(arrInfo[3])
      if nGuid and nNeedLevel then
        table.insert(self.petArr, {GUID = nGuid, needLevel = nNeedLevel})
      end
    end
  end
end

function CDG:InitDaguaiParam()
  self.attackMode = "打死换怪"
  if g_config.shuaguai.mode_youxianlvguai then
    self.attackMode = "优先绿怪"
  elseif g_config.shuaguai.mode_xiezhuduizhang then
    self.attackMode = "协助队长"
  elseif g_config.shuaguai.mode_zhanshen then
    self.attackMode = "站神模式"
  elseif g_config.shuaguai.mode_petdanshua then
    self.attackMode = "珍兽单刷"
  elseif g_config.shuaguai.mode_chonglarenda then
    self.attackMode = "宠拉人打"
  elseif g_config.shuaguai.mode_qiangguai_1 then
    self.attackMode = "普通抢怪"
  elseif g_config.shuaguai.mode_qiangguai_2 then
    self.attackMode = "超级抢怪"
  end
  if g_config.shuaguai.current_scene then
    self.sceneID = GetSceneID()
    self.sceneName = GetCurrentSceneName()
    self.sceneName = string.gsub(self.sceneName, "1线", "")
    self.sceneName = string.gsub(self.sceneName, "2线", "")
  else
    if 0 == g_config.shuaguai.scene.sel then
      self.sceneName = ""
    else
      self.sceneName = g_config.shuaguai.scene.text
    end
    self.sceneID = GetSceneIDByName(self.sceneName)
  end
  self.posFollow = g_config.shuaguai.follow_leader_pos
  self.sceneFollow = g_config.shuaguai.follow_leader_scene
  if not self.posFollow then
    self.sceneFollow = false
  end
  if self.posFollow and self.sceneFollow then
    self.sceneName = ""
    self.sceneID = -1
  end
  self.moveFollow = g_config.shuaguai.move_follow
  if g_config.shuaguai.current_pos then
    local pos = Player:GetPos()
    self.pos[#self.pos + 1] = pos
  else
    self.pos = UIPosListToTable(g_config.shuaguai.mulit_poslist)
  end
  self.posRadius = HandleTextToNumber(g_config.shuaguai.banjing, 5)
  self.tulingzhu = g_config.shuaguai.item_backpos
  if g_config.shuaguai.check_only_name then
    self.targetName = HandleText(g_config.shuaguai.only_name)
    self.targetName = HandleText_AddFuHao(self.targetName, " ")
  end
  if g_config.shuaguai.only_red_monster then
    self.targetOwer = "红"
  elseif g_config.shuaguai.only_white_monster then
    self.targetOwer = "白"
  else
    self.targetOwer = "红绿"
  end
  self.dxys = g_config.shuaguai.diaoxueyinshen
  self.pickup = g_config.shuaguai.pickup
  self.double.tld = g_config.shuaguai.exp_item_t
  self.double.xdld = g_config.shuaguai.exp_item_d
  self.double.xld = g_config.shuaguai.exp_item_x
  self.double.xyd = g_config.shuaguai.exp_item_x
  self.double.xly = g_config.shuaguai.exp_item_x
  self.double.jly = g_config.shuaguai.exp_item_x
  self.double.cww = g_config.shuaguai.exp_item_x
  self.double.sww = g_config.shuaguai.exp_item_x
  self.double.exp = g_config.shuaguai.exp_double
  self.tsys = true
  self.level.check = g_config.shuaguai.check_levelup
  self.level.cmp = HandleTextToNumber(g_config.shuaguai.levelup_count)
  self.petattr = g_config.shuaguai.petaddattr
  self.maxKillNum = -1
  if g_config.shuaguai.over_check_monster_count then
    self.maxKillNum = HandleTextToNumber(g_config.shuaguai.over_monster_count)
  end
  self.wuyi = g_config.shuaguai.over_check_wuyi
  self.die.out = g_config.shuaguai.die_out
  self.die.waittime = HandleTextToNumber(g_config.shuaguai.die_wait_time)
  self.die.maxCount = 0
  if g_config.shuaguai.over_check_die then
    self.die.maxCount = HandleTextToNumber(g_config.shuaguai.over_die_count)
  end
  self.energy.check = g_config.shuaguai.over_check_jingli
  self.energy.cmp = g_config.shuaguai.over_jingli_value
  self.back.buypetRation = g_config.shuaguai.buji_chongliang
  self.back.buyhy = g_config.shuaguai.buji_hp
  self.back.buypetHappy = g_config.shuaguai.buji_huixuanjinqiu
  self.back.fullprop = false
  self.back.fullmate = false
  self.back.fullbag = false
  if g_config.shuaguai.check_bag_full then
    self.back.fullprop = g_config.shuaguai.check_bag_full_daoju
    self.back.fullmate = g_config.shuaguai.check_bag_full_cailiao
    self.back.fullbag = g_config.shuaguai.check_bag_full_all
  end
  self.rescue = g_config.shuaguai.die_rescue
  self.savebank = true
  self.pet1.kouliang = g_config.protect.buy_pet_type1.text
  if g_config.shuaguai.pet_level_up then
    self:InitUpgradePet()
  end
end

function ParamInitUpgradePet(aScriptName)
  if g_config.tysz.upgrade_pet_all then
    CDG:InitUpgradePet()
  elseif g_config.tysz.upgrade_pet then
    local allScript = HandleText_AddFuHao(g_config.tysz.upgrade_pet_script, " ", true)
    if string.find(allScript, " " .. aScriptName .. " ", nil, true) then
      CDG:InitUpgradePet()
    end
  end
end

function BeginAttack(pos, sceneName, strTargetName, callback_over, callback_move, tParam)
  tParam = tParam or {}
  CDG.pos = pos or {}
  CDG.posIdx = tParam.posIdx or 1
  CDG.posRadius = tParam.posRadius or 15
  CDG.sceneName = sceneName or ""
  CDG.sceneID = GetSceneIDByName(CDG.sceneName)
  CDG.targetName = strTargetName or ""
  if "" ~= CDG.targetName then
    CDG.targetName = HandleText_AddFuHao(CDG.targetName, " ")
  end
  CDG.callfun = callback_over or nil
  CDG.callfun_move = callback_move or nil
  CDG.tragetSelect = true
  CDG.attack = true
  CDG.die.out = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  CDG.attackMode = tParam.attackMode or "打死换怪"
  CDG.pickup = false
  CDG.horse = true
  if tParam.pickup ~= nil then
    CDG.pickup = tParam.pickup
  end
  if tParam.horse ~= nil then
    CDG.horse = tParam.horse
  end
  CDG:OnStart()
end

CDG:Init()
