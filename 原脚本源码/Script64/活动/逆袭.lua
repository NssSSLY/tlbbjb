-- 反编译自 dfz64.dll 内嵌字节码 0042de32（unluac 2025-12-23；仅供分析）
local m_script_name = "逆袭"
ScriptOnStart(m_script_name, true, false)
local m_actionScene = GetConfigCommbox("设置", "逆袭地图")
m_actionScene = m_actionScene.text
g_config.nixi = {}
g_config.nixi.mode_cur = false
g_config.nixi.ignore_minute = 10
g_config.nixi.waitbag_timeout = ReadConfigInt("ZH", "bjk91")
g_config.nixi.unfind_timeout = 180
if "当前地图" == m_actionScene then
  g_config.nixi.mode_cur = true
elseif "太湖" == m_actionScene then
  g_config.nixi.scene_taihu = true
elseif "西湖" == m_actionScene then
  g_config.nixi.scene_xihu = true
elseif "武夷" == m_actionScene then
  g_config.nixi.scene_wuyi = true
elseif "苍山" == m_actionScene then
  g_config.nixi.scene_cangshan = true
elseif "敦煌" == m_actionScene then
  g_config.nixi.scene_dunhuang = true
elseif "嵩山" == m_actionScene then
  g_config.nixi.scene_songshan = true
elseif "雁南" == m_actionScene then
  g_config.nixi.scene_yannan = true
elseif "雁北" == m_actionScene then
  g_config.nixi.scene_yanbei = true
elseif "草原" == m_actionScene then
  g_config.nixi.scene_caoyuan = true
elseif "洱海" == m_actionScene then
  g_config.nixi.scene_erhai = true
elseif "无量山" == m_actionScene then
  g_config.nixi.scene_wuliangshan = true
elseif "剑阁" == m_actionScene then
  g_config.nixi.scene_jiange = true
end
CDG:InitFubenParam()
CDG.attack = true
if g_data_nixi == nil then
  g_data_nixi = {}
  g_data_nixi.scene_record = {}
  g_data_nixi.all_kill = 0
