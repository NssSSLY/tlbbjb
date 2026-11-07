-- 师门任务, written from the reference rules (原脚本源码/Script64/任务/师门任务.lua). Accept, do, hand in, by mission type, up to the set number of rounds.
-- 商会 buying and bag clean-up are not ported. This task owns its stages and receipts; it does not load the vendor framework.
-- docs/LONG_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Shimen={}
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
local EXIT={['丐帮酒窖']={44,51},['幻阵坪']={32,55},['三百迷津']={61,88},['三庭洞天']={32,72},['青崖山涧']={93,95}}
local EXTRA={[0]=0,[5]=1,[4]=2,[7]=3,[3]=4,[9]=5,[2]=6,[6]=7,[8]=8,[27]=10,[30]=11,[33]=12,[36]=13}
local RENAME={[4]={['遗失的首饰']='小黄猴',['遗失的祭品']='小黑猴',['遗失的珠宝']='小白猴'},[13]={['离魂']='引魄钟',['幻海沉香木']='幻海沉香树干',['忘忧果']='忘忧花'},
    [14]={['乌羽团扇']='乌羽',['枫糖']='枫坛'},[15]={['枯骨']='枯骨堆'}}
-- Which of the three mission words is the place and which the tool: {place,tool}.
local function toolSlots(s)
    if s==0 or s==1 or s==2 or s==3 then return 2,1 end
    if s==5 or s==6 or s==8 or s==11 or s==12 or s==13 then return 2,3 end
    if s==4 or s==14 or s==15 then return 1,3 end
    if s==7 then return 1,2 end
    if s==10 then return 3,2 end
