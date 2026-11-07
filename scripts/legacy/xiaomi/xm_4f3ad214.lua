-- 来自 新建文件夹/小蜜文本/小蜜文本/金先生-真元摧解.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"item"})
真元集合="|真元·紫血符|真元·紫冰符|真元·紫火符|真元·紫玄符|真元·紫毒符|真元·紫体符|真元·紫御符|真元·紫准符|真元·紫劲符|真元·紫灵符|真元·紫敏符|真元·紫韧符|真元·紫坚符|真元·紫力符|真元·紫暴符|真元·紫定符|真元·紫气符|真元·紫罡符|真元·紫闪符|紫色真元符集|无相秘钥|无相宝匣|"

背包身上东西漼解="#cFFFFFF真元·百炼铁骨|#cFFFFFF真元·百步穿杨|#cFFFFFF真元·内劲绵绵|#cFFFFFF真元·灵慧|#cFFFFFF真元·迅捷|#cFFFFFF真元·千转柔筋|#cFFFFFF真元·坚韧如岳|#cFFFFFF真元·勇力|#cFFFFFF真元·暴猛如焰|#cFFFFFF真元·气定|#cFFFFFF真元·气贯神庭|#cFFFFFF真元·外功罡猛|#cFFFFFF真元·滑不沾衣|#c00D000真元·百炼铁骨|#c00D000真元·百步穿杨|#c00D000真元·内劲绵绵|#c00D000真元·灵慧|#c00D000真元·迅捷|#c00D000真元·千转柔筋|#c00D000真元·坚韧如岳|#c00D000真元·勇力|#c00D000真元·暴猛如焰|#c00D000真元·气定|#c00D000真元·气贯神庭|#c00D000真元·外功罡猛|#c00D000真元·滑不沾衣|#c2980FF真元·百炼铁骨|#c2980FF真元·百步穿杨|#c2980FF真元·内劲绵绵|#c2980FF真元·灵慧|#c2980FF真元·迅捷|#c2980FF真元·千转柔筋|#c2980FF真元·坚韧如岳|#c2980FF真元·勇力|#c2980FF真元·暴猛如焰|#c2980FF真元·气定|#c2980FF真元·气贯神庭|#c2980FF真元·外功罡猛|#c2980FF真元·滑不沾衣|#ccc33cc真元·百炼铁骨|#ccc33cc真元·百步穿杨|#ccc33cc真元·内劲绵绵|#ccc33cc真元·灵慧|#ccc33cc真元·迅捷|#ccc33cc真元·千转柔筋|#ccc33cc真元·坚韧如岳|#ccc33cc真元·勇力|#ccc33cc真元·暴猛如焰|#ccc33cc真元·气定|#ccc33cc真元·气贯神庭|#ccc33cc真元·外功罡猛|#ccc33cc真元·滑不沾衣|"

真元保留物品列表 ="[蓝色]真元·血涌丹田|[蓝色]真元·厚体|[蓝色]真元·沉冰|[蓝色]真元·蛊毒|"



--真元保留物品列表 =string.gsub(真元保留物品列表,"%[蓝色%]","#c2980FF")
--真元保留物品列表 =string.gsub(真元保留物品列表,"%[紫色%]","#ccc33cc")
--屏幕提示(真元保留物品列表)
--延时(30000)
--真元保留物品列表 =真元保留物品列表.."|"..string.gsub(真元保留物品列表,"真","魂")
--#ccc33cc 紫色
--#c00D000 绿色
--#c2980FF 蓝色 
--#cFFFFFF 白色
--前面的是颜色要加进去
--szName=string.gsub(szName, "#ccc33cc", "[紫色]")
------------------------------------------------------------------------------------------------------------------------------------------------------
function 环宇_批量使用物品(AAA)
	local t={}
	for w in string.gmatch(AAA,"([^'|']+)") do        
		table.insert(t,w)
	end
	for k,v in ipairs(t) do
		if 获取背包物品数量(v)>=1 then
			屏幕提示("环宇批量使用物品:序号:"..k..":"..v) 
			右键使用物品(v);
			延时(2000)	
		end
	end
end


function 环宇_取出物品右键使用(物品列表)
	取出物品(物品列表)
	环宇_批量使用物品(物品列表)
end

function 环宇_漼解炉(物品列表,颜色)
	if not 颜色 then
		颜色 = 1
	end	
	for i=36,59 do
		local tem =LUA_取返回值(string.format([[	
		 i=%d
		wupin = "%s"
		 yanseindex =%d
		if yanseindex == 1 then
			yanse ="#cFFFFFF"
		elseif yanseindex == 2 then 
			yanse ="#c00D000"
		elseif yanseindex == 3 then 
			yanse ="#c2980FF"	
		elseif yanseindex == 4 then 
			yanse ="#ccc33cc"	
		end
			
		local szName, nLevel, szAdd, nAdd, nNextAdd=Pneuma:GetPneumaAddingInfo(i)
		if szName~="" and szName~=nil then
			if string.find(wupin,szName) then
				PushDebugMessage("漼解"..szName)
				PushDebugMessage("漼解"..szName)
				return 1
			end
			if  string.find(szName,yanse) then
				PushDebugMessage("漼解"..szName)
				PushDebugMessage("漼解"..szName)
				return 1
			end
			PushDebugMessage("保留"..szName)
		end
		return -1
		]],i ,物品列表,颜色))
		if tonumber(tem) == 1 then
			LUA_取返回值(string.format([[	
				Pneuma:SmeltPneumaItem(%d)
				]],i))			
			延时(1500)
		end
	end
end


function 环宇_真元漼解炉(颜色,保留物品列表)
	if not 颜色 then
		颜色 = 1
	end	
	for i=36,59 do
		local tem =LUA_取返回值(string.format([[	
		 i=%d
		 yanseindex =%d
		blwp ="%s"
		if yanseindex == 1 then
			yanse ="#cFFFFFF"
		elseif yanseindex == 2 then 
			yanse ="#c00D000"
		elseif yanseindex == 3 then 
			yanse ="#c2980FF"	
		elseif yanseindex == 4 then 
			yanse ="#ccc33cc"	
		end
			
		local szName, nLevel, szAdd, nAdd, nNextAdd=Pneuma:GetPneumaAddingInfo(i)
		if szName~="" and szName~=nil then
			szName=string.gsub(szName, "#cFFFFFF", "[白色]")
			szName=string.gsub(szName, "#c00D000", "[绿色]")
			szName=string.gsub(szName, "#c2980FF", "[蓝色]")
			szName=string.gsub(szName, "#cFF6600", "[橙色]")
			szName=string.gsub(szName, "#ccc33cc", "[紫色]")
			if  string.find(szName,yanse) then
				if  not string.find(blwp,szName) then
					PushDebugMessage("漼解"..szName)
					return 1
				end
			PushDebugMessage("保留"..szName)	
			end
			PushDebugMessage("没有处理这个颜色:"..szName)
		end
		return -1
		]],i ,颜色,保留物品列表))
		if tonumber(tem) == 1 then
			LUA_取返回值(string.format([[	
				Pneuma:SmeltPneumaItem(%d)
				]],i))			
			延时(1500)
		end
	end
end
------------------------------------------

--环宇_真元漼解炉(3,真元保留物品列表)
--环宇_真元漼解炉(4,真元保留物品列表)

环宇_取出物品右键使用(真元集合)
环宇_漼解炉(背包身上东西漼解)
环宇_取出物品右键使用(真元集合)
环宇_漼解炉(背包身上东西漼解)