-- Short tasks, written from the reference rules (原脚本源码/Script64: 活动/情寄虞兮, 常用/星落九野, 活动/问画朔源, 帮庄/帮会福利宝箱, 帮庄/帮会疑踪,
-- 帮庄/帮会神兵阁刷怪, 帮庄/刷怪无相神兵阁, 功能/真元凝元, 物品/购买元丹坊). They own their stages and receipts and do not load the vendor framework.
-- docs/SHORT_TASKS_HANDOFF.md names the differences.
LoadScript('shaoshi')
LoadScript('dungeon_tactics')
ShortTasks={}
local function int(n,lo,hi,label) assert(type(n)=='number' and n==math.floor(n) and n>=lo and n<=hi,label..'无效');return n end
-- What every short task shares: logging, limits, the receipt, and the small game reads.
local function open(label,minutes,def0)
    local api=Shaoshi.newApi();local cfg=TaskConfig or {}
    local S={api=api,cfg=cfg,phase=''}
    S.deadline=api.now()+int(tonumber(minutes),1,115,'运行时长')*60000
    local minimum=tonumber(cfg.combat_min_hp or 25)
    function S.log(s) if S.phase~=s then S.phase=s;api.log(label..' · '..s) end end
    function S.world() return assert(api.world(),label..'场景不可读') end
    function S.check(resume)
        assert(api.now()<S.deadline,label..'超过总时限')
        api.alive(minimum,label..'：角色血量低于停止阈值，已停止',resume)
    end
    function S.ui(code) GetLuaValue('-- short:ui\n'..code,'',0) end
    function S.wait(ms) S.check();api.maintain();api.sleep(ms) end
    function S.state() return GetLuaValue('-- short:state\nif not Player or type(Player.GetState)~="function" then return -1 end return Player:GetState()','n') end
    -- Casting or gathering, as the reference waits for it (5 and 8).
    function S.busy(seconds)
        api.sleep(300)
        local began=api.now()
        while (S.state()==5 or S.state()==8) and api.now()-began<seconds*1000 do api.maintain();api.sleep(200) end
    end
    function S.count(name,bag)
        local n=GetLuaValue(string.format([[-- short:count
            local want,c=%q,0
            for i=0,DataPool:Get%s_Num()-1 do local a=PlayerPackage:EnumItem('%s',i)
                if a and a:GetID()~=0 and a:GetName()==want then c=c+(a:GetNum() or 1) end end
            return c]],name,bag=='quest' and 'TaskBag' or 'BaseBag',bag=='quest' and 'quest' or 'base'),'n')
        return tonumber(n) or 0
    end
    function S.use(name)
        return GetLuaValue(string.format([[-- short:use
            local want=%q
            for i=0,DataPool:GetBaseBag_Num()-1 do local a=PlayerPackage:EnumItem('base',i)
                if a and a:GetID()~=0 and a:GetName()==want then PlayerPackage:UseItem(i) return 1 end end
            return 0]],name),'n')==1
    end
    function S.dialog()
        local text=GetLuaValue([[-- short:dialog-all
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
    function S.loot() GetLuaValue("-- short:loot\nlocal e=LootPacket_Env if e and e.this and e.this:IsVisible() then PlayerPackage:PickAllItem() CloseWindow('LootPacket',true) end",'',0) end
    function S.finish(body)
        local def={name=label,mission=def0 or label,map='',npc={name='',x=0,y=0,scene=0},bosses={}}
        function def.inside() return false end
        S.def=def
        local ok,result=pcall(function() api.validate(def,cfg);return body() end)
        local stopped,why=pcall(api.stopAttack)
        if not ok then error(tostring(result)..' [阶段：'..S.phase..']',0) end
        assert(stopped,label..'停止动作失败：'..tostring(why))
        return TaskLifecycle.report(result.status,result.message)
    end
    return S
end
ShortTasks.open=open
local CITIES={[1]={'范纯粹',322,264},[2]={'范纯礼',179,121},[246]={'范纯祐',190,131}}
local function cityName()
    local read="-- short:guild-city\nlocal n=Guild:GetMyGuildDetailInfo('CityName') if type(n)=='string' then return n end return ''"
    local n=GetLuaValue(read,'s')
    if n==nil or n=='' or n=='-1' then
        GetLuaValue("-- short:guild-ask\nGuild:AskGuildDetailInfo()",'',0)
        return nil
    end
    return n
end
-- Into the character's own guild city. Returns its scene, or nil when there is no guild.
local function toGuild(S)
    local api=S.api
    local name=cityName();if not name then api.sleep(1000);name=cityName() end
    if not name then return nil end
    local began=api.now()
    while S.world().map~=name do
        S.check()
        assert(api.now()-began<180000,'3 分钟没有进入帮会城市')
        S.log('前往帮会城市')
        local here=S.world().scene
        local c=CITIES[here] or {'范纯仁',237,236}
        api.openNpc({name=c[1],x=c[2],y=c[3],scene=CITIES[here] and here or 0});api.sleep(600)
        if not api.selectOption({'进入本帮城市'},true) then api.selectOption({'#{BHCS_090219_07}'},true) end
        api.sleep(600);CloseAllWindow()
        local wait=api.now()
        while S.world().map~=name and api.now()-wait<15000 do api.maintain();api.sleep(500) end
    end
    return S.world().scene
end

-- 情寄虞兮: two players, a seed, a flower that grows where the seed's dialog says, a final talk.
local SEED_SPOTS={{'#{QRYJH_221104_130}',137,40},{'#{QRYJH_221104_131}',121,116},{'#{QRYJH_221104_132}',107,165},{'#{QRYJH_221104_133}',236,125},{'#{QRYJH_221104_134}',108,218}}
function ShortTasks.qingji()
    local S=open('情寄虞兮',tonumber((TaskConfig or {}).short_minutes or 20))
    local api=S.api
    return S.finish(function()
        local SCENE=1075
        local npc={name='许望虞',x=158,y=100,scene=SCENE}
        S.log('找许望虞');api.openNpc(npc);api.sleep(1000)
        if GetTeamCount()>=2 and api.teamTogether() then
            api.sleep(3000);api.selectOption({'#{QRYJH_221104_13}'},true);api.sleep(1000)
        end
        CloseAllWindow()
        local T=DungeonTactics.new(api,SCENE,{})
        local idle=api.now()
        while true do
            S.check()
            assert(S.world().scene==SCENE,'情寄虞兮：离开了场景')
            local bloom,flower
            for _,o in ipairs(T.rows()) do
                if o.name=='盛开的虞美人花' then bloom=o
                elseif o.name:find('的花朵',1,true) then flower=o end
            end
            if bloom then
                S.log('采盛开的花');pcall(api.prepareBattle)
                api.openNpc({name=bloom.name,x=math.floor(bloom.x),y=math.floor(bloom.y),scene=SCENE});api.sleep(1000)
                api.selectOption({'#{QRYJH_221104_135}'},true);api.sleep(1000);CloseAllWindow()
                return {status='done',message='情寄虞兮完成'}
            elseif flower then
                S.log('照料花朵');idle=api.now();pcall(api.prepareBattle)
                local at={name=flower.name,x=math.floor(flower.x),y=math.floor(flower.y),scene=SCENE}
                api.openNpc(at);api.sleep(1000)
                api.selectOption({'#{QRYJH_221104_21}'},true);api.sleep(1000);CloseAllWindow()
                GetLuaValue(string.format("-- short:flower\nDataPool:SelectAsTargetByObjID(%d) local e=MainMenuBar_Env if type(e)=='table' and e.MainMenuBar_Clicked then e.MainMenuBar_Clicked(51) end",flower.server_id),'',0)
                api.sleep(1000);api.openNpc(at);api.sleep(1000)
                api.selectOption({'#{QRYJH_221104_135}'},true);api.sleep(1000);CloseAllWindow()
            elseif GetTeamCount()==0 or api.isLeader() then
                if S.count('痴情种')>0 then
                    S.log('种痴情种');idle=api.now();pcall(api.prepareBattle);api.sleep(1000)
                    assert(S.use('痴情种'),'情寄虞兮：痴情种用不了');api.sleep(4000)
                    local text=S.dialog();CloseAllWindow()
                    for _,spot in ipairs(SEED_SPOTS) do
                        if text:find(spot[1],1,true) then MoveTo(spot[2],spot[3],SCENE);pcall(api.prepareBattle);break end
                    end
                else
                    assert(api.now()-idle<60000,'情寄虞兮：没有痴情种，也没有花朵；任务需要 2 人队伍从许望虞处开始')
                end
            else
                S.log('等待队长');assert(api.now()-idle<600000,'情寄虞兮：队长 10 分钟没有进展')
            end
            api.maintain();api.sleep(1000)
        end
    end)
end

-- 星落九野: pick the ticked herbs by their own gather skills until 21:33.
local XL_SKILLS={['紫微香兰']=4814,['紫微银堇']=4815,['紫微凤尾']=4816}
local XL_MAPS={['林海溪谷']={118,218,152},['忘川花海']={120,76,52},['玄海']={115,136,213},['漠南青原']={119,177,161}}
function ShortTasks.xingluo()
    local cfg=TaskConfig or {}
    local S=open('星落九野',tonumber(cfg.short_minutes or 115))
    local api=S.api
    local want={}
    for name in pairs(XL_SKILLS) do if cfg[name]==true then want[name]=true end end
    if next(want)==nil then error('星落九野：没有勾选采集物品',0) end
    local map=XL_MAPS[tostring(cfg['采集地图'] or '')]
    if not map then error('星落九野：采集地图无效',0) end
    local function over()
        local m=GetLuaValue("-- short:clock\nreturn tonumber(os.date('%H'))*60+tonumber(os.date('%M'))",'n')
        return type(m)=='number' and m>=21*60+33
    end
    return S.finish(function()
        local picked=0
        if over() then return {status='already_done',message='星落九野：当前不在活动时间'} end
        if S.world().scene~=map[1] then S.log('前往采集地图');MoveTo(map[2],map[3],map[1]) end
        local T=DungeonTactics.new(api,map[1],{})
        local tried={}
        while not over() and api.now()<S.deadline do
            S.check()
            local target
            for _,o in ipairs(T.rows()) do
                if want[o.name] and api.now()-(tried[o.id] or -100000)>=30000 and (not target or o.dst<target.dst) then target=o end
            end
            if target then
                if target.dst>=2.4 then S.log('靠近 '..target.name);T.move(math.floor(target.x),math.floor(target.y))
                else
                    S.log('采集 '..target.name);T.stop();pcall(api.prepareBattle);tried[target.id]=api.now()
                    local used,missing=T.useSkill(XL_SKILLS[target.name],target)
                    if missing then error('星落九野：角色没有 '..target.name..' 的采集技能',0) end
                    if used then S.busy(20);S.loot();picked=picked+1 end
                    T.clearMove()
                end
            else
                S.log('等待刷新');T.move(map[2],map[3])
            end
            api.maintain();api.sleep(300)
        end
        return {status='done',message='星落九野结束，本次采集 '..picked..' 次'}
    end)
end

-- 问画朔源: the letter window's buttons, then 卢氏女, then three spots of 碎镜片 in 楼兰 side scene 1075.
local WH_SPOTS={{144,117},{99,196},{182,39}}
function ShortTasks.wenhua()
    local S=open('问画朔源',tonumber((TaskConfig or {}).short_minutes or 30))
    local api=S.api
    local KEY='#{XYYJ_260529_49}'
    local function press(env,fn,ms)
        S.ui(string.format("local e=%s if type(e)=='table' and type(e.%s)=='function' then e.%s() end",env,fn,fn));S.wait(ms)
    end
    local function gift()
        press('QiXi_Guide_2026_Env','QiXi_Guide_2026_HolidayGift_Clicked',1000)
        press('QiXi_HolidayGift_Env','QiXi_HolidayGift_GetClick',500)
    end
    return S.finish(function()
        S.log('打开书信')
        S.ui("local e=PlayerQuicklyEnter_Env if type(e)=='table' and type(e.PlayerQuicklyEnter_Clicked)=='function' then e.PlayerQuicklyEnter_Clicked(91) end");S.wait(1000)
        local L='QiXi_StoryLetter_Env'
        press(L,'QiXi_StoryLetter_Stage1_OpenBtn_OnClick',2000)
        for i=1,3 do press(L,'QiXi_StoryLetter_OpenBtn_'..i..'_OnClick',5000) end
        press(L,'QiXi_StoryLetter_JieMiBtn_OnClick',2000);press(L,'QiXi_StoryLetter_GoBtn_OnClick',1000);press(L,'QiXi_StoryLetter_Close',1000)
        local lu={name='卢氏女',x=254,y=252,scene=0}
        S.log('找卢氏女');api.openNpc(lu);api.sleep(1000)
        api.selectOption({'#{XYYJ_260529_23}'},true);api.sleep(1000);QuestFrameMissionComplete(nil,700);api.sleep(1000);QuestFrameAcceptClicked(2000)
        CloseAllWindow();api.openNpc(lu);api.sleep(1000)
        api.selectOption({'#{GXCJ_260604_03}'},true);api.sleep(1000);CloseAllWindow()
        local def={mission=KEY}
        local seen,elsewhere,passes=false,api.now(),0
        while true do
            S.check()
            local m=api.mission(def)
            local here=S.world().scene
            if not m then
                if not seen and here==0 then
                    CloseAllWindow();api.openNpc(lu);gift();CloseAllWindow()
                    return {status='already_done',message='问画朔源：没有进行中的任务，已尝试领节日礼'}
                end
                gift();CloseAllWindow()
                return {status='done',message='问画朔源完成'}
            end
            seen=true
            if here~=1075 then
                assert(api.now()-elsewhere<60000,'问画朔源：有任务但 60 秒没有进入场景 1075')
            elseif m.status==0 then
                elsewhere=api.now()
                S.log('寻找碎镜片');S.use('溯缘镜的碎片');S.wait(4000);CloseAllWindow()
                local T=DungeonTactics.new(api,1075,{})
                for _,spot in ipairs(WH_SPOTS) do
                    MoveTo(spot[1],spot[2],1075)
                    local began=api.now();local found={}
                    repeat
                        S.wait(500);found={}
                        for _,o in ipairs(T.rows()) do if o.name=='遗失的碎镜片' then found[#found+1]=o end end
                    until #found>0 or api.now()-began>=30000
                    -- An empty spot is normal on a resumed run; three whole passes without finishing is not.
                    for _,o in ipairs(found) do
                        MoveTo(math.floor(o.x),math.floor(o.y),1075);pcall(api.prepareBattle)
                        T.useSkill(6060,o);S.wait(7000)
                    end
                end
                passes=passes+1
                local after=api.mission(def)
                assert(not (after and after.status==0) or passes<3,'问画朔源：三处走了 3 遍任务仍未完成')
            else
                S.log('交任务');api.openNpc({name='卢姑娘',x=213,y=119,scene=1075});api.sleep(1000)
                api.selectOption({KEY},true);api.sleep(1000);QuestFrameMissionComplete(nil,700);api.sleep(1000);CloseAllWindow()
                local began=api.now()
                while api.mission(def) and api.now()-began<math.max(15000,5000) do S.wait(500) end
                assert(not api.mission(def),'问画朔源：交任务后任务还在')
                gift();CloseAllWindow()
                return {status='done',message='问画朔源完成'}
            end
            api.maintain();api.sleep(500)
        end
    end)
end

-- 帮会福利宝箱: open what is on the two sides of the guild city for ten minutes, as the reference does.
function ShortTasks.guildBox()
    local S=open('帮会福利宝箱',15)
    local api=S.api
    return S.finish(function()
        local scene=toGuild(S)
        if not scene then return {status='already_done',message='帮会福利宝箱：没有帮会城市'} end
        local T=DungeonTactics.new(api,scene,{})
        local began,opened,tried,side=api.now(),0,{},1
        local SIDES={{57,137},{145,137}}
        while api.now()-began<600000 do
            S.check()
            if S.world().scene~=scene then return {status='done',message='帮会福利宝箱：已离开帮会城市，打开 '..opened..' 个'} end
            local box
            for _,o in ipairs(T.rows()) do
                if o.name=='福利宝箱' and api.now()-(tried[o.id] or -100000)>=20000 and (not box or o.dst<box.dst) then box=o end
            end
            if box then
                if box.dst>2.4 then S.log('前往宝箱');T.move(math.floor(box.x),math.floor(box.y))
                else
                    S.log('打开宝箱');T.stop();pcall(api.prepareBattle);tried[box.id]=api.now()
                    local used,missing=T.useSkill(4720,box)
                    if missing then error('帮会福利宝箱：角色没有开箱技能',0) end
                    if used then S.busy(5);opened=opened+1 end
                    T.clearMove()
                end
            else
                S.log('寻找宝箱')
                local q=SIDES[side]
                if not T.move(q[1],q[2]) then side=side%2+1;T.clearMove() end
            end
            api.maintain();api.sleep(500)
        end
        return {status='done',message='帮会福利宝箱结束，打开 '..opened..' 个'}
    end)
end

-- 帮会疑踪: the leader blows 青竹短哨 to learn a spot, blows it there, and the team clears 影傀 away from the thunder traps.
local function yzBorder(x,y)
    if y<119 or x>156 or x<51 then return false end
    if x>147 and y>138 then return false end
    if x>122 and x<137 and y<125 then return false end
    if x<63 and y<129 then return false end
    if x<63 and y>140 and y<146 then return false end
    return true
end
function ShortTasks.yizong()
    local cfg=TaskConfig or {}
    local S=open('帮会疑踪',tonumber(cfg.short_minutes or 60))
    local api=S.api
    assert(cfg.guild_change_leader==nil or type(cfg.guild_change_leader)=='boolean','帮会疑踪开关无效')
    local school=math.floor(api.school())
    local melee=school==0 or school==1 or school==2 or school==7 or school==9 or school==10
    return S.finish(function()
        local scene=toGuild(S)
        if not scene then return {status='already_done',message='帮会疑踪：没有帮会城市'} end
        local T=DungeonTactics.new(api,scene,{})
        local fought,lastMob,kills,handed,seen=false,-100000,0,false,{}
        local function whistle()
            local before=#api.messages()
            pcall(api.prepareBattle);S.use('青竹短哨');api.sleep(600);pcall(api.confirmBox);api.sleep(800)
            local lines=api.messages()
            for i=#lines,math.max(before+1,1),-1 do
                if lines[i]:find('BPSL_Boss_210716_26',1,true) then
                    local x,y=lines[i]:match('BPSL_Boss_210716_26.-(%d+).-(%d+)}')
                    if x and y then return tonumber(x),tonumber(y) end
                end
            end
        end
        while true do
            S.check()
            assert(S.world().scene==scene,'帮会疑踪：离开了帮会城市')
            local mob
            for _,o in ipairs(T.rows()) do
                if o.name=='影傀' and T.enemy(o) then
                    if not mob or o.dst<mob.dst then mob=o end
                    seen[o.id]=true
                elseif o.name=='影傀' and seen[o.id] and o.hp==0 then seen[o.id]=nil;kills=kills+1 end
            end
            if mob then
                lastMob=api.now();fought=true
                local traps=T.traps()
                if T.escape(traps,5,mob.x,mob.y,15,3,yzBorder) then S.log('躲神雷陷阱');T.stop()
                elseif #traps==0 or not melee then
                    S.log('打影傀')
                    if mob.dst>5 and #traps==0 then T.stop();T.move(math.floor(mob.x),math.floor(mob.y)) else T.attack(mob) end
                else T.stop() end
            elseif api.now()-lastMob<10000 then
                S.log('等待捡包');T.stop();api.pickup()
                if S.world().scene~=scene then return {status='done',message='帮会疑踪：已离开帮会城市'} end
            elseif GetTeamCount()==0 or api.isLeader() then
                T.stop()
                if S.count('青竹短哨')>0 then
                    S.log('吹青竹短哨')
                    local x,y=whistle()
                    if x then MoveTo(x,y,scene);whistle();S.busy(5) end
                else
                    local n=GetTeamCount()
                    if n>1 and not handed and cfg.guild_change_leader==true then
                        S.log('短哨用完，交队长');S.ui(string.format('Player:AppointLeader(%d)',n-1));handed=true;api.sleep(1000)
                    else
                        return {status=fought and 'done' or 'already_done',message='帮会疑踪结束：青竹短哨用完'..(fought and '' or '，没有打到影傀')}
                    end
                end
            else
                S.log('跟随队长');T.stop()
                local id=DungeonTactics.leaderId()
                local p=S.world()
                for _,o in ipairs(T.players()) do
                    if o.id==id and (p.x-o.x)^2+(p.y-o.y)^2>16 then T.move(math.floor(o.x),math.floor(o.y));break end
                end
                if api.now()>=S.deadline-1000 then return {status=fought and 'done' or 'already_done',message='帮会疑踪：运行时间到'} end
            end
            api.maintain();api.sleep(500)
        end
    end)
end

-- 神兵阁: 武强盛 sends the player in; clear around the set point until the time is up or the game sends them out, then walk out.
local function shenbing(label,xKey,yKey,zoneOption,extraPrompts)
    local cfg=TaskConfig or {}
    local S=open(label,tonumber(cfg.short_minutes or 30))
    local api=S.api
    local function inside() return S.world().map:find('神兵',1,true)~=nil end
    local keys={'SBG_140512_69','SBG_140512_66'};for _,k in ipairs(extraPrompts) do keys[#keys+1]=k end
    local fired=DungeonTactics.prompts(api,keys)
    return S.finish(function()
        local px,py=tonumber(cfg[xKey] or 0) or 0,tonumber(cfg[yKey] or 0) or 0
        if not inside() then
            local scene=toGuild(S)
            if not scene then return {status='already_done',message=label..'：没有帮会城市'} end
            S.log('找武强盛');api.openNpc({name='武强盛',x=130,y=126,scene=scene});api.sleep(500)
            local T=DungeonTactics.new(api,scene,{})
            if T.hasBuff(api.buffs(),'进入神兵阁') then
                api.selectOption({'#{SBG_140512_06}'},true);api.sleep(1000);api.selectOption({zoneOption},true);api.sleep(800)
            else
                api.selectOption({'#{SBG_140512_05}'},true);api.sleep(1000);api.selectOption({'#{SBG_140512_60}'},true);api.sleep(1000)
                if fired('SBG_140512_69') then CloseAllWindow();return {status='already_done',message=label..'：今日已经参加过'} end
                if fired('SBG_140512_66') then CloseAllWindow();return {status='already_done',message=label..'：帮会未开启神兵阁'} end
                for _,k in ipairs(extraPrompts) do if fired(k) then CloseAllWindow();return {status='already_done',message=label..'：现在不是开放时间'} end end
                api.selectOption({zoneOption},true);api.sleep(800)
            end
            CloseAllWindow()
            local began=api.now()
            while not inside() do
                S.check();assert(api.now()-began<60000,label..'：选择后 60 秒没有进入神兵阁，未重复发送')
                api.maintain();api.sleep(500)
            end
        end
        local scene=S.world().scene
        local T=DungeonTactics.new(api,scene,{})
        local kills,hps,lastLoot,last=0,{},-100000,api.now()
        pcall(api.prepareBattle)
        while api.now()<S.deadline-10000 and S.world().scene==scene do
            S.check()
            assert(api.now()-last<300000,label..'：5 分钟没有打到怪')
            local mob
            for _,o in ipairs(T.rows()) do
                if T.enemy(o) then
                    if not mob or o.dst<mob.dst then mob=o end
                    if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;last=api.now() end
                end
            end
            if mob then S.log('刷怪');T.attack(mob)
            else
                T.stop()
                if api.now()-lastLoot>=3000 then lastLoot=api.now();api.pickup() end
                if S.world().scene~=scene then break end
                if px>0 and py>0 then T.move(px,py) end
            end
            api.maintain();api.sleep(250)
        end
        T=nil
        local left=api.now()
        while inside() do
            S.log('离开神兵阁')
            assert(api.now()-left<60000,label..'：走到出口后仍在神兵阁')
            local here=S.world().scene
            DungeonTactics.new(api,here,{}).move(165,253);api.maintain();api.sleep(3000)
        end
        return {status='done',message=label..'结束'}
    end)
end
function ShortTasks.shenbing() return shenbing('帮会神兵阁刷怪','bjk146','bjk147','#{SBG_140512_45}',{}) end
function ShortTasks.wuxiang() return shenbing('刷怪无相神兵阁','bjk181','bjk182','#{SBG_250811_02}',{'SBG_140512_68'}) end

-- 真元凝元: refine at 张士心 while fragments and bag room last. 淬解 destroys what it breaks down and is not ported.
function ShortTasks.zhenyuan()
    local cfg=TaskConfig or {}
    local S=open('真元凝元',tonumber(cfg.short_minutes or 30))
    local api=S.api
    return S.finish(function()
        if cfg.allow_item~=true then error('真元凝元：会消耗真元碎片，未打开“允许物品处理”，已停止',0) end
        local npc={name='张士心',x=349,y=229,scene=1}
        S.log('找张士心');MoveTo(npc.x,npc.y,npc.scene)
        local T=DungeonTactics.new(api,npc.scene,{})
        local done,same,lastChip=0,0,nil
        while true do
            S.check()
            local target
            for _,o in ipairs(T.rows()) do if o.name==npc.name then target=o end end
            if not target or target.dst>3 then
                assert(same<5,'真元凝元：走不到张士心身边')
                same=same+1;MoveTo(npc.x,npc.y,npc.scene)
            else
                local state,chip=GetLuaValue(string.format([[-- short:refine
                    local chip=Pneuma:GetPneumaChip()
                    if chip<20 then return 0,chip end
                    if Pneuma:GetSmeltBag_SpaceCount()<=0 then return 2,chip end
                    Clear_XSCRIPT() Set_XSCRIPT_Function_Name('ApplyNiangLian') Set_XSCRIPT_ScriptID(889902) Set_XSCRIPT_Parameter(0,%d) Set_XSCRIPT_ParamCount(1) Send_XSCRIPT()
                    return 1,chip]],target.id),'nn')
                if state==0 then return {status=done>0 and 'done' or 'already_done',message='真元凝元结束：碎片不足 20，本次凝元 '..done..' 次'} end
                if state==2 then return {status=done>0 and 'done' or 'already_done',message='真元凝元结束：真元栏已满，请自己处理后再运行，本次凝元 '..done..' 次'} end
                if lastChip==chip then
                    same=same+1;assert(same<8,'真元凝元：提交后碎片没有减少，不再重复')
                else same=0;if lastChip then done=done+1 end end
                lastChip=chip
            end
            api.maintain();api.sleep(500)
        end
    end)
end

-- 购买元丹坊: limited stock by name from the shop's own pages. The hook and buy functions are the reference's own text.
local function YDF_LoadFunction()
  GetLuaValue([[-- short:ydf-load

            if dmpHook_PetNeidan_Shop_OnEvent == nil then
                dm_g_PetNeidan_Shop_CurWeek = 0
                dm_g_PetNeidan_Shop_ServerObj = 0
                dmpHook_PetNeidan_Shop_OnEvent = PetNeidan_Shop_OnEvent
                function PetNeidan_Shop_OnEvent(event)
                    if event == "NEIDAN_SHOP_UPDATE" and arg0 == "show" then
                        if arg1 and arg2 then
                            dm_g_PetNeidan_Shop_CurWeek = tonumber(arg1)
                            if tonumber(arg2) > 0 then
                                dm_g_PetNeidan_Shop_ServerObj = tonumber(arg2)
                            end
                        end
                    end
                    dmpHook_PetNeidan_Shop_OnEvent(event)
                end
            end
        ]])
  GetLuaValue("-- short:ydf-load\n        function dmYDF_BuySP(ID, num, curWeek, serverObj)\n            Clear_XSCRIPT()\n            Set_XSCRIPT_Function_Name(\"OnClientBuyItem\")\n            Set_XSCRIPT_ScriptID(505111)\n            Set_XSCRIPT_Parameter(0, ID)\n            Set_XSCRIPT_Parameter(1, num)\n            Set_XSCRIPT_Parameter(2, curWeek)\n            Set_XSCRIPT_Parameter(3, serverObj)\n            Set_XSCRIPT_ParamCount(4)\n            Send_XSCRIPT()\n        end\n        \n        function dmYDF_BuyItem(pageName1, pageName2, name, curWeek, serverObj)\n            local jpCount = LuaFnGetDanqiCount(\"blue\")\n            local zpCount = LuaFnGetDanqiCount(\"purple\")\n            local spCount = LuaFnGetDanqiCount(\"orange\")\n            local jbCount = Player:GetData(\"MONEY\")\n            local ybCount = Player:GetData(\"YUANBAO\")\n        \n            local count = Lua_GetNeiDanShop_ItemsTotalCount(pageName1, pageName2)\n            local items = Lua_GetNeiDanShopData(pageName1, pageName2, 1, count)\n            if type(items) ~= \"table\" then\n                return 0, 8\n            end\n            local item_count = table.getn(items)\n            for i = 1, item_count do\n                if name == DataPool:Lua_GetItemNameByIndex(items[i].itemid) then\n                    local itemId = items[i].itemid\n                    local ID = items[i].ID\n                    local itemNum = items[i].num\n                    local price = items[i].price\n                    local huobi = items[i].huobi\n                    local zhekou = items[i].zhekou -- 折扣\n        \n                    if items[i].leftnum == 0 then\n                        return 0, 3 -- 该商品已售罄，购买失败。 -1不限购\n                    end\n        \n                    if items[i].leftnum == -1 then\n                        return 0, 4 -- 不购买非限购商品\n                    end\n        \n                    local num = Lua_GetNeiDanShop_MaxNumCanBuy(itemId, itemNum)\n                    if num <= 0 then\n                        return 0, 5 -- 计算空间后的最大购买组数（有空间不足的提示）\n                    end\n        \n                    if zhekou > 0 then\n                        price = math.floor(price * zhekou * 0.01)\n                    end\n        \n                    local isBuy = false\n                    if huobi == 1 then\n                        if jpCount >= price then\n                            isBuy = true\n                        end\n                    elseif huobi == 2 then\n                        if zpCount >= price then\n                            isBuy = true\n                        end\n                    elseif huobi == 3 then\n                        if spCount >= price then\n                            isBuy = true\n                        end\n                    elseif huobi == 4 then\n                        if ybCount >= price then\n                            isBuy = true\n                        end\n                    elseif huobi == 5 then\n                        if jbCount >= price then\n                            isBuy = true\n                        end\n                    end\n                    if isBuy then\n                        dmYDF_BuySP(ID, 1, curWeek, serverObj)\n                        return 1, 0\n                    else\n                        return 0, 6\n                    end\n                    break\n                end\n            end\n            return 0, 7\n        end\n        \n        function dmYDF_Buy(aItemName, shopType, aNpcID)\n            local pageName1 = \"\"\n            local pageName2 = \"\"\n            if not dm_g_PetNeidan_Shop_CurWeek or dm_g_PetNeidan_Shop_CurWeek == 0 then\n                return 0, 1\n            end\n            if not dm_g_PetNeidan_Shop_ServerObj or dm_g_PetNeidan_Shop_ServerObj == 0 then\n                return 0, 2\n            end\n        \n            local curWeek = dm_g_PetNeidan_Shop_CurWeek\n            local serverObj = dm_g_PetNeidan_Shop_ServerObj\n            if shopType == 1 then\n                pageName1 = \"灵元锦库\"\n                pageName2 = \"灵元什物\"\n                return dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj)\n            elseif shopType == 2 then\n                pageName1 = \"增益元丹\"\n                pageName2 = \"精品\"\n                if dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj) == 1 then\n                    return 1, 0\n                end\n                pageName2 = \"珍品\"\n                if dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj) == 1 then\n                    return 1, 0\n                end\n                pageName2 = \"神品\"\n                return dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj)\n            elseif shopType == 3 then\n                pageName1 = \"护体元丹\"\n                pageName2 = \"精品\"\n                if dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj) == 1 then\n                    return 1, 0\n                end\n                pageName2 = \"珍品\"\n                if dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj) == 1 then\n                    return 1, 0\n                end\n                pageName2 = \"神品\"\n                return dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj)\n            elseif shopType == 4 then\n                pageName1 = \"制胜元丹\"\n                pageName2 = \"精品\"\n                if dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj) == 1 then\n                    return 1, 0\n                end\n                pageName2 = \"珍品\"\n                if dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj) == 1 then\n                    return 1, 0\n                end\n                pageName2 = \"神品\"\n                return dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj)\n            elseif shopType == 5 then\n                pageName1 = \"灵元锦库\"\n                pageName2 = \"灵元锦物\"\n                return dmYDF_BuyItem(pageName1, pageName2, aItemName, curWeek, serverObj)\n            end\n            return 0, -1\n        end\n        \n    ")
end
function ShortTasks.yuandan()
    local cfg=TaskConfig or {}
    local S=open('元丹坊',tonumber(cfg.short_minutes or 10))
    local api=S.api
    local function names(text)
        local out={};for w in (tostring(text or ''):gsub('，',' '):gsub(',',' ')):gmatch('%S+') do out[#out+1]=w end
        return out
    end
    local lists={{names(cfg.bjk58),5,'灵元锦物'},{names(cfg.bjk90),1,'灵元什物'},{names(cfg.bjk103),2,'增益元丹'},{names(cfg.bjk152),3,'护体元丹'},{names(cfg.bjk153),4,'制胜元丹'}}
    local total=0;for _,l in ipairs(lists) do total=total+#l[1] end
    return S.finish(function()
        if total==0 then error('元丹坊：没有填写要买的物品',0) end
        if cfg.allow_spend~=true then error('元丹坊：会花钱，未打开“允许支付”，已停止',0) end
        CloseAllWindow();YDF_LoadFunction()
        S.log('找云丹丹');api.openNpc({name='云丹丹',x=178,y=231,scene=1});api.sleep(500)
        assert(api.selectOption({'元丹坊'},true),'元丹坊：云丹丹没有元丹坊选项');api.sleep(1000)
        local bought,skipped=0,{}
        for _,l in ipairs(lists) do
            for _,item in ipairs(l[1]) do
                local tries=0
                while true do
                    S.check();tries=tries+1
                    assert(tries<=100,'元丹坊：'..item..' 连续买了 100 次仍在买')
                    local r,sub=GetLuaValue(string.format('-- short:ydf-buy\nreturn dmYDF_Buy(%q,%d,-1)',item,l[2]),'nn')
                    if r~=1 then
                        if sub==1 or sub==2 then error('元丹坊：没有拿到商店的周次数据，购买接口要实测',0) end
                        skipped[#skipped+1]=item..'('..tostring(sub)..')';break
                    end
                    bought=bought+1;api.sleep(800)
                end
            end
        end
        CloseAllWindow()
        return {status=bought>0 and 'done' or 'already_done',message='元丹坊结束，买了 '..bought..' 次'..(#skipped>0 and '；结束项及原因：'..table.concat(skipped,' ') or '')}
    end)
end
