-- 豪气满江湖：由 dfz64.dll 字节码模块 活动/豪气满江湖.lua 静态还原
-- 模块 SHA256 7f3245fdc909929fff6f3c3e78acaab3fbbee9957ff71a1760a785ba24b76a3c；调用、参数、等待和循环按反汇编逐条保持。原规则每档固定买 1 个，这里改为任务设置（默认 1，设 0 不买）。
local m_script_name = "豪气满江湖"
ScriptOnStart(m_script_name, true, true)
local nBuy = math.floor(tonumber((TaskConfig or {}).haoqi_buy) or 1)
local nBuy1, nBuy2, nBuy3 = nBuy, nBuy, nBuy
function _SMain()
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(70);")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});Newserver_Hongbao_Tab_Click(1)")
    Sleep(1000)
    local szLingQu = [[
        Clear_XSCRIPT()
            Set_XSCRIPT_Function_Name( "LingQu" );
            Set_XSCRIPT_ScriptID( 501016 );
            Set_XSCRIPT_Parameter( 0, %d );
            Set_XSCRIPT_ParamCount( 1 );
        Send_XSCRIPT()
    ]]
    for i = 1, 23 do
        GetLuaValue(string.format(szLingQu, i))
        Sleep(200)
    end
    GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});Newserver_Hongbao_Tab_Click(2)")
    local szBuy = [[
        Clear_XSCRIPT()
            Set_XSCRIPT_Function_Name( "Buy" );
            Set_XSCRIPT_ScriptID( 501016 );
            Set_XSCRIPT_Parameter( 0, %d );
            Set_XSCRIPT_Parameter( 1, %d );
            Set_XSCRIPT_ParamCount( 2 );
        Send_XSCRIPT()
    ]]
    if nBuy1 > 0 then GetLuaValue(string.format(szBuy, 1, nBuy1)); Sleep(1000) end
    if nBuy2 > 0 then GetLuaValue(string.format(szBuy, 2, nBuy2)); Sleep(1000) end
    if nBuy3 > 0 then GetLuaValue(string.format(szBuy, 3, nBuy3)); Sleep(1000) end
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});Newserver_Hongbao_Tab_Click(3)")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});NewServerHongbaoBossReward()")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(70);")
    Sleep(1000)
    for _, szItem in ipairs({ "豪气红包", "侠情红包·武魂", "侠义红包", "侠情红包·令牌", "初级灵草礼盒" }) do
        for i = 1, Bag:GetItemCount(szItem) do
            Bag:UseItemByName(szItem)
            Sleep(200)
        end
    end
    Sleep(3000)
end
_SMain()
ScriptOnStop(m_script_name, true)
