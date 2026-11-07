-- 反编译自 dfz64.dll 内嵌字节码 00564c67（unluac 2025-12-23；仅供分析）
CExec("common")
CExec("bag")
local m_check_sec10 = -1
local m_check_sec20 = -1
local m_check_sec30 = -1
local m_check_sec180 = -1
local m_check_sec600 = -1
local m_mibao_NextCheckTick = -1
local m_mibao_unlock_cyj = false
local m_last_tick_freeaction = -1
local m_next_oneday_once_tick = -1
local m_offline_check_tick = -1
local m_talk = {}
local m_delete_item = false
m_talk.lastTick_1 = -1
m_talk.lastTick_2 = -1
m_talk.lastTick_3 = -1
g_config = {}
g_config.tysz = {}
g_config.protect = {}
g_config.item = {}
g_config.shuaguai = {}

local function GetHelpConfig()
  GlobalParam_item()
  m_delete_item = ReadConfigBool("ZH", "xzk150")
  g_config.tysz.f11_hide = GetConfigBool("通用", "F11屏蔽")
  g_config.tysz.f12_hide = GetConfigBool("通用", "F12屏蔽")
  g_config.tysz.hide_city = GetConfigBool("通用", "城内屏蔽")
  g_config.tysz.unlock_cyj = GetConfigBool("通用", "解除畅游加")
  g_config.protect.buy_petitem = GetConfigBool("保护", "珍兽丹药")
  g_config.protect.petitem_type = GetConfigCommbox("保护", "珍兽丹药_类")
  g_config.protect.first_hongli = GetConfigBool("保护", "优先红利")
  g_config.protect.extend_petlife = GetConfigBool("保护", "附体延寿")
  g_config.tysz.unlock_ejmm = GetConfigText("通用", "二级密码")
  g_config.tysz.freezeWuyi = GetConfigBool("通用", "非天外冻武意")
  g_config.tysz.huoyuehaoli = GetConfigBool("通用", "领活跃好礼")
  g_config.tysz.lqqdjl = GetConfigBool("通用", "领签到奖励")
  g_config.tysz.lqxwzy = GetConfigBool("通用", "领修武之约")
  g_config.item.make_materials = ReadConfigBool("ZH", "xzk37")
  g_config.item.make_materials_task = "新刷怪"
  g_config.item.make_materials_sec = 3
  g_config.shuaguai.jgcl = false
  g_config.tysz.auto_talk = GetConfigBool("通用", "开启喊话")
  g_config.tysz.talk1 = GetConfigBool("通用", "频道1开启")
  g_config.tysz.talk1_where = GetConfigCommbox("通用", "喊话频道1")
  g_config.tysz.talk1_sec = GetConfigText("通用", "喊话间隔1")
  g_config.tysz.talk1_text = GetConfigText("通用", "喊话内容1")
  g_config.tysz.talk2 = GetConfigBool("通用", "频道2开启")
  g_config.tysz.talk2_where = GetConfigCommbox("通用", "喊话频道2")
  g_config.tysz.talk2_sec = GetConfigText("通用", "喊话间隔2")
  g_config.tysz.talk2_text = GetConfigText("通用", "喊话内容2")
  g_config.tysz.talk3 = GetConfigBool("通用", "频道3开启")
  g_config.tysz.talk3_where = GetConfigCommbox("通用", "喊话频道3")
  g_config.tysz.talk3_sec = GetConfigText("通用", "喊话间隔3")
  g_config.tysz.talk3_text = GetConfigText("通用", "喊话内容3")
end

local function SetF11State()
  if g_config.tysz.f11_hide then
    if g_config.tysz.hide_city then
      if IsSafeSceneID() then
        HelpFun(1, 0)
      end
    else
      HelpFun(1, 0)
    end
  end
end

local function SetF12State()
  if g_config.tysz.f12_hide then
    if g_config.tysz.hide_city then
      if IsSafeSceneID() then
        HelpFun(2, 0)
      end
    else
      HelpFun(2, 0)
    end
  end
