-- 来自 新建文件夹/小蜜文本/3聊天框分屏.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend"})
local 附近频道 = "1"
local 队伍频道 = "0"
local 世界频道 = "0"
local 私聊信息 = "0"
local 系统频道 = "0"
local 自建频道 = "0"		--系统预留功能，为0就好
local 帮会频道 = "0"
local 门派频道 = "0"
local 个人信息 = "1"
local 帮助频道 = "0"
local 喇叭频道 = "0"
local 同城频道 = "0"
local 同盟频道 = "0"
local 团队频道 = "0"
local 小队频道 = "0"		--系统预留功能，为0就好
local 千里传音 = "0"		--系统预留功能，为0就好
local 古境频道 = "0"
local 势力频道 = "0"		--系统预留功能，为0就好
local 征召频道 = "0"		--系统预留功能，为0就好
local 传音入密 = "0"		--系统预留功能，为0就好
local T服信息 = "0"		--系统预留功能，为0就好
local 连杀信息 = "0"
local 世族频道 = "0"		--2014Q1大世界改造，世族功能去除。为0就好
--只改上面，1=选中，0=取消
local strConfig = 附近频道
strConfig=strConfig..队伍频道
strConfig=strConfig..世界频道
strConfig=strConfig..私聊信息
strConfig=strConfig..系统频道
strConfig=strConfig..自建频道
strConfig=strConfig..帮会频道
strConfig=strConfig..门派频道
strConfig=strConfig..个人信息
strConfig=strConfig..帮助频道
strConfig=strConfig..喇叭频道
strConfig=strConfig..同城频道
strConfig=strConfig..同盟频道
strConfig=strConfig..团队频道
strConfig=strConfig..小队频道
strConfig=strConfig..千里传音
strConfig=strConfig..古境频道
strConfig=strConfig..势力频道
strConfig=strConfig..征召频道
strConfig=strConfig..传音入密
strConfig=strConfig..T服信息
strConfig=strConfig..连杀信息
strConfig=strConfig..世族频道
local isFenpingOpen = tonumber(LUA_取返回值("return Talk:IsFenpingOpen()") )
if isFenpingOpen == 0 then
	LUA_Call("Talk:CreateFenping('"..strConfig.."');")
end
if isFenpingOpen == 1 then
	LUA_Call("Talk:ConfigFenping('"..strConfig.."');")
end