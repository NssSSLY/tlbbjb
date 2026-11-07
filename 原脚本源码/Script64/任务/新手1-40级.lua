-- 反编译自 dfz64.dll 内嵌字节码 0026bf4a（unluac 2025-12-23；仅供分析）
local m_script_name = "新手1-40级"
ScriptOnStart(m_script_name, false, false)
local strPath = g_public_dir .. "角色设置\\私有设置\\" .. g_self.name .. "\\练级设置.ini"
g_config.xsrw = {}
g_config.xsrw.max_level = ReadConfigText("设置", "练级等级", strPath)
local m_menpai = ReadConfigText("设置", "加入门派", strPath)
g_config.xsrw.other_mission = false
g_config.xsrw.not_card = false
CDG:InitFubenParam()
CDG.skill_attack = g_config.skill.shuaguai_gongji
CDG.attack = true
CDG.hp.cmp = 60
CDG.mp.cmp = 10
CDG.hp.petcmp = 30
local m_param = {}
m_param.max_level = HandleTextToNumber(g_config.xsrw.max_level, 0)
if m_param.max_level < 1 or m_param.max_level > 40 then
  m_param.max_level = 40
end
if g_config.xsrw.not_card then
  m_param.card = false
else
  m_param.card = true
end
if 9 == g_self.menpai or g_self.menpai < 0 then
  local tMenPai = {
    "少林",
    "明教",
    "丐帮",
    "武当",
    "峨嵋",
    "星宿",
    "天龙",
    "天山",
    "逍遥",
    "慕容",
    "唐门",
    "鬼谷",
    "桃花岛",
    "绝情谷",
    "恶人谷"
  }
  local tJoin = {}
  for i = 1, #tMenPai do
    if string.find(m_menpai, tMenPai[i], nil, true) then
      table.insert(tJoin, tMenPai[i])
    end
  end
  if 0 == #tJoin then
    PushColorMsg("未解析到正确的门派设置,在所有门派中随机！")
    tJoin = tMenPai
  end
  if #tJoin > 0 then
    math.randomseed(GetTickCount())
    local idx = math.random(1, #tJoin)
    m_menpai = tJoin[idx]
  end
else
  m_param.menpaiName = GetMenpaiNameByID(g_self.menpai)
end
m_param.other_mission = g_config.xsrw.other_mission
local m_UsherInfo = {
  {
    menpai = "少林",
    name = "慧易",
    x = 154,
    y = 129
  },
  {
    menpai = "明教",
    name = "石宝",
    x = 166,
    y = 138
  },
  {
    menpai = "丐帮",
    name = "简宁",
    x = 154,
    y = 133
  },
  {
    menpai = "武当",
    name = "张获",
    x = 154,
    y = 126
  },
  {
    menpai = "峨嵋",
    name = "路三娘",
    x = 154,
    y = 137
  },
  {
    menpai = "星宿",
    name = "海风子",
    x = 166,
    y = 131
  },
  {
    menpai = "天龙",
    name = "破贪",
    x = 166,
    y = 128
  },
  {
    menpai = "天山",
    name = "程青霜",
    x = 166,
    y = 135
  },
  {
    menpai = "逍遥",
    name = "澹台子羽",
    x = 166,
    y = 124
  },
  {
    menpai = "慕容",
    name = "慕容传",
    x = 154,
    y = 136
  },
  {
    menpai = "唐门",
    name = "唐昱",
    x = 166,
    y = 139
  },
  {
    menpai = "鬼谷",
    name = "杨渐",
    x = 153,
    y = 139
  },
  {
    menpai = "桃花岛",
    name = "黄时雨",
    x = 166,
    y = 142
  },
  {
    menpai = "绝情谷",
    name = "景言",
    x = 154,
    y = 142
  },
  {
    menpai = "恶人谷",
    name = "山风",
    x = 165,
    y = 143
  }
}
local m_shimen_npc = {
  {
    name = "慧方",
    x = 96,
    y = 83,
    sceneID = 9,
    menpaiID = 0,
    menpaiName = "少林"
  },
  {
    name = "林岩",
    x = 98,
    y = 105,
    sceneID = 11,
    menpaiID = 1,
    menpaiName = "明教"
  },
  {
    name = "洪通",
    x = 91,
    y = 77,
    sceneID = 10,
    menpaiID = 2,
    menpaiName = "丐帮"
  },
  {
    name = "张中行",
    x = 78,
    y = 95,
    sceneID = 12,
    menpaiID = 3,
    menpaiName = "武当"
  },
  {
    name = "孟龙",
    x = 96,
    y = 88,
    sceneID = 15,
    menpaiID = 4,
    menpaiName = "峨嵋"
  },
  {
    name = "王彦",
    x = 96,
    y = 92,
    sceneID = 16,
    menpaiID = 5,
    menpaiName = "星宿"
  },
  {
    name = "本凡",
    x = 95,
    y = 88,
    sceneID = 13,
    menpaiID = 6,
    menpaiName = "天龙"
  },
  {
    name = "符敏仪",
    x = 95,
    y = 60,
    sceneID = 17,
    menpaiID = 7,
    menpaiName = "天山"
  },
  {
    name = "秦观",
    x = 119,
    y = 152,
    sceneID = 14,
    menpaiID = 8,
    menpaiName = "逍遥"
  },
  {
    name = "慕容胜",
    x = 68,
    y = 127,
    sceneID = 284,
    menpaiID = 10,
    menpaiName = "慕容"
  },
  {
    name = "唐清秋",
    x = 100,
    y = 64,
    sceneID = 615,
    menpaiID = 11,
    menpaiName = "唐门"
  },
  {
    name = "王玄风",
    x = 96,
    y = 98,
    sceneID = 678,
    menpaiID = 12,
    menpaiName = "鬼谷"
  },
  {
    name = "萧声咽",
    x = 160,
    y = 72,
    sceneID = 731,
    menpaiID = 13,
    menpaiName = "桃花岛"
  },
  {
    name = "七叔",
    x = 245,
    y = 191,
    sceneID = 824,
    menpaiID = 14,
    menpaiName = "绝情谷"
  },
  {
    name = "岳老三",
    x = 180,
    y = 181,
    sceneID = 987,
    menpaiID = 15,
    menpaiName = "恶人谷"
  }
}

local function xs_GetPrize(nIndex)
  if IsInFubenScene() then
    return
  end
  PushDebugMessage("领取升级奖励:" .. nIndex)
  local strText = ""
  strText = fmt([[
            Clear_XSCRIPT()
                Set_XSCRIPT_Function_Name( "GetGiftsForLevelUp" );
                Set_XSCRIPT_ScriptID(892684);
                Set_XSCRIPT_Parameter( 0, %d );
                Set_XSCRIPT_ParamCount( 1 );
            Send_XSCRIPT()
        ]], nIndex)
  GetLuaValue(strText)
end

local function xs_CheckGetPrize()
  local nLevel = Player:GetDataInt("LEVEL")
  if 10 == nLevel or 20 == nLevel or 30 == nLevel or 35 == nLevel or 40 == nLevel then
    if nLevel >= 40 then
      xs_GetPrize(5)
    end
    if nLevel >= 35 then
      xs_GetPrize(4)
    end
    if nLevel >= 30 then
      xs_GetPrize(3)
    end
    if nLevel >= 20 then
      xs_GetPrize(2)
    end
    xs_GetPrize(1)
  end
end

local function xs_LevelUp()
  local nLevel, nUp = GetLuaValue("return meLevelUp(" .. m_param.max_level .. ");", "nn")
  if 1 == nUp then
    Sleep(300)
    xs_CheckGetPrize()
  end
  return nLevel, nUp
end

local function mp_get_shimen_npc()
  local npc = {}
  g_self.menpai = Player:GetDataInt("MEMPAI")
  local menpai = GetMenpaiNameByID(g_self.menpai)
  for i = 1, #m_shimen_npc do
    if m_shimen_npc[i].menpaiName == menpai then
      return m_shimen_npc[i]
    end
  end
  return npc
end

local function xs_mp_get_fbpos()
  local fubenPos = {
    [552] = {
      {x = 95, y = 130},
      {x = 111, y = 97},
      {x = 80, y = 95},
      {x = 69, y = 86},
      {x = 87, y = 82},
      {x = 95, y = 72}
    },
    [554] = {
      {x = 97, y = 139},
      {x = 98, y = 111},
      {x = 98, y = 89},
      {x = 99, y = 73},
      {x = 98, y = 56},
      {x = 97, y = 43}
    },
    [553] = {
      {x = 72, y = 101},
      {x = 43, y = 107},
      {x = 46, y = 82},
      {x = 43, y = 60},
      {x = 60, y = 52},
      {x = 80, y = 61}
    },
    [555] = {
      {x = 96, y = 167},
      {x = 85, y = 137},
      {x = 76, y = 115},
      {x = 77, y = 84},
      {x = 51, y = 96},
      {x = 45, y = 60},
      {x = 87, y = 57}
    },
    [558] = {
      {x = 89, y = 137},
      {x = 89, y = 127},
      {x = 96, y = 88},
      {x = 111, y = 92},
      {x = 112, y = 107},
      {x = 77, y = 94},
      {x = 63, y = 108},
      {x = 95, y = 67},
      {x = 94, y = 47},
      {x = 95, y = 35}
    },
    [559] = {
      {x = 95, y = 140},
      {x = 95, y = 123},
      {x = 95, y = 94},
      {x = 96, y = 74},
      {x = 68, y = 57},
      {x = 95, y = 52}
    },
    [556] = {
      {x = 95, y = 115},
      {x = 113, y = 110},
      {x = 72, y = 103},
      {x = 95, y = 89},
      {x = 116, y = 71},
      {x = 141, y = 57},
      {x = 78, y = 54},
      {x = 63, y = 73},
      {x = 42, y = 52},
      {x = 94, y = 37},
      {x = 114, y = 36}
    },
    [560] = {
      {x = 80, y = 120},
      {x = 111, y = 122},
      {x = 71, y = 102},
      {x = 95, y = 100},
      {x = 113, y = 96},
      {x = 93, y = 80},
      {x = 64, y = 60},
      {x = 66, y = 97},
      {x = 73, y = 49},
      {x = 92, y = 49},
      {x = 115, y = 48},
      {x = 99, y = 39}
    },
    [557] = {
      {x = 49, y = 126},
      {x = 53, y = 143},
      {x = 69, y = 143},
      {x = 106, y = 147},
      {x = 132, y = 124},
      {x = 118, y = 89},
      {x = 107, y = 147},
      {x = 59, y = 61},
      {x = 142, y = 58}
    },
    [561] = {
      {x = 141, y = 158},
      {x = 141, y = 142},
      {x = 145, y = 123},
      {x = 161, y = 92},
      {x = 161, y = 52},
      {x = 128, y = 37},
      {x = 58, y = 28},
      {x = 53, y = 63},
      {x = 71, y = 114},
      {x = 68, y = 124},
      {x = 86, y = 135}
    },
    [628] = {
      {x = 164, y = 146},
      {x = 168, y = 124},
      {x = 128, y = 67},
      {x = 100, y = 67},
      {x = 41, y = 72},
      {x = 72, y = 40}
    },
    [683] = {
      {x = 116, y = 152},
      {x = 148, y = 143},
      {x = 148, y = 122},
      {x = 148, y = 108},
      {x = 152, y = 88},
      {x = 144, y = 68},
      {x = 114, y = 73},
      {x = 95, y = 61}
    },
    [739] = {
      {x = 235, y = 185},
      {x = 214, y = 179},
      {x = 185, y = 176},
      {x = 164, y = 155},
      {x = 160, y = 115},
      {x = 120, y = 111},
      {x = 115, y = 92},
      {x = 159, y = 76},
      {x = 160, y = 61}
    },
    [826] = {
      {x = 172, y = 329},
      {x = 175, y = 340},
      {x = 204, y = 316},
      {x = 230, y = 321},
      {x = 240, y = 316},
      {x = 255, y = 312},
      {x = 255, y = 293},
      {x = 255, y = 260},
      {x = 255, y = 208},
      {x = 255, y = 190},
      {x = 255, y = 165}
    },
    [1000] = {
      {x = 32, y = 195},
      {x = 44, y = 144},
      {x = 41, y = 115},
      {x = 65, y = 88},
      {x = 85, y = 98},
      {x = 131, y = 109},
      {x = 108, y = 58},
      {x = 82, y = 44}
    }
  }
  local fubenBoss = {
    [552] = {
      {x = 95, y = 72}
    },
    [554] = {
      {x = 97, y = 46}
    },
    [553] = {
      {x = 69, y = 67}
    },
    [555] = {
      {x = 87, y = 55}
    },
    [558] = {
      {x = 95, y = 38}
    },
    [559] = {
      {x = 96, y = 46}
    },
    [556] = {
      {x = 95, y = 38}
    },
    [560] = {
      {x = 94, y = 42}
    },
    [557] = {
      {x = 123, y = 89}
    },
    [561] = {
      {x = 34, y = 164}
    },
    [628] = {
      {x = 72, y = 40}
    },
    [683] = {
      {x = 95, y = 61}
    },
    [739] = {
      {x = 160, y = 61}
    },
    [826] = {
      {x = 255, y = 165}
    },
    [1000] = {
      {x = 82, y = 44}
    }
  }
  local nSceneID = GetSceneID()
  return fubenPos[nSceneID], fubenBoss[nSceneID]
end

local function xs_drls_getStage()
  return GetLuaValue([[
	
            setmetatable(_G, { __index = Sancai_s_Env})
            if not this:IsVisible() then
                this:Show()
            end
            if Sancai_s_BK1:IsVisible() then
                return 1
            elseif Sancai_s_BK2:IsVisible() then
                return 2
            elseif Sancai_s_BK3:IsVisible() then
                return 3
            end
            return 0
    ]], "n")
end

local function xs_drls_stage1_num()
  local strText = [[
            setmetatable(_G, {__index=Sancai_s_Env});
            local songbing = Sancai_s_Image1Info2:GetProperty("Text")
            local fudutong = Sancai_s_Image1Info3:GetProperty("Text")
            local feilei = Sancai_s_Image1Info4:GetProperty("Text")
            local dutong = Sancai_s_Image1Info5:GetProperty("Text")
            local yudu = Sancai_s_Image1Info6:GetProperty("Text")

            if songbing == nil or songbing == "" then 
                songbing = "nil"
            end
            if fudutong == nil or fudutong == "" then 
                fudutong = "nil"
            end
            if feilei == nil or feilei == "" then 
                feilei = "nil"
            end
            if dutong == nil or dutong == "" then 
                dutong = "nil"
            end
            if yudu == nil or yudu == "" then 
                yudu = "nil"
            end
            return songbing,fudutong,feilei,dutong,yudu
        ]]
  local strSongBing, strFuDuTong, strFeiLei, strDuTong, strYuDu = GetLuaValue(strText, "sssss")
  _, _, strSongBing = string.find(strSongBing, "(%d+)/10")
  _, _, strFuDuTong = string.find(strFuDuTong, "(%d)/1")
  _, _, strFeiLei = string.find(strFeiLei, "(%d)/4")
  _, _, strDuTong = string.find(strDuTong, "(%d)/1")
  _, _, strYuDu = string.find(strYuDu, "(%d)/1")
  strSongBing = tonumber(strSongBing) or -1
  strFuDuTong = tonumber(strFuDuTong) or -1
  strFeiLei = tonumber(strFeiLei) or -1
  strDuTong = tonumber(strDuTong) or -1
  strYuDu = tonumber(strYuDu) or -1
  return strSongBing, strFuDuTong, strFeiLei, strDuTong, strYuDu
end

local function xs_drls_stage2_num()
  local strText = [[
            setmetatable(_G, {__index=Sancai_s_Env});
            local yexiong = Sancai_s_Image2Info2:GetProperty("Text")
            local hongxiongwang = Sancai_s_Image2Info3:GetProperty("Text")
           
            if yexiong == nil or yexiong == "" then 
                yexiong = "nil"
            end
            if hongxiongwang == nil or hongxiongwang == "" then 
                hongxiongwang = "nil"
            end
  
            return yexiong,hongxiongwang
        ]]
  local strYeXiong, strHongXiongWang = GetLuaValue(strText, "ss")
  _, _, strYeXiong = string.find(strYeXiong, "(%d+)/10")
  _, _, strHongXiongWang = string.find(strHongXiongWang, "(%d)/1")
  strYeXiong = tonumber(strYeXiong) or -1
  strHongXiongWang = tonumber(strHongXiongWang) or -1
  return strYeXiong, strHongXiongWang
end

local function xs_getpos_jf()
  local pos = {}
  local curStage = xs_drls_getStage()
  if 1 == curStage then
    local songbing, fudutong, feilei, dutong, yudu = xs_drls_stage1_num()
    if songbing < 10 then
      pos = {
        {x = 184, y = 153},
        {x = 197, y = 140},
        {x = 197, y = 123},
        {x = 172, y = 137},
        {x = 170, y = 119}
      }
    elseif 0 == fudutong then
      pos = {
        {x = 181, y = 123}
      }
    elseif feilei < 4 then
      pos = {
        {x = 199, y = 105},
        {x = 204, y = 122}
      }
    elseif 0 == dutong then
      pos = {
        {x = 194, y = 54}
      }
    elseif 0 == yudu then
      pos = {
        {x = 194, y = 54}
      }
    else
      PushDebugMessage("单人老三副本：未知阶段1")
      Sleep(1000)
    end
  elseif 2 == curStage then
    local yexiong, hongxiongwang = xs_drls_stage2_num()
    if yexiong < 10 then
      pos = {
        {x = 144, y = 67},
        {x = 138, y = 76},
        {x = 134, y = 57},
        {x = 120, y = 46},
        {x = 102, y = 51},
        {x = 89, y = 42},
        {x = 73, y = 41},
        {x = 67, y = 39},
        {x = 64, y = 66},
        {x = 61, y = 50},
        {x = 56, y = 41}
      }
    elseif 0 == hongxiongwang then
      pos = {
        {x = 50, y = 43}
      }
    else
      PushDebugMessage("单人老三副本：未知阶段2")
      Sleep(1000)
    end
  elseif 3 == curStage then
    pos = {
      {x = 88, y = 166},
      {x = 86, y = 176},
      {x = 77, y = 184},
      {x = 66, y = 176},
      {x = 45, y = 175},
      {x = 52, y = 188}
    }
  else
    PushDebugMessage("单人老三副本:未知 " .. curStage)
  end
  return pos
end

local function xs_SetActionPet(bEat)
  local szText = [[
            local cmp = 0
            local num = 0
            local nIndex = -1
            local nGUID = -1
            for i = 0, 9 do
                if Pet:IsPresent(i) then
                    num = num + 1
                    local ll = Pet:GetStrAptitude(i)
                    local lq = Pet:GetIntAptitude(i)
                    if ll > cmp then
                        cmp = ll
                        nIndex = i
                        _,nGUID = Pet:GetGUID(i)
                    end
                    if lq > cmp then
                        cmp = lq
                        nIndex = i
                        _,nGUID = Pet:GetGUID(i)
                    end
                end
            end
            return nIndex,nGUID ,num   
        ]]
  local nIndex, nGUID, num = GetLuaValue(szText, "nnn")
  if -1 ~= nIndex and -1 ~= nGUID and CDG.pet1.GUID ~= nGUID then
    CDG.pet1.GUID = nGUID
    CDG.pet1.OldGUID = nGUID
  end
  if bEat and num > 1 then
    local nTick = GetTickCount()
    while GetTickCount() - nTick < 30000 and Bag:GetItemCount("珍兽舍利子") > 0 do
      PushDebugMessage("自动使用珍兽舍利子")
      if CDG:checkPetPlay(CDG.pet1.GUID) then
        Bag:UseItemByName("珍兽舍利子", 1000)
        SelectServerQuest_Bn1Click()
        goto lbl_60
        break
      end
      ::lbl_60::
      Sleep(500)
    end
  end
end

local function xs_RefreshSkill()
  if #CDG.skill_attack > 0 then
    return
  end
  Player:IsJinGong()
  local menpai = GetMenpaiNameByID(g_self.menpai)
  local tSKill = {}
  tSKill.少林 = {
    state = {"弥勒护身"},
    attack = {
      "摩诃无量",
      "一拍两散",
      "金刚伏魔圈"
    }
  }
  tSKill["明教"] = {
    state = {"葵花神力"},
    attack = {
      "水淹七军",
      "火烧赤壁",
      "血战八方"
    }
  }
  tSKill["丐帮"] = {
    state = {"如影随形"},
    attack = {"青龙出水", "震惊百里"}
  }
  tSKill["武当"] = {
    state = {"犀牛望月"},
    attack = {"仙人指路", "玉女穿梭"}
  }
  tSKill["峨嵋"] = {
    state = {"坐怀不乱"},
    attack = {"障眼法"}
  }
  tSKill.星宿 = {
    state = {"百毒不侵"},
    attack = {"青蛇毒掌", "冰蚕毒掌"}
  }
  tSKill.天龙 = {
    state = {"正气浩然"},
    attack = {"欲擒故纵", "雪拥蓝关"}
  }
  tSKill["天山"] = {
    state = {"冰肌玉骨"},
    attack = {
      "雪花六出",
      "梅花三弄",
      "鹰击长空"
    }
  }
  tSKill["逍遥"] = {
    state = {"墨守成规"},
    attack = {"溪山行旅"}
  }
  tSKill["慕容"] = {
    state = {"天增岁月"},
    attack = {
      "重云掩日",
      "剑锁江山",
      "气定六合"
    }
  }
  tSKill.唐门 = {
    state = {"洗经伐脉"},
    attack = {"一叶障目"}
  }
  tSKill["鬼谷"] = {
    state = {"造化三生"},
    attack = {"风云反覆", "未老先衰"}
  }
  tSKill["桃花岛"] = {
    state = {"郑卫之曲"},
    attack = {"日月之明", "罪人不怨"}
  }
  tSKill["绝情谷"] = {
    state = {"魂飞目断"},
    attack = {"荡千军"}
  }
  tSKill["恶人谷"] = {
    state = {"银钩走蝎"},
    attack = {"剔魂削骨", "炉上青烟"}
  }
  local skill = tSKill[menpai]
  if skill then
    Skill:RefreshSkill()
    if 0 == #CDG.skill_attack then
      for i = 1, #skill.attack do
        local tmp = {
          data = 0,
          text = skill.attack[i]
        }
        table.insert(CDG.skill_attack, tmp)
      end
    end
    if 0 == #CDG.skill_state then
      for i = 1, #skill.state do
        local tmp = {
          data = 0,
          text = skill.state[i]
        }
        table.insert(CDG.skill_state, tmp)
      end
    end
  end
end

local function xs_CheckCard()
  if m_param.card then
    if Player:GetDataInt("LEVEL") > 30 then
      return
    end
    local nTick = GetTickCount()
    while GetTickCount() - nTick < 30000 do
      DebugStr("正在检查激活至尊武圣卡")
      GetLuaValue("NewUserCard('TLBB8888',2084,1)")
      Sleep(2000)
      local strText = GetNPCEventList_Item(0)
      if string.find(strText, "#{XWSK_140923_38", nil, true) or string.find(strText, "#{ZZJHK_130319_2", nil, true) then
        break
      end
    end
  end
end

local function xs_UseBagItem()
  local tObj = Bag:FindItem_vague("坐骑：", 2)
  local tObj2 = Bag:FindItem_vague("翅膀：", 2)
  TableInsertTable_arr(tObj, "index", tObj2)
  for i = 1, #tObj do
    local tmp = tObj[i]
    Bag:ItemBtnClicked(tmp.index)
    Sleep(300)
    MessageBox_Self_OK_Clicked(600)
  end
  Bag:UseItemByName("珍兽蛋：花仙子")
  Bag:UseItemByName("大还丹")
  Bag:UseItemByName("璀璨之衣")
  Bag:UseItemByName("飞蝗石")
  Bag:UseItemByName("清荷鱼浅")
  local nNum = GetLuaValue("return DataPool:GetBaseBag_Num();", "n")
  if 20 == nNum then
    Bag:UseItemByName_click("麻制囊")
  end
  local nNum = GetLuaValue("return DataPool:GetMatBag_Num();", "n")
  if 20 == nNum then
    Bag:UseItemByName_click("榆木箱")
  end
  local tItem = Bag:FindItemInfo("绵制囊")
  if #tItem > 0 then
    Bag:ItemBtnClicked(tItem[1].index)
    Sleep(500)
  end
  tItem = Bag:FindItemInfo("楠木箱")
  if #tItem > 0 then
    Bag:ItemBtnClicked(tItem[1].index)
    Sleep(500)
  end
end

local function xs_DeleteBag()
  if CheckMibao(nil) then
    local tAll = Bag:EnumAllObj()
    for i = 1, #tAll do
      local tmp = tAll[i]
      if tmp.name == "采香丸" or tmp.name == "归灵丸" or tmp.name == "麻制囊" or tmp.name == "榆木箱" then
        DiscardBagItem(tmp.index, 500)
      elseif string.find(" 刀斧类 枪棒类 单短类 双短类 扇类 环类 弩类 长杖类 箫剑类 刀组类 冷镰类 腰带 护腕 护符 护肩 戒指 鞋 手套 帽子 项链 衣服 ", " " .. tmp.class .. " ", nil, true) and tmp.xing <= 3 then
        DiscardBagItem(tmp.index, 500)
      end
    end
  end
end

local function xs_ClearBag()
  Bag_SellItem(" 青铜古币 财富银币 熊猫金币 奇物 中级皮毛 铸造类材 缝纫类材 工艺材料 初级皮毛 制药材料 ")
end

local function xs_CardReward()
  GoToSceneNPC("都大爽", 154, 171, 2)
  xs_CheckCard()
  xs_DeleteBag()
  Dismount()
  local nTick = GetTickCount()
  while GetTickCount() - nTick < 60000 do
    GoToSceneNPC("都大爽", 154, 171, 2)
    Sleep(500)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_02}", 1, 600)
    local strText = GetNPCEventList_Item(0)
    if "#{CFKYH_120723_83}" == strText and m_param.max_level > 30 and m_param.card == false then
      m_param.card = true
      return false
    end
    QuestFrameOptionClicked_Item("#{GHZZ_181018_01}", 1, 600)
    QuestFrameOptionClicked_Item("至尊武圣卡", 1, 600)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_27}", 1, 600)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_29}", 1, 600)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_30}", 1, 600)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_31}", 1, 600)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_32}", 1, 600)
    QuestFrameOptionClicked_Item("#{CFKYH_120723_33}", 1, 600)
    Sleep(200)
    local strAll = GetNPCEventListAllItem()
    if string.find(strAll, "#{FXHZ_xml_XX(", nil, true) then
      local bHave = false
      if QuestFrameOptionClicked_Item("#{FXHZ_xml_XX(02)}10#{FXHZ_xml_XX(03)}", 1, 1000) then
        bHave = true
      end
      if QuestFrameOptionClicked_Item("#{FXHZ_xml_XX(02)}15#{FXHZ_xml_XX(03)}", 1, 1000) then
        bHave = true
      end
      if QuestFrameOptionClicked_Item("#{FXHZ_xml_XX(02)}25#{FXHZ_xml_XX(03)}", 1, 1000) then
        bHave = true
      end
      if QuestFrameOptionClicked_Item("#{FXHZ_xml_XX(02)}30#{FXHZ_xml_XX(03)}", 1, 1000) then
        bHave = true
      end
      if false == bHave then
        break
      end
    end
    Sleep(200)
    DebugStr("正在领取财富卡奖励")
    for i = 1, 3 do
      if IsWindowVisible("FreshManMission_JLYH", "FreshManMission_JLYH_OK_Clicked()") then
        Sleep(300)
      end
    end
    xs_UseBagItem()
  end
  for i = 1, 3 do
    xs_LevelUp()
  end
  xs_UseBagItem()
  xs_DeleteBag()
  xs_SetActionPet(true)
  Pet:AddtAttribute()
  xs_ClearBag()
  return true