end

local function OfflineCheck()
  local nSocket = GetSocket()
  if 4294967295 == nSocket then
    DebugColorMsg("与服务器失去连接...", 2)
    if -1 == m_offline_check_tick then
      m_offline_check_tick = GetTickCount()
    elseif GetTickCount() - m_offline_check_tick > 300000 then
      local str = "自动下线：与服务器失去连接5分钟,6秒后下线"
      PushColorMsg(str)
      Log(str)
      Sleep(6000)
      OffLine(false)
    end
  else
    m_offline_check_tick = -1
  end
end

local function Help_ConfigUpdate(aUpdate)
  if aUpdate then
    GetHelpConfig()
    if false == m_mibao_unlock_cyj and g_config.tysz.unlock_cyj then
      GetLuaValue("return meIsNeedCheckMibao(1)", "n")
    end
    SwitchSetState(1)
  end
  m_mibao_unlock_cyj = g_config.tysz.unlock_cyj
end

local function Help_BuyPetItem()
  if not g_config.protect.buy_petitem then
    return
  end
  local tItem = Bag:SearchItemName("超级珍兽滋补丹 超级珍兽回春丹 珍兽滋补丹 珍兽回春丹 珍兽万补丹 珍兽回神丹")
  if #tItem >= 2 then
    return
  end
  if not CheckMibao(false) then
    PushDebugMessage("保护：购买珍兽丹失败,您还未解锁密保")
    return
  end
  local nSpace = Bag:GetSpaceNum(0)
  if 0 == nSpace then
    PushDebugMessage("保护：背包已满,无法购买珍兽丹!")
    return
  end
  local tPetItem = {
    {
      name = "珍兽回春丹",
      price = 11,
      index_bdyb = 5,
      index_hongli = 3
    },
    {
      name = "珍兽滋补丹",
      price = 6,
      index_bdyb = 4,
      index_hongli = 2
    },
    {
      name = "超级珍兽回春丹",
      price = 39,
      index_bdyb = 0,
      index_hongli = -1
    },
    {
      name = "超级珍兽滋补丹",
      price = 20,
      index_bdyb = 1,
      index_hongli = -1
    }
  }
  local buyItem = tPetItem[1]
  if g_config.protect.petitem_type then
    if 1 == g_config.protect.petitem_type.sel then
      buyItem = tPetItem[2]
    elseif 2 == g_config.protect.petitem_type.sel then
      buyItem = tPetItem[3]
    elseif 3 == g_config.protect.petitem_type.sel then
      buyItem = tPetItem[4]
    end
  end
  local bdyb = [[
            local bdyb = Player:GetData("BIND_YUANBAO")
            if bdyb and bdyb >= 39 then
                setmetatable(_G, {__index = YuanbaoShop_Env})
                YuanbaoShop_ChangeTabIndex(1)
                YuanbaoShop_UpdateList_Bind(3)
                return 1
            end 
        ]]
  local hongli = [[
            local bdyb = Player:GetData("LIJIN")
            if bdyb and bdyb >= 11 then
                setmetatable(_G, {__index = YuanbaoShop_Env})
                YuanbaoShop_ChangeTabIndex(5)
                YuanbaoShop_UpdateList(3)
                return 2
            end 
        ]]
  local strLua = bdyb .. hongli
  if g_config.protect.first_hongli and buyItem.price <= 11 then
    strLua = hongli .. bdyb
  end
  strLua = strLua .. " return 0"
  local nopen = GetLuaValue(strLua, "n")
  if 0 ~= nopen then
    Sleep(1200)
    tItem = Bag:SearchItemName("超级珍兽滋补丹 超级珍兽回春丹 珍兽滋补丹 珍兽回春丹 珍兽万补丹 珍兽回神丹")
    if #tItem < 2 then
      local strText = fmt("                    local num = 0\n                    local CurrBagNum = DataPool:GetBaseBag_Num()\n                    for i = 0, CurrBagNum - 1 do\n                        local theAction, bLocked, bProtect = PlayerPackage:EnumItem(\"base\", i)\n                        if theAction:GetID() ~= 0 then\n                            local itemName = theAction:GetName() \n                            if itemName == \"珍兽滋补丹\" or itemName == \"珍兽回春丹\" or itemName == \"珍兽万补丹\" \n                                or itemName == \"珍兽回神丹\" or itemName == \"超级珍兽滋补丹\" or itemName == \"超级珍兽回春丹\" then\n                                num = num + 1\n                            end\n                        end\n                    end\n                    if meGetSceneTransTimeDiff() > 3 and num < 2 then\n                        meTestMsg(\"保护：您已设置购买珍兽丹\")\n                        local nIdx = %d\n                        local nPrice = %d\n                        local price = NpcShop:EnumItemPrice(nIdx)\n                        if price and price == nPrice then\n                            NpcShop:BulkBuyItem(nIdx, 1, 0)\n                        end\n                    end         \n                ", buyItem.index_bdyb, buyItem.price)
      if 2 == nopen and -1 ~= buyItem.index_hongli then
        strText = fmt("                    local num = 0\n                    local CurrBagNum = DataPool:GetBaseBag_Num()\n                    for i = 0, CurrBagNum - 1 do\n                        local theAction, bLocked, bProtect = PlayerPackage:EnumItem(\"base\", i)\n                        if theAction:GetID() ~= 0 then\n                            local itemName = theAction:GetName() \n                            if itemName == \"珍兽滋补丹\" or itemName == \"珍兽回春丹\" or itemName == \"珍兽万补丹\" \n                                or itemName == \"珍兽回神丹\" or itemName == \"超级珍兽滋补丹\" or itemName == \"超级珍兽回春丹\" then\n                                num = num + 1\n                            end\n                        end\n                    end\n                    if meGetSceneTransTimeDiff() > 5 and num < 2 then\n                        meTestMsg(\"保护：您已设置购买珍兽丹\")\n                        local nIdx = %d\n                        local nPrice = %d\n                        local price = NpcShop:EnumItemPrice(nIdx)\n                        if price and price == nPrice then\n                            NpcShop:BulkBuyItem(nIdx, 1, 0)\n                        end\n                    end         \n                ", buyItem.index_hongli, buyItem.price)
      end
      GetLuaValue(strText)
      Sleep(500)
      CloseWindow("YuanbaoShop")
    end
  else
    PushDebugMessage("保护：绑定元宝和红利不足,无法购买珍兽丹!")
  end
