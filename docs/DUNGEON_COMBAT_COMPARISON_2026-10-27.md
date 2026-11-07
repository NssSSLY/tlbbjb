# 完整副本战斗：原规则对照与当前状态

本次按实际入场、战斗、机制和通关方向推进，扫荡独立。原始模块来自先前对用户提供的天龙助手 `dfz64.dll` 的静态分析与字节码提取。没有运行第三方 DLL 或操作游戏。代码库无 Git，源文件请按本工作区当前内容核对。

## 天龙助手如何组织副本

- 它的任务字节码由自己的 Lua 宿主执行，`GetLuaValue` 通过游戏窗口线程执行游戏 Lua；`EnumEnvObj` 等还使用原生对象结构。宿主调用链与证据 ID 见 `docs/REA_FUNCTION_IMPLEMENTATION_2026-10-26.md`。
- `讨伐燕子坞` 原入口 `00313c18` 初始化副本场景 ID 236 和部分 Boss/坐标数据；依赖 `RecvState(3)`、队伍、对象枚举、战斗、宠物、死亡状态、活动完成状态等。入口指令见 `artifacts/original-combat-0.12.0/listings/00313c18.listing.txt`。
- `四绝庄` 原入口 `002e1226` 设置场景 ID 291，加载 `fn四绝庄` `004ed3ee`，分别处理任务和 Boss 机制；配置包含 Boss 不敲钟、分担失明、跑对角、不跑龙柱、死亡出窍、小号模式、难度和队伍人数。入口指令见 `artifacts/original-combat-0.12.0/listings/002e1226.listing.txt`。
- 原队伍模块 `0055b610` 的 `CheckAllTeamHP` 涉及队友门派、血量及等待期间调用 `FubenAttack(-1)`；`IsTeamSteady` 涉及队友周围数量和超时。这些状态不能用固定 true 假装已经读取。

## 本次落地

`scripts/legacy/combat.lua` 的 `CombatRuntime.selectOriginalTarget` 处理原副本显式给出的敌人：检查对象为可见活体敌人并保留客户端/服务器双 ID；找不到指定对象时报错，避免由底层默认选择另一个目标。指定的敌人发生变化时切换目标，并清除旧目标的战斗进度。每步使用当前角色坐标作为范围中心。

`scripts/legacy/modules/original_combat.lua` 的已有棋局原规则宿主调用了该公共接口。燕子坞和四绝庄尚未接上该宿主，因此不能声称这两个完整副本已经可运行。

`tests/original_rules_tests.hpp` 中新增测试，覆盖原规则指定目标切换、指定目标缺失和动态坐标；还在隔离模拟宿主中加载上述两个原入口，检查四绝庄共享模块和燕子坞回调、接收状态调用，停在首次场景读取前。测试中的 `RecvState` 和其他前置参数是替身，不是生产环境接口实现。

尚需逐项完成：真实队伍与队员状态、场景/阶段、目标与危险机制、移动、入场/任务、掉落和复活、最终通关与顺序队列回执；完成后需游戏内验证。未接入的完整副本入口保持禁用。

## 验证与构建

5 个 CTest、58 组核心检查、221 项游戏 SDK、34 项界面检查通过。没有真实游戏或长期多开测试，没有生成安装包或 ZIP。开发版位于 `.tools/build/client-0.15.0/TLBB.exe`。用户自行打包可运行 `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-installer.ps1`。
