-- 游戏内 Lua 5.4 常驻执行的扩展。GetLuaValue 是直调，不经过旧文本白名单解析。
local nativeObjects=__objects
local oldLoad=LoadScript
local loaded,executing={},{}
local afterLoad
local function moduleName(name)
    assert(type(name)=="string" and #name>0 and #name<=192,"模块名称无效")
    name=name:match("^%s*(.-)%s*$"):gsub("%.lua$","")
    assert(name~="" and not name:find("[/%\\%z]") and not name:find("..",1,true),"模块名称不能包含路径")
    return name
end
local function execute(name,cache)
    name=moduleName(name)
    if cache and loaded[name] then return end
    assert(not executing[name],"模块循环引用："..name)
    local source=(__resident_modules or {})[name]
    if source==nil then
        local token=(__original_names or {})[name]
        if token then return RunOriginalRule(token,cache) end
        return oldLoad(name=="科举" and "科举.lua" or name)
    end
    local chunk,why=load(source,"="..name,"t",_G)
    assert(chunk,why)
    executing[name]=true
    local result=table.pack(pcall(chunk)) -- pcall is yieldable in the resident Lua 5.4 VM.
    executing[name]=nil
    if not result[1] then error(result[2],0) end
    if afterLoad then afterLoad(name) end
    if cache then loaded[name]=true end
    return table.unpack(result,2,result.n)
end
-- CExec executes each explicit invocation. LoadScript keeps our shared-module cache.
-- Neither retries a failed/uncertain invocation or reads arbitrary files during a task.
function CExec(name) return execute(name,false) end
function LoadScript(name) return execute(name,true) end
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local digits={};for i=1,#alphabet do digits[alphabet:byte(i)]=i-1 end
local compiled,originalLoaded,originalExecuting={},{},{}
local function decode64(encoded)
    assert(type(encoded)=="string" and #encoded<=350000 and #encoded%4==0,"原 Lua 编码无效")
    local out={}
    for i=1,#encoded,4 do
        local a,b,c,d=encoded:byte(i,i+3)
        assert(digits[a] and digits[b] and (digits[c] or c==61) and (digits[d] or d==61),"原 Lua 编码字符无效")
        assert(c~=61 or d==61,"原 Lua 编码填充无效")
        assert((c~=61 and d~=61) or i+3==#encoded,"原 Lua 编码填充位置无效")
        local n=(digits[a]<<18)|(digits[b]<<12)|((digits[c] or 0)<<6)|(digits[d] or 0)
        out[#out+1]=string.char((n>>16)&255)
        if c~=61 then out[#out+1]=string.char((n>>8)&255) end
        if d~=61 then out[#out+1]=string.char(n&255) end
    end
    return table.concat(out)
end
function RunOriginalRule(token,cache)
    assert(type(token)=="string" and token:match("^[a-f0-9]+$") and #token==8,"原 Lua 标识无效")
    if cache and originalLoaded[token] then return end
    assert(not originalExecuting[token],"原 Lua 循环引用："..token)
    local chunk=compiled[token]
    if not chunk then
        local data=decode64(assert((__original_rules or {})[token],"本任务未声明此原 Lua 依赖："..token))
        local binary=data:sub(1,1)=="\27"
        assert(not binary or data:sub(1,5)=="\27Lua\84","原 Lua 字节码 ABI 无效")
        chunk=assert(load(data,"@original/"..token,binary and "b" or "t",_G));compiled[token]=chunk
    end
    originalExecuting[token]=true
    local result=table.pack(pcall(chunk));originalExecuting[token]=nil
    if not result[1] then error(result[2],0) end
    if cache then originalLoaded[token]=true end
    return table.unpack(result,2,result.n)
end
CSleep=Sleep
function EnumObjects() return nativeObjects() end
local alive={}
local withPlayers=false -- set while an Enum2X call asks for the 玩家 class
-- Fields the reference objects carried that this program cannot read yet. Reading one stops the task by name;
-- a nil here would make comparisons such as tBoss.target==Player:GetTID() silently false and skip mechanics.
local unreadableFields={target="当前攻击目标",title="称号（如少室山“对萧远山造成伤害”）",state="对象状态",level="等级",menpai="门派",guid="GUID",mp="蓝量",mpp="蓝量百分比",baseptr="内存地址"}
__missingObjectFields={__index=function(o,key)
    local what=unreadableFields[key]
    if what then error("对象字段读取尚未接入："..key.."（"..what.."，"..tostring(rawget(o,"name") or "?").."）",0) end
end}
function EnumEnvObj()
    local result,nextAlive=nativeObjects(),{}
    for _,obj in ipairs(result) do
        local identity=tostring(obj.id)..":"..tostring(obj.server_id)
        local hostile=obj.hostile==1 or (obj.hp==0 and alive[identity])
        if obj.hp>0 and obj.hostile==1 then nextAlive[identity]=true end
        if obj.hp==0 and alive[identity] then nextAlive[identity]=true end
        obj.class=hostile and "怪物" or "NPC"
        setmetatable(obj,__missingObjectFields)
    end
    alive=nextAlive -- only identities in this bounded snapshot survive.
    if withPlayers then for _,p in ipairs(__playerObjects()) do result[#result+1]=p end end
    return result
end
Team=Team or {}
function Team:GetMemberCount() return GetTeamCount() end
-- Game UI exposes basic roster data independently of the reference DLL.
-- This deliberately returns only fields the game API supplies; it is not a
-- substitute for EnumMemberInfo's coordinates, scene, GUID or HP fields.
function Team:GetBasicMembers()
    local count=GetTeamCount()
    local members={}
    for index=0,count-1 do
        local code=string.format([[
            local name,school,level,dead,offline=DataPool:GetTeamMemInfoByIndex(%d)
            local function flag(v)
                if v==true or v==1 then return 1 end
                if v==false or v==0 then return 0 end
                error('team member state unavailable')
            end
            return name,school,level,flag(dead),flag(offline)
        ]],index)
        local name,school,level,dead,offline=GetLuaValue(code,"snnnn")
        assert(type(name)=="string" and name~="" and #name<=192,"队员名称不可读")
        assert(type(school)=="number" and school==math.floor(school),"队员门派不可读")
        assert(type(level)=="number" and level==math.floor(level) and level>=0,"队员等级不可读")
        members[#members+1]={index=index,name=name,menpai=school,level=level,
                             dead=dead==1,offline=offline==1}
    end
    return members
end
afterLoad=function(name)
    if name~="original_filters" then return end
    local originalName,originalClass=Enum2XByName,Enum2XByClass
    -- mask: NPC, 怪物, 玩家, 珍兽, 宝箱. Players come from __playerObjects when the task provides it.
    local function classes(mask)
        if type(mask)~="table" then return false end
        assert(mask[3]==nil or mask[3]==0 or type(__playerObjects)=="function","玩家对象枚举尚未适配")
        for i=4,6 do assert(mask[i]==nil or mask[i]==0,"珍兽 / 包裹对象枚举尚未适配") end
        return mask[3]==1
    end
    Enum2XByName=function(name,mask,...)
        if not classes(mask) then return originalName(name,mask,...) end
        withPlayers=true;local ok,result=pcall(originalName,name,mask,...);withPlayers=false
        if not ok then error(result,0) end return result
    end
    Enum2XByClass=function(kind,...)
        assert(type(kind)=="string","对象类型尚未接入："..tostring(kind))
        local count,players=0,false
        for class in kind:gmatch("%S+") do
            if class=="玩家" then assert(type(__playerObjects)=="function","玩家对象枚举尚未适配");players=true
            else assert(class=="NPC" or class=="怪物","对象类型尚未接入："..class) end
            count=count+1
        end
        assert(count>0,"对象类型不可为空")
        if not players then return originalClass(kind,...) end
        withPlayers=true;local ok,result=pcall(originalClass,kind,...);withPlayers=false
        if not ok then error(result,0) end return result
    end
end
local function filters()
    LoadScript("original_filters") -- original 5-argument filters, not a rewritten subset
    return Enum2XByName,Enum2XByClass
end
function Enum2XByName(...) local byName=filters();return byName(...) end
function Enum2XByClass(...) local _,byClass=filters();return byClass(...) end
-- Player 数据键不再逐个编译放行；游戏已注册的标量数据可以直接读取。
Player.GetData=function(_,key) return GetLuaValue("return Player:GetData("..string.format("%q",key)..")","",1) end
Player.GetDataInt=Player.GetData
Game={Lua=GetLuaValue,Objects=EnumObjects}
-- Lazy adapters avoid scanning skills for unrelated daily tasks.
skilllib={}
for _,name in ipairs({"CEnumSkill","CGetCD","CUseSkillByID","CUseSkillByID2","CUseSkillByID_fb"}) do
    skilllib[name]=function(...) LoadScript("original_skill_host");return skilllib[name](...) end
end
playerlib={CGetPos=function() local x,y=Player_GetPos();assert(x>=0 and y>=0,"角色坐标不可读");return {x=x,y=y} end,
    CGetTargetID=function() return GetLuaValue("local p=Target:IsPresent() if not p or p==0 then return -1 end return Target:GetData('NPCID')","n") end}
