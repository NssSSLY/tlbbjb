PushDebugMessage("许愿果兑换奖励")

local szItem = "天罡强化精华"
local min = 7

--检查背包数量是否充足，不足前往仓库取
local _, nCount, _ = FindBagItem(-1, "许愿果")
if nCount < min then
    PushDebugMessage("前往仓库取出许愿果")
    Bank_GetItem(" 许愿果 ", -1); Sleep(500)
end 


local nTick = -1

while true do

    _, nCount, _ = FindBagItem(-1, "许愿果")

    if nCount >= min then

        MoveToNPC(281, 275, 1, "梁道士"); Sleep(1000)

        QuestFrameOptionClicked("许愿果兑换奖励");Sleep(800)

        QuestFrameOptionClicked(szItem); Sleep(800)
        
        QuestFrameOptionClicked("我要兑换"); Sleep(800)
            
        if nTick == -1 then nTick = GetTickCount() end

    else

        break

    end

    --超出三分钟跳出循环
    if nTick ~= -1 and GetTickCount() - nTick > 180 * 1000 then 
        break 
    end

    Sleep(200)
    DebugStr("兑换中...")
end











