-- 反编译自 dfz64.dll 内嵌字节码 00322b14（unluac 2025-12-23；仅供分析）
local g_FuBenType = {
  [1] = 0,
  [2] = 0,
  [3] = 1,
  [4] = 1,
  [5] = 1,
  [6] = 0,
  [7] = 0,
  [8] = 0,
  [9] = 1,
  [10] = 1
}
local g_PosIndex = {
  [1] = {x = 1, z = 1},
  [2] = {x = 1, z = 2},
  [3] = {x = 1, z = 3},
  [4] = {x = 1, z = 4},
  [5] = {x = 1, z = 5},
  [6] = {x = 1, z = 6},
  [7] = {x = 2, z = 1},
  [8] = {x = 2, z = 2},
  [9] = {x = 2, z = 3},
  [10] = {x = 2, z = 4},
  [11] = {x = 2, z = 5},
  [12] = {x = 2, z = 6},
  [13] = {x = 3, z = 1},
  [14] = {x = 3, z = 2},
  [15] = {x = 3, z = 3},
  [16] = {x = 3, z = 4},
  [17] = {x = 3, z = 5},
  [18] = {x = 3, z = 6},
  [19] = {x = 4, z = 1},
  [20] = {x = 4, z = 2},
  [21] = {x = 4, z = 3},
  [22] = {x = 4, z = 4},
  [23] = {x = 4, z = 5},
  [24] = {x = 4, z = 6},
  [25] = {x = 5, z = 1},
  [26] = {x = 5, z = 2},
  [27] = {x = 5, z = 3},
  [28] = {x = 5, z = 4},
  [29] = {x = 5, z = 5},
  [30] = {x = 5, z = 6}
}
PushDebugMessage("设置副本通用参数")
local m_script_name = "凤凰陵墓-普通"
ScriptOnStart(m_script_name, true, true)
local m_param = {}
m_param.swcq = false
m_param.sceneID = 999
m_param.sceneName = "凤凰陵墓"
m_param.count_fhlm = g_config.team.count_fhlm
m_param.modelType_fhlm = 1
local fuben_over = false
npc = {
  {
    name = "杨建月",
    x = 54,
    y = 131,
    sceneID = 999
  },
  {
    name = "火凤石雕",
    x = 265,
    y = 265,
    sceneID = 999
  },
  {
    name = "暗冥乌犍",
    x = 265,
    y = 55,
    sceneID = 999
  },
  {
    name = "岩铸战将",
    x = 265,
    y = 55,
    sceneID = 999
  }
}
m_param.cPoint_fhlm = {
  25,
  26,
  20,
  19,
  13,
  14,
  8,
  7,
  1,
  2,
  3,
  4,
  10,
  9,
  15,
  16,
  22,
  21,
  27,
  28
}
local fhlm_step = 1
local fhlm_is_point = false
local boss_info_x = 0
local boss_info_y = 0

