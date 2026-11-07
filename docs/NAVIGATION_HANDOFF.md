# 跨城传送与自动登录继续入口

2026-10-24。用户在实际 0.3.0 面板中选择“洛阳坐标移动”，日志读取到苏州 187.9,268.4，因不在洛阳而停止。该结果符合旧任务只做同地图移动的范围，但不满足完整跨城目标。用户明确本次先建立传送 NPC 文件，后续逐个提供坐标。

## 本次已生成

维护目录 scripts/navigation/。catalog.json 索引城市文件；cities/suzhou.json、cities/luoyang.json 均待补名字/坐标；city-template.json 用于后续新城市；request.example.json 仅保存已知的最终目标洛阳 360,317。

苏州→洛阳记录是未启用的待核对项，不证明游戏中该 NPC 可以直接到达。洛阳也未编造返程关系。新增 NPC 追加同城 npcs 数组，一个地图允许多个。收到数据后记录用户提供值，名称、可达城市或菜单仍缺失的继续待补，不自动 verified/enable。

Lua city_travel.lua 为纯规划骨架：当前地图识别、已核对有向路径/有限中转、到 NPC、确认对应对话、选择真实选项、等待实际切图、最后到目标点。动作有会话/请求 ID、确认等待、超时和重试限制；未知 NPC、菜单、目标地图或会话变化均明确停止。只要动作仍待确认就不反复发送。

当前 runtime_enabled=false，task.json 也明确 can_run_in_current_worker=false。0.3.0 LuaTask 加载器硬编码 luoyang_plant；新骨架不是把 ID 改名就能启用。现有 Worker 也不支持 navigate_to/interact_npc/select_destination。配置由未来宿主校验合并传给 Lua，不能在沙箱里使用 require/dofile/io。

## 收到坐标后的顺序

1. 将地图、NPC 名和 X/Y 更新到对应城市文件，保留来源和待核对状态。
2. 核对可达城市、对话选项文字和必要的中转方向；不要用屏幕按钮位置替代游戏菜单语义。
3. 接真实寻路/到达状态。已有洛阳 32 格内移动不可被当成任意城市长距离寻路，保持旧限制。
4. 分别接 NPC 身份/交互、对话选项读取与选择、切图状态；确认成功判据和取消行为。
5. 完成受控实机验收后注册新任务、映射参数并启用对应路由；再重新构建完整包。当前 Lua/JSON 会由发布脚本递归打入下次 scripts/builtin/navigation/。

验证入口 tools/verify-navigation.ps1：先校验所有城市 JSON，生成 artifacts/navigation/compiled-catalog.json 与 catalog-validation.json，再用独立 Lua 测试器执行 tests/navigation_planner_tests.lua。测试只用构造数据，不连接游戏。

## 自动登录不是已实现功能

用户反馈输入账号密码后“开始游戏”没有自动登录。当前 src/launcher_window.cpp::launchGame 仅保存账号/区服/槽位、启动官方 Launch.exe、跟踪并绑定子进程；ClientStore 只提供密码加密保存，没有认证执行器或凭据解密消费流程。故不是重输密码或换启动参数即可修复的问题。

后续需实现真实登录状态识别、凭据解密后交给受限登录动作、选服/角色槽位匹配、等待进世界与核验角色，并对验证码等进入等待人工。不得写明文密码到 Lua/日志或命令行；认证与角色读取缺失时不得报告“自动登录成功”。本次生成传送文件没有修好自动登录，现有 0.3.0 安装包保持原能力。

本次没有读取进程或执行移动/传送/登录，没有改已发布 EXE、旧 Lua 或安装包。没有改全局游戏目录或用户账号记录。
