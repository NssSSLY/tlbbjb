local root=assert(arg[1])
dofile(root..'/scripts/legacy/modules/dungeon_navigation.lua')
local N=DungeonNavigation
local checks=0
local function test(fn) fn();checks=checks+1 end
local bounds={0,0,24,24}
local function verify(from,goal,hazards,radius)
    local path,why=N.plan(from,goal,hazards,radius,bounds)
    assert(path,why);assert(#path<=4097)
    local p=from
    for _,q in ipairs(path) do assert(N.clear(p,q,hazards,radius,true),'route crosses a hazard');p=q end
    assert(p.x==goal.x and p.y==goal.y)
    return path
end
test(function() assert(#verify({x=0,y=0},{x=20,y=0},{},4)==1) end)
test(function() assert(#verify({x=1.4,y=12.4},{x=23,y=12},{{x=12,y=12}},4)>2) end)
test(function() verify({x=12,y=12},{x=23,y=12},{{x=12,y=12}},4) end)
test(function() verify({x=12.7,y=12.1},{x=23,y=12},{{x=12,y=12}},4) end)
test(function() assert(not N.clear({x=0,y=0},{x=20,y=0},{{x=10,y=0}},2,true)) end)
test(function() assert(not N.clear({x=11,y=12},{x=12,y=12},{{x=12,y=12}},4,true)) end)
test(function() assert(not N.plan({x=0,y=0},{x=12,y=12},{{x=12,y=12}},4,bounds)) end)
test(function() assert(not N.plan({x=0,y=0},{x=24,y=24},{{x=12,y=12}},10,{0,0,1000,1000})) end)
test(function()
    local wall={};for y=-20,44,4 do wall[#wall+1]={x=12,y=y} end
    assert(not N.plan({x=1,y=12},{x=23,y=12},wall,4,bounds))
end)
test(function()
    local many={};for i=1,33 do many[i]={x=i,y=12} end
    assert(not pcall(N.plan,{x=0,y=0},{x=24,y=24},many,4,bounds))
end)
-- Exercise the production waypoint cache with actual movement and a changing
-- trap snapshot. Every emitted leg must be clear from the current position.
local time,p,rows=0,{scene=291,x=1.4,y=12.4},{{kind=2,id=8,server_id=-1,x=12,y=12}}
LoadScript=function(name) dofile(root..'/scripts/legacy/modules/'..name..'.lua') end
CombatRuntime={codes={RunTo=1},host=function() return 42,903 end,call=function(_,_,xy)
    assert(N.clear(p,{x=xy[1],y=xy[2]},rows,4,true),'cached leg crosses current trap')
    p.x,p.y=xy[1],xy[2]
end}
LoadScript('sijue_mechanisms')
local api={mechanisms=function() return rows end,world=function() return p end,now=function() return time end,sleep=function(ms) time=time+ms end,stop=function() end}
test(function()
    local nav=SijueMechanisms.new(api,4)
    for i=1,100 do
        nav.read();if not nav.move({23,12},bounds) then break end;time=time+500
        if i==5 then rows={{kind=2,id=9,server_id=-1,x=16,y=12}} end
    end
    assert((p.x-23)^2+(p.y-12)^2<=.16,'cached route never arrived')
end)
test(function()
    rows={{kind=1,id=43,server_id=904,x=28,y=114}};p={scene=291,x=28,y=100}
    local nav=SijueMechanisms.new(api,4);nav.read();local point=assert(nav.spread());assert((point[1]-28)^2>=36)
    api.teamIdentities=function() return {{id=42,server_id=903},{id=43,server_id=904}} end
    assert(nav.teamInArena());rows[1].y=34;assert(not nav.teamInArena())
    rows[1].server_id=905;assert(not pcall(nav.teamInArena))
end)
print(checks..' dungeon geometry/cache/roster checks passed')
