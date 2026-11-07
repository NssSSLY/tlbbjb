-- 反编译自 dfz64.dll 内嵌字节码 0043a50d（unluac 2025-12-23；仅供分析）
local m_script_name = "金元礼赠"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GetLuaValue([[
		setmetatable(_G, {__index = New_SeasonCard_Env});
		New_SeasonCard_Icon_GetClick();
	]])
  Sleep(1000)
  Dismount()
  Bag:UseItemByName_click("100绑定元宝票", 1000)
  Sleep(1000)
end

_SMain()
ScriptOnStop(m_script_name, true)
