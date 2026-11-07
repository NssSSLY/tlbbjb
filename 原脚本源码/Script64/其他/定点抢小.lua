-- 反编译自 dfz64.dll 内嵌字节码 002a9c1e（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local nOldScene = GetSceneID()
  
  local function _GetXiaoScriptID(aSceneID)
    if 9 == aSceneID then
      return 808027
    elseif 11 == aSceneID then
      return 808031
    elseif 10 == aSceneID then
      return 808032
    elseif 12 == aSceneID then
      return 808033
    elseif 15 == aSceneID then
      return 808034
    elseif 16 == aSceneID then
      return 808028
    elseif 13 == aSceneID then
      return 808029
    elseif 17 == aSceneID then
      return 808030
    elseif 14 == aSceneID then
      return 808016
    elseif 284 == aSceneID then
      return 808043
    elseif 615 == aSceneID then
      return 808044
    elseif 678 == aSceneID then
      return 808046
    elseif 731 == aSceneID then
      return 560
    end
    return -1
  end
  
  local nScriptID = _GetXiaoScriptID(nOldScene)
  local npcName = "江湖宵小"
  if -1 ~= nScriptID then
    while nOldScene == GetSceneID() do
      local sid = -1
      local tObj = Enum2XByName(npcName, {
        1,
        0,
        0,
        0
      }, nil, 1, 0)
      if #tObj > 0 then
        sid = tObj[1].id
        SP_OpenTalkAndClickedOption(sid, nScriptID, 0)
      else
        DebugStr("江湖宵小")
      end
      Sleep(30)
    end
  else
    PushColorMsg("定点抢小:当前地图不是门派地图" .. nOldScene)
  end
end

_SMain()
