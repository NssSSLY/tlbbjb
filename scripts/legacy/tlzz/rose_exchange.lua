function _SMain(...)
    local npc = {name = "°Í¸ÇÀï", x = 183, y = 68, sceneID = 2}
    local itemCount = 30
    while true do
        local nItem = Bag:GetItemCount("²¨Ë¹Ãµ¹å")
        if nItem >= itemCount then
            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
            Sleep(600)
            DialogOptionClicked("²¨Ë¹Ãµ¹å¶Ò»»½±Àø", 1, 800)
            DialogOptionClicked("30¶ä²¨Ë¹Ãµ¹å¶Ò»»½±Àø", 1, 800)
            QuestFrameMissionComplete(0, 800)
        else
            TempBank2Bag("²¨Ë¹Ãµ¹å")
            Sleep(500)
            nItem = Bag:GetItemCount("²¨Ë¹Ãµ¹å")
            if nItem < itemCount then
                Bank_GetItem("²¨Ë¹Ãµ¹å")
                Sleep(500)
                nItem = Bag:GetItemCount("²¨Ë¹Ãµ¹å")
                if nItem < itemCount then
                    break
                end
            end
        end
        Sleep(200)
        DebugStr("²¨Ë¹Ãµ¹å»»Ç¿»¯")
    end
end

_SMain()
