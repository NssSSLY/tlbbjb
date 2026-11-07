-- 反编译自 dfz64.dll 内嵌字节码 00302521（unluac 2025-12-23；仅供分析）
local m_script_name = "观山海"
ScriptOnStart(m_script_name, true, true)
CDG.hp.em_yxjx = true
local m_teamCount = HandleTextToNumber(GetConfigText("组队人数", "观山海"), 6)
local m_param = {}
m_param.attack_dz = ""
m_param.reward_check_cs = HandleTextToNumber(GetConfigText("观山海", "勾选平均层数"), 0)
m_param.reward_check_hp = HandleTextToNumber(GetConfigText("观山海", "勾选平均血量"), 0)
m_param.reward_check_member = HandleTextToNumber(GetConfigText("观山海", "勾选队伍人数"), 0)
m_param.jzz = HandleTextToNumber(GetConfigText("观山海", "金钟罩层数"), 4)
m_param.kh = HandleTextToNumber(GetConfigText("观山海", "狂慧层数"), 7)
m_param.leave_ceng_value = HandleTextToNumber(GetConfigText("观山海", "离开层数"), 100)
m_param.bosshp = HandleTextToNumber(GetConfigText("观山海", "不打弟子BOSS血"), 0)
m_param.reward_check = GetConfigBool("观山海", "勾选奖励")
m_param.count3 = GetConfigBool("观山海", "刷完奖励次数")
m_param.leave_asleader = GetConfigBool("观山海", "队长不在离开")
m_param.nottmtjl = GetConfigBool("观山海", "不打铁蒺藜")
m_param.notxypw = GetConfigBool("观山海", "逍遥黑子不跑")
m_param.jzyxboss = GetConfigBool("观山海", "近战优先BOSS")
m_param.leave_ceng = GetConfigBool("观山海", "队员层数")
m_param.leave_member = GetConfigBool("观山海", "队长层数")
m_param.open_thd = GetConfigCommbox("观山海", "谁开桃花岛")
m_param.open_gb = GetConfigCommbox("观山海", "谁开丐帮")
m_param.sqmy = GetConfigCommbox("观山海", "谁敲木鱼")
m_param.tzcs = GetConfigCommbox("观山海", "挑战层数")
m_param.qscs = GetConfigCommbox("观山海", "起始层数")
m_param.un_attack_boss = HandleText_AddFuHao(GetConfigText("观山海", "不打BOSS"), " ", true)

local function GSH_ParamInit()
  m_param.attack_dz = " #{PTFB_191228_310} "
  if GetConfigText("观山海", "弟子少林") == "1" then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_318} "
  end
  if "1" == GetConfigText("观山海", "弟子明教") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_307} "
  end
  if "1" == GetConfigText("观山海", "弟子丐帮") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_308} "
  end
  if "1" == GetConfigText("观山海", "弟子武当") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_312} "
  end
  if "1" == GetConfigText("观山海", "弟子星宿") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_311} "
  end
  if "1" == GetConfigText("观山海", "弟子天龙") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_314} "
  end
  if "1" == GetConfigText("观山海", "弟子天山") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_315} "
  end
  if "1" == GetConfigText("观山海", "弟子逍遥") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_316} "
  end
  if "1" == GetConfigText("观山海", "弟子慕容") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_317} "
  end
  if "1" == GetConfigText("观山海", "弟子唐门") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_309} "
  end
  if "1" == GetConfigText("观山海", "弟子鬼谷") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_319} "
  end
  if "1" == GetConfigText("观山海", "弟子桃花岛") then
    m_param.attack_dz = m_param.attack_dz .. "#{PTFB_191228_313} "
  end
end

local function GSH_SceneZeroPos()
  local posArr = {
    [749] = {
      x = 70,
      y = 70,
      r = 15
    },
    [750] = {
      x = 59.1,
      y = 59.2,
      r = 15
    },
    [752] = {
      x = 96.5,
      y = 97,
      r = 15
    }
  }
  local sceneID = GetSceneID()
  return posArr[sceneID]
end

local function GSH_Choose()
  local strText = [[
        setmetatable(_G, {__index = WuLin_Env})
        if this:IsVisible() then
            if Player:IsLeader() == 1 then
                if WuLin_Right_Info1_Choose:IsVisible() then
                    if WuLin_Right_Info1_Choose:GetProperty("Disabled") == "False" then
                        return 1
                    end
                elseif WuLin_Right_Info4_Choose:IsVisible() then
                    return 2
                end
            else
                if WuLin_Right_Info2_Choose:IsVisible() then
                    if WuLin_Right_Info2_Choose:GetProperty("Disabled") == "False" then
                        return 3
                    else
                        return 4
                    end
                elseif WuLin_Right_Info3_Choose:IsVisible() then
                    return 5
                end
            end
        end
        return -1       
    ]]
  local ret = GetLuaValue(strText, "n")
  local msg = "未知确认状态"
  if 1 == ret then
    msg = "需要本队长确认"
  elseif 2 == ret then
    msg = "本队长已确认,等待队员确认"
  elseif 3 == ret then
    msg = "需要本队员确认"
  elseif 4 == ret then
    msg = "本队员已确认,等待其它队员"
  elseif 5 == ret then
    msg = "队员等待队长确认"
  end
  return ret, msg
end

local function GSH_WeekAward()
  if not m_param.reward_check then
    local strText = [[
                setmetatable(_G, {__index = WuLin_Env})
                if this:IsVisible() then
                    local check = WuLin_Right_Mode:GetCheck()
                    if check > 0 then
                        WuLin_Right_Mode:SetCheck(0)
                        Clear_XSCRIPT()
                            Set_XSCRIPT_Function_Name("WeekAwardCancelActive")
                            Set_XSCRIPT_ScriptID(893398)
                            Set_XSCRIPT_ParamCount(0)
                        Send_XSCRIPT()    
                    end
                end      
            ]]
    GetLuaValue(strText)
    return
  end
  local needMember = m_param.reward_check_member
  local avgHP = m_param.reward_check_hp
  local avgStage = m_param.reward_check_cs
  local bNextCheck = true
  if needMember > 0 then
    local nCount = Team:GetMemberCount()
    if needMember > 6 then
      needMember = 6
    end
    if nCount < needMember then
      PushDebugMessage("队伍人数不达要求,不勾选奖励")
      bNextCheck = false
    end
  end
  if bNextCheck and avgHP > 0 then
    local hpAverage = Team:GetMemberHPAverage()
    if avgHP > hpAverage / 10000 then
      PushDebugMessage("队伍平均血不达要求,不勾选奖励")
      bNextCheck = false
    end
  end
  if bNextCheck and avgStage > 0 then
    if avgStage > 100 then
      avgStage = 100
    end
    local curStage = GetLuaValue("return tonumber(WuLinZhiDian:GetAverageStage()) ", "n")
    if avgStage > curStage then
      PushDebugMessage("队伍平均层数不达要求,不勾选奖励")
      bNextCheck = false
    end
  end
  local strText = "        setmetatable(_G, {__index = WuLin_Env})\n        if this:IsVisible() then\n            local awardCount = WuLinZhiDian:GetAvalibleAwardCount()\n            if awardCount > 0 then\n                WuLin_Right_Mode:SetCheck(1)\n                Clear_XSCRIPT()\n                Set_XSCRIPT_Function_Name(\"WeekAwardActive\")\n                Set_XSCRIPT_ScriptID(893398)\n                Set_XSCRIPT_ParamCount(0)\n                Send_XSCRIPT()\n            else\n                meTestMsg(\"本周已无法勾选奖励\")\n            end\n        end   \n    "
  if bNextCheck then
    PushColorMsg("已达到勾选奖励要求")
  else
    PushColorMsg("不达要求不勾选奖励")
    strText = [[
                setmetatable(_G, {__index = WuLin_Env})
                if this:IsVisible() then
                    WuLin_Right_Mode:SetCheck(0)
                    Clear_XSCRIPT()
			            Set_XSCRIPT_Function_Name("WeekAwardCancelActive")
			            Set_XSCRIPT_ScriptID(893398)
			            Set_XSCRIPT_ParamCount(0)
                    Send_XSCRIPT()      
                end      
            ]]
  end
  GetLuaValue(strText)
  Sleep(2000)
end

local function GSH_Up_GetNextChoice()
  local strText = [[
        local minC = 0
        local maxC = 0
        setmetatable(_G, {__index = WuLin_Up_Env})
        if this:IsVisible() then
            local nCnt = WuLin_Up_Choice:GetListCount()
            if nCnt > 0 then
                WuLin_Up_Choice:SetCurrentSelect(0)
                minC = WuLin_Up_Choice:GetCurrentSelect()
                WuLin_Up_Choice:SetCurrentSelect(nCnt - 1)
                maxC = WuLin_Up_Choice:GetCurrentSelect()
            end
        end
        return minC,maxC       
    ]]
  return GetLuaValue(strText, "nn")
end

local function GSH_GetNextChoice()
  local strText = [[
            local minC = 0
            local maxC = 0
            setmetatable(_G, {__index = WuLin_Env})
            if this:IsVisible() then
                local nCnt = WuLin_Right_Info1_Choice:GetListCount()
                if nCnt > 0 then
                    WuLin_Right_Info1_Choice:SetCurrentSelect(0)
                    minC = WuLin_Right_Info1_Choice:GetCurrentSelect()
                    WuLin_Right_Info1_Choice:SetCurrentSelect(nCnt - 1)
                    maxC = WuLin_Right_Info1_Choice:GetCurrentSelect()
                end
            end
            return minC,maxC       
    ]]
  return GetLuaValue(strText, "nn")
