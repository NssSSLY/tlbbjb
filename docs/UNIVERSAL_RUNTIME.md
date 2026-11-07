# 通用战斗与运行文件整理 · 0.14.0

日期：2026-10-25。用户明确要求通用战斗服务全部副本，而非只做珍珑棋局；安装后文件也应集中。保持不生成安装包、ZIP 的要求，本轮只编译开发版、构建程序运行所需的不压缩资源文件并验证。

## 通用层与副本层

scripts/legacy/combat.lua 现在只提供副本无关的目标检查、技能输出、人物恢复、珍兽维护、停滞和击杀回执。通用层中没有远古棋魂、张弈国或固定棋局巡逻坐标。CombatRuntime.new(scene, options) 的 boss_names 由调用方提供，任何副本规则可共用 CombatRuntime.step 和 maintain。

珍珑棋局专用兼容流程拆至 scripts/legacy/dungeons/qiju.lua；旧 original_combat 模块名保留兼容现有原字节码，其内容明确属于棋局专用适配。原 605 条指令及包装文件保持原哈希。

任务的战斗能力由内置任务清单声明。Worker 统一通过 resolveLegacyEntry 解析任务 ID、入口和能力，不再只接受旧适配器名称。这同时修复战斗任务和 battle_inspect 虽存在于清单却被旧名称检查拦截的问题。任务入口仍检查目录归属及 Lua 后缀，声明未启用的条目不能执行。

完整副本需要各自的入场条件、路线和阶段、Boss 机制、失败重进、通关确认及离场。共用战斗负责角色行为；通用击杀计数不能代替完整副本通关判定。游戏内扫荡和进入副本执行原战斗流程分别记录。

## 全部原模块的导入范围

所提供原程序中的 32 个副本 / 活动 Lua 5.4 模块均已导入 scripts/dungeons/original，并统一登记在 scripts/dungeons/catalog.json。导入只把 GBK 字符串转 UTF-8，逐模块复核指令、数值和控制流不变；没有执行这些字节码或加载原 DLL。原模块二进制共 530184 字节，直接参数与全局依赖从前一轮校正后的静态清单沿用。

导入资源并不代表全部宿主接口已接通。当前原模块执行适配仍只有一个，其他条目标为 source_audited_pending_adapter。原有的通用场景战斗、游戏内扫荡任务另行保留。不能将这些任务计算为所有副本完整流程都已完成。

每个角色的“信息 → 副本接入清单”显示全部 32 个原模块的名称、方式、接入状态及直接参数项数，参数项提示保留原配置键。列表不把待接入模块伪装为可运行功能。

重新导入原模块的开发命令：

```powershell
. .\tools\env.ps1
& 'C:\Users\liqia\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' -B tools\import-dungeon-rules.py --write
```

该命令只处理已提取的原字节码资源，不激活新任务、不加载目标程序 DLL，也不制作安装器。

## 文件数量与体积

检查时，.tools 有 33805 个文件、1266.63 MiB，属于编译器、Qt SDK、构建缓存等开发环境；artifacts 有 2935 个文件、121.36 MiB，属于研究、测试、备份等证据。已有 dist/TLBBClient-0.11.0 运行目录为 132 个文件、31.20 MiB。这些目录的用途不同，不能把整个开发工作区当作安装内容。

Qt6Core.dll、Qt6Gui.dll、Qt6Widgets.dll 合计 23.89 MiB，是运行包主要体积来源。原程序主要 EXE 与 dfz64.dll 分别为约 18.42 和 5.59 MiB；其 DLL 已内嵌 318 个 Lua 模块，少量可见二进制中容纳了大量内容。文件少不代表没有模块、没有运行库或功能天然更简单。

现在 147 项内置文件（含 101 个明文 Lua、32 个原 Lua 字节码及目录数据）集中到一个 TLBBData.rcc，大小 1293467 字节。该文件不压缩，Qt 直接读取，不会启动时解压出几百个临时文件。资源清单逐项保存长度和 SHA-256，加载时核验，文件总数据限 8 MiB、条目限 256、单项限 2 MiB。

这一步减少运行文件数量；Qt 依赖仍保留，因此不宣称整体体积会成比例减少。进一步减少 Qt 运行库，需要改变构建方式或迁移界面和部分基础设施，属于后续独立重构。

## 运行布局与热更新

新运行布局的核心是：

```text
TLBB.exe
TLBBEngine.dll
TLBBData.rcc
Qt6Core.dll / Qt6Gui.dll / Qt6Widgets.dll 及必要编译器运行库
platforms/qwindows.dll
data/       每个账号和角色的配置
logs/       运行日志
overrides/  需要修改的单个 Lua / 数据覆盖文件
```

内置资源优先级为 overrides、TLBBData.rcc、旧版分散文件回退。例如修改人物恢复规则时，将文件保存为 overrides/scripts/builtin/legacy/modules/battle_support.lua；只需这一项覆盖文件，其他脚本继续读资源文件。运行中的任务继续使用其启动时的快照，停止后重新运行加载修改；外部 Lua 覆盖不需要重新编译 EXE。目录中新增模块可由 LoadScript 加载，仍保留任务堆和模块数量限制。

新增“内置”脚本则放在项目 scripts 中，构建时自动归入资源文件。C++ 接口变化需要重新编译程序；修改整个 TLBBData.rcc 后需重新启动使用该资源的程序。新的运行目录无需交付 .tools、src、include、tests、tools 或 artifacts。

## 构建与验证边界

本轮只更新 .tools/build/client 开发版；没有生成新的完整发布目录、安装器、ZIP，未操作真实游戏。隔离测试目录仅放 EXE、Engine、Data 及自建窗口测试程序，Qt 由开发环境提供；其中不含分散 scripts / tasks，已验证目录读取、角色面板、覆盖规则及损坏资源拒绝加载。该验证不等同于安装后脱离开发环境的完整发布验收，也不等同于所有副本实机验收。

开发构建仍用 tools/env.ps1 加 cmake --build 和 ctest。需要自行生成完整安装器时运行：

```powershell
Set-Location E:\game\tlbb\jb
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-installer.ps1
```

预期输出 dist/packages/TLBBClient-0.14.0-Setup.exe。脚本收集 TLBBData.rcc 并核对全部源资源哈希，不复制开发工具和分散内置脚本，排除账号、日志、用户覆盖文件；默认不生成 ZIP。本轮未执行该命令，安装器构建链只完成语法和接线检查。

## 下一批实现重点

继续补齐原副本公共宿主接口，优先把选怪 / 战斗、队伍状态、导航与 NPC 对话、阶段事件、完成回执做成共用能力，再依据每份原规则逐批启用。普通副本和复杂副本的特殊机制独立验证；所有未启用模块继续保持明确状态，直到规则、参数和宿主接口闭环。

最终验证：44 组核心检查、130 项游戏 SDK 片段、42 项战斗专项、26 项界面检查通过；147 项资源全部核对源文件，32 份原字节码校验指令与控制流不变。单文件覆盖、损坏拒绝、无分散脚本目录的运行验证通过。实机及全部副本执行未完成，未生成安装器、ZIP 或完整发布目录。最终证据为 artifacts/universal-runtime-0.14.0/verification.json。
