Grid = require('jumper.grid')
Pathfinder = require('jumper.pathfinder')
local lg = love.graphics

-- First, set a collision map
local rng = love.math.newRandomGenerator(os.time())

local astray = require('astray')

-- This maze generator can only generate uneven maps.
-- To get a 39x39 maze you need to Input
local height, width = 100, 100
-- Astray:new(width/2-1, height/2-1, changeDirectionModifier (1-30), sparsenessModifier (25-70), deadEndRemovalModifier (70-99) ) | RoomGenerator:new(rooms, minWidth, maxWidth, minHeight, maxHeight)
local generator = astray.Astray:new( height/2-1, width/2-1, 30, 70, 50, astray.RoomGenerator:new(4, 2, 4, 2, 4) )

local dungeon = generator:Generate()
local map = generator:CellToTiles( dungeon )

local startx, starty
local endx, endy
for i = 0, 98 do
  for ii = 0, 98 do
    if map[i][ii] == 0 then startx, starty = ii,i; break; end
  end
end

for i = 98, 0, -1 do
  for ii = 98, 0, -1 do
    if map[i][ii] == 0 then endx, endy = ii,i; break; end
  end
end

print(startx,starty)
print(endx,endy)

local Canvas = lg.newCanvas(800,800)
local walkable = 0
local size = 98
local rsize = 800/size

local function newMap()
  lg.setCanvas(Canvas)
  lg.clear()

  for i = 1, size do
    for ii = 1, size do
      local cell = map[i][ii]
      if cell == 1 then lg.setColor(1,1,1,1);
      else lg.setColor(0.1,0.1,0.1,1); end
      lg.rectangle('fill', (ii-1)*rsize, (i-1)*rsize, rsize, rsize)
    end
  end

  local clock = os.clock
  local timer = clock()

  local grid = Grid(map)
  local myFinder = Pathfinder(grid, 'ASTAR', walkable)

  local path = myFinder:getPath(startx, starty, endx, endy)
  print(clock()-timer)

  if path then
    lg.setColor(1,0,0,1)
    for _, node in ipairs(path._nodes) do
      lg.rectangle('fill', (node:getX()-1)*rsize, (node:getY()-1)*rsize, rsize,rsize)
    end
  end

  lg.setColor(1,1,1,1)
  lg.setCanvas()
end

newMap()

local floor = math.floor

love.mouse.setVisible(false)

function love.draw()
  lg.draw(Canvas)

  local x,y = love.mouse.getPosition()
  x,y = floor(x * (size/800)), floor(y * (size/800))
  lg.rectangle('fill', (x-1)*rsize, (y-1)*rsize, rsize*2, rsize*2)

  if love.mouse.isDown(1) then
    lg.setCanvas(Canvas)
    lg.rectangle('fill', (x-1)*rsize, (y-1)*rsize, rsize*2, rsize*2)
    map[y][x] = 1
    map[y][x+1] = 1
    map[y+1][x+1] = 1
    map[y+1][x] = 1
    lg.setCanvas()
  elseif love.mouse.isDown(2) then
    lg.setColor(0.1,0.1,0.1,1)
    lg.setCanvas(Canvas)
    lg.rectangle('fill', (x-1)*rsize, (y-1)*rsize, rsize*2, rsize*2)
    map[y][x] = 0
    map[y][x+1] = 0
    map[y+1][x+1] = 0
    map[y+1][x] = 0
    lg.setCanvas()
    lg.setColor(1,1,1,1)
  end

  lg.print(love.timer.getFPS(), 10,10)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  if k == 'space' then newMap(); end
end
