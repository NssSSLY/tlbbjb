# 两套脚本程序的函数级静态实现分析

日期：2026-10-26。工具：REA 6.8.0，Ghidra 12.1.4。范围：`E:\game\tlbb\mtxjb` 与 `E:\game\tlbb\jb\满天星\天龙助手`。

本报告承接 `REA_STATIC_COMPARISON_2026-10-26.md`。此前“Ghidra 未配置”的限制是历史状态；本轮已经实际调用 Ghidra 反编译。仅静态分析：没有运行第三方 EXE、加载其 DLL、执行 Lua、向游戏或网络发送动作，也没有读取账号数据库或登录日志。没有修改本项目业务代码或生成安装器、压缩包。

## 1. 本轮结果和覆盖边界

**天龙助手已恢复主要脚本宿主链；mtxjb 仅恢复保护入口的可见路径，尚不能恢复其任务引擎。**

| 对象 | 本轮实际完成 | 仍未确认 |
|---|---|---|
| 天龙助手 `dfz64.dll` | 70 个选定函数的完整 REA dossier、伪代码、汇编、引用和直接调用；DLL 初始化、Lua 注册、模块容器、CExec、游戏 Lua 桥、对象枚举、技能接口及部分配置/调度路径 | GUI 启动器如何把 DLL 装入游戏；所有偏移的运行时有效性；全部任务达成条件及完整多开协议 |
| mtxjb 主 EXE / notepad / DiagCpl | 4 个有效入口函数 dossier；主入口字节与映射；7 个业务导出逐一确认无文件支持 | 原业务函数体、导出签名、实际 Lua 加载者、任务 Lua 存放位置 |

70 不是“全部业务函数数量”。Ghidra 在 `dfz64.dll` 共观察到 4610 个 procedure，其中包括运行库代码；本轮按问题选择函数，没有全量反编译。MTX 的 7 个失败导出也不计入有效函数数量。所有静态地址均为样本 preferred ImageBase 下的分析坐标，不能直接当作游戏当前运行地址。

## 2. 天龙助手：真正的 DLL 入口与运行环境

样本：`dfz64.dll`，x64，5,858,304 字节，SHA-256：`8ea31c24a1d9aec86621480901fbc02a58db97ae7e559414e8005aa644327cf0`。

### 2.1 唯一导出不是脚本入口

Ordinal 1 对应 `0x180111be0`，汇编仅两条指令，伪代码为 `return param_1 * 4;`。它不是根据名称猜出的 Hook 或业务入口。Evidence：`ev_d4b2fea7aedcbf920a5010789071a3a3b8b988c3d5d6acb9dd1a17770b93f34e`，伪代码投影 `ev_ebc8f56be0acc6582eb3d8aed3a5c14678503dc0b8831c3e33fa7d8f1ec0f765`。

### 2.2 DLL 初始化路径

```text
PE entry 0x18016d464
  → dllmain_dispatch 0x18016d330
    → 自定义 DllMain 0x1801132e0
      → DLL_PROCESS_ATTACH 时设置运行标志并 CreateThread(0x18010a000)
        → thunk(0x1801093d0)
          → 确认游戏窗口、等待 UI_CEGUI.dll / CEGUIBase.dll
          → 在游戏窗口线程安装窗口消息 Hook 和键盘 Hook
          → 解析 LuaPlus.dll 的 Lua C API
          → 初始化模块容器、偏移和后续工作
```

实际线程函数 `0x18010a000` 在主流程返回后调用 `0x18010a020` 清理，再 `FreeLibraryAndExitThread`。`0x18010a020` 中确认有 `UnhookWindowsHookEx` 调用；本轮没有证明它涵盖所有资源路径。

`0x1801093d0` 对 `GetWindowThreadProcessId` 的结果调用 `SetWindowsHookExW(4, 0x18010ae00, NULL, threadId)` 及 `SetWindowsHookExW(2, 0x18010a070, NULL, threadId)`，分别对应 WH_CALLWNDPROC 和 WH_KEYBOARD。这证明 DLL 内部的线程消息组织方式，**不证明 GUI 启动器最初采用哪种注入或装载手段**。该上游路径未展开。

