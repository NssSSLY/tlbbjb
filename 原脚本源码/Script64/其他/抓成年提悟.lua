-- 反编译自 dfz64.dll 内嵌字节码 002aa437（unluac 2025-12-23；仅供分析）
local m_script_name = "抓成年提悟"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
CDG.tulingzhu = true
CDG.jgyc = true
local m_catch = {}
local m_param = {}
local m_pet = {
  "成年雪貂",
  "成年駮马",
  "成年大猩猩",
  "成年北极熊",
  "成年剑齿虎",
  "成年鹰",
  "成年鸵鸟",
  "成年老虎",
  "成年野猪",
  "成年燕子",
  "成年剑龙",
  "成年孔雀",
  "成年豹子",
  "成年猫头鹰",
  "成年犀牛",
  "成年松鼠",
  "成年狼",
  "成年蜥蜴",
  "成年冰蚕",
  "成年小象"
}
m_param.on_full = 2
m_param.shopup_value = -1
m_param.catchFilter = {}
m_param.wxup_name = HandleText_AddFuHao(ReadConfigText("ZH", "bjk30"))
m_param.wxup_value = ReadConfigInt("ZH", "bjk60")
local xPos = ReadConfigInt("ZH", "bjk50")
local yPos = ReadConfigInt("ZH", "bjk59")
local nSceneIndex = ReadConfigInt("ZH", "zhk21")
local nPetIndex = ReadConfigInt("ZH", "zhk23")
m_catch.pos = {
  {x = xPos, y = yPos}
}
if 1 == nSceneIndex then
  m_catch.sceneName = "圣兽山"
else
  m_catch.sceneName = "玄武岛"
end
m_catch.sceneID = GetSceneIDByName(m_catch.sceneName)
m_catch.petName = HandleText_AddFuHao(m_pet[nPetIndex])
m_catch.attackMode = "优先绿怪"

local function ZhuaPet_GetCatchIndex()
  local allPet = Pet:GetAllInfo()
  for i = #allPet, 1, -1 do
    local tmp = allPet[i]
    if string.find(m_catch.petName, " " .. tmp.name .. " ", nil, true) then
      return tmp.index
    end
  end
  return -1
end

local function ZhuaPet_SaleNPC()
  local bNext = true
  DeleteDebugMsg("#{JJKHD_120808_103}")
  while true do
    GoToSceneNPC("沙洲冷", 84, 37, 112)
    QuestFrameOptionClicked_Item("我要出售珍兽", 1, 1000)
    if IsInDebugMsg("#{JJKHD_120808_103}") then
      PushColorMsg(m_script_name .. ":今日已上限")
      bNext = false
      break
    end
    if IsWindowVisible("MissionReply") and IsWindowVisible("PetList") then
      local idx = ZhuaPet_GetCatchIndex()
      if -1 ~= idx then
        GetLuaValue(fmt("Exchange:AddPet(%d)", idx))
        Sleep(800)
        IsWindowVisible("MissionReply", "MissionReply_Accept_Clicked()")
        Sleep(800)
      else
        break
      end
    end
    CloseWindow("MissionReply")
    CloseWindow("Quest")
    Sleep(300)
    DebugStr("抓珍兽卖NPC")
  end
  CloseWindow("MissionReply")
  CloseWindow("Quest")
  return bNext
end

local function ZhuaPet_WX_GetUpPet()
  local upPet = {}
  local allPet = Pet:GetAllInfo()
  for i = 1, #allPet do
    local tmp = allPet[i]
    if m_param.wxup_value > 0 and tmp.wuxing < m_param.wxup_value and string.find(m_param.wxup_name, " " .. tmp.name .. " ", nil, true) then
      table.insert(upPet, tmp)
    end
  end
  BubbleSort(upPet, "wuxing", 1)
  return upPet
end

local function ZhuaPet_GG_GetPet(aGengu, aNameMode, aIsFree)
  aNameMode = aNameMode or 1
  local ggPet = {}
  local usePet = {}
  local freeCount = 0
  local allPet = Pet:GetAllInfo()
  for i = 1, #allPet do
    local tmp = allPet[i]
    local cmpName = tmp.name
    if 2 == aNameMode then
      cmpName = tmp.org_name
    end
    if string.find(m_catch.petName, " " .. cmpName .. " ", nil, true) then
      table.insert(ggPet, tmp)
    end
  end
  for i = #ggPet, 1, -1 do
    local tmp = ggPet[i]
    if aGengu > tmp.gengu then
      if aIsFree then
        PushDebugMessage("%s:根骨为%d,根骨不到%d，放生！", tmp.name, tmp.gengu, aGengu)
        Pet:Free(tmp.index)
        Sleep(1000)
        MessageBox_Self_OK_Clicked(1000)
      end
      freeCount = freeCount + 1
    else
      table.insert(usePet, tmp)
    end
  end
  BubbleSort(usePet, "gengu", 1)
  return usePet, freeCount
end

local function PetSavvy_Choose_Clicked(aType)
  GetLuaValue(fmt("setmetatable(_G, {__index = PetSavvy_Env});PetSavvy_Choose_Clicked('%s');", aType))
end

