# 跨城导航资料与运行方式

2026-10-29：传送规划器已通过 `navigation_runtime` 接入驻留引擎的 `MoveTo`。`catalog.json` 的运行开关已开启；NPC 和目的地仍分别受 enabled/verified 控制。

C++ 有界读取 catalog.json 和 city_files，合并城市资料传入驻留 Lua。跨城移动有已核对的有向线路时，执行：到 NPC → 对话 → 选实际目的地 → 等待真实场景改变 → 到任务坐标。没有线路时沿用游戏 AutoRunToTargetEx；不会猜 NPC 名称、坐标或选项。

当前只有苏州 scene_id=1 和洛阳 scene_id=0。两城 NPC 名称、位置和传送选项仍待提供；没有已启用的 NPC 传送边，也没有大理→苏州线路。360,317 是任务目标，不是传送 NPC 坐标。

新增城市可复制 city-template.json，填写实际 scene_id，加入 catalog.json.city_files。每个 NPC 要填写唯一 npc_id、实际 name、position；每条目的地填写唯一 destination_id、target_city 和游戏中的 dialog_option.text。核对资料后将对应 NPC/目的地的 enabled 和 verified 设为 true。使用 tools/validate-navigation.py 检查格式。

运行中的传送请求提交一次，等待实际换图；超时或地图意外变化时停止。approach_waypoints、按索引选菜单、多级菜单和自动重新规划尚未接入本运行适配器。无需为普通移动任务新增独立传送任务。

city_travel.lua 同时保留纯 step 规划接口供离线测试。task.json 仍不作为单独任务注册；当前执行入口是 legacy/modules/navigation_runtime.lua。内置资料收集在 TLBBData.rcc，可按现有 overrides/scripts/builtin/navigation 路径覆盖。
