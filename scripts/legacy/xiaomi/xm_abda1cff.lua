-- 来自 新建文件夹/小蜜文本/小蜜文本/金先生-小号35层设置.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"sell", "item"})

function 写角色配置项(AAA,BBB,CCC)
    local 名字= 获取人物信息(12)
    local 路径=string.format("C:\\天龙小蜜\\角色配置\\%s.ini",名字)
    屏幕提示(名字.." 正在写入配置项|"..BBB) sleep()
    写配置项(路径,AAA,BBB,CCC) sleep()
end

function 读角色配置项(AAA,BBB)
    local 名字= 获取人物信息(12)
    local 路径=string.format("C:\\天龙小蜜\\角色配置\\%s.ini",名字)
    sleep()
    qingbao = 读配置项(路径,AAA,BBB)
	return qingbao
end


function 取秘籍名字(Index)	
	local tem=   LUA_取返回值(string.format([[
		Index =%d-1
		local theAction = EnumAction(Index, "combobook")
		if (theAction:GetID() ~= 0 ) then
			local bookname = Player:GetComboBookInfo(Index, "bookname");
			local nLevel = Player:GetComboBookInfo(Index, "level");
			return bookname
		end
		return -1
	]], Index))
	return tem
end


--待测试
function 取所有称号()
	
	local tem =LUA_取返回值(string.format([[
		local curAgname = Player:GetCurrentAgname();
		local curTitleType = Player:Player_GetTitleType();
		local curVirtualAgname = Player:GetCurrentVirtualAgname();					
		local curVirtualAgnameType = Player:GetCurrentVirtualAgnameType();
		local tt={ iIceAttack, iFireAttack, iThunderAttack,iPoisonAttack}
		if iIceAttack==math.max(unpack(tt)) then
		   maxOfT ="冰"
		elseif  iFireAttack==math.max(unpack(tt)) then
			maxOfT ="火"
		elseif  iThunderAttack==math.max(unpack(tt)) then
			maxOfT ="玄"
		elseif  iPoisonAttack==math.max(unpack(tt)) then
			maxOfT ="毒"
		end
		return maxOfT 
	]]), "s")
	return tem
end




----------------------------------------随机延时-----------------------------------------------
function sleep()
	AA = math.random(300,3000)
	延时(AA)
end


----------------------------------------取主属性-----------------------------------------------
function 取主属性()
	local tem =LUA_取返回值(string.format([[
		local iIceAttack  		= Player:GetData( "ATTACKCOLD" );
		local iFireAttack 		= Player:GetData( "ATTACKFIRE" );
		local iThunderAttack	= Player:GetData( "ATTACKLIGHT" );
		local iPoisonAttack		= Player:GetData( "ATTACKPOISON" );
		local tt={ iIceAttack, iFireAttack, iThunderAttack,iPoisonAttack}
		if iIceAttack==math.max(unpack(tt)) then
		   maxOfT ="冰"
		elseif  iFireAttack==math.max(unpack(tt)) then
			maxOfT ="火"
		elseif  iThunderAttack==math.max(unpack(tt)) then
			maxOfT ="玄"
		elseif  iPoisonAttack==math.max(unpack(tt)) then
			maxOfT ="毒"
		end

		return maxOfT 
	]]), "s")
	return tem
end


----------------------------------------定量出售物品-----------------------------------------------
function 出售物品(name,num)
	跨图寻路("洛阳",351,248)延时(1000)
	取出物品(name)	
	对话NPC("何生富")延时(500)
	对话NPC("何生富")延时(500)
	
	local 物品数量 = 获取背包物品数量(name)
	if 物品数量<= num then
		return
	end
	local 出售数量 = 物品数量 - num

	for i=1,10 do
		local ret = tonumber(LUA_取返回值(string.format([[
		local chushou = %d
		setmetatable(_G, {__index = Packet_Env});
		for i=0,199 do
			local theAction = EnumAction(i, "packageitem");
			local id = theAction:GetID();
			if id~=0 then
				if theAction:GetName()=="%s" then
					local num = theAction:GetNum();
					if num==chushou then
						PlayerPackage:SellCurrItem(i)
						return 0
					elseif num>chushou then
						PrepearAsunder()
						Packet_Space_Line10_Row10_button:SetActionItem(id);
						Packet_Space_Line10_Row10_button:DoSubAction();
						PlayerPackage:SplitItem(num-chushou);
						PlayerPackage:SellCurrItem(i)
						return 0
					elseif num<chushou then
						PlayerPackage:SellCurrItem(i)
						return chushou-num
					end
				end
			end
		end
		return 0
		]],出售数量,name)))	
		延时(500)
		出售数量 = ret
		if 出售数量<=0 then
			LUA_取返回值("setmetatable(_G, {__index = SplitItem_Env});this:Hide()")
			break
		end
	end
end


----------------------------------------取令牌信息-----------------------------------------------
function  取令牌信息(index)
	local aaa=  LUA_取返回值(string.format([[ 
			local index = %d
			local nType,BaoZhu1,BaoZhu2,BaoZhu3,BaoZhu4,nQual = DataPool:GetLingPaiInfo()
			--local IconName,ItemName = DataPool:GetLingPaiBaoZhuIconName(1)
			if nType> 0 then
				if index == 1 then
					return BaoZhu1
				end
				if index == 2 then
					return BaoZhu2
				end
				if index == 3 then
					return BaoZhu3
				end
				if index == 4 then
					return BaoZhu4
				end	
				if index == 5 then
					return nQual
				end	
				if index ==  0 then
					return nType
				end					
			end
			return -1
	]], index))
	return tonumber(aaa)
end


屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")

写角色配置项("观山海","出副本","1") sleep()
写角色配置项("观山海","完成层数","35") sleep()
写角色配置项("观山海","领奖类型","2") sleep()
写角色配置项("观山海","打怪速度","3") sleep()

跨图寻路("大理",220,53)




屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")