end

local function Help_ExtendPetLife()
  if not g_config.protect.extend_petlife then
    return
  end
  local nIndex = GetLuaValue("return mePetYanShou()", "n")
  if nIndex > 0 and nIndex <= 10 then
    nIndex = nIndex - 1
    local bLock = 0
    local tObj = Bag:FindItemInfo("珍兽延年丹", nil, bLock)
    if 0 == #tObj then
      if not IsUnLockMibao() then
        PushDebugMessage("购买珍兽延年丹失败:您还未解锁密保")
        return
      end
      local bdyb = [[
            local bdyb = Player:GetData("BIND_YUANBAO")
            if bdyb and bdyb >= 20 then
                setmetatable(_G, {__index = YuanbaoShop_Env})
                YuanbaoShop_ChangeTabIndex(1)
                YuanbaoShop_UpdateList_Bind(3)
                return 1
            end 
        ]]
      local hongli = [[
            local bdyb = Player:GetData("LIJIN")
            if bdyb and bdyb >= 20 then
                setmetatable(_G, {__index = YuanbaoShop_Env})
                YuanbaoShop_ChangeTabIndex(5)
                YuanbaoShop_UpdateList(3)
                return 2
            end 
        ]]
      local strLua = bdyb .. hongli
      if g_config.protect.first_hongli then
        strLua = hongli .. bdyb
      end
      strLua = strLua .. " return 0"
      local nopen = GetLuaValue(strLua, "n")
      if 0 ~= nopen then
        Sleep(1200)
        local strText = "                local num = 0\n                local CurrBagNum = DataPool:GetBaseBag_Num()\n                for i = 0, CurrBagNum - 1 do\n                    local theAction, bLocked, bProtect = PlayerPackage:EnumItem(\"base\", i)\n                    if theAction:GetID() ~= 0 then\n                        if theAction:GetName() == \"珍兽延年丹\" then\n                            num = num + 1\n                            break\n                        end\n                    end\n                end\n                if num == 0 then\n                    meTestMsg(\"保护页面：您已设置购买珍兽延年丹\")\n                    local price = NpcShop:EnumItemPrice(4)\n                    if price and price == 20 then\n                        NpcShop:BulkBuyItem(4, 1, 0)\n                    end\n                end         \n            "
        if 1 == nopen then
          strText = "                        local num = 0\n                        local CurrBagNum = DataPool:GetBaseBag_Num()\n                        for i = 0, CurrBagNum - 1 do\n                            local theAction, bLocked, bProtect = PlayerPackage:EnumItem(\"base\", i)\n                            if theAction:GetID() ~= 0 then\n                                if theAction:GetName() == \"珍兽延年丹\" then\n                                    num = num + 1\n                                    break\n                                end\n                            end\n                        end\n                        if num == 0 then\n                            meTestMsg(\"保护页面：您已设置购买珍兽延年丹\")\n                            local price = NpcShop:EnumItemPrice(6)\n                            if price and price == 20 then\n                                NpcShop:BulkBuyItem(6, 1, 0)\n                            end\n                        end         \n                    "
        end
        GetLuaValue(strText)
        Sleep(1000)
        CloseWindow("YuanbaoShop")
      else
        PushDebugMessage("绑定元宝或红利不足,无法购买珍兽延年丹")
      end
    end
    tObj = Bag:FindItemInfo("珍兽延年丹", nil, bLock)
    if #tObj > 0 then
      local strText = fmt("Pet:SkillStudy_Do(3, %d, %d);", nIndex, tObj[1].index)
      GetLuaValue(strText)
      Sleep(1000)
    end
  end
