return function()

require('lib.helpers')
Class = require('lib.classic')
lg = love.graphics
ls = love.scale

Maze_class = require('maze')
Canvas = lg.newCanvas(lg.getDimensions())

local clock = os.clock
local timer = clock()
maze = Maze_class(101,101)
maze:generate()
print(clock()-timer)

s = 800/math.max(maze:getDimensions())

love.resize(love.graphics.getDimensions())

function drawMaze()
  lg.clear()
  for i = 1, #maze.map do
    for ii = 1, #maze.map[i] do
      if maze.map[i][ii] == 0 then lg.setColor(0,0,0); else lg.setColor(1,1,1); end
      lg.rectangle('fill', s*(ii-1), s*(i-1), s,s)
    end
  end
end

Canvas:renderTo(drawMaze)

end
