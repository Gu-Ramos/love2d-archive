function love.load()
  chr = 'Player'
  x, y = 10,10
end

function love.update(dt)
  if love.keyboard.isDown('w') then y = y - dt*100; end
  if love.keyboard.isDown('a') then x = x - dt*100; end
  if love.keyboard.isDown('s') then y = y + dt*100; end
  if love.keyboard.isDown('d') then x = x + dt*100; end
end

function love.draw()
  love.graphics.rectangle('line', 100, 100, 100, 100)
  love.graphics.print(chr, x,y)
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit(); end
end

