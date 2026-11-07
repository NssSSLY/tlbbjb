-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/领神兵符.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})

for i=999,1,-1 
do
MoveToNPC(158,151,2,"新版本天使");Sleep(100)
QuestFrameOptionClicked("神器",0);Sleep(300)
QuestFrameOptionClicked("神兵符",0);Sleep(300)
GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_PackUp_Clicked();")
end
