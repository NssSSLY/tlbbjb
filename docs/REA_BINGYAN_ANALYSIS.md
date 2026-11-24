# 冰焰 V8（`by.dll`）REA + Ghidra 底层静态分析与本项目架构改进对照

日期：2026-11-25  
工具：REA 6.8.0（`E:\project\rea\.local\rea.cmd`）、Ghidra 12.1.4（`E:\project\rea\.tools\ghidra_12.1.4_PUBLIC`）、MinGW `objdump`  
分析范围：`E:\game\tlbb\jb\冰焰\V8\data\by.dll`（游戏内交互桥接组件）与 `E:\game\tlbb\jb\冰焰\V8\data\*.ini`（明文路线配置）只读静态分析。未运行第三方 EXE/DLL，未读取任何日志或用户配置库，不涉及登录鉴权与网络校验模块。

---

## 1. 为什么不能直接修改冰焰单机运行（合规与架构双重边界）

1. **合规边界**：不能分析、绕过第三方软件的登录验证与网络鉴权层，也不能修改/修补第三方商业可执行文件以脱机运行。
2. **硬性技术边界**：
   - `冰焰V8.exe`（2018-08-18 版）基于 **32 位（PE32 / x86）TC 简单开发工具框架**（RTTI：`CTCExeApp`、`CTCExeDlg`）构建，其配套插件 `by.dll`、`dm.dll`、`bob.dll` 全部为 **32 位 x86 DLL**。
   - 当前官方客户端（`Bin64/Game.exe`，见 `docs/GAME_UPDATE_2026-11-07.md`）已是 **64 位（PE32+ / x86_64）** 进程：Windows 系统层面禁止 32 位 `SetWindowsHookExA` DLL 注入 64 位进程，且 `by.dll` 内硬编码的全部 2018 年 32 位基址与虚表偏移在当前 64 位客户端中均已失效。
   - 因此，正确路径是**将冰焰成熟的“双通道控制模型（原生 C++ 虚表动作 + 无过度限制的主线程 Lua）”与 `data/*.ini` 明文坐标表吸收进我们自己的 64 位 C++/Lua 引擎中**。

---

## 2. `by.dll`（内部名 `Wuyan.dll`）完整底层实现还原

- **文件哈希（SHA-256）**：`b579dcf5baa891f52218df3ecca63d1d3fc2c5eab41902e059389f937aac6cf6`
- **原始 PDB 路径字面量**：`I:\插件\要饭汇编注入插件\Wuyan_BY_180106\Release\Wuyan.pdb`
- **核心类（RTTI）**：`CWuyanApp`、`Cplugin`（COM ProgID `Wuyan.plugin`，内嵌 `MSFT` TypeLib 偏移 `0x186e80`）、`CMgAsmBase` / `CMgDisasmBase`（内置 x86 汇编器）。

### 2.1 `Cplugin` COM 调度表（`AFX_DISPMAP` 文件偏移 `0x155ca8`，ImageBase `0x10000000`）

