# 原副本 Lua 配置读取清单（0.12.0）

共核对 32 份原副本字节码。本清单列出能静态确认的常量配置读取调用；动态键、g_config 共享字段及 fn 模块间接读取项仍需继续追踪。没有直接读取项不表示没有配置。

当前接入执行的是珍珑棋局；其余条目是后续适配依据，不代表已能执行。原整数/浮点标签已按本地 Lua 5.4 源码校正，新的可读指令列表在 artifacts/original-combat-0.12.0/listings/。

## 【副本】刷反贼

原记录：`002b54ac.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 【副本】刷棋

原记录：`002b8890.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigBool | ZH | xzk190 | 0–0 |

## 【副本】刷箱子

原记录：`002b9e15.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigBool | ZH | xzk190 | 0–0 |

## 三神幻境(凤鸣)

原记录：`002bb430.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk140 | 0–0 |
| ReadConfigBool | ZH | xzk137 | 0–0 |
| ReadConfigBool | ZH | xzk87 | 0–0 |
| ReadConfigBool | ZH | xzk157 | 0–0 |

## 偷袭门派(宵小)

原记录：`002bba5a.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 兵圣奇阵(12人)

原记录：`002c0fc9.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk43 | 0–0 |
| ReadConfigBool | ZH | xzk110 | 0–0 |
| ReadConfigBool | ZH | xzk170 | 0–0 |
| ReadConfigBool | ZH | xzk260 | 0–0 |
| ReadConfigBool | ZH | dxk34 | 0–0 |
| ReadConfigBool | ZH | dxk35 | 0–0 |
| ReadConfigBool | ZH | xzk230 | 0–0 |
| ReadConfigBool | ZH | xzk199 | 0–0 |
| ReadConfigBool | ZH | xzk200 | 0–0 |
| ReadConfigBool | ZH | xzk201 | 0–0 |
| ReadConfigBool | ZH | xzk202 | 0–0 |
| ReadConfigBool | ZH | xzk203 | 0–0 |
| ReadConfigBool | ZH | xzk204 | 0–0 |
| ReadConfigBool | ZH | xzk232 | 0–0 |
| ReadConfigBool | ZH | xzk234 | 0–0 |

## 凤鸣王陵(龙纹)

原记录：`002cf5a7.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk141 | 0–0 |

## 剑破明王境

原记录：`002cfcf9.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 四绝庄

原记录：`002e1226.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| GetConfigBool | 四绝庄 | 死亡出窍 | 0–0 |
| GetConfigBool | 四绝庄 | Boss1不敲钟 | 0–0 |
| GetConfigBool | 四绝庄 | Boss2跑对角 | 0–0 |
| GetConfigBool | 四绝庄 | Boss2分担失明 | 0–0 |
| GetConfigBool | 四绝庄 | Boss4不跑龙柱 | 0–0 |
| GetConfigBool | 副本 | 小号模式 | 0–0 |
| ReadConfigText | ZH | sjz_type | 0–0 |
| GetConfigText | 组队人数 | 四绝庄 | 0–0 |

## 夜探天波府

原记录：`002e1e29.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigBool | ZH | xzk118 | 0–0 |
| GetConfigText | 组队人数 | 天波府 | 0–0 |

## 天降奇兽(刷丹)

原记录：`002eb7bd.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 天龙幻境

原记录：`002ee7ae.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 少室山(大理)

原记录：`002ef962.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk136 | 0–0 |
| ReadConfigBool | ZH | xzk47 | 0–0 |
| ReadConfigBool | ZH | xzk189 | 0–0 |
| ReadConfigText | ZH | sss_type | 0–0 |

## 扫荡副本

原记录：`002fbab1.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigBool | ZH | xzk131 | 0–0 |
| ReadConfigBool | ZH | xzk266 | 0–0 |
| ReadConfigBool | ZH | xzk274 | 0–0 |
| ReadConfigBool | ZH | xzk272 | 0–0 |
| ReadConfigBool | ZH | xzk279 | 0–0 |
| ReadConfigBool | ZH | xzk278 | 0–0 |
| ReadConfigBool | ZH | xzk275 | 0–0 |
| ReadConfigBool | ZH | xzk277 | 0–0 |
| ReadConfigBool | ZH | xzk276 | 0–0 |
| ReadConfigBool | ZH | xzk290 | 0–0 |

## 水牢

原记录：`002fbdb4.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 汴京三神幻境

原记录：`002fd257.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk140 | 0–0 |
| ReadConfigBool | ZH | xzk137 | 0–0 |
| ReadConfigBool | ZH | xzk87 | 0–0 |
| ReadConfigBool | ZH | xzk157 | 0–0 |

## 汴京王陵

原记录：`002fd8cc.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk141 | 0–0 |

## 琅嬛福地(困难)

原记录：`002fe064.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk145 | 0–0 |
| ReadConfigBool | ZH | xzk217 | 0–0 |

## 琅嬛福地

原记录：`002fe6b9.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk145 | 0–0 |
| ReadConfigBool | ZH | xzk217 | 0–0 |
| ReadConfigText | ZH | lhfd_type | 0–0 |

## 缥缈峰(大)

原记录：`002fef1e.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigText | ZH | bjk138 | 0–0 |
| ReadConfigBool | ZH | xzk88 | 0–0 |
| ReadConfigBool | ZH | xzk158 | 0–0 |
| ReadConfigBool | ZH | xzk226 | 0–0 |
| GetConfigBool | 副本 | 小号模式 | 0–0 |
| ReadConfigBool | ZH | xzk219 | 0–0 |
| ReadConfigText | ZH | dpmf_type | 0–0 |

