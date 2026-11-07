-- 反编译自 dfz64.dll 内嵌字节码 005106ce（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：SDQY_HuoDong 中 strAll 作用域被反编译提前结束，按字节码移回 if 内
local m_hd_RefreshTime = GetTickCount() - 600000
local m_move_cb
local m_npc_double_exp = {
  {
    x = 242,
    y = 235,
    name = "刘健明",
    sceneID = LUOYANG_ID
  },
  {
    x = 250,
    y = 172,
    name = "沈澄",
    sceneID = 1
  },
  {
    x = 181,
    y = 139,
    name = "洪大贵",
    sceneID = 2
  },
  {
    x = 154,
    y = 121,
    name = "格鲁尔",
    sceneID = 246
  },
  {
    x = 163,
    y = 115,
    name = "宋三石",
    sceneID = 850
  },
  {
    x = 448,
    y = 424,
    name = "宋三石",
    sceneID = 762
  },
  {
    x = 448,
    y = 424,
    name = "宋三石",
    sceneID = 772
  },
  {
    x = 448,
    y = 424,
    name = "宋三石",
    sceneID = 773
  }
}

local function DoubleExp_GetNPC()
  local nSceneID = GetSceneID()
  local nIndex = -1
  for i = 1, #m_npc_double_exp do
    if m_npc_double_exp[i].sceneID == nSceneID then
      nIndex = i
      break
    end
  end
  if -1 == nIndex then
    nIndex = 2
    if IsKVKSceneName() then
      nIndex = 5
    end
  end
  return nIndex
end

local function DoubleExp_GetCurrentTimer()
  local strTime = [[
            setmetatable(_G, {__index = MainMenuBar_Env})
            if MainMenuBar_Doub_Watch:IsVisible() then
                local timewatch = MainMenuBar_Doub_Watch:GetProperty("Timer")
                local timecurrent = tonumber(timewatch) or 0
                return timecurrent
            else
                return 0
            end
        ]]
  local timecurrent = GetLuaValue(strTime, "n")
  return timecurrent
end

function DoubleExp_Get(aGetTime)
  PushDebugMessage("执行：领取双倍经验！")
  local nLevel = GetPlayerVipLevel()
  if nLevel >= 3 then
    local timecurrent = DoubleExp_GetCurrentTimer()
    if 0 == timecurrent then
      local tick_out = GetTickCount()
      GetLuaValue([[
            	Clear_XSCRIPT()
		            Set_XSCRIPT_Function_Name("OnUseVIP")
		            Set_XSCRIPT_ScriptID(889644)
		            Set_XSCRIPT_Parameter(0, 11)
		            Set_XSCRIPT_ParamCount(1)
	            Send_XSCRIPT()    
            ]])
      Sleep(1000)
      MessageBox_Self_Text_Clicked("解冻", 1500)
    end
  end
  if aGetTime then
    local timecurrent = DoubleExp_GetCurrentTimer()
    if timecurrent >= aGetTime * 60 then
      PushDebugMessage("领双：当前无需领取")
      return
    end
  end
  local nIndex = DoubleExp_GetNPC()
  local npc = m_npc_double_exp[nIndex]
  CloseAllWindow()
  for i = 1, 4 do
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    Sleep(500)
    if QuestFrameOptionClicked_Item("#{SBSJ_100726_02}", 1, 1500) then
      local szTalkTitle = GetNPCEventList_Item(0)
      if string.find(szTalkTitle, "你没有在我这里冻结", nil, true) then
        TalkNpc(npc.name)
        Sleep(600)
        if not QuestFrameOptionClicked_Item("我想领一小时双倍经验时间", 1, 1500) then
          goto lbl_129
        end
        szTalkTitle = GetNPCEventList_Item(0)
        if string.find(szTalkTitle, "你没有这么多的时间可以领取了", nil, true) or string.find(szTalkTitle, "达到可领取的上限", nil, true) or string.find(szTalkTitle, "已经用完了", nil, true) then
          break
        end
        QuestFrameOptionClicked_Item("是的，我要领取。", 1, 500)
      else
        MessageBox_Self_OK_Clicked()
        Sleep(500)
      end
    end
    ::lbl_129::
    if aGetTime then
      local timecurrent = DoubleExp_GetCurrentTimer()
      if timecurrent >= aGetTime * 60 then
        break
      end
    end
  end
end

function DoubleExp_Freeze()
  local timecurrent = DoubleExp_GetCurrentTimer()
  if 0 == timecurrent then
    PushDebugMessage("冻双：无需冻结双倍经验")
    return
  else
    PushDebugMessage("执行：冻结双倍经验！")
  end
  local nLevel = GetPlayerVipLevel()
  if nLevel >= 3 then
    local tick_out = GetTickCount()
    DeleteDebugMsg("#{VIPTQ_120221_38}")
    local bSuccess = true
    while true do
      DebugStr("vip随身冻结双倍经验")
      GetLuaValue([[
            	Clear_XSCRIPT()
		            Set_XSCRIPT_Function_Name("OnUseVIP")
		            Set_XSCRIPT_ScriptID(889644)
		            Set_XSCRIPT_Parameter(0, 11)
		            Set_XSCRIPT_ParamCount(1)
	            Send_XSCRIPT()    
            ]])
      Sleep(1000)
      MessageBox_Self_Text_Clicked("确定进行冻结", 1000)
      if 0 == DoubleExp_GetCurrentTimer() then
        break
      end
      if GetTickCount() - tick_out > 8000 then
        PushColorMsg("vip冻双：超时！")
        bSuccess = false
        break
      end
    end
    if bSuccess then
      return
    end
  end
  local nIndex = DoubleExp_GetNPC()
  local npc = m_npc_double_exp[nIndex]
  CloseAllWindow()
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  local tick_out = GetTickCount()
  while true do
    GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
    if QuestFrameOptionClicked_Item("#{SBSJ_100726_01}", 1, 1500) then
      local szTalkTitle = GetNPCEventList_Item(0)
      if string.find(szTalkTitle, "你现在没有已领取的双倍", nil, true) or string.find(szTalkTitle, "已经处于冻结状态", nil, true) then
        PushDebugMessage("冻双：双倍经验已经冻结！")
        break
      else
        MessageBox_Self_OK_Clicked()
        Sleep(1500)
      end
    end
    Sleep(500)
    if GetTickCount() - tick_out > 60000 then
      PushColorMsg("冻双：超时！")
      break
    end
    DebugStr("冻结双倍经验")
  end
end

function MainBankTakeItem()
  PushDebugMessage("执行：仓库取出物品")
  local tTakeItem = g_config.item.take_bank
  local bTempBag = g_config.item.tempbag_qucang
  local normalItem = ""
  local notbindItem = ""
  local bindItem = ""
  for i = 1, #tTakeItem.class do
    local tmp = tTakeItem.class[i]
    if 0 == tmp.data then
      normalItem = normalItem .. tmp.text .. " "
    end
  end
  for i = 1, #tTakeItem.name do
    local tmp = tTakeItem.name[i]
    if 0 == tmp.data then
      normalItem = normalItem .. tmp.text .. " "
    end
  end
  for i = 1, #tTakeItem.class do
    local tmp = tTakeItem.class[i]
    if 1 == tmp.data then
      notbindItem = notbindItem .. tmp.text .. " "
    end
  end
  for i = 1, #tTakeItem.name do
    local tmp = tTakeItem.name[i]
    if 1 == tmp.data then
      notbindItem = notbindItem .. tmp.text .. " "
    end
  end
  for i = 1, #tTakeItem.class do
    local tmp = tTakeItem.class[i]
    if 2 == tmp.data then
      bindItem = bindItem .. tmp.text .. " "
    end
  end
  for i = 1, #tTakeItem.name do
    local tmp = tTakeItem.name[i]
    if 2 == tmp.data then
      bindItem = bindItem .. tmp.text .. " "
    end
  end
  if bTempBag then
    TempBank2Bag(normalItem, 0)
    TempBank2Bag(notbindItem, 1)
    TempBank2Bag(bindItem, 2)
  end
  Bank_GetItem(normalItem, -1, 0, 0, true, nil)
  Bank_GetItem(notbindItem, -1, 1, 0, true, nil)
  Bank_GetItem(bindItem, -1, 2, 0, true, nil)
  PushDebugMessage("仓库取物：已完成！")
end

function MainBankSaveItem(aKeepItem)
  CloseAllWindow()
  aKeepItem = aKeepItem and HandleText_AddFuHao(aKeepItem)
  local tSaveItem = g_config.item.save_bank
  local bTempBag = g_config.item.tempbag_cuncang
  local nKeepMoneyCount = -1
  if g_config.item.save_money then
    nKeepMoneyCount = HandleTextToNumber(g_config.item.unsave_money_count, 0) * 10000
    if nKeepMoneyCount < 0 then
      nKeepMoneyCount = -1
    end
    PushDebugMessage("执行：仓库存放物品")
  else
    PushColorMsg("执行仓库存物：您未勾选存钱")
  end
  local normalItem = ""
  local notbindItem = ""
  local bindItem = ""
  for i = 1, #tSaveItem.class do
    local tmp = tSaveItem.class[i]
    if 2 ~= tmp.data or aKeepItem and string.find(aKeepItem, " " .. tmp.text .. " ", nil, true) then
    else
      bindItem = bindItem .. tmp.text .. " "
    end
  end
  for i = 1, #tSaveItem.name do
    local tmp = tSaveItem.name[i]
    if 2 ~= tmp.data or aKeepItem and string.find(aKeepItem, " " .. tmp.text .. " ", nil, true) then
    else
      bindItem = bindItem .. tmp.text .. " "
    end
  end
  for i = 1, #tSaveItem.class do
    local tmp = tSaveItem.class[i]
    if 0 ~= tmp.data or aKeepItem and string.find(aKeepItem, " " .. tmp.text .. " ", nil, true) then
    else
      normalItem = normalItem .. tmp.text .. " "
    end
  end
  for i = 1, #tSaveItem.name do
    local tmp = tSaveItem.name[i]
    if 0 ~= tmp.data or aKeepItem and string.find(aKeepItem, " " .. tmp.text .. " ", nil, true) then
    else
      normalItem = normalItem .. tmp.text .. " "
    end
  end
  for i = 1, #tSaveItem.class do
    local tmp = tSaveItem.class[i]
    if 1 ~= tmp.data or aKeepItem and string.find(aKeepItem, " " .. tmp.text .. " ", nil, true) then
    else
      notbindItem = notbindItem .. tmp.text .. " "
    end
  end
  for i = 1, #tSaveItem.name do
    local tmp = tSaveItem.name[i]
    if 1 ~= tmp.data or aKeepItem and string.find(aKeepItem, " " .. tmp.text .. " ", nil, true) then
    else
      notbindItem = notbindItem .. tmp.text .. " "
    end
  end
  local nCount = 2
  if IsInFubenScene() then
    nCount = 1
  end
  if IsUnLockMibao() == false then
    PushColorMsg("仓库存物:您未解锁密保")
    nCount = 0
  end
  for i = 1, nCount do
    if bTempBag then
      TempBank2Bag(normalItem, 0)
      TempBank2Bag(notbindItem, 1)
      TempBank2Bag(bindItem, 2)
    end
    Bank_SaveItem(normalItem, nKeepMoneyCount, 0, true)
    Bank_SaveItem(notbindItem, nKeepMoneyCount, 1, true)
    Bank_SaveItem(bindItem, nKeepMoneyCount, 2, true)
    if not (not IsInDebugMsg("目标箱子已经满了") and bTempBag) then
      break
    end
  end
  if nKeepMoneyCount >= 0 and nKeepMoneyCount < Player:GetMoney() then
    Bank_SaveMoney(nKeepMoneyCount)
  end
  PushDebugMessage("仓库存物:已完成")
  CloseAllWindow()
end

function MainSellBuyItem(aDoInCity, aScriptName)
  PushDebugMessage("执行：补给出售")
  if not IsValidConfig(true) then
    return
  end
  if aDoInCity then
    local szSceneName = GetCurrentSceneName()
    if not string.find(" 洛阳 凤鸣镇 金陵 金陵2线 金陵3线 大理 楼兰 苏州 洛阳1线 洛阳2线 苏州1线 苏州2线 大理1线 大理2线 楼兰1线 楼兰2线 ", szSceneName, nil, true) then
      PushDebugMessage("补给出售：当前不在任何主城,补给结束！" .. szSceneName)
      return
    end
  end
  local otherName = " 小麋鹿贺卡 圣诞老人贺卡 圣诞树贺卡 "
  EatFubenItem(10)
  if IsUnLockMibao() == false then
    PushColorMsg("补给出售:您未解锁密保,无法出售物品")
  else
    ClearBag()
    Bag_SellItem(otherName, "", aScriptName)
  end
  Bag_BuyPetItem(aScriptName)
  if false == IsKVKSceneName() then
    Bag_BuyPlayerItem(aScriptName)
  end
  CloseAllWindow()
  PushDebugMessage("补给出售：已完成!")
end

function move_check()
  if m_move_cb and false == m_move_cb() then
    LogMsg("跨图移动：条件结束！")
    return false
  end
  return true
end

function main_move_cb(aX, aY, aScene)
  return move_check()
end

function SHG_callback(fX, fY, nScene)
  local strName = GetCurrentSceneName()
  strName = string.gsub(strName, "1线", "")
  strName = string.gsub(strName, "2线", "")
  if "" == strName or "圣火宫" == strName then
    return true
  end
  return false
end

function SameScene_moveback(fX, fY, nScene)
  if GetSceneID() ~= nScene then
    return false
  end
  return true
end

function GuMu_moveback_2(fX, fY, nScene)
  local tN = GetSceneID()
  if tN ~= nScene and tN + 1 ~= nScene then
    return false
  end
  return true
end

function DY_callback_1(aX, aY, aSceneID)
  DebugStr("移动到 x:%s y:%s scene:%s", 1, aX, aY, aSceneID)
  if SameScene_moveback(aX, aY, aSceneID) then
    local pos = Player:GetPos()
    if pos.x >= 135 and pos.x <= 210 and pos.y > 95 then
      return true
    end
  end
  return false
end

function DY_callback_2(aX, aY, aSceneID)
  DebugStr("移动到 x:%s y:%s scene:%s", 1, aX, aY, aSceneID)
  if SameScene_moveback(aX, aY, aSceneID) then
    local pos = Player:GetPos()
    if pos.x <= 204 and pos.x >= 147 and pos.y >= 95 then
      return true
    end
  end
  return false
end

