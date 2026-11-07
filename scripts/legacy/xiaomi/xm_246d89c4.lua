-- 来自 新建文件夹/小蜜文本/小蜜文本/金先生-首次装备制作.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "sell", "item"})


取出材料列表="3级棉布|4级棉布|3级秘银|4级秘银|至尊秘银|至尊棉布|鉴定书10级|鉴定符10级|通用鉴定符10级"

装备合集="幻世圣巾|凶陌圣甲|幻世圣靴|幻世手套|幻世魔肩|幻世魔腕|步月|蝶恋|浅浪|横笛"

饰品=3 --1横笛浅浪 2横笛横笛 3横笛浅浪

local SelfEuipList =
{
	
	{ name="护腕", 等级=96,downIndex=3, equipIndex=14, 装备名称 ="幻世魔腕" ,材料="3级棉布",打造图 ="护腕打造图10级" ,鉴定符="鉴定书10级",身上星=7,背包星= 8},    --- 护腕
	{ name="护肩",等级=98, downIndex=2, equipIndex=15,装备名称 ="幻世魔肩" ,材料="3级棉布",打造图 ="护肩打造图10级" ,鉴定符="鉴定书10级" ,身上星=7,背包星= 8},    --- 护肩
	{ name="手套", 等级=96,downIndex=4,  equipIndex=3, 装备名称 ="幻世手套",装备名称2="凶陌圣掌",材料="4级棉布",打造图 ="手套打造图10级" ,鉴定符="鉴定书10级" ,身上星=7,背包星= 8},    --- 手套
	{ name="腰带",等级=92, downIndex=5,  equipIndex=5, 装备名称 ="步月" ,材料="3级棉布",打造图 ="腰带打造图10级" ,鉴定符="鉴定书10级" ,身上星=7,背包星= 8},     --- 腰带
	{ name="鞋子", 等级=94,downIndex=6,  equipIndex=4, 装备名称 ="幻世圣靴" ,材料="3级棉布",打造图 ="鞋子打造图10级" ,鉴定符="鉴定书10级" ,身上星=7,背包星= 8},     --- 鞋子
	{ name="衣服",等级=98,downIndex=12,  equipIndex=2,装备名称 ="凶陌圣甲" ,材料="4级棉布",打造图 ="衣服打造图10级" ,鉴定符="鉴定书10级" ,身上星=7,背包星= 8},     --- 衣服
	{ name="帽子", 等级=92,downIndex=1,  equipIndex=1, 装备名称 ="幻世圣巾" ,材料="4级棉布",打造图 ="帽子打造图10级" ,鉴定符="鉴定书10级" ,身上星=7,背包星= 8},    --- 帽子
	
	{ name="项链",等级=98, downIndex=13,  equipIndex=7,装备名称 ="蝶恋"  ,材料="3级秘银",打造图 ="项链打造图10级" ,鉴定符="鉴定符10级",身上星=7,背包星=8},    --- 项链
	{ name="护符上",等级=95, downIndex=9,  equipIndex=12, 装备名称 ="浅浪" ,材料="3级秘银",打造图 ="护符打造图10级" ,鉴定符="鉴定符10级",身上星=7,背包星= 8},    --- 护符（上）
	{ name="护符下", 等级=95,downIndex=10, equipIndex=13, 装备名称 ="浅浪",材料="3级秘银",打造图 ="护符打造图10级" ,鉴定符="鉴定符10级" ,身上星=7,背包星= 8},    --- 护符（下）
	{ name="戒指上",等级=95, downIndex=7,  equipIndex=6,装备名称 ="横笛" ,材料="3级秘银",打造图 ="戒指打造图10级" ,鉴定符="鉴定符10级",身上星=7,背包星= 8},    --- 戒指（上）
	{ name="戒指下", 等级=95,downIndex=8,  equipIndex=11, 装备名称 ="横笛" ,材料="3级秘银",打造图 ="戒指打造图10级" ,鉴定符="鉴定符10级",身上星=7,背包星= 8},    --- 戒指（下）
	
	--打造图很贵

	--打造图很贵
}





function 晴天_友情提示(text,...)
	local strCode = string.format(text,...)
	LUA_Call(string.format([[
		setmetatable(_G, {__index = DebugListBox_Env})
		str= "#e0000ff".."【晴天QQ103900393提示】".."#eFF0000".."%-88s"
		DebugListBox_ListBox:AddInfo(str)
		--橙色 #e0000ff#u#g0ceff3
		--蓝色 #e0000ff#g28f1ff
		--#Y
	]], strCode))
