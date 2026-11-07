-- 反编译自 dfz64.dll 内嵌字节码 0053b980（unluac 2025-12-23；仅供分析）
local m_cmp = {
  sceneID = -1,
  sceneName = "",
  cmpMode = 0
}

local function leave_special_scene_cb(aX, aY, aSceneID)
  Player:TeamFollow(false, 500)
  local cur_scene_id = GetSceneID()
  local cur_scene_name = GetCurrentSceneName()
  if -1 ~= m_cmp.sceneID then
    if m_cmp.sceneID == cur_scene_id then
      return true
    end
  elseif 0 == m_cmp.cmpMode then
    if cur_scene_name == m_cmp.sceneName then
      return true
    end
  elseif 1 == m_cmp.cmpMode and string.find(cur_scene_name, m_cmp.sceneName, nil, true) then
    return true
  end
  return false
end

local function LS_IsInSuZhouXiuXiShi()
  local cur_scene_name = GetCurrentSceneName()
  if string.find(cur_scene_name, "苏州休息室", nil, true) then
    m_cmp.sceneID = -1
    m_cmp.sceneName = "苏州休息室"
    m_cmp.cmpMode = 1
    MoveToNPC("胡小仙", 32, 14, -1, nil, nil, nil, leave_special_scene_cb)
    QuestFrameOptionClicked_Item("离开休息室", 1, 700)
    QuestFrameOptionClicked_Item("确定", 1, 700)
    return true
  end
  return false
end

local function LS_IsInFengHuangScene(aSceneID)
  local cur_scene_id = aSceneID or GetSceneID()
  if 280 == cur_scene_id then
    m_cmp.sceneID = 280
    MoveToNPC("黄龙天", 161, 162, 280, nil, nil, nil, leave_special_scene_cb)
    QuestFrameOptionClicked_Item("#{FHZD_XML_35}", 1, 700)
    return true
  end
  return false
end

local function LS_IsInMenPaiBoss(aSceneID)
  local cur_scene_id = aSceneID or GetSceneID()
  local mpBossSceneList = {
    {
      x = 91,
      y = 159,
      sceneID = 183,
      sceneName = "丐帮总舵"
    },
    {
      x = 98,
      y = 159,
      sceneID = 184,
      sceneName = "光明殿"
    },
    {
      x = 95,
      y = 192,
      sceneID = 185,
      sceneName = "武当山"
    },
    {
      x = 89,
      y = 146,
      sceneID = 188,
      sceneName = "峨嵋山"
    },
    {
      x = 96,
      y = 142,
      sceneID = 186,
      sceneName = "天龙寺"
    },
    {
      x = 95,
      y = 148,
      sceneID = 190,
      sceneName = "天山"
    },
    {
      x = 96,
      y = 158,
      sceneID = 182,
      sceneName = "少林寺"
    },
    {
      x = 44,
      y = 129,
      sceneID = 187,
      sceneName = "凌波洞"
    },
    {
      x = 96,
      y = 142,
      sceneID = 189,
      sceneName = "星宿海"
    },
    {
      x = 160,
      y = 169,
      sceneID = 289,
      sceneName = "慕容山庄"
    },
    {
      x = 173,
      y = 170,
      sceneID = 616,
      sceneName = "唐家堡"
    },
    {
      x = 98,
      y = 175,
      sceneID = 680,
      sceneName = "鬼谷"
    },
    {
      x = 274,
      y = 177,
      sceneID = 741,
      sceneName = "桃花岛"
    },
    {
      x = 148,
      y = 390,
      sceneID = 828,
      sceneName = "绝情谷"
    },
    {
      x = 56,
      y = 215,
      sceneID = 989,
      sceneName = "恶人谷"
    }
  }
  for i = 1, #mpBossSceneList do
    local tmp = mpBossSceneList[i]
    if tmp.sceneID == cur_scene_id then
      m_cmp.sceneID = cur_scene_id
      MoveTo(tmp.x, tmp.y, -1, nil, nil, nil, leave_special_scene_cb)
      return true
    end
  end
  return false
end

function LeaveSpecialScene(aCmpSceneIDList, aCmpSceneName)
  while true do
    m_cmp.sceneID = -1
    m_cmp.sceneName = ""
    m_cmp.cmpMode = 0
    local cur_scene_id = GetSceneID()
    local cur_scene_name = GetCurrentSceneName()
    if aCmpSceneIDList and FindTableValue(aCmpSceneIDList, cur_scene_id) then
      break
    end
    if LS_IsInSuZhouXiuXiShi() then
    elseif LS_IsInMenPaiBoss(cur_scene_id) then
    elseif LS_IsInFengHuangScene(cur_scene_id) then
    else
      break
    end
    Player:TeamFollow(false, 500)
    DebugStr("离开无法跨图寻路场景")
    Sleep(500)
  end
end
