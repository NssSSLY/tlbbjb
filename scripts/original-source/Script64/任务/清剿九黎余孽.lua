-- 反编译自 dfz64.dll 内嵌字节码 002842e0（unluac 2025-12-23；仅供分析）
local m_script_name = "清剿：九黎余孽"
ScriptOnStart(m_script_name, true, false)

function _SMain(...)
  local m_npc = {
    {
      x = 172,
      y = 102,
      sceneID = 857,
      sceneName = "天岐南淮",
      name = "贾明达"
    },
    {
      x = 138,
      y = 126,
      sceneID = 856,
      sceneName = "忘川花海",
      name = "梁天和"
    },
    {
      x = 140,
      y = 35,
      sceneID = 855,
      sceneName = "漠南青原",
      name = "栾英博"
    }
  }
  local npc = m_npc[1]
  g_config.qjjlyn = {}
  g_config.qjjlyn.auto_team = false
  g_config.qjjlyn.npc = {
    sel = -1,
    text = "",
    data = 0
  }
  local idxNpc = ReadConfigInt("ZH", "zhk51") + 1
  if m_npc[idxNpc] then
    g_config.qjjlyn.npc.text = m_npc[idxNpc].name
  end
  local posFile = GetUserScriptPath("坐标清剿九黎余孽.lua")
  if "" ~= posFile then
    if false == LoadUserPathScript(posFile) then
      PushColorMsg(m_script_name .. ":加载自定义坐标失败,请检查语法或者删除自定义坐标")
      return false
    end
  else
    LoadScript("坐标清剿九黎余孽")
  end
  for i = 1, #m_npc do
    local tmp = m_npc[i]
    if g_config.qjjlyn.npc.text ~= "" and string.find(g_config.qjjlyn.npc.text, tmp.name, nil, true) then
      npc = m_npc[i]
      break
    end
  end
  CDG.attack = true
  CDG.sceneName = "苍梧秘境"
  CDG.sceneID = 698
  if g_self.isjingong then
    if CDG.pet1.GUID > 0 then
      CDG.attackMode = "宠拉人打"
    else
      CDG.attackMode = "打死换怪"
    end
  else
    CDG.attackMode = "优先绿怪"
  end
  CDG.pos = m_pos1
  if 0 == #CDG.pos then
    CDG.pos = {
      {x = 135, y = 72}
    }
  end
  CDG.posRadius = 5
  CDG.buji = false
  CDG.targetOwer = "红绿"
  CDG.tragetSelect = true
  CDG.die.out = true
  CDG.die.maxCount = 0
  CDG.savebank = false
  while true do
    local nIndex, idMission, idScript = GetPlayerMission(m_script_name)
    local nComplete = GetMissionComplete(nIndex)
    if -1 == nComplete then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(600)
      QuestFrameOptionClicked_Item("#{JXMR_171027_06}", 1, 600)
      QuestFrameAcceptClicked(800)
      local strText = GetNPCEventList_Item(0)
      if string.find(strText, "#{JXMR_171027_10}", nil, true) then
        PushColorMsg(m_script_name .. "已完成")
        break
      end
    elseif 0 == nComplete then
      local function mis_callback(...)
        local nIndex, idMission, idScript = GetPlayerMission(m_script_name)
        
        local nComplete = GetMissionComplete(nIndex)
        if 0 ~= nComplete then
          if g_config.qjjlyn.auto_team then
            Team:LeaveTeam()
          end
          return true
        end
        if g_config.qjjlyn.auto_team then
          TeamCheckNear()
        end
        DebugStr("清剿九黎余孽:任务中", 2)
        return false
      end
      
      CDG.callfun = mis_callback
      CDG:OnStart()
    elseif 1 == nComplete then
      Bag_DeleteItem()
      Skill:UseName("初级隐遁", 500)
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Sleep(600)
      QuestFrameOptionClicked_Item("#{JXMR_171027_06}", 1, 700)
      QuestFrameMissionComplete(nil, 600)
    end
    DebugStr("清剿九黎余孽")
    Sleep(200)
  end
  if g_config.qjjlyn.auto_team then
    Team:LeaveTeam()
  end
  GoToScene(158, 140, 850, nil, nil, nil, nil, false, false)
end

_SMain()
ScriptOnStop(m_script_name)
