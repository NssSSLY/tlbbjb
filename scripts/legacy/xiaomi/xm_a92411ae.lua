-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/自动吃精华毒.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"item"})

for i=999,1,-1 
do
使用物品("绿晶石精华(7级)")
Player_DispelBuffByName("绿晶石精华：增加毒攻击")
end