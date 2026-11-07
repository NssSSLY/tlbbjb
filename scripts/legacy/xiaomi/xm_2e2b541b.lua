-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/碎片换石头体.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})

for i=999,1,-1 
do
MoveToNPC(290,321,0,"诸葛孔亮");Sleep(100)
QuestFrameOptionClicked("7级宝石",0);Sleep(300)
QuestFrameOptionClicked("红宝石",0);Sleep(300)
GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_PackUp_Clicked();")
end
