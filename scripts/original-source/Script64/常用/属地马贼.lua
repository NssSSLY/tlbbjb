-- 反编译自 dfz64.dll 内嵌字节码 00378b88（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：字段 .属地马贼 → ["属地马贼"]（19 处）
local m_script_name = "属地马贼"
ScriptOnStart(m_script_name, true, false, false)
PickUpLua_SetItem(" 青铜虎印 白银虎印 黄金虎印 ")
g_config["属地马贼"] = {}
g_config["属地马贼"]["地图"] = GetConfigText("属地马贼", "地图")
g_config["属地马贼"].pos_x = GetConfigText("属地马贼", "等待X")
g_config["属地马贼"].pos_y = GetConfigText("属地马贼", "等待Y")
g_config["属地马贼"]["刷马地图"] = GetConfigCommbox("属地马贼", "刷马地图")
g_config["属地马贼"]["队给星宿"] = GetConfigBool("属地马贼", "队给星宿")
g_config["属地马贼"]["死亡结束"] = GetConfigBool("属地马贼", "死亡结束")
g_config["属地马贼"]["不清理小怪"] = GetConfigBool("属地马贼", "不清理小怪")
g_config["属地马贼"]["刷完兑换"] = GetConfigBool("属地马贼", "刷完兑换")
g_config["属地马贼"]["虎印兑换"] = GetConfigCommbox("属地马贼", "虎印兑换")
local m_param = {}
m_param.wait_scene = string.gsub(g_config["属地马贼"]["地图"], " ", "")
m_param.wait_sceneID = -1
m_param.wait_x = HandleTextToNumber(g_config["属地马贼"].pos_x, 0)
m_param.wait_y = HandleTextToNumber(g_config["属地马贼"].pos_y, 0)
m_param.sceneName = g_config["属地马贼"]["刷马地图"].text
m_param.sceneID = -1
m_param.leader_xx = g_config["属地马贼"]["队给星宿"]
m_param.die_stop = g_config["属地马贼"]["死亡结束"]
m_param.help_box = not g_config["属地马贼"]["不清理小怪"]
m_param.get_price = g_config["属地马贼"]["刷完兑换"]
m_param.prize = g_config["属地马贼"]["虎印兑换"].text
local m_data = {}
m_data.targetName = " 江湖枭雄 江湖匪首 绿林响马 "
m_data.scenePos = {}
m_data.scenePos["昆仑福地"] = {
  {x = 93, y = 38},
  {x = 29, y = 34},
  {x = 69, y = 58},
  {x = 61, y = 101},
  {x = 39, y = 74},
  {x = 63, y = 101},
  {x = 84, y = 79}
}
m_data.scenePos["汗血岭"] = {
  {x = 78, y = 90},
  {x = 43, y = 88},
  {x = 39, y = 49},
  {x = 89, y = 56}
}
m_data.scenePos["圣火宫"] = {
  {x = 26, y = 71},
  {x = 31, y = 33},
  {x = 59, y = 25},
  {x = 100, y = 27},
  {x = 101, y = 95},
  {x = 53, y = 104},
  {x = 51, y = 59},
  {x = 85, y = 50},
  {x = 74, y = 80}
}
m_data.sceneNPC = {}
m_data.sceneNPC["昆仑福地"] = {
  x = 98,
  y = 41,
  name = "属地王旗"
}
m_data.sceneNPC["汗血岭"] = {
  x = 85,
  y = 83,
  name = "属地王旗"
}
m_data.sceneNPC["圣火宫"] = {
  x = 24,
  y = 98,
  name = "属地王旗"
}
m_data.over = false
m_data.last_find_tick = -1
m_data.time = {
  {
    h = 10,
    m = 0,
    eh = 12,
    em = 0
  },
  {
    h = 16,
    m = 30,
    eh = 18,
    em = 30
  }
}
m_data.start_pos_index = 1
m_data.filter = {}
m_data.filter_tick = {}

