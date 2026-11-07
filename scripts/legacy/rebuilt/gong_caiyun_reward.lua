-- 龚彩云领奖：由 dfz64.dll 字节码模块 其他/龚彩云领奖.lua 静态还原
-- 模块 SHA256 6c5eaad5f55e89cc5cc3d4502802a88e5c2036ed27e2033ce8d26cec675a59bd；NPC、选项和等待按反汇编逐条保持。
-- 原规则第 2 步的 4 次 OnGetPrize 请求文本含全角减号“(%d － 1)”，在游戏 Lua 中无法编译、实际从未发出；此处按实际效果省略，不补写成可执行请求。
local m_script_name = "龚彩云领奖"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GoToSceneNPC("龚彩云", 172, 122, 2)
    Sleep(200)
    QuestFrameOptionClicked_Item("领取活动奖励", 1, 1200)
    Sleep(200)
    for i = 1, 4 do
        Sleep(200)
    end
    GoToSceneNPC("龚彩云", 172, 122, 2)
    Sleep(200)
    QuestFrameOptionClicked_Item("#{YCBC_180510_32}", 1, 1200)
    Sleep(200)
    GoToSceneNPC("龚彩云", 172, 122, 2)
    Sleep(200)
    QuestFrameOptionClicked_Item("#{YCBC_180510_22}", 1, 1200)
    Sleep(200)
    GoToSceneNPC("龚彩云", 172, 122, 2)
    Sleep(200)
    QuestFrameOptionClicked_Item("#{YCBC_180510_23}", 1, 1200)
    Sleep(200)
end
_SMain()
ScriptOnStop(m_script_name, true)
