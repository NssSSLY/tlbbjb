-- 天龙小蜜 script API on top of this program's compat layer and direct game Lua.
-- tools/import-xiaomi-scripts.py only imports scripts whose calls are all defined here or in compat.lua.
-- A function whose exact 小蜜 behaviour is not known stops with its name rather than guessing.
local cfg=TaskConfig or {}
local rawLua=GetLuaValue
-- Private references: scripts redefine these globals in terms of this API (function Sleep(ms) 延时(ms) end),
-- which must not loop back into itself.
local cSleep=Sleep
local cPushDebugMessage=PushDebugMessage
local cMoveTo=MoveTo
local cTalkNpc=TalkNpc
local cQuestFrameOptionClicked=QuestFrameOptionClicked
local cQuestFrameAcceptClicked=QuestFrameAcceptClicked
local cQuestFrameNextClicked=QuestFrameNextClicked
local cQuestFrameMissionComplete=QuestFrameMissionComplete
local cBank_GetMoney=Bank_GetMoney
local cBank_SaveMoney=Bank_SaveMoney
local cBank_GetItem=Bank_GetItem
local cBank_SaveItem=Bank_SaveItem
local cDismount=Dismount
local cGetSceneID=GetSceneID
local cGetActiveSceneName=GetActiveSceneName
local cPlayer_GetPos=Player_GetPos
local cGetTeamCount=GetTeamCount
local cEnumEnvObj=EnumEnvObj
local cGetPlayerVipLevel=GetPlayerVipLevel
local cGoToSceneNPC=GoToSceneNPC
local cEquipDurability=EquipDurability
local cEquipRepairAt=EquipRepairAt
local cR=CombatRuntime
-- The resident VM has no os library; scripts read the game's clock.
os=os or {}
os.clock=os.clock or function() return GetTickCount()/1000 end
os.time=os.time or function(date)
    if date==nil then return rawLua("return os.time()","n") end
    return rawLua(string.format("return os.time({year=%d,month=%d,day=%d,hour=%d,min=%d,sec=%d})",date.year,date.month,date.day,date.hour or 12,date.min or 0,date.sec or 0),"n")
end
os.date=os.date or function(format,stamp)
    format=tostring(format or "%c")
    if format=="*t" then
        local y,m,d,h,n,sec=rawLua(string.format("local t=os.date('*t',%d) return t.year,t.month,t.day,t.hour,t.min,t.sec",math.floor(tonumber(stamp) or rawLua("return os.time()","n"))),"nnnnnn")
        return {year=y,month=m,day=d,hour=h,min=n,sec=sec}
    end
    if stamp==nil then return rawLua(string.format("return os.date(%q)",format),"s") end
    return rawLua(string.format("return os.date(%q,%d)",format,math.floor(tonumber(stamp))),"s")
end
local riskLabel={spend="允许支付",sell="允许出售",transfer="允许交易",offline="允许下线",item="允许物品处理"}
-- Direct game Lua cannot be classified per call, so a script's declared risks are checked before it starts.
function XiaomiRequire(risks)
    for _,risk in ipairs(risks) do
        if cfg["allow_"..risk]~=true then error("此小蜜文本含有"..riskLabel[risk].."类操作，请在任务设置里打开“"..riskLabel[risk].."”后再运行",0) end
    end
end
-- Same refusal as generic original tasks: nothing deletes items or friends, quits or shuts down.
local forbidden={"Discard","Destroy","QuitApplication","ShutDown","DelFriend","DeleteFriend","Dismantle"}
local function guard(code)
    code=tostring(code or "")
    for _,word in ipairs(forbidden) do
        if code:find(word,1,true) then error("小蜜文本要执行删除 / 下线 / 关机类操作（"..word.."），本程序不执行，已停止",0) end
    end
    return code
