-- 观山海 full flow, written from the reference rules (原脚本源码/Script64/副本/观山海.lua). Layers pick one of 13 school guardians.
-- This task owns its stages and receipts; it does not load the vendor framework. Bag_DeleteBagItem is not ported.
-- Reference fields this program cannot read (disciple titles, target, facing, trap names) are replaced by what can
-- be observed; docs/GUANSHAN_HANDOFF.md names each one.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
Guanshan={}
local R=assert(CombatRuntime)
local ZERO={[749]={x=70,y=70,r=15},[750]={x=59,y=59,r=15},[752]={x=97,y=97,r=15}}
local entrance={name='沈寒洲',x=210,y=51,scene=2}
local BOSS={['燕驰野']=1,['解谊']=1,['唐简']=1,['崔璎']=1,['夜来']=1,['傅致远']=1,['离人偶']=1,['朝覆雨']=1,['段思安']=1,['霜见']=1,['原微之']=1,['慕容信']=1,['无执']=1,['苏延清']=1}
local NOT_ADDS={['铁蒺藜']=true,['蜘蛛']=true,['蜘蛛网']=true,['地面蜘蛛网']=true,['方良']=true}
local KEYS={'BSJN_200327_11','BSJN_200327_172','BSJN_200327_173','BSJN_200327_84','BSJN_200327_60','BSJN_200327_18','BSJN_200327_36','BSJN_200327_30','BSJN_200327_32','BSJN_200327_107','BSJN_200327_129','BSJN_200327_131','BSJN_200327_99','BSJN_200327_101','BSJN_200327_95','PTFB_191228_126','PTFB_191228_124','PTFB_191228_257','PTFB_191228_473'}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function d2(a,x,y) return (a.x-x)^2+(a.y-y)^2 end
local function inside(p) return ZERO[p.scene]~=nil end

