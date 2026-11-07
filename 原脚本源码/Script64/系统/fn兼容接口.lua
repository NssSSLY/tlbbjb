-- 反编译自 dfz64.dll 内嵌字节码 004da0d3（unluac 2025-12-23；仅供分析）
function Player:IsConfraternityPK()
  return IsBangHuiPK()
end

function Player:GetCurrentTID()
  return Player:GetTID()
end

function Player_GetPos()
  local pos = Player:GetPos()
  pos.x = math.floor(pos.x + 0.5)
  pos.y = math.floor(pos.y + 0.5)
  return pos.x, pos.y
end

function GetActiveSceneName()
  return GetCurrentSceneName()
end

function GetPlayerInfo(aType, aParam)
  if "FPGUID" == aType then
    return Player:GetFightPetGUID()
  elseif "FPTID" == aType then
    return Pet:GetTID()
  elseif "NAME" == aType then
    return Player:GetName()
  elseif "LEVEL" == aType then
    return Player:GetDataInt("LEVEL")
  elseif "GUID" == aType then
    return Player:GetGUID()
  elseif "TID" == aType then
    return Player:GetTID()
  elseif "OtherName" == aType then
    return GetLocalPlayerName()
  elseif "SeverTime" == aType then
    return os.time()
  else
    PushColorMsg(aType .. " player info")
  end
end

function GetChangeMapState()
  return DoSystem_old(7780)
end

function ShowMessage(aMsg)
  DoSystem_old(7778, 1, aMsg)
  Sleep(50)
end

function DebugMessage(aMsg, ...)
  PushMessage(aMsg, 1, ...)
end

function Player_TeamFollow(aFollow)
  Player:TeamFollow(aFollow)
end

function LuaDoString(aMeta, aStr)
  local strText = [[
        setmetatable(_G, {__index = %s_Env});%s;
    ]]
  strText = fmt(strText, aMeta, aStr)
  GetLuaValue(strText)
end

function PickUp()
  PickUpLua()
end

function TalkNpcEx(aType, aID, aScriptID, aOption1, aOption2)
  if 0 == aType then
    SP_OpenTalk(aID)
  elseif 1 == aType then
    SP_OpenTalkAndClickedOption(aID, aScriptID, aOption1)
  elseif 2 == aType then
    SP_OpenTalkAndClickedClickedOption(aID, aScriptID, aOption1, aOption2)
  end
end

function UseSkill(aSkillName, aID)
  if -10 == aID then
    local skill = Skill:GetSkillByName(aSkillName)
    return Skill:CanUseSkill(skill)
  elseif -11 == aID then
  else
    return Skill:UseSkillByName(aSkillName, aID, 200)
  end
  return true
end

function UsePetSkill(aSkillName)
  Skill:UsePetSkill(aSkillName)
end

function UsePetSkill2(aSkillName)
  Skill:UsePetSkill(aSkillName)
end

function UseItem(aUseType, aItemName)
  Bag:UseItemByName_click(aItemName, 200)
end

function DelBagItem(aWhere)
  if g_config == nil or nil == g_config.item then
    GlobalParamInit()
  end
  Bag_DeleteItem()
  Bag_DeleteTempBagItem()
end

function AI_Start(aTid)
  Target:Attack(aTid, 300)
end

function DG_OnInit()
  ScriptOnStart("自定义打怪", false, false, false)
end

function DG_SetParam(aParamName, aPar1, aPar2, aPar3)
  if "打怪方式" == aParamName then
  elseif "攻击模式" == aParamName then
    CDG.attackMode = aPar1
  elseif "目标" == aParamName then
    if "所有" == aPar1 then
      CDG.targetName = ""
    elseif "添加" == aPar1 then
      CDG.targetName = aPar2
    end
  elseif "目标类型" == aParamName then
    CDG.targetType = aPar1
  elseif "是否选中怪" == aParamName then
    CDG.tragetSelect = aPar1
  elseif "怪物归属" == aParamName then
    CDG.targetOwer = aPar1
  elseif "打怪范围" == aParamName then
    CDG.posRadius = aPar1
  elseif "坐标" == aParamName then
    if "赋值" == aPar1 then
      CDG.pos = aPar2
    elseif "添加" == aPar1 then
      table.insert(CDG.pos, {x = aPar2, y = aPar3})
    end
  elseif "地图" == aParamName then
    CDG.sceneID = aPar1
    CDG.sceneName = GetSceneNameByID(CDG.sceneID)
  elseif "是否攻击" == aParamName then
    CDG.attack = aPar1
  elseif "其他参数" == aParamName then
    if aPar1.usehorse ~= nil then
      CDG.horse = aPar1.usehorse
    end
    if nil ~= aPar1.dxys then
      CDG.dxys = aPar1.dxys
    end
    if nil ~= aPar1.usepet then
    end
  end
end

function DG_OnAction()
  CDG:OnStart()
end

function ShangH_BuyItem(aBuyName, aBuyNum, aMaxMoney, aNameCmpMode)
  if 0 == aNameCmpMode then
    aNameCmpMode = 1
  elseif 1 == aNameCmpMode then
    aNameCmpMode = 3
  end
  ShangHui_BuyItem(aBuyName, aBuyNum, aMaxMoney, aNameCmpMode)
end

