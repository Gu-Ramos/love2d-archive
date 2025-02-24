utils = {}

-- setColorHEX(rgba)
-- where rgba is string as "#336699cc"
function utils.getColorHEX(rgba)
  local rb = tonumber(string.sub(rgba, 2, 3), 16) 
  local gb = tonumber(string.sub(rgba, 4, 5), 16) 
  local bb = tonumber(string.sub(rgba, 6, 7), 16)
  local ab = tonumber(string.sub(rgba, 8, 9), 16) or nil
  -- print (rb, gb, bb, ab) -- prints 	51	102	153	204
  -- print (love.math.colorFromBytes( rb, gb, bb, ab )) -- prints	0.2	0.4	0.6	0.8
  return {love.math.colorFromBytes( rb, gb, bb, ab )}
end

function utils.drawGrid(width, color)
  local wx, wy = love.graphics.getDimensions()
  local ox, oy = wx/width - math.floor(wx/width), wy/width - math.floor(wy/width)
  ox = (ox > 0.5 and ox-1 or ox)/2 * width
  oy = (oy > 0.5 and oy-1 or oy)/2 * width

  local color = color or utils.getColorHEX("#FFFFFF")
  local previous_color = {lg.getColor()}
  local previous_line_width = lg.getLineWidth()

  lg.setColor(color)
  lg.setLineWidth(1)
  -- Vertical lines
  for i = 0, wx/width do
    local offset = i * width + ox
    lg.line(offset,0, offset,wy)
  end

  -- Horizontal lines
  for i = 0, wy/width do
    local offset = i * width + oy
    lg.line(0,offset, wx,offset)
  end

  lg.setLineWidth(previous_line_width)
  lg.setColor(previous_color)
end

return utils