function BOSS_SY()
  PushColorMsg("霜影")
  while true do
    local sy_Obj = Enum2XByName("霜影", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if #sy_Obj > 0 then
      local tmp = sy_Obj[1]
      if tmp.class == "NPC" and "霜影" == tmp.name then
        boss_info_x = tmp.x
        boss_info_y = tmp.y
        if Player:IsLeader() then
          CheckAllTeamHP(85, nil, 30)
          TalkNpc("霜影")
          Sleep(2000)
          QuestFrameOptionClicked_Item("#{FHCL_240708_330}", 1, 1500)
          Sleep(1000)
          MessageBox_Self_OK_Clicked()
        end
        local boss_zero = {
          x = tmp.x,
          y = tmp.y,
          r = 15,
          rmin = 1,
          rmax = 15,
          name = ""
        }
        TeamDispersedStations(boss_zero, 7, Team:GetMemberCount())
        Sleep(2000)
        PushColorMsg("凤凰陵墓：等待队长开启霜影....")
      elseif tmp.class == "怪物" and "霜影" == tmp.name then
        FubenAttack(tmp.id)
        Sleep(200)
      end
    else
      PushColorMsg("凤凰陵墓：霜影已结束")
      return
    end
  end
end

function FHLM_FindSpecial_YZZJ()
  local tAllSpec = EnumUnSafeSpecial()
  local tObj = ObjFilterByName(tAllSpec, " 所向披靡简单 所向披靡困难 ", 3)
  local bSafe = true
  local param = {}
  param.useqg = true
  if #tObj > 0 then
    local r = 6
    if tObj[1].name == "所向披靡简单" or tObj[1].name == "所向披靡困难" then
      r = 5
    end
    return tObj, r
  end
  return {}, 0
end

function FHLM_TrapRun_YZZJ()
  local tSpec, r = FHLM_FindSpecial_YZZJ()
  local bSafe = true
  local param = {}
  param.useqg = true
  param.usesx = true
  if #tSpec > 0 then
    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, r, 15, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

function BOSS_YZZJ()
  boss_info_x = 0
  boss_info_y = 0
  PushColorMsg("岩铸战将")
  while FuBenCheckDie(false, true, FHLM_OnDie()) == false do
    local yzzj_Obj = Enum2XByName("岩铸战将", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #yzzj_Obj > 0 then
      local yzzj_tmp = yzzj_Obj[1]
      if 0 == boss_info_ or 0 == boss_info_y then
        boss_info_x = yzzj_tmp.x
        boss_info_y = yzzj_tmp.y
      end
      if yzzj_tmp.class == "NPC" and "岩铸战将" == yzzj_tmp.name then
        if Player:IsLeader() then
          CheckAllTeamHP(85, nil, 30)
          TalkNpc("岩铸战将")
          Sleep(2000)
          QuestFrameOptionClicked_Item("#{FHCL_240708_318}", 1, 1500)
          Sleep(1000)
          MessageBox_Self_OK_Clicked()
        end
        local boss_zero = {
          x = yzzj_tmp.x,
          y = yzzj_tmp.y,
          r = 15,
          rmin = 1,
          rmax = 15,
          name = ""
        }
        TeamDispersedStations(boss_zero, 7, Team:GetMemberCount())
        Sleep(1000)
        PushColorMsg("凤凰陵墓：等待队长开启岩铸战将....")
      else
        local bIsSafe, tSpecial = FHLM_TrapRun_YZZJ()
        if bIsSafe then
          local tObj = Enum2XByName("岩铸战将", {
            0,
            1,
            0,
            0
          }, {0, -1}, nil, 0)
          if #tObj > 0 then
            local tmp = tObj[1]
            local tid = tmp.id
            if 0 == #tSpecial and 6 == tmp.state then
              local param = {}
              param.useqg = false
              bIsSafe, _ = FubenTrapRun("", boss_info_x, boss_info_y, 10, 15, tObj, nil, FubenRunSafe, nil, nil, param)
              if bIsSafe then
                FubenAttack(-1)
              end
            else
              if #tSpecial > 0 then
                if g_self.isjingong then
                  if tmp.dst > 3 then
                    if tmp.dst <= 15 then
                      JinGongFarSkill(tmp.id)
                    end
                    tid = -1
                  end
                elseif tmp.dst > 15 then
                  RunTo(tmp.x, tmp.y)
                  tid = -1
                end
              end
              FubenAttack(tid)
              Sleep(200)
            end
          end
        else
          DebugStr("凤凰陵墓：岩铸战将躲避陷阱中", 2)
        end
      end
    else
      PushColorMsg("凤凰陵墓：岩铸战将已结束")
      Sleep(3000)
      return
    end
  end
end

function FHLM_FindSpecial_AMWJ()
  local tAllSpec = EnumUnSafeSpecial()
  local tObj = ObjFilterByName(tAllSpec, " 牛陷阱预警NPC 暗冥缠身陷阱简单 暗冥缠身陷阱困难 ", 3)
  local bSafe = true
  local param = {}
  param.useqg = true
  if #tObj > 0 then
    local r = 6
    if tObj[1].name == "牛陷阱预警NPC" then
      r = 6
    end
    if tObj[1].name == "暗冥缠身陷阱简单" then
      r = 6
    end
    if tObj[1].name == "暗冥缠身陷阱困难" then
      r = 6
    end
    return tObj, r
  end
  return {}, 0
end

function FHLM_TrapRun_AMWJ()
  local tSpec, r = FHLM_FindSpecial_AMWJ()
  local bSafe = true
  local param = {}
  param.useqg = true
  param.usesx = true
  if #tSpec > 0 then
    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, r, 15, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

function BOSS_AMWJ()
  boss_info_x = 0
  boss_info_y = 0
  PushColorMsg("暗冥乌犍")
  while FuBenCheckDie(false, true, FHLM_OnDie()) == false do
    local amwj_Obj = Enum2XByName("暗冥乌犍", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #amwj_Obj > 0 then
      local amwj_tmp = amwj_Obj[1]
      if 0 == boss_info_x or 0 == boss_info_y then
        boss_info_x = amwj_tmp.x
        boss_info_y = amwj_tmp.y
      end
      if amwj_tmp.class == "NPC" and "暗冥乌犍" == amwj_tmp.name then
        if Player:IsLeader() then
          CheckAllTeamHP(85, nil, 30)
          TalkNpc("暗冥乌犍")
          Sleep(2000)
          QuestFrameOptionClicked_Item("#{FHCL_240708_321}", 1, 1500)
          Sleep(1000)
          MessageBox_Self_OK_Clicked()
        end
        local boss_zero = {
          x = amwj_tmp.x,
          y = amwj_tmp.y,
          r = 15,
          rmin = 1,
          rmax = 15,
          name = ""
        }
        TeamDispersedStations(boss_zero, 7, Team:GetMemberCount())
        Sleep(1000)
        PushColorMsg("凤凰陵墓：等待队长开启暗冥乌犍....")
      else
        local bIsSafe, tSpecial = FHLM_TrapRun_AMWJ()
        if bIsSafe then
          local tObj = Enum2XByName("暗冥乌犍", {
            0,
            1,
            0,
            0
          }, {0, -1}, nil, 0)
          if #tObj > 0 then
            local tmp = tObj[1]
            local tid = tmp.id
            if 0 == #tSpecial and 6 == tmp.state then
              local param = {}
              param.useqg = false
              bIsSafe, _ = FubenTrapRun("", boss_info_x, boss_info_y, 10, 15, tObj, nil, FubenRunSafe, nil, nil, param)
              if bIsSafe then
                FubenAttack(-1)
              end
            else
              if -1 ~= Player:GetBuff("冥厄：") then
                local wj_Obj = Enum2XByClass("玩家", {0, -1})
                wj_Obj = ObjFilterByName(wj_Obj, g_self.name, 4)
                local param = {}
                param.useqg = false
                local bSafe, tSpecial = FubenTrapRun("", boss_info_x, boss_info_y, 12, 15, wj_Obj, nil, FubenRunSafe, nil, nil, param)
                if bSafe then
                  PushColorMsg("已远离队友!")
                end
              end
              if Player:IsJinGong() then
                if tmp.dst > 3 then
                  RunTo(tmp.x, tmp.y)
                end
              elseif tmp.dst > 15 then
                RunTo(tmp.x, tmp.y)
              end
              FubenAttack(tid)
              Sleep(200)
            end
          end
        else
          PushColorMsg("凤凰陵墓：暗冥乌犍躲避陷阱中")
        end
      end
    else
      PushColorMsg("凤凰陵墓：暗冥乌犍已结束")
      return
    end
  end
end

function FHLM_FindSpecial_ZLZH()
  local tAllSpec = EnumUnSafeSpecial()
  local tObj = ObjFilterByName(tAllSpec, " 裂地石阵陷阱简单 裂地石阵陷阱困难 ", 3)
  local bSafe = true
  if #tObj > 0 then
    local r = 6
    if tObj[1].name == "裂地石阵陷阱简单" then
      r = 6
    end
    if tObj[1].name == "裂地石阵陷阱困难" then
      r = 6
    end
    return tObj, r
  end
  return {}, 0
end

function FHLM_TrapRun_ZLZH()
  local tSpec, r = FHLM_FindSpecial_ZLZH()
  local bSafe = true
  local param = {}
  param.useqg = true
  param.usesx = true
  if #tSpec > 0 then
    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, r, 15, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

function BOSS_ZLZH()
  boss_info_x = 0
  boss_info_y = 0
  PushColorMsg("镇陵战魂")
  while FuBenCheckDie(false, true, FHLM_OnDie()) == false do
    local zlzh_Obj = Enum2XByName(" 镇陵战魂 涅槃：镇陵战魂 ", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if #zlzh_Obj > 0 then
      local zlzh_tmp = zlzh_Obj[1]
      if 0 == boss_info_x or 0 == boss_info_y then
        LogMsg("赋值")
        boss_info_x = zlzh_tmp.x
        boss_info_y = zlzh_tmp.y
      end
      if zlzh_tmp.class == "NPC" and "镇陵战魂" == zlzh_tmp.name then
        if Player:IsLeader() then
          CheckAllTeamHP(85, nil, 30)
          TalkNpc("镇陵战魂")
          Sleep(2000)
          QuestFrameOptionClicked_Item("#{FHCL_240708_331}", 1, 1500)
          Sleep(1000)
          MessageBox_Self_OK_Clicked()
        end
        local boss_zero = {
          x = zlzh_tmp.x,
          y = zlzh_tmp.y,
          r = 15,
          rmin = 1,
          rmax = 15,
          name = ""
        }
        TeamDispersedStations(boss_zero, 7, Team:GetMemberCount())
        PushColorMsg("凤凰陵墓：等待队长开启镇陵战魂....")
        Sleep(1000)
      else
        local bIsSafe, tSpecial = FHLM_TrapRun_ZLZH()
        if bIsSafe then
          local tObj = Enum2XByName(" 暗夜珠 耀光珠 ", {
            1,
            1,
            0,
            0
          }, {0, -1}, nil, 3)
          if #tObj > 0 then
            local tmp = tObj[1]
            FubenAttack(tmp.id)
            Sleep(200)
            if tmp.name == "暗夜珠" and -1 ~= Player:GetBuff("融光甲") then
              MoveTo(tmp.x, tmp.y)
              Sleep(200)
            end
            if tmp.name == "耀光珠" and -1 ~= Player:GetBuff("镇夜甲") then
              MoveTo(tmp.x, tmp.y)
              Sleep(200)
            end
          else
            local tObj = Enum2XByName(" 镇陵战魂 涅槃：镇陵战魂 ", {
              1,
              1,
              0,
              0
            }, {0, -1}, nil, 3)
            if #tObj > 0 then
              local tmp = tObj[1]
              if tmp.name == "涅槃：镇陵战魂" and 0 == tmp.hp then
                fuben_over = true
                break
              end
              local tid = tmp.id
              if 0 == #tSpecial and 6 == tmp.state then
                LogMsg("tmp.state == 6")
                local param = {}
                param.useqg = false
                bIsSafe, _ = FubenTrapRun("", boss_info_x, boss_info_y, 7, 15, tmp, nil, FubenRunSafe, nil, nil, param)
                if bIsSafe then
                  FubenAttack(-1)
                  Sleep(200)
                end
              else
                local bSafe = true
                local tyk_Obj = Enum2XByName("通用空npc", {
                  1,
                  0,
                  0,
                  0
                }, nil, 0, 0)
                if #tyk_Obj > 0 then
                  local shanxing = tyk_Obj[1]
                  bSafe = FubenShanXing(tmp, shanxing, 1, 45)
                end
                if bSafe then
                  local fucs_Obj = Enum2XByName("凤舞成双", {
                    1,
                    0,
                    0,
                    0
                  }, nil, 0, 0)
                  if #fucs_Obj > 0 then
                    local shanxing = fucs_Obj[1]
                    local param = {}
                    param.useqg = true
                    param.usesx = true
                    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, 5, 15, fucs_Obj, nil, FubenRunSafe, nil, nil, param)
                    if bSafe and Player:IsJinGong() then
                      JinGongFarSkill(tid)
                      Sleep(200)
                    end
                  end
                end
                if -1 ~= Player:GetBuff("镇夜甲") then
                  local hgfy_Obj = Enum2XByName("辉光凤影", {
                    1,
                    0,
                    0,
                    0
                  }, nil, 0, 0)
                  if #hgfy_Obj > 0 then
                    local shanxing = hgfy_Obj[1]
                    local param = {}
                    param.useqg = true
                    param.usesx = true
                    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, 8, 20, hgfy_Obj, nil, FubenRunSafe, nil, nil, param)
                  end
                else
                  local ayfy_Obj = Enum2XByName("暗夜凰影", {
                    1,
                    0,
                    0,
                    0
                  }, nil, 0, 0)
                  if #ayfy_Obj > 0 then
                    local shanxing = ayfy_Obj[1]
                    local param = {}
                    param.useqg = true
                    param.usesx = true
                    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, 8, 20, ayfy_Obj, nil, FubenRunSafe, nil, nil, param)
                  end
                end
                if bSafe then
                  if tmp.dst > 15 then
                    RunTo(tmp.x, tmp.y, 14)
                    Sleep(200)
                  end
                  FubenAttack(tid)
                  Sleep(200)
                end
              end
            end
          end
        else
          DebugStr("凤凰陵墓：镇陵战魂躲避陷阱中", 2)
        end
      end
    else
      DebugStr("凤凰陵墓：镇陵战魂已结束", 2)
      Sleep(6000)
      return
    end
  end
end

function FHLM_FindSpecial_DLGH()
  local tAllSpec = EnumUnSafeSpecial()
  local tObj = ObjFilterByName(tAllSpec, "恶灵缠身", 3)
  local bSafe = true
  if #tObj > 0 then
    local r = 6
    if "恶灵缠身" == tObj[1].name then
      r = 6
    end
    return tObj, r
  end
  return {}, 0
end

function FHLM_TrapRun_DLGH()
  local tSpec, r = FHLM_FindSpecial_DLGH()
  local bSafe = true
  local param = {}
  param.useqg = true
  param.usesx = true
  if #tSpec > 0 then
    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, r, 15, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

function BOSS_DLGH()
  PushColorMsg("地陵蛊花")
  boss_info_x = 0
  boss_info_y = 0
  while FuBenCheckDie(false, true, FHLM_OnDie()) == false do
    local dlgh_Obj = Enum2XByName(" 地陵蛊花 蛊墓花妖 ", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 3)
    if #dlgh_Obj > 0 then
      local dlgh_tmp = dlgh_Obj[1]
      if 0 == boss_info_x or 0 == boss_info_y then
        boss_info_x = dlgh_tmp.x
        boss_info_y = dlgh_tmp.y
      end
      if dlgh_tmp.class == "NPC" and "地陵蛊花" == dlgh_tmp.name then
        if Player:IsLeader() then
          CheckAllTeamHP(85, nil, 30)
          TalkNpc("地陵蛊花")
          Sleep(2000)
          QuestFrameOptionClicked_Item("#{FHCL_240708_76}", 1, 1500)
          Sleep(1000)
          MessageBox_Self_OK_Clicked()
        end
        local boss_zero = {
          x = dlgh_tmp.x,
          y = dlgh_tmp.y,
          r = 15,
          rmin = 1,
          rmax = 15,
          name = ""
        }
        TeamDispersedStations(boss_zero, 7, 6)
        PushColorMsg("凤凰陵墓：等待队长开启地陵蛊花....")
        Sleep(1000)
      else
        local bIsSafe, tSpecial = FHLM_TrapRun_DLGH()
        if bIsSafe then
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
            if 4 ~= g_self.menpai then
              CDG.pet2.GUID = 0
            end
            FubenAttack(tObj[1].id, true, true, true, false)
            Sleep(200)
          else
            local tObj = Enum2XByName(" 地陵蛊花 蛊墓花妖 ", {
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
                bIsSafe, _ = FubenTrapRun("", boss_info_x, boss_info_y, 7, 15, tObj, nil, FubenRunSafe, nil, nil, param)
                if bIsSafe then
                  RunTo(tmp.x, tmp.y, 14)
                  FubenAttack(-1)
                end
              else
                if #tSpecial > 0 then
                  if g_self.isjingong then
                    if tmp.dst > 3 then
                      if tmp.dst <= 15 then
                        JinGongFarSkill(tmp.id)
                      end
                      tid = -1
                    end
                  elseif tmp.dst > 15 then
                    RunTo(tmp.x, tmp.y, 14)
                    tid = -1
                  end
                end
                if tmp.dst > 15 then
                  RunTo(tmp.x, tmp.y, 14)
                end
                if -1 ~= Player:GetBuff("毒蛊入体") then
                  local wj_Obj = Enum2XByClass("玩家", {0, -1})
                  wj_Obj = ObjFilterByName(wj_Obj, g_self.name, 4)
                  local param = {}
                  param.useqg = false
                  local bSafe, tSpecial = FubenTrapRun("", boss_info_x, boss_info_y, 12, 15, wj_Obj, nil, FubenRunSafe, nil, nil, param)
                  if bSafe then
                    PushColorMsg("已远离队友!")
                    FubenAttack(tid)
                    Sleep(200)
                  end
                end
                FubenAttack(tid)
                Sleep(200)
              end
            end
          end
        else
          PushColorMsg("凤凰陵墓：地陵蛊花躲避陷阱中")
        end
      end
    else
      PushColorMsg("凤凰陵墓：地陵蛊花已结束")
      return
    end
  end
end

function checkTrap(myX, myY, trapDir, trapAngle, trapRadius, centerX, centerY)
  local trapDirDeg = (trapDir / 6.48 * 360 + 270) % 360
  local dx = myX - centerX
  local dy = centerY - myY
  local dist = math.sqrt(dx * dx + dy * dy)
  if trapRadius < dist then
    return false, {myX, myY}
  end
  local angle_rad = math.atan(dy / dx)
  if dx < 0 then
    angle_rad = angle_rad + math.pi
  end
  local angle_deg = math.deg(angle_rad) % 360
  local delta = (angle_deg - trapDirDeg + 180) % 360 - 180
  local absDelta = math.abs(delta)
  if absDelta <= trapAngle / 2 then
    local safePoint = getNearestSafePoint(myX, myY, trapDirDeg, trapAngle, trapRadius, centerX, centerY, dx, dy, dist)
    return true, safePoint
  else
    return false, {myX, myY}
  end
end

function getNearestSafePoint(myX, myY, trapDirDeg, trapAngle, trapRadius, centerX, centerY, dx, dy, dist)
  local beta_left = (trapDirDeg - trapAngle / 2 + 360) % 360
  local beta_right = (trapDirDeg + trapAngle / 2 + 360) % 360
  local candidates = {}
  if dist > 0 then
    local dirX = dx / dist
    local dirY = dy / dist
    table.insert(candidates, {
      centerX + dirX * (trapRadius + 1.0E-6),
      centerY - dirY * (trapRadius + 1.0E-6)
    })
  end
  local beta_left_rad = math.rad(beta_left)
  local normal_leftX = math.sin(beta_left_rad)
  local normal_leftY = -math.cos(beta_left_rad)
  table.insert(candidates, {
    myX + normal_leftX * 1.0E-6,
    myY - normal_leftY * 1.0E-6
  })
  local beta_right_rad = math.rad(beta_right)
  local normal_rightX = math.sin(beta_right_rad)
  local normal_rightY = -math.cos(beta_right_rad)
  table.insert(candidates, {
    myX + normal_rightX * 1.0E-6,
    myY - normal_rightY * 1.0E-6
  })
  local minDist = math.huge
  local bestPoint = {myX, myY}
  for _, point in ipairs(candidates) do
    if point[1] == point[1] and point[2] == point[2] and not isPointInSector(point[1], point[2], trapDirDeg, trapAngle, trapRadius, centerX, centerY) then
      local dx = point[1] - myX
      local dy = point[2] - myY
      local currentDist = dx * dx + dy * dy
      if minDist > currentDist then
        minDist = currentDist
        bestPoint = point
      end
    end
  end
  return bestPoint
end

function isPointInSector(x, y, trapDirDeg, trapAngle, trapRadius, centerX, centerY)
  local dx = x - centerX
  local dy = centerY - y
  local dist = math.sqrt(dx * dx + dy * dy)
  if trapRadius < dist then
    return false
  end
  local angle_rad = math.atan(dy / dx)
  if dx < 0 then
    angle_rad = angle_rad + math.pi
  end
  local angle_deg = math.deg(angle_rad) % 360
  local delta = (angle_deg - trapDirDeg + 180) % 360 - 180
  return math.abs(delta) <= trapAngle / 2
end

function TrapRun_XZMB()
  local bSafe = true
  local safePoint
  local tyk_Obj = Enum2XByName("通用空npc", {
    1,
    0,
    0,
    0
  }, {0, -1}, 1, 0)
  local myPos = Player:GetPos()
  if #tyk_Obj > 0 then
    local tObj = Enum2XByName("守陵傀儡", {
      1,
      1,
      0,
      0
    }, {0, -1}, 1, 0)
    for i = 1, #tObj do
      local tmp = tObj[i]
      local trapDir = tmp.fx
      bSafe, safePoint = checkTrap(myPos.x, myPos.y, trapDir, 45, 8, tmp.x, tmp.y)
      myPos.x = safePoint[1]
      myPos.y = safePoint[2]
      if 3 == i then
        break
      end
    end
  end
  RunTo(myPos.x, myPos.y)
  Sleep(200)
  return bSafe
end

function Game_XZMB()
  PushColorMsg("险中觅宝中")
  local tid = -1
  while true do
    local slkl_Obj = Enum2XByName("守陵傀儡", {
      1,
      1,
      0,
      0
    }, {0, -1}, 1, 0)
    if #slkl_Obj > 0 then
      local tObj = Enum2XByName("金币陷阱", {
        1,
        1,
        0,
        0
      }, {0, -1}, 1, 0)
      BubbleByDst(tObj, 1)
      for i = 1, #tObj do
        if tid == tObj[i].id then
          local tmp = tObj[i]
          RunTo(tmp.x, tmp.y)
          Sleep(500)
          break
        end
      end
      for i = 1, #tObj do
        if i == Team:GetMyIndex() + 1 then
          local tmp = tObj[i]
          tid = tmp.id
          RunTo(tmp.x, tmp.y)
          Sleep(500)
        end
      end
    else
      PushColorMsg("凤凰陵墓：险中觅宝已结束")
      Sleep(3000)
      break
    end
  end
end

function FHLM_findBuff_MSJX()
  if -1 ~= Player:GetBuff("银月秘钥") then
    return 1
  end
  if -1 ~= Player:GetBuff("炎日秘钥") then
    return 2
  end
  if -1 ~= Player:GetBuff("玄夜秘钥") then
    return 3
  end
  return 0
end

function Game_MSJX()
  PushColorMsg("密匙解匣")
  local myPos = Player:GetPos()
  boss_info_x = myPos.x
  boss_info_y = myPos.y
  while true do
    local buffType = FHLM_findBuff_MSJX()
    if 0 == buffType then
      local tObj = Enum2XByName("守陵傀儡", {
        1,
        1,
        0,
        0
      }, {0, -1}, 1, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        FubenAttack(tmp.id)
        Sleep(200)
      else
        Sleep(3000)
        return
      end
    elseif 1 == buffType then
      local tObj = Enum2XByName("银月凤雕", {
        1,
        1,
        0,
        0
      }, {0, -1}, 1, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        Skill.CUseSkillByID(3, tmp.id, -1, -1)
      else
        RunTo(boss_info_x, boss_info_y)
      end
      Sleep(1000)
    elseif 2 == buffType then
      local tObj = Enum2XByName("炎日凤雕", {
        1,
        1,
        0,
        0
      }, {0, -1}, 1, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        Skill.CUseSkillByID(3, tmp.id, -1, -1)
      else
        RunTo(boss_info_x, boss_info_y)
      end
      Sleep(1000)
    elseif 3 == buffType then
      local tObj = Enum2XByName("玄夜凤雕", {
        1,
        1,
        0,
        0
      }, {0, -1}, 1, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        Skill.CUseSkillByID(3, tmp.id, -1, -1)
      else
        RunTo(boss_info_x, boss_info_y)
      end
      Sleep(1000)
    else
      DebugStr("凤凰陵墓：交钥匙中", 2)
    end
  end
end

function FHLM_findBuff_FHQZ()
  if -1 ~= Player:GetBuff("金色印记：") then
    return 1
  end
  if -1 ~= Player:GetBuff("绿色印记：") then
    return 2
  end
  if -1 ~= Player:GetBuff("蓝色印记：") then
    return 3
  end
  if -1 ~= Player:GetBuff("红色印记：") then
    return 4
  end
  if -1 ~= Player:GetBuff("紫色印记：") then
    return 5
  end
  return 0
end

function Game_FHQZ()
  PushColorMsg("凤凰奇阵")
  local myPos = Player:GetPos()
  boss_info_x = myPos.x
  boss_info_y = myPos.y
  local stepIndex = 1
  while true do
    local tObj = Enum2XByName("区域", {
      1,
      1,
      0,
      0
    }, {0, -1}, 1, 5)
    local isPosition = false
    if #tObj > 0 then
      for i = 1, #tObj do
        local tmp = tObj[i]
        local buff = FHLM_findBuff_FHQZ()
        if 0 == buff then
          MoveTo(boss_info_x, boss_info_y)
          isPosition = false
        elseif 1 == buff and false == isPosition then
          if string.find(tmp.name, "金区域", nil, true) then
            MoveTo(tmp.x, tmp.y)
            isPosition = true
          end
        elseif 2 == buff and false == isPosition then
          if string.find(tmp.name, "木区域", nil, true) then
            MoveTo(tmp.x, tmp.y)
            isPosition = true
          end
        elseif 3 == buff and false == isPosition then
          if string.find(tmp.name, "水区域", nil, true) then
            MoveTo(tmp.x, tmp.y)
            isPosition = true
          end
        elseif 4 == buff and false == isPosition then
          if string.find(tmp.name, "火区域", nil, true) then
            MoveTo(tmp.x, tmp.y)
            isPosition = true
          end
        elseif 5 == buff and false == isPosition then
          if string.find(tmp.name, "土区域", nil, true) then
            MoveTo(tmp.x, tmp.y)
            isPosition = true
          end
        else
          DebugStr("凤凰陵墓：凤凰奇阵游戏中", 2)
        end
      end
    else
      Sleep(500)
      stepIndex = stepIndex + 1
      PushColorMsg(stepIndex)
      if stepIndex > 30 then
        break
      end
    end
  end
end

function FHLM_FindSpecial_DPHFZ()
  local tObj = Enum2XByName("火凤", {
    1,
    1,
    0,
    0
  }, {0, -1}, 1, 0)
  local bSafe = true
  if #tObj > 0 then
    local r = 5
    if "火凤" == tObj[1].name then
      r = 3
    end
    return tObj, r
  end
  return {}, 0
end

function FHLM_TrapRun_DPHFZ()
  local tSpec, r = FHLM_FindSpecial_DPHFZ()
  local bSafe = true
  local param = {}
  param.useqg = true
  param.usesx = true
  if #tSpec > 0 then
    bSafe = FubenTrapRun("", boss_info_x, boss_info_y, r, 60, tSpec, nil, FubenRunSafe, nil, nil, param)
  end
  return bSafe, tSpec
end

function Game_DPHFZ()
  PushColorMsg("大破火凤阵")
  local stepIndex = 1
  local tid = -1
  while true do
    local all_Obj = Enum2XByName(" 火凤 守陵傀儡 ", {
      1,
      1,
      0,
      0
    }, {0, -1}, 1, 3)
    if #all_Obj > 0 then
      local bIsSafe, tSpecial = FHLM_TrapRun_DPHFZ()
      if bIsSafe then
        local slkl_Obj = Enum2XByName("守陵傀儡", {
          1,
          1,
          0,
          0
        }, {0, -1}, 1, 0)
        if #slkl_Obj > 0 then
          local tmp = slkl_Obj[1]
          local isTid = false
          for i = 1, #slkl_Obj do
            if slkl_Obj[i].id == tid and slkl_Obj[i].hp > 0 then
              tid = slkl_Obj[i].id
              isTid = true
            end
          end
          if false == isTid then
            tid = tmp.id
          end
          if Player:IsLeader() then
            if GetDist(tmp.x, tmp.y) > 3 then
              RunTo(tmp.x, tmp.y)
              Sleep(200)
            else
              FubenAttack(tid)
              Sleep(200)
            end
          else
            local leader, isleader = Team:GetLeaderInfo()
            local findLeader = FindObjByGUID(leader.guid)
            for i = 1, #slkl_Obj do
              if slkl_Obj[i].id == findLeader.target then
                tmp = slkl_Obj[i]
                break
              end
            end
            if GetDist(tmp.x, tmp.y) > 3 then
              RunTo(tmp.x, tmp.y)
              Sleep(200)
            else
              FubenAttack(tmp.id)
              Sleep(200)
            end
          end
        end
      else
        PushColorMsg("凤凰陵墓：大破火凤阵躲避陷阱中")
      end
    else
      Sleep(500)
      stepIndex = stepIndex + 1
      if stepIndex > 50 then
        PushColorMsg("凤凰陵墓：大破火凤阵已结束")
        break
      end
    end
  end
end

function Game_SYGD()
  while true do
    local nObj = Enum2XByName(" 真火鼎 穹风鼎 丹水鼎 ", {
      1,
      0,
      0,
      0
    }, nil, nil, 3)
    if #nObj > 0 then
      for i = 1, #nObj do
        local tmp = nObj[i]
        if tmp.name == "真火鼎" then
          local tObj = Enum2XByName(" 风元灵 水元灵 ", {
            0,
            1,
            0,
            0
          }, {0, -1}, 1, 3)
          if #tObj > 0 then
            if tObj[1].dst > 14 then
              RunTo(tObj[1].x, tObj[1].y, 14)
            end
            FubenAttack(tObj[1].id)
            Sleep(200)
          end
        end
        if tmp.name == "穹风鼎" then
          local tObj = Enum2XByName(" 火元灵 水元灵 ", {
            0,
            1,
            0,
            0
          }, {0, -1}, 1, 3)
          if #tObj > 0 then
            if tObj[1].dst > 14 then
              RunTo(tObj[1].x, tObj[1].y, 14)
            end
            FubenAttack(tObj[1].id)
            Sleep(200)
          end
        end
        if tmp.name == "丹水鼎" then
          local tObj = Enum2XByName(" 火元灵 风元灵 ", {
            0,
            1,
            0,
            0
          }, {0, -1}, 1, 3)
          if #tObj > 0 then
            if tObj[1].dst > 14 then
              RunTo(tObj[1].x, tObj[1].y, 14)
            end
            FubenAttack(tObj[1].id)
            Sleep(200)
          end
        end
      end
    else
      return
    end
  end
end

function FHLM_SelectCheckPoint(Point_Index)
  GetLuaValue("setmetatable(_G, {__index = MiniMap_Env});ToggleSceneMap();")
  Sleep(1000)
  GetLuaValue(fmt("setmetatable(_G, {__index =ZhouchangPVE_SceneFb_Env});ZhouchangPVE_SceneFb_Room_Clicked(%d);", Point_Index))
  Sleep(1000)
  GetLuaValue("ZhouchangPVE_SceneFb_GO();")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index=MessageBox_Self2_Env});MessageBox_Self2_Ok_Clicked()")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = ZhouchangPVE_SceneFb_Env});ZhouchangPVE_SceneFb_Close();")
end

function isInArray(t, val)
  for _, v in ipairs(t) do
    if v == val then
      return true
    end
  end
  return false
end

function get_BaseInfo()
  local bIsInStartArea, nStartPosX, nStartPosZ, nPlayerPosX, nPlayerPosZ, nBossPosX, nBossPosZ, nGameItem1Num, nGameItem2Num, nGameItem3Num, nCurRoomState, nCurRound, nBossDis, nNextMoveStep, bIsNoWay, nBossWay, bIsShowBossWay, nOldBossPosX, nOldBossPosZ, nCurRoundUsedItem = GetLuaValue(fmt("return AskWeekPveMapBaseInfo();"), "nnnnnnnnnnnnnnnnnnnn")
  local currCellIndex = 1
  for i = 1, #g_PosIndex do
    if g_PosIndex[i].x == nPlayerPosX and g_PosIndex[i].z == nPlayerPosZ then
      currCellIndex = i
    end
  end
  return currCellIndex
end

function FHLM_GetStep()
  local nTransTime = GetSceneTransTime()
  local nMsgTime_fhlm = IsInDebugMsg("#{FHCL_240708_168}")
  if nMsgTime_fhlm and nTransTime < nMsgTime_fhlm then
    fuben_over = true
    return
  end
  GetLuaValue("setmetatable(_G, {__index = MiniMap_Env});ToggleSceneMap();")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = ZhouchangPVE_SceneFb_Env});ZhouchangPVE_SceneFb_Close();")
  if Player:IsLeader() then
    local currCellIndex = get_BaseInfo()
    if 2 == FHLM_get_CellState(currCellIndex) then
      return
    end
    if 3 == FHLM_get_CellState(currCellIndex) then
      for i = 1, #m_param.cPoint_fhlm do
        if m_param.cPoint_fhlm[i] == currCellIndex then
          currCellIndex = m_param.cPoint_fhlm[i + 1]
          FHLM_Use_Property()
          FHLM_SelectCheckPoint(currCellIndex)
          return
        end
      end
      if currCellIndex - 1 > 0 and currCellIndex - 1 <= 30 and 1 == FHLM_get_CellState(currCellIndex - 1) then
        FHLM_Use_Property()
        FHLM_SelectCheckPoint(currCellIndex - 1)
        return
      end
      if currCellIndex - 6 > 0 and currCellIndex - 6 <= 30 and 1 == FHLM_get_CellState(currCellIndex - 6) then
        FHLM_Use_Property()
        FHLM_SelectCheckPoint(currCellIndex - 6)
        return
      end
      if currCellIndex + 1 > 0 and currCellIndex + 1 <= 30 and 1 == FHLM_get_CellState(currCellIndex + 1) then
        FHLM_Use_Property()
        FHLM_SelectCheckPoint(currCellIndex + 1)
        return
      end
      if currCellIndex + 6 > 0 and currCellIndex + 6 <= 30 and 1 == FHLM_get_CellState(currCellIndex + 6) then
        FHLM_Use_Property()
        FHLM_SelectCheckPoint(currCellIndex + 6)
        return
      end
    end
    local cellEvent = FHLM_get_CellEvent(currCellIndex)
    local cellState = FHLM_get_CellState(currCellIndex)
    local cellGameItem = FHLM_get_CellGameItem(currCellIndex)
  end
end

function FHLM_Use_Property()
  GetLuaValue("setmetatable(_G, {__index = MiniMap_Env});ToggleSceneMap();")
  for i = 1, 3 do
    GetLuaValue(fmt("setmetatable(_G, {__index =ZhouchangPVE_SceneFb_Env}); ZhouchangPVE_SceneFb_Skill_Icon_Btn(%d);", i))
    GetLuaValue(fmt("setmetatable(_G, {__index=MessageBox_Self2_Env}); MessageBox_Self2_Ok_Clicked();"))
    Sleep(2000)
  end
  GetLuaValue("setmetatable(_G, {__index = ZhouchangPVE_SceneFb_Env});ZhouchangPVE_SceneFb_Close();")
end

function FHLM_get_CellState(Point_Index)
  local _x = g_PosIndex[Point_Index].x - 1
  local _z = g_PosIndex[Point_Index].z - 1
  local nRet, nCopySceneParam = GetLuaValue(fmt("return AskWeekPveMapInfo(%d,%d);", _x, _z), "nn")
  if 1 == nRet then
    return GetLuaValue(fmt("setmetatable(_G, {__index =ZhouchangPVE_SceneFb_Env}); return ZhouchangPVE_GetMapRoomState(%d);", nCopySceneParam), "n")
  end
  return nil
end

function FHLM_get_CellEvent(Point_Index)
  local _x = g_PosIndex[Point_Index].x - 1
  local _z = g_PosIndex[Point_Index].z - 1
  local nRet, nCopySceneParam = GetLuaValue(fmt("return AskWeekPveMapInfo(%d,%d);", _x, _z), "nn")
  if 1 == nRet then
    return GetLuaValue(fmt("setmetatable(_G, {__index =ZhouchangPVE_SceneFb_Env}); return ZhouchangPVE_GetMapRoomEventId(%d);", nCopySceneParam), "n")
  end
  return nil
end

function FHLM_get_CellGameItem(Point_Index)
  local _x = g_PosIndex[Point_Index].x - 1
  local _z = g_PosIndex[Point_Index].z - 1
  local nRet, nCopySceneParam = GetLuaValue(fmt("return AskWeekPveMapInfo(%d,%d);", _x, _z), "nn")
  if 1 == nRet then
    return GetLuaValue(fmt("setmetatable(_G, {__index =ZhouchangPVE_SceneFb_Env}); return ZhouchangPVE_GetMapRoomGameItem(%d);", nCopySceneParam), "n")
  end
  return nil
end

function FHLM_OnDie(...)
  if 9 == Player:GetState() then
    DieRelive(0)
    local tEM = Raid:GetLifeMenPai("峨嵋")
    local bHaveEM = false
    local myPos = Player:GetPos()
    for i = 1, #tEM do
      if GetDist(tEM[i].x, tEM[i].y, myPos.x, myPos.y) < 40 then
        bHaveEM = true
        break
      end
    end
    if false == bHaveEM then
      PushColorMsg("附近没有峨嵋,自动出窍！")
      DieRelive(-1)
    end
  end
  return false
end

function FHLM_OnProcess(...)
  FubenAttack(-1)
  CDG:checktime0()
  local tObj = Enum2XByName(" 杨建月 时烈风 ", {
    1,
    0,
    0,
    0
  }, {0, -1}, nil, 3)
  if #tObj > 0 then
    local tmp = tObj[1]
    if tmp.class == "NPC" and tmp.name == npc[1].name and tmp.x == npc[1].x and tmp.y == npc[1].y then
      if Player:IsLeader() then
        CheckAllTeamHP(85, nil, 30)
        TalkNpc(npc[1].name)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{FHCL_240708_162}", 1, 1500)
        MessageBox_Self_OK_Clicked()
        Sleep(1000)
        FHLM_SelectCheckPoint(26)
      end
      PushColorMsg("凤凰陵墓：准备探索墓室....")
      Sleep(1000)
      return
    elseif tmp.class == "NPC" and tmp.name == "时烈风" and 46 == tmp.x and tmp.y == 131 and 1 == #tObj then
      TalkNpc("时烈风")
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{FHCL_240708_24}", 1, 1500)
      return
    end
  end
  FHLM_GetStep()
  local currCellIndex = get_BaseInfo()
  local cellState = FHLM_get_CellState(currCellIndex)
  if 2 == cellState then
    local cellEvent = FHLM_get_CellEvent(currCellIndex)
    if 0 == g_FuBenType[cellEvent] then
      while true do
        local hfsd_Obj = Enum2XByName("火凤石雕", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 0)
        if #hfsd_Obj > 0 then
          local tmp = hfsd_Obj[1]
          boss_info_x = tmp.x
          boss_info_y = tmp.y
          if Player:IsLeader() then
            CheckAllTeamHP(85, nil, 30)
            TalkNpc("火凤石雕")
            Sleep(2000)
            QuestFrameOptionClicked_Item("#{FHCL_240708_189}", 1, 1500)
            MessageBox_Self_OK_Clicked()
          end
          local boss_zero = {
            x = tmp.x,
            y = tmp.y,
            r = 15,
            rmin = 1,
            rmax = 15,
            name = ""
          }
          TeamDispersedStations(boss_zero, 7, Team:GetMemberCount())
          Sleep(1000)
          PushColorMsg("火凤石雕开启中")
        else
          break
        end
      end
      local bGuid2 = CDG.pet2.GUID
      local bGuid3 = CDG.pet3.GUID
      CDG.pet2.GUID = 0
      CDG:checktime0()
      CDG.pet2.GUID = bGuid2
      if 1 == cellEvent then
        Game_XZMB()
      elseif 2 == cellEvent then
        Game_FHQZ()
      elseif 6 == cellEvent then
        Game_MSJX()
      elseif 7 == cellEvent then
        Game_SYGD()
      elseif 8 == cellEvent then
        Game_DPHFZ()
      end
    elseif 1 == g_FuBenType[cellEvent] then
      if 3 == cellEvent then
        BOSS_DLGH()
      elseif 4 == cellEvent then
        BOSS_YZZJ()
      elseif 5 == cellEvent then
        BOSS_AMWJ()
      elseif 9 == cellEvent then
        BOSS_ZLZH()
      elseif 10 == cellEvent then
        BOSS_SY()
      end
    else
      PushColorMsg("未知事件")
    end
  end
end

local function FHLM_Start(...)
  while GetSceneID() == m_param.sceneID and false == fuben_over do
    FHLM_OnProcess()
    PickUpLua()
    EatFubenItem(3)
    FuBenCheckDie(false, true, FHLM_OnDie())
    FubenAttack(-1)
    CDG:checktime0()
    Sleep(50)
    DebugStr("凤凰陵墓：副本中", 3)
  end
end

function _SMain(...)
  local npc = {
    name = "时烈风",
    x = 186,
    y = 113,
    sceneID = 260
  }
  EatFubenItem(3)
  while true do
    local debugnote = ""
    if GetSceneID() == m_param.sceneID then
      FHLM_Start()
    elseif IsHuodongComplete("凤凰陵墓", 1) == false then
      Bag_DeleteItem()
      GoToScene(npc.x, npc.y, npc.sceneID)
      if Player:IsLeader() then
        ChangeSceneLine()
      else
        local leader, isleader = Team:GetLeaderInfo()
        if leader and leader.sceneID == GetSceneID() then
          ChangeSceneLineID(leader.mapID)
        end
      end
      Sleep(500)
      FubenAttack(-1)
      local teamCount = HandleTextToNumber(m_param.count_fhlm, 6)
      if Team:IsCountReady(teamCount) then
        if IsTeamSteady() then
          TalkNpc(npc.name)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{FHCL_240708_295}", 1, 1500)
          if 1 == m_param.modelType_fhlm then
            QuestFrameOptionClicked_Item("#{FHCL_240708_6}", 1, 1500)
          else
            QuestFrameOptionClicked_Item("#{FHCL_240708_158}", 1, 1500)
          end
          local strText = GetNPCEventList_Item(0)
          if string.find(strText, "#{FHCL_240708_54}", nil, true) then
            Sleep(1000)
            if GetSceneID() ~= m_param.sceneID then
              PushDebugMessage("您今日已经刷过凤凰陵墓副本，结束！")
              break
            end
          end
        else
          debugnote = " 等待队员集合."
        end
      end
    else
      Sleep(1000)
      if GetSceneID() ~= m_param.sceneID and IsHuodongComplete("凤凰陵墓", 1, true) then
        TalkNpc(npc.name)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{FHCL_240708_295}", 1, 1500)
        QuestFrameOptionClicked_Item("#{FHCL_240708_5}", 1, 1500)
        PushDebugMessage("凤凰陵墓:已完成")
        break
      end
    end
    Sleep(300)
    DebugStr(m_script_name .. ":等待进入副本" .. debugnote)
  end
  EatFubenItem(3)
end

_SMain()
ScriptOnStop(m_script_name, true)
