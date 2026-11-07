-- 反编译自 dfz64.dll 内嵌字节码 0025fb7b（unluac 2025-12-23；仅供分析）
local m_script_name = "师门任务11"
ScriptOnStart(m_script_name, true, false)
CDG.tragetSelect = true
CDG.attack = true
CDG.jgyc = true
local m_param = {}
m_param.missionName = "师门任务"
m_param.misIndex = -1
m_param.misID = -1
m_param.misScriptID = -1
m_param.param = {}
m_param.tjqq = true
m_param.tmxz = ReadConfigBool("ZH", "xzk56")
m_param.wait15_over = false
m_param.round = 0
m_param.catchFilter = {}
m_param.allRound = ReadConfigInt("ZH", "bjk29")
if m_param.allRound <= 0 then
  m_param.allRound = 60
end
m_param.not_catchpet = ReadConfigBool("ZH", "xzk187")
m_param.buyItem = ReadConfigBool("ZH", "xzk58")
m_param.item_j = ReadConfigInt("ZH", "bjk26")
m_param.item_y = ReadConfigInt("ZH", "bjk27")
m_param.item_t = ReadConfigInt("ZH", "bjk28")
local m_strList = {}
m_strList[0] = {
  [0] = "大扫帚",
  [1] = "大雄宝殿",
  [2] = "藏经阁",
  [3] = "山门",
  [4] = "钟楼",
  [5] = "玄澄",
  [6] = "塔林副本",
  [7] = "散落的柴火",
  [8] = "散落的蘑菇",
  [9] = "散落的松果",
  [10] = "潘玄耕",
  [11] = "卫玄望",
  [12] = "方玄劳",
  [13] = "野生柴猫",
  [14] = "地面",
  [15] = "本相",
  [16] = "孟青青",
  [17] = "佛印",
  [18] = "方腊",
  [19] = "菊剑",
  [20] = "林灵素",
  [21] = "冯阿三",
  [22] = "红玉",
  [23] = "塔底副本",
  [24] = "桃花阵副本",
  [25] = "酒窖副本",
  [26] = "光明洞副本",
  [27] = "折梅峰副本",
  [28] = "灵性峰副",
  [29] = "谷底副本",
  [30] = "五神洞副本",
  [31] = "少林",
  [32] = "天龙",
  [33] = "峨嵋",
  [34] = "丐帮",
  [35] = "明教",
  [36] = "天山",
  [37] = "武当",
  [38] = "逍遥",
  [39] = "星宿",
  [40] = "0",
  [41] = "1",
  [42] = "2",
  [43] = "3",
  [44] = "4",
  [45] = "5",
  [46] = "6",
  [47] = "7",
  [48] = "8",
  [49] = "9"
}
m_strList[1] = {
  [0] = "火炬",
  [1] = "黄土旗",
  [2] = "青木旗",
  [3] = "白金旗",
  [4] = "黑水旗",
  [5] = "方腊",
  [6] = "光明洞副本",
  [7] = "宋军记号",
  [8] = "辽国记号",
  [9] = "波斯记号",
  [10] = "吕师襄",
  [11] = "余道安",
  [12] = "玛拉",
  [13] = "野生柴猫",
  [14] = "圣火坛",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9"
}
m_strList[2] = {
  [0] = "酒坛",
  [1] = "小桃园",
  [2] = "杜康祠",
  [3] = "演兵坛",
  [4] = "西厢房",
  [5] = "佛印",
  [6] = "酒窖副本",
  [7] = "小青蛇",
  [8] = "小白蛇",
  [9] = "小红蛇",
  [10] = "全冠清",
  [11] = "陈孤雁",
  [12] = "吴长风",
  [13] = "野生柴猫",
  [14] = "酒缸",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9"
}
m_strList[3] = {
  [0] = "紫金葫芦",
  [1] = "金殿",
  [2] = "解剑池",
  [3] = "回龙台",
  [4] = "天阶",
  [5] = "林灵素",
  [6] = "灵性峰副本",
  [7] = "武当灵芝",
  [8] = "武当首乌",
  [9] = "武当人参",
  [10] = "青冥神鹤",
  [11] = "九天神鹤",
  [12] = "无极神鹤",
  [13] = "野生柴猫",
  [14] = "云雾",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9"
}
m_strList[4] = {
  [0] = "峨嵋仙露",
  [1] = "珙椿晓雨",
  [2] = "白水秋风",
  [3] = "私语台",
  [4] = "长生殿",
  [5] = "孟青青",
  [6] = "桃花阵副本",
  [7] = "遗失的首饰",
  [8] = "遗失的祭品",
  [9] = "遗失的珠宝",
  [10] = "桃花仙",
  [11] = "桃叶仙",
  [12] = "桃枝仙",
  [13] = "野生柴猫",
  [14] = "金顶凤凰",
  [15] = "灵泉凤凰",
  [16] = "佛光凤凰",
  [17] = "万年凤凰",
  [18] = "0",
  [19] = "1",
  [20] = "2",
  [21] = "3",
  [22] = "4",
  [23] = "5",
  [24] = "6",
  [25] = "7",
  [26] = "8",
  [27] = "9"
}
m_strList[5] = {
  [0] = "五毒虫",
  [1] = "毒蟾蜍箱",
  [2] = "毒蜈蚣箱",
  [3] = "毒蜘蛛箱",
  [4] = "毒蝎子箱",
  [5] = "红玉",
  [6] = "五神洞副本",
  [7] = "毒蜈蚣",
  [8] = "毒蟾蜍",
  [9] = "毒蜘蛛",
  [10] = "西域药篓子",
  [11] = "契丹药篓子",
  [12] = "大理药篓子",
  [13] = "野生柴猫",
  [14] = "日月宫",
  [15] = "方丈殿",
  [16] = "瀛洲殿",
  [17] = "蓬莱殿",
  [18] = "0",
  [19] = "1",
  [20] = "2",
  [21] = "3",
  [22] = "4",
  [23] = "5",
  [24] = "6",
  [25] = "7",
  [26] = "8",
  [27] = "9"
}
m_strList[6] = {
  [0] = "医用金针",
  [1] = "经脉铜人区",
  [2] = "经脉铜人区",
  [3] = "经脉铜人区",
  [4] = "经脉铜人区",
  [5] = "本相",
  [6] = "塔底副本",
  [7] = "满月",
  [8] = "眼儿媚",
  [9] = "红妆素裹",
  [10] = "伍忠",
  [11] = "林国清",
  [12] = "齐归蝶",
  [13] = "野生柴猫",
  [14] = "手太阴肺经铜人",
  [15] = "手阳明肠经铜人",
  [16] = "足阳明胃经铜人",
  [17] = "足太阴脾经铜人",
  [18] = "0",
  [19] = "1",
  [20] = "2",
  [21] = "3",
  [22] = "4",
  [23] = "5",
  [24] = "6",
  [25] = "7",
  [26] = "8",
  [27] = "9"
}
m_strList[7] = {
  [0] = "天池水",
  [1] = "石露水",
  [2] = "冷泉水",
  [3] = "融冰水",
  [4] = "玄冰戽",
  [5] = "寒冰戽",
  [6] = "碎冰戽",
  [7] = "岩冰戽",
  [8] = "菊剑",
  [9] = "折梅峰副本",
  [10] = "葡萄干",
  [11] = "雪莲花",
  [12] = "哈密瓜",
  [13] = "石嫂",
  [14] = "芦雨亭",
  [15] = "任飞虹",
  [16] = "野生柴猫",
  [17] = "0",
  [18] = "1",
  [19] = "2",
  [20] = "3",
  [21] = "4",
  [22] = "5",
  [23] = "6",
  [24] = "7",
  [25] = "8",
  [26] = "9"
}
m_strList[8] = {
  [0] = "时光机",
  [1] = "思恩",
  [2] = "珍珑",
  [3] = "大观",
  [4] = "点军",
  [5] = "冯阿三",
  [6] = "谷底副本",
  [7] = "逍遥木制零件",
  [8] = "逍遥石制零件",
  [9] = "逍遥铜制零件",
  [10] = "木人傀儡",
  [11] = "铜人傀儡",
  [12] = "石人傀儡",
  [13] = "野生柴猫",
  [14] = "凤凰琴",
  [15] = "烂柯棋",
  [16] = "圣贤书",
  [17] = "丹青画",
  [18] = "0",
  [19] = "1",
  [20] = "2",
  [21] = "3",
  [22] = "4",
  [23] = "5",
  [24] = "6",
  [25] = "7",
  [26] = "8",
  [27] = "9"
}
m_strList[9] = {}
m_strList[10] = {
  [0] = "水壶",
  [1] = "听香水榭",
  [2] = "琴音小筑",
  [3] = "参合庄",
  [4] = "曼陀园",
  [5] = "慕容垂",
  [6] = "水阁副本",
  [7] = "散落的盔甲",
  [8] = "散落的盾牌",
  [9] = "散落的兵器",
  [10] = "全冠清",
  [11] = "陈孤雁",
  [12] = "吴长风",
  [13] = "野生柴猫",
  [14] = "酒缸",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9",
  [25] = "十八学士",
  [26] = "状元红",
  [27] = "花鹤令",
  [28] = "红露珍"
}
m_strList[11] = {
  [0] = "金钥",
  [1] = "演武场",
  [2] = "风羽楼",
  [3] = "千机坊",
  [4] = "唐家内堡",
  [5] = "唐岳天",
  [6] = "演武场副本",
  [7] = "云鸩翎",
  [8] = "青铜",
  [9] = "寒雪锻石",
  [10] = "全冠清",
  [11] = "陈孤雁",
  [12] = "吴长风",
  [13] = "野生柴猫",
  [14] = "云炉",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9",
  [25] = "演武场",
  [26] = "风羽楼",
  [27] = "千机坊",
  [28] = "唐家内堡"
}
m_strList[12] = {
  [0] = "竹筒",
  [1] = "巫山境",
  [2] = "玄狐苑",
  [3] = "阴阳天东侧",
  [4] = "观星台",
  [5] = "王栩之",
  [6] = "幻阵坪副本",
  [7] = "八卦镜",
  [8] = "令旗",
  [9] = "六面法印",
  [10] = "全冠清",
  [11] = "陈孤雁",
  [12] = "吴长风",
  [13] = "野生柴猫",
  [14] = "瀑布",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9",
  [25] = "巫山境",
  [26] = "玄狐苑",
  [27] = "阴阳天东侧",
  [28] = "观星台"
}
m_strList[13] = {
  [0] = "写生工具",
  [1] = "春闲情",
  [2] = "一苇航",
  [3] = "三问居",
  [4] = "湛若水",
  [5] = "枕梦归",
  [6] = "三百迷津副本",
  [7] = "离魂",
  [8] = "幻海沉香木",
  [9] = "忘忧果",
  [10] = "全冠清",
  [11] = "陈孤雁",
  [12] = "吴长风",
  [13] = "野生柴猫",
  [14] = "长廊",
  [15] = "0",
  [16] = "1",
  [17] = "2",
  [18] = "3",
  [19] = "4",
  [20] = "5",
  [21] = "6",
  [22] = "7",
  [23] = "8",
  [24] = "9",
  [25] = "春闲情",
  [26] = "一苇航",
  [27] = "三问居",
  [28] = "湛若水",
  [29] = "渡口",
  [30] = "庭院",
  [31] = "桃林"
}
m_strList[14] = {
  [0] = "笔墨",
  [1] = "听枫唱晚",
  [2] = "白云涧",
  [3] = "灵乌苑",
  [4] = "藏锋楼",
  [5] = "穆宇",
  [6] = "三庭洞天",
  [7] = "乌羽团扇",
  [8] = "枫糖",
  [9] = "琉璃石",
  [10] = "临水台",
  [11] = "观景台",
  [12] = "前院",
  [13] = "楼前广场",
  [14] = "0",
  [15] = "1",
  [16] = "2",
  [17] = "3",
  [18] = "4",
  [19] = "5",
  [20] = "6",
  [21] = "7",
  [22] = "8",
  [23] = "9",
  [24] = "听枫唱晚#{_INFOAIM369,327,824,}",
  [25] = "白云涧#{_INFOAIM258,33,824,}",
  [26] = "灵乌苑#{_INFOAIM122,252,824,}",
  [27] = "藏锋楼#{_INFOAIM278,251,824,}"
}
m_strList[15] = {
  [0] = "孔明灯",
  [1] = "盘山小径",
  [2] = "云崖深处",
  [3] = "奔流涧",
  [4] = "苦情小筑",
  [5] = "山鬼",
  [6] = "青崖山涧",
  [7] = "枯骨",
  [8] = "鳄鱼蛋",
  [9] = "一品红",
  [10] = "望兽坪",
  [11] = "云崖台",
  [12] = "团山亭台",
  [13] = "前庭",
  [14] = "0",
  [15] = "1",
  [16] = "2",
  [17] = "3",
  [18] = "4",
  [19] = "5",
  [20] = "6",
  [21] = "7",
  [22] = "8",
  [23] = "9",
  [24] = "盘山小径#{_INFOAIM57,206,987,}",
  [25] = "云崖深处#{_INFOAIM46,62,987,}",
  [26] = "奔流涧#{_INFOAIM125,115,987,}",
  [27] = "苦情小筑#{_INFOAIM178,126,987,}"
}
local m_item_pos = {
  ["大雄宝殿"] = {
    x = 94,
    y = 70,
    sceneID = 9
  },
  ["藏经阁"] = {
    x = 134,
    y = 135,
    sceneID = 9
  },
  ["山门"] = {
    x = 96,
    y = 125,
    sceneID = 9
  },
  ["钟楼"] = {
    x = 69,
    y = 62,
    sceneID = 9
  },
  ["黄土旗"] = {
    x = 59,
    y = 52,
    sceneID = 11
  },
  ["青木旗"] = {
    x = 131,
    y = 142,
    sceneID = 11
  },
  ["白金旗"] = {
    x = 60,
    y = 141,
    sceneID = 11
  },
  ["黑水旗"] = {
    x = 143,
    y = 57,
    sceneID = 11
  },
  ["小桃园"] = {
    x = 39,
    y = 147,
    sceneID = 10
  },
  ["杜康祠"] = {
    x = 132,
    y = 112,
    sceneID = 10
  },
  ["演兵坛"] = {
    x = 46,
    y = 36,
    sceneID = 10
  },
  ["西厢房"] = {
    x = 53,
    y = 88,
    sceneID = 10
  },
  ["金殿"] = {
    x = 88,
    y = 53,
    sceneID = 12
  },
  ["解剑池"] = {
    x = 47,
    y = 177,
    sceneID = 12
  },
  ["回龙台"] = {
    x = 79,
    y = 137,
    sceneID = 12
  },
  ["天阶"] = {
    x = 46,
    y = 75,
    sceneID = 12
  },
  ["珙椿晓雨"] = {
    x = 45,
    y = 44,
    sceneID = 15
  },
  ["白水秋风"] = {
    x = 146,
    y = 48,
    sceneID = 15
  },
  ["私语台"] = {
    x = 41,
    y = 148,
    sceneID = 15
  },
  ["长生殿"] = {
    x = 148,
    y = 153,
    sceneID = 15
  },
  ["毒蟾蜍箱"] = {
    x = 95,
    y = 56,
    sceneID = 16
  },
  ["毒蜈蚣箱"] = {
    x = 87,
    y = 97,
    sceneID = 16
  },
  ["毒蜘蛛箱"] = {
    x = 104,
    y = 96,
    sceneID = 16
  },
  ["毒蝎子箱"] = {
    x = 126,
    y = 73,
    sceneID = 16
  },
  ["手太阴肺经铜人"] = {
    x = 62,
    y = 90,
    sceneID = 13
  },
  ["手阳明肠经铜人"] = {
    x = 85,
    y = 85,
    sceneID = 13
  },
  ["足阳明胃经铜人"] = {
    x = 107,
    y = 85,
    sceneID = 13
  },
  ["足太阴脾经铜人"] = {
    x = 127,
    y = 90,
    sceneID = 13
  },
  ["玄冰戽"] = {
    x = 61,
    y = 37,
    sceneID = 17
  },
  ["寒冰戽"] = {
    x = 74,
    y = 63,
    sceneID = 17
  },
  ["碎冰戽"] = {
    x = 123,
    y = 89,
    sceneID = 17
  },
  ["岩冰戽"] = {
    x = 128,
    y = 50,
    sceneID = 17
  },
  ["凤凰琴"] = {
    x = 55,
    y = 146,
    sceneID = 14
  },
  ["烂柯棋"] = {
    x = 152,
    y = 144,
    sceneID = 14
  },
  ["圣贤书"] = {
    x = 49,
    y = 51,
    sceneID = 14
  },
  ["丹青画"] = {
    x = 145,
    y = 57,
    sceneID = 14
  },
  ["听香水榭"] = {
    x = 154,
    y = 93,
    sceneID = 284
  },
  ["琴音小筑"] = {
    x = 78,
    y = 142,
    sceneID = 284
  },
  ["参合庄"] = {
    x = 28,
    y = 28,
    sceneID = 284
  },
  ["曼陀园"] = {
    x = 119,
    y = 36,
    sceneID = 284
  },
  ["演武场"] = {
    x = 48,
    y = 80,
    sceneID = 615
  },
  ["唐家内堡"] = {
    x = 80,
    y = 46,
    sceneID = 615
  },
  ["千机坊"] = {
    x = 56,
    y = 136,
    sceneID = 615
  },
  ["风羽楼"] = {
    x = 102,
    y = 97,
    sceneID = 615
  },
  ["巫山境"] = {
    x = 40,
    y = 100,
    sceneID = 678
  },
  ["玄狐苑"] = {
    x = 138,
    y = 143,
    sceneID = 678
  },
  ["阴阳天东侧"] = {
    x = 128,
    y = 70,
    sceneID = 678
  },
  ["观星台"] = {
    x = 60,
    y = 42,
    sceneID = 678
  },
  ["春闲情"] = {
    x = 181,
    y = 175,
    sceneID = 731
  },
  ["一苇航"] = {
    x = 237,
    y = 189,
    sceneID = 731
  },
  ["三问居"] = {
    x = 175,
    y = 82,
    sceneID = 731
  },
  ["湛若水"] = {
    x = 112,
    y = 135,
    sceneID = 731
  },
  ["临水台"] = {
    x = 369,
    y = 327,
    sceneID = 824
  },
  ["观景台"] = {
    x = 258,
    y = 33,
    sceneID = 824
  },
  ["前院"] = {
    x = 122,
    y = 252,
    sceneID = 824
  },
  ["楼前广场"] = {
    x = 278,
    y = 251,
    sceneID = 824
  },
  望兽坪 = {
    x = 57,
    y = 206,
    sceneID = 987
  },
  ["云崖台"] = {
    x = 46,
    y = 62,
    sceneID = 987
  },
  ["团山亭台"] = {
    x = 125,
    y = 115,
    sceneID = 987
  },
  ["前庭"] = {
    x = 178,
    y = 126,
    sceneID = 987
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
    name = "岳老三",
    x = 180,
    y = 181,
    sceneID = 987
  }
}
local m_npc_fuben = {
  [0] = {
    name = "玄澄",
    x = 61,
    y = 62,
    sceneID = 9,
    option = "塔林"
  },
  [1] = {
    name = "方腊",
    x = 89,
    y = 56,
    sceneID = 11,
    option = "光明洞"
  },
  [2] = {
    name = "佛印",
    x = 41,
    y = 144,
    sceneID = 10,
    option = "酒窖"
  },
  [3] = {
    name = "林灵素",
    x = 58,
    y = 73,
    sceneID = 12,
    option = "灵性峰"
  },
  [4] = {
    name = "孟青青",
    x = 96,
    y = 73,
    sceneID = 15,
    option = "桃花阵"
  },
  [5] = {
    name = "红玉",
    x = 128,
    y = 78,
    sceneID = 16,
    option = "五神洞"
  },
  [6] = {
    name = "本相",
    x = 35,
    y = 86,
    sceneID = 13,
    option = "塔底"
  },
  [7] = {
    name = "菊剑",
    x = 101,
    y = 44,
    sceneID = 17,
    option = "折梅峰"
  },
  [8] = {
    name = "冯阿三",
    x = 62,
    y = 68,
    sceneID = 14,
    option = "谷底"
  },
  [10] = {
    name = "慕容垂",
    x = 69,
    y = 109,
    sceneID = 284,
    option = "巡视水阁"
  },
  [11] = {
    name = "唐岳天",
    x = 66,
    y = 30,
    sceneID = 615,
    option = "修整傀儡"
  },
  [12] = {
    name = "王栩之",
    x = 96,
    y = 52,
    sceneID = 678,
    option = "修复幻阵玄坛"
  },
  [13] = {
    name = "枕梦归",
    x = 160,
    y = 51,
    sceneID = 731,
    option = "修缮离人轻甲"
  },
  [14] = {
    name = "穆宇",
    x = 256,
    y = 142,
    sceneID = 824,
    option = "三庭洞天"
  },
  [15] = {
    name = "山鬼",
    x = 84,
    y = 29,
    sceneID = 987,
    option = "#{ERGSM_240709_10}"
  }
}
local m_shimen_caiji_pos = {
  [0] = {
    {x = 69, y = 42},
    {x = 42, y = 66},
    {x = 56, y = 147},
    {x = 65, y = 118},
    {x = 62, y = 87},
    {x = 129, y = 57},
    {x = 133, y = 143}
  },
  [1] = {
    {x = 97, y = 33},
    {x = 42, y = 36},
    {x = 38, y = 150},
    {x = 158, y = 140},
    {x = 145, y = 35},
    {x = 97, y = 92}
  },
  [2] = {
    {x = 124, y = 60},
    {x = 117, y = 39},
    {x = 149, y = 36},
    {x = 150, y = 155},
    {x = 129, y = 110},
    {x = 82, y = 140},
    {x = 44, y = 114},
    {x = 55, y = 55}
  },
  [3] = {
    {x = 70, y = 82},
    {x = 100, y = 128},
    {x = 78, y = 46},
    {x = 94, y = 59},
    {x = 79, y = 127},
    {x = 75, y = 135}
  },
  [4] = {
    {x = 97, y = 37},
    {x = 144, y = 39},
    {x = 145, y = 154},
    {x = 89, y = 139},
    {x = 95, y = 87},
    {x = 38, y = 150},
    {x = 42, y = 38}
  },
  [5] = {
    {x = 67, y = 143},
    {x = 48, y = 53},
    {x = 95, y = 50},
    {x = 126, y = 73},
    {x = 140, y = 93},
    {x = 142, y = 142},
    {x = 95, y = 127}
  },
  [6] = {
    {x = 152, y = 35},
    {x = 42, y = 43},
    {x = 40, y = 135},
    {x = 64, y = 150},
    {x = 149, y = 154},
    {x = 150, y = 90}
  },
  [7] = {
    {x = 60, y = 35},
    {x = 74, y = 67},
    {x = 39, y = 37},
    {x = 41, y = 145},
    {x = 95, y = 99},
    {x = 146, y = 140},
    {x = 153, y = 57}
  },
  [8] = {
    {x = 52, y = 148},
    {x = 89, y = 124},
    {x = 50, y = 60},
    {x = 142, y = 42},
    {x = 148, y = 150}
  },
  [10] = {
    {x = 86, y = 59},
    {x = 28, y = 58},
    {x = 28, y = 27},
    {x = 130, y = 34}
  },
  [11] = {
    {x = 80, y = 30},
    {x = 32, y = 34},
    {x = 45, y = 135},
    {x = 95, y = 150},
    {x = 126, y = 108},
    {x = 169, y = 159}
  },
  [12] = {
    {x = 64, y = 22},
    {x = 38, y = 72},
    {x = 34, y = 135},
    {x = 109, y = 159},
    {x = 160, y = 47},
    {x = 127, y = 14},
    {x = 121, y = 36},
    {x = 96, y = 62},
    {x = 106, y = 135}
  },
  [13] = {
    {x = 149, y = 70},
    {x = 109, y = 84},
    {x = 101, y = 128},
    {x = 142, y = 149},
    {x = 136, y = 171},
    {x = 186, y = 190},
    {x = 174, y = 157},
    {x = 195, y = 65}
  },
  [14] = {
    {x = 292, y = 231},
    {x = 204, y = 231},
    {x = 127, y = 258},
    {x = 267, y = 355},
    {x = 380, y = 410},
    {x = 410, y = 386},
    {x = 180, y = 350}
  },
  [15] = {
    {x = 123, y = 218},
    {x = 51, y = 208},
    {x = 35, y = 118},
    {x = 121, y = 154},
    {x = 104, y = 62},
    {x = 134, y = 55},
    {x = 180, y = 179}
  }
}

