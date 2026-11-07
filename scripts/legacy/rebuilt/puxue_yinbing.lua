-- 蒲雪饮冰：由 dfz64.dll 字节码模块 活动/蒲雪饮冰.lua 静态还原
-- 模块 SHA256 7b440a4fd984fe11a40f30c9bf79d24e88bf0e748b9e19b232ec2df14abb89fd；调用、参数、等待和循环按反汇编逐条保持。原规则的激活/激活提示键缺少右括号，只能按原文匹配，通常按 10 次上限结束。
local m_script_name = "蒲雪饮冰"
ScriptOnStart(m_script_name, false, false)
local function CanActivate() return UiButtonEnabled(0) end
local function CanPray() return UiButtonEnabled(1) end
function _SMain()
    GetLuaValue("setmetatable(_G, {__index = XiGua_Shop_Gift_Env});XiGua_Shop_Gift_GetClick()")
    DeleteDebugMsg("#{ZXJQ_120516_60")
    for i = 1, 10 do
        if IsWindowVisible("ZhongXiaItem") == false then
            GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env}); XiGua_Guide_Clicked(1)")
            Sleep(600)
        end
        if CanActivate() == false then break end
        GetLuaValue("setmetatable(_G, {__index = ZhongXiaItem_Env});ZhongXia_OnActivate()")
        Sleep(500)
        if IsInDebugMsg("#{ZXJQ_120516_60") then break end
    end
    for i = 1, 8 do
        if IsWindowVisible("ZhongXiaItem") then
            if CanPray() then
                GoToScene(367, 167, 1)
                if IsWindowVisible("ZhongXiaItem") == false then
                    GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env}); XiGua_Guide_Clicked(1)")
                    Sleep(1000)
                end
                Dismount()
                GetLuaValue("setmetatable(_G, {__index = ZhongXiaItem_Env});ZhongXia_OnPray()")
            else
                GoToScene(367, 167, 1)
                Dismount()
                GetLuaValue("setmetatable(_G, {__index = ZhongXiaItem_Env});ZhongXia_OnPray()")
            end
        else
            GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env}); XiGua_Guide_Clicked(1)")
        end
        Sleep(2000)
    end
    CloseWindow("ZhongXiaItem")
    GetLuaValue("setmetatable(_G, {__index = XiGua_Shop_Gift_Env});XiGua_Shop_Gift_GetClick()")
    Sleep(1000)
    Bag:UseItemByName_click("萌宠戏夏礼包", 1000)
    Bag:UseItemByName_click("清荷礼包", 1000)
end
_SMain()
