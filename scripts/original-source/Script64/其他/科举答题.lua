-- 反编译自 dfz64.dll 内嵌字节码 002b36bd（unluac 2025-12-23；仅供分析）
local m_script_name = "科举答题"
ScriptOnStart(m_script_name, false, false)
local m_unfind = {}

local function Examination_Clicked(aIndex)
  GetLuaValue(fmt("setmetatable(_G, {__index = Examination_Env});Examination_Button_Clicked(%d)", aIndex))
  Sleep(500)
end

local function Keju_GetQuestion()
  return GetLuaValue([[
        setmetatable(_G, {__index = Examination_Env})
        if this:IsVisible() then
            local q = Examination_Text:GetText()
            local a1 = Examination_Button_1:GetText()
            local a2 = Examination_Button_2:GetText()
            local a3 = Examination_Button_3:GetText()
            local a4 = Examination_Button_4:GetText()
            local a5 = Examination_Button_5:GetText()
            return q, a1, a2, a3, a4, a5
        end
        return "", "", "", "", "", ""
        ]], "ssssss")
end

local function Keju_Dati()
  local quest, a_1, a_2, a_3, a4, a5 = Keju_GetQuestion()
  if string.find(quest, "下列答案中只有1个是正确的，请选择", nil, true) then
    quest = string.gsub(quest, "\n下列答案中只有1个是正确的，请选择", "")
    local nIndex = -1
    for i, v in pairs(Q) do
      if string.find(quest, v, nil, true) then
        if a_1 == A[i] then
          nIndex = 1
          break
        elseif a_2 == A[i] then
          nIndex = 2
          break
        elseif a_3 == A[i] then
          nIndex = 3
          break
        end
      end
    end
    if -1 ~= nIndex then
      Examination_Clicked(nIndex)
    else
      PushDebugMessage(m_script_name .. ":没有题目[%s]对应的答案", quest)
      local bRecord = true
      for i = 1, #m_unfind do
        if m_unfind[i] == quest then
          bRecord = false
        end
      end
      if bRecord then
        table.insert(m_unfind, quest)
        LogMsg("题目：" .. quest .. " 选项1：" .. a_1 .. " 选项2：" .. a_2 .. " 选项3：" .. a_3)
      end
    end
  elseif string.find(quest, "想要来参加科举考试啊？", nil, true) then
    IsWindowVisible("Examination", "Examination_Button_Clicked(1)")
    Sleep(500)
  end
end

function _SMain(...)
  LoadScript("科举.lua")
  if Q == nil or nil == A then
    PushColorMsg("科举答题：加载题库失败！")
    return
  end
  local xPos = 230
  local yPos = 240
  local npcName = "林举贤"
  while true do
    if IsWindowVisible("Examination") == false then
      local szTalkTitle = GetNPCEventList_Item(0)
      if "" ~= szTalkTitle then
      end
      if string.find(szTalkTitle, "金钱不足", nil, true) then
        PushColorMsg("金钱不足，结束脚本!")
        break
      elseif string.find(szTalkTitle, "恭喜您", nil, true) then
        PushDebugMessage(m_script_name .. ":州试已完成!")
        break
      elseif string.find(szTalkTitle, "考官位置在", nil, true) then
        _, _, xPos, yPos, npcName = string.find(szTalkTitle, "#{_INFOAIM(%d+),(%d+),%d+,(.+)}")
        xPos = tonumber(xPos)
        yPos = tonumber(yPos)
        PushDebugMessage("考官:%d,%d,%s", xPos, yPos, npcName)
      elseif string.find(szTalkTitle, "对不起，您答错了", nil, true) then
        QuestFrameOptionClicked_Item("准备好了，开始吧······", 1, 800)
      elseif string.find(szTalkTitle, "请等待下一轮的科举活动。", nil, true) then
        DebugStr("等待复试", 2)
      end
      GoToSceneNPC(npcName, xPos, yPos, 2, nil, nil, nil, nil, true, true)
      ChangeSceneLine()
      Sleep(500)
      DialogOptionClicked("科举初试", 1, 600)
    else
      Keju_Dati()
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
Q = nil
A = nil
