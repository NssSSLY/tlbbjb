-- 行笔绘伏夏：由 dfz64.dll 字节码模块 活动/行笔绘伏夏.lua 静态还原
-- 模块 SHA256 c4539be645378113c38ea7f973857ac928ddae6fc6ebd81d642c4baef4f401cf；调用、参数、等待和循环按反汇编逐条保持。
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
