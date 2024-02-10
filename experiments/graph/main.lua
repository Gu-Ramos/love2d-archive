require('batteries'):export()

local med = {}
local tinsert = table.insert
local floor = math.floor
local sqrt = math.sqrt

for n = 3, 10000000, 2 do
  for d = 3, sqrt(n), 2 do
    if n % d == 0 then
      tinsert(med, floor((d-2)/2))
      goto continue
    end
  end
  tinsert(med, floor(sqrt(n)))
  ::continue::
end

print(table.mean(med))

love.event.quit()
