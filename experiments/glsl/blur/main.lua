local getFPS = love.timer.getFPS
local graphics = love.graphics
function love.load()
  img = love.graphics.newImage('img.jpg')
  bloom = graphics.newShader[[extern vec2 direction;
                                 vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc)
                                {
                                 vec4 c = 1.000000 * texture2D(tex, tc);
                                c += 1.508854 * (texture2D(tex, tc + 7.500000 * direction) + texture2D(tex, tc - 7.500000 * direction));
                                c += 1.717767 * (texture2D(tex, tc + 5.500000 * direction) + texture2D(tex, tc - 5.500000 * direction));
                                c += 1.879114 * (texture2D(tex, tc + 3.500000 * direction) + texture2D(tex, tc - 3.500000 * direction));
                                c += 1.975211 * (texture2D(tex, tc + 1.500000 * direction) + texture2D(tex, tc - 1.500000 * direction));
                                return c * vec4(0.065955) * color;
                                }]]
  Canvas1 = graphics.newCanvas(wx,wy,{type='2d',format='rgba8',readable=true,msaa=0})
  Canvas2 = graphics.newCanvas(wx,wy,{type='2d',format='rgba8',readable=true,msaa=0})
  Canvas3 = graphics.newCanvas(wx,wy,{type='2d',format='rgba8',readable=true,msaa=0})
  love.graphics.setShader(bloom)
end
function love.draw()
  graphics.setCanvas(Canvas1)
  graphics.clear()
  graphics.draw(img)
  
  graphics.setBlendMode('add', 'premultiplied')
  graphics.setShader(bloom)
  -- Blur shader pass 1
  graphics.setCanvas(Canvas2)
  graphics.clear()
  bloom:send('direction', {1/graphics.getWidth(),0})
  graphics.draw(Canvas1)
  
  -- Blur shader pass 2
  graphics.setCanvas(Canvas3)
  graphics.clear()
  bloom:send('direction', {0,1/graphics.getHeight()})
  graphics.draw(Canvas2)
  
  graphics.setCanvas()
  graphics.clear()
  graphics.draw(Canvas3)
  love.graphics.setColor(1,1,1,1)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
end
