-- 反编译自 dfz64.dll 内嵌字节码 0037edf5（unluac 2025-12-23；仅供分析）
local m_script_name = "拭剑天下"
ScriptOnStart(m_script_name, true, false)
CDG:PetParamOther()
CDG.attack = true
local m_npc = {
  {
    x = 296,
    y = 225,
    sceneID = LUOYANG_ID,
    name = "周伯衡"
  },
  {
    x = 293,
    y = 229,
    sceneID = 1,
    name = "周仲青"
  },
  {
    x = 185,
    y = 98,
    sceneID = 2,
    name = "周颐真"
  },
  {
    x = 183,
    y = 102,
    sceneID = 2,
    name = "周叔彬"
  }
}

local function SJTX_CheckLeiTaiPos(aPos)
  if aPos.x > 0 then
    return true
  end
  return false
end

local function SJTX_IsCurrentOver()
  local nMsgTime = IsInDebugMsg("#{SCGZ_180816_47")
  if nMsgTime and os.time() - nMsgTime < 35 then
    return true
  end
  return false
end

local function SJTX_FindAttack()
  local tAtkObj = EnumAttackObj("玩家 珍兽", {0, -1})
  local tPlayer = ObjFilterByStr(tAtkObj, "玩家", 1, "class")
  local tAtkPet = ObjFilterByStr(tAtkObj, "珍兽", 1, "class")
  local tAtkPlayer = {}
  for i = 1, #tPlayer do
    local tmp = tPlayer[i]
    if SJTX_CheckLeiTaiPos(tmp) then
      table.insert(tAtkPlayer, tmp)
    end
  end
  local tKillPlayer = {}
  for i = 1, #tAtkPlayer do
    local tmp = tAtkPlayer[i]
    local bKongZhi, bFangDa, bWuDi, bZuoQi = Target:GetSpecialBuff(tmp)
    if false == bWuDi then
      tmp.fangda = bFangDa
      table.insert(tKillPlayer, tmp)
    end
  end
  return tAtkPlayer, tKillPlayer
end

local function SJTX_OnAttack(aTarget)
  local tid = aTarget.id
  while 9 ~= Player:GetState() and false == SJTX_IsCurrentOver() and (GetSceneID() == 1019 or GetSceneID() == 974 or GetSceneID() == 1074) and SJTX_CheckLeiTaiPos(Player:GetPos()) do
    local tAtkPlayer, tKillPlayer = SJTX_FindAttack()
    local tFangDaPlayer = {}
    for i = 1, #tKillPlayer do
      local tmp = tKillPlayer[i]
      if tmp.fangda then
        table.insert(tFangDaPlayer, tmp)
      end
    end
    if false == g_self.isjingong then
      local newtid = tid
      if #tFangDaPlayer > 0 then
        newtid = tFangDaPlayer[1].id
        if newtid ~= tid then
          PushColorMsg("拭剑天下：对方阵营有玩家被放大,切换目标")
        end
      end
      local tFD = GetTableFieldValue(tFangDaPlayer, "id", {tid})
      if #tFD > 0 then
        newtid = tFD[1].id
      end
      tid = newtid
    elseif #tFangDaPlayer > 0 and tFangDaPlayer[1].dst < 3 then
      if tFangDaPlayer[1].id ~= tid then
        PushColorMsg("拭剑天下：对方有玩家被放大,切换目标!!!")
      end
      tid = tFangDaPlayer[1].id
    end
    local add_hp_name = CDG:checkHP_Player()
    if "" == add_hp_name then
      CDG:checkHP(false)
    end
    CDG:checkMP(false)
    local target = FindObjByTID(tid)
    if not target or 0 == target.hp then
      break
    end
    if false == SJTX_CheckLeiTaiPos(target) then
      PushDebugMessage(target.name .. ":已死亡出窍")
      break
    end
    local bKongZhi, bFangDa, bWuDi, bZuoQi = Target:GetSpecialBuff(target)
    if false == bWuDi then
      if Player:GetDataInt("MP") > 500 then
        if false == bKongZhi then
          Skill:UseKongZhi(g_config.skill.pk_kongzhi, target, false)
        end
        XiShanXingLv(target.id, true)
        CDG:SkillAttack(target.id)
        if g_self.isjingong and #tFangDaPlayer > 0 and tFangDaPlayer[1].id ~= target.id then
          PushColorMsg("拭剑天下：近攻对被放大目标远程打击")
          JinGongFarSkill(tFangDaPlayer[1].id)
        end
      end
    else
      PushDebugMessage(target.name .. ":处于无敌状态,切换目标")
      break
    end
    if g_self.isjingong then
      local dist = GetDist(target.x, target.y)
      if dist > 17 then
        Skill:UseSpeed()
        RunTo(target.x, target.y, 3, 500)
      elseif dist > 10 then
        FastRun(target, 4)
      elseif dist > 5 then
        Skill:UseSpeed()
      end
    elseif GetDist(target.x, target.y) > 12 then
      RunTo(target.x, target.y, 10, 500)
    end
    Target:Attack(target.id, 200, true)
    StateRemoveBad(true, true, true, true, true)
    Sleep(50)
    DebugStr("拭剑天下：正在与 %s PK,使用PK技能", 3, target.name)
  end
