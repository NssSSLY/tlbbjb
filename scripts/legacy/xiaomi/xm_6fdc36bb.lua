-- 来自 新建文件夹/小蜜文本/其他类型文本/J交子兑换.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
取出物品("金币")

local index=5000000
---------------------------------------------------------------------------------------------------
function  兑换交子(index)

	LUA_Call(string.format([[ 
	Clear_XSCRIPT( )
		Set_XSCRIPT_Function_Name( "DoMoneyToJiaozi" )
		Set_XSCRIPT_ScriptID( 800119 )
		Set_XSCRIPT_Parameter( 0, %d )
		Set_XSCRIPT_ParamCount( 1 )
	Send_XSCRIPT( )
		]], index))

end


兑换交子(index)

