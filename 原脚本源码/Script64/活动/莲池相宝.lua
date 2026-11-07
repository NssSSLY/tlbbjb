-- 反编译自 dfz64.dll 内嵌字节码 0043ac4d（unluac 2025-12-23；仅供分析）
GetLuaValue("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_HuoYueClicked();")
for i = 1, 5 do
  local strText = fmt("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_CostPrize1Clicked(%d)", i)
  GetLuaValue(strText)
  Sleep(1000)
end
for i = 1, 5 do
  local strText = fmt("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_CostPrize2Clicked(%d)", i)
  GetLuaValue(strText)
  Sleep(1000)
end
GetLuaValue("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_HuoYueClicked();")
Sleep(500)
GetLuaValue("setmetatable(_G, {__index = Ertongjie_Guide_Env}); Ertongjie_Guide_Clicked(4);")
Sleep(500)
GetLuaValue("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_DuiHuanClicked(1);")
Sleep(500)
GetLuaValue("setmetatable(_G, {__index = ErTongJieDaiBiPop_Env});ErTongJieDaiBiPop_DuiHuanClicked();")
Sleep(500)
WuhunQuest_Text_Clicked("", 1000)
