-- 庄园血脉觉醒：由 dfz64.dll 字节码模块 帮庄/庄园血脉觉醒.lua 静态还原
-- 模块 SHA256 171e904188ded55a9133ef4c70415d093248f1bd1c7a46654cf5d20d0a04b5af；列表读取、名字与状态判断、放入与觉醒顺序、超时与结束提示按反汇编保持；原程序设置页的珍兽名称改为任务设置；原程序进庄园要扫描场景对象找庄园管事，本程序不扫描，需要先手动进入庄园。
local m_script_name = "庄园血脉觉醒"
ScriptOnStart(m_script_name, false, false, false)
local cfg = TaskConfig or {}
local all_name = " " .. (tostring(cfg.zy_pets or ""):gsub("%s+", " ")) .. " "
local function SplitList(aText)
    local t = {}
    for piece in aText:gmatch("%S+") do
        local nIndex, szText = piece:match("^(%d+)&(.+)$")
        if nIndex and tonumber(nIndex) then
            table.insert(t, { index = tonumber(nIndex), text = szText })
        end
    end
    return t
end
function XMJX_GetListItem()
    local strData1, strData2 = AwakeRead()
    return SplitList(strData1), SplitList(strData2)
end
function XMJX_GetRealName(aText)
    local _, _, szName, szState = string.find(aText, "(.+)%?(.+)")
    return szName or "", szState or ""
end
function XMJX_AddList(aList, aWhere)
    for i = 1, #aList do
        local v = aList[i]
        local szName, szState = XMJX_GetRealName(v.text)
        if string.find(all_name, " " .. szName .. " ", 1, true) then
            if not string.find(szState, "无法觉醒", 1, true) and not string.find(szState, "疲劳", 1, true)
                and not string.find(szState, "满阶满级", 1, true) then
                PushDebugMessage(szName)
                AwakeSelect(aWhere, v.index - 1)
                Sleep(1000)
                AwakeInput(aWhere)
                Sleep(600)
            else
                DebugStr(szName .. ":无法觉醒", 2)
            end
        end
    end
end
function _SMain()
    DeleteDebugMsg("#{JYSL_160518_136}")
    CloseAllWindow()
    local nStart = -1
    while true do
        if IsZhuangYuanScene() then
            if IsWindowVisible("BieYePetBar_Awake") then
                local tList1, tList2 = XMJX_GetListItem()
                XMJX_AddList(tList1, 1)
                XMJX_AddList(tList2, 2)
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
        if nStart == -1 then nStart = GetTickCount() end
        if IsInDebugMsg("#{JYSL_160518_136}") then break end
        if GetTickCount() - nStart > 120000 then
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
ScriptOnStop(m_script_name, false)
