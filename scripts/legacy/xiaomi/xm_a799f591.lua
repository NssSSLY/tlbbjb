-- 来自 新建文件夹/小蜜文本/小蜜文本/金先生-1999骆驼(身上必须有2000J).lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
local 购买物品 = {"坐骑：骆驼"}

 

function 检测物品(index)

 local name = 购买物品[index]

 local x = LUA_取返回值(string.format([[ 

  local n = GetActionNum('boothitem')

  local name = "%s"

  PushDebugMessage(name)

  for i=0,n do

   local theAction = EnumAction(i, "boothitem");

   if theAction:GetID() ~= 0 then

    if theAction:GetName() == name then

     return i

    end

   end

  end

  return -1   

 ]],name))

 return x

end

屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")
延时(500)



取出物品("金币") 

跨图寻路("洛阳",229,324,0)

对话NPC("田骁鸣");延时(500)

NPC二级对话("购买骑乘");延时(500)

if 窗口是否出现("Shop")==1 then

 for i=1,1 do

  local index = 检测物品(i)

  if 到整数(index)>=0 then

   for n=1,1 do

    LUA_Call(string.format("NpcShop:BulkBuyItem(%d, 1, 0)",index));延时(450)

   end



  end

 end

end
屏幕提示("需要各种脚本，图形验证，定制账号，天龙专用虚拟机，请找微信：acc00080")