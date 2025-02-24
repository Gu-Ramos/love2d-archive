local checker = require("obj.Grafo.checker")
local Vertice = require("obj.Vertice")
local grafo = {}

---------------------- GERADOR ----------------------
-- Parâmetros da geração do grafo
local MIN_DISTANCIA_EXISTENTE = 3 -- distância mínima até um vértice já existente para adicioná-lo como vizinho
local MAX_VIZINHOS = 4 -- máximo de vizinhos que um vértice pode ter
local MIN_SALAS = 2 -- mínimo de salas quando gerar múltiplos vizinhos
local MAX_SALAS = 4 -- máximo de salas quando gerar múltiplos vizinhos
local CHANCE_SALA_UNICA = 0.9 -- chance de só gerar um vizinho
local CHANCE_NAO_PONTA = 0.98 -- chance de não ser ponta
local PROFUNDIDADE_MAXIMA_VIZINHOS = 8 -- profundidade máxima dos vizinhos
local MAX_DISTANCIA_ENTRE_PONTAS = 6


-- [[ HELPERS ]] --
-- Retorna true somente se todos os argumentos forem true
local function eval(...)
  for _, v in ipairs({...}) do
    if not v then return false; end
  end
  return true
end


-- [[ GERADOR ]] --
-- adiciona n vértices ao redor de um vértice-pai.
function grafo:addNeighboursToVertex(parent, n)
  local neighbouringCells = parent:getNeighbouringCells()
  -- A profundidade do filho é profundidade do pai + 1
  local new_vertices = {}
  local num_added = 0


  -- shuffle na lista de células vizinhas.
  for i = #neighbouringCells, 2, -1 do
    local j = self.rng:random(1, i)
    neighbouringCells[i], neighbouringCells[j] = neighbouringCells[j], neighbouringCells[i]
  end


  -- Vamos adicionar vértices nas <n> primeiras células da lista de células vizinhas.
  for i, cell in ipairs(neighbouringCells) do
    if num_added >= n then break; end -- quebrar o loop depois de adicionar <n> vértices. 
    
    -- verifica se adicionar um vizinho sequer é legal
    local checks_global = eval(
      not checker.checkCellHasVertex(self, cell, parent) -- verifica se a casa x,y selecionada não tem o vértice atual
      ,not checker.checkEntanglement(self, cell) -- evita que aconteçam cruzamentos em X
    )

    -- verifica se vamos adicionar um vizinho que já existe
    local checks_add_existent = eval(
      not checker.checkCellIsEmpty(self, cell) -- tem que existir um vértice na casa x,y selecionada
      ,not checker.checkCellHasMaxNeighbours(self, cell, MAX_VIZINHOS)
      ,not checker.checkVertexDistanceFromCellBelowN(self, parent, cell, MIN_DISTANCIA_EXISTENTE) -- parâmetro adicional pra mudar o formato da dungeon
    )

    -- ou se vamos criar um vértice novo como vizinho. 
    local checks_create_new = eval(
      checker.checkCellIsEmpty(self, cell)
    )
    
    if checker.checkVertexHasMaxNeighbours(self, parent, MAX_VIZINHOS) then
      parent.type = "fim_vizinhos"
      break
    end

    if checks_global then -- se adicionar um vizinho sequer é legal
      if checks_add_existent then -- se vamos adicionar um vizinho que já existe
        local existent = self.grid:get(cell.x, cell.y)

        parent:addNeighbour(existent)
        existent:addNeighbour(parent)
        parent.depth = math.min(parent.depth, existent.depth + 1)
        existent.depth = math.min(existent.depth, parent.depth + 1)
        
        num_added = num_added + 1
      elseif checks_create_new then -- se vamos criar um vértice novo como vizinho. 
        local new_vertex = Vertice(cell.x,cell.y, "meio", parent, parent.depth + 1, {parent})
        
        table.insert(new_vertices, new_vertex)
        self:insert(new_vertex)
        parent:addNeighbour(new_vertex)

        num_added = num_added + 1
      end

    end
  end


  -- retorna lista de vértices adicionados
  return new_vertices 
