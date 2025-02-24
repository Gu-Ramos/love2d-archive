-- Creating base class "Object"
local Object = {}
Object.__index = Object
Object.__super = nil
Object.__name = "Object"
Object.__type = "Class"


function Object:init()
end


function Object:implement(...)
  for _, class in pairs({...}) do
    for k,v in pairs(class) do
      if (not (k:find("__") == 1)) and (self[k] == nil) then
        self[k] = v
      end
    end
  end
end


function Object:is(class)
  local c = self.__class

  if type(class) == "string" then
    while c ~= nil do
      if c.__name == class then
        return true
      end
      c = c.__super
    end
  elseif type(class) == "table" and class.__type == "Class" then
    while c ~= nil do
      if c == class then
        return true
      end
      c = c.__super
    end
  end
  
  return false
end


function Object:__call(...)
  local obj = setmetatable({__type = "Object", __class = self}, self)
  obj:init(...)
  return obj
end


--- Class-creating function ---
local function class(class_name, super, ...)
  super = super or Object
  class_name = class_name or super.__name
  
  local new_class = {}
  
  for k, v in pairs(super) do
    if k:find("__") == 1 then
      new_class[k] = v
    end
  end

  new_class.__name = class_name or super.__name .. "(extension)"
  new_class.__type = "Class"
  new_class.__super = super
  new_class.__index = new_class
  setmetatable(new_class, super)

  new_class:implement(...)

  return new_class
end

return class
