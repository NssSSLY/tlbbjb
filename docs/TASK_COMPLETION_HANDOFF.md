# NPC 任务完成条件与原 Lua 适配 · 0.15.0

日期：2026-10-26。修复古兰玉兑换数量 / 限额不停止、领取师徒心连心重复领取、幸运快活三到达 NPC 后不继续的问题。本轮只编译开发版和运行离线测试，不生成安装器、ZIP 或完整发布目录，不向当前在线游戏发送动作。

## 已确认的原因

1. 固定游戏调用的返回包先传数字槽，再追加文字。游戏 `return 1,text` 实际传到 Lua 时是 `1,0,text`。兼容层过去把第二个返回值当文字，NPC 提示、系统提示、字典等被读成 `0`，脚本无法识别已领取 / 已达上限。
2. 以前三个任务入口是根据反汇编重建的 Lua，并非直接运行原任务。古兰玉重建流程在计数前把物品名改成全角括号，又混用了材料栏基线与道具栏读数，导致比较的范围不一致。
3. 幸运快活三截图记录了 `allow_spend is off`。旧流程到达 NPC 后才遇到权限拒绝；新版在移动前明确检查配置。
4. NPC 到达后重复调用带移动的对话操作，可能再次重设移动。现在采用原公共流程的到达后 `SetAutoRunTargetNPCName`，并确认对话窗口出现。

## 原规则和宿主职责

以下三个 `.lua` 入口加载原 Lua 5.4 任务字节码，并调用 `original_daily_host.lua` 提供兼容宿主。只转码 GBK 字符串到 UTF-8，原指令、数值、分支、闭包布局和任务控制流程逐项核验；没有加载或执行原程序 DLL。

|任务|入口|原指令数|宿主补充条件|
|---|---|---:|---|
|领取师徒心连心|scripts/legacy/original/daily/shitu.lua|86|在正确 NPC 的对话中确认今日参加状态；已提交但未确认则不重复领取|
|幸运快活三|scripts/legacy/original/daily/xingyun.lua|178|移动前检查允许支付；参加前读已参加 / 间隔提示；未确认参加窗口时不重复提交；保留原翻牌和奖励流程|
|古兰玉兑换宝石|scripts/legacy/original/daily/gulanyu.lua|380|兑换前核对持有量；每次提交后确认物品增加或限额；无反馈停止；最终核对目标量 / 今日限额|

原字符串拆分、清单解析和字段查找函数也由原字节码直接导入，文件为 `scripts/legacy/modules/original_daily_functions.lua`。原任务不是完整可编辑明文源码；适配层、参数和已取得明文的 Lua 可以编辑。旧 `rebuilt` 文件保留作历史对照，任务清单不再引用这三个旧入口，也不会自动回退。

## 古兰玉数量定义

任务参数新增 `gulanyu_count_mode`：

- **本次新增数量**：保持原规则的增量含义。例如已有 3 颗，清单 `红宝石|1`，目标为 4 颗，只新增 1 颗。
- **持有目标总数**：清单表示希望最后持有的数量。例如已有 3 颗，设置 1，直接跳过；已有 2 颗，设置 3，只补 1 颗。

统计道具栏与材料栏中的同种一级宝石，兼容 `(1级)` 和 `（1级）` 两种精确名称，不把其他等级算入。原规则的兑换前 / 后比较统一使用同一范围。重复清单项会合并；空清单、未知名称、非整数或非正数会在动作前报错。

单次“兑换成功”只证明一次提交，不证明整批数量已达标。宿主继续核对所需增量，达到目标后原任务才能结束。读取到今日上限即停止本项，队列记录 **已达上限**，不会伪装成数量已完成，也不会因“成功后删除”移除该定时配置。

数量 API 对不可读的容器数、负数 / 非整数物品数量直接报错，不能把未知状态当 0。提交一次后最长等待 8 秒：没有物品增量、也没有限额反馈，任务失败且不重复兑换。师徒和幸运任务同样限制未确认提交的重试。

## 统一完成机制与覆盖边界

`scripts/legacy/task_lifecycle.lua` 提供 `check → run → verify → report`。明文模块可返回如下接口：

```lua
return {
    check = function(config)
        -- 必须读取本任务的真实条件；已有结果返回 already_done / limit_reached。
        -- 尚需执行返回 ready；不可读状态返回 unknown 并说明原因。
    end,
    run = function(config)
        -- 原任务或任务动作。
    end,
    verify = function(config)
        -- 根据任务真实状态返回 done / already_done / limit_reached。
        -- 没有确认结果不能返回成功。
    end,
}
```

原字节码不改任务主体，通过外部宿主适配同样的条件检查和最终回执。`task_result` 经原有共享内存日志通道传回 Worker，不增加一套 IPC，也不改变 native Packet ABI。消息有长度限制；损坏、重复、非终态回执拒绝认定完成。声明 `validation_contract` 的任务没有有效回执，Worker 报错，不发成功事件；失败策略沿用任务参数，默认停止队列。

当前 119 个原脚本清单条目中，本批仅以上 3 个接入严格日常完成契约。现有签到、坐标移动、战斗另有各自的检查，但其余原任务尚未完成逐项的前置 / 后置条件审计；不能声称全量任务已核验，不能以脚本返回代替真实任务达成。后续需逐任务补齐数据来源、已完成 / 限额、材料条件、动作确认和队列结果。

## 构建和验证

开发输出移到 `.tools/build/client-0.15.0`，避免覆盖当前游戏占用的旧引擎。本地运行依赖 Qt 开发环境；自行生成安装器才会收集独立运行库。修改引擎后实测应重新启动对应游戏，用新版启动器重新绑定；本轮未关闭现有游戏。

```powershell
Set-Location E:\game\tlbb\jb
. .\tools\env.ps1
cmake --build .tools\build\client-0.15.0 --parallel 3
ctest --test-dir .tools\build\client-0.15.0 --output-on-failure
```

原规则核验：`tools/verify-daily-rules.py`。SDK 场景证据位于 `artifacts/npc-lua-compat-0.15.0/daily-task-cases.json`，总报告为同目录 `verification.json`；界面验证为 `artifacts/universal-runtime-0.15.0/native-ui/verification.json`。所有 Game Lua 调用均在本程序自建 LuaPlus 状态中执行，未访问实际游戏进程。

自行生成安装器：

```powershell
Set-Location E:\game\tlbb\jb
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-installer.ps1
```

预期输出 `dist/packages/TLBBClient-0.15.0-Setup.exe`，默认不生成 ZIP。此构建链已更新版本、路径、原规则校验和收集逻辑，但本轮未执行安装器构建或安装，不能将离线测试结果称为实机修复验收。

最终验证：5 个 CTest 目标全部通过，核心 46 组、原 Lua 日常 SDK 场景 20 个、SDK 固定调用 159 项、战斗专项 42 项、自建窗口界面 27 项。187 项集中资源全部核对源文件；单文件覆盖和损坏资源拒绝加载通过。实机、全部任务条件审计和安装器构建仍未完成。
