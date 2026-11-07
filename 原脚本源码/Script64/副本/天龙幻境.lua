-- 反编译自 dfz64.dll 内嵌字节码 002ee7ae（unluac 2025-12-23；仅供分析）
local m_script_name = "天龙幻境"
ScriptOnStart(m_script_name, true, false)
g_pick.pickmode = 0
local m_param = {}
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
m_param.sceneID = 300

local function tlhj_movecb_in_fb(fX, fY, nScene)
  PickUpLua()
  return GetSceneID() == m_param.sceneID
end

local function TLHJ_GetKillMount()
  local nTransTime = GetSceneTransTime()
  local nMsgTime, strMsg = IsInDebugMsg("/240")
  if nMsgTime and nTransTime < nMsgTime then
    local _, _, strNum = string.find(strMsg, "已杀 (%d+)/240")
    local nCount = tonumber(strNum)
    if nCount then
      return nCount
    end
  end
  return 0
end

local function TLHJ_GetStep()
  local killCount = TLHJ_GetKillMount()
  if killCount >= 239 then
    return 8
  elseif killCount >= 210 and killCount < 239 then
    return 7
  elseif killCount >= 180 and killCount < 210 then
    return 6
  elseif killCount >= 150 and killCount < 180 then
    return 5
  elseif killCount >= 120 and killCount < 150 then
    return 4
  elseif killCount >= 90 and killCount < 120 then
    return 3
  elseif killCount >= 60 and killCount < 90 then
    return 2
  elseif killCount >= 30 and killCount < 60 then
    return 1
  elseif killCount > 0 and killCount < 30 or IsInDebugMsg("#{TLHJ_120110_39}") or IsInDebugMsg("#{TLHJ_120110_42}") then
    return 0
  end
  return -1
end

local function TLHJ_OnAction()
  local fubenPos = {
    [0] = {x = 63, y = 31},
    [1] = {x = 87, y = 40},
    [2] = {x = 97, y = 64},
    [3] = {x = 87, y = 87},
    [4] = {x = 63, y = 97},
    [5] = {x = 40, y = 87},
    [6] = {x = 30, y = 64},
    [7] = {x = 40, y = 40},
    [8] = {x = 64, y = 57}
  }
  while GetSceneID() == m_param.sceneID do
    local tObj = Enum2XByClass("怪物", {0, -1})
    local step = TLHJ_GetStep()
    PickUpLua(nil, true)
    if 0 == #tObj then
      if 1 == GetMissionComplete(m_param.misIndex) then
        PushColorMsg("天龙幻境：已完成！")
        Sleep(3000)
        PickUpLua(nil, true)
        MoveToNPC("若梦", 64, 57, -1, nil, nil, nil, tlhj_movecb_in_fb)
        Sleep(600)
        QuestFrameOptionClicked_Item("#{TLHJ_120110_30}", 1, 600)
        QuestFrameOptionClicked_Item("#{INTERFACE_XML_557}", 1, 600)
      else
        if -1 == step then
          if Player:IsLeader() then
            MoveToNPC("若梦", 64, 57, -1, nil, nil, nil, tlhj_movecb_in_fb)
            Sleep(600)
            QuestFrameOptionClicked_Item("#{TLHJ_120110_29}", 1, 700)
            QuestFrameOptionClicked_Item("#{TLHJ_120110_34}", 1, 700)
          else
            step = 0
          end
        end
        local pos = fubenPos[step]
        if pos then
          local dist = 8
          if g_self.isjingong == false then
            dist = 3
          end
          MoveTo(pos.x, pos.y, -1, dist, nil, nil, tlhj_movecb_in_fb)
          PlayerStateTimeOut(2, 4)
        end
        FubenAttack(-1)
      end
    else
      Dismount()
      local tAttack = tObj
      local tHP100 = ObjFilterByHP(tObj, 100, 0)
      if g_self.isjingong == false and #tHP100 > 0 then
        tAttack = tHP100
      else
        BubbleByDst(tAttack, 1)
      end
      if g_self.isjingong == false and tAttack[1].dst > 15 then
        RunTo(tAttack[1].x, tAttack[1].y, 1, 1000)
      end
      FubenAttack(tAttack[1].id)
    end
    Sleep(200)
    CDG:checkDouble()
    DebugStr("天龙幻境：副本中.")
  end
end

function _SMain(...)
  local bOver = false
  CDG.double.tld = false
  CDG.double.xdld = false
  CDG.double.xld = false
  while true do
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item("#{TLHJ_120110_62}")
    if -1 ~= m_param.misIndex then
      local curScene = GetSceneID()
      if curScene == m_param.sceneID then
        TLHJ_OnAction()
        bOver = true
      else
        local nStep = GetMissionComplete(m_param.misIndex)
        if 1 == nStep then
          GoToSceneNPC("浮生", 171, 120, 246)
          ChangeSceneLine()
          Sleep(500)
          QuestFrameOptionClicked_Item("#{TLHJ_120110_62}", 1, 600)
          QuestFrameNextClicked(600)
          QuestFrameMissionComplete(nil, 600)
        elseif 2 == nStep then
          Sleep(3000)
          QuestFrameMissionAbnegate(m_param.misScriptID)
        elseif Player:IsLeader() then
          if 0 == Bag:GetItemCount("试炼令牌") then
            if false == TempBank2Bag("试炼令牌", 0) then
              Bank_GetItem("试炼令牌", 1, nil, nil, true)
            end
            Sleep(300)
          end
          if 0 == Bag:GetItemCount("试炼令牌") then
            PushColorMsg("天龙幻境：没有试炼令牌")
            break
          else
            GoToSceneNPC("浮生", 171, 120, 246)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{TLHJ_120110_02}", 1, 600)
          end
        else
          GoToSceneNPC("浮生", 171, 120, 246)
        end
      end
    else
      if bOver then
        break
      end
      GoToSceneNPC("浮生", 171, 120, 246)
      ChangeSceneLine(true)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{TLHJ_120110_62}", 1, 600)
      QuestFrameAcceptClicked(600)
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
  if GetSceneID() ~= m_param.sceneID then
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
