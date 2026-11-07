-- 反编译自 dfz64.dll 内嵌字节码 0028b707（unluac 2025-12-23；仅供分析）
local m_script_name = "闲常治务"
ScriptOnStart(m_script_name)
PushDebugMessage("背包有[荣赏令]时将自动使用")
local m_param = {}
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
local m_mission_npc = {
  [0] = {
    name = "玄思",
    x = 55,
    y = 97,
    sceneID = 883,
    mpname = "少林"
  },
  [1] = {
    name = "阿芙颂",
    x = 54,
    y = 97,
    sceneID = 887,
    mpname = "明教"
  },
  [2] = {
    name = "贺千钧",
    x = 53,
    y = 98,
    sceneID = 891,
    mpname = "丐帮"
  },
  [3] = {
    name = "晗月散人",
    x = 55,
    y = 96,
    sceneID = 886,
    mpname = "武当"
  },
  [4] = {
    name = "叶瑶",
    x = 54,
    y = 97,
    sceneID = 890,
    mpname = "峨嵋"
  },
  [5] = {
    name = "霜蛊",
    x = 58,
    y = 91,
    sceneID = 885,
    mpname = "星宿"
  },
  [6] = {
    name = "段红缨",
    x = 55,
    y = 96,
    sceneID = 889,
    mpname = "天龙"
  },
  [7] = {
    name = "江暮风",
    x = 56,
    y = 94,
    sceneID = 884,
    mpname = "天山"
  },
  [8] = {
    name = "方絮",
    x = 55,
    y = 96,
    sceneID = 888,
    mpname = "逍遥"
  },
  [10] = {
    name = "包问辰",
    x = 54,
    y = 97,
    sceneID = 892,
    mpname = "慕容"
  },
  [11] = {
    name = "唐峦影",
    x = 81,
    y = 42,
    sceneID = 893,
    mpname = "唐门"
  },
  [12] = {
    name = "云笈",
    x = 54,
    y = 95,
    sceneID = 894,
    mpname = "鬼谷"
  },
  [13] = {
    name = "寒云",
    x = 54,
    y = 97,
    sceneID = 895,
    mpname = "桃花岛"
  },
  [14] = {
    name = "平禾",
    x = 57,
    y = 94,
    sceneID = 896,
    mpname = "绝情谷"
  },
  [15] = {
    name = "山和尚",
    x = 57,
    y = 94,
    sceneID = 988,
    mpname = "恶人谷"
  }
}
local m_fuben_npc = {
  {
    x = 96,
    y = 163,
    sceneID = 901,
    npcname = "玄择"
  },
  {
    x = 96,
    y = 159,
    sceneID = 905,
    npcname = "炎辉"
  },
  {
    x = 95,
    y = 164,
    sceneID = 909,
    npcname = "任西"
  },
  {
    x = 95,
    y = 164,
    sceneID = 904,
    npcname = "和风道人"
  },
  {
    x = 96,
    y = 164,
    sceneID = 908,
    npcname = "孟语之"
  },
  {
    x = 95,
    y = 165,
    sceneID = 903,
    npcname = "溯游子"
  },
  {
    x = 96,
    y = 164,
    sceneID = 907,
    npcname = "高庆运"
  },
  {
    x = 96,
    y = 165,
    sceneID = 902,
    npcname = "天明"
  },
  {
    x = 95,
    y = 165,
    sceneID = 906,
    npcname = "星彩"
  },
  {
    x = 95,
    y = 162,
    sceneID = 910,
    npcname = "风璇归"
  },
  {
    x = 96,
    y = 165,
    sceneID = 911,
    npcname = "唐岭西"
  },
  {
    x = 95,
    y = 163,
    sceneID = 912,
    npcname = "苏回意"
  },
  {
    x = 96,
    y = 164,
    sceneID = 913,
    npcname = "语云情"
  },
  {
    x = 95,
    y = 164,
    sceneID = 914,
    npcname = "元恺"
  },
  {
    x = 95,
    y = 164,
    sceneID = 996,
    npcname = "山魑"
  }
}
local m_npc_shimen = {
  [0] = {
    name = "慧方",
    x = 96,
    y = 83,
    sceneID = 9
  },
  [1] = {
    name = "林岩",
    x = 98,
    y = 105,
    sceneID = 11
  },
  [2] = {
    name = "洪通",
    x = 91,
    y = 77,
    sceneID = 10
  },
  [3] = {
    name = "张中行",
    x = 78,
    y = 95,
    sceneID = 12
  },
  [4] = {
    name = "孟龙",
    x = 96,
    y = 88,
    sceneID = 15
  },
  [5] = {
    name = "王彦",
    x = 96,
    y = 92,
    sceneID = 16
  },
  [6] = {
    name = "本凡",
    x = 95,
    y = 88,
    sceneID = 13
  },
  [7] = {
    name = "符敏仪",
    x = 95,
    y = 60,
    sceneID = 17
  },
  [8] = {
    name = "秦观",
    x = 119,
    y = 152,
    sceneID = 14
  },
  [9] = {
    name = "",
    x = 0,
    y = 0,
    sceneID = 0
  },
  [10] = {
    name = "慕容胜",
    x = 68,
    y = 127,
    sceneID = 284
  },
  [11] = {
    name = "唐清秋",
    x = 100,
    y = 64,
    sceneID = 615
  },
  [12] = {
    name = "王玄风",
    x = 96,
    y = 98,
    sceneID = 678
  },
  [13] = {
    name = "萧声咽",
    x = 160,
    y = 72,
    sceneID = 731
  },
  [14] = {
    name = "七叔",
    x = 245,
    y = 191,
    sceneID = 824
  },
  [15] = {
    name = "",
    x = 232,
    y = 320,
    sceneID = LUOYANG_ID
  }
}
local m_caiji_pos = {
  少林 = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 51, y = 131}
  },
  ["明教"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["丐帮"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 51, y = 131}
  },
  ["武当"] = {
    {x = 55, y = 55},
    {x = 117, y = 71},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["峨嵋"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  星宿 = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 49, y = 129}
  },
  天龙 = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["天山"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["逍遥"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["慕容"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  唐门 = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 56, y = 131}
  },
  ["鬼谷"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["桃花岛"] = {
    {x = 58, y = 60},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 58, y = 127}
  },
  ["绝情谷"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 120}
  },
  ["恶人谷"] = {
    {x = 55, y = 55},
    {x = 114, y = 70},
    {x = 139, y = 138},
    {x = 53, y = 127}
  }
}
local g_QuestionList = {
  [1] = {
    question = "#{ZMSW_230627_117}",
    answer1 = "#{ZMSW_230627_118}",
    answer2 = "#{ZMSW_230627_119}",
    answer3 = "#{ZMSW_230627_120}",
    answerid = 2
  },
  [2] = {
    question = "#{ZMSW_230627_121}",
    answer1 = "#{ZMSW_230627_122}",
    answer2 = "#{ZMSW_230627_123}",
    answer3 = "#{ZMSW_230627_124}",
    answerid = 3
  },
  [3] = {
    question = "#{ZMSW_230627_125}",
    answer1 = "#{ZMSW_230627_126}",
    answer2 = "#{ZMSW_230627_127}",
    answer3 = "#{ZMSW_230627_128}",
    answerid = 2
  },
  [4] = {
    question = "#{ZMSW_230627_243}",
    answer1 = "#{ZMSW_230627_244}",
    answer2 = "#{ZMSW_230627_245}",
    answer3 = "#{ZMSW_230627_246}",
    answerid = 1
  },
  [5] = {
    question = "#{ZMSW_230627_247}",
    answer1 = "#{ZMSW_230627_248}",
    answer2 = "#{ZMSW_230627_249}",
    answer3 = "#{ZMSW_230627_250}",
    answerid = 2
  },
  [6] = {
    question = "#{ZMSW_230627_251}",
    answer1 = "#{ZMSW_230627_276}",
    answer2 = "#{ZMSW_230627_301}",
    answer3 = "#{ZMSW_230627_326}",
    answerid = 3
  },
  [7] = {
    question = "#{ZMSW_230627_252}",
    answer1 = "#{ZMSW_230627_277}",
    answer2 = "#{ZMSW_230627_302}",
    answer3 = "#{ZMSW_230627_327}",
    answerid = 1
  },
  [8] = {
    question = "#{ZMSW_230627_253}",
    answer1 = "#{ZMSW_230627_278}",
    answer2 = "#{ZMSW_230627_303}",
    answer3 = "#{ZMSW_230627_328}",
    answerid = 2
  },
  [9] = {
    question = "#{ZMSW_230627_254}",
    answer1 = "#{ZMSW_230627_279}",
    answer2 = "#{ZMSW_230627_304}",
    answer3 = "#{ZMSW_230627_329}",
    answerid = 3
  },
  [10] = {
    question = "#{ZMSW_230627_255}",
    answer1 = "#{ZMSW_230627_280}",
    answer2 = "#{ZMSW_230627_305}",
    answer3 = "#{ZMSW_230627_330}",
    answerid = 1
  },
  [11] = {
    question = "#{ZMSW_230627_256}",
    answer1 = "#{ZMSW_230627_281}",
    answer2 = "#{ZMSW_230627_306}",
    answer3 = "#{ZMSW_230627_331}",
    answerid = 2
  },
  [12] = {
    question = "#{ZMSW_230627_257}",
    answer1 = "#{ZMSW_230627_282}",
    answer2 = "#{ZMSW_230627_307}",
    answer3 = "#{ZMSW_230627_332}",
    answerid = 3
  },
  [13] = {
    question = "#{ZMSW_230627_258}",
    answer1 = "#{ZMSW_230627_283}",
    answer2 = "#{ZMSW_230627_308}",
    answer3 = "#{ZMSW_230627_333}",
    answerid = 1
  },
  [14] = {
    question = "#{ZMSW_230627_259}",
    answer1 = "#{ZMSW_230627_284}",
    answer2 = "#{ZMSW_230627_309}",
    answer3 = "#{ZMSW_230627_334}",
    answerid = 2
  },
  [15] = {
    question = "#{ZMSW_230627_260}",
    answer1 = "#{ZMSW_230627_285}",
    answer2 = "#{ZMSW_230627_310}",
    answer3 = "#{ZMSW_230627_335}",
    answerid = 3
  },
  [16] = {
    question = "#{ZMSW_230627_261}",
    answer1 = "#{ZMSW_230627_286}",
    answer2 = "#{ZMSW_230627_311}",
    answer3 = "#{ZMSW_230627_336}",
    answerid = 1
  },
  [17] = {
    question = "#{ZMSW_230627_262}",
    answer1 = "#{ZMSW_230627_287}",
    answer2 = "#{ZMSW_230627_312}",
    answer3 = "#{ZMSW_230627_337}",
    answerid = 2
  },
  [18] = {
    question = "#{ZMSW_230627_263}",
    answer1 = "#{ZMSW_230627_288}",
    answer2 = "#{ZMSW_230627_313}",
    answer3 = "#{ZMSW_230627_338}",
    answerid = 3
  },
  [19] = {
    question = "#{ZMSW_230627_264}",
    answer1 = "#{ZMSW_230627_289}",
    answer2 = "#{ZMSW_230627_314}",
    answer3 = "#{ZMSW_230627_339}",
    answerid = 1
  },
  [20] = {
    question = "#{ZMSW_230627_265}",
    answer1 = "#{ZMSW_230627_290}",
    answer2 = "#{ZMSW_230627_315}",
    answer3 = "#{ZMSW_230627_340}",
    answerid = 2
  },
  [21] = {
    question = "#{ZMSW_230627_266}",
    answer1 = "#{ZMSW_230627_291}",
    answer2 = "#{ZMSW_230627_316}",
    answer3 = "#{ZMSW_230627_341}",
    answerid = 3
  },
  [22] = {
    question = "#{ZMSW_230627_267}",
    answer1 = "#{ZMSW_230627_292}",
    answer2 = "#{ZMSW_230627_317}",
    answer3 = "#{ZMSW_230627_342}",
    answerid = 1
  },
  [23] = {
    question = "#{ZMSW_230627_268}",
    answer1 = "#{ZMSW_230627_293}",
    answer2 = "#{ZMSW_230627_318}",
    answer3 = "#{ZMSW_230627_343}",
    answerid = 2
  },
  [24] = {
    question = "#{ZMSW_230627_269}",
    answer1 = "#{ZMSW_230627_294}",
    answer2 = "#{ZMSW_230627_319}",
    answer3 = "#{ZMSW_230627_344}",
    answerid = 3
  },
  [25] = {
    question = "#{ZMSW_230627_270}",
    answer1 = "#{ZMSW_230627_295}",
    answer2 = "#{ZMSW_230627_320}",
    answer3 = "#{ZMSW_230627_345}",
    answerid = 1
  },
  [26] = {
    question = "#{ZMSW_230627_271}",
    answer1 = "#{ZMSW_230627_296}",
    answer2 = "#{ZMSW_230627_321}",
    answer3 = "#{ZMSW_230627_346}",
    answerid = 2
  },
  [27] = {
    question = "#{ZMSW_230627_272}",
    answer1 = "#{ZMSW_230627_297}",
    answer2 = "#{ZMSW_230627_322}",
    answer3 = "#{ZMSW_230627_347}",
    answerid = 3
  },
  [28] = {
    question = "#{ZMSW_230627_273}",
    answer1 = "#{ZMSW_230627_298}",
    answer2 = "#{ZMSW_230627_323}",
    answer3 = "#{ZMSW_230627_348}",
    answerid = 1
  },
  [29] = {
    question = "#{ZMSW_230627_274}",
    answer1 = "#{ZMSW_230627_299}",
    answer2 = "#{ZMSW_230627_324}",
    answer3 = "#{ZMSW_230627_349}",
    answerid = 2
  },
  [30] = {
    question = "#{ZMSW_230627_275}",
    answer1 = "#{ZMSW_230627_300}",
    answer2 = "#{ZMSW_230627_325}",
    answer3 = "#{ZMSW_230627_350}",
    answerid = 3
  },
  [31] = {
    question = "#{ZMSW_230627_409}",
    answer1 = "#{ZMSW_230627_410}",
    answer2 = "#{ZMSW_230627_415}",
    answer3 = "#{ZMSW_230627_416}",
    answerid = 2
  },
  [32] = {
    question = "#{ZMSW_230627_408}",
    answer1 = "#{ZMSW_230627_411}",
    answer2 = "#{ZMSW_230627_412}",
    answer3 = "#{ZMSW_230627_413}",
    answerid = 1
  }
}

