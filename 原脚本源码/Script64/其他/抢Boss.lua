-- 反编译自 dfz64.dll 内嵌字节码 002ae368（unluac 2025-12-23；仅供分析）
local m_script_name = "抢Boss"
ScriptOnStart(m_script_name, true, false, false)
g_config.qboss = {}
g_config.qboss.allname = ReadConfigText("ZH", "bjk92")
g_config.qboss.dingwei_set = ReadConfigBool("ZH", "xzk130")
g_config.qboss.dingwei_use = ReadConfigBool("ZH", "xzk46")
g_config.qboss.checkmp = ReadConfigBool("ZH", "xzk51")
g_config.qboss.autoskill = ReadConfigBool("ZH", "xzk57")
g_config.qboss.hook = ReadConfigBool("ZH", "xzk129")
g_config.qboss.follow = ReadConfigBool("ZH", "xzk59")
g_config.qboss.follow_dist = ReadConfigInt("ZH", "bjk4")
CDG:InitFubenParam()
CDG.attack = true
CDG.skill_state = g_config.skill.fuben_zhuangtai
CDG.skill_attack = g_config.skill.pk_gongji
g_pick.pickmode = 0
local m_param = {}
m_param.dingwei_use = g_config.qboss.dingwei_use
m_param.dingwei_set = g_config.qboss.dingwei_set
m_param.hook = g_config.qboss.hook
m_param.check_mp = g_config.qboss.checkmp
m_param.autoskill = g_config.qboss.autoskill
m_param.follow = g_config.qboss.follow
m_param.follow_dist = HandleTextToNumber(g_config.qboss.follow_dist, 8)
m_param.allname = HandleText(g_config.qboss.allname)
m_param.allname = HandleText_AddFuHao(m_param.allname, " ", true)
local m_dingwei = {
  x = -1,
  y = -1,
  sceneID = -1
}

function CheckSetDingWei()
  if m_param.dingwei_set and not IsSafeSceneID() then
    local nSceneID = GetSceneID()
    local selfPos = Player:GetPos()
    if nSceneID > 0 and (m_dingwei.sceneID ~= nSceneID or GetDist(m_dingwei.x, m_dingwei.y, selfPos.x, selfPos.y) > 10) and SetDingWeiZhu(1) then
      m_dingwei.sceneID = nSceneID
      m_dingwei.x = selfPos.x
      m_dingwei.y = selfPos.y
    end
  end
end

function QB_Action()
  local findType = -1
  local tObj = Enum2XByClass("怪物", {0, 20}, 1)
  tObj = ObjFilterByName(tObj, m_param.allname, 3)
  local tTemp = ObjFilterByName(tObj, " 出洞蛟 翻江蜃 阮小五 阮小七 林家将 ", 3)
  if #tTemp > 0 then
    tObj = tTemp
  end
  local tAttack = ObjFilterByColor(tObj, "绿")
  if #tAttack > 0 then
    findType = 1
  else
    tAttack = ObjFilterByColor(tObj, "红")
    if #tAttack > 0 then
      findType = 2
    end
  end
  tAttack = ObjFilterByDst(tAttack, 20, 2)
  if 0 == #tAttack then
    findType = -1
  end
  if #tAttack > 0 then
    Dismount()
    BubbleByHP(tAttack)
    local tmp = tAttack[1]
    if m_param.autoskill then
      CDG:SkillJinJi(tmp.id)
    else
      CDG:SkillAttack(tmp.id)
    end
    Target:Attack(tmp.id, 200, true)
  end
  return findType
end

function _SMain(...)
  if m_param.allname == "" then
    PushColorMsg("您没有输入Boss名称")
    return
  end
  if m_param.hook then
    DoSystem(1001, g_self.isjingong, Skill.baseID, 100, 65000, 1)
    DoSystem(1002, 1)
    RecvState(16)
  end
  while true do
    local nState = Player:GetState()
    if 9 == nState then
      if m_param.dingwei_use then
        DieOutAndGetPos()
      else
        DebugStr("您未设置使用土灵珠回点,暂不出窍")
      end
    else
      local nSceneID = GetSceneID()
      if IsDiFuScene(nSceneID) then
        CDG:checkDiFu()
        Sleep(1000)
        if m_param.dingwei_use and -1 ~= m_dingwei.sceneID and Bag_UseTuLingZhu(m_dingwei.sceneID, m_dingwei) == false then
          Bag_UseDingWeiCDFL(GetSceneNameByID(m_dingwei.sceneID))
        end
      else
        if IsWindowVisible("Item_TuDunZhu", "Item_TuDunZhu_OK_Clicked()") then
          Sleep(700)
        end
        local findType = QB_Action()
        local tObj = Enum2XByClass("怪物", {-1, 15})
        tObj = ObjFilterByName(tObj, m_param.allname, 3)
        tObj = ObjFilterByColor(tObj, "红绿")
        tObj = ObjFilterByHP(tObj, 0, 0)
        if #tObj > 0 then
          DebugStr("抢Boss：有boss已经死亡,检查捡包", 2)
          PickUpLua()
        end
        if 1 ~= findType then
          PickUpLua()
        end
        if 1 ~= findType or 4 == g_self.menpai then
          local add_hp_name = CDG:checkHP_Player()
          if "" == add_hp_name then
            CDG:checkHP(false)
          end
        end
        CDG:checkHP_Pet(false)
        if m_param.check_mp then
          CDG:checkMP()
        end
        if -1 == findType then
          CDG:checkMP()
          CDG:checkfree()
          if Player:IsInTeam() and not Player:IsLeader() then
            local function _cb(aX, aY, aSceneID)
              local tObj = Enum2XByClass("怪物", {0, -1}, 1)
              
              tObj = ObjFilterByName(tObj, m_param.allname, 3)
              local tAttack = ObjFilterByColor(tObj, "红绿")
              if #tAttack > 0 then
                local tmp = tAttack[1]
                PushColorMsg("抢Boss:发现" .. tmp.name)
                return false, nil
              end
              return MoveCallBack_GoToLeader(aX, aY, aSceneID)
            end
            
            if m_param.follow then
              GoToLeader(_cb, MoveCallBack_state_2, true, true, m_param.follow_dist)
            end
          end
        end
      end
    end
    Sleep(50)
    CheckSetDingWei()
  end
  DoSystem(1004)
end

_SMain()