function Guanshan.run(injected)
    local api=injected or Shaoshi.newApi();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 3600),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 6),3,6,'队伍人数')
    local leaveLayer=int(tonumber(cfg.guanshan_leave_layer or 100),1,100,'离开层数')
    local stageChoice=cfg.guanshan_stage or '最低'
    assert(stageChoice=='最低' or stageChoice=='整五' or stageChoice=='最高','观山海挑战层数无效')
    local muyu=cfg.guanshan_muyu or '血最低'
    assert(muyu=='血最低' or muyu=='本人' or muyu=='不敲','观山海敲木鱼设置无效')
    for _,k in ipairs({'guanshan_no_tjl','guanshan_xy_stay','guanshan_melee_boss','guanshan_reward_check','guanshan_claim'}) do
        assert(cfg[k]==nil or type(cfg[k])=='boolean','观山海开关无效：'..k)
    end
    local skipBoss=tostring(cfg.guanshan_skip_boss or '')
    local minimum=tonumber(cfg.combat_min_hp or 25)
    local bossNames={};for name in pairs(BOSS) do bossNames[#bossNames+1]=name end
    local def={name='观山海',mission='观山海',map='观山海',npc=entrance,bosses=bossNames}
    function def.inside(p) return inside(p) end
    local phase='';local function log(s) if phase~=s then phase=s;api.log('观山海 · '..s) end end
    local function world() return assert(api.world(),'观山海场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('观山海：'..label..'超时',0)
    end
    local function shown(name)
        return GetLuaValue(string.format("-- guanshan:shown\nlocal e=%s_Env if type(e)=='table' and e.this and e.this:IsVisible() then return 1 end return 0",name),'n')==1
    end
    local function ui(code) GetLuaValue('-- guanshan:ui\n'..code,'',0) end
    -- 本周剩余挑战次数, from the entry window. nil when the window is not showing.
    local function weekLeft()
        local text=GetLuaValue([[-- guanshan:week
            local e=WuLin_Peak_Env
            if type(e)=='table' and e.this and e.this:IsVisible() then return e.WuLin_Peak_ChallengeText:GetText() end
            return ''
        ]],'s')
        local n=type(text)=='string' and text:match('本周剩余挑战次数.-(%d+)/20')
        return n and tonumber(n) or nil
    end
    local function dialogText()
        local text=GetLuaValue([[-- guanshan:dialog-all
            local e=Quest_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return '' end
            local all=''
            for i=0,DataPool:GetNPCEventList_Num()-1 do
                local a,b,c,d,t=DataPool:GetNPCEventList_Item(i)
                if type(t)=='string' then all=all..t..'\n' end
            end
            return all
        ]],'s')
        return type(text)=='string' and text or ''
    end
    local function currentLayer()
        local n=GetLuaValue([[-- guanshan:layer
            local e=WuLin_Small_Env
            if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end
            local function digit(w) if w and w:IsVisible() then local _,_,d=string.find(w:GetProperty('Image') or '','Ceng(%d)') return tonumber(d) end end
            local b,s,g=digit(e.WuLin_Small_Layer1BKG),digit(e.WuLin_Small_Layer2BKG),digit(e.WuLin_Small_Layer3BKG)
            if b and b~=0 then return 100 end
            if g and s then return s*10+g end
            return s or g or 0
        ]],'n')
        return type(n)=='number' and math.floor(n) or 0
    end
    -- Range offered by a window's stage list, then the layer the chosen rule picks.
    local function pickLayer(minL,maxL)
        minL,maxL=math.floor(minL),math.floor(maxL)
        if minL<=0 or maxL<=0 then return 0 end
        if stageChoice=='最高' then return maxL end
        if stageChoice=='整五' then for i=minL,maxL do if i%5==0 then return i end end end
        return minL
    end
    local function claimReward()
        if cfg.guanshan_claim==false then return end
        -- The reference clears the bag first; deleting items is not done here, so a full bag just stops claiming.
        local lines0=api.messages()
        local function has(key,base)
            local n=0
            for _,line in ipairs(api.messages()) do if line:find(key,1,true) then n=n+1 end end
            return n>(base or 0)
        end
        local function count(key) local n=0;for _,l in ipairs(lines0) do if l:find(key,1,true) then n=n+1 end end;return n end
        local base={};for _,k in ipairs({'PTFB_191228_126','PTFB_191228_124','PTFB_191228_257','PTFB_191228_473'}) do base[k]=count(k) end
        log('领取奖励')
        for i=1,3 do
            api.openNpc(entrance);api.sleep(500)
            api.selectOption({'#{PTFB_191228_04}'},true);api.sleep(800)
            api.selectOption({'#{PTFB_191228_241}'},true);api.sleep(800);CloseAllWindow()
            if has('PTFB_191228_126',base.PTFB_191228_126) then api.log('观山海：背包需要整理，未继续领奖');return end
            if has('PTFB_191228_124',base.PTFB_191228_124) or has('PTFB_191228_257',base.PTFB_191228_257) then break end
        end
        for i=1,3 do
            api.openNpc(entrance);api.sleep(500)
            api.selectOption({'#{PTFB_191228_259}'},true);api.sleep(800)
            local text=dialogText()
            local _,_,times=text:find('#{PTFB_191228_246.-(%d).-%d+}')
            local ci=tonumber(times) or i
            if ci>3 then ci=ci%3;if ci==0 then ci=3 end end
            local option=({'#{PTFB_191228_467}','#{PTFB_191228_469}','#{PTFB_191228_471}'})[ci]
            local clicked=option and api.selectOption({option},true);CloseAllWindow();api.sleep(800)
            if not clicked or has('PTFB_191228_473',base.PTFB_191228_473) or has('PTFB_191228_126',base.PTFB_191228_126) then break end
        end
    end

    local function fight()
        local T,tScene
        local start,lastProgress=api.now(),api.now()
        local hps,cast,firstRun={},{},{}
        local lastTalk,startedWait,lastLayer=-100000,nil,0
        local school=api.school()
        local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
        local emei=school==4
        local leader=api.isLeader()
        local own,ownServer=R.host('battle_self_identity');local memberIndex=0
        local identities=api.teamIdentities()
        for i,m in ipairs(identities) do if m.id==own and m.server_id==ownServer then memberIndex=i-1 end end
        if memberIndex>5 then memberIndex=0 end
        local ownName=GetLuaValue("-- guanshan:name\nreturn Player:GetName()",'s')
        assert(type(ownName)=='string' and ownName~='','角色名称不可读')
        local function progress() lastProgress=api.now() end
        local disabledNow
        -- One click per dialog state: a click is sent once, and only a changed dialog or layer allows the next.
        local sentAt,lastSig
        local function sendOnce(name)
            if sentAt then
                assert(api.now()-sentAt<math.max(waitMs,60000),'观山海：'..name..'后没有反馈，未重复发送')
                return false
            end
            sentAt=api.now();return true
        end
        local function ensure(scene)
            if tScene~=scene then
                T=DungeonTactics.new(api,scene,bossNames);T.watch(KEYS);T.readMessages();tScene=scene;firstRun={};disabledNow=nil
            end
        end
        local function station(z,r)
            local a=memberIndex*math.pi/3
            return math.floor(z.x+r*math.cos(a)+0.5),math.floor(z.y+r*math.sin(a)+0.5)
        end
        -- Interaction skills (拼酒、敲木鱼、解救) through the same action route as other skills. A skill this character
        -- does not list cannot be used: named once in the log, and the fight goes on.
        local function useOn(define,o)
            local r=GetLuaValue(string.format([[-- guanshan:interact
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
            if r==-1 and not cast[define] then cast[define]=true;api.log('观山海：技能列表没有机制技能 '..define..'，跳过这一步') end
            return r==1
        end
        -- Stay out of the cone from the boss through spot: rotate about the boss by the safe angle.
        local function coneDodge(boss,spot,p,unsafe)
            local cone=math.deg(math.atan(spot.y-boss.y,spot.x-boss.x))
            local mine=math.deg(math.atan(p.y-boss.y,p.x-boss.x))
            local diff=math.abs(cone-mine);if diff>180 then diff=360-diff end
            if diff>=unsafe then return false end
            local r=math.max(4,math.sqrt(d2(p,boss.x,boss.y)))
            local a=math.rad(cone+unsafe+30)
            T.move(math.floor(boss.x+r*math.cos(a)+0.5),math.floor(boss.y+r*math.sin(a)+0.5));return true
        end
        local function buffsHave(text) return T.hasBuff(api.buffs(),text) end
        local function teamLowest()
            return GetLuaValue([[-- guanshan:lowest
                local n=DataPool:GetTeamMemberCount() local own=Player:GetName() local best,name=2,''
                for i=0,n-1 do
                    local nm,sc,hp,mx=DataPool:GetTeamMemberInfo(i)
                    if type(hp)=='number' and type(mx)=='number' and mx>0 and DataPool:IsTeamMemberInScene(i)==1 and hp>0 and hp/mx<best then best=hp/mx name=nm end
                end
                if name==own then return 1 end return 0
            ]],'n')==1
        end

        -- Each returns: hold (no attack this frame), and optionally the only targets to choose from.
        local H={}
        H['燕驰野']=function(all,p,boss,z)
            if T.within('BSJN_200327_11',5000) or T.within('BSJN_200327_173',5000) or T.within('BSJN_200327_172',5000) then
                if T.escape({boss},6,z.x,z.y,z.r,4) then log('燕驰野 · 远离');return true end
            end
            if T.within('BSJN_200327_84',5000) then
                local spots=T.list(all,'空npc')
                if #spots>0 and T.escape(spots,11,z.x,z.y,z.r,7) then log('燕驰野 · 躲落点');return true end
            end
        end
        H['解谊']=function(all,p,boss,z)
            local jar=T.list(all,'酒坛')[1]
            if jar then
                if buffsHave('追击目标：被解谊持续追击') then
                    log('解谊 · 拼酒');T.stop()
                    if jar.dst>2 then T.move(math.floor(jar.x),math.floor(jar.y)) else useOn(3922,jar) end
                    return true
                end
                return false,{boss}
            end
            if T.hasBuff(api.buffs(boss),'酩酊大醉') then return false,{boss} end
            if T.within('BSJN_200327_60',6000) and not melee and T.escape({boss},6,z.x,z.y,z.r,4) then log('解谊 · 远离');return true end
        end
        H['唐简']=function(all,p,boss,z)
            local spots=T.list(all,'空npc')
            if T.within('BSJN_200327_18',4000) and #spots>0 then
                if coneDodge(boss,spots[1],p,25) then log('唐简 · 躲星河流倾');return true end
            end
            for _,g in ipairs(T.list(all,'残影')) do
                for _,s in ipairs(spots) do
                    if coneDodge(g,s,p,4) then log('唐简 · 躲残影');return true end
                end
            end
            local spikes=T.list(all,'铁蒺藜',T.enemy)
            if #spikes>0 and cfg.guanshan_no_tjl~=true then log('唐简 · 打铁蒺藜');return false,spikes end
        end
        H['崔璎']=function(all,p,boss,z)
            if T.within('BSJN_200327_36',30000) then log('崔璎 · 集火');return false,{boss} end
            local line=T.lastLine['BSJN_200327_30'] or ''
            if T.within('BSJN_200327_30',5000) and line:find(ownName,1,true) and T.escape(T.players(),5,z.x,z.y,z.r,3) then log('崔璎 · 离开队友');return true end
            if T.within('BSJN_200327_32',4000) and buffsHave('花心印：') and T.escape(T.players(),5,z.x,z.y,z.r,3) then log('崔璎 · 花心印离开队友');return true end
        end
        H['夜来']=function(all,p,boss,z)
            local web=T.list(all,'地面蜘蛛网')
            if #web>0 and T.escape(web,4,z.x,z.y,z.r,2) then log('夜来 · 躲蛛网');return true end
            local spiders=T.list(all,'蜘蛛',T.enemy)
            if #spiders>0 then log('夜来 · 打蜘蛛');return false,spiders end
            local nets=T.list(all,'蜘蛛网',T.enemy)
            if #nets>0 then log('夜来 · 打蜘蛛网');return false,nets end
        end
        local yinYang={}
        H['傅致远']=function(all,p,boss,z)
            local bai,hei=T.list(all,'武当白npc'),T.list(all,'武当黑npc')
            if #bai==4 and not yinYang.bai then yinYang.bai=bai end
            if #hei==4 and not yinYang.hei then yinYang.hei=hei end
            local side=#bai>4 and yinYang.bai or #hei>4 and yinYang.hei
            if not side then
                local v=GetLuaValue([[-- guanshan:yinyang
                    local e=WuLin_YinYang_Env
                    if type(e)~='table' or not e.this or not e.this:IsVisible() then return 0 end
                    local pw=e.WuLin_YinYang_BK:GetWindowSize() local sw=e.WuLin_YinYang_Point:GetWindowSize()
                    local off=pw/2-sw/2
                    local _,_,_,x=string.find(e.WuLin_YinYang_Point:GetProperty('UnifiedPosition') or '','(%-?%d+%.*%d*).-(%-?%d+%.*%d*)')
                    x=tonumber(x) or off
                    local d=math.abs(x-off)/61 if d>1 then d=1 end
                    local y=math.asin(d)*200/math.pi
                    if x<off then y=-y end
                    return y
                ]],'n')
                local limit=melee and 5 or 3
                if type(v)=='number' then
                    if v<-limit then side=yinYang.bai elseif v>limit then side=yinYang.hei end
                end
            end
            if side then
                local q,score
                for _,o in ipairs(side) do
                    local a=math.atan(o.y-z.y,o.x-z.x)
                    local x,y=math.floor(z.x+3*math.cos(a)+0.5),math.floor(z.y+3*math.sin(a)+0.5)
                    local s=d2(p,x,y);if not score or s<score then q,score={x,y},s end
                end
                if q and T.move(q[1],q[2]) then log('傅致远 · 阴阳走位');return true end
            end
        end
        local function thd(all,p,boss,z)
            -- Players 2, 4, 6 take 离人偶, the others 朝覆雨; the chase buff overrides that.
            local mine=memberIndex%2==1 and '离人偶' or '朝覆雨'
            local own_=api.buffs()
            if T.hasBuff(own_,'被朝覆雨持续追击') then mine='朝覆雨' elseif T.hasBuff(own_,'被离人偶持续追击') then mine='离人偶' end
            local traps=T.list(all,'桃花岛陷阱npc')
            if #traps>0 and T.escape(traps,5,z.x,z.y,z.r,3) then log('桃花岛 · 躲陷阱');return true end
            local chased=T.hasBuff(own_,'追击目标：')
            local a,b=T.best(all,'朝覆雨',T.enemy),T.best(all,'离人偶',T.enemy)
            if chased and a and b then
                -- A chased player keeps the pair 11 to 14 apart.
                local gap=math.sqrt((a.x-b.x)^2+(a.y-b.y)^2)
                local side=mine=='朝覆雨' and -1 or 1
                if gap<11 then if T.move(math.floor(p.x)+side*2,z.y) then log('桃花岛 · 拉开两人');return true end
                elseif gap>14 then if T.move(z.x+side*(mine=='朝覆雨' and 5 or 6),z.y) then log('桃花岛 · 拉近两人');return true end end
            end
            local want=T.best(all,mine,T.enemy) or a or b
            if want then return false,{want} end
        end
        H['朝覆雨']=thd;H['离人偶']=thd
        H['段思安']=function(all,p,boss,z)
            local traps=T.list(all,'陷阱npc')
            if #traps>0 and T.escape(traps,5,z.x,z.y,z.r,3) then log('段思安 · 躲陷阱');return true end
            -- The reference swaps HP and MP through the 天龙 panel when one runs low.
            local mp,hp=GetLuaValue("-- guanshan:mp\nreturn Player:GetData('MP'),Player:GetData('HP')",'nn'),GetHPPercent()
            local script
            if type(mp)=='number' and mp<3000 and hp>(emei and 6 or 17) then script=0
            elseif hp<20 and not emei and GetMPPercent()>5 then script=1 end
            if script then
                ui(string.format([[local e=WuLin_TL_Env
                    if type(e)=='table' and e.this and e.this:IsVisible() then
                        Clear_XSCRIPT() Set_XSCRIPT_Function_Name('RefixHpMp') Set_XSCRIPT_ScriptID(888011) Set_XSCRIPT_Parameter(0,%d) Set_XSCRIPT_ParamCount(1) Send_XSCRIPT()
                    end]],script))
            end
        end
        H['霜见']=function(all,p,boss,z)
            local spots=T.list(all,'空npc')
            if T.within('BSJN_200327_107',4000) and #spots>0 and coneDodge(boss,spots[1],p,25) then log('霜见 · 躲扇形');return true end
        end
        H['原微之']=function(all,p,boss,z)
            local stay=cfg.guanshan_xy_stay==true
            local blacks=T.list(all,'黑子')
            if not stay and T.within('BSJN_200327_131',5000) and #blacks>0 and T.escape(blacks,4,z.x,z.y,z.r,2) then log('原微之 · 躲黑子');return true end
            if T.within('BSJN_200327_129',5000) then
                local shelter=T.list(all,'白字')[1]
                if shelter then
                    if shelter.dst>=3 then log('原微之 · 去白子');T.move(math.floor(shelter.x),math.floor(shelter.y));return true end
                else
                    -- The member holding the most 白子 (first in team order on a tie) releases one.
                    local best_,who=0,nil
                    for i,m in ipairs(identities) do
                        local ok,set=pcall(api.buffs,m)
                        if ok then for name in pairs(set) do
                            local n=tonumber(name:match('(%d)颗白子'))
                            if n and n>best_ then best_,who=n,i-1 end
                        end end
                    end
                    if who==memberIndex then log('原微之 · 释放白子');ui("local e=WuLin_XY_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.WuLin_XY_Click() end") end
                end
            end
        end
        H['慕容信']=function(all,p,boss,z)
            if T.within('BSJN_200327_99',5000) and T.escape({boss},6,z.x,z.y,z.r,4) then log('慕容信 · 远离');return true end
            local spots=T.list(all,'空npc')
            if T.within('BSJN_200327_101',6000) and #spots>0 and not buffsHave('示剑：成为慕容信释放示剑的目标') then
                if coneDodge(boss,spots[1],p,boss.dst<3 and 90 or boss.dst<4 and 45 or 20) then log('慕容信 · 躲示剑');return true end
            end
        end
        H['无执']=function(all,p,boss,z)
            local rage,armor=0,0
            for name in pairs(api.buffs(boss)) do
                local n=tonumber(name:match('(%d+)%%'))
                if n and name:find('狂慧',1,true) then rage=n/20 end
                if n and name:find('金钟罩',1,true) then armor=n/10 end
            end
            local fish
            if rage>=tonumber(cfg.guanshan_kh or 7) then fish=T.list(all,'红木木鱼')[1] end
            if not fish and armor>=tonumber(cfg.guanshan_jzz or 4) then fish=T.list(all,'鎏金木鱼')[1] end
            if fish and muyu~='不敲' and (muyu=='本人' or teamLowest()) then
                log('无执 · 敲木鱼');T.stop()
                if fish.dst>3 then T.move(math.floor(fish.x),math.floor(fish.y)) else useOn(3943,fish) end
                return true
            end
            if T.within('BSJN_200327_95',7000) and T.escape({boss},6,z.x,z.y,z.r,4) then log('无执 · 远离');return true end
        end
        H['苏延清']=function(all,p,boss,z)
            if buffsHave('方相缠身：') then log('苏延清 · 方相缠身');return true end
            local bound=T.list(all,'方相',T.enemy)[1]
            if bound then
                -- Whoever is closest frees the captured member; this client checks only against those it can see.
                local closest=true
                local d=d2(p,bound.x,bound.y)
                for _,o in ipairs(T.players()) do if d2(o,bound.x,bound.y)<d then closest=false;break end end
                if closest then
                    log('苏延清 · 解救队友');T.stop()
                    if bound.dst>3 then T.move(math.floor(bound.x),math.floor(bound.y)) else useOn(3960,bound) end
                    return true
                end
            end
            local danger={}
            for _,o in ipairs(all) do
                if o.name=='抓人预警npc' or o.name=='鬼面刷新预警npc' or o.name=='鬼面重置预警npc' or o.name=='陷阱npc' or (not melee and o.name=='方良') then danger[#danger+1]=o end
            end
            if #danger>0 and T.escape(danger,4,z.x,z.y,z.r,2) then log('苏延清 · 躲预警');return true end
        end

        local function chooseTarget(hostile,boss,only)
            if only and #only>0 then
                local t=only[1]
                for _,o in ipairs(only) do
                    if melee then if o.dst<t.dst then t=o end elseif o.hp<t.hp then t=o end
                end
                return t
            end
            -- Disciples first. The reference ranks them by title, which cannot be read.
            local adds={}
            for _,o in ipairs(hostile) do if not BOSS[o.name] and not NOT_ADDS[o.name] then adds[#adds+1]=o end end
            if #adds>0 then
                local t=adds[1]
                for _,o in ipairs(adds) do
                    if melee then if o.dst<t.dst then t=o end elseif o.hp<t.hp then t=o end
                end
                if not (melee and cfg.guanshan_melee_boss==true and t.dst>2) then return t end
            end
            return boss or hostile[1]
        end
        -- Non-fight frames: talk to the guardian about every 6 seconds and act on what its dialog offers.
        local function onNpc(all,p,z)
            local npc
            for _,o in ipairs(all) do if BOSS[o.name] and o.hp>0 then npc=o;break end end
            if not npc then log('寻找守关人');T.stop();T.move(z.x,z.y);return end
            if skipBoss~='' and skipBoss:find(npc.name,1,true) then
                log('按设置不打 '..npc.name..'，离开')
                if sendOnce('离开') then
                    TalkNpc(npc.name);api.sleep(800)
                    api.selectOption({'#{PTFB_191228_73}'},true);api.sleep(800);api.selectOption({'#{PTFB_191228_218}'},true);api.sleep(800);api.selectOption({'#{PTFB_191228_477}'},true);api.sleep(800);CloseAllWindow()
                end
                return
            end
            startedWait=startedWait or api.now()
            local openers
            if npc.name=='朝覆雨' or npc.name=='离人偶' then openers=memberIndex<=1
            elseif npc.name=='解谊' then
                local em=api.emeiMembers()
                if #em>0 then openers=em[1].id==own else openers=leader end
            else openers=leader end
            if api.now()-lastTalk<6000 then
                if not openers then T.stop();local x,y=station(z,3);T.move(x,y) end
                return
            end
            lastTalk=api.now();T.stop()
            if npc.dst>=3 and openers then T.move(math.floor(npc.x),math.floor(npc.y)) end
            local talkName=npc.name
            if npc.name=='朝覆雨' or npc.name=='离人偶' then talkName=memberIndex==1 and T.best(all,'离人偶') and '离人偶' or '朝覆雨' end
            TalkNpc(talkName);api.sleep(800)
            local text=dialogText()
            local layer=currentLayer()
            if layer~=lastLayer then lastLayer=layer;log('当前第 '..layer..' 层') end
            if text~='' and text..'|'..layer~=lastSig then lastSig=text..'|'..layer;sentAt=nil;progress() end
            local function leave()
                if not sendOnce('离开') then CloseAllWindow();return end
                api.selectOption({'#{PTFB_191228_73}'},true);api.sleep(800)
                api.selectOption({'#{PTFB_191228_218}'},true);api.sleep(800)
                api.selectOption({'#{PTFB_191228_477}'},true);api.sleep(800);CloseAllWindow()
            end
            if text:find('#{PTFB_191228_217}',1,true) then
                if layer>=leaveLayer then log('到达第 '..layer..' 层，离开');leave();return end
                if leader and not sentAt then
                    if not shown('WuLin_Up') then api.selectOption({'#{PTFB_191228_217}'},true);api.sleep(800) end
                    if shown('WuLin_Up') then
                        local minL,maxL=GetLuaValue([[-- guanshan:up-range
                            local e=WuLin_Up_Env local c=e.WuLin_Up_Choice local n=c:GetListCount()
                            if n<=0 then return 0,0 end
                            c:SetCurrentSelect(0) local a=c:GetCurrentSelect() c:SetCurrentSelect(n-1) return a,c:GetCurrentSelect()
                        ]],'nn')
                        local target=pickLayer(minL or 0,maxL or 0)
                        if target>0 then
                            log('挑战第 '..target..' 层');sendOnce('选择下一层')
                            ui(string.format("Clear_XSCRIPT() Set_XSCRIPT_Function_Name('LeaderUpgradeConfirm') Set_XSCRIPT_ScriptID(893399) Set_XSCRIPT_Parameter(0,%d) Set_XSCRIPT_ParamCount(1) Send_XSCRIPT()",target))
                            api.sleep(1000)
                        end
                    end
                end
                if sentAt then sendOnce('选择下一层') end
                CloseAllWindow()
            elseif text:find('#{PTFB_191228_219}',1,true) then
                if openers and sendOnce('开启') then api.selectOption({'#{PTFB_191228_219}'},true);api.sleep(800) end
                CloseAllWindow()
            elseif text:find('#{PTFB_191228_77',1,true) then
                if layer>leaveLayer then log('到达第 '..layer..' 层，离开');leave();return end
                if openers then
                    -- 血祭 cooldown and team HP 80%, up to the reference's 90 seconds.
                    local ready=api.now()-startedWait>90000 or api.teamHealthy(80)
                    if ready and api.now()-startedWait<=90000 then
                        for _,m in ipairs(api.emeiMembers()) do if T.hasBuff(api.buffs(m),'珍兽施放共生和血祭') then ready=false end end
                    end
                    if ready and sendOnce('开启 '..talkName) then
                        log('开启 '..talkName)
                        QuestFrameOptionClicked('#{PTFB_191228_77',0);api.sleep(800)
                        GetLuaValue([[-- guanshan:confirm2
                            local e=MessageBox_Self2_Env
                            if type(e)=='table' and e.this and e.this:IsVisible() then
                                local f=e.MessageBox_Self2_OK_Clicked or MessageBox_Self2_OK_Clicked
                                if type(f)=='function' then f() end
                            end]],'',0)
                    end
                end
                CloseAllWindow()
            elseif text:find('#{PTFB_191228_218}',1,true) then
                log('挑战失败，离开')
                if sendOnce('离开') then
                    api.selectOption({'#{PTFB_191228_218}'},true);api.sleep(800)
                    api.selectOption({'#{PTFB_191228_36}'},true);api.sleep(800)
                    api.selectOption({'#{PTFB_191228_477}'},true);api.sleep(800)
                end
                CloseAllWindow()
            else CloseAllWindow() end
            if not openers and world().scene==tScene then local x,y=station(z,3);T.move(x,y) end
        end

        while true do
            local p=world()
            if not inside(p) then break end
            ensure(p.scene)
            assert(api.now()-start<battleMs,'观山海战斗超过时限')
            api.alive(minimum,'观山海：角色血量低于停止阈值，自动复活未接入，已停止')
            api.skipCinematic();if T.readMessages() then progress() end
            local all=T.rows();local z=ZERO[p.scene]
            local hostile,boss={},nil
            for _,o in ipairs(all) do
                if T.enemy(o) then
                    hostile[#hostile+1]=o
                    if BOSS[o.name] and (not boss or o.dst<boss.dst) then boss=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;progress() end
                end
            end
            if #hostile>0 then
                startedWait=nil;sentAt=nil
                if not firstRun[1] and boss then
                    local x,y=station(z,melee and 3 or 5)
                    if T.move(x,y) then log('守关 · 走位') else firstRun[1]=true end
                end
                if firstRun[1] or not boss then
                    local hold,only=false,nil
                    if boss and H[boss.name] then hold,only=H[boss.name](all,p,boss,z) end
                    if hold then T.stop();progress()
                    else
                        if boss then log(boss.name..' · 战斗') else log('清理') end
                        local target=chooseTarget(hostile,boss,only)
                        -- Skills the reference withholds on the guardian, and the stages where it only basic-attacks.
                        local off=''
                        if boss and target==boss then
                            off='指点江山 溪山行旅 昭君出塞'
                            if boss.name=='慕容信' then off=off..' 聚星阵·长生 情尽盈血' end
                            if boss.name=='段思安' then off=off..' 暗器投掷 暗器连击 暗器打穴 暗器护体 诛仙万象' end
                        end
                        if off~=disabledNow then T.disable(off);disabledNow=off end
                        T.basicOnly(boss~=nil and target==boss and ((boss.name=='崔璎' and boss.hp>=10 and boss.hp<=40 and not T.within('BSJN_200327_36',30000)) or (boss.name=='段思安' and emei)))
                        T.attack(target)
                    end
                end
            else onNpc(all,p,z) end
            api.maintain()
            local q=world()
            if not hps.px or d2(q,hps.px,hps.py)>0.25 then hps.px,hps.py=q.x,q.y;progress() end
            assert(api.now()-lastProgress<180000,'观山海阶段没有进展：'..phase)
            api.sleep(250)
        end
        if T then T.stop() end
        return lastLayer
    end

    local completed=0
    local function body()
        api.validate(def,cfg)
        local lastDone=0
        for _=1,rounds do
            local before
            if not inside(world()) then
                api.space();api.prepareBattle()
                api.openNpc(entrance)
                wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() and api.teamNear(entrance,20) end)
                local leader=api.isLeader()
                if leader then api.selectOption({'#{PTFB_191228_02}'},true);api.sleep(1000) end
                -- Entry window, then the stage window: leader confirms a layer, then members confirm.
                local confirmed=false
                wait('确认进入观山海',function()
                    if inside(world()) then return true end
                    local left=weekLeft()
                    if left then
                        before=before or left
                        if left==0 then return 'full' end
                        ui("local e=WuLin_Peak_Env if type(e)=='table' and e.this and e.this:IsVisible() then e.WuLin_Peak_EnterScene() end")
                    end
                    local state=GetLuaValue([[-- guanshan:choose
                        local e=WuLin_Env
                        if type(e)~='table' or not e.this or not e.this:IsVisible() then return -1 end
                        if Player:IsLeader()==1 then
                            if e.WuLin_Right_Info1_Choose:IsVisible() then
                                if e.WuLin_Right_Info1_Choose:GetProperty('Disabled')=='False' then return 1 end
                            elseif e.WuLin_Right_Info4_Choose:IsVisible() then return 2 end
                        elseif e.WuLin_Right_Info2_Choose:IsVisible() then
                            if e.WuLin_Right_Info2_Choose:GetProperty('Disabled')=='False' then return 3 end
                            return 4
                        elseif e.WuLin_Right_Info3_Choose:IsVisible() then return 5 end
                        return 0
                    ]],'n')
                    if (state==1 or state==3) and not confirmed then
                        confirmed=true
                        if cfg.guanshan_reward_check==true then
                            ui([[local e=WuLin_Env
                                if WuLinZhiDian:GetAvalibleAwardCount()>0 then
                                    e.WuLin_Right_Mode:SetCheck(1)
                                    Clear_XSCRIPT() Set_XSCRIPT_Function_Name('WeekAwardActive') Set_XSCRIPT_ScriptID(893398) Set_XSCRIPT_ParamCount(0) Send_XSCRIPT()
                                end]])
                        else
                            ui([[local e=WuLin_Env
                                if e.WuLin_Right_Mode:GetCheck()>0 then
                                    e.WuLin_Right_Mode:SetCheck(0)
                                    Clear_XSCRIPT() Set_XSCRIPT_Function_Name('WeekAwardCancelActive') Set_XSCRIPT_ScriptID(893398) Set_XSCRIPT_ParamCount(0) Send_XSCRIPT()
                                end]])
                        end
                        api.sleep(500)
                        if state==1 then
                            local minL,maxL=GetLuaValue([[-- guanshan:range
                                local c=WuLin_Env.WuLin_Right_Info1_Choice local n=c:GetListCount()
                                if n<=0 then return 0,0 end
                                c:SetCurrentSelect(0) local a=c:GetCurrentSelect() c:SetCurrentSelect(n-1) return a,c:GetCurrentSelect()
                            ]],'nn')
                            local target=pickLayer(minL or 0,maxL or 0)
                            assert(target>0,'观山海：层数列表不可读')
                            log('挑战第 '..target..' 层')
                            ui(string.format("WuLin_Env.WuLin_Right_Info1_Choice:SetCurrentSelect(%d)",target-1));api.sleep(800)
                            ui("WuLin_Env.WuLin_Leader_OnChooseStageConfirm()")
                        else ui("WuLin_Env.WuLin_Member_OnChooseStageConfirm()") end
                    end
                end,math.max(waitMs,120000))
                if not inside(world()) then
                    return {status=completed>0 and 'done' or 'already_done',message='观山海本周次数已满；本次完成 '..completed..' 轮'}
                end
            end
            lastDone=fight();completed=completed+1
            claimReward()
            if before then
                -- Leaving is the end of a run. The week's count confirms a challenge was used.
                local leader=api.isLeader()
                api.openNpc(entrance);if leader then api.selectOption({'#{PTFB_191228_02}'},true);api.sleep(1000) end
                local left=weekLeft();CloseAllWindow()
                if leader then
                    assert(left and left<before,'观山海：本周剩余次数没有减少（进入前 '..before..'，现在 '..tostring(left)..'），不算完成')
                end
            end
            log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='观山海完成 '..completed..' 轮，最后第 '..lastDone..' 层；已离开副本'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'观山海停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
