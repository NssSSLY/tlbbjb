-- 反编译自 dfz64.dll 内嵌字节码 0055fe64（unluac 2025-12-23；仅供分析）
CExec("common_2")
CExec("common")
CExec("team")
CExec("player")
local m_last_tick_yaoqing = -1
local m_last_tick_shenqing_guding_team = -1
local m_last_tick_shenqing_fujin_team = -1
local m_last_tick_shenqing_guding_raid = -1
local m_last_tick_shenqing_fujin_raid = -1
local m_data_yaoqing = {}
local m_data_shenqing = {}
local m_time_diff = 30000
if 2 == g_client_type then
  m_time_diff = 60000
end
g_config.team = {}
g_config.twmz = {}

local function GetTeamConfig(aTeamState, aRaidState)
  if nil ~= aTeamState and nil ~= aRaidState then
    g_config.team.mode_team_guding = false
    g_config.team.mode_team_auto = false
    g_config.team.mode_raid_guding = false
    g_config.team.mode_raid_auto = false
    if 1 == aTeamState then
      g_config.team.mode_team_guding = true
    elseif 2 == aTeamState then
      g_config.team.mode_team_auto = true
    end
    if 1 == aRaidState then
      g_config.team.mode_raid_guding = true
    elseif 2 == aRaidState then
      g_config.team.mode_raid_auto = true
    end
  else
    g_config.team.mode_team_guding = ReadConfigBool("ZH", "dxk38")
    g_config.team.mode_team_auto = ReadConfigBool("ZH", "dxk39")
    g_config.team.mode_raid_guding = ReadConfigBool("ZH", "dxk41")
    g_config.team.mode_raid_auto = ReadConfigBool("ZH", "dxk42")
  end
  g_config.team.uncheck_script = "偷袭门派 追捕野猪王 帮会疑踪"
  g_config.twmz.auto_team = ReadConfigBool("ZH", "xzk78")
  g_config.twmz.team_name = ReadConfigText("ZH", "bjk15")
  g_config.team.bai_group1 = ReadConfigBool("ZH", "xzk80")
  g_config.team.bai_group2 = ReadConfigBool("ZH", "xzk81")
  g_config.team.bai_group3 = ReadConfigBool("ZH", "xzk82")
  g_config.team.bai_group4 = ReadConfigBool("ZH", "xzk83")
  g_config.team.check_menpai = ReadConfigBool("ZH", "xzk171")
  g_config.team.shaolin = ReadConfigBool("ZH", "xzk246")
  g_config.team.mingjiao = ReadConfigBool("ZH", "xzk248")
  g_config.team.gaibang = ReadConfigBool("ZH", "xzk249")
  g_config.team.wudang = ReadConfigBool("ZH", "xzk247")
  g_config.team.emei = ReadConfigBool("ZH", "xzk111")
  g_config.team.xingxiu = ReadConfigBool("ZH", "xzk253")
  g_config.team.tianlong = ReadConfigBool("ZH", "xzk254")
  g_config.team.tianshan = ReadConfigBool("ZH", "xzk252")
  g_config.team.xiaoyao = ReadConfigBool("ZH", "xzk251")
  g_config.team.murong = ReadConfigBool("ZH", "xzk250")
  g_config.team.tangmen = ReadConfigBool("ZH", "xzk256")
  g_config.team.guigu = ReadConfigBool("ZH", "xzk255")
  g_config.team.taohuadao = ReadConfigBool("ZH", "xzk285")
  g_config.team.congren = ReadConfigBool("ZH", "xzk289")
  g_config.team.erengu = ReadConfigBool("ZH", "xzk92")
  g_config.team.mingdan_bai = ReadConfigText("ZH", "bjk102")
  g_config.team.mingdan_hei = ReadConfigText("ZH", "bjk65")
  g_config.team.check_banghui_bai = ReadConfigBool("ZH", "xzk169")
  g_config.team.banghui_bai = ReadConfigText("ZH", "bjk66")
  g_config.team.check_banghui_hei = ReadConfigBool("ZH", "xzk172")
  g_config.team.banghui_hei = ReadConfigText("ZH", "bjk20")
  g_config.team.mingdan_team = ReadConfigText("ZH", "bjk126")
  g_config.team.mingdan_raid = ReadConfigText("ZH", "bjk42")
  g_config.team.check_level = ReadConfigBool("ZH", "xzk173")
  g_config.team.level_min = ReadConfigInt("ZH", "bjk18")
  g_config.team.level_max = ReadConfigInt("ZH", "bjk8")
  g_config.team.check_chouren = ReadConfigBool("ZH", "xzk257")
  g_config.team.give_gd = ReadConfigBool("ZH", "xzk264")
  g_config.team.check_hp = ReadConfigBool("ZH", "xzk259")
  g_config.team.hp_min = ReadConfigInt("ZH", "bjk17")
  g_config.team.yaoqing = ReadConfigBool("ZH", "xzk101")
  g_config.team.ask_gd_before_create = ReadConfigBool("ZH", "xzk262")
  g_config.team.shenqing = ReadConfigBool("ZH", "xzk258")
  g_config.team.jieshou_yaoqing = ReadConfigBool("ZH", "xzk84")
  g_config.team.leave_only_self = ReadConfigBool("ZH", "xzk263")
  g_config.team.leave_isleader = ReadConfigBool("ZH", "xzk79")
