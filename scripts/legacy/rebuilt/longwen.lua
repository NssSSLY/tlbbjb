-- 合成龙纹：由 dfz64.dll 字节码模块 功能/合成龙纹.lua 静态还原
-- 模块 SHA256 81f42eceff683965f5b1eee8f5c2f8363b0f50aaf2ae5cac10677fe4df68e7b0；取下/装回龙纹、主龙纹与材料的选择（等级、绑定、锁定）、铸纹玉、先锦囊后仓库各一次与 10 分钟超时按反汇编保持；原程序设置页的两个绑定选项改为任务设置；取下龙纹这一步只有在任务设置里允许时才做；开头清包（删除物品）未接入；锦囊和仓库取物不区分绑定。
local m_script_name = "合成龙纹"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local bind_lw, bind_stuff = cfg.lw_bind_lw == true, cfg.lw_bind_stuff == true
local tempBag, bank = true, true
local function OpenSelfEquip()
    if not IsWindowVisible("SelfEquip") then
        GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
        Sleep(300)
    end
end
local function Unequip()
    for _ = 1, 5 do
        if LwUnequip() then return true end
        OpenSelfEquip()
        Sleep(1000)
    end
    return false
end
local function Sorted(list, kind)
    local t = {}
    for _, v in ipairs(list) do if v.kind == kind then table.insert(t, v) end end
    table.sort(t, function(a, b) return a.level > b.level end)
    return t
end
local function Step()
    if not Unequip() then
        PushColorMsg(m_script_name .. ":取下龙纹失败！")
        return false
    end
    local _, tAll = LwScan()
    local tLw, tYl = Sorted(tAll, 1), Sorted(tAll, 2)
    local tMat = {}
    for i = 2, #tLw do
        if tLw[i].level == 1 and (not bind_lw or tLw[i].bind == 1) then table.insert(tMat, tLw[i]) end
    end
    for _, v in ipairs(tYl) do
        if not bind_lw or v.bind == 1 then table.insert(tMat, v) end
    end
    if #tMat < 1 then
        PushDebugMessage(m_script_name .. ":龙纹材料数量不足,请注意龙纹绑定属性")
        if tempBag then
            TempBank2Bag("龙纹 龙纹玉灵")
            tempBag = false
            Sleep(1000)
            return true
        end
        if bank then
            Bank_GetItem("龙纹 龙纹玉灵", -1)
            Bank_GetItem(" 铸纹血玉 铸纹精玉 铸纹龙玉 ", -1)
            bank = false
            Sleep(1000)
            return true
        end
        return false
    end
    if #tLw == 0 then
        PushDebugMessage("合成龙纹：背包没有龙纹")
        return false
    end
    local tMain = tLw[1]
    if tMain.level < 2 then
        PushDebugMessage(m_script_name .. "主龙纹等级过低")
        return false
    end
    if tMain.level >= 100 then
        PushDebugMessage(m_script_name .. "主龙纹已满级")
        return false
    end
    TempBank2Bag(" 铸纹血玉 铸纹精玉 铸纹龙玉 ")
    local nStuff = -1
    for _, v in ipairs(tAll) do
        if v.kind == 3 and (not bind_stuff or v.bind == 1) then
            nStuff = v.index
            break
        end
    end
    LwCombine(tMain.index, tMat[1].index, nStuff)
    return true
end
function _SMain()
    if cfg.lw_allow ~= true then
        PushColorMsg(m_script_name .. "：合成前要取下装备栏的龙纹，未在设置里允许，已停止")
        return
    end
    local nStart = -1
    while true do
        GoToSceneNPC("焦鹰", 125, 201, 850)
        if not IsWindowVisible("LongwenLevelUp") then QuestFrameOptionClicked_Item("#{LW_KVK_110704_01}", 1, 700) end
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 600000 then
            PushColorMsg("合成龙纹:超时！")
            break
        end
        if not Step() then break end
        Sleep(100)
        DebugStr(m_script_name)
    end
    CloseWindow("LongwenLevelUp")
    for _ = 1, 5 do
        local bEquipped, tAll = LwScan()
        if bEquipped then break end
        local tLw = Sorted(tAll, 1)
        if #tLw > 0 then
            LwEquip(tLw[1].index)
            Sleep(300)
        end
        Sleep(600)
    end
    if IsWindowVisible("SelfEquip") then
        GetLuaValue("setmetatable(_G, { __index = MainMenuBar_Env });MainMenuBar_SelfEquip_Clicked();")
    end
end
_SMain()
ScriptOnStop(m_script_name)
