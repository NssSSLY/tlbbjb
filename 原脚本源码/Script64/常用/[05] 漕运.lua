-- 反编译自 dfz64.dll 内嵌字节码 00364c48（unluac 2025-12-23；仅供分析）
local m_script_name = "漕运 洛阳-大理"
ScriptOnStart(m_script_name, true, false)
g_config.caoyun = {}
g_config.caoyun.daya = GetConfigBool("漕运", "打压")
g_config.caoyun.hongtai = GetConfigBool("漕运", "哄抬")
g_config.caoyun.abnegate = false
g_config.caoyun.once = GetConfigBool("漕运", "跑一次")
g_config.caoyun.unattack = GetConfigBool("漕运", "不打怪")
local m_param = {}
m_param.unattack = g_config.caoyun.unattack
CDG.tragetSelect = true
local m_npc = {
  {
    name = "赵明诚",
    x = 326,
    y = 318,
    sceneID = LUOYANG_ID
  },
  {
    name = "陆士铮",
    x = 331,
    y = 169,
    sceneID = 1
  },
  {
    name = "王若禹",
    x = 55,
    y = 176,
    sceneID = 2
  }
}
local SALT_BUY_VALUE = 1
local IRON_BUY_VALUE = 2
local RICE_BUY_VALUE = 3
local SALT_SELL_VALUE = 10
local IRON_SELL_VALUE = 20
local RICE_SELL_VALUE = 30
local g_salt = false
local g_iron = false
local g_rice = false
local g_bLuoyang = true

local function CY_Attack()
  local dist = 15
  if g_self.isjingong then
    dist = 5
  end
  local tObj = Enum2XByClass("怪物", {0, dist})
  local selfTID = Player:GetTID()
  local tAttack = GetTableFieldValue(tObj, "target", {selfTID})
  BubbleByDst(tAttack)
  local bGuid2 = CDG.pet2.GUID
  local bGuid3 = CDG.pet3.GUID
  CDG.pet2.GUID = 0
  CDG.pet3.GUID = 0
  if #tAttack > 0 then
    FubenAttack(tAttack[1].id, nil, nil, true, false)
  else
    FubenAttack(-1, nil, nil, true, false)
  end
  CDG.pet2.GUID = bGuid2
  CDG.pet3.GUID = bGuid3
end

local function CY_cb_speed(fX, fY, nScene)
  if 2 == Player:GetState() then
    Sleep(500)
  end
  if Skill:UseSpeed() then
  end
  return true
end

local function CY_cb_LuoYang(fX, fY, nSceneID)
  if GetSceneID() ~= LUOYANG_ID then
    return false
  end
  return CY_cb_speed(fX, fY, nSceneID)
end

local function CY_cb_DaLi(fX, fY, nSceneID)
  if 2 ~= GetSceneID() then
    return false
  end
  return CY_cb_speed(fX, fY, nSceneID)
end

local function CY_cb_JianGe(fX, fY, nSceneID)
  if 7 ~= GetSceneID() then
    return false
  end
  return CY_cb_speed(fX, fY, nSceneID)
end

local function CY_cb_DunHuang(fX, fY, nSceneID)
  if 8 ~= GetSceneID() then
    return false
  end
  return CY_cb_speed(fX, fY, nSceneID)
end

local function CY_HaveWrit()
  local nCount = Bag:GetItemCount("漕运货舱", nil, nil, Bag:EnumRenWuItem())
  if nCount > 0 then
    return true
  end
  return false
end

local function CY_GetWrit()
  local npc = m_npc[1]
  if 2 == GetSceneID() then
    npc = m_npc[3]
  end
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
  QuestFrameOptionClicked_Item("开始漕运", 1, 800)
  if IsWindowVisible("Carriage", "Get_Writ()") then
    Sleep(1000)
  else
    PushColorMsg("漕运:领取货舱失败")
  end
  local szText = GetNPCEventList_Item(0)
  if string.find(szText, "20次上限", nil, true) then
    return false
  end
  return true
end

local function CY_RefreshFreight(aMissionIndex)
  local Cargo = GetMissionVariable(aMissionIndex, 2)
  local Cargo_Standard = 100
  if Cargo < Cargo_Standard then
    g_salt = false
  else
    g_salt = true
  end
  Cargo_Standard = 10
  if Cargo_Standard > Cargo % 100 then
    g_iron = false
  else
    g_iron = true
  end
  Cargo_Standard = 1
  if Cargo_Standard > Cargo % 10 then
    g_rice = false
  else
    g_rice = true
  end
end

local function CY_GetBuy1Money()
  return GetLuaValue("return Carriage_Env.Carriage_Money_Buy_1:GetProperty(\"MoneyNumber\")", "n")
