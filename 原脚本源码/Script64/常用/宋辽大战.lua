-- 反编译自 dfz64.dll 内嵌字节码 003771af（unluac 2025-12-23；仅供分析）
local m_script_name = "宋辽大战"
ScriptOnStart(m_script_name, false, false)
local m_npc = {
  {
    x = 235,
    y = 222,
    sceneID = 2,
    name = "方玉拓"
  },
  {
    x = 223,
    y = 230,
    sceneID = 2,
    name = "司相"
  },
  {
    x = 255,
    y = 238,
    sceneID = 2,
    name = "齐资"
  },
  {
    x = 294,
    y = 241,
    sceneID = 1,
    name = "刘博"
  },
  {
    x = 312,
    y = 235,
    sceneID = LUOYANG_ID,
    name = "祝帅"
  },
  {
    x = 307,
    y = 230,
    sceneID = LUOYANG_ID,
    name = "郑怀远"
  }
}

local function SLDZ_UseQiZi()
  local allItem = {}
  local strAllItem = "相（宋）|車（宋）|砲（宋）|炮（辽）|車（辽）|将（辽）|卒（辽）|象（辽）|砲（宋）|砲（宋）|馬（宋）|兵（宋）|帥（宋）|車（宋）|車（宋）|馬（宋）|仕（宋）|相（宋）|兵（宋）|兵（宋）"
  for w in string.gmatch(strAllItem, "([^'|']+)") do
    table.insert(allItem, w)
  end
  for k, v in ipairs(allItem) do
    if Bag:GetItemCount(v) >= 1 then
      PushColorMsg("自动使用：" .. k .. ":" .. v)
      Bag:UseItemByName_click(v, 500)
    end
  end
end

local function SLDZ_cb(...)
  if GetSceneID() == 843 then
    return false
  end
  local strScene = GetCurrentSceneName()
  if string.find(strScene, "宋辽战场", nil, true) then
    return false
  end
  return true
end

local function SLDZ_OnFuben()
  local nZhenYin = -1
  local strFangYuTa = ""
  if -1 == Player:GetBuff("乾坤壶：") then
    Bag:UseItemByName_click("乾坤壶", 1000)
  end
  while true do
    local strScene = GetCurrentSceneName()
    if not string.find(strScene, "宋辽战场", nil, true) then
      break
    end
    if -1 == nZhenYin then
      if -1 ~= Player:GetBuff("辽·小卒") then
        nZhenYin = 1
        strFangYuTa = " #{SLDZ_220216_167} #{SLDZ_220216_168} #{SLDZ_220216_169} "
      elseif -1 ~= Player:GetBuff("宋·小兵") then
        nZhenYin = 2
        strFangYuTa = " #{SLDZ_220216_170} #{SLDZ_220216_171} #{SLDZ_220216_172} "
      end
      Sleep(5000)
    end
    SLDZ_UseQiZi()
    local tObj = EnumAttackObj("玩家", {0, 15})
    if #tObj > 0 then
      Dismount(500)
      local target = tObj[1]
      local tid = target.id
      local bKongZhi, bFangDa, bWuDi, bZuoQi = Target:GetSpecialBuff(target)
      if bWuDi then
        PushDebugMessage("%s 处于无敌状态,寻找其他目标", target.name)
      else
        if not bKongZhi then
          Skill:UseKongZhi(g_config.skill.pk_kongzhi, target, false)
        end
        CDG:SkillAttack(tid)
        Target:Attack(tid, 300, true)
      end
      CDG:checkHP_Pet(false)
      CDG:checkMP(false)
    else
      local tObj = Enum2XByName(strFangYuTa, {
        1,
        1,
        0,
        0
      }, {0, -1}, 1, 3)
      if 0 == #tObj then
        tObj = Enum2XByClass("怪物", {0, -1}, 1)
      end
      if #tObj > 0 then
        local target = tObj[1]
        local tid = target.id
        if target.dst > 15 then
          RunTo(target.x, target.y, 3, 1000)
        else
          CDG:SkillAttack(tid)
          Target:Attack(tid, 300, true)
          CDG:checkHP_Pet(false)
          CDG:checkMP(false)
        end
      else
        if 1 == nZhenYin then
          RunTo(210, 270, 3, 600)
        elseif 2 == nZhenYin then
          RunTo(110, 45, 3, 600)
        end
        CDG:checktime0()
        CDG:checktime3()
        CDG:checkfree()
      end
    end
    PickUpLua()
    DieOutAndGetPos()
    Sleep(200)
  end
end

