-- 反编译自 dfz64.dll 内嵌字节码 0046049c（unluac 2025-12-23；仅供分析）
local m_script_name = "交易给老板号"
ScriptOnStart(m_script_name, false, false)
g_config.jyglbh = {}
g_config.jyglbh.jinbi = ReadConfigBool("ZH", "xzk210")
g_config.jyglbh.keep_jinbi = ReadConfigInt("ZH", "bjk85")
g_config.jyglbh.yuanbao = ReadConfigBool("ZH", "xzk72")
g_config.jyglbh.keep_yuanbao = ReadConfigInt("ZH", "bjk89")
g_config.jyglbh.all_znt = ReadConfigBool("ZH", "xzk128")
g_config.jyglbh.all_baoshi = ReadConfigBool("ZH", "xzk140")
g_config.jyglbh.all_zst = ReadConfigBool("ZH", "xzk133")
g_config.jyglbh.list_item = ReadConfigBool("ZH", "xzk142")
g_config.jyglbh.only_bag = ReadConfigBool("ZH", "xzk138")
g_config.jyglbh.list_name = ReadConfigText("ZH", "bjk108")
g_config.jyglbh.boss_name = ReadConfigText("ZH", "bjk94")
g_config.jyglbh.boss_x = ReadConfigInt("ZH", "bjk87")
g_config.jyglbh.boss_y = ReadConfigInt("ZH", "bjk82")
g_config.jyglbh.boss_sceneName = ReadConfigText("ZH", "bjk88")
g_config.jyglbh.jyask_secdiff = ReadConfigInt("ZH", "bjk95")
g_config.jyglbh.global_timeout = ReadConfigInt("ZH", "bjk79")
g_config.jyglbh.waitboss_timeout = ReadConfigInt("ZH", "bjk80")
local m_param = {}
m_param.jinbi = g_config.jyglbh.jinbi
m_param.keep_jinbi = HandleTextToNumber(g_config.jyglbh.keep_jinbi, 0) * 10000
m_param.yuanbao = g_config.jyglbh.yuanbao
m_param.keep_yuanbao = HandleTextToNumber(g_config.jyglbh.keep_yuanbao, 0)
m_param.all_znt = g_config.jyglbh.all_znt
m_param.all_baoshi = g_config.jyglbh.all_baoshi
m_param.all_zst = g_config.jyglbh.all_zst
m_param.list_item = g_config.jyglbh.list_item
m_param.only_bag = g_config.jyglbh.only_bag
m_param.list_name = HandleText(g_config.jyglbh.list_name)
m_param.list_name = HandleText_AddFuHao(m_param.list_name, " ", true)
m_param.boss_name = HandleText_AddFuHao(g_config.jyglbh.boss_name, " ", true)
m_param.boss_x = HandleTextToNumber(g_config.jyglbh.boss_x, 0)
m_param.boss_y = HandleTextToNumber(g_config.jyglbh.boss_y, 0)
m_param.boss_sceneName = g_config.jyglbh.boss_sceneName
m_param.jyask_secdiff = HandleTextToNumber(g_config.jyglbh.jyask_secdiff, 0)
m_param.global_timeout = HandleTextToNumber(g_config.jyglbh.global_timeout, 30)
m_param.waitboss_timeout = HandleTextToNumber(g_config.jyglbh.waitboss_timeout, 5)
m_param.boss_sceneID = -1
m_param.all_name = ""
m_param.all_class = ""
m_param.from_bank = true

local function Exchange_GetName()
  local strName = ""
  local strClass = ""
  if m_param.list_item then
    strName = strName .. m_param.list_name
  end
  strName = HandleText_AddFuHao(strName, " ", true)
  if m_param.yuanbao then
    strName = strName .. "元宝票 "
  end
  strName = HandleText_AddFuHao(strName, " ", true)
  if m_param.all_znt then
    strName = strName .. "子女装备 "
    strClass = strClass .. "子女装备 "
  end
  strName = HandleText_AddFuHao(strName, " ", true)
  strClass = HandleText_AddFuHao(strClass, " ", true)
  if m_param.all_baoshi then
    strName = strName .. "所有宝石 "
    strClass = strClass .. "所有宝石 "
  end
  strName = HandleText_AddFuHao(strName, " ", true)
  strClass = HandleText_AddFuHao(strClass, " ", true)
  if m_param.all_zst then
    strName = strName .. "珍兽武器 珍兽面甲 珍兽项圈 珍兽体甲 珍兽护符 "
    strClass = strClass .. "珍兽武器 珍兽面甲 珍兽项圈 珍兽体甲 珍兽护符 "
  end
  strName = HandleText_AddFuHao(strName, " ", true)
  strClass = HandleText_AddFuHao(strClass, " ", true)
  return strName, strClass
