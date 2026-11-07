-- Bounded arena planner. It models configured circular hazard clearances, not
-- the game's collision mesh. Game navigation still executes each short leg.
DungeonNavigation={}
local N=DungeonNavigation
function N.clear(a,b,hazards,radius,escape)
    local dx,dy=b.x-a.x,b.y-a.y;local len=dx*dx+dy*dy
    for _,h in ipairs(hazards) do
        local x,y=a.x-h.x,a.y-h.y;local initial=x*x+y*y
        if initial<radius*radius and escape then
            if x*dx+y*dy<0 or (b.x-h.x)^2+(b.y-h.y)^2<=initial then return false end
        else
            local t=len>0 and math.max(0,math.min(1,-(x*dx+y*dy)/len)) or 0
            if (x+t*dx)^2+(y+t*dy)^2<radius*radius then return false end
        end
    end
    return true
end
function N.safe(p,hazards,radius) return N.clear(p,p,hazards,radius,false) end
function N.plan(from,goal,hazards,radius,bounds,yieldFn)
    assert(type(hazards)=='table' and #hazards<=32,'陷阱数量超过规划上限 32')
    assert(type(radius)=='number' and radius>=2 and radius<=10,'陷阱安全距离无效')
    if not N.safe(goal,hazards,radius) then return nil,'目标点被陷阱覆盖' end
    if N.clear(from,goal,hazards,radius,true) then return {goal} end
    local minx,miny=math.floor(math.min(bounds[1],from.x,goal.x)-2),math.floor(math.min(bounds[2],from.y,goal.y)-2)
    local maxx,maxy=math.ceil(math.max(bounds[3],from.x,goal.x)+2),math.ceil(math.max(bounds[4],from.y,goal.y)+2)
    local width,height=maxx-minx+1,maxy-miny+1
    if width*height>4096 then return nil,'规划区域超过 4096 格' end
    local function node(x,y) return (y-miny)*width+x-minx+1 end
    local function point(id) return {x=(id-1)%width+minx,y=math.floor((id-1)/width)+miny} end
    local function heuristic(p) return math.sqrt((p.x-goal.x)^2+(p.y-goal.y)^2) end
    local heap,dist,parent,closed={},{},{},{}
    local function push(id,score)
        local i=#heap+1;heap[i]={id,score}
        while i>1 do local p=math.floor(i/2);if heap[p][2]<=score then break end;heap[i],heap[p]=heap[p],heap[i];i=p end
    end
    local function pop()
        local out=heap[1];local last=table.remove(heap)
        if #heap>0 then
            heap[1]=last;local i=1
            while i*2<=#heap do local c=i*2;if c+1<=#heap and heap[c+1][2]<heap[c][2] then c=c+1 end
                if heap[i][2]<=heap[c][2] then break end;heap[i],heap[c]=heap[c],heap[i];i=c end
        end
        return out[1]
    end
    -- Connect the real, non-integer start only through verified escape/clear
    -- segments; rounding across a trap is not a valid start node.
    for y=math.floor(from.y)-1,math.ceil(from.y)+1 do for x=math.floor(from.x)-1,math.ceil(from.x)+1 do
        if x>=minx and x<=maxx and y>=miny and y<=maxy then
            local p={x=x,y=y};if N.clear(from,p,hazards,radius,true) then
                local id=node(x,y);local cost=math.sqrt((p.x-from.x)^2+(p.y-from.y)^2)
                if not dist[id] or cost<dist[id] then dist[id]=cost;parent[id]=0;push(id,cost+heuristic(p)) end
            end
        end
    end end
    local expanded=0
    while #heap>0 do
        assert(#heap<=32768,'规划候选超过上限')
        local current=pop()
        if not closed[current] then
            closed[current]=true;expanded=expanded+1
            local p=point(current)
            if heuristic(p)<=2 and N.clear(p,goal,hazards,radius,true) then
                local reverse={goal};local id=current
                while id~=0 do reverse[#reverse+1]=point(id);id=assert(parent[id],'规划父节点缺失') end
                local path={};for i=#reverse,1,-1 do path[#path+1]=reverse[i] end
                return path
            end
            for dy=-1,1 do for dx=-1,1 do if dx~=0 or dy~=0 then
                local x,y=p.x+dx,p.y+dy
                if x>=minx and x<=maxx and y>=miny and y<=maxy then
                    local id=node(x,y);local q={x=x,y=y};local cost=dist[current]+(dx~=0 and dy~=0 and math.sqrt(2) or 1)
                    if not closed[id] and (not dist[id] or cost<dist[id]) and N.clear(p,q,hazards,radius,true) then
                        dist[id]=cost;parent[id]=current;push(id,cost+heuristic(q))
                    end
                end
            end end end
            if yieldFn and expanded%64==0 then yieldFn() end
        end
    end
    return nil,'没有可用的陷阱绕行路径'
end
