-- 反编译自 dfz64.dll 内嵌字节码 0045934a（unluac 2025-12-23；仅供分析）
local m_script_name = "暗袭萧阿刺(困难)"
ScriptOnStart(m_script_name, true, true)
local nowsceneID = 1072
local jindu = 1

local function HandleMeteorTraps(boss)
  local traps = Enum2XByClass("陷阱")
  for _, trap in ipairs(traps) do
    if trap.name == "难度1BOSS4技能3陷阱" then
      local param = {useqg = true, usesx = true}
      local isSafe = FubenTrapRun("", boss[1].x, boss[1].y, 5, 10, traps, nil, FubenRunSafe, nil, nil, param)
      if not isSafe then
        FubenAttack(-1)
        return false
      end
    end
  end
  local nMsgTime1 = IsInDebugMsg("WSTZ_260403_57")
  if nMsgTime1 and os.time() - nMsgTime1 < 10 then
    PushColorMsg("躲避")
    Sleep(200)
    local param = {}
    param.useqg = false
    local bSafe, tSpecial = FubenTrapRun("", 130, 50, 10, 12, boss, nil, FubenRunSafe, nil, nil, param)
    return false
  end
  return true
end

function OnStar_boos3(...)
  GoToSceneNPC("萧阿刺", 127, 29, nowsceneID)
  Sleep(3000)
  Dismount()
  if IsTeamSteady() then
    Sleep(1000)
  else
    Sleep(200)
    return
  end
  while GetCurrentSceneName() == "边境石窟" do
    local tXAC = Enum2XByName("萧阿刺", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tXAC > 0 then
      for _, trap in ipairs(tXAC) do
        if trap.class == "NPC" then
          OpenTalk(trap.id)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{WSTZ_260403_44}", 1, 1000)
          Sleep(1000)
        end
        if trap.class == "怪物" then
          if GetDist(130, 50) > 18 then
            RunTo(130, 50, 0, 1000)
          end
          local safeToAttack = HandleMeteorTraps(tXAC)
          if safeToAttack then
            if trap.dst > 15 then
              RunTo(trap.x, trap.y, 0, 1000)
            end
            FubenAttack(trap.id)
          end
          Sleep(200)
          break
        end
      end
    else
      jindu = 4
      break
    end
  end
end

function OnStar_boos2(...)
  GoToSceneNPC("大萨满", 130, 120, nowsceneID)
  if IsTeamSteady() then
    Dismount()
    Sleep(2000)
  else
    Sleep(200)
    return
  end
  while GetCurrentSceneName() == "边境石窟" do
    local tDSM = Enum2XByName("大萨满", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tDSM > 0 then
      if tDSM[1].class == "NPC" then
        OpenTalk(tDSM[1].id)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{WSTZ_260403_44}", 1, 1000)
        Sleep(1000)
        local boss_zero = {x = 130, y = 120}
        TeamDispersedStations(boss_zero, 5, Team:GetMemberCount())
      end
      if tDSM[1].class == "怪物" then
        FubenAttack(tDSM[1].id)
        Sleep(200)
      end
    else
      local traps = Enum2XByClass("怪物", {0, -1})
      BubbleByDst(traps)
      if #traps > 0 then
        for _, trap in ipairs(traps) do
          FubenAttack(trap.id)
          Sleep(200)
          break
        end
      else
        jindu = 3
        break
      end
    end
  end
end

function OnStar_boos1(...)
  GoToSceneNPC("灵灵铃", 123, 219, nowsceneID)
  Dismount()
  Sleep(1000)
  if IsTeamSteady() then
    TalkNpc("灵灵铃")
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{WSTZ_260403_93}", 1, 1000)
    Sleep(15000)
    RunTo(127, 190, 0, 10000)
  else
    Sleep(500)
    return
  end
  while GetCurrentSceneName() == "边境石窟" do
    local traps = Enum2XByClass("怪物", {0, -1})
    BubbleByDst(traps)
    if #traps > 0 then
      for _, trap in ipairs(traps) do
        if trap.dst > 15 then
          RunTo(trap.x, trap.y, 0, 1000)
        end
        FubenAttack(trap.id)
        Sleep(200)
        break
      end
    else
      jindu = 2
      break
    end
  end
end

function onstar(...)
  while GetCurrentSceneName() == "边境石窟" do
    if 1 == jindu then
      OnStar_boos1()
    elseif 2 == jindu then
      OnStar_boos2()
    elseif 3 == jindu then
      OnStar_boos3()
    elseif 4 == jindu then
      Sleep(2000)
      PushColorMsg("结束")
    end
  end
end

function _SMain(...)
  while true do
    DeleteDebugMsg("#{WSTZ_260403_108}")
    if GetCurrentSceneName() == "边境石窟" then
      onstar()
    else
      GoToSceneNPC("灵灵铃", 250, 243, LUOYANG_ID)
      Sleep(1000)
      if IsTeamSteady() then
        QuestFrameOptionClicked_Item("#{WSTZ_260403_05}", 1, 1000)
        Sleep(1000)
        TalkNpc("灵灵铃")
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{WSTZ_260403_102}", 1, 1000)
        if IsInDebugMsg("#{WSTZ_260403_108}") then
          QuestFrameOptionClicked_Item("#{WSTZ_260403_102}", 1, 1000)
          break
        end
      end
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
