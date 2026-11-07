-- 庄园养鱼：由 dfz64.dll 字节码模块 帮庄/庄园养鱼.lua 静态还原
-- 模块 SHA256 550ab7a3503079e43896f3016c4f9f6b23da616e28e4d4e310fae65603f78996；NPC、状态判断、播撒界面操作与结束条件按反汇编保持；原程序设置页的“雇佣园丁”“元宝播撒”“成熟时间”“播撒类型”改为任务设置；
-- 原程序进庄园要扫描场景对象找庄园管事，本程序不扫描，需要先手动进入庄园；成熟时间不写原程序配置文件，只记日志；离开庄园最多尝试 10 次。
local m_script_name = "庄园养鱼"
ScriptOnStart(m_script_name, false, false, false)
local cfg = TaskConfig or {}
local guyong = cfg.zy_hire == true
local yuanbao = cfg.zy_yuanbao == true
local option = { ["早熟草鱼"] = 2, ["早熟鲤鱼"] = 3, ["早熟三文鱼"] = 4, ["早熟金枪鱼"] = 5, ["早熟罗非鱼"] = 6, ["中熟草鱼"] = 8, ["中熟鲤鱼"] = 9, ["中熟三文鱼"] = 10, ["中熟金枪鱼"] = 11, ["中熟罗非鱼"] = 12, ["晚熟草鱼"] = 14, ["晚熟鲤鱼"] = 15, ["晚熟三文鱼"] = 16, ["晚熟金枪鱼"] = 17, ["晚熟罗非鱼"] = 18 }
local list_index = nil
local tPlot = {
    { slot = 4, name = "何翁", x = 116, y = 214 }
}
local function GetState()
    GetLuaValue("setmetatable(_G, {__index = BieYe_Mini_Env});BieYe_Mini_Sub(3)")
    Sleep(1000)
    local t = {}
    for i, p in ipairs(tPlot) do
        local nState, nTime = ZhuangYuanProduct(p.slot)
        t[i] = { state = nState, time = nTime }
    end
    return t
end
local function CheckYuanDing()
    ZhuangYuanAsk()
    Sleep(1000)
    local nFree, nHire = ZhuangYuanGardeners()
    PushDebugMessage("园丁空闲：" .. nFree .. ",雇佣空闲 " .. nHire)
    if nFree == 0 and nHire == 0 then
        PushColorMsg(m_script_name .. ":已经没有园丁空闲！")
        return false
    end
    if nFree == 0 and not guyong then
        PushColorMsg(m_script_name .. ":已经没有免费园丁空闲,您未允许雇佣！")
        return false
    end
    return true
end
local function Click()
    if not IsWindowVisible("BieYePlanting") then return end
    if yuanbao then
        GetLuaValue("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_SwitchPage(2);")
    else
        GetLuaValue("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_SwitchPage(1);")
    end
    Sleep(1000)
    GetLuaValue(string.format("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_ItemDataChanged(%d)", list_index))
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_Buttons_Clicked();")
    Sleep(1000)
    if IsWindowVisible("WuhunQuest") then
        if yuanbao then
            WuhunQuest_Text_Clicked("元宝")
            Sleep(1000)
        end
        if guyong then
            WuhunQuest_Text_Clicked("均有劳务在身")
            Sleep(1000)
        end
        CloseWindow("WuhunQuest")
    end
end
local function Action()
    CloseAllWindow()
    local tState = GetState()
    for i, p in ipairs(tPlot) do
        if tState[i].state == 3 or tState[i].state == 4 then
            MoveToNPC(p.name, p.x, p.y, -1, nil, nil, IsZhuangYuanScene)
            Sleep(500)
            DialogOptionClicked("收获食材", 0, 800)
            return true
        end
    end
    local nGrowing = 0
    for i, p in ipairs(tPlot) do
        if tState[i].state == 2 then
            -- 原规则把成熟时间写进原程序的角色配置文件；本程序只记日志。
            PushColorMsg("庄园：" .. p.name .. " 生长中，剩余 " .. tState[i].time)
            nGrowing = nGrowing + 1
        end
    end
    if CheckYuanDing() == false then return false end
    for i, p in ipairs(tPlot) do
        if tState[i].state == 0 or tState[i].state == 1 then
            MoveToNPC(p.name, p.x, p.y, -1, nil, nil, IsZhuangYuanScene)
            Sleep(500)
            DialogOptionClicked("播撒鱼苗", 0, 1000)
            Click()
            return true
        end
    end
    if nGrowing == #tPlot then
        PushColorMsg(m_script_name .. ":完成")
        return false
    end
    DebugStr("养鱼中", 2)
    return true
end
function _SMain()
    list_index = option[tostring(cfg.zy_level or "") .. tostring(cfg.zy_kind or "")]
    if list_index == nil then
        PushColorMsg(m_script_name .. ":设置有误")
        return
    end
    -- 闭环保护：本轮状态与上一轮相同计为没有进展，连续 6 轮就停止并写明原因（原规则没有上限）。
    local guard = NoProgress(m_script_name, 6)
    while true do
        if IsZhuangYuanScene() then
            if Action() == false then break end
            local szState = ""
            for _, p in ipairs(tPlot) do szState = szState .. ZhuangYuanProduct(p.slot) .. "," end
            guard(szState)
        else
            GoToZhuangYuan(2)
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
    GoOutZhuangYuan()
end
_SMain()
ScriptOnStop(m_script_name)