function DY_callback_3(aX, aY, aSceneID)
  DebugStr("移动到 x:%s y:%s scene:%s", 1, aX, aY, aSceneID)
  if SameScene_moveback(aX, aY, aSceneID) then
    local pos = Player:GetPos()
    if pos.x <= 135 and pos.y >= 115 then
      return true
    end
  end
  return false
end

function DY_callback_4(aX, aY, aSceneID)
  DebugStr("移动到 x:%s y:%s scene:%s", 1, aX, aY, aSceneID)
  if SameScene_moveback(aX, aY, aSceneID) then
    local pos = Player:GetPos()
    if pos.x >= 58 and pos.x <= 118 and pos.y >= 110 then
      return true
    end
  end
  return false
end

function DY_callback_5(aX, aY, aSceneID)
  DebugStr("移动到 x:%s y:%s scene:%s", 1, aX, aY, aSceneID)
  if SameScene_moveback(aX, aY, aSceneID) then
    local pos = Player:GetPos()
    if pos.y < 110 or pos.x < 48 and pos.y < 130 then
      return true
    end
  end
  return false
end

function DG_callback_common(aX, aY, aSceneID)
  DebugStr("移动到 x:%s y:%s scene:%s", 1, aX, aY, aSceneID)
  local strName = GetCurrentSceneName()
  if "" == strName or string.find(strName, "秦皇地宫", nil, true) then
    return true
  end
  return false
end