end
g_MaZeiPos = {}
g_MaZeiPos[3] = {
  {x = 56, y = 57},
  {x = 84, y = 140},
  {x = 119, y = 138},
  {x = 46, y = 171},
  {x = 52, y = 223},
  {x = 94, y = 268},
  {x = 175, y = 248},
  {x = 187, y = 170},
  {x = 215, y = 271},
  {x = 251, y = 269},
  {x = 278, y = 270},
  {x = 251, y = 204},
  {x = 250, y = 91}
}
g_MaZeiPos[4] = {
  {x = 165, y = 254},
  {x = 89, y = 253},
  {x = 53, y = 220},
  {x = 124, y = 147},
  {x = 127, y = 64},
  {x = 158, y = 44},
  {x = 234, y = 61},
  {x = 241, y = 145},
  {x = 179, y = 170},
  {x = 180, y = 200},
  {x = 218, y = 218},
  {x = 269, y = 196},
  {x = 261, y = 246}
}
g_MaZeiPos[5] = {
  {x = 191, y = 46},
  {x = 70, y = 44},
  {x = 119, y = 83},
  {x = 125, y = 88},
  {x = 128, y = 143},
  {x = 119, y = 169},
  {x = 108, y = 146},
  {x = 45, y = 204},
  {x = 69, y = 263},
  {x = 48, y = 256},
  {x = 38, y = 276},
  {x = 108, y = 272},
  {x = 169, y = 224},
  {x = 225, y = 257},
  {x = 238, y = 252}
}
g_MaZeiPos[8] = {
  {x = 239, y = 164},
  {x = 178, y = 154},
  {x = 164, y = 118},
  {x = 246, y = 71},
  {x = 261, y = 52},
  {x = 124, y = 108},
  {x = 66, y = 78},
  {x = 97, y = 128},
  {x = 77, y = 152},
  {x = 116, y = 183},
  {x = 51, y = 213},
  {x = 112, y = 217},
  {x = 203, y = 234}
}
g_MaZeiPos[18] = {
  {x = 54, y = 50},
  {x = 56, y = 103},
  {x = 56, y = 143},
  {x = 137, y = 116},
  {x = 119, y = 165},
  {x = 83, y = 180},
  {x = 97, y = 206},
  {x = 81, y = 245},
  {x = 51, y = 261},
  {x = 192, y = 270},
  {x = 228, y = 271},
  {x = 238, y = 233},
  {x = 194, y = 216},
  {x = 266, y = 179},
  {x = 218, y = 115},
  {x = 249, y = 47},
  {x = 163, y = 73},
  {x = 102, y = 44}
}
g_MaZeiPos[19] = {
  {x = 254, y = 175},
  {x = 251, y = 165},
  {x = 266, y = 51},
  {x = 192, y = 48},
  {x = 113, y = 39},
  {x = 50, y = 36},
  {x = 47, y = 87},
  {x = 40, y = 130},
  {x = 105, y = 101},
  {x = 151, y = 119},
  {x = 74, y = 190},
  {x = 114, y = 261}
}
g_MaZeiPos[20] = {
  {x = 254, y = 222},
  {x = 258, y = 285},
  {x = 177, y = 244},
  {x = 106, y = 252},
  {x = 50, y = 265},
  {x = 82, y = 230},
  {x = 109, y = 181},
  {x = 49, y = 163},
  {x = 49, y = 52},
  {x = 109, y = 40},
  {x = 129, y = 118},
  {x = 191, y = 128},
  {x = 186, y = 84},
  {x = 270, y = 89}
}
g_MaZeiPos[21] = {
  {x = 101, y = 262},
  {x = 170, y = 270},
  {x = 84, y = 225},
  {x = 93, y = 201},
  {x = 55, y = 189},
  {x = 55, y = 156},
  {x = 61, y = 91},
  {x = 103, y = 58},
  {x = 113, y = 92},
  {x = 233, y = 50},
  {x = 275, y = 86},
  {x = 248, y = 125},
  {x = 224, y = 143},
  {x = 151, y = 137},
  {x = 155, y = 170},
  {x = 225, y = 201},
  {x = 268, y = 223},
  {x = 219, y = 259},
  {x = 271, y = 252}
}
g_MaZeiPos[22] = {
  {x = 117, y = 156},
  {x = 55, y = 165},
  {x = 52, y = 216},
  {x = 123, y = 192},
  {x = 47, y = 119},
  {x = 93, y = 180},
  {x = 142, y = 52},
  {x = 99, y = 118},
  {x = 85, y = 81},
  {x = 107, y = 47},
  {x = 47, y = 53},
  {x = 45, y = 91},
  {x = 198, y = 139},
  {x = 213, y = 271},
  {x = 201, y = 135},
  {x = 234, y = 163},
  {x = 267, y = 150},
  {x = 169, y = 64},
  {x = 262, y = 104},
  {x = 249, y = 53}
}
g_MaZeiPos[23] = {
  {x = 64, y = 194},
  {x = 54, y = 117},
  {x = 119, y = 82},
  {x = 252, y = 53},
  {x = 252, y = 108},
  {x = 263, y = 270},
  {x = 218, y = 254},
  {x = 196, y = 177},
  {x = 171, y = 278},
  {x = 119, y = 275},
  {x = 108, y = 216}
}
g_MaZeiPos[24] = {
  {x = 206, y = 130},
  {x = 187, y = 139},
  {x = 149, y = 99},
  {x = 135, y = 143},
  {x = 77, y = 100},
  {x = 62, y = 148},
  {x = 44, y = 185},
  {x = 96, y = 196},
  {x = 81, y = 236},
  {x = 87, y = 266},
  {x = 155, y = 234},
  {x = 170, y = 266},
  {x = 181, y = 232},
  {x = 230, y = 269},
  {x = 240, y = 215},
  {x = 252, y = 167}
}
g_MaZeiPos[25] = {
  {x = 162, y = 54},
  {x = 153, y = 100},
  {x = 139, y = 107},
  {x = 95, y = 130},
  {x = 105, y = 123},
  {x = 62, y = 72},
  {x = 95, y = 130},
  {x = 71, y = 187},
  {x = 63, y = 214},
  {x = 49, y = 257},
  {x = 87, y = 136},
  {x = 112, y = 222},
  {x = 157, y = 143},
  {x = 195, y = 157},
  {x = 156, y = 195},
  {x = 169, y = 261},
  {x = 227, y = 263},
  {x = 264, y = 267},
  {x = 214, y = 225},
  {x = 265, y = 136}
}
g_MaZeiPos[26] = {
  {x = 174, y = 108},
  {x = 206, y = 66},
  {x = 98, y = 56},
  {x = 48, y = 100},
  {x = 87, y = 77},
  {x = 118, y = 111},
  {x = 105, y = 132},
  {x = 85, y = 155},
  {x = 112, y = 188},
  {x = 139, y = 217},
  {x = 44, y = 241},
  {x = 105, y = 245},
  {x = 231, y = 232},
  {x = 256, y = 275},
  {x = 242, y = 198},
  {x = 258, y = 175},
  {x = 235, y = 159}
}
g_MaZeiPos[27] = {
  {x = 124, y = 61},
  {x = 48, y = 97},
  {x = 51, y = 119},
  {x = 103, y = 155},
  {x = 44, y = 243},
  {x = 86, y = 273},
  {x = 172, y = 251},
  {x = 183, y = 216},
  {x = 210, y = 257},
  {x = 270, y = 251},
  {x = 240, y = 190},
  {x = 219, y = 119},
  {x = 270, y = 149},
  {x = 264, y = 66},
  {x = 150, y = 101}
}
g_MaZeiPos[28] = {
  {x = 192, y = 144},
  {x = 276, y = 192},
  {x = 221, y = 163},
  {x = 240, y = 224},
  {x = 203, y = 213},
  {x = 201, y = 257},
  {x = 47, y = 256},
  {x = 59, y = 160},
  {x = 106, y = 158},
  {x = 106, y = 216},
  {x = 182, y = 198},
  {x = 159, y = 172},
  {x = 94, y = 106},
  {x = 64, y = 75},
  {x = 83, y = 46}
}
g_MaZeiPos[29] = {
  {x = 34, y = 35},
  {x = 98, y = 53},
  {x = 155, y = 122},
  {x = 151, y = 65},
  {x = 191, y = 53},
  {x = 170, y = 122},
  {x = 274, y = 132},
  {x = 139, y = 150},
  {x = 227, y = 154},
  {x = 222, y = 227},
  {x = 279, y = 243},
  {x = 270, y = 276},
  {x = 205, y = 200},
  {x = 153, y = 190},
  {x = 115, y = 216},
  {x = 42, y = 210},
  {x = 57, y = 188},
  {x = 64, y = 47}
}
g_MaZeiPos[30] = {
  {x = 83, y = 77},
  {x = 112, y = 95},
  {x = 105, y = 175},
  {x = 62, y = 187},
  {x = 112, y = 229},
  {x = 76, y = 245},
  {x = 101, y = 257},
  {x = 183, y = 195},
  {x = 210, y = 210},
  {x = 235, y = 201},
  {x = 231, y = 253},
  {x = 262, y = 268},
  {x = 232, y = 122}
}
g_MaZeiPos[31] = {
  {x = 64, y = 245},
  {x = 106, y = 240},
  {x = 69, y = 183},
  {x = 50, y = 123},
  {x = 105, y = 136},
  {x = 108, y = 126},
  {x = 93, y = 75},
  {x = 193, y = 89},
  {x = 266, y = 85},
  {x = 222, y = 119},
  {x = 172, y = 162},
  {x = 250, y = 148},
  {x = 241, y = 169},
  {x = 40, y = 142},
  {x = 244, y = 209},
  {x = 181, y = 224},
  {x = 158, y = 270},
  {x = 265, y = 270},
  {x = 280, y = 248}
}
g_MaZeiPos[32] = {
  {x = 69, y = 97},
  {x = 52, y = 215},
  {x = 86, y = 257},
  {x = 150, y = 262},
  {x = 188, y = 277},
  {x = 199, y = 243},
  {x = 129, y = 175},
  {x = 211, y = 184},
  {x = 239, y = 167},
  {x = 267, y = 100},
  {x = 274, y = 58},
  {x = 199, y = 124},
  {x = 195, y = 90},
  {x = 216, y = 80},
  {x = 227, y = 66},
  {x = 145, y = 45}
}
g_MaZeiPos[33] = {
  {x = 68, y = 254},
  {x = 64, y = 225},
  {x = 49, y = 100},
  {x = 101, y = 54},
  {x = 137, y = 71},
  {x = 113, y = 125},
  {x = 142, y = 135},
  {x = 126, y = 189},
  {x = 150, y = 218},
  {x = 132, y = 261},
  {x = 197, y = 262},
  {x = 250, y = 269},
  {x = 226, y = 165},
  {x = 268, y = 191},
  {x = 269, y = 112},
  {x = 238, y = 75},
  {x = 246, y = 41}
}
g_MaZeiPos[34] = {
  {x = 277, y = 261},
  {x = 244, y = 103},
  {x = 173, y = 129},
  {x = 222, y = 219},
  {x = 176, y = 272},
  {x = 124, y = 257},
  {x = 154, y = 210},
  {x = 127, y = 133},
  {x = 63, y = 178},
  {x = 51, y = 121},
  {x = 93, y = 91},
  {x = 39, y = 70},
  {x = 57, y = 39},
  {x = 156, y = 44},
  {x = 155, y = 83},
  {x = 190, y = 115},
  {x = 245, y = 42},
  {x = 284, y = 66},
  {x = 249, y = 177}
}
g_MaZeiPos[35] = {
  {x = 188, y = 218},
  {x = 210, y = 192},
  {x = 118, y = 160},
  {x = 196, y = 253},
  {x = 186, y = 250},
  {x = 142, y = 260},
  {x = 114, y = 226},
  {x = 77, y = 255},
  {x = 72, y = 235},
  {x = 137, y = 129},
  {x = 112, y = 111},
  {x = 170, y = 84},
  {x = 110, y = 76},
  {x = 140, y = 70},
  {x = 50, y = 49},
  {x = 265, y = 57},
  {x = 241, y = 84},
  {x = 258, y = 178},
  {x = 210, y = 158},
  {x = 224, y = 116},
  {x = 262, y = 221}
}
local m_param = {}
local m_data = {}
m_data.over_mark = 0
m_data.lasttick_buji = -1
m_data.lasttick_cuncang = -1
m_data.lasttick_buydwf = -1
m_data.lasttick_findMazei = -1
m_data.mazei_filter = {}
m_data.mazei_kill = {}
m_data.kill_num = 0
m_data.npc_name = " 黄金契丹刺客 契丹刺客 "

