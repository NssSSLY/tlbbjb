-- 倩心阁兑换：由 dfz64.dll 字节码模块 活动/倩心阁兑换.lua 静态还原
-- 模块 SHA256 7bff9e78a1c996e05590e43e3140abe3471bff5c4b0edfc5fb000f4ef8bed0fd；商店序号、点击与确认按反汇编保持；原程序“组合”页的物品列表改为任务设置；原规则开头的离队不执行；结束判断用完整的提示键 #{DHSD_20240522_25}（原规则第二处少了右括号）。
local m_script_name = "倩心阁兑换"
ScriptOnStart(m_script_name, true, true)
local szList = tostring((TaskConfig or {}).qianxin_items or "")
PushColorMsg(szList)
local tIndex = {
    ["兰若幽帘礼匣"] = 1, ["诗画录礼匣"] = 2, ["驱邪刃影礼匣"] = 3, ["3级秘银"] = 4, ["3级棉布"] = 5, ["觉灵珠"] = 6,
    ["四绘流光匣"] = 7, ["虹耀石"] = 8, ["缀梦灵石"] = 9, ["金蚕丝"] = 10, ["紫府星髓"] = 11,
}
local function dhOnload(dhIndex)
    DeleteDebugMsg("#{DHSD_20240522_29")
    DeleteDebugMsg("#{DHSD_20240522_25}")
    -- 闭环保护：原规则每 0.2 秒点一次兑换直到出现结束提示、没有上限；这里商店界面没开就停，每种最多 50 次。
    for _ = 1, 50 do
        if not IsWindowVisible("DaHuaQiXi_Shop") then
            PushColorMsg(m_script_name .. "：兑换界面没有打开，已停止")
            break
        end
        GetLuaValue(string.format([[
            setmetatable(_G, {__index = DaHuaQiXi_Shop_Env});
            DaHuaQiXi_Shop_Clicked(%d)
        ]], dhIndex))
        Sleep(200)
        GetLuaValue("setmetatable(_G, {__index = MessageBox_Self3_Env});MessageBox_Self3_OnOk()")
        if IsInDebugMsg("#{DHSD_20240522_29") or IsInDebugMsg("#{DHSD_20240522_25}") then break end
    end
end
function _SMain()
    -- 原规则先 Team:LeaveTeam() 离开队伍；本程序不自动离队，组队时传送可能失败。
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(77);")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = Qixi_HuaJuan_Env});Qixi_HuaJuan_ShopButton_Clicked();")
    Sleep(1000)
    for szName in string.gmatch(szList, "%S+") do
        local nIndex = tIndex[szName]
        if nIndex then dhOnload(nIndex) end
    end
end
_SMain()
ScriptOnStop(m_script_name, true)
