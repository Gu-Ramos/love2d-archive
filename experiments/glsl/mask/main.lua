local lg = love.graphics

local v = -0.5
local mask = lg.newImage('masks/pokeball.png')
local rose = lg.newImage('rose.png')

local shader = lg.newShader('shader.glsl')
shader:send('cutoff', v)
shader:send('mask', mask)
lg.setShader(shader)
local function clamp(v, min, max)
  return v < min and min or v > max and max or v
end

function love.update(dt)
  if minus then
    v = clamp(v - dt, -0.01, 1)
  else
    v = clamp(v + dt, -0.01, 1)
  end
  shader:send('cutoff', v)
end

function love.draw()
  lg.draw(rose,10,10)
end

function love.mousereleased(k)
  if k == 'escape' then love.event.quit(); end
  minus = not minus
end