local function MZ_Init()
  local posFile = GetUserScriptPath("坐标刷马.lua")
  if "" ~= posFile and LoadUserPathScript(posFile) == false then
    PushColorMsg("逆袭:加载自定义坐标失败,请检查语法或者删除自定义坐标")
    return false
  end
  m_param.zhongtu_kill = true
  m_param.mode_cur = g_config.nixi.mode_cur
  m_param.ignore_minute = HandleTextToNumber(g_config.nixi.ignore_minute, 0)
  if m_param.ignore_minute <= 0 then
    m_param.ignore_minute = 10
  end
  m_param.waitbag_timeout = HandleTextToNumber(g_config.nixi.waitbag_timeout, 1)
  m_param.unfind_timeout = HandleTextToNumber(g_config.nixi.unfind_timeout, 0)
  m_param.use_shoufei_npc = true
  m_param.use_dingweifu = true
  m_param.member_katu = true
  m_param.scene = {}
  if g_config.nixi.scene_wuliangshan then
    table.insert(m_param.scene, {sceneName = "无量山", sceneID = 6})
  end
  if g_config.nixi.scene_jiange then
    table.insert(m_param.scene, {sceneName = "剑阁", sceneID = 7})
  end
  if g_config.nixi.scene_songshan then
    table.insert(m_param.scene, {sceneName = "嵩山", sceneID = 3})
  end
  if g_config.nixi.scene_taihu then
    table.insert(m_param.scene, {sceneName = "太湖", sceneID = 4})
  end
  if g_config.nixi.scene_xihu then
    table.insert(m_param.scene, {sceneName = "西湖", sceneID = 30})
  end
  if g_config.nixi.scene_longquan then
    table.insert(m_param.scene, {sceneName = "龙泉", sceneID = 31})
  end
  if g_config.nixi.scene_wuyi then
    table.insert(m_param.scene, {sceneName = "武夷", sceneID = 32})
  end
  if g_config.nixi.scene_dunhuang then
    table.insert(m_param.scene, {sceneName = "敦煌", sceneID = 8})
  end
  if g_config.nixi.scene_yannan then
    table.insert(m_param.scene, {sceneName = "雁南", sceneID = 18})
  end
  if g_config.nixi.scene_yanbei then
    table.insert(m_param.scene, {sceneName = "雁北", sceneID = 19})
  end
  if g_config.nixi.scene_caoyuan then
    table.insert(m_param.scene, {sceneName = "草原", sceneID = 20})
  end
  if g_config.nixi.scene_erhai then
    table.insert(m_param.scene, {sceneName = "洱海", sceneID = 24})
  end
  if g_config.nixi.scene_cangshan then
    table.insert(m_param.scene, {sceneName = "苍山", sceneID = 25})
  end
  m_param.sceneText = Array2Text(m_param.scene, " ", "sceneName")
  m_param.sceneText = HandleText_AddFuHao(m_param.sceneText, " ")
  return true
