local root=assert(arg[1])
dofile(root..'/scripts/navigation/city_travel.lua')
function LoadScript() end
dofile(root..'/scripts/legacy/modules/navigation_runtime.lua')
local passed=0
local function test(name,f) f();passed=passed+1;print(name..': pass') end
local scene,clock,clicks,moves,failSwitch
local function seed()
    scene,clock,clicks,moves,failSwitch=2,0,0,0,false
    NavigationCatalog={runtime_enabled=true,cities={
        {city_id='dali',map_name='大理',scene_id=2,npcs={{enabled=true,verified=true,npc_id='npc',name='测试传送员',position={x=1,y=2},destinations={{enabled=true,verified=true,target_city='suzhou',destination_id='ds',dialog_option={text='前往苏州'}}}}}},
        {city_id='suzhou',map_name='苏州',scene_id=1,npcs={}}
    }}
end
function GetSceneID() return scene end
function GetTickCount() return clock end
function Sleep(ms) clock=clock+ms end
function PushDebugMessage() end
function GoToSceneNPC(name,x,y,s) assert(scene==s and name=='测试传送员');moves=moves+1 end
function QuestFrameOptionClicked(text) assert(text=='前往苏州');clicks=clicks+1;if not failSwitch then scene=1 end;return true end
local function finalMove(x,y,s,r) assert(scene==s and x==133 and y==260);moves=moves+1 end
test('npc_hop_then_final_position',function() seed();assert(NavigationRuntime.travel(1,133,260,3,finalMove));assert(clicks==1 and moves==2) end)
test('missing_route_uses_existing_game_path',function() seed();NavigationCatalog.cities[1].npcs[1].verified=false;assert(not NavigationRuntime.travel(1,133,260,3,finalMove));assert(clicks==0 and moves==0) end)
test('same_scene_skips_npc',function() seed();scene=1;assert(not NavigationRuntime.travel(1,133,260,3,finalMove));assert(clicks==0) end)
test('failed_map_change_never_reclicks',function() seed();failSwitch=true;local ok,why=pcall(NavigationRuntime.travel,1,133,260,3,finalMove);assert(not ok and tostring(why):find('未确认换图',1,true));assert(clicks==1 and moves==1) end)
test('missing_target_id_rejected_before_actions',function() seed();NavigationCatalog.cities[2].scene_id=nil;assert(not NavigationRuntime.travel(1,133,260,3,finalMove));assert(clicks==0) end)
test('unexpected_scene_before_click_rejected',function() seed();local old=GoToSceneNPC;GoToSceneNPC=function(...) old(...);scene=9 end;local ok=pcall(NavigationRuntime.travel,1,133,260,3,finalMove);GoToSceneNPC=old;assert(not ok) end)
print('navigation runtime checks: '..passed)
