-- 提交五行法帖：由 dfz64.dll 字节码模块 日常/提交五行法帖.lua 静态还原
-- 模块 SHA256 2806e1a01e5820cacfffb785262a6600dde8009cf76117ec93036e53b3415644；调用、参数、等待和循环按反汇编逐条保持。原规则在背包满时调用删除物品，本程序改为停止并提示；结束时把剩余法帖挪回锦囊的步骤未接入。
local m_script_name = "提交五行法帖"
ScriptOnStart(m_script_name)
function _SMain()
    DeleteDebugMsg("#{XKSC_200325_12}")
    DeleteDebugMsg("#{XKSC_200325_13}")
    DeleteDebugMsg("#{XKSC_200325_16}")
    local bTake = false
    if Bag:GetItemCount("五行法帖", 0, 0, Bag:EnumDaoJuItem()) == 0 then
        bTake = true
        PushDebugMessage("五行法帖：先尝试锦囊取出")
        if TempBank2Bag("五行法帖", 0) == false then
            PushDebugMessage("锦囊也没有五行法帖,前往仓库取出")
            Bank_GetItem("五行法帖", -1, nil, nil, true)
        end
    end
    GoToSceneNPC("独孤悔", 200, 334, 1)
    local nStart = GetTickCount()
    local b250, b100, b50, b20, b10 = true, true, true, true, true
    while true do
        GoToSceneNPC("独孤悔", 200, 334, 1)
        QuestFrameOptionClicked_Item("#{XKSC_200325_01}", 1, 800)
        local nCount = Bag:GetItemCount("五行法帖", nil, 1)
        if nCount >= 250 and b250 then
            QuestFrameOptionClicked_Item("#{XKSC_200325_07}", 1, 800)
            if IsInDebugMsg("#{XKSC_200325_13}") then DeleteDebugMsg("#{XKSC_200325_13}"); b250 = false end
        elseif nCount >= 100 and b100 then
            QuestFrameOptionClicked_Item("#{XKSC_200325_06}", 1, 800)
            if IsInDebugMsg("#{XKSC_200325_13}") then DeleteDebugMsg("#{XKSC_200325_13}"); b100 = false end
        elseif nCount >= 50 and b50 then
            QuestFrameOptionClicked_Item("#{XKSC_200325_05}", 1, 800)
            if IsInDebugMsg("#{XKSC_200325_13}") then DeleteDebugMsg("#{XKSC_200325_13}"); b50 = false end
        elseif nCount >= 20 and b20 then
            QuestFrameOptionClicked_Item("#{XKSC_200325_04}", 1, 800)
            if IsInDebugMsg("#{XKSC_200325_13}") then DeleteDebugMsg("#{XKSC_200325_13}"); b20 = false end
        elseif nCount >= 10 and b10 then
            QuestFrameOptionClicked_Item("#{XKSC_200325_03}", 1, 800)
            if IsInDebugMsg("#{XKSC_200325_13}") then DeleteDebugMsg("#{XKSC_200325_13}"); b10 = false end
        else
            break
        end
        if IsInDebugMsg("#{XKSC_200325_12}") then break end
        if IsInDebugMsg("#{XKSC_200325_16}") then
            PushDebugMessage(m_script_name .. "：背包需要清理!")
            Bag_DeleteItem()
        end
        if GetTickCount() - nStart > 60000 then
            PushColorMsg(m_script_name .. ":执行超时")
            break
        end
        DebugStr(m_script_name)
        Sleep(600)
    end
    Bag_Move2TempBank(" 五行法帖 ", 0)
end
_SMain()
ScriptOnStop(m_script_name)