end
-- Lua 5.1 names these scripts expect.
unpack=unpack or table.unpack
table.getn=table.getn or function(t) return #t end
math.mod=math.mod or math.fmod
string.gfind=string.gfind or string.gmatch
loadstring=loadstring or function(source,name) return load(source,name,"t") end
function sleep(ms) cSleep(ms or 0) end
log=cPushDebugMessage
PushDebugMessageEx=cPushDebugMessage
function lua(code,format) return LUA_取返回值(code,format) end

-- Direct game Lua. LUA_取返回值 gives text, as scripts compare results with "0" or pass them to tonumber.
local function textOf(v)
    if v==nil then return "" end
    if type(v)=="number" and v==math.floor(v) then return string.format("%.0f",v) end
    return tostring(v)
end
function LUA_Call(code) rawLua(guard(code)) end
LUA调用=LUA_Call
function LUA_取返回值(code,format)
    code=guard(code)
    if type(format)=="string" and #format>1 then return rawLua(code,format) end
    return textOf(rawLua(code,"",1))
end

function 延时(ms) cSleep(math.floor(tonumber(ms) or 0)) end
等待=延时
function 屏幕提示(v) cPushDebugMessage(textOf(v)) return v end
输入屏幕文本=屏幕提示
友情提示=屏幕提示
屏幕输出=屏幕提示
function 信息框(v) cPushDebugMessage(textOf(v)) end
function 脚本停止() error("脚本请求停止",0) end
function 到数值(v) return tonumber(v) or 0 end
function 到整数(v) local n=tonumber(v) or 0 return n>=0 and math.floor(n) or math.ceil(n) end
function 取随机数(a,b) return math.random(math.floor(a),math.floor(b)) end
function 计算两点距离(x1,y1,x2,y2)
    x1,y1,x2,y2=tonumber(x1),tonumber(y1),tonumber(x2),tonumber(y2)
    assert(x1 and y1 and x2 and y2,"计算两点距离：坐标无效")
    return math.sqrt((x1-x2)^2+(y1-y2)^2)
end

-- Scene IDs confirmed by the reference scripts; any other map stops by name instead of routing somewhere wrong.
local scenes={["洛阳"]=0,["苏州"]=1,["大理"]=2,["楼兰"]=246,["凤鸣镇"]=850,["金陵"]=762,["钱庄"]=224,["雁南"]=18,["雁北"]=19,["无量山"]=6,["剑阁"]=7,["辽西"]=21,["太湖"]=4,["西湖"]=30,["敦煌"]=8,["嵩山"]=3,["草原"]=20,["长白山"]=22,["黄龙府"]=23,["镜湖"]=5,["龙泉"]=31,["武夷"]=32,["梅岭"]=33,["南海"]=34,["琼州"]=35,["洱海"]=24,["苍山"]=25,["石林"]=26,["玉溪"]=27,["南诏"]=28,["苗疆"]=29,["玄武岛"]=112,["圣兽山"]=201}
function 跨图寻路(map,x,y)
    local name=tostring(map or ""):gsub("%d线$","")
    local scene=scenes[name]
    if not scene then error("跨图寻路：地图尚未核对场景编号："..tostring(map),0) end
    return cMoveTo(x,y,scene)
end
function 寻路(x,y) return cMoveTo(x,y,nil) end
function 等待过图完毕()
    local last,steady=nil,0
    for _=1,60 do
        local scene=cGetSceneID()
        if scene>=0 and scene==last then steady=steady+1 else steady=0 end
        if steady>=2 then return true end
        last=scene;cSleep(500)
    end
    error("等待过图超过 30 秒",0)
end

local function windowName(name)
    name=tostring(name or "")
    assert(name:match("^[%w_]+$"),"窗口名称无效："..name)
    return name
end
-- 小蜜 returns 1 / 0 (scripts compare with ==1 and ==0; the importer rewrites bare truth tests). IsWindowShow is a boolean.
function 窗口是否出现(name)
    name=windowName(name)
    return rawLua("local e="..name.."_Env if e and e.this and e.this:IsVisible() then return 1 end return 0","n")
