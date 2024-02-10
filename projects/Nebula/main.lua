require('lib.helpers')
love.load = require('load')
local lg = love.graphics
lg.setLineWidth(10)

function love.update(dt)
  updateScaling(love.window.getMode())
  UI.update(dt)
  Flux.update(dt)
  Game:update(dt)

  for i = 1, 4 do
    for ii = 1, #DrawList[i] do
      DrawList[i][ii]:update(dt)
    end
  end
end

function love.draw()
  UI.drawBG()
  lg.push()
  lg.applyTransform(Transform.obj)
    Game:draw()
    UI.draw()

    -- Title screen
    local alpha = UI.getScreen('menu').opacity
    if alpha > 0 then
      lg.setColor(1,1,1, alpha)
      local blend = UI.getBlend()
      local bgColor = UI.getBgColor()
      if bgColor ~= 'red' then
        if blend < 1 and bgColor == 'black' then
          lg.setColor(1,1,1, 1-blend*alpha)
          lg.draw(Assets.misc.title_r, 640, 140, 0, 1.25)
          lg.setColor(1,1,1, blend*alpha)
        end
        lg.draw(Assets.misc.title, 640, 140, 0, 1.25)
      else
        if blend < 1 then
          lg.setColor(1,1,1, 1-blend*alpha)
          lg.draw(Assets.misc.title, 640, 140, 0, 1.25)
          lg.setColor(1,1,1, blend*alpha)
        end
        lg.draw(Assets.misc.title_r, 640, 140, 0, 1.25)
      end
    end

    -- Draws the drawables in order
    lg.setColor(1,1,1,1)
    for i = 1, 4 do
      for ii = 1, #DrawList[i] do
        DrawList[i][ii]:draw()
      end
    end


    -- Debug info
    if State.debug then
      lg.setColor(0.2,0.2,0.2,0.5)
      lg.rectangle('fill', 0,240, 400,200)
      lg.setColor(1,1,1,1)
      local stats = lg.getStats()
      lg.print('FPS: '..love.timer.getFPS(), 10,240)
      lg.print('Draw calls: '..stats.drawcalls, 10, 267)
      lg.print(string.format('Memory: %.2f mb', collectgarbage('count')/1024), 10, 294)
      lg.print(string.format('Texture memory: %.2f mb',stats.texturememory/1048576), 10, 321)
      lg.print('Batched calls: '..stats.drawcallsbatched, 10, 348)
      lg.print('Images loaded: '..stats.images, 10,375)
      lg.print('Fonts loaded: '..stats.fonts, 10,402)
    end
  lg.pop()
end

function love.textinput(t)
  UI.textinput(t)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  UI.keypressed(k)
  Game:keypressed(k)
end

function love.mousepressed(b, x,y)
  Game:mousepressed(b, x,y)
end
