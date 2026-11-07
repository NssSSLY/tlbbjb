--此文件不是用来执行的,是自己编辑脚本时用到的一些接口说明！

--自己要编辑新的脚本时,新建一个文本文档(.txt) 文件,编辑完后缀请设置为 .lua 

--如果新编辑添加了脚本,要在控制台重新加载一次才能刷新看到！





--命令名区分大小写,不要搞错,括号都是英文状态下的括号,不要输入错误！

--更多命令将在整理后公开,若需要什么样的接口请联系客服反馈

--官方网盘有部分开源的脚本文件供大家参考，需要的联系客服下载





--[[  



--打怪方式1，参数2模式目前有效值 -1,0,1,2,3,4,5 ， 具体意义日后说

AI_Start(怪物id,模式)

    



--打怪方式2，该方式可以设置一些参数



--第一步必须初始化,设置一些默认参数

DG_OnInit()  

--以下的参数，按需自行设置，其实部分已经有默认值，无需重复设置

--三选一

DG_SetParam("打怪方式", "先红后绿")

DG_SetParam("打怪方式", "先绿后红")

DG_SetParam("打怪方式", "先近后远")

--二选一

DG_SetParam("攻击模式", "优先绿怪")

DG_SetParam("攻击模式", "珍兽单刷")

--二选一

DG_SetParam("目标","所有")

DG_SetParam("目标","添加","慕容博 萧远山")

--目标类型  1：只打指定名称的怪物，类型2：只打指定名称以外的怪物

DG_SetParam("目标类型", 1)

--是否选中要攻击的目标

DG_SetParam("是否选中怪", true) --false

--打哪种颜色的怪物 自由组合 红白绿

DG_SetParam("怪物归属", "红白绿")

DG_SetParam("怪物归属", "红绿")

--攻击范围

DG_SetParam("打怪范围", 5)

--坐标赋值方式只可以2选1

DG_SetParam("坐标", "赋值", { { x = 135, y = 183 }, { x = 125, y = 180 }})

DG_SetParam("坐标", "添加", 12, 34);DG_SetParam("坐标", "添加", 56, 78)

--设置打怪地图，默认-1

DG_SetParam("地图", sceneID)

--是否打怪，按需设置

DG_SetParam("是否攻击", true) --false

--usehorse:使用坐骑，usepet:使用珍兽 dxys:掉血隐身

DG_SetParam("其他参数", { usehorse = false, usepet = true, dxys = false })





--DG_OnAction()开始打怪，有一个参数参数可为空，该参数是一个回调函数，为防止寻路进入死循环,函数原型：

function callback(x,y,scene)

    if GetActiveSceneName() ~= "水牢" then 

        --跳出寻路

        return false

    end

    return true

end

DG_OnAction(callback)

--打怪方式2说明结束











--清理背包 -1:全清理，0:清理道具栏 1:清理材料栏 2:清理绑定物品

DelBagItem(0)



--打开地面包

CallFun(2,id)

--对话npc

CallFun(3,id)

--选怪

CallFun(4,id)

--销毁背包指定位置物品 idx:0-59

CallFun(5,idx)

--轻功

CallFun(6,x,y)





bUse = UseSkill("净心观月", -1)

UsePetSkill("冰天雪地")

UsePetSkill2("高级神佑")





--捡包

    PickUp()





--商会买物品

ShangH_BuyItem("物品名称", 数量, 最高价钱,名称匹配模式)

    名称匹配模式  0是精确匹配

                 1模糊匹配，比如要买各种颜色的定位符 填1就可以



--使用背包物品

UseItem(参数1，"参数2")

参数1整数型 目前可填 0，1，2，8，10(不同的数字代表实现方法不同，具体使用根据实际物品)

参数2文本型 是物品的名称 



--GetLuaValue() 这个是个万能接口，能实现很多功能，不会用的话请关注【其他脚本.lua】有简单例子

local 返回值1,返回值2,返回值n = GetLuaValue("游戏的lua字串","返回值类型",返回值个数)    

    类型 "s"  文本型

    类型 "n"  整数型

    "sns" 表示3个返回值，第一个文本型，第二个整数型，第三个文本型。对应返回值个数填3



--帮会百宝阁商店购买物品，后面的1是起始物品位置，需自己改动

GetLuaValue("setmetatable(_G, {__index=BangHui_Shop_Env});BangHui_Shop_GoodButton_Clicked(1);","",0);



--帮派战功商店购买物品，后面的0是起始物品位置，需自己改动

GetLuaValue("setmetatable(_G, {__index=JueweiShop_Env});JueweiShop_BuyItem(0);","",0);



local 返回我的门派ID = GetLuaValue("return Player:GetData('MEMPAI');", "n", 1)

    id=0：少林     id=1：明教     id=2：丐帮 



local 门派文本名称 = GetMenpaiName(填门派ID)



local 当前地图名 = GetActiveSceneName()



local 当前地图ID = GetSceneID()



--取玩家坐标

local x坐标,y坐标 = Player_GetPos()



--取玩家信息

local 返回值 = GetPlayerInfo("参数")

    参数 "NAME"       返回玩家名称

    参数 "LEVEL"      返回玩家等级

    参数 "GUID"       返回玩家GUID

    参数 "OtherName"  返回本机所有玩家名称

    参数 "FPGUID"     返回出战的珍兽GUID



local 金币 = GetMoney(1)

local 交子 = GetMoney(2)



local 当前血百分比 =  GetHPPercent()



local 当前蓝百分比 = GetMPPercent()



local 当前血 =  GetCurrentHP()



local 当前蓝 = GetCurrentMP()



local 当前杀气值 = Player_GetPK()



--给队员上状态

GiveTeamState("冰肌玉骨")



--洛阳回血

LuoYangRestore(百分比) 



--用地图id取地图名

local 地图名= GetSceneNameByID(地图ID)



--进入帮会城市 

CityToGuild()



--离开帮会城市参数 0，1，2，3

GuildToCity(1)



--队长返回1，队员返回0

local 是否队长 = IsLeader()



--没上坐骑返回-1

local 坐骑状态 = Player_GetMountID()



--对话npc  

TalkNpc("NPC名字")



--对话框 点击选项 0是模糊匹配，1是精确匹配

QuestFrameOptionClicked("选项名称",填0或1)



--对话框 点击接受

QuestFrameAcceptClicked()



--对话框 点击继续

QuestFrameNextClicked()



--对话框 点击完成

QuestFrameMissionComplete()



--各种确定 跨图寻路确定、销毁物品确定等...

MessageBox_Self_OK_Clicked()



--取消角色的状态

Player_DispelBuffByName("buff状态名称")





跨图寻路("凤鸣镇",159,123)



下坐骑()



使用物品("物品名")



等待(间隔时间)             例： 等待(1000) //等待1秒

    参数1  整数型           //参数1的单位是毫秒,不是秒。1000毫秒 = 1秒

    返回值 无



等待到指定时间(时间文本)    例： 等待到指定时间("20:05") //一直等到晚上8点05分 当中是英文状态的冒号！

    参数1  文本型           //文本型参数需要加英文引号

    返回值 无



等待队伍人数(数量,喊话内容) 例： 等待队伍人数(4,"75++ 楼兰箱子来人,满4人就进了")

    参数1  整数型           //需要等待的队伍数量

    参数2  文本型(可空)     //喊话内容

    返回值 无



执行脚本(脚本名)           例： 执行脚本("师门任务")

    参数1  文本型             

    返回值 无



组队跟随()

    参数1  无

    返回值 无



取消跟随()

    参数1  无

    返回值 无



输入屏幕文本(文本内容)     //将参数1输入到游戏屏幕       

    参数1  文本型             

    返回值 无





音乐报警()



闪烁窗口()



































]]--













































--常用的符号：

--  注释符：注释就是这行无作用,不会被执行 。单行注释(2个减号) ：--

--  多行注释 ：如下

--[[

  

  这里就不会被执行



]]--