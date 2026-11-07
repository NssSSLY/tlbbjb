-- 反编译自 dfz64.dll 内嵌字节码 002a84ac（unluac 2025-12-23；仅供分析）
function _SMain(...)
  math.randomseed(GetTickCount())
  
  local SuiJi = math.random(1, 10)
  local shopName = "助手" .. SuiJi
  local shopName2 = "助手" .. SuiJi - 1
  local shopType = 1
  local shopType2 = 2
  PushDebugMessage("店铺名称：" .. shopName .. "  优先创建店铺类型：" .. shopType)
  local itemCount = Bag:GetItemCount("掌柜要诀")
  if 0 == itemCount then
    PushColorMsg("零点抢店：您没有掌柜要诀")
    Bank_GetItem("掌柜要诀")
  end
  MoveToNPC("乔复盛", 330, 299, LUOYANG_ID)
  Sleep(300)
  TalkNpc("乔复盛", 800)
  local needMoney = GetLuaValue("setmetatable(_G, {__index = PS_CreateShop_Env});local nOpenNeedMoney = PlayerShop:GetMoney('open','self');return nOpenNeedMoney", "n")
  if needMoney > Player:GetMoney() then
    PushColorMsg("凌晨抢店：您当前携带金币不足，无法创建商店！")
    Bank_GetMoney(needMoney)
  end
  InitServerTime()
  local oldDay = tonumber(os.date("%d", GetServerTime()))
  PushColorMsg("零点抢店：当前日期  " .. oldDay)
  local createCount = 0
  while true do
    if IsWindowVisible("PS_CreateShop") then
      if createCount > 18 then
        LogMsg("零点抢店：已经创建10次,停止")
        break
      end
      local nowDay = tonumber(os.date("%d", GetServerTime()))
      while nowDay == oldDay do
        DebugStr(fmt("当前时间：%s  将在零点开始", os.date("%X")))
        nowDay = tonumber(os.date("%d", GetServerTime()))
        Sleep(20)
        if IsWindowVisible("PS_CreateShop") == false then
          break
        end
      end
      if IsWindowVisible("PS_CreateShop") then
        GetLuaValue(fmt("setmetatable(_G, {__index = PS_CreateShop_Env});PlayerShop:CreateShop(\"%s\", %d)", shopName, shopType))
        createCount = createCount + 1
        if itemCount > 1 then
          QuestFrameNextClicked()
          GetLuaValue(fmt("setmetatable(_G, {__index = PS_CreateShop_Env});PlayerShop:CreateShop(\"%s\", %d)", shopName2, shopType2))
          createCount = createCount + 1
        end
        CloseWindow("PS_CreateShop")
      end
    elseif IsWindowVisible("Quest") then
      if DialogOptionClicked("建立自己的商店", 1) then
        QuestFrameNextClicked()
      else
        OpenTalk(132, 50)
      end
    elseif IsDestination(330, 299, LUOYANG_ID, 3) then
      OpenTalk(132, 50)
    else
      PushDebugMessage("偏离坐标！")
      MoveTo(330, 299, LUOYANG_ID)
    end
    Sleep(10)
  end
end

_SMain()
