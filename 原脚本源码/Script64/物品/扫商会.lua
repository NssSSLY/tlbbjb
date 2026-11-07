-- 反编译自 dfz64.dll 内嵌字节码 004699da（unluac 2025-12-23；仅供分析）
local m_script_name = "扫商会"
ScriptOnStart(m_script_name, false, false, false)
g_config["扫街收购"] = {}
g_config["扫街收购"]["扫地摊"] = ReadConfigBool("ZH", "xzk155")
g_config["扫街收购"]["扫商会"] = ReadConfigBool("ZH", "xzk156")
g_config["扫街收购"]["扫钱庄"] = ReadConfigBool("ZH", "xzk161")
g_config["扫街收购"]["苏州地摊"] = ReadConfigBool("ZH", "xzk164")
g_config["扫街收购"]["洛阳地摊"] = ReadConfigBool("ZH", "xzk165")
g_config["扫街收购"]["钱庄地摊"] = ReadConfigBool("ZH", "xzk167")
g_config["扫街收购"]["苏州路线"] = ReadConfigText("ZH", "bjk118")
g_config["扫街收购"]["洛阳路线"] = ReadConfigText("ZH", "bjk125")
g_config["扫街收购"]["钱庄路线"] = ReadConfigText("ZH", "bjk128")
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
m_sg_param.sdt = false
m_sg_param.ssh = true
m_sg_param.sqz = false
m_sg_param.dt_sz = g_config["扫街收购"]["苏州地摊"]
m_sg_param.dt_ly = g_config["扫街收购"]["洛阳地摊"]
m_sg_param.dt_qz = g_config["扫街收购"]["钱庄地摊"]
m_sg_param.shqq = g_config["扫街收购"]["商会取钱"]
m_sg_param.qjsl = HandleTextToNumber(g_config["扫街收购"]["取金数量"], 1000)
m_sg_param.max_time = HandleTextToNumber(g_config["扫街收购"]["结束时间"], 999)
m_sg_param.min_jinbi = HandleTextToNumber(g_config["扫街收购"]["结束金币"], 10) * 10000
m_sg_param.full_daoju = g_config["扫街收购"]["道具执行"]
m_sg_param.full_cailiao = g_config["扫街收购"]["材料执行"]
m_sg_param.min_space_daoju = HandleTextToNumber(g_config["扫街收购"]["道具空位"], 2)
m_sg_param.min_space_cailiao = HandleTextToNumber(g_config["扫街收购"]["材料空位"], 2)
m_sg_param.runScript = g_config["扫街收购"]["包满运行"]
m_sg_param.luxian_sz = {}
m_sg_param.luxian_ly = {}
m_sg_param.luxian_qz = {}

function SJSG_Init()
  m_sg_param.luxian_sz = {}
  m_sg_param.luxian_ly = {}
  m_sg_param.luxian_qz = {}
  
  local function _parse(_aInsert, _aStr)
    local arrAll = SplitString(_aStr, "|", true)
    for i = 1, #arrAll do
      local tmp = arrAll[i]
      local arrInfo = SplitString(tmp, ",", true)
      if 2 ~= #arrInfo then
        arrInfo = SplitString(tmp, "，", true)
      end
      if 2 ~= #arrInfo then
        arrInfo = SplitString(tmp, ".", true)
      end
      if 2 == #arrInfo then
        local posX = tonumber(arrInfo[1])
        local posY = tonumber(arrInfo[2])
        if posX and posY then
          table.insert(_aInsert, {x = posX, y = posY})
        end
      end
    end
  end
  
  _parse(m_sg_param.luxian_sz, g_config["扫街收购"]["苏州路线"])
  _parse(m_sg_param.luxian_ly, g_config["扫街收购"]["洛阳路线"])
  _parse(m_sg_param.luxian_qz, g_config["扫街收购"]["钱庄路线"])
end

function _SMain(...)
  PushDebugMessage("扫街收购页面设置物品")
  LoadScript("shanghui")
  SJSG_Init()
  SJSG_Action(m_sg_param, m_script_name)
end

_SMain()
ScriptOnStop(m_script_name, false)
m_sg_param = nil
