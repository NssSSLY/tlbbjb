-- 购买寻宝图：由 dfz64.dll 字节码模块 任务/购买寻宝图.lua 静态还原
-- 模块 SHA256 6181f03ef4c563b40aba2d953c8ad6e9f32c502eb1ca5fd91db97e05b18eec49；取钱数、NPC、对话选项、确认框、结束提示与循环按反汇编保持；原规则开头的 RecvState(1)（原程序自身的接收状态开关）未接入；原规则直到出现结束提示才停，这里最多 30 轮，防止提示没识别到时一直重复。原规则第三个结束提示的键少了右括号（#{XCBT_260506_24），照原样保留，这条提示不会被识别。
local m_script_name = "购买寻宝图"
ScriptOnStart(m_script_name, false, false)
local tNpc = { x = 224, y = 226, sceneID = 1, name = "吴玠" }
function _SMain()
    DeleteDebugMsg("#{XCBT_260506_11}")
    DeleteDebugMsg("#{XCBT_260506_15}")
    DeleteDebugMsg("#{XCBT_260506_24}")
    DeleteDebugMsg("#{XCBT_260506_10}")
    Bank_GetMoney(1500000)
    for _ = 1, 30 do
        GoToSceneNPC(tNpc.name, tNpc.x, tNpc.y, tNpc.sceneID)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{XCBT_260506_01}", 1, 600)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{XCBT_260506_05}", 1, 600)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{XCBT_260506_05}", 1, 600)
        Sleep(500)
        GetLuaValue("setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
        if IsInDebugMsg("#{XCBT_260506_11}") or IsInDebugMsg("#{XCBT_260506_15}") or IsInDebugMsg("#{XCBT_260506_24")
            or IsInDebugMsg("#{XCBT_260506_10}") then
            PushColorMsg("#{XCBT_260506_11}")
            break
        end
        Sleep(100)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
