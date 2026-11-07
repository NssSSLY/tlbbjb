# mtxjb 与天龙助手：REA 静态对照

日期：2026-10-26。目标为 `E:\game\tlbb\mtxjb` 与 `E:\game\tlbb\jb\满天星\天龙助手`。

本轮只做静态读取和分析。未启动第三方 EXE、未加载第三方 DLL、未执行提取的 Lua、未访问真实游戏、未修改业务代码、未生成安装器或 ZIP。账号数据库及配置 / 登录日志的内容没有解析。独立分析器与压缩包目录工具的执行不等于目标执行。

## 结论

**天龙助手可以继续作为原 Lua 规则来源；mtxjb 当前没有找到可提取的任务 Lua。** 两者不能采用相同的“复制脚本就能运行”判断。

天龙助手已确认两层存储：`script/` 下 36 份明文 Lua，`dfz64.dll` 中 318 个完整 Lua 5.4 字节码模块。mtxjb 的“脚本”目录为空，当前 140 个文件没有 `.lua/.luac`，内层原始 RAR 也没有这些后缀；其受保护程序尚未还原出任务脚本，因此不能声称 Lua 确实存放在某个 DLL 内。

目录中的 `lua5.3.0.dll` 只证明存在 Lua 运行库，不能证明 mtxjb 的任务由它执行。这个 DLL 也不在内层 RAR 的二进制成员清单中，其实际来源和使用者尚未确认。

## REA 与补充分析的边界

已使用 REA `inspect_desktop_application`、`inspect_pe_imports`、`inspect_native_exports`，以及 REA CLI `inspect-with-objdump`。MCP 的 objdump 命令缺失，通过本机已有 REA CLI 和项目 MinGW objdump 的绝对路径恢复；只设置子进程环境，没有改全局配置、下载安装反编译器或运行目标。

本机 REA 的 Ghidra 未配置（`GHIDRA_INSTALL_DIR` 缺失），因此没有获得受保护原生代码的函数级伪代码或完整调用图。mtx 主程序的导入 / 导出声明在当前文件布局上触发 REA 结构预算拒绝，两个主 DLL 的资源范围不全部在文件内映射。保留错误记录，不能把“解析被拒绝”写成“不存在导入 / 资源”。

REA 完整证据合并为 `artifacts/rea-static-2026-10-26/combined-rea-evidence.json`，共 17 条完整 Evidence。原字节码解析、二进制字面量扫描和压缩包目录核对使用本地只读解析器，另行标记为补证，没有冒称为 REA 反编译结果。

## mtxjb

### 当前文件与 Lua 位置

- 当前外层 140 个文件，脚本目录 0 项，没有 `.lua/.luac` 文件。
- 所有 7 个 EXE / DLL 的当前 SHA-256 均与旧审计一致。历史日志和角色配置发生变化，因此未把整个目录说成未变。
- `满天星.rar` SHA-256 为 `507211ba0cd306cf1e3540489f1e612d462eac381671945bd94ba03810df2bb9`；内层 RAR 为 `796497978a7c97755a6a35951724fe66a51da6ef5f175a4b6afdead3bc4200df`。本轮重新只读列出内层 171 个文件 / 目录成员，没有 Lua / luac 成员。
- `LlEqIcVsMgE.exe`、`notepad.dll`、`DiagCpl.dll` 的当前原始磁盘字节没有找到 `\x1bLua` 签名；压缩或加密内容不在这个负面结论内。
- `lua5.3.0.dll` 在文件偏移 `0x218e8` 有字节 `1b4c7561000000006572726f7220696e205f5f67`，即运行库内部的 Lua 签名字符串，后面不是 Lua 5.3 版本 / 格式头，不能作为任务块提取。

**Lua 的真实存放位置未解决。** 当前合理候选包括受保护原生模块内部的数据、运行时解码的内容、可选外部脚本机制，或者任务本来就是编译后的原生逻辑。没有静态证据可以选择其中一种作为定论，也没有证据可把它说成从网络下载脚本。

### 运行组件和可确认的调用关系

|组件|静态观察|可以说明什么|
|---|---|---|
|LlEqIcVsMgE.exe|PE32 / x86，UPX0、UPX1 段|主程序有 UPX 风格压缩布局；不能据此恢复其业务调用顺序|
|notepad.dll|PE32 / x86；大量原 `.text/.data/.idata` 段没有原始字节，实际文件数据集中在 `.txt1`；命名导出包含 RunLog|名称是第三方组件，不是 Windows 自带记事本；RunLog 的函数签名 / 业务含义仍未知|
|DiagCpl.dll|PE32 / x86，同样的受保护布局；导出 GetDllData、GetVar、GetAdd1/2/3、GetTimeW 等|存在私有原生接口；名称不足以确定参数和返回结构|
|lua5.3.0.dll|PE32 / x86，146 个 Lua 相关命名导出|可确认 Lua 5.3 C API 运行库存在；不能据它推出业务脚本存在|
|TLibVC.dll / Tudcler.dll|旧审计记录 GetVcode/GetCode 等导出及 UPX / VMP 段，当前文件哈希一致|仅有图像 / 识别接口名称线索；实际用途、调用方和协议未验证|