local function SDMZ_GetStep()
  local nTime = GetServerTime()
  local nowTime = os.date("*t", nTime)
  local tm1 = {
    year = nowTime.year,
    month = nowTime.month,
    day = nowTime.day,
    hour = m_data.time[1].h,
    min = m_data.time[1].m,
    sec = 0
  }
  local tm1_end = {
    year = nowTime.year,
    month = nowTime.month,
    day = nowTime.day,
    hour = m_data.time[1].eh,
    min = m_data.time[1].em,
    sec = 0
  }
  local tm2 = {
    year = nowTime.year,
    month = nowTime.month,
    day = nowTime.day,
    hour = m_data.time[2].h,
    min = m_data.time[2].m,
    sec = 0
  }
  local tm2_end = {
    year = nowTime.year,
    month = nowTime.month,
    day = nowTime.day,
    hour = m_data.time[2].eh,
    min = m_data.time[2].em,
    sec = 0
  }
  local sTime1 = os.time(tm1)
  local eTime1 = os.time(tm1_end)
  local sTime2 = os.time(tm2)
  local eTime2 = os.time(tm2_end)
  local eTime1_check = sTime1 + 420
  local eTime2_check = sTime2 + 420
  if nTime >= sTime1 - 60 and nTime <= eTime1 then
    return 1, eTime1_check
  elseif nTime >= sTime2 - 60 and nTime <= eTime2 then
    return 2, eTime2_check
  end
  if nTime > eTime1 and nTime < eTime1 + 3600 or nTime > eTime2 and nTime < eTime2 + 3600 then
    return 3, 0
  end
  return 0, 0
end

local function SDMZ_Wait()
  if m_param.wait_sceneID >= 0 and m_param.wait_x > 0 and m_param.wait_y > 0 then
    GoToScene(m_param.wait_x, m_param.wait_y, m_param.wait_sceneID, nil, nil, nil, nil, true, true)
  end
end

local function SDMZ_QingGong(aSceneID)
  local nSceneID = aSceneID or GetSceneID()
  if 256 == nSceneID and SHG_To() then
    return true
  end
  return false
end

local function SDMZ_cb_move(_aX, _aY, _aSceneID)
  PickUpLua(nil, true)
  local nowScene = GetSceneID()
  if nowScene ~= _aSceneID then
    return false
  end
  if SDMZ_QingGong(nowScene) then
    return false
  end
  DebugStr("马贼移动")
  return true
end

local function SDMZ_OpenBox(aSceneID)
  local bBox = false
  local nSceneID = aSceneID or GetSceneID()
  local tObj = Enum2XByName("的宝物", {
    1,
    0,
    0,
    0
  }, {0, 15}, 1, 5)
  if #tObj > 0 then
    m_data.last_find_tick = GetTickCount()
  end
  tObj = ObjTickFilter(tObj, m_data.filter, 120000)
  if #tObj > 0 then
    PickUpLua()
    bBox = true
    local tmp = tObj[1]
    if Player:IsLeader() then
      if 5 == g_self.menpai then
        Skill:UseCheckBuff("谈笑自若")
      end
      local tRecord = GetTableFieldValue(m_data.filter_tick, "id", {
        tmp.id
      })
      if #tRecord > 0 then
        if GetTickCount() - tRecord[1].tick > 15000 then
          PushColorMsg("开箱子id:%d 超时！", tmp.id)
          m_data.filter = ObjTickPush(m_data.filter, tmp.id)
          for i = #m_data.filter_tick, 1, -1 do
            if m_data.filter_tick[i].id == tmp.id then
              table.remove(m_data.filter_tick, i)
              break
            end
          end
        end
      else
        table.insert(m_data.filter_tick, {
          id = tmp.id,
          tick = GetTickCount()
        })
      end
      DebugStr("开箱子", 2)
      MoveTo(tmp.x, tmp.y, nSceneID, 5, nil, MoveCallBack_state_2, SDMZ_cb_move)
      Dismount(200)
      Skill:UseName("初级隐遁", 700)
      Skill.CUseSkillByID(3, tmp.id, -1, -1)
      Sleep(800)
      PlayerStateTimeOut(5, 13)
      GetLuaValue("if IsWindowShow('LootPacket') then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close(); return 1 end; return 0 ", "b")
      Sleep(200)
    elseif m_param.help_box then
      DebugStr("不开箱子,协助清理怪物", 2)
      local tGuai = Enum2XByClass("怪物", {0, -1})
      GetAllPosDist(tGuai, tmp, "dist_tar")
      BubbleSort(tGuai, "dist_tar", 1)
      if #tGuai > 0 and tGuai[1].dist_tar <= 4 then
        local tmp = tGuai[1]
        FubenAttack(tmp.id)
      else
        FubenAttack(-1)
      end
    else
      DebugStr("不开箱子,不协助清理怪物", 2)
    end
  end
  return bBox
end

