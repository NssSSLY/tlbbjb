-- 反编译自 dfz64.dll 内嵌字节码 002e1226（unluac 2025-12-23；仅供分析）
local m_script_name = "四绝庄"
ScriptOnStart(m_script_name, true, true)
local m_param = {}
m_param.swcq = GetConfigBool("四绝庄", "死亡出窍")
m_param.boss1qiaozhong = not GetConfigBool("四绝庄", "Boss1不敲钟")
m_param.boss2diagonal = GetConfigBool("四绝庄", "Boss2跑对角")
m_param.boss2xhfd = GetConfigBool("四绝庄", "Boss2分担失明")
m_param.boss4longzhu = not GetConfigBool("四绝庄", "Boss4不跑龙柱")
m_param.xiaohao = GetConfigBool("副本", "小号模式")
m_param.FBType = ReadConfigText("ZH", "sjz_type")
m_param.zhidian = true
m_param.missionName = "#{SJZ_100129_03}"
m_param.sceneID = 291
local m_teamCount = HandleTextToNumber(GetConfigText("组队人数", "四绝庄"), 6)

function _SMain()
  Sleep(100)
  LoadScript("fn四绝庄")
  local bOver = false
  m_param.bossNameBZ = ""
  if m_param.FBType == "普通" then
    m_param.bossNameBZ = ""
    m_param.m_fb_text = "讨伐燕子坞"
    m_param.m_fb_next = 2
  elseif m_param.FBType == "初级" then
    m_param.bossNameBZ = "·闻恶"
    m_param.m_fb_text = "讨伐燕子坞·初级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "中级" then
    m_param.bossNameBZ = "·识恶"
    m_param.m_fb_text = "讨伐燕子坞·中级"
    m_param.m_fb_next = 4
  elseif m_param.FBType == "高级" then
    m_param.bossNameBZ = "·罚恶"
    m_param.m_fb_text = "讨伐燕子坞·高级"
    m_param.m_fb_next = 4
  end
  while true do
    local debugnote = ""
    if GetSceneID() == m_param.sceneID then
      bOver = true
      SJZ_Start(m_param)
    else
      GoToSceneNPC("潘菁菁", 195, 214, 1)
      ChangeSceneLine()
      Sleep(500)
      local nIndex, idMission, idScript = GetPlayerMission_Item(m_param.missionName)
      if -1 == nIndex then
        if bOver then
          Sleep(2000)
          if GetSceneID() ~= m_param.sceneID then
            break
          end
        end
        PushDebugMessage("四绝庄：未接取任务")
        ClearDbgMsg()
        FubenAttack(-1)
        QuestFrameOptionClicked_Item(m_param.missionName, 1, 1000)
        QuestFrameAcceptClicked(1000)
        local szText = GetNPCEventList_Item(0)
        if "#{SJZ_100129_08}" == szText then
          if GetSceneID() ~= m_param.sceneID then
            break
          end
        elseif string.find(szText, "#{SJZ_100129_22}", nil, true) and GetSceneID() ~= m_param.sceneID then
          break
        end
      elseif 1 == GetMissionComplete(nIndex) then
        ClearDbgMsg()
        QuestFrameOptionClicked_Item(m_param.missionName, 1, 1000)
        QuestFrameMissionComplete(nil, 1200)
      elseif 2 == GetMissionComplete(nIndex) then
        PushDebugMessage("四绝庄:任务失败,放弃任务！")
        Sleep(2000)
        QuestFrameMissionAbnegate(idScript)
        ClearDbgMsg()
      else
        debugnote = "四绝庄:已接任务,等待进入副本"
        if GetChangeSceneTimeDiff() > 3 then
          FubenAttack(-1)
        end
        if Team:IsInSameScene() and Player:IsLeader() then
          CheckAllTeamHP(80, OtherCallback_NoFuben)
        end
        local teamCount = m_teamCount
        if not Player:IsLeader() or Player:IsLeader() and Team:IsCountReady(teamCount) or Team:IsInSameScene() == false then
          QuestFrameOptionClicked_Item(m_param.missionName, 1, 1500)
          Sleep(1000)
          if m_param.FBType == "普通" then
            QuestFrameOptionClicked_Item("#{SJZ_100129_11}", 1, 1500)
          elseif m_param.FBType == "初级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_04}", 1, 1000)
          elseif m_param.FBType == "中级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_47}", 1, 1500)
          elseif m_param.FBType == "高级" then
            QuestFrameOptionClicked_Item("#{XKFB_250115_05}", 1, 1500)
          end
        end
      end
    end
    DebugStr("四绝庄 " .. debugnote)
    Sleep(300)
  end
  EatFubenItem(10)
end

_SMain()
ScriptOnStop(m_script_name, true)
m_param = nil
