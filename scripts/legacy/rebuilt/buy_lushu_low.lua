-- 购买初级路书：由 dfz64.dll 字节码模块 任务/购买初级路书.lua 静态还原
-- 模块 SHA256 11e4e5b3cd486b8d76e06c26df7171629cda52c3b8e5c2c0b44e8384e4d12b11；取钱数、NPC、对话选项、确认框、结束提示与循环按反汇编保持；原规则开头的 RecvState(1)（原程序自身的接收状态开关）未接入；原规则直到出现结束提示才停，这里最多 30 轮，防止提示没识别到时一直重复。
local m_script_name = "购买初级路书"
ScriptOnStart(m_script_name, false, false)
local tNpc = { x = 224, y = 226, sceneID = 1, name = "吴玠" }
function _SMain()
    DeleteDebugMsg("#{BTSM_260114_08}")
    DeleteDebugMsg("#{CPBT_260115_92}")
    DeleteDebugMsg("#{CPBT_260115_13}")
    Bank_GetMoney(2000000)
    for _ = 1, 30 do
        GoToSceneNPC(tNpc.name, tNpc.x, tNpc.y, tNpc.sceneID)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{CPBT_260115_02}", 1, 600)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{CPBT_260115_06}", 1, 600)
        Sleep(500)
        GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
        if IsInDebugMsg("#{CPBT_260115_14}") or IsInDebugMsg("#{CPBT_260115_92}") or IsInDebugMsg("#{CPBT_260115_13}") then
            PushColorMsg("#{CPBT_260115_14}")
            break
        end
        Sleep(100)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
