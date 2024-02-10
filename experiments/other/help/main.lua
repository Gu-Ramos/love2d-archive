local canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), {
   format = 'normal',
   msaa = 8,
})
canvas:renderTo(function()
   love.graphics.push 'all'
       love.graphics.setColor(1, 0, 0)
       love.graphics.circle('fill', 200, 200, 64)
   love.graphics.pop()
end)

function love.draw()
   love.graphics.push 'all'
       love.graphics.clear(0, 1, 0)
       love.graphics.setBlendMode('alpha', 'premultiplied')
       love.graphics.setColor(1, 0, 0)
       love.graphics.circle('fill', 200, 200, 64)
   love.graphics.pop()
end
