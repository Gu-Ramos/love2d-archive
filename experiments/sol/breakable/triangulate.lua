local function isConvex(p)
  return ((p[3] - p[1]) * (p[6] - p[2]) - (p[4] - p[2]) * (p[5] - p[1])) >= 0
end

local function inTriangle(t,p)
  local l = {0,0,0}
  local eps = 0.0000001
  l[1] = ((t[4] - t[6]) * (p[1] - t[5]) + (t[5] - t[3]) * (p[2] - t[6])) / (((t[4] - t[6]) * (t[1] - t[5]) + (t[5] - t[3]) * (t[2] - t[6])) + eps)
  l[2] = ((t[6] - t[2]) * (p[1] - t[5]) + (t[1] - t[5]) * (p[2] - t[6])) / (((t[4] - t[6]) * (t[1] - t[5]) + (t[5] - t[3]) * (t[2] - t[6])) + eps)
  l[3] = 1 - l[1] - l[2]
  for i=1,3 do
    if l[i] > 1 or l[i] < 0 then return false; end
  end
  return true
end

local function GetEar(poly)
  local size = #poly
  
  if size == 6 then
    local tri = {poly[1],poly[2],poly[3],poly[4],poly[5],poly[6]}
    for i = 1,6 do poly[i] = nil; end
    return tri
  end
  
  for i = 1, size, 2 do
    local tritest = false
    local tri = nil
    if i == 1 then
      tri = {poly[(i-3) % size], poly[(i-2) % size], 
             poly[i], poly[i+1],
             poly[(i+1) % size], poly[(i+2) % size]}
    else
      tri = {poly[(i-2) % size], poly[(i-1) % size], 
             poly[i], poly[i+1],
             poly[(i+1) % size], poly[(i+2) % size]}
    end
    
    if isConvex(tri) then
      for c = 1, size, 2 do
        local x,y = poly[c], poly[c+1]
        
        if (x~=tri[1] and y~=tri[2])
        and (x~=tri[3] and y~=tri[4])
        and (x~=tri[5] and y~=tri[6])
        and inTriangle(tri,{x,y}) then
          tritest = true
          break
        end
      end
      if not tritest then
        table.remove(poly, i%size)
        table.remove(poly, (i+1)%size)
        return tri
      end
    end
  end
  return false
end

local rect = {100,100,200,100,300,100,400,100, 400,200,300,200,200,200,100,200}
return function(og)
  local copy = {}
  for i = 1, #og do copy[i] = og[i]; end
  local poly = {}
  while true do
    local tri = GetEar(copy)
    if tri then table.insert(poly, tri); else break; end
  end
  return poly
end
