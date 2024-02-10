-- local suit = require('ui.suit')
local BASE = (...) .. "."
local Screen = require(BASE..'screen')
local lg = love.graphics
local tinsert = table.insert

-- local ui = setmetatable({}, {__index=function(_,k) return suit[k]; end})
local ui = {}

local screens = {}
local activeScreens = {}

-- local refresh = {}

function ui.newScreen(name, theme)
  local screen = Screen(theme)

  if name then
    screens[name] = screen
  else
    tinsert(screens, screen)
  end

  return screen
end

function ui.getScreen(name)
  return screens[name]
end

function ui.activateScreen(name)
  screens[name].active = true
  activeScreens[name] = screens[name]
end

function ui.deactivateScreen(name)
  screens[name].active = false
end

function ui.getActiveList()
  return activeScreens
end

function ui.rmvScreen(name)
  screens[name] = nil
end

function ui.update(dt)
  for _,v in pairs(activeScreens) do
    v:update(dt)
  end

  for name,screen in pairs(activeScreens) do
    if screen.active then
      if screen.opacity < 1 then
        screen.opacity = screen.opacity + dt*4
      end
    elseif not screen.active then
      if screen.opacity > 0 then
        screen.opacity = screen.opacity - dt*4
      else
        activeScreens[name] = nil
      end
    end
  end
end

function ui.draw()
  local r,g,b,a = lg.getColor()
  for _,screen in pairs(activeScreens) do
    lg.setColor(1,1,1,screen.opacity*a)
    screen:draw()
  end
  lg.setColor(r,g,b,a)
end

function ui.textinput(t)
  for _,screen in pairs(activeScreens) do
    screen.instance:textinput(t)
  end
end

function ui.keypressed(t)
  for _,screen in pairs(activeScreens) do
    screen.instance:keypressed(t)
  end
end

-- function ui.refresh(w,h)
-- end

return ui