**已确认的静态边：** notepad.dll 的 PE 导入表指向 DiagCpl.dll 的 `GetDllData`、`GetVar`、`GetAdd1`、`GetAdd2`、`GetAdd3`、`GetTimeW`。导入描述符位于文件偏移 `45912`（`0xb358`）。这是导入关系，不是运行时调用记录。

notepad.dll 与 DiagCpl.dll 的可解析常规导入中还出现窗口 Hook、进程访问、进程内存、资源和文件映射 API。它们证明组件具备这些静态依赖，不能直接证明实际采用的注入方式、线程入口、IPC 格式或具体游戏动作。已解析的常规导入没有把 Lua 运行库连入这条边；动态 GetProcAddress 路径仍未知。

主 EXE 到 RunLog 的调用、两个 DLL 是否在游戏内执行、任务调度循环、Lua 注册表、配置与任务开关绑定方式均未恢复，不能按推测编写兼容 ABI。

### 复用判断

- 坐标点表可以作为数据来源，已有 38 份、1094 点的旧解析，二进制哈希与点表来源应独立核对。地图 / 用途 / 可通行性未验证时不能直接启用路线。
- 角色配置只能借鉴字段结构；大量控件 ID 无标签，不能猜成技能或任务参数。账号数据库与旧凭据不属于脚本复用。
- 现有 DLL 全为 x86，不能直接载入我们的 x64 进程或当前 x64 游戏。即便额外做 x86 宿主，缺失的签名、对象布局、通信协议和游戏版本适配也不会自动补齐。
- 如果以后拿到明文 Lua，先做语法 / 版本检查和宿主依赖清单。Lua 5.3 二进制不能直接交给 Lua 5.4 加载；目前没有一份已恢复的 mtx Lua 可以执行此迁移。

## 天龙助手

### Lua 的真实位置

1. **外置脚本：** `E:\game\tlbb\jb\满天星\天龙助手\script\自定义` 与 `script\数据` 等目录，共 36 份明文 Lua，包含 GBK 与 UTF-8 文件；当前 36 份哈希均与旧审计相符。
2. **内置业务脚本：** `dfz64.dll` 中 318 个完整 Lua 5.4 字节码块。已从当前 DLL 的记录偏移逐块截取，核对提取文件 SHA-256，并严格解析到边界，合计 3610 个函数原型、333842 条指令。
3. **研究产物：** 提取块、反汇编和解析树在 `artifacts/reference-tlzz/bytecode`，解码后的明文副本在 `artifacts/reference-tlzz/decoded`。这些是研究目录，不是原程序的磁盘加载目录。

字节码中 `@..\tlzs\Script64\系统\common_2.lua` 一类名字是编译时的调试来源路径，不能把 Script64 当成当前电脑上的实际脚本文件夹。

模块分类：任务 35、其他 34、副本 32、功能 40、帮庄 15、常用 21、数据 5、日常 16、活动 46、物品 32、系统 42。数量表示资源存在，不表示我们的程序已实现全部功能。

`dfz64.dll` SHA-256 为 `8ea31c24a1d9aec86621480901fbc02a58db97ae7e559414e8005aa644327cf0`。

### 能从原 Lua 确认的调用逻辑

业务 Lua 依赖公共 Lua 与原生宿主。下面是经原函数常量与指令核对的接口契约：

|接口|原规则中可确认的行为|接入我们的程序需要什么|
|---|---|---|
|LoadScript(name)|去掉 `.lua` 后调用原生 CExec|建立同等的模块查找、加载和执行语义；CExec 的原生完整实现尚未知|
|GetLuaValue(code, format, count)|向游戏 Lua 交付代码，结果格式包含 n/s/b|在正确游戏 Lua 上执行，保持类型、返回顺序和编码|
|TalkNpc|拼接 SetAutoRunTargetNPCName 并通过 GetLuaValue 调用|正确 NPC、到达确认、对话状态和等待|
|DialogOptionClicked|调用 meQuestOptionClicked|适配原宿主私有 me* 接口，不能假定游戏默认有此函数|
|QuestFrameOptionClicked_Item|调用 meQuestOptionClicked_Item|同上，还需保持参数、匹配模式和布尔返回语义|
|Player.GetDataInt|拼接 Player:GetData 并按数值读取|保持数据键与无效 / 未知状态，不用猜测值替代|
|Enum2XByName|5 参数 Lua 包装，依赖原生 EnumEnvObj、过滤、血量 / 距离和排序|保持完整对象字段及参数位置；同名单参数方法不等价|
|CallFun、SP_*|跨 Lua / 原生宿主的操作包装|逐项确认签名和行为；未知项应明确报告未适配|

任务常见的开始 / 主流程 / 结束结构及依赖可从字节码还原。**EXE 到 x64 DLL 的实际启动、注入、完整调度与 IPC 路径仍没有函数级证据。** dfz64 的 Hook、内存和共享映射导入不能代替这项证明。

