-- 反编译自 dfz64.dll 内嵌字节码 00368d15（unluac 2025-12-23；仅供分析）
local m_script_name = "团战打架"
ScriptOnStart(m_script_name, false, false)
CDG:InitFubenParam()
CDG:PetParamOther()
CDG.attack = true
CDG.skill_state = g_config.skill.pk_zhuangtai
CDG.skill_attack = g_config.skill.pk_gongji
local m_dingwei = {
  x = -1,
  y = -1,
  sceneID = -1
}
local m_data = {}
m_data.all_friend_name = ""
m_data.un_follow_scene = " 77 578 823 "
m_data.filter = {}
m_data.target = {
  x = -1,
  y = -1,
  sceneID = -1,
  findtick = -1,
  run = false
}
m_data.tick_tlz_set = GetTickCount()
local m_param = {
  follow = {
    switch = false,
    distance = 8,
    leader = false,
    list = "",
    allmap = false,
    priority = false
  },
  xuanzhan = {
    switch = false,
    bangmeng = "",
    list = ""
  },
  sort = {
    mode = {},
    name = "",
    menpai = ""
  },
  huidian = {
    setDW = false,
    dwhd = false,
    zlhd = false,
    jsqf = false,
    dieout = false
  },
  zhandou = {
    switch = false,
    shuaxintime = 0,
    yidongstop = false,
    zhuiji = false
  },
  js = {
    killall = false,
    mingdan = {switch = false, list = ""},
    xiezhu = {
      switch = false,
      leader = false,
      list = ""
    }
  },
  csbh = false
}
m_param.follow.switch = ReadConfigBool("ZH", "xzk224")
m_param.follow.distance = ReadConfigInt("ZH", "bjk38")
m_param.follow.leader = ReadConfigBool("ZH", "xzk96")
m_param.follow.list = HandleText_AddFuHao(ReadConfigText("ZH", "bjk159"))
m_param.follow.allmap = ReadConfigBool("ZH", "xzk134")
m_param.follow.priority = ReadConfigBool("ZH", "xzk135")
m_param.xuanzhan.switch = ReadConfigBool("ZH", "xzk220")
m_param.xuanzhan.bangmeng = HandleText_AddFuHao(ReadConfigText("ZH", "bjk155"))
m_param.xuanzhan.list = HandleText_AddFuHao(ReadConfigText("ZH", "bjk157"))
m_param.js.killall = ReadConfigBool("ZH", "xzk221")
m_param.js.mingdan.switch = ReadConfigBool("ZH", "xzk222")
m_param.js.mingdan.list = HandleText_AddFuHao(ReadConfigText("ZH", "bjk156"))
m_param.js.xiezhu.switch = ReadConfigBool("ZH", "xzk223")
m_param.js.xiezhu.leader = ReadConfigBool("ZH", "xzk136")
m_param.js.xiezhu.list = HandleText_AddFuHao(ReadConfigText("ZH", "bjk158"))
m_param.zhandou.switch = true
m_param.zhandou.shuaxintime = ReadConfigInt("ZH", "bjk162")
m_param.zhandou.yidongstop = ReadConfigBool("ZH", "xzk195")
m_param.zhandou.zhuiji = ReadConfigBool("ZH", "xzk225")
m_param.huidian.setDW = ReadConfigBool("ZH", "xzk94")
m_param.huidian.dwhd = ReadConfigBool("ZH", "xzk93")
m_param.huidian.zlhd = true
m_param.huidian.jsqf = true
m_param.huidian.dieout = ReadConfigBool("ZH", "xzk95")
m_param.sort.name = HandleText_AddFuHao(ReadConfigText("ZH", "bjk151"))
m_param.sort.menpai = HandleText_AddFuHao(ReadConfigText("ZH", "bjk154"))
local szJiShaShunXu = ReadConfigText("ZH", "lbk25")
m_param.follow.auto_check = false

function PK_JiShaMode()
  m_param.sort.mode = SplitString(szJiShaShunXu, ",")
  for i = 1, #m_param.sort.mode do
    if m_param.sort.mode[i] == "血低于30%" then
      m_param.sort.mode[i] = "血低"
    elseif m_param.sort.mode[i] == "距离近的目标" then
      m_param.sort.mode[i] = "距离近"
    elseif m_param.sort.mode[i] == "被放大的" then
      m_param.sort.mode[i] = "放大"
    elseif m_param.sort.mode[i] == "协助者的目标" then
      m_param.sort.mode[i] = "协助"
    elseif m_param.sort.mode[i] == "优先的玩家名" then
      m_param.sort.mode[i] = "名称"
    elseif m_param.sort.mode[i] == "优先的门派" then
      m_param.sort.mode[i] = "门派"
    end
  end
