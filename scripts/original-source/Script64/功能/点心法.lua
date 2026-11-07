-- 反编译自 dfz64.dll 内嵌字节码 0034d3a7（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：表键 少林 → ["少林"]（1 处）；表键 星宿 → ["星宿"]（1 处）；表键 天龙 → ["天龙"]（1 处）；表键 唐门 → ["唐门"]（1 处）
local m_script_name = "点心法"
ScriptOnStart(m_script_name)
g_config["点心法"] = {}
g_config["点心法"]["第一本"] = ReadConfigInt("ZH", "bjk172")
g_config["点心法"]["第二本"] = ReadConfigInt("ZH", "bjk173")
g_config["点心法"]["第三本"] = ReadConfigInt("ZH", "bjk174")
g_config["点心法"]["第四本"] = ReadConfigInt("ZH", "bjk175")
g_config["点心法"]["第五本"] = ReadConfigInt("ZH", "bjk176")
g_config["点心法"]["第六本"] = ReadConfigInt("ZH", "bjk177")
g_config["点心法"]["第七本"] = ReadConfigInt("ZH", "bjk178")
g_config["点心法"]["第八本"] = ReadConfigInt("ZH", "bjk183")
local m_xinfa_level = {
  30,
  30,
  30,
  30,
  30,
  30,
  0,
  0
}
m_xinfa_level[1] = HandleTextToNumber(g_config["点心法"]["第一本"], 0)
m_xinfa_level[2] = HandleTextToNumber(g_config["点心法"]["第二本"], 0)
m_xinfa_level[3] = HandleTextToNumber(g_config["点心法"]["第三本"], 0)
m_xinfa_level[4] = HandleTextToNumber(g_config["点心法"]["第四本"], 0)
m_xinfa_level[5] = HandleTextToNumber(g_config["点心法"]["第五本"], 0)
m_xinfa_level[6] = HandleTextToNumber(g_config["点心法"]["第六本"], 0)
m_xinfa_level[7] = HandleTextToNumber(g_config["点心法"]["第七本"], 0)
m_xinfa_level[8] = HandleTextToNumber(g_config["点心法"]["第八本"], 0)
local m_menpai = {
  ["少林"] = {
    name = "玄难",
    x = 91,
    y = 72,
    sceneID = 9
  },
  ["明教"] = {
    name = "庞万春",
    x = 108,
    y = 59,
    sceneID = 11
  },
  ["丐帮"] = {
    name = "奚三祁",
    x = 95,
    y = 99,
    sceneID = 10
  },
  ["武当"] = {
    name = "俞远山",
    x = 82,
    y = 85,
    sceneID = 12
  },
  ["峨嵋"] = {
    name = "崔绿华",
    x = 98,
    y = 52,
    sceneID = 15
  },
  ["星宿"] = {
    name = "施全",
    x = 87,
    y = 70,
    sceneID = 16
  },
  ["天龙"] = {
    name = "本观",
    x = 98,
    y = 66,
    sceneID = 13
  },
  ["天山"] = {
    name = "兰剑",
    x = 88,
    y = 44,
    sceneID = 17
  },
  ["逍遥"] = {
    name = "康广陵",
    x = 124,
    y = 142,
    sceneID = 14
  },
  ["慕容"] = {
    name = "慕容青山",
    x = 48,
    y = 134,
    sceneID = 284
  },
  ["唐门"] = {
    name = "唐岳冲",
    x = 38,
    y = 75,
    sceneID = 615
  },
  ["鬼谷"] = {
    name = "李继隆",
    x = 91,
    y = 55,
    sceneID = 678
  },
  ["桃花岛"] = {
    name = "燕返",
    x = 205,
    y = 65,
    sceneID = 731
  },
  ["绝情谷"] = {
    name = "云骁",
    x = 230,
    y = 170,
    sceneID = 824
  },
  ["恶人谷"] = {
    name = "叶二娘",
    x = 186,
    y = 120,
    sceneID = 987
  }
}

local function XinFaGetIDByIndex(aIndex)
  local nXinfa_Id, nXinfa_level = GetLuaValue(fmt([[
                local index = %d
                local theAction = EnumAction(index, "xinfa")
                if theAction:GetID() ~= 0 then
                    local XINFA_INDEX = theAction:GetID()
                    local nXinfa_Id = LifeAbility:GetLifeAbility_Number(XINFA_INDEX)
                    local nXinfa_level = Player:GetXinfaInfo(nXinfa_Id, "level")
                    return nXinfa_Id, nXinfa_level
                end
                return -1, -1
	        ]], aIndex - 1), "nn")
  return nXinfa_Id, nXinfa_level
end

function _SMain(...)
  local strMenPai = GetMenpaiNameByID(g_self.menpai)
  local npc = m_menpai[strMenPai]
  if not npc then
    PushColorMsg("点心法：门派信息不正确")
    return
  end
  PushColorMsg("点心法：取钱")
  Bank_GetMoney(-1)
  CloseAllWindow()
  local nLevel = Player:GetDataInt("LEVEL")
  local nTick = GetTickCount()
  while true do
    GoToScene(npc.x, npc.y, npc.sceneID)
    local bClick = false
    for i = 1, #m_xinfa_level do
      local needLevel = m_xinfa_level[i]
      local nXinfa_Id, nXinfa_level = XinFaGetIDByIndex(i)
      if nXinfa_Id >= 0 and needLevel > nXinfa_level then
        local bCan = GetLuaValue(fmt("\t\t\t\t        local nXinfaId = %d\n\t\t\t\t        local nXinfaLevel = %d\n\t\t\t\t        local nMoneyNow,nGold,nSilverCoin,nCopperCoin = GetUplevelXinfaSpendMoney(nXinfaId,nXinfaLevel + 1);\n\t\t\t\t        --获得升级心法需要的经验\n\t\t\t\t        local nExp = GetUplevelXinfaSpendExp(nXinfaId,nXinfaLevel + 1);\n\t\t\t\t        local Player_GetEXP = Player:GetData(\"EXP\")\n\t\t\t\t        local nMoney = Player:GetData('MONEY')\n\t\t\t\t        local money = Player:GetData('MONEY_JZ')\n\t\t\t\t        if nMoneyNow > nMoney+money or nExp > Player_GetEXP then\n\t\t\t\t        \treturn 0\n\t\t\t\t        end\n                        return 1\n\t\t\t\t", nXinfa_Id, nXinfa_level), "b")
        if bCan then
          bClick = true
          PushDebugMessage("点击第" .. i .. "本心法,当前等级" .. nXinfa_level)
          GetLuaValue(fmt("SkillsStudyFrame_study(%d)", nXinfa_Id))
          Sleep(300)
          MessageBox_Self_Text_Clicked("需要使用角色自身经验", 800)
        end
      end
    end
    if false == bClick then
      PushColorMsg("点心法：没有心法可升级,检查经验或金币")
      break
    end
    if GetTickCount() - nTick > 300000 then
      PushColorMsg("点心法：超时")
      break
    end
    Sleep(100)
    DebugStr(m_script_name)
  end
  PushColorMsg("点心法：存钱")
  Bank_SaveMoney(0)
end

_SMain()
