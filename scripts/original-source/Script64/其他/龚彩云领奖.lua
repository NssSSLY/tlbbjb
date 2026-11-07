-- 反编译自 dfz64.dll 内嵌字节码 002b4ff8（unluac 2025-12-23；仅供分析）
local m_script_name = "龚彩云领奖"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  while true do
    GoToSceneNPC("龚彩云", 172, 122, 2)
    Sleep(200)
    QuestFrameOptionClicked_Item("领取活动奖励", 1, 1200)
    Sleep(200)
    for i = 1, 4 do
      GetLuaValue(fmt("                Clear_XSCRIPT()\n                    Set_XSCRIPT_Function_Name('OnGetPrize')\n                    Set_XSCRIPT_ScriptID(808062)\n                    Set_XSCRIPT_Parameter(0,(%d － 1))\n                    Set_XSCRIPT_ParamCount(1)\n                Send_XSCRIPT()\n            ", i))
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
    break
  end
end

_SMain()
ScriptOnStop(m_script_name, true)
