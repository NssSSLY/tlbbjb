-- 剑破明王境 full flow, written from the reference rules (原脚本源码/Script64/副本/剑破明王境.lua). Seven trials in one scene,
-- each drawing shadows of other dungeons' bosses. This task owns its stages and receipts; it does not load the vendor framework.
-- Reference fields this program cannot read (facing, title, state, trap names) are replaced by what can be observed;
-- docs/MINGWANG_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Mingwang={}
local R=assert(CombatRuntime)
local SCENE=934
local entrance={name='高成彦',x=355,y=221,scene=0}
local NPCPOS={{81,250},{127,224},{60,124},{72,50},{158,121},{256,173},{244,61}}
local TRIAL={['田晓宇']=1,['刘昌浩']=2,['董思']=3,['赵博']=4,['李欣泽']=5,['叶秋霜']=6,['彭靖']=7}
local STEP={['慕容复·影']=1,['庞企·影']=1,['丁春秋·影']=1,['大轮寺梵僧']=2,
    ['裂海玄蜥·影']=3,['裂海魔龙·影']=3,['灭世火凤·影']=3,['炼狱凤凰·影']=3,['摄灵蛊花·影']=3,['噬魂花妖·影']=3,
    ['李秋水·影']=5,['天山童姥·影']=5,['无崖子·影']=5,['虚竹·影']=5,
    ['燕驰野·影']=7,['唐简·影']=7,['慕容信·影']=7,['霜见·影']=7}
local RELICS={['锡杖']=true,['净瓶']=true,['金刚杵']=true,['智慧剑']=true}
local STATION_R={['燕驰野·影']=6,['唐简·影']=5,['慕容信·影']=5,['霜见·影']=5}
local KEYS={'CJG_101231_82','CJG_101231_83','MZFB_150810_67','MZFB_150810_69','LHFD_160203_75','LHFD_160203_92',
    'BSJN_200327_11','BSJN_200327_172','BSJN_200327_173','BSJN_200327_84','BSJN_200327_18','BSJN_200327_99','BSJN_200327_101','BSJN_200327_107','RGPT_231130_126','RGPT_231130_76'}