end

local function TeamGetFilterParam()
  local bai_friend = " "
  if g_config.team.bai_group1 then
    bai_friend = bai_friend .. "1 "
  end
  if g_config.team.bai_group2 then
    bai_friend = bai_friend .. "2 "
  end
  if g_config.team.bai_group3 then
    bai_friend = bai_friend .. "3 "
  end
  if g_config.team.bai_group4 then
    bai_friend = bai_friend .. "4 "
  end
  local menpai = ""
  if g_config.team.check_menpai then
    menpai = " "
    if g_config.team.shaolin then
      menpai = menpai .. "0 "
    end
    if g_config.team.mingjiao then
      menpai = menpai .. "1 "
    end
    if g_config.team.gaibang then
      menpai = menpai .. "2 "
    end
    if g_config.team.wudang then
      menpai = menpai .. "3 "
    end
    if g_config.team.emei then
      menpai = menpai .. "4 "
    end
    if g_config.team.xingxiu then
      menpai = menpai .. "5 "
    end
    if g_config.team.tianlong then
      menpai = menpai .. "6 "
    end
    if g_config.team.tianshan then
      menpai = menpai .. "7 "
    end
    if g_config.team.xiaoyao then
      menpai = menpai .. "8 "
    end
    if g_config.team.murong then
      menpai = menpai .. "10 "
    end
    if g_config.team.tangmen then
      menpai = menpai .. "11 "
    end
    if g_config.team.guigu then
      menpai = menpai .. "12 "
    end
    if g_config.team.taohuadao then
      menpai = menpai .. "13 "
    end
    if g_config.team.congren then
      menpai = menpai .. "14 "
    end
    if g_config.team.erengu then
      menpai = menpai .. "15 "
    end
  end
  local bai_ming_dan = " " .. HandleText(g_config.team.mingdan_bai) .. " "
  local hei_ming_dan = " " .. HandleText(g_config.team.mingdan_hei) .. " "
  local bai_banghui = ""
  local hei_banghui = ""
  if g_config.team.check_banghui_bai then
    bai_banghui = " " .. HandleText(g_config.team.banghui_bai) .. " "
  elseif g_config.team.check_banghui_hei then
    hei_banghui = " " .. HandleText(g_config.team.banghui_hei) .. " "
  end
  local guding_team = " " .. HandleText(g_config.team.mingdan_team) .. " "
  local guding_raid = " " .. HandleText(g_config.team.mingdan_raid) .. " "
  local minLevel = 0
  local maxLevel = 120
  if g_config.team.check_level then
    minLevel = tonumber(g_config.team.level_min)
    minLevel = minLevel or 0
    maxLevel = tonumber(g_config.team.level_max)
    maxLevel = maxLevel or 120
  end
  local param = {}
  param.bai_ming_dan = bai_ming_dan
  param.bai_friend = bai_friend
  param.guding_team = guding_team
  param.guding_raid = guding_raid
  param.bai_menpai = menpai
  param.hei_ming_dan = hei_ming_dan
  param.bai_banghui = bai_banghui
  param.hei_banghui = hei_banghui
  param.level_min = minLevel
  param.level_max = maxLevel
  param.must_em = "true"
  param.enemy = "false"
  if g_config.team.check_chouren then
    param.enemy = "true"
  end
  return param
