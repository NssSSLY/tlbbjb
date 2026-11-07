-- Daily tasks, written from the reference rules (原脚本源码/Script64: 活动/清泉茗茶-*, 任务/除恶天劫楼, 任务/临危悟道, 任务/剑纵群雄, 日常/杯酒尽江湖).
-- They own their stages and receipts and do not load the vendor framework. docs/DAILY_TASKS_HANDOFF.md names the differences.
LoadScript('short_tasks')
DailyTasks={}
local open=ShortTasks.open
local function useQuest(name)
    return GetLuaValue(string.format([[-- daily:use-quest
        local want=%q
        for i=0,DataPool:GetTaskBag_Num()-1 do local a=PlayerPackage:EnumItem('quest',i)
            if a and a:GetID()~=0 and a:GetName()==want then PlayerPackage:UseItem(200+i) return 1 end end
        return 0]],name),'n')==1
end

-- 清泉茗茶: one of four teas a day. Each mission picks leaves at one spot, then uses 竹筒 at another; only the offered tea differs between the four tasks.
local TEA_MISSIONS={[1288]={'龙井',90,194,30,104,66},[1289]={'碧螺春',185,219,4,154,223},[1290]={'普洱',146,207,6,161,229},[1291]={'竹叶青',84,235,7,98,248}}
local TEA_BUFFS={'：变身为龙井茶','：变身为普洱茶','：变身为碧螺春','：变身为竹叶青'}
local TEA_ITEMS={'龙井茶','普洱茶','碧螺春茶','竹叶青茶'}
local function teaMission()
    local slot,id,status,var1,script=GetLuaValue([[-- daily:tea-mission
        for i=0,19 do
            if DataPool:GetPlayerMission_InUse(i)==1 then
                local n=tonumber((string.gsub(DataPool:GetPlayerMission_Name(i) or '','Mission:','')))
                if n==1288 or n==1289 or n==1290 or n==1291 then
                    return i,n,DataPool:GetPlayerMission_Variable(i,0),DataPool:GetPlayerMission_Variable(i,1),DataPool:GetPlayerMission_Display(i,7)
                end
            end
        end
        return -1,-1,-1,-1,-1]],'nnnnn')
    if type(slot)~='number' or slot<0 then return nil end
    return {slot=slot,id=math.floor(id),status=math.floor(status),var1=math.floor(var1),script=script}
