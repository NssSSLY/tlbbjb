-- 反编译自 dfz64.dll 内嵌字节码 00381690（unluac 2025-12-23；仅供分析）
local m_script_name = "刷怪"
ScriptOnStart(m_script_name, true, false)

function _SMain(...)
  SG_ParseConfig()
  
  local function _GetRefreshDiff(_aSceneName, _aSceneID)
    if "" ~= _aSceneName then
      local strFind = HandleText_AddFuHao(_aSceneName, " ")
      if string.find(" 高昌 塔里木 大宛 撒马尔罕 昆仑山 黄龙府 海贼洞 ", strFind, nil, true) then
        return 65000
      elseif string.find(" 高昌迷宫 火焰山 火焰谷 塔克拉玛干 汗血岭 圣火宫 昆仑福地 千帆寨 古今亭 枯荣道 望风古原 剑兰坡 余霞港 星渔湾 冷雁横川 云梦泽 碧笋春林 雨竹岗 ", strFind, nil, true) then
        return 50000
      elseif string.find(" 漠南青原 忘川花海 天岐南淮 林海溪谷 水月洞天 大鲲遗骸 玄海 ", strFind, nil, true) then
        return 50000
      elseif string.find(" 燕王古墓七层 燕王古墓八层 燕王古墓九层 ", strFind, nil, true) then
        return 94700
      elseif string.find(" 秦皇地宫一层 秦皇地宫二层 燕王古墓一层 燕王古墓二层 燕王古墓三层 燕王古墓四层 燕王古墓五层 燕王古墓六层 ", strFind, nil, true) then
        return 95000
      elseif string.find(" 秦皇地宫三层 ", strFind, nil, true) then
        return 75000
      elseif string.find(" 秦皇地宫四层 ", strFind, nil, true) then
        return 75150
      elseif string.find(" 敦煌 ", strFind, nil, true) then
        return 8000
      elseif string.find(" 琼州 长白山 ", strFind, nil, true) then
        return 64700
      elseif string.find(" 盐湖 白沙盐坑 ", strFind, nil, true) then
        return 65000
      elseif string.find(" 雪狼湖 ", strFind, nil, true) then
        return 80000
      elseif string.find(" 桃花源 水晶湖 ", strFind, nil, true) then
        return 45000
      end
    end
    return -1
  end
  
  CDG:InitDaguaiParam()
  if not g_config.shuaguai.unuse_skill then
    CDG.skill_attack = g_config.skill.shuaguai_gongji
  else
    CDG.skill_attack = {}
  end
  CDG.skill_state = g_config.skill.shuaguai_zhuangtai
  CDG.skill_comb1 = g_config.skill.shuaguai_zuhe1
  CDG.skcb1.using = false
  CDG.skcb1.mode = g_config.skill.shuaguai_zuhe1_use.sel
  CDG.skill_comb2 = g_config.skill.shuaguai_zuhe2
  CDG.skcb2.using = false
  CDG.skcb2.mode = g_config.skill.shuaguai_zuhe2_use.sel
  PushColorMsg("刷怪地图：%s,地图ID:%d", CDG.sceneName, CDG.sceneID)
  if #CDG.petArr > 0 then
    PushColorMsg("刷怪:有%d只珍兽需要练级", #CDG.petArr)
  end
  DoSystem(1007, -1)
  CDG.jgyc = true
  local sendDiff = HandleTextToNumber(g_config.shuaguai.send_diff_tick, 0)
  if sendDiff <= 0 then
    sendDiff = 80
  end
  local refTick = _GetRefreshDiff(CDG.sceneName, CDG.sceneID)
  if CDG.attackMode == "超级抢怪" then
    if #CDG.pos <= 1 then
      if -1 ~= refTick then
        PushColorMsg("抢怪需运行几分钟后才有效果")
        DoSystem(1001, g_self.isjingong, Skill.baseID, sendDiff, refTick, 0)
        CDG.attackGrab = 3
        DoSystem(1002, CDG.attackGrab)
        RecvState(28)
      else
        CDG.attackMode = "普通抢怪"
        PushColorMsg("%s：暂不支持,转为普通抢怪,如该地图有需要请提交反馈", CDG.sceneName)
      end
    else
      CDG.attackMode = "普通抢怪"
      PushColorMsg("多点坐标不支持抢怪模式,转为普通抢怪")
    end
  end
  if CDG.attackMode == "普通抢怪" then
    DoSystem(1001, g_self.isjingong, Skill.baseID, sendDiff, refTick, 0)
    CDG.attackGrab = 1
    DoSystem(1002, CDG.attackGrab)
    RecvState(16)
  end
  
  local function _Start()
    CDG:OnStart()
    DoSystem(1004)
    DoubleExp_Freeze()
    local nOnOver = ReadConfigInt("ZH", "zhk40")
    if 0 == nOnOver then
      if not IsSafeSceneID() then
        GoBackCity()
      end
    elseif 1 == nOnOver then
      OffLine(true)
    elseif 2 == nOnOver then
      ShowTipMsg("即将关闭电脑! 如不需要，请在10秒内停止运行")
      Sleep(10000)
      ShutDown()
    end
  end
  
  _Start()
end

_SMain()
ScriptOnStop(m_script_name)
