-- 反编译自 dfz64.dll 内嵌字节码 002cfcf9（unluac 2025-12-23；仅供分析）
local m_script_name = "剑破明王境"
ScriptOnStart(m_script_name, true, true)
g_pick.pickmode = 0
local m_param = {}
m_param.btxd_safe = false
m_param.hsFollow = false
m_param.xmxl = 1
m_param.xmsh = 1
m_param.xmkb = 1
m_param.xmxjzh = 1
m_param.xmzmhg = 1
m_param.xmzjzh = 1
m_param.callback = nil
m_param.xiaohao = false
m_param.boss4longzhu = false
m_param.zhidia = false
m_param.sceneID = 934
m_param.attack_dz = " #{PTFB_191228_307} #{PTFB_191228_308} #{PTFB_191228_309} #{PTFB_191228_310} #{PTFB_191228_311} #{PTFB_191228_312} #{PTFB_191228_313} #{PTFB_191228_314} #{PTFB_191228_315} #{PTFB_191228_316} #{PTFB_191228_317} #{PTFB_191228_318} #{PTFB_191228_319} "
m_param.ladcq = false
m_param.bosshp = 20
local m_teamCount = 3
local m_last_step = -1
local m_next_step = -1
local m_tonext_tick = -1
local m_npcpos = {
  {x = 81, y = 250},
  {x = 127, y = 223.5},
  {x = 60, y = 124},
  {x = 72, y = 50},
  {x = 158, y = 121},
  {x = 256, y = 173},
  {x = 244, y = 61}
}

local function MWJ_BossDaZao(aBossID, aCheck4)
  if m_param.xmxl < 1 or m_param.xmxl > 4 then
    m_param.xmxl = 1
  end
  if m_param.xmsh < 1 or m_param.xmsh > 4 then
    m_param.xmsh = 1
  end
  if m_param.xmkb < 1 or m_param.xmkb > 4 then
    m_param.xmkb = 1
  end
  if aCheck4 < 1 or aCheck4 > 4 then
    aCheck4 = -1
  end
  local strText = fmt([[
    Clear_XSCRIPT()
		Set_XSCRIPT_Function_Name( "BossChoiceConfirm" )
		Set_XSCRIPT_ScriptID( 998947)	
		Set_XSCRIPT_Parameter( 0 ,%d)
		Set_XSCRIPT_Parameter( 1 ,%d)
		Set_XSCRIPT_Parameter( 2 ,%d)
		Set_XSCRIPT_Parameter( 3 ,%d)
		Set_XSCRIPT_Parameter( 4 ,%d)
		Set_XSCRIPT_ParamCount( 5 )
	Send_XSCRIPT()        
    ]], aBossID, m_param.xmxl, m_param.xmsh, m_param.xmkb, aCheck4)
  GetLuaValue(strText)
  Sleep(1000)
end

local function MWJ_RefreshStep(aName)
  if "田晓宇" == aName or "慕容复·影" == aName or "庞企·影" == aName or "丁春秋·影" == aName then
    m_tonext_tick = -1
    m_last_step = 1
  elseif "刘昌浩" == aName or "大轮寺梵僧" == aName then
    m_tonext_tick = -1
    m_last_step = 2
  elseif "董思" == aName or "裂海玄蜥·影" == aName or "裂海魔龙·影" == aName or "灭世火凤·影" == aName or "炼狱凤凰·影" == aName or "摄灵蛊花·影" == aName or "噬魂花妖·影" == aName then
    m_tonext_tick = -1
    m_last_step = 3
  elseif "赵博" == aName or "锡杖" == aName or "净瓶" == aName or "金刚杵" == aName or "智慧剑" == aName then
    m_tonext_tick = -1
    m_last_step = 4
  elseif "李欣泽" == aName or "李秋水·影" == aName or "天山童姥·影" == aName or "无崖子·影" == aName or "虚竹·影" == aName then
    m_tonext_tick = -1
    m_last_step = 5
  elseif "叶秋霜" == aName or "莲花灯" == aName then
    m_tonext_tick = -1
    m_last_step = 6
  elseif "彭靖" == aName or "燕驰野·影" == aName or "唐简·影" == aName or "慕容信·影" == aName or "霜见·影" == aName then
    m_tonext_tick = -1
    m_last_step = 7
  end
end

local function YZW_step3_runsafe_dzxy()
  local zero = m_npcpos[1]
  if GetDist(zero.x, zero.y) > 7 then
    RunTo(zero.x, zero.y, 0, 200)
  else
    local pos = Player:GetPos()
    RunTo(zero.x, pos.y + 1, 0, 200)
  end
end

local function YZW_step3_btxd_runpos(xNpc, yNpc, bIsKeepDist)
  local zero = m_npcpos[1]
  local xRun = zero.x
  local yMin = zero.y - 12
  local yMax = zero.y + 12
  local safedist = 10
  if bIsKeepDist then
    safedist = 7
    yMin = zero.y - 7
    yMax = zero.y + 7
  end
  local pos = Player:GetPos()
  local safepos = {}
  for i = 1, yMax - yMin do
    if safedist <= GetDist(xRun, yMin + i, xNpc, yNpc) then
      local dist = GetDist(pos.x, pos.y, xRun, yMin + i)
      table.insert(safepos, {
        x = xRun,
        y = yMin + i,
        dst = dist
      })
    end
  end
  BubbleByDst(safepos, 1)
  return safepos
end

local function YZW_step3_boss_keepdist(aBoss, aKeepdist)
  if g_self.isjingong == false and aKeepdist > GetDist(aBoss.x, aBoss.y) and aBoss.target ~= Player:GetTID() then
    local safepos = YZW_step3_btxd_runpos(aBoss.x, aBoss.y, true)
    if #safepos > 0 then
      local run = safepos[1]
      RunTo(run.x, run.y, 0, 1000)
      DebugStr("远攻远离boss进行攻击", 3)
      return false
    end
  end
  return true
end

local function YZW_step3_mrfhp50(aBoss)
  return true, true
end

