-- 领取师徒心连心：由 dfz64.dll 字节码模块 日常/领取师徒心连心.lua 静态还原
-- 模块 SHA256 d4d5ecfe6be4a3f637253d660a0d99aadabe22a22545be589ee57cdd08fbce60；调用、参数、等待和循环按反汇编逐条保持；原规则在背包满时调用删除/清理物品，本程序改为停止并提示手动清理。
local m_script_name = "领取师徒心连心"
ScriptOnStart(m_script_name)
function _SMain()
    DeleteDebugMsg("#{ResultText_15}")
    GoToSceneNPC("聂政", 139, 132, 2)
    local nStart = GetTickCount()
    while true do
        GoToSceneNPC("聂政", 139, 132, 2)
        Sleep(800)
        QuestFrameOptionClicked_Item("师徒心连心", 1, 1000)
        local szText = GetNPCEventList_Item(0)
        if string.find(szText, "对不起，你今天已经参加过此活动了，请明天再来!", nil, true) then break end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        Sleep(100)
        if IsInDebugMsg("#{ResultText_15}") then
            PushDebugMessage(m_script_name .. "：背包需要清理!")
            Bag_DeleteItem()
        end
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
