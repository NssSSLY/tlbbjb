-- 反编译自 dfz64.dll 内嵌字节码 0035f720（unluac 2025-12-23；仅供分析）
ScriptOnStart("采集")
g_config.caiji = {}
g_config.caiji.jctq = ReadConfigBool("ZH", "xzk53")
g_config.caiji.ylxs = ReadConfigBool("ZH", "xzk143")
g_config.caiji.cjyd = ReadConfigBool("ZH", "xzk144")
g_config.caiji.byzq = ReadConfigBool("ZH", "xzk145")
g_config.caiji.buykc = ReadConfigBool("ZH", "xzk26")
g_config.caiji.buycyl = ReadConfigBool("ZH", "xzk27")
g_config.caiji.hcjx = not ReadConfigBool("ZH", "xzk191")
g_config.caiji.jlmin = ReadConfigInt("ZH", "bjk132")
g_config.caiji.jlmax = ReadConfigInt("ZH", "bjk93")
g_config.caiji.exp_over = false
g_config.caiji.jlbz = {
  sel = -1,
  data = 0,
  text = ""
}
g_config.caiji.jlbz.sel = ReadConfigInt("ZH", "zhk8")
g_config.caiji.aqdt = ReadConfigText("ZH", "bjk98")
g_config.caiji.aqzbx = ReadConfigInt("ZH", "bjk24")
g_config.caiji.aqzby = ReadConfigInt("ZH", "bjk96")
g_config.caiji.item = {}
local strItemText = HandleText_AddFuHao(ReadConfigText("ZH", "lbk12"))
local arrItem = SplitString(strItemText, ",", true)
for i = 1, #arrItem do
  table.insert(g_config.caiji.item, {
    text = arrItem[i],
    data = 0
  })
end
g_config.caiji.scenefile = GetConfigCommbox("设置", "采集地图")
local m_param = {
  over = false,
  bagfullover = true,
  syzq = true,
  ylxs = false,
  jctq = false,
  cjyd = false,
  hcjx = false,
  exp_over = false,
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

local function CJ_init()
  m_param.jctq = g_config.caiji.jctq
  m_param.ylxs = g_config.caiji.ylxs
  m_param.cjyd = g_config.caiji.cjyd
  m_param.syzq = not g_config.caiji.byzq
  m_param.hcjx = g_config.caiji.hcjx
  m_param.exp_over = g_config.caiji.exp_over
  m_param.jlbz.cmpmin = HandleTextToNumber(g_config.caiji.jlmin, 0)
  m_param.jlbz.cmpmax = HandleTextToNumber(g_config.caiji.jlmax, 250)
  m_param.jlbz.action = g_config.caiji.jlbz.sel + 1
  m_param.safepos.sceneName = g_config.caiji.aqdt
  m_param.safepos.x = HandleTextToNumber(g_config.caiji.aqzbx, 0)
  m_param.safepos.y = HandleTextToNumber(g_config.caiji.aqzby, 0)
  for i = 1, #g_config.caiji.item do
    m_param.item = m_param.item .. g_config.caiji.item[i].text .. " "
  end
  if #m_param.item < 2 then
    PushColorMsg("采集：未设置采集物品！")
    return false
  end
  local tmp = g_config.caiji.scenefile.text
  local nStart = string.find(tmp, "级", nil, true)
  if nStart then
    local _name = string.sub(tmp, nStart + 2)
    if "" ~= _name then
      local strSelfPath = g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\坐标\\" .. _name .. ".txt"
      local file = io.open(strSelfPath, "r")
      if not file then
        strSelfPath = GetMainPath() .. "data\\坐标\\" .. tmp .. ".txt"
        file = io.open(strSelfPath, "r")
      end
      if file then
        local strpos = file:read("*a")
        if "string" == type(strpos) and "" ~= strpos then
          local arrPos = SplitString(strpos, "\n", true)
          local _pos = {}
          for i = 1, #arrPos do
            local strxy = SplitString(arrPos[i], ",", true)
            if 2 == #strxy then
              local _x = tonumber(strxy[1])
              local _y = tonumber(strxy[2])
              if not (_x and _y and _x > 0 and _y > 0) or "苍山" == _name and 32 == _x and 166 == _y then
              else
                table.insert(_pos, {x = _x, y = _y})
              end
            end
          end
          if #_pos > 0 then
            local scene = {name = _name, pos = _pos}
            table.insert(m_param.scene, scene)
          else
            PushColorMsg("采集：%s 解析坐标失败请检查！注意是英文的逗号！", tmp .. ".txt")
          end
        else
          PushColorMsg("采集：%s 读取坐标失败！", tmp .. ".txt")
        end
        io.close(file)
      else
        PushColorMsg("采集：%s 文本不存在", tmp .. ".txt")
      end
    end
  end
  if 0 == #m_param.scene then
    return false
  end
  return true
end

function _SMain(...)
  LoadScript("caiji")
  CJ_init()
  if g_config.caiji.buykc then
    CaiJiCheckTool("矿锄")
  end
  if g_config.caiji.buycyl then
    CaiJiCheckTool("采药镰")
  end
  if 0 == #m_param.scene then
    PushDebugMessage("采集:未设置地图")
    return
  else
    PushDebugMessage("采集地图:" .. Array2Text(m_param.scene, " ", "name"))
    CaiJiOnAction(m_param)
    GoBackCity()
  end
end

_SMain()
ScriptOnStop("采集", false)