local function SM_LeaveScene()
  local curScene = GetCurrentSceneName()
  if "丐帮酒窖" == curScene then
    PushColorMsg("师门任务:离开丐帮酒窖" .. GetSceneID())
    RunTo(44, 51)
    Sleep(5000)
    return false
  elseif "幻阵坪" == curScene then
    PushColorMsg("师门任务:离开幻阵坪" .. GetSceneID())
    RunTo(32, 55)
    Sleep(5000)
    return false
  elseif "三百迷津" == curScene then
    PushColorMsg("师门任务:离开三百迷津" .. GetSceneID())
    RunTo(61, 88)
    Sleep(5000)
    return false
  elseif "三庭洞天" == curScene then
    PushColorMsg("师门任务:离开三庭洞天" .. GetSceneID())
    RunTo(32, 72)
    Sleep(5000)
    return false
  elseif "青崖山涧" == curScene then
    PushColorMsg("师门任务:离开青崖山涧" .. GetSceneID())
    RunTo(93, 95)
    Sleep(5000)
    return false
  end
  return true
end

local function shimen_cb()
  local curScene = GetCurrentSceneName()
  if "丐帮酒窖" == curScene or "幻阵坪" == curScene or "三百迷津" == curScene or "三庭洞天" == curScene or "青崖山涧" == curScene then
    PushColorMsg("师门地图有误:" .. curScene)
    return false
  end
  return true