end
窗口是否存在=窗口是否出现
function IsWindowShow(name) return 窗口是否出现(name)==1 end
function 关闭窗口(name)
    name=windowName(name)
    rawLua("local e="..name.."_Env if e and e.this and e.this:IsVisible() then e.this:Hide() end")
end

function 对话NPC(name)
    cTalkNpc(name)
    for _=1,25 do
        if 窗口是否出现("Quest")==1 then return 1 end
        cSleep(200)
    end
    cPushDebugMessage("未确认 NPC 对话："..tostring(name))
    return 0
end
对对话NPC=对话NPC
TalkNPC=对话NPC
function NPC二级对话(option) return cQuestFrameOptionClicked(option,0) end
二级对话=NPC二级对话
function 任务_接受() return cQuestFrameAcceptClicked() end
function 任务_继续() return cQuestFrameNextClicked() end
function 任务_完成(item) return cQuestFrameMissionComplete(tonumber(item) or 0) end

-- Bag: positions are 1-based over the base bag, then the material bag (scripts subtract 1 for game calls).
local bagScan=[[-- xiaomi:bag
local name,exact=%q,%d local n,m=DataPool:GetBaseBag_Num(),DataPool:GetMatBag_Num()
if type(n)~='number' or type(m)~='number' then error('bag size unavailable') end
local count,first=0,-1
local function scan(kind,base,size)
  for i=0,size-1 do local a=PlayerPackage:EnumItem(kind,i)
    if a and a:GetID()~=0 then local s=a:GetName()
      if s==name or (exact==0 and string.find(s,name,1,true)) then
        count=count+(a:GetNum() or 1) if first<0 then first=base+i end end end end end
scan('base',0,n) scan('material',100,m)
return count,first]]
local function bagFind(name,exact)
    name=tostring(name or "")
    local count,first=rawLua(string.format(bagScan,name,exact and 1 or 0),"nn")
    assert(type(count)=="number" and type(first)=="number","背包物品读取失败："..name)
    return count,first
end
function 获取背包物品数量(name) return (bagFind(name,true)) end
function 获取背包物品位置(name) local count,first=bagFind(name,false) return count>0 and first+1 or 0 end
GetPacketNumByName=获取背包物品数量
-- Using an item that never gets used up (wrong page, cooldown) must not spin: six uses without change stop the task.
local used={}
function 右键使用物品(name)
    name=tostring(name or "")
    local count,first=bagFind(name,true)
    if count==0 then count,first=bagFind(name,false) end
    if count==0 then return false end
    local u=used[name] or {count=-1,same=0}
    u.same=u.count==count and u.same+1 or 0;u.count=count;used[name]=u
    if u.same>=6 then error(name.." 连续使用 6 次数量没有变化，已停止，避免重复操作",0) end
    rawLua(string.format("PlayerPackage:UseItem(%d)",first))
    return true