| DispID | 方法名 | 函数地址 | 参数类型（VT） | 静态确认职责 |
|---:|---|---|---|---|
| 1 | `BindWindow` | `0x10004530` | `(I4 hwnd, I4 mode)` | 提权 `SeDebugPrivilege`，`OpenProcess`，对游戏窗口线程下 `SetWindowsHookExA(WH_CALLWNDPROC, 0x10004230)` 并发送 `0x2937` 子类化游戏 `WndProc`（REA Ghidra Evidence: `ev_e9ad3db33066307c9e8a8e43f8d6d665d52b312c71c603605d2c6e4b217e28f1`） |
| 2 | `AsmClear` | `0x10004850` | `()` | 清空 `[this+0x2c]` 处的机器码缓冲区长度 `[this+0x102c]` |
| 3 | `AsmAdd` | `0x10004970` | `(BSTR sAsm)` | 调用 `CMgAsmBase`（`0x1000b980`）将单条 x86 汇编文本即时编码追加至缓冲区（Evidence: `ev_82c3b1ef5a8b5af8f21d9e5d34506e2059db5f851df9f0325c8f314ccc03f6dd`） |
| 4 | `AsmCall` | `0x10004ac0` | `(I4 mode)` | 末尾补 `0xC3 (ret)`，写入共享内存 `Global\WUYAN_ASM_MAP_%d`，`PostMessageA(hwnd, 0x2938)` 通知游戏主线程执行并等待 `Global\WUYAN_ASM_EVNET_%d`（1000ms），返回 `EAX`（Evidence: `ev_fc4a54be181fe42bc5570ccf2f6843e87839b681b7b7f64c314ccc03f6dd`） |
| 5 | `UnBindWindow` | `0x10004d00` | `()` | 发送 `0x2937 (wParam=0x4321)` 恢复原 `WndProc` 并卸载 `UnhookWindowsHookEx` |
| 6 | `IsBindWindow` | `0x10004e00` | `()` | 查询绑定标志 `[this+0x1030]` |
| 7 | `GetVer` | `0x10004e70` | `()` | 返回插件版本号 |
| 8 | `VirtualAllocEx` | `0x10004ee0` | `(I4 size)` | 在目标游戏进程分配内存 |
| 9 | `VirtualFreeEx` | `0x10004f90` | `(I4 addr)` | 释放目标游戏进程分配的内存 |
| 10 | `ReadData` | `0x10005040` | `(I4 hwnd, I4 addr, I4 len)` | `ReadProcessMemory` 读取游戏进程指定地址数据 |
| 11 | `StartHookCode` | `0x100051b0` | `(BSTR, I4)` | 发送消息触发 `0x10003840`，通过 `Global\WUYAN_HOOK_EVNET` 建立游戏内事件/提示捕获钩子 |
| 20 | `StartHookCode2` | `0x10005460` | `(BSTR, I4)` | 触发 `0x10003a00`（`Global\WUYAN_HOOK_EVNET2` 第二通道钩子） |
| 12 | `InitLuaFunction` | `0x10005630` | `(I4)` | 发送 `SendMessageA(hwnd, 0x293b)` 解析 `LuaPlus.dll` 导出，并调用 `FunCall(5)` 取得当前游戏 `lua_State*` 存入 `[this+0x107c]` |
| 13 | `Dostring` | `0x100057f0` | `(BSTR buff)` | 将 `[lua_State*]` 与 Lua 源码写入 `Global\WUYAN_DOSTRING_EVNET<pid>`，`SendMessageA(hwnd, 0x293c)` 在游戏主线程直接调用 `LuaPlus.dll!lua_dostring` |
| 14 | `GetRet` | `0x10005ad0` | `(BSTR var)` | 将全局变量名写入 `Global\WUYAN_RET_EVNET<pid>`，`SendMessageA(hwnd, 0x293d)` 在主线程调用 `lua_pushstring` + `lua_gettable` + `lua_tostring`/`lua_tonumber` 读回结果 |
| 15 | `Getstr` | `0x10006080` | `(I4)` | 加载/校验基址与偏移表（`[this+0x1084]` 向量），或按格式返回角色/对象结构化字段（`%s|%s|...`） |
| 16 | `FunCall` | `0x10006570` | `(I4 op, BSTR a1, BSTR a2, BSTR a3)` | **核心原生动作分发器（Op 1–11）**：动态拼装 x86 调用序列并通过 `AsmCall` 在游戏主线程直接调引擎 C++ 函数 / 虚表 |
| 17 | `Dllprint` | `0x10007990` | `(BSTR)` | 调试输出辅助 |
| 18 | `SetString` | `0x10007a70` | `(BSTR)` | 向插件传入基址/配置参数表 |
| 19 | `U2G` | `0x10005950` | `(BSTR utf8)` | UTF-8 转 GBK 编码辅助 |

### 2.2 游戏窗口子类化过程（`0x10003ee0`）与 `FunCall(1..11)` 原生动作机制

冰焰并**不是**“所有动作都拼一段 UI Lua 去点界面按钮”，而是采用 **“LuaPlus 读写 UI/任务状态 + `FunCall` 原生 C++ 虚表调用核心世界动作”** 的双通道架构：

