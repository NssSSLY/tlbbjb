PushDebugMessage("波斯玫瑰兑换奖励")

local szItem = "30朵波斯玫瑰兑换奖励"
local min = 30

--检查背包数量是否充足，不足前往仓库取
local _, nCount, _ = FindBagItem(-1, "波斯玫瑰")
if nCount < min then
    PushDebugMessage("前往仓库取出玫瑰")
    Bank_GetItem(" 波斯玫瑰 ", -1); Sleep(500)
end 


local nTick = -1

while true do

    _, nCount, _ = FindBagItem(-1, "波斯玫瑰")

    if nCount >= min then

        MoveToNPC(187, 68, 2, "巴盖里"); Sleep(1000)

        QuestFrameOptionClicked("波斯玫瑰兑换奖励");Sleep(1000)

        QuestFrameOptionClicked(szItem); Sleep(1000)

        QuestFrameMissionComplete();     
          
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











