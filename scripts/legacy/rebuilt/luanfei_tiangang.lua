-- 乱匪密函换天罡强化：由 dfz64.dll 字节码模块 其他/乱匪密函换天罡强化.lua 静态还原
-- 模块 SHA256 fc365720f6d93e142f1b9041ddc787f07ae4fca9010fb8ebf0f043637eac4b55；调用、参数、等待和循环按反汇编逐条保持。
function _SMain()
    local npc = { name = "苏辙", x = 258, y = 165, sceneID = LUOYANG_ID }
    local nNeed = 32
    while true do
        if Bag:GetItemCount("乱匪密函") >= nNeed then
            if DialogOptionClicked("上缴乱匪密函换取封赏", 1, 600) then
                DialogOptionClicked("32个乱匪密函兑换封赏", 1, 600)
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
