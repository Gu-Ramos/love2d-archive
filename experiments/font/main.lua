local str = [==[( ͡° ͜ʖ ͡°)
(° ͜ʖ°)
. ͡ .
•‿•
◕‿◕✿
(° ͟ʖ°)
( ͠° ͟ʖ ͡°)
the quick brown fox jumps over the lazy dog
THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG
1234567890
@#$_&-+()/*"':;!?~`|£¢€¥^°={}\\%[] ]==]

love.graphics.setFont(love.graphics.newFont('Inter-Medium.otf',30))

function love.draw()
  love.graphics.print(str,10,10)
end

function love.keypressed(k) if k == 'escape' then love.event.quit(); end; end
