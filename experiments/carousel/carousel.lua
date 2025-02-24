for i = (n-1) - center, 0.01, -1 do
  local x = pos(1/n * i)
  local s = scale(1/n * i)
  local a = -(1/n * i)^2 + 1
  
  love.graphics.setColor(a,a,a,1)
  love.graphics.draw(Card, 640 + 300 * x - 250*.3*s, 380 + (1-s)*(800*0.3), 0, 0.3*s)
end
for i = -center, 0.01, 1 do
  local x = pos(1/n * (i))
  local s = scale(1/n * (i))
  local a = -(1/n * i)^2 + 1
  
  love.graphics.setColor(a,a,a,1)
  love.graphics.draw(Card, 640 + 300 * x - 250*.3*s, 380 + (1-s)*(800*0.3), 0, 0.3*s)    
end
