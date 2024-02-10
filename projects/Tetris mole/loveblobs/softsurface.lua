local dir = (...):gsub('%.[^%.]+$', '')
local util = require(dir .. ".util")
local physics = love.physics
local graphics = love.graphics
local lmath = love.math

local softsurface = setmetatable({}, {
  __call = function(self, world, x, y, r, s, t)
    local new = util.copy(self);
    new:init(world, x, y, r, s, t);

    return setmetatable(new, getmetatable(self));
  end,
  __index = function(self, i)
    return false;
  end,
  __tostring = function(self)
    return "softsurface";
  end
});

function softsurface:init(world, points, precision, mode)
  local precision = precision or 128

  -- move the points into a new table with the correct format
  local t   = {}
  t[1]      = points[1]
  t[2]      = points[2]
  local c = 3
  for i=3,#points*2,4 do
    t[i]    = points[c]
    t[i+1]  = points[c+1]
    t[i+2]  = points[c]
    t[i+3]  = points[c+1]
    c = c + 2
  end
  t[#t+1]   = points[1]
  t[#t+1]   = points[2]

  -- container for physical objects
  self.phys = {}

  local last_dx, last_dy = 0
  local first_dx, first_dy = 0 
  local prev_base_body = nil
  for i=1,#t,4 do
    local x1,y1 = t[i],t[i+1]
    local x2,y2 = t[i+2],t[i+3]

    -- figure out amount of surfaces to create
    local distance_to   = util.dist(x1, y1, x2, y2)
    local surface_count = math.floor(distance_to / precision)
    local angle_to      = math.atan2(y2 - y1, x2 - x1)
  
    -- offset
    local dx = math.cos(angle_to)
    local dy = math.sin(angle_to)

    if i == 1 then
      last_dx   = dx
      last_dy   = dy
      first_dx  = dx
      first_dy  = dy
    end

    -- create the static base body
    local base_shape   = physics.newRectangleShape(-50*dy,50*dx, distance_to, 100, angle_to)
    local base_body    = physics.newBody(world, x1+dx*(distance_to/2+precision/4), y1+dy*(distance_to/2+precision/4), mode)
    local base_fixture = physics.newFixture(base_body, base_shape)
    --base_fixture:setCategory(1, 2)
    base_fixture:setSensor(true)
	base_fixture:setCategory(16)
	base_fixture:setMask(1)
    base_fixture:setUserData(self)
    
    local joint_a = nil
    local joint_b = nil
    if prev_base_body then
      joint_a = physics.newWeldJoint(base_body, prev_base_body, base_body:getX(), base_body:getY(), false)  
    end

    if i >= #t-4 then
      prev_base_body = self.phys[1].body
      joint_b = physics.newWeldJoint(base_body, prev_base_body, base_body:getX(), base_body:getY(), false)  
    end

    prev_base_body = base_body
    table.insert(self.phys, {body = base_body, shape = base_shape, fixture = base_fixture, joint_a = joint_a, joint_b = joint_b})

    for j=1,surface_count do
      -- create the physical object
      local x = x1+dx*(precision*j)
      local y = y1+dy*(precision*j)
      local shape   = physics.newRectangleShape(0, 0, precision*1.2, 8, angle_to)
      local body    = physics.newBody(world, x, y, "dynamic")
      local fixture = physics.newFixture(body, shape)
      fixture:setFriction(0.05)
      fixture:setMask(2)
	  fixture:setCategory(1)
      fixture:setUserData(self)

      -- create the joints
      local joint_a = physics.newDistanceJoint(body, base_body, x, y, x, y, false)
      joint_a:setDampingRatio(0.2)
      joint_a:setFrequency(0.6)

      if mode == "dynamic" then
        joint_a:setFrequency(1)
        fixture:setFriction(0.5 )
      end

      -- set up secondary joint
      local joint_b = nil
      local index = #self.phys
      if i > 1 and j == 1 then
        index = index - 1
      end
      if j > 1 or (i > 1 and j == 1) then
        local v = self.phys[index]
        if i > 1 and j == 1 then
          joint_b = physics.newRopeJoint(v.body, body, v.body:getX()+last_dx*(precision/2), v.body:getY()+last_dy*(precision/2),
          x-dx*(precision/2), y-dy*(precision/2), 1, false)
        else 
          joint_b = physics.newRopeJoint(v.body, body, v.body:getX()+dx*(precision/2), v.body:getY()+dy*(precision/2),
          x-dx*(precision/2), y-dy*(precision/2), 5, false)
        end
      end

      -- connect first to last
      local joint_c = nil
      if i >= #t-4 and j == surface_count then
        local v = self.phys[2]
        joint_c = physics.newRopeJoint(v.body, body, v.body:getX()-first_dx*(precision/2), v.body:getY()-first_dy*(precision/2),
         x+dx*(precision/2), y+dy*(precision/2), 5, false)
      end

      -- store it
      table.insert(self.phys, {body = body, shape = shape, fixture = fixture, joint_a = joint_a, joint_b = joint_b, joint_c = joint_c})
    end

    last_dx = dx
    last_dy = dy
  end
end

function softsurface:getPosition()
	local x, y = 0,0
	local count = 0
	for i,v in ipairs(self.phys) do
		if v.body then
			count = count+1
			x = x+v.body:getX()
			y = y+v.body:getY()
		end
	end
	return x/count, y/count
end

function softsurface:applyForce(fx,fy)
	for i,v in ipairs(self.phys) do
		if v.body and (v.fixture and v.fixture:isSensor()) then
			v.body:applyForce(fx,fy)
		end
	end
end

function softsurface:applyAngularImpulse(fx,fy)
	for i,v in ipairs(self.phys) do
		if v.body and (v.fixture and v.fixture:isSensor()) then
			v.body:applyAngularImpulse(fx,fy)
		end
	end
end

function softsurface:setPosition(x,y)
	local ox, oy = self:getPosition()
	local tx, ty = x-ox, y-oy
	for i,v in ipairs(self.phys) do
		if v.body then
			v.body:setPosition(v.body:getX()+tx, v.body:getY()+ty)
		end
	end
end

function softsurface:setCategory(a)
	for i,v in ipairs(self.phys) do
		if v.fixture and v.fixture:isSensor() then
			v.fixture:setCategory(a)
		end
	end
end

function softsurface:setLinearDamping(ld)
	for i,v in ipairs(self.phys) do
		if v.body then
			v.body:setLinearDamping(ld)
		end
	end
end

function softsurface:setAngularDamping(ad)
	for i,v in ipairs(self.phys) do
		if v.body then
			v.body:setAngularDamping(ad)
		end
	end
end

function softsurface:setFrequency(f)
	for i,v in ipairs(self.phys) do
		if v.joint_a then
			v.joint_a:setFrequency(f)
		end
	end
end

function softsurface:setDampingRatio(d)
	for i,v in ipairs(self.phys) do
		if v.joint_a then
			v.joint_a:setDampingRatio(d)
		end
	end
end

function softsurface:setFriction(f)
	for i,v in ipairs(self.phys) do
		if v.fixture then
			v.fixture:setFriction(f)
		end
	end
end

function softsurface:setRestitution(r)
	for i,v in ipairs(self.phys) do
		if v.fixture then
			v.fixture:setRestitution(r)
		end
	end
end

function softsurface:setMass(m)
	for i,v in ipairs(self.phys) do
		if v.body then
			v.body:setMass(m)
		end
	end
end

function softsurface:setBullet(b)
	for i,v in ipairs(self.phys) do
		if v.body then
			v.body:setBullet(true)
		end
	end
end

function softsurface:draw(debug)
  if self.dead then
    return
  end

  graphics.setLineStyle("smooth");
  graphics.setLineJoin("miter");

  if debug then
    for i,v in ipairs(self.phys) do
      graphics.setColor(1, 0, 0)
      graphics.polygon("line", v.body:getWorldPoints(v.shape:getPoints()))

      if v.joint_a then
        graphics.setColor(0, 1, 0)
        graphics.line(v.joint_a:getAnchors())
        graphics.setColor(0, 0, 1)
        if v.joint_b then
          graphics.line(v.joint_b:getAnchors())
        end
        if v.joint_c then
          graphics.line(v.joint_c:getAnchors())
        end
	  end
    end
  else
    local t = {{}, {}}
    for i,v in ipairs(self.phys) do
      if v.body and not v.fixture:isSensor() then
        table.insert(t[1], v.body:getX())
        table.insert(t[1], v.body:getY())
      end
    end

    graphics.setLineWidth(10)
    util.tessellate(t[1], t[2]);

    local ok, tri = pcall(lmath.triangulate, t[2])
    if not ok then
      graphics.polygon("fill", t[2])
      graphics.line(t[2][#t[2]-1], t[2][#t[2]], t[2][1], t[2][2])
      return
    end
    for i,v in ipairs(tri) do
      graphics.polygon("fill", v)
    end

    graphics.line(t[2])
    graphics.line(t[2][#t[2]-1], t[2][#t[2]], t[2][1], t[2][2])
  end

end

function softsurface:destroy()
  if self.dead then
    return
  end
  
  for i,v in ipairs(self.phys) do
    v.body:destroy()
  end
  self.phys = nil
  self.dead = true
end

return softsurface
