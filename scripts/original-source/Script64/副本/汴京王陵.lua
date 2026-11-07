-- 反编译自 dfz64.dll 内嵌字节码 002fd8cc（unluac 2025-12-23；仅供分析）
local m_script_name = "汴京王陵"
ScriptOnStart(m_script_name, true, true)
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk141"), 6)
local m_param = {}
m_param.xiaohao = g_config.nottongbu.fuben_ty_xhmode
m_param.yz_unrun = false
m_param.sceneID = 600
m_param.gd_dist = 4

function _SMain(...)
  LoadScript("fn王陵")
  local nWaitTimeOut = -1
  while true do
    local debugnote = ""
    IsWindowVisible("T3XinTianWai_Guide", "T3XinTianWai_Guide_OnClose()")
    local sceneID = GetSceneID()
    if sceneID == m_param.sceneID or IsHuodongComplete("凤鸣王陵", 2) == false then
      if sceneID == m_param.sceneID then
        WL_OnAction(m_param)
        break
      else
        WL_InitData()
        if IsKVKSceneName() then
          BJ_MoveToNPC_team("萧陵", 410, 380, BJ_GetRunSceneID())
          if -1 == nWaitTimeOut then
            nWaitTimeOut = GetTickCount()
          end
          if GetDist(410, 380) < 10 then
            FubenAttack(-1)
            Sleep(500)
          end
          local teamCount = m_teamCount
          if not (Player:IsLeader() and WL_IsOldTeamReady(nWaitTimeOut) and IsTeamSteady() and Team:IsCountReady(teamCount)) then
            goto lbl_146
          end
          QuestFrameOptionClicked_Item("#{FMZLW_111219_03}", 1, 1000)
          if not WL_CheckJinRi() then
            goto lbl_146
          end
          Sleep(2000)
          if GetSceneID() ~= m_param.sceneID then
            break
          end
        else
          WL_GetOldTeam()
          BJ_MoveToNPC_team("萧陵", 410, 380, BJ_GetRunSceneID())
          Sleep(500)
        end
      end
    else
      Sleep(2000)
      if GetSceneID() ~= m_param.sceneID and IsHuodongComplete("凤鸣王陵", 2) then
        Sleep(2000)
        if GetSceneID() ~= m_param.sceneID and IsHuodongComplete("凤鸣王陵", 2) then
          PushDebugMessage(m_script_name .. ":已完成")
          break
        end
      end
    end
    ::lbl_146::
    Sleep(300)
    DebugStr("汴京王陵 " .. debugnote)
  end
  Player:TeamFollow(false, 300)
end

RecvState(1)
_SMain()
ScriptOnStop(m_script_name, true)
m_param = nil
