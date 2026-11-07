-- 反编译自 dfz64.dll 内嵌字节码 004287bb（unluac 2025-12-23；仅供分析）
local m_script_name = "一键日常"
ScriptOnStart(m_script_name, true, false)
g_config.yjrc = {}
g_config.yjrc.run_list = GetConfigList("日常", "一键日常")

function _SMain(...)
  if g_config.yjrc == nil or nil == g_config.yjrc.run_list then
    PushColorMsg("您需要保存设置后再执行")
    return
  end
  local week = tonumber(os.date("%w"))
  if 0 == week then
    week = 7
  end
  PushDebugMessage("今天是星期" .. week)
  
  local function _GetRealName(aStrText)
    local zq = 0
    if string.find(aStrText, "[周一]", nil, true) then
      zq = 1
    elseif string.find(aStrText, "[周二]", nil, true) then
      zq = 2
    elseif string.find(aStrText, "[周三]", nil, true) then
      zq = 3
    elseif string.find(aStrText, "[周四]", nil, true) then
      zq = 4
    elseif string.find(aStrText, "[周五]", nil, true) then
      zq = 5
    elseif string.find(aStrText, "[周六]", nil, true) then
      zq = 6
    elseif string.find(aStrText, "[周日]", nil, true) then
      zq = 7
    end
    local scriptName = string.gsub(aStrText, "%[每天%]", "")
    scriptName = string.gsub(scriptName, "%[周一%]", "")
    scriptName = string.gsub(scriptName, "%[周二%]", "")
    scriptName = string.gsub(scriptName, "%[周三%]", "")
    scriptName = string.gsub(scriptName, "%[周四%]", "")
    scriptName = string.gsub(scriptName, "%[周五%]", "")
    scriptName = string.gsub(scriptName, "%[周六%]", "")
    scriptName = string.gsub(scriptName, "%[周日%]", "")
    return scriptName, zq
  end
  
  local runList = g_config.yjrc.run_list
  for i = 1, #runList do
    local tmp = runList[i]
    local scriptName, zq = _GetRealName(tmp.text)
    if #scriptName > 0 and (0 == zq or zq == week) then
      LoadScript(scriptName)
    end
  end
end

_SMain()
ScriptOnStop(m_script_name, false)
