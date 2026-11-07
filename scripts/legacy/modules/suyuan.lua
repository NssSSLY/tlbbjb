-- The 溯缘镜 stories: 千百渡他, 楚歌难渡, 虞花苦渡, 渡别乌江, written from the reference rules (原脚本源码/Script64/活动/*.lua). One scene, one
-- entrance; each story is driven by what stands on the field, and the entrance's refusal prompt ends the task.
-- This task owns its stages and receipts; it does not load the vendor framework. Reference fields this program cannot read
-- (title, facing, trap names) are replaced by what can be observed; docs/ACTIVITY_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Suyuan={}
local R=assert(CombatRuntime)
local TOWN,SCENE=1075,1079
local KINDS={
    qianbai={title='千百渡他',enter='#{QXFB_260529_05}',refuse={'QXFB_260529_347','QXFB_260529_15'}},
    chuge={title='楚歌难渡',enter='#{QXFB_260529_05}',refuse={'QXFB_260529_347','QXFB_260529_15'},prep={{'乐师',177,134,'#{QXZH_250528_34}'}},flute=true},
    yuhua={title='虞花苦渡',enter='#{QXFB_260529_04}',refuse={'QXFB_260529_347','QXFB_260529_15'},prep={{'卖花女',122,134,'#{QXZH_250528_42}'},{'花匠',174,188,'#{QXZH_250528_113}'}}},
    wujian={title='渡别乌江',enter='#{QXFB_260529_03}',refuse={'QXFB_260529_347','QXFB_260529_15','QXFB_260529_53'},prep={{'史官',114,48,'#{QXZH_250528_53}'}}},
}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end

-- variant: {label='普通',enter='#{...}',prep={...},leaderOnly=true}, for the other difficulties of a story.
function Suyuan.run(kind,variant)
    local K=assert(KINDS[kind],'溯缘镜任务类型无效')
    variant=variant or {}
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local title=K.title..(variant.label and ('('..variant.label..')') or '')
    local enterKey=variant.enter or K.enter
    local prepList=variant.prep or K.prep or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 20),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 1),1,6,'队伍人数')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={'项王','虞姬','怨骨虞姬'}
    local def={name=title,mission=title,map='溯缘',npc={name='溯缘镜',x=208,y=51,scene=TOWN},bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log(title..' · '..s) end end
    local function world() return assert(api.world(),title..'场景不可读') end
    local function gathered()
        if team<=1 then return true end
        return api.teamReady(team) and api.teamTogether()
    end

    local function fight()
        local T=DungeonTactics.new(api,SCENE,bossNames);T.watch({'QXFB_260529_168'});T.readMessages()
        local best,list,enemy=T.best,T.list,T.enemy
        local start,lastProgress,lastTalk,hps,settled,quietAt=api.now(),api.now(),-100000,{},false,nil
        local school=api.school();local emei=school==4
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        local over,healAt=false,-100000
        local lastSay,repeats='',0
        local function progress() lastProgress=api.now() end
        -- One conversation at a time. The same one three times with nothing changing is a stop, not progress.
        local function talk(name,x,y,keys)
            if api.now()-lastTalk<8000 then return end
            local say=name..':'..table.concat(keys,',')
            if say==lastSay then
                repeats=repeats+1
                assert(repeats<3,title..'：'..name..'的对话重复 3 次没有变化，已停止')
            else lastSay,repeats=say,0 end
            lastTalk=api.now();T.stop();T.clearMove();log(name..' · 对话')
            if pcall(api.openNpc,{name=name,x=math.floor(x),y=math.floor(y),scene=SCENE}) then
                api.sleep(500)
                for _,k in ipairs(keys) do
                    api.selectOption({k},true)
                    api.sleep(800)
                end
            end
            if world().scene==SCENE then CloseAllWindow() end
            if repeats==0 then progress() end
        end
        local function hostile(all,skip)
            local t
            for _,o in ipairs(all) do
                if enemy(o) and not (skip and skip[o.name]) and o.name~='' and (not t or o.dst<t.dst) then t=o end
                if enemy(o) and (not hps[o.id] or o.hp<hps[o.id]) then hps[o.id]=o.hp;repeats=0;lastSay='';progress() end
            end
            return t
        end
        local F={}
        F.qianbai=function(all,p)
            local t=hostile(all,{['项王']=true})
            if t then quietAt=nil;log('战斗');T.attack(t);return end
            quietAt=quietAt or api.now()
            if api.now()-quietAt<15000 then log('等待刷新');T.stop();return end
            if best(all,'项王') then talk('项王',186,121,{'#{QXFB_260529_29}'})
            else talk('溯缘镜',189,136,{'#{QXFB_260529_20}','#{QXFB_260529_25}'}) end
        end
        F.chuge=function(all,p)
            local helm={['船舵']=true,['船舵手']=true,['魔化舵手']=true,['敌方船舵']=true}
            if memberIndex==1 or memberIndex==2 then
                local t;for _,o in ipairs(all) do if helm[o.name] and enemy(o) and (not t or o.dst<t.dst) then t=o end end
                if t then log('打船舵');hostile(all);T.attack(t);return end
                if best(all,'船舵',function(o) return not enemy(o) end) and d2(p,77,111)>36 then T.stop();T.move(77,111);return end
            end
            if T.escape(T.traps(),4,77,111,10,2) then log('躲流星');T.stop();progress();return end
            if emei and api.now()-healAt>=700 then
                for _,name in ipairs({'船舵手','船舵'}) do
                    local h=best(all,name,function(o) return not enemy(o) and o.hp>0 and o.hp<60 and o.dst<30 end)
                    if h then
                        healAt=api.now();log('治疗 '..name)
                        if h.dst>15 then T.stop();T.move(math.floor(h.x),math.floor(h.y)) else T.useSkill('清心普善咒',h) end
                        progress();return
                    end
                end
            end
            local t=hostile(all,{['船体残骸']=true})
            if t then
                quietAt=nil
                if not settled then
                    local a=memberIndex*math.pi/3
                    if T.move(math.floor(77+5*math.cos(a)+0.5),math.floor(111+5*math.sin(a)+0.5)) then log('分散');return end
                    settled=true
                end
                if t.dst<30 then log('战斗');T.attack(t) else T.stop() end
                return
            end
            if best(all,'船舵') and best(all,'船舵手') then log('战斗中');T.stop();return end
            quietAt=quietAt or api.now()
            if api.now()-quietAt<3000 then T.stop();return end
            if best(all,'项王') then talk('溯缘镜',189,136,{'#{QXFB_260529_30}','#{QXFB_260529_303}'})
            elseif best(all,'船舵') then talk('船舵',77,106,{'#{QXFB_260529_32}'})
            else
                local body=best(all,'虞姬尸体')
                if body then talk('虞姬尸体',body.x,body.y,{'#{QXFB_260529_43}','#{QXFB_260529_35}'});return end
                local m=best(all,'溯缘镜')
                if m then talk('溯缘镜',m.x,m.y,{'#{QXFB_260529_20}','#{QXFB_260529_25}','#{QXFB_260529_304}','#{QXFB_260529_279}','#{QXFB_260529_30}'}) end
            end
        end
        F.yuhua=function(all,p)
            -- The panel event carries the 虞姬 counters; the same hook as the reference, kept on the game's own handler.
            local gauge=GetLuaValue([[-- suyuan:gauge
                if _QiXi_PVE_Info_OnEvent==nil and type(QiXi_PVE_Info_OnEvent)=='function' then
                    __QiXi_PVE_Info='' _QiXi_PVE_Info_OnEvent=QiXi_PVE_Info_OnEvent
                    function QiXi_PVE_Info_OnEvent(event)
                        if event=='UI_COMMAND' and tonumber(arg0)==05123801 then
                            local s=Get_XParam_STR(0)
                            for i=1,4 do s=s..'|'..Get_XParam_STR(i) end
                            for i=1,12 do s=s..'|'..tostring(Get_XParam_INT(i)) end
                            __QiXi_PVE_Info=s
                        end
                        _QiXi_PVE_Info_OnEvent(event)
                    end
                end
                return __QiXi_PVE_Info or '']],'s')
            local fields={};for part in (tostring(gauge or '')..'|'):gmatch('([^|]*)|') do fields[#fields+1]=part end
            local full=fields[11]==fields[12]
            local yj=best(all,'虞姬',function(o) return o.hp>0 end)
            if yj then talk('虞姬',yj.x,yj.y,{'#{QXFB_260529_257}'});return end
            local body=best(all,'虞姬尸体')
            if not body then
                local m=best(all,'溯缘镜')
                if m then talk('溯缘镜',m.x,m.y,{'#{QXFB_260529_279}','#{QXFB_260529_33}','#{QXFB_260529_30}'}) end
                return
            end
            local boss=best(all,'怨骨虞姬',enemy)
            if boss then
                if not hps[boss.id] or boss.hp<hps[boss.id] then hps[boss.id]=boss.hp;progress() end
                if T.escape(T.traps(),5,boss.x,boss.y,15,3) then log('怨骨虞姬 · 躲陷阱');T.stop();progress();return end
                local add
                for _,n in ipairs({'化骨伥鬼','怨血镜魔'}) do add=add or best(all,n,enemy) end
                if add then log('怨骨虞姬 · 打小怪');hostile(all);T.attack(add);return end
                -- The easy story leaves this last stretch to the leader alone.
                if full and boss.hp>15 and (not variant.leaderOnly or GetTeamCount()==0 or api.isLeader()) then log('怨骨虞姬 · 战斗');T.attack(boss)
                else log('怨骨虞姬 · 等待');T.stop() end
                return
            end
            local npc=best(all,'怨骨虞姬',function(o) return o.hp>0 end)
            if npc then talk('怨骨虞姬',npc.x,npc.y,{'#{QXFB_260529_231}'})
            else talk('虞姬尸体',body.x,body.y,{'#{QXFB_260529_43}','#{QXFB_260529_35}'}) end
        end
        F.wujian=function(all,p)
            local boss=best(all,'项王',enemy)
            local npc=best(all,'项王',function(o) return o.hp>0 and not enemy(o) end)
            local corpse=best(all,'项王',function(o) return o.hp==0 end)
            local yj=best(all,'虞姬',function(o) return o.hp>0 end)
            if corpse then over=true end
            if not boss and not npc and d2(p,186,118)<900 and not yj then over=true end
            if over then
                log('前往出口')
                if T.move(67,221) then T.stop();return end
                local m=best(all,'溯缘镜')
                if m then talk('溯缘镜',m.x,m.y,{'#{QXFB_260529_20}','#{QXFB_260529_25}'}) end
                return
            end
            local add=best(all,'营地魔兵',enemy)
            if boss then
                if not hps[boss.id] or boss.hp<hps[boss.id] then hps[boss.id]=boss.hp;progress() end
                -- The reference reads his facing and stands behind him; facing is unreadable, so step 3 clear and hold.
                if T.within('QXFB_260529_168',6000) then
                    if T.escape({boss},3,boss.x,boss.y,10,2) then progress() end
                    log('项王 · 机制中停手');T.stop();return
                end
                if T.escape(T.traps(),5,boss.x,boss.y,10,3) then log('项王 · 躲陷阱');T.stop();progress();return end
                if add then log('项王 · 打魔兵');T.attack(add);return end
                log('项王 · 战斗');T.attack(boss);return
            end
            if add then log('打魔兵');T.attack(add);return end
            if npc then
                if yj then talk('项王',npc.x,npc.y,{'#{QXFB_260529_312}'})
                else talk('项王',npc.x,npc.y,{'#{QXFB_260529_287}'}) end
                return
            end
            if yj then talk('虞姬',yj.x,yj.y,{'#{QXFB_260529_258}','#{QXFB_260529_258}'});return end
            local m=best(all,'溯缘镜')
            if m then talk('溯缘镜',m.x,m.y,{'#{QXFB_260529_36}','#{QXFB_260529_279}','#{QXFB_260529_33}','#{QXFB_260529_30}'}) end
        end
        while true do
            if T.readMessages() then progress() end
            local p=world()
            if p.scene~=SCENE then return end
            assert(api.now()-start<battleMs,title..'战斗超过时限')
            api.alive(minimum,title..'：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic()
            F[kind](T.rows(),p)
            if world().scene==SCENE then
                api.maintain()
                local q=world()
                if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;progress() end
                assert(api.now()-lastProgress<180000,title..'阶段没有进展：'..phase)
            end
            api.sleep(250)
        end
    end

    local function prepare()
        for _,q in ipairs(prepList) do
            if pcall(api.openNpc,{name=q[1],x=q[2],y=q[3],scene=TOWN}) then
                api.sleep(500);api.selectOption({q[4]},true);api.sleep(800)
            end
            CloseAllWindow()
        end
        if K.flute then
            local T=DungeonTactics.new(api,TOWN,bossNames)
            local flute=T.best(T.rows(),'风下竹笛')
            if flute then
                MoveTo(math.floor(flute.x),math.floor(flute.y),TOWN)
                local used,missing=T.useSkill(5999,flute)
                if missing then api.log(title..'：技能列表没有 5999，跳过风下竹笛') end
                if used then api.sleep(7000) end
            end
        end
    end
    local function body()
        api.validate(def,cfg)
        local prepared=false
        while completed<rounds do
            if world().scene~=SCENE then
                api.space();api.prepareBattle()
                if not prepared then prepared=true;prepare() end
                api.openNpc(def.npc)
                log('等待队伍集合');local began=api.now()
                while not gathered() do
                    assert(api.now()-began<math.max(waitMs,70000),title..'：等待队伍集合超时')
                    api.maintain();api.sleep(250)
                end
                local T=DungeonTactics.new(api,TOWN,bossNames);T.watch(K.refuse);T.readMessages()
                api.selectOption({enterKey},true);api.sleep(1000)
                api.selectOption({'#{QXFB_260529_06}'},true);api.sleep(1000)
                T.readMessages()
                local refused=false;for _,k in ipairs(K.refuse) do if T.seenAt[k] then refused=true end end
                if refused then
                    CloseAllWindow()
                    return {status=completed>0 and 'done' or 'already_done',message=title..'：入口提示次数已用完；本次完成 '..completed..' 轮'}
                end
                CloseAllWindow()
                log('确认进入副本');began=api.now()
                while world().scene~=SCENE do
                    assert(api.now()-began<math.max(waitMs,60000),title..'：选择后没有进入副本，未重复发送')
                    api.maintain();api.sleep(500)
                end
            end
            fight();completed=completed+1;log('本轮完成（'..completed..'）')
        end
        return {status='done',message=title..'完成 '..completed..' 轮'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,title..'停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