end

function 晴天_查找制作装备ID(name)
	local id = LUA_取返回值(string.format([[
		local name = '%s图样'
		local id = 0
		local num =	DataPool:GetPrescrList_Num()
		for i=1,num do
			local nPrescr = LifeAbility:GetPrescrList_Item_FromNum(i-1)
			local szPrescrName = DataPool:GetPrescrList_Item(nPrescr)
			if szPrescrName==name then
				id = nPrescr
				break
			end
		end
		return id
	]],name),"n",1)
	if tonumber(id)>0 then
		return tonumber(id)
	end
	return -1
end

function 进度条(ti)
	if not ti then
		ti =10
	end	
	local time1=os.time()
	local num1=LUA_取返回值("setmetatable(_G, {__index = ProgressBar_Env})if this:IsVisible()then return ProgressBar_Progress:GetProgress(1000)end return 1000","n",1)
	if num1~=1000 then
		延时(100)
		local num2=LUA_取返回值("setmetatable(_G, {__index = ProgressBar_Env})if this:IsVisible()then return ProgressBar_Progress:GetProgress(1000)end return 1000","n",1)
		while os.time()-time1<ti and num2~=1000 and num2~=num1 do
			延时(500)
			num1=num2	--刷新备份
			num2=LUA_取返回值("setmetatable(_G, {__index = ProgressBar_Env})if this:IsVisible()then return ProgressBar_Progress:GetProgress(1000)end return 1000","n",1)
		end
		if num2==1000 then 
			return true 	--进度条执行完成
		end
	end
	return false
end

function 制作装备(装备名字,材料名称,打造图名称)
	if 获取背包物品数量(材料名称) <1 then
		晴天_友情提示("材料不够:"..材料名称)
		return
	else
		材料位置=获取背包物品位置(材料名称)-1
	end

	if 获取背包物品数量(打造图名称) <1 then
		晴天_友情提示("打造图不够:"..打造图名称)
		return
	end
	坐骑_下坐骑();延时(500)
	local ID = 晴天_查找制作装备ID(装备名字)
	晴天_友情提示("ID ："..ID .."材料位置"..材料位置);延时(500)
	if  ID > 0 then
	LUA_Call(string.format([[ 
		AAA=%d
		BBB=%d
		ComposeItem_Begin(AAA,1,BBB)
		]],ID,材料位置))
		延时(1000)
		进度条(10)
	else
		晴天_友情提示("没有装备："..装备名字.."没有技能能或者未知")
	end	
end

function 晴天_鉴定装备(zhuangbei_name,jianding_name)
		--查找未鉴定装备
	for i=1,100 do
		local item = LUA_取返回值(string.format([[
				local i =%d
				local theAction = PlayerPackage:EnumItem("base",i-1)
				if theAction:GetID()~=0 and theAction:GetName()=='%s' then
					local num = PlayerPackage:GetSuperWeaponQual(i-1)
					if num==-1 then
						return i
					end
				end
				return -1
			]] ,i,zhuangbei_name),"n",1)
		if tonumber(item)>0 then				
				local 鉴定符位置= 获取背包物品位置(jianding_name) -1				
				if 鉴定符位置< 0 then
					--晴天_九州商会购买物品(jianding_name,20,200*10000,1)
					晴天_友情提示("鉴定符不够:"..jianding_name)
					return
				end
			LUA_取返回值("setmetatable(_G, {__index = Shop_Env})if this:IsVisible()then Booth_Close()end")
			LUA_取返回值("setmetatable(_G, {__index = YuanbaoShop_Env})if this:IsVisible()then YuanbaoShop_Close()end")
			LUA_取返回值(string.format([[
				setmetatable(_G, {__index = Packet_Env})
				Packet_Space_Line10_Row9_button:SetActionItem(PlayerPackage:EnumItem('base',%d):GetID())
				Packet_Space_Line10_Row10_button:SetActionItem(PlayerPackage:EnumItem('base',%d):GetID())
				Packet_Space_Line10_Row9_button:DoAction()
				Packet_Space_Line10_Row10_button:DoSubAction()
			]],鉴定符位置,i-1))
			延时(1000)
		end
	end	
end

function 晴天_取背包装备星星(序号)
	local tem =LUA_取返回值(string.format([[
		local equipQual =PlayerPackage:GetSuperWeaponQual(%d)
		return equipQual
		]], 序号), "n")
	return tonumber( tem)
