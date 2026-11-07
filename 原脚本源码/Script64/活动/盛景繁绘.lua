-- 反编译自 dfz64.dll 内嵌字节码 0043776f（unluac 2025-12-23；仅供分析）
local m_script_name = "盛景繁绘"
ScriptOnStart(m_script_name, false, false)
local m_targetIndex = -1
local m_npc = {
  {
    x = 259,
    y = 164,
    name = "苏辙",
    sceneID = LUOYANG_ID,
    item = "洛阳四时图",
    option = "#{SJFH_230425_108}",
    have = false
  },
  {
    x = 272,
    y = 274,
    name = "张择端",
    sceneID = 1,
    item = "苏州百景图",
    option = "#{SJFH_230425_72}",
    have = false
  },
  {
    x = 231,
    y = 248,
    name = "米芾",
    sceneID = 2,
    item = "大理风月图",
    option = "#{SJFH_230425_97}",
    have = false
  }
}
local m_record = {
  {},
  {},
  {}
}

local function SJFH_FilterPos(aObj, aPosX, aPosY, aFilterIndex)
  local tObj = {}
  for i = 1, #aObj do
    local tmp = aObj[i]
    if GetDist(tmp.x, tmp.y, aPosX, aPosY) <= 1.5 and tmp.level >= 30 and tmp.name ~= g_self.name then
      local rec = m_record[aFilterIndex]
      local bInsert = true
      for j = 1, #rec do
        if rec[j] == tmp.name then
          bInsert = false
          break
        end
      end
      if bInsert then
        table.insert(tObj, tmp)
      end
    end
  end
  return tObj
end

local function SJFH_UseItem(aObj, aItem, aFilterIndex)
  for i = 1, #aObj do
    DeleteDebugMsg("#{SJFH_230425_130}")
    Dismount(600)
    Player:TeamFollow(false, 500)
    local tmp = aObj[i]
    Target:Select(tmp.id, 800)
    RunTo(tmp.x, tmp.y, 2, 200)
    Bag:UseItemByName_click(aItem, 1000)
    PlayerStateTimeOut(5, 5)
    if IsInDebugMsg("#{SJFH_230425_130}") then
      table.insert(m_record[aFilterIndex], tmp.name)
    else
    end
  end
end