end

local function GSH_GetCurrentCeng()
  local strText = [[
        local strB, strS, strG = "", "", ""
        setmetatable(_G, {__index = WuLin_Small_Env})
        if this:IsVisible() then
            if WuLin_Small_Layer1BKG:IsVisible() then
                strB = WuLin_Small_Layer1BKG:GetProperty("Image")
            end
            if WuLin_Small_Layer2BKG:IsVisible() then
                strS = WuLin_Small_Layer2BKG:GetProperty("Image")
            end
            if WuLin_Small_Layer3BKG:IsVisible() then
                strG = WuLin_Small_Layer3BKG:GetProperty("Image")
            end
        end
        return strB, strS, strG
    ]]
  local strB, strS, strG = GetLuaValue(strText, "sss")
  local _, _, bai = string.find(strB, "Ceng(%d)")
  local _, _, shi = string.find(strS, "Ceng(%d)")
  local _, _, ge = string.find(strG, "Ceng(%d)")
  bai = tonumber(bai)
  shi = tonumber(shi)
  ge = tonumber(ge)
  if bai then
    if 0 ~= bai then
      return 100
    end
  elseif ge then
    if shi and ge then
      return shi * 10 + ge
    end
  elseif shi then
    return shi
  end
  return 0
end

local function GSH_GetClickCeng(aMin, aMax, aUiSel)
  if 0 == aMin or 0 == aMax then
    PushDebugMessage("层数获取失败")
    return 0
  end
  local nSel = aUiSel
  local nCeng = aMin
  if 1 == nSel then
    for i = aMin, aMax do
      nCeng = i
      if 0 == i % 5 then
        break
      end
    end
  elseif 2 == nSel then
    nCeng = aMax
  end
  return nCeng
end

local function GSH_ClickNextCeng(aMin, aMax)
  local nCeng = 0
  if 0 == m_param.qscs.sel then
    nCeng = GSH_GetClickCeng(aMin, aMax, m_param.tzcs.sel)
  elseif 1 == m_param.qscs.sel then
    nCeng = 1
  elseif 2 == m_param.qscs.sel then
    nCeng = GSH_GetClickCeng(aMin, aMax, 1)
  elseif 3 == m_param.qscs.sel then
    nCeng = GSH_GetClickCeng(aMin, aMax, 2)
  else
    nCeng = m_param.qscs.sel - 3
  end
  if aMax < nCeng then
    nCeng = aMax
  end
  if nCeng <= 0 then
    return
  end
  PushDebugMessage("观山海:挑战第" .. nCeng .. "层,最低%d层,最高%d层", aMin, aMax)
  local strText = fmt([[
        setmetatable(_G, {__index = WuLin_Env})
        if this:IsVisible() then
            WuLin_Right_Info1_Choice:SetCurrentSelect(%d)
        end  
        ]], nCeng - 1)
  GetLuaValue(strText)
  Sleep(800)
  IsWindowVisible("WuLin", "WuLin_Leader_OnChooseStageConfirm()")
end

local function GSH_Up_ClickNextCeng(aMin, aMax)
  local nCeng = GSH_GetClickCeng(aMin, aMax, m_param.tzcs.sel)
  if 0 == nCeng then
    return
  end
  PushDebugMessage("观山海:挑战第" .. nCeng .. "层,最低%d层,最高%d层", aMin, aMax)
  local strText = fmt([[
            Clear_XSCRIPT()
		        Set_XSCRIPT_Function_Name("LeaderUpgradeConfirm")
		        Set_XSCRIPT_ScriptID(893399)
		        Set_XSCRIPT_Parameter(0, %d)
		        Set_XSCRIPT_ParamCount(1)
	        Send_XSCRIPT()
        ]], nCeng)
  GetLuaValue(strText)
  Sleep(1000)
end

local function GSH_GetBoss(aObj)
  local tBoss = ObjFilterByName(aObj, " 燕驰野 解谊 唐简 崔璎 夜来 傅致远 离人偶 朝覆雨 段思安 霜见 原微之 慕容信 无执 苏延清 ", 3)
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
  local tCheckDistBoss = ObjFilterByName(aObj, "燕驰野 解谊 唐简 崔璎 慕容信 段思安 霜见 无执", 3)
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

local function GSH_MingJiao()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 6)
  if not myPos then
    return
  end
  npc.name = "燕驰野"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  Player:GetName()
  CDG.call.back1 = GSH_mj_cb
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
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

local function GSH_gb_cb()
  if IsInDebugMsgTime("BSJN_200327_60", false, 5) then
    return false
  end
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tJiuTan = ObjFilterByName(tAll, "酒坛", 0)
  if #tJiuTan > 0 and -1 ~= Player:GetBuff("追击目标：被解谊持续追击") then
    RunTo(tJiuTan[1].x, tJiuTan[1].y, 0, 200)
    return false
  end
  return true
end

local function GSH_GaiBang()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "解谊"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  CDG.call.back1 = GSH_gb_cb
  local saveKong = {}
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tJiuTan = ObjFilterByName(tAll, "酒坛", 0)
    local tKong = ObjFilterByName(tAll, "空npc", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    saveKong = GSH_SaveKongNPC(tKong, saveKong)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe, bHasTrap = true, false
    local bAttack = true
    if #tJiuTan > 0 then
      if -1 ~= Player:GetBuff("追击目标：被解谊持续追击") then
        bAttack = false
        local tmp = tJiuTan[1]
        PushColorMsg("与解谊拼酒")
        if 5 ~= Player:GetState() then
          if tmp.dst > 2 then
            FastRun(tmp, 5)
          end
          Skill.CUseSkillByID(3922, tmp.id, -1, -1)
          Sleep(500)
        end
        PlayerStateTimeOut(5, 10)
      elseif tBoss then
        local temp = {}
        table.insert(temp, tBoss)
        tNPC = temp
      end
    elseif tBoss and Target:FindBuff(tBoss, "酩酊大醉") then
      local temp = {}
      table.insert(temp, tBoss)
      tNPC = temp
    end
    if tBoss and bAttack then
      local tTrap = {}
      table.insert(tTrap, tBoss)
      local bIn, strMsg = IsInDebugMsgTime("BSJN_200327_60", false, 6)
      if bIn then
        bHasTrap = true
        local safeDist = 6
        if g_self.isjingong then
          BubbleSort(saveKong, "tick", 2)
          if #saveKong > 0 and GetTickCount() - saveKong[1].tick < 6000 then
            local tempPos = GetAveragePoint(tBoss.x, tBoss.y, 1, 360)
            tempPos = GetAllPosDist(tempPos, saveKong[1], "dst")
            BubbleByDst(tempPos, 2)
            bTrapSafe = FastRun(tempPos[1], 4)
          end
        else
          bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
        end
      end
    end
    if bAttack then
      GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    end
    Sleep(100)
    DebugStr("丐帮守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_TM_GetCYSafePos(aZero, aCanYing, aKongNpc, aDiffAngle)
  local safePos = {}
  local allPos = GetRangeAllPos(aZero.x, aZero.y, 1, 15, nil)
  for i = 1, #aCanYing do
    local temp = {}
    for j = 1, #aKongNpc do
      local unAngle = GetAngle(aCanYing[i].x, aCanYing[i].y, aKongNpc[j].x, aKongNpc[j].y)
      local field = math.floor(unAngle + 0.5)
      temp[field] = unAngle
    end
    aCanYing[i].unsafe = temp
  end
  for j = 1, #allPos do
    local bSafe = true
    local thisPos = allPos[j]
    for i = 1, #aCanYing do
      local tmpcy = aCanYing[i]
      local unsafeAG = tmpcy.unsafe
      local angleThis = GetAngle(tmpcy.x, tmpcy.y, thisPos.x, thisPos.y)
      local thisSafe = true
      for k, v in pairs(unsafeAG) do
        local diffAngle = math.abs(angleThis - v)
        if diffAngle > 335 then
          diffAngle = 360 - diffAngle
        end
        if aDiffAngle >= diffAngle then
          thisSafe = false
          break
        end
      end
      if false == thisSafe then
        bSafe = false
        break
      end
    end
    if bSafe then
      table.insert(safePos, allPos[j])
    end
  end
  return safePos
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
  npc.name = "唐简"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  local trapName = ""
  Player:GetName()
  CDG.call.back1 = GSH_tm_cb
  local saveKong = {}
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
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
      for i = 4, 1, -1 do
        tSafePos = GSH_TM_GetCYSafePos(npc, tCanYing, tKong, i)
        if #tSafePos > 0 then
          break
        end
      end
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

local function GSH_em_cb()
  if IsInDebugMsgTime("#{BSJN_200327_36}", false, 30) then
    return false
  end
  if IsInDebugMsgTime("BSJN_200327_30", false, 4) then
    return false
  end
  if IsInDebugMsgTime("BSJN_200327_32", false, 3) then
    return false
  end
  return true
end

local function GSH_EMei()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 6)
  if not myPos then
    return
  end
  npc.name = "崔璎"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  Player:GetName()
  CDG.call.back1 = GSH_em_cb
  local em_yxjx = CDG.hp.em_yxjx
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 玩家", {0, -1})
    local tPlayer = ObjFilterByStrClass(tAll, "玩家", 0)
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe = true
    local bHasTrap = false
    if IsInDebugMsgTime("#{BSJN_200327_36}", false, 30) then
      CDG.hp.em_yxjx = false
      debugnote = " 集火秒boss"
    else
      CDG.hp.em_yxjx = em_yxjx
      local _, strMsg = IsInDebugMsgTime("BSJN_200327_30", false, 5)
      local _, _, findName = string.find(strMsg, "*.-*.(.+)}")
      if "string" == type(findName) and "" ~= findName then
        bHasTrap = true
        local tTrap = {}
        local safeDist = 5
        if g_self.name == findName then
          tTrap = DeleteTableFieldValue(tPlayer, "name", {
            g_self.name
          })
          if #tTrap > 0 then
            bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
          end
        else
          tTrap = GetTableFieldValue(tPlayer, "name", {findName})
          if #tTrap > 0 then
            if g_self.isjingong then
              bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe, nil, nil, npc)
            else
              bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
            end
          end
        end
      end
      if IsInDebugMsgTime("#{BSJN_200327_32}", false, 4) then
        local safeDist = 5
        if -1 ~= Player:GetBuff("花心印：") then
          local tTrap = DeleteTableFieldValue(tPlayer, "name", {
            g_self.name
          })
          if #tTrap > 0 then
            bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
          end
        else
          local tTrap = GetHasBuffObj(tPlayer, "花心印：", false)
          if #tTrap > 0 then
            bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
          end
        end
      end
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("峨嵋守关 " .. debugnote)
  end
  CDG.call.back1 = nil
  CDG.hp.em_yxjx = em_yxjx
