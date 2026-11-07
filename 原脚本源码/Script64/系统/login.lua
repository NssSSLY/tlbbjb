-- 反编译自 dfz64.dll 内嵌字节码 0053c654（unluac 2025-12-23；仅供分析）
local m_scriptName = "自动登录"
local m_param
local m_network_line = -1
local m_stop = false
local m_over = false
local m_update = false
local m_kaifu_tick = -1

local function loginGetServerInfo(server_name)
  local strText = fmt([[
        local server_name ="%s"
        local area_index = -1
        local svr_index = -1
        local svr_state = -1
        local iCurAreaCount = GameProduceLogin:GetServerAreaCount()
        for index = 0, iCurAreaCount - 1 do
            local iLoginServerCount = GameProduceLogin:GetAreaLoginServerCount(index)
            local bFind = false
            for i = 0, iLoginServerCount - 1 do
                local ServerName, iServerStatus, iLevel, iServerIsNew, lastNetProvider, iServerPrizeLevel, iServerVersion = GameProduceLogin:GetAreaLoginServerInfo(index, i)
                if ServerName == server_name then
                    area_index = index
                    svr_index = i
                    svr_state = iServerStatus
                    bFind = true
                    break
                end
            end
            if bFind then break end
        end
        return area_index, svr_index, svr_state
    ]], server_name)
  return GetLuaValue(strText, "nnn")
end

local function loginGetSelectBetterText()
  local dolua = "setmetatable(_G, {__index=SelectBetterServer_Env});local szText = '' if this:IsVisible() then szText = SelectBetterServer_InfoWindow:GetText() end;return szText;"
  local strMsg = GetLuaValue(dolua, "s")
  return strMsg
end

local function loginGetNewSelectBetterText()
  local dolua = "setmetatable(_G, {__index = NewSelectBetterServer_Env});local szText = '' if this:IsVisible() then szText = NewSelectBetterServer_InfoWindow:GetText() end;return szText;"
  local strMsg = GetLuaValue(dolua, "s")
  return strMsg
end

local function loginExitToSelectServer()
  GetLuaValue("setmetatable(_G, {__index=LoginSelectServerQuest_Env});if this:IsVisible() then SelectServerQuest_Bn1Click(); end")
  Sleep(500)
  GetLuaValue("setmetatable(_G, {__index=LoginLogOn_Env});LogOn_ExitToSelectServer();")
  Sleep(1000)
end

local function loginGetKeyPos(key)
  local row = string.sub(key, 1, 1)
  local col = string.sub(key, 2, 2)
  local column = tonumber(col)
  local nrow = -1
  if "a" == row then
    nrow = 0
  elseif "b" == row then
    nrow = 1
  elseif "c" == row then
    nrow = 2
  elseif "d" == row then
    nrow = 3
  elseif "e" == row then
    nrow = 4
  elseif "f" == row then
    nrow = 5
  elseif "g" == row then
    nrow = 6
  end
  local val_pos = -1
  if -1 ~= nrow and type(column) == "number" then
    val_pos = nrow * 7 + column
    val_pos = val_pos * 2
  end
  if val_pos > 98 then
    val_pos = -1
    PushDebugMessage("索引计算错误:" .. key)
  end
  return val_pos
end

local function loginSetLoginInfo()
end

local function loginInputAccount(account, password)
  DoSystem(6001, account, password)
end

local function loginCanLoginGame()
  local bNeedUpdateGame, mustLogin, kaifu = ipc_zk_CanLoginGame(m_param.game_path, m_param.server_name)
  return bNeedUpdateGame, mustLogin, kaifu
end

local function loginCanLoadLunch(aKaifu)
  local canLoad, _, kaifu = DoSystem(6003, aKaifu, m_param.server_name)
  return canLoad, _, kaifu
end

local function loginAccountLimit(id)
end

local function loginSetStatus(status)
end

local function loginSleepCallBack()
  loginSetStatus(10)
  return true
end

