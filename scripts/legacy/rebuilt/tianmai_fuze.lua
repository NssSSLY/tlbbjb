-- 领取天脉福泽：由 dfz64.dll 字节码模块 日常/领取天脉福泽.lua 静态还原
-- 模块 SHA256 53e57644041c884b7028cd0b8bc35215b54bee802836676682c7aa44cb00fc93；NPC、坐标、选项和次数按反汇编逐条保持；系统提示提前结束尚未接入，按原上限 5 次执行。
local m_script_name = "领取天脉福泽"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    DeleteDebugMsg("#{TWWK_20220708_89}")
    for i = 1, 5 do
        GoToSceneNPC("陈霄", 105, 200, 850)
        QuestFrameOptionClicked_Item("#{TWWK_20220708_51}", 1, 800)
        Sleep(300)
        if IsInDebugMsg("#{TWWK_20220708_89}") then break end
        DebugStr(m_script_name)
    end
end
_SMain()
