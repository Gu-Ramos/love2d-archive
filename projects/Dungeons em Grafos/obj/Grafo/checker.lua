local checker = {}

-- Checa se vai rolar embaraço ao adicionar um vértice em uma célula específica
function checker.checkEntanglement(g, cell)
  if (cell.dir.x ~= 0) and (cell.dir.y ~= 0) then
    local grid_vertex = g.grid:get(cell.x - cell.dir.x, cell.y)
    local grid_vertex2 = g.grid:get(cell.x, cell.y - cell.dir.y)
    if grid_vertex and grid_vertex2 then
      return grid_vertex:hasNeighbour(grid_vertex2)
    end
  end
  return false
end

-- Checa se uma célula contém um vértice específico
function checker.checkCellHasVertex(g, cell, vertex)
  return (cell.x == vertex.x) and (cell.y == vertex.y)
end

-- Checa se uma célula não tem nenhum vértice
function checker.checkCellIsEmpty(g, cell)
  return g.grid:get(cell.x, cell.y) == nil
end

-- Checa se o vértice de uma célula já tem o número máximo de vizinhos
function checker.checkCellHasMaxNeighbours(g, cell, max_neighbours)
  if checker.checkCellIsEmpty(g, cell) then
    return false
  end
  return #(g.grid:get(cell.x, cell.y).neighbours) >= max_neighbours
end

-- Checa se um vértice já tem o número máximo de vizinhos
function checker.checkVertexHasMaxNeighbours(g, vertex, max_neighbours)
  return #vertex.neighbours >= max_neighbours
end

-- Checks if the distance between the vertex and the cell is below n
function checker.checkVertexDistanceFromCellBelowN(g, parent, cell, n)
  if checker.checkCellIsEmpty(g, cell) then
    return false
  end
  return g:findPathToTarget(parent, g.grid:get(cell.x, cell.y), n) ~= nil
end

return checker
