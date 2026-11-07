-- 来自 新建文件夹/小蜜文本/套餐/40套餐/神器8星.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
------------------------------------------------------------------------------------------------------------------------------------

local 神器名字 ="大魏长歌|雷鸣离火扇|秋水无痕剑|碧海银涛环|奕天破邪杖|天星耀阳环|含光弄影剑|万仞龙渊剑|雷鸣离火扇|碎情雾影环|赤焰九纹刀|斩忧断愁枪|转魂灭魄钩|星移无痕剑|凌霄玉琼弩|炽焰九龙刀|绝情裂影环|忘忧销魂枪|法天辟邪杖|星移月动剑|星云聚日环|灭魂轮回钩|九转龙泉剑|天光流影剑|天雷真火扇|九霄华琼弩|大夏龙雀|大商尘影|大周岚夜|大秦锋镝|大汉弘纲|大晋星痕|大隋凝霜|大唐昆岳|大宋君岑|大燕韵章|大梁辟天|九霄焱阳|洪荒龙舞|达摩一叹|无相绝踪|万世枯荣|太古飘翎|大衍天玄|末世王权|倚天长生|六道黄泉|天影天诛|鬼谷：太虚归星杖|少林：奕天破邪杖|天龙：天星耀阳环|峨嵋：含光弄影剑|武当：万仞龙渊剑|逍遥：雷鸣离火扇|天山：碎情雾影环|明教：赤焰九纹刀|丐帮：斩忧断愁枪|星宿：转魂灭魄钩|慕容世家：星移无痕剑|唐门：凌霄玉琼弩|鬼谷：太虚归星杖|玉法玄穹"



function 晴天_友情提示(text,...)
	local strCode = string.format(text,...)
	LUA_Call(string.format([[
		setmetatable(_G, {__index = DebugListBox_Env})
		str= "#e0000ff".."【晴天QQ103900393提示】".."#eFF0000".."%-88s"
		DebugListBox_ListBox:AddInfo(str)
	]], strCode))
