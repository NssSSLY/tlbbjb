-- 反编译自 dfz64.dll 内嵌字节码 00367515（unluac 2025-12-23；仅供分析）
local m_script_name = "钓鱼"
ScriptOnStart(m_script_name, false, false)
g_config.diaoyu = {}
g_config.diaoyu.scene = ReadConfigText("ZH", "bjk71")
g_config.diaoyu.yuming = ReadConfigText("ZH", "bjk74")
g_config.diaoyu.yuer = ReadConfigText("ZH", "bjk75")
g_config.diaoyu.yuer_count = ReadConfigInt("ZH", "bjk76")
g_config.diaoyu.pengren = ReadConfigBool("ZH", "xzk89")
g_config.diaoyu.over_time = ReadConfigInt("ZH", "bjk3")
g_DiaoYuPos = {}
g_DiaoYuPos[g_config.diaoyu.scene] = {
  {
    x = ReadConfigInt("ZH", "bjk72"),
    y = ReadConfigInt("ZH", "bjk73")
  }
}
local m_param = {}
m_param.sceneName = string.gsub(g_config.diaoyu.scene, " ", "")
m_param.sceneID = -1
m_param.yuer = string.gsub(g_config.diaoyu.yuer, " ", "")
m_param.yuer_count = HandleTextToNumber(g_config.diaoyu.yuer_count, 0)
m_param.yuming = HandleText_AddFuHao(g_config.diaoyu.yuming, " ", true)
m_param.pengren = g_config.diaoyu.pengren
m_param.over_time = HandleTextToNumber(g_config.diaoyu.over_time, 0)
m_param.time_start = -1
m_param.over = false

local function DY_BuyYuEr()
  local single_price = 0
  if m_param.yuer == "蚯蚓" then
    single_price = 100
  elseif m_param.yuer == "虹虫" then
    single_price = 200
  elseif m_param.yuer == "沙蚕" then
    single_price = 500
  end
  if m_param.yuer_count > 0 and single_price > 0 then
  else
    return
  end
  if not IsKVKSceneUnCity(m_param.sceneID) and single_price > 0 then
    local nCount = Bag:GetItemCount(m_param.yuer)
    if GetSceneID() ~= m_param.sceneID or 0 == nCount then
      do
        local nBuyCount = m_param.yuer_count - nCount
        if nBuyCount > 0 then
          PushColorMsg("钓鱼：需要购买鱼饵")
          local needMoney = nBuyCount * single_price
          local bagMoney = Player:GetMoney()
          if needMoney > bagMoney then
            Bank_GetMoney(needMoney, "洛阳")
          end
          for i = 1, 3 do
            GoToSceneNPC("芮福祥", 347, 284, LUOYANG_ID)
            QuestFrameOptionClicked_Item("买卖杂货", 1, 800)
            Shop_BuyItem(m_param.yuer, nBuyCount)
            Sleep(300)
            nCount = Bag:GetItemCount(m_param.yuer)
            if nCount >= m_param.yuer_count then
              goto lbl_96
            end
            nBuyCount = m_param.yuer_count - nCount
          end
        else
        end
      end
    end
  else
  end
  ::lbl_96::
end

local function DY_Init()
  if #m_param.yuming < 2 then
    PushColorMsg("钓鱼：请输入正确的鱼名")
    return false
  end
  if g_DiaoYuPos == nil then
    PushColorMsg("钓鱼坐标:加载坐标失败!")
    return false
  end
  if nil == g_DiaoYuPos[m_param.sceneName] then
    PushColorMsg("钓鱼坐标:无此地图数据,请编辑文件添加坐标!")
    return false
  end
  if 0 == #g_DiaoYuPos[m_param.sceneName] then
    PushColorMsg("钓鱼坐标:至少需要添加1个坐标!")
    return false
  end
  m_param.sceneID = GetSceneIDByName(m_param.sceneName)
  if -1 == m_param.sceneID then
    PushColorMsg("钓鱼：地图设置不正确")
    return false
  end
  CaiJiCheckTool("钓鱼竿 太公钓")
  DY_BuyYuEr()
end

local function DY_EnumObj()
  local tObj = Enum2XByClass("矿地")
  tObj = ObjFilterByName(tObj, m_param.yuming, 3)
  BubbleByDst(tObj)
  if #tObj > 0 then
    return tObj[1]
  end
  return nil
end

