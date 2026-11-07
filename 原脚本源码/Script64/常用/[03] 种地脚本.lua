-- 反编译自 dfz64.dll 内嵌字节码 003607d9（unluac 2025-12-23；仅供分析）
local m_script_name = "种地"
ScriptOnStart(m_script_name)
local m_all_item = {
  "1级 -小麦",
  "2级 -大米",
  "3级 -玉米",
  "4级 -花生",
  "5级 -红薯",
  "6级 -高粱",
  "7级 -芝麻",
  "8级 -绿豆",
  "9级 -黄豆",
  "10级-蚕豆",
  "1级 -苎麻",
  "2级 -草棉",
  "3级 -亚麻",
  "4级 -木棉",
  "5级 -黄麻",
  "6级 -云棉",
  "7级 -槿麻",
  "8级 -绒棉",
  "9级 -青麻",
  "10级-彩棉"
}
g_config.zhongdi = {}
g_config.zhongdi.exp_over = false
g_config.zhongdi.type = {
  sel = -1,
  data = 0,
  text = ""
}
local nLine = ReadConfigInt("ZH", "zhk11")
if nLine >= 0 and nLine <= 10 then
  g_config.zhongdi.type.sel = nLine - 1
  g_config.zhongdi.type.text = m_all_item[g_config.zhongdi.type.sel + 1]
elseif nLine >= 12 and nLine <= 22 then
  g_config.zhongdi.type.sel = nLine - 2
  g_config.zhongdi.type.text = m_all_item[g_config.zhongdi.type.sel + 1]
end
g_config.zhongdi.jingli_empty = {
  sel = -1,
  data = 0,
  text = ""
}
g_config.zhongdi.jingli_empty.sel = ReadConfigInt("ZH", "zhk9")
g_config.zhongdi.scene = {
  sel = -1,
  data = 0,
  text = ""
}
if ReadConfigBool("ZH", "xzk55") then
  local nIdx = ReadConfigInt("ZH", "zhk10")
  if 0 == nIdx then
    g_config.zhongdi.scene.sel = 1
    g_config.zhongdi.scene.text = "洛阳"
  elseif 1 == nIdx then
    g_config.zhongdi.scene.sel = 2
    g_config.zhongdi.scene.text = "苏州"
  elseif 2 == nIdx then
    g_config.zhongdi.scene.sel = 3
    g_config.zhongdi.scene.text = "大理"
  elseif 3 == nIdx then
    g_config.zhongdi.scene.sel = 4
    g_config.zhongdi.scene.text = "太湖"
  elseif 4 == nIdx then
    g_config.zhongdi.scene.sel = 5
    g_config.zhongdi.scene.text = "楼兰"
  elseif 6 == nIdx then
    g_config.zhongdi.scene.sel = 6
    g_config.zhongdi.scene.text = "束河古镇"
  end
else
  g_config.zhongdi.scene.sel = 0
  g_config.zhongdi.scene.text = "不判断地图"
end
g_config.zhongdi.bagfull = {
  sel = -1,
  data = 0,
  text = ""
}
nLine = ReadConfigInt("ZH", "zhk39")
if 0 == nLine then
  g_config.zhongdi.bagfull.sel = 3
elseif 1 == nLine then
  g_config.zhongdi.bagfull.sel = 0
elseif 2 == nLine then
  g_config.zhongdi.bagfull.sel = 1
