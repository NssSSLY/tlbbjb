-- 来自 新建文件夹/小蜜文本/好像类似大漠文本/a手动小票.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({})
while true dolocal 时间 = os.date("%H:%M:%S")if 时间 == "21:03:20" then     

PushDebugMessage("时间到了")endSleep(100)end