-- 莲池相宝：由 dfz64.dll 字节码模块 活动/莲池相宝.lua 静态还原
-- 模块 SHA256 2f600a87d561afb1e717386fd6d35253ea52bcfb3fcf031585824debbaed1296；调用、参数、等待和循环按反汇编逐条保持。
function _SMain()
    GetLuaValue("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_HuoYueClicked();")
    for i = 1, 5 do
        GetLuaValue(string.format("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_CostPrize1Clicked(%d)", i))
        Sleep(1000)
    end
    for i = 1, 5 do
        GetLuaValue(string.format("setmetatable(_G, {__index = ErTongJieDaiBi_Env});ErTongJieDaiBi_CostPrize2Clicked(%d)", i))
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
end
_SMain()