end
local function tea(label,offer)
    local cfg=TaskConfig or {}
    local S=open(label,tonumber(cfg.short_minutes or 40),label)
    local api=S.api
    local NPC={name='陆屿',x=296,y=188,scene=1}
    assert(cfg.quest_abandon==nil or type(cfg.quest_abandon)=='boolean','清泉茗茶开关无效')
    assert(cfg.tea_drink==nil or type(cfg.tea_drink)=='boolean','清泉茗茶开关无效')
    local function drink()
        local fired=DungeonTactics.prompts(api,{'QQMC_120522_112','QQMC_120522_118'})
        local T=DungeonTactics.new(api,S.world().scene,{})
        local function myTea() local own=api.buffs();for _,b in ipairs(TEA_BUFFS) do if T.hasBuff(own,b) then return b end end end
        local began=api.now()
        S.log('喝茶')
        while api.now()-began<300000 do
            S.check()
            if fired('QQMC_120522_112') or fired('QQMC_120522_118') then return '喝茶完成' end
            if not myTea() then
                local item
                for _,n in ipairs(TEA_ITEMS) do if S.count(n)>0 then item=n;break end end
                if not item then return '没有喝茶道具' end
                S.use(item);S.wait(1000)
            elseif GetTeamCount()>=2 then
                api.openNpc(NPC);api.sleep(800)
                api.selectOption({'#{QQMC_120522_04}'},true);api.sleep(800);api.selectOption({'#{QQMC_120522_71}'},true);api.sleep(800);CloseAllWindow()
                S.wait(3000)
            else return '身上有茶，但没有队伍；要自己组 4 种不同茶的队伍' end
            T=DungeonTactics.new(api,S.world().scene,{})
        end
        return '等 5 分钟没有喝茶结果'
    end
    return S.finish(function()
        local handed,same,sig=0,0,nil
        local msg=''
        while true do
            S.check()
            local m=teaMission()
            local now=m and (m.id..':'..m.status..':'..m.var1) or 'none'
            if now==sig then same=same+1 else sig,same=now,0 end
            assert(same<12,label..'：同一步做了 12 次没有变化，不再重复')
            if m and m.status==0 then
                local info=assert(TEA_MISSIONS[m.id],'清泉茗茶：未知任务 '..tostring(m.id))
                if m.var1~=1 then
                    S.log('采 '..info[1])
                    if S.state()~=5 then
                        MoveTo(info[2],info[3],info[4]);pcall(api.prepareBattle)
                        local T=DungeonTactics.new(api,info[4],{})
                        local leaf
                        for _,o in ipairs(T.rows()) do if o.name==info[1] and not T.enemy(o) and (not leaf or o.dst<leaf.dst) then leaf=o end end
                        if leaf then T.useSkill(3677,leaf);api.sleep(500) end
                    end
                else
                    S.log('用竹筒');MoveTo(info[5],info[6],info[4]);pcall(api.prepareBattle)
                    assert(useQuest('竹筒'),'清泉茗茶：任务栏没有竹筒');S.busy(5)
                end
            elseif m and m.status==1 then
                S.log('交任务');api.openNpc(NPC);api.sleep(500)
                api.selectOption({'#{QQMC_120522_03}'},true);api.sleep(600);QuestFrameMissionComplete(nil,600);CloseAllWindow()
                local after=teaMission()
                if not after or after.status~=1 then handed=handed+1 end
            elseif m and m.status==2 then
                if cfg.quest_abandon~=true then error(label..'：任务已失败，未打开“允许放弃任务”，已停止',0) end
                GetLuaValue(string.format('-- daily:abandon\nQuestFrameMissionAbnegate(%d)',m.script),'',0);api.sleep(1000)
            else
                S.log('接任务');api.openNpc(NPC);api.sleep(500)
                api.selectOption({'#{QQMC_120522_03}'},true);api.sleep(1100)
                local first=S.dialog()
                api.selectOption({offer},true);api.sleep(600)
                local text=S.dialog();CloseAllWindow()
                if text:find('#{QQMC_120522_09}',1,true) or first:find('#{QQMC_120522_09}',1,true) then
                    if cfg.tea_drink==true then msg='；'..drink() end
                    return {status=handed>0 and 'done' or 'already_done',message=label..'今日任务已做完；本次交 '..handed..' 次'..msg}
                end
            end
            api.maintain();api.sleep(300)
        end
    end)
end
function DailyTasks.teaBiluo() return tea('清泉茗茶·碧螺春','#{QQMC_220526_18}') end
function DailyTasks.teaLongjing() return tea('清泉茗茶·龙井','#{QQMC_220526_17}') end
function DailyTasks.teaPuer() return tea('清泉茗茶·普洱','#{QQMC_220526_19}') end
function DailyTasks.teaZhuye() return tea('清泉茗茶·竹叶青','#{QQMC_220526_20}') end

