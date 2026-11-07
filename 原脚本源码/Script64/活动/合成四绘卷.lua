-- 反编译自 dfz64.dll 内嵌字节码 0042dafd（unluac 2025-12-23；仅供分析）
local m_script_name = "合成四绘卷"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  DeleteDebugMsg("#{SXTZ_200731_24")
  local tickOut = GetTickCount()
  while true do
    TempBank2Bag("百兽绘卷 昆虫绘卷 禽鱼绘卷 花鸟绘卷")
    GoToSceneNPC("薛晏", 323, 329, LUOYANG_ID)
    QuestFrameOptionClicked_Item("#{SXTZ_200731_17}", 1, 700)
    QuestFrameOptionClicked_Item("#{SXTZ_200731_22}", 1, 700)
    if IsInDebugMsg("#{SXTZ_200731_24") then
      break
    end
    if GetTickCount() - tickOut > 180000 then
      PushColorMsg(m_script_name .. ":超时！")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
