-- 来自 新建文件夹/小蜜文本/套餐/40套餐/吃黄金马鞍.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"item"})

if 屏幕提示(判断人物状态("黄金马鞍")) == 0 then
	取出物品("黄金马鞍")
	延时(500)
	右键使用物品("黄金马鞍",1)
end