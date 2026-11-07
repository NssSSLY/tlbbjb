-- 反编译自 dfz64.dll 内嵌字节码 004f593d（unluac 2025-12-23；仅供分析）
local m_param = {}
local m_data = {}
m_data.old_item = {}
m_data.gameVer = ""
m_data.serverName = ""
m_data.last_tick_getData = -1
m_data.next_time = 0
m_data.npcID = -1
m_data.sceneID = -1

function GetShopData()
  local tItem = {}
  local strAllItem = GetLuaValue([[
            local strAllItem = ""
            setmetatable(_G, {__index = Shop_Env})
            if this:IsVisible() then 
                local nAllCount = GetActionNum("boothitem")
                for i = 0, nAllCount - 1 do
                    local theAction = EnumAction(i, "boothitem")
                    local itemID = theAction:GetID()
                    if itemID ~= 0 then
                        local maxNum = theAction:GetMaxNum()
                        local strName = theAction:GetName()
                        local nPrice = NpcShop:EnumItemPrice(i)
                        local str = i .. "&" .. strName .. "&" .. nPrice .. "&" .. maxNum
                        strAllItem = strAllItem .. str .. " "
                    end
                end 
            end
            return strAllItem       
            ]], "s")
  local strArr = SplitString(strAllItem, " ", true)
  for i = 1, #strArr do
    local infoArr = SplitString(strArr[i], "&", true)
    if #infoArr >= 4 then
      local nIndex = tonumber(infoArr[1])
      local strName = infoArr[2]
      local nPrice = tonumber(infoArr[3])
      local maxNum = tonumber(infoArr[4])
      if nIndex and nPrice then
        local tmp = {
          index = nIndex + 1,
          name = strName,
          price = nPrice,
          count = maxNum
        }
        table.insert(tItem, tmp)
      end
    end
  end
  for i = 1, #tItem do
    if tItem[i].index ~= i then
      PushColorMsg("抢抢:获取的数据无效!")
      return {}
    end
  end
  return tItem
end

local function QQ_CheckRefresh()
  local bOver = false
  local nowTick = GetTickCount()
  if nowTick - m_data.last_tick_getData < 2000 then
    return bOver
  end
  if nowTick - m_data.last_tick_getData < 10000 then
    return bOver
  end
  local bRefresh = false
  local tItem = GetShopData()
  if #tItem > 0 then
    if 0 == #m_data.old_item then
      m_data.old_item = tItem
    elseif #m_data.old_item == #tItem then
      for i = 1, #m_data.old_item do
        if m_data.old_item[i].name ~= tItem[i].name or tItem[i].count > m_data.old_item[i].count then
          bRefresh = true
          break
        end
      end
    else
      bRefresh = true
    end
  end
  if m_param.sell_out_stop and -1 ~= m_data.last_tick_getData and nowTick > m_data.last_tick_getData and #tItem > 0 then
    local bFind = false
    for i = 1, #tItem do
      local tmp = tItem[i]
      if tmp.count > 0 and string.find(m_param.itemName, " " .. tmp.name .. " ", nil, true) then
        bFind = true
        break
      end
    end
    if not bFind then
      bOver = true
    end
  end
  if bRefresh then
    m_data.old_item = tItem
    local field = m_param.name .. m_data.serverName .. "记录版本"
    GC_Set(field, m_data.gameVer, "抢购刷新")
    field = m_param.name .. m_data.serverName .. "上次刷新"
    local nNowTime = os.time()
    local strTime = GetTimeStr(nNowTime)
    GC_Set(field, strTime, "抢购刷新")
    if m_param.refresh_time > 0 then
      field = m_param.name .. m_data.serverName .. "下次刷新"
      strTime = GetTimeStr(nNowTime + m_param.refresh_time)
      GC_Set(field, strTime, "抢购刷新")
    end
    m_data.last_tick_getData = nowTick
  end
  return bOver
end

local function QQ_CheckRecordVersion()
  local field = m_param.name .. m_data.serverName .. "记录版本"
  local strVersion = GC_Get(field, "抢购刷新")
  if strVersion ~= m_data.gameVer then
    if m_param.use_record then
      PushColorMsg("抢购:记录的版本与当前不匹配,忽略！")
      m_param.use_record = false
    end
    return false
  end
  return true
