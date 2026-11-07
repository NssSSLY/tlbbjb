-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/领元宝.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
--PushDebugMessage("日常：领取每日五行法帖,点编辑可以修改领取次数") 
--参数填1-5之间的数字 ，大于1次需要金币 修改后保存
MoveToNPC(158,151,2,"新版本天使");Sleep(100)
while true do
local yuanbao = Player:GetDataInt('YUANBAO')
    if yuanbao > 9989999 then break end
QuestFrameOptionClicked("领取元宝",1);Sleep(30)
end