end

local function Team2GuDingLeader()
  if g_config.team.give_gd then
    local all_name = HandleText(g_config.team.mingdan_team)
    local memArr = SplitString(all_name, " ", true)
    if #memArr > 0 then
      local leader_name = memArr[1]
      local self_name = Player_GetName()
      if #self_name > 0 and self_name ~= leader_name then
        local info = Team:GetAllInfo()
        for i = 1, #info do
          local tmp = info[i]
          if tmp.name == leader_name and tmp.index >= 0 and tmp.index <= 5 then
            GetLuaValue(fmt("meTestMsg('组队：您已设置将队伍给固定队长');Player:AppointLeader(%d)", tmp.index))
            return true
          end
        end
      end
    end
  end
  return false
end

local function TeamCheckHP(aBaiMingDan, aGuDing, aBaiFriend)
  local minHP = tonumber(g_config.team.hp_min)
  if g_config.team.check_hp and minHP and minHP > 0 and IsInFubenScene() == false then
    local bai_ming_dan = aBaiMingDan .. aGuDing
    bai_ming_dan = HandleText(bai_ming_dan)
    GetLuaValue(fmt("meKickMemberByHP([[%s]],[[%s]],%d)", bai_ming_dan, aBaiFriend, minHP))
  end
end

local function TeamYaoQingFuJin(arg, aTeamRaid)
  if not g_config.team.yaoqing then
    return false
  end
  local nowTick = GetTickCount()
  if -1 ~= m_last_tick_yaoqing and nowTick - m_last_tick_yaoqing < m_time_diff then
    return false
  end
  m_last_tick_yaoqing = nowTick
  local strText = fmt("return meSendInvite([[%s]],[[%s]],[[%s]],[[%s]],[[%s]],[[%s]],%d,%d,%s,%s,%d)", arg.bai_ming_dan, arg.hei_ming_dan, arg.bai_friend, arg.bai_banghui, arg.hei_banghui, arg.bai_menpai, arg.level_min, arg.level_max, arg.must_em, arg.enemy, aTeamRaid)
  local invite_name = GetLuaValue(strText, "s")
  local tObj = Text2Table(invite_name, " ", "name")
  local tName = ObjTickFilter(tObj, m_data_yaoqing, 120000, "name")
  if #tName > 0 then
    local nCount = #tName
    if nCount > 5 then
      nCount = 5
    end
    for i = 1, nCount do
      if 1 == aTeamRaid then
        GetLuaValue("Target:SendTeamRequest([[" .. tName[i].name .. "]]);")
      else
        GetLuaValue("Target:SendRaidInvitation([[" .. tName[i].name .. "]]);")
      end
      m_data_yaoqing = ObjTickPush(m_data_yaoqing, tName[i].name, "name")
      if Sleep(1500) then
        break
      end
    end
    return true
  else
    m_last_tick_yaoqing = -1
  end
  return false
end

function IsFriendIsScene(aFriendName, aSelfScene)
  return GetLuaValue(fmt("return meIsFriendIsScene(\"%s\",\"%s\")", aFriendName, aSelfScene), "b")
end

