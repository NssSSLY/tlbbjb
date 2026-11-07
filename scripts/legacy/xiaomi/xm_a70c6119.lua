-- 来自 新建文件夹/小蜜文本/小蜜文本/金先生-仓库扩容.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
function 购买储物柜()

if 获取人物信息(16) =="大理" then

           跨图寻路("大理",217,177)
			延时(500)
             对话NPC("吕伙计")
              延时 (3000)
              NPC二级对话("购买新的储物箱")
              延时 (3000)
               LUA_Call(" setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
				延时(2000)

elseif 获取人物信息(16) =="苏州"  then

跨图寻路("苏州",196,277)
			延时(500)
         对话NPC("孔伙计")
              延时 (3000)
              NPC二级对话("购买新的储物箱")
              延时 (3000)
               LUA_Call(" setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
				延时(2000)

elseif 获取人物信息(16) == "洛阳"  then

跨图寻路("洛阳",183,298)
			延时(500)
            对话NPC("陈先生")
              延时 (3000)
              NPC二级对话("购买新的储物箱")
              延时 (3000)
               LUA_Call(" setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
				延时(2000)
			
		   end
      end
屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")
取出物品("金币")
购买储物柜()
购买储物柜()
购买储物柜()
购买储物柜()
购买储物柜()
购买储物柜()
存物品("金币")

屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")