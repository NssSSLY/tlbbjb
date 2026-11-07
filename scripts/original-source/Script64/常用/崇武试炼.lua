-- 反编译自 dfz64.dll 内嵌字节码 0037d84b（unluac 2025-12-23；仅供分析）
local m_script_name = "崇武试炼"
ScriptOnStart(m_script_name)
local m_npc_shimen = {
  [0] = {
    name = "玄寂",
    x = 91,
    y = 72,
    sceneID = 9
  },
  [1] = {
    name = "吕师襄",
    x = 107,
    y = 56,
    sceneID = 11
  },
  [2] = {
    name = "陈孤雁",
    x = 91,
    y = 100,
    sceneID = 10
  },
  [3] = {
    name = "张玄素",
    x = 77,
    y = 87,
    sceneID = 12
  },
  [4] = {
    name = "李十二娘",
    x = 95,
    y = 53,
    sceneID = 15
  },
  [5] = {
    name = "韩世忠",
    x = 95,
    y = 76,
    sceneID = 16
  },
  [6] = {
    name = "本因",
    x = 95,
    y = 68,
    sceneID = 13
  },
  [7] = {
    name = "梅剑",
    x = 91,
    y = 45,
    sceneID = 17
  },
  [8] = {
    name = "苏星河",
    x = 124,
    y = 144,
    sceneID = 14
  },
  [9] = {
    name = "",
    x = 0,
    y = 0,
    sceneID = 0
  },
  [10] = {
    name = "慕容杰",
    x = 49,
    y = 144,
    sceneID = 284
  },
  [11] = {
    name = "唐亦风",
    x = 77,
    y = 36,
    sceneID = 615
  },
  [12] = {
    name = "王禅一",
    x = 99,
    y = 58,
    sceneID = 678
  },
  [13] = {
    name = "君还珠",
    x = 205,
    y = 72,
    sceneID = 731
  },
  [14] = {
    name = "行严",
    x = 255,
    y = 167,
    sceneID = 824
  },
  [15] = {
    name = "段延庆",
    x = 157,
    y = 57,
    sceneID = 987
  }
}

local function CWSL_cb_out(...)
  local strScene = GetCurrentSceneName()
  if string.find(strScene, "崇武试炼", nil, true) then
    return false
  end
  return true
end

local function CWSL_EnumTrap()
  local tObj = {}
  local tSpec = EnumUnSafeSpecial()
  for i = 1, #tSpec do
    if IsPlayerTrap(tSpec[i].name) == false and tSpec[i].name ~= "加速符" and tSpec[i].name ~= "回血符" and tSpec[i].name ~= "增伤符" then
      local n = #tObj + 1
      tObj[n] = tSpec[i]
    end
  end
  return tObj
end

local function CWSL_Action()
  local boss = {
    name = " 乔峰·试炼 段誉·试炼 虚竹·试炼 ",
    x = 95,
    y = 66
  }
  while true do
    local tObj = Enum2XByName(boss.name, {
      0,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      local tSpecial = CWSL_EnumTrap()
      local bSafe, tSpec = FubenTrapRun(boss.name, boss.x, boss.y, 6, 15, tSpecial)
      if bSafe then
        if #tSpec > 0 then
          if not g_self.isjingong or tmp.dst < 3 then
            if tmp.dst > 15 then
              RunTo(tmp.x, tmp.y, 3, 800)
            end
            FubenAttack(tmp.id)
          else
            FubenAttack(-1)
          end
        else
          if tmp.dst > 15 then
            RunTo(tmp.x, tmp.y, 3, 800)
          end
          FubenAttack(tmp.id, true)
        end
      else
      end
    else
      Sleep(4000)
      tObj = Enum2XByName(boss.name, {
        1,
        0,
        0,
        0
      }, nil, nil, 3)
      if 0 == #tObj then
        break
      end
    end
    Sleep(500)
    DebugStr("副本中")
  end
end

function _SMain(...)
  DeleteDebugMsg("#{ZMB_230124_137}")
  while true do
    local strScene = GetCurrentSceneName()
    local nScene = GetSceneID()
    if "崇武试炼休息室" == strScene then
      FubenAttack(-1)
    elseif "崇武试炼" == strScene then
      CWSL_Action()
    else
      local mpID = Player:GetMenPaiID()
      local npc = m_npc_shimen[mpID]
      if npc then
        MoveTo(npc.x, npc.y, npc.sceneID, nil, nil, nil, CWSL_cb_out)
        TalkNpc(npc.name, 1000)
        DialogOptionClicked("崇武试炼", 1, 1000)
        DialogOptionClicked("前往参与", 1, 1000)
      end
    end
    if IsInDebugMsg("#{ZMB_230124_137}") then
      break
    end
    Sleep(500)
    DebugStr("崇武试炼")
  end
end

_SMain()
ScriptOnStop(m_script_name)
