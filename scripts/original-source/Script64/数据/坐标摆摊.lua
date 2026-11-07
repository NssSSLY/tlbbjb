-- 反编译自 dfz64.dll 内嵌字节码 00397f8b（unluac 2025-12-23；仅供分析）
-- 程序内副本修正（只改写法，键名与原字节码一致）：局部变量 摆摊坐标 → bt_pos（6 处）；字段 .洛阳 → ["洛阳"]（1 处）；字段 .苏州 → ["苏州"]（1 处）；局部变量 运行摆摊时先取一次物品 → bt_get_item_first（2 处）
PushDebugMessage("摆摊坐标可自定义,具体查看script/数据 目录")
local bt_pos = {}
bt_pos["洛阳"] = {
  {x = 317, y = 270},
  {x = 322, y = 270},
  {x = 336, y = 270}
}
bt_pos["苏州"] = {
  {x = 224, y = 253},
  {x = 224, y = 244},
  {x = 224, y = 241}
}
bt_pos["楼兰"] = {
  {x = 230, y = 139},
  {x = 225, y = 139},
  {x = 220, y = 139}
}
bt_pos["钱庄"] = {
  {x = 60, y = 55},
  {x = 60, y = 49},
  {x = 60, y = 43}
}
local bt_get_item_first = 0
g_BtPos = {}
g_BtPos = bt_pos
g_BtStartGetItem = bt_get_item_first