local function loginOver()
  Sleep(2000)
  local pid = GetCurrentProcessId()
  local strPath = g_public_dir .. "上号设置\\登录配置.ini"
  local strFile = ReadConfigText(pid, "账号文件", strPath)
  local strIndex = ReadConfigText(pid, "账号索引", strPath)
  local strName = Player:GetName()
  local strPath = g_public_dir .. "账号文件\\" .. strFile .. ".ini"
  IniConfigSet("角色名", strName, nil, strIndex, strPath)
  local bChange = 0
  local bZxh = 0
  local strPath = g_public_dir .. "config.ini"
  local change_name = ReadConfigText("Soft_Config", "xzk1", strPath)
  if "1" == change_name then
    bChange = 1
  end
  local zxx = ReadConfigText("Soft_Config", "xzk11", strPath)
  if "1" == zxx then
    bZxh = 1
  end
  DoSystem(6006, bZxh, bChange)
end

local function loginWaitForLoad()
  for i = 1, 10 do
    local canLoad, _, _ = loginCanLoadLunch(0)
    if 1 == canLoad then
      if IsWindowVisible("LoginSelectServerQuest") then
        local strMsg = LoginGetSelectServerText()
        if string.find(strMsg, "正在更新服务器列表……", nil, true) then
          DebugStr("正在刷新服务器列表", 3)
        else
          GetLuaValue("GameProduceLogin:LoadLaunch();")
          Sleep(4000)
          break
        end
      else
        GetLuaValue("GameProduceLogin:LoadLaunch();")
        Sleep(4000)
        break
      end
    else
      DebugStr("等待刷新服务器列表", 2)
    end
    Sleep(1000)
  end
end

local function OnSelectServer()
  local strMsg = LoginGetSelectServerText()
  if string.find(strMsg, "确定进行更新时，将自动关闭", nil, true) then
    PushDebugMessage("游戏需要更新！")
    Sleep(5000)
    m_stop = true
    loginSetStatus(0)
    ClosePathGameProcess()
    QuitGame()
    return
  end
  local network_line = m_param.network_line
  if -1 ~= m_network_line then
    PushDebugMessage("登录过于频繁,将自动切换线路进行登录")
    if m_network_line > 3 then
      m_network_line = 0
    end
    network_line = m_network_line
  end
  local area_index, svr_index, svr_state = loginGetServerInfo(m_param.server_name)
  if -1 ~= svr_index then
    if 4 ~= svr_state then
      m_update = false
    elseif -1 ~= m_kaifu_tick and GetTickCount() - m_kaifu_tick < 90000 then
      m_update = false
      PushColorMsg("已经开服！！！")
    else
      m_update = true
      loginWaitForLoad()
      DebugStr("服务器维护中", 2)
    end
    local dolua = fmt("GameProduceLogin:SelectLoginServer(%d, %d, %d)", area_index, svr_index, network_line)
    GetLuaValue(dolua)
  else
    DebugStr("找不到:" .. m_param.server_name .. ",自动刷新服务器列表", 2)
    loginWaitForLoad()
  end
  Sleep(300)
end

local function loginExitToSelectServerAndLoadLaunch()
  loginExitToSelectServer()
  Sleep(1000)
  if IsWindowVisible("LoginSelectServer") then
    PushDebugMessage("刷新服务器列表")
    loginWaitForLoad()
  end
end

local function loginZMWait()
  local strPath = g_public_dir .. "config.ini"
  local state = ReadConfigText("Soft_Config", "xzk12", strPath)
  if "1" == state then
    DebugStr("登录停留...", 2)
    return true
  end
  return false
end