local function ZM_GetFubenInfo(aScene)
  local nScene = aScene or GetSceneID()
  for i = 1, #m_fuben_npc do
    local tmp = m_fuben_npc[i]
    if tmp.sceneID == nScene then
      return tmp
    end
  end
  return nil
end

local function zm_move_in_cb(...)
  local info = ZM_GetFubenInfo()
  if info then
    return true
  end
  return false
end

local function zm_move_unin_cb(...)
  local info = ZM_GetFubenInfo()
  if info then
    return false
  end
  return true
end

local function zm_move_leave_cb(...)
  local info = ZM_GetFubenInfo()
  if info then
    MoveToNPC(info.npcname, info.x, info.y, info.sceneID, nil, nil, nil, zm_move_in_cb)
    QuestFrameOptionClicked_Item("#{ZMSW_230627_352}", 1, 1000)
  end
  return true
end

local function QuestLog_GetRiChangMission_Str(mpindex, posindex)
  local rList = {
    [0] = {
      npclink = "#{ZMSW_230627_159}",
      caijiname = "#{ZMSW_230627_173}",
      npcname = "#{ZMSW_230627_366}",
      tnpcname = "#{ZMSW_230627_383}",
      actionposlink = "#{ZMSW_230627_229}",
      poslink = {
        "#{ZMSW_230627_187}",
        "#{ZMSW_230627_201}",
        "#{ZMSW_230627_215}"
      },
      mpname = "少林"
    },
    [1] = {
      npclink = "#{ZMSW_230627_160}",
      caijiname = "#{ZMSW_230627_174}",
      npcname = "#{ZMSW_230627_367}",
      tnpcname = "#{ZMSW_230627_384}",
      actionposlink = "#{ZMSW_230627_230}",
      poslink = {
        "#{ZMSW_230627_188}",
        "#{ZMSW_230627_202}",
        "#{ZMSW_230627_216}"
      },
      mpname = "明教"
    },
    [2] = {
      npclink = "#{ZMSW_230627_161}",
      caijiname = "#{ZMSW_230627_175}",
      npcname = "#{ZMSW_230627_368}",
      tnpcname = "#{ZMSW_230627_385}",
      actionposlink = "#{ZMSW_230627_231}",
      poslink = {
        "#{ZMSW_230627_189}",
        "#{ZMSW_230627_203}",
        "#{ZMSW_230627_217}"
      },
      mpname = "丐帮"
    },
    [3] = {
      npclink = "#{ZMSW_230627_162}",
      caijiname = "#{ZMSW_230627_176}",
      npcname = "#{ZMSW_230627_369}",
      tnpcname = "#{ZMSW_230627_386}",
      actionposlink = "#{ZMSW_230627_232}",
      poslink = {
        "#{ZMSW_230627_190}",
        "#{ZMSW_230627_204}",
        "#{ZMSW_230627_218}"
      },
      mpname = "武当"
    },
    [4] = {
      npclink = "#{ZMSW_230627_163}",
      caijiname = "#{ZMSW_230627_177}",
      npcname = "#{ZMSW_230627_370}",
      tnpcname = "#{ZMSW_230627_387}",
      actionposlink = "#{ZMSW_230627_233}",
      poslink = {
        "#{ZMSW_230627_191}",
        "#{ZMSW_230627_205}",
        "#{ZMSW_230627_219}"
      },
      mpname = "峨嵋"
    },
    [5] = {
      npclink = "#{ZMSW_230627_164}",
      caijiname = "#{ZMSW_230627_178}",
      npcname = "#{ZMSW_230627_371}",
      tnpcname = "#{ZMSW_230627_388}",
      actionposlink = "#{ZMSW_230627_234}",
      poslink = {
        "#{ZMSW_230627_192}",
        "#{ZMSW_230627_206}",
        "#{ZMSW_230627_220}"
      },
      mpname = "星宿"
    },
    [6] = {
      npclink = "#{ZMSW_230627_165}",
      caijiname = "#{ZMSW_230627_179}",
      npcname = "#{ZMSW_230627_372}",
      tnpcname = "#{ZMSW_230627_389}",
      actionposlink = "#{ZMSW_230627_235}",
      poslink = {
        "#{ZMSW_230627_193}",
        "#{ZMSW_230627_207}",
        "#{ZMSW_230627_221}"
      },
      mpname = "天龙"
    },
    [7] = {
      npclink = "#{ZMSW_230627_166}",
      caijiname = "#{ZMSW_230627_180}",
      npcname = "#{ZMSW_230627_373}",
      tnpcname = "#{ZMSW_230627_390}",
      actionposlink = "#{ZMSW_230627_236}",
      poslink = {
        "#{ZMSW_230627_194}",
        "#{ZMSW_230627_208}",
        "#{ZMSW_230627_222}"
      },
      mpname = "天山"
    },
    [8] = {
      npclink = "#{ZMSW_230627_167}",
      caijiname = "#{ZMSW_230627_181}",
      npcname = "#{ZMSW_230627_374}",
      tnpcname = "#{ZMSW_230627_391}",
      actionposlink = "#{ZMSW_230627_237}",
      poslink = {
        "#{ZMSW_230627_195}",
        "#{ZMSW_230627_209}",
        "#{ZMSW_230627_223}"
      },
      mpname = "逍遥"
    },
    [10] = {
      npclink = "#{ZMSW_230627_168}",
      caijiname = "#{ZMSW_230627_182}",
      npcname = "#{ZMSW_230627_375}",
      tnpcname = "#{ZMSW_230627_392}",
      actionposlink = "#{ZMSW_230627_238}",
      poslink = {
        "#{ZMSW_230627_196}",
        "#{ZMSW_230627_210}",
        "#{ZMSW_230627_224}"
      },
      mpname = "慕容"
    },
    [11] = {
      npclink = "#{ZMSW_230627_169}",
      caijiname = "#{ZMSW_230627_183}",
      npcname = "#{ZMSW_230627_376}",
      tnpcname = "#{ZMSW_230627_393}",
      actionposlink = "#{ZMSW_230627_239}",
      poslink = {
        "#{ZMSW_230627_197}",
        "#{ZMSW_230627_211}",
        "#{ZMSW_230627_225}"
      },
      mpname = "唐门"
    },
    [12] = {
      npclink = "#{ZMSW_230627_170}",
      caijiname = "#{ZMSW_230627_184}",
      npcname = "#{ZMSW_230627_377}",
      tnpcname = "#{ZMSW_230627_394}",
      actionposlink = "#{ZMSW_230627_240}",
      poslink = {
        "#{ZMSW_230627_198}",
        "#{ZMSW_230627_212}",
        "#{ZMSW_230627_226}"
      },
      mpname = "鬼谷"
    },
    [13] = {
      npclink = "#{ZMSW_230627_171}",
      caijiname = "#{ZMSW_230627_185}",
      npcname = "#{ZMSW_230627_378}",
      tnpcname = "#{ZMSW_230627_395}",
      actionposlink = "#{ZMSW_230627_241}",
      poslink = {
        "#{ZMSW_230627_199}",
        "#{ZMSW_230627_213}",
        "#{ZMSW_230627_227}"
      },
      mpname = "桃花岛"
    },
    [14] = {
      npclink = "#{ZMSW_230627_172}",
      caijiname = "#{ZMSW_230627_186}",
      npcname = "#{ZMSW_230627_379}",
      tnpcname = "#{ZMSW_230627_396}",
      actionposlink = "#{ZMSW_230627_242}",
      poslink = {
        "#{ZMSW_230627_200}",
        "#{ZMSW_230627_214}",
        "#{ZMSW_230627_228}"
      },
      mpname = "绝情谷"
    },
    [15] = {
      npclink = "#{ZMSW_230627_400}",
      caijiname = "#{ZMSW_230627_401}",
      npcname = "#{ZMSW_230627_407}",
      tnpcname = "#{ZMSW_230627_406}",
      actionposlink = "#{ZMSW_230627_405}",
      poslink = {
        "#{ZMSW_230627_402}",
        "#{ZMSW_230627_403}",
        "#{ZMSW_230627_404}"
      },
      mpname = "恶人谷"
    }
  }
  local tList = rList[mpindex]
  if nil ~= tList then
    if nil ~= posindex and tList.poslink[posindex] ~= nil then
      return tList.mpname, tList.npcname, tList.npclink, tList.caijiname, tList.actionposlink, tList.poslink[posindex], tList.tnpcname
    else
      return tList.mpname, tList.npcname, tList.npclink, tList.caijiname, tList.actionposlink, "", tList.tnpcname
    end
  end
  return "", "", "", "", "", "", ""
