-- 反编译自 dfz64.dll 内嵌字节码 004ab809（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：表键 洛阳 → ["洛阳"]（1 处）；表键 苏州 → ["苏州"]（1 处）
local m_tick_TalkChat = -1
local m_MoveInfo = {
  last_time = 0,
  x = 0,
  y = 0,
  angle = 0,
  start_tick = 0,
  sd_x = 0,
  sd_y = 0,
  sd_tick = 0
}
g_lootOld = {}
g_pick = {
  ispick = true,
  pickmode = 1,
  pickItem = "",
  lastpicktime = -1,
  check = false,
  filterMode = 0
}

function GetUserScriptPath(aFileName)
  Player:GetName()
  local strPath = ""
  local file = io.open(g_public_dir .. "角色设置/私有设置/" .. g_self.name .. "/" .. aFileName, "r")
  if file then
    strPath = g_public_dir .. "角色设置/私有设置/" .. g_self.name .. "/" .. aFileName
    io.close(file)
  end
  return strPath
end

function GetDist(x1, y1, x2, y2)
  if type(x1) ~= "number" or type(y1) ~= "number" then
    PushDebugMessage("GetDist参数1错误")
  end
  if nil == x2 or nil == y2 then
    local pos = Player:GetPos()
    x2 = pos.x
    y2 = pos.y
  elseif type(x2) ~= "number" or type(y2) ~= "number" then
    PushDebugMessage("GetDist参数2错误")
  end
  local dist = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
  return math.sqrt(dist)
end

function GetAngle(x1, y1, x2, y2)
  if x1 < x2 and y2 < y1 then
    return 90 - math.atan(math.abs((y2 - y1) / (x2 - x1))) * 180 / math.pi
  elseif x1 < x2 and y1 < y2 then
    return 90 + math.atan(math.abs((y2 - y1) / (x2 - x1))) * 180 / math.pi
  elseif x2 < x1 and y1 < y2 then
    return 180 + (90 - math.atan(math.abs((y2 - y1) / (x2 - x1))) * 180 / math.pi)
  elseif x2 < x1 and y2 < y1 then
    return 270 + math.atan(math.abs((y2 - y1) / (x2 - x1))) * 180 / math.pi
  elseif x1 == x2 and y2 < y1 then
    return 0
  elseif x1 == x2 and y1 < y2 then
    return 180
  elseif x1 < x2 and y1 == y2 then
    return 90
  elseif x2 < x1 and y1 == y2 then
    return 270
  end
  return 0
end

function GetAnglePos(aPos, aAngle, aDist)
  local pos = {}
  if aAngle > 0 and aAngle <= 90 then
    local angle = 90 - aAngle
    local zx = math.cos(angle * math.pi / 180) * aDist
    local zy = math.sin(angle * math.pi / 180) * aDist
    pos.x = aPos.x + zx
    pos.y = aPos.y - zy
  elseif aAngle > 90 and aAngle <= 180 then
    local angle = aAngle - 90
    local zx = math.cos(angle * math.pi / 180) * aDist
    local zy = math.sin(angle * math.pi / 180) * aDist
    pos.x = aPos.x + zx
    pos.y = aPos.y + zy
  elseif aAngle > 180 and aAngle <= 270 then
    local angle = 270 - aAngle
    local zx = math.cos(angle * math.pi / 180) * aDist
    local zy = math.sin(angle * math.pi / 180) * aDist
    pos.x = aPos.x - zx
    pos.y = aPos.y + zy
  elseif 0 == aAngle or aAngle > 270 and aAngle <= 360 then
    local angle = aAngle - 270
    local zx = math.cos(angle * math.pi / 180) * aDist
    local zy = math.sin(angle * math.pi / 180) * aDist
    pos.x = aPos.x - zx
    pos.y = aPos.y - zy
  end
  pos.angle = aAngle
  return pos
end

function GetTargetAngle(aTarget)
  local fMaxAngle = 6.2831854820251
  local modulus = 57.295777918682
  local tarAngle = aTarget.fx * modulus
  if tarAngle > 360 then
    tarAngle = 360
  end
  if tarAngle >= 0 and tarAngle < 180 then
    tarAngle = 180 - tarAngle
  elseif tarAngle >= 180 and tarAngle <= 360 then
    tarAngle = 360 - (tarAngle - 180)
  end
  return tarAngle
end

function R_P(aPtr)
  return R_M(aPtr, 6)
end

function R_D(aPtr)
  return R_M(aPtr, 1)
end

function R_W(aPtr)
  return R_M(aPtr, 2)
end

function R_B(aPtr)
  return R_M(aPtr, 3)
end

function R_F(aPtr)
  return R_M(aPtr, 4)
end

function R_S(aPtr)
  return R_M(aPtr, 5)
end

function IsProcess64()
  return DoSystem(21)
end

function PickAll()
  CallFun(1)
end

function OpenPackage(aID)
  CallFun(2, aID)
end

function OpenTalk(aID, aSleep)
  CallFun(3, aID)
  if aSleep then
    Sleep(aSleep)
  end
end

function GetBase(aType)
  return DoSystem(18, aType)
end

function GetCurrentProcessId()
  return DoSystem(5)
end

function GetGamePath()
  return DoSystem(9)
end

function GetMainPath()
  return DoSystem(22)
end

function IniConfigGet(aKeyName, aFileName, aAppName, aPath)
  aAppName = aAppName or "设置"
  aPath = aPath or g_public_dir .. "角色设置\\私有设置\\" .. aFileName .. "\\用户配置.ini"
  return DoSystem(6, aKeyName, aAppName, aPath)
end

function IniConfigSet(aKeyName, aText, aFileName, aAppName, aPath)
  aAppName = aAppName or "设置"
  aPath = aPath or g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\" .. aFileName .. ".ini"
  DoSystem(7, aKeyName, aText, aAppName, aPath)
end

function SetShopBuyName(aItem)
  local strItem = HandleText_AddFuHao(aItem, " ", true)
  DoSystem(1003, strItem)
end

function PlayerConfigGet(aKeyName, aAppName)
  local strPath = g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\运行配置.ini"
  return DoSystem(6, aKeyName, aAppName, strPath)
end

function PlayerConfigSet(aKeyName, aText, aAppName)
  local strPath = g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\运行配置.ini"
  DoSystem(7, aKeyName, aText, aAppName, strPath)
end

function GC_Get(aKeyName, aAppName)
  if type(aKeyName) == "string" and #aKeyName > 0 then
    local strPath = g_public_dir .. "角色设置\\公共配置.ini"
    return IniConfigGet(aKeyName, nil, aAppName, strPath)
  end
  return ""
end

function GC_Set(aKeyName, aText, aAppName)
  if type(aKeyName) == "string" and type(aText) == "string" and #aKeyName > 0 then
    local strPath = g_public_dir .. "角色设置\\公共配置.ini"
    IniConfigSet(aKeyName, aText, nil, aAppName, strPath)
  end
end

function SetCheckLeaderSceneState(aState)
  DoSystem(1005, aState)
end

function MainRunScript(aScriptName)
  DoSystem(2000, aScriptName)
end

function MainStopRun(aParam)
  DoSystem(2001, aParam)
end

function GetLocalPlayerScript(aPlayerName)
  if type(aPlayerName) ~= "string" or 0 == #aPlayerName then
    return ""
  end
  return DoSystem(2002, aPlayerName)
end

function GetLocalPlayerName()
  DoSystem_old(7783)
  Sleep(200)
  local localName = ReadFile(g_public_dir .. "runtime/localplayername")
  localName = HandleText_AddFuHao(localName, " ", true)
  return localName
end

function GetMainState()
  local key = SetThreadKeyState(-1, -1)
  return key
end

function MainSuspend()
  if 1 == GetMainState() then
    SetThreadKeyState(1, 0)
  end
end

function MainResume()
  if 0 == GetMainState() then
    SetThreadKeyState(0, -1)
  end
end

function SP_OpenTalk(aID)
  CallFun(10, aID)
end

function OpenDitan(aID)
  CallFun(7, aID)
end

function SP_DialogOptionClicked(aNpcID, aScriptID, aOptionID)
  CallFun(11, aNpcID, aScriptID, aOptionID)
end

function SP_OpenTalkAndClickedOption(aNpcID, aScriptID, aOptionID)
  CallFun(12, aNpcID, aScriptID, aOptionID)
end

function SP_OpenTalkAndClickedClickedOption(aNpcID, aScriptID, aOptionID, aOptionID2)
  CallFun(13, aNpcID, aScriptID, aOptionID, aOptionID2)
end

function SP_SendJiaoYiAsk(aTargetID)
  CallFun(14, aTargetID)
end

function SP_ZhuangBeiZY(aBagIndex, aToIndex)
  aBagIndex = aBagIndex + 35
  if aBagIndex < 36 or aBagIndex > 59 then
    PushColorMsg("参数1错误")
    return
  end
  if aToIndex < 0 or aToIndex > 11 then
    PushColorMsg("参数2错误")
    return
  end
  CallFun(15, aBagIndex, aToIndex)
end

function SP_SkillToBar(aSkillID, aBarIndex)
end

function SP_ZhenJiu(aTargetID)
  CallFun(16, aTargetID)
end

function SP_ShopBuyItem(aShopIndex, aCheckValuse, aNpcID, aSceneID)
  CallFun(17, aShopIndex, aCheckValuse, aNpcID, aSceneID)
end

function SP_BuyShop(aShopID)
  CallFun(18, aShopID)
end

function GetDictionaryString(aStr)
  if "" == aStr then
    return ""
  end
  return GetLuaValue(fmt("return meGetDictionaryString('%s')", aStr), "s")
end

function AskFriend(aFriendName)
  local strText = fmt([[
        local szName = "%s"
		if Friend:IsPlayerIsFriend(szName,-1) == 1 then
            g_zs_show_friend_info = 0
            g_zs_show_friend_kvk_info = 0
			DataPool:ShowFriendInfo(szName)
			return 1
		end
		return 0
    ]], aFriendName)
  local isFriend = GetLuaValue(strText, "b")
  return isFriend
end

function SplitItem_back(aPosIndex, aSplitNum)
  aSplitNum = aSplitNum or 1
  CallFun(8, aPosIndex)
  Sleep(50)
  local strText = fmt([[
            local szName = PlayerPackage:GetSplitName()
            if szName == nil or type(szName) ~= "string" or szName == ""  then
            else
                PlayerPackage:SplitItem(%d)
            end
        ]], aSplitNum)
  GetLuaValue(strText)
  Sleep(250)
end

function SetShangHuiSel(aActPage, aPosIndex)
  CallFun(9, aActPage, aPosIndex)
end

function SplitItem(aPosIndex, aSplitNum)
  aSplitNum = aSplitNum or 1
  local strText = fmt("            local nIndex = %d\n            local splitNum = %d\n            local theAction = EnumAction(nIndex, \"packageitem\")\n            local splitID = theAction:GetID()\n            if splitID ~= 0 then\n                if theAction:GetNum() > splitNum then\n                    setmetatable(_G, {__index = Packet_Env})\n                    PrepearAsunder()\n                    local oldID = Packet_Space_Line1_Row1_button:GetActionItem();\n\t\t            Packet_Space_Line1_Row1_button:SetActionItem(splitID);\n\t\t            Packet_Space_Line1_Row1_button:DoSubAction();\n\t\t            Packet_Space_Line1_Row1_button:SetActionItem(oldID);\n                    local szName = PlayerPackage:GetSplitName()\n                    PushDebugMessage(\"拆分:\" .. szName)\n                    if szName == nil or type(szName) ~= \"string\" or szName == \"\" then\n                    else\n                        PlayerPackage:SplitItem(splitNum)\n                    end\n                end\n            end\n        ", aPosIndex, aSplitNum)
  GetLuaValue(strText)
  Sleep(200)
  IsWindowVisible("SplitItem", "this:Hide()")
end

function SendTalkChatMsg(aWhere, aTalkMsg, aTimeDiff)
  aTimeDiff = aTimeDiff or 10
  local nowTick = GetTickCount()
  if nowTick - m_tick_TalkChat > 1000 * aTimeDiff then
    TalkChatMsg(aWhere, aTalkMsg)
    m_tick_TalkChat = GetTickCount()
  end
end

function DieRelive(aType)
  GetLuaValue(fmt("meReliveHandle(%d)", aType))
end

function GetSceneMapByID(aID)
  return GetLuaValue("return GetSceneMapByID(" .. aID .. ")", "s")
end

function GetMapIDBySceneID(aSceneID)
  if 242 == aSceneID then
    return 0
  end
  return GetLuaValue(fmt("return Lua_GetSceneIDByResID(%d)", aSceneID), "n")
end

function GetSceneServerID()
  return GetLuaValue("return GetSceneServerID()", "n")
end

function GetSceneNameByResID(aResID)
  return GetLuaValue(fmt("return GetSceneNameByID(%d)", aResID), "s")
end

function GetSceneNameByID(aSceneID)
  local scene_id = tonumber(aSceneID)
  local scene_name = ""
  if scene_id and scene_id >= 0 and scene_id < 65535 then
    if 242 == scene_id then
      return "洛阳"
    end
    scene_name = GetLuaValue(fmt([[
                    local sceneName =  GetSceneNameByResID(%d) 
                    if sceneName == nil then 
                        sceneName = ""
                    end                  
                    return sceneName   
                ]], scene_id), "s")
  end
  return scene_name
end

function GetSceneIDByName(aSceneName)
  if type(aSceneName) == "string" and "" ~= aSceneName then
    if "洛阳" == aSceneName or "洛阳1线" == aSceneName or "洛阳2线" == aSceneName then
      return LUOYANG_ID
    end
    return CGetSceneIDByName(aSceneName)
  end
  return -1
end

function IsMenpaiJinGong(aMenPai)
  if 0 == aMenPai or 1 == aMenPai or 2 == aMenPai or 7 == aMenPai or 10 == aMenPai or 9 == aMenPai then
    return true
  end
  return false
end

function GetMenpaiIDByName(aMenPaiName)
  if aMenPaiName then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.menpaiName == aMenPaiName then
        return tmp.menpaiID
      end
    end
  end
  return -1
end

function GetMenpaiNameByID(menpaiID)
  if menpaiID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.menpaiID == menpaiID then
        return tmp.menpaiName
      end
    end
  end
  return ""
end

function GetMenpaiNameByTypeID(aTypeID)
  if aTypeID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.typeID == aTypeID then
        return tmp.menpaiName
      end
    end
  end
  return ""
end

function GetMenpaiIDByTypeID(aTypeID)
  if aTypeID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.typeID == aTypeID then
        return tmp.menpaiID
      end
    end
  end
  return -1
end

function GetSceneIDByMenpaiID(menpaiID)
  if menpaiID then
    for i = 1, #g_MenPaiInfo do
      local tmp = g_MenPaiInfo[i]
      if tmp.menpaiID == menpaiID then
        return tmp.sceneID
      end
    end
  end
  return -1
end

function QuestGetButtonText(aBtnName)
  return GetLuaValue(fmt([[
                setmetatable(_G, { __index = Quest_Env })
                if this:IsVisible() then 
                    local strText = Quest_Button_%s:GetText()
                    if strText ~= nil then
                        return strText            
                    end  
                end     	
                return ""
            ]], aBtnName), "s")