end
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Shimen.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.bjk29 or 60),1,60,'环数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local limitMs=int(tonumber(cfg.shimen_minutes or 115),1,115,'总时限')*60000
    for _,k in ipairs({'shimen_tjqq','xzk56','shimen_abandon','xzk187'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','师门开关无效：'..k) end
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local school=math.floor(api.school())
    local master=m_npc_shimen[school]
    if not master or master.name=='' then error('师门任务：门派 '..school..' 没有已知的师门 NPC',0) end
    local home={name=master.name,x=master.x,y=master.y,scene=master.sceneID}
    local fuben=m_npc_fuben[school]
    local def={name='师门任务',mission='师门任务',map='',npc=home,bosses={}}
    function def.inside() return false end
    local phase,round,tjqq,tmxz='',0,cfg.shimen_tjqq==true,cfg.xzk56==true
    local function log(s) if phase~=s then phase=s;api.log('师门任务 · '..s) end end
    local function world() return assert(api.world(),'师门任务场景不可读') end
    local deadline=api.now()+limitMs
    local function alive() assert(api.now()<deadline,'师门任务超过总时限');api.alive(minimum,'师门任务：角色血量低于停止阈值，已停止',true) end
    local function ui(code) GetLuaValue('-- shimen:ui\n'..code,'',0) end
    local function dialogText()
        local text=GetLuaValue([[-- shimen:dialog-all
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local all=''
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                if type(t)=='string' then all=all..t..'\n' end
            end
            return all]],'s')
        return type(text)=='string' and text or ''
    end
    local function vars(slot)
        local v={GetLuaValue(string.format([[-- shimen:vars
            local s=%d local g=function(i) return DataPool:GetPlayerMission_Variable(s,i) end
            return g(0),g(1),g(2),g(3),g(4),g(5),g(6),g(7)]],slot),'nnnnnnnn')}
        local out={};for i=0,7 do out[i]=math.floor(assert(tonumber(v[i+1]),'师门任务变量不可读')) end
        return out
    end
    local function scriptId(slot)
        local n=GetLuaValue(string.format("-- shimen:script\nreturn DataPool:GetPlayerMission_Display(%d,7)",slot),'n')
        return assert(tonumber(n),'师门任务脚本号不可读')
    end
    local function current() return api.mission(def) end
    local function statusOf() local m=current();return m and vars(m.slot)[0] or nil end
    local function changed(old)
        local began=api.now()
        while api.now()-began<math.max(waitMs,5000) do
            local m=current()
            local sig=m and (m.id..':'..vars(m.slot)[0]) or 'none'
            if sig~=old then return true end
            api.maintain();api.sleep(500)
        end
        return false
    end
    local function signature() local m=current();return m and (m.id..':'..vars(m.slot)[0]) or 'none' end
    local tries={}
    -- One action per mission state; the same state three times means it is not working.
    local function attempt(label)
        local key=label..':'..signature()
        tries[key]=(tries[key] or 0)+1
        if tries[key]>3 then error('师门任务：'..label..' 做了 3 次任务没有变化，不再重复',0) end
    end
    local function talkHome(option)
        CloseAllWindow();api.openNpc(home);api.sleep(500)
        return api.selectOption({option},true)
    end
    local function abandon(label)
        local m=current();if not m then return end
        if vars(m.slot)[0]==1 then return end
        if cfg.shimen_abandon~=true then error('师门任务：'..label..'做不了，未打开“允许放弃任务”，已停止',0) end
        log('放弃任务（'..label..'）')
        local id=scriptId(m.slot)
        assert(id>=0,'师门任务脚本号无效')
        ui(string.format('QuestFrameMissionAbnegate(%d)',id));api.sleep(1000)
    end
    local function help(word,allowed)
        if not allowed then return false end
        local before=statusOf();if before==nil or before==1 then return false end
        log('使用'..word)
        if not talkHome(word) then CloseAllWindow();return false end
        api.sleep(800);api.selectOption({'确定'},true);api.sleep(1000)
        local text=dialogText();CloseAllWindow()
        if text:find('#{TJQQ_90428_7}',1,true) or text:find('安排其他同门去完成',1,true) then round=round+1;log(word..'成功（第 '..round..' 环）');return true end
        if word=='投机取巧' and text:find('#{TJQQ_90428_8}',1,true) then tjqq=false end
        if word=='同门相助' and text:find('没有足够的师门贡献度',1,true) then tmxz=false end
        return false
    end
    -- What the reference does with every mission it cannot do.
    local function skip(label)
        if help('投机取巧',tjqq) then return end
        if help('同门相助',tmxz) then return end
        abandon(label)
    end
    local function npcFromDesc(desc)
        local x,y,scene,name=desc:match('{.-(%d+),(%d+),(%d+),(.-)}')
        x,y,scene=tonumber(x),tonumber(y),tonumber(scene)
        if not (x and y and scene and name) then return nil end
        if name=='-1' then name='' end
        if name=='公冶乾' and x==212 and y==175 then x,y=210,177 end
        return {name=name,x=x,y=y,scene=scene}
    end
    local function plain(desc) local at=desc:find('#G小提示',1,true);return at and desc:sub(1,at-1) or desc end
    local function state() return GetLuaValue('-- shimen:state\nreturn Player:GetState()','n') end
    local function casting(seconds)
        api.sleep(300)
        local began=api.now()
        while (state()==5 or state()==8) and api.now()-began<seconds*1000 do api.maintain();api.sleep(200) end
    end
    local function talkMission(m)
        attempt('对话')
        local npc=npcFromDesc(plain(m.desc))
        assert(npc and npc.name~='','师门任务：任务描述里没有 NPC')
        log('对话 '..npc.name)
        api.openNpc(npc);api.sleep(300)
        api.selectOption({def.mission},true)
        local old=signature();api.sleep(500);CloseAllWindow();changed(old)
    end
    local function shopMission(m)
        local item=plain(m.desc):match('#Y(.-)#W')
        local npc=npcFromDesc(plain(m.desc))
        if not (item and npc and npc.name~='') then return skip('商会购买') end
        if cfg.allow_spend~=true then return skip('未打开“允许支付”，买 '..item) end
        attempt('购买')
        log('购买 '..item)
        api.openNpc(npc);api.sleep(500)
        QuestFrameOptionClicked('买',0);api.sleep(600);QuestFrameOptionClicked('卖',0);api.sleep(600)
        local n=GetLuaValue(string.format([[-- shimen:buy
            local want=%q
            for i=0,35 do local a=EnumAction(i,'boothitem') if a and a:GetID()~=0 and a:GetName()==want then NpcShop:BulkBuyItem(i,1,0) return 1 end end
            return 0]],item),'n')
        api.sleep(800);CloseAllWindow()
        if n~=1 then return skip('商店没有 '..item) end
        changed(signature())
    end
    local function useTool(v)
        local place,tool=toolSlots(school)
        local list=m_strList[school]
        assert(place and list,'师门任务：门派 '..school..' 没有使用道具的资料')
        local words={list[v[5]],list[v[6]],list[v[7]]}
        local at,name=m_item_pos[words[place]],words[tool]
        assert(at and name and name~='','师门任务：没有找到坐标或物品：'..tostring(words[place]))
        if school==15 and name=='孔明灯' then name='孔明灯 ' end
        attempt('用 '..name)
        log('用 '..name)
        MoveTo(at.x,at.y,at.sceneID);api.prepareBattle();api.sleep(500)
        local r=GetLuaValue(string.format([[-- shimen:use
            local want=%q
            for i=0,DataPool:GetTaskBag_Num()-1 do local a=PlayerPackage:EnumItem('quest',i)
                if a and a:GetID()~=0 and a:GetName()==want then PlayerPackage:UseItem(200+i) return 1 end end
            return 0]],name),'n')
        assert(r==1,'师门任务：任务栏没有 '..name)
        casting(10);changed(signature())
    end
    local function fubenMission(old)
        assert(fuben,'师门任务：门派 '..school..' 没有副本资料')
        local p=world()
        if p.scene==fuben.sceneID then
            attempt('进入副本')
            log('前往 '..fuben.name)
            api.openNpc({name=fuben.name,x=fuben.x,y=fuben.y,scene=fuben.sceneID});api.sleep(300)
            api.selectOption({fuben.option},true);api.sleep(600);QuestFrameAcceptClicked(800)
            local began=api.now()
            while world().scene==fuben.sceneID do
                if signature()~=old then return end
                if api.now()-began>=math.max(waitMs,15000) then return end
                api.maintain();api.sleep(500)
            end
        end
        local scene=world().scene
        if scene==fuben.sceneID then return end
        -- Inside: the reference only waits; anything hostile nearby is cleared so it cannot stall the wait.
        log('副本内');api.prepareBattle()
        local T=DungeonTactics.new(api,scene,{})
        local last,hps=api.now(),{}
        while world().scene==scene and statusOf()~=1 do
            alive();assert(api.now()-last<180000,'师门任务：副本内 3 分钟没有进展')
            local mob
            for _,o in ipairs(T.rows()) do
                if T.enemy(o) then
                    if not mob or o.dst<mob.dst then mob=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;last=api.now() end
                end
            end
            if mob and mob.dst<=30 then T.attack(mob) else T.stop() end
            api.maintain();api.sleep(250)
        end
        T.stop()
    end
    local function collectMission(v)
        local want=m_strList[school] and m_strList[school][v[5]]
        assert(want and want~='','师门任务：采集物品数据错误')
        want=(RENAME[school] and RENAME[school][want]) or want
        local scene=master.sceneID;local route=assert(m_shimen_caiji_pos[school],'师门任务：没有采集坐标')
        log('采集 '..want)
        if world().scene~=scene then MoveTo(route[1].x,route[1].y,scene) end
        local T=DungeonTactics.new(api,scene,{})
        local i,tried,last=1,{},api.now()
        while statusOf()==0 do
            alive();assert(api.now()-last<300000,'师门任务：5 分钟没有采到 '..want)
            local target
            for _,o in ipairs(T.rows()) do
                if o.name:find(want,1,true) and not T.enemy(o) and api.now()-(tried[o.id] or -100000)>=60000 and (not target or o.dst<target.dst) then target=o end
            end
            if target then
                if target.dst>=2.4 then T.move(math.floor(target.x),math.floor(target.y))
                else
                    T.stop();api.prepareBattle()
                    tried[target.id]=api.now();last=api.now()
                    CombatRuntime.host('open_object',math.floor(target.id)..':'..math.floor(target.server_id))
                    casting(20)
                    GetLuaValue("-- shimen:loot\nlocal e=LootPacket_Env if e and e.this and e.this:IsVisible() then PlayerPackage:PickAllItem() CloseWindow('LootPacket',true) end",'',0)
                    T.clearMove()
                end
            else
                local q=route[i]
                if not T.move(q.x,q.y) then i=i%#route+1;T.clearMove() end
            end
            api.maintain();api.sleep(250)
        end
        T.stop()
    end
    local function petInfo(desc)
        local name,map,x,y,scene=plain(desc):match('#R(.-)#W.-#B(.-)#{.-(%d+),(%d+),(%d+),(.-)}#W')
        x,y,scene=tonumber(x),tonumber(y),tonumber(scene)
        if name and x and y and scene then return {name=name,x=x,y=y,scene=scene} end
    end
    local function catchMission(m,v)
        if cfg.xzk187==true then return abandon('抓宝宝（已设置放弃）') end
        local info=v[5]==3210 and {name='成年北极熊',x=236,y=208,scene=112} or petInfo(m.desc)
        if not info then return skip('抓宝宝（任务描述解析失败）') end
        log('抓 '..info.name)
        MoveTo(info.x,info.y,info.scene)
        local T=DungeonTactics.new(api,info.scene,{})
        local tried,last,skillAt=T and {},api.now(),-100000
        while statusOf()==0 do
            alive();assert(api.now()-last<600000,'师门任务：10 分钟没有抓到 '..info.name)
            local pet
            for _,o in ipairs(T.rows()) do
                if o.name==info.name and o.hp>0 and api.now()-(tried[o.id] or -100000)>=30000 and (not pet or o.dst<pet.dst) then pet=o end
            end
            if pet then
                if pet.dst>3 then T.move(math.floor(pet.x),math.floor(pet.y))
                elseif api.now()-skillAt>=1000 then
                    T.stop();api.prepareBattle();skillAt=api.now()
                    local used,missing=T.useSkill('捕兽',pet)
                    assert(not missing,'师门任务：角色没有捕兽技能')
                    if used then casting(60);tried[pet.id]=api.now();last=api.now() end
                end
            else T.stop() end
            api.maintain();api.sleep(250)
        end
        T.stop()
    end
    local function submitPet(m,v)
        local name=(v[5]==3210 and '成年北极熊') or (petInfo(m.desc) or {}).name
        assert(name,'师门任务：任务描述里没有珍兽名')
        log('交珍兽 '..name)
        talkHome(def.mission);api.sleep(600)
        local r=GetLuaValue(string.format([[-- shimen:pet
            local want=%q
            local e=MissionReply_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return -3 end
            for i=9,0,-1 do
                if Pet:IsPresent(i) then
                    local n,on=Pet:GetPetList_Appoint(i)
                    if n==want and on=='on_packa' then Exchange:AddPet(i) return i end
                end
            end
            return -1]],name),'n')
        if r==-1 then return abandon('交珍兽（没有 '..name..'）') end
        if r>=0 then api.sleep(1000);ui('MissionReply_Env.MissionReply_Accept_Clicked()');api.sleep(800) end
        CloseAllWindow()
    end
    local function handIn(m,v)
        attempt('交任务')
        local here=world()
        local out=EXIT[here.map]
        if out then
            log('离开 '..here.map)
            local T=DungeonTactics.new(api,here.scene,{})
            local began=api.now()
            while world().scene==here.scene do
                assert(api.now()-began<math.max(waitMs,60000),'师门任务：走到出口后仍在 '..here.map)
                T.move(out[1],out[2]);api.maintain();api.sleep(500)
            end
        elseif fuben and here.scene~=fuben.sceneID and here.scene~=master.sceneID and here.map:find('副本',1,true) then
            local began=api.now()
            while world().scene==here.scene and api.now()-began<math.max(waitMs,60000) do api.maintain();api.sleep(500) end
        end
        log('交任务')
        local old=signature()
        if v[4]==5 then submitPet(m,v)
        else
            talkHome(def.mission);api.sleep(600);QuestFrameNextClicked(600);QuestFrameMissionComplete(nil,500);CloseAllWindow()
        end
        changed(old)
        local now=current()
        if not now or vars(now.slot)[0]~=1 then round=round+1;log('完成第 '..round..' 环') end
    end
    local function extraMission(v)
        local index=EXTRA[v[6]]
        if not index then return skip('额外任务（参数 '..v[6]..'）') end
        attempt('额外任务')
        local npc=m_npc_fuben[index]
        log('额外任务 '..npc.name)
        api.openNpc({name=npc.name,x=npc.x,y=npc.y,scene=npc.sceneID});api.sleep(300)
        api.selectOption({npc.option},true);api.sleep(600);QuestFrameAcceptClicked(1000);CloseAllWindow()
        changed(signature())
    end
    local function acceptNew()
        log('接任务')
        if not talkHome(def.mission) then
            CloseAllWindow()
            attempt('接任务')
            return nil
        end
        api.sleep(600)
        local text=dialogText();CloseAllWindow()
        if text:find('60次',1,true) then return 'full' end
        if text:find('15分钟',1,true) then log('放弃后要等 15 分钟');api.maintain();api.sleep(30000);return nil end
        attempt('接任务')
        changed('none')
    end
    local function petBarFull()
        local n,lv,extra=GetLuaValue("-- shimen:petbar\nreturn Pet:GetPet_Count(),Player:GetData('LEVEL'),Player:GetData('PET_EXTRANUM')",'nnn')
        if type(n)~='number' or type(lv)~='number' then return false end
        local max=(lv<21 and 2 or lv<41 and 3 or lv<61 and 4 or lv<81 and 5 or 6)+(tonumber(extra) or 0)
        return n>=math.min(max,10)
    end
    local function body()
        api.validate(def,cfg)
        if cfg.xzk187~=true and petBarFull() then
            local m=current()
            if not (m and vars(m.slot)[0]==1 and vars(m.slot)[4]==5) then error('师门任务：珍兽栏已满，抓宝宝环会失败；请留出空位，或打开“不做抓宝宝”',0) end
        end
        local full=false
        while round<rounds do
            assert(api.now()<deadline,'师门任务超过总时限')
            local m=current()
            if not m then
                if acceptNew()=='full' then full=true;break end
            else api.resumable(function()
                local v=vars(m.slot)
                if v[0]==1 then handIn(m,v)
                elseif scriptId(m.slot)==229010 then extraMission(v)
                else
                    local kind=v[4]
                    if school==0 and kind>8 then kind=kind-1 elseif school==5 and kind==8 then kind=9 end
                    if kind==0 then talkMission(m)
                    elseif kind==1 then shopMission(m)
                    elseif kind==2 or kind==7 or kind==8 then skip('第 '..kind..' 类任务')
                    elseif kind==3 then useTool(v)
                    elseif kind==4 or kind==9 then fubenMission(signature())
                    elseif kind==5 then catchMission(m,v)
                    elseif kind==6 then collectMission(v)
                    else skip('未知任务类型 '..kind) end
                end
            end) end
            api.maintain();api.sleep(200)
        end
        if round==0 and full then return {status='already_done',message='师门任务今日已做满 60 次'} end
        return {status='done',message='师门任务完成 '..round..' 环'..(full and '；今日已做满 60 次' or '')}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..'；已完成 '..round..' 环]',0) end
    assert(stopped,'师门任务停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
