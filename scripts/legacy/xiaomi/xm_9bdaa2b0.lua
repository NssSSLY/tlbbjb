-- 来自 新建文件夹/小蜜文本/1洗普通龙纹/重洗龙纹火.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})

function 小蜜_友情提示(text,...)
	local strCode = string.format(text,...)
	LUA_Call(string.format([[
		setmetatable(_G, {__index = DebugListBox_Env})
		str= "#e0000ff".."【小蜜提示】".."#eFF0000".."%-88s"
		DebugListBox_ListBox:AddInfo(str)
	]], strCode))
end

function 小蜜_取背包物品数量(物品列表,是否绑定)
	if 是否绑定 ==0 or 是否绑定 == nil then
		tbangding =10
	elseif  是否绑定 ==1 then
		tbangding = 0
	elseif  是否绑定 ==2 then
		tbangding = 1
	end
	local tem = LUA_取返回值(string.format([[
		tem = 0
		for i= 0, 59 do
			tbangding =tostring("%s")
			ttname = "%s"
			local theAction=EnumAction(i,"packageitem")
			local GetName=theAction:GetName()
			
			local Status=GetItemBindStatus(i);
			if GetName~=nil and GetName ~="" then
				if string.find(ttname,GetName ,1,true) then
					if string.find(tbangding,tostring(Status)) then
						local szItemNum =theAction:GetNum();
						tem=tem+szItemNum
					end	
				end
			end
		end	
		return tem
			]],tbangding,物品列表))
	return tonumber(tem)		
end
		
		
function 小蜜_龙纹重洗(index)
	LUA_Call(string.format([[
		local atime =DataPool:GetServerDayTime()
		if atime >= 20220701 then
			return
		end
		m_Equip_Idx=%d
		Clear_XSCRIPT();
			Set_XSCRIPT_Function_Name("Lw_PropertyReset");
			Set_XSCRIPT_ScriptID(809273);
			Set_XSCRIPT_Parameter(0,m_Equip_Idx);
			Set_XSCRIPT_ParamCount(1);
		Send_XSCRIPT();
		 ]], index))
end


function 小蜜_龙纹确定(序号)
	LUA_Call(string.format([[
			 		Clear_XSCRIPT();
			Set_XSCRIPT_Function_Name("DoRefreshLw_Property");
			Set_XSCRIPT_ScriptID(809273);
			Set_XSCRIPT_Parameter(0,%d);
			Set_XSCRIPT_Parameter(1,0);
			Set_XSCRIPT_ParamCount(2);
		Send_XSCRIPT();
		 ]], 序号))
end

		
		
function 小蜜_取龙纹重洗后重的属性()
 local isWQ = LUA_取返回值(string.format([[
		AAA = DataPool:Lua_GetRecoinNum();
	local str = ""
	for i = 0, AAA-1 do
		local tempstr = DataPool :Lua_GetRecoinEnumAttr(i)
		if string.find(tempstr, "#{") then
			local left = string.find(tempstr, "#{")
			local left2 = string.find(tempstr, "}")
			strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))	
		end 
			str = str..strTemp.."|"
	end
	return  str
				 ]], "s"))
	return tostring(isWQ) 
end
		
function 小蜜_取龙纹重洗后重的属性条数()
	local isWQ = LUA_取返回值(string.format([[		
		AAA = DataPool:Lua_GetRecoinNum();
		return AAA
				 ]], "n"))
	return tonumber(isWQ) 
end



-------------------------------------------------------------------------


不要属性=
{ 
"内功攻击",
"外功攻击",
"灵气",
"力量",
"内功防御",
"外功防御",
"定力",
"气上限",
}

		
		
		
		
		
			
function 小蜜_自动龙纹极品重洗(总条数,不要条数)
		跨图寻路("金陵",368,423);延时(1500)
		序号 = 获取背包物品位置("龙纹")-1
		小蜜_友情提示("序号"..序号)
		
		if tonumber(序号) < 0 then
			return
		end

	while  true do
		if  获取背包物品数量("净云水",1) < 7 then
			小蜜_友情提示("净云水少于7个停止")
			return
		end	
		local 洗后当前条数 = 小蜜_取龙纹重洗后重的属性条数()
		屏幕提示("洗后的条数"..洗后当前条数)
		延时(500)
		if 洗后当前条数 >=总条数 then
			重洗后的属性= 小蜜_取龙纹重洗后重的属性()
			小蜜_友情提示(重洗后的属性)
			条数 = 0
			for i=1,#不要属性 do
				if string.find(重洗后的属性,不要属性[i]) then
					条数=条数+1
				end
			end
			小蜜_友情提示("不要属性条数:"..条数)
			延时(1000)
			if tonumber(条数) <= 不要条数 then
				小蜜_龙纹确定(序号)
				return
			end	
		end
		小蜜_龙纹重洗(序号)
		延时(1000)
	end
end
-------------------------------------------------------------------------------------------
要属性=
{ 
"血上限",
"火攻击",
"体力",
"所有属性",
}

function 小蜜_自动龙纹冰(总条数,要条数)
		跨图寻路("金陵",368,423);延时(1500)
		序号 = 获取背包物品位置("龙纹")-1
		小蜜_友情提示("序号"..序号)
		
		if tonumber(序号) < 0 then
			return
		end

	while  true do
		if  获取背包物品数量("净云水",1) < 7 then
			小蜜_友情提示("净云水少于7个停止")
			return
		end	
		local 洗后当前条数 = 小蜜_取龙纹重洗后重的属性条数()
		屏幕提示("洗后的条数"..洗后当前条数)
		延时(500)
		if 洗后当前条数 >=总条数 then
			重洗后的属性= 小蜜_取龙纹重洗后重的属性()
			小蜜_友情提示(重洗后的属性)
			条数 = 0
			for i=1,#要属性 do
				if string.find(重洗后的属性,要属性[i]) then
					条数=条数+1
				end
			end
			小蜜_友情提示("要属性条数:"..条数)
			延时(1000)
			if tonumber(条数) >= 要条数 then
				小蜜_龙纹确定(序号)
				return
			end	
		end
		小蜜_龙纹重洗(序号)
		延时(1000)
	end
end





--7条属性中，有血,火攻,体力,所属就会停止
小蜜_自动龙纹冰(7,4)  
