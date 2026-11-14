-- Generic host: runs one original task chunk unchanged.
-- The original framework modules it needs (common/common_2/bag/functions ...) load into a side
-- environment; only globals this program does not already provide are imported, so the original
-- helpers call our movement / dialog / bank implementations underneath.
-- Natives the reference program supplied (ReadConfig*, baglib, playerlib, me* game helpers ...) are
-- provided here; deletion, shutdown and quitting stay refused.
local entry=assert(__original_entry,"缺少原规则入口声明")
local cfg=TaskConfig or {}
local rawLua=GetLuaValue
local rawLoad=LoadScript
local logLine=PushDebugMessage or function() end

-- 1. Forbidden game operations: deleting items / friends, quitting, shutting down.
local forbidden={"Discard","Destroy","QuitApplication","ShutDown","DelFriend","DeleteFriend","Dismantle"}
local function guard(code)
    for _,word in ipairs(forbidden) do
        if string.find(code,word,1,true) then error("原脚本要执行删除 / 下线 / 关机类操作（"..word.."），本程序不执行，已停止",0) end
    end
end

-- 2. The reference program's helpers inside game Lua (me*), prepended per call as locals.
local helpers={
    meTestMsg="local function meTestMsg() end",
    meGetDictionaryString="local function meGetDictionaryString(k) if GetDictionaryString then return GetDictionaryString(k) or k end return k end",
    -- Mission accessors read the current DataPool directly; validate the live slots.
    meRefreshMission=[[local meRefreshMission=meRefreshMission or function()
        for i=0,19 do local used=DataPool:GetPlayerMission_InUse(i)
            if used~=0 and used~=1 then error('mission slot state unavailable') end
        end
    end]],
    meReliveHandle=[[local meReliveHandle=meReliveHandle or function(kind)
        local hp=Player:GetData('HP')
        if type(hp)~='number' or hp<0 then error('player health unavailable') end
        if hp==0 and kind==-1 then local e=Relive_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.Relive_Out_Ghost() end end
    end]],
    meBuyShopItem=[[local function meBuyShopItem(name,num) local n=0
        for _=1,num or 1 do local hit=false
            for i=0,35 do local a=EnumAction(i,'boothitem') if a and a:GetID()~=0 and a:GetName()==name then NpcShop:BulkBuyItem(i,1,0) hit=true n=n+1 break end end
            if not hit then break end end
        return n end]],
    meGetBagSpaceNum=[[local function meGetBagSpaceNum(kind) local bag,n='base',DataPool:GetBaseBag_Num()
        if kind==1 then bag,n='material',DataPool:GetMatBag_Num() end local c=0
        for i=0,n-1 do local a=PlayerPackage:EnumItem(bag,i) if not a or a:GetID()==0 then c=c+1 end end return c end]],
}
-- Team:GetAllInfo parses "name&index&level&menpai" records separated by spaces.
helpers.meGetAllTeamInfo=[[local function meGetAllTeamInfo() local n=DataPool:GetTeamMemberCount()
    if type(n)~='number' or n<0 or n>6 then error('team count unavailable') end local t=''
    for i=0,n-1 do local name,school,level=DataPool:GetTeamMemInfoByIndex(i)
        if type(name)~='string' or name=='' or type(level)~='number' then error('team member unavailable') end
        t=t..name..'&'..i..'&'..level..'&'..tostring(school)..' ' end
    return t end]]
-- Team:IsHaveMenpai expects the member index with that school, or -1.
helpers.meIsTeamHaveMenpai=[[local function meIsTeamHaveMenpai(id) local n=DataPool:GetTeamMemberCount()
    if type(n)~='number' or n<0 or n>6 then error('team count unavailable') end
    for i=0,n-1 do local name,school=DataPool:GetTeamMemInfoByIndex(i)
        if type(name)~='string' or name=='' then error('team member unavailable') end
        if school==id then return i end end
    return -1 end]]
-- daguai checks pet happiness every cycle with the configured GUID; 0/-1 means no pet is configured, so
-- there is nothing to feed. A real GUID would need the reference program's GUID encoding, not mapped yet.
for _,name in ipairs({'mePetGetHappy','mePetCheckHappy'}) do
    helpers[name]='local function '..name..'(guid) if guid==0 or guid==-1 then return 100,-1 end '
        ..'error("原程序游戏内辅助函数未接入：'..name..'（已配置珍兽 GUID）") end'
end
-- pet.lua Pet:Relax: recall the pet that is out, through the game's own 珍兽休息 action (the same
-- route DungeonPetGuard uses). Returns true when the recall was issued, false when nothing could be done.
helpers.mePetRelax=[[local function mePetRelax()
    local a=Pet and Pet.GetPetRelaxAction and Pet:GetPetRelaxAction()
    if not a or type(a.GetID)~='function' then return false end
    local id=a:GetID() if type(id)~='number' or id<=0 then return false end
    local b=Packet_Env and Packet_Env.Packet_Space_Line10_Row10_button
    if not b then return false end
    local previous=b:GetActionItem() b:SetActionItem(id)
    local ok=pcall(b.DoAction,b) b:SetActionItem(previous)
    return ok end]]
for _,name in ipairs({'meIsNeedCheckMibao','meIsUnlockMibao','meUnLockMibao','meIsMissionOutline'}) do
    helpers[name]='local '..name..'='..name..' or function() error("原生接口未接入：'..name..'") end'
