return function()

require('lib.helpers')
Class = require('lib.classic')
lg = love.graphics
ls = love.scale

Square = require('sqr')
Obj = {
  Square(400,400, 100,100, 1, 2),
  Square(400,400, 100,100, -1, 2),
  Square(400,400, 100,100, 1.2, 2.4),
  Square(400,400, 100,100, -1.2, 2.4),
  Square(400,400, 100,100, 1.4, 2.8),
  Square(400,400, 100,100, -1.4, 2.8),
}

lg.setColor(1,0,0)

love.resize(love.graphics.getDimensions())

end