function GetMenpaiName(aMenpaiID)
  return GetMenpaiNameByID(aMenpaiID)
end

function GetMoney(aType)
  return Player:GetMoney(aType)
end

function GetHPPercent()
  return Player:GetHPP()
end

function GetMPPercent()
  return Player:GetMPP()
end

function GetCurrentHP()
  return Player:GetHP()
end

function GetCurrentMP()
  return Player:GetMP()
end

function Player_GetPK()
  return Player:GetPKValue()
end

function GiveTeamState(aSkillName)
end

function LuoYangRestore(aHpCmp)
  XiaoChangHuiXue(aHpCmp)
end

function CityToGuild()
  GoToGuild()
end

function GuildToCity()
  PushColorMsg("帮会返回城市")
end

function IsLeader()
  if Player:IsLeader() then
    return 1
  end
  return 0
end

function IsFollow()
  if Player:IsFollow() then
    return 1
  end
  return 0
end

function Player_GetMountID()
  if IsMount() then
    return 1
  end
  return -1
end

function Player_GetBuff(aBuffName)
  return Player:GetBuff(aBuffName)
end

function Player_DispelBuffByName(aBuffName)
  Player:DispelBuffByName(aBuffName)
end

function FindBagItem(aTabIndex, aItemName)
  local tItem = {}
  if 0 == aTabIndex then
    tItem = Bag:FindItemInfo(aItemName, nil, nil, Bag:EnumDaoJuItem())
  elseif 2 == aTabIndex then
    tItem = Bag:FindItemInfo(aItemName, nil, nil, Bag:EnumRenWuItem())
  elseif -1 == aTabIndex then
    tItem = Bag:FindItemInfo(aItemName, nil, nil, nil)
  elseif -2 == aTabIndex then
    tItem = Bag:SearchItem(aItemName)
  end
  if -1 == aTabIndex or -2 == aTabIndex then
    if #tItem > 0 then
      local allCount = TableCount(tItem, "count")
      return true, allCount, tItem[1].index
    end
    return false, 0, -1
  end
  if #tItem > 0 then
    return tItem[1].index
  end
  return -1
end

function Bag:FindBagItem_1(aItemName)
  local tItem = Bag:FindItemInfo(aItemName, nil, nil, Bag:EnumDaoJuItem())
  if #tItem > 0 then
    return tItem[1].index
  end
  return -1
end

function Bag:FindBagItem_DJ(szItem, nBind)
  if nil == szItem or "" == szItem then
    return false
  end
  if nil == nBind then
    nBind = 0
  end
  local szText = fmt([[
        local szItem = "%s"
        local CurrBagNum = DataPool:GetBaseBag_Num()
        for i = 0, CurrBagNum - 1 do
            local theAction, bLocked, bProtect = PlayerPackage:EnumItem("base", i)
            if theAction:GetID() ~= 0 then
                if theAction:GetName() == szItem then
                    --#{ifbind}
                        return i
                    --#{endbind}
                end
            end
        end
        return -1
    ]], szItem)
  if 1 == nBind then
    szText = string.gsub(szText, "--#{ifbind}", "if GetItemBindStatus(i) == 0 then")
    szText = string.gsub(szText, "--#{endbind}", "end")
  elseif 2 == nBind then
    szText = string.gsub(szText, "--#{ifbind}", "if GetItemBindStatus(i) == 1 then")
    szText = string.gsub(szText, "--#{endbind}", "end")
  end
  local iFind = GetLuaValue(szText, "n")
  if iFind >= 0 then
    return true, iFind
  end
  return false, -1
end

function Bag:FindBagItem_3(szItemName)
  local tItem = Bag:EnumRenWuItem()
  for i = 1, #tItem do
    local tmp = tObj[i]
    if tmp.name == szItemName then
      return tmp.index
    end
  end
  return -1
end

function Bag:FindBagItem_All(aItemName)
  local tItem = Bag:FindItemInfo(aItemName, nil, nil, nil)
  if #tItem > 0 then
    local allCount = TableCount(tItem, "count")
    return true, allCount, tItem[1].index
  end
  return false, 0, -1
end

function Bag:UseBagItem_DJ(aAllItemName, aBind)
  local nIdx = Bag:LuaUseItem_DJ(aAllItemName, aBind)
  if nIdx >= 0 then
    return true, nIdx
  end
  return false, -1
end

function Bag:UseItem_2(aItemName)
  local tItem = Bag:FindItemInfo(aItemName, nil, nil, nil)
  if #tItem > 0 then
    local tmp = tItem[1]
    self:ItemBtnClicked(tmp.index)
    Sleep(300)
    PlayerStateTimeOut(5, 5)
    return tmp.index
  end
  return -1
end

function Bag:UseItem_3(aItemName)
  Bag:UseItemByName_click(aItemName, 300, Bag:EnumRenWuItem())
end

function Team:AgreeNearInvite_2()
  Team:AgreeNearInvite()
end

function Skill:CanUseSkillByName(aSkillName)
  local skill = Skill:GetSkillByName(aSkillName)
  return Skill:CanUseSkill(skill)
end

function Skill:CheckBuff(aSkillName)
  if "" == aSkillName then
    return false
  end
  Skill:UseCheckBuff(aSkillName)
end

function Enum2XAllObj()
  return EnumEnvObj()
end
