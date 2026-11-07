-- 乱匪密函换至尊强化：由 dfz64.dll 字节码模块 其他/乱匪密函换至尊强化.lua 静态还原
-- 模块 SHA256 21d26d499bf739cb7f7e29191454ffab3990d825970faf0c9d4dc8096d8b01a9；调用、参数、等待和循环按反汇编逐条保持。
function _SMain()
    local npc = { name = "苏辙", x = 258, y = 165, sceneID = LUOYANG_ID }
    local nNeed = 10
    while true do
        if Bag:GetItemCount("乱匪密函") >= nNeed then
            if DialogOptionClicked("上缴乱匪密函换取封赏", 1, 600) then
                DialogOptionClicked("10个乱匪密函兑换封赏", 1, 600)
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
