# 副本/战斗底层接口研究（2026-10-25）

用户要求“继续开发其余功能，先把副本的那些都做了”。本文件记录副本接入前的底层研究结论与分阶段计划。研究只做静态分析和对在线游戏的只读内存读取（OpenProcess 仅 VM_READ|QUERY_INFORMATION），没有向游戏发送任何动作。

## 规模

- 天龙助手 32 个副本模块共约 58,000 条 Lua 5.4 指令；共享副本模块（fn四绝庄、fn缥缈峰、fn琅嬛福地、fn三神幻境、fn聚灵谷、fn王陵、fn剧情_* 等）约 25,000 条；战斗/队伍基础（daguai 5,502、common_2 9,239、functions 8,738、skill 2,061、team 1,450、pet 614、target 396）。
- 副本模块共同依赖：FubenAttack（→ CDG:BossStart，daguai）、Enum2XByName/Enum2XByClass（→ EnumEnvObj）、Player/Team/Skill/Pet/Target 类、MoveTo/RunTo、PickUpLua（拾取）、DieRelive（死亡复活）、QuestFrameOptionClicked_Item、IsHuodongComplete、GoToLeader/IsTeamSteady 等。
- 这些战斗原语在原程序中是原生函数，不在游戏 Lua 里：EnumEnvObj（遍历场景对象）、CallFun（选怪、对话、拾取、销毁、轻功等）、CUseSkillByID（放技能）。游戏 Lua 中没有自动战斗接口（Game.exe 无 AutoFight 类注册名）。

## 已确认（静态 + 在线只读验证）

- 对象管理器：Game.exe 全局 `base+0x105CA30`（与 0.2 读取主角位置所用同一全局）；虚表 +0x88 按客户端 ID 查找、+0x90 按服务器 ID 查找（`GetNPCIDByServerID` 的 Lua 实现调用 +0x90，再调对象虚表 +0x78 取客户端 ID）。
- 对象容器：MSVC `std::map`。`mgr+0xE0` 头结点为 客户端 ID → 对象（在线读到 118 个），`mgr+0xF0` 为 服务器 ID → 对象（23 个）。结点：+0 左、+8 父、+0x10 右、+0x19 isnil、+0x20 键（int）、+0x28 对象指针。`mgr+0x108` 为主角对象。
- 对象类别用 RTTI：`CObject_PlayerNPC`（NPC、怪物、珍兽、宝箱）、`CObject_PlayerOther`（其他玩家）、`CObject_PlayerMySelf`、`CObject_PlayerInfant` 等。
- 坐标：对象 +0x4C（x）、+0x54（y）。
- 角色数据：`data = *(*(obj+0x228)+8)`；名称为 `data+0x38` 处的 std::string（GBK）；血量百分比为 `data+8` 的 float（0–1）；`data+0x58` 对 NPC 为类型（0x1F 宝箱、-1 珍兽），对玩家为门派。在线读出 NPC“林和靖/宋兵/钱宏宇”、珍兽、其他玩家名称与血量，均与游戏一致。
- 原程序 EnumEnvObj 的记录字段（0xF8 字节）：baseptr、dataptr、state、target、model、x、y、fx、dst、level、menpai、attackType、owner、id、bhid、tmid、petzrid、guid、zwType、inteam、leader、sex、hp、mpp、name、title、class、bhname。怪物与友好 NPC 的区分由一个游戏关系函数决定（原程序运行时定位，返回 0 为“怪物”），尚未在 Game.exe 中定位。
- 选目标：游戏 Lua 有 `SelectAsTargetByObjID`、`SelectAsTargetByIdx`、`LockTarget`；放技能在游戏中对应 CGCharUseSkill 报文与动作栏 DoAction，原程序用原生 CUseSkillByID。

## 待完成的底层能力（副本前置）

1. 敌我关系：定位游戏关系函数或阵营字段（需要角色站在野怪附近做在线对照）。
2. 存活/死亡状态、目标的目标、归属（state/target/owner 字段偏移）。
3. 选怪：确认 `SelectAsTargetByObjID` 的注册对象和参数，或改用原生选择函数。
4. 放技能：定位技能释放入口（CUseSkillByID 对应的游戏函数或动作栏技能 DoAction），以及技能可用/冷却判断。
5. 拾取、死亡复活、队伍跟随与队员状态。
6. 在此之上实现 daguai（CDG 打怪循环）、FubenAttack、Enum2X* 的兼容层，再逐个还原副本模块。

## 建议顺序

先在线完成 1–4（需要用户把角色带到有怪的野外地图配合几次只读对照和一次手动确认的选怪/放技能测试），再接入“打怪/刷怪”类任务验证战斗循环；之后按体量从小到大还原副本：聚灵谷（简单/普通）、琅嬛福地、汴京王陵/凤鸣王陵、三神幻境、缥缈峰、四绝庄，最后是讨伐燕子坞、少室山、兵圣奇阵、观山海、剑破明王境、凤凰陵墓等大型模块。
