LoadScript("dungeon_flow")
LoadScript("dungeon_api")
Sanhuan={}
local cfg=TaskConfig or {}
local function inside(id,name) return function(p) return id and p.scene==id or p.map==name end end
local oldRoutes={
    {{183,155},{180,143},{165,116},{182,118},{199,135}},{{178,120}},{{199,105}},{{204,122}},{{194,54}},
    {{147,65},{135,74},{125,41},{99,42},{74,40},{68,58},{52,44}},{{52,44}},{{58,196}},
}
for _,route in ipairs(oldRoutes) do for i,p in ipairs(route) do route[i]={x=p[1],y=p[2]} end end
-- Stage to route, as the reference has it: 匪类 splits the team between two camps by member order; 都统 and 余毒 share one point.
local function routeFor(index,api)
    if index==3 then
        local member=0
        pcall(function()
            local own=CombatRuntime.host('battle_self_identity')
            for i,m in ipairs(api.teamIdentities()) do if m.id==own then member=i-1 end end
        end)
        return (member==0 or member==2 or member==4) and oldRoutes[3] or oldRoutes[4]
    end
    if index==4 or index==5 then return oldRoutes[5] end
    return oldRoutes[index]
end
local stageNames={"宋兵","副都统","匪类","都统","余毒","野熊","红熊王","葛荣"}
local function fraction(text,max)
    assert(type(text)=="string","三环进度文字不可读")
    local current,total=text:match("(%d+)%s*/%s*(%d+)")
    current,total=tonumber(current),tonumber(total)
    assert(current and total==max and current<=total,"三环进度格式无效："..text)
    return current
end
local old={name="老三环 · 除匪首力破三关",mission="除匪首力破三关",map="三才峡谷",inside=inside(653,"三才峡谷"),
    npc={name="钱宏宇",x=133,y=260,scene=1},accept={"除匪首力破三关"},turnin={"除匪首力破三关"},
    enter={"#{LSHYH_150210_78}"},limit={"#{XSCS_180827_1}"},bosses={"余毒","红熊王","愤怒的红熊王","葛荣","愤怒的葛荣"},redo=true}
function old.progress(api,m,context)
    local page,a,b,c,d,e=GetLuaValue([[-- dungeon:sancai-progress
        local env=Sancai_Env
        if type(env)~='table' or not env.this then return 0,'','','','','' end
        if not env.this:IsVisible() then PushEvent('3HUAN_OPEN_UI_RESULT',1) end
        if not env.this:IsVisible() then return 0,'','','','','' end
        local function text(key) local w=env[key] if not w then error('sancai progress widget missing') end return w:GetProperty('Text') end
        if env.Sancai_BK1:IsVisible() then return 1,text('Sancai_Image1Info2'),text('Sancai_Image1Info3'),text('Sancai_Image1Info4'),text('Sancai_Image1Info5'),text('Sancai_Image1Info6') end
        if env.Sancai_BK2:IsVisible() then return 2,text('Sancai_Image2Info2'),text('Sancai_Image2Info3'),'','','' end
        if env.Sancai_BK3:IsVisible() then return 3,text('Sancai_Image3Info2'),'','','','' end
        return 0,'','','','',''
    ]],"nsssss")
    if page==0 then
        assert(api.now()-context.lastStageRead<15000,"老三环进度面板 15 秒未返回阶段")
        return nil
    end
    assert(page==1 or page==2 or page==3,"老三环进度页无效")
    context.lastStageRead=api.now()
    local index
    if page==1 then
        local values={fraction(a,30),fraction(b,1),fraction(c,6),fraction(d,1),fraction(e,1)}
        local maxima={30,1,6,1,1}
        for i,n in ipairs(values) do if n<maxima[i] then index=i;break end end
    elseif page==2 then
        local bear,king=fraction(a,30),fraction(b,1)
        if bear<30 then index=6 elseif king<1 then index=7 end
    elseif fraction(a,1)<1 then index=8 end
    -- A complete progress page waits for the server's next page/mission state.
    if not index then
        context.waitingPage=context.waitingPage or api.now()
        assert(api.now()-context.waitingPage<15000,"老三环本页进度已满，下一阶段或任务完成状态 15 秒未更新")
        return nil
    end
    context.waitingPage=nil
    -- Parcels drop as the stages fall; the reference skips them only while the team is split at the 匪类 camps.
    if index~=3 and api.pickup and api.now()-(context.lastPick or -100000)>=5000 then
        context.lastPick=api.now();api.pickup()
    end
    -- 葛荣: gather at his hall first, then bring him out with 244 if this character has it.
    if index==8 and api.teamNear and not context.bossReady then
        context.bossReady=true
        local at=oldRoutes[8][1]
        MoveTo(at.x,at.y,context.scene);api.prepareBattle()
        local began=api.now()
        local function gathered() local ok,near=pcall(api.teamNear,{scene=context.scene,x=at.x,y=at.y},14);return ok and near end
        while api.now()-began<20000 and not gathered() do api.maintain();api.sleep(500) end
        local T=DungeonTactics.new(api,context.scene,{})
        local boss
        for _,o in ipairs(T.rows()) do if (o.name=='山寨大王' or o.name=='愤怒的葛荣') and (not boss or o.dst<boss.dst) then boss=o end end
        if boss then T.useSkill(244,boss);api.sleep(boss.dst>3 and 3000 or 300) end
        context.lastProgress=api.now()
    end
    return {key=index,name=stageNames[index],route=routeFor(index,api),signature=table.concat({tostring(page),a,b,c,d,e},"/")}
