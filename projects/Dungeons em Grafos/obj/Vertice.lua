local vertice = Class("Vértice")

local colors = {
  raiz  = utils.getColorHEX("#FFCC33"),
  meio  = utils.getColorHEX("#FF2244"),
  fim_vizinhos = utils.getColorHEX("#44FF66"),
  fim_chance = utils.getColorHEX("#FF66BB"),
  fim_profundidade = utils.getColorHEX("#4466FF"),
}

local segments = {
  raiz  = 8,
  meio  = 100,
  fim_vizinhos = 3,
  fim_chance = 4,
  fim_profundidade = 4,
}

--------------- AUX FUNCTIONS ---------------

local function gridToGlobal(x,y)
  local fx,fy = love.graphics.getDimensions()
  fx = fx/2; fy = fy/2

  return fx + x*GRID_WIDTH, fy + y*GRID_WIDTH
end

--------------- METHODS ---------------
-- Constructor
function vertice:init(x,y, type, parent, depth, neighbours)
  self.x = x
  self.y = y
  self.type = type or "meio"
  self.parent = parent
  self.depth = depth or 0
  self.neighbours = neighbours or {}
  
  -- for search algorithm purposes
  self.portals = {}
  self._depth_ = 0
  self._cor_ = 0
  self._previous_ = nil
end


function vertice:hasNeighbour(n)
  for _, v in ipairs(self.neighbours) do
    if v == n then return true; end
  end
  return false
end


function vertice:addNeighbour(n)
  -- não adicionar vizinho se ele já estiver na lista de vizinhos.
  if not self:hasNeighbour(n) then
    table.insert(self.neighbours, n)
  end
end

function vertice:addNeighbours(n)
  for _, v in pairs(n) do
    self:addNeighbour(v)
  end
end


function vertice:getNeighbouringCells()
  local n_cells = {}
  for i = 0, 8 do
    if i == 4 then goto continue; end

    local x = i%3 - 1
    local y = math.floor(i/3) - 1
    table.insert(n_cells, {
      x = self.x + x, 
      y = self.y + y,
      dir = {x=x, y=y}
    })

    ::continue::
  end
  return n_cells
end


function vertice:draw()
  local previous_color = {lg.getColor()}
  local previous_line_width = lg.getLineWidth()
  local seg = segments[self.type] or segments["meio"]
  local color = colors[self.type] or colors["meio"]
  local sx, sy = gridToGlobal(self.x, self.y)

  -- Draw self on top
  lg.setColor(color)
  lg.circle("fill", sx, sy, 24, seg)
  lg.setColor(1,1,1)
  lg.print(tostring(self.depth), sx-4,sy-8)

  lg.setLineWidth(previous_line_width)
  lg.setColor(previous_color)
end

function vertice:drawConnections()
  local previous_color = {lg.getColor()}
  local previous_line_width = lg.getLineWidth()
  local color = colors[self.type] or colors["meio"]

  -- Draw connections to neighbours
  lg.setColor(color)
  for _, v in ipairs(self.neighbours) do
    local sx, sy = gridToGlobal(self.x, self.y)
    local vx, vy = gridToGlobal(v.x, v.y)

    lg.line(sx,sy, vx,vy)
  end

  lg.setLineWidth(previous_line_width)
  lg.setColor(previous_color)
end

return vertice
