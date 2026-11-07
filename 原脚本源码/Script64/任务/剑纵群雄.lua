-- 反编译自 dfz64.dll 内嵌字节码 00257006（unluac 2025-12-23；仅供分析）
local m_script_name = "剑纵群雄"
ScriptOnStart(m_script_name, true, true)
CDG.attack = true

local function JZQX_OpenUI()
  GetLuaValue("setmetatable(_G, {__index = ZongMenSkill_Env});ZongMenSkill_OpenPaTa()")
  Sleep(500)
end

local function JZQX_GetLeveInfo()
  GetLuaValue([[
        if _ZongMenPata_OnEvent == nil then
            local __nMyLevel = -1	
		    local __nMyZMLevel = -1
            _ZongMenPata_OnEvent = ZongMenPata_OnEvent;
        end

        function ZongMenPata_OnEvent(event)
            if(event == "UI_COMMAND") then
                if tonumber(arg0) == 998633006 then
                    __nMyLevel = Get_XParam_INT(0)	
		            __nMyZMLevel = Get_XParam_INT(1)
                end
            end
            _ZongMenPata_OnEvent(event)
        end
    ]])
  local nMyLevel = GetLuaValue("return __nMyLevel", "n", 1)
  local nMyZMLevel = GetLuaValue("return __nMyZMLevel", "n", 1)
  local g_MyZMLevel = nMyZMLevel
  local g_MyLevel = nMyLevel + 1
  PushColorMsg(nMyLevel)
  PushColorMsg(nMyZMLevel)
  JZQX_OpenUI()
  if -1 == nMyLevel or -1 == nMyZMLevel then
    CloseAllWindow()
    Sleep(500)
    JZQX_OpenUI()
    return -1, -1
  end
  CloseAllWindow()
  return nMyLevel, nMyZMLevel
end

local function JZQX_GetPathInfo()
  local info
  local nGuanLevel, nDiziLevel = JZQX_GetLeveInfo()
  local maxGuan = 100
  if nDiziLevel >= 35 then
  elseif nDiziLevel >= 25 then
    maxGuan = 80
  elseif nDiziLevel >= 15 then
    maxGuan = 60
  elseif nDiziLevel >= 1 then
    maxGuan = 40
  end
  if -1 ~= nGuanLevel then
    nGuanLevel = nGuanLevel + 1
    if nGuanLevel > 100 then
      nGuanLevel = 100
    end
    local strText = fmt("                local szNPCName, nSceneId, PosX, PosZ, nLimitZMLevel = Player:GetZMPTUiGoToInfo(%d)\n                local scene = \"\"\n                if nSceneId == 0 then\n                    scene = \"洛阳\"\n                elseif nSceneId == 1 then\n                    scene = \"苏州\"\n                elseif nSceneId == 2 then\n                    scene = \"大理\"\n                end\n            \n                return szNPCName, scene, PosX, PosZ\n            ", nGuanLevel)
    local strNPC, strScene, xPos, yPos = GetLuaValue(strText, "ssnn")
    info = {
      npcname = strNPC,
      sceneName = strScene,
      sceneID = GetSceneIDByName(strScene),
      x = xPos,
      y = yPos
    }
  end
  return info
end

local function JZQZ_OnFuben(aScene)
  while GetSceneID() == aScene do
    local tObj = Enum2XByClass("NPC 怪物")
    local tNPC = ObjFilterByStrClass(tObj, "NPC", 0)
    local tGuai = ObjFilterByStrClass(tObj, "怪物", 0)
    tGuai = ObjFilterByHP(tGuai, 0, 1)
    if #tGuai > 0 then
      local tmp = tGuai[1]
      local bGuid2 = CDG.pet2.GUID
      local bGuid3 = CDG.pet3.GUID
      CDG.pet2.GUID = 0
      CDG.pet3.GUID = 0
      FubenAttack(tmp.id, true, nil, nil, nil)
      CDG.pet2.GUID = bGuid2
      CDG.pet3.GUID = bGuid3
    else
      for i = 1, 5 do
        FubenAttack(-1)
      end
      for i = 1, #tNPC do
        local tmp = tNPC[i]
        if string.find(tmp.title, "第", nil, true) and string.find(tmp.title, "关考核人", nil, true) then
          RunTo(tmp.x, tmp.y, 1, 1000)
          Team:LeaveTeam()
          OpenTalk(tmp.id, 600)
          QuestFrameOptionClicked_Item("#{ZMPT_230629_47}", 1, 800)
          QuestFrameOptionClicked_Item("#{ZMPT_230629_132}", 1, 800)
          local allItem = GetNPCEventListAllItem()
          if string.find(allItem, "#{ZMPT_230629_48}", nil, true) and not string.find(allItem, "#{ZMPT_230629_47}", nil, true) and not string.find(allItem, "#{ZMPT_230629_132}", nil, true) then
            QuestFrameOptionClicked_Item("#{ZMPT_230629_48}", 1, 800)
            QuestFrameOptionClicked_Item("#{ZMPT_230629_43}", 1, 800)
          end
          break
        end
      end
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

local function ZongMenPata_Award_GetBitTable(nOct1, nOct2, nOct3, nOct4)
  local BitTable = {}
  local oct = nOct1
  for i = 1, 32 do
    BitTable[i] = oct % 2
    oct = math.floor(oct / 2)
  end
  oct = nOct2
  for i = 33, 64 do
    BitTable[i] = oct % 2
    oct = math.floor(oct / 2)
  end
  oct = nOct3
  for i = 65, 96 do
    BitTable[i] = oct % 2
    oct = math.floor(oct / 2)
  end
  oct = nOct4
  for i = 97, 100 do
    BitTable[i] = oct % 2
    oct = math.floor(oct / 2)
  end
  return BitTable
end

local function JZQX_GetPrice()
  CloseAllWindow()
  GetLuaValue("setmetatable(_G, {__index = ZongMenPata_Env});ZongMenPata_OpenAward()")
  Sleep(1000)
  local sid = 998633005
  local prize1_MD = Get_XParam_INT(sid, 0)
  local prize2_MD = Get_XParam_INT(sid, 1)
  local guanLevel = Get_XParam_INT(sid, 2)
  local prize3_MD = Get_XParam_INT(sid, 3)
  local prize4_MD = Get_XParam_INT(sid, 4)
  local PrizeState = ZongMenPata_Award_GetBitTable(prize1_MD, prize2_MD, prize3_MD, prize4_MD)
  local nClickMax = #PrizeState
  if guanLevel < nClickMax then
    nClickMax = guanLevel
  end
  if -1 ~= prize1_MD and -1 ~= prize2_MD and -1 ~= prize3_MD and -1 ~= prize4_MD then
    for i = 1, nClickMax do
      local nTemp = PrizeState[i]
      if 1 ~= nTemp then
        GetLuaValue(fmt("setmetatable(_G, {__index = ZongMenPata_Award_Env});ZongMenPata_Award_GetPrize(%d)", i))
      end
    end
  end
  CloseAllWindow()
end

function _SMain(...)
  JZQX_GetPrice()
  while true do
    local nScene = GetSceneID()
    if 897 == nScene or 898 == nScene or 899 == nScene then
      JZQZ_OnFuben(nScene)
    else
      local pinfo = JZQX_GetPathInfo()
      if pinfo then
        Team:LeaveTeam()
        MoveToNPC(pinfo.npcname, pinfo.x, pinfo.y, pinfo.sceneID)
        Team:LeaveTeam()
        QuestFrameOptionClicked_Item("#{ZMPT_230629_21}", 1, 800)
      else
      end
    end
    Sleep(500)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