end

function QuestFrameNextClicked(aSleep)
  for i = 1, 5 do
    if QuestGetButtonText("Continue") == "继续" then
      GetLuaValue("setmetatable(_G, {__index = Quest_Env}) if this:IsVisible() then QuestFrameMissionContinue() end")
      Sleep(200)
    else
      break
    end
  end
  if aSleep then
    Sleep(aSleep)
  end
end

function QuestFrameMissionComplete(aIdItem, aSleep)
  aIdItem = aIdItem or 0
  for i = 1, 5 do
    if QuestGetButtonText("Continue") == "完成" then
      GetLuaValue(fmt("setmetatable(_G, {__index = Quest_Env}) if this:IsVisible() then QuestFrameMissionComplete(%d);this:Hide() end", aIdItem))
      Sleep(200)
    else
      break
    end
  end
  if aSleep then
    Sleep(aSleep)
  end
end

function QuestFrameAcceptClicked(aSleep)
  if QuestGetButtonText("Accept") == "接受" then
    GetLuaValue("setmetatable(_G, {__index = Quest_Env}) if this:IsVisible() then QuestFrameAcceptClicked() end")
    Sleep(200)
  end
  if aSleep then
    Sleep(aSleep)
  end
end

function QuestFrameMissionAbnegate(aScriptID)
  if aScriptID > -1 then
    GetLuaValue(fmt("QuestFrameMissionAbnegate(%d);", aScriptID))
    Sleep(1000)
  end
end

function DialogOptionClicked(aOption, aCmp, aSleep)
  if type(aOption) ~= "string" or "" == aOption then
    return false
  end
  aCmp = aCmp or 1
  local bClick = GetLuaValue(fmt("return meQuestOptionClicked([[%s]],%d)", aOption, aCmp), "b")
  if bClick and aSleep then
    Sleep(aSleep)
  end
  return bClick
end

function QuestFrameOptionClicked_Item(aOption, aCmp, aSleep)
  if type(aOption) ~= "string" or "" == aOption then
    return false
  end
  aCmp = aCmp or 1
  local bClick = GetLuaValue(fmt("return meQuestOptionClicked_Item([[%s]],%d)", aOption, aCmp), "b")
  if bClick and aSleep then
    Sleep(aSleep)
  end
  return bClick
end

function QuestFrameOptionClicked_ScriptID_Extra(aScriptID, aExtra, aSleep)
  local nClick = GetLuaValue("return meQuestOptionClicked_ScriptID_Extra(" .. aScriptID .. "," .. aExtra .. ")", "n")
  if 1 == nClick and aSleep then
    Sleep(aSleep)
  end
  return nClick
end

function GetNPCEventListAllItem()
  local szText = [[
            setmetatable(_G, {__index = Quest_Env})
            if not this:IsVisible() then
                return "", 0
            end
            local nListCount = DataPool:GetNPCEventList_Num()
            local szText = " "
            for i = 0, nListCount-1 do
                local strType, _, strScriptID, strExtra, strTemp = DataPool:GetNPCEventList_Item(i)
                szText = szText .. strTemp .. " "
            end
            return szText, nListCount
        ]]
  return GetLuaValue(szText, "sn")
end

function GetNPCEventList_Item(aIndex)
  local strCodes = fmt([[
            setmetatable(_G, {__index = Quest_Env})
            if this:IsVisible() then
                local idx = %d
                local nListCount = DataPool:GetNPCEventList_Num()
                if idx <= nListCount - 1 then
                    local strType, _, strScriptID, strExtra, strTemp = DataPool:GetNPCEventList_Item(idx)
                    if strTemp ~= nil then
                        return strTemp, strType
                    end
                end
            end
            return "", ""       
        ]], aIndex)
  return GetLuaValue(strCodes, "ss")
end

function FindQuestFrameOption(aOption)
  aOption = aOption or ""
  local allText, allCount = GetNPCEventListAllItem()
  allText = HandleText_AddFuHao(allText, " ")
  local strFind = HandleText_AddFuHao(aOption)
  if string.find(allText, strFind, nil, true) then
    return true
  end
  return false
end

function GetMissionVariable(aMissionIndex, aParamIndex)
  if aMissionIndex < 0 or aMissionIndex > 19 then
    return -1
  end
  return GetLuaValue(fmt([[
                local mission_idx = %d
                if (DataPool:GetPlayerMission_InUse(mission_idx) == 1) then
                    return DataPool:GetPlayerMission_Variable(mission_idx, %d)
                end  
                return -1
            ]], aMissionIndex, aParamIndex), "n")
end

function GetMissionComplete(aMissionIndex)
  return GetMissionVariable(aMissionIndex, 0)
end

function GetPlayerMission(aOption, aCmp)
  if type(aOption) ~= "string" or "" == aOption then
    return -1, -1, -1
  end
  aCmp = aCmp or 1
  local strTemp = fmt([[
        local aOption ="%s"
        local aCmp = %d
        meRefreshMission()
        for i = 0, 19 do
            if (DataPool:GetPlayerMission_InUse(i) == 1) then
                local strTemp = DataPool:GetPlayerMission_Memo(i)
                local strFanyi = meGetDictionaryString(strTemp)
                if aCmp == 1 then
                    if strTemp == aOption or strFanyi == aOption then
                        local nMissionID = DataPool:GetPlayerMission_Name(i)
                        nMissionID = string.gsub(nMissionID, "Mission:", "")
                        return i, tonumber(nMissionID), DataPool:GetPlayerMission_Display(i, 7)
                    end
                elseif aCmp == 3 then
                    if string.find(strFanyi, aOption,nil,true) then
                        local nMissionID = DataPool:GetPlayerMission_Name(i)
                        nMissionID = string.gsub(nMissionID, "Mission:", "")
                        return i, tonumber(nMissionID), DataPool:GetPlayerMission_Display(i, 7)
                    end
                end
            end
        end
        return -1, -1, -1		
      ]], aOption, aCmp)
  return GetLuaValue(strTemp, "nnn")
end

function GetPlayerMission_ID(aIdMission)
  local strTemp = fmt([[
           meRefreshMission();
            local idMis = %d
            for i = 0, 19 do
                if (DataPool:GetPlayerMission_InUse(i) == 1) then
                    local szMissionID = DataPool:GetPlayerMission_Name(i)
                    szMissionID = string.gsub(szMissionID, "Mission:", "")
                    local nMissionID = tonumber(szMissionID)
                    if nMissionID and nMissionID == idMis then         
                        return i, DataPool:GetPlayerMission_Display(i, 7)
                    end
                end
            end
            return -1, -1	
      ]], aIdMission)
  return GetLuaValue(strTemp, "nn")
end

function GetPlayerMission_Item(aItemName)
  local szTemp = fmt([[
            meRefreshMission();
            for i = 0, 19 do
                if (DataPool:GetPlayerMission_InUse(i) == 1) then
                    local strTemp = DataPool:GetPlayerMission_Memo(i)
                    if strTemp == "%s" then
                        local nMissionID = DataPool:GetPlayerMission_Name(i)
                        nMissionID = string.gsub(nMissionID, "Mission:", "")
                        return i, tonumber(nMissionID), DataPool:GetPlayerMission_Display(i, 7)
                    end
                end
            end
            return -1, -1, -1		
        ]], aItemName)
  return GetLuaValue(szTemp, "nnn")
end

function GetPlayerMissionAllName()
  local szTemp = [[
        meRefreshMission();
            local strAllName = " "
            for i = 0, 19 do
                if (DataPool:GetPlayerMission_InUse(i) == 1) then
                    local strTemp = DataPool:GetPlayerMission_Memo(i)
                    if type(strTemp)=="string" and strTemp ~="" then 
                        strAllName = strAllName .. strTemp .. " "
                    end
                end
            end
            return strAllName
        ]]
  return GetLuaValue(szTemp, "s")
end

function GetMissionVariableByName_Item(aMissionName, aIndex)
  local nIndex, idMission, idScript = GetPlayerMission_Item(aMissionName)
  local nParam = GetMissionVariable(nIndex, aIndex)
  return nParam, nIndex
end

function GetMissionDesc(aMissionName)
  local strDesc = GetLuaValue(fmt([[
            meRefreshMission();
            for i = 0, 19 do
                if (DataPool:GetPlayerMission_InUse(i) == 1) then
                    local strInfo, strDesc = DataPool:GetPlayerMission_Memo(i)
                    if strInfo == "%s" then
                        return strDesc
                    end
                end
            end
            return ""
        ]], aMissionName), "s")
  if type(strDesc) ~= "string" or "" == strDesc then
    PushDebugMessage("%s：没有获取到任务参数", aMissionName)
    strDesc = ""
  end
  local posEnd = string.find(strDesc, "#G小提示", nil, true)
  if posEnd then
    strDesc = string.sub(strDesc, 0, posEnd - 1)
  end
  return strDesc
end

function GetMissionDesc_NPC(aMissionName, aHideMsg)
  local npc
  local strDesc = GetMissionDesc(aMissionName)
  local _, _, fX, fY, nSceneID, szNpcName = string.find(strDesc, "{.-(%d+),(%d+),(%d+),(.-)}")
  fX = tonumber(fX)
  fY = tonumber(fY)
  nSceneID = tonumber(nSceneID)
  if fX and fY and nSceneID and szNpcName then
    npc = {
      x = fX,
      y = fY,
      sceneID = nSceneID,
      name = szNpcName
    }
    if 0 == npc.sceneID then
      npc.sceneID = LUOYANG_ID
    end
    if npc.name == "-1" then
      npc.name = ""
    end
  elseif not aHideMsg then
    PushColorMsg("%s：没有解析到正确的npc参数", aMissionName)
    ShowTipMsg(strDesc)
  end
  return npc
end

function GetMissionDesc_CatchPet(aMissionName)
  local npc
  local strDesc = GetMissionDesc(aMissionName)
  local _, _, strPetName, strSceneName, fX, fY, nSceneID, szNpcName = string.find(strDesc, "#R(.-)#W.-#B(.-)#{.-(%d+),(%d+),(%d+),(.-)}#W")
  fX = tonumber(fX)
  fY = tonumber(fY)
  nSceneID = tonumber(nSceneID)
  if strPetName and strSceneName and fX and fY and nSceneID and szNpcName then
    npc = {
      pos = {
        {x = fX, y = fY}
      },
      sceneID = nSceneID,
      name = szNpcName,
      petName = strPetName,
      sceneName = strSceneName
    }
    if 0 == npc.sceneID then
      npc.sceneID = LUOYANG_ID
    end
    if npc.name == "-1" then
      npc.name = ""
    end
  end
  return npc
end

function TalkNpc(aNpcName, aSleep)
  if type(aNpcName) == "string" and "" ~= aNpcName then
    local strText = fmt("SetAutoRunTargetNPCName([[%s]])", aNpcName)
    GetLuaValue(strText)
    if aSleep then
      Sleep(aSleep)
    end
  end
end

function Dismount(aSleep)
  if Player:DispelBuffByName("坐骑：") then
    SleepCallBack(500, 30, IsMount)
    if IsInDebugMsgTime("#{FLY_101118_10}", 1, 5) then
      GetLuaValue("Player:UseSkillInLua_Const();")
      Sleep(800)
    end
    if aSleep then
      Sleep(aSleep)
    end
    return false
  end
  return true
end

function UseMount()
  if IsMount() == false then
    local function _IsZuoQi()
      return not IsMount()
    end
    
    GetLuaValue("Player:UseSkillInLua_Const();")
    SleepCallBack(5000, 100, _IsZuoQi)
    if IsInDebugMsg("#{WGTJ_201222_106}") then
      GetLuaValue("                Exterior:LuaFnInitExteriorList(0)\n                local cacheExteriorID = Exterior:LuaFnGetCurrentExteriorSetInfo(\"RIDE\")\n                if cacheExteriorID ~= nil and cacheExteriorID > 0 then\n                else\n                    meTestMsg(\"您没有装备坐骑,尝试自动装备坐骑\", 1)\n                    local nExteriorID = Exterior:LuaFnGetExteriorIDFromList(0, 0)\n                    if nExteriorID ~= -1 then\n                        Exterior:LuaFnSetCurrentExteriorSetInfo(\"RIDE\", nExteriorID)\n                        Exterior:LuaFnSaveExteriorAllChange(1)\n                    end\n                end\n\n            ")
      DeleteDebugMsg("#{WGTJ_201222_106}")
      GetLuaValue("Player:UseSkillInLua_Const();")
      SleepCallBack(5000, 100, _IsZuoQi)
    end
  end
end

function IsCityName(aSceneName)
  aSceneName = aSceneName or GetCurrentSceneName()
  aSceneName = string.gsub(aSceneName, "1线", "")
  aSceneName = string.gsub(aSceneName, "2线", "")
  if "洛阳" == aSceneName then
    return true
  elseif "苏州" == aSceneName then
    return true
  elseif "大理" == aSceneName then
    return true
  elseif "楼兰" == aSceneName then
    return true
  elseif "束河古镇" == aSceneName then
    return true
  elseif "凤鸣镇" == aSceneName then
    return true
  elseif "金陵" == aSceneName then
    return true
  else
    return false
  end
end

function GetKvkUnCityScene()
  return {
    854,
    855,
    856,
    857,
    858,
    859,
    860
  }
end

