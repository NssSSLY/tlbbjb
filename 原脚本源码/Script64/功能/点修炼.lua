-- 反编译自 dfz64.dll 内嵌字节码 0034bc02（unluac 2025-12-23；仅供分析）
local m_script_name = "自动修炼"
ScriptOnStart(m_script_name, false, false)
g_config.zdxl = {}
g_config.zdxl.list = GetConfigList("日常", "修炼列表")
g_config.zdxl.gld = GetConfigBool("日常", "修炼功力丹")

local function xl_parseParam()
  local tXL = {}
  for i = 1, #g_config.zdxl.list do
    local tmp = g_config.zdxl.list[i]
    local strArr = SplitString(tmp.text, "-", true)
    if 3 == #strArr then
      local strbook = string.gsub(strArr[1], "第", "")
      strbook = string.gsub(strbook, "本", "")
      strbook = tonumber(strbook) or -1
      local strpage = string.gsub(strArr[2], "第", "")
      strpage = string.gsub(strpage, "卷", "")
      strpage = tonumber(strpage) or -1
      local strjingjie = string.gsub(strArr[3], "到", "")
      strjingjie = string.gsub(strjingjie, "重", "")
      if "点满" == strjingjie then
        strjingjie = 11
      end
      strjingjie = tonumber(strjingjie) or -1
      if strbook > 0 and strpage > 0 and strjingjie > 0 then
        if 1 == strbook and strpage > 5 then
          PushColorMsg("第一本宝典没有第六卷,忽略！")
        elseif 3 == strbook and strpage > 4 then
          PushColorMsg("第三本宝典只有四卷,忽略！")
        else
          table.insert(tXL, {
            book = strbook,
            page = strpage,
            max_jingjie = strjingjie
          })
        end
      end
    end
  end
  return tXL
end

local function xl_getIndex(aBook, aPage)
  if 1 == aBook then
    return aPage - 1
  elseif 2 == aBook then
    return aPage + 4
  elseif 3 == aBook then
    return aPage + 10
  end
  return -1
end

local function xl_getInfo(aIndex)
  local strText = fmt([[
            local nIndex = %d
            local jingjie = Player:GetXiuLianMiJiInfo(nIndex, "JingJie")
            local level = Player:GetXiuLianMiJiInfo(nIndex, "Level")
            local maxlevel = Player:GetXiuLianMiJiInfo(nIndex, "MaxLevel")
            local nNeedMoney = Player:GetXiuLianMiJiInfo(nIndex,"UpLevelNeedMoney")
            local nNeedExp = Player:GetXiuLianMiJiInfo(nIndex,"UpLevelNeedExp")
            return jingjie,level,maxlevel,nNeedMoney,nNeedExp
        ]], aIndex)
  return GetLuaValue(strText, "nnnnn")
end

local function xl_getNeedGL(aJingJie)
  if aJingJie <= 3 then
    return 33
  elseif aJingJie <= 6 then
    return 50
  elseif aJingJie <= 12 then
    return 100
  end
  return 100
end

local function xl_upgradeSkill(aClick, aIndex)
  PushColorMsg(m_script_name .. ":第%d本,第%d卷需要提升境界", aClick.book, aClick.page)
  local npcID = 171
  local tNPC = Enum2XByName("扫地神僧", {
    1,
    0,
    0,
    0
  }, nil, nil, 0)
  if #tNPC > 0 then
    npcID = tNPC[1].id
  end
  local strText = fmt([[
            local npcID = %d
			local select = %d
			Clear_XSCRIPT();
				Set_XSCRIPT_Function_Name("AskXiuLianAdvanceJingJie");
				Set_XSCRIPT_ScriptID(002099);
				Set_XSCRIPT_Parameter(0,tonumber(npcID));
				Set_XSCRIPT_Parameter(1,tonumber(select));
				Set_XSCRIPT_ParamCount(2);
			Send_XSCRIPT();
		]], npcID, aIndex)
  GetLuaValue(strText)
  Sleep(2000)
end

