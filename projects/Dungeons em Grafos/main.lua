function love.load()
  GRID_WIDTH = 72
  lg = love.graphics
  TRANSFORM = love.math.newTransform()
  SCALE = 1

  utils = require("lib.utils")
  Class = require("lib.classy")
  Grafo = require("obj.Grafo")

  grafo = Grafo()
  grafo:generate()
end

function love.update(dt)
  local speed = 500

  if love.keyboard.isDown("a") then TRANSFORM:translate(speed*dt, 0) end
  if love.keyboard.isDown("d") then TRANSFORM:translate(-speed*dt, 0) end
  if love.keyboard.isDown("w") then TRANSFORM:translate(0, speed*dt) end
  if love.keyboard.isDown("s") then TRANSFORM:translate(0, -speed*dt) end

  if love.keyboard.isDown("q") then SCALE = SCALE - 0.5*dt end
  if love.keyboard.isDown("e") then SCALE = SCALE + 0.5*dt end
end

function love.draw()
  lg.push()
  lg.applyTransform(TRANSFORM)
  love.graphics.scale(SCALE)
  -- grafo:generate()
  grafo:draw()
  -- utils.drawGrid(GRID_WIDTH)
  lg.pop()
end

function love.keypressed(k)
  if k == "space" then
    grafo:generate()
  end
end