end

local function ZM_OnMission1(aParam)
  local mpindex = aParam[3]
  local selfmpindex = aParam[4]
  local mpname, npcname, npclink, caijiname, actionposlink, poslink, tnpcname = QuestLog_GetRiChangMission_Str(mpindex)
  local poslink = GetDictionaryString(npclink)
  local _, _, xPos, yPos, nScene, npcName = string.find(poslink, "#{_INFOAIM(%d+),(%d+),(%d+),(.+)}")
  xPos = tonumber(xPos)
  yPos = tonumber(yPos)
  nScene = tonumber(nScene)
  if xPos and yPos and nScene and npcName then
    GoToSceneNPC(npcName, xPos, yPos, nScene)
    QuestFrameOptionClicked_Item("#{ZMSW_230627_152}", 1, 800)
  else
    PushColorMsg(m_script_name .. "：任务1参数错误")
  end
end

local function ZM_OnMission2(aParam)
  local selfmpindex = aParam[4]
  local selfmpname, selfnpcname, selfnpclink, selfcaijiname, selfactionposlink, selfposlink, selftnpcname = QuestLog_GetRiChangMission_Str(selfmpindex)
  if "峨眉" == selfmpname then
    selfmpname = "峨嵋"
  end
  local caijiname = GetDictionaryString(selfcaijiname)
  if "千叶莲" == caijiname then
    caijiname = "莲花缸"
  elseif "天圣火种" == caijiname then
    caijiname = "圣火坛"
  elseif "武学典藏" == caijiname then
    caijiname = "典藏书架"
  elseif "机关弩" == caijiname then
    caijiname = "白坚木"
  elseif "枫叶书笺" == caijiname then
    caijiname = "枫叶"
  end
  local nSceneID = -1
  for i, v in pairs(m_mission_npc) do
    if m_mission_npc[i].mpname == selfmpname then
      nSceneID = m_mission_npc[i].sceneID
    end
  end
  local caijipos = m_caiji_pos[selfmpname]
  if caijipos and -1 ~= nSceneID and "" ~= caijiname then
    local function caiji_cb()
      m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item("#{ZMSW_230627_19}")
      
      m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
      if -1 == m_param.misIndex or 0 ~= m_param.param[0] then
        return true
      end
      return false
    end
    
    BeginCaiji(caijiname, nSceneID, caijipos, caiji_cb)
  end
