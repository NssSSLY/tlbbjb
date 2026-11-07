-- 反编译自 dfz64.dll 内嵌字节码 005007ad（unluac 2025-12-23；仅供分析）
local m_param = {}
local m_finish = {
  hdb = false,
  stg = false,
  wld = false,
  rps = false,
  lqs = false
}
local m_boss = {
  ["哈大霸"] = {x = 124, y = 87},
  ["桑土公"] = {
    x = 40,
    y = 105,
    isstart = false
  },
  ["乌老大"] = {x = 116, y = 50},
  ["不平道人"] = {
    x = 125,
    y = 35,
    isstart = false
  },
  ["任平生"] = {x = 125, y = 40},
  ["李秋水"] = {
    x = 125,
    y = 40,
    isstart = false,
    waittimeout = -1,
    lasthp = -1,
    findposidx = 1
  }
}
local m_findqiushuipos = {
  {x = 125, y = 40},
  {x = 116, y = 48},
  {x = 125, y = 56},
  {x = 133, y = 48}
}
local m_equip = {
  {
    type = "护腕",
    name = "",
    defineID = -1,
    index = 14
  },
  {
    type = "腰带",
    name = "",
    defineID = -1,
    index = 5
  },
  {
    type = "戒指",
    name = "",
    defineID = -1,
    index = 6,
    dec = "上"
  },
  {
    type = "护符",
    name = "",
    defineID = -1,
    index = 12,
    dec = "上"
  }
}
local m_msg = {}
m_msg[1] = {
  x = 113,
  y = 28,
  msg1 = "#{PMF_20080530_10}",
  msg2 = "PMFTS_80917_5"
}
m_msg[2] = {
  x = 136,
  y = 67,
  msg1 = "#{PMF_20080530_11}",
  msg2 = "PMFTS_80917_3"
}
m_msg[3] = {
  x = 102,
  y = 48,
  msg1 = "#{PMF_20080530_12}",
  msg2 = "PMFTS_80917_6"
}
m_msg[4] = {
  x = 114,
  y = 67,
  msg1 = "#{PMF_20080530_13}",
  msg2 = "PMFTS_80917_1"
}
m_msg[5] = {
  x = 136,
  y = 28,
  msg1 = "#{PMF_20080530_14}",
  msg2 = "PMFTS_80917_2"
}
m_msg[6] = {
  x = 147,
  y = 48,
  msg1 = "#{PMF_20080530_15}",
  msg2 = "PMFTS_80917_4"
}

local function PMF_InitData()
  m_finish = {
    hdb = false,
    stg = false,
    wld = false,
    rps = false,
    lqs = false
  }
  m_boss = {
    ["哈大霸"] = {x = 124, y = 87},
    ["桑土公"] = {
      x = 40,
      y = 105,
      isstart = false
    },
    ["乌老大"] = {x = 116, y = 50},
    ["不平道人"] = {
      x = 125,
      y = 35,
      isstart = false
    },
    ["任平生"] = {x = 125, y = 40},
    ["李秋水"] = {
      x = 125,
      y = 40,
      isstart = false,
      waittimeout = -1,
      lasthp = -1,
      findposidx = 1
    }
  }
end

