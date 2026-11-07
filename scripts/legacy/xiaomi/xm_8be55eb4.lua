-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/a西湖领取工资.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({})
跨图寻路("西湖",62,90);Sleep(100)
----------------------------------------------------------------------
--TalkNpc("祝原平")
MoveToNPC(62,90,-1,"祝原平");Sleep(1000)
QuestFrameOptionClicked("领取“龙门客栈”专属工资",1);Sleep(1000)
