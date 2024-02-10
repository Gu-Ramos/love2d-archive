local follow = 4
local center = 4

local T, B, C, D = 1,4,0,1

function easeOutQuint(time, beggining, change, duration)
  time = time / duration - 1
  return change * (time^5 + 1) + beggining
end

local sqrt = math.sqrt
function pos(x)
  if x > 0 then
    return sqrt(1 - (x - 1)^2)
  else
    return -sqrt(1 - (x + 1)^2)
  end
end

local cos = math.cos
function scale(x)
  return ((cos(x*2.4) + 1) / 2) + (x^2 / 3.2)
end

function love.load()
  Card = love.graphics.newImage('White_front.png')
  Font = love.graphics.newFont('Inter-Medium.ttf', 47)
end

function love.update(dt)
  if love.keyboard.isDown 'w' then center = center + .05; end
  if love.keyboard.isDown 's' then center = center - .05; end
  if love.keyboard.isDown 'd' then center = center + .001; end
  if love.keyboard.isDown 'a' then center = center - .001; end
  if center < 0 then center = 0; elseif center > n then center = n; end
  
  T = ( T < D and T + dt ) or D
  center = easeOutQuint(T, B, C, D)
end

-- local n = i - center
-- local x = pos(1/10 * (n))
-- local s = scale(1/10 * (n))
-- love.graphics.draw(Card, 960 + 450 * x - 250*.4*s, 160 + (1-s)*(800*0.4), 0, 0.4*s)
-- if ( c == 1 and ((center*2 - i) <= n) ) or ( (center - i) >= 0 ) then:
n = 10

function love.draw()
  for i = (n-1) - center, 0.01, -1 do
    local x = pos(1/n * i)
    local s = scale(1/n * i)
    local a = -(1/n * i)^2 + 1
    
    local px,py = 960 + 500 * x - 250*.4*s, 680 + (1-s)*(800*0.4)
    love.graphics.setColor(a,a,a,1)
    love.graphics.draw(Card, px, py, 0, 0.4*s)
    love.graphics.setColor(0.1*a,0.1*a,0.1*a,1)
    love.graphics.printf('Esta é uma carta.', Font, px, py, 400, 'left', 0, 0.4*s, 0.4*s, -50, -77)
  end
  for i = -center, 0.01, 1 do
    local x = pos(1/n * (i))
    local s = scale(1/n * (i))
    local a = -(1/n * i)^2 + 1
    
    local px,py = 960 + 500 * x - 250*.4*s, 680 + (1-s)*(800*0.4)
    love.graphics.setColor(a,a,a,1)
    love.graphics.draw(Card, px, py, 0, 0.4*s)
    love.graphics.setColor(0.1*a,0.1*a,0.1*a,1)
    love.graphics.printf('Esta é uma carta.', Font, px, py, 400, 'left', 0, 0.4*s, 0.4*s, -50, -77)
  end
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(love.timer.getFPS(), 10,10)
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit();
  elseif key == 'right' then
    follow = follow + 1
  elseif key == 'left' then
    follow = follow - 1
  end
  
  if follow < 0 then follow = 0; elseif follow > n-1 then follow = n-1; end
  
  T = 0
  B = center
  C = follow - center
  D = 0.25
end