local function OnInputAccount()
  if IsWindowVisible("Agreement", "Agreement_Accept()") then
    Sleep(2000)
  end
  if loginZMWait() then
    Sleep(1000)
    return
  end
  if IsWindowVisible("OnlyChangyoujia_Logon", "OnlyChangyoujia_Logon_CloseButton_Clicked()") or IsWindowVisible("OnlyTieshen_Logon", "OnlyTieshen_Logon_CloseButton_Clicked()") or IsWindowVisible("ChangyoujiaTieshen_Logon", "ChangyoujiaTieshen_Logon_CloseButton_Clicked()") then
    Sleep(2000)
    PushDebugMessage("账号可能卡在线上")
    loginExitToSelectServerAndLoadLaunch()
    return
  end
  if IsWindowVisible("TextValidate") then
    PushDebugMessage("等待数字验证")
    Sleep(2000)
    return
  elseif IsWindowVisible("ShiWaiCYJ1") then
    DebugStr("等待世外龙园验证", 2)
    Sleep(10000)
    return
  end
  if IsWindowVisible("FangChenMi") then
    GetLuaValue("setmetatable(_G, {__index = FangChenMi_Env});FangChenMi_Accept_Clicked();")
    Sleep(1500)
    return
  end
  local strText = loginGetSelectBetterText()
  if string.find(strText, "排队人数也已达上限", nil, true) then
    m_network_line = -1
    GetLuaValue("setmetatable(_G, {__index=SelectBetterServer_Env});if this:IsVisible() then SelectBetterServer_QuitClick() PushDebugMessage('排队人数上限,等待20秒后再次登录') end;")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index=OtherQuest_Env});if this:IsVisible() then OtherQuest__Ok_Clicked() end;")
    local nSleep = 17000
    SleepCallBack(nSleep, 2000, loginSleepCallBack)
    loginExitToSelectServer()
    return
  elseif string.find(strText, "您被排在", nil, true) then
    m_network_line = -1
    DebugStr("正在排队", 2)
    return
  end
  local strText = loginGetNewSelectBetterText()
  if string.find(strText, "您被排在", nil, true) then
    m_network_line = -1
    DebugStr("排队中", 2)
    return
  end
  local dolua = "setmetatable(_G, {__index=OnlyChangyoujia_Logon_Env});if this:IsVisible() then OnlyChangyoujia_Logon_CloseButton_Clicked(); return 1 end return 0;"
  if GetLuaValue(dolua, "b") then
    PushDebugMessage("等待20秒")
    SleepCallBack(20000, 2000, loginSleepCallBack)
  end
  local strMsg = LoginGetSelectServerText()
  if string.find(strMsg, "账号停权", nil, true) then
    loginAccountLimit(m_param.account_id)
    m_stop = true
    OffLine(true, "停权")
    return
  elseif string.find(strMsg, "客户端版本与服务器端不同", nil, true) then
    loginSetStatus(0)
    m_stop = true
    QuitGame()
    return
  elseif string.find(strMsg, "有对应角色在线", nil, true) then
    PushDebugMessage("有对应角色在线，账号可能卡在线上,等待16秒")
    SleepCallBack(17000, 2000, loginSleepCallBack)
    loginExitToSelectServerAndLoadLaunch()
  elseif string.find(strMsg, "官方将保护您的账号", nil, true) then
    PushDebugMessage("暂时在保护时间")
    SleepCallBack(15000, 2000, loginSleepCallBack)
    loginExitToSelectServer()
  elseif string.find(strMsg, "您登录过于频繁", nil, true) then
    local oldTime = os.time()
    loginExitToSelectServerAndLoadLaunch()
    local sec = SubString(strMsg, "请在", "秒之后")
    sec = tonumber(sec) or 15
    if not sec then
      goto lbl_456
    end
    if sec > 600000 then
      m_network_line = m_network_line + 1
      local line = m_network_line
      if line > 3 then
        line = 0
      end
      PushDebugMessage("切换线路" .. line .. " " .. sec)
      Sleep(2000)
    else
      while sec > os.time() - oldTime do
        Sleep(1000)
        DebugStr("登录频繁,等待%s秒剩余%s秒,最长30秒后再次尝试登录 " .. m_param.account_name, 1, sec, sec - (os.time() - oldTime))
        if os.time() - oldTime > 30 then
          break
        end
      end
    end
    Sleep(1000)
  elseif string.find(strMsg, "连接失败", nil, true) then
    loginExitToSelectServerAndLoadLaunch()
    return
  elseif string.find(strMsg, "登录失败", nil, true) then
    loginExitToSelectServer()
    return
  elseif string.find(strMsg, "连接服务器超时", nil, true) then
    loginExitToSelectServerAndLoadLaunch()
  elseif string.find(strMsg, "在其它服务器登录", nil, true) then
    loginExitToSelectServer()
    return
  elseif string.find(strMsg, "服务器处于维护状态", nil, true) then
    m_update = true
    loginExitToSelectServer()
  elseif string.find(strMsg, "已达到上限请稍后登录", nil, true) then
    loginExitToSelectServer()
    return
  elseif string.find(strMsg, "正在验证密码") then
    local strMsg2 = ""
    local nTick = GetTickCount()
    while true do
      Sleep(100)
      strMsg2 = LoginGetSelectServerText()
      if not string.find(strMsg2, "正在验证密码", nil, true) then
        break
      end
      DebugStr("验证密码.", 2)
      if GetTickCount() - nTick > 30000 then
        break
      end
    end
    if string.find(strMsg2, "正在验证密码", nil, true) then
      loginExitToSelectServer()
      return
    end
  end
  ::lbl_456::
  if "" ~= strMsg then
    DebugStr("等待登录" .. strMsg, 3)
    return
  end
  if not IsWindowVisible("LoginLogOn") then
    return
  end
  if IsWindowVisible("Pswprotect") then
    local mibao = m_param.mibao
    local key1 = GetLuaValue("setmetatable(_G, {__index = Pswprotect_Env});local key1 = GameProduceLogin:GetMiBaoKey(0);return key1;", "s")
    local key2 = GetLuaValue("setmetatable(_G, {__index = Pswprotect_Env});local key1 = GameProduceLogin:GetMiBaoKey(1);return key1;", "s")
    local key3 = GetLuaValue("setmetatable(_G, {__index = Pswprotect_Env});local key1 = GameProduceLogin:GetMiBaoKey(2);return key1;", "s")
    if 98 ~= #mibao or "" == key1 or "" == key2 or "" == key3 then
      GetLuaValue("setmetatable(_G, {__index = Pswprotect_Env});MiBao_Click_Cancel();")
      Sleep(1000)
      loginExitToSelectServer()
      return
    end
    local pos1 = loginGetKeyPos(key1)
    local pos2 = loginGetKeyPos(key2)
    local pos3 = loginGetKeyPos(key3)
    if pos1 > 0 and pos2 > 0 and pos3 > 0 then
      local val1 = string.sub(mibao, pos1 - 1, pos1)
      local val2 = string.sub(mibao, pos2 - 1, pos2)
      local val3 = string.sub(mibao, pos3 - 1, pos3)
      local strText = [[
                setmetatable(_G, {__index = Pswprotect_Env});
                if this:IsVisible() then 
                    GameProduceLogin:SetMiBaoValue(0,'%s');
                    GameProduceLogin:SetMiBaoValue(1,'%s');
                    GameProduceLogin:SetMiBaoValue(2,'%s');
                    GameProduceLogin:SendMiBaoCheckAccount();
                    this:Hide();
                end
                ]]
      strText = fmt(strText, val1, val2, val3)
      GetLuaValue(strText)
      Sleep(500)
    end
    return
  end
  local dolua = "setmetatable(_G, {__index = LoginLogOn_Env});LogOn_TraditionLogon_MouseDown();"
  if 7 ~= m_param.houzhui_index then
    dolua = dolua .. "LogOn_Region:SetCurrentSelect(" .. m_param.houzhui_index .. ");"
  end
  GetLuaValue(dolua)
  Sleep(100)
  if 7 == m_param.houzhui_index then
    GetLuaValue("setmetatable(_G, {__index = LoginLogOn_Env});LogOn_LogonMailID_Active();")
  else
    GetLuaValue("setmetatable(_G, {__index = LoginLogOn_Env});LogOn_LogonID_Active();")
  end
  Sleep(100)
  loginInputAccount(m_param.account_name, m_param.password)
  Sleep(100)
  if 98 ~= #m_param.mibao then
    GetLuaValue("setmetatable(_G, {__index = LoginLogOn_Env});LogOn_PassWord_Protect_Check:SetCheck(0);")
  else
    GetLuaValue("setmetatable(_G, {__index = LoginLogOn_Env});LogOn_PassWord_Protect_Check:SetCheck(1);")
  end
  Sleep(100)
  if 1 == m_param.login_page_zm then
    m_over = true
  else
    local tickOut = GetTickCount()
    while m_update and IsWindowVisible("LoginLogOn") do
      local bNeedUpdateGame, mustLogin, kaifu = loginCanLoginGame()
      if 1 == kaifu then
        PushColorMsg("已开服！")
        m_kaifu_tick = GetTickCount()
        break
      end
      if 1 == bNeedUpdateGame then
        for i = 1, 10 do
          PushColorMsg("游戏客户端需要更新,10秒后自动关闭此客户端")
          Sleep(1000)
        end
        loginSetStatus(0)
        m_stop = true
        QuitGame()
        break
      end
      if 1 == mustLogin then
        DebugStr("维护中,您已设置强制登录,可能会被读秒", 2)
        break
      end
      Sleep(300)
      DebugStr("服务器维护中,维护完毕后自动进入")
      if GetTickCount() - tickOut > 600000 then
      end
    end
    GetLuaValue("setmetatable(_G, {__index = LoginLogOn_Env});LogOn_CheckAccount();")
    Sleep(800)
  end
