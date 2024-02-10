local lg = love.graphics

local v = -0.5
local mask = lg.newImage('mask.png')
local logo = lg.newImage('love-app-icon.png')

local shader = lg.newShader('shader.glsl')
shader:send('cutoff', v)
shader:send('mask', mask)
lg.setShader(shader)
local function clamp(v, min, max)
  return v < min and min or v > max and max or v
end

function love.update(dt)
  dt=dt/0.5
  if minus then
    v = clamp(v - dt, -0.01, 1)
  else
    v = clamp(v + dt, -0.01, 1)
  end
  shader:send('cutoff', v)
end

function love.draw()
  lg.draw(logo)
end

function love.mousereleased(k)
  minus = not minus
end

lg.setBackgroundColor(0.3,0.3,0.3)
