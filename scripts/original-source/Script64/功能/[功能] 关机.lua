-- 反编译自 dfz64.dll 内嵌字节码 0033426a（unluac 2025-12-23；仅供分析）
PushColorMsg("10秒后自动关机")
Sleep(10000)
PlayerDataInit()
os.remove(g_public_dir .. "掉线执行\\" .. g_self.name .. ".ini")
os.remove(g_public_dir .. "掉线执行\\" .. g_self.name .. ".txd")
os.remove(g_public_dir .. "掉线执行\\" .. g_self.name .. ".txp")
ShutDown("执行关机脚本")
