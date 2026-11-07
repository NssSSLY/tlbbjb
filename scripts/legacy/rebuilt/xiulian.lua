-- 点修炼：由 dfz64.dll 字节码模块 功能/点修炼.lua 静态还原
-- 模块 SHA256 0f51c7b6d0cd739916a37cf0cd30c3f741e1144d6c4d81eb5a759d0e9b5c3082；计划解析（第N本-第M卷-到K重/点满）、秘籍序号换算、经验/功力/境界判断、先升级后提境界的顺序与 2 分钟超时按反汇编保持；原程序设置页的计划与“使用功力丹”改为任务设置；扫地神僧的 NPC 编号原程序靠扫描场景对象取得、取不到时用 171，本程序不扫描，固定用 171；原规则一轮没有可做的事也会等到超时，这里直接结束；剩余功力丹移回锦囊未接入。
local m_script_name = "点修炼"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local bGld = cfg.zdxl_gld == true
local nNpc = 171
local function ParseList()
    local t = {}
    for text_ in tostring(cfg.zdxl_list or ""):gmatch("%S+") do
        local p = {}
        for piece in (text_ .. "-"):gmatch("(.-)%-") do table.insert(p, piece) end
        if #p == 3 then
            local nBook = tonumber((p[1]:gsub("第", ""):gsub("本", ""))) or -1
            local nPage = tonumber((p[2]:gsub("第", ""):gsub("卷", ""))) or -1
            local szMax = p[3]:gsub("到", ""):gsub("重", "")
            if szMax == "点满" then szMax = 11 end
            local nMax = tonumber(szMax) or -1
            if nBook > 0 and nPage > 0 and nMax > 0 then
                if nBook == 1 and nPage > 5 then
                    PushColorMsg("第一本宝典没有第六卷,忽略！")
                elseif nBook == 3 and nPage > 4 then
                    PushColorMsg("第三本宝典只有四卷,忽略！")
                else
                    table.insert(t, { book = nBook, page = nPage, max_jingjie = nMax })
                end
            end
        end
    end
    return t
end
local function GetIndex(aBook, aPage)
    if aBook == 1 then return aPage - 1 elseif aBook == 2 then return aPage + 4 elseif aBook == 3 then return aPage + 10 end
    return -1
end
local function NeedPower(aJingJie)
    if aJingJie <= 3 then return 33 elseif aJingJie <= 6 then return 50 end
    return 100
end
local function XiuLian(szFunc, nIndex)
    GetLuaValue(string.format([[Clear_XSCRIPT();Set_XSCRIPT_Function_Name("%s");Set_XSCRIPT_ScriptID(2099);
        Set_XSCRIPT_Parameter(0,%d);Set_XSCRIPT_Parameter(1,%d);Set_XSCRIPT_ParamCount(2);Send_XSCRIPT();]], szFunc, nNpc, nIndex))
end
local function TakeGld()
    if Bag:GetItemCount("功力丹") > 0 then return end
    if TempBank2Bag("功力丹") == false then Bank_GetItem("功力丹", 1) end
end
local function UseGld()
    if not bGld or IsInDebugMsg("#{XLGLZHF_20091021_02}") then return false end
    TakeGld()
    if Bag:GetItemCount("功力丹") == 0 then return false end
    Dismount(500)
    Bag:UseItemByName("功力丹")
    Sleep(1000)
    MessageBox_Self_Text_Clicked("功力丹", 800)
    return true
end
function _SMain()
    local tList = ParseList()
    if #tList == 0 then
        PushColorMsg(m_script_name .. ":没有解析到正确的参数!")
        return
    end
    local nStart = -1
    if bGld then TakeGld() end
    DeleteDebugMsg("#{XLGLZHF_20091021_02}")
    while true do
        if Player:GetDataInt("POWER") < 33 then
            if not UseGld() then break end
            if nStart == -1 then nStart = GetTickCount() end
        else
            GoToSceneNPC("扫地神僧", 241, 31, 2)
            if nStart == -1 then nStart = GetTickCount() end
            Sleep(600)
            QuestFrameOptionClicked_Item("#{XL_XML_35}", 1, 700)
            local nExp = Player:GetDataInt("EXP") + Player:GetDataInt("HUILIUEXP")
            local bDone = false
            for _, v in ipairs(tList) do
                local nIndex = GetIndex(v.book, v.page)
                local nJingJie, nLevel, nMaxLevel, _, nNeedExp = XiuLianInfo(nIndex)
                local nNeedPower = NeedPower(nJingJie)
                local nPower = Player:GetDataInt("POWER")
                if nNeedExp <= nExp then
                    if v.max_jingjie <= nJingJie or nLevel == -1 then
                        PushColorMsg(string.format(m_script_name .. ":第%d本,第%d卷不需要点", v.book, v.page))
                    elseif nLevel == nMaxLevel then
                        DeleteDebugMsg("#{XL_090707_11}")
                        DeleteDebugMsg("#{XL_090707_65}")
                        PushColorMsg(string.format(m_script_name .. ":第%d本,第%d卷需要提升境界", v.book, v.page))
                        XiuLian("AskXiuLianAdvanceJingJie", nIndex)
                        Sleep(2000)
                        if IsInDebugMsg("#{XL_090707_11}") or IsInDebugMsg("#{XL_090707_65}") then
                            PushColorMsg(string.format(m_script_name .. ":第%d本,第%d卷无法提升境界", v.book, v.page))
                        else
                            bDone = true
                            break
                        end
                    elseif nPower < nNeedPower then
                        if UseGld() then
                            bDone = true
                            break
                        end
                        PushColorMsg(string.format(m_script_name .. ":第%d本,第%d卷功力不足", v.book, v.page))
                    else
                        XiuLian("AskXiuLianLevelUp", nIndex)
                        Sleep(800)
                        MessageBox_Self_OK_Clicked()
                        Sleep(800)
                        bDone = true
                        break
                    end
                else
                    PushColorMsg(string.format(m_script_name .. ":第%d本,第%d卷所需经验不足,点下一本", v.book, v.page))
                end
            end
            if not bDone then break end
        end
        Sleep(700)
        if nStart ~= -1 and GetTickCount() - nStart > 120000 then
            PushColorMsg(m_script_name .. ":超时5分钟")
            break
        end
        DebugStr(m_script_name)
    end
    Bag_Move2TempBank("功力丹")
end
_SMain()
