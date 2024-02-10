function love.run()
  love.load()
  
  -- We don't want the first frame's dt to include time taken by love.load.
  love.timer.step()

  collectgarbage('collect')
  
  -- Main loop time.
  return function()
    -- Process events.
    love.event.pump()
    for name, a,b,c,d,e,f in love.event.poll() do
      if name == "quit" then
        if not love.quit or not love.quit() then
          return a or 0
        end
      end
      love.handlers[name](a,b,c,d,e,f)
    end

    -- Call update and draw
    love.update(love.timer.step()) -- will pass 0 if love.timer is disabled
    
    if love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      
      love.draw()
      
      love.graphics.present()
    end
    
    love.timer.sleep(0.001)
  end
end

function HSL(h, s, l, a)
  if s<=0 then return l,l,l,a end
  h, s, l = h/256*6, s/255, l/255
  local c = (1-math.abs(2*l-1))*s
  local x = (1-math.abs(h%2-1))*c
  local m,r,g,b = (l-.5*c), 0,0,0
  if h < 1     then r,g,b = c,x,0
elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m)*255,(g+m)*255,(b+m)*255,a
end
triangulate = require('delaunay')


local rect = {}
for c = 16, 1, -1 do
  table.insert(rect, math.sin(math.rad(c/16*360))*100+500)
  table.insert(rect, math.cos(math.rad(c/16*360))*100+250)
end

rect = triangulate(rect)

love.graphics.setLineJoin('none')
local i = 1
function love.load() end
function love.update() end
function love.keypressed(k) if k=='escape' then love.event.quit(); end; end
love.graphics.setBlendMode('add')
function love.draw()
  for c = 1, #rect do
    love.graphics.polygon('line',rect[c])
  end
end
function love.keypressed(k)
  if k == 'space' then
    i = i+1
  end
end