end

local function Help_CheckMibao()
  local nowTick = GetTickCount()
  if nowTick > m_mibao_NextCheckTick then
    local strLen = #g_config.tysz.unlock_ejmm
    if g_config.tysz.unlock_cyj or strLen >= 4 and strLen <= 15 then
      local bCheck = GetLuaValue("return meIsNeedCheckMibao()", "n")
      if 1 == bCheck then
        local nCheck = GetLuaValue(fmt("return meUnLockMibao(%s,[[%s]])", tostring(g_config.tysz.unlock_cyj), g_config.tysz.unlock_ejmm), "n")
        if 0 == nCheck then
          GetLuaValue("return meIsNeedCheckMibao(0)", "n")
        elseif 1 == nCheck then
          GetLuaValue("return meIsNeedCheckMibao(0)", "n")
          Sleep(1500)
          GetLuaValue("setmetatable(_G, {__index = SafeCenter_SafeCheck_Env});if this:IsVisible() then SafeCenter_SafeCheck_Close() end;")
        elseif 2 == nCheck or 3 == nCheck then
          PushDebugMessage("申请解锁密保")
          Sleep(1500)
          if 3 == nCheck then
            GetLuaValue("setmetatable(_G, {__index = SafeCenter_SafeCheck_Env});if this:IsVisible() then SafeCenter_SafeCheck_Close() end;")
          end
          m_mibao_NextCheckTick = nowTick + 65000
        elseif 4 == nCheck then
          m_mibao_NextCheckTick = nowTick + 3000
        end
      else
        m_mibao_NextCheckTick = nowTick + 15000
      end
    end
  end
end

local function Help_DongJieWuyi()
  if g_config.tysz.freezeWuyi then
    if IsKVKSceneName() then
      GetLuaValue("meFreezeMaritia(0)")
    else
      GetLuaValue("meFreezeMaritia(1)")
    end
  end
