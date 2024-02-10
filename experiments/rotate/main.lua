love.load = require('load')

function love.update(dt) -- luacheck: ignore
  for i = 1, #Obj do
    Obj[i]:update(dt)
  end
end

function love.draw()
  lg.push()
  lg.applyTransform(ls.transform)
    for i = 1, #Obj do
      Obj[i]:draw()
    end
  lg.pop()

--   lg.print(love.timer.getFPS(), 10,10)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
end