主要 Evidence：入口 `ev_5f2ec3f791a7a62db5deea1f6c2b9692f9346141bb7b2afef2719fd5755985b9`；dispatch `ev_48a73de827e80c8947b47765bac8f1af21017ae740b7d317141e9994a5c0eba8`；DllMain `ev_6cd50904a3067e26dd29b3735b7a8db4a3e29d1086b0ce229851b21252d3bfe6`；线程 `ev_79db0c0f12d3f7fd822b3fca6d6903eb396b163795e86e441fcedb0ea3e12c1a`；初始化 `ev_9260baecd46c7f2fd049651ea84e83e50ac5c580684393a96bf60129a703ec2e`。

## 3. 两套 Lua 环境及其连接方式

### 3.1 脚本宿主 Lua

`0x1801282b0` 创建自己的 Lua state，打开标准库，并把 C 回调注册为 Lua 全局函数。注册顺序和回调地址可以在汇编中逐项对应，不依赖猜测名称。

| Lua 名称 | 回调地址 | 本轮确认到的作用 |
|---|---|---|
| CExec | `0x180128070` | 读取模块名，进入 `0x18012b3b0` 装载并调用脚本 |
| GetLuaValue | `0x180127310` | 接受游戏 Lua 代码和返回格式，交给窗口线程并把结果压回宿主栈 |
| CSleep | `0x1801292b0` | 获取毫秒参数，调用 Windows Sleep；特定线程下另设两个标志 |
| GetUserConfig | `0x180127820` | 返回配置字符串；另处理 AUTOLOGIN / CONFIG_PATH / CLIENT_TYPE |
| CGetFieldConfig | `0x180127220` | 当前磁盘函数读取两个参数后返回空字符串；未见真实字段查询 |
| CSetFieldConfig | `0x1801291a0` | 当前磁盘函数只读取三个参数并返回 0；未见写回实现 |
| GetTickCount | `0x180127ec0` | 注册关系确认，函数体未在本轮展开 |
| MessageBox2 | `0x180128180` | 注册关系确认，函数体未在本轮展开 |
| Crc32 | `0x180124ef0` | 注册关系确认，函数体未在本轮展开 |
| DoSystem | `0x180124f40` | 操作码分发；包含脚本运行标志、配置文件读写、窗口/消息操作 |
| GetPlayerState | `0x180127da0` | 调用直接读游戏状态的辅助函数并返回整数 |
| CGetSceneIDByName | `0x180127dd0` | 注册关系确认，函数体未在本轮展开 |
| EnumEnvObj | `0x180126c10` | 枚举游戏对象，转换为 Lua table |
| EnumMemberInfo | `0x180126d00` | 注册关系确认，函数体未在本轮展开 |
| CallFun | `0x180124b10` | 按操作码调用原生辅助函数或发送特定窗口消息 |
| Get_XParam_INT | `0x180127ef0` | 注册关系确认，函数体未在本轮展开 |

注册函数：`ev_1711f46d291f7b586f5edf207e106376fa60827a9e227f3b5e6e4b740d14e43e`。标准库表包含 `_G/package/coroutine/table/io/os/string/math/utf8/debug`，由 `0x1801522c0` 逐项打开。不能把它说成只开放少量宿主函数的受限 Lua。

`0x180128500` 与 `0x1801281c0` 为主任务环境继续注册 baglib、skilllib、对象 Buff 等接口。其他工作线程会调用基础注册函数，创建自己的 Lua state。已看到至少主任务、队伍检查、辅助任务这几条路径，不能把“游戏内一个 DLL”理解为“只有一个 Lua state 或一个执行线程”。

### 3.2 GetLuaValue 的实际链

```text
宿主 Lua: GetLuaValue(code, format, ...)
  → 0x180127310（读取 code 与 format）
  → 0x180119580（组织请求及结果容器）
  → SendMessageA(gameHwnd, 0xb44, request, result)
  → WH_CALLWNDPROC 回调 0x18010ae00 的 0xb44 分支
  → 0x1801193c0
  → 0x180119650
  → LuaPlus.dll: luaL_loadbuffer(gameState, code, length, chunkName)
  → LuaPlus.dll: lua_pcall(gameState, 0, resultCount, 0)
  → lua_tostring 取回字符串结果
  → 0x180127310 按 n/s/b/l 格式分支，压入宿主 Lua 栈
```

`0x180119e20` 通过 `GetModuleHandleW("LuaPlus.dll")`、`GetProcAddress` 获得 `luaL_loadbuffer`、`lua_pcall`、`lua_tostring` 等函数指针。它连接的是另一套游戏 Lua 环境，并不是把所有任务字节码直接丢给游戏自己的 Lua VM。

