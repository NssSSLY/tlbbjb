-- 合成武魂：由 dfz64.dll 字节码模块 功能/合成武魂.lua 静态还原
-- 模块 SHA256 5344f4a58f43a5c6d7a7b1b44d989a97aabb6356a43bbea690ee11bcf2f1dbd3；挑选规则、绑定模式、补材料顺序与 300 秒上限按反汇编保持；道具栏的绑定状态可以直接读，四种模式都已实现；合成请求在发送前于游戏内再次核对两个格子里确实是御瑶盘/琉璃焰；原规则开头和结尾的清包、整理、存仓未接入。
local m_script_name = "合成武魂"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local hc_level = math.floor(tonumber(cfg.wuhun_level) or 2)
local hc_mode = math.floor(tonumber(cfg.wuhun_mode) or 1)
if hc_mode < 1 or hc_mode > 4 then hc_mode = 1 end
local szNames = "御瑶盘 琉璃焰"
local function SortByLevel(t) table.sort(t, function(a, b) return a.ext_level < b.ext_level end) return t end
-- 返回 全部 / 绑定 / 非绑定 三组，只含额外等级低于设置等级的。
local function Lists()
    local all, bind, unbind = {}, {}, {}
    for _, v in ipairs(WuhunItems()) do
        if v.ext_level < hc_level then
            all[#all + 1] = v
            if v.bind == 1 then bind[#bind + 1] = v else unbind[#unbind + 1] = v end
        end
    end
    return SortByLevel(all), SortByLevel(bind), SortByLevel(unbind)
end
local function FirstPair(t)
    for i = 1, #t do
        if i < #t and t[i].ext_level == t[i + 1].ext_level then return t[i].ext_level end
    end
end
-- 1 绑定优先 / 2 只绑定 / 3 只非绑定 / 4 混合；返回 等级, 绑定码（2 绑定，1 非绑定，0 不区分）
local function Pick()
    local all, bind, unbind = Lists()
    local lv
    if hc_mode == 1 then
        lv = FirstPair(bind); if lv then return lv, 2 end
        lv = FirstPair(unbind); if lv then return lv, 1 end
    elseif hc_mode == 2 then
        lv = FirstPair(bind); if lv then return lv, 2 end
    elseif hc_mode == 3 then
        lv = FirstPair(unbind); if lv then return lv, 1 end
    else
        lv = FirstPair(all); if lv then return lv, 0 end
    end
    return -1, -1
end
local function Get(aLevel, aBindState)
    for nTry = 1, 2 do
        local all, bind, unbind = Lists()
        local t = all
        if aBindState == 1 then t = unbind elseif aBindState == 2 then t = bind end
        local tHit = {}
        for _, v in ipairs(t) do if v.ext_level == aLevel then tHit[#tHit + 1] = v end end
        if #tHit >= 2 then return tHit[1], tHit[2] end
        if nTry == 1 then TempBank2Bag(szNames, 0) else Bank_GetItem(szNames, -1, 0) end
        Sleep(600)
    end
end
local function BankHasWuhun()
    for _, name in ipairs({ "御瑶盘", "琉璃焰" }) do
        for _, v in ipairs(ItemTotals("bank", name)) do if v.num > 0 then return true end end
    end
    return false
end
function _SMain()
    if hc_level < 2 then hc_level = 2 elseif hc_level > 7 then hc_level = 7 end
    local nStart = GetTickCount()
    while true do
        local nLevel, nBind = Pick()
        if nLevel > 0 then
            local a, b = Get(nLevel, nBind)
            if a and b then
                WuhunCompound(a.index, b.index)
                Sleep(1000)
            end
        else
            PushColorMsg(m_script_name .. ":背包没有可合成的武魂")
            if TempBank2Bag(szNames, 0) == false then
                if BankHasWuhun() then
                    if Bank_GetItem(szNames, -1, 0) == 0 then
                        PushColorMsg(m_script_name .. ":已没有需要合成的武魂")
                        break
                    end
                else
                    PushColorMsg(m_script_name .. ":已没有需要合成的武魂!")
                    break
                end
            end
            Sleep(2000)
        end
        if GetTickCount() - nStart > 300000 then
            PushColorMsg(m_script_name .. ":超时")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
