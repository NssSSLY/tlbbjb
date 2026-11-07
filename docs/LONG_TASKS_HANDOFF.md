# 长任务、死亡复活、三环和安装结构

更新：2026-11-07。离线测试通过，未实机验证。

## 师门、马贼、主线、新手

|任务|入口 id|契约|模块|原脚本|
|---|---|---|---|---|
|师门任务|`shimen`|`shimen_flow_v1`|`modules/shimen.lua`|`任务/师门任务.lua`|
|马贼|`bandits`|`mazei_flow_v1`|`modules/mazei.lua`|`常用/自动刷马贼.lua`|
|主线任务|`mainline`|`zhuxian_flow_v1`|`modules/zhuxian.lua` + `quest_book.lua`|`任务/主线任务.lua`|
|新手 1–40|`novice_1_40`|`xinshou_flow_v1`|`modules/xinshou.lua` + `quest_book.lua`|`任务/新手1-40级.lua`|

**师门：** 接任务，按类型做（对话、商店、用道具、副本、抓宝宝、采集），交任务计一环。今日 60 次或达到设定环数结束。

**马贼：** 只做“循环勾选地图”模式：队长巡逻，开启并击杀夺宝和护宝马贼，杀后等包；队员跟随助战。运行满时长结束。

**主线、新手：** 任务表原样来自原脚本，放在模块里；`quest_book.lua` 用明文实现表里调用的函数，通过私有环境运行。循环顺序同原脚本：做任务、交任务、接任务。所有等待都经过 `Sleep`，统一检查总时限和血量。

### 风险开关（默认关）

|任务|开关|不开时|
|---|---|---|
|师门|`shimen_abandon` 放弃做不了的任务|停止并写明|
|师门|`shimen_tjqq` 投机取巧、`xzk56` 同门相助|不用|
|师门|`allow_spend` 商店购买|按做不了处理|
|主线、新手|`quest_abandon` 放弃失败任务|停止并写明|
|新手|`quest_leave_team` 单人副本退队|停止并写明|
|新手|`allow_spend` 买蒙汗药酒|停止并写明|
|新手|`allow_item` 用背包道具|不用，任务栏道具不受限|
|新手|`xinshou_gifts` 领升级礼包|不领|
|新手|`xinshou_school` 门派|到“加入门派”时停止，不随机|

### 与原规则不同的地方

|原规则|现在的做法|可能的偏差|
|---|---|---|
|商会购买（师门买物品、定位符）|不做|师门这一环按做不了处理|
|`Bag_DeleteItem`、丢弃、出售、存仓|不做|背包更容易满，满了停止|
|师门环数记到本地文件跨次累计|只算本次|`bjk29` 是本次环数|
|马贼 `meGetMazeiInfo` 监听刷新|没有源码，不做；只循环勾选地图|刷新慢的图也会跑|
|马贼读等级、颜色、称号|读不到；开不动的绿马跳过 30 秒|可能试开高等级马|
|马贼收费传送、定位符、补给、存仓、喊话、换队长|不做|赶路更慢|
|主线、新手 `meIsMissionOutline`|没有源码，改用游戏的 `GetMissionOutlineNum`、`GetMissionOutlineInfo`|**返回格式是推断的，最需要实测**|
|主线黑名单文件|改为设置项 `zhuxian_skip`|—|
|新手至尊武圣卡（`NewUserCard` 激活码）、财富卡奖励|不做|少一批奖励和经验|
|新手随机门派|必须自己填|—|
|新手 `Lua_SetProtectTime`（改安全设置）|不做|—|
|新手 `meLevelUp`|没有源码，改用 `EXP`、`NEEDEXP` 判断后调用 `AskLevelUp`|字段名和接口是推断的|
|新手 `DoubleExp_Get`、`Freeze`|不做|不自动领双倍|
|师门类 `OpenPackage`（`CallFun` 直发）|新宿主操作 `open_object`，调用打开包裹的同一函数|**采集物能否这样打开要实测**|
|师门交珍兽 `mePetAddlistByName`|改用抓珍兽卖 NPC 里的 `Exchange:AddPet`|要实测|
|任务栏物品下标|按 `200+序号` 推断（背包 0、材料 100）|**要实测**|

### 需要实测确认

1. 任务大纲：日志里 `主线任务 · 接任务` 有没有出现；一直“没有可做的任务”就是读取格式不对，把 `questbook:outline` 的情况告诉我。
2. 师门副本类（第 4、9 类）：进副本后是否自动完成。原脚本只等待，这里顺手清附近敌人。
3. 采集：`open_object` 能否打开采集物。
4. 用任务道具：`PlayerPackage:UseItem(200+i)`。

