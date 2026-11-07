-- 反编译自 dfz64.dll 内嵌字节码 0046c580（unluac 2025-12-23；仅供分析）
local m_script_name = "老板接收交易"
ScriptOnStart(m_script_name, false, false)
g_config.lbjsjy = {}
g_config.lbjsjy.boss_x = ReadConfigInt("ZH", "bjk87")
g_config.lbjsjy.boss_y = ReadConfigInt("ZH", "bjk82")
g_config.lbjsjy.boss_sceneName = ReadConfigText("ZH", "bjk88")
g_config.lbjsjy.max_money = ReadConfigInt("ZH", "bjk111")
g_config.lbjsjy.max_money_todo = GetConfigCommbox("交易", "爆金处理")
g_config.lbjsjy.full_daoju = ReadConfigBool("ZH", "xzk139")
g_config.lbjsjy.full_cailiao = ReadConfigBool("ZH", "xzk147")
g_config.lbjsjy.min_space_daoju = ReadConfigInt("ZH", "bjk99")
g_config.lbjsjy.min_space_cailiao = ReadConfigInt("ZH", "bjk100")
g_config.lbjsjy.runScript = ReadConfigText("ZH", "bjk112")
g_config.lbjsjy.global_timeout = ReadConfigInt("ZH", "bjk109")
local m_param = {}
m_param.boss_x = HandleTextToNumber(g_config.lbjsjy.boss_x, 0)
m_param.boss_y = HandleTextToNumber(g_config.lbjsjy.boss_y, 0)
m_param.boss_sceneName = g_config.lbjsjy.boss_sceneName
m_param.max_money = HandleTextToNumber(g_config.lbjsjy.max_money, 8000)
m_param.max_money_todo = g_config.lbjsjy.max_money_todo.sel
m_param.full_daoju = g_config.lbjsjy.full_daoju
m_param.full_cailiao = g_config.lbjsjy.full_cailiao
m_param.min_space_daoju = HandleTextToNumber(g_config.lbjsjy.min_space_daoju, 5)
m_param.min_space_cailiao = HandleTextToNumber(g_config.lbjsjy.min_space_cailiao, 5)
m_param.runScript = g_config.lbjsjy.runScript
m_param.global_timeout = HandleTextToNumber(g_config.lbjsjy.global_timeout, 60)
m_param.boss_sceneID = -1

function _SMain(...)
  LoadScript("jiaoyi")
  Bag_DeleteItem(false)
  m_param.boss_sceneID = GetSceneIDByName(m_param.boss_sceneName)
  if m_param.boss_sceneID < 0 or m_param.boss_x <= 0 or m_param.boss_y <= 0 then
    PushColorMsg(m_script_name .. "：老板地图坐标设置有误！")
    return
  end
  local start_tick = GetTickCount()
  while true do
    if IsWindowVisible("Exchange") then
      local otherName = GetLuaValue("return Exchange:GetOthersName()", "s")
      if Exchange_IsHeiMingDan(otherName) == false then
        PushColorMsg("老板：接收到 %s 的交易请求", otherName)
        local nStartTick = GetTickCount()
        while IsWindowVisible("Exchange") do
          if GetTickCount() - nStartTick > 30000 then
            PushColorMsg("老板：%s 交易超时", otherName)
            CloseWindow("Exchange")
            break
          end
          if Exchange_IsLocked("other") and Exchange_IsLocked("self") then
            local nSelfMoney = Exchange_GetMoney("self")
            local nSelfItem = GetLuaValue("return GetActionNum('ex_self');", "n")
            if nSelfMoney > 0 or nSelfItem > 0 then
              PushColorMsg("老板：自己的交易栏有物品或金币,取消交易")
              CloseWindow("Exchange")
              break
            end
            local nOtherMoney = Exchange_GetMoney("other")
            if nOtherMoney > 0 and false == Exchange_checkMaxMoney() then
              PushColorMsg(m_script_name .. ":交易后金币将已经上限")
              if 0 ~= m_param.max_money_todo then
                CloseWindow("Exchange")
                break
              end
            end
            GetLuaValue("Exchange:AcceptExchange()")
            Sleep(500)
            local nTick1 = GetTickCount()
            while IsWindowVisible("Exchange") and Exchange_IsLocked("other") and Exchange_IsLocked("self") do
              Sleep(500)
              if GetTickCount() - nTick1 > 8000 then
                PushDebugMessage(m_script_name .. ":对方超过8秒没有确定交易！")
                CloseWindow("Exchange")
                break
              end
            end
          elseif Exchange_IsLocked("other") then
            PushDebugMessage(m_script_name .. "：对方已锁定交易")
            Sleep(1000)
            Exchange_LockExchange()
            Sleep(1500)
          end
          Sleep(500)
          DebugStr("交易中")
        end
      else
        PushColorMsg("%s:玩家在黑名单中,拒绝交易", otherName)
        CloseWindow("Exchange")
      end
    elseif Exchange_IsInList() then
      GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env});MainMenuBar_Exchange_Clicked();")
      Sleep(1000)
    else
      GoToScene(m_param.boss_x, m_param.boss_y, m_param.boss_sceneID, 5)
      ChangeSceneLine(true)
      Bag:PackUp(-1)
    end
    for i = 1, 5 do
      CloseWindow("BigBank")
      CloseWindow("Shop")
      Bag:UseItemByName("元宝票", 2000)
    end
    local bCheckBankFull = false
    if m_param.full_daoju and Bag:GetSpaceNum(0) <= m_param.min_space_daoju then
      PushColorMsg("老板：道具栏空格不足,执行设置脚本！")
      ScriptExecScript(m_param.runScript, m_script_name)
      bCheckBankFull = true
      Sleep(3000)
      CloseAllWindow()
    end
    if m_param.full_cailiao and Bag:GetSpaceNum(1) <= m_param.min_space_cailiao then
      PushColorMsg("老板：材料栏空格不足,执行设置脚本！")
      ScriptExecScript(m_param.runScript, m_script_name)
      bCheckBankFull = true
      Sleep(3000)
      CloseAllWindow()
    end
    if bCheckBankFull then
    end
    if 1 == m_param.max_money_todo and Player:GetMoney() + Bank_GetBankMoney() >= m_param.max_money * 10000 then
      LogMsg(m_script_name .. ":金币达到 %s J,结束", m_param.max_money)
      break
    end
    if m_param.global_timeout > 0 and GetTickCount() - start_tick > m_param.global_timeout * 60 * 1000 then
      PushColorMsg(m_script_name .. "：执行超时！")
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