end

local function SM_CompleteMission()
  local npc = m_npc_shimen[g_self.menpai]
  MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, shimen_cb)
  Sleep(500)
  QuestFrameOptionClicked_Item(m_param.missionName, 1, 600)
  QuestFrameNextClicked(600)
  QuestFrameMissionComplete(nil, 500)
end

local function SM_Help(strText)
  if "投机取巧" == strText and not m_param.tjqq then
    return false
  end
  if "同门相助" == strText and not m_param.tmxz then
    return false
  end
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
  if -1 == m_param.misIndex or m_param.misScriptID == 229010 then
    return
  end
  m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
  if 1 == m_param.param[0] then
    return true
  end
  Sleep(1000)
  m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
  if 1 == m_param.param[0] then
    return true
  end
  local npc = m_npc_shimen[g_self.menpai]
  CloseAllWindow()
  MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, shimen_cb)
  Sleep(500)
  DialogOptionClicked(strText, 1, 1000)
  DialogOptionClicked("确定", 1, 1200)
  local strText = GetNPCEventList_Item(0)
  if string.find(strText, "#{TJQQ_90428_7}", nil, true) then
    m_param.round = m_param.round + 1
    SM_SetRound()
    PushColorMsg("师门任务：投机取巧使用成功")
  elseif string.find(strText, "安排其他同门去完成", nil, true) then
    m_param.round = m_param.round + 1
    SM_SetRound()
    PushColorMsg("师门任务：同门相助使用成功")
  end
  if "投机取巧" == strText then
    if string.find(strText, "#{TJQQ_90428_8}", nil, true) then
      m_param.tjqq = false
    end
  elseif "同门相助" == strText and string.find(strText, "没有足够的师门贡献度", nil, true) then
    m_param.tmxz = false
  end
  return true