1. **主线程消息泵同步（`0x2938`–`0x293e`）**：
   - `0x2938`（`0x10003fe5`）：映射 `Global\WUYAN_ASM_MAP_%d`，在游戏主线程执行 `AsmCall` 机器码并触发完成事件。
   - `0x293a` / `0x293e`（`0x10003840` / `0x10003a00`）：安装游戏内部回调钩子。
   - `0x293b`（`0x10003f4d` -> `0x10003bd0`）：动态获取 `LuaPlus.dll` 的 `lua_dostring`、`lua_gettable`、`lua_pushstring`、`lua_tostring`、`lua_settop`、`lua_tonumber`、`lua_type`。
   - `0x293c`（`0x10003c50`）：主线程直接对游戏 `lua_State*` 执行 `lua_dostring`。
   - `0x293d`（`0x10003d20`）：主线程从游戏 `lua_State*` 全局表读取返回值。

2. **`FunCall(1..11)`（跳转表 `0x10007820`）揭示的原版游戏 C++ 动作调用**：
   - **Op 1（`0x100065d3`）**：`mov ecx,[base]; mov eax,[ecx]; push arg1; call [eax+vslot]` —— 单参数管理器虚表调用（按对象 ID 选中/交互）。
   - **Op 2 / Op 3 / Op 6（`0x10006759` / `0x1000682f` / `0x10006cb2`）**：直接调用引擎内部函数。
   - **Op 4（`0x100068e3`）**：`mov eax,...; mov ecx,[eax+off1]; mov esi,[ecx+off2]; mov edx,[esi]; mov ecx,esi; push a3; push a2; push a1; call [edx+off3]` —— 三参数子系统虚表调用。
   - **Op 5（`0x10006bf1`）**：`mov edx,luaGlobal; mov edx,[edx]; mov edx,[edx]; mov ecx,[edx+0x3C]; call ecx; mov eax,[eax]` —— 直接取游戏主 `lua_State*`。
   - **Op 7 / Op 8（`0x10006d27` / `0x10006fee`）—— 原生技能与地面坐标技能释放**：
     压入 3 个 `0xBF800000`（IEEE-754 `-1.0f` 默认浮点坐标）或目标坐标、`0xFFFFFFFF (-1)`、目标 ID 与技能 ID，`mov ecx, [[mgr+off1]+off2]; call useSkillFn`。完全绕开 UI 快捷栏/背包按钮，一套原生调用同时覆盖**单体技能、自身技能、地面定点阵法/AOE（八阵图/桃花阵/定海神针等）**。
   - **Op 9（`0x1000726f`）**：直接写入寻路目标状态并触发移动。
   - **Op 10（`0x100074a7`）**：`mov ecx,[inputMgr]; mov edx,[ecx]; push 1; push clientObjId; call [edx+0x3C]` —— **按对象 Client ID 直接触发默认交互（对话动态 NPC / 打开机关 / 拾取包裹）**，不依赖 `SetAutoRunTargetNPCName` 名字寻路表。

---

## 3. 本项目当前“远不如冰焰稳定、大量任务跑不通”的 6 个根因与改进清单

对照本项目 `src/resident_bridge.cpp`、`src/resident_vm.cpp`、`include/game_text_session.hpp`、`include/game_snippets.hpp`、`scripts/legacy/compat.lua`、`scripts/legacy/combat.lua` 与 `scripts/legacy/modules/battle_support.lua`：