local function SJFH_RenWu()
  if -1 == m_targetIndex then
    math.randomseed(GetTickCount() + Player:GetGUID() + Player:GetHP())
    m_targetIndex = math.random(1, #m_npc)
  end
  local nHaveIndex = -1
  while true do
    local debugnote = ""
    local bOver = true
    for i = 1, #m_npc do
      local tmp = m_npc[i]
      if Bag:GetItemCount(tmp.item) > 0 then
        nHaveIndex = i
        m_npc[i].have = true
      else
        bOver = false
      end
    end
    if -1 == nHaveIndex then
      local npc = m_npc[m_targetIndex]
      debugnote = "领取城景绘图"
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      QuestFrameOptionClicked_Item(npc.option, 1, 1000)
    elseif false == bOver then
      debugnote = "收集城景绘图"
      if m_npc[1].have == false then
        SendTalkChatMsg("near", "#G来个洛阳图,谢谢", 100)
        GoToScene(274, 274, 1, 1)
      elseif m_npc[2].have == false then
        SendTalkChatMsg("near", "#G来个苏州图,谢谢", 100)
        GoToScene(272, 276, 1, 1)
      elseif m_npc[3].have == false then
        SendTalkChatMsg("near", "#G来个大理图,谢谢", 100)
        GoToScene(274, 276, 1, 1)
      end
      local tObj = Enum2XByClass("玩家")
      local nIdx = 1
      if m_npc[nIdx].have == true then
        local uObj = SJFH_FilterPos(tObj, 274, 274, nIdx)
        SJFH_UseItem(uObj, m_npc[nIdx].item, nIdx)
      end
      nIdx = 2
      if m_npc[nIdx].have == true then
        local uObj = SJFH_FilterPos(tObj, 272, 276, nIdx)
        SJFH_UseItem(uObj, m_npc[nIdx].item, nIdx)
      end
      nIdx = 3
      if m_npc[nIdx].have == true then
        local uObj = SJFH_FilterPos(tObj, 274, 276, nIdx)
        SJFH_UseItem(uObj, m_npc[nIdx].item, nIdx)
      end
    else
      break
    end
    Sleep(500)
    DebugStr(m_script_name .. " " .. debugnote)
  end
end

local function SJFH_RenWU_Give()
  local nTick = GetTickCount()
  if 1 ~= GetSceneID() then
    return
  end
  for i = 1, #m_npc do
    local tmp = m_npc[i]
    if Bag:GetItemCount(tmp.item) > 0 then
      m_npc[i].have = true
    end
  end
  while true do
    local tObj = Enum2XByClass("玩家")
    local nIdx = 1
    if m_npc[nIdx].have == true then
      local uObj = SJFH_FilterPos(tObj, 274, 274, nIdx)
      SJFH_UseItem(uObj, m_npc[nIdx].item, nIdx)
    end
    nIdx = 2
    if m_npc[nIdx].have == true then
      local uObj = SJFH_FilterPos(tObj, 272, 276, nIdx)
      SJFH_UseItem(uObj, m_npc[nIdx].item, nIdx)
    end
    nIdx = 3
    if m_npc[nIdx].have == true then
      local uObj = SJFH_FilterPos(tObj, 274, 276, nIdx)
      SJFH_UseItem(uObj, m_npc[nIdx].item, nIdx)
    end
    Sleep(600)
    if GetTickCount() - nTick > 180000 then
      break
    end
    DebugStr("循环赠送图,3分钟自动结束")
    RunTo(272, 274, 1, 800)
  end
end

function _SMain()
  ClearBag()
  DeleteDebugMsg("#{SJFH_230425_154}")
  CloseAllWindow()
  Sleep(500)
  if not IsWindowVisible("ShengJingFanHui") then
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_2023ShengJingFanHui_Cliked();")
    Sleep(600)
  end
  if not IsWindowVisible("ShengJingFanHui_RenWu") then
    GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_TaskClicked();")
    Sleep(600)
  end
  for i = 1, 3 do
    GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_RenWu});ShengJingFanHui_RenWu_GetReward(1);")
    Sleep(600)
  end
  for i = 1, 3 do
    GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_RenWu});ShengJingFanHui_RenWu_GetReward(2);")
    Sleep(600)
  end
  for i = 1, 3 do
    GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_RenWu});ShengJingFanHui_RenWu_GetReward(3);")
    Sleep(600)
  end
  for i = 1, 3 do
    GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_Paint()")
    Sleep(600)
  end
  GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_PrizeButton_Clicked(1);")
  Sleep(600)
  GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_PrizeButton_Clicked(2);")
  Sleep(600)
  CloseAllWindow()
  local bDoMis = false
  for i = 1, #m_npc do
    local tmp = m_npc[i]
    if Bag:GetItemCount(tmp.item) > 0 then
    else
      bDoMis = true
      PushColorMsg(m_script_name .. ":没有" .. tmp.item .. "，开始做任务")
      break
    end
  end
  if bDoMis then
    SJFH_RenWu()
    for i = 1, 3 do
      GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_RenWu});ShengJingFanHui_RenWu_GetReward(3);")
      Sleep(600)
    end
  end
  for i = 1, 3 do
    GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_Paint()")
    Sleep(600)
  end
  GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_PrizeButton_Clicked(1);")
  Sleep(600)
  GetLuaValue("setmetatable(_G, {__index = ShengJingFanHui_Env});ShengJingFanHui_PrizeButton_Clicked(2);")
  Sleep(600)
  SJFH_RenWU_Give()
  RunTo(280, 280, 2, 1000)
end

_SMain()
ScriptOnStop(m_script_name)