end

local function OnCreateRole()
  if 0 == m_param.create_role then
    PushDebugMessage("等待手动创建角色")
    Sleep(1000)
    return
  end
  if IsWindowVisible("LoginSelectServerQuest") then
    PushDebugMessage("等待...")
    local strMsg = LoginGetSelectServerText()
    if string.find(strMsg, "您被排在", nil, true) then
      DebugStr("角色创建：正在排队", 2)
      Sleep(4000)
    elseif string.find(strMsg, "连接失败", nil, true) or string.find(strMsg, "登录失败", nil, true) or string.find(strMsg, "连接服务器超时", nil, true) or string.find(strMsg, "已达到上限请稍后登录", nil, true) then
      PushDebugMessage("什么？")
      Sleep(4000)
    elseif string.find(strMsg, "准备进入游戏", nil, true) then
      PushDebugMessage("即将进入游戏")
    end
    Sleep(2000)
    return
  end
  local player_name = m_param.create_name
  if "" == player_name then
    player_name = DoSystem(6004)
  end
  math.randomseed(GetTickCount())
  local sex = math.random(0, 1)
  if 1 == m_param.create_sex then
    sex = 1
  elseif 2 == m_param.create_sex then
    sex = 0
  end
  local face = math.random(0, 14)
  local face_model = math.random(0, 2)
  local role_equip = math.random(0, 2)
  local hair_model = math.random(0, 2)
  GetLuaValue("GameProduceLogin:ChangeNewRoleEquipSet(" .. sex .. ", " .. role_equip .. ");")
  GetLuaValue("GameProduceLogin:SetHairModelId(" .. sex .. ", " .. hair_model .. ");")
  GetLuaValue("GameProduceLogin:SetFaceModelId(" .. sex .. ", " .. face_model .. ");")
  GetLuaValue("GameProduceLogin:SetFaceId(" .. sex .. ", " .. face .. ");")
  GetLuaValue("GameProduceLogin:CreateRole('" .. player_name .. "', " .. sex .. ",-1,-1);")
  Sleep(3000)
