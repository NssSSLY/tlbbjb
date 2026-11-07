-- 反编译自 dfz64.dll 内嵌字节码 0049c027（unluac 2025-12-23；仅供分析）
if g_config == nil then
  g_config = {}
  g_config.tysz = {}
end
if nil == g_ConfigCrc32 then
  g_ConfigCrc32 = 0
end
g_runing_script = ""
g_json = CExec("json")
g_checkMibaoTime = GetTickCount() - 120000
g_public_dir = GetUserConfig("CONFIG_PATH")
g_client_type = GetUserConfig("CLIENT_TYPE")
LUOYANG_ID = 0
if 2 == g_client_type then
  LUOYANG_ID = 0
end
g_self = {
  isjingong = false,
  menpai = -1,
  name = "",
  guid = -1,
  level = 0
}
BAG_DAOJU_MAX = 99
BAG_CAILIAO_MIN = 100
BAG_CAILIAO_MAX = 199
BAG_RENWU_MIN = 200
BAG_RENWU_MAX = 219
g_MenPaiInfo = {
  {
    menpaiID = 0,
    typeID = 1,
    sceneID = 9,
    fubenSceneID = 182,
    xiaoSceneID = 173,
    menpaiName = "少林"
  },
  {
    menpaiID = 1,
    typeID = 2,
    sceneID = 11,
    fubenSceneID = 184,
    xiaoSceneID = 175,
    menpaiName = "明教"
  },
  {
    menpaiID = 2,
    typeID = 3,
    sceneID = 10,
    fubenSceneID = 183,
    xiaoSceneID = 174,
    menpaiName = "丐帮"
  },
  {
    menpaiID = 3,
    typeID = 4,
    sceneID = 12,
    fubenSceneID = 185,
    xiaoSceneID = 176,
    menpaiName = "武当"
  },
  {
    menpaiID = 4,
    typeID = 5,
    sceneID = 15,
    fubenSceneID = 188,
    xiaoSceneID = 179,
    menpaiName = "峨嵋"
  },
  {
    menpaiID = 5,
    typeID = 6,
    sceneID = 16,
    fubenSceneID = 189,
    xiaoSceneID = 180,
    menpaiName = "星宿"
  },
  {
    menpaiID = 6,
    typeID = 7,
    sceneID = 13,
    fubenSceneID = 186,
    xiaoSceneID = 177,
    menpaiName = "天龙"
  },
  {
    menpaiID = 7,
    typeID = 8,
    sceneID = 17,
    fubenSceneID = 190,
    xiaoSceneID = 181,
    menpaiName = "天山"
  },
  {
    menpaiID = 8,
    typeID = 9,
    sceneID = 14,
    fubenSceneID = 187,
    xiaoSceneID = 178,
    menpaiName = "逍遥"
  },
  {
    menpaiID = 9,
    typeID = 0,
    sceneID = -1,
    fubenSceneID = -1,
    xiaoSceneID = -1,
    menpaiName = "无门派"
  },
  {
    menpaiID = 10,
    typeID = 32,
    sceneID = 284,
    fubenSceneID = 289,
    xiaoSceneID = 288,
    menpaiName = "慕容"
  },
  {
    menpaiID = 11,
    typeID = 37,
    sceneID = 615,
    fubenSceneID = 616,
    xiaoSceneID = 618,
    menpaiName = "唐门"
  },
  {
    menpaiID = 12,
    typeID = 53,
    sceneID = 678,
    fubenSceneID = 680,
    xiaoSceneID = 681,
    menpaiName = "鬼谷"
  },
  {
    menpaiID = 13,
    typeID = 54,
    sceneID = 731,
    fubenSceneID = 741,
    xiaoSceneID = 742,
    menpaiName = "桃花岛"
  },
  {
    menpaiID = 14,
    typeID = 55,
    sceneID = 824,
    fubenSceneID = 828,
    xiaoSceneID = 829,
    menpaiName = "绝情谷"
  },
  {
    menpaiID = 15,
    typeID = 58,
    sceneID = 987,
    fubenSceneID = 989,
    xiaoSceneID = 1001,
    menpaiName = "恶人谷"
  }
}
local m_LastDebugMsgTime = {}
local m_LastGetWeekTime = {
  os.time() - 345600,
  os.time() - 345600
}

function IsNeiCe()
end

function ShowTipMsg(aMsg)
  if type(aMsg) ~= "string" or "" == aMsg then
    aMsg = "tip msg is null"
  end
  GetLuaValue("ShowSystemTipInfo([[" .. aMsg .. "]])")
end

function MessageBox(aMsg)
  ShowTipMsg(aMsg)
end

function fmt(aMsg, ...)
  local state, msg = pcall(string.format, aMsg, ...)
  if state then
    aMsg = msg
  elseif msg and "SP_ST" == msg then
    ShowTipMsg(aMsg)
  else
    aMsg = "fmt异常：" .. aMsg
    if msg then
      ShowTipMsg(aMsg .. " " .. msg .. (...))
    else
      ShowTipMsg(aMsg)
    end
  end
  return aMsg
end

function ReadFile(aFilePath)
  local fileText = ""
  local file = io.open(aFilePath, "r")
  if file then
    fileText = file:read("*a")
    io.close(file)
  end
  return fileText
end

function WriteFile(aFilePath, aStrText)
  local file = io.open(aFilePath, "w+")
  if file then
    file:write(aStrText)
    io.close(file)
  end
end

function LoadScript(aScriptName)
  local strName = string.gsub(aScriptName, ".lua", "")
  return CExec(strName)
end

function LoadUserPathScript(aScriptPath)
  local f, msg = loadfile(aScriptPath)
  if f then
    if pcall(f) then
      return true
    else
      PushColorMsg(aScriptPath .. " ：代码或语法有误，请检查!")
    end
  else
    ShowTipMsg(msg)
  end
  return false
end

function EncryptLuaText(aType, aText, aMiMa)
  aMiMa = aMiMa or ""
  return DoSystem(10, aType, aText, aMiMa)
end

function RunEncryptLuaText(aType, aText, aMiMa)
  aMiMa = aMiMa or ""
  DoSystem(11, aType, aText, aMiMa)
end

function GetSocket()
  return DoSystem(12)
end

function Utf8ToGb2312(aStr)
  return DoSystem(13, aStr)
end

function Gb2312ToUtf8(aStr)
  return DoSystem(14, aStr)
end

function RefreshGameTitle()
  DoSystem(15)
end

function IsHelpThread()
  return DoSystem(16, 3)
end

function IsFuScriptThread()
  return DoSystem(16, 4)
end