end

function PK_CheckSetDingWei(aMust)
  if m_param.huidian.setDW and (aMust or GetTickCount() - m_data.tick_tlz_set > 2000) then
    m_data.tick_tlz_set = GetTickCount()
    local nSceneID = GetSceneID()
    if not IsSafeSceneID(nSceneID) then
      local selfPos = Player:GetPos()
      if nSceneID > 0 and (m_dingwei.sceneID ~= nSceneID or GetDist(m_dingwei.x, m_dingwei.y, selfPos.x, selfPos.y) > 10) and SetDingWeiZhu(2) then
        m_dingwei.sceneID = nSceneID
        m_dingwei.x = selfPos.x
        m_dingwei.y = selfPos.y
      end
    end
  end
end

function PK_UseChuanSong()
  if m_param.huidian.dwhd and -1 ~= m_dingwei.sceneID and Bag_UseTuLingZhu(m_dingwei.sceneID, m_dingwei) == false then
    Bag_UseDingWeiCDFL(GetSceneNameByID(m_dingwei.sceneID))
  end
end

function PK_cb_ToLeader(fX, fY, nScene)
  local info, isLeader = GetTRLeaderInfo()
  if isLeader or nil == info then
    return false, nil
  end
  if m_param.follow.allmap then
    if IsDiFuScene(info.sceneID) then
      return false, nil
    end
    if m_param.follow.auto_check then
      if info.sceneID ~= GetSceneID() and CheckLeaderScene(m_data.un_follow_scene, 2) then
        DebugColorMsg("队长最近2个地图曾在地府,暂不跟随", 3)
        return false, nil
      end
    elseif IsSafeSceneID(info.sceneID) and not IsSafeSceneID() then
      PushColorMsg("队团长在安全地图暂不跟随")
      return false, nil
    end
  elseif info.sceneID ~= GetSceneID() then
    DebugColorMsg("队团长不在当前地图暂不跟随", 3)
    return false, nil
  end
  PK_CheckUseQingGong(fX, fY)
  return MoveCallBack_GoToTRLeader(fX, fY, nScene)
end

function PK_ToLeader()
  DeleteDebugMsg("#{ResultText_167}")
  
  local function _cb(aLeader)
    if m_param.follow.auto_check and aLeader and string.find(m_data.un_follow_scene, " " .. aLeader.sceneID .. " ", nil, true) then
      return false
    end
    return true
  end
  
  GoToTRLeader(PK_cb_ToLeader, MoveCallBack_state_2, nil, nil, m_param.follow.distance, _cb)
  Dismount()
end

function PK_GetLeaderInfo()
  local leader = Raid:GetLeaderInfo()
  if nil == leader then
    leader = Team:GetLeaderInfo()
  end
  return leader
end

function PK_runCallBack()
  DebugStr("正在移动中...", 3)
  return true
end

function PK_CheckSelfPos()
  local bFollowOK = false
  local bUseTLZ = false
  local nSceneID = GetSceneID()
  if IsDiFuScene(nSceneID) then
    if m_param.huidian.dwhd then
      bUseTLZ = true
    end
    CDG:checkDiFu()
    CDG:BossStart(-1)
  end
  if bUseTLZ and -1 ~= m_dingwei.sceneID then
    CDG:BossStart(-1)
    PK_UseChuanSong()
  elseif m_param.follow.switch then
    local bFollow = false
    local szFollow = m_param.follow.list
    local tLeader
    if m_param.follow.leader then
      tLeader = PK_GetLeaderInfo()
      if tLeader then
        szFollow = szFollow .. " " .. tLeader.name
      end
    end
    local tFollow = Enum2XByName(szFollow, {
      0,
      0,
      1,
      0,
      0
    }, {0, 0}, 0, 3)
    if #tFollow > 0 then
      if tLeader then
        for i = 1, #tFollow do
          if tFollow[i].name == tLeader.name then
            bFollow = true
            if tFollow[i].dst >= m_param.follow.distance then
              RunTo(tFollow[i].x, tFollow[i].y, 0, 500)
              break
            end
            bFollowOK = true
            break
          end
        end
      end
      if false == bFollow then
        BubbleByDst(tFollow, 1)
        if tFollow[1].dst >= m_param.follow.distance then
          RunTo(tFollow[1].x, tFollow[1].y, 0, 500)
        else
          bFollowOK = true
        end
      end
    end
    if 0 == #tFollow and tLeader then
      if GetSceneID() ~= tLeader.sceneID then
        if m_param.follow.allmap then
          PK_ToLeader()
        else
          bFollowOK = true
          DebugStr("跟随目标不在同一个地图,非跨图跟随模式", 2)
        end
      else
        PK_ToLeader()
      end
    end
  end
  return bFollowOK