end

local function Exchange_CheckBoss()
  local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
  if "" ~= otherName then
    if not string.find(m_param.boss_name, " " .. otherName .. " ", nil, true) then
      PushColorMsg("交易： %s 不在老板名单中,取消交易！", otherName)
      GetLuaValue("Exchange:ExchangeCancel();Exchange:CloseExchangeInfo();")
      Sleep(1000)
      CloseWindow("Exchange")
      return false
    end
  else
    CloseWindow("Exchange")
    return false
  end
  return true
end

local function Exchange_GetItem()
  local strName = m_param.all_name
  local tItem = {}
  local tBag = Bag:EnumAllObj()
  for i = 1, #tBag do
    local tmp = tBag[i]
    if 0 == tmp.bind and 0 == tmp.lock then
      if tmp.name ~= "" and string.find(strName, " " .. tmp.name .. " ", nil, true) then
        table.insert(tItem, tmp)
      elseif "" ~= tmp.class and string.find(strName, " " .. tmp.class .. " ", nil, true) then
        table.insert(tItem, tmp)
      elseif 5 == tmp.itemType and string.find(strName, " 所有宝石 ", nil, true) then
        table.insert(tItem, tmp)
      end
    end
  end
  return tItem
end

local function Exchange_Action()
  local nStartTick = GetTickCount()
  while IsWindowVisible("Exchange") do
    if GetTickCount() - nStartTick > 60000 then
      PushColorMsg(m_script_name .. "：交易超时")
      CloseWindow("Exchange")
      break
    end
    if Exchange_IsLocked("other") and Exchange_IsLocked("self") then
      if Exchange_CheckBoss() then
        GetLuaValue("Exchange:AcceptExchange()")
        Sleep(1000)
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
      if not Exchange_CheckBoss() then
        break
      end
      Sleep(2000)
    else
      local tExc = Exchange_GetItem()
      tExc = Exchange_DeleteLockItem(tExc)
      if 0 == #tExc and 0 == GetLuaValue("return GetActionNum('ex_self');", "n") then
        local bNext = false
        if m_param.jinbi then
          local nMoney = Player:GetMoney()
          local nBankMoney = Bank_GetBankMoney()
          local nJYMoney = nMoney + nBankMoney - m_param.keep_jinbi
          if nJYMoney > 0 then
            if nMoney < nJYMoney then
              nJYMoney = nMoney
            end
            if nJYMoney > 0 then
              bNext = true
              Exchange_InputMoney(nJYMoney)
              Sleep(700)
            end
          end
        end
        if false == bNext then
          CloseWindow("Exchange")
          break
        end
      else
        CloseWindow("BigBank")
        CloseWindow("Shop")
        if #tExc > 0 and GetLuaValue("return GetActionNum('ex_self');", "n") < 5 then
          local tmp = tExc[1]
          Bag:ItemBtnClicked(tmp.index)
        end
      end
      if Exchange_GetMoney("self") > 0 then
        Exchange_LockExchange()
      elseif 5 == GetLuaValue("return GetActionNum('ex_self');", "n") then
        Exchange_LockExchange()
      elseif 0 == #tExc and GetLuaValue("return GetActionNum('ex_self');", "n") > 0 then
        Exchange_LockExchange()
      end
    end
    Sleep(200)
    DebugStr("交易：正在交易物品...")
  end
end

local function Exchange_BankItem()
  local strName = m_param.all_name
  if not m_param.only_bag and m_param.from_bank then
    local nTakeCount = Bank_GetItem(strName, -1, 1, 1)
    Sleep(500)
    if 0 == nTakeCount then
      m_param.from_bank = false
    end
    CloseAllWindow()
  end
  if m_param.jinbi then
    local nBaoLiu = m_param.keep_jinbi
    if 0 == nBaoLiu then
      nBaoLiu = 1
    end
    if nBaoLiu < Bank_GetBankMoney() then
      Bank_GetMoney(nBaoLiu * -1)
      Sleep(1000)
    end
  end