end

local function CY_GetSell1Money()
  return GetLuaValue("return Carriage_Env.Carriage_Money_Sell_1:GetProperty(\"MoneyNumber\")", "n")
end

local function CY_DaYaTime()
  local str = GetLuaValue("return Carriage_Env.Carriage_Info3:GetText()", "s")
  if string.find(str, "现在即可", nil, true) then
    return 0
  end
  local _, _, min = string.find(str, "(%d+)")
  min = tonumber(min) or 1
  DebugStr("漕运打压:需等待" .. min .. "分钟", 3)
  return min
end

local function CY_HongTaiTime()
  local str = GetLuaValue("return Carriage_Env.Carriage_Info4:GetText()", "s")
  if string.find(str, "现在即可", nil, true) then
    return 0
  end
  local _, _, min = string.find(str, "(%d+)")
  min = tonumber(min) or 1
  DebugStr("漕运哄抬:需等待 " .. min .. " 分钟", 3)
  return min
end

local function CY_ConvertWrit()
  local npc = m_npc[1]
  if 2 == GetSceneID() then
    npc = m_npc[3]
  end
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, false)
  QuestFrameOptionClicked_Item("开始漕运", 1, 700)
  IsWindowVisible("Carriage", "Convert_Writ()")
  Sleep(1000)
  QuestFrameOptionClicked_Item("贪财贪财......", 1, 700)
  IsWindowVisible("Carriage", "this:Hide()")
end

local function CY_Carriage_Action_Clicked(aActionIndex)
  local npc = m_npc[1]
  if 2 == GetSceneID() then
    npc = m_npc[3]
  end
  GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, false)
  Sleep(500)
  QuestFrameOptionClicked_Item("开始漕运", 1, 800)
  local szText = GetNPCEventList_Item(0)
  if string.find(szText, "20次上限", nil, true) then
    CY_ConvertWrit()
    return
  end
  if not IsWindowVisible("Carriage") then
    return
  end
  local CD_Time_Sell = CY_HongTaiTime()
  local CD_Time_Buy = CY_DaYaTime()
  PushDebugMessage("打压时间：" .. CD_Time_Buy .. "分, 哄抬时间：" .. CD_Time_Sell .. "分")
  if aActionIndex < 10 then
    if CD_Time_Buy <= 0 then
      IsWindowVisible("Carriage", "Carriage_Button1_Clicked()")
      Sleep(1000)
      IsWindowVisible("Carriage", fmt("Carriage_Action_Clicked(%d)", aActionIndex))
    elseif g_config.caoyun.daya then
      DebugStr("漕运:等待时机打压市场", 2)
      Sleep(5000)
    else
      IsWindowVisible("Carriage", fmt("Carriage_Action_Clicked(%d)", aActionIndex))
    end
    Sleep(600)
    local szText = GetNPCEventList_Item(0)
    if string.find(szText, "20次上限", nil, true) then
      CY_ConvertWrit()
      return
    end
  elseif aActionIndex > 9 then
    if CD_Time_Sell <= 0 then
      IsWindowVisible("Carriage", "Carriage_Button2_Clicked()")
      Sleep(1000)
      IsWindowVisible("Carriage", fmt("Carriage_Action_Clicked(%d)", aActionIndex))
    elseif g_config.caoyun.hongtai then
      DebugStr("漕运:等待时机哄抬市价", 2)
      Sleep(5000)
    else
      IsWindowVisible("Carriage", fmt("Carriage_Action_Clicked(%d)", aActionIndex))
    end
  end
  Sleep(300)
  IsWindowVisible("Carriage", "this:Hide()")
end

local function CY_ActionCheck()
  if true == g_salt then
    CY_Carriage_Action_Clicked(SALT_SELL_VALUE)
    return
  end
  if true == g_iron then
    CY_Carriage_Action_Clicked(IRON_SELL_VALUE)
    return
  end
end

local function CY_OutLuoYang()
  MessageBox_Self_OK_Clicked(1000)
  if IsWindowVisible("AcceptBox", "AcceptBox_OK_Clicked();") then
    Sleep(1000)
  end
  MoveTo(85, 257, LUOYANG_ID, nil, false, nil, CY_cb_LuoYang)
end

local function CY_OutDaLi()
  MessageBox_Self_OK_Clicked(1000)
  if IsWindowVisible("AcceptBox", "AcceptBox_OK_Clicked();") then
    Sleep(1000)
  end
  MoveTo(33, 148, 2, nil, false, nil, CY_cb_DaLi)
end

