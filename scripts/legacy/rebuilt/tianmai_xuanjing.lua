-- 上缴天脉玄晶：由 dfz64.dll 字节码模块 日常/上缴天脉玄晶.lua 静态还原
-- 模块 SHA256 e9f7d0003db3c7de7bd78d428a8ceb11200aabe447ebf0366f9229d4cc9b8631；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "上缴天脉玄晶"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local nStart = Bag:GetItemCount("天脉玄晶")
    -- 闭环保护：本轮状态与上一轮相同计为没有进展，连续 8 轮就停止并写明原因（原规则没有上限）。
    local guard = NoProgress(m_script_name, 8)
    while true do
        local szText = GetNPCEventListAllItem()
        guard(Bag:GetItemCount("天脉玄晶") .. (string.find(szText, "#{KVKZYZD_110705_36}", nil, true) and "|对话" or "|无对话"))
        if string.find(szText, "#{KVKZYZD_110705_36}", nil, true) then
            local nCount = Bag:GetItemCount("天脉玄晶")
            local nLeft = 50 - (nStart - nCount)
            if nCount < nLeft then nLeft = nCount end
            if nLeft >= 40 then
                QuestFrameOptionClicked_Item("#{KVKZYZD_110705_38}", 1, 500)
            elseif nLeft >= 10 then
                QuestFrameOptionClicked_Item("#{KVKZYZD_110705_37}", 1, 500)
            elseif nLeft >= 1 then
                QuestFrameOptionClicked_Item("#{KVKZYZD_110705_36}", 1, 500)
            else
                return
            end
        else
            GoToSceneNPC("陈霄", 105, 200, 850)
        end
        if nStart - Bag:GetItemCount("天脉玄晶") >= 50 then LogMsg("已经上缴超过50个天脉玄晶") end
        Sleep(300)
        DebugStr(m_script_name)
    end
end
_SMain()
