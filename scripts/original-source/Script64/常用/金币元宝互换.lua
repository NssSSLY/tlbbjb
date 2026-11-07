-- 反编译自 dfz64.dll 内嵌字节码 00392eb4（unluac 2025-12-23；仅供分析）
local m_script_name = "金币元宝互换"
ScriptOnStart(m_script_name, false, false)
g_config.jbybhh = {}
g_config.jbybhh.sceneName = ReadConfigText("ZH", "bjk127")
g_config.jbybhh.x = ReadConfigInt("ZH", "bjk144")
g_config.jbybhh.y = ReadConfigInt("ZH", "bjk150")
g_config.jbybhh.J2YB = ReadConfigBool("ZH", "xzk185")
g_config.jbybhh.J2YB_price = ReadConfigInt("ZH", "bjk114")
g_config.jbybhh.YB2J = ReadConfigBool("ZH", "xzk186")
g_config.jbybhh.YB2J_price = ReadConfigInt("ZH", "bjk115")
g_config.jbybhh.invalid_lock_count = ReadConfigInt("ZH", "bjk170")
g_config.jbybhh.get_money_bank = ReadConfigBool("ZH", "xzk194")
g_config.jbybhh.get_money_shop = ReadConfigBool("ZH", "xzk193")
g_config.jbybhh.keep_money = ReadConfigInt("ZH", "bjk167")
g_config.jbybhh.get_money = ReadConfigInt("ZH", "bjk168")
g_config.jbybhh.min_money = ReadConfigInt("ZH", "bjk169")
local m_param = {}
m_param.sceneName = string.gsub(g_config.jbybhh.sceneName, " ", "")
m_param.x = HandleTextToNumber(g_config.jbybhh.x, 0)
m_param.y = HandleTextToNumber(g_config.jbybhh.y, 0)
m_param.J2YB = g_config.jbybhh.J2YB
m_param.J2YB_price = HandleTextToNumber(g_config.jbybhh.J2YB_price, 0)
m_param.YB2J = g_config.jbybhh.YB2J
m_param.YB2J_price = HandleTextToNumber(g_config.jbybhh.YB2J_price, 0)
m_param.invalid_lock_count = HandleTextToNumber(g_config.jbybhh.invalid_lock_count, 0)
m_param.get_money_bank = g_config.jbybhh.get_money_bank
m_param.get_money_shop = g_config.jbybhh.get_money_shop
m_param.get_money = HandleTextToNumber(g_config.jbybhh.get_money, 0) * 10000
m_param.keep_money = HandleTextToNumber(g_config.jbybhh.keep_money, 0) * 10000
m_param.min_money = HandleTextToNumber(g_config.jbybhh.min_money, 0) * 10000
local m_data = {}
m_data.last_tick_get_money = -1
m_data.heimingdan = {}

local function JBYB_OtherItemCount()
  local strText = [[
            setmetatable(_G, {__index = Exchange_Env})
            if this:IsVisible() then
                return GetActionNum('ex_other')
            end
            return 0
        ]]
  return GetLuaValue(strText, "n")
end

local function JBYB_CalcJB()
  local hasOtherItem = false
  local nPrice = 0
  local nOtherYB = 0
  local tItem = Bag:EnumJiaoYiOtherItem()
  local tYBP = Bag:FindItemInfo("元宝票", nil, nil, tItem)
  if #tYBP ~= #tItem then
    hasOtherItem = true
  end
  if #tYBP > 0 then
    nOtherYB = TableFieldCount(tYBP, "ybpValue")
    nPrice = math.floor(nOtherYB * m_param.J2YB_price * 10000)
  end
  return nPrice, hasOtherItem, nOtherYB
end

local function JBYB_CalcYB()
  local nMoney = Exchange_GetMoney("other")
  return math.floor(nMoney / m_param.YB2J_price / 10000)
end

local function JBYB_CheckMoney()
  if GetTickCount() - m_data.last_tick_get_money > 300000 then
    local nowMoney = Player:GetMoney()
    if m_param.keep_money > 0 and nowMoney < m_param.keep_money then
      PushColorMsg("需要取金币")
      if m_param.get_money_bank then
        Bank_GetMoney(m_param.get_money)
      end
      if m_param.get_money_shop then
        ShangHui_GetMoney(m_param.get_money)
      end
    end
    m_data.last_tick_get_money = GetTickCount()
  end
