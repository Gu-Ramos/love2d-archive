x = true
love.window.setFullscreen(true)

function love.draw()
  if x then
    love.graphics.setColor(1,1,1,1)
  else
    love.graphics.setColor(0,0,0,0)
  end
  love.graphics.rectangle('fill', 0,0,love.graphics.getDimensions())
end

function love.keypressed()
  x = not x
end
