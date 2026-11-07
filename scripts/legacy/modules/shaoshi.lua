-- 少室山 full flow, written from the reference rules (原脚本源码/Script64/副本/少室山(大理).lua, docs/SHAOSHI_REFERENCE.md).
-- This task owns its stages and receipts; it does not load the vendor framework.
-- Reference fields this program cannot read are replaced by what can be observed, and named in docs/SHAOSHI_HANDOFF.md:
-- boss target (庄聚贤 狂暴), boss state (慕容复), 达魔正心 title, and trap names.
LoadScript('yanzi_api')
LoadScript('dungeon_pet_guard')
Shaoshi={}
local R=assert(CombatRuntime)
local SCENE=566
local modes={
    ['普通']={option='#{CJG_101231_70}',suffix='',campaign='少室山',page=2},
    ['初级']={option='#{XKFB_250115_06}',suffix='·闻恶',campaign='少室山·初级',page=4},
    ['中级']={option='#{XKFB_250115_48}',suffix='·识恶',campaign='少室山·中级',page=4},
    ['高级']={option='#{XKFB_250115_07}',suffix='·罚恶',campaign='少室山·高级',page=4},
}
local BOSSES={'鸠摩智','庄聚贤','慕容复','丁春秋','萧远山','慕容博'}
local BOSS_SET={};for _,n in ipairs(BOSSES) do BOSS_SET[n]=true end
local NOT_MOBS={['信徒']=true,['冰蚕']=true,['血咒巫蛊']=true,['心魔']=true,['黑色心魔']=true,['达魔正心']=true,['寒冰']=true,['萧远山与慕容博']=true}
local STAGE5={['扫地神僧']=true,['萧远山']=true,['慕容博']=true,['心魔']=true,['黑色心魔']=true,['达魔正心']=true,['少林弟子']=true}
local entrance={name='朱丹臣',x=69,y=60,scene=2}
local OPEN='#{CJG_101231_375}'
-- Stage-over and mechanism prompts. Each is matched by its key or its dictionary text.
local KEYS={'CJG_101231_211','CJG_101231_212','CJG_101231_234','CJG_101231_143','CJG_101231_213','SSS_ZJ_120109_02','SSS_ZJ_120109_50',
    'CJG_101231_140','CJG_101231_141','CJG_101231_82','CJG_101231_83','SSS_ZJ_120109_14','SSS_ZJ_120109_37','SSS_ZJ_120109_39',
    'SSS_ZJ_120109_42','SSS_ZJ_120109_45','SSS_ZJ_120109_46','GGSS_160905_03'}