end




function 晴天_取背包装备最大星星(name)
	  local tem= LUA_取返回值(string.format([[
		local star= 0
		local zhuangbei= "%s"
		for i=0, 99 do
			local theAction=EnumAction(i,"packageitem")
			local name=theAction:GetName()
			if theAction:GetID() ~= 0 then
				if string.find(zhuangbei,name,1,true) then
					local nemstar = PlayerPackage:GetSuperWeaponQual(i)
					if nemstar>star then
						star =nemstar
					end
				end
			end
		end	
		return  star
	    ]],name),"n")
	return tonumber(tem)
end

function 晴天_取背包装备最大星星位置(name)
	  local tem= LUA_取返回值(string.format([[
		local str= 0
		local k =-1
		local zhuangbei= "%s"
		for i=0, 99 do
			local theAction=EnumAction(i,"packageitem")
			local name=theAction:GetName()
			if theAction:GetID() ~= 0 then
				if string.find(zhuangbei,name,1,true) then
					local nemstar = PlayerPackage:GetSuperWeaponQual(i)
					if nemstar>str then
						str =nemstar
						k=i
					end
				end
			end
		end	
		return  k
	    ]],name),"n")
	return tonumber(tem)
end
	
function 晴天_取背包装备位置属性(位置)
	  local tem= LUA_取返回值(string.format([[
		local str = "晴天|"
		local theAction=EnumAction(%d,"packageitem")
		if theAction:GetID() ~= 0 then
			local num = theAction:GetEquipAttrCount()
			if num> 0 then
				for i = 0, num-1 do
					local tempstr = theAction:EnumEquipExtAttr(i)
					if string.find(tempstr, "#{") then
						local left = string.find(tempstr, "#{")
						local left2 = string.find(tempstr, "}")
						strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))..string.sub(tempstr, left2+3,-2)
					end 
						str = str..strTemp.."|"
				end
			end
		end
		return str
	    ]],位置),"n")
	return tem
end		
	
function 晴天_取背包装备属性位置(name,str)
	  local tem= LUA_取返回值(string.format([[
		local str= 0
		local k =-1
		local zhuangbei= "%s"
		local zhuangbeishuxing= "%s"
		for i=0, 99 do
			local theAction=EnumAction(i,"packageitem")
			if theAction:GetID() ~= 0 then
				local name=theAction:GetName()
				if zhuangbei==name then
					local str = ""
					local num = theAction:GetEquipAttrCount()
					if num> 0 then
						for i = 0, num-1 do
							local tempstr = theAction:EnumEquipExtAttr(i)
							if string.find(tempstr, "#{") then
								local left = string.find(tempstr, "#{")
								local left2 = string.find(tempstr, "}")
								strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))..string.sub(tempstr, left2+3,-2)
							end 
								str = str..strTemp.."|"
						end
					end
					if zhuangbeishuxing ==str then
						return i
					end
				end
			end
		end	
		return  k
	    ]],name,str),"n")
	return tonumber(tem)
end	

