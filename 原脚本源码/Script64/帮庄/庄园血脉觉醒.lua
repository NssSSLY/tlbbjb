-- 反编译自 dfz64.dll 内嵌字节码 00358006（unluac 2025-12-23；仅供分析）
local m_script_name = "庄园血脉觉醒"
ScriptOnStart(m_script_name, false, false, false)
g_config["庄园血脉觉醒"] = {}
g_config["庄园血脉觉醒"]["珍兽名称"] = ReadConfigText("ZH", "bjk51")
local m_param = {}
m_param.all_name = HandleText_AddFuHao(g_config["庄园血脉觉醒"]["珍兽名称"], " ", true)

function XMJX_GetListItem()
  local strData1, strData2 = GetLuaValue([[
            local strData1 = ""
            local strData2 = ""
            setmetatable(_G, {__index = BieYePetBar_Awake_Env})
            if this:IsVisible() then
                local nCount1 = BieYePetBar_Awake_List01:GetItemNumber()
                for i = 1, nCount1 do
                    local itemText = BieYePetBar_Awake_List01:GetItem(i)
                    local strTemp = i .. "&" .. itemText
                    strData1 = strData1 .. strTemp .. " "
                end
                local nCount2 = BieYePetBar_Awake_List02:GetItemNumber()
                for i = 1, nCount2 do
                    local itemText = BieYePetBar_Awake_List02:GetItem(i)
                    local strTemp = i .. "&" .. itemText
                    strData2 = strData2 .. strTemp .. " "
                end
            end
            return strData1, strData2
        ]], "ss")
  local list1 = {}
  local list2 = {}
  local strArr1 = SplitString(strData1, " ", true)
  for i = 1, #strArr1 do
    local arrInfo = SplitString(strArr1[i], "&", true)
    if #arrInfo >= 2 then
      local idx = tonumber(arrInfo[1])
      local showText = arrInfo[2]
      if idx then
        table.insert(list1, {index = idx, text = showText})
      end
    end
  end
  local strArr2 = SplitString(strData2, " ", true)
  for i = 1, #strArr2 do
    local arrInfo = SplitString(strArr2[i], "&", true)
    if #arrInfo >= 2 then
      local idx = tonumber(arrInfo[1])
      local showText = arrInfo[2]
      if idx then
        table.insert(list2, {index = idx, text = showText})
      end
    end
  end
  return list1, list2
end

function XMJX_GetRealName(aText)
  local _, _, strName, strState = string.find(aText, "(.+)%?(.+)")
  strName = strName or ""
  strState = strState or ""
  return strName, strState
end

function XMJX_AddList(aList, aWhere)
  for i = 1, #aList do
    local tmp = aList[i]
    local petName, petState = XMJX_GetRealName(tmp.text)
    local cmpText = HandleText_AddFuHao(petName, " ", true)
    if string.find(m_param.all_name, cmpText, nil, true) then
      if not string.find(petState, "无法觉醒", nil, true) and not string.find(petState, "疲劳", nil, true) and not string.find(petState, "满阶满级", nil, true) then
        PushDebugMessage(petName)
        GetLuaValue(fmt([[
                            local idx = %d
                            setmetatable(_G, {__index = BieYePetBar_Awake_Env})
                            if this:IsVisible() then
                                BieYePetBar_Awake_List0%d:SetItemSelect(idx)
                                BieYePetBar_Awake_List_Selected(%d)
                            end        
                        ]], tmp.index - 1, aWhere, aWhere - 1))
        Sleep(1000)
        GetLuaValue(fmt([[
                        setmetatable(_G, {__index = BieYePetBar_Awake_Env})
                        if this:IsVisible() then
                            BieYePetBar_Awake_PetList_Input_Click(%d)
                        end
                    ]], aWhere - 1))
        Sleep(600)
      else
        DebugStr(petName .. ":无法觉醒", 2)
      end
    end
  end
end

function _SMain()
  DeleteDebugMsg("#{JYSL_160518_136}")
  CloseAllWindow()
  local tickOut = -1
  while true do
    if IsZhuangYuanScene() then
      if IsWindowVisible("BieYePetBar_Awake") then
        local list1, list2 = XMJX_GetListItem()
        XMJX_AddList(list1, 1)
        XMJX_AddList(list2, 2)
        Sleep(600)
        GetLuaValue("setmetatable(_G, {__index = BieYePetBar_Awake_Env});BieYePetBar_Awake_Promote_Click();")
        CloseAllWindow()
      else
        MoveToNPC("云巧巧", 89, 176, -1, nil, nil, nil, IsZhuangYuanScene)
        Sleep(500)
        DialogOptionClicked("珍兽血脉觉醒", 1, 1000)
      end
    else
      GoToZhuangYuan(2)
    end
    if -1 == tickOut then
      tickOut = GetTickCount()
    end
    if IsInDebugMsg("#{JYSL_160518_136}") then
      break
    end
    if GetTickCount() - tickOut > 120000 then
      PushColorMsg(m_script_name .. ":超时！")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
  GoOutZhuangYuan()
end

_SMain()
ScriptOnStop(m_script_name)
