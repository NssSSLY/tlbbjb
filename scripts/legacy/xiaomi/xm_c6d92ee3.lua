-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/a刷神兵.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({})
CityToGuild()

if CityToGuild() then
    MoveToNPC(131, 126, -1, "武强盛"); Sleep(500)
    QuestFrameOptionClicked("领取状态：进入神兵阁",1); Sleep(500)
    QuestFrameOptionClicked("确定领取状态：进入神兵阁",1); Sleep(500)

    MoveToNPC(131, 126, -1, "武强盛"); Sleep(500)
    QuestFrameOptionClicked("我要进入神兵阁",1); Sleep(500)
    QuestFrameOptionClicked("确定进入神兵阁",1); Sleep(500)
    QuestFrameOptionClicked("确定进入神兵阁",1); Sleep(500)
end



