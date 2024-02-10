love.load = require('load')

function love.update(dt) -- luacheck: ignore
  -- Update game here
end

function love.draw()
  lg.push()
  lg.applyTransform(ls.transform)
    -- Draw game here
  lg.pop()

  lg.print(love.timer.getFPS(), 10,10)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
end