## 聚灵谷困难

原记录：`002ff923.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| GetConfigBool | 聚灵谷 | 不打雪海沧龙 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打赤焰黑虎 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打玄雷宝驹 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打剧毒乌犍 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打雷锁 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打小怪 | 0–0 |
| GetConfigText | 聚灵谷 | 副本次数 | 0–0 |
| GetConfigBool | 聚灵谷 | 宿灵渊 | 0–0 |

## 聚灵谷普通

原记录：`0030129e.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| GetConfigBool | 聚灵谷 | 不打雷锁 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打小怪 | 0–0 |
| GetConfigText | 聚灵谷 | 副本次数 | 0–0 |

## 聚灵谷简单

原记录：`00301bdf.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| GetConfigBool | 聚灵谷 | 不打雷锁 | 0–0 |
| GetConfigBool | 聚灵谷 | 不打小怪 | 0–0 |
| GetConfigText | 聚灵谷 | 副本次数 | 0–0 |

## 观山海

原记录：`00302521.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| GetConfigText | 组队人数 | 观山海 | 0–0 |
| GetConfigText | 观山海 | 勾选平均层数 | 0–0 |
| GetConfigText | 观山海 | 勾选平均血量 | 0–0 |
| GetConfigText | 观山海 | 勾选队伍人数 | 0–0 |
| GetConfigText | 观山海 | 金钟罩层数 | 0–0 |
| GetConfigText | 观山海 | 狂慧层数 | 0–0 |
| GetConfigText | 观山海 | 离开层数 | 0–0 |
| GetConfigText | 观山海 | 不打弟子BOSS血 | 0–0 |
| GetConfigBool | 观山海 | 勾选奖励 | 0–0 |
| GetConfigBool | 观山海 | 刷完奖励次数 | 0–0 |
| GetConfigBool | 观山海 | 队长不在离开 | 0–0 |
| GetConfigBool | 观山海 | 不打铁蒺藜 | 0–0 |
| GetConfigBool | 观山海 | 逍遥黑子不跑 | 0–0 |
| GetConfigBool | 观山海 | 近战优先BOSS | 0–0 |
| GetConfigBool | 观山海 | 队员层数 | 0–0 |
| GetConfigBool | 观山海 | 队长层数 | 0–0 |
| GetConfigText | 观山海 | 不打BOSS | 0–0 |
| GetConfigText | 观山海 | 弟子少林 | 34–85 |
| GetConfigText | 观山海 | 弟子明教 | 34–85 |
| GetConfigText | 观山海 | 弟子丐帮 | 34–85 |
| GetConfigText | 观山海 | 弟子武当 | 34–85 |
| GetConfigText | 观山海 | 弟子星宿 | 34–85 |
| GetConfigText | 观山海 | 弟子天龙 | 34–85 |
| GetConfigText | 观山海 | 弟子天山 | 34–85 |
| GetConfigText | 观山海 | 弟子逍遥 | 34–85 |
| GetConfigText | 观山海 | 弟子慕容 | 34–85 |
| GetConfigText | 观山海 | 弟子唐门 | 34–85 |
| GetConfigText | 观山海 | 弟子鬼谷 | 34–85 |
| GetConfigText | 观山海 | 弟子桃花岛 | 34–85 |

## 讨伐燕子坞

原记录：`00313c18.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| GetConfigBool | 副本 | 小号模式 | 0–0 |
| ReadConfigBool | ZH | xzk121 | 0–0 |
| ReadConfigBool | ZH | xzk215 | 0–0 |
| ReadConfigBool | ZH | xzk119 | 0–0 |
| ReadConfigText | ZH | bjk137 | 0–0 |
| ReadConfigText | ZH | yzw_type | 0–0 |

## 蹴鞠大赛(踢球)

原记录：`0031bd09.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 追捕野猪王(圣兽山)

原记录：`0031c749.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 野猪暴走(圣兽山)

原记录：`0031db5f.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 除匪首力破三关

原记录：`00320005.listing.txt`。

| 读取接口 | 配置分组 | 配置键 | 原函数行号 |
| --- | --- | --- | --- |
| ReadConfigBool | ZH | xzk166 | 0–0 |
| GetConfigText | 组队人数 | 老三环 | 0–0 |

## 凤凰陵墓-普通

原记录：`00322b14.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 凤凰陵墓-困难

原记录：`0032b023.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 弈决山河

原记录：`0033352d.listing.txt`。

未发现使用固定 section/key 的直接 ReadConfig/GetConfig 调用；仍需核对共享配置与公共模块。

## 已接到界面的原棋局参数

- `ReadConfigBool("ZH","xzk190")` → `original_quick_mode`，界面“原规则·快速入场”。原布尔开关直接传给原规则，未自行改写入场分支。
- 原局部变量 `m_teamCount=3` → 默认 3 人；“原规则·入场人数”是宿主补充的显式覆盖，范围 3–6。
- 原 `m_fubenSceneID=61` 固定使用 61；之前重建版的 3 是错误值，本轮已纠正。
- 输出技能来自本角色技能页或任务覆盖；低血量、间隔和总超时属于本程序战斗宿主参数。
- 界面可选“原规则”和“兼容重建”，两种方式明确区分。
