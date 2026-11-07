-- 反编译自 dfz64.dll 内嵌字节码 002ff923（unluac 2025-12-23；仅供分析）
local m_script_name = "聚灵谷困难"
ScriptOnStart(m_script_name, true, true)
LoadScript("fn聚灵谷")
CDG:InitFubenParam()
local m_param = {}
m_param.type = 3
m_param.swcq = true
m_param.unkill_xhcl = false
m_param.unkill_cyhh = false
m_param.unkill_xlbj = false
m_param.unkill_jdwj = false
m_param.unkill_xhcl = GetConfigBool("聚灵谷", "不打雪海沧龙")
m_param.unkill_cyhh = GetConfigBool("聚灵谷", "不打赤焰黑虎")
m_param.unkill_xlbj = GetConfigBool("聚灵谷", "不打玄雷宝驹")
m_param.unkill_jdwj = GetConfigBool("聚灵谷", "不打剧毒乌犍")
m_param.unkill_ls = GetConfigBool("聚灵谷", "不打雷锁")
m_param.unkill_xg = GetConfigBool("聚灵谷", "不打小怪")
m_param.fb_count = HandleTextToNumber(GetConfigText("聚灵谷", "副本次数"), 0)
if GetConfigBool("聚灵谷", "宿灵渊") then
  m_param.type = 4
else
  m_param.type = 3
end
m_param.maxtime = 0
local m_data = {}
m_data.sceneID = 877
m_data.allnpc = {
  {
    name = "剧毒乌犍",
    x = 150,
    y = 146,
    sceneID = 112,
    option = "#{SESX_230426_15}"
  },
  {
    name = "玄雷宝驹",
    x = 156,
    y = 146,
    sceneID = 112,
    option = "#{SESX_230426_139}"
  },
  {
    name = "",
    x = 0,
    y = 0,
    sceneID = 201,
    option = "#{SESX_230426_140}"
  },
  {
    name = "",
    x = 0,
    y = 0,
    sceneID = 875,
    option = "#{SESX_230426_140}"
  }
}
m_param.TransferItem = false
local m_findNpcPos = {
  [201] = {
    {x = 221, y = 165},
    {x = 228, y = 133},
    {x = 202, y = 139},
    {x = 165, y = 152},
    {x = 225, y = 73},
    {x = 200, y = 66},
    {x = 175, y = 42},
    {x = 101, y = 56},
    {x = 99, y = 18},
    {x = 73, y = 20},
    {x = 88, y = 59},
    {x = 30, y = 44},
    {x = 45, y = 111},
    {x = 46, y = 150},
    {x = 19, y = 172},
    {x = 93, y = 162},
    {x = 50, y = 212},
    {x = 102, y = 216}
  },
  [875] = {
    {x = 251, y = 272},
    {x = 239, y = 262},
    {x = 174, y = 257},
    {x = 171, y = 233},
    {x = 217, y = 204},
    {x = 227, y = 228},
    {x = 265, y = 170},
    {x = 277, y = 72},
    {x = 204, y = 84},
    {x = 192, y = 107},
    {x = 180, y = 73},
    {x = 126, y = 89},
    {x = 49, y = 118},
    {x = 111, y = 248},
    {x = 41, y = 222},
    {x = 87, y = 284}
  }
}

local function JLG_TalkNpc()
  local tick_out = GetTickCount()
  local curSceneID = GetSceneID()
  while Player:IsLeader() and not (Team:GetMemberCount() < 3) do
    local tObj = Enum2XByName("造反恶贼", {
      1,
      0,
      0,
      0
    }, nil, 1, 0)
    if #tObj > 0 then
      local tmp = tObj[1]
      SP_OpenTalkAndClickedOption(tmp.id, 50013, -1)
      if 170 ~= curSceneID and IsDestination(tmp.x, tmp.y, curSceneID, 3) == false then
        GoToScene(tmp.x, tmp.y, curSceneID, 5)
      end
    else
      break
    end
    if GetTickCount() - tick_out > 90000 then
      break
    end
    Sleep(15)
  end
end

