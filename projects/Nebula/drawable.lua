local Drawable = Class:extend()

local NONE = function() end

local function getOpt(q,x,y,r,xs,ys,a)
  if a then return q,x,y,r,xs,ys,a; else return false, q,x,y,r,xs,ys,a; end
end
local function clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end
local function smooth(a, b, amount)
	local t = clamp(amount, 0, 1)
	return a + (b - a) * (t * t * (3 - 2 * t))
end


function Drawable:new(img, quad, x,y, r, xs, ys, a, font)
  quad,x,y,r,xs,ys,a = getOpt(quad,x,y,r,xs,ys,a)
  local string

  if quad and type(quad) ~= 'userdata' then
    string, quad = quad, nil
    local text = lg.newText(font)
    text:setf(string, 440, 'left')
    self.text = text
    self.font = font
  end

  self.img = img
  self.quad = quad
  self.x  = x -- x coord
  self.y  = y -- y coord
  self.r  = r -- rotation
  self.xs = xs -- x scale
  self.ys = ys -- y scale
  self.a  = a -- alpha

  if quad then
    local x,y -- luacheck: ignore
    x,y, self.ox,self.oy = quad:getViewport()
    self.ox,self.oy = self.ox/2,self.oy/2
  else
    self.ox,self.oy = img:getDimensions()
    self.ox,self.oy = self.ox/2,self.oy/2
  end

  return self
end


function Drawable:associate(t,i)
  if self.association then
    tremove(DrawList[self.association[1]], self.association[2])
  end
  self.association = {t,i}
  tinsert(DrawList[t], i, self)
end


function Drawable:update(dt)
end


function Drawable:setTransform(ease, time, onupdate, x,y,r,xs,ys,a)
  Flux.to(
    self, time or 1,
    {
      x = x or self.x,
      y = y or self.y,
      r = r or self.r,
      xs = xs or self.xs,
      ys = ys or self.ys,
      a = a or self.a,
    }
  ):delay(0.1):ease(ease or 'quadout'):onupdate(onupdate or NONE)
end


function Drawable:setTransformNow(x,y,r,xs,ys,a)
  self.x = x or self.x
  self.y = y or self.y
  self.r = r or self.r
  self.xs = xs or self.xs
  self.ys = ys or self.ys
  self.a = a or self.a
end


function Drawable:draw()
  local r,g,b,a = lg.getColor()
  lg.setColor(1,1,1,self.a)
  local xs,ys,ox,oy = self.xs,self.ys,self.ox,self.oy
  if self.quad then
    lg.draw(self.img, self.quad, self.x+ox, self.y+oy, self.r, xs,ys,ox,oy)
  else
    lg.draw(self.img, self.x+ox, self.y+oy, self.r, xs,ys,ox,oy)
    if self.text and xs >= 0 and ys >= 0 then
      local pfont = lg.getFont()
      lg.setFont(self.font)
      lg.draw(self.text, self.x+ox+15, self.y+oy+15, self.r, xs,ys,ox-15,oy-15)
      lg.setFont(pfont)
    end
  end
  lg.setColor(r,g,b,a)
end


local clear = table.clear
function Drawable:destroy()
  if self.association then
    tremove(DrawList[self.association[1]], self.association[2])
  end
  clear(self)
  self = nil -- luacheck: ignore
  collectgarbage('collect')
end


return Drawable
