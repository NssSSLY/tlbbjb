-- 反编译自 dfz64.dll 内嵌字节码 00267ca1（unluac 2025-12-23；仅供分析）
local m_script_name = "惩凶打图"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.attack = true
CDG.die.out = true
g_pick.check = true
if GetConfigBool("惩凶打图", "全捡包裹") then
  g_pick.pickmode = 0
else
  PickUpLua_SetItem(" 藏宝图 稀世珍宝图 宝图密匣 未破译的藏宝图 ")
end
local m_param = {}
m_param.allRound = HandleTextToNumber(GetConfigText("惩凶打图", "打图环数"), 0)
m_param.use_shoufei_npc = GetConfigBool("惩凶打图", "收费传送")
m_param.dwf_sceneID = 1
m_param.dwf_x = 224
m_param.dwf_y = 227
m_param.dwf_max_count = HandleTextToNumber(GetConfigText("通用", "定位符数量"), 5)
if m_param.dwf_max_count > 5 then
  m_param.dwf_max_count = 5
end
m_param.dwf_makebyhz = GetConfigBool("惩凶打图", "制作定位")
m_param.hz_price = HandleTextToNumber(GetConfigText("惩凶打图", "黄纸价格"), 0)
if m_param.hz_price <= 0 then
  m_param.hz_price = 60000
end
m_param.dwf_buy = GetConfigBool("惩凶打图", "购买定位")
m_param.dwf_price = HandleTextToNumber(GetConfigText("通用", "定位符价格"), 0)
if m_param.dwf_price <= 0 then
  m_param.dwf_price = 30000
end
local m_data = {}
m_data.round = 0
m_data.lasttime_find_target = 0
m_data.lasttime_dwf = 0

