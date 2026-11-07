-- 经验纳元领取：由 dfz64.dll 字节码模块 功能/经验纳元领取.lua 静态还原
-- 模块 SHA256 008d619b2099515474ab63a34d5f8c747c44cb07ce8bcb371f4c0a668510f67c；NPC、坐标、选项和等待按反汇编逐条保持。
function _SMain()
    GoToSceneNPC("何所思", 258, 154, 2)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_02}", 1, 700)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_15}", 1, 700)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_19}", 1, 700)
    Sleep(1000)
end
_SMain()
