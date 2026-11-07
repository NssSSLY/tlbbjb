-- 领取鲜花种子：由 dfz64.dll 字节码模块 日常/领取鲜花种子.lua 静态还原
-- 模块 SHA256 35c1ea3802c53d010486a433532865c35f0b9e71ec636a404f5df489ca0f9222；调用、参数、等待和循环按反汇编逐条保持；原规则在背包满时调用删除/清理物品，本程序改为停止并提示手动清理。
local m_script_name = "领取鲜花种子"
ScriptOnStart(m_script_name)
function _SMain()
    GoToSceneNPC("阿里", 185, 65, 2)
    local nStart = GetTickCount()
    while true do
        GoToSceneNPC("阿里", 185, 65, 2)
        Sleep(600)
        QuestFrameOptionClicked_Item("#{SDJZH_xml_XX(13)}", 1, 1000)
        local szText = GetNPCEventList_Item(0)
        if szText == "#{SDJZH_091106_24}" then
            PushDebugMessage(m_script_name .. "：背包需要清理!")
            ClearBag()
        elseif szText == "#{SDJZH_091106_23}" then
            PushDebugMessage(m_script_name .. "：已完成！")
            break
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
