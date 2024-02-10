local BASE = (...) .. "."
local Screen = require(BASE..'screen')
local lg = love.graphics
local tinsert = table.insert

local ui = setmetatable({},{__index=function(_,k) return suit[k]; end})

local counter = 0
local blend = 0
local screens = {}
local activeScreens = {}
local pmesh
local rmesh
local particles



local hsv2rgb, rgb2hsv = color.hsv_to_rgb, color.rgb_to_hsv

local max = {
  purple={h=329.2, s=92.3, v=71.8},
  red={h=26.6, s=91.1, v=96.1}
}
local min = {
  purple={h=220.5, s=64.9, v=27.4},
  red={h=0, s=89, v=50.6}
}

-- Purple
-- local og = {
--   {h=329.2, s=81.7, v=71.8},
--   {h=256.1, s=64.9, v=31.4},
--   {h=220.5, s=92.3, v=27.4},
--   {h=284.9, s=79.0, v=59.6},
-- }

-- Red
-- local og = {
--   {h=0.0,  s=89.0, v=50.6},
--   {h=23.0, s=90.7, v=84.7},
--   {h=26.6, s=91.0, v=96.1},
--   {h=10.5, s=91.1, v=61.6}
-- }

local velocity = {
  {h=0,v=0,s=0},
  {h=0,v=0,s=0},
  {h=0,v=0,s=0},
  {h=0,s=0,v=0},
  {h=0,s=0,v=0},
  {h=0,s=0,v=0}
}

function ui.updateMesh(w,h)
  pmesh = lg.newMesh({
      {0,0, 0,0, 0.718,0.131,0.432,1},
      {w,0, 1,0, 0.165,0.110,0.314,1},
      {w,h, 1,1, 0.021,0.103,0.274,1},
      {0,h, 0,1, 0.478,0.125,0.596,1},
  },'fan', 'static')
  rmesh = lg.newMesh({
      {0,0, 0,0, 0.506,0.051,0.051,1},
      {w,0, 1,0, 0.897,0.373,0.078,1},
      {w,h, 1,1, 0.961,0.475,0.086,1},
      {0,h, 0,1, 0.616,0.153,0.055,1},
  }, 'fan', 'static')

  particles = lg.newParticleSystem(Assets.particles.sqr, 500)
  particles:setEmissionRate(5)
  particles:setEmissionArea('normal', w/2, h/2)
  particles:setLinearAcceleration(15, 30, -15, -15)
  particles:setParticleLifetime(10, 15)
  particles:setRotation(-45*math.pi/180, 45*math.pi/180)
  particles:setColors(
                          1, 1, 1, 0,
                          1, 1, 1, 0.8,
                          1, 1, 1, 0
                          )
  particles:setSizes(1.5*Transform.sc, 0.4*Transform.sc)
  particles:setSizeVariation(1)

  pmesh:setVertexMap(1,2,3,4)
  rmesh:setVertexMap(1,2,3,4)
end

local bgColor = 'purple'

function ui.newScreen(name, theme)
  local screen = Screen(theme)

  if name then
    screens[name] = screen
  else
    tinsert(screens, screen)
  end

  return screen
end

function ui.getScreen(name)
  return screens[name]
end

function ui.activateScreen(name)
  screens[name].active = true
  activeScreens[name] = screens[name]
end

function ui.deactivateScreen(name)
  screens[name].active = false
end

