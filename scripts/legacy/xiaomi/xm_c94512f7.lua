-- 来自 新建文件夹/小蜜文本/其他类型文本/等待队伍人满.txt（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({})
function 等待队伍人满()
	local 队伍人数=组队_获取队伍人数()
	while 队伍人数 ~= 6 do
		队伍人数=组队_获取队伍人数()
		延时(5000)
	end
end


等待队伍人满()