end

local function SM_AbnegateMission(aMisType)
  Sleep(1000)
  m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
  if -1 ~= m_param.misIndex and m_param.misScriptID ~= 229010 then
    m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
    if 1 ~= m_param.param[0] then
      PushDebugMessage("师门：放弃任务" .. aMisType)
      QuestFrameMissionAbnegate(m_param.misScriptID)
    end
  end
end

local function SM_OnShimen0()
  PushDebugMessage("师门:任务0")
  local npc = GetMissionDesc_NPC("师门任务")
  if nil == npc then
    PushColorMsg("师门任务0：无法取得NPC坐标！")
    return
  end
  if npc.name == "公冶乾" and npc.x == 212 and npc.y == 175 then
    npc.x = 210
    npc.y = 177
  end
  MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, 5, nil, nil, shimen_cb)
  QuestFrameOptionClicked_Item(m_param.missionName, 1, 300)
end

local function SM_OnShimen1()
  PushDebugMessage("师门:任务1")
  
  local function _GetMissionDesc_Item(aMissionName)
    local npc
    local strDesc = GetMissionDesc(aMissionName)
    local _, _, strItemName = string.find(strDesc, "#Y(.-)#W")
    if strItemName then
      npc = {itemName = strItemName}
    end
    return npc
  end
  
  local npc = GetMissionDesc_NPC("师门任务", true)
  local item = _GetMissionDesc_Item("师门任务")
  if nil == item then
    PushDebugMessage("师门1：获取任务物品名失败！")
    return
  end
  if npc then
    PushDebugMessage("师门:购买商店物品")
    for i = 1, 3 do
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, shimen_cb)
      Sleep(500)
      DialogOptionClicked("买", 3, 600)
      DialogOptionClicked("卖", 3, 600)
      Shop_BuyItem(item.itemName, 1)
      Sleep(800)
      m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
      if 1 == m_param.param[0] then
        return
      end
    end
  elseif m_param.buyItem then
    local j = m_param.item_j
    local y = m_param.item_y
    local t = m_param.item_t
    local maxMoney = j * 10000 + y * 100 + t
    if maxMoney > Player:GetMoney() then
      Bank_GetMoney(maxMoney, "洛阳")
      Sleep(500)
    end
    for i = 1, 3 do
      if -1 ~= ShangHui_BuyItem(item.itemName, 1, maxMoney) then
        Sleep(500)
        m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
        if -1 ~= m_param.misIndex then
          m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
          if 1 == m_param.param[0] then
            return
          end
          if 3 == i then
          end
        end
      end
      Sleep(200)
    end
  end
  SM_Help("投机取巧")
  SM_Help("同门相助")
  SM_AbnegateMission(1)
