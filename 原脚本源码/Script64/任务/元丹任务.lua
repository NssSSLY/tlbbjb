-- 反编译自 dfz64.dll 内嵌字节码 00254c2b（unluac 2025-12-23；仅供分析）
local m_script_name = "元丹任务"
ScriptOnStart(m_script_name)

local function ZhuXianComplete(aParam)
  mission_complete_talk_npc(aParam)
end

local function ZhuXianAttack(aParam)
  aParam.attackMode = "打死换怪"
  mission_attack_mode_1(aParam)
end

local MissionTable = {
  function()
    local apt = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local comp = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local misName = "初识元丹晓全貌"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function(_param)
        while true do
          DebugStr("执行任务:" .. _param.name)
          local npc = _param.param_accept
          GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
          DialogOptionClicked("初识元丹晓全貌", 1, 1000)
          DialogOptionClicked("继续", 1, 1000)
          DialogOptionClicked("那该当如何？", 1, 1000)
          DialogOptionClicked("何为元丹？", 1, 1000)
          Sleep(200)
          local nIndex = GetPlayerMission(misName, 1)
          local nParam0 = GetMissionVariable(nIndex, 0)
          if -1 == nIndex or 1 == nParam0 then
            CloseAllWindow()
            break
          end
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local comp = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local misName = "丹入三脉强体魄"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function(_param)
        Bag:UseItemByName_click("和光·精", 1000)
        Pet:Relax(1000)
        GetLuaValue("Pet:LuaFnOpenPetNeiDan('self')")
        Sleep(1000)
        GetLuaValue("                    local g_MaxNeiDanBarNum = DataPool:LuaFnGetPetNeiDanChipMaxCount()\n                    for i = 1, g_MaxNeiDanBarNum do\n                        local theNeiDanAction = DataPool:LuaFnEnumPlayerNeiDanAction(i - 1)\n                        if theNeiDanAction:GetID() ~= 0 and theNeiDanAction:GetName() == \"和光·精\" then\n                            setmetatable(_G, {__index = PetNeidan_Env});\n                            local ctrlAction = PetNeidan_List2_LaceItem1__auto_0__:GetSubItem(\"PetNeidan_List2_LaceItem1_Icon\")\n                            if ctrlAction ~= nil then\n                                ctrlAction:SetActionItem(theNeiDanAction:GetID())\n                                ctrlAction:DoAction()\n                            end\n                        end\n                    end\n                ")
        Sleep(1000)
        CloseAllWindow()
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local comp = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local misName = "元丹坊中觅奇珍"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function(_param)
        GoToSceneNPC(apt.name, apt.x, apt.y, apt.sceneID)
        Sleep(1000)
        DialogOptionClicked("元丹坊", 1, 1000)
        GetLuaValue([[
                    Clear_XSCRIPT()
                        Set_XSCRIPT_Function_Name("OnClientBuyItem")
                        Set_XSCRIPT_ScriptID( 505111 )
                        Set_XSCRIPT_Parameter(0, 1)
                        Set_XSCRIPT_Parameter(1, 1)
                        Set_XSCRIPT_Parameter(2, dm_g_PetNeidan_Shop_CurWeek)
                        Set_XSCRIPT_Parameter(3, dm_g_PetNeidan_Shop_ServerObj)
                        Set_XSCRIPT_ParamCount(4)
                    Send_XSCRIPT()
                ]])
        Sleep(1000)
        CloseAllWindow()
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local comp = {
      x = 177,
      y = 230,
      sceneID = 1,
      name = "云丹丹"
    }
    local misName = "按图索骥奇遇现"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {},
      OnAction = function(_param)
        Bag:UseItemByName_click("精品灵元图", 1000)
        local strMsg = GetNPCEventList_Item(0)
        local _, _, xPos, yPos, nScene = string.find(strMsg, "#{ZSCB_230426_04.-(%d+).-(%d+).-(%d+)}")
        xPos = tonumber(xPos)
        yPos = tonumber(yPos)
        nScene = tonumber(nScene)
        if xPos and yPos and nScene then
          _param.param_action = {
            pos = {
              {x = xPos, y = yPos}
            },
            use_horse = true,
            is_pick = true,
            sceneName = GetSceneNameByID(nScene),
            targetName = "夺丹恶徒",
            call_back_attack = function()
              DebugStr("按图索骥奇遇现:正在执行中", 2)
              local nComplete, nIndex = GetMissionVariableByName_Item("#{NDYD_230506_113}", 0)
              PushColorMsg(nComplete .. nIndex)
              if -1 == nIndex then
                return true
              end
              if 0 == nComplete then
                GoToScene(xPos, yPos, nScene)
                Dismount()
                Bag:UseItemByName("精品灵元图", 1000)
              else
                Sleep(2000)
                PickUpLua()
                local tObj1_1 = Enum2XByName("丹无量", {
                  1,
                  0,
                  0,
                  0
                }, {0, -1}, 1, 0)
                local tObj1 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_19}", {
                  1,
                  0,
                  0,
                  0
                }, {0, -1}, 1, 0)
                local tObj2 = Enum2XByName("精品元丹宝箱", {
                  1,
                  0,
                  0,
                  0
                })
                local tObj3 = Enum2XByTitle(g_self.name .. "#{ZSCB_230426_18}", {
                  0,
                  1,
                  0,
                  0
                }, {0, -1}, 1, 0)
                if #tObj1 > 0 or #tObj1_1 > 0 then
                  if #tObj1 > 0 then
                    OpenTalk(tObj1[1].id, 1000)
                  elseif #tObj1_1 > 0 then
                    OpenTalk(tObj1_1[1].id, 1000)
                  end
                  DialogOptionClicked("#{ZSCB_230426_21}", 1, 1000)
                elseif #tObj2 > 0 then
                  Skill.CUseSkillByID(4948, tObj2[1].id, -1, -1)
                  Sleep(1000)
                elseif #tObj3 > 0 then
                else
                  return true
                end
              end
              return false
            end
          }
          ZhuXianAttack(_param)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end
}

