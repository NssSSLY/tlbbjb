-- 反编译自 dfz64.dll 内嵌字节码 002b8890（unluac 2025-12-23；仅供分析）
local m_script_name = "刷棋"
ScriptOnStart(m_script_name, true, true)
CDG.skill_attack = g_config.skill.shuaguai_gongji
local m_teamCount = 3
local m_QuickMode = ReadConfigBool("ZH", "xzk190")
local m_fubenSceneID = 61

local function IsXiuXiShiScene()
  local cur_scene_name = GetCurrentSceneName()
  if string.find(cur_scene_name, "苏州休息室", nil, true) then
    return true
  end
  return false
end

local function sq_cb_xiuxishi(fX, fY, nScene)
  if IsXiuXiShiScene() then
    return MoveCallback_NoFuben(fX, fY, nScene)
  end
  return false
end

local function sq_cb_not_xiuxishi(fX, fY, nScene)
  if not IsXiuXiShiScene() then
    return MoveCallback_NoFuben(fX, fY, nScene)
  end
  return false
end

local function sq_cb_inscene(fX, fY, nScene)
  PickUpLua()
  return GetSceneID() == m_fubenSceneID
end

local function sq_cb_inscene_findobj(fX, fY, nScene)
  if sq_cb_inscene(fX, fY, nScene) then
    local tObj = Enum2XByClass("怪物", {0, -1})
    if #tObj > 0 then
      return false
    end
    return true
  end
  return false
end

local function SQ_QuitFuben()
  if GetSceneID() == m_fubenSceneID then
    PickUpLua_Boss(-1, 15)
  end
  while GetSceneID() == m_fubenSceneID do
    MoveToNPC("齐圣", 40, 40, -1, nil, nil, MoveCallBack_state_1, sq_cb_inscene)
    Sleep(1000)
    QuestFrameOptionClicked_Item("确定", 1, 1200)
    DebugStr("离开副本")
  end
end

local function SQ_OnAction()
  local SearchPos = {
    {x = 45, y = 45},
    {x = 82, y = 45},
    {x = 82, y = 82},
    {x = 45, y = 82},
    {x = 45, y = 64},
    {x = 64, y = 64}
  }
  local nTickFindObj = -1
  local posLast, bossLast
  if IsInDebugMsgTime("你已击败棋子", nil, 3600) then
    PushDebugMessage("刷棋：已在副本中")
    nTickFindObj = GetTickCount()
  end
  while GetSceneID() == m_fubenSceneID do
    local tObj = Enum2XByClass("怪物", {0, -1}, 1)
    if #tObj > 0 then
      nTickFindObj = GetTickCount()
      if tObj[1].dst > 5 then
        RunTo(tObj[1].x, tObj[1].y, 3, 1000)
      else
        FubenAttack(tObj[1].id)
      end
      if tObj[1].name == "远古棋魂" then
        bossLast = tObj[1]
      end
    else
      PickUpLua()
      if bossLast then
        RunTo(bossLast.x, bossLast.y, 6, 3000)
      end
      tObj = Enum2XByName("远古棋魂", {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 and 0 == tObj[1].hp then
        SQ_QuitFuben()
      end
      if not IsMount() then
        FubenAttack(-1)
      end
      if -1 ~= nTickFindObj then
        if posLast then
          MoveTo(posLast.x, posLast.y, -1, nil, nil, MoveCallBack_state_2, sq_cb_inscene)
        end
        if GetTickCount() - nTickFindObj > 25000 then
          PushDebugMessage("25秒未发现怪物，开始搜索,若90秒未找到怪物，将离开副本！")
          for i = 1, #SearchPos do
            local tObj = Enum2XByClass("怪物", {0, -1})
            if #tObj > 0 then
              break
            end
            MoveTo(SearchPos[i].x, SearchPos[i].y, -1, 1, nil, MoveCallBack_state_1, sq_cb_inscene_findobj)
            Sleep(500)
          end
        end
        if GetTickCount() - nTickFindObj > 90000 then
          PushColorMsg("刷棋：90秒未发现怪物，离开副本！")
          SQ_QuitFuben()
        end
      else
        DebugStr("等待刷新棋子")
      end
      Sleep(500)
    end
    posLast = DieOutAndGetPos()
    if posLast then
      Sleep(1500)
    end
    Sleep(300)
  end
end

function _SMain(...)
  LeaveSpecialScene({m_fubenSceneID}, nil)
  local strOption = "#{QJYH_150315_02}"
  if m_QuickMode then
    strOption = "#{QJYH_150315_03}"
  end
  CloseAllWindow()
  local teamCount = m_teamCount
  if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("棋局", 1) then
    Sleep(3000)
    if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("棋局", 1, true) then
      PushDebugMessage("刷棋：今日已完成！")
      return
    end
  end
  while true do
    if GetSceneID() == m_fubenSceneID then
      SQ_OnAction()
      PushDebugMessage("刷棋：已完成！")
      break
    elseif IsXiuXiShiScene() then
      MoveToNPC("胡小仙", 32, 14, -1, nil, nil, nil, sq_cb_xiuxishi)
      Sleep(1000)
      
      local function _LeaveScene()
        QuestFrameOptionClicked_Item("离开休息室", 1, 700)
        QuestFrameOptionClicked_Item("确定", 1, 700)
      end
      
      local strText = GetNPCEventList_Item(0)
      if "#{QJXXS_081211_01}" == strText then
        _LeaveScene()
      elseif string.find(strText, "您的队伍人数不足") then
        _LeaveScene()
      elseif string.find(strText, "不在附近") then
        _LeaveScene()
      elseif string.find(strText, "不是队长") then
        Sleep(1000)
      else
        if Team:IsCountReady(teamCount) then
          QuestFrameOptionClicked_Item("珍珑棋局", 1, 800)
          QuestFrameOptionClicked_Item(strOption, 1, 800)
        else
        end
      end
      Sleep(500)
    else
      MoveToNPC("张弈国", 267, 242, 1, nil, nil, nil, sq_cb_not_xiuxishi)
      Sleep(700)
      ChangeSceneLine()
      if Team:IsCountReady(teamCount) then
        local strText = GetNPCEventList_Item(0)
        if string.find(strText, "您的队伍人数不足", nil, true) and Team:GetMemberCount() < 3 then
          PushColorMsg("刷棋：人数不足！")
          break
        elseif string.find(strText, "你需要加入一支队伍") and Team:GetMemberCount() < 3 then
          PushColorMsg("刷棋：没有队伍！")
          break
        end
        QuestFrameOptionClicked_Item("珍珑棋局", 1, 800)
        QuestFrameOptionClicked_Item(strOption, 1, 800)
      end
    end
    if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("棋局", 1) then
      Sleep(3000)
      if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("棋局", 1, true) then
        PushDebugMessage("刷棋：今日已完成！")
        break
      end
    end
    DebugStr(m_script_name)
    Sleep(500)
  end
end

_SMain()
ScriptOnStop(m_script_name)
