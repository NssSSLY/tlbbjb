-- 来自 新建文件夹/小蜜文本/其他打造/其他打造文本/打造宝玉淬洗.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
local GetLuaValue = LUA_取返回值
local PushDebugMessageEx = 屏幕提示
local PushDebugMessage = 屏幕提示
local Sleep = 延时
local QuestFrameOptionClicked = NPC二级对话
GetLuaValue("setmetatable(_G, { __index = DebugListBox_Env })DebugListBox_ListBox:AddInfo('#eaf0c14#Y'..'本脚本由【阿航lQQ103900393】整理编辑 ')")
function MoveToNPC(fx,fy, nId, npc_name)
	while true do
		if nId==获取人物信息(16) and 计算两点距离(fx,fy,获取人物信息(7),获取人物信息(8))<5 then
			对话NPC(npc_name)
			Sleep(500)
			return 
		else
			跨图寻路(nId,fx,fy)
		end
	end
end

function IsWindowShow(name) 
	if tonumber(GetLuaValue("if IsWindowShow('"..name.."') then return 1 end return 0","n",1))==1 then
		return true
	end
	return false
end	
	
local tpname = {"鸾金","云水","建木","天火","息土",}

function 五行宝玉淬洗(n1,bfb)
	local num = 获取背包物品数量("玉华灵泉")
	local n2 = tonumber(GetLuaValue("local num=0 for i=1,5 do num=num+Player:GetFiveElements_JadeExtend("..n1-1 ..",Player:GetFiveElements_JadeType("..n1-1 ..",i-1))end return num","n",1))
	local n3 = tonumber(GetLuaValue("return Player:GetData('MONEY')+Player:GetData('MONEY_JZ')","n",1))
	PushDebugMessageEx("阿航|当前序号："..n1.." 值："..n2.."% 材料数量："..num.." 金币："..n3)
	while num>=5 and n2<bfb and n3>=10000 do
		if IsWindowShow("EquipBaoJian_Wash") and string.find(GetLuaValue("setmetatable(_G, {__index = EquipBaoJian_Wash_Env})return EquipBaoJian_Wash_DragTitle:GetText()","s",1),tpname[n1]) then
			PushDebugMessage("【阿航】 淬洗操作："..tpname[n1])
			GetLuaValue("Clear_XSCRIPT()\
				Set_XSCRIPT_Function_Name('FiveElementsJadeWash')\
				Set_XSCRIPT_ScriptID(880039)\
				Set_XSCRIPT_Parameter(0,"..n1-1 ..")\
				Set_XSCRIPT_Parameter(1,2)\
				Set_XSCRIPT_ParamCount(2)\
			Send_XSCRIPT()")
			Sleep(1000)
			GetLuaValue("setmetatable(_G, {__index = WuhunQuest_Env})if this:IsVisible()then WuhunQuest_Bn1Click()end")
		else
			MoveToNPC(115,200,"凤鸣镇","杜钏灵")
			QuestFrameOptionClicked("五行宝玉淬洗")
			Sleep(500)
			QuestFrameOptionClicked(tpname[n1].."宝玉淬洗")
		end
		Sleep(500)
		num = 获取背包物品数量("玉华灵泉")
		n2 = tonumber(GetLuaValue("local num=0 for i=1,5 do num=num+Player:GetFiveElements_JadeExtend("..n1-1 ..",Player:GetFiveElements_JadeType("..n1-1 ..",i-1))end return num","n",1))
		n3 = tonumber(GetLuaValue("return Player:GetData('MONEY')+Player:GetData('MONEY_JZ')","n",1))
		PushDebugMessageEx("【阿航】 当前序号："..n1.." 值："..n2.."% 材料数量："..num.." 金币："..n3)
		Sleep(1000)
	end
end

--"鸾金","云水","建木","天火","息土"
function 阿航_五行宝玉淬洗(加持)
	五行宝玉淬洗(1,加持)
	五行宝玉淬洗(2,加持)
	五行宝玉淬洗(3,加持)
	五行宝玉淬洗(4,加持)
	五行宝玉淬洗(5,加持)
end

取出物品("玉华灵泉")
存物品("玉华灵泉",不存物品,0,1,1) 
阿航_五行宝玉淬洗(30)
阿航_五行宝玉淬洗(45)
阿航_五行宝玉淬洗(65)
阿航_五行宝玉淬洗(80)
阿航_五行宝玉淬洗(100)
