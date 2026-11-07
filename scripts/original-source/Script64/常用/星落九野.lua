-- 反编译自 dfz64.dll 内嵌字节码 003824d1（unluac 2025-12-23；仅供分析）
local m_script_name = "星落九野"
ScriptOnStart(m_script_name)
g_config["星落九野"] = {}
g_config["星落九野"]["紫微凤尾"] = GetConfigBool("星落九野", "紫微凤尾")
g_config["星落九野"]["紫微银堇"] = GetConfigBool("星落九野", "紫微银堇")
g_config["星落九野"]["紫微香兰"] = GetConfigBool("星落九野", "紫微香兰")
g_config["星落九野"]["采集地图"] = GetConfigCommbox("星落九野", "采集地图")
g_xljy_pos = {}
g_xljy_pos["林海溪谷"] = {
  {x = 218, y = 152}
}
g_xljy_pos["忘川花海"] = {
  {x = 76, y = 52}
}
g_xljy_pos["玄海"] = {
  {x = 136, y = 213}
}
g_xljy_pos["漠南青原"] = {
  {x = 177, y = 161}
}
local m_param = {
  over = false,
  bagfullover = false,
  syzq = true,
  ylxs = false,
  jctq = false,
  cjyd = false,
  hcjx = false,
  exp_over = false,
  checktick = -1,
  jlbz = {
    cmpmin = -1,
    cmpmax = 250,
    action = -1
  },
  safepos = {
    sceneName = "",
    x = -1,
    y = -1
  },
  filter = {},
  item = "",
  scene = {},
  cb = nil,
  cj_type = 2
}

local function tmxj_check_time()
  local tTime1 = os.date("*t")
  if 21 == tTime1.hour and tTime1.min >= 33 or tTime1.hour > 21 then
    return false
  end
  return true
end

local function tmxj_cj_cb(...)
  if false == tmxj_check_time() then
    PushColorMsg(m_script_name .. "：当前不在活动时间")
    return true
  end
  return false
end

local function CJ_init()
  if g_config["星落九野"]["紫微凤尾"] then
    m_param.item = m_param.item .. "紫微凤尾 "
  end
  if g_config["星落九野"]["紫微银堇"] then
    m_param.item = m_param.item .. "紫微银堇 "
  end
  if g_config["星落九野"]["紫微香兰"] then
    m_param.item = m_param.item .. "紫微香兰 "
  end
  if #m_param.item < 2 then
    PushColorMsg(m_script_name .. "：未设置采集物品！")
    return false
  end
  local posFile = GetUserScriptPath("星落九野坐标.lua")
  if "" ~= posFile then
    if LoadUserPathScript(posFile) == false then
      PushColorMsg(m_script_name .. ":加载自定义坐标失败,请检查语法或者删除自定义坐标")
    else
      PushColorMsg("已加载用户自定义坐标")
    end
  end
  local strScene = g_config["星落九野"]["采集地图"].text
  if g_xljy_pos[strScene] == nil then
    PushColorMsg("地图设置有误,或者坐标编辑错误")
    return false
  end
  local scene = {
    name = strScene,
    pos = g_xljy_pos[strScene]
  }
  table.insert(m_param.scene, scene)
  m_param.cb = tmxj_cj_cb
  return true
end

function _SMain(...)
  LoadScript("caiji")
  if false == CJ_init() then
    return
  end
  PushDebugMessage(m_script_name .. "地图:" .. Array2Text(m_param.scene, " ", "name"))
  CaiJiOnAction(m_param)
end

_SMain()
ScriptOnStop(m_script_name, false)
