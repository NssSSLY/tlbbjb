-- 经验纳元结束：由 dfz64.dll 字节码模块 功能/经验纳元结束.lua 静态还原
-- 模块 SHA256 75d11f3fbe8ba4c3e162d63f4e5692fcdcaf82f86f3f5d2bdfcb5c5cf2fa89ee；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "经验纳元结束"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GoToSceneNPC("何所思", 258, 154, 2)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_02}", 1, 700)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_17}", 1, 700)
    Sleep(1000)
end
_SMain()
ScriptOnStop(m_script_name, true)