-- 除恶天劫楼: floors 272–279. 付劫生 in the tower gives each floor's mission and sends the player up; the day ends when he says so.
function DailyTasks.tianjie()
    local cfg=TaskConfig or {}
    local S=open('除恶天劫楼',tonumber(cfg.short_minutes or 60))
    local api=S.api
    local KEY='除恶天劫楼'
    local function floor_() local s=S.world().scene;if s>=272 and s<=279 then return s end end
    local def={mission=KEY}
    return S.finish(function()
        local handed,refused=0,0
        local outsideSince=api.now()
        while true do
            S.check()
            local scene=floor_()
            if not scene then
                assert(api.now()-outsideSince<120000,'除恶天劫楼：2 分钟没有进入天劫楼')
                S.log('进入天劫楼');api.openNpc({name='付劫生',x=94,y=201,scene=2});api.sleep(500)
                api.selectOption({'#{TJL_xml_XX(02)}'},true);api.sleep(1500);CloseAllWindow();S.wait(1000)
            else
                outsideSince=api.now()
                local m=api.mission(def)
                local npc={name='付劫生',x=73,y=79,scene=scene}
                if not m then
                    S.log('接任务');api.openNpc(npc)
                    if api.selectOption({'#{TJL_xml_XX(01)}'},true) then
                        api.sleep(1000)
                        if S.dialog():find('#{TJL_090714_02}',1,true) then CloseAllWindow();break end
                        QuestFrameAcceptClicked(500)
                    end
                    CloseAllWindow()
                    S.wait(1000)
                    if not api.mission(def) then refused=refused+1;assert(refused<4,'除恶天劫楼：接任务 3 次没有结果') else refused=0 end
                elseif m.status==1 then
                    S.log('交任务');api.openNpc(npc)
                    api.selectOption({'#{TJL_xml_XX(01)}'},true);api.sleep(500);QuestFrameMissionComplete(nil,500)
                    api.selectOption({'#{TJL_xml_XX(04)}'},true);api.sleep(500);QuestFrameAcceptClicked(500);CloseAllWindow()
                    S.wait(1000)
                    local after=api.mission(def)
                    if not after or after.status~=1 then handed=handed+1 else refused=refused+1;assert(refused<4,'除恶天劫楼：交任务 3 次没有变化') end
                else
                    S.log('清第 '..math.floor(scene-271)..' 层')
                    pcall(api.prepareBattle)
                    local T=DungeonTactics.new(api,scene,{})
                    local last,hps=api.now(),{}
                    while floor_()==scene do
                        S.check()
                        local c=api.mission(def)
                        if not c or c.status==1 then break end
                        assert(api.now()-last<180000,'除恶天劫楼：3 分钟没有进展')
                        local mob
                        for _,o in ipairs(T.rows()) do
                            if T.enemy(o) then
                                if not mob or o.dst<mob.dst then mob=o end
                                if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;last=api.now() end
                            end
                        end
                        if mob then T.attack(mob) else T.stop();T.move(78,55) end
                        api.maintain();api.sleep(250)
                    end
                    if floor_()==scene then T.stop() end
                end
            end
            api.maintain();api.sleep(300)
        end
        local left=api.now()
        while floor_() do
            S.log('离开天劫楼')
            assert(api.now()-left<60000,'除恶天劫楼：走到出口后仍在天劫楼')
            DungeonTactics.new(api,S.world().scene,{}).move(82,80);api.maintain();api.sleep(1000)
        end
        return {status=handed>0 and 'done' or 'already_done',message='除恶天劫楼今日已做完；本次交 '..handed..' 层'}
    end)
end

