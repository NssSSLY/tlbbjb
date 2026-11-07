-- 来自 新建文件夹/小蜜文本/套餐/60套餐/5洗神器_小号.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
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


function 判断关闭窗口(strWindowName)
        if 窗口是否出现(strWindowName)==1 then
                LUA_Call(string.format([[
                        setmetatable(_G, {__index = %s_Env}) this:Hide()
                ]], strWindowName))
                延时(1500)
          end
end


function 窗口关闭(strWindowName)
      if 窗口是否出现(strWindowName)==1 then
            LUA_Call(string.format([[
                    setmetatable(_G, {__index = %s_Env}) this:Hide()
          ]], strWindowName))
                延时(2000)
          end
end


function 取所有钱()
        所有钱=获取人物信息(52) +获取人物信息(45)
        return 所有钱
end


function  取身上装备持久(aaa)
        local tem = LUA_取返回值(string.format([[
                return EnumAction(%d,"equip"):GetEquipDur()
        ]], aaa))
                return  tonumber(tem)
end


function  取背包装备等级(index)
local aaa=  LUA_取返回值(string.format([[
                return LifeAbility : Get_Equip_Level(%d);
        ]], index))
        return tonumber(aaa)
end


--------------------------------------------------装备相关------------------------------------------------


function 取下神器()
     for i=1,5 do
         LUA_Call ("MainMenuBar_SelfEquip_Clicked();")
         延时 (1000)
         if 窗口是否出现("SelfEquip")==1 then   --同组命令 等待窗口出现()
              LUA_Call ("SelfEquip_Equip_Click(11,0);")
              延时 (1000)
              if LUA_取返回值("return EnumAction(0,'equip'):GetID();")=="0" then  --检测脱下装备成功
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


function 装备神器()
     for i=1,5 do
         if 窗口是否出现("EquipLingPai_ShengJie") ==1 then 
	          	关闭窗口("EquipLingPai_ShengJie")
		 elseif 窗口是否出现("EquipLingPai_Star") ==1 then 
				关闭窗口("EquipLingPai_Star")
		 elseif 窗口是否出现("EquipLingPai_OperatingSJ") ==1 then 
				关闭窗口("EquipLingPai_OperatingSJ")				
             else
              右键使用物品("武器",1)     --参数2:为使用次数
         end
         延时(1000)
         if tonumber(LUA_取返回值("return EnumAction(20,'equip'):GetID();"))>0 then  --装备成功
              break   
         end
     end
end





function 神器炼魂(序号)
        LUA_Call(string.format([[
                        Clear_XSCRIPT()
                        Set_XSCRIPT_Function_Name( "OnShenqiUpgrade" )
                        Set_XSCRIPT_ScriptID( 500505 )
                        Set_XSCRIPT_Parameter( 0, %d)
                        Set_XSCRIPT_Parameter( 1, 160)
                        Set_XSCRIPT_Parameter( 2, 0 )
                        Set_XSCRIPT_ParamCount( 3 )
                        Send_XSCRIPT()
                 ]], 序号))
end

function 神器炼魂确定(序号)
        LUA_Call(string.format([[
        g_ItemPos=%d
                Clear_XSCRIPT();
                        Set_XSCRIPT_Function_Name("DoRefreshSuperAttr");
                        Set_XSCRIPT_ScriptID(500505);
                        Set_XSCRIPT_Parameter(0,g_ItemPos);
                        Set_XSCRIPT_ParamCount(1);
                Send_XSCRIPT();
                 ]], 序号))
                延时(3000)
                LUA_Call(string.format([[
                                setmetatable(_G, {__index = SuperWeaponUpNEW_Env});
                        SuperWeaponUpNEW_Clear(1)
                        SuperWeaponUpNEW_Hide_RadioText()
                         ]]))
end