end

local function MZ_FindRecord(aRefreshTick, aRefreshSceneName)
  local nTick = GetTickCount()
  for i = #g_data_nixi.scene_record, 1, -1 do
    local tmp = g_data_nixi.scene_record[i]
    if nTick - tmp.tick > m_param.ignore_minute * 60000 then
      local bFind = false
      if tmp.tick == aRefreshTick and tmp.sceneName == aRefreshSceneName then
        bFind = true
      end
      table.remove(g_data_nixi.scene_record, i)
      if bFind then
        return true
      end
    elseif tmp.tick == aRefreshTick and tmp.sceneName == aRefreshSceneName then
      return true
    end
  end
  return false
end

local function MZ_PushRecord(aRefreshTick, aRefreshSceneName)
  if false == MZ_FindRecord(aRefreshTick, aRefreshSceneName) then
    local tmp = {tick = aRefreshTick, sceneName = aRefreshSceneName}
    table.insert(g_data_nixi.scene_record, tmp)
  end
end

local function MZ_PushFilterMazei(aTarget)
  if #m_data.mazei_filter > 5 then
    table.remove(m_data.mazei_filter, 1)
  end
  table.insert(m_data.mazei_filter, aTarget)
end

local function MZ_FilterMazei(aObj)
  local tTmp = {}
  for i = 1, #aObj do
    local bOk = true
    for j = 1, #m_data.mazei_filter do
      if m_data.mazei_filter[j].id == aObj[i].id then
        PushColorMsg("逆袭:马贼ID %d 等级 %d, 在过滤列表,可能因为其等级高", m_data.mazei_filter[j].id, m_data.mazei_filter[j].level)
        bOk = false
        break
      end
    end
    if bOk then
      table.insert(tTmp, aObj[i])
    end
  end
  return tTmp
end

local function MZ_TongJiNumAndFilterHP(aObj)
  local tTmp = {}
  local bWaitBag = false
  for i = 1, #aObj do
    if aObj[i].hp > 0 then
      table.insert(tTmp, aObj[i])
    else
      local bJoin = true
      for j = 1, #m_data.mazei_kill do
        if m_data.mazei_kill[j].id == aObj[i].id then
          bJoin = false
          break
        end
      end
      if bJoin then
        bWaitBag = true
        if #m_data.mazei_kill > 15 then
          table.remove(m_data.mazei_kill, 1)
        end
        table.insert(m_data.mazei_kill, aObj[i])
        m_data.kill_num = m_data.kill_num + 1
        g_data_nixi.all_kill = g_data_nixi.all_kill + 1
        PushColorMsg(fmt("逆袭:本次已杀%d个,历史已杀%d个刺客", m_data.kill_num, g_data_nixi.all_kill))
      end
    end
  end
  return tTmp, bWaitBag
end