end

local function JBYB_InsertHMD(aName)
  local file = io.open(g_public_dir .. "角色设置\\交易黑名单.txt", "a")
  if file then
    file:write(aName .. "\n")
    io.close(file)
  end
end

local function JBYB_SetHMDCache(aName)
  if m_param.invalid_lock_count <= 0 then
    return
  end
  if Exchange_IsHeiMingDan(aName) then
    return
  end
  local nowTick = GetTickCount()
  for i = #m_data.heimingdan, 1, -1 do
    if nowTick - m_data.heimingdan[i].last_tick > 1800000 then
      table.remove(m_data.heimingdan, i)
    end
  end
  local bHas = false
  for i = 1, #m_data.heimingdan do
    local tmp = m_data.heimingdan[i]
    if tmp.name == aName then
      tmp.count = tmp.count + 1
      tmp.last_tick = nowTick
      bHas = true
      if tmp.count > m_param.invalid_lock_count then
        PushColorMsg("将 %s 加入黑名单", tmp.name)
        JBYB_InsertHMD(tmp.name)
      end
      break
    end
  end
  if false == bHas then
    table.insert(m_data.heimingdan, {
      name = aName,
      last_tick = nowTick,
      count = 1
    })
  end
end

function _SMain(...)
  LoadScript("jiaoyi")
  if not m_param.J2YB and not m_param.YB2J then
    PushColorMsg(m_script_name .. ":您未设置兑换项")
    return
  end
  if m_param.J2YB and m_param.J2YB_price <= 0 then
    PushColorMsg(m_script_name .. ":金换元宝比例设置有误!")
    return
  end
  if m_param.YB2J and m_param.YB2J_price <= 0 then
    PushColorMsg(m_script_name .. ":元宝换金比例设置有误!")
    return
  end
  Sleep(100)
  local maxMoney = Player:GetMaxMoney()
  if m_param.get_money > maxMoney * 10000 then
    m_param.get_money = maxMoney * 10000
  end
  m_param.sceneID = GetSceneIDByName(m_param.sceneName)
  if m_param.sceneID ~= 224 and m_param.YB2J then
    PushColorMsg("注意：仅钱庄地图支持【元宝换金】,自动取消【元宝换金】")
    m_param.YB2J = false
  end
  while true do
    if IsWindowVisible("Exchange") then
      local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
      if false == Exchange_IsHeiMingDan(otherName) then
        local tYBP = Bag:FindItemInfo("元宝票", nil, nil)
        local oldYuanBao = Player:GetDataInt("YUANBAO") + TableFieldCount(tYBP, "ybpValue")
        local oldMoney = Player:GetMoney(1)
        local bInvalid = false
        local nStartTick = GetTickCount()
        while IsWindowVisible("Exchange") do
          if GetTickCount() - nStartTick > 30000 then
            PushColorMsg("%s:交易超时", otherName)
            CloseWindow("Exchange")
            bInvalid = true
            break
          end
          if Exchange_IsLocked("other") and Exchange_IsLocked("self") then
            local needJB, hasOther1 = JBYB_CalcJB()
            local needYB = JBYB_CalcYB()
            local selfYB, hasOther2 = Exchange_CalcSelfYB()
            local nOtherMoney = Exchange_GetMoney("other")
            local nSelfMoney = Exchange_GetMoney("self")
            if nOtherMoney > 0 and false == Exchange_checkMaxMoney() then
              PushColorMsg(m_script_name .. ":交易后金币将已经上限")
              CloseWindow("Exchange")
              break
            end
            if hasOther1 or hasOther2 then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if not m_param.J2YB and (nSelfMoney > 0 or needJB > 0) then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if not m_param.YB2J and (selfYB > 0 or needYB > 0) then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if needJB ~= nSelfMoney then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if needYB ~= selfYB then
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            if not Exchange_IsLocked("other") or not Exchange_IsLocked("self") then
              CloseWindow("Exchange")
              bInvalid = true
              break
            else
              GetLuaValue("Exchange:AcceptExchange()")
              Sleep(500)
              local nTick1 = GetTickCount()
              while IsWindowVisible("Exchange") and Exchange_IsLocked("other") and Exchange_IsLocked("self") do
                Sleep(500)
                if GetTickCount() - nTick1 > 8000 then
                  PushDebugMessage("对方超过8秒没有确定交易！")
                  CloseWindow("Exchange")
                  break
                end
              end
            end
          elseif Exchange_IsLocked("other") then
            Sleep(1000)
            Exchange_LockExchange()
            Sleep(1500)
          elseif Exchange_IsLocked("self") then
            CloseWindow("Exchange")
            bInvalid = true
            break
          else
            local needJB, hasOther, nOtherYB = JBYB_CalcJB()
            if hasOther then
              PushColorMsg("%s:放入了非元宝票物品", otherName)
              CloseWindow("Exchange")
              bInvalid = true
              break
            end
            local myMoney = Exchange_GetMoney("self")
            if needJB > 0 and not m_param.J2YB then
              PushColorMsg("我不收元宝")
              CloseWindow("Exchange")
              bInvalid = true
              break
            elseif myMoney ~= needJB then
              if needJB > Player:GetMoney() then
                PushColorMsg("金币不足,取消交易")
                TalkSendPrivateMsg(otherName, "身上金币不足,请尝试减少数量！")
                CloseWindow("Exchange")
                break
              else
                PushColorMsg("需要 %s 金 兑换 %s 元宝。 " .. myMoney .. " " .. needJB, needJB / 10000, nOtherYB)
                Exchange_InputMoney(needJB)
                Sleep(500)
              end
            end
            local needYB = JBYB_CalcYB()
            if needYB > 0 and not m_param.YB2J then
              PushColorMsg("我不收金币")
              CloseWindow("Exchange")
              bInvalid = true
              break
            else
              local itemYB, hasOther = Exchange_CalcSelfYB()
              if itemYB ~= needYB then
                PushColorMsg("需要 %s 元宝 兑换 %s 金", needYB, Exchange_GetMoney("other") / 10000)
                if 0 == itemYB and needYB <= Player:GetDataInt("YUANBAO") then
                  Player:YuanBaoToTicket(needYB)
                  Sleep(300)
                  local tBag = Bag:FindItemInfo("元宝票")
                  for i = 1, #tBag do
                    local tmp = tBag[i]
                    if tmp.ybpValue == needYB then
                      Bag:ItemBtnClicked(tmp.index)
                      break
                    end
                  end
                  Sleep(400)
                else
                  if needYB > Player:GetDataInt("YUANBAO") then
                    PushColorMsg("元宝不足,取消交易")
                    TalkSendPrivateMsg(otherName, "身上元宝不足,请尝试减少数量！")
                  else
                    PushColorMsg("对方已经修改了金币,重新交易")
                  end
                  CloseWindow("Exchange")
                  bInvalid = true
                  break
                end
              end
            end
          end
          Sleep(500)
          DebugStr("与 %s 交易中", nil, otherName)
        end
        local tYBP = Bag:FindItemInfo("元宝票", nil, nil)
        local nowYuanBao = Player:GetDataInt("YUANBAO") + TableFieldCount(tYBP, "ybpValue")
        if Player:GetMoney() ~= oldMoney or nowYuanBao ~= oldYuanBao then
          LogMsg(fmt("金币元宝互换:交易成功！与[%s]交易共花费 %d 铜,%d 元宝", otherName, oldMoney - Player:GetMoney(), oldYuanBao - nowYuanBao))
        else
          JBYB_SetHMDCache(otherName)
        end
        for i = 1, 5 do
          Bag:UseItemByName("元宝票", 2000)
        end
      else
        PushColorMsg("%s:玩家在黑名单中,拒绝交易", otherName)
        CloseWindow("Exchange")
      end
    elseif Exchange_IsInList() then
      GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env});MainMenuBar_Exchange_Clicked();")
      Sleep(800)
    else
      Bag:UseItemByName("元宝票", 500)
      JBYB_CheckMoney()
      if m_param.sceneID >= 0 and m_param.x > 0 and m_param.y > 0 then
        GoToScene(m_param.x, m_param.y, m_param.sceneID)
        ChangeSceneLine(true)
        Dismount(1000)
        Pet:Relax(600)
      end
    end
    if m_param.min_money > 0 and Player:GetMoney() + Bank_GetBankMoney() <= m_param.min_money then
      PushColorMsg("金币不足,结束！")
      break
    end
    Sleep(1000)
    DebugStr(m_script_name)
  end
  CloseWindow("Exchange")
  for i = 1, 5 do
    Bag:UseItemByName("元宝票", 2000)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