local function TeamShenQingGuDing(aParam, aTeamRaid)
  local now_tick = GetTickCount()
  if 1 == aTeamRaid then
    if -1 ~= m_last_tick_shenqing_guding_team and now_tick - m_last_tick_shenqing_guding_team < m_time_diff then
      return false
    end
    m_last_tick_shenqing_guding_team = now_tick
  else
    if -1 ~= m_last_tick_shenqing_guding_raid and now_tick - m_last_tick_shenqing_guding_raid < m_time_diff then
      return false
    end
    m_last_tick_shenqing_guding_raid = now_tick
  end
  local gudingTab = {}
  if 1 == aTeamRaid then
    gudingTab = SplitString(aParam.guding_team, " ", true)
  elseif 2 == aTeamRaid or 3 == aTeamRaid then
    gudingTab = SplitString(aParam.guding_raid, " ", true)
  end
  if #gudingTab > 0 then
    local szName = Player_GetName()
    if szName == gudingTab[1] then
      if 3 == aTeamRaid or not g_config.team.ask_gd_before_create then
        GetLuaValue("Player:CreateTeamSelf();")
        return false
      end
      local bCreateTeam = true
      for i = 1, #gudingTab do
        if 1 ~= i and AskFriend(gudingTab[i]) then
          if Sleep(3000) then
            return false
          end
          local team_or_raid, nleader, nMemCount = GetLuaValue("return meGetTeamRaidBaseInfo()", "nnn")
          if 0 ~= team_or_raid then
            return true
          end
          local nTeamFlag = GetLuaValue(fmt("return meFriendIsInTeam([[%s]])", gudingTab[i]), "n")
          if 1 == nTeamFlag then
            bCreateTeam = false
            if 1 == aTeamRaid or 3 == aTeamRaid then
              GetLuaValue(fmt("if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then Target:SendTeamApply([[%s]]) end;", gudingTab[i]))
              Sleep(2000)
            end
          elseif 2 == nTeamFlag then
            bCreateTeam = false
            if 2 == aTeamRaid or 3 == aTeamRaid then
              GetLuaValue(fmt("if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then Target:SendRaidApplication([[%s]]) end;", gudingTab[i]))
              Sleep(2000)
            end
          else
            local selfScene = GetCurrentSceneName()
            if "" ~= selfScene then
              if not IsKVKSceneName(selfScene) then
                DeleteDebugMsg("对方不属于某个团队。")
                if IsFriendIsScene(gudingTab[i], selfScene) then
                  GetLuaValue(fmt("if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then Target:SendRaidApplication([[%s]]) end;", gudingTab[i]))
                  Sleep(2500)
                  if not IsInDebugMsg("对方不属于某个团队。") then
                    bCreateTeam = false
                  end
                end
              end
            else
              bCreateTeam = false
              break
            end
          end
        end
      end
      if bCreateTeam then
        GetLuaValue("Player:CreateTeamSelf();")
      else
        PushDebugMessage("固定名单内成员已经有组,申请进他们组！")
      end
      return true
    else
      if AskFriend(gudingTab[1]) and Sleep(3000) then
        return false
      end
      local nAsk = GetLuaValue(fmt("return meAskPlayerTeam([[%s]],%d)", gudingTab[1], aTeamRaid), "n")
      if 0 ~= nAsk then
        return true
      end
    end
  else
    return false
  end
end

local function TeamShenQingFuJin(arg, aTeamRaid)
  if not g_config.team.shenqing then
    return false
  end
  local now_tick = GetTickCount()
  if 1 == aTeamRaid then
    if -1 ~= m_last_tick_shenqing_fujin_team and now_tick - m_last_tick_shenqing_fujin_team < m_time_diff then
      return false
    end
    m_last_tick_shenqing_fujin_team = now_tick
  else
    if -1 ~= m_last_tick_shenqing_fujin_raid and now_tick - m_last_tick_shenqing_fujin_raid < m_time_diff then
      return false
    end
    m_last_tick_shenqing_fujin_raid = now_tick
  end
  local strText = fmt("return meAskFuJinTeam([[%s]],[[%s]],[[%s]],[[%s]],[[%s]],[[%s]],%d,%d,%s,%s,%d)", arg.bai_ming_dan, arg.hei_ming_dan, arg.bai_friend, arg.bai_banghui, arg.hei_banghui, "", arg.level_min, arg.level_max, arg.must_em, arg.enemy, aTeamRaid)
  local leader_name = GetLuaValue(strText, "s")
  local tObj = Text2Table(leader_name, " ", "name")
  local leaderTab = ObjTickFilter(tObj, m_data_shenqing, 120000, "name")
  if #leaderTab > 0 then
    local nCount = #leaderTab
    if nCount > 5 then
      nCount = 5
    end
    for i = 1, nCount do
      if 1 == aTeamRaid then
        GetLuaValue(fmt("if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then Target:SendTeamApply([[%s]]) end;", leaderTab[i].name))
      else
        GetLuaValue(fmt("if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then Target:SendRaidApplication([[%s]]) end;", leaderTab[i].name))
      end
      m_data_shenqing = ObjTickPush(m_data_shenqing, leaderTab[i].name, "name")
      if Sleep(1500) then
        break
      end
    end
    return true
  elseif 1 == aTeamRaid then
    m_last_tick_shenqing_fujin_team = -1
  else
    m_last_tick_shenqing_fujin_raid = -1
  end
  return false