end
-- The reference searches for parcels for six seconds after the boss before leaving: server drops arrive late.
function old.afterComplete(api)
    if not api.pickup then return end
    local began=api.now()
    repeat api.pickup();api.maintain();api.sleep(500) until api.now()-began>=6000 or not old.inside(assert(api.world(),'场景不可读'))
end
function old.leave(api)
    api.openNpc({name="宋兵接应人",x=63,y=196,scene=653})
    local clicked=QuestFrameOptionClicked("#{LSHYH_150210_40}",1)
    Sleep(600)
    local p=api.world();if p and not old.inside(p) then return end
    clicked=QuestFrameOptionClicked("#{LSHYH_150210_43}",1) or clicked
    assert(clicked,"老三环离场对话没有返回选项")
end

local function parseRoutes(text)
    assert(type(text)=="string" and #text<=1024,"新三环路线长度不能超过 1024 字节")
    local routes={}
    if text=="" then return routes end
    for group in (text.."|"):gmatch("(.-)|") do
        local route={}
        for point in (group..";"):gmatch("(.-);") do
            local x,y=point:match("^%s*(%d+%.?%d*)%s*,%s*(%d+%.?%d*)%s*$")
            x,y=tonumber(x),tonumber(y)
            assert(x and y and x<=1000 and y<=1000,"新三环路线格式：x,y;x,y|x,y（竖线分组）")
            route[#route+1]={x=x,y=y}
        end
        assert(#route<=24,"每组路线最多 24 点")
        routes[#routes+1]=route
    end
    assert(#routes<=3,"新三环路线最多三组")
    return routes
end
local new={name="新三环 · 剑荡三环除妖魔",mission="剑荡三环除妖魔",map="炎魔山",inside=inside(nil,"炎魔山"),
    npc={name="何悦",x=295,y=68,scene=246},accept={"剑荡三环除妖魔"},turnin={"剑荡三环除妖魔"},
    enter={},limit={},bosses={"王阎","洪棘妖王","火焰妖魔"}}
function new.validate(config)
    parseRoutes(config.sanhuan_route or "")
    for _,key in ipairs({"enter_option","leave_option","sanhuan_exit_npc"}) do
        assert(config[key]==nil or type(config[key])=="string","新三环文本配置无效："..key)
    end
    local npc=(config.sanhuan_exit_npc or ""):match("^%s*(.-)%s*$")
    local option=(config.leave_option or ""):match("^%s*(.-)%s*$")
    assert((npc=="")== (option==""),"新三环离场 NPC 和离场选项必须同时填写，或同时留空读取任务返回坐标")
end
function new.progress(api,m,context)
    context.routes=context.routes or parseRoutes(cfg.sanhuan_route or "")
    local route={}
    for x,y,scene,name in m.desc:gmatch("{[^{}]-(%d+),(%d+),(%d+),([^{}]-)}") do
        if tonumber(scene)==context.scene then route[#route+1]={x=tonumber(x),y=tonumber(y),name=name} end
    end
    -- Explicit routes can supplement server task links; their order is user-configured, never invented.
    if #route==0 then for _,group in ipairs(context.routes) do for _,point in ipairs(group) do route[#route+1]=point end end end
    return {key=m.desc,signature=m.desc,name="炎魔山（按任务目标推进）",route=route}
end
function new.leave(api,m)
    local name=(cfg.sanhuan_exit_npc or ""):match("^%s*(.-)%s*$")
    if name~="" then
        local match
        for _,obj in ipairs(EnumEnvObj()) do
            if obj.class=="NPC" and obj.name==name then assert(not match,"离场 NPC 名称不唯一");match=obj end
        end
        assert(match,"未找到配置的离场 NPC："..name)
        api.openNpc({name=name,x=match.x,y=match.y,scene=assert(api.world()).scene})
        assert(type(cfg.leave_option)=="string" and cfg.leave_option~="","请配置新三环离场选项原文")
        assert(QuestFrameOptionClicked(cfg.leave_option:match("^%s*(.-)%s*$"),1),"未找到新三环离场选项")
        return
    end
    -- Only follow an actual server-supplied outside target. No guessed portal/NPC or scene ID.
    for x,y,scene,name2 in m.desc:gmatch("{[^{}]-(%d+),(%d+),(%d+),([^{}]-)}") do
        if tonumber(scene)==246 and name2=="何悦" then MoveTo(tonumber(x),tonumber(y),246);return end
    end
    error("新三环离场缺少任务返回坐标；请填写离场 NPC 和选项原文",0)
end
Sanhuan.definitions={old=old,new=new}
-- The flow's own adapter, with the parcel and gather helpers the 少室山 family already has.
function Sanhuan.api()
    LoadScript('shaoshi');LoadScript('dungeon_tactics')
    local api,extra=DungeonApi.new(),Shaoshi.newApi()
    api.pickup=extra.pickup;api.teamNear=extra.teamNear
    return api
end
function Sanhuan.run(kind)
    local result=DungeonFlow.run(assert(Sanhuan.definitions[kind],"未知三环类型"),cfg,Sanhuan.api())
    return TaskLifecycle.report(result.status,result.message)
end