end

function PK_execXuanZhan(tObj)
  local strText = fmt([[
            local tid = %d
            setmetatable(_G, {__index = PlayerList_Env})
            local ret = SetMainTargetFromList(tid , true ,false)
            if ret == 1 then
                Player:PVP_Challenge(2);               
            end            
        ]], tObj.id)
  GetLuaValue(strText)
end

function Sort_xiezhu(tObj)
  local tXieZhu = {}
  for i = 1, #tObj do
    if tObj[i].isxiezhu then
      table.insert(tXieZhu, tObj[i])
    end
  end
  return tXieZhu
end

function Pk_sort_onmode(mode, tObj)
  local tRet = {}
  if "血低" == mode then
    tRet = Sort_hp_little(tObj)
  elseif "距离近" == mode then
    tRet = Sort_dist(tObj)
  elseif "放大" == mode then
    tRet = Sort_fangda(tObj)
  elseif "协助" == mode then
    tRet = Sort_xiezhu(tObj)
  elseif "名称" == mode then
    tRet = Sort_name(tObj, m_param.sort.name)
  elseif "门派" == mode then
    tRet = Sort_menpai(tObj, m_param.sort.menpai)
  else
    PushColorMsg("PK:出现错误")
  end
  return tRet
end

function PK_TargetSort(tObj)
  local tFilter = {}
  local tLast = tObj
  for i = 1, 6 do
    tFilter = Pk_sort_onmode(m_param.sort.mode[i], tLast)
    if #tFilter > 0 then
      tLast = tFilter
    end
  end
  return tLast
end

function PK_EnumEnemyXieZhu()
  local tTid = {}
  if m_param.js.xiezhu.switch then
    if m_param.js.xiezhu.leader then
      local tLeader = PK_GetLeaderInfo()
      if tLeader then
        local tObj = Enum2XByName(tLeader.name, {
          0,
          0,
          1,
          0,
          0
        }, {0, 0}, nil, 0)
        if #tObj > 0 and tObj[1].target > -1 then
          table.insert(tTid, tObj[1].target)
        end
      end
    end
    local tObj = Enum2XByName(m_param.js.xiezhu.list, {
      0,
      0,
      1,
      0,
      0
    }, {0, 0}, nil, 3)
    for i = 1, #tObj do
      if tObj[i].target > -1 then
        table.insert(tTid, tObj[i].target)
      end
    end
  end
  return tTid
end

function PK_EnemyIsInXuanZhan(tObj)
  local bIsIn = false
  if string.find(m_param.xuanzhan.list, " " .. tObj.name .. " ", nil, true) then
    bIsIn = true
  elseif string.find(m_param.xuanzhan.bangmeng, " " .. tObj.bhid .. " ", nil, true) then
    bIsIn = true
  elseif tObj.strzhanmeng ~= "" and string.find(m_param.xuanzhan.bangmeng, " " .. tObj.strzhanmeng .. " ", nil, true) then
    bIsIn = true
  end
  return bIsIn
end

function PK_EnemyIsInMingDan(tObj)
  local bIsIn = false
  if m_param.js.mingdan.switch and string.find(m_param.js.mingdan.list, " " .. tObj.name .. " ", nil, true) then
    bIsIn = true
  end
  return bIsIn
end

function PK_EnemyIsInTable(tObj, tSingle)
  local bIsIn = false
  for i = 1, #tObj do
    if tObj[i] == tSingle.id then
      bIsIn = true
      break
    end
  end
  return bIsIn
end

function PK_OnAttack(tObj)
  local tid = tObj.id
  local startTick = GetTickCount()
  while 9 ~= Player:GetState() do
    local target = FindObjByTID(tid)
    if not target or 0 == target.hp then
      break
    end
    local bKongZhi, bFangDa, bWuDi, bZuoQi = Target:GetSpecialBuff(target)
    if false == bWuDi then
      Dismount()
      if bZuoQi then
        Skill:UseSkillByName("落马箭", tid, nil, nil, 100)
      end
      if Player:GetDataInt("MP") > 500 then
        if false == bKongZhi then
          Skill:UseKongZhi(g_config.skill.pk_kongzhi, target, false)
        end
        CDG:SkillAttack(tid)
      end
    else
      PushDebugMessage("%s 处于无敌状态,寻找其他目标...", target.name)
      break
    end
    Target:Attack(tid, 200, true)
    StateRemoveBad(true, true, true, true, true)
    Sleep(50)
    DebugStr("正在击杀：%s", 4, target.name)
    if m_param.zhandou.yidongstop and 2 == Player:GetState() then
      PlayerStateTimeOut(2, 300, PK_runCallBack)
    elseif m_param.zhandou.zhuiji then
      local cmp = 9
      if g_self.isjingong then
        cmp = 5
      end
      local dist = GetDist(target.x, target.y)
      if cmp < dist then
        if false == Skill:UseSpeed() then
          Skill:UseShunYi(target.x, target.y)
        end
        RunTo(target.x, target.y, 1, 500)
      end
    end
    if GetTickCount() - startTick > m_param.zhandou.shuaxintime * 1000 then
      break
    end
  end