end

local function SJTX_Obj_fangda(aObj)
  local tFangDa = {}
  for i = 1, #aObj do
    if aObj[i].fangda then
      table.insert(tFangDa, aObj[i])
    end
  end
  return tFangDa
end

local function SJTX_Obj_menpai(aObj, aYXMenPai)
  local tMenPai = {}
  for i = 1, #aObj do
    local strMenPai = GetMenpaiNameByTypeID(aObj[i].menpai)
    if "" ~= strMenPai and string.find(aYXMenPai, " " .. strMenPai .. " ", nil, true) then
      table.insert(tMenPai, aObj[i])
    end
  end
  return tMenPai
end

local function SJTX_Obj_hp_little(aObj)
  local tDiXue = {}
  for i = 1, #aObj do
    if aObj[i].hp < 30 and aObj[i].hp > 0 then
      table.insert(tDiXue, aObj[i])
    end
  end
  return tDiXue
end

local function SJTX_Obj_Sort(aObj, aMode, aYXMenPai, aYXName)
  local tRet = {}
  if "放大" == aMode then
    tRet = SJTX_Obj_fangda(aObj)
  elseif "门派" == aMode then
    tRet = SJTX_Obj_menpai(aObj, aYXMenPai)
  elseif "低血" == aMode then
    tRet = SJTX_Obj_hp_little(aObj)
  end
  return tRet
end

local function SJTX_TargetSort(aObj, aSortMode, aYXMenPai, aYXName)
  local sort_mode = aSortMode or {
    "放大",
    "门派",
    "低血"
  }
  local sort_menpai = aYXMenPai or " 峨嵋 "
  local sort_name = aYXName or ""
  local tFilter = {}
  local tLast = aObj
  for i = 1, #sort_mode do
    tFilter = SJTX_Obj_Sort(tLast, sort_mode[i], sort_menpai, sort_name)
    if #tFilter > 0 then
      tLast = tFilter
    end
  end
  return tLast
end

local function SJTX_OnAction()
  local runpos = {
    {x = 95, y = 95},
    {x = 95, y = 95}
  }
  local idx = 1
  while 9 ~= Player:GetState() and false == SJTX_IsCurrentOver() and (GetSceneID() == 1019 or GetSceneID() == 974 or GetSceneID() == 1074) and SJTX_CheckLeiTaiPos(Player:GetPos()) do
    PushColorMsg("zenme")
    local tAtkPlayer, tKillPlayer = SJTX_FindAttack()
    if 0 == #tAtkPlayer then
      PushColorMsg("没目标")
      CDG:checktime0()
    else
      if #tAtkPlayer > 0 then
        local tAttack = tAtkPlayer
        if #tKillPlayer > 0 then
          tAttack = tKillPlayer
        end
        BubbleByDst(tAttack, 1)
        if tAttack[1].dst <= 18 then
          PushColorMsg("有目标")
          local tKill_ = SJTX_TargetSort(tAttack)
          SJTX_OnAttack(tKill_[1])
        else
          RunTo(tAttack[1].x, tAttack[1].y, 10, 800)
        end
      end
      local add_hp_name = CDG:checkHP_Player()
      if "" == add_hp_name then
        CDG:checkHP(false)
      end
      CDG:checkMP(false)
    end
    Sleep(50)
    DebugStr("拭剑天下:战斗中")
  end
end

local function sjtx_callback(fX, fY, nScene)
  local strSceneName = GetCurrentSceneName()
  if string.find(strSceneName, "休息室", nil, true) then
    return false
  end
  if GetSceneID() == 1019 or GetSceneID() == 974 or GetSceneID() == 1074 then
    return false
  end
  return true
end