end

local function SM_OnShimen2()
  PushColorMsg("师门：任务2 放弃该任务！")
  SM_Help("投机取巧")
  SM_Help("同门相助")
  SM_AbnegateMission(2)
end

local function SM_OnShimen3()
  PushDebugMessage("师门:任务3")
  if m_strList[g_self.menpai] == nil then
    PushDebugMessage("师门:任务3无法取得门派物品列表！")
    return
  end
  local MissionArr = {}
  MissionArr[1] = m_strList[g_self.menpai][m_param.param[5]]
  MissionArr[2] = m_strList[g_self.menpai][m_param.param[6]]
  MissionArr[3] = m_strList[g_self.menpai][m_param.param[7]]
  local strPos, strToolsName = "", ""
  if 0 == g_self.menpai or 1 == g_self.menpai or 2 == g_self.menpai or 3 == g_self.menpai then
    strPos = MissionArr[2]
    strToolsName = MissionArr[1]
  elseif 5 == g_self.menpai or 6 == g_self.menpai or 8 == g_self.menpai or 11 == g_self.menpai then
    strPos = MissionArr[2]
    strToolsName = MissionArr[3]
  elseif 4 == g_self.menpai then
    strPos = MissionArr[1]
    strToolsName = MissionArr[3]
  elseif 7 == g_self.menpai then
    strPos = MissionArr[1]
    strToolsName = MissionArr[2]
  elseif 10 == g_self.menpai then
    strPos = MissionArr[3]
    strToolsName = MissionArr[2]
  elseif 12 == g_self.menpai or 13 == g_self.menpai then
    strPos = MissionArr[2]
    strToolsName = MissionArr[3]
  elseif 14 == g_self.menpai then
    strPos = MissionArr[1]
    strToolsName = MissionArr[3]
  elseif 15 == g_self.menpai then
    strPos = MissionArr[1]
    strToolsName = MissionArr[3]
    if "孔明灯" == strToolsName then
      strToolsName = "孔明灯 "
    end
  end
  if nil == m_item_pos[strPos] then
    PushDebugMessage("师门:任务3没有找到坐标[" .. strPos .. "]数据！")
    return
  end
  if "" == strToolsName then
    PushDebugMessage("师门:任务3物品名称为空！")
    return
  end
  MoveTo(m_item_pos[strPos].x, m_item_pos[strPos].y, m_item_pos[strPos].sceneID, 1, nil, nil, shimen_cb)
  Sleep(500)
  Dismount()
  Bag:UseItemByName(strToolsName, 500, Bag:EnumRenWuItem())
  PlayerStateTimeOut(5, 10)
