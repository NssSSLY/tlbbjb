-- 反编译自 dfz64.dll 内嵌字节码 00334068（unluac 2025-12-23；仅供分析）
PushColorMsg("自动下线：此号掉线登录将不再生效！")
PlayerDataInit()
os.remove(g_public_dir .. "掉线执行\\" .. g_self.name .. ".ini")
os.remove(g_public_dir .. "掉线执行\\" .. g_self.name .. ".txd")
os.remove(g_public_dir .. "掉线执行\\" .. g_self.name .. ".txp")
OffLine(true, g_self.name .. "-用户运行自动下线脚本,掉线登录不再生效！")
