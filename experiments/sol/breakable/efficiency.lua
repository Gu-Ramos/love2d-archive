local sqrt = math.sqrt
local clock = os.clock
local function f(x)
  return x^0.5
end

local time = clock()
for c = 1, 100 do
  for i = 1, 50000000 do
    f(438952214909)
  end
end
print(clock()-time)
