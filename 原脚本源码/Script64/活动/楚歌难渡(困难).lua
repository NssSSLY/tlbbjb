-- 反编译自 dfz64.dll 内嵌字节码 00446ef5（unluac 2025-12-23；仅供分析）
local m_script_name = "楚歌难渡(困难)"
ScriptOnStart(m_script_name, true, true)

function YJSH_OnDie(...)
  DieRelive(0)
  if 9 == Player:GetState() then
    GetLuaValue("setmetatable(_G, {__index = Relive_Env});Relive_Out_Ghost();")
    Sleep(1000)
    GoToSceneNPC("溯缘镜", 189, 215, 1079)
    Dismount()
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{QXFB_260529_279}", 1, 1000)
  end
  return true
end

local function HandleMeteorTraps()
  local traps = Enum2XByClass("陷阱")
  for _, trap in ipairs(traps) do
    if trap.name == "精英怪2技能1陷阱" then
      local param = {useqg = true, usesx = true}
      local isSafe = FubenTrapRun("", 77, 111, 4, 10, traps, nil, FubenRunSafe, nil, nil, param)
      if not isSafe then
        FubenAttack(-1)
        return false
      end
    end
  end
  return true
end

local function YZW_NPC_HP(npcName)
  if 4 == g_self.menpai then
    local tNPC = Enum2XByName(npcName, {
      1,
      0,
      0,
      0
    }, {0, -1}, nil, 0)
    for i = 1, #tNPC do
      if #tNPC > 0 and tNPC[i].hp < 60 and tNPC[i].hp > 0 and tNPC[i].dst < 30 then
        if tNPC[i].dst > 15 then
          RunTo(tNPC[i].x, tNPC[i].y, 0, 500)
        end
        PushColorMsg(tNPC[i].hp)
        Skill:UseSkillByName("清心普善咒", tNPC[i].id, -1, -1, 700)
        return true
      end
    end
  end
  return false
end

local iszw = false

