# TLBB 本机只读检查结果

检查日期：2026-10-23，Asia/Shanghai。

历史记录说明：本文件描述 0.1 的只读检查。2026-10-24 的 0.2 已完成真实位置与原生移动验证，用户确认角色实际移动；最新进度见 [PROGRESS.md](PROGRESS.md)，不能继续将下文当作当前能力结论。

## 结论

C++ 能实现进程管理、内存读取、原生适配与 Lua 任务客户端，不需要因为旧客户端使用易语言而继续采用易语言。旧工具的有效能力来自其游戏适配实现，无法仅凭实现语言或外观推定。

本机已验证：正在运行的游戏进程可识别、模块可枚举、基础进程内存可读取。尚未验证角色状态结构、游戏内语义动作、后台任务执行、Home 会话绑定和多开执行。因此结论是“具备继续构建适配器的基础”，不是“已能控制角色”。

本次未编译 C++ 客户端；使用 PowerShell/.NET 和只读 Windows API 做诊断，没有修改游戏程序、注入组件、调用游戏内部函数或执行角色动作。

## 现场证据

主证据：[artifacts/tlbb-readonly-inspection.json](artifacts/tlbb-readonly-inspection.json)。

| 检查项 | 实际结果 | 解释 |
| --- | --- | --- |
| 当前游戏进程 | PID 17944，`E:\game\tlbb\Bin64\Game.exe` | PID 仅对应本次采样，重启后会变化 |
| 当前游戏架构 | x64，PE32+ | 当前原生适配以 64 位为目标 |
| 游戏文件版本资源 | `0, 85, 0, 0` | 是文件版本资源，不当作完整运营版本或补丁号 |
| 同时存在的另一版本 | `Bin\Game.exe` 为 x86 | 旧版 32 位组件不能直接当作当前 64 位进程内组件使用 |
| 启动器 | `Launch.exe` 为 x86，文件版本 `1.0.30.20` | 安装配置需区分启动器和实际游戏进程 |
| 模块枚举 | 成功，采样时 143 个模块 | 包含游戏目录中的 LuaPlus、tEngine、PathLib、UI_CEGUI 等 |
| 只读进程打开 | OpenProcess 成功，错误码 0 | 请求 VM_READ 与 QUERY_LIMITED_INFORMATION，没有申请写入或执行权限 |
| 真实内存读取 | ReadProcessMemory 成功，64 字节，错误码 0 | 只读取主模块 DOS 头；前两字节为 `4D-5A`，即 MZ |
| 角色数据读取 | 未验证 | 不从 DOS 头可读推导为血量、坐标、目标等已经可用 |
| 角色动作 | 未测试 | 未释放技能、移动或交互 NPC |
| 游戏文件完整性 | 检查的 8 个文件在各自静态检查前后 SHA256 相同 | 仅覆盖报告中这 8 个文件，不代表对整个安装目录做了完整基线审计 |

## Lua 与导出接口

1. 当前进程确实加载 `Bin64\LuaPlus.dll`，该文件包含 `Lua 5.0.1` 和对应版权标识；这是文件内版本字符串证据，没有对运行中的 VM 对象做版本/状态解析。
2. `Game.exe` 静态导入 LuaPlus 与 tEngine，UI_CEGUI 也导入这两个库，说明客户端具有脚本/引擎集成基础。
3. Game.exe 的 4 个具名导出主要是显卡选择标记和线程包装，没有观察到直接向外提供角色动作的具名导出。
4. LuaPlus 有 497 个具名导出，以 Lua/LuaPlus 运行时接口为主；它们不等同于可以让外部进程控制现有角色的公共接口。
5. tEngine 有 416 个具名导出，其中有 ScriptSystem、GameInterfaceBase 等类型名称；这些只是检查线索，不证明其对象实例、可用方法或线程条件已经确定。
6. PathLib 有 PathFinder 等类型相关导出，但未取得可用的寻路对象或地图数据，也没有调用这些函数。
7. 按头文件、导入库、Lua、SDK、README 等文件名模式扫描松散文件，未发现可直接接入的开发包候选。大量内容使用 AXP 资源包；本次没有解包，不能声称其中没有脚本或接口线索。

设计修正：外部任务引擎仍可以使用自己的 Lua 5.4，但必须与游戏内的 LuaPlus 上下文隔离。若后续适配经过游戏脚本系统，应匹配目标 LuaPlus/ABI，并通过明确的数据或命令边界桥接；不能把两者的 lua_State、库或对象直接混用。

## 窗口检查的环境限制

诊断进程与游戏同属 Windows Session 19，但诊断位于 `CodexSandboxDesktop-...` 隔离桌面。EnumWindows 没有成功取得目标桌面的窗口列表，返回 false、附加错误码 0；部分游戏线程桌面查询返回不可用，其中有访问拒绝码 5。

因此，没有观察到游戏主窗口不能用于判断游戏没有窗口，也不能判断产品的 Home 热键不可行。本次没有切换桌面、改变权限或尝试绕开隔离。Home/窗口映射应由后续客户端在正常用户交互桌面验证。

## 对实际开发的影响

推荐形成三部分，均可由 C++ 工程承担：

```text
统一 EXE：进程发现、启动、会话配置、Home、托盘
    -> 独立 Lua 任务运行时：规则、任务阶段、人工干预后的重规划
    -> x64 游戏适配：状态快照 + 游戏语义动作 + 结果确认
```

- 不要求购买或依赖另一种开发语言的工具；是否使用调试分析工具属于研发手段，不等于产品运行必须依赖它们。
- 目前缺少的是目标游戏的适配实现，而不是 C++ 对 Windows 进程功能的支持。
- 下一项技术验证应确定最少量角色字段的可靠来源，并证明它们随实际游戏状态变化；不能仅以“读到某个整数”作为成功。
- 动作验证需要明确语义动作路径、对象、线程约束与反馈。在这些条件未确认前，不调用未知接口，不用客户端本地字段改变冒充服务器认可的效果。
- 一个真实动作闭环成功后，再扩展多角色与具体 Lua 任务。当前不把接口名称或资源文件当作控制能力完成的证据。

## 可复现检查

脚本：[tools/Inspect-Tlbb.ps1](tools/Inspect-Tlbb.ps1)。在当前工作区运行该脚本会重新采样当前已运行的 Game.exe，并覆盖本地诊断 JSON。它不启动游戏、不读取账号目录内容，也不执行角色动作。

API 依据：

- [ReadProcessMemory](https://learn.microsoft.com/en-us/windows/win32/api/memoryapi/nf-memoryapi-readprocessmemory)
- [Enumerating All Modules For a Process](https://learn.microsoft.com/en-us/windows/win32/psapi/enumerating-all-modules-for-a-process)
- [EnumWindows](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-enumwindows)
