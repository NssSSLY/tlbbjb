-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/a战功商店买东西.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
CityToGuild()

if CityToGuild() then
    MoveToNPC(93, 55, -1, "赵子勋"); Sleep(1000)
    QuestFrameOptionClicked("战功商店",1); Sleep(1000)

    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(1);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(1);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(1);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(1);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)

    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(9);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(9);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(9);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(9);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)
    GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(12);","",0);Sleep(1000)
MessageBox_Self_OK_Clicked(); Sleep(500)

跨图寻路("大理",179,122);Sleep(100)

GuildToCity()
end



