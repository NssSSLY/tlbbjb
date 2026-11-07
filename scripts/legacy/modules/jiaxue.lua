-- 峨嵋加血机, written from the reference rules (原脚本源码/Script64/常用/峨嵋加血机.lua). Stays by the leader and lets the battle support heal.
-- 定位 items and cross-map following are not ported. This task owns its stages and receipts; it does not load the vendor framework.
-- docs/BATTLE_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Jiaxue={}
local R=assert(CombatRuntime)
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end

function Jiaxue.run()
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local minutes=int(tonumber(cfg.jiaxue_minutes or 60),1,115,'运行时长')
    local dist=int(tonumber(cfg.bjk38 or 7),1,30,'跟随距离')
    for _,k in ipairs({'xzk96','xzk195','xzk104','xzk106','xzk07','xzk95'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','加血机开关无效：'..k) end
    if api.school()~=4 then error('加血机：只有峨嵋派可以使用',0) end
    local def={name='加血机',mission='加血机',map='',npc={name='',x=0,y=0,scene=0},bosses={}}
    function def.inside() return false end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('加血机 · '..s) end end
    local function world() return assert(api.world(),'加血机场景不可读') end
    local deadline=api.now()+minutes*60000
    local function body()
        api.validate(def,cfg)
        local T,scene
        local own,ownServer=R.host('battle_self_identity')
        local selfObj={id=own,server_id=ownServer}
        local lastPos,lastSkill=nil,-100000
        while api.now()<deadline do
            local p=world()
            if p.scene~=scene then scene=p.scene;T=DungeonTactics.new(api,scene,{}) end
            local hp=GetLuaValue("-- jiaxue:hp\nreturn Player:GetData('HP')",'n')
            if type(hp)=='number' and hp<=0 then
                if cfg.xzk95==true then log('已死亡，出窍');T.reliveOut() else log('已死亡，等待救起') end
            else
                local buffs=api.buffs()
                if cfg.xzk104==true and T.hasBuff(buffs,'传送保护：无敌') then log('传送保护中')
                else
                    local moving=lastPos~=nil and ((p.x-lastPos.x)^2+(p.y-lastPos.y)^2)>0.25
                    if cfg.xzk07==true and T.hasBuff(buffs,'虚弱：所受伤害放大') and api.now()-lastSkill>=1000 then
                        lastSkill=api.now();log('被放大，呆若木鸡');T.useSkill('呆若木鸡',selfObj)
                    end
                    if cfg.xzk106==true and api.now()-lastSkill>=1000 then
                        for _,o in ipairs(T.enemyPlayers()) do
                            if o.hp~=0 and o.dst<4 then lastSkill=api.now();log('月落西山');T.useSkill('月落西山',o);break end
                        end
                    end
                    if not (cfg.xzk195==true and moving) then api.maintain() end
                    -- Support may have yielded; the world can have changed under it.
                    local q=world()
                    if cfg.xzk96==true and q.scene==scene then
                        local leaderId=DungeonTactics.leaderId()
                        if leaderId and leaderId~=own then
                            p=q
                            for _,o in ipairs(T.players()) do
                                if o.id==leaderId and ((p.x-o.x)^2+(p.y-o.y)^2)>dist*dist then
                                    log('跟随队长');T.move(math.floor(o.x),math.floor(o.y));break
                                end
                            end
                        end
                    end
                end
            end
            lastPos=p
            api.sleep(300)
        end
        return {status='done',message='加血机运行满 '..minutes..' 分钟'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'加血机停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
