-- 本程序的战斗宿主：读取本角色的实际动作，不按门派名称假定已经学会技能。
-- GetLuaValue 在同一个游戏 Lua 子环境内运行；本模块不加载第三方 DLL。
local R=assert(CombatRuntime)
local cfg=(TaskConfig or {}).battle_system or {}
-- 原 common.lua 的 g_MenPaiInfo 常量表（静态读取，含无门派编号 9）。
-- 新门派编号须经客户端核对；不能把无门派误映射为慕容，或猜昆仑编号。
local schoolNames={[0]="少林",[1]="明教",[2]="丐帮",[3]="武当",[4]="峨嵋",[5]="星宿",
    [6]="天龙",[7]="天山",[8]="逍遥",[9]="无门派",[10]="慕容",[11]="唐门",[12]="鬼谷",
    [13]="桃花岛",[14]="绝情谷",[15]="恶人谷"}
local function raw(code,format) return GetLuaValue(code,format or "",format and #format or 0) end
local function names(v)
    local out,seen={},{}
    for n in tostring(v or ""):gsub("，",","):gmatch("[^,\r\n]+") do
        n=n:match("^%s*(.-)%s*$")
        if n~="" and not seen[n] then seen[n]=true;out[#out+1]=n end
    end
    return out
end
local function json(v)
    if type(v)=="string" then return '"'..v:gsub('[%z\1-\31\\"]',function(c)
        return string.format("\\u%04x",c:byte()) end)..'"' end
    if type(v)=="number" then assert(v==v and math.abs(v)<1e15,"无效战斗数值");return tostring(v) end
    if type(v)=="boolean" then return v and "true" or "false" end
    if type(v)~="table" then return "null" end
    local out={};if #v>0 then for _,n in ipairs(v) do out[#out+1]=json(n) end;return "["..table.concat(out,",").."]" end
    for k,n in pairs(v) do out[#out+1]=json(k)..":"..json(n) end;return "{"..table.concat(out,",").."}"
end
local function num(v,label,low,high)
    assert(type(v)=="number" and v==v and v>=low and v<=high,"战斗读数无效："..label);return v
end
local function init()
    raw([=[-- TLBB_BATTLE_INIT_V1
        __tlbbBattle=__tlbbBattle or {}
        function __tlbbBattle.flag(v)
            if v==true or v==1 then return 1 end
            if v==false or v==0 then return 0 end
            error('action state is not boolean or 0/1')
        end
        function __tlbbBattle.action(i,p)
            if p<0 then return EnumAction(i,'skill') end
            return Pet:EnumPetSkill(p,i,'petskill')
        end
        function __tlbbBattle.info(i,p)
            local a=__tlbbBattle.action(i,p)
            if not a or a:GetID()==0 then return -1,0,'',0,-1 end
            local cd=Lua_CheckActionItemCoolDown(a:GetID())
            if type(cd)~='number' then error('skill cooldown unavailable') end
            return a:GetID(),a:GetDefineID(),a:GetName(),__tlbbBattle.flag(a:IsEnable()),cd
        end
        function __tlbbBattle.batch(first,last,p)
            local out={}
            for i=first,last do
                local id,define,name,enabled,cd=__tlbbBattle.info(i,p)
                table.insert(out,id) table.insert(out,define) table.insert(out,name)
                table.insert(out,enabled) table.insert(out,cd)
            end
            return unpack(out)
        end
        function __tlbbBattle.pet(i)
            if not Pet:IsPresent(i) or Pet:IsPresent(i)==0 then return -1,0,0,0,0,0,'' end
            local h,l=Pet:GetGUID(i)
            return h,l,Pet:GetHP(i),Pet:GetMaxHP(i),Pet:GetHappy(i),__tlbbBattle.flag(Pet:GetIsFighting(i)),Pet:GetName(i)
        end
        function __tlbbBattle.cast(i,p,id,name,h,l,client,server)
            if p>=0 then
                local hh,ll=Pet:GetGUID(p)
                if hh~=h or ll~=l or __tlbbBattle.flag(Pet:GetIsFighting(p))~=1 or Pet:GetHP(p)<=0 then return -2 end
            end
            local a=__tlbbBattle.action(i,p)
            if not a or a:GetID()~=id or a:GetName()~=name then return -2 end
            local can=DataPool:IsCanDoAction()
            if not can or can==0 then return 0 end
            local cd=Lua_CheckActionItemCoolDown(id)
            if type(cd)~='number' then error('skill cooldown unavailable') end
            if cd~=0 then return 0 end
            DataPool:SelectAsTargetByObjID(server)
            local present=Target:IsPresent()
            if not present or present==0 or Target:GetData('NPCID')~=client then return -3 end
            local enabled=a:IsEnable()
            if enabled~=1 and enabled~=true then return 2 end -- selected target/action unavailable; no submission
            local b=Packet_Env.Packet_Space_Line10_Row10_button
            local old=b:GetActionItem();b:SetActionItem(id)
            local ok,err=pcall(b.DoAction,b);b:SetActionItem(old)
            if not ok then error(err) end
            return 1
        end
    ]=])
end
local function action(i,p)
    local id,define,name,enabled,cd=raw(string.format("return __tlbbBattle.info(%d,%d)",i,p),"nnsnn")
    if id<0 then return nil end
    assert(type(name)=="string" and #name<=192,"技能名称无效")
    return {index=i,pet=p,id=id,define=define,name=name,enabled=enabled==1 or enabled==true,cooldown=cd}
end
-- 指定地点、换位、复活和持续引导需要各自的专用执行器，不用普通目标动作代替。
local special={['八阵图']=true,['诛仙阵']=true,['定海神针']=true,['桃花阵']=true,
    ['江行初雪']=true,['如封似闭']=true,['呆若木鸡']=true,['起死回生']=true,
    ['冰天雪地']=true,['烈火燎原']=true,['血毒万里']=true,['五雷轰顶']=true,
    ['极冰凝杀']=true,['劫火焚杀']=true,['腐毒蚀杀']=true,['玄雷击杀']=true}
local function blocked(name) return special[name] and "地点 / 引导 / 特殊技能待适配" or nil end
local Support={}
function Support.skillList()
    init()
    -- Some game builds do not expose GetActionNum('skill'). A missing count
    -- must not prevent enumeration of the already-adapted 0..255 action slots.
    local count=GetLuaValue("if type(GetActionNum)~='function' then return nil end local ok,n=pcall(GetActionNum,'skill') if ok then return n end return nil","",1)
    -- An unusable count (text, out of range, fractional) falls back to the same full scan.
    count=tonumber(count)
    if count and (count~=count or count<0 or count>256 or count~=math.floor(count)) then count=nil end
    -- GetActionNum returns a count; the first action index is zero.
    local last=count and count>0 and math.min(255,count-1) or 255
    local result,seen={},{}
    for first=0,last,6 do
        local finish=math.min(last,first+5)
        local values=table.pack(raw(string.format("return __tlbbBattle.batch(%d,%d,-1)",first,finish),string.rep("nnsnn",finish-first+1)))
        for index=first,finish do
            local at=(index-first)*5
            local id,define,name,enabled,cd=values[at+1],values[at+2],values[at+3],values[at+4],values[at+5]
            if id>=0 then
                num(id,"技能动作 ID",1,1e9);num(define,"技能定义 ID",0,1e9);num(cd,"技能冷却",0,1e12)
                assert(type(name)=="string" and #name<=192,"技能名称无效")
                local identity=tostring(id)..":"..tostring(define)
                if not seen[identity] then
                    seen[identity]=true
                    result[#result+1]={index=index,pet=-1,id=id,define=define,name=name,enabled=enabled==1,cooldown=cd,reason=blocked(name)}
                end
            end
        end
        Sleep(0)
    end
    return result
end
Support.readAction=action
Support.restriction=blocked
function Support.new(inspect)
    local s={last=-10000,report=-10000,petIndex=-1,skills={},pets={},lastbuff={},lastpet={},pending=nil,inspect=inspect}
    s.skills=Support.skillList()
    assert(#s.skills<=256,"技能数量超过上限")
    for i=0,9 do
        local h,l,hp,maxhp,happy,on,name=raw(string.format("return __tlbbBattle.pet(%d)",i),"nnnnnns")
        if h~=-1 then
            local p={index=i,high=h,low=l,hp=hp,maxhp=maxhp,happy=happy,on=on,name=name,skills={}}
            s.pets[#s.pets+1]=p
            if on==1 then assert(s.petIndex==-1,"读取到多个出战珍兽");s.petIndex=i;s.pet=p end
        end
    end
    if s.pet then
        for i=0,6 do local a=action(i,s.petIndex);if a then a.reason=blocked(a.name);s.pet.skills[#s.pet.skills+1]=a end end
    end
    s.heals=names(cfg.heal_skills);s.buffs=names(cfg.buff_skills)
    s.petSkills=names(cfg.pet_skills);s.petHP=names(cfg.pet_hp_skills);s.petMP=names(cfg.pet_mp_skills)
    local function check(list,all)
        for _,n in ipairs(list) do
            local found=false;for _,a in ipairs(all) do if a.name==n then found=true;assert(not a.reason,n.."："..tostring(a.reason)) end end
            assert(found,"未找到本角色 / 出战珍兽已学技能："..n)
        end
    end
    Support.refresh(s,true)
    local emei=cfg.emei_enabled==true and s.school==4
    if not inspect then
        if cfg.heal_enabled and not emei then check(s.heals,s.skills);assert(#s.heals>0,"请配置自身治疗技能") end
        if cfg.buff_enabled then check(s.buffs,s.skills);assert(#s.buffs>0,"请配置自身增益技能") end
        if cfg.pet then
            assert(s.pet,"珍兽策略需要先手动出战珍兽")
            assert(not cfg.pet_name or cfg.pet_name=="" or cfg.pet_name==s.pet.name,"出战珍兽与配置名称不符")
            check(s.petSkills,s.pet.skills);check(s.petHP,s.pet.skills);check(s.petMP,s.pet.skills)
        end
    end
    if emei then
        LoadScript("emei_support");s.emei=EmeiSupport.new(s,inspect)
        if not inspect then EmeiSupport.refresh(s) end
    end
    return s
end
local function snapshot(s)
    return {school_id=s.school,school_name=schoolNames[s.school] or "未识别门派",hp=s.hp,maxhp=s.maxhp,mp=s.mp,maxmp=s.maxmp,rage=s.rage,
        skills=s.skills,pets=s.pets,pet=s.pet,pending=s.pending and s.pending.name or "",read_at=GetTickCount(),
        emei=s.emei and {attack=s.emei.attack,members=s.emei.members} or nil}
end
function Support.publish(s)
    if GetTickCount()-s.report<1000 then return end
    s.report=GetTickCount();R.host("battle_snapshot",json(snapshot(s)))
end
function Support.refresh(s,force)
    if not force and GetTickCount()-s.last<500 then return end
    s.last=GetTickCount()
    -- 原 Player.GetRage：桃花岛（编号 13）用 ENG，其他已知门派用 RAGE。
    -- 刚切进副本时属性还没下发，生命上限会短暂读到 0（实测）；最多再读 8 秒，等到有效再判定。
    local started=GetTickCount()
    repeat
        s.hp,s.maxhp,s.mp,s.maxmp,s.rage,s.school=raw("-- TLBB_BATTLE_VITALS_V1\nlocal m=Player:GetData('MEMPAI') local r=Player:GetData(m==13 and 'ENG' or 'RAGE') return Player:GetData('HP'),Player:GetData('MAXHP'),Player:GetData('MP'),Player:GetData('MAXMP'),(r or -1),m","nnnnnn")
        local settled=type(s.maxhp)=="number" and s.maxhp>=1 and type(s.hp)=="number" and s.hp<=s.maxhp
            and type(s.maxmp)=="number" and type(s.mp)=="number" and s.mp<=s.maxmp
        if settled or GetTickCount()-started>8000 then break end
        Sleep(400)
    until false
    if s.rage<0 then s.rage=nil end
    num(s.maxhp,"人物生命上限",1,1e12);num(s.hp,"人物生命",0,s.maxhp)
    num(s.maxmp,"人物气量上限",0,1e12);num(s.mp,"人物气量",0,s.maxmp)
    if s.pet then
        local p=s.pet
        local h,l,hp,maxhp,happy,on=raw(string.format("return __tlbbBattle.pet(%d)",p.index),"nnnnnn")
        if h~=p.high or l~=p.low or (on~=1 and not (s.petSuspended and on==0)) then
            if cfg.pet then error("出战珍兽身份已变化或已收回，请重新开始任务") end
            s.pet=nil
        else p.hp=num(hp,"珍兽生命",0,num(maxhp,"珍兽生命上限",1,1e12));p.maxhp=maxhp;p.happy=happy
            if cfg.pet and hp<=0 then error("出战珍兽死亡，停止战斗") end
        end
    end
    if s.hp<=0 then error("角色死亡，停止战斗") end
    Support.publish(s)
end
local function find(list,n)
    for _,a in ipairs(list) do if a.name==n then return a end end
end
local function selfIds() return R.host("battle_self_identity") end
local function cast(s,list,selected,kind,client,server)
    for _,name in ipairs(selected) do
        local a=assert(find(list,name),"技能配置失效")
        local current=action(a.index,a.pet)
        assert(current and current.id==a.id and current.name==name,"技能动作已变化，请重新开始任务："..name)
        a.enabled=current.enabled;a.cooldown=current.cooldown
        if a.cooldown==0 and not a.reason then
            if not client then client,server=selfIds() end
            local p=s.pet or {high=0,low=0}
            local result=raw(string.format("return __tlbbBattle.cast(%d,%d,%d,%q,%.0f,%.0f,%d,%d)",a.index,a.pet,a.id,name,p.high,p.low,client,server),"n")
            assert(result>=0,"战斗技能身份 / 目标变化，停止："..name)
            if result==1 then
                s.pending={name=name,action=a,kind=kind,hp=s.hp,mp=s.mp,pet=s.pet and s.pet.hp or 0,at=GetTickCount()}
                R.log("提交"..kind.."："..name.."；等待状态反馈");return true
            end
        end
    end
    return false
end
function Support.tick(s,target)
    Support.refresh(s)
    local now=GetTickCount();local hp=s.hp*100/s.maxhp;local mp=s.maxmp>0 and s.mp*100/s.maxmp or 100
    if s.pending then
        local p=s.pending;local confirmed=(p.kind=="治疗" or p.kind=="珍兽回血") and s.hp>p.hp
            or p.kind=="珍兽回气" and s.mp>p.mp or p.kind=="喂养" and s.pet and s.pet.hp>p.pet
        if p.action then
            local a=action(p.action.index,p.action.pet);assert(a and a.id==p.action.id,"施放后技能身份变化");p.action.cooldown=a.cooldown
            -- 恢复必须观察到对应生命 / 气量增加；冷却开始仅证明技能已提交。
            if p.kind=="自身增益" or p.kind=="珍兽攻击" then confirmed=a.cooldown>0 end
            if p.kind=="峨嵋治疗" then
                p.acknowledged=p.acknowledged or EmeiSupport.confirm(s,p,a)
                local ready=raw("return __tlbbBattle.flag(DataPool:IsCanDoAction())","n")
                confirmed=p.acknowledged and ready==1
            end
        end
        if confirmed then
            R.log("已确认"..p.kind.."状态反馈："..p.name);s.pending=nil;s.next=now+(p.kind=="峨嵋治疗" and 0 or 1500)
        elseif now-p.at>=8000 then error("未确认技能 / 喂养反馈，停止且不重复提交："..p.name)
        else return true end
    end
    if s.next and now<s.next then
        if s.emei and hp<=math.max(tonumber(cfg.emei_self_priority_percent or 35),tonumber((TaskConfig or {}).combat_min_hp or 25)) then s.next=nil
        else
            if hp<=tonumber((TaskConfig or {}).combat_min_hp or 25) then error("角色血量低于停止阈值，恢复间隔尚未结束") end
            return true
        end
    end
    if s.emei and EmeiSupport.tick(s) then return true end
    if not s.emei and cfg.heal_enabled and hp<=tonumber(cfg.heal_percent or 60) and cast(s,s.skills,s.heals,"治疗") then return true end
    if cfg.pet and not s.petSuspended then
        local pet=assert(s.pet,"未检测到出战珍兽")
        if pet.hp<=0 then error("出战珍兽死亡，停止战斗") end
        local percent=pet.hp*100/pet.maxhp
        if hp<=tonumber(cfg.heal_percent or 60) and percent>=tonumber(cfg.pet_sacrifice_min_percent or 65)
            and cast(s,pet.skills,s.petHP,"珍兽回血") then return true end
        if hp<=tonumber((TaskConfig or {}).combat_min_hp or 25) then error("角色血量低于停止阈值，无可用恢复技能") end
        if cfg.pet_feed and percent<=tonumber(cfg.pet_feed_percent or 50) then
            local result=raw(string.format("-- TLBB_BATTLE_FEED_V1\nlocal h,l=Pet:GetGUID(%d) if h~=%.0f or l~=%.0f or __tlbbBattle.flag(Pet:GetIsFighting(%d))~=1 then return -2 end Pet:Feed(%d) return 1",pet.index,pet.high,pet.low,pet.index,pet.index),"n")
            assert(result==1,"喂养前珍兽身份发生变化")
            s.pending={name=pet.name,kind="喂养",pet=pet.hp,at=now};R.log("已提交珍兽喂养，等待生命增加");return true
        end
        if percent<=tonumber(cfg.pet_stop_percent or 20) then error("珍兽生命低于停止阈值") end
        if pet.happy<60 then error("珍兽快乐度不足 60，请人工驯养") end
        if mp<=tonumber(cfg.mp_percent or 30) and percent>=tonumber(cfg.pet_sacrifice_min_percent or 65)
            and cast(s,pet.skills,s.petMP,"珍兽回气") then return true end
    end
    if hp<=tonumber((TaskConfig or {}).combat_min_hp or 25) then error("角色血量低于停止阈值，无可用恢复技能") end
    -- Configured self buffs target the player and remain useful in support-only mode.
    if cfg.buff_enabled then
        for _,n in ipairs(s.buffs) do
            if not s.lastbuff[n] or now-s.lastbuff[n]>=tonumber(cfg.buff_interval_seconds or 60)*1000 then
                if cast(s,s.skills,{n},"自身增益") then s.lastbuff[n]=now;return true end
            end
        end
    end
    if not Support.outputEnabled(s) then return false end
    if cfg.pet and not s.petSuspended and target and target.id>=0 and now-(s.petLast or -10000)>=3000 then
        local status,id,server=R.call(R.codes.CombatScan,{target.scene,target.id,target.server},{target.x,target.y,target.radius})
        if status==1 and id==target.id and server==target.server and cast(s,s.pet.skills,s.petSkills,"珍兽攻击",target.id,target.server) then s.petLast=now;return true end
    end
    return false
end
function Support.outputAllowed(s,name)
    local a=find(s.skills,name);assert(a,"未找到已学输出技能："..name)
    assert(not a.reason,name.."："..tostring(a.reason))
    for _,list in ipairs({s.heals,s.buffs,s.petHP,s.petMP,s.emei and s.emei.heals or {}}) do
        for _,n in ipairs(list) do assert(n~=name,"治疗 / 增益技能不能同时配置为输出："..name) end
    end
    return a.index
end
function Support.outputEnabled(s) if s.emei then return s.emei.attack end return cfg.heal_only~=true end
function Support.inspect()
    local s=Support.new(true);Support.publish(s);R.log("战斗状态与已学技能读取完成；没有施放动作")
end
BattleSupport=Support