-- 临危悟道: a fixed guide chain, one way through. Each step clicks what is offered, as the reference does; the receipt is the chain's missions being gone at the end.
local LW_CHAIN={'#{KDJYD_250814_14}','#{KDJYD_250814_53}','#{KDJYD_250814_91}','#{KDJYD_250814_115}','#{KDJYD_250814_152}','#{KDJYD_250814_169}'}
function DailyTasks.linwei()
    local cfg=TaskConfig or {}
    local S=open('临危悟道',tonumber(cfg.short_minutes or 30))
    local api=S.api
    assert(cfg.linwei_xiulian==nil or type(cfg.linwei_xiulian)=='boolean','临危悟道开关无效')
    local XIAO={name='萧峰',x=100,y=102,scene=2}
    local YAO={name='姚楚娥',x=214,y=141,scene=2}
    local SAO={name='扫地神僧',x=242,y=31,scene=2}
    local CHEN={name='陈记',x=361,y=249,scene=1}
    local function say(npc,keys,finish,accept)
        S.check();CloseAllWindow();api.openNpc(npc);api.sleep(1000)
        for _,k in ipairs(keys) do api.selectOption({k},true);S.wait(1000) end
        if finish then QuestFrameMissionComplete(nil,700);S.wait(1000) end
        if accept then QuestFrameAcceptClicked(2000) end
    end
    local function press(code) S.ui(code);S.wait(1000) end
    local function anyLeft() for _,k in ipairs(LW_CHAIN) do if api.mission({mission=k}) then return k end end end
    return S.finish(function()
        CloseAllWindow();api.openNpc(XIAO);api.sleep(1000)
        local offered=api.selectOption({'#{KDJYD_250814_14}'},true)
        if not offered and not anyLeft() then CloseAllWindow();return {status='already_done',message='临危悟道：萧峰没有这个任务，也没有进行中的步骤'} end
        api.sleep(700);QuestFrameAcceptClicked(2000);CloseAllWindow()
        S.log('萧峰：第一段')
        say(XIAO,{'#{KDJYD_250814_14}','#{KDJYD_250814_18}','#{KDJYD_250814_37}','#{KDJYD_250814_39}','#{KDJYD_250814_41}'},true,true)
        pcall(api.prepareBattle);S.wait(1000)
        api.selectOption({'#{KDJYD_250814_53}'},true);S.wait(1000);api.selectOption({'#{KDJYD_250814_57}'},true);S.wait(1000)
        S.ui("local e=MessageBox_Self2_Env if type(e)=='table' and e.MessageBox_Self2_Ok_Clicked then e.MessageBox_Self2_Ok_Clicked() end");S.wait(10000)
        say(XIAO,{'#{KDJYD_250814_53}'},true,true)
        S.log('姚楚娥');say(YAO,{'#{KDJYD_250814_91}','#{KDJYD_250814_102}'})
        for _=1,5 do S.ui("local e=Expansion_Grade_Yindao_Env if type(e)=='table' and e.Expansion_Grade_Yindao_Page_Right then e.Expansion_Grade_Yindao_Page_Right() end") end
        say(YAO,{'#{KDJYD_250814_91}'},true,true)
        S.log('北辽宝印');pcall(api.prepareBattle);S.wait(1000)
        S.use('北辽宝印');S.wait(4000);S.use('北辽宝印');S.wait(4000)
        local x,y,scene=S.dialog():match('%*[%c]*(%d+)%*[%c]*(%d+)%*[%c]*(%d+)')
        CloseAllWindow()
        if x then
            x,y,scene=tonumber(x),tonumber(y),tonumber(scene)
            MoveTo(x,y,scene);pcall(api.prepareBattle);useQuest('北辽宝印');S.wait(3000)
            local T=DungeonTactics.new(api,scene,{})
            local began=api.now();local any=true
            while any and api.now()-began<120000 do
                S.check();any=false
                for _,o in ipairs(T.rows()) do
                    if T.enemy(o) and o.name:find('伪装的',1,true) then T.attack(o);any=true;break end
                end
                api.maintain();api.sleep(250)
            end
            T.stop();S.wait(10000)
        else
            local key=api.mission({mission='#{KDJYD_250814_115}'})
            assert(not key or key.status==1,'临危悟道：北辽宝印没有给出坐标')
        end
        say(XIAO,{'#{KDJYD_250814_115}'},true,true)
        if cfg.linwei_xiulian~=true then error('临危悟道：下一步要提升修炼，未打开“允许提升修炼”，已停止；前面的步骤已做完',0) end
        S.log('扫地神僧');say(SAO,{'#{XL_XML_36}'})
        press("local e=XiulianStudy_Env if type(e)=='table' then e.XiulianStudy_Skill_Clicked(1) end");press("local e=XiulianStudy_Env if type(e)=='table' then e.XiulianStudy_UpJingJie_Clicked() end")
        say(SAO,{'#{XL_XML_35}'})
        press("local e=XiulianStudy_Env if type(e)=='table' then e.XiulianStudy_Skill_Clicked(1) end");press("local e=XiulianStudy_Env if type(e)=='table' then e.XiulianStudy_UpLevel_Clicked() end")
        S.ui("local e=MessageBox_Self_Env if type(e)=='table' and e.MessageBox_Self_Cancel_Clicked then e.MessageBox_Self_Cancel_Clicked(0) end")
        say(XIAO,{'#{KDJYD_250814_152}'},true,true)
        if cfg.allow_item~=true then error('临危悟道：最后一步要用神品龙渊玄铁强化重楼肩，未打开“允许物品处理”，已停止；前面的步骤已做完',0) end
        if S.count('重楼肩')==0 or S.count('神品龙渊玄铁')==0 then error('临危悟道：背包里没有重楼肩或神品龙渊玄铁，已停止',0) end
        S.log('陈记');say(CHEN,{'#{SZJJ_250801_05}'});pcall(api.prepareBattle)
        S.use('重楼肩');S.wait(1200);S.use('神品龙渊玄铁');S.wait(1200)
        press("local e=EquipEducation_Upstage_Env if type(e)=='table' then e.EquipEducation_Upstage_OKClicked() end")
        press("local e=EquipEducation_Upstage_Env if type(e)=='table' then e.EquipEducation_Upstage_AttrChangedClicked() end")
        say(CHEN,{'#{KDJYD_250814_169}'},true);CloseAllWindow()
        local left=anyLeft()
        if left then error('临危悟道：走完后任务还在：'..left,0) end
        return {status='done',message='临危悟道引导完成'}
    end)