end

local function TeamYaoQingWo(arg, aTeamRaid)
  if g_config.team.jieshou_yaoqing then
    local strText = fmt("return meInviteSelf([[%s]],[[%s]],[[%s]],[[%s]],[[%s]],[[%s]],%d,%d,%s,%s,%d)", arg.bai_ming_dan, arg.hei_ming_dan, arg.bai_friend, arg.bai_banghui, arg.hei_banghui, "", arg.level_min, arg.level_max, arg.must_em, arg.enemy, aTeamRaid)
    GetLuaValue(strText)
  end
end

local function TeamOnTeam(aLeader, aMemCount, aArg)
  local nleader = aLeader
  local nMemCount = aMemCount
  local arg = aArg
  if 1 == nleader and (g_config.team.mode_team_guding or g_config.team.mode_team_auto) then
    if Team2GuDingLeader() then
      return
    end
    if g_config.team.mode_team_auto then
      TeamCheckHP(arg.bai_ming_dan, arg.guding_team, arg.bai_friend)
    end
    if g_config.team.leave_only_self and 1 == nMemCount then
      GetLuaValue("meTestMsg('组队:您已设置队伍只有自己解散');Player:DismissTeam();")
      return
    end
    if nMemCount < 6 then
      if g_config.team.mode_team_guding then
        for i = 1, 3 do
          local strText = fmt("return meJoinMemberFilter([[%s]],'','','','','',120,120,false,false,1)", arg.guding_team)
          if not GetLuaValue(strText, "b") then
            break
          end
          Sleep(1000)
        end
      elseif g_config.team.mode_team_auto then
        if g_config.team.leave_isleader then
          GetLuaValue("if Player:IsLeader() == 1 then meTestMsg('自动组队：您已设置 我是队长离开队伍') Player:LeaveTeam() end")
          return
        end
        local bYaoQing = true
        for i = 1, 3 do
          local strText = fmt("return meJoinMemberFilter([[%s]],[[%s]],[[%s]],[[%s]],[[%s]],[[%s]],%d,%d,%s,%s,1)", arg.bai_ming_dan, arg.hei_ming_dan, arg.bai_friend, arg.bai_banghui, arg.hei_banghui, arg.bai_menpai, arg.level_min, arg.level_max, arg.must_em, arg.enemy)
          if not GetLuaValue(strText, "b") then
            break
          end
          bYaoQing = false
          Sleep(1000)
        end
        if bYaoQing then
          TeamYaoQingFuJin(arg, 1)
        end
      end
    end
  end
end

local function TeamOnRaid(aLeader, aMemCount, aArg)
  local nleader = aLeader
  local nMemCount = aMemCount
  local arg = aArg
  if 1 == nleader and (g_config.team.mode_raid_guding or g_config.team.mode_raid_auto) then
    if g_config.team.mode_raid_auto then
      TeamCheckHP(arg.bai_ming_dan, arg.guding_raid, arg.bai_friend)
    end
    if 12 ~= nMemCount then
      if g_config.team.mode_raid_guding then
        for i = 1, 3 do
          local strText = fmt("return meJoinMemberFilter([[%s]],'','','','','',120,120,false,false,2)", arg.guding_raid)
          if not GetLuaValue(strText, "b") then
            break
          end
          Sleep(1000)
        end
      elseif g_config.team.mode_raid_auto then
        local nCnt = 3
        if nMemCount > 9 and nMemCount < 12 then
          nCnt = 1
        end
        local bYaoQing = true
        for i = 1, nCnt do
          local strText = fmt("return meJoinMemberFilter([[%s]],[[%s]],[[%s]],[[%s]],[[%s]],[[%s]],%d,%d,%s,%s,0)", arg.bai_ming_dan, arg.hei_ming_dan, arg.bai_friend, arg.bai_banghui, arg.hei_banghui, arg.bai_menpai, arg.level_min, arg.level_max, "false", arg.enemy)
          if not GetLuaValue(strText, "b") then
            break
          end
          bYaoQing = false
          Sleep(1000)
        end
        if bYaoQing then
          TeamYaoQingFuJin(arg, 2)
        end
      end
    end
  end
