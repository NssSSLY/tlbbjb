# 峨嵋治疗策略与副本维护

更新：2026-10-29。实现准则沿用 EXECUTION_GUIDELINES.md；副本流程见 SANHUAN_HANDOFF.md。本批仅开发编译与离线校验，真实游戏由用户测试。

2026-10-31 燕子坞补充：四阶段战斗及等待期间复用人物治疗，`emei_attack=false` 不提交人物输出；离线队友推动战斗并完成最终次数回执。`dungeon_pet_guard` 修正收回回执晚于机制结束的顺序：不能仅看到已休息就恢复输出，必须先恢复同一 GUID 珍兽出战；新增生产维护层与 LuaPlus 回归。详见 YANZI_HANDOFF.md 和 `artifacts/yanzi-2026-10-31/verification.json`。

2026-10-31 四绝庄补充：`dungeon_pet_guard` 经 CombatRuntime 的 `setPetSuspended` 暂停珍兽维护；待确认的珍兽技能/喂养先等待结束，再用游戏休息动作收回。休息期间仍读原珍兽 GUID 与生命，允许“同一珍兽已休息”状态，暂停珍兽技能/喂养/回气，人物治疗继续。实际恢复同一珍兽出战后才解除暂停。此控制只由明确的副本机制调用，不改变其他任务的默认珍兽行为；异常/人工停止不自动补出战指令。生产执行层与 LuaPlus 离线回归见 SIJUE_HANDOFF.md 和 `artifacts/sijue-mechanisms-2026-10-30/verification.json`。

## 使用与配置

每个游戏面板“技能 → 峨嵋”独立保存：

|配置键|界面含义|默认|
|---|---|---|
|emei_enabled|启用峨嵋专用策略；以实际 MEMPAI=4 判定，门派备注不参与执行|关闭，用户选择开启|
|emei_attack|参与攻击；关闭时只治疗，不提交人物输出或珍兽攻击技能|关闭|
|emei_team_heal|治疗队友|开启|
|emei_heal_percent|治疗触发血量百分比|75|
|emei_self_priority_percent|自身低于此值时优先自保|35|
|emei_heal_skills|治疗技能顺序；每行一个实际已学技能名|空白时按已学技能选清心普善咒、冲虚养气|

阈值 1–95，自保阈值不得高于治疗阈值。自身低于本任务通用生命停止阈值时也优先自保，不会先救队友而忽略自身保护。手填技能严格核对，不用未学技能代替。技能读取页新增“峨嵋治疗”用途，可将选中人物技能加入此列表。启用峨嵋会启用其战斗维护依赖；关闭总维护同时关闭峨嵋策略。

峨嵋专用策略启用后，是否攻击由 emei_attack 决定，治疗由专用列表负责；旧的仅自身恢复开关不再覆盖峨嵋选择。其他门派仍使用通用策略。

## 运行方式

`scripts/legacy/modules/emei_support.lua` 在当前驻留 VM 内工作。读取小队成员的生命、最大生命、同场景状态、服务器/客户端对象 ID、名字及 GUID；缓存 500 ms，一次最多六个队员，不枚举整个场景玩家列表。紧急自身优先，其他候选按生命百分比由低到高选择；死亡、异场景或对象未加载者不提交治疗。

施放前重新读取队员身份，核对 GUID、名字及双 ID，再经现有动作按钮执行器检查冷却、可执行状态和选中目标。治疗回执来自生命增加或已启动的技能冷却；后者只表示治疗动作得到反馈，不表示生命一定净增加，也不参与副本完成判定。这样避免持续受伤抵消治疗时误报“治疗失败”。无动作反馈、身份变化或目标死亡有明确退出原因。

只治疗模式初始化时选择自己并请求停止移动；之后不提交本执行层的人物输出/基础攻击/珍兽攻击技能。游戏自身的珍兽 AI 设置不是本策略控制项。恢复、喂养和回气仍按原配置执行。

## 副本改动

- `combat.lua` 将“是否可以输出”与“本次是否执行了恢复动作”分开。只治疗且空闲时仍扫描战场，返回 empty/supporting，让副本继续巡点与读进度，而不是一直卡在 recovering。
- 原技能宿主 `original_skill_host.lua` 接入同一输出开关，治疗技能不作为敌方输出。
- `dungeon_api.lua` 在接取/入场前准备战斗配置；`dungeon_flow.lua` 在等待面板进度或阶段切换时仍执行恢复维护。新、老三环使用此链。
- 重新读取技能目录保留团队辅助函数，不再把 `__tlbbBattle` 整表清空。
- 编辑技能页会更新顺序/定时草稿的 battle_system。已经运行的 FlowRunner 快照保持不变，重启任务后使用新配置。

当前新三环的默认菜单、固定路线与离场资料，以及坐骑取消索引、地面拾取等缺口仍按 SANHUAN_HANDOFF.md 继续，不因本批治疗改造变成已完成。

## 接口证据与测试

本机 Game.exe SHA256：`72f4898ee04d2e8a6d94ff6d45cdc183dfa655eae40c31ddc67dcc2099d9c00d`。

团队数据采用 DataPool:GetTeamMemberInfo、GetTeamMemberObjIDNamePortInfo、GetTeamMemGUIDByUIIndex、IsTeamMemberInScene 与 Target:GetServerId2ClientId。注册引用及有界反汇编位于 `artifacts/emei-2026-10-29/native/`。GetTeamMemInfoExByIndex 返回其他成员元数据，不冒充生命值。REA 的 Ghidra 整程序分析启动超时，本批没有取得该函数的伪代码；实际采用的证据及局限见同目录 REA_STATUS.md。

`tests/battle_support_fixture.cpp` 使用本机 LuaPlus 的离线状态执行这些 Lua 5.0 调用；覆盖治疗优先、自保、实际门派、死亡/异场景/未加载排除、身份变化、离队、不输出、手动与自动技能、冷却回执、大血量格式、技能目录重读和原宿主输出开关。

`tests/catalog_ui_tests.hpp` 覆盖配置保存、角色独立、队列同步及总开关联动。`tests/sanhuan_tests.hpp` 覆盖阶段等待期间仍进行恢复维护，保留两个三环入口全流程回归。最终结果和源/产物哈希位于 `artifacts/emei-2026-10-29/verification.json`。

本批输出仍在 `.tools/build/client-0.15.0`。未制作安装器、ZIP 或更新安装目录。

最终离线结果：6 个 CTest 目标、85 组核心检查、107 项战斗/SDK 检查通过，其中 19 项为峨嵋场景；三环生产入口 14 个模拟运行场景通过。界面检查覆盖配置保存、角色独立、草稿队列同步及依赖联动。该记录不包含真实游戏测试。
