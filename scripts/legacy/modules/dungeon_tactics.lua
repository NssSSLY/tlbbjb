-- Shared battlefield helpers for explicit dungeon flows: movement, attack, trap avoidance, prompt tracking, raid roster.
LoadScript('dungeon_pet_guard')
DungeonTactics={}
local R=assert(CombatRuntime)
function DungeonTactics.new(api,scene,bossNames)
    local T={ctx=api.beginBattle({bosses=bossNames},scene).combat,pet=DungeonPetGuard.new(),seenAt={}}
    local stopped,key,lastMove=false,'',-10000
    local allSkills={};for _,s in ipairs(T.ctx.skills) do allSkills[#allSkills+1]=s end
    local disabled,basic={},false
    local function applyDisabled()
        local list={}
        if not basic then for _,s in ipairs(allSkills) do if not disabled[s.name] then list[#list+1]=s end end end
        T.ctx.skills=list
    end
    -- Basic attacks only, for phases where the reference holds skills back.
    function T.basicOnly(on) if basic~=on then basic=on;applyDisabled() end end
    function T.disable(names) disabled={};for n in names:gmatch('%S+') do disabled[n]=true end;applyDisabled() end
    function T.world() return assert(api.world(),'副本场景不可读') end
    function T.stop()
        if not stopped then api.stopAttack();stopped=true end
        if T.ctx.id>=0 then T.ctx=R.new(scene,{boss_names=bossNames});applyDisabled() end
    end
    function T.clearMove() key='' end
    -- Same target within 4 seconds is not resent. Returns false once within a unit of the point.
    function T.move(x,y)
        local p=T.world();assert(p.scene==scene,'副本移动时场景已变化')
        if (p.x-x)^2+(p.y-y)^2<=1 then return false end
        local nextKey=x..','..y
        if nextKey~=key or api.now()-lastMove>=4000 then
            api.stop();R.call(R.codes.RunTo,{scene},{x,y});key=nextKey;lastMove=api.now()
        end
        return true
    end
    function T.enemy(o) return o~=nil and o.class=='怪物' and o.hp>0 end
    function T.attack(target)
        if not T.enemy(target) then return false end
        local p=T.world()
        if (p.x-target.x)^2+(p.y-target.y)^2>35^2 then T.move(target.x,target.y);return true end
        if not DungeonPetGuard.update(T.pet,false) then T.stop();return true end
        if not api.maintain() and R.canAttack() then
            stopped=false;R.selectOriginalTarget(T.ctx,target.id);R.step(T.ctx)
        end
        return true
    end
    function T.holdPet() DungeonPetGuard.update(T.pet,true) end
    function T.restorePet() return DungeonPetGuard.update(T.pet,false) end
    function T.rows(rename)
        local all=api.objects();assert(type(all)=='table' and #all<=512,'副本对象不可读')
        local out={}
        for _,o in ipairs(all) do
            local name=tostring(rawget(o,'name') or '')
            if rename then name=rename(name) end
            out[#out+1]={id=o.id,server_id=o.server_id,x=o.x,y=o.y,hp=o.hp,dst=o.dst,class=o.class,hostile=o.hostile,name=name}
        end
        return out
    end
    function T.best(all,name,accept)
        local found
        for _,o in ipairs(all) do
            if o.name==name and (not accept or accept(o)) and (not found or o.dst<found.dst) then found=o end
        end
        return found
    end
    function T.list(all,name,accept)
        local out={}
        for _,o in ipairs(all) do if o.name==name and (not accept or accept(o)) then out[#out+1]=o end end
        table.sort(out,function(a,b) return a.dst<b.dst end)
        return out
    end
    function T.hasBuff(set,text) for name in pairs(set) do if name:find(text,1,true) then return true end end return false end
    local function kinds(kind)
        local out={};for _,o in ipairs(api.mechanisms()) do if o.kind==kind then out[#out+1]=o end end;return out
    end
    function T.traps() return kinds(2) end
    function T.players()
        local own=R.host('battle_self_identity');local out={}
        for _,o in ipairs(kinds(1)) do if o.id~=own then out[#out+1]=o end end
        return out
    end
    -- Leave `danger` to the nearest grid point in the circle with clearance r, or `fallback` when none has r.
    -- Returns false when already clear, true while moving (or when no point exists).
    function T.escape(danger,r,cx,cy,maxR,fallback,valid)
        local p=T.world();local inside=false
        for _,o in ipairs(danger) do if (p.x-o.x)^2+(p.y-o.y)^2<r*r then inside=true;break end end
        if not inside then return false end
        local function search(clear)
            local point,score
            for y=math.floor(cy-maxR),math.ceil(cy+maxR) do for x=math.floor(cx-maxR),math.ceil(cx+maxR) do
                if (x-cx)^2+(y-cy)^2<=maxR*maxR and (not valid or valid(x,y)) then
                    local good=true
                    for _,o in ipairs(danger) do if (o.x-x)^2+(o.y-y)^2<clear*clear then good=false;break end end
                    local s=(p.x-x)^2+(p.y-y)^2
                    if good and (not score or s<score) then point,score={x,y},s end
                end
            end end
            return point
        end
        local point=search(r) or (fallback and search(fallback))
        if point then T.move(point[1],point[2]) else api.stop() end
        return true
    end
    -- Prompt tracking: a key fires when more lines carry it than before; lines present at the first read are history.
    local counts,phrases,firstRead={},{},true
    T.lastLine={}
    function T.dict(key_)
        local text=tostring(GetDictionaryString(key_) or ''):gsub('#c%x%x%x%x%x%x',''):gsub('#%a',''):gsub('^%s+',''):gsub('%s+$','')
        return text
    end
    function T.watch(keys)
        for _,k in ipairs(keys) do phrases[k]=k:match('^[%w_]+$') and T.dict(k) or '' end
        T.keys=keys
    end
    function T.readMessages()
        local lines=api.messages();local fired=false
        for _,k in ipairs(T.keys) do
            local n,phrase=0,phrases[k]
            for _,line in ipairs(lines) do
                if line:find(k,1,true) or (phrase~='' and phrase~=k and line:find(phrase,1,true)) then n=n+1;T.lastLine[k]=line end
            end
            if not firstRead and n>(counts[k] or 0) then T.seenAt[k]=api.now();fired=true end
            counts[k]=n
        end
        firstRead=false
        return fired
    end
    -- Other players the game rates as enemies (host enemy_players). hp is a percentage, -1 when unknown.
    function T.enemyPlayers()
        local at,count,text=R.host('enemy_players')
        assert(at==scene and type(count)=='number' and type(text)=='string','敌对玩家快照不可读或场景变化')
        local out,p={},T.world()
        for id,server,x,y,hp in text:gmatch('(%d+)\t(%d+)\t([^\t]+)\t([^\t]+)\t([^\n]+)\n') do
            local o={id=tonumber(id),server_id=tonumber(server),x=tonumber(x),y=tonumber(y),hp=tonumber(hp)}
            o.dst=math.sqrt((o.x-p.x)^2+(o.y-p.y)^2);out[#out+1]=o
        end
        assert(#out==count,'敌对玩家数量不一致')
        return out
    end
    -- CombatCast only takes a hostile NPC; this is its route for any object. idx<0 is the basic attack. 1 means submitted.
    local function castRaw(o,idx,name)
        return GetLuaValue(string.format([[-- pvp:cast
            local client,server,idx,name=%d,%d,%d,%q
            local can=DataPool:IsCanDoAction() if not can or can==0 then return 0 end
            local a=nil local b=nil local old=nil
            if idx>=0 then
                a=EnumAction(idx,'skill') if not a or a:GetID()==0 or a:GetName()~=name then return -2 end
                local cd=Lua_CheckActionItemCoolDown(a:GetID()) if type(cd)~='number' then error('skill cooldown unavailable') end if cd~=0 then return 0 end
                local e=Packet_Env b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end old=b:GetActionItem()
            end
            DataPool:SelectAsTargetByObjID(server)
            local present=Target:IsPresent() if not present or present==0 or Target:GetData('NPCID')~=client then return -3 end
            if idx<0 then local r=Player:UseSkill() if r==1 then return 1 end return 0 end
            local enabled=a:IsEnable() if enabled~=1 and enabled~=true then return 0 end
            b:SetActionItem(a:GetID()) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end
            return 1]],o.id,o.server_id,idx,name or ''),'n')
    end
    local lastCast,lastBasic=-100000,-100000
    function T.strikePlayer(o)
        if api.maintain() or not R.canAttack() or api.now()-lastCast<1000 then return end
        local done=false
        for _,skill in ipairs(T.ctx.skills) do
            local r=castRaw(o,skill.index,skill.name)
            if r==1 then done=true;break end
            if r==-2 then error('技能列表已变化，请重新开始任务：'..skill.name,0) end
            if r==-3 then break end
        end
        if not done and api.now()-lastBasic>=1500 then castRaw(o,-1,'');lastBasic=api.now() end
        lastCast=api.now()
    end
    -- A learned skill by name or define id on any object. false when it is not learned or the target cannot be confirmed.
    function T.useSkill(which,o)
        local match=type(which)=='number' and ('t:GetDefineID()=='..which) or string.format('t:GetName()==%q',which)
        local r=GetLuaValue(string.format([[-- tactics:skill
            local server,client=%d,%d
            local a=nil for i=0,255 do local t=EnumAction(i,'skill') if t and t:GetID()~=0 and %s then a=t break end end
            if not a then return -1 end
            DataPool:SelectAsTargetByObjID(server)
            local present=Target:IsPresent()
            if not present or present==0 or Target:GetData('NPCID')~=client then return 0 end
            local e=Packet_Env local b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end
            local old=b:GetActionItem() b:SetActionItem(a:GetID()) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end
            return 1]],o.server_id,o.id,match),'n')
        return r==1,r==-1
    end
    -- What a player's buffs say about attacking them, by the reference's own wording.
    function T.playerState(o)
        local set=api.buffs(o)
        local invincible=false
        for _,w in ipairs({'不可被攻击','护体：免疫控制和伤害','传送保护：无敌','呆若木鸡：状态','神佑：不会受到伤害'}) do
            if T.hasBuff(set,w) then invincible=true;break end
        end
        return invincible,T.hasBuff(set,'虚弱：所受伤害放大')
    end
    -- The battlefield's own way back after dying, at most once every 3 seconds.
    local lastGhost=-100000
    function T.reliveOut()
        if api.now()-lastGhost<3000 then return end
        lastGhost=api.now()
        GetLuaValue("-- tactics:relive\nlocal e=Relive_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.Relive_Out_Ghost() end",'',0)
    end
    function T.within(k,ms) return T.seenAt[k]~=nil and api.now()-T.seenAt[k]<ms end
    function T.age(k) return T.seenAt[k] and api.now()-T.seenAt[k] or nil end
    return T
end
-- Prompt counter for flows outside any fight: what is already on screen when it starts is history.
function DungeonTactics.prompts(api,keys)
    local base={}
    local function count(key)
        local phrase=GetDictionaryString and GetDictionaryString(key) or nil
        local n=0
        for _,line in ipairs(api.messages()) do
            if line:find(key,1,true) or (type(phrase)=='string' and phrase~='' and line:find(phrase,1,true)) then n=n+1 end
        end
        return n
    end
    for _,k in ipairs(keys) do base[k]=count(k) end
    return function(k) return count(k)>(base[k] or 0) end
end
-- Client id of the team leader when they are in this scene, otherwise nil. Safe when solo or when a member is elsewhere.
function DungeonTactics.leaderId()
    local id=GetLuaValue([[-- tactics:leader
        local n=DataPool:GetTeamMemberCount()
        if type(n)~='number' or n<1 then return -1 end
        local inside=DataPool:IsTeamMemberInScene(0)
        if inside~=1 and inside~=true then return -1 end
        local server=DataPool:GetTeamMemberObjIDNamePortInfo(0)
        if type(server)~='number' then return -1 end
        return Target:GetServerId2ClientId(server)]],'n')
    if type(id)=='number' and id>=0 then return id end
    return nil
end
-- The reference's level brackets all share this shape: the first row whose top covers the level.
function DungeonTactics.level(api)
    local n=GetLuaValue("-- tactics:level\nreturn Player:GetData('LEVEL')",'n')
    assert(type(n)=='number','角色等级不可读')
    return n
end
-- Raid roster, read as the game's own UnionFrame does: squads 0-4, slots 0-5, level>0 marks a member.
function DungeonTactics.raid()
    local count,text=GetLuaValue([[-- dungeon:raid-roster
        if not Player:IsInRaid() then return 0,'' end
        local rows='' local n=0
        for i=0,4 do for j=0,5 do
            local name,menpai,level,dead,offline=Raid:GetMemberInfoByIdx(i,j)
            if type(level)=='number' and level>0 then
                local inside=Raid:IsMemberInSceneByIdx(i,j)
                if inside==true then inside=1 elseif inside~=1 then inside=0 end
                rows=rows..string.format('%d\t%d\t%d\t%d\t%d\t%s\n',i,j,menpai,dead,inside,name) n=n+1
            end
        end end
        return n,rows
    ]],'ns')
    assert(type(count)=='number' and type(text)=='string','团队成员不可读')
    local out={}
    for squad,slot,menpai,dead,inside,name in text:gmatch('(%d+)\t(%d+)\t(%-?%d+)\t(%-?%d+)\t(%d+)\t([^\n]*)\n') do
        out[#out+1]={squad=tonumber(squad),slot=tonumber(slot),menpai=tonumber(menpai),dead=tonumber(dead)==1,inside=inside=='1',name=name}
    end
    assert(#out==count,'团队成员数量不一致')
    return out
end
function DungeonTactics.raidSelf()
    local squad,slot=GetLuaValue("-- dungeon:raid-self\nlocal a,b=Player:GetMyRaidIndex() return a,b",'nn')
    assert(type(squad)=='number' and type(slot)=='number','团队位置不可读')
    return squad,slot
end
function DungeonTactics.raidLeader()
    return GetLuaValue("-- dungeon:raid-leader\nif Player:IsRaidLeader()==1 then return 1 end return 0",'n')==1
end