local function MZ_GetTargetScene()
  local tAllInfo = {}
  local strText = GetLuaValue("return dmGetMazeiInfo()", "s")
  local strArr = SplitString(strText, " ", true)
  for i = 1, #strArr do
    local strArr2 = SplitString(strArr[i], "&", true)
    if #strArr2 >= 2 and "" ~= strArr2[1] and "" ~= strArr2[2] then
      local tmp = {
        sceneName = strArr2[1],
        tick = tonumber(strArr2[2])
      }
      tmp.tick = tmp.tick or -1
      tmp.sceneID = GetSceneIDByName(tmp.sceneName)
      table.insert(tAllInfo, tmp)
    end
  end
  local strMsgText = ""
  local tMazeiInfo = {}
  local nNowTick = GetTickCount()
  for i = #tAllInfo, 1, -1 do
    local tmp = tAllInfo[i]
    if nNowTick - tmp.tick <= m_param.ignore_minute * 60000 then
      local strScene = HandleText_AddFuHao(tmp.sceneName, " ")
      if string.find(m_param.sceneText, strScene, nil, true) then
        table.insert(tMazeiInfo, tmp)
      else
        strMsgText = strMsgText .. tmp.sceneName .. "[不刷] "
      end
    else
      strMsgText = strMsgText .. tmp.sceneName .. "[超时] "
    end
  end
  local tCanAction = {}
  for i = 1, #tMazeiInfo do
    if not MZ_FindRecord(tMazeiInfo[i].tick, tMazeiInfo[i].sceneName) then
      table.insert(tCanAction, tMazeiInfo[i])
    end
  end
  local szSceneName = GetCurrentSceneName()
  szSceneName = string.gsub(szSceneName, "1线", "")
  szSceneName = string.gsub(szSceneName, "2线", "")
  local tMazei
  if m_param.use_shoufei_npc or m_param.use_dingweifu then
    for i = 1, #tCanAction do
      if nNowTick - tCanAction[i].tick < 60000 and tCanAction[i].sceneName == szSceneName then
        PushColorMsg("逆袭:当前地图60秒内又刷新,继续当前地图")
        tMazei = tCanAction[i]
        break
      end
    end
    if not tMazei then
      for i = 1, #tCanAction do
        if nNowTick - tCanAction[i].tick < 30000 and CMGraph:GetDist(tCanAction[i].sceneName, szSceneName) <= 100 then
          PushColorMsg("逆袭:隔壁地图30秒内有刷新,前往隔壁地图")
          tMazei = tCanAction[i]
          break
        end
      end
    end
    if not tMazei and #tCanAction > 0 then
      BubbleSort(tCanAction, "tick", 2)
      tMazei = tCanAction[1]
    end
  else
    local dist_min = 999999
    for i = 1, #tCanAction do
      local inte = (nNowTick - tCanAction[i].tick) / 1000
      local dist = CMGraph:GetDist(szSceneName, tCanAction[i].sceneName)
      if dist_min > dist + inte then
        tMazei = tCanAction[i]
        dist_min = dist + inte
      end
    end
  end
  return tMazei
end

local function mzmv_ShoufeiNPC(fX, fY, nScene)
  if m_param.use_shoufei_npc and MoveMoneyRoad(nScene) then
    Sleep(200)
    while MoveMoneyRoad(nScene) do
      Sleep(500)
      DebugStr("逆袭:使用收费传送")
      if not Player:IsFollow() then
        UseMount()
      end
      MoveCheckOtherGuildCity()
      MoveKaTu(fX, fY, nScene)
    end
    return true
  end
  return false
end

local function mzmv_Dingweifu(fX, fY, nScene)
  if m_param.use_dingweifu then
    local nSceneID = GetSceneID()
    if MoveDingWeiFu(nScene) then
      Sleep(200)
      while MoveDingWeiFu(nScene) do
        Sleep(500)
        DebugStr("逆袭:使用定位符")
        AutoRunToTarget(fX, fY, nScene, false)
        Sleep(500)
      end
      return true
    end
  end
  return false
end

local function mz_handleMazei(aObj)
  local tTmp = ObjFilterByClass(aObj, {
    0,
    1,
    0,
    0
  })
  local tTmp2 = ObjFilterByColor(tTmp, "绿")
  if #tTmp2 > 0 then
    BubbleByHP(tTmp2, 1)
    if tTmp2[1].dst > 15 then
      RunTo(tTmp2[1].x, tTmp2[1].y, 0, 500)
    end
    local bGuid2 = CDG.pet2.GUID
    local bGuid3 = CDG.pet3.GUID
    CDG.pet2.GUID = 0
    CDG.pet3.GUID = 0
    FubenAttack(tTmp2[1].id, nil, nil, true, false)
    CDG.pet2.GUID = bGuid2
    CDG.pet3.GUID = bGuid3
    Sleep(100)
    return 1
  else
    local tTmp3 = ObjFilterByClass(aObj, {
      1,
      0,
      0,
      0
    })
    local nLevel = Player:GetDataInt("LEVEL")
    tTmp2 = ObjFilterByInt(tTmp3, nLevel, 2, "level")
    if #tTmp2 > 0 then
      BubbleByDst(tTmp2, 1)
      if tTmp2[1].dst > 3 then
        RunTo(tTmp2[1].x, tTmp2[1].y, 0, 200)
      end
      if tTmp2[1].dst < 5 then
        Player:TeamFollow(false, 200)
        Dismount()
        OpenTalk(tTmp2[1].id, 150)
      else
        PickUpLua(nil, true)
        MoveTo(tTmp2[1].x, tTmp2[1].y, GetSceneID(), 4)
      end
    else
      tTmp2 = ObjFilterByColor(tTmp, "红")
      if #tTmp2 > 0 then
        BubbleByHP(tTmp2, 1)
        if tTmp2[1].dst > 8 then
          RunTo(tTmp2[1].x, tTmp2[1].y, 0, 300)
        end
        FubenAttack(tTmp2[1].id)
        Sleep(100)
      else
      end
    end
  end
  return 0