end

local function QQ_Buy()
  local checkValue = DoSystem(1006)
  for j = 0, 4 do
    SP_ShopBuyItem(j, checkValue, m_data.npcID, m_data.sceneID)
    CSleep(20)
  end
end

local function QQ_GetRefreshTime()
  if not QQ_CheckRecordVersion() then
    return
  end
  local nowTime = os.time()
  if nowTime < m_data.next_time then
    return
  end
  if nowTime - m_data.next_time > 10 and m_param.refresh_time > 0 then
    local field = m_param.name .. m_data.serverName .. "下次刷新"
    local strTime = GC_Get(field, "抢购刷新")
    local nNextTime = GetTimeStampFromStr(strTime)
    if nNextTime then
      local nTime = nNextTime
      for i = 1, 100 do
        if nowTime < nTime then
          break
        end
        nTime = nTime + m_param.refresh_time
      end
      if nowTime <= nTime then
        m_data.next_time = nTime
        PushColorMsg("抢购：下次刷新时间 " .. GetTimeStr(nTime))
      end
    end
  end
end

function QQ_Action(aParam)
  RecvState(0)
  m_param = aParam
  m_param.get_money = ReadConfigInt("ZH", "bjk1")
  Bag:PackUp(-1)
  CloseAllWindow()
  m_data.serverName = GetServerName()
  m_data.gameVer = GetGameVersion()
  if m_param.sleep < 10 then
    m_param.sleep = 10
  end
  m_param.itemName = HandleText_AddFuHao(m_param.itemName, " ", true)
  m_data.sceneID = m_param.sceneID
  if m_data.sceneID == 242 then
    m_data.sceneID = 0
  end
  local oldMoney = Player:GetMoney()
  if oldMoney < m_param.get_money * 10000 and m_param.name ~= "李乐施" and m_param.name ~= "神秘商人" then
    PushColorMsg("抢购：仓库取出%sJ", m_param.get_money)
    Bank_GetMoney(m_param.get_money * 10000)
    Sleep(800)
    oldMoney = Player:GetMoney()
  end
  Log(fmt("抢购前铜币:%s", oldMoney))
  QQ_GetRefreshTime()
  SetShopBuyName(m_param.itemName)
  RecvState(32)
  local bCheckYinShen = true
  while true do
    local tObj = Enum2XByName(m_param.name, {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 and tObj[1].dst < 3 then
      local tmp = tObj[1]
      m_data.npcID = tmp.id
      if m_param.option and not QuestFrameOptionClicked_Item(m_param.option, 1) then
        SP_OpenTalk(tmp.id)
      else
        SP_OpenTalk(tmp.id)
      end
      if bCheckYinShen and m_param.yinshen and 7 == g_self.menpai then
        if -1 == Player:GetBuff("隐身") then
          Dismount(500)
          Skill:UseName("金蝉脱壳", 2000)
        else
          bCheckYinShen = false
        end
      end
      local bOver = QQ_CheckRefresh()
      if bOver then
        break
      end
    else
      bCheckYinShen = true
      if #tObj > 0 then
        local tmp = tObj[1]
        GoToSceneNPC(m_param.name, tmp.x, tmp.y, m_param.sceneID, 2)
      else
        local function _cb(_aX, _aY, _aSceneID)
          local tObj = Enum2XByName(m_param.name, {
            1,
            
            0,
            0,
            0
          }, nil, nil, 0)
          if #tObj > 0 then
            RunTo(tObj[1].x, tObj[1].y, 1, 500)
            return false
          end
          return true
        end
        
        for i = 1, #m_param.pos do
          local tmp = m_param.pos[i]
          MoveTo(tmp.x, tmp.y, m_param.sceneID, nil, nil, nil, _cb, true, true)
          local tObj = Enum2XByName(m_param.name, {
            1,
            0,
            0,
            0
          }, nil, nil, 0)
          if #tObj > 0 then
            break
          end
        end
      end
      Sleep(500)
    end
    CSleep(m_param.sleep)
  end
  local nowMoney = Player:GetMoney()
  Log(fmt("抢购后铜币：%s,本次消耗 %s 铜币", nowMoney, oldMoney - nowMoney))
  Bank_SaveMoney(0)
  m_param = nil
  m_data = nil
end
