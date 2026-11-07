-- 来自 新建文件夹/小蜜文本/套餐/60套餐/5洗神器_极品.lua（小蜜文本，方言关键字已转为 Lua）
LoadScript("xiaomi_api") XiaomiRequire({"spend", "item"})
function 友情提示(text,...)
	local strCode = string.format(text,...)
	LUA_Call(string.format([[
		setmetatable(_G, {__index = DebugListBox_Env})
		str= "#e0000ff".."【V信:Moto96520出文本定制文本】".."#eFF0000".."%-88s"
		DebugListBox_ListBox:AddInfo(str)
		--橙色 #e0000ff#u#g0ceff3
		--蓝色 #e0000ff#g28f1ff
		--#Y
	]], strCode))
end


function 窗口确定()
        if  窗口是否出现("MessageBox_Self")==1 then
                友情提示("窗口确定")
                LUA_Call(" setmetatable(_G, {__index = MessageBox_Self_Env});MessageBox_Self_OK_Clicked();")
                延时(2000)
        end
end


function 取服务器时间()
        local curDay = LUA_取返回值("return DataPool:GetServerDayTime();","n",1)
        return tonumber(curDay)
end



function 判断关闭窗口(strWindowName)
        if 窗口是否出现(strWindowName)==1 then
                LUA_Call(string.format([[
                        setmetatable(_G, {__index = %s_Env}) this:Hide()
                ]], strWindowName))
                延时(1500)
          end
end

function 窗口关闭(strWindowName)
      if 窗口是否出现(strWindowName)==1 then
            LUA_Call(string.format([[
                    setmetatable(_G, {__index = %s_Env}) this:Hide()
          ]], strWindowName))
                延时(2000)
          end
end



function 取所有钱()
        所有钱=获取人物信息(52) +获取人物信息(45)
        return 所有钱
end

function  取身上装备持久(aaa)
        local tem = LUA_取返回值(string.format([[
                return EnumAction(%d,"equip"):GetEquipDur()
        ]], aaa))
                return  tonumber(tem)
end

function  取身上装备ID(aaa)
        local tem = LUA_取返回值(string.format([[
                return EnumAction(%d,"equip"):GetID()
        ]], aaa))
        return  tonumber(tem)
end

function 取身上装备名字(aaa)
        return  LUA_取返回值(string.format([[
                return EnumAction(%d,"equip"):GetName()
        ]], aaa))
end

function  取背包装备等级(index)
local aaa=  LUA_取返回值(string.format([[
                return LifeAbility : Get_Equip_Level(%d);
        ]], index))
        return tonumber(aaa)
end





function 写角色配置项(AAA, BBB, CCC)
    local 名字= 获取人物信息(12)
    local 路径=string.format("C:\\天龙小蜜\\角色配置\\%s.ini",名字)
        if AAA~=nil and BBB~=nil and CCC~=nil  then
                友情提示("写角色配置项|"..AAA.."|"..BBB.."|"..CCC);延时(200)
                写配置项(路径,AAA,BBB,CCC);延时(200)
        end
end

function 读角色配置项(AAA, BBB)
    local 名字= 获取人物信息(12)
    local 路径=string.format("C:\\天龙小蜜\\角色配置\\%s.ini",名字)
    local tem =读配置项(路径,AAA,BBB)
        if tem ~=nil then
                友情提示(AAA.."|"..BBB.."=="..tem);延时(500)
                else
                return 0
        end
        return tem
end
---------------------------------------------------------必备函数-----------------------------------------------------------------
--------------------------------------------------装备相关------------------------------------------------
local SelfEuipList =
{
        [1]  = { name="武器", downIndex=11,  equipIndex=0, equipName="" },    --- 武器
        [2]  = { name="护腕", downIndex=3, equipIndex=14, equipName=""},    --- 护腕
        [3]  = { name="戒指上", downIndex=7,  equipIndex=6,equipName=""  },    --- 戒指（上）
        [4]  = { name="戒指下", downIndex=8,  equipIndex=11, equipName=""},    --- 戒指（下）
        [5]  = { name="护符上", downIndex=9,  equipIndex=12, equipName=""},    --- 护符（上）
        [6]  = { name="护符下", downIndex=10, equipIndex=13, equipName=""},    --- 护符（下）
        [7]  = { name="衣服", downIndex=12,  equipIndex=2,equipName=""  },    --- 衣服
        [8]  = { name="帽子", downIndex=1,  equipIndex=1, equipName="" },    --- 帽子
        [9]  = { name="护肩", downIndex=2, equipIndex=15,equipName="" },    --- 肩膀
        [10] = { name="手套", downIndex=4,  equipIndex=3, equipName="" },    --- 手套
        [11] = { name="腰带", downIndex=5,  equipIndex=5, equipName="" },    --- 腰带
        [12] = { name="鞋子", downIndex=6,  equipIndex=4, equipName="" },    --- 鞋子
        [13] = { name="项链", downIndex=13,  equipIndex=7,equipName=""  },    --- 项链
        [14] = { name="暗器", downIndex=14, equipIndex=17, equipName=""},    --- 暗器
        [15] = { name="龙纹", downIndex=25, equipIndex=19,equipName="" },    --- 龙纹
        [16] = { name="武魂", downIndex="", equipIndex=18,equipName="" },    --- 武魂
        [17] = { name="令牌", downIndex=16, equipIndex=20,equipName="" },    --- 令牌
}