local function SDMZ_FindObj()
  local bFindObj = false
  local bAttack = false
  local nSceneID = GetSceneID()
  while true do
    local bOpenBox = false
    local tObj = Enum2XByName(m_data.targetName, {
      1,
      1,
      0,
      0
    }, {0, -1}, 1, 3)
    if #tObj > 0 then
      m_data.last_find_tick = GetTickCount()
      bFindObj = true
    end
    local tNPC = ObjFilterByClass(tObj, {
      1,
      0,
      0,
      0
    })
    local tGuai = ObjFilterByClass(tObj, {
      0,
      1,
      0,
      0
    })
    tGuai = ObjFilterByColor(tGuai, "红绿")
    if #tGuai > 0 then
      bAttack = true
      local tHong = ObjFilterByColor(tGuai, "红")
      if #tHong > 0 then
        BubbleByHP(tHong, 1)
        local tmp = tHong[1]
        if tmp.dst > 8 then
          RunTo(tmp.x, tmp.y, 0, 300)
        end
        FubenAttack(tmp.id)
      else
        bOpenBox = SDMZ_OpenBox(nSceneID)
        if not bOpenBox or not Player:IsLeader() then
          BubbleByDst(tGuai, 1)
          local tmp = tGuai[1]
          if tmp.dst > 15 then
            RunTo(tmp.x, tmp.y, 0, 300)
          end
          FubenAttack(tmp.id)
        end
      end
    elseif #tNPC > 0 then
      bOpenBox = SDMZ_OpenBox(nSceneID)
      if not bOpenBox and Player:IsLeader() then
        BubbleByDst(tNPC, 1)
        local tmp = tNPC[1]
        if tmp.dst > 3 then
          RunTo(tmp.x, tmp.y, 0, 200)
        end
        if tmp.dst < 5 then
          Player:TeamFollow(false, 200)
          Dismount()
          OpenTalk(tmp.id, 700)
          QuestFrameOptionClicked_Item("#{BHSD_150205_45}", 1, 1000)
        else
          MoveTo(tmp.x, tmp.y, nSceneID, 4, nil, MoveCallBack_state_2, SDMZ_cb_move)
        end
      end
    else
      bOpenBox = SDMZ_OpenBox(nSceneID)
      if not bOpenBox then
        break
      end
    end
    PickUpLua()
    if not Player:IsLeader() or 9 == Player:GetState() then
      break
    end
    Sleep(300)
    DebugStr("击杀马贼")
  end
  return bFindObj, bAttack
end

local function SDMZ_OnMove(aX, aY, aSceneID)
  PickUpLua()
  local nStep, unFindCheckTime = SDMZ_GetStep()
  local nowTime = GetServerTime()
  if (1 == nStep or 2 == nStep) and unFindCheckTime < nowTime and GetTickCount() - m_data.last_find_tick > 120000 then
    PushColorMsg(m_script_name .. ":已经没有马贼了.")
    m_data.over = true
    return false
  end
  local nSceneID = GetSceneID()
  if nSceneID ~= m_param.sceneID then
    return false
  end
  if not Player:IsLeader() then
    return false
  end
  if SDMZ_QingGong() then
    return true
  end
  SDMZ_FindObj()
  return true
end

local function SDMZ_Action()
  local arrPos = m_data.scenePos[m_param.sceneName]
  if nil == arrPos then
    PushColorMsg(m_script_name .. ":地图有误")
    Sleep(2000)
    return
  end
  if GetSceneID() == m_param.sceneID then
    if -1 == m_data.last_find_tick then
      m_data.last_find_tick = GetTickCount()
    end
    for i = 1, #arrPos do
      if i >= m_data.start_pos_index then
        local tmp = arrPos[i]
        MoveTo(tmp.x, tmp.y, m_param.sceneID, nil, nil, MoveCallBack_state_2, SDMZ_OnMove)
        PickUpLua()
        if not (not m_data.over and GetSceneID() == m_param.sceneID and Player:IsLeader()) then
          break
        end
      end
    end
    m_data.start_pos_index = 1
  else
    local function _cb(_aX, _aY, _aSceneID)
      if GetSceneID() == m_param.sceneID then
        return false
      end
      return MoveCallback_NoFuben(_aX, _aY, _aSceneID)
    end
    
    MoveTo(77, 77, m_param.sceneID, nil, nil, MoveCallBack_state_2, _cb)
  end
end