end

local function Help_LingQuHuoYueHaoLi()
  if g_config.tysz.huoyuehaoli then
    LingQuHuoYueHaoLi(false)
  end
end

local function Help_CheckSec10()
  local nowTick = GetTickCount()
  if nowTick > m_check_sec10 then
    GetLuaValue("meCheckJBZZ()")
    m_check_sec10 = nowTick + 10000
  end
end

local function Help_CheckSec20()
  local nowTick = GetTickCount()
  if nowTick > m_check_sec20 then
    Help_CheckGameConnect()
    m_check_sec20 = nowTick + 20000
  end
end

local function Help_CheckSec30()
  local nowTick = GetTickCount()
  if nowTick > m_check_sec30 then
    Help_BuyPetItem()
    OfflineCheck()
    if m_delete_item and CheckMibao(false) then
      Bag_DeleteBagItem()
      Bag_DeleteTempBagItem()
    end
    m_check_sec30 = nowTick + 30000
  end
end

local function Help_CheckSec180()
  local nowTick = GetTickCount()
  if nowTick > m_check_sec180 then
    Help_LingQuHuoYueHaoLi()
    Help_DongJieWuyi()
    m_check_sec180 = nowTick + 180000
  end
end

local function Help_CheckSec600()
  local nowTick = GetTickCount()
  if nowTick > m_check_sec600 then
    Help_ExtendPetLife()
    m_check_sec600 = nowTick + 600000
  end
end

local function Help_CheckOneDayOnce()
  local nowTick = GetTickCount()
  if nowTick > m_next_oneday_once_tick then
    local lefttime = GetLuaValue("local dblefttime = DataPool:GetLeftProtectTime() return dblefttime", "n")
    if lefttime <= 0 then
      PushDebugMessage("自动签到")
      Sleep(1000)
      QianDaoAndGetPrize()
      local next_sec = GetNextDaySec()
      next_sec = next_sec + 60
      m_next_oneday_once_tick = nowTick + next_sec * 1000
    end
  end
end

local function Help_FreeAction()
  if -1 == m_last_tick_freeaction then
    m_last_tick_freeaction = GetTickCount()
  end
  local nState = GetPlayerState()
  if 0 ~= nState then
    m_last_tick_freeaction = GetTickCount()
  else
    local bCheckShuaGuai = true
    if g_config.item.make_materials then
      local nSceneID = GetSceneID()
      local bCan = true
      if IsDiFuScene(nSceneID) then
        bCheckShuaGuai = false
        bCan = false
      end
      if bCan and CheckTaskNameHasRuningScript(g_config.item.make_materials_task) and not IsMount() and not IsPlayerFollow(true) then
        local sec = tonumber(g_config.item.make_materials_sec)
        sec = sec or 3
        if GetTickCount() - m_last_tick_freeaction > sec * 1000 then
          bCheckShuaGuai = false
          if JiaGongCaiLiao() then
            PushDebugMessage("%s:空闲%d秒,开始加工材料", g_runing_script, sec)
            Sleep(1000)
          end
        end
      end
    end
    if bCheckShuaGuai and g_config.shuaguai.jgcl then
      local sec = tonumber(g_config.item.make_materials_sec)
      sec = sec or 3
      if GetTickCount() - m_last_tick_freeaction > sec * 1000 and CheckTaskNameHasRuningScript("新刷怪") and not IsMount() and not IsPlayerFollow(true) and JiaGongCaiLiao() then
        PushDebugMessage("%s:空闲%d秒,开始加工材料!", g_runing_script, sec)
        Sleep(1000)
      end
    end
  end
end

