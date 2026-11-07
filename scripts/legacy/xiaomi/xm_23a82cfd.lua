-- 来自 新建文件夹/小蜜文本/内置文本/旧内置文件/五行宝玉淬洗（按最低）.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
--获取宝玉加持度百分比
function GetJadePercent(nJadeName)
	local CurrentJade = {[0] = "鸾金宝玉淬洗","云水宝玉淬洗","建木宝玉淬洗","天火宝玉淬洗","息土宝玉淬洗"}
	local Num = 0
	for JadeIndex, JadeName in pairs(CurrentJade) do 
		if  string.find(JadeName, nJadeName) then	
			--屏幕提示(JadeIndex)
			Num = LUA_取返回值(string.format([[
				local JadeIndex = %d
				local nAllJadeExtend = 0
				for i = 1 , 5 do	
					local bJadeType = Player:GetFiveElements_JadeType(JadeIndex, i - 1)
					local nExtendValue = Player:GetFiveElements_JadeExtend(JadeIndex, bJadeType)
					nAllJadeExtend = nAllJadeExtend + nExtendValue
				end
				--PushDebugMessage(nAllJadeExtend)
				return nAllJadeExtend
			]],JadeIndex))
		end 
	end
	屏幕提示(string.format("[ %s ]当前的加持度[ %d ]",nJadeName, Num))
	return tonumber(Num)
end
--获取需要洗的宝玉及当前百分比
function GetUpJade()
	local BaoYu = {[0] = "鸾金宝玉淬洗","云水宝玉淬洗","建木宝玉淬洗","天火宝玉淬洗","息土宝玉淬洗"}
	local BaoYuPercent = {}
	for index, jade in pairs(BaoYu) do
		local Num = GetJadePercent(jade)
		local nActive = tonumber(LUA_取返回值(string.format("local bElementsActive = Player:IsFiveElements_ElementsActive(%d);return bElementsActive",index)))
		if nActive ~= 1 then
			Num = -100
		end
		if Num < 100 then
			table.insert(BaoYuPercent,{name = jade, idx = index, num = Num})
		end
	end
	function Fun(x, y)
		if x["num"] < y["num"] then
			return x["num"] < y["num"]
		end
	end
	table.sort(BaoYuPercent, Fun)
	return BaoYuPercent
end

--淬洗动作，到高于原有百分比则停止
function WashBaoYu(JadeIndex)
	while true do 
		local nMoney = tonumber(LUA_取返回值("return Player:GetData('MONEY')+Player:GetData('MONEY_JZ')"))
		local CailiaoNum = 获取背包物品数量("玉华灵泉")
		if nMoney >= 10000 and CailiaoNum >= 5 then
			local nActive = tonumber(LUA_取返回值(string.format("local bElementsActive = Player:IsFiveElements_ElementsActive(%d);return bElementsActive",JadeIndex)))
			--洗宝玉函数
			LUA_Call(string.format([[
				Clear_XSCRIPT()
					Set_XSCRIPT_Function_Name( "FiveElementsJadeWash" )
					Set_XSCRIPT_ScriptID( 880039 )
					Set_XSCRIPT_Parameter( 0, %d ) 
					Set_XSCRIPT_Parameter( 1, 2 ) 		--表示自动，没有元宝购买的行为
					Set_XSCRIPT_ParamCount( 2 )
				Send_XSCRIPT()
			]],JadeIndex))
			延时(1000)
			if nActive == 1 then
				if 窗口是否出现("WuhunQuest") == 1 then
					--替换刷出来的宝玉效果
					LUA_Call(string.format([[
						Clear_XSCRIPT()
							Set_XSCRIPT_Function_Name( "FiveElementsJadeSwitch" )
							Set_XSCRIPT_ScriptID( 880039 )
							Set_XSCRIPT_Parameter( 0, %d ) 
							Set_XSCRIPT_ParamCount( 1 )
						Send_XSCRIPT()
					]],JadeIndex));延时(500)
					LUA_Call("setmetatable(_G, {__index = WuhunQuest_Env});WuhunQuest_Bn1Click()");延时(500)
					break
				end
			else
				--替换刷出来的宝玉效果
				LUA_Call(string.format([[
					Clear_XSCRIPT()
						Set_XSCRIPT_Function_Name( "FiveElementsJadeSwitch" )
						Set_XSCRIPT_ScriptID( 880039 )
						Set_XSCRIPT_Parameter( 0, %d ) 
						Set_XSCRIPT_ParamCount( 1 )
					Send_XSCRIPT()
				]],JadeIndex));延时(500)
			end
		else
			break
		end
	end
end

function UpDateWashBaoYu()
	while true do 
		local BaoYuPercent = GetUpJade()
		local nMoney = tonumber(LUA_取返回值("return Player:GetData('MONEY')+Player:GetData('MONEY_JZ')"))
		local CailiaoNum = 获取背包物品数量("玉华灵泉")
		local percent = GetJadePercent(BaoYuPercent[1]["name"])
		if nMoney >= 10000 and CailiaoNum >= 5 and percent < 100 then
			NPC二级对话(BaoYuPercent[1]["name"]);延时(1000)
			WashBaoYu(BaoYuPercent[1]["idx"])
		else
			屏幕提示("材料不足，无法再淬洗！")
			break
		end
		if #BaoYuPercent == 0 then
			break
		end
	end
end

--取钱物品寻路
function MainWashBaoYu()
	取出物品("玉华灵泉", -1)
	取出物品("金币", -1)
	while true do
		跨图寻路("凤鸣镇", 115, 200)
		if 获取人物属性(29) == 1 then
			等待过图完毕()
		end
		if 对话NPC("杜钏灵") == 1 then
			break
		end
	end
	NPC二级对话("五行宝玉淬洗")延时(500)
	UpDateWashBaoYu()
	存物品("玉华灵泉","",0,0,0)
end
MainWashBaoYu()