local function PMF_RefreshStep()
  local tObj = Enum2XByName(" 哈大霸" .. m_param.bossNameBZ .. " 碧磷僵尸 桑土公" .. m_param.bossNameBZ .. " 乌老大" .. m_param.bossNameBZ .. " 不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
    0,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 and 0 == tObj[1].hp then
    if tObj[1].name == "哈大霸" .. m_param.bossNameBZ then
      m_finish.hdb = true
    elseif tObj[1].name == "桑土公" .. m_param.bossNameBZ then
      m_finish.stg = true
    elseif tObj[1].name == "乌老大" .. m_param.bossNameBZ then
      m_finish.wld = true
    elseif tObj[1].name == "任平生" .. m_param.bossNameBZ then
      m_finish.wld = true
      m_finish.rps = true
    elseif tObj[1].name == "李秋水" .. m_param.bossNameBZ then
      m_finish.wld = true
      m_finish.rps = true
      m_finish.lqs = true
    end
  end
end

local function PMF_LiQiuShui_DaQun_Refresh()
  local nowtick = GetTickCount()
  local nowTime = os.time()
  local timeOut = 15
  local dq = {}
  local tmp = {
    find = false,
    msg = "",
    msgtime = -1,
    dst = -1,
    x = -1,
    y = -1
  }
  for i = 1, 6 do
    local msgTime, msgText, msgTick = IsInDebugMsg(m_msg[i].msg1)
    if msgTime and timeOut > nowTime - msgTime then
      table.insert(dq, {
        msg = "类型1",
        msgtime = msgTime,
        x = m_msg[i].x,
        y = m_msg[i].y
      })
    end
  end
  for i = 1, 6 do
    local msgTime, msgText, msgTick = IsInDebugMsg(m_msg[i].msg2)
    if msgTime and timeOut > nowTime - msgTime then
      local bIsIn = false
      for j = 1, #dq do
        if m_msg[i].x == dq[j].x and m_msg[i].y == dq[j].y then
          bIsIn = true
          break
        end
      end
      if false == bIsIn then
        table.insert(dq, {
          msg = "类型2",
          msgtime = msgTime,
          x = m_msg[i].x,
          y = m_msg[i].y
        })
      end
    end
  end
  BubbleSort(dq, "msgtime", 2)
  return dq
end

local function PMF_LiQiuShui_DaQun(bIsCallBack)
  local tdq = PMF_LiQiuShui_DaQun_Refresh()
  local bDaQun = false
  if #tdq > 0 then
    m_finish.hdb = true
    m_finish.stg = true
    m_finish.wld = true
    m_finish.rps = true
    if bIsCallBack then
      PushDebugMessage("李秋水大雾")
    else
      PushDebugMessage("李秋水大群")
    end
  end
  while #tdq > 0 do
    bDaQun = true
    local xDst, yDst = tdq[1].x, tdq[1].y
    local nTimeDiff = os.time() - tdq[1].msgtime
    if -1 == Player:GetBuff("失明：") then
      local bUsePetSkill = false
      local bNext = true
      if nTimeDiff > 12 then
        if -1 ~= Player:GetBuff("无法使用任何攻击技能") then
          RunTo(125, 40, 1, 500)
          bNext = false
        end
      elseif nTimeDiff > 6 and nTimeDiff <= 12 and GetDist(xDst, yDst) > 2 then
        bUsePetSkill = WuDiSkill()
        if bUsePetSkill then
          local selfpos = Player:GetPos()
          GetLuaValue(fmt("AutoRunToTarget(%d, %d);", math.floor(selfpos.x), math.floor(selfpos.y)))
          Sleep(100)
          Skill:UsePetSkill("高级神佑", nil, nil, 300)
        end
      end
      if bNext then
        if GetDist(xDst, yDst) > 1 then
          if false == bUsePetSkill then
            local pos = {x = xDst, y = yDst}
            if -1 == Player:GetBuff("无敌") and -1 == Player:GetBuff("神佑") then
              FastRun(pos, 3)
            else
              RunTo(pos.x, pos.y, 0, 200)
            end
          end
        elseif not bIsCallBack then
          FubenAttack(-1)
        end
      end
    else
      StateRemoveBad(true, false, false, false)
      if nTimeDiff > 6 and nTimeDiff <= 12 and GetDist(xDst, yDst) > 2 then
        WuDiSkill()
      end
    end
    Sleep(200)
    DebugStr("躲避李秋水大群 " .. tdq[1].msg, 3)
    tdq = PMF_LiQiuShui_DaQun_Refresh()
  end
  if bDaQun then
    PushDebugMessage("躲李秋水群结束")
    RunTo(125, 40, 1, 500)
  end
  return bDaQun
end

local function PMF_GoBit_Border_LiQiuShui(pos)
  local x = pos.x
  local y = pos.y
  if not (x > 92 and x < 157 and y > 28 and y < 69) or x < 103 and y < 35 then
  elseif x < 111 and y < 31 then
  elseif x > 137 and y < 31 then
  elseif x > 148 and y < 34 then
  elseif x > 119 and x < 130 and y > 42 and y < 53 then
  else
    return true
  end
  return false
end

local function PMF_OnOther()
  local function _CheckLQS()
    local tdq = PMF_LiQiuShui_DaQun_Refresh()
    
    if #tdq > 0 then
      PushDebugMessage("等待李秋水大群后复活或出窍")
      Sleep(1000)
    end
    return 0 == #tdq
  end
  
  local function _Refresh()
    PMF_RefreshStep()
    local selfpos = Player:GetPos()
    if m_finish.rps and false == PMF_GoBit_Border_LiQiuShui(selfpos) then
      PushDebugMessage("缥缈峰：李秋水死亡,此坐标死亡自动出窍")
      DieRelive(-1)
    end
  end
  
  local isDie, errScene = FuBenCheckDie(m_param.swcq, true, _CheckLQS, _Refresh)
  if isDie or errScene then
    return true
  end
  return false
end

local function PMF_cb_fuben(fX, fY, nScene)
  if IsInDebugMsgTime("你现在不能移动", false, 2) then
    if IsMount() == false then
      FubenAttack(-1)
    end
    return false
  end
  if 95 == fX and 39 == fY then
    Player:TeamFollow(false, 300)
  end
  if false == FubenCheckSceneDie(m_param.sceneID) then
    return false
  end
  PickUpLua(nil, true, true)
  if not m_param.msqs then
    PMF_LiQiuShui_DaQun()
  end
  if fX < 110 or fY < 80 then
    local nDiff = GetChangeSceneTimeDiff()
    if nDiff < 30 then
      PushColorMsg("缥缈峰：刚进入副本,进度重置")
      PMF_InitData()
      return false
    end
  end
  return true
end

local function PMF_cb_findLiQiuShui(fX, fY, nScene)
  if PMF_cb_fuben(fX, fY, nScene) then
    local tObj = Enum2XByName("李秋水 李秋水" .. m_param.bossNameBZ, {
      1,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      RunTo(tObj[1].x, tObj[1].y, 1, 400)
      return false
    end
    return true
  end
  return false
end

local function PMF_cb_stg(fX, fY, nScene)
  PickUpLua(nil, true, true)
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false
  end
  local tObj = Enum2XByName("桑土公 桑土公" .. m_param.bossNameBZ, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    return false
  end
  if false == IsMount() then
    local pos = Player:GetPos()
    if pos.x > 45 and pos.y > 90 then
      UseMount()
    end
  end
  return true
end

local function PMF_cb_findBoss(fX, fY, nScene)
  local tObj = Enum2XByName(" 不平道人 卓不凡 任平生 李秋水  不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
    1,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    RunTo(tObj[1].x, tObj[1].y, 1, 500)
    return false
  end
  if not m_param.msqs then
    PMF_LiQiuShui_DaQun()
  end
  return PMF_cb_fuben(fX, fY, nScene)
end

local function PMF_flcb_stg(fX, fY, nScene)
  PickUpLua(nil, true, true)
  if FubenCheckSceneDie(m_param.sceneID) == false then
    return false, nil
  end
  local leader, isleader = Team:GetLeaderInfo()
  if leader and not isleader and leader.sceneID ~= m_param.sceneID then
    PushColorMsg("队长不在缥缈峰副本")
    m_finish.stg = true
    return false, nil
  end
  return MoveCallBack_GoToLeader(fX, fY, nScene)
end

local function PMF_CheckOver()
  local now = GetTickCount()
  local bossname = "李秋水"
  if -1 ~= m_boss[bossname].waittimeout then
    if now > m_boss[bossname].waittimeout then
      m_boss[bossname].waittimeout = -1
      MoveTo(m_boss[bossname].x, m_boss[bossname].y, -1, 3, true, nil, PMF_cb_findLiQiuShui)
      PMF_OnOther()
      local tObj = Enum2XByName(" 不平道人 卓不凡 任平生 李秋水 不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
        1,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tObj <= 0 then
        MoveToNPC("符敏仪", 158, 54, -1, 3, true, nil, PMF_cb_findBoss)
        PMF_OnOther()
        tObj = Enum2XByName(" 不平道人 卓不凡 任平生 李秋水 不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
          1,
          1,
          0,
          0
        }, {0, -1}, nil, 3)
        if #tObj <= 0 then
          Sleep(1500)
          if QuestFrameOptionClicked_Item("挑战不平道人和卓不凡", 1, 1000) == false then
            MoveToNPC("乌老大", 96, 41, -1, 3, true, nil, PMF_cb_findBoss)
            PMF_OnOther()
            tObj = Enum2XByName(" 不平道人 卓不凡 任平生 李秋水 不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
              1,
              1,
              0,
              0
            }, {0, -1}, nil, 3)
            if #tObj <= 0 then
              Sleep(1000)
              if false == QuestFrameOptionClicked_Item("决战李秋水？", 1, 800) then
                return true
              end
            else
              RunTo(tObj[1].x, tObj[1].y, 1, 600)
              return false
            end
          end
        else
          RunTo(tObj[1].x, tObj[1].y, 1, 600)
          return false
        end
      else
        RunTo(tObj[1].x, tObj[1].y, 1, 600)
        return false
      end
      MoveTo(m_boss[bossname].x, m_boss[bossname].y, -1, 3, true, nil, PMF_cb_fuben)
    else
      DebugStr("缥缈峰:将在" .. math.ceil((m_boss[bossname].waittimeout - now) / 1000) .. "秒后检查副本进度")
    end
  else
    local diff = 37000
    if false == m_finish.rps then
      diff = 45000
    end
    m_boss[bossname].waittimeout = now + diff
  end
  return false
end

local function PMF_FindBoss(xBoss, yBoss, bossname)
  local bFind = false
  for i = 1, 5 do
    PickUpLua(nil, true, true)
    local cb_timeOut = PMF_cb_fuben
    if "李秋水" == bossname then
      local tickOld = GetTickCount()
      
      function cb_timeOut(aX, aY, aSceneID)
        if GetTickCount() - tickOld > 30000 then
          PushColorMsg("寻路超时!")
          return false
        end
        return PMF_cb_fuben(aX, aY, aSceneID)
      end
    end
    MoveTo(xBoss, yBoss, -1, 3, true, nil, cb_timeOut)
    PMF_OnOther()
    if bossname == "不平道人" .. m_param.bossNameBZ or bossname == "卓不凡" .. m_param.bossNameBZ or bossname == "任平生" .. m_param.bossNameBZ or bossname == "李秋水" .. m_param.bossNameBZ then
      break
    end
    local tObj = Enum2XByName(bossname, {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      if tObj[1].name == "乌老大" and 117 ~= math.floor(tObj[1].x) then
        return false
      end
      return true
    else
      if "乌老大" == bossname or bossname == "乌老大" .. m_param.bossNameBZ then
        xBoss = 108
        yBoss = 45
      end
      if bossname == "哈大霸" .. m_param.bossNameBZ and IsInDebugMsgTime("你现在不能移动", false, 6) then
        bFind = true
      end
    end
    tObj = Enum2XByName("碧磷僵尸", {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 and bossname == "桑土公" .. m_param.bossNameBZ then
      return true
    end
    PushDebugMessage("寻找Boss:" .. bossname)
    if i >= 2 and "桑土公" == bossname then
      break
    end
    Sleep(1000)
  end
  return bFind
end

local function PMF_HDB_bbsh()
  if m_param.holdboss and 8 == g_self.menpai then
    local tObj = Enum2XByName("哈大霸", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      local skill = Skill:GetSkillByName("步步生花")
      if skill and Skill:CanUseSkill(skill) then
        local tmp = tObj[1]
        RunTo(tmp.x, tmp.y, 0, 300)
        PlayerStateTimeOut(2, 3)
        Dismount()
        Sleep(300)
        Skill:UseName("步步生花", 300)
        Skill:UseName("定海神针", 500)
      end
    end
  end
end

local function PMF_OnBossNPC(bossname)
  local pos = m_boss[bossname]
  local bLeaderInit = false
  
  local function _HDB_Pos(aBossName)
    if "哈大霸" == aBossName then
      if IsInDebugMsgTime("战斗5秒钟后开始", false, 6) then
        PMF_HDB_bbsh()
      end
      if (g_self.isjingong == false or m_param.xiaohao) and (not m_param.holdboss or 8 ~= g_self.menpai or IsInDebugMsgTime("战斗2秒钟后开始", false, 6)) then
        local zero = {x = 124, y = 91}
        TeamDispersedStations(zero, 7)
        PlayerStateTimeOut(2, 5)
      end
    end
  end
  
  while true do
    local tObj = Enum2XByName(bossname, {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if not (#tObj > 0) or tObj[1].name == "乌老大" and 117 ~= math.floor(tObj[1].x) then
      break
    end
    bLeaderInit = true
    PMF_OnOther()
    Dismount()
    if Player:IsLeader() then
      local function _IsNpc()
        local tObj = Enum2XByName(" 哈大霸 桑土公 乌老大 ", {
          1,
          
          0,
          0,
          0
        }, nil, nil, 3)
        if #tObj > 0 then
          return true
        end
        return false
      end
      
      CheckAllTeamHP(80, _IsNpc, 35)
      if IsTeamSteady() then
        MoveToNPC(bossname, pos.x, pos.y, -1, 1, nil, nil, PMF_cb_fuben)
        if QuestFrameOptionClicked_Item("挑战", 1, 600) and "哈大霸" == bossname then
          PMF_HDB_bbsh()
        end
        local strText = GetNPCEventList_Item(0)
        if string.find(strText, "#{PMF_20080521_09}", nil, true) or string.find(strText, "#{PMF_20080521_11}", nil, true) then
          if "桑土公" == bossname then
            PushColorMsg("哈大霸还没杀完!")
            m_finish.hdb = false
            MoveTo(m_boss["哈大霸"].x, m_boss["哈大霸"].y, -1, 3, true, nil, PMF_cb_fuben)
          elseif "乌老大" == bossname or bossname == "乌老大" .. m_param.bossNameBZ then
            PushColorMsg("桑土公还没杀完!")
            m_finish.hdb = false
            m_finish.stg = false
            MoveTo(m_boss["桑土公"].x, m_boss["桑土公"].y, -1, 3, true, nil, PMF_cb_fuben)
          end
        end
      end
    else
      if "桑土公" == bossname or "乌老大" == bossname or bossname == "桑土公" .. m_param.bossNameBZ or bossname == "乌老大" .. m_param.bossNameBZ then
        while not Player:IsLeader() and GetSceneID() == m_param.sceneID do
          local tTmp = Enum2XByName(" 哈大霸" .. m_param.bossNameBZ .. " 桑土公" .. m_param.bossNameBZ .. " 碧磷僵尸 乌老大" .. m_param.bossNameBZ .. " 不平道人" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
            0,
            1,
            0,
            0
          }, nil, nil, 3)
          if #tTmp > 0 then
            if tTmp[1].name == "哈大霸" .. m_param.bossNameBZ and tTmp[1].hp > 0 then
              PushColorMsg("发现哈大霸,进度重置!")
              m_finish.hdb = false
              m_finish.stg = false
              break
            end
            if tTmp[1].name == "桑土公" .. m_param.bossNameBZ and tTmp[1].hp > 0 and bossname == "乌老大" .. m_param.bossNameBZ then
              PushColorMsg("发现桑土公,进度重置!")
              m_finish.hdb = true
              m_finish.stg = false
            end
            break
          else
            GoToLeader(PMF_flcb_stg)
          end
          tTmp = Enum2XByName("乌老大", {
            1,
            0,
            0,
            0
          }, nil, nil, 0)
          if #tTmp > 0 and 117 ~= math.floor(tTmp[1].x) then
            break
          end
          local leader, isleader = Team:GetLeaderInfo()
          if not leader or leader.sceneID ~= m_param.sceneID then
            PushColorMsg("缥缈峰：队长不在副本")
            break
          end
          Sleep(100)
          PMF_OnOther()
          FubenAttack(-1)
          DebugStr("跟随队长,等待boss开启!", 2)
        end
      end
      if "哈大霸" == bossname and IsInDebugMsgTime("战斗5秒钟后开始", false, 6) then
        PMF_HDB_bbsh()
      end
      _HDB_Pos(bossname)
    end
    FubenAttack(-1)
    goto lbl_299
    do break end
    ::lbl_299::
    DebugStr("等待Boss开启:" .. bossname)
    Sleep(200)
  end
  if bLeaderInit and Player:IsLeader() then
    _HDB_Pos(bossname)
  end
  return bLeaderInit
end

local function PMF_IsPullBoss(tObj)
  local tmp = FindObjByTID(tObj.id)
  if not tmp then
    return 0
  end
  local bpull = 0
  if m_param.xiaohao or m_param.holdboss and (0 == g_self.menpai or 8 == g_self.menpai) then
    bpull = 1
  end
  if 1 == m_param.fubentype then
    if (g_self.isjingong and Player:GetDataInt("MAXHP") < 180000 or g_self.isjingong == false and tmp.dst < 5) and Target:FindBuff(tmp, "悬枢之痛") then
      bpull = 2
    end
  elseif 2 == m_param.fubentype and tmp.name == "哈大霸" .. m_param.bossNameBZ and Target:FindBuff(tmp, "悬枢之痛") and (tmp.dst < 5 or tmp.target == Player:GetTID()) then
    bpull = 2
  end
  if 0 == bpull and Player:GetTID() == tmp.target and Player:GetHPP() < 35 then
    PushDebugMessage("哈大霸:低血远离boss")
    bpull = 1
  end
  return bpull
end

local function PMF_IsControlled(tObj)
  if m_param.xiaohao then
    return false
  end
  if 1 == m_param.fubentype or tObj.name == "碧磷僵尸" then
    if tObj.name == "哈大霸" .. m_param.bossNameBZ then
      if Target:FindBuff(tObj, "悬枢之痛") and (g_self.isjingong == false or tObj.dst <= 3) then
        DebugStr("哈大霸:悬枢之痛使用控制技能", 3)
        return Skill:UseKongZhi_fuben(tObj, true, true)
      end
    elseif tObj.name == "碧磷僵尸" then
      return Skill:UseKongZhi_fuben(tObj, true, true)
    end
  end
  return false
end

local function PMF_HoldBoss(tObj)
  if m_param.holdboss and 2 == m_param.fubentype then
    if 0 == g_self.menpai then
      local tmp = FindObjByTID(tObj.id)
      if tmp and tmp.target ~= Player:GetTID() then
        if tmp.dst < 8 then
          if Skill:UseSkillByName("灭此朝食", tObj.id, nil, nil, 200) == false and false == Skill:UseSkillByName("狮子吼", tObj.id, nil, nil, 200) and false == Skill:UseSkillByName("调虎离山 ", tObj.id, nil, nil, 200) then
            JinGongFarSkill(tObj.id)
          end
        else
          JinGongFarSkill(tObj.id, true)
          Skill:UseSkillByName("调虎离山", tObj.id, nil, nil, 200)
        end
      end
    elseif 8 == g_self.menpai then
      Skill:UseName("定海神针", 600)
      Skill:UseName("步步生花", 300)
    end
  end
end

local function PMF_HDB_pullrun(aPosNext, aPosAll, aTarget, aParam)
  local run = aPosNext
  if aParam and aParam.shunyi then
    BubbleByHP(aPosAll, 2)
    if Skill:UseShunYi(aPosAll[1].x, aPosAll[1].y) == false then
      if -1 ~= Player:GetBuff("无法移动") then
        if 75 == aTarget.level and aTarget.target == Player:GetTID() then
          Skill:UseName("初级隐遁", 200)
        end
      else
        Skill:UseSpeed()
      end
    else
      run = aPosAll[1]
    end
  elseif aParam and aParam.jiasu then
    Skill:UseSpeed()
  end
  if Skill:CheckUseQingGong(run.x, run.y) then
    PlayerStateTimeOut(3, 3, nil)
  elseif 3 ~= Player:GetState() then
    RunTo(run.x, run.y, 0, 200)
  end
  return run
end

local function PMF_OnHaDaBa()
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  local bossname = "哈大霸 哈大霸" .. m_param.bossNameBZ
  local xZero, yZero = 124, 91
  local xPick, yPick = xZero, yZero
  local bWaitPick = true
  local debugnote = ""
  local tObj = Enum2XByName(bossname, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    if tObj[1].class == "NPC" then
      PMF_OnBossNPC("哈大霸")
      Sleep(1000)
    else
      if (g_self.isjingong == false or m_param.xiaohao) and tObj[1].dst < 6 then
        local zero = {x = 124, y = 91}
        TeamDispersedStations(zero, 7)
        PlayerStateTimeOut(2, 5)
      end
      while #tObj > 0 do
        if 0 == tObj[1].hp then
          xPick, yPick = tObj[1].x, tObj[1].y
          RunTo(xPick, yPick, 3, 1000)
          Sleep(1000)
          m_finish = {
            hdb = true,
            stg = false,
            wld = false,
            rps = false,
            lqs = false
          }
          break
        end
        if PMF_OnOther() then
          break
        end
        PMF_IsControlled(tObj[1])
        PMF_HoldBoss(tObj[1])
        local npull = PMF_IsPullBoss(tObj[1])
        local bpull, pullpos
        local keepDist = 7
        if 0 ~= npull then
          local param = {}
          if 2 == npull or m_param.holdboss then
            param.shunyi = true
          end
          bpull, pullpos = FubenPullTarget(xZero, yZero, 7, tObj[1], keepDist, PMF_HDB_pullrun, param)
        end
        if 1 == m_param.fubentype then
          YinShenAsTarget(tObj[1], m_param.xiaohao, false)
        end
        local bUsePet = true
        if 2 == npull then
          bUsePet = false
          if 4 ~= g_self.menpai then
            CDG.pet3.GUID = 0
          end
          CDG.pet2.GUID = 0
        else
          CDG.pet2.GUID = bGuid2
          CDG.pet3.GUID = bGuid3
        end
        if bpull and keepDist > GetDist(tObj[1].x, tObj[1].y) then
          if -1 ~= Player:GetBuff("无法移动") then
            CDG:checktime0()
          end
        else
          debugnote = ""
          if not m_param.xiaohao then
            if 0 == g_self.menpai and m_param.holdboss then
              debugnote = " 少林拉怪"
              JinGongFarSkill(tObj[1].id)
              FubenAttack(-1, nil, nil, true, bUsePet)
            elseif g_self.isjingong and 2 == npull or g_self.isjingong and 2 == m_param.fubentype and Target:FindBuff(tObj[1], "悬枢之痛") then
              debugnote = "近攻暂时不打"
              if 0 == npull then
                FubenTrapRun("", 124, 91, 7, 15, tObj)
              end
              CDG:checktime0()
            else
              ZhiDianJiangShanObj(tObj[1], false)
              if tObj[1].target == Player:GetTID() then
                bUsePet = false
              end
              FubenAttack(tObj[1].id, nil, nil, true, bUsePet)
            end
          else
            FubenAttack(-1, nil, nil, true, bUsePet)
          end
        end
        Sleep(50)
        DebugStr("缥缈峰：" .. bossname .. " " .. debugnote)
        tObj = Enum2XByName(bossname, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
      end
    end
  else
    local bFind = PMF_FindBoss(xZero, yZero, bossname)
    if not bFind then
      bWaitPick = false
      m_finish = {
        hdb = true,
        stg = false,
        wld = false,
        rps = false,
        lqs = false
      }
    end
  end
  PickUpLua(nil, true, true)
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
  if m_finish.hdb then
    RelivePlayer(1, nil, nil, nil, nil, true)
    RelivePlayer(2, 99, 80, 145, 110, true)
    if bWaitPick then
      PickUpLua_Boss(nil, nil, nil, {
        {x = xPick, y = yPick}
      }, true, nil)
    end
    EatBindItem(3)
  end
  PickUpMust()
end

local function PMF_SangTuGongPos2(aIsAttack)
  local bOver = false
  local posOrg = {
    {
      x = 40,
      y = 105,
      index = 1
    },
    {
      x = 41,
      y = 86,
      index = 2
    },
    {
      x = 37,
      y = 60,
      index = 3
    },
    {
      x = 56,
      y = 69,
      index = 4
    },
    {
      x = 72,
      y = 66,
      index = 5
    }
  }
  local posArr = {
    {
      x = 40,
      y = 105,
      index = 1
    },
    {
      x = 41,
      y = 86,
      index = 2
    },
    {
      x = 37,
      y = 60,
      index = 3
    },
    {
      x = 56,
      y = 69,
      index = 4
    },
    {
      x = 72,
      y = 66,
      index = 5
    }
  }
  local xSang2, ySang2 = 72, 66
  if Player:IsLeader() then
    local bFind = false
    for i = 1, 3 do
      local tTmp = Enum2XByName("桑土公 桑土公" .. m_param.bossNameBZ, {
        1,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tTmp > 0 then
        bFind = true
        break
      end
      Sleep(600)
      if -1 == Player:GetBuff("隐身") and IsMount() == false then
        FubenAttack(-1)
      end
    end
    if bFind then
      goto lbl_412
    end
    if m_param.stg_zw then
      local nFindCount = 2
      if aIsAttack then
        nFindCount = 30
      end
      for i = 1, 4 do
        local zwPos = GetAllPosDist(posArr, nil, "dst")
        BubbleByDst(zwPos)
        local nextPos = posOrg[zwPos[1].index + 1]
        nextPos = nextPos or posOrg[5]
        MoveTo(nextPos.x, nextPos.y, -1, 3, false, nil, PMF_cb_stg)
        Pet:Relax(300)
        if GetDist(nextPos.x, nextPos.y, xSang2, ySang2) < 5 then
          nFindCount = 30
        end
        PMF_OnOther()
        for i = 1, nFindCount do
          Dismount()
          local tTmp = Enum2XByName("桑土公 桑土公" .. m_param.bossNameBZ, {
            1,
            1,
            0,
            0
          }, nil, nil, 3)
          if #tTmp > 0 then
            bFind = true
            break
          else
          end
          if -1 == Player:GetBuff("隐身") then
            FubenAttack(-1)
            RelivePlayer(1, nil, nil, nil, nil, true)
          end
          PMF_OnOther()
          local selftid = Player:GetTID()
          local pettid = Pet:GetTID()
          local tObj = Enum2XByName("碧磷僵尸", {
            0,
            1,
            0,
            0
          }, nil, nil, 0)
          for i = 1, #tObj do
            if tObj[i].target == selftid and -1 == Player:GetBuff("隐身") then
              Skill:UseName("初级隐遁", 800)
            end
            if tObj[i].target == pettid then
              Pet:Relax(300)
            end
          end
          local pos = Player:GetPos()
          if pos.x > 105 then
            break
          end
          Sleep(1000)
          DebugStr("等待桑土公")
        end
        if bFind then
          break
        end
        local pos = Player:GetPos()
        if pos.x > 105 or GetDist(nextPos.x, nextPos.y, xSang2, ySang2) < 5 then
          break
        end
      end
      if not bFind then
        bOver = true
      end
    else
      MoveTo(xSang2, ySang2, -1, 3, false, nil, PMF_cb_stg)
      Pet:Relax(300)
      PMF_OnOther()
      for i = 1, 30 do
        Dismount()
        local tTmp = Enum2XByName("桑土公 碧磷僵尸 桑土公" .. m_param.bossNameBZ, {
          1,
          1,
          0,
          0
        }, nil, nil, 3)
        if #tTmp > 0 then
          bFind = true
          break
        end
        if -1 == Player:GetBuff("隐身") then
          FubenAttack(-1)
          RelivePlayer(1, nil, nil, nil, nil, true)
        end
        PMF_OnOther()
        local pos = Player:GetPos()
        if pos.x > 105 then
          break
        end
        Sleep(1000)
        DebugStr("等待桑土公")
      end
      if not bFind then
        bOver = true
      end
    end
  else
    local tTmp = Enum2XByName("乌老大" .. m_param.bossNameBZ .. " 不平道人" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ, {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tTmp > 0 then
      PushColorMsg("桑土公：发现其他boss：" .. tTmp[1].name)
      bOver = true
    else
      local tTmp = Enum2XByName("桑土公 桑土公" .. m_param.bossNameBZ, {
        1,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tTmp > 0 then
      else
        Pet:Relax(300)
        GoToLeader(PMF_flcb_stg)
      end
    end
  end
  ::lbl_412::
  return bOver
end

local function PMF_OnSangTuGong()
  local bossname = "桑土公"
  local debugnote = ""
  local bWaitPick = true
  local tTmp = Enum2XByName("桑土公 碧磷僵尸 桑土公" .. m_param.bossNameBZ .. " 碧磷僵尸", {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  local xPick, yPick = -1, -1
  if #tTmp > 0 then
    if tTmp[1].class == "NPC" then
      PMF_OnBossNPC(bossname)
    else
      ::lbl_32::
      do
        local tObj = Enum2XByName(tTmp[1].name, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          if 0 == tObj[1].hp then
            xPick, yPick = tObj[1].x, tObj[1].y
            RunTo(xPick, yPick, 3, 1000)
            Sleep(1000)
            m_finish = {
              hdb = true,
              stg = true,
              wld = false,
              rps = false,
              lqs = false
            }
          elseif not PMF_OnOther() then
            ZhiDianJiangShanObj(tObj[1], false)
            FubenAttack(tObj[1].id)
            else
              PMF_OnOther()
              if PMF_SangTuGongPos2(true) then
                bWaitPick = false
                m_finish = {
                  hdb = true,
                  stg = true,
                  wld = false,
                  rps = false,
                  lqs = false
                }
                goto lbl_331
              end
              if m_param.stg_zw then
                local selftid = Player:GetTID()
                local pettid = Pet:GetTID()
                tObj = Enum2XByName("碧磷僵尸", {
                  0,
                  1,
                  0,
                  0
                }, nil, nil, 0)
                for i = 1, #tObj do
                  if tObj[i].target == selftid and -1 == Player:GetBuff("隐身") then
                    Skill:UseName("初级隐遁", 800)
                    break
                  end
                  if tObj[i].target == pettid then
                    Pet:Relax(300)
                  end
                end
              else
                local selftid = Player:GetTID()
                tObj = Enum2XByName("碧磷僵尸", {
                  0,
                  1,
                  0,
                  0
                }, nil, nil, 0)
                if #tObj > 0 then
                  local bIsKZ = false
                  for i = 1, #tObj do
                    if tObj[i].target == selftid and -1 == Player:GetBuff("隐身") then
                      if false == Skill:UseName("初级隐遁", 500) and PMF_IsControlled(tObj[i]) then
                        bIsKZ = true
                        Target:StopAttack(350)
                      end
                      break
                    end
                  end
                  if false == bIsKZ and Player:GetHP() > 80000 and -1 == Player:GetBuff("隐身") then
                    math.randomseed(GetTickCount() + g_self.guid)
                    local idx = math.random(1, #tObj)
                    if PMF_IsControlled(tObj[idx]) then
                      bIsKZ = true
                      Target:StopAttack(350)
                    end
                  end
                  if 7 == g_self.menpai and GetDist(72, 66) < 5 and -1 == Player:GetBuff("隐身") then
                    Skill:UseName("十面埋伏", 800)
                  end
                end
              end
              if -1 == Player:GetBuff("隐身") then
                FubenAttack(-1)
              else
              end
            end
            Sleep(100)
            DebugStr("缥缈峰：" .. bossname .. " " .. debugnote)
            goto lbl_32
          end
      end
    end
  else
    local bFind = false
    if false == m_boss[bossname].isstart or Player:IsLeader() then
      bFind = PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
    end
    if not bFind then
      m_boss[bossname].isstart = true
      if PMF_SangTuGongPos2(false) then
        bWaitPick = false
        m_finish = {
          hdb = true,
          stg = true,
          wld = false,
          rps = false,
          lqs = false
        }
      end
    end
  end
  ::lbl_331::
  PickUpLua(nil, true, true)
  if m_finish.stg then
    RelivePlayer(1, nil, nil, nil, nil, true)
    if bWaitPick then
      PickUpLua_Boss(nil, nil, nil, {
        {x = xPick, y = yPick}
      }, true, nil)
    end
    EatBindItem(3)
  end
  PickUpMust()
end

local function PMF_WuLaoDaChangeEquip(bChangeTao)
  if not m_param.take_dkt then
    return
  end
  for i = 1, #m_equip do
    if m_equip[i].defineID <= 0 then
      local strText = fmt([[
                    local ActionIndex = EnumAction(%d, "equip");
                    --local defineID = ActionIndex:GetDefineID()
                    local ItemTableIndex = ActionIndex:GetItemTableIndex()
                    return ItemTableIndex
                ]], m_equip[i].index)
      m_equip[i].defineID = GetLuaValue(strText, "n")
    end
  end
  if bChangeTao then
    TempBank2Bag(" 碧玉腰环 碧玉戒指 碧玉护符 碧玉护腕 ", 2)
    for i = 1, 4 do
      if TempBank2Bag(" 碧玉腰环 碧玉戒指 碧玉护符 碧玉护腕 ", 2) == false then
        break
      end
      Sleep(200)
    end
    PushDebugMessage("装备：换已绑定的碧玉套...")
    local tItem = Bag:EunmBindItem(nil, Bag:EnumDaoJuItem())
    for i = 1, #tItem do
      local tmp = tItem[i]
      if tmp.name == "碧玉腰环" or tmp.name == "碧玉戒指" or tmp.name == "碧玉护符" or tmp.name == "碧玉护腕" then
        Bag:ItemBtnClicked(tmp.index)
      end
    end
  end
  if not bChangeTao then
    local tItem = Bag:EnumDaoJuItem()
    for i = 1, #tItem do
      local tmp = tItem[i]
      for j = 1, #m_equip do
        if tmp.itemIndex > 0 and m_equip[j].defineID == tmp.itemIndex then
          Bag:ItemBtnClicked(tmp.index)
          break
        end
      end
    end
  end
end

local function PMF_WLD_ClearMsg()
  DeleteDebugMsg("你获得经验")
  DeleteDebugMsg("#{PMF_20080521_13}")
end

local function PMF_WuLaoDaDuoQun()
  local nTick = GetTickCount()
  local nOutTick = 420000
  local bossname = "乌老大 乌老大" .. m_param.bossNameBZ
  local isRun = true
  while m_param.ddq or m_param.xiaohao do
    isRun = true
    local tObj = Enum2XByName(bossname, {
      1,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      if 0 == tObj[1].hp or tObj[1].class == "NPC" and 117 ~= math.floor(tObj[1].x) then
        PushDebugMessage("乌老大已被杀死")
        break
      end
      if tObj[1].class == "怪物" and tObj[1].target == Player:GetTID() then
        isRun = false
        if 2 == Player:GetState() then
          Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 500)
          local pos = Player:GetPos()
          RunTo(pos.x - 1, pos.y + 1, 0, 500)
        end
      end
    end
    if PMF_OnOther() then
      break
    end
    local nMsgTime = IsInDebugMsg("你获得经验")
    nMsgTime = nMsgTime or IsInDebugMsg("#{PMF_20080521_13}")
    if nMsgTime then
      PushDebugMessage("乌老大:已完成,前往捡包")
      MoveTo(108, 54, -1, 3, true, nil, PMF_cb_fuben)
      PickUpMust()
      break
    end
    tObj = Team:GetAllMemberInfo()
    for i = 1, #tObj do
      if tObj[i].x >= 119 and tObj[i].y < 70 then
        PushColorMsg("有队员离开乌老大战斗区域,检查boss是否死亡.")
        MoveTo(110, 50, -1, 3, true, nil, PMF_cb_fuben)
        PickUpMust()
        break
      end
    end
    Sleep(1000)
    if isRun and RunTo(78, 65, 0, 1000) == false then
      FubenAttack(-1, nil, nil, true)
    end
    local nDiffTick = GetTickCount() - nTick
    if nOutTick < nDiffTick then
      MoveTo(110, 50, -1, 3, true, nil, PMF_cb_fuben)
      PickUpMust()
      break
    end
    DebugStr("缥缈峰：躲避乌老大毒群,%d秒后检测超时", 1, math.floor((nOutTick - nDiffTick) / 1000))
  end
end

local function PMF_OnWuLaoDa()
  if not m_finish.wld then
    PMF_WuLaoDaChangeEquip(true)
  end
  local bossname = "乌老大"
  local debugnote = ""
  local xPick, yPick = m_boss[bossname].x, m_boss[bossname].y
  local bWaitPick = true
  local tTmp = Enum2XByName("乌老大 乌老大" .. m_param.bossNameBZ, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tTmp > 0 then
    if tTmp[1].class == "NPC" and 117 == math.floor(tTmp[1].x) then
      GivePlayerState("百毒不侵", 5)
      if m_param.ddq or m_param.xiaohao then
        PMF_WLD_ClearMsg()
      end
      PMF_OnBossNPC(bossname)
      Sleep(1000)
    elseif tTmp[1].class == "NPC" and 117 ~= math.floor(tTmp[1].x) then
      bWaitPick = false
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = false,
        lqs = false
      }
    else
      while true do
        local tObj = Enum2XByName(tTmp[1].name, {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if not (#tObj > 0) then
          break
        end
        if 0 == tObj[1].hp then
          xPick, yPick = tObj[1].x, tObj[1].y
          RunTo(xPick, yPick, 3, 1000)
          Sleep(1000)
          m_finish = {
            hdb = true,
            stg = true,
            wld = true,
            rps = false,
            lqs = false
          }
          break
        end
        if m_param.ddq or m_param.xiaohao then
          PMF_WLD_ClearMsg()
          PMF_WuLaoDaDuoQun()
        end
        if not PMF_OnOther() then
          if m_param.xiaohao or false == g_self.isjingong or g_self.isjingong and tObj[1].target == Player:GetTID() then
            if false == RunTo(108, 54, 1, 500) then
              ZhiDianJiangShanObj(tObj[1], false)
              FubenAttack(tObj[1].id)
            end
          else
            FubenAttack(tObj[1].id)
          end
        else
          break
        end
        Sleep(100)
        if DebugStr("缥缈峰：" .. bossname .. " " .. debugnote) then
          GivePlayerState("百毒不侵", 5, false)
        end
      end
      if m_param.xiaohao then
        MoveTo(m_boss[bossname].x, m_boss[bossname].y, -1, 3, true, nil, PMF_cb_fuben)
      end
    end
  else
    local bFind = PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
    if not bFind then
      bWaitPick = false
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = false,
        lqs = false
      }
    end
  end
  PickUpLua(nil, true, true)
  if m_finish.wld then
    RelivePlayer(2, 70, 19, 166, 73, true)
    RelivePlayer(2, 70, 19, 166, 73, true)
    PMF_WuLaoDaChangeEquip(false)
    if bWaitPick then
      PickUpLua_Boss(nil, nil, nil, {
        {x = xPick, y = yPick}
      }, true, nil)
    end
    EatBindItem(5)
  end
  PickUpMust()
end

local function PMF_OnBuPingDaoRen()
  PMF_WuLaoDaChangeEquip(false)
  local bossname = "不平道人"
  local namestr = " 不平道人 卓不凡 任平生 不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " "
  local debugnote = ""
  local tTmp = Enum2XByName(namestr, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tTmp > 0 then
    m_boss["李秋水"].waittimeout = -1
    ::lbl_31::
    do
      local tObj = Enum2XByName(namestr, {
        1,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tObj > 0 then
        do
          local bIsOver = false
          for i = 1, #tObj do
            if tObj[i].name == "任平生" .. m_param.bossNameBZ and 0 == tObj[i].hp then
              RunTo(tObj[i].x, tObj[i].y, 3, 1000)
              Sleep(1000)
              m_finish = {
                hdb = true,
                stg = true,
                wld = true,
                rps = true,
                lqs = false
              }
              bIsOver = true
              break
            end
          end
          if not bIsOver and not PMF_OnOther() then
            local bIsTarget = false
            for i = 1, #tObj do
              if tObj[i].name == "不平道人" .. m_param.bossNameBZ and tObj[i].hp > 0 then
                bIsTarget = true
                ZhiDianJiangShanObj(tObj[i], false)
                FubenAttack(tObj[i].id)
              end
            end
            if false == bIsTarget then
              for i = 1, #tObj do
                if tObj[i].hp > 0 then
                  bIsTarget = true
                  ZhiDianJiangShanObj(tObj[i], false)
                  FubenAttack(tObj[i].id)
                end
              end
            end
            if false == bIsTarget then
              debugnote = "没有找到目标" .. tObj[1].name .. " " .. tObj[1].hp
              FubenAttack(-1)
            else
              debugnote = ""
              goto lbl_153
              goto lbl_247
            end
            ::lbl_153::
            Sleep(100)
            DebugStr("缥缈峰：" .. bossname .. " " .. debugnote)
            goto lbl_31
          end
        end
      end
    end
  elseif false == m_boss["不平道人"].isstart and Player:IsLeader() then
    m_boss["不平道人"].isstart = true
    MoveToNPC("符敏仪", 158, 54, -1, nil, nil, nil, PMF_cb_fuben)
    Sleep(1000)
    if QuestFrameOptionClicked_Item("挑战不平道人和卓不凡", 1, 2000) then
      PushDebugMessage("挑战不平道人和卓不凡")
      Sleep(2000)
    else
      PushColorMsg("挑战boss李秋水")
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = true,
        lqs = false
      }
    end
  else
    if GetDist(m_boss[bossname].x, m_boss[bossname].y) < 15 then
      FubenAttack(-1)
    end
    PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
    if PMF_CheckOver() then
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = true,
        lqs = true
      }
    end
  end
  ::lbl_247::
  PickUpLua(nil, true, true)
  RelivePlayer(2, 79, 19, 166, 73, true)
  PickUpLua(nil, true, true)
end

local function PMF_OnZhuoBuFan()
  PMF_OnBuPingDaoRen()
end

local function PMF_OnRenPingSheng()
  PMF_OnBuPingDaoRen()
end

local function PMF_LiQiuShui_Find()
  local bossname = "李秋水"
  if m_boss[bossname].lasthp > 0 then
    local tObj = Enum2XByName("李秋水 李秋水" .. m_param.bossNameBZ, {
      1,
      1,
      0,
      0
    }, nil, nil, 3)
    if 0 == #tObj then
      if m_boss[bossname].findposidx > 4 then
        m_boss[bossname].findposidx = 1
      end
      if m_param.msqs then
        Skill:UseSpeed()
      end
      PushDebugMessage("寻找李秋水")
      if IsMount() == false then
        CDG:checktime0()
      end
      MoveTo(m_findqiushuipos[m_boss[bossname].findposidx].x, m_findqiushuipos[m_boss[bossname].findposidx].y, -1, 2, true, nil, PMF_cb_findLiQiuShui)
      m_boss[bossname].findposidx = m_boss[bossname].findposidx + 1
    end
  end
end

local function PMF_LQS_xj()
  local bSafe = true
  local tAllSpec = EnumUnSafeSpecial()
  local tSpecial = ObjFilterByName(tAllSpec, " 寒冰 ", 3)
  local tUnKnow = ObjFilterByName(tAllSpec, " 寒冰 ", 4)
  for i = 1, #tUnKnow do
    PushColorMsg("缥缈未知的陷阱：" .. tUnKnow[i].name)
  end
  if #tSpecial > 0 then
    local banjin = 7
    local param
    if g_self.isjingong and m_param.xiaohao == false then
      local bIsRun = false
      local tTmp = Enum2XByName("李秋水" .. m_param.bossNameBZ, {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tTmp > 0 then
        local tmp = tTmp[1]
        local selfPos = Player:GetPos()
        if tmp.dst > 2 or false == IsPosSafe(selfPos, tSpecial, banjin) then
          local posSafe = {}
          local allPos = GetRangeAllPos(tmp.x, tmp.y, 1, 2, tmp)
          for i = 1, #allPos do
            if IsPosSafe(allPos[i], tSpecial, banjin) and PMF_GoBit_Border_LiQiuShui(allPos[i]) then
              table.insert(posSafe, allPos[i])
            end
          end
          posSafe = ObjFilterByHP(posSafe, 2, 2)
          if #posSafe > 0 then
            BubbleByDst(posSafe, 1)
            bIsRun = true
            if GetDist(selfPos.x, selfPos.y, posSafe[1].x, posSafe[1].y) < 0.5 then
              bSafe = true
            else
              FubenRunSafe_easy(posSafe[1], posSafe, param)
              bSafe = false
            end
          else
          end
        end
      end
      if 0 == #tTmp or false == bIsRun then
        bSafe = FubenTrapRun("李秋水" .. m_param.bossNameBZ, 124.5, 47.5, banjin, 15, tSpecial, PMF_GoBit_Border_LiQiuShui, FubenRunSafe_easy, nil, 6, param)
      end
    else
      bSafe = FubenTrapRun("李秋水" .. m_param.bossNameBZ, 124.5, 47.5, banjin, 15, tSpecial, PMF_GoBit_Border_LiQiuShui, FubenRunSafe_easy, nil, 6, param)
    end
  end
  return bSafe, tSpecial
end

local function PMF_LiQiuShui_cb()
  if not m_param.msqs then
    local bossname = "李秋水" .. m_param.bossNameBZ
    if false == PMF_LiQiuShui_DaQun(true) then
      PMF_LQS_xj()
    end
  end
  return true
end

local function PMF_LQS_bag()
  local bSafe, tSpecial = PMF_LQS_xj()
  if #tSpecial > 0 then
    for i = 1, 10 do
      local zero = {
        x = 124.5,
        y = 47.5,
        r = 14
      }
      local banjin = 7
      local bHas, bRun, bPick = SafeRunToPickBag(zero, tSpecial, banjin, PMF_GoBit_Border_LiQiuShui)
      if not bHas then
        break
      end
      PushDebugMessage("捡包:附近有陷阱！")
      if not bRun and not bPick then
        bSafe, tSpecial = PMF_LQS_xj()
        if 0 ~= #tSpecial then
        else
          break
        end
      end
      Sleep(1000)
      FubenAttack(-1)
    end
  end
  local tOrgObj = Enum2XByClass("包裹", nil, 1)
  if #tOrgObj > 0 then
    local tickOld = GetTickCount()
    
    local function cb_timeOut(aX, aY, aSceneID)
      if GetTickCount() - tickOld > 30000 then
        PushColorMsg("寻路超时")
        return false
      end
      return PMF_cb_fuben(aX, aY, aSceneID)
    end
    
    MoveTo(tOrgObj[1].x, tOrgObj[1].y, -1, nil, nil, nil, cb_timeOut)
  end
end

local function PMF_OnLiQiuShui()
  local bossname = "李秋水"
  local bWaitPick = true
  local shenyou = {idx = -1, GUID = -1}
  if not m_param.msqs then
    shenyou = PetSetFightShenYou()
  end
  CDG.call.back1 = PMF_LiQiuShui_cb
  local tTmp = Enum2XByName("李秋水 李秋水" .. m_param.bossNameBZ, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tTmp > 0 then
    m_boss["李秋水"].waittimeout = -1
    ::lbl_36::
    do
      local debugnote = ""
      if -1 ~= Player:GetBuff("无法使用任何攻击技能") then
        RunTo(125, 40, 1, 500)
      end
      local tObj = Enum2XByName("李秋水 李秋水" .. m_param.bossNameBZ, {
        1,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tObj > 0 then
        m_boss[bossname].lasthp = tObj[1].hp
        if 0 == tObj[1].hp then
          m_finish = {
            hdb = true,
            stg = true,
            wld = true,
            rps = true,
            lqs = true
          }
          RunTo(tObj[1].x, tObj[1].y, 3, 1000)
        else
          if tObj[1].hp < 33 and CDG.pet1.GUID ~= CDG.pet1.orgGUID then
            Pet:Relax(500)
            ChangeFightPet(false)
          end
          if not PMF_OnOther() then
            if not m_param.msqs then
              if false == PMF_LiQiuShui_DaQun() then
                ZhiDianJiangShanObj(tObj[1], false)
                local bSafe, tSpecial = PMF_LQS_xj()
                if bSafe then
                  if false == g_self.isjingong or 0 == #tSpecial or tObj[1].dst <= 2.5 then
                    FubenAttack(tObj[1].id, nil, nil, true, false)
                  else
                    debugnote = " 近攻暂不攻击"
                    JinGongFarSkill(tObj[1].id, false)
                  end
                else
                  FubenAttack(-1, nil, nil, true, false)
                end
              end
              if tObj[1].hp < 33 then
                StateRemoveBad(true, false, false, false)
              end
            else
              ZhiDianJiangShanObj(tObj[1], false)
              if tObj[1].hp < 66 then
                debugnote = " 集火秒杀"
                StateRemoveBad(true, false, false, false)
                if 4 == g_self.menpai then
                  FubenAttack(tObj[1].id, true, true, nil, false)
                else
                  FubenAttack(tObj[1].id, true, true, false, false)
                end
              else
                XiShanXingLv(tObj[1].id)
                do
                  local bSafe = PMF_LQS_xj()
                  if bSafe then
                    FubenAttack(tObj[1].id, false, false, true)
                  else
                    FubenAttack(-1, false, false, true)
                    goto lbl_235
                    goto lbl_422
                  end
                end
              end
            end
            ::lbl_235::
            Sleep(100)
            DebugStr("缥缈峰：" .. bossname .. " " .. debugnote)
            goto lbl_36
          end
        end
      end
    end
  else
    if m_boss[bossname].lasthp > 0 then
      if m_finish.lqs == false then
        FubenAttack(-1)
      end
      if GetDist(m_boss[bossname].x, m_boss[bossname].y) > 40 then
        PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
      end
    elseif m_finish.lqs == false then
      PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
    end
    if false == m_boss[bossname].isstart and Player:IsLeader() then
      RelivePlayer(2, 79, 19, 166, 73, true)
      if shenyou and -1 ~= shenyou.GUID and 0 ~= shenyou.GUID then
        DebugColorMsg("李秋水:检测到有神佑宝宝,自动使用", 2)
        CDG:checkPetPlay(shenyou.GUID)
      end
      if IsTeamSteady() then
        m_boss[bossname].isstart = true
        MoveToNPC("乌老大", 96, 41, -1, nil, nil, nil, PMF_cb_fuben)
        Sleep(1000)
        if QuestFrameOptionClicked_Item("决战李秋水？", 1, 500) then
        elseif FindQuestFrameOption("#{PMFCC_150105_1}") then
          m_finish = {
            hdb = true,
            stg = true,
            wld = true,
            rps = true,
            lqs = true
          }
        else
          PushColorMsg("未杀任平生?")
          m_finish = {
            hdb = true,
            stg = true,
            wld = true,
            rps = false,
            lqs = false
          }
        end
      end
    else
      if m_boss[bossname].lasthp < 0 then
        if shenyou and -1 ~= shenyou.GUID and 0 ~= shenyou.GUID then
          DebugColorMsg("李秋水:检测到有神佑宝宝,自动使用", 2)
          CDG:checkPetPlay(shenyou.GUID)
        end
        PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
        FubenAttack(-1)
      end
      if PMF_CheckOver() then
        bWaitPick = false
        m_finish = {
          hdb = true,
          stg = true,
          wld = true,
          rps = true,
          lqs = true
        }
      end
    end
  end
  ::lbl_422::
  PickUpLua(nil, true, true)
  if m_finish.lqs then
    FubenAttack(-1, nil, nil, true, false)
    RelivePlayer(2, 79, 19, 166, 73, true)
    tTmp = Enum2XByName(bossname, {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tTmp > 0 then
      PMF_FindBoss(tTmp[1].x, tTmp[1].y, bossname)
      PMF_LQS_bag()
      PickUpLua_Boss(15, 15, nil, {
        {
          x = tTmp[1].x,
          y = tTmp[1].y
        }
      }, true, nil)
    elseif bWaitPick then
      local selfpos = Player:GetPos()
      if selfpos.y > 80 then
        PushColorMsg("死亡后移动到李秋水坐标")
        PMF_FindBoss(m_boss[bossname].x, m_boss[bossname].y, bossname)
      end
      PMF_LQS_bag()
      PickUpLua_Boss(15, 15, nil, m_findqiushuipos, true, nil)
    end
    PickUpMust()
  else
    if not m_param.msqs then
      PMF_LiQiuShui_DaQun()
    end
    PMF_LiQiuShui_Find()
  end
  PickUpLua(nil, true, true)
  if not m_param.msqs then
    ChangeFightPet(false)
  end
  CDG.call.back1 = nil
end

local function PMF_Leave()
  PMF_LQS_bag()
  PickUpLua(nil, true, true)
  local tObj = Enum2XByName("乌老大 乌老大" .. m_param.bossNameBZ, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    local tmp = tObj[1]
    if 0 == tmp.menpai and 117 == math.floor(tmp.x) and 49 == math.floor(tmp.y) or 28 == tmp.menpai and tmp.hp > 0 then
      PushColorMsg("乌老大还未死亡")
      m_finish = {
        hdb = true,
        stg = true,
        wld = false,
        rps = false,
        lqs = false
      }
      return
    end
  end
  local tObj = Enum2XByName(" 不平道人 卓不凡 任平生 ", {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    PushColorMsg("任平生还未死亡")
    m_finish = {
      hdb = true,
      stg = true,
      wld = true,
      rps = false,
      lqs = false
    }
    return
  end
  tObj = Enum2XByName("李秋水" .. m_param.bossNameBZ, {
    0,
    1,
    0,
    0
  }, {0, -1}, nil, 0)
  if #tObj > 0 then
    PushColorMsg("李秋水还未死亡")
    m_finish = {
      hdb = true,
      stg = true,
      wld = true,
      rps = true,
      lqs = false
    }
    return
  end
  if Player:GetFightPetGUID() ~= CDG.pet1.GUID then
    Pet:Relax()
  end
  PMF_OnOther()
  FubenAttack(-1, nil, nil, true, false)
  Sleep(500)
  SDQY_HuoDong()
  RelivePlayer(2, 79, 19, 166, 73, true)
  Sleep(500)
  MoveToNPC("乌老大", 95, 39, -1, 3, true, nil, PMF_cb_fuben)
  PushColorMsg("缥缈峰:已完成")
  Sleep(300)
  local szText = GetNPCEventList_Item(0)
  if string.find(szText, "#{PMF_20080521_19}", nil, true) then
    if QuestFrameOptionClicked_Item("决战李秋水？", 1, 500) then
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = true,
        lqs = false
      }
    elseif QuestFrameOptionClicked_Item("#{PMFCC_150105_1}", 1, 800) then
      QuestFrameOptionClicked_Item("确定离开", 1, 1500)
      local strText = GetNPCEventList_Item(0)
      if "#{PMFCC_150105_2}" == strText then
        m_finish = {
          hdb = true,
          stg = true,
          wld = true,
          rps = true,
          lqs = false
        }
      end
    else
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = false,
        lqs = false
      }
    end
  end
end

local function PMF_OnStep()
  PickUpLua(nil, true, true)
  if m_finish.lqs then
    PMF_Leave()
    return
  end
  local tObj = Enum2XByName(" 哈大霸 碧磷僵尸 桑土公 乌老大 不平道人 卓不凡 任平生 李秋水 哈大霸" .. m_param.bossNameBZ .. " 碧磷僵尸" .. m_param.bossNameBZ .. " 桑土公" .. m_param.bossNameBZ .. " 乌老大" .. m_param.bossNameBZ .. " 不平道人" .. m_param.bossNameBZ .. " 卓不凡" .. m_param.bossNameBZ .. " 任平生" .. m_param.bossNameBZ .. " 李秋水" .. m_param.bossNameBZ .. " ", {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  for i = 1, #tObj do
    local tmp = tObj[i]
    if 0 == tmp.hp then
      if tmp.name == "哈大霸" .. m_param.bossNameBZ then
        m_finish = {
          hdb = true,
          stg = false,
          wld = false,
          rps = false,
          lqs = false
        }
        RelivePlayer(2, 99, 80, 145, 110, true)
      elseif tmp.name == "桑土公" .. m_param.bossNameBZ then
        m_finish = {
          hdb = true,
          stg = true,
          wld = false,
          rps = false,
          lqs = false
        }
      elseif tmp.name == "乌老大" .. m_param.bossNameBZ then
        m_finish = {
          hdb = true,
          stg = true,
          wld = true,
          rps = false,
          lqs = false
        }
      elseif tmp.name == "不平道人" .. m_param.bossNameBZ then
        m_finish.hdb = true
        m_finish.stg = true
        m_finish.wld = true
      elseif tmp.name == "卓不凡" .. m_param.bossNameBZ then
        m_finish.hdb = true
        m_finish.stg = true
        m_finish.wld = true
      elseif tmp.name == "任平生" .. m_param.bossNameBZ then
        m_finish = {
          hdb = true,
          stg = true,
          wld = true,
          rps = true,
          lqs = false
        }
      elseif tmp.name == "李秋水" .. m_param.bossNameBZ then
        m_finish = {
          hdb = true,
          stg = true,
          wld = true,
          rps = true,
          lqs = true
        }
      end
    end
  end
  local tAll = ObjFilterByHP(tObj, 0, 1)
  for i = 1, #tAll do
    local tmp = tAll[i]
    if tmp.name == "哈大霸" or tmp.name == "哈大霸" .. m_param.bossNameBZ then
      m_finish = {
        hdb = false,
        stg = false,
        wld = false,
        rps = false,
        lqs = false
      }
      PMF_OnHaDaBa()
      return
    elseif tmp.name == "碧磷僵尸" or tmp.name == "桑土公" or tmp.name == "碧磷僵尸" .. m_param.bossNameBZ or tmp.name == "桑土公" .. m_param.bossNameBZ then
      m_finish = {
        hdb = true,
        stg = false,
        wld = false,
        rps = false,
        lqs = false
      }
      PMF_OnSangTuGong()
      return
    elseif tmp.name == "乌老大" or tmp.name == "乌老大" .. m_param.bossNameBZ then
      if 0 == tmp.menpai and 117 == math.floor(tmp.x) and 49 == math.floor(tmp.y) or 28 == tmp.menpai then
        m_finish = {
          hdb = true,
          stg = true,
          wld = false,
          rps = false,
          lqs = false
        }
        PMF_OnWuLaoDa()
        return
      elseif 0 == tmp.menpai then
        m_finish.hdb = true
        m_finish.stg = true
        m_finish.wld = true
      end
    elseif tmp.name == "不平道人" or tmp.name == "不平道人" .. m_param.bossNameBZ then
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = false,
        lqs = false
      }
      PMF_OnBuPingDaoRen()
      return
    elseif tmp.name == "卓不凡" or tmp.name == "卓不凡" .. m_param.bossNameBZ then
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = false,
        lqs = false
      }
      PMF_OnZhuoBuFan()
      return
    elseif tmp.name == "任平生" or tmp.name == "任平生" .. m_param.bossNameBZ then
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = false,
        lqs = false
      }
      PMF_OnRenPingSheng()
      return
    elseif tmp.name == "李秋水" or tmp.name == "李秋水" .. m_param.bossNameBZ then
      m_finish = {
        hdb = true,
        stg = true,
        wld = true,
        rps = true,
        lqs = false
      }
      PMF_OnLiQiuShui()
      return
    end
  end
  local nDiff = GetChangeSceneTimeDiff()
  if nDiff < 20 then
    PushDebugMessage("缥缈峰:已进入副本")
    PMF_InitData()
    PMF_OnHaDaBa()
    return
  end
  if m_finish.lqs then
    PMF_Leave()
    return
  elseif m_finish.rps then
    PMF_OnLiQiuShui()
    return
  elseif m_finish.wld then
    PMF_OnBuPingDaoRen()
    return
  elseif m_finish.stg then
    PMF_OnWuLaoDa()
    return
  elseif m_finish.hdb then
    PMF_OnSangTuGong()
    return
  end
  PushDebugMessage("缥缈峰:未获取到副本进度,根据坐标获取进度")
  if GetDist(40, 106) < 8 then
    m_finish = {
      hdb = true,
      stg = false,
      wld = false,
      rps = false,
      lqs = false
    }
    PMF_OnSangTuGong()
    return
  end
  local pos = Player:GetPos()
  if pos.x > 79 and pos.x < 120 and pos.y < 77 then
    m_finish = {
      hdb = true,
      stg = true,
      wld = false,
      rps = false,
      lqs = false
    }
    PMF_OnWuLaoDa()
    return
  end
  if pos.x > 79 and pos.y < 77 then
    m_finish = {
      hdb = true,
      stg = true,
      wld = true,
      rps = false,
      lqs = false
    }
    PMF_OnBuPingDaoRen()
    return
  end
  PMF_OnHaDaBa()
end

function PMF_BankTakeOutBiYuTao(bIsTakeOut)
  if not bIsTakeOut then
    return
  end
  local bTimeOut = false
  for i = 1, 6 do
    Bag_DeleteItem()
    if 0 ~= #Bag:FindItemInfo("碧玉腰环", 2) and 0 ~= #Bag:FindItemInfo("碧玉戒指", 2) and 0 ~= #Bag:FindItemInfo("碧玉护符", 2) and 0 ~= #Bag:FindItemInfo("碧玉护腕", 2) then
      break
    end
    PushDebugMessage("碧玉套：先尝试锦囊取出 " .. i)
    if TempBank2Bag(" 碧玉腰环 碧玉戒指 碧玉护符 碧玉护腕 ", 2) == false then
      PushDebugMessage("前往仓库取出碧玉套 " .. i)
      do
        local _, bTimeOut = Bank_GetItem(" 碧玉腰环 碧玉戒指 碧玉护符 碧玉护腕 ", 5, 2, true)
        if bTimeOut then
          break
        end
      end
      goto lbl_69
      break
    end
    ::lbl_69::
    Sleep(500)
  end
end

function PMF_Start(param)
  m_param = param
  PMF_InitData()
  while GetSceneID() == m_param.sceneID do
    PMF_OnStep()
    PMF_OnOther()
    Sleep(100)
    DebugStr("缥缈峰副本中.", 2)
  end
  PMF_InitData()
end
