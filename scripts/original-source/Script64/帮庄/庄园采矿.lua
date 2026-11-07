-- 反编译自 dfz64.dll 内嵌字节码 003591b8（unluac 2025-12-23；仅供分析）
local m_script_name = "庄园采矿"
ScriptOnStart(m_script_name, false, false, false)
local m_param = {}
m_param.peiou = false
m_param.guyong = GetConfigBool("庄园采矿", "雇佣园丁")
m_param.yuanbao = GetConfigBool("庄园采矿", "元宝开采")
m_param.list_index = 0
local m_data = {}
m_data.option = {
  ["少量石灰石"] = 2,
  ["少量云母石"] = 3,
  ["少量黑曜石"] = 4,
  ["少量孔雀石"] = 5,
  ["少量紫晶石"] = 6,
  ["中级石灰石"] = 8,
  ["中级云母石"] = 9,
  ["中级黑曜石"] = 10,
  ["中级孔雀石"] = 11,
  ["中级紫晶石"] = 12,
  ["大量石灰石"] = 14,
  ["大量云母石"] = 15,
  ["大量黑曜石"] = 16,
  ["大量孔雀石"] = 17,
  ["大量紫晶石"] = 18
}

function ZYZZ_GetState()
  GetLuaValue("setmetatable(_G, {__index = BieYe_Mini_Env});BieYe_Mini_Sub(3)")
  Sleep(1000)
  local a1, a2, b1, b2 = GetLuaValue([[
            local a1, a2, a3 = BieYeUI:GetBieYeBaseInfo("ProductInfo", 2)
            local b1, b2, b3 = BieYeUI:GetBieYeBaseInfo("ProductInfo", 3)   
            return a1,a2,b1,b2
        ]], "nnnn")
  return a1, a2, b1, b2
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
  local a1, a2, b1, b2 = ZYZZ_GetState()
  if 3 == a1 or 4 == a1 then
    MoveToNPC("1号采石场", 53, 152, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    DialogOptionClicked("收获石料", 3, 800)
    return true
  end
  if 3 == b1 or 4 == b1 then
    MoveToNPC("2号采石场", 53, 163, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    DialogOptionClicked("收获石料", 3, 800)
    return true
  end
  local nState = 0
  if 2 == a1 then
    local sec = os.time() + a2 * 60 + 60
    PlayerConfigSet("庄园1号采石场", GetTimeStr(sec), "记录")
    PushColorMsg("庄园：成熟时间已经记录到配置文件")
    nState = nState + 1
  end
  if 2 == b1 then
    local sec = os.time() + b2 * 60 + 60
    PlayerConfigSet("庄园2号采石场", GetTimeStr(sec), "记录")
    PushColorMsg("庄园：成熟时间已经记录到配置文件")
    nState = nState + 1
  end
  if ZY_CheckYuanDing() == false then
    return false
  end
  if 0 == a1 or 1 == a1 then
    MoveToNPC("1号采石场", 53, 152, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    DialogOptionClicked("开采矿石", 3, 1000)
    ZY_Click()
    return true
  end
  if 0 == b1 or 1 == b1 then
    MoveToNPC("2号采石场", 53, 163, -1, nil, nil, nil, IsZhuangYuanScene)
    Sleep(500)
    DialogOptionClicked("开采矿石", 3, 1000)
    ZY_Click()
    return true
  end
  if 2 == nState then
    PushColorMsg(m_script_name .. ":完成")
    return false
  end
  DebugStr("采矿中", 2)
  return true
end

function _SMain(...)
  local comb1 = GetConfigCommbox("庄园采矿", "成熟时间")
  local comb2 = GetConfigCommbox("庄园采矿", "矿石类型")
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
