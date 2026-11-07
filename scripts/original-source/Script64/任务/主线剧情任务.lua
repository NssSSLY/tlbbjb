-- 反编译自 dfz64.dll 内嵌字节码 0024e474（unluac 2025-12-23；仅供分析）
local m_script_name = "主线剧情任务"
ScriptOnStart(m_script_name, true, false)
local m_npc = {
  x = 160,
  y = 158,
  sceneID = 2,
  name = "赵天师"
}
local m_finish = {
  wjg = false,
  yzw = false,
  jxz = false,
  cms = false,
  lgs = false,
  ypt = false,
  sss = false
}
local m_current_scene = -1

function JQ_IsFubenScene(aSceneName)
  local nowScene = GetCurrentSceneName()
  if string.find(nowScene, aSceneName, nil, true) then
    return true
  end
  return false
end

function JQ_callback_run(fX, fY, nScene)
  local strSceneName = GetCurrentSceneName()
  if string.find(strSceneName, "万劫谷", nil, true) then
    return false
  elseif string.find(strSceneName, "燕子坞", nil, true) then
    return false
  elseif string.find(strSceneName, "聚贤庄", nil, true) then
    return false
  elseif string.find(strSceneName, "苍茫山", nil, true) then
    return false
  elseif "擂鼓山" == strSceneName then
    return false
  elseif "一品堂" == strSceneName then
    return false
  elseif "少室山（剧情）" == strSceneName then
    return false
  end
  return true
end

function JQ_QueryProcess()
  MoveToNPC(m_npc.name, m_npc.x, m_npc.y, m_npc.sceneID, nil, nil, nil, JQ_callback_run)
  Sleep(500)
  QuestFrameOptionClicked_Item("剧情任务介绍", 1, 700)
  QuestFrameOptionClicked_Item("我现在进行到哪里了？", 1, 700)
  local strProcess = GetNPCEventList_Item(0)
  return strProcess
end

function JQ_mission_accept(npc, strMission)
  MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
  Sleep(500)
  mission_complete_accept(strMission, false, false, true)
end

function JQ_mission_complete(npc, strClicked)
  MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, JQ_callback_run)
  Sleep(500)
  mission_complete_accept(strClicked, false, true, true)
end

function _SMain()
  LoadScript("mission")
  LoadScript("fn剧情_万劫谷")
  LoadScript("fn剧情_燕子坞")
  LoadScript("fn剧情_聚贤庄")
  LoadScript("fn剧情_苍茫山")
  LoadScript("fn剧情_擂鼓山")
  LoadScript("fn剧情_一品堂")
  LoadScript("fn剧情_少室山")
  local fnCall
  while true do
    local debugnote = ""
    local bDoMission = false
    if m_finish.wjg == false then
      debugnote = "万劫谷"
      bDoMission = JQ_WJG_DoMission()
    end
    if false == bDoMission and false == m_finish.yzw then
      debugnote = "燕子坞"
      bDoMission = JQ_YZW_DoMission()
      if bDoMission then
        m_finish.wjg = true
      end
    end
    if false == bDoMission and false == m_finish.jxz then
      debugnote = "聚贤庄"
      bDoMission = JQ_JXZ_DoMission()
      if bDoMission then
        m_finish.wjg = true
        m_finish.yzw = true
      end
    end
    if false == bDoMission and false == m_finish.cms then
      debugnote = "苍茫山"
      bDoMission = JQ_CMS_DoMission()
      if bDoMission then
        m_finish.wjg = true
        m_finish.yzw = true
        m_finish.jxz = true
      end
    end
    if false == bDoMission and false == m_finish.lgs then
      debugnote = "擂鼓山"
      bDoMission = JQ_LGS_DoMission()
      if bDoMission then
        m_finish.wjg = true
        m_finish.yzw = true
        m_finish.jxz = true
        m_finish.cms = true
      end
    end
    if false == bDoMission and false == m_finish.ypt then
      debugnote = "一品堂"
      bDoMission = JQ_YPT_DoMission()
      if bDoMission then
        m_finish.wjg = true
        m_finish.yzw = true
        m_finish.jxz = true
        m_finish.cms = true
        m_finish.lgs = true
      end
    end
    if false == bDoMission and false == m_finish.sss then
      debugnote = "少室山"
      bDoMission = JQ_SSS_DoMission()
      if bDoMission then
        m_finish.wjg = true
        m_finish.yzw = true
        m_finish.jxz = true
        m_finish.cms = true
        m_finish.lgs = true
        m_finish.ypt = true
      end
    end
    if false == bDoMission then
      if fnCall then
        debugnote = debugnote .. " 查询"
        fnCall()
      else
        local strSceneName = GetCurrentSceneName()
        if "万劫谷" == strSceneName then
          JQ_WJG_runto_pos_wjg_out()
        elseif "燕子坞" == strSceneName then
          JQ_runto_pos_yzw_out()
        elseif "聚贤庄" == strSceneName then
          JQ_runto_pos_jxz_out()
        elseif "苍茫山" == strSceneName then
          JQ_runto_pos_cms_out()
        elseif "擂鼓山" == strSceneName then
          JQ_runto_pos_lgs_out()
        elseif "一品堂" == strSceneName then
          JQ_runto_pos_ypt_out()
        elseif "少室山（剧情）" == strSceneName then
          JQ_runto_pos_sss_out()
        else
          local strProcess = JQ_QueryProcess()
          if "你现在已经完成了#G万劫谷、燕子坞、聚贤庄、苍茫山、擂鼓山、一品堂#W和#G少室山#W剧情任务。" == strProcess then
            break
          end
          debugnote = " 万劫谷系列任务..."
          fnCall = JQ_WJG_IsInProcess(strProcess)
          if nil == fnCall then
            debugnote = " 燕子坞系列任务..."
            fnCall = JQ_YZW_IsInProcess(strProcess)
          end
          if nil == fnCall then
            debugnote = " 聚贤庄系列任务..."
            fnCall = JQ_JXZ_IsInProcess(strProcess)
          end
          if nil == fnCall then
            debugnote = " 苍茫山系列任务..."
            fnCall = JQ_CMS_IsInProcess(strProcess)
          end
          if nil == fnCall then
            debugnote = " 擂鼓山系列任务..."
            fnCall = JQ_LGS_IsInProcess(strProcess)
          end
          if nil == fnCall then
            debugnote = " 一品堂系列任务..."
            fnCall = JQ_YPT_IsInProcess(strProcess)
          end
          if nil == fnCall then
            debugnote = " 少室山系列任务..."
            fnCall = JQ_SSS_IsInProcess(strProcess)
          end
        end
      end
    else
      fnCall = nil
    end
    Sleep(50)
    DebugStr("剧情任务 " .. debugnote)
  end
end

_SMain()
ScriptOnStop(m_script_name)
