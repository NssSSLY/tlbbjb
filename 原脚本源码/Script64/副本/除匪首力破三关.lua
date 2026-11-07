-- 反编译自 dfz64.dll 内嵌字节码 00320005（unluac 2025-12-23；仅供分析）
local m_script_name = "除匪首力破三关"
ScriptOnStart(m_script_name, true, true)
local m_param = {}
m_param.xiaohao = ReadConfigBool("ZH", "xzk166")
local m_xiaohao = m_param.xiaohao
local m_teamCount = HandleTextToNumber(GetConfigText("组队人数", "老三环"), 0)
if g_self.isjingong then
  m_xiaohao = true
end
local m_sceneID = 653
if m_xiaohao then
  CDG.attackMode = "打死换怪"
else
  CDG.attackMode = "优先绿怪"
end
g_pick.check = true
CDG.sceneID = m_sceneID
CDG.overMapErr = true
CDG.die.out = true
CDG.posRadius = 15
CDG.tragetSelect = true
CDG.die.maxCount = 0
CDG.savebank = false
local m_finish = false
local m_posKill = {
  [1] = {
    {x = 183, y = 155},
    {x = 180, y = 143},
    {x = 165, y = 116},
    {x = 182, y = 118},
    {x = 199, y = 135}
  },
  [2] = {
    {x = 178, y = 120}
  },
  [3] = {
    {x = 199, y = 105}
  },
  [4] = {
    {x = 204, y = 122}
  },
  [5] = {
    {x = 194, y = 54}
  },
  [6] = {
    {x = 147, y = 65},
    {x = 135, y = 74},
    {x = 125, y = 41},
    {x = 99, y = 42},
    {x = 74, y = 40},
    {x = 68, y = 58},
    {x = 52, y = 44}
  },
  [7] = {
    {x = 52, y = 44}
  },
  [8] = {
    {x = 58, y = 196}
  }
}

local function fuben_callback(fX, fY, nScene)
  if m_param.xiaohao and 2 ~= Player:GetState() then
    DebugStr("副本：小号", 2)
    Sleep(5000)
  end
  return GetSceneID() == m_sceneID
end

local function scxg_getStage()
  return GetLuaValue([[
	
        	setmetatable(_G, {__index = Sancai_Env})
        	if this:IsVisible() then
                if Sancai_BK1:IsVisible() then
        		    return 1
        	    elseif Sancai_BK2:IsVisible() then
        	        return 2
        	    elseif Sancai_BK3:IsVisible() then
        	        return 3			
        	    end		
            end
        	return 0
        ]], "n")
end

local function scxg_stage1_num()
  local strText = [[
            setmetatable(_G, {__index=Sancai_Env});
            local songbing = Sancai_Image1Info2:GetProperty("Text")
            local fudutong = Sancai_Image1Info3:GetProperty("Text")
            local feilei = Sancai_Image1Info4:GetProperty("Text")
            local dutong = Sancai_Image1Info5:GetProperty("Text")
            local yudu = Sancai_Image1Info6:GetProperty("Text")

            if songbing == nil or songbing == "" then 
                songbing = "nil"
            end
            if fudutong == nil or fudutong == "" then 
                fudutong = "nil"
            end
            if feilei == nil or feilei == "" then 
                feilei = "nil"
            end
            if dutong == nil or dutong == "" then 
                dutong = "nil"
            end
            if yudu == nil or yudu == "" then 
                yudu = "nil"
            end
            return songbing,fudutong,feilei,dutong,yudu
        ]]
  local strSongBing, strFuDuTong, strFeiLei, strDuTong, strYuDu = GetLuaValue(strText, "sssss")
  _, _, strSongBing = string.find(strSongBing, "(%d+)/30")
  _, _, strFuDuTong = string.find(strFuDuTong, "(%d)/1")
  _, _, strFeiLei = string.find(strFeiLei, "(%d)/6")
  _, _, strDuTong = string.find(strDuTong, "(%d)/1")
  _, _, strYuDu = string.find(strYuDu, "(%d)/1")
  strSongBing = tonumber(strSongBing)
  strFuDuTong = tonumber(strFuDuTong)
  strFeiLei = tonumber(strFeiLei)
  strDuTong = tonumber(strDuTong)
  strYuDu = tonumber(strYuDu)
  if type(strSongBing) ~= "number" then
    strSongBing = -1
    PushColorMsg("宋兵获取失败！")
  end
  if type(strFuDuTong) ~= "number" then
    strFuDuTong = -1
    PushColorMsg("副都统获取失败！")
  end
  if type(strFeiLei) ~= "number" then
    strFeiLei = -1
    PushColorMsg("匪类数量获取失败！")
  end
  if type(strDuTong) ~= "number" then
    strDuTong = -1
    PushColorMsg("都统数量获取失败！")
  end
  if type(strYuDu) ~= "number" then
    strYuDu = -1
    PushColorMsg("余毒数量获取失败！")
  end
  return strSongBing, strFuDuTong, strFeiLei, strDuTong, strYuDu
