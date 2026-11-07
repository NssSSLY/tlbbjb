-- 来自 新建文件夹/小蜜文本/其他类型文本/000换交子500(1).lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
function 晴天_金换交子(交子数量)  
	交子数量=交子数量*10000
	if tonumber(获取人物信息(52))>=交子数量 then
			屏幕提示("当前人物交子:"..交子数量.."|大于设定跳过任务")
			延时(1000)
			--存物品("金币")  
		return
	end
	取出物品("金币",交子数量)  
	if tonumber(获取人物信息(45))<=交子数量- tonumber(获取人物信息(52)) then
		兑换交子数量 =tonumber(获取人物信息(45))
		else
		兑换交子数量= 交子数量-  tonumber(获取人物信息(52)) 
	end
	屏幕提示("兑换交子数量:"..兑换交子数量)
	if  string.find("洛阳|大理|苏州",获取人物信息(16)) then
		屏幕提示("兑换交子数量:"..兑换交子数量)
	else
		延时(1000)
		跨图寻路("洛阳",349,249)
	end
	LUA_Call(string.format([[	
	jiaozi =%d
	local holdMoney = Player:GetData( "MONEY" )
	if holdMoney < jiaozi then
		return
	end
	Clear_XSCRIPT( )
		Set_XSCRIPT_Function_Name( "DoMoneyToJiaozi" )
		Set_XSCRIPT_ScriptID( 800119 )
		Set_XSCRIPT_Parameter( 0, jiaozi )
		Set_XSCRIPT_ParamCount( 1 )
	Send_XSCRIPT( )
	]], 兑换交子数量), "n")
	--存物品("金币")  
	延时(1000)
end

晴天_金换交子(500) 