end

local function SM_OnShimen9(aMisType)
  aMisType = aMisType or 9
  PushDebugMessage("师门:任务" .. aMisType)
  if m_npc_fuben[g_self.menpai] == nil then
    PushDebugMessage("师门任务9：无法取得副本数据")
    return
  end
  local fuben = m_npc_fuben[g_self.menpai]
  MoveToNPC(fuben.name, fuben.x, fuben.y, fuben.sceneID, nil, nil, nil, shimen_cb)
  Sleep(300)
  QuestFrameOptionClicked_Item(fuben.option, 1, 600)
  QuestFrameAcceptClicked(800)
end

local function SM_OnShimen4()
  SM_OnShimen9(4)
end

local function SM_OnShimen5()
  DebugStr("师门：任务5")
  if m_param.not_catchpet then
    PushColorMsg("师门：您已设置放弃抓宝宝任务！")
    Sleep(1500)
    SM_AbnegateMission(5)
    return
  end
  local PetInfo = {
    [3210] = {
      pos = {
        {x = 236, y = 208}
      },
      sceneID = 112,
      sceneName = "玄武岛",
      petName = "成年北极熊",
      attackName = "成年北极熊",
      name = ""
    }
  }
  local nIdx = tonumber(m_param.param[5])
  local catchInfo = PetInfo[nIdx]
  if not catchInfo then
    catchInfo = GetMissionDesc_CatchPet("师门任务")
    if not catchInfo then
      PushDebugMessage("师门任务5：无法取得任务信息！")
      return
    end
    catchInfo.attackName = catchInfo.petName
  end
  if 1 == m_param.param[0] then
    local npc = m_npc_shimen[g_self.menpai]
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, shimen_cb)
    Sleep(500)
    QuestFrameOptionClicked_Item(m_param.missionName, 1, 600)
    local idx = GetLuaValue(fmt([[
                    setmetatable(_G, {__index = PetList_Env})
                    if this:IsVisible() then
                        return mePetAddlistByName('%s')
                    end
                    return -3
                ]], catchInfo.petName), "n")
    if idx >= 0 then
      Sleep(1000)
      GetLuaValue("setmetatable(_G, {__index = MissionReply_Env});if this:IsVisible() then MissionReply_Accept_Clicked() end")
    elseif -1 == idx then
      local function abnegate_mission()
        Sleep(1000)
        
        m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
        if -1 ~= m_param.misIndex then
          QuestFrameMissionAbnegate(m_param.misScriptID)
        end
      end
      
      abnegate_mission()
    end
    return
  end
  local nMP = Player:GetMP()
  if nMP < 1000 or GetSceneID() ~= catchInfo.sceneID and Player:GetHPP() < 60 then
    PushDebugMessage("师门:回洛阳补蓝！")
    XiaoChangHuiXue(101)
  end
  
  local function mis_callback()
    HuDaoPet()
    m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
    if 0 ~= m_param.param[0] then
      PushDebugMessage("抓珍兽:已完成!")
      return true
    end
    local bCatch = false
    bCatch, m_param.catchFilter = OnCatch(catchInfo, m_param.catchFilter)
    if bCatch then
      return true
    end
    DebugStr("抓珍兽", 2)
    return false
  end
  
  CatchPet(catchInfo, mis_callback)