function 取下装备获取名字(装备位置名称)
        for i =1,#SelfEuipList do
                if SelfEuipList[i].name == 装备位置名称 then
                        友情提示("准备取下装备位置:"..装备位置名称)
                                local 装备持久 =取身上装备持久(SelfEuipList[i].equipIndex)
                                if 装备持久 <= 0 then
                                        友情提示("装备持久不够,不取下")
                                        return 0
                                end
                                if 取身上装备ID(SelfEuipList[i].equipIndex) == 0  then
                                        return 0
                                end

                                for k =1, 10 do
                                        local  装备名称 = 取身上装备名字(SelfEuipList[i].equipIndex)
                                        if  窗口是否出现("SelfEquip")~=1  then
                                                LUA_Call ("MainMenuBar_SelfEquip_Clicked();");延时(2000)
                                        end
                                        LUA_Call(string.format([[ setmetatable(_G, {__index = SelfEquip_Env});SelfEquip_Equip_Click(%d,0)]], SelfEuipList[i].downIndex))
                                        延时(5000)
                                        if  取身上装备ID(SelfEuipList[i].equipIndex) == 0 then
                                                判断关闭窗口("SelfEquip")
                                                return 装备名称
                                        end
                                end
                                return 0
                        end
                end
end

function 穿上装备(装备位置名称,装备名称)
     if 装备名称==""  then
                友情提示("参数错误,穿上装备")
                return
        end
        if 获取背包物品数量(装备名称)<=0 then
                        友情提示("没有装备无法使用,穿上装备")
                        return
        end
        for i =1,17 do
                if SelfEuipList[i].name == 装备位置名称 then
                        for k =1, 5 do
                        右键使用物品(装备名称);延时(2000)
                                if  取身上装备ID(SelfEuipList[i].equipIndex) > 0 then
                                        友情提示(" 晴天成功穿上"..装备名称.."|在位置:"..装备位置名称)
                                        break
                                end
                        end
                end
        end
end




function 神器炼魂(序号)
        LUA_Call(string.format([[
                        Clear_XSCRIPT()
                        Set_XSCRIPT_Function_Name( "OnShenqiUpgrade" )
                        Set_XSCRIPT_ScriptID( 500505 )
                        Set_XSCRIPT_Parameter( 0, %d)
                        Set_XSCRIPT_Parameter( 1, 160)
                        Set_XSCRIPT_Parameter( 2, 0 )
                        Set_XSCRIPT_ParamCount( 3 )
                        Send_XSCRIPT()
                 ]], 序号))
end

function 神器炼魂确定(序号)
        LUA_Call(string.format([[
        g_ItemPos=%d
                Clear_XSCRIPT();
                        Set_XSCRIPT_Function_Name("DoRefreshSuperAttr");
                        Set_XSCRIPT_ScriptID(500505);
                        Set_XSCRIPT_Parameter(0,g_ItemPos);
                        Set_XSCRIPT_ParamCount(1);
                Send_XSCRIPT();
                 ]], 序号))
                延时(3000)
                LUA_Call(string.format([[
                                setmetatable(_G, {__index = SuperWeaponUpNEW_Env});
                        SuperWeaponUpNEW_Clear(1)
                        SuperWeaponUpNEW_Hide_RadioText()
                         ]]))
end

function 取身上武器属性()
 local isWQ = LUA_取返回值(string.format([[
                local  theAction =EnumAction(0, "equip");
                local num = theAction:GetEquipAttrCount()
                if num> 0 then
                local str = ""
                for i = 0, num-1 do
                        local tempstr = theAction:EnumEquipExtAttr(i)
                        if string.find(tempstr, "#{") then
                                local left = string.find(tempstr, "#{")
                                local left2 = string.find(tempstr, "}")
                                strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))
                        end
                                str = str..strTemp.."|"
                end
                return str
                end
                return -1
                                 ]], "s"))
        return tostring(isWQ)
end

