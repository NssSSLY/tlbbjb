-- 经验纳元暂停：由 dfz64.dll 字节码模块 功能/经验纳元暂停.lua 静态还原
-- 模块 SHA256 d70deb98a1b855cd32e4397b7a1ae2b8f64aaefca20d213b9d5cd6108b8d37d3；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "经验纳元暂停"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GoToSceneNPC("何所思", 258, 154, 2)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_02}", 1, 700)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_16}", 1, 700)
    Sleep(1000)
    DialogOptionClicked("#{JYQQ_250801_19}", 1, 700)
    Sleep(1000)
end
_SMain()
ScriptOnStop(m_script_name, true)