end

local function ZM_OnMission3(aParam)
  local selfmpindex = aParam[4]
  local posindex = aParam[3]
  local g_TaskItemId3 = 38006916
  local taskItemName3 = "纸墨笔砚"
  local selfmpname, selfnpcname, selfnpclink, selfcaijiname, selfactionposlink, selfposlink, selftnpcname = QuestLog_GetRiChangMission_Str(selfmpindex, posindex)
  local poslink = GetDictionaryString(selfposlink)
  local _, _, xPos, yPos, nScene = string.find(poslink, "#{_INFOAIM(%d+),(%d+),(%d+),")
  xPos = tonumber(xPos)
  yPos = tonumber(yPos)
  nScene = tonumber(nScene)
  if xPos and yPos and nScene then
    if 95 == xPos and 180 == yPos and 889 == nScene then
      yPos = 175
    end
    if 58 == xPos and 96 == yPos and 885 == nScene then
      xPos = 54
      yPos = 96
    end
    GoToScene(xPos, yPos, nScene, 5)
    Dismount(500)
    Bag:UseItemByName_click(taskItemName3, 1000)
    PlayerStateTimeOut(5, 5)
  else
    PushColorMsg(m_script_name .. "：任务3参数错误")
  end
end

local function ZM_OnMission4(aParam)
  local selfmpindex = aParam[4]
  local selfmpname, selfnpcname, selfnpclink, selfcaijiname, selfactionposlink, selfposlink, selftnpcname = QuestLog_GetRiChangMission_Str(selfmpindex)
  local poslink = GetDictionaryString(selfnpclink)
  local info = ZM_GetFubenInfo()
  if info then
    CDG.sceneID = info.sceneID
    CDG.attackMode = "打死换怪"
    CDG.pickup = false
    CDG.overMapErr = true
    CDG.die.out = true
    CDG.posRadius = 15
    CDG.tragetSelect = true
    CDG.die.maxCount = 0
    CDG.savebank = false
    CDG.pos = {}
    CDG.posIdx = GetNearestPoint(CDG.pos)
    CDG:SetTimeOut(100)
    
    local function CDG_loop_callback(...)
      DebugStr("闲常治务：打怪中.")
      if GetSceneID() ~= info.sceneID then
        return true
      end
      local nComp = GetMissionVariable(m_param.misIndex, 0)
      if 0 == nComp then
      else
        PushColorMsg("闲常治务：任务4完成")
        return true
      end
      return false
    end
    
    local function sf_move_cb_in_fb(...)
      return true
    end
    
    CDG.callfun = CDG_loop_callback
    CDG.callfun_move = sf_move_cb_in_fb
    CDG:OnStart()
    return
  end
  local _, _, xPos, yPos, nScene, npcName = string.find(poslink, "#{_INFOAIM(%d+),(%d+),(%d+),(.+)}")
  xPos = tonumber(xPos)
  yPos = tonumber(yPos)
  nScene = tonumber(nScene)
  if xPos and yPos and nScene and npcName then
    MoveToNPC(npcName, xPos, yPos, nScene, nil, nil, nil, zm_move_unin_cb)
    QuestFrameOptionClicked_Item("#{ZMSW_230627_03}", 1, 800)
    QuestFrameOptionClicked_Item("#{ZMSW_230627_99}", 1, 800)
  else
    PushColorMsg(m_script_name .. "：任务4参数1错误")
  end