function ui.getActiveList()
  local list = {}
  for k,_ in pairs(activeScreens) do
    list[#list+1] = k
  end
  return list
end

function ui.rmvScreen(name)
  screens[name] = nil
  collectgarbage('collect')
end

function ui.getBlend() return blend; end
function ui.getBgColor() return bgColor; end

local function clamp(x, l, h) return x < l and l or (x > h and h or x); end
function ui.update(dt)
  for _,v in pairs(activeScreens) do
    v:update(dt)
  end
  blend = blend < 1 and blend + dt or blend

  -- Update mesh gradient
  -- Calculates each vertice
  local vertices = {}
  -- Classic black background with particles
  if bgColor == 'black' then particles:update(dt); goto skip; end
  if blend < 1 and bgColor == 'purple' then particles:update(dt); end
  for i = 1, 4 do
    local vx,vy,vu,vv, r,g,b
    if bgColor == 'purple' then
      vx,vy,vu,vv, r,g,b = pmesh:getVertex(i)
    elseif bgColor == 'red' then
      vx,vy,vu,vv, r,g,b = rmesh:getVertex(i)
    end
    local h,s,v = rgb2hsv(r,g,b)

    local x,y,z
    if bgColor == 'purple' then
      x,y,z = h - 274.5, s - 78.6, v - 49.6

      x = RNG:randomNormal(5) + -sin(x/35)*5
      y = RNG:randomNormal(5) + -sin(y/17)*2.5
      z = RNG:randomNormal(5) + -sin(z/11)*1.5
    elseif bgColor == 'red' then
      x,y,z = h - 13.3, s - 90, v - 73.3

      x = RNG:randomNormal(5) + -sin(x/10)*1.5
      y = RNG:randomNormal(1) + -sin(y)
      z = RNG:randomNormal(5) + -sin(z/15)*2.3
    end

    velocity[i].h = velocity[i].h + x/8
    velocity[i].s = velocity[i].s + y/8
    velocity[i].v = velocity[i].v + z/8

    h = clamp(h + velocity[i].h * dt, min[bgColor].h, max[bgColor].h)
    s = clamp(s + velocity[i].s * dt, min[bgColor].s, max[bgColor].s)
    v = clamp(v + velocity[i].v * dt, min[bgColor].v, max[bgColor].v)

    r,g,b = hsv2rgb(h,s,v)

    vertices[i] = {vx,vy,vu,vv, r,g,b}
  end
  -- replace mesh vertices (this is theoretically more efficient than setVertex)
  if bgColor == 'purple' then
    pmesh:setVertices(vertices)
  elseif bgColor == 'red' then
    rmesh:setVertices(vertices)
  end

  ::skip::

  for name,screen in pairs(activeScreens) do
    if screen.active then
      if screen.opacity < 1 then
        screen.opacity = screen.opacity + dt*4
      end
    elseif not screen.active then
      if screen.opacity > 0 then
        screen.opacity = screen.opacity - dt*4
      else
        activeScreens[name] = nil
      end
    end
  end


end

function ui.changeColor(color)
  bgColor = color
  blend = 0
end

function ui.draw()
  local r,g,b,a = lg.getColor()
  for _,screen in pairs(activeScreens) do
    lg.setColor(1,1,1,screen.opacity)
    screen:draw()
  end
  lg.setColor(r,g,b,a)
end

function ui.textinput(t)
  for _,screen in pairs(activeScreens) do
    screen.instance:textinput(t)
  end
end

function ui.keypressed(t)
  for _,screen in pairs(activeScreens) do
    screen.instance:keypressed(t)
  end
end

function ui.drawBG()
  local r,g,b,a = lg.getColor()
  if bgColor == 'purple' then
    if blend < 1 then
      lg.setColor(1,1,1, 1-blend)
      local x,y = lg.getDimensions()
      lg.draw(particles, x/2,y/2)
      lg.setColor(1,1,1, blend)
    end
    lg.draw(pmesh,0,0)
  elseif bgColor == 'red' then
    if blend < 1 then
      lg.setColor(1,1,1, 1-blend)
      lg.draw(pmesh, 0,0)
      lg.setColor(1,1,1, blend)
    end
    lg.draw(rmesh,0,0)
  elseif bgColor == 'black' then
    if blend < 1 then
      lg.setColor(1,1,1, 1-blend)
      lg.draw(rmesh, 0,0)
      lg.setColor(1,1,1, blend)
    end
    local x,y = lg.getDimensions()
    lg.draw(particles, x/2, y/2)
  end
  lg.setColor(r,g,b,a)
end

return ui
