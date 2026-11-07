-- 兑换藏宝图：由 dfz64.dll 字节码模块 功能/兑换藏宝图.lua 静态还原
-- 模块 SHA256 f434250d2caf0d568b161cecf7aef87f5ecc344daf6279f79a58c75b8450bafa；调用、参数、等待和循环按反汇编逐条保持。原规则把 NPC 表定义成局部变量却按全局名读取（实际为空），这里按原意使用吴玠的坐标；结束时把物品挪回锦囊的步骤未接入，物品留在背包。
local m_script_name = "兑换藏宝图"
ScriptOnStart(m_script_name, false, false)
local npc = { x = 224, y = 226, sceneID = 1, name = "吴玠" }
function _SMain()
    DeleteDebugMsg("#{BTSM_260114_08}")
    local nMoney = Player:GetMoney()
    PushColorMsg(nMoney / 10000)
    if nMoney / 10000 < 10 then
        PushDebugMessage(m_script_name .. ":金币不够,自动取钱！")
        Bank_GetMoney(100000)
    end
    -- 闭环保护：本轮状态与上一轮相同计为没有进展，连续 3 轮就停止并写明原因（原规则没有上限）。
    local guard = NoProgress(m_script_name, 3)
    while true do
        nMoney = Player:GetMoney()
        GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BTSM_260114_02}", 1, 600)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{BTSM_260114_04}", 1, 600)
        Sleep(500)
        Bag_Move2TempBank(" 藏宝图 ", 0)
        Sleep(500)
        if IsInDebugMsg("#{BTSM_260114_08}") then
            PushColorMsg("#{BTSM_260114_08}")
            break
        end
        guard(Player:GetMoney() .. "|" .. Bag:GetItemCount("藏宝图"))
        Sleep(100)
        DebugStr(m_script_name)
    end
end
_SMain()
ScriptOnStop(m_script_name)
