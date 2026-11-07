-- 提交紫微灵草：由 dfz64.dll 字节码模块 日常/提交紫微灵草.lua 静态还原
-- 模块 SHA256 54e182d7e26c781f498260419a449896b5900ffaed1ac2ed0346b1aea3d0e4b3；调用、参数、等待和循环按反汇编逐条保持。
local m_script_name = "提交紫微灵草"
ScriptOnStart(m_script_name, false, false)
function _SMain()
    local nStart = -1
    DeleteDebugMsg("#{ZJSJ_220708_76}")
    TempBank2Bag("紫微凤尾枝 紫微银堇叶 紫微香兰蕊")
    CloseAllWindow()
    while true do
        local a = Bag:GetItemCount("紫微凤尾枝", nil, 1)
        local b = Bag:GetItemCount("紫微银堇叶", nil, 1)
        local c = Bag:GetItemCount("紫微香兰蕊", nil, 1)
        if a == 0 and b == 0 and c == 0 then
            Sleep(500)
            a = Bag:GetItemCount("紫微凤尾枝", nil, 1)
            b = Bag:GetItemCount("紫微银堇叶", nil, 1)
            c = Bag:GetItemCount("紫微香兰蕊", nil, 1)
        end
        if a == 0 and b == 0 and c == 0 then
            PushColorMsg(m_script_name .. ":您没有紫微灵草")
            break
        end
        local bTalk = false
        if a > 0 then
            bTalk = QuestFrameOptionClicked_Item("#{ZJSJ_220708_14}", 1, 600) == false
        elseif b > 0 then
            bTalk = QuestFrameOptionClicked_Item("#{ZJSJ_220708_15}", 1, 600) == false
        elseif c > 0 then
            bTalk = QuestFrameOptionClicked_Item("#{ZJSJ_220708_16}", 1, 600) == false
        end
        if bTalk then
            GoToSceneNPC("姜星辰", 144, 200, 850)
            Sleep(500)
            QuestFrameOptionClicked_Item("#{ZJSJ_220708_6}", 1, 600)
        else
            MessageBox_Self2_OK_Clicked(600)
            IsWindowVisible("ThreeCity_ZiWei_Change", "ThreeCity_ZiWei_Change_Confirm()")
        end
        if nStart == -1 then nStart = GetTickCount() end
        if IsInDebugMsg("#{ZJSJ_220708_76}") then break end
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