end

local function mzdz_FindMazei(aSceneID)
  local bWaitBag = false
  local bAttack = false
  while Player:IsLeader() do
    local tObj = Enum2XByName(m_data.npc_name, {
      1,
      1,
      0,
      0
    }, nil, nil, 3)
    if #tObj <= 0 then
      return false
    end
    tObj = ObjFilterByColor(tObj, "红绿")
    tObj = MZ_FilterMazei(tObj)
    local tKill, bWaitForBag = MZ_TongJiNumAndFilterHP(tObj)
    if #tKill > 0 then
      bAttack = true
    end
    bWaitBag = bWaitBag or bWaitForBag
    local tTmp = tKill
    local nRet = 0
    if #tTmp > 0 then
      if GetSceneID() == aSceneID then
        m_data.lasttick_findMazei = GetTickCount()
      end
      nRet = mz_handleMazei(tTmp)
    else
      break
    end
    if 1 ~= nRet then
      PickUpLua(nil, true)
    end
    if 2 == nRet then
      break
    end
    Sleep(100)
    DebugStr("逆袭:击杀刺客中")
  end
  if bWaitBag then
    local nNowTick = GetTickCount()
    while true do
      local nMiff = m_param.waitbag_timeout * 1000 - (GetTickCount() - nNowTick)
      PickUpLua(nil, true)
      if GetTickCount() - nNowTick > 20000 then
        PushDebugMessage("逆袭:捡包等待时间过长,结束等待")
        break
      end
      if nMiff < 0 then
        nMiff = 0
      end
      PushDebugMessage("逆袭:等包倒计时 " .. math.floor(nMiff / 1000) .. " 秒,可设置时间")
      if nMiff <= 0 then
        break
      end
      local tObj = Enum2XByName(m_data.npc_name, {
        1,
        1,
        0,
        0
      }, {0, -1}, nil, 3)
      tObj = ObjFilterByColor(tObj, "红绿")
      if #tObj > 0 then
        PushDebugMessage("等包时又发现刺客")
        break
      end
      UseMount()
      Sleep(950)
    end
    PickUpLua(nil, true)
  end
  return bAttack
end

local function mzdz_CheckCurScene(aCheckScene)
  local curSceneName = GetCurrentSceneName()
  curSceneName = string.gsub(curSceneName, "1线", "")
  curSceneName = string.gsub(curSceneName, "2线", "")
  local nSceneID = GetSceneIDByName(curSceneName)
  if aCheckScene == nSceneID or "" == m_param.sceneText or "" ~= curSceneName and string.find(m_param.sceneText, curSceneName, nil, true) then
    if aCheckScene ~= nSceneID and not m_param.zhongtu_kill then
      local nTeam = Team:GetSurroundMember(99)
      if nTeam < 3 then
        DebugStr("逆袭:周围队员少于3个,暂不杀中途的马！", 2)
        return false
      end
    end
    return mzdz_FindMazei(aCheckScene)
  end
  if "" ~= curSceneName and not string.find(m_param.sceneText, curSceneName, nil, true) then
    DebugStr("逆袭:此地图不刷 " .. curSceneName, 2)
  end
  return false
end

local function MZ_ExceptonState()
  CheckDieState()
end

local function mzdy_callback(fX, fY, nScene)
  local leader, isleader = Team:GetLeaderInfo()
  if not leader then
    if Player:IsInTeam(true) == false then
      return false, nil
    end
    DebugStr("刷马跟随队长：正在移动到 x:%s y:%s scene:%s", 1, fX, fY, nScene)
    return true, nil
  end
  if isleader then
    return false, nil
  end
  if Player:IsFollow() then
    return false, nil
  end
  if -1 ~= FollowFilterScene(leader.sceneID) then
    DebugStr("刷马跟随队长：队长不在正确的地图,暂不跟随!")
    return false, nil
  end
  local leaderObj = FindObjByGUID(leader.guid)
  if leaderObj then
    RunTo(leaderObj.x, leaderObj.y, 1, 350)
    if leaderObj.dst <= 3 then
      return false, nil
    else
      leaderObj.sceneID = leader.sceneID
      return true, leaderObj
    end
  end
  if leader.sceneID == 10001 then
    PushDebugMessage("逆袭跟随队长：队长可能在帮会")
  end
  if mzmv_ShoufeiNPC(leader.x, leader.y, leader.sceneID) then
    return false, nil
  end
  if mzmv_Dingweifu(leader.x, leader.y, leader.sceneID) then
    mzmv_ShoufeiNPC(leader.x, leader.y, leader.sceneID)
    return false, nil
  end
  DebugStr("逆袭跟随队长：移动到 x:%s y:%s scene:%s", 1, math.floor(leader.x), math.floor(leader.y), leader.sceneID)
  local strScene = GetCurrentSceneName()
  if (string.find(strScene, "2线", nil, true) or string.find(strScene, "3线", nil, true)) and leader.sceneID == GetSceneID() then
    ChangeSceneLine()
  end
  if leader.x > 0 and (leader.x ~= fX or leader.y ~= fY or leader.sceneID ~= nScene) then
    if leader.sceneID ~= 65535 then
      AutoRunToTarget(leader.x, leader.y, leader.sceneID, true)
      Sleep(300)
    else
      return true, nil
    end
  else
    return true, nil
  end
  return true, leader
