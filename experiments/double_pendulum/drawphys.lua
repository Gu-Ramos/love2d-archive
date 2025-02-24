local colors = {static={0.47,0.47,0.47},dynamic={0.45,0,0.77},kinematic={0.37,0.87,0.37}}
return function (world,alpha,width) -- Draws a Box2D world
  alpha, width = alpha or 1, width or 4
  -- get the current color values to reapply
  local r, g, b, a = love.graphics.getColor()
  local w = love.graphics.getLineWidth()

--   colors.static[4] = alpha
  colors.dynamic[4] = alpha
  colors.kinematic[4] = alpha

  love.graphics.setLineWidth(width)
  -- Colliders debug
  local t, bodies = pcall(world.getBodies, world)
  if not t then return; end

  for it = 1, #bodies do
    local body = bodies[it]
    love.graphics.setColor(colors[body:getType()])

    local fixtures = body:getFixtures()

    for it2 = 1, #fixtures do
      local shape = fixtures[it2]:getShape()
      if shape:type() == 'PolygonShape' then
        love.graphics.polygon('line', body:getWorldPoints(shape:getPoints()))
      elseif shape:type() == 'CircleShape' then
        local body_x, body_y = body:getPosition()
        local shape_x, shape_y = shape:getPoint()
        love.graphics.circle('line', body_x + shape_x, body_y + shape_y, shape:getRadius(), 360)
      else
        love.graphics.line(body:getWorldPoints(shape:getPoints()))
      end
    end
  end

  -- Joint debug
  love.graphics.setColor(0.75,0.50,0.97, alpha)
  love.graphics.setLineWidth(3)
  local t, joints = pcall(world.getJoints, world)
  if not t then return; end

  for iterator = 1, #(joints) do
    local joint = joints[iterator]
    local x1, y1, x2, y2 = joint:getAnchors()
    if x1 and y1 then love.graphics.circle('line', x1, y1, 8); end
    if x2 and y2 then love.graphics.circle('line', x2, y2, 8); end
  end

  local t, contacts = pcall(world.getContacts, world)
  if not t then return; end

  love.graphics.setColor(0.2, 0, 1, alpha)
  for iterator = 1, #(contacts) do
    local contact = contacts[iterator]
    local x1, y1, x2, y2 = contact:getPositions()
    if x1 and y1 then love.graphics.circle('fill', x1, y1, 8); end
    if x2 and y2 then love.graphics.circle('fill', x2, y2, 8); end
  end

  love.graphics.setLineWidth(w)
  love.graphics.setColor(r, g, b, a)
end