end
function 晴天_窗口确定()
	if  窗口是否出现("MessageBox_Self")==1 then
		晴天_友情提示("窗口确定")
		LUA_Call(" setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
		延时(2000)
	end
end

function 晴天_窗口关闭(strWindowName)
      if 窗口是否出现(strWindowName)==1 then
	    LUA_Call(string.format([[
	            setmetatable(_G, {__index = %s_Env}) this:Hide()  
	  ]], strWindowName))  
		延时(2000)
	  end
end


function 晴天_写角色配置项(AAA, BBB, CCC)
    local 名字= 获取人物信息(12)
    local 路径=string.format("C:\\天龙小蜜\\角色配置\\%s.ini",名字)
	if AAA~=nil and BBB~=nil and CCC~=nil  then
		晴天_友情提示("写角色配置项|"..AAA.."|"..BBB.."|"..CCC);延时(200)
		写配置项(路径,AAA,BBB,CCC);延时(200)
	end
end

function 晴天_读角色配置项(AAA, BBB)
    local 名字= 获取人物信息(12)
    local 路径=string.format("C:\\天龙小蜜\\角色配置\\%s.ini",名字)
    local tem =读配置项(路径,AAA,BBB)
	if tem ~=nil then
		晴天_友情提示(AAA.."|"..BBB.."=="..tem);延时(500)
		else
		return 0
	end
	return tem
end

function  晴天_取身上装备持久(aaa)
	local tem = LUA_取返回值(string.format([[ 
		return EnumAction(%d,"equip"):GetEquipDur()
	]], aaa))
		return  tonumber(tem)
end

function  晴天_取身上装备ID(aaa)
	local tem = LUA_取返回值(string.format([[ 
		return EnumAction(%d,"equip"):GetID()
	]], aaa))
	return  tonumber(tem)
end

function 晴天_取身上装备名字(aaa)
	 local aaa=  LUA_取返回值(string.format([[ 
		return EnumAction(%d,"equip"):GetName()
	]], aaa))
	return tostring(aaa)
end

function  晴天_取背包装备等级(index)
local aaa=  LUA_取返回值(string.format([[ 
		return LifeAbility : Get_Equip_Level(%d);
	]], index))
	return tonumber(aaa)
end

function  晴天_取身上武魂生命()--300最大
       if  tonumber(晴天_取身上装备ID(18) )>0 then
			return  到数值(LUA_取返回值(string.format([[ 
		return DataPool:GetKfsData("LIFE")
	]])))
	else
		return -1
    end
end


---------------------------------------------------------必备函数-----------------------------------------------------------------
--------------------------------------------------装备相关------------------------------------------------
local SelfEuipList =
{
	[1]  = { name="武器", downIndex=11,  equipIndex=0, equipName="" },    --- 武器
	[2]  = { name="护腕", downIndex=3, equipIndex=14, equipName=""},    --- 护腕
	[3]  = { name="戒指上", downIndex=7,  equipIndex=6,equipName=""  },    --- 戒指（上）
	[4]  = { name="戒指下", downIndex=8,  equipIndex=11, equipName=""},    --- 戒指（下）
	[5]  = { name="护符上", downIndex=9,  equipIndex=12, equipName=""},    --- 护符（上）
	[6]  = { name="护符下", downIndex=10, equipIndex=13, equipName=""},    --- 护符（下）
	[7]  = { name="衣服", downIndex=12,  equipIndex=2,equipName=""  },    --- 衣服
	[8]  = { name="帽子", downIndex=1,  equipIndex=1, equipName="" },    --- 帽子
	[9]  = { name="护肩", downIndex=2, equipIndex=15,equipName="" },    --- 肩膀
	[10] = { name="手套", downIndex=4,  equipIndex=3, equipName="" },    --- 手套
	[11] = { name="腰带", downIndex=5,  equipIndex=5, equipName="" },    --- 腰带
	[12] = { name="鞋子", downIndex=6,  equipIndex=4, equipName="" },    --- 鞋子
	[13] = { name="项链", downIndex=13,  equipIndex=7,equipName=""  },    --- 项链
	[14] = { name="暗器", downIndex=14, equipIndex=17, equipName=""},    --- 暗器
	[15] = { name="龙纹", downIndex=25, equipIndex=19,equipName="" },    --- 龙纹
	[16] = { name="武魂", downIndex="", equipIndex=18,equipName="" },    --- 武魂
	[17] = { name="令牌", downIndex=16, equipIndex=20,equipName="" },    --- 令牌
}



function 晴天_取下装备获取名字(装备位置名称)
	for i =1,17 do
		if SelfEuipList[i].name == 装备位置名称 then
			晴天_友情提示("准备取下装备位置:"..装备位置名称)
				local 装备持久 =晴天_取身上装备持久(SelfEuipList[i].equipIndex)
				if 装备持久 <= 0 then
					晴天_友情提示("装备持久不够,不取下")
					return 0
				end
				if 晴天_取身上装备ID(SelfEuipList[i].equipIndex) == 0  then
					return 0
				end
				
				for k =1, 10 do	
					local  装备名称 = 晴天_取身上装备名字(SelfEuipList[i].equipIndex)
					if  窗口是否出现("SelfEquip")~=1  then
						LUA_Call ("MainMenuBar_SelfEquip_Clicked();");延时(2000)
					end
					LUA_Call(string.format([[ setmetatable(_G, {__index = SelfEquip_Env});SelfEquip_Equip_Click(%d,0)]], SelfEuipList[i].downIndex))
					延时(5000)
					if  晴天_取身上装备ID(SelfEuipList[i].equipIndex) == 0 then
						晴天_窗口关闭("SelfEquip")
						return 装备名称
					end	
				end	
				return 0
			end
		end
end

function 晴天_穿上装备(装备位置名称,装备名称)
     if 装备名称==""  then
		晴天_友情提示("参数错误,晴天_穿上装备")
		return
	end
	if 获取背包物品数量(装备名称)<=0 then
			晴天_友情提示("没有装备无法使用,晴天_穿上装备")
			return
	end	
	for i =1,17 do
		if SelfEuipList[i].name == 装备位置名称 then
			for k =1, 5 do
			右键使用物品(装备名称);延时(2000)
				if  晴天_取身上装备ID(SelfEuipList[i].equipIndex) > 0 then
					晴天_友情提示(" 晴天成功穿上"..装备名称.."|在位置:"..装备位置名称)
					break   
				end
			end
		end
	end
	--晴天_友情提示(装备位置名称..":位置错误")
end

function  晴天_取背包神器通灵等级(Index)
	local tem=  LUA_取返回值(string.format([[ 
		local nByQual = tonumber(PlayerPackage:GetSuperWeaponQual(%d));
		return nByQual
	]], Index))
	return tonumber(tem)
end

function  晴天_取背包神器契合材料数量(Index)
	local tem=  LUA_取返回值(string.format([[ 
		local nMaterialCount =tonumber (PlayerPackage:GetSuperWeaponAdvanceMaterialCount(%d));
		return nMaterialCount
	]], Index))
	return tonumber(tem)
end

function  晴天_神器进阶(Index)
	LUA_Call(string.format([[ 
	Clear_XSCRIPT()
		Set_XSCRIPT_Function_Name("DoSuperWeaponStartUpAction")
		Set_XSCRIPT_ScriptID(890009)
		Set_XSCRIPT_Parameter(0, 3)
		Set_XSCRIPT_Parameter(1, %d)
		Set_XSCRIPT_Parameter(2, -1);
		Set_XSCRIPT_ParamCount(3)
	Send_XSCRIPT()
	]], Index))
end

function 晴天_自动处理聚灵石()
	晴天_友情提示("全自动处理聚灵石")
	for i =1, 5 do
		取出物品("聚灵石")
		if 获取背包物品数量("聚灵石")<= 0 then
			取出物品("玄兵石")
			if 获取背包物品数量("玄兵石")< 3 then
				存物品("玄兵石")
				break
			end
			跨图寻路("金陵",302,373)
			延时(2000)
			对话NPC("无崖子")
			延时(2000)
			 NPC二级对话("使用玄兵石打造聚灵石")
			延时(2000)
			任务_完成()   	
			延时(55000)
		else
			晴天_友情提示("背包中有聚灵石")
			延时(1000)
			break
		end
	end
end


function 晴天_自动处理女娲石()
	晴天_友情提示("全自动处理女娲石")
	for i =1, 5 do
		取出物品("女娲石")
		取出物品("玄兵石")
		if 获取背包物品数量("女娲石")<= 0 then
			取出物品("玄兵石")
			if 获取背包物品数量("玄兵石")< 3 then
				存物品("玄兵石")
				return false
			end
			跨图寻路("金陵",302,373)
			延时(2000)
			对话NPC("无崖子")
			延时(2000)
			 NPC二级对话("凝练女娲石")
			延时(2000)
			NPC二级对话("请帮我凝练")
			延时(3000)
		else
			晴天_友情提示("背包中有女娲石,跳过任务")
			延时(1000)
			return true
		end
	end
	return false
end


function 晴天_自动处理女娲神石()
	晴天_友情提示("全自动处理女娲神石")
	for i =1, 5 do
		取出物品("女娲神石")
		取出物品("玄兵石")
		if 获取背包物品数量("女娲神石")<= 0 then
			取出物品("玄兵石")
			if 获取背包物品数量("玄兵石")<5 then
				存物品("玄兵石")
				return false
			end
			跨图寻路("金陵",302,373)
			延时(2000)
			对话NPC("无崖子")
			延时(2000)
			 NPC二级对话("凝练女娲神石")
			延时(2000)
			NPC二级对话("请帮我凝练")
			延时(3000)
		else
			晴天_友情提示("背包中有女娲石,跳过任务")
			延时(1000)
			return true
		end
	end
	return false
end


function  晴天_取神器是否契合(nIndex)
	local tem=  LUA_取返回值(string.format([[ 
		local nIndex =%d
		if nIndex < 0 then
			return 0
		end
	
	--	检测物品是否可契合
	local ret = LifeAbility : CheckSuperWeaponCanAdvance(nIndex)
	if ret < 0 then
		local nByQual = tonumber(PlayerPackage:GetSuperWeaponQual(nIndex));
		if nByQual > 80 then
			--PushDebugMessage("#{SQSX_120806_61}")
			return 0
		end

		--PushDebugMessage("#{SQSX_120806_23}")
		return 0
	end
	--	检测物品等级
	local nEquipLevel = LifeAbility : Get_Equip_Level(nIndex);
	if nEquipLevel ~= 86 and nEquipLevel ~= 96 and nEquipLevel ~= 102 then
		--PushDebugMessage("#{SQSX_120806_23}")
		return 0
	end
	
	return 1
	]], nIndex))
	return tonumber(tem)
end


function 晴天_神器通灵()
	local 神器通灵=tonumber( 晴天_读角色配置项("超级晴天", "神器通灵"))
	if 神器通灵 == 1 then
		存物品("金币")
		存物品("玄兵石")	
		晴天_友情提示("神器已经通灵")
		return 
	end

	if not string.find(神器名字,晴天_取身上装备名字(0)) then
		晴天_友情提示("你当前的神器不是可通灵神器|跳过任务")
		return
	end	
	

					
	local 装备名称= 晴天_取下装备获取名字("武器")
	延时(2000) 
	取出物品("金币",9999999)
	
	if 装备名称 == 0 then
             return -1
		else
	   LPindex=获取背包物品位置(装备名称)-1	
	end
	晴天_友情提示(装备名称)
	延时(2000)
	if 晴天_取神器是否契合(LPindex) == 0 then
		晴天_自动处理聚灵石()
		聚灵石背包位置 =获取背包物品位置("聚灵石")-1	
		神器背包位置=获取背包物品位置(装备名称)-1	
		if 聚灵石背包位置<0 or 神器背包位置<0 then
			晴天_友情提示("材料不足,跳过任务")
			晴天_穿上装备("武器",装备名称)  
			return
			else
			晴天_友情提示("神器通灵,神器背包位置[%d],聚灵石背包位置[%d]",神器背包位置,聚灵石背包位置)
		end	
		
		跨图寻路("金陵",302,373)
		
		LUA_取返回值(string.format([[ 
		 	Clear_XSCRIPT()
				Set_XSCRIPT_Function_Name("DoSuperWeaponStartUpAction")
				Set_XSCRIPT_ScriptID(890009)
				Set_XSCRIPT_Parameter(0, 1)
				Set_XSCRIPT_Parameter(1, %d)
				Set_XSCRIPT_Parameter(2, %d)
				Set_XSCRIPT_Parameter(3, 25)--hook获取
				Set_XSCRIPT_ParamCount(4)
			Send_XSCRIPT()
			]], 神器背包位置,聚灵石背包位置))
		延时(2000)
	end
	
	if 晴天_取神器是否契合(LPindex) == 1 then
		晴天_写角色配置项("超级晴天", "神器通灵",1) 
	end
	
	晴天_穿上装备("武器",装备名称)  
	存物品("金币")
	存物品("玄兵石")
end
function 晴天_取背包物品位置名称(index)
	local tem = LUA_取返回值(string.format([[
		local GetName = '空'
		local theAction=EnumAction(%d,"packageitem")
		if theAction:GetID()> 0 then
			GetName =theAction:GetName()
		end	
		return GetName
		]],index))
	return tostring(tem)
end
		
---契合带进阶  61-69 90+的 71-79 为102级的
function 晴天_神器契合()
	晴天_友情提示("神器契合")
	if not string.find(神器名字,晴天_取身上装备名字(0)) then
		晴天_友情提示("你当前的神器不是可通灵神器|跳过任务")
		return
	end	
	if tonumber(晴天_读角色配置项("超级晴天", "神器契合满级"))		==1 then
		晴天_友情提示("神器契合满级,跳过任务")
		--return
	end			
	local 装备名称= 晴天_取下装备获取名字("武器")
	if 装备名称 == 0 then
        return -1
	end
	local LPindex=获取背包物品位置(装备名称)-1	
	晴天_友情提示("装备名称[%s]装备位置[%d]",装备名称,LPindex)
	延时(2000)
	for  k =1, 20 do
		取出物品("金币",9999999)
		local 背包神器契合等级=晴天_取背包神器通灵等级(LPindex)
		晴天_友情提示("背包升级契合等级%d",背包神器契合等级);延时(1000)
		if 背包神器契合等级==81 then
			装备名称 =晴天_取背包物品位置名称(LPindex)
			晴天_友情提示("8星神器:%s",装备名称);延时(1000)
			break
		end	
		
		if 背包神器契合等级==69  then
			if 晴天_自动处理女娲石() then
				晴天_友情提示("开始进阶")
				晴天_神器进阶(LPindex)
				延时(2000)
				
			else
				break
			end
		end
	
		if 背包神器契合等级==79  then
			if 晴天_自动处理女娲神石() then
				晴天_友情提示("开始进阶")
				晴天_神器进阶(LPindex)
				延时(2000)
			else
				break
			end
		end		
		
		if 背包神器契合等级>=61 and 背包神器契合等级 < 69  then
			取出物品("玄兵石")
			取出物品("金币")
			晴天_友情提示("装备名称[%s]装备位置[%d]背包神器契合等级[%d]",装备名称,LPindex,背包神器契合等级)
			local 玄兵石数量 =获取背包物品数量("玄兵石")
			local 需要玄兵石数量 = 晴天_取背包神器契合材料数量(LPindex)
			if 玄兵石数量 < 需要玄兵石数量 then
				晴天_友情提示("玄兵石材料不足")
				延时(1000)
				break
			end
			
			跨图寻路("金陵",302,351)
			LUA_Call(string.format([[
				Clear_XSCRIPT()
					Set_XSCRIPT_Function_Name("DoSuperWeaponStartUpAction")
					Set_XSCRIPT_ScriptID(890009)
					Set_XSCRIPT_Parameter(0, 2)
					Set_XSCRIPT_Parameter(1, %d)
					Set_XSCRIPT_Parameter(2, 25)
					Set_XSCRIPT_ParamCount(3)
				Send_XSCRIPT()
				]] ,LPindex))  
			延时(1000)			
		end	
		
		if 背包神器契合等级>=71 and 背包神器契合等级 < 79  then
			取出物品("玄兵石")
			取出物品("金币")
			晴天_友情提示("装备名称[%s]装备位置[%d]背包神器契合等级[%d]",装备名称,LPindex,背包神器契合等级)
			local 玄兵石数量 =获取背包物品数量("玄兵石")
			local 需要玄兵石数量 = 晴天_取背包神器契合材料数量(LPindex)
			if 玄兵石数量 < 需要玄兵石数量 then
				晴天_友情提示("玄兵石材料不足")
				延时(1000)
				break
			end
			跨图寻路("金陵",302,351)
			LUA_Call(string.format([[
				Clear_XSCRIPT()
					Set_XSCRIPT_Function_Name("DoSuperWeaponStartUpAction")
					Set_XSCRIPT_ScriptID(890009)
					Set_XSCRIPT_Parameter(0, 2)
					Set_XSCRIPT_Parameter(1, %d)
					Set_XSCRIPT_Parameter(2, 25)
					Set_XSCRIPT_ParamCount(3)
				Send_XSCRIPT()
				]] ,LPindex))  
			延时(1000)			
		end	
	end
	
		--if 晴天_取背包神器通灵(LPindex) == 1 then
			--晴天_写角色配置项("超级晴天", "神器通灵",1) 
		--end
	晴天_穿上装备("武器",装备名称)  
	存物品("金币")
	存物品("玄兵石")
end






晴天_神器通灵()
晴天_神器契合()