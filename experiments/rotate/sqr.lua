local sqr = Class:extend()

function sqr:new(x,y, w,h, v,v2)
  self.x, self.y, self.w, self.h, self.v, self.v2 = x, y, w, h, v, v2
  self.a, self.s = 0,0
end

function sqr:update(dt)
  self.a = self.a + self.v*dt
  self.s = self.s + self.v2*dt
end

function sqr:draw()
  lg.push()
  local x,y = self.x,self.y
  local w,h = self.w,self.h
  lg.translate(x + w, y + h+10)
  lg.rotate(self.a)
  lg.scale(math.sin(self.s)/4+0.75+1)
  lg.translate(-x + -w, -y + -(h+10))
    lg.polygon('line', {(100+x),(0+y), (0+x),(173.2+y), (200+x),(173.2+y)})
  lg.pop()
end

return sqr
