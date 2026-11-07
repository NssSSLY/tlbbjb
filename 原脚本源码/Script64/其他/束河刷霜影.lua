-- 反编译自 dfz64.dll 内嵌字节码 002b2eef（unluac 2025-12-23；仅供分析）
local m_script_name = "束河刷霜影"
ScriptOnStart(m_script_name, true, false)
CDG.attack = true
local m_lastFindTime = -1
local m_killNum = 0
local m_record = {}

local function SHSY_FindObj()
  PickUpLua(nil, true)
  local tObj = Enum2XByName("霜影", {
    0,
    1,
    0,
    0
  }, nil, nil, 0)
  if #tObj > 0 then
    local tmp = tObj[1]
    if 0 == tmp.hp then
      local tPush = ObjTickFilter(tObj, m_record, 60000)
      if #tPush > 0 then
        m_lastFindTime = GetTickCount()
        m_killNum = m_killNum + 1
        m_record = ObjTickPush(m_record, tmp.id)
        PickUpLua_Boss(15, 15, nil, {
          {
            x = tmp.x,
            y = tmp.y
          }
        })
      end
      return false
    else
      m_lastFindTime = GetTickCount()
      RunTo(tmp.x, tmp.y, 3, 1000)
      FubenAttack(tmp.id)
    end
    return true
  end
  return false
end

local function SHSY_OnLeader()
  local iPos = 0
  local ShuangYingPos = {
    {x = 35, y = 257},
    {x = 29, y = 147},
    {x = 33, y = 36},
    {x = 282, y = 120}
  }
  
  local function _move_cb(fX, fY, nScene)
    local tObj = Enum2XByName("霜影", {
      0,
      1,
      0,
      0
    }, nil, nil, 0)
    if #tObj > 0 then
      return false
    end
    return true
  end
  
  while true do
    if false == SHSY_FindObj() then
      if -1 ~= m_lastFindTime then
        if GetTickCount() - m_lastFindTime > 480000 then
          m_lastFindTime = -1
          PushDebugMessage("刷霜影:前往束河古镇寻找Boss")
          UseMount()
          iPos = 0
        else
          GoBackCity()
          FubenAttack(-1)
          Sleep(1000)
        end
      else
        iPos = iPos + 1
        if iPos > 4 then
          iPos = 1
        end
        MoveTo(ShuangYingPos[iPos].x, ShuangYingPos[iPos].y, 260, nil, nil, nil, _move_cb)
      end
    end
    Sleep(100)
    DieOutAndGetPos()
    DebugStr(m_script_name .. ":已杀霜影数量" .. m_killNum)
  end
end

function _SMain(...)
  while true do
    SHSY_OnLeader()
    Sleep(300)
  end
end

_SMain()
ScriptOnStop(m_script_name)
