function _SMain(...)

    local npc = {name = "巴盖里", x = 183, y = 68, sceneID = 2}

    local itemCount = 30

    while true do

        local nItem = Bag:GetItemCount("波斯玫瑰")

        if nItem >= itemCount then

            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)

            Sleep(600)

            DialogOptionClicked("波斯玫瑰兑换奖励", 1, 800)

            DialogOptionClicked("30朵波斯玫瑰兑换奖励", 1, 800)

            QuestFrameMissionComplete(0, 800)

        else

            TempBank2Bag("波斯玫瑰")

            Sleep(500)

            nItem = Bag:GetItemCount("波斯玫瑰")

            if nItem < itemCount then

                Bank_GetItem("波斯玫瑰")

                Sleep(500)

                nItem = Bag:GetItemCount("波斯玫瑰")

                if nItem < itemCount then

                    break

                end

            end

        end

        Sleep(200)

        DebugStr("波斯玫瑰换强化")

    end

end



_SMain()