end

local function xs_CheckAll()
  local szText = [[
        setmetatable(_G, {__index = FreshmanWatch_Env})
        if this:IsVisible() then
            if FreshmanWatch_Time_Text:GetText() == "" then
                FreshmanWatch_Bn2Click()
                return 1
            end
        end
        return 0
    ]]
  if GetLuaValue(szText, "b") then
    Sleep(200)
  end
  if IsWindowVisible("FreshManMission_JLYH", "FreshManMission_JLYH_OK_Clicked()") then
    Sleep(200)
  else
    xs_DeleteBag()
  end
  MessageBox_Self_OK_Clicked(500)
  xs_UseBagItem()
  xs_CheckGetPrize()
  xs_SetActionPet(false)
  Pet:AddtAttribute()
  for i = 1, 3 do
    xs_LevelUp()
  end
  xs_RefreshSkill()
  CloseWindow("PlayerGuide")
end

local function xs_submit_zhou()
  local mis = {
    "天师的期待(1)",
    "天师的期待(2)",
    "天师的期待(3)",
    "天师的期待(4)",
    "天师的期待(5)",
    "天师的期待(6)",
    "回报天师(1)",
    "#{YD_100806_120}",
    "#{YD_100806_128}",
    "十年又十年"
  }
  for i = 1, #mis do
    local nComplete, nIndex = GetMissionVariableByName_Item(mis[i], 0)
    if 1 == nComplete then
      GoToSceneNPC("周天师", 256, 273, LUOYANG_ID)
      mission_complete_accept(mis[i], true, true, false)
      return false
    elseif -1 ~= nIndex and "十年又十年" == mis[i] then
      GoToSceneNPC("周天师", 256, 273, LUOYANG_ID)
      mission_complete_accept(mis[i], true, true, false)
      return false
    end
  end
  return true
