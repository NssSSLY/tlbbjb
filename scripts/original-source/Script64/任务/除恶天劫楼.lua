-- 反编译自 dfz64.dll 内嵌字节码 00291057（unluac 2025-12-23；仅供分析）
local m_script_name = "除恶天劫楼"
ScriptOnStart(m_script_name, true, false)
g_config.cetjl = {}
g_config.cetjl.mulit_poslist = {
  {x = 78, y = 55}
}
g_config.cetjl.auto_team = false
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
CDG.die.out = true

function _SMain()
  local npc = {
    name = "付劫生",
    x = 73,
    y = 79
  }
  
  local function _IsTianJieLou()
    local curScene = GetSceneID()
    if curScene >= 272 and curScene <= 279 then
      return curScene
    end
    return nil
  end
  
  local function _move_cb_in_fb(fx, fy, nScene)
    if _IsTianJieLou() then
      return true
    end
    return false
  end
  
  while true do
    local tjlScene = _IsTianJieLou()
    if tjlScene then
      local nIndex, _, _ = GetPlayerMission_Item("除恶天劫楼")
      if -1 ~= nIndex then
        if 1 == GetMissionComplete(nIndex) then
          MoveToNPC(npc.name, npc.x, npc.y, -1, nil, nil, nil, _move_cb_in_fb)
          ClearBag()
          QuestFrameOptionClicked_Item("#{TJL_xml_XX(01)}", 1, 500)
          QuestFrameMissionComplete(nil, 500)
          QuestFrameOptionClicked_Item("#{TJL_xml_XX(04)}", 1, 500)
          QuestFrameAcceptClicked(500)
        else
          CDG.pos = g_config.cetjl.mulit_poslist
          if 0 == #CDG.pos then
            CDG.pos = {
              {x = 78, y = 55}
            }
          end
          CDG.sceneID = tjlScene
          if g_self.isjingong then
            CDG.attackMode = "打死换怪"
          else
            CDG.attackMode = "优先绿怪"
          end
          CDG.pickup = false
          CDG.overMapErr = true
          CDG.die.out = true
          CDG.posRadius = 15
          CDG.tragetSelect = true
          CDG.die.maxCount = 0
          CDG.savebank = false
          CDG.posIdx = GetNearestPoint(CDG.pos)
          CDG:SetTimeOut(100)
          
          local function _attack_cb()
            DebugStr(m_script_name .. ":执行中", 2)
            local nComplete, nIndex = GetMissionVariableByName_Item("除恶天劫楼", 0)
            if 1 == nComplete or -1 == nIndex then
              return true
            end
            if not _IsTianJieLou() then
              return true
            end
            if g_config.cetjl.auto_team then
              TeamCheckNear()
            end
            return false
          end
          
          CDG.callfun = _attack_cb
          CDG.callfun_move = _move_cb_in_fb
          CDG:OnStart()
        end
      else
        MoveToNPC(npc.name, npc.x, npc.y, -1, nil, nil, nil, _move_cb_in_fb)
        if QuestFrameOptionClicked_Item("#{TJL_xml_XX(01)}", 1, 1000) then
          local szText = GetNPCEventList_Item(0)
          if "#{TJL_090714_02}" == szText then
            PushDebugMessage(m_script_name .. "：今日已做完")
            break
          end
          QuestFrameAcceptClicked(500)
          CloseWindow("Quest")
        end
      end
    else
      if Player:GetHPP() < 70 then
        PushDebugMessage(m_script_name .. ":角色血量低，校场回血")
        XiaoChangHuiXue(100)
      end
      GoToSceneNPC("付劫生", 94, 201, 2)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{TJL_xml_XX(02)}", 1, 1500)
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  while _IsTianJieLou() do
    MoveTo(82, 80, -1, nil, nil, nil, _move_cb_in_fb)
    Sleep(500)
    DebugStr(m_script_name .. ":离开天劫楼")
  end
  if g_config.cetjl.auto_team then
    Team:LeaveTeam()
  end
end

_SMain()
ScriptOnStop(m_script_name)
