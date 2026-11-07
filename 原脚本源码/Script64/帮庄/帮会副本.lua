-- 反编译自 dfz64.dll 内嵌字节码 0034fff0（unluac 2025-12-23；仅供分析）
local m_script_name = "帮会副本"
ScriptOnStart(m_script_name, true, true)
g_config.fuben.sjz_swcq = GetConfigBool("四绝庄", "死亡出窍")
g_config.fuben.sjz_bqz = GetConfigBool("四绝庄", "Boss1不敲钟")
g_config.fuben.sjz_pdj = GetConfigBool("四绝庄", "Boss2跑对角")
g_config.fuben.sjz_xhfd = GetConfigBool("四绝庄", "Boss2分担失明")
g_config.fuben.sjz_bplz = GetConfigBool("四绝庄", "Boss4不跑龙柱")
g_config.fuben.lhfd_hsdzpw = ReadConfigBool("ZH", "xzk217")
g_config.team.count_sjz = HandleTextToNumber(GetConfigText("组队人数", "四绝庄"), 6)
g_config.team.count_lhfd = HandleTextToNumber(ReadConfigText("ZH", "bjk145"), 6)
local m_param = {}
m_param.swcq = g_config.fuben.sjz_swcq
m_param.boss1qiaozhong = not g_config.fuben.sjz_bqz
m_param.boss2diagonal = g_config.fuben.sjz_pdj
m_param.boss2xhfd = g_config.fuben.sjz_xhfd
m_param.boss4longzhu = not g_config.fuben.sjz_bplz
m_param.xiaohao = g_config.nottongbu.fuben_ty_xhmode
m_param.zhidian = true
m_param.missionName = "#{SJZ_100129_03}"
m_param.sceneID = 291
local m_param2 = {
  knMode = false,
  mustMP100 = false,
  hsFollow = g_config.fuben.lhfd_hsdzpw,
  sceneName = "琅嬛福地",
  sceneID = 677,
  callback = nil
}

function _SMain(...)
  LoadScript("fn四绝庄")
  LoadScript("fn琅嬛福地_旧版")
  while true do
    local debugnote = ""
    local nSceneID = GetSceneID()
    if nSceneID == m_param.sceneID then
      SJZ_Start(m_param)
      break
    elseif nSceneID == m_param2.sceneID then
      LHFD_Start(m_param2)
      break
    else
      if GoToGuild() == false then
        break
      end
      MoveToNPC("龙三木", 66, 129, -1, nil, nil, nil, MoveCallback_InMyGuild)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{BHFLGTMB_210714_156}", 1, 1000)
      local strItem = GetNPCEventList_Item(0)
      if string.find(strItem, "#{BHFLGTMB_210714_158}", nil, true) then
        LogMsg(m_script_name .. ":未开启")
        break
      elseif FindQuestFrameOption("#{BHFLGTMB_210714_94}") then
        local teamCount = HandleTextToNumber(g_config.team.count_sjz, 6)
        if not Player:IsLeader() or Player:IsLeader() and Team:IsCountReady(teamCount) or false == Team:IsInSameScene() then
          QuestFrameOptionClicked_Item("#{BHFLGTMB_210714_94}", 1, 800)
        end
      elseif FindQuestFrameOption("#{BHFLGTMB_210714_95}") then
        FubenAttack(-1)
        CDG.hp.em_raid = false
        CDG.skill_attack_jinji_disable = "指点江山 昭君出塞"
        g_pick.pickmode = 0
        g_pick.check = true
        local teamCount = HandleTextToNumber(g_config.team.count_lhfd, 6)
        if Player:IsLeader() and Team:IsCountReady(teamCount) then
          if IsTeamSteady() then
            QuestFrameOptionClicked_Item("#{BHFLGTMB_210714_95}", 1, 800)
          else
            debugnote = " 等待队员集合."
          end
        end
      elseif FindQuestFrameOption("#{BHFLGTMB_210714_96}") then
        FubenAttack(-1)
        m_param2.knMode = true
        CDG.hp.em_raid = false
        CDG.skill_attack_jinji_disable = "指点江山 昭君出塞"
        g_pick.pickmode = 0
        g_pick.check = true
        local teamCount = HandleTextToNumber(g_config.team.count_lhfd, 6)
        if Player:IsLeader() and Team:IsCountReady(teamCount) then
          if IsTeamSteady() then
            QuestFrameOptionClicked_Item("#{BHFLGTMB_210714_96}", 1, 800)
          else
            debugnote = " 等待队员集合."
          end
        end
      end
    end
    Sleep(600)
    DebugStr(m_script_name .. debugnote)
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
