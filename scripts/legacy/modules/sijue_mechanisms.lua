LoadScript('dungeon_navigation')
SijueMechanisms={}
local N=assert(DungeonNavigation)
function SijueMechanisms.new(api,radius)
    local s={traps={},players={},radius=radius,path=nil,last=-10000,key=''}
    function s.read()
        local rows=api.mechanisms();s.traps={};s.players={};local keys={}
        for _,o in ipairs(rows) do
            if o.kind==2 then
                s.traps[#s.traps+1]=o;keys[#keys+1]=string.format('%d:%d:%.3f:%.3f',o.id,o.server_id,o.x,o.y)
            else s.players[#s.players+1]=o end
        end
        assert(#s.traps<=32,'四绝庄陷阱数量超过 32，停止移动')
        table.sort(keys);local signature=table.concat(keys,';')
        if s.signature~=signature then s.path=nil;s.signature=signature end
    end
    function s.safe(point) return N.safe({x=point[1],y=point[2]},s.traps,radius) end
    function s.clear(a,b) return N.clear(a,b,s.traps,radius,true) end
    function s.spread()
        local p=assert(api.world());local best,score
        for x=16,40 do
            local point={x,114};local good=s.safe(point)
            for _,o in ipairs(s.players) do if (o.x-x)^2+(o.y-114)^2<36 then good=false;break end end
            local d=(p.x-x)^2+(p.y-114)^2
            if good and (not score or d<score) then best,score=point,d end
        end
        return best
    end
    function s.teamInArena()
        local self,server=CombatRuntime.host('battle_self_identity')
        local identities=api.teamIdentities();local others=0
        for _,id in ipairs(identities) do
            if id.id~=self or id.server_id~=server then
                local found
                for _,o in ipairs(s.players) do if id.id==o.id and id.server_id==o.server_id then found=o;break end end
                assert(found,'失明分担：队友位置或身份不可读')
                if found.x<5 or found.x>50 or found.y<78 or found.y>122 then return false end
                others=others+1
            end
        end
        return others>0
    end
    function s.move(point,bounds)
        local p=assert(api.world());assert(p.scene==291,'机制移动时已离开四绝庄')
        local goal={x=point[1],y=point[2]};local key=point[1]..','..point[2]
        if (p.x-goal.x)^2+(p.y-goal.y)^2<=0.16 and s.safe(point) then s.path=nil;return false end
        if key~=s.key then s.path=nil;s.key=key end
        if s.path then
            while s.path[1] and (p.x-s.path[1].x)^2+(p.y-s.path[1].y)^2<=0.16 do table.remove(s.path,1) end
            if not s.path[1] or not s.clear(p,s.path[1]) then s.path=nil end
        end
        if not s.path then
            local why;s.path,why=N.plan(p,goal,s.traps,radius,bounds,function() api.sleep(1) end)
            if not s.path then api.stop();return true,why end
        end
        local next=s.path[1];local waypoint=string.format('%.3f,%.3f',next.x,next.y)
        if waypoint~=s.waypoint or api.now()-s.last>=4000 then
            api.stop();CombatRuntime.call(CombatRuntime.codes.RunTo,{291},{next.x,next.y})
            s.waypoint=waypoint;s.last=api.now()
        end
        return true
    end
    function s.escape(bounds)
        local p=assert(api.world());if N.safe(p,s.traps,radius) then return false end
        local candidates={}
        for y=math.floor(p.y-radius*2),math.ceil(p.y+radius*2) do
            for x=math.floor(p.x-radius*2),math.ceil(p.x+radius*2) do
                if x>=bounds[1] and x<=bounds[3] and y>=bounds[2] and y<=bounds[4] and s.safe({x,y}) then
                    candidates[#candidates+1]={x,y,d=(p.x-x)^2+(p.y-y)^2}
                end
            end
        end
        table.sort(candidates,function(a,b) return a.d<b.d end)
        for _,point in ipairs(candidates) do
            if N.clear(p,{x=point[1],y=point[2]},s.traps,radius,true) then return s.move(point,bounds) end
        end
        api.stop();return true,'当前陷阱内没有可用撤离点'
    end
    return s
end
