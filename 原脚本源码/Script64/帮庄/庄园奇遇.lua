-- 反编译自 dfz64.dll 内嵌字节码 00353b78（unluac 2025-12-23；仅供分析）
local m_script_name = "庄园奇遇"
ScriptOnStart(m_script_name, false, false)

local function zyqy_cb_in_zy(fX, fY, nScene)
  return IsZhuangYuanScene()
end

local function zyqy_lqjl()
  DeleteDebugMsg("#{JYQY_160810_154}")
  MoveTo(170, 200, -1, nil, nil, nil, zyqy_cb_in_zy)
  Sleep(500)
  ClearBag()
  local tObj = Enum2XByName(" 大财神 养兔老伯 西域舞娘 果园老农 ", {
    1,
    0,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    for i = 1, 3 do
      TalkNpc(tObj[1].name)
      Sleep(600)
      QuestFrameOptionClicked_Item("#{JYQY_160810_76}", 1, 700)
      QuestFrameOptionClicked_Item("#{JYQY_160810_157}", 1, 700)
      if IsInDebugMsg("#{JYQY_160810_154}") then
        break
      end
    end
  end
  local curSceneName = GetCurrentSceneName()
  if string.find(curSceneName, "*.-" .. g_self.name .. "}") then
    for i = 1, 3 do
      local tItem = Bag:FindItemInfo("庄园福运宝箱（1级）")
      if #tItem > 0 then
        local tmp = tItem[1]
        Bag:ItemBtnClicked(tmp.index)
      end
      tItem = Bag:FindItemInfo("庄园福运宝箱（2级）")
      if #tItem > 0 then
        local tmp = tItem[1]
        Bag:ItemBtnClicked(tmp.index)
      end
      tItem = Bag:FindItemInfo("庄园福运宝箱（3级）")
      if #tItem > 0 then
        local tmp = tItem[1]
        Bag:ItemBtnClicked(tmp.index)
      end
      tItem = Bag:FindItemInfo("庄园福运宝箱（4级）")
      if #tItem > 0 then
        local tmp = tItem[1]
        Bag:ItemBtnClicked(tmp.index)
      end
      tItem = Bag:FindItemInfo("庄园福运宝箱（5级）")
      if #tItem > 0 then
        local tmp = tItem[1]
        Bag:ItemBtnClicked(tmp.index)
      end
    end
  end
  return -1
end

local function zyqy_gettime()
  local strText = [[
        setmetatable(_G, {__index = BieYe_QiYu_Env})
        if this:IsVisible() then
            return BieYe_QiYu_StopWatch:GetProperty("Timer")
        end
        setmetatable(_G, {__index = BieYe_QiYu_Mini_Env})
        if this:IsVisible() then
            return BieYe_QiYu_Mini_StopWatch:GetProperty("Timer")
        end
        return 0
    ]]
  return GetLuaValue(strText, "n")
end

local function zyqy_gettime2()
  local strText = [[
        setmetatable(_G, {__index = BieYe_QiYu2_Env})
        if this:IsVisible() then
            return BieYe_QiYu2_StopWatch:GetProperty("Timer")
        end
        setmetatable(_G, {__index = BieYe_QiYu2_Mini_Env})
        if this:IsVisible() then
            return BieYe_QiYu2_Mini_StopWatch:GetProperty("Timer")
        end
        return 0
    ]]
  return GetLuaValue(strText, "n")
end

local function zyqy_getvalue()
  local strText = [[

        setmetatable(_G, {__index = BieYe_QiYu_Env})
        if this:IsVisible() then
            return BieYe_QiYu_Text2:GetText()
        end
        setmetatable(_G, {__index = BieYe_QiYu_Mini_Env})
        if this:IsVisible() then
            return BieYe_QiYu_Mini_Text2:GetText()
        end
        return ""
        ]]
  local value = GetLuaValue(strText, "s")
  local _, _, val = string.find(value, "(%d+)/")
  val = tonumber(val) or 0
  return val
end

local function zyqy_csbx()
  local bHave = false
  local tObj = Enum2XByName("财神的大宝箱", {
    1,
    0,
    0,
    0
  }, nil, 0, 0)
  if 0 == #tObj then
    Sleep(5000)
  end
  local nTick = GetTickCount()
  DeleteDebugMsg("#{JYQY_160810_64}")
  ClearBag()
  while not (GetTickCount() - nTick > 60000) do
    local tObj = Enum2XByName("财神的大宝箱", {
      1,
      0,
      0,
      0
    }, nil, 0, 0)
    if #tObj > 0 then
      bHave = true
      RunTo(tObj[1].x, tObj[1].y, 1, 1500)
      Skill.CUseSkillByID(3, tObj[1].id, -1, -1)
      Sleep(1500)
      PlayerStateTimeOut(5, 5)
    else
      break
    end
    if IsInDebugMsg("#{JYQY_160810_64}") then
      break
    end
    Sleep(500)
    DebugStr(m_script_name .. ":开启财神宝箱")
  end
  return bHave
end

local function zyqy_tjcs()
  Dismount()
  local CurValue = zyqy_getvalue()
  PushDebugMessage("天降财神完成度：" .. CurValue)
  if 100 == CurValue then
    PushDebugMessage("天降财神完成.")
    return true
  end
  if 5 == Player:GetState() then
    return false
  end
  local tObj = Enum2XByName("珠宝箱 金元宝 宝石 银币", {
    1,
    0,
    0,
    0
  }, nil, 0, 3)
  if #tObj > 0 then
    math.randomseed(GetTickCount())
    local idx = math.random(1, #tObj)
    local tmp = tObj[idx]
    MoveTo(tmp.x, tmp.y, -1, nil, nil, nil, zyqy_cb_in_zy)
    Dismount()
    Sleep(200)
    Skill.CUseSkillByID(3, tmp.id, -1, -1)
    Sleep(1500)
  else
    tObj = Enum2XByName("散财童子", {
      1,
      0,
      0,
      0
    }, nil, 0, 0)
    if #tObj > 0 then
      RunTo(tObj[1].x, tObj[1].y, 0, 600)
    else
      local nMsgTime, szMsgText = IsInDebugMsg("#{JYQY_160810_340")
      if nMsgTime then
        local _, _, xPos, yPos = string.find(szMsgText, "*.-*.-(%d+)*.-(%d+)}")
        xPos = tonumber(xPos)
        yPos = tonumber(yPos)
        if xPos and yPos then
          PushDebugMessage("前往 %s ,%s 拾取宝物", xPos, yPos)
          RunTo(xPos, yPos, 1, 600)
        end
      end
    end
  end
  return false
end

local function zyqy_lztz_getcount()
  local strText = [[
        setmetatable(_G, {__index = BieYe_QiYu2_Env})
        if this:IsVisible() then
            local n1 = BieYe_QiYu2_Text1_2:GetText()
            local n2 = BieYe_QiYu2_Text2_2:GetText()
            local n3 = BieYe_QiYu2_Text3_2:GetText()
            local n4 = BieYe_QiYu2_Text4_2:GetText()
            return n1, n2, n3, n4
        end
        setmetatable(_G, {__index = BieYe_QiYu2_Mini_Env})
        if this:IsVisible() then
            local n1 = BieYe_QiYu2_Mini_Text1_2:GetText()
            local n2 = BieYe_QiYu2_Mini_Text2_2:GetText()
            local n3 = BieYe_QiYu2_Mini_Text3_2:GetText()
            local n4 = BieYe_QiYu2_Mini_Text4_2:GetText()
            return n1, n2, n3, n4
        end
        return "", "", "", ""
    ]]
  local str1, str2, str3, str4 = GetLuaValue(strText, "ssss")
  str1 = string.gsub(str1, "/10", "")
  str1 = tonumber(str1) or 0
  str2 = string.gsub(str2, "/10", "")
  str2 = tonumber(str2) or 0
  str3 = string.gsub(str3, "/10", "")
  str3 = tonumber(str3) or 0
  str4 = string.gsub(str4, "/10", "")
  str4 = tonumber(str4) or 0
  return str1, str2, str3, str4
end

local function zyqy_lztz()
  Dismount()
  local num1, num2, num3, num4 = zyqy_lztz_getcount()
  PushDebugMessage(num1 .. " " .. num2 .. " " .. num3 .. " " .. num4)
  if Bag:GetItemCount("小白兔") > 0 then
    MoveToNPC("白兔笼", 166, 204, -1, nil, false, nil, zyqy_cb_in_zy)
    Sleep(500)
    QuestFrameOptionClicked_Item("放入小白兔", 1, 500)
  elseif Bag:GetItemCount("小灰兔") > 0 then
    MoveToNPC("灰兔笼", 166, 204, -1, nil, false, nil, zyqy_cb_in_zy)
    Sleep(500)
    QuestFrameOptionClicked_Item("放入小灰兔", 1, 500)
  elseif Bag:GetItemCount("小黑兔") > 0 then
    MoveToNPC("黑兔笼", 173, 204, -1, nil, false, nil, zyqy_cb_in_zy)
    Sleep(500)
    QuestFrameOptionClicked_Item("放入小黑兔", 1, 500)
  elseif Bag:GetItemCount("小花兔") > 0 then
    MoveToNPC("花兔笼", 173, 204, -1, nil, false, nil, zyqy_cb_in_zy)
    Sleep(500)
    QuestFrameOptionClicked_Item("放入小花兔", 1, 500)
  end
  local szFind = " 小白兔 小灰兔 小黑兔 小花兔 "
  if 10 == num1 then
    szFind = string.gsub(szFind, "小白兔", "")
  end
  if 10 == num2 then
    szFind = string.gsub(szFind, "小灰兔", "")
  end
  if 10 == num3 then
    szFind = string.gsub(szFind, "小黑兔", "")
  end
  if 10 == num4 then
    szFind = string.gsub(szFind, "小花兔", "")
  end
  szFind = string.gsub(szFind, "  ", " ")
  szFind = string.gsub(szFind, "  ", " ")
  local tObj = Enum2XByName(szFind, {
    1,
    0,
    0,
    0
  }, nil, 1, 3)
  if #tObj > 0 then
    MoveTo(tObj[1].x, tObj[1].y, -1, nil, false, nil, zyqy_cb_in_zy)
    Sleep(100)
    Skill.CUseSkillByID(3, tObj[1].id, -1, -1)
    Sleep(1500)
  end
  return false
end

local function zyqy_ppqw()
  Dismount()
  local CurValue = zyqy_getvalue()
  if 100 == CurValue then
    PushDebugMessage("翩翩起舞完成.")
    return true
  end
  if -1 == Player:GetBuff("变身：") then
    return false
  end
  if 5 == Player:GetState() then
    return false
  end
  local nMsgTime1 = IsInDebugMsg("#{JYQY_160810_293}")
  nMsgTime1 = nMsgTime1 or 0
  local nMsgTime2 = IsInDebugMsg("#{JYQY_160810_294}")
  nMsgTime2 = nMsgTime2 or 0
  local nMsgTime3 = IsInDebugMsg("#{JYQY_160810_295}")
  nMsgTime3 = nMsgTime3 or 0
  local nMsgTime4 = IsInDebugMsg("#{JYQY_160810_296}")
  nMsgTime4 = nMsgTime4 or 0
  local nMsgTime5 = IsInDebugMsg("#{JYQY_160810_297}")
  nMsgTime5 = nMsgTime5 or 0
  local tab = {}
  table.insert(tab, {time = nMsgTime1, key = 51})
  table.insert(tab, {time = nMsgTime2, key = 52})
  table.insert(tab, {time = nMsgTime3, key = 53})
  table.insert(tab, {time = nMsgTime4, key = 54})
  table.insert(tab, {time = nMsgTime5, key = 55})
  BubbleSort(tab, "time", 2)
  if tab[1].time > 0 then
    GetLuaValue(fmt("setmetatable(_G, {__index = MainMenuBar_Env});MainMenuBar_Clicked(%d)", tab[1].key))
  end
  return false
end

local function zyqy_zpgs()
  Dismount()
  if 5 == Player:GetState() then
    return false
  end
  local nMsgTime1 = IsInDebugMsg("#{JYQY_160810_241}")
  nMsgTime1 = nMsgTime1 or 0
  local nMsgTime2 = IsInDebugMsg("#{JYQY_160810_242}")
  nMsgTime2 = nMsgTime2 or 0
  local nMsgTime3 = IsInDebugMsg("#{JYQY_160810_243}")
  nMsgTime3 = nMsgTime3 or 0
  local nMsgTime4 = IsInDebugMsg("#{JYQY_160810_244}")
  nMsgTime4 = nMsgTime4 or 0
  local tab = {}
  table.insert(tab, {
    time = nMsgTime1,
    item = "水桶",
    x = 174,
    y = 216
  })
  table.insert(tab, {
    time = nMsgTime2,
    item = "肥料",
    x = 174,
    y = 207
  })
  table.insert(tab, {
    time = nMsgTime3,
    item = "锄草耙",
    x = 165,
    y = 216
  })
  table.insert(tab, {
    time = nMsgTime4,
    item = "杀虫药",
    x = 165,
    y = 207
  })
  BubbleSort(tab, "time", 2)
  if tab[1].time > 0 then
    MoveTo(tab[1].x, tab[1].y, -1, nil, nil, nil, zyqy_cb_in_zy)
    local tObj = Enum2XByName(tab[1].item, {
      1,
      0,
      0,
      0
    }, nil, 0, 0)
    if #tObj > 0 then
      Skill.CUseSkillByID(3, tObj[1].id, -1, -1)
      Sleep(1000)
    end
  end
end

function _SMain(...)
  local bDo = false
  while true do
    if IsZhuangYuanScene() then
      local tObj = Enum2XByName(" 大财神 养兔老伯 西域舞娘 果园老农 ", {
        1,
        0,
        0,
        0
      }, nil, nil, 3)
      if #tObj > 0 then
        Dismount()
        local tmp = tObj[1]
        if tmp.name == "大财神" then
          local leftTime = zyqy_gettime()
          if 0 == leftTime then
            if bDo then
              Sleep(5000)
              break
            end
            local tObj1 = Enum2XByName("散财童子", {
              1,
              0,
              0,
              0
            }, nil, 0, 0)
            if 0 == #tObj1 then
              TalkNpc(tmp.name)
              Sleep(800)
              QuestFrameOptionClicked_Item("#{JYQY_160810_11}", 1, 800)
            end
          else
            bDo = true
            local tObj = Enum2XByName("财神的大宝箱", {
              1,
              0,
              0,
              0
            }, nil, 0, 0)
            if #tObj > 0 then
              break
            end
            zyqy_tjcs()
          end
        elseif tmp.name == "养兔老伯" then
          local leftTime = zyqy_gettime2()
          if 0 == leftTime then
            if bDo then
              break
            end
            TalkNpc(tmp.name)
            Sleep(800)
            QuestFrameOptionClicked_Item("#{JYQY_160810_75}", 1, 800)
          else
            bDo = true
            zyqy_lztz()
          end
        elseif tmp.name == "西域舞娘" then
          if -1 == Player:GetBuff("变身：") then
            if bDo then
              break
            end
            TalkNpc(tmp.name)
            Sleep(800)
            QuestFrameOptionClicked_Item("#{JYQY_160810_169}", 1, 800)
          else
            bDo = true
            zyqy_ppqw()
          end
        else
          if tmp.name ~= "果园老农" then
            goto lbl_223
          end
          local leftTime = zyqy_gettime()
          if 0 == leftTime then
            if bDo then
              break
            end
            local tObj1 = Enum2XByName(" 杀虫药 肥料 锄草耙 水桶 苹果树幼苗 ", {
              1,
              0,
              0,
              0
            }, nil, 0, 3)
            if 0 == #tObj1 then
              TalkNpc(tObj[1].name)
              Sleep(800)
              QuestFrameOptionClicked_Item("#{JYQY_160810_228}", 1, 1000)
            else
              DebugStr("果农任务等待.", 2)
            end
          else
            bDo = true
            zyqy_zpgs()
          end
        end
      else
        DebugStr(m_script_name .. ":没有找到奇遇NPC")
        Sleep(500)
        MoveTo(170, 200, -1, nil, nil, nil, zyqy_cb_in_zy)
      end
    elseif Player:IsLeader() then
      GoToZhuangYuan(1)
    elseif not Player:IsFollow() then
      DebugStr("庄园奇遇：跟随队长位置", 2)
      
      local function dy_cb(fX, fY, nScene)
        local leader, isleader = Team:GetLeaderInfo()
        if not leader then
          return false
        end
        if leader.sceneID == LUOYANG_ID or 1 == leader.sceneID or 2 == leader.sceneID or leader.sceneID == 246 then
          return MoveCallBack_GoToLeader(fX, fY, nScene)
        end
        return false
      end
      
      GoToLeader(dy_cb)
    end
    ::lbl_223::
    Sleep(300)
    DebugStr("庄园奇遇")
  end
  zyqy_csbx()
  zyqy_lqjl()
end

_SMain()
ScriptOnStop(m_script_name)
