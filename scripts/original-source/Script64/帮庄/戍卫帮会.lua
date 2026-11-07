-- 反编译自 dfz64.dll 内嵌字节码 0035a761（unluac 2025-12-23；仅供分析）
local m_script_name = "戍卫帮会"
ScriptOnStart(m_script_name, true, false)
local m_npc = {
  [0] = {
    name = "戴三金",
    x = 66,
    y = 135
  }
}
local m_SceneMapBaoZangPosData = {}
m_SceneMapBaoZangPosData[1] = {
  {52, 62},
  {43, 112},
  {35, 181},
  {49, 225},
  {54, 271},
  {118, 58},
  {75, 94},
  {93, 129},
  {76, 175},
  {142, 124},
  {125, 192},
  {107, 242},
  {160, 264},
  {97, 219},
  {245, 116},
  {190, 97},
  {234, 42},
  {269, 50},
  {240, 75},
  {270, 124},
  {274, 168},
  {232, 173},
  {137, 241},
  {227, 264},
  {267, 266}
}
m_SceneMapBaoZangPosData[2] = {
  {52, 62},
  {43, 112},
  {35, 181},
  {49, 225},
  {54, 271},
  {118, 58},
  {75, 94},
  {93, 129},
  {76, 175},
  {142, 124},
  {125, 192},
  {107, 242},
  {160, 264},
  {97, 219},
  {245, 116},
  {190, 97},
  {234, 42},
  {269, 50},
  {240, 75},
  {270, 124},
  {274, 168},
  {232, 173},
  {137, 241},
  {227, 264},
  {267, 266}
}
m_SceneMapBaoZangPosData[3] = {
  {52, 62},
  {43, 112},
  {35, 181},
  {49, 225},
  {54, 271},
  {118, 58},
  {75, 94},
  {93, 129},
  {76, 175},
  {142, 124},
  {125, 192},
  {107, 242},
  {160, 264},
  {97, 219},
  {245, 116},
  {190, 97},
  {234, 42},
  {269, 50},
  {240, 75},
  {270, 124},
  {274, 168},
  {232, 173},
  {137, 241},
  {227, 264},
  {267, 266}
}
m_SceneMapBaoZangPosData[4] = {
  {52, 62},
  {43, 112},
  {35, 181},
  {49, 225},
  {54, 271},
  {118, 58},
  {75, 94},
  {93, 129},
  {76, 175},
  {142, 124},
  {125, 192},
  {107, 242},
  {160, 264},
  {97, 219},
  {245, 116},
  {190, 97},
  {234, 42},
  {269, 50},
  {240, 75},
  {270, 124},
  {274, 168},
  {232, 173},
  {137, 241},
  {227, 264},
  {267, 266}
}
m_SceneMapBaoZangPosData[5] = {
  {52, 62},
  {43, 112},
  {35, 181},
  {49, 225},
  {54, 271},
  {118, 58},
  {75, 94},
  {93, 129},
  {76, 175},
  {142, 124},
  {125, 192},
  {107, 242},
  {160, 264},
  {97, 219},
  {245, 116},
  {190, 97},
  {234, 42},
  {269, 50},
  {240, 75},
  {270, 124},
  {274, 168},
  {232, 173},
  {137, 241},
  {227, 264},
  {267, 266}
}
local m_pos_all = m_SceneMapBaoZangPosData[1]
local m_banghui_name = ""
local m_record_time = ""
local m_record_posfilter = ""

local function swbh_move_cb()
  if GetSceneID() == 839 then
    return false
  end
  return true
end

local function SWBH_record_get()
  local strTime = GC_Get(m_record_time, "戍卫帮会")
  local strPosF = GC_Get(m_record_posfilter, "戍卫帮会")
  local nTime = GetTimeStampFromStr(strTime)
  if nTime then
    local recordT = os.date("*t", nTime)
    local nowT = os.date("*t")
    if recordT.day == nowT.day and #strPosF > 1 then
      local posF = g_json.decode(strPosF)
      return posF
    end
  end
  return {}
