-- 反编译自 dfz64.dll 内嵌字节码 0037bcdc（unluac 2025-12-23；仅供分析）
local m_script_name = "峨嵋加血机"
ScriptOnStart(m_script_name, true, false, false)
g_config.emjxj = {}
g_config.emjxj.dingwei_use = ReadConfigBool("ZH", "xzk93")
g_config.emjxj.follow_leader = ReadConfigBool("ZH", "xzk96")
g_config.emjxj.follow_player = false
g_config.emjxj.follow_name = ""
g_config.emjxj.follow_allmap = ReadConfigBool("ZH", "xzk134")
g_config.emjxj.follow_dist = ReadConfigInt("ZH", "bjk38")
g_config.emjxj.run_pause = ReadConfigBool("ZH", "xzk195")
g_config.emjxj.chuansong_protect = ReadConfigBool("ZH", "xzk104")
g_config.emjxj.auto_ylxs = ReadConfigBool("ZH", "xzk106")
g_config.emjxj.auto_wudi = ReadConfigBool("ZH", "xzk07")
g_config.emjxj.auto_dxys = ReadConfigBool("ZH", "xzk108")
CDG:InitFubenParam()
CDG:PetParamOther()
local m_param = {}
m_param.follow_leader = g_config.emjxj.follow_leader
m_param.follow_player = g_config.emjxj.follow_player
m_param.follow_name = g_config.emjxj.follow_name
m_param.follow_allmap = g_config.emjxj.follow_allmap
m_param.follow_dist = HandleTextToNumber(g_config.emjxj.follow_dist, 7)
m_param.dingwei_use = g_config.emjxj.dingwei_use
m_param.dingwei_set = ReadConfigBool("ZH", "xzk94")
m_param.chuansong_qun = true
m_param.chuansong_protect = g_config.emjxj.chuansong_protect
m_param.run_pause = g_config.emjxj.run_pause
m_param.auto_ylxs = g_config.emjxj.auto_ylxs
m_param.auto_wudi = g_config.emjxj.auto_wudi
m_param.auto_dxys = g_config.emjxj.auto_dxys
m_param.dieout = ReadConfigBool("ZH", "xzk95")
local m_dingwei = {
  x = -1,
  y = -1,
  sceneID = -1
}

function PK_CheckSetDingWei()
  if m_param.dingwei_set and not IsSafeSceneID() then
    local nSceneID = GetSceneID()
    local selfPos = Player:GetPos()
    if nSceneID > 0 and (m_dingwei.sceneID ~= nSceneID or GetDist(m_dingwei.x, m_dingwei.y, selfPos.x, selfPos.y) > 10) and SetDingWeiZhu(2) then
      m_dingwei.sceneID = nSceneID
      m_dingwei.x = selfPos.x
      m_dingwei.y = selfPos.y
    end
  end
end

function PK_UseChuanSong()
  if m_param.dingwei_use and -1 ~= m_dingwei.sceneID and Bag_UseTuLingZhu(m_dingwei.sceneID, m_dingwei) == false then
    Bag_UseDingWeiCDFL(GetSceneNameByID(m_dingwei.sceneID))
  end
end

function PK_cb_ToLeader(fX, fY, nScene)
  local info, isLeader = GetTRLeaderInfo()
  if isLeader or nil == info then
    return false, nil
  end
  if m_param.follow_allmap then
    if IsDiFuScene(info.sceneID) or IsSafeSceneID(info.sceneID) and not IsSafeSceneID() then
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
  GoToTRLeader(PK_cb_ToLeader, MoveCallBack_state_2)
  Dismount()
end

function PK_cb_ToPlayer(fX, fY, nScene, aPlayerName)
  PK_CheckUseQingGong(fX, fY)
  
  local function _cb(aInfo)
    if m_param.follow_allmap then
      if IsDiFuScene(aInfo.sceneID) or IsSafeSceneID(aInfo.sceneID) and not IsSafeSceneID() then
        DebugColorMsg("跟随玩家：在安全地图暂不跟随", 3)
        return false
      end
    elseif aInfo.sceneID ~= GetSceneID() then
      DebugColorMsg("跟随玩家：不在同一个地图暂不跟随", 3)
      return false
    end
    return true
  end
  
  return MoveCallBack_GoToPlayer(fX, fY, nScene, aPlayerName, _cb)
end

function PK_ToPlayer(aPlayerName)
  GoToPlayer(PK_cb_ToPlayer, MoveCallBack_state_2, aPlayerName)
  Dismount()
end

