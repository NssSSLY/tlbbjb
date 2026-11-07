-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/领棉布合四级.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
function 买棉布()
                GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_CaiLiaoCompound_Clicked();")
	for i=550,1,-1 
	do
	MoveToNPC(158,151,2,"新版本天使");Sleep(100)
	QuestFrameOptionClicked("领取秘银、精铁、棉布、黄纸",1);Sleep(170)
	QuestFrameOptionClicked("棉布",1);Sleep(170)
	GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_PackUp_Clicked();")
	end


while true do
GetLuaValue([[
	Clear_XSCRIPT()
		Set_XSCRIPT_Function_Name( "CaiLiaoCompound_New" )
		Set_XSCRIPT_ScriptID(701602)
		Set_XSCRIPT_Parameter(0,1)			--npcid
		Set_XSCRIPT_Parameter(1,500)	--每次合成的数量
		Set_XSCRIPT_Parameter(2,2)				--类型
		Set_XSCRIPT_Parameter(3,4)			--子类型
		Set_XSCRIPT_Parameter(4,0)					--二次确认
		Set_XSCRIPT_ParamCount(5)
	Send_XSCRIPT()
	]])
Sleep(600)
local 三级棉布数量 = GetLuaValue("setmetatable(_G, {__index = IdentifyTwice_Env});return  PlayerPackage:CountAvailableItemByIDTable(tonumber(20501003));","n",1) 
if 三级棉布数量 < 2500 then break end
end
end
买棉布()