function SplitString(aStr, aSplit, aRemoveEmpty)
  if nil == aStr or "" == aStr then
    return {}
  end
  local t = {}
  local i = 1
  local pos = 0
  local nLen = #aSplit
  while true do
    pos = string.find(aStr, aSplit, i, true)
    if nil == pos then
      local szTemp = string.sub(aStr, i, #aStr)
      if szTemp and (not aRemoveEmpty or "" ~= szTemp) then
        t[#t + 1] = szTemp
      end
      break
    end
    local strSub = string.sub(aStr, i, pos - 1)
    if not aRemoveEmpty or "" ~= strSub then
      t[#t + 1] = strSub
    end
    i = pos + nLen
  end
  return t
end

function SubString(aStr, aBefore, aAfter)
  local before_start, before_end = string.find(aStr, aBefore, nil, true)
  local after_start, after_end = string.find(aStr, aAfter, before_end + 1, true)
  if before_end and after_start then
    return string.sub(aStr, before_end + 1, after_start - 1)
  end
  return ""
end

function GetNextDaySec()
  local tTim1 = os.date("*t")
  local tTim2 = os.date("*t")
  tTim2.day = tTim2.day + 1
  tTim2.hour = 0
  tTim2.min = 0
  tTim2.sec = 0
  local nTime1 = os.time(tTim1)
  local nTime2 = os.time(tTim2)
  local nDiff = os.difftime(nTime2, nTime1)
  return nDiff
end

function BubbleSort(tObj, attr, nCmp)
  nCmp = nCmp or 1
  local n = #tObj
  local k = n
  local flags = true
  while flags do
    flags = false
    for i = 1, k - 1 do
      if 2 == nCmp then
        if tObj[i][attr] < tObj[i + 1][attr] then
          tObj[i], tObj[i + 1] = tObj[i + 1], tObj[i]
          flags = true
        end
      elseif tObj[i][attr] > tObj[i + 1][attr] then
        tObj[i], tObj[i + 1] = tObj[i + 1], tObj[i]
        flags = true
      end
    end
    k = k - 1
  end
end

function BubbleByLevel(tObj, nCmp)
  nCmp = nCmp or 1
  BubbleSort(tObj, "level", nCmp)
end

function BubbleByDst(tObj, nCmp)
  nCmp = nCmp or 1
  BubbleSort(tObj, "dst", nCmp)
end

function BubbleByDist(tObj, nCmp)
  nCmp = nCmp or 1
  BubbleSort(tObj, "dist", nCmp)
end

function BubbleByHP(tObj, nCmp)
  nCmp = nCmp or 1
  BubbleSort(tObj, "hp", nCmp)
end

function FindTableChildString(tTable, aValue, mode)
  for i = 1, #tTable do
    if 1 == mode then
      if string.find(tTable[i], aValue, nil, true) then
        return true
      end
    elseif 2 == mode then
      if string.find(aValue, tTable[i], nil, true) then
        return true
      end
    elseif 3 == mode and string.find(tTable[i], " " .. aValue .. " ", nil, true) then
      return true
    end
  end
  return false
end

function GetTableChildString(tTable, field, tValue, mode)
  local tTarget = {}
  for i = 1, #tTable do
    if FindTableChildString(tValue, tTable[i][field], mode) then
      table.insert(tTarget, tTable[i])
    end
  end
  return tTarget
end

function FindTableFieldValue(tTable, field, value)
  for i = 1, #tTable do
    if tTable[i][field] == value then
      return true
    end
  end
  return false
end

function FindTableValue(tTable, value)
  for i = 1, #tTable do
    if tTable[i] == value then
      return true
    end
  end
  return false
end

function DeleteTableFieldValue(tTable, field, tValue)
  local tTarget = {}
  if nil == tTable then
    return tTarget
  end
  for i = 1, #tTable do
    if FindTableValue(tValue, tTable[i][field]) == false then
      table.insert(tTarget, tTable[i])
    end
  end
  return tTarget
end

function GetTableFieldValue(aTable, aField, atCmp)
  local tTarget = {}
  for i = 1, #aTable do
    if FindTableValue(atCmp, aTable[i][aField]) then
      table.insert(tTarget, aTable[i])
    end
  end
  return tTarget
end

function TableGetTable(aTable, tGet, field)
  local tTarget = {}
  if 0 == #tGet then
    return tTarget
  end
  for i = 1, #aTable do
    if FindTableFieldValue(tGet, field, aTable[i][field]) then
      table.insert(tTarget, aTable[i])
    end
  end
  return tTarget
end

function SetTableFieldValue(aTable, tValue, cmp_field, set_field)
  for i = 1, #aTable do
    for j = 1, #tValue do
      if aTable[i][cmp_field] == tValue[j][cmp_field] then
        aTable[i][set_field] = tValue[j][set_field]
        break
      end
    end
  end
end

function ArrayInsertTable(aTable, aArray)
  local bInsert = false
  for i = 1, #aArray do
    if FindTableValue(aTable, aArray[i]) == false then
      bInsert = true
      table.insert(aTable, aArray[i])
    end
  end
  return aTable, bInsert
end

function TableInsertTable(aTable, aField, tValue)
  local bInsert = false
  if FindTableFieldValue(aTable, aField, tValue[aField]) == false then
    bInsert = true
    table.insert(aTable, tValue)
  end
  return aTable, bInsert
end

function TableInsertTable_arr(aTable, field, tInsert)
  for j = 1, #tInsert do
    if FindTableFieldValue(aTable, field, tInsert[j][field]) == false then
      table.insert(aTable, tInsert[j])
    end
  end
  return aTable
end

function TableDeleteTable(aTable, aCmpTable, aField)
  local tTarget = {}
  if 0 == #aCmpTable then
    return aTable
  end
  for i = 1, #aTable do
    if not FindTableFieldValue(aCmpTable, aField, aTable[i][aField]) then
      table.insert(tTarget, aTable[i])
    end
  end
  return tTarget
end

function TableFieldCount(aTable, aField)
  aField = aField or "count"
  local nCount = 0
  for i = 1, #aTable do
    if type(aTable[i][aField]) == "number" then
      nCount = nCount + aTable[i][aField]
    end
  end
  return nCount
end

function TableNameFieldCount(aTable, aName, aField)
  aField = aField or "count"
  local nameField = "name"
  local nCount = 0
  for i = 1, #aTable do
    if aTable[i][nameField] == aName and type(aTable[i][aField]) == "number" then
      nCount = nCount + aTable[i][aField]
    end
  end
  return nCount
end

function Array2Text(tArr, split_text, field)
  if 0 == #tArr then
    return ""
  end
  split_text = split_text or " "
  local strText = split_text
  if nil == field then
    for i = 1, #tArr do
      strText = strText .. tArr[i] .. split_text
    end
  else
    for i = 1, #tArr do
      strText = strText .. tArr[i][field] .. split_text
    end
  end
  return strText
end

function Text2Table(strText, split_text, field)
  split_text = split_text or " "
  local tText = {}
  local allItem = SplitString(strText, split_text, true)
  for i = 1, #allItem do
    local strTemp = allItem[i]
    if strTemp then
      if nil == field then
        table.insert(tText, strTemp)
      else
        local tmp = {}
        tmp[field] = strTemp
        table.insert(tText, tmp)
      end
    end
  end
  return tText
end

function Text2Table_Int(strText, split_text, field)
  split_text = split_text or " "
  local tText = {}
  local allItem = SplitString(strText, split_text, true)
  for i = 1, #allItem do
    local strTemp = tonumber(allItem[i])
    if strTemp then
      if nil == field then
        table.insert(tText, strTemp)
      else
        local tmp = {}
        tmp[field] = strTemp
        table.insert(tText, tmp)
      end
    end
  end
  return tText
end

function FindObjByTID(aTid)
  if type(aTid) ~= "number" or aTid < 0 then
    return nil
  end
  local tObj = EnumEnvObj()
  for i = 1, #tObj do
    if tObj[i].id == aTid then
      return tObj[i]
    end
  end
  return nil
end

function PushMessage(aMsg, aColor, ...)
  local arg = {
    ...
  }
  if type(aMsg) ~= "string" then
    local str = ""
    if type(aMsg) ~= "number" then
      str = "PushMessage param not string is " .. type(aMsg)
    end
    local strMsg = tostring(aMsg)
    if type(strMsg) == "string" then
      aMsg = str .. " " .. strMsg
    end
  elseif "" == aMsg then
    aMsg = "PushMessage(param is empty)"
  elseif 0 ~= #arg then
    aMsg = fmt(aMsg, ...)
  end
  if aMsg:sub(1, 1) == "[" then
    aMsg = " " .. aMsg
  end
  if aMsg:sub(-1, -1) == "]" then
    aMsg = aMsg .. " "
  end
  if 0 == aColor then
    GetLuaValue("meTestMsg([[" .. aMsg .. "]]);")
  elseif 1 == aColor then
    GetLuaValue("meTestMsg([[" .. aMsg .. "]],1);")
  end
end

function PushDebugMessage(aMsg, ...)
  PushMessage(aMsg, 0, ...)
end

function PushColorMsg(aMsg, ...)
  PushMessage(aMsg, 1, ...)
end

function DebugStr(aMsg, idxTimer, ...)
  idxTimer = idxTimer or 1
  if nil == m_LastDebugMsgTime[idxTimer] then
    m_LastDebugMsgTime[idxTimer] = GetTickCount() - 20000
  end
  local dwNowTick = GetTickCount()
  if dwNowTick - m_LastDebugMsgTime[idxTimer] > 10000 then
    m_LastDebugMsgTime[idxTimer] = dwNowTick
    if type(aMsg) ~= "string" or "" == aMsg then
      aMsg = "debugstr msg is nil"
    end
    PushDebugMessage(aMsg, ...)
    return true
  end
  return false
end

function DebugColorMsg(aMsg, idxTimer, ...)
  idxTimer = idxTimer or 1
  if nil == m_LastDebugMsgTime[idxTimer] then
    m_LastDebugMsgTime[idxTimer] = GetTickCount() - 20000
  end
  local dwNowTick = GetTickCount()
  if dwNowTick - m_LastDebugMsgTime[idxTimer] > 10000 then
    m_LastDebugMsgTime[idxTimer] = dwNowTick
    if type(aMsg) ~= "string" or "" == aMsg then
      aMsg = "debugclrstr msg is nil"
    end
    PushColorMsg(aMsg, ...)
    return true
  end
  return false
end

function ShowWarningMsg(aMsg)
  PushColorMsg(aMsg)
  ShowTipMsg(aMsg)
end

function LogMsg(aMsg)
  PushColorMsg(aMsg)
  Log(aMsg)
end

function CheckFieldConfigSize(aConfig, aMaxSize, aKeepSize)
  local n = #aConfig
  if aMaxSize >= n then
    return aConfig
  end
  local newCfg = {}
  for i = n - aKeepSize + 1, n do
    table.insert(newCfg, aConfig[i])
  end
  return newCfg
end

function WriteConfig(aNewConfig)
  local guid = GetLuaValue("return Player:GetGUID()", "s")
  if #guid >= 16 then
    local strCfg = g_json.encode(aNewConfig)
    DoSystem(8, guid, strCfg)
  else
    PushColorMsg("写配置：获取GUID失败")
  end
end

function GetConfig(aMust)
  local bUpdate = false
  local strConfig, runScript = GetUserConfig()
  g_runing_script = runScript
  return bUpdate
end

function IsValidConfig(aPushMsg)
  return true
end

function HandleText_AddFuHao(aStr, aFuHao, aNotEmpty)
  aFuHao = aFuHao or " "
  if aNotEmpty and "" == aStr then
    return aStr
  end
  if aStr:sub(1, 1) ~= aFuHao then
    aStr = aFuHao .. aStr
  end
  if aStr:sub(-1, -1) ~= aFuHao then
    aStr = aStr .. aFuHao
  end
  return aStr
end

function HandleText(aStr)
  if type(aStr) ~= "string" then
    return ""
  end
  local str = string.gsub(aStr, "\r\n", " ")
  str = string.gsub(str, "  ", " ")
  str = string.gsub(str, "  ", " ")
  return str
end

function HandleTextToNumber(aStr, aDef)
  aDef = aDef or 0
  local tonum = tonumber(aStr)
  tonum = tonum or aDef
  return tonum
end

function CheckTaskNameHasRuningScript(aTaskName)
  local task_name = HandleText(aTaskName)
  if "" == task_name or " " == task_name or "" == g_runing_script then
    return false
  end
  task_name = " " .. task_name .. " "
  if not string.find(task_name, " " .. g_runing_script .. " ", nil, true) then
    return false
  end
  return true
end

function IsSceneTransed()
  return GetLuaValue("return meGetSceneTransedState()", "b")
end

function CSleepCallBack(aTimeOut, aMs, aCallBack)
  local nTick = GetTickCount()
  while aTimeOut > GetTickCount() - nTick do
    CSleep(aMs)
    if not aCallBack or false == aCallBack() then
    end
  end
end

function QuitGame()
  DoSystem(2)
end

function Log(aMsg)
  DoSystem(3, aMsg)
end

function SwitchGetState()
  return DoSystem(2004)
end

function SwitchSetState(aType)
  DoSystem(2005, aType)
end

function ipc_msg_zk(aType, aStrData)
  return DoSystem(6002, aType, aStrData)
end

function ipc_zk_log(aStrLog)
  ipc_msg_zk(10, aStrLog)
end

function ipc_zk_CanLoginGame(aGamePath, aSvrName)
  local strData = aGamePath .. "$&$" .. aSvrName
  local llRet = ipc_msg_zk(11, strData)
  local kaifu = llRet & 1
  local mustLogin = llRet >> 1 & 1
  local bNeedUpdateGame = llRet >> 2 & 1
  return bNeedUpdateGame, mustLogin, kaifu
end

function OffLine(aOffAutoLogin, aLog)
  if aOffAutoLogin then
    local msg = Player:GetName() .. "：游戏正常下线(杀气、或者达到玩家的设置)！ $&$" .. DoSystem_old(7779)
    ipc_zk_log(msg)
    Sleep(500)
  end
  if aLog then
    Log("自动下线：" .. aLog)
  end
  QuitGame()
end

function ShutDown(aLog)
  if aLog then
    Log("自动关机：" .. aLog)
  end
  DoSystem(17)
end

function UnIconicWindow()
  DoSystem(23)
end

function IconicWindow()
  DoSystem(24)
end

function ClosePathGameProcess()
  DoSystem(25)
end

function Help_CheckGameConnect()
  local strText1 = "            setmetatable(_G, {__index = MessageBox_Self_Env})\n            if this:IsVisible() then\n                local szText = MessageBox_Self_Text:GetText()\n                if string.find(szText, \"已与服务器断开连接\", nil, true) then\n                    meTestMsg(\"已断开连接\", 1)\n                    MessageBox_Self_OK_Clicked()\n                    return 1\n                end\n            end\n            return 0\n        "
  local strText2 = "            setmetatable(_G, {__index = MsgBall_Connect_Env})\n            if this:IsVisible() then\n                MsgBall_Connect_Action_Click()\n                meTestMsg(\"检测到网络阻塞,重新连接.\", 1)\n                return 1\n            end\n            return 0     \n        "
  local strText3 = "            setmetatable(_G, {__index = LoginSelectServerQuest_Env})\n            if this:IsVisible() then\n                local szText = SelectServerQuest_InfoWindow:GetText()\n                if string.find(szText, \"请检查网络后重新登录\", nil, true) then\n                    SelectServerQuest_Bn1Click()\n                    return 1\n                end\n            end\n            return 0        \n        "
  if GetLuaValue(strText1, "b") then
  elseif GetLuaValue(strText3, "b") then
    CSleep(3000)
  elseif IsWindowVisible("QuitRelative") then
    PushColorMsg("等待数秒后重连")
    CSleep(1000)
  elseif GetLuaValue(strText2, "b") then
    CSleep(3000)
    IsWindowVisible("MsgBall_Connect_Msg", "MsgBall_Connect_Msg_Bn1Click()")
  end
end

function Sleep(aMs)
  if type(aMs) ~= "number" then
    return false
  end
  
  local function _TransedCheck()
    local _trans = false
    local dwNowTick = GetTickCount()
    while IsSceneTransed() do
      _trans = true
      CSleep(2000)
      if IsHelpThread() then
        if GetTickCount() - dwNowTick > 30000 then
          DebugStr("传送地图已超时,超时5分钟将自动关闭游戏！")
        end
        if GetTickCount() - dwNowTick > 300000 then
          PushColorMsg("传送地图超时5分钟，自动关闭游戏")
          OffLine(false, "传送超时5分钟")
        end
        Help_CheckGameConnect()
      end
    end
    return _trans
  end
  
  local trans = _TransedCheck()
  if aMs > 2000 then
    CSleepCallBack(aMs, 500, nil)
  else
    CSleep(aMs)
  end
  trans = _TransedCheck()
  if trans then
    CSleep(888)
  end
  return trans
end

function SleepCallBack(aTimeOut, aMs, aCallBack)
  local nTick = GetTickCount()
  local bsuccess = true
  while aTimeOut > GetTickCount() - nTick do
    Sleep(aMs)
    if aCallBack and false == aCallBack() then
      bsuccess = false
      break
    end
  end
  return bsuccess
end

function TalkChatMsg(aWhere, aTalkMsg)
  if "" ~= aTalkMsg then
    if "laba" == aWhere then
      GetLuaValue(fmt([[
                if meGetSceneTransedState() == 0 then 
                    Player:SendSpeakerMessage(0, '%s')
                end
            ]], aTalkMsg))
    elseif "qiwen" == aWhere then
      GetLuaValue(fmt([[
                if meGetSceneTransedState() == 0 then 
                    Player:SendSpeakerMessage(2, '%s')
                end
            ]], aTalkMsg))
    else
      GetLuaValue(fmt([[
                if meGetSceneTransedState() == 0 then 
                    Talk:SendChatMessage('%s', '%s')
                end
                ]], aWhere, aTalkMsg))
    end
    Sleep(100)
  end
end

function TalkSendPrivateMsg(aPlayerName, aTalkMsg)
  GetLuaValue(fmt("Talk:SendChatMessage('near', '/%s %s')", aPlayerName, aTalkMsg))
  Sleep(500)
end

function IsWindowVisible(strWindowName, visible_action, unvisible_action)
  if nil == strWindowName or "" == strWindowName then
    return false
  end
  local strText = [[
            setmetatable(_G, {__index = %s_Env}) 
            if this and this:IsVisible() then 
                --#{visible_action}
                return 1
            else 
                --#{unvisible_action}
                return 0    
            end
        ]]
  strText = fmt(strText, strWindowName)
  if visible_action then
    strText = string.gsub(strText, "--#{visible_action}", visible_action)
  end
  if unvisible_action then
    strText = string.gsub(strText, "--#{unvisible_action}", unvisible_action)
  end
  return GetLuaValue(strText, "b")
end

function IsWindowVisible2(strWindowName)
  if nil == strWindowName or "" == strWindowName then
    return false
  end
  return GetLuaValue("if " .. strWindowName .. ":IsVisible() then return 1 else return 0 end", "b")
end

function CloseWindow(aWindowName)
  local bClose = true
  for i = 1, 10 do
    if IsWindowVisible(aWindowName, "this:Hide()") then
      bClose = false
      Sleep(100)
    else
      bClose = true
      break
    end
  end
  return bClose
end

function CloseAllWindow()
  GetLuaValue("CloseAllWindow()")
  Sleep(100)
end

function IsWindowShow(aWindowName)
  return GetLuaValue("if IsWindowShow([[" .. aWindowName .. "]]) == true then return 1 else return 0 end;", "b")
end

function GetChangeSceneTimeDiff()
  local nTime = GetLuaValue("return meGetSceneTransTimeDiff()", "n")
  return nTime
end

function GetSceneTransTime()
  local nTime = GetLuaValue("return meGetSceneTransTime()", "n")
  return nTime
end

function IsPlayerFollow(abSure)
  if nil == abSure then
    abSure = true
  end
  local nFollow = GetLuaValue("if Player:InTeamFollowMode() then return 1 else return 0 end", "n")
  if 0 == nFollow and abSure and GetChangeSceneTimeDiff() < 4 then
    Sleep(2000)
    nFollow = GetLuaValue("if Player:InTeamFollowMode() then return 1 else return 0 end", "n")
  end
  return 1 == nFollow
end

function IsMount()
  local aBuffName = "坐骑："
  local nIndex = GetLuaValue("return mePlayerGetBuff([[" .. aBuffName .. "]]);", "nsn")
  return -1 ~= nIndex
end

function GetSceneID()
  local nScene = GetLuaValue("return GetSceneID()", "n")
  if 242 == nScene then
    LUOYANG_ID = 242
  end
  return nScene
end

function GetCurrentSceneName()
  local scene_name = GetLuaValue("return GetCurrentSceneName()", "s")
  if "" == scene_name then
    for i = 1, 8 do
      PushDebugMessage("尝试再次获取地图名称")
      scene_name = GetLuaValue("return GetCurrentSceneName()", "s")
      if "" ~= scene_name then
        break
      end
      Sleep(1000)
    end
  end
  return scene_name
end

function IsDiFuScene(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  if 77 == nSceneID or 578 == nSceneID or 823 == nSceneID then
    return true
  end
  return false
end

function IsKVKSceneName(aSceneName)
  local nSceneID = GetSceneID()
  if 577 == nSceneID or 578 == nSceneID or 823 == nSceneID then
    return true
  end
  aSceneName = aSceneName or GetCurrentSceneName()
  if "" == aSceneName then
    return false
  end
  if string.find(" 凤鸣镇 漠南青原 忘川花海 天岐南淮 林海溪谷 水月洞天 沁水丹林 云遥鹊岭 大鲲遗骸 玄海 千秋殿 不归林 无涯海 炎罗天 玉皇山 云浮 苍梧秘境 ", " " .. aSceneName .. " ", nil, true) then
    return true
  end
  if string.find(aSceneName, "通天塔", nil, true) then
    return true
  end
  if string.find(" 金陵 金陵2线 金陵3线 汴京 汴京2线 汴京3线 汴京4线 汴京5线 汴京6线 千帆寨 古今亭 枯荣道 望风古原 剑兰坡 余霞港 星渔湾 冷雁横川 云梦泽 碧笋春林 雨竹岗 苍梧秘境 ", " " .. aSceneName .. " ", nil, true) then
    return true
  end
  return false
end

function JL_GetSceneLineTab()
  return {
    {line = 1, sceneID = 762},
    {line = 2, sceneID = 772},
    {line = 3, sceneID = 773}
  }
end

function JL_GetSceneID(aSceneID)
  local alltab = JL_GetSceneLineTab()
  local sceneID = aSceneID or GetSceneID()
  for i = 1, #alltab do
    if alltab[i].sceneID == sceneID then
      return alltab[i].sceneID
    end
  end
  return -1
end

function BJ_GetSceneLineTab()
  return {
    {line = 1, sceneID = 755},
    {line = 2, sceneID = 775},
    {line = 3, sceneID = 776},
    {line = 4, sceneID = 779},
    {line = 5, sceneID = 780},
    {line = 6, sceneID = 785}
  }
end

function BJ_GetSceneID(aSceneID)
  local alltab = BJ_GetSceneLineTab()
  local sceneID = aSceneID or GetSceneID()
  for i = 1, #alltab do
    if alltab[i].sceneID == sceneID then
      return alltab[i].sceneID
    end
  end
  return -1
end

function GetMenpaiIDBySceneID(aSceneID)
  if aSceneID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.sceneID == aSceneID then
        return tmp.menpaiID
      end
    end
  end
  return -1
end

function IsCityScene(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  if 0 == nSceneID or 242 == nSceneID then
    return true
  elseif 1 == nSceneID then
    return true
  elseif 2 == nSceneID then
    return true
  elseif 246 == nSceneID then
    return true
  elseif 260 == nSceneID then
    return true
  elseif 850 == nSceneID then
    return true
  elseif -1 ~= BJ_GetSceneID(nSceneID) then
    return true
  elseif -1 ~= JL_GetSceneID(nSceneID) then
    return true
  elseif IsDiFuScene(nSceneID) then
    return true
  elseif 194 == nSceneID or 577 == nSceneID then
    return true
  elseif 738 == nSceneID then
    return true
  end
  return false
end

function IsSafeSceneID(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  if 0 == nSceneID or 242 == nSceneID then
    return true
  elseif 1 == nSceneID then
    return true
  elseif 2 == nSceneID then
    return true
  elseif 246 == nSceneID then
    return true
  elseif 850 == nSceneID then
    return true
  elseif -1 ~= BJ_GetSceneID(nSceneID) then
    return true
  elseif -1 ~= JL_GetSceneID(nSceneID) then
    return true
  elseif IsDiFuScene(nSceneID) then
    return true
  elseif 194 == nSceneID or 577 == nSceneID then
    return true
  elseif 738 == nSceneID then
    return true
  elseif 224 == nSceneID then
    return true
  elseif -1 ~= GetMenpaiIDBySceneID(nSceneID) then
    return true
  end
  return false
end

function IsGuanShanHaiScene(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  local sceneIdArr = {
    749,
    750,
    752
  }
  for i = 1, #sceneIdArr do
    if sceneIdArr[i] == nSceneID then
      return true
    end
  end
  return false
end

function GetMenpaiIDByXiaoFubenID(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  if -1 ~= nSceneID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.xiaoSceneID == nSceneID then
        return tmp.menpaiID
      end
    end
  end
  return -1
end

function GetFubenSceneIDByMenpaiSceneID(aMenpaiSceneID)
  if aMenpaiSceneID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.sceneID == aMenpaiSceneID then
        return tmp.fubenSceneID
      end
    end
  end
  return -1
end

function IsMenPaiBossScene(aSceneID)
  for i = 1, #g_MenPaiInfo do
    local tmp = g_MenPaiInfo[i]
    if tmp.fubenSceneID == aSceneID then
      return true
    end
  end
  return false
end

function IsMenPaiXiaoFuben_xs(aSceneID)
  local tID = {
    552,
    553,
    554,
    555,
    556,
    557,
    558,
    559,
    560,
    561,
    628,
    683,
    739,
    826,
    1000
  }
  local nSceneID = aSceneID or GetSceneID()
  for i = 1, #tID do
    if tID[i] == nSceneID then
      return true
    end
  end
  return false
end

function IsInFubenScene(aSceneID)
  local cur_scene_id = aSceneID or GetSceneID()
  local sceneIdArr = {
    61,
    66,
    110,
    170,
    230,
    231,
    232,
    233,
    236,
    261,
    268,
    269,
    272,
    273,
    274,
    275,
    276,
    277,
    278,
    279,
    280,
    281,
    291,
    294,
    300,
    546,
    550,
    551,
    565,
    566,
    600,
    645,
    651,
    652,
    653,
    662,
    677,
    848,
    124,
    877,
    934
  }
  if FindTableValue(sceneIdArr, cur_scene_id) then
    return true
  end
  if IsMenPaiXiaoFuben_xs(cur_scene_id) then
    return true
  end
  if IsMenPaiBossScene(cur_scene_id) then
    return true
  end
  if -1 ~= GetMenpaiIDByXiaoFubenID(cur_scene_id) then
    return true
  end
  return IsGuanShanHaiScene(cur_scene_id)
end

function IsBangHuiPK()
  local strText = [[
            setmetatable(_G, {__index = MainMenuBar_Env})
            if Button_ConfraternityPK_Ani:IsVisible() then
                return 1
            else
                return 0
            end
    ]]
  local bBangZhan = GetLuaValue(strText, "n")
  if 1 == bBangZhan then
    return true
  end
  strText = [[
            setmetatable(_G, {__index = NewBangHui_Xuanzhan_Env});
            local str = NewBangHui_Xuanzhan_Bhxz:GetText()
            return str
        ]]
  local s = GetLuaValue(strText, "s")
  if 13 == #s then
    return false
  end
  return true
end

function IsUnLockMibao()
  return GetLuaValue("return meIsUnlockMibao()", "b")
end

function CheckMibao(aMust)
  local bUnLock = false
  local diff_time = 60000
  aMust = true
  if aMust or diff_time < GetTickCount() - g_checkMibaoTime then
    local unlock = IsUnLockMibao()
    if unlock then
      bUnLock = true
    else
      DebugStr("还未解锁密保", 5)
      g_checkMibaoTime = GetTickCount()
    end
  else
    DebugStr("未解锁密保,%s秒后再次检查.", 5, math.floor((diff_time - (GetTickCount() - g_checkMibaoTime)) / 1000))
  end
  return bUnLock
end

function ClearDbgMsg()
  GetLuaValue("meClearDbgMsg()")
end

function DeleteDebugMsg(aMsg)
  if type(aMsg) == "string" and "" ~= aMsg then
    GetLuaValue(fmt("meDeleteDbgMsg([[%s]]);", aMsg))
  end
end

function IsInDebugMsg(aMsg, aIsDel)
  if nil == aIsDel then
    aIsDel = "false"
  elseif 1 == aIsDel then
    aIsDel = "true"
  else
    aIsDel = "false"
  end
  local nMsgTime, szMsgText, nMsgTick = GetLuaValue(fmt("return meFindDbgMsg([[%s]],2,%s);", aMsg, aIsDel), "nsn")
  if nMsgTime > 0 then
    return nMsgTime, szMsgText, nMsgTick
  end
  return nil, "", -1
end

function IsInDebugMsgTime(aMsg, aIsDel, aTime)
  local nMsgTime, szMsgText, nMsgTick = IsInDebugMsg(aMsg, aIsDel)
  if nMsgTime then
    local timeDiff = os.time() - nMsgTime
    if aTime > timeDiff then
      return true, szMsgText, nMsgTime
    end
  end
  return false, "", -1
end

function JiaGongCaiLiao()
  local tCaiLiao = Bag:EnumCailiaoItem()
  if Bag:HasCaiLiaoByType("高级皮毛", tCaiLiao) or Bag:HasCaiLiaoByType("中级皮毛", tCaiLiao) or Bag:HasCaiLiaoByType("初级皮毛", tCaiLiao) then
    GetLuaValue("ComposeItem_Begin(406,99,-1);")
    return true
  end
  if Bag:HasCaiLiaoByType("工艺材料", tCaiLiao) then
    GetLuaValue("ComposeItem_Begin(407,99,-1);")
    return true
  end
  if Bag:HasCaiLiaoByType("缝纫类材", tCaiLiao) then
    local szName = " "
    for i = 1, #tCaiLiao do
      szName = szName .. tCaiLiao[i].name .. " "
    end
    if string.find(szName, "七彩的黄骨", nil, true) or string.find(szName, "七彩的地心", nil, true) or string.find(szName, "七彩的玄丝", nil, true) or string.find(szName, "七彩的天眼") or string.find(szName, "闪亮的黄骨", nil, true) or string.find(szName, "闪亮的地心", nil, true) or string.find(szName, "闪亮的玄丝", nil, true) or string.find(szName, "闪亮的天眼", nil, true) or string.find(szName, "无瑕的黄骨", nil, true) or string.find(szName, "无瑕的地心", nil, true) or string.find(szName, "无瑕的玄丝", nil, true) or string.find(szName, "无瑕的天眼", nil, true) or string.find(szName, "完美的黄骨", nil, true) or string.find(szName, "完美的地心", nil, true) or string.find(szName, "完美的玄丝", nil, true) or string.find(szName, "完美的天眼", nil, true) or string.find(szName, "发光的黄骨", nil, true) or string.find(szName, "发光的地心", nil, true) or string.find(szName, "发光的玄丝", nil, true) or string.find(szName, "发光的天眼", nil, true) or string.find(szName, "至尊黄骨", nil, true) or string.find(szName, "至尊地心", nil, true) or string.find(szName, "至尊玄丝", nil, true) or string.find(szName, "至尊天眼", nil, true) then
      GetLuaValue("ComposeItem_Begin(405,99,-1);")
      return true
    elseif string.find(szName, "普通的黄骨", nil, true) or string.find(szName, "普通的地心", nil, true) or string.find(szName, "普通的玄丝", nil, true) or string.find(szName, "普通的天眼") or string.find(szName, "完好的黄骨", nil, true) or string.find(szName, "完好的地心", nil, true) or string.find(szName, "完好的玄丝", nil, true) or string.find(szName, "完好的天眼", nil, true) or string.find(szName, "破旧的黄骨", nil, true) or string.find(szName, "破旧的地心", nil, true) or string.find(szName, "破旧的玄丝", nil, true) or string.find(szName, "破旧的天眼", nil, true) then
      GetLuaValue("ComposeItem_Begin(404,99,-1);")
      return true
    elseif string.find(szName, "破损的黄骨", nil, true) or string.find(szName, "破损的地心", nil, true) or string.find(szName, "破损的玄丝", nil, true) or string.find(szName, "破损的天眼") or string.find(szName, "残缺的黄骨", nil, true) or string.find(szName, "残缺的地心", nil, true) or string.find(szName, "残缺的玄丝", nil, true) or string.find(szName, "残缺的天眼", nil, true) or string.find(szName, "坏掉的黄骨", nil, true) or string.find(szName, "坏掉的地心", nil, true) or string.find(szName, "坏掉的玄丝", nil, true) or string.find(szName, "坏掉的天眼", nil, true) then
      GetLuaValue("ComposeItem_Begin(403,99,-1);")
      return true
    else
      PushDebugMessage("空闲加工材料:有未被识别的缝纫类材")
    end
  end
  if Bag:HasCaiLiaoByType("铸造类材", tCaiLiao) then
    local szName = " "
    for i = 1, #tCaiLiao do
      szName = szName .. tCaiLiao[i].name .. " "
    end
    if string.find(szName, "七彩的刀柄", nil, true) or string.find(szName, "七彩的枪杆", nil, true) or string.find(szName, "七彩的剑鞘", nil, true) or string.find(szName, "七彩的双棍") or string.find(szName, "七彩的扇骨", nil, true) or string.find(szName, "七彩的环片", nil, true) or string.find(szName, "闪亮的刀柄", nil, true) or string.find(szName, "闪亮的枪杆", nil, true) or string.find(szName, "闪亮的剑鞘", nil, true) or string.find(szName, "闪亮的双棍", nil, true) or string.find(szName, "闪亮的扇骨", nil, true) or string.find(szName, "闪亮的环片", nil, true) or string.find(szName, "无瑕的刀柄", nil, true) or string.find(szName, "无瑕的枪杆", nil, true) or string.find(szName, "无瑕的剑鞘", nil, true) or string.find(szName, "无瑕的双棍", nil, true) or string.find(szName, "无瑕的扇骨", nil, true) or string.find(szName, "无瑕的环片", nil, true) or string.find(szName, "完美的刀柄", nil, true) or string.find(szName, "完美的枪杆", nil, true) or string.find(szName, "完美的剑鞘", nil, true) or string.find(szName, "完美的双棍", nil, true) or string.find(szName, "完美的扇骨", nil, true) or string.find(szName, "完美的环片", nil, true) or string.find(szName, "发光的刀柄", nil, true) or string.find(szName, "发光的枪杆", nil, true) or string.find(szName, "发光的剑鞘", nil, true) or string.find(szName, "发光的双棍", nil, true) or string.find(szName, "发光的扇骨", nil, true) or string.find(szName, "发光的环片", nil, true) or string.find(szName, "至尊刀柄", nil, true) or string.find(szName, "至尊枪杆", nil, true) or string.find(szName, "至尊剑鞘", nil, true) or string.find(szName, "至尊双棍", nil, true) or string.find(szName, "至尊扇骨", nil, true) or string.find(szName, "至尊环片", nil, true) then
      GetLuaValue("ComposeItem_Begin(402,99,-1);")
      return true
    elseif string.find(szName, "普通的刀柄", nil, true) or string.find(szName, "普通的枪杆", nil, true) or string.find(szName, "普通的剑鞘", nil, true) or string.find(szName, "普通的双棍") or string.find(szName, "普通的扇骨", nil, true) or string.find(szName, "普通的环片", nil, true) or string.find(szName, "完好的刀柄", nil, true) or string.find(szName, "完好的枪杆", nil, true) or string.find(szName, "完好的剑鞘", nil, true) or string.find(szName, "完好的双棍", nil, true) or string.find(szName, "完好的扇骨", nil, true) or string.find(szName, "完好的环片", nil, true) or string.find(szName, "破旧的刀柄", nil, true) or string.find(szName, "破旧的枪杆", nil, true) or string.find(szName, "破旧的剑鞘", nil, true) or string.find(szName, "破旧的双棍", nil, true) or string.find(szName, "破旧的扇骨", nil, true) or string.find(szName, "破旧的环片", nil, true) then
      GetLuaValue("ComposeItem_Begin(401,99,-1);")
      return true
    elseif string.find(szName, "破损的刀柄", nil, true) or string.find(szName, "破损的枪杆", nil, true) or string.find(szName, "破损的剑鞘", nil, true) or string.find(szName, "破损的双棍") or string.find(szName, "破损的扇骨", nil, true) or string.find(szName, "破损的环片", nil, true) or string.find(szName, "残缺的刀柄", nil, true) or string.find(szName, "残缺的枪杆", nil, true) or string.find(szName, "残缺的剑鞘", nil, true) or string.find(szName, "残缺的双棍", nil, true) or string.find(szName, "残缺的扇骨", nil, true) or string.find(szName, "残缺的环片", nil, true) or string.find(szName, "坏掉的刀柄", nil, true) or string.find(szName, "坏掉的枪杆", nil, true) or string.find(szName, "坏掉的剑鞘", nil, true) or string.find(szName, "坏掉的双棍", nil, true) or string.find(szName, "坏掉的扇骨", nil, true) or string.find(szName, "坏掉的环片", nil, true) then
      GetLuaValue("ComposeItem_Begin(400,99,-1);")
      return true
    else
      PushDebugMessage("空闲加工材料:有未被识别的铸造类材")
    end
  end
  return false
end

function ZYCJ_Action(aPneumaStart)
  local bCuiJie = false
  if not g_config.zycj then
    return bCuiJie
  end
  local param = {}
  param.baise = g_config.zycj.baise
  param.lvse = g_config.zycj.lvse
  param.lanse = g_config.zycj.lanse
  param.zise = g_config.zycj.zise
  param.allname = HandleText_AddFuHao(HandleText(g_config.zycj.allname))
  
  local function _GetColorName(aName, aColor)
    local clrName = ""
    if 1 == aColor then
      clrName = "[白色]" .. aName
    elseif 2 == aColor then
      clrName = "[绿色]" .. aName
    elseif 3 == aColor then
      clrName = "[蓝色]" .. aName
    elseif 4 == aColor then
      clrName = "[紫色]" .. aName
    elseif 5 == aColor then
      clrName = "[橙色]" .. aName
    elseif 6 == aColor then
    end
    return clrName
  end
  
  for i = 1, 10 do
    if -1 == Bag:LuaUseItem_DJ("紫色真元符集", 2) then
      break
    end
    Sleep(50)
  end
  
  local function _CuiJie(aClrName, aIndex)
    local strText = fmt([[
                local posIndex = %d
                local nGetExp = Pneuma:GetPneumaProperty(posIndex, 7)
                local nPlayerOwnExp = Pneuma:GetPneumaExp()
                local nMaxExp = Pneuma:GetPneumaExpMax()
                if nGetExp + nPlayerOwnExp <= nMaxExp then
                    Pneuma:SmeltPneumaItem(posIndex)
                    return 1
                end
                return 0
            ]], aIndex)
    if GetLuaValue(strText, "b") then
      PushDebugMessage("自动淬解:" .. aClrName)
      Sleep(50)
    else
      PushColorMsg("淬解失败：元晶已满" .. aClrName)
    end
  end
  
  for i = 1, 24 do
    local posIndex = aPneumaStart + i - 1
    local strText = fmt([[
                local szName = ""
                local nClr = -1
                local posIndex = %d
                local theAction, bLocked = Pneuma:EnumPneumaItem("pneuma", posIndex)
                if theAction:GetID() ~= 0 then
                    local unlocktime = Pneuma:GetPneumaItemProperty(posIndex,8)
                    if unlocktime == nil or unlocktime <=0 then
                        szName = theAction:GetName()
                        nClr = Pneuma:GetPneumaProperty(posIndex, 2)
                    end
                end
                return szName,nClr
            ]], posIndex)
    local szName, nClr = GetLuaValue(strText, "sn")
    if "" ~= szName and -1 ~= nClr then
      local clrName = _GetColorName(szName, nClr)
      if 1 == nClr and param.baise or 2 == nClr and param.lvse or 3 == nClr and param.lanse or 4 == nClr and param.zise then
        _CuiJie(clrName, posIndex)
        bCuiJie = true
      elseif string.find(param.allname, " " .. szName .. " ", nil, true) then
        if nClr < 5 then
          _CuiJie(clrName, posIndex)
          bCuiJie = true
        end
      elseif "" ~= clrName and string.find(param.allname, " " .. clrName .. " ", nil, true) then
        _CuiJie(clrName, posIndex)
        bCuiJie = true
      end
    end
  end
  return bCuiJie
end

function IsPlayerIsFriend(aPlayerName)
  if "" == aPlayerName then
    return false
  end
  return GetLuaValue(fmt([[
        local strName="%s"
        if Friend:IsPlayerIsFriend(strName, -1) == 1 then
            return 1
        end
        return 0
    ]], aPlayerName), "b")
end

function Friend_GetAllName()
  return GetLuaValue([[
        local strAllName = ""
        for i = 1, 4 do
            local friendNum = DataPool:GetFriendNumber(i)
            for j = 0, friendNum - 1 do
                local szName = DataPool:GetFriend(i, j, "NAME")
                strAllName = strAllName .. szName .. " "
            end
        end
        return strAllName
    ]], "s")
end

function LingQuHuoYueHaoLi(aGetZhou)
  DeleteDebugMsg("#{HYHL_101230_38}")
  for i = 1, 4 do
    local boxIndex = GetLuaValue([[
                    local boxIndex = 0
                    local nDataRound = DataPool:GetPlayerMission_DataRound(579)
                    for i = 1, 4 do
                        local a = meBitShr(nDataRound, i)
                        local b = meBitAnd(a, 1)
                        if b ~= 1 then
                            boxIndex = i
                            break
                        end
                    end
                    return boxIndex
                ]], "n")
    if boxIndex > 0 and boxIndex <= 4 then
      local tabNeed = {
        1,
        50,
        150,
        450
      }
      local huoyue = tabNeed[boxIndex]
      local strText = [[
                        local nTodayActivePoint = Player:GetData("TODAYACTIVEPOINT")
                        if nTodayActivePoint and nTodayActivePoint >= %d then 
                            Clear_XSCRIPT();
                                Set_XSCRIPT_Function_Name("OnAugury");
                                Set_XSCRIPT_ScriptID(889336);
                                Set_XSCRIPT_Parameter(0, %d);
                                Set_XSCRIPT_ParamCount(1);
                            Send_XSCRIPT();
                        end
                    ]]
      GetLuaValue(fmt(strText, huoyue, boxIndex))
    else
      break
    end
    Sleep(1000)
    if IsInDebugMsg("#{HYHL_101230_38}") then
      break
    end
  end
  if aGetZhou then
    local strText = [[
                local nTodayActivePoint_week = Player:GetData("WEEKACTIVEPOINT")
                if nTodayActivePoint_week and nTodayActivePoint_week >= 1200 then 
                    Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("OnAugury_week");
                    Set_XSCRIPT_ScriptID(889336);
                    Set_XSCRIPT_Parameter(0, 1);
                    Set_XSCRIPT_ParamCount(1);
                    Send_XSCRIPT();
                end
                if nTodayActivePoint_week and nTodayActivePoint_week >= 2000 then 
                    Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("OnAugury_week");
                    Set_XSCRIPT_ScriptID(889336);
                    Set_XSCRIPT_Parameter(0, 2);
                    Set_XSCRIPT_ParamCount(1);
                    Send_XSCRIPT();
                end
            ]]
    GetLuaValue(strText)
  else
    if os.time() - m_LastGetWeekTime[1] > 86400 then
      local nGet = GetLuaValue([[
                local nTodayActivePoint_week = Player:GetData("WEEKACTIVEPOINT")
                if nTodayActivePoint_week and nTodayActivePoint_week >= 1200 then 
                    Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("OnAugury_week");
                    Set_XSCRIPT_ScriptID(889336);
                    Set_XSCRIPT_Parameter(0, 1);
                    Set_XSCRIPT_ParamCount(1);
                    Send_XSCRIPT();
                    return 1
                end
                return 0
            ]], "n")
      Sleep(100)
      if 1 == nGet then
        m_LastGetWeekTime[1] = os.time()
      end
    end
    if os.time() - m_LastGetWeekTime[2] > 86400 then
      local nGet = GetLuaValue([[
                local nTodayActivePoint_week = Player:GetData("WEEKACTIVEPOINT")
                if nTodayActivePoint_week and nTodayActivePoint_week >= 2000 then 
                    Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("OnAugury_week");
                    Set_XSCRIPT_ScriptID(889336);
                    Set_XSCRIPT_Parameter(0, 2);
                    Set_XSCRIPT_ParamCount(1);
                    Send_XSCRIPT();
                    return 1
                end
                return 0
            ]], "n")
      Sleep(100)
      if 1 == nGet then
        m_LastGetWeekTime[2] = os.time()
      end
    end
  end
end

function LingQuXiuWuZhiYue()
  local function XiuWuGetPrize(aIndex, aType)
    local strText = fmt([[

                Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("AskGetReward") 
                    Set_XSCRIPT_ScriptID(790029) 
                    Set_XSCRIPT_Parameter(0, %d)
                    Set_XSCRIPT_Parameter(1, %d)
                    Set_XSCRIPT_ParamCount(2)
                Send_XSCRIPT()	
            ]], aIndex, aType)
    GetLuaValue(strText)
    Sleep(300)
  end
  
  DeleteDebugMsg("#{TLZL_190802_48}")
  for i = 1, 11 do
    XiuWuGetPrize(i, 0)
    if IsInDebugMsg("#{TLZL_190802_48}") then
      break
    end
  end
end

function LingQuQianDaoJiangLi()
  DeleteDebugMsg("#{MYQD_150513_20}")
  for i = 1, 5 do
    local strText = [[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name("GetPrize")
                Set_XSCRIPT_ScriptID(891106)
                Set_XSCRIPT_Parameter(0, %d)
                Set_XSCRIPT_ParamCount(1)
            Send_XSCRIPT()
        ]]
    GetLuaValue(fmt(strText, i))
    Sleep(300)
    if IsInDebugMsg("#{MYQD_150513_20}") then
      break
    end
  end
  CloseWindow("Fuli_MonthlySign")
end

function QianDaoAndGetPrize()
  Sleep(100)
  GetLuaValue([[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name("CheckTodaySign")
                Set_XSCRIPT_ScriptID(891106)
                Set_XSCRIPT_ParamCount(0)
            Send_XSCRIPT() 
        ]])
  Sleep(500)
  if g_config.tysz.lqqdjl then
    LingQuQianDaoJiangLi()
  end
  if g_config.tysz.lqxwzy then
    LingQuXiuWuZhiYue()
  end
end

function Player_GetName()
  local szName = GetLuaValue("local strName = Player:GetName(); return strName", "s")
  if "" ~= szName then
    g_self.name = szName
  end
  return szName
end

function GetItemConfigText(aPlayerName, aAppName, aKeyName)
  local strPath = g_public_dir .. "角色设置\\私有设置\\" .. aPlayerName .. "\\物品.ini"
  return DoSystem(6, aKeyName, aAppName, strPath)
end

function GetConfigText(aAppName, aKeyName)
  if g_self.name == "" then
    Player_GetName()
  end
  local strPath = g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\用户配置.ini"
  return ReadConfigText(aAppName, aKeyName, strPath)
end

function GetConfigInt(aJieName, aField)
  local strText = GetConfigText(aJieName, aField)
  local n = HandleTextToNumber(strText)
  return n
end

function GetConfigBool(aJieName, aField)
  local strText = GetConfigText(aJieName, aField)
  if "1" == strText then
    return true
  end
  return false
end

function GetConfigCommbox(aJieName, aField)
  local strText = GetConfigText(aJieName, aField)
  local strArr = SplitString(strText, "&")
  if #strArr >= 3 then
    return {
      sel = tonumber(strArr[1]) or -1,
      text = strArr[2],
      data = tonumber(strArr[3]) or 0
    }
  end
  return {
    sel = -1,
    text = "",
    data = 0
  }
end

function GetConfigList(aJieName, aField)
  local obj = {}
  local strText = GetConfigText(aJieName, aField)
  local strArr = SplitString(strText, "|", true)
  for i = 1, #strArr do
    local arr = SplitString(strArr[i], "&", true)
    if 2 == #arr then
      local str = arr[1]
      table.insert(obj, {
        text = arr[1],
        data = tonumber(arr[2] or 0)
      })
    end
  end
  return obj
end

function GetConfigListCtrlEx(aAppName, aKeyName, aLieCount)
  local obj = {}
  local strText = GetConfigText(aAppName, aKeyName)
  local strArr = SplitString(strText, "|", true)
  for i = 1, #strArr do
    local arr = SplitString(strArr[i], "&", false)
    if #arr == aLieCount then
      table.insert(obj, arr)
    end
  end
  return obj
end

function GlobalParam_item()
  g_config.item = {}
  g_config.item.save_money = true
  g_config.item.unsave_money_count = 0
  g_config.item.pick_all = true
  g_config.item.pick_part = false
  local PickMode = GetConfigCommbox("物品", "捡包模式1")
  if 0 == PickMode.sel then
    g_config.item.pick_all = false
    g_config.item.pick_part = true
  end
  g_config.item.make_materials = false
  g_config.item.make_materials_sec = 3
  g_config.item.make_materials_task = "刷怪"
  g_config.item.private_destroy = ""
  g_config.item.changyong_destroy = false
  g_config.item.znzblv_destroy = ReadConfigBool("ZH", "xzk60")
  g_config.item.znzblv_all_destroy = ReadConfigBool("ZH", "xzk109")
  g_config.item.destroy = {}
  g_config.item.destroy.class = {}
  g_config.item.destroy.name = {}
  local strBind = GetItemConfigText(g_self.name, "物品", "销毁绑定")
  local strUnBind = GetItemConfigText(g_self.name, "物品", "销毁")
  local strArr = SplitString(strBind, " ", true)
  for i = 1, #strArr do
    local str = strArr[i]
    table.insert(g_config.item.destroy.name, {data = 2, text = str})
    table.insert(g_config.item.destroy.class, {data = 2, text = str})
  end
  local strArr = SplitString(strUnBind, " ", true)
  for i = 1, #strArr do
    local str = strArr[i]
    table.insert(g_config.item.destroy.name, {data = 0, text = str})
    table.insert(g_config.item.destroy.class, {data = 0, text = str})
  end
  g_config.item.un_xhms = ""
  g_config.item.un_xiaohui = ""
  g_config.item.un_xhwq = false
  g_config.item.un_xhwq_min = 1
  g_config.item.un_xhwq_max = 119
  g_config.item.sale = {}
  g_config.item.sale.class = {}
  g_config.item.sale.name = {}
  g_config.item.changyong_sale = false
  g_config.item.xiaohua_wyhl = GetConfigCommbox("物品", "武约好礼")
  g_config.item.xiaohua_wjhd = GetConfigCommbox("物品", "物锦华袋")
  g_config.item.xiaohua_bind = GetItemConfigText(g_self.name, "物品", "消化绑定")
  g_config.item.xiaohua_unbind = GetItemConfigText(g_self.name, "物品", "消化非绑")
  local strSell = GetItemConfigText(g_self.name, "物品", "出售")
  local strArr = SplitString(strSell, " ", true)
  for i = 1, #strArr do
    local str = strArr[i]
    table.insert(g_config.item.sale.name, {data = 0, text = str})
    table.insert(g_config.item.sale.class, {data = 0, text = str})
  end
  g_config.item.take_bank = {}
  g_config.item.take_bank.name = {}
  g_config.item.take_bank.class = {}
  local strSell = GetItemConfigText(g_self.name, "物品", "取仓1")
  local strArr = SplitString(strSell, " ", true)
  for i = 1, #strArr do
    local str = strArr[i]
    table.insert(g_config.item.take_bank.name, {data = 0, text = str})
    table.insert(g_config.item.take_bank.class, {data = 0, text = str})
  end
  g_config.item.tempbag_qucang = ReadConfigBool("ZH", "xzk99")
  g_config.item.save_bank = {}
  g_config.item.save_bank.class = {}
  g_config.item.save_bank.name = {}
  g_config.item.tempbag_cuncang = ReadConfigBool("ZH", "xzk45")
  local strSaveBank = GetItemConfigText(g_self.name, "物品", "存仓")
  local strArr = SplitString(strSaveBank, " ", true)
  for i = 1, #strArr do
    local str = strArr[i]
    table.insert(g_config.item.save_bank.name, {data = 0, text = str})
    table.insert(g_config.item.save_bank.class, {data = 0, text = str})
  end
  g_config.item.temp_bag = {}
  g_config.item.temp_bag.class = {}
  g_config.item.temp_bag.name = {}
  local strSaveTempBank = GetItemConfigText(g_self.name, "物品", "存入锦囊")
  local strArr = SplitString(strSaveTempBank, " ", true)
  for i = 1, #strArr do
    local str = strArr[i]
    table.insert(g_config.item.temp_bag.name, {data = 0, text = str})
    table.insert(g_config.item.temp_bag.class, {data = 0, text = str})
  end
end

function GlobalParam_skill()
  g_config.skill = {}
  g_config.skill.shuaguai_gongji = GetConfigList("技能", "刷怪攻击")
  g_config.skill.shuaguai_zhuangtai = GetConfigList("技能", "刷怪状态")
  g_config.skill.shuaguai_zuhe1 = GetConfigList("技能", "组合1_列表")
  g_config.skill.shuaguai_zuhe1_use = GetConfigCommbox("技能", "组合1")
  g_config.skill.shuaguai_zuhe2 = GetConfigList("技能", "组合2_列表")
  g_config.skill.shuaguai_zuhe2_use = GetConfigCommbox("技能", "组合2")
  g_config.skill.fuben_gongji = GetConfigList("技能", "副本攻击")
  g_config.skill.fuben_zhuangtai = GetConfigList("技能", "副本状态")
  g_config.skill.pk_gongji = GetConfigList("技能", "PK攻击")
  g_config.skill.pk_kongzhi = GetConfigList("技能", "PK控制")
  g_config.skill.pk_zhuangtai = g_config.skill.fuben_zhuangtai
end

function GlobalParam_tysz()
  g_config.tysz = {}
  g_config.tysz.back_bangzhan = GetConfigBool("通用", "帮战不出地府")
  g_config.tysz.unback_bangzhan = "团战打架 峨嵋加血机"
  g_config.tysz.upgrade_pet_all = false
  g_config.tysz.upgrade_pet = false
  g_config.tysz.upgrade_pet_script = ""
  g_config.tysz.backcity = GetConfigText("通用", "空闲地图")
  g_config.tysz.backcity_x = GetConfigText("通用", "空闲X")
  g_config.tysz.backcity_y = GetConfigText("通用", "空闲Y")
  g_config.tysz.un_shgz = GetConfigBool("通用", "不走束河")
  g_config.tysz.un_bank_packup = GetConfigBool("通用", "禁整仓库")
  g_config.tysz.un_packup = GetConfigBool("通用", "禁整背包")
end

function GlobalParam_protect()
  g_config.protect = {}
  g_config.protect.pet_chuzhan = {}
  g_config.protect.pet_gongsheng = {}
  g_config.protect.pet_xueji = {}
  local pet1 = GetConfigCommbox("保护", "出战珍兽")
  local pet2 = GetConfigCommbox("保护", "共生珍兽")
  local pet3 = GetConfigCommbox("保护", "血祭珍兽")
  g_config.protect.pet_chuzhan.guid = pet1.data
  g_config.protect.pet_gongsheng.guid = pet2.data
  g_config.protect.pet_xueji.guid = pet3.data
  g_config.protect.pet_skill = GetConfigBool("保护", "珍兽技能")
  g_config.protect.qingxin = GetConfigBool("保护", "峨嵋清心")
  g_config.protect.chongxu = GetConfigBool("保护", "峨嵋冲虚")
  g_config.protect.em_fgpz = ReadConfigBool("ZH", "xzk114")
  g_config.protect.em_pet = GetConfigBool("保护", "峨嵋自己珍兽")
  g_config.protect.em_team = GetConfigBool("保护", "峨嵋队员加血")
  g_config.protect.em_raid = GetConfigBool("保护", "峨嵋团员加血")
  g_config.protect.em_banghui_self = false
  g_config.protect.em_tongmeng = false
  g_config.protect.em_banghui_other = GetConfigBool("保护", "帮会加血")
  g_config.protect.em_banghui_other_ids = GetConfigText("保护", "帮会加血ID")
  g_config.protect.em_check_mingdan = GetConfigBool("保护", "玩家加血")
  g_config.protect.em_mingdan = GetConfigList("保护", "玩家加血_列表")
  g_config.protect.em_check_first = false
  g_config.protect.em_first_mingdan = {}
  g_config.protect.hpp = HandleTextToNumber(GetConfigText("保护", "加血百分比"), 82)
  g_config.protect.mpp = HandleTextToNumber(GetConfigText("保护", "加蓝百分比"), 50)
  g_config.protect.hpp_pet = HandleTextToNumber(GetConfigText("保护", "加珍兽血百分比"), 72)
  g_config.protect.hp_skill = GetConfigBool("保护", "技能加血")
  g_config.protect.first_kouliang = GetConfigBool("保护", "优先珍兽口粮")
  g_config.protect.buy_pet_type1 = GetConfigCommbox("保护", "珍兽药_类1")
  g_config.protect.buy_pet_type1_count = GetConfigInt("保护", "珍兽药_量1")
  g_config.protect.buy_pet_type2 = GetConfigCommbox("保护", "珍兽药_类2")
  g_config.protect.buy_pet_type2_count = GetConfigInt("保护", "珍兽药_量2")
  g_config.protect.buy_jcy_count = GetConfigInt("保护", "红药_量")
  if g_config.protect.buy_jcy_count > 0 then
    g_config.protect.buy_jcy = true
  end
  g_config.protect.buy_glw_count = GetConfigInt("保护", "蓝药_量")
  if g_config.protect.buy_glw_count > 0 then
    g_config.protect.buy_glw = true
  end
  g_config.protect.buy_hxjq_count = GetConfigInt("保护", "回旋金球_量")
  if g_config.protect.buy_hxjq_count > 0 then
    g_config.protect.buy_hxjq = true
  end
end

function GlobalParamOther()
  g_config.fuben = {}
  g_config.fuben.ty_select_target = ReadConfigBool("ZH", "xzk85")
  g_config.fuben.ty_un_openbox = GetConfigBool("副本", "不开宝箱")
  g_config.fuben.ty_manxue_end = ReadConfigBool("ZH", "xzk283")
  g_config.fuben.ty_buji_end = ReadConfigBool("ZH", "xzk103")
  g_config.fuben.ty_cuncang_end = ReadConfigBool("ZH", "xzk174")
  g_config.fuben.ty_buy_pet_script = ""
  g_config.fuben.ty_buy_pet = {
    sel = 0,
    text = "后肘肉口粮",
    data = 0
  }
  g_config.fuben.ty_buy_pet_count = 0
  g_config.fuben.ty_hg_name = ""
  g_config.fuben.ty_em_yxjx = false
  g_config.nottongbu = {}
  g_config.nottongbu.fuben_ty_xhmode = GetConfigBool("副本", "小号模式")
  g_config.nottongbu.fuben_ty_not_attack = g_config.nottongbu.fuben_ty_xhmode
  g_config.nottongbu.fuben_ty_hongguai = false
end

function SG_ParseConfig()
  g_config.shuaguai = {}
  g_config.shuaguai.unuse_skill = false
  g_config.shuaguai.send_diff_tick = ReadConfigInt("ZH", "bjk36")
  if ReadConfigBool("ZH", "xzk39") then
    g_config.shuaguai.mode_xiezhuduizhang = true
  elseif ReadConfigBool("ZH", "dxk9") then
    g_config.shuaguai.mode_chonglarenda = true
  elseif ReadConfigBool("ZH", "dxk10") then
    g_config.shuaguai.mode_petdanshua = true
  elseif ReadConfigBool("ZH", "dxk12") then
    g_config.shuaguai.mode_youxianlvguai = true
  elseif ReadConfigBool("ZH", "dxk13") then
    g_config.shuaguai.mode_zhanshen = true
  elseif ReadConfigBool("ZH", "dxk14") then
    g_config.shuaguai.mode_qiangguai_1 = true
  elseif ReadConfigBool("ZH", "dxk18") then
    g_config.shuaguai.mode_qiangguai_2 = true
  end
  g_config.shuaguai.scene = GetConfigCommbox("刷怪", "挂机地图")
  if 1 == g_config.shuaguai.scene.sel then
    g_config.shuaguai.current_scene = true
  end
  g_config.shuaguai.follow_leader_pos = ReadConfigBool("ZH", "xzk38")
  g_config.shuaguai.follow_leader_scene = false
  g_config.shuaguai.move_follow = false
  g_config.shuaguai.current_pos = ReadConfigBool("ZH", "xzk70")
  g_config.shuaguai.mulit_poslist = GetConfigListCtrlEx("刷怪", "挂机坐标", 3)
  g_config.shuaguai.banjing = ReadConfigInt("ZH", "bjk10")
  g_config.shuaguai.item_backpos = ReadConfigBool("ZH", "xzk40")
  g_config.shuaguai.check_only_name = ReadConfigBool("ZH", "xzk33")
  g_config.shuaguai.only_name = ReadConfigText("ZH", "148")
  g_config.shuaguai.only_red_monster = ReadConfigBool("ZH", "xzk90")
  g_config.shuaguai.only_white_monster = ReadConfigBool("ZH", "xzk91")
  g_config.shuaguai.diaoxueyinshen = ReadConfigBool("ZH", "xzk160")
  g_config.shuaguai.pickup = ReadConfigBool("ZH", "xzk34")
  g_config.shuaguai.exp_item_t = ReadConfigBool("ZH", "xzk35")
  g_config.shuaguai.exp_item_d = ReadConfigBool("ZH", "xzk162")
  g_config.shuaguai.exp_item_x = ReadConfigBool("ZH", "xzk163")
  g_config.shuaguai.exp_double = false
  g_config.shuaguai.check_levelup = ReadConfigBool("ZH", "xzk36")
  g_config.shuaguai.levelup_count = ReadConfigInt("ZH", "bjk68")
  g_config.shuaguai.petaddattr = false
  g_config.shuaguai.over_check_monster_count = true
  g_config.shuaguai.over_monster_count = ReadConfigInt("ZH", "bjk11")
  g_config.shuaguai.over_check_wuyi = ReadConfigBool("ZH", "xzk237")
  g_config.shuaguai.die_out = ReadConfigBool("ZH", "xzk132")
  g_config.shuaguai.die_wait_time = 0
  g_config.shuaguai.over_check_die = true
  g_config.shuaguai.over_die_count = ReadConfigInt("ZH", "bjk12")
  g_config.shuaguai.over_check_jingli = ReadConfigBool("ZH", "xzk97")
  g_config.shuaguai.over_jingli_value = ReadConfigInt("ZH", "bjk22")
  g_config.shuaguai.buji_chongliang = ReadConfigBool("ZH", "xzk44")
  g_config.shuaguai.buji_hp = false
  g_config.shuaguai.buji_huixuanjinqiu = ReadConfigBool("ZH", "xzk152")
  g_config.shuaguai.check_bag_full = ReadConfigBool("ZH", "xzk98")
  g_config.shuaguai.check_bag_full_daoju = ReadConfigBool("ZH", "dxk11")
  g_config.shuaguai.check_bag_full_cailiao = ReadConfigBool("ZH", "dxk15")
  g_config.shuaguai.check_bag_full_all = ReadConfigBool("ZH", "dxk16")
  g_config.shuaguai.die_rescue = false
  g_config.shuaguai.pet_level_up = ReadConfigBool("ZH", "xzk216")
end

function GlobalParam_team()
  g_config.team = {}
end

function GlobalParamInit()
  GlobalParam_skill()
  GlobalParam_item()
  GlobalParam_tysz()
  GlobalParam_protect()
  GlobalParamOther()
  GlobalParam_team()
end

function GlobalParam_shgl()
  g_config.shgl = {}
  g_config.shgl.id_text = ReadConfigText("ZH", "bjk104")
  g_config.shgl.cun_bag = ReadConfigBool("ZH", "xzk148")
  g_config.shgl.cun_allbag = ReadConfigBool("ZH", "xzk29")
  g_config.shgl.cun_bank = ReadConfigBool("ZH", "xzk30")
  g_config.shgl.cun_allbank = ReadConfigBool("ZH", "xzk31")
  g_config.shgl.sale_all_item = ReadConfigBool("ZH", "xzk269")
  g_config.shgl.update_sell_price = ReadConfigBool("ZH", "xzk149")
  g_config.shgl.not_sale_item = ""
  g_config.shgl.ty_price = GetConfigCommbox("商会管理", "通用定价")
  g_config.shgl.max_price_diff = ReadConfigInt("ZH", "bjk2")
  g_config.shgl.list_item = {}
  local allList = GetConfigListCtrlEx("商会管理", "物品列表", 6)
  for i = 1, #allList do
    local tmp = allList[i]
    if 6 == #tmp then
      local strText = tmp[1] .. "|" .. tmp[4] .. "|" .. tmp[3] .. "|" .. tmp[5] .. "|" .. tmp[2] .. "|" .. tmp[6]
      table.insert(g_config.shgl.list_item, strText)
    end
  end
end

function GetConfigPath()
  if g_self.name == "" then
    Player_GetName()
  end
  local strPath = g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\配置.ini"
  return strPath
end

function ReadConfigText(aAppName, aKeyName, aPath)
  local strPath = aPath or GetConfigPath()
  return DoSystem(6, aKeyName, aAppName, strPath)
end

function ReadConfigInt(aJieName, aField)
  local strText = ReadConfigText(aJieName, aField)
  local n = HandleTextToNumber(strText)
  return n
end

function ReadConfigBool(aJieName, aField)
  local strText = ReadConfigText(aJieName, aField)
  if "1" == strText then
    return true
  end
  return false
end

function ReadConfigCommbox(aJieName, aField)
  return {
    sel = -1,
    text = "",
    data = 0
  }
end

function ReadConfigList(aJieName, aField)
  local obj = {}
  return obj
end

function DiscardBagItem(aIndex, aSleep)
  if aIndex >= 0 and aIndex <= BAG_CAILIAO_MAX then
    CallFun(5, aIndex, 2)
    if aSleep then
      Sleep(aSleep)
    end
  end
end

function DiscardTempBagItem(aIndex, aSleep)
  CallFun(5, aIndex, 126)
  if aSleep then
    Sleep(aSleep)
  end
end
