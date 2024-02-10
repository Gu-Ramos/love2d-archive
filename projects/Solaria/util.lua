local colors = {static={0.87,0.87,0.87},
                dynamic={0.87,0.37,0.37},
                kinematic={0.37,0.87,0.37}}

function love.physics.debug(world,alpha,width)
  -- get the current color values to reapply
  local r, g, b, a = lg.getColor()
  local w = lg.getLineWidth()

  colors.static[4] = alpha
  colors.dynamic[4] = alpha
  colors.kinematic[4] = alpha

  lg.setLineWidth(width)
  -- Colliders debug
  local bodies = world:getBodies()

  for it = 1, #bodies do
    local body = bodies[it]
    lg.setColor(colors[body:getType()])

    local fixtures = body:getFixtures()

    for it2 = 1, #fixtures do
      local shape = fixtures[it2]:getShape()
      if shape:type() == 'PolygonShape' then
        lg.polygon('line', body:getWorldPoints(shape:getPoints()))
      elseif shape:type() == 'CircleShape' then
        local body_x, body_y = body:getPosition()
        local shape_x, shape_y = shape:getPoint()
        lg.circle('line', body_x + shape_x, body_y + shape_y, shape:getRadius(), 360)
      else
        lg.line(body:getWorldPoints(shape:getPoints()))
      end
    end
  end

  -- Joint debug
  lg.setColor(0.87, 0.5, 0.25, alpha)
  local joints = world:getJoints()
  for iterator = 1, #(joints) do
    local joint = joints[iterator]
    local x1, y1, x2, y2 = joint:getAnchors()
    if x1 and y1 then lg.circle('line', x1, y1, 18); end
    if x2 and y2 then lg.circle('line', x2, y2, 18); end
  end

  local contacts = world:getContacts()
  lg.setColor(0.2, 0, 1, alpha)
  for iterator = 1, #(contacts) do
    local contact = contacts[iterator]
    local x1, y1, x2, y2 = contact:getPositions()
    lg.circle('fill', x1, y1, 8);
    if x2 and y2 then lg.circle('fill', x2, y2, 8); end
  end

  lg.setLineWidth(w)
  lg.setColor(r, g, b, a)
end
