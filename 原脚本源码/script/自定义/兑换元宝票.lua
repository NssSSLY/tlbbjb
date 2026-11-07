PushDebugMessage("可以编辑修改保留的数量")

-- 要保留、不兑换成元宝票的元宝数量 ======根据需要设置======
local BaoLiu = 10



local nTick = 0
while true do

    -- 获取当前元宝数量
    local yuanbao = Player:GetDataInt('YUANBAO')

    -- 元宝不足退出兑换
    if yuanbao <= BaoLiu then break end
    
    --前往钱庄
    MoveToNPC(65, 42, 224, "孙进宝"); Sleep(600)
    -- 获取起始兑换时间
    if nTick == 0 then nTick = GetTickCount() end

    -- 超过30秒退出兑换
    if nTick ~= 0 and GetTickCount() - nTick > 30 * 1000 then break end

    -- 计算需要兑换的数量
    local nNeed = yuanbao - BaoLiu

    -- 每次兑换不超过50000元宝
    if nNeed > 50000 then nNeed = 50000 end
    if nNeed <= 0 then break end

    -- 开始兑换
    Player:YB2Ticket(nNeed)

    Sleep(1000)

end




PushDebugMessage("兑换结束！")

-- 将元宝兑换成元宝票 FQ_101210_27