end

local function SWBH_record_query(aPos)
  local pos = {
    x = aPos[1],
    y = aPos[2]
  }
  local trec = SWBH_record_get()
  local bHave = false
  for i = 1, #trec do
    local tmp = trec[i]
    if GetDist(tmp.x, tmp.y, pos.x, pos.y) < 5 then
      bHave = true
      break
    end
  end
  return bHave
end

local function SWBH_record_set(aPos)
  local pos = {
    x = aPos[1],
    y = aPos[2]
  }
  local trec = SWBH_record_get()
  local bRecord = true
  for i = 1, #trec do
    local tmp = trec[i]
    if GetDist(tmp.x, tmp.y, pos.x, pos.y) < 5 then
      bRecord = false
      break
    end
  end
  if bRecord then
    local strTime = GetTimeStr(os.time())
    table.insert(trec, pos)
    local strPos = g_json.encode(trec)
    GC_Set(m_record_posfilter, strPos, "戍卫帮会")
    GC_Set(m_record_time, strTime, "戍卫帮会")
  end
end

local function SWBH_leave()
  while GetSceneID() == 839 do
    DebugStr("离开帮会后山")
    MoveTo(271, 236, 839, nil, nil, nil, MoveCallback_InScene)
    Sleep(600)
    TalkNpc("任颂传", 800)
    QuestFrameOptionClicked_Item("#{BHSL_210715_21}", 1, 1000)
  end
end

local function SWBH_GetFujinPos(aIndex)
  local posA = {}
  local cmpDist = 70
  if aIndex >= 1 and aIndex <= #m_pos_all then
    local pos = m_pos_all[aIndex]
    for i = 1, #m_pos_all do
      local tmp = m_pos_all[i]
      if cmpDist >= GetDist(tmp[1], tmp[2], pos[1], pos[2]) and i ~= aIndex then
        table.insert(posA, i)
      end
    end
  end
  return posA
end

local function SWBH_XianSuo()
  local tHave1 = {}
  local tHave2 = {}
  local tUnHave2 = {}
  local openCount = 0
  for posIdx = 1, #m_pos_all do
    local xianSuo1, xianSuo2, bxCount = GetLuaValue(fmt([[
                    local posIdx = %d
                    local xianSuo1 = 0
                    local xianSuo2 = 0
                    local bxCount = 0
                    local xianSuoUIIndex = 0
                    local xianSuoMaxNum = GuildActValueUI:LuaFnGetBaoZangPosXianSuoMaxNum()
                    for xianSuoIndex = 1, xianSuoMaxNum do
                        local xianSuoType, xianSuoParam, waJueNum, isWaJueBaoZang = GuildActValueUI:LuaFnGetGuildSaoLeiXianSuoData(posIdx, xianSuoIndex - 1)
                        if nil ~= xianSuoType and xianSuoType > 0 and xianSuoType <= 2 then -- and nil ~= m_XianSuoDataWuBaoZang[xianSuoType]
                            if xianSuoType == 1 then
                                if nil ~= waJueNum then
                                    xianSuo1 = 1
                                    if isWaJueBaoZang ~= nil then 
                                        if isWaJueBaoZang == 1 then 
                                            bxCount = 1
                                            xianSuo1 = 2
                                        end       
                                    end
                                else
                                    xianSuo1 = 2
                                end
                            elseif xianSuoType == 2 then
                                if xianSuoParam > 0 then
                                    xianSuo2 = 1
                                else
                                    xianSuo2 = 2
                                end
                            end
                        end
                    end
                    return xianSuo1, xianSuo2, bxCount       
                ]], posIdx), "nnn")
    openCount = openCount + bxCount
    if 0 ~= xianSuo1 then
      if 1 == xianSuo1 then
        table.insert(tHave1, m_pos_all[posIdx])
      elseif 2 == xianSuo1 then
        table.insert(tUnHave2, m_pos_all[posIdx])
      end
    end
    if 0 ~= xianSuo2 then
      local posA = SWBH_GetFujinPos(posIdx)
      if 1 == xianSuo2 then
        for i = 1, #posA do
          table.insert(tHave2, m_pos_all[posA[i]])
        end
      elseif 2 == xianSuo2 then
        for i = 1, #posA do
          table.insert(tUnHave2, m_pos_all[posA[i]])
        end
      end
    end
  end
  return tHave1, tHave2, tUnHave2, openCount