local function xl_useGLD()
  if g_config.zdxl.gld and not IsInDebugMsg("#{XLGLZHF_20091021_02}") then
    TakeItemToBag("功力丹")
    local tItem = Bag:FindItemInfo("功力丹")
    if #tItem > 0 then
      Dismount(500)
      Bag:UseItemByName("功力丹")
      Sleep(1000)
      MessageBox_Self_Text_Clicked("功力丹", 800)
      return true
    end
  end
  return false
end

function _SMain(...)
  local tXL = xl_parseParam()
  if 0 == #tXL then
    PushColorMsg(m_script_name .. ":没有解析到正确的参数!")
    return
  end
  local nTimeOut = -1
  if g_config.zdxl.gld then
    TakeItemToBag("功力丹")
  end
  DeleteDebugMsg("#{XLGLZHF_20091021_02}")
  while true do
    if Player:GetDataInt("POWER") < 33 then
      if false == xl_useGLD() then
        break
      end
      if -1 == nTimeOut then
        nTimeOut = GetTickCount()
      end
    else
      GoToSceneNPC("扫地神僧", 241, 31, 2)
      local npcID = 171
      local tNPC = Enum2XByName("扫地神僧", {
        1,
        0,
        0,
        0
      }, nil, nil, 0)
      if #tNPC > 0 then
        npcID = tNPC[1].id
      end
      if -1 == nTimeOut then
        nTimeOut = GetTickCount()
      end
      Sleep(600)
      QuestFrameOptionClicked_Item("#{XL_XML_35}", 1, 700)
      local myExp = Player:GetDataInt("EXP")
      local nHuiLiuExp = Player:GetDataInt("HUILIUEXP")
      local hasExp = myExp + nHuiLiuExp
      local bNext = false
      for i = 1, #tXL do
        local tmp = tXL[i]
        local nIndex = xl_getIndex(tmp.book, tmp.page)
        local jingjie, level, max_level, need_money, need_exp = xl_getInfo(nIndex)
        local need_power = xl_getNeedGL(jingjie)
        local myPower = Player:GetDataInt("POWER")
        if hasExp >= need_exp then
          if jingjie >= tmp.max_jingjie or 105 == level then
            PushColorMsg(m_script_name .. ":第%d本,第%d卷不需要点", tmp.book, tmp.page)
          elseif level == max_level then
            DeleteDebugMsg("#{XL_090707_11}")
            DeleteDebugMsg("#{XL_090707_65}")
            xl_upgradeSkill(tmp, nIndex)
            if IsInDebugMsg("#{XL_090707_11}", 1) or IsInDebugMsg("#{XL_090707_65}", 1) then
              PushColorMsg(m_script_name .. ":第%d本,第%d卷无法提升境界", tmp.book, tmp.page)
            else
              bNext = true
              break
            end
          elseif need_power > myPower then
            if false == xl_useGLD() then
              PushColorMsg(m_script_name .. ":第%d本,第%d卷功力不足", tmp.book, tmp.page)
            else
              bNext = true
              break
            end
          else
            GetLuaValue(fmt([[
                                    local npcID = %d
                                    local select = %d
                                    Clear_XSCRIPT();
                                        Set_XSCRIPT_Function_Name("AskXiuLianLevelUp");
                                        Set_XSCRIPT_ScriptID(002099);
                                        Set_XSCRIPT_Parameter(0,tonumber(npcID));
                                        Set_XSCRIPT_Parameter(1,tonumber(select));
                                        Set_XSCRIPT_ParamCount(2);
                                    Send_XSCRIPT();
                                ]], npcID, nIndex))
            Sleep(800)
            MessageBox_Self_OK_Clicked(800)
            bNext = true
            break
          end
        else
          PushColorMsg(m_script_name .. ":第%d本,第%d卷所需经验不足,点下一本", tmp.book, tmp.page)
        end
      end
      if false == bNext then
      end
    end
    Sleep(700)
    if -1 ~= nTimeOut and GetTickCount() - nTimeOut > 120000 then
      PushColorMsg(m_script_name .. ":超时5分钟")
      break
    end
    DebugStr(m_script_name)
  end
  Bag_Move2TempBank("功力丹")
end

_SMain()
ScriptOnStop(m_script_name)