local function ZhuaPet_WXUP()
  local bNext = true
  Pet:Relax(500)
  local upPet = ZhuaPet_WX_GetUpPet()
  for i = 1, #upPet do
    local tmp = upPet[i]
    if tmp.on == "on_possession" then
      Pet:Restore()
      Sleep(1000)
    end
  end
  GoToSceneNPC("云霏霏", 171, 238, 1, nil, nil, nil, nil, true, true)
  while true do
    upPet = ZhuaPet_WX_GetUpPet()
    if 0 == #upPet then
      bNext = false
      break
    end
    local ggPet = ZhuaPet_GG_GetPet(upPet[1].wuxing, nil, false)
    if 0 == #ggPet then
      break
    end
    BubbleSort(upPet, "wuxing", 2)
    local mainIndex = -1
    local assisIndex = -1
    for i = 1, #upPet do
      ggPet = ZhuaPet_GG_GetPet(upPet[i].wuxing, nil, false)
      if #ggPet > 0 then
        mainIndex = upPet[i].index
        assisIndex = ggPet[1].index
      end
    end
    if -1 ~= mainIndex and -1 ~= assisIndex then
      local oldCount = Pet:GetCurrentCount()
      GoToSceneNPC("云霏霏", 171, 238, 1, nil, nil, nil, nil, true, true)
      Sleep(500)
      QuestFrameOptionClicked_Item("用成年珍兽提升悟性", 1, 1200)
      if IsWindowVisible("PetSavvy") then
        PetSavvy_Choose_Clicked("main")
        Sleep(800)
        if IsWindowVisible("PetList") then
          GetLuaValue(fmt("Exchange:AddPet(%d)", mainIndex))
          Sleep(500)
        end
        PetSavvy_Choose_Clicked("assis")
        Sleep(800)
        if IsWindowVisible("PetList") then
          GetLuaValue(fmt("Exchange:AddPet(%d)", assisIndex))
          Sleep(500)
        end
      end
      GetLuaValue("setmetatable(_G, {__index = PetSavvy_Env});PetSavvy_OK_Clicked()")
      Sleep(1000)
      if Pet:GetCurrentCount() == oldCount then
        PushColorMsg("提悟失败")
        CloseWindow("PetSavvy")
        CloseWindow("Quest")
      end
    else
      PushColorMsg("珍兽悟性:获取数据失败")
      Sleep(3000)
      break
    end
    Sleep(500)
    DebugStr("珍兽提悟性")
  end
  CloseWindow("PetSavvy")
  CloseWindow("Quest")
  MainSellBuyItem(nil, "抓珍兽")
  XiaoChangHuiXue(50)
  if bNext and Pet:GetCurrentCount() ~= Pet:GetMaxCount() and 2 == m_param.on_full and 1 == GetSceneID() then
    GoToSceneNPC("云思儿", 175, 238, 1)
    Sleep(500)
    if 112 == m_catch.sceneID then
      QuestFrameOptionClicked_Item("去玄武岛", 1, 1000)
    elseif m_catch.sceneID == 201 then
      QuestFrameOptionClicked_Item("#{QSSS_090302_1}", 1, 1000)
    end
    MoveConfirm()
  end
  return bNext
end

function _SMain(...)
  m_catch.useSkill = true
  m_catch.attackName = ""
  if 0 == #m_catch.pos or -1 == m_catch.sceneID then
    PushColorMsg(m_script_name .. ":地图或坐标错误！")
  end
  if #m_catch.petName < 4 then
    PushColorMsg(m_script_name .. ":珍兽名称有误!")
    return
  end
  if m_catch.sceneName == "燕王古墓五层" or m_catch.sceneName == "燕王古墓八层" or m_catch.sceneName == "银皑雪原" then
    m_param.on_full = 0
  end
  while true do
    if Pet:GetCurrentCount() == Pet:GetMaxCount() then
      PushDebugMessage(m_script_name .. ":珍兽栏已满")
      if 0 == m_param.on_full then
        break
      end
      if 1 == m_param.on_full then
        if ZhuaPet_GetCatchIndex() >= 0 then
          if false == ZhuaPet_SaleNPC() then
            break
          end
        else
          PushColorMsg(m_script_name .. ":珍兽栏无空位,且没有需要出售的珍兽！")
          break
        end
      elseif 2 == m_param.on_full then
        local wxPet = ZhuaPet_WX_GetUpPet()
        if 0 == #wxPet then
          PushColorMsg("珍兽提悟：您已没有需要提悟性的珍兽")
          break
        end
        local _, freeCount = ZhuaPet_GG_GetPet(wxPet[1].wuxing, nil, true)
        if 0 == freeCount and false == ZhuaPet_WXUP() then
          break
        end
        MainSellBuyItem(true, m_script_name)
      elseif 3 == m_param.on_full then
        local _, freeCount = ZhuaPet_GG_GetPet(m_param.shopup_value, 2, true)
        if 0 == freeCount then
          local allFull = LoadScript("商会管理(珍兽)")
          if allFull then
            local str = m_script_name .. ":所有商会已满,结束！"
            Log(str)
            PushColorMsg(str)
            break
          end
          MainSellBuyItem(true, m_script_name)
        else
          Sleep(1000)
        end
      end
    else
      if 2 == m_param.on_full then
        local upPet = ZhuaPet_WX_GetUpPet()
        if 0 == #upPet then
          PushColorMsg("珍兽提悟：您已没有需要提悟性的珍兽")
          break
        end
      end
      
      local function mis_callback()
        HuDaoPet()
        if Pet:GetCurrentCount() == Pet:GetMaxCount() then
          return true
        end
        local bCatch = false
        bCatch, m_param.catchFilter = OnCatch(m_catch, m_param.catchFilter)
        DebugStr("抓珍兽.", 2)
        return false
      end
      
      CatchPet(m_catch, mis_callback)
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  if m_catch.sceneName == "燕王古墓五层" or m_catch.sceneName == "燕王古墓八层" then
    while not IsSafeSceneID() do
      MoveDingWeiFu(LUOYANG_ID)
      Sleep(500)
      DebugStr("抓珍兽:定位回城中")
    end
  elseif not IsSafeSceneID() then
    GoBackCity()
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_catch = nil
m_param = nil
