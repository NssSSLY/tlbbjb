-- 反编译自 dfz64.dll 内嵌字节码 002fef1e（unluac 2025-12-23；仅供分析）
local m_script_name = "缥缈峰(大)"
ScriptOnStart(m_script_name, true, true)
local m_teamCount = HandleTextToNumber(ReadConfigText("ZH", "bjk138"), 6)
local m_param = {
  swcq = not ReadConfigBool("ZH", "xzk88"),
  msqs = ReadConfigBool("ZH", "xzk158"),
  ddq = ReadConfigBool("ZH", "xzk226"),
  xiaohao = GetConfigBool("副本", "小号模式"),
  take_dkt = ReadConfigBool("ZH", "xzk219"),
  stg_zw = true,
  fubentype = 2,
  holdboss = false,
  sceneName = "缥缈峰",
  sceneID = 261
}
CDG.hp.em_raid = false
g_pick.check = true
g_pick.pickmode = 0
m_param.FBType = ReadConfigText("ZH", "dpmf_type")

function _SMain(...)
  LoadScript("fn缥缈峰")
  local bIsTakeDKT = false
  m_param.bossNameBZ = ""
  if m_param.FBType == "普通" then
    m_param.bossNameBZ = ""
    m_param.m_fb_text = "楼兰大缥缈"
    m_param.m_fb_next = 2
  elseif m_param.FBType == "初级" then
    m_param.bossNameBZ = "·闻恶"
    m_param.m_fb_text = "楼兰大缥缈·初级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "中级" then
    m_param.bossNameBZ = "·识恶"
    m_param.m_fb_text = "楼兰大缥缈·中级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "高级" then
    m_param.bossNameBZ = "·罚恶"
    m_param.m_fb_text = "楼兰大缥缈·高级"
    m_param.m_fb_next = 4
  end
  while true do
    local debugnote = ""
    local sceneID = GetSceneID()
    if sceneID == m_param.sceneID or IsHuodongComplete("楼兰大缥缈", 2) == false then
      if sceneID ~= m_param.sceneID then
        if false == bIsTakeDKT then
          PMF_BankTakeOutBiYuTao(m_param.take_dkt)
          bIsTakeDKT = true
        end
        GoToSceneNPC("程青霜", 192, 222, 246)
        ChangeSceneLine()
        CheckAllTeamHP(85, MoveCallback_NoFuben, 25)
        local teamCount = m_teamCount
        if Player:IsLeader() and Team:IsCountReady(teamCount) then
          if IsTeamSteady() then
            debugnote = ""
            Sleep(2000)
            TalkNpc("程青霜")
            Sleep(1000)
            if m_param.FBType == "普通" then
              PushColorMsg("普通")
              QuestFrameOptionClicked_Item("挑战缥缈峰", 1, 1500)
            elseif m_param.FBType == "初级" then
              QuestFrameOptionClicked_Item("#{XKFB_250115_12}", 1, 2000)
            elseif m_param.FBType == "中级" then
              QuestFrameOptionClicked_Item("#{XKFB_250115_51}", 1, 1500)
            elseif m_param.FBType == "高级" then
              QuestFrameOptionClicked_Item("#{XKFB_250115_13}", 1, 1500)
            end
          else
            debugnote = "等待队员集合."
            Sleep(2000)
          end
        end
      else
        PMF_Start(m_param)
        break
      end
    elseif false == IsSceneTransed() then
      Sleep(2000)
      sceneID = GetSceneID()
      if sceneID ~= m_param.sceneID and IsHuodongComplete("楼兰大缥缈", 2) then
        break
      end
    end
    Sleep(300)
    DebugStr(m_script_name .. "：等待进入副本 " .. debugnote)
  end
  if m_param.take_dkt then
    Bag_Move2TempBank(" 碧玉腰环 碧玉戒指 碧玉护符 碧玉护腕 ", 2)
  end
end

RecvState(1)
_SMain()
m_param = nil
ScriptOnStop(m_script_name, true)