end

local function SM_OnShimen6()
  PushDebugMessage("师门：任务6")
  local szItemName = m_strList[g_self.menpai][m_param.param[5]]
  if "" == szItemName or nil == szItemName then
    PushDebugMessage("师门任务6：数据错误 " .. g_self.menpai .. " " .. m_param.param[5])
    return
  end
  if 4 == g_self.menpai then
    if "遗失的首饰" == szItemName then
      szItemName = "小黄猴"
    elseif "遗失的祭品" == szItemName then
      szItemName = "小黑猴"
    elseif "遗失的珠宝" == szItemName then
      szItemName = "小白猴"
    end
  elseif 13 == g_self.menpai then
    if "离魂" == szItemName then
      szItemName = "引魄钟"
    elseif "幻海沉香木" == szItemName then
      szItemName = "幻海沉香树干"
    elseif "忘忧果" == szItemName then
      szItemName = "忘忧花"
    end
  elseif 14 == g_self.menpai then
    if "乌羽团扇" == szItemName then
      szItemName = "乌羽"
    elseif "枫糖" == szItemName then
      szItemName = "枫坛"
    end
  elseif 15 == g_self.menpai and "枯骨" == szItemName then
    szItemName = "枯骨堆"
  end
  
  local function _CB()
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
    m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
    if -1 == m_param.misIndex or 0 ~= m_param.param[0] then
      return true
    end
    return false
  end
  
  BeginCaiji(szItemName, m_npc_shimen[g_self.menpai].sceneID, m_shimen_caiji_pos[g_self.menpai], _CB)
end

local function SM_OnShimen7()
  PushColorMsg("师门：任务7 放弃该任务！")
  SM_Help("投机取巧")
  SM_Help("同门相助")
  SM_AbnegateMission(7)
end

local function SM_OnShimen8()
  PushColorMsg("师门：任务8 放弃该任务！")
  SM_Help("投机取巧")
  SM_Help("同门相助")
  SM_AbnegateMission(8)
end

