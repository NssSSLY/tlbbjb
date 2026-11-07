-- 领取波斯玫瑰：由 dfz64.dll 字节码模块 日常/领取波斯玫瑰.lua 静态还原
-- 模块 SHA256 c8e8a3239292eb063e548a45e8732d1dcf04cec86be1be991c8606586c219e16；调用、参数、等待和循环按反汇编逐条保持；原规则在背包满时调用删除/清理物品，本程序改为停止并提示手动清理。
local m_script_name = "领取波斯玫瑰"
ScriptOnStart(m_script_name)
function _SMain()
    GoToSceneNPC("巴盖里", 182, 69, 2)
    local nStart = GetTickCount()
    while true do
        GoToSceneNPC("巴盖里", 182, 69, 2)
        Sleep(600)
        QuestFrameOptionClicked_Item("#{SDJZH_xml_XX(01)}", 1, 700)
        local szText = GetNPCEventList_Item(0)
        if szText == "#{SDJZH_091106_04}" then
            PushDebugMessage("领取波斯玫瑰完成！")
            break
        elseif szText == "#{SDJZH_091106_24}" then
            PushDebugMessage(m_script_name .. "：背包需要清理!")
            Bag_DeleteItem()
        end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