| 序号 | 当前项目痛点根因 | 冰焰的做法 | 对本项目的具体修改建议 |
|---:|---|---|---|
| 1 | **到处 `assert` / `throw` 导致瞬态波动直接整项报错退出（最致命）**：例如 `objects()` 对象数 `>512` 或遍历 `>12ms` 直接抛异常杀任务；`combat.lua` 切子场景直接报错停止；NPC 对话/任务槽短暂未刷新直接 `error` 终止。 | **容错轮询状态机**：单帧读不到、NPC 还没点开、刚过图数据未就绪只返回 `0/false`，下个 200ms 周期自动重试，只有总阶段超时才判失败。 | 将 `resident_bridge.cpp`（放宽对象树上限至 2048、超时返回空快照而非异常崩溃）、`compat.lua`、`dungeon_api.lua`、`combat.lua` 中的瞬态断言改为**带退避的重试返回状态**。 |
| 2 | **技能释放借用背包格子按钮（`Packet_Space_Line10_Row10_button:DoAction()`）且封禁 16 个核心门派技能**：背包未就绪或界面锁定时失效；八阵图、桃花阵、定海神针、四绝属性群攻、起死回生等全部被 `battle_support.lua` 硬拦截报错。 | **直接调引擎原生 `UseSkill` 接口（`FunCall` Op 7/8）**，支持技能 ID + 目标 ID + `(x,y)` 地面坐标，不碰背包 UI。 | 在 `include/game_layout.hpp` 中像定位 `moveFunction`/`openLootFunction` 一样，从 `CGameInterface` / `CAI_MySelf` 虚表定位 64 位原生 `UseSkill` 函数，在 `resident_bridge.cpp` 暴露 `cast_skill` 原生宿主操作，解除 16 个特殊/地点技能限制。 |
| 3 | **NPC 对话依赖 `SetAutoRunTargetNPCName(name)`**：副本内动态刷出的 NPC 不在自动寻路表里，站在面前调该函数也毫无反应，10 秒后报“未确认 NPC 对话”。 | **到点后从内存对象树查出 NPC `client_id`，直接调 `CGameInterface` 原生交互虚函数（`FunCall` Op 10）**。 | 复用我们已经跑通的 `openLootFunction`（`CGameInterface` 虚表 `+0x110`）！走到坐标后先在 `objects()` 找同名最近 NPC 的 `client_id` 直接原生点击交互，只有跨距离时才用 `AutoRunToTargetEx`。 |
| 4 | **`GameTextSession` 2ms / 5 万指令硬熔断 + `setfenv` 私有环境破坏加密 UI 脚本上下文**：多开掉帧时扫一次背包超过 2ms 就触发 `Game Lua execution budget exceeded` 直接崩任务；`setfenv` 导致部分游戏 `*_Env` 函数拿不到窗口全局上下文。 | 在游戏主线程对主 `lua_State*` 直接执行代码，无 2ms 超短熔断，需要点控件时直接走 CEGUI 或原生调用。 | 将 `game_text_session.hpp` 的单次执行时限从 **2ms / 50,000 指令放宽到 50ms / 500,000 指令**；对游戏 `*_Env` UI 调用避免外层 `setfenv` 污染上下文，按钮优先复用 `cegui::pressButton`。 |
| 5 | **大量通用宿主函数被硬编码拦截或默认开关锁死**：`resident_client.cpp` 把 `使用物品/创建队伍/申请进组/组队跟随` 全部指向 `__cn_unsupported`；`original_generic_host.lua` 遇到珍兽 GUID 或密保检查直接报错；`allow_item`/`allow_spend` 默认关导致吃药/用任务道具直接抛错。 | 常用组队、跟随、任务物品、买药补给全部作为基础原语默认放通。 | 接通 `resident_client.cpp` 里那 7 个 `__cn_unsupported` 中文接口与 `mePetGetHappy`/`EnumMemberInfo(2)`；将任务自身必需的任务道具/副本药与高风险消费拆开，避免正常流程因默认开关直接暴毙。 |
| 6 | **多开缺乏本机协同状态共享，且未利用 `冰焰/V8/data/*.ini` 现成点位**：各窗口只盲读游戏 `DataPool`，进场/跟随/集合慢且容易脱节。 | 本机进程间直接共享队长/队员状态（本机自动组队、同步进场），外置明文 `.ini` 维护路线点位。 | 在 `TLBB.exe`（管理所有已绑定游戏窗口的控台进程）增加轻量本机队伍协同状态表，并可按需导入 `冰焰/V8/data/*.ini` 中已验证的师门、马贼、反贼、宵小、采集、燕子坞、杀星坐标表。 |