end

local function OnSelectRole()
  if IsWindowVisible("LoginOverTime", "LoginOverTime_Bn1Click()") then
    PushDebugMessage("登录连接超时")
    Sleep(8000)
    return
  end
  local strMsg = loginGetSelectBetterText()
  if string.find(strMsg, "排队人数也已达上限", nil, true) then
    PushDebugMessage("角色选择页面：上限")
    Sleep(6000)
  elseif string.find(strMsg, "您被排在", nil, true) then
    PushDebugMessage("角色选择页面：排队")
    CloseWindow("TextValidate")
    Sleep(6000)
    return
  end
  if IsWindowVisible("LoginSelectServerQuest") then
    local strMsg = LoginGetSelectServerText()
    if string.find(strMsg, "您被排在", nil, true) then
      DebugStr("角色选择页面：正在排队", 2)
      CloseWindow("TextValidate")
      Sleep(6000)
      return
    elseif string.find(strMsg, "连接失败", nil, true) or string.find(strMsg, "登录失败", nil, true) or string.find(strMsg, "连接服务器超时", nil, true) or string.find(strMsg, "已达到上限请稍后登录", nil, true) then
      CloseWindow("TextValidate")
      GetLuaValue("setmetatable(_G, {__index=LoginSelectServerQuest_Env});if this:IsVisible() then SelectServerQuest_Bn1Click(); end")
      Sleep(6000)
    elseif string.find(strMsg, "准备进入游戏", nil, true) then
      PushDebugMessage("即将进入游戏")
      Sleep(1000)
      return
    end
  end
  if IsWindowVisible("TextValidate") then
    SleepCallBack(15000, 2000, loginSleepCallBack)
    CloseWindow("TextValidate")
    return
  end
  local role_cnt = GetLuaValue("setmetatable(_G, {__index = LoginSelectRole_Env});local nCnt = GameProduceLogin:GetRoleCount(); return nCnt;", "n")
  if 0 == role_cnt then
    OnCreateRole()
    return
  end
  math.randomseed(GetTickCount())
  local idx = math.random(0, 2)
  local dolua = "setmetatable(_G, {__index=LogonList_Env});if this:IsVisible() then GameProduceLogin:EnterNewRoleScene_New(%d, %d);this:Hide();return 1 end return 0;"
  dolua = fmt(dolua, m_param.role_pos, idx)
  local ret = GetLuaValue(dolua, "n")
  if 0 == ret then
    GetLuaValue("setmetatable(_G, {__index = LoginSelectRole_Env});SelectRole_DoubleClicked(" .. m_param.role_pos .. ");")
    Sleep(2000)
  end
