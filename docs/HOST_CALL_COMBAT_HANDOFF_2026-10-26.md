# 2026-10-26 调用兼容与通用副本战斗维护

开发版本继续为 0.15.0。依据本轮 `REA_FUNCTION_IMPLEMENTATION_2026-10-26.md` 的静态证据维护宿主接口，没有把第三方 dfz64.dll 加入程序。任务执行仍是本程序游戏内 Lua 5.4 VM，游戏接口调用仍在对应游戏窗口线程中执行；没有恢复成每动作外部 IPC。

## 本轮改动

### 模块调用

- `CExec(name)` 每次显式调用执行一次当前任务快照中的模块，保留多返回值及中间 nil。
- `LoadScript(name)` 继续缓存本程序公共模块，避免重复初始化；它与 CExec 的执行语义明确区分。
- 同一名称可写成 `module` 或 `module.lua`；支持中文名称。已保留科举等旧兼容入口。
- 加载失败或循环引用时清除“正在执行”标志；不会自动重试该调用。任务自身显式调用产生的行为仍由脚本负责。
- 运行中只使用启动时的模块快照；不读取任意路径，不接受目录穿越。新增公共模块放入 `scripts/legacy/modules/`，下次启动任务载入；并不意味着 32 个未启用副本可以跳过契约校验直接运行。
- `CSleep` 复用现有可暂停、可停止的协程 Sleep，不阻塞游戏窗口线程。

### 游戏 Lua 返回值

`GetLuaValue` 增加原格式 `l`，用于有限浮点数，现支持 n/l/s/b。保留本项目现有 n 的数值语义和空格式的标量自动返回，不把已有坐标等小数截成整数。

布尔格式 b 接受真实布尔及有限数字，数字 0 返回 false，非零返回 true。nil / 文本不能冒充可读取的布尔状态；未知值报错。空格式仍可保留 nil。原程序返回格式、整数转换及错误默认值与本程序并非完全相同，不能宣称原生 ABI 全等。

### 通用对象筛选

`EnumEnvObj` 在当前可验证的 NPC 对象范围内补上 class/title 字段，供原对象筛选函数使用。已观察存活且敌对的同一客户端 ID + 服务器 ID，在生命读为 0 时保持怪物分类；ID 被复用、消失或不再出现在快照中，不继承旧身份。

`Enum2XByName` / `Enum2XByClass` 使用已逐指令保留的 13 个原公共函数模块，支持原位置参数、名称、生命、距离筛选和排序，不再仅限单参数子集或棋局入口。玩家、珍兽、包裹等对象尚未枚举，对这些类别的请求明确拒绝；缺少原生字段仍不伪造。空 title 只代表当前未提供称号读取，不代表原对象没有称号。

原 `original_combat.lua` 保留为棋局宿主，只修正 Team 表复用；没有改写原棋局字节码和主循环。

### 技能、人物和宠物维护

- 技能枚举按每批最多 6 个槽位读取，一批最多 30 个返回值；不会逐帧扫描全部动作。
- 有可靠数量时使用数量界限；没有 GetActionNum、查询失败或数量为 0 时，有界检查原已适配的 0..255 槽位。256 个槽位合法，越界/非整数数量拒绝。
- 稀疏末槽、重复动作、人物技能 IsEnable 的 true/false 或 0/1、宠物出战的 true/false 或 0/1 都有针对性检查。
- 人物 HP/MP、门派能量、宠物生命/快乐度、恢复等待和异常不重发沿用原维护层。没有通过返回默认血量或假冷却让任务继续。
- 技能页“可用”列综合限制、enabled 和 cooldown 显示“待适配 / 当前不可用 / 冷却中 / 可用”；仍是本次读取快照，实际释放前再次确认。

## 原名称技能适配：准确范围

新增模块 `scripts/legacy/modules/original_skill_host.lua`，通过 skilllib 首次调用时才加载，普通日常任务不触发技能扫描。

