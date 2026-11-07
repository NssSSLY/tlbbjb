-- 来自 新建文件夹/小蜜文本/4做102神器.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
--所有神器均为吸血
local  人物名称,menpai,PID,远近攻击,内外攻击,角色账号,门派地址,技能状态,性别=获取人物属性()
local 图样名称 = ""
local 神器ID = ""
function 友情提示(text,...)
	local strCode = string.format(text,...)
	LUA_Call(string.format([[
	setmetatable(_G, {__index = DebugListBox_Env})
	DebugListBox_ListBox:AddInfo("#e0000ff#g28f1ff".."%s")	--
	--橙色 #e0000ff#u#g0ceff3
	--蓝色 #e0000ff#g28f1ff
	]], strCode))
end
function 购买图样()
	友情提示(menpai)
	取出物品("金币")
	跨图寻路("楼兰",189,223);延时(1500)
	if 对话NPC("于婆") ==1  then
		NPC二级对话("购买102级神器配方")
		延时(1000)
		if menpai == "慕容" then
			LUA_Call("GoodButton_Clicked(1)")
			延时(1000)
			图样名称 = "大燕韵章图样"
		end
		if menpai == "明教" then
			LUA_Call("GoodButton_Clicked(4)")
			延时(1000)
			图样名称 = "大夏龙雀图样"
		end
		if menpai == "武当" then
			LUA_Call("GoodButton_Clicked(7)")
			延时(1000)
			图样名称 = "大商尘影图样"
		end
		if menpai == "峨嵋" then
			LUA_Call("GoodButton_Clicked(10)")
			延时(1000)
			图样名称 = "大周岚夜图样"
		end
		if menpai == "丐帮" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(1)")
			延时(1000)
			图样名称 = "大秦锋镝图样"
		end
		if menpai == "天龙" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(4)")
			延时(1000)
			图样名称 = "大汉弘纲图样"
		end
		if menpai == "星宿" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(7)")
			延时(1000)
			图样名称 = "大晋星痕图样"
		end
		if menpai == "天山" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(10)")
			延时(1000)
			图样名称 = "大隋凝霜图样"
		end
		if menpai == "少林" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(1)")
			延时(1000)
			图样名称 = "大唐昆岳图样"
		end
		if menpai == "逍遥" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(4)")
			延时(1000)
			图样名称 = "大宋君岑图样"
		end
		if menpai == "唐门" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(9)")
			延时(1000)
			图样名称 = "大梁辟天图样"
		end
		if menpai == "鬼谷" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(12)")
			延时(1000)
			图样名称 = "大魏长歌图样"
		end
		if menpai == "桃花岛" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(3)")
			延时(1000)
			图样名称 = "大越正音图样"
		end
		if menpai == "绝情谷" then
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_PageDown();") --下一页
			延时(1000)
			LUA_Call("GoodButton_Clicked(6)")
			延时(1000)
			图样名称 = "百念朝周图样"
		end
		LUA_Call("setmetatable(_G, {__index = Shop_Env});Booth_Close();")
		延时(1000)
		坐骑_下坐骑()
		延时(1000)
		坐骑_下坐骑()
		延时(1000)
		右键使用物品(图样名称);
		延时(8000)
	end
	
end
function 前往打造()
	取出物品("残缺的神节7级|新莽神符7级")
	跨图寻路("苏州",352,249);延时(1500)
	if menpai == "慕容" then
		
		神器ID = 977
	end
	if menpai == "明教" then
		
		神器ID = 980
	end
	if menpai == "武当" then
		
		神器ID = 983
	end
	if menpai == "峨嵋" then
		
		神器ID = 986
	end
	if menpai == "丐帮" then
		
		神器ID = 989
	end
	if menpai == "天龙" then
		
		神器ID = 992
	end
	if menpai == "星宿" then
		
		神器ID = 995
	end
	if menpai == "天山" then
		
		神器ID = 998
	end
	if menpai == "少林" then
		
		神器ID = 1001
	end
	if menpai == "逍遥" then
		
		神器ID = 1004
	end
	if menpai == "唐门" then
		
		神器ID = 1009 --待验证
	end
	if menpai == "鬼谷" then
		
		神器ID = 1294
	end
	if menpai == "桃花岛" then
		
		神器ID = 1015 --待验证
	end
	if menpai == "绝情谷" then
		
		神器ID = 1018 --待验证
	end
	if 对话NPC("薛烛") ==1  then
		坐骑_下坐骑()
		延时(1000)
		坐骑_下坐骑()
		延时(1000)
		for i=1,25 do
		
		if 获取背包物品数量("连戎神节7级")>= 1 then
			友情提示("神节打造完成")
			材料位置=获取背包物品位置("连戎神节7级")-1
			友情提示(材料位置)
			LUA_Call(string.format([[
			AAA=%d
			BBB=%d
			ComposeItem_Begin(AAA,1,BBB)
			]],神器ID,材料位置))
			延时(20000)
			return
		end
		右键使用物品("新莽神符7级");
		延时(8000)
		end
	end
	
	
end
购买图样()
前往打造()
for i=1,0 do

材料位置=获取背包物品位置("连戎神节7级")-1
LUA_Call(string.format([[
AAA=%d
BBB=%d
ComposeItem_Begin(AAA,1,BBB)
]],i,材料位置))
友情提示(i)
延时(500)

end
