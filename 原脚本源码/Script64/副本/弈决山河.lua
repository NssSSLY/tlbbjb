-- 反编译自 dfz64.dll 内嵌字节码 0033352d（unluac 2025-12-23；仅供分析）
local m_script_name = "弈决山河"
ScriptOnStart(m_script_name, false, false)
local m_npc = {
  {
    x = 194,
    y = 91,
    sceneID = 2,
    name = "康听弦"
  },
  {
    x = 195,
    y = 98,
    sceneID = 2,
    name = "康思乐"
  },
  {
    x = 195,
    y = 105,
    sceneID = 2,
    name = "康聆音"
  },
  {
    x = 289,
    y = 221,
    sceneID = 1,
    name = "石朝华"
  },
  {
    x = 312,
    y = 219,
    sceneID = LUOYANG_ID,
    name = "李戏生"
  },
  {
    x = 316,
    y = 225,
    sceneID = LUOYANG_ID,
    name = "李斯庭"
  }
}

function YJSH_OnDie(...)
  DieRelive(0)
  if 9 == Player:GetState() then
    GetLuaValue("setmetatable(_G, {__index = CampPVP2023_Relive_Env});CampPVP2023_Relive_Out_Ghost()")
  end
  return true
end

function YJSH_OnStar(...)
  while string.find(GetCurrentSceneName(), "弈决山河", nil, true) do
    FuBenCheckDie(false, true, YJSH_OnDie())
    local tAttack = EnumAttackObj("玩家", {0, -1})
    BubbleByDst(tAttack)
    if #tAttack > 0 then
      local tmp = tAttack[1]
      local JL = 15
      if Player:IsJinGong() then
        jl = 3
      end
      if JL < tmp.dst then
        RunTo(tmp.x, tmp.y)
      else
        FubenAttack(tmp.id)
      end
      Sleep(200)
    else
      UseMount()
      RunTo(253, 93)
    end
  end
end

local function SLDZ_cb(...)
  local strScene = GetCurrentSceneName()
  if string.find(strScene, "弈决山河", nil, true) then
    return false
  elseif string.find(strScene, "战斗休息室", nil, true) then
    return false
  end
  return true
end

function _SMain()
  local idx = -1
  local nLevel = Player:GetDataInt("LEVEL")
  if nLevel >= 60 and nLevel <= 69 then
    idx = 1
  elseif nLevel >= 70 and nLevel <= 79 then
    idx = 2
  elseif nLevel >= 80 and nLevel <= 89 then
    idx = 3
  elseif nLevel >= 90 and nLevel <= 109 then
    idx = 4
  elseif nLevel >= 110 and nLevel <= 119 then
    idx = 5
  elseif nLevel > 119 then
    idx = 6
  else
    PushDebugMessage(m_script_name .. ":等级不符合 " .. nLevel)
    return
  end
  local npc = m_npc[idx]
  while true do
    Team:LeaveTeam()
    local strScene = GetCurrentSceneName()
    PushColorMsg(strScene)
    if "弈决山河" == strScene then
      YJSH_OnStar()
    elseif string.find(strScene, "战斗休息室", nil, true) then
      Sleep(3000)
    elseif IsHuodongComplete("弈决山河", 1) == false then
      MoveTo(npc.x, npc.y, npc.sceneID, nil, nil, nil, SLDZ_cb)
      TalkNpc(npc.name, 1000)
      Team:LeaveTeam()
      QuestFrameOptionClicked_Item("#{WWSJ_230213_22", 3, 1000)
      Sleep(2000)
    elseif IsHuodongComplete("弈决山河", 1, true) then
      MoveTo(npc.x, npc.y, npc.sceneID, nil, nil, nil, SLDZ_cb)
      TalkNpc(npc.name, 1000)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{WWSJ_230213_28}", 3, 1000)
      Sleep(1000)
      break
    end
    DebugStr("地图ID:" .. GetSceneID())
    Sleep(1000)
  end
end

_SMain()
ScriptOnStop(m_script_name)
