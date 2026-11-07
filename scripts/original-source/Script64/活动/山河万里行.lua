-- 反编译自 dfz64.dll 内嵌字节码 0045cb96（unluac 2025-12-23；仅供分析）
local m_script_name = "山河万里行"
ScriptOnStart(m_script_name, true, true)

function _SMain(...)
  GetLuaValue("setmetatable(_G, {__index = PlayerQuicklyEnter_Env});PlayerQuicklyEnter_Clicked(60);")
  Sleep(1000)
  for i = 1, 4 do
    local strTxt = fmt("setmetatable(_G, {__index = ShuangYe_Env});ShuangYe_Button_Clicked(%d)", i)
    GetLuaValue(strTxt)
    Sleep(500)
    strTxt = fmt("setmetatable(_G, {__index = ShuangYe_Env});ShuangYe_Reward_Clicked(%d)", i)
    GetLuaValue(strTxt)
    Sleep(500)
  end
  GetLuaValue("setmetatable(_G, {__index = ShuangYe_Env});ShuangYe_UseQiufengyin_Clicked()")
  Sleep(1000)
  local szTalkTitle = GetNPCEventList_Item(0)
  local xPos, yPos, sceneID = szTalkTitle:match("%*[%c]*(%d+)%*[%c]*(%d+)%*[%c]*(%d+)")
  xPos = tonumber(xPos)
  yPos = tonumber(yPos)
  sceneID = tonumber(sceneID)
  PushDebugMessage("游冶，抒怀:%d,%d,%d", xPos, yPos, sceneID)
  MoveTo(xPos, yPos, sceneID)
  Sleep(1000)
  GetLuaValue("setmetatable(_G, {__index = Frost_Env});Frost_ButtonClick(3);")
end

PushColorMsg(GetSceneID())
_SMain()
ScriptOnStop(m_script_name, true)
