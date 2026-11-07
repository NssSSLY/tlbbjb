-- 反编译自 dfz64.dll 内嵌字节码 004441ef（unluac 2025-12-23；仅供分析）
GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env});XiGua_Guide_Clicked(4);")
Sleep(1000)
for i = 1, 3 do
  GetLuaValue("setmetatable(_G, {__index = XiGuaJie_Activity_Env});XiGuaJie_Activity_Start_Clicked()")
  Sleep(1000)
end
for i = 1, 5 do
  GetLuaValue("setmetatable(_G, {__index = XiGuaJie_Activity_Env});XiGuaJie_Activity_GetLichengReward_Clicked(" .. tostring(i) .. ")")
  Sleep(1000)
end
for i = 1, 3 do
  GetLuaValue("setmetatable(_G, {__index = XiGuaJie_Activity_Env});XiGuaJie_Activity_GetReward_Clicked(" .. tostring(i) .. ")")
  Sleep(1000)
end
CloseAllWindow()
Sleep(1000)