local function SM_OnShimenEx()
  PushColorMsg("师门:执行额外任务")
  local index = -1
  if 0 == m_param.param[6] then
    index = 0
  elseif 5 == m_param.param[6] then
    index = 1
  elseif 4 == m_param.param[6] then
    index = 2
  elseif 7 == m_param.param[6] then
    index = 3
  elseif 3 == m_param.param[6] then
    index = 4
  elseif 9 == m_param.param[6] then
    index = 5
  elseif 2 == m_param.param[6] then
    index = 6
  elseif 6 == m_param.param[6] then
    index = 7
  elseif 8 == m_param.param[6] then
    index = 8
  elseif 27 == m_param.param[6] then
    index = 10
  elseif 30 == m_param.param[6] then
    index = 11
  elseif 33 == m_param.param[6] then
    index = 12
  elseif 36 == m_param.param[6] then
    index = 13
  end
  if -1 ~= index then
    local npc = m_npc_fuben[index]
    MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, shimen_cb)
    Sleep(300)
    DialogOptionClicked(npc.option, 1, 600)
    QuestFrameAcceptClicked(1000)
  else
    PushColorMsg("师门:额外任务获取参数失败 " .. m_param.param[6])
    Sleep(3000)
  end
end

function SM_GetRound()
  local strDate = PlayerConfigGet("师门记录日期", "记录")
  local strRound = PlayerConfigGet("师门记录环数", "记录")
  local tab = os.date("*t")
  local strDay = tostring(tab.day)
  if strDate ~= strDay then
    PlayerConfigSet("师门记录日期", strDay, "记录")
    PlayerConfigSet("师门记录环数", "0", "记录")
  else
    m_param.round = tonumber(strRound) or 0
    PushColorMsg("师门任务：共需做%d环,今日已做%d环,再做%d环", m_param.allRound, m_param.round, m_param.allRound - m_param.round)
  end
end

function SM_SetRound()
  PlayerConfigSet("师门记录环数", tostring(m_param.round), "记录")
end

function _SMain(...)
  SM_GetRound()
  if m_param.round >= m_param.allRound then
    PushColorMsg("师门：已经达到设置环数！！")
    return
  end
  if not m_param.not_catchpet and Pet:GetCurrentCount() == Pet:GetMaxCount() then
    local bOver = true
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
    if -1 ~= m_param.misIndex then
      for i = 0, 7 do
        m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
      end
      if 1 == m_param.param[0] and 5 == m_param.param[4] then
        bOver = false
        SM_OnShimen5()
      end
    end
    if bOver then
      PushColorMsg("师门：珍兽栏已满，请留出空位后执行！")
      return
    end
  end
  local npc = m_npc_shimen[g_self.menpai]
  if nil == npc then
    PushColorMsg("师门：门派获取错误 " .. g_self.menpai)
    return
  end
  Bag_DeleteItem()
  LoadScript("caiji")
  while true do
    m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
    if -1 ~= m_param.misIndex then
      for i = 0, 7 do
        m_param.param[i] = GetMissionVariable(m_param.misIndex, i)
      end
      if 1 == m_param.param[0] then
        while true do
          DebugStr("师门：交任务", 2)
          SM_LeaveScene()
          if 5 == m_param.param[4] then
            SM_OnShimen5()
          else
            SM_CompleteMission()
          end
          Sleep(500)
          m_param.misIndex, m_param.misID, m_param.misScriptID = GetPlayerMission(m_param.missionName)
          if -1 == m_param.misIndex then
            break
          end
          m_param.param[0] = GetMissionVariable(m_param.misIndex, 0)
          if 1 ~= m_param.param[0] then
            break
          end
        end
        m_param.round = m_param.round + 1
        SM_SetRound()
      elseif m_param.misScriptID == 229010 then
        SM_OnShimenEx()
      else
        local missionType = m_param.param[4]
        if 0 == g_self.menpai then
          if missionType > 8 then
            missionType = missionType - 1
          end
        elseif 5 == g_self.menpai and 8 == missionType then
          missionType = 9
        end
        if 0 == missionType then
          SM_OnShimen0()
        elseif 1 == missionType then
          Bag_DeleteItem()
          SM_OnShimen1()
        elseif 2 == missionType then
          SM_OnShimen2()
        elseif 3 == missionType then
          SM_OnShimen3()
        elseif 4 == missionType then
          SM_OnShimen4()
        elseif 5 == missionType then
          SM_OnShimen5()
        elseif 6 == missionType then
          SM_OnShimen6()
        elseif 7 == missionType then
          SM_OnShimen7()
        elseif 8 == missionType then
          SM_OnShimen8()
        elseif 9 == missionType then
          SM_OnShimen9()
        else
          PushColorMsg("师门:未知的任务类型 " .. missionType)
        end
      end
    else
      MoveToNPC(npc.name, npc.x, npc.y, npc.sceneID, nil, nil, nil, shimen_cb)
      Sleep(500)
      QuestFrameOptionClicked_Item(m_param.missionName, 1, 600)
      local strText = GetNPCEventList_Item(1)
      if string.find(strText, "60次", nil, true) then
        PushColorMsg("师门任务:今日已经完成60次了！")
        break
      elseif string.find(strText, "15分钟", nil, true) then
        if m_param.wait15_over then
          break
        end
        Sleep(30000)
      end
    end
    if m_param.round >= m_param.allRound then
      PushColorMsg("师门：已经达到设置环数！")
      break
    end
    Sleep(200)
    DebugStr(m_script_name)
  end
end

_SMain()
ScriptOnStop(m_script_name)
m_strList = nil
m_item_pos = nil
m_npc_shimen = nil
m_npc_fuben = nil
m_shimen_caiji_pos = nil