local DONE={{'CJG_101231_211'},{'CJG_101231_212','CJG_101231_234'},{'CJG_101231_143','CJG_101231_213'},{'SSS_ZJ_120109_02'},{'SSS_ZJ_120109_50'}}
local ZOUWEI={{122,39},{128,43},{128,50},{122,53},{116,50},{116,43}}
local OUTER={{122,35},{132,41},{132,52},{122,57},{112,52},{112,41}}
-- 丁春秋 绕场 route (xzk47): outer ring inward.
local LOOP={{110,115},{110,120},{110,125},{110,130},{110,135},{110,140},{115,140},{120,140},{125,140},{130,140},{135,140},{140,140},
    {145,140},{145,135},{145,130},{145,125},{145,120},{145,115},{140,115},{135,115},{130,115},{125,115},{120,115},{115,115},
    {115,120},{115,125},{115,130},{115,135},{120,135},{125,135},{130,135},{135,135},{140,135},{140,130},{140,125},{140,120},
    {135,120},{130,120},{125,120},{120,120},{120,125},{120,130},{125,130},{130,130},{135,130},{135,125},{130,125},{125,125}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end
local function enemy(o) return o~=nil and o.class=='怪物' and o.hp>0 end

local function newApi()
    local api=YanziApi.new()
    api.campaign=function(mode,refresh)
        if refresh then
            GetLuaValue([[-- shaoshi:campaign-refresh
                local e=PlayerQuicklyEnter_Env
                local f=type(e)=='table' and e.PlayerQuicklyEnter_ActivityShedule or PlayerQuicklyEnter_ActivityShedule
                if type(f)~='function' then error('campaign refresh API unavailable') end
                f()
            ]],'',0)
            api.sleep(500)
        end
        local used,limit,kind,matches=GetLuaValue(string.format([[-- shaoshi:campaign
            local page,want=%d,%q
            local n=GetNewCampaignCount(page)
            if type(n)~='number' or n~=math.floor(n) or n<0 or n>256 then error('campaign list unavailable') end
            local used,maximum,today,matches,exact=-1,-1,-1,0,false
            for i=0,n-1 do
                local s=EnumNewCampaign(page,i,'name')
                if type(s)~='string' then error('campaign name unavailable') end
                local same=s==want
                if same or (not exact and string.find(s,want,1,true)) then
                    if same then exact=true matches=1 else matches=matches+1 end
                    used=EnumNewCampaign(page,i,'MyCampaingCount')
                    maximum=EnumNewCampaign(page,i,'PlayNum') today=EnumNewCampaign(page,i,'IsToday')
                end
            end
            return used,maximum,today,matches
        ]],mode.page,mode.campaign),'nnnn')
        assert(matches==1,'活动页没有唯一的'..mode.campaign..'记录')
        assert(type(used)=='number' and used==math.floor(used) and used>=0 and used<=1000
            and type(limit)=='number' and limit==math.floor(limit) and limit>=1 and limit<=1000 and used<=limit
            and type(kind)=='number' and kind>=0 and kind<=3,'少室山活动次数无效')
        assert(kind~=2,'少室山活动当前不可参与')
        return {used=used,limit=limit,kind=kind,name=mode.campaign}
    end
    -- In-scene members at or above the HP percentage. Off-scene members have no reading and do not block.
    api.teamHealthy=function(percent)
        local ok=GetLuaValue(string.format([[-- shaoshi:team-hp
            local need=%d local n=DataPool:GetTeamMemberCount()
            if type(n)~='number' or n<0 or n>6 then error('team count unavailable') end
            for i=0,n-1 do
                local inside=DataPool:IsTeamMemberInScene(i)
                if inside==1 or inside==true then
                    local name,school,hp,maxhp=DataPool:GetTeamMemberInfo(i)
                    if type(hp)~='number' or type(maxhp)~='number' or maxhp<=0 then error('team health unavailable') end
                    if hp*100<need*maxhp then return 0 end
                end
            end
            return 1
        ]],percent),'n')
        assert(ok==0 or ok==1,'队员血量不可读');return ok==1
    end
    -- Server IDs of 峨嵋 members in this scene, for the 血祭 cooldown wait.
    api.emeiMembers=function()
        local text=GetLuaValue([[-- shaoshi:emei-members
            local n=DataPool:GetTeamMemberCount() local rows=''
            if type(n)~='number' or n<0 or n>6 then error('team count unavailable') end
            for i=0,n-1 do
                local name,school=DataPool:GetTeamMemInfoByIndex(i)
                local inside=DataPool:IsTeamMemberInScene(i)
                if school==4 and (inside==1 or inside==true) then
                    local server=DataPool:GetTeamMemberObjIDNamePortInfo(i)
                    rows=rows..string.format('%.0f\t%.0f\n',Target:GetServerId2ClientId(server),server)
                end
            end
            return rows
        ]],'s')
        assert(type(text)=='string','峨嵋队员不可读')
        local out={};for id,server in text:gmatch('(%d+)\t(%d+)\n') do out[#out+1]={id=tonumber(id),server_id=tonumber(server)} end
        return out
    end
    api.confirmBox=function()
        GetLuaValue([[-- shaoshi:confirm
            local e=MessageBox_Self_Env
            if type(e)=='table' and e.this and e.this:IsVisible() then
                local f=e.MessageBox_Self_OK_Clicked or MessageBox_Self_OK_Clicked
                if type(f)~='function' then error('message box handler unavailable') end
                f()
            end
        ]],'',0)
    end
    api.school=function()
        local id=GetLuaValue("-- shaoshi:school\nreturn Player:GetData('MEMPAI')",'n')
        assert(type(id)=='number' and id==math.floor(id) and id>=0 and id<=31,'门派不可读')
        return id
    end
    -- First dialog line, where the reference looks for today's-limit text. Empty when no dialog is open.
    api.dialogFirst=function()
        local text=GetLuaValue([[-- shaoshi:dialog-first
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local a,b,c,d,t=DataPool:GetNPCEventList_Item(0)
            if type(t)=='string' then return t end
            return ''
        ]],'s')
        assert(type(text)=='string','NPC 对话不可读');return text
    end
    return api
end
Shaoshi.newApi=newApi

function Shaoshi.run(injected)
    local api=injected or newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3000),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 6),3,6,'队伍人数')
    local mode=assert(modes[cfg.sss_type or '普通'],'少室山难度无效')
    for _,k in ipairs({'xzk47','xzk189','shaoshi_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','少室山开关无效：'..k) end
    local ladcq=cfg.xzk47==true
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local def={name='少室山',mission='少室山',map='少室山',npc=entrance,bosses={}}
    function def.inside(p) return p.scene==SCENE end
    for _,n in ipairs(BOSSES) do def.bosses[#def.bosses+1]=n;if mode.suffix~='' then def.bosses[#def.bosses+1]=n..mode.suffix end end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('少室山 · '..s) end end
    local function world() return assert(api.world(),'少室山场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('少室山：'..label..'超时',0)
    end
    local function dict(key)
        local text=tostring(GetDictionaryString(key) or ''):gsub('#c%x%x%x%x%x%x',''):gsub('#%a',''):gsub('^%s+',''):gsub('%s+$','')
        return text
    end
    local function rows()
        local all=api.objects();assert(type(all)=='table' and #all<=512,'少室山对象不可读')
        local result={}
        for _,o in ipairs(all) do
            local name=tostring(rawget(o,'name') or '')
            for _,base in ipairs(BOSSES) do
                for _,variant in pairs(modes) do
                    if variant.suffix~='' and name==base..variant.suffix then
                        assert(variant==mode,'少室山首领后缀与所选难度不符：'..name)
                        name=base
                    end
                end
            end
            result[#result+1]={id=o.id,server_id=o.server_id,x=o.x,y=o.y,hp=o.hp,dst=o.dst,class=o.class,hostile=o.hostile,name=name}
        end
        return result
    end
    -- Nearest object of a name; same-name objects are normal here (NPC and fighting forms, several 心魔).
    local function best(all,name,accept)
        local found
        for _,o in ipairs(all) do
            if o.name==name and (not accept or accept(o)) and (not found or o.dst<found.dst) then found=o end
        end
        return found
    end
    local function sameCampaign(a,b)
        assert(a.name==b.name and a.limit==b.limit and b.used>=a.used,'少室山活动记录发生变化或次数回退')
    end
    local function gather(point)
        wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() and api.teamNear(point,20) end)
    end

    local function fight(before)
        local ctx=api.beginBattle(def,SCENE).combat;local pet=DungeonPetGuard.new()
        local all_skills={};for _,s in ipairs(ctx.skills) do all_skills[#all_skills+1]=s end
        local disabled={}
        local function applyDisabled()
            local list={};for _,s in ipairs(all_skills) do if not disabled[s.name] then list[#list+1]=s end end;ctx.skills=list
        end
        local function disable(names) disabled={};for n in names:gmatch('%S+') do disabled[n]=true end;applyDisabled() end
        local start,lastProgress=api.now(),api.now()
        local stage,stopped,key,lastMove=0,false,'',-10000
        local done,opened,seen,resetAt,hps={}, {},{},{},{}
        local leader,school=api.isLeader(),api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local emei=school==4
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        for i,m in ipairs(api.teamIdentities()) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        if memberIndex>5 then memberIndex=0 end
        local odd=memberIndex%2==0 -- reference: members 0/2/4 take the left route and station
        -- Messages: a key fires when more lines carry it than before; lines already shown at the start are history.
        local phrases={};for _,k in ipairs(KEYS) do phrases[k]=dict(k) end
        local counts,seenAt,firstRead={},{},true
        local ghostName,snowName=dict('GGSS_160905_06'),dict('SSS_ZJ_120109_79')
        local function readMessages()
            local lines=api.messages()
            for _,k in ipairs(KEYS) do
                local n,phrase=0,phrases[k]
                for _,line in ipairs(lines) do
                    if line:find(k,1,true) or (phrase~='' and phrase~=k and line:find(phrase,1,true)) then n=n+1 end
                end
                if not firstRead and n>(counts[k] or 0) then seenAt[k]=api.now();lastProgress=api.now() end
                counts[k]=n
            end
            firstRead=false
        end
        local function within(k,ms) return seenAt[k]~=nil and api.now()-seenAt[k]<ms end
        local function age(k) return seenAt[k] and api.now()-seenAt[k] or nil end
        local function hasBuff(set,text) for name in pairs(set) do if name:find(text,1,true) then return true end end return false end
        local function stop()
            if not stopped then api.stopAttack();stopped=true end
            if ctx.id>=0 then ctx=R.new(SCENE,{boss_names=def.bosses});applyDisabled() end
        end
        local function move(x,y)
            assert(world().scene==SCENE,'少室山移动时场景已变化')
            if d2(world(),x,y)<=1 then return false end
            local nextKey=x..','..y
            if nextKey~=key or api.now()-lastMove>=4000 then
                api.stop();R.call(R.codes.RunTo,{SCENE},{x,y});key=nextKey;lastMove=api.now()
            end
            return true
        end
        local function go(x,y,label) wait(label,function() return not move(x,y) end,math.max(waitMs,45000)) end
        local function attack(target)
            if not enemy(target) then return false end
            if d2(world(),target.x,target.y)>35^2 then move(target.x,target.y);return true end
            if not DungeonPetGuard.update(pet,false) then stop();return true end
            if not api.maintain() and R.canAttack() then
                stopped=false;R.selectOriginalTarget(ctx,target.id);R.step(ctx)
            end
            return true
        end
        local function nearestMob(all,radius)
            local found
            for _,o in ipairs(all) do
                if enemy(o) and not BOSS_SET[o.name] and not NOT_MOBS[o.name] and (not radius or o.dst<=radius) and (not found or o.dst<found.dst) then found=o end
            end
            return found
        end
        -- Bosses return to NPC form when the team is wiped. This program does not revive, so that stops the task by name.
        local function watchBoss(n,boss)
            if enemy(boss) then
                seen[n]=true;resetAt[n]=nil
                if not hps[boss.name] or boss.hp<hps[boss.name] then lastProgress=api.now() end
                hps[boss.name]=boss.hp
            elseif boss and boss.hp>0 and seen[n] then
                resetAt[n]=resetAt[n] or api.now()
                if api.now()-resetAt[n]>3000 then error('少室山：'..boss.name..'恢复为 NPC，本关已重置；自动复活未接入，已停止',0) end
            end
        end
        local function teamHp(timeout)
            local started=api.now()
            log('等待全队血量 85%')
            while api.now()-started<timeout and not api.teamHealthy(85) do api.maintain();api.sleep(250) end
        end
        -- Leader opens a boss once. No fight after the wait means the talk did not work, and it is not resent.
        local function openBoss(n,name,x,y,option,hpWait)
            if opened[n] then
                assert(api.now()-opened[n]<math.max(waitMs,60000),'少室山：'..name..'开怪后没有进入战斗，不重复对话')
                return
            end
            stop();teamHp(hpWait or 30000)
            api.openNpc({name=name,x=x,y=y,scene=SCENE})
            api.sleep(500);api.selectOption({option},false);api.sleep(1000);api.confirmBox();CloseAllWindow()
            opened[n]=api.now();lastProgress=api.now();log(name..' · 已开怪')
        end
        local function others()
            local out={};for _,o in ipairs(api.mechanisms()) do if o.kind==1 and o.id~=own then out[#out+1]=o end end;return out
        end
        local function traps()
            local out={};for _,o in ipairs(api.mechanisms()) do if o.kind==2 then out[#out+1]=o end end;return out
        end
        -- Leave `danger` to the nearest grid point inside the circle with clearance r, or `fallback` when none has r.
        local function escape(danger,r,cx,cy,maxR,fallback)
            local p=world();local inside=false
            for _,o in ipairs(danger) do if d2(p,o.x,o.y)<r*r then inside=true;break end end
            if not inside then return false end
            local function search(clear)
                local point,score
                for y=cy-maxR,cy+maxR do for x=cx-maxR,cx+maxR do
                    if (x-cx)^2+(y-cy)^2<=maxR*maxR then
                        local good=true
                        for _,o in ipairs(danger) do if (o.x-x)^2+(o.y-y)^2<clear*clear then good=false;break end end
                        local s=d2(p,x,y)
                        if good and (not score or s<score) then point,score={x,y},s end
                    end
                end end
                return point
            end
            local point=search(r) or (fallback and search(fallback))
            if point then move(point[1],point[2]) else api.stop() end
            return true
        end
        local function station(cx,cy,r)
            local a=memberIndex*math.pi/3
            return math.floor(cx+r*math.cos(a)+0.5),math.floor(cy+r*math.sin(a)+0.5)
        end
        local function markDone(n) if not done[n] then done[n]=true;lastProgress=api.now();log(({'鸠摩智','庄聚贤','慕容复','丁春秋','萧远山 / 慕容博'})[n]..' 已完成') end end

        local function finishBoss()
            stop()
            wait('恢复原珍兽',function() return DungeonPetGuard.update(pet,false) end,8500)
            disable('')
            if cfg.shaoshi_loot~=false then api.pickup();api.sleep(300) end
            key=''
        end

        local function stage1(all,p)
            local boss=best(all,'鸠摩智',function(o) return o.y>150 and o.y<185 and o.hp>0 end)
            watchBoss(1,boss)
            local mob=nearestMob(all,enemy(boss) and 15 or nil)
            if enemy(boss) then
                log('鸠摩智 · 战斗')
                if not melee and not leader and move(odd and 126 or 133,166) then return end
                local xt=best(all,'信徒',enemy)
                attack(xt or boss)
            elseif mob then log('清理小怪');attack(mob)
            elseif boss then
                log('鸠摩智 · 开怪')
                if leader then openBoss(1,'鸠摩智',131,172,OPEN)
                elseif melee then move(131,172)
                else move(odd and 126 or 133,166) end
            else
                log('前往鸠摩智')
                if p.y>208 then move(odd and 117 or 142,204)
                elseif p.y>190 then if not move(129,204) then move(129,182) end
                else move(130,171) end
            end
        end

        -- 庄聚贤 狂暴: the reference reads the boss's target, which this program cannot. A boss closing in on this
        -- character, or heavy damage right beside it, counts as being chased for the next 3 seconds.
        local chase={at=0,until_=0}
        local function chased(boss)
            local now,hp=api.now(),GetHPPercent()
            if now-chase.at>=500 then
                if chase.dst and ((chase.dst-boss.dst>0.5 and boss.dst<=12) or (chase.hp-hp>=8 and boss.dst<=4)) then chase.until_=now+3000 end
                chase.at,chase.dst,chase.hp=now,boss.dst,hp
            end
            return now<chase.until_
        end
        local function stage2(all,p)
            local boss=best(all,'庄聚贤',function(o) return o.hp>0 end)
            watchBoss(2,boss)
            local bing=best(all,'冰蚕',enemy)
            if p.y>90 and p.x>90 then move(68,121);return end
            local mob=not enemy(boss) and not bing and nearestMob(all,15)
            if mob then attack(mob);return end
            if not enemy(boss) and not bing then
                log('庄聚贤 · 开怪')
                if not boss then move(68,121);return end
                if leader then
                    if cfg.xzk189 and not opened[2] then
                        local started=api.now();log('庄聚贤 · 等待峨嵋血祭冷却（最多 90 秒）')
                        while api.now()-started<90000 do
                            local cooling=false
                            for _,m in ipairs(api.emeiMembers()) do if hasBuff(api.buffs(m),'珍兽施放共生和血祭') then cooling=true end end
                            if not cooling then break end
                            api.maintain();api.sleep(500)
                        end
                    end
                    openBoss(2,'庄聚贤',68,121,OPEN,45000)
                else move(68,121) end
                return
            end
            disable('指点江山')
            local bossBuffs=enemy(boss) and api.buffs(boss) or {}
            if enemy(boss) and hasBuff(bossBuffs,'疯狂：极大的提高伤害') and chased(boss) then
                log('庄聚贤 · 狂暴拉怪');stop()
                local best_,score
                for i=0,11 do
                    local a=i*math.pi/6;local x,y=math.floor(68+14*math.cos(a)+0.5),math.floor(121+14*math.sin(a)+0.5)
                    local s=(boss.x-x)^2+(boss.y-y)^2
                    if not score or s>score then best_,score={x,y},s end
                end
                move(best_[1],best_[2]);return
            end
            if escape(traps(),5,68,121,14) then log('庄聚贤 · 躲陷阱');stop();return end
            if not melee then
                local x,y=station(68,121,15)
                if not opened['s2'] then if move(x,y) then return end;opened['s2']=true end
            end
            log('庄聚贤 · 战斗');attack(bing or boss)
        end

        local function stage3(all,p)
            local boss=best(all,'慕容复',function(o) return o.y>62 and o.hp>0 end)
            watchBoss(3,boss)
            if not enemy(boss) and (p.x<90 or p.y>105) then log('前往慕容复');if p.y>90 then move(56,88) else move(167,85) end;return end
            if not enemy(boss) and p.x<172 then log('前往慕容复');if not move(167,85) then local m=nearestMob(all,20);if m then attack(m) else move(195,86) end end;return end
            local mob=not enemy(boss) and nearestMob(all,20)
            if mob then log('清理小怪');attack(mob);return end
            if not enemy(boss) then
                log('慕容复 · 开怪')
                if not boss then move(195,86);return end
                if leader then openBoss(3,'慕容复',195,86,OPEN,45000) else move(195,86) end
                return
            end
            disable('指点江山 横扫乾坤 三阳开泰 连珠腐尸毒 暗器连击 金顶绵掌 步步生花')
            local hold=within('CJG_101231_141',14000) or within('CJG_101231_140',10000)
                or (seenAt['CJG_101231_140']~=nil and hasBuff(api.buffs(boss),'以彼之道还施彼身：'))
            if hold then
                log('慕容复 · 停手');stop();DungeonPetGuard.update(pet,true);move(195,86)
            else log('慕容复 · 战斗');attack(boss) end
        end

        local loopIndex=1
        local function stage4(all,p)
            local boss=best(all,'丁春秋',function(o) return o.hp>0 end)
            watchBoss(4,boss)
            local gu=best(all,'血咒巫蛊',enemy)
            if not enemy(boss) and not gu then
                log('前往丁春秋')
                if p.x>173 and p.y<115 then move(215,180);return end
                if p.x<173 and p.y<93 then if not move(56,88) then move(130,126) end;return end
                if p.x>151 or p.y>140 then move(130,126);return end
                local mob=nearestMob(all,20)
                if mob then log('清理小怪');attack(mob);return end
                log('丁春秋 · 开怪')
                if not boss then move(130,126);return end
                if leader then openBoss(4,'丁春秋',130,126,OPEN,45000) else move(130,126) end
                return
            end
            disable('指点江山')
            if hasBuff(api.buffs(),'自爆：') then
                log('丁春秋 · 自爆远离队友')
                if escape(others(),12,130,127,15,8) then stop();DungeonPetGuard.update(pet,true);return end
                local near=gu and gu.dst<=15 and gu
                if near and not ladcq and (not melee or near.dst<=2) then attack(near) else stop();DungeonPetGuard.update(pet,true) end
                return
            end
            if ladcq then
                local point=LOOP[loopIndex]
                local unsafe=gu and (point[1]-gu.x)^2+(point[2]-gu.y)^2<=16
                if unsafe then
                    local found
                    for i=loopIndex+1,#LOOP do if (LOOP[i][1]-gu.x)^2+(LOOP[i][2]-gu.y)^2>16 then found=i;break end end
                    loopIndex=found or 1;point=LOOP[loopIndex];stop()
                end
                if move(point[1],point[2]) then return end
                log('丁春秋 · 绕场输出')
                if enemy(boss) and (not melee or boss.dst<=3) then attack(boss) end
            elseif within('CJG_101231_83',10000) then
                if d2(p,130,126)>9 then stop();move(130,126);return end
                log('丁春秋 · 回位输出');local t=gu or boss
                if t and (not melee or t.dst<=3) then attack(t) end
            elseif gu then log('丁春秋 · 集火巫蛊');attack(gu)
            else
                if not melee and not opened['s4'] then
                    local x,y=station(130,126,5)
                    if move(x,y) then return end;opened['s4']=true
                end
                log('丁春秋 · 战斗');attack(boss)
            end
        end

        local function phase1(all,p,boss)
            log('萧远山 · 战斗')
            local t=age('SSS_ZJ_120109_14')
            if t and t<9000 and boss then chase.lx,chase.ly=boss.x,boss.y end
            if t and t>2000 and t<18000 then
                local lx,ly=chase.lx or 122,chase.ly or 46
                local x,y=107,52
                if (lx-137)^2+(ly-37)^2>=(lx-107)^2+(ly-52)^2 then x,y=137,37 end
                stop()
                if not move(x,y) and boss and boss.dst<=15 and not melee then attack(boss) end
                log('萧远山 · 躲焚天灭地')
            elseif boss then attack(boss) end
        end
        local tlnx=-100000
        local function phase2(all,p,boss)
            local target,safe=boss,true
            local point=ZOUWEI[memberIndex+1]
            local function afterMove(ok) -- standing at the point: ranged keep casting, melee only beside the boss
                if ok then target=nil elseif not boss or melee and boss.dst>=3 then target=nil else target=boss end
            end
            if hasBuff(api.buffs(),'千蛛万毒') or within('SSS_ZJ_120109_42',25000) then
                safe=false;log('慕容博 · 千蛛万毒走位');afterMove(move(point[1],point[2]))
            end
            local ice=best(all,'寒冰',enemy)
            if ice then
                if safe or not melee then target=ice else target=nil end
                safe=false;log('慕容博 · 打寒冰')
            elseif not safe then target=nil end
            if safe and boss then
                local danger=traps()
                for _,n in ipairs({'从刃内息三刀','从刃内息预警','绝情谷内息三刀','绝情谷内息预警',snowName}) do
                    if n~='' then for _,o in ipairs(all) do if o.name==n then danger[#danger+1]=o end end end
                end
                if escape(danger,10,122,46,15,6) then safe=false;target=nil;log('慕容博 · 躲内息') end
            end
            if safe and boss and (within('SSS_ZJ_120109_46',23000) or within('SSS_ZJ_120109_45',23000)) then
                safe=false;log('慕容博 · 逍遥慕容走位')
                local run=point
                local danger=traps()
                local function clear(q) for _,o in ipairs(danger) do if (o.x-q[1])^2+(o.y-q[2])^2<=9 then return false end end return true end
                if not clear(run) and clear(OUTER[memberIndex+1]) then run=OUTER[memberIndex+1] end
                afterMove(move(run[1],run[2]))
            end
            if safe and boss and within('SSS_ZJ_120109_39',21000) then
                safe=false;log('慕容博 · 丐帮走位')
                if age('SSS_ZJ_120109_39')<=5000 then move(point[1],point[2]);target=nil
                else afterMove(escape({boss},5,122,46,12)) end
            end
            if safe and boss and within('SSS_ZJ_120109_37',15000) then
                safe=false;log('慕容博 · 少林回位');target=nil
                if d2(p,122,46)>9 then move(122,46) else target=boss end
            end
            if safe and boss then
                local gg=best(all,ghostName,enemy)
                if gg then safe=false;target=gg;log('慕容博 · 鬼谷目标')
                elseif within('GGSS_160905_03',21000) then
                    safe=false;log('慕容博 · 鬼谷走位')
                    local x,y=122,38;if melee then x,y=115,46 end
                    afterMove(move(x,y))
                end
            end
            if boss and target==boss and hasBuff(api.buffs(boss),'运气无敌状态') then target=nil end
            if not target then stop();return end
            if safe then log('慕容博 · 战斗') end
            attack(target)
        end
        -- 达魔正心: the reference picks the right one by its title, which this program cannot read. The boss's HP
        -- tells: 12 seconds beside one without damage to the boss moves on to the other.
        local zx={index=1,at=0,hp=nil,name=nil}
        local function pull(boss,all,p)
            local list={};for _,o in ipairs(all) do if o.name=='达魔正心' then list[#list+1]=o end end
            table.sort(list,function(a,b) return a.id<b.id end)
            if #list==0 then return false end
            if zx.name~=boss.name then zx.name,zx.index,zx.at,zx.hp=boss.name,1,api.now(),boss.hp end
            if boss.hp<(zx.hp or 101) then zx.hp=boss.hp;zx.at=api.now() end
            if api.now()-zx.at>12000 then zx.index=zx.index%#list+1;zx.at=api.now();log('达魔正心 · 换另一个') end
            local z=list[math.min(zx.index,#list)]
            local bestPoint,score
            for i=0,11 do
                local a=i*math.pi/6
                local x,y=math.floor(z.x+5*math.cos(a)+0.5),math.floor(z.y+5*math.sin(a)+0.5)
                if x>=105 and x<=142 and y>=33 and y<=60 then
                    local s=(boss.x-x)^2+(boss.y-y)^2
                    if not score or s>score then bestPoint,score={x,y},s end
                end
            end
            if bestPoint then move(bestPoint[1],bestPoint[2]) end
            return true
        end
        local walk=1
        local function phase3(all,p,xys,mrb)
            local own_=api.buffs()
            local pulled=(xys and hasBuff(own_,'萧远山目标') and xys) or (mrb and hasBuff(own_,'慕容博目标') and mrb)
            local xm,black
            for _,o in ipairs(all) do
                if enemy(o) and o.name=='心魔' and (not xm or o.dst<xm.dst) then xm=o end
                if enemy(o) and o.name=='黑色心魔' and (not black or o.dst<black.dst) then black=o end
            end
            local target=black
            if not target and xm and not hasBuff(api.buffs(xm),'无敌') then target=xm end
            if pulled then
                log('心魔 · 拉'..pulled.name);stop()
                if not pull(pulled,all,p) then move(122,46) end
                return
            end
            log('心魔 · 战斗')
            if target then attack(target)
            else
                stop();local q=ZOUWEI[walk]
                if not move(q[1],q[2]) then walk=walk%#ZOUWEI+1 end
            end
        end
        local talkedDisciple,discipleSeenAt=0,api.now()
        local function stage5(all,p)
            local xys=best(all,'萧远山',enemy);local mrb=best(all,'慕容博',enemy)
            local anyXm=best(all,'心魔') or best(all,'黑色心魔') or best(all,'达魔正心')
            local xnpc=best(all,'萧远山',function(o) return not enemy(o) and o.hp>0 end)
            local mnpc=best(all,'慕容博',function(o) return not enemy(o) and o.hp>0 end)
            if xys or mrb or anyXm then
                seen[5]=true;disable('指点江山 三阳开泰 连珠腐尸毒')
                for _,b in ipairs({xys,mrb}) do
                    if b and (not hps[b.name] or b.hp<hps[b.name]) then hps[b.name]=b.hp;lastProgress=api.now() end
                end
                if anyXm or (xys and mrb) then phase3(all,p,xys,mrb)
                elseif xys then phase1(all,p,xys)
                else phase2(all,p,mrb) end
                return
            end
            if p.y>67 then
                log('少林弟子 · 前往藏经阁')
                if move(130,125) then return end
                local d=best(all,'少林弟子',function(o) return o.y>121 end)
                if d and talkedDisciple<3 then
                    talkedDisciple=talkedDisciple+1
                    api.openNpc({name='少林弟子',x=d.x,y=d.y,scene=SCENE});api.sleep(500)
                    if api.selectOption({'#{SSS_ZJ_120109_06}'},true) then api.sleep(500);api.confirmBox() end
                    CloseAllWindow();lastProgress=api.now();return
                end
                if d then error('少室山：少林弟子对话 3 次没有放行',0) end
                if talkedDisciple>0 or api.now()-discipleSeenAt>5000 then move(137,37) end
                return
            end
            -- At the 藏经阁, no enemies: the fight has not started, is between phases, or was reset.
            if seen[5] and xnpc and mnpc and xnpc.x>130 then error('少室山：第五关进度已重置；自动复活未接入，已停止',0) end
            if seen[5] then log('等待剧情');stop();move(122,46);return end
            log('扫地神僧 · 开怪')
            if move(134,37) then return end
            if leader then openBoss(5,'扫地神僧',134,37,'#{SSS_ZJ_120109_11}') end
        end
        local run={stage1,stage2,stage3,stage4,stage5}

        readMessages()
        while not done[5] do
            assert(api.now()-start<battleMs,'少室山战斗超过时限')
            assert(world().scene==SCENE,'少室山未完成时离开副本')
            api.alive(minimum,'少室山：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();readMessages()
            local all,p=rows(),world()
            -- Prompts first: they end a stage on this client even when the object is out of sight.
            for n=1,5 do for _,k in ipairs(DONE[n]) do if seenAt[k] then for i=1,n do done[i]=true end end end end
            for n,name in ipairs({'鸠摩智','庄聚贤','慕容复','丁春秋'}) do
                local b=best(all,name)
                if seen[n] and b and b.hp==0 then markDone(n) end
            end
            local highest=0;for n=1,5 do if done[n] then highest=n end end
            if done[5] then break end
            local wanted,lowest=highest+1,nil
            -- A resumed run finds its stage from what is on the field. The lowest open stage wins; stages never go back.
            for _,o in ipairs(all) do
                if o.hp>0 then
                    local n=(o.name=='鸠摩智' and o.y>150 and o.y<185 and 1) or ((o.name=='庄聚贤' or o.name=='冰蚕') and 2)
                        or (o.name=='慕容复' and o.y>62 and 3) or ((o.name=='丁春秋' or o.name=='血咒巫蛊') and 4)
                        or (STAGE5[o.name] and (p.y<67 or highest>=4 or o.class=='怪物') and 5)
                    if n and n>highest and (not lowest or n<lowest) then lowest=n end
                end
            end
            if lowest then wanted=lowest end
            if highest==0 and not lowest and p.y>10 and p.y<67 then wanted=5 end
            if wanted>stage then
                if stage>0 then finishBoss() end
                stage=wanted;key='';lastProgress=api.now();opened['s2']=nil;opened['s4']=nil
            end
            run[stage](all,p)
            api.maintain()
            local actual=world()
            if not chase.px or d2(actual,chase.px,chase.py)>0.25 then chase.px,chase.py=actual.x,actual.y;lastProgress=api.now() end
            assert(api.now()-lastProgress<180000,'少室山阶段没有进展：'..phase)
            api.sleep(250)
        end
        finishBoss()
        -- Exit through 扫地神僧. Each client leaves for itself; the option is re-read before each attempt.
        local p=world()
        if p.y>67 then go(122,46,'前往藏经阁') end
        go(120,34,'前往扫地神僧')
        local tries=0
        wait('离开少室山',function()
            if world().scene~=SCENE then return true end
            if tries<3 then
                tries=tries+1
                api.openNpc({name='扫地神僧',x=120,y=34,scene=SCENE});api.sleep(500)
                if api.selectOption({'#{CJG_101231_79}'},true) then api.sleep(500);api.confirmBox() end
                CloseAllWindow();api.sleep(4000)
            end
        end,math.max(waitMs,45000))
        local refreshed=false
        return wait('确认本轮活动次数',function()
            local c=api.campaign(mode,not refreshed);refreshed=true;sameCampaign(before,c)
            if c.used>before.used then assert(c.used==before.used+1,'少室山次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
    end

    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(mode,true)
            if world().scene~=SCENE and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message='少室山今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=SCENE then
                api.openNpc(entrance);gather(entrance)
                if api.isLeader() then
                    assert(api.selectOption({mode.option},true),'朱丹臣没有所选难度的选项：'..tostring(cfg.sss_type or '普通'))
                    api.sleep(1000)
                    local first=api.dialogFirst()
                    local phrase=dict('CJG_101231_75')
                    if world().scene~=SCENE and (first:find('#{CJG_101231_75',1,true) or (phrase~='' and phrase~='CJG_101231_75' and first:find(phrase,1,true))) then
                        return {status=completed>0 and 'done' or 'already_done',message='朱丹臣提示今日已完成少室山；本次完成 '..completed..' 轮'}
                    end
                end
                wait('确认进入少室山',function() return world().scene==SCENE end)
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='少室山完成 '..completed..' 轮；五关结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'少室山停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
Shaoshi.entrance=entrance