function PK_CheckPos()
  local checkFollowPlayer = true
  local followNear, followScene
  if m_param.follow_leader then
    local bIsLeader = false
    followScene, bIsLeader = GetTRLeaderInfo()
    if bIsLeader then
      followScene = nil
    end
    if followScene then
      local tPlayer = FindObjByGUID(followScene.guid)
      if tPlayer and tPlayer.hp > 0 then
        followNear = tPlayer
      end
    end
  end
  if nil == followNear and followScene then
    if m_param.follow_allmap then
      if IsDiFuScene(followScene.sceneID) or IsSafeSceneID(followScene.sceneID) and not IsSafeSceneID(GetSceneID()) then
        DebugColorMsg("队团长在城内暂不跟随", 3)
      else
        PK_ToLeader()
        return true
      end
    elseif followScene.sceneID == GetSceneID() then
      PK_ToLeader()
      return true
    end
  end
  if nil == followNear and m_param.follow_player and checkFollowPlayer then
    local tFollowName = Text2Table(m_param.follow_name, " ")
    local tObj = Enum2XByClass("玩家", {0, -1})
    for i = 1, #tFollowName do
      if "" ~= tFollowName[i] and tFollowName[i] ~= g_self.name then
        local tFind = ObjFilterByName(tObj, tFollowName[i], 0)
        if #tFind > 0 then
          followNear = tFind[i]
          break
        end
      end
    end
  end
  if nil == followNear and m_param.follow_player then
    local tAllMember = {}
    if Player:IsInRaid() then
      tAllMember = Raid:GetAllMemberInfo()
    elseif Player:IsInTeam() then
      tAllMember = Team:GetAllMemberInfo()
    end
    local tFollowName = Text2Table(m_param.follow_name, " ")
    for i = 1, #tFollowName do
      if "" ~= tFollowName[i] and tFollowName[i] ~= g_self.name then
        local tFind = ObjFilterByName(tAllMember, tFollowName[i], 0)
        if #tFind > 0 then
          PK_ToPlayer(tFind[1].name)
          return true
        end
      end
    end
  end
  if followNear and followNear.dst > m_param.follow_dist then
    RunTo(followNear.x, followNear.y, 0, 600)
    PlayerStateTimeOut(2, 3)
    PK_CheckUseQingGong(followNear.x, followNear.y)
  end
  return true
end

function _SMain(...)
  LoadScript("pkfun")
  if 4 ~= g_self.menpai then
    PushDebugMessage("此功能仅峨眉派可以使用!")
    return
  end
  CDG.defaultCity = 1
  CDG.dxys = m_param.auto_dxys
  while true do
    local nState = Player:GetState()
    if 9 == nState then
      PK_CheckSetDingWei()
      if m_param.dieout then
        GetLuaValue("meReliveHandle(-1)")
      else
        GetLuaValue("meReliveHandle(0)")
        DebugStr("角色死亡,等待救起")
      end
    elseif not Player:IsFollow() then
      if m_param.chuansong_qun and not Player:IsLeader() and IsWindowVisible("Item_TuDunZhu", "Item_TuDunZhu_OK_Clicked()") then
        Sleep(700)
      end
      if IsSafeSceneID() then
        local nSceneID = GetSceneID()
        if IsDiFuScene(nSceneID) then
          CDG:checkDiFu()
          Sleep(500)
          FubenAttack(-1)
          FubenAttack(-1)
          FubenAttack(-1)
          PK_UseChuanSong()
        else
          FubenAttack(-1)
          PK_CheckPos()
        end
      elseif m_param.chuansong_protect and -1 ~= Player:GetBuff("传送保护：无敌") then
        DebugColorMsg("传送保护中.")
      else
        if m_param.auto_wudi and -1 ~= Player:GetBuff("虚弱：所受伤害放大") then
          PushColorMsg("角色被放大自动使用 呆若木鸡")
          WuDiSkill()
        end
        if m_param.auto_ylxs then
          local tAttack = EnumAttackObj("玩家", {0, -1}, 0)
          if #tAttack > 0 and tAttack[1].dst < 4 then
            Skill:UseSkillByName("月落西山", -1, -1, -1, 500)
          end
        end
        CDG:checkDXYS()
        if 2 == nState and m_param.run_pause then
          DebugStr("角色移动中,您已设置暂停加血")
        else
          local add_hp_name = CDG:checkHP_Player()
          if "" == add_hp_name then
            CDG:checkHP(false)
          end
          CDG:checkMP(true)
          CDG:checkHP_Pet(false)
        end
        PK_CheckPos()
      end
    else
      DebugStr("组队跟随中")
    end
    PK_CheckSetDingWei()
    Sleep(300)
  end
end

_SMain()
m_param = nil
