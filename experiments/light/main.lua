local Lighter = require 'lighter'

local lighter = Lighter()
local function updateScaling(wx,wy)
  if wx<wy then wx,wy = wy,wx; end

  if wx ~= __WINX__ or wy ~= __WINY__ then
    __WINX__ = wx
    __WINY__ = wy

    local sc = 16/9*wx > wy and wy/576 or wx/1024

    __GSCALE__ = sc
    __GTLX__, __GTLY__ = wx/2-1024*sc/2, wy/2-576*sc/2
    __GTRANSFORM__ = love.math.newTransform(wx/2-1024*sc/2, wy/2-576*sc/2, 0,
                                            sc,sc,0,0)
    __R0X__, __R0Y__ = __GTRANSFORM__:inverseTransformPoint(0,0)
    __R1X__, __R1Y__ = __GTRANSFORM__:inverseTransformPoint(wx,wy)
    collectgarbage('collect')
  end
end
updateScaling(love.window.getMode())


local wall = {
  100, 100, 150,100,
  150, 150, 100,150
}
local wall2 = {
  300, 300, 350,300,
  350, 350, 300,350
}
local wall3 = {
  300, 100, 350,100,
  350, 150, 300,150
}
local wall4 = {
  100, 300, 150,300,
  150, 350, 100,350
}

local wall5 = {
  600, 400, 700,400,
  600,500
}

lighter:addPolygon(wall)
lighter:addPolygon(wall2)
lighter:addPolygon(wall3)
lighter:addPolygon(wall4)
lighter:addPolygon(wall5)
-- lighter:addPolygon(circle)

local lightX, lightY = 500, 500

-- addLight signature: (x,y,radius,r,g,b,a)
local light = lighter:addLight(lightX, lightY, 2400, 0.371, 0.114, 0.738)

function love.update(dt)
  updateScaling(love.window.getMode())
  lightX, lightY = __GTRANSFORM__:inverseTransformPoint(love.mouse.getPosition())
  lighter:updateLight(light, lightX, lightY)
end
love.graphics.setLineWidth(2)
function love.draw()
  love.graphics.applyTransform(__GTRANSFORM__)
  lighter:drawLights()
  love.graphics.polygon('line', wall)
  love.graphics.polygon('line', wall2)
  love.graphics.polygon('line', wall3)
  love.graphics.polygon('line', wall4)
  love.graphics.polygon('line', wall5)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(love.timer.getFPS(),10,10)
end
function love.keypressed(k) if k == 'escape' then love.event.quit(); end; end

-- Clean up
-- lighter:removeLight(light)
-- lighter:removePolygon(lighterWall)