end
使用物品=右键使用物品
local function nameList(names)
    local out={}
    for n in tostring(names or ""):gsub("|"," "):gmatch("%S+") do out[#out+1]=n end
    return out
end
function 取出物品(names,count)
    local list,items={},nameList(names)
    for _,n in ipairs(items) do
        if n=="金币" then cBank_GetMoney(tonumber(count) or 99999999) else list[#list+1]=n end
    end
    if #list>0 then return cBank_GetItem(table.concat(list," "),count) end
    return true
end
function 存物品(names,except)
    local skip={};for _,n in ipairs(nameList(except)) do skip[n]=true end
    local list={}
    for _,n in ipairs(nameList(names)) do
        if n=="金币" then cBank_SaveMoney(0) elseif not skip[n] then list[#list+1]=n end
    end
    if #list>0 then return cBank_SaveItem(table.concat(list," ")) end
    return true
end
function 坐骑_下坐骑() return cDismount(500) end
下坐骑=坐骑_下坐骑

-- 获取人物信息 codes, read from how the scripts use them. An unlisted code stops by name.
local function dataOf(key) return tonumber(rawLua("return Player:GetData('"..key.."')","",1)) or 0 end
local function ratio(now,max) local m=dataOf(max) return m>0 and dataOf(now)/m or 0 end
local infoCodes={
    [3]=function() return ratio("HP","MAXHP") end,[6]=function() return ratio("MP","MAXMP") end,
    [7]=function() local x=cPlayer_GetPos() return x end,[8]=function() local _,y=cPlayer_GetPos() return y end,
    [11]=function() return dataOf("EXP") end,[12]=function() return rawLua("return Player:GetName()","s") end,
    [16]=function() return (tostring(cGetActiveSceneName()):gsub("%d线$","")) end,[17]=function() return cGetSceneID() end,
    [26]=function() return dataOf("LEVEL") end,[45]=function() return dataOf("MONEY_JZ") end,
    [46]=function() return dataOf("YUANBAO") end,[52]=function() return dataOf("MONEY") end,[57]=function() return dataOf("POINT_REMAIN") end,
}
function 获取人物信息(code)
    local read=infoCodes[tonumber(code)]
    if not read then error("获取人物信息("..tostring(code)..") 的含义尚未核对",0) end
    return read()
end
-- common.lua g_MenPaiInfo. Only name and school are readable; the importer rejects scripts that use the other
-- returned fields (PID, 远近攻击, 内外攻击, 角色账号, 门派地址, 技能状态, 性别) or compare school with a number.
local schools={[0]="少林",[1]="明教",[2]="丐帮",[3]="武当",[4]="峨嵋",[5]="星宿",[6]="天龙",[7]="天山",[8]="逍遥",[9]="无门派",[10]="慕容",[11]="唐门",[12]="鬼谷",[13]="桃花岛",[14]="绝情谷",[15]="恶人谷"}
function 获取人物属性()
    local id=dataOf("MEMPAI")
    return 获取人物信息(12),schools[id] or error("门派编号尚未核对："..tostring(id),0)
end
function 判断有无帮派()
    local read="local n=Guild:GetMyGuildDetailInfo('Name') if n and n~='' then return 1 end return 0"
    if rawLua(read,"n")==1 then return 1 end
    rawLua("Guild:AskGuildDetailInfo()");cSleep(1500)
    return rawLua(read,"n")
end
function 取金币数() return dataOf("MONEY")+dataOf("MONEY_JZ") end
function 取角色名称() return 获取人物信息(12) end

-- Script notes (读/写配置项) live in the game's Lua state: kept across tasks until the game exits, never in a file.
function 写配置项(path,section,key,value)
    rawLua(string.format("__xiaomiIni=__xiaomiIni or {} __xiaomiIni[%q]=%q",tostring(path).."|"..tostring(section).."|"..tostring(key),textOf(value)))
end
function 读配置项(path,section,key)
    return rawLua(string.format("if not __xiaomiIni then return '' end return __xiaomiIni[%q] or ''",tostring(path).."|"..tostring(section).."|"..tostring(key)),"s")
end
function 组队_是否组队() return cGetTeamCount()>0 and 1 or 0 end
function 组队_获取队伍人数() return cGetTeamCount() end
等待到指定时间=__cn_wait_until
等待队伍人数=__cn_wait_team

-- Objects near the player. IDs are client IDs; every action looks the object up again, so a stale ID does nothing.
-- Only mode 1 (named objects) is confirmed by the scripts. The returned 类别 is this program's own 怪物 / NPC; 归属,
-- 怪物判断 and 头顶标注 cannot be read, so the importer rejects scripts that use them. Players are not listed.
local function tokens(v)
    local out={}
    for s in tostring(v or ""):gmatch("[^|]+") do local t=s:gsub("^%s+",""):gsub("%s+$","") if t~="" then out[#out+1]=t end end
    return out
end
local function nearest(mode,name,range,skip,fuzzy,exclude,accept)
    if tonumber(mode)~=1 then error("遍历周围物品 模式 "..tostring(mode).." 的含义尚未核对",0) end
    range=tonumber(range) or math.huge
    local want,skipped,refused=tokens(name),{},tokens(exclude)
    for _,id in ipairs(tokens(skip)) do skipped[id]=true end
    fuzzy=fuzzy~=nil and fuzzy~=false and fuzzy~=0 and fuzzy~="" and fuzzy~="0"
    local function matches(text,list)
        for _,w in ipairs(list) do
            if text==w or (fuzzy and text:find(w,1,true)) then return true end
        end
        return false
    end
    local best
    for _,o in ipairs(cEnumEnvObj()) do
        local label=tostring(rawget(o,"name") or "")
        if (#want==0 or matches(label,want)) and not matches(label,refused) and not skipped[tostring(o.id)] and o.dst<=range and accept(o) and (not best or o.dst<best.dst) then best=o end
    end
    return best
end
function 遍历周围物品(mode,name,range,skip,fuzzy,exclude)
    local o=nearest(mode,name,range,skip,fuzzy,exclude,function() return true end)
    if not o then return "",-1,0,0,0,0,"","",0,"" end
    return o.name,o.id,o.x,o.y,o.hp,o.dst,o.class,"",0,""
end
function 遍历周围怪物(mode,name,range)
    local o=nearest(mode,name,range,nil,nil,nil,function(x) return x.hostile==1 and x.hp>0 end)
    return o and o.id or -1
end
local function objectById(id)
    id=tonumber(id)
    if not id or id<0 then return nil end
    for _,o in ipairs(cEnumEnvObj()) do if o.id==id then return o end end
end
local function selectObject(o)
    return rawLua(string.format("DataPool:SelectAsTargetByObjID(%d) local p=Target:IsPresent() if p and p~=0 and Target:GetData('NPCID')==%d then return 1 end return 0",o.server_id,o.id),"n")==1
end
function 选中对象(id)
    local o=objectById(id)
    return o and selectObject(o) and 1 or 0
end
-- One attack request on a live hostile, as CombatCast's basic attack does; false when it cannot be sent.
function 攻击怪物(id)
    local o=objectById(id)
    if not o or o.hostile~=1 or o.hp<=0 or not selectObject(o) then return false end
    return rawLua("local can=DataPool:IsCanDoAction() if not can or can==0 then return 0 end if Player:UseSkill()==1 then return 1 end return 0","n")==1
end

-- Skills: the same action-button route as CombatCast. 技能ID is the action ID.
function 获取技能ID(name)
    return rawLua(string.format("local name=%q for i=0,255 do local a=EnumAction(i,'skill') if a and a:GetID()~=0 and a:GetName()==name then return a:GetID() end end return -1",tostring(name or "")),"n")
end
local skillCast=[[local id=%d
local can=DataPool:IsCanDoAction() if not can or can==0 then return 0 end
local a=nil for i=0,255 do local t=EnumAction(i,'skill') if t and t:GetID()==id then a=t break end end
if not a then return 0 end
local cd=Lua_CheckActionItemCoolDown(id) if type(cd)~='number' then error('skill cooldown unavailable') end if cd~=0 then return 0 end
local enabled=a:IsEnable() if enabled~=1 and enabled~=true then return 0 end
local e=Packet_Env local b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end
local old=b:GetActionItem() b:SetActionItem(id) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end return 1]]
-- A script that never assigned its skill ID variable passes nil: nothing to cast.
function 使用技能(id,target)
    id=tonumber(id)
    if not id or id<=0 then return false end
    target=tonumber(target)
    if target and target>=0 then
        local o=objectById(target)
        if not o or not selectObject(o) then return false end
    end
    return rawLua(string.format(skillCast,id),"n")==1
end
function UseSkill(name,target) return 使用技能(获取技能ID(name),target) end
function 判断技能冷却(name)
    return rawLua(string.format("local name=%q for i=0,255 do local a=EnumAction(i,'skill') if a and a:GetID()~=0 and a:GetName()==name then local cd=Lua_CheckActionItemCoolDown(a:GetID()) if type(cd)~='number' then error('skill cooldown unavailable') end if cd==0 then return 1 end return 0 end end return 0",tostring(name or "")),"n")
end
function 判断人物死亡() return dataOf("HP")<=0 and 1 or 0 end

-- Buffs on the player: native Buff IDs read by identity, then Lua_GetBuffInfo's text, matched as a substring.
function 判断人物状态(name)
    local client,server=cR.host("battle_self_identity")
    local count,list=cR.host("object_buff_ids",string.format("%d:%d",client,server))
    assert(type(count)=="number" and type(list)=="string","Buff ID 不可读")
    local ids={}
    for token in list:gmatch("[^,]+") do ids[#ids+1]=math.floor(assert(tonumber(token),"Buff ID 无效")) end
    assert(#ids==count,"Buff 数量不一致")
    name=tostring(name or "")
    for first=1,#ids,8 do
        local code,returns="-- xiaomi:buff\nlocal out={} ",{}
        for j=first,math.min(first+7,#ids) do
            code=code..string.format("do local r={Lua_GetBuffInfo(%d)} local s='' for k=2,table.getn(r) do if type(r[k])=='string' then s=s..r[k]..'：' end end out[%d]=s end ",ids[j],j-first+1)
            returns[#returns+1]="out["..(j-first+1).."]"
        end
        local values=table.pack(rawLua(code.."return "..table.concat(returns,","),string.rep("s",#returns)))
        for j=1,#returns do if tostring(values[j]):find(name,1,true) then return 1 end end
    end
    return 0
end
function Player_DispelBuffByName(name)
    return rawLua(string.format("if Player:DispelBuffByName(%q) then return 1 end return 0",tostring(name or "")),"n")==1
end

-- Mission progress: -1 not accepted, 0 in progress, 1 complete (GetPlayerMission_ID / GetMissionComplete).
function 获取任务进度(id)
    id=tonumber(id)
    if not id then error("获取任务进度：任务编号无效",0) end
    return rawLua(string.format([[local id=%d
for i=0,19 do if DataPool:GetPlayerMission_InUse(i)==1 then
  local s=string.gsub(DataPool:GetPlayerMission_Name(i) or '','Mission:','')
  if tonumber(s)==id then if DataPool:GetPlayerMission_Variable(i,0)==1 then return 1 end return 0 end end end
return -1]],id),"n")
end
-- 接口说明: UseItem(方式, 物品名)。方式只决定实现路径，这里都按背包使用。
function UseItem(_,name) return 右键使用物品(name) end

-- Ground loot: nearest first, each package tried once per call, bounded so a stuck package cannot hold the script.
function 自动捡包()
    local scene=cGetSceneID()
    local ox,oy=cPlayer_GetPos()
    local function packages()
        local at,count,text=cR.host("loot_snapshot")
        local out={}
        if at~=scene or type(text)~="string" then return out end
        for line in text:gmatch("[^\n]+") do
            local kind,id,server,x,y=line:match("^(%d+)\t(%-?%d+)\t(%-?%d+)\t([^\t]+)\t([^\t]+)$")
            if kind=="3" then out[#out+1]={key=id..":"..server,x=tonumber(x),y=tonumber(y)} end
        end
        return out
    end
    local function find(key) for _,o in ipairs(packages()) do if o.key==key then return o end end end
    local function shown() return rawLua("local e=LootPacket_Env if e and e.this and e.this:IsVisible() then return 1 end return 0","n")==1 end
    local tried,taken={},0
    for _=1,16 do
        local px,py=cPlayer_GetPos()
        local target,best
        for _,o in ipairs(packages()) do
            local d=(o.x-px)^2+(o.y-py)^2
            if not tried[o.key] and (o.x-ox)^2+(o.y-oy)^2<=400 and (not best or d<best) then target,best=o,d end
        end
        if not target then break end
        tried[target.key]=true
        if best>9 then
            cR.call(cR.codes.RunTo,{scene},{target.x,target.y})
            local started=GetTickCount()
            while GetTickCount()-started<10000 do
                local x,y=cPlayer_GetPos()
                if (target.x-x)^2+(target.y-y)^2<=9 or not find(target.key) then break end
                cSleep(100)
            end
            cR.host("stop_motion")
        end
        local x,y=cPlayer_GetPos()
        if find(target.key) and (target.x-x)^2+(target.y-y)^2<=9 then
            rawLua("CloseWindow('LootPacket',true)")
            cR.host("open_loot",target.key)
            local started=GetTickCount()
            while not shown() and find(target.key) and GetTickCount()-started<5000 do cSleep(100) end
            if shown() then
                rawLua("if type(PlayerPackage.PickAllItem)~='function' then error('native PickAllItem unavailable') end PlayerPackage:PickAllItem()")
                taken=taken+1;cSleep(500)
                rawLua("CloseWindow('LootPacket',true)")
            end
        end
    end
    return taken
end
PickUp=自动捡包

-- 接口说明 CityToGuild / GuildToCity; NPCs and options from the 令牌宝珠升级 script that spells them out.
local cityNpc={["洛阳"]={"范纯仁",236,236},["苏州"]={"范纯粹",322,264},["大理"]={"范纯礼",179,121},["楼兰"]={"范纯祐",191,130}}
local function guildCity()
    if 判断有无帮派()~=1 then return nil end
    local read="local n=Guild:GetMyGuildDetailInfo('CityName') if type(n)=='string' then return n end return ''"
    local name=rawLua(read,"s")
    if name=="" or name=="-1" then
        rawLua("Guild:AskGuildDetailInfo()");cSleep(1000)
        name=rawLua(read,"s")
        关闭窗口("NewBangHui_Bhxx")
    end
    if name=="" or name=="-1" then return nil end
    return name
end
function CityToGuild()
    local city=guildCity()
    if not city then 屏幕提示("没有帮会城市") return false end
    for _=1,3 do
        local here=获取人物信息(16)
        if here==city then return true end
        local from=cityNpc[here] and here or "洛阳"
        local npc=cityNpc[from]
        跨图寻路(from,npc[2],npc[3]);cSleep(500)
        对话NPC(npc[1]);cSleep(500)
        NPC二级对话("进入本帮城市");cSleep(6000)
    end
    return 获取人物信息(16)==city
end
function GuildToCity(index)
    local city=guildCity()
    if not city or 获取人物信息(16)~=city then return true end
    local option=({[0]="回到洛阳",[1]="回到苏州",[2]="回到大理",[3]="回到楼兰"})[tonumber(index) or 0]
    if not option then error("GuildToCity 参数无效："..tostring(index),0) end
    for _=1,3 do
        寻路(100,55);cSleep(500)
        对话NPC("郑无名");cSleep(500)
        NPC二级对话("返回城市");cSleep(500)
        NPC二级对话(option);cSleep(3000)
        if 获取人物信息(16)~=city then return true end
    end
    error("没有确认离开帮会城市",0)
end

-- 校场满血, as the reference XiaoChangHuiXue: at or above the HP limit and 50% MP there is nothing to do and nothing is paid.
function LuoYangRestore(limit)
    limit=math.min(100,tonumber(limit) or 80)
    local function healthy() return ratio("HP","MAXHP")*100>=limit and ratio("MP","MAXMP")*100>=50 end
    if healthy() then return true end
    if dataOf("MONEY")+dataOf("MONEY_JZ")<20000 then error("洛阳加血：金币交子不足 2 金",0) end
    cMoveTo(185,336,0);cSleep(500)
    local started=GetTickCount()
    while not healthy() do
        if GetTickCount()-started>15000 then error("洛阳加血超时：15 秒内没有确认恢复",0) end
        对话NPC("龙霸天");cSleep(500)
        cQuestFrameOptionClicked("满状态治疗",1);cSleep(700)
        cQuestFrameOptionClicked("是",1);cSleep(700)
        对话NPC("龙霸天");cSleep(500)
        cQuestFrameOptionClicked("给珍兽恢复气血",1);cSleep(500)
        cQuestFrameOptionClicked("好的",1);cSleep(1000)
    end
    return true
end
-- Exits of the scenes cross-map routing cannot leave, from the reference leavescene.lua. Any other scene
-- has no known exit: the script goes on, and its next cross-map move fails visibly if it is really stuck.
local bossExit={[183]={91,159},[184]={98,159},[185]={95,192},[188]={89,146},[186]={96,142},[190]={95,148},[182]={96,158},[187]={44,129},[189]={96,142},[289]={160,169},[616]={173,170},[680]={98,175},[741]={274,177},[828]={148,390},[989]={56,215}}
local function waitLeft(scene,what)
    local started=GetTickCount()
    while cGetSceneID()==scene do
        if GetTickCount()-started>30000 then error("强制出副本：30 秒内没有离开"..what,0) end
        cSleep(500)
    end
end
local function leaveSpecialScene()
    local scene=cGetSceneID()
    local exit=bossExit[scene]
    if exit then
        cR.call(cR.codes.RunTo,{scene},{exit[1],exit[2]})
        waitLeft(scene,"门派 BOSS 场景")
    elseif tostring(cGetActiveSceneName()):find("苏州休息室",1,true) then
        cMoveTo(32,14,nil);对话NPC("胡小仙");cSleep(500)
        cQuestFrameOptionClicked("离开休息室",1);cSleep(700)
        cQuestFrameOptionClicked("确定",1)
        waitLeft(scene,"苏州休息室")
    elseif scene==280 then
        cMoveTo(161,162,280);对话NPC("黄龙天");cSleep(500)
        cQuestFrameOptionClicked("#{FHZD_XML_35}",1)
        waitLeft(scene,"凤凰古城")
    end
end
-- Repair at the reference thresholds and routes (rebuilt/repair.lua). 神器 and pieces out of repair counts need
-- steps this function does not take; they are named on screen and left alone.
local function repairEquipment()
    local atNpc=cGetPlayerVipLevel()<6
    local skip={[8]=true,[9]=true,[10]=true,[16]=true,[17]=true,[18]=true}
    for slot=0,21 do
        if not skip[slot] then
            local tid,name,define,left=cEquipDurability(slot,10)
            if tid~=0 and name~="" then
                if slot==0 and define>=10300000 and define<=10399999 then
                    cPushDebugMessage("修理装备："..name.." 是神器，需要手动修理")
                elseif left==0 then
                    cPushDebugMessage("修理装备："..name.." 修理次数已用完，需要润物露")
                else
                    if atNpc then cGoToSceneNPC("薛菲",354,249,1);cSleep(800) end
                    cEquipRepairAt(slot,atNpc);cSleep(500)
                end
            end
        end
    end
end
-- 执行功能 runs 小蜜's built-in functions. Only these have a meaning confirmed by the reference program; the importer
-- keeps out scripts naming any other, and a name reaching here at run time stops by name.
local builtins={
    ["同步游戏时间"]=function() cPushDebugMessage("同步游戏时间：脚本使用游戏客户端时钟") end,
    ["洛阳加血"]=function() return LuoYangRestore(80) end,
    ["强制出副本"]=leaveSpecialScene,
    ["修理装备"]=repairEquipment,
}
function 执行功能(name)
    local run=builtins[name]
    if not run then error("执行功能尚未接入："..tostring(name),0) end
    return run()
end
