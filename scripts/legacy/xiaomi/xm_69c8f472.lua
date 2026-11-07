-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/【领取】红利.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({})
跨图寻路("大理",148,121)
local 当前地图ID = GetSceneID()
MoveToNPC(148, 121, -1, "祝富贵");Sleep(1000)
QuestFrameOptionClicked("领取工资",0);Sleep(1000)
QuestFrameOptionClicked("领取全额红利",0);Sleep(1000)
--Lv:10
