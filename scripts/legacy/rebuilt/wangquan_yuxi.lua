-- 兑换王权御玺：由 dfz64.dll 字节码模块 功能/兑换王权御玺.lua 静态还原
-- 模块 SHA256 fadb06e956e3ac96fb2646a73137574ac815a401d97ae89d595c71eeb108b3ca；调用、参数、等待和循环按反汇编逐条保持。原规则开头的 ClearBag（清理背包）不执行。
local m_script_name = "兑换王权御玺"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local szItem = "王权御令"
    local nStart = -1
    DeleteDebugMsg("#{ZZZB_200805_25}")
    DeleteDebugMsg("#{ZZZB_200805_51}")
    CloseAllWindow()
    -- 原规则此处调用 ClearBag 清理背包；本程序不做清理类操作，跳过。
    while true do
        IsWindowVisible("T3XinTianWai_Guide", "T3XinTianWai_Guide_OnClose()")
        local nCount = Bag:GetItemCount(szItem)
        if nCount < 100 then
            TempBank2Bag(szItem)
            Sleep(500)
            nCount = Bag:GetItemCount(szItem)
            if nCount < 100 then
                Bank_GetItem(szItem)
                Sleep(500)
            end
            nCount = Bag:GetItemCount(szItem)
        end
        if nCount < 100 then
            PushColorMsg(m_script_name .. ":您王权御令数量不足")
            break
        end
        GoToSceneNPC("殷轩奇", 88, 173, 850)
        if nStart == -1 then nStart = GetTickCount() end
        QuestFrameOptionClicked_Item("#{ZZZB_200805_2}", 1, 800)
        QuestFrameOptionClicked_Item("#{ZZZB_200805_23}", 1, 800)
        IsWindowVisible("WuhunQuest", "WuhunQuest_Bn1Click();")
        if IsInDebugMsg("#{ZZZB_200805_25}") or IsInDebugMsg("#{ZZZB_200805_51}") then break end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        Sleep(300)
        DebugStr(m_script_name)
    end
    CloseAllWindow()
end
_SMain()
ScriptOnStop(m_script_name)
