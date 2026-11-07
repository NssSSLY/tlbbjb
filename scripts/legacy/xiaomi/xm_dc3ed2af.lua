-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/【兑换】隐贤名玉兑换金蚕丝.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"item"})
PushDebugMessage("#cFF0000>>诗情专用，买脚本加微信maxiong0903<<")
PushDebugMessage("隐贤名玉兑换奖励")

local szItem = "兑换5个金蚕丝"
local min = 45

--检查背包数量是否充足，不足前往仓库取
local _, nCount, _ = FindBagItem(-1, "隐贤名玉")
if nCount < min then
    PushDebugMessage("前往仓库取出隐贤名玉")
    Bank_GetItem(" 隐贤名玉 ", -1); Sleep(500)
end 


local nTick = -1

while true do

    _, nCount, _ = FindBagItem(-1, "隐贤名玉")

    if nCount >= min then

        MoveToNPC(175, 142, 2, "孙八爷"); Sleep(1000)

        QuestFrameOptionClicked("兑换携手战江湖奖励");Sleep(1000)

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