local function CY_OutDunHuang()
  MessageBox_Self_OK_Clicked(1000)
  if IsWindowVisible("AcceptBox", "AcceptBox_OK_Clicked();") then
    Sleep(1000)
  end
  if g_salt then
    MoveTo(233, 280, 8, nil, false, nil, CY_cb_DunHuang)
    if -1 ~= Player:GetBuff("遇敌：无法传送") then
      CY_Attack()
    else
      MoveTo(231, 285, 8, 1, false, nil, CY_cb_DunHuang)
      Sleep(800)
    end
  else
    MoveTo(280, 146, 8, nil, false, nil, CY_cb_DunHuang)
    if -1 ~= Player:GetBuff("遇敌：无法传送") then
      CY_Attack()
    else
      MoveTo(286, 145, 8, 1, false, nil, CY_cb_DunHuang)
      Sleep(800)
    end
  end
end

local function CY_OutJianGe()
  MessageBox_Self_OK_Clicked(1000)
  if IsWindowVisible("AcceptBox", "AcceptBox_OK_Clicked();") then
    Sleep(1000)
  end
  if g_salt then
    MoveTo(38, 281, 7, nil, false, nil, CY_cb_JianGe)
    if -1 ~= Player:GetBuff("遇敌：无法传送") then
      CY_Attack()
    else
      MoveTo(35, 287, 7, 1, false, nil, CY_cb_JianGe)
      Sleep(800)
    end
  else
    MoveTo(106, 46, 7, nil, false, nil, CY_cb_JianGe)
    if -1 ~= Player:GetBuff("遇敌：无法传送") then
      CY_Attack()
    else
      MoveTo(106, 39, 7, 1, false, nil, CY_cb_JianGe)
      Sleep(800)
    end
  end
end

function _SMain(...)
  local arg = {
    ...
  }
  if g_config.caoyun.abnegate then
    PushColorMsg("漕运:您已设置放弃漕运")
    local nIndex, nIdScript = GetPlayerMission_ID(4021)
    if -1 ~= nIndex then
      QuestFrameMissionAbnegate(311010)
    end
    return
  end
  if Player:GetMoney() < 20000 and Player:GetMoney(2) < 20000 then
    Bank_GetMoney(20000)
    Sleep(1000)
    if Player:GetMoney() < 20000 and Player:GetMoney(2) < 20000 then
      PushColorMsg("漕运：金币不足！")
      return
    end
  end
  Pet:Relax(300)
  while true do
    if CY_HaveWrit() then
      local nIndex, nIdScript = GetPlayerMission_ID(4021)
      if -1 ~= nIndex then
        CY_RefreshFreight(nIndex)
        local nCurSceneID = GetSceneID()
        if nCurSceneID == LUOYANG_ID then
          if true == g_iron then
            CY_Carriage_Action_Clicked(IRON_SELL_VALUE)
            Sleep(1000)
            CY_RefreshFreight(nIndex)
            CY_ActionCheck()
            CY_ConvertWrit()
          elseif false == g_salt then
            CY_Carriage_Action_Clicked(SALT_BUY_VALUE)
          elseif true == g_salt then
            if true == g_bLuoyang then
              XiaoChangHuiXue(50, false)
            end
            CY_OutLuoYang()
          end
        elseif 2 == nCurSceneID then
          if true == g_salt then
            CY_Carriage_Action_Clicked(SALT_SELL_VALUE)
            Sleep(1000)
            CY_RefreshFreight(nIndex)
            CY_ActionCheck()
            CY_ConvertWrit()
          elseif false == g_iron then
            CY_Carriage_Action_Clicked(IRON_BUY_VALUE)
          elseif true == g_iron then
            CY_OutDaLi()
          end
        elseif 7 == nCurSceneID then
          CY_OutJianGe()
        elseif 8 == nCurSceneID then
          CY_OutDunHuang()
        elseif GetCurrentSceneName() == "地府" then
          CDG:checkDiFu()
        elseif GetCurrentSceneName() == "监狱" then
          CDG:checkJianYu()
        else
          DebugStr("漕运：当前地图错误 " .. nCurSceneID, 2)
          Sleep(5000)
        end
      else
        PushDebugMessage("漕运:已领取货舱,但获取任务信息失败！")
      end
    else
      if Player:GetMP() < 1000 then
        for i = 1, 3 do
          CDG:checkMP(true)
          Sleep(600)
        end
      end
      if g_config.caoyun.once then
        PushColorMsg("漕运:您已设置跑完本次停止")
        break
      end
      PushDebugMessage("漕运:领取货舱")
      if false == CY_GetWrit() then
        PushColorMsg("漕运：今日已完成")
        break
      end
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
  if GetSceneID() == LUOYANG_ID then
    XiaoChangHuiXue(90)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_npc = nil
