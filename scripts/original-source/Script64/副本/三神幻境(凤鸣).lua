-- 反编译自 dfz64.dll 内嵌字节码 002bb430（unluac 2025-12-23；仅供分析）
local m_script_name = "三神幻境"
ScriptOnStart(m_script_name, true, true)
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk140"), 6)
local m_param = {
  swcq = ReadConfigBool("ZH", "xzk137"),
  keyBox = ReadConfigBool("ZH", "xzk87"),
  ybBox = ReadConfigBool("ZH", "xzk157"),
  xiaohao = g_config.nottongbu.fuben_ty_xhmode,
  sceneName = "三神幻境",
  sceneID = 662
}
CDG.hp.em_raid = false
g_pick.pickmode = 0
g_pick.check = true

function _SMain(...)
  LoadScript("fn三神幻境")
  while true do
    IsWindowVisible("T3XinTianWai_Guide", "T3XinTianWai_Guide_OnClose()")
    local sceneID = GetSceneID()
    if sceneID == m_param.sceneID or IsHuodongComplete("三神幻境", 2) == false then
      if sceneID ~= m_param.sceneID then
        GoToSceneNPC("碧落", 289, 81, 850)
        FubenAttack(-1)
        Sleep(800)
        local teamCount = m_teamCount
        if Player:IsLeader() and Team:IsCountReady(teamCount) then
          QuestFrameOptionClicked_Item("#{FMYZ_180529_2}", 1, 1500)
        end
        Sleep(300)
      else
        SSHJ_Start(m_param)
        break
      end
    else
      Sleep(2000)
      sceneID = GetSceneID()
      if sceneID ~= m_param.sceneID and IsHuodongComplete("三神幻境", 2) then
        break
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. ":等待进入副本")
  end
  Player:TeamFollow(false, 300)
end

_SMain()
m_param = nil
ScriptOnStop(m_script_name, true)
