local setmetatable = setmetatable
local remove       = table.remove
local sqrt         = math.sqrt
local max          = math.max

-- Internal class constructor
local class = function(...)
local klass = {}
klass.__index = klass
klass.__call = function(_,...) return klass:new(...) end
function klass:new(...)
  local instance = setmetatable({}, klass)
  klass.__init(instance, ...)
  return instance
end
return setmetatable(klass,{__call = klass.__call})
end

local function quatCross(a, b, c)
  local p = (a + b + c) * (a + b - c) * (a - b + c) * (-a + b + c)
  return sqrt(p)
end

local Edge = class()
Edge.__eq = function(a, b) return (a.p1 == b.p1 and a.p2 == b.p2) end

function Edge:__init(p1, p2)
  self.p1, self.p2 = p1, p2
end

function Edge:same(otherEdge)
  return ((self.p1 == otherEdge.p1) and (self.p2 == otherEdge.p2))
  or ((self.p1 == otherEdge.p2) and (self.p2 == otherEdge.p1))
end

function Edge:length()
  return sqrt((self.p1.x - self.p2.x)^2+(self.p1.y - self.p2.y)^2)
end

local Point = class()
Point.__eq = function(a,b)  return (a.x == b.x and a.y == b.y) end

function Point:__init(x, y)
  self.x, self.y = x, y
end

function Point:isInCircle(cx, cy, r)
  local dx = (cx - self.x)
  local dy = (cy - self.y)
  return ((dx * dx + dy * dy) <= (r * r))
end

local Triangle = class()

function Triangle:__init(p1, p2, p3)
  self.p1, self.p2, self.p3 = p1, p2, p3
  self.e1, self.e2, self.e3 = Edge(p1, p2), Edge(p2, p3), Edge(p3, p1)
end
function Triangle:getSidesLength()
  return self.e1:length(), self.e2:length(), self.e3:length()
end

function Triangle:getCircumCircle()
  local x, y = self:getCircumCenter()
  local r = self:getCircumRadius()
  return x, y, r
end

function Triangle:getCircumCenter()
  local p1, p2, p3 = self.p1, self.p2, self.p3
  local D =  ( p1.x * (p2.y - p3.y) +
               p2.x * (p3.y - p1.y) +
             p3.x * (p1.y - p2.y)) * 2
  local x = (( p1.x * p1.x + p1.y * p1.y) * (p2.y - p3.y) +
             ( p2.x * p2.x + p2.y * p2.y) * (p3.y - p1.y) +
            ( p3.x * p3.x + p3.y * p3.y) * (p1.y - p2.y))
  local y = (( p1.x * p1.x + p1.y * p1.y) * (p3.x - p2.x) +
             ( p2.x * p2.x + p2.y * p2.y) * (p1.x - p3.x) +
            ( p3.x * p3.x + p3.y * p3.y) * (p2.x - p1.x))
  return (x / D), (y / D)
end

function Triangle:getCircumRadius()
  local a, b, c = self:getSidesLength()
  return ((a * b * c) / quatCross(a, b, c))
end

return function(polygon)
  local vertices = {}
  for i = 1, #polygon, 2 do
    vertices[#vertices+1] = Point(polygon[i], polygon[i+1])
  end
  local nvertices = #vertices
  if nvertices == 3 then
    return {polygon}
  end
  
  local minX, minY = vertices[1].x, vertices[1].y
  local maxX, maxY = minX, minY
  
  for i = 1, nvertices do
    local vertex = vertices[i]
    vertex.id = i
    if vertex.x < minX then minX = vertex.x end
    if vertex.y < minY then minY = vertex.y end
    if vertex.x > maxX then maxX = vertex.x end
    if vertex.y > maxY then maxY = vertex.y end
  end
  
  local dx, dy = (maxX - minX) * 1000, (maxY - minY) * 1000
  local deltaMax = max(dx, dy)
  local midx, midy = (minX + maxX) * 0.5, (minY + maxY) * 0.5
  
  local p1 = Point(midx - 2 * deltaMax, midy - deltaMax)
  local p2 = Point(midx, midy + 2 * deltaMax)
  local p3 = Point(midx + 2 * deltaMax, midy - deltaMax)
  p1.id, p2.id, p3.id = nvertices + 1, nvertices + 2, nvertices + 3
  vertices[p1.id] = p1
  vertices[p2.id] = p2
  vertices[p3.id] = p3
  
  local triangles = {}
  triangles[1] = Triangle(vertices[nvertices + 1],
                          vertices[nvertices + 2],
                          vertices[nvertices + 3]
                          )
  
  for i = 1, nvertices do
    
    local edges = {}
    local ntriangles = #triangles
    
    for j = #triangles, 1, -1 do
      local curTriangle = triangles[j]
      if vertices[i]:isInCircle(curTriangle:getCircumCircle()) then
        edges[#edges + 1] = curTriangle.e1
        edges[#edges + 1] = curTriangle.e2
        edges[#edges + 1] = curTriangle.e3
        remove(triangles, j)
      end
    end
    
    for j = #edges - 1, 1, -1 do
      for k = #edges, j + 1, -1 do
        if edges[j] and edges[k] and edges[j]:same(edges[k]) then
          remove(edges, j)
          remove(edges, k-1)
        end
      end
    end
    
    for j = 1, #edges do
      local n = #triangles
      triangles[n + 1] = Triangle(edges[j].p1, edges[j].p2, vertices[i])
    end
    
  end
  
  for i = #triangles, 1, -1 do
    local triangle = triangles[i]
    if (triangle.p1.id > nvertices or 
        triangle.p2.id > nvertices or 
       triangle.p3.id > nvertices) then
      remove(triangles, i)
    end
  end
  
  local final = {}
  
  for i = 1,#triangles do
    local triangle = triangles[i]
    final[i] = {triangle.p1.x, triangle.p1.y, triangle.p2.x, triangle.p2.y, triangle.p3.x, triangle.p3.y}
  end
  
  return final
  
end
