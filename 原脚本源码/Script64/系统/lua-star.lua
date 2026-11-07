-- 反编译自 dfz64.dll 内嵌字节码 00541346（unluac 2025-12-23；仅供分析）
local module = {}

function module:clearCached()
  module.cache = nil
end

local function keyOf(start, goal)
  return fmt("%d,%d>%d,%d", start.x, start.y, goal.x, goal.y)
end

local function getCached(start, goal)
  if module.cache then
    local key = keyOf(start, goal)
    return module.cache[key]
  end
end

local function saveCached(start, goal, path)
  module.cache = module.cache or {}
  local key = keyOf(start, goal)
  module.cache[key] = path
end

local function distance(x1, y1, x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  local s = dx * dx + dy * dy
  return s
end

local function clamp(x, min, max)
  return x < min and min or max < x and max or x
end

local function calculateScore(previous, node, goal)
  local G = previous.score + 1
  local H = distance(node.x, node.y, goal.x, goal.y)
  return G + H, G, H
end

local function listContains(list, item)
  for _, test in ipairs(list) do
    if test.x == item.x and test.y == item.y then
      return true
    end
  end
  return false
end

local function listItem(list, item)
  for _, test in ipairs(list) do
    if test.x == item.x and test.y == item.y then
      return test
    end
  end
end

local function getAdjacent(widthStart, widthStop, heightStart, heightStop, node, positionIsOpenFunc)
  local result = {}
  local positions = {
    {x = 0, y = -1},
    {x = -1, y = 0},
    {x = 0, y = 1},
    {x = 1, y = 0},
    {x = -1, y = -1},
    {x = 1, y = -1},
    {x = -1, y = 1},
    {x = 1, y = 1}
  }
  for _, point in ipairs(positions) do
    local px = clamp(node.x + point.x, widthStart, widthStop)
    local py = clamp(node.y + point.y, heightStart, heightStop)
    local value = positionIsOpenFunc(px, py)
    if value then
      table.insert(result, {x = px, y = py})
    end
  end
  return result
end

function module:find(widthStart, widthStop, heightStart, heightStop, start, goal, positionIsOpenFunc, useCache)
  if useCache then
    local cachedPath = getCached(start, goal)
    if cachedPath then
      return cachedPath
    end
  end
  local success = false
  local open = {}
  local closed = {}
  start.score = 0
  start.G = 0
  start.H = distance(start.x, start.y, goal.x, goal.y)
  start.parent = {x = 0, y = 0}
  table.insert(open, start)
  local time_start = os.time()
  while not success and #open > 0 do
    if os.time() - time_start > 1 then
      if PushColorMsg then
        PushColorMsg("计算路径耗时太长")
      end
      success = false
      break
    end
    table.sort(open, function(a, b)
      return a.score > b.score
    end)
    local current = table.remove(open)
    table.insert(closed, current)
    success = listContains(closed, goal)
    if not success then
      local adjacentList = getAdjacent(widthStart, widthStop, heightStart, heightStop, current, positionIsOpenFunc)
      for _, adjacent in ipairs(adjacentList) do
        if not listContains(closed, adjacent) and not listContains(open, adjacent) then
          adjacent.score = calculateScore(current, adjacent, goal)
          adjacent.parent = current
          table.insert(open, adjacent)
        end
      end
    end
  end
  if not success then
    return false
  end
  local node = listItem(closed, closed[#closed])
  local path = {}
  while node do
    table.insert(path, 1, {
      x = node.x,
      y = node.y
    })
    node = listItem(closed, node.parent)
  end
  saveCached(start, goal, path)
  return path
end

return module
