# 启动器与单游戏面板设计入口

已进入 0.3.0 原生实现：以根 README、PROGRESS.md 和实际 EXE 为准。小启动器现在只有“开始游戏”，可选多开和角色 1/2/3；本目录草图是前轮布局参考，不再作为当前按钮/登录能力的证明。完整安装器已在 dist/packages/。

2026-10-24，0.3-r2。依据用户修订：小型账号启动器＋每游戏独立面板；Home 绑定并呼出对应面板，End 仅解绑该游戏；面板顶部直接功能 Tab，没有集中角色栏、大标题或简介。

- [当前交互规格](UI_SESSION_SPEC.md)：窗口归属、快捷键、功能 Tab、任务流程、复制、性能与实施步骤。
- [安装包与首次登录约定](INSTALLATION_AND_LOGIN.md)：完整离线安装包 / ZIP、全部 Lua 随包、账号与区服角色缓存、升级保留。
- [启动器配置示例](launcher-profile.example.json)：首次未知角色、登录后缓存角色，均不含真实凭据。
- [角色任务配置示例](role-profile.example.json)：固定游戏面板、独立任务参数/规则。
- [任务目录](task-catalog.json)：29 项初始设计目录，为目录维护来源；原型条目与其校验一致。尚未实现的保持待适配。
- [官网调研](research/OFFICIAL_FINDINGS.md)：前轮官方资料、版本与服务器适用性。

当前两种独立窗口草图为 prototype/tlbb-launcher.html、prototype/tlbb-session-panel.html。启动器可演示首次登录反馈后记录角色；任务面板可切 Tab、编辑/加入流程、复制、预览规则。所有操作仅改变示例内存数据；不收集凭据、不连接游戏，不宣称实际登录成功。

14 组交互检查通过，见 [当前验证报告](../artifacts/ui-design-r2/verification.json)。包括账号/区服缓存隔离、独立面板、参数快照、规则持久性、复制和保护、面板内 Home/End 演示、1024/736/320 宽度和深色。截图已查看；这不是原生全局快捷键、真实登录或游戏行为验收。

检查入口：tools/prepare-ui-design.py 校验当前目录及两份配置；visualize 的 render.py 生成本地检查包装器（覆盖需 --force）；tools/verify-session-design.cjs 执行当前交互检查。

旧 UI_INTERACTION_SPEC.md、prototype/tlbb-workbench.html 与 artifacts/ui-design/ 为历史方案，已被用户否定，不再作为实施依据。tools/verify-ui-prototype.cjs 仅验证旧方案。

现有 0.2 发布包未替换；新 Qt 窗口、登录适配和安装器尚未实现或生成。
