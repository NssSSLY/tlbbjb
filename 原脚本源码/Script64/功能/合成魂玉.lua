-- 反编译自 dfz64.dll 内嵌字节码 00343dc9（unluac 2025-12-23；仅供分析）
local m_script_name = "合成魂玉"
ScriptOnStart(m_script_name, true, false)
g_config.hchy = {}
g_config.hchy.thy = ReadConfigBool("ZH", "dxk8")
g_config.hchy.dhy = false

function _SMain(...)
  TempBank2Bag("命魂玉 地魂玉 天魂玉", 2)
  Bank_GetItem("命魂玉 地魂玉 天魂玉", -1, 2, 1, true)
  local tick_out = -1
  if not g_config.hchy.thy then
    g_config.hchy.dhy = true
  end
  while true do
    Sleep(200)
    local nMHY = Bag:GetItemCount("命魂玉")
    local nDHY = Bag:GetItemCount("地魂玉")
    local nTHY = Bag:GetItemCount("天魂玉")
    if g_config.hchy.dhy and nMHY < 5 then
      PushColorMsg("合成地魂玉:已经没有命魂玉！")
      break
    elseif g_config.hchy.thy and nMHY < 5 and nDHY < 5 then
      PushColorMsg("合成天魂玉:已经没有命魂玉、地魂玉！")
      break
    end
    GoToSceneNPC("逍遥子", 247, 217, 850)
    if -1 == tick_out then
      tick_out = GetTickCount()
    end
    QuestFrameOptionClicked_Item("#{JXSQ_170804_07}", 1, 800)
    if nMHY >= 5 then
      QuestFrameOptionClicked_Item("#{JXSQ_170804_132}", 1, 600)
    end
    if nDHY >= 5 and g_config.hchy.thy then
      QuestFrameOptionClicked_Item("#{JXSQ_170804_133}", 1, 600)
    end
    IsWindowVisible("ShenqiSX_HY", "ShenqiSX_HY_OK_Clicked()")
    if -1 ~= tick_out and GetTickCount() - tick_out > 120000 then
      PushColorMsg(m_script_name .. ":执行超时")
      break
    end
    DebugStr("合成魂玉")
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