local function CXDT_CheckDingWeiFu()
  if (m_param.dwf_buy or m_param.dwf_makebyhz) and IsSafeSceneID() then
    local tDWF = Bag:FindDingWei()
    if #tDWF <= 1 then
      local nCnt = m_param.dwf_max_count - #tDWF
      if nCnt >= 0 then
        if 0 == m_data.lasttime_dwf or GetTickCount() - m_data.lasttime_dwf > 300000 then
          if 0 == nCnt then
            nCnt = 1
          end
          Player:TeamFollow(false, 300)
          if m_param.dwf_makebyhz then
            PushColorMsg("定位符剩余不到2张,使用黄纸加工！")
            for i = 1, 6 do
              StopRun()
              MakeDingWeiFu(3, nil, true, m_param.hz_price)
              Sleep(500)
              tDWF = Bag:FindDingWei()
              if #tDWF >= m_param.dwf_max_count then
                break
              end
            end
          elseif m_param.dwf_buy then
            PushColorMsg("定位符剩余不到2张,前往商会购买！")
            local nNeedMoney = nCnt * m_param.dwf_price
            Bank_GetMoney(nNeedMoney)
            for i = 1, 6 do
              PushDebugMessage("购买定位符:价格不超过 %d 铜", m_param.dwf_price)
              ShangHui_BuyItem("定位符", 1, m_param.dwf_price, 3)
              Sleep(1000)
              tDWF = Bag:FindDingWei()
              if #tDWF >= m_param.dwf_max_count then
                break
              end
            end
          end
          Bank_SaveMoney(5000)
          m_data.lasttime_dwf = GetTickCount()
        else
          DebugStr(m_script_name .. ":距离上次购买制作定位符少于5分钟,忽略此次！", 2)
        end
      end
    end
  end
  if IsSafeSceneID() then
    local function _NeedSetDingWeiFU()
      local tDWF = Bag:FindDingWei()
      
      local tNeedDingWei = {}
      for i = 1, #tDWF do
        local tmp = tDWF[i]
        if 0 == tmp.dwf.data then
          table.insert(tNeedDingWei, tmp)
        end
      end
      return tNeedDingWei
    end
    
    local nTickOut = GetTickCount()
    while true do
      local tDingWei = _NeedSetDingWeiFU()
      if 0 == #tDingWei then
        break
      end
      DebugStr("定位符需要定位")
      Player:TeamFollow(false, 300)
      GoToScene(m_param.dwf_x, m_param.dwf_y, m_param.dwf_sceneID)
      Sleep(500)
      Dismount()
      Sleep(800)
      math.randomseed(GetTickCount())
      local idx = math.random(1, #tDingWei)
      local tmp = tDingWei[idx]
      Bag:UseItem(tmp.index, 800)
      PlayerStateTimeOut(5, 20)
      if GetTickCount() - nTickOut > 60000 then
        PushColorMsg(m_script_name .. ":定位符定位超时")
        break
      end
    end
  end
end

local function CXDT_FindTarget()
  local tObj = Enum2XByClass("怪物", {0, -1})
  tObj = ObjFilterByColor(tObj, "红绿")
  local tTemp = {}
  for i = 1, #tObj do
    if string.len(tObj[i].name) >= 4 then
      local char1 = string.sub(tObj[i].name, 1, 2)
      local char2 = string.sub(tObj[i].name, 3, 4)
      if string.find("吴周李赵王郑孙钱", char1, nil, true) and string.find("伯之成恩仁元文曾BB赫虎朗亮霸泰烈古", char2, nil, true) then
        tTemp[#tTemp + 1] = tObj[i]
      end
    end
  end
  local tTarget = {}
  for i = 1, #tTemp do
    local tmp = tTemp[i]
    if not Target:FindBuff(tmp, "漕运强盗") then
      table.insert(tTarget, tmp)
    end
  end
  return tTarget
end

local function CXDT_OnMission()
  local boss
  local nParam = {}
  for i = 0, 4 do
    nParam[i] = GetMissionVariableByName_Item("#{CXDT_090304_01}", i)
  end
  if 0 == nParam[0] then
    GoToScene(nParam[3], nParam[4], nParam[2], 5, true, nil, nil, m_param.use_shoufei_npc, true)
    Sleep(200)
    Dismount()
    Sleep(200)
    CDG.skill_attack_jinji_disable = " 归元阵 天覆阵 地载阵 风扬阵 暗器护体 "
    FubenAttack(-1)
    local nOldSceneID = GetSceneID()
    local tOld = CXDT_FindTarget()
    local nUseTick = -1
    while true do
      local bUse = Bag:UseItemByName("惩恶令", 100, Bag:EnumRenWuItem())
      if bUse then
        nUseTick = GetTickCount()
        m_data.lasttime_find_target = 0
      end
      local tObj = CXDT_FindTarget()
      local tNew = TableDeleteTable(tObj, tOld, "id")
      local tid = -1
      if 0 == #tNew then
        local nowScene = GetSceneID()
        if nOldSceneID ~= nowScene or IsDiFuScene(nowScene) then
          break
        end
        for i = 1, #tOld do
          if FindObjByTID(tOld[i].id) then
            tid = tOld[i].id
            break
          end
        end
      else
        BubbleByDst(tNew, 1)
        tid = tNew[1].id
      end
      if -1 ~= tid then
        Target:Attack(tid, 200)
        Dismount()
        boss = GoToTarget("", 3, tid)
        FubenAttack(tid)
        m_data.lasttime_find_target = 0
      elseif not bUse and (-1 == nUseTick or GetTickCount() - nUseTick > 6000) then
        break
      end
      if -1 == tid then
        GoToScene(nParam[3], nParam[4], nParam[2], 5, true, nil, nil, m_param.use_shoufei_npc, true)
        Dismount(600)
      end
      Sleep(100)
      if 0 ~= GetMissionVariableByName_Item("#{CXDT_090304_01}", 0) then
        break
      end
      DebugStr(m_script_name .. ":任务中")
    end
    Sleep(300)
    if 0 == GetMissionVariableByName_Item("#{CXDT_090304_01}", 0) then
      if 0 == m_data.lasttime_find_target then
        m_data.lasttime_find_target = GetTickCount()
      elseif GetTickCount() - m_data.lasttime_find_target > 40000 and -1 == nUseTick then
        PushDebugMessage(m_script_name .. ":无法找到目标,放弃本次打图任务！")
        local _, _, idScript = GetPlayerMission_Item("#{CXDT_090304_01}")
        QuestFrameMissionAbnegate(idScript)
        m_data.lasttime_find_target = 0
      end
    else
      local pos
      if boss then
        pos = {
          {
            x = boss.x,
            y = boss.y
          }
        }
      end
      if -1 == Player:GetBuff("乾坤壶：") then
        PickUpLua_Boss(15, 15, nil, pos)
      end
    end
  end
end

function _SMain(...)
  if Player:GetMoney() + Player:GetMoney(2) < 1000 then
    PushColorMsg(m_script_name .. ":金币不够10银")
    Bank_GetMoney(5000)
  end
  local npc = {
    x = 224,
    y = 226,
    sceneID = 1,
    name = "吴玠"
  }
  while true do
    local nComplete = GetMissionVariableByName_Item("#{CXDT_090304_01}", 0)
    if -1 == nComplete then
      Bag:UseItemByName("未破译的藏宝图", 800)
      m_data.lasttime_find_target = 0
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, nil, m_param.use_shoufei_npc, true)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{CXDT_090304_01}", 1, 600)
      local szText = GetNPCEventList_Item(1)
      if string.find(szText, "#{CXDT_090304_08}", nil, true) then
        Sleep(30000)
      elseif string.find(szText, "#{CXDY_090423_02}", nil, true) then
        PushDebugMessage(m_script_name .. ":打图次数上限!")
        break
      end
      local nNum = Bag:GetSpaceNum(0)
      if nNum <= 1 then
        ClearBag()
      end
      nNum = Bag:GetSpaceNum(0)
      if nNum <= 1 then
        MainBankSaveItem()
        Sleep(300)
      end
      nNum = Bag:GetSpaceNum(0)
      if nNum <= 1 then
        PushColorMsg(m_script_name .. ":背包空位小于1格!")
        break
      end
      XiaoChangHuiXue(70)
      CXDT_CheckDingWeiFu()
    elseif 0 == nComplete then
      CXDT_OnMission()
    elseif 1 == nComplete then
      m_data.lasttime_find_target = 0
      Bag:UseItemByName("未破译的藏宝图", 800)
      GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, nil, m_param.use_shoufei_npc, true)
      Sleep(600)
      QuestFrameOptionClicked_Item("#{CXDT_090304_01}", 1, 600)
      QuestFrameNextClicked(600)
      QuestFrameMissionComplete(nil, 600)
      m_data.round = m_data.round + 1
      if m_param.allRound > 0 and m_data.round >= m_param.allRound then
        PushColorMsg(m_script_name .. "：已经达到设置环数！")
        break
      end
    end
    Sleep(200)
    ClearBag()
    DebugStr(m_script_name)
  end
  for i = 1, 5 do
    Bag:UseItemByName("未破译的藏宝图", 800)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
