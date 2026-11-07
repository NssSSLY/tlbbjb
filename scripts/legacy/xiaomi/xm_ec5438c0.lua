-- 来自 新建文件夹/小蜜文本/小蜜文本/金先生-40-90神器-01.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")
------请填写您的完美武器名称------
local ShuangWanMeiWQ="降龙之双钩银丝枪|三股托天叉|八卦宣花斧|分水峨嵋刺|越王刃|晶玉扇|子母乌金环|沉香长弩|檀香箫|檀香长杖|冷月寒星|兴亡|青铜鹿雕弩|莺语箫|紫电清霜|牡鹿灵杖|清角|镇岳断|两仪战云弩|凤求凰|锁喉|破阵子|摘星|阴阳灵杖|北冥之黄泉|达摩之天崩|玉女之莫问|至情之余响|锁喉|破阵子|两仪战云弩|乐灵箫|"
------请填写您的完美武器名称------

跨图寻路("苏州",353,234)
	延时(1000)
	if 对话NPC("欧冶子") == 1 then
	延时(1000)
	NPC二级对话("血浴神兵")
	延时(1000)
	NPC二级对话("学习铸造神器")
	延时(1000)
	任务_接受()
	延时(1500)
	右键使用物品(ShuangWanMeiWQ)
	延时(1500)
右键使用物品(ShuangWanMeiWQ)
	延时(1500)
	LUA_Call ("setmetatable(_G, {__index = GodWeaponStart_Frame_Env});GodWeaponStart_Accept_Clicked();")--确认
    延时(1000)
    LUA_Call ("setmetatable(_G, {__index = LoginSelectServerQuest_Env});SelectServerQuest_Bn1Click();")--取消
    延时(1000)
	LUA_Call ("setmetatable(_G, {__index = GodWeaponStart_Frame_Env});GodWeaponStart_Accept_Clicked();")--再次确认
    延时(1000)
	

end 
屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")