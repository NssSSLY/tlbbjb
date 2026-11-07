-- 反编译自 dfz64.dll 内嵌字节码 002fe064（unluac 2025-12-23；仅供分析）
local m_script_name = "琅嬛福地(困难)"
ScriptOnStart(m_script_name, true, true)
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk145"), 6)
CDG.hp.em_raid = false
CDG.skill_attack_jinji_disable = "指点江山 昭君出塞"
g_pick.pickmode = 0
g_pick.check = true
local m_param = {
  knMode = true,
  mustMP100 = false,
  hsFollow = ReadConfigBool("ZH", "xzk217"),
  sceneName = "琅嬛福地",
  sceneID = 677,
  callback = nil
}

function _SMain()
  LoadScript("fn琅嬛福地_旧版")
  while true do
    local debugnote = ""
    if GetSceneID() == m_param.sceneID then
      LHFD_Start(m_param)
      break
    else
      if IsHuodongComplete("琅嬛福地(困难)", 2) then
        Sleep(3000)
        if IsHuodongComplete("琅嬛福地(困难)", 2) and GetSceneID() ~= m_param.sceneID then
          PushDebugMessage(m_script_name .. ":已完成")
          break
        end
      end
      GoToSceneNPC("李青萝", 292, 92, 2)
      ChangeSceneLine()
      Sleep(800)
      FubenAttack(-1)
      local teamCount = m_teamCount
      if Player:IsLeader() and Team:IsCountReady(teamCount) then
        if IsTeamSteady() then
          if m_param.knMode then
            QuestFrameOptionClicked_Item("#{LHFD_160203_03}", 1, 1500)
          else
            QuestFrameOptionClicked_Item("#{LHFD_160203_02}", 1, 1500)
          end
        else
          debugnote = " 等待队员集合."
        end
      end
    end
    Sleep(200)
    DebugStr(m_script_name .. ":等待进入副本" .. debugnote)
  end
end

_SMain()
m_param = nil
ScriptOnStop(m_script_name, true)
