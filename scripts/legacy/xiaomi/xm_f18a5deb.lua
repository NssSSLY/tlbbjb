-- 来自 新建文件夹/小蜜文本/内置文本/旧内置文件/073一键40双完美.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "sell", "item"})
-----------------------------------------需要鉴定的武器名字自己添加----------------------------------
名字集合="三股托天叉|八卦宣花斧|分水峨嵋刺|越王刃|晶玉扇|子母乌金环|沉香长弩|檀香箫|檀香长杖"
------------------------------------------------------------------------------------------------------
取出物品("通用鉴定符4级",20)
if 获取背包物品数量("通用鉴定符4级") <=20 then
	取出物品("金币",200000)
	跨图寻路("大理",252,227)
	对话NPC("初击平")
	NPC二级对话("看看你卖的东西");延时(2000)
	        if 窗口是否出现("Shop")==1 then
		 LUA_Call("NpcShop:BulkBuyItem(3, 20, 0);	")  
		LUA_Call("setmetatable(_G, {__index = Shop_Env});this:Hide();")  
          end 
end

function WQJD_Main()
    local nNum = LUA_取返回值("return DataPool:GetBaseBag_Num();", "n")
	--屏幕提示(nNum)
	
    for i = 0, nNum - 1 do
        local isWQ = LUA_取返回值(string.format([[
            local idx = %d
            local theAction,bLocked = PlayerPackage:EnumItem('base', idx);
            if theAction:GetID() ~= 0 then
               if LifeAbility : Get_Equip_TableIndex(idx) ~= -1 then 
                    if LifeAbility:Get_Equip_Point(idx) == 0 then 
						local str =  DataPool : GetEquipZiZhiRefreshDesc(idx);
							if string.find(str,"未鉴定") then
							return 1
							else
							PushDebugMessage("武器资质已经鉴定:"..idx)
						end
					 end
               end 
            end
            return 0
        ]],i),"n")
		
        if tonumber(isWQ) == 1 then 
			屏幕提示("鉴定背包武器位置:"..i)
            LUA_Call(string.format([[
            Clear_XSCRIPT();
			Set_XSCRIPT_Function_Name("FinishAdjust");
			Set_XSCRIPT_ScriptID(809261);
			Set_XSCRIPT_Parameter(0,%d);
			Set_XSCRIPT_ParamCount(1);
			Send_XSCRIPT();                       
            ]],i))
            延时(50)
        end                                         								
    end

end

屏幕提示("自动鉴定背包中所有武器资质(是否双完美)")
WQJD_Main()


function 自动鉴定武器(名字集合)
  local tem= LUA_取返回值(string.format([[
function quHL(AAA)
local row= math.ceil((AAA+1)/5)
local column  =math.mod(AAA+1,5)
if column==0 then
	column =5
end	
PushDebugMessage(row.."|"..column)
return row,column
end

function qujiandian()
for i=0,29 do
local beibaomingzi=EnumAction(i,"packageitem")
  if beibaomingzi:GetName()=="通用鉴定符4级" then
		PushDebugMessage(i)
		return i
  end
end
		return -1
end

AAA=qujiandian()
PushDebugMessage(AAA)
if AAA>=0 then
	 row,column=quHL(AAA)
end



for i=0,29 do
local theAction=EnumAction(i,"packageitem")
local name=theAction:GetName()
if theAction:GetID() ~= 0 then
	if string.find("%s",name) then
		PushDebugMessage("HAHA"..i)
		CCC,DDD=quHL(i)
		PushDebugMessage(CCC.."|"..DDD)
		setmetatable(_G, {__index = Packet_Env});Packet_ItemBtnClicked(row,column) 
		setmetatable(_G, {__index = Packet_Env});Packet_ItemBtnSubClicked(CCC,DDD);
	end
end
end	
	]],名字集合 ), "n");
end

function 杂货商店清理()
local wuqi_name = 名字集合
	while true do
		local exit1 = false
		for i=1,30 do
			local name = LUA_取返回值("local theAction=EnumAction("..i-1 ..",'packageitem')return theAction:GetName()","s",1)
			if name~="" and string.find(wuqi_name,name) then
				屏幕提示("武器："..name.." 背包位置："..i)
				local ZiZhi = LUA_取返回值("return DataPool:GetEquipZiZhiDesc("..i-1 ..")","s",1)
				if string.find(ZiZhi,"资质未鉴定") then
					屏幕提示("武器："..name.." 背包位置："..i.." 资质未鉴定")
				elseif string.find(ZiZhi,"普通") or string.find(ZiZhi,"中等") or string.find(ZiZhi,"优秀") then
					屏幕提示("武器："..name.." 背包位置："..i.." 有低于完美的资质")
					exit1 = true --出现需要出售的物品
					if 窗口是否出现("Shop")==1 then
						屏幕提示("出售武器："..name.." 背包位置："..i)
						LUA_Call("setmetatable(_G, {__index = Packet_Env})\
						Packet_Space_Line10_Row5_button:SetActionItem(PlayerPackage:EnumItem('base',"..i-1 .."):GetID())\
						Packet_Space_Line10_Row5_button:DoAction()")
					else
						屏幕提示("前往商店")
						跨图寻路("苏州",344,230)
						对话NPC("张小泉")
						break	--直接退出for循环
					end
				end
			end
		end
		if exit1 == false then
			屏幕提示("没有需要出售的物品 退出")
			break
		end
		延时(500)
	end
end

取出物品(名字集合)
自动鉴定武器(名字集合)
WQJD_Main()
杂货商店清理()
存物品(名字集合)




