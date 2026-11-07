-- 反编译自 dfz64.dll 内嵌字节码 002b1de4（unluac 2025-12-23；仅供分析）
local m_script_name = "抢箱子"
ScriptOnStart(m_script_name, false, false)
g_config.qxz = {}
g_config.qxz.box = ReadConfigText("ZH", "bjk81")
local m_param = {}
m_param.box_name = HandleText_AddFuHao(g_config.qxz.box, " ", true)

local function QXZ_EnumObj()
  local tObj = Enum2XByClass("宝箱")
  tObj = ObjFilterByName(tObj, m_param.box_name, 3)
  BubbleByDst(tObj, 1)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

function _SMain(...)
  if m_param.box_name == "" then
    PushDebugMessage("抢箱子：请设置正确的名称")
    return
  end
  PushDebugMessage("抢箱子 : " .. m_param.box_name)
  while true do
    local tar = QXZ_EnumObj()
    if tar then
      if tar.dst > 3 then
        RunTo(tar.x, tar.y, 1, 300)
      end
      Skill.CUseSkillByID(3, tar.id, -1, -1)
      PushDebugMessage("发现宝箱:%s", m_param.box_name)
      Sleep(200)
      local nState = Player:GetState()
      while 5 == nState or 8 == nState do
        Sleep(100)
        GetLuaValue("if IsWindowShow('LootPacket') == true then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close();end;")
        nState = Player:GetState()
        DebugStr("正在打开宝箱.")
      end
      Sleep(100)
    end
    GetLuaValue("if IsWindowShow('LootPacket') == true then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close();end;")
    Sleep(10)
  end
  PushDebugMessage("抢箱子：结束！")
end

_SMain()
