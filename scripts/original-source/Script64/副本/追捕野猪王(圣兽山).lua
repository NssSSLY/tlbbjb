-- 反编译自 dfz64.dll 内嵌字节码 0031c749（unluac 2025-12-23；仅供分析）
local m_script_name = "追捕野猪王"
ScriptOnStart(m_script_name, true, false)
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
g_config.zbyzw = {}
g_config.zbyzw.overtime = false
local m_param = {}
m_param.sceneID_sss = 201
m_param.sceneID_fb = 231

function _SMain(...)
  LeaveSpecialScene({
    m_param.sceneID_fb
  }, nil)
  local lastFindTime = GetTickCount()
  if IsKVKSceneName() then
    Player:TeamFollow(false, 300)
  end
  local bChange = false
  while true do
    if GetSceneID() == m_param.sceneID_fb then
      CDG.sceneID = m_param.sceneID_fb
      if g_self.isjingong then
        CDG.attackMode = "打死换怪"
      else
        CDG.attackMode = "优先绿怪"
      end
      CDG.pickup = false
      CDG.overMapErr = true
      CDG.die.out = true
      if g_self.isjingong then
        CDG.posRadius = 15
      else
        CDG.posRadius = 5
      end
      CDG.tragetSelect = true
      CDG.die.maxCount = 0
      CDG.savebank = false
      CDG.pos = {
        {x = 60, y = 81},
        {x = 78, y = 94},
        {x = 94, y = 88},
        {x = 87, y = 75},
        {x = 87, y = 64},
        {x = 92, y = 39},
        {x = 81, y = 30},
        {x = 74, y = 41},
        {x = 58, y = 37},
        {x = 33, y = 37},
        {x = 38, y = 50},
        {x = 45, y = 52},
        {x = 60, y = 50}
      }
      CDG.posIdx = GetNearestPoint(CDG.pos)
      CDG:SetTimeOut(100)
      
      local function CDG_loop_callback()
        DebugStr(m_script_name .. ":执行中", 2)
        if GetSceneID() ~= m_param.sceneID_fb then
          return true
        end
        Player:TeamFollow(false, 300)
        local tObj = Enum2XByName("尖牙野猪王", {
          0,
          1,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 and 0 == tObj[1].hp then
          Sleep(3000)
          local tGuaiWu = Enum2XByClass("怪物", {0, -1})
          if #tGuaiWu > 0 then
            PushDebugMessage("发现怪物:" .. tGuaiWu[1].name)
          else
            PushDebugMessage(m_script_name .. ":boss已被杀死")
            return true
          end
        end
        return false
      end
      
      local function sf_move_cb_in_fb(fX, fY, nScene)
        if GetSceneID() ~= m_param.sceneID_fb then
          return false
        end
        Player:TeamFollow(false, 300)
        local nTransTime = GetSceneTransTime()
        local nMsgTime1 = IsInDebugMsg("30/30")
        if #CDG.pos > 2 and nMsgTime1 and nTransTime < nMsgTime1 then
          PushDebugMessage(m_script_name .. ":前往尖牙野猪王")
          CDG.pos = {
            {x = 72, y = 50}
          }
          CDG.posIdx = 1
          return false
        end
        return true
      end
      
      CDG.callfun = CDG_loop_callback
      CDG.callfun_move = sf_move_cb_in_fb
      CDG:OnStart()
      
      local function _move_cb(fX, fY, nScene)
        if GetSceneID() ~= m_param.sceneID_fb then
          return false
        end
        PickUpLua(nil, true)
        return true
      end
      
      local pickPos
      local tObj = Enum2XByName("尖牙野猪王", {
        0,
        1,
        0,
        0
      }, nil, nil, 0)
      if #tObj > 0 then
        pickPos = {
          {
            x = tObj[1].x,
            y = tObj[1].y
          }
        }
      end
      local petName = " 成年血牙暴龙 成年钢牙暴龙 成年利牙暴龙 成年尖牙暴龙 血牙暴龙宝宝 钢牙暴龙宝宝 利牙暴龙宝宝 尖牙暴龙宝宝 "
      local tPet = Enum2XByName(petName, {
        1,
        0,
        0,
        0
      }, nil, 1, 3)
      PickUpLua_Boss(15, 15, m_param.sceneID_fb, pickPos)
      if #tPet > 0 then
        RunTo(tPet[1].x, tPet[1].y, 0, 3000)
        PlayerStateTimeOut(2, 10)
      else
        tPet = Enum2XByName(petName, {
          1,
          0,
          0,
          0
        }, nil, 1, 3)
        if #tPet > 0 then
          RunTo(tPet[1].x, tPet[1].y, 0, 3000)
          PlayerStateTimeOut(2, 10)
        end
      end
      while #tPet > 0 do
        local info = {
          petName = tPet[1].name
        }
        local filter = {}
        OnCatch(info, filter, _move_cb)
        Sleep(1000)
        DebugStr("捕捉霸王龙")
        tPet = Enum2XByName(petName, {
          1,
          0,
          0,
          0
        }, nil, 1, 3)
      end
      while GetSceneID() == m_param.sceneID_fb do
        MoveTo(27, 107, m_param.sceneID_fb, nil, nil, nil, _move_cb)
        Sleep(1000)
        MoveConfirm()
        Sleep(600)
        DebugStr(m_script_name .. ":离开副本.")
      end
      lastFindTime = GetTickCount()
    else
      if g_config.zbyzw.overtime and GetTickCount() - lastFindTime > 600000 then
        PushColorMsg(m_script_name .. ":已经10分钟没有进入副本")
        break
      end
      if Player:IsLeader() then
        local tItem = Bag:FindItemInfo("野猪王的踪迹", nil, nil, Bag:EnumRenWuItem())
        if 0 == #tItem then
          Sleep(3000)
          tItem = Bag:FindItemInfo("野猪王的踪迹", nil, nil, Bag:EnumRenWuItem())
          if 0 == #tItem and GetSceneID() ~= m_param.sceneID_fb then
            PushColorMsg(m_script_name .. ":队长已没有野猪王的踪迹")
            local nCount = Team:GetMemberCount()
            if nCount > 1 then
              GetLuaValue(fmt("Player:AppointLeader(%d)", nCount - 1))
            end
            if bChange then
              break
            end
            bChange = true
          end
        end
      end
      GoToSceneNPC("云飘飘", 136, 109, m_param.sceneID_sss)
      Sleep(500)
      QuestFrameOptionClicked_Item("追捕野猪王", 1, 1000)
    end
    Sleep(300)
    DebugStr(m_script_name)
  end
  if GetSceneID() == 201 then
    GoToScene(282, 64, 112)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_param = nil