end

function PK_EnumCanAttackTarget()
  local tObj = EnumPlayerList(false)
  local tKill = {}
  local tXieZhu = PK_EnumEnemyXieZhu()
  if m_param.js.killall then
    for i = 1, #tObj do
      if PK_EnemyIsInTable(tXieZhu, tObj[i]) then
        tObj[i].isxiezhu = true
      end
    end
    tKill = tObj
  else
    for i = 1, #tObj do
      if PK_EnemyIsInTable(tXieZhu, tObj[i]) then
        tObj[i].isxiezhu = true
        table.insert(tKill, tObj[i])
      elseif PK_EnemyIsInMingDan(tObj[i]) or PK_EnemyIsInXuanZhan(tObj[i]) then
        table.insert(tKill, tObj[i])
      end
    end
  end
  return tKill
end

function PK_OnKillPet(tObj)
  DebugStr("目标[无敌]状态,攻击珍兽...", 2)
  local tCanKill = PK_TargetSort(tObj)
  local tPet = Enum2XByClass("珍兽", {0, -1})
  for i = 1, #tCanKill do
    for j = 1, #tPet do
      if tPet[j].petzrid == tCanKill[i].id then
        Dismount()
        Target:Attack(tPet[j].id, 100, true)
        return true
      end
    end
  end
end

function PK_OnXuanZhan()
  if m_param.xuanzhan.switch == false then
    return false
  end
  local tObj = EnumPlayerList(true)
  local tXuanZhan = {}
  local tXieZhu = PK_EnumEnemyXieZhu()
  for i = 1, #tObj do
    if PK_EnemyIsInTable(tXieZhu, tObj[i]) then
      tObj[i].isxiezhu = true
    end
    if PK_EnemyIsInXuanZhan(tObj[i]) then
      local bKongZhi, bFangDa, bWuDi, bZuoQi = Target:GetSpecialBuff(tObj[i])
      local tmp = tObj[i]
      tmp.fangda = bFangDa
      table.insert(tXuanZhan, tmp)
    end
  end
  local tCanKill = PK_TargetSort(tXuanZhan)
  if #tCanKill > 0 then
    DebugStr("宣战：" .. tCanKill[1].name, 2)
    PK_execXuanZhan(tCanKill[1])
    Sleep(150)
    return true
  end
  return false
end

function PK_OnAction()
  if m_param.zhandou.yidongstop and 2 == Player:GetState() then
    DebugStr("移动中不攻击", 3)
    return true
  end
  local tObj = PK_EnumCanAttackTarget()
  if 0 == #tObj then
    return false
  end
  local tKill = {}
  for i = 1, #tObj do
    local bKongZhi, bFangDa, bWuDi, bZuoQi = Target:GetSpecialBuff(tObj[i])
    if false == bWuDi then
      local tmp = tObj[i]
      tmp.fangda = bFangDa
      table.insert(tKill, tmp)
    end
  end
  local tCanKill = PK_TargetSort(tKill)
  if 0 == #tCanKill then
    PK_OnKillPet(tObj)
  else
    PK_OnAttack(tCanKill[1])
  end
  return true
end

function _SMain(...)
  LoadScript("pkfun")
  LoadScript("fn修理装备")
  PK_JiShaMode()
  while true do
    if 9 == Player:GetState() then
      if m_param.huidian.dieout then
        CheckDieState()
      else
        while 9 == Player:GetState() do
          DebugStr("打架时角色死亡,未设置自动出窍,等待救起")
          Sleep(1000)
          GetLuaValue("meReliveHandle(0)")
        end
      end
    else
      if IsSafeSceneID() == false then
        if m_param.follow.priority then
          if PK_CheckSelfPos() == true then
            if false == PK_OnAction() then
              CDG:checkMP()
              PK_OnXuanZhan()
            end
          else
            CDG:checkMP()
          end
        elseif false == PK_OnAction() then
          CDG:checkMP()
          if false == PK_OnXuanZhan() then
            PK_CheckSelfPos()
          end
        end
      else
        CDG:checkMP()
        CDG:SkillState()
        PK_CheckSelfPos()
      end
      PK_CheckSetDingWei()
    end
    Sleep(50)
    DebugStr("团战打架...")
  end
end

_SMain()
ScriptOnStop(m_script_name)