end

-- gera o grafo de uma dungeon do zero
function grafo:legacyGeneration()
  self:empty()
  local pontas = {}
  
  -- começa pela raiz, não coloca a raiz na fila
  local current_vertex = Vertice(0,0, "raiz", nil, 0, {})
  self:insert(current_vertex)

  
  -- Começa gerando as salas adjacentes à raiz e adicionando elas à fila
  local fila = self:addNeighboursToVertex(current_vertex, self.rng:random(MIN_SALAS, MAX_SALAS))

  -- Gerar salas até esvaziar a fila.
  while #fila ~= 0 do
    current_vertex = table.remove(fila, 1) -- t.remove funciona tanto pra pilha quanto pra fila ;)

    -- Chance de só não gerar mais nada a partir desse vértice.
    -- Aumenta exponencialmente conforme a profundidade do vértice.
    if (self.rng:random() > CHANCE_NAO_PONTA^(current_vertex.depth)) then
      table.insert(pontas, current_vertex)
      current_vertex.type = "fim_chance"
    else
      local num_salas = 1
      -- Chance de gerar mais de uma sala
      if self.rng:random() > CHANCE_SALA_UNICA then
        num_salas = self.rng:random(MIN_SALAS, MAX_SALAS)
      end
      
      -- Cria os novos vizinhos
      local new_vertices = self:addNeighboursToVertex(current_vertex, num_salas)

      -- Adiciona os novos vizinhos na fila
      for _, v in ipairs(new_vertices) do
        -- A profundidade máxima evita loops infinitos e dungeons idioticamente grandes.
        if v.depth >= PROFUNDIDADE_MAXIMA_VIZINHOS then
          table.insert(pontas, v)
          v.type = "fim_profundidade"
        else
          table.insert(fila, v)
        end
      end
    end
  end

  -- Post Processing
  -- local i = 1
  -- while i <= #pontas - 1 do
  --   print(i)
  --   for p = 1, #pontas do
  --     if self:findPathToTarget(pontas[i], pontas[p], MAX_DISTANCIA_ENTRE_PONTAS) == nil then
  --       pontas[i]:addNeighbour(pontas[p])
  --       pontas[p]:addNeighbour(pontas[i])
  --       i = 1
  --       break
  --     end
  --   end
  --   i = i + 1
  -- end


  
  
  local i = 1
  while i <= #pontas-1 do
    local candidatos = {}
    for p = 1, #pontas do
      if (#pontas[p].portals < 2) and (not self:findPathToTarget(pontas[i],pontas[p], MAX_DISTANCIA_ENTRE_PONTAS)) then
        table.insert(candidatos, pontas[p])
      end
    end
    
    if #candidatos > 0 then
      table.sort(candidatos, function(a,b)
        return #a.portals < #b.portals
      end)
      local min = #(candidatos[1].portals)
      for k, p in ipairs(candidatos) do
        if #p.portals > min then
          table.remove(candidatos, k)
        end
      end
      
      table.sort(candidatos, function(a,b)
        return #self:findPathToTarget(pontas[i],a) > #self:findPathToTarget(pontas[i],b)
      end)
      
      -- local selecionado = candidatos[self.rng:random(1, #candidatos)]
      local selecionado = candidatos[1]
      pontas[i]:addNeighbour(selecionado)
      selecionado:addNeighbour(pontas[i])
      table.insert(pontas[i].portals, selecionado)
      table.insert(selecionado.portals, pontas[i])
    end
    
    i = i + 1
  end
  
  
  local center = self.grid:get(0,0)
  for _, v in ipairs(self.lista) do
    v._cor_ = 0; v.depth = 0
  end
  center._cor_ = 1
  local fila2 = {center}

  while #fila2 > 0 do
    local current_vertex = table.remove(fila2, 1)
    for _, v in ipairs(current_vertex.neighbours) do
      if v._cor_ == 0 then
        v._cor_ = 1
        v.depth = current_vertex.depth + 1
        table.insert(fila2, v)
      end
    end
  end
  
  return self
end


return grafo