function DiGongOne(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 263 == nowSceneID or 264 == nowSceneID or 292 == nowSceneID then
    PushDebugMessage("地宫：已经穿过地宫一层！")
    return
  end
  if 262 ~= nowSceneID then
    if 15 == nowSceneID or 7 == nowSceneID then
      MoveTo(227, 117, 262, 1, nil, nil, main_move_cb)
    else
      MoveTo(89, 139, 15, 1, nil, nil, main_move_cb)
    end
    return
  end
  local pos = Player:GetPos()
  if pos.x > 216 and pos.y > 100 then
    MoveTo(227, 117, 262, 1, true, nil, DG_callback_common)
    MoveTo(220, 115, 262, 1, true, nil, DG_callback_common)
    Sleep(1000)
    Skill:UseQingGong(211, 114)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  pos = Player:GetPos()
  if pos.x >= 205 and pos.x <= 215 and pos.y >= 113 and pos.y <= 115 then
    Skill:UseQingGong(200, 108)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
    PushDebugMessage("地一：已穿过第一个桥！")
  end
  if false == toNext then
    pos = Player:GetPos()
    if pos.x > 135 and pos.y > 95 and aToPosX > 135 and aToPosY > 95 then
      MoveTo(aToPosX, aToPosY, aToSceneID, 3, nil, nil, DY_callback_1)
      return
    end
  end
  pos = Player:GetPos()
  if pos.x >= 148 and pos.x <= 204 and pos.y >= 102 then
    MoveTo(152, 123, 262, 1, false, nil, DY_callback_2)
    Dismount()
    Skill:UseQingGong(144, 121)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
    Skill:UseName("初级隐遁", 300)
    Sleep(1500)
  end
  pos = Player:GetPos()
  if pos.x >= 122 and pos.x <= 148 and pos.y >= 119 and pos.y <= 125 then
    MoveTo(123, 122, 262, 1, false, nil, DG_callback_common)
    Skill:UseQingGong(116, 121)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
    PushColorMsg("地一：已穿过第二个桥！")
  end
  if false == toNext then
    pos = Player:GetPos()
    if pos.x <= 135 and pos.y >= 115 and aToPosX <= 135 and aToPosY >= 115 then
      MoveTo(aToPosX, aToPosY, aToSceneID, 3, true, nil, DY_callback_3)
      return
    end
  end
  pos = Player:GetPos()
  if pos.x >= 58 and pos.x <= 118 and pos.y >= 110 then
    MoveTo(59, 134, 262, 1, false, nil, DY_callback_4)
    Skill:UseQingGong(50, 135)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  pos = Player:GetPos()
  if pos.x < 100 and pos.y > 150 then
    MoveTo(59, 134, 262, 1, false, nil, DG_callback_common)
    Skill:UseQingGong(50, 135)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  pos = Player:GetPos()
  if pos.x >= 43 and pos.x <= 53 and pos.y >= 132 and pos.y <= 138 then
    MoveTo(45, 135, 262, 1, false, nil, DG_callback_common)
    Skill:UseQingGong(38, 136)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  pos = Player:GetPos()
  if pos.x >= 30 and pos.x <= 40 and pos.y >= 132 and pos.y <= 138 then
    MoveTo(33, 136, 262, 1, false, nil, DG_callback_common)
    Skill:UseQingGong(30, 126)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
    PushDebugMessage("地一：已穿过第三个桥！")
  end
  if false == toNext then
    pos = Player:GetPos()
    if aToPosY < 110 then
      if pos.x < 110 then
        MoveTo(aToPosX, aToPosY, aToSceneID, 3, true, nil, DY_callback_5)
        return
      end
      if aToPosY < 100 and (pos.x < 52 and pos.y < 128 or pos.y < 100) then
        MoveTo(aToPosX, aToPosY, aToSceneID, 3, true, nil, DY_callback_5)
        return
      end
    end
  end
  pos = Player:GetPos()
  if toNext and (pos.y < 95 or pos.x < 85 and pos.y < 130) then
    MoveTo(223, 225, 263, 3, true, nil, DG_callback_common)
  end
end

function DiGongTwo(toNext, aToPosX, aToPosY, aToSceneID, aUnNext)
  local nowSceneID = GetSceneID()
  if 263 == nowSceneID then
    local pos = Player:GetPos()
    if pos.x < 100 or pos.y > 200 or pos.x < 100 and pos.y < 61 then
      if false == toNext and (aToPosX < 100 or aToPosY > 200) then
        MoveTo(aToPosX, aToPosY, aToSceneID, 3, true, nil, DG_callback_common)
        return
      end
      if false == IsDestination(98, 40, 263, 5) then
        MoveTo(30, 86, 263, 3, true, nil, DG_callback_common)
      end
      MoveTo(98, 40, 263, 1, true, nil, DG_callback_common)
      Skill:UseQingGong(110, 40)
      Sleep(1000)
      PlayerStateTimeOut(3, 6)
    end
    pos = Player:GetPos()
    if pos.x > 105 and pos.x < 120 and pos.y < 46 then
      MoveTo(115, 40, 263, 1, false, nil, DG_callback_common)
      Skill:UseQingGong(127, 40)
      Sleep(1000)
      PlayerStateTimeOut(3, 6)
    end
    pos = Player:GetPos()
    if pos.x >= 120 and pos.y < 200 or pos.x >= 100 and pos.y > 50 and pos.y < 200 then
      if false == toNext then
        MoveTo(aToPosX, aToPosY, aToSceneID, 3, true, nil, DG_callback_common)
        return
      end
      if true == toNext and not aUnNext then
        MoveTo(224, 216, 264, 3, true, nil, DG_callback_common)
      end
    end
  elseif (264 == nowSceneID or 292 == nowSceneID) and false == toNext then
    MoveTo(117, 164, 263, 3, true, nil, DG_callback_common)
  elseif nowSceneID >= 0 then
    DiGongOne(true)
  end
end

function DiGongOther(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 264 == nowSceneID or 292 == nowSceneID then
    MoveTo(aToPosX, aToPosY, aToSceneID, 3, true, nil, DG_callback_common)
  else
    DiGongTwo(true)
  end
end

function SHG_To()
  local bFei = false
  local pos = Player:GetPos()
  if pos.x <= 32 and pos.y > 90 then
    bFei = true
    RunTo(26, 93, 0, 800)
    PlayerStateTimeOut(2, 5)
    Dismount(500)
    Sleep(200)
    Skill:UseQingGong(26, 85)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  pos = Player:GetPos()
  if pos.x < 30 and pos.y > 78 and pos.y < 89 then
    bFei = true
    RunTo(26, 81, 0, 800)
    PlayerStateTimeOut(2, 5)
    Dismount(500)
    RunTo(26, 81, 0, 800)
    Sleep(3000)
    Skill:UseQingGong(26, 73)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  return bFei
end

function SHG_Leave()
  local bFei = false
  local pos = Player:GetPos()
  if pos.x > 32 or pos.y < 78 then
    bFei = true
    RunTo(26, 73, 0, 800)
    PlayerStateTimeOut(2, 30)
    Dismount(500)
    Sleep(200)
    Skill:UseQingGong(26, 81)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  pos = Player:GetPos()
  if pos.x < 30 and pos.y > 78 and pos.y < 89 then
    bFei = true
    RunTo(26, 86, 0, 800)
    PlayerStateTimeOut(2, 5)
    Dismount(500)
    RunTo(26, 86, 0, 800)
    Sleep(3000)
    Skill:UseQingGong(26, 93)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  return bFei
end

function ShengHuoGong(aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 256 == nowSceneID then
    SHG_To()
    local pos = Player:GetPos()
    if pos.x > 35 or pos.y < 75 then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, true, nil, SHG_callback)
    end
  else
    MoveTo(26, 100, 256, 1, true, nil, main_move_cb)
  end
end

function GuMuTwo(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  local nTemp = 210 - nowSceneID
  if nTemp < 0 or nTemp > 8 then
    DebugStr("前往古墓一")
    MoveTo(28, 70, 202, nil, nil, nil, main_move_cb)
    return false
  end
  local pos = Player:GetPos()
  if 203 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("去古二")
    return true
  elseif 202 == nowSceneID then
    if pos.x < 27 and pos.y > 74 and pos.y < 87 then
    else
      MoveTo(28, 70, 202, nil, nil, nil, SameScene_moveback)
      Sleep(300)
    end
    Skill:UseQingGong(20, 79)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
    MoveConfirm()
  else
    DebugStr("古墓二出错")
  end
  return false
end

function GuMuThree(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 204 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("到古三")
    return true
  elseif GuMuTwo(true) then
    MoveTo(13, 25, 204, nil, nil, nil, GuMu_moveback_2)
  end
  return false
end

function GuMuFour(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 205 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("到古四")
    return true
  elseif GuMuThree(true) then
    MoveTo(102, 18, 205, nil, nil, nil, GuMu_moveback_2)
  end
  return false
end

function GuMuFive(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 206 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("到古五")
    return true
  elseif GuMuFour(true) then
    MoveTo(24, 24, 206, nil, nil, nil, GuMu_moveback_2)
  end
  return false
end

function GuMuSix(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 207 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("到古六")
    return true
  elseif GuMuFive(true) then
    MoveTo(65, 108, 207, nil, nil, nil, GuMu_moveback_2)
  end
  return false
end

function GuMuSeven(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 208 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("到古七")
    return true
  elseif GuMuSix(true) then
    MoveTo(64, 60, 207, nil, nil, nil, GuMu_moveback_2)
    Skill:UseQingGong(65, 55)
    Sleep(1000)
    PlayerStateTimeOut(3, 6)
  end
  return false
end

function GuMuEight(toNext, aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  if 209 == nowSceneID then
    if false == toNext then
      MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    end
    DebugStr("到古八")
    return true
  elseif GuMuSeven(true) then
    MoveTo(14, 14, 209, nil, nil, nil, GuMu_moveback_2)
  end
  return false
end

function GuMuNine(aToPosX, aToPosY, aToSceneID)
  local nowSceneID = GetSceneID()
  local pos = Player:GetPos()
  if 210 == nowSceneID then
    MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, SameScene_moveback)
    DebugStr("到古墓9")
    return true
  elseif GuMuEight(true) then
    if pos.x > 31 and pos.x < 60 and pos.y < 45 then
      MoveTo(20, 18, 210, nil, nil, nil, GuMu_moveback_2)
      return false
    elseif pos.x > 31 and pos.x < 77 and pos.y < 40 then
    else
      MoveTo(81, 24, 209, nil, nil, nil, SameScene_moveback)
      Sleep(300)
    end
    Skill:UseQingGong(73, 24)
    Sleep(5000)
    PlayerStateTimeOut(3, 6)
    Skill:UseQingGong(66, 23)
    Sleep(5000)
    PlayerStateTimeOut(3, 6)
    Skill:UseQingGong(55, 24)
    Sleep(5000)
    PlayerStateTimeOut(3, 6)
    Skill:UseName("初级隐遁", 300)
  end
  return false
end

function MainMoveToScene(aToSceneID, aToPosX, aToPosY, aCB)
  m_move_cb = nil
  if aCB then
    m_move_cb = aCB
  end
  local toSceneName = GetSceneNameByID(aToSceneID)
  PushColorMsg("前往地图：%s,地图ID：%s,X坐标：%s,Y坐标：%s", toSceneName, aToSceneID, math.floor(aToPosX), math.floor(aToPosY))
  
  local function _cb(_aX, _aY, _aSceneID)
    if aCB and false == aCB() then
      return false
    end
    return true
  end
  
  while true do
    if IsDestination(aToPosX, aToPosY, aToSceneID, 3) then
      PushDebugMessage("已回到挂机点")
      break
    end
    if aCB and false == aCB() then
      break
    end
    local nowSceneID = GetSceneID()
    if nowSceneID >= 0 then
      if "秦皇地宫一层" == toSceneName then
        DiGongOne(false, aToPosX, aToPosY, aToSceneID)
      elseif "秦皇地宫二层" == toSceneName then
        DiGongTwo(false, aToPosX, aToPosY, aToSceneID)
      elseif "秦皇地宫三层" == toSceneName or "秦皇地宫四层" == toSceneName then
        DiGongOther(false, aToPosX, aToPosY, aToSceneID)
      elseif "圣火宫" == toSceneName then
        ShengHuoGong(aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓二层" == toSceneName then
        GuMuTwo(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓三层" == toSceneName then
        GuMuThree(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓四层" == toSceneName then
        GuMuFour(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓五层" == toSceneName then
        GuMuFive(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓六层" == toSceneName then
        GuMuSix(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓七层" == toSceneName then
        GuMuSeven(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓八层" == toSceneName then
        GuMuEight(false, aToPosX, aToPosY, aToSceneID)
      elseif "燕王古墓九层" == toSceneName then
        GuMuNine(aToPosX, aToPosY, aToSceneID)
      else
        MoveTo(aToPosX, aToPosY, aToSceneID, nil, nil, nil, _cb)
      end
    end
    DebugStr("前往挂机地图中")
    Sleep(200)
  end
  m_move_cb = nil
end

function FubenAttack(aTargetID, aUseSkill, aUseJinJiSkill, aCheckHpMpDx, aPetFightHappyDieOutBuji, aMustAttack, aPetSkill, aOnlyPetAttack)
  if aTargetID >= 0 and Player:IsFollow() and Player:IsLeader() then
    Player:TeamFollow(false, 200)
  end
  Dismount()
  CDG:BossStart(aTargetID, aUseSkill, aUseJinJiSkill, aCheckHpMpDx, aPetFightHappyDieOutBuji, aMustAttack, aPetSkill, aOnlyPetAttack)
end

function TargetAttack(aTid, aJinJiSkill)
  if CDG:SkillAttack(aTid) == false then
    if aJinJiSkill then
      CDG:SkillJinJi(aTid)
    end
    Target:Attack(aTid, 200, CDG.tragetSelect, nil, false)
    if 4 == g_self.menpai then
      local add_hp_name = CDG:checkHP_Player()
    end
  end
end

function CheckDistAttack(aTarget, bCheckPet, bJinJiSkill)
  if aTarget and aTarget.dst <= 15 then
    if g_self.isjingong == false or aTarget.dst <= 2 then
      FubenAttack(aTarget.id, nil, bJinJiSkill, nil, bCheckPet)
    else
      JinGongFarSkill(aTarget.id)
      FubenAttack(-1, nil, nil, nil, bCheckPet)
    end
  else
    FubenAttack(-1, nil, nil, nil, bCheckPet)
  end
end

function JinGongFarSkill(aTid, aUsePetAttack)
  local bUse = false
  if CDG.attack then
    if aUsePetAttack then
      FubenAttack(aTid, false, false, nil, nil, nil, nil, true)
    end
    if -1 ~= aTid then
      local skl = Skill:GetJinGongFarSkill()
      for i = 1, #skl do
        local tmp = skl[i]
        if Skill:UseSkillByName(tmp.name, aTid, nil, nil, 100) then
          bUse = true
          break
        end
      end
    end
  end
  return bUse
end

function FuBenCheckDie(aDieOut, aDiewait, aDieDo_cb, aDieRefresh_cb)
  local isDie = false
  local errorMap = false
  if nil == aDiewait then
    aDiewait = true
  end
  while true do
    if IsInFubenScene() == false then
      errorMap = true
      break
    end
    if 9 == Player:GetState() then
      isDie = true
      local bNext = true
      if aDieDo_cb then
        bNext = aDieDo_cb()
      end
      if bNext then
        if aDieOut then
          errorMap = true
          PushDebugMessage("副本:已设置死亡自动出窍")
          DieRelive(-1)
        else
          if aDieRefresh_cb then
            aDieRefresh_cb()
          end
          DieRelive(0)
          local bHave, HPValue = Team:IsSceneHaveFammily(nil, 4)
          if false == bHave or 0 == HPValue then
            Sleep(4000)
            bHave, HPValue = Team:IsSceneHaveFammily(nil, 4)
            if false == bHave or 0 == HPValue then
              errorMap = true
              PushDebugMessage("副本：峨嵋已出或者已死亡,自动出窍")
              DieRelive(-1)
            end
          end
        end
      end
    else
      break
    end
    if false == aDiewait then
      break
    end
    Sleep(1000)
    DebugStr("副本:角色死亡,等待救起！")
  end
  return isDie, errorMap
end

function FubenCheckSceneDie(aSceneID)
  local bOK = true
  local errorMap = false
  local isDie = false
  if GetSceneID() ~= aSceneID then
    errorMap = true
  end
  if 9 == Player:GetState() then
    isDie = true
  end
  if isDie or errorMap then
    bOK = false
  end
  return bOK, isDie, errorMap
end

function FastSkill(aPos, aCmpDist)
  aCmpDist = aCmpDist or 3
  local myPos = Player:GetPos()
  aPos.dst = GetDist(aPos.x, aPos.y, myPos.x, myPos.y)
  if aCmpDist < aPos.dst and Skill:UseShunYi(aPos.x, aPos.y) == false then
    Skill:UseSpeed()
  end
end

function FastRun(aPos, aCmpDist)
  FastSkill(aPos, aCmpDist)
  return not RunTo(aPos.x, aPos.y, 0, 200)
end

function FubenRunSafe_easy(aPos, aPosSafe, aParam)
  BubbleByDst(aPosSafe, 1)
  local runpos = aPosSafe[1]
  RunTo(runpos.x, runpos.y, 0, 500)
end

function GetPosAngleDiff(aPosArr, aCmp)
  for i = 1, #aPosArr do
    local tmp = aPosArr[i]
    local diff = math.abs(tmp.angle - aCmp)
    if diff > 335 then
      diff = 360 - diff
    end
    aPosArr[i].angle_diff = diff
  end
  return aPosArr
end

function RunSafePos(aPos, aParam)
  local runpos = aPos
  FastSkill(runpos, 4)
  RunTo(runpos.x, runpos.y, 0, 200)
  for i = 1, 5 do
    if 2 ~= Player:GetState() and GetDist(runpos.x, runpos.y) > 1 then
      RunTo(runpos.x, runpos.y, 0, 100)
    else
      break
    end
  end
  if 4 == g_self.menpai then
    if 3 ~= Player:GetState() then
      RunTo(runpos.x, runpos.y, 0, 200)
    end
    PlayerStateTimeOut(2, 2)
  end
end

function FubenRunSafe(aPos, aPosSafe, aParam)
  local runpos = aPos
  if g_self.isjingong and CDG.attack and -1 ~= runpos.hp and (nil == aParam or nil == aParam.sort_boss or aParam.sort_boss == true) then
    BubbleByHP(aPosSafe, 1)
    runpos = aPosSafe[1]
  end
  RunSafePos(runpos, aParam)
end

function FubenRunSafe_Sort(aPos, aPosSafe, aParam)
  if aParam then
    if aParam.selfdist then
      BubbleByDst(aPosSafe, 1)
    elseif aParam.zerodist then
      BubbleByLevel(aPosSafe, 1)
    elseif aParam.bossdist then
      BubbleByHP(aPosSafe, 1)
    end
  end
  local runpos = aPosSafe[1]
  RunSafePos(runpos, aParam)
end

function FubenRunSafe_fangshe(aPos, aAllPosSafe, aParam)
  local angleSelf = GetAngle(aParam.x, aParam.y, aParam.xSelf, aParam.ySelf)
  for i = 1, #aAllPosSafe do
    aAllPosSafe[i].angle = GetAngle(aParam.x, aParam.y, aAllPosSafe[i].x, aAllPosSafe[i].y)
  end
  GetPosAngleDiff(aAllPosSafe, angleSelf)
  local tRun = {}
  for i = 5, 1, -1 do
    tRun = ObjFilterByInt(aAllPosSafe, i, 1, "level")
    BubbleSort(tRun, "angle_diff", 1)
    if #tRun > 0 and tRun[1].angle_diff < 20 then
      break
    end
  end
  if 0 == #tRun then
    tRun = aAllPosSafe
  end
  local bfind = false
  for i = 1, 5 do
    local tfind = ObjFilterByInt(tRun, i * 5, 2, "angle_diff")
    if #tfind > 0 then
      bfind = true
      if aParam.sort_zero then
        BubbleByLevel(tfind, 1)
      else
        BubbleByDst(tfind, 1)
      end
      if aParam.usespeed == nil or aParam.usespeed then
        FastRun(tfind[1], 3)
      else
        RunTo(tfind[1].x, tfind[1].y, 0, 200)
      end
      local runpos = tfind[1]
      for i = 1, 5 do
        if 2 ~= Player:GetState() and GetDist(runpos.x, runpos.y) > 1 then
          RunTo(runpos.x, runpos.y, 0, 100)
        else
          break
        end
      end
      break
    end
  end
  if false == bfind and #tRun > 0 then
    if aParam.usespeed == nil or aParam.usespeed then
      FastRun(tRun[1], 3)
    else
      RunTo(tRun[1].x, tRun[1].y, 0, 200)
    end
    local runpos = tRun[1]
    for i = 1, 5 do
      if 2 ~= Player:GetState() and GetDist(runpos.x, runpos.y) > 1 then
        RunTo(runpos.x, runpos.y, 0, 100)
      else
        break
      end
    end
  end
  if 4 == g_self.menpai then
    PlayerStateTimeOut(2, 3)
  end
end

function IsPosSafe(aPos, aUnsafePos, aRadius)
  local bIsSafe = true
  for i = 1, #aUnsafePos do
    if aRadius >= GetDist(aPos.x, aPos.y, aUnsafePos[i].x, aUnsafePos[i].y) then
      bIsSafe = false
      break
    end
  end
  return bIsSafe
end

function IsPlayerTrap(szText)
  if nil == szText or "" == szText then
    return false
  end
  if string.find(szText, "初级陷阱", nil, true) or string.find(szText, "八阵图", nil, true) or string.find(szText, "诛仙阵", nil, true) or string.find(szText, "桃花阵", nil, true) or string.find(szText, "定海神针", nil, true) or string.find(szText, "步步生花", nil, true) or string.find(szText, "破天式", nil, true) or string.find(szText, "凌神式消失", nil, true) or string.find(szText, "傀儡香", nil, true) or string.find(szText, "散魂阵术", nil, true) then
    return true
  end
  return false
end

function FindSpecial(aSpecialName)
  local tObj = Enum2XByClass("陷阱")
  for i = 1, #tObj do
    if string.find(tObj[i].name, aSpecialName, nil, true) then
      return true
    end
  end
  return false
end

function EnumUnSafeSpecial(aSpecName, aNameType)
  aNameType = aNameType or 1
  local tSpecial = {}
  local tObj = Enum2XByClass("陷阱")
  if 2 == aNameType then
    aSpecName = aSpecName or ""
    aSpecName = HandleText_AddFuHao(aSpecName, " ", true)
  end
  for i = 1, #tObj do
    if IsPlayerTrap(tObj[i].name) == false then
      if 1 == aNameType then
        if nil == aSpecName or string.find(tObj[i].name, aSpecName, nil, true) then
          local n = #tSpecial + 1
          tSpecial[n] = tObj[i]
        end
      elseif string.find(aSpecName, " " .. tObj[i].name .. " ", nil, true) then
        local n = #tSpecial + 1
        tSpecial[n] = tObj[i]
      end
    end
  end
  return tSpecial
end

function GetAllPosDist(aTab, aCmpPos, aField)
  aCmpPos = aCmpPos or Player:GetPos()
  aField = aField or "dst"
  for i = 1, #aTab do
    aTab[i][aField] = GetDist(aTab[i].x, aTab[i].y, aCmpPos.x, aCmpPos.y)
  end
  return aTab
end

function GetAllSafePos(tSpecial, allPos, radius)
  local safePos = {}
  for i = 1, #allPos do
    if IsPosSafe(allPos[i], tSpecial, radius) then
      table.insert(safePos, allPos[i])
    end
  end
  return safePos
end

function GetAveragePoint(xR, yR, r, nPos, index)
  local nMax = nPos
  index = index or 1
  if 0 == index then
    nMax = nMax - 1
  end
  if nPos < 3 then
    nPos = 3
  end
  local angle = 360 / nPos
  local tObj = {}
  for i = index, nMax do
    local fAngle = math.pi * i * angle / 180
    local fX = math.floor(xR + r * math.sin(fAngle) + 0.5)
    local fY = math.floor(yR - r * math.cos(fAngle) + 0.5)
    local n = #tObj + 1
    local a = GetAngle(xR, yR, fX, fY)
    tObj[n] = {
      x = fX,
      y = fY,
      angle = a,
      index = i
    }
  end
  return tObj
end

function GetRunposOfRange(aRunPos, aTargetPos, aRange)
  local range = aRange or 14
  if range >= GetDist(aRunPos.x, aRunPos.y, aTargetPos.x, aTargetPos.y) then
    return aRunPos
  else
    local tPos = GetAveragePoint(aTargetPos.x, aTargetPos.y, range, 36, 0)
    tPos = GetAllPosDist(tPos, {
      x = aRunPos.x,
      y = aRunPos.y
    }, "dst")
    BubbleByDst(tPos, 1)
    return tPos[1]
  end
end

function GetRangeAllPos(aZeroX, aZeroY, aMinRadius, aMaxRadius, aBoss)
  local allPos = {}
  local posSelf = Player:GetPos()
  for k = 1, aMaxRadius do
    if aMinRadius <= k then
      local pos = GetAveragePoint(aZeroX, aZeroY, k, 36)
      for j = 1, #pos do
        pos[j].dst = GetDist(pos[j].x, pos[j].y, posSelf.x, posSelf.y)
        pos[j].level = GetDist(pos[j].x, pos[j].y, aZeroX, aZeroY)
        if aBoss and aBoss.x and aBoss.y then
          pos[j].hp = GetDist(pos[j].x, pos[j].y, aBoss.x, aBoss.y)
        else
          pos[j].hp = -1
        end
        table.insert(allPos, pos[j])
      end
    end
  end
  return allPos
end

function GetNearestPoint(aPosArr, aPosCmp)
  aPosCmp = aPosCmp or Player:GetPos()
  local dst, idx = 9999, 1
  for i = 1, #aPosArr do
    local ndst = GetDist(aPosCmp.x, aPosCmp.y, aPosArr[i].x, aPosArr[i].y)
    if dst > ndst then
      dst = ndst
      idx = i
    end
  end
  return idx
end

function TeamGetDispersedStations(aPosZero, aRadius, aPosCount)
  local nMemIndex, teamCount = Team:GetMyIndex()
  aPosCount = aPosCount or teamCount
  local tPos = GetAveragePoint(aPosZero.x, aPosZero.y, aRadius, aPosCount, 0)
  if nMemIndex >= 0 and nMemIndex < #tPos then
    return tPos[nMemIndex + 1]
  end
  return nil
end

function TeamDispersedStations(aPosZero, aRadius, aPosCount)
  local tRun = TeamGetDispersedStations(aPosZero, aRadius, aPosCount)
  if tRun then
    if RunTo(tRun.x, tRun.y, 0, 500) == false then
      return true, tRun
    end
    return false, tRun
  end
  return false, nil
end

function TeamDispersedStations_fast(aPosZero, aRadius, aPosCount)
  local tRun = TeamGetDispersedStations(aPosZero, aRadius, aPosCount)
  if tRun then
    tRun.dst = GetDist(tRun.x, tRun.y)
    FastRun(tRun, 3)
    if RunTo(tRun.x, tRun.y, 0, 300) == false then
      return true, tRun
    end
    return false, tRun
  end
  return false, nil
end

function AStarRun(aZero, aPos, aTrap, aTrapRadius, aBorderCall, aRunCall, aRunCount)
  local bRun = false
  local canNearbyPos = true
  if 0 == #aTrap then
    RunTo(aPos.x, aPos.y, 0, 1000)
    return bRun
  end
  local posSelf = Player:GetPos()
  local rad = aZero.r - 1
  if #aTrap > 0 and IsPosSafe(posSelf, aTrap, aTrapRadius) then
    local bNext = true
    local runpos = {}
    runpos.x = aPos.x
    runpos.y = aPos.y
    if not IsPosSafe(aPos, aTrap, aTrapRadius) then
      if canNearbyPos then
        local nearbyPos = GetAveragePoint(aPos.x, aPos.y, 2, 8, 0)
        local safePos = {}
        for i = 1, #nearbyPos do
          if IsPosSafe(nearbyPos[i], aTrap, aTrapRadius) then
            table.insert(safePos, nearbyPos[i])
          end
        end
        if 0 == #safePos then
          bNext = false
        else
          GetAllPosDist(safePos)
          BubbleByDst(safePos)
          bNext = false
          for i = 1, #safePos do
            local tmp = safePos[i]
            if nil == aBorderCall or aBorderCall(tmp) then
              runpos.x = tmp.x
              runpos.y = tmp.y
              bNext = true
              break
            end
          end
        end
      else
        bNext = false
      end
    end
    if bNext then
      if GetDist(posSelf.x, posSelf.y, runpos.x, runpos.y) > 2 then
        local function positionIsOpen(_aPosX, _aPosY)
          local pos = {x = _aPosX, y = _aPosY}
          
          if aBorderCall and not aBorderCall(pos) then
            return false
          end
          if GetDist(aZero.x, aZero.y, pos.x, pos.y) > rad then
            return false
          end
          return IsPosSafe(pos, aTrap, aTrapRadius)
        end
        
        local path = AStar(nil, runpos, aZero.x - rad, aZero.x + rad, aZero.y - rad, aZero.y + rad, positionIsOpen)
        if aRunCall then
          bRun = aRunCall(path)
        else
          bRun = AStarMove(path, aRunCount)
        end
      end
    else
      DebugStr("坐标%s,%s不安全,暂不靠近", 2, math.floor(aPos.x), math.floor(aPos.y))
    end
  end
  return bRun
end

function SafeRunToPickBag(aZero, aTrap, aTrapRadius, aBorderCall)
  local bHas = false
  local bRun = false
  local bPick = false
  local tOrgObj = Enum2XByClass("包裹", nil, 1)
  if #tOrgObj > 0 then
    local tmp = tOrgObj[1]
    if tmp.dst < 3 then
      bPick = true
      PickUpLua()
    else
      bRun = AStarRun(aZero, tmp, aTrap, aTrapRadius, aBorderCall)
    end
    bHas = true
  end
  return bHas, bRun, bPick
end

function FubenTrapRun(aBossName, aZeroX, aZeroY, aTrapRadius, aMaxRadius, aHasSpecialObj, aCheckBorder_cb, aRunSafe_cb, aSpecialFitle_cb, aMinRadius, aParam)
  aMinRadius = aMinRadius or 1
  local nFindPos = 0
  local tSpecial = {}
  if aHasSpecialObj then
    tSpecial = aHasSpecialObj
  else
    tSpecial = EnumUnSafeSpecial()
  end
  if aSpecialFitle_cb then
    local specRadius_callback
    tSpecial, specRadius_callback = aSpecialFitle_cb(tSpecial)
    aTrapRadius = specRadius_callback or aTrapRadius
  end
  local posSelf = Player:GetPos()
  if IsPosSafe(posSelf, tSpecial, aTrapRadius) then
    return true, tSpecial, {}, nFindPos
  end
  local bIsFindBoss = false
  local tObj = Enum2XByName(aBossName, {
    1,
    1,
    0,
    0
  }, nil, nil, 3)
  if #tObj > 0 then
    bIsFindBoss = true
  end
  local posSafe = {}
  local allPos = GetRangeAllPos(aZeroX, aZeroY, aMinRadius, aMaxRadius, tObj[1])
  for i = 1, #allPos do
    if IsPosSafe(allPos[i], tSpecial, aTrapRadius) and (nil == aCheckBorder_cb or aCheckBorder_cb(allPos[i])) then
      table.insert(posSafe, allPos[i])
    end
  end
  if #posSafe > 0 then
    nFindPos = 1
    BubbleByDst(posSafe, 1)
    if aRunSafe_cb then
      aRunSafe_cb(posSafe[1], posSafe, aParam, tObj[1])
    else
      if bIsFindBoss and g_self.isjingong and CDG.attack then
        BubbleByHP(posSafe, 1)
      end
      if false == bIsFindBoss then
        BubbleByLevel(posSafe, 1)
      end
      RunTo(posSafe[1].x, posSafe[1].y, 0, 550)
      PlayerStateTimeOut(2, 1, nil)
    end
  else
    nFindPos = 2
    DebugStr("没有找到安全坐标", 4)
  end
  return false, tSpecial, posSafe, nFindPos
end

function FubenShanXing(aBoss, aSXPos, aZouWeiMode, aUnSafeAngleDiff, aRunAngleDiff, aRunZero, aXJAngle)
  aRunZero = aRunZero or aBoss
  aUnSafeAngleDiff = aUnSafeAngleDiff or 25
  aRunAngleDiff = aRunAngleDiff or 30
  local bSafe = true
  local myPos = Player:GetPos()
  local xjAngle = aXJAngle or GetAngle(aBoss.x, aBoss.y, aSXPos.x, aSXPos.y)
  local myAngle = GetAngle(aBoss.x, aBoss.y, myPos.x, myPos.y)
  local diffAngle = math.abs(myAngle - xjAngle)
  if diffAngle > 180 then
    diffAngle = 360 - diffAngle
  end
  if aUnSafeAngleDiff > diffAngle then
    bSafe = false
    local myDist = GetDist(aBoss.x, aBoss.y, myPos.x, myPos.y)
    local bNextPaoWei = true
    local bitJG = aZouWeiMode & 1
    local bitMust = aZouWeiMode >> 1 & 1
    local bitJGMust = aZouWeiMode >> 2 & 1
    if 1 == bitJG and g_self.isjingong or 1 == bitMust or 1 == bitJGMust and g_self.isjingong then
      bNextPaoWei = false
      local tempPos = {}
      if aXJAngle then
        local safeAngle = aXJAngle + 180
        while safeAngle >= 360 do
          safeAngle = safeAngle - 360
        end
        local pos = GetAnglePos(aRunZero, safeAngle, 2)
        table.insert(tempPos, pos)
        tempPos = GetAllPosDist(tempPos, nil, "dst")
      else
        tempPos = GetAveragePoint(aRunZero.x, aRunZero.y, 2, 360)
        tempPos = GetAllPosDist(tempPos, aSXPos, "dst")
        BubbleByDst(tempPos, 2)
      end
      if tempPos[1].dst <= 7 or 1 == bitMust or 1 == bitJGMust then
        FastRun(tempPos[1], 4)
      else
        bNextPaoWei = true
      end
    end
    if bNextPaoWei then
      local newAngle1 = xjAngle - aRunAngleDiff
      local newAngle2 = xjAngle + aRunAngleDiff
      if newAngle1 < 0 then
        newAngle1 = newAngle1 + 360
      end
      if newAngle2 >= 360 then
        newAngle2 = newAngle2 - 360
      end
      local pos1 = GetAnglePos(aBoss, newAngle1, myDist)
      local pos2 = GetAnglePos(aBoss, newAngle2, myDist)
      local runpos = pos1
      if GetDist(pos1.x, pos1.y, myPos.x, myPos.y) > GetDist(pos2.x, pos2.y, myPos.x, myPos.y) then
        runpos = pos2
      end
      FastRun(runpos, 4)
    end
  end
  return bSafe
end

function IsAngleSafe(aTrap, aCheckPos, aMinSafeAngle, aTrapZeroMinDist, aBossZero)
  local minDist = aTrapZeroMinDist or 1.8
  local checkPos = aCheckPos or Player:GetPos()
  if 0 == #aTrap then
    return true
  end
  local trapZero = aBossZero
  if minDist > GetDist(trapZero.x, trapZero.y, checkPos.x, checkPos.y) then
    return false
  end
  local myAngle = GetAngle(trapZero.x, trapZero.y, checkPos.x, checkPos.y)
  for i = 1, #aTrap do
    local diffAngle = math.abs(myAngle - aTrap[i].angle)
    if aMinSafeAngle >= diffAngle or diffAngle >= 360 - aMinSafeAngle then
      return false
    end
  end
  return true
end

function FubenShanXing2(aZero, aTrapZero, aTrapAngle, aMinSafeAngle, aBoss)
  local myPos = Player:GetPos()
  local bSafe = true
  local trapZero = aTrapZero
  trapZero.angle = aTrapAngle
  local tTrap = {}
  table.insert(tTrap, trapZero)
  if not IsAngleSafe(tTrap, myPos, aMinSafeAngle, nil, trapZero) then
    bSafe = false
    local posSafe = {}
    local safeAngle = aTrapAngle + 180
    while safeAngle >= 360 do
      safeAngle = safeAngle - 360
    end
    local pos = GetAnglePos(aTrapZero, safeAngle, 2)
    pos.level = GetDist(pos.x, pos.y, aZero.x, aZero.y)
    if pos.level <= aZero.rmax then
      pos.dst = GetDist(pos.x, pos.y, myPos.x, myPos.y)
      if aBoss then
        pos.hp = GetDist(pos.x, pos.y, aBoss.x, aBoss.y)
      end
      table.insert(posSafe, pos)
    end
    if 0 == #posSafe or posSafe[1].dst > 5 then
      posSafe = {}
      local allPos = GetRangeAllPos(aZero.x, aZero.y, aZero.rmin, aZero.rmax, aBoss)
      for i = 1, #allPos do
        local temp = allPos[i]
        if IsAngleSafe(tTrap, temp, aMinSafeAngle, nil, trapZero) then
          table.insert(posSafe, temp)
        end
      end
    end
    if #posSafe > 0 then
      if aBoss and g_self.isjingong and CDG.attack then
        BubbleByHP(posSafe, 1)
        if posSafe[1].dst > 6 then
          BubbleByDst(posSafe, 1)
        end
      else
        BubbleByDst(posSafe, 1)
      end
      local runpos = posSafe[1]
      FastRun(runpos, 4)
    else
      DebugStr("扇形陷阱没有找到安全坐标", 4)
    end
  end
  return bSafe
end

function FubenTrapTiaoXing(aTrap, aTrapLen, aUnSafeR, aZero, aBoss)
  local bSafe = true
  local myPos = Player:GetPos()
  local unsafePos = {}
  for i = 1, #aTrap do
    local tmp = aTrap[i]
    for j = 1, aTrapLen do
      local tempPos = GetAnglePos(tmp, tmp.angle, j)
      if tempPos.x > 0 then
        table.insert(unsafePos, tempPos)
      end
    end
  end
  if not IsPosSafe(myPos, unsafePos, aUnSafeR) then
    bSafe = false
    local posSafe = {}
    local allPos = GetRangeAllPos(aZero.x, aZero.y, aZero.rmin, aZero.rmax, nil)
    for i = 1, #allPos do
      if IsPosSafe(allPos[i], unsafePos, aUnSafeR) then
        table.insert(posSafe, allPos[i])
      end
    end
    if #posSafe > 0 then
      if aBoss and g_self.isjingong and CDG.attack then
        BubbleByHP(posSafe, 1)
        if posSafe[1].dst > 6 then
          BubbleByDst(posSafe, 1)
        end
      else
        BubbleByDst(posSafe, 1)
      end
      local runpos = posSafe[1]
      FastRun(runpos, 4)
    else
      DebugStr("条形陷阱：没有找到安全坐标", 4)
    end
  end
  return bSafe
end

function FubenPullTarget(xZero, yZero, radius, tBoss, aKeepDist, aMove_cb, aParam)
  local tObj = FindObjByTID(tBoss.id)
  if not tObj then
    return false
  end
  local num_pos = 8
  local safedist = aKeepDist or 6
  local pos = Player:GetPos()
  if safedist < GetDist(pos.x, pos.y, tObj.x, tObj.y) then
    return false
  end
  local tPos = GetAveragePoint(xZero, yZero, radius, num_pos, 0)
  tPos = GetAllPosDist(tPos)
  tPos = GetAllPosDist(tPos, tObj, "hp")
  local selfAngle = GetAngle(xZero, yZero, pos.x, pos.y)
  local bossAngle = GetAngle(xZero, yZero, tObj.x, tObj.y)
  if bossAngle <= 90 and (selfAngle < bossAngle or selfAngle > 270) then
    BubbleSort(tPos, "angle", 2)
  end
  if selfAngle < bossAngle and selfAngle >= 90 then
    BubbleSort(tPos, "angle", 2)
  end
  local iRun = 2
  for i = 1, #tPos do
    local tmp = tPos[i]
    local posAngle = tmp.angle
    if selfAngle < bossAngle then
      if bossAngle > 270 and selfAngle <= 90 then
        if selfAngle < posAngle then
          iRun = i
          break
        end
      elseif bossAngle <= 90 and selfAngle <= 45 then
        if selfAngle < posAngle then
          iRun = i
          break
        end
      elseif selfAngle > posAngle then
        iRun = i
        break
      end
    elseif bossAngle >= 270 and selfAngle >= 315 then
      if selfAngle > posAngle then
        iRun = i
        break
      end
    elseif bossAngle <= 90 and selfAngle > 270 then
      if selfAngle > posAngle then
        iRun = i
        break
      end
    elseif selfAngle < posAngle then
      iRun = i
      break
    end
  end
  local run = tPos[iRun]
  if aMove_cb then
    run = aMove_cb(run, tPos, tObj, aParam)
  else
    FastRun(run, 3)
  end
  return true, run
end

function AStar(aStart, aStop, aWidthStart, aWidthStop, aHeightStart, aHeightStop, aPosIsOpen)
  if g_luastar == nil then
    g_luastar = LoadScript("lua-star")
  end
  aWidthStart = math.floor(aWidthStart + 0.5)
  aWidthStop = math.floor(aWidthStop + 0.5)
  aHeightStart = math.floor(aHeightStart + 0.5)
  aHeightStop = math.floor(aHeightStop + 0.5)
  local start = aStart or Player:GetPos()
  start.x = math.floor(start.x + 0.5)
  start.y = math.floor(start.y + 0.5)
  local goal = {}
  goal.x = math.floor(aStop.x + 0.5)
  goal.y = math.floor(aStop.y + 0.5)
  local path = g_luastar:find(aWidthStart, aWidthStop, aHeightStart, aHeightStop, start, goal, aPosIsOpen)
  return path
end

function AStarMove(aPosPath, aMaxRunCount)
  local bRun = false
  local path = aPosPath
  aMaxRunCount = aMaxRunCount or 10
  if path and #path < 100 then
    for i = 1, #path do
      local tmp = path[i]
      if GetDist(tmp.x, tmp.y) >= 1 then
        bRun = true
        PushDebugMessage("安全移动到：" .. tmp.x .. " " .. tmp.y)
        RunTo(tmp.x, tmp.y, 0, 200)
      end
      if aMaxRunCount and i >= aMaxRunCount then
        break
      end
    end
  end
  return bRun
end

function CheckCanXue(hpcmp)
  if 4 == g_self.menpai then
    hpcmp = hpcmp or 15
    Dismount()
    local oldcmp = CDG.hp.cmp
    CDG.hp.cmp = hpcmp
    for i = 1, 5 do
      local add_hp_name = CDG:checkHP_Player()
      if "" == add_hp_name then
        break
      end
    end
    CDG.hp.cmp = oldcmp
  end
end

function GetDiePlayer(aPlayer, aCheckJZDJ)
  local tRelive = aPlayer or Enum2XByClass("玩家")
  tRelive = ObjFilterByHP(tRelive, 0, 2)
  if aCheckJZDJ then
    for i = #tRelive, 1, -1 do
      local tmp = tRelive[i]
      if Target:FindBuff(tmp, "疲劳：无法再受到金针渡劫的复活效果") then
        table.remove(tRelive, i)
      end
    end
  end
  local tDieEM = {}
  for i = 1, #tRelive do
    if 5 == tRelive[i].menpai then
      table.insert(tDieEM, tRelive[i])
    end
  end
  local tDieOther = TableDeleteTable(tRelive, tDieEM, "name")
  return tDieEM, tDieOther, tRelive
end

function ReliveOnAction(aPlayer, aNotCheckHP)
  local nTick = GetTickCount()
  while true do
    if GetDist(aPlayer.x, aPlayer.y) < 12 then
      local tmp = FindObjByTID(aPlayer.id)
      if not tmp or tmp.hp > 0 then
        PushDebugMessage("起死回生:未发现目标 " .. aPlayer.name)
        return
      end
    end
    if 9 == Player:GetState() then
      return
    end
    if not RunTo(aPlayer.x, aPlayer.y, 3, 600) or GetTickCount() - nTick > 12000 then
      break
    end
    DebugStr("起死回生:移动到 " .. math.floor(aPlayer.x) .. " " .. math.floor(aPlayer.y) .. " " .. aPlayer.name)
  end
  Dismount()
  Sleep(300)
  nTick = GetTickCount()
  local timeout = 6000
  while timeout > GetTickCount() - nTick do
    Skill:UseSkillByName("起死回生", aPlayer.id, nil, nil, 1200)
    if 9 == Player:GetState() then
      return
    end
    PlayerStateTimeOut(5, 50)
    if GetDist(aPlayer.x, aPlayer.y) > 3 then
      PushDebugMessage("复活 %s 超出范围！", aPlayer.name)
      break
    end
    if Player:GetMP() < 250 then
      if not aNotCheckHP then
        timeout = 15000
        PushDebugMessage("复活 %s 时真气不足", aPlayer.name)
        FubenAttack(-1)
        CDG:checkMP()
        FubenAttack(-1)
      else
        break
      end
    end
    Sleep(200)
    local tmp = FindObjByTID(aPlayer.id)
    if not tmp or tmp.hp > 0 then
      PushDebugMessage("起死回生:复活时未发现目标 " .. aPlayer.name)
      return
    end
    DebugStr("正在复活玩家" .. aPlayer.name)
  end
  PlayerStateTimeOut(5, 50)
  PushDebugMessage("复活 %s 完成！", aPlayer.name)
  if not aNotCheckHP then
    FubenAttack(-1)
  end
end

function RelivePlayerJZDJ(aCheckDist)
  if 4 ~= g_self.menpai then
    return 0
  end
  if not Skill:CanUseByCdIdx(72) then
    return 0
  end
  if 9 == Player:GetState() then
    return 0
  end
  if IsMount() then
    return 0
  end
  local tDieEM, tDieOther, tDieAll = GetDiePlayer(nil, true)
  local tar
  if #tDieOther > 0 then
    if aCheckDist then
      BubbleByDst(tDieOther)
    end
    tar = tDieOther[1]
  end
  if #tDieEM > 0 then
    if aCheckDist then
      BubbleByDst(tDieEM)
    end
    tar = tDieEM[1]
  end
  if tar and (not aCheckDist or aCheckDist >= tar.dst) then
    PushColorMsg("峨嵋：金针渡劫" .. tar.name)
    Skill:UseSkillByName("金针渡劫", tar.id, nil, nil, 600)
    return 1
  end
  return 0
end

function CheckUseJZDJ(aDebugMsg, aMsgMinTimeDiff, aMsgMaxTimeDiff)
  if 4 == g_self.menpai then
    local nMsgTime, szMsgText, nMsgTick = IsInDebugMsg(aDebugMsg)
    if nMsgTime then
      local timeDiff = os.time() - nMsgTime
      if aMsgMinTimeDiff <= timeDiff and aMsgMaxTimeDiff > timeDiff then
        local emQueue = {
          {min = 0, max = 3},
          {min = 3, max = 6},
          {min = 6, max = 9},
          {min = 9, max = 30}
        }
        local tEM = Raid:GetLifeMenPai("峨嵋")
        for i = 1, #tEM do
          tEM[i].emIndex = i
        end
        local myQueue = emQueue[4]
        for i = 1, #tEM do
          if tEM[i].name == g_self.name and emQueue[tEM[i].emIndex] then
            myQueue = emQueue[tEM[i].emIndex]
          end
        end
        local helpTime = timeDiff - aMsgMinTimeDiff
        if helpTime >= myQueue.min and helpTime < myQueue.max then
          RelivePlayerJZDJ()
        end
      end
    end
  end
end

function RelivePlayer(nType, x1, y1, x2, y2, aSaveAll, aNotCheckHP)
  nType = nType or 1
  Player:IsJinGong()
  if 4 ~= g_self.menpai then
    return 0
  end
  if 9 == Player:GetState() then
    return 0
  end
  local nDieCount = 0
  if IsMount() == false and not aNotCheckHP then
    FubenAttack(-1, nil, nil, true, false)
  end
  
  local function _SaveFun(atPlayer, aSaveAll, _aNotCheckHP)
    local bSave = false
    while #atPlayer > 0 do
      GetAllPosDist(atPlayer)
      BubbleByDst(atPlayer, 1)
      if 9 == Player:GetState() then
        break
      end
      PushDebugMessage("复活 ： " .. atPlayer[1].name)
      ReliveOnAction(atPlayer[1], _aNotCheckHP)
      table.remove(atPlayer, 1)
      bSave = true
      if false == aSaveAll then
        break
      end
      Sleep(500)
    end
    return bSave
  end
  
  if 1 == nType then
    local tDieEM, tDieOther = GetDiePlayer()
    nDieCount = #tDieEM + #tDieOther
    local bSave = _SaveFun(tDieEM, aSaveAll)
    if false == bSave or aSaveAll then
      local _, tDieOther = GetDiePlayer()
      _SaveFun(tDieOther, aSaveAll, aNotCheckHP)
    end
  elseif 2 == nType then
    local tRelive = {}
    local tAllMember = Team:GetAllMemberInfo()
    local _, _, tAllDie = GetDiePlayer(tAllMember)
    for i = 1, #tAllDie do
      local tmp = tAllDie[i]
      if x1 > 0 and y1 > 0 and x2 > 0 and y2 > 0 then
        if x1 > tmp.x or x2 < tmp.x then
          PushDebugMessage(fmt("%s：死亡位置超出范围", tmp.name))
        elseif y1 > tmp.y or y2 < tmp.y then
          PushDebugMessage(fmt("%s：死亡位置超出范围2", tmp.name))
        else
          table.insert(tRelive, tmp)
        end
      else
        table.insert(tRelive, tmp)
      end
    end
    nDieCount = #tRelive
    local tDieEM, tDieOther, _ = GetDiePlayer(tRelive)
    if nDieCount > 0 then
      _SaveFun(tDieEM, aSaveAll, aNotCheckHP)
      _SaveFun(tDieOther, aSaveAll, aNotCheckHP)
    end
  end
  return nDieCount
end

function IsHuodongComplete(aHuoDong, listnum, aMust)
  if GetTickCount() - m_hd_RefreshTime > 60000 or aMust then
    m_hd_RefreshTime = GetTickCount()
    GetLuaValue("setmetatable(_G, {__index=PlayerQuicklyEnter_Env});PlayerQuicklyEnter_ActivityShedule();")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index=PlayerQuicklyEnter_Env});PlayerQuicklyEnter_ActivityShedule();")
    Sleep(1000)
  end
  local strCode = fmt([[
           
            local campaignlistnum = %d
            local nPageCampaignCount = GetNewCampaignCount(campaignlistnum)
            for i = 0, nPageCampaignCount - 1 do
                local szName = EnumNewCampaign(campaignlistnum, i, "name")
                if string.find(szName,"%s",nil,true) then 
                    local nMyCount = EnumNewCampaign(campaignlistnum, i, "MyCampaingCount");
                    local nCampaignCount = EnumNewCampaign(campaignlistnum, i, "PlayNum")
                    local nTimeType, nRemainDay = EnumNewCampaign(campaignlistnum, i, "IsToday");
                    return nMyCount,nCampaignCount,nTimeType,1
                end
            end
            return -1,-1,-1,0
        ]], listnum, aHuoDong)
  local nMyCount, nCampaignCount, nTimeType, nHave = GetLuaValue(strCode, "nnnn")
  local h = tonumber(os.date("%H"))
  local m = tonumber(os.date("%M"))
  if nMyCount == nCampaignCount and nCampaignCount > 0 and 2 ~= nTimeType then
    return true, nMyCount, nCampaignCount, nHave
  end
  return false, nMyCount, nCampaignCount, nHave
end

function SDQY_HuoDong()
  local nTick = GetTickCount()
  Sleep(2000)
  local bFindObj = false
  while true do
    PickUpLua()
    local tObj = Enum2XByName("圣诞老人 圣诞树 节日小雪人 糖果盒", {
      1,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj > 0 then
      local tmp = tObj[1]
      RunTo(tmp.x, tmp.y, 0, 500)
      TalkNpc(tmp.name, 600)
      if QuestFrameOptionClicked_Item("#{SDQY_141031_04}", 1, 600) == false and false == QuestFrameOptionClicked_Item("#{SDQY_141031_15}", 1, 600) and false == QuestFrameOptionClicked_Item("#{SDQY_141031_22}", 1, 600) and false == QuestFrameOptionClicked_Item("#{SDQY_141031_05}", 1, 600) then
        local strAll, nNum = GetNPCEventListAllItem()
        if string.find(strAll, "#{SDQY_141031_", nil, true) and not string.find(strAll, "#{SDQY_141031_04}", nil, true) and not string.find(strAll, "#{SDQY_141031_15}", nil, true) and not string.find(strAll, "#{SDQY_141031_22}", nil, true) and not string.find(strAll, "#{SDQY_141031_05}", nil, true) then
          break
        end
      end
      if GetTickCount() - nTick > 30000 then
        break
      end
    else
      tObj = Enum2XByName("辽国密探", {
        0,
        1,
        0,
        0
      }, nil, nil, 3)
      if #tObj > 0 then
        bFindObj = true
        local tmp = tObj[1]
        RunTo(tmp.x, tmp.y, 5, 1000)
        if tmp.hp > 0 then
          FubenAttack(tmp.id)
        else
          FubenAttack(-1)
          PickUpLua()
          break
        end
        PickUpLua()
      else
        break
      end
    end
    Sleep(100)
    DebugStr("奇遇")
  end
  if bFindObj then
    PickUpLua_Boss(15, 15)
  end
end

function YinShenAsTarget(tBoss, bIsXiaoHao, bMustCheck)
  local bNeedYinShen = false
  local bSuccess = false
  if bIsXiaoHao or bMustCheck then
    local selfTID = Player:GetTID()
    if tBoss.target == selfTID then
      bSuccess = Skill:UseName("初级隐遁", 300)
      bNeedYinShen = true
    end
  end
  return bNeedYinShen, bSuccess
end

function XiShanXingLv(aTid, aCheckFangDa)
  if nil == aCheckFangDa then
    aCheckFangDa = true
  end
  if CDG.attack and 8 == g_self.menpai then
    local tmp = FindObjByTID(aTid)
    if tmp then
      Skill:UseSkillByName("溪山行旅", tmp.id, nil, nil, 300)
    end
  end
end

function ZhiDianJiangShanObj(tTar, aCheckXiaoYao)
  if nil == aCheckXiaoYao then
    aCheckXiaoYao = true
  end
  if CDG.attack and 6 == g_self.menpai and (false == aCheckXiaoYao or false == Team:IsHaveMenpai("逍遥")) then
    local bfind = Target:FindBuff(tTar, "所受伤害放大")
    if false == bfind and Player:GetMPP() > 10 then
      Skill:UseSkillByName("指点江山", tTar.id, nil, nil, 300)
    end
  end
end

function ZhiDianJiangShan(aTid, aCheckXiaoYao)
  if CDG.attack and 6 == g_self.menpai then
    local tmp = FindObjByTID(aTid)
    if tmp then
      ZhiDianJiangShanObj(tmp, aCheckXiaoYao)
    end
  end
end

function HuiShouLiRenOu()
  Player:GetName()
  local tObj = Enum2XByClass("阵法")
  local tLRE = ObjFilterByName(tObj, g_self.name .. "的离人偶", 0)
  if #tLRE > 0 then
    Skill:UseName("勒马归鞍", 400)
  end
end

function XiaoChangHuiXue(aHpCmp, aUseMount)
  PushDebugMessage("校场满血")
  aHpCmp = aHpCmp or 80
  local mpCmp = 50
  local npc = {
    x = 185,
    y = 336,
    sceneID = LUOYANG_ID,
    name = "龙霸天"
  }
  if IsKVKSceneName() then
    local nSceneID = BJ_GetSceneID()
    if -1 ~= nSceneID then
      npc = {
        x = 358,
        y = 283,
        sceneID = nSceneID,
        name = "尉迟敬武"
      }
    else
      npc = {
        x = 123,
        y = 172,
        sceneID = 850,
        name = "尉迟良飞"
      }
    end
  end
  if aHpCmp <= Player:GetHPP() and mpCmp <= Player:GetMPP() then
    PushDebugMessage("校场满血:血量已达到%s%%,无需回血", aHpCmp)
    return
  end
  local money = Player:GetMoney(1)
  local money_jz = Player:GetMoney(2)
  if money + money_jz < 20000 then
    PushColorMsg("校场满血:金币交子不足2J")
    return
  end
  local bUseMoney = true
  local bUseItem = false
  if false == aUseMount then
    bUseMoney = false
  end
  
  local function _cb(...)
    local nIndex, nIdScript = GetPlayerMission_ID(4021)
    if -1 ~= nIndex and GetSceneID() ~= LUOYANG_ID then
      PushColorMsg("漕运时不在洛阳无法校场满血")
      return false
    end
    return MoveCallback_NoFuben(...)
  end
  
  MoveTo(npc.x, npc.y, npc.sceneID, nil, aUseMount, nil, _cb, bUseMoney, bUseItem)
  local oldTime = os.time()
  while true do
    local nHPPercent = Player:GetHPP()
    local nMPP = Player:GetMPP()
    if aHpCmp > nHPPercent or mpCmp > nMPP then
      if aHpCmp > 100 then
        aHpCmp = 100
      end
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, aUseMount, nil, _cb, bUseMoney, bUseItem)
      Sleep(500)
      QuestFrameOptionClicked_Item("满状态治疗", 1, 700)
      QuestFrameOptionClicked_Item("是", 1, 700)
      TalkNpc(npc.name)
      Sleep(500)
      QuestFrameOptionClicked_Item("给珍兽恢复气血", 1, 500)
      QuestFrameOptionClicked_Item("好的", 1, 500)
    else
      PushDebugMessage("校场满血:已完成.血量已达到:%s%%", aHpCmp)
      break
    end
    if IsInFubenScene() then
      PushColorMsg("校场满血:当前地图无法回血")
      break
    end
    if os.time() - oldTime > 15 then
      PushColorMsg("校场满血:超时!")
      break
    end
    DebugStr("校场满血..")
    Sleep(1000)
  end
end

function MPCheck100(bMust, aCmp)
  local cmp = CDG.mp.cmp
  if bMust then
    CDG.mp.cmp = aCmp or 80
  end
  CDG:checkMP()
  CDG:checkMP()
  Sleep(5000)
  CDG:checkMP()
  CDG.mp.cmp = cmp
end

function ChangeFightPet(bChange, info)
  if false == bChange then
    CDG.pet1.GUID = CDG.pet1.OldGUID
    CDG.pet1.OldGUID = CDG.pet1.orgGUID
    return
  end
  CDG.pet1.GUID = info.GUID
  CDG.pet1.OldGUID = info.GUID
end

function PetSetFightShenYou()
  local tPet = {idx = -1, GUID = -1}
  local tShenYou = {}
  local szRet = GetLuaValue("return meGetPetBySkill('神佑',0)", "s")
  if "" ~= szRet then
    local szArr = SplitString(szRet, " ")
    for i = 1, #szArr do
      local szArr2 = SplitString(szArr[i], "&")
      if #szArr2 >= 4 then
        table.insert(tShenYou, {
          idx = tonumber(szArr2[1]),
          GUID = tonumber(szArr2[2]),
          hp = tonumber(szArr2[3])
        })
      end
    end
  end
  if #tShenYou > 0 then
    BubbleByHP(tShenYou, 2)
    tPet = {
      idx = tShenYou[1].idx,
      GUID = tShenYou[1].GUID
    }
    ChangeFightPet(true, tPet)
  end
  return tPet
end

function PetSetHPMax()
  local tPet = {idx = -1, GUID = -1}
  local tShenYou = {}
  local szRet = GetLuaValue("return meGetPetHPMax()", "s")
  if "" ~= szRet then
    local szArr = SplitString(szRet, " ")
    for i = 1, #szArr do
      local szArr2 = SplitString(szArr[i], "&")
      if 4 == #szArr2 then
        table.insert(tShenYou, {
          idx = tonumber(szArr2[1]),
          GUID = tonumber(szArr2[2]),
          hp = tonumber(szArr2[3]),
          fight = szArr2[4]
        })
      end
    end
  end
  if #tShenYou > 0 then
    BubbleByHP(tShenYou, 2)
    tPet = {
      idx = tShenYou[1].idx,
      GUID = tShenYou[1].GUID
    }
    ChangeFightPet(true, tPet)
  end
  return tPet
end

function WuDiSkill()
  local bUseShenYou = false
  if -1 ~= Player:GetBuff("神佑") or -1 ~= Player:GetBuff("无敌") or 4 == g_self.menpai and Skill:UseName("呆若木鸡", 300) then
  else
    bUseShenYou = Skill:UsePetSkill("高级神佑")
    Skill:UsePetSkill("高级肉墙")
    Skill:UsePetSkill("高级共生")
  end
  return bUseShenYou
end

function StopRun(aRunPos)
  if 2 == Player:GetState() then
    local pos = Player:GetPos()
    aRunPos = aRunPos or pos
    RunTo(pos.x, pos.y + 1, 0, 200)
    RunTo(aRunPos.x, aRunPos.y, 0, 200)
  end
end

function StopAttack(aTarget, aRunPos)
  if aTarget then
    Pet:CheckRelax(aTarget.id, 2)
  end
  if 7 == Player:GetState() then
    local pos = Player:GetPos()
    aRunPos = aRunPos or pos
    Skill:UseSkillByID(Skill.baseID, Player:GetTID(), nil, nil, 150)
    RunTo(pos.x, pos.y + 1, 0, 200)
    RunTo(aRunPos.x, aRunPos.y, 0, 200)
  end
end

function EnumPlayerState(aBuffName, aType)
  local bHave = false
  local szName = " "
  local tObj = Enum2XByClass(" 玩家 ", {0, -1})
  for i = 1, #tObj do
    if 1 == aType then
    elseif 2 == aType then
      if Target:FindBuff(tObj[i], aBuffName) == false then
        szName = szName .. tObj[i].name .. " "
      else
        bHave = true
      end
    end
  end
  return bHave, szName
end

function GivePlayerState(skillname, menpai, bmust)
  if nil == bmust then
    bmust = true
  end
  local tSkillBuf = {}
  tSkillBuf["百毒不侵"] = "百毒不侵：增加毒抗"
  tSkillBuf["冰肌玉骨"] = "冰肌玉骨：增加冰抗"
  tSkillBuf["墨守成规"] = "墨守成规：增加火抗"
  tSkillBuf["正气浩然"] = "正气浩然：增加玄抗"
  if g_self.menpai == menpai then
    local tObj = Enum2XByClass(" 玩家 ", {0, 15})
    for i = 1, #tObj do
      if bmust then
        Skill:UseSkillByName(skillname, tObj[i].id, -1, -1, 1650)
      elseif tSkillBuf[skillname] and Target:FindBuff(tObj[i], tSkillBuf[skillname]) == false then
        Skill:UseSkillByName(skillname, tObj[i].id, -1, -1, 1000)
      end
    end
  end
end

function CheckFubenJinRi()
  local bSelfComp = false
  local strText, nListCount = GetNPCEventListAllItem()
  if string.find(strText, "#{FBJR_091019_1}", nil, true) then
    DebugColorMsg("有队员已刷过！")
    local tMember = Team:GetAllMemberInfo()
    for i = #tMember, 1, -1 do
      local tmp = tMember[i]
      if string.find(strText, "#B队员  " .. tmp.name .. "#r    #{FBJR_091019_2}60  #{FBJR_091019_12}#r    #{FBJR_091019_11}", nil, true) then
        if tmp.name == g_self.name then
          Team:LeaveTeam()
          bSelfComp = true
          break
        else
          Team:KickTeamMember(tmp.teamIndex)
          break
        end
      end
    end
  end
  return bSelfComp
end

function GuiShi_BuyItem(aItemName, aBuyCount)
  PushColorMsg("鬼市:购买%s个%s", aBuyCount, aItemName)
  local strText = "            local buyName = \"%s\"\n            local buyCount = %d\n            local buyState = 0\n            local myMoney = GuiShiUI:LuaFnGetGuiShiTongBi()\n            local curyl = GuiShiUI:LuaFnGetGuiShiYinLiang()\n            setmetatable(_G, {__index = GuiShi_Shop_Env})\n            if this:IsVisible() then\n                local goodsNum = GuiShiUI:LuaFnGetNPCShopGoodsNum()\n                for i = 0, goodsNum - 1 do\n                    local result, name, isLimited, limitedNum, buyNum, needType1, needNum1, needStep1, needType2, needNum2, needStep2 = GuiShiUI:LuaFnGetNPCShopGoodsInfo(i)\n                    if result ~= 0 then\n                        local theAction = EnumAction(i, \"gs_npcshop_goodslist\")\n                        if theAction:GetID() ~= 0 then\n                            if name == buyName then\n                                if isLimited == 1 then     \n                                    meTestMsg(name .. \":已经购买\" .. buyNum .. \",还可购买\" .. limitedNum)                                                                 \n                                    local canBuyCount = limitedNum\n                                    if buyCount > canBuyCount then\n                                        buyCount = canBuyCount\n                                        if buyCount <= 0 then\n                                            buyState = 3\n                                            meTestMsg(name .. \":超出数量限制\", 1)\n                                        end\n                                    end\n                                end\n                                if buyCount > 0 then\n                                    local allNeed2 = 0\n                                    local allNeed3 = 0\n                                    local allNeed4 = 0\n                                    local allNeed5 = 0\n                                    if needType1 == 3 then\n                                        allNeed3 = needNum1 * buyCount\n                                    end\n                                    if needType2 == 2 then\n                                        allNeed2 = needNum2 * buyCount\n                                    end\n                               \n                                    if myMoney >= allNeed3 and curyl >= allNeed2 then\n                                        buyState = 2\n                                        local goodsId = GuiShiUI:LuaFnGetNPCShopGoodsId(i)\n                                        if goodsId ~= -1 then\n                                            buyState = 1\n                                            PushEvent(\"GUISHI_ONBUY\", tostring(i), tostring(goodsId), tostring(0), tostring(buyCount), tostring(0))\n                                        end\n                                    else\n                                        meTestMsg(name .. \":钱俩不够\", 1)\n                                        buyState = 4\n                                    end\n                                end\n                                break\n                            end\n                        end\n                    end\n                end\n            end\n            return buyState     \n        "
  local buyState = GetLuaValue(fmt(strText, aItemName, aBuyCount), "n")
  return buyState
end

function MakeDingWeiFu(aMakeLevel, aMakeColor, aBuyHuangZhi, aZuPrice)
  local make_table = {
    {
      {id = 510, color = "红"},
      {id = 511, color = "蓝"},
      {id = 512, color = "白"},
      {id = 513, color = "绿"},
      {id = 514, color = "黄"},
      {id = 515, color = "紫"}
    },
    {
      {id = 516, color = "红"},
      {id = 517, color = "蓝"},
      {id = 518, color = "白"},
      {id = 519, color = "绿"},
      {id = 520, color = "黄"},
      {id = 521, color = "紫"}
    },
    {
      {id = 522, color = "红"},
      {id = 523, color = "蓝"},
      {id = 524, color = "白"},
      {id = 525, color = "绿"},
      {id = 526, color = "黄"},
      {id = 527, color = "紫"}
    }
  }
  TempBank2Bag("黄纸", 0)
  Sleep(100)
  local canMakeLevel = GetLuaValue([[
        local sklLevel = Player:GetAbilityInfo(39, "level")
        if sklLevel == nil then
            sklLevel = 0
        end
        return sklLevel
    ]], "n")
  if 0 == canMakeLevel then
    PushColorMsg("制作定位符:您没有学习此技能")
    return false
  end
  aMakeLevel = aMakeLevel or canMakeLevel
  if canMakeLevel < aMakeLevel then
    PushColorMsg("制作定位符:您无法制作" .. aMakeLevel .. "级定位")
    aMakeLevel = canMakeLevel
  end
  if aMakeLevel < 1 then
    aMakeLevel = 1
  end
  if aMakeLevel > 3 then
    aMakeLevel = 3
  end
  if nil == aMakeColor then
    math.randomseed(GetTickCount())
    local idx = math.random(1, 6)
    aMakeColor = make_table[1][idx].color
  end
  local needCount = 10
  if 1 == aMakeLevel then
    needCount = 5
  elseif 2 == aMakeLevel then
    needCount = 8
  end
  local hzCount = Bag:GetItemCount("黄纸", nil, nil, Bag:EnumCailiaoItem())
  if needCount > hzCount and aBuyHuangZhi then
    Bank_GetMoney(aZuPrice, "洛阳")
    for i = 1, 3 do
      PushDebugMessage("购买黄纸:每250个价格不超过 %d 铜", aZuPrice)
      ShangHui_BuyItem("黄纸", 250, aZuPrice / 250, 1)
      Sleep(500)
      hzCount = Bag:GetItemCount("黄纸", nil, nil, Bag:EnumCailiaoItem())
      if hzCount >= 40 then
        break
      end
    end
  end
  local bMake = false
  if needCount <= hzCount then
    bMake = true
    local make = make_table[aMakeLevel]
    local makeid = make[1].id
    for i = 1, #make do
      if string.find(aMakeColor, make[i].color, nil, true) then
        makeid = make[i].id
        break
      end
    end
    Dismount()
    Sleep(800)
    GetLuaValue(fmt("ComposeItem_Begin(%d,1,-1)", makeid))
    Sleep(1000)
    PlayerStateTimeOut(8, 20)
  else
    PushColorMsg("制作定位符:背包和锦囊没有足够黄纸")
  end
  Bag_Move2TempBank("黄纸")
  return bMake
end

function UseMaAn()
  local tItem = Bag:EnumDaoJuItem()
  local cntMaAn = Bag:GetItemCount("马鞍", nil, nil, tItem)
  if cntMaAn > 0 and -1 == Player:GetBuff("马鞍：增加骑乘时的移动速度") then
    if not Player:IsFollow() then
      PushColorMsg("自动使用:马鞍")
      Bag:UseItemByName("马鞍", 300, tItem)
    else
      PushColorMsg("组队跟随:无法使用马鞍")
    end
  end
end

local function SD_OnClearBag1()
  EatBindItem()
  EatFubenItem(5)
  ClearBag()
end

local function SD_OnClearBag2()
  if not IsInFubenScene() and (IsInDebugMsg("#{FBSD_150126_33") or IsInDebugMsg("#{FBSD_150126_34")) then
    Bag_SellItem()
    MainBankSaveItem()
    DeleteDebugMsg("#{FBSD_150126_33")
    DeleteDebugMsg("#{FBSD_150126_34")
  end
end

local function SD_OnAction(FubenName, ActionID, index, aParam)
  local nTickOut = GetTickCount()
  DeleteDebugMsg("#{FBSD_150126_33")
  DeleteDebugMsg("#{FBSD_150126_34")
  DeleteDebugMsg("#{FBSD_150126_50}")
  DeleteDebugMsg("#{FBSD_150126_51}")
  DeleteDebugMsg("#{FBSD_150126_52}")
  DeleteDebugMsg("#{FBSD_150126_70}")
  DeleteDebugMsg("#{SDXG_20210624_16}")
  DeleteDebugMsg("#{SDXG_20210624_17}")
  DeleteDebugMsg("#{SDXG_20210624_29}")
  DeleteDebugMsg("#{SDXG_20210624_30}")
  DeleteDebugMsg("#{SDXG_20210624_31}")
  DeleteDebugMsg("#{SDXG_20210624_32}")
  DeleteDebugMsg("#{SDXG_20210624_33}")
  DeleteDebugMsg("#{SDXG_20210624_34}")
  DeleteDebugMsg("#{SDXG_20210624_35}")
  DeleteDebugMsg("#{SDXG_20210624_36}")
  DeleteDebugMsg("#{SDXG_20210624_37}")
  while IsWindowVisible("SweepPage") do
    SD_OnClearBag1()
    SD_OnClearBag2()
    local szTemp = "                setmetatable(_G, { __index = SweepPage_Env });\n                if SecKillItemListEmpty() == 1 then\n                    local szTitle = SweepPage_DragTitle:GetText()\n                    local SweepPage_BossName = { SweepPage_Boss1Name, SweepPage_Boss2Name, SweepPage_Boss3Name, SweepPage_Boss4Name, SweepPage_Boss5Name, SweepPage_Boss6Name }\n                    local SweepPage_BossDieIcon = { SweepPage_Boss1finish, SweepPage_Boss2finish, SweepPage_Boss3finish, SweepPage_Boss4finish, SweepPage_Boss5finish, SweepPage_Boss6finish }\n                    for i = 1, 6 do\n                        if SweepPage_BossName[i]:IsVisible() then\n                            if SweepPage_BossDieIcon[i]:IsVisible() == false then\n                                if i > 3 and string.find(szTitle, \"扫荡三神幻境\", nil, true) then\n                                    --SweepPage_OnBossButton(i);\n                                    return -2\n                                else\n                                    SweepPage_OnBossButton(i);\n                                    return i\n                                end                 \n                            end\n                        end\n                    end\n                    return -1\n                else\n                    return 0\n                end\n            "
    local nRet = GetLuaValue(szTemp, "n")
    if -2 == nRet then
      local boxIndex = 4
      IsWindowVisible("SweepPage", fmt("SweepPage_OnBossButton(%d)", boxIndex))
      Sleep(600)
    end
    Sleep(500)
    if IsInDebugMsg("#{SDXG_20210624_29}") or IsInDebugMsg("#{SDXG_20210624_30}") or IsInDebugMsg("#{SDXG_20210624_31}") or IsInDebugMsg("#{SDXG_20210624_32}") or IsInDebugMsg("#{SDXG_20210624_33}") then
      PushColorMsg("扫荡副本：成就不足无法扫荡" .. FubenName)
      break
    elseif IsInDebugMsg("#{SDXG_20210624_34}") or IsInDebugMsg("#{SDXG_20210624_35}") or IsInDebugMsg("#{SDXG_20210624_36}") or IsInDebugMsg("#{SDXG_20210624_37}") then
      PushColorMsg("扫荡副本：成就不足无法扫荡" .. FubenName)
      break
    end
    if IsWindowVisible("SanShen_BaoXiang") then
      local bDouble = false
      if aParam.sshj_usekey and Bag:GetItemCount("天星灵符") > 0 then
        bDouble = true
      end
      if bDouble then
        IsWindowVisible("SanShen_BaoXiang", "SanShen_BaoXiang_OpenLingfu()")
      else
        IsWindowVisible("SanShen_BaoXiang", "SanShen_BaoXiang_OpenFree()")
      end
      Sleep(200)
      GetLuaValue("setmetatable(_G, { __index = SweepPage_Env });SweepPage_OnOkClicked()")
      break
    end
    if nRet < 0 then
      break
    end
    Sleep(500)
    GetLuaValue("setmetatable(_G, { __index = SweepPage_Env });SweepPage_OnOkClicked()")
    Sleep(1000)
    DebugStr(FubenName .. ":扫荡中")
    if IsInDebugMsg("#{FBSD_150126_50}") or IsInDebugMsg("#{FBSD_150126_51}") or IsInDebugMsg("#{FBSD_150126_52}") or IsInDebugMsg("#{SDXG_20210624_16}") or IsInDebugMsg("#{SDXG_20210624_17}") or IsInDebugMsg("#{FBSD_150126_70}") then
      break
    end
    if GetTickCount() - nTickOut > 60000 then
      PushDebugMessage(FubenName .. ":扫荡超时")
      break
    end
  end
  CloseWindow("SweepPage")
  CloseWindow("Shop")
end

local function SD_OnOpenPage(FubenName, ActionID, aFubenID, aParam)
  CloseWindow("SweepPage")
  Sleep(100)
  GetLuaValue(fmt("setmetatable(_G, {__index=SweepAll_Env});OpenSecKillPage(%d,0)", aFubenID))
  for j = 1, 5 do
    if IsWindowVisible("SweepPage") then
      SD_OnAction(FubenName, ActionID, aFubenID, aParam)
      if not IsWindowVisible("SweepAll") then
        GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_OpenSecKillBox()")
        Sleep(600)
      end
      break
    else
      GetLuaValue(fmt("setmetatable(_G, {__index=SweepAll_Env});OpenSecKillPage(%d,0)", aFubenID))
      Sleep(800)
    end
  end
end

local function SD_EnumFBByIdx(aIdx)
  local szTemp = fmt([[
            setmetatable(_G, { __index = SweepAll_Env });
            local idx = %d
		    local Id,IconName,FubenName,needLevel,LowSecKillNum, HightSecKillNum,SecKillNeedNumType,SecKillNeedNum,CanDoubleExp, numYuanbao, ActionID = EnumSecKillTable(idx)
            local Number = GetCampaignTotalNum(ActionID)
            local Micount = Number - GetCampaignCountNum(ActionID)
            local FubenID = Lua_SecKillGetFuBenIndexID_New(idx)
            if FubenName == nil or FubenName == "" then 
                FubenName = "nil" 
            end
            return FubenName,LowSecKillNum, HightSecKillNum,SecKillNeedNumType,SecKillNeedNum, ActionID, Micount,FubenID
        ]], aIdx)
  local FubenName, LowSecKillNum, HightSecKillNum, SecKillNeedNumType, SecKillNeedNum, ActionID, Micount, FubenID = GetLuaValue(szTemp, "snnnnnnn")
  return FubenName, LowSecKillNum, HightSecKillNum, SecKillNeedNumType, SecKillNeedNum, ActionID, Micount, FubenID
end

local function SD_GetSecKillData()
  local isInSecKill, FubenID, nIndex = GetLuaValue([[
        local isInSecKill,FubenID,BossIndex,DoubleExp = GetSecKillData();
        local nIndex = Lua_SecKillGetIndexFromFuBenIndexID(FubenID)
        return isInSecKill,FubenID,nIndex
        ]], "nnn")
  return isInSecKill, FubenID, nIndex
end

local function SDFB_IsSaoDang(fubenName, aParam)
  local bSaoDang = false
  if aParam.yzw and "讨伐燕子坞" == fubenName then
    bSaoDang = true
  elseif aParam.sjz and "苏州四绝庄" == fubenName then
    bSaoDang = true
  elseif aParam.sss and "少室山" == fubenName then
    bSaoDang = true
  elseif aParam.bsqz and "兵圣奇阵" == fubenName then
    bSaoDang = true
  elseif aParam.fmwl and "凤鸣王陵" == fubenName then
    bSaoDang = true
  elseif aParam.sshj and "三神幻境" == fubenName then
    bSaoDang = true
  elseif aParam.pmf and "挑战缥缈峰" == fubenName then
    bSaoDang = true
  elseif aParam.lhfd_easy and "琅嬛福地（普通）" == fubenName then
    bSaoDang = true
  elseif aParam.lhfd and "琅嬛福地（困难）" == fubenName then
    bSaoDang = true
  elseif aParam.lsh and "除匪首力破三关" == fubenName then
    bSaoDang = true
  end
  return bSaoDang
end

function SDFB_OnStart(aParam)
  aParam.sshj_usekey = true
  DeleteDebugMsg("#{SDXG_20210624_29}")
  DeleteDebugMsg("#{SDXG_20210624_30}")
  DeleteDebugMsg("#{SDXG_20210624_31}")
  DeleteDebugMsg("#{SDXG_20210624_32}")
  DeleteDebugMsg("#{SDXG_20210624_33}")
  DeleteDebugMsg("#{SDXG_20210624_34}")
  DeleteDebugMsg("#{SDXG_20210624_35}")
  DeleteDebugMsg("#{SDXG_20210624_36}")
  DeleteDebugMsg("#{SDXG_20210624_37}")
  local nTickOut = GetTickCount()
  if not IsWindowVisible("SweepAll") then
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_OpenSecKillBox()")
    Sleep(1000)
  end
  while true do
    if IsWindowVisible("SweepAll") then
      local bHave_SaoDang = false
      local isInSecKill, nFubenID, nFubenIndex = SD_GetSecKillData()
      if 1 ~= isInSecKill then
        local SecKillFubenCount = GetLuaValue("return GetSecKillFuBenCount()", "n")
        for i = 0, SecKillFubenCount - 1 do
          local FubenName, LowSecKillNum, HightSecKillNum, SecKillNeedNumType, SecKillNeedNum, ActionID, Micount, FubenId = SD_EnumFBByIdx(i)
          isInSecKill, nFubenID, nFubenIndex = SD_GetSecKillData()
          if 1 == isInSecKill and nFubenID ~= FubenId then
            bHave_SaoDang = true
            PushDebugMessage("有未扫荡完的副本 " .. nFubenID .. " " .. FubenId)
            break
          end
          local bIsSaoDang = SDFB_IsSaoDang(FubenName, aParam)
          if bIsSaoDang and Micount > 0 then
            if 2 == SecKillNeedNumType then
              if SecKillNeedNum <= HightSecKillNum then
                bHave_SaoDang = true
              end
            elseif SecKillNeedNum <= LowSecKillNum then
              bHave_SaoDang = true
            end
            if bHave_SaoDang then
              SD_OnOpenPage(FubenName, ActionID, FubenId, aParam)
              break
            elseif 2 == SecKillNeedNumType then
              PushDebugMessage("扫荡副本：%s 剩余点数%d,不够扫%d次", FubenName, HightSecKillNum, Micount)
            else
              PushDebugMessage("扫荡副本：%s 剩余点数%d,不够扫%d次", FubenName, LowSecKillNum, Micount)
            end
          elseif false == bIsSaoDang then
          end
        end
        if IsInDebugMsg("#{SDXG_20210624_29}") then
          aParam.sjz = false
        elseif IsInDebugMsg("#{SDXG_20210624_30}") then
          aParam.pmf = false
        elseif IsInDebugMsg("#{SDXG_20210624_31}") then
          aParam.yzw = false
        elseif IsInDebugMsg("#{SDXG_20210624_32}") then
          aParam.sss = false
        elseif IsInDebugMsg("#{SDXG_20210624_33}") then
          aParam.lhfd_easy = false
        elseif IsInDebugMsg("#{SDXG_20210624_34}") then
          aParam.fmwl = false
        elseif IsInDebugMsg("#{SDXG_20210624_35}") then
          aParam.sshj = false
        elseif IsInDebugMsg("#{SDXG_20210624_36}") then
          aParam.bsqz = false
        elseif IsInDebugMsg("#{SDXG_20210624_37}") then
          aParam.lsh = false
        end
      else
        bHave_SaoDang = true
        PushDebugMessage("扫荡副本：有未扫荡完成" .. nFubenID)
        local FubenName, LowSecKillNum, HightSecKillNum, SecKillNeedNumType, SecKillNeedNum, ActionID, Micount, FubenIdx = SD_EnumFBByIdx(nFubenIndex)
        SD_OnOpenPage(FubenName, ActionID, nFubenID, aParam)
      end
      if not bHave_SaoDang then
        LogMsg("扫荡副本：无可扫荡副本")
        break
      end
    else
      for i = 1, 2 do
        SD_OnClearBag1()
      end
      GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_OpenSecKillBox()")
    end
    if GetTickCount() - nTickOut > 1200000 then
      LogMsg("扫荡副本：超时")
      break
    end
    Sleep(1000)
    DebugStr("扫荡副本")
  end
  for i = 1, 2 do
    SD_OnClearBag1()
    Sleep(100)
  end
  Bag_SellItem()
  MainBankSaveItem()
  Bag_SellItem()
  MainBankSaveItem()
end

function SetDingWeiZhu(aNum)
  local bSet = false
  aNum = aNum or 1
  local tItem = Bag:SearchItemName("土灵珠 地灵珠")
  for i = 1, #tItem do
    bSet = true
    local tmp = tItem[i]
    GetLuaValue(fmt([[
                    Clear_XSCRIPT();
                        Set_XSCRIPT_Function_Name("SetPosition");
                        Set_XSCRIPT_ScriptID(330001);
                        Set_XSCRIPT_Parameter(0, %d);
                        Set_XSCRIPT_ParamCount(1);
                    Send_XSCRIPT();	
                ]], tmp.index))
    if i >= aNum then
      break
    end
  end
  if 0 == #tItem then
    tItem = Bag:FindItemInfo("彻地符箓")
    if #tItem > 0 then
      bSet = true
      local tmp = tItem[1]
      GetLuaValue(fmt([[
                        Clear_XSCRIPT()
                            Set_XSCRIPT_Function_Name("SetPosition")
                            Set_XSCRIPT_ScriptID(330059)
                            Set_XSCRIPT_Parameter(0, %d)
                            Set_XSCRIPT_Parameter(1, 9)
                            Set_XSCRIPT_ParamCount(2)
                        Send_XSCRIPT()
                    ]], tmp.index))
    end
  end
  return bSet
end

function InitServerTime()
end

function GetServerTime()
  local nTime = GetLuaValue("return DataPool:GetCurrentServerTime()", "n")
  return nTime
end

function GetServerTime_init()
  return GetServerTime()
end

function GetServerName()
  local strText = [[
        local svrName = ""
        local zoneID = DataPool:GetSelfZoneWorldID()
        svrName = DataPool:GetServerName(zoneID)
        return svrName        
    ]]
  return GetLuaValue(strText, "s")
end

function GetGameVersion()
  local version = ""
  local strPath = GetGamePath()
  strPath = strPath .. "(version)"
  local file = io.open(strPath, "r")
  if file then
    file:seek("set")
    local strpos = file:read()
    if type(strpos) == "string" and "" ~= strpos then
      local strArr = SplitString(strpos, "|", true)
      if #strArr > 1 and #strArr[1] > 5 and string.find(strArr[1], "3.", nil, true) then
        version = strArr[1]
      end
    end
    io.close(file)
  end
  return version
end

function GetTimeStr(aTimeStamp)
  local timeStamp = aTimeStamp or os.time()
  return os.date("%Y年%m月%d日%H时%M分%S秒", timeStamp)
end

function GetTimeStampFromStr(aTimeStr)
  local _, _, y, m, d, h, mn, s = string.find(aTimeStr, "(%d+)年(%d+)月(%d+)日(%d+)时(%d+)分(%d+)秒")
  y = tonumber(y)
  m = tonumber(m)
  d = tonumber(d)
  h = tonumber(h)
  mn = tonumber(mn)
  s = tonumber(s)
  if y and m and d and h and mn and s then
    local tab = {
      year = y,
      month = m,
      day = d,
      hour = h,
      min = mn,
      sec = s
    }
    return os.time(tab)
  end
  return nil
end

function WaitForTime(aHour, aMinute)
  PushColorMsg("当前系统时间 " .. os.date("%X") .. ",等待时间到 %d:%d", aHour, aMinute)
  while true do
    local h2 = tonumber(os.date("%H"))
    local m2 = tonumber(os.date("%M"))
    if aHour == h2 and aMinute == m2 then
      break
    end
    Sleep(10000)
    DebugStr("当前系统时间 " .. os.date("%X") .. ",等待时间到 %d:%d", 1, aHour, aMinute)
  end
  PushColorMsg("当前系统时间 " .. os.date("%X") .. ",已到了等待的时间 %d:%d", aHour, aMinute)
end

function JL_GetLineInfoBySceneID(aSceneID)
  local alltab = JL_GetSceneLineTab()
  local tab
  for i = 1, #alltab do
    if alltab[i].sceneID == aSceneID then
      tab = alltab[i]
      break
    end
  end
  return tab
end

function JL_GetLineSceneID(aDefaultType)
  local alltab = JL_GetSceneLineTab()
  local tab
  if nil == tab then
    local curScene = GetSceneID()
    for i = 1, #alltab do
      if alltab[i].sceneID == curScene then
        tab = alltab[i]
        break
      end
    end
  end
  if nil == tab then
    if 1 == aDefaultType then
      tab = tab[1]
    else
      math.randomseed(GetTickCount())
      local idx = math.random(1, #alltab)
      tab = alltab[idx]
    end
  end
  return tab
end

function JL_GetRandomSceneID()
  local alltab = JL_GetSceneLineTab()
  math.randomseed(GetTickCount())
  local idx = math.random(1, #alltab)
  return alltab[idx].sceneID
end

function JL_GetRunSceneID()
  local tempID = JL_GetSceneID()
  if -1 == tempID then
    tempID = JL_GetRandomSceneID()
  end
  return tempID
end

function JL_GetLine()
  local tab = JL_GetLineInfoBySceneID(GetSceneID())
  if tab then
    return tab.line
  end
  return -1
end

function JL_GetSceneIDByLine(aLine)
  local alltab = JL_GetSceneLineTab()
  for i = 1, #alltab do
    if alltab[i].line == aLine then
      return alltab[i].sceneID
    end
  end
  return -1
end

function JL_GetLeaderLineSceneID()
  local leader, isleader = Team:GetLeaderInfo()
  if isleader then
    return JL_GetLineSceneID(2)
  end
  if leader then
    return JL_GetLineInfoBySceneID(leader.sceneID)
  end
  return nil
end

function JL_ChangeLine(aLine, aLeaderOver, aCB)
  local bChange = false
  local _cb = aCB or MoveCallback_InScene
  if aLine > 0 then
    local npc1 = {
      x = 377,
      y = 530,
      name = "宋唐",
      scriptID = 702037
    }
    local npc2 = {
      x = 311,
      y = 277,
      name = "宋元",
      scriptID = 702042
    }
    local npc = npc1
    if GetDist(npc1.x, npc1.y) > GetDist(npc2.x, npc2.y) then
      npc = npc2
    end
    local tick_change_pos = -1
    while true do
      local nSceneID = JL_GetSceneID()
      if -1 == nSceneID or aLeaderOver and Player:IsLeader() then
        break
      end
      local nLine = JL_GetLine()
      if -1 ~= nLine and nLine ~= aLine then
        PushColorMsg("更换线路" .. aLine)
        MoveTo(npc.x, npc.y, nSceneID, nil, nil, nil, _cb)
        local tObj = Enum2XByName(npc.name, {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          MoveToNPC(tmp.name, tmp.x, tmp.y, nSceneID, nil, nil, nil, _cb)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{TWFX_200814_04}", 1, 700)
          QuestFrameOptionClicked_ScriptID_Extra(npc.scriptID, 50 + aLine, 700)
          bChange = true
        else
          DebugStr("金陵:切换线路时没有发现传送的NPC,10秒切换NPC", 2)
          if -1 == tick_change_pos then
            tick_change_pos = GetTickCount()
          end
          if GetTickCount() - tick_change_pos > 10000 then
            if npc.x == npc1.x then
              npc = npc2
            else
              npc = npc1
            end
            tick_change_pos = -1
          end
        end
        Sleep(100)
        DebugStr("金陵: 切换线路" .. aLine)
      else
        if -1 ~= nLine then
          break
        end
        PushColorMsg("未获取到当前金陵线路")
      end
      if aCB and false == aCB(nil, nil, nil) then
        break
      end
      Sleep(1000)
    end
  end
  return bChange
end

function JL_ChangeLeaderLine()
  local nLine = JL_GetLine()
  if -1 ~= nLine then
    local info = JL_GetLeaderLineSceneID()
    if not Player:IsLeader() and info and nLine ~= info.line then
      local function _cb(_aX, _aY, _aScene)
        local _info = JL_GetLeaderLineSceneID()
        
        local _nLine = JL_GetLine()
        if not _info or Player:IsLeader() or -1 == _nLine or _nLine == _info.line then
          return false
        end
        if _aX then
          return MoveCallback_InScene(_aX, _aY, _aScene)
        end
        return true
      end
      
      JL_ChangeLine(info.line, true, _cb)
    end
  end
end

function JL_MoveToNPC_team(aNpcName, aNpcX, aNpcY, aDefSceneID)
  local jlScene = JL_GetSceneID()
  if -1 ~= jlScene then
    local info = JL_GetLeaderLineSceneID()
    if Player:IsLeader() then
      MoveToNPC(aNpcName, aNpcX, aNpcY, jlScene, nil, nil, nil, MoveCallback_InScene)
    elseif info then
      if JL_ChangeLine(info.line, true) == false then
        MoveToNPC(aNpcName, aNpcX, aNpcY, info.sceneID, nil, nil, nil, MoveCallback_NoFuben)
      end
    else
      DebugStr("金陵:没有获取到队长的金陵地图", 2)
    end
  else
    PushColorMsg("前往金陵地图")
    local info = JL_GetLeaderLineSceneID()
    if IsKVKSceneName() and info then
      if Player:IsLeader() then
        MoveToNPC(aNpcName, aNpcX, aNpcY, aDefSceneID, nil, nil, nil, MoveCallback_NoFuben)
      else
        MoveToNPC(aNpcName, aNpcX, aNpcY, info.sceneID, nil, nil, nil, MoveCallback_NoFuben)
      end
    else
      MoveToNPC(aNpcName, aNpcX, aNpcY, aDefSceneID, nil, nil, nil, MoveCallback_NoFuben)
    end
  end
end

function JL_MoveToNPC_line(aNpcName, aNpcX, aNpcY, aLine)
  local defSceneID = 762
  local jlScene = JL_GetSceneID()
  if -1 ~= jlScene then
    local nScene = JL_GetSceneIDByLine(aLine)
    if JL_ChangeLine(aLine, true) == false and nScene > -1 then
      MoveToNPC(aNpcName, aNpcX, aNpcY, nScene, nil, nil, nil, MoveCallback_InScene)
      return true
    end
  else
    PushColorMsg("前往金陵地图")
    MoveToNPC(aNpcName, aNpcX, aNpcY, defSceneID, nil, nil, nil, MoveCallback_NoFuben)
  end
  return false
end

function BJ_GetLineInfoBySceneID(aSceneID)
  local alltab = BJ_GetSceneLineTab()
  local tab
  for i = 1, #alltab do
    if alltab[i].sceneID == aSceneID then
      tab = alltab[i]
      break
    end
  end
  return tab
end

function BJ_GetLineSceneID(aDefaultType)
  local alltab = BJ_GetSceneLineTab()
  local tab
  if nil == tab then
    local curScene = GetSceneID()
    for i = 1, #alltab do
      if alltab[i].sceneID == curScene then
        tab = alltab[i]
        break
      end
    end
  end
  if nil == tab then
    if 1 == aDefaultType then
      tab = tab[1]
    else
      math.randomseed(GetTickCount())
      local idx = math.random(1, #alltab)
      tab = alltab[idx]
    end
  end
  return tab
end

function BJ_GetRandomSceneID()
  local alltab = BJ_GetSceneLineTab()
  math.randomseed(GetTickCount())
  local idx = math.random(1, #alltab)
  return alltab[idx].sceneID
end

function BJ_GetRunSceneID()
  local tempID = BJ_GetSceneID()
  if -1 == tempID then
    tempID = BJ_GetRandomSceneID()
  end
  return tempID
end

function BJ_GetLine()
  local tab = BJ_GetLineInfoBySceneID(GetSceneID())
  if tab then
    return tab.line
  end
  return -1
end

function BJ_GetLeaderLineSceneID()
  local leader, isleader = Team:GetLeaderInfo()
  if isleader then
    return BJ_GetLineSceneID(2)
  end
  if leader then
    return BJ_GetLineInfoBySceneID(leader.sceneID)
  end
  return nil
end

function BJ_ChangeLine(aLine, aLeaderOver)
  local bChange = false
  if aLine > 0 then
    local npc = {
      x = 347,
      y = 353,
      name = "梁民",
      scriptID = 702510
    }
    local tick_change_pos = -1
    while true do
      local nSceneID = BJ_GetSceneID()
      if -1 == nSceneID or aLeaderOver and Player:IsLeader() then
        break
      end
      local nLine = BJ_GetLine()
      if -1 ~= nLine and nLine ~= aLine then
        PushColorMsg("更换线路" .. aLine)
        MoveTo(npc.x, npc.y, nSceneID, nil, nil, nil, MoveCallback_InScene)
        local tObj = Enum2XByName(npc.name, {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          local tmp = tObj[1]
          MoveToNPC(tmp.name, tmp.x, tmp.y, nSceneID, nil, nil, nil, MoveCallback_InScene)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{TWFX_200814_04}", 1, 700)
          QuestFrameOptionClicked_ScriptID_Extra(npc.scriptID, 30 + aLine, 700)
          bChange = true
        else
          if -1 == tick_change_pos then
            tick_change_pos = GetTickCount()
          end
          if GetTickCount() - tick_change_pos > 10000 then
          end
        end
        Sleep(100)
        DebugStr("汴京: 切换线路" .. aLine)
      else
        if -1 ~= nLine then
          break
        end
        PushColorMsg("未获取到当前线路")
      end
      Sleep(1000)
    end
  end
  return bChange
end

function BJ_MoveToNPC_team(aNpcName, aNpcX, aNpcY, aDefSceneID)
  local bjScene = BJ_GetSceneID()
  if -1 ~= bjScene then
    local info = BJ_GetLeaderLineSceneID()
    if Player:IsLeader() then
      MoveToNPC(aNpcName, aNpcX, aNpcY, bjScene, nil, nil, nil, MoveCallback_InScene)
    elseif info then
      if BJ_ChangeLine(info.line, true) == false then
        MoveToNPC(aNpcName, aNpcX, aNpcY, info.sceneID, nil, nil, nil, MoveCallback_NoFuben)
      end
    else
      DebugStr("汴京:没有获取到队长的金陵地图", 2)
    end
  else
    PushColorMsg("前往汴京地图")
    local info = BJ_GetLeaderLineSceneID()
    if IsKVKSceneName() and info then
      if Player:IsLeader() then
        MoveToNPC(aNpcName, aNpcX, aNpcY, aDefSceneID, nil, nil, nil, MoveCallback_NoFuben)
      else
        MoveToNPC(aNpcName, aNpcX, aNpcY, info.sceneID, nil, nil, nil, MoveCallback_NoFuben)
      end
    else
      MoveToNPC(aNpcName, aNpcX, aNpcY, aDefSceneID, nil, nil, nil, MoveCallback_NoFuben)
    end
  end
end

function GetLifeInfo(aLifeID)
  local lifeID = aLifeID
  local strText = fmt([[
        local skillID = %d
        local curLevel = 0
        local canUp = 0
        local nLifeAbilityCount = GetActionNum("life")
        for i = 1, nLifeAbilityCount do
            local theAction = EnumAction(i - 1, "life")
            local lifeIndex = theAction:GetID()
            if lifeIndex ~= 0 then
                local lifeid = LifeAbility:GetLifeAbility_Number(lifeIndex)
                if lifeid == skillID then
                    local strName = Player:GetAbilityInfo(lifeid, "name")
                    local life_level = Player:GetAbilityInfo(lifeid, "level")
                    local curExp = Player:GetAbilityInfo(lifeid, "skillexp")
                    life_level = tonumber(life_level) or 0
                    curExp = tonumber(curExp) or 0
                    if life_level > 12 or life_level < 1 then
                    else
                        curLevel = life_level
                        local max_exp = LifeAbility:GetLifeAbility_LimitExp(lifeid, life_level)
                        if curExp >= max_exp then
                            canUp = 1
                        end
                    end
                    break
                end
            end
        end
        return curLevel, canUp 
    ]], lifeID)
  local curLevel, canUp = GetLuaValue(strText, "nb")
  if 10 == curLevel then
    canUp = false
  end
  return curLevel, canUp
end
