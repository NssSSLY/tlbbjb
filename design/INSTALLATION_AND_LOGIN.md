# 完整安装包、账号和角色缓存约定

2026-10-24；设计修订 0.3-r2。当前 0.3.0 已构建完整安装器/ZIP 并在 E 盘安装验证，实际文件见根 README 和 artifacts/安装后文件清单-0.3.md；以下登录认证仍属分阶段目标。

## 软件目录

```text
E:\TLBBClient\
  TLBB.exe                       单入口，启动器/托盘/单游戏面板
  TLBBNativeBridge.dll
  Qt6*.dll / 其他运行库
  platforms\ styles\
  qt.conf
  scripts\builtin\               随包全部内置 Lua
  scripts\user\                  用户脚本，升级保留
  tasks\                         task_id、入口、参数、依赖能力
  defaults\
  package-manifest.json           版本、相对路径、大小、SHA256
  data\
    launcher.json                路径、窗口、默认选择
    accounts.json                别名、区服、凭据引用
    credentials.dat              本机用户加密的凭据
    roles.json                   账号＋区服对应已读角色
    profiles\<role-key>.json     每角色参数/队列/规则
    backups\
  logs\                         有界、脱敏
  cache\                        有界，不静默使用 C 盘
```

新版通过迁移兼容现有 scripts/luoyang_plant.lua 和 user-data/，无需手搬。首次检测目录可写。完整软件目录不等于密码可以跨电脑直接解密，换电脑需重新录入凭据。

## 交付

- TLBBClient-<version>-Setup.exe：完整离线安装，选择目录、创建入口，安装目录包含全部运行文件。
- TLBBClient-<version>-full.zip：从同一 staging 生成的完整文件夹，解压可运行，不是仅 EXE 增量包。

已使用项目本地 Inno 7.1.0 生成安装器。开发机 .tools、Qt SDK、编译器不进用户包。完整打包不能补出尚未实现的游戏接口。

## Lua 随包与升级

1. 源 scripts/ 递归收集兼容 Lua 与所引用资源，内置文件进入 scripts/builtin/；排除测试凭据、缓存和备份。
2. 可选任务有 tasks/<task_id>.json：入口、参数、脚本版本、引擎 API 版本、依赖能力、完成判据、安全点。
3. 发布检查唯一 ID、入口存在、相对路径不越界、资源齐全，生成文件哈希；缺失则打包失败。
4. 安装包/ZIP 从同一 staging 生成，解包对比路径/大小/哈希；运行只用安装目录相对路径，不依赖开发机。
5. 新增兼容 Lua 或改规则无需重编 C++，但发完整包时必须重新打包；改客户端界面/原生 API 必须重新编译再打包。
6. 脚本经任务描述出现在对应 Tab，发现 .lua 不等于动作可用；能力/版本不满足则阻止执行。

升级保留 data/、scripts/user/ 与自定义任务描述；先备份再迁移，失败可回退。内置与自定义 ID 冲突明确处理。安装前有序退出宿主，不强杀游戏。卸载默认保留用户数据，明确选择才删除。

## 首次登录缓存

- 未登录/未读取：unknown，不构造虚假角色，不阻止保存账号和区服。
- 角色选择适配成功：保存该账号该服实际读到的列表、读取时间和来源。
- 只在世界读取当前角色：只保存当前角色，roster_complete=false。
- 再次打开：选本地已知角色作为目标，到选择界面再次核验；缓存不替代身份核验。
- 读取失败：保留旧缓存并标记 stale，不以空列表覆盖。
- 手动登录后 Home：核验当前角色；无法确定账号归属时只保存待确认角色，不能随意挂入已存账号。

稳定键为 account_id/product_id/district_id/server_id/character_id；名称、门派、等级、槽位和 last_seen 为属性。角色 ID 不可读时不将槽位当永久身份。

没有保存密码则认证阶段等待输入；验证挑战转人工，重试有上限。首次成功后记录角色供下次选择，任务仍由 Home 面板显式开始。

## 发布验收

在未安装 Qt/MinGW/Lua 开发环境的 Windows 离线启动。分别验首次路径配置、无缓存账号登录、角色读取、重开后选角色、角色列表变化、多窗口 Home/End 归属、游戏退出清理。核对全部 Lua/资源，升级不丢账号队列、不启用销毁、敏感数据不进 Lua/日志。

0.3.0 已实现新启动器、每游戏独立面板和安装器；账号登录动作、完整角色读取和真实昵称仍未适配。角色槽位可手动选择并保存，可靠昵称后续替换显示。