function onstar()
  while GetSceneID() == 1079 do
    FuBenCheckDie(false, true, YJSH_OnDie())
    local nMemIndex = Team:GetMyIndex()
    if 1 == nMemIndex or 2 == nMemIndex then
      local tHD = Enum2XByName("船舵 船舵手 魔化舵手 敌方船舵", {
        0,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      BubbleByDst(tHD)
      if #tHD > 0 then
        RunTo(tHD[1].x, tHD[1].y, 0, 1000)
        FubenAttack(tHD[1].id)
        break
      else
        local tCDNPC = Enum2XByName("船舵 船舵手", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 3)
        if #tCDNPC > 0 and GetDist(77, 111) > 6 then
          RunTo(77, 111, 0, 2000)
        end
      end
    end
    local safeToAttack = HandleMeteorTraps()
    if not safeToAttack then
      break
    end
    if YZW_NPC_HP("船舵手") then
      Sleep(100)
      break
    end
    if YZW_NPC_HP("船舵") then
      Sleep(100)
      break
    end
    local tObj = Enum2XByClass("怪物 陷阱", {0, -1})
    BubbleByDst(tObj)
    for i = #tObj, 1, -1 do
      local tmp = tObj[i]
      if tmp.name == "" or tmp.name == "船体残骸" then
        table.remove(tObj, i)
      end
    end
    if #tObj > 0 then
      if not iszw then
        iszw = true
        local boss_zero = {x = 77, y = 111}
        PushColorMsg("分散")
        TeamDispersedStations(boss_zero, 5, Team:GetMemberCount())
        Sleep(2000)
      end
      local tmp = tObj[1]
      if tmp.class == "怪物" and tmp.dst < 30 then
        FubenAttack(tmp.id)
        Sleep(200)
      end
    else
      local tCDNPC = Enum2XByName("船舵", {
        1,
        0,
        0,
        0
      }, {0, -1}, nil, 0)
      if #tCDNPC > 0 then
        local tCDSNPC = Enum2XByName("船舵手", {
          1,
          0,
          0,
          0
        }, {0, -1}, nil, 0)
        if #tCDSNPC > 0 then
          PushColorMsg("战斗中")
          Sleep(200)
          break
        end
      end
      Sleep(3000)
      local tObj = Enum2XByClass("怪物")
      for i = #tObj, 1, -1 do
        local tmp = tObj[i]
        if tmp.name == "" or tmp.name == "船体残骸" then
          table.remove(tObj, i)
        end
      end
      if 0 == #tObj then
        local txw = Enum2XByName("项王 船舵", {
          1,
          1,
          1,
          0
        }, nil, nil, 3)
        if #txw > 0 then
          if txw[1].name == "项王" then
            GoToSceneNPC("溯缘镜", 189, 136, 1079)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{QXFB_260529_30}", 1, 1000)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{QXFB_260529_303}", 1, 1000)
          elseif "船舵" == txw[1].name then
            GoToSceneNPC("船舵", 77, 106, 1079)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{QXFB_260529_32}", 1, 1000)
            Sleep(1000)
          end
        else
          local tYGST = Enum2XByName("虞姬尸体", {
            1,
            0,
            0,
            0
          }, {0, -1}, nil, 0)
          if #tYGST > 0 then
            local tmp = tYGST[1]
            RunTo(tmp.x, tmp.y, 0, 1000)
            if IsTeamSteady() then
              Sleep(3000)
              OpenTalk(tmp.id, 600)
              Dismount()
              Sleep(1000)
              QuestFrameOptionClicked_Item("#{QXFB_260529_43}", 1, 1000)
              Sleep(1000)
              QuestFrameOptionClicked_Item("#{QXFB_260529_35}", 1, 1000)
              Sleep(3000)
              local tSYJ = Enum2XByName("溯缘镜", {
                1,
                0,
                0,
                0
              }, {0, -1}, nil, 0)
              if #tSYJ > 0 then
                local tmp = tSYJ[1]
                RunTo(tmp.x, tmp.y, 0, 2000)
                OpenTalk(tmp.id, 600)
                Sleep(1000)
                QuestFrameOptionClicked_Item("#{QXFB_260529_20}", 1, 1000)
                Sleep(1000)
                QuestFrameOptionClicked_Item("#{QXFB_260529_25}", 1, 1000)
                Sleep(2000)
              end
              break
            end
          end
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
            QuestFrameOptionClicked_Item("#{QXFB_260529_304}", 1, 1000)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{QXFB_260529_279}", 1, 1000)
            Sleep(1000)
            QuestFrameOptionClicked_Item("#{QXFB_260529_30}", 1, 1000)
          end
        end
      end
    end
  end
end

function _SMain(...)
  if GetSceneID() ~= 1079 then
    GoToSceneNPC("乐师", 177, 134, 1075)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{QXZH_250528_34}", 1, 1000)
    Sleep(1000)
    local tzd = Enum2XByName("风下竹笛", {
      1,
      1,
      1,
      0
    }, nil, nil, 0)
    if #tzd > 0 then
      MoveTo(tzd[1].x, tzd[1].y)
      Dismount()
      Skill.CUseSkillByID(5999, tzd[1].id, -1, -1)
      Sleep(7000)
    end
  end
  while true do
    DeleteDebugMsg("#{QXFB_260529_347}")
    DeleteDebugMsg("#{QXFB_260529_15}")
    if GetSceneID() == 1079 then
      onstar()
    else
      GoToSceneNPC("溯缘镜", 208, 51, 1075)
      Sleep(1000)
      if IsTeamSteady() then
        QuestFrameOptionClicked_Item("#{QXFB_260529_05}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
        if IsInDebugMsg("#{QXFB_260529_347}") or IsInDebugMsg("#{QXFB_260529_15}") then
          PushColorMsg("#{QXFB_260529_347}")
          QuestFrameOptionClicked_Item("#{QXFB_260529_06}", 1, 1000)
          break
        end
      end
    end
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
