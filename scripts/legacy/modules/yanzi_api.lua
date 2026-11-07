LoadScript('dungeon_api')
YanziApi={}
local function integer(v,lo,hi) return type(v)=='number' and v==math.floor(v) and v>=lo and v<=hi end
local supplies={['悲酥清风解药']=true,['段延庆的宝箱']=true,['段延庆的宝藏']=true,['段延庆的宝箱·遗']=true}
function YanziApi.new()
    local api=DungeonApi.new()
    api.teamNear=function(point,radius)
        local p=assert(api.world());if p.scene~=point.scene or (p.x-point.x)^2+(p.y-point.y)^2>radius^2 then return false end
        local own,server=CombatRuntime.host('battle_self_identity');local rows=api.mechanisms()
        for _,id in ipairs(api.teamIdentities()) do
            if id.id~=own or id.server_id~=server then
                local found
                for _,o in ipairs(rows) do if o.kind==1 and o.id==id.id and o.server_id==id.server_id then found=o;break end end
                if not found or (found.x-point.x)^2+(found.y-point.y)^2>radius^2 then return false end
            end
        end
        return true
    end
    api.campaign=function(refresh)
        if refresh then
            GetLuaValue([[-- yanzi:campaign-refresh
                local e=PlayerQuicklyEnter_Env
                local f=type(e)=='table' and e.PlayerQuicklyEnter_ActivityShedule or PlayerQuicklyEnter_ActivityShedule
                if type(f)~='function' then error('campaign refresh API unavailable') end
                f()
            ]],'',0)
            api.sleep(500)
        end
        local used,limit,kind,index,name=GetLuaValue([[-- yanzi:campaign
            local n=GetNewCampaignCount(2)
            if type(n)~='number' or n~=math.floor(n) or n<0 or n>256 then error('campaign list unavailable') end
            local found=-1 local title='' local used=-1 local maximum=-1 local today=-1
            for i=0,n-1 do
                local s=EnumNewCampaign(2,i,'name')
                if type(s)~='string' then error('campaign name unavailable') end
                if s=='讨伐燕子坞' then
                    if found~=-1 then error('duplicate Yanzi campaign') end
                    found=i title=s used=EnumNewCampaign(2,i,'MyCampaingCount')
                    maximum=EnumNewCampaign(2,i,'PlayNum') today=EnumNewCampaign(2,i,'IsToday')
                end
            end
            if GetNewCampaignCount(2)~=n then error('campaign list changed') end
            return used,maximum,today,found,title
        ]],'nnnns')
        assert(integer(index,0,255) and name=='讨伐燕子坞','活动页没有可核对的讨伐燕子坞记录')
        assert(integer(used,0,1000) and integer(limit,1,1000) and used<=limit and integer(kind,0,3),'燕子坞活动次数无效')
        assert(kind~=2,'燕子坞活动当前不可参与')
        return {used=used,limit=limit,kind=kind,name=name}
    end
    api.item=function(name)
        assert(supplies[name],'不是燕子坞副本道具')
        local slot,id,num,total=GetLuaValue(string.format([[-- yanzi:item
            local name=%q local n=DataPool:GetBaseBag_Num()
            if type(n)~='number' or n~=math.floor(n) or n<1 or n>512 then error('base bag unavailable') end
            local slot=-1 local define=-1 local count=0 local total=0
            for i=0,n-1 do local a=PlayerPackage:EnumItem('base',i)
                if a and a:GetID()~=0 and a:GetName()==name then
                    local c=a:GetNum() local id=a:GetDefineID()
                    if type(c)~='number' or c~=math.floor(c) or c<1 or c>2000000000 or type(id)~='number' or id<=0 or id~=math.floor(id) then error('dungeon item unavailable') end
                    total=total+c
                    if slot==-1 then slot=i define=id count=c end
                end
            end
            return slot,define,count,total
        ]],name),'nnnn')
        assert(integer(slot,-1,511) and integer(id,-1,2147483647) and integer(num,0,2000000000)
            and integer(total,0,2000000000) and (slot==-1 and id==-1 and num==0 and total==0 or slot>=0 and id>0 and num>0 and total>=num),'副本道具记录无效')
        return {slot=slot,id=id,num=num,total=total,name=name}
    end
    api.useItem=function(item)
        assert(supplies[item.name] and item.slot>=0 and item.id>0,'副本道具身份无效')
        local result=GetLuaValue(string.format([[-- yanzi:use-item
            local i=%d local id=%d local name=%q local count=%d
            local a=PlayerPackage:EnumItem('base',i)
            if not a or a:GetID()==0 or a:GetName()~=name or a:GetDefineID()~=id or a:GetNum()~=count then error('dungeon item identity changed') end
            PlayerPackage:UseItem(i)
            return 1
        ]],item.slot,item.id,item.name,item.num),'n')
        assert(result==1,'副本道具使用请求无回执')
    end
    api.pickup=function()
        local origin=assert(api.world());local began=api.now();local attempted={};local requests=0
        local function snapshot()
            local scene,count,text=CombatRuntime.host('loot_snapshot')
            assert(scene==origin.scene and assert(api.world()).scene==scene and integer(count,0,512) and type(text)=='string','包裹快照或场景无效')
            local result,seen={},{}
            for line in text:gmatch('[^\n]+') do
                local kind,id,server,x,y=line:match('^(%d+)\t(%d+)\t(-?%d+)\t([^\t]+)\t([^\t]+)$')
                kind,id,server,x,y=tonumber(kind),tonumber(id),tonumber(server),tonumber(x),tonumber(y)
                assert(kind==3 and integer(id,0,2147483647) and integer(server,-1,2147483647) and x and y and x==x and y==y
                    and math.abs(x)<100000 and math.abs(y)<100000 and not seen[id],'地面包裹身份或坐标无效')
                seen[id]=true;result[#result+1]={id=id,server=server,x=x,y=y,key=id..':'..server}
            end
            assert(#result==count,'包裹快照数量变化');return result
        end
        local function current(item)
            for _,o in ipairs(snapshot()) do if o.key==item.key then return o end end
        end
        local function visible()
            local v=GetLuaValue([[-- yanzi:loot-visible
                local e=LootPacket_Env
                if not e or not e.this then error('LootPacket UI unavailable') end
                return e.this:IsVisible()
            ]],'b')
            assert(type(v)=='boolean','包裹窗口状态不可读');return v
        end
        local function close()
            GetLuaValue([[-- yanzi:loot-close
                CloseWindow('LootPacket',true)
            ]],'',0)
        end
        local function wait(label,probe,ms)
            local start=api.now()
            repeat
                assert(api.now()-began<60000,'本次拾取超过总时限')
                local result=probe();if result then return result end
                api.maintain();api.sleep(100)
            until api.now()-start>=ms
            error(label..'超时，停止且不重复打开或领取',0)
        end
        for _=1,16 do
            local target,best;local p=assert(api.world())
            for _,o in ipairs(snapshot()) do
                local d=(o.x-p.x)^2+(o.y-p.y)^2
                if not attempted[o.key] and (o.x-origin.x)^2+(o.y-origin.y)^2<=35^2 and (not best or d<best) then target=o;best=d end
            end
            if not target then return requests end
            attempted[target.key]=true;api.space()
            if best>9 then
                CombatRuntime.call(CombatRuntime.codes.RunTo,{origin.scene},{target.x,target.y})
                wait('接近地面包裹',function()
                    local o=current(target);if not o then return true end
                    local p=assert(api.world());return (p.x-o.x)^2+(p.y-o.y)^2<=9
                end,15000)
                api.stop()
            end
            if current(target) then
                close();wait('关闭上一个包裹窗口',function() return not visible() end,2000)
                assert(CombatRuntime.host('open_loot',target.key)==1,'打开包裹请求无回执')
                local opened=wait('等待地面包裹打开',function()
                    if visible() then return 'open' end
                    if not current(target) then return 'gone' end
                end,8000)
                if opened=='open' then
                    api.space()
                    GetLuaValue([[-- yanzi:pickup
                        local e=LootPacket_Env
                        if not e or not e.this or not e.this:IsVisible() then error('LootPacket closed before take') end
                        if type(PlayerPackage.PickAllItem)~='function' then error('native PickAllItem unavailable') end
                        PlayerPackage:PickAllItem()
                    ]],'',0)
                    requests=requests+1;api.sleep(500);close()
                    -- Taking is not a completion receipt. Supplies subsequently
                    -- verify bag changes; dungeon completion uses the campaign.
                end
            end
        end
        return requests
    end
    api.takeAntidote=function()
        api.space()
        GetLuaValue([[-- yanzi:temporary-antidote
            local e=Packet_Temporary_Env
            if type(e)~='table' then error('temporary bag UI unavailable') end
            local open=type(Packet_Env)=='table' and Packet_Env.Packet_Temporary_BtnClick or Packet_Temporary_BtnClick
            if not e.this or not e.this:IsVisible() then
                if type(open)~='function' then error('temporary bag open unavailable') end
                open()
            end
        ]],'',0)
        api.sleep(300)
        GetLuaValue([[-- yanzi:temporary-take
            local e=Packet_Temporary_Env
            if not e or not e.this or not e.this:IsVisible() then error('temporary bag not open') end
            local n=Bank:GetTemBankItemNum()
            if type(n)~='number' or n~=math.floor(n) or n<0 or n>120 then error('temporary bag count unavailable') end
            for i=0,119 do local a,locked=Bank:EnumTemItem(i)
                if a and a:GetID()~=0 and locked~=true and a:GetName()=='悲酥清风解药' then
                    local element=e['Packet_Temporary_ActionsList_auto_element'..i]
                    local button=element and element:GetLuaActionButton('Packet_Temporary')
                    if not button then error('temporary item action unavailable') end
                    button:DoAction() return
                end
            end
        ]],'',0)
    end
    return api
end
