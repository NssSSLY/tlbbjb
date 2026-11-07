-- 除邪惩恶领取：由 dfz64.dll 字节码模块 功能/除邪惩恶领取.lua 静态还原
-- 模块 SHA256 209d4e54e9beefbff0dd80dbebadacc66608c9a4765eba395e99b3fb37c33712；NPC、坐标、选项和等待按反汇编逐条保持。
function _SMain()
    GoToSceneNPC("姚楚娥", 216, 139, 2)
    Sleep(1000)
    DialogOptionClicked("#{CJJY_250806_02}", 1, 700)
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = ExorciseEvil_Env});ExorciseEvil_LevelBox_Clicked();")
end
_SMain()