本样本 `GetLuaValue` 回调从第二个字符串的长度确定结果数量，并按其每个字符分支；没有观察到它读取第三个 Lua 参数。适配时不能仅按函数同名或旧文档参数个数实现。外层结果不足时存在默认值分支，因此空值/读取失败与“任务已经完成”更不能混用。

核心 Evidence：`GetLuaValue` `ev_03a5589792b49426f676b8e1e5413df47eb226d6089d07200d7e76711519fa9a`；发送 `ev_fe3fba977ae8504a66f269d03e746d5f6e471e5c30baba46a3b59a4ca77616e2`；接收分发 `ev_6aff1c1dbe305c2de42a7f8b88de40c6eda47d6b08e8346e76873205b48a0fc9`；接收适配 `ev_a959f70411af0d9234bea9379a2891a75ca1c97bbf3281dbd712ba10df511b5a`；游戏 Lua 调用 `ev_7d707c846f29eec37f613ca9622380f5ab85a9a35c6e121a6abef2dac734a349`；API 解析 `ev_07898c5e832fd3de8bc2b9021b093fe20ae83ac548b6f940d507e40a1d249d82`。

**效率判断应据此修正：** 目标程序同样存在跨线程消息往返和字符串结果转换。减少不必要 IPC、重复查询和外部编排可能有帮助，但仅凭“任务在 DLL 中”不能断言每个调用没有开销。该链明确使用同步 SendMessageA，本轮未见在这次调用外包 SendMessageTimeout，因此也不能声称目标每步都有超时保障。没有运行时性能测试。

## 4. 原 Lua 在哪里，CExec 怎样加载

### 4.1 不只是搜索到 Lua 签名：已确认容器装载函数

`0x180123f90` 从 `0x18023e330` 复制 `0x332dfa` 字节到临时缓冲区。随后每条记录读取四个 little-endian u32：名称字节长度、分类字节长度、载荷字节长度、第四字段；再分别复制名称、分类和载荷，放入带锁的模块容器。

依据该函数做只读 PE 字节复核：

- 容器原文件偏移：`0x23d130`，大小 3,354,106 字节。
- 严格顺序解析 319 条，恰好消耗全部容器字节，无剩余。
- 318 条以完整 Lua 5.4 头开始，与前次 318 个字节码模块结论一致。
- 另有一条名称 `game`、分类“系统”的记录，载荷 66,768 字节，开头不是 Lua 头；格式未确认，不能当作第 319 份可执行 Lua，也不能擅称它是加密脚本。
- 319 条第四字段均为 0；未推断其未使用情况下的语义。

容器解析函数 Evidence：`ev_09e457ea950522a0b073d0053fa9f323c6f64a4764ddc8a16668a11d54a16f3a`；头部静态字节由 REA `read_bytes` 保留。完整模块名、分类、偏移、大小、SHA-256 在 `tlzz/container-and-registration-tables.json`。解析器是本地只读补证，不冒称为 Ghidra 原生模块清单。

### 4.2 模块加载优先级

`CExec → 0x18012b3b0` 有以下静态分支：

1. 常规模式先由 `0x18012edd0` 按模块名称精确匹配内置容器；有载荷则进入缓冲区装载，并 protected call 执行。
2. 内置模块未命中时，`0x180103420 → 0x1800edd80 → 0x180137f70` 查找外部 `.lua` 文件；可见路径为程序根目录下 `Script/自定义`。
3. 另一模式标志分支查找根目录 `Script64` 下的 `.lua`，走文件装载；`DoSystem` 的操作码 1 能修改这个标志。本轮没有把它进一步命名为确定的用户界面选项。
4. 脚本装载或调用失败时，读取 Lua 栈错误字符串并进入日志/提示路径；`CExec` 返回值由宿主 Lua 栈数量/错误分支决定，不是统一的“任务成功”布尔值。

原样复制到外部目录未必覆盖同名内置模块。模块名、搜索路径、模式及环境依赖必须同时匹配。`Script64` 的调试源路径也不代表用户当前目录已经存在这些源码。