end

local function scxg_stage2_num()
  local strText = [[
            setmetatable(_G, {__index=Sancai_Env});
            local yexiong = Sancai_Image2Info2:GetProperty("Text")
            local hongxiongwang = Sancai_Image2Info3:GetProperty("Text")
           
            if yexiong == nil or yexiong == "" then 
                yexiong = "nil"
            end
            if hongxiongwang == nil or hongxiongwang == "" then 
                hongxiongwang = "nil"
            end
  
            return yexiong,hongxiongwang
        ]]
  local strYeXiong, strHongXiongWang = GetLuaValue(strText, "ss")
  _, _, strYeXiong = string.find(strYeXiong, "(%d+)/30")
  _, _, strHongXiongWang = string.find(strHongXiongWang, "(%d)/1")
  strYeXiong = tonumber(strYeXiong)
  strHongXiongWang = tonumber(strHongXiongWang)
  if type(strYeXiong) ~= "number" then
    strYeXiong = -1
    PushColorMsg("野熊获取失败！")
  end
  if type(strHongXiongWang) ~= "number" then
    strHongXiongWang = -1
    PushColorMsg("红熊王统获取失败！")
  end
  return strYeXiong, strHongXiongWang
end

local function scxg_checkInfoWindow()
  if IsWindowVisible("SancaiMini") then
    GetLuaValue("setmetatable(_G, {__index = SancaiMini_Env});SancaiMini_Cliecked();")
    Sleep(500)
  end
  if not IsWindowVisible("Sancai") then
    GetLuaValue("PushEvent(\"3HUAN_OPEN_UI_RESULT\", 1)")
    Sleep(1000)
    PushColorMsg("老三：获取进度的窗口不可视！")
    return false
  end
  return true
end

local function scxg_getPos()
  scxg_checkInfoWindow()
  local pos = {}
  local step = -1
  local curStage = scxg_getStage()
  if 1 == curStage then
    local songbing, fudutong, feilei, dutong, yudu = scxg_stage1_num()
    if songbing < 30 then
      step = 1
      pos = m_posKill[1]
    elseif 0 == fudutong then
      step = 2
      pos = m_posKill[2]
    elseif feilei < 6 then
      step = 3
      local nMemIndex = Team:GetMyIndex()
      if 0 == nMemIndex or 2 == nMemIndex or 4 == nMemIndex then
        pos = m_posKill[3]
      else
        pos = m_posKill[4]
      end
    elseif 0 == dutong then
      step = 4
      pos = m_posKill[5]
    elseif 0 == yudu then
      step = 5
      pos = m_posKill[5]
    else
      PushColorMsg("老三：未知阶段1")
    end
  elseif 2 == curStage then
    local yexiong, hongxiongwang = scxg_stage2_num()
    if yexiong < 30 then
      step = 6
      pos = m_posKill[6]
    elseif 0 == hongxiongwang then
      step = 7
      pos = m_posKill[7]
    else
      PushColorMsg("老三：未知阶段2")
    end
  elseif 3 == curStage then
    step = 8
    pos = m_posKill[8]
  else
    PushColorMsg("老三环:未知进度：" .. curStage)
  end
  return pos, step
end

