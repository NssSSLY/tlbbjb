-- 反编译自 dfz64.dll 内嵌字节码 00436cf5（unluac 2025-12-23；仅供分析）
local m_script_name = "豪气满江湖"
ScriptOnStart(m_script_name, true, true)
local hfhs_fyhb = 1
local hfhs_jxhb = 1
local hfhs_cftb = 1

function _SMain(...)
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(70);")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});Newserver_Hongbao_Tab_Click(1)")
  Sleep(1000)
  local strText = [[
    	Clear_XSCRIPT()
            Set_XSCRIPT_Function_Name( "LingQu" ); 
            Set_XSCRIPT_ScriptID( 501016 );
            Set_XSCRIPT_Parameter( 0, %d );
            Set_XSCRIPT_ParamCount( 1 );
        Send_XSCRIPT()
    ]]
  for i = 1, 23 do
    local strTemp = fmt(strText, i)
    GetLuaValue(strTemp)
    Sleep(200)
  end
  GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});Newserver_Hongbao_Tab_Click(2)")
  local strText_buy = [[
        Clear_XSCRIPT()
            Set_XSCRIPT_Function_Name( "Buy" );
            Set_XSCRIPT_ScriptID( 501016 );
            Set_XSCRIPT_Parameter( 0, %d );	 
            Set_XSCRIPT_Parameter( 1, %d );	 
            Set_XSCRIPT_ParamCount( 2 );
        Send_XSCRIPT()	
    ]]
  if hfhs_fyhb > 0 then
    local strTemp1 = fmt(strText_buy, 1, hfhs_fyhb)
    GetLuaValue(strTemp1)
    Sleep(1000)
  end
  if hfhs_jxhb > 0 then
    local strTemp2 = fmt(strText_buy, 2, hfhs_jxhb)
    GetLuaValue(strTemp2)
    Sleep(1000)
  end
  if hfhs_cftb > 0 then
    local strTemp3 = fmt(strText_buy, 3, hfhs_cftb)
    GetLuaValue(strTemp3)
    Sleep(1000)
  end
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});Newserver_Hongbao_Tab_Click(3)")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = Newserver_Hongbao_Env});NewServerHongbaoBossReward()")
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(70);")
  Sleep(1000)
  for i = 1, Bag:GetItemCount("豪气红包") do
    Bag:UseItemByName("豪气红包")
    Sleep(200)
  end
  for i = 1, Bag:GetItemCount("侠情红包·武魂") do
    Bag:UseItemByName("侠情红包·武魂")
    Sleep(200)
  end
  for i = 1, Bag:GetItemCount("侠义红包") do
    Bag:UseItemByName("侠义红包")
    Sleep(200)
  end
  for i = 1, Bag:GetItemCount("侠情红包·令牌") do
    Bag:UseItemByName("侠情红包·令牌")
    Sleep(200)
  end
  for i = 1, Bag:GetItemCount("初级灵草礼盒") do
    Bag:UseItemByName("初级灵草礼盒")
    Sleep(200)
  end
  Sleep(3000)
end

_SMain()
ScriptOnStop(m_script_name, true)
