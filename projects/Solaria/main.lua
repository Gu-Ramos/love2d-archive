function love.run()
  love.load()

  -- We don't want the first frame's dt to include time taken by love.load.
  love.timer.step()

  -- Main loop time.
  local le = love.event
  local lh = love.handlers
  local lt = love.timer
  return function()
    -- Process events.
    le.pump()
    for name, a,b,c,d,e,f in le.poll() do
      if name == "quit" then
        if not love.quit or not love.quit() then
          return a or 0
        end
      end
      lh[name](a,b,c,d,e,f)
    end

    -- Call update and draw
    love.update(lt.step()) -- will pass 0 if love.timer is disabled

    if lg.isActive() then
      lg.origin()
      lg.clear(lg.getBackgroundColor())

      love.draw()

      lg.present()
    end

    lt.sleep(0.001)
  end
end

local start = require('load')

function love.load()
  start()
  Camera = Stalker(1920/2,1080/2, 1920, 1080)
  Camera:setFollowStyle('LOCKON')
  Camera:setFollowLerp(0.05)
  Camera:setFollowLead(25)
  collectgarbage('collect')
end

function love.update(dt)
  if Splash then Splash:update(dt); return; end
  if State.sfade < 1 then
    local fade = State.sfade
    State.sfade = fade+dt/2
    lg.setColor(fade,fade,fade,fade)
    for _, preset in pairs(UI.color) do
      preset.normal.bg[4] = fade
      preset.normal.fg[4] = fade

      preset.hovered.bg[4] = fade
      preset.hovered.fg[4] = fade

      preset.active.bg[4] = fade
      preset.active.fg[4] = fade
    end
  end

  updateScaling(love.window.getMode())

  World:update(dt)
  UI:draw(dt)
  Particles.line:update(dt)
  Particles.circle:update(dt)
  Camera:update(dt)
  Camera:follow(Body:getPosition())

  if lk.isDown('w') then Body:applyForce(0,-10000) end
  if lk.isDown('a') then Body:applyForce(-10000,0) end
  if lk.isDown('s') then Body:applyForce(0,10000) end
  if lk.isDown('d') then Body:applyForce(10000,0) end
end

local function drawGame()
  lg.push()
  lg.applyTransform(Scale.transform)
  Camera:attach()

  lg.draw(Particles.line)
  lg.draw(Particles.circle)
  lg.setLineWidth(6)
  lp.debug(World,State.sfade,3)

  Camera:detach()
  Suit.draw()
  lg.pop()
end

function love.draw()
  if Splash then
    Splash:draw()
    lg.setColor(1,1,1,1)
    lg.print(love.timer.getFPS(),10,10)
    return
  end
  if Conf.post.csep or Conf.post.bloom then
    lg.setCanvas({Canvas1,stencil=true})
    lg.clear()
  end

  drawGame()
  lg.setColor(1,1,1,1)

  if Conf.post.csep or Conf.post.bloom then
    -- Blur shaders
    if Conf.post.bloom then
      local st = Conf.post.bloomSt
      lg.setBlendMode('add', 'premultiplied')
      lg.setShader(Assets.shaders.bloom[st])
      -- Blur shader pass 1
      lg.setCanvas(Canvas2)
      lg.clear()
      Assets.shaders.bloom[st]:send('direction', {1/lg.getWidth(),0})
      lg.draw(Canvas1)

      -- Blur shader pass 2
      lg.setCanvas(Canvas3)
      lg.clear()
      Assets.shaders.bloom[st]:send('direction', {0,1/lg.getHeight()})
      lg.draw(Canvas2)
    end

    -- Final post-processing
    lg.setCanvas()
    lg.clear()
    lg.setShader(Conf.post.csep and Assets.shaders.chroma or nil)
    lg.draw(Canvas1)
    if Conf.post.bloom then lg.draw(Canvas3); end
    lg.setShader()
    lg.setBlendMode('add','alphamultiply')
  end
  lg.print(love.timer.getFPS(),10,10)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  if Splash then Splash:skip(); return; end
  if k == 'return' then
    Camera:shake(16,1,60,'XY')
  end
end

function love.mousepressed(x,y)
  if Splash then Splash:skip(); return; end
  Particles.circle:setPosition(Camera:toWorldCoords(Scale.transform:inverseTransformPoint(x,y)))
  Particles.circle:emit(500)
end
