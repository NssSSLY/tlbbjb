-- 反编译自 dfz64.dll 内嵌字节码 0043a061（unluac 2025-12-23；仅供分析）
local m_script_name = "使用金纹铜钱"
ScriptOnStart(m_script_name, false, false)

function _SMain(...)
  local npc = {
    x = 256,
    y = 246,
    sceneID = LUOYANG_ID,
    name = "摇钱树"
  }
  local tickOut = GetTickCount()
  TempBank2Bag("金纹铜钱")
  while true do
    local tItem = Bag:FindItemInfo("金纹铜钱")
    if #tItem > 0 then
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
      Dismount(500)
      local tObj = Enum2XByName("摇钱树", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        local tmp = tObj[1]
        Target:Select(tmp.id, 500)
        Bag:UseItemByName_click("金纹铜钱", 800)
        PlayerStateTimeOut(5, 8)
      end
    else
      PushColorMsg(m_script_name .. ":背包没有金纹铜钱")
      break
    end
    if GetTickCount() - tickOut > 300000 then
      PushColorMsg(m_script_name .. ":超时")
      break
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  for i = 1, 3 do
    Bag:UseItemByName_click("踏雪迎冬礼盒", 300)
  end
  CloseAllWindow()
end

_SMain()
ScriptOnStop(m_script_name, false)
