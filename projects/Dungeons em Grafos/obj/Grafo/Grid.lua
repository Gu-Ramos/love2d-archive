------------------------ GRID ----------------------
local grid = Class("Grid")
-- constructor do grid.
function grid:init(center)
  if center ~= nil then
    self[0] = {}
    self[0][0] = center
  end
end

-- insere o objeto <obj> na posição x,y do grid.
function grid:insert(x,y, obj)
  if self[y] == nil then
    self[y] = {}
  end

  self[y][x] = obj
end

-- retorna o elemento na posição x,y do grid (nil se não houver elemento)
function grid:get(x,y)
  if self[y] == nil then
    return nil
  else
    return self[y][x]
  end
end

return grid