function 重复制作装备()
local list = 啤酒分割文本(装备合集, "|")
local n = 1
if list~=nil then
	while true do
	    屏幕提示(list[n])
		if list[n] == nil then
			break
		else	
			local beibaop = 晴天_取背包装备最大星星(list[n])
			晴天_友情提示("背包里"..list[n].."最高星级:"..beibaop);延时(1000)
			if beibaop<8 and beibaop~=0 then					
				晴天_友情提示("开始制作装备:%s",list[n])
				if list[n]=="幻世圣巾" then
					制作装备("幻世圣巾","4级棉布","帽子打造图10级")
					延时(1000)
					晴天_鉴定装备("幻世圣巾","鉴定书10级")
					延时(1000)
					晴天_出售装备("幻世圣巾",6)
				elseif list[n]=="凶陌圣甲" then
					制作装备("凶陌圣甲","4级棉布","衣服打造图10级")	
					延时(1000)
					晴天_鉴定装备("凶陌圣甲","鉴定书10级")
					延时(1000)
					晴天_出售装备("凶陌圣甲",6)
				elseif list[n]=="幻世魔肩" then
					制作装备("幻世魔肩","3级棉布","护肩打造图10级")
					延时(1000)
					晴天_鉴定装备("幻世魔肩","鉴定书10级")	
					延时(1000)
					晴天_出售装备("幻世魔肩",6)
				elseif list[n]=="幻世魔腕" then
					制作装备("幻世魔腕","3级棉布","护腕打造图10级")
					延时(1000)
					晴天_鉴定装备("幻世魔腕","鉴定书10级")	
					延时(1000)	
					晴天_出售装备("幻世魔腕",6)
				elseif list[n]=="幻世手套" then
					制作装备("幻世手套","3级棉布","手套打造图10级")
					延时(1000)
					晴天_鉴定装备("幻世手套","鉴定书10级")	
					延时(1000)
					晴天_出售装备("幻世手套",6)	
				elseif list[n]=="幻世圣靴" then
					制作装备("幻世圣靴","3级棉布","鞋子打造图10级")	
					延时(1000)
					晴天_鉴定装备("幻世圣靴","鉴定书10级")	
					延时(1000)
					晴天_出售装备("幻世圣靴",6)
				elseif list[n]=="步月" then
					制作装备("步月","3级棉布","腰带打造图10级")
					延时(1000)
					晴天_鉴定装备("步月","鉴定书10级")	
					延时(1000)	
					晴天_出售装备("步月",6)
				elseif list[n]=="蝶恋" then
					制作装备("蝶恋","3级秘银","项链打造图10级")	
					延时(1000)
					晴天_鉴定装备("蝶恋","鉴定符10级")	
					延时(1000)
					晴天_出售装备("蝶恋",6)
				elseif list[n]=="横笛" then
					制作装备("横笛","3级秘银","戒指打造图10级")
					延时(1000)
					晴天_鉴定装备("横笛","鉴定符10级")	
					延时(1000)
					晴天_出售装备("横笛",6)	
				elseif list[n]=="横笛" then
					制作装备("横笛","3级秘银","戒指打造图10级")	
					延时(1000)
					晴天_鉴定装备("横笛","鉴定符10级")
					延时(1000)
					晴天_出售装备("横笛",6)	
				elseif list[n]=="横笛" then
					制作装备("横笛","3级秘银","戒指打造图10级")	
					延时(1000)
					晴天_鉴定装备("横笛","鉴定符10级")	
					延时(1000)
					晴天_出售装备("横笛",6)
				elseif list[n]=="浅浪" then
					制作装备("浅浪","3级秘银","护符打造图10级")	
					延时(1000)
					晴天_鉴定装备("浅浪","鉴定符10级")
					延时(1000)	
					晴天_出售装备("浅浪",6)
				elseif list[n]=="浅浪" then
					制作装备("浅浪","3级秘银","护符打造图10级")	
					延时(1000)
					晴天_鉴定装备("浅浪","鉴定符10级")	
					延时(1000)
					晴天_出售装备("浅浪",6)
				elseif list[n]=="浅浪" then
					制作装备("浅浪","3级秘银","护符打造图10级")
					延时(1000)
					晴天_鉴定装备("浅浪","鉴定符10级")	
					延时(1000)
					晴天_出售装备("浅浪",6)																																																												
				end		
			end
		n=n+1
		延时(1000)	
		end	
	end	
end
end

function 啤酒分割文本(szFullString, szSeparator)
	
local nFindStartIndex = 1
local nSplitIndex = 1
local nSplitArray = {}
while true do
   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
   if not nFindLastIndex then
    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
    break
   end
   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
   nSplitIndex = nSplitIndex + 1
end
return nSplitArray
end

function 晴天_关闭窗口(strWindowName)
      if 窗口是否出现(strWindowName)==1 then
	    LUA_Call(string.format([[
	            setmetatable(_G, {__index = %s_Env}) this:Hide()  
	  ]], strWindowName))  
	  end
end

function 晴天_出售装备(物品名称,星级)
	for qqq=1,100 do
		local tem = LUA_取返回值(string.format([[
			local  i =%d
			local theAction = PlayerPackage:EnumItem("base",i-1)
			if theAction:GetID()~=0 and theAction:GetName()=='%s' then
				local num = PlayerPackage:GetSuperWeaponQual(i-1)
				if num~=-1 then
					--强化
					local QHLevel=  LifeAbility : Get_Equip_CurStrengthLevel(i-1);
					if QHLevel then
						if  QHLevel>= 1 then
							return -1
						end
					end	
					--精通
					local pName, pLevel, pBValue, pPercent, pRValue = theAction:GetEquipAttaProperty(0);
					if pLevel then
						if pLevel>=1 then
							return -1
						end
					end	
					if num<%d then
						return  i
					end
				end			
			end	
			return -1
		]], qqq,物品名称,星级))
		if 	 tonumber(tem) >= 0 then
			for k=1,5 do
				if 窗口是否出现("Shop")==1 then
					屏幕提示("晴天出售物品："..物品名称.." 背包位置："..qqq)
					LUA_Call(string.format([[
						local theAction = EnumAction(%d-1, "packageitem");
						if theAction:GetID() ~= 0 then
								setmetatable(_G, {__index = Packet_Env});
								local oldid = Packet_Space_Line1_Row1_button:GetActionItem();
								Packet_Space_Line1_Row1_button:SetActionItem(theAction:GetID());
								Packet_Space_Line1_Row1_button:DoAction();
								Packet_Space_Line1_Row1_button:SetActionItem(oldid);
						end
					]],qqq))
					延时(1000)
					break
				else
					跨图寻路("洛阳",352,248)
					延时(1000)
					对话NPC("何生富")
					延时(1000)
				end
			end
		end
	end
	晴天_关闭窗口("Shop")