local function ZhuXianCommitMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if 1 == nComplete then
      DebugStr("交任务 " .. mis.name, 2)
      mis.is_complete = true
      mis.OnComplete(mis)
      bDoAction = true
      break
    end
  end
  return bDoAction
end

local function ZhuXianDoMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    local nComplete = GetMissionVariable(nIndex, 0)
    if -1 ~= nIndex then
      if 0 == nComplete then
        if mis.commit then
          PushColorMsg("切换地图,提交已完成任务！")
          if ZhuXianCommitMission() then
            return true
          end
        end
        DebugStr("执行任务 " .. mis.name, 2)
        if mis.OnAction then
          mis.OnAction(mis)
        elseif mis.OnComplete then
          mis.OnComplete(mis)
        end
        bDoAction = true
        break
      elseif 2 == nComplete then
        PushColorMsg("放弃任务：" .. misName)
        QuestFrameMissionAbnegate(idScript)
      end
    end
  end
  return bDoAction
end

local function ZhuXianCanAccept(aMisName)
  return true
end

local function ZhuXianAcceptCheckScene(aMisTable, aAcceptSceneID, aAcceptIndex)
  local mis_table = aMisTable
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    local misName = mission_get_name(mis)
    local nIndex, idMission, idScript = GetPlayerMission(misName)
    if -1 ~= nIndex and GetSceneID() ~= aAcceptSceneID and mis.param_accept.sceneID ~= aAcceptSceneID then
      return false
    end
  end
  return true
end

local function ZhuXianAcceptMission(aMisTable)
  local mis_table = aMisTable or MissionTable
  local bDoAction = false
  CollectMissionOutline()
  Sleep(500)
  local lastScene = -1
  local nLevel = Player:GetDataInt("LEVEL")
  for i = 1, #mis_table do
    local mis = mis_table[i]()
    if (mis.is_complete == nil or mis.is_complete == false) and IsMissionOutline(mis.name) and ZhuXianCanAccept(mis.name) and (-1 == lastScene or lastScene == mis.param_accept.sceneID) and mis.param_accept and mis.param_accept.sceneID and ZhuXianAcceptCheckScene(mis_table, mis.param_accept.sceneID, i) then
      lastScene = mis.param_accept.sceneID
      DebugStr("接任务 " .. mis.name, 2)
      bDoAction = true
      mis.OnAccept(mis)
      if i > 63 then
        break
      end
    end
  end
  return bDoAction
end

function _SMain()
  LoadScript("mission")
  LoadScript("fn元丹坊")
  local nOverCount = 0
  while true do
    local debugnote = ""
    if false == ZhuXianDoMission() then
      if false == ZhuXianCommitMission() then
        if false == ZhuXianAcceptMission() then
          PushColorMsg("无任务可接")
          break
        end
      elseif false == ZhuXianCommitMission() then
        ZhuXianAcceptMission()
      end
    end
    Sleep(100)
    DebugStr(m_script_name .. " " .. debugnote, 1)
  end
end

_SMain()
ScriptOnStop(m_script_name)