end

local function GSH_xx_cb()
  local tAll = Enum2XByClass("怪物", {0, -1})
  local tZhiZ = ObjFilterByName(tAll, "蜘蛛", 0)
  if #tZhiZ > 0 then
    return false
  end
  return true
end

local function GSH_XingXiu()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 6)
  if not myPos then
    return
  end
  npc.name = "夜来"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  CDG.call.back1 = GSH_xx_cb
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物", {0, -1})
    local tNPC = ObjFilterByName(tAll, "地面蜘蛛网", 4)
    local tXianJin = ObjFilterByName(tAll, "地面蜘蛛网", 0)
    local tZZW = ObjFilterByName(tAll, "蜘蛛网", 0)
    local tZhiZ = ObjFilterByName(tAll, "蜘蛛", 0)
    local myTid = Player:GetTID()
    for i = 1, #tZhiZ do
      local tmp = tZhiZ[i]
      if tmp.target == myTid then
        table.insert(tXianJin, tmp)
      end
    end
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe, bHasTrap = true, false
    if #tXianJin > 0 then
      bHasTrap = true
      if g_self.isjingong then
        bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, 4, npc.r, tXianJin, nil, FubenRunSafe, nil, nil, npc)
      else
        npc.sort_zero = true
        bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, 4, npc.r, tXianJin, nil, FubenRunSafe_fangshe, nil, nil, npc)
      end
    end
    if #tZhiZ > 0 then
      if g_self.isjingong == false or false == bHasTrap then
        tNPC = tZhiZ
      end
    elseif #tZZW > 0 then
      tNPC = tZZW
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap, tXianJin)
    Sleep(100)
    DebugStr("星宿守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_WD_GetYY()
  local strText = [[
        local yyz = 0
        setmetatable(_G, {__index = WuLin_YinYang_Env})
        if this:IsVisible() then
            local pwidth, pheight = WuLin_YinYang_BK:GetWindowSize()
            local swidth, sheight = WuLin_YinYang_Point:GetWindowSize()
            local g_WuLin_YinYang_Offsetx = pwidth / 2 - swidth / 2
            local g_WuLin_YinYang_Offsety = pheight / 2 - sheight / 2
            local g_WuLin_YinYang_Long = 61
            local posstr = WuLin_YinYang_Point:GetProperty("UnifiedPosition")
            local _, _, _, posX, _, posY = string.find(posstr, "(%-?%d+%.*%d*).-(%-?%d+%.*%d*).-(%-?%d+%.*%d*).-(%-?%d+%.*%d*)")
            local nNewPosX = tonumber(posX) or 61
            local nNewPosY = tonumber(posY) or 0
            if nNewPosX >= g_WuLin_YinYang_Offsetx then
                yyz = (nNewPosX - g_WuLin_YinYang_Offsetx) / g_WuLin_YinYang_Long
                yyz = math.asin(yyz) * 200 / math.pi
            else
                yyz = (g_WuLin_YinYang_Offsetx - nNewPosX) / g_WuLin_YinYang_Long
                yyz = math.asin(yyz) * 200 / math.pi
                if yyz > 0 then
                    yyz = yyz * -1
                end
            end
        end
        return yyz
    ]]
  local yyz = GetLuaValue(strText, "n")
  DebugStr("阴阳值：" .. yyz, 2)
  return yyz
end

local function GSH_WD_BaiHeiRun(aZero, aSafeQuYu)
  local bIsSafe = false
  local myPos = Player:GetPos()
  if aZero.x == myPos.x and aZero.y == myPos.y then
    bIsSafe = false
  else
    local myAngle = GetAngle(aZero.x, aZero.y, myPos.x, myPos.y)
    bIsSafe = false
    for i = 1, #aSafeQuYu do
      local tmp = aSafeQuYu[i]
      local diffAngle = math.abs(tmp.angle - myAngle)
      if diffAngle > 335 then
        diffAngle = 360 - diffAngle
      end
      if diffAngle < 15 then
        bIsSafe = true
        break
      end
    end
  end
  if false == bIsSafe and #aSafeQuYu > 0 then
    aSafeQuYu = GetAllPosDist(aSafeQuYu, myPos)
    BubbleByDst(aSafeQuYu)
    FastRun(aSafeQuYu[1], 4)
    RunTo(aSafeQuYu[1].x, aSafeQuYu[1].y, 0, 300)
    PlayerStateTimeOut(2, 2)
  end
  return bIsSafe
end

local function GSH_wd_cb()
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tYang = ObjFilterByName(tAll, "武当白npc", 0)
  local tYin = ObjFilterByName(tAll, "武当黑npc", 0)
  if #tYang > 4 or #tYin > 4 then
    return false
  end
  return true
end

local function GSH_WuDang()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 4)
  if not myPos then
    return
  end
  npc.name = "傅致远"
  npc.xSelf = npc.x
  npc.ySelf = npc.y
  local tBaiSafe = {}
  local tHeiSafe = {}
  CDG.call.back1 = GSH_wd_cb
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tYang = ObjFilterByName(tAll, "武当白npc", 0)
    local tYin = ObjFilterByName(tAll, "武当黑npc", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    if 0 == #tBaiSafe and 4 == #tYang then
      for i = 1, #tYang do
        local tmp = tYang[i]
        local angle = GetAngle(npc.x, npc.y, tmp.x, tmp.y)
        local baipos = GetAnglePos(npc, angle, 3)
        table.insert(tBaiSafe, baipos)
      end
    end
    if 0 == #tHeiSafe and 4 == #tYin then
      for i = 1, #tYin do
        local tmp = tYin[i]
        local angle = GetAngle(npc.x, npc.y, tmp.x, tmp.y)
        local heipos = GetAnglePos(npc, angle, 3)
        table.insert(tHeiSafe, heipos)
      end
    end
    local bTrapSafe, bHasTrap = true, false
    local bRunWhere = 0
    if #tYang > 4 then
      bRunWhere = 1
      bHasTrap = true
    elseif #tYin > 4 then
      bRunWhere = 2
      bHasTrap = true
    end
    if false == bHasTrap then
      local yyz = GSH_WD_GetYY()
      if g_self.isjingong then
        if yyz < -5 then
          bRunWhere = 1
        elseif yyz > 5 then
          bRunWhere = 2
        end
      elseif yyz < -3 then
        bRunWhere = 1
      elseif yyz > 3 then
        bRunWhere = 2
      end
    end
    if 1 == bRunWhere then
      bTrapSafe = GSH_WD_BaiHeiRun(npc, tBaiSafe)
    elseif 2 == bRunWhere then
      bTrapSafe = GSH_WD_BaiHeiRun(npc, tHeiSafe)
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("武当守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_THD_GetNPCObj(aObj)
  local tCfy = ObjFilterByName(aObj, "朝覆雨", 0)
  local tLre = ObjFilterByName(aObj, "离人偶", 0)
  return tCfy, tLre
end

local function GSH_THD_IsTarget(aObj)
  local tCfy, tLre = GSH_THD_GetNPCObj(aObj)
  if #tCfy > 0 and #tLre > 0 then
    local myTID = Player:GetTID()
    if myTID == tCfy[1].target then
      return true, tCfy[1]
    elseif myTID == tLre[1].target then
      return true, tLre[1]
    end
  end
  return false
end

local function GSH_THD_GetNPCDist(aObj)
  local tCfy, tLre = GSH_THD_GetNPCObj(aObj)
  if #tCfy > 0 and #tLre > 0 then
    return GetDist(tCfy[1].x, tCfy[1].y, tLre[1].x, tLre[1].y)
  end
  return -1
end

local function GSH_THD_GetNPCHPDiff(aObj)
  local tCfy, tLre = GSH_THD_GetNPCObj(aObj)
  if #tCfy > 0 and #tLre > 0 then
    local hp_diff = math.abs(tCfy[1].hp - tLre[1].hp)
    local hpMore = "离人偶"
    if tCfy[1].hp > tLre[1].hp then
      hpMore = "朝覆雨"
    end
    return hp_diff, hpMore
  end
  return 0, ""
end

local function GSH_THD_CheckDist(aObj, aNPC)
  local bMove = false
  local dist = GSH_THD_GetNPCDist(aObj)
  if -1 ~= dist then
    local bIsTarget, tar = GSH_THD_IsTarget(aObj)
    if dist < 11 then
      if bIsTarget or -1 ~= Player:GetBuff(aNPC.buff) then
        local pos = Player:GetPos()
        local xRun = pos.x + aNPC.z * 2
        PushDebugMessage("NPC距离太近")
        RunTo(xRun, aNPC.y, 0, 500)
        PlayerStateTimeOut(2, 2)
        bMove = true
      end
    elseif dist > 14 and (bIsTarget or -1 ~= Player:GetBuff(aNPC.buff)) then
      PushDebugMessage("NPC距离太远")
      local tAll = Enum2XByClass("怪物 NPC", {0, -1})
      local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
      local tTrap = ObjFilterByName(tAll, "桃花岛陷阱npc", 0)
      local runY = aNPC.y
      local pos = Player:GetPos()
      if #tTrap > 0 then
        if IsPosSafe(aNPC, tTrap, 4) == false then
          local tBro = ObjFilterByName(tNPC, aNPC.brother, 0)
          if #tBro > 0 then
            runY = tBro[1].y
          end
        else
          runY = pos.y
        end
      end
      if pos.x > aNPC.xzero then
        RunTo(pos.x - 1, runY, 0, 500)
      elseif pos.x < aNPC.xzero then
        if dist > 15 then
          RunTo(pos.x + 1, runY, 0, 500)
        else
          RunTo(aNPC.x, runY, 0, 500)
        end
      else
        RunTo(aNPC.x + aNPC.z * 1, runY, 0, 500)
      end
      PlayerStateTimeOut(2, 2)
      bMove = true
    end
  end
  return bMove
end

local function GSH_thd_cb()
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
  local tTrap = ObjFilterByName(tAll, "桃花岛陷阱npc", 0)
  if #tTrap > 0 and 4 ~= g_self.menpai then
    return false
  end
  return true
end

local function GSH_TaoHuaDao()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local posZhanDou = {
    {
      x = npc.x - 5,
      y = npc.y,
      xzero = npc.x,
      z = -1,
      name = "朝覆雨",
      brother = "离人偶",
      buff = "追击目标：被朝覆雨持续追击"
    },
    {
      x = npc.x + 6,
      y = npc.y,
      xzero = npc.x,
      z = 1,
      name = "离人偶",
      brother = "朝覆雨",
      buff = "追击目标：被离人偶持续追击"
    }
  }
  local teamIndex = Team:GetMyIndex()
  local posNPC = posZhanDou[1]
  if 1 == teamIndex or 3 == teamIndex or 5 == teamIndex then
    posNPC = posZhanDou[2]
    PushDebugMessage("桃花岛守关:2、4、6打离人偶")
  else
    PushDebugMessage("桃花岛守关:1、3、5打朝覆雨")
  end
  CDG.call.back1 = GSH_thd_cb
  if -1 ~= Player:GetBuff("追击目标：被朝覆雨持续追击") then
    posNPC = posZhanDou[1]
    RunTo(posZhanDou[1].x, posZhanDou[1].y, 0, 600)
    PlayerStateTimeOut(2, 3)
  elseif -1 ~= Player:GetBuff("追击目标：被离人偶持续追击") then
    posNPC = posZhanDou[2]
    RunTo(posZhanDou[2].x, posZhanDou[2].y, 0, 600)
    PlayerStateTimeOut(2, 3)
  else
    RunTo(npc.x, npc.y, 0, 300)
  end
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local bIsTarget = false
    if -1 ~= Player:GetBuff("追击目标：被朝覆雨持续追击") then
      bIsTarget = true
      posNPC = posZhanDou[1]
    elseif -1 ~= Player:GetBuff("追击目标：被离人偶持续追击") then
      bIsTarget = true
      posNPC = posZhanDou[2]
    end
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tTrap = ObjFilterByName(tAll, "桃花岛陷阱npc", 0)
    local tBoss_cfy = GSH_GetAttackNPC(tNPC, posZhanDou[1])
    local tBoss_lre = GSH_GetAttackNPC(tNPC, posZhanDou[2])
    if nil == tBoss_cfy and nil == tBoss_lre then
      PushDebugMessage("未找到桃花岛boss")
      break
    end
    local hpdiff, moreName = GSH_THD_GetNPCHPDiff(tNPC)
    local bMove = GSH_THD_CheckDist(tNPC, posNPC)
    local bTrapSafe, bHasTrap = true, false
    local bAttack = true
    if #tTrap > 0 then
      bHasTrap = true
      if false == bMove then
        local bIsTar, tar = GSH_THD_IsTarget(tNPC)
        if bIsTar or -1 ~= Player:GetBuff("追击目标：") then
          local defPos1 = {
            x = posNPC.x,
            y = posNPC.y + 5
          }
          local defPos2 = {
            x = posNPC.x,
            y = posNPC.y - 5
          }
          local myPos = Player:GetPos()
          defPos1.dst = GetDist(defPos1.x, defPos1.y, myPos.x, myPos.y)
          defPos2.dst = GetDist(defPos2.x, defPos2.y, myPos.x, myPos.y)
          local safeDist = 4
          if false == IsPosSafe(myPos, tTrap, safeDist) then
            bTrapSafe = false
            if IsPosSafe(defPos1, tTrap, safeDist) then
              FastRun(defPos1, 4)
            else
              FastRun(defPos2, 4)
            end
          end
        elseif g_self.isjingong then
          bTrapSafe = FubenTrapRun(posNPC.name, npc.x, npc.y, 5, npc.r, tTrap, nil, FubenRunSafe, nil, nil)
        else
          bTrapSafe = FubenTrapRun("", npc.x, npc.y, 5, npc.r, tTrap, nil, FubenRunSafe, nil, nil)
        end
      end
    end
    if false == bMove and false == bHasTrap and bIsTarget and tBoss_cfy and tBoss_lre then
      bAttack = not RunTo(posNPC.x, posNPC.y, 0, 600)
      PlayerStateTimeOut(2, 5)
    end
    local tFitle = tNPC
    local jgFar = false
    if g_self.isjingong then
      if bMove or bIsTarget or bHasTrap then
        tFitle = ObjFilterByDst(tNPC, 3, 2)
      end
      local tmp = GSH_GetAttackNPC(tNPC, posNPC)
      if tmp and tmp.target == Player:GetTID() then
        tFitle = ObjFilterByDst(tNPC, 3, 2)
      end
    else
      if bMove or bIsTarget or bHasTrap then
        tFitle = ObjFilterByDst(tNPC, 15, 2)
      end
      local tmp = GSH_GetAttackNPC(tNPC, posNPC)
      if tmp and tmp.target == Player:GetTID() then
        tFitle = ObjFilterByDst(tNPC, 15, 2)
      end
    end
    local tid, attackNPC, attackTab = GSH_GetAttackTID(tFitle, posNPC, false)
    if -1 == tid then
      tid, attackNPC, attackTab = GSH_GetAttackTID(tNPC, posNPC, false)
      if -1 ~= tid then
        jgFar = true
      else
        local nextnpc = {
          name = posNPC.brother
        }
        tid, attackNPC, attackTab = GSH_GetAttackTID(tFitle, nextnpc, false)
        if -1 == tid then
          tid, attackNPC, attackTab = GSH_GetAttackTID(tNPC, nextnpc, false)
          if -1 ~= tid then
            jgFar = true
          end
        end
      end
    end
    local bUseJinJi = false
    local hpcmp = 5
    if g_self.isjingong then
      hpcmp = 10
    end
    if attackNPC and hpdiff > hpcmp then
      if moreName ~= posNPC.name then
        debugnote = posNPC.name .. "攻击血高的"
        local isStop = true
        local tPlayer = Enum2XByClass("玩家", {0, -1})
        local buff = "追击目标：被" .. moreName .. "持续追击"
        local bCanAttackBrother = false
        for i = 1, #tPlayer do
          if Target:FindBuff(tPlayer[i], buff) then
            bCanAttackBrother = true
            break
          end
        end
        if bCanAttackBrother then
          local bro = {name = moreName}
          local tmp = GSH_GetAttackNPC(tNPC, bro)
          if tmp and tmp.dst <= 15 then
            isStop = false
            if g_self.isjingong then
              if not bIsTarget then
                jgFar = true
                tid = tmp.id
              end
            else
              tid = tmp.id
            end
          end
        end
      else
        bUseJinJi = true
      end
    end
    if false == bTrapSafe then
      tid = -1
    end
    if -1 ~= tid and jgFar then
      DebugStr("周围陷阱,近攻暂时不过去", 2)
      JinGongFarSkill(tid, true)
      if false == bMove or -1 == Player:GetBuff("追击目标：") then
        local tmp = GSH_GetAttackNPC(tNPC, posNPC)
        if tmp and IsPosSafe(tmp, tTrap, 4) then
          RunTo(tmp.x, tmp.y, 0, 200)
        end
      end
    else
      if nil == tBoss_lre or nil == tBoss_cfy then
        bUseJinJi = true
      else
        local msHp = m_param.bosshp
        if msHp >= tBoss_lre.hp or msHp >= tBoss_cfy.hp then
          if tBoss_lre.hp < tBoss_cfy.hp then
            if tBoss_cfy.id == tid then
              bUseJinJi = true
              DebugStr("Boss血量低于%d%%,甩技能", 2, msHp)
            end
          elseif tBoss_lre.hp > tBoss_cfy.hp then
            if tBoss_lre.id == tid then
              bUseJinJi = true
              DebugStr("Boss血量低于%d%%,甩技能", 2, msHp)
            end
          else
            bUseJinJi = true
            DebugStr("Boss血量低于%d%%,甩技能", 2, msHp)
          end
        end
      end
      GSH_UseKongZhi({}, attackNPC, attackTab)
      FubenAttack(tid, nil, bUseJinJi)
      RelivePlayerJZDJ()
    end
    Sleep(100)
    DebugStr("桃花岛守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_TL_HPMP()
  local HpToMp = [[
        setmetatable(_G, {__index = WuLin_TL_Env})
        if this:IsVisible() then
            if WuLin_TL_Btn2:GetProperty("Disabled") == "False" then
                Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("RefixHpMp")
                    Set_XSCRIPT_ScriptID(888011)
                    Set_XSCRIPT_Parameter(0, 0)
                    Set_XSCRIPT_ParamCount(1)
                Send_XSCRIPT()
                return 1
            end
        end
        return 0
    ]]
  local MpToHp = [[
            setmetatable(_G, {__index = WuLin_TL_Env})
            if this:IsVisible() then
                if WuLin_TL_Btn1:GetProperty("Disabled") == "False" then            
                    Clear_XSCRIPT()
                        Set_XSCRIPT_Function_Name( "RefixHpMp" )
                        Set_XSCRIPT_ScriptID(888011) 
                        Set_XSCRIPT_Parameter(0,1) 			
                        Set_XSCRIPT_ParamCount(1)
                    Send_XSCRIPT()
                    return 1
                end
            end
            return 0
        ]]
  local mpcur = Player:GetMP()
  local hpp = Player:GetHPP()
  if mpcur < 3000 then
    local hpcmp = 17
    if 4 == g_self.menpai then
      hpcmp = 6
    end
    if hpp > hpcmp then
      PushDebugMessage("血换蓝")
      if GetLuaValue(HpToMp, "b") then
        Sleep(500)
      end
    end
  elseif hpp < 20 and 4 ~= g_self.menpai then
    local mpp = Player:GetMPP()
    if mpp > 5 then
      PushDebugMessage("蓝换血")
      if GetLuaValue(MpToHp, "b") then
        Sleep(500)
      end
    end
  end
end

local function GSH_tl_cb()
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tXianJin = ObjFilterByName(tAll, "陷阱npc", 0)
  if #tXianJin > 0 then
    return false
  end
  return true
end

local function GSH_TianLong()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "段思安"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  Player:IsJinGong()
  local hpcmp_old = CDG.hp.cmp
  if 4 == g_self.menpai then
    CDG.hp.cmp = 90
  end
  CDG.call.back1 = GSH_tl_cb
  CDG.skill_attack_jinji_disable = " 暗器投掷 暗器连击 暗器打穴 暗器护体 诛仙万象 "
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tXianJin = ObjFilterByName(tAll, "陷阱npc", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe, bHasTrap = true, false
    if #tXianJin > 0 then
      bHasTrap = true
      npc.useqg = false
      bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, 5, npc.r, tXianJin, nil, FubenRunSafe, nil, nil, npc)
    end
    GSH_TL_HPMP()
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("天龙守关 " .. debugnote)
  end
  if 4 == g_self.menpai then
    CDG.hp.cmp = hpcmp_old
  end
  CDG.call.back1 = nil
  CDG.skill_attack_jinji_disable = ""
end

local function GSH_ts_cb()
  if IsInDebugMsgTime("#{BSJN_200327_107}", false, 4) then
    return false
  end
  return true
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
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
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

local function GSH_XY_TWQP(aAQQ)
  local bHas = false
  local bSafe = true
  
  local function _RunAnQuanQu(aAQQPos)
    if #aAQQPos > 0 then
      BubbleByDst(aAQQPos)
      FastRun(aAQQPos[1], 3)
      if GetDist(aAQQPos[1].x, aAQQPos[1].y) < 3 then
        return true
      end
    end
    return false
  end
  
  if IsInDebugMsgTime("#{BSJN_200327_129}", false, 5) then
    bHas = true
    if #aAQQ > 0 then
      bSafe = _RunAnQuanQu(aAQQ)
      return bHas, bSafe
    end
    local tPlayer = Enum2XByClass("玩家", {0, -1})
    for i = 1, #tPlayer do
      tPlayer[i].baizi = 0
      local tStr = EnumObjBuff(tPlayer[i])
      for j = 1, #tStr do
        local _, _, nHas = string.find(tStr[j], "(%d)颗白子：受到伤害减少")
        if nHas then
          tPlayer[i].baizi = tonumber(nHas)
          tPlayer[i].baizi = tPlayer[i].baizi or 0
          break
        end
      end
    end
    local tMember = Team:GetAllMemberInfo()
    for i = 1, #tMember do
      tMember[i].baizi = 0
      for j = 1, #tPlayer do
        if tMember[i].name == tPlayer[j].name then
          tMember[i].baizi = tPlayer[j].baizi
          tMember[i].x = tPlayer[j].x
          tMember[i].y = tPlayer[j].y
          break
        end
      end
    end
    BubbleSort(tMember, "baizi", 2)
    local mostBZ = -1
    if #tMember > 0 then
      mostBZ = tMember[1].baizi
    end
    if mostBZ > 0 then
      BubbleSort(tMember, "teamIndex", 1)
      for i = 1, #tMember do
        local tmp = tMember[i]
        if tmp.baizi == mostBZ then
          PushDebugMessage("天为棋盘: 本次由 %s 释放白子", tmp.name)
          if tmp.name == g_self.name then
            do
              local strText = [[
                            setmetatable(_G, {__index = WuLin_XY_Env})
                            if this:IsVisible() then
                                WuLin_XY_Click()
                            end       
                        ]]
              GetLuaValue(strText)
              Sleep(300)
            end
            break
          end
          do
            local tObj = Enum2XByName("白字", {
              1,
              0,
              0,
              0
            }, nil, 1, 0)
            if #tObj > 0 then
              do
                local pos = tObj[1]
                RunTo(pos.x, pos.y, 0, 500)
              end
              break
            end
            RunTo(tmp.x, tmp.y, 0, 500)
            if i < #tMember and tMember[i + 1].name == g_self.name then
              Sleep(600)
              break
            end
            if i == #tMember and tMember[1].name == g_self.name then
              Sleep(600)
            end
          end
          break
        end
      end
    else
      PushDebugMessage("队伍已经没有白子可释放")
    end
  end
  return bHas, bSafe
end

local function GSH_xy_cb()
  if not m_param.notxypw and IsInDebugMsgTime("#{BSJN_200327_131}", false, 4) then
    return false
  end
  if IsInDebugMsgTime("#{BSJN_200327_129}", false, 4) then
    return false
  end
  return true
end

local function GSH_XiaoYao()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  npc.name = "原微之"
  if not m_param.notxypw then
    local zwOk, myPos = TeamDispersedStations(npc, 5)
    if not myPos then
      return
    end
    npc.xSelf = myPos.x
    npc.ySelf = myPos.y
  else
    RunTo(npc.x, npc.y, 0, 200)
    npc.xSelf = npc.x
    npc.ySelf = npc.y
  end
  CDG.call.back1 = GSH_xy_cb
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tXianJin = ObjFilterByName(tAll, "黑子", 0)
    local tAQQ = ObjFilterByName(tAll, "白字", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bTrapSafe, bHasTrap = true, false
    if not m_param.notxypw and IsInDebugMsgTime("#{BSJN_200327_131}", false, 5) and #tXianJin > 0 then
      bHasTrap = true
      bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, 4, npc.r, tXianJin, nil, FubenRunSafe, nil, nil, npc)
    end
    local bHasDaQun, bDaQunSafe = GSH_XY_TWQP(tAQQ)
    if bHasDaQun then
      bHasTrap = true
    end
    if false == bDaQunSafe then
      bTrapSafe = false
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("逍遥守关 " .. debugnote)
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
  npc.name = "慕容信"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  CDG.call.back1 = GSH_mr_cb
  CDG.call.CanJiaXue = GSH_MR_cb_jiaxue
  CDG.skill_attack_jinji_disable = " 聚星阵·长生 情尽盈血 "
  local saveKong = {}
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
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

local function GSH_SL_GetCeng(aNPC)
  if not aNPC then
    return 0, 0
  end
  local strKH = ""
  local strJZZ = ""
  local tStr = EnumObjBuff(aNPC)
  for i = 1, #tStr do
    if string.find(tStr[i], "狂慧：伤害加成", nil, true) then
      strKH = tStr[i]
    elseif string.find(tStr[i], "金钟罩：所受伤害减免", nil, true) then
      strJZZ = tStr[i]
    end
  end
  local _, _, kh = string.find(strKH, "(%d+)%%")
  local _, _, jzz = string.find(strJZZ, "(%d+)%%")
  kh = tonumber(kh) or 0
  jzz = tonumber(jzz) or 0
  kh = kh or 0
  jzz = jzz or 0
  if kh > 0 then
    kh = kh / 20
  end
  if jzz > 0 then
    jzz = jzz / 10
  end
  return kh, jzz
end

local function GSH_SL_QMY(aMuYu)
  local function _QMY(_MuYu)
    BubbleByDst(_MuYu)
    
    local tmp = _MuYu[1]
    FastRun(tmp, 4)
    Skill.CUseSkillByID(3943, tmp.id, -1, -1)
    Sleep(500)
    PlayerStateTimeOut(5, 6)
  end
  
  if 0 == m_param.sqmy.sel then
    local tPlayer = Team:GetHPLeastMember(true)
    if tPlayer and tPlayer.name == g_self.name then
      PushColorMsg("队内本人血最低,前去敲木鱼")
      _QMY(aMuYu)
    else
      DebugStr("等待队内血最低者前去敲木鱼", 2)
    end
    return true
  elseif 1 == m_param.sqmy.sel then
    PushColorMsg("已设置本人前去敲木鱼")
    _QMY(aMuYu)
    return true
  end
  return false
end

local function GSH_sl_cb()
  if IsInDebugMsgTime("#{BSJN_200327_95}", false, 4) then
    return false
  end
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tKH = ObjFilterByName(tAll, "红木木鱼", 0)
  local tJZZ = ObjFilterByName(tAll, "鎏金木鱼", 0)
  local tWuZhi = ObjFilterByName(tAll, "无执", 0)
  if #tWuZhi > 0 then
    local nKH, nJZZ = GSH_SL_GetCeng(tWuZhi[1])
    if #tKH > 0 and nKH >= m_param.kh then
      GSH_SL_QMY(tKH)
    elseif #tJZZ > 0 and nJZZ >= m_param.jzz then
      GSH_SL_QMY(tJZZ)
    end
  end
  return true
end

local function GSH_ShaoLin()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "无执"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  Player:GetName()
  CDG.call.back1 = GSH_sl_cb
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tNPC = ObjFilterByStrClass(tAll, "怪物", 0)
    local tKH = ObjFilterByName(tAll, "红木木鱼", 0)
    local tJZZ = ObjFilterByName(tAll, "鎏金木鱼", 0)
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bQMY = false
    local nKH, nJZZ = GSH_SL_GetCeng(tBoss)
    if #tKH > 0 and nKH >= m_param.kh then
      bQMY = GSH_SL_QMY(tKH)
    elseif #tJZZ > 0 and nJZZ >= m_param.jzz then
      bQMY = GSH_SL_QMY(tJZZ)
    end
    local bHasTrap, bTrapSafe = false, true
    if tBoss and false == bQMY and IsInDebugMsgTime("#{BSJN_200327_95}", false, 7) then
      bHasTrap = true
      local tTrap = {}
      table.insert(tTrap, tBoss)
      local defPos = {
        x = npc.xSelf,
        y = npc.ySelf
      }
      local myPos = Player:GetPos()
      defPos.dst = GetDist(defPos.x, defPos.y, myPos.x, myPos.y)
      local safeDist = 6
      if false == IsPosSafe(myPos, tTrap, safeDist) then
        bTrapSafe = false
        if IsPosSafe(defPos, tTrap, safeDist) then
          FastRun(defPos, 4)
        else
          FubenTrapRun(npc.name, npc.x, npc.y, safeDist, npc.r, tTrap, nil, FubenRunSafe_fangshe, nil, nil, npc)
        end
      end
    end
    if bQMY then
      bTrapSafe = false
    end
    GSH_Attack(tNPC, bTrapSafe, bHasTrap)
    Sleep(100)
    DebugStr("少林守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_GG_FangXiang()
  local bJieJiu = false
  local bSafe = true
  if -1 ~= Player:GetBuff("方相缠身：") then
    bSafe = false
  else
    local tObj = Enum2XByClass("怪物 玩家", {0, -1})
    local tGuai = ObjFilterByStrClass(tObj, "怪物")
    local tFX = ObjFilterByName(tGuai, "方相", 0)
    local tWanJia = ObjFilterByStrClass(tObj, "玩家")
    local tHelpPlayer = {}
    local tSafePlayer = {}
    for i = 1, #tWanJia do
      local tmp = tWanJia[i]
      local tStr = EnumObjBuff(tmp)
      local bSafeP = true
      for j = 1, #tStr do
        if string.find(tStr[j], "方相缠身：", nil, true) then
          bSafeP = false
          table.insert(tHelpPlayer, tmp)
          break
        end
      end
      if bSafeP then
        table.insert(tSafePlayer, tmp)
      end
    end
    local selfTid = Player:GetTID()
    for i = 1, #tFX do
      local tmp = tFX[i]
      tSafePlayer = GetAllPosDist(tSafePlayer, tmp)
      BubbleByDst(tSafePlayer)
      if #tSafePlayer > 0 and tSafePlayer[1].id == selfTid then
        PushColorMsg("距离被困队员最近,前去解救")
        bJieJiu = true
        tmp.dst = GetDist(tmp.x, tmp.y)
        FastRun(tmp, 4)
        Skill.CUseSkillByID(3960, tmp.id, -1, -1)
        PlayerStateTimeOut(5, 6)
        break
      end
    end
  end
  return bJieJiu, bSafe
end

local function GSH_gg_cb()
  local tAll = Enum2XByClass("怪物 NPC", {0, -1})
  local tXianJin = ObjFilterByName(tAll, "抓人预警npc 鬼面刷新预警npc 鬼面重置预警npc 陷阱npc", 3)
  if #tXianJin > 0 then
    return false
  end
  return true
end

local function GSH_GuiGu()
  local npc = GSH_SceneZeroPos()
  if not npc then
    return
  end
  local zwOk, myPos = TeamDispersedStations(npc, 5)
  if not myPos then
    return
  end
  npc.name = "苏延清"
  npc.xSelf = myPos.x
  npc.ySelf = myPos.y
  CDG.call.back1 = GSH_gg_cb
  while IsGuanShanHaiScene() and 9 ~= Player:GetState() do
    local debugnote = ""
    local tAll = Enum2XByClass("怪物 NPC", {0, -1})
    local tXianJinAll = ObjFilterByName(tAll, "抓人预警npc 鬼面刷新预警npc 鬼面重置预警npc 陷阱npc 方良", 3)
    local tFangl = ObjFilterByName(tAll, "方良", 3)
    local tXianJin = ObjFilterByName(tAll, "抓人预警npc 鬼面刷新预警npc 鬼面重置预警npc 陷阱npc", 3)
    local tGuai = ObjFilterByStrClass(tAll, "怪物", 0)
    local tNPC = DeleteTableFieldValue(tGuai, "name", {"方良"})
    local tBoss = GSH_GetAttackNPC(tNPC, npc)
    if nil == tBoss then
      PushDebugMessage("未找到boss" .. npc.name)
      break
    end
    local bJieJiu, bFxSafe = GSH_GG_FangXiang()
    local bTrapSafe = true
    local bHasTrap = false
    if #tXianJin > 0 then
      bHasTrap = true
    end
    if false == bJieJiu and bFxSafe then
      if #tXianJin > 0 or false == g_self.isjingong and #tXianJinAll > 0 then
        npc.useqg = false
        if 4 == g_self.menpai then
          npc.zerodist = true
          bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, 4, npc.r, tXianJinAll, nil, FubenRunSafe_Sort, nil, nil, npc)
        else
          bTrapSafe = FubenTrapRun(npc.name, npc.x, npc.y, 4, npc.r, tXianJinAll, nil, FubenRunSafe, nil, nil, npc)
        end
      elseif #tFangl > 0 and g_self.isjingong then
        local tmpid, attackNPC, attackTab = GSH_GetAttackTID(tNPC, nil, nil)
        if #attackTab > 0 then
          BubbleByDst(attackTab)
          local allPos = GetRangeAllPos(attackTab[1].x, attackTab[1].y, 1, 2, nil)
          table.insert(allPos, attackTab[1])
          allPos = GetAllPosDist(allPos, nil)
          for i = 1, #allPos do
            if IsPosSafe(allPos[i], tFangl, 4) then
              FastRun(allPos[i], 3)
              break
            end
          end
        end
      end
    end
    if bFxSafe then
      GSH_Attack(tNPC, bTrapSafe, bHasTrap, tXianJin)
    else
      debugnote = " 方相缠身"
    end
    Sleep(100)
    DebugStr("鬼谷守关 " .. debugnote)
  end
  CDG.call.back1 = nil
end

local function GSH_LeaveScene(aNpcName, aNpcID, aNextLeave)
  if aNpcID then
    OpenTalk(aNpcID, 800)
    PlayerStateTimeOut(2, 8)
  elseif aNpcName then
    TalkNpc(aNpcName, 800)
    PlayerStateTimeOut(2, 8)
  end
  if aNextLeave then
    PushColorMsg("进入下一层满血离开副本")
    if Player:IsLeader() then
      if IsWindowVisible("WuLin_Up") == false then
        QuestFrameOptionClicked_Item("#{PTFB_191228_217}", 1, 800)
      end
      if IsWindowVisible("WuLin_Up") then
        local minC, maxC = GSH_Up_GetNextChoice()
        GSH_Up_ClickNextCeng(minC, maxC)
      end
    else
      Sleep(8000)
    end
  end
  QuestFrameOptionClicked_Item("#{PTFB_191228_73}", 1, 800)
  QuestFrameOptionClicked_Item("#{PTFB_191228_218}", 1, 800)
  QuestFrameOptionClicked_Item("#{PTFB_191228_477}", 1, 800)
end

local function GSH_leave_asleader()
  if m_param.leave_asleader then
    local leader = Team:GetLeaderInfo()
    if leader and leader.sceneID ~= GetSceneID() then
      Sleep(3000)
      leader = Team:GetLeaderInfo()
      if leader and leader.sceneID ~= GetSceneID() then
        PushColorMsg("队长已不在副本,将自动离开副本")
        GSH_LeaveScene(nil, nil)
        return true
      end
    end
  end
  return false
end

local function GSH_IsUnAttackBoss(aNpcName)
  if m_param.un_attack_boss ~= "" and "" ~= aNpcName then
    if ("离人偶" == aNpcName or "朝覆雨" == aNpcName) and (string.find(m_param.un_attack_boss, "离人偶", nil, true) or string.find(m_param.un_attack_boss, "朝覆雨", nil, true)) then
      LogMsg(m_script_name .. ":您设置不打boss" .. aNpcName .. ",即将离开副本！")
      GSH_LeaveScene(aNpcName, nil)
      return true
    end
    if string.find(m_param.un_attack_boss, aNpcName, nil, true) then
      LogMsg(m_script_name .. ":您设置不打boss" .. aNpcName .. ",即将离开副本！")
      GSH_LeaveScene(aNpcName, nil)
      return true
    end
  end
  return false
end

local function GSH_NPCStart(aNPC, aStart_wait_tick)
  local maxTime = 90
  if -1 == aStart_wait_tick then
    aStart_wait_tick = GetTickCount()
  end
  if GSH_IsUnAttackBoss(aNPC.name) then
    return aStart_wait_tick
  end
  local bStart = false
  if GetTickCount() - aStart_wait_tick > maxTime * 1000 then
    PushColorMsg("等待已超时,队长开怪！")
    bStart = true
  end
  if not bStart then
    local bCheck, name = Team:CheckPetXueJiCD(5)
    if false == bCheck then
      DebugStr("等待峨嵋 %s 血祭冷却,暂不开怪! %d秒超时", 2, name, maxTime)
    else
      local hpp = 80
      bCheck, name = Team:CheckMemberHP(hpp)
      if false == bCheck then
        DebugStr("等待 %s 回血%d%%,暂不开怪! %d秒超时", 2, name, hpp, maxTime)
      else
        local mpp = 40
        bCheck, name = Team:CheckMemberMP(mpp)
        if false == bCheck then
          DebugStr("等待 %s 回蓝%d%%,暂不开怪! %d秒超时", 2, name, mpp, maxTime)
        else
          bStart = true
          DebugStr("观山海:队伍满足开怪条件", 2)
        end
      end
    end
  end
  local runnpc = "朝覆雨"
  local talkNPC = aNPC.name
  local bOpenNPC = false
  if aNPC.name == "朝覆雨" or aNPC.name == "离人偶" then
    local bIn, strMsg = IsInDebugMsgTime("#{BSJN_200327_50", false, 30)
    if string.find(strMsg, "离人偶", nil, true) then
      runnpc = "离人偶"
      talkNPC = "离人偶"
    elseif string.find(strMsg, "朝覆雨", nil, true) then
      runnpc = "朝覆雨"
      talkNPC = "朝覆雨"
    end
    local openJG = true
    if m_param.open_thd and 0 ~= m_param.open_thd.sel then
      openJG = false
    end
    local openCFY = {teamIndex = -1, name = "队长"}
    local openLRO = {teamIndex = -1, name = ""}
    local tAllMember = Team:GetAllMemberInfo()
    if openJG then
      local tMember = GetTableFieldValue(tAllMember, "isjingong", {true})
      BubbleSort(tMember, "hpmax", 2)
      if #tMember >= 1 then
        openCFY.teamIndex = tMember[1].teamIndex
        openCFY.name = tMember[1].name
      end
      if #tMember >= 2 then
        openLRO.teamIndex = tMember[2].teamIndex
        openLRO.name = tMember[2].name
      end
      BubbleSort(tAllMember, "hpmax", 2)
      for i = 1, #tAllMember do
        local tmp = tAllMember[i]
        if -1 == openCFY.teamIndex then
          if tmp.teamIndex ~= openLRO.teamIndex then
            openCFY.teamIndex = tmp.teamIndex
            openCFY.name = tmp.name
          end
        elseif -1 == openLRO.teamIndex then
          if tmp.teamIndex ~= openCFY.teamIndex then
            openLRO.teamIndex = tmp.teamIndex
            openLRO.name = tmp.name
          end
        else
          break
        end
      end
    else
      openCFY.teamIndex = 0
      BubbleSort(tAllMember, "hpmax", 2)
      local nCount = 0
      for i = 1, #tAllMember do
        local tmp = tAllMember[i]
        if tmp.teamIndex ~= openCFY.teamIndex then
          openLRO.teamIndex = tmp.teamIndex
          openLRO.name = tmp.name
          nCount = nCount + 1
          if nCount > 1 then
            break
          end
        end
      end
    end
    local teamIndex = Team:GetMyIndex()
    if teamIndex == openCFY.teamIndex then
      talkNPC = "朝覆雨"
      bOpenNPC = true
    elseif teamIndex == openLRO.teamIndex then
      local tObj = Enum2XByName("离人偶", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        talkNPC = "离人偶"
      else
        talkNPC = "朝覆雨"
      end
      bOpenNPC = true
    else
      PushDebugMessage("等待[%s]开朝覆雨,[%s]开离人偶", openCFY.name, openLRO.name)
    end
  else
    local openIndex = -1
    if aNPC.name == "解谊" then
      local tAllMember = Team:GetAllMemberInfo()
      BubbleSort(tAllMember, "hpmax", 2)
      for i = 1, #tAllMember do
        local tmp = tAllMember[i]
        if 4 == tmp.menpai then
          openIndex = tmp.teamIndex
          break
        end
      end
      if m_param.open_gb and 0 ~= m_param.open_gb.sel then
        openIndex = -1
      end
    end
    if -1 == openIndex and Player:IsLeader(false) or openIndex == Team:GetMyIndex() then
      bOpenNPC = true
    end
  end
  local tObj = Enum2XByName(talkNPC, {
    1,
    0,
    0,
    0
  }, {0, -1}, nil, 0)
  if #tObj > 0 then
    local tmp = tObj[1]
    if tmp.dst >= 3 then
      RunTo(tmp.x, tmp.y, 2, 1000)
      PlayerStateTimeOut(2, 3)
    end
    OpenTalk(tmp.id, 800)
  else
    TalkNpc(talkNPC, 800)
  end
  local strItem = GetNPCEventListAllItem()
  if string.find(strItem, "#{PTFB_191228_217}", nil, true) then
    local curCeng = GSH_GetCurrentCeng()
    local leaveCeng = m_param.leave_ceng_value
    if Player:IsLeader() then
      if m_param.leave_ceng then
        PushDebugMessage("当前层数%d,下一层%d", curCeng, curCeng + 1)
        if curCeng >= leaveCeng then
          PushColorMsg("队长到达指定的层数,离开副本")
          Sleep(5000)
          GSH_LeaveScene(nil, nil, true)
          return aStart_wait_tick
        end
      end
    else
      if m_param.leave_member then
        PushDebugMessage("当前层数%d,下一层%d", curCeng, curCeng + 1)
        if curCeng >= leaveCeng then
          PushColorMsg("队员到达指定的层数,离开副本")
          Sleep(5000)
          GSH_LeaveScene(nil, nil, true)
          return aStart_wait_tick
        end
      end
      if GSH_leave_asleader() then
        return aStart_wait_tick
      end
    end
    if false == IsWindowVisible("WuLin_Up") then
      QuestFrameOptionClicked_Item("#{PTFB_191228_217}", 1, 800)
    end
    if IsWindowVisible("WuLin_Up") then
      local minC, maxC = GSH_Up_GetNextChoice()
      GSH_Up_ClickNextCeng(minC, maxC)
    end
  elseif string.find(strItem, "#{PTFB_191228_219}", nil, true) then
    if GSH_leave_asleader() then
      return aStart_wait_tick
    end
    if bOpenNPC then
      QuestFrameOptionClicked_Item("#{PTFB_191228_219}", 1, 800)
    end
  elseif string.find(strItem, "#{PTFB_191228_77", nil, true) then
    if GSH_leave_asleader() then
      return aStart_wait_tick
    end
    local curCeng = GSH_GetCurrentCeng()
    local leaveCeng = m_param.leave_ceng_value
    if Player:IsLeader() then
      if m_param.leave_ceng and curCeng > leaveCeng then
        PushColorMsg("队长到达指定的层数,离开副本！")
        Sleep(5000)
        GSH_LeaveScene(nil, nil)
        return aStart_wait_tick
      end
    elseif m_param.leave_member and curCeng > leaveCeng then
      PushColorMsg("队员到达指定的层数,离开副本！")
      Sleep(5000)
      GSH_LeaveScene(nil, nil)
      return aStart_wait_tick
    end
    if bOpenNPC and bStart then
      QuestFrameOptionClicked_Item("#{PTFB_191228_77", 3, 800)
      MessageBox_Self2_OK_Clicked(600)
    end
  elseif string.find(strItem, "#{PTFB_191228_218}", nil, true) then
    PushColorMsg("挑战失败")
    QuestFrameOptionClicked_Item("#{PTFB_191228_218}", 1, 800)
    QuestFrameOptionClicked_Item("#{PTFB_191228_36}", 1, 800)
    QuestFrameOptionClicked_Item("#{PTFB_191228_477}", 1, 800)
  end
  if false == bOpenNPC then
    if aNPC.name == "朝覆雨" or aNPC.name == "离人偶" then
      local pos = GSH_SceneZeroPos()
      if pos then
        RunTo(pos.x, pos.y, 0, 500)
      end
    elseif aNPC.name == "傅致远" then
      local pos = GSH_SceneZeroPos()
      if pos then
        RunTo(pos.x, pos.y, 0, 500)
      end
    else
      TeamDispersedStations(aNPC, 2)
    end
  end
  return aStart_wait_tick
end

local function GSH_OnAttack(aObj)
  CloseWindow("Quest")
  CDG.call.back1 = nil
  for i = 1, #aObj do
    local tmp = aObj[i]
    if tmp.name == "燕驰野" then
      GSH_MingJiao()
      break
    elseif tmp.name == "解谊" then
      GSH_GaiBang()
      break
    elseif tmp.name == "唐简" then
      GSH_TangMeng()
      break
    elseif tmp.name == "崔璎" then
      GSH_EMei()
      break
    elseif tmp.name == "夜来" then
      GSH_XingXiu()
      break
    elseif tmp.name == "傅致远" then
      GSH_WuDang()
      break
    elseif tmp.name == "离人偶" or tmp.name == "朝覆雨" then
      GSH_TaoHuaDao()
      break
    elseif tmp.name == "段思安" then
      GSH_TianLong()
      break
    elseif tmp.name == "霜见" then
      GSH_TianShan()
      break
    elseif tmp.name == "原微之" then
      GSH_XiaoYao()
      break
    elseif tmp.name == "慕容信" then
      GSH_MuRong()
      break
    elseif tmp.name == "无执" then
      GSH_ShaoLin()
      break
    elseif tmp.name == "苏延清" then
      GSH_GuiGu()
      break
    end
  end
end

local function GSH_OnAction()
  local start_wait_tick = -1
  while IsGuanShanHaiScene() do
    local debugnote = ""
    HuiShouLiRenOu()
    FuBenCheckDie(false, true)
    local tObj = Enum2XByClass("NPC 怪物", {0, -1})
    local tNPC = ObjFilterByStrClass(tObj, "NPC", 0)
    local tGuai = ObjFilterByStrClass(tObj, "怪物", 0)
    if #tGuai > 0 then
      debugnote = " 怪物"
      GSH_OnAttack(tGuai)
      start_wait_tick = -1
    else
      DeleteDebugMsg("#{BSJN_200327_36}")
      if #tNPC > 0 then
        debugnote = " NPC"
        start_wait_tick = GSH_NPCStart(tNPC[1], start_wait_tick)
      else
        local pos = GSH_SceneZeroPos()
        RunTo(pos.x, pos.y, 0, 500)
        debugnote = " 没有找到NPC"
      end
    end
    FubenAttack(-1)
    Sleep(300)
    DebugStr("观山海副本" .. debugnote)
  end
end

local function GSH_lqjl(aCount)
  local is3over = false
  aCount = aCount or 10
  DeleteDebugMsg("#{PTFB_191228_124}")
  DeleteDebugMsg("#{PTFB_191228_126")
  DeleteDebugMsg("#{PTFB_191228_257}")
  Bag_DeleteBagItem()
  for i = 1, aCount do
    GoToSceneNPC("沈寒洲", 210, 51, 2)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{PTFB_191228_04}", 1, 800)
    QuestFrameOptionClicked_Item("#{PTFB_191228_241}", 1, 800)
    if IsInDebugMsg("#{PTFB_191228_126") then
      PushColorMsg("背包需要清理")
      break
    end
    if IsInDebugMsg("#{PTFB_191228_124}") or IsInDebugMsg("#{PTFB_191228_257}") then
      break
    end
  end
  DeleteDebugMsg("#{PTFB_191228_126")
  DeleteDebugMsg("#{PTFB_191228_473}")
  for i = 1, aCount do
    GoToSceneNPC("沈寒洲", 210, 51, 2)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{PTFB_191228_259}", 1, 800)
    local strItem = GetNPCEventListAllItem()
    if string.find(strItem, "#{DBLL_200628_35", nil, true) then
      is3over = true
      if string.find(strItem, "#{PTFB_191228_247", nil, true) then
        is3over = false
      end
    end
    local _, _, ci, ceng = string.find(strItem, "#{PTFB_191228_246.-(%d).-(%d+)}")
    ci = tonumber(ci) or i
    if ci > 3 then
      ci = ci % 3
      if 0 == ci then
        ci = 3
      end
    end
    PushColorMsg("领取第" .. ci .. "次奖励")
    if 1 == ci then
      QuestFrameOptionClicked_Item("#{PTFB_191228_467}", 1, 800)
      if IsInDebugMsg("#{PTFB_191228_473}") then
        break
      end
    elseif 2 == ci then
      QuestFrameOptionClicked_Item("#{PTFB_191228_469}", 1, 800)
      if IsInDebugMsg("#{PTFB_191228_473}") then
        break
      end
    else
      if 3 ~= ci then
        break
      end
      QuestFrameOptionClicked_Item("#{PTFB_191228_471}", 1, 800)
      if not IsInDebugMsg("#{PTFB_191228_473}") then
      else
        break
      end
    end
    if IsInDebugMsg("#{PTFB_191228_126") then
      PushColorMsg("背包需要清理")
      break
    end
  end
  return is3over
end

local function GSH_GetWeekCount()
  local strText = GetLuaValue([[
        setmetatable(_G, {__index = WuLin_Peak_Env})
        if this:IsVisible() then
            return WuLin_Peak_ChallengeText:GetText()
        end
        return ""
        ]], "s")
  local _, _, str = string.find(strText, "本周剩余挑战次数.-(%d+)/20")
  str = tonumber(str) or 21
  return str
end

function _SMain(...)
  if not IsGuanShanHaiScene() then
    GSH_lqjl(3)
  end
  GSH_ParamInit()
  local nFubenCount = 0
  while true do
    local debugnote = ""
    if IsGuanShanHaiScene() then
      GSH_OnAction()
      RunTo(210, 51, 0)
      local is3Over = GSH_lqjl(10)
      nFubenCount = nFubenCount + 1
      if not m_param.count3 then
        break
      end
      if nFubenCount >= 3 or is3Over then
        if is3Over then
          PushColorMsg("观山海：您本周奖励已经刷完")
        else
          PushColorMsg("观山海：您已经刷了3次了")
        end
        if IsGuanShanHaiScene() then
        else
          break
        end
      end
    else
      local teamCount = m_teamCount
      if IsWindowVisible("WuLin") then
        if not Team:IsCountReady(teamCount) then
          CloseWindow("WuLin")
        end
        if 0 == GSH_GetWeekCount() then
          PushColorMsg("观山海：本周已完成20次！")
          break
        end
        local choose
        choose, debugnote = GSH_Choose()
        if 1 == choose then
          if Player:IsLeader() then
            GSH_WeekAward()
            local minC, maxC = GSH_GetNextChoice()
            GSH_ClickNextCeng(minC, maxC)
          end
        elseif 3 == choose and Player:IsLeader() == false then
          GSH_WeekAward()
          IsWindowVisible("WuLin", "WuLin_Member_OnChooseStageConfirm()")
        end
      elseif IsWindowVisible("WuLin_Peak", "WuLin_Peak_EnterScene()") then
        if 0 == GSH_GetWeekCount() then
          PushColorMsg("观山海：本周已完成20次！")
          break
        end
        Sleep(800)
      else
        GoToSceneNPC("沈寒洲", 210, 51, 2)
        ChangeSceneLine()
        if Player:IsLeader() and Team:IsCountReady(teamCount) then
          QuestFrameOptionClicked_Item("#{PTFB_191228_02}", 1, 1000)
        end
      end
    end
    Sleep(600)
    FubenAttack(-1)
    DebugStr(m_script_name .. " " .. debugnote)
  end
  RunTo(211, 88, 0)
end

_SMain()
ScriptOnStop(m_script_name, true)
