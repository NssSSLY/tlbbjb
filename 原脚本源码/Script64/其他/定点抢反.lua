-- 反编译自 dfz64.dll 内嵌字节码 002a98ce（unluac 2025-12-23；仅供分析）
function _SMain(...)
  local fanzeiScene = {
    6,
    
    7,
    4,
    8,
    3
  }
  local npcName = "造反恶贼"
  local nOldScene = GetSceneID()
  if FindTableValue(fanzeiScene, nOldScene) then
    DoSystem(1001, g_self.isjingong, Skill.baseID, 100, 65000, 2)
    DoSystem(1002, 1)
    RecvState(16)
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
        SP_OpenTalkAndClickedOption(sid, 50013, -1)
        Sleep(20)
      else
        DebugStr(npcName)
      end
      Sleep(10)
    end
  else
    PushColorMsg("定点抢反:当前地图不是反贼地图" .. nOldScene)
  end
  DoSystem(1004)
end

_SMain()
