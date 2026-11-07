-- 购买路书：由 dfz64.dll 字节码模块 任务/购买路书.lua 静态还原
-- 模块 SHA256 e437bd30c08872b53e9a3c6ecfefb4bfe40a8705607a1f68cba1b9b49c5b3f4d；取钱数、NPC、对话选项、确认框、结束提示与循环按反汇编保持；原规则开头的 RecvState(1)（原程序自身的接收状态开关）未接入；原规则直到出现结束提示才停，这里最多 30 轮，防止提示没识别到时一直重复。
local m_script_name = "购买路书"
ScriptOnStart(m_script_name, false, false)
local tNpc = { x = 224, y = 226, sceneID = 1, name = "吴玠" }
function _SMain()
    DeleteDebugMsg("#{CPBT_260115_13}")
    DeleteDebugMsg("#{CPBT_260115_14}")
    DeleteDebugMsg("#{CPBT_260115_15}")
    Bank_GetMoney(2000000)
    for _ = 1, 30 do
        GoToSceneNPC(tNpc.name, tNpc.x, tNpc.y, tNpc.sceneID)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{CPBT_260115_02}", 1, 600)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{CPBT_260115_06}", 1, 600)
        Sleep(500)
        GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
        if IsInDebugMsg("#{CPBT_260115_14}") or IsInDebugMsg("#{CPBT_260115_15}") or IsInDebugMsg("#{CPBT_260115_13}") then
            PushColorMsg("#{CPBT_260115_14}")
            break
        end
        Sleep(100)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
