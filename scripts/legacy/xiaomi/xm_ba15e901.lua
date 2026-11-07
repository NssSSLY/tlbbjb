-- 来自 新建文件夹/小蜜文本/套餐/60套餐/5洗龙纹_小号.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})


净云水类型 = 1			--0为全用 1仅使用绑定



------------------------------------友情提示-------------------------------------------------
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



------------------------------------取下龙纹-------------------------------------------------

function 取下龙纹()
     for i=1,5 do
         LUA_Call ("MainMenuBar_SelfEquip_Clicked();")
         延时 (1000)
         if 窗口是否出现("SelfEquip")==1 then   --同组命令 等待窗口出现()
              LUA_Call ("SelfEquip_Equip_Click(25,0);")
              延时 (1000)
              if LUA_取返回值("return EnumAction(19,'equip'):GetID();")=="0" then  --检测脱下装备成功
                   LUA_Call("setmetatable(_G, {__index = SelfEquip_Env});SelfEquip_CloseFunction();")      
                   延时(500)  
                   return 1   
              end
         end      
     end
     LUA_Call("setmetatable(_G, {__index = SelfEquip_Env});SelfEquip_CloseFunction();")      
     延时(500) 
     if LUA_取返回值("return EnumAction(20,'equip'):GetID();")=="0" then
          return 1   
     else  
          return 0
     end     
end

------------------------------------装备龙纹-------------------------------------------------

function 装备龙纹()
     for i=1,5 do
         if 窗口是否出现("EquipLingPai_ShengJie") ==1 then 
	          	关闭窗口("EquipLingPai_ShengJie")
		 elseif 窗口是否出现("EquipLingPai_Star") ==1 then 
				关闭窗口("EquipLingPai_Star")
		 elseif 窗口是否出现("EquipLingPai_OperatingSJ") ==1 then 
				关闭窗口("EquipLingPai_OperatingSJ")				
             else
              右键使用物品("龙纹",1)     --参数2:为使用次数
         end
         延时(1000)
         if tonumber(LUA_取返回值("return EnumAction(20,'equip'):GetID();"))>0 then  --装备成功
              break   
         end
     end
end

------------------------------------取背包净云水-------------------------------------------------

function 取背包物品数量(物品列表)
	--0为使用全部
	--1为仅使用绑定
	if 净云水类型 ==0 or 净云水类型 == nil then
		tbangding =10
	elseif  净云水类型 ==1 then
		tbangding = 1
	--elseif  净云水类型 ==2 then
	--	tbangding = 0
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

------------------------------------龙纹重洗-------------------------------------------------
	
		
function 龙纹重洗(index)
	LUA_Call(string.format([[
		m_Equip_Idx=%d
		Clear_XSCRIPT();
		Set_XSCRIPT_Function_Name("Lw_PropertyReset");
		Set_XSCRIPT_ScriptID(809273);
		Set_XSCRIPT_Parameter(0,m_Equip_Idx);
		Set_XSCRIPT_ParamCount(1);
		Send_XSCRIPT();
		 ]], index))
end


------------------------------------点击确定-------------------------------------------------

function 龙纹确定(序号)
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

		
------------------------------------龙纹重洗后属性-------------------------------------------------

		
function 取龙纹重洗后重的属性()
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


------------------------------------龙纹重洗后条数-------------------------------------------------


function 取龙纹重洗后重的属性条数()
	local isWQ = LUA_取返回值(string.format([[		
		AAA = DataPool:Lua_GetRecoinNum();
		return AAA
				 ]], "n"))
	return tonumber(isWQ) 
end




------------------------------------取号上金币+交子数-------------------------------------------------


function 取所有钱()
        所有钱=获取人物信息(52) +获取人物信息(45)
        return 所有钱
end








function 全自动洗龙纹(属性,属性2,属性3,属性4)
	取出物品("净云水")
	if 取背包物品数量("净云水") < 7 or 取所有钱() < 5*10000 then
		友情提示("金币或者材料不足，等等再来洗吧")
	end
	友情提示("材料充足，开始搞")
	取下龙纹()
	取出物品("金币")
	跨图寻路("凤鸣镇",125,200);延时(1500)
	序号 = 获取背包物品位置("龙纹")-1
	
	while true do
		if 取背包物品数量("净云水") < 7 then
			友情提示("净云水不够了，下次再洗吧")
			break
		end
		--开始洗
		龙纹重洗(序号)
		local 洗后当前条数 = 取龙纹重洗后重的属性条数()
		延时(500)
		友情提示("重洗后龙纹 "..洗后当前条数.." 条属性，下面开始判断属性是否需要")
		--条数是否满足
		if 洗后当前条数 >= 5 then	
			--再看属性是否满足
			重洗后的属性= 取龙纹重洗后重的属性()			
			if string.find(重洗后的属性,属性) and  string.find(重洗后的属性,属性2) and  string.find(重洗后的属性,属性3) and  string.find(重洗后的属性,属性4) then
				友情提示("属性满足，准备确定 |"..洗后当前条数.."条属性| "..重洗后的属性)
				延时(500)
				龙纹确定(序号)
				延时(500)
				break
			else
				友情提示("属性不满足，重洗 |"..重洗后的属性)
			end		
		else
			友情提示("属性条数低于5条，重洗")
			延时(1000)
		end		
	end
	--存水存钱
	装备龙纹()
	延时(500)	
	友情提示("已洗完，开始存物品存钱")
	存物品("净云水")
	延时(500)
	存物品("金币")
end



function 根据门派自动洗()	
	
	
	local 人物名称,门派,PID,远近攻击,内外攻击,角色账号,门派地址,技能状态,性别=获取人物属性()
	
------------------前4条满足，5-7条满足一条就会停止，例如峨眉出血上限、体力、所有属性、冰攻击、毒攻击就会停止；毒攻击换成火攻击也会停止--------------
	if 门派 == "峨嵋" or 门派 == "天山" or 门派 == "桃花岛" then
		全自动洗龙纹("血上限","体力","所有属性","冰攻击")
	elseif 门派 == "逍遥" or 门派 == "绝情谷" or 门派 == "明教" then
		全自动洗龙纹("血上限","体力","所有属性","火攻击")
	elseif 门派 == "天龙" or 门派 == "鬼谷" or 门派 == "武当" or 门派 == "少林" or 门派 == "慕容" then
		全自动洗龙纹("血上限","体力","所有属性","玄攻击")
	elseif 门派 == "唐门" or 门派 == "星宿" or 门派 == "丐帮" then
		全自动洗龙纹("血上限","体力","所有属性","毒攻击")
	end
	
end



根据门派自动洗()


