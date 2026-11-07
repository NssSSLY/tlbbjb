-- 霸王别姬颂千年：由 dfz64.dll 字节码模块 活动/霸王别姬颂千年.lua 静态还原
-- 模块 SHA256 a026abf72ab121778c30fd224e31ce09704b5bc05e6e78553e77645e0143c405；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "霸王别姬颂千年"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GetLuaValue("setmetatable(_G, {__index = QiXi_Guide_2026_Env});QiXi_Guide_2026_ActionClicked(3);")
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = XiQuLianDong_Env});XiQuLianDong_GetGiftClicked();")
end
_SMain()
ScriptOnStop(m_script_name, true)
