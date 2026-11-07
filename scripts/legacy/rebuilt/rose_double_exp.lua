-- 玫瑰换双倍：由 dfz64.dll 字节码模块 其他/玫瑰换双倍.lua 静态还原
-- 模块 SHA256 dbee22179647f86d538711425518ced6067dd88a4e918eddb180d582e781287d；调用、参数、等待和循环按反汇编逐条保持。
function _SMain()
    local npc = { name = "巴盖里", x = 183, y = 68, sceneID = 2 }
    local itemCount = 5
    while true do
        local nItem = Bag:GetItemCount("波斯玫瑰")
        if nItem >= itemCount then
            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
            Sleep(600)
            DialogOptionClicked("波斯玫瑰兑换奖励", 1, 800)
            DialogOptionClicked("5朵波斯玫瑰兑换奖励", 1, 800)
            QuestFrameMissionComplete(0, 800)
        else
            TempBank2Bag("波斯玫瑰")
            Sleep(500)
            nItem = Bag:GetItemCount("波斯玫瑰")
            if nItem < itemCount then
                Bank_GetItem("波斯玫瑰")
                Sleep(500)
                nItem = Bag:GetItemCount("波斯玫瑰")
                if nItem < itemCount then break end
            end
        end
        Sleep(200)
        DebugStr("波斯玫瑰换双倍")
    end
end
_SMain()
