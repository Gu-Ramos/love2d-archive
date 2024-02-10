--[[
  What it will do:
    - Create an anchor (the grappling hook's hook) on the mouse position
    - Reset the player velocity and start to move it towards the anchor
    - Once the player lets go of the anchor the anchor will be destroyed
]]--

love.physics.draw = require('drawphys') -- love.physics.draw stolen from https://github.com/a327ex/windfield

local lp = love.physics
local lg = love.graphics

-- Creating the physics world, player, and floor
lp.setMeter(25)
local world = lp.newWorld(0,20*25, false)
local player = lp.newBody(world, 400,400, 'dynamic')
lp.newFixture(player, lp.newCircleShape(25), 1):setFriction(18912371297)
local floor = lp.newBody(world, 400,750, 'static')
lp.newFixture(floor, lp.newRectangleShape(800,100), 1)

local anchor
local weld

function love.update(dt)
  world:update(dt)
  if love.keyboard.isDown('a') then player:applyForce(-2000,0); end
  if love.keyboard.isDown('d') then player:applyForce(2000,0); end
  if anchor then
    local px,py = player:getPosition()
    local ax,ay = anchor:getPosition()
    if #anchor:getContacts() >= 1 and ((ax-px)^2 + (ay-py)^2)^0.5 <= 32 then
      weld = lp.newWeldJoint(player,anchor,px,py)
    else
      -- Moves the player towards the anchor
      local angle = math.atan2(ay-py, ax-px)
      player:applyForce(15000*math.cos(angle), 15000*math.sin(angle))
    end
  end
end

lg.setLineWidth(4)
function love.draw()
  lp.draw(world)
  if anchor then
    lg.line(player:getX(), player:getY(), anchor:getX(), anchor:getY())
  end
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  if k == 'space' or k == 'a' or k == 'd' then
    if k == 'space' then player:applyLinearImpulse(0,-1000); end -- jump
    player:setGravityScale(1)

    -- if the player jumps, let go of the anchor, destroy it
    if anchor then
      anchor:destroy()
      anchor:release()
      anchor = nil
      if weld then weld:release(); weld = nil; end
    end
  end
end

function love.mousepressed(x,y)
  if anchor then
    anchor:destroy()
    anchor:release()
    anchor = nil
    if weld then weld:release(); weld = nil; end
  end
  player:setLinearVelocity(0,0)                      -- Resets the player velocity
  player:setGravityScale(0)
  anchor = lp.newBody(world, x,y, 'static')          -- Creates the anchor
  lp.newFixture(anchor, lp.newCircleShape(5), 1)
end