local LIUYANG_SAFE={{149,111},{167,111},{149,131},{167,131}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end
local function region(p)
    local x,y=p.x,p.y
    if x<=100 and y>228 then return 1 end
    if x<=152 and y>192 then return 2 end
    if x<=80 and y>98 and y<148 then return 3 end
    if x<=98 and y<98 then return 4 end
    if x>100 and x<=181 and y>80 and y<152 then return 5 end
    if x>181 and x<=276 and y>140 and y<200 then return 6 end
    if x>210 and x<=276 and y<90 then return 7 end
end

function Mingwang.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 3),3,6,'队伍人数')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={};for name in pairs(STEP) do bossNames[#bossNames+1]=name end
    local def={name='剑破明王境',mission='剑破明王境',map='明王境',npc=entrance,bosses=bossNames}
    function def.inside(p) return p.scene==SCENE end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('剑破明王境 · '..s) end end
    local function world() return assert(api.world(),'剑破明王境场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('剑破明王境：'..label..'超时',0)
    end
    local function ui(code) GetLuaValue('-- mingwang:ui\n'..code,'',0) end
    local function dialogText()
        local text=GetLuaValue([[-- mingwang:dialog-all
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local all=''
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                if type(t)=='string' then all=all..t..'\n' end
            end
            return all]],'s')
        return type(text)=='string' and text or ''
    end

    local function fight()
        local T=DungeonTactics.new(api,SCENE,bossNames);T.watch(KEYS);T.readMessages()
        local start,lastProgress,hps=api.now(),api.now(),{}
        local leader,school=api.isLeader(),api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local emei=school==4
        local own,ownServer=R.host('battle_self_identity');local memberIndex,teamSize=0,1
        for i,m in ipairs(api.teamIdentities()) do teamSize=i;if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        local ownName=GetLuaValue("-- mingwang:name\nreturn Player:GetName()",'s')
        assert(type(ownName)=='string' and ownName~='','角色名称不可读')
        local fought,opened,skillDone,reset,settled,warned={},{},{},{},{},{}
        local lastStep,toNextAt,nextStep,lastTalk,disabledNow=nil,nil,nil,-100000,nil
        local stage7Dead=false
        local function progress() lastProgress=api.now() end
        local function station(z,r)
            local a=memberIndex*math.pi/3
            return math.floor(z[1]+r*math.cos(a)+0.5),math.floor(z[2]+r*math.sin(a)+0.5)
        end
        local function buffsHave(text) return T.hasBuff(api.buffs(),text) end
        local function useOn(define,o)
            local r=GetLuaValue(string.format([[-- mingwang:interact
                local define,server,client=%d,%d,%d
                local a=nil for i=0,255 do local t=EnumAction(i,'skill') if t and t:GetDefineID()==define then a=t break end end
                if not a then return -1 end
                DataPool:SelectAsTargetByObjID(server)
                local present=Target:IsPresent()
                if not present or present==0 or Target:GetData('NPCID')~=client then return 0 end
                local e=Packet_Env local b=type(e)=='table' and e.Packet_Space_Line10_Row10_button if not b then error('action button unavailable') end
                local old=b:GetActionItem() b:SetActionItem(a:GetID()) local ok,err=pcall(b.DoAction,b) b:SetActionItem(old) if not ok then error(err) end
                return 1
            ]],define,o.server_id,o.id),'n')
            if r==-1 and not warned[define] then warned[define]=true;api.log('剑破明王境：技能列表没有机制技能 '..define) end
            return r==1
        end
        local function coneDodge(boss,spot,p,unsafe)
            local cone=math.deg(math.atan(spot.y-boss.y,spot.x-boss.x))
            local mine=math.deg(math.atan(p.y-boss.y,p.x-boss.x))
            local diff=math.abs(cone-mine);if diff>180 then diff=360-diff end
            if diff>=unsafe then return false end
            local r=math.max(4,math.sqrt(d2(p,boss.x,boss.y)))
            local a=math.rad(cone+unsafe+30)
            T.move(math.floor(boss.x+r*math.cos(a)+0.5),math.floor(boss.y+r*math.sin(a)+0.5));return true
        end
        -- Each handler returns: hold (no attack this frame), then optional targets, then skills to leave out.
        local H={}
        H['慕容复·影']=function(all,p,boss)
            local z=NPCPOS[1]
            if T.hasBuff(api.buffs(boss),'斗转星移') then
                log('慕容复 · 斗转星移，停手');T.stop();T.holdPet();T.move(z[1],z[2]);return true
            end
            return false,nil,'横扫乾坤 三阳开泰 连珠腐尸毒 暗器连击 金顶绵掌 步步生花'
        end
        H['庞企·影']=function(all,p,boss)
            local z=NPCPOS[1];local danger=T.traps()
            if T.escape(danger,6,z[1],z[2],15,4) then log('庞企 · 躲陷阱');T.stop();return true end
            local adds=T.list(all,'星罗武士',T.enemy)
            if #adds>0 then log('庞企 · 打星罗武士');return false,adds,'暗器连击' end
            local x,y=station(z,3)
            if T.hasBuff(api.buffs(boss),'天罡护体') then log('庞企 · 小怪将出现');T.stop();T.move(x,y);return true end
            if boss.hp>90 and not melee and T.move(x,y) then return true end
            if #danger>0 and boss.dst>(melee and 2 or 15) then log('庞企 · 有陷阱，目标太远');T.stop();return true end
            return false,nil,boss.hp>80 and '横扫乾坤 真武七截阵 三阳开泰 连珠腐尸毒 三环套月 七星聚首 玉碎昆岗 万箭齐发 天女散花 太上忘情 绝星阵·七杀 暗器连击' or ''
        end
        H['丁春秋·影']=function(all,p,boss)
            local z=NPCPOS[1];local gu=T.list(all,'血咒巫蛊',T.enemy)
            if buffsHave('自爆：') then
                if T.escape(T.players(),12,z[1],z[2],15,6) then log('丁春秋 · 自爆远离队友');T.stop();return true end
                if #gu>0 and (not melee or gu[1].dst<=2) then return false,{gu[1]} end
                log('丁春秋 · 自爆等待');T.stop();return true
            end
            if T.within('CJG_101231_83',10000) and d2(p,z[1],z[2])>9 then log('丁春秋 · 回中心');T.stop();T.move(z[1],z[2]);return true end
            if #gu>0 then log('丁春秋 · 集火血咒巫蛊');return false,gu,'指点江山' end
            if not melee then local x,y=station(z,5);if T.move(x,y) then return true end end
            return false,nil,'指点江山'
        end
        -- 三神 shadows
        local function sanshenTraps(n)
            local z=NPCPOS[3];local danger=T.traps()
            if T.escape(danger,6,z[1],z[2],15,4) then log('第三重 · 躲陷阱');T.stop();return true,danger end
            return false,danger
        end
        local function liehai(all,p,boss)
            local hold,danger=sanshenTraps();if hold then return true end
            if #danger>0 and boss.dst>(melee and 3 or 15) then log('裂海魔龙 · 有陷阱，目标太远');T.stop();return true end
        end
        H['裂海玄蜥·影']=liehai;H['裂海魔龙·影']=liehai
        local function huofeng(all,p,boss)
            local z=NPCPOS[3];local hold=sanshenTraps();if hold then return true end
            local flames,mine={},false
            for _,o in ipairs(all) do
                if o.name:find('的离火',1,true) or o.name:find('的焱火',1,true) then
                    flames[#flames+1]=o
                    if o.name==ownName..'的离火' or o.name==ownName..'的焱火' then mine=true end
                end
            end
            if #flames>0 then
                if mine and T.escape(T.players(),6,z[1],z[2],15,4) then log('灭世火凤 · 带火苗离开队友');T.stop();return true end
                if not mine and T.escape(flames,6,z[1],z[2],15,4) then log('灭世火凤 · 躲火苗');T.stop();return true end
            end
            if not melee then local x,y=station(z,6);if T.move(x,y) then return true end end
        end
        H['灭世火凤·影']=huofeng;H['炼狱凤凰·影']=huofeng
        local function huayao(all,p,boss)
            local z=NPCPOS[3]
            local burning=T.within('MZFB_150810_67',6000) or buffsHave('每秒对周围玩家造成伤害')
            local poisoned=T.within('MZFB_150810_69',6000) or buffsHave('毒蛊入体')
            local x,y=station(z,burning and 8 or 6)
            if not melee and T.move(x,y) then log('噬魂花妖 · 走位');return true end
            local unsafe=false
            if melee and (burning or poisoned) then
                unsafe=true;if T.move(x,y) then log('噬魂花妖 · 散开');T.stop();return true end
            elseif melee and T.escape(T.traps(),6,z[1],z[2],15,4) then log('噬魂花妖 · 躲陷阱');T.stop();return true end
            local adds={};for _,name in ipairs({'毒种籽','毒花'}) do for _,o in ipairs(T.list(all,name,T.enemy)) do adds[#adds+1]=o end end
            if unsafe and boss.dst>=3 and #adds==0 then T.stop();return true end
            if #adds>0 then return false,adds end
        end
        H['摄灵蛊花·影']=huayao;H['噬魂花妖·影']=huayao
        -- 琅嬛 shadows
        H['李秋水·影']=function(all,p,boss)
            local z=NPCPOS[5]
            if T.best(all,'玉璧残影') then log('李秋水 · 玉璧残影集火');return false,{boss} end
            if T.within('LHFD_160203_75',6000) then
                -- The reference reads the sword's facing; that field is unreadable, so keep away from the sword.
                local swords=T.list(all,'剑')
                if #swords>0 and T.escape(swords,15,z[1],z[2],15,8) then log('李秋水 · 躲剑气');T.stop();return true end
            end
            local shade=T.list(all,'无相踪影',T.enemy)
            if #shade>0 then log('李秋水 · 打无相踪影');return false,shade end
            if not melee and d2(p,z[1],z[2])>(emei and 36 or 64) then T.stop();T.move(z[1],z[2]);return true end
            if boss.hp<=17 then return false,{boss},nil,true end
        end
        H['天山童姥·影']=function(all,p,boss)
            local z=NPCPOS[5]
            if boss.hp>=50 then
                local danger=T.traps()
                if T.escape(danger,8,z[1],z[2],15,5) then log('天山童姥 · 躲陷阱');T.stop();return true end
                if melee and #danger>0 and boss.dst>2 then log('天山童姥 · 有陷阱，近战等待');T.stop();return true end
            elseif T.move(z[1],z[2]) then T.stop();return true end
        end
        H['无崖子·影']=function(all,p,boss)
            local z=NPCPOS[5]
            if boss.hp<21 then
                local pools={}
                for _,o in ipairs(all) do
                    if o.name:find('黑水NPC',1,true) then
                        local r=tonumber((o.name:gsub('黑水NPC','')));o.r=(r and r>0) and r or 4;pools[#pools+1]=o
                    end
                end
                if #pools>0 then
                    table.sort(pools,function(a,c) return a.dst<c.dst end)
                    local first=pools[1].r
                    local need=(first>14 and 25) or (first>9 and 22) or (first>4 and 18) or 14
                    if pools[1].dst<need then
                        local point,score
                        for clear=need,14,-1 do
                            for i=0,71 do
                                local a=i*math.pi/36
                                local x,y=z[1]+17*math.cos(a),z[2]+17*math.sin(a)
                                local good=true
                                for _,o in ipairs(pools) do if (o.x-x)^2+(o.y-y)^2<clear*clear then good=false;break end end
                                local s=(p.x-x)^2+(p.y-y)^2
                                if good and (not score or s<score) then point,score={math.floor(x+0.5),math.floor(y+0.5)},s end
                            end
                            if point then break end
                        end
                        assert(point,'剑破明王境：躲避黑水时没有安全坐标')
                        log('无崖子 · 躲黑水');T.stop();T.move(point[1],point[2]);return true
                    end
                    log('无崖子 · 黑水输出');return false,{boss}
                end
            end
            for _,o in ipairs(all) do
                if o.name:find('八卦安全区',1,true) then log('无崖子 · 八卦安全区');T.stop();T.move(math.floor(o.x),math.floor(o.y));return true end
            end
            for _,o in ipairs(all) do
                if o.name~='' and ('乾坤震巽坎离艮兑'):find(o.name,1,true) then log('无崖子 · 八卦等待');T.stop();T.move(z[1],z[2]);return true end
            end
            local breaker=T.list(all,'击杀破阵',T.enemy)[1]
            if breaker then
                if breaker.dst>3 then log('无崖子 · 破阵');T.stop();T.move(math.floor(breaker.x),math.floor(breaker.y));return true end
                return false,{breaker}
            end
            if T.escape(T.traps(),7,z[1],z[2],18,5) then log('无崖子 · 躲陷阱');T.stop();return true end
            if boss.hp<18 and boss.hp>10 and d2(p,158,106)>9 then log('无崖子 · 到黑水站位');T.stop();T.move(158,106);return true end
            if boss.hp>30 and not melee and d2(p,z[1],z[2])>(emei and 16 or 36) then T.stop();T.move(z[1],z[2]);return true end
            if boss.hp<21 and boss.hp>9 then return false,{boss},nil,true end
        end
        H['虚竹·影']=function(all,p,boss)
            local z=NPCPOS[5]
            -- The reference picks mechanics by his title, unreadable here, so it uses its own fallback: check them all.
            if T.escape(T.traps(),7,z[1],z[2],16,4) then log('虚竹 · 躲陷阱');T.stop();return true end
            local age=T.age('LHFD_160203_92')
            if age and age<15000 then
                if (T.lastLine['LHFD_160203_92'] or ''):find(ownName,1,true) then
                    if age<=7000 then
                        local q,score
                        for _,s in ipairs(LIUYANG_SAFE) do local v=d2(p,s[1],s[2]);if not score or v<score then q,score=s,v end end
                        log('虚竹 · 被点六阳掌，跑开');T.stop()
                        if T.move(q[1],q[2]) then return true end
                    end
                else
                    local palms=T.list(all,'六阳掌力')
                    if #palms>0 and T.escape(palms,7,z[1],z[2],15) then log('虚竹 · 躲六阳掌');T.stop();return true end
                end
            end
        end
        -- 观山海 shadows
        H['燕驰野·影']=function(all,p,boss)
            local z=NPCPOS[7]
            if T.within('BSJN_200327_11',5000) or T.within('BSJN_200327_173',5000) or T.within('BSJN_200327_172',5000) then
                if T.escape({boss},6,z[1],z[2],15,4) then log('燕驰野 · 远离');return true end
            end
            if T.within('BSJN_200327_84',5000) then
                local spots=T.list(all,'空npc')
                if #spots>0 and T.escape(spots,11,z[1],z[2],15,7) then log('燕驰野 · 躲落点');return true end
            end
        end
        H['唐简·影']=function(all,p,boss)
            local spots=T.list(all,'空npc')
            if T.within('BSJN_200327_18',4000) and #spots>0 and coneDodge(boss,spots[1],p,25) then log('唐简 · 躲星河流倾');return true end
            local spikes=T.list(all,'铁蒺藜',T.enemy)
            if #spikes>0 then log('唐简 · 打铁蒺藜');return false,spikes end
        end
        H['慕容信·影']=function(all,p,boss)
            local z=NPCPOS[7]
            if T.within('BSJN_200327_99',5000) and T.escape({boss},6,z[1],z[2],15,4) then log('慕容信 · 远离');return true end
            local spots=T.list(all,'空npc')
            if T.within('BSJN_200327_101',6000) and #spots>0 and not buffsHave('示剑：成为慕容信释放示剑的目标') then
                if coneDodge(boss,spots[1],p,boss.dst<3 and 90 or boss.dst<4 and 45 or 20) then log('慕容信 · 躲示剑');return true end
            end
            return false,nil,'聚星阵·长生 情尽盈血'
        end
        H['霜见·影']=function(all,p,boss)
            local spots=T.list(all,'空npc')
            if T.within('BSJN_200327_107',4000) and #spots>0 and coneDodge(boss,spots[1],p,25) then log('霜见 · 躲扇形');return true end
        end

        local function chooseTarget(hostile,boss,only)
            local list=only and #only>0 and only or nil
            if not list then
                -- Stage 7 disciples are told apart by title in the reference; here every non-boss enemy goes first.
                list={}
                for _,o in ipairs(hostile) do if not STEP[o.name] or o.name=='大轮寺梵僧' then list[#list+1]=o end end
                if #list==0 then return boss or hostile[1] end
            end
            local t=list[1]
            for _,o in ipairs(list) do
                if melee then if o.dst<t.dst then t=o end elseif o.hp<t.hp then t=o end
            end
            return t
        end
        -- Leader at a trial's NPC: assign skills when asked, then start once the team is near and alive.
        local function trial(npc,p)
            local step=TRIAL[npc.name];lastStep=step;toNextAt=nil
            if fought[step] then
                reset[step]=reset[step] or api.now()
                if api.now()-reset[step]>3000 then error('剑破明王境：第 '..step..' 重的 '..npc.name..' 重新出现，本关已重置；自动复活未接入，已停止',0) end
                T.stop();return
            end
            log('第 '..step..' 重 · '..npc.name)
            T.stop()
            if npc.dst>3 then T.move(math.floor(npc.x),math.floor(npc.y));return end
            if not leader then return end
            if opened[step] then
                assert(api.now()-opened[step]<math.max(waitMs,60000),'剑破明王境：'..npc.name..'开始挑战后没有进入战斗，不重复对话')
                return
            end
            if api.now()-lastTalk<6000 then return end
            lastTalk=api.now();CloseAllWindow();TalkNpc(npc.name);api.sleep(800)
            local text=dialogText()
            if not skillDone[step] and (text:find('#{RGPT_231130_97}',1,true) or text:find('#{RGPT_231130_204}',1,true)) then
                skillDone[step]=true;log(npc.name..' · 技能分配');progress()
                api.selectOption({'技能分配'},true);api.sleep(1000)
                ui("RouGe_Skill_Env.RouGe_Skill_DefaultSkill()");api.sleep(800)
                ui("RouGe_Skill_Env.RouGe_Skill_OkClicked()");api.sleep(800)
                CloseAllWindow();return
            end
            if api.teamHealthy(1) and api.teamNear({scene=SCENE,x=npc.x,y=npc.y},10) then
                if api.selectOption({'开始挑战'},true) then
                    opened[step]=api.now();progress();api.sleep(1000)
                    local shown=GetLuaValue("-- mingwang:dazao\nlocal e=RouGe_BossDaZao_Env if type(e)=='table' and e.this and e.this:IsVisible() then return 1 end return 0",'n')
                    if shown==1 then
                        local extra=(npc.name=='董思' or npc.name=='李欣泽' or npc.name=='彭靖') and 1 or -1
                        ui(string.format("Clear_XSCRIPT() Set_XSCRIPT_Function_Name('BossChoiceConfirm') Set_XSCRIPT_ScriptID(998947) Set_XSCRIPT_Parameter(0,%d) Set_XSCRIPT_Parameter(1,1) Set_XSCRIPT_Parameter(2,1) Set_XSCRIPT_Parameter(3,1) Set_XSCRIPT_Parameter(4,%d) Set_XSCRIPT_ParamCount(5) Send_XSCRIPT()",npc.id,extra))
                        api.sleep(1000)
                    end
                end
            else log(npc.name..' · 等待全队到齐') end
            CloseAllWindow()
        end
        -- Relics and lamps: each member takes its own by team order; the reference splits them by a facing it can read.
        local function ownPick(items)
            table.sort(items,function(a,b) return a.id<b.id end)
            return items[memberIndex%#items+1]
        end
        local function relics(items,lotus)
            lastStep=4;toNextAt=nil;fought[4]=true;progress();T.stop()
            if #lotus>0 then
                log('第四重 · 雪莲');T.move(math.floor(lotus[1].x),math.floor(lotus[1].y));return
            end
            local t=ownPick(items);log('第四重 · '..t.name)
            if t.dst>3 then T.move(math.floor(t.x),math.floor(t.y));return end
            if api.now()-lastTalk<3000 then return end
            lastTalk=api.now()
            if pcall(api.openNpc,{name=t.name,x=math.floor(t.x),y=math.floor(t.y),scene=SCENE}) then
                api.sleep(300);api.selectOption({'#{RGPT_231130_297}'},true);api.sleep(800)
            end
            CloseAllWindow()
        end
        local tries={}
        local function lamps(items)
            lastStep=6;toNextAt=nil;fought[6]=true;T.stop()
            local t
            local open={}
            for _,o in ipairs(items) do if (tries[o.id] or 0)<2 then open[#open+1]=o end end
            if #open==0 then log('第六重 · 等待莲花灯');return end
            t=ownPick(open);log('第六重 · 点亮莲花灯')
            if t.dst>3 then progress();T.move(math.floor(t.x),math.floor(t.y));return end
            if useOn(4976,t) then
                tries[t.id]=(tries[t.id] or 0)+1;progress()
                local began=api.now()
                repeat
                    api.maintain();api.sleep(500)
                    local still=false
                    for _,o in ipairs(T.rows()) do if o.id==t.id then still=true;break end end
                until not still or api.now()-began>=16000
            else tries[t.id]=2 end
        end
        local function guide(npc)
            if api.now()-lastTalk<20000 then return false end
            lastTalk=api.now();T.stop()
            if not pcall(api.openNpc,{name=npc.name,x=math.floor(npc.x),y=math.floor(npc.y),scene=SCENE}) then return false end
            api.sleep(500)
            local text=dialogText()
            if text:find('#{RGPT_231130_110}',1,true) then
                for _,k in ipairs({'116','115','114','113','112','111'}) do
                    local key='#{RGPT_231130_'..k..'}'
                    if text:find(key,1,true) then log('王静萱 · 传送');api.selectOption({key},true);api.sleep(1000);CloseAllWindow();progress();return true end
                end
            end
            CloseAllWindow();return false
        end
        local function navigate(p)
            local step=region(p)
            if not step then
                log('未识别的区域')
                if lastStep and lastStep~=7 then local q=NPCPOS[lastStep+1];T.stop();T.move(q[1],q[2]) end
                return
            end
            T.stop()
            if step~=7 and toNextAt and api.now()-toNextAt>6000 then
                local target=step+1
                if nextStep==nil then nextStep=target
                elseif nextStep~=target then nextStep,toNextAt=nil,nil;return end
                log('前往第 '..target..' 重')
                local gate=target==3 and {113,196,'雪雕','#{RGPT_231130_639}'} or target==5 and {92,49,'雪雕','#{RGPT_231130_642}'} or target==7 and {257,155,'幻境深处','#{RGPT_231130_116}'}
                if gate then
                    if not T.move(gate[1],gate[2]) and api.now()-lastTalk>=6000 then
                        lastTalk=api.now();TalkNpc(gate[3]);api.sleep(800);api.selectOption({gate[4]},true);api.sleep(1000);CloseAllWindow()
                    end
                    return
                end
                local q=NPCPOS[target];T.move(q[1],q[2]);return
            end
            log('寻找第 '..step..' 重')
            local q=NPCPOS[step];T.move(q[1],q[2])
            if d2(p,q[1],q[2])<25 and not T.within('RGPT_231130_126',10000) and not toNextAt then toNextAt=api.now() end
        end

        while true do
            local p=world()
            if p.scene~=SCENE then error('剑破明王境未通过第七重时离开副本',0) end
            assert(api.now()-start<battleMs,'剑破明王境战斗超过时限')
            api.alive(minimum,'剑破明王境：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();if T.readMessages() then progress() end
            local all=T.rows()
            local hostile,boss,npc,items,lotus,lampList={},nil,nil,{},{},{}
            local guideNpc
            for _,o in ipairs(all) do
                if T.enemy(o) then
                    hostile[#hostile+1]=o
                    if H[o.name] and (not boss or o.dst<boss.dst) then boss=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;progress() end
                elseif o.hp>0 then
                    if TRIAL[o.name] and (not npc or o.dst<npc.dst) then npc=o
                    elseif RELICS[o.name] then items[#items+1]=o
                    elseif o.name=='雪莲' then lotus[#lotus+1]=o
                    elseif o.name=='莲花灯' then lampList[#lampList+1]=o
                    elseif o.name=='王静萱' and o.dst<15 then guideNpc=o end
                elseif STEP[o.name]==7 and fought[7] then stage7Dead=true end
            end
            if stage7Dead and #hostile==0 then break end
            if npc then
                T.basicOnly(false);trial(npc,p)
            elseif #hostile>0 then
                local name=(boss or hostile[1]).name
                if STEP[name] then lastStep=STEP[name];fought[STEP[name]]=true;toNextAt,nextStep=nil,nil;opened[STEP[name]]=nil end
                local step=lastStep or 1
                local hold,only,off,basic=false,nil,nil,false
                if boss and not settled[boss.name] then
                    local z=NPCPOS[STEP[boss.name] or step]
                    local x,y=station(z,melee and 3 or (STATION_R[boss.name] or 5))
                    if T.move(x,y) then log(boss.name..' · 走位');hold=true else settled[boss.name]=true end
                end
                if not hold and boss then hold,only,off,basic=H[boss.name](all,p,boss) end
                if hold then T.stop();progress()
                else
                    local target=chooseTarget(hostile,boss,only)
                    log((boss and boss.name or name)..' · 战斗')
                    if not off then off='' end
                    if boss and target==boss and STEP[boss.name]==7 then off=off..' 指点江山 溪山行旅 昭君出塞' end
                    if off~=disabledNow then T.disable(off);disabledNow=off end
                    T.basicOnly(basic==true)
                    T.attack(target)
                end
            elseif #items>0 or #lotus>0 then relics(items,lotus)
            elseif #lampList>0 then lamps(lampList)
            elseif guideNpc and guide(guideNpc) then
            else navigate(p) end
            api.maintain()
            local q=world()
            if q.scene==SCENE and (not hps.px or d2(q,hps.px,hps.py)>0.25) then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,'剑破明王境阶段没有进展：'..phase)
            api.sleep(250)
        end
        T.stop();T.basicOnly(false)
        wait('恢复原珍兽',function() return T.restorePet() end,8500)
        -- The reference leaves nothing to chance here either: it waits for the game to move the team out.
        log('第七重已过，等待离开副本')
        local began=api.now()
        while world().scene==SCENE and api.now()-began<math.max(waitMs,60000) do api.maintain();api.sleep(500) end
        return world().scene~=SCENE
    end

    local completed=0
    local function body()
        api.validate(def,cfg)
        local stayed=false
        while completed<rounds and not stayed do
            if world().scene~=SCENE then
                api.space();api.prepareBattle()
                api.openNpc(entrance)
                wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() and api.teamNear(entrance,20) end,DungeonApi.teamPatience())
                if api.isLeader() then
                    api.selectOption({'#{RGPT_231130_02}'},true);api.sleep(600);QuestFrameAcceptClicked(600)
                end
                -- Entry can need the item the reference collects here first (its RGPT_231130_03 and 71 options).
                local start=api.now()
                while world().scene~=SCENE and api.now()-start<3000 do api.maintain();api.sleep(250) end
                if world().scene~=SCENE then
                    log('领取入场资格')
                    CloseAllWindow();api.openNpc(entrance);api.sleep(500)
                    api.selectOption({'#{RGPT_231130_03}'},true);api.sleep(600)
                    api.selectOption({'#{RGPT_231130_71}'},true);api.sleep(600);CloseAllWindow()
                    if api.isLeader() then
                        api.openNpc(entrance);api.sleep(500)
                        api.selectOption({'#{RGPT_231130_02}'},true);api.sleep(600);QuestFrameAcceptClicked(600)
                    end
                end
                DungeonApi.enterRetry(api,'确认进入明王境',function() return world().scene==SCENE end,function()
                    CloseAllWindow();api.openNpc(entrance);api.sleep(500)
                    api.selectOption({'#{RGPT_231130_02}'},true);api.sleep(600);QuestFrameAcceptClicked(600)
                end,{skipFirst=true})
            end
            stayed=not fight();completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        if stayed then return {status='done',message='剑破明王境已通过第七重，完成 '..completed..' 轮；仍在副本内，没有继续下一轮'} end
        return {status='done',message='剑破明王境完成 '..completed..' 轮；第七重结束和离场均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'剑破明王境停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