主要 Evidence：`CExec` `ev_44509cb7a5a1b1c0b9cabed1467635ecac1b75ca22e4bcfa8a9e8e39298a3bb3`；装载器 `ev_a40e003fadd845bfbe140d282ef8c5b9ae1d7287e2283b42e79e4a177257f299`；内置查找 `ev_38855caaa255944eb5eac9240780f6ecb6df5a50befab775c8a22df2c918b80d`；路径查找 `ev_f3dd17538e8762928fa52cabe3f24cece96c8b61dbc7daa4411fa7c78b6b9dad`；路径构造 `ev_326e4dbfdc1f4d4b7e1352206085ec2d50d261d91fb41c3ebe55f89867e9a6ef`；递归文件枚举 `ev_5692d0ba44d5ed892e4d401967bca4fec26bc1c6c3374be97b5fe8a5e01af93d`。

## 5. 对象枚举：确实直接访问对象结构

`EnumEnvObj 0x180126c10 → 0x180130480 → 0x1801305b0 → 0x180133810`。

- 先从全局基址/偏移获得对象管理结构，遍历树节点；循环计数有静态上界检查，而不是全进程盲扫。
- `0x180133810` 根据类名分支，已见 CObject_PlayerNPC、CObject_PlayerMySelf、CObject_PlayerOther、CObject_PlayerInfant、CTripperObject_ItemBox、CTripperObject_Resource、CObject_PlayerSummoner 等。
- 原生结果记录步长为 `0xf8`；`0x180128890` 将其转换为 Lua table，字段可确认包括 baseptr、dataptr、state、target、model、level、menpai、attackType、owner、petzrid、guid2、inteam、leader、title、class、bhname 等。坐标等短字段名也留在原始字符串/字节证据中。
- `0x180133730` 等辅助函数直接沿对象/数据指针读取状态；`0x1801333a0` 对不同 CLIENT_TYPE 初始化一组偏移。这表明结构依赖具体客户端版本，并非跨版本通用接口。

不能说它只是读取界面系统提示，也不能把它的对象表简单替换为只含名字和坐标的列表。原 Lua 对 class、对象身份、状态、目标及距离的依赖必须逐项保持一致。

Evidence：`ev_a36214e45fb999f5abc84e5e7677f466c72f5a8d746100aa7bb96b90d4cbe296`、`ev_36b392b2f48003d4e28964263839b5e85b47b85e8ca59d4914ccbb7f1029fd93`、`ev_16791020dab794ca0b9d8a6ee10ba6fa3edecf514d496eccc0686cf6d6c53735`、`ev_7df90e7236afb50df55fab562ea79de49674d507e42d2e0a7054aafd4301376c`、`ev_ce3492f54f80f7dc06664e476e17b400aea0a73a0581dff47c0bede3bf7e77e8`、`ev_c5cc418e81fb40d45d79f63d17564a85476f79bc508c2bcc688e2efb7d8753a5`、`ev_31c54c51d49a926bc5879fc5dd5f3137d3eacab9de0831e856becc7f5e3b12da`。

## 6. 技能与战斗底层不是只有 GetLuaValue

`0x18012e8d0` 为 skilllib 注册 5 个函数，表位于 `0x1805712e0`：

| Lua 接口 | 回调 | 已追踪的下一层 |
|---|---|---|
| CUseSkillByID | `0x18011ea90` | `0x180131b70` 写入由游戏指针取得的动作结构 |
| CUseSkillByID2 | `0x18011eb20` | `0x1801345e0` 进入套接字发送路径 |
| CUseSkillByID_fb | `0x18011ebd0` | `0x180131c70` 用同步窗口消息把动作结构交给窗口线程 |
| CEnumSkill | `0x18011ec80` | `0x1801306f0` 从角色关联结构枚举技能并生成 Lua table |
| CGetCD | `0x18011f020` | `0x180133050` 从技能冷却相关内存表取得返回数值 |

因此不能把三个“技能 ID”接口当作可互换的同一函数，参数和执行路径需要分别适配。本轮没有向游戏发送技能或套接字数据，也没有验证这些历史偏移/协议在当前游戏版本可用。

技能表可见字段包括 cdidx、consume、consume_type、baseskl、attack、kongzhi、diandi、jiasu、shunyi、buff_check、buff_need、fdist。playerlib 另外注册 CGetPos、CGetTID、CGetGUID、CGetBangMengID、CGetTargetID、CGetFightPetGUID。这个结果可以支撑后续宿主接口清单，**不是已经恢复所有门派技能、宠物技能和血量维护规则**；具体优先级、治疗条件及副本策略仍在各 Lua 模块中。

