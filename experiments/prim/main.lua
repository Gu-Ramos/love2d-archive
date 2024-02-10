love.load = require('load')

function love.update(dt) -- luacheck: ignore
  -- Update game here
end

function love.draw()
  lg.push()
  lg.scale(0.5)
  lg.draw(Canvas)
  lg.setColor(1,0,0)
  lg.print(love.timer.getFPS(), 10,10)
  lg.setColor(1,1,1)
  lg.pop()
end

love.graphics.setBackgroundColor(0.2,0.2,0.2)

function love.mousereleased()
 
    maze = Maze_class(51,51)
    maze:generate()
    s = 800/math.max(maze:getDimensions())

    Canvas:renderTo(drawMaze)
end
