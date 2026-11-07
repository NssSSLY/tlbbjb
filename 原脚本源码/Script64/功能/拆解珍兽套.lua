-- 反编译自 dfz64.dll 内嵌字节码 0034a9b3（unluac 2025-12-23；仅供分析）
ScriptOnStart("拆解背包75级珍兽一星套", false, false)
g_config["拆解珍兽套"] = {}
g_config["拆解珍兽套"]["白名单"] = ""
local m_param = {}
m_param.bai = ""

local function CJ_EnumTao()
  local tBag = Bag:EnumDaoJuItem()
  for i = 1, #tBag do
    local tmp = tBag[i]
    if 7 == tmp.itemType and 75 == tmp.level and 1 == tmp.xing and 0 == tmp.lock and not string.find(tmp.name, "灵兽", nil, true) and not string.find(m_param.bai, " " .. tmp.name .. " ", nil, true) then
      return tmp.index
    end
  end
  return -1
end

function CJ_Main()
  if g_config["拆解珍兽套"] then
    m_param.bai = HandleText_AddFuHao(g_config["拆解珍兽套"]["白名单"], " ", true)
  end
  TempBank2Bag(" 珍兽装备 ", 1)
  Sleep(500)
  local nIdx = CJ_EnumTao()
  if -1 == nIdx then
    PushColorMsg("拆解：当前没有珍兽套可拆解")
    return
  end
  Bag_DeleteItem()
  Bag_SellItem()
  CloseAllWindow()
  GoToSceneNPC("云姗姗", 355, 268, 1)
  local nStartTick = GetTickCount()
  while true do
    if IsWindowVisible("PetEquipSuitDepart") then
      if IsWindowVisible("LoginSelectServerQuest") then
        SelectServerQuest_Bn1Click()
        Sleep(150)
        GetLuaValue("setmetatable(_G, {__index=PetEquipSuitDepart_Env});PetEquipSuitDepart_Buttons_Clicked();")
        Sleep(150)
      end
      if not IsWindowVisible("Packet") then
        GetLuaValue("setmetatable(_G, {__index = Packet_Env});Packet_Open()")
        Sleep(800)
      end
      nIdx = CJ_EnumTao()
      if -1 == nIdx then
        break
      end
      Bag:ItemBtnClicked(nIdx)
      Sleep(100)
      GetLuaValue("setmetatable(_G, {__index=PetEquipSuitDepart_Env});PetEquipSuitDepart_Buttons_Clicked()")
    else
      GoToSceneNPC("云姗姗", 355, 268, 1)
      Sleep(600)
      QuestFrameOptionClicked_Item("珍兽套装拆解", 1, 800)
    end
    DebugStr("拆解珍兽套")
    Sleep(200)
    if -1 ~= nStartTick and GetTickCount() - nStartTick > 99000 then
      PushColorMsg("拆解：超时！")
      break
    end
  end
  SelectServerQuest_Bn1Click()
  CloseAllWindow()
end

CJ_Main()
ScriptOnStop("拆解珍兽套", false)
