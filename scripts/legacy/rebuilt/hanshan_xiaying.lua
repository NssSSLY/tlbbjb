-- 寒山侠影：由 dfz64.dll 字节码模块 活动/寒山侠影.lua 静态还原
-- 模块 SHA256 03e26cee1c1500d55bee1fb811b7718f1596c82db3d81fd11afba0635e1ff2f2；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "寒山侠影"
ScriptOnStart(m_script_name, true, true)
function _SMain()
    GoToSceneNPC("寒时月", 272, 269, LUOYANG_ID)
    Sleep(1000)
    QuestFrameOptionClicked_Item("#{DGRR_260821_14}", 1, 1000)
end
PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
