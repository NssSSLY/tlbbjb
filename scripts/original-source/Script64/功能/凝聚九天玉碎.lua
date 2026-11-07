-- 反编译自 dfz64.dll 内嵌字节码 003357ff（unluac 2025-12-23；仅供分析）
local m_script_name = "凝聚九天玉碎"
ScriptOnStart(m_script_name, false, false)
g_config["凝聚九天玉碎"] = {}
g_config["凝聚九天玉碎"]["攻击"] = GetConfigCommbox("设置", "凝聚九天玉碎攻击")
g_config["凝聚九天玉碎"]["抗性"] = GetConfigCommbox("设置", "凝聚九天玉碎抗性")
g_config["凝聚九天玉碎"]["穿刺"] = GetConfigCommbox("设置", "凝聚九天玉碎穿刺")
local m_param = {}
m_param.gj = g_config["凝聚九天玉碎"]["攻击"].sel
m_param.kx = g_config["凝聚九天玉碎"]["抗性"].sel
m_param.cc = g_config["凝聚九天玉碎"]["穿刺"].sel + 1

function _SMain(...)
  local npc = {
    x = 115,
    y = 199,
    sceneID = 850,
    name = "杜钏灵"
  }
  local itemName = "九天玉碎"
  TempBank2Bag(itemName)
  if 0 == Bag:GetItemCount(itemName) then
    Bank_GetItem(itemName)
  end
  local attr = Player:GetAttackAttr()
  if m_param.gj <= 0 then
    m_param.gj = attr[1].index
  end
  if m_param.kx <= 0 then
    m_param.kx = attr[1].index
  end
  if m_param.cc <= 0 then
    m_param.cc = 1
  end
  local nTick = -1
  CloseAllWindow()
  while true do
    if IsWindowVisible("EquipBaoJian_Cohesion") then
      local nIndex2Cohesion, nCostMoney = GetLuaValue([[
                    local g_CostItemCount = {2, 5, 8, 12, 16, 20, 25, 30, 40, 50}
                    local g_CostMoney = {20000, 50000, 80000, 120000, 160000, 200000, 250000, 300000, 400000, 500000}
                    local nIndex2Cohesion = Player:GetFiveElementsIndexCanDoCohesion()
                    if nIndex2Cohesion >= 0 and nIndex2Cohesion < 5 then
                        local bElementsLevel = Player:GetFiveElements_ElementsLevel(nIndex2Cohesion)
                        local nLevelGrade = math.floor(bElementsLevel / 10)
                        if g_CostItemCount[nLevelGrade + 1] and g_CostMoney[nLevelGrade + 1] then
                            return g_CostItemCount[nLevelGrade + 1], g_CostMoney[nLevelGrade + 1]
                        end
                    end
                    return -1, -1
                ]], "nn")
      if nIndex2Cohesion > Bag:GetItemCount(itemName) then
        PushColorMsg(m_script_name .. ":数量不足")
        break
      end
      if nCostMoney > Player:GetMoney() + Player:GetMoney(2) then
        PushColorMsg(m_script_name .. ":金币不足")
        break
      end
      GetLuaValue("setmetatable(_G, {__index = EquipBaoJian_Cohesion_Env});EquipBaoJian_Cohesion_OnOK();")
      Sleep(500)
      if IsWindowVisible("EquipBaoJian_YuLuan_Tips") then
        GetLuaValue(fmt("setmetatable(_G, {__index = EquipBaoJian_YuLuan_Tips_Env});EquipBaoJian_YuLuan_Tips_OnSelect(%d);", m_param.gj))
        Sleep(600)
        CloseWindow("EquipBaoJian_YuLuan_Tips")
        Sleep(600)
      elseif IsWindowVisible("EquipBaoJian_TianHuo_Tips") then
        GetLuaValue(fmt("setmetatable(_G, {__index = EquipBaoJian_TianHuo_Tips_Env});EquipBaoJian_TianHuo_Tips_OnSelect(%d);", m_param.kx))
        Sleep(600)
        CloseWindow("EquipBaoJian_TianHuo_Tips")
        Sleep(600)
      elseif IsWindowVisible("EquipBaoJian_YunShui_Tips") then
        GetLuaValue(fmt("setmetatable(_G, {__index = EquipBaoJian_YunShui_Tips_Env});EquipBaoJian_YunShui_Tips_OnSelect(%d);", m_param.cc))
        Sleep(600)
        CloseWindow("EquipBaoJian_YunShui_Tips")
        Sleep(600)
      end
    else
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      DialogOptionClicked("五行宝玉凝聚", 1, 800)
    end
    if -1 == nTick then
      nTick = GetTickCount()
    end
    if GetTickCount() - nTick > 300000 then
      PushColorMsg(m_script_name .. "：执行超时")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