local function MWJ_Boss1_MRF_dzxy(aBoss, aDzxyTick)
  if Target:FindBuff(aBoss, "斗转星移") then
    aDzxyTick = GetTickCount()
    YZW_step3_runsafe_dzxy()
    if Player:IsLeader() then
      Player:TeamFollow(true)
      Sleep(700)
      Player:TeamFollow(false)
      Sleep(300)
    end
    Pet:CheckRelax(aBoss.id, 2)
    local bSafe = true
    while true do
      local tObj = Enum2XByName("慕容复·影", {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if 0 == #tObj then
        break
      end
      local tmp = tObj[1]
      if bSafe and Target:FindBuff(tmp, "斗转星移") == false then
        break
      end
      if 7 == Player:GetState() then
        Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 200)
        YZW_step3_runsafe_dzxy()
      else
        if tmp.hp < 50 and not m_param.btxd_safe then
          YZW_step3_boss_keepdist(tmp, 7)
        end
        local bcheckpet = true
        FubenAttack(-1, nil, nil, true, bcheckpet)
        CDG:checktime0()
        CDG:checktime0()
        CDG:checkPetHappy(CDG.pet1.GUID)
      end
      if Target:FindBuff(tmp, "斗转星移") then
        CDG:SetActionTick(true)
        aDzxyTick = GetTickCount()
      end
      bSafe = YZW_step3_mrfhp50(tmp)
      Sleep(50)
      DebugStr("燕子坞：等待斗转星移", 2)
    end
  end
  return aDzxyTick
end

local function MWJ_Boss1_MRF()
  CDG.call.back1 = nil
  CDG.skill_attack_jinji_disable = " 横扫乾坤 三阳开泰 连珠腐尸毒 暗器连击 金顶绵掌 步步生花 "
  local nDzxyTick = -1
  local debugnote = ""
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName("慕容复·影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      local tmp = tObj[1]
      local bSafe, bAttack = YZW_step3_mrfhp50(tmp)
      if false == bAttack then
        debugnote = " 正在移动"
        tmp.id = -1
      end
      if false == bSafe then
        debugnote = " 躲避冰天雪地"
        if g_self.isjingong then
          tmp.id = -1
        end
      end
      nDzxyTick = MWJ_Boss1_MRF_dzxy(tmp, nDzxyTick)
      if -1 ~= nDzxyTick then
        local nDiff = GetTickCount() - nDzxyTick
        local bUseSkill = false
        if nDiff < 9000 then
          bUseSkill = true
          if nDiff < 600 then
            tmp.id = -1
          else
          end
        end
        FubenAttack(tmp.id)
      else
        FubenAttack(tmp.id)
      end
    else
      break
    end
    Sleep(200)
    DebugStr("第一重:慕容复·影")
  end
  CDG.call.back1 = nil
  CDG.skill_attack_jinji_disable = ""
end

local function SJZ_Boss4_longzhu()
  local nowtick = GetTickCount()
  local pos_longzhu = {
    {x = 92, y = 254},
    {x = 92, y = 254},
    {x = 69, y = 254},
    {x = 69, y = 254},
    {x = 80, y = 242}
  }
  local timeout = 8
  local longzhu = {}
  local tmp = {
    msgtime = -1,
    msg = "",
    tick = -1
  }
  for i = 1, 5 do
    tmp.msgtime, tmp.msg, tmp.tick = IsInDebugMsg(fmt("SJZ_100129_7%d", 2 + i))
    if tmp.msgtime and timeout > os.time() - tmp.msgtime then
      table.insert(longzhu, {
        dst = tmp.msgtime,
        x = pos_longzhu[i].x,
        y = pos_longzhu[i].y
      })
    end
  end
  BubbleByDst(longzhu, 2)
  return longzhu
end

local function SJZ_Boss4_teamOK(startTick)
  return true
end

local function SJZ_Boss4_CDG_cb()
  local bossname = "庞企·影"
  local pos_zero = m_npcpos[1]
  pos_zero.r = 15
  local bSafe, tSpecial = FubenTrapRun(bossname, pos_zero.x, pos_zero.y, 6, pos_zero.r, nil, nil, FubenRunSafe)
  return bSafe, tSpecial
end

local function SJZ_Boss4()
  CDG.call.back1 = SJZ_Boss4_CDG_cb
  local bossname = "庞企·影"
  local pos_zero = m_npcpos[1]
  local nIndex = Team:GetMyIndex()
  local runpos = GetAveragePoint(pos_zero.x, pos_zero.y, 3, 6, 0)
  local startWaitTick = -1
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("星罗武士", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if 0 == #tObj then
      tObj = Enum2XByName(bossname, {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
    end
    local longzhu = SJZ_Boss4_longzhu()
    local bSafe, tSpecial = SJZ_Boss4_CDG_cb()
    if 0 == #tSpecial and 0 == #tObj and 0 == #longzhu then
      PushDebugMessage("没有找到Boss庞企")
      break
    end
    if bSafe then
      if #tObj > 0 then
        local bJinJiSkill = false
        local bMustAttack = false
        local bCheckMP = true
        local bXiaoGuai = false
        if "星罗武士" == tObj[1].name then
          bXiaoGuai = true
          bCheckMP = false
          bJinJiSkill = true
          debugnote = ",甩技能"
          bMustAttack = true
          if g_self.isjingong then
            Skill:UseSpeed()
          end
          if 8 == g_self.menpai and m_param.xiaohao == false then
            Skill:UseName("定海神针", 300)
            Skill:UseName("步步生花", 300)
          end
          CDG.skill_attack_jinji_disable = " 暗器连击 "
          if tObj[1].dst < 6 and 4 == g_self.menpai then
            Skill:UseName("月落西山", 300)
          end
          if g_self.isjingong then
            GetAllPosDist(tObj)
            BubbleByDst(tObj, 1)
            if tObj[1].dst > 5 then
              JinGongFarSkill(tObj[1].id)
            else
            end
          end
        elseif tObj[1].hp > 80 then
          CDG.skill_attack_jinji_disable = "横扫乾坤 真武七截阵 三阳开泰 连珠腐尸毒 三环套月 七星聚首 玉碎昆岗 万箭齐发 天女散花 太上忘情 绝星阵·七杀 暗器连击"
        else
          CDG.skill_attack_jinji_disable = ""
        end
        local tmp = tObj[1]
        if tmp.name == bossname then
          if tmp.hp > 90 and g_self.isjingong == false then
            local pos = runpos[nIndex + 1]
            if pos then
              RunTo(pos.x, pos.y, 0, 2000)
            end
          end
          local tLongZhu = Enum2XByName("金龙柱 木龙柱 水龙柱 火龙柱 土龙柱", {
            1,
            0,
            0,
            0
          }, {0, -1}, nil, 3)
          if tmp.hp > 60 and 0 == #tLongZhu then
            bJinJiSkill = true
            debugnote = "龙柱未出现,甩技能"
          end
          if 0 == #tSpecial and m_param.boss4longzhu and #longzhu > 0 and RunTo(longzhu[1].x, longzhu[1].y, 0, 1000) then
            debugnote = ",拉到龙柱处"
            tmp.id = -1
          end
          if Target:FindBuff(tmp, "天罡护体") then
            tmp.id = -1
            debugnote = ",小怪即将出现"
            local pos = runpos[nIndex + 1]
            if pos then
              RunTo(pos.x, pos.y, 0, 1000)
            end
          elseif Target:FindBuff(tmp, "四绝之怒") then
            if -1 == startWaitTick then
              if false == SJZ_Boss4_teamOK(-1) then
                tmp.id = -1
              end
              startWaitTick = GetTickCount()
            end
            if false == SJZ_Boss4_teamOK(startWaitTick) then
              tmp.id = -1
            end
          elseif tmp.class == "NPC" then
            RunTo(tmp.x, tmp.y, 0, 1000)
            break
          end
          if #tSpecial > 0 then
            if g_self.isjingong then
              if tmp.dst > 2 then
                tmp.id = -1
                debugnote = debugnote .. ",有陷阱近攻暂时不打"
              end
            elseif tmp.dst > 15 then
              tmp.id = -1
              debugnote = debugnote .. ",有陷阱 Boss距离过远"
            end
          end
          if -1 ~= tmp.id and m_param.zhidian then
            ZhiDianJiangShan(tmp, false)
          end
        end
        if bXiaoGuai and tmp.id > -1 then
          TargetAttack(tmp.id, true)
        else
          FubenAttack(tmp.id, nil, bJinJiSkill, bCheckMP, nil, bMustAttack)
        end
      end
    else
      debugnote = ",躲避陷阱"
    end
    DebugStr("第一重：庞企 " .. debugnote)
    Sleep(50)
  end
  CDG.call.back1 = nil
end

local function MWJ_Boss1_PQ()
  SJZ_Boss4()
end

local function SSS_Boss4_special_self()
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    if -1 == Player:GetBuff("自爆：") then
      break
    end
    local tObj = Enum2XByClass("玩家", {0, -1})
    tObj = ObjFilterByName(tObj, g_self.name, 4)
    local param = {}
    param.useqg = false
    local bSafe, tSpecial = FubenTrapRun("", 130, 127, 12, 15, tObj, nil, FubenRunSafe, nil, nil, param)
    debugnote = "需远离队友!"
    local tXue = Enum2XByName("血咒巫蛊", {
      0,
      1,
      0,
      0
    }, {0, 15}, 3, 0)
    local tBoss = Enum2XByName("丁春秋·影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    local temp
    local actionID = -1
    if not m_param.ladcq and #tXue > 0 then
      temp = tXue[1]
      if false == g_self.isjingong or temp.dst <= 2 then
        actionID = temp.id
      else
        JinGongFarSkill(temp.id)
      end
    else
      if #tBoss > 0 then
        StopAttack(tBoss[1], nil)
      end
      local pet = Pet:GetSelfPet()
      if pet and 7 == pet.state then
        Pet:Relax(200)
      end
    end
    if bSafe then
      debugnote = "已远离队友!"
      FubenAttack(actionID)
    end
    Sleep(50)
    DebugStr("少室山：即将自爆 " .. debugnote)
  end
end

local function SSS_Boss4_is_special_2()
  local nMsgTime = IsInDebugMsg("CJG_101231_83")
  if nMsgTime and os.time() - nMsgTime <= 10 then
    return true
  end
  return false
end

local function SSS_Boss4_is_special_1()
  local nMsgTime = IsInDebugMsg("#{CJG_101231_82")
  if nMsgTime and os.time() - nMsgTime <= 10 then
    return true
  end
  if SSS_Boss4_is_special_2() then
    return true
  end
  return false
end

local function SSS_Boss4_mode2(nIndex, tBoss, tXue)
  local runpos = {
    {x = 110, y = 115},
    {x = 110, y = 120},
    {x = 110, y = 125},
    {x = 110, y = 130},
    {x = 110, y = 135},
    {x = 110, y = 140},
    {x = 115, y = 140},
    {x = 120, y = 140},
    {x = 125, y = 140},
    {x = 130, y = 140},
    {x = 135, y = 140},
    {x = 140, y = 140},
    {x = 145, y = 140},
    {x = 145, y = 135},
    {x = 145, y = 130},
    {x = 145, y = 125},
    {x = 145, y = 120},
    {x = 145, y = 115},
    {x = 140, y = 115},
    {x = 135, y = 115},
    {x = 130, y = 115},
    {x = 125, y = 115},
    {x = 120, y = 115},
    {x = 115, y = 115},
    {x = 115, y = 120},
    {x = 115, y = 125},
    {x = 115, y = 130},
    {x = 115, y = 135},
    {x = 120, y = 135},
    {x = 125, y = 135},
    {x = 130, y = 135},
    {x = 135, y = 135},
    {x = 140, y = 135},
    {x = 140, y = 130},
    {x = 140, y = 125},
    {x = 140, y = 120},
    {x = 135, y = 120},
    {x = 130, y = 120},
    {x = 125, y = 120},
    {x = 120, y = 120},
    {x = 120, y = 125},
    {x = 120, y = 130},
    {x = 125, y = 130},
    {x = 130, y = 130},
    {x = 135, y = 130},
    {x = 135, y = 125},
    {x = 130, y = 125},
    {x = 125, y = 125}
  }
  local attackID = -1
  if #tXue > 0 and #tBoss > 0 then
    if IsPosSafe(runpos[nIndex], tXue, 4) and IsPosSafe(tBoss[1], tXue, 4) then
      if 1 ~= nIndex and g_self.isjingong and false == SSS_Boss4_is_special_1() then
        attackID = tBoss[1].id
      elseif false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 500) and (g_self.isjingong == false or tBoss[1].dst <= 3) then
        attackID = tBoss[1].id
      end
    elseif IsPosSafe(runpos[nIndex], tXue, 4) == false or false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 500) and GetDist(runpos[nIndex].x, runpos[nIndex].y, tBoss[1].x, tBoss[1].y) <= 3 and 2 ~= tBoss[1].state then
      local bHaveSafePos = false
      for i = 1, #runpos do
        if nIndex < i and IsPosSafe(runpos[i], tXue, 4) then
          bHaveSafePos = true
          nIndex = i
          break
        end
      end
      if false == bHaveSafePos then
        nIndex = 1
        PushColorMsg("丁春秋：未找到安全坐标")
      end
      RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 1000)
    elseif false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 500) then
      if g_self.isjingong == false then
        attackID = tBoss[1].id
      else
        JinGongFarSkill(tBoss[1].id)
      end
    end
  else
    if #tBoss > 0 and false == RunTo(runpos[nIndex].x, runpos[nIndex].y, 0, 1000) and (g_self.isjingong == false or tBoss[1].dst <= 2) then
      attackID = tBoss[1].id
    else
    end
  end
  return nIndex, attackID
end

local function SSS_Boss4()
  local zero = m_npcpos[1]
  local boss = {
    name = "丁春秋·影",
    x = zero.x,
    y = zero.y
  }
  DebugStr("少室山：" .. boss.name)
  local pos = Player:GetPos()
  local tLast = {}
  tLast.ipos = 1
  tLast.id = -1
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.skill_attack_jinji_disable = " 指点江山 "
  while FubenCheckSceneDie(m_param.sceneID) do
    CDG.pet2.GUID = bGuid2
    CDG.pet3.GUID = bGuid3
    local debugnote = ""
    local tXue = Enum2XByName("血咒巫蛊", {
      0,
      1,
      0,
      0
    }, {0, -1}, 3, 0)
    local tBoss = Enum2XByName(boss.name, {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tBoss > 0 then
      tLast.x = tBoss[1].x
      tLast.y = tBoss[1].y
    end
    SSS_Boss4_special_self()
    if #tBoss > 0 and tBoss[1].hp > 0 then
      tLast.id = -1
      local bJinJi = false
      local bUsePet = true
      if m_param.ladcq then
        tLast.ipos, tLast.id = SSS_Boss4_mode2(tLast.ipos, tBoss, tXue)
        if 4 ~= g_self.menpai and #tXue > 0 then
          debugnote = " 集火攻击"
          bJinJi = true
        end
      elseif SSS_Boss4_is_special_2() then
        if RunTo(boss.x, boss.y, 3, 1000) == false then
          local temp = tBoss[1]
          if #tXue > 0 then
            debugnote = " 攻击血咒巫蛊..."
            bUsePet = false
            if 4 ~= g_self.menpai then
              CDG.pet3.GUID = 0
            end
            CDG.pet2.GUID = 0
            bJinJi = true
            temp = tXue[1]
          end
          tLast.id = temp.id
          if g_self.isjingong and temp.dst > 3 then
            JinGongFarSkill(temp.id)
            tLast.id = -1
          end
        end
      elseif #tXue > 0 then
        debugnote = " 集火攻击血咒巫蛊"
        bUsePet = false
        if 4 ~= g_self.menpai then
          CDG.pet3.GUID = 0
        end
        CDG.pet2.GUID = 0
        bJinJi = true
        tLast.id = tXue[1].id
      elseif g_self.isjingong or TeamDispersedStations(boss, 5) then
        tLast.id = tBoss[1].id
      end
      FubenAttack(tLast.id, true, bJinJi, true, bUsePet)
    else
      debugnote = " 寻找目标"
      Sleep(500)
      FubenAttack(-1)
      if not tLast.x or RunTo(tLast.x, tLast.y, 0, 1000) ~= false then
        PushDebugMessage("少室山:没有找到" .. boss.name)
      end
      break
    end
    Sleep(50)
    DebugStr("少室山:" .. boss.name .. debugnote)
  end
  CDG.skill_attack_jinji_disable = ""
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function MWJ_Boss1_DCQ()
  SSS_Boss4()
end

local function MWJ_Boss1()
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName(" 慕容复·影 庞企·影 丁春秋·影 ", {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.name == "慕容复·影" then
        MWJ_Boss1_MRF()
      elseif tmp.name == "庞企·影" then
        MWJ_Boss1_PQ()
      elseif tmp.name == "丁春秋·影" then
        MWJ_Boss1_DCQ()
      end
    else
      break
    end
    Sleep(200)
    DebugStr("第一重")
  end
end

local function MWJ_Boss2()
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName("大轮寺梵僧", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      local tObj2 = ObjFilterByInt(tObj, 0, 1, "hp")
      if g_self.isjingong then
        BubbleByDst(tObj2)
      else
        BubbleByHP(tObj2)
      end
      if #tObj2 > 0 then
        local tmp = tObj2[1]
        FubenAttack(tmp.id)
      end
    else
      break
    end
    Sleep(200)
    DebugStr("第二重:大轮寺梵僧")
  end
end

local function SSHJ_FindSpecial()
  local tAllSpec = EnumUnSafeSpecial()
  local tObj = ObjFilterByName(tAllSpec, " 刺骨寒霜 狂风暴雨 冰雪连天 百毒缠灵 寒冰 寒冰预警 烈火 ", 3)
  local tUnKnow = ObjFilterByName(tAllSpec, " BOSS1变身 BOSS2变身 BOSS3变身 谁入地狱1米 谁入地狱3米 谁入地狱5米 谁入地狱7米 谁入地狱9米 烈焰焚身1米 烈焰焚身3米 烈焰焚身5米 烈焰焚身7米 烈焰焚身9米 刺骨寒霜 狂风暴雨 冰雪连天 百毒缠灵 寒冰 寒冰预警 烈火 ", 4)
  for i = 1, #tUnKnow do
    LogMsg("三神未知陷阱：" .. tUnKnow[i].name)
  end
  if #tObj > 0 then
    local r = 6
    if tObj[1].name == "冰雪连天" then
      r = 4
    end
    return tObj, r
  end
  tObj = {}
  for i = 1, #tAllSpec do
    if string.find(tAllSpec[i].name, "谁入地狱", nil, true) or string.find(tAllSpec[i].name, "烈焰焚身", nil, true) then
      table.insert(tObj, tAllSpec[i])
    end
  end
  if #tObj > 0 then
    return tObj, 13
  end
  if #tAllSpec > 0 and tAllSpec[1].name ~= "BOSS1变身" and tAllSpec[1].name ~= "BOSS2变身" and tAllSpec[1].name ~= "BOSS3变身" then
    PushColorMsg("三神未知的陷阱：" .. tAllSpec[1].name)
  end
  return {}, 0
end

local function SSHJ_TrapRun(aBossIndex)
  local boss = m_npcpos[3]
  local tSpec, r = SSHJ_FindSpecial()
  local bSafe = true
  local param = {}
  if 1 == aBossIndex then
    param.useqg = false
  elseif 2 == aBossIndex then
    param.useqg = false
    param.sort_boss = false
  end
  if #tSpec > 0 then
    bSafe = FubenTrapRun(" 裂海玄蜥·影 裂海魔龙·影 灭世火凤·影 炼狱凤凰·影 ", boss.x, boss.y, r, 15, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

local function SSHJ_Boss1()
  local boss = m_npcpos[3]
  while FubenCheckSceneDie(m_param.sceneID) do
    local bIsSafe, tSpecial = SSHJ_TrapRun(1)
    if bIsSafe then
      local tObj = Enum2XByName(" 裂海玄蜥·影 裂海魔龙·影 ", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      if #tObj > 0 then
        local tmp = tObj[1]
        local tid = tmp.id
        if 0 == #tSpecial and 6 == tmp.state then
          local param = {}
          param.useqg = false
          bIsSafe, _ = FubenTrapRun("", boss.x, boss.y, 10, 15, tObj, nil, FubenRunSafe, nil, nil, param)
          if bIsSafe then
            FubenAttack(-1)
          end
        else
          if #tSpecial > 0 then
            if g_self.isjingong then
              if tmp.dst > 3 then
                DebugStr("明王境：裂海魔龙躲避陷阱,近攻暂时不打", 2)
                if tmp.dst <= 15 then
                  JinGongFarSkill(tmp.id)
                end
                tid = -1
              end
            elseif tmp.dst > 15 then
              DebugStr("明王境：裂海魔龙躲避陷阱,远攻距离过远暂时不打", 2)
              tid = -1
            end
          end
          FubenAttack(tid)
        end
      else
        DebugStr("第三重:未找到裂海魔龙", 2)
        break
      end
    else
      DebugStr("明王境：裂海魔龙躲避陷阱", 2)
    end
    Sleep(200)
    DebugStr("第三重:裂海魔龙")
  end
end

local function SSHJ_Boss2_Huo(aIsCallBack)
  local boss = m_npcpos[3]
  local bIsSelfInSpecial = false
  local tObj = Enum2XByTitle("#{KBOSS_140805_187", nil, {0, -1}, nil, 5)
  if #tObj > 0 then
    for i = 1, #tObj do
      if tObj[i].name == g_self.name .. "的离火" or tObj[i].name == g_self.name .. "的焱火" then
        bIsSelfInSpecial = true
        break
      end
    end
    if bIsSelfInSpecial then
      local bIsSafe, tSpecial = FubenTrapRun("", boss.x, boss.y, 6, 15, tObj, nil, FubenRunSafe_easy, nil, 12)
      if bIsSafe and not aIsCallBack then
        local bGuid2 = CDG.pet2.GUID
        local bGuid3 = CDG.pet3.GUID
        CDG.pet2.GUID = 0
        CDG.pet3.GUID = 0
        CDG:checktime0()
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
      end
      return true
    else
      BubbleByDst(tObj)
      if tObj[1].dst <= 6 then
        local bIsSafe, tSpecial = FubenTrapRun("", boss.x, boss.y, 6, 7, tObj, nil, FubenRunSafe_easy, nil, 1)
        return true
      end
    end
  end
  return false
end

local function SSHJ_Boss2(nMemIndex)
  local boss = m_npcpos[3]
  local tpos = GetAveragePoint(boss.x, boss.y, 6, 6, 0)
  while FubenCheckSceneDie(m_param.sceneID) do
    local bIsSafe, tSpecial = SSHJ_TrapRun(2)
    if bIsSafe and 0 == #tSpecial then
      if false == SSHJ_Boss2_Huo(false) then
        if false == g_self.isjingong and nMemIndex >= 0 and nMemIndex <= 5 then
          RunTo(tpos[nMemIndex + 1].x, tpos[nMemIndex + 1].y, 1, 800)
        end
        local tObj = Enum2XByName(" 灭世火凤·影 炼狱凤凰·影 ", {
          0,
          1,
          0,
          0
        }, {0, -1}, nil, 3)
        if #tObj > 0 then
          FubenAttack(tObj[1].id)
        else
          break
        end
      else
        DebugStr("明王境：灭世火凤躲火苗 ", 2)
      end
    else
      DebugStr("明王境：灭世火凤躲避陷阱", 2)
      if bIsSafe then
        local tObj = Enum2XByName(" 灭世火凤·影 炼狱凤凰·影 ", {
          0,
          1,
          0,
          0
        }, {0, -1}, nil, 3)
        if #tObj > 0 then
          FubenAttack(tObj[1].id)
        end
      end
    end
    Sleep(200)
    DebugStr("第三重:灭世火凤")
  end
end

local function SSHJ_Boss3(nMemIndex)
  local boss = m_npcpos[3]
  while FubenCheckSceneDie(m_param.sceneID) do
    local banjin = 6
    if IsInDebugMsgTime("#{MZFB_150810_67}", false, 6) or -1 ~= Player:GetBuff("每秒对周围玩家造成伤害") then
      banjin = 8
    end
    local tpos = GetAveragePoint(boss.x, boss.y, banjin, 6, 0)
    if g_self.isjingong == false and nMemIndex >= 0 and nMemIndex <= 5 then
      RunTo(tpos[nMemIndex + 1].x, tpos[nMemIndex + 1].y, 0, 500)
    end
    local bSafeJG = true
    local bAttack = true
    if IsInDebugMsgTime("#{MZFB_150810_69}", false, 6) or -1 ~= Player:GetBuff("毒蛊入体：该状态消失时会传染给周围玩家。") then
      StateRemoveBad(true, false, false, false, false)
    end
    if g_self.isjingong then
      if IsInDebugMsgTime("#{MZFB_150810_69}", false, 6) or IsInDebugMsgTime("#{MZFB_150810_67}", false, 6) or -1 ~= Player:GetBuff("每秒对周围玩家造成伤害") then
        bSafeJG = false
        bAttack = false
        if nMemIndex >= 0 and nMemIndex <= 5 and FastRun(tpos[nMemIndex + 1], 4) then
          bAttack = true
        end
      else
        local tSpec, r = SSHJ_FindSpecial()
        if #tSpec > 0 then
          bSafeJG = false
          bAttack = false
          local pos = Player:GetPos()
          if IsPosSafe(pos, tSpec, r) then
            bAttack = true
          elseif nMemIndex >= 0 and nMemIndex <= 5 and FastRun(tpos[nMemIndex + 1], 4) then
            bAttack = true
          end
        end
      end
    end
    local tObj = Enum2XByName(" 毒种籽 毒花 ", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if #tObj > 0 then
      if g_self.isjingong then
        BubbleByDst(tObj, 1)
      else
        BubbleByHP(tObj, 1)
      end
      DebugStr("噬魂花妖：集火攻击毒种籽、毒花", 2)
      if false == bSafeJG then
        if bAttack then
          if tObj[1].dst < 3 then
            FubenAttack(tObj[1].id)
          else
            JinGongFarSkill(tObj[1].id)
          end
        end
      else
        local bGuid2 = CDG.pet2.GUID
        local bGuid3 = CDG.pet3.GUID
        if 4 ~= g_self.menpai then
          CDG.pet2.GUID = 0
          CDG.pet3.GUID = 0
        end
        FubenAttack(tObj[1].id, true, true, true, false)
        CDG.pet2.GUID = bGuid2
        CDG.pet3.GUID = bGuid3
      end
    else
      tObj = Enum2XByName(" 摄灵蛊花·影 噬魂花妖·影 ", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      if #tObj > 0 then
        if false == bSafeJG then
          if bAttack then
            if tObj[1].dst < 3 then
              FubenAttack(tObj[1].id)
            else
              JinGongFarSkill(tObj[1].id)
            end
          end
        else
          FubenAttack(tObj[1].id)
        end
      end
    end
    Sleep(200)
    DebugStr("第三重:噬魂花妖")
  end
end

local function SSHJ_CDG_callback()
  local bSafe, tSpec = SSHJ_TrapRun(2)
  if bSafe then
    if 0 == #tSpec and SSHJ_Boss2_Huo(true) then
      return false
    end
    return true
  end
  return false
end

local function MWJ_Boss3()
  local nMemIndex = Team:GetMyIndex()
  CDG.call.back1 = SSHJ_CDG_callback
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName(" 裂海玄蜥·影 裂海魔龙·影 灭世火凤·影 炼狱凤凰·影 摄灵蛊花·影 噬魂花妖·影 ", {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      if 0 == tmp.hp then
        PushColorMsg("第三重:Boss血量0")
        break
      end
      if tmp.name == "裂海玄蜥·影" or tmp.name == "裂海魔龙·影" then
        SSHJ_Boss1()
      elseif tmp.name == "灭世火凤·影" or tmp.name == "炼狱凤凰·影" then
        SSHJ_Boss2(nMemIndex)
      elseif tmp.name == "摄灵蛊花·影" or tmp.name == "噬魂花妖·影" then
        SSHJ_Boss3(nMemIndex)
      end
    else
      break
    end
    Sleep(200)
    DebugStr("第三重:三神幻境")
  end
  CDG.call.back1 = nil
end

local function MWJ_Boss4()
  local teamIndex, nCount = Team:GetMyIndex()
  local angleMy = 0
  if nCount >= 3 then
    teamIndex = teamIndex + 1
    local angleMin = 360 / nCount * (teamIndex - 1)
    local angleMax = 360 / nCount * teamIndex
    angleMy = (angleMin + angleMax) / 2
  end
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName(" 锡杖 净瓶 金刚杵 智慧剑 雪莲 ", {
      1,
      0,
      0,
      0
    }, nil, nil, 3)
    if not (#tObj > 0) then
      break
    end
    if tObj[1].name == "雪莲" then
      BubbleByDst(tObj)
      local tmp = tObj[1]
      RunTo(tmp.x, tmp.y, 1, 1000)
    else
      for i = 1, #tObj do
        tObj[i].angle = GetTargetAngle(tObj[i])
      end
      do
        local tTar = {}
        for j = 1, 12 do
          for i = 1, #tObj do
            local absA = math.abs(tObj[i].angle - angleMy)
            if absA > 180 then
              absA = 360 - absA
            end
            if absA < j * 30 then
              table.insert(tTar, tObj[i])
            end
          end
          if #tTar > 0 then
            break
          end
        end
        if 0 == #tTar then
          tTar = tObj
        end
        BubbleByDst(tTar)
        if #tTar > 0 then
          local tmp = tTar[1]
          RunTo(tmp.x, tmp.y, 3, 600)
          OpenTalk(tmp.id, 700)
          QuestFrameOptionClicked_Item("#{RGPT_231130_297}", 1, 800)
          goto lbl_135
          break
        end
      end
    end
    ::lbl_135::
    Sleep(200)
    DebugStr("第四重:拾取")
  end
end

local function Boss1Jian(aID)
  if IsInDebugMsgTime("LHFD_160203_75", false, 6) then
    PushColorMsg("李秋水:发现剑气")
    CDG.call.back1 = nil
    local zero = m_npcpos[5]
    zero.rmin = 1
    zero.rmax = 15
    while FubenCheckSceneDie(m_param.sceneID) and IsInDebugMsgTime("LHFD_160203_75", false, 6) do
      local debugnote = ""
      local tAll = Enum2XByClass("NPC 怪物")
      local tBoss = ObjFilterByStrClass(tAll, "怪物", 0)
      local tNPC = ObjFilterByStrClass(tAll, "NPC", 0)
      local tJian = ObjFilterByName(tNPC, "剑", 0)
      local tLQS = ObjFilterByName(tBoss, "李秋水·影", 0)
      if #tJian > 0 then
        local lqs = tLQS[1]
        local jian = tJian[1]
        local trapPos = {
          x = jian.x,
          y = jian.y
        }
        local trapAngle = GetTargetAngle(jian)
        local bTrapSafe = FubenShanXing2(zero, trapPos, trapAngle, 45, lqs)
        if bTrapSafe then
          PlayerStateTimeOut(2, 2)
          if lqs then
            CheckDistAttack(lqs, false)
          end
          if -1 == aID then
            debugnote = " 已安全"
          end
        end
      else
        FubenAttack(-1)
      end
      Sleep(50)
      DebugStr("琅嬛福地:李秋水躲避剑气" .. debugnote, 2)
    end
    CDG.call.back1 = m_param.callback
    PushDebugMessage("李秋水:剑气已释放")
  end
end

local function Boss1WXZY()
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local tObj = Enum2XByName("无相踪影", {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 0)
  while #tObj > 0 and FubenCheckSceneDie(m_param.sceneID) do
    if g_self.isjingong then
      BubbleByDst(tObj, 1)
    else
      BubbleByHP(tObj, 1)
    end
    CDG.pet2.GUID = 0
    CDG.pet3.GUID = 0
    FubenAttack(tObj[1].id, nil, true, true, false, true)
    Sleep(100)
    DebugStr("无相踪影")
    tObj = Enum2XByName("无相踪影", {
      0,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss1YBCY()
  local tObj = Enum2XByName("玉璧残影", {
    1,
    1,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 then
    return true
  end
  return false
end

local function Boss1OnAction()
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local boss = m_npcpos[5]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("李秋水·影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      if 0 == tObj[1].hp then
        break
      end
      local bYBCY = Boss1YBCY()
      if false == bYBCY then
        Boss1Jian(tObj[1].id)
        Boss1WXZY()
      end
      if false == bYBCY and false == g_self.isjingong then
        local nDist = 8
        if 4 == g_self.menpai then
          nDist = 6
        end
        if nDist < GetDist(boss.x, boss.y) then
          RunTo(boss.x, boss.y, 3, 700)
        end
      end
      if bYBCY or tObj[1].hp > 17 then
        if bYBCY then
          debugnote = "玉璧残影，集火攻击"
          CDG.pet3.GUID = 0
          CDG.pet2.GUID = 0
          FubenAttack(tObj[1].id, true, true, true, false, true, true)
          CDG.pet2.GUID = bGuid2
          CDG.pet3.GUID = bGuid3
        else
          debugnote = "."
          FubenAttack(tObj[1].id)
        end
      else
        if false == g_self.isjingong and tObj[1].hp < 9 then
          RunTo(boss.x, boss.y, 2, 1000)
        end
        debugnote = "暂不用技能."
        FubenAttack(tObj[1].id, false, false)
      end
    else
      debugnote = " 未找到boss"
      if false == RunTo(boss.x, boss.y, 1, 500) then
        break
      end
    end
    Sleep(50)
    DebugStr("第五重:李秋水 " .. debugnote)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss2Special()
  local bIsSafe = true
  local tSpecial = {}
  CDG.call.back1 = nil
  local zero = m_npcpos[5]
  repeat
    local tAllSpec = EnumUnSafeSpecial()
    local specName = " 寒冰符指引特效 寒冰符 饮血爆炸陷阱 天火符 "
    tSpecial = ObjFilterByName(tAllSpec, specName, 3)
    local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
    for i = 1, #tUnKnow do
      LogMsg("童姥未知的陷阱：" .. tUnKnow[i].name)
    end
    if #tSpecial > 0 then
      local param = {}
      param.useqg = false
      bIsSafe, tSpecial = FubenTrapRun("", zero.x, zero.y, 8, 15, tSpecial, nil, FubenRunSafe, nil, nil, param)
      Sleep(50)
      DebugStr("天山童姥:躲避陷阱")
    else
      bIsSafe = true
    end
  until bIsSafe
  CDG.call.back1 = m_param.callback
  return bIsSafe, tSpecial
end

local function Boss2OnAction()
  local boss = m_npcpos[5]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("天山童姥·影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      if 0 == tObj[1].hp then
        break
      end
      local bCheckPet = true
      local bUseJinJi = false
      local bMustAttack = false
      if Target:FindBuff(tObj[1], "速速打破血盾") then
        debugnote = "集火打血盾"
        bCheckPet = false
        bUseJinJi = true
        if 4 == g_self.menpai and CDG.hp.em_yxjx then
          bMustAttack = true
        end
      end
      if tObj[1].hp >= 50 then
        local bIsSafe, tSpecial = Boss2Special()
        local bAttack = false
        if bIsSafe then
          if g_self.isjingong then
            if 0 == #tSpecial then
              bAttack = true
            else
              local tmp = Enum2XByName("天山童姥·影", {
                0,
                1,
                0,
                0
              }, nil, nil, 0)
              if #tmp > 0 then
                if tmp[1].dst <= 2 then
                  bAttack = true
                else
                  debugnote = "有陷进,近攻暂时不攻击"
                  if tmp[1].dst <= 15 then
                    JinGongFarSkill(tmp[1].id)
                  end
                end
              end
            end
          else
            bAttack = true
          end
        end
        if bAttack then
          FubenAttack(tObj[1].id, nil, bUseJinJi, nil, bCheckPet, bMustAttack)
        elseif bIsSafe then
          FubenAttack(-1)
        end
      elseif RunTo(boss.x, boss.y, 0, 500) == false then
        FubenAttack(tObj[1].id)
      end
    elseif RunTo(boss.x, boss.y, 0, 800) == false then
      break
    end
    Sleep(100)
    DebugStr("第五重:天山童姥 " .. debugnote)
  end
end

local function Boss3BaGua(tid)
  CDG.call.back1 = nil
  local boss = m_npcpos[5]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByClass("NPC")
    local runpos = {x = -1, y = -1}
    for i = 1, #tObj do
      if string.find(tObj[i].name, "八卦安全区", nil, true) then
        runpos.x, runpos.y = tObj[i].x, tObj[i].y
        break
      end
    end
    if runpos.x > 0 and runpos.y > 0 then
      FastRun(runpos, 3)
      if RunTo(runpos.x, runpos.y, 2, 500) == false then
        if -1 == tid then
          debugnote = " 躲阵"
        end
        FubenAttack(-1)
      end
    else
      local bBaGua = false
      for i = 1, #tObj do
        if string.find("乾坤震巽坎离艮兑", tObj[i].name, nil, true) then
          if RunTo(boss.x, boss.y, 1, 200) == false then
            if -1 ~= tid then
              debugnote = " 躲阵中"
            end
            FubenAttack(-1)
          end
          bBaGua = true
          break
        end
      end
      if false == bBaGua then
        break
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地：无崖子八卦阵")
  end
  CDG.call.back1 = m_param.callback
end

local function Boss3JSPZ(hp)
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local emYXJX = CDG.hp.em_yxjx
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  CDG.hp.em_yxjx = false
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName("击杀破阵", {
      0,
      1,
      0,
      0
    }, {0, -1}, 1, 0)
    local xSafe, ySafe, tid = -1, -1, -1
    if #tObj > 0 then
      xSafe, ySafe, tid = tObj[1].x, tObj[1].y, tObj[1].id
    end
    if xSafe > 0 and ySafe > 0 and tid > 0 then
      if GetDist(xSafe, ySafe) > 3 then
        Skill:UseSpeed()
        RunTo(xSafe, ySafe, 0, 250)
      else
        local bCheckHP = false
        if hp < 18 then
          FubenAttack(tid, true, false, bCheckHP, false, true, true)
        else
          FubenAttack(tid, true, true, bCheckHP, false, true, true)
        end
      end
    else
      break
    end
    Sleep(50)
    DebugStr("琅嬛福地：无崖子破阵集火攻击")
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  CDG.hp.em_yxjx = emYXJX
end

local function Boss3XianJin(hp, bCallBack)
  local boss = m_npcpos[5]
  CDG.call.back1 = nil
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local specName = " 凌波微步伤害陷阱 黑白棋陷阱展示 黑棋陷阱 白棋陷阱 "
    local tAllSpec = EnumUnSafeSpecial()
    local tSpecial = ObjFilterByName(tAllSpec, specName, 3)
    local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
    for i = 1, #tUnKnow do
      LogMsg("无崖子未知的陷阱：" .. tUnKnow[i].name)
    end
    if #tSpecial > 0 then
      local bIsSafe = false
      local param = {}
      param.useqg = false
      if tSpecial[1].name == "黑白棋陷阱展示" or tSpecial[1].name == "黑棋陷阱" or tSpecial[1].name == "白棋陷阱" then
        bIsSafe = FubenTrapRun("", boss.x, boss.y, 5, 18, tSpecial, nil, FubenRunSafe, nil, nil, param)
      else
        bIsSafe = FubenTrapRun("", boss.x, boss.y, 7, 18, tSpecial, nil, FubenRunSafe, nil, nil, param)
      end
      if bIsSafe then
        if bCallBack then
          debugnote = " 已安全"
        end
        local tObj = Enum2XByName("无崖子·影", {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          hp = tmp.hp
          CheckDistAttack(tmp, false)
        else
          FubenAttack(-1)
        end
      end
    else
      break
    end
    if hp < 20 then
      local tObj = Enum2XByClass("NPC")
      local bOver = false
      for i = 1, #tObj do
        if string.find(tObj[i].name, "黑水NPC", nil, true) then
          bOver = true
          break
        end
      end
      if bOver then
        break
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地：躲避无崖子陷阱." .. debugnote)
  end
  CDG.call.back1 = m_param.callback
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss3_hs_fl()
  local boss = m_npcpos[5]
  if Player:IsLeader() then
    return 0
  end
  local leader = Team:GetLeaderInfo()
  if not leader then
    PushColorMsg("无崖子:跟随队长时未获取到队长信息")
    return 0
  end
  if 0 == leader.hp then
    PushDebugMessage("无崖子:跟随队长时队长死亡")
    return 0
  end
  local xPos, yPos = leader.x, leader.y
  local nearLeader = FindObjByGUID(leader.guid)
  if nearLeader then
    xPos, yPos = nearLeader.x, nearLeader.y
  end
  if GetDist(boss.x, boss.y, xPos, yPos) < 25 then
    if GetDist(xPos, yPos) < 1 then
    else
      local runpos = {x = xPos, y = yPos}
      FastRun(runpos, 4)
      return 2
    end
  else
    PushColorMsg("无崖子:跟随队长时队长位置非boss区域！")
    return 0
  end
  return 1
end

local function Boss3_get_hs()
  local tHeiS = {}
  local tObj = Enum2XByClass("NPC")
  for i = 1, #tObj do
    if string.find(tObj[i].name, "黑水NPC", nil, true) then
      local szR = string.gsub(tObj[i].name, "黑水NPC", "")
      local r = tonumber(szR)
      if type(r) ~= "number" or r <= 0 then
        r = 4
      end
      local n = #tHeiS + 1
      tHeiS[n] = {}
      tHeiS[n] = tObj[i]
      tHeiS[n].r = r
    end
  end
  BubbleByDst(tHeiS, 1)
  return tHeiS
end

local function Boss3HeiShui()
  local boss = m_npcpos[5]
  local bHaveHeiShui = false
  local allpos = GetAveragePoint(boss.x, boss.y, 17, 72, 0)
  CDG.call.back1 = nil
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  if 4 ~= g_self.menpai then
    CDG.pet3.GUID = 0
  end
  CDG.pet2.GUID = 0
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tHeiS = Boss3_get_hs()
    if bHaveHeiShui and 0 == #tHeiS then
      Sleep(200)
      tHeiS = Boss3_get_hs()
    end
    local bIsSelfSafe = true
    if #tHeiS > 0 then
      bHaveHeiShui = true
      local nflag = 0
      if m_param.hsFollow then
        nflag = Boss3_hs_fl()
      end
      if 0 == nflag then
        local rReal = 14
        if tHeiS[1].r > 14 then
          rReal = 25
        elseif tHeiS[1].r > 9 then
          rReal = 22
        elseif tHeiS[1].r > 4 then
          rReal = 18
        end
        for i = 1, #tHeiS do
          if tHeiS[i].dst < 14 or rReal > GetDist(tHeiS[1].x, tHeiS[1].y) then
            bIsSelfSafe = false
            break
          end
        end
        if false == bIsSelfSafe then
          local safepos1 = {}
          for i = rReal, 14, -1 do
            safepos1 = GetAllSafePos(tHeiS, allpos, i)
            if #safepos1 > 0 then
              break
            end
          end
          if 0 == #safepos1 then
            PushColorMsg("琅嬛福地：躲避黑水时没有找到安全坐标!")
            break
          end
          for i = 1, #safepos1 do
            safepos1[i].angle = GetAngle(boss.x, boss.y, safepos1[i].x, safepos1[i].y)
          end
          local angleSpecial = GetAngle(boss.x, boss.y, tHeiS[1].x, tHeiS[1].y)
          local safepos_2 = {}
          for i = 1, #safepos1 do
            if angleSpecial < safepos1[i].angle then
              table.insert(safepos_2, safepos1[i])
            end
          end
          local runpos = {x = -1, y = -1}
          if 0 == #safepos_2 then
            BubbleSort(safepos1, "angle", 1)
            runpos.x, runpos.y = safepos1[1].x, safepos1[1].y
          else
            BubbleSort(safepos_2, "angle", 1)
            runpos.x, runpos.y = safepos_2[1].x, safepos_2[1].y
          end
          if runpos.x > 0 and runpos.y > 0 then
            local nTick = GetTickCount()
            while GetTickCount() - nTick < 6000 do
              local temp = Boss3_get_hs()
              if false == IsPosSafe(runpos, temp, 13) or FastRun(runpos, 4) or GetDist(runpos.x, runpos.y) < 2 then
                break
              end
              Sleep(50)
              PushDebugMessage("黑水跑位 %s,%s", math.floor(runpos.x), math.floor(runpos.y))
            end
            RunTo(runpos.x, runpos.y, 0, 600)
          else
            bIsSelfSafe = true
            PushColorMsg("无崖子:躲避黑水,没有合适的坐标！")
          end
        end
      end
      if 2 ~= nflag then
        local temp = Boss3_get_hs()
        local tObj = Enum2XByName("无崖子·影", {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if 0 == #temp or temp[1].dst >= 14 then
          if #tObj > 0 then
            local bJinJiSkill = true
            CheckDistAttack(tObj[1], false, bJinJiSkill)
          else
            FubenAttack(-1, nil, nil, true, false)
          end
        else
          PushDebugMessage("走位中.")
          if 1 == nflag and #tObj > 0 then
            FubenAttack(tObj[1].id, nil, nil, true, false)
          end
        end
      else
        debugnote = " 跟随队长走位中"
      end
    else
      if false == bHaveHeiShui then
        break
      end
      local tObj = Enum2XByName("无崖子·影", {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if 0 == #tObj or 0 == tObj[1].hp then
        break
      end
      PushColorMsg("搜索黑水")
      local bHas = false
      for i = 1, 8 do
        local temp = Boss3_get_hs()
        if #temp > 0 then
          bHas = true
          break
        end
        Sleep(100)
        FubenAttack(-1, nil, nil, true, false)
      end
      if false == bHas then
        PushColorMsg("未发现黑水,攻击无崖子")
        FubenAttack(tObj[1].id, nil, nil, nil, false)
      end
    end
    Sleep(50)
    DebugStr("琅嬛福地：黑水集火攻击" .. debugnote)
  end
  if bHaveHeiShui then
    PushDebugMessage("躲避黑水完成")
  end
  CDG.call.back1 = m_param.callback
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss3OnAction()
  local boss = m_npcpos[5]
  local tick_follow = -1
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("无崖子·影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      if 0 == tObj[1].hp then
        break
      end
      if tObj[1].hp < 21 then
        Boss3HeiShui()
      end
      Boss3BaGua(tObj[1].id)
      Boss3JSPZ(tObj[1].hp)
      Boss3XianJin(tObj[1].hp, false)
      local bCheckPet = true
      local bUseSkill = true
      local tid = tObj[1].id
      if tObj[1].hp < 21 then
        bUseSkill = false
        if m_param.hsFollow == false or Player:IsLeader() then
          if tObj[1].hp < 18 and tObj[1].hp > 10 and RunTo(158, 106, 3, 650) then
            tid = -1
            bCheckPet = false
          end
        elseif tObj[1].hp < 18 and m_param.hsFollow and GetTickCount() - tick_follow > 10000 then
          if 2 == Boss3_hs_fl() then
            debugnote = " 跟随队长."
            tid = -1
          else
            tick_follow = GetTickCount()
          end
        end
      end
      if tObj[1].hp > 9 then
        if tObj[1].hp > 30 and false == g_self.isjingong then
          local dist = 6
          if 4 == g_self.menpai then
            dist = 4
          end
          if false == RunTo(boss.x, boss.y, dist, 300) then
            FubenAttack(tid, bUseSkill, false, true, bCheckPet)
          else
            debugnote = " 靠近中心点"
          end
        else
          FubenAttack(tid, bUseSkill, false, true, bCheckPet)
        end
      else
        local bUseJinJi = false
        if tObj[1].hp < 7 then
          bUseJinJi = true
          debugnote = " 集火攻击"
        end
        FubenAttack(tid, true, bUseJinJi, true, false)
      end
    elseif false == RunTo(boss.x, boss.y, 1, 800) then
      break
    end
    Sleep(50)
    DebugStr("第五重:无崖子" .. debugnote)
  end
end

local function Boss4XianJin(bCallBack)
  local boss = m_npcpos[5]
  CDG.call.back1 = nil
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local specName = " 韦陀掌伤害陷阱 罗汉拳伤害陷阱 "
    local tAllSpec = EnumUnSafeSpecial()
    local tSpecial = ObjFilterByName(tAllSpec, specName, 3)
    local tUnKnow = ObjFilterByName(tAllSpec, specName, 4)
    for i = 1, #tUnKnow do
      LogMsg("虚竹未知的陷阱：" .. tUnKnow[i].name)
    end
    if #tSpecial > 0 then
      local param = {}
      param.useqg = false
      local bIsSafe, tSpecial = FubenTrapRun("虚竹·影", boss.x, boss.y, 7, 15, tSpecial, nil, FubenRunSafe, nil, nil, param)
      if bIsSafe then
        if bCallBack then
          debugnote = " 已安全"
        end
        local tObj = Enum2XByName("虚竹·影", {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          CheckDistAttack(tmp, false)
        else
          FubenAttack(-1)
        end
      end
    else
      break
    end
    Sleep(20)
    DebugStr("虚竹:躲避伤害陷阱" .. debugnote)
  end
  CDG.call.back1 = m_param.callback
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function Boss4HeiBaQi(tid)
  local boss = m_npcpos[5]
  CDG.call.back1 = nil
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local specName = "珍珑棋局"
    local tAllSpec = EnumUnSafeSpecial()
    local tSpecial = ObjFilterByName(tAllSpec, specName, 5)
    if #tSpecial > 0 then
      local param = {}
      param.useqg = false
      local bIsSafe = FubenTrapRun("", boss.x, boss.y, 4, 16, tSpecial, nil, FubenRunSafe, nil, nil, param)
      if bIsSafe then
        if -1 == tid then
          debugnote = " 已安全"
        end
        local tmp = FindObjByTID(tid)
        CheckDistAttack(tmp, false)
      end
    else
      break
    end
    Sleep(80)
    DebugStr("虚竹:躲避棋局" .. debugnote)
  end
  CDG.call.back1 = m_param.callback
end

local function Boss4LiuYangZ()
  local tarName = ""
  local tSafePos = {
    {x = 149, y = 111},
    {x = 167, y = 111},
    {x = 149, y = 131},
    {x = 167, y = 131}
  }
  local bHasMsg, strDbgMsg, nSpecTime = IsInDebugMsgTime("LHFD_160203_92", false, 15)
  if bHasMsg then
    local str1 = string.sub(strDbgMsg, 22, -1)
    local posEnd = string.find(str1, "*")
    if posEnd then
      tarName = string.sub(str1, 0, posEnd - 1)
    end
  end
  if bHasMsg and os.time() - nSpecTime <= 7 and "" ~= tarName and tarName == g_self.name then
    GetAllPosDist(tSafePos)
    BubbleByDst(tSafePos, 1)
    while IsInDebugMsgTime("LHFD_160203_92", false, 7) do
      if FastRun(tSafePos[1], 4) then
        local tObj = Enum2XByName("虚竹·影", {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        CheckDistAttack(tObj[1], true)
      end
      Sleep(100)
      DebugStr(tarName .. ":将被使用六阳掌")
    end
  end
  if bHasMsg and "" ~= tarName and tarName ~= g_self.name then
    local xZero, yZero = -1, -1
    while FubenCheckSceneDie(m_param.sceneID) do
      local debugnote = ""
      local tObj = Enum2XByClass("玩家 NPC")
      local bHaveLYZ = false
      for i = 1, #tObj do
        if tObj[i].class == "NPC" and tObj[i].name == "六阳掌力" then
          bHaveLYZ = true
        end
      end
      if false == bHaveLYZ then
        for i = 1, #tObj do
          if tObj[i].class == "玩家" and tObj[i].name and "" ~= tObj[i].name and tarName == tObj[i].name then
            xZero, yZero = tObj[i].x, tObj[i].y
            break
          end
        end
      end
      local tBoss = Enum2XByName("虚竹", {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if xZero > 0 and yZero > 0 then
        local dist = GetDist(xZero, yZero)
        local cmpPos = Player:GetPos()
        if g_self.isjingong and CDG.attack and #tBoss > 0 then
          dist = GetDist(xZero, yZero, tBoss[1].x, tBoss[1].y)
          cmpPos = tBoss[1]
        end
        if dist < 7 then
          dist = 7
        end
        local tPos = GetAveragePoint(xZero, yZero, dist, 6, 0)
        tPos = GetAllPosDist(tPos, cmpPos, "dst")
        BubbleByDst(tPos, 1)
        local runpos = {x = -1, y = -1}
        for i = 1, #tPos do
          runpos.x, runpos.y = tPos[i].x, tPos[i].y
          if GetDist(m_npcpos[5].x, m_npcpos[5].y, runpos.x, runpos.y) < 15 then
            break
          end
        end
        if runpos.x > 0 and runpos.y > 0 then
          debugnote = " 移动到坐标 " .. runpos.x .. "," .. runpos.y
          if false == RunTo(runpos.x, runpos.y, 0, 200) then
            if #tBoss > 0 then
              CheckDistAttack(tBoss[1], false)
            else
              FubenAttack(-1)
            end
          end
        else
          PushColorMsg("六阳掌没有安全坐标.")
        end
      elseif #tBoss > 0 then
        FubenAttack(tBoss[1].id)
      else
        FubenAttack(-1)
      end
      if os.time() - nSpecTime > 10 and false == bHaveLYZ then
        break
      end
      Sleep(50)
      DebugStr("虚竹:躲避六阳掌 " .. debugnote)
    end
  end
end

local function Boss4OnAction()
  local boss = m_npcpos[5]
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tObj = Enum2XByName("虚竹·影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      if 0 == tObj[1].hp then
        break
      end
      if tObj[1].title == "逍遥真身" then
        Boss4LiuYangZ()
        Boss4HeiBaQi(tObj[1].id)
      elseif tObj[1].title == "少林真身" then
        Boss4XianJin()
      else
        PushDebugMessage("琅嬛福地:Boss4未读取到虚竹状态")
        Boss4XianJin()
        Boss4LiuYangZ()
        Boss4HeiBaQi(tObj[1].id)
      end
      FubenAttack(tObj[1].id)
    elseif RunTo(boss.x, boss.y, 1, 800) == false then
      break
    end
    Sleep(80)
    DebugStr("琅嬛福地:虚竹")
  end
end

local function MWJ_Boss5()
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName(" 李秋水·影 天山童姥·影 无崖子·影 虚竹·影 ", {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.name == "李秋水·影" then
        Boss1OnAction()
      elseif tmp.name == "天山童姥·影" then
        Boss2OnAction()
      elseif tmp.name == "无崖子·影" then
        Boss3OnAction()
      elseif tmp.name == "虚竹·影" then
        Boss4OnAction()
      end
    else
      break
    end
    Sleep(200)
    DebugStr("第五重:琅嬛福地")
  end
end

local function MWJ_Boss6()
  local teamIndex, nCount = Team:GetMyIndex()
  local angleMy = 0
  if nCount >= 3 then
    teamIndex = teamIndex + 1
    local angleMin = 360 / nCount * (teamIndex - 1)
    local angleMax = 360 / nCount * teamIndex
    angleMy = (angleMin + angleMax) / 2
  end
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName(" 莲花灯 ", {
      1,
      0,
      0,
      0
    }, nil, nil, 3)
    if not (#tObj > 0) then
      break
    end
    for i = 1, #tObj do
      tObj[i].angle = GetTargetAngle(tObj[i])
    end
    do
      local tTar = {}
      for j = 1, 12 do
        for i = 1, #tObj do
          local absA = math.abs(tObj[i].angle - angleMy)
          if absA > 180 then
            absA = 360 - absA
          end
          if absA < j * 30 then
            table.insert(tTar, tObj[i])
          end
        end
        if #tTar > 0 then
          break
        end
      end
      if 0 == #tTar then
        tTar = tObj
      end
      BubbleByDst(tTar)
      if #tTar > 0 then
        local tmp = tTar[1]
        RunTo(tmp.x, tmp.y, 3, 600)
        Skill.CUseSkillByID(4976, tmp.id, -1, -1)
        Sleep(1500)
        PlayerStateTimeOut(5, 8)
        PlayerStateTimeOut(8, 8)
        goto lbl_129
        break
      end
    end
    ::lbl_129::
    Sleep(200)
    DebugStr("第六重:点亮莲花灯")
  end
end

local function GSH_SceneZeroPos()
  local pos = m_npcpos[7]
  pos.r = 15
  return pos
end

local function GSH_GetBoss(aObj)
  local tBoss = ObjFilterByName(aObj, " 燕驰野·影 唐简·影 霜见·影 慕容信·影 ", 3)
  return tBoss
end

local function GSH_GetAttackNPC(aObj, aNPC)
  local tObj = ObjFilterByName(aObj, aNPC.name, 0)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

local function GSH_UseKongZhi(aObj, aIsAttackNpc, aAttackTarget)
  local minMPP = 20
  if 4 == g_self.menpai then
    minMPP = 50
  end
  local temp = {name = "段思安"}
  local tBoss = GSH_GetAttackNPC(aObj, temp)
  if nil == tBoss and false == aIsAttackNpc and #aAttackTarget > 0 then
    local tmp = aAttackTarget[1]
    if tmp.name ~= "蜘蛛" and tmp.name ~= "蜘蛛网" and minMPP < Player:GetMPP() and CDG.attack and Skill:UseKongZhi_fuben(tmp, true, true) then
      DebugStr("观山海:对魁元弟子使用控制技能", 3)
    end
  end
end

local function GSH_KuiYuanDiZi(aObj, aFilter)
  local tObj = ObjFilterByTitle(aObj, " #{PTFB_191228_307} #{PTFB_191228_308} #{PTFB_191228_309} #{PTFB_191228_310} #{PTFB_191228_311} #{PTFB_191228_312} #{PTFB_191228_313} #{PTFB_191228_314} #{PTFB_191228_315} #{PTFB_191228_316} #{PTFB_191228_317} #{PTFB_191228_318} #{PTFB_191228_319} ", 3)
  if #tObj > 0 and aFilter then
    local msHp = m_param.bosshp
    if msHp > 0 then
      local tBoss = GSH_GetBoss(aObj)
      if #tBoss > 0 and msHp >= tBoss[1].hp then
        DebugStr("Boss血量低于%d%%,只会攻击峨嵋弟子", 4, msHp)
        if g_self.isjingong == false then
          GSH_UseKongZhi(aObj, false, tObj)
        end
        tObj = ObjFilterByTitle(aObj, " #{PTFB_191228_310} ", 3)
      end
    end
  end
  if #tObj > 0 and g_self.isjingong and m_param.jzyxboss then
    BubbleByDst(tObj)
    if tObj[1].dst > 2 then
      DebugStr("魁元弟子距离过远,近战优先打Boss", 3)
      tObj = {}
    end
  end
  return tObj
end

local function GSH_GetAttackTID(aObj, aNPC, bHasTrap)
  local tid = -1
  local attackNPC = false
  local attackTab = {}
  local allDiZi = " #{PTFB_191228_307} #{PTFB_191228_308} #{PTFB_191228_309} #{PTFB_191228_310} #{PTFB_191228_311} #{PTFB_191228_312} #{PTFB_191228_313} #{PTFB_191228_314} #{PTFB_191228_315} #{PTFB_191228_316} #{PTFB_191228_317} #{PTFB_191228_318} #{PTFB_191228_319} "
  local _Obj = {}
  for i = 1, #aObj do
    local tmp = aObj[i]
    if tmp.title ~= "" and string.find(allDiZi, " " .. tmp.title .. " ", nil, true) then
      if string.find(m_param.attack_dz, " " .. tmp.title .. " ", nil, true) then
        table.insert(_Obj, tmp)
      end
    else
      table.insert(_Obj, tmp)
    end
  end
  aObj = _Obj
  local tAttack = GSH_KuiYuanDiZi(aObj, true)
  if 0 == #tAttack then
    attackNPC = true
    if #aObj > 0 then
      if aNPC then
        local tmp = GSH_GetAttackNPC(aObj, aNPC)
        if tmp then
          tid = tmp.id
          table.insert(attackTab, tmp)
        end
      else
        local tObj = ObjFilterByTitle(aObj, " #{PTFB_191228_307} #{PTFB_191228_308} #{PTFB_191228_309} #{PTFB_191228_310} #{PTFB_191228_311} #{PTFB_191228_312} #{PTFB_191228_313} #{PTFB_191228_314} #{PTFB_191228_315} #{PTFB_191228_316} #{PTFB_191228_317} #{PTFB_191228_318} #{PTFB_191228_319} ", 4)
        if g_self.isjingong then
          BubbleByDst(tObj, 1)
        else
          BubbleByHP(tObj, 1)
        end
        if tObj[1].name == "蜘蛛" or tObj[1].name == "蜘蛛网" or tObj[1].name == "铁蒺藜" then
          attackNPC = false
        end
        tid = tObj[1].id
        attackTab = tObj
      end
    end
  else
    if g_self.isjingong then
      BubbleByDst(tAttack, 1)
    else
      BubbleByHP(tAttack, 1)
    end
    local tYX = ObjFilterByTitle(tAttack, "#{PTFB_191228_310}", 0)
    if 0 == #tYX then
      tYX = ObjFilterByTitle(tAttack, "#{PTFB_191228_314}", 0)
    end
    if 0 == #tYX then
      tYX = ObjFilterByTitle(tAttack, "#{PTFB_191228_319}", 0)
    end
    if 0 == #tYX then
      tYX = ObjFilterByTitle(tAttack, "#{PTFB_191228_312}", 0)
    end
    if #tYX > 0 then
      DebugColorMsg("优先攻击 " .. tYX[1].title, 2)
      tid = tYX[1].id
    else
      tid = tAttack[1].id
    end
    attackTab = tAttack
  end
  local tCheckDistBoss = ObjFilterByName(aObj, "燕驰野·影 解谊 唐简·影 崔璎 慕容信·影 段思安 霜见·影 无执", 3)
  if -1 ~= tid and bHasTrap and #tCheckDistBoss > 0 and g_self.isjingong == false and #attackTab > 0 and attackTab[1].dst > 15 then
    BubbleByDst(attackTab)
    if attackTab[1].dst > 15 then
      BubbleByDst(aObj)
      if aObj[1].dst > 15 then
        if aObj[1].name ~= "崔璎" or aObj[1].hp > 20 then
          tid = -1
        end
      else
        tid = aObj[1].id
        attackNPC = true
        if aObj[1].name == "蜘蛛" or aObj[1].name == "蜘蛛网" or aObj[1].name == "铁蒺藜" then
          attackNPC = false
        end
        attackTab = aObj
      end
    else
      tid = attackTab[1].id
    end
  end
  return tid, attackNPC, attackTab
end

local function GSH_SaveKongNPC(aEnvObj, aSaveObj)
  local tick_now = GetTickCount()
  local nextObj = TableGetTable(aSaveObj, aEnvObj, "id")
  for i = 1, #aEnvObj do
    local tmp = aEnvObj[i]
    tmp.tick = tick_now
    if FindTableFieldValue(nextObj, "id", tmp.id) == false then
      table.insert(nextObj, tmp)
    end
  end
  return nextObj
end

local function GSH_Attack(aObj, aIsSafe, aIsHasTrap, aTrap)
  local jgFar = false
  local tid = -1
  local tmpid, attackNPC, attackTab = GSH_GetAttackTID(aObj, nil, aIsHasTrap)
  tid = tmpid
  if false == aIsSafe then
    tid = -1
  end
  local tempWD = {name = "傅致远"}
  local wdFZY = GSH_GetAttackNPC(aObj, tempWD)
  if g_self.isjingong and wdFZY and false == attackNPC and -1 ~= tid and #attackTab > 0 and attackTab[1].dst > 2 then
    DebugStr("魁元弟子过远,近攻打boss", 2)
    tid = wdFZY.id
    attackNPC = true
  end
  if aIsHasTrap and -1 ~= tid then
    if g_self.isjingong and #attackTab > 0 and attackTab[1].dst > 2 then
      BubbleByDst(aObj, 1)
      if aObj[1].dst > 2 then
        if aTrap and #aTrap > 0 then
          local tTab = ObjFilterByName(aObj, "夜来 苏延清", 3)
          if CDG.attack and #tTab > 0 and IsPosSafe(aObj[1], aTrap, 5) then
            local function positionIsOpen(_aPosX, _aPosY)
              local pos = {x = _aPosX, y = _aPosY}
              
              return IsPosSafe(pos, aTrap, 5)
            end
            
            local zeroPos = GSH_SceneZeroPos()
            if zeroPos then
              local banjin = 14
              local path = AStar(nil, aObj[1], zeroPos.x - banjin, zeroPos.x + banjin, zeroPos.y - banjin, zeroPos.y + banjin, positionIsOpen)
              AStarMove(path)
            end
          end
        end
        jgFar = true
      else
        tid = aObj[1].id
      end
    elseif false == g_self.isjingong then
      local temp = {name = "苏延清"}
      local tBoss = GSH_GetAttackNPC(aObj, temp)
      if nil == tBoss and false == attackNPC and #attackTab > 0 and attackTab[1].dst > 14 then
        BubbleByDst(attackTab, 1)
        if attackTab[1].dst > 14 then
          BubbleByDst(aObj, 1)
          attackNPC = true
          tid = aObj[1].id
        else
          tid = attackTab[1].id
        end
      end
    end
  end
  if jgFar then
    DebugStr("周围陷阱,近攻暂时不过去", 2)
    local tmp = FindObjByTID(tid)
    if tmp and tmp.dst <= 15 then
      JinGongFarSkill(tid, true)
    end
  else
    RelivePlayerJZDJ()
    local bUseSkill = true
    local bUseJinJiSkill = false
    local temp = {name = "崔璎"}
    local tBoss = GSH_GetAttackNPC(aObj, temp)
    if tBoss then
      if tBoss.hp < 40 and tBoss.hp > 10 then
        bUseSkill = false
      end
      if #attackTab > 0 and attackTab[1].title == "#{PTFB_191228_310}" then
      elseif IsInDebugMsgTime("#{BSJN_200327_36}", false, 40) then
        bUseSkill = true
        bUseJinJiSkill = true
        if false == attackNPC then
          attackNPC = true
          tid = tBoss.id
        end
      end
    end
    if false == bUseJinJiSkill then
      local tBoss = GSH_GetBoss(aObj)
      local msHp = m_param.bosshp
      if #tBoss > 0 and msHp >= tBoss[1].hp and tBoss[1].name ~= "崔璎" then
        DebugStr("Boss血量低于%d%%,甩技能", 2, msHp)
        bUseJinJiSkill = true
      end
    end
    if false == bUseJinJiSkill and attackNPC and #attackTab > 0 and 4 ~= g_self.menpai and attackTab[1].hp < 13 then
      DebugStr("甩技能打boss", 2)
      bUseJinJiSkill = true
    end
    if -1 ~= tid then
      GSH_UseKongZhi(aObj, attackNPC, attackTab)
      if attackNPC then
        if not string.find(CDG.skill_attack_jinji_disable, "指点江山 溪山行旅 昭君出塞", nil, true) then
          CDG.skill_attack_jinji_disable = CDG.skill_attack_jinji_disable .. " 指点江山 溪山行旅 昭君出塞 "
        end
        if false == bUseJinJiSkill and attackTab[1].name == "解谊" then
          local tStr = EnumObjBuff(attackTab[1])
          bUseSkill = false
          for i = 1, #tStr do
            if string.find(tStr[i], "护盾：抵消所受到伤害", nil, true) then
              PushColorMsg("集火击破护盾")
              bUseSkill = true
              bUseJinJiSkill = true
              break
            elseif string.find(tStr[i], "酩酊大醉", nil, true) then
              PushColorMsg("解谊虚弱状态,甩技能！")
              bUseSkill = true
              bUseJinJiSkill = true
              break
            end
          end
          local tAll = Enum2XByClass("怪物 NPC", {0, -1})
          local tJiuTan = ObjFilterByName(tAll, "酒坛", 0)
          if #tJiuTan > 0 then
            bUseSkill = true
            bUseJinJiSkill = true
          end
        end
      else
        CDG.skill_attack_jinji_disable = string.gsub(CDG.skill_attack_jinji_disable, "指点江山 溪山行旅 昭君出塞", "")
        CDG.skill_attack_jinji_disable = string.gsub(CDG.skill_attack_jinji_disable, "  ", " ")
        XiShanXingLv(tid)
        ZhiDianJiangShan(tid, false)
        local tGB = GSH_GetBoss(aObj)
        if #tGB > 0 then
          bUseSkill = false
          bUseJinJiSkill = false
        end
      end
    end
    local temp = {name = "段思安"}
    local tBoss = GSH_GetAttackNPC(aObj, temp)
    if 4 == g_self.menpai and tBoss then
      bUseSkill = false
      bUseJinJiSkill = false
    end
    FubenAttack(tid, bUseSkill, bUseJinJiSkill)
  end
end

local function GSH_mj_cb()
  if IsInDebugMsgTime("#{BSJN_200327_84}", false, 5) then
    return false
  end
  if IsInDebugMsgTime("BSJN_200327_11", false, 5) then
    return false
  end
  if IsInDebugMsgTime("BSJN_200327_173", false, 5) then
    return false
  end
  if IsInDebugMsgTime("BSJN_200327_172", false, 5) then
    return false
  end
  return true
end

local function GSH_GetAttackNPC(aObj, aNPC)
  local tObj = ObjFilterByName(aObj, aNPC.name, 0)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

local function GSH_MingJiao()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 6)
  if not myPos then
    return
  end
  npc.name = "燕驰野·影"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  Player:GetName()
  CDG.call.back1 = GSH_mj_cb
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tKong = ObjFilterByName(tAll, "空npc", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe, bHasTrap = true, false
    local bTrapTarget = false
    if tBoss then
      local tTrap = {}
      table.insert(tTrap, tBoss)
      local bIn, strMsg = IsInDebugMsgTime("BSJN_200327_11", false, 5)
      if not bIn then
        bIn, strMsg = IsInDebugMsgTime("BSJN_200327_173", false, 5)
        if not bIn then
          bIn, strMsg = IsInDebugMsgTime("BSJN_200327_172", false, 5)
        end
      end
      if bIn then
        bHasTrap = true
        if string.find(strMsg, g_self.name, nil, true) then
          bTrapTarget = true
          PushDebugMessage("将被天欲燃")
        end
        local defPos = {
          x = npc.xSelf,
          y = npc.ySelf
        }
        local myPos = Player:GetPos()
        defPos.dst = GetDist(defPos.x, defPos.y, myPos.x, myPos.y)
        local safeDist = 6
        if IsPosSafe(myPos, tTrap, safeDist) == false then
          bTrapSafe = false
          if IsPosSafe(defPos, tTrap, safeDist) then
            FastRun(defPos, 3)
          else
            FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
          end
        end
      end
      if IsInDebugMsgTime("#{BSJN_200327_84}", false, 5) then
        bHasTrap = true
        if #tKong > 0 then
          bHasTrap = true
          FubenTrapRun(npc.name, npc.x, npc.y, 11, npc.r, tKong, nil, FubenRunSafe, nil, nil, npc)
        end
      end
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("明教守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_tm_cb()
  if IsInDebugMsgTime("#{BSJN_200327_18}", false, 4) then
    return false
  end
  return true
end

local function GSH_TangMeng()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "唐简·影"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  local trapName = ""
  Player:GetName()
  CDG.call.back1 = GSH_tm_cb
  local saveKong = {}
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    tNPC = ObjFilterByName(tNPC, " 铁蒺藜 ", 4)
    local tTie = ObjFilterByName(tAll, "铁蒺藜", 0)
    local tKong = ObjFilterByName(tAll, "空npc", 0)
    local tCanYing = ObjFilterByName(tAll, "残影", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    saveKong = GSH_SaveKongNPC(tKong, saveKong)
    local bTrapSafe, bHasTrap = true, false
    if tBoss and IsInDebugMsgTime("#{BSJN_200327_18}", false, 4) then
      if -1 == Player:GetBuff("定身：无法移动") then
      end
      local tick_now = GetTickCount()
      local tXianJin = {}
      for i = 1, #saveKong do
        local tmp = saveKong[i]
        if tick_now - tmp.tick < 5000 then
          table.insert(tXianJin, tmp)
        end
      end
      BubbleSort(tXianJin, "tick", 2)
      if #tXianJin > 0 then
        bHasTrap = true
        bTrapSafe = FubenShanXing(tBoss, tXianJin[1], 1)
      else
        PushDebugMessage("发现星河流倾")
      end
    end
    if false == bHasTrap and #tCanYing > 0 and #tKong > 0 then
      local tSafePos = {}
      if #tSafePos > 0 then
        if -1 == Player:GetBuff("定身：无法移动") then
          bHasTrap = true
          GetAllPosDist(tSafePos, nil, "dst")
          BubbleByDst(tSafePos)
          if false == FastRun(tSafePos[1], 4) then
            PushDebugMessage("躲避残影:移动到安全坐标")
            bTrapSafe = false
          else
            bTrapSafe = true
          end
        end
      else
        PushDebugMessage("躲避残影:未找到安全坐标")
      end
    end
    if #tTie > 0 and not m_param.nottmtjl then
      tNPC = tTie
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("唐门守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_MR_cb_jiaxue(aType, aObj)
  if 1 == aType then
    if -1 ~= Player:GetBuff("示剑：被治疗效果将按一定比例治疗慕容信") then
      PushDebugMessage("暂不给自己加血")
      return false
    end
    return true
  elseif 2 == aType then
    for i = 1, #aObj do
      local tmp = aObj[i]
      if not Target:FindBuff(tmp, "示剑：被治疗效果将按一定比例治疗慕容信") then
        return tmp
      else
        PushDebugMessage("暂不给 " .. tmp.name .. " 加血")
      end
    end
  end
  return nil
end

local function GSH_mr_cb()
  if IsInDebugMsgTime("#{BSJN_200327_99}", false, 5) then
    return false
  end
  if IsInDebugMsgTime("#{BSJN_200327_101}", false, 6) then
    return false
  end
  return true
end

local function GSH_MuRong()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "慕容信·影"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  CDG.call.back1 = GSH_mr_cb
  CDG.call.CanJiaXue = GSH_MR_cb_jiaxue
  CDG.skill_attack_jinji_disable = " 聚星阵·长生 情尽盈血 "
  local saveKong = {}
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tKong = ObjFilterByName(tAll, "空npc", 0)
    local tMRX = GSH_GetAttackNPC(tNPC, npc)
    saveKong = GSH_SaveKongNPC(tKong, saveKong)
    if nil == tMRX then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bHasTrap, bTrapSafe = false, true
    if tMRX and IsInDebugMsgTime("#{BSJN_200327_99}", false, 5) then
      bHasTrap = true
      local tTrap = {}
      table.insert(tTrap, tMRX)
      local safeDist = 6
      if g_self.isjingong then
        npc.selfdist = true
        bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_Sort, nil, nil, npc)
      else
        bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
      end
    end
    if -1 == Player:GetBuff("示剑：成为慕容信释放示剑的目标") then
      if tMRX and false == bHasTrap and IsInDebugMsgTime("#{BSJN_200327_101}", false, 6) then
        BubbleSort(saveKong, "tick", 2)
        if #saveKong > 0 and GetTickCount() - saveKong[1].tick < 4000 then
          bHasTrap = true
          local shijian = saveKong[1]
          local jgZouWei = 1
          local diffAngle = 20
          if tMRX.dst < 4 then
            diffAngle = 45
          end
          if tMRX.dst < 3 then
            diffAngle = 90
            jgZouWei = 3
          end
          bTrapSafe = FubenShanXing(tMRX, shijian, jgZouWei, diffAngle)
        end
      end
    else
      debugnote = " 已成为示剑目标"
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("慕容守关 " .. debugnote)
  end
  CDG.call.CanJiaXue = nil
  CDG.call.back1 = nil
  CDG.skill_attack_jinji_disable = ""
end

local function GSH_TianShan()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "霜见"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  local saveKong = {}
  local hp_first = CDG.hp.em_firstlist_name
  CDG.hp.em_firstlist_name = ""
  CDG.call.back1 = GSH_ts_cb
  while FubenCheckSceneDie(m_param.sceneID) do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tKong = ObjFilterByName(tAll, "空npc", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    saveKong = GSH_SaveKongNPC(tKong, saveKong)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe, bHasTrap = true, false
    if tBoss and IsInDebugMsgTime("#{BSJN_200327_107}", false, 4) then
      bHasTrap = true
      BubbleSort(saveKong, "tick", 2)
      if #saveKong > 0 and GetTickCount() - saveKong[1].tick < 4000 then
        local shanxing = saveKong[1]
        bTrapSafe = FubenShanXing(tBoss, shanxing, 1, 25)
      end
    end
    while 4 == g_self.menpai and IsInDebugMsgTime("#{BSJN_200327_109}", false, 3) do
      CDG:checkHP_Player()
      Sleep(200)
      if Player:GetMP() < 2000 then
        break
      end
      DebugStr("峨嵋集中加血", 2)
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("天山守关 " .. debugnote)
  end
  CDG.call.back1 = nil
  CDG.hp.em_firstlist_name = hp_first
end

local function MWJ_Boss7()
  while FubenCheckSceneDie(m_param.sceneID) do
    local tObj = Enum2XByName(" 燕驰野·影 唐简·影 慕容信·影 霜见·影 ", {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      if tmp.name == "燕驰野·影" then
        GSH_MingJiao()
      elseif tmp.name == "唐简·影" then
        GSH_TangMeng()
      elseif tmp.name == "慕容信·影" then
        GSH_MuRong()
      elseif tmp.name == "霜见·影" then
        GSH_TianShan()
      end
    else
      break
    end
    Sleep(200)
    DebugStr("第七重:观山海")
  end
end

local function MWJ_OnAction()
  local tObj = Enum2XByName(" 田晓宇 刘昌浩 董思 赵博 李欣泽 叶秋霜 彭靖 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    local tmp = tObj[1]
    MWJ_RefreshStep(tmp.name)
    DebugColorMsg("对话关卡NPC", 2)
    RunTo(tmp.x, tmp.y, 3, 1000)
    Dismount(650)
    if Player:IsLeader() then
      CloseAllWindow()
      OpenTalk(tmp.id, 800)
      local allItem = GetNPCEventListAllItem()
      if string.find(allItem, "#{RGPT_231130_97}", nil, true) or string.find(allItem, "#{RGPT_231130_204}", nil, true) then
        DialogOptionClicked("技能分配", 1, 1000)
        GetLuaValue("setmetatable(_G, {__index = RouGe_Skill_Env});RouGe_Skill_DefaultSkill()")
        Sleep(800)
        GetLuaValue("setmetatable(_G, {__index = RouGe_Skill_Env});RouGe_Skill_OkClicked()")
        Sleep(800)
        CloseAllWindow()
      else
        local hp0 = Team:CheckMemberHP(0)
        if hp0 and Team:GetSurroundMember(10) == Team:GetMemberCount() then
          DialogOptionClicked("开始挑战", 1, 1000)
          if IsWindowVisible("RouGe_BossDaZao") then
            local check4 = -1
            if tmp.name == "董思" then
              check4 = m_param.xmxjzh
            elseif tmp.name == "李欣泽" then
              check4 = m_param.xmzmhg
            elseif tmp.name == "彭靖" then
              check4 = m_param.xmzjzh
            end
            MWJ_BossDaZao(tmp.id, check4)
          end
        end
      end
    else
      FubenAttack(-1)
    end
    return
  end
  local tObj = Enum2XByName(" 慕容复·影 庞企·影 丁春秋·影 ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss1()
    return
  end
  local tObj = Enum2XByName("大轮寺梵僧", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss2()
    return
  end
  local tObj = Enum2XByName(" 裂海玄蜥·影 裂海魔龙·影 灭世火凤·影 炼狱凤凰·影 摄灵蛊花·影 噬魂花妖·影 ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss3()
    return
  end
  local tObj = Enum2XByName(" 锡杖 净瓶 金刚杵 智慧剑 雪莲 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss4()
    return
  end
  local tObj = Enum2XByName(" 李秋水·影 天山童姥·影 无崖子·影 虚竹·影 ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss5()
    return
  end
  local tObj = Enum2XByName(" 莲花灯 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss6()
    return
  end
  local tObj = Enum2XByName(" 燕驰野·影 唐简·影 慕容信·影 霜见·影 ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    MWJ_RefreshStep(tObj[1].name)
    CloseAllWindow()
    MWJ_Boss7()
    return
  end
  local tObj = Enum2XByName("王静萱", {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 and tObj[1].dst < 15 then
    local tmp = tObj[1]
    RunTo(tmp.x, tmp.y, 3, 1000)
    PlayerStateTimeOut(2, 10)
    OpenTalk(tmp.id, 1000)
    local allItem = GetNPCEventListAllItem()
    if string.find(allItem, "#{RGPT_231130_110}", nil, true) then
      if string.find(allItem, "#{RGPT_231130_116}", nil, true) then
        QuestFrameOptionClicked_Item("#{RGPT_231130_116}", 1, 1000)
        return
      elseif string.find(allItem, "#{RGPT_231130_115}", nil, true) then
        QuestFrameOptionClicked_Item("#{RGPT_231130_115}", 1, 1000)
        return
      elseif string.find(allItem, "#{RGPT_231130_114}", nil, true) then
        QuestFrameOptionClicked_Item("#{RGPT_231130_114}", 1, 1000)
        return
      elseif string.find(allItem, "#{RGPT_231130_113}", nil, true) then
        QuestFrameOptionClicked_Item("#{RGPT_231130_113}", 1, 1000)
        return
      elseif string.find(allItem, "#{RGPT_231130_112}", nil, true) then
        QuestFrameOptionClicked_Item("#{RGPT_231130_112}", 1, 1000)
        return
      else
        if string.find(allItem, "#{RGPT_231130_111}", nil, true) then
          QuestFrameOptionClicked_Item("#{RGPT_231130_111}", 1, 1000)
          return
        else
        end
      end
    end
  end
  local pos_step = -1
  local mypos = Player:GetPos()
  if mypos.x <= 100 and mypos.y > 228 then
    pos_step = 1
  elseif mypos.x <= 152 and mypos.y > 192 then
    pos_step = 2
  elseif mypos.x <= 80 and mypos.y > 98 and mypos.y < 148 then
    pos_step = 3
  elseif mypos.x <= 98 and mypos.y < 98 then
    pos_step = 4
  elseif mypos.x > 100 and mypos.x <= 181 and mypos.y > 80 and mypos.y < 152 then
    pos_step = 5
  elseif mypos.x > 181 and mypos.x <= 276 and mypos.y > 140 and mypos.y < 200 then
    pos_step = 6
  elseif mypos.x > 210 and mypos.x <= 276 and mypos.y < 90 then
    pos_step = 7
  end
  if -1 == pos_step then
    PushColorMsg("未能识别的区域")
    if -1 ~= m_last_step and 7 ~= m_last_step then
      local nNextStep = m_last_step + 1
      local pos = m_npcpos[nNextStep]
      RunTo(pos.x, pos.y, 3, 1000)
    end
    return
  end
  if 7 ~= pos_step and -1 ~= m_tonext_tick and GetTickCount() - m_tonext_tick > 6000 then
    DebugStr("前往下个NPC", 3)
    local nNextStep = pos_step + 1
    if -1 == m_next_step then
      m_next_step = nNextStep
    elseif m_next_step ~= nNextStep then
      m_next_step = -1
      m_tonext_tick = -1
      return
    end
    if 3 ~= nNextStep and 5 ~= nNextStep and 7 ~= nNextStep then
      UseMount()
    end
    if 3 == nNextStep then
      if RunTo(113, 196, 3, 1000) == false then
        Dismount(500)
        TalkNpc("雪雕", 1000)
        QuestFrameOptionClicked_Item("#{RGPT_231130_639}", 1, 1000)
      end
      return
    elseif 5 == nNextStep then
      if RunTo(92, 49, 3, 1000) == false then
        Dismount(500)
        TalkNpc("雪雕", 1000)
        QuestFrameOptionClicked_Item("#{RGPT_231130_642}", 1, 1000)
      end
      return
    elseif 7 == nNextStep then
      if RunTo(257, 155, 3, 1000) == false then
        TalkNpc("幻境深处", 1000)
        QuestFrameOptionClicked_Item("#{RGPT_231130_116}", 1, 1000)
      end
      return
    end
    local pos = m_npcpos[nNextStep]
    RunTo(pos.x, pos.y, 3, 1000)
  else
    DebugStr("寻找NPC", 2)
    local pos = m_npcpos[pos_step]
    RunTo(pos.x, pos.y, 3, 1000)
    if GetDist(pos.x, pos.y) < 5 then
      if IsInDebugMsgTime("#{RGPT_231130_126}", nil, 10) then
      elseif -1 == m_tonext_tick then
        m_tonext_tick = GetTickCount()
      end
      FubenAttack(-1)
    end
  end
end

local function LHFD_OnDie()
  DieRelive(0)
  local tObj = Enum2XByName(" 田晓宇 刘昌浩 董思 赵博 李欣泽 叶秋霜 彭靖 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    PushColorMsg(m_script_name .. ":已经灭队，自动出窍！")
    DieRelive(-1)
  else
    local bHave, HPValue = Team:IsSceneHaveFammily(nil, 4)
    if false == bHave or 0 == HPValue then
      Sleep(4000)
      bHave, HPValue = Team:IsSceneHaveFammily(nil, 4)
      if false == bHave or 0 == HPValue then
        PushDebugMessage("峨嵋已出或者已死亡,自动出窍")
        DieRelive(-1)
      end
    end
  end
  return false
end

local function MWJ_OnProcess()
  while GetSceneID() == m_param.sceneID do
    if 9 == Player:GetState() then
      Sleep(2000)
      DieRelive(0)
      Sleep(2000)
      DieRelive(-1)
    end
    MWJ_OnAction()
    Sleep(50)
    DebugStr(m_script_name .. "：副本中 ", 3)
  end
end

function _SMain(...)
  local bOver = false
  local bLing = false
  DeleteDebugMsg("#{RGPT_231130_76}")
  while true do
    local curScene = GetSceneID()
    if curScene == m_param.sceneID then
      MWJ_OnProcess()
      bOver = true
    else
      if bOver then
        break
      end
      GoToSceneNPC("高成彦", 355, 221, LUOYANG_ID)
      ChangeSceneLine()
      if Player:IsLeader() then
        Sleep(500)
        FubenAttack(-1)
        local teamCount = m_teamCount
        if Team:IsCountReady(teamCount) then
          QuestFrameOptionClicked_Item("#{RGPT_231130_02}", 1, 600)
          QuestFrameAcceptClicked(600)
        end
      else
        FubenAttack(-1)
      end
      if IsInDebugMsg("#{RGPT_231130_76}") then
        bLing = true
      end
      if false == bLing then
        GoToSceneNPC("高成彦", 355, 221, LUOYANG_ID)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{RGPT_231130_03}", 1, 600)
        QuestFrameOptionClicked_Item("#{RGPT_231130_71}", 1, 600)
      end
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
end

RecvState(3)
_SMain()
ScriptOnStop(m_script_name)
m_param = nil
