-- 来自 新建文件夹/小蜜文本/其他类型文本/A00开放帮会福利.txt（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
function AskGuildDetailInfo()
	if 判断有无帮派()==1 then
			   GuildCity_Name = LUA_取返回值([[
					local CityName = Guild:GetMyGuildDetailInfo("CityName")
					return CityName
			   ]], "s")
	   if GuildCity_Name ~= "-1" then--之前已经打开过帮会界面，并已获取过帮会城市，直接return！
	       return GuildCity_Name
	   end
	   LUA_Call("Guild:AskGuildDetailInfo()")
	   延时(3000)
		 GuildCity_Name = LUA_取返回值([[
				local CityName = Guild:GetMyGuildDetailInfo("CityName")
				return CityName
		   ]], "s")
        延时(2000)
        if 窗口是否出现("NewBangHui_Bhxx")==1 then
	        LUA_Call("setmetatable(_G, {__index = NewBangHui_Bhxx_Env}) NewBangHui_Bhxx_Close()")
	    end
	    return GuildCity_Name
	end
end
帮会名字=AskGuildDetailInfo()
屏幕提示("帮会名字:"..帮会名字)
屏幕提示("帮会名字:"..帮会名字)
屏幕提示("帮会名字:"..帮会名字)

function 关闭窗口(strWindowName)
	if 窗口是否出现(strWindowName)==1 then
	  LUA_Call(string.format([[
		setmetatable(_G, {__index = %s_Env}) this:Hide()  
	 ]], strWindowName))  
	 end
end

function 进入帮会城市()
    for i=1,5 do
        if 获取人物信息(16)~=帮会名字 then
            跨图寻路("洛阳",236,236)
            延时(500)
            对话NPC("范纯仁")
            延时(500)
            NPC二级对话("进入本帮城市") 
            延时(5000) 
            寻路(150,44,1) 
			延时(3000) 
        end
    end
end

进入帮会城市()
延时(2000)
寻路(150,44,1) 
延时(2000)
对话NPC("万藏宝")
延时(1000)
NPC二级对话("开放帮会福利：百宝阁")
延时(1000)
NPC二级对话("开放5级百宝阁")
延时(1000)
NPC二级对话("确认开启")
延时(1000)

延时(500)