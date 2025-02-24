local grafo = {}

-- retorna o menor caminho entre um vértice e outro
-- se conseguir encontrar ele numa profundidade máxima N
function grafo:findPathToTarget(vertex, target, max_depth)
  if vertex == target then return {vertex}; end
  
  max_depth = max_depth or math.huge
  for _,v in ipairs(self.lista) do 
    v._cor_ = 0; v._depth_ = 0; v._previous_ = nil;
  end
  vertex._cor_ = 1
  local fila = {vertex}

  while (#fila ~= 0) do
    local current_vertex = table.remove(fila, 1)

    for _,v in ipairs(current_vertex.neighbours) do
      if v._cor_ == 0 then
        v._cor_ = 1
        v._depth_ = current_vertex._depth_ + 1
        v._previous_ = current_vertex

        if v == target then
          local step = v
          local path = {}
          
          for i = v._depth_, 0, -1 do
            path[i+1] = step
            step = step._previous_
          end

          return path
        elseif v._depth_ < max_depth then
          table.insert(fila, v)
        else
          v._cor_ = 2
        end
      end
    end
  end

  return nil
end

return grafo