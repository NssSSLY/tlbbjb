-- 反编译自 dfz64.dll 内嵌字节码 0055a207（unluac 2025-12-23；仅供分析）
CExec("common_2")
CExec("common")
LoadScript("graph")
LoadScript("player")
LoadScript("bag")
LoadScript("skill")
LoadScript("target")
LoadScript("pet")
LoadScript("team")
LoadScript("daguai")
LoadScript("functions")
LoadScript("leavescene")
LoadScript("fn兼容接口")
LoadScript("fnE2C")

function GlobalInit(aGetCfg)
  CMGraph:Init()
  Skill:RefreshSkill()
  CDG:Init()
end

function ErrorInit()
  local error = 1
end
