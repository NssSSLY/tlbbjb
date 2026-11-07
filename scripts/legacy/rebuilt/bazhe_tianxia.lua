-- 领取霸者天下奖励：由 dfz64.dll 字节码模块 日常/领取霸者天下奖励.lua 静态还原
-- 模块 SHA256 df386d1365f703e99afbc5e20628155874169c0e6c4113666898073709c3a1b8；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "领取霸者天下奖励"
ScriptOnStart(m_script_name, true, false)
function _SMain()
    local nStart = -1
    DeleteDebugMsg("#{BZTX_220705_163}")
    DeleteDebugMsg("#{BZTX_220705_164}")
    CloseAllWindow()
    while true do
        GoToSceneNPC("万翎疆", 133, 59, 850)
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. "：超时")
            break
        end
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BZTX_220705_162}", 1, 1000)
        if IsInDebugMsg("#{BZTX_220705_163}") or IsInDebugMsg("#{BZTX_220705_164}") then break end
        if string.find(GetNPCEventList_Item(0), "#{BZTX_220705_382", nil, true) then
            PushColorMsg("不是霸主")
            break
        end
    end
    nStart = -1
    DeleteDebugMsg("#{BZTX_220705_164}")
    DeleteDebugMsg("#{BZTX_220705_221}")
    DeleteDebugMsg("#{BZTX_220705_304}")
    while true do
        GoToSceneNPC("万翎疆", 133, 59, 850)
        if nStart == -1 then nStart = GetTickCount() end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. "：超时")
            return
        end
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BZTX_220705_220}", 1, 1000)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BZTX_260602_15}", 1, 1000)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BZTX_260602_16}", 1, 1000)
        if IsInDebugMsg("#{BZTX_220705_164}") or IsInDebugMsg("#{BZTX_220705_221}") or IsInDebugMsg("#{BZTX_220705_304}") then break end
    end
end
_SMain()
ScriptOnStop(m_script_name)