local function SLDZ_GetYuBeiShiNpc()
  local pos = Player:GetPos()
  local npc = {
    index = -1,
    x = -1,
    y = -1
  }
  if pos.y > 4 and pos.y < 68 then
    if pos.x > 4 and pos.x < 68 then
      npc.index = 1
      npc.x = 36
      npc.y = 14
      return npc
    end
    if pos.x > 96 and pos.x < 163 then
      npc.index = 2
      npc.x = 132
      npc.y = 14
      return npc
    end
    if pos.x > 186 and pos.x < 254 then
      npc.index = 3
      npc.x = 219
      npc.y = 14
      return npc
    end
  end
  if pos.y > 100 and pos.y < 158 then
    if pos.x > 4 and pos.x < 67 then
      npc.index = 4
      npc.x = 36
      npc.y = 107
      return npc
    end
    if pos.x > 96 and pos.x < 163 then
      npc.index = 5
      npc.x = 132
      npc.y = 107
      return npc
    end
    if pos.x > 186 and pos.x < 254 then
      npc.index = 6
      npc.x = 219
      npc.y = 107
      return npc
    end
  end
  if pos.y > 186 and pos.y < 254 then
    if pos.x > 4 and pos.x < 67 then
      npc.index = 7
      npc.x = 36
      npc.y = 197
      return npc
    end
    if pos.x > 96 and pos.x < 163 then
      npc.index = 8
      npc.x = 132
      npc.y = 197
      return npc
    end
    if pos.x > 186 and pos.x < 254 then
      npc.index = 9
      npc.x = 219
      npc.y = 197
      return npc
    end
  end
  return npc
end

local function SLDZ_LeaveYBS(aNpc)
  while GetSceneID() == 843 do
    local npc = SLDZ_GetYuBeiShiNpc()
    if -1 ~= npc.index and RunTo(npc.x, npc.y, 3, 600) == false then
      TalkNpc(aNpc.name, 1000)
      Sleep(500)
      DialogOptionClicked("退出雁门关前哨", 1, 1000)
      MessageBox_Self_OK_Clicked(1000)
    end
    PushDebugMessage("离开休息室")
    Sleep(3000)
  end
end

function _SMain()
  local nWeek = tonumber(os.date("%w"))
  if 0 == nWeek then
    nWeek = 7
  end
  if 3 ~= nWeek and 7 ~= nWeek then
    PushColorMsg("宋辽活动为周三和周日,今天是周%s", nWeek)
    return
  end
  local idx = -1
  local nLevel = Player:GetDataInt("LEVEL")
  if nLevel >= 60 and nLevel <= 69 then
    idx = 1
  elseif nLevel >= 70 and nLevel <= 79 then
    idx = 2
  elseif nLevel >= 80 and nLevel <= 89 then
    idx = 3
  elseif nLevel >= 90 and nLevel <= 109 then
    idx = 4
  elseif nLevel >= 110 and nLevel <= 119 then
    idx = 5
  elseif nLevel > 119 then
    idx = 6
  else
    PushDebugMessage(m_script_name .. ":等级不符合 " .. nLevel)
    return
  end
  local npc = m_npc[idx]
  while true do
    local strScene = GetCurrentSceneName()
    if "雁门关前哨" == strScene then
      PushDebugMessage("等待进入")
      Sleep(3000)
      if IsInDebugMsg("#{SLDZ_220216_32}") then
        SLDZ_LeaveYBS(npc)
        break
      end
    elseif string.find(strScene, "宋辽战场", nil, true) then
      SLDZ_OnFuben()
      break
    else
      DeleteDebugMsg("#{SLDZ_220216_43}")
      DeleteDebugMsg("#{SLDZ_220216_108}")
      MoveTo(npc.x, npc.y, npc.sceneID, nil, nil, nil, SLDZ_cb)
      TalkNpc(npc.name, 1000)
      Team:LeaveTeam()
      QuestFrameOptionClicked_Item("#{SLDZ_220216_01", 3, 1000)
      Sleep(2000)
      if IsInDebugMsg("#{SLDZ_220216_43}") then
        break
      end
      if IsInDebugMsg("#{SLDZ_220216_108}") then
        MoveTo(npc.x, npc.y, npc.sceneID, nil, nil, nil, SLDZ_cb)
        TalkNpc(npc.name, 1000)
        QuestFrameOptionClicked_Item("#{SLDZ_100805_03}", 1, 1000)
      end
    end
    DebugStr(m_script_name)
    Sleep(1000)
  end
  GetLuaValue("if Player:IsInRaid() == 1 then Player:LeaveRiad() end")
  DeleteDebugMsg("#{SLDZ_220216_11}")
  for i = 1, 5 do
    MoveTo(npc.x, npc.y, npc.sceneID, nil, nil, nil, SLDZ_cb)
    TalkNpc(npc.name, 1000)
    QuestFrameOptionClicked_Item("#{SLDZ_100805_03}", 1, 1000)
    if IsInDebugMsg("#{SLDZ_220216_11}") then
      break
    end
  end
  Bag:UseItemByName_click("宋辽破竹礼·雀影", 1000)
  Bag:UseItemByName_click("宋辽破竹礼·鹤鸣", 1000)
  Bag:UseItemByName_click("宋辽破竹礼·鹰扬", 1000)
  Bag:UseItemByName_click("宋辽破竹礼·虎啸", 1000)
  Bag:UseItemByName_click("宋辽破竹礼·龙腾", 1000)
end

_SMain()
ScriptOnStop(m_script_name)
