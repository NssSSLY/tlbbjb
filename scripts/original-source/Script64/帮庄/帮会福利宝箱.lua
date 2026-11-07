-- 反编译自 dfz64.dll 内嵌字节码 003521ee（unluac 2025-12-23；仅供分析）
local m_script_name = "帮会福利宝箱"
ScriptOnStart(m_script_name, false, false)
local m_stop = false

local function BHFL_cb_find(aX, aY, aSceneID)
  if not MoveCallback_InMyGuild(aX, aY, aSceneID) then
    return false
  end
  local tObj = Enum2XByName("福利宝箱", {
    0,
    0,
    0,
    0,
    1
  }, nil, nil, 0)
  if #tObj > 0 then
    return false
  end
  return true
end

local function BHFL_FindObj()
  local tObj = Enum2XByName("福利宝箱", {
    0,
    0,
    0,
    0,
    1
  }, nil, 1, 0)
  if #tObj > 0 then
    local tmp = tObj[1]
    RunTo(tmp.x, tmp.y, 1, 1500)
    PlayerStateTimeOut(2, 20)
    Dismount(600)
    Skill.CUseSkillByID(4720, tmp.id, -1, -1)
    Sleep(800)
    PlayerStateTimeOut(5, 5)
    if IsInDebugMsg("#{BHFLGTMB_210714_80}") then
      m_stop = false
    end
    return true
  end
  return false
end

function _SMain(...)
  local tickOut = -1
  while true do
    local debugnote = ""
    if IsMyGuildCity() then
      if -1 == tickOut then
        tickOut = GetTickCount()
      end
      if GetTickCount() - tickOut > 600000 then
        LogMsg(m_script_name .. ":超时10分钟")
        break
      end
      if false == BHFL_FindObj() then
        MoveTo(57, 137, -1, nil, nil, nil, BHFL_cb_find)
        if false == BHFL_FindObj() then
          MoveTo(145, 137, -1, nil, nil, nil, BHFL_cb_find)
        end
      end
    else
    end
    if false == GoToGuild() or m_stop then
      break
    end
    Sleep(800)
    DebugStr(m_script_name)
  end
end

_SMain()