end

local function Login_GetConfig()
  m_param = {}
  m_param.network_line = -1
  m_param.login_page_zm = 0
  m_param.login_page_role = 0
  local strPath = g_public_dir .. "上号设置\\登录配置.ini"
  local pid = GetCurrentProcessId()
  if IsProcess64() then
    m_param.game_path = DoSystem(9) .. "bin64\\game.exe"
  else
    m_param.game_path = DoSystem(9) .. "bin\\game.exe"
  end
  m_param.server_name = ReadConfigText(pid, "服务器", strPath)
  m_param.account_name = ReadConfigText(pid, "账号", strPath)
  m_param.password = ReadConfigText(pid, "密码", strPath)
  m_param.mibao = ReadConfigText(pid, "密保卡", strPath)
  local strHouZhui = ReadConfigText(pid, "后缀", strPath)
  local strRolePos = ReadConfigText(pid, "角色位置", strPath)
  m_param.houzhui_index = tonumber(strHouZhui)
  m_param.role_pos = tonumber(strRolePos)
  local strPath = g_public_dir .. "上号设置\\登录配置.ini"
  ReadConfigText(pid, "账号文件", strPath)
  ReadConfigText(pid, "账号索引", strPath)
  ReadConfigText(pid, "登录方式", strPath)
  if m_param.server_name == "" then
    return false
  end
  if m_param.account_name == "" then
    return false
  end
  if m_param.password == "" then
    return false
  end
  if not m_param.role_pos then
    return false
  end
  if not m_param.houzhui_index then
    return false
  end
  local strPath = g_public_dir .. "账号文件\\" .. m_param.account_name .. m_param.houzhui_index .. ".config"
  local strText = ReadConfigText(m_param.server_name .. m_param.role_pos, "练级等级", strPath)
  if "" == strText then
    m_param.create_role = 0
  else
    m_param.create_role = 1
    m_param.create_name = ReadConfigText(m_param.server_name .. m_param.role_pos, "角色名称", strPath)
    local strSex = ReadConfigText(m_param.server_name .. m_param.role_pos, "角色性别", strPath)
    if "男" == strSex then
      m_param.create_sex = 1
    elseif "女" == strSex then
      m_param.create_sex = 0
    end
  end
  return true
end

function _SMain()
  if false == Login_GetConfig() then
    return
  end
  while true do
    local note = ""
    if false == m_stop then
      loginSetStatus(10)
    end
    loginSetLoginInfo()
    if false == IsWindowVisible("bg_info") then
      if IsWindowVisible("LoginSelectServer") then
        if m_param.server_name == "龙门镖局" then
          m_param.server_name = "龙腾天下"
        end
        OnSelectServer()
      elseif IsWindowVisible("LoginLogOn") then
        OnInputAccount()
      elseif IsWindowVisible("LoginSelectRole") then
        if 1 == m_param.login_page_role then
          m_over = true
        else
          OnSelectRole()
        end
      elseif IsWindowVisible("LoginCreateRole") then
        OnCreateRole()
      elseif IsWindowVisible("PlayerFrame") then
        LogMsg("自动登录：已进入游戏")
        break
      else
        PushDebugMessage("未知页面...")
      end
    end
    if m_over then
      LogMsg("自动登录：已登录到指定页面")
      break
    end
    Sleep(500)
    DebugStr("自动登陆中" .. note)
  end
  CloseWindow("LogonList")
  PushDebugMessage("登陆完成！")
  if false == m_stop then
    loginSetStatus(1)
    if false == m_over then
      loginOver()
    end
  end
end

_SMain()
