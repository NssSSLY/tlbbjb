-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/修炼第三本.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
-------修炼 开始--------------------------------------------------------------------------------------------------------
--TalkNpc("扫地神僧")
MoveToNPC(241,31,2,"扫地神僧");Sleep(1000)
QuestFrameOptionClicked("修炼",1);Sleep(1000)

--秘籍 技能 需要自己改
local miji = 3
local jineng = 1

--点击秘籍
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Xinfa_Clicked(%d)",miji),"",0);Sleep(800)
--点击技能
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Skill_Clicked(%d)",jineng),"",0);Sleep(800)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)

--重复复制上面的命令，达到修炼多次的目的

--秘籍 技能 需要自己改
local miji = 3
local jineng = 2

--点击秘籍
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Xinfa_Clicked(%d)",miji),"",0);Sleep(800)
--点击技能
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Skill_Clicked(%d)",jineng),"",0);Sleep(800)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)

--重复复制上面的命令，达到修炼多次的目的


--秘籍 技能 需要自己改
local miji = 3
local jineng = 3

--点击秘籍
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Xinfa_Clicked(%d)",miji),"",0);Sleep(800)
--点击技能
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Skill_Clicked(%d)",jineng),"",0);Sleep(800)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)

--重复复制上面的命令，达到修炼多次的目的

--秘籍 技能 需要自己改
local miji = 3
local jineng = 4

--点击秘籍
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Xinfa_Clicked(%d)",miji),"",0);Sleep(800)
--点击技能
GetLuaValue(string.format("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_Skill_Clicked(%d)",jineng),"",0);Sleep(800)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)
--点击学习
GetLuaValue("setmetatable(_G, {__index=XiulianStudy_Env});XiulianStudy_UpLevel_Clicked()","",0);Sleep(500)

--重复复制上面的命令，达到修炼多次的目的



---------修炼 结束------------------------------------------------------------------------------------------------------
