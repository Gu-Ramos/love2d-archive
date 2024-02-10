love.physics.debug = require('drawphys')
local RNG = love.math.newRandomGenerator(os.time())
local urutora = require('urutora')
local ui = urutora:new()

local button = urutora.button({
  x = 740, y = 20,
  w = 60, h = 60, cr = 30
})
button:setStyle({
  bgColor={.9,.9,.9},
})

local button2 = urutora.button({
  x = 740, y = 100,
  w = 60, h = 60, cr = 30
})
button2:setStyle({
  bgColor={.9,.9,.9},
})

button:action(function() love.keypressed('space'); end)
button2:action(function() love.keypressed('r'); end)

ui:add(button)
ui:add(button2)

local lp = love.physics
local lg = love.graphics

lp.setMeter(60)
local world = lp.newWorld(0,10*lp.getMeter(),true)

local stem = lp.newBody(world, 360,540, 'static')
lp.newFixture(stem, lp.newRectangleShape(1,360)):setMask(1)

local r1 = lp.newBody(world, 360, 270, 'dynamic')
lp.newFixture(r1, lp.newRectangleShape(1, 180), 1)
r1:setMass(0)
local r2 = lp.newBody(world, 360, 110, 'dynamic')
r2:setMass(0)
lp.newFixture(r2, lp.newRectangleShape(1, 180), 1)

local c1 = lp.newBody(world, 360,190, 'dynamic')
lp.newFixture(c1, lp.newCircleShape(10)):setMask(1)
c1:setMass(.1)
local c2 = lp.newBody(world, 360,20, 'dynamic')
lp.newFixture(c2, lp.newCircleShape(10)):setMask(1)
c2:setMass(.1)

local mouse = lp.newBody(world, 0,0, 'dynamic')
lp.newFixture(mouse, lp.newCircleShape(10))

local rev1 = lp.newRevoluteJoint(stem, r1, 360,360, false)
local rev2 = lp.newRevoluteJoint(r1, r2, 360,190, false)
local wld1 = lp.newWeldJoint(c1,r1, 360,190, false)
local wld2 = lp.newWeldJoint(c2,r2, 360,20, false)

local canvas = lg.newCanvas(720,720)
local shader = lg.newShader('shader.glsl')

function love.update(dt)
  world:update(dt)
  mouse:setPosition(love.mouse.getPosition())
  ui:update(dt)
end


local line = {360,-96}
lg.setBackgroundColor(0,0,0)
function love.draw()
  lp.debug(world)
  lg.setShader(shader)
  lg.draw(canvas)
  lg.setShader()

  lg.setCanvas(canvas)
    lg.setBlendMode('multiply', 'premultiplied')
    lg.setColor(1,1,1,0.99)
    lg.rectangle('fill',0,0,720,720)

    lg.setBlendMode('alpha', 'alphamultiply')
    lg.setColor(1,1,1)
    lg.setLineWidth(4)

    -- table.insert(line, c2:getX()+RNG:random(-10,10))
    -- table.insert(line, c2:getY()+RNG:random(-10,10))
    table.insert(line, c2:getX())
    table.insert(line, c2:getY())
    if #line > 8 then
      table.remove(line, 1)
      table.remove(line, 1)
    end
    lg.line(line)
    lg.setColor(1,1,1)
  lg.setCanvas()

  lg.circle('fill', c1:getX(), c1:getY(), c1:getMass()*10)
  lg.circle('fill', c2:getX(), c2:getY(), c2:getMass()*10)
  ui:draw()
  lg.print(love.timer.getFPS(), 10,10)
end

lg.setLineStyle('smooth')
lg.setLineJoin('bevel')

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  if k == 'space' then
    c2:applyLinearImpulse(RNG:random(100,500) * (RNG:random() <= 0.5 and -1 or 1) ,0)
  end

  if k == 'r' then
    r1:destroy()
    r2:destroy()
    c1:destroy()
    c2:destroy()
    r1 = lp.newBody(world, 360, 270, 'dynamic')
    lp.newFixture(r1, lp.newRectangleShape(1, 180), 1)
    r1:setMass(.1)
    r2 = lp.newBody(world, 360, 110, 'dynamic')
    r2:setMass(.1)
    lp.newFixture(r2, lp.newRectangleShape(1, 180), 1)

    c1 = lp.newBody(world, 360,190, 'dynamic')
    lp.newFixture(c1, lp.newCircleShape(10)):setMask(1)
    c1:setMass(.1)
    c2 = lp.newBody(world, 360,20, 'dynamic')
    lp.newFixture(c2, lp.newCircleShape(10)):setMask(1)
    c2:setMass(.1)

    rev1 = lp.newRevoluteJoint(stem, r1, 360,360, false)
    rev2 = lp.newRevoluteJoint(r1, r2, 360,190, false)
    wld1 = lp.newWeldJoint(c1,r1, 360,190, false)
    wld2 = lp.newWeldJoint(c2,r2, 360,20, false)
  end
end

function love.mousepressed(x, y, button) ui:pressed(x, y) end
function love.mousemoved(x, y, dx, dy) ui:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) ui:released(x, y) end
function love.textinput(text) ui:textinput(text) end
function love.wheelmoved(x, y) ui:wheelmoved(x, y) end

