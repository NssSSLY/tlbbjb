-- 反编译自 dfz64.dll 内嵌字节码 0036c43f（unluac 2025-12-23；仅供分析）
local m_script_name = "大理种花"
ScriptOnStart("大理种花", false, false)
local m_xStart = ReadConfigInt("ZH", "bjk67")
local m_ballShiFei = ReadConfigBool("ZH", "xzk86")
local m_isNotShouHua = ReadConfigBool("ZH", "xzk188")
local m_isShouPlayer = ReadConfigBool("ZH", "xzk284")
local m_yStart = 145
local m_shouhua = {}
local m_shifei = {}
local m_stopShifei, m_stopShouHua = false, false
local m_stopBank = false
g_self.name = GetLuaValue("return Player:GetName();", "s")

local function zh_checkShouHua(tid)
  local nNowTick = GetTickCount()
  for i = #m_shouhua, 1, -1 do
    local tmp = m_shouhua[i]
    if nNowTick - tmp.tick > 180000 then
      table.remove(m_shouhua, i)
    elseif nNowTick > tmp.tick_shou then
      table.remove(m_shouhua, i)
    end
  end
  return not FindTableFieldValue(m_shouhua, "id", tid)
end

local function zh_pushShouHuaID(tid)
  local strText = GetNPCEventList_Item(0)
  local _, _, nTick = string.find(strText, "#{SDJZH_091106_08}(%d+)#{SDJZH_091106_09}")
  nTick = tonumber(nTick)
  if nTick then
    local n = #m_shouhua + 1
    m_shouhua[n] = {}
    m_shouhua[n].id = tid
    m_shouhua[n].tick = GetTickCount()
    m_shouhua[n].tick_shou = GetTickCount() + 1000 * nTick
    PushDebugMessage("成熟鲜花ID:" .. tid .. " " .. nTick .. "秒后可收取")
    return true
  end
  return false
end

local function zh_checkShiFei(tid)
  local nNowTick = GetTickCount()
  for i = #m_shifei, 1, -1 do
    local tmp = m_shifei[i]
    if nNowTick - tmp.tick > 480000 then
      table.remove(m_shifei, i)
    end
  end
  return not FindTableFieldValue(m_shifei, "id", tid)
end

local function zh_pushShiFeiID(tid)
  if IsInDebugMsg("#{SDJZH_091106_21}", 1) then
    local n = #m_shifei + 1
    m_shifei[n] = {}
    m_shifei[n].id = tid
    m_shifei[n].tick = GetTickCount()
  end
end

local function zh_enumNeedShiFei()
  local tret = {}
  if m_ballShiFei then
    local tObj = Enum2XByClass("NPC", nil, 0)
    tObj = GetTableChildString(tObj, "name", {"鲜花幼苗"}, 2)
    for i = 1, #tObj do
      local tmp = tObj[i]
      if zh_checkShiFei(tmp.id) then
        local n = #tret + 1
        tret[n] = {}
        tret[n].id = tmp.id
        tret[n].x = tmp.x
        tret[n].y = tmp.y
      end
    end
  else
    local szAllOther = GetLocalPlayerName()
    local tObj = Enum2XByClass("NPC", nil, 0)
    for i = 1, #tObj do
      local tmp = tObj[i]
      local playerName = string.gsub(tmp.title, "#{SDJZH_32}", "")
      if string.find(szAllOther, " " .. playerName .. " ", nil, true) and zh_checkShiFei(tmp.id) then
        local n = #tret + 1
        tret[n] = {}
        tret[n].id = tmp.id
        tret[n].x = tmp.x
        tret[n].y = tmp.y
      end
    end
  end
  return tret
end

local function zh_shiFei()
  if 0 == Bag:GetItemCount("花肥") then
    local pos = Player:GetPos()
    if false == m_stopBank then
      Bank_GetItem(" 花肥 ", 150)
    end
    Sleep(500)
    if 0 == Bag:GetItemCount("花肥") then
      m_stopShifei = true
      m_stopBank = true
      return
    end
    MoveTo(pos.x, pos.y, 2, 1, false)
  end
  local x1 = m_xStart
  local y1 = m_yStart + 4
  local tObj = zh_enumNeedShiFei()
  if 0 == #tObj then
    MoveTo(x1, y1, 2, 1, false)
    Sleep(500)
    tObj = zh_enumNeedShiFei()
    if 0 == #tObj then
      x1 = x1 + 12
      MoveTo(x1, y1, 2, 1, false)
      Sleep(500)
      tObj = zh_enumNeedShiFei()
    end
  end
  Dismount()
  if #tObj > 0 then
    ClearDbgMsg()
    tObj = GetAllPosDist(tObj, nil, "dst")
    BubbleByDst(tObj, 1)
    local tmp = tObj[1]
    if GetDist(tmp.x, tmp.y) > 3 then
      MoveTo(tmp.x, tmp.y, 2, nil, false)
      Sleep(300)
    end
    Target:Select(tmp.id)
    Sleep(300)
    local tItem = Bag:FindItemInfo("花肥")
    if #tItem > 0 then
      local tmp = tItem[1]
      Bag:ItemBtnClicked(tmp.index)
      Sleep(300)
      PlayerStateTimeOut(5, 10)
      zh_pushShiFeiID(tmp.id)
    end
    ClearDbgMsg()
  end
