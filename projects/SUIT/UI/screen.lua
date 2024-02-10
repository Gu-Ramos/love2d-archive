local BASE = (...):match('(.-)[^%.]+$')
local suit = require(BASE..'suit')
local Class = require(BASE..'classic')
local Screen = Class:extend()
local tinsert = table.insert

local function unpack6(t) return t[1],t[2],t[3],t[4],t[5],t[6]; end

function Screen:new(theme, transform)
  self.theme = theme
  self.widgets = {}
  self.instance = suit.new()
  self.opacity = 0
  self.active = false

  self.instance.transform = transform

  self.transform = transform
  self.layout = self.instance.layout

  return self
end

function Screen:setTransform(transform)
  self.instance.transform = transform
end

function Screen:getWidget(name)
  return self.widgets[name]
end

function Screen:removeWidget(name)
  self.widgets[name] = nil
end

function Screen:newWidget(type, name, view, opts, x,y, w,h, onHit)
  opts.color = opts.color or self.theme
  opts.id = name or #self.widgets+1
  local widget = {t=type, f=onHit, w={view,opts,x,y,w,h}}
  if name then
    self.widgets[name] = widget
  else
    tinsert(self.widgets, widget)
  end
  return widget
end

local function merge(t1, t2)
  for i,v in pairs(t1) do
    t1[i] = t2[i] or v
  end
  return t1
end

local function merge_recursive(t1,t2)
  for k,v in pairs(t1) do
    if type(v) == 'table' and type(t2[k]) == 'table' then
      merge_recursive(v, t2[k])
    end
  end
  merge(t1,t2)
end

function Screen:modifyWidget(name, opts)
  local widget = self.widgets[name].w
  merge_recursive(widget,opts)
  return self.widgets[name].w
end

function Screen:changeTheme(theme)
  self.theme = theme
end

function Screen:update(dt)
  for _,widg in pairs(self.widgets) do
    local v,o,x,y,w,h = unpack6(widg.w)
    local state = self.instance[widg.t](self.instance, v,o, x,y, w,h, dt)
    if self.active and widg.f and state.hit then
      widg.f(widg, state)
    end
  end
end

function Screen:draw()
  self.instance:draw()
end

return Screen