end

function 晴天_取生活技能(aaa)
	local tem =     LUA_取返回值(string.format([[ 
	local nLifeAbilityCount = GetActionNum("life");
	for index = 0, nLifeAbilityCount do
		local theAction = EnumAction(index, "life");
		local life_id=theAction:GetID();
		if life_id ~= 0 then
			local name = theAction:GetName()
			if name== "%s" then
				return 1
			end
		end
	end
	return -1
		]], aaa))
		return  tonumber(tem)	
end

-------------------------------------------------------------------------------------------------------------


		
		
function 晴天_学习精工()    
	local jingong ={
		"精工" ,"精制","精炼"
	}
	for i =1,#jingong do
		local 技能 =jingong[i]
		for  k=1,5 do
			if 晴天_取生活技能(技能) == -1 then
				 跨图寻路("苏州",366,249)
				 if 对话NPC("朱锋")==1 then
					NPC二级对话("朱锋"); 延时(2000)
					NPC二级对话(技能,1);延时(3000)        
				end	
			else	
				break
			end
		end
	end	
end

取出物品(取出材料列表)

晴天_学习精工() 

制作装备("凶陌圣甲","3级棉布","衣服打造图10级")

制作装备("幻世圣巾","3级棉布","帽子打造图10级")

制作装备("幻世手套","3级棉布","手套打造图10级")

制作装备("幻世魔肩","3级棉布","护肩打造图10级")

制作装备("幻世圣靴","3级棉布","鞋子打造图10级")

制作装备("幻世魔腕","3级棉布","护腕打造图10级")

制作装备("步月","3级棉布","腰带打造图10级")

制作装备("蝶恋","3级秘银","项链打造图10级")

制作装备("横笛","3级秘银","戒指打造图10级")

制作装备("横笛","3级秘银","戒指打造图10级")

制作装备("浅浪","4级秘银","护符打造图10级")

制作装备("浅浪","4级秘银","护符打造图10级")

制作装备("浅浪","至尊秘银","护符打造图10级")

制作装备("浅浪","3级秘银","护符打造图10级")

制作装备("浅浪","3级秘银","护符打造图10级")



晴天_鉴定装备("幻世圣巾","鉴定书10级")

晴天_鉴定装备("凶陌圣甲","鉴定书10级")

晴天_鉴定装备("幻世手套","鉴定书10级")

晴天_鉴定装备("幻世魔肩","鉴定书10级")

晴天_鉴定装备("幻世圣靴","鉴定书10级")

晴天_鉴定装备("幻世魔腕","鉴定书10级")

晴天_鉴定装备("步月","鉴定书10级")

晴天_鉴定装备("蝶恋","鉴定符10级")

晴天_鉴定装备("横笛","鉴定符10级")

晴天_鉴定装备("横笛","鉴定符10级")

晴天_鉴定装备("浅浪","鉴定符10级")

晴天_鉴定装备("浅浪","鉴定符10级")

晴天_鉴定装备("浅浪","鉴定符10级")

晴天_鉴定装备("浅浪","鉴定符10级")

晴天_鉴定装备("浅浪","鉴定符10级")

--晴天_出售装备("凶陌圣甲",6)
--晴天_出售装备("幻世魔肩",6)
--晴天_出售装备("幻世魔腕",6)
--晴天_出售装备("幻世手套",6)
--晴天_出售装备("幻世圣靴",6)
--晴天_出售装备("步月",6)
--晴天_出售装备("蝶恋",6)
--晴天_出售装备("横笛",6)
--晴天_出售装备("浅浪",6)