function 取身上武器属性()
	local isWQ = LUA_取返回值(string.format([[
		local  theAction =EnumAction(0, "equip");
		local num = theAction:GetEquipAttrCount()
		if num> 0 then
		local str = ""
		for i = 0, num-1 do
				local tempstr = theAction:EnumEquipExtAttr(i)
				if string.find(tempstr, "#{") then
						local left = string.find(tempstr, "#{")
						local left2 = string.find(tempstr, "}")
						strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))
				end
						str = str..strTemp.."|"
		end
		return str
		end
		return -1
						 ]], "s"))
	return tostring(isWQ)
end

--屏幕提示(取身上武器属性())

function 取神器炼魂后重的属性()
 local isWQ = LUA_取返回值(string.format([[
        local num =  DataPool : Lua_GetSuperRecoinNum();
        if num> 0 then
        local str = ""
        for i = 0, num-1 do
                local tempstr = DataPool:Lua_GetSuperRecoinEnumAttr(i)
                if string.find(tempstr, "#{") then
                        local left = string.find(tempstr, "#{")
                        local left2 = string.find(tempstr, "}")
                        strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))
                end
                        str = str..strTemp.."|"
        end
        return str
        end
        return -1
                                 ]], "s"))
        return tostring(isWQ)
end




function 全自动神器炼魂(属性,属性2,属性3)
	现属性 = 取身上武器属性()
	if string.find(现属性,属性) and string.find(现属性,属性2) and string.find(现属性,属性3) and string.find(现属性,"体力") and string.find(现属性,"血上限") then
		友情提示("完成啦 跳过任务")
		return
	else
		友情提示("开始洗，目标属性：血上限|体力|"..属性.."|"..属性2.."|"..属性3)
		延时(1000)
	end
	取下神器()
	取出物品("神兵符1级|神兵符2级|神兵符3级")
	取出物品("金币")
	LPindex = 获取背包物品位置("武器")-1
	if 获取背包物品数量("神兵符3级")< 5 or 取所有钱()<=5*10000 then
		友情提示("没有材料")
		return
	end
	延时(1000)
	跨图寻路("苏州",353,241)
	while true do
		if 获取背包物品数量("神兵符3级")< 5 or 取所有钱()<=5*10000 then
			友情提示("材料或金币不足，自动停止")
			break
		end
		神器炼魂(LPindex)
		炼魂属性 = 取神器炼魂后重的属性()
		延时(500)

		if string.find(炼魂属性,属性) and  string.find(炼魂属性,属性2) and  string.find(炼魂属性,属性3) and  string.find(炼魂属性,"体力") and string.find(现属性,"血上限") then
			友情提示("满足属性，准备确认")
			延时(500)
			神器炼魂确定(LPindex)
			break
		else
			友情提示("属性不满足，重洗 |"..炼魂属性)
		end
		延时(1000)
	end
	装备神器()
	延时(500)
	友情提示("已洗完，开始存物品存钱")
	存物品("神兵符1级|神兵符2级|神兵符3级")
	延时(500)
	存物品("金币")	
end


function 根据门派自动洗()
	--获取人物主属性
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
	主属性攻击=tem
	屏幕提示("属性攻击:"..主属性攻击)
	
	
	
	local 人物名称,门派,PID,远近攻击,内外攻击,角色账号,门派地址,技能状态,性别=获取人物属性()
	
	------------------前3条满足即会停止，第4-6条满足一条就会停止；如峨眉(血上限、冰攻击、所有属性、体力、忽略目标冰抗，就会停止)--(第五条跟第六条其中一条生效则停止)--------------
	if 门派 == "峨嵋" then
		全自动神器炼魂("冰攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "唐门" then
		全自动神器炼魂("毒攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "星宿" then
		全自动神器炼魂("毒攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "天龙" then
		全自动神器炼魂("玄攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "丐帮" then
		全自动神器炼魂("毒攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "逍遥" then
		全自动神器炼魂("火攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "绝情谷" then
		全自动神器炼魂("火攻击","所有属性","忽略目标"..主属性攻击.."抗")
	elseif 门派 == "鬼谷" then
		全自动神器炼魂("玄攻击","所有属性","忽略目标"..主属性攻击.."抗")
	end
	
end
根据门派自动洗()