主要 Evidence：skilllib 注册 `ev_08bc4db20d288d0507bd506cf5a1a48bf6ea95edcb878b38d976acff46800c20`；3 个回调 `ev_61fe4bf504af3bab30c37989655a486f237adc918ac853adbe61aa634c33338d`、`ev_89dd6658c932d341dc03a7a9cf81f36953920f61d89659721233bedaaabdb01c`、`ev_9ce9382df98711be485b902d14d86d900ec016ce4969d0d82236e875ceefe012`；下一层 `ev_b1bb67c224420367005086fa4660c987a06a91dc407b62ea093e275ba9d39502`、`ev_3f2920c8a5a28bfac7eefd12f79102206079939f16cb78fd396a09187d415c6d`、`ev_cf9c4d537ae5e8fb8e8eaba56b743fb2f63f4ae32e7190ec67b439a88f8ae983`；枚举 `ev_eec99018be0b24ea0fdb83dbfcbb09650c6b9ece70d3bb5a66c63948bb1fcbd0`、`ev_118d06359e9e069dda4b2440b669e910895f9617e84ffe329c713861b8d57f5a`；冷却辅助 `ev_f7f5a8128a2b8ad23b8d1ffad0deb0350a5188714b5d624a04e92876a0c64684`。

### 反编译陷阱：空伪代码不等于空函数

`0x180132d10`、`0x180132fd0`、`0x180133050` 的 Ghidra 伪代码被推断为 `void f(){return;}`，但完整汇编分别从对象指针/状态/冷却表读取 RAX/EAX，并在 RET 前保留返回寄存器；调用方也使用该返回值。这里只能采用汇编和调用点的联合解释，不能照搬错误的恢复签名。

相反，CGetFieldConfig / CSetFieldConfig 的“空串/无写回”结论已看过对应汇编，限于当前磁盘样本；不外推其他版本或运行时修补行为。

## 7. 配置、调度和任务达成状态

- `GetUserConfig` 的非单参数分支复制共享配置字符串，压回两个字符串；单参数分支处理 AUTOLOGIN、CONFIG_PATH、CLIENT_TYPE。字符串转换辅助函数及全部字段 schema 未全部展开，没有读取用户真实账号配置。
- `DoSystem` 具有操作码分发，部分分支调用 GetPrivateProfileStringA / WritePrivateProfileStringA。原 Lua 的配置访问并不限于两个 FieldConfig 回调。
- 主工作线程 `0x18012beb0` 创建扩展 Lua 环境，装载 `syszs`，运行 `CMGraph:Init()`，按状态决定是否装载 `login`；后续有 `GlobalInit(false)`、`ErrorInit()` 和选定模块的 CExec 调用。
- `0x18012bc20` 为队伍检查创建基础环境并周期调用 `thcheckteam`；`0x18012d790` 为辅助环境注册 baglib/HelpFun 并周期调用 `thhelp`。这些名称从函数内立即数字节和调用恢复，完整线程创建/销毁、暂停协议仍未全部追完。
- `CExec` 的装载成功、Lua pcall 返回，以及原生动作函数返回，都不等于服务器确认任务已完成。领取次数、库存增减、每日上限、任务标志和任务超时需要继续查看对应原 Lua 及其依赖 API；不能只在面板把函数返回当作成功。

Evidence：配置 `ev_b695c6688e654a71c0878afbac03d595fb0be1b59769485616f62473e3e7bd6a`；FieldConfig `ev_92b1a4fff6849f20a0c4ccafa5c9472d401b4745764a420c4e2b32dc6c550ff5`、`ev_719efd60d7ca2d9c7c44d01da73f714396e99ce1601cebbd7c06a9b1fe3a0cee`；DoSystem `ev_1e5b6b39f0eea8371a0b569ba294ca55b6a3ffaeec652b83790add916859343c`；主线程 `ev_35cce87df6117440090defbe03616380e59a0c14cb1fa92524fd21dbfa653165`；队伍 `ev_248e5a01e0ba0229a53b8f15aa7c6c517098d3b43be880185245f754a16ace06`；辅助 `ev_dd75721d16d1704c5c7755e62c48ebb12524d4fe34b85313eb8713e497b38788`。

## 8. mtxjb：本轮可确认与不可确认的实现

