-- Maze generation algorithm based on Prim's algorithm. Taken from:
-- https://en.wikipedia.org/wiki/Maze_generation_algorithm#Randomized_Prim's_algorithm

local m = Class:extend()

local rng = love.math and love.math.newRandomGenerator(os.time())

local remove = table.remove
local insert = table.insert

function m:new(w,h)
  assert(w > 2 and h > 2, 'Width and height needs to be higher than 2.')
  w = w % 2 == 1 and w or w - 1
  h = h % 2 == 1 and h or h - 1
  self.w = w
  self.h = h

  -- Creates the maze, 1 = wall, 0 = path
  local maze = {}
  for i = 1, h do
    maze[i] = {}
    for ii = 1, w do
      maze[i][ii] = 1
    end
  end

  self.map = maze

  return self
end

function m:getWidth() return self.w; end
function m:getHeight() return self.h; end
function m:getDimensions() return self.w, self.h; end

function m:getMapCopy()
  local copy = {}
  local map = self.map

  for i = 1, #map do
    copy[i] = {}
    for ii = 1, #map[i] do
      copy[i][ii] = map[i][ii]
    end
  end

  return copy
end

function m:getWalls(x,y)
  local walls = {}
  if self.map[y-1] then
    walls[1] = self.map[y-1][x] == 1 and {x,y-1, {0,-1}} or false
  else
    walls[1] = false
  end
  if self.map[y+1] then
    walls[3] = self.map[y+1][x] == 1 and {x,y+1, {0, 1}} or false
  else
    walls[3] = false
  end
  walls[2] = self.map[y][x+1] == 1 and {x+1,y, {1, 0}} or false
  walls[4] = self.map[y][x-1] == 1 and {x-1,y, {-1,0}} or false
  for i = 1, 4 do if not walls[i] then remove(walls, i); end; end
  for i = 1, 4 do if not walls[i] then remove(walls, i); end; end
  return walls
end

function m:generate(algorithm)
  algorithm = algorithm or 'prim'
  if algorithm == 'prim' then
    --[[
      1. Start with a grid full of walls.
      2. Pick a cell, mark it as part of the maze. Add the walls of the cell to the wall list.
      3. While there are walls in the list:
        1. Pick a random wall from the list. If only one of the two cells that the wall divides is visited, then:
          1. Make the wall a passage and mark the unvisited cell as part of the maze.
          2. Add the neighboring walls of the cell to the wall list.
        2. Remove the wall from the list.
    --]]
    local maze_walls = {}
    local maze = self:getMapCopy()

    -- Select random first cell
    local x = 0
    local y = 0
    while y % 2 == 0 do y = rng:random(1, #maze); end
    while x % 2 == 0 do x = rng:random(1, #maze[y]); end

    -- Add the first cell's walls to the wall list
    local cell_walls = self:getWalls(x,y)
    for i = 1, #cell_walls do
      insert(maze_walls, cell_walls[i])
    end

    while #maze_walls > 0 do
      local w = rng:random(1, #maze_walls)
      local wall = maze_walls[w]
      x,y = wall[1]+wall[3][1], wall[2]+wall[3][2]
      if maze[y][x] == 1 then
        maze[wall[2]][wall[1]] = 0
        maze[y][x] = 0

        cell_walls = self:getWalls(x,y)
        for i = 1, #cell_walls do
          insert(maze_walls, cell_walls[i])
        end
      end
      remove(maze_walls, w)
    end

    self.map = maze
  elseif algorithm == 'depth' then -- luacheck: ignore
    --[[
      1. Choose the initial cell, mark it as visited and push it to the stack
      2. While the stack is not empty
        1. Pop a cell from the stack and make it a current cell
        2. If the current cell has any neighbours which have not been visited
          1. Push the current cell to the stack
          2. Choose one of the unvisited neighbours
          3. Remove the wall between the current cell and the chosen cell
          4. Mark the chosen cell as visited and push it to the stack
    --]]
  elseif algorithm == 'kruksal' then -- luacheck: ignore
    --[[
      1. Create a list of all walls, and create a set for each cell, each containing just that one cell.
      2. For each wall, in some random order:
         1. If the cells divided by this wall belong to distinct sets:
          1. Remove the current wall.
          2. Join the sets of the formerly divided cells.
    ]]
  elseif algorithm == 'aldous' then
    --[[
      1. Pick a random cell as the current cell and mark it as visited.
      2. While there are unvisited cells:
        1. Pick a random neighbour.
        2. If the chosen neighbour has not been visited:
          1. Remove the wall between the current cell and the chosen neighbour.
          2. Mark the chosen neighbour as visited.
          3. Make the chosen neighbour the current cell.
    --]]
  end

  return self.map
end

return m
