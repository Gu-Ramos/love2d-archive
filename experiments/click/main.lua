love.load = require('load')

local t = 0
local x = 0

function love.update(dt) -- luacheck: ignore
  if t < 5 and x > 0 then
    t = t + dt
  end
end

function love.draw()
  lg.print(love.timer.getFPS(), 10,10)
  lg.print(x, 10, 25)
  if t > 5 then
    lg.print(x/5, 10, 40)
  end
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
end

function love.mousepressed()
  if t < 5 then
    x = x+1
  end
end