end

local function xs_CaiJi(aItemName)
  local actionNum = 0
  local tObj = Enum2XByName(aItemName, {
    1,
    0,
    0,
    0
  }, nil, 1, 0)
  if #tObj > 0 then
    local tTarget = tObj[1]
    actionNum = actionNum + 1
    if tTarget.dst > 3 then
      GoToScene(tTarget.x, tTarget.y, GetSceneID())
    else
      RunTo(tTarget.x, tTarget.y, 0, 1000)
    end
    Dismount()
    Sleep(500)
    if tTarget.name == "溶尸草" then
      Skill.CUseSkillByID(3681, tTarget.id, -1, -1)
    elseif tTarget.name == "养心草" then
      Skill.CUseSkillByID(3682, tTarget.id, -1, -1)
    elseif tTarget.name == "情人草" then
      Skill.CUseSkillByID(3683, tTarget.id, -1, -1)
    else
      PushColorMsg("不支持的物品")
    end
    Sleep(1500)
    PlayerStateTimeOut(8, 6)
    PlayerStateTimeOut(5, 6)
    Sleep(200)
    GetLuaValue("if IsWindowShow('LootPacket')==true then setmetatable(_G, {__index =LootPacket_Env});LootPacket_Collect_Clicked();LootPacket_Button_Close();end;")
    Sleep(200)
  end
  return actionNum