local function JLG_FindNPC()
  local curScene = GetSceneID()
  local strAllNpc = " 剧毒乌犍 玄雷宝驹 雪海沧龙 赤焰黑虎 "
  if m_param.unkill_xhcl then
    strAllNpc = string.gsub(strAllNpc, " 雪海沧龙 ", " ")
  end
  if m_param.unkill_cyhh then
    strAllNpc = string.gsub(strAllNpc, " 赤焰黑虎 ", " ")
  end
  if m_param.unkill_xlbj then
    strAllNpc = string.gsub(strAllNpc, " 玄雷宝驹 ", " ")
  end
  if m_param.unkill_jdwj then
    strAllNpc = string.gsub(strAllNpc, " 剧毒乌犍 ", " ")
  end
  local tObj = Enum2XByName(strAllNpc, {
    1,
    0,
    0,
    0
  }, nil, 1, 3)
  if #tObj > 0 then
    local tmp = tObj[1]
    GoToScene(tmp.x, tmp.y, curScene, 5)
    OpenTalk(tmp.id, 500)
    QuestFrameOptionClicked_Item("#{SESX_230426_140}", 1, 100)
    return true
  end
  return false
end

local function sf_movecb_findNPC(fX, fY, nScene)
  local curSceneID = GetSceneID()
  if curSceneID == m_data.sceneID then
    return false
  end
  if not Player:IsLeader() then
    return false
  end
  if curSceneID == nScene and JLG_FindNPC() then
    return false
  end
  if not Player:IsFollow() then
    UseMount()
    Player:TeamFollow(true, 300)
  end
  return true
end

function _SMain(...)
  LeaveSpecialScene({
    m_data.sceneID
  }, nil)
  local bOver = false
  local bOldComp, nOldMyCount, nOldAllCount = IsHuodongComplete("灵谷勘兽迹", 1, true)
  if GetSceneID() == m_data.sceneID then
    nOldMyCount = nOldMyCount - 1
  end
  local tarSceneID = 201
  if 4 == m_param.type then
    tarSceneID = 875
  end
  local tarScenePos = m_findNpcPos[tarSceneID]
  local posIndex = 1
  if GetSceneID() == tarSceneID then
    posIndex = GetNearestPoint(tarScenePos)
  end
  local lastFindTime = GetTickCount()
  while true do
    local curScene = GetSceneID()
    if curScene == m_data.sceneID then
      bOver = true
      JLG_Fuben(m_param)
      lastFindTime = GetTickCount()
    else
      local bNowComp, nNowMyCount, nNowAllCount = IsHuodongComplete("灵谷勘兽迹", 1)
      if bNowComp then
        Sleep(2000)
        if GetSceneID() ~= m_data.sceneID and IsHuodongComplete("灵谷勘兽迹", 1, true) then
          PushColorMsg("聚灵谷:已刷满")
          break
        end
      else
        if 0 == m_param.fb_count and bOver then
          LogMsg("聚灵谷:本次已完成")
          break
        end
        if 0 ~= m_param.fb_count and nNowMyCount - nOldMyCount >= m_param.fb_count and GetSceneID() ~= m_data.sceneID then
          LogMsg(m_script_name .. ":已经完成" .. m_param.fb_count .. "次")
          break
        end
        if m_param.maxtime > 0 and GetTickCount() - lastFindTime > m_param.maxtime * 60 * 1000 then
          PushColorMsg("聚灵谷困难:已经" .. m_param.maxtime .. "分钟没有进入副本")
          Sleep(2000)
          if GetSceneID() ~= m_data.sceneID then
            break
          end
        end
        if Player:IsLeader() then
          DebugStr("聚灵谷困难:队长寻找NPC.")
          local searchPos = tarScenePos
          if posIndex > #searchPos then
            posIndex = 1
          end
          local tmp = searchPos[posIndex]
          if curScene ~= tarSceneID or false == JLG_FindNPC() then
            MoveTo(tmp.x, tmp.y, tarSceneID, nil, nil, nil, sf_movecb_findNPC, true, m_param.TransferItem)
            ChangeSceneLine()
            if false == JLG_FindNPC() then
              posIndex = posIndex + 1
            end
          else
            PushColorMsg("聚灵谷困难:发现npc")
            JLG_TalkNpc()
          end
        elseif not Player:IsFollow() then
          UseMount()
          DebugStr("聚灵谷困难:队员跟着队长")
          
          local function dy_cb(...)
            local leader, isleader = Team:GetLeaderInfo()
            if leader and leader.sceneID == m_data.sceneID then
              return false
            end
            if GetSceneID() == m_data.sceneID then
              return false
            end
            return MoveCallBack_GoToLeader(...)
          end
          
          GoToLeader(dy_cb, nil, true, true)
        else
          if IsKVKSceneName() then
            Player:TeamFollow(false, 300)
          end
          DebugStr("聚灵谷困难:队员组队跟随寻找NPC")
          Sleep(500)
        end
      end
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
  Player:TeamFollow(false, 300)
end

_SMain()
ScriptOnStop(m_script_name)
