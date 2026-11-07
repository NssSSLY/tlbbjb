-- Emei policy. Uses the game's indexed team records, never the reference DLL's EnumMemberInfo.
local R=assert(CombatRuntime)
local cfg=(TaskConfig or {}).battle_system or {}
local E={}
local function raw(code,format) return GetLuaValue(code,format or "",format and #format or 0) end
local function names(text)
    local out,seen={},{}
    for n in tostring(text or ""):gsub("，",","):gmatch("[^,\r\n]+") do
        n=n:match("^%s*(.-)%s*$")
        if n~="" and not seen[n] then seen[n]=true;out[#out+1]=n end
    end
    return out
end
local function setup()
    raw([=[-- TLBB_EMEI_TEAM_INIT_V1
        function __tlbbBattle.teamMember(i)
            local name,school,hp,maxhp=DataPool:GetTeamMemberInfo(i)
            local server,identity=DataPool:GetTeamMemberObjIDNamePortInfo(i)
            local guid=DataPool:GetTeamMemGUIDByUIIndex(i)
            local inside=__tlbbBattle.flag(DataPool:IsTeamMemberInScene(i))
            if type(name)~='string' or name=='' or string.len(name)>192 or name~=identity or guid==nil then error('team identity unavailable') end
            guid=tostring(guid)
            if guid=='' or guid=='-1' or string.len(guid)>128 or string.find(name,'[%c]') or string.find(guid,'[%c]') then error('invalid team identity') end
            if type(server)~='number' or server~=math.floor(server) or server< -1 or server>10000000 then error('team object ID unavailable') end
            local client=-1
            if inside==1 and server>=0 then
                client=Target:GetServerId2ClientId(server)
                if type(hp)~='number' or type(maxhp)~='number' or hp<0 or maxhp<=0 or hp>maxhp or maxhp>1e12 then error('team health unavailable') end
                if type(client)~='number' or client~=math.floor(client) or client< -1 then error('team client ID unavailable') end
            else hp=-1 maxhp=-1 end
            return name,guid,server,client,hp,maxhp,inside
        end
        function __tlbbBattle.teamSnapshot()
            local count=DataPool:GetTeamMemberCount()
            if type(count)~='number' or count~=math.floor(count) or count<0 or count>6 then error('team count unavailable') end
            local own=Player:GetName()
            if type(own)~='string' or own=='' then error('player name unavailable') end
            local text='' local seen={}
            for i=0,count-1 do
                local name,guid,server,client,hp,maxhp,inside=__tlbbBattle.teamMember(i)
                if seen[guid] then error('duplicate team identity') end seen[guid]=true
                text=text..i..'\t'..name..'\t'..guid..'\t'..string.format('%.0f\t%.0f\t%.0f\t%.0f',server,client,hp,maxhp)..'\t'..inside..'\n'
            end
            if DataPool:GetTeamMemberCount()~=count then error('team changed during snapshot') end
            return count,text,own
        end
        function __tlbbBattle.teamCast(i,guid,server,client,name,slot,id,skill,threshold)
            local current,gg,ss,cc,hp,maxhp,inside=__tlbbBattle.teamMember(i)
            if current~=name or gg~=guid or ss~=server or cc~=client then error('healing target identity changed') end
            if inside~=1 or client<0 or hp<=0 then return 0 end
            if hp*100/maxhp>threshold then return 0 end
            return __tlbbBattle.cast(slot,-1,id,skill,0,0,client,server)
        end
    ]=])
end
local function skill(s,name)
    for _,a in ipairs(s.skills) do if a.name==name then return a end end
end
function E.new(s,inspect)
    local selected=names(cfg.emei_heal_skills)
    if #selected==0 then for _,name in ipairs({"清心普善咒","冲虚养气"}) do if skill(s,name) then selected[#selected+1]=name end end end
    if not inspect then
        assert(#selected>0,"峨嵋策略没有可用治疗技能，请读取已学技能并设置治疗顺序")
        for _,name in ipairs(selected) do local a=assert(skill(s,name),"峨嵋治疗技能未学会："..name);assert(not a.reason,name.."："..tostring(a.reason)) end
    end
    local state={heals=selected,attack=cfg.emei_attack==true,members={},read=-10000,unavailable={}}
    setup()
    if not inspect and not state.attack then
        local client,server=R.host("battle_self_identity")
        raw(string.format("DataPool:SelectAsTargetByObjID(%d) if not Target:IsPresent() or Target:GetData('NPCID')~=%d then error('self target unavailable') end",server,client))
        R.host("stop_motion")
    end
    return state
end
function E.refresh(s)
    local e=s.emei
    if not e or cfg.emei_team_heal==false or GetTickCount()-e.read<500 then return end
    local count,text,own=raw("return __tlbbBattle.teamSnapshot()","nss")
    assert(type(count)=="number" and count>=0 and count<=6 and count==math.floor(count) and type(text)=="string","队伍治疗快照无效")
    local list={}
    for line in text:gmatch("[^\n]+") do
        local index,name,guid,server,client,hp,maxhp,inside=line:match("^(%d+)\t([^\t]+)\t([^\t]+)\t(-?%d+)\t(-?%d+)\t(-?[%d.]+)\t(-?[%d.]+)\t([01])$")
        assert(index,"队伍治疗快照格式无效")
        list[#list+1]={index=tonumber(index),name=name,guid=guid,server=tonumber(server),client=tonumber(client),hp=tonumber(hp),maxhp=tonumber(maxhp),inside=inside=="1",own=name==own}
    end
    assert(#list==count,"队伍治疗快照数量不一致")
    e.members=list;e.read=GetTickCount()
end
function E.confirm(s,p,a)
    local hp=s.hp
    if p.target.index>=0 then
        E.refresh(s)
        local found
        for _,m in ipairs(s.emei.members) do if m.guid==p.target.guid then found=m;break end end
        assert(found and found.server==p.target.server and found.client==p.target.client and found.inside,"治疗目标离队、离场或身份变化")
        assert(found.hp>0,"治疗目标已死亡")
        hp=found.hp
    end
    -- This acknowledges the healing action, not a dungeon result. Damage may
    -- offset healing; a live cooldown receipt still allows the next healing cycle.
    return hp>p.hp or a.cooldown>0
end
function E.tick(s)
    E.refresh(s)
    local selfPercent=s.hp*100/s.maxhp
    local threshold=tonumber(cfg.emei_heal_percent or 75)
    local protection=tonumber((TaskConfig or {}).combat_min_hp or 25)
    local candidates={}
    if selfPercent<=math.max(threshold,protection) then candidates[#candidates+1]={index=-1,name="自己",hp=s.hp,maxhp=s.maxhp,percent=selfPercent} end
    for _,m in ipairs(s.emei.members) do
        if not m.own and m.inside and m.client>=0 and m.server>=0 and m.hp>0 and m.hp*100/m.maxhp<=threshold then
            m.percent=m.hp*100/m.maxhp;candidates[#candidates+1]=m
        end
    end
    table.sort(candidates,function(a,b)
        if a==b then return false end
        local critical=math.max(tonumber(cfg.emei_self_priority_percent or 35),protection)
        if a.index==-1 and a.percent<=critical then return true end
        if b.index==-1 and b.percent<=critical then return false end
        return a.percent<b.percent or a.percent==b.percent and a.index<b.index
    end)
    for _,target in ipairs(candidates) do
        local targetKey=target.guid or 'self'
        if GetTickCount()>=(s.emei.unavailable[targetKey] or 0) then
        local unavailable=false
        for _,name in ipairs(s.emei.heals) do
            local a=assert(skill(s,name),"峨嵋治疗技能配置失效")
            local current=BattleSupport.readAction(a.index,-1)
            assert(current and current.id==a.id and current.name==name,"峨嵋治疗技能动作发生变化")
            if current.cooldown==0 then
                local result
                if target.index<0 then
                    local client,server=R.host("battle_self_identity")
                    result=raw(string.format("return __tlbbBattle.cast(%d,-1,%d,%q,0,0,%d,%d)",a.index,a.id,name,client,server),"n")
                else
                    result=raw(string.format("return __tlbbBattle.teamCast(%d,%q,%d,%d,%q,%d,%d,%q,%d)",target.index,target.guid,target.server,target.client,target.name,a.index,a.id,name,threshold),"n")
                end
                assert(result>=0,"峨嵋治疗目标或动作状态发生变化")
                if result==2 then unavailable=true end
                if result==1 then
                    s.pending={name=name,action=a,kind="峨嵋治疗",hp=target.hp,mp=s.mp,at=GetTickCount(),target=target}
                    R.log("提交峨嵋治疗："..target.name.." · "..name);return true
                end
            end
        end
        if unavailable then
            -- IsEnable is evaluated after selecting the real target. Do not
            -- invent a skill radius or repeatedly select the same invalid target.
            s.emei.unavailable[targetKey]=GetTickCount()+1000
        end
        end
    end
    -- Bound stale GUID entries across long-running team changes.
    for key,untilTime in pairs(s.emei.unavailable) do if untilTime<GetTickCount() then s.emei.unavailable[key]=nil end end
    return false
end
EmeiSupport=E
