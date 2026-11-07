-- 团战打架 (自动打架), written from the reference rules (原脚本源码/Script64/常用/团战打架.lua). Attacks enemy players the game itself rates as enemies,
-- limited by lists; declaring war is a separate switch. Repair, 定位 items and the pet fallback are not ported.
-- This task owns its stages and receipts; it does not load the vendor framework. docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Tuanzhan={}
local R=assert(CombatRuntime)
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function nameSet(text)
    -- A byte class cannot hold a Chinese comma: its bytes would split other characters.
    local out={};for w in (tostring(text or ''):gsub('，',' '):gsub(',',' ')):gmatch('%S+') do out[w]=true end
    return out
end

function Tuanzhan.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local minutes=int(tonumber(cfg.tuanzhan_minutes or 60),1,115,'运行时长')
    local follow=int(tonumber(cfg.bjk38 or 8),1,30,'跟随距离')
    for _,k in ipairs({'xzk224','xzk96','xzk135','xzk220','xzk221','xzk222','xzk195','xzk225','xzk95'}) do
        assert(cfg[k]==nil or type(cfg[k])=='boolean','打架开关无效：'..k)
    end
    if cfg.xzk221~=true and cfg.xzk222~=true and cfg.xzk220~=true then error('自动打架：全杀、名单、宣战都没有打开，不会攻击任何人',0) end
    local priority,declare=nameSet(cfg.bjk151),nameSet(cfg.bjk157)
    local mingdan,followList=nameSet(cfg.bjk156),nameSet(cfg.bjk159)
    local def={name='自动打架',mission='自动打架',map='',npc={name='',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    local phase=''
    local function log(s) if phase~=s then phase=s;api.log('自动打架 · '..s) end end
    local function world() return assert(api.world(),'打架场景不可读') end
    local deadline=api.now()+minutes*60000
    local school=api.school()
    local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
    local function nameOf(id)
        local n=GetLuaValue(string.format("-- tuanzhan:name\nreturn Target:GetNpcName(%d) or ''",id),'s')
        return type(n)=='string' and n or ''
    end
    -- Enemies this task may attack: everyone with 全杀, otherwise only the kill list.
    local function candidates(T)
        local out={}
        for _,o in ipairs(T.enemyPlayers()) do
            if o.hp~=0 then
                o.name=nameOf(o.id)
                if cfg.xzk221==true or (cfg.xzk222==true and mingdan[o.name]) or (cfg.xzk220==true and declare[o.name]) then out[#out+1]=o end
            end
        end
        return out
    end
    local function choose(T,list)
        local best,score
        for _,o in ipairs(list) do
            local invincible,magnified=T.playerState(o)
            if not invincible then
                local s=(priority[o.name] and 0 or 4000)+(magnified and 0 or 2000)+((o.hp>0 and o.hp<30) and 0 or 1000)+o.dst
                if not score or s<score then best,score=o,s end
            end
        end
        return best
    end
    -- Stay near the leader or a listed player. True once close enough, or when there is nobody to follow.
    local function keepClose(T,p,own)
        if cfg.xzk224~=true then return true end
        local leaderId
        if cfg.xzk96==true then leaderId=DungeonTactics.leaderId() end
        local target
        for _,o in ipairs(T.players()) do
            if o.id~=own and (o.id==leaderId or followList[nameOf(o.id)]) then
                local d=(p.x-o.x)^2+(p.y-o.y)^2
                if not target or o.id==leaderId or d<target.d then target={x=o.x,y=o.y,d=d} end
                if o.id==leaderId then break end
            end
        end
        if not target then return true end
        if target.d>=follow*follow then log('跟随');T.move(math.floor(target.x),math.floor(target.y));return false end
        return true
    end
    local function declareWar(T,lastDeclared)
        if cfg.xzk220~=true or next(declare)==nil then return false end
        for _,o in ipairs(T.players()) do
            if declare[nameOf(o.id)] and api.now()-(lastDeclared[o.id] or -100000)>=30000 then
                lastDeclared[o.id]=api.now();log('宣战')
                GetLuaValue(string.format([[-- tuanzhan:declare
                    local e=PlayerList_Env
                    local f=(type(e)=='table' and e.SetMainTargetFromList) or SetMainTargetFromList
                    if type(f)=='function' and f(%d,true,false)==1 then Player:PVP_Challenge(2) end]],o.id),'',0)
                return true
            end
        end
        return false
    end
    local function body()
        api.validate(def,cfg)
        local T,scene
        local own=R.host('battle_self_identity')
        local lastPos,lastDeclared=nil,{}
        while api.now()<deadline do
            local p=world()
            if p.scene~=scene then scene=p.scene;T=DungeonTactics.new(api,scene,{}) end
            local hp=GetLuaValue("-- tuanzhan:hp\nreturn Player:GetData('HP')",'n')
            if type(hp)=='number' and hp<=0 then
                if cfg.xzk95==true then log('已死亡，出窍');T.reliveOut() else log('已死亡，等待救起') end
            else
                local moving=lastPos~=nil and ((p.x-lastPos.x)^2+(p.y-lastPos.y)^2)>0.25
                if cfg.xzk195==true and moving then log('移动中不攻击')
                else
                    local close=true
                    if cfg.xzk135==true then close=keepClose(T,p,own) end
                    if close then
                        local t=choose(T,candidates(T))
                        if t then
                            if cfg.xzk225==true and t.dst>(melee and 5 or 9) then log('追击 '..t.name);T.move(math.floor(t.x),math.floor(t.y))
                            else log('攻击 '..t.name);T.clearMove();T.strikePlayer(t) end
                        elseif not declareWar(T,lastDeclared) and cfg.xzk135~=true then
                            keepClose(T,p,own)
                        end
                    end
                end
            end
            lastPos=p
            api.maintain();api.sleep(250)
        end
        return {status='done',message='自动打架运行满 '..minutes..' 分钟'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'自动打架停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