local function DY_KvkScene()
  local param = {
    over = false,
    bagfullover = true,
    syzq = true,
    ylxs = false,
    jctq = false,
    cjyd = false,
    hcjx = false,
    checktick = -1,
    jlbz = {
      cmpmin = 0,
      cmpmax = 250,
      action = 0
    },
    safepos = {
      sceneName = "",
      x = -1,
      y = -1
    },
    filter = {},
    item = "",
    scene = {},
    cb = nil
  }
  param.item = m_param.yuming
  param.jlbz.cmpmin = 20
  param.jlbz.action = 2
  param.cj_type = 3
  if m_param.over_time > 0 then
    function param.cb()
      if GetTickCount() - m_param.time_start > m_param.over_time * 60 * 1000 then
        PushColorMsg("钓鱼：已经钓了%s分钟,结束！", m_param.over_time)
        
        return true
      end
      return false
    end
  end
  table.insert(param.scene, {
    name = m_param.sceneName,
    pos = g_DiaoYuPos[m_param.sceneName]
  })
  CaiJiOnAction(param)
end

local function DY_QuScene()
  local pos = g_DiaoYuPos[m_param.sceneName][1]
  if IsDestination(pos.x, pos.y, m_param.sceneID, 3) then
    Dismount()
    if m_param.pengren then
      local tItem = Bag:SearchItemName(m_param.yuming)
      local nAllCount = TableFieldCount(tItem, "count")
      if nAllCount >= 20 then
        local nSpace = Bag:GetSpaceNum(1)
        if nSpace > 0 then
          Skill:UseID(Skill.baseID, Player:GetTID(), -1, -1)
          Sleep(1500)
          for i = 1, 2 do
            GetLuaValue("ComposeItem_Begin(558,4,-1);")
            Sleep(200)
            PlayerStateTimeOut(5, 10)
            GetLuaValue("ComposeItem_Begin(559,4,-1);")
            Sleep(200)
            PlayerStateTimeOut(5, 10)
            GetLuaValue("ComposeItem_Begin(560,4,-1);")
            Sleep(200)
            PlayerStateTimeOut(5, 10)
          end
        end
      end
    end
    if 0 == Bag:GetSpaceNum(1) then
      PushDebugMessage("钓鱼：材料栏已满")
      ClearBag()
      Sleep(500)
      if 0 == Bag:GetSpaceNum(1) then
        PushColorMsg("材料栏已满,无可清理物品,结束运行！")
        m_param.over = true
        return
      end
    end
    if Bag:GetItemCount(m_param.yuer) > 0 then
      if -1 == Player:GetBuff("鱼饵") then
        if 8 == Player:GetState() then
          RunTo(pos.x + 1, pos.y, 0, 500)
          RunTo(pos.x, pos.y + 1, 0, 500)
          RunTo(pos.x - 1, pos.y, 0, 500)
          RunTo(pos.x, pos.y - 1, 0, 500)
        end
        Bag:UseItemByName(m_param.yuer, 500)
        RunTo(pos.x, pos.y, 0, 500)
      end
    elseif -1 == Player:GetBuff("鱼饵") then
      DY_BuyYuEr()
    end
    GetLuaValue("if IsWindowShow('LootPacket')==true then PlayerPackage:PickAllItem();end;")
    if 8 ~= Player:GetState() then
      RunTo(pos.x, pos.y, 0, 1000)
      local fish = DY_EnumObj()
      if fish then
        OpenPackage(fish.id)
        Sleep(3000)
      end
    end
    Sleep(500)
  else
    MoveTo(pos.x, pos.y, m_param.sceneID, 3)
    Sleep(2000)
  end
end

function _SMain(...)
  LoadScript("caiji")
  m_param.time_start = GetTickCount()
  if false == DY_Init() then
    return
  end
  while true do
    if IsKVKSceneUnCity(m_param.sceneID) then
      DY_KvkScene()
    else
      DY_QuScene()
    end
    Sleep(500)
    DebugStr(m_script_name)
    if m_param.over_time > 0 and GetTickCount() - m_param.time_start > m_param.over_time * 60 * 1000 then
      PushColorMsg("钓鱼：已经钓了%s分钟,结束！", m_param.over_time)
      break
    end
    if m_param.over then
      break
    end
  end
  GoBackCity()
end

_SMain()
ScriptOnStop(m_script_name, false)
g_DiaoYuPos = nil