local function Help_GetTalkPinDao(aIndex)
  if 0 == aIndex then
    return "near"
  elseif 1 == aIndex then
    return "scene"
  elseif 2 == aIndex then
    return "team"
  elseif 3 == aIndex then
    return "menpai"
  elseif 4 == aIndex then
    return "guild"
  elseif 5 == aIndex then
    return "guild_league"
  elseif 6 == aIndex then
    return "bigworld"
  elseif 7 == aIndex then
    return "alliance"
  elseif 8 == aIndex then
    return "laba"
  elseif 9 == aIndex then
    return "qiwen"
  end
  return ""
end

local function Help_GetTalkMsg(aWhere, aMsg)
  if "laba" == aWhere then
    if 0 == Bag:GetItemCount("小喇叭") then
      aMsg = ""
      PushDebugMessage("自动喊话：您缺少小喇叭")
    end
  elseif "qiwen" == aWhere and 0 == Bag:GetItemCount("奇闻小喇叭") then
    aMsg = ""
    PushDebugMessage("自动喊话：您缺少奇闻小喇叭")
  end
  return aMsg
end

local function Help_AutoTalk()
  if g_config.tysz.auto_talk then
    local nowTick = GetTickCount()
    if g_config.tysz.talk1 then
      local nSec = HandleTextToNumber(g_config.tysz.talk1_sec, 0)
      if nSec > 0 and nowTick - m_talk.lastTick_1 > nSec * 1000 then
        local where = Help_GetTalkPinDao(g_config.tysz.talk1_where.sel)
        local strMsg = Help_GetTalkMsg(where, g_config.tysz.talk1_text)
        if "" ~= strMsg then
          TalkChatMsg(where, strMsg)
        end
        m_talk.lastTick_1 = nowTick
      end
    end
    if g_config.tysz.talk2 then
      local nSec = HandleTextToNumber(g_config.tysz.talk2_sec, 0)
      if nSec > 0 and nowTick - m_talk.lastTick_2 > nSec * 1000 then
        local where = Help_GetTalkPinDao(g_config.tysz.talk2_where.sel)
        local strMsg = Help_GetTalkMsg(where, g_config.tysz.talk2_text)
        if "" ~= strMsg then
          TalkChatMsg(where, strMsg)
        end
        m_talk.lastTick_2 = nowTick
      end
    end
    if g_config.tysz.talk3 then
      local nSec = HandleTextToNumber(g_config.tysz.talk3_sec, 0)
      if nSec > 0 and nowTick - m_talk.lastTick_3 > nSec * 1000 then
        local where = Help_GetTalkPinDao(g_config.tysz.talk3_where.sel)
        local strMsg = Help_GetTalkMsg(where, g_config.tysz.talk3_text)
        if "" ~= strMsg then
          TalkChatMsg(where, strMsg)
        end
        m_talk.lastTick_3 = nowTick
      end
    end
  end
end

function MainHelp()
  local bFirst = true
  m_check_sec10 = GetTickCount()
  m_check_sec20 = m_check_sec10
  m_check_sec30 = m_check_sec10
  m_check_sec180 = m_check_sec10
  m_check_sec600 = m_check_sec10
  m_mibao_NextCheckTick = m_check_sec10
  m_next_oneday_once_tick = m_check_sec10
  m_talk.lastTick_1 = m_check_sec10
  m_talk.lastTick_2 = m_check_sec10
  m_talk.lastTick_3 = m_check_sec10
  while true do
    if IsWindowVisible("PlayerFrame") or IsWindowVisible("MainMenuBar") then
      if bFirst and Player_GetName() ~= "" then
        GetHelpConfig()
        bFirst = false
      end
      if false == bFirst and IsValidConfig() then
        GetConfig()
        local bUpdate = SwitchGetState()
        Help_ConfigUpdate(bUpdate)
        Help_CheckMibao()
        Help_CheckSec10()
        Help_CheckSec30()
        Help_CheckSec180()
        Help_CheckSec600()
        Help_CheckOneDayOnce()
        SetF11State()
        SetF12State()
        Help_FreeAction()
        Help_AutoTalk()
      end
    else
      Sleep(3000)
    end
    Sleep(500)
    Help_CheckSec20()
  end
end

MainHelp()
