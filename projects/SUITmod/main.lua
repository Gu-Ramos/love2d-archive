UI = require('UI')
local lg = love.graphics
local stats = {}
lg.getStats(stats)
love.keyboard.setKeyRepeat(true)

mesh = lg.newMesh({
  {0,0,   0,0, 1,0,0,1},
  {200,0, 1,0, 0,1,0,1},
  {200,50,1,1, 0,0,1,1},
  {0,50,  0,1, 1,0,1,1}
})

local theme = {
  normal   = {bg = {0.96, 0.96, 0.96}, fg = {0.13, 0.13, 0.13}},
  hovered  = {bg = {0.7, 0.7, 0.7}, fg = {0.13, 0.13, 0.13}},
  active   = {bg = {0.7, 0.2, 0.2}, fg = {0.13, 0.13, 0.13}}
}

local invtheme = {
  normal   = {fg = {0.96, 0.96, 0.96}, bg = {0, 0, 0}},
  hovered  = {fg = {0.96, 0.96, 0.96}, bg = {0, 0, 0}},
  active   = {fg = {0.7, 0.7, 0.7}, bg = {0, 0, 0}}
}

local font = lg.newFont('Comfortaa.ttf', 20)
local main = UI.newScreen('main',theme)
local sub = UI.newScreen('sub',theme)
local debug = UI.newScreen('debug',theme)
UI.activateScreen('main')

lg.setBackgroundColor(0.125,0.125,0.125)

main:newWidget('Button', 'Button', 'Button', {font=font, cornerRadius=25},
               100,100, 200,50,
               function(self)
                 self.w[1] = self.w[1] == 'Botão' and 'Button' or 'Botão'
               end)

main:newWidget('Checkbox', 'Check', {text='Checked!!!', utext='Not checked...'}, {font=font, cornerRadius=25, align='center', t_color=invtheme},
               100,160, 200,50,
               function(self)
                 if self.w[1].checked then
                   UI.activateScreen('sub')
                 else
                   UI.deactivateScreen('sub')
                 end
               end)

main.layout:reset(310,100)
main.layout:padding(10,10)
local x,y, w,h = main.layout:row(200,50)

main:newWidget('Input', 'Input', {text='',placeholder='Type here...'}, {font=font, cornerRadius=25, align='center'},
               x,y,w,h)

x,y, w,h = main.layout:row(200,50)
local sl1 = {min=1,value=3,max=5,svalue=3,round=false}
main:newWidget('Slider', 'Slider_normal', sl1, {fgtexture=nil,font=font, cornerRadius=12.5, align='center', color=invtheme},
               x,y,w,h)

x,y, w,h = main.layout:row(200,50)
local sl2 = {min=1,value=3,max=5,round=true}
main:newWidget('Slider', 'Slider_round', sl2, {font=font, cornerRadius=12.5, align='center', color=invtheme},
               x,y,w,h)

main.layout:reset(520,100)
main.layout:padding(10,10)

local function index_of(t, a)
	if a == nil then return nil end
	for i = 1, #t do
		if a == t[i] then
			return i
		end
	end
	return nil
end

radio = {
  {text={}},{text={}},{text={}},{text={}},{text={}},
  max=3,active={}
}

radio[1].text = function() return tostring(index_of(radio.active, 1) or '-') end
radio[2].text = function() return tostring(index_of(radio.active, 2) or '-') end
radio[3].text = function() return tostring(index_of(radio.active, 3) or '-') end
radio[4].text = function() return tostring(index_of(radio.active, 4) or '-') end
radio[5].text = function() return tostring(index_of(radio.active, 5) or '-') end

x,y, w,h = main.layout:row(200,50)
main:newWidget('Radio','r1',{id=1,list=radio}, {font=font, cornerRadius=25, align='center', t_color=invtheme}, x,y,w,h)
x,y, w,h = main.layout:row(200,50)
main:newWidget('Radio','r2',{id=2,list=radio}, {font=font, cornerRadius=25, align='center', t_color=invtheme}, x,y,w,h)
x,y, w,h = main.layout:row(200,50)
main:newWidget('Radio','r3',{id=3,list=radio}, {font=font, cornerRadius=25, align='center', t_color=invtheme}, x,y,w,h)
x,y, w,h = main.layout:row(200,50)
main:newWidget('Radio','r4',{id=4,list=radio}, {font=font, cornerRadius=25, align='center', t_color=invtheme}, x,y,w,h)
x,y, w,h = main.layout:row(200,50)
main:newWidget('Radio','r5',{id=5,list=radio}, {font=font, cornerRadius=25, align='center', t_color=invtheme}, x,y,w,h)


main:newWidget('Checkbox', 'Debug', {text='Debugging...', utext='Debug?'}, {font=font, cornerRadius=25, align='center', t_color=invtheme},
               730,40, 200,50,
               function(self)
                 if self.w[1].checked then
                   UI.activateScreen('debug')
                 else
                   UI.deactivateScreen('debug')
                 end
               end)


debug:newWidget('Screen', 'Screen', true, {cornerRadius=25,color=invtheme}, 730,100, 200,300)
debug.layout:reset(730,110)
debug.layout:padding(10,10)

debug:newWidget('Label', 'fps', function() return 'FPS: '..love.timer.getFPS(); end,
                {color=invtheme,font=font}, debug.layout:row(200,20))

debug:newWidget('Label', 'drawCalls', function() return 'Draw calls: '..stats.drawcalls; end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'drawBatched', function() return 'Draws batched: '..stats.drawcallsbatched; end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'memory', function() return string.format('Memory: %.1fmb', collectgarbage('count')/1024); end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'tmemory', function() return string.format('Texture: %d bytes', stats.texturememory); end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'slider1', function() return string.format('Slider 1: %.1f', sl1.value); end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'slider2', function() return string.format('Slider 2: %.1f', sl2.value); end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'slider1s', function() return string.format('Smooth 1: %.1f', sl1.svalue); end,
                {color=invtheme,font=font}, debug.layout:row())

debug:newWidget('Label', 'slider2s', function() return string.format('Smooth 2: %.1f', sl2.svalue); end,
                {color=invtheme,font=font}, debug.layout:row())


sub:newWidget('Button', 'Close', 'Close me', {font=font, cornerRadius=25, drawMode='line', t_color=invtheme},
              100,225, 200,50,
              function(self)
                main:getWidget('Check').w[1].checked = false
                UI.deactivateScreen('sub')
              end)


function love.update(dt)
  UI.update(dt)
end

function love.draw()
  UI.draw()
  lg.getStats(stats)
end

lg.setFont(font)

function love.keypressed(k)
  if k == 'escape' then love.event.quit(); end
  UI.keypressed(k)
end

function love.textinput(t)
  UI.textinput(t)
end

function love.quit()
end