local function SJTX_GetYuBeiShiNpc()
  local pos = Player:GetPos()
  local npc = {
    index = -1,
    x = -1,
    y = -1
  }
  if pos.y > 4 and pos.y < 68 then
    if pos.x > 4 and pos.x < 68 then
      npc.index = 1
      npc.x = 36
      npc.y = 14
      return npc
    end
    if pos.x > 96 and pos.x < 163 then
      npc.index = 2
      npc.x = 132
      npc.y = 14
      return npc
    end
    if pos.x > 186 and pos.x < 254 then
      npc.index = 3
      npc.x = 219
      npc.y = 14
      return npc
    end
  end
  if pos.y > 100 and pos.y < 158 then
    if pos.x > 4 and pos.x < 67 then
      npc.index = 4
      npc.x = 36
      npc.y = 107
      return npc
    end
    if pos.x > 96 and pos.x < 163 then
      npc.index = 5
      npc.x = 132
      npc.y = 107
      return npc
    end
    if pos.x > 186 and pos.x < 254 then
      npc.index = 6
      npc.x = 219
      npc.y = 107
      return npc
    end
  end
  if pos.y > 186 and pos.y < 254 then
    if pos.x > 4 and pos.x < 67 then
      npc.index = 7
      npc.x = 36
      npc.y = 197
      return npc
    end
    if pos.x > 96 and pos.x < 163 then
      npc.index = 8
      npc.x = 132
      npc.y = 197
      return npc
    end
    if pos.x > 186 and pos.x < 254 then
      npc.index = 9
      npc.x = 219
      npc.y = 197
      return npc
    end
  end
  return npc
end

function _SMain(...)
  CDG.skill_state = g_config.skill.pk_zhuangtai
  CDG.skill_attack = g_config.skill.pk_gongji
  local idx = -1
  local nLevel = Player:GetDataInt("LEVEL")
  if nLevel >= 60 and nLevel <= 69 then
    idx = 3
    PushDebugMessage(m_script_name .. ":前往大理擂台")
  elseif nLevel >= 70 and nLevel <= 89 then
    idx = 2
    PushDebugMessage(m_script_name .. ":前往苏州擂台")
  elseif nLevel >= 90 and nLevel <= 119 then
    idx = 1
    PushDebugMessage(m_script_name .. ":前往洛阳擂台")
  elseif nLevel >= 120 then
    idx = 4
    PushDebugMessage(m_script_name .. ":前往大理擂台")
  else
    PushDebugMessage(m_script_name .. ":等级不符合 " .. nLevel)
    return
  end
  local bOver = false
  local hasOverMsg = false
  local nTickZhanDou = -1
  while true do
    local nMsgTime = IsInDebugMsg("#{BWDH_180804_66")
    if nMsgTime and os.time() - nMsgTime < 3600 then
      hasOverMsg = true
      bOver = true
    end
    local strSceneName = GetCurrentSceneName()
    if string.find(strSceneName, "休息室", nil, true) then
      PushColorMsg("休息室中")
      Sleep(3000)
      if -1 == nTickZhanDou then
        nTickZhanDou = GetTickCount()
      end
      if GetTickCount() - nTickZhanDou > 3600000 then
        hasOverMsg = true
        bOver = true
      end
      if hasOverMsg then
        PushColorMsg("拭剑天下：已完成")
        local npc = SJTX_GetYuBeiShiNpc()
        if -1 ~= npc.index and RunTo(npc.x, npc.y, 3, 600) == false then
          TalkNpc("擂台指引使")
          Sleep(500)
          QuestFrameOptionClicked_Item("#{BWDH_180804_71}", 1, 800)
          QuestFrameOptionClicked_Item("#{BWDH_180804_71}", 1, 800)
        end
      end
      FubenAttack(-1)
    elseif GetSceneID() == 1019 or GetSceneID() == 974 or GetSceneID() == 1074 then
      nTickZhanDou = -1
      bOver = true
      PushColorMsg("战场中")
      if -1 ~= Player:GetBuff("战斗准备") then
        FubenAttack(-1)
        Sleep(500)
        GivePlayerState("百毒不侵", 5, false)
        GivePlayerState("正气浩然", 6, false)
        GivePlayerState("冰肌玉骨", 7, false)
        GivePlayerState("墨守成规", 8, false)
      elseif 9 ~= Player:GetState() and false == SJTX_IsCurrentOver() and SJTX_CheckLeiTaiPos(Player:GetPos()) then
        SJTX_OnAction()
      else
        Sleep(1000)
      end
      nTickZhanDou = -1
    else
      local nScene = GetSceneID()
      if (nScene == LUOYANG_ID or 1 == nScene or 2 == nScene) and bOver then
        PushColorMsg("拭剑天下：您已离开战场！")
        break
      end
      local npc = m_npc[idx]
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, sjtx_callback)
      Sleep(800)
      QuestFrameOptionClicked_Item("#{BWDH_180804_11", 3, 1000)
      Sleep(2000)
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
  Team:LeaveTeam()
  if 1 == GetSceneID() then
    local tab = GetTableFieldValue(g_MenPaiInfo, "menpaiID", {
      g_self.menpai
    })
    if #tab > 0 then
      local tmp = tab[1]
      
      local function _cb()
        if GetSceneID() == tmp.sceneID then
          local pos = Player:GetPos()
          RunTo(pos.x - 1, pos.y - 1, 0, 800)
          RunTo(pos.x + 1, pos.y + 1, 0, 800)
          return false
        end
        return true
      end
      
      MoveTo(123, 123, tab[1].sceneID, nil, nil, nil, _cb)
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, false)
Team:LeaveTeam()
