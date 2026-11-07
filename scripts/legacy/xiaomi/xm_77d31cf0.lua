-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/领取灵石天降.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({})
local 当前地图ID = GetSceneID()
MoveToNPC(163, 181, -1, "姜炎山");Sleep(1000)
QuestFrameOptionClicked("上缴昆吾之石",1);Sleep(1000)
等待到指定时间("15:26")
QuestFrameOptionClicked("领取灵石天降活动奖励",1);Sleep(1000)