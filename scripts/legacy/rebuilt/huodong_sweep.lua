-- 活动扫荡：由 dfz64.dll 字节码模块 任务/活动扫荡.lua 静态还原
-- 模块 SHA256 2a0d1411614e2fa06d57503b5ccfbb1dd2aa29f38d670824006c586c5bb214ac；活动表读取、点数与次数判断、扫荡请求和 20 轮循环按反汇编保持；每轮之间加 0.5 秒间隔；开箱只用名字带“宝箱”的物品，同名多格只开第一格（批量使用框一次开完）；原规则最后的清包（删除物品）不做，出售与存仓依赖原程序配置，未接入。
local m_script_name = "活动扫荡"
ScriptOnStart(m_script_name, false, false)
local cfg = TaskConfig or {}
local bOpenBox = cfg.hdsd_openbox ~= false
function SaoDangHuoDong_xm()
    local nCount = HuoDongSweepCount()
    for i = 0, nCount - 1 do
        local Id, nSeckillNum1, nSeckillNum2, nSeckillNum3, SecKillNeedNum, nDone, nTotal, FubenName = HuoDongSweepEnum(i)
        local bSkip = false
        if Id == 1 or Id == 2 then
            bSkip = nSeckillNum1 < SecKillNeedNum
        elseif Id == 3 or Id == 4 then
            bSkip = nSeckillNum2 < SecKillNeedNum
        elseif Id == 5 or Id == 6 then
            bSkip = nSeckillNum3 < SecKillNeedNum
        end
        if not bSkip then
            PushColorMsg(FubenName .. "：" .. nDone .. "/" .. nTotal)
            if nTotal - nDone ~= 0 and nTotal ~= 0 then
                PushDebugMessage("扫荡活动：" .. FubenName)
                GetLuaValue(string.format([[
                    Clear_XSCRIPT();
                    Set_XSCRIPT_Function_Name("OnFuBenSecKill");
                    Set_XSCRIPT_ScriptID(100003);
                    Set_XSCRIPT_Parameter(0,%d);
                    Set_XSCRIPT_ParamCount(1);
                    Send_XSCRIPT();
                ]], Id))
            end
        end
    end
end
function SDHD_OnStart()
    if not IsWindowVisible("SweepAll") then
        GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_OpenSecKillBox()")
        Sleep(1000)
        GetLuaValue("setmetatable(_G, {__index = SweepAll_Env});SweepAll_Tab_2_OnClick();")
        Sleep(1000)
    end
    for i = 1, 20 do
        SaoDangHuoDong_xm()
        Sleep(500)
    end
    if bOpenBox then
        for _, v in ipairs(ItemTotals("bag", "宝箱")) do
            PushColorMsg(v.name)
            UseBoxItem(v.name)
            Sleep(300)
            GetLuaValue("setmetatable(_G, {__index = Item_MultiUse_Env});Item_MultiUse_BuyMulti_Clicked();")
        end
    end
    -- 原规则此处清包、出售、存仓各两遍：清包会删除物品，不做；出售与存仓依赖原程序配置，未接入。
    PushDebugMessage(m_script_name .. "：清包、出售、存仓未接入")
end
SDHD_OnStart()
ScriptOnStop(m_script_name)
