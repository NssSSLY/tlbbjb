-- Reference 00313c18, decoded from its original GBK chunk. This task owns its
-- stages and receipts; it does not load the vendor's mixed generic framework.
LoadScript('yanzi_api')
LoadScript('dungeon_pet_guard')
Yanzi={}
local R=assert(CombatRuntime)
local modes={['普通']={'讨伐燕子坞',''},['初级']={'#{XKFB_250115_08}','·闻恶'},
    ['中级']={'#{XKFB_250115_49}','·识恶'},['高级']={'#{XKFB_250115_09}','·罚恶'}}
local bosses={'段延庆','岳老三','云中鹤','鸠摩智','姚伯当','司马林','慕容复','王语嫣'}
local entrance={name='李纲',x=70,y=120,scene=4}
local guides={{name='呼延豹',x=79,y=203,scene=236},{name='钱宏宇',x=217,y=150,scene=236},
    {name='华赫艮',x=180,y=88,scene=236}}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
local function dist(a,b) return (a.x-b[1])^2+(a.y-b[2])^2 end
local function inner(p) return p.scene==236 and p.x>10 and p.x<=165 and p.y>10 and p.y<=135 end
local function enemy(o) return o and o.class=='怪物' and o.hp>0 end
function Yanzi.run(injected)
    local api=injected or YanziApi.new();local cfg=TaskConfig or {}
    local rounds=int(tonumber(cfg.dungeon_rounds or 1),1,20,'轮数')
    local waitMs=int(tonumber(cfg.dungeon_wait_seconds or 45),5,180,'状态等待')*1000
    local battleMs=int(tonumber(cfg.dungeon_battle_seconds or 1800),30,3600,'战斗时限')*1000
    local team=int(tonumber(cfg.dungeon_team_count or 3),3,6,'队伍人数')
    local mode=assert(modes[cfg.yzw_type or '普通'],'燕子坞难度无效')
    for _,k in ipairs({'yanzi_kill_wyy','yanzi_supplies','yanzi_loot'}) do assert(cfg[k]==nil or type(cfg[k])=='boolean','燕子坞开关无效：'..k) end
    local def={name='燕子坞',mission='讨伐燕子坞',map='燕子坞',npc=entrance,bosses={}}
    function def.inside(p) return p.scene==236 end
    for _,name in ipairs(bosses) do def.bosses[#def.bosses+1]=name;if mode[2]~='' then def.bosses[#def.bosses+1]=name..mode[2] end end
    local phase,completed='',0
    local function log(s) if phase~=s then phase=s;api.log('燕子坞 · '..s) end end
    local function world() return assert(api.world(),'燕子坞场景不可读') end
    local function wait(label,probe,timeout)
        log(label);local start=api.now()
        repeat local v=probe();if v then return v end;api.maintain();api.sleep(250) until api.now()-start>=(timeout or waitMs)
        error('燕子坞：'..label..'超时',0)
    end
    local lastMove,key=-10000,''
    local function move(point)
        assert(world().scene==236,'燕子坞移动时场景已变化')
        if dist(world(),point)<=1 then return false end
        local nextKey=point[1]..','..point[2]
        if nextKey~=key or api.now()-lastMove>=4000 then api.stop();R.call(R.codes.RunTo,{236},point);key=nextKey;lastMove=api.now() end
        return true
    end
    local function go(point,label)
        wait(label,function() return not move(point) end,math.max(waitMs,45000))
    end
    local function rows()
        local all=api.objects();assert(type(all)=='table' and #all<=512,'燕子坞对象不可读')
        local result={}
        for _,o in ipairs(all) do
            for _,base in ipairs(bosses) do
                for _,variant in pairs(modes) do
                    if variant[2]~='' and o.name==base..variant[2] then
                        assert(variant==mode,'燕子坞首领后缀与所选难度不符：'..o.name)
                        local copy={};for k,v in pairs(o) do copy[k]=v end;o=copy;o.name=base;break
                    end
                end
            end
            result[#result+1]=o
        end
        return result
    end
    local function named(all,name)
        local found
        for _,o in ipairs(all) do if o.name==name then assert(not found,'燕子坞同名对象不唯一：'..name);found=o end end
        return found
    end
    local function sameCampaign(a,b)
        assert(a.name==b.name and a.limit==b.limit and b.used>=a.used,'燕子坞活动记录发生变化或次数回退')
    end
    local function gather(point)
        wait('等待队伍集合',function() return api.teamReady(team) and api.teamTogether() and api.teamNear(point,20) end)
    end
    local function supply()
        local item=api.item('悲酥清风解药');if item.total>0 then return item end
        api.pickup();api.sleep(500);item=api.item(item.name);if item.total>0 then return item end
        local opened=0
        for _,name in ipairs({'段延庆的宝箱','段延庆的宝藏','段延庆的宝箱·遗'}) do
            local box=api.item(name)
            while box.total>0 and opened<3 do
                api.space();api.useItem(box)
                opened=opened+1
                wait('等待段延庆宝箱道具反馈',function()
                    local after=api.item(name);local antidote=api.item('悲酥清风解药')
                    if antidote.total>0 then return antidote end
                    if after.total<box.total then return true end
                end,8000)
                item=api.item(item.name);if item.total>0 then return item end
                box=api.item(name)
            end
        end
        api.takeAntidote();api.sleep(500);return api.item(item.name)
    end
    local function fight(before)
        local ctx=api.beginBattle(def,236).combat;local pet=DungeonPetGuard.new()
        local start,lastProgress=api.now(),api.now();local all=rows();local p=world()
        local stage=inner(p) and 4 or 1
        if stage==1 and ((named(all,'钱宏宇') and dist(p,{217,150})<55^2) or enemy(named(all,'鸠摩智')) or enemy(named(all,'姚伯当')) or enemy(named(all,'司马林')))
            and not named(all,'段延庆') then stage=2 end
        local opened,duanDone,jiumoDone,mrfDone={},false,false,false
        local seen,dead,hps={}, {},{};local wave=0;local stopped=false;local firstHit=false;local reflected=false;local firstHitAt=0
        local ice,iceUntil=nil,0;local prior={};for _,s in ipairs(api.messages()) do prior[s]=true end
        local qianPositive,qianZero=false,0;local previousPosition=world();local patrol=1
        local function stop()
            if not stopped then api.stopAttack();stopped=true end
            if ctx.id>=0 then ctx=R.new(236,{boss_names=def.bosses}) end
        end
        local function advance(n)
            assert(n>=stage,'燕子坞阶段回退')
            if n~=stage then stop();stage=n;lastProgress=api.now();patrol=1;key='' end
        end
        local function observe(o)
            if not o then return false end
            local id=o.id..':'..o.server_id;local key=o.name
            if hps[key] and hps[key].id~=id and seen[key] then error('燕子坞首领身份变化：'..key,0) end
            if o.hp>0 and enemy(o) then
                seen[key]=id;dead[key]=0
                if not hps[key] or o.hp<hps[key].hp then lastProgress=api.now() end
                hps[key]={id=id,hp=o.hp}
            elseif o.hp==0 and seen[key]==id then
                dead[key]=(dead[key] or 0)+1;return dead[key]>=2
            end
            return false
        end
        local function attack(target)
            if not target or not enemy(target) then return false end
            if dist(world(),{target.x,target.y})>35^2 then move({target.x,target.y});return true end
            if not DungeonPetGuard.update(pet,false) then stop();return true end
            local submitted=ctx.submitted
            if not api.maintain() and R.canAttack() then
                stopped=false;R.selectOriginalTarget(ctx,target.id);R.step(ctx)
            end
            return true,ctx.submitted>submitted
        end
        while not mrfDone do
            assert(api.now()-start<battleMs,'燕子坞战斗超过时限')
            assert(world().scene==236,'燕子坞未完成时离开副本')
            api.skipCinematic();all=rows();p=world()
            local duan,jiumo,mrf=named(all,'段延庆'),named(all,'鸠摩智'),named(all,'慕容复')
            duanDone=observe(duan) or duanDone;jiumoDone=observe(jiumo) or jiumoDone;mrfDone=observe(mrf) or mrfDone
            local messages=api.messages();local current={};local fresh={}
            for _,s in ipairs(messages) do current[s]=true;if not prior[s] then fresh[#fresh+1]=s end end;prior=current
            for _,s in ipairs(fresh) do
                local w=s:match('第(%d+)拨燕子坞援军')
                if w then w=int(tonumber(w),1,9,'援军拨数');if w>wave then wave=w;lastProgress=api.now() end end
                if stage==1 and (s:find('请迅速赶至阻截点协助钱宏宇',1,true) or s:find('请各位大侠速速前往水军旗舰保护他',1,true)) then advance(2) end
                if stage==2 and s:find('鸠摩智被打败，其手下纷纷四散逃窜',1,true) then jiumoDone=true end
                if stage==4 and s:find('慕容复已被打败',1,true) and seen['慕容复'] then mrfDone=true end
                if stage==4 and s:find('YZW_MRF_SKILL_BTXD:',1,true) then
                    local x,y=s:match('YZW_MRF_SKILL_BTXD:%s*(%d+%.?%d*),(%d+%.?%d*)')
                    x,y=tonumber(x),tonumber(y);assert(x and y and x>=0 and x<=300 and y>=0 and y<=300,'冰天雪地坐标参数无效')
                    ice={x=x,y=y};iceUntil=api.now()+5000
                end
            end
            if inner(p) and stage<4 then advance(4) end
            if duanDone and stage==1 and not enemy(named(all,'岳老三')) and not enemy(named(all,'云中鹤')) then
                stop()
                if cfg.yanzi_supplies~=false then
                    log('段延庆结束 · 获取解药')
                    assert(supply().total>0,'段延庆战场未取得悲酥清风解药，停在本场；请补充后继续')
                end
                advance(2)
            end
            if jiumoDone and stage==2 then advance(3) end
            if mrfDone then break end
            local own=api.buffs()
            if own['就擒：无法使用'] then
                stop();DungeonPetGuard.update(pet,true);log('悲酥清风 · 使用解药')
                assert(cfg.yanzi_supplies~=false,'角色中了悲酥清风；自动解药已关闭')
                local item=supply();assert(item.total>0,'缺少悲酥清风解药，无法继续；拾取和锦囊均未取得')
                api.useItem(item)
                wait('等待悲酥清风解除',function() return not api.buffs()['就擒：无法使用'] end,8000)
                lastProgress=api.now()
            elseif stage==1 then
                log('段延庆 · 呼延豹开场与战斗')
                local target=enemy(duan) and duan or enemy(named(all,'岳老三')) and named(all,'岳老三') or named(all,'云中鹤')
                if not attack(target) then
                    if not opened[1] and api.isLeader() then
                        api.openNpc(guides[1]);gather(guides[1]);api.selectOption({'战斗吧！'},false);opened[1]=true;lastProgress=api.now()
                    elseif not target then move({83,203}) end
                end
            elseif stage==2 then
                log('钱宏宇 · 阻截援军（'..wave..'/9）与鸠摩智')
                local qian=named(all,'钱宏宇')
                if qian and qian.hp>0 then qianPositive=true;qianZero=0 end
                if qian and qian.hp==0 and qianPositive then qianZero=qianZero+1;assert(qianZero<2,'钱宏宇死亡，保护失败') end
                local target=enemy(jiumo) and jiumo or nil;local best
                if not target then for _,o in ipairs(all) do
                    if enemy(o) and o.name~='慕容复' and o.name~='王语嫣' and o.name~='段延庆' and dist(o,{217,150})<=70^2 then
                        local d=dist(o,{p.x,p.y});if not best or d<best then target=o;best=d end
                    end
                end end
                if not attack(target) then
                    if qian and not opened[2] and api.isLeader() and wave==0 then
                        api.openNpc(guides[2]);gather(guides[2]);api.selectOption({'战斗吧！'},false);opened[2]=true;lastProgress=api.now()
                    elseif wave==9 then advance(3)
                    else
                        local route={{217,150},{227,181},{198,156},{220,158}}
                        if not move(route[patrol]) then patrol=patrol%#route+1 end
                    end
                end
            elseif stage==3 then
                log('华赫艮 · 进入地道')
                if enemy(jiumo) then attack(jiumo)
                elseif not opened[3] then
                    stop();api.openNpc(guides[3])
                    wait('等待地道开放',function() return api.selectOption({'从地道进入燕子坞'},true) end)
                    opened[3]=true
                    wait('确认进入慕容复区域',function() return inner(world()) end)
                    advance(4)
                end
            else
                log('慕容复 · 战斗与机制')
                if not inner(p) then error('慕容复阶段位置不在内场',0) end
                local buff=enemy(mrf) and api.buffs(mrf) or {}
                local hold=false
                if buff['斗转星移'] then reflected=true;hold=true;stop();log('慕容复 · 斗转星移停手') end
                if ice and api.now()<iceUntil then
                    hold=true;stop()
                    if (p.x-ice.x)^2+(p.y-ice.y)^2<100 then
                        local point,best
                        for y=69,93 do if (49-ice.x)^2+(y-ice.y)^2>=100 then
                            local d=dist(p,{49,y});if not best or d<best then point={49,y};best=d end
                        end end
                        assert(point,'冰天雪地没有可用避让坐标');move(point)
                    end
                    log('慕容复 · 冰天雪地避让')
                end
                if hold then DungeonPetGuard.update(pet,true)
                elseif enemy(mrf) then
                    if firstHit and not reflected and mrf.hp>=97.99 then
                        -- A submitted attack can still be winding up. Do not
                        -- cancel it or send another output before observing it.
                        assert(api.now()-firstHitAt<8000,'慕容复首次输出未出现生命/反伤反馈，停止且不重发')
                        DungeonPetGuard.update(pet,true);log('慕容复 · 等待首次斗转星移或生命反馈')
                    else
                        local wyy=named(all,'王语嫣');local target=cfg.yanzi_kill_wyy and enemy(wyy) and wyy or mrf
                        local _,issued=attack(target)
                        if mrf.hp>=97.99 and target==mrf and issued then firstHit=true;firstHitAt=api.now() end
                    end
                elseif not opened[4] then
                    if api.isLeader() then go({49,89},'慕容复入口集合');gather({scene=236,x=49,y=89});go({60,70},'引出慕容复');go({49,89},'返回慕容复战位')
                    else move({49,89}) end
                    opened[4]=true;lastProgress=api.now()
                end
            end
            api.maintain()
            local actual=world()
            if dist(actual,{previousPosition.x,previousPosition.y})>0.25 then previousPosition=actual;lastProgress=api.now() end
            assert(api.now()-lastProgress<(stage==2 and 180000 or 120000),'燕子坞阶段没有进展：'..phase)
            api.sleep(250)
        end
        stop()
        wait('恢复原珍兽',function() return DungeonPetGuard.update(pet,false) end,8500)
        if cfg.yanzi_loot~=false then api.pickup();api.sleep(500) end
        if world().x>77 or world().y>95 or world().x<40 then go({49,80},'前往离场通道') end
        wait('前往出口',function() return world().scene~=236 or not move({65,36}) end,math.max(waitMs,45000))
        if world().scene==236 then move({62,20}) end
        wait('确认离开燕子坞',function()
            local p=world();if p.scene~=236 then assert(p.scene==4,'燕子坞出口返回了未预期场景');return true end
            move({62,20})
        end)
        local refreshed=false
        local after=wait('确认本轮活动次数',function()
            local c=api.campaign(not refreshed);refreshed=true;sameCampaign(before,c)
            if c.used>before.used then assert(c.used==before.used+1,'燕子坞次数一次增加超过一轮');return c end
        end,math.max(waitMs,15000))
        return after
    end
    local function body()
        api.validate(def,cfg)
        for _=1,rounds do
            local before=api.campaign(true)
            if world().scene~=236 and before.used==before.limit then
                return {status=completed>0 and 'done' or 'already_done',message='燕子坞今日次数已满；本次完成 '..completed..' 轮'}
            end
            api.space();api.prepareBattle()
            if world().scene~=236 then
                api.openNpc(entrance);gather(entrance)
                if api.isLeader() then
                    if not api.selectOption({mode[1]},true) then
                        api.selectOption({'讨伐燕子坞'},false)
                        wait('等待所选难度入场选项',function() return api.selectOption({mode[1]},true) end)
                    end
                end
                wait('确认进入燕子坞',function() return world().scene==236 end)
            end
            fight(before);completed=completed+1;log('本轮完成（'..completed..'/'..rounds..'）')
        end
        return {status='done',message='燕子坞完成 '..completed..' 轮；慕容复结束、离场及活动次数均已确认'}
    end
    local ok,result=pcall(body);local stopped,why=pcall(api.stopAttack)
    if not ok then error(tostring(result)..' [阶段：'..phase..']',0) end
    assert(stopped,'燕子坞停止动作失败：'..tostring(why))
    return TaskLifecycle.report(result.status,result.message)
end
Yanzi.entrance=entrance