end

local function zh_enumShouHua(mode)
  local tret = {}
  local npcTitle = g_self.name .. "#{SDJZH_33}"
  if m_isShouPlayer then
    local tObj = Enum2XByName("成熟的鲜花", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    for i = 1, #tObj do
      local tmp = tObj[i]
      if tmp.title == npcTitle or zh_checkShouHua(tmp.id) then
        local n = #tret + 1
        tret[n] = {}
        tret[n].id = tmp.id
        tret[n].x = tmp.x
        tret[n].y = tmp.y
      end
    end
  else
    tret = Enum2XByTitle(npcTitle, {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
  end
  return tret
end

local function zh_shouHua()
  local x1 = m_xStart
  local y1 = m_yStart + 4
  local tObj = zh_enumShouHua()
  if 0 == #tObj then
    MoveTo(m_xStart + 6, y1, 2, nil, false)
    tObj = zh_enumShouHua()
  end
  Dismount()
  if 0 == #tObj then
    m_stopShouHua = true
  else
    m_stopShouHua = false
  end
  for i = 1, #tObj do
    CloseWindow("Quest")
    local tmp = tObj[i]
    if GetDist(tmp.x, tmp.y) > 3 then
      MoveTo(tmp.x, tmp.y, 2, nil, false)
      Sleep(300)
    end
    for j = 1, 3 do
      Skill.CUseSkillByID(3, tmp.id, -1, -1)
      Sleep(1000)
      if PlayerStateTimeOut(5, 10) or zh_pushShouHuaID(tmp.id) then
        break
      end
    end
    Sleep(500)
  end
  if #tObj > 0 then
    return true
  end
  return false
end

local function zh_checkPos(xPos, yPos)
  local pos = {}
  pos.x = xPos
  pos.y = yPos
  local tObj = Enum2XByClass("NPC", nil, 0)
  tObj = GetTableChildString(tObj, "name", {"鲜花"}, 2)
  return IsPosSafe(pos, tObj, 2.999)
end

local function zh_findPos()
  local tX = m_xStart
  local tY = m_yStart
  local bHavePos = false
  for i = 1, 5 do
    for j = 1, 5 do
      if tY < 144 or tY > 153 then
        break
      end
      if zh_checkPos(tX, tY) then
        bHavePos = true
        break
      end
      tY = tY + 3
    end
    if bHavePos then
      break
    end
    tY = m_yStart
    tX = tX + 3
  end
  return bHavePos, tX, tY
end

function _SMain(...)
  if not IsWindowVisible("Packet") then
    GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_Open();")
  end
  if 0 == Bag:GetItemCount("鲜花的种子") or 0 == Bag:GetItemCount("花肥") then
    PushDebugMessage("仓库取鲜花种子、花肥")
    Bank_GetItem(" 鲜花的种子 花肥 ", 100)
  end
  while true do
    local isShouHua = false
    if not m_isNotShouHua then
      isShouHua = zh_shouHua()
    else
      m_stopShouHua = true
    end
    if false == isShouHua then
      if 0 ~= Bag:GetItemCount("鲜花的种子") then
        local bHavePos, tX, tY = zh_findPos()
        if false == bHavePos then
          MoveTo(m_xStart + 6, m_yStart + 5, 2, 1, false)
          bHavePos, tX, tY = zh_findPos()
        end
        if bHavePos then
          MoveTo(tX, tY, 2, 0, false)
          Dismount()
          Bag:UseItemByName("鲜花的种子")
          Sleep(1000)
          PlayerStateTimeOut(5, 10)
        end
      else
        MoveTo(m_xStart + 6, m_yStart + 4, 2, nil, false)
        local tObj = Enum2XByName("鲜花幼苗1级 鲜花幼苗2级 鲜花幼苗3级 成熟的鲜花", {
          1,
          0,
          0,
          0
        }, nil, nil, 3)
        if 0 == #tObj then
          Sleep(10000)
          tObj = Enum2XByName("鲜花幼苗1级 鲜花幼苗2级 鲜花幼苗3级 成熟的鲜花", {
            1,
            0,
            0,
            0
          }, nil, nil, 3)
          if 0 == #tObj then
            PushColorMsg("已经没有种子和花！")
            break
          end
        end
        if m_stopShifei and m_stopShouHua then
          PushColorMsg("种花：已经没有种子、花苗、成熟的鲜花！")
          break
        end
      end
      zh_shiFei()
    end
    Player:DispelBuffByName("解除变身状态")
    Sleep(500)
    DebugStr("大理种花...")
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
