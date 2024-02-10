local urutora = require('urutora')
local ui = urutora:new()


function love.load()
  local clickMe = urutora.button({
    text = 'Click me!',
    x = 10, y = 10,
    w = 500, h = 50, cr = 25
  })
  local num = 0
  clickMe:action(function(e)
    num = num + 1
    e.target.text = 'You clicked me ' .. num .. ' times!'
  end)

  local panel = urutora.panel({
    text = 'This is a panel!',
    x = 10, y = 80,
    w = 500, h = 400,
    rows = 8, cols = 1
  })
  local slider = urutora.slider({
    value = 7.5,
    minValue = 5, maxValue = 10,
    cr=25, round=true
  })
  local label = urutora.label({
    text = function()
      return string.format('%.2f', slider.svalue);
    end,
    textAlign = 'center'
  })
  local button = urutora.button({
    text = 'Button!',
    cr = 25
  })
  local rpanel = urutora.panel({
    rows = 1, cols = 3
  })
  local multi = urutora.multi({
    items={'1...', '2...', '3!!!'}, cr=25
  })
  local img = love.graphics.newImage('love.png')
  local image = urutora.image({
    image=img
  })
  local input = urutora.text({
    text='', placeholder_text='Digite aqui.'
  })

  local joystick = urutora.joy({x=750,y=250,w=100,h=100})

  local t1 = urutora.toggle({text = 'One!', cr=25})
  local t2 = urutora.toggle({text = 'Two!', cr=25})
  local t3 = urutora.toggle({text = 'Three!', cr=25})

  rpanel:addAt(1,1, t1)
  rpanel:addAt(1,2, t2)
  rpanel:addAt(1,3, t3)

  panel:addAt(1,1, slider)
  panel:addAt(2,1, label)
  panel:addAt(3,1, button)
  panel:addAt(4,1, rpanel)
  panel:addAt(5,1, multi)
  panel:addAt(6,1, image)
  panel:addAt(7,1, input)

  ui:add(clickMe)
  ui:add(panel)
  ui:add(joystick)
end


function love.update(dt)
  ui:update(dt)
end

local lg = love.graphics
lg.setBackgroundColor(0.1,0.1,0.1)
function love.draw()
  ui:draw()
  lg.print(love.timer.getFPS(), 10, 10)
  lg.circle('line', 800,300, 100)
  lg.print(collectgarbage('count')/1024 .. 'mb',10,25)
end


love.keyboard.setKeyRepeat(true)
function love.mousepressed(x, y, button) ui:pressed(x, y) end
function love.mousemoved(x, y, dx, dy) ui:moved(x, y, dx, dy) end
function love.mousereleased(x, y, button) ui:released(x, y) end
function love.textinput(text) ui:textinput(text) end
function love.wheelmoved(x, y) ui:wheelmoved(x, y) end

function love.keypressed(k, scancode, isrepeat)
    ui:keypressed(k, scancode, isrepeat)

  if k == 'escape' then
    love.event.quit()
  end
end
