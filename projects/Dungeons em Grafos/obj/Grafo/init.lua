local Grid = require("obj.Grafo.Grid")
local generators = require("obj.Grafo.generators")
local search = require("obj.Grafo.search")

---------------------- GRAFO ----------------------
local grafo = Class("Grafo")
-- construct do grafo
function grafo:init(vertices)
  self.grid = Grid()
  self.lista = {}
  self.rng = love.math.newRandomGenerator(os.time())

  if vertices ~= nil then
    for k,v in pairs(vertices) do
      self.grid:insert(v.x, v.y, v)
      table.insert(self.lista, v)
    end
  end
end

-- esvazia o grafo
function grafo:empty() 
  self.grid = Grid() -- this
  self.lista = {} -- is fucking
  collectgarbage("collect") -- awful
end

-- desenha o grafo na tela
function grafo:draw()
  for _,v in ipairs(self.lista) do
    v:drawConnections()
  end
  for _,v in ipairs(self.lista) do
    v:draw()
  end
end

-- insere um vértice no grafo
function grafo:insert(v)
  self.grid:insert(v.x,v.y, v)
  table.insert(self.lista, v)
end


function grafo:generate(algorithm)
  algorithm = algorithm or "legacyGeneration"
  local time = os.clock()

  local return_value = self[algorithm](self)
  
  print(string.format("Time to generate: %.4fs", os.clock() - time))
  return return_value
end


grafo:implement(search, unpack(generators))


return grafo
