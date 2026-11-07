-- Same movement entry for verified directed NPC routes and built-in game routes.
LoadScript('city_travel')
NavigationRuntime={}
local function city(catalog,scene)
    for _,c in ipairs(catalog.cities or {}) do if c.scene_id==scene then return c end end
end
function NavigationRuntime.travel(scene,x,y,range,move)
    local catalog=NavigationCatalog
    if type(catalog)~='table' or catalog.runtime_enabled~=true then return false end
    local current=GetSceneID()
    if current==scene then return false end
    local from,to=city(catalog,current),city(catalog,scene)
    if not from or not to then return false end
    local route,why=CityTravelPlanner.find_route(catalog,from.city_id,to.city_id)
    if not route then
        PushDebugMessage('无已核对 NPC 线路，使用游戏自动寻路：'..tostring(why));return false
    end
    local start=GetTickCount()
    local limit=math.min(600000,tonumber((catalog.policy or {}).task_timeout_ms) or 180000)
    for _,hop in ipairs(route) do
        local destination
        for _,c in ipairs(catalog.cities) do if c.city_id==hop.to_city then destination=c end end
        assert(destination and type(destination.scene_id)=='number' and destination.scene_id>=0,'传送目标场景编号缺失')
    end
    for _,hop in ipairs(route) do
        assert(GetTickCount()-start<limit,'跨城 NPC 导航超过总时限')
        local source=assert(city(catalog,GetSceneID()),'传送前场景不可识别')
        assert(source.city_id==hop.from_city,'传送前地图发生变化')
        GoToSceneNPC(hop.npc_name,hop.x,hop.y,source.scene_id,start+limit)
        assert(GetTickCount()-start<limit,'跨城 NPC 导航超过总时限')
        assert(GetSceneID()==source.scene_id,'传送对话前地图发生变化')
        assert(QuestFrameOptionClicked(hop.option_text,1),'传送 NPC 没有目的地选项：'..hop.option_text)
        local target
        for _,c in ipairs(catalog.cities) do if c.city_id==hop.to_city then target=c end end
        assert(target and type(target.scene_id)=='number','传送目标场景编号缺失')
        local sent=GetTickCount()
        while GetSceneID()~=target.scene_id do
            assert(GetTickCount()-sent<45000 and GetTickCount()-start<limit,'NPC 传送后未确认换图，不重复提交')
            Sleep(250)
        end
    end
    move(x,y,scene,range,start+limit)
    return true
end