end

local function ZM_OnMission5(aParam)
  local question = GetNPCEventList_Item(0)
  for i = 1, #g_QuestionList do
    local tmp = g_QuestionList[i]
    if question == tmp.question then
      local answer = tmp["answer" .. tmp.answerid]
      QuestFrameOptionClicked_Item(answer, 1, 800)
      QuestFrameOptionClicked_Item("#{ZMSW_230627_111}", 1, 800)
      return
    end
  end
  local selfmpindex = aParam[4]
  local selfmpname, selfnpcname, selfnpclink, selfcaijiname, selfactionposlink, selfposlink, selftnpcname = QuestLog_GetRiChangMission_Str(selfmpindex)
  local poslink = GetDictionaryString(selfnpclink)
  local _, _, xPos, yPos, nScene, npcName = string.find(poslink, "#{_INFOAIM(%d+),(%d+),(%d+),(.+)}")
  xPos = tonumber(xPos)
  yPos = tonumber(yPos)
  nScene = tonumber(nScene)
  if xPos and yPos and nScene and npcName then
    MoveToNPC(npcName, xPos, yPos, nScene)
    QuestFrameOptionClicked_Item("#{ZMSW_230627_03}", 1, 800)
    QuestFrameOptionClicked_Item("#{ZMSW_230627_111}", 1, 800)
  end
