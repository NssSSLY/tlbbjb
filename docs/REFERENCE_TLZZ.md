# 天龙助手静态分析与迁移

2026-10-25，项目版本 0.5.4。输入目录 `E:\game\tlbb\jb\满天星\天龙助手`。

已建立 250 个文件、108,969,551 字节的哈希清单。源码、文档、PE 和字节码全部静态读取；第三方 EXE、DLL、批处理、更新器和字节码执行数为 0，输入目录保持原样。外层账号密码文件没有读取。

| 输入 | 分析结果 | 本项目处理 |
| --- | --- | --- |
| script/ | 36 份明文 Lua，主要为 GBK，部分 UTF-8 | 解码副本保存在 artifacts/reference-tlzz/decoded/；识别等待、组队、签到、仓库、兑换、扫荡示例及数据表 |
| dfz64.dll | x64；318 个完整 Lua 5.4 字节码块，全部通过边界和格式检查 | 静态提取函数树、指令、常量、局部变量及依赖索引，位于 artifacts/reference-tlzz/bytecode/ |
| dfz32.dll | x86，存在 .themida 等保护段 | 保存 PE 段和哈希证据，未加载 |
| 天龙助手.exe / JT.exe / sc.exe | x86，部分段名经过处理 | 保存 PE 元数据，没有假定存在可直接调用的公开 ABI |
| data/zydd.dll | x86，导出 LoadAXP/SaveAXP/ReplaceFile/FreeAXP | 记录导出，未加载，不改游戏 AXP |
| data/坐标/*.txt | 29 份坐标表 | 逐行解析到独立参考库，保留来源、编码、SHA256 和原始行号 |
| data/模版/*.json | 43 个地点模板，含 sceneName/sceneID/x/y/r | 地图名、场景 ID、半径仅作为线索；不据此启用自动寻路或战斗 |
| 接口文档.pdf | 70 页接口说明 | 提取至 artifacts/reference-tlzz/interface-document.txt，供逐项核对 |
| 更新包/ | 包含同版程序、脚本和数据副本 | 按哈希记录重复，未重复导入 |

字节码产物为原始 luac、指令清单和静态函数树 JSON。未生成宣称与原程序等价的完整 Lua 源码。统计为任务 35、其他 34、副本 32、功能 40、帮庄 15、常用 21、数据 5、日常 16、活动 46、物品 32、系统 42，共 318 个模块。

## 已完成的迁移

- `scripts/utility/wait_until.lua`：将原 WaitForTime 示例改写为本引擎的 step 接口，进入“所有功能 → 工具 → 等待到指定时间”。支持指定本地 HH:mm 和等待秒数；当前时刻已过则等待下一日。暂停时不累计等待时长，指定时刻仍依本地日历；恢复后重新核对。可加入顺序/定时列表，并随停止、解绑和游戏退出清理。
- Worker 每 500 ms 检查一次等待条件，复用既有定时器；独立校验完成条件，等待脚本只能返回 wait/complete/error，游戏动作数为 0。Lua 仍受原有内存、指令、输出和 Job 限制。支持兼容 Lua 重载。
- `scripts/data/tlzz_reference_routes.json`：72 份参考，共 912 点；加入刷怪、采集、挖图、马贼配置页的路线下拉框，以“天龙助手 ·”区分。原满天星 38 份 1,094 点保持原样，合计 110 份、2,006 点。
- 所有新点表均保持 verified=false、runtime_enabled=false、map=null。来源场景 ID 保存在 scene_id_hint，半径保存在 radius_hint；运行时不会将这些线索当作已验证事实，也不会访问第三方目录。

## 0.7.0 已迁移的原规则

common_2/bag/fn兼容接口 模块的函数逐个反汇编后，确认移动、NPC、对话等公共接口最终落到游戏自身注册的 Lua 函数（AutoRunToTargetEx、SetAutoRunTargetNPCName、QuestFrame*、DataPool、PlayerPackage、Player:GetData、CloseAllWindow、PushEvent、GetDictionaryString）。原程序额外注入的 me* 辅助函数（如 meQuestOptionClicked）不在任何 Lua 字节码中，本程序按 Game.exe 静态反汇编得到的参数语义重新实现。

16 个任务已接入（详见 design/SCRIPT_ADAPTATION_BATCHES.md）：6 个原文件逐字节保留，10 个由字节码还原。0.8.0 继续迁移了仓库/锦囊（bag 模块）与扫荡副本（functions 模块 SDFB_OnStart 及 SD_* 局部函数），新增 14 个原文件任务。注意：tools/inspect-lua54-chunks.py 把整数常量（tag 3）按 double 解码、浮点（tag 19）按整数解码，JSON 中的极小浮点实为整数，需按位重解释。合成宝石（MainHCGem）、商会存取、自动组队等仍未列入。

## 需要后续适配的模块

副本、刷怪、采集、师门、NPC、仓库、交易和物品操作依赖原宿主提供的 Player/Bag/Pet/Skill、GetLuaValue、MoveTo、CUseSkillByID、CallFun、SDFB_OnStart 等接口。本项目尚无对应的已验证动作与结果读取。当前保存模块依赖索引，按目标读取、移动、NPC 对话、技能、背包和结果确认逐项迁移。原私有接口不按同名函数直接接入。

部分示例包含销毁物品、金币和物品转移；没有直接启用这些操作。当前可执行新增任务为等待；新增坐标用于配置和预览。

## 昵称编码修正

CEGUI String32::c_str 的本地反汇编显示，它按 Unicode 码点计算 1/2/3/4 字节的 UTF-8 输出；旧 Ui::read 错用 CP936。0.5.4 改为严格 UTF-8，拒绝无效字节和容量不足，保证终止符。区服和地图的原生 std::string 继续按 GBK 读取。

旧昵称缓存缺少编码标记，升级先备份整个 launcher.json 到 data/migrations/，仅清除旧昵称缓存，保留账号、凭据引用、区服、槽位和角色任务文件。新缓存标记 cegui-utf8-v1。不能逆推的旧文本不做猜测，之后进入选角界面会重新读取。

本轮未重复认证在线账号。只读修复工具检查时原实测游戏已退出，因此真实角色昵称的再次读取待后续验证。UTF-8 中文、补充平面字符、坏字节、容量不足以及缓存迁移已通过回归；0.5.2 的完整登录证据独立保留。

## 可重跑入口

1. `tools/audit-tianlong-assistant.py`：目录、PE、明文 Lua 和 PDF。
2. `tools/inspect-lua54-chunks.py`：严格、有限的 Lua 5.4 静态解析与反汇编，不调用 Lua 执行器。
3. `tools/import-tlzz-data.py`：依据审计哈希转换 29 份点表与 43 个地点模板。
4. `artifacts/reference-tlzz/module-dependencies.json`：318 个模块的全局依赖索引。
5. `tools/verify-role-encoding.py`：仅针对此前已验证的同一游戏会话查询昵称；缺少该会话时不重新登录。

软件包包含本引擎改写的 Lua 任务及参考 JSON。第三方二进制、提取的字节码、原始程序配置、账号、文档解码副本与研究产物不进入安装包。