end
g_config.zhongdi.wanchan = ReadConfigBool("ZH", "xzk54")
g_config.zhongdi.safepos_wait = ReadConfigBool("ZH", "xzk159")
g_config.zhongdi.safe_scene = ReadConfigText("ZH", "bjk98")
g_config.zhongdi.safe_x = ReadConfigInt("ZH", "bjk24")
g_config.zhongdi.safe_y = ReadConfigInt("ZH", "bjk96")
local m_param = {}
local m_SearchPos = {}
m_SearchPos[LUOYANG_ID] = {
  {x = 148, y = 315},
  {x = 186, y = 395},
  {x = 329, y = 390},
  {x = 360, y = 321},
  {x = 368, y = 306}
}
m_SearchPos[1] = {
  {x = 235, y = 118},
  {x = 222, y = 118},
  {x = 315, y = 112},
  {x = 327, y = 118},
  {x = 131, y = 239},
  {x = 130, y = 216},
  {x = 316, y = 371},
  {x = 333, y = 371}
}
m_SearchPos[2] = {
  {x = 302, y = 217},
  {x = 302, y = 249},
  {x = 113, y = 292},
  {x = 103, y = 292},
  {x = 21, y = 197},
  {x = 27, y = 93}
}
m_SearchPos[4] = {
  {x = 172, y = 198},
  {x = 187, y = 198}
}
m_SearchPos[246] = {
  {x = 103, y = 206},
  {x = 100, y = 227},
  {x = 46, y = 210}
}
m_SearchPos[260] = {
  {x = 235, y = 258},
  {x = 292, y = 274},
  {x = 292, y = 262}
}

local function ZD_DBConfig(aSave, aCfg)
  if aSave then
    local str = g_json.encode(aCfg)
    PlayerConfigSet("种地记录", str, "记录")
  else
    local str = PlayerConfigGet("种地记录", "记录")
    if "" == str then
      return nil
    end
    local tCfg = g_json.decode(str)
    return tCfg
  end
end

local function ZD_Init()
  m_param.exp_over = g_config.zhongdi.exp_over
  m_param.info = nil
  m_param.bagfulltime = -1
  m_param.clickParam = {
    254,
    255,
    256,
    257
  }
  m_param.itemName = "物品的名称"
  local ZaoCan = {
    {
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10
    },
    {
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22
    }
  }
  local WanCan = {
    {
      25,
      26,
      27,
      28,
      29,
      30,
      31,
      32,
      33,
      34
    },
    {
      37,
      38,
      39,
      40,
      41,
      42,
      43,
      44,
      45,
      46
    }
  }
  if g_config.zhongdi.type.sel >= 0 and g_config.zhongdi.type.sel <= 9 then
    m_param.zaochan_val = ZaoCan[1][g_config.zhongdi.type.sel + 1]
    m_param.wanchan_val = WanCan[1][g_config.zhongdi.type.sel + 1]
  elseif g_config.zhongdi.type.sel >= 10 and g_config.zhongdi.type.sel <= 19 then
    m_param.zaochan_val = ZaoCan[2][g_config.zhongdi.type.sel - 9]
    m_param.wanchan_val = WanCan[2][g_config.zhongdi.type.sel - 9]
  else
    PushColorMsg("种地:请选择正确的种植类型")
    return false
  end
  local _, _, name = string.find(g_config.zhongdi.type.text, "-(.+)")
  if name then
    m_param.itemName = name
  end
  return true
end

local function ZD_GetScriptID(aSceneName)
  if "苏州" == aSceneName then
    return 714093
  elseif "大理" == aSceneName then
    return 714057
  elseif "洛阳" == aSceneName then
    return 714021
  elseif "楼兰" == aSceneName then
    return 714201
  elseif "太湖" == aSceneName then
    return 714211
  elseif "束河古镇" == aSceneName then
    return 714129
  end
  return -1
end

local function ZD_old_ClickZaoWan(aSceneName)
  local bWanChan = g_config.zhongdi.wanchan
  local nEnergy = Player:GetDataInt("ENERGY")
  if nEnergy < 60 and nEnergy >= 0 and 0 == g_config.zhongdi.jingli_empty.sel and "太湖" ~= aSceneName then
    bWanChan = true
  end
  local nParam = 0
  local nParam2 = m_param.zaochan_val
  if bWanChan then
    nParam2 = m_param.wanchan_val
    nParam = m_param.clickParam[2]
    if "束河古镇" == aSceneName then
      nParam = m_param.clickParam[3]
      if g_config.zhongdi.type.sel >= 10 then
        nParam = m_param.clickParam[4]
      end
    end
  else
    nParam = m_param.clickParam[1]
    if "束河古镇" == aSceneName and g_config.zhongdi.type.sel >= 10 then
      nParam = m_param.clickParam[2]
    end
  end
  return nParam, nParam2