end

local function ZM_OnMission6(aParam)
  local selfmpindex = aParam[4]
  local selfmpname, selfnpcname, selfnpclink, selfcaijiname, selfactionposlink, selfposlink, selftnpcname = QuestLog_GetRiChangMission_Str(selfmpindex)
  local poslink = GetDictionaryString(selfactionposlink)
  local _, _, xPos, yPos, nScene, npcName = string.find(poslink, "#{_INFOAIM(%d+),(%d+),(%d+),(.+)}")
  xPos = tonumber(xPos)
  yPos = tonumber(yPos)
  nScene = tonumber(nScene)
  if xPos and yPos and nScene and npcName then
    GoToScene(xPos, yPos, nScene)
    Dismount(500)
    local tObj = Enum2XByName(npcName, {
      1,
      0,
      0,
      0
    })
    if #tObj > 0 then
      local tmp = tObj[1]
      Skill.CUseSkillByID(4956, tmp.id, -1, -1)
      Sleep(1000)
      PlayerStateTimeOut(5, 15)
    end
  else
    PushColorMsg(m_script_name .. "：任务6参数错误")
  end
end

local function ZM_OnMission7(aParam)
  local tObj = Enum2XByClass("玩家")
  BubbleByDst(tObj)
  local target
  for i = 1, #tObj do
    local tmp = tObj[i]
    if tmp.name ~= g_self.name and GetMenpaiIDByTypeID(tmp.menpai) == g_self.menpai then
      target = tmp
      break
    end
  end
  if target then
    PushColorMsg(m_script_name .. ":" .. target.name)
    RunTo(target.x, target.y, 3, 1000)
    PlayerStateTimeOut(2, 5)
    Dismount(600)
    Target:Select(target.id, 500)
    Bag:UseItemByName_click("名家书画", 3000)
    PlayerStateTimeOut(5, 6)
  else
    local npc = m_npc_shimen[g_self.menpai]
    if 3 == g_client_type then
      npc = {
        x = 155,
        y = 150,
        sceneID = 2
      }
    end
    MoveTo(npc.x, npc.y, npc.sceneID)
  end