end

local function MZ_OnPlayer()
  local leaderDist = 3
  local xLast, yLast, nLastTime = -1, -1, -1
  while not Player:IsLeader() do
    if Player:IsFollow() then
      if m_param.member_katu then
        local selfPos = Player:GetPos()
        if selfPos.x ~= xLast or selfPos.y ~= yLast then
          xLast, yLast = selfPos.x, selfPos.y
          nLastTime = -1
        else
          local leader = Team:GetLeaderInfo()
          if leader then
            local t1 = FindObjByGUID(leader.guid)
            if not t1 then
              if GetSceneID() == leader.sceneID then
                if GetDist(leader.x, leader.y, selfPos.x, selfPos.y) > 30 then
                  if -1 ~= nLastTime then
                    if GetTickCount() - nLastTime > 5000 and not IsSceneTransed() then
                      PushColorMsg("逆袭:队员卡图,自动退出跟随")
                      Player:TeamFollow(false, 300)
                    end
                  else
                    nLastTime = GetTickCount()
                  end
                else
                  nLastTime = -1
                end
              else
                nLastTime = -1
              end
            else
              nLastTime = -1
            end
          else
            nLastTime = -1
          end
        end
      end
      DebugStr("逆袭:队员组队跟随中")
    else
      xLast, yLast, nLastTime = -1, -1, -1
      UseMaAn()
      GoToLeader(mzdy_callback, nil, false, false, leaderDist)
      Sleep(20)
      local tObj = Enum2XByName(m_data.npc_name, {
        0,
        1,
        0,
        0
      }, nil, nil, 3)
      tObj = ObjFilterByColor(tObj, "红绿")
      tObj = MZ_TongJiNumAndFilterHP(tObj)
      if #tObj > 0 then
        leaderDist = 7
        local tTmp = ObjFilterByColor(tObj, "绿")
        if #tTmp > 0 then
          BubbleByHP(tTmp, 1)
          local bGuid2 = CDG.pet2.GUID
          local bGuid3 = CDG.pet3.GUID
          CDG.pet2.GUID = 0
          CDG.pet3.GUID = 0
          FubenAttack(tTmp[1].id, nil, nil, true, false)
          CDG.pet2.GUID = bGuid2
          CDG.pet3.GUID = bGuid3
          Sleep(200)
        else
          BubbleByHP(tObj, 1)
          FubenAttack(tObj[1].id)
          Sleep(200)
        end
      else
        leaderDist = 3
        PickUpLua(nil, true)
        if not IsMount() then
          local _ld = Team:GetLeaderInfo()
          if _ld and FindObjByGUID(_ld.guid) then
            FubenAttack(-1)
          end
        end
      end
      if 1 == m_data.over_mark then
        break
      end
      DebugStr("逆袭:队员跟随队长")
    end
    Sleep(80)
    PickUpLua(nil, true)
    MZ_ExceptonState()
  end
end

local function mzdz_callback(fX, fY, nScene)
  if mzdz_CheckCurScene(nScene) then
    if not Player:IsFollow() then
      UseMaAn()
      UseMount()
      Sleep(300)
      Player:TeamFollow(true, 300)
    end
    PickUpLua(nil, true)
    MoveKaTuSetLastPos(Player:GetPos())
  end
  if not Player:IsLeader() then
    return false
  end
  local bWaitMember = false
  if mzmv_ShoufeiNPC(fX, fY, nScene) then
    bWaitMember = true
  end
  if not bWaitMember and mzmv_Dingweifu(fX, fY, nScene) then
    UseMount()
  end
  if 2 == m_data.over_mark then
    return false
  end
  if mzmv_ShoufeiNPC(fX, fY, nScene) then
    bWaitMember = true
  end
  if bWaitMember then
    local nTickOut = GetTickCount()
    while true do
      local nTeam = Team:GetSurroundMember(99)
      if nTeam >= 3 then
        if GetTickCount() - nTickOut > 3000 then
          Sleep(1000)
        end
        break
      end
      if not Player:IsLeader() then
        break
      end
      local nDiff = GetTickCount() - nTickOut
      if nDiff > 15000 then
        PushDebugMessage("传送后等待队员超时！")
        break
      end
      PushDebugMessage("传送等待队员,%d秒后超时", math.floor((15000 - nDiff) / 1000))
      ChangeSceneLine()
      Sleep(980)
      UseMount()
    end
    Player:TeamFollow(true, 500)
    if GetSceneID() == nScene then
      RunTo(fX, fY, 0, 300)
    else
      AutoRunToTarget(fX, fY, nScene, false)
      Sleep(300)
    end
    Player:TeamFollow(true, 300)
  end
  if 2 == m_data.over_mark then
    return false
  end
  local nNowScene = GetSceneID()
  if nNowScene == nScene then
    ChangeSceneLine()
  end
  if not Player:IsFollow() then
    UseMount()
    Sleep(500)
    Player:TeamFollow(true, 500)
    PickUpLua(nil, true)
    if GetSceneID() == nScene then
      RunTo(fX, fY, 0, 300)
    else
      AutoRunToTarget(fX, fY, nScene, false)
      Sleep(300)
    end
    Player:TeamFollow(true, 200)
  end
  return true
