-- 领取良缘会奖励：由 dfz64.dll 字节码模块 活动/领取良缘会奖励.lua 静态还原
-- 模块 SHA256 a72f7cf72b87a16ff953ccc56f9dc3ade8376e2c9026fd4d6427eeea2f1cb464；调用、参数、等待和次数按反汇编逐条保持。
GetLuaValue("Clear_XSCRIPT();Set_XSCRIPT_Function_Name('GetTodayHuoYuePointGift');Set_XSCRIPT_ScriptID(892921);Set_XSCRIPT_ParamCount(0);Send_XSCRIPT()")
Sleep(100)
for i = 1, 5 do
    GetLuaValue(string.format("setmetatable(_G, {__index = Token_Shop_Env});Token_Shop_GetReward_Click(%d)", i))
    Sleep(100)
end
