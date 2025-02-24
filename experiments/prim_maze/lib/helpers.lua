love.network = {
  update = function()end,
  delay = 1/10,
  timer = 0
}

function love.resize(nw, nh)
  local scale = 16/9*nw > nh and nh/1080 or nw/1920
  local tx, ty = nw/2-1920*scale/2, nh/2-1080*scale/2

  local transform = love.math.newTransform(tx,ty, 0, scale,scale, 0,0)

  local rx0, ry0 = transform:inverseTransformPoint(0,0)
  local rx1, ry1 = transform:inverseTransformPoint(nw,nh)

  love.scale = {
    transform = transform,
    x = tx, y = ty, sc = scale,
    x0 = rx0, y0 = ry0,
    x1 = rx1, y1 = ry1,
    w = nw, h = nh
  }
end

love.resize(love.graphics.getDimensions())

function love.run()
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  love.timer.step()

  local dt = 0
  local lt = love.timer
  local lg = love.graphics
  local le = love.event
  local lh = love.handlers
  local ln = love.network

  -- Main loop.
  return function()
    le.pump()
    for name, a,b,c,d,e,f in le.poll() do
      if name == "quit" then
        if not love.quit or not love.quit() then
          return a or 0
        end
      end
      lh[name](a,b,c,d,e,f)
    end

    -- Update dt, as we'll be passing it to update
    dt = lt.step()

    ln.timer = ln.timer + dt
    if ln.timer >= ln.delay then
      ln.update(dt,ln.timer)
      ln.timer = 0
    end

    -- Call update and draw
    love.update(dt)

    if lg.isActive() then
      lg.origin()
      lg.clear(lg.getBackgroundColor())
      love.draw()
      lg.present()
    end

    lt.sleep(0.001)
  end
end
