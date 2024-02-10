local Text = require('slog-text')
Text.configure.function_command_enable(true)
lg = love.graphics

lg.setBackgroundColor(0.9,0.9,0.9)

local font = lg.newFont("Inter-Medium.otf", 30)

my_textbox = Text.new('left', {color = {0,0,0,1}, shadow_color = {0.5,0.5,1,0.4}, font = font})
hello_cute = '[rainbow] Hello world! :3[/rainbow]'
my_textbox:send("[rainbow]Ana Bernadete Barroso Oriá Quevedo - 2º ano aplicação[/rainbow]")
my_textbox:send(hello_cute)

function love.update(dt)
  my_textbox:update(dt)
end

function love.draw()
  my_textbox:draw(20,100)
  lg.setColor(0,0,0,1)
  lg.print(love.timer.getFPS(), 10, 10)
end

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  my_textbox:continue()
end