end

local function TeamOnBingSheng(aTeamRaid, aLeader, aMemCount, aArg)
  local team_or_raid = aTeamRaid
  local nleader = aLeader
  local nMemCount = aMemCount
  local arg = aArg
  if 1 == team_or_raid then
    if g_config.team.mode_raid_guding then
      local leader, isleader = Team:GetLeaderInfo()
      local gudingTab = SplitString(arg.guding_raid, " ", true)
      if not (leader and #gudingTab > 0) then
        goto lbl_205
      end
      if leader.name == gudingTab[1] then
        if isleader and nMemCount >= 2 then
          GetLuaValue("Player:CreateRaidSelf()")
          Sleep(3000)
        end
        for i = 1, 3 do
          local strText = fmt("return meJoinMemberFilter([[%s]],'','','','','',120,120,false,false,1)", arg.guding_team)
          if not GetLuaValue(strText, "b") then
            break
          end
          Sleep(1000)
        end
      else
        if 1 == nleader then
          GetLuaValue("meTestMsg('12人组队:解散队伍申请固定团长队');Player:DismissTeam();")
        else
          Team:LeaveTeam()
        end
        Sleep(300)
      end
    else
      if not (g_config.team.mode_raid_auto and 1 == nleader and GetDist(307, 251) < 15) or GetSceneID() ~= LUOYANG_ID then
        goto lbl_205
      end
      local bYaoQing = true
      for i = 1, 3 do
        local strText = fmt("return meJoinMemberFilter([[%s]],[[%s]],[[%s]],[[%s]],[[%s]],[[%s]],%d,%d,%s,%s,1)", arg.bai_ming_dan, arg.hei_ming_dan, arg.bai_friend, arg.bai_banghui, arg.hei_banghui, arg.bai_menpai, arg.level_min, arg.level_max, arg.must_em, arg.enemy)
        if not GetLuaValue(strText, "b") then
          break
        end
        bYaoQing = false
        Sleep(1000)
      end
      if bYaoQing then
        TeamYaoQingFuJin(arg, 1)
      end
      if nMemCount >= 2 then
        GetLuaValue("Player:CreateRaidSelf()")
        Sleep(3000)
      end
    end
  elseif 2 == team_or_raid then
    if GetDist(307, 251) < 15 and GetSceneID() == LUOYANG_ID then
      TeamOnRaid(nleader, nMemCount, arg)
    end
  elseif g_config.team.mode_raid_guding then
    TeamShenQingGuDing(arg, 3)
  elseif g_config.team.mode_raid_auto and GetDist(307, 251) < 15 and GetSceneID() == LUOYANG_ID then
    TeamYaoQingWo(arg, 2)
    TeamShenQingFuJin(arg, 2)
    TeamYaoQingFuJin(arg, 2)
    Sleep(3000)
    TeamYaoQingWo(arg, 1)
    TeamShenQingFuJin(arg, 1)
    TeamYaoQingFuJin(arg, 1)
  end
  ::lbl_205::
end

local function TeamOnTWMZ()
  local team_or_raid, nleader, nMemCount = GetLuaValue("return meGetTeamRaidBaseInfo()", "nnn")
  local arg = TeamGetFilterParam()
  if 2 == team_or_raid then
    GetLuaValue("Player:LeaveRiad();")
  elseif g_config.twmz and g_config.twmz.auto_team then
    local gudingTab = SplitString(g_config.twmz.team_name, " ", true)
    if #gudingTab > 0 then
      if 1 == team_or_raid then
        local tTeam = Team:GetAllInfo()
        for i = 1, #tTeam do
          local tmp = tTeam[i]
          local bFind = false
          for j = 1, #gudingTab do
            if tmp.name == gudingTab[j] then
              bFind = true
            end
          end
          if false == bFind then
            PushDebugMessage("天外马贼：队伍内有非名单成员")
            Team:LeaveTeam()
            return
          end
        end
        if #tTeam < 6 then
          local leader, isleader = Team:GetLeaderInfo()
          if leader and leader.name ~= gudingTab[1] then
            PushDebugMessage("天外马贼：队长不是首名单")
            Team:LeaveTeam()
            return
          end
          local strMingDan = HandleText_AddFuHao(g_config.twmz.team_name)
          local strText = fmt("return meJoinMemberFilter([[%s]],'','','','','',120,120,false,false,1)", strMingDan)
          GetLuaValue(strText, "b")
        end
      else
        local szName = Player_GetName()
        if gudingTab[1] == szName then
          GetLuaValue("Player:CreateTeamSelf();")
        elseif AskFriend(gudingTab[1]) then
          if Sleep(3000) then
            return false
          end
          GetLuaValue(fmt("if Player:IsInTeam() == 0 and Player:IsInRaid() == 0 then Target:SendTeamApply([[%s]]) end;", gudingTab[1]))
          Sleep(2000)
        end
      end
    end
  end
  return
end

local function TeamAction()
  local team_or_raid, nleader, nMemCount = GetLuaValue("return meGetTeamRaidBaseInfo()", "nnn")
  local arg = TeamGetFilterParam()
  if g_runing_script == "兵圣奇阵" or g_runing_script == "夜探天波府" then
    TeamOnBingSheng(team_or_raid, nleader, nMemCount, arg)
    return
  end
  if 1 == team_or_raid then
    TeamOnTeam(nleader, nMemCount, arg)
  elseif 2 == team_or_raid then
    TeamOnRaid(nleader, nMemCount, arg)
  else
    if g_config.team.mode_team_guding then
      TeamShenQingGuDing(arg, 1)
    elseif g_config.team.mode_team_auto then
      TeamShenQingGuDing(arg, 1)
      TeamYaoQingWo(arg, 1)
      TeamShenQingFuJin(arg, 1)
      TeamYaoQingFuJin(arg, 1)
    end
    if g_config.team.mode_raid_guding then
      TeamShenQingGuDing(arg, 2)
    elseif g_config.team.mode_raid_auto then
      TeamYaoQingWo(arg, 2)
      TeamShenQingFuJin(arg, 2)
      TeamYaoQingFuJin(arg, 2)
    end
  end
end

function MainCheckTeam()
  local bFirst = true
  while true do
    if IsWindowVisible("PlayerFrame") or IsWindowVisible("MainMenuBar") then
      if bFirst and Player_GetName() ~= "" then
        GetTeamConfig()
        bFirst = false
      end
      local _, nTeamState, nRaidState, bUpdate = SwitchGetState()
      if bUpdate then
        GetTeamConfig()
        SwitchSetState(3)
      elseif nTeamState > 0 or nRaidState > 0 then
        GetTeamConfig(nTeamState, nRaidState)
        SwitchSetState(2)
      end
      if false == bFirst and IsValidConfig() then
        GetConfig()
        if g_config.twmz and g_config.twmz.auto_team and g_runing_script == "天外马贼" then
          TeamOnTWMZ()
        elseif g_config.team.mode_team_guding or g_config.team.mode_team_auto or g_config.team.mode_raid_guding or g_config.team.mode_raid_auto then
          local unCheckScript = g_config.team.uncheck_script
          unCheckScript = HandleText(unCheckScript)
          unCheckScript = HandleText_AddFuHao(unCheckScript, " ", true)
          if "" ~= g_runing_script and string.find(unCheckScript, " " .. g_runing_script .. " ", nil, true) then
            DebugStr(g_runing_script .. ":暂停自动组队！")
          else
            TeamAction()
          end
        end
      end
    end
    Sleep(4000)
  end
end

MainCheckTeam()
