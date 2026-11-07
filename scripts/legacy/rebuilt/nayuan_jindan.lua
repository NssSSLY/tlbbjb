-- 提取纳元金丹：由 dfz64.dll 字节码模块 功能/提取纳元金丹.lua 静态还原
-- 模块 SHA256 4e345d4395def469df76bc6b9b74bbbb9a20bc03f43257ff1e3e5136dd8260c5；NPC、坐标、选项和等待按反汇编逐条保持。
function _SMain()
    GoToSceneNPC("何所思", 258, 154, 2)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_03}", 1, 700)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_33}", 1, 700)
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
end
_SMain()