function IsUnSafeSceneID(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  local un_safe_scene = {
    3,
    4,
    5,
    6,
    7,
    8,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    112,
    166,
    199
  }
  ArrayInsertTable(un_safe_scene, {
    200,
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    209,
    210,
    211,
    212,
    213,
    214,
    215,
    216,
    217,
    218,
    219
  })
  ArrayInsertTable(un_safe_scene, {
    220,
    221,
    222,
    223,
    229,
    235,
    237,
    283
  })
  ArrayInsertTable(un_safe_scene, {
    244,
    245,
    247,
    248,
    249,
    250,
    251,
    252,
    253,
    254,
    255,
    256
  })
  ArrayInsertTable(un_safe_scene, {260, 282})
  ArrayInsertTable(un_safe_scene, {
    262,
    263,
    264,
    292
  })
  ArrayInsertTable(un_safe_scene, GetKvkUnCityScene())
  for i = 1, #un_safe_scene do
    if un_safe_scene[i] == nSceneID then
      return true
    end
  end
  return false
end

function IsKVKSceneUnCity(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  local tab = GetKvkUnCityScene()
  if FindTableValue(tab, nSceneID) then
    return true
  end
  return false
end

function IsInAnyGuildCity()
  local cur_scene_id = GetSceneID()
  if cur_scene_id >= 501 and cur_scene_id <= 545 then
    return true
  end
  return false
end

function GetMyGuildCityName()
  local id = -1
  local name = ""
  local city_name = ""
  DeleteDebugMsg("你还没有加入帮会。")
  for i = 1, 5 do
    id, name, city_name = GetLuaValue([[
                local id = Guild:GetMyGuildDetailInfo('ID');
                local name = Guild:GetMyGuildDetailInfo('Name'); 
                local cityName = Guild:GetMyGuildDetailInfo('CityName'); 
                return id, name, cityName
            ]], "nss")
    if -1 == id or nil ~= name and "" ~= name then
      break
    end
    GetLuaValue("Guild:AskGuildDetailInfo();")
    do
      local function _FindMsg()
        if IsInDebugMsg("你还没有加入帮会。") then
          return false
        end
        return true
      end
      
      SleepCallBack(1000, 100, _FindMsg)
      if IsInDebugMsg("你还没有加入帮会。") then
        break
      end
      PushDebugMessage("检查您是否已加入帮派：" .. city_name)
    end
    goto lbl_45
    do break end
    ::lbl_45::
  end
  CloseWindow("NewBangHui_Bhxx")
  if "-1" == city_name then
    city_name = ""
  end
  return city_name
end

function IsMyGuildCity()
  local city_name = GetMyGuildCityName()
  if "" ~= city_name then
    local cur_scene_name = GetCurrentSceneName()
    if cur_scene_name == city_name then
      return true
    end
  end
  return false
end

function PlayerStateTimeOut(aState, aTimeOut, aCallBack)
  local nTick = GetTickCount()
  local bIsWait = false
  Sleep(300)
  while Player:GetState() == aState do
    bIsWait = true
    Sleep(80)
    if aCallBack and false == aCallBack() or GetTickCount() - nTick > aTimeOut * 1000 then
      break
    end
  end
  return bIsWait
end

function IsDestination(aX, aY, aSceneID, aSpace)
  if (aSceneID < 0 or aSceneID == GetSceneID()) and (-1 == aSpace or aSpace >= GetDist(aX, aY)) then
    return true
  end
  return false
end

function MoveConfirm()
  return GetLuaValue("return meMoveButtonClick()", "b")
end

function MessageBox_Self_OK_Clicked(aSleep)
  local bClick = GetLuaValue("setmetatable(_G, {__index=MessageBox_Self_Env});if this:IsVisible() then MessageBox_Self_OK_Clicked();return 1 end; return 0", "b")
  if bClick and aSleep then
    Sleep(aSleep)
  end
  return bClick
end

function MessageBox_Self_Text_Clicked(aCmpText, aSleep)
  local strText = fmt([[
            local strCmp = "%s"
            setmetatable(_G, {__index = MessageBox_Self_Env})
            if this:IsVisible() then
                local strText = MessageBox_Self_Text:GetText()
                if strCmp ~= "" and string.find(strText, strCmp, nil, true) then
                    MessageBox_Self_OK_Clicked()
                    return 1
                end
            end
            return 0
        ]], aCmpText)
  local bClick = GetLuaValue(strText, "b")
  if bClick and aSleep then
    Sleep(aSleep)
  end
  return bClick
end

function MessageBox_Self2_OK_Clicked(aSleep)
  local bClick = GetLuaValue("setmetatable(_G, {__index=MessageBox_Self2_Env});if this:IsVisible() then MessageBox_Self2_Ok_Clicked();return 1 end; return 0", "b")
  if bClick and aSleep then
    Sleep(aSleep)
  end
  return bClick
end

function SelectServerQuest_Bn1Click(strText)
  if nil == strText then
    GetLuaValue("setmetatable(_G, {__index=LoginSelectServerQuest_Env});if this:IsVisible() then SelectServerQuest_Bn1Click() end")
  else
    local szLua = fmt([[
			local szFind = '%s'
			setmetatable(_G, {__index = LoginSelectServerQuest_Env})
			if this:IsVisible() then
				local szText = SelectServerQuest_InfoWindow:GetText()
				if string.find(szText, szFind, nil, true) then
					SelectServerQuest_Bn1Click()
				end
			end
		]], strText)
    GetLuaValue(szLua)
  end
end

function WuhunQuest_Text_Clicked(aCmpText, aSleep)
  local strText = fmt([[
            local strCmp = "%s"
            local strText = ""
            setmetatable(_G, {__index = WuhunQuest_Env})
            if this:IsVisible() then
                strText = WuhunQuest_InfoWindow:GetText()
                if strCmp == "" then 
                    WuhunQuest_Bn1Click();
                    return 1, strText
                elseif string.find(strText, strCmp, nil, true) then
                    WuhunQuest_Bn1Click();
                    return 1, strText
                end
            end
            return 0, strText
        ]], aCmpText)
  local bClick, strText = GetLuaValue(strText, "bs")
  if bClick and aSleep then
    Sleep(aSleep)
  end
  return bClick, strText
end

function LoginGetSelectServerText()
  local dolua = [[
            local szText = '' 
            setmetatable(_G, {__index=LoginSelectServerQuest_Env});
            if this:IsVisible() then 
                szText = SelectServerQuest_InfoWindow:GetText() 
            end 
            return szText
        ]]
  local strMsg = GetLuaValue(dolua, "s")
  return strMsg
end

function AutoRunToTarget(aX, aY, aSceneID, aCheckButton, aCurSceneID)
  local curScene = aCurSceneID or GetSceneID()
  
  local function _CheckButton()
    local function _ClickMoveButton()
      local bclick = not MoveConfirm()
      
      return bclick
    end
    
    if SleepCallBack(1000, 100, _ClickMoveButton) == false then
      Sleep(2000)
    end
  end
  
  if aSceneID < 0 or curScene == aSceneID then
    GetLuaValue(fmt("AutoRunToTarget(%.6f,%.6f);", aX, aY))
    if aCheckButton then
      _CheckButton()
    end
  elseif curScene ~= aSceneID then
    GetLuaValue(fmt("AutoRunToTargetEx(%.6f,%.6f,%d);", aX, aY, aSceneID))
    _CheckButton()
  end
end

function RunTo(aX, aY, aDist, aSleep)
  if type(aX) ~= "number" or type(aY) ~= "number" then
    PushDebugMessage("Runto参数错误1")
  end
  if aX < 1 or aX > 1000 or aY < 1 or aY > 1000 then
    PushDebugMessage("Runto参数错误2")
    return false
  end
  aDist = aDist or 0
  local nowDist = GetDist(aX, aY)
  if nowDist >= 1.0 and aDist < nowDist then
    AutoRunToTarget(aX, aY, -1, false)
    if nil ~= aSleep then
      local function _RunOk()
        local _dist = GetDist(aX, aY)
        
        return _dist >= 1.0 and _dist > aDist
      end
      
      SleepCallBack(aSleep, 100, _RunOk)
    end
    return true
  elseif 0 == aDist and nowDist > 0 and nowDist < 1.0 then
    AutoRunToTarget(aX, aY, -1, false)
    Sleep(100)
  end
  return false
end

function MoveDaliSkill()
  local skill = Skill:GetSkillByName("返回大理城")
  local bUse = false
  if skill and Skill:CanUseSkill(skill) then
    PlayerStateTimeOut(2, 2)
    Player:TeamFollow(false, 500)
    Dismount()
    Skill:UseName("初级隐遁", 1500)
    bUse = Skill:UseName("返回大理城", 2000)
    PlayerStateTimeOut(5, 40)
  end
  return bUse
end

function MoveDingWeiFu(aTargetSceneID, aMust)
  local cur_scene_id = GetSceneID()
  local cur_scene_name = GetCurrentSceneName()
  cur_scene_name = string.gsub(cur_scene_name, "1线", "")
  cur_scene_name = string.gsub(cur_scene_name, "2线", "")
  if not aMust and (aTargetSceneID < 0 or IsCityScene(cur_scene_id) or IsMyGuildCity() or -1 ~= GetMenpaiIDBySceneID(cur_scene_id)) then
    return false
  end
  local target_scene_name = GetSceneNameByID(aTargetSceneID)
  if "" == target_scene_name or "" == cur_scene_name or target_scene_name == cur_scene_name then
    return false
  end
  if "地府" == cur_scene_name or "监狱" == cur_scene_name then
    return false
  end
  
  local function _SurroundingScene(_aSceneID)
    local t = {
      4,
      5,
      30,
      3,
      8,
      18,
      24
    }
    for i = 1, #t do
      if t[i] == _aSceneID then
        return true
      end
    end
    return false
  end
  
  local dist, movePath = CMGraph:GetDist(cur_scene_name, target_scene_name, true)
  if aMust or dist >= 100 and IsCityName(target_scene_name) or -1 == GetMenpaiIDBySceneID(cur_scene_id) and -1 ~= GetMenpaiIDByName(cur_scene_name) or dist > 200 and dist < 99999 and (0 ~= dist % 100 or _SurroundingScene(aTargetSceneID)) or dist > 100 and 0 == dist % 100 and not IsCityName(cur_scene_name) and (string.find(movePath, "洛阳", nil, true) or string.find(movePath, "苏州", nil, true) or string.find(movePath, "大理", nil, true)) then
    local function _UseDingWeiFu(_aIndex)
      PlayerStateTimeOut(2, 2)
      
      Dismount()
      Player:TeamFollow(false, 500)
      Skill:UseName("初级隐遁", 1200)
      Bag:UseItem(_aIndex, 1000)
      PlayerStateTimeOut(5, 20)
    end
    
    local tDWF = Bag:FindDingWei()
    if #tDWF > 0 then
      local branchID = GetSceneMainBranch(aTargetSceneID)
      for i = 1, #tDWF do
        local tmp = tDWF[i]
        if tmp.dwf.data > 0 and tmp.dwf.sceneID == branchID then
          _UseDingWeiFu(tmp.index)
          return true
        end
      end
      for i = 1, #tDWF do
        local tmp = tDWF[i]
        if tmp.dwf.data > 0 then
          _UseDingWeiFu(tmp.index)
          return true
        end
      end
    end
    local tMPZJL = Bag:FindItemInfo("门派召集令")
    if #tMPZJL > 0 then
      _UseDingWeiFu(tMPZJL[1].index)
      return true
    end
    if MoveDaliSkill() then
      return true
    end
  end
  return false
end

function MoveCheckOtherGuildCity(aToSceneID)
  if (nil == aToSceneID or -2 ~= aToSceneID) and IsInAnyGuildCity() and IsMyGuildCity() == false then
    Sleep(1000)
    if IsMyGuildCity() == false then
      CloseAllWindow()
      Sleep(500)
      GetLuaValue("setmetatable(_G, {__index = MainMenuBar_Env}); MainMenuBar_OnOpenGruidClick();")
      Sleep(600)
      if IsWindowVisible("NewBangHui_Hygl", "NewBangHui_Hygl_Bhxx_Clicked()") then
        Sleep(600)
      elseif IsWindowVisible("NewBangHui_Bhxx", "NewBangHui_Bhxx_Hygl_Clicked()") then
        Sleep(600)
      end
      CloseAllWindow()
      GetLuaValue("Guild:AskGuildDetailInfo();")
      PushDebugMessage("离开非本帮的城市")
      AutoRunToTarget(100, 158, -1, true)
      Sleep(2000)
    end
  end
end

function MoveFei()
  local function _UseDingWeiFu(_aIndex)
    PlayerStateTimeOut(2, 2)
    
    Dismount(500)
    Player:TeamFollow(false, 500)
    Bag:UseItem(_aIndex, 1000)
    PlayerStateTimeOut(5, 20)
  end
  
  local tDWF = Bag:FindDingWei()
  if #tDWF > 0 then
    for i = 1, #tDWF do
      local tmp = tDWF[i]
      if tmp.dwf.data > 0 then
        _UseDingWeiFu(tmp.index)
        return 1
      end
    end
  end
  local tMPZJL = Bag:FindItemInfo("门派召集令")
  if #tMPZJL > 0 then
    _UseDingWeiFu(tMPZJL[1].index)
    return 2
  end
  if MoveDaliSkill() then
    return 3
  end
  return 0
end

function MoveKaTuSetLastPos(aPos)
  m_MoveInfo.x = aPos.x
  m_MoveInfo.y = aPos.y
  m_MoveInfo.last_time = GetTickCount()
end

function MoveKaTuSetSDPos(aPos)
  m_MoveInfo.sd_x = aPos.x
  m_MoveInfo.sd_y = aPos.y
  m_MoveInfo.sd_tick = GetTickCount()
end

function MoveKaTu(aPosX, aPosY, aSceneID)
  local pos = Player:GetPos()
  local nowTick = GetTickCount()
  local bQingGong = false
  if GetDist(m_MoveInfo.sd_x, m_MoveInfo.sd_y, pos.x, pos.y) > 15 then
    m_MoveInfo.sd_x = pos.x
    m_MoveInfo.sd_y = pos.y
    m_MoveInfo.sd_tick = nowTick
  elseif nowTick - m_MoveInfo.sd_tick > 60000 then
    local nScene = GetSceneID()
    if nScene ~= LUOYANG_ID and 2 ~= nScene or nScene == LUOYANG_ID and GetDist(234, 321) <= 3 then
    elseif nScene == LUOYANG_ID and GetDist(326, 269) <= 2 then
    elseif 2 == nScene and GetDist(253, 121) < 5 then
    else
      local nFei = MoveFei()
      if 1 == nFei then
        LogMsg("【深度卡图】定位处理 " .. nScene)
        return
      elseif 2 == nFei then
        LogMsg("【深度卡图】门派召集令处理 " .. nScene)
        return
      elseif 3 == nFei then
        LogMsg("【深度卡图】大理技能处理 " .. nScene)
        return
      end
      PushColorMsg("处理【深度卡图】没有可传送道具或技能 " .. nScene)
      bQingGong = true
    end
  end
  if GetDist(m_MoveInfo.x, m_MoveInfo.y, pos.x, pos.y) > 5 or IsInDebugMsgTime("你现在不能移动", 0, 2) or IsInDebugMsgTime("恐惧状态，无法那样做", 0, 2) or IsInDebugMsgTime("目标场景人数已满", 0, 3) or IsInDebugMsgTime("目标服务器负载过高", 0, 3) then
    MoveKaTuSetLastPos(pos)
    return
  end
  if nowTick - m_MoveInfo.last_time > 5000 then
    if m_MoveInfo.angle >= 360 then
      m_MoveInfo.angle = 0
    end
    PushDebugMessage("卡图纠正")
    local newPos = GetAnglePos(pos, m_MoveInfo.angle, 5)
    m_MoveInfo.angle = m_MoveInfo.angle + 90
    if bQingGong then
      Skill:UseQingGong(newPos.x, newPos.y)
      Sleep(1200)
    end
    RunTo(newPos.x, newPos.y, 0, 600)
    PlayerStateTimeOut(2, 6)
    if aPosX and aPosY and aSceneID then
      AutoRunToTarget(aPosX, aPosY, aSceneID, true)
    end
    Sleep(500)
    PlayerStateTimeOut(2, 6)
    MoveConfirm()
  end
end

function MoveCallback_InScene(aX, aY, aScene)
  if GetSceneID() == aScene then
    return true
  end
  return false
end

function MoveCB_KaDian(aX, aY, aSceneID, aNowSceneID)
  local function handle_fei(aCheckPos, aRunPos)
    if GetDist(aCheckPos.x, aCheckPos.y) < aCheckPos.dist and 2 ~= Player:GetState() then
      AutoRunToTarget(aX, aY, aSceneID, false)
      
      Sleep(1000)
      if GetDist(aCheckPos.x, aCheckPos.y) < aCheckPos.dist and 2 ~= Player:GetState() then
        PushColorMsg("卡点：飞处理")
        Player:TeamFollow(false, 500)
        RunTo(aRunPos.x, aRunPos.y, 0, 2000)
        PlayerStateTimeOut(2, 8)
        if GetDist(aCheckPos.x, aCheckPos.y) < aCheckPos.dist and 2 ~= Player:GetState() then
          MoveDingWeiFu(2, true)
        end
      end
    end
  end
  
  if 260 == aNowSceneID then
    local pos = Player:GetPos()
    if pos.x >= 212 and pos.x <= 220 and pos.y >= 186 and pos.y <= 196 then
      PushColorMsg("束河屋顶卡点处理")
      RunTo(213, 190, 0, 500)
      PlayerStateTimeOut(2, 5)
      Skill:UseQingGong(206, 187)
      Sleep(1000)
    end
  elseif 246 == aNowSceneID then
    handle_fei({
      x = 271,
      y = 150,
      dist = 5
    }, {x = 280, y = 143})
    handle_fei({
      x = 271,
      y = 135,
      dist = 5
    }, {x = 280, y = 143})
  elseif 256 == aNowSceneID then
    if aSceneID >= 0 and 256 ~= aSceneID then
      SHG_Leave()
    end
  elseif aNowSceneID > 202 and aNowSceneID <= 210 then
    if aSceneID > 202 and aSceneID <= 210 then
    elseif 203 == aNowSceneID then
      RunTo(86, 92, 0, 2000)
      PlayerStateTimeOut(2, 20)
      Skill:UseQingGong(90, 99)
      Sleep(1000)
    elseif aSceneID >= 0 then
      MoveFei()
    end
  elseif aNowSceneID >= 262 and aNowSceneID <= 264 or 292 == aNowSceneID then
    if aSceneID >= 262 and aSceneID <= 264 or 292 == aSceneID then
    elseif aSceneID >= 0 then
      MoveFei()
    end
  elseif 216 == aNowSceneID then
    local pos = Player:GetPos()
    if 216 == aSceneID then
      if pos.x > 94 and pos.y > 190 then
        if aX < 94 or aY < 190 then
          RunTo(224, 208, 1, 1500)
          PlayerStateTimeOut(2, 50)
          Sleep(1000)
        end
      elseif aX > 94 and aY > 190 then
        RunTo(215, 165, 1, 1500)
        PlayerStateTimeOut(2, 50)
        Sleep(1000)
      end
    elseif pos.x > 94 and pos.y > 190 then
    else
      RunTo(215, 165, 1, 1500)
      PlayerStateTimeOut(2, 30)
      Sleep(1000)
    end
  end
end

function Move_check(aX, aY, aSceneID)
  aX = aX or -1
  aY = aY or -1
  aSceneID = aSceneID or -1
  local nowSceneID = GetSceneID()
  if -1 ~= JL_GetSceneID(aSceneID) then
    local curScene = JL_GetSceneID()
    if -1 ~= curScene and curScene ~= aSceneID then
      PushColorMsg("金陵:需要切换线路" .. aSceneID .. " " .. curScene)
      for i = 1, 18 do
        RunTo(384, 516, 0, 200)
      end
      return false
    end
  elseif -1 ~= BJ_GetSceneID(aSceneID) then
    local curScene = BJ_GetSceneID()
    if -1 ~= curScene and curScene ~= aSceneID then
      PushColorMsg("汴京:需要切换线路" .. aSceneID .. " " .. curScene)
      for i = 1, 18 do
        RunTo(365, 339, 0, 200)
      end
      return false
    end
  end
  MoveCB_KaDian(aX, aY, aSceneID, nowSceneID)
end

function MoveCallBack_Default(aX, aY, aSceneID)
  aX = aX or -1
  aY = aY or -1
  aSceneID = aSceneID or -1
  DebugStr("移动回调:正移动到 x:%s y:%s scene:%s", 6, math.floor(aX), math.floor(aY), aSceneID)
  return true, nil
end

function OtherCallback_NoFuben()
  return not IsInFubenScene()
end

function MoveCallback_NoFuben(aX, aY, aSceneID)
  if IsInFubenScene() then
    PushColorMsg("当前为副本地图,退出寻路!")
    return false, nil
  end
  return MoveCallBack_Default(aX, aY, aSceneID)
end

function DieOutAndGetPos()
  local pos
  if 9 == Player:GetState() then
    pos = Player:GetPos()
    DieRelive(-1)
  end
  return pos
end

function CheckDieState()
  if 9 == Player:GetState() and IsInFubenScene() == false then
    PushDebugMessage("角色死亡：自动出窍！")
    DieRelive(-1)
    Sleep(1000)
  end
  return true
end

function MoveCallBack_state_1()
  if 9 == Player:GetState() then
    PushDebugMessage("寻路:角色死亡自动出窍,结束寻路！")
    DieRelive(-1)
    Sleep(1000)
    return false
  end
  return true
end

function MoveCallBack_state_2()
  if 9 == Player:GetState() then
    PushDebugMessage("寻路:角色死亡,结束寻路！")
    return false
  end
  return true
end

function MoveCheckTeamFollow()
  if IsInDebugMsg("跟随的队友没有到达本场景", 1) then
    Player:TeamFollow(false, 1000)
    Player:TeamFollow(true, 300)
  elseif IsInDebugMsg("#{TFJCGZ_20200817_05", 1) then
    Player:TeamFollow(false, 1000)
  end
end

function MoveMoneyRoadNpc(aSceneName)
  local tPos = {
    ["洛阳"] = {
      name = "车传义",
      x = 217,
      y = 339
    },
    ["苏州"] = {
      name = "车传安",
      x = 335,
      y = 250
    },
    ["大理"] = {
      name = "车传志",
      x = 258,
      y = 82
    },
    ["楼兰"] = {
      name = "车传平",
      x = 297,
      y = 87
    },
    ["南诏"] = {
      name = "车传福",
      x = 187,
      y = 43
    },
    ["南海"] = {
      name = "车传信",
      x = 205,
      y = 259
    },
    ["长白山"] = {
      name = "车传仁",
      x = 153,
      y = 108
    }
  }
  return tPos[aSceneName]
end

function MoveMoneyRoad(aTargetSceneID)
  local target_scene_name = GetSceneNameByID(aTargetSceneID)
  if "" == target_scene_name then
    return false
  end
  local money = Player:GetMoney(1)
  local money_jz = Player:GetMoney(2)
  if money < 5000 and money_jz < 5000 then
    return false
  end
  local transfer_scene = ""
  if string.find("南诏苗疆石林", target_scene_name, nil, true) then
    transfer_scene = "南诏"
  elseif string.find("南海琼州武夷", target_scene_name, nil, true) then
    transfer_scene = "南海"
  elseif string.find("长白山草原黄龙府", target_scene_name, nil, true) then
    transfer_scene = "长白山"
  else
    return false
  end
  local cur_scene_id = GetSceneID()
  local cur_scene_name = GetSceneNameByID(cur_scene_id)
  if cur_scene_name == transfer_scene or cur_scene_name == target_scene_name then
    return false
  elseif not string.find("洛阳苏州大理楼兰南诏南海长白山", cur_scene_name, nil, true) then
    return false
  end
  local npc = MoveMoneyRoadNpc(cur_scene_name)
  if nil == npc then
    return false
  end
  if IsDestination(npc.x, npc.y, cur_scene_id, 3) then
    Player:TeamFollow(false, 300)
    if not QuestFrameOptionClicked_Item("确定", 1, 600) then
      if not QuestFrameOptionClicked_Item(transfer_scene, 1, 600) then
        TalkNpc(npc.name, 400)
        QuestFrameOptionClicked_Item(transfer_scene, 1, 600)
        QuestFrameOptionClicked_Item("确定", 1, 600)
      else
        QuestFrameOptionClicked_Item("确定", 1, 600)
      end
    end
    MoveConfirm()
  else
    RunTo(npc.x, npc.y, 0, 600)
  end
  return true
end

function GetSceneMainBranch(aSceneID)
  local suzhou = {
    1,
    4,
    5,
    30,
    31,
    32,
    33,
    34,
    35
  }
  local dali = {
    2,
    6,
    7,
    24,
    25,
    26,
    27,
    28,
    29
  }
  local loulan = {246}
  for i = 1, #suzhou do
    if suzhou[i] == aSceneID then
      return 1
    end
  end
  for i = 1, #dali do
    if dali[i] == aSceneID then
      return 2
    end
  end
  for i = 1, #loulan do
    if loulan[i] == aSceneID then
      return 246
    end
  end
  return LUOYANG_ID
end

function MoveUseMount()
  local bUse = false
  if IsMount() == false then
    local bFollow = false
    if Player:IsFollow() and Player:IsLeader() then
      Player:TeamFollow(false, 500)
      bFollow = true
    end
    if false == Player:IsFollow() then
      bUse = true
      UseMount()
    end
    if bFollow then
      Player:TeamFollow(true, 300)
    end
  end
end

function MoveCheckMount(aTargetX, aTargetY, aTargetSceneID)
  local bUse = false
  if IsMount() == false and (GetDist(aTargetX, aTargetY) > 25 or aTargetSceneID >= 0 and GetSceneID() ~= aTargetSceneID) then
    local bFollow = false
    if Player:IsFollow() and Player:IsLeader() then
      Player:TeamFollow(false, 500)
      bFollow = true
    end
    if false == Player:IsFollow() then
      bUse = true
      UseMount()
    end
    if bFollow then
      Player:TeamFollow(true, 300)
    end
  end
  return bUse
end

function MoveRepairPos(aPosX, aPosY, aSceneID)
  if 6 == aSceneID then
    if 236 == aPosX and 170 == aPosY then
      aPosX = 239
    end
  elseif 20 == aSceneID then
    if 197 == aPosX and 202 == aPosY then
      aPosY = 204
    end
  elseif 32 == aSceneID and 110 == aPosX and 50 == aPosY then
    aPosX = 110
    aPosY = 51
  end
  return aPosX, aPosY, aSceneID
end

function MoveRepairScene(aPosX, aPosY, aSceneID)
  local nCurScene = GetSceneID()
  if 28 == nCurScene and 26 ~= aSceneID and 27 ~= aSceneID and 28 ~= aSceneID and 29 ~= aSceneID and 235 ~= aSceneID and GetDist(95, 40) < 5 then
    local myCityName = GetMyGuildCityName()
    if "" ~= myCityName then
      PlayerStateTimeOut(2, 4)
      if GetDist(95, 40) < 5 then
        RunTo(95, 40, 0, 3000)
        OpenTalk(127, 1000)
        QuestFrameOptionClicked_Item(myCityName, 0, 1000)
      end
    end
  end
end

function MoveToAction(aTarX, aTarY, aTarScene, aCurScene)
  if 25 == aTarScene and g_config.tysz.un_shgz then
    local nScene = GetSceneID()
    if 24 == nScene or 25 == nScene or 260 == nScene then
      AutoRunToTarget(aTarX, aTarY, aTarScene, false, aCurScene)
    else
      DebugStr("已设置不走束河古镇", 5)
      AutoRunToTarget(41, 159, 24, false, aCurScene)
    end
  else
    AutoRunToTarget(aTarX, aTarY, aTarScene, false, aCurScene)
  end
end

function MoveToAction_cb(aCB, aTarX, aTarY, aTarScene, aFollowName, aFollowCB)
  local bMove, newPos
  if 25 == aTarScene and g_config.tysz.un_shgz then
    local nScene = GetSceneID()
    if 24 == nScene or 25 == nScene or 260 == nScene then
      bMove, newPos = aCB(aTarX, aTarY, aTarScene, aFollowName, aFollowCB)
    else
      bMove, newPos = aCB(41, 159, 24, aFollowName, aFollowCB)
    end
  else
    bMove, newPos = aCB(aTarX, aTarY, aTarScene, aFollowName, aFollowCB)
  end
  return bMove, newPos
end

function MoveTo(aX, aY, aSceneID, aSpace, aMount, aCallBack, aCallBackMove, aMoneyRoad, aTransferItem, aFollowName, aFollowCallBack)
  aSceneID = aSceneID or -1
  aSpace = aSpace or 3
  if nil == aMount then
    aMount = true
  end
  if type(aX) ~= "number" or type(aY) ~= "number" or type(aSceneID) ~= "number" or aX <= 0 or aY <= 0 then
    PushDebugMessage("MoveTo参数x y scene错误！")
    return
  end
  local target_x, target_y = MoveRepairPos(aX, aY, aSceneID)
  local target_scene_id = aSceneID
  local die_call_back = aCallBack or CheckDieState
  local move_call_back = aCallBackMove or MoveCallBack_Default
  DeleteDebugMsg("跟随的队友没有到达本场景")
  DeleteDebugMsg("#{TFJCGZ_20200817_05")
  m_MoveInfo.x = 0
  m_MoveInfo.y = 0
  m_MoveInfo.start_tick = GetTickCount()
  m_MoveInfo.sd_tick = m_MoveInfo.start_tick
  local first_move = true
  while IsDestination(target_x, target_y, target_scene_id, aSpace) == false and false ~= die_call_back() do
    local bMove, new_pos = MoveToAction_cb(move_call_back, target_x, target_y, target_scene_id, aFollowName, aFollowCallBack)
    if not bMove then
      break
    end
    if new_pos and new_pos.x and new_pos.y and new_pos.sceneID then
      target_x = new_pos.x
      target_y = new_pos.y
      target_scene_id = new_pos.sceneID
    end
    if false ~= Move_check(target_x, target_y, target_scene_id) then
    else
      break
    end
    CDG:checkDiFu()
    CDG:checkJianYu()
    MoveCheckTeamFollow()
    do
      local bUseItem = false
      if aMoneyRoad and MoveMoneyRoad(target_scene_id) then
        if aMount then
          local bUse = MoveCheckMount(target_x, target_y, target_scene_id)
          if bUse then
            first_move = true
          end
        end
        MoveCheckOtherGuildCity(target_scene_id)
        MoveKaTu(target_x, target_y, target_scene_id)
      else
        if aTransferItem then
          bUseItem = MoveDingWeiFu(target_scene_id)
        end
        if false == bUseItem then
          if aMount then
            local bUse = MoveCheckMount(target_x, target_y, target_scene_id)
            if bUse then
              first_move = true
            end
          end
          MoveCheckOtherGuildCity(target_scene_id)
          MoveKaTu(target_x, target_y, target_scene_id)
        end
        if not aMoneyRoad or not MoveMoneyRoad(target_scene_id) then
          if first_move then
            MoveToAction(target_x, target_y, target_scene_id, false)
            first_move = false
          elseif 2 ~= Player:GetState() then
            local curScene = GetSceneID()
            if target_scene_id < 0 or curScene == target_scene_id then
              Sleep(100)
            else
              Sleep(1200)
            end
            if 2 ~= Player:GetState() and GetChangeSceneTimeDiff() > 5 then
              MoveToAction(target_x, target_y, target_scene_id, false, curScene)
            end
          end
        end
      end
    end
    Sleep(70)
    MoveRepairScene()
  end
end

function MoveToNPC(aNPCName, aX, aY, aSceneID, aSpace, aMount, aCallBack, aCallBackMove, aMoneyRoad, aTransferItem, aFollowName, aFollowCallBack)
  if type(aNPCName) == "number" then
    MoveTo(aNPCName, aX, aY, aSpace, aMount, nil, aCallBack, aCallBackMove, aMoneyRoad, aTransferItem, aFollowName, aFollowCallBack)
    Sleep(500)
    TalkNpc(aSceneID, 500)
  else
    MoveTo(aX, aY, aSceneID, aSpace, aMount, aCallBack, aCallBackMove, aMoneyRoad, aTransferItem, aFollowName, aFollowCallBack)
    Sleep(500)
    TalkNpc(aNPCName, 500)
  end
  PlayerStateTimeOut(2, 10)
end

function GoToScene(aX, aY, aSceneID, aSpace, aMount, aCallBack, aCallBackMove, aMoneyRoad, aTransferItem)
  MoveTo(aX, aY, aSceneID, aSpace, aMount, aCallBack, MoveCallback_NoFuben, aMoneyRoad, aTransferItem)
end

function GoToSceneNPC(aNPCName, aX, aY, aSceneID, aSpace, aMount, aCallBack, aCallBackMove, aMoneyRoad, aTransferItem)
  MoveTo(aX, aY, aSceneID, aSpace, aMount, aCallBack, MoveCallback_NoFuben, aMoneyRoad, aTransferItem)
  Sleep(500)
  TalkNpc(aNPCName, 500)
  PlayerStateTimeOut(2, 10)
end

function FollowFilterScene(aSceneID)
  local tScene = {
    77,
    194,
    577,
    578,
    823
  }
  for i = 1, #tScene do
    if aSceneID == tScene[i] then
      return i
    end
  end
  return -1
end

function MoveFollowGuMuDiGong(aX, aY, aSceneID)
  if aSceneID > 202 and aSceneID <= 210 then
    local nScene = GetSceneID()
    if nScene ~= aSceneID and nScene >= 202 and nScene <= 210 and aSceneID > nScene then
      if 203 == aSceneID then
        aX = 87
        aY = 89
      elseif 204 == aSceneID then
        aX = 16
        aY = 22
      elseif 205 == aSceneID then
        aX = 102
        aY = 26
      elseif 206 == aSceneID then
        aX = 26
        aY = 27
      elseif 207 == aSceneID then
        aX = 64
        aY = 103
      elseif 208 == aSceneID then
        aX = 28
        aY = 107
      elseif 209 == aSceneID then
        aX = 16
        aY = 15
      elseif 210 == aSceneID then
        aX = 20
        aY = 20
      end
      MainMoveToScene(aSceneID, aX, aY)
      return true
    end
  elseif aSceneID >= 262 and aSceneID <= 264 or 292 == aSceneID then
    local nScene = GetSceneID()
    if nScene >= 262 and nScene <= 264 and aSceneID >= nScene then
      if nScene ~= aSceneID then
        if 263 == aSceneID then
          aX = 207
          aY = 226
        elseif 264 == aSceneID then
          aX = 224
          aY = 218
        elseif 292 == aSceneID then
          aX = 32
          aY = 39
        end
      end
      MainMoveToScene(aSceneID, aX, aY)
      return true
    end
  end
  return false
end

function MoveToLeader_InGuild()
  local function _cb()
    local _leader, _isleader = Team:GetLeaderInfo()
    
    if _isleader then
      return false
    end
    if Player:IsFollow() then
      return false
    end
    if _leader then
      if _leader.sceneID ~= 10001 then
        return false
      end
      local _leaderObj = FindObjByGUID(_leader.guid)
      if _leaderObj then
        RunTo(_leaderObj.x, _leaderObj.y, 1, 350)
        return false
      end
    else
      return false
    end
    return true
  end
  
  GoToGuild(_cb)
end

function MoveCallBack_GoToLeader(fX, fY, nScene)
  local leader, isleader = Team:GetLeaderInfo()
  if not leader then
    if Player:IsInTeam(true) == false then
      return false, nil
    end
    DebugStr("跟随队长：正在移动到 x:%s y:%s scene:%s", 1, fX, fY, nScene)
    Sleep(500)
    return true, nil
  end
  if isleader then
    return false, nil
  end
  if Player:IsFollow() then
    return false, nil
  end
  if -1 ~= FollowFilterScene(leader.sceneID) then
    DebugStr("跟随队长：队长不在正确的地图,暂不跟随!")
    return false, nil
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    RunTo(leaderObj.x, leaderObj.y, 1, 350)
    if leaderObj.dst <= 3 then
      return false, nil
    else
      leaderObj.sceneID = leader.sceneID
      return true, leaderObj
    end
  end
  if leader.sceneID == 10001 then
    DebugStr("跟随队长：队长可能在帮会", 5)
    MoveToLeader_InGuild()
    leader.sceneID = -1
  end
  DebugStr("跟随队长：移动到 x:%s y:%s scene:%s", 1, math.floor(leader.x), math.floor(leader.y), leader.sceneID)
  if MoveFollowGuMuDiGong(leader.x, leader.y, leader.sceneID) then
    return false, nil
  end
  if leader.sceneID == GetSceneID() then
    ChangeSceneLineID(leader.mapID)
  end
  if leader.x > 0 and (leader.x ~= fX or leader.y ~= fY or leader.sceneID ~= nScene) then
    if leader.sceneID ~= 65535 then
      AutoRunToTarget(leader.x, leader.y, leader.sceneID, true)
      Sleep(300)
    else
      return true, nil
    end
  else
    return true, nil
  end
  return true, leader
end

function MoveCallBack_GoToRaidLeader(fX, fY, nScene)
  local leader, isleader = Raid:GetLeaderInfo()
  if not leader then
    if Player:IsInRaid(true) == false then
      return false, nil
    end
    DebugStr("跟随团长：正在移动到 x:%s y:%s scene:%s", 1, fX, fY, nScene)
    Sleep(500)
    return true, nil
  end
  if isleader then
    return false, nil
  end
  if -1 ~= FollowFilterScene(leader.sceneID) then
    DebugStr("跟随团长：团长不在正确的地图,暂不跟随!")
    return false, nil
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    RunTo(leaderObj.x, leaderObj.y, 1, 350)
    if leaderObj.dst <= 3 then
      return false, nil
    else
      leaderObj.sceneID = leader.sceneID
      return true, leaderObj
    end
  end
  if leader.sceneID == 10001 then
    PushDebugMessage("跟随团长：团长可能在帮会")
  end
  DebugStr("跟随团长：移动到 x:%s y:%s scene:%s", 1, math.floor(leader.x), math.floor(leader.y), leader.sceneID)
  if leader.x > 0 and (leader.x ~= fX or leader.y ~= fY or leader.sceneID ~= nScene) then
    if leader.sceneID ~= 65535 then
      AutoRunToTarget(leader.x, leader.y, leader.sceneID, true)
      Sleep(300)
    else
      return true, nil
    end
  else
    return true, nil
  end
  return true, leader
end

function MoveCallBack_GoToPlayer(fX, fY, nScene, aFollowName, aCheckCB)
  if Player:IsFollow() then
    return false, nil
  end
  local tAllMember = {}
  if Player:IsInRaid() then
    tAllMember = Raid:GetAllMemberInfo()
  elseif Player:IsInTeam() then
    tAllMember = Team:GetAllMemberInfo()
  end
  if 0 == #tAllMember then
    return false, nil
  end
  local tFind = ObjFilterByName(tAllMember, aFollowName, 0)
  if 0 == #tFind then
    return false, nil
  end
  local leader = tFind[1]
  if 0 == leader.x or 0 == leader.y then
    leader.x, leader.y = GetSceneTempPos(leader.sceneID)
  end
  if aCheckCB and false == aCheckCB(leader) then
    return false, nil
  end
  if -1 ~= FollowFilterScene(leader.sceneID) then
    DebugStr("跟随玩家：玩家不在正确的地图,暂不跟随!")
    return false, nil
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    RunTo(leaderObj.x, leaderObj.y, 1, 350)
    if leaderObj.dst <= 3 then
      return false, nil
    else
      leaderObj.sceneID = leader.sceneID
      return true, leaderObj
    end
  end
  if leader.sceneID == 10001 then
    PushDebugMessage("跟随玩家：可能在帮会")
  end
  DebugStr("跟随玩家：移动到 x:%s y:%s scene:%s", 1, math.floor(leader.x), math.floor(leader.y), leader.sceneID)
  if leader.sceneID == 65535 then
    return true, nil
  elseif leader.x > 0 and (leader.x ~= fX or leader.y ~= fY or leader.sceneID ~= nScene) then
    AutoRunToTarget(leader.x, leader.y, leader.sceneID, true)
    Sleep(300)
  else
    return true, nil
  end
  return true, leader
end

function MoveCallBack_same_scene_GoToLeader(fX, fY, nScene)
  local leader, isleader = Team:GetLeaderInfo()
  if not leader then
    return false, nil
  end
  if isleader then
    return false, nil
  end
  if GetSceneID() ~= leader.sceneID then
    return false
  end
  return MoveCallBack_GoToLeader(fX, fY, nScene)
end

function GetSceneTempPos(aSceneID)
  local tTempPos = {
    {
      x = 235,
      y = 321,
      sceneID = LUOYANG_ID,
      sceneName = "洛阳"
    },
    {
      x = 182,
      y = 126,
      sceneID = 8,
      sceneName = "敦煌"
    },
    {
      x = 143,
      y = 127,
      sceneID = 3,
      sceneName = "嵩山"
    },
    {
      x = 150,
      y = 185,
      sceneID = 18,
      sceneName = "雁南"
    },
    {
      x = 228,
      y = 211,
      sceneID = 19,
      sceneName = "雁北"
    },
    {
      x = 223,
      y = 192,
      sceneID = 20,
      sceneName = "草原"
    },
    {
      x = 100,
      y = 182,
      sceneID = 21,
      sceneName = "辽西"
    },
    {
      x = 154,
      y = 109,
      sceneID = 22,
      sceneName = "长白山"
    },
    {
      x = 128,
      y = 236,
      sceneID = 23,
      sceneName = "黄龙府"
    },
    {
      x = 332,
      y = 226,
      sceneID = 1,
      sceneName = "苏州"
    },
    {
      x = 199,
      y = 56,
      sceneID = 5,
      sceneName = "镜湖"
    },
    {
      x = 169,
      y = 179,
      sceneID = 4,
      sceneName = "太湖"
    },
    {
      x = 136,
      y = 120,
      sceneID = 30,
      sceneName = "西湖"
    },
    {
      x = 148,
      y = 209,
      sceneID = 31,
      sceneName = "龙泉"
    },
    {
      x = 123,
      y = 157,
      sceneID = 32,
      sceneName = "武夷"
    },
    {
      x = 135,
      y = 237,
      sceneID = 33,
      sceneName = "梅岭"
    },
    {
      x = 205,
      y = 263,
      sceneID = 34,
      sceneName = "南海"
    },
    {
      x = 206,
      y = 261,
      sceneID = 35,
      sceneName = "琼州"
    },
    {
      x = 160,
      y = 111,
      sceneID = 2,
      sceneName = "大理"
    },
    {
      x = 105,
      y = 171,
      sceneID = 6,
      sceneName = "无量山"
    },
    {
      x = 126,
      y = 259,
      sceneID = 7,
      sceneName = "剑阁"
    },
    {
      x = 145,
      y = 169,
      sceneID = 24,
      sceneName = "洱海"
    },
    {
      x = 222,
      y = 52,
      sceneID = 25,
      sceneName = "苍山"
    },
    {
      x = 128,
      y = 128,
      sceneID = 26,
      sceneName = "石林"
    },
    {
      x = 136,
      y = 136,
      sceneID = 27,
      sceneName = "玉溪"
    },
    {
      x = 186,
      y = 43,
      sceneID = 28,
      sceneName = "南诏"
    },
    {
      x = 75,
      y = 207,
      sceneID = 29,
      sceneName = "苗疆"
    },
    {
      x = 66,
      y = 66,
      sceneID = 112,
      sceneName = "玄武岛"
    },
    {
      x = 222,
      y = 216,
      sceneID = 201,
      sceneName = "圣兽山"
    }
  }
  local xDef = 66
  local yDef = 66
  for i = 1, #tTempPos do
    if tTempPos[i].sceneID == aSceneID then
      xDef = tTempPos[i].x
      yDef = tTempPos[i].y
      break
    end
  end
  return xDef, yDef
end

function GoToLeader(aMoveCallBack, aCallBack, bUseShouFeiNpc, bUseDingWeiFu, aKeepDist)
  aKeepDist = aKeepDist or 3
  aMoveCallBack = aMoveCallBack or MoveCallBack_GoToLeader
  aCallBack = aCallBack or MoveCallBack_state_1
  local leader, isleader = Team:GetLeaderInfo()
  if not leader or isleader then
    return -1
  end
  if leader.sceneID == 65535 then
    return -1
  end
  if leader.sceneID == 10001 then
    DebugStr("跟随队长：队长可能在帮会", 5)
    MoveToLeader_InGuild()
    leader.sceneID = -1
  end
  local nNowScene = GetSceneID()
  if nNowScene == leader.sceneID then
    ChangeSceneLineID(leader.mapID)
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    leader.x = leaderObj.x
    leader.y = leaderObj.y
  end
  MoveTo(leader.x, leader.y, leader.sceneID, aKeepDist, nil, aCallBack, aMoveCallBack, bUseShouFeiNpc, bUseDingWeiFu)
  return 0
end

function GoToPlayer(aMoveCallBack, aCallBack, aPlayerName)
  aCallBack = aCallBack or MoveCallBack_state_1
  if "" == aPlayerName or aPlayerName == g_self.name then
    return
  end
  local tAllMember = {}
  if Player:IsInRaid() then
    tAllMember = Raid:GetAllMemberInfo()
  elseif Player:IsInTeam() then
    tAllMember = Team:GetAllMemberInfo()
  end
  local tFind = ObjFilterByName(tAllMember, aPlayerName, 0)
  if #tFind > 0 then
    local leader = tFind[1]
    if 0 == leader.x or 0 == leader.y then
      leader.x, leader.y = GetSceneTempPos(leader.sceneID)
    end
    MoveTo(leader.x, leader.y, leader.sceneID, 3, nil, aCallBack, aMoveCallBack, true, true, aPlayerName)
  end
end

function GoToRaidLeader(aMoveCallBack, aCallBack, bUseShouFeiNpc, bUseDingWeiFu, aKeepDist)
  aKeepDist = aKeepDist or 3
  aMoveCallBack = aMoveCallBack or MoveCallBack_GoToRaidLeader
  aCallBack = aCallBack or MoveCallBack_state_1
  local leader, isleader = Raid:GetLeaderInfo()
  if not leader or isleader then
    return -1
  end
  if leader.sceneID == 65535 then
    return -1
  end
  if leader.sceneID == 10001 then
    PushDebugMessage("跟随团长：团长可能在帮会")
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    leader.x = leaderObj.x
    leader.y = leaderObj.y
  end
  MoveTo(leader.x, leader.y, leader.sceneID, aKeepDist, nil, aCallBack, aMoveCallBack, bUseShouFeiNpc, bUseDingWeiFu)
  return 0
end

function GoToTarget(aTargetName, aKeepDist, aTargetID)
  local tTar
  local tObj = {}
  if aTargetID then
    tTar = FindObjByTID(aTargetID)
  else
    local tObj = Enum2XByName(aTargetName, {
      1,
      1,
      0,
      0
    }, {0, -1}, nil, 0)
    if #tObj > 0 then
      tTar = tObj[1]
    end
  end
  if tTar and aKeepDist < tTar.dst then
    RunTo(tTar.x, tTar.y, 0, 500)
    local tick_out = GetTickCount()
    while true do
      local temp = FindObjByTID(tTar.id)
      if not temp then
        break
      end
      tTar = temp
      RunTo(temp.x, temp.y, 0, 500)
      if aKeepDist >= temp.dst then
        break
      end
      if GetTickCount() - tick_out > 8000 then
        PushColorMsg("跟随攻击目标 超时")
        break
      end
      DebugStr("跟随攻击目标")
      DieOutAndGetPos()
    end
  end
  return tTar
end

function MoveCallback_InMyGuild(aPosX, aPosY, aSceneID)
  if IsMyGuildCity() then
    return MoveCallBack_Default(aPosX, aPosY, aSceneID)
  end
  return false
end

function MoveCallback_GoToGuild(aPosX, aPosY, aSceneID)
  local nowSceneName = GetCurrentSceneName()
  if string.find(nowSceneName, "神兵殿", nil, true) then
    PushDebugMessage("进入帮派城市错误:" .. nowSceneName)
  end
  if IsMyGuildCity() then
    return false
  end
  MoveCheckOtherGuildCity()
  return MoveCallback_NoFuben(aPosX, aPosY, aSceneID)
end

function GoToGuild(aCallBack)
  local bsuccess = false
  DeleteDebugMsg("你还没有加入帮会。")
  local _cb = MoveCallback_GoToGuild
  if aCallBack then
    function _cb(_aX, _aY, _aScene)
      if aCallBack() then
        return MoveCallback_GoToGuild(_aX, _aY, _aScene)
      end
      return false
    end
  end
  while true do
    if IsMyGuildCity() then
      bsuccess = true
      break
    end
    MoveCheckOtherGuildCity()
    if IsInDebugMsg("你还没有加入帮会。") then
      break
    end
    local nowSceneName = GetCurrentSceneName()
    if string.find(nowSceneName, "神兵殿", nil, true) then
      PushDebugMessage("进入帮派城市错误:" .. nowSceneName)
    end
    local idx = GetSceneMainBranch(GetSceneID())
    if 1 == idx then
      MoveToNPC("范纯粹", 322, 264, 1, nil, nil, nil, _cb, nil, true)
      Sleep(600)
    elseif 2 == idx then
      MoveToNPC("范纯礼", 179, 121, 2, nil, nil, nil, _cb, nil, true)
      Sleep(600)
    elseif 246 == idx then
      MoveToNPC("范纯祐", 190, 131, 246, nil, nil, nil, _cb, nil, true)
      Sleep(600)
    else
      MoveToNPC("范纯仁", 237, 236, LUOYANG_ID, nil, nil, nil, _cb, nil, true)
      Sleep(600)
    end
    local strText = GetNPCEventListAllItem()
    if string.find(strText, "#{BHCS_090219_05}", nil, true) or string.find(strText, "查看帮会列表", nil, true) then
      if string.find(strText, "#{BHCS_090219_07}", nil, true) or string.find(strText, "进入本帮城市", nil, true) then
        QuestFrameOptionClicked_Item("进入本帮城市", 1, 600)
        QuestFrameOptionClicked_Item("#{BHCS_090219_07}", 1, 600)
      else
        break
      end
    else
      Sleep(3000)
    end
    DebugStr("进入帮派城市")
  end
  return bsuccess
end

function IsZhuangYuanScene()
  local b = GetLuaValue("local bRet = BieYeFurniture:IsBieYeScene(); if bRet then return 1 else return 0 end", "n")
  if 1 == b then
    return true
  end
  return false
end

function GoToZhuangYuan(aType)
  local function _move_cb(fX, fY, nScene)
    return not IsZhuangYuanScene()
  end
  
  if not IsZhuangYuanScene() then
    local cur_scene_id = GetSceneID()
    if 2 == cur_scene_id then
      MoveTo(210, 192, 2, nil, nil, nil, _move_cb)
    elseif 1 == cur_scene_id then
      MoveTo(199, 284, 1, nil, nil, nil, _move_cb)
    elseif 246 == cur_scene_id then
      MoveTo(207, 130, 246, nil, nil, nil, _move_cb)
    else
      MoveTo(193, 289, LUOYANG_ID, nil, nil, nil, _move_cb)
    end
    Sleep(800)
    if not IsZhuangYuanScene() then
      local tObj = Enum2XByTitle("庄园管事", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        TalkNpc(tObj[1].name)
        Sleep(1000)
        if 1 == aType or 4 == aType then
          if Player:IsLeader() then
            QuestFrameOptionClicked_Item("#{JYGZ_160523_04}", 1, 800)
            if 4 == aType then
              QuestFrameOptionClicked_Item("#{JYGZ_160809_399}", 1, 800)
            else
              QuestFrameOptionClicked_Item("#{JYGZ_160809_398}", 1, 800)
            end
          end
        else
          QuestFrameOptionClicked_Item("#{JYGZ_160523_03}", 1, 800)
          if 3 == aType then
            QuestFrameOptionClicked_Item("#{JYGZ_160525_188}", 1, 800)
          else
            QuestFrameOptionClicked_Item("#{JYGZ_160525_187}", 1, 800)
          end
        end
      end
    end
    DebugStr("正在进入庄园中")
  end
end

function GoOutZhuangYuan()
  while IsZhuangYuanScene() do
    DebugStr("离开庄园")
    MoveToNPC("何闲庭", 125, 147, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{JYGZ_160523_07}", 1, 1000)
    QuestFrameOptionClicked_Item("#{JYGZ_160523_07}", 1, 1000)
    QuestFrameOptionClicked_Item("#{JYGZ_160523_97}", 1, 1000)
  end
end

function TargetColor(aTargetGuid, aMemberGuid)
  if -1 == aTargetGuid then
    return "绿"
  end
  for i = 1, #aMemberGuid do
    if aMemberGuid[i] == aTargetGuid then
      return "红"
    end
  end
  return "白"
end

function GetTargetColor(aTarget)
  local allGuid = {}
  local allMember = Team:GetAllMemberInfo()
  for i = 1, #allMember do
    allGuid[#allGuid + 1] = allMember[i].guid
  end
  if 0 == #allGuid then
    local myguid = Player:GetGUID()
    allGuid[1] = myguid
  end
  return TargetColor(aTarget.owner, allGuid)
end

function ObjFilterByColor(aObj, aColor)
  local tTmp = {}
  if nil == aObj then
    return tTmp
  end
  if nil == aColor or "" == aColor then
    return aObj
  end
  local allGuid = {}
  local allMember = Team:GetAllMemberInfo()
  for i = 1, #allMember do
    allGuid[#allGuid + 1] = allMember[i].guid
  end
  if 0 == #allGuid then
    local myguid = Player:GetGUID()
    allGuid[1] = myguid
  end
  for i = 1, #aObj do
    local guid = aObj[i].owner
    local strColor = TargetColor(guid, allGuid)
    if string.find(aColor, strColor, nil, true) then
      tTmp[#tTmp + 1] = aObj[i]
    end
  end
  return tTmp
end

function ObjFilterByStr(aObj, aStrCmp, aPiPeiType, aField)
  local field = aField or "name"
  local tTmp = {}
  if nil == aObj then
    return tTmp
  end
  if type(aStrCmp) ~= "string" or "" == aStrCmp then
    return aObj
  end
  aPiPeiType = aPiPeiType or 0
  if 3 == aPiPeiType or 4 == aPiPeiType then
    aStrCmp = HandleText_AddFuHao(aStrCmp, " ")
  end
  local tObj2
  if "title" == aField then
    tObj2 = DeleteTableFieldValue(aObj, field, {nil})
  else
    tObj2 = DeleteTableFieldValue(aObj, field, {nil, ""})
  end
  for i = 1, #tObj2 do
    if 0 == aPiPeiType then
      if tObj2[i][field] == aStrCmp then
        local n = #tTmp + 1
        tTmp[n] = tObj2[i]
      end
    elseif 1 == aPiPeiType then
      if "" ~= tObj2[i][field] and string.find(aStrCmp, tObj2[i][field], nil, true) then
        tTmp[#tTmp + 1] = tObj2[i]
      end
    elseif 2 == aPiPeiType then
      if "" == tObj2[i][field] or not string.find(aStrCmp, tObj2[i][field], nil, true) then
        local n = #tTmp + 1
        tTmp[n] = tObj2[i]
      end
    elseif 3 == aPiPeiType then
      if string.find(aStrCmp, " " .. tObj2[i][field] .. " ", nil, true) then
        local n = #tTmp + 1
        tTmp[n] = tObj2[i]
      end
    elseif 4 == aPiPeiType then
      if not string.find(aStrCmp, " " .. tObj2[i][field] .. " ", nil, true) then
        tTmp[#tTmp + 1] = tObj2[i]
      end
    elseif 5 == aPiPeiType and string.find(tObj2[i][field], aStrCmp, nil, true) then
      tTmp[#tTmp + 1] = tObj2[i]
    end
  end
  return tTmp
end

function ObjFilterByStrClass(aObj, aClassName, aType)
  aType = aType or 0
  return ObjFilterByStr(aObj, aClassName, aType, "class")
end

function ObjFilterByTitle(aObj, aTitle, aType)
  aType = aType or 0
  return ObjFilterByStr(aObj, aTitle, aType, "title")
end

function ObjFilterByName(aObj, aName, aType)
  aType = aType or 0
  return ObjFilterByStr(aObj, aName, aType, "name")
end

function ObjFilterByInt(aObj, aCmp, aType, aField)
  local field = aField or "hp"
  if type(aCmp) ~= "number" or aCmp < 0 then
    return aObj
  end
  local tTmp = {}
  aType = aType or 1
  if nil == aObj then
    return tTmp
  end
  for i = 1, #aObj do
    if 0 == aType then
      if aObj[i][field] == aCmp then
        local n = #tTmp + 1
        tTmp[n] = aObj[i]
      end
    elseif 1 == aType then
      if aCmp < aObj[i][field] then
        local n = #tTmp + 1
        tTmp[n] = aObj[i]
      end
    elseif 2 == aType then
      if aCmp >= aObj[i][field] then
        local n = #tTmp + 1
        tTmp[n] = aObj[i]
      end
    elseif 3 == aType then
      if aCmp <= aObj[i][field] then
        local n = #tTmp + 1
        tTmp[n] = aObj[i]
      end
    elseif 4 == aType and aCmp > aObj[i][field] then
      local n = #tTmp + 1
      tTmp[n] = aObj[i]
    end
  end
  return tTmp
end

function ObjFilterByHP(aObj, aCmp, aType)
  aType = aType or 2
  return ObjFilterByInt(aObj, aCmp, aType, "hp")
end

function ObjFilterByDst(aObj, aCmp, aType)
  aType = aType or 2
  return ObjFilterByInt(aObj, aCmp, aType, "dst")
end

function ObjFilterByTID(aObj, aCmp)
  return ObjFilterByInt(aObj, aCmp, 0, "id")
end

function ObjFilterByClass(aObj, aType)
  local tObj2 = {}
  if nil == aObj then
    return tObj2
  end
  if nil == aType then
    return aObj
  end
  if #aType < 4 then
    PushDebugMessage("ObjFilterByClass:过滤类型参数错误!")
    return tObj2
  end
  local szCmpClass = " "
  if 1 == aType[1] then
    szCmpClass = szCmpClass .. "NPC "
  end
  if 1 == aType[2] then
    szCmpClass = szCmpClass .. "怪物 "
  end
  if 1 == aType[3] then
    szCmpClass = szCmpClass .. "玩家 "
  end
  if 1 == aType[4] then
    szCmpClass = szCmpClass .. "珍兽 "
  end
  if nil ~= aType[5] and 1 == aType[5] then
    szCmpClass = szCmpClass .. "宝箱 "
  end
  return ObjFilterByStr(aObj, szCmpClass, 3, "class")
end

function ObjFilterByBHID(aObj, aCmp)
  local tTmp = {}
  if nil == aObj then
    return tTmp
  end
  if type(aCmp) ~= "string" or "" == aCmp then
    return aObj
  end
  for i = 1, #aObj do
    if string.find(aCmp, " " .. aObj[i].bhid .. " ", nil, true) then
      local n = #tTmp + 1
      tTmp[n] = aObj[i]
    end
  end
  return tTmp
end

function ObjSort(aObj, aSort)
  aSort = aSort or 0
  if 1 == aSort then
    BubbleByDst(aObj, 1)
  elseif 2 == aSort then
    BubbleByDst(aObj, 2)
  elseif 3 == aSort then
    BubbleByHP(aObj, 1)
  elseif 4 == aSort then
    BubbleByHP(aObj, 2)
  end
end

function Enum2XByName(aName, aClassType, aFilter, aSort, aPiPeiType)
  if type(aName) ~= "string" or "" == aName then
    return {}
  end
  aPiPeiType = aPiPeiType or 0
  local tObj = EnumEnvObj()
  local tObj2 = ObjFilterByStr(tObj, aName, aPiPeiType, "name")
  tObj2 = ObjFilterByClass(tObj2, aClassType)
  if nil ~= aFilter then
    tObj2 = ObjFilterByInt(tObj2, aFilter[1], 1, "hp")
    local cmp_dist = aFilter[2]
    tObj2 = ObjFilterByInt(tObj2, cmp_dist, 2, "dst")
  end
  ObjSort(tObj2, aSort)
  return tObj2
end

function Enum2XByClass(aClassName, aFilter, aSort)
  local tObj = EnumEnvObj()
  local tObj2 = ObjFilterByStr(tObj, aClassName, 1, "class")
  if nil ~= aFilter then
    tObj2 = ObjFilterByInt(tObj2, aFilter[1], 1, "hp")
    local cmp_dist = aFilter[2]
    tObj2 = ObjFilterByInt(tObj2, cmp_dist, 2, "dst")
  end
  ObjSort(tObj2, aSort)
  return tObj2
end

function Enum2XByTitle(aTitle, aClassType, aFilter, aSort, aPiPeiType)
  if type(aTitle) ~= "string" or "" == aTitle then
    return {}
  end
  local tObj = EnumEnvObj()
  local tObj2 = ObjFilterByStr(tObj, aTitle, aPiPeiType, "title")
  tObj2 = ObjFilterByClass(tObj2, aClassType)
  if nil ~= aFilter then
    tObj2 = ObjFilterByInt(tObj2, aFilter[1], 1, "hp")
    local cmp_dist = aFilter[2]
    tObj2 = ObjFilterByInt(tObj2, cmp_dist, 2, "dst")
  end
  ObjSort(tObj2, aSort)
  return tObj2
end

function EnumFriendPlayer(aObj)
  local tObj = aObj or Enum2XByClass("玩家")
  local tTemp = {}
  for i = 1, #tObj do
    local tmp = tObj[i]
    if 1 == tmp.attackType or -1 == tmp.attackType then
      table.insert(tTemp, tmp)
    end
  end
  return tTemp
end

function EnumPlayerList(aFlag)
  local tList = {}
  local strInfo = GetLuaValue(fmt("return meGetPlayerList(%s)", tostring(aFlag)), "s")
  local arrInfo = SplitString(strInfo, " ", true)
  for i = 1, #arrInfo do
    local arr2 = SplitString(arrInfo[i], "&")
    if #arr2 >= 2 then
      local tid = tonumber(arr2[1])
      if tid then
        table.insert(tList, {id = tid})
      end
    end
  end
  local tEnv = Enum2XByClass("玩家", {0, -1})
  local tObj = {}
  for i = 1, #tEnv do
    for j = 1, #tList do
      local tmp = tEnv[i]
      if tmp.id == tList[j].id then
        table.insert(tObj, tmp)
      end
    end
  end
  return tObj
end

function FindObjByGUID(aGUID)
  if type(aGUID) ~= "number" then
    return nil
  end
  local tObj = EnumEnvObj()
  for i = 1, #tObj do
    if tObj[i].guid == aGUID then
      return tObj[i]
    end
  end
  return nil
end

function ObjTickClear(aFilter)
  aFilter = {}
  return aFilter
end

function ObjTickPush(aFilter, aId, aField)
  local fld = aField or "id"
  aFilter = DeleteTableFieldValue(aFilter, fld, {aId})
  table.insert(aFilter, {
    [fld] = aId,
    tick = GetTickCount()
  })
  return aFilter
end

function ObjTickFilter(aObj, aFilter, aTickOut, aField)
  local fld = aField or "id"
  local tRet = {}
  local nowTick = GetTickCount()
  for i = #aFilter, 1, -1 do
    if aTickOut > 0 and aTickOut < nowTick - aFilter[i].tick then
      table.remove(aFilter, i)
    end
  end
  for i = 1, #aObj do
    local bInsert = true
    for j = 1, #aFilter do
      if aObj[i][fld] == aFilter[j][fld] then
        if aTickOut >= nowTick - aFilter[j].tick then
          bInsert = false
        end
        break
      end
    end
    if bInsert then
      tRet[#tRet + 1] = aObj[i]
    end
  end
  return tRet
end

function ObjFilterByRecord(aObj, aFilter)
  local tRet = {}
  for i = 1, #aObj do
    local bInsert = true
    for j = 1, #aFilter do
      if aObj[i].id == aFilter[j].id then
        bInsert = false
        break
      end
    end
    if bInsert then
      tRet[#tRet + 1] = aObj[i]
    end
  end
  return tRet
end

function EnumObjBuff(aObj)
  local tStr = {}
  if aObj and aObj.baseptr then
    tStr = CEnumObjBuff(aObj.baseptr)
  end
  return tStr
end

function GetHasBuffObj(aObj, aBuffName, aWithSelf)
  local tHas = {}
  if "" == aBuffName then
    return tHas
  end
  for i = 1, #aObj do
    local tmp = aObj[i]
    if aWithSelf or tmp.name ~= g_self.name then
      local tStr = EnumObjBuff(tmp)
      for j = 1, #tStr do
        if string.find(tStr[j], aBuffName, nil, true) then
          table.insert(tHas, tmp)
          break
        end
      end
    end
  end
  return tHas
end

function EnumAttackObj(aClassName, aFilter, aSort)
  local tObj = EnumEnvObj()
  local atkObj = ObjFilterByInt(tObj, 0, 0, "attackType")
  local tObj2 = ObjFilterByStr(atkObj, aClassName, 1, "class")
  if nil ~= aFilter then
    tObj2 = ObjFilterByInt(tObj2, aFilter[1], 1, "hp")
    local cmp_dist = aFilter[2]
    tObj2 = ObjFilterByInt(tObj2, cmp_dist, 2, "dst")
  end
  ObjSort(tObj2, aSort)
  return tObj2
end

function StateHasShiMing(aStateText)
  local state = {
    "失明：",
    "：失明",
    "彼行我释（失明）"
  }
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateHasSanGong(aStateText)
  local state = {
    "散功：",
    "：散功",
    "彼行我释（散功）"
  }
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateHasFengXue(aStateText)
  local state = {
    "封穴：",
    "：封穴",
    "彼行我释（封穴）"
  }
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateHasHunShui(aStateText)
  local state = {
    "昏睡：",
    "：昏睡",
    "彼行我释（昏睡）"
  }
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateHasMabi(aStateText)
  local state = {"麻痹：", "：麻痹"}
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateHasFengYin(aStateText)
  local state = {"封印：", "：封印"}
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateHasDingShen(aStateText)
  if g_self.isjingong then
    local state = {
      "定身：",
      "：定身",
      "彼行我释（定身）"
    }
    for i = 1, #state do
      if string.find(aStateText, state[i], nil, true) then
        return true
      end
    end
  end
  return false
end

function StateHasOthreKongZhi(aStateText)
  local state = {"：眩晕", "恶蟒缠身："}
  for i = 1, #state do
    if string.find(aStateText, state[i], nil, true) then
      return true
    end
  end
  return false
end

function StateRemoveShiMing(aBuffText)
  aBuffText = aBuffText or GetLuaValue("return mePlayerGetAllBuff()", "s")
  if StateHasShiMing(aBuffText) then
    if 0 == g_self.menpai then
      Skill:UseName("明镜台", 350)
    elseif 7 == g_self.menpai then
      Skill:UseName("阳春白雪", 350)
    elseif 10 == g_self.menpai then
      Skill:UseName("净心观月", 350)
    elseif 13 == g_self.menpai then
      Skill:UseName("解我心忧", 350)
    end
  end
  aBuffText = GetLuaValue("return mePlayerGetAllBuff()", "s")
  if StateHasShiMing(aBuffText) then
    Skill:UsePetSkill("高级明目")
    Skill:UsePetSkill("高级净化")
  end
end

function StateRemoveSanGong(aBuffText)
  aBuffText = aBuffText or GetLuaValue("return mePlayerGetAllBuff()", "s")
  if StateHasSanGong(aBuffText) then
    if 1 == g_self.menpai then
      Skill:UseName("坐地求全", 350)
    elseif 6 == g_self.menpai then
      Skill:UseName("非枯非荣", 350)
    elseif 8 == g_self.menpai then
      Skill:UseName("波澜不惊", 350)
    elseif 13 == g_self.menpai then
      Skill:UseName("解我心忧", 350)
    end
  end
end

function StateRemoveFengXue(aBuffText)
  aBuffText = aBuffText or GetLuaValue("return mePlayerGetAllBuff()", "s")
  if StateHasFengXue(aBuffText) then
    if 3 == g_self.menpai then
      Skill:UseName("无懈可击", 350)
    elseif 6 == g_self.menpai then
      Skill:UseName("非枯非荣", 350)
    elseif 11 == g_self.menpai then
      Skill:UseName("冰消冻释", 350)
    elseif 12 == g_self.menpai then
      Skill:UseName("天人合一", 350)
    elseif 13 == g_self.menpai then
      Skill:UseName("解我心忧", 350)
    end
  end
end

function StateRemoveHunShui(aBuffText)
  aBuffText = aBuffText or GetLuaValue("return mePlayerGetAllBuff()", "s")
  if StateHasHunShui(aBuffText) then
    if 2 == g_self.menpai then
      Skill:UseName("神龙摆尾", 350)
    elseif 5 == g_self.menpai then
      Skill:UseName("金石俱焚", 350)
    elseif 13 == g_self.menpai then
      Skill:UseName("解我心忧", 350)
    end
  end
end

function StateRemoveDingShen(aBuffText)
  aBuffText = aBuffText or GetLuaValue("return mePlayerGetAllBuff()", "s")
  if StateHasDingShen(aBuffText) and 2 == g_self.menpai then
    Skill:UseName("神龙摆尾", 350)
  end
end

function StateRemoveBad(bShiMing, bSanGong, bFengXue, bHunShui, bDingShen)
  local szAllBuff = GetLuaValue("return mePlayerGetAllBuff()", "s")
  if bShiMing then
    StateRemoveShiMing(szAllBuff)
  end
  if bSanGong then
    StateRemoveSanGong(szAllBuff)
  end
  if bFengXue then
    StateRemoveFengXue(szAllBuff)
  end
  if bHunShui then
    StateRemoveHunShui(szAllBuff)
  end
  if bDingShen then
    StateRemoveDingShen(szAllBuff)
  end
end

function LootFilter_clear()
  g_lootOld = {}
end

function LootFilter(aObj)
  local tRet = {}
  local nowTick = GetTickCount()
  for i = 1, #aObj do
    local bPick = true
    for j = 1, #g_lootOld do
      if aObj[i].id == g_lootOld[j].id and nowTick - g_lootOld[j].tick <= 60000 then
        bPick = false
        break
      end
    end
    if bPick then
      tRet[#tRet + 1] = aObj[i]
    end
  end
  return tRet
end

function LootChoiceItem(aObj)
  local bPickItem = false
  local tmp = aObj
  local lootID = -1
  CloseWindow("LootPacket")
  OpenPackage(tmp.id)
  for i = 1, 5 do
    if IsWindowVisible("LootPacket") then
      break
    end
    Sleep(100)
  end
  PlayerStateTimeOut(2, 8)
  for i = 1, 40 do
    if IsWindowVisible("LootPacket") then
      Sleep(100)
      lootID = tmp.id
      break
    else
      Sleep(200)
    end
    if not FindObjByTID(tmp.id) then
      break
    end
    OpenPackage(tmp.id)
    DebugStr("捡包:移动到包裹处")
  end
  if -1 ~= lootID then
    local tItem = Bag:EnumLootItem()
    for i = #tItem, 1, -1 do
      local bPick = true
      local tmp = tItem[i]
      if 1 == g_pick.filterMode then
        bPick = false
        if 5 == tmp.itemType and string.find(g_pick.pickItem, " 所有宝石 ", nil, true) then
          bPick = true
        elseif 6 == tmp.itemType and 9 ~= tmp.childType and string.find(g_pick.pickItem, " 子女装备 ", nil, true) then
          bPick = true
        elseif string.find(g_pick.pickItem, " " .. tmp.name .. " ", nil, true) then
          bPick = true
        elseif string.find(g_pick.pickItem, " " .. tmp.class .. " ", nil, true) then
          bPick = true
        end
      elseif not IsXiaoHuiBaiMingDan(tmp) then
        if g_config.item.changyong_destroy then
          local otherName = Bag:GetChangYongDestroyItem()
          if string.find(otherName, " " .. tmp.name .. " ", nil, true) then
            bPick = false
          end
        end
        local tDestroyItem = g_config.item.destroy
        if bPick then
          for i = 1, #tDestroyItem.class do
            if tDestroyItem.class[i].text == tmp.class and (0 == tDestroyItem.class[i].data or 1 == tDestroyItem.class[i].data) then
              bPick = false
              break
            end
          end
        end
        if bPick then
          for i = 1, #tDestroyItem.name do
            if tDestroyItem.name[i].text == tmp.name and (0 == tDestroyItem.name[i].data or 1 == tDestroyItem.name[i].data) then
              bPick = false
              break
            end
          end
        end
      else
        bPick = true
      end
      if bPick then
        local nCurPage = math.floor(tItem[i].index / 4) + 1
        local line = tItem[i].index % 4 + 1
        local strText = fmt([[
                        if IsWindowShow('LootPacket')==true then 
                            setmetatable(_G, {__index =LootPacket_Env});
                            LootPacket_Update(%d,0);
                            LootPacket_Clicked(%d)                       
                        end
                    ]], nCurPage, line)
        GetLuaValue(strText)
        Sleep(160)
        bPickItem = true
      end
    end
  end
  return lootID, bPickItem
end

function LootAllItem(aObj)
  local tmp = aObj
  PickAll()
  OpenPackage(tmp.id)
  Sleep(200)
  PlayerStateTimeOut(2, 8)
  Sleep(300)
  if GetOpenLootID() == tmp.id then
    return tmp.id
  end
  return -1
end

function ClearBag()
  Bag_DeleteItem(false)
  Bag_Move2TempBank(nil, nil, nil, false)
end

function PickUpLua(pickNum, aDelBag, aClearFilter)
  if aDelBag or g_pick.check then
    ClearBag()
  end
  if aClearFilter then
    LootFilter_clear()
  end
  if g_pick.ispick == false then
    return 0, 0, 0, false
  end
  local tOrgObj = Enum2XByClass("包裹", nil, 1)
  local tObj = LootFilter(tOrgObj)
  pickNum = pickNum or #tObj
  if pickNum > #tObj then
    pickNum = #tObj
  end
  local idLoot = -1
  local bPickItem = false
  local bFollow = false
  if pickNum > 0 and IsPlayerFollow(false) then
    if -1 == Player:GetBuff("乾坤壶：") then
      bFollow = true
      PushColorMsg("捡包：退出跟随")
      Player:TeamFollow(false, 300)
    else
      PushColorMsg("乾坤壶捡包：不退出跟随")
    end
  end
  for i = 1, pickNum do
    if 1 == g_pick.pickmode then
      idLoot, bPickItem = LootChoiceItem(tObj[i])
      if bPickItem and g_pick.check then
        for j = 1, 5 do
          Sleep(100)
          if not (9 ~= Player:GetState() and FindObjByTID(tObj[i].id)) then
            break
          end
          _, bPickItem = LootChoiceItem(tObj[i])
          if false ~= bPickItem then
            Bag_DeleteItem(false)
          else
            break
          end
        end
      end
    else
      bPickItem = true
      idLoot = LootAllItem(tObj[i])
      if g_pick.check then
        for j = 1, 6 do
          Sleep(100)
          if 9 ~= Player:GetState() and FindObjByTID(tObj[i].id) then
            local _id = LootAllItem(tObj[i])
            if -1 ~= _id then
              idLoot = _id
            end
          else
            break
          end
        end
      end
    end
    if -1 ~= idLoot then
      g_pick.lastpicktime = GetTickCount()
      table.insert(g_lootOld, {
        id = idLoot,
        tick = GetTickCount()
      })
      if #g_lootOld > 20 then
        table.remove(g_lootOld, 1)
      end
    end
    Sleep(200)
  end
  if bFollow and Player:IsLeader() then
    Player:TeamFollow(true, 300)
  end
  return idLoot, #tObj, #tOrgObj, bPickItem
end

function PickUpLua_SetItem(aItemNames)
  g_pick.pickmode = 1
  g_pick.filterMode = 1
  g_pick.pickItem = HandleText_AddFuHao(aItemNames, " ")
end

function PickUpMust()
  local tick_out = GetTickCount()
  while true do
    EatBindItem()
    local _, _, numBag = PickUpLua(nil, true, true)
    if numBag > 0 then
      DebugStr("捡包中...")
      if IsMount() == false then
        CDG:checktime0()
      end
    else
      break
    end
    Sleep(300)
  end
end

function PickUp_callback()
  CDG:BossStart(-1)
  EatBindItem(1)
  EatFubenItem(1)
  return true
end

function PickUpLua_Boss(aPickTimeDiff, aMaxPickTime, aSceneID, aPos, aDisfollow, aCallBack)
  aPickTimeDiff = aPickTimeDiff or 30
  aMaxPickTime = aMaxPickTime or 15
  aSceneID = aSceneID or GetSceneID()
  aPos = aPos or {}
  aCallBack = aCallBack or PickUp_callback
  if nil == aDisfollow then
    aDisfollow = true
  end
  local idxPos = 1
  local tick_out = GetTickCount()
  if -1 ~= Player:GetBuff("乾坤壶：") then
    PushColorMsg("您已开启乾坤壶")
    aMaxPickTime = 5
  end
  DeleteDebugMsg("背包已满！")
  while true do
    if IsInDebugMsg("背包已满！") then
      aMaxPickTime = 60
    end
    if 9 == Player:GetState() then
      PushColorMsg("捡Boss包时死亡")
      DieRelive(0)
      Sleep(200)
    end
    if GetTickCount() - tick_out > aMaxPickTime * 1000 then
      PushDebugMessage("Boss捡包:超过最长时间%s秒", aMaxPickTime)
      break
    end
    if aDisfollow and Player:IsFollow() then
      Player:TeamFollow(false, 200)
    end
    local pickID, _, _, hasItem = PickUpLua(nil, true)
    if GetSceneID() ~= aSceneID then
      PushDebugMessage("Boss捡包:地图发生变化,不再搜索")
      break
    end
    EatBindItem(1)
    EatFubenItem(1)
    if -1 ~= aPickTimeDiff and GetTickCount() - g_pick.lastpicktime < aPickTimeDiff * 1000 then
      if not IsInDebugMsg("背包已满！") then
        PushDebugMessage("Boss捡包:%s秒内已经捡过包,不再搜索", aPickTimeDiff)
        if IsInFubenScene() then
          SleepCallBack(2500, 100, function()
            PickUpLua(nil, true)
            aCallBack()
            return true
          end)
        end
        break
      else
        local tOrgObj = Enum2XByClass("包裹", nil, 1)
        if not (#tOrgObj > 0) then
          break
        end
        PushDebugMessage("Boss捡包:背包需要清理!")
        if not (pickID > 0) or false ~= hasItem or 1 ~= #tOrgObj then
          LootFilter_clear()
        else
          break
        end
      end
    elseif IsInDebugMsg("背包已满！") then
      local tOrgObj = Enum2XByClass("包裹", nil, 1)
      if #tOrgObj > 0 then
        LootFilter_clear()
        PushDebugMessage("Boss捡包:背包需要清理")
      end
    end
    if #aPos > 0 then
      if idxPos > #aPos then
        idxPos = 1
      end
      local pos = aPos[idxPos]
      if pos and pos.x and pos.y and pos.x > 0 and pos.y > 0 then
        RunTo(pos.x, pos.y, 2, 500)
        if GetDist(pos.x, pos.y) < 2 then
          idxPos = idxPos + 1
        end
      end
    end
    Sleep(300)
    if not aCallBack() then
      break
    end
    DebugStr("包裹刷新可能延迟,持续" .. aMaxPickTime .. "秒搜索包裹中")
  end
  PickUpLua(nil, true)
  PushDebugMessage("Boss捡包:捡包完成!")
end

function GoSafeScene(aScene, aPosX, aPosY, aMount, aMoveCB)
  aMoveCB = aMoveCB or MoveCallback_NoFuben
  local sceneName = string.gsub(aScene, " ", "")
  local sceneID = GetSceneIDByName(sceneName)
  local posX = tonumber(aPosX)
  local posY = tonumber(aPosY)
  local msg = "前往安全地图"
  if -1 ~= sceneID and posX and posY and posX > 0 and posY > 0 then
  else
    posX = 358
    posY = 227
    sceneID = 1
    msg = "安全地图:您未在通用页面设置安全坐标,前往默认坐标"
  end
  if not IsDestination(posX, posY, sceneID, 3) then
    PushColorMsg(msg)
    MoveTo(posX, posY, sceneID, nil, aMount, nil, aMoveCB, true, true)
    if GetSceneID() == 280 then
      for i = 1, 10 do
        MoveDingWeiFu(sceneID)
        Sleep(500)
      end
    end
  end
end

function GoBackCity()
  GoSafeScene(g_config.tysz.backcity, g_config.tysz.backcity_x, g_config.tysz.backcity_y)
end

function RemoveStall()
  while 10 == Player:GetState() do
    DebugStr("收摊")
    GetLuaValue("StallSale:ConfirmRemoveStall();")
    Sleep(1000)
    MessageBox_Self_OK_Clicked(1000)
    if GetLuaValue("setmetatable(_G, {__index=MessageBox_Self_Env});if this:IsVisible() then MessageBox_Self_Cancel_Clicked(1);MessageBox_Self_Cancel_Clicked(0);return 1 end; return 0", "b") then
      Sleep(2000)
    end
  end
end

function RecvState(aState)
  DoSystem(4, aState)
end

function CommonParamInit(aScriptName)
  LoadScript("daguai")
  CDG:InitCommonParam()
  CDG.scriptName = aScriptName
  CDG:checkSkill(true)
  CDG.skill_jinji = {}
  for i = 1, #Skill.skill_jinji do
    local tmp = Skill.skill_jinji[i]
    local skl = {
      data = 0,
      text = tmp.name
    }
    table.insert(CDG.skill_jinji, skl)
  end
end

function FubenOnStart(aScriptName, aMust)
  if not (not g_config.fuben.ty_manxue or IsInFubenScene()) or aMust then
    XiaoChangHuiXue(90, true)
  end
  if not (not g_config.fuben.ty_buji or IsInFubenScene()) or aMust then
    MainSellBuyItem(false, aScriptName)
  end
  if g_config.fuben.ty_cuncang and not IsInFubenScene() then
    MainBankSaveItem()
  end
end

function FubenParamInit(aScriptName)
  CDG:InitFubenParam()
  if g_config.nottongbu.fuben_ty_xhmode then
    CDG.attack = false
  elseif g_config.nottongbu.fuben_ty_not_attack then
    CDG.attack = false
  end
  FubenOnStart(aScriptName)
end

function PlayerDataInit()
  if IsWindowVisible("PlayerFrame") or IsWindowVisible("MainMenuBar") then
    Player:IsJinGong()
    g_self.name = Player:GetName()
    g_self.guid = Player:GetGUID()
    g_self.level = Player:GetDataInt("LEVEL")
    if 0 == Skill.baseID then
      Skill:RefreshSkill()
    end
  end
end

function ScriptExecScript(aStrScript, aExecScript)
  aExecScript = aExecScript or ""
  if nil == aStrScript then
    PushColorMsg("%s 有了新设置,请保存设置", aExecScript)
    return
  end
  local runScript = HandleText(aStrScript)
  local arrScript = SplitString(runScript, " ", true)
  local bNext = true
  for i = 1, #arrScript do
    local qxNext = false
    local runScript = arrScript[i]
    if string.find(arrScript[i], "[", nil, true) and string.find(arrScript[i], "]", nil, true) and (string.find(arrScript[i], "功能", nil, true) or string.find(arrScript[i], "0", nil, true)) then
      local nextScript = arrScript[i + 1]
      if nextScript then
        runScript = runScript .. " " .. nextScript
        qxNext = true
      end
    end
    if bNext then
      if runScript ~= aExecScript then
        PushColorMsg("%s 由 %s 执行", runScript, aExecScript)
        LoadScript(runScript)
      else
        PushColorMsg("%s 不能执行自身", runScript)
      end
    else
      bNext = true
    end
    if qxNext then
      bNext = false
    end
  end
end

function ScriptOnUserStart(aScriptName)
  local runingScrpit = aScriptName
  if not g_config.tysz.check_onstart or not g_config.tysz.check_onstart_run then
    return
  end
  local allCheckScript = HandleText(g_config.tysz.check_onstart)
  local arrCheck = SplitString(allCheckScript, " ", true)
  for i = 1, #arrCheck do
    if arrCheck[i] == runingScrpit then
      Log("自定义执行：" .. runingScrpit .. " 执行前执行 " .. HandleText(g_config.tysz.check_onstart_run))
      ScriptExecScript(g_config.tysz.check_onstart_run, runingScrpit)
      break
    end
  end
end

function ScriptOnUserStop(aScriptName)
  local runingScrpit = aScriptName
  if not g_config.tysz.check_onstop or not g_config.tysz.check_onstop_run then
    return
  end
  local allCheckScript = HandleText(g_config.tysz.check_onstop)
  local arrCheck = SplitString(allCheckScript, " ", true)
  for i = 1, #arrCheck do
    if arrCheck[i] == runingScrpit then
      Log("自定义执行：" .. runingScrpit .. " 完成后执行 " .. HandleText(g_config.tysz.check_onstop_run))
      ScriptExecScript(g_config.tysz.check_onstop_run, runingScrpit)
      break
    end
  end
end

function ScriptStart_State(aScriptName)
  if "自动摆摊" ~= aScriptName then
    RemoveStall()
  end
  if "天外马贼" ~= aScriptName and "自动刷马贼" ~= aScriptName and "刷反贼" ~= aScriptName and "天降奇兽" ~= aScriptName and "偷袭门派" ~= aScriptName and "野猪暴走" ~= aScriptName then
    Player:TeamFollow(false, 500)
  end
end

function ScriptOnStart(aScriptName, aCommon, aIsFuben, aEatItem)
  PushDebugMessage("执行：" .. aScriptName)
  Log(aScriptName .. " 开始地图 " .. GetCurrentSceneName() .. " " .. GetSceneID())
  ClearTick_CheckJGYC()
  RecvState(0)
  ScriptStart_State(aScriptName)
  GlobalParamInit()
  PlayerDataInit()
  if aIsFuben then
    aCommon = true
  end
  CommonParamInit(aScriptName)
  if aIsFuben then
    FubenParamInit(aScriptName)
  end
  ParamInitUpgradePet(aScriptName)
  if nil == aEatItem or aEatItem then
    EatBindItem(2)
    EatFubenItem(10)
  end
end

function ScriptOnStop(aScriptName, aIsFuben, aMoveToTempBank)
  Log(aScriptName .. " 完成地图 " .. GetCurrentSceneName() .. " " .. GetSceneID())
  GlobalParamInit()
  RecvState(0)
  EatBindItem(10)
  local strTakeItem = "真元珀 真元精珀"
  if not IsInDebugMsg("#{LSHYH_150210_123}") then
    strTakeItem = strTakeItem .. " 上品少阳丹"
  end
  TempBank2Bag(strTakeItem, 2)
  EatBindItem(5)
  if nil == aMoveToTempBank or aMoveToTempBank then
    Bag_Move2TempBank()
  end
  Box2TempBag()
  EatFubenItem(10)
  OpenBindItem(5)
  EatBindItem(5)
  OpenBindItem(5)
  Bag:PackUpTempBag()
  if aIsFuben then
    if g_config.fuben.ty_manxue_end and not IsInFubenScene() then
      XiaoChangHuiXue(90, true)
    end
    if g_config.fuben.ty_buji_end and not IsInFubenScene() then
      MainSellBuyItem(false, aScriptName)
    end
    if g_config.fuben.ty_cuncang_end and not IsInFubenScene() then
      MainBankSaveItem()
    end
  end
end

function ChangeSceneLine(aMust)
  while true do
    local strScene = GetCurrentSceneName()
    if not (string.find(strScene, "2线", nil, true) or string.find(strScene, "3线", nil, true)) then
      break
    end
    Dismount(1000)
    Player:TeamFollow(false)
    GetLuaValue([[
                local g_BranchingScene = GetMultiLineInfo()
                if g_BranchingScene ~= nil and table.getn(g_BranchingScene) >=1 then
                    -- local nSceneCount = table.getn(g_BranchingScene)
                    Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("OnChangeBranchingScene")
                    Set_XSCRIPT_ScriptID( 999114 )
                    Set_XSCRIPT_Parameter( 0, g_BranchingScene[1]);	
                    Set_XSCRIPT_ParamCount(1)
                    Send_XSCRIPT()            
                end
                ]])
    Sleep(1500)
    PlayerStateTimeOut(5, 10)
    if aMust then
    else
      break
    end
    Sleep(200)
    DebugStr("切换线路中")
  end
end

function ChangeSceneLine(aMust)
  while true do
    local strScene = GetCurrentSceneName()
    if not (string.find(strScene, "2线", nil, true) or string.find(strScene, "3线", nil, true)) then
      break
    end
    Dismount(1000)
    Player:TeamFollow(false)
    GetLuaValue([[
                local g_BranchingScene = GetMultiLineInfo()
                if g_BranchingScene ~= nil and table.getn(g_BranchingScene) >=1 then
                    -- local nSceneCount = table.getn(g_BranchingScene)
                    Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("OnChangeBranchingScene")
                    Set_XSCRIPT_ScriptID( 999114 )
                    Set_XSCRIPT_Parameter( 0, g_BranchingScene[1]);	
                    Set_XSCRIPT_ParamCount(1)
                    Send_XSCRIPT()            
                end
                ]])
    Sleep(1500)
    PlayerStateTimeOut(5, 10)
    if aMust then
    else
      break
    end
    Sleep(200)
    DebugStr("切换线路中")
  end
end

function ChangeScene2Line()
  while true do
    local strScene = GetCurrentSceneName()
    if string.find(strScene, "1线", nil, true) then
      Dismount(1000)
      Player:TeamFollow(false)
      GetLuaValue([[
                local g_BranchingScene = GetMultiLineInfo()
                if g_BranchingScene ~= nil and table.getn(g_BranchingScene) >=1 then
                    -- local nSceneCount = table.getn(g_BranchingScene)
                    Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("OnChangeBranchingScene")
                    Set_XSCRIPT_ScriptID( 999114 )
                    Set_XSCRIPT_Parameter( 0, g_BranchingScene[2]);	
                    Set_XSCRIPT_ParamCount(1)
                    Send_XSCRIPT()            
                end
                ]])
      Sleep(1500)
      PlayerStateTimeOut(5, 10)
    else
      break
    end
    Sleep(200)
    DebugStr("切换2线中")
  end
end

function ChangeSceneLineID(aMapID)
  if GetSceneServerID() ~= aMapID then
    DebugStr("切换线路" .. aMapID)
    Dismount(500)
    while true do
      Player:TeamFollow(false)
      GetLuaValue(fmt([[
                local nMapID = %d
                local nSceneId = GetSceneServerID()
                if nSceneId ~= nMapID then 
                    local g_BranchingScene = GetMultiLineInfo()
                    if g_BranchingScene ~= nil then
                        local nSceneCount = table.getn(g_BranchingScene)
                        for i = 1, nSceneCount do
                            if g_BranchingScene[i] == nMapID then
                                Clear_XSCRIPT()
                                Set_XSCRIPT_Function_Name("OnChangeBranchingScene")
                                Set_XSCRIPT_ScriptID( 999114 )
                                Set_XSCRIPT_Parameter( 0, g_BranchingScene[i]);	
                                Set_XSCRIPT_ParamCount(1)
                                Send_XSCRIPT()            
                            end
                        end
                    end
                end
                ]], aMapID))
      Sleep(1500)
      PlayerStateTimeOut(5, 10)
      Sleep(200)
      DebugStr("切换线路" .. aMapID)
      break
    end
  end
end
