--  -- Fast gaussian blur shader from moonshine
-- local function build_shader(taps, offset, offset_type, sigma)
--   taps = math.floor(taps)
--   sigma = sigma >= 1 and sigma or (taps - 1) * offset / 6
--   sigma = math.max(sigma, 1)
--   local steps = (taps + 1) / 2
--   local g_offsets, g_weights = {}, {}
--   for i = 1, steps, 1 do
--     g_offsets[i] = offset * (i - 1)
--     g_weights[i] = math.exp(-0.5 * (g_offsets[i] - 0) ^ 2 * 1 / sigma ^ 2 )
--   end
--   local offsets, weights = {}, {}
--   for i = #g_weights, 2, -2 do
--     local oA, oB = g_offsets[i], g_offsets[i - 1]
--     local wA, wB = g_weights[i], g_weights[i - 1]
--     wB = oB == 0 and wB / 2 or wB
--     local weight = wA + wB
--     offsets[#offsets + 1] = offset_type == 'center' and (oA + oB) / 2 or (oA * wA + oB * wB) / weight
--     weights[#weights + 1] = weight
--   end
--   local code = {"extern vec2 direction;\nvec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)\n{\n"}
--   local norm = 0
--   if #g_weights % 2 == 0 then
--     code[#code+1] =  '	vec4 c = vec4( 0.0 );\n'
--   else
--     local weight = g_weights[1]
--     norm = norm + weight
--     code[#code+1] = ('	vec4 c = %f * texture2D(tex, tc);\n'):format(weight)
--   end
--   local tmpl = '	c += %f * (texture2D(tex, tc + %f * direction) + texture2D(tex, tc - %f * direction));\n'
--   for i = 1, #offsets, 1 do
--     local offset = offsets[i]
--     local weight = weights[i]
--     norm = norm + weight * 2
--     code[#code+1] = tmpl:format(weight, offset, offset)
--   end
--   code[#code+1] = ('	return c * vec4(%f) * color;\n}'):format(1 / norm)
--   local shader = table.concat(code)
--   print(shader)
--   return love.graphics.newShader(shader)
-- end

function updateScaling(wx,wy) -- Scale
  if wx<wy then wx,wy = wy,wx; end

  if (not Scale or Scale.width ~= wx) or Scale.height ~= wy then
    Scale = Scale or {}
    Scale.width = wx
    Scale.height = wy

    Scale.scale = 16/9*wx > wy and wy/1080 or wx/1920
    Scale.tX, Scale.tY = wx/2-1920*sc/2, wy/2-1080*sc/2

    Scale.transform = love.math.newTransform(TranslateX,TranslateY, 0,
                                             Scale,Scale, 0,0)

    Scale.rx0, Scale.ry0 = Transform:inverseTransformPoint(0,0)
    Scale.rx1, Scale.ry1 = Transform:inverseTransformPoint(wx,wy)
  end
end

local colors = {static={0.87,0.87,0.87},
                dynamic={0.87,0.37,0.37},
                kinematic={0.37,0.87,0.37}}
function love.physics.debug(world,alpha,width) -- Draws a Box2D world
  -- get the current color values to reapply
  local r, g, b, a = love.graphics.getColor()
  local w = love.graphics.getLineWidth()

  colors.static[4] = alpha
  colors.dynamic[4] = alpha
  colors.kinematic[4] = alpha

  love.graphics.setLineWidth(width)
  -- Colliders debug
  local bodies = world:getBodies()

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
        love.graphics.circle('line', body_x+shape_x, body_y+shape_y,
                              shape:getRadius(), 360)
      else
        love.graphics.line(body:getWorldPoints(shape:getPoints()))
      end
    end
  end

  -- Joint debug
  love.graphics.setColor(0.87, 0.5, 0.25, alpha)
  local joints = world:getJoints()
  for iterator = 1, #(joints) do
    local joint = joints[iterator]
    local x1, y1, x2, y2 = joint:getAnchors()
    if x1 and y1 then love.graphics.circle('line', x1, y1, 18); end
    if x2 and y2 then love.graphics.circle('line', x2, y2, 18); end
  end

  local contacts = world:getContacts()
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
