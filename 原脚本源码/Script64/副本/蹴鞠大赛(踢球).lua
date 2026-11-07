-- 反编译自 dfz64.dll 内嵌字节码 0031bd09（unluac 2025-12-23；仅供分析）
local m_script_name = "蹴鞠大赛"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
g_pick.pickmode = 0
local m_teamCount = 3
local m_param = {}
m_param.sceneID = 233
local m_npc = {
  {
    sceneID = LUOYANG_ID,
    x = 301,
    y = 192,
    name = "童贯"
  },
  {
    sceneID = 1,
    x = 283,
    y = 241,
    name = "于倩倩"
  },
  {
    sceneID = 2,
    x = 295,
    y = 131,
    name = "夏青青"
  }
}

local function TQ_OnAction()
  local function tq_cb_fb(fX, fY, nScene)
    PickUpLua(nil, true)
    
    if GetSceneID() == m_param.sceneID then
      return true
    end
    return false
  end
  
  while GetSceneID() == m_param.sceneID do
    if -1 == Player:GetBuff("被打醒") then
      PickUpLua(nil, true)
      local tObj = Enum2XByClass("怪物", {0, -1}, 1)
      if #tObj > 0 then
        local tmp = tObj[1]
        MoveTo(tmp.x, tmp.y, -1, nil, nil, nil, tq_cb_fb)
        FubenAttack(tmp.id)
      elseif -1 ~= Player:GetBuff("蹴鞠光环") then
        PickUpLua_Boss(15, 15, nil)
        MoveTo(37, 31, -1, 3, true, nil, tq_cb_fb)
        Sleep(800)
        local tObj = Enum2XByName(" 童贳 于倩倩 夏青青 ", {
          1,
          0,
          0,
          0
        }, nil, nil, 3)
        if #tObj > 0 then
          TalkNpc(tObj[1].name, 800)
          DialogOptionClicked("送", 3, 800)
        end
      end
    end
    Sleep(300)
    DebugStr("踢球中.")
  end
end

function _SMain()
  while true do
    if GetSceneID() == m_param.sceneID then
      TQ_OnAction()
      PushColorMsg("踢球:已完成")
      break
    else
      local curSceneID = GetSceneID()
      local npc = m_npc[2]
      if curSceneID == LUOYANG_ID then
        npc = m_npc[1]
      elseif 2 == curSceneID then
        npc = m_npc[3]
      end
      if Player:IsLeader() then
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        local teamCount = m_teamCount
        if Team:IsCountReady(teamCount) then
          Sleep(600)
          QuestFrameOptionClicked_Item("横扫牡丹碗", 1, 1000)
        end
      else
        local function tqdy_cb(fX, fY, nScene)
          local leader, isleader = Team:GetLeaderInfo()
          
          if leader and leader.sceneID == m_param.sceneID then
            return false
          end
          if GetSceneID() == m_param.sceneID then
            return false
          end
          return MoveCallBack_GoToLeader(fX, fY, nScene)
        end
        
        GoToLeader(tqdy_cb)
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. " 踢球")
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_npc = nil