end

local function MZ_XiuFuPos(aPosX, aPosY, aSceneID)
  if 34 == aSceneID and 57 == aPosX and 32 == aPosY then
    return 57, 39
  end
  return aPosX, aPosY
end

local function MZ_SearchScene(aSearchceneID, iPosStart, aWumaTimeout)
  local map = g_MaZeiPos[aSearchceneID]
  if nil == map then
    return
  end
  if -1 == iPosStart then
    iPosStart = GetNearestPoint(map)
  end
  local nPos = #map
  if iPosStart >= nPos then
    iPosStart = 1
  end
  m_data.lasttick_findMazei = -1
  for i = 1, nPos do
    if i >= iPosStart then
      local runX, runY = MZ_XiuFuPos(map[i].x, map[i].y, aSearchceneID)
      PushDebugMessage("逆袭:前往[%d,%d]寻马,共%d个坐标,还剩余%d个", math.floor(runX), math.floor(runY), nPos, nPos - i)
      mzdz_CheckCurScene(aSearchceneID)
      MoveTo(runX, runY, aSearchceneID, 3, nil, nil, mzdz_callback)
      if aWumaTimeout and -1 == m_data.lasttick_findMazei then
        m_data.lasttick_findMazei = GetTickCount()
      end
      if aWumaTimeout and -1 ~= m_data.lasttick_findMazei and m_param.unfind_timeout > 0 and GetTickCount() - m_data.lasttick_findMazei > m_param.unfind_timeout * 1000 then
        PushColorMsg("逆袭:此地图已 " .. m_param.unfind_timeout .. " 秒  没有找到刺客,提前换图！")
        break
      end
    end
    if not Player:IsLeader() then
      break
    end
    if 2 == m_data.over_mark then
      m_data.over_mark = 0
      break
    end
    if 1 == m_data.over_mark then
      break
    end
  end
end

local function MZ_OnLeader(aMode)
  if m_param.mode_cur then
    local curSceneID = GetSceneID()
    if g_MaZeiPos[curSceneID] then
      PushColorMsg("逆袭:先刷当前地图")
      local tarSceneName = GetSceneNameByID(curSceneID)
      if "长白山" == tarSceneName then
        tarSceneName = "长1白1山"
      end
      TalkChatMsg("team", fmt("#eaf0c14#Y请速度前往【%s】集合!", tarSceneName))
      MZ_SearchScene(curSceneID, -1, false)
    end
    m_param.mode_cur = false
  end
  while Player:IsLeader() do
    mzdz_CheckCurScene(GetSceneID())
    if 1 == aMode then
      local tTar = MZ_GetTargetScene()
      if tTar then
        local nowTime = os.time()
        local h = tonumber(os.date("%H", nowTime))
        local m = tonumber(os.date("%M", nowTime))
        local s = tonumber(os.date("%S", nowTime))
        local tarSceneName = tTar.sceneName
        if "长白山" == tarSceneName then
          tarSceneName = "长1白1山"
        end
        TalkChatMsg("team", fmt("#eaf0c14#Y%.2d:%.2d:%.2d 请速度前往【%s】刷马", h, m, s, tarSceneName))
        MZ_SearchScene(tTar.sceneID, 1, true)
        MZ_PushRecord(tTar.tick, tTar.sceneName)
      else
        DebugStr("逆袭:无马可刷,未设置等待地图坐标,原地等待刷新")
        FubenAttack(-1)
        Sleep(1000)
      end
    elseif 3 == aMode then
      for i = 1, #m_param.scene do
        local tmp = m_param.scene[i]
        local nowTime = os.time()
        local h = tonumber(os.date("%H", nowTime))
        local m = tonumber(os.date("%M", nowTime))
        local s = tonumber(os.date("%S", nowTime))
        local tarSceneName = tmp.sceneName
        if "长白山" == tarSceneName then
          tarSceneName = "长1白1山"
        end
        TalkChatMsg("team", fmt("#eaf0c14#Y%.2d:%.2d:%.2d请速度前往【%s】", h, m, s, tarSceneName))
        MZ_SearchScene(tmp.sceneID, 1, false)
      end
    end
    Sleep(50)
    MZ_ExceptonState()
    if 1 == m_data.over_mark then
      break
    end
  end
end

function _SMain(...)
  LeaveSpecialScene(nil, nil)
  if not MZ_Init() then
    return
  end
  PushColorMsg(fmt("逆袭:累计已杀%d个刺客", g_data_nixi.all_kill))
  while true do
    if Player:IsLeader() then
      PushColorMsg("逆袭:队长模式,循环打勾地图")
      MZ_OnLeader(3)
    else
      PushDebugMessage("逆袭:队员模式")
      MZ_OnPlayer()
    end
    if 1 == m_data.over_mark then
      break
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  if not IsSafeSceneID() then
    GoBackCity()
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
m_data = nil
g_MaZeiPos = nil
