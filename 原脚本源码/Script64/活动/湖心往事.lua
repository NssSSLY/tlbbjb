-- 反编译自 dfz64.dll 内嵌字节码 0043905b（unluac 2025-12-23；仅供分析）
local m_script_name = "湖心往事"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  if GetSceneID() ~= 1031 then
    Team:LeaveTeam()
    GoToSceneNPC("宁采臣", 69, 146, 1039)
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(77);")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = Qixi_HuaJuan_Env});Qixi_HuaJuan_Story_Goto();")
    Sleep(1000)
    GoToSceneNPC("宁采臣", 69, 146, 1039)
    Sleep(300)
    Dismount()
    QuestFrameOptionClicked_Item("#{QNHJ_250609_08}", 1, 600)
    Sleep(1000)
    QuestFrameMissionComplete(nil, 700)
    Sleep(1000)
    QuestFrameAcceptClicked(2000)
    Sleep(1000)
    QuestFrameMissionComplete(nil, 700)
  end
  while true do
    Team:LeaveTeam()
    local nIndex = GetPlayerMission_Item("#{HXWS_20250613_62}")
    if -1 == nIndex then
      DeleteDebugMsg("#{HXWS_20250613_31}")
      GoToSceneNPC("宁采臣", 69, 146, 1039)
      Sleep(300)
      Dismount()
      QuestFrameOptionClicked_Item("#{HXWS_20250613_11}", 1, 600)
      Sleep(1000)
      QuestFrameAcceptClicked(2000)
      local nTransTime = GetSceneTransTime()
      local nMsg1, szMsgText, nMsgTime1 = IsInDebugMsgTime("#{HXWS_20250613_31}", nil, 1001)
      if nMsg1 and nTransTime < nMsgTime1 then
        break
      end
    else
      local nParam = GetMissionComplete(nIndex)
      if 0 == nParam then
        if GetSceneID() == 1031 then
          GoToSceneNPC("聂小倩", 64, 34, 1031)
          Sleep(300)
          QuestFrameOptionClicked_Item("#{HXWS_20250613_9}", 1, 600)
        end
      else
        GoToSceneNPC("宁采臣", 69, 146, 1039)
        Sleep(300)
        QuestFrameOptionClicked_Item("#{HXWS_20250613_11}", 1, 600)
        Sleep(1000)
        GetLuaValue("setmetatable(_G, {__index = Qixi_HuaJuan_Env});Qixi_HuaJuan_RewardClicked(1)")
        break
      end
    end
  end
end

_SMain()
ScriptOnStop(m_script_name, true)
