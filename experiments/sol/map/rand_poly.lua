local insert = table.insert
local sin = math.sin
local cos = math.cos
local pi2 = math.pi*2
local lp = love.physics

-- TODO: function complete_poly(i, x,y, rX,rY, s, rvX, rvY, cvX, cvY)

function complete_poly(v,p,  ox,oy, orx,ory, os,  rx,ry, s, rvx, rvy, cvx, cvy)
  return poly, ox,oy
end

local function random_poly(x,y, rx,ry, s, rvx,rvy, cvx,cvy)
  local poly = {}
  for i = 1, s do
    insert(poly, sin(i/s*pi2) * (rx+rand:randomNormal((rvx*2)^0.5)) + (x+rand:randomNormal((cvx*2)^0.5)))
    insert(poly, cos(i/s*pi2) * (ry+rand:randomNormal((rvy*2)^0.5)) + (y+rand:randomNormal((cvy*2)^0.5)))
  end
  return poly
end

local function regular_poly(x,y, rX,rY, s)
  local poly = {}
  for i = 1, s do
    insert(poly, sin(i/s*pi2) * rX + x)
    insert(poly, cos(i/s*pi2) * rY + y)
  end
  return poly
end

return random_poly, regular_poly