end
local observedScene,sceneSince
local function withHelpers(code)
    local prelude={}
    if code:find('meGetSceneTransTime',1,true) then
        local scene=GetSceneID()
        assert(type(scene)=='number' and scene>=0,'转场时间：当前场景不可读')
        local now=GetTickCount()
        if scene~=observedScene then observedScene,sceneSince=scene,now end
        prelude[#prelude+1]=string.format('local function meGetSceneTransTime() return %.3f end local function meGetSceneTransTimeDiff() return %.3f end',sceneSince/1000,(now-sceneSince)/1000)
    end
    for name,source in pairs(helpers) do if string.find(code,name,1,true) then prelude[#prelude+1]=source end end
    -- Any other reference-program helper would fail inside game Lua with an unclear nil call.
    for name in code:gmatch("%f[%w_](me%u[%w_]*)") do
        if not helpers[name] and not name:find("^meGetSceneTransTime") then error("原程序游戏内辅助函数未接入："..name,0) end
    end
    if #prelude==0 then return code end
    return table.concat(prelude,"\n").."\n"..code
end
function GetLuaValue(code,...)
    code=tostring(code or "");guard(code)
    -- IsMount and player.lua query Buffs through this game helper; answer it with the identity-checked reader.
    local buff=code:match("^%s*return%s+mePlayerGetBuff%(%[%[(.-)%]%]%);?%s*$")
    if buff then return Player.GetBuff(Player,buff) end
    return rawLua(withHelpers(code),...)
end

-- 3. Original configuration readers: values come from this task's settings in the UI.
local function value(key) return cfg[tostring(key)] end
function ReadConfigText(_,key)
    local v=value(key);if v==nil then return "" end
    if type(v)=='table' then assert(type(v.text)=='string','文本配置缺少 text：'..tostring(key));return v.text end
    return tostring(v)
end
function ReadConfigInt(_,key)
    local v=value(key);if type(v)=='table' then v=v.sel;assert(type(v)=='number','整数配置缺少 sel：'..tostring(key)) end
    if type(v)=="boolean" then return v and 1 or 0 end return math.floor(tonumber(v) or 0)
end
function ReadConfigBool(_,key)
    if entry.original_token=="00267ca1" and (key=="购买定位" or key=="制作定位") then return false end
    local v=value(key);if type(v)=="string" then return v=="1" or v=="true" end
    if type(v)=="number" then return v~=0 end return v==true
end
function GetConfigInt(_,name) return ReadConfigInt(nil,name) end
function GetConfigBool(_,name) return ReadConfigBool(nil,name) end
rawLoad('original_config')
-- The reference program's pet selections hold the pet GUID in data; this program offers no pet selection,
-- so an unset one is "no pet" (GUID 0), which the original framework skips.
local petSelections={["出战珍兽"]=true,["共生珍兽"]=true,["血祭珍兽"]=true}
-- The protect page's pet medicine types are only used with a buy count; unset means none chosen.
local emptySelections={["珍兽药_类1"]=true,["珍兽药_类2"]=true,["珍兽丹药_类"]=true}
function GetConfigCommbox(_,name)
    if petSelections[name] and value(name)==nil then return {sel=-1,text="",data=0} end
    if emptySelections[name] and value(name)==nil then return {sel=-1,text="",data=""} end
    return OriginalConfig.combo(value(name),(__original_entry.config_shapes or {})[name],name)
end
function GetConfigList(_,name) return OriginalConfig.list(value(name),name) end
GetConfigListCtrlEx=GetConfigList
function GetItemConfigText(_,name) return ReadConfigText(nil,name) end
function GetConfigPath() return "" end
-- The reference program's per-character 运行配置.ini (e.g. 种地记录). Kept for this run only: after a
-- restart the script finds no record and takes its own "no record" branch, as with a new character.
do
    local records={}
    function PlayerConfigGet(key,app) return records[tostring(app).."\0"..tostring(key)] or "" end
    function PlayerConfigSet(key,text,app) records[tostring(app).."\0"..tostring(key)]=tostring(text or "") end
end
local selectedDungeonConfig = ({["00320005"]=true,["00313c18"]=true,["002e1226"]=true,["002ef962"]=true,["002fef1e"]=true})[entry.original_token] == true
function GetUserConfig(key) if (selectedDungeonConfig or entry.original_token=="0034fff0") and key=="CONFIG_PATH" then return "" end return nil end

-- 4a. Team and Buff natives rebuilt on this program's identity-checked readers.
local function whole(v,low,high) return type(v)=="number" and v==math.floor(v) and v>=low and v<=high end
-- EnumMemberInfo(1): the game's team records, plus positions of members in this scene from the native player
-- snapshot. id is the server ID (what Player:GetTID returns here); client_id/server_id identify the object.
function EnumMemberInfo(kind)
    if kind==2 then error("团队（多队）成员读取尚未接入：EnumMemberInfo(2)",0) end
    assert(kind==nil or kind==1,"EnumMemberInfo 参数无效："..tostring(kind))
    local count,text=rawLua([[-- generic:team-members
        local n=DataPool:GetTeamMemberCount()
        if type(n)~='number' or n~=math.floor(n) or n<0 or n>6 then error('team count unavailable') end
        local line=-1 if GetSceneServerID then line=GetSceneServerID() end
        local rows='' local seen={}
        for i=0,n-1 do
            local name,school,hp,maxhp=DataPool:GetTeamMemberInfo(i)
            local _,_,level,dead,offline=DataPool:GetTeamMemInfoByIndex(i)
            local server,identity=DataPool:GetTeamMemberObjIDNamePortInfo(i)
            local guid=DataPool:GetTeamMemGUIDByUIIndex(i)
            local inside=DataPool:IsTeamMemberInScene(i)
            inside=(inside==1 or inside==true) and 1 or 0
            local function flag(v) if v==true or v==1 then return 1 end if v==false or v==0 or v==nil then return 0 end error('team member state unavailable') end
            dead,offline=flag(dead),flag(offline)
            if type(name)~='string' or name=='' or name~=identity or guid==nil or seen[name] then error('team identity unavailable') end
            seen[name]=true
            if type(server)~='number' or server~=math.floor(server) or server<-1 then error('team object ID unavailable') end
            local client=-1
            if inside==1 and server>=0 then client=Target:GetServerId2ClientId(server)
                if type(client)~='number' or client~=math.floor(client) or client<-1 then error('team client ID unavailable') end
                if type(hp)~='number' or type(maxhp)~='number' or hp<0 or maxhp<=0 or hp>maxhp then error('team health unavailable') end
            else hp=-1 maxhp=-1 end
            rows=rows..i..'\t'..name..'\t'..tostring(guid)..'\t'..string.format('%.0f\t%.0f\t%.0f\t%.0f',server,client,hp,maxhp)..'\t'
                ..inside..'\t'..tostring(school)..'\t'..tostring(level or 0)..'\t'..line..'\t'..dead..'\t'..offline..'\n'
        end
        if DataPool:GetTeamMemberCount()~=n then error('team changed during read') end
        return n,rows]],"ns")
    assert(whole(count,0,6) and type(text)=="string","队伍成员不可读")
    local scene,positions=GetSceneID(),{}
    if count>0 then
        local snapScene,_,rows=CombatRuntime.host("mechanism_snapshot")
        assert(snapScene==scene and type(rows)=="string","队员位置快照不可读")
        for k,client,server,x,y in rows:gmatch("(%d+)\t(%-?%d+)\t(%-?%d+)\t([^\t]+)\t([^\n]+)\n") do
            if k=="1" then positions[tonumber(server)]={x=tonumber(x),y=tonumber(y)} end
        end
    end
    local own=playerlib.CGetPos();local _,ownServer=CombatRuntime.host("battle_self_identity")
    local members={}
    for index,name,guid,server,client,hp,maxhp,inside,school,level,line,dead,offline in
        text:gmatch("(%d+)\t([^\t]+)\t([^\t]+)\t(%-?%d+)\t(%-?%d+)\t(%-?%d+)\t(%-?%d+)\t(%d)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([01])\t([01])\n") do
        server,client,hp,maxhp=tonumber(server),tonumber(client),tonumber(hp),tonumber(maxhp)
        local here=inside=="1"
        local pos=server==ownServer and own or (here and positions[server]) or nil
        -- Off-scene members have no object here: id -1 and HP unknown (-1), so the original's death test
        -- (id>0 and hp==0) only fires for a member who is in this scene with zero health.
        local m={teamIndex=tonumber(index),name=name,guid=tonumber(guid) or guid,id=here and server or -1,server_id=server,client_id=client,
            menpai=tonumber(school) or -1,level=tonumber(level) or 0,leader=tonumber(index)==0 and 1 or 0,
            inScene=here,dead=dead=="1",offline=offline=="1",
            sceneID=here and scene or -1,mapID=here and (tonumber(line) or -1) or -1,
            hpcur=here and hp or -1,hpmax=here and maxhp or 0,hp=(here and maxhp>0) and hp*100/maxhp or -1,
            x=pos and pos.x or 0,y=pos and pos.y or 0}
        m.dst=pos and math.sqrt((m.x-own.x)^2+(m.y-own.y)^2) or 9999
        members[#members+1]=m
    end
    assert(#members==count,"队伍成员数量不一致")
    return members
end
-- 矿地 objects for Enum2X*: ore / herb spots and farm fields (CTripperObject_Resource). Name and the
-- resource type come from the game's resource definition; zwType is that type (710000 ore, 711001 growing,
-- 711002 ripe crop), which the original planting script compares directly.
function __resourceObjects()
    local scene,count,rows=CombatRuntime.host("resource_objects")
    assert(scene==GetSceneID() and whole(count,0,512) and type(rows)=="string","矿地对象快照不可读")
    local own=playerlib.CGetPos();local out={}
    for client,server,x,y,kind,name in rows:gmatch("(%-?%d+)\t(%-?%d+)\t([^\t]+)\t([^\t]+)\t(%-?%d+)\t([^\n]*)\n") do
        client,server,x,y,kind=tonumber(client),tonumber(server),tonumber(x),tonumber(y),tonumber(kind)
        out[#out+1]=setmetatable({id=client,server_id=server,class="矿地",x=x,y=y,dst=math.sqrt((x-own.x)^2+(y-own.y)^2),
            name=name,zwType=kind,type=kind,hp=100,hostile=0},__missingObjectFields)
    end
    assert(#out==count,"矿地对象数量不一致")
    return out
end
-- 玩家 objects for Enum2X*: other players in this scene from the native snapshot; team members carry the
-- roster's name/HP/school, others the game's name for that object. MP is not readable and says so.
function __playerObjects()
    local scene,count,rows=CombatRuntime.host("mechanism_snapshot")
    assert(scene==GetSceneID() and whole(count,0,512) and type(rows)=="string","玩家对象快照不可读")
    local own=playerlib.CGetPos();local team={}
    for _,m in ipairs(EnumMemberInfo(1)) do team[m.server_id]=m end
    local out,unnamed={},{}
    for k,client,server,x,y in rows:gmatch("(%d+)\t(%-?%d+)\t(%-?%d+)\t([^\t]+)\t([^\n]+)\n") do
        if k=="1" then
            client,server,x,y=tonumber(client),tonumber(server),tonumber(x),tonumber(y)
            local m=team[server]
            local o=setmetatable({id=client,server_id=server,class="玩家",x=x,y=y,dst=math.sqrt((x-own.x)^2+(y-own.y)^2),
                name=m and m.name or nil,hp=m and m.hp or -1,menpai=m and m.menpai or nil,level=m and m.level or nil,hostile=0},__missingObjectFields)
            out[#out+1]=o;if not o.name then unnamed[#unnamed+1]=o end
        end
    end
    for first=1,#unnamed,32 do
        local terms={};for j=first,math.min(first+31,#unnamed) do terms[#terms+1]="(Target:GetNpcName("..unnamed[j].id..") or '')" end
        local names=table.pack(rawLua("return "..table.concat(terms,","),string.rep("s",#terms)))
        for j=1,#terms do unnamed[first+j-1].name=tostring(names[j] or "") end
    end
    return out
end
-- Buff text per object: the native Buff-ID tree read by identity, then Lua_GetBuffInfo's strings joined with "："
-- so both names ("千蛛万毒") and descriptive fragments ("定身：无法移动") match as substrings.
local function buffTexts(client,server)
    assert(whole(client,-1,2147483647) and whole(server,-1,2147483647),"Buff 对象身份无效")
    local count,text=CombatRuntime.host("object_buff_ids",string.format("%d:%d",client,server))
    assert(whole(count,0,256) and type(text)=="string","Buff ID 不可读")
    local ids={};for token in text:gmatch("[^,]+") do local n=tonumber(token);assert(whole(n,0,2147483647),"Buff ID 无效");ids[#ids+1]=n end
    assert(#ids==count,"Buff 数量不一致")
    local out={}
    for first=1,#ids,8 do
        local code,returns="-- generic:buff-text\nlocal out={} ",{}
        for j=first,math.min(first+7,#ids) do
            code=code..string.format("do local r={Lua_GetBuffInfo(%d)} local s='' for k=2,table.getn(r) do if type(r[k])=='string' and r[k]~='' then if s~='' then s=s..'：' end s=s..r[k] end end out[%d]=s end ",ids[j],j-first+1)
            returns[#returns+1]="out["..(j-first+1).."]"
        end
        local values=table.pack(rawLua(code.."return "..table.concat(returns,","),string.rep("s",#returns)))
        for j=1,#returns do assert(type(values[j])=="string" and values[j]~="","Buff 文本不可读："..ids[first+j-1]);out[#out+1]=values[j] end
    end
    return out
end
function EnumObjBuff(obj)
    assert(type(obj)=="table","Buff 对象无效")
    local client,server=obj.client_id or obj.id,obj.server_id
    assert(client~=nil and server~=nil,"对象缺少身份，Buff 不可读："..tostring(obj.name))
    return buffTexts(client,server)
end
function CEnumObjBuff() error("原程序按内存地址读取 Buff 的接口不使用；请经 EnumObjBuff(对象) 读取",0) end
local function playerGetBuff(_,name)
    name=tostring(name or "")
    for i,t in ipairs(buffTexts(-1,-1)) do if t:find(name,1,true) then return i-1,t,0 end end
    return -1,"",0
end
Player.GetBuff=playerGetBuff -- defined before player.lua loads, so its mePlayerGetBuff version is not imported

-- 4. Native functions of the reference program.
local function missing(name) return function() error("原程序原生函数未接入："..name,0) end end
for _,name in ipairs({"BagBankTempMove","EnumMemberInfo","CallFun","HelpFun","R_M","SetThreadKeyState","runScript",
    "GetOpenLootID","GetMiJiSkillIndex","CEnumObjBuff","DoSystem_old"}) do if _G[name]==nil then _G[name]=missing(name) end end
if entry.original_token=="00320005" then
    Pet=Pet or {}
    function Pet:GetSelfPet()
        if Player:GetFightPetGUID()==-1 then return nil end
        error("已出战珍兽的场景对象读取尚未接入（Pet:GetSelfPet）",0)
    end
end
local function noDelete() error("原脚本要删除物品，本程序不执行删除类操作，已停止",0) end
DiscardBagItem,DiscardTempBagItem,ShutDown=noDelete,noDelete,function() error("原脚本要关机，本程序不执行，已停止",0) end
-- DoSystem(22) is GetMainPath: the reference program's folder. Its data\坐标 route files are served below.
function DoSystem(kind) if kind==4 then return end if kind==22 then return "original\\" end error("原程序系统操作未接入：DoSystem("..tostring(kind)..")",0) end
function GetPlayerState() return rawLua("if not Player or type(Player.GetState)~='function' then return -1 end return Player:GetState()","n") end
if entry.original_token=="00320005" then Player.GetHPP=function() return GetHPPercent() end end
if entry.original_token=="00320005" then Player.GetMPP=function() return GetMPPercent() end end
-- Every task reads the fighting pet through the native-level reader (playerlib.CGetFightPetGUID below): -1 for
-- none, the GUID when one is out. The earlier per-task copy stopped as soon as a pet was out.
function Player:GetFightPetGUID() return playerlib.CGetFightPetGUID() end
if selectedDungeonConfig then local oldClearBag=ClearBag; ClearBag=function(...) local space=Bag:GetSpaceNum(0); if type(space)=="number" and space>0 then return true end; return oldClearBag(...) end end
if entry.original_token=="00320005" or entry.original_token=="00313c18" or entry.original_token=="002cf5a7" or entry.original_token=="002b54ac" or entry.original_token=="0031c749" or entry.original_token=="0031db5f" or entry.original_token=="002bba5a" or entry.original_token=="002fd257" or entry.original_token=="002bb430" or entry.original_token=="002fe064" or entry.original_token=="002fe6b9" then Player.IsLeader=function() local n=tonumber(rawLua("return tonumber(Player:IsLeader())","n")); assert(n==0 or n==1,"cannot read team leader state"); return n==1 end end
function TableCount(t) local n=0 if type(t)=="table" then for _ in pairs(t) do n=n+1 end end return n end
-- Scene numbers confirmed in this project (小蜜 route table + 清剿九黎余孽 NPC list).
local scenes={["洛阳"]=0,["苏州"]=1,["大理"]=2,["楼兰"]=246,["凤鸣镇"]=850,["金陵"]=762,["钱庄"]=224,["雁南"]=18,["雁北"]=19,["无量山"]=6,["剑阁"]=7,["辽西"]=21,["太湖"]=4,["西湖"]=30,["敦煌"]=8,["嵩山"]=3,["草原"]=20,["长白山"]=22,["黄龙府"]=23,["镜湖"]=5,["龙泉"]=31,["武夷"]=32,["梅岭"]=33,["南海"]=34,["琼州"]=35,["洱海"]=24,["苍山"]=25,["石林"]=26,["玉溪"]=27,["南诏"]=28,["苗疆"]=29,["玄武岛"]=112,["圣兽山"]=201,["漠南青原"]=855,["忘川花海"]=856,["天岐南淮"]=857}
function CGetSceneIDByName(name)
    -- Originals cut names after "级" assuming 2-byte GBK; in UTF-8 that leaves a stray byte in front.
    name=tostring(name or ""):gsub("^[\128-\191]+",""):gsub("%d线$","")
    local id=scenes[name]
    if id then return id end
    if GetSceneName and GetSceneName()==name then return GetSceneID() end
    -- Same as the original: -1 for a name it does not know; the script decides what that means.
    return -1
end
-- The reference program kept per-character text files under g_public_dir; none exist here and io.open finds
-- nothing, so scripts take their own "file missing" branch.
g_public_dir=g_public_dir or ""
io=io or {open=function() return nil end,close=function() end,lines=function() return function() return nil end end}
-- Read-only access to the reference program's route files shipped with tasks that use them
-- (__original_coords, e.g. 采集脚本: GetMainPath().."data\\坐标\\<map>.txt"); every other path stays absent.
do
    local open,close=io.open,io.close
    io.open=function(path,mode)
        local name=tostring(path or ""):match("^original\\data\\坐标\\(.+)%.txt$")
        if name and (mode==nil or mode=="r") and type((__original_coords or {})[name])=="string" then
            local text=__original_coords[name]
            local file={}
            function file:read(format) local t=text;text=nil;return t end
            function file:close() return true end
            function file:lines() local rest=text or "";text=nil;return rest:gmatch("[^\n]+") end
            return file
        end
        return open(path,mode)
    end
    io.close=function(file) if type(file)=="table" and file.close then return file:close() end return close(file) end
end
os=os or {}
os.clock=os.clock or function() return GetTickCount()/1000 end
os.time=os.time or function() local v=rawLua("if os and os.time then return os.time() end return 0","n");return v end
os.date=os.date or function(fmt) local v=rawLua("if os and os.date then return os.date("..string.format("%q",tostring(fmt or "%c"))..") end return ''","s");return v end

-- os.date("*t", stamp) / os.time{...} in the game's clock for every task (天降奇兽 computes its time windows
-- with them); the plain replacement above returns a string and ignores the stamp.
do
    local defaultDate,defaultTime=os.date,os.time
    os.date=function(format,stamp)
        if format~="*t" then
            if stamp==nil then return defaultDate(format) end
            -- Other formats with a time (刷马: os.date("%H", t)) format that time, not now.
            stamp=tonumber(stamp)
            assert(stamp and stamp==math.floor(stamp) and stamp>=0 and stamp<=253402300799,"指定时间无效")
            local text=rawLua(string.format("return os.date(%q,%d)",tostring(format or "%c"),stamp),"s")
            assert(type(text)=="string","服务器日期格式化失败")
            return text
        end
        if stamp==nil then stamp=defaultTime() end -- os.date("*t") is "now"
        stamp=tonumber(stamp)
        assert(stamp and stamp==math.floor(stamp) and stamp>=0 and stamp<=253402300799,"服务器时间不可读")
        local y,m,d,h,minute,sec=rawLua(string.format([[local t=os.date("*t",%d)
            if type(t)~="table" then error("server date unavailable") end
            return t.year,t.month,t.day,t.hour,t.min,t.sec]],stamp),"nnnnnn")
        for _,v in ipairs({y,m,d,h,minute,sec}) do assert(type(v)=="number" and v==math.floor(v),"服务器日期字段不可读") end
        assert(y and m and d and h and minute and sec and y>=1970 and y<=9999 and m>=1 and m<=12 and d>=1 and d<=31 and h>=0 and h<=23 and minute>=0 and minute<=59 and sec>=0 and sec<=60,"服务器日期无效")
        return {year=y,month=m,day=d,hour=h,min=minute,sec=sec}
    end
    os.time=function(date)
        if date==nil then return defaultTime() end
        assert(type(date)=="table","活动时间参数无效")
        local y,m,d,h,minute,sec=tonumber(date.year),tonumber(date.month),tonumber(date.day),tonumber(date.hour),tonumber(date.min),tonumber(date.sec)
        assert(y and m and d and h and minute and sec and y==math.floor(y) and m==math.floor(m) and d==math.floor(d) and h==math.floor(h) and minute==math.floor(minute) and sec==math.floor(sec) and y>=1970 and y<=9999 and m>=1 and m<=12 and d>=1 and d<=31 and h>=0 and h<=23 and minute>=0 and minute<=59 and sec>=0 and sec<=60,"活动日期参数无效")
        local value=rawLua(string.format("return os.time({year=%d,month=%d,day=%d,hour=%d,min=%d,sec=%d})",y,m,d,h,minute,sec),"n")
        assert(type(value)=="number" and value==math.floor(value) and value>=0,"活动时间计算失败")
        return value
    end
end

-- Bag containers: 0 all, 1 道具, 2 材料, 3 任务栏 (quest bag, as daily_tasks / shimen read it), 10 锦囊, 11 仓库, 13/14 交易双方. Item class / type are not readable.
local enumSource=[[local kind=%d local t=''
local function add(a,index,bind,lock)
  if a and a:GetID()~=0 then t=t..a:GetID()..'\t'..(a:GetName() or '')..'\t'..(a:GetNum() or 1)..'\t'..index..'\t'..bind..'\t'..lock..'\n' end end
local function bag(name,base,n) for i=0,n-1 do local a,locked=PlayerPackage:EnumItem(name,i)
  local bind=0 if GetItemBindStatus then bind=GetItemBindStatus(base+i) or 0 end add(a,base+i,bind,locked and 1 or 0) end end
if kind==0 or kind==1 then bag('base',0,DataPool:GetBaseBag_Num()) end
if kind==0 or kind==2 then bag('material',100,DataPool:GetMatBag_Num()) end
if kind==3 then bag('quest',200,DataPool:GetTaskBag_Num()) end
if kind==10 then for i=0,119 do local a,locked=Bank:EnumTemItem(i) add(a,i,0,locked and 1 or 0) end end
if kind==11 then for k=0,9 do local b,n=Bank:GetRentBoxInfo(k) if b and n and n>0 then for i=1,n do local a,locked=Bank:EnumItem(b+i-1) add(a,b+i-1,0,locked and 1 or 0) end end end end
if kind==13 or kind==14 then local name='ex_self' if kind==14 then name='ex_other' end for i=0,GetActionNum(name)-1 do add(EnumAction(i,name),i,0,0) end end
return t]]
local bagKinds={[0]=true,[1]=true,[2]=true,[3]=true,[10]=true,[11]=true,[13]=true,[14]=true}
local function enumBag(kind,strict)
    assert(bagKinds[math.floor(tonumber(kind) or -1)],"背包类型读取尚未接入："..tostring(kind).."（3 任务栏 / 4 / 12 拾取等）")
    local text=rawLua(string.format(enumSource,math.floor(tonumber(kind) or 0)),"s") or ""
    local out={}
    for line in tostring(text):gmatch("[^\n]+") do
        local obj,name,num,index,bind,lock=line:match("^(%-?%d+)\t(.-)\t(%d+)\t(%d+)\t(%d+)\t(%d+)$")
        if obj then
            local level=tonumber(name:match("%((%d+)级%)") or name:match("（(%d+)级）") or 0)
            out[#out+1]={obj=tonumber(obj),name=name,num=tonumber(num),count=tonumber(num),index=tonumber(index),bind=tonumber(bind),
                lock=tonumber(lock),class="",itemType="",level=level,desc="",ybpValue=0}
        elseif strict then
            error("背包查询结果格式错误",0)
        end
    end
    return out
end
-- 燕子坞原字节码在入口和战斗循环均无参数调用 Bag_DeleteItem。
-- 空位充足时无需删除即可继续；满包或读取异常时暂停，指定物品删除仍不接管。
if entry.original_token=="00313c18" then
    function Bag_DeleteItem(...)
        assert(select("#",...)==0,"燕子坞指定物品处理尚未适配")
        local base,material=Bag:GetSpaceNum(0),Bag:GetSpaceNum(1)
        assert(type(base)=="number" and base==math.floor(base) and base>0 and
               type(material)=="number" and material==math.floor(material) and material>0,
               "燕子坞背包空位不足或不可读取，请先整理背包")
        return true
    end
end
local dungeonBagSearch=({["00320005"]=true,["002bb430"]=true,["002fd257"]=true,["002fe064"]=true,["002fe6b9"]=true})[entry.original_token]
-- Original loops call bag cleanup (Bag_DeleteItem / Bag_DeleteBagItem / ClearBag) every cycle. Nothing is ever
-- deleted here: with readable free space in both bags there is nothing to clean and the task continues;
-- a full or unreadable bag stops it with a request to tidy up by hand. 燕子坞 keeps its own variant above.
local function checkBagSpace()
    local base,material=Bag:GetSpaceNum(0),Bag:GetSpaceNum(1)
    assert(type(base)=="number" and base==math.floor(base) and base>0 and
           type(material)=="number" and material==math.floor(material) and material>0,
           "背包空位不足或无法读取：本程序不会自动删除或清理物品，请手动整理背包")
    return true
end
if entry.original_token~="00313c18" then
    function Bag_DeleteItem(...)
        assert(select("#",...)==0,"原脚本要处理指定物品（删除类），本程序不执行，已停止")
        return checkBagSpace()
    end
end
function Bag_DeleteBagItem() return checkBagSpace() end
function ClearBag() return checkBagSpace() end
-- Bag:SearchItemName lives in bag.lua (99 KB, not shipped with every task); this version reads the same bag records.
if dungeonBagSearch or rawget(Bag,"SearchItemName")==nil then
    function Bag:SearchItemName(names,provided)
        local allowed={};for name in tostring(names or ""):gmatch("%S+") do allowed[name]=true end
        local list=type(provided)=="table" and provided or enumBag(0,true);local result={}
        for _,item in ipairs(list) do if allowed[item.name] then result[#result+1]=item end end
        return result
    end
end
playerlib=playerlib or {}
playerlib.CGetGUID=playerlib.CGetGUID or function() return rawLua("return Player:GetData('GUID')","n") end
playerlib.CGetTID=playerlib.CGetTID or function()
    local _,server=CombatRuntime.host('battle_self_identity')
    assert(type(server)=='number' and server>=0 and server==math.floor(server),'player server ID unavailable')
    return server
end
playerlib.CGetBangMengID=playerlib.CGetBangMengID or missing('playerlib.CGetBangMengID')
-- Native level: player.lua's Player:GetFightPetGUID calls this, so it must never call back into Player.
-- -1 when no pet is out; otherwise the fighting pet's game GUID as high*2^32+low (this program's encoding;
-- comparisons with GUIDs from the reference program's own pet settings are not meaningful).
playerlib.CGetFightPetGUID=function()
    local high,low=rawLua([[-- generic:fight-pet-guid
        if not Pet then error('pet interface missing') end
        local found=nil
        for i=0,9 do local present=Pet:IsPresent(i)
            if present~=true and present~=1 and present~=false and present~=0 then error('pet presence state unavailable') end
            if present==true or present==1 then local on=Pet:GetIsFighting(i)
                if on~=true and on~=1 and on~=false and on~=0 then error('pet fighting state unavailable') end
                if on==true or on==1 then if found then error('two fighting pets') end found=i end
            end
        end
        if not found then return -1,-1 end
        local h,l=Pet:GetGUID(found)
        if type(h)~='number' or type(l)~='number' or h<0 or l<0 then error('pet GUID unavailable') end
        return h,l]],"nn")
    assert(type(high)=="number" and type(low)=="number","出战珍兽状态不可读")
    if high==-1 and low==-1 then return -1 end
    assert(high>=0 and low>=0 and high<2^20 and low<2^32,"出战珍兽 GUID 无效")
    return high*4294967296+low
end
if entry.original_token=="00320005" then
    local function ownServerId()
        local _,server=CombatRuntime.host("battle_self_identity")
        assert(type(server)=="number" and server>=0 and server==math.floor(server),"player scene ID unavailable")
        return server
    end
    Player.GetTID=ownServerId;playerlib.CGetTID=ownServerId
end
local natives={baglib=function() return {EnumBagItem=function(kind) return enumBag(kind) end} end,
    playerlib=function() return playerlib end,skilllib=function() return skilllib end}

-- 5. Framework modules: load into a side environment, import only what is missing here.
local alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local digits={};for i=1,#alphabet do digits[alphabet:byte(i)]=i-1 end
-- Buffered so a large module stays within the VM's memory cap; Sleep(0) resets its instruction budget.
local function decode(encoded)
    local parts,buf,n={},{},0
    for i=1,#encoded,4 do
        local a,b,c,d=encoded:byte(i,i+3)
        local v=(digits[a]<<18)|(digits[b]<<12)|((digits[c] or 0)<<6)|(digits[d] or 0)
        n=n+1;buf[n]=(v>>16)&255
        if c~=61 then n=n+1;buf[n]=(v>>8)&255 end
        if d~=61 then n=n+1;buf[n]=v&255 end
        if n>=3000 then parts[#parts+1]=string.char(table.unpack(buf,1,n));n=0 end
        if i%65536==1 then Sleep(0) end
    end
    if n>0 then parts[#parts+1]=string.char(table.unpack(buf,1,n)) end
    return table.concat(parts)
end
local fw=setmetatable({},{__index=_G})
fw.require=function(name) local make=natives[name];if not make then error("原程序原生库未接入："..tostring(name),0) end return make() end
local loaded,loading={},{}
local function merge()
    for k,v in pairs(fw) do
        if k~="require" then
            local mine=rawget(_G,k)
            if mine==nil then _G[k]=v
            elseif mine~=v then
                if type(v)=="table" and type(mine)=="table" then for kk,vv in pairs(v) do if rawget(mine,kk)==nil then mine[kk]=vv end end end
                fw[k]=nil -- original helpers now resolve this name to our implementation
            end
        end
    end
end
local compiledModules={}
-- Runs an original module in the side environment and returns its results. fresh=true is CExec: run again
-- even if loaded before (common.lua's g_json=CExec("json") needs the returned table); otherwise once.
local function runModule(name,fresh)
    if loaded[name] and not fresh then return true end
    local token=(__original_names or {})[name];if not token then return false end
    if loading[name] then error("原框架模块循环加载："..name,0) end
    local chunk=compiledModules[name]
    if not chunk then
        local data=decode(assert((__original_rules or {})[token],"缺少原 Lua 模块："..name))
        local why;chunk,why=load(data,"@original/"..name,data:sub(1,1)=="\27" and "b" or "t",fw)
        if not chunk then error("原框架模块无法加载（"..name.."）："..tostring(why),0) end
        compiledModules[name]=chunk
    end
    loading[name]=true
    local result=table.pack(pcall(chunk))
    loading[name]=nil
    if not result[1] then error("原框架模块初始化出错（"..name.."）："..tostring(result[2]),0) end
    merge();loaded[name]=true;Sleep(0);return true,table.unpack(result,2,result.n)
end
local function loadModule(name) return (runModule(name,false)) end
-- This program defines its own Player/Target/Pet/Bag/Team/Skill tables, so dependency discovery by global
-- name never pulls in the original modules that add methods to them (Player:GetBuff, Bag:EnumRenWuItem ...).
-- A method missing here loads its original module on first use; methods this program defines stay ours.
for tableName,module in pairs({Player="player",Target="target",Pet="pet",Bag="bag",Team="team",Skill="skill"}) do
    local t=rawget(_G,tableName)
    if type(t)=="table" and (__original_names or {})[module] then
        local mt=getmetatable(t) or {};local prior=mt.__index
        local fetching=false
        mt.__index=function(self,key)
            if not loaded[module] and not loading[module] and not fetching and type(key)=="string" then
                fetching=true;local ok,err=pcall(loadModule,module);fetching=false
                if not ok then error(err,0) end
                local v=rawget(self,key);if v~=nil then return v end
            end
            if type(prior)=="function" then return prior(self,key) elseif type(prior)=="table" then return prior[key] end
        end
        setmetatable(t,mt)
    end
end
function LoadScript(name)
    local n=tostring(name or ""):match("^%s*(.-)%s*$"):gsub("%.lua$","")
    if loadModule(n) then return end
    return rawLoad(name)
end
-- Original CExec executes the named module every time and returns its results. Modules of this task run in
-- the framework environment (where require gives the native libraries); anything else is this program's.
local rawCExec=CExec
function CExec(name)
    local n=tostring(name or ""):match("^%s*(.-)%s*$"):gsub("%.lua$","")
    local found=table.pack(runModule(n,true))
    if found[1] then return table.unpack(found,2,found.n) end
    return rawCExec(name)
end
-- 原程序先找角色私有坐标文件（GetUserScriptPath），找不到才用预载的 script/数据。
-- 本程序的数据文件随任务预载（__original_data），自定义走 overrides 目录，故私有路径恒为空。
function GetUserScriptPath(name) return "" end
function LoadUserPathScript(path) return false end
local function loadData()
    for _,name in ipairs(entry.data_files or {}) do
        local source=(__original_data or {})[name]
        if type(source)~="string" then error("缺少原程序数据文件："..tostring(name),0) end
        local chunk,why=load(source,"=data/"..name,"t",fw)
        if not chunk then error("原程序数据文件语法错误（"..name.."）："..tostring(why),0) end
        local ok,err=pcall(chunk)
        if not ok then error("原程序数据文件执行出错（"..name.."）："..tostring(err),0) end
        merge()
    end
end

local function explain(err)
    err=tostring(err)
    local fn=err:match("attempt to call a nil value %(global '([^']+)'%)") or err:match("attempt to call a nil value %(field '([^']+)'%)")
        or err:match("attempt to call a nil value %(method '([^']+)'%)")
    if fn then return "原脚本调用了本程序尚未接入的函数："..fn.."（"..err.."）" end
    return err
end
local riskLabel={spend="允许支付",sell="允许出售",transfer="允许交易",offline="允许下线"}
-- The original IsHuodongComplete reads the campaign's daily count, limit and
-- presence. A returned script by itself does not prove a completed dungeon.
function RunOriginalGenericTask()
    assert(entry.adapter=="original_generic_v1","通用原脚本入口声明无效")
    for _,risk in ipairs(entry.risks or {}) do
        if cfg["allow_"..risk]~=true then error("此任务的原脚本含有"..(riskLabel[risk] or risk).."类操作，请在任务设置里打开“"..(riskLabel[risk] or risk).."”后再运行",0) end
    end
    if entry.original_token=="00320005" then
        rawLoad("original_filters")
        local baseClass,lootNoted=Enum2XByClass,false
        Enum2XByClass=function(kind,...)
            if type(kind)=="string" then kind=kind:match("^%s*(.-)%s*$") end
            if kind=="包裹" then if not lootNoted then lootNoted=true;logLine("除匪首：地面包裹拾取尚未接入，本次跳过") end;return {} end
            return baseClass(kind,...)
        end
    end
    g_config=g_config or {}
    for _,name in ipairs(entry.framework or {}) do
        if not loadModule(name) then error("原框架模块未登记："..tostring(name),0) end
    end
    loadData()
    g_config=g_config or {}
    -- The reference ScriptOnStart runs GlobalParamInit (common.lua) before every task: it builds g_config.team,
    -- .protect, .skill, .item ... from the global settings pages. This program's ScriptOnStart only logs, so run
    -- it here once, before the task-specific values below that it would otherwise overwrite.
    if type(GlobalParamInit)=="function" then GlobalParamInit() end
    if entry.original_token=="002bb430" or entry.original_token=="002fd257" or entry.original_token=="0034fff0" or entry.original_token=="002cf5a7" then
        g_config.nottongbu=g_config.nottongbu or {}
        g_config.nottongbu.fuben_ty_xhmode=ReadConfigBool("副本","小号模式")
    end
    if entry.original_token=="0034fff0" then
        g_config.fuben=g_config.fuben or {}
        g_config.team=g_config.team or {}
    end
    if entry.original_token=="00322b14" or entry.original_token=="0032b023" then
        g_config.team=g_config.team or {}
        g_config.team.count_fhlm=math.floor(tonumber(cfg.count_fhlm) or 0)
    end
    if g_self==nil then g_self={} end
    if g_self.menpai==nil then g_self.menpai=Player:GetData("MEMPAI") end
    local token=assert(entry.original_token,"缺少原脚本标识")
    local data=decode(assert((__original_rules or {})[token],"缺少原脚本"))
    local chunk=assert(load(data,"@original/"..tostring(entry.name or token),"b",_G))
    local ok,err=pcall(chunk)
    if not ok then error(explain(err),0) end
    logLine("原脚本执行结束："..tostring(entry.name or token))
end
