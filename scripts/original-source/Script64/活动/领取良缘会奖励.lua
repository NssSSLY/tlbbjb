-- 反编译自 dfz64.dll 内嵌字节码 00457a35（unluac 2025-12-23；仅供分析）
GetLuaValue("Clear_XSCRIPT();Set_XSCRIPT_Function_Name('GetTodayHuoYuePointGift');Set_XSCRIPT_ScriptID(892921);Set_XSCRIPT_ParamCount(0);Send_XSCRIPT()")
Sleep(100)
for i = 1, 5 do
  GetLuaValue(fmt("setmetatable(_G, {__index = Token_Shop_Env});Token_Shop_GetReward_Click(%d)", i))
  Sleep(100)
end
