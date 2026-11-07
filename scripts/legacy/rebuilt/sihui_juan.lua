-- 合成四绘卷：由 dfz64.dll 字节码模块 活动/合成四绘卷.lua 静态还原
-- 模块 SHA256 75e5f929779e88f68e454c17110e251cf83946ba6991956d8417ce55a8523a71；调用、参数、等待和循环按反汇编逐条保持。原规则的结束提示键缺少右括号（"#{SXTZ_200731_24"），只能按原文匹配，通常要到 180 秒上限才结束。
local m_script_name = "合成四绘卷"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    DeleteDebugMsg("#{SXTZ_200731_24")
    local nStart = GetTickCount()
    while true do
        TempBank2Bag("百兽绘卷 昆虫绘卷 禽鱼绘卷 花鸟绘卷")
        GoToSceneNPC("薛晏", 323, 329, LUOYANG_ID)
        QuestFrameOptionClicked_Item("#{SXTZ_200731_17}", 1, 700)
        QuestFrameOptionClicked_Item("#{SXTZ_200731_22}", 1, 700)
        if IsInDebugMsg("#{SXTZ_200731_24") then break end
        if GetTickCount() - nStart > 180000 then
            PushColorMsg(m_script_name .. ":超时！")
            break
        end
        Sleep(500)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
