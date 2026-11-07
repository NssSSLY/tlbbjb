# 天龙助手原脚本源码（反编译导出）

本目录由 `python tools/decompile-original.py` 生成，每次运行会整体重建；需要修改请另存副本。

| 目录 | 内容 |
|---|---|
| `Script64/<分组>/<名称>.lua` | dfz64.dll 内嵌的 318 个 Lua 5.4 字节码模块，经 unluac 2025-12-23 反编译。目录与原程序 `..\tlzs\Script64` 一致，保留原局部变量名 |
| `script/数据`、`script/自定义` | 随原程序附带的 36 个明文脚本，内容未改 |

共 354 个 Lua 文件，全部由 GBK 转为 UTF-8。

- 每个反编译文件第一行注明对应的字节码编号，原字节码在 `artifacts/reference-tlzz/bytecode/<编号>.luac`。
- `Script64/系统/daguai.lua` 中有一个函数 `CDG:checkMP` unluac 处理不了。该函数已按原字节码手工还原，与原字节码随机对拍 2 万次，返回值和调用序列一致；见 `tools/original-fixups/`。
- 往返核对：用标准 Lua 5.4.9 重新编译后与原字节码（去调试信息）比较。26 个逐字节一致，其余差异不超过 0.6%，属寄存器和跳转排布不同，逻辑相同。
- 以下 11 个反编译文件和 5 个明文脚本使用了中文变量名或函数名，原程序的 Lua 可以运行，标准 Lua 会报语法错：师门任务、新手1-40级、闲常治务、材料点金、点心法、庄园养鱼、属地马贼、坐标摆摊、common_2、fnE2C、graph；script 下的坐标摆摊、[例] 等待到时间、[例] 等待队伍人数、窗口闪烁报警、自动组队(例)。
- 本目录只供阅读，程序不直接读取。程序使用的副本在 `scripts/original-source/`，由 `python tools/import-original-source.py` 从本目录导入：中文键名改为 `["键名"]` 写法，并修正反编译错误，修正后逐函数与原字节码比对一致。对接表见 `docs/ORIGINAL_SOURCE_MAP.md`。
