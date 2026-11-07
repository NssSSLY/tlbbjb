-- 山河万里行：由 dfz64.dll 字节码模块 活动/山河万里行.lua 静态还原
-- 模块 SHA256 a2a42a749e39804e02d9e85556fdebe140c96e30c38e1b87428c233e32964ff7；调用、参数、等待和循环按反汇编逐条保持。读不到坐标时停止，不再像原规则那样带着空坐标去寻路。
local m_script_name = "山河万里行"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(60);")
    Sleep(1000)
    for i = 1, 4 do
        GetLuaValue(string.format("setmetatable(_G, {__index = ShuangYe_Env});ShuangYe_Button_Clicked(%d)", i))
        Sleep(500)
        GetLuaValue(string.format("setmetatable(_G, {__index = ShuangYe_Env});ShuangYe_Reward_Clicked(%d)", i))
        Sleep(500)
    end
    GetLuaValue("setmetatable(_G, {__index = ShuangYe_Env});ShuangYe_UseQiufengyin_Clicked()")
    Sleep(1000)
    local szText = GetNPCEventList_Item(0)
    local a, b, c = szText:match("%*[%c]*(%d+)%*[%c]*(%d+)%*[%c]*(%d+)")
    a, b, c = tonumber(a), tonumber(b), tonumber(c)
    if not (a and b and c) then
        PushDebugMessage(m_script_name .. "：没有读到目标坐标")
        return
    end
    PushDebugMessage(string.format("游冶，抒怀:%d,%d,%d", a, b, c))
    MoveTo(a, b, c)
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = Frost_Env});Frost_ButtonClick(3);")
end
PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