end

local function ZhuXianAttack(aParam)
  aParam.attackMode = "打死换怪"
  mission_attack_mode_1(aParam)
end

local function ZhuXianComplete(aParam)
  mission_complete_talk_npc(aParam)
end

local MissionTable = {
  function()
    local comp = {
      x = 187,
      y = 205,
      sceneID = 6,
      use_horse = false,
      name = "受伤的山民"
    }
    local misName = "缘起无量"
    local mission = {
      name = misName,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 187,
      y = 205,
      sceneID = 6,
      use_horse = false,
      name = "受伤的山民"
    }
    local comp = {
      x = 194,
      y = 174,
      sceneID = 6,
      use_horse = false,
      name = "遇险的钟灵"
    }
    local misName = "路见不平"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 187, y = 205}
        },
        use_horse = false,
        sceneName = "无量山",
        targetName = "神农帮喽啰"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 194,
      y = 174,
      sceneID = 6,
      use_horse = false,
      name = "遇险的钟灵"
    }
    local comp = {
      x = 238,
      y = 133,
      sceneID = 6,
      use_horse = false,
      name = "剑湖宫的钟灵"
    }
    local misName = "武功招式"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 216, y = 156}
        },
        use_horse = false,
        sceneName = "无量山",
        targetName = "神农帮精英"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 238,
      y = 133,
      sceneID = 6,
      use_horse = false,
      name = "剑湖宫的钟灵"
    }
    local comp = apt
    local misName = "并肩作战"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 257, y = 130}
        },
        use_horse = false,
        sceneName = "无量山",
        targetName = "神农帮堂主"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 238,
      y = 133,
      sceneID = 6,
      use_horse = false,
      name = "剑湖宫的钟灵"
    }
    local comp = {
      x = 276,
      y = 94,
      sceneID = 6,
      use_horse = false,
      name = "木婉清"
    }
    local misName = "寡不敌众"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 276,
      y = 94,
      sceneID = 6,
      name = "木婉清"
    }
    local comp = apt
    local misName = "无量玉壁"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function(_param)
        while true do
          DebugStr("执行任务:无量玉壁")
          GoToScene(204, 59, 6, 1)
          local tObj = Enum2XByName("不起眼的土堆", {
            1,
            0,
            0,
            0
          }, nil, nil, 0)
          if #tObj > 0 then
            Dismount()
            Skill.CUseSkillByID(3, tObj[1].id, -1, -1)
            Sleep(1000)
          end
          local nComplete, nIndex = GetMissionVariableByName_Item("#{XSLC_130831_63}", 0)
          if 1 == nComplete or -1 == nIndex then
            break
          end
          Sleep(200)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 276,
      y = 94,
      sceneID = 6,
      name = "木婉清"
    }
    local comp = {
      x = 209,
      y = 106,
      sceneID = 6,
      name = "被俘的段誉"
    }
    local misName = "尔虞我诈"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function(_param)
        while true do
          DebugStr("执行任务:" .. misName)
          GoToSceneNPC("司空玄", 200, 104, 6, nil, false)
          Sleep(500)
          Dismount()
          if -1 == Player:GetBuff("乔装") then
            Bag:UseItemByName("灵鹫圣使的衣帽", 500, Bag:EnumRenWuItem())
          end
          Sleep(500)
          QuestFrameOptionClicked_Item("#{XSLC_130831_109}", 1, 500)
          local nComplete, nIndex = GetMissionVariableByName_Item("#{XSLC_130831_81}", 0)
          if 1 == nComplete or -1 == nIndex then
            break
          end
          Sleep(200)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 209,
      y = 106,
      sceneID = 6,
      name = "被俘的段誉"
    }
    local comp = {
      x = 63,
      y = 172,
      sceneID = 6,
      name = "城外的段誉"
    }
    local misName = "城外相会"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 63,
      y = 172,
      sceneID = 6,
      name = "城外的段誉"
    }
    local comp = {
      x = 271,
      y = 133,
      sceneID = 2,
      name = "云飘飘"
    }
    local misName = "珍兽商店"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 271,
      y = 133,
      sceneID = 2,
      name = "云飘飘"
    }
    local comp = {
      x = 219,
      y = 123,
      sceneID = 2,
      name = "蒲良"
    }
    local misName = "武器商店"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 219,
      y = 123,
      sceneID = 2,
      name = "蒲良"
    }
    local comp = {
      x = 254,
      y = 174,
      sceneID = 2,
      name = "黄公道"
    }
    local misName = "防具商店"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 254,
      y = 174,
      sceneID = 2,
      name = "黄公道"
    }
    local comp = {
      x = 160,
      y = 159,
      sceneID = 2,
      name = "赵天师"
    }
    local misName = "拜访天师"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 160,
      y = 159,
      sceneID = 2,
      name = "赵天师"
    }
    local misName = "加入门派"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        local idx = -1
        for i = 1, #m_UsherInfo do
          if m_UsherInfo[i].menpai == m_param.menpaiName then
            idx = i
            break
          end
        end
        local npc = m_UsherInfo[idx]
        if nil == npc then
          PushColorMsg("加入的门派名称设置有误")
          return
        end
        GoToSceneNPC(npc.name, npc.x, npc.y, 2)
        PlayerStateTimeOut(2, 3)
        QuestFrameOptionClicked_Item("加入门派", 3, 600)
        if m_param.menpaiName == "唐门" then
          QuestFrameOptionClicked_Item("#{XMPTM_130123_116}", 1, 600)
        elseif m_param.menpaiName == "桃花岛" then
          QuestFrameOptionClicked_Item("#{THDRZ_190613_41}", 1, 600)
        elseif m_param.menpaiName == "绝情谷" then
          QuestFrameOptionClicked_Item("#{HMRZ_210622_39}", 1, 600)
        elseif m_param.menpaiName == "恶人谷" then
          QuestFrameOptionClicked_Item("#{XKDRZ_240619_39}", 1, 600)
        else
          QuestFrameOptionClicked_Item("我确定要", 3, 600)
        end
        QuestFrameMissionComplete()
      end,
      param_complete = nil,
      OnComplete = function()
        Player:IsJinGong()
        local strName = GetMenpaiNameByID(g_self.menpai)
        for i = 1, #m_UsherInfo do
          local npc = m_UsherInfo[i]
          if npc.menpai == strName then
            GoToSceneNPC(npc.name, npc.x, npc.y, 2)
            mission_complete_accept("#{XSLC_130831_177}", false, true, false)
            break
          end
        end
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 256,
      y = 273,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 252,
      y = 144,
      sceneID = 8,
      name = "杨文广"
    }
    local misName = "奔赴敦煌"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 252,
      y = 144,
      sceneID = 8,
      name = "杨文广"
    }
    local comp = {
      x = 258,
      y = 163,
      sceneID = 8,
      name = "张全祥"
    }
    local misName = "救治伤患"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 258,
      y = 163,
      sceneID = 8,
      name = "张全祥"
    }
    local comp = {
      x = 258,
      y = 163,
      sceneID = 8,
      name = "张全祥"
    }
    local misName = "月牙泉水"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        GoToScene(257, 178, 8, 1)
        Sleep(500)
        Dismount()
        Sleep(500)
        Bag:UseItemByName("空竹筒", 800, Bag:EnumRenWuItem())
        PlayerStateTimeOut(5, 5)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 258,
      y = 163,
      sceneID = 8,
      name = "张全祥"
    }
    local comp = apt
    local misName = "驱逐群狼"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 256, y = 178}
        },
        sceneName = "敦煌",
        targetName = "沙坡狼"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 258,
      y = 163,
      sceneID = 8,
      name = "张全祥"
    }
    local comp = {
      x = 141,
      y = 126,
      sceneID = 8,
      name = "吴长风"
    }
    local misName = "火线支援"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 141,
      y = 126,
      sceneID = 8,
      name = "吴长风"
    }
    local comp = apt
    local misName = "牛刀小试"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 141, y = 126},
          {x = 125, y = 111}
        },
        sceneName = "敦煌",
        targetName = "西夏士兵"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 141,
      y = 126,
      sceneID = 8,
      name = "吴长风"
    }
    local comp = apt
    local misName = "乔装准备"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        local nIndex, idMission, idScript = GetPlayerMission_Item("#{DHRW_130904_232}")
        if -1 ~= nIndex then
          local item = {
            {
              x = 98,
              y = 136,
              name = "西夏士兵的头盔"
            },
            {
              x = 87,
              y = 144,
              name = "西夏士兵的铠甲"
            },
            {
              x = 107,
              y = 146,
              name = "西夏士兵的长刀"
            }
          }
          for i = 1, 3 do
            local nParam = GetMissionVariable(nIndex, i)
            if 0 == nParam then
              GoToScene(item[i].x, item[i].y, 8)
              Sleep(500)
              Dismount()
              local tObj = Enum2XByName(item[i].name, {
                1,
                0,
                0,
                0
              }, nil, nil, 0)
              if #tObj > 0 then
                Skill.CUseSkillByID(3, tObj[1].id, -1, -1)
                Sleep(1000)
                PlayerStateTimeOut(5, 5)
              end
              break
            end
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
      x = 141,
      y = 126,
      sceneID = 8,
      name = "吴长风"
    }
    local comp = {
      x = 139,
      y = 232,
      sceneID = 8,
      name = "奚三祁",
      use_horse = false
    }
    local misName = "深入敌营"
    local mission = {
      name = misName,
      option = {
        "#{DHRW_130904_233}",
        "#{DHRW_130904_142}",
        "#{DHRW_130904_144}",
        "#{DHRW_130904_146}"
      },
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function(_param)
        if -1 == Player:GetBuff("变身为西夏士兵") then
          Bag:UseItemByName("西夏士兵的服装", 500, Bag:EnumRenWuItem())
        end
        ZhuXianComplete(_param)
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 139,
      y = 232,
      sceneID = 8,
      name = "奚三祁"
    }
    local comp = apt
    local misName = "虎口夺药"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 139, y = 232},
          {x = 139, y = 245}
        },
        sceneName = "敦煌",
        targetName = "一品堂前锋"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 139,
      y = 232,
      sceneID = 8,
      name = "奚三祁"
    }
    local comp = apt
    local misName = "还施彼身"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        GoToScene(187, 248, 8, 1)
        Sleep(500)
        Dismount()
        Bag:UseItemByName("蛇毒", 500, Bag:EnumRenWuItem())
        PlayerStateTimeOut(5, 5)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 139,
      y = 232,
      sceneID = 8,
      name = "奚三祁"
    }
    local comp = apt
    local misName = "焚毁粮草"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = nil,
      OnAction = function()
        GoToScene(176, 270, 8, 1)
        Sleep(500)
        Dismount()
        Bag:UseItemByName("火石", 500, Bag:EnumRenWuItem())
        PlayerStateTimeOut(5, 5)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 139,
      y = 232,
      sceneID = 8,
      name = "奚三祁"
    }
    local comp = apt
    local misName = "破坏弩车"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 166, y = 246}
        },
        sceneName = "敦煌",
        targetName = "弩车"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 139,
      y = 232,
      sceneID = 8,
      name = "奚三祁"
    }
    local comp = {
      x = 141,
      y = 126,
      sceneID = 8,
      name = "吴长风"
    }
    local misName = "刺杀大将"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 94, y = 211}
        },
        sceneName = "敦煌",
        targetName = "李重烈"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 141,
      y = 126,
      sceneID = 8,
      name = "吴长风"
    }
    local comp = {
      x = 252,
      y = 144,
      sceneID = 8,
      name = "杨文广"
    }
    local misName = "首战告捷"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 252,
      y = 144,
      sceneID = 8,
      name = "杨文广"
    }
    local comp = {
      x = 255,
      y = 372,
      sceneID = LUOYANG_ID,
      name = "韩银叶"
    }
    local misName = "洛阳游医"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 255,
      y = 372,
      sceneID = LUOYANG_ID,
      name = "韩银叶"
    }
    local comp = {
      x = 168,
      y = 217,
      sceneID = 3,
      name = "空闻大师"
    }
    local misName = "惊闻变故"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 168,
      y = 217,
      sceneID = 3,
      name = "空闻大师"
    }
    local comp = apt
    local misName = "采集草药"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToScene(183, 183, 3, 3)
        xs_CaiJi("养心草")
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 168,
      y = 217,
      sceneID = 3,
      name = "空闻大师"
    }
    local comp = apt
    local misName = "收集狼血"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 183, y = 183}
        },
        sceneName = "嵩山",
        targetName = "颍水狼"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 168,
      y = 217,
      sceneID = 3,
      name = "空闻大师"
    }
    local comp = apt
    local misName = "熬制良药"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if Bag:GetItemCount("伤药", nil, nil, Bag:EnumRenWuItem()) > 0 then
          GoToScene(168, 216, 3, 1)
          Sleep(500)
          Dismount()
          Sleep(500)
          Bag:UseItemByName("伤药", 500, Bag:EnumRenWuItem())
          PlayerStateTimeOut(5, 8)
        else
          GoToSceneNPC("陶土罐", 166, 200, 3)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{SSCJ_130828_86}", 1, 500)
          QuestFrameOptionClicked_Item("#{SSCJ_130828_89}", 1, 500)
          QuestFrameOptionClicked_Item("#{SSCJ_130828_91}", 1, 500)
          QuestFrameOptionClicked_Item("#{SSCJ_130828_95}", 1, 500)
          QuestFrameOptionClicked_Item("#{SSCJ_130828_97}", 1, 500)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 168,
      y = 217,
      sceneID = 3,
      name = "空闻大师"
    }
    local comp = {
      x = 63,
      y = 136,
      sceneID = 3,
      name = "林影儿"
    }
    local misName = "解救少女"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 86, y = 117}
        },
        sceneName = "嵩山",
        targetName = "衣衫褴褛的恶汉"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 63,
      y = 136,
      sceneID = 3,
      name = "林影儿"
    }
    local comp = {
      x = 60,
      y = 128,
      sceneID = 3,
      name = "马三"
    }
    local misName = "真真假假"
    local mission = {
      name = misName,
      option = {
        "#{SSCJ_130828_298}",
        "#{SSCJ_130828_144}",
        "#{SSCJ_130828_146}",
        "#{SSCJ_130828_147}",
        "#{SSCJ_130828_142}"
      },
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 60,
      y = 128,
      sceneID = 3,
      name = "马三"
    }
    local comp = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进"
    }
    local misName = "嵩阳一探"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("空闻大师之墓", 139, 106, 3)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_165}", 1, 600)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进"
    }
    local comp = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进",
      use_horse = false
    }
    local misName = "美若天仙"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("伤愈的空闻大师", 241, 60, 3, nil, false)
        Dismount()
        if -1 == Player:GetBuff("乔装") then
          Bag:UseItemByName("玲珑锦装", 500, Bag:EnumRenWuItem())
        end
        Sleep(500)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_192}", 1, 600)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_195}", 1, 600)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_197}", 1, 600)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进"
    }
    local comp = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进"
    }
    local misName = "迷魂汤"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("黑市商人", 181, 63, 3)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_216}", 1, 800)
        Shop_BuyItem("蒙汗药酒", 1)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进"
    }
    local comp = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进",
      use_horse = false
    }
    local misName = "智计擒贼"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("伤愈的空闻大师", 241, 60, 3, nil, false)
        Dismount()
        if -1 == Player:GetBuff("乔装") then
          Bag:UseItemByName("玲珑锦装", 500, Bag:EnumRenWuItem())
        end
        Sleep(500)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_245}", 1, 600)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_247}", 1, 600)
        QuestFrameOptionClicked_Item("#{SSCJ_130828_249}", 1, 600)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 200,
      y = 67,
      sceneID = 3,
      name = "柴进"
    }
    local comp = {
      x = 90,
      y = 42,
      sceneID = 3,
      name = "乔峰"
    }
    local misName = "拜祭英魂"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToScene(123, 51, 3, 1)
        Sleep(500)
        Dismount()
        Sleep(500)
        Bag:UseItemByName("上等黄酒", 500, Bag:EnumRenWuItem())
        PlayerStateTimeOut(5, 8)
      end,
      param_complete = comp,
      OnComplete = function(_param)
        ZhuXianComplete(_param)
        xs_LevelUp()
        Sleep(300)
        QuestFrameAcceptClicked(500)
        QuestFrameAcceptClicked(500)
        GoToSceneNPC("乔峰", 90, 42, 3)
        mission_complete_accept("西湖分舵", false, false, true)
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 90,
      y = 42,
      sceneID = 3,
      name = "乔峰"
    }
    local comp = {
      x = 45,
      y = 59,
      sceneID = 30,
      name = "乔小喜"
    }
    local misName = "西湖分舵"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if 3 == GetSceneID() then
          GoToSceneNPC("乔峰", 90, 42, 3)
          QuestFrameOptionClicked_Item("#{SSCJ_130828_318}", 1, 1000)
        else
          GoToSceneNPC("乔小喜", 45, 59, 30)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 45,
      y = 59,
      sceneID = 30,
      name = "乔小喜"
    }
    local comp = {
      x = 104,
      y = 80,
      sceneID = 30,
      name = "悬挂的尸体"
    }
    local misName = "西湖寻踪"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 104,
      y = 80,
      sceneID = 30,
      name = "悬挂的尸体"
    }
    local comp = {
      x = 116,
      y = 98,
      sceneID = 30,
      name = "刘浩然"
    }
    local misName = "节外生枝"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("悬挂的尸体", 104, 80, 30)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{XHCJ_130822_22}", 1, 600)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 116,
      y = 98,
      sceneID = 30,
      name = "刘浩然"
    }
    local comp = apt
    local misName = "蜂毒毁尸"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 116, y = 98},
          {x = 92, y = 92}
        },
        sceneName = "西湖",
        targetName = "花港毒蜂"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 116,
      y = 98,
      sceneID = 30,
      name = "刘浩然"
    }
    local comp = apt
    local misName = "毒草灭迹"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if 0 == xs_CaiJi("溶尸草") then
          GoToScene(92, 92, 30, 3)
          xs_CaiJi("溶尸草")
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 116,
      y = 98,
      sceneID = 30,
      name = "刘浩然"
    }
    local comp = {
      x = 83,
      y = 163,
      sceneID = 30,
      name = "包不同"
    }
    local misName = "抽丝剥茧"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        local nIndex, idMission, idScript = GetPlayerMission_Item("#{XHCJ_130822_271}")
        if -1 ~= nIndex then
          local item = {
            {
              x = 141,
              y = 111,
              name = "新鲜的血迹"
            },
            {
              x = 131,
              y = 123,
              name = "遗落的暗器"
            },
            {
              x = 106,
              y = 146,
              name = "树上的剑痕"
            }
          }
          for i = 1, 3 do
            local nParam = GetMissionVariable(nIndex, i)
            if 0 == nParam then
              GoToSceneNPC(item[i].name, item[i].x, item[i].y, 30)
              Sleep(500)
              QuestFrameOptionClicked_Item("#{XHCJ_130822_263}", 1, 500)
              break
            end
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
      x = 83,
      y = 163,
      sceneID = 30,
      name = "包不同"
    }
    local comp = apt
    local misName = "非也非也"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("包不同", 83, 163, 30)
        QuestFrameOptionClicked_Item("#{XHCJ_130822_129}", 1, 600)
        QuestFrameOptionClicked_Item("#{XHCJ_130822_129}", 1, 600)
        QuestFrameOptionClicked_Item("#{XHCJ_130822_129}", 1, 600)
        QuestFrameOptionClicked_Item("#{XHCJ_130822_134}", 1, 600)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 83,
      y = 163,
      sceneID = 30,
      name = "包不同"
    }
    local comp = {
      x = 97,
      y = 171,
      sceneID = 30,
      name = "风波恶"
    }
    local misName = "见面大礼"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 92, y = 163}
        },
        sceneName = "西湖",
        targetName = "白堤柳鬼"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = function(_param)
        GoToSceneNPC("风波恶", 97, 171, 30)
        Dismount()
        Sleep(500)
        ZhuXianComplete(_param)
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 97,
      y = 171,
      sceneID = 30,
      name = "风波恶"
    }
    local comp = {
      x = 97,
      y = 171,
      sceneID = 30,
      name = "风波恶",
      use_horse = false
    }
    local misName = "陈年佳酿"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = function(_param)
        GoToSceneNPC("风波恶", 97, 171, 30)
        Dismount()
        mission_accept(_param)
      end,
      OnAction = function()
        GoToSceneNPC("美酒酒桶", 76, 193, 30, nil, false)
        Dismount()
        Sleep(500)
        if -1 == Player:GetBuff("伪装") then
          Bag:UseItemByName("陈年佳酿", 500, Bag:EnumRenWuItem())
        end
        QuestFrameOptionClicked_Item("#{XHCJ_130822_265}", 1, 500)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 97,
      y = 171,
      sceneID = 30,
      name = "风波恶"
    }
    local comp = apt
    local misName = "杯中恩怨"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 133, y = 169}
        },
        sceneName = "西湖",
        targetName = "风波恶的仇敌",
        call_back_attack = function()
          DebugStr("杯中恩怨:正在执行中", 2)
          local nComplete, nIndex = GetMissionVariableByName_Item("#{XHCJ_130822_275}", 0)
          if 1 == nComplete or -1 == nIndex then
            return true
          end
          TeamCheckNear()
          local tObj = Enum2XByName("风波恶的仇敌", {
            0,
            1,
            0,
            0
          }, {0, -1}, 1, 0)
          if 0 == #tObj then
            GoToScene(133, 169, 30)
            Dismount()
            Bag:UseItemByName("喝剩的绝世美酒", 1000, Bag:EnumRenWuItem())
            PlayerStateTimeOut(5, 8)
          end
          return false
        end
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 97,
      y = 171,
      sceneID = 30,
      name = "风波恶"
    }
    local comp = {
      x = 101,
      y = 218,
      sceneID = 30,
      name = "慕容复"
    }
    local misName = "姑苏慕容"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 101,
      y = 218,
      sceneID = 30,
      name = "慕容复"
    }
    local comp = apt
    local misName = "真相大白"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("一动不动的飞贼", 104, 212, 30)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{XHCJ_130822_238}", 1, 500)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 101,
      y = 218,
      sceneID = 30,
      name = "慕容复"
    }
    local comp = {
      x = 243,
      y = 42,
      sceneID = 24,
      name = "刀白凤"
    }
    local misName = "洱海玉虚"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function(_param)
        if 30 == GetSceneID() then
          GoToSceneNPC("慕容复", 101, 218, 30)
          Sleep(500)
          QuestFrameOptionClicked_Item("#{XHCJ_130822_296}", 1, 1000)
        else
          ZhuXianComplete(_param)
        end
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 243,
      y = 42,
      sceneID = 24,
      name = "刀白凤"
    }
    local comp = {
      x = 176,
      y = 78,
      sceneID = 24,
      name = "木铃儿"
    }
    local misName = "洱海寻医"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 176,
      y = 78,
      sceneID = 24,
      name = "木铃儿"
    }
    local comp = {
      x = 180,
      y = 36,
      sceneID = 24,
      name = "木柯隆"
    }
    local misName = "望闻问切"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("木赫", 177, 45, 24)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{EHCJ_130823_35}", 1, 600)
        QuestFrameOptionClicked_Item("#{EHCJ_130823_37}", 1, 600)
        QuestFrameOptionClicked_Item("#{EHCJ_130823_39}", 1, 600)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 180,
      y = 36,
      sceneID = 24,
      name = "木柯隆"
    }
    local comp = apt
    local misName = "怪病真相"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToScene(178, 45, 24, 1)
        Dismount()
        Bag:UseItemByName("金针", 600, Bag:EnumRenWuItem())
        PlayerStateTimeOut(5, 8)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 180,
      y = 36,
      sceneID = 24,
      name = "木柯隆"
    }
    local comp = apt
    local misName = "洱海仙虫"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 111, y = 100}
        },
        sceneName = "洱海",
        targetName = "仙海虫",
        call_back_attack = function()
          DebugStr("洱海仙虫:正在执行中", 2)
          local nComplete, nIndex = GetMissionVariableByName_Item("洱海仙虫", 0)
          if 1 == nComplete or -1 == nIndex then
            return true
          end
          TeamCheckNear()
          local tObj = Enum2XByName("仙海虫", {
            0,
            1,
            0,
            0
          }, {0, -1}, 1, 0)
          if 0 == #tObj then
            GoToScene(111, 100, 24)
            Dismount()
            Bag:UseItemByName("蝶香粉", 1000, Bag:EnumRenWuItem())
            PlayerStateTimeOut(5, 8)
          end
          return false
        end
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 180,
      y = 36,
      sceneID = 24,
      name = "木柯隆"
    }
    local comp = apt
    local misName = "情人之血"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("木铃儿", 176, 78, 24)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{EHCJ_130823_104}", 1, 500)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 180,
      y = 36,
      sceneID = 24,
      name = "木柯隆"
    }
    local comp = apt
    local misName = "以蛊制蛊"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToSceneNPC("木赫", 177, 45, 24)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{EHCJ_130823_125}", 1, 500)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 180,
      y = 36,
      sceneID = 24,
      name = "木柯隆"
    }
    local comp = {
      x = 176,
      y = 78,
      sceneID = 24,
      name = "木铃儿"
    }
    local misName = "痴爱"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 176,
      y = 78,
      sceneID = 24,
      name = "木铃儿"
    }
    local comp = {
      x = 280,
      y = 205,
      sceneID = 24,
      name = "纳塔"
    }
    local misName = "蛊巫真身"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 163, y = 186}
        },
        sceneName = "洱海",
        targetName = "风豹"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 280,
      y = 205,
      sceneID = 24,
      name = "纳塔"
    }
    local comp = apt
    local misName = "心结"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        if 0 == xs_CaiJi("情人草") then
          GoToScene(255, 176, 24, 3)
          xs_CaiJi("情人草")
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 280,
      y = 205,
      sceneID = 24,
      name = "纳塔"
    }
    local comp = {
      x = 257,
      y = 133,
      sceneID = 24,
      name = "云端"
    }
    local misName = "活着的仙药"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnAction = function()
        GoToScene(272, 207, 24, 1)
        Dismount()
        Bag:UseItemByName("熏香", 600, Bag:EnumRenWuItem())
        PlayerStateTimeOut(5, 8)
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 257,
      y = 133,
      sceneID = 24,
      name = "云端"
    }
    local comp = {
      x = 160,
      y = 159,
      sceneID = 2,
      name = "赵天师"
    }
    local misName = "神秘棋局"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 160,
      y = 159,
      sceneID = 2,
      name = "赵天师"
    }
    local comp = {
      x = 286,
      y = 138,
      sceneID = 2,
      name = "刘仲甫"
    }
    local misName = "大理棋圣"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 286,
      y = 138,
      sceneID = 2,
      name = "刘仲甫"
    }
    local comp = {
      x = 267,
      y = 243,
      sceneID = 1,
      name = "张弈国"
    }
    local misName = "苏州棋圣"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 267,
      y = 243,
      sceneID = 1,
      name = "张弈国"
    }
    local comp = {
      x = 366,
      y = 228,
      sceneID = LUOYANG_ID,
      name = "王积薪"
    }
    local misName = "洛阳棋圣"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 366,
      y = 228,
      sceneID = LUOYANG_ID,
      name = "王积薪"
    }
    local comp = {
      x = 356,
      y = 208,
      sceneID = LUOYANG_ID,
      name = "卜悔琪"
    }
    local misName = "黑白"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 356,
      y = 208,
      sceneID = LUOYANG_ID,
      name = "卜悔琪"
    }
    local comp = {
      x = 40,
      y = 40,
      sceneID = 550,
      sceneName = "珍珑棋局",
      name = "齐圣"
    }
    local misName = "生死棋局"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function(_param)
        if GetSceneID() ~= 550 then
          DoubleExp_Get(50)
          Team:LeaveTeam()
          GoToSceneNPC("王积薪", 366, 228, LUOYANG_ID)
          QuestFrameOptionClicked_Item("生死棋局", 1, 600)
        else
          ZhuXianComplete(_param)
        end
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 40,
      y = 40,
      sceneID = 550,
      sceneName = "珍珑棋局",
      name = "齐圣"
    }
    local comp = {
      x = 40,
      y = 40,
      sceneID = 550,
      sceneName = "珍珑棋局",
      name = "齐圣"
    }
    local misName = "棋局试炼"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 55, y = 43},
          {x = 68, y = 48},
          {x = 62, y = 55}
        },
        call_back_run = function()
          if GetSceneID() ~= 550 then
            return false
          end
          return true
        end,
        call_back_attack = function()
          CDG.double.tld = true
          xs_LevelUp()
          DebugStr("棋局试炼:执行中", 2)
          local nComplete, nIndex = GetMissionVariableByName_Item("棋局试炼", 0)
          if 1 == nComplete or -1 == nIndex or GetSceneID() ~= 550 then
            return true
          end
          return false
        end,
        sceneName = "",
        targetName = ""
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = function(_param)
        PickUpLua()
        RunTo(40, 40, 3, 2000)
        PickUpLua()
        PlayerStateTimeOut(2, 10)
        TalkNpc("齐圣")
        Sleep(600)
        QuestFrameOptionClicked_Item("#{INTERFACE_XML_557}", 1, 600)
      end
    }
    return mission
  end,
  function()
    local misName = "贼兵入侵"
    local apt = {
      x = 256,
      y = 273,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 214,
      y = 325,
      sceneID = LUOYANG_ID,
      name = "立繁"
    }
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = function(_param)
        if xs_submit_zhou() then
          local nComplete, nIndex = GetMissionVariableByName_Item("试炼之所摩崖洞", 0)
          if -1 == nIndex then
            GoToSceneNPC("周天师", 256, 273, LUOYANG_ID)
            mission_complete_accept("试炼之所摩崖洞", false, false, true)
          end
          GoToSceneNPC("周天师", 256, 273, LUOYANG_ID)
          mission_complete_accept("贼兵入侵", false, false, true)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 214,
      y = 325,
      sceneID = LUOYANG_ID,
      name = "立繁"
    }
    local comp = {
      x = 108,
      y = 110,
      sceneID = 3,
      name = "造反恶贼指引人"
    }
    local misName = "造反恶贼"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function(mission)
        if GetSceneID() ~= 551 then
          DoubleExp_Get(10)
          Team:LeaveTeam()
          GoToSceneNPC("造反恶贼指引人", 108, 110, 3)
          QuestFrameOptionClicked_Item("#{YD_100806_54}", 1, 800)
        else
          local function call_back_run()
            if GetSceneID() ~= 551 then
              return false
            end
            return true
          end
          
          MoveToNPC("造反恶贼指引人", 74, 111, -1, nil, nil, nil, call_back_run)
          mission_complete_accept("#{YD_100806_56}", true, true, true)
        end
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = 74,
      y = 111,
      sceneID = 551,
      sceneName = "贼寇营地",
      name = "造反恶贼指引人"
    }
    local misName = "剿灭反贼"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 80, y = 91},
          {x = 96, y = 83},
          {x = 109, y = 47},
          {x = 99, y = 25},
          {x = 73, y = 23},
          {x = 52, y = 25},
          {x = 37, y = 20},
          {x = 28, y = 25},
          {x = 42, y = 78},
          {x = 22, y = 100}
        },
        call_back_run = function()
          if GetSceneID() ~= 551 then
            return false
          end
          return true
        end,
        call_back_attack = function()
          DebugStr("剿灭反贼:执行中", 2)
          CDG.double.tld = true
          xs_LevelUp()
          local nComplete, nIndex = GetMissionVariableByName_Item("剿灭反贼", 0)
          if 1 == nComplete or -1 == nIndex or GetSceneID() ~= 551 then
            return true
          end
          return false
        end,
        sceneName = "",
        targetName = ""
      },
      OnAction = ZhuXianAttack,
      OnComplete = function()
        PickUpLua()
        UseMount()
      end
    }
    return mission
  end,
  function()
    local misName = "偷袭门派"
    local apt = {
      x = 256,
      y = 273,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 214,
      y = 325,
      sceneID = LUOYANG_ID,
      name = "立繁"
    }
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = function(_param)
        if xs_submit_zhou() then
          GoToSceneNPC("周天师", 256, 273, LUOYANG_ID)
          mission_complete_accept(misName, false, false, true)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local misName = "江湖宵小"
    local apt = {
      x = 214,
      y = 325,
      sceneID = LUOYANG_ID,
      name = "立繁"
    }
    local comp = {
      x = 214,
      y = 325,
      sceneID = LUOYANG_ID,
      name = "立繁"
    }
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = function()
        if IsMenPaiXiaoFuben_xs() == false then
          Team:LeaveTeam()
          local npc = mp_get_shimen_npc()
          if npc.x then
            GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
            QuestFrameOptionClicked_Item("#{YD_100806_58}", 1, 600)
          end
        else
          local tObj = Enum2XByName("保卫门派指引人", {
            1,
            0,
            0,
            0
          }, nil, nil, 0)
          if #tObj > 0 then
            RunTo(tObj[1].x, tObj[1].y, 1, 2000)
          end
          TalkNpc("保卫门派指引人")
          Sleep(600)
          mission_complete_accept("#{YD_100806_64}", true, true, true)
        end
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = -1,
      y = -1,
      sceneID = -1,
      sceneName = "",
      name = ""
    }
    local misName = "剿灭宵小"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = function()
        local tObj = Enum2XByName("保卫门派指引人", {
          1,
          0,
          0,
          0
        }, nil, nil, 0)
        if #tObj > 0 then
          RunTo(tObj[1].x, tObj[1].y, 1, 2000)
        end
        TalkNpc("保卫门派指引人")
        Sleep(600)
        mission_complete_accept("剿灭宵小", true, true, true)
      end,
      param_action = {
        pos = nil,
        call_back_run = function()
          return IsMenPaiXiaoFuben_xs()
        end,
        call_back_attack = function()
          DebugStr("剿灭宵小:执行中", 2)
          CDG.double.tld = true
          xs_LevelUp()
          local nComplete, nIndex = GetMissionVariableByName_Item("剿灭宵小", 0)
          if 1 == nComplete or -1 == nIndex or IsMenPaiXiaoFuben_xs() == false then
            return true
          end
          local nParam1 = GetMissionVariable(nIndex, 1)
          if 15 ~= nParam1 then
            local fubenPos, fubenBoss = xs_mp_get_fbpos()
            if fubenPos and #fubenPos > 0 then
              CDG.pos = fubenPos
            end
          else
            local fubenPos, fubenBoss = xs_mp_get_fbpos()
            if fubenBoss and #fubenBoss > 0 then
              CDG.pos = fubenBoss
            end
          end
          return false
        end,
        sceneName = "",
        targetName = ""
      },
      OnAction = ZhuXianAttack,
      OnComplete = function()
        PickUpLua()
        UseMount()
      end
    }
    return mission
  end,
  function()
    local misName = "匪首聚三关"
    local apt = {
      x = 256,
      y = 273,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 134,
      y = 260,
      sceneID = 1,
      name = "钱宏宇"
    }
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = function(_param)
        if IsInFubenScene() == false and xs_submit_zhou() then
          GoToSceneNPC("周天师", 256, 273, LUOYANG_ID)
          mission_complete_accept(misName, false, false, true)
        end
      end,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local misName = "勇闯三才阵"
    local apt = {
      x = 134,
      y = 260,
      sceneID = 1,
      name = "钱宏宇"
    }
    local comp
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      OnComplete = function()
        if GetSceneID() ~= 652 then
          DoubleExp_Get(30)
          Team:LeaveTeam()
          local npc = apt
          GoToSceneNPC(npc.name, npc.x, npc.y, npc.sceneID)
          mission_complete_accept("#{LSHDR_150203_10}", true, true, true)
        else
          local function call_back_run()
            if GetSceneID() ~= 652 then
              return false
            end
            return true
          end
          
          MoveToNPC("三关指引人", 183, 197, -1, nil, nil, nil, call_back_run)
          mission_complete_accept("#{LSHDR_150203_15}", true, true, true)
        end
      end
    }
    return mission
  end,
  function()
    local apt = {
      x = -1,
      y = -1,
      sceneID = -1,
      sceneName = "",
      name = ""
    }
    local misName = "剿灭匪首"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = function()
        local function call_back_run()
          if GetSceneID() ~= 652 then
            return false
          end
          return true
        end
        
        MoveToNPC("三关指引人", 183, 197, -1, nil, nil, nil, call_back_run)
        Sleep(600)
        mission_complete_accept("剿灭匪首", false, false, true)
      end,
      param_action = {
        pos = nil,
        is_pick = true,
        call_back_run = function()
          return GetSceneID() == 652
        end,
        call_back_attack = function()
          DebugStr("剿灭匪首:执行中", 2)
          CDG.double.tld = true
          xs_LevelUp()
          local nComplete, nIndex = GetMissionVariableByName_Item("剿灭匪首", 0)
          if 1 == nComplete or -1 == nIndex or GetSceneID() ~= 652 then
            return true
          end
          CDG.pos = xs_getpos_jf()
          return false
        end,
        sceneName = "",
        targetName = ""
      },
      OnAction = ZhuXianAttack,
      OnComplete = function()
        PickUpLua()
        UseMount()
        PickUpLua()
        
        local function call_back_run()
          if GetSceneID() ~= 652 then
            return false
          end
          return true
        end
        
        MoveToNPC("宋兵前哨", 65, 198, -1, nil, nil, nil, call_back_run)
        Sleep(600)
        local nComplete, nIndex = GetMissionVariableByName_Item("#{YD_100806_90}", 0)
        if -1 == nIndex then
          mission_complete_accept("#{YD_100806_90}", false, false, true)
          MoveToNPC("宋兵前哨", 65, 198, -1, nil, nil, nil, call_back_run)
          Sleep(600)
        end
        if -1 ~= GetPlayerMission("单枪匹马战群贼") then
          mission_complete_accept("#{LSHDR_150203_116}", true, true, false)
        else
          QuestFrameOptionClicked_Item("#{LSHDR_150203_32}", 1, 600)
          QuestFrameOptionClicked_Item("#{LSHDR_150203_52}", 1, 600)
        end
      end
    }
    return mission
  end
}
local MissionTable_2 = {
  function()
    local apt = {
      x = 90,
      y = 42,
      sceneID = 3,
      name = "乔峰"
    }
    local comp = {
      x = 160,
      y = 159,
      sceneID = 2,
      name = "赵天师"
    }
    local misName = "江湖救急"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 256,
      y = 273,
      sceneID = LUOYANG_ID,
      name = "周天师"
    }
    local comp = {
      x = 17,
      y = 229,
      sceneID = 213,
      name = "摩云天"
    }
    local misName = "试炼之所摩崖洞"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 242,
      y = 72,
      sceneID = 18,
      name = "周无畏"
    }
    local comp = apt
    local misName = "狼害"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 240, y = 262}
        },
        sceneName = "雁南",
        targetName = "西北狼"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 242,
      y = 72,
      sceneID = 18,
      name = "周无畏"
    }
    local comp = apt
    local misName = "豹害"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 253, y = 210}
        },
        sceneName = "雁南",
        targetName = "金钱豹"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 260,
      y = 88,
      sceneID = 18,
      name = "马承倩"
    }
    local comp = apt
    local misName = "完美的灰熊皮"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 170, y = 76}
        },
        is_pick = true,
        sceneName = "雁南",
        targetName = "灰熊",
        pick_item = "完美的灰熊皮"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 242,
      y = 72,
      sceneID = 18,
      name = "周无畏"
    }
    local comp = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local misName = "周处除三害"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 156, y = 163}
        },
        sceneName = "雁南",
        targetName = "骆奉仙"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local comp = apt
    local misName = "秘密联络"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 206, y = 117}
        },
        is_pick = true,
        sceneName = "雁南",
        targetName = "秦家寨信使",
        pick_item = "秦家寨密信"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local comp = apt
    local misName = "一打秦家寨"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 127, y = 123}
        },
        sceneName = "雁南",
        targetName = "秦家寨探子"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local comp = apt
    local misName = "二打秦家寨"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 37, y = 129}
        },
        sceneName = "雁南",
        targetName = "秦家寨喽啰"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local comp = apt
    local misName = "三打秦家寨"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 68, y = 201}
        },
        sceneName = "雁南",
        targetName = "秦家寨亲兵"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local comp = apt
    local misName = "胜利的曙光"
    local mission = {
      name = misName,
      is_check_team = true,
      param_accept = apt,
      OnAccept = mission_accept,
      param_action = {
        pos = {
          {x = 38, y = 206}
        },
        sceneName = "雁南",
        targetName = "秦伯起"
      },
      OnAction = ZhuXianAttack,
      param_complete = comp,
      OnComplete = ZhuXianComplete
    }
    return mission
  end,
  function()
    local apt = {
      x = 263,
      y = 47,
      sceneID = 18,
      name = "种世衡"
    }
    local comp = {
      x = 165,
      y = 137,
      sceneID = 31,
      next_mission = false,
      name = "雷焕"
    }
    local misName = "尘封已久的友谊"
    local mission = {
      name = misName,
      param_accept = apt,
      OnAccept = mission_accept,
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
      DebugStr("主线交任务 " .. mis.name, 2)
      mis.is_complete = true
      if mis.name == "大理棋圣" then
        if xs_CardReward() then
          mis.OnComplete(mis)
        end
      else
        mis.OnComplete(mis)
      end
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
          if mis.name == "大理棋圣" then
            if xs_CardReward() then
              mis.OnComplete(mis)
            end
          else
            mis.OnComplete(mis)
          end
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

local function ZhuXianCanAccept(aMisName)
  if "加入门派" == aMisName then
    Player:IsJinGong()
    if 9 ~= g_self.menpai then
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
    if (mis.is_complete == nil or mis.is_complete == false) and IsMissionOutline(mis.name) and ZhuXianCanAccept(mis.name) and (-1 == lastScene or lastScene == mis.param_accept.sceneID) then
      if nLevel >= 30 and mis.name == "西湖分舵" then
        PushColorMsg("忽略可接任务：" .. mis.name)
      elseif mis.param_accept and mis.param_accept.sceneID and ZhuXianAcceptCheckScene(mis_table, mis.param_accept.sceneID, i) then
        lastScene = mis.param_accept.sceneID
        DebugStr("新手任务 " .. mis.name, 2)
        bDoAction = true
        mis.OnAccept(mis)
        if i > 63 then
          break
        end
      end
    end
  end
  return bDoAction
end

local function xs_other_mission()
  local nLevel = Player:GetDataInt("LEVEL")
  if not m_param.other_mission and nLevel >= 40 then
    return false
  end
  if nLevel < 40 then
    if false == ZhuXianCommitMission(MissionTable_2) and false == ZhuXianDoMission(MissionTable_2) and false == ZhuXianAcceptMission(MissionTable_2) then
      return false
    end
  elseif false == ZhuXianDoMission(MissionTable_2) and false == ZhuXianCommitMission(MissionTable_2) and false == ZhuXianAcceptMission(MissionTable_2) then
    return false
  end
  return true
end

function _SMain()
  LoadScript("mission")
  xs_CheckCard()
  while true do
    local debugnote = ""
    xs_CheckAll()
    if false == ZhuXianDoMission() then
      if false == ZhuXianCommitMission() then
        if false == ZhuXianAcceptMission() and xs_submit_zhou() and false == xs_other_mission() then
          PushColorMsg("新手任务：无任务可做")
          break
        end
      elseif false == ZhuXianCommitMission() then
        ZhuXianAcceptMission()
      end
    end
    local nLevel = Player:GetDataInt("LEVEL")
    if nLevel >= m_param.max_level and m_param.max_level < 40 then
      break
    end
    Sleep(100)
    DebugStr("新手任务 " .. debugnote, 1)
  end
  for i = 5, 3, -1 do
    xs_GetPrize(i)
  end
  xs_DeleteBag()
  DoubleExp_Freeze()
  GoToSceneNPC("冯铸铁", 250, 315, LUOYANG_ID)
  QuestFrameOptionClicked_Item("学习材料加工技能", 1, 600)
  QuestFrameOptionClicked_Item("我确定要学习", 1, 600)
  GetLuaValue("Lua_SetProtectTime(0,1);")
  Sleep(1000)
  MessageBox_Self_OK_Clicked()
  xs_ClearBag()
end

_SMain()
ScriptOnStop(m_script_name)
MissionTable = nil
MissionTable_2 = nil
m_param = nil
m_UsherInfo = nil
