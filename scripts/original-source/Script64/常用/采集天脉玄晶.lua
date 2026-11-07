-- 反编译自 dfz64.dll 内嵌字节码 003921c4（unluac 2025-12-23；仅供分析）
ScriptOnStart("采集天脉玄晶")
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
local m_npc = {
  {
    x = 81,
    y = 157,
    sceneID = 854,
    name = "文彦广"
  },
  {
    x = 170,
    y = 148,
    sceneID = 854,
    name = "袁天殊"
  },
  {
    x = 159,
    y = 78,
    sceneID = 854,
    name = "石彩仙"
  },
  {
    x = 72,
    y = 97,
    sceneID = 854,
    name = "崔九变"
  }
}

local function tmxj_check_time()
  local week = tonumber(os.date("%w"))
  if 0 == week then
    week = 7
  end
  local tTime1 = os.date("*t")
  if tTime1.hour > 22 or 22 == tTime1.hour and tTime1.min >= 1 then
    return false
  end
  return true
end

local function tmxj_cj_cb(...)
  if -1 == Player:GetBuff("变身：古境矿师") then
    while -1 == Player:GetBuff("变身：古境矿师") do
      if 0 == Bag:GetItemCount("易容丹：古境矿师") then
        if Player:GetMoney(1) < 500 then
          PushColorMsg("取出金币购买易容丹")
          Bank_GetMoney(10000, "凤鸣镇")
        end
        local myPos = Player:GetPos()
        for i = 1, #m_npc do
          m_npc[i].dst = GetDist(m_npc[i].x, m_npc[i].y, myPos.x, myPos.y)
        end
        BubbleByDst(m_npc)
        local npc = m_npc[1]
        MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID)
        QuestFrameOptionClicked_Item("#{KVKZYZD_110705_09}", 1, 1000)
        Shop_BuyItem("易容丹：古境矿师", 1)
      elseif GetSceneID() == 854 then
        Dismount(500)
        Bag:UseItemByName("易容丹：古境矿师", 1000)
        PlayerStateTimeOut(5, 5)
      else
        local npc = m_npc[1]
        MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID)
      end
      Sleep(1000)
      DebugStr("获取易容丹")
      if false == tmxj_check_time() then
        break
      end
    end
  end
  if false == tmxj_check_time() then
    PushColorMsg("天脉玄晶：当前不在活动时间")
    return true
  end
  return false
end

local function CJ_init()
  local cjpos = {}
  local strpos = GetConfigText("采集天脉玄晶", "多点坐标")
  local arrPos = SplitString(strpos, "|", true)
  for i = 1, #arrPos do
    local strxy = SplitString(arrPos[i], ",", true)
    if 2 ~= #strxy then
      strxy = SplitString(arrPos[i], "，", true)
    end
    if 2 == #strxy then
      local _x = tonumber(strxy[1])
      local _y = tonumber(strxy[2])
      if _x and _y and _x > 0 and _y > 0 then
        table.insert(cjpos, {x = _x, y = _y})
      end
    end
  end
  if 0 == #cjpos then
    PushColorMsg("天脉玄晶:您未设置坐标")
    return false
  end
  m_param.syzq = false
  m_param.jlbz.cmpmin = -1
  m_param.jlbz.cmpmax = 0
  m_param.jlbz.action = -1
  m_param.item = " 天脉玄晶 "
  m_param.cb = tmxj_cj_cb
  local scene = {name = "林海溪谷", pos = cjpos}
  table.insert(m_param.scene, scene)
  return true
end

function _SMain(...)
  LoadScript("caiji")
  if CJ_init() then
    PushDebugMessage("采集地图:" .. Array2Text(m_param.scene, " ", "name"))
    CaiJiOnAction(m_param)
  end
end

_SMain()
ScriptOnStop("采集", false)
