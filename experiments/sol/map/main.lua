rand = love.math.newRandomGenerator()
rand:setSeed(os.time())
Batteries = require('batteries'):export()
log = require('log')
require('snippets')

local newpoly = require('rand_poly')
local p1 = newpoly(3000,3000,900,600,16, 800,200, 3000,3000)
local p = {p1[7],p1[8],p1[9],p1[10],p1[11],p1[12],p1[13],p1[14]}
local p2 = complete_poly(5, p, 3000,3000, 900,600, 16, 900,600,16, 800,200, 3000,3000)

local lg = love.graphics
lg.setLineJoin('none')

function love.draw()
  lg.scale(0.1)
  lg.setLineWidth(20)
  lg.polygon('line', p1)
  lg.setLineWidth(20)
  lg.polygon('line', p2)
  lg.setColor(1,0,0,1)
  lg.setColor(1,1,1,1)
end
function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  if k == 'space' then
    p1 = newpoly(3000,3000,900,600,16, 800,200, 3000,3000)
    local r = rand:random(3,3)*2
    local p = {p1[r-3],p1[r-2],p1[r-1],p1[r],p1[r+1],p1[r+2],p1[r+3],p1[r+4]}
    p2 = complete_poly(r/2, p, 3000,3000, 900,600, 16, 900,600,16, 800,200, 3000,3000)
  end
end
