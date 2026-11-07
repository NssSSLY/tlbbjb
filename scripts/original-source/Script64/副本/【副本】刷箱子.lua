-- 反编译自 dfz64.dll 内嵌字节码 002b9e15（unluac 2025-12-23；仅供分析）
local m_script_name = "刷箱子"
ScriptOnStart(m_script_name, true, true)
CDG.skill_attack = g_config.skill.shuaguai_gongji
local m_teamCount = 3
local m_QuickMode = ReadConfigBool("ZH", "xzk190")
local m_fubenSceneID = 269
local m_SearchPos = {
  {x = 63, y = 77},
  {x = 82, y = 78},
  {x = 78, y = 55},
  {x = 53, y = 53},
  {x = 50, y = 77}
}

local function IsFubenSceneID()
  return GetSceneID() == m_fubenSceneID
end

local function sxz_isboss_pos()
  local pos = Player:GetPos()
  if pos.x >= 57 and pos.x <= 72 and pos.y >= 57 and pos.y <= 72 then
    return true
  end
  return false
end

local function sxz_move_cb_inscene_findobj(fX, fY, nScene)
  PickUpLua(nil, true)
  if IsFubenSceneID() then
    local tObj = Enum2XByClass("怪物", {0, -1})
    if #tObj > 0 then
      RunTo(tObj[1].x, tObj[1].y, 0, 500)
      return false
    end
    tObj = Enum2XByName("镇宝龙王", {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      RunTo(tObj[1].x, tObj[1].y, 0, 500)
      return false
    end
    return true
  end
  return false
end

local function sxz_pick_cb()
  if IsInDebugMsg("#{ResultText_167}") then
    local xFly = 63
    local yFly = 77
    if not sxz_isboss_pos() then
      xFly = 65
      yFly = 70
    end
    local tObj = Enum2XByName("镇宝龙王", {
      1,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      xFly = tObj[1].x
      yFly = tObj[1].y
    end
    if IsFubenSceneID() then
      RunTo(xFly, yFly, 1, 500)
      Skill:UseQingGong(xFly, yFly)
      Sleep(1000)
      PlayerStateTimeOut(3, 4)
    end
    DeleteDebugMsg("#{ResultText_167}")
  end
  return true
end

local function SXZ_OnFuben()
  local nTickFindObj = -1
  local posLast
  if IsInDebugMsgTime("已杀死怪物", nil, 3600) then
    PushDebugMessage("刷箱子：已在副本中")
    nTickFindObj = GetTickCount()
  end
  
  local function _RunToBoss(aBoss)
    local bRun = RunTo(aBoss.x, aBoss.y, 3, 600)
    PlayerStateTimeOut(2, 5)
    if aBoss.dst > 3 then
      Skill:UseQingGong(aBoss.x, aBoss.y)
      Sleep(1000)
      PlayerStateTimeOut(3, 4)
    end
    return not bRun
  end
  
  DeleteDebugMsg("#{ResultText_167}")
  while IsFubenSceneID() do
    local debugnote = ""
    local tObj = Enum2XByClass("怪物", {0, -1}, 1)
    if #tObj > 0 then
      nTickFindObj = GetTickCount()
      local tmp = tObj[1]
      if tmp.name == "镇宝龙王" then
        debugnote = " 杀boss"
        if tmp.dst > 3 then
          RunTo(63, 78, 3, 2000)
        end
        if tmp.dst > 3 and g_self.isjingong then
          JinGongFarSkill(tmp.id)
        end
        FubenAttack(tmp.id)
      elseif tmp.dst > 5 then
        RunTo(tmp.x, tmp.y, 3, 1000)
      else
        FubenAttack(tmp.id)
      end
    else
      tObj = Enum2XByName("镇宝龙王", {
        1,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 and 0 == tObj[1].hp then
        nTickFindObj = GetTickCount()
        posLast = nil
        local tmp = tObj[1]
        PickUpLua()
        RunTo(tmp.x, tmp.y, 3, 700)
        if _RunToBoss(tmp) then
          PickUpLua_Boss(-1, 30, m_fubenSceneID, {
            {
              x = tmp.x,
              y = tmp.y
            }
          }, nil, sxz_pick_cb)
        end
      end
      local idLoot, pickNum = PickUpLua()
      sxz_pick_cb()
      if -1 ~= nTickFindObj then
        if posLast then
          MoveTo(posLast.x, posLast.y, -1, nil, nil, MoveCallBack_state_2, sxz_move_cb_inscene_findobj)
        end
        if IsInDebugMsgTime("已杀死怪物 200/200", nil, 600) then
          if 0 == pickNum then
            if not sxz_isboss_pos() then
              RunTo(63, 78, 0, 500)
            else
              RunTo(65, 70, 0, 500)
            end
          end
        elseif GetTickCount() - nTickFindObj > 35000 then
          PushDebugMessage("35秒未发现怪物，开始搜索怪物")
          for i = 1, #m_SearchPos do
            local tObj = Enum2XByClass("怪物", {0, -1})
            if not (not (#tObj > 0) and IsInFubenScene()) then
              break
            end
            local pos = m_SearchPos[i]
            MoveTo(pos.x, pos.y, -1, nil, nil, MoveCallBack_state_1, sxz_move_cb_inscene_findobj)
            Sleep(500)
          end
        end
      else
        DebugStr("等待刷新箱子")
      end
    end
    posLast = DieOutAndGetPos()
    if posLast then
      Sleep(1500)
    end
    Sleep(300)
    DebugStr("刷箱子副本 " .. debugnote)
  end
end

function _SMain(...)
  LeaveSpecialScene({m_fubenSceneID}, nil)
  local strOption = "#{LLXB_8815_25}"
  if m_QuickMode then
    strOption = "#{LLXB_8815_26}"
  end
  if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("楼兰寻宝", 1) then
    Sleep(3000)
    if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("楼兰寻宝", 1, true) then
      PushDebugMessage("刷箱子：今日已完成！")
      return
    end
  end
  while true do
    if IsFubenSceneID() then
      SXZ_OnFuben()
      PushDebugMessage("刷箱子：完成！")
      RunTo(162, 75)
      break
    else
      GoToSceneNPC("金久灵", 162, 75, 246)
      Sleep(500)
      ChangeSceneLine()
      QuestFrameOptionClicked_Item("楼兰寻宝", 1, 700)
      local strText = GetNPCEventList_Item(0)
      if string.find(strText, "#{LLXB_8815_09}", nil, true) then
        PushDebugMessage("刷箱子：时间不对！")
        break
      elseif string.find(strText, "#{LLXB_8815_24}", nil, true) then
        local teamCount = m_teamCount
        if Team:IsCountReady(teamCount) then
          QuestFrameOptionClicked_Item(strOption, 1, 800)
          local strText = GetNPCEventList_Item(0)
          if "#{LLXB_8815_10}" == strText then
            PushDebugMessage("刷箱子：刷箱子没有队伍！")
            break
          elseif "#{LLXB_8815_12}" == strText then
            PushDebugMessage("刷箱子：刷箱子人数不足！")
            break
          end
        end
      end
      Sleep(1000)
    end
    if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("楼兰寻宝", 1) then
      Sleep(3000)
      if GetSceneID() ~= m_fubenSceneID and IsHuodongComplete("楼兰寻宝", 1, true) then
        PushDebugMessage("刷箱子：今日已完成！")
        break
      end
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  SXZ_OnFuben = nil
end

_SMain()
ScriptOnStop(m_script_name)
