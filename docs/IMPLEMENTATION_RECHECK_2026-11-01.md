# 修复后复查（2026-11-01）

本次只审查，未修改功能代码、未操作游戏、未打包或更新安装目录。已读取执行准则、最新进度、修复清单和峨嵋交接。

## 已核实的修复

- R01/R02：Worker 两条路径调用 TaskCompletion::judge；带契约任务不再要求自身击杀数，普通原战斗脚本不再仅凭 combat 标记或少量击杀标为 verified。
- R04：已加入选中自身停止攻击；以下 F04 保留异常路径问题，不否认正常路径修复。
- R06：索引缓存改为实际路径、大小和修改时间标识。外置原源码仍要求同步更新 index.json 的 SHA256；仅改 Lua 文件不会自动通过校验。
- R09：当前 TLBBData.rcc 为 9,159,877 字节，旧 binary 分片已排除。
- 队伍/Buff/默认配置等新实现存在；接口完整性仍有下列问题。

## 新确认问题

### F01 / P1：玩家类别枚举入口仍拒绝玩家

scripts/legacy/resident.lua:131–140 的 Enum2XByClass 只接受 NPC、怪物。新增 __playerObjects 仅在 Enum2XByName 的 mask[3] 分支打开 withPlayers，按类别查询未接入。少室山(大理).lua:719/882、凤凰陵墓和峨嵋加血机等原脚本直接使用 Enum2XByClass("玩家")，到该分支即报“对象类型尚未接入：玩家”。需要让类别查询与名字查询共享同一枚举范围，并回归混合类别与错误后范围复位。

### F02 / P1：珍兽 GUID 适配出现循环调用

original_generic_host.lua:388–390 的 playerlib.CGetFightPetGUID 回调 Player:GetFightPetGUID；按需加载的原 player.lua:39–40 又调用 self.CGetFightPetGUID。没有六个 token 特例覆盖的任务，在缺少其它真实实现时形成循环。原 daguai.lua 多处调用该方法。离线用原方法及实际适配函数复现，10000 指令钩子截停；生产运行会受到 VM 限制并终止，并非返回有效珍兽信息。需要让最底层直接读取真实 GUID，不能回调上层包装。

### F03 / P1：不可读的异场景队员被伪装成死亡

original_generic_host.lua:164–173 将异场景成员 hpcur/hpmax/hp 设为 0，未将原 API 读取的 dead/offline 状态传递出去。原 team.lua:82–95 用 id>0 且 hp==0 判死亡。若异场景记录仍有正 server ID，会把活着但不在场的队员归为死亡；原 fn四绝庄.lua:1171 等会使用该判定。已用生产适配函数与原 Team:IsHaveDieMember 离线复现。应区分死亡、离线、异场景、读数未知，并同步调整使用者；不能只换一个同样可能被误用的数值。

### F04 / P2：选自身失败时没有继续尝试停走

src/resident_bridge.cpp:107–116 的 stop_attack 顺序为读取身份、选中自身、确认目标、stop_motion；身份或选中确认失败会先抛异常，最后停走不会执行。Manager::finish 捕获后销毁 VM，故正在移动的角色在该异常分支没有收到停走请求。当前代码会报告错误，不是静默成功。应把停攻/停走做成独立的尽力清理步骤，汇总两者结果。未在线复现角色行为；本项依据明确的异常控制流。

### F05 / P1：首领目标等必要字段仍可能静默改变机制分支

include/resident_vm.hpp:Object 没有 target、title、level 等原脚本部分机制读取的字段；resident.lua 把 title 补为空串。少室山(大理).lua:422/1436 与 fn缥缈峰.lua:706/709/737/1035 等比较首领 target。nil 比较不会报错，会跳过“首领当前追我”的处理，或走入 target~=自身的相反分支。因此不是所有缺失字段都会“明确报错停止”。需要补真实字段和有效标记，或在使用必需字段时明确停止；正常的“不存在”和“不可读”必须分开。

### F06 / P2：回归仍缺真正 Worker 结束/清理集成与机制阶段断言

tests/task_audit_tests.hpp:61–85 调用 judge 后手工构造 completed 事件并调用 FlowRunner，没有实际运行 Worker 的结束分支。tests/resident_tests.hpp:66–75 允许时限结束时仍 Running/Sleeping 且无错误；场内三神诊断还显式替换拾取函数。它们适合启动诊断，无法覆盖 F01/F02 的后续分支，也不验证 Manager 的停止失败路径。需要新增生产入口的玩家枚举/珍兽、异场景队友、Boss 机制与 Worker/Manager 生命周期回归；保留启动诊断的用途。

## 原有未完成项

- EnumMemberInfo(2) 团队、宵小 meGetXiaoInfo、任务栏物品 EnumRenWuItem、玩家蓝量、出战珍兽完整身份与操作、mePlayerDispelBuff/下坐骑、死亡复活仍有缺口。
- 城市 NPC、坐标、菜单及已核验跨城边资料仍缺。
- 原控件编号标签及参数语义整理仍未完成。
- 新老三环实际入口/路线/机制资料缺口继续按 SANHUAN_HANDOFF 保留；少室山尚待逐阶段实现和结果契约。
- 许多通用原任务尚无任务专属完成回执，结束时依旧未核验；本轮修复解决的是误判，不会自动生成这些完成条件。

## 验证与建议顺序

运行 cmake --build .tools/build/client --parallel 4（无待编译工作）；ctest --test-dir .tools/build/client --output-on-failure：9/9 通过，42.13 秒。

独立复现脚本 artifacts/review-followup-2026-11-01/probe.lua 已运行成功，确认 F01/F02/F03。其中 team-source.lua、player-source.lua 是原文件的逐字副本，仅绕开离线 Lua C 文件接口的中文路径限制；未改运行脚本。探针使用模拟游戏数据，不连接进程。

建议先修 F02 循环、F01 玩家枚举、F03 状态语义、F04 清理异常；同步补 F06。再按少室山机制补 F05 所需的真实对象字段，逐阶段推进，不扩展任务目录数量。