function _SMain(...)
  InitServerTime()
  if m_param.leader_xx and Player:IsLeader() and 5 ~= g_self.menpai then
    TeamChangeLeader(5)
  end
  m_param.wait_sceneID = GetSceneIDByName(m_param.wait_scene)
  m_param.sceneID = GetSceneIDByName(m_param.sceneName)
  m_data.last_find_tick = -1
  local arrPos = m_data.scenePos[m_param.sceneName]
  if nil == arrPos then
    PushColorMsg(m_script_name .. ":地图有误")
    return
  else
    if GetSceneID() == m_param.sceneID then
      m_data.start_pos_index = GetNearestPoint(arrPos)
    end
    arrPos = nil
  end
  local leaderDist = 3
  while true do
    local debugnote = ""
    if 9 == Player:GetState() then
      SetDingWeiZhu(1)
      DieOutAndGetPos()
      if m_param.die_stop then
        break
      end
    else
      local nStep, unFindCheckTime = SDMZ_GetStep()
      local nowTime = GetServerTime()
      if 3 == nStep then
        PushColorMsg(m_script_name .. ":已过了活动时间")
        break
      else
        if m_data.over then
          break
        end
        if Player:IsLeader() then
          if 0 == nStep then
            debugnote = " 未到活动时间等待中"
            SDMZ_Wait()
          elseif 1 == nStep or 2 == nStep then
            if unFindCheckTime < nowTime and -1 ~= m_data.last_find_tick and GetTickCount() - m_data.last_find_tick > 120000 then
              PushColorMsg(m_script_name .. ":活动时间,已经没有马贼了.")
              break
            end
            SDMZ_Action()
          end
        else
          debugnote = " 跟随队长"
          if -1 == m_data.last_find_tick then
            local nScene = GetSceneID()
            if 254 == nScene or 255 == nScene or 256 == nScene then
              m_data.last_find_tick = GetTickCount()
            end
          end
          if (1 == nStep or 2 == nStep) and unFindCheckTime < nowTime and -1 ~= m_data.last_find_tick and GetTickCount() - m_data.last_find_tick > 240000 then
            PushColorMsg(m_script_name .. ":活动时间,已经没有马贼了!")
            break
          end
          local followTick = GetTickCount()
          
          local function _cb(_aX, _aY, _aSceneID)
            PickUpLua()
            SDMZ_QingGong()
            if GetTickCount() - followTick > 120000 then
              return false
            end
            return MoveCallBack_GoToLeader(_aX, _aY, _aSceneID)
          end
          
          GoToLeader(_cb, MoveCallBack_state_2, false, false, leaderDist)
          local bFindObj, bAttack = SDMZ_FindObj()
          if bAttack then
            leaderDist = 7
          else
            leaderDist = 3
          end
        end
      end
    end
    Sleep(300)
    DebugStr(m_script_name .. debugnote)
  end
  local sceneName = GetCurrentSceneName()
  sceneName = string.gsub(sceneName, "1线", "")
  sceneName = string.gsub(sceneName, "2线", "")
  if "昆仑福地" == sceneName or "汗血岭" == sceneName or "圣火宫" == sceneName then
    local pos = m_data.sceneNPC[sceneName]
    
    local function _cb(_aX, _aY, _aSceneID)
      if GetSceneID() == 256 then
        SHG_Leave()
      end
      return true
    end
    
    MoveTo(pos.x, pos.y, GetSceneIDByName(sceneName), nil, nil, MoveCallBack_state_2, _cb)
    if m_param.get_price and m_param.prize ~= "不兑换" then
      DeleteDebugMsg("#{BHSD_150205_125}")
      DeleteDebugMsg("#{BHSD_150205_126")
      local tObj = Enum2XByName(pos.name, {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 and tObj[1].dst < 5 then
        local tmp = tObj[1]
        for i = 1, 6 do
          OpenTalk(tmp.id, 800)
          local hj = Bag:GetItemCount("黄金虎印")
          local by = Bag:GetItemCount("白银虎印")
          local qt = Bag:GetItemCount("青铜虎印")
          local tItem = {
            {
              option = "#{BHSD_150205_107}",
              count = hj
            },
            {
              option = "#{BHSD_150205_108}",
              count = by
            },
            {
              option = "#{BHSD_150205_109}",
              count = qt
            }
          }
          QuestFrameOptionClicked_Item("#{BHSD_150205_157}", 1, 1000)
          BubbleSort(tItem, "count", 2)
          QuestFrameOptionClicked_Item(tItem[1].option, 1, 1000)
          DialogOptionClicked(m_param.prize, 3, 1000)
          QuestFrameMissionComplete(0, 600)
          if IsInDebugMsg("#{BHSD_150205_125}") or IsInDebugMsg("#{BHSD_150205_126") then
            break
          end
        end
      end
    end
  end
  GoBackCity()
end

_SMain()
ScriptOnStop(m_script_name, false)
m_param = nil
