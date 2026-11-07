-- 帮会宣战点火：由 dfz64.dll 字节码模块 常用/帮会宣战点火.lua 静态还原
-- 模块 SHA256 d9097614c374944c4c743b92560787fbe33b898d9109d0634087862a6ba20f57；调用、参数、等待和循环按反汇编逐条保持。原程序“组合”页的帮会 ID 列表改为任务设置。
local szConfig = tostring((TaskConfig or {}).war_guild_ids or "")
local tGuild = {}
local function CheckOnce()
    CityEnemyAsk()
    Sleep(1000)
    for i = 1, #tGuild do
        if CityEnemyHas(tGuild[i]) == false then
            PushDebugMessage("自动宣战帮会ID：" .. tGuild[i])
            CityOpenAddEnemy(tGuild[i])
            Sleep(3000)
            break
        end
    end
end
function _SMain()
    for szId in string.gmatch(szConfig, "%S+") do
        local nId = tonumber(szId)
        if nId and nId >= 0 then table.insert(tGuild, nId) end
    end
    if #tGuild > 0 then
        while true do
            CheckOnce()
            Sleep(3000)
            DebugStr("帮会宣战点火")
        end
    else
        PushDebugMessage("未设置宣战帮会ID")
    end
end
_SMain()
