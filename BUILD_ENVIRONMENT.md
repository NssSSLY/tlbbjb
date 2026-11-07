# 客户端构建环境

配置日期：2026-10-23。结论：本机已具备构建 C++17 / Qt Widgets / Lua 外部 Windows x64 客户端的环境，并已通过真实编译、运行与独立部署验证。

## 本机条件

- Windows 11 x64，系统版本 10.0.26100。
- 16 个可见逻辑处理器，物理内存约 31.11 GiB。
- 配置前 E 盘空闲约 299.30 GiB；配置后的实时资源数据见 [artifacts/build-environment.json](artifacts/build-environment.json)。
- 标准路径未发现 Visual Studio/MSVC、Microsoft Windows SDK 或 Qt 安装；项目使用便携 MinGW-w64 提供 Windows API 头文件与导入库，不要求为当前外部客户端安装完整 Visual Studio。

## 已配置的组件

| 组件 | 固定版本 | 项目内位置 |
| --- | --- | --- |
| CMake | 4.4.4 | `.tools/cmake` |
| Ninja | 1.13.2 | `.tools/ninja` |
| GCC / G++ / MinGW-w64 | 13.1.0，x86_64-w64-mingw32 | `.tools/Qt/Tools/mingw1310_64` |
| Qt | 6.8.3，MinGW x64 | `.tools/Qt/6.8.3/mingw_64` |
| Qt 范围 | qtbase、qttools，含 Core/Gui/Widgets/Network、moc/uic、windeployqt | 同上 |
| Lua | 5.4.9，源码校验后本地编译 | `.tools/src/lua-5.4.9` |
| GDB | 11.2，随编译器包提供，版本查询通过 | MinGW 的 `bin` |
| aqtinstall | 3.3.0，安装用途 | `.tools/pythonpkgs` |

CMake/Ninja 从电脑已有项目复制到本工作区，后续构建不依赖那个项目目录。Qt 与 MinGW 从 Qt 官方仓库及其重定向镜像下载，未关闭安装器的包校验。Lua 下载包与官方 SHA256 相符：

```text
2335b6c582a52654f94612bf10d2f4672805d05329aa6568b1d8cd9e5c6fb8e6
```

未选用较新 Qt 分支的原因是该分支安装元数据校验失败；没有跳过校验，而是固定到可以验证且与 MinGW 13.1 匹配的 6.8.3。

没有修改持久系统 PATH，没有安装全局 Python 包，没有安装系统服务、驱动或 Visual Studio。环境只在执行 `env.ps1` 的 PowerShell 进程中激活。Python 只用于安装/记录，编译出的程序不依赖 Python 运行。

`tools/env.ps1` 同时将当前构建进程及其子进程的 `TEMP` / `TMP` 指向项目 `.tools/temp`，将 `PIP_CACHE_DIR` 和 `PYTHONPYCACHEPREFIX` 指向 `.tools/cache`，避免后续构建沿用 C 盘默认临时目录。此设置不会迁移既有缓存，不会修改系统环境变量，也不会改变 Codex 应用自身的安装、会话或运行时目录。源码、工具链、下载包、构建输出、测试报告和发布目录均在本项目 E 盘目录下。

## 使用方式

在 PowerShell 中执行：

```powershell
Set-Location 'E:\game\tlbb\jb'
. .\tools\env.ps1

cmake --version
g++ --version
qmake -query QT_VERSION
```

重新构建并验证环境：

```powershell
& 'E:\game\tlbb\jb\tools\verify-build-environment.ps1' -Jobs 4
& 'E:\game\tlbb\jb\tools\verify-deployment.ps1'
```

默认最多四个并行编译任务，避免在游戏运行时使用全部逻辑处理器。构建文件放在 `.tools/build/environment-smoke`，独立部署验证放在 `.tools/deploy/environment-smoke`。它们是环境验证程序，不是游戏脚本客户端成品。

## 实际验证结果

CTest：2/2 通过，0 失败。综合 C++ 验证覆盖八项：

1. Lua 5.4.9 嵌入与脚本计算。
2. Qt Widgets 创建和渲染，未在用户桌面显示窗口。
3. uic 从 `.ui` 文件生成界面代码并参与编译。
4. moc 生成代码及 Qt 信号/槽执行。
5. QLocalServer/QLocalSocket 本地命名管道通信。
6. QProcess 隐藏启动自己的测试子进程并正确取得退出码。
7. Win32 Job 创建和内存限额配置；没有把游戏或测试程序加入限额组，不宣称已经验证生产限额执行。
8. Win32 进程内存指标与 User32 API 可用性。

另一个测试验证独立 Lua 解释器。随后使用 windeployqt 复制运行库，设置包内 qt.conf，把测试进程 PATH 缩减到 Windows 系统目录、清除外部 Qt 插件路径后运行成功；报告中的插件路径指向部署目录本身。

证据：

- [完整环境、版本、源码及下载包哈希](artifacts/build-environment.json)
- [综合运行结果](artifacts/environment-smoke.json)
- [CTest JUnit 结果](artifacts/environment-ctest.xml)
- [独立部署运行结果](artifacts/environment-deployment.json)
- [部署日志](artifacts/environment-deployment.log)
- [安装工具依赖锁定清单](tools/environment-requirements.lock.txt)

验证时使用了 Windows Qt 平台插件，不依赖 offscreen 替代平台。隔离桌面中的控件渲染成功不等于已经测试正常桌面的 Home/End 快捷键。

## 边界与可选项

- Vulkan 头文件、DXC 着色器编译 DLL 和 Qt 翻译资源未安装，配置/部署日志会提示相关可选项缺失；已验证的 Widgets、Lua、IPC 路径不依赖这些资源。
- 没有安装 Qt Creator；当前已能使用命令行构建，图形 IDE 不属于编译必需条件。
- 尚未验证游戏内部 C++ ABI 互操作。游戏模块使用的 MSVC 风格 C++ 类接口不能直接当作 MinGW 可链接 API，后续游戏适配应采用明确的边界，并按实际接口另行确认所需工具链。
- 本次环境验证没有读取、修改或控制游戏进程；没有实现绑定客户端、任务系统、游戏动作或超过双开的能力。
- 此结果证明能构建并运行所选技术栈，不证明三会话稳定性、长期内存上限或游戏适配已经通过。

技术依据：[Qt 6.8 Windows 支持配置](https://doc.qt.io/qt-6.8/windows.html)、[Lua 官方源码与校验值](https://www.lua.org/ftp/)。
