-- 反编译自 dfz64.dll 内嵌字节码 00444592（unluac 2025-12-23；仅供分析）
local m_script_name = "楚汉之战"
ScriptOnStart(m_script_name, true, true)
local hybossinfo = {
  {
    x = 243,
    y = 49,
    ists = false
  },
  {
    x = 243,
    y = 148,
    ists = false
  }
}
local cybossinfo = {
  {
    x = 71,
    y = 45,
    ists = false
  },
  {
    x = 71,
    y = 141,
    ists = false
  }
}

local function MoveToIfNeeded(x, y, threshold)
  threshold = threshold or 30
  if threshold < GetDist(x, y) then
    RunTo(x, y)
    return true
  end
  return false
end

local function CollectRemainingPoints(zyinfo)
  for _, point in ipairs(zyinfo) do
    if not point.ists then
      MoveToIfNeeded(point.x, point.y, 30)
      point.ists = true
      return true
    end
  end
  return false
end

function YJSH_OnDie(...)
  DieRelive(0)
  if 9 == Player:GetState() then
    GetLuaValue("setmetatable(_G, {__index = Relive_Env});Relive_Out_Ghost();")
  end
  return true
end

function CHZZ_OnStar(...)
  while string.find(GetCurrentSceneName(), "楚河汉界", nil, true) do
    FuBenCheckDie(false, true, YJSH_OnDie())
    local txw = Enum2XByName("传令兵", {
      1,
      1,
      1,
      0
    }, nil, nil, 0)
    if #txw > 0 then
      local myPos = Player:GetPos()
      if -1 ~= Player:GetBuff("汉营") then
        local thydm = Enum2XByName("汉营大门", {
          1,
          1,
          1,
          0
        }, nil, nil, 0)
        if #thydm > 0 and thydm[1].x >= myPos.x then
          MoveTo(txw[1].x, txw[1].y)
          TalkNpc("传令兵", 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{XQPVP_260526_139}", 1, 1000)
          Sleep(500)
        end
      end
      if -1 ~= Player:GetBuff("楚营") then
        local tcydm = Enum2XByName("楚营大门", {
          1,
          1,
          1,
          0
        }, nil, nil, 0)
        if #tcydm > 0 and tcydm[1].x <= myPos.x then
          MoveTo(txw[1].x, txw[1].y)
          TalkNpc("传令兵", 1000)
          Sleep(1000)
          QuestFrameOptionClicked_Item("#{XQPVP_260526_139}", 1, 1000)
          Sleep(500)
        end
      end
    end
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
      local tObj = Enum2XByClass("怪物")
      BubbleByDst(tObj)
      if #tObj > 0 then
        RunTo(tObj[1].x, tObj[1].y, 0, 200)
        FubenAttack(tObj[1].id)
        Sleep(200)
      elseif -1 ~= Player:GetBuff("汉营") then
        RunTo(262, 95, 0, 200)
      else
        RunTo(55, 95, 0, 200)
      end
    end
  end
end

function _SMain(...)
  while true do
    DeleteDebugMsg("#{XQPVP_260526_12}")
    Team:LeaveTeam()
    local strScene = GetCurrentSceneName()
    PushColorMsg(strScene)
    if "楚河汉界" == strScene then
      CHZZ_OnStar()
    elseif string.find(strScene, "驻扎营地", nil, true) then
      Sleep(3000)
    else
      GoToSceneNPC("苏星河", 88, 210, 1075)
      Sleep(1000)
      QuestFrameOptionClicked_Item("#{XQPVP_260526_03}", 1, 1000)
      Sleep(1000)
      if IsInDebugMsg("#{XQPVP_260526_12}") then
        PushColorMsg("#{XQPVP_260526_12}")
        GoToSceneNPC("苏星河", 88, 210, 1075)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{XQPVP_260526_04}", 1, 1000)
        Sleep(1000)
        QuestFrameOptionClicked_Item("#{XQPVP_260526_05}", 1, 1000)
        break
      end
    end
    DebugStr("地图ID:" .. GetSceneID())
    Sleep(1000)
  end
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
