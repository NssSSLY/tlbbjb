-- 许愿果换红宝石：由 dfz64.dll 字节码模块 其他/许愿果换红宝石.lua 静态还原
-- 模块 SHA256 93f06d0d06766e6c5dd40ee3228716cc2a3779fda2c24fd84fd9fde903591a9a；调用、参数、等待和循环按反汇编逐条保持。
function _SMain()
    local npc = { name = "梁道士", x = 282, y = 275, sceneID = 1 }
    local szItem = "红宝石"
    while true do
        local nItem = Bag:GetItemCount("许愿果")
        if nItem >= 20 then
            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
            Sleep(600)
            DialogOptionClicked("许愿果兑换奖励", 1, 700)
            DialogOptionClicked(szItem, 3, 700)
            DialogOptionClicked("我要兑换", 1, 700)
        else
            TempBank2Bag("许愿果")
            Sleep(500)
            nItem = Bag:GetItemCount("许愿果")
            if nItem < 20 then
                Bank_GetItem("许愿果")
                Sleep(500)
                nItem = Bag:GetItemCount("许愿果")
                if nItem < 20 then break end
            end
        end
        Sleep(200)
        DebugStr("许愿果换" .. szItem)
    end
end
_SMain()