--屏幕提示(取身上武器属性())

function 取神器炼魂后重的属性()
 local isWQ = LUA_取返回值(string.format([[
        local num =  DataPool : Lua_GetSuperRecoinNum();
        if num> 0 then
        local str = ""
        for i = 0, num-1 do
                local tempstr = DataPool:Lua_GetSuperRecoinEnumAttr(i)
                if string.find(tempstr, "#{") then
                        local left = string.find(tempstr, "#{")
                        local left2 = string.find(tempstr, "}")
                        strTemp = GetDictionaryString(string.sub(tempstr, left+2, left2-1))
                end
                        str = str..strTemp.."|"
        end
        return str
        end
        return -1
                                 ]], "s"))
        return tostring(isWQ)
end



--[[友情提示(取神器炼魂后重的属性())

if string.find(取神器炼魂后重的属性(),"毒攻击") then
        友情提示("11111")
end
延时(500000)
友情提示(取神器炼魂后重的属性())
延时(500000)    --]]


function 全自动神器炼魂(属性,属性2,属性3,属性4,属性5,属性6)
取出物品("神兵符1级|神兵符2级|神兵符3级")
        if  not 属性 then
                属性= "血上限"
        end

        if  not 属性2 then
                属性2= "血上限"
        end
        if  not 属性3 then
                属性3= "血上限"
        end
        if  not 属性4 then
                属性4= "血上限"
        end
        if  not 属性5 then
                属性5= "血上限"
        end
        if  not 属性6 then
                属性6= "血上限"
        end
        if string.find(取身上武器属性(),属性) and  string.find(取身上武器属性(),属性2) and  string.find(取身上武器属性(),属性3) and  string.find(取身上武器属性(),属性4) and  string.find(取身上武器属性(),"体力")  then
        if string.find(取身上武器属性(),属性5) or string.find(取身上武器属性(),属性6) then
                        友情提示("完成啦 跳过任务")
                        return
        end
                else
                友情提示("武器不满足属性"..属性..属性2..属性3..属性4..属性5.."或"..属性6.."|开始干活")
                延时(2000)
        
        end

        装备位置名称 ="武器"
        取出物品("神兵符2级")
        取出物品("金币")
        if 获取背包物品数量("神兵符3级")< 5 then
                友情提示("没有材料")
                return
        end
        if 取所有钱()<=5*10000 then
                        return
        end

                local 装备名称= 取下装备获取名字(装备位置名称)
             延时(2000)
        友情提示(装备名称)
        if 装备名称 == 0 then
             return -1
                else
           LPindex=获取背包物品位置(装备名称)-1
        end

        跨图寻路("苏州",353,241)

        for i =1,999 do
                if 获取背包物品数量("神兵符3级")< 5 then
                        break
                end
                if 取所有钱()<=5*10000 then
                                                                break
                end
                神器炼魂(LPindex)
                延时(2000)
                友情提示(取神器炼魂后重的属性())
                延时(500)

                if string.find(取神器炼魂后重的属性(),属性) and  string.find(取神器炼魂后重的属性(),属性2) and  string.find(取神器炼魂后重的属性(),属性3) and  string.find(取神器炼魂后重的属性(),属性4)  and  string.find(取神器炼魂后重的属性(),"体力") then
                if string.find(取神器炼魂后重的属性(),属性5) or string.find(取神器炼魂后重的属性(),属性6) then
                        神器炼魂确定(LPindex)
                        break
                end
                end
                延时(2000)
        end
        穿上装备(装备位置名称,装备名称)
end





local tem =LUA_取返回值(string.format([[
	local iIceAttack  		= Player:GetData( "ATTACKCOLD" );
	local iFireAttack 		= Player:GetData( "ATTACKFIRE" );
	local iThunderAttack	= Player:GetData( "ATTACKLIGHT" );
	local iPoisonAttack		= Player:GetData( "ATTACKPOISON" );
local tt={ iIceAttack, iFireAttack, iThunderAttack,iPoisonAttack}
if iIceAttack==math.max(unpack(tt)) then
   maxOfT ="冰攻击"
elseif  iFireAttack==math.max(unpack(tt)) then
maxOfT ="火攻击"
elseif  iThunderAttack==math.max(unpack(tt)) then
maxOfT ="玄攻击"
elseif  iPoisonAttack==math.max(unpack(tt)) then
maxOfT ="毒攻击"
end

return maxOfT 
]]), "s")
属性攻击=tem
屏幕提示("属性攻击:"..属性攻击)
------------------提示(血上限跟体力默认选择)--(第五条跟第六条其中一条生效则停止)--------------
全自动神器炼魂("冰攻击","火攻击","玄攻击","毒攻击","命中","身法")