end

local function ZD_ClickZaoWan(aSceneName)
  local bWanChan = g_config.zhongdi.wanchan
  local nEnergy = Player:GetDataInt("ENERGY")
  if nEnergy < 60 and nEnergy >= 0 and 0 == g_config.zhongdi.jingli_empty.sel and "太湖" ~= aSceneName then
    bWanChan = true
  end
  if bWanChan then
    if "束河古镇" == aSceneName then
      if g_config.zhongdi.type.sel >= 0 and g_config.zhongdi.type.sel <= 9 then
        return "种植晚产粮食作物"
      else
        return "种植晚产经济作物"
      end
    end
    return "种植晚产植物"
  end
  if "束河古镇" == aSceneName then
    if g_config.zhongdi.type.sel >= 0 and g_config.zhongdi.type.sel <= 9 then
      return "种植早产粮食作物"
    else
      return "种植早产经济作物"
    end
  end
  return "种植早产植物"
end

local function ZD_EnumNpcZuWu(aNpcID)
  local tAll = Enum2XByClass("NPC 矿地")
  local tZZW = ObjFilterByStrClass(tAll, "矿地")
  local tDCR = ObjFilterByName(tAll, "稻草人")
  for i = 1, #tDCR do
    if tDCR[i].id == aNpcID then
      local tObj1 = {}
      for j = 1, #tZZW do
        if GetDist(tZZW[j].x, tZZW[j].y, tDCR[i].x, tDCR[i].y) < 4 then
          tObj1[#tObj1 + 1] = tZZW[j]
        end
      end
      return tObj1
    end
  end
  return {}
end

local function ZD_SearchEmptyDCR()
  local tAll = Enum2XByClass("NPC 矿地")
  local tZZW = ObjFilterByStrClass(tAll, "矿地")
  local tDCR = ObjFilterByName(tAll, "稻草人")
  local tKong = {}
  for i = 1, #tDCR do
    local bkong = true
    for j = 1, #tZZW do
      if GetDist(tZZW[j].x, tZZW[j].y, tDCR[i].x, tDCR[i].y) < 3 then
        bkong = false
        break
      end
    end
    if bkong then
      local n = #tKong + 1
      tKong[n] = tDCR[i]
    end
  end
  if #tKong <= 0 then
    return nil
  end
  BubbleByDst(tKong, 1)
  return {
    id = tKong[1].id,
    x = tKong[1].x,
    y = tKong[1].y
  }
end

local function ZD_CheckZhongDi(aNPC)
  CloseWindow("Quest")
  local cur_scene_name = GetCurrentSceneName()
  cur_scene_name = string.gsub(cur_scene_name, "1线", "")
  cur_scene_name = string.gsub(cur_scene_name, "2线", "")
  while true do
    if IsWindowVisible("Quest") then
      local strText = GetNPCEventList_Item(0)
      if string.find(strText, "每种作物都可以分为晚产和早产两种", nil, true) or string.find(strText, "这里只能种植早产植物", nil, true) then
        local clickText = ZD_ClickZaoWan(cur_scene_name)
        if not DialogOptionClicked(clickText, 1, 600) then
          CloseAllWindow()
        end
        QuestFrameOptionClicked_Item(m_param.itemName, 3, 600)
      elseif string.find(strText, "请选择你要种的植物", nil, true) then
        if not QuestFrameOptionClicked_Item(m_param.itemName, 3, 600) then
          CloseAllWindow()
          break
        end
      elseif string.find(strText, "不能连续种植", nil, true) then
        local _, _, nMin = string.find(strText, "(%d+)")
        nMin = tonumber(nMin) or -1
        m_param.info = {}
        m_param.info.x = aNPC.x
        m_param.info.y = aNPC.y
        m_param.info.id = aNPC.id
        m_param.info.sceneName = cur_scene_name
        m_param.info.nexttime = os.time() - 1
        if nMin > 0 then
          m_param.info.nexttime = os.time() + nMin * 60 + 30
        end
        ZD_DBConfig(true, m_param.info)
        break
      elseif string.find(strText, "土地已被种植", nil, true) then
        DeleteDebugMsg("别人种的庄稼")
        local tObj = ZD_EnumNpcZuWu(aNPC.id)
        if #tObj > 0 and tObj[1].zwType == 711002 then
          do
            local tmp = tObj[1]
            Dismount()
            OpenPackage(tmp.id, 1500)
            if IsInDebugMsg("别人种的庄稼") then
              m_param.info = nil
              break
            end
            PushDebugMessage("种地：可以收割")
            break
          end
          break
        end
        m_param.info = nil
        break
      elseif string.find(strText, "精力不足", nil, true) then
        if 0 ~= g_config.zhongdi.jingli_empty.sel then
          m_param.over = true
          PushDebugMessage("种地：无精力停止种地！")
          break
        else
          Sleep(30000)
        end
      else
        CloseAllWindow()
      end
    else
      OpenTalk(aNPC.id, 400)
      PlayerStateTimeOut(2, 8)
    end
    if not FindObjByTID(aNPC.id) then
      break
    end
    Sleep(200)
    DebugStr("种地:对话NPC")
  end
end

local function ZD_CheckRecord()
  local info = ZD_DBConfig(false)
  if info and info.sceneName then
    if g_config.zhongdi.scene.text == info.sceneName or g_config.zhongdi.scene.sel <= 0 then
      local nTimeNow = os.time()
      if nTimeNow < info.nexttime then
        m_param.info = info
        PushColorMsg("种地：记录地图:%s 坐标x:%s 坐标y:%s 过%s秒后可收地", info.sceneName, math.floor(info.x), math.floor(info.y), info.nexttime - nTimeNow)
      elseif nTimeNow > info.nexttime + 960 then
        PushColorMsg("种地:记录数据已失效")
      else
        m_param.info = info
        PushColorMsg("种地：记录地图:%s 坐标x:%s 坐标y:%s 可收地", info.sceneName, math.floor(info.x), math.floor(info.y))
      end
    else
      PushColorMsg("种地:指定地图与上次记录的地图不同！按指定地图种地")
    end
  end
  if m_param.info then
    if g_config.zhongdi.scene.sel <= 0 then
      g_config.zhongdi.scene.text = info.sceneName
    end
  elseif g_config.zhongdi.scene.sel <= 0 then
    g_config.zhongdi.scene.text = GetCurrentSceneName()
    g_config.zhongdi.scene.text = string.gsub(g_config.zhongdi.scene.text, "1线", "")
    g_config.zhongdi.scene.text = string.gsub(g_config.zhongdi.scene.text, "2线", "")
  end
  m_param.sceneID = GetSceneIDByName(g_config.zhongdi.scene.text)
end

local function ZD_SearchRipeDCR()
  local tAll = Enum2XByClass("NPC 矿地")
  local tZZW = ObjFilterByStrClass(tAll, "矿地")
  local tDCR = ObjFilterByName(tAll, "稻草人")
  local tRipe = {}
  for i = 1, #tDCR do
    for j = 1, #tZZW do
      if GetDist(tZZW[j].x, tZZW[j].y, tDCR[i].x, tDCR[i].y) < 3 and tZZW[j].zwType == 711002 then
        tRipe[#tRipe + 1] = tDCR[i]
        break
      end
    end
  end
  for i = 1, #tRipe do
    tRipe[i].hp = 0
    for j = 1, #tZZW do
      if GetDist(tZZW[j].x, tZZW[j].y, tRipe[i].x, tRipe[i].y) < 3 then
        tRipe[i].hp = tRipe[i].hp + 1
      end
    end
  end
  BubbleByHP(tRipe, 1)
  return tRipe
end

local function ZD_SearchNPCNearst(aNpcID)
  local tAll = Enum2XByClass("NPC 矿地")
  local tZZW = ObjFilterByStrClass(tAll, "矿地")
  local tDCR = ObjFilterByName(tAll, "稻草人")
  for i = 1, #tDCR do
    if tDCR[i].id == aNpcID then
      local tObj1 = {}
      for j = 1, #tZZW do
        if GetDist(tZZW[j].x, tZZW[j].y, tDCR[i].x, tDCR[i].y) < 3 then
          tObj1[#tObj1 + 1] = tZZW[j]
        end
      end
      if tDCR[i].dst > 3 then
        RunTo(tDCR[i].x, tDCR[i].y, 0, 400)
      end
      return tObj1
    end
  end
  return {}
end

local function ZD_QiangQiang(tNPC)
  local cur_scene_name = GetCurrentSceneName()
  cur_scene_name = string.gsub(cur_scene_name, "1线", "")
  cur_scene_name = string.gsub(cur_scene_name, "2线", "")
  local cur_scene_id = GetSceneIDByName(cur_scene_name)
  if cur_scene_id == m_param.sceneID then
    local scriptID = ZD_GetScriptID(cur_scene_name)
    local param1, param2 = ZD_old_ClickZaoWan(cur_scene_name)
    local nTimeOut = -1
    while true do
      local tObj = ZD_SearchNPCNearst(tNPC.id)
      if #tObj > 0 then
        if tObj[1].zwType ~= 711002 then
          break
        end
        if #tObj <= 1 then
          if -1 == nTimeOut then
            nTimeOut = os.time()
          end
          SP_OpenTalkAndClickedClickedOption(tNPC.id, scriptID, param1, param2)
        end
        DebugStr("种地:等待剩下最后一块地时抢！")
      else
        if not FindObjByTID(tNPC.id) then
          break
        end
        if -1 == nTimeOut then
          nTimeOut = os.time()
        end
        SP_OpenTalkAndClickedClickedOption(tNPC.id, scriptID, param1, param2)
        DebugStr("种地:抢种中")
      end
      Sleep(200)
      if -1 ~= nTimeOut and os.time() - nTimeOut > 30 then
        break
      end
    end
  end
  ZD_CheckZhongDi(tNPC)
end

local function ZD_movecb_sh(aX, aY, aScene)
  return MoveCallback_NoFuben(aX, aY, aScene)
end

local function ZD_search_cb(aX, aY, aScene)
  if GetSceneID() == m_param.sceneID then
    local tNPC = ZD_SearchEmptyDCR()
    if tNPC then
      ZD_CheckZhongDi(tNPC)
    else
    end
    if m_param.info or m_param.over then
      return false
    end
  end
  return ZD_movecb_sh(aX, aY, aScene)
end

local function ZD_SearchScene()
  for i = 1, #m_SearchPos[m_param.sceneID] do
    local pos = m_SearchPos[m_param.sceneID][i]
    MoveTo(pos.x, pos.y, m_param.sceneID, 1, nil, nil, ZD_search_cb, true, true)
    if m_param.info or m_param.over then
      break
    end
    Sleep(200)
  end
end

local function ZD_SafeSceneWait()
  if not g_config.zhongdi.safepos_wait or not m_param.info then
    return
  end
  while not (os.time() >= m_param.info.nexttime) do
    GoSafeScene(g_config.zhongdi.safe_scene, g_config.zhongdi.safe_x, g_config.zhongdi.safe_y)
    local nMiff = m_param.info.nexttime - os.time()
    if nMiff > 60 then
      DebugStr(fmt("种地：在安全地图等待作物成熟,剩余%s分钟", math.floor(nMiff / 60)))
    else
      DebugStr(fmt("种地：在安全地图等待作物成熟,剩余%s秒。", nMiff))
    end
    Sleep(5000)
  end
end

local function ZD_CheckBagFull()
  Bag_DeleteItem()
  local nSpaceNum = Bag:GetSpaceNum(1)
  if 0 == nSpaceNum then
    Bag_DeleteItem(true)
    nSpaceNum = Bag:GetSpaceNum(1)
    if 0 == nSpaceNum then
      if 3 == g_config.zhongdi.bagfull.sel then
        PushDebugMessage("种地:背包已满,无可销毁的物品,停止运行！")
        return false
      end
      if 2 == g_config.zhongdi.bagfull.sel then
        Bag_Move2TempBank(m_param.itemName)
      end
      if os.time() - m_param.bagfulltime > 180 then
        if 1 == g_config.zhongdi.bagfull.sel then
          PushDebugMessage("种地:背包已满,执行交易老板！")
        elseif 0 == g_config.zhongdi.bagfull.sel then
          PushDebugMessage("种地:背包已满,执行存仓！")
          MainBankSaveItem()
        end
        m_param.bagfulltime = os.time()
      else
        DebugStr("种地:距离上次交易或存仓时间还没到3分钟,忽略！")
      end
    end
  end
  return true
end

local function ZD_CheckShouGe()
  local npc = m_param.info
  local sceneID = GetSceneIDByName(npc.sceneName)
  MoveTo(npc.x, npc.y, sceneID, 1, nil, nil, ZD_movecb_sh, true, true)
  Sleep(300)
  local tObj = ZD_EnumNpcZuWu(npc.id)
  if #tObj > 0 then
    local tmp = tObj[1]
    if tmp.zwType == 711002 then
      Player:DispelBuffByName("解除变身状态")
      Dismount()
      OpenPackage(tmp.id, 500)
      PlayerStateTimeOut(8, 8)
      tObj = ZD_EnumNpcZuWu(npc.id)
      if 1 == #tObj then
        local scriptID = ZD_GetScriptID(npc.sceneName)
        local clickText = ZD_ClickZaoWan(npc.sceneName)
        OpenTalk(npc.id, 300)
        PlayerStateTimeOut(2, 6)
        DialogOptionClicked(clickText, 1, 600)
        local strText = GetNPCEventList_Item(0)
        if "请选择你要种的植物" == strText then
          for i = 1, 10 do
            local str = [[
                            setmetatable(_G, {__index = Quest_Env})
                            if this:IsVisible() then
                                if IsWindowShow("LootPacket") == true then
                                    PlayerPackage:PickAllItem()
                                end
                                meQuestOptionClicked_Item("%s",3)
                            end
                        ]]
            GetLuaValue(fmt(str, m_param.itemName))
            Sleep(80)
            local strText = GetNPCEventList_Item(0)
            if "请选择你要种的植物" ~= strText then
              break
            end
          end
        end
      else
        Sleep(100)
        GetLuaValue("if IsWindowShow('LootPacket')==true then PlayerPackage:PickAllItem();end;")
      end
    else
      ZD_CheckZhongDi(npc)
      if m_param.info and not g_config.zhongdi.safepos_wait then
        local nDiff = m_param.info.nexttime - os.time()
        if nDiff < 0 then
          Sleep(5000)
        else
          Sleep(20000)
        end
      end
    end
  else
    local tNPC = ZD_SearchEmptyDCR()
    if tNPC then
      ZD_CheckZhongDi(tNPC)
    end
  end
end

function _SMain(...)
  LeaveSpecialScene(nil, nil)
  if not ZD_Init() then
    return
  end
  ZD_CheckRecord()
  if m_SearchPos[m_param.sceneID] == nil then
    PushDebugMessage("种地:无法确定种植地图")
    return
  end
  local bFirst = true
  while true do
    if m_param.exp_over then
      local curLevel, canUp = GetLifeInfo(10)
      if canUp then
        LogMsg("种地：熟练度已满可升级!")
        break
      end
    end
    if not ZD_CheckBagFull() or m_param.over then
      break
    end
    if m_param.info then
      ZD_SafeSceneWait()
      ZD_CheckShouGe()
    else
      if bFirst then
        bFirst = false
        if GetSceneID() == m_param.sceneID then
          local tNPC = Enum2XByName("稻草人", {
            1,
            0,
            0,
            0
          }, nil, 1, 0)
          if #tNPC > 0 and tNPC[1].dst < 4 then
            ZD_CheckZhongDi(tNPC[1])
          end
        end
      end
      if not m_param.info then
        ZD_SearchScene()
      end
    end
    Sleep(300)
    DebugStr("种地中")
  end
end

_SMain()
ScriptOnStop(m_script_name)