主 EXE 是 x86，dfz64.dll 是 amd64；仅有一个 ordinal 1 导出、地址 `0x180111be0`，没有 GetLuaValue / CExec 等命名 DLL 导出。这些是脚本宿主接口，不能把 dfz64.dll 当成可通过同名 GetProcAddress 使用的通用 SDK。

## 与我们程序的匹配程度

当前源码具有 Lua 5.4 任务 VM，游戏内通过 `GameTextSession` 调用 LuaPlus 的 Lua 5.0 子环境；`GetLuaValue` 在游戏内执行模式下直接调用，不依靠旧文本模式识别全部游戏代码。这种双 VM 结构能承接天龙助手的原 Lua，但不是加载同名函数就天然兼容。

本轮读取时的清单快照为 135 项：25 项明文原规则、104 项重建规则、4 项直接原字节码、2 项其他适配。直接原字节码包含棋局、师徒心连心、幸运快活三、古兰玉兑换宝石。源码在分析期间有并行变化，所以总数只代表 `source-interface-snapshot.json` 的时点与 SHA-256，不作为全量最终能力承诺。

因此，当前程序既有原样迁移，也有重建；不能把清单里的每个 `.lua` 都说成原任务原样运行。原 Lua 5.4 转码保留任务指令和控制流程，私有宿主、配置、对象结构和结果确认仍由我们实现。

|材料|能否直接复用|正确处理方式|
|---|---|---|
|天龙助手明文 Lua|有条件可以|编码与语法规范化，列出依赖与配置键，逐项匹配宿主|
|天龙助手内置 Lua 5.4|有条件可以|保留字节码 / 流程，转码并验证指令和闭包，再适配公共宿主|
|mtxjb 任务 Lua|当前没有可迁移样本|先取得真实脚本或可靠的解包 / 还原结果，不把运行库当任务|
|mtxjb Lua 5.3 DLL / 原生 DLL|不能直接替换当前组件|版本、位数、ABI 和游戏版本均需匹配；不建议用于替换当前执行器|
|两者的路线与配置结构|可作为线索 / 数据|保留来源，验证地图与实际用途，不导入账号信息|

建议继续以 **天龙助手原规则 → 公共 Lua 宿主兼容 → 参数映射 → 完成条件验证** 为主线。批次单位应是“任务 + 全部公共依赖”，不是只复制一个入口文件。下一批每个任务保留以下清单：原规则身份 / 是否重建、ReadConfigText 或 g_config 配置键、CExec / CallFun / GetLuaValue / 对象接口依赖、前置条件、每步回执和完成 / 上限 / 失败条件。

界面可以由配置清单生成，但默认值和选项含义必须来自原规则或文档。只有在公共接口契约覆盖的任务上，才可能做到新增任务主要改 Lua 与参数数据，而无需重写每个任务流程。

## Evidence 索引与尚未解决的问题

|结论|证据|
|---|---|
|mtx 目录观察|ev_680267af3217b2c5b3d4fbd11a064078907cc10d002be1cf275d272796db5cae|
|notepad 导入和 DiagCpl 私有边|ev_d3321c99797ca35fa49bb868833d36180680079d8ca2386db1ec38924ea93a0b|
|DiagCpl 导入|ev_abf97c918162a590fdc5ef61722cf47067d13f82123fe4c6e2271cc29893bf72|
|DiagCpl 导出|ev_ece29e61882f848b1fa7b9d77f590a9c697f657ca97b45cc630ddd00f8a1785b|
|Lua 5.3 运行库导出|ev_ab6407ff5ce069d5bb41881c1a6a0634a3b07d7be920a279f493754f7b7628b9|
|mtx 主程序段布局|ev_3a918ffe17f64a086a86df6512158c42ffdb9a26c61786eec508d2f96aa80231|
|notepad / DiagCpl 段布局|ev_e9dbefcf462ab065a88f569bc4fbaf110f8f50a6a9fa2dd752f077a711222c89 / ev_be6780ffacd62abb9e6671c2e1c456a39903ba8d38916c0ba2f933be89ef73fb|
|天龙助手完整目录|ev_e040c75351018c026ce864e55ad095f003241f04dae7bfbd29b7e5e5882e0568|
|dfz64 导入 / 导出|ev_f63fbe73d8122b467eec96b870949333fed923df7a77bdc1eea720d9286adda3 / ev_5877c8decebc0bd0999c1959262cc849f9727ac9e5eaefa8a470e794fff68e84|
|当前 DLL 的 318 块与调用常量|artifacts/rea-static-2026-10-26/tlzz/lua-static-verification.json（严格本地解析补证）|
|mtx 压缩包与原始字节搜索|artifacts/rea-static-2026-10-26/mtx/file-static-scan.json（本地静态补证）|

尚未解决：mtx 任务是否采用 Lua 及实际承载位置、受保护业务函数体、主程序到两个 DLL 的完整启动链；天龙助手的完整 native CExec / GetLuaValue / 对象枚举实现和 IPC。没有恢复出这些事实前，不做二进制 ABI 调用、不把推测标为已控制游戏，也不宣称全部原任务已兼容。
