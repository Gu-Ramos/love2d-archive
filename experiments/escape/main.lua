local lg = love.graphics
local lw = love.window
local lm = love.mouse

lg.setFont(lg.newFont(60))
local w,h = lw.getMode()
lm.setRelativeMode(true)

function love.update()
  if (not lw.hasFocus()) or (not lw.hasMouseFocus()) then
    lw.requestAttention(true)
    local nw,nh = lw.getDesktopDimensions()
    lw.setMode(nw,nh,{fullscreen=false})
    ESCAPE = true
    w,h = lw.getMode()
    lm.setGrabbed(true)
    lm.setRelativeMode(true)
    print('YOU CANNOT ESCAPE. :)')
  end
  lm.setPosition(w/2, h/2)
end

function love.draw()
  if RED then lg.setColor(1,0,0); end
  if ESCAPE then
    lg.print('YOU CANNOT ESCAPE. :)', 10,250)
  end
end

function love.keypressed(_,s)
  if s == 'escape' then
    ESCAPE = true
  end
  if s == 'lgui' or s == 'rgui' then
    ESCAPE = true
    RED = true
  end
end

function love.run()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  love.timer.step()

  local dt = 0
  local lt = love.timer
  local le = love.event
  local lh = love.handlers

  -- Main loop.
  return function()
--     le.pump()
--     for name, a,b,c,d,e,f in le.poll() do
--       if name == "quit" then
--         if not love.quit or not love.quit() then
--           return a or 0
--         end
--       end
--       lh[name](a,b,c,d,e,f)
--     end

    -- Update dt, as we'll be passing it to update
    dt = lt.step()

    -- Call update and draw
    love.update(dt)

    lg.origin()
    lg.clear(lg.getBackgroundColor())
    love.draw()
    lg.present()

    lt.sleep(0.001)
  end
end