end

function _SMain(...)
  LoadScript("caiji")
  local misNpc = m_mission_npc[g_self.menpai]
  if not misNpc then
    LogMsg(m_script_name .. ":门派获取错误")
    return
  end
  while true do
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission_Item("#{ZMSW_230627_19}")
    if -1 ~= m_param.misIndex then
      for i = 0, 4 do
        m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
      end
      if 1 == m_param.param[0] then
        local npc = misNpc
        MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, zm_move_leave_cb)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{ZMSW_230627_03}", 1, 800)
        QuestFrameNextClicked(600)
        QuestFrameMissionComplete(nil, 500)
      else
        local missionType = m_param.param[2]
        if 1 == missionType then
          ZM_OnMission1(m_param.param)
        elseif 2 == missionType then
          ZM_OnMission2(m_param.param)
        elseif 3 == missionType then
          ZM_OnMission3(m_param.param)
        elseif 4 == missionType then
          ZM_OnMission4(m_param.param)
        elseif 5 == missionType then
          ZM_OnMission5(m_param.param)
        elseif 6 == missionType then
          ZM_OnMission6(m_param.param)
        else
          if 7 == missionType then
            ZM_OnMission7(m_param.param)
          else
          end
        end
      end
    else
      GoToSceneNPC(misNpc.name, misNpc.x, misNpc.y, misNpc.sceneID)
      Sleep(500)
      QuestFrameOptionClicked_Item("#{ZMSW_230627_03}", 1, 800)
      local strText = GetNPCEventList_Item(0)
      if string.find(strText, "#{ZMSW_230627_35}", nil, true) then
        GoToSceneNPC(misNpc.name, misNpc.x, misNpc.y, misNpc.sceneID)
        Sleep(500)
        QuestFrameOptionClicked_Item("#{ZMJJ_230711_20}", 1, 800)
        if Bag:GetItemCount("荣赏令") > 0 then
          QuestFrameOptionClicked_Item("#{ZMJJ_230711_22}", 1, 800)
        else
          QuestFrameOptionClicked_Item("#{ZMJJ_230711_21}", 1, 800)
        end
        QuestFrameOptionClicked_Item("#{ZMJJ_230711_13}", 1, 800)
      elseif string.find(strText, "#{ZMSW_230627_37}", nil, true) then
        LogMsg("闲常治务:本周已完成")
        break
      elseif string.find(strText, "#{ZMSW_230627_39}", nil, true) then
        LogMsg("闲常治务:今日已完成")
        break
      end
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
