-- 反编译自 dfz64.dll 内嵌字节码 004cf8d9（unluac 2025-12-23；仅供分析）
function WaitTime(szTime)
  local arrTime = SplitString(szTime, ":")
  
  if 2 ~= #arrTime then
    DebugStr("接口的参数设置错误,正确示例 1:30 ,注意中间的 冒号 是英文状态下的！")
    return
  end
  local hour, min = tonumber(arrTime[1]), tonumber(arrTime[2])
  if hour and min then
    WaitForTime(hour, min)
  end
end

function WaitTeamCount(nNum, szTalk)
  PushColorMsg("当前系统时间 " .. os.date("%X") .. " 开始等待队伍人数达到 " .. nNum .. " 第二个参数不为空时可喊话")
  while true do
    local nowNum = Team:GetMemberCount()
    if nNum <= nowNum then
      break
    end
    if nil ~= szTalk and "" ~= szTalk then
      SendTalkChatMsg("scene", szTalk, 180)
    end
    Sleep(10000)
    DebugStr("当前系统时间 " .. os.date("%X") .. " 正在等待队伍人数达到 " .. nNum)
  end
  PushColorMsg("当前系统时间 " .. os.date("%X") .. " 队伍人数已经达到 " .. nNum)
end

_ENV["等待到指定时间"] = function(szTime)
  WaitTime(szTime)
end
_ENV["等待队伍人数"] = function(nNum, szTalk)
  WaitTeamCount(nNum, szTalk)
end
_ENV["组队跟随"] = function()
  Player:TeamFollow(true, 300)
end
_ENV["取消跟随"] = function()
  Player:TeamFollow(false, 300)
end
_ENV["等待"] = function(nTick)
  Sleep(tonumber(nTick))
end
_ENV["执行脚本"] = function(szScriptName)
  LoadScript(szScriptName)
end
_ENV["输入屏幕文本"] = function(szMsg)
  PushDebugMessage(szMsg)
end
_ENV["定时执行脚本"] = function(脚本名, 开始时间, 结束时间)
  if nil ~= 开始时间 and "" ~= 开始时间 then
    _ENV["等待到指定时间"](开始时间)
  end
  LoadScript(脚本名)
end
_ENV["解散队伍"] = function()
  GetLuaValue("Player:DismissTeam();")
end
_ENV["创建队伍"] = function()
  GetLuaValue("Player:CreateTeamSelf();")
end
_ENV["申请进组"] = function(szName)
  if nil == szName or "" == szName then
    PushDebugMessage("名字设置有错误！")
    return
  end
  if type(szName) ~= "string" then
    PushDebugMessage("名字请加引号")
    return
  end
  szName = " " .. szName .. " "
  PushDebugMessage("循环申请进组，直到有队伍！")
  local szArr1 = SplitString(szName, " ")
  while true do
    local bIn = GetLuaValue("if Player:IsInTeam() == 0 then return 0 end return 1", "b")
    if bIn then
      break
    end
    if #szArr1 <= 0 then
      PushDebugMessage("名字设置有错误！")
      break
    end
    for i = 1, #szArr1 do
      if "" ~= szArr1[i] then
        GetLuaValue(fmt("Target:SendTeamApply('%s')", szArr1[i]))
        Sleep(2000)
      end
    end
    Sleep(5000)
    DebugStr("正在申请进组,请确保名称设置无误...")
  end
end
_ENV["跨图寻路"] = function(szScene, fX, fY)
  local nScene = GetSceneIDByName(szScene)
  if nScene < 0 then
    PushDebugMessage("跨图寻路:请设置正确的地图名称")
    return
  end
  if type(fX) ~= "number" then
    PushDebugMessage("跨图寻路:X坐标设置错误")
    return
  end
  if type(fY) ~= "number" then
    PushDebugMessage("跨图寻路:Y坐标设置错误")
    return
  end
  MoveTo(fX, fY, nScene)
  Sleep(500)
end
_ENV["使用物品"] = function(szName)
  if nil == szName or "" == szName then
    PushDebugMessage("物品名称使用错误")
    return
  end
  Bag:UseItemByName_click(szName, 500)
end
_ENV["下坐骑"] = function()
  Dismount()
end
_ENV["闪烁窗口"] = function()
end
_ENV["音乐报警"] = function()
end
_ENV["取杀怪数量"] = function()
  return Player:GetDataInt("KILLMONSTERCOUNT")
end
_ENV["杀怪"] = function(aPosX, aPosY, aSceneID, aTargetName, aKillNum)
  ScriptOnStart("杀怪", false, false)
  local pos = {
    {x = aPosX, y = aPosY}
  }
  local sceneName = GetSceneNameByID(aSceneID)
  local startCnt = Player:GetDataInt("KILLMONSTERCOUNT")
  
  local function _cb()
    if 9 == Player:GetState() then
      DieOutAndGetPos()
    end
    local nowCnt = Player:GetDataInt("KILLMONSTERCOUNT")
    local nKill = nowCnt - startCnt
    if nKill >= aKillNum then
      PushColorMsg("本次杀怪已经完成")
      return true
    end
    DebugStr("已杀数量%d,一共需杀%d", nKill, aKillNum)
    return false
  end
  
  local param = {}
  param.attackMode = "优先绿怪"
  BeginAttack(pos, sceneName, aTargetName)
end
