-- 反编译自 dfz64.dll 内嵌字节码 004690da（unluac 2025-12-23；仅供分析）
local m_script_name = "定点收购"
ScriptOnStart(m_script_name, false, false, false)
g_config["定点收购"] = {}
g_config["定点收购"]["地图"] = ReadConfigText("ZH", "bjk135")
g_config["定点收购"].pos_x = ReadConfigInt("ZH", "bjk142")
g_config["定点收购"].pos_y = ReadConfigInt("ZH", "bjk143")
g_config["定点收购"]["附近喊话"] = ReadConfigBool("ZH", "xzk73")
g_config["定点收购"]["世界喊话"] = ReadConfigBool("ZH", "xzk184")
g_config["定点收购"]["喊话内容"] = ReadConfigText("ZH", "bjk48")
g_config["扫街收购"] = {}
g_config["扫街收购"]["商会取钱"] = ReadConfigBool("ZH", "xzk168")
g_config["扫街收购"]["取金数量"] = ReadConfigInt("ZH", "bjk56")
g_config["扫街收购"]["结束时间"] = ReadConfigInt("ZH", "bjk41")
g_config["扫街收购"]["结束金币"] = ReadConfigInt("ZH", "bjk40")
g_config["扫街收购"]["道具空位"] = ReadConfigInt("ZH", "bjk49")
g_config["扫街收购"]["材料空位"] = ReadConfigInt("ZH", "bjk133")
g_config["扫街收购"]["道具执行"] = ReadConfigBool("ZH", "xzk182")
g_config["扫街收购"]["材料执行"] = ReadConfigBool("ZH", "xzk183")
g_config["扫街收购"]["包满运行"] = ReadConfigText("ZH", "bjk134")
local m_sg_param = {}
m_sg_param.list_item = {}
m_sg_param.shqq = g_config["扫街收购"]["商会取钱"]
m_sg_param.qjsl = HandleTextToNumber(g_config["扫街收购"]["取金数量"], 1000)
m_sg_param.max_time = HandleTextToNumber(g_config["扫街收购"]["结束时间"], 999)
m_sg_param.min_jinbi = HandleTextToNumber(g_config["扫街收购"]["结束金币"], 10) * 10000
m_sg_param.full_daoju = g_config["扫街收购"]["道具执行"]
m_sg_param.full_cailiao = g_config["扫街收购"]["材料执行"]
m_sg_param.min_space_daoju = HandleTextToNumber(g_config["扫街收购"]["道具空位"], 2)
m_sg_param.min_space_cailiao = HandleTextToNumber(g_config["扫街收购"]["材料空位"], 2)
m_sg_param.runScript = g_config["扫街收购"]["包满运行"]
m_sg_param.sceneID = -1
m_sg_param.x = -1
m_sg_param.y = -1

function _SMain(...)
  LoadScript("shanghui")
  LoadScript("jiaoyi")
  local strScene = g_config["定点收购"]["地图"]
  strScene = string.gsub(strScene, "1线", "")
  strScene = string.gsub(strScene, "2线", "")
  strScene = string.gsub(strScene, " ", "")
  local xPos = HandleTextToNumber(g_config["定点收购"].pos_x, 0)
  local yPos = HandleTextToNumber(g_config["定点收购"].pos_y, 0)
  local nScene = GetSceneIDByName(strScene)
  m_sg_param.sceneID = nScene
  m_sg_param.x = xPos
  m_sg_param.y = yPos
  m_sg_param.is_talk_near = g_config["定点收购"]["附近喊话"]
  m_sg_param.is_talk_scene = g_config["定点收购"]["世界喊话"]
  m_sg_param.talk_msg = g_config["定点收购"]["喊话内容"]
  HHSG_Action(m_sg_param, m_script_name)
end

_SMain()
ScriptOnStop(m_script_name, false)
m_sg_param = nil