完整专项报告：`../artifacts/rea-functions-2026-10-26/mtx/FINDINGS.md`。

可确认的入口直接边为：

```text
DiagCpl.dll:  0xe2cf0c → CALL 0xac4375 → JMP 0xe33f0a（未展开）
notepad.dll: 0x10067fe → JMP 0xbd5853 → CALL 0xbd48e5（未展开）
```

这 4 个函数以栈改写、PUSHFD/PUSHAD 和跳转为主，是保护入口可见路径。主 EXE 的 `0x5f3320` 有 96 个实际文件字节，但 Ghidra 将其标为 data、未创建 procedure；不能说入口不存在。

RunLog、GetDllData、GetVar、GetAdd1/2/3、GetTimeW 七个业务导出则位于原 `.text` 的未初始化内存映射。逐个 `address_to_file_offset` 都确认无 initialized file-backed memory；GetDllData / RunLog 的 32 字节读取实际返回 0 字节且 complete=false。无法凭导出名恢复 ABI，也不能把缺失字节填零后当作业务空函数。

前次 PE 导入证据确认 notepad 声明导入 DiagCpl 的上述六个命名接口，但业务调用点尚未恢复。MTX 是否由 Lua 5.3 库执行任务、Lua 存放在何处，仍未知；没有新增可直接复制的 MTX 任务 Lua。

原始样本 SHA-256 与前次清单相符；该目录实际分析了 3 个关键样本而非所有 DLL，未进行运行时解包。有效的后续材料是同版本未保护构建、符号、公开格式脚本/资源或作者接口说明。

## 9. 对本项目复用方式的具体影响

1. **优先复用天龙助手原 Lua，适配宿主契约。** 需要匹配模块名、Lua 版本/字符串编码、全局配置格式、注册库、对象字段、参数顺序和返回值；只复制任务文件不能补齐原生能力。
2. **先核对基础接口，再谈任务已经接入。** GetLuaValue 的结果格式、EnumEnvObj 的完整对象结构、技能五接口和配置读取应有真实数据对照；缺失读取不能用零/空表伪装有效状态。
3. **达成条件属于任务逻辑和状态接口的共同责任。** 本轮没有修复领取、兑换或副本任务，也没有把装载/动作成功改写成任务完成。后续逐任务保留原 Lua 分支，并核对库存、次数、上限与完成标志。
4. **文件少主要来自集成和内嵌。** 当前 dfz64 自己包含 Lua 宿主、原生兼容接口和约 3.2 MiB 模块容器。减少文件数量是部署组织选择，不等于减少执行层数或自动兼容其接口。不能直接把受保护 x86 MTX DLL 放进 x64 宿主。
5. **效率结论暂不能量化。** 目标也有工作线程、多个 Lua state、窗口消息往返及部分字符串转换；没有基准、实时内存或游戏运行验收，不能宣称按目标形式改造就必然更快、更稳。

## 10. 证据和后续入口

产物全部位于 `E:\game\tlbb\jb\artifacts\rea-functions-2026-10-26`，属于静态研究材料，不是新增运行组件。

- `tlzz/rea-evidence.json`：90 条完整 REA Evidence，包含 70 个选定函数 dossier。
- `tlzz/function-index.json`：地址、文件、Evidence ID、调用关系和伪代码/汇编摘要哈希。
- `tlzz/functions/*.cpp`：Ghidra 原始伪代码投影；`*.asm.txt`：对应完整函数体汇编。不是可编译的原始源码。
- `tlzz/container-and-registration-tables.json`：319 条容器记录及 playerlib / skilllib / 标准库注册表；每条载荷保留静态偏移和哈希，未执行载荷。
- `mtx/combined-evidence.json`：15 条去重成功 REA Evidence；真实失败结果另以逐调用 JSON 保留。
- `mtx/address-table.json`、`mtx/verification.json`：MTX 地址表、样本复核及会话清理信息。
- `inspect_tlzz_container.py`、`project_native_evidence.py`：静态解析与可读投影的可复核脚本。
- `INDEX.json`、`verification.json`：总索引与最终复核。

所有分析器会话已关闭。后续适合继续的独立范围为：GUI 到 DLL 的装载/消息链、三项已反馈任务的原 Lua 结束条件，以及主角色/宠物/技能所依赖对象字段的接口契约。MTX 的保护内业务恢复仍需补充可见证据。
