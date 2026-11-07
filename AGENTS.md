# 后续任务入口

开始修改前读取：

1. `docs/EXECUTION_GUIDELINES.md`：用户确认的实现与验收准则。
2. `PROGRESS.md` 顶部当前状态。
3. 涉及新、老三环时，读取 `docs/SANHUAN_HANDOFF.md`。
4. 涉及治疗、峨嵋或战斗维护时，读取 `docs/EMEI_SUPPORT_HANDOFF.md`。
5. 逐项销项按 `docs/FIX_CHECKLIST.md`；已销项和实际接口缺口分别保留，不用历史说明覆盖新代码。
6. 用户已要求继续其他副本；水牢见 `docs/WATER_PRISON_HANDOFF.md`，四绝庄见 `docs/SIJUE_HANDOFF.md`，燕子坞见 `docs/YANZI_HANDOFF.md`。燕子坞四档难度、完整四阶段战斗、解药/包裹、离场及活动次数回执已完成开发与离线回归。三神幻境（凤鸣、汴京）流程已完成开发与离线回归，见 `docs/SANSHEN_HANDOFF.md`。观山海流程已完成开发与离线回归，见 `docs/GUANSHAN_HANDOFF.md`。圣兽山野猪（追捕野猪王、野猪暴走）流程已完成开发与离线回归，见 `docs/YEZHU_HANDOFF.md`。剑破明王境流程已完成开发与离线回归，见 `docs/MINGWANG_HANDOFF.md`。夜探天波府流程已完成开发与离线回归，见 `docs/TIANBO_HANDOFF.md`。凤凰陵墓（普通、困难）流程已完成开发与离线回归，见 `docs/FENGHUANG_HANDOFF.md`。弈决山河流程已完成开发与离线回归，见 `docs/YIJUE_HANDOFF.md`。聚灵谷（简单、普通、困难）流程已完成开发与离线回归，见 `docs/JULING_HANDOFF.md`。蹴鞠大赛、刷箱子、天龙幻境流程已完成开发与离线回归，见 `docs/SMALL_DUNGEONS_HANDOFF.md`。天降奇兽流程已完成开发与离线回归，见 `docs/TIANJIANG_HANDOFF.md`。活动类（千百渡他、楚歌难渡、虞花苦渡、渡别乌江、楚汉之战、暗袭萧阿刺、侠客行、逆袭）流程已完成开发与离线回归，见 `docs/ACTIVITY_HANDOFF.md`。扫荡副本流程已完成开发与离线回归，见 `docs/SAODANG_HANDOFF.md`。战斗和野外（宋辽、贼兵入侵、偷袭门派、崇武试炼、拭剑天下、加血机、自动打架）流程已完成开发与离线回归，见 `docs/BATTLE_TASKS_HANDOFF.md`。师门、马贼、主线、新手 1-40、死亡复活、老三环修复和新安装结构已完成开发与离线回归，见 `docs/LONG_TASKS_HANDOFF.md`。短任务已完成开发与离线回归，见 `docs/SHORT_TASKS_HANDOFF.md`。日常（茗茶、天劫楼、临危悟道、剑纵群雄、杯酒、金针渡劫）已完成开发与离线回归，见 `docs/DAILY_TASKS_HANDOFF.md`。凤鸣王陵、汴京王陵流程已完成开发与离线回归，见 `docs/WANGLING_HANDOFF.md`。琅嬛福地（含困难）完整四关流程已完成开发与离线回归，见 `docs/LANGHUAN_HANDOFF.md`。兵圣奇阵完整四关流程已完成开发与离线回归，见 `docs/BINGSHENG_HANDOFF.md`；新副本复用 `modules/dungeon_tactics.lua`，新增的副本模块要加入 `src/resident_client.cpp` 的 `flowOnly` 名单。用户计划等副本接入差不多后统一实测。挑战缥缈峰完整五关流程已完成开发与离线回归，见 `docs/PIAOMIAO_HANDOFF.md`。少室山完整五关流程已完成开发与离线回归，见 `docs/SHAOSHI_HANDOFF.md`（原脚本反编译对照见 `docs/SHAOSHI_REFERENCE.md`，全部原脚本的可读源码在 `原脚本源码/`，程序运行的是 `scripts/original-source/` 副本，对接表 `docs/ORIGINAL_SOURCE_MAP.md`）。其他副本保持一个副本逐项推进；实测反馈优先在原流程内修复。

当前按用户最新要求继续其他副本，维护顺序以最新交接为准；三环缺口仍保留。允许依据已确认规则编写明文 Lua，不要求照搬天龙助手。沿用游戏内驻留 VM、游戏 API 与现有内存读取，集中补齐接口和结果契约；禁止以占位返回值替代必要功能。每个副本按完整流程推进，不以目录数量报告进度。

项目文件、构建工具和产物放在 E:。可编译及运行离线自动化校验；用户自行进行真实游戏测试。未明确要求时不生成安装器、ZIP，不更新已安装目录。安装命令未变化时无需重复解释。

进度直接列完成项、未完成项及下一项。项目上下文写入上述文档，不记录账号或密码，不复制 Codex 会话数据库。
