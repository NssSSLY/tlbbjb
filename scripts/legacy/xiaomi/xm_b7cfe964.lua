-- 来自 新建文件夹/小蜜文本/套餐/60套餐/5洗珍兽成长.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})


珍兽名字 = "蛋蛋鸡宝宝"		--填你宝宝的名字，不要把引号去掉
卷轴名字 = "高级珍兽还童卷轴"	--填你要用的卷轴类型，不要把引号去掉

---------------------------------------------------以下勿动------------------------------------------------

function 友情提示(text,...)
	local strCode = string.format(text,...)
	LUA_Call(string.format([[
		setmetatable(_G, {__index = DebugListBox_Env})
		str= "#e0000ff".."【V信:Moto96520出文本定制文本】".."#eFF0000".."%-88s"
		DebugListBox_ListBox:AddInfo(str)
		--橙色 #e0000ff#u#g0ceff3
		--蓝色 #e0000ff#g28f1ff
		--#Y
	]], strCode))
end



function 查询珍兽成长率(珍兽名称)
友情提示("珍兽查询成长率:"..珍兽名称)
       LUA_Call(string.format([[
	for i=0, 9 do
		if Pet:IsPresent(i) then
					local Petchengzhanglv = Pet : GetGrowRate(i);
                     local PetName=Pet:GetName(i)

                      if PetName==PetDoName then
						if tonumber(Petchengzhanglv) < 500 then
								local hid,lid = Pet:GetGUID(i);
								PushDebugMessage("资质鉴定珍兽成长:"..PetName)
                             Clear_XSCRIPT();
                             Set_XSCRIPT_Function_Name("OnInquiryForGrowRate");
                             Set_XSCRIPT_ScriptID(1050);
                             Set_XSCRIPT_Parameter(0,hid);
                             Set_XSCRIPT_Parameter(1,lid);
                             Set_XSCRIPT_ParamCount(2);
                             Send_XSCRIPT();   
					end
			end
         end
	end	
	]], 珍兽名称))
end


function 查询所有珍兽成长率()
	友情提示("查询所有珍兽成长率")
	LUA_Call(string.format([[
		for i=0, 9 do
			if Pet:IsPresent(i) then
				local Petchengzhanglv = Pet : GetGrowRate(i);
				local PetName=Pet:GetName(i)
				--PushDebugMessage(Petchengzhanglv)
				if tonumber(Petchengzhanglv) < 500 then
					local hid,lid = Pet:GetGUID(i);
					PushDebugMessage("资质鉴定珍兽成长:"..PetName)
					Clear_XSCRIPT();
					Set_XSCRIPT_Function_Name("OnInquiryForGrowRate");
					Set_XSCRIPT_ScriptID(1050);
					Set_XSCRIPT_Parameter(0,hid);
					Set_XSCRIPT_Parameter(1,lid);
					Set_XSCRIPT_ParamCount(2);
					Send_XSCRIPT();   
				end
			end
		end	
	]]))
end






function 放生珍兽(aaaa)
	local nIndex =  LUA_取返回值(string.format([[

	for i=0, 9 do
		if Pet:IsPresent(i) then
			local strName=Pet:GetName(i)
			PushDebugMessage(strName)
			--成长率
			local strTbl = {"普通","优秀","杰出","卓越","完美"};
			local Petchengzhanglv = Pet : GetGrowRate(i);
			local nGrowLevel = Pet : GetPetGrowLevel(i,tonumber(Petchengzhanglv));
			if(nGrowLevel >= 0) then
			nGrowLevel = nGrowLevel + 1;
			nGrowLevelname=strTbl[nGrowLevel]
			else
			nGrowLevelname="未知"
			Petchengzhanglv=""
			end
			--PushDebugMessage(nGrowLevel..nGrowLevelname..strName)
			if strName == "%s" and nGrowLevel<= tonumber(%d) then
							  PushDebugMessage("放生珍兽:"..strName.."|成长率"..nGrowLevelname)
							   Pet : Go_Free(i)
			end
		end
	end
			return -1
	]], aaaa,5), "n")
	return nIndex
end




function 还童珍兽(aaaa,材料)
	if 获取背包物品数量(材料)<=0 then
		return -1
	end
	材料位置=获取背包物品位置(材料)-1
	local nIndex =  LUA_取返回值(string.format([[


		for i=0, 10-1 do
		if Pet:IsPresent(i) then
			local strName=Pet:GetName(i)
		--PushDebugMessage(strName)
		--成长率
		local strTbl = {"普通","优秀","杰出","卓越","完美"};
		local Petchengzhanglv = Pet : GetGrowRate(i);
		local nGrowLevel = Pet : GetPetGrowLevel(i,tonumber(Petchengzhanglv));
		if(nGrowLevel >= 0) then
		  nGrowLevel = nGrowLevel + 1;
		nGrowLevelname=strTbl[nGrowLevel]
		else
		nGrowLevelname="未知"
		Petchengzhanglv=""
		end
		--PushDebugMessage(nGrowLevel..nGrowLevelname..strName)
		if strName == "%s" and nGrowLevel < tonumber(%d) then
						  PushDebugMessage("放生珍兽:"..strName.."|成长率        "..nGrowLevelname)
						   Pet : SkillStudy_Do(2, i, %d)
			end
		end
		end
				return -1
	]], aaaa,5,材料位置), "n")
	return nIndex
end





for i=1,9999 do
	取出物品("金币")	
	跨图寻路("洛阳",275,297)
	查询所有珍兽成长率()
	延时(700)
	if 还童珍兽(珍兽名字,卷轴名字) == -1 then
		break
	end	
	延时(500)
end