local function scxg_action()
  if false == scxg_checkInfoWindow() then
    return
  end
  CDG.posIdx = 1
  CDG.horse = false
  local posStep, curIndex = scxg_getPos()
  if -1 == curIndex then
    PushColorMsg("老三：未获取到进度数据")
    return
  elseif 8 == curIndex then
    CDG.horse = true
    CDG.pos = posStep
    local pos = m_posKill[8][1]
    MoveTo(pos.x, pos.y, m_sceneID, nil, nil, nil, fuben_callback)
    Sleep(300)
    Dismount(600)
    Pet:Relax(500)
    Skill:UseName("初级隐遁", 800)
    while -1 ~= Player:GetBuff("初级隐身") do
      Sleep(300)
    end
    for i = 1, 20 do
      if Team:GetSurroundMember(14) < Team:GetMemberCount() then
        DebugStr("等待队友20秒")
      else
        break
      end
      FubenAttack(-1)
      Sleep(1000)
    end
    local tObj = Enum2XByName("山寨大王 愤怒的葛荣", {
      1,
      1,
      0,
      0
    })
    if #tObj > 0 then
      PushDebugMessage("拉Boss" .. tObj[1].class)
      Skill:UseSkillByID(244, tObj[1].id, nil, nil, 300)
      if tObj[1].dst > 3 then
        Sleep(3000)
      end
    end
  end
  
  local function CDG_loop_callback(...)
    local nIndex, idMission, idScript = GetPlayerMission_Item("除匪首力破三关")
    local nComp = GetMissionComplete(nIndex)
    if 0 ~= nComp and 3 ~= nComp then
      return true
    end
    local posArr, newIndex = scxg_getPos()
    if -1 == newIndex then
      return true
    end
    g_pick.ispick = true
    CDG.pos = posArr
    CDG.targetName = ""
    if m_xiaohao then
      CDG.attackMode = "打死换怪"
    else
      CDG.attackMode = "优先绿怪"
    end
    if 3 == newIndex then
      g_pick.ispick = false
      CDG.attackMode = "优先绿怪"
    elseif 6 == newIndex then
      CDG.targetName = " 野熊 "
    elseif 7 == newIndex then
      local hxw = GoToTarget("红熊王", 3)
      if hxw then
        CDG.pos = {}
        table.insert(CDG.pos, {
          x = hxw.x,
          y = hxw.y
        })
      elseif #CDG.pos > 0 then
        local pos = CDG.pos[1]
        RunTo(pos.x, pos.y, 0, 1000)
      end
    elseif 8 == newIndex then
      CDG.targetName = " 山寨大王 愤怒的葛荣 "
    end
    if curIndex <= 5 and newIndex > 5 then
      PushColorMsg("老三：已经打败余毒！")
      return true
    elseif curIndex <= 7 and newIndex > 7 then
      PushColorMsg("老三：已经打败红熊王！")
      if #CDG.pos > 0 then
        local pos = CDG.pos[1]
        RunTo(pos.x, pos.y, 0, 3000)
      end
      return true
    end
    DebugStr("老三：阶段 " .. curIndex .. "." .. newIndex)
    return false
  end
  
  CDG.callfun = CDG_loop_callback
  CDG.callfun_move = fuben_callback
  CDG:SetTimeOut(300)
  CDG:OnStart()
  FubenAttack(-1)
  PickUpLua()
  EatBindItem()
  local _, curIndex = scxg_getPos()
  if 8 == curIndex then
    PickUpLua_Boss(15, 15, nil)
  end
end

function _SMain(...)
  while true do
    local debugnote = ""
    local nParam = {}
    local nIndex, idMission, idScript = GetPlayerMission_Item("除匪首力破三关")
    if -1 ~= nIndex then
      nParam[0] = GetMissionComplete(nIndex)
      if GetSceneID() ~= m_sceneID then
        GoToSceneNPC("钱宏宇", 133, 260, 1)
        ChangeSceneLine()
        Sleep(500)
        if 0 == nParam[0] then
          local teamCount = m_teamCount
          if Player:IsLeader() and Team:IsCountReady(teamCount) or not Player:IsLeader() then
            QuestFrameOptionClicked_Item("#{LSHYH_150210_78}", 1, 800)
          end
          Sleep(2000)
        elseif 1 == nParam[0] then
          QuestFrameOptionClicked_Item("除匪首力破三关", 1, 800)
          QuestFrameNextClicked(800)
          QuestFrameMissionComplete(nil, 500)
        elseif 2 == nParam[0] then
          PushColorMsg("老三：任务失败,放弃任务")
          QuestFrameMissionAbnegate(idScript)
          Sleep(500)
        elseif 3 == nParam[0] then
          PushColorMsg("老三：本号已经进入副本后离开了副本，放弃任务！")
          QuestFrameMissionAbnegate(idScript)
          Sleep(500)
        end
      else
        m_finish = true
        if 0 == nParam[0] or 3 == nParam[0] then
          scxg_action()
        else
          PushDebugMessage("老三：任务完成！")
          SDQY_HuoDong()
          PickUpLua()
          EatBindItem()
          for i = 1, 12 do
            DebugStr("包裹刷新有延迟,持续10秒搜索包裹中.")
            PickUpLua()
            Sleep(500)
            FubenAttack(-1)
          end
          EatBindItem()
          MoveToNPC("宋兵接应人", 63, 196, m_sceneID, nil, nil, nil, fuben_callback)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{LSHYH_150210_40}", 1, 600)
          PickUpLua()
          QuestFrameOptionClicked_Item("#{LSHYH_150210_43}", 1, 800)
          Sleep(2000)
        end
      end
    else
      if m_finish then
        PushColorMsg("老三：已完成单次任务")
        break
      end
      PushDebugMessage("老三：接取任务！")
      XiaoChangHuiXue(80)
      GoToSceneNPC("钱宏宇", 133, 260, 1)
      ChangeSceneLine()
      Sleep(500)
      QuestFrameOptionClicked_Item("除匪首力破三关", 1, 800)
      QuestFrameAcceptClicked(2000)
      local strText = GetNPCEventList_Item(0)
      if "#{XSCS_180827_1}" == strText then
        Sleep(1000)
        if GetSceneID() ~= m_sceneID then
          PushColorMsg("老三：今日已完成！")
          break
        end
      end
    end
    Sleep(500)
    DebugStr("除匪首力破三关" .. debugnote)
  end
end

_SMain()
m_posKill = nil
ScriptOnStop(m_script_name, true)
