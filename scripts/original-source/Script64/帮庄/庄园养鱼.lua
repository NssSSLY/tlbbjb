-- 反编译自 dfz64.dll 内嵌字节码 003527dd（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：表键 早熟鲤鱼 → ["早熟鲤鱼"]（1 处）；表键 早熟三文鱼 → ["早熟三文鱼"]（1 处）；表键 中熟鲤鱼 → ["中熟鲤鱼"]（1 处）；表键 中熟三文鱼 → ["中熟三文鱼"]（1 处）；表键 晚熟鲤鱼 → ["晚熟鲤鱼"]（1 处）；表键 晚熟三文鱼 → ["晚熟三文鱼"]（1 处）
local m_script_name = "庄园养鱼"
ScriptOnStart(m_script_name, false, false, false)
local m_param = {}
m_param.peiou = false
m_param.guyong = GetConfigBool("庄园养鱼", "雇佣园丁")
m_param.yuanbao = GetConfigBool("庄园养鱼", "元宝播撒")
m_param.list_index = 0
local m_data = {}
m_data.option = {
  ["早熟草鱼"] = 2,
  ["早熟鲤鱼"] = 3,
  ["早熟三文鱼"] = 4,
  ["早熟金枪鱼"] = 5,
  ["早熟罗非鱼"] = 6,
  ["中熟草鱼"] = 8,
  ["中熟鲤鱼"] = 9,
  ["中熟三文鱼"] = 10,
  ["中熟金枪鱼"] = 11,
  ["中熟罗非鱼"] = 12,
  ["晚熟草鱼"] = 14,
  ["晚熟鲤鱼"] = 15,
  ["晚熟三文鱼"] = 16,
  ["晚熟金枪鱼"] = 17,
  ["晚熟罗非鱼"] = 18
}

function ZYZZ_GetState()
  GetLuaValue("setmetatable(_G, {__index = BieYe_Mini_Env});BieYe_Mini_Sub(3)")
  Sleep(1000)
  local a1, a2 = GetLuaValue([[
            local a1, a2, a3 = BieYeUI:GetBieYeBaseInfo("ProductInfo", 4) 
            return a1,a2
        ]], "nn")
  return a1, a2
end

function ZY_GetYuanDing()
  local freeYD = 2
  local gyYD = 4
  GetLuaValue("BieYeUI:AskBieYeBaseInfo(5)")
  Sleep(1000)
  local strText = [[
            local WorkType0, BuildingIndex0, Remains0, PlantType0 = BieYeUI:GetBieYeBaseInfo("GardnerInfo", 0)
            local WorkType1, BuildingIndex1, Remains1, PlantType1 = BieYeUI:GetBieYeBaseInfo("GardnerInfo", 1)
            local WorkType2, BuildingIndex2, Remains2, PlantType2 = BieYeUI:GetBieYeBaseInfo("GardnerInfo", 2)
            local WorkType3, BuildingIndex3, Remains3, PlantType3 = BieYeUI:GetBieYeBaseInfo("GardnerInfo", 3)
            local WorkType4, BuildingIndex4, Remains4, PlantType4 = BieYeUI:GetBieYeBaseInfo("GardnerInfo", 4)
            local WorkType5, BuildingIndex5, Remains5, PlantType5 = BieYeUI:GetBieYeBaseInfo("GardnerInfo", 5)
            return WorkType0, WorkType1, WorkType2, WorkType3, WorkType4, WorkType5        
        ]]
  local WorkType0, WorkType1, WorkType2, WorkType3, WorkType4, WorkType5 = GetLuaValue(strText, "nnnnnn")
  if WorkType0 > 0 and WorkType0 <= 9 then
    freeYD = freeYD - 1
  end
  if WorkType1 > 0 and WorkType1 <= 9 then
    freeYD = freeYD - 1
  end
  if WorkType2 > 0 and WorkType2 <= 9 then
    gyYD = gyYD - 1
  end
  if WorkType3 > 0 and WorkType3 <= 9 then
    gyYD = gyYD - 1
  end
  if WorkType4 > 0 and WorkType4 <= 9 then
    gyYD = gyYD - 1
  end
  if WorkType5 > 0 and WorkType5 <= 9 then
    gyYD = gyYD - 1
  end
  return freeYD, gyYD
end

function ZY_CheckYuanDing()
  local freeYD, gyYD = ZY_GetYuanDing()
  PushDebugMessage("园丁空闲：" .. freeYD .. ",雇佣空闲 " .. gyYD)
  if 0 == freeYD and 0 == gyYD then
    PushColorMsg(m_script_name .. ":已经没有园丁空闲！")
    return false
  end
  if 0 == freeYD and not m_param.guyong then
    PushColorMsg(m_script_name .. ":已经没有免费园丁空闲,您未允许雇佣！")
    return false
  end
  return true
end

function ZY_Click()
  if IsWindowVisible("BieYePlanting") then
    if m_param.yuanbao then
      GetLuaValue("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_SwitchPage(2);")
    else
      GetLuaValue("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_SwitchPage(1);")
    end
    Sleep(1000)
    GetLuaValue(fmt("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_ItemDataChanged(%d)", m_param.list_index))
    Sleep(1000)
    GetLuaValue("setmetatable(_G, {__index = BieYePlanting_Env});BieYePlanting_Buttons_Clicked();")
    Sleep(1000)
    if IsWindowVisible("WuhunQuest") then
      if m_param.yuanbao then
        WuhunQuest_Text_Clicked("元宝")
        Sleep(1000)
      end
      if m_param.guyong then
        WuhunQuest_Text_Clicked("均有劳务在身")
        Sleep(1000)
      end
      CloseWindow("WuhunQuest")
    end
  end
end

function ZYZZ_Action()
  CloseAllWindow()
  local a1, a2 = ZYZZ_GetState()
  if 3 == a1 or 4 == a1 then
    MoveToNPC("何翁", 116, 214, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    DialogOptionClicked("收获食材", 3, 800)
    return true
  end
  local nState = 0
  if 2 == a1 then
    local sec = os.time() + a2 * 60 + 60
    PlayerConfigSet("庄园养鱼", GetTimeStr(sec), "记录")
    PushColorMsg("庄园：成熟时间已经记录到配置文件")
    nState = nState + 1
  end
  if ZY_CheckYuanDing() == false then
    return false
  end
  if 0 == a1 or 1 == a1 then
    MoveToNPC("何翁", 116, 214, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    DialogOptionClicked("播撒鱼苗", 3, 1000)
    ZY_Click()
    return true
  end
  if 1 == nState then
    PushColorMsg(m_script_name .. ":完成")
    return false
  end
  DebugStr("养鱼中", 2)
  return true
end

function _SMain(...)
  local comb1 = GetConfigCommbox("庄园养鱼", "成熟时间")
  local comb2 = GetConfigCommbox("庄园养鱼", "播撒类型")
  local str = comb1.text .. comb2.text
  m_param.list_index = m_data.option[str]
  if m_param.list_index == nil then
    PushColorMsg(m_script_name .. ":设置有误")
    return
  end
  while true do
    if IsZhuangYuanScene() then
      if ZYZZ_Action() == false then
        break
      end
    else
      GoToZhuangYuan(2)
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
  GoOutZhuangYuan()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