end

local function SWBH_calc_pos()
  local unrecord_pos = {}
  for idx = 1, #m_pos_all do
    local pos = m_pos_all[idx]
    local bHave = SWBH_record_query(pos)
    if false == bHave then
      table.insert(unrecord_pos, pos)
    end
  end
  local unfil_pos = {}
  local tHave1, tHave2, tUnHave2, openCount = SWBH_XianSuo()
  if 5 == openCount then
    PushColorMsg("宝箱已经全部挖掘")
    return m_pos_all[#m_pos_all]
  end
  for i = 1, #unrecord_pos do
    local tmp = unrecord_pos[i]
    local bInsert = true
    for j = 1, #tUnHave2 do
      local pos = tUnHave2[j]
      if GetDist(tmp[1], tmp[2], pos[1], pos[2]) < 5 then
        bInsert = false
        break
      end
    end
    if bInsert then
      table.insert(unfil_pos, unrecord_pos[i])
    end
  end
  local tHave1_pos = {}
  for j = 1, #tHave1 do
    local bInsert = false
    local pos = tHave1[j]
    for i = 1, #unfil_pos do
      local tmp = unfil_pos[i]
      if GetDist(tmp[1], tmp[2], pos[1], pos[2]) < 5 then
        bInsert = true
        break
      end
    end
    if bInsert then
      table.insert(tHave1_pos, tHave1[j])
    end
  end
  if #tHave1_pos > 0 then
    PushDebugMessage(m_script_name .. "：宝箱坐标%d个", #tHave1_pos)
    return tHave1_pos[1]
  end
  local tHave2_pos = {}
  for j = 1, #tHave2 do
    local bInsert = false
    local pos = tHave2[j]
    for i = 1, #unfil_pos do
      local tmp = unfil_pos[i]
      if GetDist(tmp[1], tmp[2], pos[1], pos[2]) < 5 then
        bInsert = true
        break
      end
    end
    if bInsert then
      table.insert(tHave2_pos, tHave2[j])
    end
  end
  if #tHave2_pos > 0 then
    local tArr = {}
    for i = 1, #tHave2_pos do
      local tmp = tHave2_pos[i]
      local filed = tmp[1] .. "-" .. tmp[2]
      local bHave = false
      for k = 1, #tArr do
        local tk = tArr[k]
        if tk.name == filed then
          bHave = true
          tk.count = tk.count + 1
          break
        end
      end
      if not bHave then
        table.insert(tArr, {
          name = filed,
          x = tmp[1],
          y = tmp[2],
          count = 1
        })
      end
    end
    BubbleSort(tArr, "count", 2)
    PushDebugMessage(m_script_name .. "：寻找坐标%d个", #tArr)
    local tmp = {
      tArr[1].x,
      tArr[1].y
    }
    return tmp
  end
  if #unfil_pos > 0 then
    PushDebugMessage(m_script_name .. "：过滤掉线索和记录坐标%d个", #m_pos_all - #unfil_pos)
    math.randomseed(GetTickCount() + g_self.guid)
    local idx = math.random(1, #unfil_pos)
    return unfil_pos[idx]
  end
  if #unrecord_pos > 0 then
    PushDebugMessage(m_script_name .. "：过滤掉记录坐标%d个", #m_pos_all - #unrecord_pos)
    math.randomseed(GetTickCount() + g_self.guid)
    local idx = math.random(1, #unrecord_pos)
    return unrecord_pos[idx]
  end
  math.randomseed(GetTickCount() + g_self.guid)
  local idx = math.random(1, #m_pos_all)
  return m_pos_all[idx]
end

local function SWBH_Action()
  DeleteDebugMsg("#{BHSL_210715_34}")
  DeleteDebugMsg("#{BHSL_210715_35}")
  local nTickOut = -1
  while true do
    local pos = SWBH_calc_pos()
    PushDebugMessage(pos[1] .. " " .. pos[2])
    DeleteDebugMsg("#{BHSL_210715_73}")
    MoveTo(pos[1], pos[2], 839, nil, nil, nil, MoveCallback_InScene)
    PlayerStateTimeOut(2, 2)
    local tObj = Enum2XByName("已寻得的福源宝箱", {
      1,
      0,
      0,
      0
    }, nil, nil, 0)
    if 0 == #tObj then
    else
      SWBH_record_set(pos)
    end
    Dismount(500)
    GetLuaValue([[
                Clear_XSCRIPT()
                    Set_XSCRIPT_Function_Name("StartWaJueBaoZaong")
                    Set_XSCRIPT_ScriptID( 888478 )
                    Set_XSCRIPT_ParamCount(0)
                Send_XSCRIPT()
            ]])
    Sleep(1000)
    WuhunQuest_Text_Clicked("", 600)
    PlayerStateTimeOut(5, 5)
    if IsInDebugMsg("#{BHSL_210715_34}") or IsInDebugMsg("#{BHSL_210715_35}") then
      break
    end
    if Bag:GetSpaceNum(0) < 2 then
      if -1 == nTickOut then
        nTickOut = GetTickCount()
      end
      if GetTickCount() - nTickOut > 480000 then
        LogMsg(m_script_name .. ":道具包已满,结束!")
        break
      end
    end
    if IsInDebugMsgTime("#{BHSL_210715_73}", nil, 10) then
      SWBH_record_set(pos)
    end
    Sleep(1500)
    DebugStr(m_script_name)
  end
end

function _SMain(...)
  while true do
    if GetSceneID() == 839 then
      if "" == m_banghui_name then
        m_banghui_name = GetMyGuildCityName()
        m_record_time = m_banghui_name .. "记录时间"
        m_record_posfilter = m_banghui_name .. "排除坐标"
      end
      local mapIndex = GetLuaValue("return GuildActValueUI:LuaFnGetGuildSaoLeiMapIndex()", "n")
      if mapIndex and m_SceneMapBaoZangPosData[mapIndex] then
        m_pos_all = m_SceneMapBaoZangPosData[mapIndex]
      end
      SWBH_Action()
      SWBH_leave()
      DeleteDebugMsg("#{BHSL_210715_15}")
      for i = 1, 10 do
        GoToGuild()
        MoveToNPC(m_npc[0].name, m_npc[0].x, m_npc[0].y, -1, nil, nil, nil, MoveCallback_InMyGuild)
        QuestFrameOptionClicked_Item("#{BHSL_210715_03}", 1, 1000)
        QuestFrameOptionClicked_Item("#{BHSL_210715_74}", 1, 1000)
        if IsInDebugMsg("#{BHSL_210715_15}") then
          goto lbl_118
        end
      end
      break
    else
      local ACTIVEPOINT = Player:GetDataInt("ACTIVEPOINT")
      if ACTIVEPOINT < 250 then
      end
      if GoToGuild(swbh_move_cb) == false then
        break
      end
      MoveToNPC(m_npc[0].name, m_npc[0].x, m_npc[0].y, -1, nil, nil, nil, MoveCallback_InMyGuild)
      QuestFrameOptionClicked_Item("#{BHSL_210715_02}", 1, 1000)
      QuestFrameOptionClicked_Item("#{BHSL_210715_82}", 1, 1000)
    end
    Sleep(500)
  end
  ::lbl_118::
end

_SMain()
ScriptOnStop(m_script_name, false)