end

-- 剑纵群雄: climb the sect tower. The game tells the next floor's NPC through its own panel event, which is hooked as the reference does.
local ZM_HOOK=[[-- daily:zm-level
    if not __tlbbZm then
        local e=ZongMenPata_Env
        local t=(type(e)=='table' and type(e.ZongMenPata_OnEvent)=='function') and e or _G
        local old=t.ZongMenPata_OnEvent
        if type(old)~='function' then return -2,-2 end
        __tlbbZm={level=-1,zm=-1}
        t.ZongMenPata_OnEvent=function(event)
            if event=='UI_COMMAND' and tonumber(arg0)==998633006 then
                __tlbbZm.level=Get_XParam_INT(0)
                __tlbbZm.zm=Get_XParam_INT(1)
            end
            old(event)
        end
    end
    return __tlbbZm.level,__tlbbZm.zm]]
function DailyTasks.jianzong()
    local cfg=TaskConfig or {}
    local S=open('剑纵群雄',tonumber(cfg.short_minutes or 60))
    local api=S.api
    assert(cfg.quest_leave_team==nil or type(cfg.quest_leave_team)=='boolean','剑纵群雄开关无效')
    local function solo()
        if GetTeamCount()==0 then return end
        if cfg.quest_leave_team~=true then error('剑纵群雄：要单人进行，未打开“允许自动退队”，已停止',0) end
        S.ui("if Player:IsInTeam()==1 then Player:LeaveTeam() end");api.sleep(1000)
    end
    local function inside() local s=S.world().scene;return s==897 or s==898 or s==899 end
    local function level()
        GetLuaValue(ZM_HOOK,'nn',2)
        S.ui("local e=ZongMenSkill_Env if type(e)=='table' and e.ZongMenSkill_OpenPaTa then e.ZongMenSkill_OpenPaTa() end");S.wait(1000)
        local n=GetLuaValue(ZM_HOOK,'nn',2)
        CloseAllWindow()
        if n==-2 then error('剑纵群雄：游戏没有宗门塔界面函数，读不到关数',0) end
        return tonumber(n) or -1
    end
    return S.finish(function()
        local cleared,floorsTried=0,{}
        while true do
            S.check()
            if inside() then
                local scene=S.world().scene
                local T=DungeonTactics.new(api,scene,{})
                local last,hps,talked=api.now(),{},{}
                S.log('闯关');pcall(api.prepareBattle)
                while S.world().scene==scene do
                    S.check()
                    assert(api.now()-last<180000,'剑纵群雄：关内 3 分钟没有进展')
                    local mob,friend
                    for _,o in ipairs(T.rows()) do
                        if T.enemy(o) then
                            if not mob or o.hp<mob.hp then mob=o end
                            if not hps[o.id] or o.hp<hps[o.id] then hps[o.id]=o.hp;last=api.now() end
                        elseif o.hp>0 and api.now()-(talked[o.id] or -100000)>=5000 and not friend then friend=o end
                    end
                    if mob then T.attack(mob)
                    else
                        T.stop()
                        if friend then
                            -- 考核人's title is not readable: ask whoever is there and let the options decide.
                            talked[friend.id]=api.now();S.log('找考核人');solo()
                            api.openNpc({name=friend.name,x=math.floor(friend.x),y=math.floor(friend.y),scene=scene});api.sleep(600)
                            local a=api.selectOption({'#{ZMPT_230629_47}'},true);api.sleep(800)
                            local b=api.selectOption({'#{ZMPT_230629_132}'},true);api.sleep(800)
                            if not a and not b then
                                if api.selectOption({'#{ZMPT_230629_48}'},true) then api.sleep(800);api.selectOption({'#{ZMPT_230629_43}'},true);api.sleep(800);cleared=cleared+1 end
                            end
                            if S.world().scene==scene then CloseAllWindow() end
                        end
                    end
                    if S.world().scene==scene then api.maintain() end
                    api.sleep(500)
                end
            else
                local n=level()
                if n<0 then n=level() end
                if n<0 then error('剑纵群雄：读不到当前关数，界面事件要实测',0) end
                local nextFloor=math.floor(math.min(n+1,100))
                floorsTried[nextFloor]=(floorsTried[nextFloor] or 0)+1
                if floorsTried[nextFloor]>2 then
                    return {status=cleared>0 and 'done' or 'already_done',message='剑纵群雄结束：第 '..nextFloor..' 关进不去或打不过；本次过 '..cleared..' 关'}
                end
                local name,sc,x,y=GetLuaValue(string.format([[-- daily:zm-goto
                    local name,scene,x,z=Player:GetZMPTUiGoToInfo(%d)
                    return name or '',scene or -1,x or 0,z or 0]],nextFloor),'snnn')
                if type(name)~='string' or name=='' or sc~=0 and sc~=1 and sc~=2 then error('剑纵群雄：第 '..nextFloor..' 关没有 NPC 资料',0) end
                solo();S.log('前往第 '..nextFloor..' 关')
                api.openNpc({name=name,x=math.floor(x),y=math.floor(y),scene=math.floor(sc)});api.sleep(500)
                local ok=api.selectOption({'#{ZMPT_230629_21}'},true);api.sleep(800);CloseAllWindow()
                if not ok then return {status=cleared>0 and 'done' or 'already_done',message='剑纵群雄结束：'..name..' 没有入关选项；本次过 '..cleared..' 关'} end
                local began=api.now()
                while not inside() and api.now()-began<15000 do api.maintain();api.sleep(500) end
            end
            api.maintain();api.sleep(300)
        end
    end)
