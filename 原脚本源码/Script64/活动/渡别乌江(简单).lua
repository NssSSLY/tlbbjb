-- 反编译自 dfz64.dll 内嵌字节码 00453a9f（unluac 2025-12-23；仅供分析）
local m_script_name = "渡别乌江"
ScriptOnStart(m_script_name, true, true)
local METEOR_SAFE_RADIUS = 8
local METEOR_WARN_DIST = 15
local bossOVER = false

function YJSH_OnDie(...)
  DieRelive(0)
  if 9 == Player:GetState() then
    DieRelive(-1)
    local tSYJ = Enum2XByName("溯缘镜", {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tSYJ > 0 then
      local tmp = tSYJ[1]
      OpenTalk(tmp.id, 600)
      Dismount()
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_279}", 1, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_33}", 1, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_30}", 1, 1000)
    end
  end
  return true
end

function getBackPoint(bossX, bossY, trapDir, distance)
  local rad = trapDir / 6.48 * 2 * math.pi
  local faceX = math.sin(rad)
  local faceY = math.cos(rad)
  local backX = bossX - faceX * distance
  local backY = bossY - faceY * distance
  return {backX, backY}
end

local function HandleMeteorTraps(boss)
  local traps = Enum2XByClass("陷阱")
  for _, trap in ipairs(traps) do
    if trap.name == "项羽技能2圆形陷阱" then
      local param = {useqg = true, usesx = true}
      local isSafe = FubenTrapRun("", boss.x, boss.y, 5, 10, traps, nil, FubenRunSafe, nil, nil, param)
      if not isSafe then
        FubenAttack(-1)
        return false
      end
    end
  end
  return true
end

function onstar()
  while GetSceneID() == 1079 do
    FuBenCheckDie(false, true, YJSH_OnDie())
    local tXW = Enum2XByName("项王", {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tXW > 0 then
      local boss = tXW[1]
      local tYDMB = Enum2XByName("营地魔兵", {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 0)
      BubbleByDst(tYDMB)
      if #tYDMB > 0 then
        local tmp = tYDMB[1]
        FubenAttack(tmp.id)
        Sleep(200)
        RunTo(boss.x, boss.y, 0, 200)
        break
      elseif boss.title == "长夜终尽" then
        RunTo(boss.x, boss.y, 0, 2000)
        OpenTalk(boss.id, 200)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_287}", 1, 1000)
        Sleep(2000)
        local tSYJ = Enum2XByName("溯缘镜", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 0)
        if #tSYJ > 0 then
          PushColorMsg(1111)
          local tmp = tSYJ[1]
          RunTo(tmp.x, tmp.y, 0, 2000)
          OpenTalk(tmp.id, 200)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXFB_260529_20}", 1, 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{QXFB_260529_25}", 1, 1000)
        end
      end
    elseif GetDist(186, 118) < 30 then
      bossOVER = true
    end
    if bossOVER then
      RunTo(67, 221, 0, 1000)
      break
    end
    local tYJ = Enum2XByName("虞姬", {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tXW > 0 and #tYJ > 0 then
      local boss = tXW[1]
      if boss.class == "NPC" then
        OpenTalk(boss.id, 600)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_312}", 1, 1000)
        break
      end
      if boss.class == "怪物" then
        if 0 == boss.hp then
          bossOVER = true
        end
        local myPos = Player:GetPos()
        local trapDir = boss.fx
        if IsInDebugMsgTime("#{QXFB_260529_168}", false, 6) then
          local safePoint = getBackPoint(boss.x, boss.y, trapDir, 3)
          RunTo(safePoint[1], safePoint[2], 0, 500)
          FubenAttack(-1)
          Sleep(3000)
          local symX = 2 * boss.x - safePoint[1]
          local symY = 2 * boss.y - safePoint[2]
          RunTo(symX, symY, 0, 500)
          return
        end
        local safeToAttack = HandleMeteorTraps(boss)
        if safeToAttack then
          do
            local tYDMB = Enum2XByName("营地魔兵", {
              1,
              1,
              0,
              0
            }, {0, -1}, nil, 0)
            BubbleByDst(tYDMB)
            if #tYDMB > 0 then
              local tmp = tYDMB[1]
              FubenAttack(tmp.id)
              Sleep(200)
            end
            FubenAttack(boss.id)
          end
          break
        end
        FubenAttack(-1)
      end
      break
    end
    local tYJ = Enum2XByName("虞姬", {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tYJ > 0 then
      local tmp = tYJ[1]
      RunTo(tmp.x, tmp.y, 0, 2000)
      OpenTalk(tmp.id, 200)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_258}", 1, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{QXFB_260529_258}", 1, 1000)
      Sleep(5000)
      MoveTo(186, 118)
      Dismount()
    else
      local tSYJ = Enum2XByName("溯缘镜", {
        1,
        0,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tSYJ > 0 then
        local tmp = tSYJ[1]
        OpenTalk(tmp.id, 600)
        Dismount()
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_36}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_279}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_33}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_30}", 1, 1000)
        Sleep(1000)
      end
    end
  end
end

function _SMain(...)
  if GetSceneID() ~= 1079 then
    GoToSceneNPC("史官", 114, 48, 1075)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{QXZH_250528_53}", 1, 1000)
    Sleep(1000)
  end
  while true do
    DeleteDebugMsg("#{QXFB_260529_347}")
    DeleteDebugMsg("#{QXFB_260529_53}")
    DeleteDebugMsg("#{QXFB_260529_15}")
    if GetSceneID() == 1079 then
      onstar()
    else
      GoToSceneNPC("溯缘镜", 208, 51, 1075)
      Dismount()
      Sleep(1000)
      if IsTeamSteady() then
        QuestFrameOptionClicked_Item("#{QXFB_260529_03}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
        Sleep(1000)
        if IsInDebugMsg("#{QXFB_260529_347}") or IsInDebugMsg("#{QXFB_260529_53}") or IsInDebugMsg("#{QXFB_260529_15}") then
          PushColorMsg("#{QXFB_260529_347}")
          QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
          break
        end
        QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
      end
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