## 死亡复活

新增设置 `revive_mode`（45 个任务）和 `revive_wait_seconds`：

|模式|行为|
|---|---|
|停止（默认）|和以前一样，血量低于阈值就停|
|等待救援|死了才处理；等人救，能接受就接受，超时停止|
|等待后出窍回城|超时点 `Relive_Out_Ghost`，走到孟婆回洛阳。师门、马贼、主线、新手继续做；副本任务报明原因结束，因为副本内进度已经中断|

选后两种时，活着不会因为血量低停止，血量由战斗维护负责。通用宿主的 `meReliveHandle(-1)` 也改为真的点出窍。

战场类（宋辽、楚汉、弈决山河）一直走自己的复活面板；加血机、打架用各自的 `xzk95`。

**需要实测：** `Relive_Relive_Button`、`Relive_Relive` 是从 `Interface.axp` 读到的名字，接受救援的按钮是否就是它要确认。

## 三环

**老三环，已修：**
- 都统阶段走错了点：路线表把第 4 阶段映射到 (204,122)，原脚本是 (194,54)。
- 匪类阶段按队员序号分两个营地（0、2、4 号一边，其余一边）。
- 打的过程中捡包（匪类阶段除外），打完搜 6 秒再离场。
- 葛荣阶段先到大殿集合，最多等 20 秒，有 244 技能时拉怪。
- 任务失败或中途离开过副本：打开 `dungeon_abandon` 后放弃重接，否则停止。

**坐骑：** 游戏没有 `DispelBuffByName`。现在在这种情况下点坐骑切换键（`Player:UseSkillInLua_Const`，原脚本飞行时也这样用），8 秒内坐骑 ID 要变成 -1，否则停止且不重复。**这影响所有任务的下坐骑，要实测。**

**新三环仍是缺口：** 原脚本源码里没有它，何悦的多级菜单、固定路线、离场 NPC、首领机制都没有依据，不编造。现在只能靠任务描述的坐标或手填路线。需要你实测一次，把日志和菜单文字给我。

## 安装结构

```
TLBB.exe          启动器，没有 Qt 依赖
TLBBRuntime.dll   程序主体、Qt、运行库，打包在一个资源里
TLBBEngine.dll    游戏内引擎，和以前一样
scripts/          builtin 明文 Lua，tasks 任务目录，user 用户脚本
data/             账号、配置、日志；docs 许可和说明；cache 解压的运行库
```

启动器把 `TLBBRuntime.dll` 解到 `data/cache/runtime-<版本>/`，只在版本变化时解一次，然后在自己进程内加载 `TLBBApp.dll`。所以程序看到的目录仍是安装目录，后台子进程也还是调 `TLBB.exe`。

- **为什么没有真正合并 Qt：** 现有 Qt 是动态库，静态版要自己编译，而且静态链接要额外履行 LGPL 的重新链接义务。这个方案用户看到的文件数已经满足要求，以后要改静态也不影响目录结构。
- **脚本校验：** 发布版不再有 `TLBBData.rcc`，所以不校验脚本哈希，因为你要能直接改。`data/package-manifest.json` 仍记录每个文件的哈希。
- **覆盖安装：** 旧版留下的 Qt、插件、`TLBBData.rcc` 由安装器删除；旧 `logs/` 目录里的历史日志不动，新日志写到 `data/logs/`。
- **开发版不受影响：** `TLBB_PACKAGED` 只在 `tools/build-client.ps1` 里打开。

校验：`tools/verify-release.py` 要先加载 `tools/env.ps1`，因为完整自测用构建目录的开发版 EXE，打包版没有内置资源包。打包版 `TLBB.exe` 自身在去掉开发 PATH 后跑资源报告、登录自测和 35 项界面检查，已通过。这次顺手修了两条过时的界面检查：写死的 259 个别名改为从目录计算，计划中任务的检查对象从师门换成 `pet_shop`。安装器本身没有生成过，`packaging/tlbb.iss` 只改了未编译。

相关文件：`src/launcher_stub.cpp`、`tools/make-runtime-pack.py`、`tools/build-client.ps1`、`packaging/tlbb.iss`、`tools/package-client.py`、`tools/verify-release.py`。

## 测试

`tests/long_task_tests.hpp`：师门各类型、风险开关、停止；马贼流程和人数；主线和新手接交、拒接跳过、大纲不可读、失败任务、跳过名单、等级上限、门派必填；死亡三种模式。三环见 `tests/sanhuan_tests.hpp`。