| 接口 | 当前行为 | 限制 |
|---|---|---|
| skilllib.CEnumSkill() | 返回当前已学技能定义 ID、动作句柄、槽位、名称、可用状态及冷却 | `schema=sdk_action_v1`；未伪造 baseskl/attack/consume/fdist 等原生属性 |
| skilllib.CGetCD(cdidx) | 重新核对同一动作身份并读实时冷却 | cdidx 必须来自本适配器本次 CEnumSkill 返回的动作槽位，不能混用原 DLL 内存表索引 |
| skilllib.CUseSkillByID(defineID, clientID [, -1, -1]) | 普通敌方 NPC 目标技能，使用现有 CombatScan / CombatCast | 任务必须声明 combat；校验已学定义 ID、动作身份、冷却、血量、目标双 ID、敌对、存活、距离和施放间隔 |
| skilllib.CUseSkillByID2 | 明确报独立原生协议尚未适配 | 不混用普通技能接口 |
| skilllib.CUseSkillByID_fb | 明确报专用调用尚未适配 | 不混用普通技能接口 |
| playerlib.CGetPos() | 返回 x/y 表 | 来自当前绑定角色实际位置 |
| playerlib.CGetTargetID() | 返回当前目标的客户端 ID，没有目标为 -1 | 不是服务器 ID 或 GUID |

这是依据当前官方游戏 SDK 和已有验证链提供的同名子集，**不是原 skill.lua 全属性或全部原生接口的完整兼容**。没有把原生动作句柄、技能定义 ID、客户端 ID、服务器 ID、宠物 GUID 混成同一个数值。`OriginalCallCapabilities` 明示当前对象/技能子集，不启用未知原生属性。

技能提交的 1 只表示提交；0 表示当时未提交。异常或不确定结果会封住本次 VM 中的再次提交。治疗/增益配置不能通过该接口作为敌方输出；指定地点/引导等特殊技能继续等待专用适配。

## 副本范围

通用“副本内战斗”与上述接口可以继续做实机验收。已有原棋局、兼容重建棋局及游戏扫荡入口保留。32 份原副本/活动资源继续保留各自控制流，没有因为共享调用接口增加就全部设置 runtime_enabled。

其他副本仍须分别完成入场、队伍条件、阶段/首领机制、特殊技能、掉落、任务状态、离场及最终回执；CExec 返回不能代替任务成功。原 CEnumSkill 的完整属性、玩家/宠物/包裹原生枚举、两个专用施放分支和指定地点技能仍待适配。

## 构建与验证

本轮只编译 `.tools/build/client-0.15.0` 开发输出，未收集新发布目录、未生成安装器或 ZIP，也未控制真实游戏。SDK 场景使用本程序自建 LuaPlus 状态，原 DLL 未加载。

```powershell
Set-Location E:\game\tlbb\jb
. .\tools\env.ps1
cmake --build .tools\build\client-0.15.0 --parallel 3
ctest --test-dir .tools\build\client-0.15.0 --output-on-failure
```

开发程序为 `.tools/build/client-0.15.0/TLBB.exe`，需在上述进程环境中启动。引擎修改后，对应游戏需退出并重新启动、重新绑定后才会使用新 DLL；不要把已常驻的旧 DLL 当成已更新。

用户自行生成完整安装器：

```powershell
Set-Location E:\game\tlbb\jb
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-installer.ps1
```

当前输出路径为 `dist/packages/TLBBClient-0.15.0-Setup.exe`，默认不生成 ZIP。本轮未执行这个命令。

源文件备份、CTest、SDK 场景、来源核验、最终二进制和资源哈希在 `artifacts/host-call-combat-2026-10-26/`。最终检查数量以该目录 verification.json 为准，历史测试数量不作为本轮验收。

最终结果：5 个 CTest 目标全部通过，49 组核心检查、62 个战斗 SDK 场景、219 项游戏 SDK 检查、14 项登录检查、27 项原生界面检查通过。自建窗口原生快捷键本次通过，不能当作真实游戏快捷键验收。204 项资源与源文件哈希一致，32 份原副本资源来源及指令保持验证通过，单文件覆盖及损坏资源拒绝加载通过。当前原完整副本清单仍仅刷棋一项启用；其他副本的游戏内扫荡属于既有独立任务，不能混算为实打通关。