end

local function Exchange_checkJinBi()
  if m_param.jinbi == false then
    return false
  end
  if Player:GetMoney() + Bank_GetBankMoney() <= m_param.keep_jinbi then
    return false
  end
  return true
end

local function Exchange_checkYuanBao()
  if m_param.yuanbao == false then
    return false
  end
  local nowYuanBao = Player:GetDataInt("YUANBAO")
  if 0 == nowYuanBao or nowYuanBao <= m_param.keep_yuanbao then
    return false
  end
  PushColorMsg(m_script_name .. "：前往钱庄兑换元宝票")
  GoToScene(65, 50, 224)
  local nYB = Player:GetDataInt("YUANBAO") - m_param.keep_yuanbao
  if nYB > 100000 then
    nYB = 100000
  end
  Player:YuanBaoToTicket(nYB)
  Sleep(1000)
  return true
end

function _SMain(...)
  LoadScript("jiaoyi")
  m_param.boss_name = string.gsub(m_param.boss_name, " " .. g_self.name .. " ", " ")
  if m_param.boss_name == "" then
    PushColorMsg(m_script_name .. ":您未设置老板名称")
    return
  end
  m_param.boss_sceneID = GetSceneIDByName(m_param.boss_sceneName)
  if m_param.boss_sceneID < 0 or m_param.boss_x <= 0 or m_param.boss_y <= 0 then
    PushColorMsg(m_script_name .. "：老板地图坐标设置有误！")
    return
  end
  if m_param.jyask_secdiff < 5 then
    m_param.jyask_secdiff = 5
  end
  m_param.all_name, m_param.all_class = Exchange_GetName()
  Bag_DeleteItem(false)
  local start_tick = GetTickCount()
  local lastTickSend = -1
  local lastTickFindBoss = -1
  while true do
    local tObj = Enum2XByName(m_param.boss_name, {
      0,
      0,
      1,
      0
    }, {0, -1}, 0, 3)
    if #tObj > 0 then
      lastTickFindBoss = -1
      if IsWindowVisible("Exchange") then
        if Exchange_CheckBoss() then
          Exchange_Action()
        end
      else
        GoToScene(tObj[1].x, tObj[1].y, GetSceneID())
        ChangeSceneLine(true)
        Sleep(500)
        if GetTickCount() - lastTickSend > m_param.jyask_secdiff * 1000 then
          lastTickSend = GetTickCount()
          SP_SendJiaoYiAsk(tObj[1].id)
        else
          DebugStr("等待发送交易,%d秒", 2, m_param.jyask_secdiff)
        end
      end
    else
      GoToScene(m_param.boss_x, m_param.boss_y, m_param.boss_sceneID)
      ChangeSceneLine(true)
      if -1 == lastTickFindBoss then
        lastTickFindBoss = GetTickCount()
      elseif m_param.waitboss_timeout > 0 and GetTickCount() - lastTickFindBoss > m_param.waitboss_timeout * 60 * 1000 then
        PushColorMsg(m_script_name .. ":%d分钟没有找到老板,结束！", m_param.waitboss_timeout)
        break
      end
    end
    local tExc = Exchange_GetItem()
    if 0 == #tExc then
      if not m_param.only_bag then
        TempBank2Bag(m_param.all_name, 1)
        Sleep(1000)
      end
      tExc = Exchange_GetItem()
      if 0 == #tExc then
        Exchange_BankItem()
        tExc = Exchange_GetItem()
        if 0 == #tExc and false == Exchange_checkYuanBao() and false == Exchange_checkJinBi() then
          PushColorMsg(m_script_name .. ":已经没有可交易物品")
          break
        end
      end
    end
    if m_param.global_timeout > 0 and GetTickCount() - start_tick > m_param.global_timeout * 60 * 1000 then
      PushColorMsg(m_script_name .. "：超时！")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseWindow("Exchange")
  Bag_Move2TempBank()
  MainBankSaveItem()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