end

-- 杯酒尽江湖: drink at the jar until the game says enough, then collect at 嵇竹叶. Pouring for others goes through a direct packet and is not ported.
function DailyTasks.beijiu()
    local cfg=TaskConfig or {}
    local S=open('杯酒尽江湖',tonumber(cfg.short_minutes or 30))
    local api=S.api
    local fired=DungeonTactics.prompts(api,{'BJJH_221024_66','BJJH_221024_100','BJJH_221024_12','BJJH_221024_14','BJJH_221024_18','BJJH_221024_19','BJJH_221024_29','BJJH_221024_30'})
    return S.finish(function()
        S.log('喝酒')
        MoveTo(399,224,0);pcall(api.prepareBattle)
        local T=DungeonTactics.new(api,0,{})
        local sips,idle=0,api.now()
        while not (fired('BJJH_221024_66') or fired('BJJH_221024_100')) do
            S.check()
            local jar
            for _,o in ipairs(T.rows()) do if o.name=='酒坛' and not T.enemy(o) and (not jar or o.dst<jar.dst) then jar=o end end
            if jar then
                local used,missing=T.useSkill(4830,jar)
                if missing then error('杯酒尽江湖：角色没有饮酒技能',0) end
                if used then sips=sips+1;idle=api.now() end
                S.busy(5);S.wait(1000)
            else
                assert(api.now()-idle<120000,'杯酒尽江湖：2 分钟没有看到酒坛，可能不在活动时间')
                S.wait(1000)
            end
        end
        S.log('领奖')
        local npc={name='嵇竹叶',x=404,y=224,scene=0}
        local function claim(options,a,b)
            for _=1,10 do
                S.check();CloseAllWindow();api.openNpc(npc);api.sleep(300)
                for _,o in ipairs(options) do api.selectOption({o},true);api.sleep(1000) end
                if fired(a) or fired(b) then break end
            end
            CloseAllWindow()
        end
        claim({'领取饮酒奖励'},'BJJH_221024_12','BJJH_221024_14')
        claim({'领取斟酒奖励'},'BJJH_221024_18','BJJH_221024_19')
        claim({'领取上周斟酒达成奖励','领取斟酒达成奖励'},'BJJH_221024_29','BJJH_221024_30')
        return {status=sips>0 and 'done' or 'already_done',message='杯酒尽江湖结束；喝酒 '..sips..' 次，奖励已领'}
    end)
end
