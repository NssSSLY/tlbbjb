-- 反编译自 dfz64.dll 内嵌字节码 0043b846（unluac 2025-12-23；仅供分析）
local m_script_name = "蒲雪饮冰"
ScriptOnStart(m_script_name, false, false)

local function zxqf_canNJ()
  local strText = [[
            setmetatable(_G, {__index = ZhongXiaItem_Env})
            if tostring(ZhongXiaItem_Button1:GetProperty("Disabled")) == "False" then 
                return 1
            end
            return 0
        ]]
  return GetLuaValue(strText, "b")
end

local function zxqf_canQF()
  local strText = [[
            setmetatable(_G, {__index = ZhongXiaItem_Env})
            if tostring(ZhongXiaItem_Button2:GetProperty("Disabled")) == "False" then
                return 1
            end
            return 0
        ]]
  return GetLuaValue(strText, "b")
end

function _SMain(...)
  GetLuaValue("setmetatable(_G, {__index = XiGua_Shop_Gift_Env});XiGua_Shop_Gift_GetClick()")
  DeleteDebugMsg("#{ZXJQ_120516_60")
  for i = 1, 10 do
    if IsWindowVisible("ZhongXiaItem") == false then
      GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env}); XiGua_Guide_Clicked(1)")
      Sleep(600)
    end
    if false == zxqf_canNJ() then
      break
    end
    GetLuaValue("setmetatable(_G, {__index = ZhongXiaItem_Env});ZhongXia_OnActivate()")
    Sleep(500)
    if IsInDebugMsg("#{ZXJQ_120516_60") then
      break
    end
  end
  for i = 1, 8 do
    if IsWindowVisible("ZhongXiaItem") then
      if zxqf_canQF() then
        GoToScene(367, 167, 1)
        if IsWindowVisible("ZhongXiaItem") == false then
          GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env}); XiGua_Guide_Clicked(1)")
          Sleep(1000)
        end
        Dismount()
        GetLuaValue("setmetatable(_G, {__index = ZhongXiaItem_Env});ZhongXia_OnPray()")
      else
        GoToScene(367, 167, 1)
        Dismount()
        GetLuaValue("setmetatable(_G, {__index = ZhongXiaItem_Env});ZhongXia_OnPray()")
      end
    else
      GetLuaValue("setmetatable(_G, {__index = XiGua_Guide_Env}); XiGua_Guide_Clicked(1)")
    end
    Sleep(2000)
  end
  CloseWindow("ZhongXiaItem")
  GetLuaValue("setmetatable(_G, {__index = XiGua_Shop_Gift_Env});XiGua_Shop_Gift_GetClick()")
  Sleep(1000)
  Bag:UseItemByName_click("萌宠戏夏礼包", 1000)
  Bag:UseItemByName_click("清荷礼包", 1000)
end

_SMain()
