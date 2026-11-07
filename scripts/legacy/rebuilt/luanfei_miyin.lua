-- 乱匪密函换秘银：由 dfz64.dll 字节码模块 其他/乱匪密函换秘银.lua 静态还原
-- 模块 SHA256 7299996e88d39a81274ab750e24f7b60f663df6c9801709d36d4d7fa6efcb249；调用、参数、等待和循环按反汇编逐条保持。
function _SMain()
    local npc = { name = "苏辙", x = 258, y = 165, sceneID = LUOYANG_ID }
    local nNeed = 42
    while true do
        if Bag:GetItemCount("乱匪密函") >= nNeed then
            if DialogOptionClicked("上缴乱匪密函换取封赏", 1, 600) then
                DialogOptionClicked("42个乱匪密函兑换封赏", 1, 600)
                QuestFrameMissionComplete(nil, 200)
            else
                GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
                Sleep(200)
            end
        else
            PushColorMsg("乱匪密函数量不足")
            break
        end
        Sleep(200)
        DebugStr("乱匪密函兑换")
    end
end
_SMain()
